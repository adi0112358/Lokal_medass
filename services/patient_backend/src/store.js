import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { initialStore } from "./seed.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const dataDirectory = path.join(__dirname, "..", "data");
const storePath = path.join(dataDirectory, "store.json");

function ensureStoreFile() {
  if (!fs.existsSync(dataDirectory)) {
    fs.mkdirSync(dataDirectory, { recursive: true });
  }

  if (!fs.existsSync(storePath)) {
    fs.writeFileSync(storePath, JSON.stringify(initialStore, null, 2));
  }
}

export function readStore() {
  ensureStoreFile();
  return JSON.parse(fs.readFileSync(storePath, "utf8"));
}

export function writeStore(nextStore) {
  ensureStoreFile();
  fs.writeFileSync(storePath, JSON.stringify(nextStore, null, 2));
}

export function updateStore(updater) {
  const current = readStore();
  const updated = updater(current);
  writeStore(updated);
  return updated;
}

export function getStorePath() {
  ensureStoreFile();
  return storePath;
}
