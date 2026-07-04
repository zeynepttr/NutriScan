import os
import json
from ultralytics import YOLO
import numpy as np

# Dosya yollari
MODEL_PATH = "best5.pt"
IMAGE_DIR = "."

# Modelin kendi sınıf isimlerine göre güncellenmiş Beklenen Yemek İsimleri (Ground Truth)
# Bu eşleşmeler, modelin hem Türkçe hem de İngilizce birleştirilmiş veri kümesindeki sınıfları doğrulamak içindir.
ground_truth_classes = {
    "yumurta.jpg": "haslanmis-yumurta",
    "egg2.jpg": "haslanmis-yumurta",
    "hamburger.jpg": "hamburger",
    "kuru.jpg": "sulu-kuru-fasulye-yemegi", 
    "kuru2.jpg": "sulu-kuru-fasulye-yemegi",
    "lahmacun2.jpg": "lahmacun",
    "makarna2.jpg": "spaghetti_bolognese",
    "pilav.jpg": "pilav",
    "pilav2.jpg": "pilav",
    "pizza.jpg": "pizza"
}

def main():
    print("==================================================")
    print("   NutriScan YOLO Sınıflandırma Model Testi       ")
    print("==================================================")
    
    if not os.path.exists(MODEL_PATH):
        print(f"Hata: {MODEL_PATH} dosyasi bulunamadi!")
        return

    print("Model yukleniyor (YOLOv8m-cls)...")
    model = YOLO(MODEL_PATH)
    print("Model basariyla yuklendi.")

    results = []
    dogru_sayisi = 0
    toplam_gorsel = 0

    print("\nTest gorselleri taraniyor ve siniflandirma yapiliyor...")
    for img_name, expected_class in ground_truth_classes.items():
        img_path = os.path.join(IMAGE_DIR, img_name)
        if not os.path.exists(img_path):
            continue
            
        try:
            # Tahmin yap
            pred_results = model(img_path, verbose=False)
            probs = pred_results[0].probs
            names = model.names
            
            top1_idx = probs.top1
            predicted_class = names[top1_idx]
            confidence = float(probs.top1conf)
            
            # En yuksek olasilikli ilk 5 sinifi al (Top-5 kontrolu icin)
            top5_indices = probs.top5
            top5_classes = [names[idx] for idx in top5_indices]
            
            # Tam eşleşme veya alt kelime kontrolü
            top1_correct = (predicted_class.lower() == expected_class.lower() or 
                            expected_class.lower() in predicted_class.lower() or 
                            predicted_class.lower() in expected_class.lower())
                            
            top5_correct = any(expected_class.lower() in c.lower() or c.lower() in expected_class.lower() for c in top5_classes)
            
            if top1_correct:
                dogru_sayisi += 1
                
            toplam_gorsel += 1
            
            results.append({
                "image": img_name,
                "expected": expected_class,
                "predicted": predicted_class,
                "confidence": confidence,
                "top1_correct": top1_correct,
                "top5_correct": top5_correct,
                "top5": top5_classes[:3] # Ilk 3 tahmini rapora yazalim
            })
            print(f"  - {img_name}: Beklenen={expected_class}, Tahmin={predicted_class} (Conf: {confidence:.2f})")
        except Exception as e:
            print(f"  - Hata ({img_name}): {e}")

    if toplam_gorsel == 0:
        print("\nHata: Klasorde test edilecek uygun gorsel bulunamadi.")
        return

    accuracy = (dogru_sayisi / toplam_gorsel) * 100
    top5_acc = (sum(1 for r in results if r["top5_correct"]) / toplam_gorsel) * 100

    # Markdown Raporu olustur
    report_content = f"""# YOLOv8 Yemek Sınıflandırma Modeli (`{MODEL_PATH}`) Yerel Test Raporu

Bu rapor, projenizde yemek tanıma için kullanılan YOLOv8m-cls sınıflandırma modelinin yerel test görselleri üzerindeki doğruluğunu ölçmek amacıyla üretilmiştir.

## 1. Test Detayları ve Görsel Tahminleri

| Görsel Adı | Beklenen Sınıf | Model Tahmini | Güven Skoru (Confidence) | Durum (Top-1) | Modelin İlk 3 Tahmini |
| :--- | :--- | :--- | :---: | :---: | :--- |
"""
    
    for r in results:
        status = "BAŞARILI ✅" if r["top1_correct"] else "BAŞARISIZ ❌"
        top3_str = ", ".join(r["top5"])
        report_content += f"| {r['image']} | {r['expected']} | {r['predicted']} | %{r['confidence']*100:.1f} | {status} | {top3_str} |\n"

    report_content += f"""
## 2. Genel Başarı İstatistikleri

* **Toplam Test Edilen Görsel Sayısı:** {toplam_gorsel}
* **Doğru Tahmin Edilen (Top-1):** {dogru_sayisi}
* **Yerel Sınıflandırma Doğruluğu (Top-1 Accuracy):** %{accuracy:.2f}
* **Top-5 Doğruluk Oranı (Top-5 Accuracy):** %{top5_acc:.2f}

### Metriklerin Açıklaması:
* **Top-1 Accuracy:** Modelin en yüksek olasılık verdiği ilk tahminin doğru yemek sınıfı olması durumudur.
* **Top-5 Accuracy:** Doğru yemeğin, modelin olasılık sıralamasındaki ilk 5 tahmini arasında yer alması durumudur.

---
*Rapor olusturulma tarihi: 2026-06-17*
"""

    report_path = "classification_report.md"
    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report_content)
        
    print("\n==================================================")
    print(f"Rapor basariyla olusturuldu: {report_path}")
    print("==================================================")
    print(f"Toplam Test Görseli: {toplam_gorsel}")
    print(f"Doğruluk Oranı (Top-1 Accuracy): %{accuracy:.2f}")
    print(f"Top-5 Doğruluk Oranı: %{top5_acc:.2f}")
    print("==================================================")

if __name__ == "__main__":
    main()
