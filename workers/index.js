// Timbo Gemini API Proxy + Payment Verification — Cloudflare Worker

const GEMINI_MODEL = 'gemini-2.0-flash';
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}`;
const FLW_BASE = 'https://api.flutterwave.com/v3';

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

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    if (url.pathname === '/health') {
      return jsonResponse({ status: 'ok' });
    }

    // --- Verify a Flutterwave transaction ---
    if (url.pathname === '/verify-payment' && request.method === 'POST') {
      try {
        const body = await request.json();
        const { tx_ref } = body;
        if (!tx_ref) return jsonResponse({ error: 'Missing tx_ref' }, 400);

        const flwSecretKey = env.FLW_SECRET_KEY;
        if (!flwSecretKey) {
          return jsonResponse({ error: 'Payment not configured' }, 500);
        }

        const verifyUrl = `${FLW_BASE}/transactions/verify_by_reference?tx_ref=${tx_ref}`;
        const resp = await fetch(verifyUrl, {
          headers: { Authorization: `Bearer ${flwSecretKey}` },
        });
        const result = await resp.json();

        if (!resp.ok || result.status !== 'success') {
          return jsonResponse({ verified: false, error: 'Transaction not found or failed' });
        }

        const data = result.data;
        const expectedAmount = parseInt(env.EXPECTED_PRICE || '5000', 10);
        const paidAmount = parseInt(data.amount, 10);

        if (paidAmount < expectedAmount) {
          return jsonResponse({ verified: false, error: 'Amount mismatch' });
        }

        return jsonResponse({
          verified: true,
          tx_ref: data.tx_ref,
          amount: data.amount,
          currency: data.currency,
          charged_amount: data.charged_amount,
        });
      } catch (err) {
        return jsonResponse({ error: err.message }, 500);
      }
    }

    // --- Payment callback (user lands here after payment) ---
    if (url.pathname === '/payment-callback' && request.method === 'GET') {
      const txRef = url.searchParams.get('tx_ref');
      const status = url.searchParams.get('status');
      return jsonResponse({
        status: status || 'completed',
        tx_ref: txRef,
        message: 'Payment processed. You can close this tab.',
      });
    }

    // --- Gemini proxy (existing) ---
    if (request.method !== 'POST') {
      return jsonResponse({ error: 'Method not allowed' }, 405);
    }

    const apiKey = env.GEMINI_API_KEY;
    if (!apiKey) return jsonResponse({ error: 'Server misconfigured' }, 500);

    // Rate limiting
    const ip = request.headers.get('CF-Connecting-IP') || 'unknown';
    const rateKey = `rl:${ip}`;
    const now = Date.now();
    const rlRaw = await env.RATE_LIMIT?.get(rateKey);
    const rl = rlRaw ? JSON.parse(rlRaw) : null;
    if (rl && now - rl.resetAt < RATE_WINDOW_MS && rl.count >= RATE_LIMIT) {
      return jsonResponse({ error: 'Rate limit exceeded' }, 429);
    }
    const newRl = rl && now - rl.resetAt < RATE_WINDOW_MS
      ? { count: rl.count + 1, resetAt: rl.resetAt }
      : { count: 1, resetAt: now + RATE_WINDOW_MS };
    try { await env.RATE_LIMIT?.put(rateKey, JSON.stringify(newRl), { expirationTtl: 120 }); } catch (_) {}

    try {
      const body = await request.json();
      const { prompt, history, systemPrompt } = body;

      if (!prompt || typeof prompt !== 'string') {
        return jsonResponse({ error: 'Missing "prompt"' }, 400);
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
        return jsonResponse({ error: 'AI service unavailable' }, 502);
      }

      const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
      return jsonResponse({ [isChat ? 'reply' : 'text']: text });
    } catch (err) {
      console.error('Worker error:', err.message);
      return jsonResponse({ error: 'Internal error' }, 500);
    }
  },
};
