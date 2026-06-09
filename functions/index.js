const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

admin.initializeApp();

// API key stays server-side — set via functions/.env file (deployed as env var)
const getApiKey = () => {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error('GEMINI_API_KEY env var not set. Add it to functions/.env and redeploy.');
  return key;
};

const rateLimitMap = new Map();
const RATE_LIMIT = 30;
const RATE_WINDOW_MS = 60_000;

function checkRateLimit(uid) {
  const now = Date.now();
  const entry = rateLimitMap.get(uid);
  if (!entry || now - entry.resetAt > RATE_WINDOW_MS) {
    rateLimitMap.set(uid, { count: 1, resetAt: now + RATE_WINDOW_MS });
    return true;
  }
  if (entry.count >= RATE_LIMIT) return false;
  entry.count++;
  return true;
}

async function verifyAuth(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Error('Missing or invalid Authorization header');
  }
  const idToken = authHeader.slice(7);
  const decoded = await admin.auth().verifyIdToken(idToken);
  return decoded;
}

exports.geminiChat = onRequest(
  { cors: true },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    let uid;
    try {
      const decoded = await verifyAuth(req.headers.authorization);
      uid = decoded.uid;
    } catch (_) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    if (!checkRateLimit(uid)) {
      res.status(429).json({ error: 'Rate limit exceeded. Try again later.' });
      return;
    }

    const { prompt, history, systemPrompt } = req.body || {};
    if (!prompt || typeof prompt !== 'string') {
      res.status(400).json({ error: 'Missing "prompt" field.' });
      return;
    }

    try {
      const genAI = new GoogleGenerativeAI(getApiKey());
      const model = genAI.getGenerativeModel({
        model: 'gemini-2.0-flash',
        systemInstruction: systemPrompt
          ? { role: 'system', parts: [{ text: systemPrompt }] }
          : undefined,
      });

      const chat = model.startChat({
        history: (history || []).map((msg) => ({
          role: msg.role,
          parts: [{ text: msg.parts || msg.content }],
        })),
      });

      const result = await chat.sendMessage(prompt);
      const text = result.response.text();
      res.json({ reply: text });
    } catch (err) {
      console.error('Gemini API error:', err);
      res.status(502).json({ error: 'AI service temporarily unavailable.' });
    }
  }
);

exports.geminiGenerate = onRequest(
  { cors: true },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const decoded = await verifyAuth(req.headers.authorization);
      if (!checkRateLimit(decoded.uid)) {
        res.status(429).json({ error: 'Rate limit exceeded.' });
        return;
      }
    } catch (_) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const { prompt, systemPrompt } = req.body || {};
    if (!prompt) {
      res.status(400).json({ error: 'Missing "prompt".' });
      return;
    }

    try {
      const genAI = new GoogleGenerativeAI(getApiKey());
      const model = genAI.getGenerativeModel({
        model: 'gemini-2.0-flash',
        systemInstruction: systemPrompt
          ? { role: 'system', parts: [{ text: systemPrompt }] }
          : undefined,
      });

      const result = await model.generateContent(prompt);
      res.json({ text: result.response.text() });
    } catch (err) {
      console.error('Gemini generate error:', err);
      res.status(502).json({ error: 'AI service unavailable.' });
    }
  }
);
