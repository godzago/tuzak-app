# Tuzak

Şüpheli mesajlardaki risk işaretlerini cihaz üzerinde incelemek için geliştirilen Flutter uygulaması. iOS öncelikli; Android iskeleti ve web önizlemesi içerir.

- Türkçe arayüz, uygulamaya gömülü Inter fontu ve dört risk görünümü.
- Yerel kural motoru, noisy-OR skorlama ve en fazla üç gerekçe.
- Üyelik, sunucu, mesaj geçmişi veya analitik takibi yok.
- Swift Share Extension ve App Group üzerinden geçici metin aktarımı.

**Durum:** İlk geliştirme sürümü. Gerçek kural/veri dosyaları henüz eklenmediği için analiz kapalıdır; açıkça etiketlenmiş örnek sonuçlar incelenebilir. Sentetik testler dolandırıcılık tespit başarısını ölçmez. iOS derleme ve gerçek cihaz doğrulaması bekleniyor.

## Çalıştırma

Flutter 3.44.0 / Dart 3.12.0 ile geliştirilmiştir.

```sh
flutter pub get
flutter run -d chrome
```

Mobil cihaz için `flutter run`; iOS için macOS/Xcode gerekir. Bundle ID: `com.example.tuzak`.

## Doğrulama

```sh
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
```

## Yapı

`lib/core`: tema ve ortak bileşenler · `lib/features/analysis`: motor, veri ve ekranlar · `lib/features/sharing`: iOS köprüsü · `lib/l10n`: çeviriler.

[Veri sözleşmesi](docs/rule-format.md) · [iOS kurulumu](docs/ios-setup.md)

Özel kurallar, gerçek mesaj/test verileri, `.env`, imzalama dosyaları ve yerel ayarlar `.gitignore` ile dışarıda tutulur. Depoda yalnızca boş veri şablonları ve sentetik testler bulunur. Mesaj metni analiz sırasında ağ üzerinden gönderilmez; risk bulunmaması güvenlik garantisi değildir.
