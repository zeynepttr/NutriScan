import torch
import torchvision
from PIL import Image
from torchvision import transforms
import os

# PyTorch 2.6+ güvenlik duvarını aşmak için EfficientNet'i güvenli listeye ekliyoruz
try:
    torch.serialization.add_safe_globals([torchvision.models.efficientnet.EfficientNet])
except AttributeError:
    pass # Eski bir PyTorch sürümü kullanılıyorsa bu satırı es geç

def predict_calories(image_path, model_path):
    # 1. Cihaz tespiti (Ekran kartı varsa GPU, yoksa CPU)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"🖥️ Hesaplama Cihazı: {device}")
    
    # 2. Dosya Kontrolleri
    if not os.path.exists(model_path):
        print(f"❌ Hata: Model dosyası bulunamadı! Lütfen '{model_path}' dosyasını proje klasörüne yükleyin.")
        return
        
    if not os.path.exists(image_path):
        print(f"❌ Hata: Test görseli bulunamadı! Lütfen klasöre bir yemek fotoğrafı koyup adını '{image_path}' yapın.")
        return

    # 3. Model Yükleme
    print("⏳ Model yükleniyor...")
    try:
        model = torch.load(model_path, map_location=device, weights_only=False)
        model.to(device)
        model.eval()
    except Exception as e:
        print(f"❌ Model yüklenirken bir hata oluştu: {e}")
        return
    
    # 4. Görsel Hazırlama (Preprocessing)
    img = Image.open(image_path).convert('RGB')
    
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    img_tensor = transform(img).unsqueeze(0).to(device)
    
    # 5. Tahminleme (Inference)
    print("🔮 Kalori hesaplanıyor...")
    with torch.no_grad():
        output = model(img_tensor)
        predicted_calories = output.item()
        
    print("\n====================================")
    print(f"🍽️ NutriScan Tahmin Sonucu: {predicted_calories:.2f} kcal")
    print("====================================\n")

if __name__ == "__main__":
    # Dosya isimleri (Aynı klasörde olduklarından emin ol)
    model_dosyasi = "nutriscan_best.pt"
    test_gorseli = "kuru.jpg" 
    
    predict_calories(image_path=test_gorseli, model_path=model_dosyasi)