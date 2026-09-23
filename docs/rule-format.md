# Yerel veri sözleşmesi

Bu, motorun ilk sürümündeki **geçici entegrasyon şemasıdır**. Asıl `rules.json`
ve `test_cases.json` henüz sağlanmadı. Geldiklerinde adaptör ve regresyon testleri
o dosyalara göre güncellenmelidir. Buradaki sentetik ağırlıklar ürün önerisi değildir.

Public depoda yalnızca `assets/data/*.example.json` bulunur. Bunların `pending`
durumu gerçek analizi kapatır; arayüz örneklerini açar. Özel veri dosyaları
`.gitignore` ile dışarıda tutulur. Flutter, yerelde mevcut olan gerçek JSON
dosyalarını `assets/data/` dizininden uygulamaya paketler. Uygulamaya paketlenmiş
veriler tersine mühendislikle okunabilir; API anahtarları bu dizine konulmamalıdır.

## rules.json

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

## brands.json

```json
{"schemaVersion":1,"version":"your-version","status":"ready","brands":[
  {"aliases":["Testmarka"],"domains":["testmarka.test"]}
]}
```

## usom.json

```json
{"schemaVersion":1,"version":"your-version","status":"ready",
 "hashAlgorithm":"sha256","domainHashes":[]}
```

Hash girdisi protokol/yol/port içermeyen küçük harfli, sondaki noktası kaldırılmış
**tam host** değerinin UTF-8 baytlarıdır. Hash'ler küçük harfli hex biçimindedir.
Alt alan adına otomatik yayılım yoktur. IDN/punycode ve alan adı benzerliği için
üretim veri sözleşmesi henüz belirlenmedi; bu sürüm bunları doğruladığını iddia etmez.

Üç dosyanın da `ready` olması ve kuralların boş olmaması gerekir. Eksik/bozuk
veri hiçbir zaman düşük risk sonucu üretmez. URL'ler açılmaz, DNS sorgusu yapılmaz,
kısaltılmış bağlantılar çözülmez. Uzaktan güncelleme bu sürümde yoktur.

## Testler

`test/fixtures/synthetic_cases.json` kişisel veri içermeyen 20 mühendislik
senaryosudur. Sağlanacak `test_cases.json` veya gerçek mesaj veri seti değildir.
Yanlış alarm / kaçırma oranları henüz ölçülmemiştir. Gerçek veri setleri
`private/` altında veya ignore edilmiş `test/fixtures/test_cases.json` yolunda tutulmalıdır.
