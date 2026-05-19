from ultralytics import YOLO
import cv2

det_model = YOLO("yolov8n.pt")   # detection
cls_model = YOLO("best5.pt")     # senin model

def detect_and_count(image_path):

    img = cv2.imread(image_path)
    h, w = img.shape[:2]

    results = det_model(img)[0]

    counts = {}

    for box in results.boxes:

        conf = float(box.conf[0])

        # düşük confidence çöpe
        if conf < 0.5:
            continue

        x1, y1, x2, y2 = map(int, box.xyxy[0])

        # 🔥 KRİTİK: çok küçük bbox alma
        area = (x2 - x1) * (y2 - y1)
        if area < 0.1 * (h * w):   # %10'dan küçükse ignore
            continue

        # crop
        crop = img[y1:y2, x1:x2]

        if crop.size == 0:
            continue

        # classification
        cls_result = cls_model(crop)

        probs = cls_result[0].probs
        conf_cls = probs.top1conf.item()
        food = cls_result[0].names[probs.top1]

        # düşük güven → çöpe
        if conf_cls < 0.6:
            continue

        counts[food] = counts.get(food, 0) + 1

    return counts

detect_and_count("test.jpg")