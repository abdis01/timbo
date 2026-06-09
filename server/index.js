const express = require('express');
const cors = require('cors');
const { GoogleGenerativeAI } = require('@google/generative-ai');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '1mb' }));

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error('❌ GEMINI_API_KEY not set. Copy .env.example to .env and fill in your key.');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(apiKey);

// Simple rate limiting
const rateLimit = new Map();
function checkRateLimit(ip, limit = 30, windowMs = 60_000) {
  const now = Date.now();
  const entry = rateLimit.get(ip);
  if (!entry || now - entry.resetAt > windowMs) {
    rateLimit.set(ip, { count: 1, resetAt: now + windowMs });
    return true;
  }
  if (entry.count >= limit) return false;
  entry.count++;
  return true;
}

// Health check
app.get('/health', (_, res) => res.json({ status: 'ok' }));

// Chat endpoint — POST /chat
app.post('/chat', async (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  if (!checkRateLimit(ip)) {
    return res.status(429).json({ error: 'Rate limit exceeded.' });
  }

  const { prompt, history, systemPrompt } = req.body;
  if (!prompt || typeof prompt !== 'string') {
    return res.status(400).json({ error: 'Missing "prompt" field.' });
  }

  try {
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
    res.json({ reply: result.response.text() });
  } catch (err) {
    console.error('Chat error:', err.message);
    res.status(502).json({ error: 'AI service temporarily unavailable.' });
  }
});

// Generate endpoint — POST /generate
app.post('/generate', async (req, res) => {
  const ip = req.ip || req.connection.remoteAddress;
  if (!checkRateLimit(ip)) {
    return res.status(429).json({ error: 'Rate limit exceeded.' });
  }

  const { prompt, systemPrompt } = req.body;
  if (!prompt) {
    return res.status(400).json({ error: 'Missing "prompt".' });
  }

  try {
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.0-flash',
      systemInstruction: systemPrompt
        ? { role: 'system', parts: [{ text: systemPrompt }] }
        : undefined,
    });

    const result = await model.generateContent(prompt);
    res.json({ text: result.response.text() });
  } catch (err) {
    console.error('Generate error:', err.message);
    res.status(502).json({ error: 'AI service unavailable.' });
  }
});

app.listen(PORT, () => {
  console.log(`✅ Timbo Gemini proxy running on port ${PORT}`);
  console.log(`   POST /chat     — Chat endpoint`);
  console.log(`   POST /generate — Generate endpoint`);
  console.log(`   GET  /health   — Health check`);
});
