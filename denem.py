from ultralytics import YOLO

# 1. Modeli yükle
model = YOLO("best5.pt")

# 2. Tahmin yap
# Bilgisayarında 'show=True' bazen pencere hatası verebilir, 
# 'save=True' dersen 'runs/classify/predict' klasörüne sonucu kaydeder.
results = model.predict("yumurta.jpg", save=True)

# 3. Sonuçları al ve ekrana yazdır
for result in results:
    # probs: Olasılıkları içeren objedir
    probs = result.probs 
    
    # En yüksek olasılıklı sınıfın ID'sini al (Örn: 5)
    top1_idx = probs.top1 
    
    # Bu ID'ye karşılık gelen ismi modelden çek (Örn: "Elma")
    tahmin_edilen_isim = result.names[top1_idx]
    
    # Güven skorunu al
    guven_skoru = probs.top1conf.item() # .item() ile tensor'den sayıya çeviriyoruz

    print("\n" + "="*30)
    print(f"SONUÇ: {tahmin_edilen_isim}")
    print(f"GÜVEN: %{guven_skoru * 100:.2f}")
    print("="*30)

input("\nKapatmak için Enter'a bas...")