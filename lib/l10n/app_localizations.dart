import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'Tuzak'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'Tıklamadan önce,\nbir kontrol.'**
  String get tagline;

  /// No description provided for @homeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Şüpheli mesajı yapıştır. Risk işaretlerine\nbirlikte bakalım.'**
  String get homeSubtitle;

  /// No description provided for @offline.
  ///
  /// In tr, this message translates to:
  /// **'Cihazında çalışır'**
  String get offline;

  /// No description provided for @messageLabel.
  ///
  /// In tr, this message translates to:
  /// **'KONTROL EDİLECEK MESAJ'**
  String get messageLabel;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'SMS, WhatsApp veya e-posta mesajını buraya yapıştır…'**
  String get messageHint;

  /// No description provided for @paste.
  ///
  /// In tr, this message translates to:
  /// **'Yapıştır'**
  String get paste;

  /// No description provided for @check.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol et'**
  String get check;

  /// No description provided for @checking.
  ///
  /// In tr, this message translates to:
  /// **'İnceleniyor…'**
  String get checking;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı temizle'**
  String get clear;

  /// No description provided for @privacyNote.
  ///
  /// In tr, this message translates to:
  /// **'Mesajın yalnızca senin cihazında kalır.'**
  String get privacyNote;

  /// No description provided for @privacyShort.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik yok. Mesaj geçmişi yok.'**
  String get privacyShort;

  /// No description provided for @howItWorks.
  ///
  /// In tr, this message translates to:
  /// **'NASIL ÇALIŞIR?'**
  String get howItWorks;

  /// No description provided for @stepPaste.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı yapıştır'**
  String get stepPaste;

  /// No description provided for @stepCheck.
  ///
  /// In tr, this message translates to:
  /// **'İşaretleri incele'**
  String get stepCheck;

  /// No description provided for @stepDecide.
  ///
  /// In tr, this message translates to:
  /// **'Bilinçli karar ver'**
  String get stepDecide;

  /// No description provided for @previewTitle.
  ///
  /// In tr, this message translates to:
  /// **'Önce bir göz at'**
  String get previewTitle;

  /// No description provided for @previewSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Dört farklı örnek sonucu keşfet.'**
  String get previewSubtitle;

  /// No description provided for @previewLabel.
  ///
  /// In tr, this message translates to:
  /// **'ÖRNEK SONUÇ'**
  String get previewLabel;

  /// No description provided for @previewNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu bir tasarım örneğidir; mesajın analiz edilmedi.'**
  String get previewNotice;

  /// No description provided for @previewFootnote.
  ///
  /// In tr, this message translates to:
  /// **'Önizleme sürümü · Gerçek analiz için kural seti bekleniyor.'**
  String get previewFootnote;

  /// No description provided for @analysis.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj analizi'**
  String get analysis;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @lowLabel.
  ///
  /// In tr, this message translates to:
  /// **'Düşük risk'**
  String get lowLabel;

  /// No description provided for @suspiciousLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şüpheli'**
  String get suspiciousLabel;

  /// No description provided for @highLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek risk'**
  String get highLabel;

  /// No description provided for @dangerousLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tehlikeli'**
  String get dangerousLabel;

  /// No description provided for @lowTitle.
  ///
  /// In tr, this message translates to:
  /// **'Belirgin risk\nbulunamadı.'**
  String get lowTitle;

  /// No description provided for @suspiciousTitle.
  ///
  /// In tr, this message translates to:
  /// **'Biraz temkinli\nolmakta fayda var.'**
  String get suspiciousTitle;

  /// No description provided for @highTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu mesajda\nrisk işaretleri var.'**
  String get highTitle;

  /// No description provided for @dangerousTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu bağlantıdan\nuzak dur.'**
  String get dangerousTitle;

  /// No description provided for @lowDescription.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol edilen yerel kurallar belirgin bir risk işareti bulmadı. Bu, güvenlik garantisi değildir.'**
  String get lowDescription;

  /// No description provided for @suspiciousDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bazı ifadeler veya bağlantılar dikkat gerektiriyor. İşlem yapmadan önce resmi kanaldan doğrula.'**
  String get suspiciousDescription;

  /// No description provided for @highDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj dolandırıcılık girişimiyle ilişkili işaretler taşıyor. Acele etmeden bir adım geri çekil.'**
  String get highDescription;

  /// No description provided for @dangerousDescription.
  ///
  /// In tr, this message translates to:
  /// **'Mesajdaki bir alan adı cihazdaki zararlı alan adı listesiyle eşleşiyor. Bağlantıyı açma.'**
  String get dangerousDescription;

  /// No description provided for @whyLow.
  ///
  /// In tr, this message translates to:
  /// **'NELERE BAKTIK?'**
  String get whyLow;

  /// No description provided for @whyFlagged.
  ///
  /// In tr, this message translates to:
  /// **'NEDEN DİKKAT ETMELİSİN?'**
  String get whyFlagged;

  /// No description provided for @recommendedActions.
  ///
  /// In tr, this message translates to:
  /// **'ŞİMDİ NE YAPMALI?'**
  String get recommendedActions;

  /// No description provided for @scanAnother.
  ///
  /// In tr, this message translates to:
  /// **'Başka mesaj kontrol et'**
  String get scanAnother;

  /// No description provided for @resultDisclaimer.
  ///
  /// In tr, this message translates to:
  /// **'Tuzak bir yardımcıdır; gönderenin kimliğini doğrulamaz.'**
  String get resultDisclaimer;

  /// No description provided for @noSignalsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Belirgin bir kural eşleşmesi yok'**
  String get noSignalsTitle;

  /// No description provided for @noSignalsBody.
  ///
  /// In tr, this message translates to:
  /// **'İncelenen metinde etkin kurallarla eşleşen bir risk işareti bulunamadı.'**
  String get noSignalsBody;

  /// No description provided for @urgencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acele ettiren ifadeler'**
  String get urgencyTitle;

  /// No description provided for @urgencyBody.
  ///
  /// In tr, this message translates to:
  /// **'Hemen işlem yapmanı isteyen dil, düşünmeden karar vermene yol açabilir.'**
  String get urgencyBody;

  /// No description provided for @credentialsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre veya kod talebi'**
  String get credentialsTitle;

  /// No description provided for @credentialsBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj, özel erişim bilgilerini ya da tek kullanımlık kodunu paylaşmanı istiyor.'**
  String get credentialsBody;

  /// No description provided for @paymentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ödeme talebi'**
  String get paymentTitle;

  /// No description provided for @paymentBody.
  ///
  /// In tr, this message translates to:
  /// **'İşlem yapmadan önce ödeme isteğini bağımsız bir resmi kanaldan doğrula.'**
  String get paymentBody;

  /// No description provided for @shortLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi gizleyen bağlantı'**
  String get shortLinkTitle;

  /// No description provided for @shortLinkBody.
  ///
  /// In tr, this message translates to:
  /// **'Kısaltılmış bağlantının son adresi çevrimdışı doğrulanamaz.'**
  String get shortLinkBody;

  /// No description provided for @brandTitle.
  ///
  /// In tr, this message translates to:
  /// **'Markayla uyuşmayan alan adı'**
  String get brandTitle;

  /// No description provided for @brandBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesajdaki marka adıyla bağlantının alan adı, yerel resmi adres listesinde uyuşmuyor.'**
  String get brandBody;

  /// No description provided for @domainTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şüpheli alan adı'**
  String get domainTitle;

  /// No description provided for @domainBody.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı, kural setinde tanımlanan bir alan adı risk işareti taşıyor.'**
  String get domainBody;

  /// No description provided for @usomTitle.
  ///
  /// In tr, this message translates to:
  /// **'Zararlı alan adı eşleşmesi'**
  String get usomTitle;

  /// No description provided for @usomBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir alan adı, cihazda bulunan USOM veri kümesiyle eşleşti.'**
  String get usomBody;

  /// No description provided for @genericSignalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Dikkat gerektiren ifade'**
  String get genericSignalTitle;

  /// No description provided for @genericSignalBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj, yerel kural setinde tanımlanan bir risk örüntüsüyle eşleşiyor.'**
  String get genericSignalBody;

  /// No description provided for @protectSecretsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kodların ve şifrelerin sende kalsın'**
  String get protectSecretsTitle;

  /// No description provided for @protectSecretsBody.
  ///
  /// In tr, this message translates to:
  /// **'Tek kullanımlık SMS kodunu, kart şifreni veya hesap parolanı kimseyle paylaşma.'**
  String get protectSecretsBody;

  /// No description provided for @officialAppTitle.
  ///
  /// In tr, this message translates to:
  /// **'Resmi uygulamadan kontrol et'**
  String get officialAppTitle;

  /// No description provided for @officialAppBody.
  ///
  /// In tr, this message translates to:
  /// **'Şüphen varsa bağlantıya dokunmak yerine kurumun uygulamasını kendin aç.'**
  String get officialAppBody;

  /// No description provided for @verifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Göndereni bağımsız olarak doğrula'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesajdaki numarayı kullanmadan, kurumun bilinen resmi iletişim kanalından teyit al.'**
  String get verifyBody;

  /// No description provided for @doNotTapTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantıyı açma, yanıt verme'**
  String get doNotTapTitle;

  /// No description provided for @doNotTapBody.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel bilgi paylaşma ve mesaj üzerinden ödeme yapma.'**
  String get doNotTapBody;

  /// No description provided for @deleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı sil veya engelle'**
  String get deleteTitle;

  /// No description provided for @deleteBody.
  ///
  /// In tr, this message translates to:
  /// **'Gerekli bir bildirim için kanıtı sakladıktan sonra mesajı kaldırabilirsin.'**
  String get deleteBody;

  /// No description provided for @contactBankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bilgi paylaştıysan bankana ulaş'**
  String get contactBankTitle;

  /// No description provided for @contactBankBody.
  ///
  /// In tr, this message translates to:
  /// **'Kartının arkasındaki numarayı veya bankanın resmi uygulamasını kullan.'**
  String get contactBankBody;

  /// No description provided for @emergencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Acil tehlikede 112'**
  String get emergencyTitle;

  /// No description provided for @emergencyBody.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca acil yardım gerektiren bir durum varsa ara.'**
  String get emergencyBody;

  /// No description provided for @call.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get call;

  /// No description provided for @callConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Telefon uygulaması açılsın mı?'**
  String get callConfirmTitle;

  /// No description provided for @callConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'112 yalnızca acil durumlar içindir. Arama telefon uygulamasında devam eder.'**
  String get callConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @callUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Telefon uygulaması açılamadı. Acil durumda telefonundan 112’yi arayabilirsin.'**
  String get callUnavailable;

  /// No description provided for @clipboardEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Panoda yapıştırılabilecek bir metin yok.'**
  String get clipboardEmpty;

  /// No description provided for @clipboardUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Panoya erişilemedi. Mesajı metin alanına elle yapıştırabilirsin.'**
  String get clipboardUnavailable;

  /// No description provided for @analysisUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Analiz henüz hazır değil. Doğrulanmış kural seti bu sürüme eklenmedi. Aşağıdan örnek sonuçları inceleyebilirsin.'**
  String get analysisUnavailable;

  /// No description provided for @analysisFailed.
  ///
  /// In tr, this message translates to:
  /// **'Analiz tamamlanamadı. Mesaj için bir risk sonucu üretilmedi. Lütfen yeniden dene.'**
  String get analysisFailed;

  /// No description provided for @inputTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Tek seferde en fazla 10.000 karakter kontrol edebilirsin.'**
  String get inputTooLong;

  /// No description provided for @sharedMessageLoaded.
  ///
  /// In tr, this message translates to:
  /// **'Paylaştığın mesaj hazır. Kontrol et’e dokunabilirsin.'**
  String get sharedMessageLoaded;

  /// No description provided for @shareUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılan mesaj alınamadı. Mesajı kopyalayıp yapıştırabilirsin.'**
  String get shareUnavailable;

  /// No description provided for @infoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tuzak hakkında'**
  String get infoTitle;

  /// No description provided for @infoIntro.
  ///
  /// In tr, this message translates to:
  /// **'Bir an durmak,\nfark yaratabilir.'**
  String get infoIntro;

  /// No description provided for @infoDescription.
  ///
  /// In tr, this message translates to:
  /// **'Tuzak, mesajlardaki dolandırıcılık işaretlerini anlamana yardımcı olmak için tasarlandı.'**
  String get infoDescription;

  /// No description provided for @privacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel olan, özel kalır'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar sunucuya gönderilmez. Hesap, analiz geçmişi, reklam veya analitik takibi yoktur. İşlem bitince mesaj bellekte tutulmaz.'**
  String get privacyBody;

  /// No description provided for @sourcesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yerel kurallar, açık sınırlar'**
  String get sourcesTitle;

  /// No description provided for @sourcesBody.
  ///
  /// In tr, this message translates to:
  /// **'Analiz; metin kuralları, resmi marka adresleri ve yerel zararlı alan adı listesiyle çalışacak. Kaynaklar eklenmeden gerçek analiz etkinleştirilmez. Liste eşleşmesi bulunmaması bir adresin güvenli olduğunu kanıtlamaz.'**
  String get sourcesBody;

  /// No description provided for @shareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşarak kontrol et'**
  String get shareTitle;

  /// No description provided for @shareBody.
  ///
  /// In tr, this message translates to:
  /// **'iPhone’da metin paylaşımını destekleyen bir uygulamada Paylaş → Tuzak’ı seç. Ardından Tuzak’ı aç. Aktarılan metin bir kez okunur ve geçici kopyası silinir; bekleyen içerik en fazla 10 dakika geçerlidir.'**
  String get shareBody;

  /// No description provided for @sharePreviewBody.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşarak metin alma özelliği iOS içindir. Bu önizlemede mesajı kopyalayıp yapıştırabilirsin.'**
  String get sharePreviewBody;

  /// No description provided for @ruleVersion.
  ///
  /// In tr, this message translates to:
  /// **'Kural seti'**
  String get ruleVersion;

  /// No description provided for @brandVersion.
  ///
  /// In tr, this message translates to:
  /// **'Marka listesi'**
  String get brandVersion;

  /// No description provided for @usomVersion.
  ///
  /// In tr, this message translates to:
  /// **'USOM listesi'**
  String get usomVersion;

  /// No description provided for @pending.
  ///
  /// In tr, this message translates to:
  /// **'Henüz eklenmedi'**
  String get pending;

  /// No description provided for @unavailable.
  ///
  /// In tr, this message translates to:
  /// **'Yüklenemedi'**
  String get unavailable;

  /// No description provided for @version.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm 0.1.0 · Önizleme'**
  String get version;

  /// No description provided for @licenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak lisansları'**
  String get licenses;

  /// No description provided for @localAnalysis.
  ///
  /// In tr, this message translates to:
  /// **'YEREL ANALİZ'**
  String get localAnalysis;

  /// No description provided for @characterCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} / 10.000'**
  String characterCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
