import os
import json
import torch
from torchvision import transforms
from PIL import Image
import numpy as np

# Dosya yollari
MODEL_PATH = "nutriscan_full.pt"
STATS_PATH = "nutriscan_stats.json"
IMAGE_DIR = "."

# Standart/Gercek Besin Degerleri (Ground Truth)
# Format: [Kalori (kcal), Yag (g), Karbonhidrat (g), Protein (g)]
ground_truth = {
    "yumurta.jpg": [100.0, 7.5, 0.6, 9.0],
    "egg2.jpg": [100.0, 7.5, 0.6, 9.0],
    "hamburger.jpg": [500.0, 25.0, 40.0, 22.0],
    "kuru.jpg": [350.0, 8.0, 50.0, 18.0],
    "kuru2.jpg": [350.0, 8.0, 50.0, 18.0],
    "lahmacun.jpg": [250.0, 9.0, 32.0, 10.0],
    "lahmacun2.jpg": [250.0, 9.0, 32.0, 10.0],
    "makarna2.jpg": [300.0, 5.0, 55.0, 10.0],
    "pilav.jpg": [250.0, 6.0, 45.0, 4.0],
    "pilav2.jpg": [250.0, 6.0, 45.0, 4.0],
    "pizza.jpg": [650.0, 22.0, 85.0, 26.0]
}

def main():
    print("==================================================")
    print("   NutriScan Besin Degeri Modeli Test Programi    ")
    print("==================================================")
    
    if not os.path.exists(MODEL_PATH):
        print(f"Hata: {MODEL_PATH} dosyasi bulunamadi!")
        return
        
    if not os.path.exists(STATS_PATH):
        print(f"Hata: {STATS_PATH} dosyasi bulunamadi!")
        return

    # Istatistik ve model yukleme
    with open(STATS_PATH) as f:
        S = json.load(f)

    device = torch.device("cpu")
    print("Model yukleniyor (EfficientNetV2)...")
    model = torch.load(MODEL_PATH, map_location=device, weights_only=False)
    model.eval()
    print("Model basariyla yuklendi.")

    tf = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    results = []
    
    print("\nTest gorselleri taraniyor ve tahminler yapiliyor...")
    for img_name, true_vals in ground_truth.items():
        img_path = os.path.join(IMAGE_DIR, img_name)
        if not os.path.exists(img_path):
            continue
            
        try:
            img = Image.open(img_path).convert("RGB")
            tensor = tf(img).unsqueeze(0).to(device)
            
            with torch.no_grad():
                out = model(tensor)[0].cpu().numpy()
                
            cal  = max(0.0, float(out[0] * S['cal_std']  + S['cal_mean']))
            fat  = max(0.0, float(out[1] * S['fat_std']  + S['fat_mean']))
            carb = max(0.0, float(out[2] * S['carb_std'] + S['carb_mean']))
            prot = max(0.0, float(out[3] * S['prot_std'] + S['prot_mean']))
            
            pred_vals = [cal, fat, carb, prot]
            results.append({
                "image": img_name,
                "true": true_vals,
                "pred": pred_vals
            })
            print(f"  - {img_name}: Tahmin yapildi.")
        except Exception as e:
            print(f"  - Hata ({img_name}): {e}")

    if not results:
        print("\nHata: Klasorde test edilecek uygun gorsel (makarna2.jpg, pizza.jpg vb.) bulunamadi.")
        return

    trues = np.array([r["true"] for r in results])
    preds = np.array([r["pred"] for r in results])

    # Hata Metrikleri
    mae = np.mean(np.abs(trues - preds), axis=0)
    mse = np.mean((trues - preds) ** 2, axis=0)
    rmse = np.sqrt(mse)
    
    # R2 Skoru
    ss_res = np.sum((trues - preds) ** 2, axis=0)
    ss_tot = np.sum((trues - np.mean(trues, axis=0)) ** 2, axis=0)
    r2 = 1 - (ss_res / (ss_tot + 1e-8))

    # Markdown Raporu olustur
    report_content = f"""# NutriScan Regresyon Modeli Test Raporu

Bu rapor, projenizde kullanılan besin değeri tahmin modelinin (`{MODEL_PATH}`) yerel test görselleri üzerindeki performansını ölçmek amacıyla üretilmiştir.

## 1. Test Edilen Görseller ve Tahmin Detayları

| Görsel Adı | Değer Türü | Gerçek Değer (Ground Truth) | Model Tahmini | Sapma (Fark) |
| :--- | :--- | :---: | :---: | :---: |
"""
    
    for r in results:
        img = r["image"]
        t = r["true"]
        p = r["pred"]
        labels = ["Kalori (kcal)", "Yağ (g)", "Karbonhidrat (g)", "Protein (g)"]
        for i in range(4):
            diff = p[i] - t[i]
            report_content += f"| {img} | {labels[i]} | {t[i]:.1f} | {p[i]:.1f} | {diff:+.1f} |\n"
        report_content += "| | | | | |\n"

    report_content += f"""
## 2. Genel Hata Metrikleri (Özet Rapor)

Modelin genel başarısını gösteren regresyon hata metrikleri aşağıdadır:

| Metrik | Kalori (kcal) | Yağ (g) | Karbonhidrat (g) | Protein (g) |
| :--- | :---: | :---: | :---: | :---: |
| **MAE (Ortalama Mutlak Hata)** | {mae[0]:.2f} | {mae[1]:.2f} | {mae[2]:.2f} | {mae[3]:.2f} |
| **MSE (Ortalama Kare Hata)** | {mse[0]:.2f} | {mse[1]:.2f} | {mse[2]:.2f} | {mse[3]:.2f} |
| **RMSE (Kök Ortalama Kare Hata)** | {rmse[0]:.2f} | {rmse[1]:.2f} | {rmse[2]:.2f} | {rmse[3]:.2f} |
| **R² Belirleme Katsayısı (Skoru)** | {r2[0]:.4f} | {r2[1]:.4f} | {r2[2]:.4f} | {r2[3]:.4f} |

### Metriklerin Açıklaması:
* **MAE (Mean Absolute Error):** Modelin tahminlerinin gerçek değerlerden ortalama sapma miktarıdır. Örneğin, Kalori MAE değeri **{mae[0]:.1f} kcal** ise, modelimiz kalori tahminlerinde ortalama bu kadar yanılmaktadır.
* **R² Skoru:** Modelin tahmin kalitesini 0 ile 1 arasında gösterir. 1'e ne kadar yakınsa model o kadar başarılıdır.

---
*Rapor olusturulma tarihi: 2026-06-16*
"""

    report_path = "nutrition_report.md"
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report_content)
        
    print("\n==================================================")
    print(f"Rapor basariyla olusturuldu: {report_path}")
    print("==================================================")
    print(f"Kalori MAE (Ortalama Sapma): {mae[0]:.2f} kcal")
    print(f"Protein MAE (Ortalama Sapma): {mae[3]:.2f} g")
    print(f"Karbonhidrat MAE (Ortalama Sapma): {mae[2]:.2f} g")
    print(f"Yağ MAE (Ortalama Sapma): {mae[1]:.2f} g")
    print("==================================================")

if __name__ == "__main__":
    main()
