# YOLOv8 Yemek Sınıflandırma Modeli (`best5.pt`) Yerel Test Raporu

Bu rapor, projenizde yemek tanıma için kullanılan YOLOv8m-cls sınıflandırma modelinin yerel test görselleri üzerindeki doğruluğunu ölçmek amacıyla üretilmiştir.

## 1. Test Detayları ve Görsel Tahminleri

| Görsel Adı | Beklenen Sınıf | Model Tahmini | Güven Skoru (Confidence) | Durum (Top-1) | Modelin İlk 3 Tahmini |
| :--- | :--- | :--- | :---: | :---: | :--- |
| yumurta.jpg | haslanmis-yumurta | haslanmis-yumurta | %100.0 | BAŞARILI ✅ | haslanmis-yumurta, kayisi, mango |
| egg2.jpg | haslanmis-yumurta | croque_madame | %99.9 | BAŞARISIZ ❌ | croque_madame, huevos_rancheros, sucuklu-yumurta |
| hamburger.jpg | hamburger | hamburger | %100.0 | BAŞARILI ✅ | hamburger, lobster_roll_sandwich, pulled_pork_sandwich |
| kuru.jpg | sulu-kuru-fasulye-yemegi | sulu-kuru-fasulye-yemegi | %89.6 | BAŞARILI ✅ | sulu-kuru-fasulye-yemegi, sulu-nohut-yemegi, sulu-barbunya-yemegi |
| kuru2.jpg | sulu-kuru-fasulye-yemegi | sulu-kuru-fasulye-yemegi | %100.0 | BAŞARILI ✅ | sulu-kuru-fasulye-yemegi, sulu-barbunya-yemegi, macaroni_and_cheese |
| lahmacun2.jpg | lahmacun | lahmacun | %100.0 | BAŞARILI ✅ | lahmacun, kiymali-pide, tacos |
| makarna2.jpg | spaghetti_bolognese | spaghetti_bolognese | %94.8 | BAŞARILI ✅ | spaghetti_bolognese, spaghetti_carbonara, lobster_bisque |
| pilav.jpg | pilav | pilav | %100.0 | BAŞARILI ✅ | pilav, patates-salatasi, patates-puresi |
| pilav2.jpg | pilav | fried_rice | %35.6 | BAŞARISIZ ❌ | fried_rice, pad_thai, ramen |
| pizza.jpg | pizza | pizza | %93.4 | BAŞARILI ✅ | pizza, waffles, pho |

## 2. Genel Başarı İstatistikleri

* **Toplam Test Edilen Görsel Sayısı:** 10
* **Doğru Tahmin Edilen (Top-1):** 8
* **Yerel Sınıflandırma Doğruluğu (Top-1 Accuracy):** %80.00
* **Top-5 Doğruluk Oranı (Top-5 Accuracy):** %100.00

### Metriklerin Açıklaması:
* **Top-1 Accuracy:** Modelin en yüksek olasılık verdiği ilk tahminin doğru yemek sınıfı olması durumudur.
* **Top-5 Accuracy:** Doğru yemeğin, modelin olasılık sıralamasındaki ilk 5 tahmini arasında yer alması durumudur.

---
*Rapor olusturulma tarihi: 2026-06-17*
