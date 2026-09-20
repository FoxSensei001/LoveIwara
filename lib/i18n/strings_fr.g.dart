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
class TranslationsFr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	@override 
	TranslationsFr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileFr personalProfile = _TranslationsPersonalProfileFr._(_root);
	@override late final _TranslationsTutorialFr tutorial = _TranslationsTutorialFr._(_root);
	@override late final _TranslationsCommonFr common = _TranslationsCommonFr._(_root);
	@override late final _TranslationsAuthFr auth = _TranslationsAuthFr._(_root);
	@override late final _TranslationsErrorsFr errors = _TranslationsErrorsFr._(_root);
	@override late final _TranslationsFriendsFr friends = _TranslationsFriendsFr._(_root);
	@override late final _TranslationsAuthorProfileFr authorProfile = _TranslationsAuthorProfileFr._(_root);
	@override late final _TranslationsFavoritesFr favorites = _TranslationsFavoritesFr._(_root);
	@override late final _TranslationsGalleryDetailFr galleryDetail = _TranslationsGalleryDetailFr._(_root);
	@override late final _TranslationsPlayListFr playList = _TranslationsPlayListFr._(_root);
	@override late final _TranslationsSearchFr search = _TranslationsSearchFr._(_root);
	@override late final _TranslationsMediaListFr mediaList = _TranslationsMediaListFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsFavoriteTagsFr favoriteTags = _TranslationsFavoriteTagsFr._(_root);
	@override late final _TranslationsOreno3dFr oreno3d = _TranslationsOreno3dFr._(_root);
	@override late final _TranslationsSignInFr signIn = _TranslationsSignInFr._(_root);
	@override late final _TranslationsSubscriptionsFr subscriptions = _TranslationsSubscriptionsFr._(_root);
	@override late final _TranslationsVideoDetailFr videoDetail = _TranslationsVideoDetailFr._(_root);
	@override late final _TranslationsShareFr share = _TranslationsShareFr._(_root);
	@override late final _TranslationsMarkdownFr markdown = _TranslationsMarkdownFr._(_root);
	@override late final _TranslationsForumFr forum = _TranslationsForumFr._(_root);
	@override late final _TranslationsNotificationsFr notifications = _TranslationsNotificationsFr._(_root);
	@override late final _TranslationsConversationFr conversation = _TranslationsConversationFr._(_root);
	@override late final _TranslationsSplashFr splash = _TranslationsSplashFr._(_root);
	@override late final _TranslationsDownloadFr download = _TranslationsDownloadFr._(_root);
	@override late final _TranslationsDownloadNotificationsFr downloadNotifications = _TranslationsDownloadNotificationsFr._(_root);
	@override late final _TranslationsFavoriteFr favorite = _TranslationsFavoriteFr._(_root);
	@override late final _TranslationsTranslationFr translation = _TranslationsTranslationFr._(_root);
	@override late final _TranslationsBottomNavFr bottomNav = _TranslationsBottomNavFr._(_root);
	@override late final _TranslationsNavigationOrderSettingsFr navigationOrderSettings = _TranslationsNavigationOrderSettingsFr._(_root);
	@override late final _TranslationsNewsFr news = _TranslationsNewsFr._(_root);
	@override late final _TranslationsDisplaySettingsFr displaySettings = _TranslationsDisplaySettingsFr._(_root);
	@override late final _TranslationsLayoutSettingsFr layoutSettings = _TranslationsLayoutSettingsFr._(_root);
	@override late final _TranslationsMediaPlayerFr mediaPlayer = _TranslationsMediaPlayerFr._(_root);
	@override late final _TranslationsDiagnosticsFr diagnostics = _TranslationsDiagnosticsFr._(_root);
	@override late final _TranslationsLogViewerFr logViewer = _TranslationsLogViewerFr._(_root);
	@override late final _TranslationsCrashRecoveryDialogFr crashRecoveryDialog = _TranslationsCrashRecoveryDialogFr._(_root);
	@override late final _TranslationsLinkInputDialogFr linkInputDialog = _TranslationsLinkInputDialogFr._(_root);
	@override late final _TranslationsLogFr log = _TranslationsLogFr._(_root);
	@override late final _TranslationsEmojiFr emoji = _TranslationsEmojiFr._(_root);
	@override late final _TranslationsSearchFilterFr searchFilter = _TranslationsSearchFilterFr._(_root);
	@override late final _TranslationsFirstTimeSetupFr firstTimeSetup = _TranslationsFirstTimeSetupFr._(_root);
	@override late final _TranslationsProxyHelperFr proxyHelper = _TranslationsProxyHelperFr._(_root);
	@override late final _TranslationsTagSelectorFr tagSelector = _TranslationsTagSelectorFr._(_root);
	@override late final _TranslationsAnime4kFr anime4k = _TranslationsAnime4kFr._(_root);
	@override late final _TranslationsSiteModeFr siteMode = _TranslationsSiteModeFr._(_root);
	@override late final _TranslationsSavedSearchConfigFr savedSearchConfig = _TranslationsSavedSearchConfigFr._(_root);
	@override late final _TranslationsSavedSearchFr savedSearch = _TranslationsSavedSearchFr._(_root);
	@override late final _TranslationsDefaultBlacklistReminderFr defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderFr._(_root);
	@override late final _TranslationsColorVisionAssistFr colorVisionAssist = _TranslationsColorVisionAssistFr._(_root);
	@override late final _TranslationsExternalPlayerFr externalPlayer = _TranslationsExternalPlayerFr._(_root);
	@override late final _TranslationsWatchLaterFr watchLater = _TranslationsWatchLaterFr._(_root);
	@override late final _TranslationsMediaMenuFr mediaMenu = _TranslationsMediaMenuFr._(_root);
	@override late final _TranslationsMediaPreviewFr mediaPreview = _TranslationsMediaPreviewFr._(_root);
	@override late final _TranslationsPlaybackQueueFr playbackQueue = _TranslationsPlaybackQueueFr._(_root);
	@override late final _TranslationsVrFormatFr vrFormat = _TranslationsVrFormatFr._(_root);
	@override late final _TranslationsLocalMediaFr localMedia = _TranslationsLocalMediaFr._(_root);
	@override late final _TranslationsHistoryPageFr historyPage = _TranslationsHistoryPageFr._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileFr extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Profil';
	@override String get editPersonalProfile => 'Modifier le profil';
	@override String get avatar => 'Avatar';
	@override String get background => 'Arrière-plan';
	@override String fetchUserProfileFailed({required Object error}) => 'Échec de la récupération du profil utilisateur : ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Résolution conseillée : ${resolution}, taille du fichier < ${size}';
	@override String supportedFormats({required Object formats}) => 'Formats pris en charge : ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Les utilisateurs Premium peuvent utiliser des ${type} dynamiques (${formats})';
	@override String get homepageBackground => 'Arrière-plan de la page d\'accueil';
	@override String get basicInfo => 'Informations de base';
	@override String get nickname => 'Pseudo';
	@override String get username => 'Nom d\'utilisateur';
	@override String get copyUsername => 'Copier le nom d\'utilisateur';
	@override String get usernameCopied => 'Nom d\'utilisateur copié';
	@override String get personalIntroduction => 'Présentation';
	@override String get noPersonalIntroduction => 'Aucune présentation';
	@override String get clickToEdit => 'Cliquez pour modifier';
	@override String get privacySettings => 'Paramètres de confidentialité';
	@override String get hideSensitiveContent => 'Masquer le contenu sensible';
	@override String get hideSensitiveContentDesc => 'Masquer les vidéos ou images comportant des tags sensibles.';
	@override String get notificationSettings => 'Paramètres de notification';
	@override String get contentCommentNotification => 'Notification de commentaire sur vos contenus';
	@override String get contentCommentNotificationDesc => 'Vous notifier lorsque quelqu\'un commente vos contenus.';
	@override String get commentReplyNotification => 'Notification de réponse aux commentaires';
	@override String get commentReplyNotificationDesc => 'Vous notifier lorsque quelqu\'un répond à votre commentaire.';
	@override String get mentionNotification => 'Notification de mention';
	@override String get mentionNotificationDesc => 'Vous notifier lorsque quelqu\'un vous mentionne dans un contenu.';
	@override String get accountInfo => 'Infos du compte';
	@override String get registrationTime => 'Date d\'inscription';
	@override String updateSettingsFailed({required Object error}) => 'Échec de la mise à jour des paramètres : ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'Échec de la mise à jour des paramètres de notification : ${error}';
	@override String get editNickname => 'Modifier le pseudo';
	@override String get nicknameCannotBeEmpty => 'Le pseudo ne peut pas être vide';
	@override String get changeSuccess => 'Modification réussie';
	@override String get unsupportedFileFormat => 'Format de fichier non pris en charge';
	@override String fileTooLarge({required Object size}) => 'La taille du fichier ne peut pas dépasser ${size}';
	@override String get uploadFailed => 'Échec de l\'envoi';
	@override String get avatarUpdatedSuccessfully => 'Avatar mis à jour';
	@override String updateAvatarFailed({required Object error}) => 'Échec de la mise à jour de l\'avatar : ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Arrière-plan mis à jour';
	@override String updateBackgroundFailed({required Object error}) => 'Échec de la mise à jour de l\'arrière-plan : ${error}';
	@override String get editPersonalIntroduction => 'Modifier la présentation';
	@override String get enterPersonalIntroduction => 'Veuillez saisir une présentation';
}

// Path: tutorial
class _TranslationsTutorialFr extends TranslationsTutorialEn {
	_TranslationsTutorialFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Abonnement spécial';
	@override String get specialFollowDescription => 'Marquez les auteurs que vous suivez le plus comme abonnements spéciaux, puis accédez directement à leurs dernières publications depuis ici.';
	@override String get stepsTitle => 'Trois étapes';
	@override String get stepFollowAuthor => 'Touchez Suivre sur la vidéo, la galerie ou la page de profil de l\'auteur.';
	@override String get stepPickSpecial => 'Touchez de nouveau Abonné, puis choisissez Abonnement spécial dans le menu.';
	@override String get stepSwitchHere => 'Revenez ici et basculez vers cet auteur avec le sélecteur d\'avatar ci-dessus.';
	@override String get specialFollowManagementTip => 'Gérez la liste des abonnements spéciaux dans Barre latérale - Liste d\'abonnements - Abonnements spéciaux.';
	@override String get gotIt => 'Compris';
}

// Path: common
class _TranslationsCommonFr extends TranslationsCommonEn {
	_TranslationsCommonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Trier';
	@override String get filter => 'Filtrer';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'OK';
	@override String get cancel => 'Annuler';
	@override String get select => 'Sélectionner';
	@override String get save => 'Enregistrer';
	@override String get delete => 'Supprimer';
	@override String get visit => 'Visiter';
	@override String get loading => 'Chargement...';
	@override String get scrollToTop => 'Revenir en haut';
	@override String get privacyHint => 'Le mode privé est activé, le contenu est masqué';
	@override String get latest => 'Récent';
	@override String get likesCount => 'J\'aime';
	@override String get viewsCount => 'Vues';
	@override String get popular => 'Populaire';
	@override String get trending => 'Tendances';
	@override String get commentList => 'Liste des commentaires';
	@override String get sendComment => 'Envoyer le commentaire';
	@override String get send => 'Envoyer';
	@override String get retry => 'Réessayer';
	@override String get premium => 'Premium';
	@override String get follower => 'Abonné';
	@override String get friend => 'Ami';
	@override String get video => 'Vidéo';
	@override String get following => 'Abonnements';
	@override String get expand => 'Développer';
	@override String get collapse => 'Réduire';
	@override String get cancelFriendRequest => 'Annuler la demande';
	@override String get cancelSpecialFollow => 'Annuler l\'abonnement spécial';
	@override String get addFriend => 'Ajouter un ami';
	@override String get removeFriend => 'Retirer l\'ami';
	@override String get followed => 'Abonné';
	@override String get follow => 'Suivre';
	@override String get unfollow => 'Ne plus suivre';
	@override String get specialFollow => 'Abonnement spécial';
	@override String get specialFollowed => 'Abonnement spécial ajouté';
	@override String get gallery => 'Galerie';
	@override String get playlist => 'Liste de lecture';
	@override String get commentPostedSuccessfully => 'Commentaire publié';
	@override String get commentPostedFailed => 'Échec de la publication du commentaire';
	@override String get success => 'Succès';
	@override String get commentDeletedSuccessfully => 'Commentaire supprimé';
	@override String get commentUpdatedSuccessfully => 'Commentaire modifié avec succès';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: '${n} commentaire',
		other: '${n} commentaires',
	);
	@override String get writeYourCommentHere => 'Écrivez votre commentaire ici...';
	@override String get tmpNoReplies => 'Aucune réponse pour l\'instant';
	@override String get loadMore => 'Charger plus';
	@override String get loadingMore => 'Chargement...';
	@override String get noMoreDatas => 'Plus de données';
	@override String get selectTranslationLanguage => 'Choisir la langue de traduction';
	@override String get translate => 'Traduire';
	@override String get translateFailedPleaseTryAgainLater => 'Échec de la traduction, veuillez réessayer plus tard';
	@override String get translationResult => 'Résultat de la traduction';
	@override String get justNow => 'À l\'instant';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: 'il y a ${n} minute',
		other: 'il y a ${n} minutes',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: 'il y a ${n} heure',
		other: 'il y a ${n} heures',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: 'il y a ${n} jour',
		other: 'il y a ${n} jours',
	);
	@override String editedAt({required Object num}) => 'modifié ${num} fois';
	@override String get editComment => 'Modifier le commentaire';
	@override String get commentUpdated => 'Commentaire modifié';
	@override String get replyComment => 'Répondre au commentaire';
	@override String get reply => 'Répondre';
	@override String get edit => 'Modifier';
	@override String get unknownUser => 'Utilisateur inconnu';
	@override String get me => 'Moi';
	@override String get author => 'Auteur';
	@override String get admin => 'Admin';
	@override String viewReplies({required Object num}) => 'Voir les réponses (${num})';
	@override String get hideReplies => 'Masquer les réponses';
	@override String get confirmDelete => 'Confirmer la suppression';
	@override String get areYouSureYouWantToDeleteThisItem => 'Voulez-vous vraiment supprimer cet élément ?';
	@override String get tmpNoComments => 'Aucun commentaire pour l\'instant';
	@override String get refresh => 'Actualiser';
	@override String get back => 'Retour';
	@override String get tips => 'Astuces';
	@override String get linkIsEmpty => 'Le lien est vide';
	@override String get linkCopiedToClipboard => 'Lien copié dans le presse-papiers';
	@override String get imageCopiedToClipboard => 'Image copiée dans le presse-papiers';
	@override String get copyImageFailed => 'Échec de la copie de l\'image';
	@override String get mobileSaveImageIsUnderDevelopment => 'L\'enregistrement des images sur mobile est en cours de développement';
	@override String get imageSavedTo => 'Image enregistrée dans';
	@override String get saveImageFailed => 'Échec de l\'enregistrement de l\'image';
	@override String get close => 'Fermer';
	@override String get more => 'Plus';
	@override String get unknownError => 'Erreur inconnue';
	@override String get moreFeaturesToBeDeveloped => 'D\'autres fonctionnalités à venir';
	@override String get all => 'Tout';
	@override String selectedRecords({required Object num}) => '${num} enregistrements sélectionnés';
	@override String get cancelSelectAll => 'Annuler la sélection';
	@override String get selectAll => 'Tout sélectionner';
	@override String get invertSelection => 'Inverser la sélection';
	@override String get exitEditMode => 'Quitter le mode édition';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Voulez-vous vraiment supprimer les ${num} éléments sélectionnés ?';
	@override String get searchHistoryRecords => 'Rechercher dans l\'historique...';
	@override String get settings => 'Réglages';
	@override String get subscriptions => 'Abonnements';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: '${n} vidéo',
		other: '${n} vidéos',
	);
	@override String get share => 'Partager';
	@override String get areYouSureYouWantToShareThisPlaylist => 'Voulez-vous vraiment partager cette liste de lecture ?';
	@override String get editTitle => 'Modifier le titre';
	@override String get editMode => 'Mode édition';
	@override String get pleaseEnterNewTitle => 'Veuillez saisir le nouveau titre';
	@override String get createPlayList => 'Créer une liste de lecture';
	@override String get create => 'Créer';
	@override String get checkNetworkSettings => 'Vérifier les paramètres réseau';
	@override String get general => 'Général';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Sensible';
	@override String get year => 'Année';
	@override String get month => 'Mois';
	@override String get tag => 'Tag';
	@override String get private => 'Privé';
	@override String get noTitle => 'Sans titre';
	@override String get search => 'Rechercher';
	@override String get noContent => 'Aucun contenu';
	@override String get recording => 'Enregistrement';
	@override String get paused => 'En pause';
	@override String get clear => 'Effacer';
	@override String get clearSelection => 'Effacer la sélection';
	@override String get selectItemsToContinue => 'Sélectionnez des éléments pour continuer';
	@override String andMoreItems({required Object num}) => 'et ${num} de plus';
	@override String get batchDelete => 'Suppression groupée';
	@override String get user => 'Utilisateur';
	@override String get post => 'Publier';
	@override String get seconds => 'Secondes';
	@override String get comingSoon => 'Bientôt disponible';
	@override String get confirm => 'Confirmer';
	@override String get hour => 'Heure';
	@override String get minute => 'Minute';
	@override String get clickToRefresh => 'Cliquez pour actualiser';
	@override String get history => 'Historique';
	@override String get favorites => 'Favoris';
	@override String get friends => 'Amis';
	@override String get playList => 'Liste de lecture';
	@override String get checkLicense => 'Vérifier la licence';
	@override String get logout => 'Déconnexion';
	@override String get fensi => 'Abonnés';
	@override String get accept => 'Accepter';
	@override String get reject => 'Refuser';
	@override String get clearAllHistory => 'Effacer tout l\'historique';
	@override String get clearAllHistoryConfirm => 'Voulez-vous vraiment effacer tout l\'historique ?';
	@override String get followingList => 'Liste des abonnements';
	@override String get followersList => 'Liste des abonnés';
	@override String get follows => 'Abonnements';
	@override String get fans => 'Abonnés';
	@override String get followsAndFans => 'Abonnements et abonnés';
	@override String get numViews => 'Vues';
	@override String get updatedAt => 'Mis à jour le';
	@override String get publishedAt => 'Publié le';
	@override String get externalVideo => 'Vidéo externe';
	@override String get originalText => 'Texte original';
	@override String get showOriginalText => 'Afficher le texte d\'origine';
	@override String get showProcessedText => 'Afficher le texte traité';
	@override String get preview => 'Aperçu';
	@override String get rules => 'Règles';
	@override String get agree => 'Accepter';
	@override String get disagree => 'Refuser';
	@override String get agreeToRules => 'Accepter les règles';
	@override String get markdownSyntaxHelp => 'Aide sur la syntaxe Markdown';
	@override String get previewContent => 'Aperçu du contenu';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Dépasse la longueur maximale (${max})';
	@override String get agreeToCommunityRules => 'Accepter les règles de la communauté';
	@override String get createPost => 'Créer une publication';
	@override String get title => 'Titre';
	@override String get enterTitle => 'Veuillez saisir le titre';
	@override String get content => 'Contenu';
	@override String get enterContent => 'Veuillez saisir le contenu';
	@override String get writeYourContentHere => 'Veuillez saisir le contenu...';
	@override String get tagBlacklist => 'Liste noire de tags';
	@override String get noData => 'Aucune donnée';
	@override String get tagLimit => 'Limite de tags';
	@override String get enableFloatingButtons => 'Activer les boutons flottants';
	@override String get disableFloatingButtons => 'Désactiver les boutons flottants';
	@override String get enabledFloatingButtons => 'Boutons flottants activés';
	@override String get disabledFloatingButtons => 'Boutons flottants désactivés';
	@override String get pendingCommentCount => 'Commentaires en attente';
	@override String joined({required Object str}) => 'Membre depuis ${str}';
	@override String lastSeenAt({required Object str}) => 'Vu pour la dernière fois ${str}';
	@override String get download => 'Télécharger';
	@override String get selectQuality => 'Choisir la qualité';
	@override String get videoQualitySource => 'Source';
	@override String get selectImageQuality => 'Choisir la qualité d\'image';
	@override String get imageQualityStandard => 'Standard';
	@override String get imageQualityOriginal => 'Originale';
	@override String get selectDateRange => 'Sélectionner une plage de dates';
	@override String get selectDateRangeHint => 'Sélectionnez une plage de dates ; par défaut, les 30 derniers jours';
	@override String get clearDateRange => 'Effacer la plage de dates';
	@override String get deleteRecordsInDateRange => 'Supprimer les enregistrements de cette plage';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'Voulez-vous vraiment supprimer ${num} enregistrements d\'historique dans cette plage de dates ? Cette action est irréversible.';
	@override String get noHistoryRecordsInRange => 'Aucun historique dans cette plage de dates';
	@override String get followSuccessClickAgainToSpecialFollow => 'Abonnement réussi, cliquez à nouveau pour un abonnement spécial';
	@override String get specialFollowTip => 'Ajouté aux abonnements spéciaux — sélectionnez-les dans le sélecteur en haut à droite de la page Abonnements pour y accéder rapidement';
	@override String get exitConfirmTip => 'Voulez-vous vraiment quitter ?';
	@override String get error => 'Erreur';
	@override String get taskRunning => 'Une tâche est déjà en cours, veuillez patienter.';
	@override String get operationCancelled => 'Opération annulée.';
	@override String get unsavedChanges => 'Vous avez des modifications non enregistrées';
	@override String get specialFollowsManagementTip => 'Faites glisser la poignée pour réorganiser • Appuyez sur le bouton pour supprimer';
	@override String get specialFollowsManagement => 'Gestion des abonnements spéciaux';
	@override String get removeSpecialFollow => 'Retirer l\'abonnement spécial';
	@override String removeSpecialFollowConfirm({required Object name}) => 'Retirer ${name} des abonnements spéciaux ?';
	@override String get noSpecialFollows => 'Aucun abonnement spécial';
	@override String get createTimeDesc => 'Date de création décroissante';
	@override String get createTimeAsc => 'Date de création croissante';
	@override late final _TranslationsCommonPaginationFr pagination = _TranslationsCommonPaginationFr._(_root);
	@override String get notice => 'Annonce';
	@override String get detail => 'Détail';
	@override String get parseExceptionDestopHint => '- Les utilisateurs sur ordinateur peuvent configurer un proxy dans les réglages';
	@override String get iwaraTags => 'Tags Iwara';
	@override String get tagInfo => 'Infos du tag';
	@override String get tagOriginalKey => 'Tag d\'origine';
	@override String get tagTranslation => 'Traduction';
	@override String get copy => 'Copier';
	@override String get selectCopy => 'Sélectionner et copier';
	@override String get copiedToClipboard => 'Copié dans le presse-papiers';
	@override String get showOriginalTag => 'Afficher le tag d\'origine';
	@override String get showTranslatedTag => 'Afficher la traduction';
	@override String get tagTranslationFeedback => 'Un doute sur une traduction ? Donnez votre avis';
	@override String get tagLocalizationGuideTitle => 'À propos de la localisation des tags';
	@override String get tagLocalizationGuideContent => 'L\'application affiche les tags bruts d\'Iwara (ex. mother) avec le nom dans votre langue actuelle.\n\n• Lors de la recherche de tags, la traduction et le tag d\'origine correspondent tous les deux.\n• Appuyez longuement ou faites un clic droit sur un tag pour voir et copier sa clé d\'origine et sa traduction.\n• Les traductions sont maintenues par la communauté, au mieux — elles peuvent contenir des erreurs.';
	@override String get likeThisVideo => 'Aimer cette vidéo';
	@override String get likeThisGallery => 'Aimer cette galerie';
	@override String get operation => 'Action';
	@override String get replies => 'Réponses';
	@override String get externalLinkWarning => 'Avertissement de lien externe';
	@override String get externalLinkWarningMessage => 'Vous êtes sur le point d\'ouvrir un lien externe qui ne fait pas partie d\'iwara.tv. Soyez prudent et vérifiez que le lien est sûr avant de continuer.';
	@override String get continueToExternalLink => 'Continuer';
	@override String get cancelExternalLink => 'Annuler';
}

// Path: auth
class _TranslationsAuthFr extends TranslationsAuthEn {
	_TranslationsAuthFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get login => 'Connexion';
	@override String get logout => 'Déconnexion';
	@override String get email => 'E-mail';
	@override String get password => 'Mot de passe';
	@override String get loginOrRegister => 'Connexion / Inscription';
	@override String get register => 'S\'inscrire';
	@override String get pleaseEnterEmail => 'Veuillez saisir votre e-mail';
	@override String get pleaseEnterPassword => 'Veuillez saisir votre mot de passe';
	@override String get passwordMustBeAtLeast6Characters => 'Le mot de passe doit comporter au moins 6 caractères';
	@override String get pleaseEnterCaptcha => 'Veuillez saisir le captcha';
	@override String get captcha => 'Captcha';
	@override String get refreshCaptcha => 'Actualiser le captcha';
	@override String get captchaNotLoaded => 'Captcha non chargé';
	@override String get loginSuccess => 'Connexion réussie';
	@override String get loginSuccessProfilePending => 'Connecté. Chargement de votre profil…';
	@override String get emailVerificationSent => 'E-mail de vérification envoyé';
	@override String get notLoggedIn => 'Non connecté';
	@override String get clickToLogin => 'Cliquez pour vous connecter';
	@override String get logoutConfirmation => 'Voulez-vous vraiment vous déconnecter ?';
	@override String get logoutSuccess => 'Déconnexion réussie';
	@override String get logoutFailed => 'Échec de la déconnexion';
	@override String get usernameOrEmail => 'Nom d\'utilisateur ou e-mail';
	@override String get pleaseEnterUsernameOrEmail => 'Veuillez saisir votre nom d\'utilisateur ou e-mail';
	@override String get rememberMe => 'Mémoriser le nom d\'utilisateur';
	@override String get registerNoticeTitle => 'S\'inscrire sur le site officiel';
	@override String get registerNoticeDescription => 'L\'inscription dans l\'application n\'est plus disponible. Rendez-vous sur le site officiel d\'Iwara pour créer votre compte, puis revenez ici pour vous connecter.';
	@override String get registerNoticeReturnTip => 'Après votre inscription, revenez ici et connectez-vous avec votre compte.';
	@override String get goToOfficialWebsite => 'Aller au site officiel';
}

// Path: errors
class _TranslationsErrorsFr extends TranslationsErrorsEn {
	_TranslationsErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get error => 'Erreur';
	@override String get required => 'Ce champ est obligatoire';
	@override String get invalidEmail => 'Adresse e-mail invalide';
	@override String get networkError => 'Erreur réseau, veuillez réessayer';
	@override String get errorWhileFetching => 'Erreur lors de la récupération';
	@override String get commentCanNotBeEmpty => 'Le contenu du commentaire ne peut pas être vide';
	@override String get errorWhileFetchingReplies => 'Erreur lors de la récupération des réponses, vérifiez la connexion réseau';
	@override String get canNotFindCommentController => 'Contrôleur de commentaires introuvable';
	@override String get errorWhileLoadingGallery => 'Erreur lors du chargement de la galerie';
	@override String get howCouldThereBeNoDataItCantBePossible => 'Comment pourrait-il ne pas y avoir de données ? C\'est impossible :<';
	@override String unsupportedImageFormat({required Object str}) => 'Format d\'image non pris en charge : ${str}';
	@override String get invalidGalleryId => 'ID de galerie invalide';
	@override String get translationFailedPleaseTryAgainLater => 'Échec de la traduction, veuillez réessayer plus tard';
	@override String get errorOccurred => 'Une erreur est survenue, veuillez réessayer plus tard.';
	@override String get errorOccurredWhileProcessingRequest => 'Une erreur est survenue lors du traitement de la requête';
	@override String get errorWhileFetchingDatas => 'Erreur lors de la récupération des données, veuillez réessayer plus tard';
	@override String get serviceNotInitialized => 'Service non initialisé';
	@override String get unknownType => 'Type inconnu';
	@override String errorWhileOpeningLink({required Object link}) => 'Erreur lors de l\'ouverture du lien : ${link}';
	@override String get invalidUrl => 'URL invalide';
	@override String get failedToOperate => 'Échec de l\'opération';
	@override String get permissionDenied => 'Permission refusée';
	@override String get youDoNotHavePermissionToAccessThisResource => 'Vous n\'avez pas la permission d\'accéder à cette ressource';
	@override String get loginFailed => 'Échec de la connexion';
	@override String get unknownError => 'Erreur inconnue';
	@override String get sessionExpired => 'Session expirée';
	@override String get failedToFetchCaptcha => 'Échec de la récupération du captcha';
	@override String get emailAlreadyExists => 'Cet e-mail existe déjà';
	@override String get invalidCaptcha => 'Captcha invalide';
	@override String get registerFailed => 'Échec de l\'inscription';
	@override String get failedToFetchComments => 'Échec de la récupération des commentaires';
	@override String get failedToFetchImageDetail => 'Échec de la récupération du détail de l\'image';
	@override String get failedToFetchImageList => 'Échec de la récupération de la liste des images';
	@override String get failedToFetchData => 'Échec de la récupération des données';
	@override String get invalidParameter => 'Paramètre invalide';
	@override String get pleaseLoginFirst => 'Veuillez d\'abord vous connecter';
	@override String get errorWhileLoadingPost => 'Erreur lors du chargement de la publication';
	@override String get errorWhileLoadingPostDetail => 'Erreur lors du chargement du détail de la publication';
	@override String get invalidPostId => 'ID de publication invalide';
	@override String get forceUpdateNotPermittedToGoBack => 'Mise à jour forcée en cours, impossible de revenir en arrière';
	@override String get pleaseLoginAgain => 'Veuillez vous reconnecter';
	@override String get invalidLogin => 'Connexion invalide, vérifiez votre e-mail et votre mot de passe';
	@override String get tooManyRequests => 'Trop de requêtes, veuillez réessayer plus tard';
	@override String exceedsMaxLength({required Object max}) => 'Dépasse la longueur maximale : ${max}';
	@override String get contentCanNotBeEmpty => 'Le contenu ne peut pas être vide';
	@override String get titleCanNotBeEmpty => 'Le titre ne peut pas être vide';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Trop de requêtes, veuillez réessayer plus tard ; restant';
	@override String remainingHours({required Object num}) => '${num} heures';
	@override String remainingMinutes({required Object num}) => '${num} min';
	@override String remainingSeconds({required Object num}) => '${num} secondes';
	@override String tagLimitExceeded({required Object limit}) => 'Limite de tags dépassée, limite : ${limit}';
	@override String get failedToRefresh => 'Échec de l\'actualisation';
	@override String get noPermission => 'Aucune permission';
	@override String get resourceNotFound => 'Ressource introuvable';
	@override String get failedToSaveCredentials => 'Échec de l\'enregistrement des identifiants de connexion';
	@override String get failedToLoadSavedCredentials => 'Échec du chargement des identifiants enregistrés';
	@override String get notFound => 'Contenu introuvable ou supprimé';
	@override late final _TranslationsErrorsNetworkFr network = _TranslationsErrorsNetworkFr._(_root);
}

// Path: friends
class _TranslationsFriendsFr extends TranslationsFriendsEn {
	_TranslationsFriendsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Cliquez pour restaurer l\'ami';
	@override String get friendsList => 'Liste d\'amis';
	@override String get friendRequests => 'Demandes d\'amis';
	@override String get friendRequestsList => 'Liste des demandes d\'amis';
	@override String get removingFriend => 'Retrait de l\'ami...';
	@override String get failedToRemoveFriend => 'Échec du retrait de l\'ami';
	@override String get cancelingRequest => 'Annulation de la demande d\'ami...';
	@override String get failedToCancelRequest => 'Échec de l\'annulation de la demande d\'ami';
}

// Path: authorProfile
class _TranslationsAuthorProfileFr extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'Plus de données';
	@override String get userProfile => 'Profil utilisateur';
}

// Path: favorites
class _TranslationsFavoritesFr extends TranslationsFavoritesEn {
	_TranslationsFavoritesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Cliquez pour restaurer le favori';
	@override String get myFavorites => 'Mes favoris';
	@override String get batchCancelFavorite => 'Retirer les favoris sélectionnés';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'Retirer les ${count} éléments sélectionnés des favoris ? Vous pourrez les restaurer en touchant les cartes ensuite.';
	@override String batchCancelFavoriteSuccess({required Object count}) => '${count} élément(s) retiré(s) des favoris';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => '${success} élément(s) retiré(s), ${failed} en échec';
}

// Path: galleryDetail
class _TranslationsGalleryDetailFr extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Parcourir dans l\'espace';
	@override String get galleryDetail => 'Détail de la galerie';
	@override String get viewGalleryDetail => 'Voir le détail de la galerie';
	@override String get zoomReset => 'Réinitialiser le zoom';
	@override String get copyLink => 'Copier le lien';
	@override String get copyImage => 'Copier l\'image';
	@override String get saveAs => 'Enregistrer sous';
	@override String get saveToAlbum => 'Enregistrer dans l\'album';
	@override String get publishedAt => 'Publié le';
	@override String get viewsCount => 'Nombre de vues';
	@override String get imageLibraryFunctionIntroduction => 'Présentation des fonctions de la bibliothèque d\'images';
	@override String get rightClickToSaveSingleImage => 'Clic droit pour enregistrer l\'image seule';
	@override String get batchSave => 'Enregistrement groupé';
	@override String get keyboardLeftAndRightToSwitch => 'Flèches gauche et droite pour changer';
	@override String get keyboardUpAndDownToZoom => 'Flèches haut et bas pour zoomer';
	@override String get mouseWheelToSwitch => 'Molette pour changer';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + molette pour zoomer';
	@override String get moreFeaturesToBeDiscovered => 'D\'autres fonctions à découvrir...';
	@override String get authorOtherGalleries => 'Autres galeries de l\'auteur';
	@override String get relatedGalleries => 'Galeries associées';
	@override String get authorNoOtherGalleries => 'Aucune autre galerie de cet auteur';
	@override String get noRelatedGalleries => 'Aucune galerie associée';
	@override String get scrollLeft => 'Défiler à gauche';
	@override String get scrollRight => 'Défiler à droite';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Cliquez sur les bords gauche et droit pour changer d\'image';
	@override String get rotateToLandscape => 'Plein écran paysage';
	@override String get backToPortrait => 'Revenir au portrait';
}

// Path: playList
class _TranslationsPlayListFr extends TranslationsPlayListEn {
	_TranslationsPlayListFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Mes playlists';
	@override String get friendlyTips => 'Conseils';
	@override String get dearUser => 'Cher utilisateur';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'Le système de playlists d\'iwara n\'est pas encore parfait';
	@override String get notSupportSetCover => 'Définition de la couverture non prise en charge';
	@override String get notSupportDeleteList => 'Suppression de liste non prise en charge';
	@override String get notSupportSetPrivate => 'Passage en privé non pris en charge';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Oui... la liste créée existera toujours et sera visible par tout le monde';
	@override String get smallSuggestion => 'Petit conseil';
	@override String get useLikeToCollectContent => 'Si vous tenez davantage à votre confidentialité, il est conseillé d\'utiliser la fonction « J\'aime » pour enregistrer du contenu';
	@override String get welcomeToDiscussOnGitHub => 'Si vous avez d\'autres suggestions ou idées, n\'hésitez pas à en discuter sur GitHub !';
	@override String get iUnderstand => 'J\'ai compris';
	@override String get searchPlaylists => 'Rechercher des playlists...';
	@override String get newPlaylistName => 'Nom de la nouvelle playlist';
	@override String get createNewPlaylist => 'Créer une playlist';
	@override String get videos => 'Vidéos';
}

// Path: search
class _TranslationsSearchFr extends TranslationsSearchEn {
	_TranslationsSearchFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Portée de la recherche';
	@override String get searchTags => 'Rechercher des tags...';
	@override String get contentRating => 'Classification du contenu';
	@override String get removeTag => 'Retirer le tag';
	@override String get pleaseEnterSearchContent => 'Veuillez saisir le contenu à rechercher';
	@override String get searchHistory => 'Historique de recherche';
	@override String get searchSuggestion => 'Suggestion de recherche';
	@override String get usedTimes => 'Nombre d\'utilisations';
	@override String get lastUsed => 'Dernière utilisation';
	@override String get noSearchHistoryRecords => 'Aucun historique de recherche';
	@override String get clearSearchHistoryConfirm => 'Voulez-vous vraiment effacer tout l\'historique de recherche ? Cette action est irréversible.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Type de recherche actuel ${searchType} non pris en charge, veuillez attendre la mise à jour';
	@override String get searchResult => 'Résultat de recherche';
	@override String unsupportedSearchType({required Object searchType}) => 'Type de recherche non pris en charge : ${searchType}';
	@override String get googleSearch => 'Recherche Google';
	@override String googleSearchHint({required Object webName}) => '${webName}, la fonction de recherche n\'est pas pratique ? Essayez la recherche Google !';
	@override String get googleSearchDescription => 'Utilisez l\'opérateur de recherche :site de Google pour chercher du contenu sur le site. Très utile pour rechercher des vidéos, galeries, playlists et utilisateurs.';
	@override String get googleSearchKeywordsHint => 'Saisir des mots-clés à rechercher';
	@override String get openLinkJump => 'Saut de lien';
	@override String get googleSearchButton => 'Recherche Google';
	@override String get pleaseEnterSearchKeywords => 'Veuillez saisir des mots-clés';
	@override String get googleSearchQueryCopied => 'Requête de recherche copiée';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'Échec de l\'ouverture du navigateur : ${error}';
	@override String get searchRequestTimeout => 'Délai de la requête dépassé, veuillez réessayer plus tard';
	@override String get searchCannotConnectToServer => 'Impossible de se connecter au serveur, veuillez vérifier votre connexion réseau';
	@override String get searchNetworkError => 'Échec de la connexion réseau, veuillez vérifier vos paramètres réseau ou réessayer plus tard';
	@override String get searchFailedPleaseRetry => 'Échec de la recherche, veuillez réessayer plus tard';
}

// Path: mediaList
class _TranslationsMediaListFr extends TranslationsMediaListEn {
	_TranslationsMediaListFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Présentation';
}

// Path: settings
class _TranslationsSettingsFr extends TranslationsSettingsEn {
	_TranslationsSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Mode liste';
	@override String get previewEffect => 'Aperçu de l\'effet';
	@override String get useTraditionalPaginationMode => 'Utiliser la pagination classique';
	@override String get useTraditionalPaginationModeDesc => 'Activer la pagination classique et désactiver le mode cascade. Prend effet après un nouveau rendu de la page ou un redémarrage de l\'app';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Afficher la barre de progression vidéo en bas lorsque la barre d\'outils est masquée';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Ce réglage détermine si la barre de progression vidéo en bas s\'affiche lorsque la barre d\'outils est masquée.';
	@override String get seekPreviewSize => 'Taille de l\'aperçu de navigation';
	@override String get seekPreviewSizeDesc => 'Taille de la fenêtre d\'aperçu au-dessus de la barre de progression. Elle suit déjà la taille du lecteur et les proportions de la vidéo ; ce réglage ne fait que l\'ajuster légèrement.';
	@override String get seekPreviewSizeSmall => 'Petite';
	@override String get seekPreviewSizeStandard => 'Standard';
	@override String get seekPreviewSizeLarge => 'Grande';
	@override String get seekPreviewSizeStandardDesc => 'La taille dérivée du lecteur et de la vidéo';
	@override String get showFullscreenUpNextHint => 'Afficher la poignée « À suivre »';
	@override String get showFullscreenUpNextHintDesc => 'Affiche une petite poignée sur le bord droit du lecteur, qui ouvre le tiroir de la file (source / playlist / à regarder plus tard). Une fois désactivée, il n\'y a plus d\'autre accès.';
	@override String get basicSettings => 'Paramètres de base';
	@override String get personalizedSettings => 'Paramètres personnalisés';
	@override String get otherSettings => 'Autres paramètres';
	@override String get searchConfig => 'Configuration de recherche';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Ce réglage détermine si la configuration précédente est réutilisée lors de la lecture suivante de vidéos.';
	@override String get playControl => 'Contrôle de lecture';
	@override String get playbackSpeedSettings => 'Lecture et vitesse';
	@override String get playbackBehaviorSettings => 'Comportement de lecture';
	@override String get enhancementSettings => 'Théâtre et améliorations';
	@override String get fastForwardTime => 'Durée d\'avance rapide';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'La durée d\'avance rapide doit être un entier positif.';
	@override String get rewindTime => 'Durée de retour arrière';
	@override String get rewindTimeMustBeAPositiveInteger => 'La durée de retour arrière doit être un entier positif.';
	@override String get longPressPlaybackSpeed => 'Vitesse en appui long';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'La vitesse de lecture en appui long doit être un nombre positif.';
	@override String get defaultPlaybackSpeed => 'Vitesse de lecture par défaut';
	@override String get rememberPlaybackSpeed => 'Mémoriser la vitesse de lecture';
	@override String get rememberPlaybackSpeedDesc => 'Une fois activé, la vitesse définie dans le lecteur est enregistrée comme valeur par défaut et appliquée automatiquement aux nouvelles vidéos.';
	@override String get repeat => 'Répéter';
	@override String get renderVerticalVideoInVerticalScreen => 'Afficher les vidéos verticales en écran vertical';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Ce réglage détermine si la vidéo est affichée en écran vertical lors de la lecture en plein écran.';
	@override String get rememberVolume => 'Mémoriser le volume';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Ce réglage détermine si le volume est conservé lors de la lecture suivante de vidéos.';
	@override String get rememberBrightness => 'Mémoriser la luminosité';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Ce réglage détermine si la luminosité est conservée lors de la lecture suivante de vidéos.';
	@override String get playControlArea => 'Zone de contrôle de lecture';
	@override String get leftAndRightControlAreaWidth => 'Largeur des zones de contrôle gauche et droite';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Ce réglage détermine la largeur des zones de contrôle à gauche et à droite du lecteur.';
	@override String get proxyAddressCannotBeEmpty => 'L\'adresse du proxy ne peut pas être vide.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Format d\'adresse proxy non valide. Utilisez le format IP:port ou nom de domaine:port.';
	@override String get proxyNormalWork => 'Le proxy fonctionne normalement.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Échec du test du proxy, code d\'état : ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Échec du test du proxy, exception : ${exception}';
	@override String get proxyConfig => 'Configuration du proxy';
	@override String get thisIsHttpProxyAddress => 'Il s\'agit de l\'adresse du proxy HTTP';
	@override String get checkProxy => 'Vérifier le proxy';
	@override String get proxyAddress => 'Adresse du proxy';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Veuillez saisir l\'URL du serveur proxy, par exemple 127.0.0.1:8080';
	@override String get enableProxy => 'Activer le proxy';
	@override String get left => 'Gauche';
	@override String get middle => 'Milieu';
	@override String get right => 'Droite';
	@override String get playerSettings => 'Paramètres du lecteur';
	@override String get networkSettings => 'Paramètres réseau';
	@override String get customizeYourPlaybackExperience => 'Personnalisez votre expérience de lecture';
	@override String get chooseYourFavoriteAppAppearance => 'Choisissez l\'apparence de votre app';
	@override String get configureYourProxyServer => 'Configurez votre serveur proxy';
	@override String get settings => 'Paramètres';
	@override String get themeSettings => 'Paramètres de thème';
	@override String get followSystem => 'Suivre le système';
	@override String get lightMode => 'Mode clair';
	@override String get darkMode => 'Mode sombre';
	@override String get presetTheme => 'Thème prédéfini';
	@override String get basicTheme => 'Thème de base';
	@override String get needRestartToApply => 'Redémarrez l\'app pour appliquer les paramètres';
	@override String get themeNeedRestartDescription => 'Les paramètres de thème nécessitent de redémarrer l\'app pour être appliqués';
	@override String get about => 'À propos';
	@override String get diagnosticsAndFeedback => 'Diagnostic et retours';
	@override String get currentVersion => 'Version actuelle';
	@override String get latestVersion => 'Dernière version';
	@override String get checkForUpdates => 'Rechercher des mises à jour';
	@override String get update => 'Mettre à jour';
	@override String get newVersionAvailable => 'Nouvelle version disponible';
	@override String get projectHome => 'Accueil du projet';
	@override String get release => 'Versions';
	@override String get issueReport => 'Signaler un problème';
	@override String get openSourceLicense => 'Licence open source';
	@override String get checkForUpdatesFailed => 'Échec de la recherche de mises à jour, veuillez réessayer plus tard';
	@override String get autoCheckUpdate => 'Recherche auto. des mises à jour';
	@override String get updateContent => 'Contenu de la mise à jour';
	@override String get releaseDate => 'Date de publication';
	@override String get ignoreThisVersion => 'Ignorer cette version';
	@override String get forceUpdateTip => 'Cette mise à jour est obligatoire. Veuillez passer dès que possible à la dernière version';
	@override String get viewChangelog => 'Voir le journal des modifications';
	@override String get alreadyLatestVersion => 'Vous avez déjà la dernière version';
	@override String get appSettings => 'Paramètres de l\'app';
	@override String get configureYourAppSettings => 'Configurez les paramètres de votre app';
	@override String get history => 'Historique';
	@override String get autoRecordHistory => 'Enregistrement auto. de l\'historique';
	@override String get autoRecordHistoryDesc => 'Enregistrer automatiquement les vidéos et images que vous avez regardées';
	@override String get autoDeleteHistory => 'Nettoyage auto. de l\'historique';
	@override String get autoDeleteHistoryDesc => 'Supprimer automatiquement au démarrage l\'historique de navigation plus ancien que la durée de conservation (désactivé par défaut)';
	@override String get autoDeleteHistoryDays => 'Jours de conservation';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Conserver les ${num} derniers jours';
	@override String get autoDeleteHistoryDaysInvalid => 'Veuillez saisir un nombre de jours valide (au moins 1)';
	@override String get showUnprocessedMarkdownText => 'Afficher le texte Markdown brut';
	@override String get showUnprocessedMarkdownTextDesc => 'Afficher le texte d\'origine du markdown';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Mode confidentialité';
	@override String get activeBackgroundPrivacyModeDesc => 'Bloquer les captures d\'écran et l\'enregistrement, et masquer l\'écran en arrière-plan';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Masquer l\'écran lorsque l\'app passe en arrière-plan (cette plateforme ne peut pas bloquer les captures d\'écran)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Bloquer les captures d\'écran et l\'enregistrement d\'écran';
	@override String get privacy => 'Confidentialité';
	@override String get appLock => 'Verrouillage de l\'app';
	@override String get appLockEnabled => 'Activer le verrouillage de l\'app';
	@override String get appLockEnabledDesc => 'Exiger un code PIN ou une donnée biométrique pour ouvrir l\'app ; l\'aperçu en arrière-plan est masqué automatiquement';
	@override String get appLockEnabledSummary => 'Activé · protégé par code PIN';
	@override String get appLockDisabledSummary => 'Désactivé';
	@override String get appLockTimeout => 'Verrouiller après avoir quitté l\'app';
	@override String get appLockTimeoutDesc => 'Temps autorisé en arrière-plan avant qu\'une authentification soit requise';
	@override String get appLockAfterScreenOff => 'Verrouiller après le verrouillage de l\'écran';
	@override String get appLockAfterScreenOffDesc => 'Exiger une authentification après le verrouillage de l\'écran de l\'appareil';
	@override String get appLockTimeoutDisabled => 'Désactivé';
	@override String get appLockImmediately => 'Immédiatement';
	@override String appLockSeconds({required Object seconds}) => '${seconds} secondes';
	@override String appLockMinutes({required Object minutes}) => '${minutes} minutes';
	@override String get appLockUseBiometrics => 'Utiliser la biométrie';
	@override String get appLockUseBiometricsDesc => 'Déverrouiller par empreinte digitale ou reconnaissance faciale';
	@override String get appLockBiometricsUnavailable => 'Aucune donnée biométrique enregistrée sur cet appareil';
	@override String get appLockSetPin => 'Définir le code PIN';
	@override String get appLockEnterPin => 'Saisir le code PIN';
	@override String get appLockConfirmPin => 'Confirmer le code PIN';
	@override String get appLockCurrentPin => 'Saisir le code PIN actuel';
	@override String get appLockNewPin => 'Saisir le nouveau code PIN';
	@override String get appLockPinRequirements => 'Le code PIN doit comporter 4 à 8 chiffres';
	@override String get appLockPinsDoNotMatch => 'Les codes PIN ne correspondent pas';
	@override String get appLockInvalidPin => 'Code PIN incorrect';
	@override String get appLockSetupFailed => 'Impossible d\'enregistrer le code PIN en toute sécurité';
	@override String get appLockDisable => 'Saisir le code PIN pour désactiver le verrouillage';
	@override String get appLockChangePin => 'Modifier le code PIN';
	@override String get appLockNow => 'Verrouiller maintenant';
	@override String get appLockUnlock => 'Déverrouiller';
	@override String get appLockLockedTitle => 'Verrouillé';
	@override String get appLockLockedDesc => 'Authentifiez-vous pour continuer';
	@override String get appLockAuthenticateReason => 'Authentifiez-vous pour déverrouiller';
	@override String get appLockEnableBiometricsReason => 'Authentifiez-vous pour activer le déverrouillage biométrique';
	@override String get appLockBiometricFailed => 'L\'authentification biométrique n\'a pas abouti';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Trop de tentatives. Réessayez dans ${seconds} s';
	@override String get appLockCredentialUnavailableTitle => 'Impossible de lire l\'identifiant de verrouillage de l\'app';
	@override String get appLockCredentialUnavailableDesc => 'Le stockage sécurisé du système est temporairement indisponible ou l\'identifiant est corrompu. L\'application reste verrouillée. Réessayez d\'abord ; si l\'échec persiste, vous pouvez réinitialiser le verrouillage de l\'app, ce qui le désactive et efface le code PIN enregistré.';
	@override String get appLockRetry => 'Réessayer';
	@override String get appLockReset => 'Réinitialiser le verrouillage';
	@override String get appLockResetAction => 'Réinitialiser';
	@override String get appLockResetConfirmTitle => 'Réinitialiser le verrouillage de l\'app ?';
	@override String get appLockResetConfirmDesc => 'Cela désactive le verrouillage de l\'app et efface le code PIN et le réglage biométrique enregistrés. Vous pourrez le reconfigurer ensuite.';
	@override String get appLockRetrySucceeded => 'Lecture de l\'identifiant réussie. Saisissez votre code PIN.';
	@override String get appLockRetryFailed => 'Toujours impossible de lire l\'identifiant';
	@override String get forum => 'Forum';
	@override String get news => 'Actualités';
	@override String get community => 'Communauté';
	@override String get disableForumReplyQuote => 'Désactiver la citation des réponses du forum';
	@override String get disableForumReplyQuoteDesc => 'Ne pas reprendre les informations du message cité lors d\'une réponse sur le forum';
	@override String get theaterMode => 'Mode théâtre';
	@override String get theaterModeDesc => 'Une fois activé, l\'arrière-plan du lecteur devient la version floutée de la couverture de la vidéo';
	@override String get appLinks => 'Liens de l\'app';
	@override String get defaultBrowser => 'Navigation par défaut';
	@override String get defaultBrowserDesc => 'Ouvrez l\'élément « liens par défaut » dans les réglages système et ajoutez le lien du site iwara.tv';
	@override String get themeMode => 'Mode de thème';
	@override String get themeModeDesc => 'Ce réglage détermine le mode de thème de l\'app';
	@override String get glassEffect => 'Matériau de l\'interface';
	@override String get glassEffectDesc => 'Choisit le matériau utilisé dans toute l\'app — capsules d\'en-tête, menus, boutons de dialogue et barre de navigation inférieure';
	@override String get liquidGlassEffect => 'Verre liquide';
	@override String get liquidGlassEffectDesc => 'Véritable flou et réfraction. Le plus beau, mais peut entraîner des saccades et consommer un peu plus d\'énergie sur les appareils d\'entrée de gamme';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Surfaces Material 3 standard — opaques, sans flou ni ombres. Meilleures performances et autonomie';
	@override String get glassEffectIntroTitle => 'Choisissez le matériau de votre interface';
	@override String get glassEffectIntroContent => 'Les en-têtes, la barre d\'onglets et les menus utilisent le verre liquide — véritable flou et réfraction. Si cela paraît lent sur votre appareil, ou si vous préférez plus sobre, passez à Material (surfaces opaques, sans flou ni ombres).';
	@override String get glassEffectIntroHint => 'Vous pouvez modifier ce choix à tout moment dans Paramètres → Thème → Matériau de l\'interface.';
	@override String get glassEffectIntroDone => 'Conserver';
	@override String get dynamicColor => 'Couleur dynamique';
	@override String get dynamicColorDesc => 'Ce réglage détermine si l\'app utilise la couleur dynamique';
	@override String get useDynamicColor => 'Utiliser la couleur dynamique';
	@override String get useDynamicColorDesc => 'Ce réglage détermine si l\'app utilise la couleur dynamique';
	@override String get presetColors => 'Couleurs prédéfinies';
	@override String get customColors => 'Couleurs personnalisées';
	@override String get customColorsDisabledByDynamicColor => 'La couleur dynamique est activée, les couleurs prédéfinies/personnalisées sont donc indisponibles. Désactivez d\'abord la couleur dynamique.';
	@override String get pickColor => 'Choisir une couleur';
	@override String get cancel => 'Annuler';
	@override String get confirm => 'Confirmer';
	@override String get noCustomColors => 'Aucune couleur personnalisée';
	@override String get recordAndRestorePlaybackProgress => 'Mémoriser et restaurer la progression de lecture';
	@override String get autoPlayVideoOnFirstEnter => 'Lecture auto. à la première ouverture';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Ce réglage détermine si la vidéo démarre automatiquement lors de la première ouverture de la page vidéo.';
	@override String get autoEnterFullscreen => 'Passer en plein écran automatiquement';
	@override String get autoEnterFullscreenDesc => 'Quand le lecteur doit passer en plein écran de lui-même. Les vidéos privées, supprimées et externes ne sont jamais concernées, tout comme l\'incrustation d\'image.';
	@override String get autoEnterFullscreenOff => 'Désactivé';
	@override String get autoEnterFullscreenOffDesc => 'Ne jamais passer en plein écran automatiquement';
	@override String get autoEnterFullscreenOnPlaybackStart => 'Au démarrage de la lecture';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Passer en plein écran dès que la lecture commence réellement';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'À l\'ouverture de la vidéo';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Passer en plein écran dès l\'ouverture de la page vidéo, sans attendre la lecture';
	@override String get autoEnterFullscreenKind => 'Type de plein écran';
	@override String get autoEnterFullscreenKindDesc => 'Quel type de plein écran activer automatiquement. Bureau uniquement.';
	@override String get autoEnterFullscreenKindSystem => 'Plein écran système';
	@override String get autoEnterFullscreenKindSystemDesc => 'Laisser le gestionnaire de fenêtres passer la fenêtre en plein écran';
	@override String get autoEnterFullscreenKindApp => 'Plein écran de l\'app';
	@override String get autoEnterFullscreenKindAppDesc => 'Conserver la fenêtre telle quelle et transformer toute l\'app en lecteur';
	@override String get signature => 'Signature';
	@override String get enableSignature => 'Activer la signature';
	@override String get enableSignatureDesc => 'Ce réglage détermine si l\'app ajoute la signature lors des réponses';
	@override String get enterSignature => 'Saisir la signature';
	@override String get editSignature => 'Modifier la signature';
	@override String get signatureContent => 'Contenu de la signature';
	@override String get exportConfig => 'Exporter la configuration de l\'app';
	@override String get exportConfigDesc => 'Exporter les paramètres et l\'historique (historique de navigation, progression de lecture, favoris, etc.) dans un fichier pour sauvegarde ou transfert vers un autre appareil. Les tâches de téléchargement ne sont pas incluses.';
	@override String get importConfig => 'Importer la configuration de l\'app';
	@override String get importConfigDesc => 'Importer la configuration de l\'app depuis un fichier';
	@override String get exportConfigSuccess => 'Configuration exportée !';
	@override String get exportConfigFailed => 'Échec de l\'export de la configuration';
	@override String get importConfigSuccess => 'Configuration importée !';
	@override String get importConfigFailed => 'Échec de l\'import de la configuration';
	@override String get exportIncludeSensitive => 'Inclure les infos sensibles';
	@override String get exportIncludeSensitiveDesc => 'Inclut les clés d\'API, les jetons de session et l\'adresse du proxy. À activer uniquement pour une sauvegarde sur votre propre appareil.';
	@override String get importConfigOverwriteWarning => 'L\'import écrasera vos paramètres et votre historique actuels (historique de navigation, progression de lecture, favoris, etc.). Continuer ?';
	@override String get importConfigRestartTitle => 'Import réussi';
	@override String get importConfigRestartContent => 'Votre configuration a été importée. Veuillez fermer complètement puis rouvrir l\'app pour que tous les changements prennent effet.';
	@override String get historyUpdateLogs => 'Historique des mises à jour';
	@override String get noUpdateLogs => 'Aucun journal de mise à jour disponible';
	@override String get versionLabel => 'Version : {version}';
	@override String get releaseDateLabel => 'Date de publication : {date}';
	@override String get noChanges => 'Aucun contenu de mise à jour disponible';
	@override String get interaction => 'Interaction';
	@override String get enableVibration => 'Activer les vibrations';
	@override String get enableVibrationDesc => 'Activer le retour par vibration lors des interactions avec l\'app';
	@override String get defaultKeepVideoToolbarVisible => 'Garder la barre d\'outils vidéo visible';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Ce réglage détermine si la barre d\'outils vidéo reste visible à la première ouverture de la page vidéo.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Sur mobile, le mode théâtre peut entraîner des problèmes de performance. Vous pouvez choisir de l\'activer.';
	@override String get fullscreenOrientation => 'Orientation de l\'écran après le plein écran';
	@override String get fullscreenOrientationDesc => 'Ce réglage détermine l\'orientation d\'écran par défaut lors du passage en plein écran (mobile uniquement)';
	@override String get fullscreenOrientationLeftLandscape => 'Paysage gauche';
	@override String get fullscreenOrientationRightLandscape => 'Paysage droite';
	@override String get screenFit => 'Taille d\'écran';
	@override String get screenFitDesc => 'Choisir comment la vidéo remplit la zone du lecteur.';
	@override String get rememberScreenFit => 'Mémoriser la taille d\'écran';
	@override String get rememberScreenFitDesc => 'Appliquer la taille sélectionnée aux vidéos ouvertes ensuite.';
	@override String get screenFitFit => 'Ajuster';
	@override String get screenFitFitDesc => 'Afficher toute l\'image en conservant les proportions';
	@override String get screenFitStretch => 'Étirer';
	@override String get screenFitStretchDesc => 'Remplir la zone du lecteur ; l\'image peut être déformée';
	@override String get screenFitCover => 'Remplir';
	@override String get screenFitCoverDesc => 'Remplir la zone du lecteur en conservant les proportions ; le surplus est rogné';
	@override String get screenFitRatioDesc => 'Forcer ces proportions ; l\'image peut être déformée';
	@override String get jumpLink => 'Saut de lien';
	@override String get language => 'Langue';
	@override String get languageNativeName => 'Français';
	@override String get followSystemLanguage => 'Suivre le système';
	@override String get languageChangedMessage => 'Langue modifiée. Certaines fonctions nécessitent un redémarrage de l\'application.';
	@override String get languageChanged => 'Le réglage de langue a été modifié ; veuillez redémarrer l\'app pour qu\'il prenne effet.';
	@override late final _TranslationsSettingsKeybindingFr keybinding = _TranslationsSettingsKeybindingFr._(_root);
	@override String get gestureControl => 'Contrôle gestuel';
	@override String get leftDoubleTapRewind => 'Double tap à gauche : reculer';
	@override String get rightDoubleTapFastForward => 'Double tap à droite : avance rapide';
	@override String get doubleTapPause => 'Pause au double tap';
	@override String get rightVerticalSwipeVolume => 'Glissement vertical à droite : volume (effectif à l\'ouverture d\'une nouvelle page)';
	@override String get leftVerticalSwipeBrightness => 'Glissement vertical à gauche : luminosité (effectif à l\'ouverture d\'une nouvelle page)';
	@override String get longPressFastForward => 'Appui long : avance rapide';
	@override String get enableMouseHoverShowToolbar => 'Afficher la barre d\'outils au survol de la souris';
	@override String get enableMouseHoverShowToolbarInfo => 'Une fois activé, la barre d\'outils vidéo s\'affiche lorsque la souris survole le lecteur. Elle se masque automatiquement après 3 secondes d\'inactivité.';
	@override String get enableHorizontalDragSeek => 'Balayage horizontal pour naviguer';
	@override String get enableVideoGestureZoom => 'Pincer pour zoomer l\'image vidéo';
	@override String get enableVideoGestureZoomInfo => 'Pincez avec deux doigts (ou Ctrl + molette sur ordinateur) pour zoomer l\'image vidéo, puis faites glisser pour la déplacer.';
	@override String get showCenterPlayPauseButton => 'Bouton lecture/pause au centre';
	@override String get showCenterPlayPauseButtonDesc => 'Afficher le grand bouton lecture/pause au centre du lecteur.';
	@override String get audioVideoConfig => 'Configuration audio et vidéo';
	@override String get expandBuffer => 'Étendre le tampon';
	@override String get expandBufferInfo => 'Une fois activé, la taille du tampon augmente : le chargement est plus long, mais la lecture plus fluide';
	@override String get videoSyncMode => 'Mode de synchro A/V';
	@override String get videoSyncModeSubtitle => 'Stratégie de synchronisation audio-vidéo';
	@override String get hardwareDecodingMode => 'Mode de décodage matériel';
	@override String get hardwareDecodingModeSubtitle => 'Paramètres de décodage matériel';
	@override String get enableHardwareAcceleration => 'Activer l\'accélération matérielle';
	@override String get enableHardwareAccelerationInfo => 'Activer l\'accélération matérielle peut améliorer les performances de décodage, mais certains appareils peuvent être incompatibles';
	@override String get useOpenSLESAudioOutput => 'Utiliser la sortie audio OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'Utiliser une sortie audio à faible latence, peut améliorer les performances audio';
	@override String get videoSyncAudio => 'Synchro audio';
	@override String get videoSyncDisplayResample => 'Afficher le rééchantillonnage';
	@override String get videoSyncDisplayResampleVdrop => 'Afficher rééchantillonnage (perte de trames)';
	@override String get videoSyncDisplayResampleDesync => 'Afficher rééchantillonnage (désynchro)';
	@override String get videoSyncDisplayTempo => 'Afficher le tempo';
	@override String get videoSyncDisplayVdrop => 'Afficher : perte de trames vidéo';
	@override String get videoSyncDisplayAdrop => 'Afficher : perte de trames audio';
	@override String get videoSyncDisplayDesync => 'Afficher la désynchro';
	@override String get videoSyncDesync => 'Désynchro';
	@override late final _TranslationsSettingsForumSettingsFr forumSettings = _TranslationsSettingsForumSettingsFr._(_root);
	@override late final _TranslationsSettingsGallerySettingsFr gallerySettings = _TranslationsSettingsGallerySettingsFr._(_root);
	@override late final _TranslationsSettingsBlockSettingsFr blockSettings = _TranslationsSettingsBlockSettingsFr._(_root);
	@override late final _TranslationsSettingsChatSettingsFr chatSettings = _TranslationsSettingsChatSettingsFr._(_root);
	@override String get hardwareDecodingAuto => 'Auto';
	@override String get hardwareDecodingAutoCopy => 'Copie auto.';
	@override String get hardwareDecodingAutoSafe => 'Auto sûr';
	@override String get hardwareDecodingNo => 'Désactivé';
	@override String get hardwareDecodingYes => 'Forcer l\'activation';
	@override String get cdnDistributionStrategy => 'Stratégie de distribution du contenu';
	@override String get cdnDistributionStrategyDesc => 'Choisir la stratégie de distribution des serveurs sources pour optimiser la vitesse de chargement';
	@override String get cdnDistributionStrategyLabel => 'Stratégie de distribution';
	@override String get cdnDistributionStrategyNoChange => 'Aucun changement (serveur d\'origine)';
	@override String get cdnDistributionStrategyAuto => 'Sélection auto. (serveur le plus rapide)';
	@override String get cdnDistributionStrategySpecial => 'Spécifier le serveur';
	@override String get cdnSpecialServer => 'Spécifier le serveur';
	@override String get cdnRefreshServerListHint => 'Veuillez cliquer sur le bouton ci-dessous pour actualiser la liste des serveurs';
	@override String get cdnRefreshButton => 'Actualiser';
	@override String get cdnFastRingServers => 'Serveurs Fast Ring';
	@override String get cdnRefreshServerListTooltip => 'Actualiser la liste des serveurs';
	@override String get cdnSpeedTestButton => 'Test de vitesse';
	@override String cdnSpeedTestingButton({required Object count}) => 'Test (${count})';
	@override String get cdnNoServerDataHint => 'Aucune donnée de serveur, veuillez cliquer sur le bouton d\'actualisation';
	@override String get cdnTestingStatus => 'Test en cours';
	@override String get cdnUnreachableStatus => 'Injoignable';
	@override String get cdnNotTestedStatus => 'Non testé';
	@override late final _TranslationsSettingsDownloadSettingsFr downloadSettings = _TranslationsSettingsDownloadSettingsFr._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsFr extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tags favoris';
	@override String get emptyIwara => 'Aucun tag Iwara favori pour l\'instant';
	@override String get emptyOreno3d => 'Aucun favori pour l\'instant';
	@override String get addIwaraTag => 'Ajouter un tag Iwara';
	@override String get quickPickHint => 'Les éléments mis en favori apparaissent comme suggestions rapides dans la recherche.';
	@override String get pickerTitle => 'Sélectionner Oreno3D';
	@override String get searchHint => 'Rechercher par nom ou original';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n,
		one: '${n} œuvre',
		other: '${n} œuvres',
	);
	@override String get browseEntry => 'Parcourir origine / personnage / tag';
	@override String get favoritesSection => 'Favoris';
	@override String get addFavorite => 'Ajouter';
	@override String get iwaraTitle => 'Tags Iwara favoris';
	@override String get oreno3dTitle => 'Tags Oreno3D favoris';
	@override String get changeTag => 'Changer de tag';
	@override String get switchToText => 'Recherche textuelle';
}

// Path: oreno3d
class _TranslationsOreno3dFr extends TranslationsOreno3dEn {
	_TranslationsOreno3dFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Tags';
	@override String get characters => 'Personnages';
	@override String get origin => 'Origine';
	@override String get thirdPartyTagsExplanation => 'Les informations de **tags**, **personnages** et **origine** affichées ici proviennent du site tiers **Oreno3D** et sont fournies à titre indicatif.\n\nCette source n\'étant disponible qu\'en japonais, elle n\'est pas encore adaptée à l\'internationalisation.\n\nSi vous souhaitez contribuer à l\'internationalisation, rendez-vous sur le dépôt pour nous aider à l\'améliorer.';
	@override late final _TranslationsOreno3dSortTypesFr sortTypes = _TranslationsOreno3dSortTypesFr._(_root);
	@override late final _TranslationsOreno3dErrorsFr errors = _TranslationsOreno3dErrorsFr._(_root);
	@override late final _TranslationsOreno3dLoadingFr loading = _TranslationsOreno3dLoadingFr._(_root);
	@override late final _TranslationsOreno3dMessagesFr messages = _TranslationsOreno3dMessagesFr._(_root);
}

// Path: signIn
class _TranslationsSignInFr extends TranslationsSignInEn {
	_TranslationsSignInFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Veuillez d\'abord vous connecter';
	@override String get alreadySignedInToday => 'Vous vous êtes déjà connecté aujourd\'hui !';
	@override String get youDidNotStickToTheSignIn => 'Vous n\'avez pas maintenu la connexion quotidienne.';
	@override String get signInSuccess => 'Connexion réussie !';
	@override String get signInFailed => 'Échec de la connexion, veuillez réessayer plus tard';
	@override String get consecutiveSignIns => 'Connexions consécutives';
	@override String get failureReason => 'Motif de l\'échec';
	@override String get selectDateRange => 'Sélectionner une plage de dates';
	@override String get startDate => 'Date de début';
	@override String get endDate => 'Date de fin';
	@override String get invalidDate => 'Date non valide';
	@override String get invalidDateRange => 'Plage de dates non valide';
	@override String get errorFormatText => 'Erreur de format de date';
	@override String get errorInvalidText => 'Plage de dates non valide';
	@override String get errorInvalidRangeText => 'Plage de dates non valide';
	@override String get dateRangeCantBeMoreThanOneYear => 'La plage de dates ne peut pas dépasser un an';
	@override String get signIn => 'Se connecter';
	@override String get signInRecord => 'Historique des connexions';
	@override String get totalSignIns => 'Total des connexions';
	@override String get pleaseSelectSignInStatus => 'Veuillez sélectionner l\'état de connexion';
}

// Path: subscriptions
class _TranslationsSubscriptionsFr extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Veuillez d\'abord vous connecter pour voir vos abonnements.';
	@override String get selectUser => 'Sélectionner un utilisateur';
	@override String get noSubscribedUsers => 'Aucun utilisateur abonné';
	@override String get showAllSubscribedUsersContent => 'Afficher le contenu de tous les utilisateurs abonnés';
}

// Path: videoDetail
class _TranslationsVideoDetailFr extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'Mode PiP';
	@override String resumeFromLastPosition({required Object position}) => 'Reprendre à la dernière position : ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Reprise à ${position}';
	@override String get restartFromBeginning => 'Recommencer';
	@override String get dismissResumeTip => 'Ignorer';
	@override late final _TranslationsVideoDetailLocalInfoFr localInfo = _TranslationsVideoDetailLocalInfoFr._(_root);
	@override String get videoIdIsEmpty => 'L\'ID de la vidéo est vide';
	@override String get videoInfoIsEmpty => 'Les informations de la vidéo sont vides';
	@override String get thisIsAPrivateVideo => 'Ceci est une vidéo privée';
	@override String get getVideoInfoFailed => 'Échec de l\'obtention des informations de la vidéo, veuillez réessayer plus tard';
	@override String get noVideoSourceFound => 'Aucune source vidéo trouvée';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Tag « ${tagId} » copié dans le presse-papiers';
	@override String get errorLoadingVideo => 'Erreur de chargement de la vidéo';
	@override String get play => 'Lire';
	@override String get pause => 'Pause';
	@override String get exitAppFullscreen => 'Quitter le plein écran de l\'app';
	@override String get enterAppFullscreen => 'Plein écran de l\'app';
	@override String get exitSystemFullscreen => 'Quitter le plein écran système';
	@override String get enterSystemFullscreen => 'Plein écran système';
	@override String get seekTo => 'Aller à';
	@override String get switchResolution => 'Changer la résolution';
	@override String get switchPlaybackSpeed => 'Changer la vitesse de lecture';
	@override String rewindSeconds({required Object num}) => 'Reculer de ${num} secondes';
	@override String fastForwardSeconds({required Object num}) => 'Avance rapide de ${num} secondes';
	@override String playbackSpeedIng({required Object rate}) => 'Lecture à ${rate}x';
	@override String get brightness => 'Luminosité';
	@override String get brightnessLowest => 'Luminosité minimale';
	@override String get volume => 'Volume';
	@override String get volumeMuted => 'Le son est coupé';
	@override String get restoreDefaultZoom => 'Restaurer';
	@override late final _TranslationsVideoDetailGestureGuideFr gestureGuide = _TranslationsVideoDetailGestureGuideFr._(_root);
	@override String get home => 'Accueil';
	@override String get videoPlayer => 'Lecteur vidéo';
	@override String get videoPlayerInfo => 'Infos du lecteur vidéo';
	@override String get moreSettings => 'Plus de paramètres';
	@override String get videoPlayerFeatureInfo => 'Infos sur les fonctionnalités du lecteur';
	@override String get autoRewind => 'Retour arrière auto.';
	@override String get rewindAndFastForward => 'Retour et avance rapide';
	@override String get volumeAndBrightness => 'Volume et luminosité';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Double tap au centre : pause ou lecture';
	@override String get showVerticalVideoInFullScreen => 'Afficher les vidéos verticales en plein écran';
	@override String get keepLastVolumeAndBrightness => 'Conserver le dernier volume et la luminosité';
	@override String get setProxy => 'Définir le proxy';
	@override String get moreFeaturesToBeDiscovered => 'D\'autres fonctionnalités à découvrir...';
	@override String get videoPlayerSettings => 'Paramètres du lecteur vidéo';
	@override String commentCount({required Object num}) => '${num} commentaires';
	@override String get writeYourCommentHere => 'Écrivez votre commentaire ici...';
	@override String get authorOtherVideos => 'Autres vidéos de l\'auteur';
	@override String get relatedVideos => 'Vidéos associées';
	@override String get privateVideo => 'Ceci est une vidéo privée';
	@override String get externalVideo => 'Ceci est une vidéo externe';
	@override String get openInBrowser => 'Ouvrir dans le navigateur';
	@override String get resourceDeleted => 'Cette vidéo semble avoir été supprimée :/';
	@override String get noDownloadUrl => 'Aucune URL de téléchargement';
	@override String get startDownloading => 'Démarrer le téléchargement';
	@override String get downloadFailed => 'Échec du téléchargement, veuillez réessayer plus tard';
	@override String get downloadSuccess => 'Téléchargement réussi';
	@override String get download => 'Télécharger';
	@override String get downloadManager => 'Gestionnaire de téléchargements';
	@override String get resourceNotFound => 'Ressource introuvable';
	@override String get videoLoadError => 'Erreur de chargement de la vidéo';
	@override String get authorNoOtherVideos => 'L\'auteur n\'a pas d\'autres vidéos';
	@override String get noRelatedVideos => 'Aucune vidéo associée';
	@override late final _TranslationsVideoDetailPlayerFr player = _TranslationsVideoDetailPlayerFr._(_root);
	@override late final _TranslationsVideoDetailSkeletonFr skeleton = _TranslationsVideoDetailSkeletonFr._(_root);
	@override late final _TranslationsVideoDetailCastFr cast = _TranslationsVideoDetailCastFr._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsFr likeAvatars = _TranslationsVideoDetailLikeAvatarsFr._(_root);
}

// Path: share
class _TranslationsShareFr extends TranslationsShareEn {
	_TranslationsShareFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Partager la playlist';
	@override String get wowDidYouSeeThis => 'Waouh, avez-vous vu ceci ?';
	@override String get nameIs => 'Le nom est';
	@override String get clickLinkToView => 'Cliquez sur le lien pour voir';
	@override String get iReallyLikeThis => 'J\'aime beaucoup ceci';
	@override String get shareFailed => 'Échec du partage, veuillez réessayer plus tard';
	@override String get share => 'Partager';
	@override String get shareAsImage => 'Partager en image';
	@override String get shareAsText => 'Partager en texte';
	@override String get shareAsImageDesc => 'Partager la couverture vidéo sous forme d\'image';
	@override String get shareAsTextDesc => 'Partager les détails de la vidéo en texte';
	@override String get shareAsImageFailed => 'Échec du partage de la couverture vidéo en image, veuillez réessayer plus tard';
	@override String get shareAsTextFailed => 'Échec du partage des détails vidéo en texte, veuillez réessayer plus tard';
	@override String get shareVideo => 'Partager la vidéo';
	@override String get authorIs => 'L\'auteur est';
	@override String get shareGallery => 'Partager la galerie';
	@override String get galleryTitleIs => 'Le titre de la galerie est';
	@override String get galleryAuthorIs => 'L\'auteur de la galerie est';
	@override String get shareUser => 'Partager l\'utilisateur';
	@override String get userNameIs => 'Le nom d\'utilisateur est';
	@override String get userAuthorIs => 'L\'auteur de l\'utilisateur est';
	@override String get comments => 'Commentaires';
	@override String get shareThread => 'Partager le sujet';
	@override String get views => 'Vues';
	@override String get sharePost => 'Partager la publication';
	@override String get postTitleIs => 'Le titre de la publication est';
	@override String get postAuthorIs => 'L\'auteur de la publication est';
}

// Path: markdown
class _TranslationsMarkdownFr extends TranslationsMarkdownEn {
	_TranslationsMarkdownFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Syntaxe Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'Syntaxe Markdown spéciale Iwara';
	@override String get internalLink => 'Lien interne';
	@override String get supportAutoConvertLinkBelow => 'Conversion automatique des liens ci-dessous :';
	@override String get convertLinkExample => '🎬 Lien vidéo\n🖼️ Lien image\n👤 Lien utilisateur\n📌 Lien forum\n🎵 Lien liste de lecture\n💬 Lien sujet';
	@override String get mentionUser => 'Mentionner un utilisateur';
	@override String get mentionUserDescription => 'Saisissez @ suivi du nom d\'utilisateur, cela sera automatiquement converti en lien utilisateur';
	@override String get markdownBasicSyntax => 'Syntaxe Markdown de base';
	@override String get paragraphAndLineBreak => 'Paragraphe et saut de ligne';
	@override String get paragraphAndLineBreakDescription => 'Les paragraphes sont séparés par une ligne vide, et deux espaces en fin de ligne seront convertis en saut de ligne';
	@override String get paragraphAndLineBreakSyntax => 'Ceci est le premier paragraphe\n\nCeci est le deuxième paragraphe\nCette ligne se termine par deux espaces  \nsera convertie en saut de ligne';
	@override String get textStyle => 'Style de texte';
	@override String get textStyleDescription => 'Encadrez le texte de symboles spéciaux pour changer son style';
	@override String get textStyleSyntax => '**Texte en gras**\n*Texte en italique*\n~~Texte barré~~\n`Texte de code`';
	@override String get quote => 'Citation';
	@override String get quoteDescription => 'Utilisez le symbole > pour créer une citation, plusieurs > pour créer une citation à plusieurs niveaux';
	@override String get quoteSyntax => '> Ceci est une citation de premier niveau\n>> Ceci est une citation de deuxième niveau';
	@override String get list => 'Liste';
	@override String get listDescription => 'Créez une liste ordonnée avec un chiffre suivi d\'un point, une liste non ordonnée avec -';
	@override String get listSyntax => '1. Premier élément\n2. Deuxième élément\n\n- Élément non ordonné\n  - Sous-élément\n  - Autre sous-élément';
	@override String get linkAndImage => 'Lien et image';
	@override String get linkAndImageDescription => 'Format de lien : [texte](URL)\nFormat d\'image : ![description](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[texte du lien](${link})\n![description de l\'image](${imgUrl})';
	@override String get title => 'Titre';
	@override String get titleDescription => 'Utilisez le symbole # pour créer un titre, le nombre indique le niveau';
	@override String get titleSyntax => '# Titre de premier niveau\n## Titre de deuxième niveau\n### Titre de troisième niveau';
	@override String get separator => 'Séparateur';
	@override String get separatorDescription => 'Créez un séparateur avec trois symboles - ou plus';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Syntaxe';
}

// Path: forum
class _TranslationsForumFr extends TranslationsForumEn {
	_TranslationsForumFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get recent => 'Récent';
	@override String get category => 'Catégorie';
	@override String get lastReply => 'Dernière réponse';
	@override late final _TranslationsForumSitewideFr sitewide = _TranslationsForumSitewideFr._(_root);
	@override late final _TranslationsForumErrorsFr errors = _TranslationsForumErrorsFr._(_root);
	@override String get createPost => 'Créer une publication';
	@override String get title => 'Titre';
	@override String get enterTitle => 'Saisir le titre';
	@override String get content => 'Contenu';
	@override String get enterContent => 'Saisir le contenu';
	@override String get writeYourContentHere => 'Écrivez votre contenu ici...';
	@override String get posts => 'Publications';
	@override String get threads => 'Sujets';
	@override String get forum => 'Forum';
	@override String get createThread => 'Créer un sujet';
	@override String get selectCategory => 'Choisir une catégorie';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Délai restant : ${minutes} minutes ${seconds} secondes';
	@override late final _TranslationsForumGroupsFr groups = _TranslationsForumGroupsFr._(_root);
	@override late final _TranslationsForumLeafNamesFr leafNames = _TranslationsForumLeafNamesFr._(_root);
	@override late final _TranslationsForumLeafDescriptionsFr leafDescriptions = _TranslationsForumLeafDescriptionsFr._(_root);
	@override String get reply => 'Répondre';
	@override String get pendingReview => 'En attente de vérification';
	@override String get editedAt => 'Modifié le';
	@override String get copySuccess => 'Copié dans le presse-papiers';
	@override String copySuccessForMessage({required Object str}) => 'Copié dans le presse-papiers : ${str}';
	@override String get editReply => 'Modifier la réponse';
	@override String get editTitle => 'Modifier le titre';
	@override String get submit => 'Envoyer';
}

// Path: notifications
class _TranslationsNotificationsFr extends TranslationsNotificationsEn {
	_TranslationsNotificationsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsFr errors = _TranslationsNotificationsErrorsFr._(_root);
	@override String get notifications => 'Notifications';
	@override String get profile => 'Profil';
	@override String get postedNewComment => 'Nouveau commentaire publié';
	@override String get inYour => 'Dans votre';
	@override String get video => 'Vidéo';
	@override String get repliedYourVideoComment => 'A répondu à votre commentaire de vidéo';
	@override String get copyInfoToClipboard => 'Copier les infos de notification';
	@override String get copySuccess => 'Copié dans le presse-papiers';
	@override String copySuccessForMessage({required Object str}) => 'Copié dans le presse-papiers : ${str}';
	@override String get markAllAsRead => 'Tout marquer comme lu';
	@override String get markAllAsReadSuccess => 'Toutes les notifications ont été marquées comme lues';
	@override String get markAllAsReadFailed => 'Échec du marquage de tout comme lu';
	@override String get markSelectedAsRead => 'Marquer la sélection comme lue';
	@override String get markSelectedAsReadSuccess => 'Les notifications sélectionnées ont été marquées comme lues';
	@override String get markSelectedAsReadFailed => 'Échec du marquage de la sélection comme lue';
	@override String get markAsRead => 'Marquer comme lu';
	@override String get markAsReadSuccess => 'La notification a été marquée comme lue';
	@override String get markAsReadFailed => 'Échec du marquage de la notification comme lue';
	@override String get notificationTypeHelp => 'Aide sur les types de notification';
	@override String get dueToLackOfNotificationTypeDetails => 'Faute de détails sur le type de notification, les types pris en charge peuvent ne pas couvrir les messages que vous recevez actuellement';
	@override String get helpUsImproveNotificationTypeSupport => 'Si vous souhaitez nous aider à améliorer la prise en charge des types de notification';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Copiez les informations de la notification\n2. 🐞 Ouvrez un ticket sur le dépôt du projet\n\n⚠️ Remarque : les informations de notification peuvent contenir des données personnelles ; si vous ne souhaitez pas les rendre publiques, vous pouvez aussi les envoyer à l\'auteur du projet par e-mail.';
	@override String get goToRepository => 'Aller au dépôt';
	@override String get copy => 'Copier';
	@override String get commentApproved => 'Commentaire approuvé';
	@override String get repliedYourProfileComment => 'A répondu à votre commentaire de profil';
	@override String get kReplied => 'a répondu à votre commentaire sur';
	@override String get kCommented => 'a commenté votre';
	@override String get kVideo => 'vidéo';
	@override String get kGallery => 'galerie';
	@override String get kProfile => 'profil';
	@override String get kThread => 'sujet';
	@override String get kPost => 'publication';
	@override String get kCommentSection => 'section de commentaires';
	@override String get kApprovedComment => 'Commentaire approuvé';
	@override String get kApprovedVideo => 'Vidéo approuvée';
	@override String get kApprovedGallery => 'Galerie approuvée';
	@override String get kApprovedThread => 'Sujet approuvé';
	@override String get kApprovedPost => 'Publication approuvée';
	@override String get kApprovedForumPost => 'Message de forum approuvé';
	@override String get kRejectedContent => 'Contenu rejeté par la modération';
	@override String get kUnknownType => 'Type de notification inconnu';
}

// Path: conversation
class _TranslationsConversationFr extends TranslationsConversationEn {
	_TranslationsConversationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsFr errors = _TranslationsConversationErrorsFr._(_root);
	@override String get conversation => 'Conversation';
	@override String get startConversation => 'Démarrer la conversation';
	@override String get noConversation => 'Aucune conversation';
	@override String get selectFromLeftListAndStartConversation => 'Choisissez un utilisateur dans la liste de gauche pour démarrer la conversation';
	@override String get title => 'Titre';
	@override String get body => 'Corps';
	@override String get selectAUser => 'Choisir un utilisateur';
	@override String get searchUsers => 'Rechercher des utilisateurs...';
	@override String get tmpNoConversions => 'Aucune conversation';
	@override String get deleteThisMessage => 'Supprimer ce message';
	@override String get deleteThisMessageSubtitle => 'Cette opération est irréversible';
	@override String get writeMessageHere => 'Écrivez votre message ici...';
	@override String get lastMessageFromMe => 'Vous : ';
	@override String get sendMessage => 'Envoyer le message';
}

// Path: splash
class _TranslationsSplashFr extends TranslationsSplashEn {
	_TranslationsSplashFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsFr errors = _TranslationsSplashErrorsFr._(_root);
	@override String get preparing => 'Préparation...';
	@override String get initializing => 'Initialisation...';
	@override String get loading => 'Chargement...';
	@override String get ready => 'Prêt';
	@override String get initializingMessageService => 'Initialisation du service de messagerie...';
}

// Path: download
class _TranslationsDownloadFr extends TranslationsDownloadEn {
	_TranslationsDownloadFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsFr errors = _TranslationsDownloadErrorsFr._(_root);
	@override String get downloadList => 'Liste des téléchargements';
	@override String get viewDownloadList => 'Voir la liste des téléchargements';
	@override String get download => 'Télécharger';
	@override String get selectDownloadTitle => 'Choisir le téléchargement';
	@override String get qualitySectionLabel => 'Qualité';
	@override String get categorySectionLabel => 'Catégorie';
	@override String get saveToPreviewLabel => 'Sera enregistré dans';
	@override String saveToPreviewSuggested({required Object name}) => 'Nom de fichier suggéré : ${name} (modifiable dans la boîte de dialogue système)';
	@override String get lastUsedBadge => 'Dernier utilisé';
	@override String get pickedBadge => 'Sélectionné';
	@override String get startDownloading => 'Démarrer le téléchargement';
	@override String get clearAllFailedTasks => 'Effacer toutes les tâches échouées';
	@override String get clearAllFailedTasksConfirmation => 'Voulez-vous vraiment effacer toutes les tâches de téléchargement échouées ? Les fichiers de ces tâches seront également supprimés.';
	@override String get clearAllFailedTasksSuccess => 'Toutes les tâches échouées ont été effacées';
	@override String get clearAllFailedTasksError => 'Une erreur est survenue lors de l\'effacement des tâches échouées';
	@override String get downloadStatus => 'État du téléchargement';
	@override String get imageList => 'Liste des images';
	@override String get retryDownload => 'Relancer le téléchargement';
	@override String get notDownloaded => 'Non téléchargé';
	@override String get downloaded => 'Téléchargé';
	@override String get waitingForDownload => 'En attente de téléchargement';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Téléchargement (${downloaded}/${total} images, ${progress} %)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Téléchargement (${downloaded} images)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'En pause (${downloaded}/${total} images, ${progress} %)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'En pause (${downloaded} images)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Téléchargé (total : ${total} images)';
	@override String get viewVideoDetail => 'Voir le détail de la vidéo';
	@override String get viewGalleryDetail => 'Voir le détail de la galerie';
	@override String get moreOptions => 'Plus d\'options';
	@override String get openFile => 'Ouvrir le fichier';
	@override String get playLocally => 'Lire localement';
	@override String get pause => 'Pause';
	@override String get resume => 'Reprendre';
	@override String get copyDownloadUrl => 'Copier l\'URL de téléchargement';
	@override String get showInFolder => 'Afficher dans le dossier';
	@override String get deleteTask => 'Supprimer la tâche';
	@override String get deleteTaskConfirmation => 'Voulez-vous vraiment supprimer cette tâche de téléchargement ?\nLe fichier de la tâche sera également supprimé.';
	@override String get forceDeleteTask => 'Forcer la suppression de la tâche';
	@override String get forceDeleteTaskConfirmation => 'Voulez-vous vraiment forcer la suppression de cette tâche de téléchargement ?\nLe fichier de la tâche sera également supprimé, même s\'il est en cours d\'utilisation.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Téléchargement ${downloaded}/${total} (${progress} %) • ${speed} Mo/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Téléchargement ${downloaded} • ${speed} Mo/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'En pause ${downloaded}/${total} (${progress} %)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'En pause • Téléchargé ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Téléchargé • ${size}';
	@override String get copyDownloadUrlSuccess => 'URL de téléchargement copiée';
	@override String totalImageNums({required Object num}) => '${num} image(s)';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Téléchargement ${downloaded}/${total} (${progress} %) • ${speed} Mo/s';
	@override String get downloading => 'Téléchargement';
	@override String get failed => 'Échec';
	@override String get completed => 'Terminé';
	@override String get downloadDetail => 'Détails du téléchargement';
	@override String get copy => 'Copier';
	@override String get copySuccess => 'Copié';
	@override String get waiting => 'En attente';
	@override String get paused => 'En pause';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Téléchargement ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Téléchargement de la galerie terminé : ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Téléchargement terminé : ${fileName}';
	@override String get searchTasks => 'Rechercher des tâches...';
	@override String statusLabel({required Object label}) => 'État : ${label}';
	@override String get allStatus => 'Tous les états';
	@override String typeLabel({required Object label}) => 'Type : ${label}';
	@override String get allTypes => 'Tous les types';
	@override String get taskType => 'Type';
	@override String get video => 'Vidéo';
	@override String get gallery => 'Galerie';
	@override String get other => 'Autre';
	@override String get clearFilters => 'Effacer les filtres';
	@override String get pauseAll => 'Tout mettre en pause';
	@override String get resumeAll => 'Tout démarrer';
	@override String remainingTime({required Object time}) => '${time} restant';
	@override late final _TranslationsDownloadTimelineFr timeline = _TranslationsDownloadTimelineFr._(_root);
	@override late final _TranslationsDownloadErrorTypesFr errorTypes = _TranslationsDownloadErrorTypesFr._(_root);
	@override String get errorDetailCopied => 'Détails de l\'erreur copiés';
	@override String get errorDetailCopyHint => 'Appuyez longuement pour copier les détails de l\'erreur';
	@override late final _TranslationsDownloadRestoredPausedFr restoredPaused = _TranslationsDownloadRestoredPausedFr._(_root);
	@override late final _TranslationsDownloadActionsFr actions = _TranslationsDownloadActionsFr._(_root);
	@override late final _TranslationsDownloadNoticeFr notice = _TranslationsDownloadNoticeFr._(_root);
	@override String get emptyTaskList => 'Aucune tâche de téléchargement pour l\'instant';
	@override String get noMatchingTasks => 'Aucune tâche correspondante';
	@override late final _TranslationsDownloadDeleteByDateFr deleteByDate = _TranslationsDownloadDeleteByDateFr._(_root);
	@override late final _TranslationsDownloadRelocationFr relocation = _TranslationsDownloadRelocationFr._(_root);
	@override late final _TranslationsDownloadCategoryFr category = _TranslationsDownloadCategoryFr._(_root);
	@override late final _TranslationsDownloadLocationFr location = _TranslationsDownloadLocationFr._(_root);
	@override String get maxConcurrentDownloads => 'Téléchargements simultanés maximum';
	@override String get maxConcurrentDownloadsDesc => 'Nombre de tâches téléchargées en même temps (1-5)';
	@override String get stillInDevelopment => 'En cours de développement';
	@override String get saveToAppDirectory => 'Enregistrer dans le dossier de l\'application';
	@override String get alreadyDownloadedWithQuality => 'Déjà téléchargé avec la même qualité. Continuer le téléchargement ?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Déjà téléchargé avec les qualités : ${qualities}. Continuer le téléchargement ?';
	@override String get otherQualities => 'Autres qualités';
	@override late final _TranslationsDownloadBatchDownloadFr batchDownload = _TranslationsDownloadBatchDownloadFr._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsFr extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Téléchargement terminé';
	@override String get failedTitle => 'Échec du téléchargement';
	@override String completedBody({required Object name}) => '${name} téléchargé avec succès';
	@override String failedBody({required Object name}) => 'Échec du téléchargement de ${name}';
	@override String completedToast({required Object name}) => '${name} téléchargé';
	@override String failedToast({required Object name}) => 'Échec du téléchargement de ${name}';
	@override String savedToFolder({required Object dir}) => 'Enregistré dans ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Enregistré sous ${name} (un fichier du même nom existait déjà)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Enregistré dans le dossier de lapp — écriture impossible dans ${target} (${reason})';
	@override String get viewFolder => 'Voir le dossier';
	@override String get fixInSettings => 'Corriger dans les réglages';
	@override String get channelName => 'État des téléchargements';
	@override String get channelDescription => 'Notifications de téléchargements terminés et échoués';
}

// Path: favorite
class _TranslationsFavoriteFr extends TranslationsFavoriteEn {
	_TranslationsFavoriteFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsFr errors = _TranslationsFavoriteErrorsFr._(_root);
	@override String get add => 'Ajouter';
	@override String get addSuccess => 'Ajout réussi';
	@override String get addFailed => 'Échec de l\'ajout';
	@override String get remove => 'Retirer';
	@override String get removeSuccess => 'Retrait réussi';
	@override String get removeFailed => 'Échec du retrait';
	@override String get removeConfirmation => 'Voulez-vous vraiment retirer cet élément des favoris ?';
	@override String get removeConfirmationSuccess => 'Élément retiré des favoris';
	@override String get removeConfirmationFailed => 'Échec du retrait de l\'élément des favoris';
	@override String get createFolderSuccess => 'Dossier créé avec succès';
	@override String get createFolderFailed => 'Échec de la création du dossier';
	@override String get createFolder => 'Créer un dossier';
	@override String get enterFolderName => 'Saisir le nom du dossier';
	@override String get enterFolderNameHere => 'Saisissez ici le nom du dossier...';
	@override String get create => 'Créer';
	@override String get items => 'Éléments';
	@override String get newFolderName => 'Nouveau dossier';
	@override String get searchFolders => 'Rechercher des dossiers...';
	@override String get searchItems => 'Rechercher des éléments...';
	@override String get createdAt => 'Créé le';
	@override String get myFavorites => 'Mes favoris';
	@override String get deleteFolderTitle => 'Supprimer le dossier';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'Voulez-vous vraiment supprimer le dossier ${title} ?';
	@override String get removeItemTitle => 'Retirer l\'élément';
	@override String removeItemConfirmWithTitle({required Object title}) => 'Voulez-vous vraiment supprimer l\'élément ${title} ?';
	@override String get removeItemSuccess => 'Élément retiré des favoris';
	@override String get removeItemFailed => 'Échec du retrait de l\'élément des favoris';
	@override String get localizeFavorite => 'Favori local';
	@override String get editFolderTitle => 'Modifier le dossier';
	@override String get editFolderSuccess => 'Dossier mis à jour avec succès';
	@override String get editFolderFailed => 'Échec de la mise à jour du dossier';
	@override String get searchTags => 'Rechercher des tags';
	@override String get noTagsInFolder => 'Aucun tag sur les éléments de ce dossier pour l\'instant';
	@override String get tagFilterMatchAll => 'Affiche uniquement les éléments portant tous les tags sélectionnés';
	@override String get clearSelectedTags => 'Effacer les tags sélectionnés';
	@override String selectedTagCount({required Object count}) => '${count} sélectionné(s)';
	@override String get noMatchingTags => 'Aucun tag correspondant';
}

// Path: translation
class _TranslationsTranslationFr extends TranslationsTranslationEn {
	_TranslationsTranslationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Service actuel';
	@override String get testConnection => 'Tester la connexion';
	@override String get testConnectionSuccess => 'Test de connexion réussi';
	@override String get testConnectionFailed => 'Échec du test de connexion';
	@override String testConnectionFailedWithMessage({required Object message}) => 'Échec du test de connexion : ${message}';
	@override String get translation => 'Traduction';
	@override String get needVerification => 'Vérification requise';
	@override String get needVerificationContent => 'Veuillez d\'abord tester la connexion avant d\'activer la traduction par IA';
	@override String get confirm => 'Confirmer';
	@override String get disclaimer => 'Avertissement';
	@override String get riskWarning => 'Avertissement de risque';
	@override String get dureToRisk1 => 'Le texte étant généré par les utilisateurs, il peut contenir des éléments contraires à la politique de contenu du fournisseur de service d\'IA';
	@override String get dureToRisk2 => 'Un contenu inapproprié peut entraîner la suspension de la clé d\'API ou la résiliation du service';
	@override String get operationSuggestion => 'Conseils d\'utilisation';
	@override String get operationSuggestion1 => '1. À utiliser avant d\'examiner rigoureusement le contenu à traduire';
	@override String get operationSuggestion2 => '2. Évitez de traduire des contenus impliquant de la violence, du contenu pour adultes, etc.';
	@override String get apiConfig => 'Configuration de l\'API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Modifier la configuration fermera automatiquement la traduction par IA ; un nouveau test sera nécessaire après l\'activation';
	@override String get apiAddress => 'Adresse de l\'API';
	@override String get modelName => 'Nom du modèle';
	@override String get modelNameHintText => 'Par exemple : gpt-4-turbo';
	@override String get maxTokens => 'Jetons max';
	@override String get maxTokensHintText => 'Par exemple : 32000';
	@override String get temperature => 'Température';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Cliquez sur le bouton de test pour vérifier la validité de la connexion à l\'API';
	@override String get requestPreview => 'Aperçu de la requête';
	@override String get enableAITranslation => 'Activer l\'IA';
	@override String get enabled => 'Activé';
	@override String get disabled => 'Désactivé';
	@override String get testing => 'Test en cours...';
	@override String get testNow => 'Tester maintenant';
	@override String get connectionStatus => 'État de la connexion';
	@override String get success => 'Succès';
	@override String get failed => 'Échec';
	@override String get information => 'Informations';
	@override String get viewRawResponse => 'Voir la réponse brute';
	@override String get pleaseCheckInputParametersFormat => 'Veuillez vérifier le format des paramètres saisis';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Veuillez renseigner l\'adresse de l\'API, le nom du modèle et la clé';
	@override String get pleaseFillInValidConfigurationParameters => 'Veuillez renseigner des paramètres de configuration valides';
	@override String get pleaseCompleteConnectionTest => 'Veuillez effectuer le test de connexion';
	@override String get notConfigured => 'Non configuré';
	@override String get apiEndpoint => 'Point de terminaison de l\'API';
	@override String get configuredKey => 'Clé configurée';
	@override String get notConfiguredKey => 'Clé non configurée';
	@override String get authenticationStatus => 'État de l\'authentification';
	@override String get thisFieldCannotBeEmpty => 'Ce champ ne peut pas être vide';
	@override String get apiKey => 'Clé d\'API';
	@override String get apiKeyCannotBeEmpty => 'La clé d\'API ne peut pas être vide';
	@override String get pleaseEnterValidNumber => 'Veuillez saisir un nombre valide';
	@override String get range => 'Plage';
	@override String get mustBeGreaterThan => 'Doit être supérieur à';
	@override String get invalidAPIResponse => 'Réponse d\'API non valide';
	@override String connectionFailedForMessage({required Object message}) => 'Échec de la connexion : ${message}';
	@override String get aiTranslationNotEnabledHint => 'La traduction par IA n\'est pas activée, veuillez l\'activer dans les paramètres';
	@override String get goToSettings => 'Aller aux paramètres';
	@override String get disableAITranslation => 'Désactiver la traduction par IA';
	@override String get currentValue => 'Valeur actuelle';
	@override String get configureTranslationStrategy => 'Configurer la stratégie de traduction';
	@override String get advancedSettings => 'Paramètres avancés';
	@override String get translationPrompt => 'Prompt de traduction';
	@override String get promptHint => 'Veuillez saisir le prompt de traduction ; utilisez [TL] comme espace réservé pour la langue cible';
	@override String get promptHelperText => 'Le prompt doit contenir [TL] comme espace réservé pour la langue cible';
	@override String get promptMustContainTargetLang => 'Le prompt doit contenir l\'espace réservé [TL]';
	@override String get aiTranslationWillBeDisabled => 'La traduction par IA sera désactivée';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'En raison d\'un changement de configuration de base, la traduction par IA sera désactivée';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'En raison d\'un changement du prompt de traduction, la traduction par IA sera désactivée';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'En raison d\'un changement de configuration des paramètres, la traduction par IA sera désactivée';
	@override String get onlyOpenAIAPISupported => 'Ne prend actuellement en charge que le format d\'API compatible OpenAI (corps de requête application/json)';
	@override String get streamingTranslation => 'Traduction en flux';
	@override String get streamingTranslationSupported => 'Traduction en flux prise en charge';
	@override String get streamingTranslationNotSupported => 'Traduction en flux non prise en charge';
	@override String get streamingTranslationDescription => 'La traduction en flux peut afficher les résultats en temps réel pendant la traduction, pour une meilleure expérience';
	@override String get usingFullUrlWithHash => 'Utilisation de l\'URL complète (se terminant par #)';
	@override String get baseUrlInputHelperText => 'S\'il se termine par #, il sera utilisé comme adresse de requête réelle';
	@override String currentActualUrl({required Object url}) => 'URL réelle actuelle : ${url}';
	@override String get urlEndingWithHashTip => 'Une URL se terminant par # sera utilisée directement, sans ajout de suffixe';
	@override String get streamingTranslationWarning => 'Remarque : cette fonctionnalité nécessite que le service d\'API prenne en charge la transmission en flux ; certains modèles peuvent ne pas la prendre en charge';
	@override String get translationService => 'Service de traduction';
	@override String get translationServiceDescription => 'Sélectionnez votre service de traduction préféré';
	@override String get googleTranslation => 'Traduction Google';
	@override String get googleTranslationDescription => 'Service de traduction en ligne gratuit prenant en charge plusieurs langues';
	@override String get aiTranslation => 'Traduction par IA';
	@override String get aiTranslationDescription => 'Service de traduction intelligent basé sur de grands modèles de langage';
	@override String get deeplxTranslation => 'Traduction DeepLX';
	@override String get deeplxTranslationDescription => 'Implémentation open source de la traduction DeepL, offrant une traduction de haute qualité';
	@override String get googleTranslationFeatures => 'Fonctionnalités';
	@override String get freeToUse => 'Gratuit';
	@override String get freeToUseDescription => 'Aucune configuration requise, prêt à l\'emploi';
	@override String get fastResponse => 'Réponse rapide';
	@override String get fastResponseDescription => 'Traduction rapide avec une faible latence';
	@override String get stableAndReliable => 'Stable et fiable';
	@override String get stableAndReliableDescription => 'Basé sur l\'API officielle Google';
	@override String get enabledDefaultService => 'Activé - service de traduction par défaut';
	@override String get notEnabled => 'Non activé';
	@override String get deeplxTranslationService => 'Service de traduction DeepLX';
	@override String get deeplxDescription => 'DeepLX est une implémentation open source de la traduction DeepL, prenant en charge les modes Free, Pro et Official';
	@override String get serverAddress => 'Adresse du serveur';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Adresse de base du serveur DeepLX';
	@override String get endpointType => 'Type de point de terminaison';
	@override String get freeEndpoint => 'Free - point de terminaison gratuit, peut avoir des limites de débit';
	@override String get proEndpoint => 'Pro - nécessite dl_session, plus stable';
	@override String get officialEndpoint => 'Official - format d\'API officiel';
	@override String get finalRequestUrl => 'URL de requête finale';
	@override String get apiKeyOptional => 'Clé d\'API (facultative)';
	@override String get apiKeyOptionalHint => 'Pour accéder aux services DeepLX protégés';
	@override String get apiKeyOptionalHelperText => 'Certains services DeepLX exigent une clé d\'API pour l\'authentification';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Paramètre dl_session requis pour le mode Pro';
	@override String get dlSessionHelperText => 'Paramètre de session requis pour le point de terminaison Pro, obtenu depuis un compte DeepL Pro';
	@override String get proModeRequiresDlSession => 'Le mode Pro nécessite dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Cliquez sur le bouton de test pour vérifier la connexion à l\'API DeepLX';
	@override String get enableDeepLXTranslation => 'Activer la traduction DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'La traduction DeepLX sera désactivée en raison de changements de configuration';
	@override String get translatedResult => 'Résultat traduit';
	@override String get testSuccess => 'Test réussi';
	@override String get pleaseFillInDeepLXServerAddress => 'Veuillez renseigner l\'adresse du serveur DeepLX';
	@override String get invalidAPIResponseFormat => 'Format de réponse d\'API non valide';
	@override String get translationServiceReturnedError => 'Le service de traduction a renvoyé une erreur ou un résultat vide';
	@override String get connectionFailed => 'Échec de la connexion';
	@override String get translationFailed => 'Échec de la traduction';
	@override String get aiTranslationFailed => 'Échec de la traduction par IA';
	@override String get deeplxTranslationFailed => 'Échec de la traduction DeepLX';
	@override String get aiTranslationTestFailed => 'Échec du test de la traduction par IA';
	@override String get deeplxTranslationTestFailed => 'Échec du test de traduction DeepLX';
	@override String get streamingTranslationTimeout => 'Délai de traduction en flux dépassé, nettoyage forcé des ressources';
	@override String get translationRequestTimeout => 'Délai de la requête de traduction dépassé';
	@override String get streamingTranslationDataTimeout => 'Délai de réception des données de traduction en flux dépassé';
	@override String get dataReceptionTimeout => 'Délai de réception des données dépassé';
	@override String get streamDataParseError => 'Erreur d\'analyse des données du flux';
	@override String get streamingTranslationFailed => 'Échec de la traduction en flux';
	@override String get fallbackTranslationFailed => 'Le repli vers la traduction normale a également échoué';
	@override String get translationSettings => 'Paramètres de traduction';
	@override String get enableGoogleTranslation => 'Activer la traduction Google';
	@override String get thinking => 'Réflexion...';
	@override String get thoughtProcess => 'Processus de réflexion';
	@override String get modelCompatibility => 'Compatibilité des modèles';
	@override String get modelCompatibilityDescription => 'Adapter les paramètres de requête aux modèles récents tels que les modèles de raisonnement (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'Modèle de raisonnement';
	@override String get reasoningModelDescription => 'Pour o1/o3, DeepSeek-R1, QwQ, etc. Intègre le prompt dans le message utilisateur, omet la température et utilise max_completion_tokens';
	@override String get useMaxCompletionTokens => 'Utiliser max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'Les points de terminaison OpenAI récents exigent max_completion_tokens au lieu du max_tokens obsolète';
	@override String get sendTemperature => 'Envoyer la température';
	@override String get sendTemperatureDescription => 'À désactiver pour les modèles qui rejettent le paramètre temperature (la plupart des modèles de raisonnement)';
	@override String get showReasoningProcess => 'Afficher le processus de réflexion';
	@override String get showReasoningProcessDescription => 'Afficher le raisonnement dépliable des modèles de raisonnement dans la boîte de dialogue de traduction';
	@override String get provider => 'Fournisseur';
	@override String get providerOpenAI => 'OpenAI (et compatibles)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Prend en charge OpenAI (et tout point de terminaison compatible OpenAI), Anthropic et Google via le SDK dartantic_ai';
	@override String get baseUrlOptionalHelperText => 'Facultatif. Laissez vide pour utiliser le point de terminaison par défaut du fournisseur ; renseignez-le pour les points de terminaison compatibles OpenAI/relais';
	@override String get defaultEndpoint => 'Point de terminaison par défaut';
	@override String get providerPreset => 'Préréglage du fournisseur';
	@override String get selectProviderPreset => 'Sélectionner un préréglage';
	@override String get presetCustom => 'Personnalisé';
	@override String presetApplied({required Object name}) => 'Préréglage appliqué : ${name}';
	@override late final _TranslationsTranslationPresetNamesFr presetNames = _TranslationsTranslationPresetNamesFr._(_root);
	@override String get fetchModelList => 'Récupérer la liste des modèles';
	@override String get fetchingModels => 'Récupération...';
	@override String get selectModel => 'Sélectionner un modèle';
	@override String get searchModel => 'Rechercher un modèle';
	@override String get noModelsFound => 'Aucun modèle trouvé';
}

// Path: bottomNav
class _TranslationsBottomNavFr extends TranslationsBottomNavEn {
	_TranslationsBottomNavFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get video => 'Vidéo';
	@override String get gallery => 'Galerie';
	@override String get subscription => 'Fil';
	@override String get community => 'Forum';
	@override String get localMedia => 'Local';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsFr extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages de l\'ordre de navigation';
	@override String get customNavigationOrder => 'Ordre de navigation personnalisé';
	@override String get customNavigationOrderDesc => 'Faites glisser pour ajuster l\'ordre d\'affichage des pages dans la barre de navigation inférieure et la barre latérale';
	@override String get restartRequired => 'Redémarrage de l\'application requis';
	@override String get navigationItemSorting => 'Tri des éléments de navigation';
	@override String get done => 'Terminé';
	@override String get edit => 'Modifier';
	@override String get reset => 'Réinitialiser';
	@override String get previewEffect => 'Aperçu du résultat';
	@override String get bottomNavigationPreview => 'Aperçu de la navigation inférieure :';
	@override String get sidebarPreview => 'Aperçu de la barre latérale :';
	@override String get confirmResetNavigationOrder => 'Confirmer la réinitialisation de l\'ordre de navigation';
	@override String get confirmResetNavigationOrderDesc => 'Voulez-vous vraiment rétablir l\'ordre de navigation par défaut ?';
	@override String get cancel => 'Annuler';
	@override String get show => 'Afficher';
	@override String get hide => 'Masquer';
	@override String get hidden => 'Masqué';
	@override String get hideHint => 'Appuyez sur l\'icône en forme d\'œil pour afficher ou masquer Communauté et les fichiers locaux';
	@override String get videoDescription => 'Parcourir les vidéos populaires';
	@override String get galleryDescription => 'Parcourir les images et les galeries';
	@override String get subscriptionDescription => 'Voir les derniers contenus des utilisateurs suivis';
	@override String get forumDescription => 'Participez aux discussions de la communauté';
	@override String get newsDescription => 'Parcourir les actualités, articles et diffusions officiels';
	@override String get communityDescription => 'Discussions du forum, plus les actualités, articles et diffusions officiels';
	@override String get localMediaDescription => 'Parcourir les vidéos et images stockées sur cet appareil';
}

// Path: news
class _TranslationsNewsFr extends TranslationsNewsEn {
	_TranslationsNewsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Actualités';
	@override String get newsUpdates => 'Actualités';
	@override String get articles => 'Articles';
	@override String get broadcast => 'Diffusion';
	@override String get openInBrowser => 'Ouvrir dans le navigateur';
}

// Path: displaySettings
class _TranslationsDisplaySettingsFr extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages d\'affichage';
	@override String get layoutSettings => 'Réglages de disposition';
	@override String get layoutSettingsDesc => 'Personnalisez le nombre de colonnes et la configuration des points de rupture';
	@override String get gridLayout => 'Disposition en grille';
	@override String get navigationOrderSettings => 'Réglages de l\'ordre de navigation';
	@override String get customNavigationOrder => 'Ordre de navigation personnalisé';
	@override String get customNavigationOrderDesc => 'Ajustez l\'ordre d\'affichage des pages dans la barre de navigation inférieure et la barre latérale';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsFr extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages de disposition';
	@override String get descriptionTitle => 'Description de la configuration de disposition';
	@override String get descriptionContent => 'La configuration ici détermine le nombre de colonnes affichées dans les pages de liste de vidéos et de galeries. Vous pouvez choisir le mode automatique pour laisser le système s\'ajuster selon la largeur de l\'écran, ou le mode manuel pour fixer le nombre de colonnes.';
	@override String get layoutMode => 'Mode de disposition';
	@override String get reset => 'Réinitialiser';
	@override String get autoMode => 'Mode automatique';
	@override String get autoModeDesc => 'Ajuster automatiquement selon la largeur de l\'écran';
	@override String get manualMode => 'Mode manuel';
	@override String get manualModeDesc => 'Utiliser un nombre de colonnes fixe';
	@override String get manualSettings => 'Réglages manuels';
	@override String get fixedColumns => 'Colonnes fixes';
	@override String get columns => 'colonnes';
	@override String get breakpointConfig => 'Configuration des points de rupture';
	@override String get add => 'Ajouter';
	@override String get defaultColumns => 'Colonnes par défaut';
	@override String get defaultColumnsDesc => 'Affichage par défaut pour les grands écrans';
	@override String get previewEffect => 'Aperçu du résultat';
	@override String get screenWidth => 'Largeur de l\'écran';
	@override String get addBreakpoint => 'Ajouter un point de rupture';
	@override String get editBreakpoint => 'Modifier le point de rupture';
	@override String get deleteBreakpoint => 'Supprimer le point de rupture';
	@override String get screenWidthLabel => 'Largeur de l\'écran';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Colonnes';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Veuillez saisir la largeur';
	@override String get enterValidWidth => 'Veuillez saisir une largeur valide';
	@override String get widthCannotExceed9999 => 'La largeur ne peut pas dépasser 9999';
	@override String get breakpointAlreadyExists => 'Le point de rupture existe déjà';
	@override String get enterColumns => 'Veuillez saisir le nombre de colonnes';
	@override String get enterValidColumns => 'Veuillez saisir un nombre de colonnes valide';
	@override String get columnsCannotExceed12 => 'Le nombre de colonnes ne peut pas dépasser 12';
	@override String get breakpointConflict => 'Le point de rupture existe déjà';
	@override String get confirmResetLayoutSettings => 'Réinitialiser les réglages de disposition';
	@override String get confirmResetLayoutSettingsDesc => 'Voulez-vous vraiment réinitialiser tous les réglages de disposition aux valeurs par défaut ?\n\nRestauration de :\n• Mode automatique\n• Configuration des points de rupture par défaut';
	@override String get resetToDefaults => 'Rétablir les valeurs par défaut';
	@override String get confirmDeleteBreakpoint => 'Supprimer le point de rupture';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'Voulez-vous vraiment supprimer le point de rupture ${width}px ?';
	@override String get noCustomBreakpoints => 'Aucun point de rupture personnalisé, utilisation des colonnes par défaut';
	@override String get breakpointRange => 'Plage du point de rupture';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Modifier';
	@override String get delete => 'Supprimer';
	@override String get cancel => 'Annuler';
	@override String get save => 'Enregistrer';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerFr extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Erreur du lecteur vidéo';
	@override String get videoLoadFailed => 'Échec du chargement de la vidéo';
	@override String get videoCodecNotSupported => 'Codec vidéo non pris en charge';
	@override String get networkConnectionIssue => 'Problème de connexion réseau';
	@override String get insufficientPermission => 'Permissions insuffisantes';
	@override String get unsupportedVideoFormat => 'Format vidéo non pris en charge';
	@override String get retry => 'Réessayer';
	@override String get externalPlayer => 'Lecteur externe';
	@override String get detailedErrorInfo => 'Informations détaillées sur l\'erreur';
	@override String get format => 'Format';
	@override String get suggestion => 'Conseil';
	@override String get androidWebmCompatibilityIssue => 'Les appareils Android ne prennent que partiellement en charge le format WEBM. Il est recommandé d\'utiliser un lecteur externe ou de télécharger une application de lecture compatible WEBM';
	@override String get currentDeviceCodecNotSupported => 'L\'appareil actuel ne prend pas en charge le codec de ce format vidéo';
	@override String get checkNetworkConnection => 'Vérifiez votre connexion réseau et réessayez';
	@override String get appMayLackMediaPermission => 'L\'application ne dispose peut-être pas des permissions nécessaires à la lecture multimédia';
	@override String get tryOtherVideoPlayer => 'Essayez d\'utiliser d\'autres lecteurs vidéo';
	@override String get unrecognizedVideoFormat => 'Fichier vidéo non reconnu';
	@override String get unrecognizedVideoFormatSuggestion => 'Le lien a peut-être expiré, ou la réponse n\'était pas une vidéo. Réessayez, ou ouvrez-la avec une autre application.';
	@override String get accessDenied => 'Le serveur a refusé cette requête (403)';
	@override String get accessDeniedSuggestion => 'Le lien de lecture a très probablement expiré. Appuyez sur Réessayer pour le récupérer, ou ouvrez-le avec une autre application.';
	@override String get mute => 'Couper le son';
	@override String get unmute => 'Rétablir le son';
	@override String get video => 'VIDÉO';
	@override String get serverSelector => 'Choix du serveur CDN';
	@override String get serverSelectorDescription => 'Sélectionnez le serveur avec la latence la plus faible pour une meilleure expérience de lecture';
	@override String get retestSpeed => 'Retester la vitesse';
	@override String get waitingForSpeedTest => 'En attente du test de vitesse';
	@override String get testingSpeed => 'Test de vitesse...';
	@override String get testFailed => 'Échec du test';
	@override String get loadingServerList => 'Chargement de la liste des serveurs...';
	@override String get noAvailableServers => 'Aucun serveur disponible';
	@override String get refreshServerList => 'Actualiser la liste des serveurs';
	@override String get cannotGetSource => 'Impossible d\'obtenir la source de la vidéo en cours';
	@override String switchedToServer({required Object serverName}) => 'Serveur changé : ${serverName}';
	@override String serverCount({required Object count}) => 'Total : ${count} serveurs';
	@override String statusCode({required Object code}) => 'Code d\'état : ${code}';
	@override String get connectionFailed => 'Échec de la connexion';
	@override String get connectionTimeout => 'Délai de connexion dépassé';
	@override String get networkError => 'Erreur réseau';
	@override String get sslError => 'Erreur de certificat SSL';
	@override String get testCompleted => 'Test terminé';
	@override String get local => 'Local';
	@override String get unknown => 'Inconnu';
	@override String get localVideoPathEmpty => 'Le chemin de la vidéo locale est vide';
	@override String localVideoFileNotExists({required Object path}) => 'Le fichier vidéo local n\'existe pas : ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'Impossible de lire la vidéo locale : ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Déposez un fichier vidéo ici pour le lire';
	@override String get supportedFormats => 'Formats pris en charge : MP4, MKV, AVI, MOV, WEBM, etc.';
	@override String get noSupportedVideoFile => 'Aucun fichier vidéo pris en charge trouvé';
	@override String get retryingOpenVideoLink => 'Échec de l\'ouverture du lien vidéo, nouvel essai';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'Impossible de charger le décodeur : ${event}. Essayez de passer au décodage logiciel dans les réglages du lecteur et revenez sur la page';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Erreur de chargement de la vidéo : ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Échecs de lecture répétés détectés. Allez dans Réglages > Diagnostics et retours pour exporter les journaux.';
	@override String get openSettingsAction => 'Voir';
	@override late final _TranslationsMediaPlayerNoticeFr notice = _TranslationsMediaPlayerNoticeFr._(_root);
	@override String get imageLoadFailed => 'Échec du chargement de l\'image';
	@override String get unsupportedImageFormat => 'Format d\'image non pris en charge';
	@override String get tryOtherViewer => 'Essayez d\'utiliser d\'autres visionneuses';
}

// Path: diagnostics
class _TranslationsDiagnosticsFr extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Infos de diagnostic';
	@override String get appVersionLabel => 'Version de l\'application';
	@override String memoryUsage({required Object memMB}) => 'Utilisation de la mémoire : ${memMB} Mo';
	@override String get deviceInfoUnavailable => 'Impossible de récupérer les infos de l\'appareil';
	@override String get secureStorageLabel => 'Stockage sécurisé';
	@override String get secureStorageHealthy => 'Disponible';
	@override String get secureStorageRecovered => 'Réparé automatiquement par réinitialisation (données précédentes effacées)';
	@override String get secureStorageUnavailable => 'Indisponible (connexion enregistrée avec un chiffrement de secours)';
	@override String get secureStoragePlatformOptOut => 'Chiffrement local imposé par la politique de la plateforme (trousseau système non utilisé sur macOS)';
	@override String get secureStorageDualWrite => ' (protection en double écriture activée)';
	@override String get schemaHealthLabel => 'Schéma de base de données';
	@override String get schemaHealthOk => 'OK';
	@override String get schemaHealthRepairedNow => 'Réparé par le filet de sécurité à ce lancement (la migration n\'a pas pris effet)';
	@override String get schemaHealthRepairedBefore => 'A déjà été réparé par le filet de sécurité';
	@override String get logPolicySectionTitle => 'Politique de journalisation';
	@override String get configServiceUnavailable => 'Le service de configuration n\'est pas initialisé. La politique de journalisation ne peut pas être modifiée.';
	@override String get enableLoggingTitle => 'Activer la journalisation';
	@override String get enableLoggingSubtitle => 'Désactivez pour arrêter d\'écrire de nouveaux journaux';
	@override String get enableLogPersistenceTitle => 'Activer la persistance des journaux';
	@override String get enableLogPersistenceSubtitle => 'Désactivez pour garder les journaux en mémoire uniquement et arrêter les écritures sur disque';
	@override String get minLogLevelTitle => 'Niveau de journalisation minimal';
	@override String get minLogLevelSubtitle => 'Les journaux en dessous de ce niveau seront filtrés';
	@override String get maxFileSizeTitle => 'Limite de taille d\'un fichier';
	@override String get maxFileSizeSubtitle => 'Effectuer une rotation au seuil atteint';
	@override String get rotatedFileCountTitle => 'Nombre de fichiers de rotation du journal principal';
	@override String get rotatedFileCountSubtitle => 'Nombre de fichiers conservés hors fichier actuel';
	@override String get hangFileSizeTitle => 'Limite de taille du journal des blocages';
	@override String get hangFileSizeSubtitle => 'Contrôler la croissance du fichier hang_events';
	@override String get hangRotatedFileCountTitle => 'Nombre de fichiers de rotation du journal des blocages';
	@override String get hangRotatedFileCountSubtitle => 'Contrôler l\'historique conservé pour hang_events';
	@override String get healthSectionTitle => 'État des journaux';
	@override String get refreshMetrics => 'Actualiser les métriques';
	@override String get toolsSectionTitle => 'Outils';
	@override String get privacyNotice => 'Les journaux peuvent contenir des informations sensibles comme les données de compte et les paramètres de requête. Ne publiez pas les journaux complets dans les tickets ; vérifiez-les d\'abord et envoyez-les par e-mail.';
	@override String get exportLogsTitle => 'Exporter les journaux';
	@override String get exportLogsSubtitle => 'Vérifiez les données privées avant de les envoyer aux développeurs';
	@override String get viewLogsTitle => 'Voir les journaux';
	@override String get viewLogsSubtitle => 'Consulter les journaux d\'exécution en temps réel';
	@override String get copySupportEmailTitle => 'Copier l\'e-mail d\'assistance';
	@override String get reportIssueTitle => 'Signaler un problème';
	@override String get reportIssueSubtitle => 'Fournissez les étapes de reproduction sur GitHub (ne joignez pas les journaux complets)';
	@override String get healthSummaryUnavailable => 'Aucune donnée d\'état des journaux pour l\'instant';
	@override String get healthMetricsUnavailable => 'Les métriques d\'état n\'ont pas encore été collectées';
	@override String get healthNoRiskIndicators => 'Aucun indicateur de risque détecté';
	@override late final _TranslationsDiagnosticsHealthAlertFr healthAlert = _TranslationsDiagnosticsHealthAlertFr._(_root);
	@override late final _TranslationsDiagnosticsToastFr toast = _TranslationsDiagnosticsToastFr._(_root);
	@override String get shareSubject => 'Journaux de diagnostic LoveIwara (contiennent des données sensibles, à partager avec prudence)';
}

// Path: logViewer
class _TranslationsLogViewerFr extends TranslationsLogViewerEn {
	_TranslationsLogViewerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Visionneuse de journaux';
	@override String get searchHint => 'Rechercher dans les journaux...';
	@override String get emptyState => 'Aucun journal';
	@override String get copiedToClipboard => 'Copié dans le presse-papiers';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogFr extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'L\'application s\'est fermée de façon inattendue';
	@override String get description => 'Nous avons détecté une fermeture anormale lors de la dernière session. Veuillez exporter les journaux de diagnostic et les envoyer par e-mail au développeur pour nous aider à corriger le problème.';
	@override String previousVersion({required Object version}) => 'Dernière version : ${version}';
	@override String previousStart({required Object time}) => 'Dernier lancement : ${time}';
	@override String lastException({required Object message}) => 'Dernière exception : ${message}';
	@override String get lastHangRecovered => 'Un blocage de l\'interface a été détecté la dernière fois et récupéré automatiquement';
	@override String lastHangStalled({required Object stalledMs}) => 'Un possible gel de l\'interface a été détecté la dernière fois, durant environ ${stalledMs} ms';
	@override String get exportGuide => 'Allez dans Réglages > Diagnostics et retours > Exporter les journaux.';
	@override String get privacyHint => 'Les journaux peuvent contenir des données privées. Vérifiez-les avant de les envoyer à :';
	@override String get issueWarning => 'Ne joignez pas les journaux complets publiquement dans les tickets GitHub';
	@override String get acknowledge => 'Compris';
	@override String get supportEmailCopied => 'E-mail copié';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogFr extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Saisir un lien';
	@override String supportedLinksHint({required Object webName}) => 'Reconnaît intelligemment plusieurs liens ${webName} et accède rapidement à la page correspondante dans l\'application (séparez les liens du reste du texte par des espaces)';
	@override String inputHint({required Object webName}) => 'Veuillez saisir un lien ${webName}';
	@override String get validatorEmptyLink => 'Veuillez saisir un lien';
	@override String validatorNoIwaraLink({required Object webName}) => 'Aucun lien ${webName} valide détecté';
	@override String get multipleLinksDetected => 'Plusieurs liens détectés, veuillez en choisir un :';
	@override String notIwaraLink({required Object webName}) => 'Lien ${webName} non valide';
	@override String linkParseError({required Object error}) => 'Erreur d\'analyse du lien : ${error}';
	@override String get unsupportedLinkDialogTitle => 'Lien non pris en charge';
	@override String get unsupportedLinkDialogContent => 'Ce type de lien ne peut pas être ouvert directement dans l\'application et doit être consulté avec un navigateur externe.\n\nVoulez-vous ouvrir ce lien dans un navigateur ?';
	@override String get openInBrowser => 'Ouvrir dans le navigateur';
	@override String get confirmOpenBrowserDialogTitle => 'Confirmer l\'ouverture du navigateur';
	@override String get confirmOpenBrowserDialogContent => 'Le lien suivant va être ouvert dans un navigateur externe :';
	@override String get confirmContinueBrowserOpen => 'Voulez-vous vraiment continuer ?';
	@override String get browserOpenFailed => 'Échec de l\'ouverture du lien';
	@override String get unsupportedLink => 'Lien non pris en charge';
	@override String get cancel => 'Annuler';
	@override String get confirm => 'Ouvrir dans le navigateur';
}

// Path: log
class _TranslationsLogFr extends TranslationsLogEn {
	_TranslationsLogFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Gestion des journaux';
	@override String get enableLogPersistence => 'Activer la persistance des journaux';
	@override String get enableLogPersistenceDesc => 'Enregistrer les journaux dans la base de données pour analyse';
	@override String get logDatabaseSizeLimit => 'Limite de taille de la base de journaux';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Actuelle : ${size}';
	@override String get exportCurrentLogs => 'Exporter les journaux actuels';
	@override String get exportCurrentLogsDesc => 'Exporter les journaux actuels de l\'application pour aider les développeurs à diagnostiquer les problèmes';
	@override String get exportHistoryLogs => 'Exporter l\'historique des journaux';
	@override String get exportHistoryLogsDesc => 'Exporter les journaux d\'une plage de dates donnée';
	@override String get exportMergedLogs => 'Exporter les journaux fusionnés';
	@override String get exportMergedLogsDesc => 'Exporter les journaux fusionnés d\'une plage de dates donnée';
	@override String get showLogStats => 'Afficher les statistiques des journaux';
	@override String get logExportSuccess => 'Export des journaux réussi';
	@override String logExportFailed({required Object error}) => 'Échec de l\'export des journaux : ${error}';
	@override String get showLogStatsDesc => 'Consulter les statistiques des différents types de journaux';
	@override String logExtractFailed({required Object error}) => 'Échec de l\'obtention des statistiques de journaux : ${error}';
	@override String get clearAllLogs => 'Effacer tous les journaux';
	@override String get clearAllLogsDesc => 'Effacer toutes les données de journal';
	@override String get confirmClearAllLogs => 'Confirmer l\'effacement';
	@override String get confirmClearAllLogsDesc => 'Voulez-vous vraiment effacer toutes les données de journal ? Cette opération est irréversible.';
	@override String get clearAllLogsSuccess => 'Journaux effacés avec succès';
	@override String clearAllLogsFailed({required Object error}) => 'Échec de l\'effacement des journaux : ${error}';
	@override String get unableToGetLogSizeInfo => 'Impossible d\'obtenir les informations de taille des journaux';
	@override String get currentLogSize => 'Taille actuelle des journaux :';
	@override String get logCount => 'Nombre de journaux :';
	@override String get logCountUnit => 'journaux';
	@override String get logSizeLimit => 'Limite de taille des journaux :';
	@override String get usageRate => 'Taux d\'utilisation :';
	@override String get exceedLimit => 'Dépasser la limite';
	@override String get remaining => 'Restant';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'La taille des journaux est dépassée, veuillez nettoyer les anciens journaux ou augmenter la limite de taille';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'La taille des journaux est presque atteinte, veuillez nettoyer les anciens journaux';
	@override String get cleaningOldLogs => 'Nettoyage des anciens journaux...';
	@override String get logCleaningCompleted => 'Nettoyage des journaux terminé';
	@override String get logCleaningProcessMayNotBeCompleted => 'Le nettoyage des journaux n\'est peut-être pas terminé';
	@override String get cleanExceededLogs => 'Nettoyer les journaux excédentaires';
	@override String get noLogsToExport => 'Aucun journal à exporter';
	@override String get exportingLogs => 'Exportation des journaux...';
	@override String get noHistoryLogsToExport => 'Aucun historique de journaux à exporter, utilisez d\'abord l\'application quelque temps';
	@override String get selectLogDate => 'Choisir la date des journaux';
	@override String get today => 'Aujourd\'hui';
	@override String get selectMergeRange => 'Choisir la plage de fusion';
	@override String get selectMergeRangeHint => 'Veuillez choisir la plage horaire des journaux à fusionner';
	@override String selectMergeRangeDays({required Object days}) => '${days} derniers jours';
	@override String get logStats => 'Statistiques des journaux';
	@override String todayLogs({required Object count}) => 'Journaux d\'aujourd\'hui : ${count} journaux';
	@override String recent7DaysLogs({required Object count}) => 'Journaux des 7 derniers jours : ${count} journaux';
	@override String totalLogs({required Object count}) => 'Total des journaux : ${count} journaux';
	@override String get setLogDatabaseSizeLimit => 'Définir la limite de taille de la base de journaux';
	@override String currentLogSizeWithSize({required Object size}) => 'Taille actuelle des journaux : ${size}';
	@override String get warning => 'Avertissement';
	@override String newSizeLimit({required Object size}) => 'Nouvelle limite de taille : ${size}';
	@override String get confirmToContinue => 'Confirmez pour continuer';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Limite de taille des journaux définie sur ${size}';
}

// Path: emoji
class _TranslationsEmojiFr extends TranslationsEmojiEn {
	_TranslationsEmojiFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Emoji';
	@override String get size => 'Taille';
	@override String get small => 'Petit';
	@override String get medium => 'Moyen';
	@override String get large => 'Grand';
	@override String get extraLarge => 'Très grand';
	@override String get copyEmojiLinkSuccess => 'Lien de l\'emoji copié';
	@override String get preview => 'Aperçu de l\'emoji';
	@override String get library => 'Bibliothèque d\'emojis';
	@override String get noEmojis => 'Aucun emoji';
	@override String get clickToAddEmojis => 'Cliquez sur le bouton en haut à droite pour ajouter des emojis';
	@override String get addEmojis => 'Ajouter des emojis';
	@override String get imagePreview => 'Aperçu de l\'image';
	@override String get imageLoadFailed => 'Échec du chargement de l\'image';
	@override String get loading => 'Chargement...';
	@override String get delete => 'Supprimer';
	@override String get close => 'Fermer';
	@override String get deleteImage => 'Supprimer l\'image';
	@override String get confirmDeleteImage => 'Voulez-vous vraiment supprimer cette image ?';
	@override String get cancel => 'Annuler';
	@override String get batchDelete => 'Suppression groupée';
	@override String confirmBatchDelete({required Object count}) => 'Voulez-vous vraiment supprimer les ${count} images sélectionnées ? Cette opération est irréversible.';
	@override String get deleteSuccess => 'Supprimé avec succès';
	@override String get addImage => 'Ajouter une image';
	@override String get addImageByUrl => 'Ajouter par URL';
	@override String get addImageUrl => 'Ajouter une URL d\'image';
	@override String get imageUrl => 'URL de l\'image';
	@override String get enterImageUrl => 'Veuillez saisir l\'URL de l\'image';
	@override String get add => 'Ajouter';
	@override String get batchImport => 'Importation groupée';
	@override String get enterJsonUrlArray => 'Veuillez saisir le tableau d\'URL au format JSON :';
	@override String get formatExample => 'Exemple de format :\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Veuillez coller le tableau d\'URL au format JSON';
	@override String get import => 'Importer';
	@override String importSuccess({required Object count}) => '${count} images importées avec succès';
	@override String get jsonFormatError => 'Erreur de format JSON, vérifiez la saisie';
	@override String get createGroup => 'Créer un groupe d\'emojis';
	@override String get groupName => 'Nom du groupe';
	@override String get enterGroupName => 'Veuillez saisir le nom du groupe';
	@override String get create => 'Créer';
	@override String get editGroupName => 'Modifier le nom du groupe';
	@override String get save => 'Enregistrer';
	@override String get deleteGroup => 'Supprimer le groupe';
	@override String get confirmDeleteGroup => 'Voulez-vous vraiment supprimer ce groupe d\'emojis ? Toutes les images du groupe seront également supprimées.';
	@override String imageCount({required Object count}) => '${count} image(s)';
	@override String get selectEmoji => 'Choisir un emoji';
	@override String get noEmojisInGroup => 'Aucun emoji dans ce groupe';
	@override String get goToSettingsToAddEmojis => 'Allez dans les réglages pour ajouter des emojis';
	@override String get emojiManagement => 'Gestion des emojis';
	@override String get manageEmojiGroupsAndImages => 'Gérer les groupes d\'emojis et les images';
	@override String get uploadLocalImages => 'Envoyer des images locales';
	@override String get uploadingImages => 'Envoi des images';
	@override String uploadingImagesProgress({required Object count}) => 'Envoi de ${count} images, veuillez patienter...';
	@override String get doNotCloseDialog => 'Ne fermez pas cette fenêtre';
	@override String uploadSuccess({required Object count}) => '${count} images envoyées avec succès';
	@override String uploadFailed({required Object count}) => 'Échec : ${count}';
	@override String get uploadFailedMessage => 'Échec de l\'envoi de l\'image, vérifiez la connexion réseau ou le format du fichier';
	@override String uploadErrorMessage({required Object error}) => 'Une erreur est survenue pendant l\'envoi : ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterFr extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Sélectionner un champ';
	@override String get add => 'Ajouter';
	@override String get clear => 'Effacer';
	@override String get clearAll => 'Tout effacer';
	@override String get generatedQuery => 'Requête générée';
	@override String get copyToClipboard => 'Copier dans le presse-papiers';
	@override String get copied => 'Copié';
	@override String filterCount({required Object count}) => '${count} filtres';
	@override String get filterSettings => 'Paramètres de filtre';
	@override String get field => 'Champ';
	@override String get operator => 'Opérateur';
	@override String get language => 'Langue';
	@override String get value => 'Valeur';
	@override String get dateRange => 'Plage de dates';
	@override String get numberRange => 'Plage de nombres';
	@override String get from => 'De';
	@override String get to => 'À';
	@override String get date => 'Date';
	@override String get number => 'Nombre';
	@override String get boolean => 'Booléen';
	@override String get tags => 'Tags';
	@override String get select => 'Sélectionner';
	@override String get clickToSelectDate => 'Cliquez pour choisir une date';
	@override String get pleaseEnterValidNumber => 'Veuillez saisir un nombre valide';
	@override String get pleaseEnterValidDate => 'Veuillez saisir une date valide (AAAA-MM-JJ)';
	@override String get startValueMustBeLessThanEndValue => 'La valeur de début doit être inférieure à la valeur de fin';
	@override String get startDateMustBeBeforeEndDate => 'La date de début doit être antérieure à la date de fin';
	@override String get pleaseFillStartValue => 'Veuillez saisir la valeur de début';
	@override String get pleaseFillEndValue => 'Veuillez saisir la valeur de fin';
	@override String get rangeValueFormatError => 'Format de valeur de plage incorrect';
	@override String get contains => 'Contient';
	@override String get equals => 'Égal à';
	@override String get notEquals => 'Différent de';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Plage';
	@override String get kIn => 'Contient au moins un';
	@override String get notIn => 'Ne contient aucun';
	@override String get username => 'Nom d\'utilisateur';
	@override String get nickname => 'Pseudo';
	@override String get registrationDate => 'Date d\'inscription';
	@override String get description => 'Description';
	@override String get title => 'Titre';
	@override String get body => 'Corps';
	@override String get author => 'Auteur';
	@override String get publishDate => 'Date de publication';
	@override String get private => 'Privé';
	@override String get duration => 'Durée (secondes)';
	@override String get likes => 'J\'aime';
	@override String get views => 'Vues';
	@override String get comments => 'Commentaires';
	@override String get rating => 'Note';
	@override String get imageCount => 'Nombre d\'images';
	@override String get videoCount => 'Nombre de vidéos';
	@override String get createDate => 'Date de création';
	@override String get content => 'Contenu';
	@override String get all => 'Tout';
	@override String get adult => 'Adulte';
	@override String get general => 'Général';
	@override String get yes => 'Oui';
	@override String get no => 'Non';
	@override String get users => 'Utilisateurs';
	@override String get videos => 'Vidéos';
	@override String get images => 'Images';
	@override String get posts => 'Publications';
	@override String get forumThreads => 'Sujets du forum';
	@override String get forumPosts => 'Messages du forum';
	@override String get playlists => 'Playlists';
	@override late final _TranslationsSearchFilterSortTypesFr sortTypes = _TranslationsSearchFilterSortTypesFr._(_root);
	@override String get drawerSubtitle => 'Les changements s\'appliquent aussitôt';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupFr extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeFr welcome = _TranslationsFirstTimeSetupWelcomeFr._(_root);
	@override late final _TranslationsFirstTimeSetupBasicFr basic = _TranslationsFirstTimeSetupBasicFr._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkFr network = _TranslationsFirstTimeSetupNetworkFr._(_root);
	@override late final _TranslationsFirstTimeSetupThemeFr theme = _TranslationsFirstTimeSetupThemeFr._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerFr player = _TranslationsFirstTimeSetupPlayerFr._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialFr spatial = _TranslationsFirstTimeSetupSpatialFr._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionFr completion = _TranslationsFirstTimeSetupCompletionFr._(_root);
	@override late final _TranslationsFirstTimeSetupCommonFr common = _TranslationsFirstTimeSetupCommonFr._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperFr extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Proxy système détecté';
	@override String get copied => 'Copié';
	@override String get copy => 'Copier';
}

// Path: tagSelector
class _TranslationsTagSelectorFr extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Sélectionner des tags';
	@override String get clickToSelectTags => 'Cliquez pour sélectionner des tags';
	@override String get addTag => 'Ajouter un tag';
	@override String get removeTag => 'Retirer le tag';
	@override String get deleteTag => 'Supprimer le tag';
	@override String get usageInstructions => 'Ajoutez d\'abord des tags, puis cliquez pour en sélectionner parmi les tags existants';
	@override String get usageInstructionsTooltip => 'Mode d\'emploi';
	@override String get addTagTooltip => 'Ajouter un tag';
	@override String get removeTagTooltip => 'Retirer le tag';
	@override String get cancelSelection => 'Annuler la sélection';
	@override String get selectAll => 'Tout sélectionner';
	@override String get cancelSelectAll => 'Annuler la sélection globale';
	@override String get delete => 'Supprimer';
}

// Path: anime4k
class _TranslationsAnime4kFr extends TranslationsAnime4kEn {
	_TranslationsAnime4kFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Mise à l\'échelle et débruitage vidéo en temps réel, améliorant la qualité des vidéos d\'animation';
	@override String get settings => 'Réglages Anime4K';
	@override String get preset => 'Préréglage Anime4K';
	@override String get disable => 'Désactiver Anime4K';
	@override String get disableDescription => 'Désactiver les effets d\'amélioration vidéo';
	@override String get highQualityPresets => 'Préréglages haute qualité';
	@override String get fastPresets => 'Préréglages rapides';
	@override String get litePresets => 'Préréglages légers';
	@override String get moreLitePresets => 'Préréglages très légers';
	@override String get customPresets => 'Préréglages personnalisés';
	@override late final _TranslationsAnime4kPresetGroupsFr presetGroups = _TranslationsAnime4kPresetGroupsFr._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsFr presetDescriptions = _TranslationsAnime4kPresetDescriptionsFr._(_root);
	@override late final _TranslationsAnime4kPresetNamesFr presetNames = _TranslationsAnime4kPresetNamesFr._(_root);
	@override String get performanceTip => '💡 Astuce : choisissez des préréglages adaptés aux performances de l\'appareil. Les appareils d\'entrée de gamme devraient utiliser des préréglages légers.';
	@override String get compatibilityTip => '⚠️ Certains GPU mobiles (ex. Kirin 980 / Mali-G76) ne peuvent afficher aucun shader personnalisé. Si l\'image devient noire alors que le son continue, désactivez Anime4K ici.';
	@override String get autoDisabledOnRenderFailure => 'Le GPU de votre appareil n\'a pas pu appliquer le shader Anime4K ; il a donc été désactivé automatiquement.';
}

// Path: siteMode
class _TranslationsSiteModeFr extends TranslationsSiteModeEn {
	_TranslationsSiteModeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mode de site';
	@override String get mainSite => 'Principal';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Actuel : ${currentSite} · Touchez pour passer à ${nextSite}';
	@override String get dialogTitle => 'Changer de mode de site';
	@override String get dialogDescription => 'Le changement actualisera toute l\'app et réinitialisera les listes et l\'état des pages chargés précédemment.';
	@override String get chooseLinkTargetTitle => 'Choisir le site cible';
	@override String get chooseLinkTargetDescription => 'Ce lien n\'inclut pas de domaine. Choisissez de l\'ouvrir dans Principal ou AI.';
	@override String get chooseLinkTargetHint => 'Une fois ouvert, cette page et les requêtes de détail suivantes continueront d\'utiliser le site sélectionné.';
	@override String get alreadyUsing => 'Vous utilisez déjà ce mode de site.';
	@override String openInSite({required Object site}) => 'Ouvrir dans ${site}';
	@override String confirmUsing({required Object site}) => 'Après confirmation, les requêtes suivantes utiliseront le mode ${site}.';
	@override String switched({required Object site}) => 'Passé à ${site}. L\'app a été actualisée.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigFr extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtres enregistrés';
	@override String get empty => 'Aucun filtre enregistré';
	@override String get saveTooltip => 'Enregistrer le filtre actuel';
	@override String get namePromptTitle => 'Enregistrer le filtre';
	@override String get nameLabel => 'Nom';
	@override String get nameHint => 'Saisir un nom';
	@override String get saveSuccess => 'Filtre enregistré';
	@override String get deleteSuccess => 'Filtre supprimé';
	@override String get addCurrent => 'Enregistrer le filtre actuel';
	@override String get reorderHint => 'Appuyez longuement et faites glisser pour réorganiser';
	@override String get rename => 'Renommer';
	@override String get unnamed => 'Sans nom';
	@override String get noConditions => 'Tout le contenu (sans filtre)';
	@override String tagsCount({required Object count}) => '${count} tags';
}

// Path: savedSearch
class _TranslationsSavedSearchFr extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recherches enregistrées';
	@override String get empty => 'Aucune recherche enregistrée';
	@override String get saveTooltip => 'Enregistrer la recherche actuelle';
	@override String get namePromptTitle => 'Enregistrer la recherche';
	@override String get nameLabel => 'Nom';
	@override String get nameHint => 'Saisir un nom';
	@override String get saveSuccess => 'Recherche enregistrée';
	@override String get deleteSuccess => 'Recherche supprimée';
	@override String get addCurrent => 'Enregistrer la recherche actuelle';
	@override String get reorderHint => 'Appuyez longuement et faites glisser pour réorganiser';
	@override String get rename => 'Renommer';
	@override String get noKeyword => '(Aucun mot-clé)';
	@override String filtersCount({required Object count}) => '${count} filtres';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderFr extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Liste noire de tags par défaut détectée';
	@override String get content => 'Votre compte utilise toujours la liste noire de tags appliquée automatiquement par le site à chaque nouveau compte. Voulez-vous la consulter et la gérer ?';
	@override String get goManage => 'Gérer';
	@override String get dismiss => 'Plus tard';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistFr extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aide à la vision des couleurs';
	@override String get description => 'Corrige les couleurs des vidéos pour les personnes daltoniennes ; utilisable avec Anime4K';
	@override String get galleryDescription => 'Corrige les couleurs des images de la galerie pour les personnes daltoniennes (indépendamment du réglage du lecteur)';
	@override String get galleryDescriptionSpatial => 'Corrige les couleurs des images de la galerie pour les personnes daltoniennes. S\'applique uniquement à la visionneuse 2D de ce panneau — les images de l\'écran spatial sont rendues nativement et ne passent pas par ce filtre';
	@override String get disable => 'Désactivé';
	@override String get disableDescription => 'Aucune correction des couleurs';
	@override String get protanopia => 'Aide au rouge (protanopie)';
	@override String get protanopiaDescription => 'Pour la protanopie — difficulté à distinguer le rouge';
	@override String get deuteranopia => 'Aide au vert (deutéranopie)';
	@override String get deuteranopiaDescription => 'Pour la deutéranopie — difficulté à distinguer le vert';
	@override String get tritanopia => 'Aide au bleu (tritanopie)';
	@override String get tritanopiaDescription => 'Pour la tritanopie — difficulté à distinguer le bleu et le jaune';
	@override String appliedToast({required Object filterName}) => '${filterName} appliqué, effet immédiat';
	@override String get disabledToast => 'Aide à la vision des couleurs désactivée';
}

// Path: externalPlayer
class _TranslationsExternalPlayerFr extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ouvrir avec une autre application';
	@override String get description => 'Transmettez la vidéo en cours à un autre lecteur de cet appareil, comme Skybox ou Pigasus sur un casque VR, ou MX Player et VLC sur un téléphone';
	@override String get openWithOtherApp => 'Choisir une autre application';
	@override String get openWithOtherAppDescription => 'Afficher le sélecteur du système et choisir un lecteur pour prendre le relais';
	@override String get openWithSystemPlayer => 'Ouvrir dans le lecteur par défaut';
	@override String get openWithSystemPlayerDescription => 'Le transmettre à l\'application vidéo par défaut du système';
	@override String get copyLink => 'Copier le lien de la vidéo';
	@override String get copyLinkDescription => 'Pour les lecteurs qui acceptent uniquement le collage d\'une URL, comme Skybox ou DeoVR';
	@override String get linkCopied => 'Lien de la vidéo copié';
	@override String get sourceLocal => 'Fichier local';
	@override String get sourceOnline => 'Lien direct';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Lien direct · ${quality}';
	@override String get onlineLinkExpiryHint => 'Les liens directs expirent ; un lecteur externe peut donc s\'arrêter en cours de route. Télécharger d\'abord est la solution fiable.';
	@override String get vrPlayerHint => 'Si votre lecteur VR est absent du sélecteur, utilisez Copier le lien de la vidéo et collez-le dans ce lecteur.';
	@override String get noHandler => 'Aucune application de cet appareil ne peut ouvrir la vidéo';
	@override String handoffFailed({required Object message}) => 'Échec de la transmission : ${message}';
	@override String get handoffFailedUnknown => 'Échec de la transmission';
	@override String get sourceUnavailable => 'Impossible d\'obtenir l\'adresse de la vidéo en cours, veuillez réessayer';
	@override String get localFileMissing => 'Le fichier local n\'existe plus';
	@override String get handedOff => 'Transmis au lecteur externe';
	@override String get desktopSectionTitle => 'Lecteurs externes';
	@override String get managePlayers => 'Gérer les lecteurs externes';
	@override String get managePlayersDescWindows => 'Les lecteurs PCVR comme HereSphere, DeoVR et Whirligig ne sont pas l\'application par défaut du système. Indiquez leur .exe ici et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.';
	@override String get managePlayersDescMac => 'Indiquez ici des lecteurs comme IINA, VLC ou mpv et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.';
	@override String get managePlayersDescLinux => 'Indiquez ici des lecteurs comme mpv, VLC ou Celluloid et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.';
	@override String get pickExecutableHintWindows => 'Choisissez le .exe principal dans le dossier d\'installation du lecteur, par ex. HereSphere.exe ou vlc.exe. Les raccourcis du bureau (.lnk) ne fonctionneront pas.';
	@override String get pickExecutableHintMac => 'Choisissez le .app du lecteur dans Applications, par ex. IINA.app — l\'exécutable réel qu\'il contient est localisé pour vous.';
	@override String get pickExecutableHintLinux => 'Choisissez l\'exécutable du lecteur, par ex. /usr/bin/mpv. La commande which mpv vous indiquera son emplacement.';
	@override String emptyStateGuide({required Object examples}) => 'Une fois configuré, il apparaît comme entrée distincte sous Ouvrir avec une autre application sur la page du lecteur. Les plus courants : ${examples}';
	@override String get detectNothingFoundGuide => 'Aucun lecteur installé trouvé. Les dossiers d\'installation personnalisés et les versions portables ne peuvent pas être détectés — utilisez Ajouter un lecteur pour en indiquer un vous-même.';
	@override String get detectNothingNew => 'Aucun nouveau lecteur trouvé ; tout ce qui est installé figure déjà dans la liste';
	@override String get detectFailed => 'Échec de la détection — utilisez Ajouter un lecteur pour en indiquer un vous-même';
	@override String get advancedOptions => 'Avancé';
	@override String get playerNameHint => 'Laissez vide pour utiliser le nom du fichier';
	@override String get executablePathRequired => 'Choisissez d\'abord l\'exécutable du lecteur';
	@override String playerCount({required Object count}) => '${count} configuré(s)';
	@override String get noPlayerConfigured => 'Aucun lecteur externe configuré pour l\'instant';
	@override String get autoDetect => 'Détection automatique';
	@override String get detecting => 'Détection…';
	@override String detectFound({required Object count}) => '${count} lecteur(s) trouvé(s)';
	@override String get detectNothingFound => 'Aucun nouveau lecteur trouvé, ajoutez-en un manuellement';
	@override String get autoDetectedTag => 'détecté';
	@override String get addPlayer => 'Ajouter un lecteur';
	@override String get editPlayer => 'Modifier le lecteur';
	@override String get playerName => 'Nom';
	@override String get executablePath => 'Exécutable';
	@override String get browse => 'Parcourir';
	@override String get argumentTemplate => 'Arguments de lancement';
	@override String get argumentTemplateHint => 'Utilisez {input} pour le chemin ou l\'URL de la vidéo. Laissez vide pour le transmettre comme unique argument.';
	@override String get nameAndPathRequired => 'Le nom et l\'exécutable sont tous deux obligatoires';
	@override String get testLaunch => 'Tester le lancement';
	@override String get testLaunched => 'Lecteur lancé';
	@override String get testFailed => 'Échec du lancement, vérifiez le chemin de l\'exécutable';
	@override String get executableMissing => 'Exécutable introuvable';
	@override String openWithNamed({required Object name}) => 'Ouvrir dans ${name}';
	@override String get managePlayersEntry => 'Gérer les lecteurs externes…';
}

// Path: watchLater
class _TranslationsWatchLaterFr extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Regarder plus tard';
	@override String get addToWatchLater => 'Regarder plus tard';
	@override String get removeFromWatchLater => 'Retirer de Regarder plus tard';
	@override String get addedToWatchLater => 'Ajouté à Regarder plus tard';
	@override String get alreadyInWatchLater => 'Déjà dans Regarder plus tard';
	@override String get removedFromWatchLater => 'Retiré de Regarder plus tard';
	@override String removedCount({required Object count}) => '${count} éléments retirés';
	@override String get viewWatchLaterList => 'Voir la liste';
	@override String get addFailed => 'Échec de l\'ajout à Regarder plus tard';
	@override String get invalidItem => 'Indisponible';
	@override String get clearWatched => 'Effacer les vus';
	@override String watchedCleared({required Object count}) => '${count} éléments vus effacés';
	@override String get noWatchedToClear => 'Aucun élément vu à effacer';
	@override String get emptyVideo => 'Aucune vidéo dans Regarder plus tard';
	@override String get emptyGallery => 'Aucune galerie dans Regarder plus tard';
	@override String get filterAll => 'Tout';
	@override String get filterUnwatched => 'Non vus';
	@override String get sortRecentlyAdded => 'Ajoutés récemment';
	@override String get sortEarliestAdded => 'Ajoutés en premier';
	@override String get watched => 'Vus';
	@override String get playlistLoadFailed => 'Échec du chargement des playlists';
	@override String get noPlaylists => 'Aucune playlist';
	@override String get undo => 'Annuler';
	@override String get clearWatchedConfirm => 'Effacer tout ce que vous avez déjà regardé dans cet onglet ? Cette action est irréversible.';
	@override String get emptyUnwatchedVideo => 'Plus rien à regarder ici';
	@override String get emptyUnwatchedGallery => 'Plus rien à regarder ici';
	@override String get queueLoadFailed => 'Échec du chargement, touchez pour réessayer';
}

// Path: mediaMenu
class _TranslationsMediaMenuFr extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get like => 'J\'aime';
	@override String get unlike => 'Je n\'aime plus';
	@override String get viewAuthor => 'Voir l\'auteur';
	@override String inFolders({required Object count}) => '${count} dossiers';
	@override String inPlaylists({required Object count}) => '${count} listes de lecture';
	@override String get downloaded => 'Téléchargé';
}

// Path: mediaPreview
class _TranslationsMediaPreviewFr extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Aperçu';
	@override String get openDetail => 'Ouvrir';
	@override String get moreActions => 'Plus d\'actions';
	@override String get previousImage => 'Image précédente';
	@override String get nextImage => 'Image suivante';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueFr extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} images';
	@override String get upNext => 'À suivre';
	@override String get sourceTab => 'Source';
	@override String get emptyQueue => 'Rien à lire dans cette file';
	@override String get emptyGalleryQueue => 'Aucune galerie dans cette file';
	@override String get nowPlaying => 'Lecture en cours';
	@override String get myPlaylists => 'Mes playlists';
	@override String get authorPlaylists => 'Playlists de l\'auteur';
	@override String get openQueue => 'À suivre';
	@override String get continueInQueue => 'Continuer la lecture depuis la file actuelle';
	@override String get continueInQueueSubtitle => 'Lit l\'élément suivant automatiquement ; désactive « répéter à la fin »';
	@override String get repeatDisabledByQueue => 'Désactivé lorsque « continuer la lecture depuis la file actuelle » est activé';
	@override String get playNext => 'Lire ensuite';
	@override String get queueEnded => 'C\'est le dernier élément de la file';
	@override String get playNextHint => 'Touchez pour lire l\'élément suivant, appuyez longuement pour ouvrir « À suivre »';
	@override String get authorVideos => 'Vidéos de l\'auteur';
	@override String get authorGalleries => 'Galeries de l\'auteur';
	@override String get favoriteFolders => 'Dossiers favoris';
	@override String get localFiles => 'Sur cet appareil';
	@override String get currentFolder => 'Dossier de ce fichier';
	@override String get playThisFolder => 'Voir la file de vidéos de ce dossier';
	@override String get browseThisFolder => 'Voir la file de galeries de ce dossier';
	@override String get downloads => 'Téléchargés';
	@override String get otherPlaylists => 'Playlists d\'autres utilisateurs';
	@override String get nothingHere => 'Rien ici';
}

// Path: vrFormat
class _TranslationsVrFormatFr extends TranslationsVrFormatEn {
	_TranslationsVrFormatFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Lire dans le lecteur spatial';
	@override String get handingOff => 'Transfert vers l\'espace…';
	@override String get title => 'Mode de lecture';
	@override String get spatialSectionTitle => 'Lecture spatiale';
	@override String get spatialSectionDesc => 'Sur le casque, une vidéo n\'est pas affichée dans ce panneau — le lecteur spatial la place sur un écran dans la pièce.';
	@override String get spatialPanelEntry => 'Panneau de contrôle spatial';
	@override String get spatialPanelEntryDesc => 'La distance, la taille et la courbure de l\'écran, l\'environnement d\'arrière-plan, ainsi que la vitesse, la répétition et le masquage automatique se trouvent dans le panneau de contrôle spatial.';
	@override String get spatialGuideEntry => 'Guide des commandes du casque';
	@override String get spatialGuideEntryDesc => 'Boutons de la manette, saisie de l\'écran, déplacement au stick et changements de page';
	@override String get spatialFlatOmitted => 'Les gestes tactiles, l\'amélioration d\'image et les paramètres audio/vidéo ne s\'appliquent qu\'au lecteur 2D ; le lecteur spatial utilise un autre moteur, ils ne sont donc pas listés ici.';
	@override String get spatialGallerySectionTitle => 'Galerie spatiale';
	@override String get spatialGalleryPanelDesc => 'L\'intervalle du diaporama, la répétition d\'un seul clip et la courbure de l\'écran se règlent dans le panneau de contrôle spatial.';
	@override String get autoEnterGallery => 'Ouvrir les images de galerie dans la galerie spatiale';
	@override String get autoEnterGalleryDesc => 'Sur Quest, toucher une image ouvre toute la galerie sur l\'écran flottant, avec bande de vignettes, diaporama et pagination à la manette, au lieu de la visionneuse intégrée à ce panneau.';
	@override String get panelSettings => 'Panneau et arrière-plan';
	@override String get panelSettingsDesc => 'À quelle distance se trouve ce panneau et quelle part de votre pièce apparaît derrière';
	@override String get panelDistance => 'Distance du panneau';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Réinitialiser le placement';
	@override String get panelResetBackground => 'Réinitialiser';
	@override String get panelBackground => 'Transparence de l\'arrière-plan';
	@override String get panelBackgroundHint => '0 % : environnement noir · 100 % : votre pièce réelle, éclairée par l\'ambiance';
	@override String get panelUnavailable => 'Le panneau n\'est pas en place pour le moment — réessayez dans un instant';
	@override String get desc => 'Choisissez la géométrie avec laquelle lire cette vidéo. Le site ne fournit pas cette information, la détection automatique ne donne donc qu\'un point de départ — votre choix l\'emporte.';
	@override String get sectionFlat => 'Plat';
	@override String get sectionStereo => '3D plat';
	@override String get sectionPanorama => 'Panorama VR';
	@override String get flat => 'Vidéo normale';
	@override String get flatDesc => 'Lire telle quelle, sans remappage';
	@override String get flatSideBySide => '3D côte à côte';
	@override String get flatSideBySideDesc => 'Un œil par moitié, gauche et droite ; affiche l\'œil gauche et rétablit ses proportions';
	@override String get flatTopBottom => '3D haut-bas';
	@override String get flatTopBottomDesc => 'Un œil par moitié, haut et bas ; affiche la moitié supérieure et rétablit ses proportions';
	@override String get vr180SideBySide => 'VR180 côte à côte';
	@override String get vr180SideBySideDesc => 'Panorama hémisphérique avec les deux yeux — la source VR la plus courante';
	@override String get vr180Mono => 'VR180 mono';
	@override String get vr180MonoDesc => 'Panorama hémisphérique, un seul œil par image';
	@override String get vr360Mono => 'VR360 mono';
	@override String get vr360MonoDesc => 'Panorama à 360°, un seul œil par image';
	@override String get vr360TopBottom => 'VR360 haut-bas';
	@override String get vr360TopBottomDesc => 'Panorama à 360° avec les deux yeux empilés';
	@override String get resetView => 'Réinitialiser la vue';
	@override String get resetViewDesc => 'Ramener la direction du regard et le champ de vision vers l\'avant';
	@override String get resetToAuto => 'Revenir à la détection auto.';
	@override String get resetToAutoDesc => 'Oublier le choix manuel pour cette vidéo et laisser la détection décider à nouveau';
	@override String get manualBadge => 'Défini manuellement';
	@override String get panoramaHint => 'Faites glisser l\'image pour regarder autour, pincez pour changer le champ de vision';
	@override String get panoramaGestureNotice => 'Pendant que vous regardez autour, faire glisser tourne la vue — utilisez la barre de progression pour vous déplacer';
	@override String get shaderUnsupported => 'Cet appareil ne peut pas afficher de panorama en direct ; affichage d\'un seul œil à la place';
	@override String get handoffTooltip => 'Lire autrement';
	@override String get suggestedBadge => 'Suggéré';
	@override String suggestedEntryDesc({required Object format}) => 'Semble être ${format} — touchez pour basculer';
	@override String suggestionTitle({required Object format}) => 'Il s\'agit peut-être d\'une vidéo VR (${format})';
	@override String get suggestionTitleShort => 'Il s\'agit peut-être d\'une vidéo VR';
	@override String get suggestionAction => 'Lire en VR';
	@override String get suggestionDismiss => 'Ignorer';
}

// Path: localMedia
class _TranslationsLocalMediaFr extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseFr browse = _TranslationsLocalMediaBrowseFr._(_root);
	@override String get tabFolders => 'Dossiers';
	@override String get tabFavoriteVideos => 'Favoris';
	@override String get tabAllVideos => 'Toutes les vidéos';
	@override String get tabAllImages => 'Toutes les images';
	@override String get tabDownloadedVideos => 'Vidéos téléchargées';
	@override String get tabDownloadedGalleries => 'Galeries téléchargées';
	@override String get title => 'Sur cet appareil';
	@override String get sourceOnline => 'Iwara en ligne';
	@override String get manageSources => 'Gérer les sources';
	@override String get moveToCategory => 'Déplacer vers une catégorie';
	@override String get manageCategories => 'Gérer les catégories';
	@override String get suggestedFolders => 'Dossiers contenant des vidéos';
	@override String get sortRecentlyAdded => 'Ajoutés récemment';
	@override String get sortRecentlyPlayed => 'Lus récemment';
	@override String get sortName => 'Nom';
	@override String get sortDuration => 'Durée';
	@override String get sortSize => 'Taille';
	@override String get sortFolder => 'Dossier';
	@override String get sortRecentlyModified => 'Modifiés récemment';
	@override String get sortCount => 'Nombre';
	@override String folderCardItemCount({required Object count}) => '${count} image(s)';
	@override String get downloadsSource => 'Téléchargé';
	@override String get builtInSourceHint => 'Téléchargé est géré automatiquement';
	@override String get filterByCategory => 'Filtrer par catégorie';
	@override String get longPressToCategorize => 'Appuyez longuement pour déplacer vers une catégorie';
	@override String get uncategorized => 'Sans catégorie';
	@override String get setCategoryFailed => 'Impossible de définir la catégorie';
	@override String get categoryUpdated => 'Catégorie mise à jour';
	@override String get addFolder => 'Ajouter un dossier';
	@override String get addDeviceVideos => 'Analyser les vidéos de l\'appareil';
	@override String get mediaStoreSourceName => 'Vidéos de l\'appareil';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsFr itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsFr._(_root);
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
	@override late final _TranslationsLocalMediaMissingFr missing = _TranslationsLocalMediaMissingFr._(_root);
	@override late final _TranslationsLocalMediaWebdavFr webdav = _TranslationsLocalMediaWebdavFr._(_root);
	@override String get mediaStoreUnavailable => 'L\'index multimédia de l\'appareil n\'est disponible que sur Android';
	@override String get mediaStorePermissionDenied => 'L\'accès aux vidéos n\'a pas été accordé';
	@override String get rescan => 'Réanalyser';
	@override String scanning({required Object count}) => 'Analyse… ${count} trouvés';
	@override String scanFailed({required Object reason}) => 'Échec de l\'analyse : ${reason}';
	@override String scanTruncated({required Object count}) => 'Ce dossier est très volumineux — seuls les ${count} premiers fichiers ont été ajoutés.';
	@override String sourceOverlaps({required Object name}) => 'Déjà couvert par le dossier « ${name} »';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '« ${name} » se trouve dans « ${source} », il a donc été ajouté aux dossiers épinglés';
	@override String alreadyPinnedFolder({required Object name}) => '« ${name} » figure déjà dans les dossiers épinglés';
	@override String sourceAlreadyAdded({required Object name}) => '« ${name} » a déjà été ajouté';
	@override String sourceContainsExisting({required Object name}) => 'Il contient déjà le dossier ajouté « ${name} » ; l\'ajout de son dossier parent n\'est pas encore pris en charge';
	@override String get addSourceFailed => 'Impossible d\'ajouter ce dossier';
	@override String get fileMissing => 'Ce fichier n\'est plus sur le disque';
	@override String get permissionDenied => 'Accès aux fichiers non accordé · appuyez pour l\'accorder';
	@override String get noVideosFound => 'Aucune vidéo dans ce dossier';
	@override String get emptyTitle => 'Ajoutez un dossier pour lire les vidéos déjà présentes sur cet appareil';
	@override String get emptyPrivacyNote => 'Les fichiers sont lus uniquement sur cet appareil. Rien n\'est envoyé.';
	@override String removeSourceTitle({required Object name}) => 'Retirer « ${name} » ?';
	@override String get removeSourceBody => 'Les fichiers restent sur le disque. Seule cette entrée de la bibliothèque est retirée.';
	@override String get remove => 'Retirer';
	@override String get removeFolder => 'Retirer le dossier';
	@override String get removeFolderSelectTitle => 'Choisir le dossier à retirer';
	@override String get longPressToRemove => 'Appuyez longuement pour retirer ce dossier';
	@override String get clearProgress => 'Effacer l\'historique de lecture local';
	@override String clearProgressCount({required Object count}) => '${count} entrées';
	@override String get clearProgressEmpty => 'Aucun historique de lecture local pour l\'instant';
	@override String get clearProgressTitle => 'Effacer l\'historique de lecture local ?';
	@override String get clearProgressBody => 'Seules les positions de lecture et les marques de visionnage sont supprimées. Vos fichiers et dossiers restent exactement tels quels.';
	@override String clearProgressDone({required Object count}) => '${count} entrées de l\'historique de lecture local effacées';
	@override String get clearAction => 'Effacer';
	@override String get iosManualRescanNotice => 'iOS ne détecte pas automatiquement les nouveaux fichiers. Vous devrez relancer une analyse manuellement après avoir ajouté ou supprimé des fichiers.';
}

// Path: historyPage
class _TranslationsHistoryPageFr extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Retirer de l\'historique';
	@override String get removed => 'Retiré de l\'historique';
	@override String watchedTo({required Object time}) => 'Vu jusqu’à ${time}';
	@override String get finished => 'Vu';
	@override String clearTabTitle({required Object tab}) => 'Effacer « ${tab} »';
	@override String clearTabConfirm({required Object tab}) => 'Tout l’historique de « ${tab} » sera supprimé, ainsi que la progression de lecture de ces vidéos. Action irréversible.';
	@override String get rangeByLastViewed => 'Filtré par dernière consultation';
}

// Path: common.pagination
class _TranslationsCommonPaginationFr extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Total : ${num} éléments';
	@override String get jumpToPage => 'Aller à la page';
	@override String pleaseEnterPageNumber({required Object max}) => 'Veuillez saisir le numéro de page (1-${max})';
	@override String get pageNumber => 'Numéro de page';
	@override String get jump => 'Aller';
	@override String invalidPageNumber({required Object max}) => 'Veuillez saisir un numéro de page valide (1-${max})';
	@override String get invalidInput => 'Veuillez saisir un numéro de page valide';
	@override String get waterfall => 'Cascade';
	@override String get pagination => 'Pagination';
}

// Path: errors.network
class _TranslationsErrorsNetworkFr extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Erreur réseau - ';
	@override String get failedToConnectToServer => 'Échec de la connexion au serveur';
	@override String get serverNotAvailable => 'Serveur indisponible';
	@override String get requestTimeout => 'Délai de requête dépassé';
	@override String get unexpectedError => 'Erreur inattendue';
	@override String get invalidResponse => 'Réponse invalide';
	@override String get invalidRequest => 'Requête invalide';
	@override String get invalidUrl => 'URL invalide';
	@override String get invalidMethod => 'Méthode invalide';
	@override String get invalidHeader => 'En-tête invalide';
	@override String get invalidBody => 'Corps invalide';
	@override String get invalidStatusCode => 'Code d\'état invalide';
	@override String get serverError => 'Erreur du serveur';
	@override String get requestCanceled => 'Requête annulée';
	@override String get invalidPort => 'Port invalide';
	@override String get proxyPortError => 'Erreur de port du proxy';
	@override String get connectionRefused => 'Connexion refusée';
	@override String get networkUnreachable => 'Réseau inaccessible';
	@override String get noRouteToHost => 'Aucune route vers l\'hôte';
	@override String get connectionFailed => 'Échec de la connexion';
	@override String get sslConnectionFailed => 'Échec de la connexion SSL, vérifiez vos paramètres réseau';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingFr extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Raccourcis clavier';
	@override String get entryLabel => 'Raccourcis clavier';
	@override String get entryDesc => 'Personnaliser les raccourcis clavier de l\'app (surtout pour ordinateur)';
	@override String get desktopHint => 'Les raccourcis s\'appliquent surtout aux claviers d\'ordinateur ; sur mobile, les gestes sont généralement utilisés.';
	@override String get resetAll => 'Tout réinitialiser';
	@override String get resetAllConfirm => 'Réinitialiser tous les raccourcis de l\'app ?';
	@override String get resetToDefault => 'Réinitialiser';
	@override String get resetScope => 'Réinitialiser cette section';
	@override String get notSet => 'Non défini';
	@override String get addShortcut => 'Ajouter un raccourci';
	@override String get removeShortcut => 'Supprimer ce raccourci';
	@override String get pressNewShortcut => 'Appuyez sur le nouveau raccourci…';
	@override String get recordingCancelHint => 'Appuyez sur Échap pour annuler';
	@override String get mouseHint => 'Vous pouvez aussi lier les boutons latéraux de la souris (retour / avant) ou le bouton central';
	@override String get mouseNotSupportedInScope => 'Cette zone ne gère pas les boutons de la souris ; utilisez le clavier';
	@override String get capabilityKeyboardOnly => 'Cette zone accepte uniquement les touches du clavier';
	@override String get capabilityKeyboardAndMouse => 'Cette zone accepte les touches du clavier, ainsi que les boutons central et latéraux de la souris';
	@override String get capabilityKeyboardAndMouseMobile => 'Cette zone accepte les touches du clavier, ainsi que les boutons central et avant de la souris (le bouton retour est utilisé par le système)';
	@override String get rejectMultipleButtons => 'Appuyez sur un bouton de souris à la fois';
	@override String get rejectPlatformBack => 'Le système l\'utilise déjà pour Retour ; le lier ferait un double retour';
	@override String get detectedLabel => 'Détecté';
	@override String get reservedKey => 'Cette touche est réservée par le système et ne peut pas être liée';
	@override String reservedForGlobalBack({required Object action}) => 'Cette touche est liée à « ${action} » ; elle reste réservée ici pour que vous puissiez toujours quitter cet écran';
	@override String get conflictTitle => 'Conflit de raccourci';
	@override String conflictMessage({required Object action}) => 'Cette combinaison est déjà liée à « ${action} ». Continuer supprimera la liaison existante.';
	@override String get conflictContinue => 'Lier quand même';
	@override String get shadowWarningTitle => 'Chevauchement de raccourci global';
	@override String shadowWarningMessage({required Object action}) => 'Cette combinaison est liée à « ${action} » au niveau global. La lier ici ne remplacera cette action que dans cette section.';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'Cette combinaison est déjà liée à « ${action} » dans ${scope}. Dans cette section, ce raccourci global sera remplacé par celui-ci.';
	@override String get searchHint => 'Rechercher des raccourcis…';
	@override String get scopeGlobal => 'Global';
	@override String get scopeGallery => 'Galerie';
	@override String get scopeVideo => 'Vidéo';
	@override String get categoryNavigation => 'Navigation';
	@override String get categoryZoom => 'Zoom';
	@override String get categoryPlayback => 'Lecture';
	@override String get categorySeek => 'Déplacement';
	@override String get categoryVolume => 'Volume';
	@override String get categoryDisplay => 'Affichage';
	@override String get actionGlobalBack => 'Retour';
	@override String get actionGalleryNext => 'Photo suivante';
	@override String get actionGalleryPrevious => 'Photo précédente';
	@override String get actionGalleryZoomIn => 'Zoom avant';
	@override String get actionGalleryZoomOut => 'Zoom arrière';
	@override String get actionGalleryResetZoom => 'Réinitialiser le zoom';
	@override String get actionGalleryPlayPause => 'Lecture / Pause';
	@override String get actionGallerySeekBackward => 'Rembobiner';
	@override String get actionGallerySeekForward => 'Avance rapide';
	@override String get actionGalleryToggleMute => 'Activer/couper le son';
	@override String get actionPlayPause => 'Lecture / Pause';
	@override String get actionSpeedUp => 'Augmenter la vitesse';
	@override String get actionSpeedDown => 'Réduire la vitesse';
	@override String get actionSeekForward => 'Avancer';
	@override String get actionSeekBackward => 'Reculer';
	@override String get actionVolumeUp => 'Monter le volume';
	@override String get actionVolumeDown => 'Baisser le volume';
	@override String get actionToggleMute => 'Activer/couper le son';
	@override String get actionToggleFullscreen => 'Basculer en plein écran';
	@override String get seekLongPressHint => 'Maintenez la touche avancer/reculer pour déclencher la vitesse en appui long';
	@override String get zoomSectionTitle => 'Zoom de l\'image (fixe)';
	@override String get zoomFixedNote => 'Les raccourcis ci-dessous sont fixes et ne peuvent pas être modifiés';
	@override String get zoomScaleLabel => 'Zoomer l\'image';
	@override String get zoomScaleHint => 'Ctrl + molette';
	@override String get zoomRotateLabel => 'Pivoter l\'image';
	@override String get zoomRotateHint => 'Maj + molette';
	@override String get zoomPinchGesture => 'Pincer';
	@override String get zoomTwoFingerRotateGesture => 'Rotation à deux doigts';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsFr extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Forum';
	@override String get configureYourForumSettings => 'Configurez les paramètres du forum';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsFr extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Paramètres de galerie';
	@override String get gallerySettingsSubtitle => 'Configurer les préférences de la visionneuse';
	@override String get defaultViewerQuality => 'Qualité d\'affichage par défaut';
	@override String get defaultViewerQualityDesc => 'Choisir la qualité d\'image affichée par défaut à l\'ouverture de la visionneuse.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsFr extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Blocage de contenu';
	@override String get subtitle => 'Masquer automatiquement les vidéos et galeries dont le titre correspond à un mot-clé ou à un motif, ou qui proviennent d\'un utilisateur bloqué. Tout le filtrage a lieu sur votre appareil — rien n\'est envoyé.';
	@override String get blocked => 'Bloqué';
	@override String get reveal => 'Afficher';
	@override String get reblock => 'Bloquer à nouveau';
	@override String get why => 'Pourquoi bloqué ?';
	@override String get manageRules => 'Gérer les règles';
	@override String reasonKeyword({required Object value}) => 'Le titre contient « ${value} »';
	@override String reasonRegex({required Object value}) => 'Le titre correspond à « ${value} »';
	@override String get reasonUser => 'D\'un utilisateur bloqué';
	@override String get addRule => 'Ajouter une règle';
	@override String get editRule => 'Modifier la règle';
	@override String get deleteRule => 'Supprimer la règle';
	@override String get ruleType => 'Type de règle';
	@override String get keyword => 'Mot-clé';
	@override String get regex => 'Regex';
	@override String get userId => 'Utilisateur';
	@override String get value => 'Texte à faire correspondre';
	@override String get caseSensitive => 'Sensible à la casse';
	@override String get regexHint => 'ex. trailer|teaser';
	@override String get valueRequired => 'Veuillez saisir le texte à faire correspondre';
	@override String get invalidRegex => 'Ce n\'est pas une expression régulière valide';
	@override String get noRules => 'Aucune règle pour l\'instant. Touchez + pour en ajouter une.';
	@override String get blockUser => 'Bloquer';
	@override String get unblockUser => 'Débloquer';
	@override String blockUserConfirm({required Object name}) => 'Bloquer « ${name} » ? Ses vidéos et galeries seront masquées des listes et de la recherche.';
	@override String get userBlocked => 'Utilisateur bloqué';
	@override String get userUnblocked => 'Utilisateur débloqué';
	@override String get exportRules => 'Exporter';
	@override String get importRules => 'Importer';
	@override String get importExport => 'Importer / Exporter';
	@override String get exportSuccess => 'Règles exportées';
	@override String get exportFailed => 'Échec de l\'export des règles';
	@override String importSuccess({required Object count}) => '${count} règle(s) importée(s)';
	@override String get importFailed => 'Échec de l\'import des règles';
	@override String get regexHelp => 'Aide sur les motifs';
	@override String get regexHelpTitle => 'Référence regex';
	@override String get regexHelpIntro => 'Une expression régulière filtre les titres de façon plus souple qu\'un simple mot-clé. Voici quelques exemples courants :';
	@override String get regexHelpTapHint => 'Touchez un exemple pour le reprendre.';
	@override String get regexEx1Pattern => 'bande-annonce|teaser|bonus';
	@override String get regexEx1Desc => 'Correspond à l\'un de ces mots ("|" signifie "ou")';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Titres qui commencent par [crochets]';
	@override String get regexEx3Pattern => 'Intégrale\$';
	@override String get regexEx3Desc => 'Titres qui se terminent par « Intégrale »';
	@override String get regexEx4Pattern => 'Ep.[0-9]+';
	@override String get regexEx4Desc => '[0-9]+ correspond à un ou plusieurs chiffres — correspond à « Ep.12 »';
	@override String get regexEx5Pattern => '[0-9]{4}';
	@override String get regexEx5Desc => '[0-9] correspond à un chiffre et {4} signifie quatre d\'affilée (p. ex. une année)';
	@override String get regexEx1Sample => 'Nouvelle bande-annonce disponible';
	@override String get regexEx2Sample => '[Remux] Film complet';
	@override String get regexEx3Sample => 'Intégrale d\'art du printemps';
	@override String get regexEx4Sample => 'Récapitulatif Ep.12 de ma série';
	@override String get regexEx5Sample => 'Le meilleur de 2024';
	@override String get regexHelpSampleLabel => 'Titre d\'exemple';
	@override String get regexHelpMatchedTag => 'Bloqué';
	@override String get regexHelpNoMatch => 'Aucune correspondance';
	@override String get regexEx6Pattern => '[Ss]aison';
	@override String get regexEx6Desc => '[Ss] correspond à un S majuscule ou minuscule — ici il attrape « Saison »';
	@override String get regexEx6Sample => 'Bande-annonce de la dernière saison';
	@override String get regexEx7Pattern => '(le film|la série)';
	@override String get regexEx7Desc => 'Les parenthèses () regroupent des alternatives — correspond à « le film » ou « la série »';
	@override String get regexEx7Sample => 'Regarder la série maintenant';
	@override String get regexEx8Pattern => 'saisons?';
	@override String get regexEx8Desc => 's? rend la lettre précédente facultative — correspond à « saison » et « saisons »';
	@override String get regexEx8Sample => 'Pack de deux saisons';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ signifie un ou plusieurs — correspond à !, !!, !!! ...';
	@override String get regexEx9Sample => 'OMG !!! À voir absolument';
	@override String get regexEx10Pattern => 'bonus.*scène';
	@override String get regexEx10Desc => '.* correspond à n\'importe quel texte entre les deux — « bonus … scène »';
	@override String get regexEx10Sample => 'Scène bonus supprimée';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsFr extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Discussion';
	@override String get configureYourChatSettings => 'Configurez vos paramètres de discussion';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsFr extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Paramètres de téléchargement';
	@override String get enableDownloadNotifications => 'Notifications de téléchargement';
	@override String get enableDownloadNotificationsDescription => 'Afficher une notification système lorsqu\'un téléchargement se termine ou échoue';
	@override String get notificationPermissionDenied => 'Autorisation de notification refusée. Les notifications dans l\'app fonctionnent toujours ; activez les notifications système dans les réglages.';
	@override String get storagePermissionStatus => 'État de l\'autorisation de stockage';
	@override String get accessPublicDirectoryNeedStoragePermission => 'L\'accès au dossier public nécessite l\'autorisation de stockage';
	@override String get checkingPermissionStatus => 'Vérification de l\'état des autorisations...';
	@override String get storagePermissionGranted => 'Autorisation de stockage accordée';
	@override String get storagePermissionNotGranted => 'Autorisation de stockage non accordée';
	@override String get storagePermissionGrantSuccess => 'Autorisation de stockage accordée';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Échec de l\'octroi de l\'autorisation de stockage ; certaines fonctions peuvent être limitées';
	@override String get storagePermissionRationale => 'Pour enregistrer les téléchargements dans le dossier choisi, l\'app a besoin d\'un accès au stockage.\n\nSur Android 11 et versions ultérieures, cela correspond à l\'autorisation « Accès à tous les fichiers » ; sans elle, les fichiers sont enregistrés dans le dossier privé de l\'app.';
	@override String get storagePermissionRationaleLegacy => 'Pour enregistrer les téléchargements dans le dossier choisi, l\'app a besoin d\'un accès au stockage.\n\nSans cela, les fichiers sont enregistrés dans le dossier privé de l\'app.';
	@override String get grantStoragePermission => 'Accorder l\'autorisation de stockage';
	@override String get customDownloadPath => 'Chemin de téléchargement personnalisé';
	@override String get customDownloadPathDescription => 'Une fois activé, vous pouvez choisir un emplacement d\'enregistrement personnalisé pour les fichiers téléchargés';
	@override String get customDownloadPathTip => '💡 Astuce : sélectionner des dossiers publics (comme Téléchargements) nécessite l\'autorisation de stockage ; privilégiez d\'abord les chemins recommandés';
	@override String get androidWarning => 'Note Android : évitez de sélectionner des dossiers publics (comme Téléchargements) ; privilégiez les dossiers propres à l\'app pour garantir les autorisations d\'accès.';
	@override String get publicDirectoryPermissionTip => '⚠️ Remarque : vous avez sélectionné un dossier public ; l\'autorisation de stockage est requise pour télécharger normalement les fichiers';
	@override String get permissionRequiredForPublicDirectory => 'Autorisation de stockage requise pour les dossiers publics';
	@override String get currentDownloadPath => 'Chemin de téléchargement actuel';
	@override String get actualDownloadPath => 'Chemin de téléchargement réel';
	@override String get defaultAppDirectory => 'Dossier d\'app par défaut';
	@override String get permissionGranted => 'Accordée';
	@override String get permissionRequired => 'Autorisation requise';
	@override String get enableCustomDownloadPath => 'Activer le chemin personnalisé';
	@override String get disableCustomDownloadPath => 'Utiliser le chemin d\'app par défaut si désactivé';
	@override String get customDownloadPathLabel => 'Chemin de téléchargement personnalisé';
	@override String get selectDownloadFolder => 'Sélectionner le dossier de téléchargement';
	@override String get recommendedPath => 'Chemin recommandé';
	@override String get selectFolder => 'Sélectionner un dossier';
	@override String get filenameTemplate => 'Modèle de nom de fichier';
	@override String get filenameTemplateDescription => 'Personnaliser les règles de nommage des fichiers téléchargés, avec substitution de variables';
	@override String get videoFilenameTemplate => 'Modèle de nom de vidéo';
	@override String get galleryFolderTemplate => 'Modèle de dossier de galerie';
	@override String get imageFilenameTemplate => 'Modèle de nom d\'image';
	@override String get resetToDefault => 'Réinitialiser';
	@override String get supportedVariables => 'Variables prises en charge';
	@override String get supportedVariablesDescription => 'Les variables suivantes peuvent être utilisées dans les modèles de nom de fichier :';
	@override String get copyVariable => 'Copier la variable';
	@override String get variableCopied => 'Variable copiée';
	@override String get warningPublicDirectory => 'Attention : le dossier public sélectionné peut être inaccessible. Il est conseillé de choisir un dossier propre à l\'app.';
	@override String get downloadPathUpdated => 'Chemin de téléchargement mis à jour';
	@override String get selectPathFailed => 'Échec de la sélection du chemin';
	@override String get pickerAlreadyActive => 'Le sélecteur de dossier est déjà ouvert';
	@override String get unsupportedStorageVolume => 'Emplacement de stockage non pris en charge. Choisissez un dossier sur le stockage de l\'appareil ou la carte SD.';
	@override String get recommendedPathSet => 'Défini sur le chemin recommandé';
	@override String get setRecommendedPathFailed => 'Échec de la définition du chemin recommandé';
	@override String get templateResetToDefault => 'Réinitialiser le modèle par défaut';
	@override String get functionalTest => 'Test fonctionnel';
	@override String get testInProgress => 'Test en cours...';
	@override String get runTest => 'Lancer le test';
	@override String get testDownloadPathAndPermissions => 'Vérifier que le chemin de téléchargement et la configuration des autorisations fonctionnent correctement';
	@override String get testResults => 'Résultats du test';
	@override String get testCompleted => 'Test terminé';
	@override String get testMultisegmentDomain => 'Validation du domaine de valeurs (multi-segments / dépassement / formes d\'échappement)';
	@override String get testMultisegmentPaths => 'Rendu de la structure multi-segments (issue #126)';
	@override String get testPassed => 'éléments réussis';
	@override String get testFailed => 'Échec du test';
	@override String get testStoragePermissionCheck => 'Vérification de l\'autorisation de stockage';
	@override String get testStoragePermissionGranted => 'Autorisation de stockage accordée';
	@override String get testStoragePermissionMissing => 'Autorisation de stockage manquante, certaines fonctions peuvent être limitées';
	@override String get testPermissionCheckFailed => 'Échec de la vérification des autorisations';
	@override String get testDownloadPathValidation => 'Validation du chemin de téléchargement';
	@override String get testPathValidationFailed => 'Échec de la validation du chemin';
	@override String get testFilenameTemplateValidation => 'Validation du modèle de nom de fichier';
	@override String get testAllTemplatesValid => 'Tous les modèles sont valides';
	@override String get testSomeTemplatesInvalid => 'Certains modèles contiennent des caractères non valides';
	@override String get testTemplateValidationFailed => 'Échec de la validation du modèle';
	@override String get testDirectoryOperationTest => 'Test des opérations sur dossier';
	@override String get testDirectoryOperationNormal => 'La création de dossier et l\'écriture de fichier fonctionnent normalement';
	@override String get testDirectoryOperationFailed => 'Échec de l\'opération sur le dossier';
	@override String get testVideoTemplate => 'Modèle de vidéo';
	@override String get testGalleryTemplate => 'Modèle de galerie';
	@override String get testImageTemplate => 'Modèle d\'image';
	@override String get testValid => 'Valide';
	@override String get testInvalid => 'Invalide';
	@override String get testSuccess => 'Réussi';
	@override String get testCorrect => 'Correct';
	@override String get testError => 'Erreur';
	@override String get testPath => 'Chemin de test';
	@override String get testBasePath => 'Chemin de base';
	@override String get testDirectoryCreation => 'Création de dossier';
	@override String get testFileWriting => 'Écriture de fichier';
	@override String get testFileContent => 'Contenu du fichier';
	@override String get checkingPathStatus => 'Vérification de l\'état du chemin...';
	@override String get unableToGetPathStatus => 'Impossible d\'obtenir l\'état du chemin';
	@override String get actualPathDifferentFromSelected => 'Remarque : le chemin réel diffère du chemin sélectionné';
	@override String get grantPermission => 'Accorder l\'autorisation';
	@override String get fixIssue => 'Corriger le problème';
	@override String get issueFixed => 'Problème corrigé';
	@override String get fixFailed => 'Échec de la correction, veuillez agir manuellement';
	@override String get lackStoragePermission => 'Autorisation de stockage manquante';
	@override String get cannotAccessPublicDirectory => 'Impossible d\'accéder au dossier public ; l\'autorisation « Accès à tous les fichiers » est requise';
	@override String get cannotCreateDirectory => 'Impossible de créer le dossier';
	@override String get directoryNotWritable => 'Dossier non accessible en écriture';
	@override String get insufficientSpace => 'Espace disponible insuffisant';
	@override String get pathValid => 'Chemin valide';
	@override String get validationFailed => 'Échec de la validation';
	@override String get usingDefaultAppDirectory => 'Utilisation du dossier d\'app par défaut';
	@override String get appPrivateDirectory => 'Dossier privé de l\'app';
	@override String get appPrivateDirectoryDesc => 'Sûr et fiable, aucune autorisation supplémentaire requise';
	@override String get downloadDirectory => 'Dossier de téléchargement';
	@override String get downloadDirectoryDesc => 'Emplacement de téléchargement par défaut du système, facile à gérer';
	@override String get moviesDirectory => 'Dossier Films';
	@override String get moviesDirectoryDesc => 'Dossier Films du système, reconnu par les applis multimédias';
	@override String get documentsDirectory => 'Dossier Documents';
	@override String get documentsDirectoryDesc => 'Dossier Documents de l\'app iOS';
	@override String get requiresStoragePermission => 'Nécessite l\'autorisation de stockage pour y accéder';
	@override String get recommendedPaths => 'Chemins recommandés';
	@override String get externalAppPrivateDirectory => 'Dossier privé de l\'app (externe)';
	@override String get externalAppPrivateDirectoryDesc => 'Dossier privé de l\'app sur le stockage externe, accessible à l\'utilisateur, plus d\'espace';
	@override String get internalAppPrivateDirectory => 'Dossier privé de l\'app (interne)';
	@override String get internalAppPrivateDirectoryDesc => 'Stockage interne de l\'app, aucune autorisation requise, moins d\'espace';
	@override String get appDocumentsDirectory => 'Dossier de documents de l\'app';
	@override String get appDocumentsDirectoryDesc => 'Dossier de documents propre à l\'app, sûr et fiable';
	@override String get downloadsFolder => 'Dossier Téléchargements';
	@override String get downloadsFolderDesc => 'Dossier de téléchargement par défaut du système';
	@override String get selectRecommendedDownloadLocation => 'Sélectionner un emplacement de téléchargement recommandé';
	@override String get noRecommendedPaths => 'Aucun chemin recommandé disponible';
	@override String get recommended => 'Recommandé';
	@override String get requiresPermission => 'Autorisation requise';
	@override String get authorizeAndSelect => 'Autoriser et sélectionner';
	@override String get select => 'Sélectionner';
	@override String get permissionAuthorizationFailed => 'Échec de l\'autorisation, impossible de sélectionner ce chemin';
	@override String get pathValidationFailed => 'Échec de la validation du chemin';
	@override String get downloadPathSetTo => 'Chemin de téléchargement défini sur';
	@override String get setPathFailed => 'Échec de la définition du chemin';
	@override String get variableTitle => 'Titre';
	@override String get variableAuthorcache => 'Premier nom vu de l\'auteur (stable malgré les renommages)';
	@override String get variableAuthor => 'Nom de l\'auteur';
	@override String get variableUsername => 'Nom d\'utilisateur de l\'auteur';
	@override String get variableQuality => 'Qualité de la vidéo';
	@override String get variableFilename => 'Nom de fichier d\'origine';
	@override String get variableId => 'ID du contenu';
	@override String get variableCount => 'Nombre d\'images de la galerie';
	@override String get variableDate => 'Date actuelle (AAAA-MM-JJ)';
	@override String get variableTime => 'Heure actuelle (HH-MM-SS)';
	@override String get variableDatetime => 'Date et heure actuelles (AAAA-MM-JJ_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'Paramètres de téléchargement';
	@override String get downloadSettingsSubtitle => 'Configurer le chemin de téléchargement et les règles de nommage des fichiers';
	@override String get suchAsTitleQuality => 'Par exemple : %title_%quality';
	@override String get suchAsTitleId => 'Par exemple : %title_%id';
	@override String get suchAsTitleFilename => 'Par exemple : %title_%filename';
	@override String get structureSection => 'Structure de sauvegarde et nommage';
	@override String get structureSectionDescription => 'Les fichiers téléchargés sont rangés en sous-dossiers selon le mode choisi ci-dessous. Ne concerne que les nouveaux téléchargements, les fichiers existants restent en place.';
	@override String get structureNoticeTitle => 'Nouveau : classement automatique par auteur';
	@override String get structureNoticeBody => 'Choisissez ci-dessous · ne concerne que les nouveaux téléchargements, les fichiers existants restent en place.';
	@override String get presetFlat => 'À plat';
	@override String get presetFlatDesc => 'Tous les fichiers directement à la racine des téléchargements';
	@override String get presetAuthor => 'Par auteur';
	@override String get presetAuthorBadge => 'Recommandé';
	@override String get presetAuthorDesc => 'Un dossier par auteur · reste stable même si le pseudo change';
	@override String get presetDate => 'Par date';
	@override String get presetDateDesc => 'Regroupé par date de téléchargement';
	@override String get presetCustomActive => 'Actif';
	@override String get structurePreviewLabel => 'Aperçu';
	@override String get structurePreviewNote => 'Les segments colorés sont les niveaux de rangement, ils suivent le mode choisi.';
	@override String get pathTooLongWarning => 'Le chemin relatif dépasse 200 caractères, la sauvegarde peut échouer sur certains appareils';
	@override String get pathTemplateEditorEntry => 'Modèle de chemin personnalisé';
	@override String get pathTemplateEditorEntryDesc => 'Décidez vous-même des dossiers et du nommage des fichiers';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorFr pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorFr._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesFr extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Tendance';
	@override String get favorites => 'Favoris';
	@override String get latest => 'Récents';
	@override String get popularity => 'Popularité';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsFr extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Échec de la requête, code d\'état';
	@override String get connectionTimeout => 'Délai de connexion dépassé, veuillez vérifier votre connexion réseau';
	@override String get sendTimeout => 'Délai d\'envoi de la requête dépassé';
	@override String get receiveTimeout => 'Délai de réception de la réponse dépassé';
	@override String get badCertificate => 'Échec de la vérification du certificat';
	@override String get resourceNotFound => 'Ressource demandée introuvable';
	@override String get accessDenied => 'Accès refusé ; une authentification ou une autorisation peut être requise';
	@override String get serverError => 'Erreur interne du serveur';
	@override String get serviceUnavailable => 'Service temporairement indisponible';
	@override String get requestCancelled => 'Requête annulée';
	@override String get connectionError => 'Erreur de connexion réseau, veuillez vérifier vos paramètres réseau';
	@override String get networkRequestFailed => 'Échec de la requête réseau';
	@override String get searchVideoError => 'Une erreur inconnue est survenue lors de la recherche de vidéos';
	@override String get getPopularVideoError => 'Une erreur inconnue est survenue lors de la récupération des vidéos populaires';
	@override String get getVideoDetailError => 'Une erreur inconnue est survenue lors de la récupération des détails de la vidéo';
	@override String get parseVideoDetailError => 'Une erreur inconnue est survenue lors de la récupération et de l\'analyse des détails de la vidéo';
	@override String get downloadFileError => 'Une erreur inconnue est survenue lors du téléchargement du fichier';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingFr extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Récupération des informations de la vidéo...';
	@override String get cancel => 'Annuler';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesFr extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Vidéo introuvable ou supprimée';
	@override String get unableToGetVideoPlayLink => 'Impossible d\'obtenir le lien de lecture de la vidéo';
	@override String get getVideoDetailFailed => 'Échec de la récupération des détails de la vidéo';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoFr extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Infos de la vidéo';
	@override String get currentQuality => 'Qualité actuelle';
	@override String get duration => 'Durée';
	@override String get resolution => 'Résolution';
	@override String get fileInfo => 'Infos du fichier';
	@override String get fileName => 'Nom du fichier';
	@override String get fileSize => 'Taille du fichier';
	@override String get filePath => 'Chemin du fichier';
	@override String get copyPath => 'Copier le chemin';
	@override String get openFolder => 'Ouvrir le dossier';
	@override String get pathCopiedToClipboard => 'Chemin copié dans le presse-papiers';
	@override String get openFolderFailed => 'Échec de l\'ouverture du dossier';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideFr extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Vidéo d\'exemple';
	@override String get title => 'Guide des gestes et interactions';
	@override String get viewGuide => 'Guide des gestes et interactions';
	@override String get firstTimeIntro => 'Prenez quelques secondes pour découvrir les gestes du lecteur. Vous pouvez rouvrir ce guide à tout moment depuis les paramètres du lecteur.';
	@override String get startWatching => 'Compris, commencer à regarder';
	@override String get basicTitle => 'Commandes de base';
	@override String get zoomTitle => 'Zoom / Rotation / Déplacement';
	@override String get restoreTip => 'Touchez le bouton « Restaurer » en bas à droite pour réinitialiser le zoom, la rotation et la position.';
	@override String get mTap => 'Appui simple : afficher / masquer les contrôles';
	@override String get mDoubleTap => 'Double tap : reculer (gauche) / pause (centre) / avance rapide (droite)';
	@override String get mHorizontalDrag => 'Balayage horizontal : naviguer';
	@override String get mVerticalDrag => 'Balayage vertical : luminosité (gauche) / volume (droite)';
	@override String get mLongPress => 'Appui long : accélération temporaire';
	@override String get mPinch => 'Pincement à deux doigts : zoomer l\'image';
	@override String get mRotate => 'Rotation à deux doigts : pivoter l\'image';
	@override String get dTap => 'Clic : afficher / masquer les contrôles';
	@override String get dDoubleTap => 'Double clic : reculer (gauche) / pause (centre) / avance rapide (droite)';
	@override String get dKeys => 'Touches de navigation : appuyez pour reculer/avancer, maintenez pour accélérer ; touches de vitesse : ajustent la vitesse en lecture normale ; Espace : lecture / pause';
	@override String get dTrackpadPinch => 'Pincement sur pavé tactile : zoomer l\'image';
	@override String get dTrackpadRotate => 'Rotation sur pavé tactile : pivoter l\'image';
	@override String get dCtrlWheel => 'Ctrl + molette : zoom autour du curseur';
	@override String get dShiftWheel => 'Maj + molette : rotation autour du curseur';
	@override late final _TranslationsVideoDetailGestureGuideQuestFr quest = _TranslationsVideoDetailGestureGuideQuestFr._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerFr extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Erreur lors du chargement de la source vidéo';
	@override String get errorWhileSettingUpListeners => 'Erreur lors de la configuration des écouteurs';
	@override String get serverFaultDetectedAutoSwitched => 'Défaillance du serveur détectée, itinéraire changé automatiquement et nouvelle tentative en cours';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonFr extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Récupération des informations de la vidéo...';
	@override String get fetchingVideoSources => 'Récupération des sources vidéo...';
	@override String get loadingVideo => 'Chargement de la vidéo...';
	@override String get applyingSolution => 'Application de la solution...';
	@override String get addingListeners => 'Ajout des écouteurs...';
	@override String get successFecthVideoDurationInfo => 'Durée de la vidéo récupérée, démarrage du chargement de la vidéo...';
	@override String get successFecthVideoHeightInfo => 'Chargement terminé';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastFr extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Diffuser';
	@override String unableToStartCastingSearch({required Object error}) => 'Échec du lancement de la recherche de diffusion : ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Démarrer la diffusion vers ${deviceName}';
	@override String castFailed({required Object error}) => 'Échec de la diffusion : ${error}\nVeuillez relancer la recherche d\'appareils ou changer de réseau';
	@override String get castStopped => 'Diffusion arrêtée';
	@override late final _TranslationsVideoDetailCastDeviceTypesFr deviceTypes = _TranslationsVideoDetailCastDeviceTypesFr._(_root);
	@override String get currentPlatformNotSupported => 'La plateforme actuelle ne prend pas en charge la diffusion';
	@override String get unableToGetVideoUrl => 'Impossible d\'obtenir l\'URL de la vidéo, veuillez réessayer plus tard';
	@override String get stopCasting => 'Arrêter la diffusion';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetFr dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetFr._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsFr extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Qui aime en secret';
	@override String get dialogDescription => 'Curieux de savoir qui ils sont ? Feuilletez cet « album de J\'aime »~';
	@override String get closeTooltip => 'Fermer';
	@override String get retry => 'Réessayer';
	@override String get noLikesYet => 'Personne n\'est encore apparu ici. Soyez le premier !';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Page ${page} / ${totalPages} · ${totalCount} personnes au total';
	@override String get prevPage => 'Page précédente';
	@override String get nextPage => 'Page suivante';
}

// Path: forum.sitewide
class _TranslationsForumSitewideFr extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get badge => 'Tout le site';
	@override String get title => 'Annonce à l\'échelle du site';
	@override String get readMore => 'Lire la suite';
}

// Path: forum.errors
class _TranslationsForumErrorsFr extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Veuillez choisir une catégorie';
	@override String get threadLocked => 'Ce sujet est verrouillé, impossible de répondre';
}

// Path: forum.groups
class _TranslationsForumGroupsFr extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Administration';
	@override String get global => 'Global';
	@override String get chinese => 'Chinois';
	@override String get japanese => 'Japonais';
	@override String get korean => 'Coréen';
	@override String get other => 'Autre';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesFr extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Annonces';
	@override String get feedback => 'Avis';
	@override String get support => 'Assistance';
	@override String get general => 'Général';
	@override String get guides => 'Guides';
	@override String get questions => 'Questions';
	@override String get requests => 'Demandes';
	@override String get sharing => 'Partage';
	@override String get general_zh => 'Général';
	@override String get questions_zh => 'Questions';
	@override String get requests_zh => 'Demandes';
	@override String get support_zh => 'Assistance';
	@override String get general_ja => 'Général';
	@override String get questions_ja => 'Questions';
	@override String get requests_ja => 'Demandes';
	@override String get support_ja => 'Assistance';
	@override String get korean => 'Coréen';
	@override String get other => 'Autre';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsFr extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Notifications et annonces officielles importantes';
	@override String get feedback => 'Avis sur les fonctionnalités et services du site';
	@override String get support => 'Aidez à résoudre les problèmes liés au site';
	@override String get general => 'Discutez de tout sujet';
	@override String get guides => 'Partagez vos expériences et tutoriels';
	@override String get questions => 'Posez vos questions';
	@override String get requests => 'Publiez vos demandes';
	@override String get sharing => 'Partagez du contenu intéressant';
	@override String get general_zh => 'Discutez de tout sujet';
	@override String get questions_zh => 'Posez vos questions';
	@override String get requests_zh => 'Publiez vos demandes';
	@override String get support_zh => 'Aidez à résoudre les problèmes liés au site';
	@override String get general_ja => 'Discutez de tout sujet';
	@override String get questions_ja => 'Posez vos questions';
	@override String get requests_ja => 'Publiez vos demandes';
	@override String get support_ja => 'Aidez à résoudre les problèmes liés au site';
	@override String get korean => 'Discussions liées au coréen';
	@override String get other => 'Autres contenus non classés';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsFr extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Type de notification non pris en charge';
	@override String get unknownUser => 'Utilisateur inconnu';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Type de notification non pris en charge : ${type}';
	@override String get unknownNotificationType => 'Type de notification inconnu';
}

// Path: conversation.errors
class _TranslationsConversationErrorsFr extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Veuillez choisir un utilisateur';
	@override String get pleaseEnterATitle => 'Veuillez saisir un titre';
	@override String get clickToSelectAUser => 'Cliquez pour choisir un utilisateur';
	@override String get loadFailedClickToRetry => 'Échec du chargement, cliquez pour réessayer';
	@override String get loadFailed => 'Échec du chargement';
	@override String get clickToRetry => 'Cliquez pour réessayer';
	@override String get noMoreConversations => 'Plus de conversations';
}

// Path: splash.errors
class _TranslationsSplashErrorsFr extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Échec de l\'initialisation, veuillez redémarrer l\'app';
}

// Path: download.errors
class _TranslationsDownloadErrorsFr extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'Modèle d\'image introuvable';
	@override String get downloadFailed => 'Échec du téléchargement';
	@override String get videoInfoNotFound => 'Infos de la vidéo introuvables';
	@override String get downloadTaskAlreadyExists => 'La tâche de téléchargement existe déjà';
	@override String get downloadTaskSavePathConflict => 'Le chemin d\'enregistrement est déjà utilisé par une autre tâche';
	@override String get videoAlreadyDownloaded => 'Vidéo déjà téléchargée';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'Échec de l\'ajout de la tâche de téléchargement : ${errorInfo}';
	@override String get userPausedDownload => 'L\'utilisateur a mis en pause le téléchargement';
	@override String get unknown => 'Inconnu';
	@override String fileSystemError({required Object errorInfo}) => 'Erreur du système de fichiers : ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Erreur inconnue : ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'Échec de l\'écriture du fichier : ${errorInfo}';
	@override String get connectionTimeout => 'Délai de connexion dépassé';
	@override String get sendTimeout => 'Délai d\'envoi dépassé';
	@override String get receiveTimeout => 'Délai de réception dépassé';
	@override String serverError({required Object errorInfo}) => 'Erreur du serveur : ${errorInfo}';
	@override String get unknownNetworkError => 'Erreur réseau inconnue';
	@override String get sslHandshakeFailed => 'Échec de la poignée de main SSL, vérifiez votre réseau';
	@override String get connectionFailed => 'Échec de la connexion, vérifiez votre réseau';
	@override String get serviceIsClosing => 'Le service de téléchargement se ferme';
	@override String get partialDownloadFailed => 'Échec du téléchargement partiel du contenu';
	@override String get noDownloadTask => 'Aucune tâche de téléchargement';
	@override String get taskNotFoundOrDataError => 'Tâche introuvable ou données erronées';
	@override String get fileNotFound => 'Fichier introuvable';
	@override String get openFolderFailed => 'Échec de l\'ouverture du dossier';
	@override String get copyDownloadUrlFailed => 'Échec de la copie de l\'URL de téléchargement';
	@override String openFolderFailedWithMessage({required Object message}) => 'Échec de l\'ouverture du dossier : ${message}';
	@override String get directoryNotFound => 'Répertoire introuvable';
	@override String get copyFailed => 'Échec de la copie';
	@override String get openFileFailed => 'Échec de l\'ouverture du fichier';
	@override String openFileFailedWithMessage({required Object message}) => 'Échec de l\'ouverture du fichier : ${message}';
	@override String get playLocallyFailed => 'Échec de la lecture locale';
	@override String playLocallyFailedWithMessage({required Object message}) => 'Échec de la lecture locale : ${message}';
	@override String get noDownloadSource => 'Aucune source de téléchargement';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'Aucune source de téléchargement, attendez la fin du chargement des informations et réessayez';
	@override String get noActiveDownloadTask => 'Aucune tâche de téléchargement active';
	@override String get noFailedDownloadTask => 'Aucune tâche de téléchargement échouée';
	@override String get noCompletedDownloadTask => 'Aucune tâche de téléchargement terminée';
	@override String get taskAlreadyCompletedDoNotAdd => 'Tâche déjà terminée, ne pas ajouter à nouveau';
	@override String get linkExpiredTryAgain => 'Lien expiré, tentative d\'obtention d\'un nouveau lien de téléchargement';
	@override String get linkExpiredTryAgainSuccess => 'Lien expiré, nouveau lien de téléchargement obtenu';
	@override String get linkExpiredTryAgainFailed => 'Lien expiré, échec de l\'obtention d\'un nouveau lien de téléchargement';
	@override String get taskDeleted => 'Tâche supprimée';
	@override String unsupportedImageFormat({required Object format}) => 'Format d\'image non pris en charge : ${format}';
	@override String get deleteFileError => 'Échec de la suppression du fichier, peut-être parce qu\'il est utilisé par un autre processus';
	@override String get deleteTaskError => 'Échec de la suppression de la tâche';
	@override String get canNotRefreshVideoTask => 'Échec de l\'actualisation de la tâche vidéo';
	@override String get videoRemovedCanNotRefresh => 'Cette vidéo a été supprimée ou n\'existe plus, le lien de téléchargement ne peut donc pas être actualisé';
	@override String get videoInaccessibleCanNotRefresh => 'Cette vidéo n\'est pas accessible ; elle est peut-être privée ou vous devez vous reconnecter';
	@override String get videoQualityGone => 'Cette qualité n\'est plus proposée, veuillez rajouter le téléchargement';
	@override String get refreshLinkNetworkFailed => 'Erreur réseau, le lien de téléchargement ne peut pas être actualisé pour l\'instant, veuillez réessayer plus tard';
	@override String get taskAlreadyProcessing => 'Tâche déjà en cours de traitement';
	@override String get taskNotFound => 'Tâche introuvable';
	@override String get failedToLoadTasks => 'Échec du chargement des tâches';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'Échec du téléchargement partiel : ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Format d\'image non pris en charge : ${extension}, vous pouvez essayer de le télécharger sur votre appareil pour le consulter';
	@override String get imageLoadFailed => 'Échec du chargement de l\'image';
	@override String get pleaseTryOtherViewer => 'Essayez d\'ouvrir avec d\'autres visionneuses';
}

// Path: download.timeline
class _TranslationsDownloadTimelineFr extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get today => 'Aujourd\'hui';
	@override String get yesterday => 'Hier';
	@override String get thisWeek => 'Cette semaine';
	@override String get thisMonth => 'Ce mois-ci';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesFr extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get network => 'Problème réseau, réessayer peut aider';
	@override String get serverRejected => 'Rejeté par le serveur, vous devrez peut-être vous reconnecter';
	@override String get notFound => 'La ressource a disparu ou a été supprimée';
	@override String get diskFull => 'Espace de stockage insuffisant';
	@override String get fileInUse => 'Le fichier est utilisé par un autre programme';
	@override String get permission => 'Aucune permission d\'écriture';
	@override String get cancelled => 'Annulé';
	@override String get unknown => 'Erreur inconnue';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedFr extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '${num} tâches inachevées de la dernière session ont été mises en pause';
	@override String get resume => 'Tout reprendre';
	@override String get dismiss => 'Ignorer';
}

// Path: download.actions
class _TranslationsDownloadActionsFr extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeFr extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateFr extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Supprimer par date';
	@override String get dialogTitle => 'Supprimer par date';
	@override String get description => 'Supprimez en masse les tâches de téléchargement par date de création. Les tâches dont les fichiers sont utilisés sont ignorées ; celles dont les fichiers n\'existent plus sont nettoyées.';
	@override String get modeRange => 'Plage de dates';
	@override String get modeDays => 'Plus ancien que';
	@override String get startDate => 'Date de début';
	@override String get endDate => 'Date de fin';
	@override String get notSet => 'Non défini';
	@override String get daysUnit => 'jours';
	@override String olderThanDaysHint({required Object days}) => 'Supprimer les tâches créées il y a plus de ${days} jour(s)';
	@override String get noMatch => 'Aucune tâche ne correspond à la condition sélectionnée';
	@override String get invalidRange => 'La date de début doit être antérieure ou égale à la date de fin';
	@override String get confirmTitle => 'Confirmer la suppression';
	@override String confirmContent({required Object count}) => 'Supprimer ${count} tâche(s) de téléchargement et leurs fichiers ? Cette action est irréversible.';
	@override String deleting({required Object done, required Object total}) => 'Suppression ${done}/${total}…';
	@override String resultSuccess({required Object count}) => '${count} tâche(s) supprimée(s)';
	@override String resultPartial({required Object deleted, required Object skipped}) => '${deleted} tâche(s) supprimée(s) ; ${skipped} ignorée(s) (en cours d\'utilisation)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationFr extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryFr extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Gérer les catégories';
	@override String get label => 'Catégories';
	@override String get uncategorized => 'Sans catégorie';
	@override String get manage => 'Gérer';
	@override String get createShortcut => 'Nouveau';
	@override String get newCategoryHint => 'Nom de la nouvelle catégorie';
	@override String get createSuccess => 'Catégorie créée';
	@override String get createFailed => 'Échec de la création de la catégorie';
	@override String get nameEmpty => 'Le nom de la catégorie ne peut pas être vide';
	@override String get emptyHint => 'Aucune catégorie pour l\'instant. Créez-en une pour organiser vos téléchargements.';
	@override String get moveTo => 'Déplacer vers une catégorie';
	@override String moveToWithCount({required Object count}) => 'Déplacer ${count} élément(s) vers…';
	@override String moveSuccess({required Object title}) => 'Déplacé vers ${title}';
	@override String get moveToUncategorizedSuccess => 'Déplacé vers Sans catégorie';
	@override String get moveFailed => 'Échec du déplacement';
	@override String get renameTitle => 'Renommer la catégorie';
	@override String get renameHint => 'Saisissez le nom de la catégorie';
	@override String get renameSuccess => 'Catégorie renommée';
	@override String get renameFailed => 'Échec du renommage de la catégorie';
	@override String get deleteTitle => 'Supprimer la catégorie';
	@override String deleteConfirm({required Object title, required Object count}) => 'Supprimer la catégorie « ${title} » ? Les ${count} éléments qu\'elle contient passent dans Sans catégorie. Aucun fichier n\'est supprimé.';
	@override String get deleteSuccess => 'Catégorie supprimée';
	@override String get deleteFailed => 'Échec de la suppression de la catégorie';
}

// Path: download.location
class _TranslationsDownloadLocationFr extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadFr extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Téléchargement par lots';
	@override String get downloadTaskAlreadyRunning => 'Une tâche est déjà en cours, veuillez patienter.';
	@override String get userCancelled => 'Annulé par l\'utilisateur';
	@override String get failedToGetVideoInfo => 'Impossible d\'obtenir les informations de la vidéo';
	@override String get failedToGetVideoSource => 'Impossible d\'obtenir la source vidéo';
	@override String get failedToGetGalleryInfo => 'Impossible d\'obtenir les informations de la galerie';
	@override String get galleryNoImages => 'La galerie ne contient aucune image';
	@override String get failedToGetSavePath => 'Impossible d\'obtenir le chemin d\'enregistrement';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Échec du téléchargement par lots : ${exception}';
	@override String get selectQuality => 'Choisir la qualité';
	@override String get downloading => 'Téléchargement';
	@override String get downloadResult => 'Résultat du téléchargement';
	@override String selectedVideosCount({required Object count}) => '${count} vidéo(s) sélectionnée(s)';
	@override String selectedGalleriesCount({required Object count}) => '${count} galerie(s) sélectionnée(s)';
	@override String get qualityNote => 'Si la qualité sélectionnée n\'est pas disponible, la meilleure qualité disponible sera utilisée';
	@override String progress({required Object current, required Object total}) => 'Traitement ${current}/${total}';
	@override String get queued => 'En file d\'attente';
	@override String get success => 'Réussi';
	@override String get skipped => 'Ignoré';
	@override String get failed => 'Échec';
	@override String get failureDetails => 'Détails de l\'échec';
	@override String get reasonPrivateVideo => 'Vidéo privée';
	@override String get reasonAlreadyExists => 'Existe déjà';
	@override String get reasonNoSource => 'Aucune source de téléchargement';
	@override String get reasonNoSavePath => 'Impossible d\'obtenir le chemin d\'enregistrement';
	@override String get reasonOther => 'Autre erreur';
	@override String get startDownload => 'Démarrer le téléchargement';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsFr extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'Échec de l\'ajout';
	@override String get addSuccess => 'Ajout réussi';
	@override String get deleteFolderFailed => 'Échec de la suppression du dossier';
	@override String get deleteFolderSuccess => 'Dossier supprimé';
	@override String get folderNameCannotBeEmpty => 'Le nom du dossier ne peut pas être vide';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesFr extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI Reasoning (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude Reasoning (réflexion étendue)';
	@override String get gemini => 'Google Gemini (natif)';
	@override String get geminiReasoning => 'Google Gemini Reasoning (réflexion)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek Reasoning (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeFr extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Avis de lecture : ${message}';
	@override String get networkUnstable => 'Vérifiez votre réseau ; la lecture peut saccader';
	@override String get audioTrackUnavailable => 'Aucun son disponible ; la vidéo continue';
	@override String get hardwareDecodeFellBack => 'Passage au décodage logiciel ; consommation d\'énergie accrue possible';
	@override String get videoDecodeProblem => 'Essayez une autre qualité ; l\'image peut présenter des artefacts';
	@override String get repeatedPlaybackProblems => 'Exportez les journaux pour signaler des problèmes de lecture répétés';
	@override String get issuesSheetTitle => 'Problèmes de lecture';
	@override String issueOccurrences({required Object count}) => 'Survenu ${count} fois';
	@override String issueAtPosition({required Object position}) => 'À ${position}';
	@override String get noIssuesRecorded => 'Aucun problème enregistré';
	@override String get exportLogsAction => 'Exporter les journaux';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertFr extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Échecs de vidage';
	@override String get sinkDegradedTitle => 'Écriture des journaux dégradée';
	@override String get sinkDegradedDetail => 'Le récepteur de fichier est en état dégradé';
	@override String get queueBacklogTitle => 'File d\'attente d\'écriture saturée';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (seuil=${threshold}, peut augmenter l\'utilisation de la mémoire)';
	@override String get highFlushLatencyTitle => 'Latence de vidage élevée';
	@override String get droppedTooManyTitle => 'Trop de journaux abandonnés';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (seuil=${threshold})';
	@override String get rateLimitedTitle => 'Limitation de débit déclenchée';
	@override String get exportFailedTitle => 'Échecs d\'export des journaux';
	@override String get fileNearLimitTitle => 'Fichier de journal proche de la limite de taille';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (pression de rotation des E/S plus élevée)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastFr extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'Le service de journalisation n\'est pas initialisé';
	@override String get exportSuccess => 'Journaux exportés. Vérifiez les données privées avant de les envoyer par e-mail.';
	@override String exportFailed({required Object error}) => 'Échec de l\'export : ${error}';
	@override String get supportEmailCopied => 'E-mail d\'assistance copié. Collez-le dans votre client de messagerie et joignez les journaux.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesFr extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'Pertinence';
	@override String get latest => 'Récents';
	@override String get views => 'Vues';
	@override String get likes => 'J\'aime';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeFr extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bienvenue';
	@override String get subtitle => 'Commençons votre configuration personnalisée';
	@override String get description => 'Quelques étapes suffisent pour adapter la meilleure expérience pour vous';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicFr extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages de base';
	@override String get subtitle => 'Personnalisez votre expérience';
	@override String get description => 'Choisissez les préférences qui vous conviennent';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkFr extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres réseau';
	@override String get subtitle => 'Configurez les options réseau';
	@override String get description => 'Ajustez selon votre environnement réseau';
	@override String get tip => 'Un redémarrage est nécessaire après une configuration réussie pour qu\'elle prenne effet';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeFr extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages du thème';
	@override String get subtitle => 'Choisissez l\'apparence que vous préférez';
	@override String get description => 'Personnalisez votre expérience visuelle';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerFr extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Réglages du lecteur';
	@override String get subtitle => 'Configurez les commandes de lecture';
	@override String get description => 'Réglez rapidement les préférences de lecture courantes';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialFr extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lecture spatiale';
	@override String get subtitle => 'Regarder et naviguer sur le casque';
	@override String get description => 'Sur le casque, les vidéos et galeries apparaissent dans l\'espace autour de vous plutôt qu\'à l\'intérieur de ce panneau flottant';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionFr extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Terminer la configuration';
	@override String get subtitle => 'Vous êtes prêt à commencer l\'aventure';
	@override String get description => 'Veuillez lire et accepter les contrats associés';
	@override String get agreementTitle => 'Contrat d\'utilisation et règles de la communauté';
	@override String get agreementDesc => 'Avant d\'utiliser cette application, veuillez lire attentivement et accepter notre contrat d\'utilisation et les règles de la communauté. Ces conditions aident à maintenir un bon environnement.';
	@override String get checkboxTitle => 'J\'ai lu et j\'accepte le contrat d\'utilisation et les règles de la communauté';
	@override String get checkboxSubtitle => 'Vous ne pouvez pas utiliser l\'application si vous refusez';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonFr extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Ces réglages peuvent être modifiés à tout moment dans Réglages';
	@override String get previousStep => 'Étape précédente';
	@override String get nextStep => 'Étape suivante';
	@override String get finishSetup => 'Terminer la configuration';
	@override String get agreeAgreementSnackbar => 'Veuillez d\'abord accepter le contrat d\'utilisation et les règles de la communauté';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsFr extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Haute qualité';
	@override String get fast => 'Rapide';
	@override String get lite => 'Léger';
	@override String get moreLite => 'Très léger';
	@override String get custom => 'Personnalisé';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsFr extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Adapté à la plupart des animations 1080p, en particulier celles présentant du flou, du rééchantillonnage et des artefacts de compression. Offre la meilleure qualité perçue.';
	@override String get mode_b_hq => 'Adapté aux animations présentant un léger flou ou des halos dus à la mise à l\'échelle. Réduit efficacement les halos et l\'aliasing.';
	@override String get mode_c_hq => 'Adapté aux sources de haute qualité (animations ou films 1080p natifs, par exemple). Débruite et offre le meilleur PSNR.';
	@override String get mode_a_a_hq => 'Version améliorée du mode A, offrant une qualité perçue optimale et reconstruisant presque toutes les lignes dégradées. Peut produire un excès de netteté ou des halos.';
	@override String get mode_b_b_hq => 'Version améliorée du mode B, offrant une meilleure qualité perçue, optimisant davantage les lignes et réduisant les artefacts.';
	@override String get mode_c_a_hq => 'Version du mode C à qualité perçue améliorée, conservant un PSNR élevé tout en tentant de reconstruire certains détails de lignes.';
	@override String get mode_a_fast => 'Version rapide du mode A, équilibrant qualité et performances, adaptée à la plupart des animations 1080p.';
	@override String get mode_b_fast => 'Version rapide du mode B, pour traiter les légers artefacts et halos avec un coût réduit.';
	@override String get mode_c_fast => 'Version rapide du mode C, pour un débruitage et une mise à l\'échelle rapides des sources de haute qualité.';
	@override String get mode_a_a_fast => 'Version rapide du mode A+A, visant une meilleure qualité perçue sur les appareils peu puissants.';
	@override String get mode_b_b_fast => 'Version rapide du mode B+B, offrant une meilleure réparation des lignes et un traitement des artefacts sur les appareils peu puissants.';
	@override String get mode_c_a_fast => 'Version rapide du mode C+A, traitant rapidement les sources de haute qualité tout en offrant une légère réparation des lignes.';
	@override String get upscale_only_s => 'Mise à l\'échelle x2 ultra-rapide via le modèle CNN le plus rapide uniquement, sans réparation ni débruitage, coût minimal.';
	@override String get upscale_deblur_fast => 'Mise à l\'échelle et défloutage rapides via des algorithmes classiques non CNN, meilleurs que ceux du lecteur par défaut avec un coût très faible.';
	@override String get restore_s_only => 'Réparation uniquement via le modèle CNN le plus rapide, sans mise à l\'échelle. Adapté à la lecture en résolution native lorsque vous voulez améliorer la qualité.';
	@override String get denoise_bilateral_fast => 'Débruitage rapide par filtrage bilatéral classique, très rapide, adapté au bruit léger.';
	@override String get upscale_non_cnn => 'Mise à l\'échelle rapide via des algorithmes classiques, coût très faible, meilleure que les réglages par défaut du lecteur.';
	@override String get mode_a_fast_darken => 'Mode A (rapide) + assombrissement des lignes, ajoutant un effet d\'assombrissement au mode A rapide pour des lignes plus marquées et stylisées.';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + affinage des lignes, ajoutant un effet d\'affinage au mode A haute qualité pour un rendu plus fin.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesFr extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'Mise à l\'échelle CNN (ultra rapide)';
	@override String get upscale_deblur_fast => 'Mise à l\'échelle et défloutage (rapide)';
	@override String get restore_s_only => 'Restauration (ultra rapide)';
	@override String get denoise_bilateral_fast => 'Débruitage bilatéral (ultra rapide)';
	@override String get upscale_non_cnn => 'Mise à l\'échelle non CNN (ultra rapide)';
	@override String get mode_a_fast_darken => 'Mode A (rapide) + assombrissement des lignes';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + affinage des lignes';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseFr extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Accès rapide';
	@override String get sourcesSection => 'Dossiers';
	@override String get pin => 'Ajouter à l\'accès rapide';
	@override String get unpin => 'Retirer de l\'accès rapide';
	@override String get pinned => 'Ajouté à l\'accès rapide';
	@override String get unpinned => 'Retiré de l\'accès rapide';
	@override String folderCount({required Object count}) => '${count} dossiers';
	@override String videoCount({required Object count}) => '${count} vidéos';
	@override String imageCount({required Object count}) => '${count} image(s)';
	@override String get emptyFolder => 'Ce dossier est vide';
	@override String get videosSection => 'Vidéos';
	@override String get imagesSection => 'Images';
	@override String get galleriesSection => 'Galeries';
	@override String get filterAll => 'Tout';
	@override String get searchInFolder => 'Rechercher dans ce dossier';
	@override String get searchHint => 'Rechercher par nom';
	@override String get clearSearch => 'Effacer la recherche';
	@override String searchNoResult({required Object query}) => 'Aucun résultat pour « ${query} »';
	@override String viewAllFolders({required Object count}) => 'Voir les ${count} dossiers';
	@override String viewAllVideos({required Object count}) => 'Voir les ${count} vidéos';
	@override String viewAllImages({required Object count}) => 'Voir les ${count} images';
	@override String viewAllGalleries({required Object count}) => 'Voir les ${count} galeries';
	@override String get location => 'Emplacement';
	@override String get sourceMissing => 'Cette source a disparu';
	@override String get notScannedYet => 'Ce dossier n\'a pas encore été analysé';
	@override String get scanning => 'Lecture de ce dossier…';
	@override String get deleteFileTitle => 'Supprimer ce fichier ?';
	@override String deleteFileBody({required Object name}) => '« ${name} » sera définitivement supprimé de cet appareil. Cette action est irréversible.';
	@override String get hideFolder => 'Masquer ce dossier';
	@override String get unhideFolder => 'Afficher de nouveau';
	@override String get showHiddenFolders => 'Afficher les dossiers masqués';
	@override String get includeDotFolders => 'Analyser les dossiers commençant par .';
	@override String get dotFoldersIncluded => 'Les dossiers commençant par . sont maintenant analysés';
	@override String get dotFoldersExcluded => 'Les dossiers commençant par . ne sont plus analysés';
	@override String get showDotFolders => 'Afficher les dossiers commençant par .';
	@override String dotFoldersSkipped({required Object count}) => '${count} dossiers commençant par . ne sont pas analysés ici';
	@override String get scanDotFoldersAction => 'Activer pour cette source';
	@override String get otherAppsPrivateNotice => 'Depuis Android 11, aucune application ne peut lire les fichiers des autres applications dans Android/data ou Android/obb, et cette application ne peut pas le contourner. Téléchargez ou exportez les vidéos vers un dossier public comme Download dans l\'application d\'origine, puis ajoutez ce dossier ici. Les caches de lecture sont généralement fragmentés et illisibles même s\'ils sont accessibles.';
	@override String get folderHidden => 'Masqué ; l’analyse l’ignorera aussi';
	@override String get folderUnhidden => 'N’est plus masqué';
	@override String get hiddenFolderBadge => 'Masqué';
	@override String get deleteFolder => 'Supprimer le dossier';
	@override String get deleteFolderTitle => 'Supprimer ce dossier ?';
	@override String deleteFolderBody({required Object name}) => '« ${name} » et tout son contenu seront définitivement supprimés de cet appareil. Cette action est irréversible.';
	@override String get deleteFolderIncludesOthers => 'Les autres fichiers qu’il contient seront aussi supprimés';
	@override String get folderDeleted => 'Dossier supprimé';
	@override String get deleteFolderFailed => 'Échec de la suppression : permission refusée ou fichier en cours d’utilisation';
	@override String get deleteGalleryTitle => 'Supprimer cette galerie ?';
	@override String deleteGalleryBody({required Object name}) => 'L\'enregistrement de téléchargement et les fichiers image locaux de « ${name} » seront supprimés. Cette action est irréversible.';
	@override String get galleryResourceMissing => 'Les fichiers locaux n\'existent plus. Enregistrement nettoyé.';
	@override String get viewDownloadDetail => 'Voir les détails du téléchargement';
	@override String get viewOnlineGallery => 'Voir sur le site web';
	@override String get pickFolderTitle => 'Choisir un dossier';
	@override String get useThisFolder => 'Utiliser ce dossier';
	@override String get noSubfolders => 'Aucun sous-dossier ici';
	@override String get storageRoot => 'Stockage de l\'appareil';
	@override String get homeFolder => 'Accueil';
	@override String get filesystemRoot => 'Racine du système de fichiers';
	@override String get folderUnreadable => 'Ce dossier ne peut pas être lu';
	@override String get setCover => 'Définir la couverture';
	@override String get setAsFolderCover => 'Utiliser comme couverture du dossier';
	@override String get folderCoverSet => 'Couverture du dossier mise à jour';
	@override String get setFolderCoverPick => 'Définir la couverture…';
	@override String get restoreAutoCover => 'Rétablir la couverture automatique';
	@override String get autoCoverRestored => 'Couverture automatique rétablie';
	@override String get rescanFolder => 'Réanalyser ce dossier';
	@override String get coverPickerTitle => 'Choisir une image';
	@override String get folderCoverPickerTitle => 'Choisir une couverture';
	@override String get coverPickerEmpty => 'Aucune image disponible dans ce dossier pour l\'instant. Les vignettes des vidéos sont peut-être encore en cours de génération en arrière-plan.';
	@override String get coverSaved => 'Couverture mise à jour';
	@override String get coverSaveFailed => 'Impossible d\'enregistrer la couverture';
	@override String get coverUnavailable => 'Aucune image vidéo n\'a pu être lue depuis ce fichier';
	@override String get deleted => 'Supprimé';
	@override String get deleteFailed => 'Impossible de supprimer — le fichier est peut-être utilisé ou protégé en écriture';
	@override String get openFolder => 'Ouvrir';
	@override String get favorite => 'Ajouter aux favoris';
	@override String get unfavorite => 'Retirer des favoris';
	@override String get favorited => 'Ajouté aux favoris';
	@override String get unfavorited => 'Retiré des favoris';
	@override String get sortBy => 'Trier par';
	@override String get sortAscending => 'Croissant';
	@override String get sortDescending => 'Décroissant';
	@override String get sortFieldName => 'Nom';
	@override String get sortFieldModified => 'Date de modification';
	@override String get sortFieldDuration => 'Durée';
	@override String get sortFieldSize => 'Taille';
	@override String get sortFieldResolution => 'Résolution';
	@override String get sortFieldFileType => 'Type de fichier';
	@override String get sortFieldFps => 'Fréquence d\'images';
	@override String get sortFieldFavorited => 'Date d\'ajout aux favoris';
	@override String get emptyAllVideos => 'Aucune vidéo trouvée pour l\'instant. Ajoutez un dossier dans Dossiers pour commencer.';
	@override String get emptyAllImages => 'Aucune image trouvée pour l\'instant. Ajoutez un dossier dans Dossiers pour commencer.';
	@override String get emptyFavorites => 'Aucun favori pour l\'instant. Ajoutez-en un depuis le menu ⋮ d\'une vidéo.';
	@override String get emptyPinned => 'Aucun dossier épinglé pour l\'instant. Appuyez longuement sur un dossier dans Dossiers et choisissez Épingler.';
	@override String get emptyDownloadedVideos => 'Aucun téléchargement de vidéo terminé pour l\'instant.';
	@override String get emptyDownloadedGalleries => 'Aucun téléchargement de galerie terminé pour l\'instant.';
	@override String get folderInfo => 'Infos du dossier';
	@override String get folderInfoName => 'Nom';
	@override String get folderInfoPath => 'Chemin';
	@override String get folderInfoSource => 'Source';
	@override String get folderInfoContents => 'Contenu';
	@override String get folderInfoSize => 'Taille sur le disque';
	@override String get folderInfoScannedAt => 'Dernière analyse';
	@override String get folderInfoNeverScanned => 'Pas encore analysé';
	@override String get folderInfoNoPath => 'Cette source n\'a aucun dossier à ouvrir';
	@override String get copyPath => 'Copier le chemin';
	@override String get pathCopied => 'Chemin copié';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsFr extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingFr extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavFr extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorFr extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Modèle de chemin';
	@override String get subtitle => 'Range automatiquement les téléchargements en sous-dossiers';
	@override String get tabVideo => 'Vidéo';
	@override String get tabGallery => 'Galerie';
	@override String get tabImage => 'Image unique';
	@override String get previewLabel => 'Aperçu · résultat réel après nettoyage';
	@override String get galleryPreviewLabel => 'Aperçu · le modèle de galerie nomme le dossier (les images internes gardent l\'identifiant de l\'image)';
	@override String get addFolder => 'Ajouter un niveau de dossier';
	@override String get folderCapReached => 'Limite de niveaux de dossier atteinte';
	@override String get folderSegmentHint => '%authorcache, une variable ou du texte fixe';
	@override String get fileSegmentHint => 'ex. %title_%quality';
	@override String videoCapNote({required Object max}) => 'Lextension .mp4 est ajoutée automatiquement · taper / dans un segment le scinde en deux niveaux · jusquà ${max} niveaux';
	@override String imageCapNote({required Object max}) => 'Lextension dorigine est ajoutée automatiquement · taper / dans un segment le scinde en deux niveaux · jusquà ${max} niveaux';
	@override String galleryCapNote({required Object max}) => 'Le modèle de galerie est entièrement des dossiers, jusquà ${max} niveaux · les images internes gardent le nommage par ID';
	@override String get trayHint => 'Touchez pour insérer à la position du curseur · appui long pour les détails';
	@override String get emptySegment => 'Segment vide';
	@override String get emptySegmentSaveBlocked => 'Impossible de sauvegarder : des segments vides subsistent, remplissez-les ou supprimez-les';
	@override String get tooManySegmentsSaveBlocked => 'Impossible de sauvegarder : trop de segments de chemin (4 max). Fusionnez ou supprimez-en';
	@override String get templateInvalidSaveBlocked => 'Impossible de sauvegarder : le modèle contient des caractères non valides';
	@override String get variableInserted => 'Variable insérée';
	@override String get savedToast => 'Enregistré · ne concerne que les nouveaux téléchargements';
	@override String get trayCategoryContent => 'Contenu';
	@override String get trayCategoryAuthor => 'Auteur';
	@override String get trayCategoryTime => 'Temps';
	@override String get chipAuthorcache => 'Nom de lauteur·fixe';
	@override String get chipDate => 'Date';
	@override String get chipTime => 'Heure';
	@override String get chipDatetime => 'Date et heure';
	@override String get chipCount => 'Index';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestFr extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Prendre ses repères dans Quest';
	@override String get intro => 'Découvrez à quoi sert chaque commande, puis essayez-la dans votre espace.';
	@override String get videoTab => 'Vidéo spatiale';
	@override String get galleryTab => 'Galerie spatiale';
	@override String get scopeNote => 'Pour les écrans et fenêtres dans votre espace Quest. Rouvrez à tout moment depuis les paramètres du lecteur.';
	@override String get catalog => 'Découvrir les commandes';
	@override String lessonCount({required Object current, required Object total}) => '${current} sur ${total}';
	@override String get previous => 'Précédent';
	@override String get next => 'Commande suivante';
	@override String get replay => 'Rejouer la démo';
	@override String get pauseDemo => 'Mettre la démo en pause';
	@override String get resumeDemo => 'Reprendre la démo';
	@override String get looping => 'Démo de la commande';
	@override String get still => 'Illustration fixe';
	@override String get done => 'Compris, continuer';
	@override String get leftController => 'Main gauche';
	@override String get rightController => 'Main droite';
	@override String get trigger => 'Gâchette d\'index';
	@override String get grip => 'Bouton de préhension';
	@override String get bothGrips => 'Les deux boutons de préhension';
	@override String get stick => 'Stick';
	@override String get handTracking => 'Suivi des mains';
	@override String get ready => 'Prêt';
	@override String get press => 'Appuyer';
	@override String get hold => 'Maintenir';
	@override String get release => 'Relâcher';
	@override String get result => 'Voir le résultat';
	@override String get pinch => 'Pincer';
	@override String get selectTitle => 'Pointer et sélectionner';
	@override String get selectBody => 'Visez un bouton avec le rayon, puis appuyez et relâchez la gâchette d\'index. Utilisez-la pour la lecture, les réglages et les curseurs du panneau de contrôle.';
	@override String get selectHint => 'La gâchette d\'index se trouve derrière la face du bouton. Le bouton de préhension sur la poignée intérieure saisit les fenêtres.';
	@override String get panelTitle => 'Afficher ou masquer le panneau';
	@override String get panelBody => 'Pointez à l\'extérieur du panneau de contrôle, puis appuyez sur la gâchette d\'index pour l\'afficher ou le masquer. Avec le suivi des mains, un pincement rapide hors du panneau fait la même chose.';
	@override String get panelHint => 'Faites une pression brève sans glisser. Maintenir et déplacer est un glissement, pas un basculement du panneau.';
	@override String get playTitle => 'Lire et mettre en pause';
	@override String get playBody => 'Pointez ailleurs que vers le panneau de contrôle et appuyez sur A à droite ou X à gauche pour lire ou mettre en pause. Vous pouvez aussi sélectionner le bouton de lecture du panneau.';
	@override String get playHint => 'Ce raccourci par défaut peut être désactivé dans les paramètres du lecteur spatial. En pointant vers le panneau, la saisie va au panneau.';
	@override String get seekTitle => 'Se déplacer avec le stick';
	@override String get seekBody => 'Poussez légèrement l\'un ou l\'autre stick vers la gauche ou la droite pour avancer de 5 secondes. Maintenez-le pour défiler plus vite tout en prévisualisant le temps cible. Relâchez pour valider la position.';
	@override String get seekHint => 'Gardez le rayon de cette manette hors du panneau de contrôle. Un stick pointé vers le panneau le fait défiler à la place.';
	@override String get browseTitle => 'Parcourir avec le stick';
	@override String get browseBody => 'Déplacez l\'un ou l\'autre stick vers la gauche ou la droite pour passer à l\'élément précédent ou suivant ; maintenez pour continuer à parcourir. Vous pouvez aussi sélectionner une vignette dans la bande d\'images.';
	@override String get browseHint => 'Les vidéos d\'une galerie sont aussi des éléments. En pointant vers le panneau de contrôle, le stick fait défiler le panneau.';
	@override String get swipeTitle => 'Glisser pour tourner une page';
	@override String get swipeBody => 'Visez l\'image, maintenez la gâchette d\'index et faites glisser vers la gauche. Relâchez après l\'indice de changement de page pour avancer ; faites glisser vers la droite pour revenir. Un pincement-glissement fonctionne aussi.';
	@override String get swipeHint => 'Les images doivent être à 1× pour changer de page en glissant. Les vidéos de galerie le permettent aussi. La scène reste immobile jusqu\'au relâchement.';
	@override String get zoomTitle => 'Zoomer sur l\'image';
	@override String get zoomBody => 'Visez un détail de l\'image, maintenez la gâchette d\'index, puis poussez le stick vers le haut pour zoomer ou vers le bas pour dézoomer. Le zoom est ancré là où vous avez appuyé.';
	@override String get zoomHint => 'Cela agrandit l\'image dans sa fenêtre. Sans maintenir l\'image, le haut/bas ajuste la distance de visionnage.';
	@override String get panTitle => 'Déplacer et restaurer l\'image';
	@override String get panBody => 'Une fois zoomé, maintenez la gâchette d\'index et faites glisser pour regarder autour. Double-touchez l\'image pour zoomer à 2,5× ou la restaurer. Avec les mains, pincez deux fois rapidement.';
	@override String get panHint => 'Faire glisser déplace une image zoomée. Revenez à 1× avant de faire glisser pour tourner les pages.';
	@override String get slideshowTitle => 'Lancer un diaporama';
	@override String get slideshowBody => 'Sur une image, A / X démarre ou met en pause le diaporama. Le panneau propose des intervalles de 3, 5, 10 ou 20 secondes et une qualité d\'image standard ou d\'origine.';
	@override String get slideshowHint => 'Sur une vidéo de galerie, A / X contrôle la lecture de cette vidéo. Le raccourci de la manette doit être activé dans les paramètres.';
	@override String get moveTitle => 'Saisir et déplacer l\'écran';
	@override String get moveBody => 'Maintenez le bouton de préhension sur la poignée intérieure, déplacez le contrôleur pour positionner l\'écran, puis relâchez. Pendant le visionnage, vous pouvez saisir l\'écran sans le viser.';
	@override String get moveHint => 'Viser la fenêtre de l\'app ou le panneau de contrôle saisit d\'abord cette fenêtre. Dans une vidéo panoramique, la préhension ajuste l\'orientation.';
	@override String get scaleTitle => 'Redimensionner avec les deux mains';
	@override String get scaleBody => 'Maintenez les deux boutons de préhension. Écartez les mains pour agrandir l\'écran, ou rapprochez-les pour le réduire. Avec le suivi des mains, maintenez un pincement dans les deux mains.';
	@override String get scaleHint => 'Pour les écrans plats ou courbes, y compris la scène de galerie. Gardez les rayons hors du panneau de contrôle. Cela redimensionne tout l\'écran.';
	@override String get distanceTitle => 'Ajuster la distance de visionnage';
	@override String get distanceBody => 'Poussez le stick vers le haut pour éloigner l\'écran, ou vers le bas pour le rapprocher. Lorsque vous saisissez une fenêtre, le haut/bas déplace cette fenêtre. Réglez le volume sur le panneau.';
	@override String get distanceHint => 'Pointez ailleurs que vers le panneau de contrôle. En maintenant une image, le haut/bas devient un zoom d\'image ; pour les vidéos panoramiques, cela ajuste la vue.';
	@override String get resizeTitle => 'Utiliser les bords et les coins';
	@override String get resizeBody => 'Le cadre s\'illumine lorsque le rayon approche d\'un bord. Maintenez la gâchette ou pincez sur un bord pour déplacer la fenêtre ; faites glisser un coin pour la redimensionner.';
	@override String get resizeHint => 'Fonctionne sur la fenêtre de l\'app, le panneau de contrôle et l\'écran. La fenêtre de l\'app change de largeur et de hauteur ; les écrans conservent leurs proportions.';
	@override String get navigationTitle => 'Revenir en arrière et ouvrir les paramètres';
	@override String get navigationBody => 'B / Y revient d\'un niveau : ferme une fenêtre contextuelle ou revient à l\'accueil du panneau, masque le panneau, puis revient à l\'app. Le bouton Menu gauche ouvre les paramètres spatiaux.';
	@override String get navigationHint => 'Le bouton Meta droit appartient au système. Le recentrage système ramène la vue devant en conservant la taille et la distance de l\'écran.';
	@override String get handsTitle => 'Utiliser vos mains';
	@override String get handsBody => 'Lorsque le suivi des mains est activé, visez un bouton avec le rayon du système, pincez le pouce et l\'index, puis relâchez. Utilisez le panneau pour la lecture, la navigation et les galeries.';
	@override String get handsHint => 'Pincez à l\'extérieur pour afficher ou masquer le panneau. Pincez un bord pour déplacer, un coin pour redimensionner, ou pincez avec les deux mains et écartez pour agrandir l\'écran.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesFr extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Lecteur multimédia';
	@override String get mediaServer => 'Serveur multimédia';
	@override String get internetGatewayDevice => 'Routeur';
	@override String get basicDevice => 'Appareil de base';
	@override String get dimmableLight => 'Éclairage connecté';
	@override String get wlanAccessPoint => 'Point d\'accès WLAN';
	@override String get wlanConnectionDevice => 'Appareil de connexion WLAN';
	@override String get printer => 'Imprimante';
	@override String get scanner => 'Scanner';
	@override String get digitalSecurityCamera => 'Caméra de sécurité numérique';
	@override String get unknownDevice => 'Appareil inconnu';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetFr extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Diffusion à distance';
	@override String get close => 'Fermer';
	@override String get searchingDevices => 'Recherche d\'appareils...';
	@override String get searchPrompt => 'Cliquez sur le bouton de recherche pour relancer la recherche d\'appareils de diffusion';
	@override String get searching => 'Recherche';
	@override String get searchAgain => 'Rechercher à nouveau';
	@override String get noDevicesFound => 'Aucun appareil de diffusion trouvé\nVeuillez vous assurer que les appareils sont sur le même réseau';
	@override String get searchingDevicesPrompt => 'Recherche d\'appareils, veuillez patienter...';
	@override String get cast => 'Diffuser';
	@override String connectedTo({required Object deviceName}) => 'Connecté à : ${deviceName}';
	@override String get notConnected => 'Aucun appareil connecté';
	@override String get stopCasting => 'Arrêter la diffusion';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsFr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Profil',
			'personalProfile.editPersonalProfile' => 'Modifier le profil',
			'personalProfile.avatar' => 'Avatar',
			'personalProfile.background' => 'Arrière-plan',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'Échec de la récupération du profil utilisateur : ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Résolution conseillée : ${resolution}, taille du fichier < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Formats pris en charge : ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Les utilisateurs Premium peuvent utiliser des ${type} dynamiques (${formats})',
			'personalProfile.homepageBackground' => 'Arrière-plan de la page d\'accueil',
			'personalProfile.basicInfo' => 'Informations de base',
			'personalProfile.nickname' => 'Pseudo',
			'personalProfile.username' => 'Nom d\'utilisateur',
			'personalProfile.copyUsername' => 'Copier le nom d\'utilisateur',
			'personalProfile.usernameCopied' => 'Nom d\'utilisateur copié',
			'personalProfile.personalIntroduction' => 'Présentation',
			'personalProfile.noPersonalIntroduction' => 'Aucune présentation',
			'personalProfile.clickToEdit' => 'Cliquez pour modifier',
			'personalProfile.privacySettings' => 'Paramètres de confidentialité',
			'personalProfile.hideSensitiveContent' => 'Masquer le contenu sensible',
			'personalProfile.hideSensitiveContentDesc' => 'Masquer les vidéos ou images comportant des tags sensibles.',
			'personalProfile.notificationSettings' => 'Paramètres de notification',
			'personalProfile.contentCommentNotification' => 'Notification de commentaire sur vos contenus',
			'personalProfile.contentCommentNotificationDesc' => 'Vous notifier lorsque quelqu\'un commente vos contenus.',
			'personalProfile.commentReplyNotification' => 'Notification de réponse aux commentaires',
			'personalProfile.commentReplyNotificationDesc' => 'Vous notifier lorsque quelqu\'un répond à votre commentaire.',
			'personalProfile.mentionNotification' => 'Notification de mention',
			'personalProfile.mentionNotificationDesc' => 'Vous notifier lorsque quelqu\'un vous mentionne dans un contenu.',
			'personalProfile.accountInfo' => 'Infos du compte',
			'personalProfile.registrationTime' => 'Date d\'inscription',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'Échec de la mise à jour des paramètres : ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'Échec de la mise à jour des paramètres de notification : ${error}',
			'personalProfile.editNickname' => 'Modifier le pseudo',
			'personalProfile.nicknameCannotBeEmpty' => 'Le pseudo ne peut pas être vide',
			'personalProfile.changeSuccess' => 'Modification réussie',
			'personalProfile.unsupportedFileFormat' => 'Format de fichier non pris en charge',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'La taille du fichier ne peut pas dépasser ${size}',
			'personalProfile.uploadFailed' => 'Échec de l\'envoi',
			'personalProfile.avatarUpdatedSuccessfully' => 'Avatar mis à jour',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'Échec de la mise à jour de l\'avatar : ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Arrière-plan mis à jour',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'Échec de la mise à jour de l\'arrière-plan : ${error}',
			'personalProfile.editPersonalIntroduction' => 'Modifier la présentation',
			'personalProfile.enterPersonalIntroduction' => 'Veuillez saisir une présentation',
			'tutorial.specialFollowFeature' => 'Abonnement spécial',
			'tutorial.specialFollowDescription' => 'Marquez les auteurs que vous suivez le plus comme abonnements spéciaux, puis accédez directement à leurs dernières publications depuis ici.',
			'tutorial.stepsTitle' => 'Trois étapes',
			'tutorial.stepFollowAuthor' => 'Touchez Suivre sur la vidéo, la galerie ou la page de profil de l\'auteur.',
			'tutorial.stepPickSpecial' => 'Touchez de nouveau Abonné, puis choisissez Abonnement spécial dans le menu.',
			'tutorial.stepSwitchHere' => 'Revenez ici et basculez vers cet auteur avec le sélecteur d\'avatar ci-dessus.',
			'tutorial.specialFollowManagementTip' => 'Gérez la liste des abonnements spéciaux dans Barre latérale - Liste d\'abonnements - Abonnements spéciaux.',
			'tutorial.gotIt' => 'Compris',
			'common.sort' => 'Trier',
			'common.filter' => 'Filtrer',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Annuler',
			'common.select' => 'Sélectionner',
			'common.save' => 'Enregistrer',
			'common.delete' => 'Supprimer',
			'common.visit' => 'Visiter',
			'common.loading' => 'Chargement...',
			'common.scrollToTop' => 'Revenir en haut',
			'common.privacyHint' => 'Le mode privé est activé, le contenu est masqué',
			'common.latest' => 'Récent',
			'common.likesCount' => 'J\'aime',
			'common.viewsCount' => 'Vues',
			'common.popular' => 'Populaire',
			'common.trending' => 'Tendances',
			'common.commentList' => 'Liste des commentaires',
			'common.sendComment' => 'Envoyer le commentaire',
			'common.send' => 'Envoyer',
			'common.retry' => 'Réessayer',
			'common.premium' => 'Premium',
			'common.follower' => 'Abonné',
			'common.friend' => 'Ami',
			'common.video' => 'Vidéo',
			'common.following' => 'Abonnements',
			'common.expand' => 'Développer',
			'common.collapse' => 'Réduire',
			'common.cancelFriendRequest' => 'Annuler la demande',
			'common.cancelSpecialFollow' => 'Annuler l\'abonnement spécial',
			'common.addFriend' => 'Ajouter un ami',
			'common.removeFriend' => 'Retirer l\'ami',
			'common.followed' => 'Abonné',
			'common.follow' => 'Suivre',
			'common.unfollow' => 'Ne plus suivre',
			'common.specialFollow' => 'Abonnement spécial',
			'common.specialFollowed' => 'Abonnement spécial ajouté',
			'common.gallery' => 'Galerie',
			'common.playlist' => 'Liste de lecture',
			'common.commentPostedSuccessfully' => 'Commentaire publié',
			'common.commentPostedFailed' => 'Échec de la publication du commentaire',
			'common.success' => 'Succès',
			'common.commentDeletedSuccessfully' => 'Commentaire supprimé',
			'common.commentUpdatedSuccessfully' => 'Commentaire modifié avec succès',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: '${n} commentaire', other: '${n} commentaires', ), 
			'common.writeYourCommentHere' => 'Écrivez votre commentaire ici...',
			'common.tmpNoReplies' => 'Aucune réponse pour l\'instant',
			'common.loadMore' => 'Charger plus',
			'common.loadingMore' => 'Chargement...',
			'common.noMoreDatas' => 'Plus de données',
			'common.selectTranslationLanguage' => 'Choisir la langue de traduction',
			'common.translate' => 'Traduire',
			'common.translateFailedPleaseTryAgainLater' => 'Échec de la traduction, veuillez réessayer plus tard',
			'common.translationResult' => 'Résultat de la traduction',
			'common.justNow' => 'À l\'instant',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: 'il y a ${n} minute', other: 'il y a ${n} minutes', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: 'il y a ${n} heure', other: 'il y a ${n} heures', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: 'il y a ${n} jour', other: 'il y a ${n} jours', ), 
			'common.editedAt' => ({required Object num}) => 'modifié ${num} fois',
			'common.editComment' => 'Modifier le commentaire',
			'common.commentUpdated' => 'Commentaire modifié',
			'common.replyComment' => 'Répondre au commentaire',
			'common.reply' => 'Répondre',
			'common.edit' => 'Modifier',
			'common.unknownUser' => 'Utilisateur inconnu',
			'common.me' => 'Moi',
			'common.author' => 'Auteur',
			'common.admin' => 'Admin',
			'common.viewReplies' => ({required Object num}) => 'Voir les réponses (${num})',
			'common.hideReplies' => 'Masquer les réponses',
			'common.confirmDelete' => 'Confirmer la suppression',
			'common.areYouSureYouWantToDeleteThisItem' => 'Voulez-vous vraiment supprimer cet élément ?',
			'common.tmpNoComments' => 'Aucun commentaire pour l\'instant',
			'common.refresh' => 'Actualiser',
			'common.back' => 'Retour',
			'common.tips' => 'Astuces',
			'common.linkIsEmpty' => 'Le lien est vide',
			'common.linkCopiedToClipboard' => 'Lien copié dans le presse-papiers',
			'common.imageCopiedToClipboard' => 'Image copiée dans le presse-papiers',
			'common.copyImageFailed' => 'Échec de la copie de l\'image',
			'common.mobileSaveImageIsUnderDevelopment' => 'L\'enregistrement des images sur mobile est en cours de développement',
			'common.imageSavedTo' => 'Image enregistrée dans',
			'common.saveImageFailed' => 'Échec de l\'enregistrement de l\'image',
			'common.close' => 'Fermer',
			'common.more' => 'Plus',
			'common.unknownError' => 'Erreur inconnue',
			'common.moreFeaturesToBeDeveloped' => 'D\'autres fonctionnalités à venir',
			'common.all' => 'Tout',
			'common.selectedRecords' => ({required Object num}) => '${num} enregistrements sélectionnés',
			'common.cancelSelectAll' => 'Annuler la sélection',
			'common.selectAll' => 'Tout sélectionner',
			'common.invertSelection' => 'Inverser la sélection',
			'common.exitEditMode' => 'Quitter le mode édition',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Voulez-vous vraiment supprimer les ${num} éléments sélectionnés ?',
			'common.searchHistoryRecords' => 'Rechercher dans l\'historique...',
			'common.settings' => 'Réglages',
			'common.subscriptions' => 'Abonnements',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: '${n} vidéo', other: '${n} vidéos', ), 
			'common.share' => 'Partager',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Voulez-vous vraiment partager cette liste de lecture ?',
			'common.editTitle' => 'Modifier le titre',
			'common.editMode' => 'Mode édition',
			'common.pleaseEnterNewTitle' => 'Veuillez saisir le nouveau titre',
			'common.createPlayList' => 'Créer une liste de lecture',
			'common.create' => 'Créer',
			'common.checkNetworkSettings' => 'Vérifier les paramètres réseau',
			'common.general' => 'Général',
			'common.r18' => 'R18',
			'common.sensitive' => 'Sensible',
			'common.year' => 'Année',
			'common.month' => 'Mois',
			'common.tag' => 'Tag',
			'common.private' => 'Privé',
			'common.noTitle' => 'Sans titre',
			'common.search' => 'Rechercher',
			'common.noContent' => 'Aucun contenu',
			'common.recording' => 'Enregistrement',
			'common.paused' => 'En pause',
			'common.clear' => 'Effacer',
			'common.clearSelection' => 'Effacer la sélection',
			'common.selectItemsToContinue' => 'Sélectionnez des éléments pour continuer',
			'common.andMoreItems' => ({required Object num}) => 'et ${num} de plus',
			'common.batchDelete' => 'Suppression groupée',
			'common.user' => 'Utilisateur',
			'common.post' => 'Publier',
			'common.seconds' => 'Secondes',
			'common.comingSoon' => 'Bientôt disponible',
			'common.confirm' => 'Confirmer',
			'common.hour' => 'Heure',
			'common.minute' => 'Minute',
			'common.clickToRefresh' => 'Cliquez pour actualiser',
			'common.history' => 'Historique',
			'common.favorites' => 'Favoris',
			'common.friends' => 'Amis',
			'common.playList' => 'Liste de lecture',
			'common.checkLicense' => 'Vérifier la licence',
			'common.logout' => 'Déconnexion',
			'common.fensi' => 'Abonnés',
			'common.accept' => 'Accepter',
			'common.reject' => 'Refuser',
			'common.clearAllHistory' => 'Effacer tout l\'historique',
			'common.clearAllHistoryConfirm' => 'Voulez-vous vraiment effacer tout l\'historique ?',
			'common.followingList' => 'Liste des abonnements',
			'common.followersList' => 'Liste des abonnés',
			'common.follows' => 'Abonnements',
			'common.fans' => 'Abonnés',
			'common.followsAndFans' => 'Abonnements et abonnés',
			'common.numViews' => 'Vues',
			'common.updatedAt' => 'Mis à jour le',
			'common.publishedAt' => 'Publié le',
			'common.externalVideo' => 'Vidéo externe',
			'common.originalText' => 'Texte original',
			'common.showOriginalText' => 'Afficher le texte d\'origine',
			'common.showProcessedText' => 'Afficher le texte traité',
			'common.preview' => 'Aperçu',
			'common.rules' => 'Règles',
			'common.agree' => 'Accepter',
			'common.disagree' => 'Refuser',
			'common.agreeToRules' => 'Accepter les règles',
			'common.markdownSyntaxHelp' => 'Aide sur la syntaxe Markdown',
			'common.previewContent' => 'Aperçu du contenu',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Dépasse la longueur maximale (${max})',
			'common.agreeToCommunityRules' => 'Accepter les règles de la communauté',
			'common.createPost' => 'Créer une publication',
			'common.title' => 'Titre',
			'common.enterTitle' => 'Veuillez saisir le titre',
			'common.content' => 'Contenu',
			'common.enterContent' => 'Veuillez saisir le contenu',
			'common.writeYourContentHere' => 'Veuillez saisir le contenu...',
			'common.tagBlacklist' => 'Liste noire de tags',
			'common.noData' => 'Aucune donnée',
			'common.tagLimit' => 'Limite de tags',
			'common.enableFloatingButtons' => 'Activer les boutons flottants',
			'common.disableFloatingButtons' => 'Désactiver les boutons flottants',
			'common.enabledFloatingButtons' => 'Boutons flottants activés',
			'common.disabledFloatingButtons' => 'Boutons flottants désactivés',
			'common.pendingCommentCount' => 'Commentaires en attente',
			'common.joined' => ({required Object str}) => 'Membre depuis ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Vu pour la dernière fois ${str}',
			'common.download' => 'Télécharger',
			'common.selectQuality' => 'Choisir la qualité',
			'common.videoQualitySource' => 'Source',
			'common.selectImageQuality' => 'Choisir la qualité d\'image',
			'common.imageQualityStandard' => 'Standard',
			'common.imageQualityOriginal' => 'Originale',
			'common.selectDateRange' => 'Sélectionner une plage de dates',
			'common.selectDateRangeHint' => 'Sélectionnez une plage de dates ; par défaut, les 30 derniers jours',
			'common.clearDateRange' => 'Effacer la plage de dates',
			'common.deleteRecordsInDateRange' => 'Supprimer les enregistrements de cette plage',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'Voulez-vous vraiment supprimer ${num} enregistrements d\'historique dans cette plage de dates ? Cette action est irréversible.',
			'common.noHistoryRecordsInRange' => 'Aucun historique dans cette plage de dates',
			'common.followSuccessClickAgainToSpecialFollow' => 'Abonnement réussi, cliquez à nouveau pour un abonnement spécial',
			'common.specialFollowTip' => 'Ajouté aux abonnements spéciaux — sélectionnez-les dans le sélecteur en haut à droite de la page Abonnements pour y accéder rapidement',
			'common.exitConfirmTip' => 'Voulez-vous vraiment quitter ?',
			'common.error' => 'Erreur',
			'common.taskRunning' => 'Une tâche est déjà en cours, veuillez patienter.',
			'common.operationCancelled' => 'Opération annulée.',
			'common.unsavedChanges' => 'Vous avez des modifications non enregistrées',
			'common.specialFollowsManagementTip' => 'Faites glisser la poignée pour réorganiser • Appuyez sur le bouton pour supprimer',
			'common.specialFollowsManagement' => 'Gestion des abonnements spéciaux',
			'common.removeSpecialFollow' => 'Retirer l\'abonnement spécial',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => 'Retirer ${name} des abonnements spéciaux ?',
			'common.noSpecialFollows' => 'Aucun abonnement spécial',
			'common.createTimeDesc' => 'Date de création décroissante',
			'common.createTimeAsc' => 'Date de création croissante',
			'common.pagination.totalItems' => ({required Object num}) => 'Total : ${num} éléments',
			'common.pagination.jumpToPage' => 'Aller à la page',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Veuillez saisir le numéro de page (1-${max})',
			'common.pagination.pageNumber' => 'Numéro de page',
			'common.pagination.jump' => 'Aller',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Veuillez saisir un numéro de page valide (1-${max})',
			'common.pagination.invalidInput' => 'Veuillez saisir un numéro de page valide',
			'common.pagination.waterfall' => 'Cascade',
			'common.pagination.pagination' => 'Pagination',
			'common.notice' => 'Annonce',
			'common.detail' => 'Détail',
			'common.parseExceptionDestopHint' => '- Les utilisateurs sur ordinateur peuvent configurer un proxy dans les réglages',
			'common.iwaraTags' => 'Tags Iwara',
			'common.tagInfo' => 'Infos du tag',
			'common.tagOriginalKey' => 'Tag d\'origine',
			'common.tagTranslation' => 'Traduction',
			'common.copy' => 'Copier',
			'common.selectCopy' => 'Sélectionner et copier',
			'common.copiedToClipboard' => 'Copié dans le presse-papiers',
			'common.showOriginalTag' => 'Afficher le tag d\'origine',
			'common.showTranslatedTag' => 'Afficher la traduction',
			'common.tagTranslationFeedback' => 'Un doute sur une traduction ? Donnez votre avis',
			'common.tagLocalizationGuideTitle' => 'À propos de la localisation des tags',
			'common.tagLocalizationGuideContent' => 'L\'application affiche les tags bruts d\'Iwara (ex. mother) avec le nom dans votre langue actuelle.\n\n• Lors de la recherche de tags, la traduction et le tag d\'origine correspondent tous les deux.\n• Appuyez longuement ou faites un clic droit sur un tag pour voir et copier sa clé d\'origine et sa traduction.\n• Les traductions sont maintenues par la communauté, au mieux — elles peuvent contenir des erreurs.',
			'common.likeThisVideo' => 'Aimer cette vidéo',
			'common.likeThisGallery' => 'Aimer cette galerie',
			'common.operation' => 'Action',
			'common.replies' => 'Réponses',
			'common.externalLinkWarning' => 'Avertissement de lien externe',
			'common.externalLinkWarningMessage' => 'Vous êtes sur le point d\'ouvrir un lien externe qui ne fait pas partie d\'iwara.tv. Soyez prudent et vérifiez que le lien est sûr avant de continuer.',
			'common.continueToExternalLink' => 'Continuer',
			'common.cancelExternalLink' => 'Annuler',
			'auth.login' => 'Connexion',
			'auth.logout' => 'Déconnexion',
			'auth.email' => 'E-mail',
			'auth.password' => 'Mot de passe',
			'auth.loginOrRegister' => 'Connexion / Inscription',
			'auth.register' => 'S\'inscrire',
			'auth.pleaseEnterEmail' => 'Veuillez saisir votre e-mail',
			'auth.pleaseEnterPassword' => 'Veuillez saisir votre mot de passe',
			'auth.passwordMustBeAtLeast6Characters' => 'Le mot de passe doit comporter au moins 6 caractères',
			'auth.pleaseEnterCaptcha' => 'Veuillez saisir le captcha',
			'auth.captcha' => 'Captcha',
			'auth.refreshCaptcha' => 'Actualiser le captcha',
			'auth.captchaNotLoaded' => 'Captcha non chargé',
			'auth.loginSuccess' => 'Connexion réussie',
			'auth.loginSuccessProfilePending' => 'Connecté. Chargement de votre profil…',
			'auth.emailVerificationSent' => 'E-mail de vérification envoyé',
			'auth.notLoggedIn' => 'Non connecté',
			'auth.clickToLogin' => 'Cliquez pour vous connecter',
			'auth.logoutConfirmation' => 'Voulez-vous vraiment vous déconnecter ?',
			'auth.logoutSuccess' => 'Déconnexion réussie',
			'auth.logoutFailed' => 'Échec de la déconnexion',
			'auth.usernameOrEmail' => 'Nom d\'utilisateur ou e-mail',
			'auth.pleaseEnterUsernameOrEmail' => 'Veuillez saisir votre nom d\'utilisateur ou e-mail',
			'auth.rememberMe' => 'Mémoriser le nom d\'utilisateur',
			'auth.registerNoticeTitle' => 'S\'inscrire sur le site officiel',
			'auth.registerNoticeDescription' => 'L\'inscription dans l\'application n\'est plus disponible. Rendez-vous sur le site officiel d\'Iwara pour créer votre compte, puis revenez ici pour vous connecter.',
			'auth.registerNoticeReturnTip' => 'Après votre inscription, revenez ici et connectez-vous avec votre compte.',
			'auth.goToOfficialWebsite' => 'Aller au site officiel',
			'errors.error' => 'Erreur',
			'errors.required' => 'Ce champ est obligatoire',
			'errors.invalidEmail' => 'Adresse e-mail invalide',
			'errors.networkError' => 'Erreur réseau, veuillez réessayer',
			'errors.errorWhileFetching' => 'Erreur lors de la récupération',
			'errors.commentCanNotBeEmpty' => 'Le contenu du commentaire ne peut pas être vide',
			'errors.errorWhileFetchingReplies' => 'Erreur lors de la récupération des réponses, vérifiez la connexion réseau',
			'errors.canNotFindCommentController' => 'Contrôleur de commentaires introuvable',
			'errors.errorWhileLoadingGallery' => 'Erreur lors du chargement de la galerie',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'Comment pourrait-il ne pas y avoir de données ? C\'est impossible :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Format d\'image non pris en charge : ${str}',
			'errors.invalidGalleryId' => 'ID de galerie invalide',
			'errors.translationFailedPleaseTryAgainLater' => 'Échec de la traduction, veuillez réessayer plus tard',
			'errors.errorOccurred' => 'Une erreur est survenue, veuillez réessayer plus tard.',
			'errors.errorOccurredWhileProcessingRequest' => 'Une erreur est survenue lors du traitement de la requête',
			'errors.errorWhileFetchingDatas' => 'Erreur lors de la récupération des données, veuillez réessayer plus tard',
			'errors.serviceNotInitialized' => 'Service non initialisé',
			'errors.unknownType' => 'Type inconnu',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Erreur lors de l\'ouverture du lien : ${link}',
			'errors.invalidUrl' => 'URL invalide',
			'errors.failedToOperate' => 'Échec de l\'opération',
			'errors.permissionDenied' => 'Permission refusée',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'Vous n\'avez pas la permission d\'accéder à cette ressource',
			'errors.loginFailed' => 'Échec de la connexion',
			'errors.unknownError' => 'Erreur inconnue',
			'errors.sessionExpired' => 'Session expirée',
			'errors.failedToFetchCaptcha' => 'Échec de la récupération du captcha',
			'errors.emailAlreadyExists' => 'Cet e-mail existe déjà',
			'errors.invalidCaptcha' => 'Captcha invalide',
			'errors.registerFailed' => 'Échec de l\'inscription',
			'errors.failedToFetchComments' => 'Échec de la récupération des commentaires',
			'errors.failedToFetchImageDetail' => 'Échec de la récupération du détail de l\'image',
			'errors.failedToFetchImageList' => 'Échec de la récupération de la liste des images',
			'errors.failedToFetchData' => 'Échec de la récupération des données',
			'errors.invalidParameter' => 'Paramètre invalide',
			'errors.pleaseLoginFirst' => 'Veuillez d\'abord vous connecter',
			'errors.errorWhileLoadingPost' => 'Erreur lors du chargement de la publication',
			'errors.errorWhileLoadingPostDetail' => 'Erreur lors du chargement du détail de la publication',
			'errors.invalidPostId' => 'ID de publication invalide',
			'errors.forceUpdateNotPermittedToGoBack' => 'Mise à jour forcée en cours, impossible de revenir en arrière',
			'errors.pleaseLoginAgain' => 'Veuillez vous reconnecter',
			'errors.invalidLogin' => 'Connexion invalide, vérifiez votre e-mail et votre mot de passe',
			'errors.tooManyRequests' => 'Trop de requêtes, veuillez réessayer plus tard',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Dépasse la longueur maximale : ${max}',
			'errors.contentCanNotBeEmpty' => 'Le contenu ne peut pas être vide',
			'errors.titleCanNotBeEmpty' => 'Le titre ne peut pas être vide',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Trop de requêtes, veuillez réessayer plus tard ; restant',
			'errors.remainingHours' => ({required Object num}) => '${num} heures',
			'errors.remainingMinutes' => ({required Object num}) => '${num} min',
			'errors.remainingSeconds' => ({required Object num}) => '${num} secondes',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Limite de tags dépassée, limite : ${limit}',
			'errors.failedToRefresh' => 'Échec de l\'actualisation',
			'errors.noPermission' => 'Aucune permission',
			'errors.resourceNotFound' => 'Ressource introuvable',
			'errors.failedToSaveCredentials' => 'Échec de l\'enregistrement des identifiants de connexion',
			'errors.failedToLoadSavedCredentials' => 'Échec du chargement des identifiants enregistrés',
			'errors.notFound' => 'Contenu introuvable ou supprimé',
			'errors.network.basicPrefix' => 'Erreur réseau - ',
			'errors.network.failedToConnectToServer' => 'Échec de la connexion au serveur',
			'errors.network.serverNotAvailable' => 'Serveur indisponible',
			'errors.network.requestTimeout' => 'Délai de requête dépassé',
			'errors.network.unexpectedError' => 'Erreur inattendue',
			'errors.network.invalidResponse' => 'Réponse invalide',
			'errors.network.invalidRequest' => 'Requête invalide',
			'errors.network.invalidUrl' => 'URL invalide',
			'errors.network.invalidMethod' => 'Méthode invalide',
			'errors.network.invalidHeader' => 'En-tête invalide',
			'errors.network.invalidBody' => 'Corps invalide',
			'errors.network.invalidStatusCode' => 'Code d\'état invalide',
			'errors.network.serverError' => 'Erreur du serveur',
			'errors.network.requestCanceled' => 'Requête annulée',
			'errors.network.invalidPort' => 'Port invalide',
			'errors.network.proxyPortError' => 'Erreur de port du proxy',
			'errors.network.connectionRefused' => 'Connexion refusée',
			'errors.network.networkUnreachable' => 'Réseau inaccessible',
			'errors.network.noRouteToHost' => 'Aucune route vers l\'hôte',
			'errors.network.connectionFailed' => 'Échec de la connexion',
			'errors.network.sslConnectionFailed' => 'Échec de la connexion SSL, vérifiez vos paramètres réseau',
			'friends.clickToRestoreFriend' => 'Cliquez pour restaurer l\'ami',
			'friends.friendsList' => 'Liste d\'amis',
			'friends.friendRequests' => 'Demandes d\'amis',
			'friends.friendRequestsList' => 'Liste des demandes d\'amis',
			'friends.removingFriend' => 'Retrait de l\'ami...',
			'friends.failedToRemoveFriend' => 'Échec du retrait de l\'ami',
			'friends.cancelingRequest' => 'Annulation de la demande d\'ami...',
			'friends.failedToCancelRequest' => 'Échec de l\'annulation de la demande d\'ami',
			'authorProfile.noMoreDatas' => 'Plus de données',
			'authorProfile.userProfile' => 'Profil utilisateur',
			'favorites.clickToRestoreFavorite' => 'Cliquez pour restaurer le favori',
			'favorites.myFavorites' => 'Mes favoris',
			'favorites.batchCancelFavorite' => 'Retirer les favoris sélectionnés',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'Retirer les ${count} éléments sélectionnés des favoris ? Vous pourrez les restaurer en touchant les cartes ensuite.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => '${count} élément(s) retiré(s) des favoris',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => '${success} élément(s) retiré(s), ${failed} en échec',
			'galleryDetail.browseInSpace' => 'Parcourir dans l\'espace',
			'galleryDetail.galleryDetail' => 'Détail de la galerie',
			'galleryDetail.viewGalleryDetail' => 'Voir le détail de la galerie',
			'galleryDetail.zoomReset' => 'Réinitialiser le zoom',
			'galleryDetail.copyLink' => 'Copier le lien',
			'galleryDetail.copyImage' => 'Copier l\'image',
			'galleryDetail.saveAs' => 'Enregistrer sous',
			'galleryDetail.saveToAlbum' => 'Enregistrer dans l\'album',
			'galleryDetail.publishedAt' => 'Publié le',
			'galleryDetail.viewsCount' => 'Nombre de vues',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Présentation des fonctions de la bibliothèque d\'images',
			'galleryDetail.rightClickToSaveSingleImage' => 'Clic droit pour enregistrer l\'image seule',
			'galleryDetail.batchSave' => 'Enregistrement groupé',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Flèches gauche et droite pour changer',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Flèches haut et bas pour zoomer',
			'galleryDetail.mouseWheelToSwitch' => 'Molette pour changer',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + molette pour zoomer',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'D\'autres fonctions à découvrir...',
			'galleryDetail.authorOtherGalleries' => 'Autres galeries de l\'auteur',
			'galleryDetail.relatedGalleries' => 'Galeries associées',
			'galleryDetail.authorNoOtherGalleries' => 'Aucune autre galerie de cet auteur',
			'galleryDetail.noRelatedGalleries' => 'Aucune galerie associée',
			'galleryDetail.scrollLeft' => 'Défiler à gauche',
			'galleryDetail.scrollRight' => 'Défiler à droite',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Cliquez sur les bords gauche et droit pour changer d\'image',
			'galleryDetail.rotateToLandscape' => 'Plein écran paysage',
			'galleryDetail.backToPortrait' => 'Revenir au portrait',
			'playList.myPlayList' => 'Mes playlists',
			'playList.friendlyTips' => 'Conseils',
			'playList.dearUser' => 'Cher utilisateur',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'Le système de playlists d\'iwara n\'est pas encore parfait',
			'playList.notSupportSetCover' => 'Définition de la couverture non prise en charge',
			'playList.notSupportDeleteList' => 'Suppression de liste non prise en charge',
			'playList.notSupportSetPrivate' => 'Passage en privé non pris en charge',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Oui... la liste créée existera toujours et sera visible par tout le monde',
			'playList.smallSuggestion' => 'Petit conseil',
			'playList.useLikeToCollectContent' => 'Si vous tenez davantage à votre confidentialité, il est conseillé d\'utiliser la fonction « J\'aime » pour enregistrer du contenu',
			'playList.welcomeToDiscussOnGitHub' => 'Si vous avez d\'autres suggestions ou idées, n\'hésitez pas à en discuter sur GitHub !',
			'playList.iUnderstand' => 'J\'ai compris',
			'playList.searchPlaylists' => 'Rechercher des playlists...',
			'playList.newPlaylistName' => 'Nom de la nouvelle playlist',
			'playList.createNewPlaylist' => 'Créer une playlist',
			'playList.videos' => 'Vidéos',
			'search.googleSearchScope' => 'Portée de la recherche',
			'search.searchTags' => 'Rechercher des tags...',
			'search.contentRating' => 'Classification du contenu',
			'search.removeTag' => 'Retirer le tag',
			'search.pleaseEnterSearchContent' => 'Veuillez saisir le contenu à rechercher',
			'search.searchHistory' => 'Historique de recherche',
			'search.searchSuggestion' => 'Suggestion de recherche',
			'search.usedTimes' => 'Nombre d\'utilisations',
			'search.lastUsed' => 'Dernière utilisation',
			'search.noSearchHistoryRecords' => 'Aucun historique de recherche',
			'search.clearSearchHistoryConfirm' => 'Voulez-vous vraiment effacer tout l\'historique de recherche ? Cette action est irréversible.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Type de recherche actuel ${searchType} non pris en charge, veuillez attendre la mise à jour',
			'search.searchResult' => 'Résultat de recherche',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Type de recherche non pris en charge : ${searchType}',
			'search.googleSearch' => 'Recherche Google',
			'search.googleSearchHint' => ({required Object webName}) => '${webName}, la fonction de recherche n\'est pas pratique ? Essayez la recherche Google !',
			'search.googleSearchDescription' => 'Utilisez l\'opérateur de recherche :site de Google pour chercher du contenu sur le site. Très utile pour rechercher des vidéos, galeries, playlists et utilisateurs.',
			'search.googleSearchKeywordsHint' => 'Saisir des mots-clés à rechercher',
			'search.openLinkJump' => 'Saut de lien',
			'search.googleSearchButton' => 'Recherche Google',
			'search.pleaseEnterSearchKeywords' => 'Veuillez saisir des mots-clés',
			'search.googleSearchQueryCopied' => 'Requête de recherche copiée',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Échec de l\'ouverture du navigateur : ${error}',
			'search.searchRequestTimeout' => 'Délai de la requête dépassé, veuillez réessayer plus tard',
			'search.searchCannotConnectToServer' => 'Impossible de se connecter au serveur, veuillez vérifier votre connexion réseau',
			'search.searchNetworkError' => 'Échec de la connexion réseau, veuillez vérifier vos paramètres réseau ou réessayer plus tard',
			'search.searchFailedPleaseRetry' => 'Échec de la recherche, veuillez réessayer plus tard',
			'mediaList.personalIntroduction' => 'Présentation',
			'settings.listViewMode' => 'Mode liste',
			'settings.previewEffect' => 'Aperçu de l\'effet',
			'settings.useTraditionalPaginationMode' => 'Utiliser la pagination classique',
			'settings.useTraditionalPaginationModeDesc' => 'Activer la pagination classique et désactiver le mode cascade. Prend effet après un nouveau rendu de la page ou un redémarrage de l\'app',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Afficher la barre de progression vidéo en bas lorsque la barre d\'outils est masquée',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Ce réglage détermine si la barre de progression vidéo en bas s\'affiche lorsque la barre d\'outils est masquée.',
			'settings.seekPreviewSize' => 'Taille de l\'aperçu de navigation',
			'settings.seekPreviewSizeDesc' => 'Taille de la fenêtre d\'aperçu au-dessus de la barre de progression. Elle suit déjà la taille du lecteur et les proportions de la vidéo ; ce réglage ne fait que l\'ajuster légèrement.',
			'settings.seekPreviewSizeSmall' => 'Petite',
			'settings.seekPreviewSizeStandard' => 'Standard',
			'settings.seekPreviewSizeLarge' => 'Grande',
			'settings.seekPreviewSizeStandardDesc' => 'La taille dérivée du lecteur et de la vidéo',
			'settings.showFullscreenUpNextHint' => 'Afficher la poignée « À suivre »',
			'settings.showFullscreenUpNextHintDesc' => 'Affiche une petite poignée sur le bord droit du lecteur, qui ouvre le tiroir de la file (source / playlist / à regarder plus tard). Une fois désactivée, il n\'y a plus d\'autre accès.',
			'settings.basicSettings' => 'Paramètres de base',
			'settings.personalizedSettings' => 'Paramètres personnalisés',
			'settings.otherSettings' => 'Autres paramètres',
			'settings.searchConfig' => 'Configuration de recherche',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Ce réglage détermine si la configuration précédente est réutilisée lors de la lecture suivante de vidéos.',
			'settings.playControl' => 'Contrôle de lecture',
			'settings.playbackSpeedSettings' => 'Lecture et vitesse',
			'settings.playbackBehaviorSettings' => 'Comportement de lecture',
			'settings.enhancementSettings' => 'Théâtre et améliorations',
			'settings.fastForwardTime' => 'Durée d\'avance rapide',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'La durée d\'avance rapide doit être un entier positif.',
			'settings.rewindTime' => 'Durée de retour arrière',
			'settings.rewindTimeMustBeAPositiveInteger' => 'La durée de retour arrière doit être un entier positif.',
			'settings.longPressPlaybackSpeed' => 'Vitesse en appui long',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'La vitesse de lecture en appui long doit être un nombre positif.',
			'settings.defaultPlaybackSpeed' => 'Vitesse de lecture par défaut',
			_ => null,
		} ?? switch (path) {
			'settings.rememberPlaybackSpeed' => 'Mémoriser la vitesse de lecture',
			'settings.rememberPlaybackSpeedDesc' => 'Une fois activé, la vitesse définie dans le lecteur est enregistrée comme valeur par défaut et appliquée automatiquement aux nouvelles vidéos.',
			'settings.repeat' => 'Répéter',
			'settings.renderVerticalVideoInVerticalScreen' => 'Afficher les vidéos verticales en écran vertical',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Ce réglage détermine si la vidéo est affichée en écran vertical lors de la lecture en plein écran.',
			'settings.rememberVolume' => 'Mémoriser le volume',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Ce réglage détermine si le volume est conservé lors de la lecture suivante de vidéos.',
			'settings.rememberBrightness' => 'Mémoriser la luminosité',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Ce réglage détermine si la luminosité est conservée lors de la lecture suivante de vidéos.',
			'settings.playControlArea' => 'Zone de contrôle de lecture',
			'settings.leftAndRightControlAreaWidth' => 'Largeur des zones de contrôle gauche et droite',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Ce réglage détermine la largeur des zones de contrôle à gauche et à droite du lecteur.',
			'settings.proxyAddressCannotBeEmpty' => 'L\'adresse du proxy ne peut pas être vide.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Format d\'adresse proxy non valide. Utilisez le format IP:port ou nom de domaine:port.',
			'settings.proxyNormalWork' => 'Le proxy fonctionne normalement.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Échec du test du proxy, code d\'état : ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Échec du test du proxy, exception : ${exception}',
			'settings.proxyConfig' => 'Configuration du proxy',
			'settings.thisIsHttpProxyAddress' => 'Il s\'agit de l\'adresse du proxy HTTP',
			'settings.checkProxy' => 'Vérifier le proxy',
			'settings.proxyAddress' => 'Adresse du proxy',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Veuillez saisir l\'URL du serveur proxy, par exemple 127.0.0.1:8080',
			'settings.enableProxy' => 'Activer le proxy',
			'settings.left' => 'Gauche',
			'settings.middle' => 'Milieu',
			'settings.right' => 'Droite',
			'settings.playerSettings' => 'Paramètres du lecteur',
			'settings.networkSettings' => 'Paramètres réseau',
			'settings.customizeYourPlaybackExperience' => 'Personnalisez votre expérience de lecture',
			'settings.chooseYourFavoriteAppAppearance' => 'Choisissez l\'apparence de votre app',
			'settings.configureYourProxyServer' => 'Configurez votre serveur proxy',
			'settings.settings' => 'Paramètres',
			'settings.themeSettings' => 'Paramètres de thème',
			'settings.followSystem' => 'Suivre le système',
			'settings.lightMode' => 'Mode clair',
			'settings.darkMode' => 'Mode sombre',
			'settings.presetTheme' => 'Thème prédéfini',
			'settings.basicTheme' => 'Thème de base',
			'settings.needRestartToApply' => 'Redémarrez l\'app pour appliquer les paramètres',
			'settings.themeNeedRestartDescription' => 'Les paramètres de thème nécessitent de redémarrer l\'app pour être appliqués',
			'settings.about' => 'À propos',
			'settings.diagnosticsAndFeedback' => 'Diagnostic et retours',
			'settings.currentVersion' => 'Version actuelle',
			'settings.latestVersion' => 'Dernière version',
			'settings.checkForUpdates' => 'Rechercher des mises à jour',
			'settings.update' => 'Mettre à jour',
			'settings.newVersionAvailable' => 'Nouvelle version disponible',
			'settings.projectHome' => 'Accueil du projet',
			'settings.release' => 'Versions',
			'settings.issueReport' => 'Signaler un problème',
			'settings.openSourceLicense' => 'Licence open source',
			'settings.checkForUpdatesFailed' => 'Échec de la recherche de mises à jour, veuillez réessayer plus tard',
			'settings.autoCheckUpdate' => 'Recherche auto. des mises à jour',
			'settings.updateContent' => 'Contenu de la mise à jour',
			'settings.releaseDate' => 'Date de publication',
			'settings.ignoreThisVersion' => 'Ignorer cette version',
			'settings.forceUpdateTip' => 'Cette mise à jour est obligatoire. Veuillez passer dès que possible à la dernière version',
			'settings.viewChangelog' => 'Voir le journal des modifications',
			'settings.alreadyLatestVersion' => 'Vous avez déjà la dernière version',
			'settings.appSettings' => 'Paramètres de l\'app',
			'settings.configureYourAppSettings' => 'Configurez les paramètres de votre app',
			'settings.history' => 'Historique',
			'settings.autoRecordHistory' => 'Enregistrement auto. de l\'historique',
			'settings.autoRecordHistoryDesc' => 'Enregistrer automatiquement les vidéos et images que vous avez regardées',
			'settings.autoDeleteHistory' => 'Nettoyage auto. de l\'historique',
			'settings.autoDeleteHistoryDesc' => 'Supprimer automatiquement au démarrage l\'historique de navigation plus ancien que la durée de conservation (désactivé par défaut)',
			'settings.autoDeleteHistoryDays' => 'Jours de conservation',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Conserver les ${num} derniers jours',
			'settings.autoDeleteHistoryDaysInvalid' => 'Veuillez saisir un nombre de jours valide (au moins 1)',
			'settings.showUnprocessedMarkdownText' => 'Afficher le texte Markdown brut',
			'settings.showUnprocessedMarkdownTextDesc' => 'Afficher le texte d\'origine du markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Mode confidentialité',
			'settings.activeBackgroundPrivacyModeDesc' => 'Bloquer les captures d\'écran et l\'enregistrement, et masquer l\'écran en arrière-plan',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Masquer l\'écran lorsque l\'app passe en arrière-plan (cette plateforme ne peut pas bloquer les captures d\'écran)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Bloquer les captures d\'écran et l\'enregistrement d\'écran',
			'settings.privacy' => 'Confidentialité',
			'settings.appLock' => 'Verrouillage de l\'app',
			'settings.appLockEnabled' => 'Activer le verrouillage de l\'app',
			'settings.appLockEnabledDesc' => 'Exiger un code PIN ou une donnée biométrique pour ouvrir l\'app ; l\'aperçu en arrière-plan est masqué automatiquement',
			'settings.appLockEnabledSummary' => 'Activé · protégé par code PIN',
			'settings.appLockDisabledSummary' => 'Désactivé',
			'settings.appLockTimeout' => 'Verrouiller après avoir quitté l\'app',
			'settings.appLockTimeoutDesc' => 'Temps autorisé en arrière-plan avant qu\'une authentification soit requise',
			'settings.appLockAfterScreenOff' => 'Verrouiller après le verrouillage de l\'écran',
			'settings.appLockAfterScreenOffDesc' => 'Exiger une authentification après le verrouillage de l\'écran de l\'appareil',
			'settings.appLockTimeoutDisabled' => 'Désactivé',
			'settings.appLockImmediately' => 'Immédiatement',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} secondes',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} minutes',
			'settings.appLockUseBiometrics' => 'Utiliser la biométrie',
			'settings.appLockUseBiometricsDesc' => 'Déverrouiller par empreinte digitale ou reconnaissance faciale',
			'settings.appLockBiometricsUnavailable' => 'Aucune donnée biométrique enregistrée sur cet appareil',
			'settings.appLockSetPin' => 'Définir le code PIN',
			'settings.appLockEnterPin' => 'Saisir le code PIN',
			'settings.appLockConfirmPin' => 'Confirmer le code PIN',
			'settings.appLockCurrentPin' => 'Saisir le code PIN actuel',
			'settings.appLockNewPin' => 'Saisir le nouveau code PIN',
			'settings.appLockPinRequirements' => 'Le code PIN doit comporter 4 à 8 chiffres',
			'settings.appLockPinsDoNotMatch' => 'Les codes PIN ne correspondent pas',
			'settings.appLockInvalidPin' => 'Code PIN incorrect',
			'settings.appLockSetupFailed' => 'Impossible d\'enregistrer le code PIN en toute sécurité',
			'settings.appLockDisable' => 'Saisir le code PIN pour désactiver le verrouillage',
			'settings.appLockChangePin' => 'Modifier le code PIN',
			'settings.appLockNow' => 'Verrouiller maintenant',
			'settings.appLockUnlock' => 'Déverrouiller',
			'settings.appLockLockedTitle' => 'Verrouillé',
			'settings.appLockLockedDesc' => 'Authentifiez-vous pour continuer',
			'settings.appLockAuthenticateReason' => 'Authentifiez-vous pour déverrouiller',
			'settings.appLockEnableBiometricsReason' => 'Authentifiez-vous pour activer le déverrouillage biométrique',
			'settings.appLockBiometricFailed' => 'L\'authentification biométrique n\'a pas abouti',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Trop de tentatives. Réessayez dans ${seconds} s',
			'settings.appLockCredentialUnavailableTitle' => 'Impossible de lire l\'identifiant de verrouillage de l\'app',
			'settings.appLockCredentialUnavailableDesc' => 'Le stockage sécurisé du système est temporairement indisponible ou l\'identifiant est corrompu. L\'application reste verrouillée. Réessayez d\'abord ; si l\'échec persiste, vous pouvez réinitialiser le verrouillage de l\'app, ce qui le désactive et efface le code PIN enregistré.',
			'settings.appLockRetry' => 'Réessayer',
			'settings.appLockReset' => 'Réinitialiser le verrouillage',
			'settings.appLockResetAction' => 'Réinitialiser',
			'settings.appLockResetConfirmTitle' => 'Réinitialiser le verrouillage de l\'app ?',
			'settings.appLockResetConfirmDesc' => 'Cela désactive le verrouillage de l\'app et efface le code PIN et le réglage biométrique enregistrés. Vous pourrez le reconfigurer ensuite.',
			'settings.appLockRetrySucceeded' => 'Lecture de l\'identifiant réussie. Saisissez votre code PIN.',
			'settings.appLockRetryFailed' => 'Toujours impossible de lire l\'identifiant',
			'settings.forum' => 'Forum',
			'settings.news' => 'Actualités',
			'settings.community' => 'Communauté',
			'settings.disableForumReplyQuote' => 'Désactiver la citation des réponses du forum',
			'settings.disableForumReplyQuoteDesc' => 'Ne pas reprendre les informations du message cité lors d\'une réponse sur le forum',
			'settings.theaterMode' => 'Mode théâtre',
			'settings.theaterModeDesc' => 'Une fois activé, l\'arrière-plan du lecteur devient la version floutée de la couverture de la vidéo',
			'settings.appLinks' => 'Liens de l\'app',
			'settings.defaultBrowser' => 'Navigation par défaut',
			'settings.defaultBrowserDesc' => 'Ouvrez l\'élément « liens par défaut » dans les réglages système et ajoutez le lien du site iwara.tv',
			'settings.themeMode' => 'Mode de thème',
			'settings.themeModeDesc' => 'Ce réglage détermine le mode de thème de l\'app',
			'settings.glassEffect' => 'Matériau de l\'interface',
			'settings.glassEffectDesc' => 'Choisit le matériau utilisé dans toute l\'app — capsules d\'en-tête, menus, boutons de dialogue et barre de navigation inférieure',
			'settings.liquidGlassEffect' => 'Verre liquide',
			'settings.liquidGlassEffectDesc' => 'Véritable flou et réfraction. Le plus beau, mais peut entraîner des saccades et consommer un peu plus d\'énergie sur les appareils d\'entrée de gamme',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Surfaces Material 3 standard — opaques, sans flou ni ombres. Meilleures performances et autonomie',
			'settings.glassEffectIntroTitle' => 'Choisissez le matériau de votre interface',
			'settings.glassEffectIntroContent' => 'Les en-têtes, la barre d\'onglets et les menus utilisent le verre liquide — véritable flou et réfraction. Si cela paraît lent sur votre appareil, ou si vous préférez plus sobre, passez à Material (surfaces opaques, sans flou ni ombres).',
			'settings.glassEffectIntroHint' => 'Vous pouvez modifier ce choix à tout moment dans Paramètres → Thème → Matériau de l\'interface.',
			'settings.glassEffectIntroDone' => 'Conserver',
			'settings.dynamicColor' => 'Couleur dynamique',
			'settings.dynamicColorDesc' => 'Ce réglage détermine si l\'app utilise la couleur dynamique',
			'settings.useDynamicColor' => 'Utiliser la couleur dynamique',
			'settings.useDynamicColorDesc' => 'Ce réglage détermine si l\'app utilise la couleur dynamique',
			'settings.presetColors' => 'Couleurs prédéfinies',
			'settings.customColors' => 'Couleurs personnalisées',
			'settings.customColorsDisabledByDynamicColor' => 'La couleur dynamique est activée, les couleurs prédéfinies/personnalisées sont donc indisponibles. Désactivez d\'abord la couleur dynamique.',
			'settings.pickColor' => 'Choisir une couleur',
			'settings.cancel' => 'Annuler',
			'settings.confirm' => 'Confirmer',
			'settings.noCustomColors' => 'Aucune couleur personnalisée',
			'settings.recordAndRestorePlaybackProgress' => 'Mémoriser et restaurer la progression de lecture',
			'settings.autoPlayVideoOnFirstEnter' => 'Lecture auto. à la première ouverture',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Ce réglage détermine si la vidéo démarre automatiquement lors de la première ouverture de la page vidéo.',
			'settings.autoEnterFullscreen' => 'Passer en plein écran automatiquement',
			'settings.autoEnterFullscreenDesc' => 'Quand le lecteur doit passer en plein écran de lui-même. Les vidéos privées, supprimées et externes ne sont jamais concernées, tout comme l\'incrustation d\'image.',
			'settings.autoEnterFullscreenOff' => 'Désactivé',
			'settings.autoEnterFullscreenOffDesc' => 'Ne jamais passer en plein écran automatiquement',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'Au démarrage de la lecture',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Passer en plein écran dès que la lecture commence réellement',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'À l\'ouverture de la vidéo',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Passer en plein écran dès l\'ouverture de la page vidéo, sans attendre la lecture',
			'settings.autoEnterFullscreenKind' => 'Type de plein écran',
			'settings.autoEnterFullscreenKindDesc' => 'Quel type de plein écran activer automatiquement. Bureau uniquement.',
			'settings.autoEnterFullscreenKindSystem' => 'Plein écran système',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Laisser le gestionnaire de fenêtres passer la fenêtre en plein écran',
			'settings.autoEnterFullscreenKindApp' => 'Plein écran de l\'app',
			'settings.autoEnterFullscreenKindAppDesc' => 'Conserver la fenêtre telle quelle et transformer toute l\'app en lecteur',
			'settings.signature' => 'Signature',
			'settings.enableSignature' => 'Activer la signature',
			'settings.enableSignatureDesc' => 'Ce réglage détermine si l\'app ajoute la signature lors des réponses',
			'settings.enterSignature' => 'Saisir la signature',
			'settings.editSignature' => 'Modifier la signature',
			'settings.signatureContent' => 'Contenu de la signature',
			'settings.exportConfig' => 'Exporter la configuration de l\'app',
			'settings.exportConfigDesc' => 'Exporter les paramètres et l\'historique (historique de navigation, progression de lecture, favoris, etc.) dans un fichier pour sauvegarde ou transfert vers un autre appareil. Les tâches de téléchargement ne sont pas incluses.',
			'settings.importConfig' => 'Importer la configuration de l\'app',
			'settings.importConfigDesc' => 'Importer la configuration de l\'app depuis un fichier',
			'settings.exportConfigSuccess' => 'Configuration exportée !',
			'settings.exportConfigFailed' => 'Échec de l\'export de la configuration',
			'settings.importConfigSuccess' => 'Configuration importée !',
			'settings.importConfigFailed' => 'Échec de l\'import de la configuration',
			'settings.exportIncludeSensitive' => 'Inclure les infos sensibles',
			'settings.exportIncludeSensitiveDesc' => 'Inclut les clés d\'API, les jetons de session et l\'adresse du proxy. À activer uniquement pour une sauvegarde sur votre propre appareil.',
			'settings.importConfigOverwriteWarning' => 'L\'import écrasera vos paramètres et votre historique actuels (historique de navigation, progression de lecture, favoris, etc.). Continuer ?',
			'settings.importConfigRestartTitle' => 'Import réussi',
			'settings.importConfigRestartContent' => 'Votre configuration a été importée. Veuillez fermer complètement puis rouvrir l\'app pour que tous les changements prennent effet.',
			'settings.historyUpdateLogs' => 'Historique des mises à jour',
			'settings.noUpdateLogs' => 'Aucun journal de mise à jour disponible',
			'settings.versionLabel' => 'Version : {version}',
			'settings.releaseDateLabel' => 'Date de publication : {date}',
			'settings.noChanges' => 'Aucun contenu de mise à jour disponible',
			'settings.interaction' => 'Interaction',
			'settings.enableVibration' => 'Activer les vibrations',
			'settings.enableVibrationDesc' => 'Activer le retour par vibration lors des interactions avec l\'app',
			'settings.defaultKeepVideoToolbarVisible' => 'Garder la barre d\'outils vidéo visible',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Ce réglage détermine si la barre d\'outils vidéo reste visible à la première ouverture de la page vidéo.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Sur mobile, le mode théâtre peut entraîner des problèmes de performance. Vous pouvez choisir de l\'activer.',
			'settings.fullscreenOrientation' => 'Orientation de l\'écran après le plein écran',
			'settings.fullscreenOrientationDesc' => 'Ce réglage détermine l\'orientation d\'écran par défaut lors du passage en plein écran (mobile uniquement)',
			'settings.fullscreenOrientationLeftLandscape' => 'Paysage gauche',
			'settings.fullscreenOrientationRightLandscape' => 'Paysage droite',
			'settings.screenFit' => 'Taille d\'écran',
			'settings.screenFitDesc' => 'Choisir comment la vidéo remplit la zone du lecteur.',
			'settings.rememberScreenFit' => 'Mémoriser la taille d\'écran',
			'settings.rememberScreenFitDesc' => 'Appliquer la taille sélectionnée aux vidéos ouvertes ensuite.',
			'settings.screenFitFit' => 'Ajuster',
			'settings.screenFitFitDesc' => 'Afficher toute l\'image en conservant les proportions',
			'settings.screenFitStretch' => 'Étirer',
			'settings.screenFitStretchDesc' => 'Remplir la zone du lecteur ; l\'image peut être déformée',
			'settings.screenFitCover' => 'Remplir',
			'settings.screenFitCoverDesc' => 'Remplir la zone du lecteur en conservant les proportions ; le surplus est rogné',
			'settings.screenFitRatioDesc' => 'Forcer ces proportions ; l\'image peut être déformée',
			'settings.jumpLink' => 'Saut de lien',
			'settings.language' => 'Langue',
			'settings.languageNativeName' => 'Français',
			'settings.followSystemLanguage' => 'Suivre le système',
			'settings.languageChangedMessage' => 'Langue modifiée. Certaines fonctions nécessitent un redémarrage de l\'application.',
			'settings.languageChanged' => 'Le réglage de langue a été modifié ; veuillez redémarrer l\'app pour qu\'il prenne effet.',
			'settings.keybinding.title' => 'Raccourcis clavier',
			'settings.keybinding.entryLabel' => 'Raccourcis clavier',
			'settings.keybinding.entryDesc' => 'Personnaliser les raccourcis clavier de l\'app (surtout pour ordinateur)',
			'settings.keybinding.desktopHint' => 'Les raccourcis s\'appliquent surtout aux claviers d\'ordinateur ; sur mobile, les gestes sont généralement utilisés.',
			'settings.keybinding.resetAll' => 'Tout réinitialiser',
			'settings.keybinding.resetAllConfirm' => 'Réinitialiser tous les raccourcis de l\'app ?',
			'settings.keybinding.resetToDefault' => 'Réinitialiser',
			'settings.keybinding.resetScope' => 'Réinitialiser cette section',
			'settings.keybinding.notSet' => 'Non défini',
			'settings.keybinding.addShortcut' => 'Ajouter un raccourci',
			'settings.keybinding.removeShortcut' => 'Supprimer ce raccourci',
			'settings.keybinding.pressNewShortcut' => 'Appuyez sur le nouveau raccourci…',
			'settings.keybinding.recordingCancelHint' => 'Appuyez sur Échap pour annuler',
			'settings.keybinding.mouseHint' => 'Vous pouvez aussi lier les boutons latéraux de la souris (retour / avant) ou le bouton central',
			'settings.keybinding.mouseNotSupportedInScope' => 'Cette zone ne gère pas les boutons de la souris ; utilisez le clavier',
			'settings.keybinding.capabilityKeyboardOnly' => 'Cette zone accepte uniquement les touches du clavier',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Cette zone accepte les touches du clavier, ainsi que les boutons central et latéraux de la souris',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Cette zone accepte les touches du clavier, ainsi que les boutons central et avant de la souris (le bouton retour est utilisé par le système)',
			'settings.keybinding.rejectMultipleButtons' => 'Appuyez sur un bouton de souris à la fois',
			'settings.keybinding.rejectPlatformBack' => 'Le système l\'utilise déjà pour Retour ; le lier ferait un double retour',
			'settings.keybinding.detectedLabel' => 'Détecté',
			'settings.keybinding.reservedKey' => 'Cette touche est réservée par le système et ne peut pas être liée',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Cette touche est liée à « ${action} » ; elle reste réservée ici pour que vous puissiez toujours quitter cet écran',
			'settings.keybinding.conflictTitle' => 'Conflit de raccourci',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Cette combinaison est déjà liée à « ${action} ». Continuer supprimera la liaison existante.',
			'settings.keybinding.conflictContinue' => 'Lier quand même',
			'settings.keybinding.shadowWarningTitle' => 'Chevauchement de raccourci global',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Cette combinaison est liée à « ${action} » au niveau global. La lier ici ne remplacera cette action que dans cette section.',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'Cette combinaison est déjà liée à « ${action} » dans ${scope}. Dans cette section, ce raccourci global sera remplacé par celui-ci.',
			'settings.keybinding.searchHint' => 'Rechercher des raccourcis…',
			'settings.keybinding.scopeGlobal' => 'Global',
			'settings.keybinding.scopeGallery' => 'Galerie',
			'settings.keybinding.scopeVideo' => 'Vidéo',
			'settings.keybinding.categoryNavigation' => 'Navigation',
			'settings.keybinding.categoryZoom' => 'Zoom',
			'settings.keybinding.categoryPlayback' => 'Lecture',
			'settings.keybinding.categorySeek' => 'Déplacement',
			'settings.keybinding.categoryVolume' => 'Volume',
			'settings.keybinding.categoryDisplay' => 'Affichage',
			'settings.keybinding.actionGlobalBack' => 'Retour',
			'settings.keybinding.actionGalleryNext' => 'Photo suivante',
			'settings.keybinding.actionGalleryPrevious' => 'Photo précédente',
			'settings.keybinding.actionGalleryZoomIn' => 'Zoom avant',
			'settings.keybinding.actionGalleryZoomOut' => 'Zoom arrière',
			'settings.keybinding.actionGalleryResetZoom' => 'Réinitialiser le zoom',
			'settings.keybinding.actionGalleryPlayPause' => 'Lecture / Pause',
			'settings.keybinding.actionGallerySeekBackward' => 'Rembobiner',
			'settings.keybinding.actionGallerySeekForward' => 'Avance rapide',
			'settings.keybinding.actionGalleryToggleMute' => 'Activer/couper le son',
			'settings.keybinding.actionPlayPause' => 'Lecture / Pause',
			'settings.keybinding.actionSpeedUp' => 'Augmenter la vitesse',
			'settings.keybinding.actionSpeedDown' => 'Réduire la vitesse',
			'settings.keybinding.actionSeekForward' => 'Avancer',
			'settings.keybinding.actionSeekBackward' => 'Reculer',
			'settings.keybinding.actionVolumeUp' => 'Monter le volume',
			'settings.keybinding.actionVolumeDown' => 'Baisser le volume',
			'settings.keybinding.actionToggleMute' => 'Activer/couper le son',
			'settings.keybinding.actionToggleFullscreen' => 'Basculer en plein écran',
			'settings.keybinding.seekLongPressHint' => 'Maintenez la touche avancer/reculer pour déclencher la vitesse en appui long',
			'settings.keybinding.zoomSectionTitle' => 'Zoom de l\'image (fixe)',
			'settings.keybinding.zoomFixedNote' => 'Les raccourcis ci-dessous sont fixes et ne peuvent pas être modifiés',
			'settings.keybinding.zoomScaleLabel' => 'Zoomer l\'image',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + molette',
			'settings.keybinding.zoomRotateLabel' => 'Pivoter l\'image',
			'settings.keybinding.zoomRotateHint' => 'Maj + molette',
			'settings.keybinding.zoomPinchGesture' => 'Pincer',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Rotation à deux doigts',
			'settings.gestureControl' => 'Contrôle gestuel',
			'settings.leftDoubleTapRewind' => 'Double tap à gauche : reculer',
			'settings.rightDoubleTapFastForward' => 'Double tap à droite : avance rapide',
			'settings.doubleTapPause' => 'Pause au double tap',
			'settings.rightVerticalSwipeVolume' => 'Glissement vertical à droite : volume (effectif à l\'ouverture d\'une nouvelle page)',
			'settings.leftVerticalSwipeBrightness' => 'Glissement vertical à gauche : luminosité (effectif à l\'ouverture d\'une nouvelle page)',
			'settings.longPressFastForward' => 'Appui long : avance rapide',
			'settings.enableMouseHoverShowToolbar' => 'Afficher la barre d\'outils au survol de la souris',
			'settings.enableMouseHoverShowToolbarInfo' => 'Une fois activé, la barre d\'outils vidéo s\'affiche lorsque la souris survole le lecteur. Elle se masque automatiquement après 3 secondes d\'inactivité.',
			'settings.enableHorizontalDragSeek' => 'Balayage horizontal pour naviguer',
			'settings.enableVideoGestureZoom' => 'Pincer pour zoomer l\'image vidéo',
			'settings.enableVideoGestureZoomInfo' => 'Pincez avec deux doigts (ou Ctrl + molette sur ordinateur) pour zoomer l\'image vidéo, puis faites glisser pour la déplacer.',
			'settings.showCenterPlayPauseButton' => 'Bouton lecture/pause au centre',
			'settings.showCenterPlayPauseButtonDesc' => 'Afficher le grand bouton lecture/pause au centre du lecteur.',
			'settings.audioVideoConfig' => 'Configuration audio et vidéo',
			'settings.expandBuffer' => 'Étendre le tampon',
			'settings.expandBufferInfo' => 'Une fois activé, la taille du tampon augmente : le chargement est plus long, mais la lecture plus fluide',
			'settings.videoSyncMode' => 'Mode de synchro A/V',
			'settings.videoSyncModeSubtitle' => 'Stratégie de synchronisation audio-vidéo',
			'settings.hardwareDecodingMode' => 'Mode de décodage matériel',
			'settings.hardwareDecodingModeSubtitle' => 'Paramètres de décodage matériel',
			'settings.enableHardwareAcceleration' => 'Activer l\'accélération matérielle',
			'settings.enableHardwareAccelerationInfo' => 'Activer l\'accélération matérielle peut améliorer les performances de décodage, mais certains appareils peuvent être incompatibles',
			'settings.useOpenSLESAudioOutput' => 'Utiliser la sortie audio OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'Utiliser une sortie audio à faible latence, peut améliorer les performances audio',
			'settings.videoSyncAudio' => 'Synchro audio',
			'settings.videoSyncDisplayResample' => 'Afficher le rééchantillonnage',
			'settings.videoSyncDisplayResampleVdrop' => 'Afficher rééchantillonnage (perte de trames)',
			'settings.videoSyncDisplayResampleDesync' => 'Afficher rééchantillonnage (désynchro)',
			'settings.videoSyncDisplayTempo' => 'Afficher le tempo',
			'settings.videoSyncDisplayVdrop' => 'Afficher : perte de trames vidéo',
			'settings.videoSyncDisplayAdrop' => 'Afficher : perte de trames audio',
			'settings.videoSyncDisplayDesync' => 'Afficher la désynchro',
			'settings.videoSyncDesync' => 'Désynchro',
			'settings.forumSettings.name' => 'Forum',
			'settings.forumSettings.configureYourForumSettings' => 'Configurez les paramètres du forum',
			'settings.gallerySettings.gallerySettingsTitle' => 'Paramètres de galerie',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Configurer les préférences de la visionneuse',
			'settings.gallerySettings.defaultViewerQuality' => 'Qualité d\'affichage par défaut',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Choisir la qualité d\'image affichée par défaut à l\'ouverture de la visionneuse.',
			'settings.blockSettings.title' => 'Blocage de contenu',
			'settings.blockSettings.subtitle' => 'Masquer automatiquement les vidéos et galeries dont le titre correspond à un mot-clé ou à un motif, ou qui proviennent d\'un utilisateur bloqué. Tout le filtrage a lieu sur votre appareil — rien n\'est envoyé.',
			'settings.blockSettings.blocked' => 'Bloqué',
			'settings.blockSettings.reveal' => 'Afficher',
			'settings.blockSettings.reblock' => 'Bloquer à nouveau',
			'settings.blockSettings.why' => 'Pourquoi bloqué ?',
			'settings.blockSettings.manageRules' => 'Gérer les règles',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'Le titre contient « ${value} »',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'Le titre correspond à « ${value} »',
			'settings.blockSettings.reasonUser' => 'D\'un utilisateur bloqué',
			'settings.blockSettings.addRule' => 'Ajouter une règle',
			'settings.blockSettings.editRule' => 'Modifier la règle',
			'settings.blockSettings.deleteRule' => 'Supprimer la règle',
			'settings.blockSettings.ruleType' => 'Type de règle',
			'settings.blockSettings.keyword' => 'Mot-clé',
			'settings.blockSettings.regex' => 'Regex',
			'settings.blockSettings.userId' => 'Utilisateur',
			'settings.blockSettings.value' => 'Texte à faire correspondre',
			'settings.blockSettings.caseSensitive' => 'Sensible à la casse',
			'settings.blockSettings.regexHint' => 'ex. trailer|teaser',
			'settings.blockSettings.valueRequired' => 'Veuillez saisir le texte à faire correspondre',
			'settings.blockSettings.invalidRegex' => 'Ce n\'est pas une expression régulière valide',
			'settings.blockSettings.noRules' => 'Aucune règle pour l\'instant. Touchez + pour en ajouter une.',
			'settings.blockSettings.blockUser' => 'Bloquer',
			'settings.blockSettings.unblockUser' => 'Débloquer',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => 'Bloquer « ${name} » ? Ses vidéos et galeries seront masquées des listes et de la recherche.',
			'settings.blockSettings.userBlocked' => 'Utilisateur bloqué',
			'settings.blockSettings.userUnblocked' => 'Utilisateur débloqué',
			'settings.blockSettings.exportRules' => 'Exporter',
			'settings.blockSettings.importRules' => 'Importer',
			'settings.blockSettings.importExport' => 'Importer / Exporter',
			'settings.blockSettings.exportSuccess' => 'Règles exportées',
			'settings.blockSettings.exportFailed' => 'Échec de l\'export des règles',
			'settings.blockSettings.importSuccess' => ({required Object count}) => '${count} règle(s) importée(s)',
			'settings.blockSettings.importFailed' => 'Échec de l\'import des règles',
			'settings.blockSettings.regexHelp' => 'Aide sur les motifs',
			'settings.blockSettings.regexHelpTitle' => 'Référence regex',
			'settings.blockSettings.regexHelpIntro' => 'Une expression régulière filtre les titres de façon plus souple qu\'un simple mot-clé. Voici quelques exemples courants :',
			'settings.blockSettings.regexHelpTapHint' => 'Touchez un exemple pour le reprendre.',
			'settings.blockSettings.regexEx1Pattern' => 'bande-annonce|teaser|bonus',
			'settings.blockSettings.regexEx1Desc' => 'Correspond à l\'un de ces mots ("|" signifie "ou")',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Titres qui commencent par [crochets]',
			'settings.blockSettings.regexEx3Pattern' => 'Intégrale\$',
			'settings.blockSettings.regexEx3Desc' => 'Titres qui se terminent par « Intégrale »',
			'settings.blockSettings.regexEx4Pattern' => 'Ep.[0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ correspond à un ou plusieurs chiffres — correspond à « Ep.12 »',
			'settings.blockSettings.regexEx5Pattern' => '[0-9]{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9] correspond à un chiffre et {4} signifie quatre d\'affilée (p. ex. une année)',
			'settings.blockSettings.regexEx1Sample' => 'Nouvelle bande-annonce disponible',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Film complet',
			'settings.blockSettings.regexEx3Sample' => 'Intégrale d\'art du printemps',
			'settings.blockSettings.regexEx4Sample' => 'Récapitulatif Ep.12 de ma série',
			'settings.blockSettings.regexEx5Sample' => 'Le meilleur de 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'Titre d\'exemple',
			'settings.blockSettings.regexHelpMatchedTag' => 'Bloqué',
			'settings.blockSettings.regexHelpNoMatch' => 'Aucune correspondance',
			'settings.blockSettings.regexEx6Pattern' => '[Ss]aison',
			'settings.blockSettings.regexEx6Desc' => '[Ss] correspond à un S majuscule ou minuscule — ici il attrape « Saison »',
			'settings.blockSettings.regexEx6Sample' => 'Bande-annonce de la dernière saison',
			'settings.blockSettings.regexEx7Pattern' => '(le film|la série)',
			'settings.blockSettings.regexEx7Desc' => 'Les parenthèses () regroupent des alternatives — correspond à « le film » ou « la série »',
			'settings.blockSettings.regexEx7Sample' => 'Regarder la série maintenant',
			'settings.blockSettings.regexEx8Pattern' => 'saisons?',
			'settings.blockSettings.regexEx8Desc' => 's? rend la lettre précédente facultative — correspond à « saison » et « saisons »',
			'settings.blockSettings.regexEx8Sample' => 'Pack de deux saisons',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ signifie un ou plusieurs — correspond à !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'OMG !!! À voir absolument',
			'settings.blockSettings.regexEx10Pattern' => 'bonus.*scène',
			'settings.blockSettings.regexEx10Desc' => '.* correspond à n\'importe quel texte entre les deux — « bonus … scène »',
			'settings.blockSettings.regexEx10Sample' => 'Scène bonus supprimée',
			'settings.chatSettings.name' => 'Discussion',
			'settings.chatSettings.configureYourChatSettings' => 'Configurez vos paramètres de discussion',
			'settings.hardwareDecodingAuto' => 'Auto',
			'settings.hardwareDecodingAutoCopy' => 'Copie auto.',
			'settings.hardwareDecodingAutoSafe' => 'Auto sûr',
			'settings.hardwareDecodingNo' => 'Désactivé',
			'settings.hardwareDecodingYes' => 'Forcer l\'activation',
			'settings.cdnDistributionStrategy' => 'Stratégie de distribution du contenu',
			'settings.cdnDistributionStrategyDesc' => 'Choisir la stratégie de distribution des serveurs sources pour optimiser la vitesse de chargement',
			'settings.cdnDistributionStrategyLabel' => 'Stratégie de distribution',
			'settings.cdnDistributionStrategyNoChange' => 'Aucun changement (serveur d\'origine)',
			'settings.cdnDistributionStrategyAuto' => 'Sélection auto. (serveur le plus rapide)',
			'settings.cdnDistributionStrategySpecial' => 'Spécifier le serveur',
			'settings.cdnSpecialServer' => 'Spécifier le serveur',
			'settings.cdnRefreshServerListHint' => 'Veuillez cliquer sur le bouton ci-dessous pour actualiser la liste des serveurs',
			'settings.cdnRefreshButton' => 'Actualiser',
			'settings.cdnFastRingServers' => 'Serveurs Fast Ring',
			'settings.cdnRefreshServerListTooltip' => 'Actualiser la liste des serveurs',
			'settings.cdnSpeedTestButton' => 'Test de vitesse',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Test (${count})',
			'settings.cdnNoServerDataHint' => 'Aucune donnée de serveur, veuillez cliquer sur le bouton d\'actualisation',
			'settings.cdnTestingStatus' => 'Test en cours',
			'settings.cdnUnreachableStatus' => 'Injoignable',
			'settings.cdnNotTestedStatus' => 'Non testé',
			'settings.downloadSettings.downloadSettings' => 'Paramètres de téléchargement',
			'settings.downloadSettings.enableDownloadNotifications' => 'Notifications de téléchargement',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Afficher une notification système lorsqu\'un téléchargement se termine ou échoue',
			'settings.downloadSettings.notificationPermissionDenied' => 'Autorisation de notification refusée. Les notifications dans l\'app fonctionnent toujours ; activez les notifications système dans les réglages.',
			'settings.downloadSettings.storagePermissionStatus' => 'État de l\'autorisation de stockage',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'L\'accès au dossier public nécessite l\'autorisation de stockage',
			'settings.downloadSettings.checkingPermissionStatus' => 'Vérification de l\'état des autorisations...',
			'settings.downloadSettings.storagePermissionGranted' => 'Autorisation de stockage accordée',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Autorisation de stockage non accordée',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Autorisation de stockage accordée',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Échec de l\'octroi de l\'autorisation de stockage ; certaines fonctions peuvent être limitées',
			'settings.downloadSettings.storagePermissionRationale' => 'Pour enregistrer les téléchargements dans le dossier choisi, l\'app a besoin d\'un accès au stockage.\n\nSur Android 11 et versions ultérieures, cela correspond à l\'autorisation « Accès à tous les fichiers » ; sans elle, les fichiers sont enregistrés dans le dossier privé de l\'app.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Pour enregistrer les téléchargements dans le dossier choisi, l\'app a besoin d\'un accès au stockage.\n\nSans cela, les fichiers sont enregistrés dans le dossier privé de l\'app.',
			'settings.downloadSettings.grantStoragePermission' => 'Accorder l\'autorisation de stockage',
			'settings.downloadSettings.customDownloadPath' => 'Chemin de téléchargement personnalisé',
			'settings.downloadSettings.customDownloadPathDescription' => 'Une fois activé, vous pouvez choisir un emplacement d\'enregistrement personnalisé pour les fichiers téléchargés',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Astuce : sélectionner des dossiers publics (comme Téléchargements) nécessite l\'autorisation de stockage ; privilégiez d\'abord les chemins recommandés',
			'settings.downloadSettings.androidWarning' => 'Note Android : évitez de sélectionner des dossiers publics (comme Téléchargements) ; privilégiez les dossiers propres à l\'app pour garantir les autorisations d\'accès.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Remarque : vous avez sélectionné un dossier public ; l\'autorisation de stockage est requise pour télécharger normalement les fichiers',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Autorisation de stockage requise pour les dossiers publics',
			'settings.downloadSettings.currentDownloadPath' => 'Chemin de téléchargement actuel',
			'settings.downloadSettings.actualDownloadPath' => 'Chemin de téléchargement réel',
			'settings.downloadSettings.defaultAppDirectory' => 'Dossier d\'app par défaut',
			'settings.downloadSettings.permissionGranted' => 'Accordée',
			'settings.downloadSettings.permissionRequired' => 'Autorisation requise',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Activer le chemin personnalisé',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Utiliser le chemin d\'app par défaut si désactivé',
			'settings.downloadSettings.customDownloadPathLabel' => 'Chemin de téléchargement personnalisé',
			'settings.downloadSettings.selectDownloadFolder' => 'Sélectionner le dossier de téléchargement',
			'settings.downloadSettings.recommendedPath' => 'Chemin recommandé',
			'settings.downloadSettings.selectFolder' => 'Sélectionner un dossier',
			'settings.downloadSettings.filenameTemplate' => 'Modèle de nom de fichier',
			'settings.downloadSettings.filenameTemplateDescription' => 'Personnaliser les règles de nommage des fichiers téléchargés, avec substitution de variables',
			'settings.downloadSettings.videoFilenameTemplate' => 'Modèle de nom de vidéo',
			'settings.downloadSettings.galleryFolderTemplate' => 'Modèle de dossier de galerie',
			'settings.downloadSettings.imageFilenameTemplate' => 'Modèle de nom d\'image',
			'settings.downloadSettings.resetToDefault' => 'Réinitialiser',
			'settings.downloadSettings.supportedVariables' => 'Variables prises en charge',
			'settings.downloadSettings.supportedVariablesDescription' => 'Les variables suivantes peuvent être utilisées dans les modèles de nom de fichier :',
			'settings.downloadSettings.copyVariable' => 'Copier la variable',
			'settings.downloadSettings.variableCopied' => 'Variable copiée',
			'settings.downloadSettings.warningPublicDirectory' => 'Attention : le dossier public sélectionné peut être inaccessible. Il est conseillé de choisir un dossier propre à l\'app.',
			'settings.downloadSettings.downloadPathUpdated' => 'Chemin de téléchargement mis à jour',
			'settings.downloadSettings.selectPathFailed' => 'Échec de la sélection du chemin',
			'settings.downloadSettings.pickerAlreadyActive' => 'Le sélecteur de dossier est déjà ouvert',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Emplacement de stockage non pris en charge. Choisissez un dossier sur le stockage de l\'appareil ou la carte SD.',
			'settings.downloadSettings.recommendedPathSet' => 'Défini sur le chemin recommandé',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Échec de la définition du chemin recommandé',
			'settings.downloadSettings.templateResetToDefault' => 'Réinitialiser le modèle par défaut',
			'settings.downloadSettings.functionalTest' => 'Test fonctionnel',
			'settings.downloadSettings.testInProgress' => 'Test en cours...',
			'settings.downloadSettings.runTest' => 'Lancer le test',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Vérifier que le chemin de téléchargement et la configuration des autorisations fonctionnent correctement',
			'settings.downloadSettings.testResults' => 'Résultats du test',
			'settings.downloadSettings.testCompleted' => 'Test terminé',
			'settings.downloadSettings.testMultisegmentDomain' => 'Validation du domaine de valeurs (multi-segments / dépassement / formes d\'échappement)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Rendu de la structure multi-segments (issue #126)',
			'settings.downloadSettings.testPassed' => 'éléments réussis',
			'settings.downloadSettings.testFailed' => 'Échec du test',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Vérification de l\'autorisation de stockage',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Autorisation de stockage accordée',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Autorisation de stockage manquante, certaines fonctions peuvent être limitées',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Échec de la vérification des autorisations',
			'settings.downloadSettings.testDownloadPathValidation' => 'Validation du chemin de téléchargement',
			'settings.downloadSettings.testPathValidationFailed' => 'Échec de la validation du chemin',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Validation du modèle de nom de fichier',
			'settings.downloadSettings.testAllTemplatesValid' => 'Tous les modèles sont valides',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Certains modèles contiennent des caractères non valides',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Échec de la validation du modèle',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Test des opérations sur dossier',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'La création de dossier et l\'écriture de fichier fonctionnent normalement',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Échec de l\'opération sur le dossier',
			'settings.downloadSettings.testVideoTemplate' => 'Modèle de vidéo',
			'settings.downloadSettings.testGalleryTemplate' => 'Modèle de galerie',
			'settings.downloadSettings.testImageTemplate' => 'Modèle d\'image',
			'settings.downloadSettings.testValid' => 'Valide',
			'settings.downloadSettings.testInvalid' => 'Invalide',
			'settings.downloadSettings.testSuccess' => 'Réussi',
			'settings.downloadSettings.testCorrect' => 'Correct',
			'settings.downloadSettings.testError' => 'Erreur',
			'settings.downloadSettings.testPath' => 'Chemin de test',
			'settings.downloadSettings.testBasePath' => 'Chemin de base',
			'settings.downloadSettings.testDirectoryCreation' => 'Création de dossier',
			'settings.downloadSettings.testFileWriting' => 'Écriture de fichier',
			'settings.downloadSettings.testFileContent' => 'Contenu du fichier',
			'settings.downloadSettings.checkingPathStatus' => 'Vérification de l\'état du chemin...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Impossible d\'obtenir l\'état du chemin',
			_ => null,
		} ?? switch (path) {
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Remarque : le chemin réel diffère du chemin sélectionné',
			'settings.downloadSettings.grantPermission' => 'Accorder l\'autorisation',
			'settings.downloadSettings.fixIssue' => 'Corriger le problème',
			'settings.downloadSettings.issueFixed' => 'Problème corrigé',
			'settings.downloadSettings.fixFailed' => 'Échec de la correction, veuillez agir manuellement',
			'settings.downloadSettings.lackStoragePermission' => 'Autorisation de stockage manquante',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Impossible d\'accéder au dossier public ; l\'autorisation « Accès à tous les fichiers » est requise',
			'settings.downloadSettings.cannotCreateDirectory' => 'Impossible de créer le dossier',
			'settings.downloadSettings.directoryNotWritable' => 'Dossier non accessible en écriture',
			'settings.downloadSettings.insufficientSpace' => 'Espace disponible insuffisant',
			'settings.downloadSettings.pathValid' => 'Chemin valide',
			'settings.downloadSettings.validationFailed' => 'Échec de la validation',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Utilisation du dossier d\'app par défaut',
			'settings.downloadSettings.appPrivateDirectory' => 'Dossier privé de l\'app',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Sûr et fiable, aucune autorisation supplémentaire requise',
			'settings.downloadSettings.downloadDirectory' => 'Dossier de téléchargement',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Emplacement de téléchargement par défaut du système, facile à gérer',
			'settings.downloadSettings.moviesDirectory' => 'Dossier Films',
			'settings.downloadSettings.moviesDirectoryDesc' => 'Dossier Films du système, reconnu par les applis multimédias',
			'settings.downloadSettings.documentsDirectory' => 'Dossier Documents',
			'settings.downloadSettings.documentsDirectoryDesc' => 'Dossier Documents de l\'app iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'Nécessite l\'autorisation de stockage pour y accéder',
			'settings.downloadSettings.recommendedPaths' => 'Chemins recommandés',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Dossier privé de l\'app (externe)',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Dossier privé de l\'app sur le stockage externe, accessible à l\'utilisateur, plus d\'espace',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Dossier privé de l\'app (interne)',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Stockage interne de l\'app, aucune autorisation requise, moins d\'espace',
			'settings.downloadSettings.appDocumentsDirectory' => 'Dossier de documents de l\'app',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'Dossier de documents propre à l\'app, sûr et fiable',
			'settings.downloadSettings.downloadsFolder' => 'Dossier Téléchargements',
			'settings.downloadSettings.downloadsFolderDesc' => 'Dossier de téléchargement par défaut du système',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Sélectionner un emplacement de téléchargement recommandé',
			'settings.downloadSettings.noRecommendedPaths' => 'Aucun chemin recommandé disponible',
			'settings.downloadSettings.recommended' => 'Recommandé',
			'settings.downloadSettings.requiresPermission' => 'Autorisation requise',
			'settings.downloadSettings.authorizeAndSelect' => 'Autoriser et sélectionner',
			'settings.downloadSettings.select' => 'Sélectionner',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Échec de l\'autorisation, impossible de sélectionner ce chemin',
			'settings.downloadSettings.pathValidationFailed' => 'Échec de la validation du chemin',
			'settings.downloadSettings.downloadPathSetTo' => 'Chemin de téléchargement défini sur',
			'settings.downloadSettings.setPathFailed' => 'Échec de la définition du chemin',
			'settings.downloadSettings.variableTitle' => 'Titre',
			'settings.downloadSettings.variableAuthorcache' => 'Premier nom vu de l\'auteur (stable malgré les renommages)',
			'settings.downloadSettings.variableAuthor' => 'Nom de l\'auteur',
			'settings.downloadSettings.variableUsername' => 'Nom d\'utilisateur de l\'auteur',
			'settings.downloadSettings.variableQuality' => 'Qualité de la vidéo',
			'settings.downloadSettings.variableFilename' => 'Nom de fichier d\'origine',
			'settings.downloadSettings.variableId' => 'ID du contenu',
			'settings.downloadSettings.variableCount' => 'Nombre d\'images de la galerie',
			'settings.downloadSettings.variableDate' => 'Date actuelle (AAAA-MM-JJ)',
			'settings.downloadSettings.variableTime' => 'Heure actuelle (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Date et heure actuelles (AAAA-MM-JJ_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Paramètres de téléchargement',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Configurer le chemin de téléchargement et les règles de nommage des fichiers',
			'settings.downloadSettings.suchAsTitleQuality' => 'Par exemple : %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Par exemple : %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Par exemple : %title_%filename',
			'settings.downloadSettings.structureSection' => 'Structure de sauvegarde et nommage',
			'settings.downloadSettings.structureSectionDescription' => 'Les fichiers téléchargés sont rangés en sous-dossiers selon le mode choisi ci-dessous. Ne concerne que les nouveaux téléchargements, les fichiers existants restent en place.',
			'settings.downloadSettings.structureNoticeTitle' => 'Nouveau : classement automatique par auteur',
			'settings.downloadSettings.structureNoticeBody' => 'Choisissez ci-dessous · ne concerne que les nouveaux téléchargements, les fichiers existants restent en place.',
			'settings.downloadSettings.presetFlat' => 'À plat',
			'settings.downloadSettings.presetFlatDesc' => 'Tous les fichiers directement à la racine des téléchargements',
			'settings.downloadSettings.presetAuthor' => 'Par auteur',
			'settings.downloadSettings.presetAuthorBadge' => 'Recommandé',
			'settings.downloadSettings.presetAuthorDesc' => 'Un dossier par auteur · reste stable même si le pseudo change',
			'settings.downloadSettings.presetDate' => 'Par date',
			'settings.downloadSettings.presetDateDesc' => 'Regroupé par date de téléchargement',
			'settings.downloadSettings.presetCustomActive' => 'Actif',
			'settings.downloadSettings.structurePreviewLabel' => 'Aperçu',
			'settings.downloadSettings.structurePreviewNote' => 'Les segments colorés sont les niveaux de rangement, ils suivent le mode choisi.',
			'settings.downloadSettings.pathTooLongWarning' => 'Le chemin relatif dépasse 200 caractères, la sauvegarde peut échouer sur certains appareils',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Modèle de chemin personnalisé',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Décidez vous-même des dossiers et du nommage des fichiers',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Modèle de chemin',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Range automatiquement les téléchargements en sous-dossiers',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Vidéo',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Galerie',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Image unique',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Aperçu · résultat réel après nettoyage',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Aperçu · le modèle de galerie nomme le dossier (les images internes gardent l\'identifiant de l\'image)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Ajouter un niveau de dossier',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Limite de niveaux de dossier atteinte',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, une variable ou du texte fixe',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'ex. %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'Lextension .mp4 est ajoutée automatiquement · taper / dans un segment le scinde en deux niveaux · jusquà ${max} niveaux',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'Lextension dorigine est ajoutée automatiquement · taper / dans un segment le scinde en deux niveaux · jusquà ${max} niveaux',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'Le modèle de galerie est entièrement des dossiers, jusquà ${max} niveaux · les images internes gardent le nommage par ID',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Touchez pour insérer à la position du curseur · appui long pour les détails',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Segment vide',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'Impossible de sauvegarder : des segments vides subsistent, remplissez-les ou supprimez-les',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'Impossible de sauvegarder : trop de segments de chemin (4 max). Fusionnez ou supprimez-en',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'Impossible de sauvegarder : le modèle contient des caractères non valides',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Variable insérée',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Enregistré · ne concerne que les nouveaux téléchargements',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Contenu',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Auteur',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Temps',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Nom de lauteur·fixe',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Date',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Heure',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Date et heure',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Index',
			'favoriteTags.title' => 'Tags favoris',
			'favoriteTags.emptyIwara' => 'Aucun tag Iwara favori pour l\'instant',
			'favoriteTags.emptyOreno3d' => 'Aucun favori pour l\'instant',
			'favoriteTags.addIwaraTag' => 'Ajouter un tag Iwara',
			'favoriteTags.quickPickHint' => 'Les éléments mis en favori apparaissent comme suggestions rapides dans la recherche.',
			'favoriteTags.pickerTitle' => 'Sélectionner Oreno3D',
			'favoriteTags.searchHint' => 'Rechercher par nom ou original',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('fr'))(n, one: '${n} œuvre', other: '${n} œuvres', ), 
			'favoriteTags.browseEntry' => 'Parcourir origine / personnage / tag',
			'favoriteTags.favoritesSection' => 'Favoris',
			'favoriteTags.addFavorite' => 'Ajouter',
			'favoriteTags.iwaraTitle' => 'Tags Iwara favoris',
			'favoriteTags.oreno3dTitle' => 'Tags Oreno3D favoris',
			'favoriteTags.changeTag' => 'Changer de tag',
			'favoriteTags.switchToText' => 'Recherche textuelle',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Tags',
			'oreno3d.characters' => 'Personnages',
			'oreno3d.origin' => 'Origine',
			'oreno3d.thirdPartyTagsExplanation' => 'Les informations de **tags**, **personnages** et **origine** affichées ici proviennent du site tiers **Oreno3D** et sont fournies à titre indicatif.\n\nCette source n\'étant disponible qu\'en japonais, elle n\'est pas encore adaptée à l\'internationalisation.\n\nSi vous souhaitez contribuer à l\'internationalisation, rendez-vous sur le dépôt pour nous aider à l\'améliorer.',
			'oreno3d.sortTypes.hot' => 'Tendance',
			'oreno3d.sortTypes.favorites' => 'Favoris',
			'oreno3d.sortTypes.latest' => 'Récents',
			'oreno3d.sortTypes.popularity' => 'Popularité',
			'oreno3d.errors.requestFailed' => 'Échec de la requête, code d\'état',
			'oreno3d.errors.connectionTimeout' => 'Délai de connexion dépassé, veuillez vérifier votre connexion réseau',
			'oreno3d.errors.sendTimeout' => 'Délai d\'envoi de la requête dépassé',
			'oreno3d.errors.receiveTimeout' => 'Délai de réception de la réponse dépassé',
			'oreno3d.errors.badCertificate' => 'Échec de la vérification du certificat',
			'oreno3d.errors.resourceNotFound' => 'Ressource demandée introuvable',
			'oreno3d.errors.accessDenied' => 'Accès refusé ; une authentification ou une autorisation peut être requise',
			'oreno3d.errors.serverError' => 'Erreur interne du serveur',
			'oreno3d.errors.serviceUnavailable' => 'Service temporairement indisponible',
			'oreno3d.errors.requestCancelled' => 'Requête annulée',
			'oreno3d.errors.connectionError' => 'Erreur de connexion réseau, veuillez vérifier vos paramètres réseau',
			'oreno3d.errors.networkRequestFailed' => 'Échec de la requête réseau',
			'oreno3d.errors.searchVideoError' => 'Une erreur inconnue est survenue lors de la recherche de vidéos',
			'oreno3d.errors.getPopularVideoError' => 'Une erreur inconnue est survenue lors de la récupération des vidéos populaires',
			'oreno3d.errors.getVideoDetailError' => 'Une erreur inconnue est survenue lors de la récupération des détails de la vidéo',
			'oreno3d.errors.parseVideoDetailError' => 'Une erreur inconnue est survenue lors de la récupération et de l\'analyse des détails de la vidéo',
			'oreno3d.errors.downloadFileError' => 'Une erreur inconnue est survenue lors du téléchargement du fichier',
			'oreno3d.loading.gettingVideoInfo' => 'Récupération des informations de la vidéo...',
			'oreno3d.loading.cancel' => 'Annuler',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Vidéo introuvable ou supprimée',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Impossible d\'obtenir le lien de lecture de la vidéo',
			'oreno3d.messages.getVideoDetailFailed' => 'Échec de la récupération des détails de la vidéo',
			'signIn.pleaseLoginFirst' => 'Veuillez d\'abord vous connecter',
			'signIn.alreadySignedInToday' => 'Vous vous êtes déjà connecté aujourd\'hui !',
			'signIn.youDidNotStickToTheSignIn' => 'Vous n\'avez pas maintenu la connexion quotidienne.',
			'signIn.signInSuccess' => 'Connexion réussie !',
			'signIn.signInFailed' => 'Échec de la connexion, veuillez réessayer plus tard',
			'signIn.consecutiveSignIns' => 'Connexions consécutives',
			'signIn.failureReason' => 'Motif de l\'échec',
			'signIn.selectDateRange' => 'Sélectionner une plage de dates',
			'signIn.startDate' => 'Date de début',
			'signIn.endDate' => 'Date de fin',
			'signIn.invalidDate' => 'Date non valide',
			'signIn.invalidDateRange' => 'Plage de dates non valide',
			'signIn.errorFormatText' => 'Erreur de format de date',
			'signIn.errorInvalidText' => 'Plage de dates non valide',
			'signIn.errorInvalidRangeText' => 'Plage de dates non valide',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'La plage de dates ne peut pas dépasser un an',
			'signIn.signIn' => 'Se connecter',
			'signIn.signInRecord' => 'Historique des connexions',
			'signIn.totalSignIns' => 'Total des connexions',
			'signIn.pleaseSelectSignInStatus' => 'Veuillez sélectionner l\'état de connexion',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Veuillez d\'abord vous connecter pour voir vos abonnements.',
			'subscriptions.selectUser' => 'Sélectionner un utilisateur',
			'subscriptions.noSubscribedUsers' => 'Aucun utilisateur abonné',
			'subscriptions.showAllSubscribedUsersContent' => 'Afficher le contenu de tous les utilisateurs abonnés',
			'videoDetail.pipMode' => 'Mode PiP',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Reprendre à la dernière position : ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Reprise à ${position}',
			'videoDetail.restartFromBeginning' => 'Recommencer',
			'videoDetail.dismissResumeTip' => 'Ignorer',
			'videoDetail.localInfo.videoInfo' => 'Infos de la vidéo',
			'videoDetail.localInfo.currentQuality' => 'Qualité actuelle',
			'videoDetail.localInfo.duration' => 'Durée',
			'videoDetail.localInfo.resolution' => 'Résolution',
			'videoDetail.localInfo.fileInfo' => 'Infos du fichier',
			'videoDetail.localInfo.fileName' => 'Nom du fichier',
			'videoDetail.localInfo.fileSize' => 'Taille du fichier',
			'videoDetail.localInfo.filePath' => 'Chemin du fichier',
			'videoDetail.localInfo.copyPath' => 'Copier le chemin',
			'videoDetail.localInfo.openFolder' => 'Ouvrir le dossier',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Chemin copié dans le presse-papiers',
			'videoDetail.localInfo.openFolderFailed' => 'Échec de l\'ouverture du dossier',
			'videoDetail.videoIdIsEmpty' => 'L\'ID de la vidéo est vide',
			'videoDetail.videoInfoIsEmpty' => 'Les informations de la vidéo sont vides',
			'videoDetail.thisIsAPrivateVideo' => 'Ceci est une vidéo privée',
			'videoDetail.getVideoInfoFailed' => 'Échec de l\'obtention des informations de la vidéo, veuillez réessayer plus tard',
			'videoDetail.noVideoSourceFound' => 'Aucune source vidéo trouvée',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Tag « ${tagId} » copié dans le presse-papiers',
			'videoDetail.errorLoadingVideo' => 'Erreur de chargement de la vidéo',
			'videoDetail.play' => 'Lire',
			'videoDetail.pause' => 'Pause',
			'videoDetail.exitAppFullscreen' => 'Quitter le plein écran de l\'app',
			'videoDetail.enterAppFullscreen' => 'Plein écran de l\'app',
			'videoDetail.exitSystemFullscreen' => 'Quitter le plein écran système',
			'videoDetail.enterSystemFullscreen' => 'Plein écran système',
			'videoDetail.seekTo' => 'Aller à',
			'videoDetail.switchResolution' => 'Changer la résolution',
			'videoDetail.switchPlaybackSpeed' => 'Changer la vitesse de lecture',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Reculer de ${num} secondes',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Avance rapide de ${num} secondes',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Lecture à ${rate}x',
			'videoDetail.brightness' => 'Luminosité',
			'videoDetail.brightnessLowest' => 'Luminosité minimale',
			'videoDetail.volume' => 'Volume',
			'videoDetail.volumeMuted' => 'Le son est coupé',
			'videoDetail.restoreDefaultZoom' => 'Restaurer',
			'videoDetail.gestureGuide.sampleVideo' => 'Vidéo d\'exemple',
			'videoDetail.gestureGuide.title' => 'Guide des gestes et interactions',
			'videoDetail.gestureGuide.viewGuide' => 'Guide des gestes et interactions',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Prenez quelques secondes pour découvrir les gestes du lecteur. Vous pouvez rouvrir ce guide à tout moment depuis les paramètres du lecteur.',
			'videoDetail.gestureGuide.startWatching' => 'Compris, commencer à regarder',
			'videoDetail.gestureGuide.basicTitle' => 'Commandes de base',
			'videoDetail.gestureGuide.zoomTitle' => 'Zoom / Rotation / Déplacement',
			'videoDetail.gestureGuide.restoreTip' => 'Touchez le bouton « Restaurer » en bas à droite pour réinitialiser le zoom, la rotation et la position.',
			'videoDetail.gestureGuide.mTap' => 'Appui simple : afficher / masquer les contrôles',
			'videoDetail.gestureGuide.mDoubleTap' => 'Double tap : reculer (gauche) / pause (centre) / avance rapide (droite)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Balayage horizontal : naviguer',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Balayage vertical : luminosité (gauche) / volume (droite)',
			'videoDetail.gestureGuide.mLongPress' => 'Appui long : accélération temporaire',
			'videoDetail.gestureGuide.mPinch' => 'Pincement à deux doigts : zoomer l\'image',
			'videoDetail.gestureGuide.mRotate' => 'Rotation à deux doigts : pivoter l\'image',
			'videoDetail.gestureGuide.dTap' => 'Clic : afficher / masquer les contrôles',
			'videoDetail.gestureGuide.dDoubleTap' => 'Double clic : reculer (gauche) / pause (centre) / avance rapide (droite)',
			'videoDetail.gestureGuide.dKeys' => 'Touches de navigation : appuyez pour reculer/avancer, maintenez pour accélérer ; touches de vitesse : ajustent la vitesse en lecture normale ; Espace : lecture / pause',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Pincement sur pavé tactile : zoomer l\'image',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Rotation sur pavé tactile : pivoter l\'image',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + molette : zoom autour du curseur',
			'videoDetail.gestureGuide.dShiftWheel' => 'Maj + molette : rotation autour du curseur',
			'videoDetail.gestureGuide.quest.title' => 'Prendre ses repères dans Quest',
			'videoDetail.gestureGuide.quest.intro' => 'Découvrez à quoi sert chaque commande, puis essayez-la dans votre espace.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Vidéo spatiale',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Galerie spatiale',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Pour les écrans et fenêtres dans votre espace Quest. Rouvrez à tout moment depuis les paramètres du lecteur.',
			'videoDetail.gestureGuide.quest.catalog' => 'Découvrir les commandes',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} sur ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Précédent',
			'videoDetail.gestureGuide.quest.next' => 'Commande suivante',
			'videoDetail.gestureGuide.quest.replay' => 'Rejouer la démo',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Mettre la démo en pause',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Reprendre la démo',
			'videoDetail.gestureGuide.quest.looping' => 'Démo de la commande',
			'videoDetail.gestureGuide.quest.still' => 'Illustration fixe',
			'videoDetail.gestureGuide.quest.done' => 'Compris, continuer',
			'videoDetail.gestureGuide.quest.leftController' => 'Main gauche',
			'videoDetail.gestureGuide.quest.rightController' => 'Main droite',
			'videoDetail.gestureGuide.quest.trigger' => 'Gâchette d\'index',
			'videoDetail.gestureGuide.quest.grip' => 'Bouton de préhension',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Les deux boutons de préhension',
			'videoDetail.gestureGuide.quest.stick' => 'Stick',
			'videoDetail.gestureGuide.quest.handTracking' => 'Suivi des mains',
			'videoDetail.gestureGuide.quest.ready' => 'Prêt',
			'videoDetail.gestureGuide.quest.press' => 'Appuyer',
			'videoDetail.gestureGuide.quest.hold' => 'Maintenir',
			'videoDetail.gestureGuide.quest.release' => 'Relâcher',
			'videoDetail.gestureGuide.quest.result' => 'Voir le résultat',
			'videoDetail.gestureGuide.quest.pinch' => 'Pincer',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Pointer et sélectionner',
			'videoDetail.gestureGuide.quest.selectBody' => 'Visez un bouton avec le rayon, puis appuyez et relâchez la gâchette d\'index. Utilisez-la pour la lecture, les réglages et les curseurs du panneau de contrôle.',
			'videoDetail.gestureGuide.quest.selectHint' => 'La gâchette d\'index se trouve derrière la face du bouton. Le bouton de préhension sur la poignée intérieure saisit les fenêtres.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Afficher ou masquer le panneau',
			'videoDetail.gestureGuide.quest.panelBody' => 'Pointez à l\'extérieur du panneau de contrôle, puis appuyez sur la gâchette d\'index pour l\'afficher ou le masquer. Avec le suivi des mains, un pincement rapide hors du panneau fait la même chose.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Faites une pression brève sans glisser. Maintenir et déplacer est un glissement, pas un basculement du panneau.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Lire et mettre en pause',
			'videoDetail.gestureGuide.quest.playBody' => 'Pointez ailleurs que vers le panneau de contrôle et appuyez sur A à droite ou X à gauche pour lire ou mettre en pause. Vous pouvez aussi sélectionner le bouton de lecture du panneau.',
			'videoDetail.gestureGuide.quest.playHint' => 'Ce raccourci par défaut peut être désactivé dans les paramètres du lecteur spatial. En pointant vers le panneau, la saisie va au panneau.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Se déplacer avec le stick',
			'videoDetail.gestureGuide.quest.seekBody' => 'Poussez légèrement l\'un ou l\'autre stick vers la gauche ou la droite pour avancer de 5 secondes. Maintenez-le pour défiler plus vite tout en prévisualisant le temps cible. Relâchez pour valider la position.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Gardez le rayon de cette manette hors du panneau de contrôle. Un stick pointé vers le panneau le fait défiler à la place.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Parcourir avec le stick',
			'videoDetail.gestureGuide.quest.browseBody' => 'Déplacez l\'un ou l\'autre stick vers la gauche ou la droite pour passer à l\'élément précédent ou suivant ; maintenez pour continuer à parcourir. Vous pouvez aussi sélectionner une vignette dans la bande d\'images.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Les vidéos d\'une galerie sont aussi des éléments. En pointant vers le panneau de contrôle, le stick fait défiler le panneau.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Glisser pour tourner une page',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Visez l\'image, maintenez la gâchette d\'index et faites glisser vers la gauche. Relâchez après l\'indice de changement de page pour avancer ; faites glisser vers la droite pour revenir. Un pincement-glissement fonctionne aussi.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Les images doivent être à 1× pour changer de page en glissant. Les vidéos de galerie le permettent aussi. La scène reste immobile jusqu\'au relâchement.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'Zoomer sur l\'image',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Visez un détail de l\'image, maintenez la gâchette d\'index, puis poussez le stick vers le haut pour zoomer ou vers le bas pour dézoomer. Le zoom est ancré là où vous avez appuyé.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Cela agrandit l\'image dans sa fenêtre. Sans maintenir l\'image, le haut/bas ajuste la distance de visionnage.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Déplacer et restaurer l\'image',
			'videoDetail.gestureGuide.quest.panBody' => 'Une fois zoomé, maintenez la gâchette d\'index et faites glisser pour regarder autour. Double-touchez l\'image pour zoomer à 2,5× ou la restaurer. Avec les mains, pincez deux fois rapidement.',
			'videoDetail.gestureGuide.quest.panHint' => 'Faire glisser déplace une image zoomée. Revenez à 1× avant de faire glisser pour tourner les pages.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Lancer un diaporama',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'Sur une image, A / X démarre ou met en pause le diaporama. Le panneau propose des intervalles de 3, 5, 10 ou 20 secondes et une qualité d\'image standard ou d\'origine.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'Sur une vidéo de galerie, A / X contrôle la lecture de cette vidéo. Le raccourci de la manette doit être activé dans les paramètres.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Saisir et déplacer l\'écran',
			'videoDetail.gestureGuide.quest.moveBody' => 'Maintenez le bouton de préhension sur la poignée intérieure, déplacez le contrôleur pour positionner l\'écran, puis relâchez. Pendant le visionnage, vous pouvez saisir l\'écran sans le viser.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Viser la fenêtre de l\'app ou le panneau de contrôle saisit d\'abord cette fenêtre. Dans une vidéo panoramique, la préhension ajuste l\'orientation.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Redimensionner avec les deux mains',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Maintenez les deux boutons de préhension. Écartez les mains pour agrandir l\'écran, ou rapprochez-les pour le réduire. Avec le suivi des mains, maintenez un pincement dans les deux mains.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Pour les écrans plats ou courbes, y compris la scène de galerie. Gardez les rayons hors du panneau de contrôle. Cela redimensionne tout l\'écran.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Ajuster la distance de visionnage',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Poussez le stick vers le haut pour éloigner l\'écran, ou vers le bas pour le rapprocher. Lorsque vous saisissez une fenêtre, le haut/bas déplace cette fenêtre. Réglez le volume sur le panneau.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Pointez ailleurs que vers le panneau de contrôle. En maintenant une image, le haut/bas devient un zoom d\'image ; pour les vidéos panoramiques, cela ajuste la vue.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Utiliser les bords et les coins',
			'videoDetail.gestureGuide.quest.resizeBody' => 'Le cadre s\'illumine lorsque le rayon approche d\'un bord. Maintenez la gâchette ou pincez sur un bord pour déplacer la fenêtre ; faites glisser un coin pour la redimensionner.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Fonctionne sur la fenêtre de l\'app, le panneau de contrôle et l\'écran. La fenêtre de l\'app change de largeur et de hauteur ; les écrans conservent leurs proportions.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Revenir en arrière et ouvrir les paramètres',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y revient d\'un niveau : ferme une fenêtre contextuelle ou revient à l\'accueil du panneau, masque le panneau, puis revient à l\'app. Le bouton Menu gauche ouvre les paramètres spatiaux.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'Le bouton Meta droit appartient au système. Le recentrage système ramène la vue devant en conservant la taille et la distance de l\'écran.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Utiliser vos mains',
			'videoDetail.gestureGuide.quest.handsBody' => 'Lorsque le suivi des mains est activé, visez un bouton avec le rayon du système, pincez le pouce et l\'index, puis relâchez. Utilisez le panneau pour la lecture, la navigation et les galeries.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Pincez à l\'extérieur pour afficher ou masquer le panneau. Pincez un bord pour déplacer, un coin pour redimensionner, ou pincez avec les deux mains et écartez pour agrandir l\'écran.',
			'videoDetail.home' => 'Accueil',
			'videoDetail.videoPlayer' => 'Lecteur vidéo',
			'videoDetail.videoPlayerInfo' => 'Infos du lecteur vidéo',
			'videoDetail.moreSettings' => 'Plus de paramètres',
			'videoDetail.videoPlayerFeatureInfo' => 'Infos sur les fonctionnalités du lecteur',
			'videoDetail.autoRewind' => 'Retour arrière auto.',
			'videoDetail.rewindAndFastForward' => 'Retour et avance rapide',
			'videoDetail.volumeAndBrightness' => 'Volume et luminosité',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Double tap au centre : pause ou lecture',
			'videoDetail.showVerticalVideoInFullScreen' => 'Afficher les vidéos verticales en plein écran',
			'videoDetail.keepLastVolumeAndBrightness' => 'Conserver le dernier volume et la luminosité',
			'videoDetail.setProxy' => 'Définir le proxy',
			'videoDetail.moreFeaturesToBeDiscovered' => 'D\'autres fonctionnalités à découvrir...',
			'videoDetail.videoPlayerSettings' => 'Paramètres du lecteur vidéo',
			'videoDetail.commentCount' => ({required Object num}) => '${num} commentaires',
			'videoDetail.writeYourCommentHere' => 'Écrivez votre commentaire ici...',
			'videoDetail.authorOtherVideos' => 'Autres vidéos de l\'auteur',
			'videoDetail.relatedVideos' => 'Vidéos associées',
			'videoDetail.privateVideo' => 'Ceci est une vidéo privée',
			'videoDetail.externalVideo' => 'Ceci est une vidéo externe',
			'videoDetail.openInBrowser' => 'Ouvrir dans le navigateur',
			'videoDetail.resourceDeleted' => 'Cette vidéo semble avoir été supprimée :/',
			'videoDetail.noDownloadUrl' => 'Aucune URL de téléchargement',
			'videoDetail.startDownloading' => 'Démarrer le téléchargement',
			'videoDetail.downloadFailed' => 'Échec du téléchargement, veuillez réessayer plus tard',
			'videoDetail.downloadSuccess' => 'Téléchargement réussi',
			'videoDetail.download' => 'Télécharger',
			'videoDetail.downloadManager' => 'Gestionnaire de téléchargements',
			'videoDetail.resourceNotFound' => 'Ressource introuvable',
			'videoDetail.videoLoadError' => 'Erreur de chargement de la vidéo',
			'videoDetail.authorNoOtherVideos' => 'L\'auteur n\'a pas d\'autres vidéos',
			'videoDetail.noRelatedVideos' => 'Aucune vidéo associée',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Erreur lors du chargement de la source vidéo',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Erreur lors de la configuration des écouteurs',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Défaillance du serveur détectée, itinéraire changé automatiquement et nouvelle tentative en cours',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Récupération des informations de la vidéo...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Récupération des sources vidéo...',
			'videoDetail.skeleton.loadingVideo' => 'Chargement de la vidéo...',
			'videoDetail.skeleton.applyingSolution' => 'Application de la solution...',
			'videoDetail.skeleton.addingListeners' => 'Ajout des écouteurs...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Durée de la vidéo récupérée, démarrage du chargement de la vidéo...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Chargement terminé',
			'videoDetail.cast.dlnaCast' => 'Diffuser',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Échec du lancement de la recherche de diffusion : ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Démarrer la diffusion vers ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Échec de la diffusion : ${error}\nVeuillez relancer la recherche d\'appareils ou changer de réseau',
			'videoDetail.cast.castStopped' => 'Diffusion arrêtée',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Lecteur multimédia',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Serveur multimédia',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Routeur',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Appareil de base',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Éclairage connecté',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'Point d\'accès WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'Appareil de connexion WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'Imprimante',
			'videoDetail.cast.deviceTypes.scanner' => 'Scanner',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Caméra de sécurité numérique',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Appareil inconnu',
			'videoDetail.cast.currentPlatformNotSupported' => 'La plateforme actuelle ne prend pas en charge la diffusion',
			'videoDetail.cast.unableToGetVideoUrl' => 'Impossible d\'obtenir l\'URL de la vidéo, veuillez réessayer plus tard',
			'videoDetail.cast.stopCasting' => 'Arrêter la diffusion',
			'videoDetail.cast.dlnaCastSheet.title' => 'Diffusion à distance',
			'videoDetail.cast.dlnaCastSheet.close' => 'Fermer',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Recherche d\'appareils...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Cliquez sur le bouton de recherche pour relancer la recherche d\'appareils de diffusion',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Recherche',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Rechercher à nouveau',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'Aucun appareil de diffusion trouvé\nVeuillez vous assurer que les appareils sont sur le même réseau',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Recherche d\'appareils, veuillez patienter...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Diffuser',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Connecté à : ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Aucun appareil connecté',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Arrêter la diffusion',
			'videoDetail.likeAvatars.dialogTitle' => 'Qui aime en secret',
			'videoDetail.likeAvatars.dialogDescription' => 'Curieux de savoir qui ils sont ? Feuilletez cet « album de J\'aime »~',
			'videoDetail.likeAvatars.closeTooltip' => 'Fermer',
			'videoDetail.likeAvatars.retry' => 'Réessayer',
			'videoDetail.likeAvatars.noLikesYet' => 'Personne n\'est encore apparu ici. Soyez le premier !',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Page ${page} / ${totalPages} · ${totalCount} personnes au total',
			'videoDetail.likeAvatars.prevPage' => 'Page précédente',
			'videoDetail.likeAvatars.nextPage' => 'Page suivante',
			'share.sharePlayList' => 'Partager la playlist',
			'share.wowDidYouSeeThis' => 'Waouh, avez-vous vu ceci ?',
			'share.nameIs' => 'Le nom est',
			'share.clickLinkToView' => 'Cliquez sur le lien pour voir',
			'share.iReallyLikeThis' => 'J\'aime beaucoup ceci',
			'share.shareFailed' => 'Échec du partage, veuillez réessayer plus tard',
			'share.share' => 'Partager',
			'share.shareAsImage' => 'Partager en image',
			'share.shareAsText' => 'Partager en texte',
			'share.shareAsImageDesc' => 'Partager la couverture vidéo sous forme d\'image',
			'share.shareAsTextDesc' => 'Partager les détails de la vidéo en texte',
			'share.shareAsImageFailed' => 'Échec du partage de la couverture vidéo en image, veuillez réessayer plus tard',
			'share.shareAsTextFailed' => 'Échec du partage des détails vidéo en texte, veuillez réessayer plus tard',
			'share.shareVideo' => 'Partager la vidéo',
			'share.authorIs' => 'L\'auteur est',
			'share.shareGallery' => 'Partager la galerie',
			'share.galleryTitleIs' => 'Le titre de la galerie est',
			'share.galleryAuthorIs' => 'L\'auteur de la galerie est',
			'share.shareUser' => 'Partager l\'utilisateur',
			'share.userNameIs' => 'Le nom d\'utilisateur est',
			'share.userAuthorIs' => 'L\'auteur de l\'utilisateur est',
			'share.comments' => 'Commentaires',
			'share.shareThread' => 'Partager le sujet',
			'share.views' => 'Vues',
			'share.sharePost' => 'Partager la publication',
			'share.postTitleIs' => 'Le titre de la publication est',
			'share.postAuthorIs' => 'L\'auteur de la publication est',
			'markdown.markdownSyntax' => 'Syntaxe Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Syntaxe Markdown spéciale Iwara',
			'markdown.internalLink' => 'Lien interne',
			'markdown.supportAutoConvertLinkBelow' => 'Conversion automatique des liens ci-dessous :',
			'markdown.convertLinkExample' => '🎬 Lien vidéo\n🖼️ Lien image\n👤 Lien utilisateur\n📌 Lien forum\n🎵 Lien liste de lecture\n💬 Lien sujet',
			'markdown.mentionUser' => 'Mentionner un utilisateur',
			'markdown.mentionUserDescription' => 'Saisissez @ suivi du nom d\'utilisateur, cela sera automatiquement converti en lien utilisateur',
			'markdown.markdownBasicSyntax' => 'Syntaxe Markdown de base',
			'markdown.paragraphAndLineBreak' => 'Paragraphe et saut de ligne',
			'markdown.paragraphAndLineBreakDescription' => 'Les paragraphes sont séparés par une ligne vide, et deux espaces en fin de ligne seront convertis en saut de ligne',
			'markdown.paragraphAndLineBreakSyntax' => 'Ceci est le premier paragraphe\n\nCeci est le deuxième paragraphe\nCette ligne se termine par deux espaces  \nsera convertie en saut de ligne',
			'markdown.textStyle' => 'Style de texte',
			'markdown.textStyleDescription' => 'Encadrez le texte de symboles spéciaux pour changer son style',
			'markdown.textStyleSyntax' => '**Texte en gras**\n*Texte en italique*\n~~Texte barré~~\n`Texte de code`',
			'markdown.quote' => 'Citation',
			'markdown.quoteDescription' => 'Utilisez le symbole > pour créer une citation, plusieurs > pour créer une citation à plusieurs niveaux',
			'markdown.quoteSyntax' => '> Ceci est une citation de premier niveau\n>> Ceci est une citation de deuxième niveau',
			'markdown.list' => 'Liste',
			'markdown.listDescription' => 'Créez une liste ordonnée avec un chiffre suivi d\'un point, une liste non ordonnée avec -',
			'markdown.listSyntax' => '1. Premier élément\n2. Deuxième élément\n\n- Élément non ordonné\n  - Sous-élément\n  - Autre sous-élément',
			'markdown.linkAndImage' => 'Lien et image',
			'markdown.linkAndImageDescription' => 'Format de lien : [texte](URL)\nFormat d\'image : ![description](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[texte du lien](${link})\n![description de l\'image](${imgUrl})',
			'markdown.title' => 'Titre',
			'markdown.titleDescription' => 'Utilisez le symbole # pour créer un titre, le nombre indique le niveau',
			'markdown.titleSyntax' => '# Titre de premier niveau\n## Titre de deuxième niveau\n### Titre de troisième niveau',
			'markdown.separator' => 'Séparateur',
			'markdown.separatorDescription' => 'Créez un séparateur avec trois symboles - ou plus',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Syntaxe',
			'forum.recent' => 'Récent',
			'forum.category' => 'Catégorie',
			'forum.lastReply' => 'Dernière réponse',
			'forum.sitewide.badge' => 'Tout le site',
			'forum.sitewide.title' => 'Annonce à l\'échelle du site',
			'forum.sitewide.readMore' => 'Lire la suite',
			'forum.errors.pleaseSelectCategory' => 'Veuillez choisir une catégorie',
			'forum.errors.threadLocked' => 'Ce sujet est verrouillé, impossible de répondre',
			'forum.createPost' => 'Créer une publication',
			'forum.title' => 'Titre',
			'forum.enterTitle' => 'Saisir le titre',
			'forum.content' => 'Contenu',
			'forum.enterContent' => 'Saisir le contenu',
			'forum.writeYourContentHere' => 'Écrivez votre contenu ici...',
			'forum.posts' => 'Publications',
			'forum.threads' => 'Sujets',
			'forum.forum' => 'Forum',
			'forum.createThread' => 'Créer un sujet',
			'forum.selectCategory' => 'Choisir une catégorie',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Délai restant : ${minutes} minutes ${seconds} secondes',
			'forum.groups.administration' => 'Administration',
			'forum.groups.global' => 'Global',
			'forum.groups.chinese' => 'Chinois',
			'forum.groups.japanese' => 'Japonais',
			'forum.groups.korean' => 'Coréen',
			'forum.groups.other' => 'Autre',
			'forum.leafNames.announcements' => 'Annonces',
			'forum.leafNames.feedback' => 'Avis',
			'forum.leafNames.support' => 'Assistance',
			'forum.leafNames.general' => 'Général',
			'forum.leafNames.guides' => 'Guides',
			'forum.leafNames.questions' => 'Questions',
			'forum.leafNames.requests' => 'Demandes',
			'forum.leafNames.sharing' => 'Partage',
			'forum.leafNames.general_zh' => 'Général',
			'forum.leafNames.questions_zh' => 'Questions',
			'forum.leafNames.requests_zh' => 'Demandes',
			'forum.leafNames.support_zh' => 'Assistance',
			'forum.leafNames.general_ja' => 'Général',
			'forum.leafNames.questions_ja' => 'Questions',
			'forum.leafNames.requests_ja' => 'Demandes',
			'forum.leafNames.support_ja' => 'Assistance',
			'forum.leafNames.korean' => 'Coréen',
			'forum.leafNames.other' => 'Autre',
			'forum.leafDescriptions.announcements' => 'Notifications et annonces officielles importantes',
			'forum.leafDescriptions.feedback' => 'Avis sur les fonctionnalités et services du site',
			'forum.leafDescriptions.support' => 'Aidez à résoudre les problèmes liés au site',
			'forum.leafDescriptions.general' => 'Discutez de tout sujet',
			'forum.leafDescriptions.guides' => 'Partagez vos expériences et tutoriels',
			'forum.leafDescriptions.questions' => 'Posez vos questions',
			'forum.leafDescriptions.requests' => 'Publiez vos demandes',
			'forum.leafDescriptions.sharing' => 'Partagez du contenu intéressant',
			'forum.leafDescriptions.general_zh' => 'Discutez de tout sujet',
			'forum.leafDescriptions.questions_zh' => 'Posez vos questions',
			'forum.leafDescriptions.requests_zh' => 'Publiez vos demandes',
			'forum.leafDescriptions.support_zh' => 'Aidez à résoudre les problèmes liés au site',
			'forum.leafDescriptions.general_ja' => 'Discutez de tout sujet',
			'forum.leafDescriptions.questions_ja' => 'Posez vos questions',
			'forum.leafDescriptions.requests_ja' => 'Publiez vos demandes',
			'forum.leafDescriptions.support_ja' => 'Aidez à résoudre les problèmes liés au site',
			'forum.leafDescriptions.korean' => 'Discussions liées au coréen',
			'forum.leafDescriptions.other' => 'Autres contenus non classés',
			'forum.reply' => 'Répondre',
			'forum.pendingReview' => 'En attente de vérification',
			'forum.editedAt' => 'Modifié le',
			_ => null,
		} ?? switch (path) {
			'forum.copySuccess' => 'Copié dans le presse-papiers',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Copié dans le presse-papiers : ${str}',
			'forum.editReply' => 'Modifier la réponse',
			'forum.editTitle' => 'Modifier le titre',
			'forum.submit' => 'Envoyer',
			'notifications.errors.unsupportedNotificationType' => 'Type de notification non pris en charge',
			'notifications.errors.unknownUser' => 'Utilisateur inconnu',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Type de notification non pris en charge : ${type}',
			'notifications.errors.unknownNotificationType' => 'Type de notification inconnu',
			'notifications.notifications' => 'Notifications',
			'notifications.profile' => 'Profil',
			'notifications.postedNewComment' => 'Nouveau commentaire publié',
			'notifications.inYour' => 'Dans votre',
			'notifications.video' => 'Vidéo',
			'notifications.repliedYourVideoComment' => 'A répondu à votre commentaire de vidéo',
			'notifications.copyInfoToClipboard' => 'Copier les infos de notification',
			'notifications.copySuccess' => 'Copié dans le presse-papiers',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Copié dans le presse-papiers : ${str}',
			'notifications.markAllAsRead' => 'Tout marquer comme lu',
			'notifications.markAllAsReadSuccess' => 'Toutes les notifications ont été marquées comme lues',
			'notifications.markAllAsReadFailed' => 'Échec du marquage de tout comme lu',
			'notifications.markSelectedAsRead' => 'Marquer la sélection comme lue',
			'notifications.markSelectedAsReadSuccess' => 'Les notifications sélectionnées ont été marquées comme lues',
			'notifications.markSelectedAsReadFailed' => 'Échec du marquage de la sélection comme lue',
			'notifications.markAsRead' => 'Marquer comme lu',
			'notifications.markAsReadSuccess' => 'La notification a été marquée comme lue',
			'notifications.markAsReadFailed' => 'Échec du marquage de la notification comme lue',
			'notifications.notificationTypeHelp' => 'Aide sur les types de notification',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Faute de détails sur le type de notification, les types pris en charge peuvent ne pas couvrir les messages que vous recevez actuellement',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Si vous souhaitez nous aider à améliorer la prise en charge des types de notification',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Copiez les informations de la notification\n2. 🐞 Ouvrez un ticket sur le dépôt du projet\n\n⚠️ Remarque : les informations de notification peuvent contenir des données personnelles ; si vous ne souhaitez pas les rendre publiques, vous pouvez aussi les envoyer à l\'auteur du projet par e-mail.',
			'notifications.goToRepository' => 'Aller au dépôt',
			'notifications.copy' => 'Copier',
			'notifications.commentApproved' => 'Commentaire approuvé',
			'notifications.repliedYourProfileComment' => 'A répondu à votre commentaire de profil',
			'notifications.kReplied' => 'a répondu à votre commentaire sur',
			'notifications.kCommented' => 'a commenté votre',
			'notifications.kVideo' => 'vidéo',
			'notifications.kGallery' => 'galerie',
			'notifications.kProfile' => 'profil',
			'notifications.kThread' => 'sujet',
			'notifications.kPost' => 'publication',
			'notifications.kCommentSection' => 'section de commentaires',
			'notifications.kApprovedComment' => 'Commentaire approuvé',
			'notifications.kApprovedVideo' => 'Vidéo approuvée',
			'notifications.kApprovedGallery' => 'Galerie approuvée',
			'notifications.kApprovedThread' => 'Sujet approuvé',
			'notifications.kApprovedPost' => 'Publication approuvée',
			'notifications.kApprovedForumPost' => 'Message de forum approuvé',
			'notifications.kRejectedContent' => 'Contenu rejeté par la modération',
			'notifications.kUnknownType' => 'Type de notification inconnu',
			'conversation.errors.pleaseSelectAUser' => 'Veuillez choisir un utilisateur',
			'conversation.errors.pleaseEnterATitle' => 'Veuillez saisir un titre',
			'conversation.errors.clickToSelectAUser' => 'Cliquez pour choisir un utilisateur',
			'conversation.errors.loadFailedClickToRetry' => 'Échec du chargement, cliquez pour réessayer',
			'conversation.errors.loadFailed' => 'Échec du chargement',
			'conversation.errors.clickToRetry' => 'Cliquez pour réessayer',
			'conversation.errors.noMoreConversations' => 'Plus de conversations',
			'conversation.conversation' => 'Conversation',
			'conversation.startConversation' => 'Démarrer la conversation',
			'conversation.noConversation' => 'Aucune conversation',
			'conversation.selectFromLeftListAndStartConversation' => 'Choisissez un utilisateur dans la liste de gauche pour démarrer la conversation',
			'conversation.title' => 'Titre',
			'conversation.body' => 'Corps',
			'conversation.selectAUser' => 'Choisir un utilisateur',
			'conversation.searchUsers' => 'Rechercher des utilisateurs...',
			'conversation.tmpNoConversions' => 'Aucune conversation',
			'conversation.deleteThisMessage' => 'Supprimer ce message',
			'conversation.deleteThisMessageSubtitle' => 'Cette opération est irréversible',
			'conversation.writeMessageHere' => 'Écrivez votre message ici...',
			'conversation.lastMessageFromMe' => 'Vous : ',
			'conversation.sendMessage' => 'Envoyer le message',
			'splash.errors.initializationFailed' => 'Échec de l\'initialisation, veuillez redémarrer l\'app',
			'splash.preparing' => 'Préparation...',
			'splash.initializing' => 'Initialisation...',
			'splash.loading' => 'Chargement...',
			'splash.ready' => 'Prêt',
			'splash.initializingMessageService' => 'Initialisation du service de messagerie...',
			'download.errors.imageModelNotFound' => 'Modèle d\'image introuvable',
			'download.errors.downloadFailed' => 'Échec du téléchargement',
			'download.errors.videoInfoNotFound' => 'Infos de la vidéo introuvables',
			'download.errors.downloadTaskAlreadyExists' => 'La tâche de téléchargement existe déjà',
			'download.errors.downloadTaskSavePathConflict' => 'Le chemin d\'enregistrement est déjà utilisé par une autre tâche',
			'download.errors.videoAlreadyDownloaded' => 'Vidéo déjà téléchargée',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Échec de l\'ajout de la tâche de téléchargement : ${errorInfo}',
			'download.errors.userPausedDownload' => 'L\'utilisateur a mis en pause le téléchargement',
			'download.errors.unknown' => 'Inconnu',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Erreur du système de fichiers : ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Erreur inconnue : ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'Échec de l\'écriture du fichier : ${errorInfo}',
			'download.errors.connectionTimeout' => 'Délai de connexion dépassé',
			'download.errors.sendTimeout' => 'Délai d\'envoi dépassé',
			'download.errors.receiveTimeout' => 'Délai de réception dépassé',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Erreur du serveur : ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Erreur réseau inconnue',
			'download.errors.sslHandshakeFailed' => 'Échec de la poignée de main SSL, vérifiez votre réseau',
			'download.errors.connectionFailed' => 'Échec de la connexion, vérifiez votre réseau',
			'download.errors.serviceIsClosing' => 'Le service de téléchargement se ferme',
			'download.errors.partialDownloadFailed' => 'Échec du téléchargement partiel du contenu',
			'download.errors.noDownloadTask' => 'Aucune tâche de téléchargement',
			'download.errors.taskNotFoundOrDataError' => 'Tâche introuvable ou données erronées',
			'download.errors.fileNotFound' => 'Fichier introuvable',
			'download.errors.openFolderFailed' => 'Échec de l\'ouverture du dossier',
			'download.errors.copyDownloadUrlFailed' => 'Échec de la copie de l\'URL de téléchargement',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Échec de l\'ouverture du dossier : ${message}',
			'download.errors.directoryNotFound' => 'Répertoire introuvable',
			'download.errors.copyFailed' => 'Échec de la copie',
			'download.errors.openFileFailed' => 'Échec de l\'ouverture du fichier',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Échec de l\'ouverture du fichier : ${message}',
			'download.errors.playLocallyFailed' => 'Échec de la lecture locale',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Échec de la lecture locale : ${message}',
			'download.errors.noDownloadSource' => 'Aucune source de téléchargement',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'Aucune source de téléchargement, attendez la fin du chargement des informations et réessayez',
			'download.errors.noActiveDownloadTask' => 'Aucune tâche de téléchargement active',
			'download.errors.noFailedDownloadTask' => 'Aucune tâche de téléchargement échouée',
			'download.errors.noCompletedDownloadTask' => 'Aucune tâche de téléchargement terminée',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Tâche déjà terminée, ne pas ajouter à nouveau',
			'download.errors.linkExpiredTryAgain' => 'Lien expiré, tentative d\'obtention d\'un nouveau lien de téléchargement',
			'download.errors.linkExpiredTryAgainSuccess' => 'Lien expiré, nouveau lien de téléchargement obtenu',
			'download.errors.linkExpiredTryAgainFailed' => 'Lien expiré, échec de l\'obtention d\'un nouveau lien de téléchargement',
			'download.errors.taskDeleted' => 'Tâche supprimée',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Format d\'image non pris en charge : ${format}',
			'download.errors.deleteFileError' => 'Échec de la suppression du fichier, peut-être parce qu\'il est utilisé par un autre processus',
			'download.errors.deleteTaskError' => 'Échec de la suppression de la tâche',
			'download.errors.canNotRefreshVideoTask' => 'Échec de l\'actualisation de la tâche vidéo',
			'download.errors.videoRemovedCanNotRefresh' => 'Cette vidéo a été supprimée ou n\'existe plus, le lien de téléchargement ne peut donc pas être actualisé',
			'download.errors.videoInaccessibleCanNotRefresh' => 'Cette vidéo n\'est pas accessible ; elle est peut-être privée ou vous devez vous reconnecter',
			'download.errors.videoQualityGone' => 'Cette qualité n\'est plus proposée, veuillez rajouter le téléchargement',
			'download.errors.refreshLinkNetworkFailed' => 'Erreur réseau, le lien de téléchargement ne peut pas être actualisé pour l\'instant, veuillez réessayer plus tard',
			'download.errors.taskAlreadyProcessing' => 'Tâche déjà en cours de traitement',
			'download.errors.taskNotFound' => 'Tâche introuvable',
			'download.errors.failedToLoadTasks' => 'Échec du chargement des tâches',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Échec du téléchargement partiel : ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Format d\'image non pris en charge : ${extension}, vous pouvez essayer de le télécharger sur votre appareil pour le consulter',
			'download.errors.imageLoadFailed' => 'Échec du chargement de l\'image',
			'download.errors.pleaseTryOtherViewer' => 'Essayez d\'ouvrir avec d\'autres visionneuses',
			'download.downloadList' => 'Liste des téléchargements',
			'download.viewDownloadList' => 'Voir la liste des téléchargements',
			'download.download' => 'Télécharger',
			'download.selectDownloadTitle' => 'Choisir le téléchargement',
			'download.qualitySectionLabel' => 'Qualité',
			'download.categorySectionLabel' => 'Catégorie',
			'download.saveToPreviewLabel' => 'Sera enregistré dans',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Nom de fichier suggéré : ${name} (modifiable dans la boîte de dialogue système)',
			'download.lastUsedBadge' => 'Dernier utilisé',
			'download.pickedBadge' => 'Sélectionné',
			'download.startDownloading' => 'Démarrer le téléchargement',
			'download.clearAllFailedTasks' => 'Effacer toutes les tâches échouées',
			'download.clearAllFailedTasksConfirmation' => 'Voulez-vous vraiment effacer toutes les tâches de téléchargement échouées ? Les fichiers de ces tâches seront également supprimés.',
			'download.clearAllFailedTasksSuccess' => 'Toutes les tâches échouées ont été effacées',
			'download.clearAllFailedTasksError' => 'Une erreur est survenue lors de l\'effacement des tâches échouées',
			'download.downloadStatus' => 'État du téléchargement',
			'download.imageList' => 'Liste des images',
			'download.retryDownload' => 'Relancer le téléchargement',
			'download.notDownloaded' => 'Non téléchargé',
			'download.downloaded' => 'Téléchargé',
			'download.waitingForDownload' => 'En attente de téléchargement',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Téléchargement (${downloaded}/${total} images, ${progress} %)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Téléchargement (${downloaded} images)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'En pause (${downloaded}/${total} images, ${progress} %)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'En pause (${downloaded} images)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Téléchargé (total : ${total} images)',
			'download.viewVideoDetail' => 'Voir le détail de la vidéo',
			'download.viewGalleryDetail' => 'Voir le détail de la galerie',
			'download.moreOptions' => 'Plus d\'options',
			'download.openFile' => 'Ouvrir le fichier',
			'download.playLocally' => 'Lire localement',
			'download.pause' => 'Pause',
			'download.resume' => 'Reprendre',
			'download.copyDownloadUrl' => 'Copier l\'URL de téléchargement',
			'download.showInFolder' => 'Afficher dans le dossier',
			'download.deleteTask' => 'Supprimer la tâche',
			'download.deleteTaskConfirmation' => 'Voulez-vous vraiment supprimer cette tâche de téléchargement ?\nLe fichier de la tâche sera également supprimé.',
			'download.forceDeleteTask' => 'Forcer la suppression de la tâche',
			'download.forceDeleteTaskConfirmation' => 'Voulez-vous vraiment forcer la suppression de cette tâche de téléchargement ?\nLe fichier de la tâche sera également supprimé, même s\'il est en cours d\'utilisation.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Téléchargement ${downloaded}/${total} (${progress} %) • ${speed} Mo/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Téléchargement ${downloaded} • ${speed} Mo/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'En pause ${downloaded}/${total} (${progress} %)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'En pause • Téléchargé ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Téléchargé • ${size}',
			'download.copyDownloadUrlSuccess' => 'URL de téléchargement copiée',
			'download.totalImageNums' => ({required Object num}) => '${num} image(s)',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Téléchargement ${downloaded}/${total} (${progress} %) • ${speed} Mo/s',
			'download.downloading' => 'Téléchargement',
			'download.failed' => 'Échec',
			'download.completed' => 'Terminé',
			'download.downloadDetail' => 'Détails du téléchargement',
			'download.copy' => 'Copier',
			'download.copySuccess' => 'Copié',
			'download.waiting' => 'En attente',
			'download.paused' => 'En pause',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Téléchargement ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Téléchargement de la galerie terminé : ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Téléchargement terminé : ${fileName}',
			'download.searchTasks' => 'Rechercher des tâches...',
			'download.statusLabel' => ({required Object label}) => 'État : ${label}',
			'download.allStatus' => 'Tous les états',
			'download.typeLabel' => ({required Object label}) => 'Type : ${label}',
			'download.allTypes' => 'Tous les types',
			'download.taskType' => 'Type',
			'download.video' => 'Vidéo',
			'download.gallery' => 'Galerie',
			'download.other' => 'Autre',
			'download.clearFilters' => 'Effacer les filtres',
			'download.pauseAll' => 'Tout mettre en pause',
			'download.resumeAll' => 'Tout démarrer',
			'download.remainingTime' => ({required Object time}) => '${time} restant',
			'download.timeline.today' => 'Aujourd\'hui',
			'download.timeline.yesterday' => 'Hier',
			'download.timeline.thisWeek' => 'Cette semaine',
			'download.timeline.thisMonth' => 'Ce mois-ci',
			'download.errorTypes.network' => 'Problème réseau, réessayer peut aider',
			'download.errorTypes.serverRejected' => 'Rejeté par le serveur, vous devrez peut-être vous reconnecter',
			'download.errorTypes.notFound' => 'La ressource a disparu ou a été supprimée',
			'download.errorTypes.diskFull' => 'Espace de stockage insuffisant',
			'download.errorTypes.fileInUse' => 'Le fichier est utilisé par un autre programme',
			'download.errorTypes.permission' => 'Aucune permission d\'écriture',
			'download.errorTypes.cancelled' => 'Annulé',
			'download.errorTypes.unknown' => 'Erreur inconnue',
			'download.errorDetailCopied' => 'Détails de l\'erreur copiés',
			'download.errorDetailCopyHint' => 'Appuyez longuement pour copier les détails de l\'erreur',
			'download.restoredPaused.banner' => ({required Object num}) => '${num} tâches inachevées de la dernière session ont été mises en pause',
			'download.restoredPaused.resume' => 'Tout reprendre',
			'download.restoredPaused.dismiss' => 'Ignorer',
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
			'download.emptyTaskList' => 'Aucune tâche de téléchargement pour l\'instant',
			'download.noMatchingTasks' => 'Aucune tâche correspondante',
			'download.deleteByDate.menuTitle' => 'Supprimer par date',
			'download.deleteByDate.dialogTitle' => 'Supprimer par date',
			'download.deleteByDate.description' => 'Supprimez en masse les tâches de téléchargement par date de création. Les tâches dont les fichiers sont utilisés sont ignorées ; celles dont les fichiers n\'existent plus sont nettoyées.',
			'download.deleteByDate.modeRange' => 'Plage de dates',
			'download.deleteByDate.modeDays' => 'Plus ancien que',
			'download.deleteByDate.startDate' => 'Date de début',
			'download.deleteByDate.endDate' => 'Date de fin',
			'download.deleteByDate.notSet' => 'Non défini',
			'download.deleteByDate.daysUnit' => 'jours',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Supprimer les tâches créées il y a plus de ${days} jour(s)',
			'download.deleteByDate.noMatch' => 'Aucune tâche ne correspond à la condition sélectionnée',
			'download.deleteByDate.invalidRange' => 'La date de début doit être antérieure ou égale à la date de fin',
			'download.deleteByDate.confirmTitle' => 'Confirmer la suppression',
			'download.deleteByDate.confirmContent' => ({required Object count}) => 'Supprimer ${count} tâche(s) de téléchargement et leurs fichiers ? Cette action est irréversible.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Suppression ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => '${count} tâche(s) supprimée(s)',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => '${deleted} tâche(s) supprimée(s) ; ${skipped} ignorée(s) (en cours d\'utilisation)',
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
			'download.category.manageTitle' => 'Gérer les catégories',
			'download.category.label' => 'Catégories',
			'download.category.uncategorized' => 'Sans catégorie',
			'download.category.manage' => 'Gérer',
			'download.category.createShortcut' => 'Nouveau',
			'download.category.newCategoryHint' => 'Nom de la nouvelle catégorie',
			'download.category.createSuccess' => 'Catégorie créée',
			'download.category.createFailed' => 'Échec de la création de la catégorie',
			'download.category.nameEmpty' => 'Le nom de la catégorie ne peut pas être vide',
			'download.category.emptyHint' => 'Aucune catégorie pour l\'instant. Créez-en une pour organiser vos téléchargements.',
			'download.category.moveTo' => 'Déplacer vers une catégorie',
			'download.category.moveToWithCount' => ({required Object count}) => 'Déplacer ${count} élément(s) vers…',
			'download.category.moveSuccess' => ({required Object title}) => 'Déplacé vers ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Déplacé vers Sans catégorie',
			'download.category.moveFailed' => 'Échec du déplacement',
			'download.category.renameTitle' => 'Renommer la catégorie',
			'download.category.renameHint' => 'Saisissez le nom de la catégorie',
			'download.category.renameSuccess' => 'Catégorie renommée',
			'download.category.renameFailed' => 'Échec du renommage de la catégorie',
			'download.category.deleteTitle' => 'Supprimer la catégorie',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'Supprimer la catégorie « ${title} » ? Les ${count} éléments qu\'elle contient passent dans Sans catégorie. Aucun fichier n\'est supprimé.',
			'download.category.deleteSuccess' => 'Catégorie supprimée',
			'download.category.deleteFailed' => 'Échec de la suppression de la catégorie',
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
			'download.maxConcurrentDownloads' => 'Téléchargements simultanés maximum',
			_ => null,
		} ?? switch (path) {
			'download.maxConcurrentDownloadsDesc' => 'Nombre de tâches téléchargées en même temps (1-5)',
			'download.stillInDevelopment' => 'En cours de développement',
			'download.saveToAppDirectory' => 'Enregistrer dans le dossier de l\'application',
			'download.alreadyDownloadedWithQuality' => 'Déjà téléchargé avec la même qualité. Continuer le téléchargement ?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Déjà téléchargé avec les qualités : ${qualities}. Continuer le téléchargement ?',
			'download.otherQualities' => 'Autres qualités',
			'download.batchDownload.title' => 'Téléchargement par lots',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Une tâche est déjà en cours, veuillez patienter.',
			'download.batchDownload.userCancelled' => 'Annulé par l\'utilisateur',
			'download.batchDownload.failedToGetVideoInfo' => 'Impossible d\'obtenir les informations de la vidéo',
			'download.batchDownload.failedToGetVideoSource' => 'Impossible d\'obtenir la source vidéo',
			'download.batchDownload.failedToGetGalleryInfo' => 'Impossible d\'obtenir les informations de la galerie',
			'download.batchDownload.galleryNoImages' => 'La galerie ne contient aucune image',
			'download.batchDownload.failedToGetSavePath' => 'Impossible d\'obtenir le chemin d\'enregistrement',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Échec du téléchargement par lots : ${exception}',
			'download.batchDownload.selectQuality' => 'Choisir la qualité',
			'download.batchDownload.downloading' => 'Téléchargement',
			'download.batchDownload.downloadResult' => 'Résultat du téléchargement',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => '${count} vidéo(s) sélectionnée(s)',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => '${count} galerie(s) sélectionnée(s)',
			'download.batchDownload.qualityNote' => 'Si la qualité sélectionnée n\'est pas disponible, la meilleure qualité disponible sera utilisée',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Traitement ${current}/${total}',
			'download.batchDownload.queued' => 'En file d\'attente',
			'download.batchDownload.success' => 'Réussi',
			'download.batchDownload.skipped' => 'Ignoré',
			'download.batchDownload.failed' => 'Échec',
			'download.batchDownload.failureDetails' => 'Détails de l\'échec',
			'download.batchDownload.reasonPrivateVideo' => 'Vidéo privée',
			'download.batchDownload.reasonAlreadyExists' => 'Existe déjà',
			'download.batchDownload.reasonNoSource' => 'Aucune source de téléchargement',
			'download.batchDownload.reasonNoSavePath' => 'Impossible d\'obtenir le chemin d\'enregistrement',
			'download.batchDownload.reasonOther' => 'Autre erreur',
			'download.batchDownload.startDownload' => 'Démarrer le téléchargement',
			'downloadNotifications.completedTitle' => 'Téléchargement terminé',
			'downloadNotifications.failedTitle' => 'Échec du téléchargement',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} téléchargé avec succès',
			'downloadNotifications.failedBody' => ({required Object name}) => 'Échec du téléchargement de ${name}',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} téléchargé',
			'downloadNotifications.failedToast' => ({required Object name}) => 'Échec du téléchargement de ${name}',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Enregistré dans ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Enregistré sous ${name} (un fichier du même nom existait déjà)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Enregistré dans le dossier de lapp — écriture impossible dans ${target} (${reason})',
			'downloadNotifications.viewFolder' => 'Voir le dossier',
			'downloadNotifications.fixInSettings' => 'Corriger dans les réglages',
			'downloadNotifications.channelName' => 'État des téléchargements',
			'downloadNotifications.channelDescription' => 'Notifications de téléchargements terminés et échoués',
			'favorite.errors.addFailed' => 'Échec de l\'ajout',
			'favorite.errors.addSuccess' => 'Ajout réussi',
			'favorite.errors.deleteFolderFailed' => 'Échec de la suppression du dossier',
			'favorite.errors.deleteFolderSuccess' => 'Dossier supprimé',
			'favorite.errors.folderNameCannotBeEmpty' => 'Le nom du dossier ne peut pas être vide',
			'favorite.add' => 'Ajouter',
			'favorite.addSuccess' => 'Ajout réussi',
			'favorite.addFailed' => 'Échec de l\'ajout',
			'favorite.remove' => 'Retirer',
			'favorite.removeSuccess' => 'Retrait réussi',
			'favorite.removeFailed' => 'Échec du retrait',
			'favorite.removeConfirmation' => 'Voulez-vous vraiment retirer cet élément des favoris ?',
			'favorite.removeConfirmationSuccess' => 'Élément retiré des favoris',
			'favorite.removeConfirmationFailed' => 'Échec du retrait de l\'élément des favoris',
			'favorite.createFolderSuccess' => 'Dossier créé avec succès',
			'favorite.createFolderFailed' => 'Échec de la création du dossier',
			'favorite.createFolder' => 'Créer un dossier',
			'favorite.enterFolderName' => 'Saisir le nom du dossier',
			'favorite.enterFolderNameHere' => 'Saisissez ici le nom du dossier...',
			'favorite.create' => 'Créer',
			'favorite.items' => 'Éléments',
			'favorite.newFolderName' => 'Nouveau dossier',
			'favorite.searchFolders' => 'Rechercher des dossiers...',
			'favorite.searchItems' => 'Rechercher des éléments...',
			'favorite.createdAt' => 'Créé le',
			'favorite.myFavorites' => 'Mes favoris',
			'favorite.deleteFolderTitle' => 'Supprimer le dossier',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Voulez-vous vraiment supprimer le dossier ${title} ?',
			'favorite.removeItemTitle' => 'Retirer l\'élément',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Voulez-vous vraiment supprimer l\'élément ${title} ?',
			'favorite.removeItemSuccess' => 'Élément retiré des favoris',
			'favorite.removeItemFailed' => 'Échec du retrait de l\'élément des favoris',
			'favorite.localizeFavorite' => 'Favori local',
			'favorite.editFolderTitle' => 'Modifier le dossier',
			'favorite.editFolderSuccess' => 'Dossier mis à jour avec succès',
			'favorite.editFolderFailed' => 'Échec de la mise à jour du dossier',
			'favorite.searchTags' => 'Rechercher des tags',
			'favorite.noTagsInFolder' => 'Aucun tag sur les éléments de ce dossier pour l\'instant',
			'favorite.tagFilterMatchAll' => 'Affiche uniquement les éléments portant tous les tags sélectionnés',
			'favorite.clearSelectedTags' => 'Effacer les tags sélectionnés',
			'favorite.selectedTagCount' => ({required Object count}) => '${count} sélectionné(s)',
			'favorite.noMatchingTags' => 'Aucun tag correspondant',
			'translation.currentService' => 'Service actuel',
			'translation.testConnection' => 'Tester la connexion',
			'translation.testConnectionSuccess' => 'Test de connexion réussi',
			'translation.testConnectionFailed' => 'Échec du test de connexion',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Échec du test de connexion : ${message}',
			'translation.translation' => 'Traduction',
			'translation.needVerification' => 'Vérification requise',
			'translation.needVerificationContent' => 'Veuillez d\'abord tester la connexion avant d\'activer la traduction par IA',
			'translation.confirm' => 'Confirmer',
			'translation.disclaimer' => 'Avertissement',
			'translation.riskWarning' => 'Avertissement de risque',
			'translation.dureToRisk1' => 'Le texte étant généré par les utilisateurs, il peut contenir des éléments contraires à la politique de contenu du fournisseur de service d\'IA',
			'translation.dureToRisk2' => 'Un contenu inapproprié peut entraîner la suspension de la clé d\'API ou la résiliation du service',
			'translation.operationSuggestion' => 'Conseils d\'utilisation',
			'translation.operationSuggestion1' => '1. À utiliser avant d\'examiner rigoureusement le contenu à traduire',
			'translation.operationSuggestion2' => '2. Évitez de traduire des contenus impliquant de la violence, du contenu pour adultes, etc.',
			'translation.apiConfig' => 'Configuration de l\'API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Modifier la configuration fermera automatiquement la traduction par IA ; un nouveau test sera nécessaire après l\'activation',
			'translation.apiAddress' => 'Adresse de l\'API',
			'translation.modelName' => 'Nom du modèle',
			'translation.modelNameHintText' => 'Par exemple : gpt-4-turbo',
			'translation.maxTokens' => 'Jetons max',
			'translation.maxTokensHintText' => 'Par exemple : 32000',
			'translation.temperature' => 'Température',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Cliquez sur le bouton de test pour vérifier la validité de la connexion à l\'API',
			'translation.requestPreview' => 'Aperçu de la requête',
			'translation.enableAITranslation' => 'Activer l\'IA',
			'translation.enabled' => 'Activé',
			'translation.disabled' => 'Désactivé',
			'translation.testing' => 'Test en cours...',
			'translation.testNow' => 'Tester maintenant',
			'translation.connectionStatus' => 'État de la connexion',
			'translation.success' => 'Succès',
			'translation.failed' => 'Échec',
			'translation.information' => 'Informations',
			'translation.viewRawResponse' => 'Voir la réponse brute',
			'translation.pleaseCheckInputParametersFormat' => 'Veuillez vérifier le format des paramètres saisis',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Veuillez renseigner l\'adresse de l\'API, le nom du modèle et la clé',
			'translation.pleaseFillInValidConfigurationParameters' => 'Veuillez renseigner des paramètres de configuration valides',
			'translation.pleaseCompleteConnectionTest' => 'Veuillez effectuer le test de connexion',
			'translation.notConfigured' => 'Non configuré',
			'translation.apiEndpoint' => 'Point de terminaison de l\'API',
			'translation.configuredKey' => 'Clé configurée',
			'translation.notConfiguredKey' => 'Clé non configurée',
			'translation.authenticationStatus' => 'État de l\'authentification',
			'translation.thisFieldCannotBeEmpty' => 'Ce champ ne peut pas être vide',
			'translation.apiKey' => 'Clé d\'API',
			'translation.apiKeyCannotBeEmpty' => 'La clé d\'API ne peut pas être vide',
			'translation.pleaseEnterValidNumber' => 'Veuillez saisir un nombre valide',
			'translation.range' => 'Plage',
			'translation.mustBeGreaterThan' => 'Doit être supérieur à',
			'translation.invalidAPIResponse' => 'Réponse d\'API non valide',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Échec de la connexion : ${message}',
			'translation.aiTranslationNotEnabledHint' => 'La traduction par IA n\'est pas activée, veuillez l\'activer dans les paramètres',
			'translation.goToSettings' => 'Aller aux paramètres',
			'translation.disableAITranslation' => 'Désactiver la traduction par IA',
			'translation.currentValue' => 'Valeur actuelle',
			'translation.configureTranslationStrategy' => 'Configurer la stratégie de traduction',
			'translation.advancedSettings' => 'Paramètres avancés',
			'translation.translationPrompt' => 'Prompt de traduction',
			'translation.promptHint' => 'Veuillez saisir le prompt de traduction ; utilisez [TL] comme espace réservé pour la langue cible',
			'translation.promptHelperText' => 'Le prompt doit contenir [TL] comme espace réservé pour la langue cible',
			'translation.promptMustContainTargetLang' => 'Le prompt doit contenir l\'espace réservé [TL]',
			'translation.aiTranslationWillBeDisabled' => 'La traduction par IA sera désactivée',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'En raison d\'un changement de configuration de base, la traduction par IA sera désactivée',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'En raison d\'un changement du prompt de traduction, la traduction par IA sera désactivée',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'En raison d\'un changement de configuration des paramètres, la traduction par IA sera désactivée',
			'translation.onlyOpenAIAPISupported' => 'Ne prend actuellement en charge que le format d\'API compatible OpenAI (corps de requête application/json)',
			'translation.streamingTranslation' => 'Traduction en flux',
			'translation.streamingTranslationSupported' => 'Traduction en flux prise en charge',
			'translation.streamingTranslationNotSupported' => 'Traduction en flux non prise en charge',
			'translation.streamingTranslationDescription' => 'La traduction en flux peut afficher les résultats en temps réel pendant la traduction, pour une meilleure expérience',
			'translation.usingFullUrlWithHash' => 'Utilisation de l\'URL complète (se terminant par #)',
			'translation.baseUrlInputHelperText' => 'S\'il se termine par #, il sera utilisé comme adresse de requête réelle',
			'translation.currentActualUrl' => ({required Object url}) => 'URL réelle actuelle : ${url}',
			'translation.urlEndingWithHashTip' => 'Une URL se terminant par # sera utilisée directement, sans ajout de suffixe',
			'translation.streamingTranslationWarning' => 'Remarque : cette fonctionnalité nécessite que le service d\'API prenne en charge la transmission en flux ; certains modèles peuvent ne pas la prendre en charge',
			'translation.translationService' => 'Service de traduction',
			'translation.translationServiceDescription' => 'Sélectionnez votre service de traduction préféré',
			'translation.googleTranslation' => 'Traduction Google',
			'translation.googleTranslationDescription' => 'Service de traduction en ligne gratuit prenant en charge plusieurs langues',
			'translation.aiTranslation' => 'Traduction par IA',
			'translation.aiTranslationDescription' => 'Service de traduction intelligent basé sur de grands modèles de langage',
			'translation.deeplxTranslation' => 'Traduction DeepLX',
			'translation.deeplxTranslationDescription' => 'Implémentation open source de la traduction DeepL, offrant une traduction de haute qualité',
			'translation.googleTranslationFeatures' => 'Fonctionnalités',
			'translation.freeToUse' => 'Gratuit',
			'translation.freeToUseDescription' => 'Aucune configuration requise, prêt à l\'emploi',
			'translation.fastResponse' => 'Réponse rapide',
			'translation.fastResponseDescription' => 'Traduction rapide avec une faible latence',
			'translation.stableAndReliable' => 'Stable et fiable',
			'translation.stableAndReliableDescription' => 'Basé sur l\'API officielle Google',
			'translation.enabledDefaultService' => 'Activé - service de traduction par défaut',
			'translation.notEnabled' => 'Non activé',
			'translation.deeplxTranslationService' => 'Service de traduction DeepLX',
			'translation.deeplxDescription' => 'DeepLX est une implémentation open source de la traduction DeepL, prenant en charge les modes Free, Pro et Official',
			'translation.serverAddress' => 'Adresse du serveur',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Adresse de base du serveur DeepLX',
			'translation.endpointType' => 'Type de point de terminaison',
			'translation.freeEndpoint' => 'Free - point de terminaison gratuit, peut avoir des limites de débit',
			'translation.proEndpoint' => 'Pro - nécessite dl_session, plus stable',
			'translation.officialEndpoint' => 'Official - format d\'API officiel',
			'translation.finalRequestUrl' => 'URL de requête finale',
			'translation.apiKeyOptional' => 'Clé d\'API (facultative)',
			'translation.apiKeyOptionalHint' => 'Pour accéder aux services DeepLX protégés',
			'translation.apiKeyOptionalHelperText' => 'Certains services DeepLX exigent une clé d\'API pour l\'authentification',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Paramètre dl_session requis pour le mode Pro',
			'translation.dlSessionHelperText' => 'Paramètre de session requis pour le point de terminaison Pro, obtenu depuis un compte DeepL Pro',
			'translation.proModeRequiresDlSession' => 'Le mode Pro nécessite dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Cliquez sur le bouton de test pour vérifier la connexion à l\'API DeepLX',
			'translation.enableDeepLXTranslation' => 'Activer la traduction DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'La traduction DeepLX sera désactivée en raison de changements de configuration',
			'translation.translatedResult' => 'Résultat traduit',
			'translation.testSuccess' => 'Test réussi',
			'translation.pleaseFillInDeepLXServerAddress' => 'Veuillez renseigner l\'adresse du serveur DeepLX',
			'translation.invalidAPIResponseFormat' => 'Format de réponse d\'API non valide',
			'translation.translationServiceReturnedError' => 'Le service de traduction a renvoyé une erreur ou un résultat vide',
			'translation.connectionFailed' => 'Échec de la connexion',
			'translation.translationFailed' => 'Échec de la traduction',
			'translation.aiTranslationFailed' => 'Échec de la traduction par IA',
			'translation.deeplxTranslationFailed' => 'Échec de la traduction DeepLX',
			'translation.aiTranslationTestFailed' => 'Échec du test de la traduction par IA',
			'translation.deeplxTranslationTestFailed' => 'Échec du test de traduction DeepLX',
			'translation.streamingTranslationTimeout' => 'Délai de traduction en flux dépassé, nettoyage forcé des ressources',
			'translation.translationRequestTimeout' => 'Délai de la requête de traduction dépassé',
			'translation.streamingTranslationDataTimeout' => 'Délai de réception des données de traduction en flux dépassé',
			'translation.dataReceptionTimeout' => 'Délai de réception des données dépassé',
			'translation.streamDataParseError' => 'Erreur d\'analyse des données du flux',
			'translation.streamingTranslationFailed' => 'Échec de la traduction en flux',
			'translation.fallbackTranslationFailed' => 'Le repli vers la traduction normale a également échoué',
			'translation.translationSettings' => 'Paramètres de traduction',
			'translation.enableGoogleTranslation' => 'Activer la traduction Google',
			'translation.thinking' => 'Réflexion...',
			'translation.thoughtProcess' => 'Processus de réflexion',
			'translation.modelCompatibility' => 'Compatibilité des modèles',
			'translation.modelCompatibilityDescription' => 'Adapter les paramètres de requête aux modèles récents tels que les modèles de raisonnement (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'Modèle de raisonnement',
			'translation.reasoningModelDescription' => 'Pour o1/o3, DeepSeek-R1, QwQ, etc. Intègre le prompt dans le message utilisateur, omet la température et utilise max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'Utiliser max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'Les points de terminaison OpenAI récents exigent max_completion_tokens au lieu du max_tokens obsolète',
			'translation.sendTemperature' => 'Envoyer la température',
			'translation.sendTemperatureDescription' => 'À désactiver pour les modèles qui rejettent le paramètre temperature (la plupart des modèles de raisonnement)',
			'translation.showReasoningProcess' => 'Afficher le processus de réflexion',
			'translation.showReasoningProcessDescription' => 'Afficher le raisonnement dépliable des modèles de raisonnement dans la boîte de dialogue de traduction',
			'translation.provider' => 'Fournisseur',
			'translation.providerOpenAI' => 'OpenAI (et compatibles)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Prend en charge OpenAI (et tout point de terminaison compatible OpenAI), Anthropic et Google via le SDK dartantic_ai',
			'translation.baseUrlOptionalHelperText' => 'Facultatif. Laissez vide pour utiliser le point de terminaison par défaut du fournisseur ; renseignez-le pour les points de terminaison compatibles OpenAI/relais',
			'translation.defaultEndpoint' => 'Point de terminaison par défaut',
			'translation.providerPreset' => 'Préréglage du fournisseur',
			'translation.selectProviderPreset' => 'Sélectionner un préréglage',
			'translation.presetCustom' => 'Personnalisé',
			'translation.presetApplied' => ({required Object name}) => 'Préréglage appliqué : ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI Reasoning (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude Reasoning (réflexion étendue)',
			'translation.presetNames.gemini' => 'Google Gemini (natif)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini Reasoning (réflexion)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek Reasoning (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Récupérer la liste des modèles',
			'translation.fetchingModels' => 'Récupération...',
			'translation.selectModel' => 'Sélectionner un modèle',
			'translation.searchModel' => 'Rechercher un modèle',
			'translation.noModelsFound' => 'Aucun modèle trouvé',
			'bottomNav.video' => 'Vidéo',
			'bottomNav.gallery' => 'Galerie',
			'bottomNav.subscription' => 'Fil',
			'bottomNav.community' => 'Forum',
			'bottomNav.localMedia' => 'Local',
			'navigationOrderSettings.title' => 'Réglages de l\'ordre de navigation',
			'navigationOrderSettings.customNavigationOrder' => 'Ordre de navigation personnalisé',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Faites glisser pour ajuster l\'ordre d\'affichage des pages dans la barre de navigation inférieure et la barre latérale',
			'navigationOrderSettings.restartRequired' => 'Redémarrage de l\'application requis',
			'navigationOrderSettings.navigationItemSorting' => 'Tri des éléments de navigation',
			'navigationOrderSettings.done' => 'Terminé',
			'navigationOrderSettings.edit' => 'Modifier',
			'navigationOrderSettings.reset' => 'Réinitialiser',
			'navigationOrderSettings.previewEffect' => 'Aperçu du résultat',
			'navigationOrderSettings.bottomNavigationPreview' => 'Aperçu de la navigation inférieure :',
			'navigationOrderSettings.sidebarPreview' => 'Aperçu de la barre latérale :',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Confirmer la réinitialisation de l\'ordre de navigation',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Voulez-vous vraiment rétablir l\'ordre de navigation par défaut ?',
			'navigationOrderSettings.cancel' => 'Annuler',
			'navigationOrderSettings.show' => 'Afficher',
			'navigationOrderSettings.hide' => 'Masquer',
			'navigationOrderSettings.hidden' => 'Masqué',
			'navigationOrderSettings.hideHint' => 'Appuyez sur l\'icône en forme d\'œil pour afficher ou masquer Communauté et les fichiers locaux',
			'navigationOrderSettings.videoDescription' => 'Parcourir les vidéos populaires',
			'navigationOrderSettings.galleryDescription' => 'Parcourir les images et les galeries',
			'navigationOrderSettings.subscriptionDescription' => 'Voir les derniers contenus des utilisateurs suivis',
			'navigationOrderSettings.forumDescription' => 'Participez aux discussions de la communauté',
			'navigationOrderSettings.newsDescription' => 'Parcourir les actualités, articles et diffusions officiels',
			'navigationOrderSettings.communityDescription' => 'Discussions du forum, plus les actualités, articles et diffusions officiels',
			'navigationOrderSettings.localMediaDescription' => 'Parcourir les vidéos et images stockées sur cet appareil',
			'news.title' => 'Actualités',
			'news.newsUpdates' => 'Actualités',
			'news.articles' => 'Articles',
			'news.broadcast' => 'Diffusion',
			'news.openInBrowser' => 'Ouvrir dans le navigateur',
			'displaySettings.title' => 'Réglages d\'affichage',
			'displaySettings.layoutSettings' => 'Réglages de disposition',
			'displaySettings.layoutSettingsDesc' => 'Personnalisez le nombre de colonnes et la configuration des points de rupture',
			'displaySettings.gridLayout' => 'Disposition en grille',
			'displaySettings.navigationOrderSettings' => 'Réglages de l\'ordre de navigation',
			'displaySettings.customNavigationOrder' => 'Ordre de navigation personnalisé',
			'displaySettings.customNavigationOrderDesc' => 'Ajustez l\'ordre d\'affichage des pages dans la barre de navigation inférieure et la barre latérale',
			'layoutSettings.title' => 'Réglages de disposition',
			'layoutSettings.descriptionTitle' => 'Description de la configuration de disposition',
			'layoutSettings.descriptionContent' => 'La configuration ici détermine le nombre de colonnes affichées dans les pages de liste de vidéos et de galeries. Vous pouvez choisir le mode automatique pour laisser le système s\'ajuster selon la largeur de l\'écran, ou le mode manuel pour fixer le nombre de colonnes.',
			'layoutSettings.layoutMode' => 'Mode de disposition',
			'layoutSettings.reset' => 'Réinitialiser',
			'layoutSettings.autoMode' => 'Mode automatique',
			'layoutSettings.autoModeDesc' => 'Ajuster automatiquement selon la largeur de l\'écran',
			'layoutSettings.manualMode' => 'Mode manuel',
			'layoutSettings.manualModeDesc' => 'Utiliser un nombre de colonnes fixe',
			'layoutSettings.manualSettings' => 'Réglages manuels',
			'layoutSettings.fixedColumns' => 'Colonnes fixes',
			'layoutSettings.columns' => 'colonnes',
			'layoutSettings.breakpointConfig' => 'Configuration des points de rupture',
			'layoutSettings.add' => 'Ajouter',
			'layoutSettings.defaultColumns' => 'Colonnes par défaut',
			'layoutSettings.defaultColumnsDesc' => 'Affichage par défaut pour les grands écrans',
			'layoutSettings.previewEffect' => 'Aperçu du résultat',
			'layoutSettings.screenWidth' => 'Largeur de l\'écran',
			'layoutSettings.addBreakpoint' => 'Ajouter un point de rupture',
			'layoutSettings.editBreakpoint' => 'Modifier le point de rupture',
			'layoutSettings.deleteBreakpoint' => 'Supprimer le point de rupture',
			'layoutSettings.screenWidthLabel' => 'Largeur de l\'écran',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Colonnes',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Veuillez saisir la largeur',
			'layoutSettings.enterValidWidth' => 'Veuillez saisir une largeur valide',
			'layoutSettings.widthCannotExceed9999' => 'La largeur ne peut pas dépasser 9999',
			'layoutSettings.breakpointAlreadyExists' => 'Le point de rupture existe déjà',
			'layoutSettings.enterColumns' => 'Veuillez saisir le nombre de colonnes',
			'layoutSettings.enterValidColumns' => 'Veuillez saisir un nombre de colonnes valide',
			'layoutSettings.columnsCannotExceed12' => 'Le nombre de colonnes ne peut pas dépasser 12',
			'layoutSettings.breakpointConflict' => 'Le point de rupture existe déjà',
			'layoutSettings.confirmResetLayoutSettings' => 'Réinitialiser les réglages de disposition',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Voulez-vous vraiment réinitialiser tous les réglages de disposition aux valeurs par défaut ?\n\nRestauration de :\n• Mode automatique\n• Configuration des points de rupture par défaut',
			'layoutSettings.resetToDefaults' => 'Rétablir les valeurs par défaut',
			'layoutSettings.confirmDeleteBreakpoint' => 'Supprimer le point de rupture',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Voulez-vous vraiment supprimer le point de rupture ${width}px ?',
			'layoutSettings.noCustomBreakpoints' => 'Aucun point de rupture personnalisé, utilisation des colonnes par défaut',
			'layoutSettings.breakpointRange' => 'Plage du point de rupture',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Modifier',
			'layoutSettings.delete' => 'Supprimer',
			'layoutSettings.cancel' => 'Annuler',
			'layoutSettings.save' => 'Enregistrer',
			'mediaPlayer.videoPlayerError' => 'Erreur du lecteur vidéo',
			'mediaPlayer.videoLoadFailed' => 'Échec du chargement de la vidéo',
			'mediaPlayer.videoCodecNotSupported' => 'Codec vidéo non pris en charge',
			'mediaPlayer.networkConnectionIssue' => 'Problème de connexion réseau',
			'mediaPlayer.insufficientPermission' => 'Permissions insuffisantes',
			'mediaPlayer.unsupportedVideoFormat' => 'Format vidéo non pris en charge',
			'mediaPlayer.retry' => 'Réessayer',
			'mediaPlayer.externalPlayer' => 'Lecteur externe',
			'mediaPlayer.detailedErrorInfo' => 'Informations détaillées sur l\'erreur',
			'mediaPlayer.format' => 'Format',
			'mediaPlayer.suggestion' => 'Conseil',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Les appareils Android ne prennent que partiellement en charge le format WEBM. Il est recommandé d\'utiliser un lecteur externe ou de télécharger une application de lecture compatible WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'L\'appareil actuel ne prend pas en charge le codec de ce format vidéo',
			'mediaPlayer.checkNetworkConnection' => 'Vérifiez votre connexion réseau et réessayez',
			'mediaPlayer.appMayLackMediaPermission' => 'L\'application ne dispose peut-être pas des permissions nécessaires à la lecture multimédia',
			'mediaPlayer.tryOtherVideoPlayer' => 'Essayez d\'utiliser d\'autres lecteurs vidéo',
			'mediaPlayer.unrecognizedVideoFormat' => 'Fichier vidéo non reconnu',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Le lien a peut-être expiré, ou la réponse n\'était pas une vidéo. Réessayez, ou ouvrez-la avec une autre application.',
			'mediaPlayer.accessDenied' => 'Le serveur a refusé cette requête (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Le lien de lecture a très probablement expiré. Appuyez sur Réessayer pour le récupérer, ou ouvrez-le avec une autre application.',
			'mediaPlayer.mute' => 'Couper le son',
			'mediaPlayer.unmute' => 'Rétablir le son',
			'mediaPlayer.video' => 'VIDÉO',
			'mediaPlayer.serverSelector' => 'Choix du serveur CDN',
			'mediaPlayer.serverSelectorDescription' => 'Sélectionnez le serveur avec la latence la plus faible pour une meilleure expérience de lecture',
			'mediaPlayer.retestSpeed' => 'Retester la vitesse',
			'mediaPlayer.waitingForSpeedTest' => 'En attente du test de vitesse',
			'mediaPlayer.testingSpeed' => 'Test de vitesse...',
			'mediaPlayer.testFailed' => 'Échec du test',
			'mediaPlayer.loadingServerList' => 'Chargement de la liste des serveurs...',
			'mediaPlayer.noAvailableServers' => 'Aucun serveur disponible',
			'mediaPlayer.refreshServerList' => 'Actualiser la liste des serveurs',
			'mediaPlayer.cannotGetSource' => 'Impossible d\'obtenir la source de la vidéo en cours',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Serveur changé : ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'Total : ${count} serveurs',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Code d\'état : ${code}',
			'mediaPlayer.connectionFailed' => 'Échec de la connexion',
			'mediaPlayer.connectionTimeout' => 'Délai de connexion dépassé',
			'mediaPlayer.networkError' => 'Erreur réseau',
			'mediaPlayer.sslError' => 'Erreur de certificat SSL',
			'mediaPlayer.testCompleted' => 'Test terminé',
			'mediaPlayer.local' => 'Local',
			'mediaPlayer.unknown' => 'Inconnu',
			'mediaPlayer.localVideoPathEmpty' => 'Le chemin de la vidéo locale est vide',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Le fichier vidéo local n\'existe pas : ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Impossible de lire la vidéo locale : ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Déposez un fichier vidéo ici pour le lire',
			'mediaPlayer.supportedFormats' => 'Formats pris en charge : MP4, MKV, AVI, MOV, WEBM, etc.',
			'mediaPlayer.noSupportedVideoFile' => 'Aucun fichier vidéo pris en charge trouvé',
			'mediaPlayer.retryingOpenVideoLink' => 'Échec de l\'ouverture du lien vidéo, nouvel essai',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Impossible de charger le décodeur : ${event}. Essayez de passer au décodage logiciel dans les réglages du lecteur et revenez sur la page',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Erreur de chargement de la vidéo : ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Échecs de lecture répétés détectés. Allez dans Réglages > Diagnostics et retours pour exporter les journaux.',
			'mediaPlayer.openSettingsAction' => 'Voir',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Avis de lecture : ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Vérifiez votre réseau ; la lecture peut saccader',
			'mediaPlayer.notice.audioTrackUnavailable' => 'Aucun son disponible ; la vidéo continue',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Passage au décodage logiciel ; consommation d\'énergie accrue possible',
			'mediaPlayer.notice.videoDecodeProblem' => 'Essayez une autre qualité ; l\'image peut présenter des artefacts',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Exportez les journaux pour signaler des problèmes de lecture répétés',
			'mediaPlayer.notice.issuesSheetTitle' => 'Problèmes de lecture',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'Survenu ${count} fois',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'À ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'Aucun problème enregistré',
			'mediaPlayer.notice.exportLogsAction' => 'Exporter les journaux',
			'mediaPlayer.imageLoadFailed' => 'Échec du chargement de l\'image',
			'mediaPlayer.unsupportedImageFormat' => 'Format d\'image non pris en charge',
			'mediaPlayer.tryOtherViewer' => 'Essayez d\'utiliser d\'autres visionneuses',
			'diagnostics.infoSectionTitle' => 'Infos de diagnostic',
			'diagnostics.appVersionLabel' => 'Version de l\'application',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Utilisation de la mémoire : ${memMB} Mo',
			'diagnostics.deviceInfoUnavailable' => 'Impossible de récupérer les infos de l\'appareil',
			'diagnostics.secureStorageLabel' => 'Stockage sécurisé',
			'diagnostics.secureStorageHealthy' => 'Disponible',
			'diagnostics.secureStorageRecovered' => 'Réparé automatiquement par réinitialisation (données précédentes effacées)',
			'diagnostics.secureStorageUnavailable' => 'Indisponible (connexion enregistrée avec un chiffrement de secours)',
			'diagnostics.secureStoragePlatformOptOut' => 'Chiffrement local imposé par la politique de la plateforme (trousseau système non utilisé sur macOS)',
			'diagnostics.secureStorageDualWrite' => ' (protection en double écriture activée)',
			'diagnostics.schemaHealthLabel' => 'Schéma de base de données',
			'diagnostics.schemaHealthOk' => 'OK',
			'diagnostics.schemaHealthRepairedNow' => 'Réparé par le filet de sécurité à ce lancement (la migration n\'a pas pris effet)',
			'diagnostics.schemaHealthRepairedBefore' => 'A déjà été réparé par le filet de sécurité',
			'diagnostics.logPolicySectionTitle' => 'Politique de journalisation',
			'diagnostics.configServiceUnavailable' => 'Le service de configuration n\'est pas initialisé. La politique de journalisation ne peut pas être modifiée.',
			'diagnostics.enableLoggingTitle' => 'Activer la journalisation',
			'diagnostics.enableLoggingSubtitle' => 'Désactivez pour arrêter d\'écrire de nouveaux journaux',
			'diagnostics.enableLogPersistenceTitle' => 'Activer la persistance des journaux',
			'diagnostics.enableLogPersistenceSubtitle' => 'Désactivez pour garder les journaux en mémoire uniquement et arrêter les écritures sur disque',
			'diagnostics.minLogLevelTitle' => 'Niveau de journalisation minimal',
			'diagnostics.minLogLevelSubtitle' => 'Les journaux en dessous de ce niveau seront filtrés',
			'diagnostics.maxFileSizeTitle' => 'Limite de taille d\'un fichier',
			'diagnostics.maxFileSizeSubtitle' => 'Effectuer une rotation au seuil atteint',
			'diagnostics.rotatedFileCountTitle' => 'Nombre de fichiers de rotation du journal principal',
			'diagnostics.rotatedFileCountSubtitle' => 'Nombre de fichiers conservés hors fichier actuel',
			'diagnostics.hangFileSizeTitle' => 'Limite de taille du journal des blocages',
			'diagnostics.hangFileSizeSubtitle' => 'Contrôler la croissance du fichier hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'Nombre de fichiers de rotation du journal des blocages',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Contrôler l\'historique conservé pour hang_events',
			'diagnostics.healthSectionTitle' => 'État des journaux',
			'diagnostics.refreshMetrics' => 'Actualiser les métriques',
			'diagnostics.toolsSectionTitle' => 'Outils',
			'diagnostics.privacyNotice' => 'Les journaux peuvent contenir des informations sensibles comme les données de compte et les paramètres de requête. Ne publiez pas les journaux complets dans les tickets ; vérifiez-les d\'abord et envoyez-les par e-mail.',
			'diagnostics.exportLogsTitle' => 'Exporter les journaux',
			'diagnostics.exportLogsSubtitle' => 'Vérifiez les données privées avant de les envoyer aux développeurs',
			'diagnostics.viewLogsTitle' => 'Voir les journaux',
			'diagnostics.viewLogsSubtitle' => 'Consulter les journaux d\'exécution en temps réel',
			'diagnostics.copySupportEmailTitle' => 'Copier l\'e-mail d\'assistance',
			'diagnostics.reportIssueTitle' => 'Signaler un problème',
			'diagnostics.reportIssueSubtitle' => 'Fournissez les étapes de reproduction sur GitHub (ne joignez pas les journaux complets)',
			'diagnostics.healthSummaryUnavailable' => 'Aucune donnée d\'état des journaux pour l\'instant',
			'diagnostics.healthMetricsUnavailable' => 'Les métriques d\'état n\'ont pas encore été collectées',
			'diagnostics.healthNoRiskIndicators' => 'Aucun indicateur de risque détecté',
			'diagnostics.healthAlert.flushFailureTitle' => 'Échecs de vidage',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Écriture des journaux dégradée',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'Le récepteur de fichier est en état dégradé',
			'diagnostics.healthAlert.queueBacklogTitle' => 'File d\'attente d\'écriture saturée',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (seuil=${threshold}, peut augmenter l\'utilisation de la mémoire)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Latence de vidage élevée',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Trop de journaux abandonnés',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (seuil=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Limitation de débit déclenchée',
			'diagnostics.healthAlert.exportFailedTitle' => 'Échecs d\'export des journaux',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'Fichier de journal proche de la limite de taille',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (pression de rotation des E/S plus élevée)',
			'diagnostics.toast.logServiceNotInitialized' => 'Le service de journalisation n\'est pas initialisé',
			'diagnostics.toast.exportSuccess' => 'Journaux exportés. Vérifiez les données privées avant de les envoyer par e-mail.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'Échec de l\'export : ${error}',
			'diagnostics.toast.supportEmailCopied' => 'E-mail d\'assistance copié. Collez-le dans votre client de messagerie et joignez les journaux.',
			'diagnostics.shareSubject' => 'Journaux de diagnostic LoveIwara (contiennent des données sensibles, à partager avec prudence)',
			'logViewer.title' => 'Visionneuse de journaux',
			'logViewer.searchHint' => 'Rechercher dans les journaux...',
			'logViewer.emptyState' => 'Aucun journal',
			'logViewer.copiedToClipboard' => 'Copié dans le presse-papiers',
			'crashRecoveryDialog.title' => 'L\'application s\'est fermée de façon inattendue',
			'crashRecoveryDialog.description' => 'Nous avons détecté une fermeture anormale lors de la dernière session. Veuillez exporter les journaux de diagnostic et les envoyer par e-mail au développeur pour nous aider à corriger le problème.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Dernière version : ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Dernier lancement : ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Dernière exception : ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'Un blocage de l\'interface a été détecté la dernière fois et récupéré automatiquement',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'Un possible gel de l\'interface a été détecté la dernière fois, durant environ ${stalledMs} ms',
			'crashRecoveryDialog.exportGuide' => 'Allez dans Réglages > Diagnostics et retours > Exporter les journaux.',
			'crashRecoveryDialog.privacyHint' => 'Les journaux peuvent contenir des données privées. Vérifiez-les avant de les envoyer à :',
			'crashRecoveryDialog.issueWarning' => 'Ne joignez pas les journaux complets publiquement dans les tickets GitHub',
			'crashRecoveryDialog.acknowledge' => 'Compris',
			'crashRecoveryDialog.supportEmailCopied' => 'E-mail copié',
			'linkInputDialog.title' => 'Saisir un lien',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Reconnaît intelligemment plusieurs liens ${webName} et accède rapidement à la page correspondante dans l\'application (séparez les liens du reste du texte par des espaces)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Veuillez saisir un lien ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'Veuillez saisir un lien',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'Aucun lien ${webName} valide détecté',
			'linkInputDialog.multipleLinksDetected' => 'Plusieurs liens détectés, veuillez en choisir un :',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Lien ${webName} non valide',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Erreur d\'analyse du lien : ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Lien non pris en charge',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Ce type de lien ne peut pas être ouvert directement dans l\'application et doit être consulté avec un navigateur externe.\n\nVoulez-vous ouvrir ce lien dans un navigateur ?',
			'linkInputDialog.openInBrowser' => 'Ouvrir dans le navigateur',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Confirmer l\'ouverture du navigateur',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'Le lien suivant va être ouvert dans un navigateur externe :',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Voulez-vous vraiment continuer ?',
			'linkInputDialog.browserOpenFailed' => 'Échec de l\'ouverture du lien',
			'linkInputDialog.unsupportedLink' => 'Lien non pris en charge',
			_ => null,
		} ?? switch (path) {
			'linkInputDialog.cancel' => 'Annuler',
			'linkInputDialog.confirm' => 'Ouvrir dans le navigateur',
			'log.logManagement' => 'Gestion des journaux',
			'log.enableLogPersistence' => 'Activer la persistance des journaux',
			'log.enableLogPersistenceDesc' => 'Enregistrer les journaux dans la base de données pour analyse',
			'log.logDatabaseSizeLimit' => 'Limite de taille de la base de journaux',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Actuelle : ${size}',
			'log.exportCurrentLogs' => 'Exporter les journaux actuels',
			'log.exportCurrentLogsDesc' => 'Exporter les journaux actuels de l\'application pour aider les développeurs à diagnostiquer les problèmes',
			'log.exportHistoryLogs' => 'Exporter l\'historique des journaux',
			'log.exportHistoryLogsDesc' => 'Exporter les journaux d\'une plage de dates donnée',
			'log.exportMergedLogs' => 'Exporter les journaux fusionnés',
			'log.exportMergedLogsDesc' => 'Exporter les journaux fusionnés d\'une plage de dates donnée',
			'log.showLogStats' => 'Afficher les statistiques des journaux',
			'log.logExportSuccess' => 'Export des journaux réussi',
			'log.logExportFailed' => ({required Object error}) => 'Échec de l\'export des journaux : ${error}',
			'log.showLogStatsDesc' => 'Consulter les statistiques des différents types de journaux',
			'log.logExtractFailed' => ({required Object error}) => 'Échec de l\'obtention des statistiques de journaux : ${error}',
			'log.clearAllLogs' => 'Effacer tous les journaux',
			'log.clearAllLogsDesc' => 'Effacer toutes les données de journal',
			'log.confirmClearAllLogs' => 'Confirmer l\'effacement',
			'log.confirmClearAllLogsDesc' => 'Voulez-vous vraiment effacer toutes les données de journal ? Cette opération est irréversible.',
			'log.clearAllLogsSuccess' => 'Journaux effacés avec succès',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Échec de l\'effacement des journaux : ${error}',
			'log.unableToGetLogSizeInfo' => 'Impossible d\'obtenir les informations de taille des journaux',
			'log.currentLogSize' => 'Taille actuelle des journaux :',
			'log.logCount' => 'Nombre de journaux :',
			'log.logCountUnit' => 'journaux',
			'log.logSizeLimit' => 'Limite de taille des journaux :',
			'log.usageRate' => 'Taux d\'utilisation :',
			'log.exceedLimit' => 'Dépasser la limite',
			'log.remaining' => 'Restant',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'La taille des journaux est dépassée, veuillez nettoyer les anciens journaux ou augmenter la limite de taille',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'La taille des journaux est presque atteinte, veuillez nettoyer les anciens journaux',
			'log.cleaningOldLogs' => 'Nettoyage des anciens journaux...',
			'log.logCleaningCompleted' => 'Nettoyage des journaux terminé',
			'log.logCleaningProcessMayNotBeCompleted' => 'Le nettoyage des journaux n\'est peut-être pas terminé',
			'log.cleanExceededLogs' => 'Nettoyer les journaux excédentaires',
			'log.noLogsToExport' => 'Aucun journal à exporter',
			'log.exportingLogs' => 'Exportation des journaux...',
			'log.noHistoryLogsToExport' => 'Aucun historique de journaux à exporter, utilisez d\'abord l\'application quelque temps',
			'log.selectLogDate' => 'Choisir la date des journaux',
			'log.today' => 'Aujourd\'hui',
			'log.selectMergeRange' => 'Choisir la plage de fusion',
			'log.selectMergeRangeHint' => 'Veuillez choisir la plage horaire des journaux à fusionner',
			'log.selectMergeRangeDays' => ({required Object days}) => '${days} derniers jours',
			'log.logStats' => 'Statistiques des journaux',
			'log.todayLogs' => ({required Object count}) => 'Journaux d\'aujourd\'hui : ${count} journaux',
			'log.recent7DaysLogs' => ({required Object count}) => 'Journaux des 7 derniers jours : ${count} journaux',
			'log.totalLogs' => ({required Object count}) => 'Total des journaux : ${count} journaux',
			'log.setLogDatabaseSizeLimit' => 'Définir la limite de taille de la base de journaux',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Taille actuelle des journaux : ${size}',
			'log.warning' => 'Avertissement',
			'log.newSizeLimit' => ({required Object size}) => 'Nouvelle limite de taille : ${size}',
			'log.confirmToContinue' => 'Confirmez pour continuer',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Limite de taille des journaux définie sur ${size}',
			'emoji.name' => 'Emoji',
			'emoji.size' => 'Taille',
			'emoji.small' => 'Petit',
			'emoji.medium' => 'Moyen',
			'emoji.large' => 'Grand',
			'emoji.extraLarge' => 'Très grand',
			'emoji.copyEmojiLinkSuccess' => 'Lien de l\'emoji copié',
			'emoji.preview' => 'Aperçu de l\'emoji',
			'emoji.library' => 'Bibliothèque d\'emojis',
			'emoji.noEmojis' => 'Aucun emoji',
			'emoji.clickToAddEmojis' => 'Cliquez sur le bouton en haut à droite pour ajouter des emojis',
			'emoji.addEmojis' => 'Ajouter des emojis',
			'emoji.imagePreview' => 'Aperçu de l\'image',
			'emoji.imageLoadFailed' => 'Échec du chargement de l\'image',
			'emoji.loading' => 'Chargement...',
			'emoji.delete' => 'Supprimer',
			'emoji.close' => 'Fermer',
			'emoji.deleteImage' => 'Supprimer l\'image',
			'emoji.confirmDeleteImage' => 'Voulez-vous vraiment supprimer cette image ?',
			'emoji.cancel' => 'Annuler',
			'emoji.batchDelete' => 'Suppression groupée',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Voulez-vous vraiment supprimer les ${count} images sélectionnées ? Cette opération est irréversible.',
			'emoji.deleteSuccess' => 'Supprimé avec succès',
			'emoji.addImage' => 'Ajouter une image',
			'emoji.addImageByUrl' => 'Ajouter par URL',
			'emoji.addImageUrl' => 'Ajouter une URL d\'image',
			'emoji.imageUrl' => 'URL de l\'image',
			'emoji.enterImageUrl' => 'Veuillez saisir l\'URL de l\'image',
			'emoji.add' => 'Ajouter',
			'emoji.batchImport' => 'Importation groupée',
			'emoji.enterJsonUrlArray' => 'Veuillez saisir le tableau d\'URL au format JSON :',
			'emoji.formatExample' => 'Exemple de format :\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Veuillez coller le tableau d\'URL au format JSON',
			'emoji.import' => 'Importer',
			'emoji.importSuccess' => ({required Object count}) => '${count} images importées avec succès',
			'emoji.jsonFormatError' => 'Erreur de format JSON, vérifiez la saisie',
			'emoji.createGroup' => 'Créer un groupe d\'emojis',
			'emoji.groupName' => 'Nom du groupe',
			'emoji.enterGroupName' => 'Veuillez saisir le nom du groupe',
			'emoji.create' => 'Créer',
			'emoji.editGroupName' => 'Modifier le nom du groupe',
			'emoji.save' => 'Enregistrer',
			'emoji.deleteGroup' => 'Supprimer le groupe',
			'emoji.confirmDeleteGroup' => 'Voulez-vous vraiment supprimer ce groupe d\'emojis ? Toutes les images du groupe seront également supprimées.',
			'emoji.imageCount' => ({required Object count}) => '${count} image(s)',
			'emoji.selectEmoji' => 'Choisir un emoji',
			'emoji.noEmojisInGroup' => 'Aucun emoji dans ce groupe',
			'emoji.goToSettingsToAddEmojis' => 'Allez dans les réglages pour ajouter des emojis',
			'emoji.emojiManagement' => 'Gestion des emojis',
			'emoji.manageEmojiGroupsAndImages' => 'Gérer les groupes d\'emojis et les images',
			'emoji.uploadLocalImages' => 'Envoyer des images locales',
			'emoji.uploadingImages' => 'Envoi des images',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Envoi de ${count} images, veuillez patienter...',
			'emoji.doNotCloseDialog' => 'Ne fermez pas cette fenêtre',
			'emoji.uploadSuccess' => ({required Object count}) => '${count} images envoyées avec succès',
			'emoji.uploadFailed' => ({required Object count}) => 'Échec : ${count}',
			'emoji.uploadFailedMessage' => 'Échec de l\'envoi de l\'image, vérifiez la connexion réseau ou le format du fichier',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Une erreur est survenue pendant l\'envoi : ${error}',
			'searchFilter.selectField' => 'Sélectionner un champ',
			'searchFilter.add' => 'Ajouter',
			'searchFilter.clear' => 'Effacer',
			'searchFilter.clearAll' => 'Tout effacer',
			'searchFilter.generatedQuery' => 'Requête générée',
			'searchFilter.copyToClipboard' => 'Copier dans le presse-papiers',
			'searchFilter.copied' => 'Copié',
			'searchFilter.filterCount' => ({required Object count}) => '${count} filtres',
			'searchFilter.filterSettings' => 'Paramètres de filtre',
			'searchFilter.field' => 'Champ',
			'searchFilter.operator' => 'Opérateur',
			'searchFilter.language' => 'Langue',
			'searchFilter.value' => 'Valeur',
			'searchFilter.dateRange' => 'Plage de dates',
			'searchFilter.numberRange' => 'Plage de nombres',
			'searchFilter.from' => 'De',
			'searchFilter.to' => 'À',
			'searchFilter.date' => 'Date',
			'searchFilter.number' => 'Nombre',
			'searchFilter.boolean' => 'Booléen',
			'searchFilter.tags' => 'Tags',
			'searchFilter.select' => 'Sélectionner',
			'searchFilter.clickToSelectDate' => 'Cliquez pour choisir une date',
			'searchFilter.pleaseEnterValidNumber' => 'Veuillez saisir un nombre valide',
			'searchFilter.pleaseEnterValidDate' => 'Veuillez saisir une date valide (AAAA-MM-JJ)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'La valeur de début doit être inférieure à la valeur de fin',
			'searchFilter.startDateMustBeBeforeEndDate' => 'La date de début doit être antérieure à la date de fin',
			'searchFilter.pleaseFillStartValue' => 'Veuillez saisir la valeur de début',
			'searchFilter.pleaseFillEndValue' => 'Veuillez saisir la valeur de fin',
			'searchFilter.rangeValueFormatError' => 'Format de valeur de plage incorrect',
			'searchFilter.contains' => 'Contient',
			'searchFilter.equals' => 'Égal à',
			'searchFilter.notEquals' => 'Différent de',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Plage',
			'searchFilter.kIn' => 'Contient au moins un',
			'searchFilter.notIn' => 'Ne contient aucun',
			'searchFilter.username' => 'Nom d\'utilisateur',
			'searchFilter.nickname' => 'Pseudo',
			'searchFilter.registrationDate' => 'Date d\'inscription',
			'searchFilter.description' => 'Description',
			'searchFilter.title' => 'Titre',
			'searchFilter.body' => 'Corps',
			'searchFilter.author' => 'Auteur',
			'searchFilter.publishDate' => 'Date de publication',
			'searchFilter.private' => 'Privé',
			'searchFilter.duration' => 'Durée (secondes)',
			'searchFilter.likes' => 'J\'aime',
			'searchFilter.views' => 'Vues',
			'searchFilter.comments' => 'Commentaires',
			'searchFilter.rating' => 'Note',
			'searchFilter.imageCount' => 'Nombre d\'images',
			'searchFilter.videoCount' => 'Nombre de vidéos',
			'searchFilter.createDate' => 'Date de création',
			'searchFilter.content' => 'Contenu',
			'searchFilter.all' => 'Tout',
			'searchFilter.adult' => 'Adulte',
			'searchFilter.general' => 'Général',
			'searchFilter.yes' => 'Oui',
			'searchFilter.no' => 'Non',
			'searchFilter.users' => 'Utilisateurs',
			'searchFilter.videos' => 'Vidéos',
			'searchFilter.images' => 'Images',
			'searchFilter.posts' => 'Publications',
			'searchFilter.forumThreads' => 'Sujets du forum',
			'searchFilter.forumPosts' => 'Messages du forum',
			'searchFilter.playlists' => 'Playlists',
			'searchFilter.sortTypes.relevance' => 'Pertinence',
			'searchFilter.sortTypes.latest' => 'Récents',
			'searchFilter.sortTypes.views' => 'Vues',
			'searchFilter.sortTypes.likes' => 'J\'aime',
			'searchFilter.drawerSubtitle' => 'Les changements s\'appliquent aussitôt',
			'firstTimeSetup.welcome.title' => 'Bienvenue',
			'firstTimeSetup.welcome.subtitle' => 'Commençons votre configuration personnalisée',
			'firstTimeSetup.welcome.description' => 'Quelques étapes suffisent pour adapter la meilleure expérience pour vous',
			'firstTimeSetup.basic.title' => 'Réglages de base',
			'firstTimeSetup.basic.subtitle' => 'Personnalisez votre expérience',
			'firstTimeSetup.basic.description' => 'Choisissez les préférences qui vous conviennent',
			'firstTimeSetup.network.title' => 'Paramètres réseau',
			'firstTimeSetup.network.subtitle' => 'Configurez les options réseau',
			'firstTimeSetup.network.description' => 'Ajustez selon votre environnement réseau',
			'firstTimeSetup.network.tip' => 'Un redémarrage est nécessaire après une configuration réussie pour qu\'elle prenne effet',
			'firstTimeSetup.theme.title' => 'Réglages du thème',
			'firstTimeSetup.theme.subtitle' => 'Choisissez l\'apparence que vous préférez',
			'firstTimeSetup.theme.description' => 'Personnalisez votre expérience visuelle',
			'firstTimeSetup.player.title' => 'Réglages du lecteur',
			'firstTimeSetup.player.subtitle' => 'Configurez les commandes de lecture',
			'firstTimeSetup.player.description' => 'Réglez rapidement les préférences de lecture courantes',
			'firstTimeSetup.spatial.title' => 'Lecture spatiale',
			'firstTimeSetup.spatial.subtitle' => 'Regarder et naviguer sur le casque',
			'firstTimeSetup.spatial.description' => 'Sur le casque, les vidéos et galeries apparaissent dans l\'espace autour de vous plutôt qu\'à l\'intérieur de ce panneau flottant',
			'firstTimeSetup.completion.title' => 'Terminer la configuration',
			'firstTimeSetup.completion.subtitle' => 'Vous êtes prêt à commencer l\'aventure',
			'firstTimeSetup.completion.description' => 'Veuillez lire et accepter les contrats associés',
			'firstTimeSetup.completion.agreementTitle' => 'Contrat d\'utilisation et règles de la communauté',
			'firstTimeSetup.completion.agreementDesc' => 'Avant d\'utiliser cette application, veuillez lire attentivement et accepter notre contrat d\'utilisation et les règles de la communauté. Ces conditions aident à maintenir un bon environnement.',
			'firstTimeSetup.completion.checkboxTitle' => 'J\'ai lu et j\'accepte le contrat d\'utilisation et les règles de la communauté',
			'firstTimeSetup.completion.checkboxSubtitle' => 'Vous ne pouvez pas utiliser l\'application si vous refusez',
			'firstTimeSetup.common.settingsChangeableTip' => 'Ces réglages peuvent être modifiés à tout moment dans Réglages',
			'firstTimeSetup.common.previousStep' => 'Étape précédente',
			'firstTimeSetup.common.nextStep' => 'Étape suivante',
			'firstTimeSetup.common.finishSetup' => 'Terminer la configuration',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Veuillez d\'abord accepter le contrat d\'utilisation et les règles de la communauté',
			'proxyHelper.systemProxyDetected' => 'Proxy système détecté',
			'proxyHelper.copied' => 'Copié',
			'proxyHelper.copy' => 'Copier',
			'tagSelector.selectTags' => 'Sélectionner des tags',
			'tagSelector.clickToSelectTags' => 'Cliquez pour sélectionner des tags',
			'tagSelector.addTag' => 'Ajouter un tag',
			'tagSelector.removeTag' => 'Retirer le tag',
			'tagSelector.deleteTag' => 'Supprimer le tag',
			'tagSelector.usageInstructions' => 'Ajoutez d\'abord des tags, puis cliquez pour en sélectionner parmi les tags existants',
			'tagSelector.usageInstructionsTooltip' => 'Mode d\'emploi',
			'tagSelector.addTagTooltip' => 'Ajouter un tag',
			'tagSelector.removeTagTooltip' => 'Retirer le tag',
			'tagSelector.cancelSelection' => 'Annuler la sélection',
			'tagSelector.selectAll' => 'Tout sélectionner',
			'tagSelector.cancelSelectAll' => 'Annuler la sélection globale',
			'tagSelector.delete' => 'Supprimer',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Mise à l\'échelle et débruitage vidéo en temps réel, améliorant la qualité des vidéos d\'animation',
			'anime4k.settings' => 'Réglages Anime4K',
			'anime4k.preset' => 'Préréglage Anime4K',
			'anime4k.disable' => 'Désactiver Anime4K',
			'anime4k.disableDescription' => 'Désactiver les effets d\'amélioration vidéo',
			'anime4k.highQualityPresets' => 'Préréglages haute qualité',
			'anime4k.fastPresets' => 'Préréglages rapides',
			'anime4k.litePresets' => 'Préréglages légers',
			'anime4k.moreLitePresets' => 'Préréglages très légers',
			'anime4k.customPresets' => 'Préréglages personnalisés',
			'anime4k.presetGroups.highQuality' => 'Haute qualité',
			'anime4k.presetGroups.fast' => 'Rapide',
			'anime4k.presetGroups.lite' => 'Léger',
			'anime4k.presetGroups.moreLite' => 'Très léger',
			'anime4k.presetGroups.custom' => 'Personnalisé',
			'anime4k.presetDescriptions.mode_a_hq' => 'Adapté à la plupart des animations 1080p, en particulier celles présentant du flou, du rééchantillonnage et des artefacts de compression. Offre la meilleure qualité perçue.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Adapté aux animations présentant un léger flou ou des halos dus à la mise à l\'échelle. Réduit efficacement les halos et l\'aliasing.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Adapté aux sources de haute qualité (animations ou films 1080p natifs, par exemple). Débruite et offre le meilleur PSNR.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Version améliorée du mode A, offrant une qualité perçue optimale et reconstruisant presque toutes les lignes dégradées. Peut produire un excès de netteté ou des halos.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Version améliorée du mode B, offrant une meilleure qualité perçue, optimisant davantage les lignes et réduisant les artefacts.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Version du mode C à qualité perçue améliorée, conservant un PSNR élevé tout en tentant de reconstruire certains détails de lignes.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Version rapide du mode A, équilibrant qualité et performances, adaptée à la plupart des animations 1080p.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Version rapide du mode B, pour traiter les légers artefacts et halos avec un coût réduit.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Version rapide du mode C, pour un débruitage et une mise à l\'échelle rapides des sources de haute qualité.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Version rapide du mode A+A, visant une meilleure qualité perçue sur les appareils peu puissants.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Version rapide du mode B+B, offrant une meilleure réparation des lignes et un traitement des artefacts sur les appareils peu puissants.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Version rapide du mode C+A, traitant rapidement les sources de haute qualité tout en offrant une légère réparation des lignes.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Mise à l\'échelle x2 ultra-rapide via le modèle CNN le plus rapide uniquement, sans réparation ni débruitage, coût minimal.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Mise à l\'échelle et défloutage rapides via des algorithmes classiques non CNN, meilleurs que ceux du lecteur par défaut avec un coût très faible.',
			'anime4k.presetDescriptions.restore_s_only' => 'Réparation uniquement via le modèle CNN le plus rapide, sans mise à l\'échelle. Adapté à la lecture en résolution native lorsque vous voulez améliorer la qualité.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Débruitage rapide par filtrage bilatéral classique, très rapide, adapté au bruit léger.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Mise à l\'échelle rapide via des algorithmes classiques, coût très faible, meilleure que les réglages par défaut du lecteur.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (rapide) + assombrissement des lignes, ajoutant un effet d\'assombrissement au mode A rapide pour des lignes plus marquées et stylisées.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + affinage des lignes, ajoutant un effet d\'affinage au mode A haute qualité pour un rendu plus fin.',
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
			'anime4k.presetNames.upscale_only_s' => 'Mise à l\'échelle CNN (ultra rapide)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Mise à l\'échelle et défloutage (rapide)',
			'anime4k.presetNames.restore_s_only' => 'Restauration (ultra rapide)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Débruitage bilatéral (ultra rapide)',
			'anime4k.presetNames.upscale_non_cnn' => 'Mise à l\'échelle non CNN (ultra rapide)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (rapide) + assombrissement des lignes',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + affinage des lignes',
			'anime4k.performanceTip' => '💡 Astuce : choisissez des préréglages adaptés aux performances de l\'appareil. Les appareils d\'entrée de gamme devraient utiliser des préréglages légers.',
			'anime4k.compatibilityTip' => '⚠️ Certains GPU mobiles (ex. Kirin 980 / Mali-G76) ne peuvent afficher aucun shader personnalisé. Si l\'image devient noire alors que le son continue, désactivez Anime4K ici.',
			'anime4k.autoDisabledOnRenderFailure' => 'Le GPU de votre appareil n\'a pas pu appliquer le shader Anime4K ; il a donc été désactivé automatiquement.',
			'siteMode.title' => 'Mode de site',
			'siteMode.mainSite' => 'Principal',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Actuel : ${currentSite} · Touchez pour passer à ${nextSite}',
			'siteMode.dialogTitle' => 'Changer de mode de site',
			'siteMode.dialogDescription' => 'Le changement actualisera toute l\'app et réinitialisera les listes et l\'état des pages chargés précédemment.',
			'siteMode.chooseLinkTargetTitle' => 'Choisir le site cible',
			'siteMode.chooseLinkTargetDescription' => 'Ce lien n\'inclut pas de domaine. Choisissez de l\'ouvrir dans Principal ou AI.',
			'siteMode.chooseLinkTargetHint' => 'Une fois ouvert, cette page et les requêtes de détail suivantes continueront d\'utiliser le site sélectionné.',
			'siteMode.alreadyUsing' => 'Vous utilisez déjà ce mode de site.',
			'siteMode.openInSite' => ({required Object site}) => 'Ouvrir dans ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'Après confirmation, les requêtes suivantes utiliseront le mode ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Passé à ${site}. L\'app a été actualisée.',
			'savedSearchConfig.title' => 'Filtres enregistrés',
			'savedSearchConfig.empty' => 'Aucun filtre enregistré',
			'savedSearchConfig.saveTooltip' => 'Enregistrer le filtre actuel',
			'savedSearchConfig.namePromptTitle' => 'Enregistrer le filtre',
			'savedSearchConfig.nameLabel' => 'Nom',
			'savedSearchConfig.nameHint' => 'Saisir un nom',
			'savedSearchConfig.saveSuccess' => 'Filtre enregistré',
			'savedSearchConfig.deleteSuccess' => 'Filtre supprimé',
			'savedSearchConfig.addCurrent' => 'Enregistrer le filtre actuel',
			'savedSearchConfig.reorderHint' => 'Appuyez longuement et faites glisser pour réorganiser',
			'savedSearchConfig.rename' => 'Renommer',
			'savedSearchConfig.unnamed' => 'Sans nom',
			'savedSearchConfig.noConditions' => 'Tout le contenu (sans filtre)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} tags',
			'savedSearch.title' => 'Recherches enregistrées',
			'savedSearch.empty' => 'Aucune recherche enregistrée',
			'savedSearch.saveTooltip' => 'Enregistrer la recherche actuelle',
			'savedSearch.namePromptTitle' => 'Enregistrer la recherche',
			'savedSearch.nameLabel' => 'Nom',
			'savedSearch.nameHint' => 'Saisir un nom',
			'savedSearch.saveSuccess' => 'Recherche enregistrée',
			'savedSearch.deleteSuccess' => 'Recherche supprimée',
			'savedSearch.addCurrent' => 'Enregistrer la recherche actuelle',
			'savedSearch.reorderHint' => 'Appuyez longuement et faites glisser pour réorganiser',
			'savedSearch.rename' => 'Renommer',
			'savedSearch.noKeyword' => '(Aucun mot-clé)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} filtres',
			'defaultBlacklistReminder.title' => 'Liste noire de tags par défaut détectée',
			'defaultBlacklistReminder.content' => 'Votre compte utilise toujours la liste noire de tags appliquée automatiquement par le site à chaque nouveau compte. Voulez-vous la consulter et la gérer ?',
			'defaultBlacklistReminder.goManage' => 'Gérer',
			'defaultBlacklistReminder.dismiss' => 'Plus tard',
			'colorVisionAssist.title' => 'Aide à la vision des couleurs',
			'colorVisionAssist.description' => 'Corrige les couleurs des vidéos pour les personnes daltoniennes ; utilisable avec Anime4K',
			'colorVisionAssist.galleryDescription' => 'Corrige les couleurs des images de la galerie pour les personnes daltoniennes (indépendamment du réglage du lecteur)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Corrige les couleurs des images de la galerie pour les personnes daltoniennes. S\'applique uniquement à la visionneuse 2D de ce panneau — les images de l\'écran spatial sont rendues nativement et ne passent pas par ce filtre',
			'colorVisionAssist.disable' => 'Désactivé',
			'colorVisionAssist.disableDescription' => 'Aucune correction des couleurs',
			'colorVisionAssist.protanopia' => 'Aide au rouge (protanopie)',
			'colorVisionAssist.protanopiaDescription' => 'Pour la protanopie — difficulté à distinguer le rouge',
			'colorVisionAssist.deuteranopia' => 'Aide au vert (deutéranopie)',
			'colorVisionAssist.deuteranopiaDescription' => 'Pour la deutéranopie — difficulté à distinguer le vert',
			'colorVisionAssist.tritanopia' => 'Aide au bleu (tritanopie)',
			'colorVisionAssist.tritanopiaDescription' => 'Pour la tritanopie — difficulté à distinguer le bleu et le jaune',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} appliqué, effet immédiat',
			'colorVisionAssist.disabledToast' => 'Aide à la vision des couleurs désactivée',
			'externalPlayer.title' => 'Ouvrir avec une autre application',
			'externalPlayer.description' => 'Transmettez la vidéo en cours à un autre lecteur de cet appareil, comme Skybox ou Pigasus sur un casque VR, ou MX Player et VLC sur un téléphone',
			'externalPlayer.openWithOtherApp' => 'Choisir une autre application',
			'externalPlayer.openWithOtherAppDescription' => 'Afficher le sélecteur du système et choisir un lecteur pour prendre le relais',
			'externalPlayer.openWithSystemPlayer' => 'Ouvrir dans le lecteur par défaut',
			'externalPlayer.openWithSystemPlayerDescription' => 'Le transmettre à l\'application vidéo par défaut du système',
			'externalPlayer.copyLink' => 'Copier le lien de la vidéo',
			'externalPlayer.copyLinkDescription' => 'Pour les lecteurs qui acceptent uniquement le collage d\'une URL, comme Skybox ou DeoVR',
			'externalPlayer.linkCopied' => 'Lien de la vidéo copié',
			'externalPlayer.sourceLocal' => 'Fichier local',
			'externalPlayer.sourceOnline' => 'Lien direct',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Lien direct · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'Les liens directs expirent ; un lecteur externe peut donc s\'arrêter en cours de route. Télécharger d\'abord est la solution fiable.',
			'externalPlayer.vrPlayerHint' => 'Si votre lecteur VR est absent du sélecteur, utilisez Copier le lien de la vidéo et collez-le dans ce lecteur.',
			'externalPlayer.noHandler' => 'Aucune application de cet appareil ne peut ouvrir la vidéo',
			'externalPlayer.handoffFailed' => ({required Object message}) => 'Échec de la transmission : ${message}',
			'externalPlayer.handoffFailedUnknown' => 'Échec de la transmission',
			'externalPlayer.sourceUnavailable' => 'Impossible d\'obtenir l\'adresse de la vidéo en cours, veuillez réessayer',
			'externalPlayer.localFileMissing' => 'Le fichier local n\'existe plus',
			'externalPlayer.handedOff' => 'Transmis au lecteur externe',
			'externalPlayer.desktopSectionTitle' => 'Lecteurs externes',
			'externalPlayer.managePlayers' => 'Gérer les lecteurs externes',
			'externalPlayer.managePlayersDescWindows' => 'Les lecteurs PCVR comme HereSphere, DeoVR et Whirligig ne sont pas l\'application par défaut du système. Indiquez leur .exe ici et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.',
			'externalPlayer.managePlayersDescMac' => 'Indiquez ici des lecteurs comme IINA, VLC ou mpv et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.',
			'externalPlayer.managePlayersDescLinux' => 'Indiquez ici des lecteurs comme mpv, VLC ou Celluloid et vous pourrez transmettre la vidéo en cours directement depuis le lecteur.',
			'externalPlayer.pickExecutableHintWindows' => 'Choisissez le .exe principal dans le dossier d\'installation du lecteur, par ex. HereSphere.exe ou vlc.exe. Les raccourcis du bureau (.lnk) ne fonctionneront pas.',
			'externalPlayer.pickExecutableHintMac' => 'Choisissez le .app du lecteur dans Applications, par ex. IINA.app — l\'exécutable réel qu\'il contient est localisé pour vous.',
			'externalPlayer.pickExecutableHintLinux' => 'Choisissez l\'exécutable du lecteur, par ex. /usr/bin/mpv. La commande which mpv vous indiquera son emplacement.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'Une fois configuré, il apparaît comme entrée distincte sous Ouvrir avec une autre application sur la page du lecteur. Les plus courants : ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'Aucun lecteur installé trouvé. Les dossiers d\'installation personnalisés et les versions portables ne peuvent pas être détectés — utilisez Ajouter un lecteur pour en indiquer un vous-même.',
			'externalPlayer.detectNothingNew' => 'Aucun nouveau lecteur trouvé ; tout ce qui est installé figure déjà dans la liste',
			'externalPlayer.detectFailed' => 'Échec de la détection — utilisez Ajouter un lecteur pour en indiquer un vous-même',
			'externalPlayer.advancedOptions' => 'Avancé',
			'externalPlayer.playerNameHint' => 'Laissez vide pour utiliser le nom du fichier',
			'externalPlayer.executablePathRequired' => 'Choisissez d\'abord l\'exécutable du lecteur',
			'externalPlayer.playerCount' => ({required Object count}) => '${count} configuré(s)',
			'externalPlayer.noPlayerConfigured' => 'Aucun lecteur externe configuré pour l\'instant',
			'externalPlayer.autoDetect' => 'Détection automatique',
			'externalPlayer.detecting' => 'Détection…',
			'externalPlayer.detectFound' => ({required Object count}) => '${count} lecteur(s) trouvé(s)',
			'externalPlayer.detectNothingFound' => 'Aucun nouveau lecteur trouvé, ajoutez-en un manuellement',
			'externalPlayer.autoDetectedTag' => 'détecté',
			'externalPlayer.addPlayer' => 'Ajouter un lecteur',
			'externalPlayer.editPlayer' => 'Modifier le lecteur',
			'externalPlayer.playerName' => 'Nom',
			'externalPlayer.executablePath' => 'Exécutable',
			'externalPlayer.browse' => 'Parcourir',
			'externalPlayer.argumentTemplate' => 'Arguments de lancement',
			'externalPlayer.argumentTemplateHint' => 'Utilisez {input} pour le chemin ou l\'URL de la vidéo. Laissez vide pour le transmettre comme unique argument.',
			'externalPlayer.nameAndPathRequired' => 'Le nom et l\'exécutable sont tous deux obligatoires',
			'externalPlayer.testLaunch' => 'Tester le lancement',
			'externalPlayer.testLaunched' => 'Lecteur lancé',
			'externalPlayer.testFailed' => 'Échec du lancement, vérifiez le chemin de l\'exécutable',
			'externalPlayer.executableMissing' => 'Exécutable introuvable',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'Ouvrir dans ${name}',
			'externalPlayer.managePlayersEntry' => 'Gérer les lecteurs externes…',
			'watchLater.title' => 'Regarder plus tard',
			'watchLater.addToWatchLater' => 'Regarder plus tard',
			'watchLater.removeFromWatchLater' => 'Retirer de Regarder plus tard',
			'watchLater.addedToWatchLater' => 'Ajouté à Regarder plus tard',
			'watchLater.alreadyInWatchLater' => 'Déjà dans Regarder plus tard',
			'watchLater.removedFromWatchLater' => 'Retiré de Regarder plus tard',
			'watchLater.removedCount' => ({required Object count}) => '${count} éléments retirés',
			'watchLater.viewWatchLaterList' => 'Voir la liste',
			'watchLater.addFailed' => 'Échec de l\'ajout à Regarder plus tard',
			'watchLater.invalidItem' => 'Indisponible',
			'watchLater.clearWatched' => 'Effacer les vus',
			'watchLater.watchedCleared' => ({required Object count}) => '${count} éléments vus effacés',
			'watchLater.noWatchedToClear' => 'Aucun élément vu à effacer',
			'watchLater.emptyVideo' => 'Aucune vidéo dans Regarder plus tard',
			'watchLater.emptyGallery' => 'Aucune galerie dans Regarder plus tard',
			'watchLater.filterAll' => 'Tout',
			'watchLater.filterUnwatched' => 'Non vus',
			'watchLater.sortRecentlyAdded' => 'Ajoutés récemment',
			'watchLater.sortEarliestAdded' => 'Ajoutés en premier',
			'watchLater.watched' => 'Vus',
			'watchLater.playlistLoadFailed' => 'Échec du chargement des playlists',
			'watchLater.noPlaylists' => 'Aucune playlist',
			'watchLater.undo' => 'Annuler',
			'watchLater.clearWatchedConfirm' => 'Effacer tout ce que vous avez déjà regardé dans cet onglet ? Cette action est irréversible.',
			'watchLater.emptyUnwatchedVideo' => 'Plus rien à regarder ici',
			'watchLater.emptyUnwatchedGallery' => 'Plus rien à regarder ici',
			'watchLater.queueLoadFailed' => 'Échec du chargement, touchez pour réessayer',
			'mediaMenu.like' => 'J\'aime',
			'mediaMenu.unlike' => 'Je n\'aime plus',
			'mediaMenu.viewAuthor' => 'Voir l\'auteur',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} dossiers',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} listes de lecture',
			'mediaMenu.downloaded' => 'Téléchargé',
			'mediaPreview.preview' => 'Aperçu',
			'mediaPreview.openDetail' => 'Ouvrir',
			'mediaPreview.moreActions' => 'Plus d\'actions',
			'mediaPreview.previousImage' => 'Image précédente',
			'mediaPreview.nextImage' => 'Image suivante',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} images',
			'playbackQueue.upNext' => 'À suivre',
			'playbackQueue.sourceTab' => 'Source',
			'playbackQueue.emptyQueue' => 'Rien à lire dans cette file',
			'playbackQueue.emptyGalleryQueue' => 'Aucune galerie dans cette file',
			'playbackQueue.nowPlaying' => 'Lecture en cours',
			'playbackQueue.myPlaylists' => 'Mes playlists',
			'playbackQueue.authorPlaylists' => 'Playlists de l\'auteur',
			'playbackQueue.openQueue' => 'À suivre',
			'playbackQueue.continueInQueue' => 'Continuer la lecture depuis la file actuelle',
			'playbackQueue.continueInQueueSubtitle' => 'Lit l\'élément suivant automatiquement ; désactive « répéter à la fin »',
			'playbackQueue.repeatDisabledByQueue' => 'Désactivé lorsque « continuer la lecture depuis la file actuelle » est activé',
			'playbackQueue.playNext' => 'Lire ensuite',
			'playbackQueue.queueEnded' => 'C\'est le dernier élément de la file',
			'playbackQueue.playNextHint' => 'Touchez pour lire l\'élément suivant, appuyez longuement pour ouvrir « À suivre »',
			'playbackQueue.authorVideos' => 'Vidéos de l\'auteur',
			'playbackQueue.authorGalleries' => 'Galeries de l\'auteur',
			'playbackQueue.favoriteFolders' => 'Dossiers favoris',
			'playbackQueue.localFiles' => 'Sur cet appareil',
			'playbackQueue.currentFolder' => 'Dossier de ce fichier',
			'playbackQueue.playThisFolder' => 'Voir la file de vidéos de ce dossier',
			'playbackQueue.browseThisFolder' => 'Voir la file de galeries de ce dossier',
			'playbackQueue.downloads' => 'Téléchargés',
			'playbackQueue.otherPlaylists' => 'Playlists d\'autres utilisateurs',
			'playbackQueue.nothingHere' => 'Rien ici',
			'vrFormat.playInSpace' => 'Lire dans le lecteur spatial',
			'vrFormat.handingOff' => 'Transfert vers l\'espace…',
			'vrFormat.title' => 'Mode de lecture',
			'vrFormat.spatialSectionTitle' => 'Lecture spatiale',
			'vrFormat.spatialSectionDesc' => 'Sur le casque, une vidéo n\'est pas affichée dans ce panneau — le lecteur spatial la place sur un écran dans la pièce.',
			'vrFormat.spatialPanelEntry' => 'Panneau de contrôle spatial',
			'vrFormat.spatialPanelEntryDesc' => 'La distance, la taille et la courbure de l\'écran, l\'environnement d\'arrière-plan, ainsi que la vitesse, la répétition et le masquage automatique se trouvent dans le panneau de contrôle spatial.',
			'vrFormat.spatialGuideEntry' => 'Guide des commandes du casque',
			'vrFormat.spatialGuideEntryDesc' => 'Boutons de la manette, saisie de l\'écran, déplacement au stick et changements de page',
			'vrFormat.spatialFlatOmitted' => 'Les gestes tactiles, l\'amélioration d\'image et les paramètres audio/vidéo ne s\'appliquent qu\'au lecteur 2D ; le lecteur spatial utilise un autre moteur, ils ne sont donc pas listés ici.',
			'vrFormat.spatialGallerySectionTitle' => 'Galerie spatiale',
			'vrFormat.spatialGalleryPanelDesc' => 'L\'intervalle du diaporama, la répétition d\'un seul clip et la courbure de l\'écran se règlent dans le panneau de contrôle spatial.',
			'vrFormat.autoEnterGallery' => 'Ouvrir les images de galerie dans la galerie spatiale',
			'vrFormat.autoEnterGalleryDesc' => 'Sur Quest, toucher une image ouvre toute la galerie sur l\'écran flottant, avec bande de vignettes, diaporama et pagination à la manette, au lieu de la visionneuse intégrée à ce panneau.',
			'vrFormat.panelSettings' => 'Panneau et arrière-plan',
			'vrFormat.panelSettingsDesc' => 'À quelle distance se trouve ce panneau et quelle part de votre pièce apparaît derrière',
			'vrFormat.panelDistance' => 'Distance du panneau',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Réinitialiser le placement',
			'vrFormat.panelResetBackground' => 'Réinitialiser',
			'vrFormat.panelBackground' => 'Transparence de l\'arrière-plan',
			'vrFormat.panelBackgroundHint' => '0 % : environnement noir · 100 % : votre pièce réelle, éclairée par l\'ambiance',
			'vrFormat.panelUnavailable' => 'Le panneau n\'est pas en place pour le moment — réessayez dans un instant',
			'vrFormat.desc' => 'Choisissez la géométrie avec laquelle lire cette vidéo. Le site ne fournit pas cette information, la détection automatique ne donne donc qu\'un point de départ — votre choix l\'emporte.',
			'vrFormat.sectionFlat' => 'Plat',
			'vrFormat.sectionStereo' => '3D plat',
			'vrFormat.sectionPanorama' => 'Panorama VR',
			'vrFormat.flat' => 'Vidéo normale',
			'vrFormat.flatDesc' => 'Lire telle quelle, sans remappage',
			'vrFormat.flatSideBySide' => '3D côte à côte',
			'vrFormat.flatSideBySideDesc' => 'Un œil par moitié, gauche et droite ; affiche l\'œil gauche et rétablit ses proportions',
			'vrFormat.flatTopBottom' => '3D haut-bas',
			'vrFormat.flatTopBottomDesc' => 'Un œil par moitié, haut et bas ; affiche la moitié supérieure et rétablit ses proportions',
			'vrFormat.vr180SideBySide' => 'VR180 côte à côte',
			'vrFormat.vr180SideBySideDesc' => 'Panorama hémisphérique avec les deux yeux — la source VR la plus courante',
			'vrFormat.vr180Mono' => 'VR180 mono',
			'vrFormat.vr180MonoDesc' => 'Panorama hémisphérique, un seul œil par image',
			'vrFormat.vr360Mono' => 'VR360 mono',
			'vrFormat.vr360MonoDesc' => 'Panorama à 360°, un seul œil par image',
			'vrFormat.vr360TopBottom' => 'VR360 haut-bas',
			'vrFormat.vr360TopBottomDesc' => 'Panorama à 360° avec les deux yeux empilés',
			'vrFormat.resetView' => 'Réinitialiser la vue',
			'vrFormat.resetViewDesc' => 'Ramener la direction du regard et le champ de vision vers l\'avant',
			_ => null,
		} ?? switch (path) {
			'vrFormat.resetToAuto' => 'Revenir à la détection auto.',
			'vrFormat.resetToAutoDesc' => 'Oublier le choix manuel pour cette vidéo et laisser la détection décider à nouveau',
			'vrFormat.manualBadge' => 'Défini manuellement',
			'vrFormat.panoramaHint' => 'Faites glisser l\'image pour regarder autour, pincez pour changer le champ de vision',
			'vrFormat.panoramaGestureNotice' => 'Pendant que vous regardez autour, faire glisser tourne la vue — utilisez la barre de progression pour vous déplacer',
			'vrFormat.shaderUnsupported' => 'Cet appareil ne peut pas afficher de panorama en direct ; affichage d\'un seul œil à la place',
			'vrFormat.handoffTooltip' => 'Lire autrement',
			'vrFormat.suggestedBadge' => 'Suggéré',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Semble être ${format} — touchez pour basculer',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Il s\'agit peut-être d\'une vidéo VR (${format})',
			'vrFormat.suggestionTitleShort' => 'Il s\'agit peut-être d\'une vidéo VR',
			'vrFormat.suggestionAction' => 'Lire en VR',
			'vrFormat.suggestionDismiss' => 'Ignorer',
			'localMedia.browse.pinnedSection' => 'Accès rapide',
			'localMedia.browse.sourcesSection' => 'Dossiers',
			'localMedia.browse.pin' => 'Ajouter à l\'accès rapide',
			'localMedia.browse.unpin' => 'Retirer de l\'accès rapide',
			'localMedia.browse.pinned' => 'Ajouté à l\'accès rapide',
			'localMedia.browse.unpinned' => 'Retiré de l\'accès rapide',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} dossiers',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} vidéos',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} image(s)',
			'localMedia.browse.emptyFolder' => 'Ce dossier est vide',
			'localMedia.browse.videosSection' => 'Vidéos',
			'localMedia.browse.imagesSection' => 'Images',
			'localMedia.browse.galleriesSection' => 'Galeries',
			'localMedia.browse.filterAll' => 'Tout',
			'localMedia.browse.searchInFolder' => 'Rechercher dans ce dossier',
			'localMedia.browse.searchHint' => 'Rechercher par nom',
			'localMedia.browse.clearSearch' => 'Effacer la recherche',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'Aucun résultat pour « ${query} »',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Voir les ${count} dossiers',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Voir les ${count} vidéos',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Voir les ${count} images',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Voir les ${count} galeries',
			'localMedia.browse.location' => 'Emplacement',
			'localMedia.browse.sourceMissing' => 'Cette source a disparu',
			'localMedia.browse.notScannedYet' => 'Ce dossier n\'a pas encore été analysé',
			'localMedia.browse.scanning' => 'Lecture de ce dossier…',
			'localMedia.browse.deleteFileTitle' => 'Supprimer ce fichier ?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '« ${name} » sera définitivement supprimé de cet appareil. Cette action est irréversible.',
			'localMedia.browse.hideFolder' => 'Masquer ce dossier',
			'localMedia.browse.unhideFolder' => 'Afficher de nouveau',
			'localMedia.browse.showHiddenFolders' => 'Afficher les dossiers masqués',
			'localMedia.browse.includeDotFolders' => 'Analyser les dossiers commençant par .',
			'localMedia.browse.dotFoldersIncluded' => 'Les dossiers commençant par . sont maintenant analysés',
			'localMedia.browse.dotFoldersExcluded' => 'Les dossiers commençant par . ne sont plus analysés',
			'localMedia.browse.showDotFolders' => 'Afficher les dossiers commençant par .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => '${count} dossiers commençant par . ne sont pas analysés ici',
			'localMedia.browse.scanDotFoldersAction' => 'Activer pour cette source',
			'localMedia.browse.otherAppsPrivateNotice' => 'Depuis Android 11, aucune application ne peut lire les fichiers des autres applications dans Android/data ou Android/obb, et cette application ne peut pas le contourner. Téléchargez ou exportez les vidéos vers un dossier public comme Download dans l\'application d\'origine, puis ajoutez ce dossier ici. Les caches de lecture sont généralement fragmentés et illisibles même s\'ils sont accessibles.',
			'localMedia.browse.folderHidden' => 'Masqué ; l’analyse l’ignorera aussi',
			'localMedia.browse.folderUnhidden' => 'N’est plus masqué',
			'localMedia.browse.hiddenFolderBadge' => 'Masqué',
			'localMedia.browse.deleteFolder' => 'Supprimer le dossier',
			'localMedia.browse.deleteFolderTitle' => 'Supprimer ce dossier ?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '« ${name} » et tout son contenu seront définitivement supprimés de cet appareil. Cette action est irréversible.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Les autres fichiers qu’il contient seront aussi supprimés',
			'localMedia.browse.folderDeleted' => 'Dossier supprimé',
			'localMedia.browse.deleteFolderFailed' => 'Échec de la suppression : permission refusée ou fichier en cours d’utilisation',
			'localMedia.browse.deleteGalleryTitle' => 'Supprimer cette galerie ?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'L\'enregistrement de téléchargement et les fichiers image locaux de « ${name} » seront supprimés. Cette action est irréversible.',
			'localMedia.browse.galleryResourceMissing' => 'Les fichiers locaux n\'existent plus. Enregistrement nettoyé.',
			'localMedia.browse.viewDownloadDetail' => 'Voir les détails du téléchargement',
			'localMedia.browse.viewOnlineGallery' => 'Voir sur le site web',
			'localMedia.browse.pickFolderTitle' => 'Choisir un dossier',
			'localMedia.browse.useThisFolder' => 'Utiliser ce dossier',
			'localMedia.browse.noSubfolders' => 'Aucun sous-dossier ici',
			'localMedia.browse.storageRoot' => 'Stockage de l\'appareil',
			'localMedia.browse.homeFolder' => 'Accueil',
			'localMedia.browse.filesystemRoot' => 'Racine du système de fichiers',
			'localMedia.browse.folderUnreadable' => 'Ce dossier ne peut pas être lu',
			'localMedia.browse.setCover' => 'Définir la couverture',
			'localMedia.browse.setAsFolderCover' => 'Utiliser comme couverture du dossier',
			'localMedia.browse.folderCoverSet' => 'Couverture du dossier mise à jour',
			'localMedia.browse.setFolderCoverPick' => 'Définir la couverture…',
			'localMedia.browse.restoreAutoCover' => 'Rétablir la couverture automatique',
			'localMedia.browse.autoCoverRestored' => 'Couverture automatique rétablie',
			'localMedia.browse.rescanFolder' => 'Réanalyser ce dossier',
			'localMedia.browse.coverPickerTitle' => 'Choisir une image',
			'localMedia.browse.folderCoverPickerTitle' => 'Choisir une couverture',
			'localMedia.browse.coverPickerEmpty' => 'Aucune image disponible dans ce dossier pour l\'instant. Les vignettes des vidéos sont peut-être encore en cours de génération en arrière-plan.',
			'localMedia.browse.coverSaved' => 'Couverture mise à jour',
			'localMedia.browse.coverSaveFailed' => 'Impossible d\'enregistrer la couverture',
			'localMedia.browse.coverUnavailable' => 'Aucune image vidéo n\'a pu être lue depuis ce fichier',
			'localMedia.browse.deleted' => 'Supprimé',
			'localMedia.browse.deleteFailed' => 'Impossible de supprimer — le fichier est peut-être utilisé ou protégé en écriture',
			'localMedia.browse.openFolder' => 'Ouvrir',
			'localMedia.browse.favorite' => 'Ajouter aux favoris',
			'localMedia.browse.unfavorite' => 'Retirer des favoris',
			'localMedia.browse.favorited' => 'Ajouté aux favoris',
			'localMedia.browse.unfavorited' => 'Retiré des favoris',
			'localMedia.browse.sortBy' => 'Trier par',
			'localMedia.browse.sortAscending' => 'Croissant',
			'localMedia.browse.sortDescending' => 'Décroissant',
			'localMedia.browse.sortFieldName' => 'Nom',
			'localMedia.browse.sortFieldModified' => 'Date de modification',
			'localMedia.browse.sortFieldDuration' => 'Durée',
			'localMedia.browse.sortFieldSize' => 'Taille',
			'localMedia.browse.sortFieldResolution' => 'Résolution',
			'localMedia.browse.sortFieldFileType' => 'Type de fichier',
			'localMedia.browse.sortFieldFps' => 'Fréquence d\'images',
			'localMedia.browse.sortFieldFavorited' => 'Date d\'ajout aux favoris',
			'localMedia.browse.emptyAllVideos' => 'Aucune vidéo trouvée pour l\'instant. Ajoutez un dossier dans Dossiers pour commencer.',
			'localMedia.browse.emptyAllImages' => 'Aucune image trouvée pour l\'instant. Ajoutez un dossier dans Dossiers pour commencer.',
			'localMedia.browse.emptyFavorites' => 'Aucun favori pour l\'instant. Ajoutez-en un depuis le menu ⋮ d\'une vidéo.',
			'localMedia.browse.emptyPinned' => 'Aucun dossier épinglé pour l\'instant. Appuyez longuement sur un dossier dans Dossiers et choisissez Épingler.',
			'localMedia.browse.emptyDownloadedVideos' => 'Aucun téléchargement de vidéo terminé pour l\'instant.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Aucun téléchargement de galerie terminé pour l\'instant.',
			'localMedia.browse.folderInfo' => 'Infos du dossier',
			'localMedia.browse.folderInfoName' => 'Nom',
			'localMedia.browse.folderInfoPath' => 'Chemin',
			'localMedia.browse.folderInfoSource' => 'Source',
			'localMedia.browse.folderInfoContents' => 'Contenu',
			'localMedia.browse.folderInfoSize' => 'Taille sur le disque',
			'localMedia.browse.folderInfoScannedAt' => 'Dernière analyse',
			'localMedia.browse.folderInfoNeverScanned' => 'Pas encore analysé',
			'localMedia.browse.folderInfoNoPath' => 'Cette source n\'a aucun dossier à ouvrir',
			'localMedia.browse.copyPath' => 'Copier le chemin',
			'localMedia.browse.pathCopied' => 'Chemin copié',
			'localMedia.tabFolders' => 'Dossiers',
			'localMedia.tabFavoriteVideos' => 'Favoris',
			'localMedia.tabAllVideos' => 'Toutes les vidéos',
			'localMedia.tabAllImages' => 'Toutes les images',
			'localMedia.tabDownloadedVideos' => 'Vidéos téléchargées',
			'localMedia.tabDownloadedGalleries' => 'Galeries téléchargées',
			'localMedia.title' => 'Sur cet appareil',
			'localMedia.sourceOnline' => 'Iwara en ligne',
			'localMedia.manageSources' => 'Gérer les sources',
			'localMedia.moveToCategory' => 'Déplacer vers une catégorie',
			'localMedia.manageCategories' => 'Gérer les catégories',
			'localMedia.suggestedFolders' => 'Dossiers contenant des vidéos',
			'localMedia.sortRecentlyAdded' => 'Ajoutés récemment',
			'localMedia.sortRecentlyPlayed' => 'Lus récemment',
			'localMedia.sortName' => 'Nom',
			'localMedia.sortDuration' => 'Durée',
			'localMedia.sortSize' => 'Taille',
			'localMedia.sortFolder' => 'Dossier',
			'localMedia.sortRecentlyModified' => 'Modifiés récemment',
			'localMedia.sortCount' => 'Nombre',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} image(s)',
			'localMedia.downloadsSource' => 'Téléchargé',
			'localMedia.builtInSourceHint' => 'Téléchargé est géré automatiquement',
			'localMedia.filterByCategory' => 'Filtrer par catégorie',
			'localMedia.longPressToCategorize' => 'Appuyez longuement pour déplacer vers une catégorie',
			'localMedia.uncategorized' => 'Sans catégorie',
			'localMedia.setCategoryFailed' => 'Impossible de définir la catégorie',
			'localMedia.categoryUpdated' => 'Catégorie mise à jour',
			'localMedia.addFolder' => 'Ajouter un dossier',
			'localMedia.addDeviceVideos' => 'Analyser les vidéos de l\'appareil',
			'localMedia.mediaStoreSourceName' => 'Vidéos de l\'appareil',
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
			'localMedia.mediaStoreUnavailable' => 'L\'index multimédia de l\'appareil n\'est disponible que sur Android',
			'localMedia.mediaStorePermissionDenied' => 'L\'accès aux vidéos n\'a pas été accordé',
			'localMedia.rescan' => 'Réanalyser',
			'localMedia.scanning' => ({required Object count}) => 'Analyse… ${count} trouvés',
			'localMedia.scanFailed' => ({required Object reason}) => 'Échec de l\'analyse : ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Ce dossier est très volumineux — seuls les ${count} premiers fichiers ont été ajoutés.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Déjà couvert par le dossier « ${name} »',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '« ${name} » se trouve dans « ${source} », il a donc été ajouté aux dossiers épinglés',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '« ${name} » figure déjà dans les dossiers épinglés',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '« ${name} » a déjà été ajouté',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Il contient déjà le dossier ajouté « ${name} » ; l\'ajout de son dossier parent n\'est pas encore pris en charge',
			'localMedia.addSourceFailed' => 'Impossible d\'ajouter ce dossier',
			'localMedia.fileMissing' => 'Ce fichier n\'est plus sur le disque',
			'localMedia.permissionDenied' => 'Accès aux fichiers non accordé · appuyez pour l\'accorder',
			'localMedia.noVideosFound' => 'Aucune vidéo dans ce dossier',
			'localMedia.emptyTitle' => 'Ajoutez un dossier pour lire les vidéos déjà présentes sur cet appareil',
			'localMedia.emptyPrivacyNote' => 'Les fichiers sont lus uniquement sur cet appareil. Rien n\'est envoyé.',
			'localMedia.removeSourceTitle' => ({required Object name}) => 'Retirer « ${name} » ?',
			'localMedia.removeSourceBody' => 'Les fichiers restent sur le disque. Seule cette entrée de la bibliothèque est retirée.',
			'localMedia.remove' => 'Retirer',
			'localMedia.removeFolder' => 'Retirer le dossier',
			'localMedia.removeFolderSelectTitle' => 'Choisir le dossier à retirer',
			'localMedia.longPressToRemove' => 'Appuyez longuement pour retirer ce dossier',
			'localMedia.clearProgress' => 'Effacer l\'historique de lecture local',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} entrées',
			'localMedia.clearProgressEmpty' => 'Aucun historique de lecture local pour l\'instant',
			'localMedia.clearProgressTitle' => 'Effacer l\'historique de lecture local ?',
			'localMedia.clearProgressBody' => 'Seules les positions de lecture et les marques de visionnage sont supprimées. Vos fichiers et dossiers restent exactement tels quels.',
			'localMedia.clearProgressDone' => ({required Object count}) => '${count} entrées de l\'historique de lecture local effacées',
			'localMedia.clearAction' => 'Effacer',
			'localMedia.iosManualRescanNotice' => 'iOS ne détecte pas automatiquement les nouveaux fichiers. Vous devrez relancer une analyse manuellement après avoir ajouté ou supprimé des fichiers.',
			'historyPage.removeFromHistory' => 'Retirer de l\'historique',
			'historyPage.removed' => 'Retiré de l\'historique',
			'historyPage.watchedTo' => ({required Object time}) => 'Vu jusqu’à ${time}',
			'historyPage.finished' => 'Vu',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'Effacer « ${tab} »',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Tout l’historique de « ${tab} » sera supprimé, ainsi que la progression de lecture de ces vidéos. Action irréversible.',
			'historyPage.rangeByLastViewed' => 'Filtré par dernière consultation',
			_ => null,
		};
	}
}
