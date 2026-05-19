# calori2.py
import torch, json
from torchvision import transforms
from PIL import Image

MODEL_PATH = "nutriscan_full2.pt"
STATS_PATH = "nutriscan_stats2.json"
IMAGE      = "test.jpg"

with open(STATS_PATH) as f:
    S = json.load(f)

device = torch.device("cpu")

# state_dict değil, direkt modeli yükle
model = torch.load(MODEL_PATH, map_location=device, weights_only=False)
model.eval()
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