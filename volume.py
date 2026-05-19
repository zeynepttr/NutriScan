from ultralytics import YOLO
import torch
import cv2
import numpy as np

# -----------------------
# YOLO MODEL
# -----------------------
yolo = YOLO("yolov8n-seg.pt")

# -----------------------
# MiDaS MODEL
# -----------------------
midas = torch.hub.load("intel-isl/MiDaS", "MiDaS_small")
midas.eval()

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
midas.to(device)

transform = torch.hub.load("intel-isl/MiDaS", "transforms").small_transform


# -----------------------
# MAIN FUNCTION
# -----------------------
def predict_food(image_path):

    img = cv2.imread(image_path)
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # YOLO
    results = yolo(img_rgb)
    r = results[0]

    if len(r.boxes) == 0:
        return "No food detected"

    box = r.boxes[0].xyxy[0]
    x1, y1, x2, y2 = map(int, box)

    # MASK
    mask = np.zeros(img_rgb.shape[:2])
    mask[y1:y2, x1:x2] = 1

    # MiDaS
    input_batch = transform(img_rgb).to(device)

    with torch.no_grad():
        depth = midas(input_batch)
        depth = torch.nn.functional.interpolate(
            depth.unsqueeze(1),
            size=img_rgb.shape[:2],
            mode="bicubic",
            align_corners=False
        ).squeeze()

    depth_map = depth.cpu().numpy()

    # VOLUME
    volume = np.sum(depth_map * mask)

    return {
        "bbox": (x1, y1, x2, y2),
        "volume": float(volume)
    }


# -----------------------
# TEST RUN
# -----------------------
if __name__ == "__main__":
    result = predict_food("image.jpg")
    print(result)
