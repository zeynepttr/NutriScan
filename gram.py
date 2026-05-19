# 1. yemek tahmini
from ultralytics import YOLO
cls_model = YOLO("best5.pt")
cls_result = cls_model("kuru.jpg")
food = cls_result[0].names[cls_result[0].probs.top1]

# 2. segmentation
seg_model = YOLO("yolov8n-seg.pt")
seg_result = seg_model("test.jpg")

mask = seg_result[0].masks.data[0].cpu().numpy()

# 3. alan
area = mask.sum()

# 4. gram tahmini
grams = area * 0.05

# 5. kalori
calories = {"pizza":266, "kuru":295, "menemen":85}
cal = calories.get(food, 200) * grams / 100

print(food, grams, cal)
