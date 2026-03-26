# Lokal MedAssist Native

Native Android-first proposal workspace for Lokal's medical assistance platform.

## Workspace layout

- `apps/patient_app`: Flutter patient application
- `apps/doctor_app`: Flutter doctor application
- `packages/lokal_health_shared`: shared models, seeded data, and app-safe domain helpers
- `services/patient_backend`: patient-facing backend with OpenRouter-powered AI chat
- `docs/system-architecture.md`: production architecture for auth, LLM orchestration, video, payments, and queueing

## Product direction

This workspace now reflects the correct target shape:

- separate patient and doctor apps
- local-language patient experience
- LLM-based medical guidance through backend orchestration
- doctor handoff, video consultation, prescription, feedback, and wallet flows

## Current state

This is a native app scaffold with working Flutter UI code structure and demo data flows.
It is not yet wired to:

- production authentication
- production database
- real video calling SDK
- real payment gateway
- production LLM account
- real notifications

## Recommended stack

- Mobile apps: Flutter
- Backend: Node.js with NestJS or Express
- Database: PostgreSQL
- Cache / queue: Redis
- Notifications: Firebase Cloud Messaging
- Video: Agora or Twilio
- Payments: Razorpay
- LLM orchestration: OpenAI API via backend only

## How to continue

1. Install Flutter on your machine.
2. From each app directory, run:

```bash
flutter pub get
flutter run
```

For the patient backend:

```bash
cd /Users/aditya/Desktop/Lokal_medass/services/patient_backend
npm install
npm run dev
```

Detailed patient backend APIs:

- [/Users/aditya/Desktop/Lokal_medass/docs/patient-backend.md](/Users/aditya/Desktop/Lokal_medass/docs/patient-backend.md)

3. If platform folders are missing in your environment, run:

```bash
flutter create .
```

inside `apps/patient_app` and `apps/doctor_app`, then reapply the `lib/` and `pubspec.yaml` contents from this workspace if needed.

## Important note

I could not run or build Flutter here because this machine currently does not have `flutter` or `dart` installed.
