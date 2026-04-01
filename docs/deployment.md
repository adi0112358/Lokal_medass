# Deployment Guide

This project can be shared publicly in two parts:

- a hosted backend
- separate Android APKs for patient and doctor

## 1. Backend Hosting

The easiest no-cost MVP hosting path is Render.

This repo includes:

- [render.yaml](/Users/aditya/Desktop/Lokal_medass/render.yaml)

It is configured to deploy:

- `services/patient_backend`

### Render steps

1. Push this repository to GitHub.
2. Log in to Render.
3. Create a new Blueprint or Web Service from the repository.
4. Render will detect [render.yaml](/Users/aditya/Desktop/Lokal_medass/render.yaml).
5. Set these environment variables in Render:

```text
OPENROUTER_API_KEY=your_openrouter_key
JWT_SECRET=use_a_real_secret_here
OPENROUTER_MODEL=openrouter/free
```

6. Deploy.

After deployment, verify:

- `https://your-render-service.onrender.com/health`

### Important note

The current backend uses JSON file storage. It is okay for demo hosting, but free hosts usually have ephemeral storage, so data can reset after redeploys/restarts. For long-term public use, move persistence to PostgreSQL or Supabase.

## 2. Rebuild APKs With Public Backend URL

Once the backend is deployed, rebuild both apps with the public backend URL.

Example backend:

```text
https://lokal-medassist-backend.onrender.com
```

### Patient APK

```bash
cd /Users/aditya/Desktop/Lokal_medass/apps/patient_app
flutter build apk --release --dart-define=PATIENT_API_BASE_URL=https://lokal-medassist-backend.onrender.com
```

### Doctor APK

```bash
cd /Users/aditya/Desktop/Lokal_medass/apps/doctor_app
flutter build apk --release --dart-define=PATIENT_API_BASE_URL=https://lokal-medassist-backend.onrender.com
```

## 3. Share The APKs

After the build, the APKs will be at:

### Patient

- [app-release.apk](/Users/aditya/Desktop/Lokal_medass/apps/patient_app/build/app/outputs/flutter-apk/app-release.apk)

### Doctor

- [app-release.apk](/Users/aditya/Desktop/Lokal_medass/apps/doctor_app/build/app/outputs/flutter-apk/app-release.apk)

You can rename them before sharing, for example:

- `lokal-medassist-patient.apk`
- `lokal-medassist-doctor.apk`

## 4. Public Distribution

Fastest options:

- GitHub Releases
- direct Google Drive links

Production route later:

- Google Play Store
- signed AAB/APK builds
- real database
- real video provider
- real payments
