# NutriScan Flutter Frontend

AI destekli yemek analizi ve günlük besin takibi uygulaması.

## Özellikler
- 🔐 JWT tabanlı kimlik doğrulama (giriş / kayıt)
- 📸 Kamera ve galeri ile yemek fotoğrafı analizi
- 🍽️ Günlük öğün logu ve silme
- 📊 Kalori halkası ve makro besin ilerleme çubukları
- 📅 Tarih seçici ile geçmiş günlere bakış
- 🌙 Premium karanlık tema (mor + turuncu)

## Kurulum

### 1. Bağımlılıkları yükle
```bash
flutter pub get
```

### 2. Backend URL'ini ayarla
`lib/constants/api_constants.dart` dosyasını aç:

- **Android Emülatör:** `http://10.0.2.2:8080` (varsayılan)
- **Fiziksel cihaz veya iOS Simulator:** `http://192.168.1.41:8080` (yerel ağ IP'nizi girin)

### 3. Çalıştır
```bash
flutter run
```

### 4. Release APK derle
```bash
flutter build apk --debug
```

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama giriş noktası
├── constants/
│   ├── api_constants.dart       # API URL sabitleri
│   └── app_theme.dart           # Tema, renkler, tipografi
├── models/
│   └── models.dart              # MealLog, DailySummary, AnalysisResult
├── services/
│   └── api_service.dart         # HTTP istekleri, JWT yönetimi
└── screens/
    ├── login_screen.dart        # Giriş ekranı
    ├── register_screen.dart     # Kayıt ekranı
    ├── dashboard_screen.dart    # Ana ekran (özet + öğün listesi)
    └── analysis_screen.dart     # Fotoğraf çek / analiz / kaydet
```

## Backend API Beklentisi

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/api/auth/login` | POST | `{email, password}` → `{token}` |
| `/api/auth/register` | POST | `{firstName, lastName, email, password, age, gender}` |
| `/api/meal-logs/daily-summary?date=YYYY-MM-DD` | GET | Günlük özet |
| `/api/meal-logs/analyze` | POST (multipart) | Görüntü analizi |
| `/api/meal-logs` | POST | Öğün kaydet |
| `/api/meal-logs/{id}` | DELETE | Öğün sil |

## Gereksinimler
- Flutter 3.x+
- Dart 3.0+
- Android SDK (emülatör veya cihaz)
- Spring Boot backend çalışır durumda

## Renk Paleti
- Ana Mor: `#6C3FC5`
- Derin Mor: `#4A1FA0`
- Turuncu Vurgu: `#FF6B35`
- Arka Plan: `#0E0B1A`
