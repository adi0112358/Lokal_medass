import { NextRequest, NextResponse } from "next/server";

function getReply(prompt: string, language: string) {
  const normalized = prompt.toLowerCase();

  if (normalized.includes("chest") || normalized.includes("breath") || normalized.includes("bleeding")) {
    return language === "Hindi"
      ? "Yeh emergency symptom ho sakta hai. Kripya turant nearest hospital ya emergency care se sampark karein. Video consult ka wait mat kijiye."
      : "This may indicate an emergency. Please contact the nearest hospital or emergency care immediately instead of waiting for a video consultation.";
  }

  if (normalized.includes("fever") || normalized.includes("cold") || normalized.includes("cough")) {
    return language === "Hindi"
      ? "Lagta hai yeh routine consultation case ho sakta hai. Pani zyada lijiye, temperature note kijiye, aur agar 2 din se zyada rahe to doctor video call book kijiye."
      : "This looks suitable for a routine consultation. Track temperature, stay hydrated, and book a doctor call if symptoms continue beyond two days.";
  }

  if (normalized.includes("skin") || normalized.includes("rash") || normalized.includes("itch")) {
    return language === "Hindi"
      ? "Skin issue ke liye affected area clean aur dry rakhein. Agar rash fail raha hai ya itching severe hai to dermatologist se video consultation book karna better rahega."
      : "Keep the affected skin clean and dry. If the rash is spreading or itching is severe, a dermatologist video consultation is the better next step.";
  }

  return language === "Hindi"
    ? "Main pehle level ka medical guide hoon. Main symptoms samajhkar batata hoon ki ghar par care kaafi hai, doctor video call chahiye, ya physical visit zaroori ho sakti hai."
    : "I am a first-level medical guide. I can help assess whether home care is enough, a doctor video call is needed, or an in-person visit is more appropriate.";
}

export async function POST(request: NextRequest) {
  const body = (await request.json()) as { prompt?: string; language?: string };
  const prompt = body.prompt?.trim();

  if (!prompt) {
    return NextResponse.json({ reply: "Please describe the symptoms first." }, { status: 400 });
  }

  return NextResponse.json({
    reply: getReply(prompt, body.language ?? "English")
  });
}
