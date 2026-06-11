const { onCall } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const admin = require('firebase-admin');

admin.initializeApp();

const geminiApiKey = defineSecret('GEMINI_API_KEY');

exports.processCapture = onCall(
  { secrets: [geminiApiKey], cors: true },
  async (request) => {
    const { rawInput } = request.data;
    if (!rawInput || typeof rawInput !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument', 'rawInput is required'
      );
    }

    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

    const prompt = `
      You are Timbo AI, a personal secretary.
      The user said: "${rawInput}"

      Determine what this is and extract structured data.
      Reply ONLY with valid JSON, no explanation, no markdown.

      Format:
      {
        "type": "note" | "expense" | "reminder",
        "content": "clean version of what they said",
        "amount": null or number (for expenses),
        "category": null or one of: Food, Transport, Entertainment, Health, Shopping, Other,
        "scheduledAt": null or ISO 8601 datetime string (for reminders)
      }

      Today is ${new Date().toISOString()}.
      If unsure of type, default to "note".
    `;

    const result = await model.generateContent(prompt);
    const text = result.response.text();
    const json = JSON.parse(text.replace(/```json|```/g, '').trim());
    return json;
  }
);

exports.dailySummary = onCall(
  { secrets: [geminiApiKey], cors: true },
  async (request) => {
    const { captures } = request.data;

    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const genAI = new GoogleGenerativeAI(geminiApiKey.value());
    const model = genAI.getGenerativeModel({ model: 'gemini-2.0-flash' });

    const prompt = `
      You are Timbo AI. Given the user's captures for today, generate a single
      friendly sentence summarizing their activity.

      Captures: ${JSON.stringify(captures || [])}

      Reply with one sentence only. No markdown. No JSON.
      Example: "You've captured 3 thoughts today. 1 reminder coming up at 6pm."
    `;

    const result = await model.generateContent(prompt);
    return { summary: result.response.text() };
  }
);
