# NexSpend 💸

AI-Powered Financial Copilot

NexSpend helps users track expenses, understand spending habits, and make smarter financial decisions through AI-powered insights, voice expense tracking, and natural language expense entry.

## AI Used

GPT-5.6 (Codex) was used as a development assistant throughout the project. It helped accelerate Flutter development, UI implementation, Supabase integration, Riverpod state management, voice expense tracking, natural language expense parsing, AI Copilot functionality, analytics dashboards, and overall debugging. GPT-5.6 was also used to iterate on user experience, improve application architecture, resolve implementation issues, and rapidly prototype new features. All final decisions, integration, testing, and project direction were performed by the developer.

## Features

### Smart Expense Tracking
- Manual expense entry
- Voice expense entry
- Natural language expense entry
- Automatic categorization

Examples:

- Spent ₹450 at Starbucks
- Uber ride ₹250
- Bought groceries for ₹1800
- Spent ₹1600 at H&M

### AI Financial Copilot

Ask questions like:

- Where did I spend the most money this month?
- How much did I spend on food?
- Can I afford AirPods next month?
- Compare this month with last month.

### Insights & Analytics

- Monthly spending trends
- Category breakdowns
- Top merchants
- Spending health indicators
- Budget tracking

### Privacy & Security

- Privacy Mode
- Local settings persistence
- Theme customization
- Currency preferences

## Tech Stack

### Frontend
- Flutter
- Riverpod
- Material 3

### Backend
- Supabase
- PostgreSQL
- FastAPI

### AI
- Groq API

## Screenshots

(Add screenshots here)

## Demo Video

(Add your unlisted YouTube link here)

## Installation

### Frontend

```bash
cd frontend
flutter pub get
flutter run --dart-define-from-file=../.env
```

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Environment Variables

Create a root `.env` file containing:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
GROQ_API_KEY=
```

## Project Status

Release v1 ✅

Core features complete:
- Authentication
- Expense Tracking
- Voice Entry
- Natural Language Parsing
- AI Copilot
- Insights Dashboard
- Privacy Mode
- Android APK
