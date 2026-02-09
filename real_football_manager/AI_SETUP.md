# AI Chat Integration Setup

The player detail screen now includes AI-powered chat functionality! Here's how to set it up:

## 1. Get Your Groq API Key

1. Go to [https://console.groq.com/](https://console.groq.com/)
2. Sign up for a free account
3. Navigate to the API Keys section
4. Create a new API key
5. Copy the key

## 2. Configure the API Key

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Open the `.env` file and replace `your_api_key_here` with your actual API key:
   ```
   GROQ_API_KEY=gsk_your_actual_api_key_here
   ```

## 3. How It Works

- When viewing a player's profile, tap the "KONUŞ" button
- This opens a chat screen where you can talk to the player
- The AI responds based on the player's:
  - Name and personality
  - Ego level (affects arrogance/humility)
  - Current mood/status
  - Context (like being benched, etc.)

## 4. Features

- **Dynamic Responses**: Each player has unique personality traits
- **Context-Aware**: AI considers recent events and player status
- **Realistic Chat**: Players respond like real footballers
- **Turkish Language**: All responses are in Turkish

## 5. Troubleshooting

If the chat doesn't work:
1. Check that your `.env` file has a valid API key
2. Ensure you have internet connection
3. The app will show "Sunucu hatası" if there are API issues

## 6. API Limits

Groq provides generous free tier limits:
- Rate limits apply
- Check your console for usage details

The AI integration brings your football manager game to life with realistic player interactions!
