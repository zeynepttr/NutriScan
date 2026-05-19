# calori2.py
import torch, json
from torchvision import transforms
from PIL import Image
import timm

MODEL_PATH = "nutriscan_best.pt"
STATS_PATH = "nutriscan_stats.json"
IMAGE      = "makarna2.jpg"  # ← fotoğraf adını buraya yaz

# STATS yükle
with open(STATS_PATH) as f:
    S = json.load(f)

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Colab'daki ile AYNI mimari
model = timm.create_model('tf_efficientnetv2_s', pretrained=False, num_classes=4)
model.load_state_dict(torch.load(MODEL_PATH, map_location=device))
model.eval().to(device)
print("✅ Model yüklendi")

tf = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485,0.456,0.406],[0.229,0.224,0.225]),
])

img    = Image.open(IMAGE).convert("RGB")
tensor = tf(img).unsqueeze(0).to(device)

with torch.no_grad():
    out = model(tensor)[0].cpu().numpy()

cal  = out[0] * S['cal_std']  + S['cal_mean']
fat  = out[1] * S['fat_std']  + S['fat_mean']
carb = out[2] * S['carb_std'] + S['carb_mean']
prot = out[3] * S['prot_std'] + S['prot_mean']

print(f"\n📊 {IMAGE} için tahmin:")
print(f"  🔥 Kalori  : {cal:.0f} kcal")
print(f"  🥑 Yağ     : {fat:.1f} g")
print(f"  🍞 Karb    : {carb:.1f} g")
print(f"  💪 Protein : {prot:.1f} g")