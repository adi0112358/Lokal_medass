from pathlib import Path


ROOT = Path("/Users/aditya/Desktop/Lokal_medass/docs")
SVG_PATH = ROOT / "system-design-n8n-style.svg"
PDF_PATH = ROOT / "system-design-n8n-style.pdf"


WIDTH = 1600
HEIGHT = 980


COLORS = {
    "bg": "#F7F8FC",
    "title": "#1F2440",
    "text": "#4D5775",
    "edge": "#B9C0D4",
    "line": "#8A94B6",
    "clients": "#FFF4E8",
    "edge_box": "#EEF2FF",
    "backend": "#EAF8F3",
    "ai": "#FFF1F6",
    "data": "#F3F4F8",
    "external": "#EEF7FF",
    "accent": "#FF6D5A",
}


def rect(x, y, w, h, fill, stroke="#D9DEEC", rx=20):
    return (
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" '
        f'fill="{fill}" stroke="{stroke}" stroke-width="1.5"/>'
    )


def text(x, y, value, size=16, weight=600, fill=None, anchor="middle"):
    fill = fill or COLORS["title"]
    value = (
        value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )
    return (
        f'<text x="{x}" y="{y}" font-family="Inter, Arial, sans-serif" '
        f'font-size="{size}" font-weight="{weight}" fill="{fill}" '
        f'text-anchor="{anchor}">{value}</text>'
    )


def line(x1, y1, x2, y2, color=None, width=3, dash=None, marker_end=True):
    color = color or COLORS["line"]
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    marker = ' marker-end="url(#arrow)"' if marker_end else ""
    return (
        f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" '
        f'stroke-width="{width}" stroke-linecap="round"{dash_attr}{marker}/>'
    )


def card(x, y, w, h, title_value, fill):
    return "\n".join(
        [
            rect(x, y, w, h, fill),
            text(x + w / 2, y + h / 2 + 6, title_value),
        ]
    )


def generate_svg():
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">',
        "<defs>",
        '<marker id="arrow" markerWidth="10" markerHeight="10" refX="7" refY="3" orient="auto" markerUnits="strokeWidth">',
        f'<path d="M0,0 L0,6 L8,3 z" fill="{COLORS["line"]}"/>',
        "</marker>",
        "</defs>",
        rect(0, 0, WIDTH, HEIGHT, COLORS["bg"], stroke=COLORS["bg"], rx=0),
        text(800, 60, "Lokal MedAssist System Design", size=30, weight=700),
        text(
            800,
            92,
            "Clean product architecture with workflow orchestration (n8n-style)",
            size=15,
            weight=500,
            fill=COLORS["text"],
        ),
    ]

    groups = [
        (70, 140, 250, 170, "Clients", COLORS["clients"]),
        (380, 140, 220, 170, "Edge Layer", COLORS["edge_box"]),
        (660, 110, 330, 660, "Core Backend", COLORS["backend"]),
        (1050, 110, 250, 350, "AI Workflow", COLORS["ai"]),
        (1050, 500, 250, 270, "Data & Infra", COLORS["data"]),
        (1360, 210, 190, 430, "External Integrations", COLORS["external"]),
    ]
    for x, y, w, h, label, fill in groups:
        parts.append(rect(x, y, w, h, fill, stroke="#D6DCEC", rx=28))
        parts.append(text(x + 22, y + 34, label, size=20, weight=700, anchor="start"))

    # Clients
    parts += [
        card(100, 200, 190, 52, "Patient App", "#FFFFFF"),
        card(100, 268, 190, 52, "Doctor App", "#FFFFFF"),
        card(100, 336, 190, 52, "Admin Dashboard", "#FFFFFF"),
    ]

    # Edge
    parts += [
        card(415, 220, 150, 54, "WAF / Rate Limit", "#FFFFFF"),
        card(415, 305, 150, 54, "API Gateway", "#FFFFFF"),
    ]

    # Backend
    backend_cards = [
        ("Auth & Identity", 700, 170),
        ("Profile Service", 700, 245),
        ("Consultation & Queue", 700, 320),
        ("Appointment Service", 700, 395),
        ("Prescription Service", 700, 470),
        ("Feedback & Rating", 700, 545),
        ("Payment & Wallet", 700, 620),
        ("Video & Notification", 700, 695),
    ]
    for label, x, y in backend_cards:
        parts.append(card(x, y, 250, 52, label, "#FFFFFF"))

    # AI
    ai_cards = [
        ("AI Triage API", 1080, 170),
        ("Workflow Orchestrator", 1080, 245),
        ("Safety Rules Engine", 1080, 320),
        ("Prompt Builder", 1080, 395),
    ]
    for label, x, y in ai_cards:
        parts.append(card(x, y, 190, 52, label, "#FFFFFF"))

    # Data
    data_cards = [
        ("PostgreSQL", 1080, 560),
        ("Redis / Realtime", 1080, 635),
        ("Object Storage", 1080, 710),
    ]
    for label, x, y in data_cards:
        parts.append(card(x, y, 190, 52, label, "#FFFFFF"))

    # External
    external_cards = [
        ("n8n / Workflow Bus", 1385, 270),
        ("LLM Provider Layer", 1385, 345),
        ("Razorpay", 1385, 420),
        ("Agora / Twilio", 1385, 495),
        ("FCM Notifications", 1385, 570),
    ]
    for label, x, y in external_cards:
        parts.append(card(x, y, 140, 52, label, "#FFFFFF"))

    # Main connection lines
    parts += [
        line(290, 226, 415, 247),
        line(290, 294, 415, 247),
        line(290, 362, 415, 247),
        line(490, 274, 490, 305),
        line(565, 332, 700, 196),
        line(565, 332, 700, 271),
        line(565, 332, 700, 346),
        line(565, 332, 700, 421),
        line(565, 332, 700, 496),
        line(565, 332, 700, 571),
        line(565, 332, 700, 646),
        line(565, 332, 700, 721),
        line(950, 346, 1080, 196),
        line(950, 346, 1080, 271),
        line(1175, 222, 1175, 245),
        line(1175, 297, 1175, 320),
        line(1175, 372, 1175, 395),
        line(1270, 271, 1385, 296),
        line(1270, 421, 1385, 371),
        line(950, 421, 1080, 586),
        line(950, 571, 1080, 661),
        line(950, 496, 1080, 736),
        line(950, 646, 1385, 446),
        line(950, 721, 1385, 521),
        line(950, 721, 1385, 596),
    ]

    # Accent annotation
    parts += [
        rect(70, 845, 1480, 88, "#FFFFFF", stroke="#E0E5F2", rx=24),
        text(110, 880, "Key Flow:", size=16, weight=700, anchor="start", fill=COLORS["accent"]),
        text(
            210,
            880,
            "Patient/Doctor Apps -> API Gateway -> Core Backend -> AI Workflow / Data Layer -> External Services",
            size=16,
            weight=600,
            anchor="start",
            fill=COLORS["title"],
        ),
        text(
            110,
            910,
            "The workflow orchestrator acts like an n8n-style automation layer for AI triage, escalation, reminders, and care transitions.",
            size=14,
            weight=500,
            anchor="start",
            fill=COLORS["text"],
        ),
    ]

    parts.append("</svg>")
    SVG_PATH.write_text("\n".join(parts), encoding="utf-8")


def pdf_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def pdf_rect(ops, x, y, w, h, r, g, b, stroke=None):
    ops.append(f"{r:.3f} {g:.3f} {b:.3f} rg")
    if stroke:
        sr, sg, sb = stroke
        ops.append(f"{sr:.3f} {sg:.3f} {sb:.3f} RG")
        ops.append("1.2 w")
    ops.append(f"{x:.1f} {y:.1f} {w:.1f} {h:.1f} re B")


def pdf_text(ops, x, y, value, size=11, color=(0.12, 0.14, 0.25)):
    value = pdf_escape(value)
    r, g, b = color
    ops.append("BT")
    ops.append(f"/F1 {size} Tf")
    ops.append(f"{r:.3f} {g:.3f} {b:.3f} rg")
    ops.append(f"1 0 0 1 {x:.1f} {y:.1f} Tm")
    ops.append(f"({value}) Tj")
    ops.append("ET")


def pdf_line(ops, x1, y1, x2, y2, color=(0.54, 0.58, 0.71), width=1.8):
    r, g, b = color
    ops.append(f"{r:.3f} {g:.3f} {b:.3f} RG")
    ops.append(f"{width:.1f} w")
    ops.append(f"{x1:.1f} {y1:.1f} m {x2:.1f} {y2:.1f} l S")


def generate_pdf():
    page_w = 1200
    page_h = 760
    ops = []

    # background
    pdf_rect(ops, 0, 0, page_w, page_h, 0.969, 0.973, 0.988, stroke=(0.969, 0.973, 0.988))
    pdf_text(ops, 400, 718, "Lokal MedAssist System Design", size=22)
    pdf_text(ops, 315, 696, "n8n-style workflow architecture for AI triage, consultation, and care operations", size=11, color=(0.30, 0.34, 0.46))

    # group frames
    pdf_rect(ops, 40, 500, 190, 150, 1.0, 0.957, 0.910, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 56, 625, "Clients", size=14)
    pdf_rect(ops, 270, 500, 150, 150, 0.933, 0.949, 1.0, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 286, 625, "Edge Layer", size=14)
    pdf_rect(ops, 460, 260, 270, 390, 0.918, 0.973, 0.953, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 476, 625, "Core Backend", size=14)
    pdf_rect(ops, 770, 390, 190, 260, 1.0, 0.945, 0.965, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 786, 625, "AI Workflow", size=14)
    pdf_rect(ops, 770, 170, 190, 170, 0.953, 0.957, 0.973, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 786, 315, "Data & Infra", size=14)
    pdf_rect(ops, 1000, 300, 160, 270, 0.933, 0.969, 1.0, stroke=(0.84, 0.86, 0.93))
    pdf_text(ops, 1016, 545, "External", size=14)

    def small_card(x, y, w, h, label):
        pdf_rect(ops, x, y, w, h, 1, 1, 1, stroke=(0.85, 0.88, 0.94))
        pdf_text(ops, x + 14, y + h / 2 - 4, label, size=10)

    # cards
    for y, label in [(575, "Patient App"), (530, "Doctor App"), (485, "Admin Dashboard")]:
        small_card(58, y, 154, 30, label)

    for y, label in [(575, "WAF / Rate Limit"), (520, "API Gateway")]:
        small_card(286, y, 118, 32, label)

    backend = [
        (575, "Auth & Identity"),
        (530, "Profile Service"),
        (485, "Consultation & Queue"),
        (440, "Appointment Service"),
        (395, "Prescription Service"),
        (350, "Feedback & Rating"),
        (305, "Payment & Wallet"),
    ]
    for y, label in backend:
        small_card(478, y, 234, 32, label)
    small_card(478, 270, 234, 32, "Video & Notification")

    for y, label in [(575, "AI Triage API"), (530, "Workflow Orchestrator"), (485, "Safety Rules Engine"), (440, "Prompt Builder")]:
        small_card(788, y, 154, 32, label)

    for y, label in [(265, "PostgreSQL"), (220, "Redis / Realtime"), (175, "Object Storage")]:
        small_card(788, y, 154, 32, label)

    for y, label in [(495, "n8n / Workflow Bus"), (450, "LLM Provider Layer"), (405, "Razorpay"), (360, "Agora / Twilio"), (315, "FCM Notifications")]:
        small_card(1018, y, 124, 32, label)

    # lines
    for y in (590, 545, 500):
        pdf_line(ops, 212, y, 286, 591)
    pdf_line(ops, 345, 552, 345, 520)
    for y in (591, 546, 501, 456, 411, 366, 321, 286):
        pdf_line(ops, 404, 536, 478, y)
    for y in (591, 546):
        pdf_line(ops, 712, y, 788, y)
    pdf_line(ops, 865, 575, 865, 562)
    pdf_line(ops, 865, 530, 865, 517)
    pdf_line(ops, 865, 485, 865, 472)
    pdf_line(ops, 942, 546, 1018, 511)
    pdf_line(ops, 942, 456, 1018, 466)
    for y in (281, 236, 191):
        pdf_line(ops, 712, 456, 788, y)
    for y in (421, 376, 331):
        pdf_line(ops, 712, y, 1018, y)

    pdf_rect(ops, 40, 52, 1120, 76, 1, 1, 1, stroke=(0.88, 0.90, 0.95))
    pdf_text(ops, 58, 98, "Key Flow:", size=11, color=(1.0, 0.43, 0.35))
    pdf_text(ops, 125, 98, "Apps -> Gateway -> Core Backend -> AI Workflow / Data Layer -> External Services", size=11)
    pdf_text(ops, 58, 76, "The workflow orchestrator is the n8n-style automation layer for triage, escalation, reminders, and care transitions.", size=10, color=(0.30, 0.34, 0.46))

    content = "\n".join(ops).encode("latin-1", "replace")

    objects = []

    def add_object(data: bytes):
        objects.append(data)

    add_object(b"<< /Type /Catalog /Pages 2 0 R >>")
    add_object(b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>")
    add_object(f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {page_w} {page_h}] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>".encode("latin-1"))
    add_object(b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>")
    add_object(f"<< /Length {len(content)} >>\nstream\n".encode("latin-1") + content + b"\nendstream")

    pdf = bytearray(b"%PDF-1.4\n")
    offsets = [0]
    for i, obj in enumerate(objects, start=1):
        offsets.append(len(pdf))
        pdf.extend(f"{i} 0 obj\n".encode("latin-1"))
        pdf.extend(obj)
        pdf.extend(b"\nendobj\n")

    xref_pos = len(pdf)
    pdf.extend(f"xref\n0 {len(objects)+1}\n".encode("latin-1"))
    pdf.extend(b"0000000000 65535 f \n")
    for off in offsets[1:]:
        pdf.extend(f"{off:010d} 00000 n \n".encode("latin-1"))
    pdf.extend(
        f"trailer\n<< /Size {len(objects)+1} /Root 1 0 R >>\nstartxref\n{xref_pos}\n%%EOF\n".encode("latin-1")
    )

    PDF_PATH.write_bytes(pdf)


if __name__ == "__main__":
    generate_svg()
    generate_pdf()
