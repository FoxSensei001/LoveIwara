///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsDe extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsDe({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsDe _root = this; // ignore: unused_field

	@override 
	TranslationsDe $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsDe(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileDe personalProfile = _TranslationsPersonalProfileDe._(_root);
	@override late final _TranslationsTutorialDe tutorial = _TranslationsTutorialDe._(_root);
	@override late final _TranslationsCommonDe common = _TranslationsCommonDe._(_root);
	@override late final _TranslationsAuthDe auth = _TranslationsAuthDe._(_root);
	@override late final _TranslationsErrorsDe errors = _TranslationsErrorsDe._(_root);
	@override late final _TranslationsFriendsDe friends = _TranslationsFriendsDe._(_root);
	@override late final _TranslationsAuthorProfileDe authorProfile = _TranslationsAuthorProfileDe._(_root);
	@override late final _TranslationsFavoritesDe favorites = _TranslationsFavoritesDe._(_root);
	@override late final _TranslationsGalleryDetailDe galleryDetail = _TranslationsGalleryDetailDe._(_root);
	@override late final _TranslationsPlayListDe playList = _TranslationsPlayListDe._(_root);
	@override late final _TranslationsSearchDe search = _TranslationsSearchDe._(_root);
	@override late final _TranslationsMediaListDe mediaList = _TranslationsMediaListDe._(_root);
	@override late final _TranslationsSettingsDe settings = _TranslationsSettingsDe._(_root);
	@override late final _TranslationsFavoriteTagsDe favoriteTags = _TranslationsFavoriteTagsDe._(_root);
	@override late final _TranslationsOreno3dDe oreno3d = _TranslationsOreno3dDe._(_root);
	@override late final _TranslationsSignInDe signIn = _TranslationsSignInDe._(_root);
	@override late final _TranslationsSubscriptionsDe subscriptions = _TranslationsSubscriptionsDe._(_root);
	@override late final _TranslationsVideoDetailDe videoDetail = _TranslationsVideoDetailDe._(_root);
	@override late final _TranslationsShareDe share = _TranslationsShareDe._(_root);
	@override late final _TranslationsMarkdownDe markdown = _TranslationsMarkdownDe._(_root);
	@override late final _TranslationsForumDe forum = _TranslationsForumDe._(_root);
	@override late final _TranslationsNotificationsDe notifications = _TranslationsNotificationsDe._(_root);
	@override late final _TranslationsConversationDe conversation = _TranslationsConversationDe._(_root);
	@override late final _TranslationsSplashDe splash = _TranslationsSplashDe._(_root);
	@override late final _TranslationsDownloadDe download = _TranslationsDownloadDe._(_root);
	@override late final _TranslationsDownloadNotificationsDe downloadNotifications = _TranslationsDownloadNotificationsDe._(_root);
	@override late final _TranslationsFavoriteDe favorite = _TranslationsFavoriteDe._(_root);
	@override late final _TranslationsTranslationDe translation = _TranslationsTranslationDe._(_root);
	@override late final _TranslationsBottomNavDe bottomNav = _TranslationsBottomNavDe._(_root);
	@override late final _TranslationsNavigationOrderSettingsDe navigationOrderSettings = _TranslationsNavigationOrderSettingsDe._(_root);
	@override late final _TranslationsNewsDe news = _TranslationsNewsDe._(_root);
	@override late final _TranslationsDisplaySettingsDe displaySettings = _TranslationsDisplaySettingsDe._(_root);
	@override late final _TranslationsLayoutSettingsDe layoutSettings = _TranslationsLayoutSettingsDe._(_root);
	@override late final _TranslationsMediaPlayerDe mediaPlayer = _TranslationsMediaPlayerDe._(_root);
	@override late final _TranslationsDiagnosticsDe diagnostics = _TranslationsDiagnosticsDe._(_root);
	@override late final _TranslationsLogViewerDe logViewer = _TranslationsLogViewerDe._(_root);
	@override late final _TranslationsCrashRecoveryDialogDe crashRecoveryDialog = _TranslationsCrashRecoveryDialogDe._(_root);
	@override late final _TranslationsLinkInputDialogDe linkInputDialog = _TranslationsLinkInputDialogDe._(_root);
	@override late final _TranslationsLogDe log = _TranslationsLogDe._(_root);
	@override late final _TranslationsEmojiDe emoji = _TranslationsEmojiDe._(_root);
	@override late final _TranslationsSearchFilterDe searchFilter = _TranslationsSearchFilterDe._(_root);
	@override late final _TranslationsFirstTimeSetupDe firstTimeSetup = _TranslationsFirstTimeSetupDe._(_root);
	@override late final _TranslationsProxyHelperDe proxyHelper = _TranslationsProxyHelperDe._(_root);
	@override late final _TranslationsTagSelectorDe tagSelector = _TranslationsTagSelectorDe._(_root);
	@override late final _TranslationsAnime4kDe anime4k = _TranslationsAnime4kDe._(_root);
	@override late final _TranslationsSiteModeDe siteMode = _TranslationsSiteModeDe._(_root);
	@override late final _TranslationsSavedSearchConfigDe savedSearchConfig = _TranslationsSavedSearchConfigDe._(_root);
	@override late final _TranslationsSavedSearchDe savedSearch = _TranslationsSavedSearchDe._(_root);
	@override late final _TranslationsDefaultBlacklistReminderDe defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderDe._(_root);
	@override late final _TranslationsColorVisionAssistDe colorVisionAssist = _TranslationsColorVisionAssistDe._(_root);
	@override late final _TranslationsExternalPlayerDe externalPlayer = _TranslationsExternalPlayerDe._(_root);
	@override late final _TranslationsWatchLaterDe watchLater = _TranslationsWatchLaterDe._(_root);
	@override late final _TranslationsMediaMenuDe mediaMenu = _TranslationsMediaMenuDe._(_root);
	@override late final _TranslationsMediaPreviewDe mediaPreview = _TranslationsMediaPreviewDe._(_root);
	@override late final _TranslationsPlaybackQueueDe playbackQueue = _TranslationsPlaybackQueueDe._(_root);
	@override late final _TranslationsVrFormatDe vrFormat = _TranslationsVrFormatDe._(_root);
	@override late final _TranslationsLocalMediaDe localMedia = _TranslationsLocalMediaDe._(_root);
	@override late final _TranslationsHistoryPageDe historyPage = _TranslationsHistoryPageDe._(_root);
	@override late final _TranslationsAiDe ai = _TranslationsAiDe._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileDe extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Persönliches Profil';
	@override String get editPersonalProfile => 'Persönliches Profil bearbeiten';
	@override String get avatar => 'Avatar';
	@override String get background => 'Hintergrund';
	@override String fetchUserProfileFailed({required Object error}) => 'Benutzerprofil konnte nicht abgerufen werden: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Empfohlene Auflösung: ${resolution}, Dateigröße < ${size}';
	@override String supportedFormats({required Object formats}) => 'Unterstützte Formate: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Premium-Nutzer können dynamische ${type} verwenden (${formats})';
	@override String get homepageBackground => 'Startseiten-Hintergrund';
	@override String get basicInfo => 'Grundlegende Informationen';
	@override String get nickname => 'Spitzname';
	@override String get username => 'Benutzername';
	@override String get copyUsername => 'Benutzernamen kopieren';
	@override String get usernameCopied => 'Benutzername kopiert';
	@override String get personalIntroduction => 'Persönliche Vorstellung';
	@override String get noPersonalIntroduction => 'Keine persönliche Vorstellung';
	@override String get clickToEdit => 'Zum Bearbeiten tippen';
	@override String get privacySettings => 'Datenschutzeinstellungen';
	@override String get hideSensitiveContent => 'Sensible Inhalte ausblenden';
	@override String get hideSensitiveContentDesc => 'Blendet alle Videos oder Bilder mit sensiblen Tags aus.';
	@override String get notificationSettings => 'Benachrichtigungseinstellungen';
	@override String get contentCommentNotification => 'Benachrichtigung bei Inhaltskommentaren';
	@override String get contentCommentNotificationDesc => 'Benachrichtigen, wenn jemand Ihre Inhalte kommentiert.';
	@override String get commentReplyNotification => 'Benachrichtigung bei Kommentarantworten';
	@override String get commentReplyNotificationDesc => 'Benachrichtigen, wenn jemand auf Ihren Kommentar antwortet.';
	@override String get mentionNotification => 'Benachrichtigung bei Erwähnungen';
	@override String get mentionNotificationDesc => 'Benachrichtigen, wenn jemand Sie in Inhalten erwähnt.';
	@override String get accountInfo => 'Kontoinformationen';
	@override String get registrationTime => 'Registrierungszeitpunkt';
	@override String updateSettingsFailed({required Object error}) => 'Einstellungen konnten nicht aktualisiert werden: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'Benachrichtigungseinstellungen konnten nicht aktualisiert werden: ${error}';
	@override String get editNickname => 'Spitznamen bearbeiten';
	@override String get nicknameCannotBeEmpty => 'Spitzname darf nicht leer sein';
	@override String get changeSuccess => 'Erfolgreich geändert';
	@override String get unsupportedFileFormat => 'Nicht unterstütztes Dateiformat';
	@override String fileTooLarge({required Object size}) => 'Dateigröße darf ${size} nicht überschreiten';
	@override String get uploadFailed => 'Upload fehlgeschlagen';
	@override String get avatarUpdatedSuccessfully => 'Avatar erfolgreich aktualisiert';
	@override String updateAvatarFailed({required Object error}) => 'Avatar konnte nicht aktualisiert werden: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Hintergrund erfolgreich aktualisiert';
	@override String updateBackgroundFailed({required Object error}) => 'Hintergrund konnte nicht aktualisiert werden: ${error}';
	@override String get editPersonalIntroduction => 'Persönliche Vorstellung bearbeiten';
	@override String get enterPersonalIntroduction => 'Bitte geben Sie Ihre persönliche Vorstellung ein';
}

// Path: tutorial
class _TranslationsTutorialDe extends TranslationsTutorialEn {
	_TranslationsTutorialDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Spezielles Folgen';
	@override String get specialFollowDescription => 'Markieren Sie die Autoren, die Sie am meisten verfolgen, als „Spezielles Folgen“ und springen Sie dann von hier direkt zu deren neuesten Uploads.';
	@override String get stepsTitle => 'Drei Schritte';
	@override String get stepFollowAuthor => 'Tippen Sie auf „Folgen“ auf der Video-, Galerie- oder Profilseite des Autors.';
	@override String get stepPickSpecial => 'Tippen Sie erneut auf „Gefolgt“ und wählen Sie dann im Menü „Spezielles Folgen“.';
	@override String get stepSwitchHere => 'Kommen Sie hierher zurück und wechseln Sie mit der Avatar-Auswahl oben zu diesem Autor.';
	@override String get specialFollowManagementTip => 'Verwalten Sie die Liste „Spezielles Folgen“ unter Seitenleiste – Folge-Liste – Spezielles Folgen.';
	@override String get gotIt => 'Verstanden';
}

// Path: common
class _TranslationsCommonDe extends TranslationsCommonEn {
	_TranslationsCommonDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Sortieren';
	@override String get filter => 'Filter';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'OK';
	@override String get cancel => 'Abbrechen';
	@override String get select => 'Auswählen';
	@override String get save => 'Speichern';
	@override String get delete => 'Löschen';
	@override String get visit => 'Besuchen';
	@override String get loading => 'Wird geladen…';
	@override String get scrollToTop => 'Nach oben scrollen';
	@override String get privacyHint => 'Datenschutzmodus ist aktiv, Inhalte sind ausgeblendet';
	@override String get latest => 'Neueste';
	@override String get likesCount => 'Likes';
	@override String get viewsCount => 'Aufrufe';
	@override String get popular => 'Beliebt';
	@override String get trending => 'Im Trend';
	@override String get commentList => 'Kommentarliste';
	@override String get sendComment => 'Kommentar senden';
	@override String get send => 'Senden';
	@override String get retry => 'Erneut versuchen';
	@override String get premium => 'Premium';
	@override String get follower => 'Follower';
	@override String get friend => 'Freund';
	@override String get video => 'Video';
	@override String get following => 'Folge ich';
	@override String get expand => 'Erweitern';
	@override String get collapse => 'Einklappen';
	@override String get cancelFriendRequest => 'Anfrage abbrechen';
	@override String get cancelSpecialFollow => 'Spezial-Follow aufheben';
	@override String get addFriend => 'Freund hinzufügen';
	@override String get removeFriend => 'Freund entfernen';
	@override String get followed => 'Gefolgt';
	@override String get follow => 'Folgen';
	@override String get unfollow => 'Nicht mehr folgen';
	@override String get specialFollow => 'Spezial-Follow';
	@override String get specialFollowed => 'Spezial-Follow aktiv';
	@override String get gallery => 'Galerie';
	@override String get playlist => 'Playlist';
	@override String get commentPostedSuccessfully => 'Kommentar erfolgreich gesendet';
	@override String get commentPostedFailed => 'Kommentar konnte nicht gesendet werden';
	@override String get success => 'Erfolg';
	@override String get commentDeletedSuccessfully => 'Kommentar erfolgreich gelöscht';
	@override String get commentUpdatedSuccessfully => 'Kommentar erfolgreich aktualisiert';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} Kommentar',
		other: '${n} Kommentare',
	);
	@override String get writeYourCommentHere => 'Schreiben Sie hier Ihren Kommentar…';
	@override String get tmpNoReplies => 'Noch keine Antworten';
	@override String get loadMore => 'Mehr laden';
	@override String get loadingMore => 'Weitere werden geladen…';
	@override String get noMoreDatas => 'Keine weiteren Daten';
	@override String get selectTranslationLanguage => 'Übersetzungssprache auswählen';
	@override String get translate => 'Übersetzen';
	@override String get translateFailedPleaseTryAgainLater => 'Übersetzung fehlgeschlagen, bitte später erneut versuchen';
	@override String get translationResult => 'Übersetzungsergebnis';
	@override String get justNow => 'Gerade eben';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: 'vor ${n} Minute',
		other: 'vor ${n} Minuten',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: 'vor ${n} Stunde',
		other: 'vor ${n} Stunden',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: 'vor ${n} Tag',
		other: 'vor ${n} Tagen',
	);
	@override String editedAt({required Object num}) => '${num} bearbeitet';
	@override String get editComment => 'Kommentar bearbeiten';
	@override String get commentUpdated => 'Kommentar aktualisiert';
	@override String get replyComment => 'Auf Kommentar antworten';
	@override String get reply => 'Antworten';
	@override String get edit => 'Bearbeiten';
	@override String get unknownUser => 'Unbekannter Benutzer';
	@override String get me => 'Ich';
	@override String get author => 'Autor';
	@override String get admin => 'Admin';
	@override String viewReplies({required Object num}) => 'Antworten ansehen (${num})';
	@override String get hideReplies => 'Antworten ausblenden';
	@override String get confirmDelete => 'Löschen bestätigen';
	@override String get areYouSureYouWantToDeleteThisItem => 'Möchten Sie dieses Element wirklich löschen?';
	@override String get tmpNoComments => 'Noch keine Kommentare';
	@override String get refresh => 'Aktualisieren';
	@override String get back => 'Zurück';
	@override String get tips => 'Tipps';
	@override String get linkIsEmpty => 'Link ist leer';
	@override String get linkCopiedToClipboard => 'Link in die Zwischenablage kopiert';
	@override String get imageCopiedToClipboard => 'Bild in die Zwischenablage kopiert';
	@override String get copyImageFailed => 'Kopieren des Bildes fehlgeschlagen';
	@override String get mobileSaveImageIsUnderDevelopment => 'Das Speichern von Bildern ist auf Mobilgeräten noch in Entwicklung';
	@override String get imageSavedTo => 'Bild gespeichert unter';
	@override String get saveImageFailed => 'Bild konnte nicht gespeichert werden';
	@override String get close => 'Schließen';
	@override String get more => 'Mehr';
	@override String get unknownError => 'Unbekannter Fehler';
	@override String get moreFeaturesToBeDeveloped => 'Weitere Funktionen werden noch entwickelt';
	@override String get all => 'Alle';
	@override String selectedRecords({required Object num}) => '${num} Einträge ausgewählt';
	@override String get cancelSelectAll => 'Alle abwählen';
	@override String get selectAll => 'Alle auswählen';
	@override String get invertSelection => 'Auswahl umkehren';
	@override String get exitEditMode => 'Bearbeitungsmodus beenden';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Möchten Sie die ausgewählten ${num} Elemente wirklich löschen?';
	@override String get searchHistoryRecords => 'Verlaufseinträge durchsuchen…';
	@override String get settings => 'Einstellungen';
	@override String get subscriptions => 'Abos';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} Video',
		other: '${n} Videos',
	);
	@override String get share => 'Teilen';
	@override String get areYouSureYouWantToShareThisPlaylist => 'Möchten Sie diese Wiedergabeliste wirklich teilen?';
	@override String get editTitle => 'Titel bearbeiten';
	@override String get editMode => 'Bearbeitungsmodus';
	@override String get pleaseEnterNewTitle => 'Bitte neuen Titel eingeben';
	@override String get createPlayList => 'Wiedergabeliste erstellen';
	@override String get create => 'Erstellen';
	@override String get checkNetworkSettings => 'Netzwerkeinstellungen prüfen';
	@override String get general => 'Allgemein';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Sensibel';
	@override String get year => 'Jahr';
	@override String get month => 'Monat';
	@override String get tag => 'Tag';
	@override String get private => 'Privat';
	@override String get noTitle => 'Kein Titel';
	@override String get search => 'Suchen';
	@override String get noContent => 'Kein Inhalt';
	@override String get recording => 'Aufzeichnung';
	@override String get paused => 'Pausiert';
	@override String get clear => 'Leeren';
	@override String get clearSelection => 'Auswahl aufheben';
	@override String get selectItemsToContinue => 'Elemente auswählen, um fortzufahren';
	@override String andMoreItems({required Object num}) => 'und ${num} weitere';
	@override String get batchDelete => 'Stapellöschung';
	@override String get user => 'Benutzer';
	@override String get post => 'Beitrag';
	@override String get seconds => 'Sekunden';
	@override String get comingSoon => 'Demnächst';
	@override String get confirm => 'Bestätigen';
	@override String get hour => 'Stunde';
	@override String get minute => 'Minute';
	@override String get clickToRefresh => 'Zum Aktualisieren tippen';
	@override String get history => 'Verlauf';
	@override String get favorites => 'Favoriten';
	@override String get friends => 'Freunde';
	@override String get playList => 'Wiedergabeliste';
	@override String get checkLicense => 'Lizenz prüfen';
	@override String get logout => 'Abmelden';
	@override String get fensi => 'Fans';
	@override String get accept => 'Annehmen';
	@override String get reject => 'Ablehnen';
	@override String get clearAllHistory => 'Gesamten Verlauf löschen';
	@override String get clearAllHistoryConfirm => 'Möchten Sie den gesamten Verlauf wirklich löschen?';
	@override String get followingList => 'Liste meiner Follows';
	@override String get followersList => 'Follower-Liste';
	@override String get follows => 'Folgt';
	@override String get fans => 'Fans';
	@override String get followsAndFans => 'Gefolgt und Fans';
	@override String get numViews => 'Aufrufe';
	@override String get updatedAt => 'Aktualisiert am';
	@override String get publishedAt => 'Veröffentlicht am';
	@override String get externalVideo => 'Externes Video';
	@override String get originalText => 'Originaltext';
	@override String get showOriginalText => 'Originaltext anzeigen';
	@override String get showProcessedText => 'Verarbeiteten Text anzeigen';
	@override String get preview => 'Vorschau';
	@override String get rules => 'Regeln';
	@override String get agree => 'Zustimmen';
	@override String get disagree => 'Ablehnen';
	@override String get agreeToRules => 'Den Regeln zustimmen';
	@override String get tapToReread => 'Zum erneuten Lesen tippen';
	@override String get markdownSyntaxHelp => 'Markdown-Syntax-Hilfe';
	@override String get previewContent => 'Inhalt vorschauen';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Maximale Länge überschritten (${max})';
	@override String get agreeToCommunityRules => 'Den Community-Regeln zustimmen';
	@override String get createPost => 'Beitrag erstellen';
	@override String get title => 'Titel';
	@override String get enterTitle => 'Bitte Titel eingeben';
	@override String get content => 'Inhalt';
	@override String get enterContent => 'Bitte Inhalt eingeben';
	@override String get writeYourContentHere => 'Bitte Inhalt eingeben…';
	@override String get tagBlacklist => 'Tag-Sperrliste';
	@override String get noData => 'Keine Daten';
	@override String get tagLimit => 'Tag-Limit';
	@override String get enableFloatingButtons => 'Schwebende Schaltflächen aktivieren';
	@override String get disableFloatingButtons => 'Schwebende Schaltflächen deaktivieren';
	@override String get enabledFloatingButtons => 'Schwebende Schaltflächen aktiviert';
	@override String get disabledFloatingButtons => 'Schwebende Schaltflächen deaktiviert';
	@override String get pendingCommentCount => 'Ausstehende Kommentare';
	@override String joined({required Object str}) => 'Beigetreten am ${str}';
	@override String lastSeenAt({required Object str}) => 'Zuletzt gesehen ${str}';
	@override String get download => 'Herunterladen';
	@override String get selectQuality => 'Qualität auswählen';
	@override String get videoQualitySource => 'Quelle';
	@override String get selectImageQuality => 'Bildqualität auswählen';
	@override String get imageQualityStandard => 'Standard';
	@override String get imageQualityOriginal => 'Original';
	@override String get selectDateRange => 'Datumsbereich auswählen';
	@override String get selectDateRangeHint => 'Datumsbereich auswählen, Standard sind die letzten 30 Tage';
	@override String get clearDateRange => 'Datumsbereich löschen';
	@override String get deleteRecordsInDateRange => 'Einträge in diesem Bereich löschen';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'Möchten Sie ${num} Verlaufseinträge in diesem Datumsbereich wirklich löschen? Dies kann nicht rückgängig gemacht werden.';
	@override String get noHistoryRecordsInRange => 'Keine Verlaufseinträge in diesem Datumsbereich';
	@override String get followSuccessClickAgainToSpecialFollow => 'Erfolgreich gefolgt, erneut tippen für Spezial-Follow';
	@override String get specialFollowTip => 'Zu den Spezial-Follows hinzugefügt – wählen Sie sie über die Auswahl oben rechts auf der Abo-Seite für den Schnellzugriff';
	@override String get exitConfirmTip => 'Möchten Sie wirklich beenden?';
	@override String get error => 'Fehler';
	@override String get taskRunning => 'Es läuft bereits eine Aufgabe, bitte warten.';
	@override String get operationCancelled => 'Vorgang abgebrochen.';
	@override String get unsavedChanges => 'Sie haben ungespeicherte Änderungen';
	@override String get specialFollowsManagementTip => 'Zum Umsortieren am Griff ziehen • Zum Entfernen auf die Schaltfläche tippen';
	@override String get specialFollowsManagement => 'Spezial-Follows verwalten';
	@override String get removeSpecialFollow => 'Spezial-Follow entfernen';
	@override String removeSpecialFollowConfirm({required Object name}) => '${name} aus den Spezial-Follows entfernen?';
	@override String get noSpecialFollows => 'Noch keine Spezial-Follows';
	@override String get createTimeDesc => 'Erstellzeit absteigend';
	@override String get createTimeAsc => 'Erstellzeit aufsteigend';
	@override late final _TranslationsCommonPaginationDe pagination = _TranslationsCommonPaginationDe._(_root);
	@override String get notice => 'Hinweis';
	@override String get detail => 'Details';
	@override String get parseExceptionDestopHint => ' – Desktop-Benutzer können den Proxy in den Einstellungen konfigurieren';
	@override String get iwaraTags => 'Iwara-Tags';
	@override String get tagInfo => 'Tag-Info';
	@override String get tagOriginalKey => 'Original-Tag';
	@override String get tagTranslation => 'Übersetzung';
	@override String get copy => 'Kopieren';
	@override String get selectCopy => 'Auswählen & kopieren';
	@override String get copiedToClipboard => 'In die Zwischenablage kopiert';
	@override String get showOriginalTag => 'Original-Tag anzeigen';
	@override String get showTranslatedTag => 'Übersetzung anzeigen';
	@override String get tagTranslationFeedback => 'Zweifel an einer Übersetzung? Geben Sie Feedback';
	@override String get tagLocalizationGuideTitle => 'Über die Tag-Lokalisierung';
	@override String get tagLocalizationGuideContent => 'Die App zeigt die Original-Tags von Iwara (z. B. mother) mit dem Namen in Ihrer aktuellen Sprache an.\n\n• Bei der Tag-Suche stimmen sowohl die Übersetzung als auch das Original-Tag überein.\n• Halten Sie ein Tag gedrückt bzw. klicken Sie mit der rechten Maustaste darauf, um den Originalschlüssel und die Übersetzung anzuzeigen und zu kopieren.\n• Die Übersetzungen werden von der Community gepflegt und nach bestem Wissen erstellt – sie können Fehler enthalten.';
	@override String get likeThisVideo => 'Dieses Video liken';
	@override String get likeThisGallery => 'Diese Galerie liken';
	@override String get operation => 'Aktion';
	@override String get replies => 'Antworten';
	@override String get externalLinkWarning => 'Warnung vor externem Link';
	@override String get externalLinkWarningMessage => 'Sie sind dabei, einen externen Link zu öffnen, der nicht zu iwara.tv gehört. Bitte seien Sie vorsichtig und stellen Sie sicher, dass der Link sicher ist, bevor Sie fortfahren.';
	@override String get continueToExternalLink => 'Weiter';
	@override String get cancelExternalLink => 'Abbrechen';
}

// Path: auth
class _TranslationsAuthDe extends TranslationsAuthEn {
	_TranslationsAuthDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get login => 'Anmelden';
	@override String get logout => 'Abmelden';
	@override String get email => 'E-Mail';
	@override String get password => 'Passwort';
	@override String get loginOrRegister => 'Anmelden / Registrieren';
	@override String get register => 'Registrieren';
	@override String get pleaseEnterEmail => 'Bitte E-Mail eingeben';
	@override String get pleaseEnterPassword => 'Bitte Passwort eingeben';
	@override String get passwordMustBeAtLeast6Characters => 'Das Passwort muss mindestens 6 Zeichen lang sein';
	@override String get pleaseEnterCaptcha => 'Bitte Captcha eingeben';
	@override String get captcha => 'Captcha';
	@override String get refreshCaptcha => 'Captcha erneuern';
	@override String get captchaNotLoaded => 'Captcha nicht geladen';
	@override String get loginSuccess => 'Anmeldung erfolgreich';
	@override String get loginSuccessProfilePending => 'Angemeldet. Profil wird geladen…';
	@override String get emailVerificationSent => 'E-Mail-Verifizierung gesendet';
	@override String get notLoggedIn => 'Nicht angemeldet';
	@override String get clickToLogin => 'Zum Anmelden tippen';
	@override String get logoutConfirmation => 'Möchten Sie sich wirklich abmelden?';
	@override String get logoutSuccess => 'Abmeldung erfolgreich';
	@override String get logoutFailed => 'Abmeldung fehlgeschlagen';
	@override String get usernameOrEmail => 'Benutzername oder E-Mail';
	@override String get pleaseEnterUsernameOrEmail => 'Bitte Benutzername oder E-Mail eingeben';
	@override String get rememberMe => 'Benutzername merken';
	@override String get registerNoticeTitle => 'Auf der offiziellen Website registrieren';
	@override String get registerNoticeDescription => 'Die In-App-Registrierung ist nicht mehr verfügbar. Bitte rufen Sie die offizielle Iwara-Website auf, um Ihr Konto zu erstellen, und kehren Sie dann hierher zurück, um sich anzumelden.';
	@override String get registerNoticeReturnTip => 'Kehren Sie nach der Registrierung hierher zurück und melden Sie sich mit Ihrem Konto an.';
	@override String get goToOfficialWebsite => 'Zur offiziellen Website';
}

// Path: errors
class _TranslationsErrorsDe extends TranslationsErrorsEn {
	_TranslationsErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get error => 'Fehler';
	@override String get required => 'Dieses Feld ist erforderlich';
	@override String get invalidEmail => 'Ungültige E-Mail-Adresse';
	@override String get networkError => 'Netzwerkfehler, bitte erneut versuchen';
	@override String get errorWhileFetching => 'Fehler beim Abrufen';
	@override String get commentCanNotBeEmpty => 'Der Kommentarinhalt darf nicht leer sein';
	@override String get errorWhileFetchingReplies => 'Fehler beim Abrufen der Antworten, bitte prüfen Sie die Netzwerkverbindung';
	@override String get canNotFindCommentController => 'Kommentar-Controller nicht gefunden';
	@override String get errorWhileLoadingGallery => 'Fehler beim Laden der Galerie';
	@override String get howCouldThereBeNoDataItCantBePossible => 'Wie kann es keine Daten geben? Das ist unmöglich :<';
	@override String unsupportedImageFormat({required Object str}) => 'Nicht unterstütztes Bildformat: ${str}';
	@override String get invalidGalleryId => 'Ungültige Galerie-ID';
	@override String get translationFailedPleaseTryAgainLater => 'Übersetzung fehlgeschlagen, bitte später erneut versuchen';
	@override String get errorOccurred => 'Ein Fehler ist aufgetreten, bitte später erneut versuchen.';
	@override String get errorOccurredWhileProcessingRequest => 'Beim Verarbeiten der Anfrage ist ein Fehler aufgetreten';
	@override String get errorWhileFetchingDatas => 'Fehler beim Abrufen der Daten, bitte später erneut versuchen';
	@override String get serviceNotInitialized => 'Dienst nicht initialisiert';
	@override String get unknownType => 'Unbekannter Typ';
	@override String errorWhileOpeningLink({required Object link}) => 'Fehler beim Öffnen des Links: ${link}';
	@override String get invalidUrl => 'Ungültige URL';
	@override String get failedToOperate => 'Vorgang fehlgeschlagen';
	@override String get permissionDenied => 'Berechtigung verweigert';
	@override String get youDoNotHavePermissionToAccessThisResource => 'Sie haben keine Berechtigung, auf diese Ressource zuzugreifen';
	@override String get loginFailed => 'Anmeldung fehlgeschlagen';
	@override String get unknownError => 'Unbekannter Fehler';
	@override String get sessionExpired => 'Sitzung abgelaufen';
	@override String get failedToFetchCaptcha => 'Captcha konnte nicht abgerufen werden';
	@override String get emailAlreadyExists => 'E-Mail existiert bereits';
	@override String get invalidCaptcha => 'Ungültiges Captcha';
	@override String get registerFailed => 'Registrierung fehlgeschlagen';
	@override String get failedToFetchComments => 'Kommentare konnten nicht abgerufen werden';
	@override String get failedToFetchImageDetail => 'Bilddetails konnten nicht abgerufen werden';
	@override String get failedToFetchImageList => 'Bildliste konnte nicht abgerufen werden';
	@override String get failedToFetchData => 'Daten konnten nicht abgerufen werden';
	@override String get invalidParameter => 'Ungültiger Parameter';
	@override String get pleaseLoginFirst => 'Bitte zuerst anmelden';
	@override String get errorWhileLoadingPost => 'Fehler beim Laden des Beitrags';
	@override String get errorWhileLoadingPostDetail => 'Fehler beim Laden der Beitragsdetails';
	@override String get invalidPostId => 'Ungültige Beitrags-ID';
	@override String get forceUpdateNotPermittedToGoBack => 'Derzeit im Zustand der erzwungenen Aktualisierung, Zurückgehen nicht möglich';
	@override String get pleaseLoginAgain => 'Bitte erneut anmelden';
	@override String get invalidLogin => 'Ungültige Anmeldung, bitte prüfen Sie E-Mail und Passwort';
	@override String get tooManyRequests => 'Zu viele Anfragen, bitte später erneut versuchen';
	@override String exceedsMaxLength({required Object max}) => 'Maximale Länge überschritten: ${max}';
	@override String get contentCanNotBeEmpty => 'Der Inhalt darf nicht leer sein';
	@override String get titleCanNotBeEmpty => 'Der Titel darf nicht leer sein';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Zu viele Anfragen, bitte später erneut versuchen, verbleibend';
	@override String remainingHours({required Object num}) => '${num} Stunden';
	@override String remainingMinutes({required Object num}) => '${num} Minuten';
	@override String remainingSeconds({required Object num}) => '${num} Sekunden';
	@override String tagLimitExceeded({required Object limit}) => 'Tag-Limit überschritten, Limit: ${limit}';
	@override String get failedToRefresh => 'Aktualisierung fehlgeschlagen';
	@override String get noPermission => 'Keine Berechtigung';
	@override String get resourceNotFound => 'Ressource nicht gefunden';
	@override String get failedToSaveCredentials => 'Anmeldedaten konnten nicht gespeichert werden';
	@override String get failedToLoadSavedCredentials => 'Gespeicherte Anmeldedaten konnten nicht geladen werden';
	@override String get notFound => 'Inhalt nicht gefunden oder wurde gelöscht';
	@override late final _TranslationsErrorsNetworkDe network = _TranslationsErrorsNetworkDe._(_root);
}

// Path: friends
class _TranslationsFriendsDe extends TranslationsFriendsEn {
	_TranslationsFriendsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Zum Wiederherstellen des Freundes klicken';
	@override String get friendsList => 'Freundesliste';
	@override String get friendRequests => 'Freundschaftsanfragen';
	@override String get friendRequestsList => 'Liste der Freundschaftsanfragen';
	@override String get removingFriend => 'Freund wird entfernt…';
	@override String get failedToRemoveFriend => 'Freund konnte nicht entfernt werden';
	@override String get cancelingRequest => 'Freundschaftsanfrage wird abgebrochen…';
	@override String get failedToCancelRequest => 'Freundschaftsanfrage konnte nicht abgebrochen werden';
}

// Path: authorProfile
class _TranslationsAuthorProfileDe extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'Keine weiteren Daten';
	@override String get userProfile => 'Benutzerprofil';
}

// Path: favorites
class _TranslationsFavoritesDe extends TranslationsFavoritesEn {
	_TranslationsFavoritesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Zum Wiederherstellen des Favoriten klicken';
	@override String get myFavorites => 'Meine Favoriten';
	@override String get batchCancelFavorite => 'Ausgewählte Favoriten entfernen';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'Die ${count} ausgewählten Element(e) aus den Favoriten entfernen? Sie können sie anschließend durch Antippen der Karten wiederherstellen.';
	@override String batchCancelFavoriteSuccess({required Object count}) => '${count} Element(e) aus den Favoriten entfernt';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => '${success} Element(e) entfernt, ${failed} fehlgeschlagen';
}

// Path: galleryDetail
class _TranslationsGalleryDetailDe extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Im Raum durchsuchen';
	@override String get galleryDetail => 'Galeriedetails';
	@override String get viewGalleryDetail => 'Galeriedetails anzeigen';
	@override String get zoomReset => 'Zoom zurücksetzen';
	@override String get copyLink => 'Link kopieren';
	@override String get copyImage => 'Bild kopieren';
	@override String get saveAs => 'Speichern unter';
	@override String get saveToAlbum => 'In Album speichern';
	@override String get publishedAt => 'Veröffentlicht am';
	@override String get viewsCount => 'Aufrufe';
	@override String get imageLibraryFunctionIntroduction => 'Einführung in die Funktionen der Bildbibliothek';
	@override String get rightClickToSaveSingleImage => 'Rechtsklick, um einzelnes Bild zu speichern';
	@override String get batchSave => 'Stapelspeicherung';
	@override String get keyboardLeftAndRightToSwitch => 'Tastatur links und rechts zum Wechseln';
	@override String get keyboardUpAndDownToZoom => 'Tastatur oben und unten zum Zoomen';
	@override String get mouseWheelToSwitch => 'Mausrad zum Wechseln';
	@override String get ctrlAndMouseWheelToZoom => 'STRG + Mausrad zum Zoomen';
	@override String get moreFeaturesToBeDiscovered => 'Weitere Funktionen zu entdecken…';
	@override String get authorOtherGalleries => 'Weitere Galerien des Autors';
	@override String get relatedGalleries => 'Verwandte Galerien';
	@override String get authorNoOtherGalleries => 'Keine weiteren Galerien von diesem Autor';
	@override String get noRelatedGalleries => 'Keine verwandten Galerien';
	@override String get scrollLeft => 'Nach links scrollen';
	@override String get scrollRight => 'Nach rechts scrollen';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Zum Wechseln des Bildes auf den linken oder rechten Rand klicken';
	@override String get rotateToLandscape => 'Vollbild im Querformat';
	@override String get backToPortrait => 'Zurück zum Hochformat';
}

// Path: playList
class _TranslationsPlayListDe extends TranslationsPlayListEn {
	_TranslationsPlayListDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Meine Wiedergabeliste';
	@override String get friendlyTips => 'Freundliche Hinweise';
	@override String get dearUser => 'Liebe Nutzerin, lieber Nutzer';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'Iwaras Wiedergabelisten-System ist noch nicht perfekt';
	@override String get notSupportSetCover => 'Festlegen eines Titelbilds wird nicht unterstützt';
	@override String get notSupportDeleteList => 'Löschen der Liste wird nicht unterstützt';
	@override String get notSupportSetPrivate => 'Festlegen als privat wird nicht unterstützt';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Ja... eine erstellte Liste bleibt dauerhaft bestehen und ist für alle sichtbar';
	@override String get smallSuggestion => 'Kleiner Tipp';
	@override String get useLikeToCollectContent => 'Wenn Ihnen Datenschutz wichtiger ist, empfiehlt es sich, die Funktion „Gefällt mir“ zum Sammeln von Inhalten zu verwenden';
	@override String get welcomeToDiscussOnGitHub => 'Wenn Sie weitere Vorschläge oder Ideen haben, diskutieren Sie gerne auf GitHub!';
	@override String get iUnderstand => 'Verstanden';
	@override String get searchPlaylists => 'Wiedergabelisten suchen...';
	@override String get newPlaylistName => 'Name der neuen Wiedergabeliste';
	@override String get createNewPlaylist => 'Neue Wiedergabeliste erstellen';
	@override String get videos => 'Videos';
}

// Path: search
class _TranslationsSearchDe extends TranslationsSearchEn {
	_TranslationsSearchDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Suchbereich';
	@override String get searchTags => 'Tags suchen...';
	@override String get contentRating => 'Inhaltseinstufung';
	@override String get removeTag => 'Tag entfernen';
	@override String get pleaseEnterSearchContent => 'Bitte Suchinhalt eingeben';
	@override String get exactMatch => 'Exakt';
	@override String get exactMatchOnHint => 'Exakte Übereinstimmung der Phrase, zusätzlich werden chinesische und japanische Titel durchsucht. Tippen für eine lockerere Suche.';
	@override String get exactMatchOffHint => 'Lockere Übereinstimmung — Iwara zerlegt die Wörter. Tippen für exakte Phrase.';
	@override String get searchHistory => 'Suchverlauf';
	@override String get searchSuggestion => 'Suchvorschläge';
	@override String get usedTimes => 'Nutzungshäufigkeit';
	@override String get lastUsed => 'Zuletzt verwendet';
	@override String get noSearchHistoryRecords => 'Kein Suchverlauf';
	@override String get clearSearchHistoryConfirm => 'Möchten Sie wirklich den gesamten Suchverlauf löschen? Dies kann nicht rückgängig gemacht werden.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Der aktuelle Suchtyp ${searchType} wird nicht unterstützt, bitte warten Sie auf das Update';
	@override String get searchResult => 'Suchergebnis';
	@override String unsupportedSearchType({required Object searchType}) => 'Nicht unterstützter Suchtyp: ${searchType}';
	@override String get googleSearch => 'Google-Suche';
	@override String googleSearchHint({required Object webName}) => '${webName}s Suchfunktion ist unpraktisch? Probieren Sie die Google-Suche!';
	@override String get googleSearchDescription => 'Verwenden Sie den Suchoperator :site der Google-Suche, um Inhalte auf der Website zu suchen. Das ist sehr nützlich bei der Suche nach Videos, Galerien, Wiedergabelisten und Nutzern.';
	@override String get googleSearchKeywordsHint => 'Stichwörter zum Suchen eingeben';
	@override String get openLinkJump => 'Link extern öffnen';
	@override String get googleSearchButton => 'Google-Suche';
	@override String get pleaseEnterSearchKeywords => 'Bitte Suchbegriffe eingeben';
	@override String get googleSearchQueryCopied => 'Suchanfrage in die Zwischenablage kopiert';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'Browser konnte nicht geöffnet werden: ${error}';
	@override String get searchRequestTimeout => 'Zeitüberschreitung der Anfrage, bitte später erneut versuchen';
	@override String get searchCannotConnectToServer => 'Verbindung zum Server nicht möglich, bitte prüfen Sie Ihre Netzwerkverbindung';
	@override String get searchNetworkError => 'Netzwerkverbindung fehlgeschlagen, bitte prüfen Sie Ihre Netzwerkeinstellungen oder versuchen Sie es später erneut';
	@override String get searchFailedPleaseRetry => 'Suche fehlgeschlagen, bitte später erneut versuchen';
}

// Path: mediaList
class _TranslationsMediaListDe extends TranslationsMediaListEn {
	_TranslationsMediaListDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Vorstellung';
}

// Path: settings
class _TranslationsSettingsDe extends TranslationsSettingsEn {
	_TranslationsSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Listenansicht';
	@override String get previewEffect => 'Effektvorschau';
	@override String get useTraditionalPaginationMode => 'Traditionellen Seitenmodus verwenden';
	@override String get useTraditionalPaginationModeDesc => 'Traditionellen Seitenmodus aktivieren, Wasserfall-Modus deaktivieren. Wirkt nach erneutem Rendern der Seite oder Neustart der App';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Untere Fortschrittsleiste bei ausgeblendeter Symbolleiste anzeigen';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Diese Konfiguration legt fest, ob die untere Videofortschrittsleiste angezeigt wird, wenn die Symbolleiste ausgeblendet ist.';
	@override String get seekPreviewSize => 'Größe der Spulvorschau';
	@override String get seekPreviewSizeDesc => 'Wie groß das Vorschaufenster über dem Fortschrittsbalken ist. Es richtet sich bereits nach der Playergröße und dem Seitenverhältnis des Videos; dies passt es nur leicht an.';
	@override String get seekPreviewSizeSmall => 'Klein';
	@override String get seekPreviewSizeStandard => 'Standard';
	@override String get seekPreviewSizeLarge => 'Groß';
	@override String get seekPreviewSizeStandardDesc => 'Die aus Player und Video abgeleitete Größe';
	@override String get showFullscreenUpNextHint => 'Den Griff „Als Nächstes“ anzeigen';
	@override String get showFullscreenUpNextHintDesc => 'Zeigt einen kleinen Griff am rechten Rand des Players an, der die Warteschlangen-Schublade (Quelle / Wiedergabeliste / Später ansehen) öffnet. Wenn er ausgeschaltet ist, gibt es keinen anderen Zugang.';
	@override String get basicSettings => 'Grundeinstellungen';
	@override String get personalizedSettings => 'Personalisierte Einstellungen';
	@override String get otherSettings => 'Weitere Einstellungen';
	@override String get searchConfig => 'Suchkonfiguration';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Diese Konfiguration legt fest, ob beim erneuten Abspielen von Videos die vorherige Konfiguration verwendet wird.';
	@override String get playControl => 'Wiedergabesteuerung';
	@override String get playbackSpeedSettings => 'Wiedergabe & Geschwindigkeit';
	@override String get playbackBehaviorSettings => 'Wiedergabeverhalten';
	@override String get enhancementSettings => 'Kino & Verbesserungen';
	@override String get fastForwardTime => 'Vorspulzeit';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'Die Vorspulzeit muss eine positive ganze Zahl sein.';
	@override String get rewindTime => 'Rückspulzeit';
	@override String get rewindTimeMustBeAPositiveInteger => 'Die Rückspulzeit muss eine positive ganze Zahl sein.';
	@override String get longPressPlaybackSpeed => 'Wiedergabegeschwindigkeit bei Langdruck';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Die Wiedergabegeschwindigkeit bei Langdruck muss eine positive Zahl sein.';
	@override String get defaultPlaybackSpeed => 'Standard-Wiedergabegeschwindigkeit';
	@override String get rememberPlaybackSpeed => 'Wiedergabegeschwindigkeit merken';
	@override String get rememberPlaybackSpeedDesc => 'Wenn aktiviert, wird die im Player eingestellte Geschwindigkeit als Standard gespeichert und automatisch auf neue Videos angewendet.';
	@override String get repeat => 'Wiederholen';
	@override String get renderVerticalVideoInVerticalScreen => 'Vertikales Video im Hochformat darstellen';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Diese Konfiguration legt fest, ob das Video bei der Wiedergabe im Vollbildmodus im Hochformat dargestellt wird.';
	@override String get rememberVolume => 'Lautstärke merken';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Diese Konfiguration legt fest, ob die Lautstärke beim erneuten Abspielen von Videos beibehalten wird.';
	@override String get rememberBrightness => 'Helligkeit merken';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Diese Konfiguration legt fest, ob die Helligkeit beim erneuten Abspielen von Videos beibehalten wird.';
	@override String get playControlArea => 'Wiedergabesteuerbereich';
	@override String get leftAndRightControlAreaWidth => 'Breite der linken und rechten Steuerfläche';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Diese Konfiguration legt die Breite der Steuerbereiche links und rechts am Player fest.';
	@override String get proxyAddressCannotBeEmpty => 'Proxy-Adresse darf nicht leer sein.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Ungültiges Proxy-Adressformat. Bitte verwenden Sie das Format IP:Port oder Domainname:Port.';
	@override String get proxyNormalWork => 'Proxy funktioniert normal.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Proxy-Test fehlgeschlagen, Statuscode: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Proxy-Test fehlgeschlagen, Ausnahme: ${exception}';
	@override String get proxyConfig => 'Proxy-Konfiguration';
	@override String get thisIsHttpProxyAddress => 'Dies ist eine HTTP-Proxy-Adresse';
	@override String get checkProxy => 'Proxy prüfen';
	@override String get proxyAddress => 'Proxy-Adresse';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Bitte geben Sie die URL des Proxyservers ein, zum Beispiel 127.0.0.1:8080';
	@override String get enableProxy => 'Proxy aktivieren';
	@override String get left => 'Links';
	@override String get middle => 'Mitte';
	@override String get right => 'Rechts';
	@override String get playerSettings => 'Player-Einstellungen';
	@override String get networkSettings => 'Netzwerkeinstellungen';
	@override String get customizeYourPlaybackExperience => 'Passen Sie Ihr Wiedergabeerlebnis an';
	@override String get chooseYourFavoriteAppAppearance => 'Wählen Sie Ihr bevorzugtes App-Erscheinungsbild';
	@override String get configureYourProxyServer => 'Konfigurieren Sie Ihren Proxyserver';
	@override String get settings => 'Einstellungen';
	@override String get themeSettings => 'Design-Einstellungen';
	@override String get followSystem => 'System folgen';
	@override String get lightMode => 'Hellmodus';
	@override String get darkMode => 'Dunkelmodus';
	@override String get presetTheme => 'Voreingestelltes Design';
	@override String get basicTheme => 'Standarddesign';
	@override String get needRestartToApply => 'Die App muss neu gestartet werden, damit die Einstellungen wirksam werden';
	@override String get themeNeedRestartDescription => 'Die Design-Einstellungen erfordern einen Neustart der App, um wirksam zu werden';
	@override String get about => 'Über';
	@override String get diagnosticsAndFeedback => 'Diagnose & Feedback';
	@override String get currentVersion => 'Aktuelle Version';
	@override String get latestVersion => 'Neueste Version';
	@override String get checkForUpdates => 'Nach Updates suchen';
	@override String get update => 'Aktualisieren';
	@override String get newVersionAvailable => 'Neue Version verfügbar';
	@override String get projectHome => 'Projekt-Startseite';
	@override String get release => 'Version';
	@override String get issueReport => 'Problem melden';
	@override String get openSourceLicense => 'Open-Source-Lizenz';
	@override String get checkForUpdatesFailed => 'Suche nach Updates fehlgeschlagen, bitte später erneut versuchen';
	@override String get autoCheckUpdate => 'Automatisch nach Updates suchen';
	@override String get updateContent => 'Update-Inhalt';
	@override String get releaseDate => 'Veröffentlichungsdatum';
	@override String get ignoreThisVersion => 'Diese Version ignorieren';
	@override String get forceUpdateTip => 'Dies ist ein obligatorisches Update. Bitte aktualisieren Sie so bald wie möglich auf die neueste Version';
	@override String get viewChangelog => 'Änderungsprotokoll anzeigen';
	@override String get alreadyLatestVersion => 'Bereits die neueste Version';
	@override String get appSettings => 'App-Einstellungen';
	@override String get configureYourAppSettings => 'Konfigurieren Sie Ihre App-Einstellungen';
	@override String get history => 'Verlauf';
	@override String get autoRecordHistory => 'Verlauf automatisch aufzeichnen';
	@override String get autoRecordHistoryDesc => 'Angesehene Videos und Bilder automatisch aufzeichnen';
	@override String get autoDeleteHistory => 'Verlauf automatisch löschen';
	@override String get autoDeleteHistoryDesc => 'Beim Start automatisch den Browserverlauf löschen, der älter als die Aufbewahrungstage ist (standardmäßig aus)';
	@override String get autoDeleteHistoryDays => 'Aufbewahrungstage';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Die letzten ${num} Tage behalten';
	@override String get autoDeleteHistoryDaysInvalid => 'Bitte eine gültige Anzahl von Tagen eingeben (mindestens 1)';
	@override String get showUnprocessedMarkdownText => 'Unverarbeiteten Markdown-Text anzeigen';
	@override String get showUnprocessedMarkdownTextDesc => 'Den Originaltext des Markdown anzeigen';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Datenschutzmodus';
	@override String get activeBackgroundPrivacyModeDesc => 'Screenshots und Bildschirmaufnahmen blockieren und den Bildschirm im Hintergrund ausblenden';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Den Bildschirm ausblenden, wenn die App in den Hintergrund wechselt (diese Plattform kann Screenshots nicht blockieren)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Screenshots und Bildschirmaufnahmen blockieren';
	@override String get privacy => 'Datenschutz';
	@override String get appLock => 'App-Sperre';
	@override String get appLockEnabled => 'App-Sperre aktivieren';
	@override String get appLockEnabledDesc => 'PIN oder Biometrie zum Öffnen der App erforderlich; die Hintergrundvorschau wird automatisch ausgeblendet';
	@override String get appLockEnabledSummary => 'An · PIN-geschützt';
	@override String get appLockDisabledSummary => 'Aus';
	@override String get appLockTimeout => 'Sperren nach Verlassen der App';
	@override String get appLockTimeoutDesc => 'Zulässige Zeit im Hintergrund, bevor eine Authentifizierung erforderlich ist';
	@override String get appLockAfterScreenOff => 'Sperren nach Bildschirmsperre';
	@override String get appLockAfterScreenOffDesc => 'Authentifizierung nach Sperren des Gerätebildschirms erforderlich';
	@override String get appLockTimeoutDisabled => 'Deaktiviert';
	@override String get appLockImmediately => 'Sofort';
	@override String appLockSeconds({required Object seconds}) => '${seconds} Sekunden';
	@override String appLockMinutes({required Object minutes}) => '${minutes} Minuten';
	@override String get appLockUseBiometrics => 'Biometrie verwenden';
	@override String get appLockUseBiometricsDesc => 'Mit Fingerabdruck oder Gesichtserkennung entsperren';
	@override String get appLockBiometricsUnavailable => 'Auf diesem Gerät sind keine registrierten biometrischen Daten verfügbar';
	@override String get appLockSetPin => 'PIN festlegen';
	@override String get appLockEnterPin => 'PIN eingeben';
	@override String get appLockConfirmPin => 'PIN bestätigen';
	@override String get appLockCurrentPin => 'Aktuelle PIN eingeben';
	@override String get appLockNewPin => 'Neue PIN eingeben';
	@override String get appLockPinRequirements => 'Die PIN muss 4–8 Ziffern enthalten';
	@override String get appLockPinsDoNotMatch => 'Die PINs stimmen nicht überein';
	@override String get appLockInvalidPin => 'Falsche PIN';
	@override String get appLockSetupFailed => 'PIN konnte nicht sicher gespeichert werden';
	@override String get appLockDisable => 'PIN eingeben, um die App-Sperre zu deaktivieren';
	@override String get appLockChangePin => 'PIN ändern';
	@override String get appLockNow => 'Jetzt sperren';
	@override String get appLockUnlock => 'Entsperren';
	@override String get appLockLockedTitle => 'Gesperrt';
	@override String get appLockLockedDesc => 'Zum Fortfahren authentifizieren';
	@override String get appLockAuthenticateReason => 'Zum Entsperren authentifizieren';
	@override String get appLockEnableBiometricsReason => 'Authentifizieren, um die biometrische Entsperrung zu aktivieren';
	@override String get appLockBiometricFailed => 'Biometrische Authentifizierung wurde nicht abgeschlossen';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Zu viele Versuche. Erneut versuchen in ${seconds}s';
	@override String get appLockCredentialUnavailableTitle => 'Zugangsdaten der App-Sperre können nicht gelesen werden';
	@override String get appLockCredentialUnavailableDesc => 'Der sichere Systemspeicher ist vorübergehend nicht verfügbar oder die Zugangsdaten sind beschädigt. Die App bleibt gesperrt. Versuchen Sie es zunächst erneut; wenn es weiter fehlschlägt, können Sie die App-Sperre zurücksetzen, wodurch sie deaktiviert und die gespeicherte PIN gelöscht wird.';
	@override String get appLockRetry => 'Erneut versuchen';
	@override String get appLockReset => 'App-Sperre zurücksetzen';
	@override String get appLockResetAction => 'Zurücksetzen';
	@override String get appLockResetConfirmTitle => 'App-Sperre zurücksetzen?';
	@override String get appLockResetConfirmDesc => 'Dadurch wird die App-Sperre deaktiviert und die gespeicherte PIN sowie die Biometrie-Einstellung gelöscht. Sie können sie danach erneut einrichten.';
	@override String get appLockRetrySucceeded => 'Zugangsdaten erfolgreich gelesen. Geben Sie Ihre PIN ein.';
	@override String get appLockRetryFailed => 'Zugangsdaten können weiterhin nicht gelesen werden';
	@override String get forum => 'Forum';
	@override String get news => 'Neuigkeiten';
	@override String get community => 'Community';
	@override String get disableForumReplyQuote => 'Zitat von Forumantworten deaktivieren';
	@override String get disableForumReplyQuoteDesc => 'Das Mitführen von Informationen zum beantworteten Beitrag beim Antworten im Forum deaktivieren';
	@override String get theaterMode => 'Kinomodus';
	@override String get theaterModeDesc => 'Nach dem Öffnen wird der Player-Hintergrund auf die unscharfe Version des Videocovers gesetzt';
	@override String get appLinks => 'App-Links';
	@override String get defaultBrowser => 'Standardbrowser';
	@override String get defaultBrowserDesc => 'Bitte öffnen Sie in den Systemeinstellungen den Eintrag für die Standard-Linkkonfiguration und fügen Sie den Link zur Website iwara.tv hinzu';
	@override String get themeMode => 'Designmodus';
	@override String get themeModeDesc => 'Diese Konfiguration legt den Designmodus der App fest';
	@override String get glassEffect => 'Oberflächenmaterial';
	@override String get glassEffectDesc => 'Wählt das in der gesamten App verwendete Material — Kopfbereich-Kapseln, Menüs, Dialogschaltflächen und die untere Navigationsleiste';
	@override String get liquidGlassEffect => 'Liquid Glass';
	@override String get liquidGlassEffectDesc => 'Echte Unschärfe und Lichtbrechung. Sieht am besten aus, kann aber auf schwächeren Geräten Bildraten senken und etwas mehr Energie verbrauchen';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Standard-Material-3-Oberflächen — undurchsichtig, keine Unschärfe, keine Schatten. Beste Leistung und Akkulaufzeit';
	@override String get glassEffectIntroTitle => 'Wählen Sie Ihr Oberflächenmaterial';
	@override String get glassEffectIntroContent => 'Kopfbereiche, die Registerleiste und Menüs verwenden Liquid Glass — echte Unschärfe und Lichtbrechung. Wenn es sich auf Ihrem Gerät langsam anfühlt oder Sie etwas Schlichteres bevorzugen, wechseln Sie jetzt zu Material (undurchsichtige Oberflächen, keine Unschärfe, keine Schatten).';
	@override String get glassEffectIntroHint => 'Sie können dies jederzeit unter Einstellungen → Design → Oberflächenmaterial ändern.';
	@override String get glassEffectIntroDone => 'Beibehalten';
	@override String get dynamicColor => 'Dynamische Farbe';
	@override String get dynamicColorDesc => 'Diese Konfiguration legt fest, ob die App dynamische Farben verwendet';
	@override String get useDynamicColor => 'Dynamische Farbe verwenden';
	@override String get useDynamicColorDesc => 'Diese Konfiguration legt fest, ob die App dynamische Farben verwendet';
	@override String get presetColors => 'Voreingestellte Farben';
	@override String get customColors => 'Benutzerdefinierte Farben';
	@override String get customColorsDisabledByDynamicColor => 'Dynamische Farbe ist aktiviert, daher sind Voreinstellungs-/benutzerdefinierte Farben nicht verfügbar. Deaktivieren Sie zuerst die dynamische Farbe.';
	@override String get pickColor => 'Farbe auswählen';
	@override String get cancel => 'Abbrechen';
	@override String get confirm => 'Bestätigen';
	@override String get noCustomColors => 'Keine benutzerdefinierten Farben';
	@override String get recordAndRestorePlaybackProgress => 'Wiedergabefortschritt aufzeichnen und wiederherstellen';
	@override String get autoPlayVideoOnFirstEnter => 'Video beim ersten Betreten automatisch abspielen';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Diese Einstellung legt fest, ob das Video beim ersten Betreten der Videoseite automatisch zu spielen beginnt.';
	@override String get autoEnterFullscreen => 'Automatisch Vollbild aktivieren';
	@override String get autoEnterFullscreenDesc => 'Wann der Player von selbst in den Vollbildmodus wechseln soll. Private, gelöschte und externe Videos bleiben unberührt, ebenso Bild-in-Bild.';
	@override String get autoEnterFullscreenOff => 'Aus';
	@override String get autoEnterFullscreenOffDesc => 'Nie von selbst in den Vollbildmodus wechseln';
	@override String get autoEnterFullscreenOnPlaybackStart => 'Wenn die Wiedergabe startet';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Im Moment des tatsächlichen Wiedergabebeginns in den Vollbildmodus wechseln';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'Beim Öffnen des Videos';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Sofort in den Vollbildmodus wechseln, sobald die Videoseite geöffnet wird, ohne auf die Wiedergabe zu warten';
	@override String get autoEnterFullscreenKind => 'Vollbildtyp';
	@override String get autoEnterFullscreenKindDesc => 'Welche Art von Vollbild automatisch aktiviert wird. Nur Desktop.';
	@override String get autoEnterFullscreenKindSystem => 'System-Vollbild';
	@override String get autoEnterFullscreenKindSystemDesc => 'Den Fenstermanager das Fenster in den Vollbildmodus versetzen lassen';
	@override String get autoEnterFullscreenKindApp => 'App-Vollbild';
	@override String get autoEnterFullscreenKindAppDesc => 'Das Fenster unverändert lassen und die gesamte App in den Player verwandeln';
	@override String get signature => 'Signatur';
	@override String get enableSignature => 'Signatur aktivieren';
	@override String get enableSignatureDesc => 'Diese Konfiguration legt fest, ob die App beim Antworten eine Signatur hinzufügt';
	@override String get enterSignature => 'Signatur eingeben';
	@override String get editSignature => 'Signatur bearbeiten';
	@override String get signatureContent => 'Signaturinhalt';
	@override String get signaturePreview => 'Vorschau';
	@override String get signatureSampleBody => 'Hier steht dein Text';
	@override String get signatureRegenerate => 'Neu generieren';
	@override String get signatureNotSet => 'Nicht festgelegt';
	@override String get signatureRuleHint => 'Die Signatur wird nach dem Text angehängt, getrennt durch eine Trennlinie. Die Linie fügt die App hinzu – schreibe nur die Zeile unten.';
	@override String get signatureInsertVariable => 'Variable einfügen';
	@override String get varDate => 'Datum';
	@override String get varTime => 'Uhrzeit';
	@override String get varDatetime => 'Datum und Uhrzeit';
	@override String get varWeekday => 'Wochentag';
	@override String get varPlatform => 'Plattform';
	@override String get varPick => 'Zufällige Zeile';
	@override String get varTitle => 'Titel';
	@override String get varAuthor => 'Urheber';
	@override String get varTags => 'Tags';
	@override String get varSection => 'Bereich';
	@override String get varReplyTo => 'Antwort an';
	@override String get varPlaytime => 'Wiedergabeposition';
	@override String get signatureContextGroup => 'Kontextvariablen';
	@override String get signatureContextHint => 'Die Werte kommen von der Seite, auf der du schreibst: Eine Videoseite kennt Titel, Autor, Tags und Abspielposition, das Forum kennt Bereich und Beitragsnummer. Rechts stehen Beispielwerte – was sich nicht füllen lässt, verschwindet beim Senden einfach.';
	@override String get signatureContextValue => 'Je nach Seite';
	@override String get varFloor => 'Beitragsnummer';
	@override String get varDuration => 'Videolänge';
	@override String get signatureRecipesHint => 'Keine Idee? Tippe eine an, übernimm sie und passe sie an. Unten siehst du, wie sie wirklich aussieht.';
	@override String get recipeWatchingName => 'Was ich gerade sehe';
	@override String get recipeWatchingTemplate => 'Sehe gerade %title% · %date%';
	@override String get recipeTimestampName => 'Bis hierher gesehen';
	@override String get recipeTimestampTemplate => 'Bei %playtime% von %duration%';
	@override String get recipeHitokotoName => 'Spruch des Tages';
	@override String get recipeHitokotoTemplate => 'Spruch des Tages: %hitokoto%';
	@override String get recipeAiName => 'Die KI schreiben lassen';
	@override String get recipeAiTemplate => '%ai_hitokoto%';
	@override String get recipeReplyName => 'Beim Antworten grüßen';
	@override String get recipeReplyTemplate => 'An %reply_to% · gesendet von %platform%';
	@override String get recipeMoodName => 'Wechselnde Laune';
	@override String get recipeMoodTemplate => 'Laune heute: %pick:bestens|geht so|frag lieber nicht%';
	@override String get signatureRecipesTitle => 'Beispiele';
	@override String get signatureRecipesMore => 'Mehr Beispiele';
	@override String get signatureSceneVideo => 'Auf einem Video';
	@override String get signatureSceneForum => 'Im Forum';
	@override String get signatureSceneAuthor => 'Auf einem Profil';
	@override String get signatureSceneNone => 'Ohne Kontext';
	@override String get signatureSceneFromHistory => 'Der Beispielinhalt stammt aus dem, was du zuletzt angesehen hast. Beim echten Senden zählt die Seite, auf der du gerade bist.';
	@override String get signatureSceneFromDemo => 'Noch kein Verlauf – es wird ein Platzhalter gezeigt. Beim echten Senden zählt die Seite, auf der du gerade bist.';
	@override String get signatureDemoVideoTitle => 'Tanz im Mondlicht';
	@override String get signatureDemoAuthor => 'Hoshino';
	@override String get signatureDemoTags => 'mmd 4k 60fps';
	@override String get signatureDemoThreadTitle => 'Tipps für die Qualitätseinstellungen?';
	@override String get signatureDemoSection => 'Allgemein';
	@override String get signatureDemoQuote => 'Langsam ist ruhig, ruhig ist schnell.';
	@override String get signatureDemoAiQuote => 'Diese Drehung bei dreieinhalb Minuten war allein schon alles wert.';
	@override String get signatureRecipeGroupWatching => 'Beim Ansehen';
	@override String get signatureRecipeGroupReplying => 'Beim Antworten';
	@override String get signatureRecipeGroupForum => 'Im Forum';
	@override String get signatureRecipeGroupDaily => 'Jeden Tag ein Satz';
	@override String get signatureRecipeGroupAi => 'Die KI schreiben lassen';
	@override String get signaturePromptSampleContext => 'Dieser Testlauf nutzt den Beispielkontext einer Videoseite. Beim echten Senden bekommt die KI das, was du gerade ansiehst.';
	@override String get recipeAuthorTagsName => 'Autor und Tags';
	@override String get recipeAuthorTagsTemplate => '%author% · %tags%';
	@override String get recipeFloorName => 'Antwort auf einen Beitrag';
	@override String get recipeFloorTemplate => 'Aus Beitrag %floor% · an %reply_to%';
	@override String get recipeSectionName => 'Bereich nennen';
	@override String get recipeSectionTemplate => 'Aus %section%';
	@override String get recipeDailyName => 'Datum plus Zitat';
	@override String get recipeDailyTemplate => '%date% %weekday% · %hitokoto%';
	@override String get signatureSources => 'Datenquellen';
	@override String get signatureAutoTranslate => 'In meine Sprache übersetzen';
	@override String get signatureAutoTranslateDesc => 'Zitatquellen wie Hitokoto liefern bisher nur Chinesisch. Der Satz wird direkt vor dem Senden übersetzt.';
	@override String get signatureWizardTitle => 'Datenquelle hinzufügen';
	@override String get signatureWizardUrlTitle => 'Adresse des Endpunkts';
	@override String get signatureWizardUrlHint => 'Gib eine URL an, die eine Textzeile zurückliefert. Der Knopf unten ruft sie wirklich auf, damit du siehst, was zurückkommt.';
	@override String get signatureWizardFetch => 'Abrufen';
	@override String get signatureWizardSkipTest => 'Überspringen, nur umbenennen';
	@override String get signatureWizardPickTitle => 'Wähle den gewünschten Teil';
	@override String get signatureWizardPickHint => 'Das kam von diesem Endpunkt zurück. Tippe die Zeile an, die deine Signatur zeigen soll.';
	@override String get signatureWizardPickPlainHint => 'Dieser Endpunkt liefert reinen Text – das Ganze wird angezeigt.';
	@override String get signatureWizardWholeBody => 'Die ganze Antwort';
	@override String get signatureWizardNameTitle => 'Gib ihr einen Namen';
	@override String get signatureWizardNameHint => 'Der Name ist nur für dich. Angesprochen wird die Quelle über den Referenznamen darunter.';
	@override String get signatureWizardNext => 'Weiter';
	@override String get signatureWizardDone => 'Fertig';
	@override String get signatureWizardStripHtml => 'HTML-Tags entfernen';
	@override String get signatureWizardAdvanced => 'Erweitert: mit Muster herausziehen';
	@override String get signatureWizardExtractHint => 'Regulärer Ausdruck; die erste Gruppe zählt';
	@override String get signatureWizardExtractMissed => 'Das Muster passt nicht, der Text bleibt unverändert';
	@override String get signatureWizardChooseTitle => 'Quelle auswählen';
	@override String get signatureWizardChooseHint => 'Tippe auf eine fertige Quelle, fertig. Oder gib deinen eigenen Endpunkt an.';
	@override String get signatureWizardCustomSource => 'Eigenen Endpunkt verwenden';
	@override String get signatureWizardWithOrigin => 'Herkunft mit anzeigen';
	@override String get signatureWizardRandomItem => 'Jedes Mal eine andere nehmen';
	@override String get signatureWizardSuffixTitle => 'Weiteres Feld anhängen';
	@override String get signatureWizardSuffixNone => 'Nichts';
	@override String get signatureOptFlavor => 'Inhalt';
	@override String get signatureOptFlavorAny => 'Alles';
	@override String get signatureOptFlavorOtaku => 'Anime, Manga & Spiele';
	@override String get signatureOptFlavorLiterary => 'Literatur & Poesie';
	@override String get signatureOptFlavorMeme => 'Internetkultur';
	@override String get signatureOptLength => 'Länge';
	@override String get signatureOptLengthAny => 'Beliebig';
	@override String get signatureOptLengthShort => 'Nur kurze Sätze';
	@override String get signatureRestoreDefault => 'Standard wiederherstellen';
	@override String get signatureSourceHitokoto => 'Hitokoto (Zufallszitat)';
	@override String get signatureAiSourceName => 'KI-generierte Zeile';
	@override String get signatureEditTextHint => 'Das ist die Signatur, die bereits in diesem Kommentar steht — Spruch und Datum sind jetzt einfach Text, ändere sie beliebig. Leeren entfernt die Signatur.';
	@override String signatureResolving({required Object name}) => 'Erzeuge ${name}…';
	@override String get signaturePendingValue => '(wird beim Senden erzeugt)';
	@override String get signatureAiHint => 'Ein Satz, den die KI spontan schreibt – für jeden Kommentar neu, über den von dir eingerichteten KI-Anbieter. Auf Video-, Galerie- und Forumseiten weiß sie außerdem, was du gerade ansiehst, und kann darauf eingehen.';
	@override String get signatureAiUnavailable => 'Noch kein KI-Anbieter eingerichtet, deshalb taucht diese Quelle nicht im Variablen-Panel auf.';
	@override String get signaturePromptTitle => 'Prompt';
	@override String get signaturePromptHint => 'Das geht so an das Modell. Schreib es um, wie du willst — Ton, Länge, Thema. Die Regeln, die schon drinstehen, lohnt es sich zu behalten.';
	@override String get signaturePromptReset => 'Standard wiederherstellen';
	@override String get signaturePromptTry => 'Ausprobieren';
	@override String get signaturePromptSample => 'Das Ergebnis';
	@override String get signaturePromptLanguageHint => 'wird durch deine Oberflächensprache ersetzt. Ohne das folgt die Zeile der Sprache des Prompts.';
	@override String get signaturePromptEdited => 'geändert';
	@override String get signatureVariablesGroup => 'Eingebaute Variablen';
	@override String get signatureNeedsNetwork => 'Braucht Netz';
	@override String get signatureBuiltinSource => 'Eingebaut';
	@override String get signatureSourceIdReserved => 'Dieser Name gehört bereits einer eingebauten Variablen';
	@override String get signatureSourcesTitle => 'Eigene Datenquellen';
	@override String get signatureSourcesHint => 'Gib eine Adresse an, die eine Textzeile zurückliefert, und du kannst sie in deine Signatur holen.';
	@override String get signatureSourcesEmpty => 'Noch keine Datenquellen';
	@override String get signatureAddSource => 'Hinzufügen';
	@override String get signatureEditSource => 'Datenquelle bearbeiten';
	@override String get signatureSourceName => 'Name';
	@override String get signatureSourceId => 'Referenzname';
	@override String get signatureSourceIdHint => 'So spricht deine Signatur diese Quelle an';
	@override String get signatureSourceUrl => 'Endpunkt-URL';
	@override String get signatureSourcePath => 'Wertpfad';
	@override String get signatureSourcePathHint => 'Leer lassen, wenn die gesamte Antwort der Text ist. Mit data.text holst du dieses Feld aus einer JSON-Antwort.';
	@override String get signatureSourceTest => 'Testen';
	@override String get signatureSourceTestOk => 'Hat geklappt';
	@override String get signatureSourceTestFailed => 'Es kam nichts zurück';
	@override String get signatureSourceIdInvalid => 'Referenznamen dürfen nur Kleinbuchstaben, Ziffern und Unterstriche enthalten';
	@override String get signatureSourceIdDuplicate => 'Dieser Referenzname ist bereits vergeben';
	@override String get signatureSourceUrlRequired => 'Eine Endpunkt-URL ist erforderlich';
	@override String get exportConfig => 'App-Konfiguration exportieren';
	@override String get exportConfigDesc => 'Einstellungen und Verlauf (Browserverlauf, Wiedergabefortschritt, Favoriten usw.) zur Sicherung oder Übertragung auf ein anderes Gerät in eine Datei exportieren. Download-Aufgaben sind nicht enthalten.';
	@override String get importConfig => 'App-Konfiguration importieren';
	@override String get importConfigDesc => 'App-Konfiguration aus einer Datei importieren';
	@override String get exportConfigSuccess => 'Konfiguration erfolgreich exportiert!';
	@override String get exportConfigFailed => 'Konfiguration konnte nicht exportiert werden';
	@override String get importConfigSuccess => 'Konfiguration erfolgreich importiert!';
	@override String get importConfigFailed => 'Konfiguration konnte nicht importiert werden';
	@override String get exportIncludeSensitive => 'Sensible Informationen einschließen';
	@override String get exportIncludeSensitiveDesc => 'Schließt API-Schlüssel, Sitzungstoken und Proxy-Adresse ein. Nur aktivieren, wenn Sie auf Ihr eigenes Gerät sichern.';
	@override String get importConfigOverwriteWarning => 'Beim Importieren werden Ihre aktuellen Einstellungen und Ihr Verlauf (Browserverlauf, Wiedergabefortschritt, Favoriten usw.) überschrieben. Fortfahren?';
	@override String get importConfigRestartTitle => 'Import erfolgreich';
	@override String get importConfigRestartContent => 'Ihre Konfiguration wurde importiert. Bitte schließen Sie die App vollständig und öffnen Sie sie erneut, damit alle Änderungen wirksam werden.';
	@override String get historyUpdateLogs => 'Update-Verlauf';
	@override String get noUpdateLogs => 'Keine Update-Protokolle verfügbar';
	@override String get versionLabel => 'Version: {version}';
	@override String get releaseDateLabel => 'Veröffentlichungsdatum: {date}';
	@override String get noChanges => 'Kein Update-Inhalt verfügbar';
	@override String get interaction => 'Interaktion';
	@override String get enableVibration => 'Vibration aktivieren';
	@override String get enableVibrationDesc => 'Vibrationsfeedback bei der Interaktion mit der App aktivieren';
	@override String get defaultKeepVideoToolbarVisible => 'Video-Symbolleiste sichtbar halten';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Diese Einstellung legt fest, ob die Video-Symbolleiste beim ersten Betreten der Videoseite sichtbar bleibt.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Auf Mobilgeräten kann der Kinomodus Leistungsprobleme verursachen. Sie können ihn optional aktivieren.';
	@override String get fullscreenOrientation => 'Bildschirmausrichtung nach Wechsel in den Vollbildmodus';
	@override String get fullscreenOrientationDesc => 'Diese Einstellung legt die Standardbildschirmausrichtung beim Wechsel in den Vollbildmodus fest (nur mobil)';
	@override String get fullscreenOrientationLeftLandscape => 'Querformat links';
	@override String get fullscreenOrientationRightLandscape => 'Querformat rechts';
	@override String get screenFit => 'Bildschirmgröße';
	@override String get screenFitDesc => 'Wählen Sie, wie das Video den Player-Bereich füllt.';
	@override String get rememberScreenFit => 'Bildschirmgröße merken';
	@override String get rememberScreenFitDesc => 'Die ausgewählte Größe auf später geöffnete Videos anwenden.';
	@override String get screenFitFit => 'Einpassen';
	@override String get screenFitFitDesc => 'Das gesamte Bild unter Beibehaltung des Seitenverhältnisses anzeigen';
	@override String get screenFitStretch => 'Strecken';
	@override String get screenFitStretchDesc => 'Den Player-Bereich füllen; das Bild kann verzerrt werden';
	@override String get screenFitCover => 'Ausfüllen';
	@override String get screenFitCoverDesc => 'Den Player-Bereich unter Beibehaltung des Seitenverhältnisses füllen; Überstehendes wird abgeschnitten';
	@override String get screenFitRatioDesc => 'Dieses Seitenverhältnis erzwingen; das Bild kann verzerrt werden';
	@override String get jumpLink => 'Sprunglink';
	@override String get language => 'Sprache';
	@override String get languageNativeName => 'Deutsch';
	@override String get followSystemLanguage => 'Systemsprache';
	@override String get languageChangedMessage => 'Sprache geändert. Einige Funktionen werden erst nach einem Neustart der App wirksam.';
	@override String get languageChanged => 'Die Spracheinstellung wurde geändert. Bitte starten Sie die App neu, damit sie wirksam wird.';
	@override late final _TranslationsSettingsKeybindingDe keybinding = _TranslationsSettingsKeybindingDe._(_root);
	@override String get gestureControl => 'Gestensteuerung';
	@override String get leftDoubleTapRewind => 'Zurückspulen bei Doppeltipp links';
	@override String get rightDoubleTapFastForward => 'Vorspulen bei Doppeltipp rechts';
	@override String get doubleTapPause => 'Pause durch Doppeltippen';
	@override String get rightVerticalSwipeVolume => 'Lautstärke durch vertikales Wischen rechts (wirksam beim Öffnen einer neuen Seite)';
	@override String get leftVerticalSwipeBrightness => 'Helligkeit durch vertikales Wischen links (wirksam beim Öffnen einer neuen Seite)';
	@override String get longPressFastForward => 'Vorspulen bei Langdruck';
	@override String get enableMouseHoverShowToolbar => 'Symbolleiste bei Mauszeiger-Anzeige einblenden';
	@override String get enableMouseHoverShowToolbarInfo => 'Wenn aktiviert, wird die Video-Symbolleiste angezeigt, wenn der Mauszeiger über dem Player schwebt. Nach 3 Sekunden Inaktivität wird sie automatisch ausgeblendet.';
	@override String get enableHorizontalDragSeek => 'Horizontales Wischen zum Spulen';
	@override String get enableVideoGestureZoom => 'Videobild durch Zusammenziehen vergrößern';
	@override String get enableVideoGestureZoomInfo => 'Ziehen Sie mit zwei Fingern zusammen (oder Strg + Mausrad auf dem Desktop), um das Videobild zu vergrößern, und ziehen Sie es dann zum Verschieben.';
	@override String get showCenterPlayPauseButton => 'Wiedergabe-/Pause-Schaltfläche in der Mitte';
	@override String get showCenterPlayPauseButtonDesc => 'Die große Wiedergabe-/Pause-Schaltfläche in der Mitte des Players anzeigen.';
	@override String get audioVideoConfig => 'Audio-Video-Konfiguration';
	@override String get expandBuffer => 'Puffer erweitern';
	@override String get expandBufferInfo => 'Wenn aktiviert, wird die Puffergröße erhöht; die Ladezeit wird länger, aber die Wiedergabe ist flüssiger';
	@override String get videoSyncMode => 'Video-Synchronisierungsmodus';
	@override String get videoSyncModeSubtitle => 'Strategie zur Audio-Video-Synchronisierung';
	@override String get hardwareDecodingMode => 'Hardware-Dekodierungsmodus';
	@override String get hardwareDecodingModeSubtitle => 'Einstellungen für die Hardware-Dekodierung';
	@override String get enableHardwareAcceleration => 'Hardwarebeschleunigung aktivieren';
	@override String get enableHardwareAccelerationInfo => 'Das Aktivieren der Hardwarebeschleunigung kann die Dekodierungsleistung verbessern, aber einige Geräte sind möglicherweise nicht kompatibel';
	@override String get useOpenSLESAudioOutput => 'OpenSLES-Audioausgabe verwenden';
	@override String get useOpenSLESAudioOutputInfo => 'Audioausgabe mit niedriger Latenz verwenden, kann die Audioleistung verbessern';
	@override String get videoSyncAudio => 'Audio-Synchronisierung';
	@override String get videoSyncDisplayResample => 'Neuabtastung anzeigen';
	@override String get videoSyncDisplayResampleVdrop => 'Neuabtastung anzeigen (Frames verwerfen)';
	@override String get videoSyncDisplayResampleDesync => 'Neuabtastung anzeigen (desynchronisiert)';
	@override String get videoSyncDisplayTempo => 'Tempo anzeigen';
	@override String get videoSyncDisplayVdrop => 'Video-Frames verwerfen anzeigen';
	@override String get videoSyncDisplayAdrop => 'Audio-Frames verwerfen anzeigen';
	@override String get videoSyncDisplayDesync => 'Desynchronisation anzeigen';
	@override String get videoSyncDesync => 'Desynchronisiert';
	@override late final _TranslationsSettingsForumSettingsDe forumSettings = _TranslationsSettingsForumSettingsDe._(_root);
	@override late final _TranslationsSettingsGallerySettingsDe gallerySettings = _TranslationsSettingsGallerySettingsDe._(_root);
	@override late final _TranslationsSettingsBlockSettingsDe blockSettings = _TranslationsSettingsBlockSettingsDe._(_root);
	@override late final _TranslationsSettingsChatSettingsDe chatSettings = _TranslationsSettingsChatSettingsDe._(_root);
	@override String get hardwareDecodingAuto => 'Automatisch';
	@override String get hardwareDecodingAutoCopy => 'Automatisch kopieren';
	@override String get hardwareDecodingAutoSafe => 'Automatisch sicher';
	@override String get hardwareDecodingNo => 'Deaktiviert';
	@override String get hardwareDecodingYes => 'Erzwingen';
	@override String get cdnDistributionStrategy => 'Inhaltsverteilungsstrategie';
	@override String get cdnDistributionStrategyDesc => 'Wählen Sie die Verteilungsstrategie der Videoquellenserver, um die Ladegeschwindigkeit zu optimieren';
	@override String get cdnDistributionStrategyLabel => 'Verteilungsstrategie';
	@override String get cdnDistributionStrategyNoChange => 'Keine Änderung (ursprünglichen Server verwenden)';
	@override String get cdnDistributionStrategyAuto => 'Automatisch auswählen (schnellster Server)';
	@override String get cdnDistributionStrategySpecial => 'Server festlegen';
	@override String get cdnSpecialServer => 'Server festlegen';
	@override String get cdnRefreshServerListHint => 'Bitte klicken Sie auf die Schaltfläche unten, um die Serverliste zu aktualisieren';
	@override String get cdnRefreshButton => 'Aktualisieren';
	@override String get cdnFastRingServers => 'Fast-Ring-Server';
	@override String get cdnRefreshServerListTooltip => 'Serverliste aktualisieren';
	@override String get cdnSpeedTestButton => 'Geschwindigkeitstest';
	@override String cdnSpeedTestingButton({required Object count}) => 'Test läuft (${count})';
	@override String get cdnNoServerDataHint => 'Keine Serverdaten verfügbar, bitte klicken Sie auf die Aktualisieren-Schaltfläche';
	@override String get cdnTestingStatus => 'Wird getestet';
	@override String get cdnUnreachableStatus => 'Nicht erreichbar';
	@override String get cdnNotTestedStatus => 'Nicht getestet';
	@override late final _TranslationsSettingsDownloadSettingsDe downloadSettings = _TranslationsSettingsDownloadSettingsDe._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsDe extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Favorisierte Tags';
	@override String get emptyIwara => 'Noch keine favorisierten Iwara-Tags';
	@override String get emptyOreno3d => 'Noch keine Favoriten';
	@override String get addIwaraTag => 'Iwara-Tag hinzufügen';
	@override String get quickPickHint => 'Favorisierte Elemente erscheinen als Schnellauswahl in der Suche.';
	@override String get pickerTitle => 'Oreno3D auswählen';
	@override String get searchHint => 'Nach Name oder Original suchen';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n,
		one: '${n} Werk',
		other: '${n} Werke',
	);
	@override String get browseEntry => 'Nach Herkunft / Charakter / Tag durchsuchen';
	@override String get favoritesSection => 'Favoriten';
	@override String get addFavorite => 'Hinzufügen';
	@override String get iwaraTitle => 'Favorisierte Iwara-Tags';
	@override String get oreno3dTitle => 'Favorisierte Oreno3D-Tags';
	@override String get changeTag => 'Tag ändern';
	@override String get switchToText => 'Textsuche';
}

// Path: oreno3d
class _TranslationsOreno3dDe extends TranslationsOreno3dEn {
	_TranslationsOreno3dDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Tags';
	@override String get characters => 'Charaktere';
	@override String get origin => 'Herkunft';
	@override String get thirdPartyTagsExplanation => 'Die hier angezeigten Informationen zu **Tags**, **Charakteren** und **Herkunft** stammen von der Drittanbieter-Seite **Oreno3D** und dienen nur als Referenz.\n\nDa diese Informationsquelle nur auf Japanisch verfügbar ist, fehlt derzeit eine Internationalisierungsanpassung.\n\nWenn Sie zur Internationalisierung beitragen möchten, besuchen Sie bitte das Repository, um es zu verbessern!';
	@override late final _TranslationsOreno3dSortTypesDe sortTypes = _TranslationsOreno3dSortTypesDe._(_root);
	@override late final _TranslationsOreno3dErrorsDe errors = _TranslationsOreno3dErrorsDe._(_root);
	@override late final _TranslationsOreno3dLoadingDe loading = _TranslationsOreno3dLoadingDe._(_root);
	@override late final _TranslationsOreno3dMessagesDe messages = _TranslationsOreno3dMessagesDe._(_root);
}

// Path: signIn
class _TranslationsSignInDe extends TranslationsSignInEn {
	_TranslationsSignInDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Bitte melden Sie sich zuerst an';
	@override String get alreadySignedInToday => 'Sie haben sich heute bereits angemeldet!';
	@override String get youDidNotStickToTheSignIn => 'Sie haben die Anmeldung nicht durchgehalten.';
	@override String get signInSuccess => 'Erfolgreich angemeldet!';
	@override String get signInFailed => 'Anmeldung fehlgeschlagen, bitte später erneut versuchen';
	@override String get consecutiveSignIns => 'Aufeinanderfolgende Anmeldungen';
	@override String get failureReason => 'Fehlergrund';
	@override String get selectDateRange => 'Datumsbereich auswählen';
	@override String get startDate => 'Startdatum';
	@override String get endDate => 'Enddatum';
	@override String get invalidDate => 'Ungültiges Datum';
	@override String get invalidDateRange => 'Ungültiger Datumsbereich';
	@override String get errorFormatText => 'Datumsformatfehler';
	@override String get errorInvalidText => 'Ungültiger Datumsbereich';
	@override String get errorInvalidRangeText => 'Ungültiger Datumsbereich';
	@override String get dateRangeCantBeMoreThanOneYear => 'Der Datumsbereich darf nicht mehr als ein Jahr betragen';
	@override String get signIn => 'Anmelden';
	@override String get signInRecord => 'Anmeldeverlauf';
	@override String get totalSignIns => 'Anmeldungen insgesamt';
	@override String get pleaseSelectSignInStatus => 'Bitte wählen Sie den Anmeldestatus';
}

// Path: subscriptions
class _TranslationsSubscriptionsDe extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Bitte melden Sie sich zuerst an, um Ihre Abonnements anzusehen.';
	@override String get selectUser => 'Nutzer auswählen';
	@override String get noSubscribedUsers => 'Keine abonnierten Nutzer';
	@override String get showAllSubscribedUsersContent => 'Inhalte aller abonnierten Nutzer anzeigen';
}

// Path: videoDetail
class _TranslationsVideoDetailDe extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'PiP-Modus';
	@override String resumeFromLastPosition({required Object position}) => 'Von der letzten Position fortsetzen: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Fortgesetzt ab ${position}';
	@override String get restartFromBeginning => 'Von vorne beginnen';
	@override String get dismissResumeTip => 'Ausblenden';
	@override late final _TranslationsVideoDetailLocalInfoDe localInfo = _TranslationsVideoDetailLocalInfoDe._(_root);
	@override String get videoIdIsEmpty => 'Video-ID ist leer';
	@override String get videoInfoIsEmpty => 'Videoinformationen sind leer';
	@override String get thisIsAPrivateVideo => 'Dies ist ein privates Video';
	@override String get getVideoInfoFailed => 'Videoinformationen konnten nicht abgerufen werden, bitte später erneut versuchen';
	@override String get noVideoSourceFound => 'Keine Videoquelle gefunden';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Tag „${tagId}“ in die Zwischenablage kopiert';
	@override String get errorLoadingVideo => 'Fehler beim Laden des Videos';
	@override String get play => 'Wiedergabe';
	@override String get pause => 'Pause';
	@override String get exitAppFullscreen => 'App-Vollbild beenden';
	@override String get enterAppFullscreen => 'App-Vollbild aktivieren';
	@override String get exitSystemFullscreen => 'System-Vollbild beenden';
	@override String get enterSystemFullscreen => 'System-Vollbild aktivieren';
	@override String get seekTo => 'Springen zu';
	@override String get switchResolution => 'Auflösung wechseln';
	@override String get switchPlaybackSpeed => 'Wiedergabegeschwindigkeit wechseln';
	@override String rewindSeconds({required Object num}) => '${num} Sekunden zurückspulen';
	@override String fastForwardSeconds({required Object num}) => '${num} Sekunden vorspulen';
	@override String playbackSpeedIng({required Object rate}) => 'Wiedergabe mit ${rate}x Geschwindigkeit';
	@override String get brightness => 'Helligkeit';
	@override String get brightnessLowest => 'Helligkeit ist am niedrigsten';
	@override String get volume => 'Lautstärke';
	@override String get volumeMuted => 'Lautstärke ist stummgeschaltet';
	@override String get restoreDefaultZoom => 'Wiederherstellen';
	@override late final _TranslationsVideoDetailGestureGuideDe gestureGuide = _TranslationsVideoDetailGestureGuideDe._(_root);
	@override String get home => 'Startseite';
	@override String get videoPlayer => 'Videoplayer';
	@override String get videoPlayerInfo => 'Videoplayer-Info';
	@override String get moreSettings => 'Weitere Einstellungen';
	@override String get videoPlayerFeatureInfo => 'Funktionsinfo zum Videoplayer';
	@override String get autoRewind => 'Automatisches Zurückspulen';
	@override String get rewindAndFastForward => 'Zurückspulen und Vorspulen';
	@override String get volumeAndBrightness => 'Lautstärke und Helligkeit';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Pause oder Wiedergabe bei Doppeltipp im mittleren Bereich';
	@override String get showVerticalVideoInFullScreen => 'Vertikales Video im Vollbild anzeigen';
	@override String get keepLastVolumeAndBrightness => 'Letzte Lautstärke und Helligkeit beibehalten';
	@override String get setProxy => 'Proxy festlegen';
	@override String get moreFeaturesToBeDiscovered => 'Weitere Funktionen zu entdecken...';
	@override String get videoPlayerSettings => 'Videoplayer-Einstellungen';
	@override String commentCount({required Object num}) => '${num} Kommentare';
	@override String get writeYourCommentHere => 'Schreiben Sie hier Ihren Kommentar...';
	@override String get authorOtherVideos => 'Weitere Videos des Autors';
	@override String get relatedVideos => 'Ähnliche Videos';
	@override String get privateVideo => 'Dies ist ein privates Video';
	@override String get externalVideo => 'Dies ist ein externes Video';
	@override String get openInBrowser => 'Im Browser öffnen';
	@override String get resourceDeleted => 'Dieses Video wurde offenbar gelöscht :/';
	@override String get noDownloadUrl => 'Keine Download-URL';
	@override String get startDownloading => 'Download starten';
	@override String get downloadFailed => 'Download fehlgeschlagen, bitte später erneut versuchen';
	@override String get downloadSuccess => 'Download erfolgreich';
	@override String get download => 'Herunterladen';
	@override String get downloadManager => 'Download-Manager';
	@override String get resourceNotFound => 'Ressource nicht gefunden';
	@override String get videoLoadError => 'Fehler beim Laden des Videos';
	@override String get authorNoOtherVideos => 'Autor hat keine weiteren Videos';
	@override String get noRelatedVideos => 'Keine ähnlichen Videos';
	@override late final _TranslationsVideoDetailPlayerDe player = _TranslationsVideoDetailPlayerDe._(_root);
	@override late final _TranslationsVideoDetailSkeletonDe skeleton = _TranslationsVideoDetailSkeletonDe._(_root);
	@override late final _TranslationsVideoDetailCastDe cast = _TranslationsVideoDetailCastDe._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsDe likeAvatars = _TranslationsVideoDetailLikeAvatarsDe._(_root);
}

// Path: share
class _TranslationsShareDe extends TranslationsShareEn {
	_TranslationsShareDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Wiedergabeliste teilen';
	@override String get wowDidYouSeeThis => 'Wow, haben Sie das gesehen?';
	@override String get nameIs => 'Name ist';
	@override String get clickLinkToView => 'Zum Ansehen auf den Link klicken';
	@override String get iReallyLikeThis => 'Das gefällt mir sehr';
	@override String get shareFailed => 'Teilen fehlgeschlagen, bitte später erneut versuchen';
	@override String get share => 'Teilen';
	@override String get shareAsImage => 'Als Bild teilen';
	@override String get shareAsText => 'Als Text teilen';
	@override String get shareAsImageDesc => 'Das Videocover als Bild teilen';
	@override String get shareAsTextDesc => 'Die Videodetails als Text teilen';
	@override String get shareAsImageFailed => 'Teilen des Videocovers als Bild fehlgeschlagen, bitte später erneut versuchen';
	@override String get shareAsTextFailed => 'Teilen der Videodetails als Text fehlgeschlagen, bitte später erneut versuchen';
	@override String get shareVideo => 'Video teilen';
	@override String get authorIs => 'Autor ist';
	@override String get shareGallery => 'Galerie teilen';
	@override String get galleryTitleIs => 'Titel der Galerie ist';
	@override String get galleryAuthorIs => 'Autor der Galerie ist';
	@override String get shareUser => 'Nutzer teilen';
	@override String get userNameIs => 'Benutzername ist';
	@override String get userAuthorIs => 'Autor des Nutzers ist';
	@override String get comments => 'Kommentare';
	@override String get shareThread => 'Thread teilen';
	@override String get views => 'Aufrufe';
	@override String get sharePost => 'Beitrag teilen';
	@override String get postTitleIs => 'Titel des Beitrags ist';
	@override String get postAuthorIs => 'Autor des Beitrags ist';
}

// Path: markdown
class _TranslationsMarkdownDe extends TranslationsMarkdownEn {
	_TranslationsMarkdownDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Markdown-Syntax';
	@override String get iwaraSpecialMarkdownSyntax => 'Iwara-spezifische Markdown-Syntax';
	@override String get internalLink => 'Interner Link';
	@override String get supportAutoConvertLinkBelow => 'Automatische Umwandlung der folgenden Links wird unterstützt:';
	@override String get convertLinkExample => '🎬 Videolink\n🖼️ Bildlink\n👤 Benutzerlink\n📌 Forum-Link\n🎵 Playlist-Link\n💬 Themenlink';
	@override String get mentionUser => 'Benutzer erwähnen';
	@override String get mentionUserDescription => 'Geben Sie @ gefolgt vom Benutzernamen ein; dies wird automatisch in einen Benutzerlink umgewandelt';
	@override String get markdownBasicSyntax => 'Markdown-Grundsyntax';
	@override String get paragraphAndLineBreak => 'Absatz und Zeilenumbruch';
	@override String get paragraphAndLineBreakDescription => 'Absätze werden durch eine Leerzeile getrennt, und zwei Leerzeichen am Zeilenende werden in einen Zeilenumbruch umgewandelt';
	@override String get paragraphAndLineBreakSyntax => 'Dies ist der erste Absatz\n\nDies ist der zweite Absatz\nDiese Zeile endet mit zwei Leerzeichen  \nwird in einen Zeilenumbruch umgewandelt';
	@override String get textStyle => 'Textstil';
	@override String get textStyleDescription => 'Umgeben Sie Text mit speziellen Symbolen, um den Stil zu ändern';
	@override String get textStyleSyntax => '**Fetter Text**\n*Kursiver Text*\n~~Durchgestrichener Text~~\n`Code-Text`';
	@override String get quote => 'Zitat';
	@override String get quoteDescription => 'Verwenden Sie das Symbol >, um ein Zitat zu erstellen, mehrere > für ein mehrstufiges Zitat';
	@override String get quoteSyntax => '> Dies ist ein Zitat der ersten Ebene\n>> Dies ist ein Zitat der zweiten Ebene';
	@override String get list => 'Liste';
	@override String get listDescription => 'Erstellen Sie eine geordnete Liste mit Zahl+Punkt und eine ungeordnete Liste mit -';
	@override String get listSyntax => '1. Erstes Element\n2. Zweites Element\n\n- Ungeordnetes Element\n  - Unterelement\n  - Weiteres Unterelement';
	@override String get linkAndImage => 'Link und Bild';
	@override String get linkAndImageDescription => 'Link-Format: [Text](URL)\nBild-Format: ![Beschreibung](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[Linktext](${link})\n![Bildbeschreibung](${imgUrl})';
	@override String get title => 'Titel';
	@override String get titleDescription => 'Verwenden Sie das Symbol #, um einen Titel zu erstellen, die Anzahl zeigt die Ebene an';
	@override String get titleSyntax => '# Titel der ersten Ebene\n## Titel der zweiten Ebene\n### Titel der dritten Ebene';
	@override String get separator => 'Trennlinie';
	@override String get separatorDescription => 'Erstellen Sie eine Trennlinie mit drei oder mehr -Symbolen';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Syntax';
}

// Path: forum
class _TranslationsForumDe extends TranslationsForumEn {
	_TranslationsForumDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get attachQuote => 'Zitat anhängen';
	@override String replyToFloor({required Object floor, required Object username}) => 'Antwort auf #${floor} @${username}';
	@override String get removeQuote => 'Zitat entfernen';
	@override String get recent => 'Neueste';
	@override String get category => 'Kategorie';
	@override String get lastReply => 'Letzte Antwort';
	@override late final _TranslationsForumSitewideDe sitewide = _TranslationsForumSitewideDe._(_root);
	@override late final _TranslationsForumErrorsDe errors = _TranslationsForumErrorsDe._(_root);
	@override String get createPost => 'Beitrag erstellen';
	@override String get title => 'Titel';
	@override String get enterTitle => 'Titel eingeben';
	@override String get content => 'Inhalt';
	@override String get enterContent => 'Inhalt eingeben';
	@override String get writeYourContentHere => 'Schreiben Sie hier Ihren Inhalt…';
	@override String get posts => 'Beiträge';
	@override String get threads => 'Themen';
	@override String get forum => 'Forum';
	@override String get createThread => 'Thema erstellen';
	@override String get selectCategory => 'Kategorie auswählen';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Verbleibende Sperrzeit ${minutes} Minuten ${seconds} Sekunden';
	@override late final _TranslationsForumGroupsDe groups = _TranslationsForumGroupsDe._(_root);
	@override late final _TranslationsForumLeafNamesDe leafNames = _TranslationsForumLeafNamesDe._(_root);
	@override late final _TranslationsForumLeafDescriptionsDe leafDescriptions = _TranslationsForumLeafDescriptionsDe._(_root);
	@override String get reply => 'Antworten';
	@override String get pendingReview => 'Ausstehende Prüfung';
	@override String get floorNotFound => 'Dieser Beitrag existiert nicht mehr';
	@override String get floorNotLoadedYet => 'Dieser Beitrag liegt weiter oben — lade mehr Antworten, um dorthin zu springen';
	@override String get editedAt => 'Bearbeitet am';
	@override String get copySuccess => 'In die Zwischenablage kopiert';
	@override String copySuccessForMessage({required Object str}) => 'In die Zwischenablage kopiert: ${str}';
	@override String get editReply => 'Antwort bearbeiten';
	@override String get editTitle => 'Titel bearbeiten';
	@override String get submit => 'Absenden';
}

// Path: notifications
class _TranslationsNotificationsDe extends TranslationsNotificationsEn {
	_TranslationsNotificationsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsDe errors = _TranslationsNotificationsErrorsDe._(_root);
	@override String get notifications => 'Benachrichtigungen';
	@override String get profile => 'Profil';
	@override String get postedNewComment => 'Neuer Kommentar veröffentlicht';
	@override String get inYour => 'In Ihrem';
	@override String get video => 'Video';
	@override String get repliedYourVideoComment => 'Hat auf Ihren Videokommentar geantwortet';
	@override String get copyInfoToClipboard => 'Benachrichtigungsinfo in die Zwischenablage kopieren';
	@override String get copySuccess => 'In die Zwischenablage kopiert';
	@override String copySuccessForMessage({required Object str}) => 'In die Zwischenablage kopiert: ${str}';
	@override String get markAllAsRead => 'Alle als gelesen markieren';
	@override String get markAllAsReadSuccess => 'Alle Benachrichtigungen wurden als gelesen markiert';
	@override String get markAllAsReadFailed => 'Alle als gelesen markieren fehlgeschlagen';
	@override String get markSelectedAsRead => 'Ausgewählte als gelesen markieren';
	@override String get markSelectedAsReadSuccess => 'Ausgewählte Benachrichtigungen wurden als gelesen markiert';
	@override String get markSelectedAsReadFailed => 'Ausgewählte als gelesen markieren fehlgeschlagen';
	@override String get markAsRead => 'Als gelesen markieren';
	@override String get markAsReadSuccess => 'Benachrichtigung wurde als gelesen markiert';
	@override String get markAsReadFailed => 'Benachrichtigung als gelesen markieren fehlgeschlagen';
	@override String get notificationTypeHelp => 'Hilfe zu Benachrichtigungstypen';
	@override String get dueToLackOfNotificationTypeDetails => 'Da Details zum Benachrichtigungstyp fehlen, decken die unterstützten Typen möglicherweise nicht die Nachrichten ab, die Sie derzeit erhalten';
	@override String get helpUsImproveNotificationTypeSupport => 'Wenn Sie uns helfen möchten, die Unterstützung für Benachrichtigungstypen zu verbessern';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Kopieren Sie die Benachrichtigungsinformationen\n2. 🐞 Reichen Sie ein Issue im Projekt-Repository ein\n\n⚠️ Hinweis: Benachrichtigungsinformationen können persönliche Privatsphäre enthalten. Wenn Sie sie nicht veröffentlichen möchten, können Sie sie auch per E-Mail an den Projektautor senden.';
	@override String get goToRepository => 'Zum Repository';
	@override String get copy => 'Kopieren';
	@override String get commentApproved => 'Kommentar genehmigt';
	@override String get repliedYourProfileComment => 'Hat auf Ihren Profilkommentar geantwortet';
	@override String get kReplied => 'hat auf Ihren Kommentar geantwortet zu';
	@override String get kCommented => 'hat kommentiert in Ihrem';
	@override String get kVideo => 'Video';
	@override String get kGallery => 'Galerie';
	@override String get kProfile => 'Profil';
	@override String get kThread => 'Thread';
	@override String get kPost => 'Beitrag';
	@override String get kCommentSection => 'Kommentarbereich';
	@override String get kApprovedComment => 'Kommentar genehmigt';
	@override String get kApprovedVideo => 'Video genehmigt';
	@override String get kApprovedGallery => 'Galerie genehmigt';
	@override String get kApprovedThread => 'Thread genehmigt';
	@override String get kApprovedPost => 'Beitrag genehmigt';
	@override String get kApprovedForumPost => 'Forumsbeitrag genehmigt';
	@override String get kRejectedContent => 'Inhaltsprüfung abgelehnt';
	@override String get kUnknownType => 'Unbekannter Benachrichtigungstyp';
}

// Path: conversation
class _TranslationsConversationDe extends TranslationsConversationEn {
	_TranslationsConversationDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsDe errors = _TranslationsConversationErrorsDe._(_root);
	@override String get conversation => 'Unterhaltung';
	@override String get startConversation => 'Unterhaltung starten';
	@override String get noConversation => 'Keine Unterhaltung';
	@override String get selectFromLeftListAndStartConversation => 'In der linken Liste auswählen und Unterhaltung starten';
	@override String get title => 'Titel';
	@override String get body => 'Text';
	@override String get selectAUser => 'Benutzer auswählen';
	@override String get searchUsers => 'Benutzer suchen…';
	@override String get tmpNoConversions => 'Keine Unterhaltungen';
	@override String get deleteThisMessage => 'Diese Nachricht löschen';
	@override String get deleteThisMessageSubtitle => 'Dieser Vorgang kann nicht rückgängig gemacht werden';
	@override String get writeMessageHere => 'Nachricht hier schreiben…';
	@override String get lastMessageFromMe => 'Sie: ';
	@override String get sendMessage => 'Nachricht senden';
}

// Path: splash
class _TranslationsSplashDe extends TranslationsSplashEn {
	_TranslationsSplashDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsDe errors = _TranslationsSplashErrorsDe._(_root);
	@override String get preparing => 'Wird vorbereitet...';
	@override String get initializing => 'Wird initialisiert...';
	@override String get loading => 'Wird geladen...';
	@override String get ready => 'Bereit';
	@override String get initializingMessageService => 'Nachrichtendienst wird initialisiert...';
}

// Path: download
class _TranslationsDownloadDe extends TranslationsDownloadEn {
	_TranslationsDownloadDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsDe errors = _TranslationsDownloadErrorsDe._(_root);
	@override String get downloadList => 'Download-Liste';
	@override String get viewDownloadList => 'Download-Liste anzeigen';
	@override String get download => 'Herunterladen';
	@override String get selectDownloadTitle => 'Download auswählen';
	@override String get qualitySectionLabel => 'Qualität';
	@override String get categorySectionLabel => 'Kategorie';
	@override String get saveToPreviewLabel => 'Wird gespeichert unter';
	@override String saveToPreviewSuggested({required Object name}) => 'Vorgeschlagener Dateiname: ${name} (im Systemdialog änderbar)';
	@override String get lastUsedBadge => 'Zuletzt verwendet';
	@override String get pickedBadge => 'Ausgewählt';
	@override String get startDownloading => 'Download starten';
	@override String get clearAllFailedTasks => 'Alle fehlgeschlagenen Aufgaben löschen';
	@override String get clearAllFailedTasksConfirmation => 'Möchten Sie wirklich alle fehlgeschlagenen Download-Aufgaben löschen? Die Dateien dieser Aufgaben werden ebenfalls gelöscht.';
	@override String get clearAllFailedTasksSuccess => 'Alle fehlgeschlagenen Aufgaben gelöscht';
	@override String get clearAllFailedTasksError => 'Beim Löschen der fehlgeschlagenen Aufgaben ist ein Fehler aufgetreten';
	@override String get downloadStatus => 'Download-Status';
	@override String get imageList => 'Bildliste';
	@override String get retryDownload => 'Download erneut versuchen';
	@override String get notDownloaded => 'Nicht heruntergeladen';
	@override String get downloaded => 'Heruntergeladen';
	@override String get waitingForDownload => 'Wartet auf Download';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Wird heruntergeladen (${downloaded}/${total} Bilder ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Wird heruntergeladen (${downloaded} Bilder)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Pausiert (${downloaded}/${total} Bilder ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'Pausiert (${downloaded} Bilder)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Heruntergeladen (insgesamt ${total} Bilder)';
	@override String get viewVideoDetail => 'Videodetails anzeigen';
	@override String get viewGalleryDetail => 'Galeriedetails anzeigen';
	@override String get moreOptions => 'Weitere Optionen';
	@override String get openFile => 'Datei öffnen';
	@override String get playLocally => 'Lokal abspielen';
	@override String get pause => 'Pausieren';
	@override String get resume => 'Fortsetzen';
	@override String get copyDownloadUrl => 'Download-URL kopieren';
	@override String get showInFolder => 'Im Ordner anzeigen';
	@override String get deleteTask => 'Aufgabe löschen';
	@override String get deleteTaskConfirmation => 'Möchten Sie diese Download-Aufgabe wirklich löschen?\nDie Datei der Aufgabe wird ebenfalls gelöscht.';
	@override String get forceDeleteTask => 'Aufgabe zwangsweise löschen';
	@override String get forceDeleteTaskConfirmation => 'Möchten Sie diese Download-Aufgabe wirklich zwangsweise löschen?\nDie Datei der Aufgabe wird ebenfalls gelöscht, auch wenn sie gerade verwendet wird.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Wird heruntergeladen ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Wird heruntergeladen ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Pausiert ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'Pausiert • Heruntergeladen ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Heruntergeladen • ${size}';
	@override String get copyDownloadUrlSuccess => 'Download-URL kopiert';
	@override String totalImageNums({required Object num}) => '${num} Bilder';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Wird heruntergeladen ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'Wird heruntergeladen';
	@override String get failed => 'Fehlgeschlagen';
	@override String get completed => 'Abgeschlossen';
	@override String get downloadDetail => 'Download-Details';
	@override String get copy => 'Kopieren';
	@override String get copySuccess => 'Kopiert';
	@override String get waiting => 'Wartend';
	@override String get paused => 'Pausiert';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Wird heruntergeladen ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Galerie-Download abgeschlossen: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Download abgeschlossen: ${fileName}';
	@override String get searchTasks => 'Aufgaben suchen…';
	@override String statusLabel({required Object label}) => 'Status: ${label}';
	@override String get allStatus => 'Alle Status';
	@override String typeLabel({required Object label}) => 'Typ: ${label}';
	@override String get allTypes => 'Alle Typen';
	@override String get taskType => 'Typ';
	@override String get video => 'Video';
	@override String get gallery => 'Galerie';
	@override String get other => 'Sonstiges';
	@override String get clearFilters => 'Filter zurücksetzen';
	@override String get pauseAll => 'Alle pausieren';
	@override String get resumeAll => 'Alle starten';
	@override String remainingTime({required Object time}) => 'noch ${time}';
	@override late final _TranslationsDownloadTimelineDe timeline = _TranslationsDownloadTimelineDe._(_root);
	@override late final _TranslationsDownloadErrorTypesDe errorTypes = _TranslationsDownloadErrorTypesDe._(_root);
	@override String get errorDetailCopied => 'Fehlerdetails kopiert';
	@override String get errorDetailCopyHint => 'Lange drücken, um Fehlerdetails zu kopieren';
	@override late final _TranslationsDownloadRestoredPausedDe restoredPaused = _TranslationsDownloadRestoredPausedDe._(_root);
	@override late final _TranslationsDownloadActionsDe actions = _TranslationsDownloadActionsDe._(_root);
	@override late final _TranslationsDownloadNoticeDe notice = _TranslationsDownloadNoticeDe._(_root);
	@override String get emptyTaskList => 'Noch keine Download-Aufgaben';
	@override String get noMatchingTasks => 'Keine passenden Aufgaben';
	@override late final _TranslationsDownloadDeleteByDateDe deleteByDate = _TranslationsDownloadDeleteByDateDe._(_root);
	@override late final _TranslationsDownloadRelocationDe relocation = _TranslationsDownloadRelocationDe._(_root);
	@override late final _TranslationsDownloadCategoryDe category = _TranslationsDownloadCategoryDe._(_root);
	@override late final _TranslationsDownloadLocationDe location = _TranslationsDownloadLocationDe._(_root);
	@override String get maxConcurrentDownloads => 'Max. gleichzeitige Downloads';
	@override String get maxConcurrentDownloadsDesc => 'Anzahl der gleichzeitig herunterladenden Aufgaben (1-5)';
	@override String get stillInDevelopment => 'Noch in Entwicklung';
	@override String get saveToAppDirectory => 'Im App-Verzeichnis speichern';
	@override String get alreadyDownloadedWithQuality => 'Bereits in der gleichen Qualität heruntergeladen. Möchten Sie den Download fortsetzen?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Bereits in den Qualitätsstufen heruntergeladen: ${qualities}. Möchten Sie den Download fortsetzen?';
	@override String get otherQualities => 'Andere Qualitäten';
	@override late final _TranslationsDownloadBatchDownloadDe batchDownload = _TranslationsDownloadBatchDownloadDe._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsDe extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Download abgeschlossen';
	@override String get failedTitle => 'Download fehlgeschlagen';
	@override String completedBody({required Object name}) => '${name} wurde erfolgreich heruntergeladen';
	@override String failedBody({required Object name}) => '${name} konnte nicht heruntergeladen werden';
	@override String completedToast({required Object name}) => '${name} heruntergeladen';
	@override String failedToast({required Object name}) => 'Download von ${name} fehlgeschlagen';
	@override String savedToFolder({required Object dir}) => 'Gespeichert unter ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Gespeichert als ${name} (gleichnamige Datei existierte bereits)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Im App-Ordner gespeichert — Schreiben nach ${target} nicht möglich (${reason})';
	@override String get viewFolder => 'Ordner anzeigen';
	@override String get fixInSettings => 'In den Einstellungen beheben';
	@override String get channelName => 'Download-Status';
	@override String get channelDescription => 'Benachrichtigungen für abgeschlossene und fehlgeschlagene Downloads';
}

// Path: favorite
class _TranslationsFavoriteDe extends TranslationsFavoriteEn {
	_TranslationsFavoriteDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsDe errors = _TranslationsFavoriteErrorsDe._(_root);
	@override String get add => 'Hinzufügen';
	@override String get addSuccess => 'Erfolgreich hinzugefügt';
	@override String get addFailed => 'Hinzufügen fehlgeschlagen';
	@override String get remove => 'Entfernen';
	@override String get removeSuccess => 'Erfolgreich entfernt';
	@override String get removeFailed => 'Entfernen fehlgeschlagen';
	@override String get removeConfirmation => 'Möchten Sie dieses Element wirklich aus den Favoriten entfernen?';
	@override String get removeConfirmationSuccess => 'Element aus den Favoriten entfernt';
	@override String get removeConfirmationFailed => 'Element konnte nicht aus den Favoriten entfernt werden';
	@override String get createFolderSuccess => 'Ordner erfolgreich erstellt';
	@override String get createFolderFailed => 'Ordner konnte nicht erstellt werden';
	@override String get createFolder => 'Ordner erstellen';
	@override String get enterFolderName => 'Ordnernamen eingeben';
	@override String get enterFolderNameHere => 'Ordnernamen hier eingeben…';
	@override String get create => 'Erstellen';
	@override String get items => 'Elemente';
	@override String get newFolderName => 'Neuer Ordner';
	@override String get searchFolders => 'Ordner suchen…';
	@override String get searchItems => 'Elemente suchen…';
	@override String get createdAt => 'Erstellt am';
	@override String get myFavorites => 'Meine Favoriten';
	@override String get deleteFolderTitle => 'Ordner löschen';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'Möchten Sie den Ordner ${title} wirklich löschen?';
	@override String get removeItemTitle => 'Element entfernen';
	@override String removeItemConfirmWithTitle({required Object title}) => 'Möchten Sie das Element ${title} wirklich löschen?';
	@override String get removeItemSuccess => 'Element aus den Favoriten entfernt';
	@override String get removeItemFailed => 'Element konnte nicht aus den Favoriten entfernt werden';
	@override String get localizeFavorite => 'Lokale Favoriten';
	@override String get editFolderTitle => 'Ordner bearbeiten';
	@override String get editFolderSuccess => 'Ordner erfolgreich aktualisiert';
	@override String get editFolderFailed => 'Ordner konnte nicht aktualisiert werden';
	@override String get searchTags => 'Tags suchen';
	@override String get noTagsInFolder => 'Noch keine Tags an den Elementen in diesem Ordner';
	@override String get tagFilterMatchAll => 'Zeigt nur Elemente, die alle ausgewählten Tags tragen';
	@override String get clearSelectedTags => 'Ausgewählte Tags zurücksetzen';
	@override String selectedTagCount({required Object count}) => '${count} ausgewählt';
	@override String get noMatchingTags => 'Keine passenden Tags';
}

// Path: translation
class _TranslationsTranslationDe extends TranslationsTranslationEn {
	_TranslationsTranslationDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Aktueller Dienst';
	@override String get testConnection => 'Verbindung testen';
	@override String get testConnectionSuccess => 'Verbindungstest erfolgreich';
	@override String get testConnectionFailed => 'Verbindungstest fehlgeschlagen';
	@override String testConnectionFailedWithMessage({required Object message}) => 'Verbindungstest fehlgeschlagen: ${message}';
	@override String get translation => 'Übersetzung';
	@override String get needVerification => 'Verifizierung erforderlich';
	@override String get needVerificationContent => 'Bitte testen Sie zuerst die Verbindung, bevor Sie die KI-Übersetzung aktivieren';
	@override String get confirm => 'Bestätigen';
	@override String get disclaimer => 'Haftungsausschluss';
	@override String get riskWarning => 'Risikowarnung';
	@override String get dureToRisk1 => 'Da der Text von Nutzern erstellt wird, kann er Inhalte enthalten, die gegen die Inhaltsrichtlinien des KI-Dienstanbieters verstoßen';
	@override String get dureToRisk2 => 'Unangemessene Inhalte können zur Sperrung des API-Schlüssels oder zur Beendigung des Dienstes führen';
	@override String get operationSuggestion => 'Bedienhinweis';
	@override String get operationSuggestion1 => '1. Vor der strengen Prüfung der zu übersetzenden Inhalte verwenden';
	@override String get operationSuggestion2 => '2. Vermeiden Sie die Übersetzung von Inhalten mit Gewalt, sexuellen Inhalten usw.';
	@override String get apiConfig => 'API-Konfiguration';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Das Ändern der Konfiguration schließt die KI-Übersetzung automatisch; nach dem Aktivieren muss erneut getestet werden';
	@override String get apiAddress => 'API-Adresse';
	@override String get modelName => 'Modellname';
	@override String get modelNameHintText => 'Zum Beispiel: gpt-4-turbo';
	@override String get maxTokens => 'Max. Tokens';
	@override String get maxTokensHintText => 'Zum Beispiel: 32000';
	@override String get temperature => 'Temperatur';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Klicken Sie auf die Testschaltfläche, um die Gültigkeit der API-Verbindung zu prüfen';
	@override String get requestPreview => 'Anfragevorschau';
	@override String get enableAITranslation => 'KI aktivieren';
	@override String get enabled => 'Aktiviert';
	@override String get disabled => 'Deaktiviert';
	@override String get testing => 'Wird getestet...';
	@override String get testNow => 'Jetzt testen';
	@override String get connectionStatus => 'Verbindungsstatus';
	@override String get success => 'Erfolg';
	@override String get failed => 'Fehlgeschlagen';
	@override String get information => 'Information';
	@override String get viewRawResponse => 'Rohantwort anzeigen';
	@override String get pleaseCheckInputParametersFormat => 'Bitte überprüfen Sie das Format der Eingabeparameter';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Bitte API-Adresse, Modellname und Schlüssel ausfüllen';
	@override String get pleaseFillInValidConfigurationParameters => 'Bitte gültige Konfigurationsparameter ausfüllen';
	@override String get pleaseCompleteConnectionTest => 'Bitte schließen Sie den Verbindungstest ab';
	@override String get notConfigured => 'Nicht konfiguriert';
	@override String get apiEndpoint => 'API-Endpunkt';
	@override String get configuredKey => 'Konfigurierter Schlüssel';
	@override String get notConfiguredKey => 'Nicht konfigurierter Schlüssel';
	@override String get authenticationStatus => 'Authentifizierungsstatus';
	@override String get thisFieldCannotBeEmpty => 'Dieses Feld darf nicht leer sein';
	@override String get apiKey => 'API-Schlüssel';
	@override String get apiKeyCannotBeEmpty => 'Der API-Schlüssel darf nicht leer sein';
	@override String get pleaseEnterValidNumber => 'Bitte eine gültige Zahl eingeben';
	@override String get range => 'Bereich';
	@override String get mustBeGreaterThan => 'Muss größer sein als';
	@override String get invalidAPIResponse => 'Ungültige API-Antwort';
	@override String connectionFailedForMessage({required Object message}) => 'Verbindung fehlgeschlagen: ${message}';
	@override String get aiTranslationNotEnabledHint => 'KI-Übersetzung ist nicht aktiviert, bitte aktivieren Sie sie in den Einstellungen';
	@override String get goToSettings => 'Zu den Einstellungen';
	@override String get disableAITranslation => 'KI-Übersetzung deaktivieren';
	@override String get currentValue => 'Aktueller Wert';
	@override String get configureTranslationStrategy => 'Übersetzungsstrategie konfigurieren';
	@override String get advancedSettings => 'Erweiterte Einstellungen';
	@override String get translationPrompt => 'Übersetzungs-Prompt';
	@override String get promptHint => 'Bitte geben Sie den Übersetzungs-Prompt ein und verwenden Sie [TL] als Platzhalter für die Zielsprache';
	@override String get promptHelperText => 'Der Prompt muss [TL] als Platzhalter für die Zielsprache enthalten';
	@override String get promptMustContainTargetLang => 'Der Prompt muss den Platzhalter [TL] enthalten';
	@override String get aiTranslationWillBeDisabled => 'KI-Übersetzung wird deaktiviert';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'Aufgrund einer Änderung der Basiskonfiguration wird die KI-Übersetzung deaktiviert';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'Aufgrund einer Änderung des Übersetzungs-Prompts wird die KI-Übersetzung deaktiviert';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'Aufgrund einer Änderung der Parameterkonfiguration wird die KI-Übersetzung deaktiviert';
	@override String get onlyOpenAIAPISupported => 'Derzeit wird nur das OpenAI-kompatible API-Format unterstützt (Anfragetext im Format application/json)';
	@override String get streamingTranslation => 'Streaming-Übersetzung';
	@override String get streamingTranslationSupported => 'Streaming-Übersetzung wird unterstützt';
	@override String get streamingTranslationNotSupported => 'Streaming-Übersetzung wird nicht unterstützt';
	@override String get streamingTranslationDescription => 'Die Streaming-Übersetzung kann Ergebnisse während des Übersetzungsvorgangs in Echtzeit anzeigen und bietet so ein besseres Nutzererlebnis';
	@override String get usingFullUrlWithHash => 'Vollständige URL verwenden (endet mit #)';
	@override String get baseUrlInputHelperText => 'Bei einem abschließenden # wird es als tatsächliche Anfrageadresse verwendet';
	@override String currentActualUrl({required Object url}) => 'Aktuelle tatsächliche URL: ${url}';
	@override String get urlEndingWithHashTip => 'Eine URL mit abschließendem # wird direkt verwendet, ohne einen Suffix anzuhängen';
	@override String get streamingTranslationWarning => 'Hinweis: Diese Funktion erfordert, dass der API-Dienst Streaming-Übertragung unterstützt; einige Modelle unterstützen dies möglicherweise nicht';
	@override String get translationService => 'Übersetzungsdienst';
	@override String get translationServiceDescription => 'Wählen Sie Ihren bevorzugten Übersetzungsdienst';
	@override String get googleTranslation => 'Google-Übersetzung';
	@override String get googleTranslationDescription => 'Kostenloser Online-Übersetzungsdienst, der mehrere Sprachen unterstützt';
	@override String get aiTranslation => 'KI-Übersetzung';
	@override String get aiTranslationDescription => 'Intelligenter Übersetzungsdienst auf Basis großer Sprachmodelle';
	@override String get deeplxTranslation => 'DeepLX-Übersetzung';
	@override String get deeplxTranslationDescription => 'Open-Source-Implementierung der DeepL-Übersetzung mit qualitativ hochwertiger Übersetzung';
	@override String get googleTranslationFeatures => 'Funktionen';
	@override String get freeToUse => 'Kostenlos nutzbar';
	@override String get freeToUseDescription => 'Keine Konfiguration erforderlich, sofort einsatzbereit';
	@override String get fastResponse => 'Schnelle Antwort';
	@override String get fastResponseDescription => 'Schnelle Übersetzungsgeschwindigkeit mit geringer Latenz';
	@override String get stableAndReliable => 'Stabil und zuverlässig';
	@override String get stableAndReliableDescription => 'Basierend auf der offiziellen Google-API';
	@override String get enabledDefaultService => 'Aktiviert – Standard-Übersetzungsdienst';
	@override String get notEnabled => 'Nicht aktiviert';
	@override String get deeplxTranslationService => 'DeepLX-Übersetzungsdienst';
	@override String get deeplxDescription => 'DeepLX ist eine Open-Source-Implementierung der DeepL-Übersetzung und unterstützt die Endpunktmodi Free, Pro und Official';
	@override String get serverAddress => 'Serveradresse';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Basisadresse des DeepLX-Servers';
	@override String get endpointType => 'Endpunkttyp';
	@override String get freeEndpoint => 'Free – kostenloser Endpunkt, ggf. mit Ratenlimits';
	@override String get proEndpoint => 'Pro – erfordert dl_session, stabiler';
	@override String get officialEndpoint => 'Official – offizielles API-Format';
	@override String get finalRequestUrl => 'Endgültige Anfrage-URL';
	@override String get apiKeyOptional => 'API-Schlüssel (optional)';
	@override String get apiKeyOptionalHint => 'Für den Zugriff auf geschützte DeepLX-Dienste';
	@override String get apiKeyOptionalHelperText => 'Einige DeepLX-Dienste erfordern zur Authentifizierung einen API-Schlüssel';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Für den Pro-Modus erforderlicher dl_session-Parameter';
	@override String get dlSessionHelperText => 'Für den Pro-Endpunkt erforderlicher Sitzungsparameter, erhalten aus dem DeepL-Pro-Konto';
	@override String get proModeRequiresDlSession => 'Der Pro-Modus erfordert dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Klicken Sie auf die Testschaltfläche, um die DeepLX-API-Verbindung zu prüfen';
	@override String get enableDeepLXTranslation => 'DeepLX-Übersetzung aktivieren';
	@override String get deepLXTranslationWillBeDisabled => 'Die DeepLX-Übersetzung wird aufgrund von Konfigurationsänderungen deaktiviert';
	@override String get translatedResult => 'Übersetztes Ergebnis';
	@override String get testSuccess => 'Test erfolgreich';
	@override String get pleaseFillInDeepLXServerAddress => 'Bitte die DeepLX-Serveradresse ausfüllen';
	@override String get invalidAPIResponseFormat => 'Ungültiges API-Antwortformat';
	@override String get translationServiceReturnedError => 'Der Übersetzungsdienst hat einen Fehler oder ein leeres Ergebnis zurückgegeben';
	@override String get connectionFailed => 'Verbindung fehlgeschlagen';
	@override String get translationFailed => 'Übersetzung fehlgeschlagen';
	@override String get aiTranslationFailed => 'KI-Übersetzung fehlgeschlagen';
	@override String get deeplxTranslationFailed => 'DeepLX-Übersetzung fehlgeschlagen';
	@override String get aiTranslationTestFailed => 'Test der KI-Übersetzung fehlgeschlagen';
	@override String get deeplxTranslationTestFailed => 'Test der DeepLX-Übersetzung fehlgeschlagen';
	@override String get streamingTranslationTimeout => 'Zeitüberschreitung der Streaming-Übersetzung, Ressourcenbereinigung wird erzwungen';
	@override String get translationRequestTimeout => 'Zeitüberschreitung der Übersetzungsanfrage';
	@override String get streamingTranslationDataTimeout => 'Zeitüberschreitung beim Empfang der Streaming-Übersetzungsdaten';
	@override String get dataReceptionTimeout => 'Zeitüberschreitung beim Datenempfang';
	@override String get streamDataParseError => 'Fehler beim Analysieren der Stream-Daten';
	@override String get streamingTranslationFailed => 'Streaming-Übersetzung fehlgeschlagen';
	@override String get fallbackTranslationFailed => 'Rückfall auf die normale Übersetzung ist ebenfalls fehlgeschlagen';
	@override String get translationSettings => 'Übersetzungseinstellungen';
	@override String get enableGoogleTranslation => 'Google-Übersetzung aktivieren';
	@override String get thinking => 'Denkt nach...';
	@override String get thoughtProcess => 'Denkprozess';
	@override String get modelCompatibility => 'Modellkompatibilität';
	@override String get modelCompatibilityDescription => 'Anfrageparameter für moderne Modelle wie Reasoning-Modelle (o1/o3, DeepSeek-R1, QwQ) anpassen';
	@override String get reasoningModel => 'Reasoning-Modell';
	@override String get reasoningModelDescription => 'Für o1/o3, DeepSeek-R1, QwQ usw. Faltet den Prompt in die Benutzernachricht, lässt temperature weg und verwendet max_completion_tokens';
	@override String get useMaxCompletionTokens => 'max_completion_tokens verwenden';
	@override String get useMaxCompletionTokensDescription => 'Neuere OpenAI-Endpunkte erfordern max_completion_tokens anstelle des veralteten max_tokens';
	@override String get sendTemperature => 'Temperature senden';
	@override String get sendTemperatureDescription => 'Für Modelle deaktivieren, die den Parameter temperature ablehnen (die meisten Reasoning-Modelle)';
	@override String get showReasoningProcess => 'Denkprozess anzeigen';
	@override String get showReasoningProcessDescription => 'Das einklappbare Reasoning von Reasoning-Modellen im Übersetzungsdialog anzeigen';
	@override String get provider => 'Anbieter';
	@override String get providerOpenAI => 'OpenAI (und kompatibel)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Unterstützt OpenAI (und jeden OpenAI-kompatiblen Endpunkt), Anthropic und Google über das dartantic_ai SDK';
	@override String get baseUrlOptionalHelperText => 'Optional. Leer lassen, um den Standardendpunkt des Anbieters zu verwenden; ausfüllen für OpenAI-kompatible/Relay-Endpunkte';
	@override String get defaultEndpoint => 'Standardendpunkt';
	@override String get providerPreset => 'Anbieter-Voreinstellung';
	@override String get selectProviderPreset => 'Voreinstellung auswählen';
	@override String get presetCustom => 'Benutzerdefiniert';
	@override String presetApplied({required Object name}) => 'Voreinstellung angewendet: ${name}';
	@override late final _TranslationsTranslationPresetNamesDe presetNames = _TranslationsTranslationPresetNamesDe._(_root);
	@override String get fetchModelList => 'Modellliste abrufen';
	@override String get fetchingModels => 'Wird abgerufen...';
	@override String get selectModel => 'Modell auswählen';
	@override String get searchModel => 'Modell suchen';
	@override String get noModelsFound => 'Keine Modelle gefunden';
}

// Path: bottomNav
class _TranslationsBottomNavDe extends TranslationsBottomNavEn {
	_TranslationsBottomNavDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get video => 'Video';
	@override String get gallery => 'Galerie';
	@override String get subscription => 'Feed';
	@override String get community => 'Forum';
	@override String get localMedia => 'Lokal';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsDe extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Navigationsreihenfolge';
	@override String get customNavigationOrder => 'Benutzerdefinierte Navigationsreihenfolge';
	@override String get customNavigationOrderDesc => 'Ziehen Sie, um die Anzeigereihenfolge der Seiten in der unteren Navigationsleiste und der Seitenleiste anzupassen';
	@override String get restartRequired => 'Neustart der App erforderlich';
	@override String get navigationItemSorting => 'Sortierung der Navigationselemente';
	@override String get done => 'Fertig';
	@override String get edit => 'Bearbeiten';
	@override String get reset => 'Zurücksetzen';
	@override String get previewEffect => 'Vorschau der Wirkung';
	@override String get bottomNavigationPreview => 'Vorschau der unteren Navigation:';
	@override String get sidebarPreview => 'Vorschau der Seitenleiste:';
	@override String get confirmResetNavigationOrder => 'Zurücksetzen der Navigationsreihenfolge bestätigen';
	@override String get confirmResetNavigationOrderDesc => 'Möchten Sie die Navigationsreihenfolge wirklich auf die Standardeinstellungen zurücksetzen?';
	@override String get cancel => 'Abbrechen';
	@override String get show => 'Anzeigen';
	@override String get hide => 'Ausblenden';
	@override String get hidden => 'Ausgeblendet';
	@override String get hideHint => 'Tippen Sie auf das Augensymbol, um Community und lokale Dateien ein- oder auszublenden';
	@override String get videoDescription => 'Beliebte Videoinhalte durchsuchen';
	@override String get galleryDescription => 'Bilder und Galerien durchsuchen';
	@override String get subscriptionDescription => 'Neueste Inhalte von gefolgten Benutzern ansehen';
	@override String get forumDescription => 'An Community-Diskussionen teilnehmen';
	@override String get newsDescription => 'Offizielle Neuigkeiten, Artikel und Ankündigungen durchsuchen';
	@override String get communityDescription => 'Forumdiskussionen sowie offizielle Neuigkeiten, Artikel und Ankündigungen';
	@override String get localMediaDescription => 'Auf diesem Gerät gespeicherte Videos und Bilder durchsuchen';
}

// Path: news
class _TranslationsNewsDe extends TranslationsNewsEn {
	_TranslationsNewsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Neuigkeiten';
	@override String get newsUpdates => 'Neuigkeiten';
	@override String get articles => 'Artikel';
	@override String get broadcast => 'Übertragung';
	@override String get openInBrowser => 'Im Browser öffnen';
}

// Path: displaySettings
class _TranslationsDisplaySettingsDe extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Anzeige-Einstellungen';
	@override String get layoutSettings => 'Layout-Einstellungen';
	@override String get layoutSettingsDesc => 'Spaltenanzahl und Haltepunkte anpassen';
	@override String get gridLayout => 'Raster-Layout';
	@override String get navigationOrderSettings => 'Navigationsreihenfolge';
	@override String get customNavigationOrder => 'Benutzerdefinierte Navigationsreihenfolge';
	@override String get customNavigationOrderDesc => 'Passen Sie die Anzeigereihenfolge der Seiten in der unteren Navigationsleiste und der Seitenleiste an';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsDe extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Layout-Einstellungen';
	@override String get descriptionTitle => 'Beschreibung der Layout-Konfiguration';
	@override String get descriptionContent => 'Die Konfiguration hier bestimmt die Anzahl der Spalten, die in den Video- und Galerielisten angezeigt werden. Sie können den automatischen Modus wählen, damit das System anhand der Bildschirmbreite automatisch anpasst, oder den manuellen Modus, um die Spaltenzahl festzulegen.';
	@override String get layoutMode => 'Layout-Modus';
	@override String get reset => 'Zurücksetzen';
	@override String get autoMode => 'Automatischer Modus';
	@override String get autoModeDesc => 'Automatisch anhand der Bildschirmbreite anpassen';
	@override String get manualMode => 'Manueller Modus';
	@override String get manualModeDesc => 'Feste Spaltenzahl verwenden';
	@override String get manualSettings => 'Manuelle Einstellungen';
	@override String get fixedColumns => 'Feste Spalten';
	@override String get columns => 'Spalten';
	@override String get breakpointConfig => 'Konfiguration der Haltepunkte';
	@override String get add => 'Hinzufügen';
	@override String get defaultColumns => 'Standardspalten';
	@override String get defaultColumnsDesc => 'Standardanzeige für große Bildschirme';
	@override String get previewEffect => 'Vorschau der Wirkung';
	@override String get screenWidth => 'Bildschirmbreite';
	@override String get addBreakpoint => 'Haltepunkt hinzufügen';
	@override String get editBreakpoint => 'Haltepunkt bearbeiten';
	@override String get deleteBreakpoint => 'Haltepunkt löschen';
	@override String get screenWidthLabel => 'Bildschirmbreite';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Spalten';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Bitte Breite eingeben';
	@override String get enterValidWidth => 'Bitte eine gültige Breite eingeben';
	@override String get widthCannotExceed9999 => 'Die Breite darf 9999 nicht überschreiten';
	@override String get breakpointAlreadyExists => 'Haltepunkt existiert bereits';
	@override String get enterColumns => 'Bitte Spaltenzahl eingeben';
	@override String get enterValidColumns => 'Bitte eine gültige Spaltenzahl eingeben';
	@override String get columnsCannotExceed12 => 'Die Spaltenzahl darf 12 nicht überschreiten';
	@override String get breakpointConflict => 'Haltepunkt existiert bereits';
	@override String get confirmResetLayoutSettings => 'Layout-Einstellungen zurücksetzen';
	@override String get confirmResetLayoutSettingsDesc => 'Möchten Sie alle Layout-Einstellungen wirklich auf die Standardwerte zurücksetzen?\n\nWird wiederhergestellt:\n• Automatischer Modus\n• Standard-Konfiguration der Haltepunkte';
	@override String get resetToDefaults => 'Auf Standard zurücksetzen';
	@override String get confirmDeleteBreakpoint => 'Haltepunkt löschen';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'Möchten Sie den Haltepunkt bei ${width}px wirklich löschen?';
	@override String get noCustomBreakpoints => 'Keine benutzerdefinierten Haltepunkte, es werden Standardspalten verwendet';
	@override String get breakpointRange => 'Haltepunktbereich';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Bearbeiten';
	@override String get delete => 'Löschen';
	@override String get cancel => 'Abbrechen';
	@override String get save => 'Speichern';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerDe extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Video-Player-Fehler';
	@override String get videoLoadFailed => 'Video konnte nicht geladen werden';
	@override String get videoCodecNotSupported => 'Videocodec nicht unterstützt';
	@override String get networkConnectionIssue => 'Problem mit der Netzwerkverbindung';
	@override String get insufficientPermission => 'Unzureichende Berechtigung';
	@override String get unsupportedVideoFormat => 'Nicht unterstütztes Videoformat';
	@override String get retry => 'Erneut versuchen';
	@override String get externalPlayer => 'Externer Player';
	@override String get detailedErrorInfo => 'Detaillierte Fehlerinformationen';
	@override String get format => 'Format';
	@override String get suggestion => 'Vorschlag';
	@override String get androidWebmCompatibilityIssue => 'Android-Geräte unterstützen das WEBM-Format nur eingeschränkt. Es wird empfohlen, einen externen Player zu verwenden oder eine Player-App herunterzuladen, die WEBM unterstützt';
	@override String get currentDeviceCodecNotSupported => 'Das aktuelle Gerät unterstützt den Codec für dieses Videoformat nicht';
	@override String get checkNetworkConnection => 'Bitte prüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut';
	@override String get appMayLackMediaPermission => 'Der App fehlen möglicherweise die erforderlichen Berechtigungen für die Medienwiedergabe';
	@override String get tryOtherVideoPlayer => 'Bitte versuchen Sie es mit anderen Video-Playern';
	@override String get unrecognizedVideoFormat => 'Nicht erkannte Videodatei';
	@override String get unrecognizedVideoFormatSuggestion => 'Der Link ist möglicherweise abgelaufen, oder die Antwort war kein Video. Versuchen Sie es erneut oder öffnen Sie es mit einer anderen App.';
	@override String get accessDenied => 'Der Server hat diese Anfrage abgelehnt (403)';
	@override String get accessDeniedSuggestion => 'Der Wiedergabelink ist höchstwahrscheinlich abgelaufen. Tippen Sie auf „Wiederholen“, um ihn erneut abzurufen, oder öffnen Sie ihn mit einer anderen App.';
	@override String get mute => 'Stummschalten';
	@override String get unmute => 'Stummschaltung aufheben';
	@override String get video => 'VIDEO';
	@override String get serverSelector => 'CDN-Server-Auswahl';
	@override String get serverSelectorDescription => 'Wählen Sie den Server mit der niedrigsten Latenz für das beste Wiedergabeerlebnis';
	@override String get retestSpeed => 'Geschwindigkeit erneut testen';
	@override String get waitingForSpeedTest => 'Warten auf Geschwindigkeitstest';
	@override String get testingSpeed => 'Geschwindigkeit wird getestet…';
	@override String get testFailed => 'Test fehlgeschlagen';
	@override String get loadingServerList => 'Serverliste wird geladen…';
	@override String get noAvailableServers => 'Keine verfügbaren Server';
	@override String get refreshServerList => 'Serverliste aktualisieren';
	@override String get cannotGetSource => 'Die aktuelle Videoquelle kann nicht abgerufen werden';
	@override String switchedToServer({required Object serverName}) => 'Zu Server gewechselt: ${serverName}';
	@override String serverCount({required Object count}) => 'Insgesamt ${count} Server';
	@override String statusCode({required Object code}) => 'Statuscode: ${code}';
	@override String get connectionFailed => 'Verbindung fehlgeschlagen';
	@override String get connectionTimeout => 'Verbindungszeitüberschreitung';
	@override String get networkError => 'Netzwerkfehler';
	@override String get sslError => 'SSL-Zertifikatsfehler';
	@override String get testCompleted => 'Test abgeschlossen';
	@override String get local => 'Lokal';
	@override String get unknown => 'Unbekannt';
	@override String get localVideoPathEmpty => 'Der lokale Videopfad ist leer';
	@override String localVideoFileNotExists({required Object path}) => 'Lokale Videodatei existiert nicht: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'Lokales Video kann nicht abgespielt werden: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Videodatei zum Abspielen hierher ziehen';
	@override String get supportedFormats => 'Unterstützte Formate: MP4, MKV, AVI, MOV, WEBM usw.';
	@override String get noSupportedVideoFile => 'Keine unterstützte Videodatei gefunden';
	@override String get retryingOpenVideoLink => 'Öffnen des Videolinks fehlgeschlagen, erneuter Versuch';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'Decoder konnte nicht geladen werden: ${event}. Versuchen Sie, in den Player-Einstellungen auf Software-Dekodierung umzuschalten, und rufen Sie die Seite erneut auf';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Fehler beim Laden des Videos: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Wiederholte Wiedergabefehler erkannt. Gehen Sie zu Einstellungen > Diagnose & Feedback, um Protokolle zu exportieren.';
	@override String get openSettingsAction => 'Anzeigen';
	@override late final _TranslationsMediaPlayerNoticeDe notice = _TranslationsMediaPlayerNoticeDe._(_root);
	@override String get imageLoadFailed => 'Bild konnte nicht geladen werden';
	@override String get unsupportedImageFormat => 'Nicht unterstütztes Bildformat';
	@override String get tryOtherViewer => 'Bitte versuchen Sie es mit anderen Betrachtern';
}

// Path: diagnostics
class _TranslationsDiagnosticsDe extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Diagnoseinformationen';
	@override String get appVersionLabel => 'App-Version';
	@override String memoryUsage({required Object memMB}) => 'Speicherverbrauch: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'Geräteinformationen konnten nicht abgerufen werden';
	@override String get secureStorageLabel => 'Sicherer Speicher';
	@override String get secureStorageHealthy => 'Verfügbar';
	@override String get secureStorageRecovered => 'Durch Zurücksetzen selbst geheilt (vorherige Daten gelöscht)';
	@override String get secureStorageUnavailable => 'Nicht verfügbar (Anmeldung mit Ersatzverschlüsselung gespeichert)';
	@override String get secureStoragePlatformOptOut => 'Lokale Verschlüsselung gemäß Plattformrichtlinie (auf macOS wird der Systemschlüsselbund nicht verwendet)';
	@override String get secureStorageDualWrite => ' (Dual-Write-Schutz aktiv)';
	@override String get schemaHealthLabel => 'Datenbankschema';
	@override String get schemaHealthOk => 'OK';
	@override String get schemaHealthRepairedNow => 'Bei diesem Start vom Sicherheitsnetz repariert (Migration hat nicht gegriffen)';
	@override String get schemaHealthRepairedBefore => 'Wurde zuvor vom Sicherheitsnetz repariert';
	@override String get logPolicySectionTitle => 'Protokollrichtlinie';
	@override String get configServiceUnavailable => 'Der Konfigurationsdienst ist nicht initialisiert. Die Protokollrichtlinie kann nicht angepasst werden.';
	@override String get enableLoggingTitle => 'Protokollierung aktivieren';
	@override String get enableLoggingSubtitle => 'Deaktivieren, um keine neuen Protokolle mehr zu schreiben';
	@override String get enableLogPersistenceTitle => 'Protokollpersistenz aktivieren';
	@override String get enableLogPersistenceSubtitle => 'Deaktivieren, um Protokolle nur im Speicher zu halten und Schreibvorgänge auf die Festplatte zu stoppen';
	@override String get minLogLevelTitle => 'Minimale Protokollstufe';
	@override String get minLogLevelSubtitle => 'Protokolle unterhalb dieser Stufe werden herausgefiltert';
	@override String get maxFileSizeTitle => 'Größenlimit für einzelne Datei';
	@override String get maxFileSizeSubtitle => 'Rotieren, wenn die Schwelle erreicht ist';
	@override String get rotatedFileCountTitle => 'Anzahl rotierter Hauptprotokolldateien';
	@override String get rotatedFileCountSubtitle => 'Anzahl der aufbewahrten Dateien ohne die aktuelle Datei';
	@override String get hangFileSizeTitle => 'Größenlimit des Hänger-Protokolls';
	@override String get hangFileSizeSubtitle => 'Wachstum der hang_events-Datei steuern';
	@override String get hangRotatedFileCountTitle => 'Anzahl rotierter Hänger-Protokolldateien';
	@override String get hangRotatedFileCountSubtitle => 'Anzahl der aufbewahrten Dateien für hang_events steuern';
	@override String get healthSectionTitle => 'Protokollzustand';
	@override String get refreshMetrics => 'Metriken aktualisieren';
	@override String get toolsSectionTitle => 'Werkzeuge';
	@override String get privacyNotice => 'Protokolle können sensible Informationen wie Kontodaten und Anfrageparameter enthalten. Veröffentlichen Sie keine vollständigen Protokolle in Issues; prüfen Sie sie zuerst und senden Sie sie per E-Mail.';
	@override String get exportLogsTitle => 'Protokolle exportieren';
	@override String get exportLogsSubtitle => 'Prüfen Sie die privaten Daten, bevor Sie sie an Entwickler senden';
	@override String get viewLogsTitle => 'Protokolle anzeigen';
	@override String get viewLogsSubtitle => 'Laufzeitprotokolle in Echtzeit anzeigen';
	@override String get copySupportEmailTitle => 'Support-E-Mail kopieren';
	@override String get reportIssueTitle => 'Problem melden';
	@override String get reportIssueSubtitle => 'Geben Sie Reproduktionsschritte auf GitHub an (hängen Sie keine vollständigen Protokolle an)';
	@override String get healthSummaryUnavailable => 'Noch keine Daten zum Protokollzustand';
	@override String get healthMetricsUnavailable => 'Zustandsmetriken wurden noch nicht erfasst';
	@override String get healthNoRiskIndicators => 'Keine Risikoindikatoren erkannt';
	@override late final _TranslationsDiagnosticsHealthAlertDe healthAlert = _TranslationsDiagnosticsHealthAlertDe._(_root);
	@override late final _TranslationsDiagnosticsToastDe toast = _TranslationsDiagnosticsToastDe._(_root);
	@override String get shareSubject => 'LoveIwara-Diagnoseprotokolle (enthält sensible Daten, mit Vorsicht teilen)';
}

// Path: logViewer
class _TranslationsLogViewerDe extends TranslationsLogViewerEn {
	_TranslationsLogViewerDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Protokollanzeige';
	@override String get searchHint => 'Protokolle durchsuchen…';
	@override String get emptyState => 'Keine Protokolle';
	@override String get copiedToClipboard => 'In die Zwischenablage kopiert';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogDe extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'App unerwartet beendet';
	@override String get description => 'In der letzten Sitzung wurde ein unsauberes Beenden festgestellt. Bitte exportieren Sie die Diagnoseprotokolle und senden Sie sie per E-Mail an den Entwickler, damit wir das Problem beheben können.';
	@override String previousVersion({required Object version}) => 'Letzte Version: ${version}';
	@override String previousStart({required Object time}) => 'Letzter Start: ${time}';
	@override String lastException({required Object message}) => 'Letzte Ausnahme: ${message}';
	@override String get lastHangRecovered => 'Beim letzten Mal wurde ein UI-Hänger erkannt und automatisch behoben';
	@override String lastHangStalled({required Object stalledMs}) => 'Beim letzten Mal wurde ein mögliches Einfrieren der UI erkannt, das etwa ${stalledMs}ms dauerte';
	@override String get exportGuide => 'Gehen Sie zu Einstellungen > Diagnose & Feedback > Protokolle exportieren.';
	@override String get privacyHint => 'Protokolle können private Daten enthalten. Bitte prüfen Sie sie, bevor Sie sie per E-Mail senden an:';
	@override String get issueWarning => 'Hängen Sie keine vollständigen Protokolle öffentlich an GitHub-Issues an';
	@override String get acknowledge => 'Verstanden';
	@override String get supportEmailCopied => 'E-Mail kopiert';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogDe extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Link eingeben';
	@override String supportedLinksHint({required Object webName}) => 'Erkennt mehrere ${webName}-Links intelligent und springt schnell zur entsprechenden Seite in der App (trennen Sie Links mit Leerzeichen vom übrigen Text)';
	@override String inputHint({required Object webName}) => 'Bitte ${webName}-Link eingeben';
	@override String get validatorEmptyLink => 'Bitte Link eingeben';
	@override String validatorNoIwaraLink({required Object webName}) => 'Kein gültiger ${webName}-Link erkannt';
	@override String get multipleLinksDetected => 'Mehrere Links erkannt, bitte einen auswählen:';
	@override String notIwaraLink({required Object webName}) => 'Kein gültiger ${webName}-Link';
	@override String linkParseError({required Object error}) => 'Fehler beim Parsen des Links: ${error}';
	@override String get unsupportedLinkDialogTitle => 'Nicht unterstützter Link';
	@override String get unsupportedLinkDialogContent => 'Dieser Linktyp kann nicht direkt in der App geöffnet werden und muss über einen externen Browser aufgerufen werden.\n\nMöchten Sie diesen Link in einem Browser öffnen?';
	@override String get openInBrowser => 'Im Browser öffnen';
	@override String get confirmOpenBrowserDialogTitle => 'Browser öffnen bestätigen';
	@override String get confirmOpenBrowserDialogContent => 'Der folgende Link wird in einem externen Browser geöffnet:';
	@override String get confirmContinueBrowserOpen => 'Möchten Sie wirklich fortfahren?';
	@override String get browserOpenFailed => 'Link konnte nicht geöffnet werden';
	@override String get unsupportedLink => 'Nicht unterstützter Link';
	@override String get cancel => 'Abbrechen';
	@override String get confirm => 'Im Browser öffnen';
}

// Path: log
class _TranslationsLogDe extends TranslationsLogEn {
	_TranslationsLogDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Protokollverwaltung';
	@override String get enableLogPersistence => 'Protokollpersistenz aktivieren';
	@override String get enableLogPersistenceDesc => 'Protokolle zur Analyse in der Datenbank speichern';
	@override String get logDatabaseSizeLimit => 'Größenlimit der Protokolldatenbank';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Aktuell: ${size}';
	@override String get exportCurrentLogs => 'Aktuelle Protokolle exportieren';
	@override String get exportCurrentLogsDesc => 'Die aktuellen App-Protokolle exportieren, um Entwicklern bei der Diagnose von Problemen zu helfen';
	@override String get exportHistoryLogs => 'Verlaufsprotokolle exportieren';
	@override String get exportHistoryLogsDesc => 'Protokolle innerhalb eines bestimmten Datumsbereichs exportieren';
	@override String get exportMergedLogs => 'Zusammengeführte Protokolle exportieren';
	@override String get exportMergedLogsDesc => 'Zusammengeführte Protokolle innerhalb eines bestimmten Datumsbereichs exportieren';
	@override String get showLogStats => 'Protokollstatistiken anzeigen';
	@override String get logExportSuccess => 'Protokollexport erfolgreich';
	@override String logExportFailed({required Object error}) => 'Protokollexport fehlgeschlagen: ${error}';
	@override String get showLogStatsDesc => 'Statistiken zu verschiedenen Protokolltypen anzeigen';
	@override String logExtractFailed({required Object error}) => 'Protokollstatistiken konnten nicht abgerufen werden: ${error}';
	@override String get clearAllLogs => 'Alle Protokolle löschen';
	@override String get clearAllLogsDesc => 'Alle Protokolldaten löschen';
	@override String get confirmClearAllLogs => 'Löschen bestätigen';
	@override String get confirmClearAllLogsDesc => 'Möchten Sie wirklich alle Protokolldaten löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.';
	@override String get clearAllLogsSuccess => 'Protokoll erfolgreich gelöscht';
	@override String clearAllLogsFailed({required Object error}) => 'Protokolle konnten nicht gelöscht werden: ${error}';
	@override String get unableToGetLogSizeInfo => 'Protokollgrößeninformationen konnten nicht abgerufen werden';
	@override String get currentLogSize => 'Aktuelle Protokollgröße:';
	@override String get logCount => 'Anzahl der Protokolle:';
	@override String get logCountUnit => 'Protokolle';
	@override String get logSizeLimit => 'Größenlimit der Protokolle:';
	@override String get usageRate => 'Nutzungsrate:';
	@override String get exceedLimit => 'Limit überschritten';
	@override String get remaining => 'Verbleibend';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Die aktuelle Protokollgröße wurde überschritten, bitte bereinigen Sie alte Protokolle oder erhöhen Sie das Größenlimit';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Die aktuelle Protokollgröße ist fast erreicht, bitte bereinigen Sie alte Protokolle';
	@override String get cleaningOldLogs => 'Alte Protokolle werden bereinigt…';
	@override String get logCleaningCompleted => 'Protokollbereinigung abgeschlossen';
	@override String get logCleaningProcessMayNotBeCompleted => 'Der Vorgang der Protokollbereinigung wurde möglicherweise nicht abgeschlossen';
	@override String get cleanExceededLogs => 'Übermäßige Protokolle bereinigen';
	@override String get noLogsToExport => 'Keine Protokolle zum Exportieren';
	@override String get exportingLogs => 'Protokolle werden exportiert…';
	@override String get noHistoryLogsToExport => 'Keine Verlaufsprotokolle zum Exportieren; verwenden Sie die App bitte zunächst eine Weile';
	@override String get selectLogDate => 'Protokolldatum auswählen';
	@override String get today => 'Heute';
	@override String get selectMergeRange => 'Zusammenführungsbereich auswählen';
	@override String get selectMergeRangeHint => 'Bitte wählen Sie den zusammenzuführenden Protokollzeitraum';
	@override String selectMergeRangeDays({required Object days}) => 'Letzte ${days} Tage';
	@override String get logStats => 'Protokollstatistiken';
	@override String todayLogs({required Object count}) => 'Heutige Protokolle: ${count} Protokolle';
	@override String recent7DaysLogs({required Object count}) => 'Protokolle der letzten 7 Tage: ${count} Protokolle';
	@override String totalLogs({required Object count}) => 'Protokolle insgesamt: ${count} Protokolle';
	@override String get setLogDatabaseSizeLimit => 'Größenlimit der Protokolldatenbank festlegen';
	@override String currentLogSizeWithSize({required Object size}) => 'Aktuelle Protokollgröße: ${size}';
	@override String get warning => 'Warnung';
	@override String newSizeLimit({required Object size}) => 'Neues Größenlimit: ${size}';
	@override String get confirmToContinue => 'Zur Fortsetzung bestätigen';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Größenlimit der Protokolle auf ${size} festgelegt';
}

// Path: emoji
class _TranslationsEmojiDe extends TranslationsEmojiEn {
	_TranslationsEmojiDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get recentlyUsed => 'Zuletzt';
	@override String insertedCount({required Object count}) => '${count} eingefügt';
	@override String get name => 'Emoji';
	@override String get size => 'Größe';
	@override String get small => 'Klein';
	@override String get medium => 'Mittel';
	@override String get large => 'Groß';
	@override String get extraLarge => 'Sehr groß';
	@override String get copyEmojiLinkSuccess => 'Emoji-Link kopiert';
	@override String get preview => 'Emoji-Vorschau';
	@override String get library => 'Emoji-Bibliothek';
	@override String get noEmojis => 'Keine Emojis';
	@override String get clickToAddEmojis => 'Klicken Sie oben rechts auf die Schaltfläche, um Emojis hinzuzufügen';
	@override String get addEmojis => 'Emojis hinzufügen';
	@override String get imagePreview => 'Bildvorschau';
	@override String get imageLoadFailed => 'Bild konnte nicht geladen werden';
	@override String get loading => 'Wird geladen…';
	@override String get delete => 'Löschen';
	@override String get close => 'Schließen';
	@override String get deleteImage => 'Bild löschen';
	@override String get confirmDeleteImage => 'Möchten Sie dieses Bild wirklich löschen?';
	@override String get cancel => 'Abbrechen';
	@override String get batchDelete => 'Stapellöschung';
	@override String confirmBatchDelete({required Object count}) => 'Möchten Sie die ausgewählten ${count} Bilder wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.';
	@override String get deleteSuccess => 'Erfolgreich gelöscht';
	@override String get addImage => 'Bild hinzufügen';
	@override String get addImageByUrl => 'Per URL hinzufügen';
	@override String get addImageUrl => 'Bild-URL hinzufügen';
	@override String get imageUrl => 'Bild-URL';
	@override String get enterImageUrl => 'Bitte Bild-URL eingeben';
	@override String get add => 'Hinzufügen';
	@override String get batchImport => 'Stapelimport';
	@override String get enterJsonUrlArray => 'Bitte URL-Array im JSON-Format eingeben:';
	@override String get formatExample => 'Formatbeispiel:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Bitte fügen Sie ein URL-Array im JSON-Format ein';
	@override String get import => 'Importieren';
	@override String importSuccess({required Object count}) => '${count} Bilder erfolgreich importiert';
	@override String get jsonFormatError => 'JSON-Formatfehler, bitte Eingabe prüfen';
	@override String get createGroup => 'Emoji-Gruppe erstellen';
	@override String get groupName => 'Gruppenname';
	@override String get enterGroupName => 'Bitte Gruppennamen eingeben';
	@override String get create => 'Erstellen';
	@override String get editGroupName => 'Gruppennamen bearbeiten';
	@override String get save => 'Speichern';
	@override String get deleteGroup => 'Gruppe löschen';
	@override String get confirmDeleteGroup => 'Möchten Sie diese Emoji-Gruppe wirklich löschen? Alle Bilder in der Gruppe werden ebenfalls gelöscht.';
	@override String imageCount({required Object count}) => '${count} Bilder';
	@override String get selectEmoji => 'Emoji auswählen';
	@override String get noEmojisInGroup => 'Keine Emojis in dieser Gruppe';
	@override String get goToSettingsToAddEmojis => 'Gehen Sie zu den Einstellungen, um Emojis hinzuzufügen';
	@override String get emojiManagement => 'Emoji-Verwaltung';
	@override String get manageEmojiGroupsAndImages => 'Emoji-Gruppen und -Bilder verwalten';
	@override String get uploadLocalImages => 'Lokale Bilder hochladen';
	@override String get uploadingImages => 'Bilder werden hochgeladen';
	@override String uploadingImagesProgress({required Object count}) => 'Es werden ${count} Bilder hochgeladen, bitte warten…';
	@override String get doNotCloseDialog => 'Bitte schließen Sie diesen Dialog nicht';
	@override String uploadSuccess({required Object count}) => '${count} Bilder erfolgreich hochgeladen';
	@override String uploadFailed({required Object count}) => 'Fehlgeschlagen: ${count}';
	@override String get uploadFailedMessage => 'Bild-Upload fehlgeschlagen, bitte prüfen Sie Netzwerkverbindung oder Dateiformat';
	@override String uploadErrorMessage({required Object error}) => 'Beim Hochladen ist ein Fehler aufgetreten: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterDe extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Feld auswählen';
	@override String get add => 'Hinzufügen';
	@override String get clear => 'Leeren';
	@override String get clearAll => 'Alle löschen';
	@override String get generatedQuery => 'Generierte Abfrage';
	@override String get copyToClipboard => 'In die Zwischenablage kopieren';
	@override String get copied => 'Kopiert';
	@override String filterCount({required Object count}) => '${count} Filter';
	@override String get filterSettings => 'Filtereinstellungen';
	@override String get field => 'Feld';
	@override String get operator => 'Operator';
	@override String get language => 'Sprache';
	@override String get value => 'Wert';
	@override String get dateRange => 'Datumsbereich';
	@override String get numberRange => 'Zahlenbereich';
	@override String get from => 'Von';
	@override String get to => 'Bis';
	@override String get date => 'Datum';
	@override String get number => 'Zahl';
	@override String get boolean => 'Boolesch';
	@override String get tags => 'Tags';
	@override String get select => 'Auswählen';
	@override String get clickToSelectDate => 'Zum Auswählen des Datums klicken';
	@override String get pleaseEnterValidNumber => 'Bitte eine gültige Zahl eingeben';
	@override String get pleaseEnterValidDate => 'Bitte ein gültiges Datumsformat eingeben (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => 'Der Startwert muss kleiner als der Endwert sein';
	@override String get startDateMustBeBeforeEndDate => 'Das Startdatum muss vor dem Enddatum liegen';
	@override String get pleaseFillStartValue => 'Bitte Startwert eingeben';
	@override String get pleaseFillEndValue => 'Bitte Endwert eingeben';
	@override String get rangeValueFormatError => 'Format des Bereichswerts fehlerhaft';
	@override String get contains => 'Enthält';
	@override String get equals => 'Gleich';
	@override String get notEquals => 'Ungleich';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Bereich';
	@override String get kIn => 'Enthält beliebiges';
	@override String get notIn => 'Enthält kein beliebiges';
	@override String get username => 'Benutzername';
	@override String get nickname => 'Spitzname';
	@override String get registrationDate => 'Registrierungsdatum';
	@override String get description => 'Beschreibung';
	@override String get title => 'Titel';
	@override String get body => 'Text';
	@override String get author => 'Autor';
	@override String get publishDate => 'Veröffentlichungsdatum';
	@override String get private => 'Privat';
	@override String get duration => 'Dauer (Sekunden)';
	@override String get likes => 'Likes';
	@override String get views => 'Aufrufe';
	@override String get comments => 'Kommentare';
	@override String get rating => 'Bewertung';
	@override String get imageCount => 'Bildanzahl';
	@override String get videoCount => 'Videoanzahl';
	@override String get createDate => 'Erstellungsdatum';
	@override String get content => 'Inhalt';
	@override String get all => 'Alle';
	@override String get adult => 'Erwachsene';
	@override String get general => 'Allgemein';
	@override String get yes => 'Ja';
	@override String get no => 'Nein';
	@override String get users => 'Nutzer';
	@override String get videos => 'Videos';
	@override String get images => 'Bilder';
	@override String get posts => 'Beiträge';
	@override String get forumThreads => 'Forum-Threads';
	@override String get forumPosts => 'Forumsbeiträge';
	@override String get playlists => 'Wiedergabelisten';
	@override late final _TranslationsSearchFilterSortTypesDe sortTypes = _TranslationsSearchFilterSortTypesDe._(_root);
	@override String get drawerSubtitle => 'Änderungen werden sofort übernommen';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupDe extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeDe welcome = _TranslationsFirstTimeSetupWelcomeDe._(_root);
	@override late final _TranslationsFirstTimeSetupBasicDe basic = _TranslationsFirstTimeSetupBasicDe._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkDe network = _TranslationsFirstTimeSetupNetworkDe._(_root);
	@override late final _TranslationsFirstTimeSetupThemeDe theme = _TranslationsFirstTimeSetupThemeDe._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerDe player = _TranslationsFirstTimeSetupPlayerDe._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialDe spatial = _TranslationsFirstTimeSetupSpatialDe._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionDe completion = _TranslationsFirstTimeSetupCompletionDe._(_root);
	@override late final _TranslationsFirstTimeSetupCommonDe common = _TranslationsFirstTimeSetupCommonDe._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperDe extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Systemproxy erkannt';
	@override String get copied => 'Kopiert';
	@override String get copy => 'Kopieren';
}

// Path: tagSelector
class _TranslationsTagSelectorDe extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Tags auswählen';
	@override String get clickToSelectTags => 'Klicken Sie, um Tags auszuwählen';
	@override String get addTag => 'Tag hinzufügen';
	@override String get removeTag => 'Tag entfernen';
	@override String get deleteTag => 'Tag löschen';
	@override String get usageInstructions => 'Fügen Sie zuerst Tags hinzu und klicken Sie dann, um aus vorhandenen Tags auszuwählen';
	@override String get usageInstructionsTooltip => 'Anleitung';
	@override String get addTagTooltip => 'Tag hinzufügen';
	@override String get removeTagTooltip => 'Tag entfernen';
	@override String get cancelSelection => 'Auswahl abbrechen';
	@override String get selectAll => 'Alle auswählen';
	@override String get cancelSelectAll => 'Alle auswählen abbrechen';
	@override String get delete => 'Löschen';
}

// Path: anime4k
class _TranslationsAnime4kDe extends TranslationsAnime4kEn {
	_TranslationsAnime4kDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Echtzeit-Video-Upscaling und Rauschunterdrückung zur Verbesserung der Qualität von Animationsvideos';
	@override String get settings => 'Anime4K-Einstellungen';
	@override String get preset => 'Anime4K-Preset';
	@override String get disable => 'Anime4K deaktivieren';
	@override String get disableDescription => 'Video-Verbesserungseffekte deaktivieren';
	@override String get highQualityPresets => 'Presets hoher Qualität';
	@override String get fastPresets => 'Schnelle Presets';
	@override String get litePresets => 'Leichte Presets';
	@override String get moreLitePresets => 'Noch leichtere Presets';
	@override String get customPresets => 'Eigene Presets';
	@override late final _TranslationsAnime4kPresetGroupsDe presetGroups = _TranslationsAnime4kPresetGroupsDe._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsDe presetDescriptions = _TranslationsAnime4kPresetDescriptionsDe._(_root);
	@override late final _TranslationsAnime4kPresetNamesDe presetNames = _TranslationsAnime4kPresetNamesDe._(_root);
	@override String get performanceTip => '💡 Tipp: Wählen Sie passende Presets je nach Geräteleistung. Für leistungsschwache Geräte empfiehlt sich die Verwendung leichter Presets.';
	@override String get compatibilityTip => '⚠️ Einige mobile GPUs (z. B. Kirin 980 / Mali-G76) können keine benutzerdefinierten Shader rendern. Wenn das Bild schwarz wird, der Ton aber weiterläuft, deaktivieren Sie Anime4K hier.';
	@override String get autoDisabledOnRenderFailure => 'Die GPU Ihres Geräts konnte den Anime4K-Shader nicht rendern, daher wurde er automatisch deaktiviert.';
}

// Path: siteMode
class _TranslationsSiteModeDe extends TranslationsSiteModeEn {
	_TranslationsSiteModeDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Website-Modus';
	@override String get mainSite => 'Main';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Aktuell ${currentSite} · Tippen, um zu ${nextSite} zu wechseln';
	@override String get dialogTitle => 'Website-Modus wechseln';
	@override String get dialogDescription => 'Beim Wechseln wird die gesamte App neu geladen und zuvor geladene Listen und Seitenzustände werden zurückgesetzt.';
	@override String get chooseLinkTargetTitle => 'Ziel-Website wählen';
	@override String get chooseLinkTargetDescription => 'Dieser Link enthält keine Domain. Bitte wählen Sie, ob er in Main oder AI geöffnet werden soll.';
	@override String get chooseLinkTargetHint => 'Nach dem Öffnen verwenden diese Seite und ihre nachfolgenden Detailanfragen weiterhin die ausgewählte Website.';
	@override String get alreadyUsing => 'Sie verwenden diesen Website-Modus bereits.';
	@override String openInSite({required Object site}) => 'In ${site} öffnen';
	@override String confirmUsing({required Object site}) => 'Nach der Bestätigung verwenden zukünftige Anfragen den Modus ${site}.';
	@override String switched({required Object site}) => 'Zu ${site} gewechselt. Die App wurde neu geladen.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigDe extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gespeicherte Filter';
	@override String get empty => 'Noch keine gespeicherten Filter';
	@override String get saveTooltip => 'Aktuellen Filter speichern';
	@override String get namePromptTitle => 'Filter speichern';
	@override String get nameLabel => 'Name';
	@override String get nameHint => 'Namen eingeben';
	@override String get saveSuccess => 'Filter gespeichert';
	@override String get deleteSuccess => 'Filter entfernt';
	@override String get addCurrent => 'Aktuellen Filter speichern';
	@override String get reorderHint => 'Zum Umsortieren lange drücken und ziehen';
	@override String get rename => 'Umbenennen';
	@override String get unnamed => 'Unbenannt';
	@override String get noConditions => 'Alle Inhalte (kein Filter)';
	@override String tagsCount({required Object count}) => '${count} Tags';
}

// Path: savedSearch
class _TranslationsSavedSearchDe extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Gespeicherte Suchen';
	@override String get empty => 'Noch keine gespeicherten Suchen';
	@override String get saveTooltip => 'Aktuelle Suche speichern';
	@override String get namePromptTitle => 'Suche speichern';
	@override String get nameLabel => 'Name';
	@override String get nameHint => 'Namen eingeben';
	@override String get saveSuccess => 'Suche gespeichert';
	@override String get deleteSuccess => 'Suche entfernt';
	@override String get addCurrent => 'Aktuelle Suche speichern';
	@override String get reorderHint => 'Zum Umsortieren lange drücken und ziehen';
	@override String get rename => 'Umbenennen';
	@override String get noKeyword => '(Kein Stichwort)';
	@override String filtersCount({required Object count}) => '${count} Filter';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderDe extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Standard-Tag-Sperrliste erkannt';
	@override String get content => 'Ihr Konto verwendet noch die Tag-Sperrliste, die die Website automatisch auf jedes neue Konto anwendet. Möchten Sie sie überprüfen und verwalten?';
	@override String get goManage => 'Verwalten';
	@override String get dismiss => 'Nicht jetzt';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistDe extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Farbseh-Unterstützung';
	@override String get description => 'Korrigiert Videofarben für farbenblindheitsbeeinträchtigte Zuschauer, kann zusammen mit Anime4K verwendet werden';
	@override String get galleryDescription => 'Korrigiert die Bildfarben der Galerie für farbenblindheitsbeeinträchtigte Zuschauer (unabhängig vom Player-Schalter)';
	@override String get galleryDescriptionSpatial => 'Korrigiert die Bildfarben der Galerie für farbenblindheitsbeeinträchtigte Zuschauer. Gilt nur für den 2D-Betrachter in diesem Bereich – Bilder auf dem räumlichen Bildschirm werden nativ gerendert und durchlaufen diesen Filter nicht';
	@override String get disable => 'Aus';
	@override String get disableDescription => 'Keine Farbkorrektur';
	@override String get protanopia => 'Rot-Unterstützung (Protanopie)';
	@override String get protanopiaDescription => 'Für Protanopie – Schwierigkeiten, Rot zu unterscheiden';
	@override String get deuteranopia => 'Grün-Unterstützung (Deuteranopie)';
	@override String get deuteranopiaDescription => 'Für Deuteranopie – Schwierigkeiten, Grün zu unterscheiden';
	@override String get tritanopia => 'Blau-Unterstützung (Tritanopie)';
	@override String get tritanopiaDescription => 'Für Tritanopie – Schwierigkeiten, Blau und Gelb zu unterscheiden';
	@override String appliedToast({required Object filterName}) => '${filterName} angewendet, wirkt sofort';
	@override String get disabledToast => 'Farbseh-Unterstützung deaktiviert';
}

// Path: externalPlayer
class _TranslationsExternalPlayerDe extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mit anderer App öffnen';
	@override String get description => 'Übergeben Sie das aktuelle Video an einen anderen Player auf diesem Gerät, z. B. Skybox oder Pegasus auf einem VR-Headset oder MX Player und VLC auf einem Telefon';
	@override String get openWithOtherApp => 'Andere App wählen';
	@override String get openWithOtherAppDescription => 'Systemauswahl anzeigen und einen Player zum Übernehmen wählen';
	@override String get openWithSystemPlayer => 'Im Standard-Player öffnen';
	@override String get openWithSystemPlayerDescription => 'An die Standard-Video-App des Systems übergeben';
	@override String get copyLink => 'Videolink kopieren';
	@override String get copyLinkDescription => 'Für Player, die nur eine URL einfügen können, z. B. Skybox oder DeoVR';
	@override String get linkCopied => 'Videolink kopiert';
	@override String get sourceLocal => 'Lokale Datei';
	@override String get sourceOnline => 'Direkter Link';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Direkter Link · ${quality}';
	@override String get onlineLinkExpiryHint => 'Direkte Links laufen ab, daher kann ein externer Player mittendrin abbrechen. Zuerst herunterzuladen ist der zuverlässige Weg.';
	@override String get vrPlayerHint => 'Wenn Ihr VR-Player in der Auswahl fehlt, verwenden Sie „Videolink kopieren“ und fügen Sie ihn in diesem Player ein.';
	@override String get noHandler => 'Keine App auf diesem Gerät kann das Video öffnen';
	@override String handoffFailed({required Object message}) => 'Übergabe fehlgeschlagen: ${message}';
	@override String get handoffFailedUnknown => 'Übergabe fehlgeschlagen';
	@override String get sourceUnavailable => 'Die aktuelle Videoadresse konnte nicht abgerufen werden, bitte erneut versuchen';
	@override String get localFileMissing => 'Die lokale Datei existiert nicht mehr';
	@override String get handedOff => 'An den externen Player übergeben';
	@override String get desktopSectionTitle => 'Externe Player';
	@override String get managePlayers => 'Externe Player verwalten';
	@override String get managePlayersDescWindows => 'PCVR-Player wie HereSphere, DeoVR und Whirligig sind nicht die Standard-App des Systems. Richten Sie dies auf ihre .exe aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.';
	@override String get managePlayersDescMac => 'Richten Sie dies auf Player wie IINA, VLC oder mpv aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.';
	@override String get managePlayersDescLinux => 'Richten Sie dies auf Player wie mpv, VLC oder Celluloid aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.';
	@override String get pickExecutableHintWindows => 'Wählen Sie die Haupt-.exe im Installationsordner des Players, z. B. HereSphere.exe oder vlc.exe. Desktop-Verknüpfungen (.lnk) funktionieren nicht.';
	@override String get pickExecutableHintMac => 'Wählen Sie die .app des Players in „Programme“, z. B. IINA.app – die tatsächliche Programmdatei darin wird für Sie ermittelt.';
	@override String get pickExecutableHintLinux => 'Wählen Sie die Programmdatei des Players, z. B. /usr/bin/mpv. Mit „which mpv“ finden Sie heraus, wo sie liegt.';
	@override String emptyStateGuide({required Object examples}) => 'Nach der Konfiguration erscheint er als eigener Eintrag unter „Mit anderer App öffnen“ auf der Player-Seite. Häufige: ${examples}';
	@override String get detectNothingFoundGuide => 'Keine installierten Player gefunden. Benutzerdefinierte Installationsordner und portable Versionen können nicht erkannt werden – verwenden Sie „Player hinzufügen“, um selbst einen anzugeben.';
	@override String get detectNothingNew => 'Keine neuen Player gefunden; alles Installierte ist bereits in der Liste';
	@override String get detectFailed => 'Erkennung fehlgeschlagen – verwenden Sie „Player hinzufügen“, um selbst einen anzugeben';
	@override String get advancedOptions => 'Erweitert';
	@override String get playerNameHint => 'Leer lassen, um den Dateinamen zu verwenden';
	@override String get executablePathRequired => 'Wählen Sie zuerst die Programmdatei des Players';
	@override String playerCount({required Object count}) => '${count} konfiguriert';
	@override String get noPlayerConfigured => 'Noch kein externer Player konfiguriert';
	@override String get autoDetect => 'Automatisch erkennen';
	@override String get detecting => 'Wird erkannt…';
	@override String detectFound({required Object count}) => '${count} Player gefunden';
	@override String get detectNothingFound => 'Keine neuen Player gefunden, fügen Sie einen manuell hinzu';
	@override String get autoDetectedTag => 'erkannt';
	@override String get addPlayer => 'Player hinzufügen';
	@override String get editPlayer => 'Player bearbeiten';
	@override String get playerName => 'Name';
	@override String get executablePath => 'Programmdatei';
	@override String get browse => 'Durchsuchen';
	@override String get argumentTemplate => 'Startargumente';
	@override String get argumentTemplateHint => 'Verwenden Sie {input} für den Videopfad oder die URL. Leer lassen, um sie als einziges Argument zu übergeben.';
	@override String get nameAndPathRequired => 'Name und Programmdatei sind beide erforderlich';
	@override String get testLaunch => 'Teststart';
	@override String get testLaunched => 'Player gestartet';
	@override String get testFailed => 'Start fehlgeschlagen, prüfen Sie den Pfad der Programmdatei';
	@override String get executableMissing => 'Programmdatei nicht gefunden';
	@override String openWithNamed({required Object name}) => 'In ${name} öffnen';
	@override String get managePlayersEntry => 'Externe Player verwalten…';
}

// Path: watchLater
class _TranslationsWatchLaterDe extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Später ansehen';
	@override String get addToWatchLater => 'Später ansehen';
	@override String get removeFromWatchLater => 'Aus „Später ansehen“ entfernen';
	@override String get addedToWatchLater => 'Zu „Später ansehen“ hinzugefügt';
	@override String get alreadyInWatchLater => 'Bereits in „Später ansehen“';
	@override String get removedFromWatchLater => 'Aus „Später ansehen“ entfernt';
	@override String removedCount({required Object count}) => '${count} Elemente entfernt';
	@override String get viewWatchLaterList => 'Liste anzeigen';
	@override String get addFailed => 'Hinzufügen zu „Später ansehen“ fehlgeschlagen';
	@override String get invalidItem => 'Nicht verfügbar';
	@override String get clearWatched => 'Angesehenes löschen';
	@override String watchedCleared({required Object count}) => '${count} angesehene Elemente gelöscht';
	@override String get noWatchedToClear => 'Nichts Angesehenes zum Löschen';
	@override String get emptyVideo => 'Noch keine Videos in „Später ansehen“';
	@override String get emptyGallery => 'Noch keine Galerien in „Später ansehen“';
	@override String get filterAll => 'Alle';
	@override String get filterUnwatched => 'Nicht angesehen';
	@override String get sortRecentlyAdded => 'Zuletzt hinzugefügt';
	@override String get sortEarliestAdded => 'Zuerst hinzugefügt';
	@override String get watched => 'Angesehen';
	@override String get playlistLoadFailed => 'Wiedergabelisten konnten nicht geladen werden';
	@override String get noPlaylists => 'Noch keine Wiedergabelisten';
	@override String get undo => 'Rückgängig';
	@override String get clearWatchedConfirm => 'Alles löschen, was Sie in diesem Tab bereits angesehen haben? Dies kann nicht rückgängig gemacht werden.';
	@override String get emptyUnwatchedVideo => 'Hier gibt es nichts mehr anzuschauen';
	@override String get emptyUnwatchedGallery => 'Hier gibt es nichts mehr anzusehen';
	@override String get queueLoadFailed => 'Laden fehlgeschlagen, zum Wiederholen tippen';
}

// Path: mediaMenu
class _TranslationsMediaMenuDe extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get like => 'Gefällt mir';
	@override String get unlike => 'Gefällt mir nicht mehr';
	@override String get viewAuthor => 'Autor ansehen';
	@override String inFolders({required Object count}) => '${count} Ordner';
	@override String inPlaylists({required Object count}) => '${count} Playlists';
	@override String get downloaded => 'Heruntergeladen';
}

// Path: mediaPreview
class _TranslationsMediaPreviewDe extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Vorschau';
	@override String get openDetail => 'Öffnen';
	@override String get moreActions => 'Weitere Aktionen';
	@override String get previousImage => 'Vorheriges Bild';
	@override String get nextImage => 'Nächstes Bild';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueDe extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} Bilder';
	@override String get upNext => 'Als Nächstes';
	@override String get sourceTab => 'Quelle';
	@override String get emptyQueue => 'Nichts Abspielbares in dieser Warteschlange';
	@override String get emptyGalleryQueue => 'Keine Galerien in dieser Warteschlange';
	@override String get nowPlaying => 'Wird abgespielt';
	@override String get myPlaylists => 'Meine Wiedergabelisten';
	@override String get authorPlaylists => 'Wiedergabelisten des Autors';
	@override String get openQueue => 'Als Nächstes';
	@override String get continueInQueue => 'Weiter aus der aktuellen Warteschlange abspielen';
	@override String get continueInQueueSubtitle => 'Spielt automatisch das nächste Element ab; deaktiviert „Wiederholen nach Ende“';
	@override String get repeatDisabledByQueue => 'Deaktiviert, solange „Weiter aus der aktuellen Warteschlange abspielen“ aktiv ist';
	@override String get playNext => 'Als Nächstes abspielen';
	@override String get queueEnded => 'Dies ist das letzte Element in der Warteschlange';
	@override String get playNextHint => 'Tippen, um das nächste Element abzuspielen, lange drücken, um „Als Nächstes“ zu öffnen';
	@override String get authorVideos => 'Videos des Autors';
	@override String get authorGalleries => 'Galerien des Autors';
	@override String get favoriteFolders => 'Favoriten-Ordner';
	@override String get localFiles => 'Auf diesem Gerät';
	@override String get currentFolder => 'Ordner dieser Datei';
	@override String get playThisFolder => 'Video-Warteschlange dieses Ordners anzeigen';
	@override String get browseThisFolder => 'Galerie-Warteschlange dieses Ordners anzeigen';
	@override String get downloads => 'Heruntergeladen';
	@override String get otherPlaylists => 'Wiedergabelisten anderer Nutzer';
	@override String get nothingHere => 'Hier ist nichts';
}

// Path: vrFormat
class _TranslationsVrFormatDe extends TranslationsVrFormatEn {
	_TranslationsVrFormatDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Im räumlichen Player abspielen';
	@override String get handingOff => 'Übergabe an den Raum…';
	@override String get title => 'Wiedergabemodus';
	@override String get spatialSectionTitle => 'Räumliche Wiedergabe';
	@override String get spatialSectionDesc => 'Auf dem Headset wird ein Video nicht in diesem Bedienfeld dargestellt — der räumliche Player zeigt es auf einem Bildschirm im Raum.';
	@override String get spatialPanelEntry => 'Räumliches Bedienfeld';
	@override String get spatialPanelEntryDesc => 'Bildschirmabstand, Größe und Krümmung, die Hintergrundumgebung sowie Geschwindigkeit, Wiederholung und automatisches Ausblenden befinden sich alle im räumlichen Bedienfeld.';
	@override String get spatialGuideEntry => 'Anleitung zur Headset-Steuerung';
	@override String get spatialGuideEntryDesc => 'Controller-Tasten, Greifen des Bildschirms, Stick-Spulen und Umblättern';
	@override String get spatialFlatOmitted => 'Touch-Gesten, Bildverbesserung und die Audio-/Videoparameter gelten nur für den 2D-Player; der räumliche Player läuft auf einer anderen Engine und wird hier daher nicht aufgeführt.';
	@override String get spatialGallerySectionTitle => 'Räumliche Galerie';
	@override String get spatialGalleryPanelDesc => 'Diashow-Intervall, Wiederholung einzelner Clips und Bildschirmkrümmung werden alle im räumlichen Bedienfeld eingestellt.';
	@override String get autoEnterGallery => 'Galeriebilder in der räumlichen Galerie öffnen';
	@override String get autoEnterGalleryDesc => 'In Quest öffnet das Tippen auf ein Bild die gesamte Galerie auf dem schwebenden Bildschirm mit Filmstreifen, Diashow und Controller-Blättern statt des Betrachters in diesem Bedienfeld.';
	@override String get panelSettings => 'Bedienfeld & Hintergrund';
	@override String get panelSettingsDesc => 'Wie weit dieses App-Bedienfeld entfernt ist und wie viel von Ihrem Raum dahinter sichtbar ist';
	@override String get panelDistance => 'Abstand des Bedienfelds';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Platzierung zurücksetzen';
	@override String get panelResetBackground => 'Auf Standard zurücksetzen';
	@override String get panelBackground => 'Transparenz des Hintergrunds';
	@override String get panelBackgroundHint => '0 %: schwarze Umgebung · 100 %: Ihr echter Raum mit Umgebungslicht';
	@override String get panelUnavailable => 'Das Bedienfeld ist derzeit nicht platziert — versuchen Sie es gleich noch einmal';
	@override String get desc => 'Wählen Sie die Geometrie, mit der dieses Video abgespielt werden soll. Die Website liefert diese Information nicht, daher wählt die automatische Erkennung nur einen Ausgangspunkt — Ihre Wahl entscheidet.';
	@override String get sectionFlat => 'Flach';
	@override String get sectionStereo => 'Flaches 3D';
	@override String get sectionPanorama => 'VR-Panorama';
	@override String get flat => 'Normales Video';
	@override String get flatDesc => 'Unverändert abspielen, keine Neuzuordnung';
	@override String get flatSideBySide => 'Side-by-Side-3D';
	@override String get flatSideBySideDesc => 'Ein Auge pro Hälfte, links und rechts; zeigt das linke Auge und stellt dessen Seitenverhältnis wieder her';
	@override String get flatTopBottom => 'Over-Under-3D';
	@override String get flatTopBottomDesc => 'Ein Auge pro Hälfte, oben und unten; zeigt die obere Hälfte und stellt deren Seitenverhältnis wieder her';
	@override String get vr180SideBySide => 'VR180 Side-by-Side';
	@override String get vr180SideBySideDesc => 'Hemisphärisches Panorama mit beiden Augen — die häufigste VR-Quelle';
	@override String get vr180Mono => 'VR180 Mono';
	@override String get vr180MonoDesc => 'Hemisphärisches Panorama, ein Auge pro Bild';
	@override String get vr360Mono => 'VR360 Mono';
	@override String get vr360MonoDesc => 'Vollständiges Rundumpanorama, ein Auge pro Bild';
	@override String get vr360TopBottom => 'VR360 Over-Under';
	@override String get vr360TopBottomDesc => 'Vollständiges Rundumpanorama mit beiden Augen übereinander';
	@override String get resetView => 'Ansicht zurücksetzen';
	@override String get resetViewDesc => 'Blickrichtung und Sichtfeld wieder nach vorne ausrichten';
	@override String get resetToAuto => 'Zurück zur automatischen Erkennung';
	@override String get resetToAutoDesc => 'Die manuelle Auswahl für dieses Video verwerfen und die Erkennung erneut entscheiden lassen';
	@override String get manualBadge => 'Manuell festgelegt';
	@override String get panoramaHint => 'Ziehen Sie das Bild, um sich umzusehen; ziehen Sie zusammen, um das Sichtfeld zu ändern';
	@override String get panoramaGestureNotice => 'Beim Umsehen dreht Ziehen die Ansicht — verwenden Sie den Fortschrittsbalken zum Spulen';
	@override String get shaderUnsupported => 'Dieses Gerät kann Live-Panorama nicht rendern; es wird stattdessen ein einzelnes Auge angezeigt';
	@override String get handoffTooltip => 'Anders abspielen';
	@override String get suggestedBadge => 'Vorgeschlagen';
	@override String suggestedEntryDesc({required Object format}) => 'Sieht aus wie ${format} — zum Wechseln tippen';
	@override String suggestionTitle({required Object format}) => 'Dies könnte ein VR-Video sein (${format})';
	@override String get suggestionTitleShort => 'Dies könnte ein VR-Video sein';
	@override String get suggestionAction => 'Als VR abspielen';
	@override String get suggestionDismiss => 'Ausblenden';
}

// Path: localMedia
class _TranslationsLocalMediaDe extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseDe browse = _TranslationsLocalMediaBrowseDe._(_root);
	@override String get tabFolders => 'Ordner';
	@override String get tabFavoriteVideos => 'Favoriten';
	@override String get tabAllVideos => 'Alle Videos';
	@override String get tabAllImages => 'Alle Bilder';
	@override String get tabDownloadedVideos => 'Heruntergeladene Videos';
	@override String get tabDownloadedGalleries => 'Heruntergeladene Galerien';
	@override String get title => 'Auf diesem Gerät';
	@override String get sourceOnline => 'Iwara online';
	@override String get manageSources => 'Quellen verwalten';
	@override String get moveToCategory => 'In Kategorie verschieben';
	@override String get manageCategories => 'Kategorien verwalten';
	@override String get suggestedFolders => 'Ordner mit Videos';
	@override String get sortRecentlyAdded => 'Zuletzt hinzugefügt';
	@override String get sortRecentlyPlayed => 'Zuletzt abgespielt';
	@override String get sortName => 'Name';
	@override String get sortDuration => 'Dauer';
	@override String get sortSize => 'Größe';
	@override String get sortFolder => 'Ordner';
	@override String get sortRecentlyModified => 'Zuletzt geändert';
	@override String get sortCount => 'Anzahl';
	@override String folderCardItemCount({required Object count}) => '${count} Bilder';
	@override String get downloadsSource => 'Heruntergeladen';
	@override String get builtInSourceHint => '„Heruntergeladen“ wird automatisch verwaltet';
	@override String get filterByCategory => 'Nach Kategorie filtern';
	@override String get longPressToCategorize => 'Zum Verschieben in eine Kategorie lange drücken';
	@override String get uncategorized => 'Nicht kategorisiert';
	@override String get setCategoryFailed => 'Kategorie konnte nicht festgelegt werden';
	@override String get categoryUpdated => 'Kategorie aktualisiert';
	@override String get addFolder => 'Ordner hinzufügen';
	@override String get addDeviceVideos => 'Gerätevideos scannen';
	@override String get mediaStoreSourceName => 'Gerätevideos';
	@override String get scanQueued => 'Waiting to scan';
	@override String get itemInfo => 'File info';
	@override String get revealInFolder => 'Show in folder';
	@override String get rescanAll => 'Rescan all';
	@override String rescanAllStarted({required Object count}) => 'Rescanning ${count} sources';
	@override String get searchLibrary => 'Search';
	@override String get searchIncludeSubfolders => 'Include subfolders';
	@override String get searchThisFolderOnly => 'This folder only';
	@override String searchResultCount({required Object count}) => 'Found ${count}';
	@override String get savedServers => 'Saved NAS';
	@override String get newServer => 'Connect a new NAS';
	@override late final _TranslationsLocalMediaItemInfoLabelsDe itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsDe._(_root);
	@override String get addSource => 'Add source';
	@override String get addSourceKinds => 'Folder · NAS';
	@override String get openSettings => 'Open settings';
	@override String removeSourceLoses({required Object items}) => 'This also clears the following, and re-adding won\'t bring it back: ${items}';
	@override String loseProgress({required Object count}) => '${count} watch progress';
	@override String loseFavorites({required Object count}) => '${count} featured';
	@override String losePinned({required Object count}) => '${count} pinned folders';
	@override String loseHidden({required Object count}) => '${count} hidden folders';
	@override String loseCovers({required Object count}) => '${count} custom covers';
	@override String get renameSource => 'Rename';
	@override String get renameSourceTitle => 'Rename source';
	@override String get renameSourceLabel => 'Name';
	@override String get renamed => 'Renamed';
	@override String get nasAggregateHint => 'NAS content only includes folders you have opened. Videos and images in folders you haven\'t opened won\'t show up here.';
	@override String rescanDone({required Object name}) => '"${name}" updated';
	@override String get unknownSourceHint => 'This source needs a newer version of the app';
	@override late final _TranslationsLocalMediaMissingDe missing = _TranslationsLocalMediaMissingDe._(_root);
	@override late final _TranslationsLocalMediaWebdavDe webdav = _TranslationsLocalMediaWebdavDe._(_root);
	@override String get mediaStoreUnavailable => 'Der Gerätemedienindex ist nur unter Android verfügbar';
	@override String get mediaStorePermissionDenied => 'Der Videozugriff wurde nicht erteilt';
	@override String get rescan => 'Erneut scannen';
	@override String scanning({required Object count}) => 'Wird gescannt… ${count} gefunden';
	@override String scanFailed({required Object reason}) => 'Scan fehlgeschlagen: ${reason}';
	@override String scanTruncated({required Object count}) => 'Dieser Ordner ist sehr groß – es wurden nur die ersten ${count} Dateien hinzugefügt.';
	@override String sourceOverlaps({required Object name}) => 'Bereits durch den Ordner „${name}“ abgedeckt';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '„${name}“ befindet sich in „${source}“ und wurde daher zu den angehefteten Ordnern hinzugefügt';
	@override String alreadyPinnedFolder({required Object name}) => '„${name}“ befindet sich bereits in den angehefteten Ordnern';
	@override String sourceAlreadyAdded({required Object name}) => '„${name}“ wurde bereits hinzugefügt';
	@override String sourceContainsExisting({required Object name}) => 'Er enthält bereits den hinzugefügten Ordner „${name}“; das Hinzufügen des übergeordneten Ordners wird noch nicht unterstützt';
	@override String get addSourceFailed => 'Dieser Ordner konnte nicht hinzugefügt werden';
	@override String get fileMissing => 'Diese Datei befindet sich nicht mehr auf dem Datenträger';
	@override String get permissionDenied => 'Dateizugriff nicht erteilt · zum Erteilen tippen';
	@override String get noVideosFound => 'Keine Videos in diesem Ordner';
	@override String get emptyTitle => 'Fügen Sie einen Ordner hinzu, um die bereits auf diesem Gerät befindlichen Videos anzusehen';
	@override String get emptyPrivacyNote => 'Dateien werden nur auf diesem Gerät gelesen. Nichts wird hochgeladen.';
	@override String removeSourceTitle({required Object name}) => '„${name}“ entfernen?';
	@override String get removeSourceBody => 'Die Dateien bleiben auf dem Datenträger. Nur dieser Bibliothekseintrag wird entfernt.';
	@override String get remove => 'Entfernen';
	@override String get removeFolder => 'Ordner entfernen';
	@override String get removeFolderSelectTitle => 'Zu entfernenden Ordner auswählen';
	@override String get longPressToRemove => 'Diesen Ordner durch langes Drücken entfernen';
	@override String get clearProgress => 'Lokalen Wiedergabeverlauf löschen';
	@override String clearProgressCount({required Object count}) => '${count} Einträge';
	@override String get clearProgressEmpty => 'Noch kein lokaler Wiedergabeverlauf';
	@override String get clearProgressTitle => 'Lokalen Wiedergabeverlauf löschen?';
	@override String get clearProgressBody => 'Nur Wiedergabepositionen und Gesehen-Markierungen werden gelöscht. Ihre Dateien und Ordner bleiben unverändert.';
	@override String clearProgressDone({required Object count}) => '${count} lokale Wiedergabeverlauf-Einträge gelöscht';
	@override String get clearAction => 'Leeren';
	@override String get iosManualRescanNotice => 'iOS erkennt neue Dateien nicht automatisch. Nach dem Hinzufügen oder Löschen von Dateien müssen Sie manuell erneut scannen.';
}

// Path: historyPage
class _TranslationsHistoryPageDe extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Aus Verlauf entfernen';
	@override String get removed => 'Aus dem Verlauf entfernt';
	@override String watchedTo({required Object time}) => 'Gesehen bis ${time}';
	@override String get finished => 'Angesehen';
	@override String clearTabTitle({required Object tab}) => '„${tab}“ leeren';
	@override String clearTabConfirm({required Object tab}) => 'Der gesamte Verlauf in „${tab}“ wird gelöscht, einschließlich des Wiedergabefortschritts dieser Videos. Dies kann nicht rückgängig gemacht werden.';
	@override String get rangeByLastViewed => 'Nach zuletzt angesehen gefiltert';
}

// Path: ai
class _TranslationsAiDe extends TranslationsAiEn {
	_TranslationsAiDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'KI';
	@override String get providers => 'Anbieter';
	@override String get providersHint => 'Fügen Sie einen oder mehrere KI-Anbieter hinzu und weisen Sie diese den Funktionen zu.';
	@override String get addProvider => 'Anbieter hinzufügen';
	@override String get noProviders => 'Noch keine Anbieter vorhanden. Fügen Sie einen hinzu, um KI-Übersetzung, Suche und Signatur zu aktivieren.';
	@override String get pickPreset => 'Anbieter auswählen';
	@override String get providerNameLabel => 'Bezeichnung';
	@override String get apiKey => 'API-Schlüssel';
	@override String get baseUrl => 'Endpunkt';
	@override String get model => 'Modell';
	@override String get modelPick => 'Modell auswählen';
	@override String get modelEmpty => 'Modellliste konnte nicht geladen werden — Sie können den Modellnamen auch direkt eingeben.';
	@override String get advanced => 'Erweitert';
	@override String get reasoning => 'Reasoning-Modell';
	@override String get streaming => 'Streaming-Ausgabe';
	@override String get structuredOutput => 'Strukturierte Ausgabe';
	@override String get structuredOutputHint => 'Wird für die KI-Suche benötigt. Viele Relay-Endpunkte unterstützen dies nicht — deaktivieren Sie es, wenn die Suche fehlschlägt.';
	@override String get temperature => 'Temperatur';
	@override String get maxTokens => 'Max. Tokens';
	@override String get maxTokensAuto => 'Automatisch (Modellgrenze)';
	@override String get test => 'Testen';
	@override String get testOk => 'Verbindung erfolgreich';
	@override String get deleteProvider => 'Anbieter löschen';
	@override String get usedBy => 'Verwendet für';
	@override String get taskBindings => 'Funktionszuweisung';
	@override String get taskBindingsHint => 'Jede Funktion kann einen anderen Anbieter verwenden.';
	@override String get taskTranslate => 'Übersetzung';
	@override String get taskSearch => 'KI-Suche';
	@override String get taskSignature => 'Signatur';
	@override String get taskAuto => 'Automatisch';
	@override String get usage => 'Nutzung';
	@override String get usageCalls => 'Aufrufe';
	@override String get usageTokens => 'Token-Anzahl';
	@override String get usageFailures => 'Fehlgeschlagen';
	@override String get usageReset => 'Statistiken zurücksetzen';
	@override String get usageEmpty => 'Noch keine Aufrufe vorhanden';
	@override String get openSettings => 'KI-Einstellungen öffnen';
	@override String get notConfigured => 'Nicht konfiguriert';
	@override String get searchTitle => 'KI-Suche';
	@override String get searchHint => 'Beschreiben Sie, was Sie suchen. Die KI füllt Suchbegriffe und Filter automatisch aus.';
	@override String get searchPlaceholder => 'z. B. aktuelle MMDs mit über 10.000 Aufrufen';
	@override String get searchApply => 'Mit diesen Begriffen suchen';
	@override String get searchEmpty => 'Suchbegriffe konnten nicht erkannt werden. Bitte versuchen Sie es mit einer anderen Formulierung.';
	@override String get searchFilters => 'Filterkriterien';
	@override String searchSwitchSegment({required Object segment}) => 'Zu ${segment} wechseln';
	@override String get searchGenerating => 'Wird verarbeitet…';
	@override String get searchRetrying => 'Letzter Versuch fehlgeschlagen, neuer Versuch…';
	@override String searchRetryReason({required Object reason}) => 'Grund: ${reason}';
	@override String get searchStageWaiting => 'Anfrage gesendet, warte auf Antwort…';
	@override String get searchStageThinkingNext => 'Überlegt den nächsten Schritt…';
	@override String get searchStageReasoning => 'Überlegt…';
	@override String get searchStageTool => 'Testsuche läuft…';
	@override String searchStageDrafting({required Object chars}) => 'Antwort wird geschrieben · ${chars} Zeichen';
	@override String get searchStageParsing => 'Ergebnis wird aufbereitet…';
	@override String get searchThinking => 'Denkprozess';
	@override String get searchKeywordNeedsQuotes => 'Dieses Stichwort steht nicht in Anführungszeichen, daher passt Iwara es nur lose an — bei dieser Sortierung ist die erste Seite meist unpassend. Setze es in "Anführungszeichen" oder sortiere nach Relevanz.';
	@override String searchToolProbing({required Object query}) => 'Teste ${query}';
	@override String searchToolFound({required Object count, required Object titles}) => '${count} Treffer · ${titles}';
	@override String searchToolFailed({required Object reason}) => 'Fehlgeschlagen: ${reason}';
	@override String searchFiltersDropped({required Object count}) => '${count} Filter entfernt, die es in diesem Bereich nicht gibt.';
	@override String get revealKey => 'Show';
	@override String get hideKey => 'Hide';
	@override String get connection => 'Connection';
	@override String get providerEnabled => 'Enabled';
	@override String get providerEnabledHint => 'Turn off to keep the settings but stop using this provider.';
	@override String providerModelCount({required Object count}) => '${count} model(s)';
	@override String get noModels => 'No models';
	@override String get noModelsHint => 'No models yet. Pull the list from the server, or type a model name.';
	@override String get missingApiKey => 'API key missing';
	@override String get providerGone => 'This provider no longer exists.';
	@override String get deleteProviderConfirm => 'Delete this provider? Its models and feature assignments go with it.';
	@override String get getApiKey => 'Get an API key';
	@override String get providerDocs => 'Documentation';
	@override String get models => 'Models';
	@override String get fetchModels => 'Pull from server';
	@override String get fetchModelsHint => 'Pick from what this endpoint actually serves, instead of guessing a name.';
	@override String get addModel => 'Add a model by name';
	@override String get deleteModel => 'Remove model';
	@override String get modelUnknown => 'Not in the catalog — capabilities unknown';
	@override String get serverDefaultModel => 'Server default model';
	@override String get resetToDefault => 'Reset to default';
	@override String contextWindow({required Object tokens}) => 'Context ${tokens}';
	@override String get capFunctionCall => 'Tools';
	@override String get capReasoning => 'Reasoning';
	@override String get capStructuredOutput => 'JSON output';
	@override String get capVision => 'Vision';
	@override String get capFileInput => 'Files';
	@override String get triOn => 'On';
	@override String get triOff => 'Off';
	@override String get triAutoOn => 'Auto (on)';
	@override String get triAutoOff => 'Auto (off)';
	@override String get triAutoUnknown => 'Auto (unknown)';
	@override String endpointPreview({required Object url}) => 'Requests go to ${url}';
	@override String get endpointTrailingSlash => 'The trailing slash produces a doubled // in the path.';
	@override String get endpointMissingVersion => 'No version segment — most OpenAI-compatible endpoints need /v1.';
	@override String get modelOverrideHint => 'Everything here is optional. Leave a field alone and it follows the model\'s own capabilities and the built-in catalog.';
	@override String followCatalog({required Object value}) => 'Following the catalog: ${value}';
	@override String get userOverride => 'Overridden by you';
	@override String get sendTemperature => 'Send temperature';
	@override String get sendTemperatureHint => 'Some endpoints reject a request that carries this parameter.';
	@override String maxTokensFromCatalog({required Object tokens}) => 'Catalog says ${tokens}';
	@override String get maxTokensHint => 'Leave empty to follow the catalog. Enter 0 to omit the parameter entirely and let the server use the model\'s own limit.';
	@override String catalogVersion({required Object version}) => 'Provider catalog ${version}';
	@override String get catalogMissing => 'Provider catalog unavailable.';
	@override String get searchModel => 'Search models';
	@override String get searchProvider => 'Search providers';
	@override String get customProvider => 'Custom (OpenAI-compatible endpoint)';
	@override String get customProviderHint => 'For a relay or self-hosted gateway not in the list.';
	@override String get wizardNext => 'Next';
	@override String get wizardApiKeyTitle => 'API key';
	@override String get wizardModelsTitle => 'Pick models';
	@override String get wizardVerifyTitle => 'Verify';
	@override String get wizardModelsHint => 'These come from the endpoint itself. Pick the ones you want to use.';
	@override String get wizardModelsFallbackHint => 'Could not pull the list; these are common models for this provider.';
	@override String get wizardNoModels => 'No list available. Skip this step and add a model by name later — an empty model name also works, the server picks its default.';
	@override String get wizardVerifyHint => 'One real round-trip. A model can be listed and still fail, and only an actual request shows whether this endpoint honours JSON schema.';
	@override String get wizardCheckChat => 'Send a test message';
	@override String get wizardCheckSchema => 'Check JSON output support';
	@override String get wizardCheckSchemaWarn => 'This endpoint ignores JSON schema. AI search still works through the prompt-contract path, just a little slower.';
	@override String get unsavedBadge => 'Unsaved changes';
	@override String get unsavedTitle => 'Unsaved changes';
	@override String get unsavedBody => 'This page has changes you haven\'t saved yet. Leaving now discards them.';
	@override String get saveAndLeave => 'Save and leave';
	@override String get discardChanges => 'Discard';
	@override String get savedToast => 'Saved';
}

// Path: common.pagination
class _TranslationsCommonPaginationDe extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Insgesamt ${num} Elemente';
	@override String get jumpToPage => 'Zu Seite springen';
	@override String pleaseEnterPageNumber({required Object max}) => 'Bitte Seitenzahl eingeben (1-${max})';
	@override String get pageNumber => 'Seitenzahl';
	@override String get jump => 'Springen';
	@override String invalidPageNumber({required Object max}) => 'Bitte eine gültige Seitenzahl eingeben (1-${max})';
	@override String get invalidInput => 'Bitte eine gültige Seitenzahl eingeben';
	@override String get waterfall => 'Wasserfall';
	@override String get pagination => 'Seitennummerierung';
}

// Path: errors.network
class _TranslationsErrorsNetworkDe extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Netzwerkfehler – ';
	@override String get failedToConnectToServer => 'Verbindung zum Server fehlgeschlagen';
	@override String get serverNotAvailable => 'Server nicht verfügbar';
	@override String get requestTimeout => 'Zeitüberschreitung der Anfrage';
	@override String get unexpectedError => 'Unerwarteter Fehler';
	@override String get invalidResponse => 'Ungültige Antwort';
	@override String get invalidRequest => 'Ungültige Anfrage';
	@override String get invalidUrl => 'Ungültige URL';
	@override String get invalidMethod => 'Ungültige Methode';
	@override String get invalidHeader => 'Ungültiger Header';
	@override String get invalidBody => 'Ungültiger Anfragetext';
	@override String get invalidStatusCode => 'Ungültiger Statuscode';
	@override String get serverError => 'Serverfehler';
	@override String get requestCanceled => 'Anfrage abgebrochen';
	@override String get invalidPort => 'Ungültiger Port';
	@override String get proxyPortError => 'Proxy-Port-Fehler';
	@override String get connectionRefused => 'Verbindung abgelehnt';
	@override String get networkUnreachable => 'Netzwerk nicht erreichbar';
	@override String get noRouteToHost => 'Keine Route zum Host';
	@override String get connectionFailed => 'Verbindung fehlgeschlagen';
	@override String get sslConnectionFailed => 'SSL-Verbindung fehlgeschlagen, bitte prüfen Sie Ihre Netzwerkeinstellungen';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingDe extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tastenkürzel';
	@override String get entryLabel => 'Tastenkürzel';
	@override String get entryDesc => 'Tastenkürzel der App anpassen (hauptsächlich für Desktop)';
	@override String get desktopHint => 'Tastenkürzel gelten hauptsächlich für Desktop-Tastaturen; auf Mobilgeräten werden meist Gesten verwendet.';
	@override String get resetAll => 'Alle auf Standard zurücksetzen';
	@override String get resetAllConfirm => 'Alle Tastenkürzel der App auf die Standardwerte zurücksetzen?';
	@override String get resetToDefault => 'Auf Standard zurücksetzen';
	@override String get resetScope => 'Diesen Bereich zurücksetzen';
	@override String get notSet => 'Nicht festgelegt';
	@override String get addShortcut => 'Tastenkürzel hinzufügen';
	@override String get removeShortcut => 'Dieses Tastenkürzel entfernen';
	@override String get pressNewShortcut => 'Neues Tastenkürzel drücken…';
	@override String get recordingCancelHint => 'Esc drücken zum Abbrechen';
	@override String get mouseHint => 'Sie können auch Seitentasten der Maus (Zurück / Vorwärts) oder die mittlere Taste belegen';
	@override String get mouseNotSupportedInScope => 'Dieser Bereich verarbeitet keine Maustasten; verwenden Sie stattdessen die Tastatur';
	@override String get capabilityKeyboardOnly => 'Dieser Bereich akzeptiert nur Tastaturtasten';
	@override String get capabilityKeyboardAndMouse => 'Dieser Bereich akzeptiert Tastaturtasten sowie die mittlere und die seitlichen Maustasten';
	@override String get capabilityKeyboardAndMouseMobile => 'Dieser Bereich akzeptiert Tastaturtasten sowie die mittlere und die vordere Maustaste (die Zurück-Taste ist vom System belegt)';
	@override String get rejectMultipleButtons => 'Drücken Sie jeweils nur eine Maustaste';
	@override String get rejectPlatformBack => 'Das System verwendet dies bereits für Zurück; eine Belegung würde zweimal zurückgehen';
	@override String get detectedLabel => 'Erkannt';
	@override String get reservedKey => 'Diese Taste ist vom System reserviert und kann nicht belegt werden';
	@override String reservedForGlobalBack({required Object action}) => 'Diese Taste ist mit „${action}“ belegt; sie bleibt hier reserviert, damit Sie diesen Bildschirm weiterhin verlassen können';
	@override String get conflictTitle => 'Tastenkürzel-Konflikt';
	@override String conflictMessage({required Object action}) => 'Diese Kombination ist bereits mit „${action}“ belegt. Wenn Sie fortfahren, wird die vorhandene Belegung entfernt.';
	@override String get conflictContinue => 'Trotzdem belegen';
	@override String get shadowWarningTitle => 'Überschneidung mit globalem Tastenkürzel';
	@override String shadowWarningMessage({required Object action}) => 'Diese Kombination ist global mit „${action}“ belegt. Wenn Sie sie hier belegen, wird diese Aktion nur innerhalb dieses Bereichs überschrieben.';
	@override String globalShadowedMessage({required Object scope, required Object action}) => 'Diese Kombination ist bereits in ${scope} mit „${action}“ belegt. In diesem Bereich wird dieses globale Tastenkürzel dadurch überschrieben.';
	@override String get searchHint => 'Tastenkürzel suchen…';
	@override String get scopeGlobal => 'Global';
	@override String get scopeGallery => 'Galerie';
	@override String get scopeVideo => 'Video';
	@override String get categoryNavigation => 'Navigation';
	@override String get categoryZoom => 'Zoom';
	@override String get categoryPlayback => 'Wiedergabe';
	@override String get categorySeek => 'Spulen';
	@override String get categoryVolume => 'Lautstärke';
	@override String get categoryDisplay => 'Anzeige';
	@override String get actionGlobalBack => 'Zurück';
	@override String get actionGalleryNext => 'Nächstes Foto';
	@override String get actionGalleryPrevious => 'Vorheriges Foto';
	@override String get actionGalleryZoomIn => 'Vergrößern';
	@override String get actionGalleryZoomOut => 'Verkleinern';
	@override String get actionGalleryResetZoom => 'Zoom zurücksetzen';
	@override String get actionGalleryPlayPause => 'Wiedergabe / Pause';
	@override String get actionGallerySeekBackward => 'Zurückspulen';
	@override String get actionGallerySeekForward => 'Vorspulen';
	@override String get actionGalleryToggleMute => 'Stummschaltung umschalten';
	@override String get actionPlayPause => 'Wiedergabe / Pause';
	@override String get actionSpeedUp => 'Geschwindigkeit erhöhen';
	@override String get actionSpeedDown => 'Geschwindigkeit verringern';
	@override String get actionSeekForward => 'Vorspulen';
	@override String get actionSeekBackward => 'Zurückspulen';
	@override String get actionVolumeUp => 'Lautstärke erhöhen';
	@override String get actionVolumeDown => 'Lautstärke verringern';
	@override String get actionToggleMute => 'Stummschaltung umschalten';
	@override String get actionToggleFullscreen => 'Vollbild umschalten';
	@override String get seekLongPressHint => 'Halten Sie die Taste zum Vor-/Zurückspulen gedrückt, um den Langdruck-Geschwindigkeitsmodus auszulösen';
	@override String get zoomSectionTitle => 'Bildzoom (fest)';
	@override String get zoomFixedNote => 'Die folgenden Tastenkürzel sind fest und können nicht geändert werden';
	@override String get zoomScaleLabel => 'Bild vergrößern';
	@override String get zoomScaleHint => 'Strg + Mausrad';
	@override String get zoomRotateLabel => 'Bild drehen';
	@override String get zoomRotateHint => 'Umschalt + Mausrad';
	@override String get zoomPinchGesture => 'Zusammenziehen';
	@override String get zoomTwoFingerRotateGesture => 'Drehen mit zwei Fingern';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsDe extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get name => 'Forum';
	@override String get configureYourForumSettings => 'Konfigurieren Sie Ihre Forum-Einstellungen';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsDe extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Galerie-Einstellungen';
	@override String get gallerySettingsSubtitle => 'Einstellungen des Galerie-Betrachters konfigurieren';
	@override String get defaultViewerQuality => 'Standard-Bildqualität des Betrachters';
	@override String get defaultViewerQualityDesc => 'Wählen Sie, welche Bildqualität beim Öffnen des Galerie-Betrachters standardmäßig angezeigt wird.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsDe extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Inhaltsblockierung';
	@override String get subtitle => 'Videos und Galerien automatisch ausblenden, deren Titel einem Stichwort oder Muster entspricht oder die von einem blockierten Nutzer stammen. Der gesamte Abgleich erfolgt auf Ihrem Gerät — nichts wird hochgeladen.';
	@override String get blocked => 'Blockiert';
	@override String get reveal => 'Anzeigen';
	@override String get reblock => 'Erneut blockieren';
	@override String get why => 'Warum blockiert?';
	@override String get manageRules => 'Regeln verwalten';
	@override String reasonKeyword({required Object value}) => 'Titel enthält „${value}“';
	@override String reasonRegex({required Object value}) => 'Titel entspricht „${value}“';
	@override String get reasonUser => 'Von einem blockierten Nutzer';
	@override String get addRule => 'Regel hinzufügen';
	@override String get editRule => 'Regel bearbeiten';
	@override String get deleteRule => 'Regel löschen';
	@override String get ruleType => 'Regeltyp';
	@override String get keyword => 'Stichwort';
	@override String get regex => 'Regex';
	@override String get userId => 'Nutzer';
	@override String get value => 'Abzugleichender Text';
	@override String get caseSensitive => 'Groß-/Kleinschreibung beachten';
	@override String get regexHint => 'z. B. Vorschau|Teaser';
	@override String get valueRequired => 'Bitte geben Sie den abzugleichenden Text ein';
	@override String get invalidRegex => 'Das ist kein gültiger regulärer Ausdruck';
	@override String get noRules => 'Noch keine Regeln. Tippen Sie auf +, um eine hinzuzufügen.';
	@override String get blockUser => 'Blockieren';
	@override String get unblockUser => 'Entsperren';
	@override String blockUserConfirm({required Object name}) => '„${name}“ blockieren? Deren Videos und Galerien werden in Listen und Suchergebnissen ausgeblendet.';
	@override String get userBlocked => 'Nutzer blockiert';
	@override String get userUnblocked => 'Blockierung des Nutzers aufgehoben';
	@override String get exportRules => 'Exportieren';
	@override String get importRules => 'Importieren';
	@override String get importExport => 'Import / Export';
	@override String get exportSuccess => 'Regeln exportiert';
	@override String get exportFailed => 'Regeln konnten nicht exportiert werden';
	@override String importSuccess({required Object count}) => '${count} Regel(n) importiert';
	@override String get importFailed => 'Regeln konnten nicht importiert werden';
	@override String get regexHelp => 'Musterhilfe';
	@override String get regexHelpTitle => 'Regex-Referenz';
	@override String get regexHelpIntro => 'Ein regulärer Ausdruck gleicht Titel flexibler ab als ein einfaches Stichwort. Einige gängige Beispiele:';
	@override String get regexHelpTapHint => 'Tippen Sie auf ein Beispiel, um es einzusetzen.';
	@override String get regexEx1Pattern => 'Vorschau|Teaser|Bonus';
	@override String get regexEx1Desc => 'Entspricht einem dieser Wörter (| bedeutet „oder“)';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Titel, die mit [Klammern] beginnen';
	@override String get regexEx3Pattern => 'Sammlung\$';
	@override String get regexEx3Desc => 'Titel, die mit „Sammlung“ enden';
	@override String get regexEx4Pattern => 'Folge [0-9]+';
	@override String get regexEx4Desc => '[0-9]+ steht für eine oder mehrere Ziffern — entspricht „Folge 12“';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '[0-9] steht für eine Ziffer und {4} bedeutet vier hintereinander (z. B. ein Jahr)';
	@override String get regexEx1Sample => 'Neuer Spiel-Teaser jetzt online';
	@override String get regexEx2Sample => '[Remux] Ganzer Film';
	@override String get regexEx3Sample => 'Frühlings-Kunstsammlung';
	@override String get regexEx4Sample => 'Meine Serie Folge 12 Zusammenfassung';
	@override String get regexEx5Sample => 'Die besten Highlights von 2024';
	@override String get regexHelpSampleLabel => 'Beispieltitel';
	@override String get regexHelpMatchedTag => 'Blockiert';
	@override String get regexHelpNoMatch => 'Keine Übereinstimmung';
	@override String get regexEx6Pattern => '[Ss]taffel';
	@override String get regexEx6Desc => '[Ss] entspricht einem großen oder kleinen S — hier erfasst es „Staffel“';
	@override String get regexEx6Sample => 'Trailer zur letzten Staffel';
	@override String get regexEx7Pattern => '(der Film|die Serie)';
	@override String get regexEx7Desc => 'Klammern () gruppieren Alternativen — entspricht „der Film“ oder „die Serie“';
	@override String get regexEx7Sample => 'Jetzt die Serie ansehen';
	@override String get regexEx8Pattern => 'Staffeln?';
	@override String get regexEx8Desc => 's? macht den vorherigen Buchstaben optional — entspricht „Staffel“ und „Staffeln“';
	@override String get regexEx8Sample => 'Paket mit zwei Staffeln';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ bedeutet ein oder mehr — entspricht !, !!, !!! ...';
	@override String get regexEx9Sample => 'OMG!!! Muss man sehen';
	@override String get regexEx10Pattern => 'Bonus.*Szene';
	@override String get regexEx10Desc => '.* entspricht beliebigem Text dazwischen — „Bonus … Szene“';
	@override String get regexEx10Sample => 'Bonus Gelöschte Szene';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsDe extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get name => 'Chat';
	@override String get configureYourChatSettings => 'Konfigurieren Sie Ihre Chat-Einstellungen';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsDe extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Download-Einstellungen';
	@override String get enableDownloadNotifications => 'Download-Benachrichtigungen';
	@override String get enableDownloadNotificationsDescription => 'Eine Systembenachrichtigung anzeigen, wenn ein einzelner Download abgeschlossen ist oder fehlschlägt';
	@override String get notificationPermissionDenied => 'Benachrichtigungsberechtigung verweigert. In-App-Benachrichtigungen funktionieren weiterhin; aktivieren Sie Systembenachrichtigungen in den Einstellungen.';
	@override String get storagePermissionStatus => 'Status der Speicherberechtigung';
	@override String get accessPublicDirectoryNeedStoragePermission => 'Zugriff auf öffentliches Verzeichnis erfordert Speicherberechtigung';
	@override String get checkingPermissionStatus => 'Berechtigungsstatus wird geprüft...';
	@override String get storagePermissionGranted => 'Speicherberechtigung erteilt';
	@override String get storagePermissionNotGranted => 'Speicherberechtigung nicht erteilt';
	@override String get storagePermissionGrantSuccess => 'Speicherberechtigung erfolgreich erteilt';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Speicherberechtigung nicht erteilt, einige Funktionen sind möglicherweise eingeschränkt';
	@override String get storagePermissionRationale => 'Um Downloads in dem von Ihnen gewählten Ordner zu speichern, benötigt die App Speicherzugriff.\n\nUnter Android 11 und höher bedeutet das die Berechtigung „Zugriff auf alle Dateien“; ohne sie werden Dateien stattdessen im privaten App-Ordner gespeichert.';
	@override String get storagePermissionRationaleLegacy => 'Um Downloads in dem von Ihnen gewählten Ordner zu speichern, benötigt die App Speicherzugriff.\n\nOhne ihn werden Dateien stattdessen im privaten App-Ordner gespeichert.';
	@override String get grantStoragePermission => 'Speicherberechtigung erteilen';
	@override String get customDownloadPath => 'Benutzerdefinierter Downloadpfad';
	@override String get customDownloadPathDescription => 'Wenn aktiviert, können Sie einen benutzerdefinierten Speicherort für heruntergeladene Dateien wählen';
	@override String get customDownloadPathTip => '💡 Tipp: Die Auswahl öffentlicher Verzeichnisse (z. B. des Downloads-Ordners) erfordert eine Speicherberechtigung; verwenden Sie am besten zuerst die empfohlenen Pfade';
	@override String get androidWarning => 'Android-Hinweis: Vermeiden Sie die Auswahl öffentlicher Verzeichnisse (z. B. des Downloads-Ordners); verwenden Sie am besten app-spezifische Verzeichnisse, um die Zugriffsberechtigungen zu gewährleisten.';
	@override String get publicDirectoryPermissionTip => '⚠️ Hinweis: Sie haben ein öffentliches Verzeichnis ausgewählt; für normale Datei-Downloads ist eine Speicherberechtigung erforderlich';
	@override String get permissionRequiredForPublicDirectory => 'Für öffentliche Verzeichnisse ist eine Speicherberechtigung erforderlich';
	@override String get currentDownloadPath => 'Aktueller Downloadpfad';
	@override String get actualDownloadPath => 'Tatsächlicher Downloadpfad';
	@override String get defaultAppDirectory => 'Standard-App-Verzeichnis';
	@override String get permissionGranted => 'Erteilt';
	@override String get permissionRequired => 'Berechtigung erforderlich';
	@override String get enableCustomDownloadPath => 'Benutzerdefinierten Downloadpfad aktivieren';
	@override String get disableCustomDownloadPath => 'Bei Deaktivierung wird der Standardpfad der App verwendet';
	@override String get customDownloadPathLabel => 'Benutzerdefinierter Downloadpfad';
	@override String get selectDownloadFolder => 'Download-Ordner auswählen';
	@override String get recommendedPath => 'Empfohlener Pfad';
	@override String get selectFolder => 'Ordner auswählen';
	@override String get filenameTemplate => 'Dateinamen-Vorlage';
	@override String get filenameTemplateDescription => 'Passen Sie die Benennungsregeln für heruntergeladene Dateien an, Variablenersetzung wird unterstützt';
	@override String get videoFilenameTemplate => 'Dateinamen-Vorlage für Videos';
	@override String get galleryFolderTemplate => 'Galerie-Ordner-Vorlage';
	@override String get imageFilenameTemplate => 'Dateinamen-Vorlage für Bilder';
	@override String get resetToDefault => 'Auf Standard zurücksetzen';
	@override String get supportedVariables => 'Unterstützte Variablen';
	@override String get supportedVariablesDescription => 'In Dateinamen-Vorlagen können die folgenden Variablen verwendet werden:';
	@override String get copyVariable => 'Variable kopieren';
	@override String get variableCopied => 'Variable kopiert';
	@override String get warningPublicDirectory => 'Warnung: Das ausgewählte öffentliche Verzeichnis ist möglicherweise nicht zugänglich. Wählen Sie am besten ein app-spezifisches Verzeichnis.';
	@override String get downloadPathUpdated => 'Downloadpfad aktualisiert';
	@override String get selectPathFailed => 'Pfad konnte nicht ausgewählt werden';
	@override String get pickerAlreadyActive => 'Die Ordnerauswahl ist bereits geöffnet';
	@override String get unsupportedStorageVolume => 'Nicht unterstützter Speicherort. Wählen Sie einen Ordner im Gerätespeicher oder auf der SD-Karte.';
	@override String get recommendedPathSet => 'Auf empfohlenen Pfad festgelegt';
	@override String get setRecommendedPathFailed => 'Empfohlener Pfad konnte nicht festgelegt werden';
	@override String get templateResetToDefault => 'Auf Standardvorlage zurücksetzen';
	@override String get functionalTest => 'Funktionstest';
	@override String get testInProgress => 'Test läuft...';
	@override String get runTest => 'Test ausführen';
	@override String get testDownloadPathAndPermissions => 'Testen, ob Downloadpfad und Berechtigungskonfiguration ordnungsgemäß funktionieren';
	@override String get testResults => 'Testergebnisse';
	@override String get testCompleted => 'Test abgeschlossen';
	@override String get testMultisegmentDomain => 'Wertebereichsprüfung (mehrere Abschnitte / Überschreitung / Fluchtformen)';
	@override String get testMultisegmentPaths => 'Rendern der Mehrabschnitte-Struktur (issue #126)';
	@override String get testPassed => 'Elemente bestanden';
	@override String get testFailed => 'Test fehlgeschlagen';
	@override String get testStoragePermissionCheck => 'Prüfung der Speicherberechtigung';
	@override String get testStoragePermissionGranted => 'Speicherberechtigung erteilt';
	@override String get testStoragePermissionMissing => 'Speicherberechtigung fehlt, einige Funktionen sind möglicherweise eingeschränkt';
	@override String get testPermissionCheckFailed => 'Berechtigungsprüfung fehlgeschlagen';
	@override String get testDownloadPathValidation => 'Validierung des Downloadpfads';
	@override String get testPathValidationFailed => 'Pfadvalidierung fehlgeschlagen';
	@override String get testFilenameTemplateValidation => 'Validierung der Dateinamen-Vorlage';
	@override String get testAllTemplatesValid => 'Alle Vorlagen sind gültig';
	@override String get testSomeTemplatesInvalid => 'Einige Vorlagen enthalten ungültige Zeichen';
	@override String get testTemplateValidationFailed => 'Vorlagenvalidierung fehlgeschlagen';
	@override String get testDirectoryOperationTest => 'Test der Verzeichnisvorgänge';
	@override String get testDirectoryOperationNormal => 'Verzeichniserstellung und Dateischreiben sind normal';
	@override String get testDirectoryOperationFailed => 'Verzeichnisvorgang fehlgeschlagen';
	@override String get testVideoTemplate => 'Video-Vorlage';
	@override String get testGalleryTemplate => 'Galerie-Vorlage';
	@override String get testImageTemplate => 'Bild-Vorlage';
	@override String get testValid => 'Gültig';
	@override String get testInvalid => 'Ungültig';
	@override String get testSuccess => 'Erfolg';
	@override String get testCorrect => 'Korrekt';
	@override String get testError => 'Fehler';
	@override String get testPath => 'Testpfad';
	@override String get testBasePath => 'Basispfad';
	@override String get testDirectoryCreation => 'Verzeichniserstellung';
	@override String get testFileWriting => 'Dateischreiben';
	@override String get testFileContent => 'Dateiinhalt';
	@override String get checkingPathStatus => 'Pfadstatus wird geprüft...';
	@override String get unableToGetPathStatus => 'Pfadstatus kann nicht abgerufen werden';
	@override String get actualPathDifferentFromSelected => 'Hinweis: Der tatsächliche Pfad weicht vom ausgewählten Pfad ab';
	@override String get grantPermission => 'Berechtigung erteilen';
	@override String get fixIssue => 'Problem beheben';
	@override String get issueFixed => 'Problem behoben';
	@override String get fixFailed => 'Behebung fehlgeschlagen, bitte manuell bearbeiten';
	@override String get lackStoragePermission => 'Fehlende Speicherberechtigung';
	@override String get cannotAccessPublicDirectory => 'Zugriff auf öffentliches Verzeichnis nicht möglich, „Zugriff auf alle Dateien“ erforderlich';
	@override String get cannotCreateDirectory => 'Verzeichnis kann nicht erstellt werden';
	@override String get directoryNotWritable => 'Verzeichnis nicht beschreibbar';
	@override String get insufficientSpace => 'Nicht genügend verfügbarer Speicherplatz';
	@override String get pathValid => 'Pfad ist gültig';
	@override String get validationFailed => 'Validierung fehlgeschlagen';
	@override String get usingDefaultAppDirectory => 'Standard-App-Verzeichnis wird verwendet';
	@override String get appPrivateDirectory => 'Privates App-Verzeichnis';
	@override String get appPrivateDirectoryDesc => 'Sicher und zuverlässig, keine zusätzlichen Berechtigungen erforderlich';
	@override String get downloadDirectory => 'Download-Verzeichnis';
	@override String get downloadDirectoryDesc => 'Systemstandard-Speicherort für Downloads, einfach zu verwalten';
	@override String get moviesDirectory => 'Filme-Verzeichnis';
	@override String get moviesDirectoryDesc => 'System-Filmeverzeichnis, von Medien-Apps erkannt';
	@override String get documentsDirectory => 'Dokumentenverzeichnis';
	@override String get documentsDirectoryDesc => 'iOS-App-Dokumentenverzeichnis';
	@override String get requiresStoragePermission => 'Für den Zugriff ist eine Speicherberechtigung erforderlich';
	@override String get recommendedPaths => 'Empfohlene Pfade';
	@override String get externalAppPrivateDirectory => 'Externes privates App-Verzeichnis';
	@override String get externalAppPrivateDirectoryDesc => 'Privates App-Verzeichnis im externen Speicher, für Nutzer zugänglich, mehr Speicherplatz';
	@override String get internalAppPrivateDirectory => 'Internes privates App-Verzeichnis';
	@override String get internalAppPrivateDirectoryDesc => 'Interner App-Speicher, keine Berechtigungen erforderlich, weniger Speicherplatz';
	@override String get appDocumentsDirectory => 'App-Dokumentenverzeichnis';
	@override String get appDocumentsDirectoryDesc => 'App-spezifisches Dokumentenverzeichnis, sicher und zuverlässig';
	@override String get downloadsFolder => 'Downloads-Ordner';
	@override String get downloadsFolderDesc => 'Systemstandard-Downloadverzeichnis';
	@override String get selectRecommendedDownloadLocation => 'Empfohlenen Download-Speicherort auswählen';
	@override String get noRecommendedPaths => 'Keine empfohlenen Pfade verfügbar';
	@override String get recommended => 'Empfohlen';
	@override String get requiresPermission => 'Berechtigung erforderlich';
	@override String get authorizeAndSelect => 'Autorisieren und auswählen';
	@override String get select => 'Auswählen';
	@override String get permissionAuthorizationFailed => 'Berechtigungsautorisierung fehlgeschlagen, dieser Pfad kann nicht ausgewählt werden';
	@override String get pathValidationFailed => 'Pfadvalidierung fehlgeschlagen';
	@override String get downloadPathSetTo => 'Downloadpfad festgelegt auf';
	@override String get setPathFailed => 'Pfad konnte nicht festgelegt werden';
	@override String get variableTitle => 'Titel';
	@override String get variableAuthorcache => 'Erster gesehener Autorenname (stabil bei Umbenennungen)';
	@override String get variableAuthor => 'Name des Autors';
	@override String get variableUsername => 'Benutzername des Autors';
	@override String get variableQuality => 'Videoqualität';
	@override String get variableFilename => 'Ursprünglicher Dateiname';
	@override String get variableId => 'Inhalts-ID';
	@override String get variableCount => 'Anzahl der Galeriebilder';
	@override String get variableDate => 'Aktuelles Datum (YYYY-MM-DD)';
	@override String get variableTime => 'Aktuelle Uhrzeit (HH-MM-SS)';
	@override String get variableDatetime => 'Aktuelles Datum und Uhrzeit (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'Download-Einstellungen';
	@override String get downloadSettingsSubtitle => 'Downloadpfad und Dateibenennungsregeln konfigurieren';
	@override String get suchAsTitleQuality => 'Zum Beispiel: %title_%quality';
	@override String get suchAsTitleId => 'Zum Beispiel: %title_%id';
	@override String get suchAsTitleFilename => 'Zum Beispiel: %title_%filename';
	@override String get structureSection => 'Speicherstruktur und Namensgebung';
	@override String get structureSectionDescription => 'Heruntergeladene Dateien werden nach der unten gewählten Regel in Unterordner einsortiert. Betrifft nur künftige Downloads; bestehende Dateien bleiben unangetastet.';
	@override String get structureNoticeTitle => 'Neu: automatisch nach Autor einsortieren';
	@override String get structureNoticeBody => 'Unten auswählen · betrifft nur neue Downloads, bestehende Dateien bleiben unangetastet.';
	@override String get presetFlat => 'Flach';
	@override String get presetFlatDesc => 'Alle Dateien direkt im Download-Stammordner';
	@override String get presetAuthor => 'Nach Autor';
	@override String get presetAuthorBadge => 'Empfohlen';
	@override String get presetAuthorDesc => 'Ein Ordner pro Autor · Umbenennungen spalten das Archiv nicht';
	@override String get presetDate => 'Nach Datum';
	@override String get presetDateDesc => 'Nach Download-Datum gruppiert';
	@override String get presetCustomActive => 'Aktiv';
	@override String get structurePreviewLabel => 'Vorschau';
	@override String get structurePreviewNote => 'Farbige Abschnitte sind die Organisationsebenen und folgen der gewählten Regel.';
	@override String get pathTooLongWarning => 'Relativer Pfad über 200 Zeichen, das Speichern kann auf manchen Geräten fehlschlagen';
	@override String get pathTemplateEditorEntry => 'Eigene Pfadvorlage';
	@override String get pathTemplateEditorEntryDesc => 'Ordnerstruktur und Dateinamen selbst bestimmen';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorDe pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorDe._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesDe extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Angesagt';
	@override String get favorites => 'Favoriten';
	@override String get latest => 'Neueste';
	@override String get popularity => 'Beliebtheit';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsDe extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Anfrage fehlgeschlagen, Statuscode';
	@override String get connectionTimeout => 'Verbindungszeitüberschreitung, bitte prüfen Sie die Netzwerkverbindung';
	@override String get sendTimeout => 'Zeitüberschreitung beim Senden der Anfrage';
	@override String get receiveTimeout => 'Zeitüberschreitung beim Empfangen der Antwort';
	@override String get badCertificate => 'Zertifikatsüberprüfung fehlgeschlagen';
	@override String get resourceNotFound => 'Angeforderte Ressource nicht gefunden';
	@override String get accessDenied => 'Zugriff verweigert, ggf. sind Anmeldung oder Berechtigung erforderlich';
	@override String get serverError => 'Interner Serverfehler';
	@override String get serviceUnavailable => 'Dienst vorübergehend nicht verfügbar';
	@override String get requestCancelled => 'Anfrage abgebrochen';
	@override String get connectionError => 'Netzwerkverbindungsfehler, bitte prüfen Sie die Netzwerkeinstellungen';
	@override String get networkRequestFailed => 'Netzwerkanfrage fehlgeschlagen';
	@override String get searchVideoError => 'Unbekannter Fehler bei der Videosuche';
	@override String get getPopularVideoError => 'Unbekannter Fehler beim Abrufen beliebter Videos';
	@override String get getVideoDetailError => 'Unbekannter Fehler beim Abrufen der Videodetails';
	@override String get parseVideoDetailError => 'Unbekannter Fehler beim Abrufen und Verarbeiten der Videodetails';
	@override String get downloadFileError => 'Unbekannter Fehler beim Herunterladen der Datei';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingDe extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Videoinformationen werden abgerufen...';
	@override String get cancel => 'Abbrechen';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesDe extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Video nicht gefunden oder gelöscht';
	@override String get unableToGetVideoPlayLink => 'Wiedergabelink konnte nicht abgerufen werden';
	@override String get getVideoDetailFailed => 'Videodetails konnten nicht abgerufen werden';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoDe extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Videoinfo';
	@override String get currentQuality => 'Aktuelle Qualität';
	@override String get duration => 'Dauer';
	@override String get resolution => 'Auflösung';
	@override String get fileInfo => 'Dateiinfo';
	@override String get fileName => 'Dateiname';
	@override String get fileSize => 'Dateigröße';
	@override String get filePath => 'Dateipfad';
	@override String get copyPath => 'Pfad kopieren';
	@override String get openFolder => 'Ordner öffnen';
	@override String get pathCopiedToClipboard => 'Pfad in die Zwischenablage kopiert';
	@override String get openFolderFailed => 'Ordner konnte nicht geöffnet werden';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideDe extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Beispielvideo';
	@override String get title => 'Anleitung für Gesten & Interaktion';
	@override String get viewGuide => 'Anleitung für Gesten & Interaktion';
	@override String get firstTimeIntro => 'Nehmen Sie sich ein paar Sekunden Zeit, um die Player-Gesten kennenzulernen. Sie können diese Anleitung jederzeit in den Player-Einstellungen erneut öffnen.';
	@override String get startWatching => 'Verstanden, Wiedergabe starten';
	@override String get basicTitle => 'Grundlegende Steuerung';
	@override String get zoomTitle => 'Zoom / Drehen / Verschieben';
	@override String get restoreTip => 'Tippen Sie unten rechts auf die Schaltfläche „Wiederherstellen“, um Zoom, Drehung und Position zurückzusetzen.';
	@override String get mTap => 'Einmaliges Tippen: Steuerelemente ein-/ausblenden';
	@override String get mDoubleTap => 'Doppeltippen: zurückspulen (links) / Pause (Mitte) / vorspulen (rechts)';
	@override String get mHorizontalDrag => 'Horizontales Wischen: spulen';
	@override String get mVerticalDrag => 'Vertikales Wischen: Helligkeit (links) / Lautstärke (rechts)';
	@override String get mLongPress => 'Langdruck: vorübergehende Beschleunigung';
	@override String get mPinch => 'Zusammenziehen mit zwei Fingern: das Bild vergrößern';
	@override String get mRotate => 'Drehen mit zwei Fingern: das Bild drehen';
	@override String get dTap => 'Klick: Steuerelemente ein-/ausblenden';
	@override String get dDoubleTap => 'Doppelklick: zurückspulen (links) / Pause (Mitte) / vorspulen (rechts)';
	@override String get dKeys => 'Spultasten: tippen zum Zurück-/Vorspringen, halten zum Beschleunigen; Geschwindigkeitstasten: die Wiedergabegeschwindigkeit während der normalen Wiedergabe stufenweise ändern; Leertaste: Wiedergabe / Pause';
	@override String get dTrackpadPinch => 'Trackpad-Zusammenziehen: das Bild vergrößern';
	@override String get dTrackpadRotate => 'Trackpad-Drehen: das Bild drehen';
	@override String get dCtrlWheel => 'Strg + Mausrad: um den Cursor zoomen';
	@override String get dShiftWheel => 'Umschalt + Mausrad: um den Cursor drehen';
	@override late final _TranslationsVideoDetailGestureGuideQuestDe quest = _TranslationsVideoDetailGestureGuideQuestDe._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerDe extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Fehler beim Laden der Videoquelle';
	@override String get errorWhileSettingUpListeners => 'Fehler beim Einrichten der Listener';
	@override String get serverFaultDetectedAutoSwitched => 'Serverfehler erkannt, Route automatisch gewechselt und erneuter Versuch';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonDe extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Videoinformationen werden abgerufen...';
	@override String get fetchingVideoSources => 'Videoquellen werden abgerufen...';
	@override String get loadingVideo => 'Video wird geladen...';
	@override String get applyingSolution => 'Lösung wird angewendet...';
	@override String get addingListeners => 'Listener werden hinzugefügt...';
	@override String get successFecthVideoDurationInfo => 'Videodauer erfolgreich abgerufen, Video wird geladen...';
	@override String get successFecthVideoHeightInfo => 'Laden abgeschlossen';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastDe extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Übertragen';
	@override String unableToStartCastingSearch({required Object error}) => 'Suche nach Übertragungsgeräten konnte nicht gestartet werden: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Übertragung an ${deviceName} starten';
	@override String castFailed({required Object error}) => 'Übertragen fehlgeschlagen: ${error}\nBitte suchen Sie erneut nach Geräten oder wechseln Sie das Netzwerk';
	@override String get castStopped => 'Übertragung beendet';
	@override late final _TranslationsVideoDetailCastDeviceTypesDe deviceTypes = _TranslationsVideoDetailCastDeviceTypesDe._(_root);
	@override String get currentPlatformNotSupported => 'Die aktuelle Plattform unterstützt keine Übertragung';
	@override String get unableToGetVideoUrl => 'Video-URL konnte nicht abgerufen werden, bitte später erneut versuchen';
	@override String get stopCasting => 'Übertragung beenden';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetDe dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetDe._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsDe extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Wer heimlich liked';
	@override String get dialogDescription => 'Neugierig, wer sie sind? Blättern Sie durch dieses „Like-Album“~';
	@override String get closeTooltip => 'Schließen';
	@override String get retry => 'Erneut versuchen';
	@override String get noLikesYet => 'Hier ist noch niemand aufgetaucht. Seien Sie der Erste!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Seite ${page} / ${totalPages} · Insgesamt ${totalCount} Personen';
	@override String get prevPage => 'Vorherige Seite';
	@override String get nextPage => 'Nächste Seite';
}

// Path: forum.sitewide
class _TranslationsForumSitewideDe extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get badge => 'Websiteweit';
	@override String get title => 'Websiteweite Ankündigung';
	@override String get readMore => 'Mehr lesen';
}

// Path: forum.errors
class _TranslationsForumErrorsDe extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Bitte eine Kategorie auswählen';
	@override String get threadLocked => 'Dieses Thema ist gesperrt, Antwort nicht möglich';
}

// Path: forum.groups
class _TranslationsForumGroupsDe extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Verwaltung';
	@override String get global => 'Global';
	@override String get chinese => 'Chinesisch';
	@override String get japanese => 'Japanisch';
	@override String get korean => 'Koreanisch';
	@override String get other => 'Sonstiges';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesDe extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Ankündigungen';
	@override String get feedback => 'Feedback';
	@override String get support => 'Support';
	@override String get general => 'Allgemein';
	@override String get guides => 'Anleitungen';
	@override String get questions => 'Fragen';
	@override String get requests => 'Wünsche';
	@override String get sharing => 'Teilen';
	@override String get general_zh => 'Allgemein';
	@override String get questions_zh => 'Fragen';
	@override String get requests_zh => 'Wünsche';
	@override String get support_zh => 'Support';
	@override String get general_ja => 'Allgemein';
	@override String get questions_ja => 'Fragen';
	@override String get requests_ja => 'Wünsche';
	@override String get support_ja => 'Support';
	@override String get korean => 'Koreanisch';
	@override String get other => 'Sonstiges';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsDe extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Offizielle wichtige Mitteilungen und Ankündigungen';
	@override String get feedback => 'Feedback zu den Funktionen und Diensten der Website';
	@override String get support => 'Hilfe bei der Behebung websitebezogener Probleme';
	@override String get general => 'Über jedes Thema diskutieren';
	@override String get guides => 'Teilen Sie Ihre Erfahrungen und Anleitungen';
	@override String get questions => 'Stellen Sie Ihre Fragen';
	@override String get requests => 'Veröffentlichen Sie Ihre Wünsche';
	@override String get sharing => 'Teilen Sie interessante Inhalte';
	@override String get general_zh => 'Über jedes Thema diskutieren';
	@override String get questions_zh => 'Stellen Sie Ihre Fragen';
	@override String get requests_zh => 'Veröffentlichen Sie Ihre Wünsche';
	@override String get support_zh => 'Hilfe bei der Behebung websitebezogener Probleme';
	@override String get general_ja => 'Über jedes Thema diskutieren';
	@override String get questions_ja => 'Stellen Sie Ihre Fragen';
	@override String get requests_ja => 'Veröffentlichen Sie Ihre Wünsche';
	@override String get support_ja => 'Hilfe bei der Behebung websitebezogener Probleme';
	@override String get korean => 'Diskussionen rund um Koreanisch';
	@override String get other => 'Sonstige nicht klassifizierte Inhalte';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsDe extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Nicht unterstützter Benachrichtigungstyp';
	@override String get unknownUser => 'Unbekannter Benutzer';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Nicht unterstützter Benachrichtigungstyp: ${type}';
	@override String get unknownNotificationType => 'Unbekannter Benachrichtigungstyp';
}

// Path: conversation.errors
class _TranslationsConversationErrorsDe extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Bitte einen Benutzer auswählen';
	@override String get pleaseEnterATitle => 'Bitte einen Titel eingeben';
	@override String get clickToSelectAUser => 'Tippen, um einen Benutzer auszuwählen';
	@override String get loadFailedClickToRetry => 'Laden fehlgeschlagen, zum erneuten Versuch tippen';
	@override String get loadFailed => 'Laden fehlgeschlagen';
	@override String get clickToRetry => 'Zum erneuten Versuch tippen';
	@override String get noMoreConversations => 'Keine weiteren Unterhaltungen';
}

// Path: splash.errors
class _TranslationsSplashErrorsDe extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Initialisierung fehlgeschlagen, bitte starten Sie die App neu';
}

// Path: download.errors
class _TranslationsDownloadErrorsDe extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'Bildmodell nicht gefunden';
	@override String get downloadFailed => 'Download fehlgeschlagen';
	@override String get videoInfoNotFound => 'Videoinformationen nicht gefunden';
	@override String get downloadTaskAlreadyExists => 'Download-Aufgabe existiert bereits';
	@override String get downloadTaskSavePathConflict => 'Der Speicherpfad wird bereits von einer anderen Aufgabe verwendet';
	@override String get videoAlreadyDownloaded => 'Video bereits heruntergeladen';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'Hinzufügen der Download-Aufgabe fehlgeschlagen: ${errorInfo}';
	@override String get userPausedDownload => 'Download vom Benutzer pausiert';
	@override String get unknown => 'Unbekannt';
	@override String fileSystemError({required Object errorInfo}) => 'Dateisystemfehler: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Unbekannter Fehler: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'Datei konnte nicht geschrieben werden: ${errorInfo}';
	@override String get connectionTimeout => 'Verbindungszeitüberschreitung';
	@override String get sendTimeout => 'Zeitüberschreitung beim Senden';
	@override String get receiveTimeout => 'Zeitüberschreitung beim Empfangen';
	@override String serverError({required Object errorInfo}) => 'Serverfehler: ${errorInfo}';
	@override String get unknownNetworkError => 'Unbekannter Netzwerkfehler';
	@override String get sslHandshakeFailed => 'SSL-Handshake fehlgeschlagen, bitte prüfen Sie Ihr Netzwerk';
	@override String get connectionFailed => 'Verbindung fehlgeschlagen, bitte prüfen Sie Ihr Netzwerk';
	@override String get serviceIsClosing => 'Der Download-Dienst wird beendet';
	@override String get partialDownloadFailed => 'Download von Teilinhalten fehlgeschlagen';
	@override String get noDownloadTask => 'Keine Download-Aufgabe';
	@override String get taskNotFoundOrDataError => 'Aufgabe nicht gefunden oder Datenfehler';
	@override String get fileNotFound => 'Datei nicht gefunden';
	@override String get openFolderFailed => 'Ordner konnte nicht geöffnet werden';
	@override String get copyDownloadUrlFailed => 'Download-URL konnte nicht kopiert werden';
	@override String openFolderFailedWithMessage({required Object message}) => 'Ordner konnte nicht geöffnet werden: ${message}';
	@override String get directoryNotFound => 'Verzeichnis nicht gefunden';
	@override String get copyFailed => 'Kopieren fehlgeschlagen';
	@override String get openFileFailed => 'Datei konnte nicht geöffnet werden';
	@override String openFileFailedWithMessage({required Object message}) => 'Datei konnte nicht geöffnet werden: ${message}';
	@override String get playLocallyFailed => 'Lokale Wiedergabe fehlgeschlagen';
	@override String playLocallyFailedWithMessage({required Object message}) => 'Lokale Wiedergabe fehlgeschlagen: ${message}';
	@override String get noDownloadSource => 'Keine Download-Quelle';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'Keine Download-Quelle, bitte warten Sie, bis die Informationen geladen sind, und versuchen Sie es erneut';
	@override String get noActiveDownloadTask => 'Keine aktive Download-Aufgabe';
	@override String get noFailedDownloadTask => 'Keine fehlgeschlagene Download-Aufgabe';
	@override String get noCompletedDownloadTask => 'Keine abgeschlossene Download-Aufgabe';
	@override String get taskAlreadyCompletedDoNotAdd => 'Aufgabe bereits abgeschlossen, nicht erneut hinzufügen';
	@override String get linkExpiredTryAgain => 'Link abgelaufen, es wird versucht, einen neuen Download-Link zu erhalten';
	@override String get linkExpiredTryAgainSuccess => 'Link abgelaufen, neuer Download-Link erfolgreich abgerufen';
	@override String get linkExpiredTryAgainFailed => 'Link abgelaufen, das Abrufen eines neuen Download-Links ist fehlgeschlagen';
	@override String get taskDeleted => 'Aufgabe gelöscht';
	@override String unsupportedImageFormat({required Object format}) => 'Nicht unterstütztes Bildformat: ${format}';
	@override String get deleteFileError => 'Datei konnte nicht gelöscht werden, möglicherweise wird sie von einem anderen Prozess verwendet';
	@override String get deleteTaskError => 'Aufgabe konnte nicht gelöscht werden';
	@override String get canNotRefreshVideoTask => 'Video-Aufgabe konnte nicht aktualisiert werden';
	@override String get videoRemovedCanNotRefresh => 'Dieses Video wurde gelöscht oder existiert nicht mehr, daher kann der Download-Link nicht aktualisiert werden';
	@override String get videoInaccessibleCanNotRefresh => 'Auf dieses Video kann nicht zugegriffen werden; es ist möglicherweise privat oder Sie müssen sich erneut anmelden';
	@override String get videoQualityGone => 'Diese Qualität wird nicht mehr angeboten, bitte fügen Sie den Download erneut hinzu';
	@override String get refreshLinkNetworkFailed => 'Netzwerkfehler, der Download-Link kann derzeit nicht aktualisiert werden, bitte später erneut versuchen';
	@override String get taskAlreadyProcessing => 'Aufgabe wird bereits verarbeitet';
	@override String get taskNotFound => 'Aufgabe nicht gefunden';
	@override String get failedToLoadTasks => 'Aufgaben konnten nicht geladen werden';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'Teilweiser Download fehlgeschlagen: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Nicht unterstütztes Bildformat: ${extension}; Sie können versuchen, es auf Ihr Gerät herunterzuladen, um es anzusehen';
	@override String get imageLoadFailed => 'Bild konnte nicht geladen werden';
	@override String get pleaseTryOtherViewer => 'Bitte versuchen Sie, es mit einem anderen Betrachter zu öffnen';
}

// Path: download.timeline
class _TranslationsDownloadTimelineDe extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get today => 'Heute';
	@override String get yesterday => 'Gestern';
	@override String get thisWeek => 'Diese Woche';
	@override String get thisMonth => 'Diesen Monat';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesDe extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get network => 'Netzwerkproblem, ein erneuter Versuch kann helfen';
	@override String get serverRejected => 'Vom Server abgelehnt, möglicherweise müssen Sie sich erneut anmelden';
	@override String get notFound => 'Ressource ist nicht mehr vorhanden oder wurde gelöscht';
	@override String get diskFull => 'Nicht genügend Speicherplatz';
	@override String get fileInUse => 'Die Datei wird von einem anderen Programm verwendet';
	@override String get permission => 'Keine Schreibberechtigung';
	@override String get cancelled => 'Abgebrochen';
	@override String get unknown => 'Unbekannter Fehler';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedDe extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '${num} unvollendete Aufgaben aus der letzten Sitzung wurden pausiert';
	@override String get resume => 'Alle fortsetzen';
	@override String get dismiss => 'Verwerfen';
}

// Path: download.actions
class _TranslationsDownloadActionsDe extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get open => 'Open';
	@override String get play => 'Play';
	@override String get openWith => 'Open with another app';
	@override String get redownload => 'Download again';
	@override String get relocate => 'Move files to…';
	@override String get categorize => 'Categorize…';
	@override String get viewOnline => 'View online page';
	@override String get delete => 'Delete…';
	@override String redownloadStarted({required Object count}) => 'Started downloading ${count} items again';
	@override String get redownloadNone => 'Nothing to download again';
	@override String deleteTitle({required Object count}) => 'Delete ${count} downloads?';
	@override String deleteSummary({required Object count, required Object size}) => '${count} items · ${size}';
	@override String deleteSummaryNoSize({required Object count}) => '${count} items';
	@override String deleteGalleryNote({required Object count}) => 'Size of ${count} galleries not included';
	@override String get deleteFiles => 'Also delete files from disk';
	@override String get deleteFilesDesc => 'When off, only the list entries are removed and the files stay where they are';
	@override String get deleteFilesAllMissing => 'The files are already gone; only the entries will be removed';
	@override String deleteDone({required Object count}) => 'Deleted ${count} items';
	@override String deletePartial({required Object failed}) => 'Could not delete the files of ${failed} items (they may be in use); their entries were kept';
	@override String get removeRecordAnyway => 'Remove entries anyway';
	@override String get fileMissing => 'File is missing';
	@override String get filePending => 'File not found right now, it may still be recoverable';
	@override String get statusActive => 'In progress';
	@override String get statusCompleted => 'Completed';
	@override String get needsAttention => 'Needs attention';
	@override String needsAttentionCount({required Object count}) => 'Needs attention · ${count}';
	@override String get organize => 'Organize';
	@override String get checkIntegrity => 'Check file integrity…';
	@override String get migrateToCurrent => 'Move to current download folder…';
	@override String get migrateNone => 'Everything is already in the current download folder';
}

// Path: download.notice
class _TranslationsDownloadNoticeDe extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String failed({required Object count}) => '${count} downloads failed';
	@override String get retryAll => 'Retry all';
	@override String get view => 'View';
	@override String missing({required Object count}) => 'Files of ${count} downloaded items are missing';
	@override String get handle => 'Handle…';
	@override String outside({required Object count}) => '${count} items are still in the old download folder';
	@override String get migrate => 'Move';
	@override String get dismiss => 'Dismiss';
}

// Path: download.deleteByDate
class _TranslationsDownloadDeleteByDateDe extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Nach Datum löschen';
	@override String get dialogTitle => 'Nach Datum löschen';
	@override String get description => 'Löscht Download-Aufgaben gesammelt nach Erstellungsdatum. Aufgaben, deren Dateien gerade verwendet werden, werden übersprungen; Aufgaben, deren Dateien nicht mehr existieren, werden bereinigt.';
	@override String get modeRange => 'Datumsbereich';
	@override String get modeDays => 'Älter als';
	@override String get startDate => 'Startdatum';
	@override String get endDate => 'Enddatum';
	@override String get notSet => 'Nicht festgelegt';
	@override String get daysUnit => 'Tage';
	@override String olderThanDaysHint({required Object days}) => 'Aufgaben löschen, die vor mehr als ${days} Tag(en) erstellt wurden';
	@override String get noMatch => 'Keine Aufgaben entsprechen der gewählten Bedingung';
	@override String get invalidRange => 'Das Startdatum muss am oder vor dem Enddatum liegen';
	@override String get confirmTitle => 'Löschen bestätigen';
	@override String confirmContent({required Object count}) => '${count} Download-Aufgabe(n) und ihre Dateien löschen? Dies kann nicht rückgängig gemacht werden.';
	@override String deleting({required Object done, required Object total}) => 'Lösche ${done}/${total}…';
	@override String resultSuccess({required Object count}) => '${count} Aufgabe(n) gelöscht';
	@override String resultPartial({required Object deleted, required Object skipped}) => '${deleted} Aufgabe(n) gelöscht; ${skipped} übersprungen (in Verwendung)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationDe extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get moveFiles => 'Move files';
	@override String get moveFilesEllipsis => 'Move files…';
	@override String get chooseDestination => 'Move files to';
	@override String get currentDownloadDir => 'Current download folder';
	@override String get otherFolder => 'Choose another folder…';
	@override String get pickerUnsupported => 'Folders can\'t be picked on this device. Downloads stay in the app\'s own folder.';
	@override String get planning => 'Checking files…';
	@override String get confirmTitle => 'Move files?';
	@override String get confirmNote => 'Files are moved on disk. Watch progress, VR settings and favorites move with them.';
	@override String get nothingToMove => 'Nothing in the selection can be moved. See the reason for each item below.';
	@override String get move => 'Move';
	@override String moving({required Object done, required Object total}) => 'Moving ${done}/${total}';
	@override String get stop => 'Stop';
	@override String get stopping => 'Stopping after the current item…';
	@override String get resultTitle => 'Move finished';
	@override String resultMoved({required Object count}) => '${count} item(s) moved';
	@override String get cancelled => 'Stopped. Items already moved are complete.';
	@override String get alreadyRunning => 'Another move is already in progress';
	@override String get destination => 'Destination';
	@override String get statMove => 'To move';
	@override String get statSkip => 'Skipped';
	@override String get statRenamed => 'Renamed';
	@override String get statMoved => 'Moved';
	@override String get statFailed => 'Not moved';
	@override String get statLeftover => 'Left behind';
	@override String get sectionMove => 'Will be moved';
	@override String get sectionSkip => 'Will be skipped';
	@override String get sectionMoved => 'Moved';
	@override String get sectionFailed => 'Not moved (left where it was)';
	@override String get sectionLeftover => 'Old folders not fully removed';
	@override String get leftoverHint => 'The copy at the new location is complete. These leftovers can be deleted.';
	@override String get from => 'From';
	@override String get to => 'To';
	@override String renamedBadge({required Object name}) => 'Name taken, will be saved as "${name}"';
	@override String get showPaths => 'Show paths';
	@override String get hidePaths => 'Hide paths';
	@override String get revealInFolder => 'Show in folder';
	@override String get copyPath => 'Copy path';
	@override String get pathCopied => 'Path copied';
	@override String stateDownloading({required Object percent}) => 'downloading, ${percent}%';
	@override String get statePending => 'waiting to download';
	@override String statePaused({required Object percent}) => 'paused at ${percent}%';
	@override String get stateFailed => 'download failed';
	@override String get skipAlreadyThere => 'Already in this folder';
	@override String get skipInsideSource => 'The destination is inside this gallery\'s own folder';
	@override String get reasonBusy => 'Busy with another operation (deleting or moving)';
	@override String get reasonSourceLocked => 'The file is in use (for example, playing), so it couldn\'t be removed from the old location. Nothing was changed.';
	@override String get reasonNoSpace => 'The destination ran out of space. The rest of the batch was stopped.';
	@override String get reasonVerifyFailed => 'The copy didn\'t match the original\'s size. The copy was discarded.';
	@override String get reasonIoError => 'Couldn\'t read or write the file. Nothing was changed.';
	@override String systemMessage({required Object message}) => 'System message: ${message}';
	@override String outsideTitle({required Object count}) => '${count} downloaded item(s) are outside this folder';
	@override String get outsideSubtitle => 'They still play where they are. Move them here to keep everything together.';
	@override String get moveHere => 'Move here';
	@override String get missingTitle => 'Files not found';
	@override String get recordedLocation => 'Recorded location';
	@override String get legendExists => 'still exists';
	@override String get legendMissing => 'missing';
	@override String diagVolume({required Object volume}) => 'Storage "${volume}" is not available. The SD card or external drive may not be connected.';
	@override String diagVolumeShort({required Object volume}) => 'storage "${volume}" not connected';
	@override String get diagContainer => 'After an app update, the system moved the app\'s storage. The file is still here:';
	@override String get diagContainerShort => 'app storage moved after update';
	@override String get diagNoAccess => 'The app doesn\'t have permission to read this location. Grant "All files access" and check again.';
	@override String get diagNoAccessShort => 'no permission to read this location';
	@override String diagFolder({required Object folder}) => 'The folder "${folder}" no longer exists.';
	@override String diagFolderShort({required Object folder}) => 'folder "${folder}" no longer exists';
	@override String diagFile({required Object name}) => 'The folder is still there, but "${name}" isn\'t in it.';
	@override String get diagFileShort => 'not found in its folder';
	@override String get diagCandidates => 'Found something in that folder that looks like it (maybe renamed):';
	@override String get diagNoCandidates => 'Nothing with the same size was found in that folder.';
	@override String get useThis => 'Use this';
	@override String get fixPath => 'Fix path';
	@override String get checkAgain => 'Check again';
	@override String get grantPermission => 'Grant permission';
	@override String get locate => 'Find in another folder…';
	@override String get deleteRecord => 'Delete record';
	@override String get locateNotFound => 'This download\'s files aren\'t in that folder';
	@override String get located => 'Found. The record now points to the new location.';
	@override String get stillMissing => 'Still not found';
	@override String downloadedOn({required Object date}) => 'Downloaded ${date}';
	@override String galleryImages({required Object count}) => '${count} images';
	@override String unfinishedDownloading({required Object percent}) => 'Downloading ${percent}%: paused first, the downloaded part moves too, then continues';
	@override String get unfinishedPending => 'Waiting to download: re-queued after the move';
	@override String unfinishedPaused({required Object percent}) => 'Paused at ${percent}%: the downloaded part moves too, stays paused';
	@override String get unfinishedFailed => 'Download failed: the downloaded part moves too';
	@override String get noDataYet => 'Nothing downloaded yet, only the save location changes';
	@override String missingGroup({required Object count}) => '${count} item(s) with missing files';
	@override String get missingSkip => 'Leave as is';
	@override String get missingRedownload => 'Re-download to the destination';
	@override String get missingRemove => 'Remove records';
	@override String missingRemoveVolumeNote({required Object count}) => '${count} of them are on storage that isnt connected and wont be removed';
	@override String failedGroup({required Object count}) => '${count} failed download(s)';
	@override String get failedMoveOnly => 'Just move';
	@override String get failedMoveAndRetry => 'Move, then re-download';
	@override String get failedRemove => 'Remove tasks';
	@override String get failedRemoveNote => 'Their partially downloaded files are deleted too';
	@override String get execute => 'Apply';
	@override String get actionWillRedownload => 'Will be re-downloaded to the destination';
	@override String get actionWillRemove => 'This record will be removed';
	@override String get actionWillKeep => 'Storage not connected, will be kept';
	@override String get actionWillRetry => 'Re-downloaded after the move';
	@override String get actionWillRemoveTask => 'This task will be removed';
	@override String get statRedownload => 'Re-download';
	@override String get statRemoved => 'Removed';
	@override String get sectionRedownloaded => 'Re-download started';
	@override String get sectionRedownloadFailed => 'Couldnt start re-download';
	@override String get redownloadFailedHint => 'Usually the download link is no longer valid (the work was deleted or made private). You can retry later from the download list.';
	@override String get sectionRemoved => 'Removed';
	@override String get sectionKept => 'Kept (storage not connected)';
	@override String get redownload => 'Re-download';
	@override String get redownloadStarted => 'Re-download started';
	@override String get redownloadNotStarted => 'Couldnt start re-download';
	@override String get diagFileShortWithCandidates => 'a file with the same size is in its folder, maybe renamed';
	@override String get cleanupMenu => 'Clean up broken records…';
	@override String cleanupScanning({required Object done, required Object total}) => 'Checking ${done}/${total}';
	@override String get cleanupTitle => 'Clean up broken records';
	@override String cleanupNone({required Object count}) => 'Checked ${count} completed download(s). All files are there.';
	@override String get statChecked => 'Checked';
	@override String get statMissing => 'Missing';
	@override String get statKeep => 'Keep';
	@override String get cleanupGroupGone => 'Files are gone';
	@override String get cleanupGroupRecoverable => 'May still be recoverable';
	@override String get cleanupRecoverableHint => 'Storage not connected, no permission, or maybe renamed. Not selected by default. Open an item to see details and recover it.';
	@override String get selectAll => 'Select all';
	@override String get selectNone => 'Select none';
	@override String removeSelected({required Object count}) => 'Remove selected (${count})';
	@override String redownloadSelected({required Object count}) => 'Re-download selected (${count})';
	@override String processing({required Object done, required Object total}) => 'Processing ${done}/${total}';
	@override String cleanupRemoved({required Object count}) => '${count} record(s) removed';
	@override String cleanupRedownloaded({required Object count}) => 'Re-download started for ${count} item(s)';
	@override String get tapForDetail => 'Details';
	@override String get deleteRecordFailed => 'Couldnt delete the record. Try again later.';
	@override String get sectionNotAttempted => 'Not processed (stopped, left as is)';
	@override String unexpectedError({required Object message}) => 'Stopped because of an error: ${message}. Items already moved are complete.';
}

// Path: download.category
class _TranslationsDownloadCategoryDe extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Kategorien verwalten';
	@override String get label => 'Kategorien';
	@override String get uncategorized => 'Nicht kategorisiert';
	@override String get manage => 'Verwalten';
	@override String get createShortcut => 'Neu';
	@override String get newCategoryHint => 'Name der neuen Kategorie';
	@override String get createSuccess => 'Kategorie erstellt';
	@override String get createFailed => 'Kategorie konnte nicht erstellt werden';
	@override String get nameEmpty => 'Der Kategoriename darf nicht leer sein';
	@override String get emptyHint => 'Noch keine Kategorien. Erstellen Sie eine, um Ihre Downloads zu organisieren.';
	@override String get moveTo => 'In Kategorie verschieben';
	@override String moveToWithCount({required Object count}) => '${count} Element(e) verschieben nach…';
	@override String moveSuccess({required Object title}) => 'Verschoben nach ${title}';
	@override String get moveToUncategorizedSuccess => 'Nach „Nicht kategorisiert“ verschoben';
	@override String get moveFailed => 'Verschieben fehlgeschlagen';
	@override String get renameTitle => 'Kategorie umbenennen';
	@override String get renameHint => 'Kategoriename eingeben';
	@override String get renameSuccess => 'Kategorie umbenannt';
	@override String get renameFailed => 'Kategorie konnte nicht umbenannt werden';
	@override String get deleteTitle => 'Kategorie löschen';
	@override String deleteConfirm({required Object title, required Object count}) => 'Kategorie „${title}“ löschen? Die ${count} Elemente darin werden nach „Nicht kategorisiert“ verschoben. Es werden keine Dateien gelöscht.';
	@override String get deleteSuccess => 'Kategorie gelöscht';
	@override String get deleteFailed => 'Kategorie konnte nicht gelöscht werden';
}

// Path: download.location
class _TranslationsDownloadLocationDe extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => 'Save location';
	@override String get behaviorSection => 'Download behavior';
	@override String get namingSection => 'File naming';
	@override String get advancedSection => 'Advanced';
	@override String get advancedSubtitle => 'Write diagnostics and other tools';
	@override String get volumeInternal => 'Internal storage';
	@override String get volumeSdCard => 'SD card';
	@override String get volumeExternalDrive => 'External drive';
	@override String get appSpace => 'App-only storage';
	@override String get downloadsFolder => 'Downloads';
	@override String get askEveryTime => 'Ask every time';
	@override String askEveryTimeDesc({required Object location}) => 'Choose where to save for each download. Batch downloads go to ${location}';
	@override String freeSpace({required Object size}) => '${size} free';
	@override String get statusWritable => 'Writable';
	@override String get statusNeedsPermission => 'Needs permission';
	@override String get statusFallback => 'Temporarily redirected';
	@override String get statusLowSpace => 'Low space';
	@override String get statusChecking => 'Checking';
	@override String get grant => 'Grant';
	@override String get fix => 'Fix';
	@override String get changeLocation => 'Change location';
	@override String get openInFileManager => 'Open in file manager';
	@override String get moreActions => 'More';
	@override String get copyPath => 'Copy path';
	@override String get pathCopied => 'Path copied';
	@override String get manualInput => 'Enter path manually (advanced)';
	@override String get restoreDefault => 'Restore default';
	@override String get runDiagnostics => 'Run diagnostics';
	@override String get restoredDefault => 'Restored the default location';
	@override String get sheetTitle => 'Choose download location';
	@override String get chooseOtherFolder => 'Choose another folder…';
	@override String get chooseOtherFolderDesc => 'Pick one with the system file picker';
	@override String get optionRecommendedDesc => 'Recommended · no permission needed';
	@override String get optionRecommendedLegacyDesc => 'Recommended · needs storage permission';
	@override String get optionAppPrivateDesc => 'Deleted on uninstall · hidden from the gallery';
	@override String get optionRemovableDesc => 'Needs "All files access"';
	@override String get optionDesktopDownloadsDesc => 'Recommended · your Downloads folder';
	@override String get optionAskEveryTimeDesc => 'Pick a folder for each download';
	@override String get current => 'Current';
	@override String get fallbackBanner => 'Your last download was temporarily saved to app storage because the chosen folder could not be used.';
	@override String get fallbackReasonPermission => 'storage permission is missing';
	@override String get fallbackReasonVolumeMissing => 'the storage device is not connected';
	@override String get fallbackReasonCannotCreate => 'the folder could not be created';
	@override String get fallbackReasonNotWritable => 'the folder cannot be written to';
	@override String fallbackDetail({required Object reason}) => 'Temporarily redirected: ${reason}';
	@override String get errorUnresolvable => 'This location belongs to a cloud drive or another app and cannot be written to directly. Choose a folder on your device storage or SD card.';
	@override String get errorNotWritable => 'This folder cannot be written to (read-only, protected by the system, or disconnected). The location was not changed.';
	@override String get errorVolumeMissing => 'This storage device cannot be found (removed or not connected). The location was not changed.';
	@override String get permissionTitle => 'Permission needed';
	@override String get permissionAllFiles => 'Writing to this folder needs "All files access". If you\'d rather not allow that, use "Downloads › LoveIwara" instead.';
	@override String get permissionLegacy => 'Writing to this folder needs the storage permission. If you\'d rather not allow that, use app-only storage instead.';
	@override String get useDownloadsInstead => 'Use Downloads › LoveIwara';
	@override String get useAppSpaceInstead => 'Use app-only storage';
	@override String get goToSettings => 'Grant';
	@override String get permissionDenied => 'Permission was not granted. The location was not changed.';
	@override String get checking => 'Checking this location…';
	@override String get confirmTitle => 'Use this location?';
	@override String confirmFree({required Object size}) => '${size} free';
	@override String confirmOutside({required Object count}) => '${count} downloaded item(s) stay in the old location';
	@override String get confirmOutsideDesc => 'New downloads will be saved here. What about the ones you already have?';
	@override String get moveThem => 'Move them here';
	@override String get keepThem => 'Keep them where they are';
	@override String get decideLater => 'Decide later';
	@override String get useThisLocation => 'Use this location';
	@override String get locationChanged => 'Download location changed';
	@override String get manualTitle => 'Enter path manually';
	@override String get manualLabel => 'Folder path';
	@override String get manualHint => 'e.g. /storage/emulated/0/Download/LoveIwara';
	@override String get manualSubmit => 'Check and use';
	@override String get manualEmpty => 'Enter a path';
	@override String get manualNotAbsolute => 'Enter a full absolute path';
	@override String get fixStillFailing => 'This location still cannot be used. Choose another one.';
	@override String get fixed => 'The location works again';
}

// Path: download.batchDownload
class _TranslationsDownloadBatchDownloadDe extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Stapel-Download';
	@override String get downloadTaskAlreadyRunning => 'Es läuft bereits eine Aufgabe, bitte warten.';
	@override String get userCancelled => 'Vom Benutzer abgebrochen';
	@override String get failedToGetVideoInfo => 'Videoinformationen konnten nicht abgerufen werden';
	@override String get failedToGetVideoSource => 'Videoquelle konnte nicht ermittelt werden';
	@override String get failedToGetGalleryInfo => 'Galerieinformationen konnten nicht abgerufen werden';
	@override String get galleryNoImages => 'Die Galerie enthält keine Bilder';
	@override String get failedToGetSavePath => 'Speicherpfad konnte nicht ermittelt werden';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Stapel-Download fehlgeschlagen: ${exception}';
	@override String get selectQuality => 'Qualität auswählen';
	@override String get downloading => 'Wird heruntergeladen';
	@override String get downloadResult => 'Download-Ergebnis';
	@override String selectedVideosCount({required Object count}) => '${count} Video(s) ausgewählt';
	@override String selectedGalleriesCount({required Object count}) => '${count} Galerie(n) ausgewählt';
	@override String get qualityNote => 'Ist die gewählte Qualität nicht verfügbar, wird die bestmögliche verfügbare Qualität verwendet';
	@override String progress({required Object current, required Object total}) => 'Verarbeite ${current}/${total}';
	@override String get queued => 'In Warteschlange';
	@override String get success => 'Erfolg';
	@override String get skipped => 'Übersprungen';
	@override String get failed => 'Fehlgeschlagen';
	@override String get failureDetails => 'Fehlerdetails';
	@override String get reasonPrivateVideo => 'Privates Video';
	@override String get reasonAlreadyExists => 'Bereits vorhanden';
	@override String get reasonNoSource => 'Keine Download-Quelle';
	@override String get reasonNoSavePath => 'Speicherpfad nicht ermittelbar';
	@override String get reasonOther => 'Anderer Fehler';
	@override String get startDownload => 'Download starten';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsDe extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'Hinzufügen fehlgeschlagen';
	@override String get addSuccess => 'Erfolgreich hinzugefügt';
	@override String get deleteFolderFailed => 'Ordner löschen fehlgeschlagen';
	@override String get deleteFolderSuccess => 'Ordner erfolgreich gelöscht';
	@override String get folderNameCannotBeEmpty => 'Der Ordnername darf nicht leer sein';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesDe extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI Reasoning (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude Reasoning (erweitertes Denken)';
	@override String get gemini => 'Google Gemini (nativ)';
	@override String get geminiReasoning => 'Google Gemini Reasoning (Denken)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek Reasoning (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeDe extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Wiedergabehinweis: ${message}';
	@override String get networkUnstable => 'Prüfen Sie Ihr Netzwerk; die Wiedergabe kann ruckeln';
	@override String get audioTrackUnavailable => 'Kein Ton verfügbar; das Video läuft weiter';
	@override String get hardwareDecodeFellBack => 'Auf Software-Dekodierung umgeschaltet; kann mehr Energie verbrauchen';
	@override String get videoDecodeProblem => 'Versuchen Sie eine andere Qualität; das Bild kann Störungen aufweisen';
	@override String get repeatedPlaybackProblems => 'Exportieren Sie die Protokolle, um wiederkehrende Wiedergabeprobleme zu melden';
	@override String get issuesSheetTitle => 'Wiedergabeprobleme';
	@override String issueOccurrences({required Object count}) => '${count}-mal aufgetreten';
	@override String issueAtPosition({required Object position}) => 'Bei ${position}';
	@override String get noIssuesRecorded => 'Keine Probleme aufgezeichnet';
	@override String get exportLogsAction => 'Protokolle exportieren';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertDe extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Fehler beim Leeren (Flush)';
	@override String get sinkDegradedTitle => 'Protokollschreiben eingeschränkt';
	@override String get sinkDegradedDetail => 'Dateisenke befindet sich im eingeschränkten Zustand';
	@override String get queueBacklogTitle => 'Rückstand der Schreibwarteschlange';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'Warteschlangentiefe=${queueDepth} (Schwelle=${threshold}, kann den Speicherverbrauch erhöhen)';
	@override String get highFlushLatencyTitle => 'Hohe Flush-Latenz';
	@override String get droppedTooManyTitle => 'Zu viele verworfene Protokolle';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'Verworfen=${droppedCount} (Schwelle=${threshold})';
	@override String get rateLimitedTitle => 'Ratenbegrenzung ausgelöst';
	@override String get exportFailedTitle => 'Fehler beim Protokollexport';
	@override String get fileNearLimitTitle => 'Protokolldatei nahe am Größenlimit';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'Dateinutzung=${usagePercent}% (höherer Rotationsdruck auf IO)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastDe extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'Der Protokolldienst ist nicht initialisiert';
	@override String get exportSuccess => 'Protokolle exportiert. Bitte prüfen Sie die privaten Daten, bevor Sie sie per E-Mail senden.';
	@override String exportFailed({required Object error}) => 'Export fehlgeschlagen: ${error}';
	@override String get supportEmailCopied => 'Support-E-Mail kopiert. Fügen Sie sie in Ihr E-Mail-Programm ein und hängen Sie die Protokolle an.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesDe extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'Relevanz';
	@override String get latest => 'Neueste';
	@override String get views => 'Aufrufe';
	@override String get likes => 'Likes';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeDe extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Willkommen';
	@override String get subtitle => 'Beginnen wir mit Ihrer personalisierten Einrichtung';
	@override String get description => 'Nur wenige Schritte, um das beste Erlebnis für Sie abzustimmen';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicDe extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Grundeinstellungen';
	@override String get subtitle => 'Personalisieren Sie Ihr Erlebnis';
	@override String get description => 'Wählen Sie die Einstellungen, die zu Ihnen passen';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkDe extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Netzwerkeinstellungen';
	@override String get subtitle => 'Netzwerkoptionen konfigurieren';
	@override String get description => 'Passen Sie die Einstellungen an Ihre Netzwerkumgebung an';
	@override String get tip => 'Nach erfolgreicher Konfiguration ist ein Neustart erforderlich, damit die Änderungen wirksam werden';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeDe extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Design-Einstellungen';
	@override String get subtitle => 'Wählen Sie Ihr bevorzugtes Erscheinungsbild';
	@override String get description => 'Personalisieren Sie Ihr visuelles Erlebnis';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerDe extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Player-Einstellungen';
	@override String get subtitle => 'Wiedergabesteuerung konfigurieren';
	@override String get description => 'Legen Sie schnell häufig verwendete Wiedergabeeinstellungen fest';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialDe extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Räumliche Wiedergabe';
	@override String get subtitle => 'Ansehen und Durchsuchen auf dem Headset';
	@override String get description => 'Auf dem Headset erscheinen Videos und Galerien im Raum um Sie herum statt in diesem schwebenden Fenster';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionDe extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Einrichtung abschließen';
	@override String get subtitle => 'Sie sind bereit, Ihre Reise zu beginnen';
	@override String get description => 'Bitte lesen Sie die zugehörigen Vereinbarungen und stimmen Sie ihnen zu';
	@override String get agreementTitle => 'Nutzungsvereinbarung und Community-Regeln';
	@override String get agreementDesc => 'Bevor Sie diese App verwenden, lesen Sie bitte sorgfältig unsere Nutzungsvereinbarung und die Community-Regeln und stimmen Sie ihnen zu. Diese Bedingungen helfen, eine gute Umgebung zu erhalten.';
	@override String get checkboxTitle => 'Ich habe die Nutzungsvereinbarung und die Community-Regeln gelesen und stimme ihnen zu';
	@override String get checkboxSubtitle => 'Wenn Sie nicht zustimmen, können Sie die App nicht verwenden';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonDe extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Diese Einstellungen können jederzeit in den Einstellungen geändert werden';
	@override String get previousStep => 'Vorheriger Schritt';
	@override String get nextStep => 'Nächster Schritt';
	@override String get finishSetup => 'Einrichtung abschließen';
	@override String get agreeAgreementSnackbar => 'Bitte stimmen Sie zuerst der Nutzungsvereinbarung und den Community-Regeln zu';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsDe extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Hohe Qualität';
	@override String get fast => 'Schnell';
	@override String get lite => 'Leicht';
	@override String get moreLite => 'Leichter';
	@override String get custom => 'Eigene';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsDe extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Geeignet für die meisten 1080p-Animationen, insbesondere bei Unschärfe, Resampling- und Kompressionsartefakten. Bietet die höchste wahrgenommene Qualität.';
	@override String get mode_b_hq => 'Geeignet für Animationen mit leichter Unschärfe oder durch Skalierung verursachtem Ringing. Kann Ringing und Aliasing wirksam reduzieren.';
	@override String get mode_c_hq => 'Geeignet für hochwertige Quellen (z. B. native 1080p-Animationen oder Filme). Unterdrückt Rauschen und bietet den höchsten PSNR.';
	@override String get mode_a_a_hq => 'Erweiterte Version von Modus A, bietet höchste wahrgenommene Qualität und kann fast alle degradierten Linien rekonstruieren. Kann Überschärfung oder Ringing erzeugen.';
	@override String get mode_b_b_hq => 'Erweiterte Version von Modus B, bietet höhere wahrgenommene Qualität, optimiert Linien weiter und reduziert Artefakte.';
	@override String get mode_c_a_hq => 'Version von Modus C mit verbesserter wahrgenommener Qualität, hält hohen PSNR und versucht, einige Liniendetails zu rekonstruieren.';
	@override String get mode_a_fast => 'Schnelle Version von Modus A, gleicht Qualität und Leistung aus, geeignet für die meisten 1080p-Animationen.';
	@override String get mode_b_fast => 'Schnelle Version von Modus B, für geringe Artefakte und Ringing mit geringerem Aufwand.';
	@override String get mode_c_fast => 'Schnelle Version von Modus C, für schnelle Rauschunterdrückung und Skalierung hochwertiger Quellen.';
	@override String get mode_a_a_fast => 'Schnelle Version von Modus A+A, für höhere wahrgenommene Qualität auf leistungsbegrenzten Geräten.';
	@override String get mode_b_b_fast => 'Schnelle Version von Modus B+B, bietet verbesserte Linienreparatur und Artefaktverarbeitung für leistungsbegrenzte Geräte.';
	@override String get mode_c_a_fast => 'Schnelle Version von Modus C+A, verarbeitet hochwertige Quellen schnell und bietet leichte Linienreparatur.';
	@override String get upscale_only_s => 'Ultraschnelles x2-Upscaling nur mit dem schnellsten CNN-Modell, keine Reparatur und Rauschunterdrückung, minimaler Leistungsaufwand.';
	@override String get upscale_deblur_fast => 'Schnelles Upscaling und Deblurring mit herkömmlichen Nicht-CNN-Algorithmen, besser als Standard-Player-Algorithmen bei sehr geringem Leistungsaufwand.';
	@override String get restore_s_only => 'Nur Reparatur mit dem schnellsten CNN-Modell, kein Upscaling. Geeignet für Wiedergabe in nativer Auflösung, wenn Sie die Qualität verbessern möchten.';
	@override String get denoise_bilateral_fast => 'Schnelle Rauschunterdrückung mit herkömmlicher bilateraler Filterung, extrem schnell, geeignet für leichtes Rauschen.';
	@override String get upscale_non_cnn => 'Schnelles Upscaling mit herkömmlichen Algorithmen, sehr geringer Leistungsaufwand, besser als die Player-Standardeinstellungen.';
	@override String get mode_a_fast_darken => 'Modus A (Schnell) + Linienabdunklung, fügt zusätzlich zur schnellen Variante A eine Linienabdunklung für kräftigere, stilisierte Linien hinzu.';
	@override String get mode_a_hq_thin => 'Modus A (HQ) + Linienverdünnung, fügt zusätzlich zur hochwertigen Variante A eine Linienverdünnung für ein feineres Erscheinungsbild hinzu.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesDe extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Mode A (HQ)';
	@override String get mode_b_hq => 'Mode B (HQ)';
	@override String get mode_c_hq => 'Mode C (HQ)';
	@override String get mode_a_a_hq => 'Mode A+A (HQ)';
	@override String get mode_b_b_hq => 'Mode B+B (HQ)';
	@override String get mode_c_a_hq => 'Mode C+A (HQ)';
	@override String get mode_a_fast => 'Mode A (Fast)';
	@override String get mode_b_fast => 'Mode B (Fast)';
	@override String get mode_c_fast => 'Mode C (Fast)';
	@override String get mode_a_a_fast => 'Mode A+A (Fast)';
	@override String get mode_b_b_fast => 'Mode B+B (Fast)';
	@override String get mode_c_a_fast => 'Mode C+A (Fast)';
	@override String get upscale_only_s => 'CNN-Upscaling (Ultraschnell)';
	@override String get upscale_deblur_fast => 'Upscaling & Deblurring (Schnell)';
	@override String get restore_s_only => 'Restaurierung (Ultraschnell)';
	@override String get denoise_bilateral_fast => 'Bilaterale Rauschunterdrückung (Ultraschnell)';
	@override String get upscale_non_cnn => 'Nicht-CNN-Upscaling (Ultraschnell)';
	@override String get mode_a_fast_darken => 'Modus A (Schnell) + Linienabdunklung';
	@override String get mode_a_hq_thin => 'Modus A (HQ) + Linienverdünnung';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseDe extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Schnellzugriff';
	@override String get sourcesSection => 'Ordner';
	@override String get pin => 'Zum Schnellzugriff hinzufügen';
	@override String get unpin => 'Aus dem Schnellzugriff entfernen';
	@override String get pinned => 'Zum Schnellzugriff hinzugefügt';
	@override String get unpinned => 'Aus dem Schnellzugriff entfernt';
	@override String folderCount({required Object count}) => '${count} Ordner';
	@override String videoCount({required Object count}) => '${count} Videos';
	@override String imageCount({required Object count}) => '${count} Bilder';
	@override String get emptyFolder => 'Dieser Ordner ist leer';
	@override String get videosSection => 'Videos';
	@override String get imagesSection => 'Bilder';
	@override String get galleriesSection => 'Galerien';
	@override String get filterAll => 'Alle';
	@override String get searchInFolder => 'In diesem Ordner suchen';
	@override String get searchHint => 'Nach Namen suchen';
	@override String get clearSearch => 'Suche löschen';
	@override String searchNoResult({required Object query}) => 'Keine Treffer für „${query}“';
	@override String viewAllFolders({required Object count}) => 'Alle ${count} Ordner anzeigen';
	@override String viewAllVideos({required Object count}) => 'Alle ${count} Videos anzeigen';
	@override String viewAllImages({required Object count}) => 'Alle ${count} Bilder anzeigen';
	@override String viewAllGalleries({required Object count}) => 'Alle ${count} Galerien anzeigen';
	@override String get location => 'Ort';
	@override String get sourceMissing => 'Diese Quelle ist nicht mehr vorhanden';
	@override String get notScannedYet => 'Dieser Ordner wurde noch nicht gescannt';
	@override String get scanning => 'Dieser Ordner wird gelesen…';
	@override String get deleteFileTitle => 'Diese Datei löschen?';
	@override String deleteFileBody({required Object name}) => '„${name}“ wird endgültig von diesem Gerät entfernt. Dies kann nicht rückgängig gemacht werden.';
	@override String get hideFolder => 'Diesen Ordner ausblenden';
	@override String get unhideFolder => 'Einblenden';
	@override String get showHiddenFolders => 'Ausgeblendete Ordner anzeigen';
	@override String get includeDotFolders => 'Ordner mit . am Anfang scannen';
	@override String get dotFoldersIncluded => 'Ordner mit . am Anfang werden jetzt gescannt';
	@override String get dotFoldersExcluded => 'Ordner mit . am Anfang werden nicht mehr gescannt';
	@override String get showDotFolders => 'Ordner mit . am Anfang anzeigen';
	@override String dotFoldersSkipped({required Object count}) => '${count} Ordner mit . am Anfang werden hier nicht gescannt';
	@override String get scanDotFoldersAction => 'Für diese Quelle aktivieren';
	@override String get otherAppsPrivateNotice => 'Seit Android 11 kann keine App die Dateien anderer Apps in Android/data oder Android/obb lesen, auch diese App nicht. Lade die Videos in der ursprünglichen App herunter oder exportiere sie in einen öffentlichen Ordner wie Download und füge diesen Ordner hier hinzu. Streaming-Caches bestehen meist aus Fragmenten und lassen sich auch gelesen nicht abspielen.';
	@override String get folderHidden => 'Ausgeblendet – wird auch beim Scannen übersprungen';
	@override String get folderUnhidden => 'Nicht mehr ausgeblendet';
	@override String get hiddenFolderBadge => 'Ausgeblendet';
	@override String get deleteFolder => 'Ordner löschen';
	@override String get deleteFolderTitle => 'Diesen Ordner löschen?';
	@override String deleteFolderBody({required Object name}) => '„${name}“ und der gesamte Inhalt werden endgültig von diesem Gerät gelöscht. Das lässt sich nicht rückgängig machen.';
	@override String get deleteFolderIncludesOthers => 'Andere Dateien darin werden ebenfalls gelöscht';
	@override String get folderDeleted => 'Ordner gelöscht';
	@override String get deleteFolderFailed => 'Löschen fehlgeschlagen – keine Berechtigung, oder eine Datei darin wird gerade verwendet';
	@override String get deleteGalleryTitle => 'Diese Galerie löschen?';
	@override String deleteGalleryBody({required Object name}) => 'Der Download-Eintrag und die lokalen Bilddateien von „${name}“ werden gelöscht. Dies kann nicht rückgängig gemacht werden.';
	@override String get galleryResourceMissing => 'Lokale Dateien existieren nicht mehr. Eintrag bereinigt.';
	@override String get viewDownloadDetail => 'Download-Details anzeigen';
	@override String get viewOnlineGallery => 'Auf der Website ansehen';
	@override String get pickFolderTitle => 'Ordner wählen';
	@override String get useThisFolder => 'Diesen Ordner verwenden';
	@override String get noSubfolders => 'Keine Unterordner hier';
	@override String get storageRoot => 'Gerätespeicher';
	@override String get homeFolder => 'Persönlicher Ordner';
	@override String get filesystemRoot => 'Dateisystem-Wurzel';
	@override String get folderUnreadable => 'Dieser Ordner kann nicht gelesen werden';
	@override String get setCover => 'Titelbild festlegen';
	@override String get setAsFolderCover => 'Als Ordner-Titelbild verwenden';
	@override String get folderCoverSet => 'Ordner-Titelbild aktualisiert';
	@override String get setFolderCoverPick => 'Titelbild festlegen…';
	@override String get restoreAutoCover => 'Automatisches Titelbild wiederherstellen';
	@override String get autoCoverRestored => 'Automatisches Titelbild wiederhergestellt';
	@override String get rescanFolder => 'Diesen Ordner erneut scannen';
	@override String get coverPickerTitle => 'Ein Einzelbild auswählen';
	@override String get folderCoverPickerTitle => 'Titelbild wählen';
	@override String get coverPickerEmpty => 'In diesem Ordner sind noch keine Bilder verfügbar. Video-Miniaturbilder werden möglicherweise noch im Hintergrund erzeugt.';
	@override String get coverSaved => 'Titelbild aktualisiert';
	@override String get coverSaveFailed => 'Das Titelbild konnte nicht gespeichert werden';
	@override String get coverUnavailable => 'Aus dieser Datei konnte kein Video-Einzelbild gelesen werden';
	@override String get deleted => 'Gelöscht';
	@override String get deleteFailed => 'Löschen nicht möglich – die Datei wird möglicherweise verwendet oder ist nicht beschreibbar';
	@override String get openFolder => 'Öffnen';
	@override String get favorite => 'Zu Favoriten hinzufügen';
	@override String get unfavorite => 'Aus Favoriten entfernen';
	@override String get favorited => 'Zu Favoriten hinzugefügt';
	@override String get unfavorited => 'Aus Favoriten entfernt';
	@override String get sortBy => 'Sortieren nach';
	@override String get sortAscending => 'Aufsteigend';
	@override String get sortDescending => 'Absteigend';
	@override String get sortFieldName => 'Name';
	@override String get sortFieldModified => 'Änderungsdatum';
	@override String get sortFieldDuration => 'Dauer';
	@override String get sortFieldSize => 'Größe';
	@override String get sortFieldResolution => 'Auflösung';
	@override String get sortFieldFileType => 'Dateityp';
	@override String get sortFieldFps => 'Bildrate';
	@override String get sortFieldFavorited => 'Datum der Favorisierung';
	@override String get emptyAllVideos => 'Noch keine Videos gefunden. Fügen Sie unter „Ordner“ einen Ordner hinzu, um zu beginnen.';
	@override String get emptyAllImages => 'Noch keine Bilder gefunden. Fügen Sie unter „Ordner“ einen Ordner hinzu, um zu beginnen.';
	@override String get emptyFavorites => 'Noch keine Favoriten. Fügen Sie einen über das ⋮-Menü eines Videos hinzu.';
	@override String get emptyPinned => 'Noch keine angehefteten Ordner. Halten Sie einen Ordner unter „Ordner“ gedrückt und wählen Sie „Anheften“.';
	@override String get emptyDownloadedVideos => 'Noch keine abgeschlossenen Video-Downloads.';
	@override String get emptyDownloadedGalleries => 'Noch keine abgeschlossenen Galerie-Downloads.';
	@override String get folderInfo => 'Ordnerinfo';
	@override String get folderInfoName => 'Name';
	@override String get folderInfoPath => 'Pfad';
	@override String get folderInfoSource => 'Quelle';
	@override String get folderInfoContents => 'Inhalt';
	@override String get folderInfoSize => 'Größe auf dem Datenträger';
	@override String get folderInfoScannedAt => 'Zuletzt gescannt';
	@override String get folderInfoNeverScanned => 'Noch nicht gescannt';
	@override String get folderInfoNoPath => 'Diese Quelle hat keinen zu öffnenden Ordner';
	@override String get copyPath => 'Pfad kopieren';
	@override String get pathCopied => 'Pfad kopiert';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsDe extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get size => 'Size';
	@override String get resolution => 'Resolution';
	@override String get duration => 'Duration';
	@override String get modified => 'Modified';
	@override String get lastPlayed => 'Last played';
	@override String get neverPlayed => 'Not watched yet';
	@override String get completed => 'Finished';
}

// Path: localMedia.missing
class _TranslationsLocalMediaMissingDe extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Can\'t find this file';
	@override String get rescanFolder => 'Rescan folder';
	@override String get relistNas => 'Refresh this folder';
	@override String get removeFromList => 'Remove from list';
	@override String get removed => 'Removed from the list. The file on disk was not touched';
	@override String get found => 'Found it';
	@override String nasGone({required Object name}) => '"${name}" is no longer on the NAS: it may have been deleted, moved or renamed. Refresh this folder to see what it contains now.';
}

// Path: localMedia.webdav
class _TranslationsLocalMediaWebdavDe extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get addNas => 'Connect NAS (WebDAV)';
	@override String get connectTitle => 'Connect NAS';
	@override String get editTitle => 'Sign in to NAS again';
	@override String get hint => 'Turn on the WebDAV service in your NAS settings, then enter its address and account.';
	@override String get address => 'Address';
	@override String get addressHint => 'e.g. 192.168.1.10:5005';
	@override String get username => 'Username';
	@override String get password => 'Password';
	@override String get displayName => 'Name (optional)';
	@override String get connect => 'Connect';
	@override String get invalidAddress => 'Invalid address';
	@override String get errorAuth => 'Wrong username or password';
	@override String get errorUnreachable => 'Can\'t reach the server. Check the address and port, and that this device is on the same network as the NAS';
	@override String get errorNotWebdav => 'This address is not a WebDAV service';
	@override String errorGeneric({required Object code}) => 'Connection failed (${code})';
	@override String get errorCredUnreadable => 'Couldn\'t read the saved password. Try again later';
	@override String get certTitle => 'Trust this server?';
	@override String get certBody => 'The server\'s certificate isn\'t trusted by the system (common with self-signed NAS certificates). Make sure this fingerprint matches the one shown in your NAS settings:';
	@override String get certChangedBody => 'This server\'s certificate is different from the one you trusted before. If you didn\'t replace your NAS certificate, someone may be impersonating it. Don\'t continue.';
	@override String get trust => 'Trust';
	@override String get pickRootTitle => 'Choose a folder to add';
	@override String get serverRoot => 'Root';
	@override String get alreadyAdded => 'This NAS folder has already been added';
	@override String get relogin => 'Sign in again';
	@override String get stateAuthFailed => 'Sign-in required';
	@override String get stateCertUntrusted => 'Server certificate changed';
	@override String get stateUnreachable => 'Can\'t reach NAS';
	@override String get stateCredUnreadable => 'Couldn\'t read password';
	@override String get connected => 'Connected';
	@override String get errorForbidden => 'This account has no WebDAV access. Grant it WebDAV permission in the NAS settings.';
	@override String get errorTls => 'Secure connection failed. Check that http:// or https:// matches the NAS settings.';
	@override String get errorTryHttps => 'If the NAS only serves HTTPS, add https:// in front of the address.';
	@override String get previousStep => 'Back';
	@override String get bannerUnreachable => 'Can\'t reach the NAS. Showing what was seen last time.';
	@override String get bannerAuthFailed => 'Login expired. Sign in again to see the latest content.';
	@override String get bannerCertUntrusted => 'The NAS certificate changed. Confirm it to continue.';
	@override String get bannerCredUnreadable => 'Couldn\'t read the saved password. Sign in again.';
}

// Path: settings.downloadSettings.pathTemplateEditor
class _TranslationsSettingsDownloadSettingsPathTemplateEditorDe extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pfadvorlage';
	@override String get subtitle => 'Ordnet Downloads automatisch in Unterordner';
	@override String get tabVideo => 'Video';
	@override String get tabGallery => 'Galerie';
	@override String get tabImage => 'Einzelfoto';
	@override String get previewLabel => 'Vorschau · tatsächliches Speicherergebnis nach Bereinigung';
	@override String get galleryPreviewLabel => 'Vorschau · Galerievorlage = Ordnername (interne Bilder tragen die Bild-ID)';
	@override String get addFolder => 'Ordnerebene hinzufügen';
	@override String get folderCapReached => 'Limit der Ordnerebenen erreicht';
	@override String get folderSegmentHint => '%authorcache, eine Variable oder fester Text';
	@override String get fileSegmentHint => 'z. B. %title_%quality';
	@override String videoCapNote({required Object max}) => 'Die Erweiterung .mp4 wird automatisch angehängt · / in einem Abschnitt teilt ihn in zwei Ebenen · maximal ${max} Ebenen';
	@override String imageCapNote({required Object max}) => 'Die ursprüngliche Erweiterung wird automatisch angehängt · / in einem Abschnitt teilt ihn in zwei Ebenen · maximal ${max} Ebenen';
	@override String galleryCapNote({required Object max}) => 'Die Galerievorlage besteht nur aus Ordnern, maximal ${max} Ebenen · interne Bilder tragen die Bild-ID als Namen';
	@override String get trayHint => 'Zum Einfügen an der Cursorposition tippen · lange drücken für Details';
	@override String get emptySegment => 'Leerer Abschnitt';
	@override String get emptySegmentSaveBlocked => 'Speichern nicht möglich: Es gibt leere Abschnitte, bitte ausfüllen oder entfernen';
	@override String get tooManySegmentsSaveBlocked => 'Speichern nicht möglich: Zu viele Pfadabschnitte (max. 4). Bitte zusammenführen oder entfernen';
	@override String get templateInvalidSaveBlocked => 'Speichern nicht möglich: Die Vorlage enthält ungültige Zeichen';
	@override String get variableInserted => 'Variable eingefügt';
	@override String get savedToast => 'Gespeichert · betrifft nur künftige Downloads';
	@override String get trayCategoryContent => 'Inhalt';
	@override String get trayCategoryAuthor => 'Autor';
	@override String get trayCategoryTime => 'Zeit';
	@override String get chipAuthorcache => 'Autorenname·fest';
	@override String get chipDate => 'Datum';
	@override String get chipTime => 'Uhrzeit';
	@override String get chipDatetime => 'Datum & Zeit';
	@override String get chipCount => 'Nr.';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestDe extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'In Quest zurechtkommen';
	@override String get intro => 'Sehen Sie, welche Steuerung was bewirkt, und probieren Sie es dann in Ihrem Raum aus.';
	@override String get videoTab => 'Räumliches Video';
	@override String get galleryTab => 'Räumliche Galerie';
	@override String get scopeNote => 'Für Bildschirme und Fenster in Ihrem Quest-Raum. Jederzeit in den Player-Einstellungen erneut öffnen.';
	@override String get catalog => 'Die Steuerelemente erkunden';
	@override String lessonCount({required Object current, required Object total}) => '${current} von ${total}';
	@override String get previous => 'Zurück';
	@override String get next => 'Nächste Steuerung';
	@override String get replay => 'Demo erneut abspielen';
	@override String get pauseDemo => 'Demo pausieren';
	@override String get resumeDemo => 'Demo fortsetzen';
	@override String get looping => 'Steuerungsdemo';
	@override String get still => 'Stehende Illustration';
	@override String get done => 'Verstanden, weiter';
	@override String get leftController => 'Linke Hand';
	@override String get rightController => 'Rechte Hand';
	@override String get trigger => 'Zeigefinger-Auslöser';
	@override String get grip => 'Greiftaste';
	@override String get bothGrips => 'Beide Greiftasten';
	@override String get stick => 'Daumenstick';
	@override String get handTracking => 'Handverfolgung';
	@override String get ready => 'Bereit';
	@override String get press => 'Drücken';
	@override String get hold => 'Halten';
	@override String get release => 'Loslassen';
	@override String get result => 'Das Ergebnis sehen';
	@override String get pinch => 'Kneifen';
	@override String get selectTitle => 'Zeigen und auswählen';
	@override String get selectBody => 'Richten Sie den Strahl auf eine Schaltfläche und drücken und lassen Sie dann den Zeigefinger-Auslöser los. Verwenden Sie ihn für Wiedergabe, Einstellungen und Schieberegler im Bedienfeld.';
	@override String get selectHint => 'Der Zeigefinger-Auslöser befindet sich hinter der Schaltflächenvorderseite. Die Greiftaste am inneren Griff greift Fenster.';
	@override String get panelTitle => 'Das Bedienfeld ein- oder ausblenden';
	@override String get panelBody => 'Zeigen Sie außerhalb des Bedienfelds und tippen Sie dann auf den Zeigefinger-Auslöser, um es ein- oder auszublenden. Mit Handverfolgung bewirkt ein kurzes Kneifen außerhalb des Bedienfelds dasselbe.';
	@override String get panelHint => 'Verwenden Sie ein kurzes Tippen ohne Ziehen. Halten und Bewegen ist ein Ziehen, kein Umschalten des Bedienfelds.';
	@override String get playTitle => 'Abspielen und pausieren';
	@override String get playBody => 'Zeigen Sie weg vom Bedienfeld und drücken Sie A rechts oder X links, um abzuspielen oder zu pausieren. Sie können auch die Wiedergabetaste im Bedienfeld auswählen.';
	@override String get playHint => 'Dieses Standard-Tastenkürzel kann in den Einstellungen des räumlichen Players deaktiviert werden. Wenn Sie auf das Bedienfeld zeigen, gehen Eingaben an das Bedienfeld.';
	@override String get seekTitle => 'Mit dem Stick spulen';
	@override String get seekBody => 'Bewegen Sie einen der Sticks leicht nach links oder rechts für einen 5-Sekunden-Schritt. Halten Sie ihn, um schneller zu spulen, während die Zielzeit als Vorschau angezeigt wird. Lassen Sie los, um das Spulen zu übernehmen.';
	@override String get seekHint => 'Halten Sie den Strahl dieses Controllers vom Bedienfeld fern. Ein Stick, der auf das Bedienfeld zeigt, scrollt stattdessen das Bedienfeld.';
	@override String get browseTitle => 'Mit dem Stick blättern';
	@override String get browseBody => 'Bewegen Sie einen der Sticks nach links oder rechts für das vorherige oder nächste Element; halten, um weiterzublättern. Sie können auch ein Miniaturbild im Filmstreifen auswählen.';
	@override String get browseHint => 'Videos in einer Galerie sind ebenfalls Elemente. Wenn Sie auf das Bedienfeld zeigen, scrollt der Stick das Bedienfeld.';
	@override String get swipeTitle => 'Zum Umblättern quer ziehen';
	@override String get swipeBody => 'Zielen Sie auf das Bild, halten Sie den Zeigefinger-Auslöser und ziehen Sie nach links. Lassen Sie nach dem Umblätter-Signal los, um weiterzublättern; ziehen Sie nach rechts, um zurückzugehen. Kneifen und Ziehen funktioniert ebenfalls.';
	@override String get swipeHint => 'Bilder müssen bei 1× sein, um durch Ziehen umzublättern. Galerie-Videos unterstützen dies ebenfalls. Die Bühne bleibt stehen, bis Sie loslassen.';
	@override String get zoomTitle => 'In das Bild hineinzoomen';
	@override String get zoomBody => 'Zielen Sie auf ein Detail im Bild, halten Sie den Zeigefinger-Auslöser und schieben Sie dann den Stick nach oben, um hineinzuzoomen, oder nach unten, um herauszuzoomen. Der Zoom ist dort verankert, wo Sie gedrückt haben.';
	@override String get zoomHint => 'Dadurch wird das Bild innerhalb seines Fensters vergrößert. Ohne Halten des Bildes passt Auf/Ab den Betrachtungsabstand an.';
	@override String get panTitle => 'Das Bild verschieben und wiederherstellen';
	@override String get panBody => 'Sobald Sie hineingezoomt haben, halten Sie den Zeigefinger-Auslöser und ziehen Sie, um sich umzusehen. Doppeltippen Sie auf das Bild, um auf 2,5× zu zoomen oder es wiederherzustellen. Mit Händen zweimal schnell kneifen.';
	@override String get panHint => 'Durch Ziehen wird ein gezoomtes Bild verschoben. Stellen Sie vor dem Ziehen zum Umblättern auf 1× zurück.';
	@override String get slideshowTitle => 'Eine Diashow starten';
	@override String get slideshowBody => 'Bei einem Bild startet oder pausiert A / X die Diashow. Das Bedienfeld bietet Intervalle von 3, 5, 10 oder 20 Sekunden sowie Standard- oder Original-Bildqualität.';
	@override String get slideshowHint => 'Bei einem Galerie-Video steuert A / X die Wiedergabe dieses Videos. Das Controller-Tastenkürzel muss in den Einstellungen aktiviert sein.';
	@override String get moveTitle => 'Den Bildschirm greifen und bewegen';
	@override String get moveBody => 'Halten Sie die Greiftaste am inneren Griff, bewegen Sie den Controller, um den Bildschirm zu positionieren, und lassen Sie dann los. Beim Zuschauen können Sie den Bildschirm greifen, ohne darauf zu zeigen.';
	@override String get moveHint => 'Wenn Sie auf das App-Fenster oder das Bedienfeld zeigen, wird zuerst dieses Fenster gegriffen. Bei Panoramavideos passt das Greifen die Ausrichtung an.';
	@override String get scaleTitle => 'Mit beiden Händen skalieren';
	@override String get scaleBody => 'Halten Sie beide Greiftasten. Spreizen Sie die Hände, um den Bildschirm zu vergrößern, oder führen Sie sie zusammen, um ihn zu verkleinern. Bei der Handverfolgung halten Sie mit beiden Händen ein Kneifen.';
	@override String get scaleHint => 'Für flache oder gewölbte Bildschirme, einschließlich der Galerie-Bühne. Halten Sie die Strahlen vom Bedienfeld fern. Dadurch wird der gesamte Bildschirm skaliert.';
	@override String get distanceTitle => 'Betrachtungsabstand anpassen';
	@override String get distanceBody => 'Schieben Sie den Stick nach oben, um den Bildschirm zu entfernen, oder nach unten, um ihn näher zu bringen. Während Sie ein Fenster greifen, bewegt Auf/Ab dieses Fenster. Die Lautstärke stellen Sie im Bedienfeld ein.';
	@override String get distanceHint => 'Zeigen Sie weg vom Bedienfeld. Beim Halten eines Bildes wird Auf/Ab zur Bildvergrößerung; Panoramavideos passen stattdessen die Ansicht an.';
	@override String get resizeTitle => 'Ränder und Ecken verwenden';
	@override String get resizeBody => 'Der Rahmen leuchtet auf, wenn sich Ihr Strahl einem Rand nähert. Halten Sie den Auslöser oder kneifen Sie an einem Rand, um das Fenster zu verschieben; ziehen Sie an einer Ecke, um die Größe zu ändern.';
	@override String get resizeHint => 'Funktioniert am App-Fenster, am Bedienfeld und am Bildschirm. Das App-Fenster ändert Breite und Höhe; Bildschirme behalten ihr Seitenverhältnis.';
	@override String get navigationTitle => 'Zurückgehen und Einstellungen öffnen';
	@override String get navigationBody => 'B / Y geht eine Ebene zurück: ein Popup schließen oder zum Start des Bedienfelds zurückkehren, das Bedienfeld ausblenden und dann zur App zurückkehren. Die linke Menü-Taste öffnet die räumlichen Einstellungen.';
	@override String get navigationHint => 'Die rechte Meta-Taste gehört zum System. Das System-Recenter bringt die Ansicht wieder nach vorne, wobei Bildschirmgröße und -abstand erhalten bleiben.';
	@override String get handsTitle => 'Hände verwenden';
	@override String get handsBody => 'Wenn die Handverfolgung aktiviert ist, richten Sie den Systemstrahl auf eine Schaltfläche, kneifen Sie Daumen und Zeigefinger zusammen und lassen Sie dann los. Verwenden Sie das Bedienfeld für Wiedergabe, Spulen und Galerie-Navigation.';
	@override String get handsHint => 'Kneifen Sie außerhalb, um das Bedienfeld umzuschalten. Kneifen Sie an einem Rand, um es zu verschieben, an einer Ecke, um die Größe zu ändern, oder mit beiden Händen und spreizen Sie, um den Bildschirm zu vergrößern.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesDe extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Mediaplayer';
	@override String get mediaServer => 'Medienserver';
	@override String get internetGatewayDevice => 'Router';
	@override String get basicDevice => 'Einfaches Gerät';
	@override String get dimmableLight => 'Smartes Licht';
	@override String get wlanAccessPoint => 'WLAN-Zugangspunkt';
	@override String get wlanConnectionDevice => 'WLAN-Verbindungsgerät';
	@override String get printer => 'Drucker';
	@override String get scanner => 'Scanner';
	@override String get digitalSecurityCamera => 'Digitale Überwachungskamera';
	@override String get unknownDevice => 'Unbekanntes Gerät';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetDe extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetDe._(TranslationsDe root) : this._root = root, super.internal(root);

	final TranslationsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Remote-Übertragung';
	@override String get close => 'Schließen';
	@override String get searchingDevices => 'Geräte werden gesucht...';
	@override String get searchPrompt => 'Klicken Sie auf die Suchschaltfläche, um erneut nach Übertragungsgeräten zu suchen';
	@override String get searching => 'Suche läuft';
	@override String get searchAgain => 'Erneut suchen';
	@override String get noDevicesFound => 'Keine Übertragungsgeräte gefunden\nBitte stellen Sie sicher, dass sich die Geräte im selben Netzwerk befinden';
	@override String get searchingDevicesPrompt => 'Geräte werden gesucht, bitte warten...';
	@override String get cast => 'Übertragen';
	@override String connectedTo({required Object deviceName}) => 'Verbunden mit: ${deviceName}';
	@override String get notConnected => 'Kein Gerät verbunden';
	@override String get stopCasting => 'Übertragung beenden';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsDe {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Persönliches Profil',
			'personalProfile.editPersonalProfile' => 'Persönliches Profil bearbeiten',
			'personalProfile.avatar' => 'Avatar',
			'personalProfile.background' => 'Hintergrund',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'Benutzerprofil konnte nicht abgerufen werden: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Empfohlene Auflösung: ${resolution}, Dateigröße < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Unterstützte Formate: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Premium-Nutzer können dynamische ${type} verwenden (${formats})',
			'personalProfile.homepageBackground' => 'Startseiten-Hintergrund',
			'personalProfile.basicInfo' => 'Grundlegende Informationen',
			'personalProfile.nickname' => 'Spitzname',
			'personalProfile.username' => 'Benutzername',
			'personalProfile.copyUsername' => 'Benutzernamen kopieren',
			'personalProfile.usernameCopied' => 'Benutzername kopiert',
			'personalProfile.personalIntroduction' => 'Persönliche Vorstellung',
			'personalProfile.noPersonalIntroduction' => 'Keine persönliche Vorstellung',
			'personalProfile.clickToEdit' => 'Zum Bearbeiten tippen',
			'personalProfile.privacySettings' => 'Datenschutzeinstellungen',
			'personalProfile.hideSensitiveContent' => 'Sensible Inhalte ausblenden',
			'personalProfile.hideSensitiveContentDesc' => 'Blendet alle Videos oder Bilder mit sensiblen Tags aus.',
			'personalProfile.notificationSettings' => 'Benachrichtigungseinstellungen',
			'personalProfile.contentCommentNotification' => 'Benachrichtigung bei Inhaltskommentaren',
			'personalProfile.contentCommentNotificationDesc' => 'Benachrichtigen, wenn jemand Ihre Inhalte kommentiert.',
			'personalProfile.commentReplyNotification' => 'Benachrichtigung bei Kommentarantworten',
			'personalProfile.commentReplyNotificationDesc' => 'Benachrichtigen, wenn jemand auf Ihren Kommentar antwortet.',
			'personalProfile.mentionNotification' => 'Benachrichtigung bei Erwähnungen',
			'personalProfile.mentionNotificationDesc' => 'Benachrichtigen, wenn jemand Sie in Inhalten erwähnt.',
			'personalProfile.accountInfo' => 'Kontoinformationen',
			'personalProfile.registrationTime' => 'Registrierungszeitpunkt',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'Einstellungen konnten nicht aktualisiert werden: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'Benachrichtigungseinstellungen konnten nicht aktualisiert werden: ${error}',
			'personalProfile.editNickname' => 'Spitznamen bearbeiten',
			'personalProfile.nicknameCannotBeEmpty' => 'Spitzname darf nicht leer sein',
			'personalProfile.changeSuccess' => 'Erfolgreich geändert',
			'personalProfile.unsupportedFileFormat' => 'Nicht unterstütztes Dateiformat',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'Dateigröße darf ${size} nicht überschreiten',
			'personalProfile.uploadFailed' => 'Upload fehlgeschlagen',
			'personalProfile.avatarUpdatedSuccessfully' => 'Avatar erfolgreich aktualisiert',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'Avatar konnte nicht aktualisiert werden: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Hintergrund erfolgreich aktualisiert',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'Hintergrund konnte nicht aktualisiert werden: ${error}',
			'personalProfile.editPersonalIntroduction' => 'Persönliche Vorstellung bearbeiten',
			'personalProfile.enterPersonalIntroduction' => 'Bitte geben Sie Ihre persönliche Vorstellung ein',
			'tutorial.specialFollowFeature' => 'Spezielles Folgen',
			'tutorial.specialFollowDescription' => 'Markieren Sie die Autoren, die Sie am meisten verfolgen, als „Spezielles Folgen“ und springen Sie dann von hier direkt zu deren neuesten Uploads.',
			'tutorial.stepsTitle' => 'Drei Schritte',
			'tutorial.stepFollowAuthor' => 'Tippen Sie auf „Folgen“ auf der Video-, Galerie- oder Profilseite des Autors.',
			'tutorial.stepPickSpecial' => 'Tippen Sie erneut auf „Gefolgt“ und wählen Sie dann im Menü „Spezielles Folgen“.',
			'tutorial.stepSwitchHere' => 'Kommen Sie hierher zurück und wechseln Sie mit der Avatar-Auswahl oben zu diesem Autor.',
			'tutorial.specialFollowManagementTip' => 'Verwalten Sie die Liste „Spezielles Folgen“ unter Seitenleiste – Folge-Liste – Spezielles Folgen.',
			'tutorial.gotIt' => 'Verstanden',
			'common.sort' => 'Sortieren',
			'common.filter' => 'Filter',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Abbrechen',
			'common.select' => 'Auswählen',
			'common.save' => 'Speichern',
			'common.delete' => 'Löschen',
			'common.visit' => 'Besuchen',
			'common.loading' => 'Wird geladen…',
			'common.scrollToTop' => 'Nach oben scrollen',
			'common.privacyHint' => 'Datenschutzmodus ist aktiv, Inhalte sind ausgeblendet',
			'common.latest' => 'Neueste',
			'common.likesCount' => 'Likes',
			'common.viewsCount' => 'Aufrufe',
			'common.popular' => 'Beliebt',
			'common.trending' => 'Im Trend',
			'common.commentList' => 'Kommentarliste',
			'common.sendComment' => 'Kommentar senden',
			'common.send' => 'Senden',
			'common.retry' => 'Erneut versuchen',
			'common.premium' => 'Premium',
			'common.follower' => 'Follower',
			'common.friend' => 'Freund',
			'common.video' => 'Video',
			'common.following' => 'Folge ich',
			'common.expand' => 'Erweitern',
			'common.collapse' => 'Einklappen',
			'common.cancelFriendRequest' => 'Anfrage abbrechen',
			'common.cancelSpecialFollow' => 'Spezial-Follow aufheben',
			'common.addFriend' => 'Freund hinzufügen',
			'common.removeFriend' => 'Freund entfernen',
			'common.followed' => 'Gefolgt',
			'common.follow' => 'Folgen',
			'common.unfollow' => 'Nicht mehr folgen',
			'common.specialFollow' => 'Spezial-Follow',
			'common.specialFollowed' => 'Spezial-Follow aktiv',
			'common.gallery' => 'Galerie',
			'common.playlist' => 'Playlist',
			'common.commentPostedSuccessfully' => 'Kommentar erfolgreich gesendet',
			'common.commentPostedFailed' => 'Kommentar konnte nicht gesendet werden',
			'common.success' => 'Erfolg',
			'common.commentDeletedSuccessfully' => 'Kommentar erfolgreich gelöscht',
			'common.commentUpdatedSuccessfully' => 'Kommentar erfolgreich aktualisiert',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} Kommentar', other: '${n} Kommentare', ), 
			'common.writeYourCommentHere' => 'Schreiben Sie hier Ihren Kommentar…',
			'common.tmpNoReplies' => 'Noch keine Antworten',
			'common.loadMore' => 'Mehr laden',
			'common.loadingMore' => 'Weitere werden geladen…',
			'common.noMoreDatas' => 'Keine weiteren Daten',
			'common.selectTranslationLanguage' => 'Übersetzungssprache auswählen',
			'common.translate' => 'Übersetzen',
			'common.translateFailedPleaseTryAgainLater' => 'Übersetzung fehlgeschlagen, bitte später erneut versuchen',
			'common.translationResult' => 'Übersetzungsergebnis',
			'common.justNow' => 'Gerade eben',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: 'vor ${n} Minute', other: 'vor ${n} Minuten', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: 'vor ${n} Stunde', other: 'vor ${n} Stunden', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: 'vor ${n} Tag', other: 'vor ${n} Tagen', ), 
			'common.editedAt' => ({required Object num}) => '${num} bearbeitet',
			'common.editComment' => 'Kommentar bearbeiten',
			'common.commentUpdated' => 'Kommentar aktualisiert',
			'common.replyComment' => 'Auf Kommentar antworten',
			'common.reply' => 'Antworten',
			'common.edit' => 'Bearbeiten',
			'common.unknownUser' => 'Unbekannter Benutzer',
			'common.me' => 'Ich',
			'common.author' => 'Autor',
			'common.admin' => 'Admin',
			'common.viewReplies' => ({required Object num}) => 'Antworten ansehen (${num})',
			'common.hideReplies' => 'Antworten ausblenden',
			'common.confirmDelete' => 'Löschen bestätigen',
			'common.areYouSureYouWantToDeleteThisItem' => 'Möchten Sie dieses Element wirklich löschen?',
			'common.tmpNoComments' => 'Noch keine Kommentare',
			'common.refresh' => 'Aktualisieren',
			'common.back' => 'Zurück',
			'common.tips' => 'Tipps',
			'common.linkIsEmpty' => 'Link ist leer',
			'common.linkCopiedToClipboard' => 'Link in die Zwischenablage kopiert',
			'common.imageCopiedToClipboard' => 'Bild in die Zwischenablage kopiert',
			'common.copyImageFailed' => 'Kopieren des Bildes fehlgeschlagen',
			'common.mobileSaveImageIsUnderDevelopment' => 'Das Speichern von Bildern ist auf Mobilgeräten noch in Entwicklung',
			'common.imageSavedTo' => 'Bild gespeichert unter',
			'common.saveImageFailed' => 'Bild konnte nicht gespeichert werden',
			'common.close' => 'Schließen',
			'common.more' => 'Mehr',
			'common.unknownError' => 'Unbekannter Fehler',
			'common.moreFeaturesToBeDeveloped' => 'Weitere Funktionen werden noch entwickelt',
			'common.all' => 'Alle',
			'common.selectedRecords' => ({required Object num}) => '${num} Einträge ausgewählt',
			'common.cancelSelectAll' => 'Alle abwählen',
			'common.selectAll' => 'Alle auswählen',
			'common.invertSelection' => 'Auswahl umkehren',
			'common.exitEditMode' => 'Bearbeitungsmodus beenden',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Möchten Sie die ausgewählten ${num} Elemente wirklich löschen?',
			'common.searchHistoryRecords' => 'Verlaufseinträge durchsuchen…',
			'common.settings' => 'Einstellungen',
			'common.subscriptions' => 'Abos',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} Video', other: '${n} Videos', ), 
			'common.share' => 'Teilen',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Möchten Sie diese Wiedergabeliste wirklich teilen?',
			'common.editTitle' => 'Titel bearbeiten',
			'common.editMode' => 'Bearbeitungsmodus',
			'common.pleaseEnterNewTitle' => 'Bitte neuen Titel eingeben',
			'common.createPlayList' => 'Wiedergabeliste erstellen',
			'common.create' => 'Erstellen',
			'common.checkNetworkSettings' => 'Netzwerkeinstellungen prüfen',
			'common.general' => 'Allgemein',
			'common.r18' => 'R18',
			'common.sensitive' => 'Sensibel',
			'common.year' => 'Jahr',
			'common.month' => 'Monat',
			'common.tag' => 'Tag',
			'common.private' => 'Privat',
			'common.noTitle' => 'Kein Titel',
			'common.search' => 'Suchen',
			'common.noContent' => 'Kein Inhalt',
			'common.recording' => 'Aufzeichnung',
			'common.paused' => 'Pausiert',
			'common.clear' => 'Leeren',
			'common.clearSelection' => 'Auswahl aufheben',
			'common.selectItemsToContinue' => 'Elemente auswählen, um fortzufahren',
			'common.andMoreItems' => ({required Object num}) => 'und ${num} weitere',
			'common.batchDelete' => 'Stapellöschung',
			'common.user' => 'Benutzer',
			'common.post' => 'Beitrag',
			'common.seconds' => 'Sekunden',
			'common.comingSoon' => 'Demnächst',
			'common.confirm' => 'Bestätigen',
			'common.hour' => 'Stunde',
			'common.minute' => 'Minute',
			'common.clickToRefresh' => 'Zum Aktualisieren tippen',
			'common.history' => 'Verlauf',
			'common.favorites' => 'Favoriten',
			'common.friends' => 'Freunde',
			'common.playList' => 'Wiedergabeliste',
			'common.checkLicense' => 'Lizenz prüfen',
			'common.logout' => 'Abmelden',
			'common.fensi' => 'Fans',
			'common.accept' => 'Annehmen',
			'common.reject' => 'Ablehnen',
			'common.clearAllHistory' => 'Gesamten Verlauf löschen',
			'common.clearAllHistoryConfirm' => 'Möchten Sie den gesamten Verlauf wirklich löschen?',
			'common.followingList' => 'Liste meiner Follows',
			'common.followersList' => 'Follower-Liste',
			'common.follows' => 'Folgt',
			'common.fans' => 'Fans',
			'common.followsAndFans' => 'Gefolgt und Fans',
			'common.numViews' => 'Aufrufe',
			'common.updatedAt' => 'Aktualisiert am',
			'common.publishedAt' => 'Veröffentlicht am',
			'common.externalVideo' => 'Externes Video',
			'common.originalText' => 'Originaltext',
			'common.showOriginalText' => 'Originaltext anzeigen',
			'common.showProcessedText' => 'Verarbeiteten Text anzeigen',
			'common.preview' => 'Vorschau',
			'common.rules' => 'Regeln',
			'common.agree' => 'Zustimmen',
			'common.disagree' => 'Ablehnen',
			'common.agreeToRules' => 'Den Regeln zustimmen',
			'common.tapToReread' => 'Zum erneuten Lesen tippen',
			'common.markdownSyntaxHelp' => 'Markdown-Syntax-Hilfe',
			'common.previewContent' => 'Inhalt vorschauen',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Maximale Länge überschritten (${max})',
			'common.agreeToCommunityRules' => 'Den Community-Regeln zustimmen',
			'common.createPost' => 'Beitrag erstellen',
			'common.title' => 'Titel',
			'common.enterTitle' => 'Bitte Titel eingeben',
			'common.content' => 'Inhalt',
			'common.enterContent' => 'Bitte Inhalt eingeben',
			'common.writeYourContentHere' => 'Bitte Inhalt eingeben…',
			'common.tagBlacklist' => 'Tag-Sperrliste',
			'common.noData' => 'Keine Daten',
			'common.tagLimit' => 'Tag-Limit',
			'common.enableFloatingButtons' => 'Schwebende Schaltflächen aktivieren',
			'common.disableFloatingButtons' => 'Schwebende Schaltflächen deaktivieren',
			'common.enabledFloatingButtons' => 'Schwebende Schaltflächen aktiviert',
			'common.disabledFloatingButtons' => 'Schwebende Schaltflächen deaktiviert',
			'common.pendingCommentCount' => 'Ausstehende Kommentare',
			'common.joined' => ({required Object str}) => 'Beigetreten am ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Zuletzt gesehen ${str}',
			'common.download' => 'Herunterladen',
			'common.selectQuality' => 'Qualität auswählen',
			'common.videoQualitySource' => 'Quelle',
			'common.selectImageQuality' => 'Bildqualität auswählen',
			'common.imageQualityStandard' => 'Standard',
			'common.imageQualityOriginal' => 'Original',
			'common.selectDateRange' => 'Datumsbereich auswählen',
			'common.selectDateRangeHint' => 'Datumsbereich auswählen, Standard sind die letzten 30 Tage',
			'common.clearDateRange' => 'Datumsbereich löschen',
			'common.deleteRecordsInDateRange' => 'Einträge in diesem Bereich löschen',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'Möchten Sie ${num} Verlaufseinträge in diesem Datumsbereich wirklich löschen? Dies kann nicht rückgängig gemacht werden.',
			'common.noHistoryRecordsInRange' => 'Keine Verlaufseinträge in diesem Datumsbereich',
			'common.followSuccessClickAgainToSpecialFollow' => 'Erfolgreich gefolgt, erneut tippen für Spezial-Follow',
			'common.specialFollowTip' => 'Zu den Spezial-Follows hinzugefügt – wählen Sie sie über die Auswahl oben rechts auf der Abo-Seite für den Schnellzugriff',
			'common.exitConfirmTip' => 'Möchten Sie wirklich beenden?',
			'common.error' => 'Fehler',
			'common.taskRunning' => 'Es läuft bereits eine Aufgabe, bitte warten.',
			'common.operationCancelled' => 'Vorgang abgebrochen.',
			'common.unsavedChanges' => 'Sie haben ungespeicherte Änderungen',
			'common.specialFollowsManagementTip' => 'Zum Umsortieren am Griff ziehen • Zum Entfernen auf die Schaltfläche tippen',
			'common.specialFollowsManagement' => 'Spezial-Follows verwalten',
			'common.removeSpecialFollow' => 'Spezial-Follow entfernen',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => '${name} aus den Spezial-Follows entfernen?',
			'common.noSpecialFollows' => 'Noch keine Spezial-Follows',
			'common.createTimeDesc' => 'Erstellzeit absteigend',
			'common.createTimeAsc' => 'Erstellzeit aufsteigend',
			'common.pagination.totalItems' => ({required Object num}) => 'Insgesamt ${num} Elemente',
			'common.pagination.jumpToPage' => 'Zu Seite springen',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Bitte Seitenzahl eingeben (1-${max})',
			'common.pagination.pageNumber' => 'Seitenzahl',
			'common.pagination.jump' => 'Springen',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Bitte eine gültige Seitenzahl eingeben (1-${max})',
			'common.pagination.invalidInput' => 'Bitte eine gültige Seitenzahl eingeben',
			'common.pagination.waterfall' => 'Wasserfall',
			'common.pagination.pagination' => 'Seitennummerierung',
			'common.notice' => 'Hinweis',
			'common.detail' => 'Details',
			'common.parseExceptionDestopHint' => ' – Desktop-Benutzer können den Proxy in den Einstellungen konfigurieren',
			'common.iwaraTags' => 'Iwara-Tags',
			'common.tagInfo' => 'Tag-Info',
			'common.tagOriginalKey' => 'Original-Tag',
			'common.tagTranslation' => 'Übersetzung',
			'common.copy' => 'Kopieren',
			'common.selectCopy' => 'Auswählen & kopieren',
			'common.copiedToClipboard' => 'In die Zwischenablage kopiert',
			'common.showOriginalTag' => 'Original-Tag anzeigen',
			'common.showTranslatedTag' => 'Übersetzung anzeigen',
			'common.tagTranslationFeedback' => 'Zweifel an einer Übersetzung? Geben Sie Feedback',
			'common.tagLocalizationGuideTitle' => 'Über die Tag-Lokalisierung',
			'common.tagLocalizationGuideContent' => 'Die App zeigt die Original-Tags von Iwara (z. B. mother) mit dem Namen in Ihrer aktuellen Sprache an.\n\n• Bei der Tag-Suche stimmen sowohl die Übersetzung als auch das Original-Tag überein.\n• Halten Sie ein Tag gedrückt bzw. klicken Sie mit der rechten Maustaste darauf, um den Originalschlüssel und die Übersetzung anzuzeigen und zu kopieren.\n• Die Übersetzungen werden von der Community gepflegt und nach bestem Wissen erstellt – sie können Fehler enthalten.',
			'common.likeThisVideo' => 'Dieses Video liken',
			'common.likeThisGallery' => 'Diese Galerie liken',
			'common.operation' => 'Aktion',
			'common.replies' => 'Antworten',
			'common.externalLinkWarning' => 'Warnung vor externem Link',
			'common.externalLinkWarningMessage' => 'Sie sind dabei, einen externen Link zu öffnen, der nicht zu iwara.tv gehört. Bitte seien Sie vorsichtig und stellen Sie sicher, dass der Link sicher ist, bevor Sie fortfahren.',
			'common.continueToExternalLink' => 'Weiter',
			'common.cancelExternalLink' => 'Abbrechen',
			'auth.login' => 'Anmelden',
			'auth.logout' => 'Abmelden',
			'auth.email' => 'E-Mail',
			'auth.password' => 'Passwort',
			'auth.loginOrRegister' => 'Anmelden / Registrieren',
			'auth.register' => 'Registrieren',
			'auth.pleaseEnterEmail' => 'Bitte E-Mail eingeben',
			'auth.pleaseEnterPassword' => 'Bitte Passwort eingeben',
			'auth.passwordMustBeAtLeast6Characters' => 'Das Passwort muss mindestens 6 Zeichen lang sein',
			'auth.pleaseEnterCaptcha' => 'Bitte Captcha eingeben',
			'auth.captcha' => 'Captcha',
			'auth.refreshCaptcha' => 'Captcha erneuern',
			'auth.captchaNotLoaded' => 'Captcha nicht geladen',
			'auth.loginSuccess' => 'Anmeldung erfolgreich',
			'auth.loginSuccessProfilePending' => 'Angemeldet. Profil wird geladen…',
			'auth.emailVerificationSent' => 'E-Mail-Verifizierung gesendet',
			'auth.notLoggedIn' => 'Nicht angemeldet',
			'auth.clickToLogin' => 'Zum Anmelden tippen',
			'auth.logoutConfirmation' => 'Möchten Sie sich wirklich abmelden?',
			'auth.logoutSuccess' => 'Abmeldung erfolgreich',
			'auth.logoutFailed' => 'Abmeldung fehlgeschlagen',
			'auth.usernameOrEmail' => 'Benutzername oder E-Mail',
			'auth.pleaseEnterUsernameOrEmail' => 'Bitte Benutzername oder E-Mail eingeben',
			'auth.rememberMe' => 'Benutzername merken',
			'auth.registerNoticeTitle' => 'Auf der offiziellen Website registrieren',
			'auth.registerNoticeDescription' => 'Die In-App-Registrierung ist nicht mehr verfügbar. Bitte rufen Sie die offizielle Iwara-Website auf, um Ihr Konto zu erstellen, und kehren Sie dann hierher zurück, um sich anzumelden.',
			'auth.registerNoticeReturnTip' => 'Kehren Sie nach der Registrierung hierher zurück und melden Sie sich mit Ihrem Konto an.',
			'auth.goToOfficialWebsite' => 'Zur offiziellen Website',
			'errors.error' => 'Fehler',
			'errors.required' => 'Dieses Feld ist erforderlich',
			'errors.invalidEmail' => 'Ungültige E-Mail-Adresse',
			'errors.networkError' => 'Netzwerkfehler, bitte erneut versuchen',
			'errors.errorWhileFetching' => 'Fehler beim Abrufen',
			'errors.commentCanNotBeEmpty' => 'Der Kommentarinhalt darf nicht leer sein',
			'errors.errorWhileFetchingReplies' => 'Fehler beim Abrufen der Antworten, bitte prüfen Sie die Netzwerkverbindung',
			'errors.canNotFindCommentController' => 'Kommentar-Controller nicht gefunden',
			'errors.errorWhileLoadingGallery' => 'Fehler beim Laden der Galerie',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'Wie kann es keine Daten geben? Das ist unmöglich :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Nicht unterstütztes Bildformat: ${str}',
			'errors.invalidGalleryId' => 'Ungültige Galerie-ID',
			'errors.translationFailedPleaseTryAgainLater' => 'Übersetzung fehlgeschlagen, bitte später erneut versuchen',
			'errors.errorOccurred' => 'Ein Fehler ist aufgetreten, bitte später erneut versuchen.',
			'errors.errorOccurredWhileProcessingRequest' => 'Beim Verarbeiten der Anfrage ist ein Fehler aufgetreten',
			'errors.errorWhileFetchingDatas' => 'Fehler beim Abrufen der Daten, bitte später erneut versuchen',
			'errors.serviceNotInitialized' => 'Dienst nicht initialisiert',
			'errors.unknownType' => 'Unbekannter Typ',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Fehler beim Öffnen des Links: ${link}',
			'errors.invalidUrl' => 'Ungültige URL',
			'errors.failedToOperate' => 'Vorgang fehlgeschlagen',
			'errors.permissionDenied' => 'Berechtigung verweigert',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'Sie haben keine Berechtigung, auf diese Ressource zuzugreifen',
			'errors.loginFailed' => 'Anmeldung fehlgeschlagen',
			'errors.unknownError' => 'Unbekannter Fehler',
			'errors.sessionExpired' => 'Sitzung abgelaufen',
			'errors.failedToFetchCaptcha' => 'Captcha konnte nicht abgerufen werden',
			'errors.emailAlreadyExists' => 'E-Mail existiert bereits',
			'errors.invalidCaptcha' => 'Ungültiges Captcha',
			'errors.registerFailed' => 'Registrierung fehlgeschlagen',
			'errors.failedToFetchComments' => 'Kommentare konnten nicht abgerufen werden',
			'errors.failedToFetchImageDetail' => 'Bilddetails konnten nicht abgerufen werden',
			'errors.failedToFetchImageList' => 'Bildliste konnte nicht abgerufen werden',
			'errors.failedToFetchData' => 'Daten konnten nicht abgerufen werden',
			'errors.invalidParameter' => 'Ungültiger Parameter',
			'errors.pleaseLoginFirst' => 'Bitte zuerst anmelden',
			'errors.errorWhileLoadingPost' => 'Fehler beim Laden des Beitrags',
			'errors.errorWhileLoadingPostDetail' => 'Fehler beim Laden der Beitragsdetails',
			'errors.invalidPostId' => 'Ungültige Beitrags-ID',
			'errors.forceUpdateNotPermittedToGoBack' => 'Derzeit im Zustand der erzwungenen Aktualisierung, Zurückgehen nicht möglich',
			'errors.pleaseLoginAgain' => 'Bitte erneut anmelden',
			'errors.invalidLogin' => 'Ungültige Anmeldung, bitte prüfen Sie E-Mail und Passwort',
			'errors.tooManyRequests' => 'Zu viele Anfragen, bitte später erneut versuchen',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Maximale Länge überschritten: ${max}',
			'errors.contentCanNotBeEmpty' => 'Der Inhalt darf nicht leer sein',
			'errors.titleCanNotBeEmpty' => 'Der Titel darf nicht leer sein',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Zu viele Anfragen, bitte später erneut versuchen, verbleibend',
			'errors.remainingHours' => ({required Object num}) => '${num} Stunden',
			'errors.remainingMinutes' => ({required Object num}) => '${num} Minuten',
			'errors.remainingSeconds' => ({required Object num}) => '${num} Sekunden',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Tag-Limit überschritten, Limit: ${limit}',
			'errors.failedToRefresh' => 'Aktualisierung fehlgeschlagen',
			'errors.noPermission' => 'Keine Berechtigung',
			'errors.resourceNotFound' => 'Ressource nicht gefunden',
			'errors.failedToSaveCredentials' => 'Anmeldedaten konnten nicht gespeichert werden',
			'errors.failedToLoadSavedCredentials' => 'Gespeicherte Anmeldedaten konnten nicht geladen werden',
			'errors.notFound' => 'Inhalt nicht gefunden oder wurde gelöscht',
			'errors.network.basicPrefix' => 'Netzwerkfehler – ',
			'errors.network.failedToConnectToServer' => 'Verbindung zum Server fehlgeschlagen',
			'errors.network.serverNotAvailable' => 'Server nicht verfügbar',
			'errors.network.requestTimeout' => 'Zeitüberschreitung der Anfrage',
			'errors.network.unexpectedError' => 'Unerwarteter Fehler',
			'errors.network.invalidResponse' => 'Ungültige Antwort',
			'errors.network.invalidRequest' => 'Ungültige Anfrage',
			'errors.network.invalidUrl' => 'Ungültige URL',
			'errors.network.invalidMethod' => 'Ungültige Methode',
			'errors.network.invalidHeader' => 'Ungültiger Header',
			'errors.network.invalidBody' => 'Ungültiger Anfragetext',
			'errors.network.invalidStatusCode' => 'Ungültiger Statuscode',
			'errors.network.serverError' => 'Serverfehler',
			'errors.network.requestCanceled' => 'Anfrage abgebrochen',
			'errors.network.invalidPort' => 'Ungültiger Port',
			'errors.network.proxyPortError' => 'Proxy-Port-Fehler',
			'errors.network.connectionRefused' => 'Verbindung abgelehnt',
			'errors.network.networkUnreachable' => 'Netzwerk nicht erreichbar',
			'errors.network.noRouteToHost' => 'Keine Route zum Host',
			'errors.network.connectionFailed' => 'Verbindung fehlgeschlagen',
			'errors.network.sslConnectionFailed' => 'SSL-Verbindung fehlgeschlagen, bitte prüfen Sie Ihre Netzwerkeinstellungen',
			'friends.clickToRestoreFriend' => 'Zum Wiederherstellen des Freundes klicken',
			'friends.friendsList' => 'Freundesliste',
			'friends.friendRequests' => 'Freundschaftsanfragen',
			'friends.friendRequestsList' => 'Liste der Freundschaftsanfragen',
			'friends.removingFriend' => 'Freund wird entfernt…',
			'friends.failedToRemoveFriend' => 'Freund konnte nicht entfernt werden',
			'friends.cancelingRequest' => 'Freundschaftsanfrage wird abgebrochen…',
			'friends.failedToCancelRequest' => 'Freundschaftsanfrage konnte nicht abgebrochen werden',
			'authorProfile.noMoreDatas' => 'Keine weiteren Daten',
			'authorProfile.userProfile' => 'Benutzerprofil',
			'favorites.clickToRestoreFavorite' => 'Zum Wiederherstellen des Favoriten klicken',
			'favorites.myFavorites' => 'Meine Favoriten',
			'favorites.batchCancelFavorite' => 'Ausgewählte Favoriten entfernen',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'Die ${count} ausgewählten Element(e) aus den Favoriten entfernen? Sie können sie anschließend durch Antippen der Karten wiederherstellen.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => '${count} Element(e) aus den Favoriten entfernt',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => '${success} Element(e) entfernt, ${failed} fehlgeschlagen',
			'galleryDetail.browseInSpace' => 'Im Raum durchsuchen',
			'galleryDetail.galleryDetail' => 'Galeriedetails',
			'galleryDetail.viewGalleryDetail' => 'Galeriedetails anzeigen',
			'galleryDetail.zoomReset' => 'Zoom zurücksetzen',
			'galleryDetail.copyLink' => 'Link kopieren',
			'galleryDetail.copyImage' => 'Bild kopieren',
			'galleryDetail.saveAs' => 'Speichern unter',
			'galleryDetail.saveToAlbum' => 'In Album speichern',
			'galleryDetail.publishedAt' => 'Veröffentlicht am',
			'galleryDetail.viewsCount' => 'Aufrufe',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Einführung in die Funktionen der Bildbibliothek',
			'galleryDetail.rightClickToSaveSingleImage' => 'Rechtsklick, um einzelnes Bild zu speichern',
			'galleryDetail.batchSave' => 'Stapelspeicherung',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Tastatur links und rechts zum Wechseln',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Tastatur oben und unten zum Zoomen',
			'galleryDetail.mouseWheelToSwitch' => 'Mausrad zum Wechseln',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'STRG + Mausrad zum Zoomen',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'Weitere Funktionen zu entdecken…',
			'galleryDetail.authorOtherGalleries' => 'Weitere Galerien des Autors',
			'galleryDetail.relatedGalleries' => 'Verwandte Galerien',
			'galleryDetail.authorNoOtherGalleries' => 'Keine weiteren Galerien von diesem Autor',
			'galleryDetail.noRelatedGalleries' => 'Keine verwandten Galerien',
			'galleryDetail.scrollLeft' => 'Nach links scrollen',
			'galleryDetail.scrollRight' => 'Nach rechts scrollen',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Zum Wechseln des Bildes auf den linken oder rechten Rand klicken',
			'galleryDetail.rotateToLandscape' => 'Vollbild im Querformat',
			'galleryDetail.backToPortrait' => 'Zurück zum Hochformat',
			'playList.myPlayList' => 'Meine Wiedergabeliste',
			'playList.friendlyTips' => 'Freundliche Hinweise',
			'playList.dearUser' => 'Liebe Nutzerin, lieber Nutzer',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'Iwaras Wiedergabelisten-System ist noch nicht perfekt',
			'playList.notSupportSetCover' => 'Festlegen eines Titelbilds wird nicht unterstützt',
			'playList.notSupportDeleteList' => 'Löschen der Liste wird nicht unterstützt',
			'playList.notSupportSetPrivate' => 'Festlegen als privat wird nicht unterstützt',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Ja... eine erstellte Liste bleibt dauerhaft bestehen und ist für alle sichtbar',
			'playList.smallSuggestion' => 'Kleiner Tipp',
			'playList.useLikeToCollectContent' => 'Wenn Ihnen Datenschutz wichtiger ist, empfiehlt es sich, die Funktion „Gefällt mir“ zum Sammeln von Inhalten zu verwenden',
			'playList.welcomeToDiscussOnGitHub' => 'Wenn Sie weitere Vorschläge oder Ideen haben, diskutieren Sie gerne auf GitHub!',
			'playList.iUnderstand' => 'Verstanden',
			'playList.searchPlaylists' => 'Wiedergabelisten suchen...',
			'playList.newPlaylistName' => 'Name der neuen Wiedergabeliste',
			'playList.createNewPlaylist' => 'Neue Wiedergabeliste erstellen',
			'playList.videos' => 'Videos',
			'search.googleSearchScope' => 'Suchbereich',
			'search.searchTags' => 'Tags suchen...',
			'search.contentRating' => 'Inhaltseinstufung',
			'search.removeTag' => 'Tag entfernen',
			'search.pleaseEnterSearchContent' => 'Bitte Suchinhalt eingeben',
			'search.exactMatch' => 'Exakt',
			'search.exactMatchOnHint' => 'Exakte Übereinstimmung der Phrase, zusätzlich werden chinesische und japanische Titel durchsucht. Tippen für eine lockerere Suche.',
			'search.exactMatchOffHint' => 'Lockere Übereinstimmung — Iwara zerlegt die Wörter. Tippen für exakte Phrase.',
			'search.searchHistory' => 'Suchverlauf',
			'search.searchSuggestion' => 'Suchvorschläge',
			'search.usedTimes' => 'Nutzungshäufigkeit',
			'search.lastUsed' => 'Zuletzt verwendet',
			'search.noSearchHistoryRecords' => 'Kein Suchverlauf',
			'search.clearSearchHistoryConfirm' => 'Möchten Sie wirklich den gesamten Suchverlauf löschen? Dies kann nicht rückgängig gemacht werden.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Der aktuelle Suchtyp ${searchType} wird nicht unterstützt, bitte warten Sie auf das Update',
			'search.searchResult' => 'Suchergebnis',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Nicht unterstützter Suchtyp: ${searchType}',
			'search.googleSearch' => 'Google-Suche',
			'search.googleSearchHint' => ({required Object webName}) => '${webName}s Suchfunktion ist unpraktisch? Probieren Sie die Google-Suche!',
			'search.googleSearchDescription' => 'Verwenden Sie den Suchoperator :site der Google-Suche, um Inhalte auf der Website zu suchen. Das ist sehr nützlich bei der Suche nach Videos, Galerien, Wiedergabelisten und Nutzern.',
			'search.googleSearchKeywordsHint' => 'Stichwörter zum Suchen eingeben',
			'search.openLinkJump' => 'Link extern öffnen',
			'search.googleSearchButton' => 'Google-Suche',
			'search.pleaseEnterSearchKeywords' => 'Bitte Suchbegriffe eingeben',
			'search.googleSearchQueryCopied' => 'Suchanfrage in die Zwischenablage kopiert',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Browser konnte nicht geöffnet werden: ${error}',
			'search.searchRequestTimeout' => 'Zeitüberschreitung der Anfrage, bitte später erneut versuchen',
			'search.searchCannotConnectToServer' => 'Verbindung zum Server nicht möglich, bitte prüfen Sie Ihre Netzwerkverbindung',
			'search.searchNetworkError' => 'Netzwerkverbindung fehlgeschlagen, bitte prüfen Sie Ihre Netzwerkeinstellungen oder versuchen Sie es später erneut',
			'search.searchFailedPleaseRetry' => 'Suche fehlgeschlagen, bitte später erneut versuchen',
			'mediaList.personalIntroduction' => 'Vorstellung',
			'settings.listViewMode' => 'Listenansicht',
			'settings.previewEffect' => 'Effektvorschau',
			'settings.useTraditionalPaginationMode' => 'Traditionellen Seitenmodus verwenden',
			'settings.useTraditionalPaginationModeDesc' => 'Traditionellen Seitenmodus aktivieren, Wasserfall-Modus deaktivieren. Wirkt nach erneutem Rendern der Seite oder Neustart der App',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Untere Fortschrittsleiste bei ausgeblendeter Symbolleiste anzeigen',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Diese Konfiguration legt fest, ob die untere Videofortschrittsleiste angezeigt wird, wenn die Symbolleiste ausgeblendet ist.',
			'settings.seekPreviewSize' => 'Größe der Spulvorschau',
			'settings.seekPreviewSizeDesc' => 'Wie groß das Vorschaufenster über dem Fortschrittsbalken ist. Es richtet sich bereits nach der Playergröße und dem Seitenverhältnis des Videos; dies passt es nur leicht an.',
			'settings.seekPreviewSizeSmall' => 'Klein',
			'settings.seekPreviewSizeStandard' => 'Standard',
			'settings.seekPreviewSizeLarge' => 'Groß',
			'settings.seekPreviewSizeStandardDesc' => 'Die aus Player und Video abgeleitete Größe',
			'settings.showFullscreenUpNextHint' => 'Den Griff „Als Nächstes“ anzeigen',
			'settings.showFullscreenUpNextHintDesc' => 'Zeigt einen kleinen Griff am rechten Rand des Players an, der die Warteschlangen-Schublade (Quelle / Wiedergabeliste / Später ansehen) öffnet. Wenn er ausgeschaltet ist, gibt es keinen anderen Zugang.',
			'settings.basicSettings' => 'Grundeinstellungen',
			'settings.personalizedSettings' => 'Personalisierte Einstellungen',
			'settings.otherSettings' => 'Weitere Einstellungen',
			'settings.searchConfig' => 'Suchkonfiguration',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Diese Konfiguration legt fest, ob beim erneuten Abspielen von Videos die vorherige Konfiguration verwendet wird.',
			'settings.playControl' => 'Wiedergabesteuerung',
			'settings.playbackSpeedSettings' => 'Wiedergabe & Geschwindigkeit',
			'settings.playbackBehaviorSettings' => 'Wiedergabeverhalten',
			'settings.enhancementSettings' => 'Kino & Verbesserungen',
			'settings.fastForwardTime' => 'Vorspulzeit',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'Die Vorspulzeit muss eine positive ganze Zahl sein.',
			'settings.rewindTime' => 'Rückspulzeit',
			_ => null,
		} ?? switch (path) {
			'settings.rewindTimeMustBeAPositiveInteger' => 'Die Rückspulzeit muss eine positive ganze Zahl sein.',
			'settings.longPressPlaybackSpeed' => 'Wiedergabegeschwindigkeit bei Langdruck',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'Die Wiedergabegeschwindigkeit bei Langdruck muss eine positive Zahl sein.',
			'settings.defaultPlaybackSpeed' => 'Standard-Wiedergabegeschwindigkeit',
			'settings.rememberPlaybackSpeed' => 'Wiedergabegeschwindigkeit merken',
			'settings.rememberPlaybackSpeedDesc' => 'Wenn aktiviert, wird die im Player eingestellte Geschwindigkeit als Standard gespeichert und automatisch auf neue Videos angewendet.',
			'settings.repeat' => 'Wiederholen',
			'settings.renderVerticalVideoInVerticalScreen' => 'Vertikales Video im Hochformat darstellen',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Diese Konfiguration legt fest, ob das Video bei der Wiedergabe im Vollbildmodus im Hochformat dargestellt wird.',
			'settings.rememberVolume' => 'Lautstärke merken',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Diese Konfiguration legt fest, ob die Lautstärke beim erneuten Abspielen von Videos beibehalten wird.',
			'settings.rememberBrightness' => 'Helligkeit merken',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Diese Konfiguration legt fest, ob die Helligkeit beim erneuten Abspielen von Videos beibehalten wird.',
			'settings.playControlArea' => 'Wiedergabesteuerbereich',
			'settings.leftAndRightControlAreaWidth' => 'Breite der linken und rechten Steuerfläche',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Diese Konfiguration legt die Breite der Steuerbereiche links und rechts am Player fest.',
			'settings.proxyAddressCannotBeEmpty' => 'Proxy-Adresse darf nicht leer sein.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Ungültiges Proxy-Adressformat. Bitte verwenden Sie das Format IP:Port oder Domainname:Port.',
			'settings.proxyNormalWork' => 'Proxy funktioniert normal.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Proxy-Test fehlgeschlagen, Statuscode: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Proxy-Test fehlgeschlagen, Ausnahme: ${exception}',
			'settings.proxyConfig' => 'Proxy-Konfiguration',
			'settings.thisIsHttpProxyAddress' => 'Dies ist eine HTTP-Proxy-Adresse',
			'settings.checkProxy' => 'Proxy prüfen',
			'settings.proxyAddress' => 'Proxy-Adresse',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Bitte geben Sie die URL des Proxyservers ein, zum Beispiel 127.0.0.1:8080',
			'settings.enableProxy' => 'Proxy aktivieren',
			'settings.left' => 'Links',
			'settings.middle' => 'Mitte',
			'settings.right' => 'Rechts',
			'settings.playerSettings' => 'Player-Einstellungen',
			'settings.networkSettings' => 'Netzwerkeinstellungen',
			'settings.customizeYourPlaybackExperience' => 'Passen Sie Ihr Wiedergabeerlebnis an',
			'settings.chooseYourFavoriteAppAppearance' => 'Wählen Sie Ihr bevorzugtes App-Erscheinungsbild',
			'settings.configureYourProxyServer' => 'Konfigurieren Sie Ihren Proxyserver',
			'settings.settings' => 'Einstellungen',
			'settings.themeSettings' => 'Design-Einstellungen',
			'settings.followSystem' => 'System folgen',
			'settings.lightMode' => 'Hellmodus',
			'settings.darkMode' => 'Dunkelmodus',
			'settings.presetTheme' => 'Voreingestelltes Design',
			'settings.basicTheme' => 'Standarddesign',
			'settings.needRestartToApply' => 'Die App muss neu gestartet werden, damit die Einstellungen wirksam werden',
			'settings.themeNeedRestartDescription' => 'Die Design-Einstellungen erfordern einen Neustart der App, um wirksam zu werden',
			'settings.about' => 'Über',
			'settings.diagnosticsAndFeedback' => 'Diagnose & Feedback',
			'settings.currentVersion' => 'Aktuelle Version',
			'settings.latestVersion' => 'Neueste Version',
			'settings.checkForUpdates' => 'Nach Updates suchen',
			'settings.update' => 'Aktualisieren',
			'settings.newVersionAvailable' => 'Neue Version verfügbar',
			'settings.projectHome' => 'Projekt-Startseite',
			'settings.release' => 'Version',
			'settings.issueReport' => 'Problem melden',
			'settings.openSourceLicense' => 'Open-Source-Lizenz',
			'settings.checkForUpdatesFailed' => 'Suche nach Updates fehlgeschlagen, bitte später erneut versuchen',
			'settings.autoCheckUpdate' => 'Automatisch nach Updates suchen',
			'settings.updateContent' => 'Update-Inhalt',
			'settings.releaseDate' => 'Veröffentlichungsdatum',
			'settings.ignoreThisVersion' => 'Diese Version ignorieren',
			'settings.forceUpdateTip' => 'Dies ist ein obligatorisches Update. Bitte aktualisieren Sie so bald wie möglich auf die neueste Version',
			'settings.viewChangelog' => 'Änderungsprotokoll anzeigen',
			'settings.alreadyLatestVersion' => 'Bereits die neueste Version',
			'settings.appSettings' => 'App-Einstellungen',
			'settings.configureYourAppSettings' => 'Konfigurieren Sie Ihre App-Einstellungen',
			'settings.history' => 'Verlauf',
			'settings.autoRecordHistory' => 'Verlauf automatisch aufzeichnen',
			'settings.autoRecordHistoryDesc' => 'Angesehene Videos und Bilder automatisch aufzeichnen',
			'settings.autoDeleteHistory' => 'Verlauf automatisch löschen',
			'settings.autoDeleteHistoryDesc' => 'Beim Start automatisch den Browserverlauf löschen, der älter als die Aufbewahrungstage ist (standardmäßig aus)',
			'settings.autoDeleteHistoryDays' => 'Aufbewahrungstage',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Die letzten ${num} Tage behalten',
			'settings.autoDeleteHistoryDaysInvalid' => 'Bitte eine gültige Anzahl von Tagen eingeben (mindestens 1)',
			'settings.showUnprocessedMarkdownText' => 'Unverarbeiteten Markdown-Text anzeigen',
			'settings.showUnprocessedMarkdownTextDesc' => 'Den Originaltext des Markdown anzeigen',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Datenschutzmodus',
			'settings.activeBackgroundPrivacyModeDesc' => 'Screenshots und Bildschirmaufnahmen blockieren und den Bildschirm im Hintergrund ausblenden',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Den Bildschirm ausblenden, wenn die App in den Hintergrund wechselt (diese Plattform kann Screenshots nicht blockieren)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Screenshots und Bildschirmaufnahmen blockieren',
			'settings.privacy' => 'Datenschutz',
			'settings.appLock' => 'App-Sperre',
			'settings.appLockEnabled' => 'App-Sperre aktivieren',
			'settings.appLockEnabledDesc' => 'PIN oder Biometrie zum Öffnen der App erforderlich; die Hintergrundvorschau wird automatisch ausgeblendet',
			'settings.appLockEnabledSummary' => 'An · PIN-geschützt',
			'settings.appLockDisabledSummary' => 'Aus',
			'settings.appLockTimeout' => 'Sperren nach Verlassen der App',
			'settings.appLockTimeoutDesc' => 'Zulässige Zeit im Hintergrund, bevor eine Authentifizierung erforderlich ist',
			'settings.appLockAfterScreenOff' => 'Sperren nach Bildschirmsperre',
			'settings.appLockAfterScreenOffDesc' => 'Authentifizierung nach Sperren des Gerätebildschirms erforderlich',
			'settings.appLockTimeoutDisabled' => 'Deaktiviert',
			'settings.appLockImmediately' => 'Sofort',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} Sekunden',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} Minuten',
			'settings.appLockUseBiometrics' => 'Biometrie verwenden',
			'settings.appLockUseBiometricsDesc' => 'Mit Fingerabdruck oder Gesichtserkennung entsperren',
			'settings.appLockBiometricsUnavailable' => 'Auf diesem Gerät sind keine registrierten biometrischen Daten verfügbar',
			'settings.appLockSetPin' => 'PIN festlegen',
			'settings.appLockEnterPin' => 'PIN eingeben',
			'settings.appLockConfirmPin' => 'PIN bestätigen',
			'settings.appLockCurrentPin' => 'Aktuelle PIN eingeben',
			'settings.appLockNewPin' => 'Neue PIN eingeben',
			'settings.appLockPinRequirements' => 'Die PIN muss 4–8 Ziffern enthalten',
			'settings.appLockPinsDoNotMatch' => 'Die PINs stimmen nicht überein',
			'settings.appLockInvalidPin' => 'Falsche PIN',
			'settings.appLockSetupFailed' => 'PIN konnte nicht sicher gespeichert werden',
			'settings.appLockDisable' => 'PIN eingeben, um die App-Sperre zu deaktivieren',
			'settings.appLockChangePin' => 'PIN ändern',
			'settings.appLockNow' => 'Jetzt sperren',
			'settings.appLockUnlock' => 'Entsperren',
			'settings.appLockLockedTitle' => 'Gesperrt',
			'settings.appLockLockedDesc' => 'Zum Fortfahren authentifizieren',
			'settings.appLockAuthenticateReason' => 'Zum Entsperren authentifizieren',
			'settings.appLockEnableBiometricsReason' => 'Authentifizieren, um die biometrische Entsperrung zu aktivieren',
			'settings.appLockBiometricFailed' => 'Biometrische Authentifizierung wurde nicht abgeschlossen',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Zu viele Versuche. Erneut versuchen in ${seconds}s',
			'settings.appLockCredentialUnavailableTitle' => 'Zugangsdaten der App-Sperre können nicht gelesen werden',
			'settings.appLockCredentialUnavailableDesc' => 'Der sichere Systemspeicher ist vorübergehend nicht verfügbar oder die Zugangsdaten sind beschädigt. Die App bleibt gesperrt. Versuchen Sie es zunächst erneut; wenn es weiter fehlschlägt, können Sie die App-Sperre zurücksetzen, wodurch sie deaktiviert und die gespeicherte PIN gelöscht wird.',
			'settings.appLockRetry' => 'Erneut versuchen',
			'settings.appLockReset' => 'App-Sperre zurücksetzen',
			'settings.appLockResetAction' => 'Zurücksetzen',
			'settings.appLockResetConfirmTitle' => 'App-Sperre zurücksetzen?',
			'settings.appLockResetConfirmDesc' => 'Dadurch wird die App-Sperre deaktiviert und die gespeicherte PIN sowie die Biometrie-Einstellung gelöscht. Sie können sie danach erneut einrichten.',
			'settings.appLockRetrySucceeded' => 'Zugangsdaten erfolgreich gelesen. Geben Sie Ihre PIN ein.',
			'settings.appLockRetryFailed' => 'Zugangsdaten können weiterhin nicht gelesen werden',
			'settings.forum' => 'Forum',
			'settings.news' => 'Neuigkeiten',
			'settings.community' => 'Community',
			'settings.disableForumReplyQuote' => 'Zitat von Forumantworten deaktivieren',
			'settings.disableForumReplyQuoteDesc' => 'Das Mitführen von Informationen zum beantworteten Beitrag beim Antworten im Forum deaktivieren',
			'settings.theaterMode' => 'Kinomodus',
			'settings.theaterModeDesc' => 'Nach dem Öffnen wird der Player-Hintergrund auf die unscharfe Version des Videocovers gesetzt',
			'settings.appLinks' => 'App-Links',
			'settings.defaultBrowser' => 'Standardbrowser',
			'settings.defaultBrowserDesc' => 'Bitte öffnen Sie in den Systemeinstellungen den Eintrag für die Standard-Linkkonfiguration und fügen Sie den Link zur Website iwara.tv hinzu',
			'settings.themeMode' => 'Designmodus',
			'settings.themeModeDesc' => 'Diese Konfiguration legt den Designmodus der App fest',
			'settings.glassEffect' => 'Oberflächenmaterial',
			'settings.glassEffectDesc' => 'Wählt das in der gesamten App verwendete Material — Kopfbereich-Kapseln, Menüs, Dialogschaltflächen und die untere Navigationsleiste',
			'settings.liquidGlassEffect' => 'Liquid Glass',
			'settings.liquidGlassEffectDesc' => 'Echte Unschärfe und Lichtbrechung. Sieht am besten aus, kann aber auf schwächeren Geräten Bildraten senken und etwas mehr Energie verbrauchen',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Standard-Material-3-Oberflächen — undurchsichtig, keine Unschärfe, keine Schatten. Beste Leistung und Akkulaufzeit',
			'settings.glassEffectIntroTitle' => 'Wählen Sie Ihr Oberflächenmaterial',
			'settings.glassEffectIntroContent' => 'Kopfbereiche, die Registerleiste und Menüs verwenden Liquid Glass — echte Unschärfe und Lichtbrechung. Wenn es sich auf Ihrem Gerät langsam anfühlt oder Sie etwas Schlichteres bevorzugen, wechseln Sie jetzt zu Material (undurchsichtige Oberflächen, keine Unschärfe, keine Schatten).',
			'settings.glassEffectIntroHint' => 'Sie können dies jederzeit unter Einstellungen → Design → Oberflächenmaterial ändern.',
			'settings.glassEffectIntroDone' => 'Beibehalten',
			'settings.dynamicColor' => 'Dynamische Farbe',
			'settings.dynamicColorDesc' => 'Diese Konfiguration legt fest, ob die App dynamische Farben verwendet',
			'settings.useDynamicColor' => 'Dynamische Farbe verwenden',
			'settings.useDynamicColorDesc' => 'Diese Konfiguration legt fest, ob die App dynamische Farben verwendet',
			'settings.presetColors' => 'Voreingestellte Farben',
			'settings.customColors' => 'Benutzerdefinierte Farben',
			'settings.customColorsDisabledByDynamicColor' => 'Dynamische Farbe ist aktiviert, daher sind Voreinstellungs-/benutzerdefinierte Farben nicht verfügbar. Deaktivieren Sie zuerst die dynamische Farbe.',
			'settings.pickColor' => 'Farbe auswählen',
			'settings.cancel' => 'Abbrechen',
			'settings.confirm' => 'Bestätigen',
			'settings.noCustomColors' => 'Keine benutzerdefinierten Farben',
			'settings.recordAndRestorePlaybackProgress' => 'Wiedergabefortschritt aufzeichnen und wiederherstellen',
			'settings.autoPlayVideoOnFirstEnter' => 'Video beim ersten Betreten automatisch abspielen',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Diese Einstellung legt fest, ob das Video beim ersten Betreten der Videoseite automatisch zu spielen beginnt.',
			'settings.autoEnterFullscreen' => 'Automatisch Vollbild aktivieren',
			'settings.autoEnterFullscreenDesc' => 'Wann der Player von selbst in den Vollbildmodus wechseln soll. Private, gelöschte und externe Videos bleiben unberührt, ebenso Bild-in-Bild.',
			'settings.autoEnterFullscreenOff' => 'Aus',
			'settings.autoEnterFullscreenOffDesc' => 'Nie von selbst in den Vollbildmodus wechseln',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'Wenn die Wiedergabe startet',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Im Moment des tatsächlichen Wiedergabebeginns in den Vollbildmodus wechseln',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'Beim Öffnen des Videos',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Sofort in den Vollbildmodus wechseln, sobald die Videoseite geöffnet wird, ohne auf die Wiedergabe zu warten',
			'settings.autoEnterFullscreenKind' => 'Vollbildtyp',
			'settings.autoEnterFullscreenKindDesc' => 'Welche Art von Vollbild automatisch aktiviert wird. Nur Desktop.',
			'settings.autoEnterFullscreenKindSystem' => 'System-Vollbild',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Den Fenstermanager das Fenster in den Vollbildmodus versetzen lassen',
			'settings.autoEnterFullscreenKindApp' => 'App-Vollbild',
			'settings.autoEnterFullscreenKindAppDesc' => 'Das Fenster unverändert lassen und die gesamte App in den Player verwandeln',
			'settings.signature' => 'Signatur',
			'settings.enableSignature' => 'Signatur aktivieren',
			'settings.enableSignatureDesc' => 'Diese Konfiguration legt fest, ob die App beim Antworten eine Signatur hinzufügt',
			'settings.enterSignature' => 'Signatur eingeben',
			'settings.editSignature' => 'Signatur bearbeiten',
			'settings.signatureContent' => 'Signaturinhalt',
			'settings.signaturePreview' => 'Vorschau',
			'settings.signatureSampleBody' => 'Hier steht dein Text',
			'settings.signatureRegenerate' => 'Neu generieren',
			'settings.signatureNotSet' => 'Nicht festgelegt',
			'settings.signatureRuleHint' => 'Die Signatur wird nach dem Text angehängt, getrennt durch eine Trennlinie. Die Linie fügt die App hinzu – schreibe nur die Zeile unten.',
			'settings.signatureInsertVariable' => 'Variable einfügen',
			'settings.varDate' => 'Datum',
			'settings.varTime' => 'Uhrzeit',
			'settings.varDatetime' => 'Datum und Uhrzeit',
			'settings.varWeekday' => 'Wochentag',
			'settings.varPlatform' => 'Plattform',
			'settings.varPick' => 'Zufällige Zeile',
			'settings.varTitle' => 'Titel',
			'settings.varAuthor' => 'Urheber',
			'settings.varTags' => 'Tags',
			'settings.varSection' => 'Bereich',
			'settings.varReplyTo' => 'Antwort an',
			'settings.varPlaytime' => 'Wiedergabeposition',
			'settings.signatureContextGroup' => 'Kontextvariablen',
			'settings.signatureContextHint' => 'Die Werte kommen von der Seite, auf der du schreibst: Eine Videoseite kennt Titel, Autor, Tags und Abspielposition, das Forum kennt Bereich und Beitragsnummer. Rechts stehen Beispielwerte – was sich nicht füllen lässt, verschwindet beim Senden einfach.',
			'settings.signatureContextValue' => 'Je nach Seite',
			'settings.varFloor' => 'Beitragsnummer',
			'settings.varDuration' => 'Videolänge',
			'settings.signatureRecipesHint' => 'Keine Idee? Tippe eine an, übernimm sie und passe sie an. Unten siehst du, wie sie wirklich aussieht.',
			'settings.recipeWatchingName' => 'Was ich gerade sehe',
			'settings.recipeWatchingTemplate' => 'Sehe gerade %title% · %date%',
			'settings.recipeTimestampName' => 'Bis hierher gesehen',
			'settings.recipeTimestampTemplate' => 'Bei %playtime% von %duration%',
			'settings.recipeHitokotoName' => 'Spruch des Tages',
			'settings.recipeHitokotoTemplate' => 'Spruch des Tages: %hitokoto%',
			'settings.recipeAiName' => 'Die KI schreiben lassen',
			'settings.recipeAiTemplate' => '%ai_hitokoto%',
			'settings.recipeReplyName' => 'Beim Antworten grüßen',
			'settings.recipeReplyTemplate' => 'An %reply_to% · gesendet von %platform%',
			'settings.recipeMoodName' => 'Wechselnde Laune',
			'settings.recipeMoodTemplate' => 'Laune heute: %pick:bestens|geht so|frag lieber nicht%',
			'settings.signatureRecipesTitle' => 'Beispiele',
			'settings.signatureRecipesMore' => 'Mehr Beispiele',
			'settings.signatureSceneVideo' => 'Auf einem Video',
			'settings.signatureSceneForum' => 'Im Forum',
			'settings.signatureSceneAuthor' => 'Auf einem Profil',
			'settings.signatureSceneNone' => 'Ohne Kontext',
			'settings.signatureSceneFromHistory' => 'Der Beispielinhalt stammt aus dem, was du zuletzt angesehen hast. Beim echten Senden zählt die Seite, auf der du gerade bist.',
			'settings.signatureSceneFromDemo' => 'Noch kein Verlauf – es wird ein Platzhalter gezeigt. Beim echten Senden zählt die Seite, auf der du gerade bist.',
			'settings.signatureDemoVideoTitle' => 'Tanz im Mondlicht',
			'settings.signatureDemoAuthor' => 'Hoshino',
			'settings.signatureDemoTags' => 'mmd 4k 60fps',
			'settings.signatureDemoThreadTitle' => 'Tipps für die Qualitätseinstellungen?',
			'settings.signatureDemoSection' => 'Allgemein',
			'settings.signatureDemoQuote' => 'Langsam ist ruhig, ruhig ist schnell.',
			'settings.signatureDemoAiQuote' => 'Diese Drehung bei dreieinhalb Minuten war allein schon alles wert.',
			'settings.signatureRecipeGroupWatching' => 'Beim Ansehen',
			'settings.signatureRecipeGroupReplying' => 'Beim Antworten',
			'settings.signatureRecipeGroupForum' => 'Im Forum',
			'settings.signatureRecipeGroupDaily' => 'Jeden Tag ein Satz',
			'settings.signatureRecipeGroupAi' => 'Die KI schreiben lassen',
			'settings.signaturePromptSampleContext' => 'Dieser Testlauf nutzt den Beispielkontext einer Videoseite. Beim echten Senden bekommt die KI das, was du gerade ansiehst.',
			'settings.recipeAuthorTagsName' => 'Autor und Tags',
			'settings.recipeAuthorTagsTemplate' => '%author% · %tags%',
			'settings.recipeFloorName' => 'Antwort auf einen Beitrag',
			'settings.recipeFloorTemplate' => 'Aus Beitrag %floor% · an %reply_to%',
			'settings.recipeSectionName' => 'Bereich nennen',
			'settings.recipeSectionTemplate' => 'Aus %section%',
			'settings.recipeDailyName' => 'Datum plus Zitat',
			'settings.recipeDailyTemplate' => '%date% %weekday% · %hitokoto%',
			'settings.signatureSources' => 'Datenquellen',
			'settings.signatureAutoTranslate' => 'In meine Sprache übersetzen',
			'settings.signatureAutoTranslateDesc' => 'Zitatquellen wie Hitokoto liefern bisher nur Chinesisch. Der Satz wird direkt vor dem Senden übersetzt.',
			'settings.signatureWizardTitle' => 'Datenquelle hinzufügen',
			'settings.signatureWizardUrlTitle' => 'Adresse des Endpunkts',
			'settings.signatureWizardUrlHint' => 'Gib eine URL an, die eine Textzeile zurückliefert. Der Knopf unten ruft sie wirklich auf, damit du siehst, was zurückkommt.',
			'settings.signatureWizardFetch' => 'Abrufen',
			'settings.signatureWizardSkipTest' => 'Überspringen, nur umbenennen',
			'settings.signatureWizardPickTitle' => 'Wähle den gewünschten Teil',
			'settings.signatureWizardPickHint' => 'Das kam von diesem Endpunkt zurück. Tippe die Zeile an, die deine Signatur zeigen soll.',
			'settings.signatureWizardPickPlainHint' => 'Dieser Endpunkt liefert reinen Text – das Ganze wird angezeigt.',
			'settings.signatureWizardWholeBody' => 'Die ganze Antwort',
			'settings.signatureWizardNameTitle' => 'Gib ihr einen Namen',
			'settings.signatureWizardNameHint' => 'Der Name ist nur für dich. Angesprochen wird die Quelle über den Referenznamen darunter.',
			'settings.signatureWizardNext' => 'Weiter',
			'settings.signatureWizardDone' => 'Fertig',
			'settings.signatureWizardStripHtml' => 'HTML-Tags entfernen',
			'settings.signatureWizardAdvanced' => 'Erweitert: mit Muster herausziehen',
			'settings.signatureWizardExtractHint' => 'Regulärer Ausdruck; die erste Gruppe zählt',
			'settings.signatureWizardExtractMissed' => 'Das Muster passt nicht, der Text bleibt unverändert',
			'settings.signatureWizardChooseTitle' => 'Quelle auswählen',
			'settings.signatureWizardChooseHint' => 'Tippe auf eine fertige Quelle, fertig. Oder gib deinen eigenen Endpunkt an.',
			'settings.signatureWizardCustomSource' => 'Eigenen Endpunkt verwenden',
			'settings.signatureWizardWithOrigin' => 'Herkunft mit anzeigen',
			'settings.signatureWizardRandomItem' => 'Jedes Mal eine andere nehmen',
			'settings.signatureWizardSuffixTitle' => 'Weiteres Feld anhängen',
			'settings.signatureWizardSuffixNone' => 'Nichts',
			'settings.signatureOptFlavor' => 'Inhalt',
			'settings.signatureOptFlavorAny' => 'Alles',
			'settings.signatureOptFlavorOtaku' => 'Anime, Manga & Spiele',
			'settings.signatureOptFlavorLiterary' => 'Literatur & Poesie',
			'settings.signatureOptFlavorMeme' => 'Internetkultur',
			'settings.signatureOptLength' => 'Länge',
			'settings.signatureOptLengthAny' => 'Beliebig',
			'settings.signatureOptLengthShort' => 'Nur kurze Sätze',
			'settings.signatureRestoreDefault' => 'Standard wiederherstellen',
			'settings.signatureSourceHitokoto' => 'Hitokoto (Zufallszitat)',
			'settings.signatureAiSourceName' => 'KI-generierte Zeile',
			'settings.signatureEditTextHint' => 'Das ist die Signatur, die bereits in diesem Kommentar steht — Spruch und Datum sind jetzt einfach Text, ändere sie beliebig. Leeren entfernt die Signatur.',
			'settings.signatureResolving' => ({required Object name}) => 'Erzeuge ${name}…',
			'settings.signaturePendingValue' => '(wird beim Senden erzeugt)',
			'settings.signatureAiHint' => 'Ein Satz, den die KI spontan schreibt – für jeden Kommentar neu, über den von dir eingerichteten KI-Anbieter. Auf Video-, Galerie- und Forumseiten weiß sie außerdem, was du gerade ansiehst, und kann darauf eingehen.',
			'settings.signatureAiUnavailable' => 'Noch kein KI-Anbieter eingerichtet, deshalb taucht diese Quelle nicht im Variablen-Panel auf.',
			'settings.signaturePromptTitle' => 'Prompt',
			'settings.signaturePromptHint' => 'Das geht so an das Modell. Schreib es um, wie du willst — Ton, Länge, Thema. Die Regeln, die schon drinstehen, lohnt es sich zu behalten.',
			'settings.signaturePromptReset' => 'Standard wiederherstellen',
			'settings.signaturePromptTry' => 'Ausprobieren',
			'settings.signaturePromptSample' => 'Das Ergebnis',
			'settings.signaturePromptLanguageHint' => 'wird durch deine Oberflächensprache ersetzt. Ohne das folgt die Zeile der Sprache des Prompts.',
			'settings.signaturePromptEdited' => 'geändert',
			'settings.signatureVariablesGroup' => 'Eingebaute Variablen',
			'settings.signatureNeedsNetwork' => 'Braucht Netz',
			'settings.signatureBuiltinSource' => 'Eingebaut',
			'settings.signatureSourceIdReserved' => 'Dieser Name gehört bereits einer eingebauten Variablen',
			'settings.signatureSourcesTitle' => 'Eigene Datenquellen',
			'settings.signatureSourcesHint' => 'Gib eine Adresse an, die eine Textzeile zurückliefert, und du kannst sie in deine Signatur holen.',
			'settings.signatureSourcesEmpty' => 'Noch keine Datenquellen',
			'settings.signatureAddSource' => 'Hinzufügen',
			'settings.signatureEditSource' => 'Datenquelle bearbeiten',
			'settings.signatureSourceName' => 'Name',
			'settings.signatureSourceId' => 'Referenzname',
			'settings.signatureSourceIdHint' => 'So spricht deine Signatur diese Quelle an',
			'settings.signatureSourceUrl' => 'Endpunkt-URL',
			'settings.signatureSourcePath' => 'Wertpfad',
			'settings.signatureSourcePathHint' => 'Leer lassen, wenn die gesamte Antwort der Text ist. Mit data.text holst du dieses Feld aus einer JSON-Antwort.',
			'settings.signatureSourceTest' => 'Testen',
			'settings.signatureSourceTestOk' => 'Hat geklappt',
			'settings.signatureSourceTestFailed' => 'Es kam nichts zurück',
			'settings.signatureSourceIdInvalid' => 'Referenznamen dürfen nur Kleinbuchstaben, Ziffern und Unterstriche enthalten',
			'settings.signatureSourceIdDuplicate' => 'Dieser Referenzname ist bereits vergeben',
			'settings.signatureSourceUrlRequired' => 'Eine Endpunkt-URL ist erforderlich',
			'settings.exportConfig' => 'App-Konfiguration exportieren',
			'settings.exportConfigDesc' => 'Einstellungen und Verlauf (Browserverlauf, Wiedergabefortschritt, Favoriten usw.) zur Sicherung oder Übertragung auf ein anderes Gerät in eine Datei exportieren. Download-Aufgaben sind nicht enthalten.',
			'settings.importConfig' => 'App-Konfiguration importieren',
			'settings.importConfigDesc' => 'App-Konfiguration aus einer Datei importieren',
			'settings.exportConfigSuccess' => 'Konfiguration erfolgreich exportiert!',
			'settings.exportConfigFailed' => 'Konfiguration konnte nicht exportiert werden',
			'settings.importConfigSuccess' => 'Konfiguration erfolgreich importiert!',
			'settings.importConfigFailed' => 'Konfiguration konnte nicht importiert werden',
			'settings.exportIncludeSensitive' => 'Sensible Informationen einschließen',
			'settings.exportIncludeSensitiveDesc' => 'Schließt API-Schlüssel, Sitzungstoken und Proxy-Adresse ein. Nur aktivieren, wenn Sie auf Ihr eigenes Gerät sichern.',
			'settings.importConfigOverwriteWarning' => 'Beim Importieren werden Ihre aktuellen Einstellungen und Ihr Verlauf (Browserverlauf, Wiedergabefortschritt, Favoriten usw.) überschrieben. Fortfahren?',
			'settings.importConfigRestartTitle' => 'Import erfolgreich',
			'settings.importConfigRestartContent' => 'Ihre Konfiguration wurde importiert. Bitte schließen Sie die App vollständig und öffnen Sie sie erneut, damit alle Änderungen wirksam werden.',
			'settings.historyUpdateLogs' => 'Update-Verlauf',
			'settings.noUpdateLogs' => 'Keine Update-Protokolle verfügbar',
			'settings.versionLabel' => 'Version: {version}',
			'settings.releaseDateLabel' => 'Veröffentlichungsdatum: {date}',
			'settings.noChanges' => 'Kein Update-Inhalt verfügbar',
			'settings.interaction' => 'Interaktion',
			'settings.enableVibration' => 'Vibration aktivieren',
			'settings.enableVibrationDesc' => 'Vibrationsfeedback bei der Interaktion mit der App aktivieren',
			'settings.defaultKeepVideoToolbarVisible' => 'Video-Symbolleiste sichtbar halten',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Diese Einstellung legt fest, ob die Video-Symbolleiste beim ersten Betreten der Videoseite sichtbar bleibt.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Auf Mobilgeräten kann der Kinomodus Leistungsprobleme verursachen. Sie können ihn optional aktivieren.',
			'settings.fullscreenOrientation' => 'Bildschirmausrichtung nach Wechsel in den Vollbildmodus',
			'settings.fullscreenOrientationDesc' => 'Diese Einstellung legt die Standardbildschirmausrichtung beim Wechsel in den Vollbildmodus fest (nur mobil)',
			'settings.fullscreenOrientationLeftLandscape' => 'Querformat links',
			'settings.fullscreenOrientationRightLandscape' => 'Querformat rechts',
			'settings.screenFit' => 'Bildschirmgröße',
			'settings.screenFitDesc' => 'Wählen Sie, wie das Video den Player-Bereich füllt.',
			'settings.rememberScreenFit' => 'Bildschirmgröße merken',
			'settings.rememberScreenFitDesc' => 'Die ausgewählte Größe auf später geöffnete Videos anwenden.',
			'settings.screenFitFit' => 'Einpassen',
			'settings.screenFitFitDesc' => 'Das gesamte Bild unter Beibehaltung des Seitenverhältnisses anzeigen',
			'settings.screenFitStretch' => 'Strecken',
			'settings.screenFitStretchDesc' => 'Den Player-Bereich füllen; das Bild kann verzerrt werden',
			'settings.screenFitCover' => 'Ausfüllen',
			'settings.screenFitCoverDesc' => 'Den Player-Bereich unter Beibehaltung des Seitenverhältnisses füllen; Überstehendes wird abgeschnitten',
			'settings.screenFitRatioDesc' => 'Dieses Seitenverhältnis erzwingen; das Bild kann verzerrt werden',
			'settings.jumpLink' => 'Sprunglink',
			'settings.language' => 'Sprache',
			'settings.languageNativeName' => 'Deutsch',
			'settings.followSystemLanguage' => 'Systemsprache',
			'settings.languageChangedMessage' => 'Sprache geändert. Einige Funktionen werden erst nach einem Neustart der App wirksam.',
			'settings.languageChanged' => 'Die Spracheinstellung wurde geändert. Bitte starten Sie die App neu, damit sie wirksam wird.',
			'settings.keybinding.title' => 'Tastenkürzel',
			'settings.keybinding.entryLabel' => 'Tastenkürzel',
			'settings.keybinding.entryDesc' => 'Tastenkürzel der App anpassen (hauptsächlich für Desktop)',
			'settings.keybinding.desktopHint' => 'Tastenkürzel gelten hauptsächlich für Desktop-Tastaturen; auf Mobilgeräten werden meist Gesten verwendet.',
			'settings.keybinding.resetAll' => 'Alle auf Standard zurücksetzen',
			'settings.keybinding.resetAllConfirm' => 'Alle Tastenkürzel der App auf die Standardwerte zurücksetzen?',
			'settings.keybinding.resetToDefault' => 'Auf Standard zurücksetzen',
			'settings.keybinding.resetScope' => 'Diesen Bereich zurücksetzen',
			'settings.keybinding.notSet' => 'Nicht festgelegt',
			'settings.keybinding.addShortcut' => 'Tastenkürzel hinzufügen',
			'settings.keybinding.removeShortcut' => 'Dieses Tastenkürzel entfernen',
			'settings.keybinding.pressNewShortcut' => 'Neues Tastenkürzel drücken…',
			'settings.keybinding.recordingCancelHint' => 'Esc drücken zum Abbrechen',
			'settings.keybinding.mouseHint' => 'Sie können auch Seitentasten der Maus (Zurück / Vorwärts) oder die mittlere Taste belegen',
			'settings.keybinding.mouseNotSupportedInScope' => 'Dieser Bereich verarbeitet keine Maustasten; verwenden Sie stattdessen die Tastatur',
			'settings.keybinding.capabilityKeyboardOnly' => 'Dieser Bereich akzeptiert nur Tastaturtasten',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Dieser Bereich akzeptiert Tastaturtasten sowie die mittlere und die seitlichen Maustasten',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Dieser Bereich akzeptiert Tastaturtasten sowie die mittlere und die vordere Maustaste (die Zurück-Taste ist vom System belegt)',
			'settings.keybinding.rejectMultipleButtons' => 'Drücken Sie jeweils nur eine Maustaste',
			'settings.keybinding.rejectPlatformBack' => 'Das System verwendet dies bereits für Zurück; eine Belegung würde zweimal zurückgehen',
			'settings.keybinding.detectedLabel' => 'Erkannt',
			'settings.keybinding.reservedKey' => 'Diese Taste ist vom System reserviert und kann nicht belegt werden',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Diese Taste ist mit „${action}“ belegt; sie bleibt hier reserviert, damit Sie diesen Bildschirm weiterhin verlassen können',
			'settings.keybinding.conflictTitle' => 'Tastenkürzel-Konflikt',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Diese Kombination ist bereits mit „${action}“ belegt. Wenn Sie fortfahren, wird die vorhandene Belegung entfernt.',
			'settings.keybinding.conflictContinue' => 'Trotzdem belegen',
			'settings.keybinding.shadowWarningTitle' => 'Überschneidung mit globalem Tastenkürzel',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Diese Kombination ist global mit „${action}“ belegt. Wenn Sie sie hier belegen, wird diese Aktion nur innerhalb dieses Bereichs überschrieben.',
			'settings.keybinding.globalShadowedMessage' => ({required Object scope, required Object action}) => 'Diese Kombination ist bereits in ${scope} mit „${action}“ belegt. In diesem Bereich wird dieses globale Tastenkürzel dadurch überschrieben.',
			'settings.keybinding.searchHint' => 'Tastenkürzel suchen…',
			'settings.keybinding.scopeGlobal' => 'Global',
			'settings.keybinding.scopeGallery' => 'Galerie',
			'settings.keybinding.scopeVideo' => 'Video',
			'settings.keybinding.categoryNavigation' => 'Navigation',
			'settings.keybinding.categoryZoom' => 'Zoom',
			'settings.keybinding.categoryPlayback' => 'Wiedergabe',
			'settings.keybinding.categorySeek' => 'Spulen',
			'settings.keybinding.categoryVolume' => 'Lautstärke',
			'settings.keybinding.categoryDisplay' => 'Anzeige',
			'settings.keybinding.actionGlobalBack' => 'Zurück',
			'settings.keybinding.actionGalleryNext' => 'Nächstes Foto',
			'settings.keybinding.actionGalleryPrevious' => 'Vorheriges Foto',
			'settings.keybinding.actionGalleryZoomIn' => 'Vergrößern',
			'settings.keybinding.actionGalleryZoomOut' => 'Verkleinern',
			'settings.keybinding.actionGalleryResetZoom' => 'Zoom zurücksetzen',
			'settings.keybinding.actionGalleryPlayPause' => 'Wiedergabe / Pause',
			'settings.keybinding.actionGallerySeekBackward' => 'Zurückspulen',
			'settings.keybinding.actionGallerySeekForward' => 'Vorspulen',
			'settings.keybinding.actionGalleryToggleMute' => 'Stummschaltung umschalten',
			'settings.keybinding.actionPlayPause' => 'Wiedergabe / Pause',
			'settings.keybinding.actionSpeedUp' => 'Geschwindigkeit erhöhen',
			'settings.keybinding.actionSpeedDown' => 'Geschwindigkeit verringern',
			'settings.keybinding.actionSeekForward' => 'Vorspulen',
			'settings.keybinding.actionSeekBackward' => 'Zurückspulen',
			'settings.keybinding.actionVolumeUp' => 'Lautstärke erhöhen',
			'settings.keybinding.actionVolumeDown' => 'Lautstärke verringern',
			'settings.keybinding.actionToggleMute' => 'Stummschaltung umschalten',
			'settings.keybinding.actionToggleFullscreen' => 'Vollbild umschalten',
			'settings.keybinding.seekLongPressHint' => 'Halten Sie die Taste zum Vor-/Zurückspulen gedrückt, um den Langdruck-Geschwindigkeitsmodus auszulösen',
			'settings.keybinding.zoomSectionTitle' => 'Bildzoom (fest)',
			'settings.keybinding.zoomFixedNote' => 'Die folgenden Tastenkürzel sind fest und können nicht geändert werden',
			'settings.keybinding.zoomScaleLabel' => 'Bild vergrößern',
			'settings.keybinding.zoomScaleHint' => 'Strg + Mausrad',
			'settings.keybinding.zoomRotateLabel' => 'Bild drehen',
			'settings.keybinding.zoomRotateHint' => 'Umschalt + Mausrad',
			'settings.keybinding.zoomPinchGesture' => 'Zusammenziehen',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Drehen mit zwei Fingern',
			'settings.gestureControl' => 'Gestensteuerung',
			'settings.leftDoubleTapRewind' => 'Zurückspulen bei Doppeltipp links',
			'settings.rightDoubleTapFastForward' => 'Vorspulen bei Doppeltipp rechts',
			'settings.doubleTapPause' => 'Pause durch Doppeltippen',
			'settings.rightVerticalSwipeVolume' => 'Lautstärke durch vertikales Wischen rechts (wirksam beim Öffnen einer neuen Seite)',
			'settings.leftVerticalSwipeBrightness' => 'Helligkeit durch vertikales Wischen links (wirksam beim Öffnen einer neuen Seite)',
			'settings.longPressFastForward' => 'Vorspulen bei Langdruck',
			'settings.enableMouseHoverShowToolbar' => 'Symbolleiste bei Mauszeiger-Anzeige einblenden',
			'settings.enableMouseHoverShowToolbarInfo' => 'Wenn aktiviert, wird die Video-Symbolleiste angezeigt, wenn der Mauszeiger über dem Player schwebt. Nach 3 Sekunden Inaktivität wird sie automatisch ausgeblendet.',
			'settings.enableHorizontalDragSeek' => 'Horizontales Wischen zum Spulen',
			'settings.enableVideoGestureZoom' => 'Videobild durch Zusammenziehen vergrößern',
			'settings.enableVideoGestureZoomInfo' => 'Ziehen Sie mit zwei Fingern zusammen (oder Strg + Mausrad auf dem Desktop), um das Videobild zu vergrößern, und ziehen Sie es dann zum Verschieben.',
			'settings.showCenterPlayPauseButton' => 'Wiedergabe-/Pause-Schaltfläche in der Mitte',
			'settings.showCenterPlayPauseButtonDesc' => 'Die große Wiedergabe-/Pause-Schaltfläche in der Mitte des Players anzeigen.',
			'settings.audioVideoConfig' => 'Audio-Video-Konfiguration',
			'settings.expandBuffer' => 'Puffer erweitern',
			'settings.expandBufferInfo' => 'Wenn aktiviert, wird die Puffergröße erhöht; die Ladezeit wird länger, aber die Wiedergabe ist flüssiger',
			'settings.videoSyncMode' => 'Video-Synchronisierungsmodus',
			'settings.videoSyncModeSubtitle' => 'Strategie zur Audio-Video-Synchronisierung',
			'settings.hardwareDecodingMode' => 'Hardware-Dekodierungsmodus',
			'settings.hardwareDecodingModeSubtitle' => 'Einstellungen für die Hardware-Dekodierung',
			'settings.enableHardwareAcceleration' => 'Hardwarebeschleunigung aktivieren',
			'settings.enableHardwareAccelerationInfo' => 'Das Aktivieren der Hardwarebeschleunigung kann die Dekodierungsleistung verbessern, aber einige Geräte sind möglicherweise nicht kompatibel',
			'settings.useOpenSLESAudioOutput' => 'OpenSLES-Audioausgabe verwenden',
			'settings.useOpenSLESAudioOutputInfo' => 'Audioausgabe mit niedriger Latenz verwenden, kann die Audioleistung verbessern',
			'settings.videoSyncAudio' => 'Audio-Synchronisierung',
			'settings.videoSyncDisplayResample' => 'Neuabtastung anzeigen',
			'settings.videoSyncDisplayResampleVdrop' => 'Neuabtastung anzeigen (Frames verwerfen)',
			'settings.videoSyncDisplayResampleDesync' => 'Neuabtastung anzeigen (desynchronisiert)',
			'settings.videoSyncDisplayTempo' => 'Tempo anzeigen',
			'settings.videoSyncDisplayVdrop' => 'Video-Frames verwerfen anzeigen',
			'settings.videoSyncDisplayAdrop' => 'Audio-Frames verwerfen anzeigen',
			'settings.videoSyncDisplayDesync' => 'Desynchronisation anzeigen',
			'settings.videoSyncDesync' => 'Desynchronisiert',
			'settings.forumSettings.name' => 'Forum',
			'settings.forumSettings.configureYourForumSettings' => 'Konfigurieren Sie Ihre Forum-Einstellungen',
			'settings.gallerySettings.gallerySettingsTitle' => 'Galerie-Einstellungen',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Einstellungen des Galerie-Betrachters konfigurieren',
			'settings.gallerySettings.defaultViewerQuality' => 'Standard-Bildqualität des Betrachters',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Wählen Sie, welche Bildqualität beim Öffnen des Galerie-Betrachters standardmäßig angezeigt wird.',
			'settings.blockSettings.title' => 'Inhaltsblockierung',
			'settings.blockSettings.subtitle' => 'Videos und Galerien automatisch ausblenden, deren Titel einem Stichwort oder Muster entspricht oder die von einem blockierten Nutzer stammen. Der gesamte Abgleich erfolgt auf Ihrem Gerät — nichts wird hochgeladen.',
			'settings.blockSettings.blocked' => 'Blockiert',
			'settings.blockSettings.reveal' => 'Anzeigen',
			'settings.blockSettings.reblock' => 'Erneut blockieren',
			'settings.blockSettings.why' => 'Warum blockiert?',
			'settings.blockSettings.manageRules' => 'Regeln verwalten',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'Titel enthält „${value}“',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'Titel entspricht „${value}“',
			'settings.blockSettings.reasonUser' => 'Von einem blockierten Nutzer',
			'settings.blockSettings.addRule' => 'Regel hinzufügen',
			'settings.blockSettings.editRule' => 'Regel bearbeiten',
			'settings.blockSettings.deleteRule' => 'Regel löschen',
			'settings.blockSettings.ruleType' => 'Regeltyp',
			'settings.blockSettings.keyword' => 'Stichwort',
			'settings.blockSettings.regex' => 'Regex',
			'settings.blockSettings.userId' => 'Nutzer',
			'settings.blockSettings.value' => 'Abzugleichender Text',
			'settings.blockSettings.caseSensitive' => 'Groß-/Kleinschreibung beachten',
			'settings.blockSettings.regexHint' => 'z. B. Vorschau|Teaser',
			'settings.blockSettings.valueRequired' => 'Bitte geben Sie den abzugleichenden Text ein',
			'settings.blockSettings.invalidRegex' => 'Das ist kein gültiger regulärer Ausdruck',
			'settings.blockSettings.noRules' => 'Noch keine Regeln. Tippen Sie auf +, um eine hinzuzufügen.',
			'settings.blockSettings.blockUser' => 'Blockieren',
			'settings.blockSettings.unblockUser' => 'Entsperren',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => '„${name}“ blockieren? Deren Videos und Galerien werden in Listen und Suchergebnissen ausgeblendet.',
			'settings.blockSettings.userBlocked' => 'Nutzer blockiert',
			'settings.blockSettings.userUnblocked' => 'Blockierung des Nutzers aufgehoben',
			'settings.blockSettings.exportRules' => 'Exportieren',
			'settings.blockSettings.importRules' => 'Importieren',
			'settings.blockSettings.importExport' => 'Import / Export',
			'settings.blockSettings.exportSuccess' => 'Regeln exportiert',
			'settings.blockSettings.exportFailed' => 'Regeln konnten nicht exportiert werden',
			'settings.blockSettings.importSuccess' => ({required Object count}) => '${count} Regel(n) importiert',
			'settings.blockSettings.importFailed' => 'Regeln konnten nicht importiert werden',
			'settings.blockSettings.regexHelp' => 'Musterhilfe',
			'settings.blockSettings.regexHelpTitle' => 'Regex-Referenz',
			'settings.blockSettings.regexHelpIntro' => 'Ein regulärer Ausdruck gleicht Titel flexibler ab als ein einfaches Stichwort. Einige gängige Beispiele:',
			'settings.blockSettings.regexHelpTapHint' => 'Tippen Sie auf ein Beispiel, um es einzusetzen.',
			'settings.blockSettings.regexEx1Pattern' => 'Vorschau|Teaser|Bonus',
			'settings.blockSettings.regexEx1Desc' => 'Entspricht einem dieser Wörter (| bedeutet „oder“)',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Titel, die mit [Klammern] beginnen',
			_ => null,
		} ?? switch (path) {
			'settings.blockSettings.regexEx3Pattern' => 'Sammlung\$',
			'settings.blockSettings.regexEx3Desc' => 'Titel, die mit „Sammlung“ enden',
			'settings.blockSettings.regexEx4Pattern' => 'Folge [0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ steht für eine oder mehrere Ziffern — entspricht „Folge 12“',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9] steht für eine Ziffer und {4} bedeutet vier hintereinander (z. B. ein Jahr)',
			'settings.blockSettings.regexEx1Sample' => 'Neuer Spiel-Teaser jetzt online',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Ganzer Film',
			'settings.blockSettings.regexEx3Sample' => 'Frühlings-Kunstsammlung',
			'settings.blockSettings.regexEx4Sample' => 'Meine Serie Folge 12 Zusammenfassung',
			'settings.blockSettings.regexEx5Sample' => 'Die besten Highlights von 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'Beispieltitel',
			'settings.blockSettings.regexHelpMatchedTag' => 'Blockiert',
			'settings.blockSettings.regexHelpNoMatch' => 'Keine Übereinstimmung',
			'settings.blockSettings.regexEx6Pattern' => '[Ss]taffel',
			'settings.blockSettings.regexEx6Desc' => '[Ss] entspricht einem großen oder kleinen S — hier erfasst es „Staffel“',
			'settings.blockSettings.regexEx6Sample' => 'Trailer zur letzten Staffel',
			'settings.blockSettings.regexEx7Pattern' => '(der Film|die Serie)',
			'settings.blockSettings.regexEx7Desc' => 'Klammern () gruppieren Alternativen — entspricht „der Film“ oder „die Serie“',
			'settings.blockSettings.regexEx7Sample' => 'Jetzt die Serie ansehen',
			'settings.blockSettings.regexEx8Pattern' => 'Staffeln?',
			'settings.blockSettings.regexEx8Desc' => 's? macht den vorherigen Buchstaben optional — entspricht „Staffel“ und „Staffeln“',
			'settings.blockSettings.regexEx8Sample' => 'Paket mit zwei Staffeln',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ bedeutet ein oder mehr — entspricht !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'OMG!!! Muss man sehen',
			'settings.blockSettings.regexEx10Pattern' => 'Bonus.*Szene',
			'settings.blockSettings.regexEx10Desc' => '.* entspricht beliebigem Text dazwischen — „Bonus … Szene“',
			'settings.blockSettings.regexEx10Sample' => 'Bonus Gelöschte Szene',
			'settings.chatSettings.name' => 'Chat',
			'settings.chatSettings.configureYourChatSettings' => 'Konfigurieren Sie Ihre Chat-Einstellungen',
			'settings.hardwareDecodingAuto' => 'Automatisch',
			'settings.hardwareDecodingAutoCopy' => 'Automatisch kopieren',
			'settings.hardwareDecodingAutoSafe' => 'Automatisch sicher',
			'settings.hardwareDecodingNo' => 'Deaktiviert',
			'settings.hardwareDecodingYes' => 'Erzwingen',
			'settings.cdnDistributionStrategy' => 'Inhaltsverteilungsstrategie',
			'settings.cdnDistributionStrategyDesc' => 'Wählen Sie die Verteilungsstrategie der Videoquellenserver, um die Ladegeschwindigkeit zu optimieren',
			'settings.cdnDistributionStrategyLabel' => 'Verteilungsstrategie',
			'settings.cdnDistributionStrategyNoChange' => 'Keine Änderung (ursprünglichen Server verwenden)',
			'settings.cdnDistributionStrategyAuto' => 'Automatisch auswählen (schnellster Server)',
			'settings.cdnDistributionStrategySpecial' => 'Server festlegen',
			'settings.cdnSpecialServer' => 'Server festlegen',
			'settings.cdnRefreshServerListHint' => 'Bitte klicken Sie auf die Schaltfläche unten, um die Serverliste zu aktualisieren',
			'settings.cdnRefreshButton' => 'Aktualisieren',
			'settings.cdnFastRingServers' => 'Fast-Ring-Server',
			'settings.cdnRefreshServerListTooltip' => 'Serverliste aktualisieren',
			'settings.cdnSpeedTestButton' => 'Geschwindigkeitstest',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Test läuft (${count})',
			'settings.cdnNoServerDataHint' => 'Keine Serverdaten verfügbar, bitte klicken Sie auf die Aktualisieren-Schaltfläche',
			'settings.cdnTestingStatus' => 'Wird getestet',
			'settings.cdnUnreachableStatus' => 'Nicht erreichbar',
			'settings.cdnNotTestedStatus' => 'Nicht getestet',
			'settings.downloadSettings.downloadSettings' => 'Download-Einstellungen',
			'settings.downloadSettings.enableDownloadNotifications' => 'Download-Benachrichtigungen',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Eine Systembenachrichtigung anzeigen, wenn ein einzelner Download abgeschlossen ist oder fehlschlägt',
			'settings.downloadSettings.notificationPermissionDenied' => 'Benachrichtigungsberechtigung verweigert. In-App-Benachrichtigungen funktionieren weiterhin; aktivieren Sie Systembenachrichtigungen in den Einstellungen.',
			'settings.downloadSettings.storagePermissionStatus' => 'Status der Speicherberechtigung',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Zugriff auf öffentliches Verzeichnis erfordert Speicherberechtigung',
			'settings.downloadSettings.checkingPermissionStatus' => 'Berechtigungsstatus wird geprüft...',
			'settings.downloadSettings.storagePermissionGranted' => 'Speicherberechtigung erteilt',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Speicherberechtigung nicht erteilt',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Speicherberechtigung erfolgreich erteilt',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Speicherberechtigung nicht erteilt, einige Funktionen sind möglicherweise eingeschränkt',
			'settings.downloadSettings.storagePermissionRationale' => 'Um Downloads in dem von Ihnen gewählten Ordner zu speichern, benötigt die App Speicherzugriff.\n\nUnter Android 11 und höher bedeutet das die Berechtigung „Zugriff auf alle Dateien“; ohne sie werden Dateien stattdessen im privaten App-Ordner gespeichert.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Um Downloads in dem von Ihnen gewählten Ordner zu speichern, benötigt die App Speicherzugriff.\n\nOhne ihn werden Dateien stattdessen im privaten App-Ordner gespeichert.',
			'settings.downloadSettings.grantStoragePermission' => 'Speicherberechtigung erteilen',
			'settings.downloadSettings.customDownloadPath' => 'Benutzerdefinierter Downloadpfad',
			'settings.downloadSettings.customDownloadPathDescription' => 'Wenn aktiviert, können Sie einen benutzerdefinierten Speicherort für heruntergeladene Dateien wählen',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Tipp: Die Auswahl öffentlicher Verzeichnisse (z. B. des Downloads-Ordners) erfordert eine Speicherberechtigung; verwenden Sie am besten zuerst die empfohlenen Pfade',
			'settings.downloadSettings.androidWarning' => 'Android-Hinweis: Vermeiden Sie die Auswahl öffentlicher Verzeichnisse (z. B. des Downloads-Ordners); verwenden Sie am besten app-spezifische Verzeichnisse, um die Zugriffsberechtigungen zu gewährleisten.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Hinweis: Sie haben ein öffentliches Verzeichnis ausgewählt; für normale Datei-Downloads ist eine Speicherberechtigung erforderlich',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Für öffentliche Verzeichnisse ist eine Speicherberechtigung erforderlich',
			'settings.downloadSettings.currentDownloadPath' => 'Aktueller Downloadpfad',
			'settings.downloadSettings.actualDownloadPath' => 'Tatsächlicher Downloadpfad',
			'settings.downloadSettings.defaultAppDirectory' => 'Standard-App-Verzeichnis',
			'settings.downloadSettings.permissionGranted' => 'Erteilt',
			'settings.downloadSettings.permissionRequired' => 'Berechtigung erforderlich',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Benutzerdefinierten Downloadpfad aktivieren',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Bei Deaktivierung wird der Standardpfad der App verwendet',
			'settings.downloadSettings.customDownloadPathLabel' => 'Benutzerdefinierter Downloadpfad',
			'settings.downloadSettings.selectDownloadFolder' => 'Download-Ordner auswählen',
			'settings.downloadSettings.recommendedPath' => 'Empfohlener Pfad',
			'settings.downloadSettings.selectFolder' => 'Ordner auswählen',
			'settings.downloadSettings.filenameTemplate' => 'Dateinamen-Vorlage',
			'settings.downloadSettings.filenameTemplateDescription' => 'Passen Sie die Benennungsregeln für heruntergeladene Dateien an, Variablenersetzung wird unterstützt',
			'settings.downloadSettings.videoFilenameTemplate' => 'Dateinamen-Vorlage für Videos',
			'settings.downloadSettings.galleryFolderTemplate' => 'Galerie-Ordner-Vorlage',
			'settings.downloadSettings.imageFilenameTemplate' => 'Dateinamen-Vorlage für Bilder',
			'settings.downloadSettings.resetToDefault' => 'Auf Standard zurücksetzen',
			'settings.downloadSettings.supportedVariables' => 'Unterstützte Variablen',
			'settings.downloadSettings.supportedVariablesDescription' => 'In Dateinamen-Vorlagen können die folgenden Variablen verwendet werden:',
			'settings.downloadSettings.copyVariable' => 'Variable kopieren',
			'settings.downloadSettings.variableCopied' => 'Variable kopiert',
			'settings.downloadSettings.warningPublicDirectory' => 'Warnung: Das ausgewählte öffentliche Verzeichnis ist möglicherweise nicht zugänglich. Wählen Sie am besten ein app-spezifisches Verzeichnis.',
			'settings.downloadSettings.downloadPathUpdated' => 'Downloadpfad aktualisiert',
			'settings.downloadSettings.selectPathFailed' => 'Pfad konnte nicht ausgewählt werden',
			'settings.downloadSettings.pickerAlreadyActive' => 'Die Ordnerauswahl ist bereits geöffnet',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Nicht unterstützter Speicherort. Wählen Sie einen Ordner im Gerätespeicher oder auf der SD-Karte.',
			'settings.downloadSettings.recommendedPathSet' => 'Auf empfohlenen Pfad festgelegt',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Empfohlener Pfad konnte nicht festgelegt werden',
			'settings.downloadSettings.templateResetToDefault' => 'Auf Standardvorlage zurücksetzen',
			'settings.downloadSettings.functionalTest' => 'Funktionstest',
			'settings.downloadSettings.testInProgress' => 'Test läuft...',
			'settings.downloadSettings.runTest' => 'Test ausführen',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Testen, ob Downloadpfad und Berechtigungskonfiguration ordnungsgemäß funktionieren',
			'settings.downloadSettings.testResults' => 'Testergebnisse',
			'settings.downloadSettings.testCompleted' => 'Test abgeschlossen',
			'settings.downloadSettings.testMultisegmentDomain' => 'Wertebereichsprüfung (mehrere Abschnitte / Überschreitung / Fluchtformen)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Rendern der Mehrabschnitte-Struktur (issue #126)',
			'settings.downloadSettings.testPassed' => 'Elemente bestanden',
			'settings.downloadSettings.testFailed' => 'Test fehlgeschlagen',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Prüfung der Speicherberechtigung',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Speicherberechtigung erteilt',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Speicherberechtigung fehlt, einige Funktionen sind möglicherweise eingeschränkt',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Berechtigungsprüfung fehlgeschlagen',
			'settings.downloadSettings.testDownloadPathValidation' => 'Validierung des Downloadpfads',
			'settings.downloadSettings.testPathValidationFailed' => 'Pfadvalidierung fehlgeschlagen',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Validierung der Dateinamen-Vorlage',
			'settings.downloadSettings.testAllTemplatesValid' => 'Alle Vorlagen sind gültig',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Einige Vorlagen enthalten ungültige Zeichen',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Vorlagenvalidierung fehlgeschlagen',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Test der Verzeichnisvorgänge',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'Verzeichniserstellung und Dateischreiben sind normal',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Verzeichnisvorgang fehlgeschlagen',
			'settings.downloadSettings.testVideoTemplate' => 'Video-Vorlage',
			'settings.downloadSettings.testGalleryTemplate' => 'Galerie-Vorlage',
			'settings.downloadSettings.testImageTemplate' => 'Bild-Vorlage',
			'settings.downloadSettings.testValid' => 'Gültig',
			'settings.downloadSettings.testInvalid' => 'Ungültig',
			'settings.downloadSettings.testSuccess' => 'Erfolg',
			'settings.downloadSettings.testCorrect' => 'Korrekt',
			'settings.downloadSettings.testError' => 'Fehler',
			'settings.downloadSettings.testPath' => 'Testpfad',
			'settings.downloadSettings.testBasePath' => 'Basispfad',
			'settings.downloadSettings.testDirectoryCreation' => 'Verzeichniserstellung',
			'settings.downloadSettings.testFileWriting' => 'Dateischreiben',
			'settings.downloadSettings.testFileContent' => 'Dateiinhalt',
			'settings.downloadSettings.checkingPathStatus' => 'Pfadstatus wird geprüft...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Pfadstatus kann nicht abgerufen werden',
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Hinweis: Der tatsächliche Pfad weicht vom ausgewählten Pfad ab',
			'settings.downloadSettings.grantPermission' => 'Berechtigung erteilen',
			'settings.downloadSettings.fixIssue' => 'Problem beheben',
			'settings.downloadSettings.issueFixed' => 'Problem behoben',
			'settings.downloadSettings.fixFailed' => 'Behebung fehlgeschlagen, bitte manuell bearbeiten',
			'settings.downloadSettings.lackStoragePermission' => 'Fehlende Speicherberechtigung',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Zugriff auf öffentliches Verzeichnis nicht möglich, „Zugriff auf alle Dateien“ erforderlich',
			'settings.downloadSettings.cannotCreateDirectory' => 'Verzeichnis kann nicht erstellt werden',
			'settings.downloadSettings.directoryNotWritable' => 'Verzeichnis nicht beschreibbar',
			'settings.downloadSettings.insufficientSpace' => 'Nicht genügend verfügbarer Speicherplatz',
			'settings.downloadSettings.pathValid' => 'Pfad ist gültig',
			'settings.downloadSettings.validationFailed' => 'Validierung fehlgeschlagen',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Standard-App-Verzeichnis wird verwendet',
			'settings.downloadSettings.appPrivateDirectory' => 'Privates App-Verzeichnis',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Sicher und zuverlässig, keine zusätzlichen Berechtigungen erforderlich',
			'settings.downloadSettings.downloadDirectory' => 'Download-Verzeichnis',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Systemstandard-Speicherort für Downloads, einfach zu verwalten',
			'settings.downloadSettings.moviesDirectory' => 'Filme-Verzeichnis',
			'settings.downloadSettings.moviesDirectoryDesc' => 'System-Filmeverzeichnis, von Medien-Apps erkannt',
			'settings.downloadSettings.documentsDirectory' => 'Dokumentenverzeichnis',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOS-App-Dokumentenverzeichnis',
			'settings.downloadSettings.requiresStoragePermission' => 'Für den Zugriff ist eine Speicherberechtigung erforderlich',
			'settings.downloadSettings.recommendedPaths' => 'Empfohlene Pfade',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Externes privates App-Verzeichnis',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Privates App-Verzeichnis im externen Speicher, für Nutzer zugänglich, mehr Speicherplatz',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Internes privates App-Verzeichnis',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Interner App-Speicher, keine Berechtigungen erforderlich, weniger Speicherplatz',
			'settings.downloadSettings.appDocumentsDirectory' => 'App-Dokumentenverzeichnis',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'App-spezifisches Dokumentenverzeichnis, sicher und zuverlässig',
			'settings.downloadSettings.downloadsFolder' => 'Downloads-Ordner',
			'settings.downloadSettings.downloadsFolderDesc' => 'Systemstandard-Downloadverzeichnis',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Empfohlenen Download-Speicherort auswählen',
			'settings.downloadSettings.noRecommendedPaths' => 'Keine empfohlenen Pfade verfügbar',
			'settings.downloadSettings.recommended' => 'Empfohlen',
			'settings.downloadSettings.requiresPermission' => 'Berechtigung erforderlich',
			'settings.downloadSettings.authorizeAndSelect' => 'Autorisieren und auswählen',
			'settings.downloadSettings.select' => 'Auswählen',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Berechtigungsautorisierung fehlgeschlagen, dieser Pfad kann nicht ausgewählt werden',
			'settings.downloadSettings.pathValidationFailed' => 'Pfadvalidierung fehlgeschlagen',
			'settings.downloadSettings.downloadPathSetTo' => 'Downloadpfad festgelegt auf',
			'settings.downloadSettings.setPathFailed' => 'Pfad konnte nicht festgelegt werden',
			'settings.downloadSettings.variableTitle' => 'Titel',
			'settings.downloadSettings.variableAuthorcache' => 'Erster gesehener Autorenname (stabil bei Umbenennungen)',
			'settings.downloadSettings.variableAuthor' => 'Name des Autors',
			'settings.downloadSettings.variableUsername' => 'Benutzername des Autors',
			'settings.downloadSettings.variableQuality' => 'Videoqualität',
			'settings.downloadSettings.variableFilename' => 'Ursprünglicher Dateiname',
			'settings.downloadSettings.variableId' => 'Inhalts-ID',
			'settings.downloadSettings.variableCount' => 'Anzahl der Galeriebilder',
			'settings.downloadSettings.variableDate' => 'Aktuelles Datum (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'Aktuelle Uhrzeit (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Aktuelles Datum und Uhrzeit (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Download-Einstellungen',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Downloadpfad und Dateibenennungsregeln konfigurieren',
			'settings.downloadSettings.suchAsTitleQuality' => 'Zum Beispiel: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Zum Beispiel: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Zum Beispiel: %title_%filename',
			'settings.downloadSettings.structureSection' => 'Speicherstruktur und Namensgebung',
			'settings.downloadSettings.structureSectionDescription' => 'Heruntergeladene Dateien werden nach der unten gewählten Regel in Unterordner einsortiert. Betrifft nur künftige Downloads; bestehende Dateien bleiben unangetastet.',
			'settings.downloadSettings.structureNoticeTitle' => 'Neu: automatisch nach Autor einsortieren',
			'settings.downloadSettings.structureNoticeBody' => 'Unten auswählen · betrifft nur neue Downloads, bestehende Dateien bleiben unangetastet.',
			'settings.downloadSettings.presetFlat' => 'Flach',
			'settings.downloadSettings.presetFlatDesc' => 'Alle Dateien direkt im Download-Stammordner',
			'settings.downloadSettings.presetAuthor' => 'Nach Autor',
			'settings.downloadSettings.presetAuthorBadge' => 'Empfohlen',
			'settings.downloadSettings.presetAuthorDesc' => 'Ein Ordner pro Autor · Umbenennungen spalten das Archiv nicht',
			'settings.downloadSettings.presetDate' => 'Nach Datum',
			'settings.downloadSettings.presetDateDesc' => 'Nach Download-Datum gruppiert',
			'settings.downloadSettings.presetCustomActive' => 'Aktiv',
			'settings.downloadSettings.structurePreviewLabel' => 'Vorschau',
			'settings.downloadSettings.structurePreviewNote' => 'Farbige Abschnitte sind die Organisationsebenen und folgen der gewählten Regel.',
			'settings.downloadSettings.pathTooLongWarning' => 'Relativer Pfad über 200 Zeichen, das Speichern kann auf manchen Geräten fehlschlagen',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Eigene Pfadvorlage',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Ordnerstruktur und Dateinamen selbst bestimmen',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Pfadvorlage',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Ordnet Downloads automatisch in Unterordner',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Video',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Galerie',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Einzelfoto',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Vorschau · tatsächliches Speicherergebnis nach Bereinigung',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Vorschau · Galerievorlage = Ordnername (interne Bilder tragen die Bild-ID)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Ordnerebene hinzufügen',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Limit der Ordnerebenen erreicht',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, eine Variable oder fester Text',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'z. B. %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'Die Erweiterung .mp4 wird automatisch angehängt · / in einem Abschnitt teilt ihn in zwei Ebenen · maximal ${max} Ebenen',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'Die ursprüngliche Erweiterung wird automatisch angehängt · / in einem Abschnitt teilt ihn in zwei Ebenen · maximal ${max} Ebenen',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'Die Galerievorlage besteht nur aus Ordnern, maximal ${max} Ebenen · interne Bilder tragen die Bild-ID als Namen',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Zum Einfügen an der Cursorposition tippen · lange drücken für Details',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Leerer Abschnitt',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'Speichern nicht möglich: Es gibt leere Abschnitte, bitte ausfüllen oder entfernen',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'Speichern nicht möglich: Zu viele Pfadabschnitte (max. 4). Bitte zusammenführen oder entfernen',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'Speichern nicht möglich: Die Vorlage enthält ungültige Zeichen',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Variable eingefügt',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Gespeichert · betrifft nur künftige Downloads',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Inhalt',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Autor',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Zeit',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Autorenname·fest',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Datum',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Uhrzeit',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Datum & Zeit',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Nr.',
			'favoriteTags.title' => 'Favorisierte Tags',
			'favoriteTags.emptyIwara' => 'Noch keine favorisierten Iwara-Tags',
			'favoriteTags.emptyOreno3d' => 'Noch keine Favoriten',
			'favoriteTags.addIwaraTag' => 'Iwara-Tag hinzufügen',
			'favoriteTags.quickPickHint' => 'Favorisierte Elemente erscheinen als Schnellauswahl in der Suche.',
			'favoriteTags.pickerTitle' => 'Oreno3D auswählen',
			'favoriteTags.searchHint' => 'Nach Name oder Original suchen',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('de'))(n, one: '${n} Werk', other: '${n} Werke', ), 
			'favoriteTags.browseEntry' => 'Nach Herkunft / Charakter / Tag durchsuchen',
			'favoriteTags.favoritesSection' => 'Favoriten',
			'favoriteTags.addFavorite' => 'Hinzufügen',
			'favoriteTags.iwaraTitle' => 'Favorisierte Iwara-Tags',
			'favoriteTags.oreno3dTitle' => 'Favorisierte Oreno3D-Tags',
			'favoriteTags.changeTag' => 'Tag ändern',
			'favoriteTags.switchToText' => 'Textsuche',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Tags',
			'oreno3d.characters' => 'Charaktere',
			'oreno3d.origin' => 'Herkunft',
			'oreno3d.thirdPartyTagsExplanation' => 'Die hier angezeigten Informationen zu **Tags**, **Charakteren** und **Herkunft** stammen von der Drittanbieter-Seite **Oreno3D** und dienen nur als Referenz.\n\nDa diese Informationsquelle nur auf Japanisch verfügbar ist, fehlt derzeit eine Internationalisierungsanpassung.\n\nWenn Sie zur Internationalisierung beitragen möchten, besuchen Sie bitte das Repository, um es zu verbessern!',
			'oreno3d.sortTypes.hot' => 'Angesagt',
			'oreno3d.sortTypes.favorites' => 'Favoriten',
			'oreno3d.sortTypes.latest' => 'Neueste',
			'oreno3d.sortTypes.popularity' => 'Beliebtheit',
			'oreno3d.errors.requestFailed' => 'Anfrage fehlgeschlagen, Statuscode',
			'oreno3d.errors.connectionTimeout' => 'Verbindungszeitüberschreitung, bitte prüfen Sie die Netzwerkverbindung',
			'oreno3d.errors.sendTimeout' => 'Zeitüberschreitung beim Senden der Anfrage',
			'oreno3d.errors.receiveTimeout' => 'Zeitüberschreitung beim Empfangen der Antwort',
			'oreno3d.errors.badCertificate' => 'Zertifikatsüberprüfung fehlgeschlagen',
			'oreno3d.errors.resourceNotFound' => 'Angeforderte Ressource nicht gefunden',
			'oreno3d.errors.accessDenied' => 'Zugriff verweigert, ggf. sind Anmeldung oder Berechtigung erforderlich',
			'oreno3d.errors.serverError' => 'Interner Serverfehler',
			'oreno3d.errors.serviceUnavailable' => 'Dienst vorübergehend nicht verfügbar',
			'oreno3d.errors.requestCancelled' => 'Anfrage abgebrochen',
			'oreno3d.errors.connectionError' => 'Netzwerkverbindungsfehler, bitte prüfen Sie die Netzwerkeinstellungen',
			'oreno3d.errors.networkRequestFailed' => 'Netzwerkanfrage fehlgeschlagen',
			'oreno3d.errors.searchVideoError' => 'Unbekannter Fehler bei der Videosuche',
			'oreno3d.errors.getPopularVideoError' => 'Unbekannter Fehler beim Abrufen beliebter Videos',
			'oreno3d.errors.getVideoDetailError' => 'Unbekannter Fehler beim Abrufen der Videodetails',
			'oreno3d.errors.parseVideoDetailError' => 'Unbekannter Fehler beim Abrufen und Verarbeiten der Videodetails',
			'oreno3d.errors.downloadFileError' => 'Unbekannter Fehler beim Herunterladen der Datei',
			'oreno3d.loading.gettingVideoInfo' => 'Videoinformationen werden abgerufen...',
			'oreno3d.loading.cancel' => 'Abbrechen',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Video nicht gefunden oder gelöscht',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Wiedergabelink konnte nicht abgerufen werden',
			'oreno3d.messages.getVideoDetailFailed' => 'Videodetails konnten nicht abgerufen werden',
			'signIn.pleaseLoginFirst' => 'Bitte melden Sie sich zuerst an',
			'signIn.alreadySignedInToday' => 'Sie haben sich heute bereits angemeldet!',
			'signIn.youDidNotStickToTheSignIn' => 'Sie haben die Anmeldung nicht durchgehalten.',
			'signIn.signInSuccess' => 'Erfolgreich angemeldet!',
			'signIn.signInFailed' => 'Anmeldung fehlgeschlagen, bitte später erneut versuchen',
			'signIn.consecutiveSignIns' => 'Aufeinanderfolgende Anmeldungen',
			'signIn.failureReason' => 'Fehlergrund',
			'signIn.selectDateRange' => 'Datumsbereich auswählen',
			'signIn.startDate' => 'Startdatum',
			'signIn.endDate' => 'Enddatum',
			'signIn.invalidDate' => 'Ungültiges Datum',
			'signIn.invalidDateRange' => 'Ungültiger Datumsbereich',
			'signIn.errorFormatText' => 'Datumsformatfehler',
			'signIn.errorInvalidText' => 'Ungültiger Datumsbereich',
			'signIn.errorInvalidRangeText' => 'Ungültiger Datumsbereich',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'Der Datumsbereich darf nicht mehr als ein Jahr betragen',
			'signIn.signIn' => 'Anmelden',
			'signIn.signInRecord' => 'Anmeldeverlauf',
			'signIn.totalSignIns' => 'Anmeldungen insgesamt',
			'signIn.pleaseSelectSignInStatus' => 'Bitte wählen Sie den Anmeldestatus',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Bitte melden Sie sich zuerst an, um Ihre Abonnements anzusehen.',
			'subscriptions.selectUser' => 'Nutzer auswählen',
			'subscriptions.noSubscribedUsers' => 'Keine abonnierten Nutzer',
			'subscriptions.showAllSubscribedUsersContent' => 'Inhalte aller abonnierten Nutzer anzeigen',
			'videoDetail.pipMode' => 'PiP-Modus',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Von der letzten Position fortsetzen: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Fortgesetzt ab ${position}',
			'videoDetail.restartFromBeginning' => 'Von vorne beginnen',
			'videoDetail.dismissResumeTip' => 'Ausblenden',
			'videoDetail.localInfo.videoInfo' => 'Videoinfo',
			'videoDetail.localInfo.currentQuality' => 'Aktuelle Qualität',
			'videoDetail.localInfo.duration' => 'Dauer',
			'videoDetail.localInfo.resolution' => 'Auflösung',
			'videoDetail.localInfo.fileInfo' => 'Dateiinfo',
			'videoDetail.localInfo.fileName' => 'Dateiname',
			'videoDetail.localInfo.fileSize' => 'Dateigröße',
			'videoDetail.localInfo.filePath' => 'Dateipfad',
			'videoDetail.localInfo.copyPath' => 'Pfad kopieren',
			'videoDetail.localInfo.openFolder' => 'Ordner öffnen',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Pfad in die Zwischenablage kopiert',
			'videoDetail.localInfo.openFolderFailed' => 'Ordner konnte nicht geöffnet werden',
			'videoDetail.videoIdIsEmpty' => 'Video-ID ist leer',
			'videoDetail.videoInfoIsEmpty' => 'Videoinformationen sind leer',
			'videoDetail.thisIsAPrivateVideo' => 'Dies ist ein privates Video',
			'videoDetail.getVideoInfoFailed' => 'Videoinformationen konnten nicht abgerufen werden, bitte später erneut versuchen',
			'videoDetail.noVideoSourceFound' => 'Keine Videoquelle gefunden',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Tag „${tagId}“ in die Zwischenablage kopiert',
			'videoDetail.errorLoadingVideo' => 'Fehler beim Laden des Videos',
			'videoDetail.play' => 'Wiedergabe',
			'videoDetail.pause' => 'Pause',
			'videoDetail.exitAppFullscreen' => 'App-Vollbild beenden',
			'videoDetail.enterAppFullscreen' => 'App-Vollbild aktivieren',
			'videoDetail.exitSystemFullscreen' => 'System-Vollbild beenden',
			'videoDetail.enterSystemFullscreen' => 'System-Vollbild aktivieren',
			'videoDetail.seekTo' => 'Springen zu',
			'videoDetail.switchResolution' => 'Auflösung wechseln',
			'videoDetail.switchPlaybackSpeed' => 'Wiedergabegeschwindigkeit wechseln',
			'videoDetail.rewindSeconds' => ({required Object num}) => '${num} Sekunden zurückspulen',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => '${num} Sekunden vorspulen',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Wiedergabe mit ${rate}x Geschwindigkeit',
			'videoDetail.brightness' => 'Helligkeit',
			'videoDetail.brightnessLowest' => 'Helligkeit ist am niedrigsten',
			'videoDetail.volume' => 'Lautstärke',
			'videoDetail.volumeMuted' => 'Lautstärke ist stummgeschaltet',
			'videoDetail.restoreDefaultZoom' => 'Wiederherstellen',
			'videoDetail.gestureGuide.sampleVideo' => 'Beispielvideo',
			'videoDetail.gestureGuide.title' => 'Anleitung für Gesten & Interaktion',
			'videoDetail.gestureGuide.viewGuide' => 'Anleitung für Gesten & Interaktion',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Nehmen Sie sich ein paar Sekunden Zeit, um die Player-Gesten kennenzulernen. Sie können diese Anleitung jederzeit in den Player-Einstellungen erneut öffnen.',
			'videoDetail.gestureGuide.startWatching' => 'Verstanden, Wiedergabe starten',
			'videoDetail.gestureGuide.basicTitle' => 'Grundlegende Steuerung',
			'videoDetail.gestureGuide.zoomTitle' => 'Zoom / Drehen / Verschieben',
			'videoDetail.gestureGuide.restoreTip' => 'Tippen Sie unten rechts auf die Schaltfläche „Wiederherstellen“, um Zoom, Drehung und Position zurückzusetzen.',
			'videoDetail.gestureGuide.mTap' => 'Einmaliges Tippen: Steuerelemente ein-/ausblenden',
			'videoDetail.gestureGuide.mDoubleTap' => 'Doppeltippen: zurückspulen (links) / Pause (Mitte) / vorspulen (rechts)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Horizontales Wischen: spulen',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Vertikales Wischen: Helligkeit (links) / Lautstärke (rechts)',
			'videoDetail.gestureGuide.mLongPress' => 'Langdruck: vorübergehende Beschleunigung',
			'videoDetail.gestureGuide.mPinch' => 'Zusammenziehen mit zwei Fingern: das Bild vergrößern',
			'videoDetail.gestureGuide.mRotate' => 'Drehen mit zwei Fingern: das Bild drehen',
			'videoDetail.gestureGuide.dTap' => 'Klick: Steuerelemente ein-/ausblenden',
			'videoDetail.gestureGuide.dDoubleTap' => 'Doppelklick: zurückspulen (links) / Pause (Mitte) / vorspulen (rechts)',
			'videoDetail.gestureGuide.dKeys' => 'Spultasten: tippen zum Zurück-/Vorspringen, halten zum Beschleunigen; Geschwindigkeitstasten: die Wiedergabegeschwindigkeit während der normalen Wiedergabe stufenweise ändern; Leertaste: Wiedergabe / Pause',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Trackpad-Zusammenziehen: das Bild vergrößern',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Trackpad-Drehen: das Bild drehen',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Strg + Mausrad: um den Cursor zoomen',
			'videoDetail.gestureGuide.dShiftWheel' => 'Umschalt + Mausrad: um den Cursor drehen',
			'videoDetail.gestureGuide.quest.title' => 'In Quest zurechtkommen',
			'videoDetail.gestureGuide.quest.intro' => 'Sehen Sie, welche Steuerung was bewirkt, und probieren Sie es dann in Ihrem Raum aus.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Räumliches Video',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Räumliche Galerie',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Für Bildschirme und Fenster in Ihrem Quest-Raum. Jederzeit in den Player-Einstellungen erneut öffnen.',
			'videoDetail.gestureGuide.quest.catalog' => 'Die Steuerelemente erkunden',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} von ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Zurück',
			'videoDetail.gestureGuide.quest.next' => 'Nächste Steuerung',
			'videoDetail.gestureGuide.quest.replay' => 'Demo erneut abspielen',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Demo pausieren',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Demo fortsetzen',
			'videoDetail.gestureGuide.quest.looping' => 'Steuerungsdemo',
			'videoDetail.gestureGuide.quest.still' => 'Stehende Illustration',
			'videoDetail.gestureGuide.quest.done' => 'Verstanden, weiter',
			'videoDetail.gestureGuide.quest.leftController' => 'Linke Hand',
			'videoDetail.gestureGuide.quest.rightController' => 'Rechte Hand',
			'videoDetail.gestureGuide.quest.trigger' => 'Zeigefinger-Auslöser',
			'videoDetail.gestureGuide.quest.grip' => 'Greiftaste',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Beide Greiftasten',
			'videoDetail.gestureGuide.quest.stick' => 'Daumenstick',
			'videoDetail.gestureGuide.quest.handTracking' => 'Handverfolgung',
			'videoDetail.gestureGuide.quest.ready' => 'Bereit',
			'videoDetail.gestureGuide.quest.press' => 'Drücken',
			'videoDetail.gestureGuide.quest.hold' => 'Halten',
			'videoDetail.gestureGuide.quest.release' => 'Loslassen',
			'videoDetail.gestureGuide.quest.result' => 'Das Ergebnis sehen',
			'videoDetail.gestureGuide.quest.pinch' => 'Kneifen',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Zeigen und auswählen',
			'videoDetail.gestureGuide.quest.selectBody' => 'Richten Sie den Strahl auf eine Schaltfläche und drücken und lassen Sie dann den Zeigefinger-Auslöser los. Verwenden Sie ihn für Wiedergabe, Einstellungen und Schieberegler im Bedienfeld.',
			'videoDetail.gestureGuide.quest.selectHint' => 'Der Zeigefinger-Auslöser befindet sich hinter der Schaltflächenvorderseite. Die Greiftaste am inneren Griff greift Fenster.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Das Bedienfeld ein- oder ausblenden',
			'videoDetail.gestureGuide.quest.panelBody' => 'Zeigen Sie außerhalb des Bedienfelds und tippen Sie dann auf den Zeigefinger-Auslöser, um es ein- oder auszublenden. Mit Handverfolgung bewirkt ein kurzes Kneifen außerhalb des Bedienfelds dasselbe.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Verwenden Sie ein kurzes Tippen ohne Ziehen. Halten und Bewegen ist ein Ziehen, kein Umschalten des Bedienfelds.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Abspielen und pausieren',
			'videoDetail.gestureGuide.quest.playBody' => 'Zeigen Sie weg vom Bedienfeld und drücken Sie A rechts oder X links, um abzuspielen oder zu pausieren. Sie können auch die Wiedergabetaste im Bedienfeld auswählen.',
			'videoDetail.gestureGuide.quest.playHint' => 'Dieses Standard-Tastenkürzel kann in den Einstellungen des räumlichen Players deaktiviert werden. Wenn Sie auf das Bedienfeld zeigen, gehen Eingaben an das Bedienfeld.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Mit dem Stick spulen',
			'videoDetail.gestureGuide.quest.seekBody' => 'Bewegen Sie einen der Sticks leicht nach links oder rechts für einen 5-Sekunden-Schritt. Halten Sie ihn, um schneller zu spulen, während die Zielzeit als Vorschau angezeigt wird. Lassen Sie los, um das Spulen zu übernehmen.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Halten Sie den Strahl dieses Controllers vom Bedienfeld fern. Ein Stick, der auf das Bedienfeld zeigt, scrollt stattdessen das Bedienfeld.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Mit dem Stick blättern',
			'videoDetail.gestureGuide.quest.browseBody' => 'Bewegen Sie einen der Sticks nach links oder rechts für das vorherige oder nächste Element; halten, um weiterzublättern. Sie können auch ein Miniaturbild im Filmstreifen auswählen.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Videos in einer Galerie sind ebenfalls Elemente. Wenn Sie auf das Bedienfeld zeigen, scrollt der Stick das Bedienfeld.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Zum Umblättern quer ziehen',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Zielen Sie auf das Bild, halten Sie den Zeigefinger-Auslöser und ziehen Sie nach links. Lassen Sie nach dem Umblätter-Signal los, um weiterzublättern; ziehen Sie nach rechts, um zurückzugehen. Kneifen und Ziehen funktioniert ebenfalls.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Bilder müssen bei 1× sein, um durch Ziehen umzublättern. Galerie-Videos unterstützen dies ebenfalls. Die Bühne bleibt stehen, bis Sie loslassen.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'In das Bild hineinzoomen',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Zielen Sie auf ein Detail im Bild, halten Sie den Zeigefinger-Auslöser und schieben Sie dann den Stick nach oben, um hineinzuzoomen, oder nach unten, um herauszuzoomen. Der Zoom ist dort verankert, wo Sie gedrückt haben.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Dadurch wird das Bild innerhalb seines Fensters vergrößert. Ohne Halten des Bildes passt Auf/Ab den Betrachtungsabstand an.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Das Bild verschieben und wiederherstellen',
			'videoDetail.gestureGuide.quest.panBody' => 'Sobald Sie hineingezoomt haben, halten Sie den Zeigefinger-Auslöser und ziehen Sie, um sich umzusehen. Doppeltippen Sie auf das Bild, um auf 2,5× zu zoomen oder es wiederherzustellen. Mit Händen zweimal schnell kneifen.',
			'videoDetail.gestureGuide.quest.panHint' => 'Durch Ziehen wird ein gezoomtes Bild verschoben. Stellen Sie vor dem Ziehen zum Umblättern auf 1× zurück.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Eine Diashow starten',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'Bei einem Bild startet oder pausiert A / X die Diashow. Das Bedienfeld bietet Intervalle von 3, 5, 10 oder 20 Sekunden sowie Standard- oder Original-Bildqualität.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'Bei einem Galerie-Video steuert A / X die Wiedergabe dieses Videos. Das Controller-Tastenkürzel muss in den Einstellungen aktiviert sein.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Den Bildschirm greifen und bewegen',
			'videoDetail.gestureGuide.quest.moveBody' => 'Halten Sie die Greiftaste am inneren Griff, bewegen Sie den Controller, um den Bildschirm zu positionieren, und lassen Sie dann los. Beim Zuschauen können Sie den Bildschirm greifen, ohne darauf zu zeigen.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Wenn Sie auf das App-Fenster oder das Bedienfeld zeigen, wird zuerst dieses Fenster gegriffen. Bei Panoramavideos passt das Greifen die Ausrichtung an.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Mit beiden Händen skalieren',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Halten Sie beide Greiftasten. Spreizen Sie die Hände, um den Bildschirm zu vergrößern, oder führen Sie sie zusammen, um ihn zu verkleinern. Bei der Handverfolgung halten Sie mit beiden Händen ein Kneifen.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Für flache oder gewölbte Bildschirme, einschließlich der Galerie-Bühne. Halten Sie die Strahlen vom Bedienfeld fern. Dadurch wird der gesamte Bildschirm skaliert.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Betrachtungsabstand anpassen',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Schieben Sie den Stick nach oben, um den Bildschirm zu entfernen, oder nach unten, um ihn näher zu bringen. Während Sie ein Fenster greifen, bewegt Auf/Ab dieses Fenster. Die Lautstärke stellen Sie im Bedienfeld ein.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Zeigen Sie weg vom Bedienfeld. Beim Halten eines Bildes wird Auf/Ab zur Bildvergrößerung; Panoramavideos passen stattdessen die Ansicht an.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Ränder und Ecken verwenden',
			'videoDetail.gestureGuide.quest.resizeBody' => 'Der Rahmen leuchtet auf, wenn sich Ihr Strahl einem Rand nähert. Halten Sie den Auslöser oder kneifen Sie an einem Rand, um das Fenster zu verschieben; ziehen Sie an einer Ecke, um die Größe zu ändern.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Funktioniert am App-Fenster, am Bedienfeld und am Bildschirm. Das App-Fenster ändert Breite und Höhe; Bildschirme behalten ihr Seitenverhältnis.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Zurückgehen und Einstellungen öffnen',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y geht eine Ebene zurück: ein Popup schließen oder zum Start des Bedienfelds zurückkehren, das Bedienfeld ausblenden und dann zur App zurückkehren. Die linke Menü-Taste öffnet die räumlichen Einstellungen.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'Die rechte Meta-Taste gehört zum System. Das System-Recenter bringt die Ansicht wieder nach vorne, wobei Bildschirmgröße und -abstand erhalten bleiben.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Hände verwenden',
			'videoDetail.gestureGuide.quest.handsBody' => 'Wenn die Handverfolgung aktiviert ist, richten Sie den Systemstrahl auf eine Schaltfläche, kneifen Sie Daumen und Zeigefinger zusammen und lassen Sie dann los. Verwenden Sie das Bedienfeld für Wiedergabe, Spulen und Galerie-Navigation.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Kneifen Sie außerhalb, um das Bedienfeld umzuschalten. Kneifen Sie an einem Rand, um es zu verschieben, an einer Ecke, um die Größe zu ändern, oder mit beiden Händen und spreizen Sie, um den Bildschirm zu vergrößern.',
			'videoDetail.home' => 'Startseite',
			'videoDetail.videoPlayer' => 'Videoplayer',
			'videoDetail.videoPlayerInfo' => 'Videoplayer-Info',
			'videoDetail.moreSettings' => 'Weitere Einstellungen',
			'videoDetail.videoPlayerFeatureInfo' => 'Funktionsinfo zum Videoplayer',
			'videoDetail.autoRewind' => 'Automatisches Zurückspulen',
			'videoDetail.rewindAndFastForward' => 'Zurückspulen und Vorspulen',
			'videoDetail.volumeAndBrightness' => 'Lautstärke und Helligkeit',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Pause oder Wiedergabe bei Doppeltipp im mittleren Bereich',
			'videoDetail.showVerticalVideoInFullScreen' => 'Vertikales Video im Vollbild anzeigen',
			'videoDetail.keepLastVolumeAndBrightness' => 'Letzte Lautstärke und Helligkeit beibehalten',
			'videoDetail.setProxy' => 'Proxy festlegen',
			'videoDetail.moreFeaturesToBeDiscovered' => 'Weitere Funktionen zu entdecken...',
			'videoDetail.videoPlayerSettings' => 'Videoplayer-Einstellungen',
			'videoDetail.commentCount' => ({required Object num}) => '${num} Kommentare',
			'videoDetail.writeYourCommentHere' => 'Schreiben Sie hier Ihren Kommentar...',
			'videoDetail.authorOtherVideos' => 'Weitere Videos des Autors',
			'videoDetail.relatedVideos' => 'Ähnliche Videos',
			'videoDetail.privateVideo' => 'Dies ist ein privates Video',
			'videoDetail.externalVideo' => 'Dies ist ein externes Video',
			'videoDetail.openInBrowser' => 'Im Browser öffnen',
			'videoDetail.resourceDeleted' => 'Dieses Video wurde offenbar gelöscht :/',
			'videoDetail.noDownloadUrl' => 'Keine Download-URL',
			'videoDetail.startDownloading' => 'Download starten',
			'videoDetail.downloadFailed' => 'Download fehlgeschlagen, bitte später erneut versuchen',
			'videoDetail.downloadSuccess' => 'Download erfolgreich',
			'videoDetail.download' => 'Herunterladen',
			'videoDetail.downloadManager' => 'Download-Manager',
			'videoDetail.resourceNotFound' => 'Ressource nicht gefunden',
			'videoDetail.videoLoadError' => 'Fehler beim Laden des Videos',
			'videoDetail.authorNoOtherVideos' => 'Autor hat keine weiteren Videos',
			'videoDetail.noRelatedVideos' => 'Keine ähnlichen Videos',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Fehler beim Laden der Videoquelle',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Fehler beim Einrichten der Listener',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Serverfehler erkannt, Route automatisch gewechselt und erneuter Versuch',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Videoinformationen werden abgerufen...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Videoquellen werden abgerufen...',
			'videoDetail.skeleton.loadingVideo' => 'Video wird geladen...',
			'videoDetail.skeleton.applyingSolution' => 'Lösung wird angewendet...',
			'videoDetail.skeleton.addingListeners' => 'Listener werden hinzugefügt...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Videodauer erfolgreich abgerufen, Video wird geladen...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Laden abgeschlossen',
			'videoDetail.cast.dlnaCast' => 'Übertragen',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Suche nach Übertragungsgeräten konnte nicht gestartet werden: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Übertragung an ${deviceName} starten',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Übertragen fehlgeschlagen: ${error}\nBitte suchen Sie erneut nach Geräten oder wechseln Sie das Netzwerk',
			'videoDetail.cast.castStopped' => 'Übertragung beendet',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Mediaplayer',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Medienserver',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Router',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Einfaches Gerät',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Smartes Licht',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'WLAN-Zugangspunkt',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'WLAN-Verbindungsgerät',
			'videoDetail.cast.deviceTypes.printer' => 'Drucker',
			'videoDetail.cast.deviceTypes.scanner' => 'Scanner',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Digitale Überwachungskamera',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Unbekanntes Gerät',
			'videoDetail.cast.currentPlatformNotSupported' => 'Die aktuelle Plattform unterstützt keine Übertragung',
			'videoDetail.cast.unableToGetVideoUrl' => 'Video-URL konnte nicht abgerufen werden, bitte später erneut versuchen',
			'videoDetail.cast.stopCasting' => 'Übertragung beenden',
			'videoDetail.cast.dlnaCastSheet.title' => 'Remote-Übertragung',
			'videoDetail.cast.dlnaCastSheet.close' => 'Schließen',
			_ => null,
		} ?? switch (path) {
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Geräte werden gesucht...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Klicken Sie auf die Suchschaltfläche, um erneut nach Übertragungsgeräten zu suchen',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Suche läuft',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Erneut suchen',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'Keine Übertragungsgeräte gefunden\nBitte stellen Sie sicher, dass sich die Geräte im selben Netzwerk befinden',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Geräte werden gesucht, bitte warten...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Übertragen',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Verbunden mit: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Kein Gerät verbunden',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Übertragung beenden',
			'videoDetail.likeAvatars.dialogTitle' => 'Wer heimlich liked',
			'videoDetail.likeAvatars.dialogDescription' => 'Neugierig, wer sie sind? Blättern Sie durch dieses „Like-Album“~',
			'videoDetail.likeAvatars.closeTooltip' => 'Schließen',
			'videoDetail.likeAvatars.retry' => 'Erneut versuchen',
			'videoDetail.likeAvatars.noLikesYet' => 'Hier ist noch niemand aufgetaucht. Seien Sie der Erste!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Seite ${page} / ${totalPages} · Insgesamt ${totalCount} Personen',
			'videoDetail.likeAvatars.prevPage' => 'Vorherige Seite',
			'videoDetail.likeAvatars.nextPage' => 'Nächste Seite',
			'share.sharePlayList' => 'Wiedergabeliste teilen',
			'share.wowDidYouSeeThis' => 'Wow, haben Sie das gesehen?',
			'share.nameIs' => 'Name ist',
			'share.clickLinkToView' => 'Zum Ansehen auf den Link klicken',
			'share.iReallyLikeThis' => 'Das gefällt mir sehr',
			'share.shareFailed' => 'Teilen fehlgeschlagen, bitte später erneut versuchen',
			'share.share' => 'Teilen',
			'share.shareAsImage' => 'Als Bild teilen',
			'share.shareAsText' => 'Als Text teilen',
			'share.shareAsImageDesc' => 'Das Videocover als Bild teilen',
			'share.shareAsTextDesc' => 'Die Videodetails als Text teilen',
			'share.shareAsImageFailed' => 'Teilen des Videocovers als Bild fehlgeschlagen, bitte später erneut versuchen',
			'share.shareAsTextFailed' => 'Teilen der Videodetails als Text fehlgeschlagen, bitte später erneut versuchen',
			'share.shareVideo' => 'Video teilen',
			'share.authorIs' => 'Autor ist',
			'share.shareGallery' => 'Galerie teilen',
			'share.galleryTitleIs' => 'Titel der Galerie ist',
			'share.galleryAuthorIs' => 'Autor der Galerie ist',
			'share.shareUser' => 'Nutzer teilen',
			'share.userNameIs' => 'Benutzername ist',
			'share.userAuthorIs' => 'Autor des Nutzers ist',
			'share.comments' => 'Kommentare',
			'share.shareThread' => 'Thread teilen',
			'share.views' => 'Aufrufe',
			'share.sharePost' => 'Beitrag teilen',
			'share.postTitleIs' => 'Titel des Beitrags ist',
			'share.postAuthorIs' => 'Autor des Beitrags ist',
			'markdown.markdownSyntax' => 'Markdown-Syntax',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara-spezifische Markdown-Syntax',
			'markdown.internalLink' => 'Interner Link',
			'markdown.supportAutoConvertLinkBelow' => 'Automatische Umwandlung der folgenden Links wird unterstützt:',
			'markdown.convertLinkExample' => '🎬 Videolink\n🖼️ Bildlink\n👤 Benutzerlink\n📌 Forum-Link\n🎵 Playlist-Link\n💬 Themenlink',
			'markdown.mentionUser' => 'Benutzer erwähnen',
			'markdown.mentionUserDescription' => 'Geben Sie @ gefolgt vom Benutzernamen ein; dies wird automatisch in einen Benutzerlink umgewandelt',
			'markdown.markdownBasicSyntax' => 'Markdown-Grundsyntax',
			'markdown.paragraphAndLineBreak' => 'Absatz und Zeilenumbruch',
			'markdown.paragraphAndLineBreakDescription' => 'Absätze werden durch eine Leerzeile getrennt, und zwei Leerzeichen am Zeilenende werden in einen Zeilenumbruch umgewandelt',
			'markdown.paragraphAndLineBreakSyntax' => 'Dies ist der erste Absatz\n\nDies ist der zweite Absatz\nDiese Zeile endet mit zwei Leerzeichen  \nwird in einen Zeilenumbruch umgewandelt',
			'markdown.textStyle' => 'Textstil',
			'markdown.textStyleDescription' => 'Umgeben Sie Text mit speziellen Symbolen, um den Stil zu ändern',
			'markdown.textStyleSyntax' => '**Fetter Text**\n*Kursiver Text*\n~~Durchgestrichener Text~~\n`Code-Text`',
			'markdown.quote' => 'Zitat',
			'markdown.quoteDescription' => 'Verwenden Sie das Symbol >, um ein Zitat zu erstellen, mehrere > für ein mehrstufiges Zitat',
			'markdown.quoteSyntax' => '> Dies ist ein Zitat der ersten Ebene\n>> Dies ist ein Zitat der zweiten Ebene',
			'markdown.list' => 'Liste',
			'markdown.listDescription' => 'Erstellen Sie eine geordnete Liste mit Zahl+Punkt und eine ungeordnete Liste mit -',
			'markdown.listSyntax' => '1. Erstes Element\n2. Zweites Element\n\n- Ungeordnetes Element\n  - Unterelement\n  - Weiteres Unterelement',
			'markdown.linkAndImage' => 'Link und Bild',
			'markdown.linkAndImageDescription' => 'Link-Format: [Text](URL)\nBild-Format: ![Beschreibung](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[Linktext](${link})\n![Bildbeschreibung](${imgUrl})',
			'markdown.title' => 'Titel',
			'markdown.titleDescription' => 'Verwenden Sie das Symbol #, um einen Titel zu erstellen, die Anzahl zeigt die Ebene an',
			'markdown.titleSyntax' => '# Titel der ersten Ebene\n## Titel der zweiten Ebene\n### Titel der dritten Ebene',
			'markdown.separator' => 'Trennlinie',
			'markdown.separatorDescription' => 'Erstellen Sie eine Trennlinie mit drei oder mehr -Symbolen',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Syntax',
			'forum.attachQuote' => 'Zitat anhängen',
			'forum.replyToFloor' => ({required Object floor, required Object username}) => 'Antwort auf #${floor} @${username}',
			'forum.removeQuote' => 'Zitat entfernen',
			'forum.recent' => 'Neueste',
			'forum.category' => 'Kategorie',
			'forum.lastReply' => 'Letzte Antwort',
			'forum.sitewide.badge' => 'Websiteweit',
			'forum.sitewide.title' => 'Websiteweite Ankündigung',
			'forum.sitewide.readMore' => 'Mehr lesen',
			'forum.errors.pleaseSelectCategory' => 'Bitte eine Kategorie auswählen',
			'forum.errors.threadLocked' => 'Dieses Thema ist gesperrt, Antwort nicht möglich',
			'forum.createPost' => 'Beitrag erstellen',
			'forum.title' => 'Titel',
			'forum.enterTitle' => 'Titel eingeben',
			'forum.content' => 'Inhalt',
			'forum.enterContent' => 'Inhalt eingeben',
			'forum.writeYourContentHere' => 'Schreiben Sie hier Ihren Inhalt…',
			'forum.posts' => 'Beiträge',
			'forum.threads' => 'Themen',
			'forum.forum' => 'Forum',
			'forum.createThread' => 'Thema erstellen',
			'forum.selectCategory' => 'Kategorie auswählen',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Verbleibende Sperrzeit ${minutes} Minuten ${seconds} Sekunden',
			'forum.groups.administration' => 'Verwaltung',
			'forum.groups.global' => 'Global',
			'forum.groups.chinese' => 'Chinesisch',
			'forum.groups.japanese' => 'Japanisch',
			'forum.groups.korean' => 'Koreanisch',
			'forum.groups.other' => 'Sonstiges',
			'forum.leafNames.announcements' => 'Ankündigungen',
			'forum.leafNames.feedback' => 'Feedback',
			'forum.leafNames.support' => 'Support',
			'forum.leafNames.general' => 'Allgemein',
			'forum.leafNames.guides' => 'Anleitungen',
			'forum.leafNames.questions' => 'Fragen',
			'forum.leafNames.requests' => 'Wünsche',
			'forum.leafNames.sharing' => 'Teilen',
			'forum.leafNames.general_zh' => 'Allgemein',
			'forum.leafNames.questions_zh' => 'Fragen',
			'forum.leafNames.requests_zh' => 'Wünsche',
			'forum.leafNames.support_zh' => 'Support',
			'forum.leafNames.general_ja' => 'Allgemein',
			'forum.leafNames.questions_ja' => 'Fragen',
			'forum.leafNames.requests_ja' => 'Wünsche',
			'forum.leafNames.support_ja' => 'Support',
			'forum.leafNames.korean' => 'Koreanisch',
			'forum.leafNames.other' => 'Sonstiges',
			'forum.leafDescriptions.announcements' => 'Offizielle wichtige Mitteilungen und Ankündigungen',
			'forum.leafDescriptions.feedback' => 'Feedback zu den Funktionen und Diensten der Website',
			'forum.leafDescriptions.support' => 'Hilfe bei der Behebung websitebezogener Probleme',
			'forum.leafDescriptions.general' => 'Über jedes Thema diskutieren',
			'forum.leafDescriptions.guides' => 'Teilen Sie Ihre Erfahrungen und Anleitungen',
			'forum.leafDescriptions.questions' => 'Stellen Sie Ihre Fragen',
			'forum.leafDescriptions.requests' => 'Veröffentlichen Sie Ihre Wünsche',
			'forum.leafDescriptions.sharing' => 'Teilen Sie interessante Inhalte',
			'forum.leafDescriptions.general_zh' => 'Über jedes Thema diskutieren',
			'forum.leafDescriptions.questions_zh' => 'Stellen Sie Ihre Fragen',
			'forum.leafDescriptions.requests_zh' => 'Veröffentlichen Sie Ihre Wünsche',
			'forum.leafDescriptions.support_zh' => 'Hilfe bei der Behebung websitebezogener Probleme',
			'forum.leafDescriptions.general_ja' => 'Über jedes Thema diskutieren',
			'forum.leafDescriptions.questions_ja' => 'Stellen Sie Ihre Fragen',
			'forum.leafDescriptions.requests_ja' => 'Veröffentlichen Sie Ihre Wünsche',
			'forum.leafDescriptions.support_ja' => 'Hilfe bei der Behebung websitebezogener Probleme',
			'forum.leafDescriptions.korean' => 'Diskussionen rund um Koreanisch',
			'forum.leafDescriptions.other' => 'Sonstige nicht klassifizierte Inhalte',
			'forum.reply' => 'Antworten',
			'forum.pendingReview' => 'Ausstehende Prüfung',
			'forum.floorNotFound' => 'Dieser Beitrag existiert nicht mehr',
			'forum.floorNotLoadedYet' => 'Dieser Beitrag liegt weiter oben — lade mehr Antworten, um dorthin zu springen',
			'forum.editedAt' => 'Bearbeitet am',
			'forum.copySuccess' => 'In die Zwischenablage kopiert',
			'forum.copySuccessForMessage' => ({required Object str}) => 'In die Zwischenablage kopiert: ${str}',
			'forum.editReply' => 'Antwort bearbeiten',
			'forum.editTitle' => 'Titel bearbeiten',
			'forum.submit' => 'Absenden',
			'notifications.errors.unsupportedNotificationType' => 'Nicht unterstützter Benachrichtigungstyp',
			'notifications.errors.unknownUser' => 'Unbekannter Benutzer',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Nicht unterstützter Benachrichtigungstyp: ${type}',
			'notifications.errors.unknownNotificationType' => 'Unbekannter Benachrichtigungstyp',
			'notifications.notifications' => 'Benachrichtigungen',
			'notifications.profile' => 'Profil',
			'notifications.postedNewComment' => 'Neuer Kommentar veröffentlicht',
			'notifications.inYour' => 'In Ihrem',
			'notifications.video' => 'Video',
			'notifications.repliedYourVideoComment' => 'Hat auf Ihren Videokommentar geantwortet',
			'notifications.copyInfoToClipboard' => 'Benachrichtigungsinfo in die Zwischenablage kopieren',
			'notifications.copySuccess' => 'In die Zwischenablage kopiert',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'In die Zwischenablage kopiert: ${str}',
			'notifications.markAllAsRead' => 'Alle als gelesen markieren',
			'notifications.markAllAsReadSuccess' => 'Alle Benachrichtigungen wurden als gelesen markiert',
			'notifications.markAllAsReadFailed' => 'Alle als gelesen markieren fehlgeschlagen',
			'notifications.markSelectedAsRead' => 'Ausgewählte als gelesen markieren',
			'notifications.markSelectedAsReadSuccess' => 'Ausgewählte Benachrichtigungen wurden als gelesen markiert',
			'notifications.markSelectedAsReadFailed' => 'Ausgewählte als gelesen markieren fehlgeschlagen',
			'notifications.markAsRead' => 'Als gelesen markieren',
			'notifications.markAsReadSuccess' => 'Benachrichtigung wurde als gelesen markiert',
			'notifications.markAsReadFailed' => 'Benachrichtigung als gelesen markieren fehlgeschlagen',
			'notifications.notificationTypeHelp' => 'Hilfe zu Benachrichtigungstypen',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Da Details zum Benachrichtigungstyp fehlen, decken die unterstützten Typen möglicherweise nicht die Nachrichten ab, die Sie derzeit erhalten',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Wenn Sie uns helfen möchten, die Unterstützung für Benachrichtigungstypen zu verbessern',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Kopieren Sie die Benachrichtigungsinformationen\n2. 🐞 Reichen Sie ein Issue im Projekt-Repository ein\n\n⚠️ Hinweis: Benachrichtigungsinformationen können persönliche Privatsphäre enthalten. Wenn Sie sie nicht veröffentlichen möchten, können Sie sie auch per E-Mail an den Projektautor senden.',
			'notifications.goToRepository' => 'Zum Repository',
			'notifications.copy' => 'Kopieren',
			'notifications.commentApproved' => 'Kommentar genehmigt',
			'notifications.repliedYourProfileComment' => 'Hat auf Ihren Profilkommentar geantwortet',
			'notifications.kReplied' => 'hat auf Ihren Kommentar geantwortet zu',
			'notifications.kCommented' => 'hat kommentiert in Ihrem',
			'notifications.kVideo' => 'Video',
			'notifications.kGallery' => 'Galerie',
			'notifications.kProfile' => 'Profil',
			'notifications.kThread' => 'Thread',
			'notifications.kPost' => 'Beitrag',
			'notifications.kCommentSection' => 'Kommentarbereich',
			'notifications.kApprovedComment' => 'Kommentar genehmigt',
			'notifications.kApprovedVideo' => 'Video genehmigt',
			'notifications.kApprovedGallery' => 'Galerie genehmigt',
			'notifications.kApprovedThread' => 'Thread genehmigt',
			'notifications.kApprovedPost' => 'Beitrag genehmigt',
			'notifications.kApprovedForumPost' => 'Forumsbeitrag genehmigt',
			'notifications.kRejectedContent' => 'Inhaltsprüfung abgelehnt',
			'notifications.kUnknownType' => 'Unbekannter Benachrichtigungstyp',
			'conversation.errors.pleaseSelectAUser' => 'Bitte einen Benutzer auswählen',
			'conversation.errors.pleaseEnterATitle' => 'Bitte einen Titel eingeben',
			'conversation.errors.clickToSelectAUser' => 'Tippen, um einen Benutzer auszuwählen',
			'conversation.errors.loadFailedClickToRetry' => 'Laden fehlgeschlagen, zum erneuten Versuch tippen',
			'conversation.errors.loadFailed' => 'Laden fehlgeschlagen',
			'conversation.errors.clickToRetry' => 'Zum erneuten Versuch tippen',
			'conversation.errors.noMoreConversations' => 'Keine weiteren Unterhaltungen',
			'conversation.conversation' => 'Unterhaltung',
			'conversation.startConversation' => 'Unterhaltung starten',
			'conversation.noConversation' => 'Keine Unterhaltung',
			'conversation.selectFromLeftListAndStartConversation' => 'In der linken Liste auswählen und Unterhaltung starten',
			'conversation.title' => 'Titel',
			'conversation.body' => 'Text',
			'conversation.selectAUser' => 'Benutzer auswählen',
			'conversation.searchUsers' => 'Benutzer suchen…',
			'conversation.tmpNoConversions' => 'Keine Unterhaltungen',
			'conversation.deleteThisMessage' => 'Diese Nachricht löschen',
			'conversation.deleteThisMessageSubtitle' => 'Dieser Vorgang kann nicht rückgängig gemacht werden',
			'conversation.writeMessageHere' => 'Nachricht hier schreiben…',
			'conversation.lastMessageFromMe' => 'Sie: ',
			'conversation.sendMessage' => 'Nachricht senden',
			'splash.errors.initializationFailed' => 'Initialisierung fehlgeschlagen, bitte starten Sie die App neu',
			'splash.preparing' => 'Wird vorbereitet...',
			'splash.initializing' => 'Wird initialisiert...',
			'splash.loading' => 'Wird geladen...',
			'splash.ready' => 'Bereit',
			'splash.initializingMessageService' => 'Nachrichtendienst wird initialisiert...',
			'download.errors.imageModelNotFound' => 'Bildmodell nicht gefunden',
			'download.errors.downloadFailed' => 'Download fehlgeschlagen',
			'download.errors.videoInfoNotFound' => 'Videoinformationen nicht gefunden',
			'download.errors.downloadTaskAlreadyExists' => 'Download-Aufgabe existiert bereits',
			'download.errors.downloadTaskSavePathConflict' => 'Der Speicherpfad wird bereits von einer anderen Aufgabe verwendet',
			'download.errors.videoAlreadyDownloaded' => 'Video bereits heruntergeladen',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Hinzufügen der Download-Aufgabe fehlgeschlagen: ${errorInfo}',
			'download.errors.userPausedDownload' => 'Download vom Benutzer pausiert',
			'download.errors.unknown' => 'Unbekannt',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Dateisystemfehler: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Unbekannter Fehler: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'Datei konnte nicht geschrieben werden: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Verbindungszeitüberschreitung',
			'download.errors.sendTimeout' => 'Zeitüberschreitung beim Senden',
			'download.errors.receiveTimeout' => 'Zeitüberschreitung beim Empfangen',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Serverfehler: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Unbekannter Netzwerkfehler',
			'download.errors.sslHandshakeFailed' => 'SSL-Handshake fehlgeschlagen, bitte prüfen Sie Ihr Netzwerk',
			'download.errors.connectionFailed' => 'Verbindung fehlgeschlagen, bitte prüfen Sie Ihr Netzwerk',
			'download.errors.serviceIsClosing' => 'Der Download-Dienst wird beendet',
			'download.errors.partialDownloadFailed' => 'Download von Teilinhalten fehlgeschlagen',
			'download.errors.noDownloadTask' => 'Keine Download-Aufgabe',
			'download.errors.taskNotFoundOrDataError' => 'Aufgabe nicht gefunden oder Datenfehler',
			'download.errors.fileNotFound' => 'Datei nicht gefunden',
			'download.errors.openFolderFailed' => 'Ordner konnte nicht geöffnet werden',
			'download.errors.copyDownloadUrlFailed' => 'Download-URL konnte nicht kopiert werden',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Ordner konnte nicht geöffnet werden: ${message}',
			'download.errors.directoryNotFound' => 'Verzeichnis nicht gefunden',
			'download.errors.copyFailed' => 'Kopieren fehlgeschlagen',
			'download.errors.openFileFailed' => 'Datei konnte nicht geöffnet werden',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Datei konnte nicht geöffnet werden: ${message}',
			'download.errors.playLocallyFailed' => 'Lokale Wiedergabe fehlgeschlagen',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Lokale Wiedergabe fehlgeschlagen: ${message}',
			'download.errors.noDownloadSource' => 'Keine Download-Quelle',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'Keine Download-Quelle, bitte warten Sie, bis die Informationen geladen sind, und versuchen Sie es erneut',
			'download.errors.noActiveDownloadTask' => 'Keine aktive Download-Aufgabe',
			'download.errors.noFailedDownloadTask' => 'Keine fehlgeschlagene Download-Aufgabe',
			'download.errors.noCompletedDownloadTask' => 'Keine abgeschlossene Download-Aufgabe',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Aufgabe bereits abgeschlossen, nicht erneut hinzufügen',
			'download.errors.linkExpiredTryAgain' => 'Link abgelaufen, es wird versucht, einen neuen Download-Link zu erhalten',
			'download.errors.linkExpiredTryAgainSuccess' => 'Link abgelaufen, neuer Download-Link erfolgreich abgerufen',
			'download.errors.linkExpiredTryAgainFailed' => 'Link abgelaufen, das Abrufen eines neuen Download-Links ist fehlgeschlagen',
			'download.errors.taskDeleted' => 'Aufgabe gelöscht',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Nicht unterstütztes Bildformat: ${format}',
			'download.errors.deleteFileError' => 'Datei konnte nicht gelöscht werden, möglicherweise wird sie von einem anderen Prozess verwendet',
			'download.errors.deleteTaskError' => 'Aufgabe konnte nicht gelöscht werden',
			'download.errors.canNotRefreshVideoTask' => 'Video-Aufgabe konnte nicht aktualisiert werden',
			'download.errors.videoRemovedCanNotRefresh' => 'Dieses Video wurde gelöscht oder existiert nicht mehr, daher kann der Download-Link nicht aktualisiert werden',
			'download.errors.videoInaccessibleCanNotRefresh' => 'Auf dieses Video kann nicht zugegriffen werden; es ist möglicherweise privat oder Sie müssen sich erneut anmelden',
			'download.errors.videoQualityGone' => 'Diese Qualität wird nicht mehr angeboten, bitte fügen Sie den Download erneut hinzu',
			'download.errors.refreshLinkNetworkFailed' => 'Netzwerkfehler, der Download-Link kann derzeit nicht aktualisiert werden, bitte später erneut versuchen',
			'download.errors.taskAlreadyProcessing' => 'Aufgabe wird bereits verarbeitet',
			'download.errors.taskNotFound' => 'Aufgabe nicht gefunden',
			'download.errors.failedToLoadTasks' => 'Aufgaben konnten nicht geladen werden',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Teilweiser Download fehlgeschlagen: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Nicht unterstütztes Bildformat: ${extension}; Sie können versuchen, es auf Ihr Gerät herunterzuladen, um es anzusehen',
			'download.errors.imageLoadFailed' => 'Bild konnte nicht geladen werden',
			'download.errors.pleaseTryOtherViewer' => 'Bitte versuchen Sie, es mit einem anderen Betrachter zu öffnen',
			'download.downloadList' => 'Download-Liste',
			'download.viewDownloadList' => 'Download-Liste anzeigen',
			'download.download' => 'Herunterladen',
			'download.selectDownloadTitle' => 'Download auswählen',
			'download.qualitySectionLabel' => 'Qualität',
			'download.categorySectionLabel' => 'Kategorie',
			'download.saveToPreviewLabel' => 'Wird gespeichert unter',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Vorgeschlagener Dateiname: ${name} (im Systemdialog änderbar)',
			'download.lastUsedBadge' => 'Zuletzt verwendet',
			'download.pickedBadge' => 'Ausgewählt',
			'download.startDownloading' => 'Download starten',
			'download.clearAllFailedTasks' => 'Alle fehlgeschlagenen Aufgaben löschen',
			'download.clearAllFailedTasksConfirmation' => 'Möchten Sie wirklich alle fehlgeschlagenen Download-Aufgaben löschen? Die Dateien dieser Aufgaben werden ebenfalls gelöscht.',
			'download.clearAllFailedTasksSuccess' => 'Alle fehlgeschlagenen Aufgaben gelöscht',
			'download.clearAllFailedTasksError' => 'Beim Löschen der fehlgeschlagenen Aufgaben ist ein Fehler aufgetreten',
			'download.downloadStatus' => 'Download-Status',
			'download.imageList' => 'Bildliste',
			'download.retryDownload' => 'Download erneut versuchen',
			'download.notDownloaded' => 'Nicht heruntergeladen',
			'download.downloaded' => 'Heruntergeladen',
			'download.waitingForDownload' => 'Wartet auf Download',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Wird heruntergeladen (${downloaded}/${total} Bilder ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Wird heruntergeladen (${downloaded} Bilder)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Pausiert (${downloaded}/${total} Bilder ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'Pausiert (${downloaded} Bilder)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Heruntergeladen (insgesamt ${total} Bilder)',
			'download.viewVideoDetail' => 'Videodetails anzeigen',
			'download.viewGalleryDetail' => 'Galeriedetails anzeigen',
			'download.moreOptions' => 'Weitere Optionen',
			'download.openFile' => 'Datei öffnen',
			'download.playLocally' => 'Lokal abspielen',
			'download.pause' => 'Pausieren',
			'download.resume' => 'Fortsetzen',
			'download.copyDownloadUrl' => 'Download-URL kopieren',
			'download.showInFolder' => 'Im Ordner anzeigen',
			'download.deleteTask' => 'Aufgabe löschen',
			'download.deleteTaskConfirmation' => 'Möchten Sie diese Download-Aufgabe wirklich löschen?\nDie Datei der Aufgabe wird ebenfalls gelöscht.',
			'download.forceDeleteTask' => 'Aufgabe zwangsweise löschen',
			'download.forceDeleteTaskConfirmation' => 'Möchten Sie diese Download-Aufgabe wirklich zwangsweise löschen?\nDie Datei der Aufgabe wird ebenfalls gelöscht, auch wenn sie gerade verwendet wird.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Wird heruntergeladen ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Wird heruntergeladen ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'Pausiert ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'Pausiert • Heruntergeladen ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Heruntergeladen • ${size}',
			'download.copyDownloadUrlSuccess' => 'Download-URL kopiert',
			'download.totalImageNums' => ({required Object num}) => '${num} Bilder',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Wird heruntergeladen ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'Wird heruntergeladen',
			'download.failed' => 'Fehlgeschlagen',
			'download.completed' => 'Abgeschlossen',
			'download.downloadDetail' => 'Download-Details',
			'download.copy' => 'Kopieren',
			'download.copySuccess' => 'Kopiert',
			'download.waiting' => 'Wartend',
			'download.paused' => 'Pausiert',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Wird heruntergeladen ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Galerie-Download abgeschlossen: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Download abgeschlossen: ${fileName}',
			'download.searchTasks' => 'Aufgaben suchen…',
			'download.statusLabel' => ({required Object label}) => 'Status: ${label}',
			'download.allStatus' => 'Alle Status',
			'download.typeLabel' => ({required Object label}) => 'Typ: ${label}',
			'download.allTypes' => 'Alle Typen',
			'download.taskType' => 'Typ',
			'download.video' => 'Video',
			'download.gallery' => 'Galerie',
			'download.other' => 'Sonstiges',
			'download.clearFilters' => 'Filter zurücksetzen',
			'download.pauseAll' => 'Alle pausieren',
			'download.resumeAll' => 'Alle starten',
			'download.remainingTime' => ({required Object time}) => 'noch ${time}',
			'download.timeline.today' => 'Heute',
			'download.timeline.yesterday' => 'Gestern',
			'download.timeline.thisWeek' => 'Diese Woche',
			'download.timeline.thisMonth' => 'Diesen Monat',
			'download.errorTypes.network' => 'Netzwerkproblem, ein erneuter Versuch kann helfen',
			'download.errorTypes.serverRejected' => 'Vom Server abgelehnt, möglicherweise müssen Sie sich erneut anmelden',
			'download.errorTypes.notFound' => 'Ressource ist nicht mehr vorhanden oder wurde gelöscht',
			'download.errorTypes.diskFull' => 'Nicht genügend Speicherplatz',
			'download.errorTypes.fileInUse' => 'Die Datei wird von einem anderen Programm verwendet',
			'download.errorTypes.permission' => 'Keine Schreibberechtigung',
			'download.errorTypes.cancelled' => 'Abgebrochen',
			'download.errorTypes.unknown' => 'Unbekannter Fehler',
			'download.errorDetailCopied' => 'Fehlerdetails kopiert',
			'download.errorDetailCopyHint' => 'Lange drücken, um Fehlerdetails zu kopieren',
			'download.restoredPaused.banner' => ({required Object num}) => '${num} unvollendete Aufgaben aus der letzten Sitzung wurden pausiert',
			'download.restoredPaused.resume' => 'Alle fortsetzen',
			'download.restoredPaused.dismiss' => 'Verwerfen',
			'download.actions.open' => 'Open',
			'download.actions.play' => 'Play',
			'download.actions.openWith' => 'Open with another app',
			'download.actions.redownload' => 'Download again',
			'download.actions.relocate' => 'Move files to…',
			'download.actions.categorize' => 'Categorize…',
			'download.actions.viewOnline' => 'View online page',
			'download.actions.delete' => 'Delete…',
			'download.actions.redownloadStarted' => ({required Object count}) => 'Started downloading ${count} items again',
			'download.actions.redownloadNone' => 'Nothing to download again',
			'download.actions.deleteTitle' => ({required Object count}) => 'Delete ${count} downloads?',
			'download.actions.deleteSummary' => ({required Object count, required Object size}) => '${count} items · ${size}',
			'download.actions.deleteSummaryNoSize' => ({required Object count}) => '${count} items',
			'download.actions.deleteGalleryNote' => ({required Object count}) => 'Size of ${count} galleries not included',
			'download.actions.deleteFiles' => 'Also delete files from disk',
			'download.actions.deleteFilesDesc' => 'When off, only the list entries are removed and the files stay where they are',
			'download.actions.deleteFilesAllMissing' => 'The files are already gone; only the entries will be removed',
			'download.actions.deleteDone' => ({required Object count}) => 'Deleted ${count} items',
			'download.actions.deletePartial' => ({required Object failed}) => 'Could not delete the files of ${failed} items (they may be in use); their entries were kept',
			'download.actions.removeRecordAnyway' => 'Remove entries anyway',
			'download.actions.fileMissing' => 'File is missing',
			'download.actions.filePending' => 'File not found right now, it may still be recoverable',
			'download.actions.statusActive' => 'In progress',
			'download.actions.statusCompleted' => 'Completed',
			'download.actions.needsAttention' => 'Needs attention',
			'download.actions.needsAttentionCount' => ({required Object count}) => 'Needs attention · ${count}',
			'download.actions.organize' => 'Organize',
			'download.actions.checkIntegrity' => 'Check file integrity…',
			'download.actions.migrateToCurrent' => 'Move to current download folder…',
			'download.actions.migrateNone' => 'Everything is already in the current download folder',
			'download.notice.failed' => ({required Object count}) => '${count} downloads failed',
			'download.notice.retryAll' => 'Retry all',
			'download.notice.view' => 'View',
			'download.notice.missing' => ({required Object count}) => 'Files of ${count} downloaded items are missing',
			'download.notice.handle' => 'Handle…',
			'download.notice.outside' => ({required Object count}) => '${count} items are still in the old download folder',
			'download.notice.migrate' => 'Move',
			'download.notice.dismiss' => 'Dismiss',
			'download.emptyTaskList' => 'Noch keine Download-Aufgaben',
			'download.noMatchingTasks' => 'Keine passenden Aufgaben',
			'download.deleteByDate.menuTitle' => 'Nach Datum löschen',
			'download.deleteByDate.dialogTitle' => 'Nach Datum löschen',
			'download.deleteByDate.description' => 'Löscht Download-Aufgaben gesammelt nach Erstellungsdatum. Aufgaben, deren Dateien gerade verwendet werden, werden übersprungen; Aufgaben, deren Dateien nicht mehr existieren, werden bereinigt.',
			'download.deleteByDate.modeRange' => 'Datumsbereich',
			'download.deleteByDate.modeDays' => 'Älter als',
			'download.deleteByDate.startDate' => 'Startdatum',
			'download.deleteByDate.endDate' => 'Enddatum',
			'download.deleteByDate.notSet' => 'Nicht festgelegt',
			'download.deleteByDate.daysUnit' => 'Tage',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Aufgaben löschen, die vor mehr als ${days} Tag(en) erstellt wurden',
			'download.deleteByDate.noMatch' => 'Keine Aufgaben entsprechen der gewählten Bedingung',
			'download.deleteByDate.invalidRange' => 'Das Startdatum muss am oder vor dem Enddatum liegen',
			'download.deleteByDate.confirmTitle' => 'Löschen bestätigen',
			'download.deleteByDate.confirmContent' => ({required Object count}) => '${count} Download-Aufgabe(n) und ihre Dateien löschen? Dies kann nicht rückgängig gemacht werden.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Lösche ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => '${count} Aufgabe(n) gelöscht',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => '${deleted} Aufgabe(n) gelöscht; ${skipped} übersprungen (in Verwendung)',
			'download.relocation.moveFiles' => 'Move files',
			'download.relocation.moveFilesEllipsis' => 'Move files…',
			'download.relocation.chooseDestination' => 'Move files to',
			'download.relocation.currentDownloadDir' => 'Current download folder',
			'download.relocation.otherFolder' => 'Choose another folder…',
			'download.relocation.pickerUnsupported' => 'Folders can\'t be picked on this device. Downloads stay in the app\'s own folder.',
			'download.relocation.planning' => 'Checking files…',
			'download.relocation.confirmTitle' => 'Move files?',
			'download.relocation.confirmNote' => 'Files are moved on disk. Watch progress, VR settings and favorites move with them.',
			'download.relocation.nothingToMove' => 'Nothing in the selection can be moved. See the reason for each item below.',
			'download.relocation.move' => 'Move',
			'download.relocation.moving' => ({required Object done, required Object total}) => 'Moving ${done}/${total}',
			'download.relocation.stop' => 'Stop',
			'download.relocation.stopping' => 'Stopping after the current item…',
			'download.relocation.resultTitle' => 'Move finished',
			'download.relocation.resultMoved' => ({required Object count}) => '${count} item(s) moved',
			'download.relocation.cancelled' => 'Stopped. Items already moved are complete.',
			'download.relocation.alreadyRunning' => 'Another move is already in progress',
			'download.relocation.destination' => 'Destination',
			'download.relocation.statMove' => 'To move',
			'download.relocation.statSkip' => 'Skipped',
			'download.relocation.statRenamed' => 'Renamed',
			'download.relocation.statMoved' => 'Moved',
			'download.relocation.statFailed' => 'Not moved',
			'download.relocation.statLeftover' => 'Left behind',
			'download.relocation.sectionMove' => 'Will be moved',
			'download.relocation.sectionSkip' => 'Will be skipped',
			'download.relocation.sectionMoved' => 'Moved',
			'download.relocation.sectionFailed' => 'Not moved (left where it was)',
			'download.relocation.sectionLeftover' => 'Old folders not fully removed',
			'download.relocation.leftoverHint' => 'The copy at the new location is complete. These leftovers can be deleted.',
			'download.relocation.from' => 'From',
			'download.relocation.to' => 'To',
			'download.relocation.renamedBadge' => ({required Object name}) => 'Name taken, will be saved as "${name}"',
			'download.relocation.showPaths' => 'Show paths',
			'download.relocation.hidePaths' => 'Hide paths',
			'download.relocation.revealInFolder' => 'Show in folder',
			'download.relocation.copyPath' => 'Copy path',
			'download.relocation.pathCopied' => 'Path copied',
			'download.relocation.stateDownloading' => ({required Object percent}) => 'downloading, ${percent}%',
			'download.relocation.statePending' => 'waiting to download',
			'download.relocation.statePaused' => ({required Object percent}) => 'paused at ${percent}%',
			'download.relocation.stateFailed' => 'download failed',
			'download.relocation.skipAlreadyThere' => 'Already in this folder',
			'download.relocation.skipInsideSource' => 'The destination is inside this gallery\'s own folder',
			'download.relocation.reasonBusy' => 'Busy with another operation (deleting or moving)',
			'download.relocation.reasonSourceLocked' => 'The file is in use (for example, playing), so it couldn\'t be removed from the old location. Nothing was changed.',
			'download.relocation.reasonNoSpace' => 'The destination ran out of space. The rest of the batch was stopped.',
			'download.relocation.reasonVerifyFailed' => 'The copy didn\'t match the original\'s size. The copy was discarded.',
			'download.relocation.reasonIoError' => 'Couldn\'t read or write the file. Nothing was changed.',
			'download.relocation.systemMessage' => ({required Object message}) => 'System message: ${message}',
			'download.relocation.outsideTitle' => ({required Object count}) => '${count} downloaded item(s) are outside this folder',
			'download.relocation.outsideSubtitle' => 'They still play where they are. Move them here to keep everything together.',
			'download.relocation.moveHere' => 'Move here',
			'download.relocation.missingTitle' => 'Files not found',
			'download.relocation.recordedLocation' => 'Recorded location',
			'download.relocation.legendExists' => 'still exists',
			'download.relocation.legendMissing' => 'missing',
			'download.relocation.diagVolume' => ({required Object volume}) => 'Storage "${volume}" is not available. The SD card or external drive may not be connected.',
			'download.relocation.diagVolumeShort' => ({required Object volume}) => 'storage "${volume}" not connected',
			'download.relocation.diagContainer' => 'After an app update, the system moved the app\'s storage. The file is still here:',
			'download.relocation.diagContainerShort' => 'app storage moved after update',
			'download.relocation.diagNoAccess' => 'The app doesn\'t have permission to read this location. Grant "All files access" and check again.',
			'download.relocation.diagNoAccessShort' => 'no permission to read this location',
			'download.relocation.diagFolder' => ({required Object folder}) => 'The folder "${folder}" no longer exists.',
			'download.relocation.diagFolderShort' => ({required Object folder}) => 'folder "${folder}" no longer exists',
			'download.relocation.diagFile' => ({required Object name}) => 'The folder is still there, but "${name}" isn\'t in it.',
			'download.relocation.diagFileShort' => 'not found in its folder',
			'download.relocation.diagCandidates' => 'Found something in that folder that looks like it (maybe renamed):',
			'download.relocation.diagNoCandidates' => 'Nothing with the same size was found in that folder.',
			'download.relocation.useThis' => 'Use this',
			'download.relocation.fixPath' => 'Fix path',
			'download.relocation.checkAgain' => 'Check again',
			'download.relocation.grantPermission' => 'Grant permission',
			'download.relocation.locate' => 'Find in another folder…',
			'download.relocation.deleteRecord' => 'Delete record',
			'download.relocation.locateNotFound' => 'This download\'s files aren\'t in that folder',
			'download.relocation.located' => 'Found. The record now points to the new location.',
			'download.relocation.stillMissing' => 'Still not found',
			'download.relocation.downloadedOn' => ({required Object date}) => 'Downloaded ${date}',
			'download.relocation.galleryImages' => ({required Object count}) => '${count} images',
			'download.relocation.unfinishedDownloading' => ({required Object percent}) => 'Downloading ${percent}%: paused first, the downloaded part moves too, then continues',
			'download.relocation.unfinishedPending' => 'Waiting to download: re-queued after the move',
			'download.relocation.unfinishedPaused' => ({required Object percent}) => 'Paused at ${percent}%: the downloaded part moves too, stays paused',
			'download.relocation.unfinishedFailed' => 'Download failed: the downloaded part moves too',
			'download.relocation.noDataYet' => 'Nothing downloaded yet, only the save location changes',
			_ => null,
		} ?? switch (path) {
			'download.relocation.missingGroup' => ({required Object count}) => '${count} item(s) with missing files',
			'download.relocation.missingSkip' => 'Leave as is',
			'download.relocation.missingRedownload' => 'Re-download to the destination',
			'download.relocation.missingRemove' => 'Remove records',
			'download.relocation.missingRemoveVolumeNote' => ({required Object count}) => '${count} of them are on storage that isnt connected and wont be removed',
			'download.relocation.failedGroup' => ({required Object count}) => '${count} failed download(s)',
			'download.relocation.failedMoveOnly' => 'Just move',
			'download.relocation.failedMoveAndRetry' => 'Move, then re-download',
			'download.relocation.failedRemove' => 'Remove tasks',
			'download.relocation.failedRemoveNote' => 'Their partially downloaded files are deleted too',
			'download.relocation.execute' => 'Apply',
			'download.relocation.actionWillRedownload' => 'Will be re-downloaded to the destination',
			'download.relocation.actionWillRemove' => 'This record will be removed',
			'download.relocation.actionWillKeep' => 'Storage not connected, will be kept',
			'download.relocation.actionWillRetry' => 'Re-downloaded after the move',
			'download.relocation.actionWillRemoveTask' => 'This task will be removed',
			'download.relocation.statRedownload' => 'Re-download',
			'download.relocation.statRemoved' => 'Removed',
			'download.relocation.sectionRedownloaded' => 'Re-download started',
			'download.relocation.sectionRedownloadFailed' => 'Couldnt start re-download',
			'download.relocation.redownloadFailedHint' => 'Usually the download link is no longer valid (the work was deleted or made private). You can retry later from the download list.',
			'download.relocation.sectionRemoved' => 'Removed',
			'download.relocation.sectionKept' => 'Kept (storage not connected)',
			'download.relocation.redownload' => 'Re-download',
			'download.relocation.redownloadStarted' => 'Re-download started',
			'download.relocation.redownloadNotStarted' => 'Couldnt start re-download',
			'download.relocation.diagFileShortWithCandidates' => 'a file with the same size is in its folder, maybe renamed',
			'download.relocation.cleanupMenu' => 'Clean up broken records…',
			'download.relocation.cleanupScanning' => ({required Object done, required Object total}) => 'Checking ${done}/${total}',
			'download.relocation.cleanupTitle' => 'Clean up broken records',
			'download.relocation.cleanupNone' => ({required Object count}) => 'Checked ${count} completed download(s). All files are there.',
			'download.relocation.statChecked' => 'Checked',
			'download.relocation.statMissing' => 'Missing',
			'download.relocation.statKeep' => 'Keep',
			'download.relocation.cleanupGroupGone' => 'Files are gone',
			'download.relocation.cleanupGroupRecoverable' => 'May still be recoverable',
			'download.relocation.cleanupRecoverableHint' => 'Storage not connected, no permission, or maybe renamed. Not selected by default. Open an item to see details and recover it.',
			'download.relocation.selectAll' => 'Select all',
			'download.relocation.selectNone' => 'Select none',
			'download.relocation.removeSelected' => ({required Object count}) => 'Remove selected (${count})',
			'download.relocation.redownloadSelected' => ({required Object count}) => 'Re-download selected (${count})',
			'download.relocation.processing' => ({required Object done, required Object total}) => 'Processing ${done}/${total}',
			'download.relocation.cleanupRemoved' => ({required Object count}) => '${count} record(s) removed',
			'download.relocation.cleanupRedownloaded' => ({required Object count}) => 'Re-download started for ${count} item(s)',
			'download.relocation.tapForDetail' => 'Details',
			'download.relocation.deleteRecordFailed' => 'Couldnt delete the record. Try again later.',
			'download.relocation.sectionNotAttempted' => 'Not processed (stopped, left as is)',
			'download.relocation.unexpectedError' => ({required Object message}) => 'Stopped because of an error: ${message}. Items already moved are complete.',
			'download.category.manageTitle' => 'Kategorien verwalten',
			'download.category.label' => 'Kategorien',
			'download.category.uncategorized' => 'Nicht kategorisiert',
			'download.category.manage' => 'Verwalten',
			'download.category.createShortcut' => 'Neu',
			'download.category.newCategoryHint' => 'Name der neuen Kategorie',
			'download.category.createSuccess' => 'Kategorie erstellt',
			'download.category.createFailed' => 'Kategorie konnte nicht erstellt werden',
			'download.category.nameEmpty' => 'Der Kategoriename darf nicht leer sein',
			'download.category.emptyHint' => 'Noch keine Kategorien. Erstellen Sie eine, um Ihre Downloads zu organisieren.',
			'download.category.moveTo' => 'In Kategorie verschieben',
			'download.category.moveToWithCount' => ({required Object count}) => '${count} Element(e) verschieben nach…',
			'download.category.moveSuccess' => ({required Object title}) => 'Verschoben nach ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Nach „Nicht kategorisiert“ verschoben',
			'download.category.moveFailed' => 'Verschieben fehlgeschlagen',
			'download.category.renameTitle' => 'Kategorie umbenennen',
			'download.category.renameHint' => 'Kategoriename eingeben',
			'download.category.renameSuccess' => 'Kategorie umbenannt',
			'download.category.renameFailed' => 'Kategorie konnte nicht umbenannt werden',
			'download.category.deleteTitle' => 'Kategorie löschen',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'Kategorie „${title}“ löschen? Die ${count} Elemente darin werden nach „Nicht kategorisiert“ verschoben. Es werden keine Dateien gelöscht.',
			'download.category.deleteSuccess' => 'Kategorie gelöscht',
			'download.category.deleteFailed' => 'Kategorie konnte nicht gelöscht werden',
			'download.location.sectionTitle' => 'Save location',
			'download.location.behaviorSection' => 'Download behavior',
			'download.location.namingSection' => 'File naming',
			'download.location.advancedSection' => 'Advanced',
			'download.location.advancedSubtitle' => 'Write diagnostics and other tools',
			'download.location.volumeInternal' => 'Internal storage',
			'download.location.volumeSdCard' => 'SD card',
			'download.location.volumeExternalDrive' => 'External drive',
			'download.location.appSpace' => 'App-only storage',
			'download.location.downloadsFolder' => 'Downloads',
			'download.location.askEveryTime' => 'Ask every time',
			'download.location.askEveryTimeDesc' => ({required Object location}) => 'Choose where to save for each download. Batch downloads go to ${location}',
			'download.location.freeSpace' => ({required Object size}) => '${size} free',
			'download.location.statusWritable' => 'Writable',
			'download.location.statusNeedsPermission' => 'Needs permission',
			'download.location.statusFallback' => 'Temporarily redirected',
			'download.location.statusLowSpace' => 'Low space',
			'download.location.statusChecking' => 'Checking',
			'download.location.grant' => 'Grant',
			'download.location.fix' => 'Fix',
			'download.location.changeLocation' => 'Change location',
			'download.location.openInFileManager' => 'Open in file manager',
			'download.location.moreActions' => 'More',
			'download.location.copyPath' => 'Copy path',
			'download.location.pathCopied' => 'Path copied',
			'download.location.manualInput' => 'Enter path manually (advanced)',
			'download.location.restoreDefault' => 'Restore default',
			'download.location.runDiagnostics' => 'Run diagnostics',
			'download.location.restoredDefault' => 'Restored the default location',
			'download.location.sheetTitle' => 'Choose download location',
			'download.location.chooseOtherFolder' => 'Choose another folder…',
			'download.location.chooseOtherFolderDesc' => 'Pick one with the system file picker',
			'download.location.optionRecommendedDesc' => 'Recommended · no permission needed',
			'download.location.optionRecommendedLegacyDesc' => 'Recommended · needs storage permission',
			'download.location.optionAppPrivateDesc' => 'Deleted on uninstall · hidden from the gallery',
			'download.location.optionRemovableDesc' => 'Needs "All files access"',
			'download.location.optionDesktopDownloadsDesc' => 'Recommended · your Downloads folder',
			'download.location.optionAskEveryTimeDesc' => 'Pick a folder for each download',
			'download.location.current' => 'Current',
			'download.location.fallbackBanner' => 'Your last download was temporarily saved to app storage because the chosen folder could not be used.',
			'download.location.fallbackReasonPermission' => 'storage permission is missing',
			'download.location.fallbackReasonVolumeMissing' => 'the storage device is not connected',
			'download.location.fallbackReasonCannotCreate' => 'the folder could not be created',
			'download.location.fallbackReasonNotWritable' => 'the folder cannot be written to',
			'download.location.fallbackDetail' => ({required Object reason}) => 'Temporarily redirected: ${reason}',
			'download.location.errorUnresolvable' => 'This location belongs to a cloud drive or another app and cannot be written to directly. Choose a folder on your device storage or SD card.',
			'download.location.errorNotWritable' => 'This folder cannot be written to (read-only, protected by the system, or disconnected). The location was not changed.',
			'download.location.errorVolumeMissing' => 'This storage device cannot be found (removed or not connected). The location was not changed.',
			'download.location.permissionTitle' => 'Permission needed',
			'download.location.permissionAllFiles' => 'Writing to this folder needs "All files access". If you\'d rather not allow that, use "Downloads › LoveIwara" instead.',
			'download.location.permissionLegacy' => 'Writing to this folder needs the storage permission. If you\'d rather not allow that, use app-only storage instead.',
			'download.location.useDownloadsInstead' => 'Use Downloads › LoveIwara',
			'download.location.useAppSpaceInstead' => 'Use app-only storage',
			'download.location.goToSettings' => 'Grant',
			'download.location.permissionDenied' => 'Permission was not granted. The location was not changed.',
			'download.location.checking' => 'Checking this location…',
			'download.location.confirmTitle' => 'Use this location?',
			'download.location.confirmFree' => ({required Object size}) => '${size} free',
			'download.location.confirmOutside' => ({required Object count}) => '${count} downloaded item(s) stay in the old location',
			'download.location.confirmOutsideDesc' => 'New downloads will be saved here. What about the ones you already have?',
			'download.location.moveThem' => 'Move them here',
			'download.location.keepThem' => 'Keep them where they are',
			'download.location.decideLater' => 'Decide later',
			'download.location.useThisLocation' => 'Use this location',
			'download.location.locationChanged' => 'Download location changed',
			'download.location.manualTitle' => 'Enter path manually',
			'download.location.manualLabel' => 'Folder path',
			'download.location.manualHint' => 'e.g. /storage/emulated/0/Download/LoveIwara',
			'download.location.manualSubmit' => 'Check and use',
			'download.location.manualEmpty' => 'Enter a path',
			'download.location.manualNotAbsolute' => 'Enter a full absolute path',
			'download.location.fixStillFailing' => 'This location still cannot be used. Choose another one.',
			'download.location.fixed' => 'The location works again',
			'download.maxConcurrentDownloads' => 'Max. gleichzeitige Downloads',
			'download.maxConcurrentDownloadsDesc' => 'Anzahl der gleichzeitig herunterladenden Aufgaben (1-5)',
			'download.stillInDevelopment' => 'Noch in Entwicklung',
			'download.saveToAppDirectory' => 'Im App-Verzeichnis speichern',
			'download.alreadyDownloadedWithQuality' => 'Bereits in der gleichen Qualität heruntergeladen. Möchten Sie den Download fortsetzen?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Bereits in den Qualitätsstufen heruntergeladen: ${qualities}. Möchten Sie den Download fortsetzen?',
			'download.otherQualities' => 'Andere Qualitäten',
			'download.batchDownload.title' => 'Stapel-Download',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Es läuft bereits eine Aufgabe, bitte warten.',
			'download.batchDownload.userCancelled' => 'Vom Benutzer abgebrochen',
			'download.batchDownload.failedToGetVideoInfo' => 'Videoinformationen konnten nicht abgerufen werden',
			'download.batchDownload.failedToGetVideoSource' => 'Videoquelle konnte nicht ermittelt werden',
			'download.batchDownload.failedToGetGalleryInfo' => 'Galerieinformationen konnten nicht abgerufen werden',
			'download.batchDownload.galleryNoImages' => 'Die Galerie enthält keine Bilder',
			'download.batchDownload.failedToGetSavePath' => 'Speicherpfad konnte nicht ermittelt werden',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Stapel-Download fehlgeschlagen: ${exception}',
			'download.batchDownload.selectQuality' => 'Qualität auswählen',
			'download.batchDownload.downloading' => 'Wird heruntergeladen',
			'download.batchDownload.downloadResult' => 'Download-Ergebnis',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => '${count} Video(s) ausgewählt',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => '${count} Galerie(n) ausgewählt',
			'download.batchDownload.qualityNote' => 'Ist die gewählte Qualität nicht verfügbar, wird die bestmögliche verfügbare Qualität verwendet',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Verarbeite ${current}/${total}',
			'download.batchDownload.queued' => 'In Warteschlange',
			'download.batchDownload.success' => 'Erfolg',
			'download.batchDownload.skipped' => 'Übersprungen',
			'download.batchDownload.failed' => 'Fehlgeschlagen',
			'download.batchDownload.failureDetails' => 'Fehlerdetails',
			'download.batchDownload.reasonPrivateVideo' => 'Privates Video',
			'download.batchDownload.reasonAlreadyExists' => 'Bereits vorhanden',
			'download.batchDownload.reasonNoSource' => 'Keine Download-Quelle',
			'download.batchDownload.reasonNoSavePath' => 'Speicherpfad nicht ermittelbar',
			'download.batchDownload.reasonOther' => 'Anderer Fehler',
			'download.batchDownload.startDownload' => 'Download starten',
			'downloadNotifications.completedTitle' => 'Download abgeschlossen',
			'downloadNotifications.failedTitle' => 'Download fehlgeschlagen',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} wurde erfolgreich heruntergeladen',
			'downloadNotifications.failedBody' => ({required Object name}) => '${name} konnte nicht heruntergeladen werden',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} heruntergeladen',
			'downloadNotifications.failedToast' => ({required Object name}) => 'Download von ${name} fehlgeschlagen',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Gespeichert unter ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Gespeichert als ${name} (gleichnamige Datei existierte bereits)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Im App-Ordner gespeichert — Schreiben nach ${target} nicht möglich (${reason})',
			'downloadNotifications.viewFolder' => 'Ordner anzeigen',
			'downloadNotifications.fixInSettings' => 'In den Einstellungen beheben',
			'downloadNotifications.channelName' => 'Download-Status',
			'downloadNotifications.channelDescription' => 'Benachrichtigungen für abgeschlossene und fehlgeschlagene Downloads',
			'favorite.errors.addFailed' => 'Hinzufügen fehlgeschlagen',
			'favorite.errors.addSuccess' => 'Erfolgreich hinzugefügt',
			'favorite.errors.deleteFolderFailed' => 'Ordner löschen fehlgeschlagen',
			'favorite.errors.deleteFolderSuccess' => 'Ordner erfolgreich gelöscht',
			'favorite.errors.folderNameCannotBeEmpty' => 'Der Ordnername darf nicht leer sein',
			'favorite.add' => 'Hinzufügen',
			'favorite.addSuccess' => 'Erfolgreich hinzugefügt',
			'favorite.addFailed' => 'Hinzufügen fehlgeschlagen',
			'favorite.remove' => 'Entfernen',
			'favorite.removeSuccess' => 'Erfolgreich entfernt',
			'favorite.removeFailed' => 'Entfernen fehlgeschlagen',
			'favorite.removeConfirmation' => 'Möchten Sie dieses Element wirklich aus den Favoriten entfernen?',
			'favorite.removeConfirmationSuccess' => 'Element aus den Favoriten entfernt',
			'favorite.removeConfirmationFailed' => 'Element konnte nicht aus den Favoriten entfernt werden',
			'favorite.createFolderSuccess' => 'Ordner erfolgreich erstellt',
			'favorite.createFolderFailed' => 'Ordner konnte nicht erstellt werden',
			'favorite.createFolder' => 'Ordner erstellen',
			'favorite.enterFolderName' => 'Ordnernamen eingeben',
			'favorite.enterFolderNameHere' => 'Ordnernamen hier eingeben…',
			'favorite.create' => 'Erstellen',
			'favorite.items' => 'Elemente',
			'favorite.newFolderName' => 'Neuer Ordner',
			'favorite.searchFolders' => 'Ordner suchen…',
			'favorite.searchItems' => 'Elemente suchen…',
			'favorite.createdAt' => 'Erstellt am',
			'favorite.myFavorites' => 'Meine Favoriten',
			'favorite.deleteFolderTitle' => 'Ordner löschen',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Möchten Sie den Ordner ${title} wirklich löschen?',
			'favorite.removeItemTitle' => 'Element entfernen',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Möchten Sie das Element ${title} wirklich löschen?',
			'favorite.removeItemSuccess' => 'Element aus den Favoriten entfernt',
			'favorite.removeItemFailed' => 'Element konnte nicht aus den Favoriten entfernt werden',
			'favorite.localizeFavorite' => 'Lokale Favoriten',
			'favorite.editFolderTitle' => 'Ordner bearbeiten',
			'favorite.editFolderSuccess' => 'Ordner erfolgreich aktualisiert',
			'favorite.editFolderFailed' => 'Ordner konnte nicht aktualisiert werden',
			'favorite.searchTags' => 'Tags suchen',
			'favorite.noTagsInFolder' => 'Noch keine Tags an den Elementen in diesem Ordner',
			'favorite.tagFilterMatchAll' => 'Zeigt nur Elemente, die alle ausgewählten Tags tragen',
			'favorite.clearSelectedTags' => 'Ausgewählte Tags zurücksetzen',
			'favorite.selectedTagCount' => ({required Object count}) => '${count} ausgewählt',
			'favorite.noMatchingTags' => 'Keine passenden Tags',
			'translation.currentService' => 'Aktueller Dienst',
			'translation.testConnection' => 'Verbindung testen',
			'translation.testConnectionSuccess' => 'Verbindungstest erfolgreich',
			'translation.testConnectionFailed' => 'Verbindungstest fehlgeschlagen',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Verbindungstest fehlgeschlagen: ${message}',
			'translation.translation' => 'Übersetzung',
			'translation.needVerification' => 'Verifizierung erforderlich',
			'translation.needVerificationContent' => 'Bitte testen Sie zuerst die Verbindung, bevor Sie die KI-Übersetzung aktivieren',
			'translation.confirm' => 'Bestätigen',
			'translation.disclaimer' => 'Haftungsausschluss',
			'translation.riskWarning' => 'Risikowarnung',
			'translation.dureToRisk1' => 'Da der Text von Nutzern erstellt wird, kann er Inhalte enthalten, die gegen die Inhaltsrichtlinien des KI-Dienstanbieters verstoßen',
			'translation.dureToRisk2' => 'Unangemessene Inhalte können zur Sperrung des API-Schlüssels oder zur Beendigung des Dienstes führen',
			'translation.operationSuggestion' => 'Bedienhinweis',
			'translation.operationSuggestion1' => '1. Vor der strengen Prüfung der zu übersetzenden Inhalte verwenden',
			'translation.operationSuggestion2' => '2. Vermeiden Sie die Übersetzung von Inhalten mit Gewalt, sexuellen Inhalten usw.',
			'translation.apiConfig' => 'API-Konfiguration',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Das Ändern der Konfiguration schließt die KI-Übersetzung automatisch; nach dem Aktivieren muss erneut getestet werden',
			'translation.apiAddress' => 'API-Adresse',
			'translation.modelName' => 'Modellname',
			'translation.modelNameHintText' => 'Zum Beispiel: gpt-4-turbo',
			'translation.maxTokens' => 'Max. Tokens',
			'translation.maxTokensHintText' => 'Zum Beispiel: 32000',
			'translation.temperature' => 'Temperatur',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Klicken Sie auf die Testschaltfläche, um die Gültigkeit der API-Verbindung zu prüfen',
			'translation.requestPreview' => 'Anfragevorschau',
			'translation.enableAITranslation' => 'KI aktivieren',
			'translation.enabled' => 'Aktiviert',
			'translation.disabled' => 'Deaktiviert',
			'translation.testing' => 'Wird getestet...',
			'translation.testNow' => 'Jetzt testen',
			'translation.connectionStatus' => 'Verbindungsstatus',
			'translation.success' => 'Erfolg',
			'translation.failed' => 'Fehlgeschlagen',
			'translation.information' => 'Information',
			'translation.viewRawResponse' => 'Rohantwort anzeigen',
			'translation.pleaseCheckInputParametersFormat' => 'Bitte überprüfen Sie das Format der Eingabeparameter',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Bitte API-Adresse, Modellname und Schlüssel ausfüllen',
			'translation.pleaseFillInValidConfigurationParameters' => 'Bitte gültige Konfigurationsparameter ausfüllen',
			'translation.pleaseCompleteConnectionTest' => 'Bitte schließen Sie den Verbindungstest ab',
			'translation.notConfigured' => 'Nicht konfiguriert',
			'translation.apiEndpoint' => 'API-Endpunkt',
			'translation.configuredKey' => 'Konfigurierter Schlüssel',
			'translation.notConfiguredKey' => 'Nicht konfigurierter Schlüssel',
			'translation.authenticationStatus' => 'Authentifizierungsstatus',
			'translation.thisFieldCannotBeEmpty' => 'Dieses Feld darf nicht leer sein',
			'translation.apiKey' => 'API-Schlüssel',
			'translation.apiKeyCannotBeEmpty' => 'Der API-Schlüssel darf nicht leer sein',
			'translation.pleaseEnterValidNumber' => 'Bitte eine gültige Zahl eingeben',
			'translation.range' => 'Bereich',
			'translation.mustBeGreaterThan' => 'Muss größer sein als',
			'translation.invalidAPIResponse' => 'Ungültige API-Antwort',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Verbindung fehlgeschlagen: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'KI-Übersetzung ist nicht aktiviert, bitte aktivieren Sie sie in den Einstellungen',
			'translation.goToSettings' => 'Zu den Einstellungen',
			'translation.disableAITranslation' => 'KI-Übersetzung deaktivieren',
			'translation.currentValue' => 'Aktueller Wert',
			'translation.configureTranslationStrategy' => 'Übersetzungsstrategie konfigurieren',
			'translation.advancedSettings' => 'Erweiterte Einstellungen',
			'translation.translationPrompt' => 'Übersetzungs-Prompt',
			'translation.promptHint' => 'Bitte geben Sie den Übersetzungs-Prompt ein und verwenden Sie [TL] als Platzhalter für die Zielsprache',
			'translation.promptHelperText' => 'Der Prompt muss [TL] als Platzhalter für die Zielsprache enthalten',
			'translation.promptMustContainTargetLang' => 'Der Prompt muss den Platzhalter [TL] enthalten',
			'translation.aiTranslationWillBeDisabled' => 'KI-Übersetzung wird deaktiviert',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Aufgrund einer Änderung der Basiskonfiguration wird die KI-Übersetzung deaktiviert',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Aufgrund einer Änderung des Übersetzungs-Prompts wird die KI-Übersetzung deaktiviert',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Aufgrund einer Änderung der Parameterkonfiguration wird die KI-Übersetzung deaktiviert',
			'translation.onlyOpenAIAPISupported' => 'Derzeit wird nur das OpenAI-kompatible API-Format unterstützt (Anfragetext im Format application/json)',
			'translation.streamingTranslation' => 'Streaming-Übersetzung',
			'translation.streamingTranslationSupported' => 'Streaming-Übersetzung wird unterstützt',
			'translation.streamingTranslationNotSupported' => 'Streaming-Übersetzung wird nicht unterstützt',
			'translation.streamingTranslationDescription' => 'Die Streaming-Übersetzung kann Ergebnisse während des Übersetzungsvorgangs in Echtzeit anzeigen und bietet so ein besseres Nutzererlebnis',
			'translation.usingFullUrlWithHash' => 'Vollständige URL verwenden (endet mit #)',
			'translation.baseUrlInputHelperText' => 'Bei einem abschließenden # wird es als tatsächliche Anfrageadresse verwendet',
			'translation.currentActualUrl' => ({required Object url}) => 'Aktuelle tatsächliche URL: ${url}',
			'translation.urlEndingWithHashTip' => 'Eine URL mit abschließendem # wird direkt verwendet, ohne einen Suffix anzuhängen',
			'translation.streamingTranslationWarning' => 'Hinweis: Diese Funktion erfordert, dass der API-Dienst Streaming-Übertragung unterstützt; einige Modelle unterstützen dies möglicherweise nicht',
			'translation.translationService' => 'Übersetzungsdienst',
			'translation.translationServiceDescription' => 'Wählen Sie Ihren bevorzugten Übersetzungsdienst',
			'translation.googleTranslation' => 'Google-Übersetzung',
			'translation.googleTranslationDescription' => 'Kostenloser Online-Übersetzungsdienst, der mehrere Sprachen unterstützt',
			'translation.aiTranslation' => 'KI-Übersetzung',
			'translation.aiTranslationDescription' => 'Intelligenter Übersetzungsdienst auf Basis großer Sprachmodelle',
			'translation.deeplxTranslation' => 'DeepLX-Übersetzung',
			'translation.deeplxTranslationDescription' => 'Open-Source-Implementierung der DeepL-Übersetzung mit qualitativ hochwertiger Übersetzung',
			'translation.googleTranslationFeatures' => 'Funktionen',
			'translation.freeToUse' => 'Kostenlos nutzbar',
			'translation.freeToUseDescription' => 'Keine Konfiguration erforderlich, sofort einsatzbereit',
			'translation.fastResponse' => 'Schnelle Antwort',
			'translation.fastResponseDescription' => 'Schnelle Übersetzungsgeschwindigkeit mit geringer Latenz',
			'translation.stableAndReliable' => 'Stabil und zuverlässig',
			'translation.stableAndReliableDescription' => 'Basierend auf der offiziellen Google-API',
			'translation.enabledDefaultService' => 'Aktiviert – Standard-Übersetzungsdienst',
			'translation.notEnabled' => 'Nicht aktiviert',
			'translation.deeplxTranslationService' => 'DeepLX-Übersetzungsdienst',
			'translation.deeplxDescription' => 'DeepLX ist eine Open-Source-Implementierung der DeepL-Übersetzung und unterstützt die Endpunktmodi Free, Pro und Official',
			'translation.serverAddress' => 'Serveradresse',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Basisadresse des DeepLX-Servers',
			'translation.endpointType' => 'Endpunkttyp',
			'translation.freeEndpoint' => 'Free – kostenloser Endpunkt, ggf. mit Ratenlimits',
			'translation.proEndpoint' => 'Pro – erfordert dl_session, stabiler',
			'translation.officialEndpoint' => 'Official – offizielles API-Format',
			'translation.finalRequestUrl' => 'Endgültige Anfrage-URL',
			'translation.apiKeyOptional' => 'API-Schlüssel (optional)',
			'translation.apiKeyOptionalHint' => 'Für den Zugriff auf geschützte DeepLX-Dienste',
			'translation.apiKeyOptionalHelperText' => 'Einige DeepLX-Dienste erfordern zur Authentifizierung einen API-Schlüssel',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Für den Pro-Modus erforderlicher dl_session-Parameter',
			'translation.dlSessionHelperText' => 'Für den Pro-Endpunkt erforderlicher Sitzungsparameter, erhalten aus dem DeepL-Pro-Konto',
			'translation.proModeRequiresDlSession' => 'Der Pro-Modus erfordert dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Klicken Sie auf die Testschaltfläche, um die DeepLX-API-Verbindung zu prüfen',
			'translation.enableDeepLXTranslation' => 'DeepLX-Übersetzung aktivieren',
			'translation.deepLXTranslationWillBeDisabled' => 'Die DeepLX-Übersetzung wird aufgrund von Konfigurationsänderungen deaktiviert',
			'translation.translatedResult' => 'Übersetztes Ergebnis',
			'translation.testSuccess' => 'Test erfolgreich',
			'translation.pleaseFillInDeepLXServerAddress' => 'Bitte die DeepLX-Serveradresse ausfüllen',
			'translation.invalidAPIResponseFormat' => 'Ungültiges API-Antwortformat',
			'translation.translationServiceReturnedError' => 'Der Übersetzungsdienst hat einen Fehler oder ein leeres Ergebnis zurückgegeben',
			'translation.connectionFailed' => 'Verbindung fehlgeschlagen',
			'translation.translationFailed' => 'Übersetzung fehlgeschlagen',
			'translation.aiTranslationFailed' => 'KI-Übersetzung fehlgeschlagen',
			'translation.deeplxTranslationFailed' => 'DeepLX-Übersetzung fehlgeschlagen',
			'translation.aiTranslationTestFailed' => 'Test der KI-Übersetzung fehlgeschlagen',
			'translation.deeplxTranslationTestFailed' => 'Test der DeepLX-Übersetzung fehlgeschlagen',
			'translation.streamingTranslationTimeout' => 'Zeitüberschreitung der Streaming-Übersetzung, Ressourcenbereinigung wird erzwungen',
			'translation.translationRequestTimeout' => 'Zeitüberschreitung der Übersetzungsanfrage',
			'translation.streamingTranslationDataTimeout' => 'Zeitüberschreitung beim Empfang der Streaming-Übersetzungsdaten',
			'translation.dataReceptionTimeout' => 'Zeitüberschreitung beim Datenempfang',
			'translation.streamDataParseError' => 'Fehler beim Analysieren der Stream-Daten',
			'translation.streamingTranslationFailed' => 'Streaming-Übersetzung fehlgeschlagen',
			'translation.fallbackTranslationFailed' => 'Rückfall auf die normale Übersetzung ist ebenfalls fehlgeschlagen',
			'translation.translationSettings' => 'Übersetzungseinstellungen',
			'translation.enableGoogleTranslation' => 'Google-Übersetzung aktivieren',
			'translation.thinking' => 'Denkt nach...',
			'translation.thoughtProcess' => 'Denkprozess',
			'translation.modelCompatibility' => 'Modellkompatibilität',
			'translation.modelCompatibilityDescription' => 'Anfrageparameter für moderne Modelle wie Reasoning-Modelle (o1/o3, DeepSeek-R1, QwQ) anpassen',
			'translation.reasoningModel' => 'Reasoning-Modell',
			'translation.reasoningModelDescription' => 'Für o1/o3, DeepSeek-R1, QwQ usw. Faltet den Prompt in die Benutzernachricht, lässt temperature weg und verwendet max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'max_completion_tokens verwenden',
			'translation.useMaxCompletionTokensDescription' => 'Neuere OpenAI-Endpunkte erfordern max_completion_tokens anstelle des veralteten max_tokens',
			'translation.sendTemperature' => 'Temperature senden',
			'translation.sendTemperatureDescription' => 'Für Modelle deaktivieren, die den Parameter temperature ablehnen (die meisten Reasoning-Modelle)',
			'translation.showReasoningProcess' => 'Denkprozess anzeigen',
			'translation.showReasoningProcessDescription' => 'Das einklappbare Reasoning von Reasoning-Modellen im Übersetzungsdialog anzeigen',
			'translation.provider' => 'Anbieter',
			'translation.providerOpenAI' => 'OpenAI (und kompatibel)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Unterstützt OpenAI (und jeden OpenAI-kompatiblen Endpunkt), Anthropic und Google über das dartantic_ai SDK',
			'translation.baseUrlOptionalHelperText' => 'Optional. Leer lassen, um den Standardendpunkt des Anbieters zu verwenden; ausfüllen für OpenAI-kompatible/Relay-Endpunkte',
			'translation.defaultEndpoint' => 'Standardendpunkt',
			'translation.providerPreset' => 'Anbieter-Voreinstellung',
			'translation.selectProviderPreset' => 'Voreinstellung auswählen',
			'translation.presetCustom' => 'Benutzerdefiniert',
			'translation.presetApplied' => ({required Object name}) => 'Voreinstellung angewendet: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI Reasoning (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude Reasoning (erweitertes Denken)',
			'translation.presetNames.gemini' => 'Google Gemini (nativ)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini Reasoning (Denken)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek Reasoning (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Modellliste abrufen',
			'translation.fetchingModels' => 'Wird abgerufen...',
			'translation.selectModel' => 'Modell auswählen',
			'translation.searchModel' => 'Modell suchen',
			'translation.noModelsFound' => 'Keine Modelle gefunden',
			'bottomNav.video' => 'Video',
			'bottomNav.gallery' => 'Galerie',
			'bottomNav.subscription' => 'Feed',
			'bottomNav.community' => 'Forum',
			'bottomNav.localMedia' => 'Lokal',
			'navigationOrderSettings.title' => 'Navigationsreihenfolge',
			'navigationOrderSettings.customNavigationOrder' => 'Benutzerdefinierte Navigationsreihenfolge',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Ziehen Sie, um die Anzeigereihenfolge der Seiten in der unteren Navigationsleiste und der Seitenleiste anzupassen',
			'navigationOrderSettings.restartRequired' => 'Neustart der App erforderlich',
			'navigationOrderSettings.navigationItemSorting' => 'Sortierung der Navigationselemente',
			'navigationOrderSettings.done' => 'Fertig',
			'navigationOrderSettings.edit' => 'Bearbeiten',
			'navigationOrderSettings.reset' => 'Zurücksetzen',
			'navigationOrderSettings.previewEffect' => 'Vorschau der Wirkung',
			'navigationOrderSettings.bottomNavigationPreview' => 'Vorschau der unteren Navigation:',
			'navigationOrderSettings.sidebarPreview' => 'Vorschau der Seitenleiste:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Zurücksetzen der Navigationsreihenfolge bestätigen',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Möchten Sie die Navigationsreihenfolge wirklich auf die Standardeinstellungen zurücksetzen?',
			'navigationOrderSettings.cancel' => 'Abbrechen',
			'navigationOrderSettings.show' => 'Anzeigen',
			'navigationOrderSettings.hide' => 'Ausblenden',
			'navigationOrderSettings.hidden' => 'Ausgeblendet',
			'navigationOrderSettings.hideHint' => 'Tippen Sie auf das Augensymbol, um Community und lokale Dateien ein- oder auszublenden',
			'navigationOrderSettings.videoDescription' => 'Beliebte Videoinhalte durchsuchen',
			'navigationOrderSettings.galleryDescription' => 'Bilder und Galerien durchsuchen',
			'navigationOrderSettings.subscriptionDescription' => 'Neueste Inhalte von gefolgten Benutzern ansehen',
			'navigationOrderSettings.forumDescription' => 'An Community-Diskussionen teilnehmen',
			'navigationOrderSettings.newsDescription' => 'Offizielle Neuigkeiten, Artikel und Ankündigungen durchsuchen',
			'navigationOrderSettings.communityDescription' => 'Forumdiskussionen sowie offizielle Neuigkeiten, Artikel und Ankündigungen',
			'navigationOrderSettings.localMediaDescription' => 'Auf diesem Gerät gespeicherte Videos und Bilder durchsuchen',
			'news.title' => 'Neuigkeiten',
			'news.newsUpdates' => 'Neuigkeiten',
			'news.articles' => 'Artikel',
			'news.broadcast' => 'Übertragung',
			'news.openInBrowser' => 'Im Browser öffnen',
			'displaySettings.title' => 'Anzeige-Einstellungen',
			'displaySettings.layoutSettings' => 'Layout-Einstellungen',
			'displaySettings.layoutSettingsDesc' => 'Spaltenanzahl und Haltepunkte anpassen',
			'displaySettings.gridLayout' => 'Raster-Layout',
			'displaySettings.navigationOrderSettings' => 'Navigationsreihenfolge',
			'displaySettings.customNavigationOrder' => 'Benutzerdefinierte Navigationsreihenfolge',
			'displaySettings.customNavigationOrderDesc' => 'Passen Sie die Anzeigereihenfolge der Seiten in der unteren Navigationsleiste und der Seitenleiste an',
			'layoutSettings.title' => 'Layout-Einstellungen',
			'layoutSettings.descriptionTitle' => 'Beschreibung der Layout-Konfiguration',
			'layoutSettings.descriptionContent' => 'Die Konfiguration hier bestimmt die Anzahl der Spalten, die in den Video- und Galerielisten angezeigt werden. Sie können den automatischen Modus wählen, damit das System anhand der Bildschirmbreite automatisch anpasst, oder den manuellen Modus, um die Spaltenzahl festzulegen.',
			'layoutSettings.layoutMode' => 'Layout-Modus',
			'layoutSettings.reset' => 'Zurücksetzen',
			'layoutSettings.autoMode' => 'Automatischer Modus',
			'layoutSettings.autoModeDesc' => 'Automatisch anhand der Bildschirmbreite anpassen',
			'layoutSettings.manualMode' => 'Manueller Modus',
			'layoutSettings.manualModeDesc' => 'Feste Spaltenzahl verwenden',
			'layoutSettings.manualSettings' => 'Manuelle Einstellungen',
			'layoutSettings.fixedColumns' => 'Feste Spalten',
			'layoutSettings.columns' => 'Spalten',
			'layoutSettings.breakpointConfig' => 'Konfiguration der Haltepunkte',
			'layoutSettings.add' => 'Hinzufügen',
			'layoutSettings.defaultColumns' => 'Standardspalten',
			'layoutSettings.defaultColumnsDesc' => 'Standardanzeige für große Bildschirme',
			'layoutSettings.previewEffect' => 'Vorschau der Wirkung',
			'layoutSettings.screenWidth' => 'Bildschirmbreite',
			'layoutSettings.addBreakpoint' => 'Haltepunkt hinzufügen',
			'layoutSettings.editBreakpoint' => 'Haltepunkt bearbeiten',
			'layoutSettings.deleteBreakpoint' => 'Haltepunkt löschen',
			'layoutSettings.screenWidthLabel' => 'Bildschirmbreite',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Spalten',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Bitte Breite eingeben',
			'layoutSettings.enterValidWidth' => 'Bitte eine gültige Breite eingeben',
			'layoutSettings.widthCannotExceed9999' => 'Die Breite darf 9999 nicht überschreiten',
			'layoutSettings.breakpointAlreadyExists' => 'Haltepunkt existiert bereits',
			'layoutSettings.enterColumns' => 'Bitte Spaltenzahl eingeben',
			'layoutSettings.enterValidColumns' => 'Bitte eine gültige Spaltenzahl eingeben',
			'layoutSettings.columnsCannotExceed12' => 'Die Spaltenzahl darf 12 nicht überschreiten',
			'layoutSettings.breakpointConflict' => 'Haltepunkt existiert bereits',
			'layoutSettings.confirmResetLayoutSettings' => 'Layout-Einstellungen zurücksetzen',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Möchten Sie alle Layout-Einstellungen wirklich auf die Standardwerte zurücksetzen?\n\nWird wiederhergestellt:\n• Automatischer Modus\n• Standard-Konfiguration der Haltepunkte',
			'layoutSettings.resetToDefaults' => 'Auf Standard zurücksetzen',
			'layoutSettings.confirmDeleteBreakpoint' => 'Haltepunkt löschen',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Möchten Sie den Haltepunkt bei ${width}px wirklich löschen?',
			'layoutSettings.noCustomBreakpoints' => 'Keine benutzerdefinierten Haltepunkte, es werden Standardspalten verwendet',
			'layoutSettings.breakpointRange' => 'Haltepunktbereich',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Bearbeiten',
			'layoutSettings.delete' => 'Löschen',
			'layoutSettings.cancel' => 'Abbrechen',
			'layoutSettings.save' => 'Speichern',
			'mediaPlayer.videoPlayerError' => 'Video-Player-Fehler',
			'mediaPlayer.videoLoadFailed' => 'Video konnte nicht geladen werden',
			'mediaPlayer.videoCodecNotSupported' => 'Videocodec nicht unterstützt',
			'mediaPlayer.networkConnectionIssue' => 'Problem mit der Netzwerkverbindung',
			'mediaPlayer.insufficientPermission' => 'Unzureichende Berechtigung',
			'mediaPlayer.unsupportedVideoFormat' => 'Nicht unterstütztes Videoformat',
			'mediaPlayer.retry' => 'Erneut versuchen',
			'mediaPlayer.externalPlayer' => 'Externer Player',
			'mediaPlayer.detailedErrorInfo' => 'Detaillierte Fehlerinformationen',
			'mediaPlayer.format' => 'Format',
			'mediaPlayer.suggestion' => 'Vorschlag',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Android-Geräte unterstützen das WEBM-Format nur eingeschränkt. Es wird empfohlen, einen externen Player zu verwenden oder eine Player-App herunterzuladen, die WEBM unterstützt',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'Das aktuelle Gerät unterstützt den Codec für dieses Videoformat nicht',
			'mediaPlayer.checkNetworkConnection' => 'Bitte prüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut',
			'mediaPlayer.appMayLackMediaPermission' => 'Der App fehlen möglicherweise die erforderlichen Berechtigungen für die Medienwiedergabe',
			'mediaPlayer.tryOtherVideoPlayer' => 'Bitte versuchen Sie es mit anderen Video-Playern',
			'mediaPlayer.unrecognizedVideoFormat' => 'Nicht erkannte Videodatei',
			_ => null,
		} ?? switch (path) {
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Der Link ist möglicherweise abgelaufen, oder die Antwort war kein Video. Versuchen Sie es erneut oder öffnen Sie es mit einer anderen App.',
			'mediaPlayer.accessDenied' => 'Der Server hat diese Anfrage abgelehnt (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Der Wiedergabelink ist höchstwahrscheinlich abgelaufen. Tippen Sie auf „Wiederholen“, um ihn erneut abzurufen, oder öffnen Sie ihn mit einer anderen App.',
			'mediaPlayer.mute' => 'Stummschalten',
			'mediaPlayer.unmute' => 'Stummschaltung aufheben',
			'mediaPlayer.video' => 'VIDEO',
			'mediaPlayer.serverSelector' => 'CDN-Server-Auswahl',
			'mediaPlayer.serverSelectorDescription' => 'Wählen Sie den Server mit der niedrigsten Latenz für das beste Wiedergabeerlebnis',
			'mediaPlayer.retestSpeed' => 'Geschwindigkeit erneut testen',
			'mediaPlayer.waitingForSpeedTest' => 'Warten auf Geschwindigkeitstest',
			'mediaPlayer.testingSpeed' => 'Geschwindigkeit wird getestet…',
			'mediaPlayer.testFailed' => 'Test fehlgeschlagen',
			'mediaPlayer.loadingServerList' => 'Serverliste wird geladen…',
			'mediaPlayer.noAvailableServers' => 'Keine verfügbaren Server',
			'mediaPlayer.refreshServerList' => 'Serverliste aktualisieren',
			'mediaPlayer.cannotGetSource' => 'Die aktuelle Videoquelle kann nicht abgerufen werden',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Zu Server gewechselt: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'Insgesamt ${count} Server',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Statuscode: ${code}',
			'mediaPlayer.connectionFailed' => 'Verbindung fehlgeschlagen',
			'mediaPlayer.connectionTimeout' => 'Verbindungszeitüberschreitung',
			'mediaPlayer.networkError' => 'Netzwerkfehler',
			'mediaPlayer.sslError' => 'SSL-Zertifikatsfehler',
			'mediaPlayer.testCompleted' => 'Test abgeschlossen',
			'mediaPlayer.local' => 'Lokal',
			'mediaPlayer.unknown' => 'Unbekannt',
			'mediaPlayer.localVideoPathEmpty' => 'Der lokale Videopfad ist leer',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Lokale Videodatei existiert nicht: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Lokales Video kann nicht abgespielt werden: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Videodatei zum Abspielen hierher ziehen',
			'mediaPlayer.supportedFormats' => 'Unterstützte Formate: MP4, MKV, AVI, MOV, WEBM usw.',
			'mediaPlayer.noSupportedVideoFile' => 'Keine unterstützte Videodatei gefunden',
			'mediaPlayer.retryingOpenVideoLink' => 'Öffnen des Videolinks fehlgeschlagen, erneuter Versuch',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Decoder konnte nicht geladen werden: ${event}. Versuchen Sie, in den Player-Einstellungen auf Software-Dekodierung umzuschalten, und rufen Sie die Seite erneut auf',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Fehler beim Laden des Videos: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Wiederholte Wiedergabefehler erkannt. Gehen Sie zu Einstellungen > Diagnose & Feedback, um Protokolle zu exportieren.',
			'mediaPlayer.openSettingsAction' => 'Anzeigen',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Wiedergabehinweis: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Prüfen Sie Ihr Netzwerk; die Wiedergabe kann ruckeln',
			'mediaPlayer.notice.audioTrackUnavailable' => 'Kein Ton verfügbar; das Video läuft weiter',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Auf Software-Dekodierung umgeschaltet; kann mehr Energie verbrauchen',
			'mediaPlayer.notice.videoDecodeProblem' => 'Versuchen Sie eine andere Qualität; das Bild kann Störungen aufweisen',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Exportieren Sie die Protokolle, um wiederkehrende Wiedergabeprobleme zu melden',
			'mediaPlayer.notice.issuesSheetTitle' => 'Wiedergabeprobleme',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => '${count}-mal aufgetreten',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'Bei ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'Keine Probleme aufgezeichnet',
			'mediaPlayer.notice.exportLogsAction' => 'Protokolle exportieren',
			'mediaPlayer.imageLoadFailed' => 'Bild konnte nicht geladen werden',
			'mediaPlayer.unsupportedImageFormat' => 'Nicht unterstütztes Bildformat',
			'mediaPlayer.tryOtherViewer' => 'Bitte versuchen Sie es mit anderen Betrachtern',
			'diagnostics.infoSectionTitle' => 'Diagnoseinformationen',
			'diagnostics.appVersionLabel' => 'App-Version',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Speicherverbrauch: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'Geräteinformationen konnten nicht abgerufen werden',
			'diagnostics.secureStorageLabel' => 'Sicherer Speicher',
			'diagnostics.secureStorageHealthy' => 'Verfügbar',
			'diagnostics.secureStorageRecovered' => 'Durch Zurücksetzen selbst geheilt (vorherige Daten gelöscht)',
			'diagnostics.secureStorageUnavailable' => 'Nicht verfügbar (Anmeldung mit Ersatzverschlüsselung gespeichert)',
			'diagnostics.secureStoragePlatformOptOut' => 'Lokale Verschlüsselung gemäß Plattformrichtlinie (auf macOS wird der Systemschlüsselbund nicht verwendet)',
			'diagnostics.secureStorageDualWrite' => ' (Dual-Write-Schutz aktiv)',
			'diagnostics.schemaHealthLabel' => 'Datenbankschema',
			'diagnostics.schemaHealthOk' => 'OK',
			'diagnostics.schemaHealthRepairedNow' => 'Bei diesem Start vom Sicherheitsnetz repariert (Migration hat nicht gegriffen)',
			'diagnostics.schemaHealthRepairedBefore' => 'Wurde zuvor vom Sicherheitsnetz repariert',
			'diagnostics.logPolicySectionTitle' => 'Protokollrichtlinie',
			'diagnostics.configServiceUnavailable' => 'Der Konfigurationsdienst ist nicht initialisiert. Die Protokollrichtlinie kann nicht angepasst werden.',
			'diagnostics.enableLoggingTitle' => 'Protokollierung aktivieren',
			'diagnostics.enableLoggingSubtitle' => 'Deaktivieren, um keine neuen Protokolle mehr zu schreiben',
			'diagnostics.enableLogPersistenceTitle' => 'Protokollpersistenz aktivieren',
			'diagnostics.enableLogPersistenceSubtitle' => 'Deaktivieren, um Protokolle nur im Speicher zu halten und Schreibvorgänge auf die Festplatte zu stoppen',
			'diagnostics.minLogLevelTitle' => 'Minimale Protokollstufe',
			'diagnostics.minLogLevelSubtitle' => 'Protokolle unterhalb dieser Stufe werden herausgefiltert',
			'diagnostics.maxFileSizeTitle' => 'Größenlimit für einzelne Datei',
			'diagnostics.maxFileSizeSubtitle' => 'Rotieren, wenn die Schwelle erreicht ist',
			'diagnostics.rotatedFileCountTitle' => 'Anzahl rotierter Hauptprotokolldateien',
			'diagnostics.rotatedFileCountSubtitle' => 'Anzahl der aufbewahrten Dateien ohne die aktuelle Datei',
			'diagnostics.hangFileSizeTitle' => 'Größenlimit des Hänger-Protokolls',
			'diagnostics.hangFileSizeSubtitle' => 'Wachstum der hang_events-Datei steuern',
			'diagnostics.hangRotatedFileCountTitle' => 'Anzahl rotierter Hänger-Protokolldateien',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Anzahl der aufbewahrten Dateien für hang_events steuern',
			'diagnostics.healthSectionTitle' => 'Protokollzustand',
			'diagnostics.refreshMetrics' => 'Metriken aktualisieren',
			'diagnostics.toolsSectionTitle' => 'Werkzeuge',
			'diagnostics.privacyNotice' => 'Protokolle können sensible Informationen wie Kontodaten und Anfrageparameter enthalten. Veröffentlichen Sie keine vollständigen Protokolle in Issues; prüfen Sie sie zuerst und senden Sie sie per E-Mail.',
			'diagnostics.exportLogsTitle' => 'Protokolle exportieren',
			'diagnostics.exportLogsSubtitle' => 'Prüfen Sie die privaten Daten, bevor Sie sie an Entwickler senden',
			'diagnostics.viewLogsTitle' => 'Protokolle anzeigen',
			'diagnostics.viewLogsSubtitle' => 'Laufzeitprotokolle in Echtzeit anzeigen',
			'diagnostics.copySupportEmailTitle' => 'Support-E-Mail kopieren',
			'diagnostics.reportIssueTitle' => 'Problem melden',
			'diagnostics.reportIssueSubtitle' => 'Geben Sie Reproduktionsschritte auf GitHub an (hängen Sie keine vollständigen Protokolle an)',
			'diagnostics.healthSummaryUnavailable' => 'Noch keine Daten zum Protokollzustand',
			'diagnostics.healthMetricsUnavailable' => 'Zustandsmetriken wurden noch nicht erfasst',
			'diagnostics.healthNoRiskIndicators' => 'Keine Risikoindikatoren erkannt',
			'diagnostics.healthAlert.flushFailureTitle' => 'Fehler beim Leeren (Flush)',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Protokollschreiben eingeschränkt',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'Dateisenke befindet sich im eingeschränkten Zustand',
			'diagnostics.healthAlert.queueBacklogTitle' => 'Rückstand der Schreibwarteschlange',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'Warteschlangentiefe=${queueDepth} (Schwelle=${threshold}, kann den Speicherverbrauch erhöhen)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Hohe Flush-Latenz',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Zu viele verworfene Protokolle',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'Verworfen=${droppedCount} (Schwelle=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Ratenbegrenzung ausgelöst',
			'diagnostics.healthAlert.exportFailedTitle' => 'Fehler beim Protokollexport',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'Protokolldatei nahe am Größenlimit',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'Dateinutzung=${usagePercent}% (höherer Rotationsdruck auf IO)',
			'diagnostics.toast.logServiceNotInitialized' => 'Der Protokolldienst ist nicht initialisiert',
			'diagnostics.toast.exportSuccess' => 'Protokolle exportiert. Bitte prüfen Sie die privaten Daten, bevor Sie sie per E-Mail senden.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'Export fehlgeschlagen: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'Support-E-Mail kopiert. Fügen Sie sie in Ihr E-Mail-Programm ein und hängen Sie die Protokolle an.',
			'diagnostics.shareSubject' => 'LoveIwara-Diagnoseprotokolle (enthält sensible Daten, mit Vorsicht teilen)',
			'logViewer.title' => 'Protokollanzeige',
			'logViewer.searchHint' => 'Protokolle durchsuchen…',
			'logViewer.emptyState' => 'Keine Protokolle',
			'logViewer.copiedToClipboard' => 'In die Zwischenablage kopiert',
			'crashRecoveryDialog.title' => 'App unerwartet beendet',
			'crashRecoveryDialog.description' => 'In der letzten Sitzung wurde ein unsauberes Beenden festgestellt. Bitte exportieren Sie die Diagnoseprotokolle und senden Sie sie per E-Mail an den Entwickler, damit wir das Problem beheben können.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Letzte Version: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Letzter Start: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Letzte Ausnahme: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'Beim letzten Mal wurde ein UI-Hänger erkannt und automatisch behoben',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'Beim letzten Mal wurde ein mögliches Einfrieren der UI erkannt, das etwa ${stalledMs}ms dauerte',
			'crashRecoveryDialog.exportGuide' => 'Gehen Sie zu Einstellungen > Diagnose & Feedback > Protokolle exportieren.',
			'crashRecoveryDialog.privacyHint' => 'Protokolle können private Daten enthalten. Bitte prüfen Sie sie, bevor Sie sie per E-Mail senden an:',
			'crashRecoveryDialog.issueWarning' => 'Hängen Sie keine vollständigen Protokolle öffentlich an GitHub-Issues an',
			'crashRecoveryDialog.acknowledge' => 'Verstanden',
			'crashRecoveryDialog.supportEmailCopied' => 'E-Mail kopiert',
			'linkInputDialog.title' => 'Link eingeben',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Erkennt mehrere ${webName}-Links intelligent und springt schnell zur entsprechenden Seite in der App (trennen Sie Links mit Leerzeichen vom übrigen Text)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Bitte ${webName}-Link eingeben',
			'linkInputDialog.validatorEmptyLink' => 'Bitte Link eingeben',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'Kein gültiger ${webName}-Link erkannt',
			'linkInputDialog.multipleLinksDetected' => 'Mehrere Links erkannt, bitte einen auswählen:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Kein gültiger ${webName}-Link',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Fehler beim Parsen des Links: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Nicht unterstützter Link',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Dieser Linktyp kann nicht direkt in der App geöffnet werden und muss über einen externen Browser aufgerufen werden.\n\nMöchten Sie diesen Link in einem Browser öffnen?',
			'linkInputDialog.openInBrowser' => 'Im Browser öffnen',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Browser öffnen bestätigen',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'Der folgende Link wird in einem externen Browser geöffnet:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Möchten Sie wirklich fortfahren?',
			'linkInputDialog.browserOpenFailed' => 'Link konnte nicht geöffnet werden',
			'linkInputDialog.unsupportedLink' => 'Nicht unterstützter Link',
			'linkInputDialog.cancel' => 'Abbrechen',
			'linkInputDialog.confirm' => 'Im Browser öffnen',
			'log.logManagement' => 'Protokollverwaltung',
			'log.enableLogPersistence' => 'Protokollpersistenz aktivieren',
			'log.enableLogPersistenceDesc' => 'Protokolle zur Analyse in der Datenbank speichern',
			'log.logDatabaseSizeLimit' => 'Größenlimit der Protokolldatenbank',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Aktuell: ${size}',
			'log.exportCurrentLogs' => 'Aktuelle Protokolle exportieren',
			'log.exportCurrentLogsDesc' => 'Die aktuellen App-Protokolle exportieren, um Entwicklern bei der Diagnose von Problemen zu helfen',
			'log.exportHistoryLogs' => 'Verlaufsprotokolle exportieren',
			'log.exportHistoryLogsDesc' => 'Protokolle innerhalb eines bestimmten Datumsbereichs exportieren',
			'log.exportMergedLogs' => 'Zusammengeführte Protokolle exportieren',
			'log.exportMergedLogsDesc' => 'Zusammengeführte Protokolle innerhalb eines bestimmten Datumsbereichs exportieren',
			'log.showLogStats' => 'Protokollstatistiken anzeigen',
			'log.logExportSuccess' => 'Protokollexport erfolgreich',
			'log.logExportFailed' => ({required Object error}) => 'Protokollexport fehlgeschlagen: ${error}',
			'log.showLogStatsDesc' => 'Statistiken zu verschiedenen Protokolltypen anzeigen',
			'log.logExtractFailed' => ({required Object error}) => 'Protokollstatistiken konnten nicht abgerufen werden: ${error}',
			'log.clearAllLogs' => 'Alle Protokolle löschen',
			'log.clearAllLogsDesc' => 'Alle Protokolldaten löschen',
			'log.confirmClearAllLogs' => 'Löschen bestätigen',
			'log.confirmClearAllLogsDesc' => 'Möchten Sie wirklich alle Protokolldaten löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.',
			'log.clearAllLogsSuccess' => 'Protokoll erfolgreich gelöscht',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Protokolle konnten nicht gelöscht werden: ${error}',
			'log.unableToGetLogSizeInfo' => 'Protokollgrößeninformationen konnten nicht abgerufen werden',
			'log.currentLogSize' => 'Aktuelle Protokollgröße:',
			'log.logCount' => 'Anzahl der Protokolle:',
			'log.logCountUnit' => 'Protokolle',
			'log.logSizeLimit' => 'Größenlimit der Protokolle:',
			'log.usageRate' => 'Nutzungsrate:',
			'log.exceedLimit' => 'Limit überschritten',
			'log.remaining' => 'Verbleibend',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Die aktuelle Protokollgröße wurde überschritten, bitte bereinigen Sie alte Protokolle oder erhöhen Sie das Größenlimit',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'Die aktuelle Protokollgröße ist fast erreicht, bitte bereinigen Sie alte Protokolle',
			'log.cleaningOldLogs' => 'Alte Protokolle werden bereinigt…',
			'log.logCleaningCompleted' => 'Protokollbereinigung abgeschlossen',
			'log.logCleaningProcessMayNotBeCompleted' => 'Der Vorgang der Protokollbereinigung wurde möglicherweise nicht abgeschlossen',
			'log.cleanExceededLogs' => 'Übermäßige Protokolle bereinigen',
			'log.noLogsToExport' => 'Keine Protokolle zum Exportieren',
			'log.exportingLogs' => 'Protokolle werden exportiert…',
			'log.noHistoryLogsToExport' => 'Keine Verlaufsprotokolle zum Exportieren; verwenden Sie die App bitte zunächst eine Weile',
			'log.selectLogDate' => 'Protokolldatum auswählen',
			'log.today' => 'Heute',
			'log.selectMergeRange' => 'Zusammenführungsbereich auswählen',
			'log.selectMergeRangeHint' => 'Bitte wählen Sie den zusammenzuführenden Protokollzeitraum',
			'log.selectMergeRangeDays' => ({required Object days}) => 'Letzte ${days} Tage',
			'log.logStats' => 'Protokollstatistiken',
			'log.todayLogs' => ({required Object count}) => 'Heutige Protokolle: ${count} Protokolle',
			'log.recent7DaysLogs' => ({required Object count}) => 'Protokolle der letzten 7 Tage: ${count} Protokolle',
			'log.totalLogs' => ({required Object count}) => 'Protokolle insgesamt: ${count} Protokolle',
			'log.setLogDatabaseSizeLimit' => 'Größenlimit der Protokolldatenbank festlegen',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Aktuelle Protokollgröße: ${size}',
			'log.warning' => 'Warnung',
			'log.newSizeLimit' => ({required Object size}) => 'Neues Größenlimit: ${size}',
			'log.confirmToContinue' => 'Zur Fortsetzung bestätigen',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Größenlimit der Protokolle auf ${size} festgelegt',
			'emoji.recentlyUsed' => 'Zuletzt',
			'emoji.insertedCount' => ({required Object count}) => '${count} eingefügt',
			'emoji.name' => 'Emoji',
			'emoji.size' => 'Größe',
			'emoji.small' => 'Klein',
			'emoji.medium' => 'Mittel',
			'emoji.large' => 'Groß',
			'emoji.extraLarge' => 'Sehr groß',
			'emoji.copyEmojiLinkSuccess' => 'Emoji-Link kopiert',
			'emoji.preview' => 'Emoji-Vorschau',
			'emoji.library' => 'Emoji-Bibliothek',
			'emoji.noEmojis' => 'Keine Emojis',
			'emoji.clickToAddEmojis' => 'Klicken Sie oben rechts auf die Schaltfläche, um Emojis hinzuzufügen',
			'emoji.addEmojis' => 'Emojis hinzufügen',
			'emoji.imagePreview' => 'Bildvorschau',
			'emoji.imageLoadFailed' => 'Bild konnte nicht geladen werden',
			'emoji.loading' => 'Wird geladen…',
			'emoji.delete' => 'Löschen',
			'emoji.close' => 'Schließen',
			'emoji.deleteImage' => 'Bild löschen',
			'emoji.confirmDeleteImage' => 'Möchten Sie dieses Bild wirklich löschen?',
			'emoji.cancel' => 'Abbrechen',
			'emoji.batchDelete' => 'Stapellöschung',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Möchten Sie die ausgewählten ${count} Bilder wirklich löschen? Dieser Vorgang kann nicht rückgängig gemacht werden.',
			'emoji.deleteSuccess' => 'Erfolgreich gelöscht',
			'emoji.addImage' => 'Bild hinzufügen',
			'emoji.addImageByUrl' => 'Per URL hinzufügen',
			'emoji.addImageUrl' => 'Bild-URL hinzufügen',
			'emoji.imageUrl' => 'Bild-URL',
			'emoji.enterImageUrl' => 'Bitte Bild-URL eingeben',
			'emoji.add' => 'Hinzufügen',
			'emoji.batchImport' => 'Stapelimport',
			'emoji.enterJsonUrlArray' => 'Bitte URL-Array im JSON-Format eingeben:',
			'emoji.formatExample' => 'Formatbeispiel:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Bitte fügen Sie ein URL-Array im JSON-Format ein',
			'emoji.import' => 'Importieren',
			'emoji.importSuccess' => ({required Object count}) => '${count} Bilder erfolgreich importiert',
			'emoji.jsonFormatError' => 'JSON-Formatfehler, bitte Eingabe prüfen',
			'emoji.createGroup' => 'Emoji-Gruppe erstellen',
			'emoji.groupName' => 'Gruppenname',
			'emoji.enterGroupName' => 'Bitte Gruppennamen eingeben',
			'emoji.create' => 'Erstellen',
			'emoji.editGroupName' => 'Gruppennamen bearbeiten',
			'emoji.save' => 'Speichern',
			'emoji.deleteGroup' => 'Gruppe löschen',
			'emoji.confirmDeleteGroup' => 'Möchten Sie diese Emoji-Gruppe wirklich löschen? Alle Bilder in der Gruppe werden ebenfalls gelöscht.',
			'emoji.imageCount' => ({required Object count}) => '${count} Bilder',
			'emoji.selectEmoji' => 'Emoji auswählen',
			'emoji.noEmojisInGroup' => 'Keine Emojis in dieser Gruppe',
			'emoji.goToSettingsToAddEmojis' => 'Gehen Sie zu den Einstellungen, um Emojis hinzuzufügen',
			'emoji.emojiManagement' => 'Emoji-Verwaltung',
			'emoji.manageEmojiGroupsAndImages' => 'Emoji-Gruppen und -Bilder verwalten',
			'emoji.uploadLocalImages' => 'Lokale Bilder hochladen',
			'emoji.uploadingImages' => 'Bilder werden hochgeladen',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Es werden ${count} Bilder hochgeladen, bitte warten…',
			'emoji.doNotCloseDialog' => 'Bitte schließen Sie diesen Dialog nicht',
			'emoji.uploadSuccess' => ({required Object count}) => '${count} Bilder erfolgreich hochgeladen',
			'emoji.uploadFailed' => ({required Object count}) => 'Fehlgeschlagen: ${count}',
			'emoji.uploadFailedMessage' => 'Bild-Upload fehlgeschlagen, bitte prüfen Sie Netzwerkverbindung oder Dateiformat',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Beim Hochladen ist ein Fehler aufgetreten: ${error}',
			'searchFilter.selectField' => 'Feld auswählen',
			'searchFilter.add' => 'Hinzufügen',
			'searchFilter.clear' => 'Leeren',
			'searchFilter.clearAll' => 'Alle löschen',
			'searchFilter.generatedQuery' => 'Generierte Abfrage',
			'searchFilter.copyToClipboard' => 'In die Zwischenablage kopieren',
			'searchFilter.copied' => 'Kopiert',
			'searchFilter.filterCount' => ({required Object count}) => '${count} Filter',
			'searchFilter.filterSettings' => 'Filtereinstellungen',
			'searchFilter.field' => 'Feld',
			'searchFilter.operator' => 'Operator',
			'searchFilter.language' => 'Sprache',
			'searchFilter.value' => 'Wert',
			'searchFilter.dateRange' => 'Datumsbereich',
			'searchFilter.numberRange' => 'Zahlenbereich',
			'searchFilter.from' => 'Von',
			'searchFilter.to' => 'Bis',
			'searchFilter.date' => 'Datum',
			'searchFilter.number' => 'Zahl',
			'searchFilter.boolean' => 'Boolesch',
			'searchFilter.tags' => 'Tags',
			'searchFilter.select' => 'Auswählen',
			'searchFilter.clickToSelectDate' => 'Zum Auswählen des Datums klicken',
			'searchFilter.pleaseEnterValidNumber' => 'Bitte eine gültige Zahl eingeben',
			'searchFilter.pleaseEnterValidDate' => 'Bitte ein gültiges Datumsformat eingeben (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'Der Startwert muss kleiner als der Endwert sein',
			'searchFilter.startDateMustBeBeforeEndDate' => 'Das Startdatum muss vor dem Enddatum liegen',
			'searchFilter.pleaseFillStartValue' => 'Bitte Startwert eingeben',
			'searchFilter.pleaseFillEndValue' => 'Bitte Endwert eingeben',
			'searchFilter.rangeValueFormatError' => 'Format des Bereichswerts fehlerhaft',
			'searchFilter.contains' => 'Enthält',
			'searchFilter.equals' => 'Gleich',
			'searchFilter.notEquals' => 'Ungleich',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Bereich',
			'searchFilter.kIn' => 'Enthält beliebiges',
			'searchFilter.notIn' => 'Enthält kein beliebiges',
			'searchFilter.username' => 'Benutzername',
			'searchFilter.nickname' => 'Spitzname',
			'searchFilter.registrationDate' => 'Registrierungsdatum',
			'searchFilter.description' => 'Beschreibung',
			'searchFilter.title' => 'Titel',
			'searchFilter.body' => 'Text',
			'searchFilter.author' => 'Autor',
			'searchFilter.publishDate' => 'Veröffentlichungsdatum',
			'searchFilter.private' => 'Privat',
			'searchFilter.duration' => 'Dauer (Sekunden)',
			'searchFilter.likes' => 'Likes',
			'searchFilter.views' => 'Aufrufe',
			'searchFilter.comments' => 'Kommentare',
			'searchFilter.rating' => 'Bewertung',
			'searchFilter.imageCount' => 'Bildanzahl',
			'searchFilter.videoCount' => 'Videoanzahl',
			'searchFilter.createDate' => 'Erstellungsdatum',
			'searchFilter.content' => 'Inhalt',
			'searchFilter.all' => 'Alle',
			'searchFilter.adult' => 'Erwachsene',
			'searchFilter.general' => 'Allgemein',
			'searchFilter.yes' => 'Ja',
			'searchFilter.no' => 'Nein',
			'searchFilter.users' => 'Nutzer',
			'searchFilter.videos' => 'Videos',
			'searchFilter.images' => 'Bilder',
			'searchFilter.posts' => 'Beiträge',
			'searchFilter.forumThreads' => 'Forum-Threads',
			'searchFilter.forumPosts' => 'Forumsbeiträge',
			'searchFilter.playlists' => 'Wiedergabelisten',
			'searchFilter.sortTypes.relevance' => 'Relevanz',
			'searchFilter.sortTypes.latest' => 'Neueste',
			'searchFilter.sortTypes.views' => 'Aufrufe',
			'searchFilter.sortTypes.likes' => 'Likes',
			'searchFilter.drawerSubtitle' => 'Änderungen werden sofort übernommen',
			'firstTimeSetup.welcome.title' => 'Willkommen',
			'firstTimeSetup.welcome.subtitle' => 'Beginnen wir mit Ihrer personalisierten Einrichtung',
			'firstTimeSetup.welcome.description' => 'Nur wenige Schritte, um das beste Erlebnis für Sie abzustimmen',
			'firstTimeSetup.basic.title' => 'Grundeinstellungen',
			'firstTimeSetup.basic.subtitle' => 'Personalisieren Sie Ihr Erlebnis',
			'firstTimeSetup.basic.description' => 'Wählen Sie die Einstellungen, die zu Ihnen passen',
			'firstTimeSetup.network.title' => 'Netzwerkeinstellungen',
			'firstTimeSetup.network.subtitle' => 'Netzwerkoptionen konfigurieren',
			'firstTimeSetup.network.description' => 'Passen Sie die Einstellungen an Ihre Netzwerkumgebung an',
			'firstTimeSetup.network.tip' => 'Nach erfolgreicher Konfiguration ist ein Neustart erforderlich, damit die Änderungen wirksam werden',
			'firstTimeSetup.theme.title' => 'Design-Einstellungen',
			'firstTimeSetup.theme.subtitle' => 'Wählen Sie Ihr bevorzugtes Erscheinungsbild',
			'firstTimeSetup.theme.description' => 'Personalisieren Sie Ihr visuelles Erlebnis',
			'firstTimeSetup.player.title' => 'Player-Einstellungen',
			'firstTimeSetup.player.subtitle' => 'Wiedergabesteuerung konfigurieren',
			'firstTimeSetup.player.description' => 'Legen Sie schnell häufig verwendete Wiedergabeeinstellungen fest',
			'firstTimeSetup.spatial.title' => 'Räumliche Wiedergabe',
			'firstTimeSetup.spatial.subtitle' => 'Ansehen und Durchsuchen auf dem Headset',
			'firstTimeSetup.spatial.description' => 'Auf dem Headset erscheinen Videos und Galerien im Raum um Sie herum statt in diesem schwebenden Fenster',
			'firstTimeSetup.completion.title' => 'Einrichtung abschließen',
			'firstTimeSetup.completion.subtitle' => 'Sie sind bereit, Ihre Reise zu beginnen',
			'firstTimeSetup.completion.description' => 'Bitte lesen Sie die zugehörigen Vereinbarungen und stimmen Sie ihnen zu',
			'firstTimeSetup.completion.agreementTitle' => 'Nutzungsvereinbarung und Community-Regeln',
			'firstTimeSetup.completion.agreementDesc' => 'Bevor Sie diese App verwenden, lesen Sie bitte sorgfältig unsere Nutzungsvereinbarung und die Community-Regeln und stimmen Sie ihnen zu. Diese Bedingungen helfen, eine gute Umgebung zu erhalten.',
			'firstTimeSetup.completion.checkboxTitle' => 'Ich habe die Nutzungsvereinbarung und die Community-Regeln gelesen und stimme ihnen zu',
			'firstTimeSetup.completion.checkboxSubtitle' => 'Wenn Sie nicht zustimmen, können Sie die App nicht verwenden',
			'firstTimeSetup.common.settingsChangeableTip' => 'Diese Einstellungen können jederzeit in den Einstellungen geändert werden',
			'firstTimeSetup.common.previousStep' => 'Vorheriger Schritt',
			'firstTimeSetup.common.nextStep' => 'Nächster Schritt',
			'firstTimeSetup.common.finishSetup' => 'Einrichtung abschließen',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Bitte stimmen Sie zuerst der Nutzungsvereinbarung und den Community-Regeln zu',
			'proxyHelper.systemProxyDetected' => 'Systemproxy erkannt',
			'proxyHelper.copied' => 'Kopiert',
			'proxyHelper.copy' => 'Kopieren',
			'tagSelector.selectTags' => 'Tags auswählen',
			'tagSelector.clickToSelectTags' => 'Klicken Sie, um Tags auszuwählen',
			'tagSelector.addTag' => 'Tag hinzufügen',
			'tagSelector.removeTag' => 'Tag entfernen',
			'tagSelector.deleteTag' => 'Tag löschen',
			'tagSelector.usageInstructions' => 'Fügen Sie zuerst Tags hinzu und klicken Sie dann, um aus vorhandenen Tags auszuwählen',
			'tagSelector.usageInstructionsTooltip' => 'Anleitung',
			'tagSelector.addTagTooltip' => 'Tag hinzufügen',
			'tagSelector.removeTagTooltip' => 'Tag entfernen',
			'tagSelector.cancelSelection' => 'Auswahl abbrechen',
			'tagSelector.selectAll' => 'Alle auswählen',
			'tagSelector.cancelSelectAll' => 'Alle auswählen abbrechen',
			'tagSelector.delete' => 'Löschen',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Echtzeit-Video-Upscaling und Rauschunterdrückung zur Verbesserung der Qualität von Animationsvideos',
			'anime4k.settings' => 'Anime4K-Einstellungen',
			'anime4k.preset' => 'Anime4K-Preset',
			'anime4k.disable' => 'Anime4K deaktivieren',
			'anime4k.disableDescription' => 'Video-Verbesserungseffekte deaktivieren',
			'anime4k.highQualityPresets' => 'Presets hoher Qualität',
			'anime4k.fastPresets' => 'Schnelle Presets',
			'anime4k.litePresets' => 'Leichte Presets',
			'anime4k.moreLitePresets' => 'Noch leichtere Presets',
			'anime4k.customPresets' => 'Eigene Presets',
			'anime4k.presetGroups.highQuality' => 'Hohe Qualität',
			'anime4k.presetGroups.fast' => 'Schnell',
			'anime4k.presetGroups.lite' => 'Leicht',
			'anime4k.presetGroups.moreLite' => 'Leichter',
			'anime4k.presetGroups.custom' => 'Eigene',
			'anime4k.presetDescriptions.mode_a_hq' => 'Geeignet für die meisten 1080p-Animationen, insbesondere bei Unschärfe, Resampling- und Kompressionsartefakten. Bietet die höchste wahrgenommene Qualität.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Geeignet für Animationen mit leichter Unschärfe oder durch Skalierung verursachtem Ringing. Kann Ringing und Aliasing wirksam reduzieren.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Geeignet für hochwertige Quellen (z. B. native 1080p-Animationen oder Filme). Unterdrückt Rauschen und bietet den höchsten PSNR.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Erweiterte Version von Modus A, bietet höchste wahrgenommene Qualität und kann fast alle degradierten Linien rekonstruieren. Kann Überschärfung oder Ringing erzeugen.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Erweiterte Version von Modus B, bietet höhere wahrgenommene Qualität, optimiert Linien weiter und reduziert Artefakte.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Version von Modus C mit verbesserter wahrgenommener Qualität, hält hohen PSNR und versucht, einige Liniendetails zu rekonstruieren.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Schnelle Version von Modus A, gleicht Qualität und Leistung aus, geeignet für die meisten 1080p-Animationen.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Schnelle Version von Modus B, für geringe Artefakte und Ringing mit geringerem Aufwand.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Schnelle Version von Modus C, für schnelle Rauschunterdrückung und Skalierung hochwertiger Quellen.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Schnelle Version von Modus A+A, für höhere wahrgenommene Qualität auf leistungsbegrenzten Geräten.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Schnelle Version von Modus B+B, bietet verbesserte Linienreparatur und Artefaktverarbeitung für leistungsbegrenzte Geräte.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Schnelle Version von Modus C+A, verarbeitet hochwertige Quellen schnell und bietet leichte Linienreparatur.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Ultraschnelles x2-Upscaling nur mit dem schnellsten CNN-Modell, keine Reparatur und Rauschunterdrückung, minimaler Leistungsaufwand.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Schnelles Upscaling und Deblurring mit herkömmlichen Nicht-CNN-Algorithmen, besser als Standard-Player-Algorithmen bei sehr geringem Leistungsaufwand.',
			'anime4k.presetDescriptions.restore_s_only' => 'Nur Reparatur mit dem schnellsten CNN-Modell, kein Upscaling. Geeignet für Wiedergabe in nativer Auflösung, wenn Sie die Qualität verbessern möchten.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Schnelle Rauschunterdrückung mit herkömmlicher bilateraler Filterung, extrem schnell, geeignet für leichtes Rauschen.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Schnelles Upscaling mit herkömmlichen Algorithmen, sehr geringer Leistungsaufwand, besser als die Player-Standardeinstellungen.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Modus A (Schnell) + Linienabdunklung, fügt zusätzlich zur schnellen Variante A eine Linienabdunklung für kräftigere, stilisierte Linien hinzu.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Modus A (HQ) + Linienverdünnung, fügt zusätzlich zur hochwertigen Variante A eine Linienverdünnung für ein feineres Erscheinungsbild hinzu.',
			'anime4k.presetNames.mode_a_hq' => 'Mode A (HQ)',
			'anime4k.presetNames.mode_b_hq' => 'Mode B (HQ)',
			'anime4k.presetNames.mode_c_hq' => 'Mode C (HQ)',
			'anime4k.presetNames.mode_a_a_hq' => 'Mode A+A (HQ)',
			'anime4k.presetNames.mode_b_b_hq' => 'Mode B+B (HQ)',
			'anime4k.presetNames.mode_c_a_hq' => 'Mode C+A (HQ)',
			'anime4k.presetNames.mode_a_fast' => 'Mode A (Fast)',
			'anime4k.presetNames.mode_b_fast' => 'Mode B (Fast)',
			'anime4k.presetNames.mode_c_fast' => 'Mode C (Fast)',
			'anime4k.presetNames.mode_a_a_fast' => 'Mode A+A (Fast)',
			'anime4k.presetNames.mode_b_b_fast' => 'Mode B+B (Fast)',
			'anime4k.presetNames.mode_c_a_fast' => 'Mode C+A (Fast)',
			'anime4k.presetNames.upscale_only_s' => 'CNN-Upscaling (Ultraschnell)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Upscaling & Deblurring (Schnell)',
			'anime4k.presetNames.restore_s_only' => 'Restaurierung (Ultraschnell)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Bilaterale Rauschunterdrückung (Ultraschnell)',
			'anime4k.presetNames.upscale_non_cnn' => 'Nicht-CNN-Upscaling (Ultraschnell)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Modus A (Schnell) + Linienabdunklung',
			'anime4k.presetNames.mode_a_hq_thin' => 'Modus A (HQ) + Linienverdünnung',
			'anime4k.performanceTip' => '💡 Tipp: Wählen Sie passende Presets je nach Geräteleistung. Für leistungsschwache Geräte empfiehlt sich die Verwendung leichter Presets.',
			'anime4k.compatibilityTip' => '⚠️ Einige mobile GPUs (z. B. Kirin 980 / Mali-G76) können keine benutzerdefinierten Shader rendern. Wenn das Bild schwarz wird, der Ton aber weiterläuft, deaktivieren Sie Anime4K hier.',
			'anime4k.autoDisabledOnRenderFailure' => 'Die GPU Ihres Geräts konnte den Anime4K-Shader nicht rendern, daher wurde er automatisch deaktiviert.',
			'siteMode.title' => 'Website-Modus',
			'siteMode.mainSite' => 'Main',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Aktuell ${currentSite} · Tippen, um zu ${nextSite} zu wechseln',
			'siteMode.dialogTitle' => 'Website-Modus wechseln',
			'siteMode.dialogDescription' => 'Beim Wechseln wird die gesamte App neu geladen und zuvor geladene Listen und Seitenzustände werden zurückgesetzt.',
			'siteMode.chooseLinkTargetTitle' => 'Ziel-Website wählen',
			'siteMode.chooseLinkTargetDescription' => 'Dieser Link enthält keine Domain. Bitte wählen Sie, ob er in Main oder AI geöffnet werden soll.',
			'siteMode.chooseLinkTargetHint' => 'Nach dem Öffnen verwenden diese Seite und ihre nachfolgenden Detailanfragen weiterhin die ausgewählte Website.',
			'siteMode.alreadyUsing' => 'Sie verwenden diesen Website-Modus bereits.',
			'siteMode.openInSite' => ({required Object site}) => 'In ${site} öffnen',
			'siteMode.confirmUsing' => ({required Object site}) => 'Nach der Bestätigung verwenden zukünftige Anfragen den Modus ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Zu ${site} gewechselt. Die App wurde neu geladen.',
			'savedSearchConfig.title' => 'Gespeicherte Filter',
			'savedSearchConfig.empty' => 'Noch keine gespeicherten Filter',
			'savedSearchConfig.saveTooltip' => 'Aktuellen Filter speichern',
			'savedSearchConfig.namePromptTitle' => 'Filter speichern',
			'savedSearchConfig.nameLabel' => 'Name',
			'savedSearchConfig.nameHint' => 'Namen eingeben',
			'savedSearchConfig.saveSuccess' => 'Filter gespeichert',
			'savedSearchConfig.deleteSuccess' => 'Filter entfernt',
			'savedSearchConfig.addCurrent' => 'Aktuellen Filter speichern',
			'savedSearchConfig.reorderHint' => 'Zum Umsortieren lange drücken und ziehen',
			'savedSearchConfig.rename' => 'Umbenennen',
			'savedSearchConfig.unnamed' => 'Unbenannt',
			'savedSearchConfig.noConditions' => 'Alle Inhalte (kein Filter)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} Tags',
			'savedSearch.title' => 'Gespeicherte Suchen',
			'savedSearch.empty' => 'Noch keine gespeicherten Suchen',
			'savedSearch.saveTooltip' => 'Aktuelle Suche speichern',
			'savedSearch.namePromptTitle' => 'Suche speichern',
			'savedSearch.nameLabel' => 'Name',
			'savedSearch.nameHint' => 'Namen eingeben',
			'savedSearch.saveSuccess' => 'Suche gespeichert',
			'savedSearch.deleteSuccess' => 'Suche entfernt',
			'savedSearch.addCurrent' => 'Aktuelle Suche speichern',
			'savedSearch.reorderHint' => 'Zum Umsortieren lange drücken und ziehen',
			'savedSearch.rename' => 'Umbenennen',
			'savedSearch.noKeyword' => '(Kein Stichwort)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} Filter',
			'defaultBlacklistReminder.title' => 'Standard-Tag-Sperrliste erkannt',
			'defaultBlacklistReminder.content' => 'Ihr Konto verwendet noch die Tag-Sperrliste, die die Website automatisch auf jedes neue Konto anwendet. Möchten Sie sie überprüfen und verwalten?',
			'defaultBlacklistReminder.goManage' => 'Verwalten',
			'defaultBlacklistReminder.dismiss' => 'Nicht jetzt',
			'colorVisionAssist.title' => 'Farbseh-Unterstützung',
			'colorVisionAssist.description' => 'Korrigiert Videofarben für farbenblindheitsbeeinträchtigte Zuschauer, kann zusammen mit Anime4K verwendet werden',
			'colorVisionAssist.galleryDescription' => 'Korrigiert die Bildfarben der Galerie für farbenblindheitsbeeinträchtigte Zuschauer (unabhängig vom Player-Schalter)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Korrigiert die Bildfarben der Galerie für farbenblindheitsbeeinträchtigte Zuschauer. Gilt nur für den 2D-Betrachter in diesem Bereich – Bilder auf dem räumlichen Bildschirm werden nativ gerendert und durchlaufen diesen Filter nicht',
			'colorVisionAssist.disable' => 'Aus',
			'colorVisionAssist.disableDescription' => 'Keine Farbkorrektur',
			'colorVisionAssist.protanopia' => 'Rot-Unterstützung (Protanopie)',
			'colorVisionAssist.protanopiaDescription' => 'Für Protanopie – Schwierigkeiten, Rot zu unterscheiden',
			'colorVisionAssist.deuteranopia' => 'Grün-Unterstützung (Deuteranopie)',
			'colorVisionAssist.deuteranopiaDescription' => 'Für Deuteranopie – Schwierigkeiten, Grün zu unterscheiden',
			'colorVisionAssist.tritanopia' => 'Blau-Unterstützung (Tritanopie)',
			'colorVisionAssist.tritanopiaDescription' => 'Für Tritanopie – Schwierigkeiten, Blau und Gelb zu unterscheiden',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} angewendet, wirkt sofort',
			'colorVisionAssist.disabledToast' => 'Farbseh-Unterstützung deaktiviert',
			'externalPlayer.title' => 'Mit anderer App öffnen',
			'externalPlayer.description' => 'Übergeben Sie das aktuelle Video an einen anderen Player auf diesem Gerät, z. B. Skybox oder Pegasus auf einem VR-Headset oder MX Player und VLC auf einem Telefon',
			'externalPlayer.openWithOtherApp' => 'Andere App wählen',
			'externalPlayer.openWithOtherAppDescription' => 'Systemauswahl anzeigen und einen Player zum Übernehmen wählen',
			'externalPlayer.openWithSystemPlayer' => 'Im Standard-Player öffnen',
			'externalPlayer.openWithSystemPlayerDescription' => 'An die Standard-Video-App des Systems übergeben',
			'externalPlayer.copyLink' => 'Videolink kopieren',
			'externalPlayer.copyLinkDescription' => 'Für Player, die nur eine URL einfügen können, z. B. Skybox oder DeoVR',
			'externalPlayer.linkCopied' => 'Videolink kopiert',
			'externalPlayer.sourceLocal' => 'Lokale Datei',
			'externalPlayer.sourceOnline' => 'Direkter Link',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Direkter Link · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'Direkte Links laufen ab, daher kann ein externer Player mittendrin abbrechen. Zuerst herunterzuladen ist der zuverlässige Weg.',
			'externalPlayer.vrPlayerHint' => 'Wenn Ihr VR-Player in der Auswahl fehlt, verwenden Sie „Videolink kopieren“ und fügen Sie ihn in diesem Player ein.',
			'externalPlayer.noHandler' => 'Keine App auf diesem Gerät kann das Video öffnen',
			_ => null,
		} ?? switch (path) {
			'externalPlayer.handoffFailed' => ({required Object message}) => 'Übergabe fehlgeschlagen: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'Übergabe fehlgeschlagen',
			'externalPlayer.sourceUnavailable' => 'Die aktuelle Videoadresse konnte nicht abgerufen werden, bitte erneut versuchen',
			'externalPlayer.localFileMissing' => 'Die lokale Datei existiert nicht mehr',
			'externalPlayer.handedOff' => 'An den externen Player übergeben',
			'externalPlayer.desktopSectionTitle' => 'Externe Player',
			'externalPlayer.managePlayers' => 'Externe Player verwalten',
			'externalPlayer.managePlayersDescWindows' => 'PCVR-Player wie HereSphere, DeoVR und Whirligig sind nicht die Standard-App des Systems. Richten Sie dies auf ihre .exe aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.',
			'externalPlayer.managePlayersDescMac' => 'Richten Sie dies auf Player wie IINA, VLC oder mpv aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.',
			'externalPlayer.managePlayersDescLinux' => 'Richten Sie dies auf Player wie mpv, VLC oder Celluloid aus, und Sie können das aktuelle Video direkt aus dem Player übergeben.',
			'externalPlayer.pickExecutableHintWindows' => 'Wählen Sie die Haupt-.exe im Installationsordner des Players, z. B. HereSphere.exe oder vlc.exe. Desktop-Verknüpfungen (.lnk) funktionieren nicht.',
			'externalPlayer.pickExecutableHintMac' => 'Wählen Sie die .app des Players in „Programme“, z. B. IINA.app – die tatsächliche Programmdatei darin wird für Sie ermittelt.',
			'externalPlayer.pickExecutableHintLinux' => 'Wählen Sie die Programmdatei des Players, z. B. /usr/bin/mpv. Mit „which mpv“ finden Sie heraus, wo sie liegt.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'Nach der Konfiguration erscheint er als eigener Eintrag unter „Mit anderer App öffnen“ auf der Player-Seite. Häufige: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'Keine installierten Player gefunden. Benutzerdefinierte Installationsordner und portable Versionen können nicht erkannt werden – verwenden Sie „Player hinzufügen“, um selbst einen anzugeben.',
			'externalPlayer.detectNothingNew' => 'Keine neuen Player gefunden; alles Installierte ist bereits in der Liste',
			'externalPlayer.detectFailed' => 'Erkennung fehlgeschlagen – verwenden Sie „Player hinzufügen“, um selbst einen anzugeben',
			'externalPlayer.advancedOptions' => 'Erweitert',
			'externalPlayer.playerNameHint' => 'Leer lassen, um den Dateinamen zu verwenden',
			'externalPlayer.executablePathRequired' => 'Wählen Sie zuerst die Programmdatei des Players',
			'externalPlayer.playerCount' => ({required Object count}) => '${count} konfiguriert',
			'externalPlayer.noPlayerConfigured' => 'Noch kein externer Player konfiguriert',
			'externalPlayer.autoDetect' => 'Automatisch erkennen',
			'externalPlayer.detecting' => 'Wird erkannt…',
			'externalPlayer.detectFound' => ({required Object count}) => '${count} Player gefunden',
			'externalPlayer.detectNothingFound' => 'Keine neuen Player gefunden, fügen Sie einen manuell hinzu',
			'externalPlayer.autoDetectedTag' => 'erkannt',
			'externalPlayer.addPlayer' => 'Player hinzufügen',
			'externalPlayer.editPlayer' => 'Player bearbeiten',
			'externalPlayer.playerName' => 'Name',
			'externalPlayer.executablePath' => 'Programmdatei',
			'externalPlayer.browse' => 'Durchsuchen',
			'externalPlayer.argumentTemplate' => 'Startargumente',
			'externalPlayer.argumentTemplateHint' => 'Verwenden Sie {input} für den Videopfad oder die URL. Leer lassen, um sie als einziges Argument zu übergeben.',
			'externalPlayer.nameAndPathRequired' => 'Name und Programmdatei sind beide erforderlich',
			'externalPlayer.testLaunch' => 'Teststart',
			'externalPlayer.testLaunched' => 'Player gestartet',
			'externalPlayer.testFailed' => 'Start fehlgeschlagen, prüfen Sie den Pfad der Programmdatei',
			'externalPlayer.executableMissing' => 'Programmdatei nicht gefunden',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'In ${name} öffnen',
			'externalPlayer.managePlayersEntry' => 'Externe Player verwalten…',
			'watchLater.title' => 'Später ansehen',
			'watchLater.addToWatchLater' => 'Später ansehen',
			'watchLater.removeFromWatchLater' => 'Aus „Später ansehen“ entfernen',
			'watchLater.addedToWatchLater' => 'Zu „Später ansehen“ hinzugefügt',
			'watchLater.alreadyInWatchLater' => 'Bereits in „Später ansehen“',
			'watchLater.removedFromWatchLater' => 'Aus „Später ansehen“ entfernt',
			'watchLater.removedCount' => ({required Object count}) => '${count} Elemente entfernt',
			'watchLater.viewWatchLaterList' => 'Liste anzeigen',
			'watchLater.addFailed' => 'Hinzufügen zu „Später ansehen“ fehlgeschlagen',
			'watchLater.invalidItem' => 'Nicht verfügbar',
			'watchLater.clearWatched' => 'Angesehenes löschen',
			'watchLater.watchedCleared' => ({required Object count}) => '${count} angesehene Elemente gelöscht',
			'watchLater.noWatchedToClear' => 'Nichts Angesehenes zum Löschen',
			'watchLater.emptyVideo' => 'Noch keine Videos in „Später ansehen“',
			'watchLater.emptyGallery' => 'Noch keine Galerien in „Später ansehen“',
			'watchLater.filterAll' => 'Alle',
			'watchLater.filterUnwatched' => 'Nicht angesehen',
			'watchLater.sortRecentlyAdded' => 'Zuletzt hinzugefügt',
			'watchLater.sortEarliestAdded' => 'Zuerst hinzugefügt',
			'watchLater.watched' => 'Angesehen',
			'watchLater.playlistLoadFailed' => 'Wiedergabelisten konnten nicht geladen werden',
			'watchLater.noPlaylists' => 'Noch keine Wiedergabelisten',
			'watchLater.undo' => 'Rückgängig',
			'watchLater.clearWatchedConfirm' => 'Alles löschen, was Sie in diesem Tab bereits angesehen haben? Dies kann nicht rückgängig gemacht werden.',
			'watchLater.emptyUnwatchedVideo' => 'Hier gibt es nichts mehr anzuschauen',
			'watchLater.emptyUnwatchedGallery' => 'Hier gibt es nichts mehr anzusehen',
			'watchLater.queueLoadFailed' => 'Laden fehlgeschlagen, zum Wiederholen tippen',
			'mediaMenu.like' => 'Gefällt mir',
			'mediaMenu.unlike' => 'Gefällt mir nicht mehr',
			'mediaMenu.viewAuthor' => 'Autor ansehen',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} Ordner',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} Playlists',
			'mediaMenu.downloaded' => 'Heruntergeladen',
			'mediaPreview.preview' => 'Vorschau',
			'mediaPreview.openDetail' => 'Öffnen',
			'mediaPreview.moreActions' => 'Weitere Aktionen',
			'mediaPreview.previousImage' => 'Vorheriges Bild',
			'mediaPreview.nextImage' => 'Nächstes Bild',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} Bilder',
			'playbackQueue.upNext' => 'Als Nächstes',
			'playbackQueue.sourceTab' => 'Quelle',
			'playbackQueue.emptyQueue' => 'Nichts Abspielbares in dieser Warteschlange',
			'playbackQueue.emptyGalleryQueue' => 'Keine Galerien in dieser Warteschlange',
			'playbackQueue.nowPlaying' => 'Wird abgespielt',
			'playbackQueue.myPlaylists' => 'Meine Wiedergabelisten',
			'playbackQueue.authorPlaylists' => 'Wiedergabelisten des Autors',
			'playbackQueue.openQueue' => 'Als Nächstes',
			'playbackQueue.continueInQueue' => 'Weiter aus der aktuellen Warteschlange abspielen',
			'playbackQueue.continueInQueueSubtitle' => 'Spielt automatisch das nächste Element ab; deaktiviert „Wiederholen nach Ende“',
			'playbackQueue.repeatDisabledByQueue' => 'Deaktiviert, solange „Weiter aus der aktuellen Warteschlange abspielen“ aktiv ist',
			'playbackQueue.playNext' => 'Als Nächstes abspielen',
			'playbackQueue.queueEnded' => 'Dies ist das letzte Element in der Warteschlange',
			'playbackQueue.playNextHint' => 'Tippen, um das nächste Element abzuspielen, lange drücken, um „Als Nächstes“ zu öffnen',
			'playbackQueue.authorVideos' => 'Videos des Autors',
			'playbackQueue.authorGalleries' => 'Galerien des Autors',
			'playbackQueue.favoriteFolders' => 'Favoriten-Ordner',
			'playbackQueue.localFiles' => 'Auf diesem Gerät',
			'playbackQueue.currentFolder' => 'Ordner dieser Datei',
			'playbackQueue.playThisFolder' => 'Video-Warteschlange dieses Ordners anzeigen',
			'playbackQueue.browseThisFolder' => 'Galerie-Warteschlange dieses Ordners anzeigen',
			'playbackQueue.downloads' => 'Heruntergeladen',
			'playbackQueue.otherPlaylists' => 'Wiedergabelisten anderer Nutzer',
			'playbackQueue.nothingHere' => 'Hier ist nichts',
			'vrFormat.playInSpace' => 'Im räumlichen Player abspielen',
			'vrFormat.handingOff' => 'Übergabe an den Raum…',
			'vrFormat.title' => 'Wiedergabemodus',
			'vrFormat.spatialSectionTitle' => 'Räumliche Wiedergabe',
			'vrFormat.spatialSectionDesc' => 'Auf dem Headset wird ein Video nicht in diesem Bedienfeld dargestellt — der räumliche Player zeigt es auf einem Bildschirm im Raum.',
			'vrFormat.spatialPanelEntry' => 'Räumliches Bedienfeld',
			'vrFormat.spatialPanelEntryDesc' => 'Bildschirmabstand, Größe und Krümmung, die Hintergrundumgebung sowie Geschwindigkeit, Wiederholung und automatisches Ausblenden befinden sich alle im räumlichen Bedienfeld.',
			'vrFormat.spatialGuideEntry' => 'Anleitung zur Headset-Steuerung',
			'vrFormat.spatialGuideEntryDesc' => 'Controller-Tasten, Greifen des Bildschirms, Stick-Spulen und Umblättern',
			'vrFormat.spatialFlatOmitted' => 'Touch-Gesten, Bildverbesserung und die Audio-/Videoparameter gelten nur für den 2D-Player; der räumliche Player läuft auf einer anderen Engine und wird hier daher nicht aufgeführt.',
			'vrFormat.spatialGallerySectionTitle' => 'Räumliche Galerie',
			'vrFormat.spatialGalleryPanelDesc' => 'Diashow-Intervall, Wiederholung einzelner Clips und Bildschirmkrümmung werden alle im räumlichen Bedienfeld eingestellt.',
			'vrFormat.autoEnterGallery' => 'Galeriebilder in der räumlichen Galerie öffnen',
			'vrFormat.autoEnterGalleryDesc' => 'In Quest öffnet das Tippen auf ein Bild die gesamte Galerie auf dem schwebenden Bildschirm mit Filmstreifen, Diashow und Controller-Blättern statt des Betrachters in diesem Bedienfeld.',
			'vrFormat.panelSettings' => 'Bedienfeld & Hintergrund',
			'vrFormat.panelSettingsDesc' => 'Wie weit dieses App-Bedienfeld entfernt ist und wie viel von Ihrem Raum dahinter sichtbar ist',
			'vrFormat.panelDistance' => 'Abstand des Bedienfelds',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Platzierung zurücksetzen',
			'vrFormat.panelResetBackground' => 'Auf Standard zurücksetzen',
			'vrFormat.panelBackground' => 'Transparenz des Hintergrunds',
			'vrFormat.panelBackgroundHint' => '0 %: schwarze Umgebung · 100 %: Ihr echter Raum mit Umgebungslicht',
			'vrFormat.panelUnavailable' => 'Das Bedienfeld ist derzeit nicht platziert — versuchen Sie es gleich noch einmal',
			'vrFormat.desc' => 'Wählen Sie die Geometrie, mit der dieses Video abgespielt werden soll. Die Website liefert diese Information nicht, daher wählt die automatische Erkennung nur einen Ausgangspunkt — Ihre Wahl entscheidet.',
			'vrFormat.sectionFlat' => 'Flach',
			'vrFormat.sectionStereo' => 'Flaches 3D',
			'vrFormat.sectionPanorama' => 'VR-Panorama',
			'vrFormat.flat' => 'Normales Video',
			'vrFormat.flatDesc' => 'Unverändert abspielen, keine Neuzuordnung',
			'vrFormat.flatSideBySide' => 'Side-by-Side-3D',
			'vrFormat.flatSideBySideDesc' => 'Ein Auge pro Hälfte, links und rechts; zeigt das linke Auge und stellt dessen Seitenverhältnis wieder her',
			'vrFormat.flatTopBottom' => 'Over-Under-3D',
			'vrFormat.flatTopBottomDesc' => 'Ein Auge pro Hälfte, oben und unten; zeigt die obere Hälfte und stellt deren Seitenverhältnis wieder her',
			'vrFormat.vr180SideBySide' => 'VR180 Side-by-Side',
			'vrFormat.vr180SideBySideDesc' => 'Hemisphärisches Panorama mit beiden Augen — die häufigste VR-Quelle',
			'vrFormat.vr180Mono' => 'VR180 Mono',
			'vrFormat.vr180MonoDesc' => 'Hemisphärisches Panorama, ein Auge pro Bild',
			'vrFormat.vr360Mono' => 'VR360 Mono',
			'vrFormat.vr360MonoDesc' => 'Vollständiges Rundumpanorama, ein Auge pro Bild',
			'vrFormat.vr360TopBottom' => 'VR360 Over-Under',
			'vrFormat.vr360TopBottomDesc' => 'Vollständiges Rundumpanorama mit beiden Augen übereinander',
			'vrFormat.resetView' => 'Ansicht zurücksetzen',
			'vrFormat.resetViewDesc' => 'Blickrichtung und Sichtfeld wieder nach vorne ausrichten',
			'vrFormat.resetToAuto' => 'Zurück zur automatischen Erkennung',
			'vrFormat.resetToAutoDesc' => 'Die manuelle Auswahl für dieses Video verwerfen und die Erkennung erneut entscheiden lassen',
			'vrFormat.manualBadge' => 'Manuell festgelegt',
			'vrFormat.panoramaHint' => 'Ziehen Sie das Bild, um sich umzusehen; ziehen Sie zusammen, um das Sichtfeld zu ändern',
			'vrFormat.panoramaGestureNotice' => 'Beim Umsehen dreht Ziehen die Ansicht — verwenden Sie den Fortschrittsbalken zum Spulen',
			'vrFormat.shaderUnsupported' => 'Dieses Gerät kann Live-Panorama nicht rendern; es wird stattdessen ein einzelnes Auge angezeigt',
			'vrFormat.handoffTooltip' => 'Anders abspielen',
			'vrFormat.suggestedBadge' => 'Vorgeschlagen',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Sieht aus wie ${format} — zum Wechseln tippen',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Dies könnte ein VR-Video sein (${format})',
			'vrFormat.suggestionTitleShort' => 'Dies könnte ein VR-Video sein',
			'vrFormat.suggestionAction' => 'Als VR abspielen',
			'vrFormat.suggestionDismiss' => 'Ausblenden',
			'localMedia.browse.pinnedSection' => 'Schnellzugriff',
			'localMedia.browse.sourcesSection' => 'Ordner',
			'localMedia.browse.pin' => 'Zum Schnellzugriff hinzufügen',
			'localMedia.browse.unpin' => 'Aus dem Schnellzugriff entfernen',
			'localMedia.browse.pinned' => 'Zum Schnellzugriff hinzugefügt',
			'localMedia.browse.unpinned' => 'Aus dem Schnellzugriff entfernt',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} Ordner',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} Videos',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} Bilder',
			'localMedia.browse.emptyFolder' => 'Dieser Ordner ist leer',
			'localMedia.browse.videosSection' => 'Videos',
			'localMedia.browse.imagesSection' => 'Bilder',
			'localMedia.browse.galleriesSection' => 'Galerien',
			'localMedia.browse.filterAll' => 'Alle',
			'localMedia.browse.searchInFolder' => 'In diesem Ordner suchen',
			'localMedia.browse.searchHint' => 'Nach Namen suchen',
			'localMedia.browse.clearSearch' => 'Suche löschen',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'Keine Treffer für „${query}“',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Alle ${count} Ordner anzeigen',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Alle ${count} Videos anzeigen',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Alle ${count} Bilder anzeigen',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Alle ${count} Galerien anzeigen',
			'localMedia.browse.location' => 'Ort',
			'localMedia.browse.sourceMissing' => 'Diese Quelle ist nicht mehr vorhanden',
			'localMedia.browse.notScannedYet' => 'Dieser Ordner wurde noch nicht gescannt',
			'localMedia.browse.scanning' => 'Dieser Ordner wird gelesen…',
			'localMedia.browse.deleteFileTitle' => 'Diese Datei löschen?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '„${name}“ wird endgültig von diesem Gerät entfernt. Dies kann nicht rückgängig gemacht werden.',
			'localMedia.browse.hideFolder' => 'Diesen Ordner ausblenden',
			'localMedia.browse.unhideFolder' => 'Einblenden',
			'localMedia.browse.showHiddenFolders' => 'Ausgeblendete Ordner anzeigen',
			'localMedia.browse.includeDotFolders' => 'Ordner mit . am Anfang scannen',
			'localMedia.browse.dotFoldersIncluded' => 'Ordner mit . am Anfang werden jetzt gescannt',
			'localMedia.browse.dotFoldersExcluded' => 'Ordner mit . am Anfang werden nicht mehr gescannt',
			'localMedia.browse.showDotFolders' => 'Ordner mit . am Anfang anzeigen',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => '${count} Ordner mit . am Anfang werden hier nicht gescannt',
			'localMedia.browse.scanDotFoldersAction' => 'Für diese Quelle aktivieren',
			'localMedia.browse.otherAppsPrivateNotice' => 'Seit Android 11 kann keine App die Dateien anderer Apps in Android/data oder Android/obb lesen, auch diese App nicht. Lade die Videos in der ursprünglichen App herunter oder exportiere sie in einen öffentlichen Ordner wie Download und füge diesen Ordner hier hinzu. Streaming-Caches bestehen meist aus Fragmenten und lassen sich auch gelesen nicht abspielen.',
			'localMedia.browse.folderHidden' => 'Ausgeblendet – wird auch beim Scannen übersprungen',
			'localMedia.browse.folderUnhidden' => 'Nicht mehr ausgeblendet',
			'localMedia.browse.hiddenFolderBadge' => 'Ausgeblendet',
			'localMedia.browse.deleteFolder' => 'Ordner löschen',
			'localMedia.browse.deleteFolderTitle' => 'Diesen Ordner löschen?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '„${name}“ und der gesamte Inhalt werden endgültig von diesem Gerät gelöscht. Das lässt sich nicht rückgängig machen.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Andere Dateien darin werden ebenfalls gelöscht',
			'localMedia.browse.folderDeleted' => 'Ordner gelöscht',
			'localMedia.browse.deleteFolderFailed' => 'Löschen fehlgeschlagen – keine Berechtigung, oder eine Datei darin wird gerade verwendet',
			'localMedia.browse.deleteGalleryTitle' => 'Diese Galerie löschen?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'Der Download-Eintrag und die lokalen Bilddateien von „${name}“ werden gelöscht. Dies kann nicht rückgängig gemacht werden.',
			'localMedia.browse.galleryResourceMissing' => 'Lokale Dateien existieren nicht mehr. Eintrag bereinigt.',
			'localMedia.browse.viewDownloadDetail' => 'Download-Details anzeigen',
			'localMedia.browse.viewOnlineGallery' => 'Auf der Website ansehen',
			'localMedia.browse.pickFolderTitle' => 'Ordner wählen',
			'localMedia.browse.useThisFolder' => 'Diesen Ordner verwenden',
			'localMedia.browse.noSubfolders' => 'Keine Unterordner hier',
			'localMedia.browse.storageRoot' => 'Gerätespeicher',
			'localMedia.browse.homeFolder' => 'Persönlicher Ordner',
			'localMedia.browse.filesystemRoot' => 'Dateisystem-Wurzel',
			'localMedia.browse.folderUnreadable' => 'Dieser Ordner kann nicht gelesen werden',
			'localMedia.browse.setCover' => 'Titelbild festlegen',
			'localMedia.browse.setAsFolderCover' => 'Als Ordner-Titelbild verwenden',
			'localMedia.browse.folderCoverSet' => 'Ordner-Titelbild aktualisiert',
			'localMedia.browse.setFolderCoverPick' => 'Titelbild festlegen…',
			'localMedia.browse.restoreAutoCover' => 'Automatisches Titelbild wiederherstellen',
			'localMedia.browse.autoCoverRestored' => 'Automatisches Titelbild wiederhergestellt',
			'localMedia.browse.rescanFolder' => 'Diesen Ordner erneut scannen',
			'localMedia.browse.coverPickerTitle' => 'Ein Einzelbild auswählen',
			'localMedia.browse.folderCoverPickerTitle' => 'Titelbild wählen',
			'localMedia.browse.coverPickerEmpty' => 'In diesem Ordner sind noch keine Bilder verfügbar. Video-Miniaturbilder werden möglicherweise noch im Hintergrund erzeugt.',
			'localMedia.browse.coverSaved' => 'Titelbild aktualisiert',
			'localMedia.browse.coverSaveFailed' => 'Das Titelbild konnte nicht gespeichert werden',
			'localMedia.browse.coverUnavailable' => 'Aus dieser Datei konnte kein Video-Einzelbild gelesen werden',
			'localMedia.browse.deleted' => 'Gelöscht',
			'localMedia.browse.deleteFailed' => 'Löschen nicht möglich – die Datei wird möglicherweise verwendet oder ist nicht beschreibbar',
			'localMedia.browse.openFolder' => 'Öffnen',
			'localMedia.browse.favorite' => 'Zu Favoriten hinzufügen',
			'localMedia.browse.unfavorite' => 'Aus Favoriten entfernen',
			'localMedia.browse.favorited' => 'Zu Favoriten hinzugefügt',
			'localMedia.browse.unfavorited' => 'Aus Favoriten entfernt',
			'localMedia.browse.sortBy' => 'Sortieren nach',
			'localMedia.browse.sortAscending' => 'Aufsteigend',
			'localMedia.browse.sortDescending' => 'Absteigend',
			'localMedia.browse.sortFieldName' => 'Name',
			'localMedia.browse.sortFieldModified' => 'Änderungsdatum',
			'localMedia.browse.sortFieldDuration' => 'Dauer',
			'localMedia.browse.sortFieldSize' => 'Größe',
			'localMedia.browse.sortFieldResolution' => 'Auflösung',
			'localMedia.browse.sortFieldFileType' => 'Dateityp',
			'localMedia.browse.sortFieldFps' => 'Bildrate',
			'localMedia.browse.sortFieldFavorited' => 'Datum der Favorisierung',
			'localMedia.browse.emptyAllVideos' => 'Noch keine Videos gefunden. Fügen Sie unter „Ordner“ einen Ordner hinzu, um zu beginnen.',
			'localMedia.browse.emptyAllImages' => 'Noch keine Bilder gefunden. Fügen Sie unter „Ordner“ einen Ordner hinzu, um zu beginnen.',
			'localMedia.browse.emptyFavorites' => 'Noch keine Favoriten. Fügen Sie einen über das ⋮-Menü eines Videos hinzu.',
			'localMedia.browse.emptyPinned' => 'Noch keine angehefteten Ordner. Halten Sie einen Ordner unter „Ordner“ gedrückt und wählen Sie „Anheften“.',
			'localMedia.browse.emptyDownloadedVideos' => 'Noch keine abgeschlossenen Video-Downloads.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Noch keine abgeschlossenen Galerie-Downloads.',
			'localMedia.browse.folderInfo' => 'Ordnerinfo',
			'localMedia.browse.folderInfoName' => 'Name',
			'localMedia.browse.folderInfoPath' => 'Pfad',
			'localMedia.browse.folderInfoSource' => 'Quelle',
			'localMedia.browse.folderInfoContents' => 'Inhalt',
			'localMedia.browse.folderInfoSize' => 'Größe auf dem Datenträger',
			'localMedia.browse.folderInfoScannedAt' => 'Zuletzt gescannt',
			'localMedia.browse.folderInfoNeverScanned' => 'Noch nicht gescannt',
			'localMedia.browse.folderInfoNoPath' => 'Diese Quelle hat keinen zu öffnenden Ordner',
			'localMedia.browse.copyPath' => 'Pfad kopieren',
			'localMedia.browse.pathCopied' => 'Pfad kopiert',
			'localMedia.tabFolders' => 'Ordner',
			'localMedia.tabFavoriteVideos' => 'Favoriten',
			'localMedia.tabAllVideos' => 'Alle Videos',
			'localMedia.tabAllImages' => 'Alle Bilder',
			'localMedia.tabDownloadedVideos' => 'Heruntergeladene Videos',
			'localMedia.tabDownloadedGalleries' => 'Heruntergeladene Galerien',
			'localMedia.title' => 'Auf diesem Gerät',
			'localMedia.sourceOnline' => 'Iwara online',
			'localMedia.manageSources' => 'Quellen verwalten',
			'localMedia.moveToCategory' => 'In Kategorie verschieben',
			'localMedia.manageCategories' => 'Kategorien verwalten',
			'localMedia.suggestedFolders' => 'Ordner mit Videos',
			'localMedia.sortRecentlyAdded' => 'Zuletzt hinzugefügt',
			'localMedia.sortRecentlyPlayed' => 'Zuletzt abgespielt',
			'localMedia.sortName' => 'Name',
			'localMedia.sortDuration' => 'Dauer',
			'localMedia.sortSize' => 'Größe',
			'localMedia.sortFolder' => 'Ordner',
			'localMedia.sortRecentlyModified' => 'Zuletzt geändert',
			'localMedia.sortCount' => 'Anzahl',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} Bilder',
			'localMedia.downloadsSource' => 'Heruntergeladen',
			'localMedia.builtInSourceHint' => '„Heruntergeladen“ wird automatisch verwaltet',
			'localMedia.filterByCategory' => 'Nach Kategorie filtern',
			'localMedia.longPressToCategorize' => 'Zum Verschieben in eine Kategorie lange drücken',
			'localMedia.uncategorized' => 'Nicht kategorisiert',
			'localMedia.setCategoryFailed' => 'Kategorie konnte nicht festgelegt werden',
			'localMedia.categoryUpdated' => 'Kategorie aktualisiert',
			'localMedia.addFolder' => 'Ordner hinzufügen',
			'localMedia.addDeviceVideos' => 'Gerätevideos scannen',
			'localMedia.mediaStoreSourceName' => 'Gerätevideos',
			'localMedia.scanQueued' => 'Waiting to scan',
			'localMedia.itemInfo' => 'File info',
			'localMedia.revealInFolder' => 'Show in folder',
			'localMedia.rescanAll' => 'Rescan all',
			'localMedia.rescanAllStarted' => ({required Object count}) => 'Rescanning ${count} sources',
			'localMedia.searchLibrary' => 'Search',
			'localMedia.searchIncludeSubfolders' => 'Include subfolders',
			'localMedia.searchThisFolderOnly' => 'This folder only',
			'localMedia.searchResultCount' => ({required Object count}) => 'Found ${count}',
			'localMedia.savedServers' => 'Saved NAS',
			'localMedia.newServer' => 'Connect a new NAS',
			'localMedia.itemInfoLabels.size' => 'Size',
			'localMedia.itemInfoLabels.resolution' => 'Resolution',
			'localMedia.itemInfoLabels.duration' => 'Duration',
			'localMedia.itemInfoLabels.modified' => 'Modified',
			'localMedia.itemInfoLabels.lastPlayed' => 'Last played',
			'localMedia.itemInfoLabels.neverPlayed' => 'Not watched yet',
			'localMedia.itemInfoLabels.completed' => 'Finished',
			'localMedia.addSource' => 'Add source',
			'localMedia.addSourceKinds' => 'Folder · NAS',
			'localMedia.openSettings' => 'Open settings',
			'localMedia.removeSourceLoses' => ({required Object items}) => 'This also clears the following, and re-adding won\'t bring it back: ${items}',
			'localMedia.loseProgress' => ({required Object count}) => '${count} watch progress',
			'localMedia.loseFavorites' => ({required Object count}) => '${count} featured',
			'localMedia.losePinned' => ({required Object count}) => '${count} pinned folders',
			'localMedia.loseHidden' => ({required Object count}) => '${count} hidden folders',
			'localMedia.loseCovers' => ({required Object count}) => '${count} custom covers',
			'localMedia.renameSource' => 'Rename',
			'localMedia.renameSourceTitle' => 'Rename source',
			'localMedia.renameSourceLabel' => 'Name',
			'localMedia.renamed' => 'Renamed',
			'localMedia.nasAggregateHint' => 'NAS content only includes folders you have opened. Videos and images in folders you haven\'t opened won\'t show up here.',
			'localMedia.rescanDone' => ({required Object name}) => '"${name}" updated',
			'localMedia.unknownSourceHint' => 'This source needs a newer version of the app',
			'localMedia.missing.title' => 'Can\'t find this file',
			'localMedia.missing.rescanFolder' => 'Rescan folder',
			'localMedia.missing.relistNas' => 'Refresh this folder',
			'localMedia.missing.removeFromList' => 'Remove from list',
			'localMedia.missing.removed' => 'Removed from the list. The file on disk was not touched',
			'localMedia.missing.found' => 'Found it',
			'localMedia.missing.nasGone' => ({required Object name}) => '"${name}" is no longer on the NAS: it may have been deleted, moved or renamed. Refresh this folder to see what it contains now.',
			'localMedia.webdav.addNas' => 'Connect NAS (WebDAV)',
			'localMedia.webdav.connectTitle' => 'Connect NAS',
			'localMedia.webdav.editTitle' => 'Sign in to NAS again',
			'localMedia.webdav.hint' => 'Turn on the WebDAV service in your NAS settings, then enter its address and account.',
			'localMedia.webdav.address' => 'Address',
			'localMedia.webdav.addressHint' => 'e.g. 192.168.1.10:5005',
			'localMedia.webdav.username' => 'Username',
			'localMedia.webdav.password' => 'Password',
			'localMedia.webdav.displayName' => 'Name (optional)',
			'localMedia.webdav.connect' => 'Connect',
			'localMedia.webdav.invalidAddress' => 'Invalid address',
			'localMedia.webdav.errorAuth' => 'Wrong username or password',
			'localMedia.webdav.errorUnreachable' => 'Can\'t reach the server. Check the address and port, and that this device is on the same network as the NAS',
			'localMedia.webdav.errorNotWebdav' => 'This address is not a WebDAV service',
			'localMedia.webdav.errorGeneric' => ({required Object code}) => 'Connection failed (${code})',
			'localMedia.webdav.errorCredUnreadable' => 'Couldn\'t read the saved password. Try again later',
			'localMedia.webdav.certTitle' => 'Trust this server?',
			'localMedia.webdav.certBody' => 'The server\'s certificate isn\'t trusted by the system (common with self-signed NAS certificates). Make sure this fingerprint matches the one shown in your NAS settings:',
			'localMedia.webdav.certChangedBody' => 'This server\'s certificate is different from the one you trusted before. If you didn\'t replace your NAS certificate, someone may be impersonating it. Don\'t continue.',
			'localMedia.webdav.trust' => 'Trust',
			'localMedia.webdav.pickRootTitle' => 'Choose a folder to add',
			'localMedia.webdav.serverRoot' => 'Root',
			'localMedia.webdav.alreadyAdded' => 'This NAS folder has already been added',
			'localMedia.webdav.relogin' => 'Sign in again',
			'localMedia.webdav.stateAuthFailed' => 'Sign-in required',
			'localMedia.webdav.stateCertUntrusted' => 'Server certificate changed',
			'localMedia.webdav.stateUnreachable' => 'Can\'t reach NAS',
			'localMedia.webdav.stateCredUnreadable' => 'Couldn\'t read password',
			'localMedia.webdav.connected' => 'Connected',
			'localMedia.webdav.errorForbidden' => 'This account has no WebDAV access. Grant it WebDAV permission in the NAS settings.',
			'localMedia.webdav.errorTls' => 'Secure connection failed. Check that http:// or https:// matches the NAS settings.',
			'localMedia.webdav.errorTryHttps' => 'If the NAS only serves HTTPS, add https:// in front of the address.',
			'localMedia.webdav.previousStep' => 'Back',
			'localMedia.webdav.bannerUnreachable' => 'Can\'t reach the NAS. Showing what was seen last time.',
			'localMedia.webdav.bannerAuthFailed' => 'Login expired. Sign in again to see the latest content.',
			'localMedia.webdav.bannerCertUntrusted' => 'The NAS certificate changed. Confirm it to continue.',
			'localMedia.webdav.bannerCredUnreadable' => 'Couldn\'t read the saved password. Sign in again.',
			'localMedia.mediaStoreUnavailable' => 'Der Gerätemedienindex ist nur unter Android verfügbar',
			'localMedia.mediaStorePermissionDenied' => 'Der Videozugriff wurde nicht erteilt',
			'localMedia.rescan' => 'Erneut scannen',
			'localMedia.scanning' => ({required Object count}) => 'Wird gescannt… ${count} gefunden',
			'localMedia.scanFailed' => ({required Object reason}) => 'Scan fehlgeschlagen: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Dieser Ordner ist sehr groß – es wurden nur die ersten ${count} Dateien hinzugefügt.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Bereits durch den Ordner „${name}“ abgedeckt',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '„${name}“ befindet sich in „${source}“ und wurde daher zu den angehefteten Ordnern hinzugefügt',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '„${name}“ befindet sich bereits in den angehefteten Ordnern',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '„${name}“ wurde bereits hinzugefügt',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Er enthält bereits den hinzugefügten Ordner „${name}“; das Hinzufügen des übergeordneten Ordners wird noch nicht unterstützt',
			'localMedia.addSourceFailed' => 'Dieser Ordner konnte nicht hinzugefügt werden',
			'localMedia.fileMissing' => 'Diese Datei befindet sich nicht mehr auf dem Datenträger',
			'localMedia.permissionDenied' => 'Dateizugriff nicht erteilt · zum Erteilen tippen',
			'localMedia.noVideosFound' => 'Keine Videos in diesem Ordner',
			'localMedia.emptyTitle' => 'Fügen Sie einen Ordner hinzu, um die bereits auf diesem Gerät befindlichen Videos anzusehen',
			'localMedia.emptyPrivacyNote' => 'Dateien werden nur auf diesem Gerät gelesen. Nichts wird hochgeladen.',
			'localMedia.removeSourceTitle' => ({required Object name}) => '„${name}“ entfernen?',
			'localMedia.removeSourceBody' => 'Die Dateien bleiben auf dem Datenträger. Nur dieser Bibliothekseintrag wird entfernt.',
			'localMedia.remove' => 'Entfernen',
			'localMedia.removeFolder' => 'Ordner entfernen',
			'localMedia.removeFolderSelectTitle' => 'Zu entfernenden Ordner auswählen',
			'localMedia.longPressToRemove' => 'Diesen Ordner durch langes Drücken entfernen',
			'localMedia.clearProgress' => 'Lokalen Wiedergabeverlauf löschen',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} Einträge',
			'localMedia.clearProgressEmpty' => 'Noch kein lokaler Wiedergabeverlauf',
			'localMedia.clearProgressTitle' => 'Lokalen Wiedergabeverlauf löschen?',
			'localMedia.clearProgressBody' => 'Nur Wiedergabepositionen und Gesehen-Markierungen werden gelöscht. Ihre Dateien und Ordner bleiben unverändert.',
			'localMedia.clearProgressDone' => ({required Object count}) => '${count} lokale Wiedergabeverlauf-Einträge gelöscht',
			'localMedia.clearAction' => 'Leeren',
			'localMedia.iosManualRescanNotice' => 'iOS erkennt neue Dateien nicht automatisch. Nach dem Hinzufügen oder Löschen von Dateien müssen Sie manuell erneut scannen.',
			'historyPage.removeFromHistory' => 'Aus Verlauf entfernen',
			'historyPage.removed' => 'Aus dem Verlauf entfernt',
			'historyPage.watchedTo' => ({required Object time}) => 'Gesehen bis ${time}',
			'historyPage.finished' => 'Angesehen',
			'historyPage.clearTabTitle' => ({required Object tab}) => '„${tab}“ leeren',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Der gesamte Verlauf in „${tab}“ wird gelöscht, einschließlich des Wiedergabefortschritts dieser Videos. Dies kann nicht rückgängig gemacht werden.',
			'historyPage.rangeByLastViewed' => 'Nach zuletzt angesehen gefiltert',
			'ai.title' => 'KI',
			'ai.providers' => 'Anbieter',
			'ai.providersHint' => 'Fügen Sie einen oder mehrere KI-Anbieter hinzu und weisen Sie diese den Funktionen zu.',
			'ai.addProvider' => 'Anbieter hinzufügen',
			'ai.noProviders' => 'Noch keine Anbieter vorhanden. Fügen Sie einen hinzu, um KI-Übersetzung, Suche und Signatur zu aktivieren.',
			'ai.pickPreset' => 'Anbieter auswählen',
			'ai.providerNameLabel' => 'Bezeichnung',
			'ai.apiKey' => 'API-Schlüssel',
			'ai.baseUrl' => 'Endpunkt',
			'ai.model' => 'Modell',
			'ai.modelPick' => 'Modell auswählen',
			'ai.modelEmpty' => 'Modellliste konnte nicht geladen werden — Sie können den Modellnamen auch direkt eingeben.',
			'ai.advanced' => 'Erweitert',
			'ai.reasoning' => 'Reasoning-Modell',
			'ai.streaming' => 'Streaming-Ausgabe',
			'ai.structuredOutput' => 'Strukturierte Ausgabe',
			'ai.structuredOutputHint' => 'Wird für die KI-Suche benötigt. Viele Relay-Endpunkte unterstützen dies nicht — deaktivieren Sie es, wenn die Suche fehlschlägt.',
			'ai.temperature' => 'Temperatur',
			'ai.maxTokens' => 'Max. Tokens',
			'ai.maxTokensAuto' => 'Automatisch (Modellgrenze)',
			'ai.test' => 'Testen',
			'ai.testOk' => 'Verbindung erfolgreich',
			'ai.deleteProvider' => 'Anbieter löschen',
			'ai.usedBy' => 'Verwendet für',
			'ai.taskBindings' => 'Funktionszuweisung',
			'ai.taskBindingsHint' => 'Jede Funktion kann einen anderen Anbieter verwenden.',
			'ai.taskTranslate' => 'Übersetzung',
			'ai.taskSearch' => 'KI-Suche',
			'ai.taskSignature' => 'Signatur',
			'ai.taskAuto' => 'Automatisch',
			'ai.usage' => 'Nutzung',
			'ai.usageCalls' => 'Aufrufe',
			'ai.usageTokens' => 'Token-Anzahl',
			'ai.usageFailures' => 'Fehlgeschlagen',
			'ai.usageReset' => 'Statistiken zurücksetzen',
			'ai.usageEmpty' => 'Noch keine Aufrufe vorhanden',
			'ai.openSettings' => 'KI-Einstellungen öffnen',
			'ai.notConfigured' => 'Nicht konfiguriert',
			'ai.searchTitle' => 'KI-Suche',
			'ai.searchHint' => 'Beschreiben Sie, was Sie suchen. Die KI füllt Suchbegriffe und Filter automatisch aus.',
			'ai.searchPlaceholder' => 'z. B. aktuelle MMDs mit über 10.000 Aufrufen',
			'ai.searchApply' => 'Mit diesen Begriffen suchen',
			'ai.searchEmpty' => 'Suchbegriffe konnten nicht erkannt werden. Bitte versuchen Sie es mit einer anderen Formulierung.',
			'ai.searchFilters' => 'Filterkriterien',
			'ai.searchSwitchSegment' => ({required Object segment}) => 'Zu ${segment} wechseln',
			'ai.searchGenerating' => 'Wird verarbeitet…',
			'ai.searchRetrying' => 'Letzter Versuch fehlgeschlagen, neuer Versuch…',
			'ai.searchRetryReason' => ({required Object reason}) => 'Grund: ${reason}',
			'ai.searchStageWaiting' => 'Anfrage gesendet, warte auf Antwort…',
			'ai.searchStageThinkingNext' => 'Überlegt den nächsten Schritt…',
			'ai.searchStageReasoning' => 'Überlegt…',
			'ai.searchStageTool' => 'Testsuche läuft…',
			'ai.searchStageDrafting' => ({required Object chars}) => 'Antwort wird geschrieben · ${chars} Zeichen',
			'ai.searchStageParsing' => 'Ergebnis wird aufbereitet…',
			'ai.searchThinking' => 'Denkprozess',
			'ai.searchKeywordNeedsQuotes' => 'Dieses Stichwort steht nicht in Anführungszeichen, daher passt Iwara es nur lose an — bei dieser Sortierung ist die erste Seite meist unpassend. Setze es in "Anführungszeichen" oder sortiere nach Relevanz.',
			'ai.searchToolProbing' => ({required Object query}) => 'Teste ${query}',
			'ai.searchToolFound' => ({required Object count, required Object titles}) => '${count} Treffer · ${titles}',
			'ai.searchToolFailed' => ({required Object reason}) => 'Fehlgeschlagen: ${reason}',
			'ai.searchFiltersDropped' => ({required Object count}) => '${count} Filter entfernt, die es in diesem Bereich nicht gibt.',
			'ai.revealKey' => 'Show',
			'ai.hideKey' => 'Hide',
			'ai.connection' => 'Connection',
			'ai.providerEnabled' => 'Enabled',
			'ai.providerEnabledHint' => 'Turn off to keep the settings but stop using this provider.',
			'ai.providerModelCount' => ({required Object count}) => '${count} model(s)',
			'ai.noModels' => 'No models',
			'ai.noModelsHint' => 'No models yet. Pull the list from the server, or type a model name.',
			'ai.missingApiKey' => 'API key missing',
			'ai.providerGone' => 'This provider no longer exists.',
			'ai.deleteProviderConfirm' => 'Delete this provider? Its models and feature assignments go with it.',
			'ai.getApiKey' => 'Get an API key',
			'ai.providerDocs' => 'Documentation',
			'ai.models' => 'Models',
			'ai.fetchModels' => 'Pull from server',
			'ai.fetchModelsHint' => 'Pick from what this endpoint actually serves, instead of guessing a name.',
			'ai.addModel' => 'Add a model by name',
			'ai.deleteModel' => 'Remove model',
			'ai.modelUnknown' => 'Not in the catalog — capabilities unknown',
			'ai.serverDefaultModel' => 'Server default model',
			'ai.resetToDefault' => 'Reset to default',
			'ai.contextWindow' => ({required Object tokens}) => 'Context ${tokens}',
			'ai.capFunctionCall' => 'Tools',
			'ai.capReasoning' => 'Reasoning',
			'ai.capStructuredOutput' => 'JSON output',
			'ai.capVision' => 'Vision',
			'ai.capFileInput' => 'Files',
			'ai.triOn' => 'On',
			'ai.triOff' => 'Off',
			'ai.triAutoOn' => 'Auto (on)',
			'ai.triAutoOff' => 'Auto (off)',
			'ai.triAutoUnknown' => 'Auto (unknown)',
			'ai.endpointPreview' => ({required Object url}) => 'Requests go to ${url}',
			'ai.endpointTrailingSlash' => 'The trailing slash produces a doubled // in the path.',
			'ai.endpointMissingVersion' => 'No version segment — most OpenAI-compatible endpoints need /v1.',
			'ai.modelOverrideHint' => 'Everything here is optional. Leave a field alone and it follows the model\'s own capabilities and the built-in catalog.',
			'ai.followCatalog' => ({required Object value}) => 'Following the catalog: ${value}',
			'ai.userOverride' => 'Overridden by you',
			_ => null,
		} ?? switch (path) {
			'ai.sendTemperature' => 'Send temperature',
			'ai.sendTemperatureHint' => 'Some endpoints reject a request that carries this parameter.',
			'ai.maxTokensFromCatalog' => ({required Object tokens}) => 'Catalog says ${tokens}',
			'ai.maxTokensHint' => 'Leave empty to follow the catalog. Enter 0 to omit the parameter entirely and let the server use the model\'s own limit.',
			'ai.catalogVersion' => ({required Object version}) => 'Provider catalog ${version}',
			'ai.catalogMissing' => 'Provider catalog unavailable.',
			'ai.searchModel' => 'Search models',
			'ai.searchProvider' => 'Search providers',
			'ai.customProvider' => 'Custom (OpenAI-compatible endpoint)',
			'ai.customProviderHint' => 'For a relay or self-hosted gateway not in the list.',
			'ai.wizardNext' => 'Next',
			'ai.wizardApiKeyTitle' => 'API key',
			'ai.wizardModelsTitle' => 'Pick models',
			'ai.wizardVerifyTitle' => 'Verify',
			'ai.wizardModelsHint' => 'These come from the endpoint itself. Pick the ones you want to use.',
			'ai.wizardModelsFallbackHint' => 'Could not pull the list; these are common models for this provider.',
			'ai.wizardNoModels' => 'No list available. Skip this step and add a model by name later — an empty model name also works, the server picks its default.',
			'ai.wizardVerifyHint' => 'One real round-trip. A model can be listed and still fail, and only an actual request shows whether this endpoint honours JSON schema.',
			'ai.wizardCheckChat' => 'Send a test message',
			'ai.wizardCheckSchema' => 'Check JSON output support',
			'ai.wizardCheckSchemaWarn' => 'This endpoint ignores JSON schema. AI search still works through the prompt-contract path, just a little slower.',
			'ai.unsavedBadge' => 'Unsaved changes',
			'ai.unsavedTitle' => 'Unsaved changes',
			'ai.unsavedBody' => 'This page has changes you haven\'t saved yet. Leaving now discards them.',
			'ai.saveAndLeave' => 'Save and leave',
			'ai.discardChanges' => 'Discard',
			'ai.savedToast' => 'Saved',
			_ => null,
		};
	}
}
