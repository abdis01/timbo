# Gemini API Proxy — Deployment Guide

The proxy keeps your Gemini API key on the server so it's never exposed in the app binary.

## Option A: Vercel (Recommended — Free, no credit card)

1. Push the `server/` folder to a GitHub repo (or use the CLI)

2. Install Vercel CLI and deploy:
   ```bash
   cd server
   npm install
   npx vercel --prod
   ```

3. Set the environment variable in Vercel dashboard:
   - Go to your project on vercel.com → Settings → Environment Variables
   - Add `GEMINI_API_KEY` with your key value

4. Update `lib/config/constants.dart`:
   ```dart
   static const String? geminiProxyUrl = 'https://your-app.vercel.app';
   ```

## Option B: Render (Free tier)

1. Create a new Web Service on [render.com](https://render.com)
2. Connect your GitHub repo (or use the `server/` folder)
3. Settings:
   - Build Command: `cd server && npm install`
   - Start Command: `cd server && node index.js`
   - Add `GEMINI_API_KEY` as an environment variable

## Option C: Local development / self-hosted

```bash
cd server
npm install
npm start
# Runs on http://localhost:3000
```

Then set in constants:
```dart
static const String? geminiProxyUrl = 'http://localhost:3000';
```

## Security Notes

- The `.env` file contains your API key — it's in `.gitignore` and won't be committed
- For Firebase auth verification, add a `FIREBASE_SERVICE_ACCOUNT_PATH` env var pointing to a Firebase service account JSON key
- Rate limiting: 30 requests/minute per IP
