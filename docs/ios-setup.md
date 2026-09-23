# iOS kurulumu ve cihaz kontrolü

Xcode projesinde `Runner` ve `ShareExtension` hedefleri hazırdır. Windows üzerinde
Swift derlenmedi; macOS/Xcode ve gerçek iPhone doğrulaması gereklidir.

1. `flutter pub get` ve `flutter build ios --config-only` çalıştır.
2. `ios/Runner.xcworkspace` dosyasını Xcode'da aç.
3. İki hedef için aynı Apple Developer takımını seç. Takım bilgilerini public
   depoya commit etme; yerel Xcode ayarları veya ignore edilmiş `Signing.xcconfig` kullan.
4. Bundle ID'ler: `com.example.tuzak`, `com.example.tuzak.ShareExtension`.
5. Her iki hedefte App Groups: `group.com.example.tuzak`. Bu kimliklerin Apple
   hesabında kullanılabilir olması gerekir; gerekirse tüm referansları birlikte değiştir.
6. `flutter build ios --release --no-codesign` ile derleme; ardından cihazda imzalı
   çalıştırma yap. Sürüm yükseltirken extension'ın `MARKETING_VERSION` ve
   `CURRENT_PROJECT_VERSION` değerlerini uygulamayla birlikte güncelle.

Paylaşım akışı: metni destekleyen kaynak uygulama → Paylaş → Tuzak → Tuzak'a aktar
→ Kapat → kullanıcı Tuzak'ı açar → metin kutusu dolar → Kontrol et.
Ana uygulamayı zorla açan özel API / responder-chain geçişi kullanılmaz.

Geçici dosya App Group içinde dosya korumasıyla yazılır ve yedeklemeye dahil
edilmez. Okumada silinir. 10 dakikadan eski içerik kabul edilmez; dosyanın fiziksel
temizliği bir sonraki okumada yapılır. Yeni paylaşım önceki bekleyen içeriğin yerini alır.

Cihazda doğrula:

- Uygulama kapalı / arka planda / açıkken paylaşım ve geri dönüş.
- Boş metin, URL, Unicode, çok uzun metin, iptal ve arka arkaya paylaşımlar.
- Süresi dolmuş içeriğin alınmaması; aynı içeriğin ikinci kez gelmemesi.
- Mesajlar/WhatsApp/Mail'in seçilen içerik için metin paylaşımını sunması.
- Uçak modunda ilk açılış, Inter fontu, VoiceOver ve büyük yazı.
- 112 aksiyonunun yalnızca açık kullanıcı onayıyla telefon uygulamasına geçmesi.

Uygulama gerçek kural seti olmadan önizleme olarak kalır. App Store yayın öncesi
kurallar, kaynak güncelliği, imzalama, gizlilik beyanı ve cihaz testleri tamamlanmalıdır.
