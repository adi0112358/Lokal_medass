# Patient Backend And AI Integration

## What exists now

The patient backend is now a persistent file-backed API with:

- patient auth
- doctor auth
- patient profile lookup
- AI chat with saved chat history
- doctor listing
- doctor booking
- appointment APIs
- prescription APIs
- feedback APIs

Data is stored locally in:

- `services/patient_backend/data/store.json`

The store file is created automatically on first run with seeded doctors, one seeded patient, prior consultations, appointments, and prescriptions.

Default demo patient:

- email: `suman.verma@lokal.demo`
- password: `Pass@123`

Default demo doctor:

- email: `meera.sharma@lokal.demo`
- password: `Doc@123`

If you already started the backend before this seed was updated, delete the existing store and restart to reseed:

```bash
rm /Users/aditya/Desktop/Lokal_medass/services/patient_backend/data/store.json
```

## Backend location

- `services/patient_backend`

## Local setup

```bash
cd /Users/aditya/Desktop/Lokal_medass/services/patient_backend
npm install
```

Create `.env` from `.env.example` and set:

```bash
PORT=8080
OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_MODEL=openrouter/free
JWT_SECRET=replace_this_for_non_demo_usage
```

Start the backend:

```bash
npm run dev
```

Health check:

- [http://localhost:8080/health](http://localhost:8080/health)

Android emulator base URL:

- `http://10.0.2.2:8080`

## Auth APIs

### `POST /api/patient/auth/register`

Request body:

```json
{
  "name": "Asha Singh",
  "email": "asha@example.com",
  "password": "Pass@123",
  "age": 28,
  "sex": "Female",
  "bmi": 22.4,
  "city": "Lucknow",
  "preferredLanguage": "Hindi"
}
```

Response:

```json
{
  "token": "...jwt...",
  "patient": {
    "patientId": "PAT-12345",
    "name": "Asha Singh"
  }
}
```

### `POST /api/patient/auth/login`

### `GET /api/patient/me`

Requires:

```text
Authorization: Bearer <token>
```

## Doctor Auth APIs

### `POST /api/doctor/auth/login`

### `GET /api/doctor/me`

Requires:

```text
Authorization: Bearer <doctor_token>
```

## Chat APIs

### `POST /api/patient/chat`

Works with auth token, or with direct patient context for the current Flutter demo compatibility.

Request body:

```json
{
  "message": "I have fever and cough since yesterday",
  "conversationId": "CHAT-1001"
}
```

Response:

```json
{
  "conversationId": "CHAT-1001",
  "assistantMessage": "....",
  "riskLevel": "medium",
  "careMode": "doctor_call",
  "redFlagDetected": false,
  "doctorSummary": "....",
  "followUpQuestions": ["...."]
}
```

### `GET /api/patient/chats`

### `GET /api/patient/chats/:conversationId`

## Doctor APIs

### `GET /api/doctors`

### `GET /api/doctors/:doctorId`

## Booking APIs

### `GET /api/patient/bookings`

### `POST /api/patient/bookings`

Request body:

```json
{
  "doctorId": "DOC-1101",
  "concern": "Recurring acidity and bloating after meals",
  "recommendedMode": "VIDEO_CALL"
}
```

## Appointment APIs

### `GET /api/patient/appointments`

### `POST /api/patient/appointments`

Request body:

```json
{
  "consultationId": "CONS-7601",
  "doctorId": "DOC-1101",
  "date": "2026-03-31",
  "slot": "12:15 PM",
  "clinicName": "Lokal Health Clinic - Kanpur Central"
}
```

## Prescription APIs

### `GET /api/patient/prescriptions`

### `GET /api/patient/prescriptions/:prescriptionId`

## Feedback APIs

### `GET /api/patient/feedback`

### `POST /api/patient/feedback`

Request body:

```json
{
  "consultationId": "CONS-7601",
  "doctorId": "DOC-1101",
  "rating": 5,
  "note": "Doctor explained the diet plan very clearly in Hindi."
}
```

### `GET /api/doctor/feedback`

## Doctor Operations APIs

### `GET /api/doctor/queue`

### `POST /api/doctor/availability`

Request body:

```json
{
  "online": true
}
```

### `POST /api/doctor/consultations/:consultationId/start`

### `POST /api/doctor/consultations/:consultationId/request-visit`

### `POST /api/doctor/consultations/:consultationId/complete`

Request body:

```json
{
  "prescription": "Take medicines as prescribed and review after 3 days."
}
```

### `GET /api/doctor/wallet`

## Notes

- passwords are hashed for this local demo backend
- persistence is file-based, not production-grade database storage
- the current Flutter patient app is only wired to the chat endpoint so far
- next step is to wire auth, doctor list, and bookings into the patient app UI
