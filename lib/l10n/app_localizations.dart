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

  /// No description provided for @splashTagline.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı, e-postayı, linki ya da numarayı gönder; birlikte bakalım.'**
  String get splashTagline;

  /// No description provided for @startCheck.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj kontrol et'**
  String get startCheck;

  /// No description provided for @welcomeDescription.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı, e-postayı, linki ya da numarayı gönder; birlikte bakalım.'**
  String get welcomeDescription;

  /// No description provided for @featureLinks.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı kontrolü'**
  String get featureLinks;

  /// No description provided for @featureLinksBody.
  ///
  /// In tr, this message translates to:
  /// **'Sahte adresleri hemen fark et.'**
  String get featureLinksBody;

  /// No description provided for @featureMessages.
  ///
  /// In tr, this message translates to:
  /// **'Anlaşılır sonuçlar'**
  String get featureMessages;

  /// No description provided for @featureMessagesBody.
  ///
  /// In tr, this message translates to:
  /// **'Ne olduğunu ve ne yapacağını gör.'**
  String get featureMessagesBody;

  /// No description provided for @homeTip.
  ///
  /// In tr, this message translates to:
  /// **'Seni acele ettiriyorsa önce dur.'**
  String get homeTip;

  /// No description provided for @homeTipBody.
  ///
  /// In tr, this message translates to:
  /// **'Kodunu ya da şifreni kimseyle paylaşma.'**
  String get homeTipBody;

  /// No description provided for @searchHeader.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj kontrolü'**
  String get searchHeader;

  /// No description provided for @searchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şüpheyi birlikte\ninceleyelim.'**
  String get searchTitle;

  /// No description provided for @searchSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı buraya yapıştır.'**
  String get searchSubtitle;

  /// No description provided for @tagline.
  ///
  /// In tr, this message translates to:
  /// **'Tıklamadan önce,\nbir kontrol.'**
  String get tagline;

  /// No description provided for @offline.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj içeriği cihazında kalır'**
  String get offline;

  /// No description provided for @offlineWarning.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok — kontroller sınırlı olabilir.'**
  String get offlineWarning;

  /// No description provided for @messageLabel.
  ///
  /// In tr, this message translates to:
  /// **'MESAJ'**
  String get messageLabel;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'Mesajını buraya yapıştır…'**
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
  /// **'Mesajın sende kalır. Biz sadece linkleri ve numaraları kontrol ederiz.'**
  String get privacyNote;

  /// No description provided for @privacyShort.
  ///
  /// In tr, this message translates to:
  /// **'Üyelik yok, geçmiş yok.'**
  String get privacyShort;

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

  /// No description provided for @linkCleanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı temiz'**
  String get linkCleanTitle;

  /// No description provided for @numberCleanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Numara temiz'**
  String get numberCleanTitle;

  /// No description provided for @messageCleanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj temiz'**
  String get messageCleanTitle;

  /// No description provided for @suspiciousMessageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaj içime sinmedi'**
  String get suspiciousMessageTitle;

  /// No description provided for @suspiciousLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu link içime sinmedi'**
  String get suspiciousLinkTitle;

  /// No description provided for @suspiciousNumberTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu numara içime sinmedi'**
  String get suspiciousNumberTitle;

  /// No description provided for @highMessageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaja güvenme'**
  String get highMessageTitle;

  /// No description provided for @highLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu linke güvenme'**
  String get highLinkTitle;

  /// No description provided for @highNumberTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu numaraya güvenme'**
  String get highNumberTitle;

  /// No description provided for @dangerousMessageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu mesaja cevap verme'**
  String get dangerousMessageTitle;

  /// No description provided for @dangerousLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu linki açma'**
  String get dangerousLinkTitle;

  /// No description provided for @dangerousNumberTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu numarayı arama'**
  String get dangerousNumberTitle;

  /// No description provided for @whyLow.
  ///
  /// In tr, this message translates to:
  /// **'KONTROL SONUCU'**
  String get whyLow;

  /// No description provided for @whyFlagged.
  ///
  /// In tr, this message translates to:
  /// **'NEDEN ŞÜPHELİ?'**
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

  /// No description provided for @noSignalsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ters giden bir şey bulamadık'**
  String get noSignalsTitle;

  /// No description provided for @urgencyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seni acele ettirmeye çalışıyor'**
  String get urgencyTitle;

  /// No description provided for @credentialsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifre ya da kart bilgisi istiyor'**
  String get credentialsTitle;

  /// No description provided for @codeRequestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Senden doğrulama kodunu istiyor'**
  String get codeRequestTitle;

  /// No description provided for @paymentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Senden para göndermeni istiyor'**
  String get paymentTitle;

  /// No description provided for @shortLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu link nereye gittiğini gizliyor'**
  String get shortLinkTitle;

  /// No description provided for @brandTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu marka değil, sadece öyle görünüyor'**
  String get brandTitle;

  /// No description provided for @domainTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu link güvenilir görünmüyor'**
  String get domainTitle;

  /// No description provided for @lookalikeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Site adı gerçeğine çok benzetilmiş'**
  String get lookalikeTitle;

  /// No description provided for @riskyTldTitle.
  ///
  /// In tr, this message translates to:
  /// **'Link alışılmadık bir uzantı kullanıyor'**
  String get riskyTldTitle;

  /// No description provided for @ipHostTitle.
  ///
  /// In tr, this message translates to:
  /// **'Linkte site adı yerine sayı var'**
  String get ipHostTitle;

  /// No description provided for @punycodeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Linkte taklit harfler olabilir'**
  String get punycodeTitle;

  /// No description provided for @manyHyphensTitle.
  ///
  /// In tr, this message translates to:
  /// **'Link gerçek site adını gizliyor'**
  String get manyHyphensTitle;

  /// No description provided for @longSubdomainTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uzun adres gerçek siteyi gizliyor'**
  String get longSubdomainTitle;

  /// No description provided for @atSignTitle.
  ///
  /// In tr, this message translates to:
  /// **'@ işaretinden önceki ada aldanma'**
  String get atSignTitle;

  /// No description provided for @nonHttpsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu link güvenli bağlantı kullanmıyor'**
  String get nonHttpsTitle;

  /// No description provided for @deceptiveDomainTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gerçek site adı linkin içine saklanmış'**
  String get deceptiveDomainTitle;

  /// No description provided for @usomTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu link daha önce zararlı diye işaretlenmiş'**
  String get usomTitle;

  /// No description provided for @genericSignalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mesajın dili doğal görünmüyor'**
  String get genericSignalTitle;

  /// No description provided for @cargoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sahte bir kargo bildirimi olabilir'**
  String get cargoTitle;

  /// No description provided for @governmentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kurum gibi konuşuyor'**
  String get governmentTitle;

  /// No description provided for @bankCardTitle.
  ///
  /// In tr, this message translates to:
  /// **'Banka mesajı gibi görünmeye çalışıyor'**
  String get bankCardTitle;

  /// No description provided for @prizeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Olmadık bir ödül vadediyor'**
  String get prizeTitle;

  /// No description provided for @easyMoneyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kolay para vadediyor'**
  String get easyMoneyTitle;

  /// No description provided for @familyImpersonationTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tanıdığın biri gibi davranıyor'**
  String get familyImpersonationTitle;

  /// No description provided for @promotionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kampanya bahanesiyle dikkatini çekiyor'**
  String get promotionTitle;

  /// No description provided for @protectSecretsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kimseyle kod ya da şifre paylaşma'**
  String get protectSecretsTitle;

  /// No description provided for @officialAppTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şüphen varsa resmi uygulamadan bak'**
  String get officialAppTitle;

  /// No description provided for @verifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Göndereni resmi kanaldan kontrol et'**
  String get verifyTitle;

  /// No description provided for @doNotEngageMessageTitle.
  ///
  /// In tr, this message translates to:
  /// **'Cevap yazma, bilgi paylaşma'**
  String get doNotEngageMessageTitle;

  /// No description provided for @doNotEngageLinkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Linke tıklama, cevap yazma'**
  String get doNotEngageLinkTitle;

  /// No description provided for @doNotEngageNumberTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu numarayı arama, cevap yazma'**
  String get doNotEngageNumberTitle;

  /// No description provided for @contactBankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bankanı resmi numaradan ara'**
  String get contactBankTitle;

  /// No description provided for @callAction.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get callAction;

  /// No description provided for @bankCallHint.
  ///
  /// In tr, this message translates to:
  /// **'Kartının arkasındaki ya da bankanın resmi uygulamasındaki numarayı yaz.'**
  String get bankCallHint;

  /// No description provided for @bankPhoneLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bankanın resmi numarası'**
  String get bankPhoneLabel;

  /// No description provided for @openPhone.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu aç'**
  String get openPhone;

  /// No description provided for @phoneUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Telefon açılamadı. Numarayı telefon uygulamandan arayabilirsin.'**
  String get phoneUnavailable;

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
  /// **'Kontrol şu an kullanılamıyor. Uygulamayı yeniden başlatıp tekrar dene.'**
  String get analysisUnavailable;

  /// No description provided for @threatCheckComplete.
  ///
  /// In tr, this message translates to:
  /// **'Alan adları resmi kayıtlarla karşılaştırıldı.'**
  String get threatCheckComplete;

  /// No description provided for @threatCheckPartial.
  ///
  /// In tr, this message translates to:
  /// **'Bazı alan adları resmi kayıtlarla karşılaştırıldı; diğerleri yerel olarak incelendi.'**
  String get threatCheckPartial;

  /// No description provided for @threatCheckLocal.
  ///
  /// In tr, this message translates to:
  /// **'Yalnızca yerel analiz kullanıldı.'**
  String get threatCheckLocal;

  /// No description provided for @threatCheckUnavailable.
  ///
  /// In tr, this message translates to:
  /// **'Resmi kayıt kontrolü tamamlanamadı; yalnızca yerel analiz kullanıldı.'**
  String get threatCheckUnavailable;

  /// No description provided for @limitedCheckLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol yarım kaldı'**
  String get limitedCheckLabel;

  /// No description provided for @limitedCheckTitle.
  ///
  /// In tr, this message translates to:
  /// **'Linki tam kontrol edemedik'**
  String get limitedCheckTitle;

  /// No description provided for @officialThreatBankTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu adres banka dolandırıcılığı kayıtlarında var'**
  String get officialThreatBankTitle;

  /// No description provided for @officialThreatPhishingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu adres oltalama kayıtlarında var'**
  String get officialThreatPhishingTitle;

  /// No description provided for @officialThreatMalwareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu adres zararlı yazılım kayıtlarında var'**
  String get officialThreatMalwareTitle;

  /// No description provided for @officialThreatTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu adres tehdit kayıtlarında var'**
  String get officialThreatTitle;

  /// No description provided for @officialCleanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtlarda sorun görünmüyor'**
  String get officialCleanTitle;

  /// No description provided for @analysisFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kontrol tamamlanamadı. Lütfen yeniden dene.'**
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
  /// **'Tuzak, şüpheli mesajları anlamana yardımcı olur.'**
  String get infoDescription;

  /// No description provided for @privacyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Özel olan, özel kalır'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj içeriği cihazınızdan çıkmaz; yalnızca bağlantılar ve telefon numaraları güvenlik kontrolü için T.C. Siber Güvenlik Başkanlığı\'na sorgulanır. Mesaj geçmişi kaydedilmez.'**
  String get privacyBody;

  /// No description provided for @sourcesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Neler kontrol edilir?'**
  String get sourcesTitle;

  /// No description provided for @sourcesBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj cihazda incelenir. İnternet varsa bağlantılar ve telefon numaraları resmi tehdit kayıtlarında da sorgulanır. Sonuç güvenlik garantisi değildir.'**
  String get sourcesBody;

  /// No description provided for @shareTitle.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşarak kontrol et'**
  String get shareTitle;

  /// No description provided for @shareBody.
  ///
  /// In tr, this message translates to:
  /// **'iPhone’da mesajı seçip Paylaş → Tuzak yolunu izle.'**
  String get shareBody;

  /// No description provided for @sharePreviewBody.
  ///
  /// In tr, this message translates to:
  /// **'Mesajı kopyalayıp kontrol ekranına yapıştır.'**
  String get sharePreviewBody;

  /// No description provided for @licenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak lisansları'**
  String get licenses;

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
