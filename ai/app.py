from flask import Flask, request, jsonify
from ultralytics import YOLO
import torch
from torchvision import transforms
from PIL import Image
import json, io

app = Flask(__name__)

# ── MODELLER ─────────────────────────────
print("Modeller yükleniyor...")

yolo_model = YOLO("best5.pt")

nutrition_model = torch.load(
    "nutriscan_full.pt",
    map_location="cpu",
    weights_only=False
)
nutrition_model.eval()

with open("nutriscan_stats.json") as f:
    S = json.load(f)

print("✅ AI API hazır")

# ── TRANSFORM ────────────────────────────
tf = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225]
    ),
])

# ── HEALTH CHECK ─────────────────────────
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

# ── ANA AI ENDPOINT ───────────────────────
@app.route("/analyze", methods=["POST"])
def analyze():

    if "image" not in request.files:
        return jsonify({"error": "image missing"}), 400

    file = request.files["image"]
    img = Image.open(io.BytesIO(file.read())).convert("RGB")

    # ── 1. YOLO PREDICTION ────────────────
    results = yolo_model(img, verbose=False)

    # detection ise box'tan al
    if results[0].probs is not None:
        top_class = results[0].probs.top1
        food_name = yolo_model.names[top_class]
        confidence = float(results[0].probs.top1conf)
    else:
        # detection modeli fallback
        boxes = results[0].boxes
        if len(boxes) == 0:
            return jsonify({"error": "food not detected"}), 200

        cls_id = int(boxes.cls[0])
        food_name = yolo_model.names[cls_id]
        confidence = float(boxes.conf[0])

    # ── 2. NUTRITION MODEL ────────────────
    tensor = tf(img).unsqueeze(0)

    with torch.no_grad():
        out = nutrition_model(tensor)

    out = out[0].cpu().numpy()
    cal  = float(max(0, out[0] * S["cal_std"]  + S["cal_mean"]))
    fat  = float(max(0, out[1] * S["fat_std"]  + S["fat_mean"]))
    carb = float(max(0, out[2] * S["carb_std"] + S["carb_mean"]))
    prot = float(max(0, out[3] * S["prot_std"] + S["prot_mean"]))

    return jsonify({
        "food": food_name,
        "confidence": round(confidence, 3),
        "nutrition": {
            "calories": round(cal, 1),
            "fat_g": round(fat, 1),
            "carb_g": round(carb, 1),
            "protein_g": round(prot, 1)
        }
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)