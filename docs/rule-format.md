# Yerel veri sözleşmesi

## Etkin veri formatı

Hazırlanan `../assets/rules.json`, `text_categories`, `url_signals` ve gömülü
`brands` alanlarını içerir. `python tool/sync_analysis_assets.py` ile Flutter'ın
`assets/data/` klasörüne kopyalanır. `asset_rule_adapter.dart` yeni şemayı okur;
21 sinyal, noisy-OR, `<0.25 / 0.25..0.60 / >0.60` eşikleri ve en güçlü üç farklı
gerekçe uygulanır. Resmi adres yalnız kendi marka taklidi/benzerliği sinyalini
bastırır; diğer sinyalleri veya başka bir şüpheli bağlantıyı temizlemez.

Yeni USOM şeması `version`, UTC `generated`, SHA-256 hex listesi `entries`
alanlarından oluşur. Placeholder/yerel-doğrulanmamış/eksik/bozuk USOM yerel metin
ve URL analizini kapatmaz; `usomAvailable` / `usomChecked` false olur. Sahte hash'ler yalnız test adaptöründeki
`allowSyntheticUsom` seçeneğiyle kullanılabilir. Canlı indirme halen kapalıdır.

Yerel sonuçtan sonra ayrı bir [resmi API katmanı](threat-api.md) çalışır.
Arayüzdeki yerel/kısmi/tam kontrol bilgisi bu sorguların sonucunu yansıtır;
yerel USOM dosyasının kullanılabilirliğiyle karıştırılmaz.

URL'ler orijinal metinden çıkarılır; Türkçe harf katlama yalnız metne uygulanır.
Unicode hostlar Punycode'a çevrilir; tam IDNA 2003 nameprep desteği henüz yoktur.
Canlı veri açılmadan önce güncelleme betiğiyle IDN profil eşdeğerliği tamamlanmalıdır.
IPv4/IPv6, alt alan adı sınırları, `@` kullanıcı bilgisi ve açık HTTP desteklenir.
URL açma, DNS sorgusu veya kısaltılmış link çözme yapılmaz.

98 hazırlanmış senaryo `test/analysis/authored_assets_test.dart` ile doğrudan
motorda sınanır. Paket yükleme, USOM placeholder ayrımı ve gerçek analizden sonuç
ekranına geçiş de test edilir. Yeni veriler için senkronizasyondan sonra Flutter'ı
durdurup yeniden çalıştırın; hot reload başlangıçtaki veri yüklemesini tekrarlamaz.

## Eski örnek/test formatı

Aşağıdaki şema eski sentetik testler ve boş örneklerle geriye uyumluluk içindir.
Yeni veri formatında ayrı bir `brands.json` gerekmez.

Public depoda yalnızca `assets/data/*.example.json` bulunur. Bunların `pending`
durumu gerçek analizi kapatır; sahte sonuç gösterilmez. Özel veri dosyaları
`.gitignore` ile dışarıda tutulur. Flutter, yerelde mevcut olan gerçek JSON
dosyalarını `assets/data/` dizininden uygulamaya paketler. Uygulamaya paketlenmiş
veriler tersine mühendislikle okunabilir; API anahtarları bu dizine konulmamalıdır.

### Eski rules.json

```json
{
  "schemaVersion": 1,
  "version": "your-reviewed-version",
  "status": "ready",
  "thresholds": {"suspicious": 0.25, "high": 0.6},
  "rules": [
    {
      "id": "unique-rule-id",
      "reason": "urgency",
      "kind": "contains",
      "weight": 0.25,
      "patterns": ["synthetic example only"]
    }
  ]
}
```

- `kind`: `contains`, `regex`, `host`, `tld`, `brandMismatch`.
- `reason`: `urgency`, `credentials`, `payment`, `shortLink`, `brandMismatch`,
  `suspiciousDomain`, `generic`. USOM ve eşleşme-yok gerekçesini motor üretir.
- `contains`/`regex` normalize edilmiş metinde çalışır. Regex'ler güvenilen,
  önceden incelenmiş kurallar olmalıdır; karmaşık desenler performans testi gerektirir.
- `host` tam alan adı veya onun alt alan adıyla eşleşir. `tld` son uzantıyı denetler.
- `brandMismatch`, marka metinde bağımsız kelime olarak geçiyorsa bağlantıları
  o markanın resmi alan adlarıyla karşılaştırır. Bu sinyal tek başına kimlik kanıtı değildir.
- Her kural bir kez skorlanır; noisy-OR: `1 - product(1 - weight)`.
- `< 0.25` düşük; `0.25..0.60` şüpheli; `> 0.60` yüksek. Skor bir olasılık değildir.
- En güçlü üç farklı gerekçe gösterilir. USOM eşleşmesi tehlikeli seviyesini geçersiz
  kılınamaz biçimde seçer ve ilk gerekçedir.

### Eski brands.json

```json
{"schemaVersion":1,"version":"your-version","status":"ready","brands":[
  {"aliases":["Testmarka"],"domains":["testmarka.test"]}
]}
```

### Eski usom.json

```json
{"schemaVersion":1,"version":"your-version","status":"ready",
 "hashAlgorithm":"sha256","domainHashes":[]}
```

Hash girdisi protokol/yol/port içermeyen küçük harfli, sondaki noktası kaldırılmış
**tam host** değerinin UTF-8 baytlarıdır. Hash'ler küçük harfli hex biçimindedir.
Alt alan adına otomatik yayılım yoktur. IDN/punycode ve alan adı benzerliği için
üretim veri sözleşmesi henüz belirlenmedi; bu sürüm bunları doğruladığını iddia etmez.

Yalnız eski şemada üç dosyanın da `ready` olması ve kuralların boş olmaması gerekir. Eksik/bozuk
veri hiçbir zaman düşük risk sonucu üretmez. URL'ler açılmaz, DNS sorgusu yapılmaz,
kısaltılmış bağlantılar çözülmez. Uzaktan güncelleme bu sürümde yoktur.

## Testler

`test/fixtures/synthetic_cases.json` kişisel veri içermeyen 20 eski mühendislik
senaryosudur. Yeni `test/fixtures/test_cases.json` 98 hazırlanmış mesaj içerir;
ikisi kullanıcı tarafından bildirilen açık tehdit kaydındaki alan adını kullanır.
Yanlış alarm / kaçırma oranları henüz ölçülmemiştir. Gerçek veri setleri
`private/` altında veya ignore edilmiş `test/fixtures/test_cases.json` yolunda tutulmalıdır.

## 1.1.0 marka ve adres kuralları

Aktif marka listesi ayrı bir `brands.json` yerine `rules.json.brands` içindedir:
26 Türkiye markasına Apple, iCloud, Google, Microsoft, Meta/Facebook, WhatsApp,
Netflix, PayPal ve Amazon eklenmiştir (35 kayıt). Resmi alan adı eşleşmesi nokta
sınırlarıyla yapılır; `.com` gibi bir TLD tek başına güvenilirlik kanıtı değildir.

Marka + sayı + yapılandırılmış ekler (`apple03cloudstore` gibi) tam parçalarla
eşleştirilir; keyfi alt dize aranmaz (`pineapple`/`appleton` eşleşmez). Bu biçim
brand_mismatch ve lookalike üretir. Çok uzun sayılı girdilerde regex geri izleme
riski olmaması için sınırlı dinamik bölümleme kullanılır.

`deceptive_subdomain` marka listesinden bağımsızdır: başka bir gerçek alan adı
altına yerleştirilmiş `bilinmeyenmarka.com` benzeri yapı veya metinde geçen adı
tekrarlayan derin, giriş/hesap etiketli alt alan adları için yapısal şüphe üretir.
Bilinmeyen bir markanın resmi alan adını bildiğini iddia etmez. Derinlik tek
başına mevcut düşük ağırlıklı `long_subdomain` sinyalidir.
