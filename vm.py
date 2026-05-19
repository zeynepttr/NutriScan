from ultralytics import YOLO
import torch
import cv2
import numpy as np

# -----------------------
# 1. MODELS
# -----------------------

cls_model = YOLO("best5.pt")
det_model = YOLO("yolov8n-seg.pt")

midas = torch.hub.load("intel-isl/MiDaS", "MiDaS_small")
midas.eval()

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
midas.to(device)

transform = torch.hub.load("intel-isl/MiDaS", "transforms").small_transform


# -----------------------
# 2. BASE GRAM VALUES (anchor-based)
# -----------------------
base_grams = {
    "pizza": 250,
    "kebap": 220,
    "pilav": 180,
    "yumurta": 70
    
}


# -----------------------
# 3. PIPELINE
# -----------------------

def predict(image_path):

    img = cv2.imread(image_path)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # -----------------------
    # 1. FOOD CLASSIFICATION
    # -----------------------
    cls_results = cls_model(image_path)

    probs = cls_results[0].probs
    food_name = cls_results[0].names[probs.top1]

    # -----------------------
    # 2. DETECTION
    # -----------------------
    det_results = det_model(img_rgb)
    r = det_results[0]

    if len(r.boxes) == 0:
        return {"error": "No object detected"}

    x1, y1, x2, y2 = map(int, r.boxes[0].xyxy[0])

    # -----------------------
    # 3. MASK
    # -----------------------
    mask = np.zeros(img_rgb.shape[:2], dtype=np.float32)
    mask[y1:y2, x1:x2] = 1.0

    mask_sum = np.sum(mask)
    if mask_sum == 0:
        return {"error": "Invalid mask"}

    # normalize mask
    mask = mask / mask_sum

    # -----------------------
    # 4. MiDaS DEPTH
    # -----------------------
    input_batch = transform(img_rgb).to(device)

    with torch.no_grad():
        depth = midas(input_batch)
        depth = torch.nn.functional.interpolate(
            depth.unsqueeze(1),
            size=img_rgb.shape[:2],
            mode="bicubic",
            align_corners=False
        ).squeeze()

    depth_map = depth.cpu().numpy().astype(np.float32)

    # -----------------------
    # 5. NORMALIZATION (IMPORTANT)
    # -----------------------
    depth_map = depth_map - depth_map.min()
    depth_map = depth_map / (depth_map.max() + 1e-6)

    # -----------------------
    # 6. FEATURE (STABLE VERSION)
    # -----------------------

    depth_mean = np.sum(depth_map * mask)
    area_ratio = mask_sum / mask.size

    # combined feature (NO explosion)
    feature = depth_mean * (1 + area_ratio)

    # -----------------------
    # 7. GRAM (STABLE SCALING)
    # -----------------------
    base = base_grams.get(food_name, 200)

    grams = base * (0.5 + feature)

    # clamp (real-world limit)
    grams = np.clip(grams, 50, 1000)

    # -----------------------
    # 8. RETURN
    # -----------------------
    return {
        "food": food_name,
        "bbox": (x1, y1, x2, y2),
        "feature": float(feature),
        "grams": float(grams)
    }


# -----------------------
# 4. TEST
# -----------------------

if __name__ == "__main__":
    result = predict("yumurta.jpg")

    print("\n====================")
    print("FOOD:", result["food"])
    print("BBOX:", result["bbox"])
    print("FEATURE:", result["feature"])
    print("GRAM:", result["grams"])
    print("====================\n")
