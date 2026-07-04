# NutriScan Regresyon Modeli Test Raporu

Bu rapor, projenizde kullanılan besin değeri tahmin modelinin (`nutriscan_full.pt`) yerel test görselleri üzerindeki performansını ölçmek amacıyla üretilmiştir.

## 1. Test Edilen Görseller ve Tahmin Detayları

| Görsel Adı | Değer Türü | Gerçek Değer (Ground Truth) | Model Tahmini | Sapma (Fark) |
| :--- | :--- | :---: | :---: | :---: |
| yumurta.jpg | Kalori (kcal) | 100.0 | 174.6 | +74.6 |
| yumurta.jpg | Yağ (g) | 7.5 | 0.0 | -7.5 |
| yumurta.jpg | Karbonhidrat (g) | 0.6 | 18.5 | +17.9 |
| yumurta.jpg | Protein (g) | 9.0 | 19.9 | +10.9 |
| | | | | |
| egg2.jpg | Kalori (kcal) | 100.0 | 105.9 | +5.9 |
| egg2.jpg | Yağ (g) | 7.5 | 6.7 | -0.8 |
| egg2.jpg | Karbonhidrat (g) | 0.6 | 17.7 | +17.1 |
| egg2.jpg | Protein (g) | 9.0 | 10.6 | +1.6 |
| | | | | |
| hamburger.jpg | Kalori (kcal) | 500.0 | 284.4 | -215.6 |
| hamburger.jpg | Yağ (g) | 25.0 | 12.9 | -12.1 |
| hamburger.jpg | Karbonhidrat (g) | 40.0 | 19.1 | -20.9 |
| hamburger.jpg | Protein (g) | 22.0 | 22.2 | +0.2 |
| | | | | |
| kuru.jpg | Kalori (kcal) | 350.0 | 502.3 | +152.3 |
| kuru.jpg | Yağ (g) | 8.0 | 21.5 | +13.5 |
| kuru.jpg | Karbonhidrat (g) | 50.0 | 27.8 | -22.2 |
| kuru.jpg | Protein (g) | 18.0 | 26.8 | +8.8 |
| | | | | |
| kuru2.jpg | Kalori (kcal) | 350.0 | 591.2 | +241.2 |
| kuru2.jpg | Yağ (g) | 8.0 | 37.4 | +29.4 |
| kuru2.jpg | Karbonhidrat (g) | 50.0 | 56.4 | +6.4 |
| kuru2.jpg | Protein (g) | 18.0 | 46.1 | +28.1 |
| | | | | |
| lahmacun2.jpg | Kalori (kcal) | 250.0 | 557.8 | +307.8 |
| lahmacun2.jpg | Yağ (g) | 9.0 | 19.7 | +10.7 |
| lahmacun2.jpg | Karbonhidrat (g) | 32.0 | 26.4 | -5.6 |
| lahmacun2.jpg | Protein (g) | 10.0 | 46.3 | +36.3 |
| | | | | |
| makarna2.jpg | Kalori (kcal) | 300.0 | 139.5 | -160.5 |
| makarna2.jpg | Yağ (g) | 5.0 | 14.8 | +9.8 |
| makarna2.jpg | Karbonhidrat (g) | 55.0 | 17.3 | -37.7 |
| makarna2.jpg | Protein (g) | 10.0 | 15.8 | +5.8 |
| | | | | |
| pilav.jpg | Kalori (kcal) | 250.0 | 366.3 | +116.3 |
| pilav.jpg | Yağ (g) | 6.0 | 11.7 | +5.7 |
| pilav.jpg | Karbonhidrat (g) | 45.0 | 42.4 | -2.6 |
| pilav.jpg | Protein (g) | 4.0 | 20.6 | +16.6 |
| | | | | |
| pilav2.jpg | Kalori (kcal) | 250.0 | 410.1 | +160.1 |
| pilav2.jpg | Yağ (g) | 6.0 | 13.0 | +7.0 |
| pilav2.jpg | Karbonhidrat (g) | 45.0 | 27.4 | -17.6 |
| pilav2.jpg | Protein (g) | 4.0 | 40.3 | +36.3 |
| | | | | |
| pizza.jpg | Kalori (kcal) | 650.0 | 566.0 | -84.0 |
| pizza.jpg | Yağ (g) | 22.0 | 34.9 | +12.9 |
| pizza.jpg | Karbonhidrat (g) | 85.0 | 36.3 | -48.7 |
| pizza.jpg | Protein (g) | 26.0 | 45.5 | +19.5 |
| | | | | |

## 2. Genel Hata Metrikleri (Özet Rapor)

Modelin genel başarısını gösteren regresyon hata metrikleri aşağıdadır:

| Metrik | Kalori (kcal) | Yağ (g) | Karbonhidrat (g) | Protein (g) |
| :--- | :---: | :---: | :---: | :---: |
| **MAE (Ortalama Mutlak Hata)** | 151.85 | 10.94 | 19.68 | 16.42 |
| **MSE (Ortalama Kare Hata)** | 30024.23 | 170.81 | 572.97 | 431.84 |
| **RMSE (Kök Ortalama Kare Hata)** | 173.28 | 13.07 | 23.94 | 20.78 |
| **R² Belirleme Katsayısı (Skoru)** | -0.1821 | -2.8307 | -0.0109 | -7.4343 |

### Metriklerin Açıklaması:
* **MAE (Mean Absolute Error):** Modelin tahminlerinin gerçek değerlerden ortalama sapma miktarıdır. Örneğin, Kalori MAE değeri **151.8 kcal** ise, modelimiz kalori tahminlerinde ortalama bu kadar yanılmaktadır.
* **R² Skoru:** Modelin tahmin kalitesini 0 ile 1 arasında gösterir. 1'e ne kadar yakınsa model o kadar başarılıdır.

---
*Rapor olusturulma tarihi: 2026-06-16*
