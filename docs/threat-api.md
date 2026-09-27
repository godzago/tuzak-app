# Resmi tehdit API katmanı

Yerel `RuleEngine` ve `rules.json` puanlaması değişmez. `AnalysisController`,
yerel motoru isolate içinde çalıştırır; ardından `ThreatEnrichedAnalyzer`,
algılanan her URL'nin tam hostunu ve her telefon numarasını `Future.wait` ile
paralel sorgular. Tekrarlanan bağlantılar da ayrı istek başlatır. Alt alan adları
silinmez; IP hostları `type=ip` ile sorgulanır. E-posta adresleri sorgulanmaz.

## İstek ve yanıt

`GET https://siberguvenlik.gov.tr/api/address/index?q={domain}&type=domain&per-page=1`

IP hostları aynı uç noktada `type=ip` kullanır. Resmi OpenAPI şeması telefon türü
sunmadığı için telefonlar geçerli genel adres aramasıyla (`q` ve `per-page`, tür
filtresi olmadan) sorgulanır; yalnız `phone`/`telephone` türünde tam eşleşme tehdit
kaydı sayılır.

Yalnız normalize edilmiş host veya telefon numarası gönderilir; mesaj, URL yolu,
kullanıcı bilgisi, port, fragment ve query gönderilmez. Kısaltılmış bağlantılar açılmaz. HTTPS
sertifika doğrulaması açık, yönlendirme takibi kapalıdır. Otomatik yeniden deneme
yoktur. Release/profile sürümlerinde loglama yoktur. Debug sürümünde sorgu türü,
HTTP durumu, kayıt sayısı, süre ve hata sınıfı konsola yazılır; ham host/telefon,
yanıt gövdesi, API anahtarı ve header'lar yazılmaz. 401/403 ayrıca auth hatası
olarak işaretlenir.

Doğrulanan yanıt şekli:

```json
{"totalCount":1,"count":1,"models":[
  {"url":"synthetic.example","type":"domain","desc":"PH","criticality_level":2}
],"page":0,"pageCount":1}
```

Yukarıdaki adres sentetiktir. Canlı, anahtarsız bir sorguda HTTP 200 alındı;
bu gözlem ileride yetkilendirme gerekmeyeceği garantisi değildir.

**Tam eşleşme kontrolü gerekir:** Canlı API'de `q=example.com` farklı bir adres
olan `kgm-example.com` kaydını da döndürdü. Bu yüzden `totalCount > 0` tek başına
tehdit sayılmaz. İlk kayıt tam eşleşmiyorsa, aynı süre bütçesi içinde en
fazla 9999 kayda genişletilen ikinci istek yapılır. Dönen `url` ve `type=domain`
doğrulanır. Tamamlanamayan arama veya bozuk yanıt `null` sayılır; temiz sonuç
olarak gösterilmez. Tamamlanan aramada tam eşleşme yoksa `found: false` döner.

## Sonuca etkisi

- Eşleşme ve `criticality_level` 1–3: **Tehlikeli**; gerekçe ilk sırada.
- Eşleşme ve seviye 4–10 veya eksik/geçersiz: en az **Yüksek risk**; mevcut
  tehlikeli sonuç düşürülmez. Criticality, bir kaydın güvenli olduğu anlamına
  gelmez. Yerel skor değişmez.
- Kategori kodları BP, PH ve MD ekranda Türkçe gösterilir; bilinmeyen kategori
  “Belirtilmemiş” olur. API'den gelen serbest metin arayüze basılmaz.
- `null`: yalnız gerçek bağlantı hatası, iptal veya zaman aşımında döner ve yerel
  sonuçla devam edilir. TLS sertifika hataları, 401/403/429/5xx ve bozuk/eksik
  yanıt sessizce atlanmaz; analiz başarısız durumu gösterilir ve debug nedeni
  kaydedilir.
- Her istek için connect/receive/send ve toplam timeout 3,5 saniyedir; ayrıca
  **tüm paralel sorgular için ortak dört saniyelik süre** vardır. Süre dolduğunda bekleyen
  istekler iptal edilir; zamanında gelen eşleşmeler korunur. Geç yanıtlar sonucu
  değiştirmez. Ekran kapatılınca istekler de iptal edilir.
- Tüm varlık sorguları geçerli cevap aldıysa tam, bir kısmı aldıysa kısmi,
  hiçbiri alamadıysa tamamlanamayan resmi kontrol durumu gösterilir. Sorgulanacak
  varlık yoksa yerel kontrol notu kullanılır. Yerel bulgu yokken
  resmi kontrol kısmi veya erişilemez durumdaysa yeşil düşük risk başlığı yerine
  nötr **Kontrol sınırlı** görünümü kullanılır.

## Yapılandırma

`ThreatApiConfig` programatik olarak verilebilir veya derlemede tanımlanabilir:

| Değişken | Varsayılan |
|---|---|
| `THREAT_API_KEY` | boş |
| `THREAT_API_KEY_HEADER` | `X-API-Key` |
| `THREAT_API_KEY_PREFIX` | boş |

Örneğin sunucu Bearer kullanırsa header `Authorization`, prefix `Bearer ` olur.
Header adı henüz kurum tarafından teyit edilmedi; boş anahtarla auth header'ı
gönderilmez. Gerçek anahtarı kaynak koduna yazmayın. `--dart-define` bir mobil
uygulama içinde anahtarı gizli tutmaz; dağıtım biçimi izin verilen auth modeline
göre belirlenmelidir.

## Açılış ve gizlilik

`ConnectivityService`, `internet_connection_checker_plus` ile gerçek internet
erişimini başlangıçta kontrol eder ve uygulama açıkken durum akışını sürekli
dinler. İnternet yokken üstte ince, kalıcı uyarı görünür; bağlantı dönünce otomatik
kaybolur. Ana ekran ve kontrol düğmesi kullanılabilir kalır. Durum kontrolü hata
verirse cihaz çevrimdışı ilan edilmez. Gerçek API sonucu her analizde ayrıca
değerlendirilir.

Ana ekran, kontrol ve bilgi sayfası yalnız bağlantı hostları ile telefon numaralarının
kurumun servisine gönderildiğini açıklar. Fontlar, yerel kurallar ve yerel analiz internetsiz çalışır.
`assets/usom.json` placeholder olarak kalır; günlük toplu indirme bu
entegrasyonla etkinleştirilmez.

## Doğrulama

`flutter test`: sentetik HTTP yanıtları, auth header'ları, tam/alt dize eşleşmesi,
bozuk yanıtlar, tüm hata durumları, ortak zaman aşımı, iptal, gizlilik, risk
birleştirme ve açılış/sonuç arayüzleri. Birim testleri canlı API'ye bağlanmaz.
Android debug derlemesi ve iOS'ta gerçek cihaz/uçak modu kontrolü ayrıca yapılır.
Web'de sunucunun CORS engeli bağlantı hatası olarak yerel analize dönüşebilir.

Canlı teşhis (yalnız resmi API'ye bağlanır, incelenen siteyi açmaz):

```sh
dart --enable-asserts run tool/diagnose_threat_api.dart toria.apple03cloudstore.com
```

[1172234 numaralı kayıt için kök neden ve doğrulama](incidents/1172234.md).
