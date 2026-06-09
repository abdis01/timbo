// Timbo AI + Payment Proxy — Cloudflare Worker
// Supports Groq (primary) and Gemini (fallback)

const GROQ_MODEL = 'llama-3.3-70b-versatile';
const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';

const AZAMPAY_AUTH_SANDBOX = 'https://authenticator-sandbox.azampay.co.tz/AppAuth';
const AZAMPAY_AUTH_PROD = 'https://authenticator.azampay.co.tz/AppAuth';
const AZAMPAY_CHECKOUT_SANDBOX = 'https://sandbox.azampay.co.tz/api/v1/Checkout/MNO';
const AZAMPAY_CHECKOUT_PROD = 'https://api.azampay.co.tz/api/v1/Checkout/MNO';

const RATE_LIMIT = 30;
const RATE_WINDOW_MS = 60_000;

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}

function errorResponse(message, status) {
  return jsonResponse({ error: message }, status);
}

// Authenticate with AzamPay and get an access token
async function azampayAuth(appName, clientId, clientSecret, isSandbox) {
  const url = isSandbox ? AZAMPAY_AUTH_SANDBOX : AZAMPAY_AUTH_PROD;
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ appName, clientId, clientSecret }),
  });
  if (!resp.ok) return null;
  const data = await resp.json();
  return data.data?.accessToken || data.accessToken || null;
}

// Initiate MNO (mobile money) checkout — sends USSD push to phone
async function azampayMnoCheckout(accessToken, payload, isSandbox) {
  const url = isSandbox ? AZAMPAY_CHECKOUT_SANDBOX : AZAMPAY_CHECKOUT_PROD;
  const resp = await fetch(url, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      accountNumber: payload.phone_number,
      amount: payload.amount,
      currency: payload.currency || 'TZS',
      externalId: payload.external_id,
      provider: payload.provider,
      additionalProperties: {},
    }),
  });
  const data = await resp.json();
  return { ok: resp.ok, data };
}

function buildGroqMessages(prompt, history, systemPrompt) {
  const messages = [];
  if (systemPrompt) {
    messages.push({ role: 'system', content: systemPrompt });
  }
  if (history && Array.isArray(history)) {
    for (const msg of history) {
      const role = msg.role === 'model' || msg.role === 'assistant' ? 'assistant' : 'user';
      messages.push({ role, content: msg.content || msg.parts || '' });
    }
  }
  messages.push({ role: 'user', content: prompt });
  return messages;
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    if (url.pathname === '/health') {
      return jsonResponse({ status: 'ok' });
    }

    // --- AzamPay checkout (initiates USSD push) ---
    if (url.pathname === '/azampay-checkout' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { phone_number, amount, currency, provider, external_id, app_name, client_id, client_secret } = body;

        if (!phone_number || !amount || !provider || !external_id) {
          return errorResponse('Missing required fields', 400);
        }

        const isSandbox = env.AZAMPAY_SANDBOX !== 'false';
        const token = await azampayAuth(app_name, client_id, client_secret, isSandbox);
        if (!token) {
          return errorResponse('Authentication failed', 502);
        }

        const result = await azampayMnoCheckout(token, { phone_number, amount, currency, provider, external_id }, isSandbox);

        if (!result.ok) {
          return jsonResponse({
            success: false,
            error: result.data?.message || 'Checkout failed',
            details: result.data,
          });
        }

        return jsonResponse({
          success: true,
          external_id,
          transaction_id: result.data?.data?.transactionId || null,
          message: 'USSD push sent. Check your phone.',
        });
      } catch (err) {
        return errorResponse(err.message, 500);
      }
    }

    // --- AzamPay verify payment status ---
    if (url.pathname === '/azampay-verify' && request.method === 'GET') {
      try {
        const externalId = url.searchParams.get('external_id');
        if (!externalId) return errorResponse('Missing external_id', 400);

        const verified = await env.PAYMENTS?.get(externalId);
        return jsonResponse({
          verified: verified === 'confirmed',
          external_id: externalId,
        });
      } catch (err) {
        return errorResponse(err.message, 500);
      }
    }

    // --- AzamPay callback (webhook from AzamPay after payment) ---
    if (url.pathname === '/azampay-callback') {
      try {
        const body = request.method === 'POST' ? await request.json() : {};
        const externalId = body.externalId || body.external_id || url.searchParams.get('external_id');
        const status = body.status || body.transactionStatus || 'completed';

        if (externalId && (status === 'success' || status === 'completed')) {
          try {
            await env.PAYMENTS?.put(externalId, 'confirmed', { expirationTtl: 86400 });
          } catch (_) {}
        }

        return jsonResponse({ received: true });
      } catch (err) {
        return errorResponse(err.message, 500);
      }
    }

    // --- Payment callback (backward compat) ---
    if (url.pathname === '/payment-callback' && request.method === 'GET') {
      return jsonResponse({
        status: 'completed',
        message: 'Payment processed. You can close this tab.',
      });
    }

    // --- AI proxy endpoints (Groq) ---
    if (request.method !== 'POST') {
      return errorResponse('Method not allowed', 405);
    }

    const apiKey = env.GROQ_API_KEY;
    if (!apiKey) return errorResponse('Server misconfigured', 502);

    // Rate limiting
    const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
    const rateKey = `rl:${ip}`;
    const now = Date.now();
    const rlRaw = await env.RATE_LIMIT?.get(rateKey);
    const rl = rlRaw ? JSON.parse(rlRaw) : null;
    if (rl && now - rl.resetAt < RATE_WINDOW_MS && rl.count >= RATE_LIMIT) {
      return errorResponse('Rate limit exceeded', 429);
    }
    const newRl = rl && now - rl.resetAt < RATE_WINDOW_MS
      ? { count: rl.count + 1, resetAt: rl.resetAt }
      : { count: 1, resetAt: now + RATE_WINDOW_MS };
    try { await env.RATE_LIMIT?.put(rateKey, JSON.stringify(newRl), { expirationTtl: 120 }); } catch (_) {}

    try {
      const body = await request.json();
      const { prompt, history, systemPrompt } = body;

      if (!prompt || typeof prompt !== 'string') {
        return errorResponse('Missing "prompt"', 400);
      }

      const messages = buildGroqMessages(prompt, history, systemPrompt);

      const groqBody = {
        model: GROQ_MODEL,
        messages,
        temperature: 0.7,
        max_tokens: 1024,
      };

      const response = await fetch(GROQ_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify(groqBody),
      });

      const data = await response.json();

      if (!response.ok) {
        console.error('Groq API error:', response.status, JSON.stringify(data));
        return errorResponse('AI service unavailable', 502);
      }

      const text = data.choices?.[0]?.message?.content || '';
      const isChat = url.pathname === '/groqChat' || url.pathname === '/chat';
      return jsonResponse({ [isChat ? 'reply' : 'text']: text });
    } catch (err) {
      console.error('Worker error:', err.message);
      return errorResponse('Internal error', 500);
    }
  },
};
