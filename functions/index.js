const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Groq = require("groq-sdk");

admin.initializeApp();

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

exports.askTimboAI = functions.https.onCall(async (data, context) => {
  const { question, timboContext, chatHistory } = data;

  const systemPrompt = `You are Timbo AI — a warm, intelligent personal notebook assistant.
You help the user make sense of their thoughts, notes, and ideas.
Speak in short, clear sentences. Be helpful, not chatty.
You have access to the user's notes (called Timbos).
Answer based on what you know from their notes. If unsure, say so.

User's recent Timbos:
${timboContext || "No notes yet."}`;

  const messages = [
    { role: "system", content: systemPrompt },
    ...(chatHistory || []).map(m => ({ role: m.role, content: m.content })),
    { role: "user", content: question }
  ];

  const completion = await groq.chat.completions.create({
    model: "llama-3.3-70b-versatile",
    messages,
    max_tokens: 500,
    temperature: 0.7,
  });

  return { reply: completion.choices[0].message.content };
});

exports.getDailyInsight = functions.https.onCall(async (data) => {
  const { recentNotes } = data;

  const completion = await groq.chat.completions.create({
    model: "llama-3.3-70b-versatile",
    messages: [{
      role: "user",
      content: `Based on these notes: "${recentNotes}"\n\nWrite ONE warm, personal sentence (max 20 words) reflecting what this person has been thinking about. Do not start with "You".`
    }],
    max_tokens: 60,
    temperature: 0.8,
  });

  return { insight: completion.choices[0].message.content.trim() };
});

exports.generateTimbo = functions.https.onCall(async (data) => {
  const { request } = data;

  const completion = await groq.chat.completions.create({
    model: "llama-3.3-70b-versatile",
    messages: [{
      role: "user",
      content: `Create a practical note about: "${request}"\nReply ONLY with JSON:\n{"title":"max 5 words","blocks":[{"type":"text","content":"..."},{"type":"checklist","items":["item1","item2"]}]}`
    }],
    max_tokens: 300,
    temperature: 0.6,
  });

  const text = completion.choices[0].message.content.replace(/\`\`\`json|\`\`\`/g, "").trim();
  return JSON.parse(text);
});

const { GoogleGenerativeAI } = require("@google/generative-ai");

const apiKey = process.env.GEMINI_API_KEY;

exports.processCapture = functions.https.onCall(async (data) => {
  const { rawInput } = data;
  if (!rawInput || typeof rawInput !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "rawInput is required");
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

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
  const json = JSON.parse(text.replace(/```json|```/g, "").trim());
  return json;
});

exports.dailySummary = functions.https.onCall(async (data) => {
  const { captures } = data;

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

  const prompt = `
    You are Timbo AI. Given the user's captures for today, generate a single
    friendly sentence summarizing their activity.

    Captures: ${JSON.stringify(captures || [])}

    Reply with one sentence only. No markdown. No JSON.
    Example: "You've captured 3 thoughts today. 1 reminder coming up at 6pm."
  `;

  const result = await model.generateContent(prompt);
  return { summary: result.response.text() };
});
