# Lokal MedAssist System Architecture

## 1. Product split

Two separate Android applications:

- `Patient App`
- `Doctor App`

Both apps communicate with a shared backend platform over secure APIs.

## 2. Core backend services

### API Gateway

- single public entry point for mobile apps
- JWT validation
- rate limiting
- device and app version checks

### Auth Service

- patient signup/login
- doctor signup/login
- OTP login for patients
- doctor verification and onboarding review

### Profile Service

- patient metadata
- doctor metadata
- consultation history
- medical reports references

### Consultation Service

- create consultation request
- manage doctor queue
- consultation lifecycle
- consultation notes and outcomes

### Appointment Service

- clinic follow-up booking
- slot management
- rescheduling and cancellation

### Prescription Service

- doctor-generated e-prescriptions
- versioned prescription history
- patient access to prescriptions

### Payment and Wallet Service

- pre-consultation payment capture
- split settlement logic
- doctor wallet
- payout scheduling to bank account

### Notification Service

- FCM push notifications
- queue alerts
- appointment reminders
- payment confirmation
- prescription ready alerts

### Realtime Session Service

- doctor online/offline state
- queue updates
- consultation request acceptance
- call status transitions

### Video Consultation Service

- token generation for Agora or Twilio
- session start/end tracking
- call audit metadata

## 3. LLM orchestration layer

The mobile app must not call the LLM provider directly.

Use a backend `Medical Guidance Orchestrator` with these responsibilities:

- language normalization
- prompt templating
- symptom intake parsing
- emergency keyword detection
- unsafe query refusal
- structured triage output
- doctor handoff recommendation
- audit logging
- model routing

### Recommended output contract from LLM layer

The backend should transform model output into a strict structure:

- `risk_level`: low, medium, high, emergency
- `care_mode`: self_care, doctor_call, physical_visit, emergency
- `summary_for_patient`
- `summary_for_doctor`
- `follow_up_questions`
- `red_flag_detected`
- `disclaimer`

### Safety controls

- never position the LLM as final diagnosis authority
- block direct medication advice for high-risk cases
- force hospital escalation for emergency symptom patterns
- log prompt and response versions
- maintain doctor escalation pathways
- add regional language moderation and abuse handling

## 4. Data model overview

### Patient

- patient_id
- name
- age
- sex
- bmi
- city
- preferred_language
- medical_history
- allergies
- report_references
- previous_consultations

### Doctor

- doctor_id
- name
- specialty
- languages
- experience_years
- consultation_fee
- rating
- availability_status
- wallet_balance
- payout_account_reference

### Consultation

- consultation_id
- patient_id
- doctor_id
- source: ai, doctor, follow_up
- status
- concern
- structured_triage_summary
- payment_status
- prescription_id
- appointment_id

### Feedback

- feedback_id
- consultation_id
- patient_id
- doctor_id
- rating
- note

## 5. Suggested production stack

### Mobile

- Flutter
- Riverpod or Bloc for state management
- Dio for API layer
- GoRouter for navigation

### Backend

- NestJS
- PostgreSQL
- Redis
- WebSocket gateway

### Infra

- Docker
- Kubernetes or ECS
- object storage for reports and prescriptions
- monitoring with Grafana and Prometheus

## 6. Deployment flow

### Patient app

- distributed via Play Store or enterprise APK
- connects to production API gateway

### Doctor app

- distributed separately
- role-restricted onboarding and verification

### Backend

- deploy API services independently
- isolate LLM orchestration service from user-facing API where possible
- keep payment and payout logic in separate secured service boundary

## 7. Phase plan

### Phase 1

- patient login
- doctor login
- AI triage
- doctor list
- queue management
- payment before consultation
- prescription generation

### Phase 2

- real video SDK
- report uploads
- multilingual voice input
- doctor payout automation
- admin operations console

### Phase 3

- chronic care plans
- reminders and adherence tracking
- regional diagnostic partner integrations
- insurance and claims workflow
