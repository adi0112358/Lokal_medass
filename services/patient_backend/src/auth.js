import crypto from "crypto";
import jwt from "jsonwebtoken";

const jwtSecret = process.env.JWT_SECRET || "lokal-medassist-dev-secret";

export function hashPassword(password, salt = crypto.randomBytes(16).toString("hex")) {
  const derived = crypto.scryptSync(password, salt, 32).toString("hex");
  return `${salt}:${derived}`;
}

export function verifyPassword(password, hashedValue) {
  const [salt, expected] = hashedValue.split(":");
  if (!salt || !expected) {
    return false;
  }

  const derived = crypto.scryptSync(password, salt, 32).toString("hex");
  return crypto.timingSafeEqual(
    Buffer.from(derived, "hex"),
    Buffer.from(expected, "hex")
  );
}

export function issuePatientToken(patient) {
  return jwt.sign(
    {
      sub: patient.patientId,
      role: "patient",
      email: patient.email
    },
    jwtSecret,
    {
      expiresIn: "7d"
    }
  );
}

export function issueDoctorToken(doctor) {
  return jwt.sign(
    {
      sub: doctor.doctorId,
      role: "doctor",
      email: doctor.email
    },
    jwtSecret,
    {
      expiresIn: "7d"
    }
  );
}

export function authenticatePatient(request, response, next) {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    return response.status(401).json({ error: "missing_auth_token" });
  }

  const token = authorization.slice("Bearer ".length);

  try {
    const payload = jwt.verify(token, jwtSecret);
    request.auth = payload;
    return next();
  } catch {
    return response.status(401).json({ error: "invalid_auth_token" });
  }
}

export function authenticateDoctor(request, response, next) {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    return response.status(401).json({ error: "missing_auth_token" });
  }

  const token = authorization.slice("Bearer ".length);

  try {
    const payload = jwt.verify(token, jwtSecret);
    if (payload.role !== "doctor") {
      return response.status(403).json({ error: "doctor_role_required" });
    }
    request.auth = payload;
    return next();
  } catch {
    return response.status(401).json({ error: "invalid_auth_token" });
  }
}

export function attachPatientAuth(request, _response, next) {
  const authorization = request.headers.authorization;
  if (!authorization?.startsWith("Bearer ")) {
    return next();
  }

  const token = authorization.slice("Bearer ".length);

  try {
    request.auth = jwt.verify(token, jwtSecret);
  } catch {
    request.auth = undefined;
  }

  return next();
}

export function sanitizePatient(patient) {
  const { passwordHash, ...safePatient } = patient;
  return safePatient;
}

export function sanitizeDoctor(doctor) {
  const { passwordHash, ...safeDoctor } = doctor;
  return safeDoctor;
}
