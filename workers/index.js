// Timbo Gemini API Proxy + AzamPay Payment — Cloudflare Worker

const GEMINI_MODEL = 'gemini-2.0-flash';
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}`;

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
    body: JSON.stringify({
      appName,
      clientId,
      clientSecret,
    }),
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

        // Check if using sandbox (based on client_secret pattern or env flag)
        const isSandbox = env.AZAMPAY_SANDBOX !== 'false';

        // Authenticate with AzamPay
        const token = await azampayAuth(app_name, client_id, client_secret, isSandbox);
        if (!token) {
          return errorResponse('Authentication failed', 502);
        }

        // Initiate checkout
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

        // For sandbox testing, we simulate verification
        // In production, this would call AzamPay's transaction status API
        // AzamPay sends callbacks to /azampay-callback which stores results in KV

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
          // Store in KV for verification
          try {
            await env.PAYMENTS?.put(externalId, 'confirmed', { expirationTtl: 86400 });
          } catch (_) {}
        }

        return jsonResponse({ received: true });
      } catch (err) {
        return errorResponse(err.message, 500);
      }
    }

    // --- Payment callback (user sees after redirect — kept for backward compat) ---
    if (url.pathname === '/payment-callback' && request.method === 'GET') {
      return jsonResponse({
        status: 'completed',
        message: 'Payment processed. You can close this tab.',
      });
    }

    // --- Gemini proxy endpoints ---
    if (request.method !== 'POST') {
      return errorResponse('Method not allowed', 405);
    }

    const apiKey = env.GEMINI_API_KEY;
    if (!apiKey) return errorResponse('Server misconfigured', 500);

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

      const contents = [];
      if (history) {
        for (const msg of history) {
          contents.push({
            role: msg.role === 'model' ? 'model' : 'user',
            parts: [{ text: msg.content || msg.parts || '' }],
          });
        }
      }
      contents.push({ role: 'user', parts: [{ text: prompt }] });

      const geminiBody = {
        contents,
        systemInstruction: systemPrompt
          ? { parts: [{ text: systemPrompt }] }
          : undefined,
      };

      const isChat = url.pathname === '/geminiChat' || url.pathname === '/chat';
      const response = await fetch(`${GEMINI_URL}:generateContent?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(geminiBody),
      });

      const data = await response.json();

      if (!response.ok) {
        console.error('Gemini API error:', response.status, JSON.stringify(data));
        return errorResponse('AI service unavailable', 502);
      }

      const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
      return jsonResponse({ [isChat ? 'reply' : 'text']: text });
    } catch (err) {
      console.error('Worker error:', err.message);
      return errorResponse('Internal error', 500);
    }
  },
};
