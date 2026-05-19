import kagglehub

path = kagglehub.dataset_download("rkuo2000/uecfood256")

print("Dataset path:", path)


import os
import shutil

src = path + "/UECFOOD256"
dst = "/content/food_dataset"
# category.txt dosyasının yolu (Genellikle UECFOOD256 ana dizinindedir)
cat_file = path + "/UECFOOD256/category.txt"

# Kategori isimlerini oku (Eğer dosya varsa)
id_to_name = {}
if os.path.exists(cat_file):
    with open(cat_file, 'r') as f:
        lines = f.readlines()[1:] # İlk satır başlık olabilir, atla
        for line in lines:
            parts = line.strip().split('\t')
            if len(parts) >= 2:
                id_to_name[parts[0]] = parts[1].replace(" ", "_")

os.makedirs(dst, exist_ok=True)

for split in ["train", "val"]:
    os.makedirs(f"{dst}/{split}", exist_ok=True)

classes = sorted(os.listdir(src))

for cls in classes:
    cls_path = os.path.join(src, cls)
    if not os.path.isdir(cls_path) or cls == "labels":
        continue

    # İSİM BURADA BELİRLENİYOR:
    # Eğer listede varsa ismini koy, yoksa klasörün kendi adını (örn: '89') koy
    folder_name = id_to_name.get(cls, cls) 

    images = [f for f in os.listdir(cls_path) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    split_point = int(len(images) * 0.8)

    for split in ["train", "val"]:
        new_cls_path = os.path.join(dst, split, folder_name)
        os.makedirs(new_cls_path, exist_ok=True)
        
        selected = images[:split_point] if split == "train" else images[split_point:]
        
        for img in selected:
            shutil.copy(os.path.join(cls_path, img), os.path.join(new_cls_path, img))

print("Veri seti isimlerle hazırlandı!")



from ultralytics import YOLO

# 1. Medium modeli çekiyoruz (Sıfırdan veya pretrained olarak)
model = YOLO("yolov8m-cls.pt") 

# 2. Eğitimi başlat
model.train(
    data="/content/food_dataset",
    epochs=100,
    imgsz=224,
    batch=32,
    patience=20,
    save=True,
    device=0,
    optimizer='AdamW',
    lr0=0.001
)