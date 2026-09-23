// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Tuzak';

  @override
  String get tagline => 'Tıklamadan önce,\nbir kontrol.';

  @override
  String get homeSubtitle =>
      'Şüpheli mesajı yapıştır. Risk işaretlerine\nbirlikte bakalım.';

  @override
  String get offline => 'Cihazında çalışır';

  @override
  String get messageLabel => 'KONTROL EDİLECEK MESAJ';

  @override
  String get messageHint =>
      'SMS, WhatsApp veya e-posta mesajını buraya yapıştır…';

  @override
  String get paste => 'Yapıştır';

  @override
  String get check => 'Kontrol et';

  @override
  String get checking => 'İnceleniyor…';

  @override
  String get clear => 'Mesajı temizle';

  @override
  String get privacyNote => 'Mesajın yalnızca senin cihazında kalır.';

  @override
  String get privacyShort => 'Üyelik yok. Mesaj geçmişi yok.';

  @override
  String get howItWorks => 'NASIL ÇALIŞIR?';

  @override
  String get stepPaste => 'Mesajı yapıştır';

  @override
  String get stepCheck => 'İşaretleri incele';

  @override
  String get stepDecide => 'Bilinçli karar ver';

  @override
  String get previewTitle => 'Önce bir göz at';

  @override
  String get previewSubtitle => 'Dört farklı örnek sonucu keşfet.';

  @override
  String get previewLabel => 'ÖRNEK SONUÇ';

  @override
  String get previewNotice =>
      'Bu bir tasarım örneğidir; mesajın analiz edilmedi.';

  @override
  String get previewFootnote =>
      'Önizleme sürümü · Gerçek analiz için kural seti bekleniyor.';

  @override
  String get analysis => 'Mesaj analizi';

  @override
  String get back => 'Geri';

  @override
  String get lowLabel => 'Düşük risk';

  @override
  String get suspiciousLabel => 'Şüpheli';

  @override
  String get highLabel => 'Yüksek risk';

  @override
  String get dangerousLabel => 'Tehlikeli';

  @override
  String get lowTitle => 'Belirgin risk\nbulunamadı.';

  @override
  String get suspiciousTitle => 'Biraz temkinli\nolmakta fayda var.';

  @override
  String get highTitle => 'Bu mesajda\nrisk işaretleri var.';

  @override
  String get dangerousTitle => 'Bu bağlantıdan\nuzak dur.';

  @override
  String get lowDescription =>
      'Kontrol edilen yerel kurallar belirgin bir risk işareti bulmadı. Bu, güvenlik garantisi değildir.';

  @override
  String get suspiciousDescription =>
      'Bazı ifadeler veya bağlantılar dikkat gerektiriyor. İşlem yapmadan önce resmi kanaldan doğrula.';

  @override
  String get highDescription =>
      'Bu mesaj dolandırıcılık girişimiyle ilişkili işaretler taşıyor. Acele etmeden bir adım geri çekil.';

  @override
  String get dangerousDescription =>
      'Mesajdaki bir alan adı cihazdaki zararlı alan adı listesiyle eşleşiyor. Bağlantıyı açma.';

  @override
  String get whyLow => 'NELERE BAKTIK?';

  @override
  String get whyFlagged => 'NEDEN DİKKAT ETMELİSİN?';

  @override
  String get recommendedActions => 'ŞİMDİ NE YAPMALI?';

  @override
  String get scanAnother => 'Başka mesaj kontrol et';

  @override
  String get resultDisclaimer =>
      'Tuzak bir yardımcıdır; gönderenin kimliğini doğrulamaz.';

  @override
  String get noSignalsTitle => 'Belirgin bir kural eşleşmesi yok';

  @override
  String get noSignalsBody =>
      'İncelenen metinde etkin kurallarla eşleşen bir risk işareti bulunamadı.';

  @override
  String get urgencyTitle => 'Acele ettiren ifadeler';

  @override
  String get urgencyBody =>
      'Hemen işlem yapmanı isteyen dil, düşünmeden karar vermene yol açabilir.';

  @override
  String get credentialsTitle => 'Şifre veya kod talebi';

  @override
  String get credentialsBody =>
      'Mesaj, özel erişim bilgilerini ya da tek kullanımlık kodunu paylaşmanı istiyor.';

  @override
  String get paymentTitle => 'Ödeme talebi';

  @override
  String get paymentBody =>
      'İşlem yapmadan önce ödeme isteğini bağımsız bir resmi kanaldan doğrula.';

  @override
  String get shortLinkTitle => 'Hedefi gizleyen bağlantı';

  @override
  String get shortLinkBody =>
      'Kısaltılmış bağlantının son adresi çevrimdışı doğrulanamaz.';

  @override
  String get brandTitle => 'Markayla uyuşmayan alan adı';

  @override
  String get brandBody =>
      'Mesajdaki marka adıyla bağlantının alan adı, yerel resmi adres listesinde uyuşmuyor.';

  @override
  String get domainTitle => 'Şüpheli alan adı';

  @override
  String get domainBody =>
      'Bağlantı, kural setinde tanımlanan bir alan adı risk işareti taşıyor.';

  @override
  String get usomTitle => 'Zararlı alan adı eşleşmesi';

  @override
  String get usomBody =>
      'Bir alan adı, cihazda bulunan USOM veri kümesiyle eşleşti.';

  @override
  String get genericSignalTitle => 'Dikkat gerektiren ifade';

  @override
  String get genericSignalBody =>
      'Mesaj, yerel kural setinde tanımlanan bir risk örüntüsüyle eşleşiyor.';

  @override
  String get protectSecretsTitle => 'Kodların ve şifrelerin sende kalsın';

  @override
  String get protectSecretsBody =>
      'Tek kullanımlık SMS kodunu, kart şifreni veya hesap parolanı kimseyle paylaşma.';

  @override
  String get officialAppTitle => 'Resmi uygulamadan kontrol et';

  @override
  String get officialAppBody =>
      'Şüphen varsa bağlantıya dokunmak yerine kurumun uygulamasını kendin aç.';

  @override
  String get verifyTitle => 'Göndereni bağımsız olarak doğrula';

  @override
  String get verifyBody =>
      'Mesajdaki numarayı kullanmadan, kurumun bilinen resmi iletişim kanalından teyit al.';

  @override
  String get doNotTapTitle => 'Bağlantıyı açma, yanıt verme';

  @override
  String get doNotTapBody =>
      'Kişisel bilgi paylaşma ve mesaj üzerinden ödeme yapma.';

  @override
  String get deleteTitle => 'Mesajı sil veya engelle';

  @override
  String get deleteBody =>
      'Gerekli bir bildirim için kanıtı sakladıktan sonra mesajı kaldırabilirsin.';

  @override
  String get contactBankTitle => 'Bilgi paylaştıysan bankana ulaş';

  @override
  String get contactBankBody =>
      'Kartının arkasındaki numarayı veya bankanın resmi uygulamasını kullan.';

  @override
  String get emergencyTitle => 'Acil tehlikede 112';

  @override
  String get emergencyBody =>
      'Yalnızca acil yardım gerektiren bir durum varsa ara.';

  @override
  String get call => 'Ara';

  @override
  String get callConfirmTitle => 'Telefon uygulaması açılsın mı?';

  @override
  String get callConfirmBody =>
      '112 yalnızca acil durumlar içindir. Arama telefon uygulamasında devam eder.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get callUnavailable =>
      'Telefon uygulaması açılamadı. Acil durumda telefonundan 112’yi arayabilirsin.';

  @override
  String get clipboardEmpty => 'Panoda yapıştırılabilecek bir metin yok.';

  @override
  String get clipboardUnavailable =>
      'Panoya erişilemedi. Mesajı metin alanına elle yapıştırabilirsin.';

  @override
  String get analysisUnavailable =>
      'Analiz henüz hazır değil. Doğrulanmış kural seti bu sürüme eklenmedi. Aşağıdan örnek sonuçları inceleyebilirsin.';

  @override
  String get analysisFailed =>
      'Analiz tamamlanamadı. Mesaj için bir risk sonucu üretilmedi. Lütfen yeniden dene.';

  @override
  String get inputTooLong =>
      'Tek seferde en fazla 10.000 karakter kontrol edebilirsin.';

  @override
  String get sharedMessageLoaded =>
      'Paylaştığın mesaj hazır. Kontrol et’e dokunabilirsin.';

  @override
  String get shareUnavailable =>
      'Paylaşılan mesaj alınamadı. Mesajı kopyalayıp yapıştırabilirsin.';

  @override
  String get infoTitle => 'Tuzak hakkında';

  @override
  String get infoIntro => 'Bir an durmak,\nfark yaratabilir.';

  @override
  String get infoDescription =>
      'Tuzak, mesajlardaki dolandırıcılık işaretlerini anlamana yardımcı olmak için tasarlandı.';

  @override
  String get privacyTitle => 'Özel olan, özel kalır';

  @override
  String get privacyBody =>
      'Mesajlar sunucuya gönderilmez. Hesap, analiz geçmişi, reklam veya analitik takibi yoktur. İşlem bitince mesaj bellekte tutulmaz.';

  @override
  String get sourcesTitle => 'Yerel kurallar, açık sınırlar';

  @override
  String get sourcesBody =>
      'Analiz; metin kuralları, resmi marka adresleri ve yerel zararlı alan adı listesiyle çalışacak. Kaynaklar eklenmeden gerçek analiz etkinleştirilmez. Liste eşleşmesi bulunmaması bir adresin güvenli olduğunu kanıtlamaz.';

  @override
  String get shareTitle => 'Paylaşarak kontrol et';

  @override
  String get shareBody =>
      'iPhone’da metin paylaşımını destekleyen bir uygulamada Paylaş → Tuzak’ı seç. Ardından Tuzak’ı aç. Aktarılan metin bir kez okunur ve geçici kopyası silinir; bekleyen içerik en fazla 10 dakika geçerlidir.';

  @override
  String get sharePreviewBody =>
      'Paylaşarak metin alma özelliği iOS içindir. Bu önizlemede mesajı kopyalayıp yapıştırabilirsin.';

  @override
  String get ruleVersion => 'Kural seti';

  @override
  String get brandVersion => 'Marka listesi';

  @override
  String get usomVersion => 'USOM listesi';

  @override
  String get pending => 'Henüz eklenmedi';

  @override
  String get unavailable => 'Yüklenemedi';

  @override
  String get version => 'Sürüm 0.1.0 · Önizleme';

  @override
  String get licenses => 'Açık kaynak lisansları';

  @override
  String get localAnalysis => 'YEREL ANALİZ';

  @override
  String characterCount(int count) {
    return '$count / 10.000';
  }
}
