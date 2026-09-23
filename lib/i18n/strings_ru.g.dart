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
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileRu personalProfile = _TranslationsPersonalProfileRu._(_root);
	@override late final _TranslationsTutorialRu tutorial = _TranslationsTutorialRu._(_root);
	@override late final _TranslationsCommonRu common = _TranslationsCommonRu._(_root);
	@override late final _TranslationsAuthRu auth = _TranslationsAuthRu._(_root);
	@override late final _TranslationsErrorsRu errors = _TranslationsErrorsRu._(_root);
	@override late final _TranslationsFriendsRu friends = _TranslationsFriendsRu._(_root);
	@override late final _TranslationsAuthorProfileRu authorProfile = _TranslationsAuthorProfileRu._(_root);
	@override late final _TranslationsFavoritesRu favorites = _TranslationsFavoritesRu._(_root);
	@override late final _TranslationsGalleryDetailRu galleryDetail = _TranslationsGalleryDetailRu._(_root);
	@override late final _TranslationsPlayListRu playList = _TranslationsPlayListRu._(_root);
	@override late final _TranslationsSearchRu search = _TranslationsSearchRu._(_root);
	@override late final _TranslationsMediaListRu mediaList = _TranslationsMediaListRu._(_root);
	@override late final _TranslationsSettingsRu settings = _TranslationsSettingsRu._(_root);
	@override late final _TranslationsFavoriteTagsRu favoriteTags = _TranslationsFavoriteTagsRu._(_root);
	@override late final _TranslationsOreno3dRu oreno3d = _TranslationsOreno3dRu._(_root);
	@override late final _TranslationsSignInRu signIn = _TranslationsSignInRu._(_root);
	@override late final _TranslationsSubscriptionsRu subscriptions = _TranslationsSubscriptionsRu._(_root);
	@override late final _TranslationsVideoDetailRu videoDetail = _TranslationsVideoDetailRu._(_root);
	@override late final _TranslationsShareRu share = _TranslationsShareRu._(_root);
	@override late final _TranslationsMarkdownRu markdown = _TranslationsMarkdownRu._(_root);
	@override late final _TranslationsForumRu forum = _TranslationsForumRu._(_root);
	@override late final _TranslationsNotificationsRu notifications = _TranslationsNotificationsRu._(_root);
	@override late final _TranslationsConversationRu conversation = _TranslationsConversationRu._(_root);
	@override late final _TranslationsSplashRu splash = _TranslationsSplashRu._(_root);
	@override late final _TranslationsDownloadRu download = _TranslationsDownloadRu._(_root);
	@override late final _TranslationsDownloadNotificationsRu downloadNotifications = _TranslationsDownloadNotificationsRu._(_root);
	@override late final _TranslationsFavoriteRu favorite = _TranslationsFavoriteRu._(_root);
	@override late final _TranslationsTranslationRu translation = _TranslationsTranslationRu._(_root);
	@override late final _TranslationsBottomNavRu bottomNav = _TranslationsBottomNavRu._(_root);
	@override late final _TranslationsNavigationOrderSettingsRu navigationOrderSettings = _TranslationsNavigationOrderSettingsRu._(_root);
	@override late final _TranslationsNewsRu news = _TranslationsNewsRu._(_root);
	@override late final _TranslationsDisplaySettingsRu displaySettings = _TranslationsDisplaySettingsRu._(_root);
	@override late final _TranslationsLayoutSettingsRu layoutSettings = _TranslationsLayoutSettingsRu._(_root);
	@override late final _TranslationsMediaPlayerRu mediaPlayer = _TranslationsMediaPlayerRu._(_root);
	@override late final _TranslationsDiagnosticsRu diagnostics = _TranslationsDiagnosticsRu._(_root);
	@override late final _TranslationsLogViewerRu logViewer = _TranslationsLogViewerRu._(_root);
	@override late final _TranslationsCrashRecoveryDialogRu crashRecoveryDialog = _TranslationsCrashRecoveryDialogRu._(_root);
	@override late final _TranslationsLinkInputDialogRu linkInputDialog = _TranslationsLinkInputDialogRu._(_root);
	@override late final _TranslationsLogRu log = _TranslationsLogRu._(_root);
	@override late final _TranslationsEmojiRu emoji = _TranslationsEmojiRu._(_root);
	@override late final _TranslationsSearchFilterRu searchFilter = _TranslationsSearchFilterRu._(_root);
	@override late final _TranslationsFirstTimeSetupRu firstTimeSetup = _TranslationsFirstTimeSetupRu._(_root);
	@override late final _TranslationsProxyHelperRu proxyHelper = _TranslationsProxyHelperRu._(_root);
	@override late final _TranslationsTagSelectorRu tagSelector = _TranslationsTagSelectorRu._(_root);
	@override late final _TranslationsAnime4kRu anime4k = _TranslationsAnime4kRu._(_root);
	@override late final _TranslationsSiteModeRu siteMode = _TranslationsSiteModeRu._(_root);
	@override late final _TranslationsSavedSearchConfigRu savedSearchConfig = _TranslationsSavedSearchConfigRu._(_root);
	@override late final _TranslationsSavedSearchRu savedSearch = _TranslationsSavedSearchRu._(_root);
	@override late final _TranslationsDefaultBlacklistReminderRu defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderRu._(_root);
	@override late final _TranslationsColorVisionAssistRu colorVisionAssist = _TranslationsColorVisionAssistRu._(_root);
	@override late final _TranslationsExternalPlayerRu externalPlayer = _TranslationsExternalPlayerRu._(_root);
	@override late final _TranslationsWatchLaterRu watchLater = _TranslationsWatchLaterRu._(_root);
	@override late final _TranslationsMediaMenuRu mediaMenu = _TranslationsMediaMenuRu._(_root);
	@override late final _TranslationsMediaPreviewRu mediaPreview = _TranslationsMediaPreviewRu._(_root);
	@override late final _TranslationsPlaybackQueueRu playbackQueue = _TranslationsPlaybackQueueRu._(_root);
	@override late final _TranslationsVrFormatRu vrFormat = _TranslationsVrFormatRu._(_root);
	@override late final _TranslationsLocalMediaRu localMedia = _TranslationsLocalMediaRu._(_root);
	@override late final _TranslationsHistoryPageRu historyPage = _TranslationsHistoryPageRu._(_root);
	@override late final _TranslationsAiRu ai = _TranslationsAiRu._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileRu extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Профиль';
	@override String get editPersonalProfile => 'Редактировать профиль';
	@override String get avatar => 'Аватар';
	@override String get background => 'Фон';
	@override String fetchUserProfileFailed({required Object error}) => 'Не удалось загрузить профиль: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Рекомендуемое разрешение: ${resolution}, размер файла < ${size}';
	@override String supportedFormats({required Object formats}) => 'Поддерживаемые форматы: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Премиум-пользователи могут использовать анимированный ${type} (${formats})';
	@override String get homepageBackground => 'Фон главной страницы';
	@override String get basicInfo => 'Основная информация';
	@override String get nickname => 'Псевдоним';
	@override String get username => 'Имя пользователя';
	@override String get copyUsername => 'Копировать имя пользователя';
	@override String get usernameCopied => 'Имя пользователя скопировано';
	@override String get personalIntroduction => 'О себе';
	@override String get noPersonalIntroduction => 'Нет описания';
	@override String get clickToEdit => 'Нажмите для редактирования';
	@override String get privacySettings => 'Конфиденциальность';
	@override String get hideSensitiveContent => 'Скрывать деликатный контент';
	@override String get hideSensitiveContentDesc => 'Скрывать видео и изображения с деликатными тегами.';
	@override String get notificationSettings => 'Настройки уведомлений';
	@override String get contentCommentNotification => 'Комментарии к контенту';
	@override String get contentCommentNotificationDesc => 'Уведомлять о новых комментариях к вашему контенту.';
	@override String get commentReplyNotification => 'Ответы на комментарии';
	@override String get commentReplyNotificationDesc => 'Уведомлять об ответах на ваши комментарии.';
	@override String get mentionNotification => 'Упоминания';
	@override String get mentionNotificationDesc => 'Уведомлять, когда вас упоминают в контенте.';
	@override String get accountInfo => 'Данные аккаунта';
	@override String get registrationTime => 'Дата регистрации';
	@override String updateSettingsFailed({required Object error}) => 'Не удалось обновить настройки: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'Не удалось обновить настройки уведомлений: ${error}';
	@override String get editNickname => 'Изменить псевдоним';
	@override String get nicknameCannotBeEmpty => 'Псевдоним не может быть пустым';
	@override String get changeSuccess => 'Изменения сохранены';
	@override String get unsupportedFileFormat => 'Неподдерживаемый формат файла';
	@override String fileTooLarge({required Object size}) => 'Размер файла не может превышать ${size}';
	@override String get uploadFailed => 'Ошибка загрузки';
	@override String get avatarUpdatedSuccessfully => 'Аватар успешно обновлен';
	@override String updateAvatarFailed({required Object error}) => 'Не удалось обновить аватар: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Фон успешно обновлен';
	@override String updateBackgroundFailed({required Object error}) => 'Не удалось обновить фон: ${error}';
	@override String get editPersonalIntroduction => 'Редактировать описание';
	@override String get enterPersonalIntroduction => 'Введите описание о себе';
}

// Path: tutorial
class _TranslationsTutorialRu extends TranslationsTutorialEn {
	_TranslationsTutorialRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Особые подписки';
	@override String get specialFollowDescription => 'Отмечайте любимых авторов как особые подписки, чтобы быстро переходить к их новым публикациям.';
	@override String get stepsTitle => 'Три шага';
	@override String get stepFollowAuthor => 'Нажмите «Подписаться» на странице автора, видео или галереи.';
	@override String get stepPickSpecial => 'Нажмите «Подписан» еще раз и выберите «Особая подписка».';
	@override String get stepSwitchHere => 'Вернитесь сюда и переключитесь на автора через панель аватаров выше.';
	@override String get specialFollowManagementTip => 'Управление списком особых подписок: Боковое меню — Подписки — Особые подписки.';
	@override String get gotIt => 'Понятно';
}

// Path: common
class _TranslationsCommonRu extends TranslationsCommonEn {
	_TranslationsCommonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Сортировка';
	@override String get filter => 'Фильтр';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'ОК';
	@override String get cancel => 'Отмена';
	@override String get select => 'Выбрать';
	@override String get save => 'Сохранить';
	@override String get delete => 'Удалить';
	@override String get visit => 'Перейти';
	@override String get loading => 'Загрузка...';
	@override String get scrollToTop => 'Наверх';
	@override String get privacyHint => 'Включен приватный режим, контент скрыт';
	@override String get latest => 'Новые';
	@override String get likesCount => 'Отметки «Нравится»';
	@override String get viewsCount => 'Просмотры';
	@override String get popular => 'Популярные';
	@override String get trending => 'В тренде';
	@override String get commentList => 'Комментарии';
	@override String get sendComment => 'Написать комментарий';
	@override String get send => 'Отправить';
	@override String get retry => 'Повторить';
	@override String get premium => 'Премиум';
	@override String get follower => 'Подписчик';
	@override String get friend => 'Друг';
	@override String get video => 'Видео';
	@override String get following => 'Подписки';
	@override String get expand => 'Развернуть';
	@override String get collapse => 'Свернуть';
	@override String get cancelFriendRequest => 'Отменить заявку';
	@override String get cancelSpecialFollow => 'Отменить особую подписку';
	@override String get addFriend => 'Добавить в друзья';
	@override String get removeFriend => 'Удалить из друзей';
	@override String get followed => 'Вы подписаны';
	@override String get follow => 'Подписаться';
	@override String get unfollow => 'Отписаться';
	@override String get specialFollow => 'Особая подписка';
	@override String get specialFollowed => 'Особая подписка';
	@override String get gallery => 'Галерея';
	@override String get playlist => 'Плейлист';
	@override String get commentPostedSuccessfully => 'Комментарий опубликован';
	@override String get commentPostedFailed => 'Не удалось опубликовать комментарий';
	@override String get success => 'Успешно';
	@override String get commentDeletedSuccessfully => 'Комментарий удален';
	@override String get commentUpdatedSuccessfully => 'Комментарий обновлен';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: 'Комментарий: ${n}',
		other: 'Комментариев: ${n}',
	);
	@override String get writeYourCommentHere => 'Напишите комментарий...';
	@override String get tmpNoReplies => 'Ответов пока нет';
	@override String get loadMore => 'Загрузить еще';
	@override String get loadingMore => 'Загрузка...';
	@override String get noMoreDatas => 'Больше ничего нет';
	@override String get selectTranslationLanguage => 'Выберите язык перевода';
	@override String get translate => 'Перевести';
	@override String get translateFailedPleaseTryAgainLater => 'Ошибка перевода, повторите позже';
	@override String get translationResult => 'Результат перевода';
	@override String get justNow => 'Только что';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} мин. назад',
		other: '${n} мин. назад',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} ч. назад',
		other: '${n} ч. назад',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: '${n} дн. назад',
		other: '${n} дн. назад',
	);
	@override String editedAt({required Object num}) => 'изменено: ${num}';
	@override String get editComment => 'Изменить комментарий';
	@override String get commentUpdated => 'Комментарий обновлен';
	@override String get replyComment => 'Ответить на комментарий';
	@override String get reply => 'Ответить';
	@override String get edit => 'Изменить';
	@override String get unknownUser => 'Неизвестный пользователь';
	@override String get me => 'Я';
	@override String get author => 'Автор';
	@override String get admin => 'Администратор';
	@override String viewReplies({required Object num}) => 'Показать ответы (${num})';
	@override String get hideReplies => 'Скрыть ответы';
	@override String get confirmDelete => 'Подтверждение удаления';
	@override String get areYouSureYouWantToDeleteThisItem => 'Вы уверены, что хотите удалить этот элемент?';
	@override String get tmpNoComments => 'Комментариев пока нет';
	@override String get refresh => 'Обновить';
	@override String get back => 'Назад';
	@override String get tips => 'Подсказка';
	@override String get linkIsEmpty => 'Ссылка пуста';
	@override String get linkCopiedToClipboard => 'Ссылка скопирована';
	@override String get imageCopiedToClipboard => 'Изображение скопировано';
	@override String get copyImageFailed => 'Не удалось скопировать изображение';
	@override String get mobileSaveImageIsUnderDevelopment => 'Сохранение на мобильных в разработке';
	@override String get imageSavedTo => 'Изображение сохранено в';
	@override String get saveImageFailed => 'Не удалось сохранить изображение';
	@override String get close => 'Закрыть';
	@override String get more => 'Еще';
	@override String get unknownError => 'Неизвестная ошибка';
	@override String get moreFeaturesToBeDeveloped => 'Другие функции в разработке';
	@override String get all => 'Все';
	@override String selectedRecords({required Object num}) => 'Выбрано записей: ${num}';
	@override String get cancelSelectAll => 'Снять выбор';
	@override String get selectAll => 'Выбрать все';
	@override String get invertSelection => 'Инвертировать выбор';
	@override String get exitEditMode => 'Выйти из режима выбора';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Удалить выбранные элементы (${num})?';
	@override String get searchHistoryRecords => 'Поиск в истории...';
	@override String get settings => 'Настройки';
	@override String get subscriptions => 'Подписки';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: 'Видео: ${n}',
		other: 'Видео: ${n}',
	);
	@override String get share => 'Поделиться';
	@override String get areYouSureYouWantToShareThisPlaylist => 'Поделиться этим плейлистом?';
	@override String get editTitle => 'Изменить название';
	@override String get editMode => 'Режим редактирования';
	@override String get pleaseEnterNewTitle => 'Введите новое название';
	@override String get createPlayList => 'Создать плейлист';
	@override String get create => 'Создать';
	@override String get checkNetworkSettings => 'Проверьте настройки сети';
	@override String get general => 'Общее';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Деликатный';
	@override String get year => 'Год';
	@override String get month => 'Месяц';
	@override String get tag => 'Тег';
	@override String get private => 'Приватный';
	@override String get noTitle => 'Без названия';
	@override String get search => 'Поиск';
	@override String get noContent => 'Нет содержимого';
	@override String get recording => 'Запись';
	@override String get paused => 'На паузе';
	@override String get clear => 'Очистить';
	@override String get clearSelection => 'Снять выбор';
	@override String get selectItemsToContinue => 'Выберите элементы для продолжения';
	@override String andMoreItems({required Object num}) => 'и еще ${num}';
	@override String get batchDelete => 'Пакетное удаление';
	@override String get user => 'Пользователь';
	@override String get post => 'Публикация';
	@override String get seconds => 'Секунды';
	@override String get comingSoon => 'Скоро';
	@override String get confirm => 'Подтвердить';
	@override String get hour => 'Час';
	@override String get minute => 'Минута';
	@override String get clickToRefresh => 'Нажмите для обновления';
	@override String get history => 'История';
	@override String get favorites => 'Избранное';
	@override String get friends => 'Друзья';
	@override String get playList => 'Плейлист';
	@override String get checkLicense => 'Лицензия';
	@override String get logout => 'Выйти';
	@override String get fensi => 'Подписчики';
	@override String get accept => 'Принять';
	@override String get reject => 'Отклонить';
	@override String get clearAllHistory => 'Очистить всю историю';
	@override String get clearAllHistoryConfirm => 'Вы уверены, что хотите очистить всю историю?';
	@override String get followingList => 'Подписки';
	@override String get followersList => 'Подписчики';
	@override String get follows => 'Подписки';
	@override String get fans => 'Подписчики';
	@override String get followsAndFans => 'Подписки и подписчики';
	@override String get numViews => 'Просмотры';
	@override String get updatedAt => 'Обновлено';
	@override String get publishedAt => 'Опубликовано';
	@override String get externalVideo => 'Внешнее видео';
	@override String get originalText => 'Исходный текст';
	@override String get showOriginalText => 'Показать оригинал';
	@override String get showProcessedText => 'Показать обработанный текст';
	@override String get preview => 'Предпросмотр';
	@override String get rules => 'Правила';
	@override String get agree => 'Принять';
	@override String get disagree => 'Отклонить';
	@override String get agreeToRules => 'Принять правила';
	@override String get tapToReread => 'Нажмите, чтобы перечитать';
	@override String get markdownSyntaxHelp => 'Справка по Markdown';
	@override String get previewContent => 'Предпросмотр';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Превышен лимит символов (${max})';
	@override String get agreeToCommunityRules => 'Принять правила сообщества';
	@override String get createPost => 'Создать запись';
	@override String get title => 'Заголовок';
	@override String get enterTitle => 'Введите заголовок';
	@override String get content => 'Содержимое';
	@override String get enterContent => 'Введите содержимое';
	@override String get writeYourContentHere => 'Введите текст...';
	@override String get tagBlacklist => 'Черный список тегов';
	@override String get noData => 'Нет данных';
	@override String get tagLimit => 'Лимит тегов';
	@override String get enableFloatingButtons => 'Включить плавающие кнопки';
	@override String get disableFloatingButtons => 'Отключить плавающие кнопки';
	@override String get enabledFloatingButtons => 'Плавающие кнопки включены';
	@override String get disabledFloatingButtons => 'Плавающие кнопки отключены';
	@override String get pendingCommentCount => 'Ожидает проверки';
	@override String joined({required Object str}) => 'Регистрация: ${str}';
	@override String lastSeenAt({required Object str}) => 'В сети: ${str}';
	@override String get download => 'Скачать';
	@override String get selectQuality => 'Выберите качество';
	@override String get videoQualitySource => 'Исходное';
	@override String get selectImageQuality => 'Качество изображений';
	@override String get imageQualityStandard => 'Стандартное';
	@override String get imageQualityOriginal => 'Исходное';
	@override String get selectDateRange => 'Выбрать диапазон дат';
	@override String get selectDateRangeHint => 'Выберите диапазон дат (по умолч. 30 дней)';
	@override String get clearDateRange => 'Сбросить диапазон';
	@override String get deleteRecordsInDateRange => 'Удалить записи за этот период';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'Удалить ${num} записей за выбранный период? Действие необратимо.';
	@override String get noHistoryRecordsInRange => 'Нет записей за указанный период';
	@override String get followSuccessClickAgainToSpecialFollow => 'Вы подписались, нажмите еще раз для особой подписки';
	@override String get specialFollowTip => 'Добавлено в особые подписки — доступно в меню справа вверху на странице подписок';
	@override String get exitConfirmTip => 'Вы действительно хотите выйти?';
	@override String get error => 'Ошибка';
	@override String get taskRunning => 'Задача уже выполняется, подождите.';
	@override String get operationCancelled => 'Операция отменена.';
	@override String get unsavedChanges => 'Есть несохраненные изменения';
	@override String get specialFollowsManagementTip => 'Потяните за ручку для перемещения • Нажмите кнопку для удаления';
	@override String get specialFollowsManagement => 'Управление особыми подписками';
	@override String get removeSpecialFollow => 'Удалить особую подписку';
	@override String removeSpecialFollowConfirm({required Object name}) => 'Удалить ${name} из особых подписок?';
	@override String get noSpecialFollows => 'Нет особых подписок';
	@override String get createTimeDesc => 'Сначала новые';
	@override String get createTimeAsc => 'Сначала старые';
	@override late final _TranslationsCommonPaginationRu pagination = _TranslationsCommonPaginationRu._(_root);
	@override String get notice => 'Внимание';
	@override String get detail => 'Подробнее';
	@override String get parseExceptionDestopHint => ' - На ПК можно настроить прокси в настройках';
	@override String get iwaraTags => 'Теги Iwara';
	@override String get tagInfo => 'Информация о теге';
	@override String get tagOriginalKey => 'Исходный тег';
	@override String get tagTranslation => 'Перевод';
	@override String get copy => 'Копировать';
	@override String get selectCopy => 'Выбрать и скопировать';
	@override String get copiedToClipboard => 'Скопировано в буфер';
	@override String get showOriginalTag => 'Показать исходный тег';
	@override String get showTranslatedTag => 'Показать перевод';
	@override String get tagTranslationFeedback => 'Неточность в переводе? Отправьте отзыв';
	@override String get tagLocalizationGuideTitle => 'О локализации тегов';
	@override String get tagLocalizationGuideContent => 'Приложение отображает теги Iwara (например, mother) на выбранном вами языке.\n\n• При поиске учитываются как перевод, так и оригинал.\n• Удерживайте или нажмите правой кнопкой мыши по тегу, чтобы скопировать оригинал и перевод.\n• Переводы поддерживаются сообществом и могут содержать неточности.';
	@override String get likeThisVideo => 'Оценить видео';
	@override String get likeThisGallery => 'Оценить галерею';
	@override String get operation => 'Действие';
	@override String get replies => 'Ответы';
	@override String get externalLinkWarning => 'Переход по внешней ссылке';
	@override String get externalLinkWarningMessage => 'Вы переходите по ссылке, не относящейся к iwara.tv. Будьте осторожны и убедитесь в надежности ресурса.';
	@override String get continueToExternalLink => 'Продолжить';
	@override String get cancelExternalLink => 'Отмена';
}

// Path: auth
class _TranslationsAuthRu extends TranslationsAuthEn {
	_TranslationsAuthRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get login => 'Вход';
	@override String get logout => 'Выход';
	@override String get email => 'Эл. почта';
	@override String get password => 'Пароль';
	@override String get loginOrRegister => 'Вход / Регистрация';
	@override String get register => 'Регистрация';
	@override String get pleaseEnterEmail => 'Введите эл. почту';
	@override String get pleaseEnterPassword => 'Введите пароль';
	@override String get passwordMustBeAtLeast6Characters => 'Пароль должен содержать не менее 6 символов';
	@override String get pleaseEnterCaptcha => 'Введите капчу';
	@override String get captcha => 'Капча';
	@override String get refreshCaptcha => 'Обновить капчу';
	@override String get captchaNotLoaded => 'Капча не загружена';
	@override String get loginSuccess => 'Вход выполнен';
	@override String get loginSuccessProfilePending => 'Вход выполнен. Загрузка профиля…';
	@override String get emailVerificationSent => 'Подтверждение отправлено на почту';
	@override String get notLoggedIn => 'Вы не вошли в аккаунт';
	@override String get clickToLogin => 'Нажмите для входа';
	@override String get logoutConfirmation => 'Вы уверены, что хотите выйти из аккаунта?';
	@override String get logoutSuccess => 'Выход выполнен';
	@override String get logoutFailed => 'Не удалось выйти';
	@override String get usernameOrEmail => 'Имя пользователя или эл. почта';
	@override String get pleaseEnterUsernameOrEmail => 'Введите имя пользователя или эл. почту';
	@override String get rememberMe => 'Запомнить имя пользователя';
	@override String get registerNoticeTitle => 'Регистрация на официальном сайте';
	@override String get registerNoticeDescription => 'Регистрация в приложении недоступна. Создайте аккаунт на официальном сайте Iwara, затем войдите здесь.';
	@override String get registerNoticeReturnTip => 'После регистрации вернитесь сюда и выполните вход.';
	@override String get goToOfficialWebsite => 'Перейти на сайт';
}

// Path: errors
class _TranslationsErrorsRu extends TranslationsErrorsEn {
	_TranslationsErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get error => 'Ошибка';
	@override String get required => 'Обязательное поле';
	@override String get invalidEmail => 'Некорректный адрес эл. почты';
	@override String get networkError => 'Ошибка сети, повторите попытку';
	@override String get errorWhileFetching => 'Ошибка загрузки';
	@override String get commentCanNotBeEmpty => 'Комментарий не может быть пустым';
	@override String get errorWhileFetchingReplies => 'Ошибка загрузки ответов, проверьте подключение к сети';
	@override String get canNotFindCommentController => 'Не удалось найти контроллер комментариев';
	@override String get errorWhileLoadingGallery => 'Ошибка загрузки галереи';
	@override String get howCouldThereBeNoDataItCantBePossible => 'Данных нет? Этого не может быть :<';
	@override String unsupportedImageFormat({required Object str}) => 'Неподдерживаемый формат изображения: ${str}';
	@override String get invalidGalleryId => 'Некорректный ID галереи';
	@override String get translationFailedPleaseTryAgainLater => 'Ошибка перевода, повторите позже';
	@override String get errorOccurred => 'Произошла ошибка, повторите попытку позже.';
	@override String get errorOccurredWhileProcessingRequest => 'Произошла ошибка при обработке запроса';
	@override String get errorWhileFetchingDatas => 'Ошибка при получении данных, повторите позже';
	@override String get serviceNotInitialized => 'Сервис не инициализирован';
	@override String get unknownType => 'Неизвестный тип';
	@override String errorWhileOpeningLink({required Object link}) => 'Ошибка открытия ссылки: ${link}';
	@override String get invalidUrl => 'Некорректный URL';
	@override String get failedToOperate => 'Сбой операции';
	@override String get permissionDenied => 'Доступ запрещен';
	@override String get youDoNotHavePermissionToAccessThisResource => 'У вас нет доступа к этому ресурсу';
	@override String get loginFailed => 'Ошибка входа';
	@override String get unknownError => 'Неизвестная ошибка';
	@override String get sessionExpired => 'Сессия истекла';
	@override String get failedToFetchCaptcha => 'Не удалось получить капчу';
	@override String get emailAlreadyExists => 'Эл. почта уже используется';
	@override String get invalidCaptcha => 'Неверная капча';
	@override String get registerFailed => 'Ошибка регистрации';
	@override String get failedToFetchComments => 'Не удалось загрузить комментарии';
	@override String get failedToFetchImageDetail => 'Не удалось загрузить сведения об изображении';
	@override String get failedToFetchImageList => 'Не удалось загрузить список изображений';
	@override String get failedToFetchData => 'Не удалось получить данные';
	@override String get invalidParameter => 'Недопустимый параметр';
	@override String get pleaseLoginFirst => 'Сначала войдите в систему';
	@override String get errorWhileLoadingPost => 'Ошибка загрузки публикации';
	@override String get errorWhileLoadingPostDetail => 'Ошибка загрузки подробностей публикации';
	@override String get invalidPostId => 'Некорректный ID публикации';
	@override String get forceUpdateNotPermittedToGoBack => 'Обязательное обновление, вернуться нельзя';
	@override String get pleaseLoginAgain => 'Пожалуйста, войдите снова';
	@override String get invalidLogin => 'Ошибка входа. Проверьте эл. почту и пароль';
	@override String get tooManyRequests => 'Слишком много запросов, повторите попытку позже';
	@override String exceedsMaxLength({required Object max}) => 'Превышена максимальная длина: ${max}';
	@override String get contentCanNotBeEmpty => 'Содержимое не может быть пустым';
	@override String get titleCanNotBeEmpty => 'Заголовок не может быть пустым';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Слишком много запросов, повторите попытку позже, осталось: ';
	@override String remainingHours({required Object num}) => '${num} ч.';
	@override String remainingMinutes({required Object num}) => '${num} мин.';
	@override String remainingSeconds({required Object num}) => '${num} сек.';
	@override String tagLimitExceeded({required Object limit}) => 'Превышен лимит тегов (макс.: ${limit})';
	@override String get failedToRefresh => 'Не удалось обновить';
	@override String get noPermission => 'Нет прав';
	@override String get resourceNotFound => 'Ресурс не найден';
	@override String get failedToSaveCredentials => 'Не удалось сохранить учетные данные';
	@override String get failedToLoadSavedCredentials => 'Не удалось загрузить сохраненные учетные данные';
	@override String get notFound => 'Контент не найден или удален';
	@override late final _TranslationsErrorsNetworkRu network = _TranslationsErrorsNetworkRu._(_root);
}

// Path: friends
class _TranslationsFriendsRu extends TranslationsFriendsEn {
	_TranslationsFriendsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Нажмите для восстановления';
	@override String get friendsList => 'Список друзей';
	@override String get friendRequests => 'Заявки в друзья';
	@override String get friendRequestsList => 'Список заявок в друзья';
	@override String get removingFriend => 'Удаление из друзей...';
	@override String get failedToRemoveFriend => 'Не удалось удалить из друзей';
	@override String get cancelingRequest => 'Отмена заявки...';
	@override String get failedToCancelRequest => 'Не удалось отменить заявку';
}

// Path: authorProfile
class _TranslationsAuthorProfileRu extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'Больше ничего нет';
	@override String get userProfile => 'Профиль пользователя';
}

// Path: favorites
class _TranslationsFavoritesRu extends TranslationsFavoritesEn {
	_TranslationsFavoritesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Нажмите для восстановления';
	@override String get myFavorites => 'Мое избранное';
	@override String get batchCancelFavorite => 'Удалить выбранное из избранного';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'Удалить выбранные элементы (${count}) из избранного? Их можно восстановить нажатием на карточки.';
	@override String batchCancelFavoriteSuccess({required Object count}) => 'Удалено элементов: ${count}';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => 'Убрано элементов: ${success}, не удалось: ${failed}';
}

// Path: galleryDetail
class _TranslationsGalleryDetailRu extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Просмотр в пространстве';
	@override String get galleryDetail => 'Сведения о галерее';
	@override String get viewGalleryDetail => 'О галерее';
	@override String get zoomReset => 'Сбросить масштаб';
	@override String get copyLink => 'Копировать ссылку';
	@override String get copyImage => 'Копировать изображение';
	@override String get saveAs => 'Сохранить как';
	@override String get saveToAlbum => 'Сохранить в альбом';
	@override String get publishedAt => 'Опубликовано';
	@override String get viewsCount => 'Просмотры';
	@override String get imageLibraryFunctionIntroduction => 'Возможности галереи';
	@override String get rightClickToSaveSingleImage => 'Правый клик для сохранения изображения';
	@override String get batchSave => 'Пакетное сохранение';
	@override String get keyboardLeftAndRightToSwitch => 'Стрелки влево/вправо для переключения';
	@override String get keyboardUpAndDownToZoom => 'Стрелки вверх/вниз для масштабирования';
	@override String get mouseWheelToSwitch => 'Колесико мыши для переключения';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + колесико мыши для зума';
	@override String get moreFeaturesToBeDiscovered => 'Больше возможностей впереди...';
	@override String get authorOtherGalleries => 'Другие галереи автора';
	@override String get relatedGalleries => 'Похожие галереи';
	@override String get authorNoOtherGalleries => 'У автора больше нет галерей';
	@override String get noRelatedGalleries => 'Нет похожих галерей';
	@override String get scrollLeft => 'Прокрутка влево';
	@override String get scrollRight => 'Прокрутка вправо';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Нажатие по краям экрана для перелистывания';
	@override String get rotateToLandscape => 'В альбомный режим';
	@override String get backToPortrait => 'В портретный режим';
}

// Path: playList
class _TranslationsPlayListRu extends TranslationsPlayListEn {
	_TranslationsPlayListRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Мои плейлисты';
	@override String get friendlyTips => 'Обратите внимание';
	@override String get dearUser => 'Уважаемый пользователь';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'Система плейлистов Iwara пока несовершенна';
	@override String get notSupportSetCover => 'Нельзя установить обложку';
	@override String get notSupportDeleteList => 'Нельзя удалить плейлист';
	@override String get notSupportSetPrivate => 'Нельзя сделать приватным';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Созданный плейлист останется навсегда и будет виден всем';
	@override String get smallSuggestion => 'Совет';
	@override String get useLikeToCollectContent => 'Если вам важна приватность, рекомендуем сохранять через отметку «Нравится»';
	@override String get welcomeToDiscussOnGitHub => 'Если у вас есть предложения или идеи, присоединяйтесь к обсуждению на GitHub!';
	@override String get iUnderstand => 'Понятно';
	@override String get searchPlaylists => 'Поиск плейлистов...';
	@override String get newPlaylistName => 'Название нового плейлиста';
	@override String get createNewPlaylist => 'Создать плейлист';
	@override String get videos => 'Видео';
}

// Path: search
class _TranslationsSearchRu extends TranslationsSearchEn {
	_TranslationsSearchRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Область поиска';
	@override String get searchTags => 'Поиск тегов...';
	@override String get contentRating => 'Возрастной рейтинг';
	@override String get removeTag => 'Удалить тег';
	@override String get pleaseEnterSearchContent => 'Введите поисковый запрос';
	@override String get exactMatch => 'Точно';
	@override String get exactMatchOnHint => 'Точное совпадение фразы, дополнительно ищем в китайских и японских заголовках. Нажмите для менее строгого поиска.';
	@override String get exactMatchOffHint => 'Нестрогое совпадение — Iwara разбивает слова. Нажмите для точной фразы.';
	@override String get tagExpansion => 'Искать и по тегу';
	@override String tagExpansionOnHint({required Object tags}) => 'Также ищем по тегу «${tags}» и его японскому/английскому названию — во многих заголовках вашего слова нет.';
	@override String tagExpansionOffHint({required Object tags}) => 'Ищем только ваши слова. Включите, чтобы искать также по тегу «${tags}» и его названиям на других языках.';
	@override String get searchHistory => 'История поиска';
	@override String get searchSuggestion => 'Подсказки поиска';
	@override String get usedTimes => 'Использований';
	@override String get lastUsed => 'Последний раз';
	@override String get noSearchHistoryRecords => 'История поиска пуста';
	@override String get clearSearchHistoryConfirm => 'Очистить всю историю поиска? Действие необратимо.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Тип поиска ${searchType} пока не поддерживается';
	@override String get searchResult => 'Результаты поиска';
	@override String unsupportedSearchType({required Object searchType}) => 'Неподдерживаемый тип поиска: ${searchType}';
	@override String get googleSearch => 'Поиск в Google';
	@override String googleSearchHint({required Object webName}) => 'Поиск на ${webName} работает неудобно? Попробуйте Google!';
	@override String get googleSearchDescription => 'Используйте оператор :site в Google для поиска по сайту. Это особенно удобно для видео, галерей, плейлистов и авторов.';
	@override String get googleSearchKeywordsHint => 'Введите ключевые слова для поиска';
	@override String get openLinkJump => 'Переход по ссылке';
	@override String get googleSearchButton => 'Поиск в Google';
	@override String get pleaseEnterSearchKeywords => 'Введите ключевые слова для поиска';
	@override String get googleSearchQueryCopied => 'Поисковый запрос скопирован';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'Не удалось открыть браузер: ${error}';
	@override String get searchRequestTimeout => 'Время ожидания истекло, повторите попытку позже';
	@override String get searchCannotConnectToServer => 'Не удалось подключиться к серверу, проверьте сеть';
	@override String get searchNetworkError => 'Ошибка сетевого соединения, проверьте настройки сети';
	@override String get searchFailedPleaseRetry => 'Сбой поиска, повторите попытку позже';
}

// Path: mediaList
class _TranslationsMediaListRu extends TranslationsMediaListEn {
	_TranslationsMediaListRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Описание';
}

// Path: settings
class _TranslationsSettingsRu extends TranslationsSettingsEn {
	_TranslationsSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Режим отображения списка';
	@override String get previewEffect => 'Эффект предпросмотра';
	@override String get useTraditionalPaginationMode => 'Классическая пагинация';
	@override String get useTraditionalPaginationModeDesc => 'Включает страницы вместо бесконечной ленты. Вступает в силу после перезагрузки страницы или перезапуска приложения';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Нижняя полоса прогресса при скрытой панели';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Показывать тонкую полосу прогресса видео внизу экрана, когда элементы управления скрыты.';
	@override String get seekPreviewSize => 'Размер предпросмотра при перемотке';
	@override String get seekPreviewSizeDesc => 'Размер окна предпросмотра над шкалой времени. Он уже зависит от размера плеера и пропорций видео; эта настройка лишь корректирует его.';
	@override String get seekPreviewSizeSmall => 'Маленький';
	@override String get seekPreviewSizeStandard => 'Стандартный';
	@override String get seekPreviewSizeLarge => 'Большой';
	@override String get seekPreviewSizeStandardDesc => 'Размер по умолчанию с учетом плеера и видео';
	@override String get showFullscreenUpNextHint => 'Ярлык «Далее»';
	@override String get showFullscreenUpNextHintDesc => 'Показывать ярлык справа в плеере для открытия очереди воспроизведения (источник / плейлист / смотреть позже). Если скрыть, доступ к очереди будет невозможен.';
	@override String get basicSettings => 'Основные настройки';
	@override String get personalizedSettings => 'Персонализация';
	@override String get otherSettings => 'Прочие настройки';
	@override String get searchConfig => 'Настройки поиска';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Использовать ли предыдущие параметры при повторном воспроизведении видео.';
	@override String get playControl => 'Управление воспроизведением';
	@override String get playbackSpeedSettings => 'Скорость воспроизведения';
	@override String get playbackBehaviorSettings => 'Поведение воспроизведения';
	@override String get enhancementSettings => 'Кинотеатр и улучшение';
	@override String get fastForwardTime => 'Время перемотки вперед';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'Время перемотки должно быть положительным целым числом.';
	@override String get rewindTime => 'Время перемотки назад';
	@override String get rewindTimeMustBeAPositiveInteger => 'Время перемотки должно быть положительным целым числом.';
	@override String get longPressPlaybackSpeed => 'Скорость при долгом нажатии';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Скорость при долгом нажатии должна быть положительным числом.';
	@override String get defaultPlaybackSpeed => 'Скорость по умолчанию';
	@override String get rememberPlaybackSpeed => 'Запоминать скорость воспроизведения';
	@override String get rememberPlaybackSpeedDesc => 'Скорость, установленная в плеере, будет сохранена по умолчанию и применена к новым видео.';
	@override String get repeat => 'Повтор';
	@override String get renderVerticalVideoInVerticalScreen => 'Вертикальные видео в портретном режиме';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Отображать ли вертикальное видео на полный экран в портретной ориентации.';
	@override String get rememberVolume => 'Запоминать громкость';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Сохранять ли уровень громкости для следующих видео.';
	@override String get rememberBrightness => 'Запоминать яркость';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Сохранять ли уровень яркости для следующих видео.';
	@override String get playControlArea => 'Область управления';
	@override String get leftAndRightControlAreaWidth => 'Ширина боковых областей управления';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Определяет ширину областей управления слева и справа в плеере.';
	@override String get proxyAddressCannotBeEmpty => 'Адрес прокси не может быть пустым.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Неверный формат адреса прокси. Используйте IP:порт или домен:порт.';
	@override String get proxyNormalWork => 'Прокси работает нормально.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Проверка прокси не удалась, код состояния: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Проверка прокси не удалась: ${exception}';
	@override String get proxyConfig => 'Настройки прокси';
	@override String get thisIsHttpProxyAddress => 'Адрес HTTP-прокси';
	@override String get checkProxy => 'Проверить прокси';
	@override String get proxyAddress => 'Адрес прокси';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Введите адрес прокси-сервера, например 127.0.0.1:8080';
	@override String get enableProxy => 'Включить прокси';
	@override String get left => 'Слева';
	@override String get middle => 'По центру';
	@override String get right => 'Справа';
	@override String get playerSettings => 'Настройки плеера';
	@override String get networkSettings => 'Настройки сети';
	@override String get customizeYourPlaybackExperience => 'Настройте параметры воспроизведения';
	@override String get chooseYourFavoriteAppAppearance => 'Выберите внешний вид приложения';
	@override String get configureYourProxyServer => 'Настройка прокси-сервера';
	@override String get settings => 'Настройки';
	@override String get themeSettings => 'Тема оформления';
	@override String get followSystem => 'Как в системе';
	@override String get lightMode => 'Светлая';
	@override String get darkMode => 'Темная';
	@override String get presetTheme => 'Готовые темы';
	@override String get basicTheme => 'Базовая тема';
	@override String get needRestartToApply => 'Требуется перезапуск приложения';
	@override String get themeNeedRestartDescription => 'Для применения настроек темы необходимо перезапустить приложение';
	@override String get about => 'О приложении';
	@override String get diagnosticsAndFeedback => 'Диагностика и отзывы';
	@override String get currentVersion => 'Текущая версия';
	@override String get latestVersion => 'Последняя версия';
	@override String get checkForUpdates => 'Проверить обновления';
	@override String get update => 'Обновить';
	@override String get newVersionAvailable => 'Доступна новая версия';
	@override String get projectHome => 'Страница проекта';
	@override String get release => 'Релизы';
	@override String get issueReport => 'Сообщить об ошибке';
	@override String get openSourceLicense => 'Лицензии открытого ПО';
	@override String get checkForUpdatesFailed => 'Не удалось проверить обновления, повторите позже';
	@override String get autoCheckUpdate => 'Автопроверка обновлений';
	@override String get updateContent => 'Что нового';
	@override String get releaseDate => 'Дата выпуска';
	@override String get ignoreThisVersion => 'Пропустить эту версию';
	@override String get forceUpdateTip => 'Это обязательное обновление. Пожалуйста, обновите приложение как можно скорее';
	@override String get viewChangelog => 'Список изменений';
	@override String get alreadyLatestVersion => 'У вас последняя версия';
	@override String get appSettings => 'Настройки приложения';
	@override String get configureYourAppSettings => 'Основные параметры приложения';
	@override String get history => 'История';
	@override String get autoRecordHistory => 'Автосохранение истории';
	@override String get autoRecordHistoryDesc => 'Автоматически сохранять просмотренные видео и изображения';
	@override String get autoDeleteHistory => 'Автоочистка истории';
	@override String get autoDeleteHistoryDesc => 'Автоматически удалять историю старше указанного срока при запуске (по умолч. выкл.)';
	@override String get autoDeleteHistoryDays => 'Срок хранения';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Хранить последние ${num} дн.';
	@override String get autoDeleteHistoryDaysInvalid => 'Введите корректное число дней (не менее 1)';
	@override String get showUnprocessedMarkdownText => 'Исходный текст Markdown';
	@override String get showUnprocessedMarkdownTextDesc => 'Показывать сырой исходный текст разметки';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Приватный режим';
	@override String get activeBackgroundPrivacyModeDesc => 'Блокировать скриншоты, запись экрана и скрывать приложение в фоне';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Скрывать экран приложения при переходе в фон (на этой платформе блокировка скриншотов недоступна)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Блокировать скриншоты и запись экрана';
	@override String get privacy => 'Конфиденциальность';
	@override String get appLock => 'Блокировка приложения';
	@override String get appLockEnabled => 'Включить блокировку';
	@override String get appLockEnabledDesc => 'Запрашивать PIN-код или биометрию при входе; превью в фоне скрывается автоматически';
	@override String get appLockEnabledSummary => 'Вкл. · Защищено PIN-кодом';
	@override String get appLockDisabledSummary => 'Выкл.';
	@override String get appLockTimeout => 'Блокировать после выхода';
	@override String get appLockTimeoutDesc => 'Время в фоне, после которого требуется повторная авторизация';
	@override String get appLockAfterScreenOff => 'Блокировать при выключении экрана';
	@override String get appLockAfterScreenOffDesc => 'Требовать авторизацию после блокировки экрана устройства';
	@override String get appLockTimeoutDisabled => 'Отключено';
	@override String get appLockImmediately => 'Немедленно';
	@override String appLockSeconds({required Object seconds}) => '${seconds} сек.';
	@override String appLockMinutes({required Object minutes}) => '${minutes} мин.';
	@override String get appLockUseBiometrics => 'Использовать биометрию';
	@override String get appLockUseBiometricsDesc => 'Разблокировка по отпечатку пальца или лицу';
	@override String get appLockBiometricsUnavailable => 'На этом устройстве нет настроенной биометрии';
	@override String get appLockSetPin => 'Установить PIN-код';
	@override String get appLockEnterPin => 'Введите PIN-код';
	@override String get appLockConfirmPin => 'Подтвердите PIN-код';
	@override String get appLockCurrentPin => 'Введите текущий PIN-код';
	@override String get appLockNewPin => 'Введите новый PIN-код';
	@override String get appLockPinRequirements => 'PIN-код должен содержать от 4 до 8 цифр';
	@override String get appLockPinsDoNotMatch => 'PIN-коды не совпадают';
	@override String get appLockInvalidPin => 'Неверный PIN-код';
	@override String get appLockSetupFailed => 'Не удалось безопасно сохранить PIN-код';
	@override String get appLockDisable => 'Введите PIN-код для отключения блокировки';
	@override String get appLockChangePin => 'Изменить PIN-код';
	@override String get appLockNow => 'Заблокировать сейчас';
	@override String get appLockUnlock => 'Разблокировать';
	@override String get appLockLockedTitle => 'Заблокировано';
	@override String get appLockLockedDesc => 'Авторизуйтесь для продолжения';
	@override String get appLockAuthenticateReason => 'Авторизуйтесь для разблокировки';
	@override String get appLockEnableBiometricsReason => 'Авторизуйтесь для включения биометрии';
	@override String get appLockBiometricFailed => 'Сбой биометрической аутентификации';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Слишком много попыток. Повторите через ${seconds} с';
	@override String get appLockCredentialUnavailableTitle => 'Не удалось прочитать данные блокировки';
	@override String get appLockCredentialUnavailableDesc => 'Системное хранилище недоступно или данные повреждены. Приложение остается заблокированным. Повторите попытку; если ошибка повторяется, сбросьте блокировку (это отключит ее и сотрет PIN-код).';
	@override String get appLockRetry => 'Повторить';
	@override String get appLockReset => 'Сбросить блокировку';
	@override String get appLockResetAction => 'Сбросить';
	@override String get appLockResetConfirmTitle => 'Сбросить блокировку приложения?';
	@override String get appLockResetConfirmDesc => 'Блокировка будет отключена, а сохраненный PIN-код и настройки биометрии — удалены. Вы сможете настроить ее заново.';
	@override String get appLockRetrySucceeded => 'Данные прочитаны. Введите PIN-код.';
	@override String get appLockRetryFailed => 'По-прежнему не удается прочитать данные';
	@override String get forum => 'Форум';
	@override String get news => 'Новости';
	@override String get community => 'Сообщество';
	@override String get disableForumReplyQuote => 'Отключить цитирование в ответах форума';
	@override String get disableForumReplyQuoteDesc => 'Не добавлять информацию о цитируемом сообщении при ответе на форуме';
	@override String get theaterMode => 'Режим кинотеатра';
	@override String get theaterModeDesc => 'Размывать обложку видео в качестве фона плеера';
	@override String get appLinks => 'Ссылки приложения';
	@override String get defaultBrowser => 'Открытие ссылок';
	@override String get defaultBrowserDesc => 'Откройте параметры ссылок по умолчанию в системных настройках и добавьте сайт iwara.tv';
	@override String get themeMode => 'Режим темы';
	@override String get themeModeDesc => 'Определяет тему оформления приложения';
	@override String get glassEffect => 'Стиль интерфейса';
	@override String get glassEffectDesc => 'Материал элементов интерфейса — заголовков, меню, кнопок и нижней панели';
	@override String get liquidGlassEffect => 'Жидкое стекло';
	@override String get liquidGlassEffectDesc => 'Настоящее размытие и преломление. Выглядит красивее всего, но на слабых устройствах может снижать плавность и повышать расход батареи';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Стандартный стиль Material 3 — непрозрачный, без размытия и теней. Максимальная производительность и автономность';
	@override String get glassEffectIntroTitle => 'Выберите стиль интерфейса';
	@override String get glassEffectIntroContent => 'Заголовки, панель вкладок и меню используют эффект стекла — настоящее размытие и преломление. Если интерфейс подтормаживает или вы предпочитаете простой стиль, выберите Material (непрозрачные поверхности, без размытия и теней).';
	@override String get glassEffectIntroHint => 'Вы можете изменить это в любое время: Настройки → Тема → Стиль интерфейса.';
	@override String get glassEffectIntroDone => 'Оставить';
	@override String get dynamicColor => 'Динамические цвета';
	@override String get dynamicColorDesc => 'Определяет, использует ли приложение динамические цвета системы';
	@override String get useDynamicColor => 'Использовать динамические цвета';
	@override String get useDynamicColorDesc => 'Использовать палитру системы Material You';
	@override String get presetColors => 'Предустановленные цвета';
	@override String get customColors => 'Пользовательские цвета';
	@override String get customColorsDisabledByDynamicColor => 'Включены динамические цвета. Отключите их для выбора палитры вручную.';
	@override String get pickColor => 'Выбрать цвет';
	@override String get cancel => 'Отмена';
	@override String get confirm => 'Подтвердить';
	@override String get noCustomColors => 'Нет пользовательских цветов';
	@override String get recordAndRestorePlaybackProgress => 'Запоминать позицию воспроизведения';
	@override String get autoPlayVideoOnFirstEnter => 'Автовоспроизведение при открытии';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Запускать воспроизведение автоматически при переходе на страницу видео.';
	@override String get autoEnterFullscreen => 'Автоматический полноэкранный режим';
	@override String get autoEnterFullscreenDesc => 'Когда плеер должен автоматически переходить в полноэкранный режим. Приватные, удаленные, внешние видео и режим «картинка в картинке» игнорируются.';
	@override String get autoEnterFullscreenOff => 'Выкл.';
	@override String get autoEnterFullscreenOffDesc => 'Никогда не разворачивать автоматически';
	@override String get autoEnterFullscreenOnPlaybackStart => 'При старте воспроизведения';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Разворачивать сразу при фактическом начале воспроизведения';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'При открытии видео';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Разворачивать сразу при открытии страницы, не дожидаясь воспроизведения';
	@override String get autoEnterFullscreenKind => 'Тип полноэкранного режима';
	@override String get autoEnterFullscreenKindDesc => 'Вариант полноэкранного режима (только для ПК).';
	@override String get autoEnterFullscreenKindSystem => 'Системный полноэкранный';
	@override String get autoEnterFullscreenKindSystemDesc => 'Разворачивать окно на весь экран средствами системы';
	@override String get autoEnterFullscreenKindApp => 'Внутри приложения';
	@override String get autoEnterFullscreenKindAppDesc => 'Окно остается прежним, плеер занимает все окно приложения';
	@override String get signature => 'Подпись';
	@override String get enableSignature => 'Включить подпись';
	@override String get enableSignatureDesc => 'Добавлять ли подпись при публикации ответов';
	@override String get enterSignature => 'Введите подпись';
	@override String get editSignature => 'Изменить подпись';
	@override String get signatureContent => 'Текст подписи';
	@override String get signaturePreview => 'Предпросмотр';
	@override String get signatureSampleBody => 'Здесь ваш текст';
	@override String get signatureRegenerate => 'Обновить';
	@override String get signatureNotSet => 'Не задано';
	@override String get signatureRuleHint => 'Подпись добавляется после текста и отделяется горизонтальной линией. Линию добавляет приложение — вам нужно написать только строку ниже.';
	@override String get signatureInsertVariable => 'Вставить переменную';
	@override String get varDate => 'Дата';
	@override String get varTime => 'Время';
	@override String get varDatetime => 'Дата и время';
	@override String get varWeekday => 'День недели';
	@override String get varPlatform => 'Платформа';
	@override String get varPick => 'Случайная строка';
	@override String get varTitle => 'Заголовок';
	@override String get varAuthor => 'Автор';
	@override String get varTags => 'Теги';
	@override String get varSection => 'Раздел';
	@override String get varReplyTo => 'Кому отвечаете';
	@override String get varPlaytime => 'Позиция воспроизведения';
	@override String get signatureContextGroup => 'Контекстные переменные';
	@override String get signatureContextHint => 'Значения берутся со страницы, с которой вы пишете: страница видео знает название, автора, теги и позицию воспроизведения, форум — раздел и номер сообщения. Справа показаны примеры; то, что подставить нельзя, при отправке просто исчезает.';
	@override String get signatureContextValue => 'Зависит от страницы';
	@override String get varFloor => 'Номер сообщения';
	@override String get varDuration => 'Длительность видео';
	@override String get signatureRecipesHint => 'Не знаете, что написать? Нажмите на любой вариант, возьмите его и поправьте. Ниже показано, как это будет выглядеть на самом деле.';
	@override String get recipeWatchingName => 'Что смотрю';
	@override String get recipeWatchingTemplate => 'Смотрю %title% · %date%';
	@override String get recipeTimestampName => 'Докуда досмотрел';
	@override String get recipeTimestampTemplate => 'На %playtime% из %duration%';
	@override String get recipeHitokotoName => 'Цитата дня';
	@override String get recipeHitokotoTemplate => 'Цитата дня: %hitokoto%';
	@override String get recipeAiName => 'Пусть напишет ИИ';
	@override String get recipeAiTemplate => '%ai_hitokoto%';
	@override String get recipeReplyName => 'Поздороваться в ответе';
	@override String get recipeReplyTemplate => 'Для %reply_to% · отправлено с %platform%';
	@override String get recipeMoodName => 'Случайное настроение';
	@override String get recipeMoodTemplate => 'Настроение: %pick:отличное|так себе|лучше не спрашивать%';
	@override String get signatureRecipesTitle => 'Примеры';
	@override String get signatureRecipesMore => 'Ещё примеры';
	@override String get signatureSceneVideo => 'На странице видео';
	@override String get signatureSceneForum => 'На форуме';
	@override String get signatureSceneAuthor => 'В профиле';
	@override String get signatureSceneNone => 'Без контекста';
	@override String get signatureSceneFromHistory => 'Пример взят из того, что вы смотрели последним. При реальной отправке используется та страница, где вы находитесь.';
	@override String get signatureSceneFromDemo => 'Истории пока нет, поэтому показан условный пример. При реальной отправке используется та страница, где вы находитесь.';
	@override String get signatureDemoVideoTitle => 'Танец в лунном свете';
	@override String get signatureDemoAuthor => 'Hoshino';
	@override String get signatureDemoTags => 'mmd 4k 60fps';
	@override String get signatureDemoThreadTitle => 'Посоветуйте настройки качества';
	@override String get signatureDemoSection => 'Общий раздел';
	@override String get signatureDemoQuote => 'Тише едешь — дальше будешь.';
	@override String get signatureDemoAiQuote => 'Один этот разворот на третьей с половиной минуте уже всё оправдал.';
	@override String get signatureRecipeGroupWatching => 'Когда смотрите';
	@override String get signatureRecipeGroupReplying => 'Когда отвечаете';
	@override String get signatureRecipeGroupForum => 'На форуме';
	@override String get signatureRecipeGroupDaily => 'Каждый день новая строка';
	@override String get signatureRecipeGroupAi => 'Пусть напишет ИИ';
	@override String get signaturePromptSampleContext => 'Этот пробный запуск использует пример контекста страницы видео. При реальной отправке ИИ получает то, что вы смотрите.';
	@override String get recipeAuthorTagsName => 'Автор и теги';
	@override String get recipeAuthorTagsTemplate => '%author% · %tags%';
	@override String get recipeFloorName => 'Ответ на сообщение';
	@override String get recipeFloorTemplate => 'Из сообщения %floor% · для %reply_to%';
	@override String get recipeSectionName => 'Указать раздел';
	@override String get recipeSectionTemplate => 'Из раздела %section%';
	@override String get recipeDailyName => 'Дата и цитата';
	@override String get recipeDailyTemplate => '%date% %weekday% · %hitokoto%';
	@override String get signatureSources => 'Источники данных';
	@override String get signatureAutoTranslate => 'Переводить на мой язык';
	@override String get signatureAutoTranslateDesc => 'Источники вроде Hitokoto пока отдают только китайский. Фраза переводится прямо перед отправкой.';
	@override String get signatureWizardTitle => 'Добавить источник';
	@override String get signatureWizardUrlTitle => 'Адрес запроса';
	@override String get signatureWizardUrlHint => 'Укажите адрес, который возвращает строку текста. Кнопка ниже действительно обратится к нему, чтобы вы увидели ответ.';
	@override String get signatureWizardFetch => 'Запросить';
	@override String get signatureWizardSkipTest => 'Пропустить и только переименовать';
	@override String get signatureWizardPickTitle => 'Выберите нужную часть';
	@override String get signatureWizardPickHint => 'Вот что вернул этот адрес. Нажмите строку, которую должна показывать подпись.';
	@override String get signatureWizardPickPlainHint => 'Ответ пришёл обычным текстом — он и будет показан целиком.';
	@override String get signatureWizardWholeBody => 'Весь ответ';
	@override String get signatureWizardNameTitle => 'Дайте ему имя';
	@override String get signatureWizardNameHint => 'Имя нужно только вам. Подпись обращается к источнику по имени для ссылки ниже.';
	@override String get signatureWizardNext => 'Далее';
	@override String get signatureWizardDone => 'Готово';
	@override String get signatureWizardStripHtml => 'Убрать HTML-теги';
	@override String get signatureWizardAdvanced => 'Дополнительно: вытащить по шаблону';
	@override String get signatureWizardExtractHint => 'Регулярное выражение; берётся первая группа';
	@override String get signatureWizardExtractMissed => 'Шаблон ничего не нашёл — текст остался как есть';
	@override String get signatureWizardChooseTitle => 'Выберите источник';
	@override String get signatureWizardChooseHint => 'Нажмите на готовый — и всё. Либо укажите свой адрес.';
	@override String get signatureWizardCustomSource => 'Свой адрес';
	@override String get signatureWizardWithOrigin => 'Показывать источник цитаты';
	@override String get signatureWizardRandomItem => 'Каждый раз брать другую';
	@override String get signatureWizardSuffixTitle => 'Добавить ещё одно поле';
	@override String get signatureWizardSuffixNone => 'Ничего';
	@override String get signatureOptFlavor => 'Содержание';
	@override String get signatureOptFlavorAny => 'Без ограничений';
	@override String get signatureOptFlavorOtaku => 'Аниме, манга и игры';
	@override String get signatureOptFlavorLiterary => 'Литература и поэзия';
	@override String get signatureOptFlavorMeme => 'Интернет-культура';
	@override String get signatureOptLength => 'Длина';
	@override String get signatureOptLengthAny => 'Без ограничений';
	@override String get signatureOptLengthShort => 'Только короткие';
	@override String get signatureRestoreDefault => 'Вернуть по умолчанию';
	@override String get signatureSourceHitokoto => 'Hitokoto (случайная цитата)';
	@override String get signatureAiSourceName => 'Фраза от ИИ';
	@override String get signatureEditTextHint => 'Это подпись, уже записанная в этот комментарий: фраза и дата теперь просто текст, правьте как угодно. Очистите поле, чтобы убрать подпись.';
	@override String signatureResolving({required Object name}) => 'Создаём ${name}…';
	@override String get signaturePendingValue => '(создаётся при отправке)';
	@override String get signatureAiHint => 'Фраза, которую ИИ пишет на месте — своя для каждого комментария, через настроенного вами провайдера. На страницах видео, галереи и форума он ещё и знает, что вы сейчас смотрите, и может написать об этом.';
	@override String get signatureAiUnavailable => 'Провайдер ИИ ещё не настроен, поэтому этот источник не показывается в панели переменных.';
	@override String get signaturePromptTitle => 'Промпт';
	@override String get signaturePromptHint => 'Именно это уходит модели. Перепишите как угодно: тон, длину, тему. Правила, которые уже есть, стоит оставить.';
	@override String get signaturePromptReset => 'Сбросить по умолчанию';
	@override String get signaturePromptTry => 'Попробовать';
	@override String get signaturePromptSample => 'Что получилось';
	@override String get signaturePromptLanguageHint => 'заменяется языком интерфейса. Без него строка пойдёт на языке промпта.';
	@override String get signaturePromptEdited => 'изменён';
	@override String get signatureVariablesGroup => 'Встроенные переменные';
	@override String get signatureNeedsNetwork => 'Нужна сеть';
	@override String get signatureBuiltinSource => 'Встроенный';
	@override String get signatureSourceIdReserved => 'Это имя занято встроенной переменной';
	@override String get signatureSourcesTitle => 'Свои источники данных';
	@override String get signatureSourcesHint => 'Укажите адрес, который возвращает строку текста, и её можно будет подставлять в подпись.';
	@override String get signatureSourcesEmpty => 'Источников пока нет';
	@override String get signatureAddSource => 'Добавить';
	@override String get signatureEditSource => 'Изменить источник';
	@override String get signatureSourceName => 'Название';
	@override String get signatureSourceId => 'Имя для ссылки';
	@override String get signatureSourceIdHint => 'Под этим именем подпись обращается к источнику';
	@override String get signatureSourceUrl => 'Адрес запроса';
	@override String get signatureSourcePath => 'Путь к значению';
	@override String get signatureSourcePathHint => 'Оставьте пустым, если весь ответ — это текст. Укажите data.text, чтобы взять это поле из JSON.';
	@override String get signatureSourceTest => 'Проверить';
	@override String get signatureSourceTestOk => 'Получилось';
	@override String get signatureSourceTestFailed => 'Ничего не пришло';
	@override String get signatureSourceIdInvalid => 'В имени для ссылки допустимы только строчные буквы, цифры и подчёркивания';
	@override String get signatureSourceIdDuplicate => 'Такое имя уже занято';
	@override String get signatureSourceUrlRequired => 'Укажите адрес запроса';
	@override String get exportConfig => 'Экспорт конфигурации';
	@override String get exportConfigDesc => 'Экспорт настроек и истории (просмотры, позиция воспроизведения, избранное) в файл для резервного копирования или переноса. Загрузки не включаются.';
	@override String get importConfig => 'Импорт конфигурации';
	@override String get importConfigDesc => 'Импорт конфигурации приложения из файла';
	@override String get exportConfigSuccess => 'Конфигурация успешно экспортирована!';
	@override String get exportConfigFailed => 'Не удалось экспортировать конфигурацию';
	@override String get importConfigSuccess => 'Конфигурация успешно импортирована!';
	@override String get importConfigFailed => 'Не удалось импортировать конфигурацию';
	@override String get exportIncludeSensitive => 'Включать конфиденциальные данные';
	@override String get exportIncludeSensitiveDesc => 'Включает ключи API, токены сессий и адрес прокси. Включайте только для личных резервных копий.';
	@override String get importConfigOverwriteWarning => 'Импорт перезапишет текущие настройки и историю (просмотры, прогресс, избранное). Продолжить?';
	@override String get importConfigRestartTitle => 'Импорт выполнен';
	@override String get importConfigRestartContent => 'Конфигурация импортирована. Полностью закройте и перезапустите приложение для применения изменений.';
	@override String get historyUpdateLogs => 'История обновлений';
	@override String get noUpdateLogs => 'Нет истории обновлений';
	@override String get versionLabel => 'Версия: {version}';
	@override String get releaseDateLabel => 'Дата выпуска: {date}';
	@override String get noChanges => 'Нет описания изменений';
	@override String get interaction => 'Взаимодействие';
	@override String get enableVibration => 'Виброотклик';
	@override String get enableVibrationDesc => 'Тактильный отклик при взаимодействии с приложением';
	@override String get defaultKeepVideoToolbarVisible => 'Не скрывать панель управления видео';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Панель управления видео остается видимой при первом открытии страницы видео.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Режим кинотеатра на мобильных устройствах может вызывать просадку производительности. Включайте на свое усмотрение.';
	@override String get fullscreenOrientation => 'Ориентация при переходе в полный экран';
	@override String get fullscreenOrientationDesc => 'Ориентация экрана по умолчанию при разворачивании на весь экран (только для мобильных)';
	@override String get fullscreenOrientationLeftLandscape => 'Альбомная влево';
	@override String get fullscreenOrientationRightLandscape => 'Альбомная вправо';
	@override String get screenFit => 'Масштаб видео';
	@override String get screenFitDesc => 'Как видео заполняет область плеера.';
	@override String get rememberScreenFit => 'Запоминать масштаб видео';
	@override String get rememberScreenFitDesc => 'Применять выбранный масштаб к открываемым видео.';
	@override String get screenFitFit => 'По размеру';
	@override String get screenFitFitDesc => 'Поместить в экран с сохранением пропорций';
	@override String get screenFitStretch => 'Растянуть';
	@override String get screenFitStretchDesc => 'Заполнить область плеера с возможным искажением пропорций';
	@override String get screenFitCover => 'Заполнить';
	@override String get screenFitCoverDesc => 'Заполнить экран с сохранением пропорций и обрезкой краев';
	@override String get screenFitRatioDesc => 'Принудительное соотношение сторон с возможным искажением';
	@override String get jumpLink => 'Быстрый переход';
	@override String get language => 'Язык';
	@override String get languageNativeName => 'Русский';
	@override String get followSystemLanguage => 'Как в системе';
	@override String get languageChangedMessage => 'Язык изменён. Некоторые функции вступят в силу после перезапуска приложения.';
	@override String get languageChanged => 'Язык изменен, перезапустите приложение для применения.';
	@override late final _TranslationsSettingsKeybindingRu keybinding = _TranslationsSettingsKeybindingRu._(_root);
	@override String get gestureControl => 'Управление жестами';
	@override String get leftDoubleTapRewind => 'Двойное нажатие слева: перемотка назад';
	@override String get rightDoubleTapFastForward => 'Двойное нажатие справа: перемотка вперед';
	@override String get doubleTapPause => 'Двойное нажатие: пауза';
	@override String get rightVerticalSwipeVolume => 'Смахивание справа по вертикали: громкость (при входе на новую страницу)';
	@override String get leftVerticalSwipeBrightness => 'Смахивание слева по вертикали: яркость (при входе на новую страницу)';
	@override String get longPressFastForward => 'Долгое нажатие: ускорение';
	@override String get enableMouseHoverShowToolbar => 'Показывать панель при наведении мыши';
	@override String get enableMouseHoverShowToolbarInfo => 'Панель управления видео появляется при наведении курсора и скрывается через 3 секунды бездействия.';
	@override String get enableHorizontalDragSeek => 'Горизонтальный жест: перемотка';
	@override String get enableVideoGestureZoom => 'Масштабирование кадра жестом';
	@override String get enableVideoGestureZoomInfo => 'Сведите/разведите пальцы (или Ctrl + колесико мыши на ПК) для масштабирования кадра видео, затем перетаскивайте для перемещения.';
	@override String get showCenterPlayPauseButton => 'Кнопка воспроизведения по центру';
	@override String get showCenterPlayPauseButtonDesc => 'Показывать крупную кнопку воспроизведения/паузы в центре плеера.';
	@override String get audioVideoConfig => 'Аудио и видео';
	@override String get expandBuffer => 'Увеличенный буфер';
	@override String get expandBufferInfo => 'Увеличивает размер буфера: загрузка длится дольше, но воспроизведение плавнее';
	@override String get videoSyncMode => 'Режим синхронизации видео';
	@override String get videoSyncModeSubtitle => 'Стратегия синхронизации звука и видео';
	@override String get hardwareDecodingMode => 'Режим аппаратного декодирования';
	@override String get hardwareDecodingModeSubtitle => 'Настройки аппаратного декодирования';
	@override String get enableHardwareAcceleration => 'Аппаратное ускорение';
	@override String get enableHardwareAccelerationInfo => 'Включение аппаратного ускорения может улучшить декодирование, но поддерживается не всеми устройствами';
	@override String get useOpenSLESAudioOutput => 'Использовать вывод OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'Низкая задержка звука, может улучшить воспроизведение аудио';
	@override String get videoSyncAudio => 'По звуку';
	@override String get videoSyncDisplayResample => 'Передискретизация дисплея';
	@override String get videoSyncDisplayResampleVdrop => 'Передискретизация (пропуск видеокадров)';
	@override String get videoSyncDisplayResampleDesync => 'Передискретизация (рассинхрон)';
	@override String get videoSyncDisplayTempo => 'Скорость дисплея';
	@override String get videoSyncDisplayVdrop => 'Пропуск видеокадров';
	@override String get videoSyncDisplayAdrop => 'Пропуск аудиокадров';
	@override String get videoSyncDisplayDesync => 'Рассинхрон дисплея';
	@override String get videoSyncDesync => 'Без синхронизации';
	@override late final _TranslationsSettingsForumSettingsRu forumSettings = _TranslationsSettingsForumSettingsRu._(_root);
	@override late final _TranslationsSettingsGallerySettingsRu gallerySettings = _TranslationsSettingsGallerySettingsRu._(_root);
	@override late final _TranslationsSettingsBlockSettingsRu blockSettings = _TranslationsSettingsBlockSettingsRu._(_root);
	@override late final _TranslationsSettingsChatSettingsRu chatSettings = _TranslationsSettingsChatSettingsRu._(_root);
	@override String get hardwareDecodingAuto => 'Авто';
	@override String get hardwareDecodingAutoCopy => 'Авто-копирование';
	@override String get hardwareDecodingAutoSafe => 'Безопасное авто';
	@override String get hardwareDecodingNo => 'Отключено';
	@override String get hardwareDecodingYes => 'Принудительно';
	@override String get cdnDistributionStrategy => 'Распределение CDN';
	@override String get cdnDistributionStrategyDesc => 'Выбор стратегии распределения серверов для ускорения загрузки видео';
	@override String get cdnDistributionStrategyLabel => 'Стратегия распределения';
	@override String get cdnDistributionStrategyNoChange => 'Без изменений (исходный сервер)';
	@override String get cdnDistributionStrategyAuto => 'Автоматически (самый быстрый)';
	@override String get cdnDistributionStrategySpecial => 'Выбрать сервер вручную';
	@override String get cdnSpecialServer => 'Выбрать сервер';
	@override String get cdnRefreshServerListHint => 'Нажмите кнопку ниже для обновления списка серверов';
	@override String get cdnRefreshButton => 'Обновить';
	@override String get cdnFastRingServers => 'Быстрые серверы Fast Ring';
	@override String get cdnRefreshServerListTooltip => 'Обновить список серверов';
	@override String get cdnSpeedTestButton => 'Проверка скорости';
	@override String cdnSpeedTestingButton({required Object count}) => 'Проверка (${count})';
	@override String get cdnNoServerDataHint => 'Нет данных о серверах, нажмите кнопку обновления';
	@override String get cdnTestingStatus => 'Проверка';
	@override String get cdnUnreachableStatus => 'Недоступен';
	@override String get cdnNotTestedStatus => 'Не проверен';
	@override late final _TranslationsSettingsDownloadSettingsRu downloadSettings = _TranslationsSettingsDownloadSettingsRu._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsRu extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Избранные теги';
	@override String get emptyIwara => 'Нет избранных тегов Iwara';
	@override String get emptyOreno3d => 'Нет избранных тегов';
	@override String get addIwaraTag => 'Добавить тег Iwara';
	@override String get quickPickHint => 'Избранные теги будут доступны для быстрого выбора в поиске.';
	@override String get pickerTitle => 'Выбор Oreno3D';
	@override String get searchHint => 'Поиск по названию или оригиналу';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n,
		one: 'Работ: ${n}',
		other: 'Работ: ${n}',
	);
	@override String get browseEntry => 'Обзор: оригинал / персонаж / тег';
	@override String get favoritesSection => 'Избранное';
	@override String get addFavorite => 'Добавить';
	@override String get iwaraTitle => 'Избранные теги Iwara';
	@override String get oreno3dTitle => 'Избранные теги Oreno3D';
	@override String get changeTag => 'Изменить тег';
	@override String get switchToText => 'Поиск по тексту';
}

// Path: oreno3d
class _TranslationsOreno3dRu extends TranslationsOreno3dEn {
	_TranslationsOreno3dRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Теги';
	@override String get characters => 'Персонажи';
	@override String get origin => 'Первоисточник';
	@override String get thirdPartyTagsExplanation => 'Информация о **тегах**, **персонажах** и **источнике**, показанная здесь, предоставлена сторонним сайтом **Oreno3D** исключительно для справки.\n\nЭтот источник доступен только на японском языке, поэтому пока не адаптирован под локализацию.\n\nЕсли вы хотите помочь с локализацией, перейдите в репозиторий.';
	@override late final _TranslationsOreno3dSortTypesRu sortTypes = _TranslationsOreno3dSortTypesRu._(_root);
	@override late final _TranslationsOreno3dErrorsRu errors = _TranslationsOreno3dErrorsRu._(_root);
	@override late final _TranslationsOreno3dLoadingRu loading = _TranslationsOreno3dLoadingRu._(_root);
	@override late final _TranslationsOreno3dMessagesRu messages = _TranslationsOreno3dMessagesRu._(_root);
}

// Path: signIn
class _TranslationsSignInRu extends TranslationsSignInEn {
	_TranslationsSignInRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Сначала войдите в систему';
	@override String get alreadySignedInToday => 'Вы уже отметились сегодня!';
	@override String get youDidNotStickToTheSignIn => 'Серия отметок прервана.';
	@override String get signInSuccess => 'Отметка успешно поставлена!';
	@override String get signInFailed => 'Не удалось отметиться, повторите позже';
	@override String get consecutiveSignIns => 'Дней подряд';
	@override String get failureReason => 'Причина сбоя';
	@override String get selectDateRange => 'Выбрать диапазон дат';
	@override String get startDate => 'Начальная дата';
	@override String get endDate => 'Конечная дата';
	@override String get invalidDate => 'Неверная дата';
	@override String get invalidDateRange => 'Неверный диапазон дат';
	@override String get errorFormatText => 'Ошибка формата даты';
	@override String get errorInvalidText => 'Неверный диапазон дат';
	@override String get errorInvalidRangeText => 'Неверный диапазон дат';
	@override String get dateRangeCantBeMoreThanOneYear => 'Диапазон дат не может превышать один год';
	@override String get signIn => 'Отметиться';
	@override String get signInRecord => 'История отметок';
	@override String get totalSignIns => 'Всего отметок';
	@override String get pleaseSelectSignInStatus => 'Выберите статус отметки';
}

// Path: subscriptions
class _TranslationsSubscriptionsRu extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Войдите в систему для просмотра подписок.';
	@override String get selectUser => 'Выбрать пользователя';
	@override String get noSubscribedUsers => 'Нет подписок';
	@override String get showAllSubscribedUsersContent => 'Контент всех авторов';
}

// Path: videoDetail
class _TranslationsVideoDetailRu extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'Режим «картинка в картинке»';
	@override String resumeFromLastPosition({required Object position}) => 'Продолжить с места остановки: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Воспроизведение с ${position}';
	@override String get restartFromBeginning => 'Начать сначала';
	@override String get dismissResumeTip => 'Скрыть';
	@override late final _TranslationsVideoDetailLocalInfoRu localInfo = _TranslationsVideoDetailLocalInfoRu._(_root);
	@override String get videoIdIsEmpty => 'ID видео пуст';
	@override String get videoInfoIsEmpty => 'Нет данных о видео';
	@override String get thisIsAPrivateVideo => 'Это приватное видео';
	@override String get getVideoInfoFailed => 'Не удалось получить данные о видео, повторите позже';
	@override String get noVideoSourceFound => 'Источник видео не найден';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Тег «${tagId}» скопирован';
	@override String get errorLoadingVideo => 'Ошибка загрузки видео';
	@override String get play => 'Воспроизвести';
	@override String get pause => 'Пауза';
	@override String get exitAppFullscreen => 'Выйти из полноэкранного режима';
	@override String get enterAppFullscreen => 'Полный экран в приложении';
	@override String get exitSystemFullscreen => 'Выйти из полного экрана';
	@override String get enterSystemFullscreen => 'Системный полный экран';
	@override String get seekTo => 'Перемотать на';
	@override String get switchResolution => 'Сменить качество';
	@override String get switchPlaybackSpeed => 'Сменить скорость';
	@override String rewindSeconds({required Object num}) => 'Назад на ${num} сек.';
	@override String fastForwardSeconds({required Object num}) => 'Вперед на ${num} сек.';
	@override String playbackSpeedIng({required Object rate}) => 'Скорость: ${rate}x';
	@override String get brightness => 'Яркость';
	@override String get brightnessLowest => 'Минимальная яркость';
	@override String get volume => 'Громкость';
	@override String get volumeMuted => 'Звук выключен';
	@override String get restoreDefaultZoom => 'Сбросить';
	@override late final _TranslationsVideoDetailGestureGuideRu gestureGuide = _TranslationsVideoDetailGestureGuideRu._(_root);
	@override String get home => 'Главная';
	@override String get videoPlayer => 'Видеоплеер';
	@override String get videoPlayerInfo => 'О видеоплеере';
	@override String get moreSettings => 'Дополнительные настройки';
	@override String get videoPlayerFeatureInfo => 'О возможностях плеера';
	@override String get autoRewind => 'Автоперемотка';
	@override String get rewindAndFastForward => 'Перемотка назад и вперед';
	@override String get volumeAndBrightness => 'Громкость и яркость';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Двойное нажатие по центру: пауза/воспроизведение';
	@override String get showVerticalVideoInFullScreen => 'Вертикальное видео на весь экран';
	@override String get keepLastVolumeAndBrightness => 'Запоминать громкость и яркость';
	@override String get setProxy => 'Настройка прокси';
	@override String get moreFeaturesToBeDiscovered => 'Больше возможностей впереди...';
	@override String get videoPlayerSettings => 'Настройки видеоплеера';
	@override String commentCount({required Object num}) => 'Комментариев: ${num}';
	@override String get writeYourCommentHere => 'Напишите комментарий...';
	@override String get authorOtherVideos => 'Другие видео автора';
	@override String get relatedVideos => 'Похожие видео';
	@override String get privateVideo => 'Это приватное видео';
	@override String get externalVideo => 'Это внешнее видео';
	@override String get openInBrowser => 'Открыть в браузере';
	@override String get resourceDeleted => 'Похоже, это видео удалено :/';
	@override String get noDownloadUrl => 'Ссылка для скачивания отсутствует';
	@override String get startDownloading => 'Начать скачивание';
	@override String get downloadFailed => 'Ошибка скачивания, повторите позже';
	@override String get downloadSuccess => 'Скачивание завершено';
	@override String get download => 'Скачать';
	@override String get downloadManager => 'Менеджер загрузок';
	@override String get resourceNotFound => 'Ресурс не найден';
	@override String get videoLoadError => 'Ошибка загрузки видео';
	@override String get authorNoOtherVideos => 'У автора больше нет других видео';
	@override String get noRelatedVideos => 'Нет похожих видео';
	@override late final _TranslationsVideoDetailPlayerRu player = _TranslationsVideoDetailPlayerRu._(_root);
	@override late final _TranslationsVideoDetailSkeletonRu skeleton = _TranslationsVideoDetailSkeletonRu._(_root);
	@override late final _TranslationsVideoDetailCastRu cast = _TranslationsVideoDetailCastRu._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsRu likeAvatars = _TranslationsVideoDetailLikeAvatarsRu._(_root);
}

// Path: share
class _TranslationsShareRu extends TranslationsShareEn {
	_TranslationsShareRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Поделиться плейлистом';
	@override String get wowDidYouSeeThis => 'Вау, вы это видели?';
	@override String get nameIs => 'Название:';
	@override String get clickLinkToView => 'Нажмите ссылку для просмотра';
	@override String get iReallyLikeThis => 'Мне очень нравится';
	@override String get shareFailed => 'Не удалось поделиться, повторите попытку позже';
	@override String get share => 'Поделиться';
	@override String get shareAsImage => 'Поделиться изображением';
	@override String get shareAsText => 'Поделиться текстом';
	@override String get shareAsImageDesc => 'Поделиться обложкой видео как изображением';
	@override String get shareAsTextDesc => 'Поделиться деталями видео в виде текста';
	@override String get shareAsImageFailed => 'Не удалось поделиться обложкой видео как изображением, повторите попытку позже';
	@override String get shareAsTextFailed => 'Не удалось поделиться деталями видео в виде текста, повторите попытку позже';
	@override String get shareVideo => 'Поделиться видео';
	@override String get authorIs => 'Автор:';
	@override String get shareGallery => 'Поделиться галереей';
	@override String get galleryTitleIs => 'Название галереи:';
	@override String get galleryAuthorIs => 'Автор галереи:';
	@override String get shareUser => 'Поделиться пользователем';
	@override String get userNameIs => 'Имя пользователя:';
	@override String get userAuthorIs => 'Автор пользователя:';
	@override String get comments => 'Комментарии';
	@override String get shareThread => 'Поделиться темой';
	@override String get views => 'Просмотры';
	@override String get sharePost => 'Поделиться публикацией';
	@override String get postTitleIs => 'Заголовок публикации:';
	@override String get postAuthorIs => 'Автор публикации:';
}

// Path: markdown
class _TranslationsMarkdownRu extends TranslationsMarkdownEn {
	_TranslationsMarkdownRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Синтаксис Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'Особый синтаксис Markdown Iwara';
	@override String get internalLink => 'Внутренняя ссылка';
	@override String get supportAutoConvertLinkBelow => 'Поддерживается автоматическое преобразование следующих ссылок:';
	@override String get convertLinkExample => '🎬 Ссылка на видео\n🖼️ Ссылка на изображение\n👤 Ссылка на пользователя\n📌 Ссылка на форум\n🎵 Ссылка на плейлист\n💬 Ссылка на тему';
	@override String get mentionUser => 'Упоминание пользователя';
	@override String get mentionUserDescription => 'Введите @, а затем имя пользователя — оно автоматически преобразуется в ссылку на пользователя';
	@override String get markdownBasicSyntax => 'Основы синтаксиса Markdown';
	@override String get paragraphAndLineBreak => 'Абзац и перенос строки';
	@override String get paragraphAndLineBreakDescription => 'Абзацы разделяются пустой строкой, а два пробела в конце строки преобразуются в перенос строки';
	@override String get paragraphAndLineBreakSyntax => 'Это первый абзац\n\nЭто второй абзац\nЭта строка заканчивается двумя пробелами  \nпреобразуется в перенос строки';
	@override String get textStyle => 'Стиль текста';
	@override String get textStyleDescription => 'Окружите текст специальными символами, чтобы изменить стиль';
	@override String get textStyleSyntax => '**Жирный текст**\n*Курсив*\n~~Зачёркнутый текст~~\n`Код`';
	@override String get quote => 'Цитата';
	@override String get quoteDescription => 'Символ > создаёт цитату, несколько > — многоуровневую цитату';
	@override String get quoteSyntax => '> Это цитата первого уровня\n>> Это цитата второго уровня';
	@override String get list => 'Список';
	@override String get listDescription => 'Нумерованный список создаётся цифрой с точкой, маркированный — знаком -';
	@override String get listSyntax => '1. Первый пункт\n2. Второй пункт\n\n- Пункт маркированного списка\n  - Подпункт\n  - Ещё один подпункт';
	@override String get linkAndImage => 'Ссылка и изображение';
	@override String get linkAndImageDescription => 'Формат ссылки: [текст](URL)\nФормат изображения: ![описание](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[текст ссылки](${link})\n![описание изображения](${imgUrl})';
	@override String get title => 'Заголовок';
	@override String get titleDescription => 'Символ # создаёт заголовок, число символов # задаёт уровень';
	@override String get titleSyntax => '# Заголовок первого уровня\n## Заголовок второго уровня\n### Заголовок третьего уровня';
	@override String get separator => 'Разделитель';
	@override String get separatorDescription => 'Разделитель создаётся тремя или более символами -';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Синтаксис';
}

// Path: forum
class _TranslationsForumRu extends TranslationsForumEn {
	_TranslationsForumRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get attachQuote => 'Прикрепить цитату';
	@override String replyToFloor({required Object floor, required Object username}) => 'Ответ на #${floor} @${username}';
	@override String get removeQuote => 'Убрать цитату';
	@override String get recent => 'Недавние';
	@override String get category => 'Категория';
	@override String get lastReply => 'Последний ответ';
	@override late final _TranslationsForumSitewideRu sitewide = _TranslationsForumSitewideRu._(_root);
	@override late final _TranslationsForumErrorsRu errors = _TranslationsForumErrorsRu._(_root);
	@override String get createPost => 'Создать публикацию';
	@override String get title => 'Заголовок';
	@override String get enterTitle => 'Введите заголовок';
	@override String get content => 'Содержание';
	@override String get enterContent => 'Введите содержание';
	@override String get writeYourContentHere => 'Напишите здесь свой текст...';
	@override String get posts => 'Публикации';
	@override String get threads => 'Темы';
	@override String get forum => 'Форум';
	@override String get createThread => 'Создать тему';
	@override String get selectCategory => 'Выберите категорию';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Осталось ждать: ${minutes} мин ${seconds} с';
	@override late final _TranslationsForumGroupsRu groups = _TranslationsForumGroupsRu._(_root);
	@override late final _TranslationsForumLeafNamesRu leafNames = _TranslationsForumLeafNamesRu._(_root);
	@override late final _TranslationsForumLeafDescriptionsRu leafDescriptions = _TranslationsForumLeafDescriptionsRu._(_root);
	@override String get reply => 'Ответить';
	@override String get pendingReview => 'На рассмотрении';
	@override String get floorNotFound => 'Это сообщение не существует или удалено';
	@override String get floorNotLoadedYet => 'Это сообщение выше — загрузите больше ответов, чтобы перейти к нему';
	@override String get editedAt => 'Дата изменения';
	@override String get copySuccess => 'Скопировано в буфер обмена';
	@override String copySuccessForMessage({required Object str}) => 'Скопировано в буфер обмена: ${str}';
	@override String get editReply => 'Изменить ответ';
	@override String get editTitle => 'Изменить заголовок';
	@override String get submit => 'Отправить';
}

// Path: notifications
class _TranslationsNotificationsRu extends TranslationsNotificationsEn {
	_TranslationsNotificationsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsRu errors = _TranslationsNotificationsErrorsRu._(_root);
	@override String get notifications => 'Уведомления';
	@override String get profile => 'Профиль';
	@override String get postedNewComment => 'Опубликован новый комментарий';
	@override String get inYour => 'В вашем';
	@override String get video => 'Видео';
	@override String get repliedYourVideoComment => 'Ответил(а) на ваш комментарий к видео';
	@override String get copyInfoToClipboard => 'Скопировать информацию об уведомлении в буфер обмена';
	@override String get copySuccess => 'Скопировано в буфер обмена';
	@override String copySuccessForMessage({required Object str}) => 'Скопировано в буфер обмена: ${str}';
	@override String get markAllAsRead => 'Отметить всё как прочитанное';
	@override String get markAllAsReadSuccess => 'Все уведомления отмечены как прочитанные';
	@override String get markAllAsReadFailed => 'Не удалось отметить всё как прочитанное';
	@override String get markSelectedAsRead => 'Отметить выбранные как прочитанные';
	@override String get markSelectedAsReadSuccess => 'Выбранные уведомления отмечены как прочитанные';
	@override String get markSelectedAsReadFailed => 'Не удалось отметить выбранные как прочитанные';
	@override String get markAsRead => 'Отметить как прочитанное';
	@override String get markAsReadSuccess => 'Уведомление отмечено как прочитанное';
	@override String get markAsReadFailed => 'Не удалось отметить уведомление как прочитанное';
	@override String get notificationTypeHelp => 'Справка по типам уведомлений';
	@override String get dueToLackOfNotificationTypeDetails => 'Из-за отсутствия подробностей о типе уведомления поддерживаемые типы могут не охватывать получаемые вами сообщения';
	@override String get helpUsImproveNotificationTypeSupport => 'Если вы хотите помочь нам улучшить поддержку типов уведомлений';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Скопируйте информацию об уведомлении\n2. 🐞 Создайте задачу в репозитории проекта\n\n⚠️ Примечание: информация об уведомлении может содержать личные данные; если вы не хотите публиковать её, можно отправить автору проекта по электронной почте.';
	@override String get goToRepository => 'Перейти в репозиторий';
	@override String get copy => 'Копировать';
	@override String get commentApproved => 'Комментарий одобрен';
	@override String get repliedYourProfileComment => 'Ответил(а) на ваш комментарий в профиле';
	@override String get kReplied => 'ответил(а) на ваш комментарий в';
	@override String get kCommented => 'оставил(а) комментарий к вашему';
	@override String get kVideo => 'видео';
	@override String get kGallery => 'галерее';
	@override String get kProfile => 'профиле';
	@override String get kThread => 'теме';
	@override String get kPost => 'публикации';
	@override String get kCommentSection => 'раздел комментариев';
	@override String get kApprovedComment => 'Комментарий одобрен';
	@override String get kApprovedVideo => 'Видео одобрено';
	@override String get kApprovedGallery => 'Галерея одобрена';
	@override String get kApprovedThread => 'Тема одобрена';
	@override String get kApprovedPost => 'Публикация одобрена';
	@override String get kApprovedForumPost => 'Публикация на форуме одобрена';
	@override String get kRejectedContent => 'Контент отклонён модерацией';
	@override String get kUnknownType => 'Неизвестный тип уведомления';
}

// Path: conversation
class _TranslationsConversationRu extends TranslationsConversationEn {
	_TranslationsConversationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsRu errors = _TranslationsConversationErrorsRu._(_root);
	@override String get conversation => 'Беседа';
	@override String get startConversation => 'Начать беседу';
	@override String get noConversation => 'Нет бесед';
	@override String get selectFromLeftListAndStartConversation => 'Выберите пользователя из списка слева и начните беседу';
	@override String get title => 'Заголовок';
	@override String get body => 'Текст';
	@override String get selectAUser => 'Выберите пользователя';
	@override String get searchUsers => 'Поиск пользователей...';
	@override String get tmpNoConversions => 'Нет бесед';
	@override String get deleteThisMessage => 'Удалить это сообщение';
	@override String get deleteThisMessageSubtitle => 'Это действие нельзя отменить';
	@override String get writeMessageHere => 'Введите сообщение...';
	@override String get lastMessageFromMe => 'Вы: ';
	@override String get sendMessage => 'Отправить сообщение';
}

// Path: splash
class _TranslationsSplashRu extends TranslationsSplashEn {
	_TranslationsSplashRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsRu errors = _TranslationsSplashErrorsRu._(_root);
	@override String get preparing => 'Подготовка...';
	@override String get initializing => 'Инициализация...';
	@override String get loading => 'Загрузка...';
	@override String get ready => 'Готово';
	@override String get initializingMessageService => 'Инициализация службы сообщений...';
}

// Path: download
class _TranslationsDownloadRu extends TranslationsDownloadEn {
	_TranslationsDownloadRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsRu errors = _TranslationsDownloadErrorsRu._(_root);
	@override String get downloadList => 'Список загрузок';
	@override String get viewDownloadList => 'Открыть список загрузок';
	@override String get download => 'Скачать';
	@override String get selectDownloadTitle => 'Выбор загрузки';
	@override String get qualitySectionLabel => 'Качество';
	@override String get categorySectionLabel => 'Категория';
	@override String get saveToPreviewLabel => 'Будет сохранено в';
	@override String saveToPreviewSuggested({required Object name}) => 'Предлагаемое имя файла: ${name} (можно изменить в системном диалоге)';
	@override String get lastUsedBadge => 'Недавно использованное';
	@override String get pickedBadge => 'Выбрано';
	@override String get startDownloading => 'Начать загрузку';
	@override String get clearAllFailedTasks => 'Очистить все неудачные задачи';
	@override String get clearAllFailedTasksConfirmation => 'Вы уверены, что хотите очистить все неудачные задачи загрузки? Файлы этих задач также будут удалены.';
	@override String get clearAllFailedTasksSuccess => 'Все неудачные задачи очищены';
	@override String get clearAllFailedTasksError => 'Произошла ошибка при очистке неудачных задач';
	@override String get downloadStatus => 'Статус загрузки';
	@override String get imageList => 'Список изображений';
	@override String get retryDownload => 'Повторить загрузку';
	@override String get notDownloaded => 'Не скачано';
	@override String get downloaded => 'Скачано';
	@override String get waitingForDownload => 'Ожидание загрузки';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Загрузка (${downloaded}/${total} изображений, ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Загрузка (${downloaded} изображений)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Приостановлено (${downloaded}/${total} изображений, ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'Приостановлено (${downloaded} изображений)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Скачано (всего изображений: ${total})';
	@override String get viewVideoDetail => 'Открыть детали видео';
	@override String get viewGalleryDetail => 'Открыть детали галереи';
	@override String get moreOptions => 'Дополнительно';
	@override String get openFile => 'Открыть файл';
	@override String get playLocally => 'Воспроизвести локально';
	@override String get pause => 'Пауза';
	@override String get resume => 'Продолжить';
	@override String get copyDownloadUrl => 'Копировать ссылку загрузки';
	@override String get showInFolder => 'Показать в папке';
	@override String get deleteTask => 'Удалить задачу';
	@override String get deleteTaskConfirmation => 'Вы уверены, что хотите удалить эту задачу загрузки?\nФайл задачи также будет удалён.';
	@override String get forceDeleteTask => 'Принудительно удалить задачу';
	@override String get forceDeleteTaskConfirmation => 'Вы уверены, что хотите принудительно удалить эту задачу загрузки?\nФайл задачи также будет удалён, даже если он используется.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Загрузка ${downloaded}/${total} (${progress}%) • ${speed} МБ/с';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Загрузка ${downloaded} • ${speed} МБ/с';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Приостановлено ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'Приостановлено • скачано ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Скачано • ${size}';
	@override String get copyDownloadUrlSuccess => 'Ссылка загрузки скопирована';
	@override String totalImageNums({required Object num}) => 'Изображений: ${num}';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Загрузка ${downloaded}/${total} (${progress}%) • ${speed} МБ/с';
	@override String get downloading => 'Загрузка';
	@override String get failed => 'Ошибка';
	@override String get completed => 'Завершено';
	@override String get downloadDetail => 'Детали загрузки';
	@override String get copy => 'Копировать';
	@override String get copySuccess => 'Скопировано';
	@override String get waiting => 'Ожидание';
	@override String get paused => 'Приостановлено';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Загрузка ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Загрузка галереи завершена: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Загрузка завершена: ${fileName}';
	@override String get searchTasks => 'Поиск задач...';
	@override String statusLabel({required Object label}) => 'Статус: ${label}';
	@override String get allStatus => 'Все статусы';
	@override String typeLabel({required Object label}) => 'Тип: ${label}';
	@override String get allTypes => 'Все типы';
	@override String get taskType => 'Тип';
	@override String get video => 'Видео';
	@override String get gallery => 'Галерея';
	@override String get other => 'Другое';
	@override String get clearFilters => 'Сбросить фильтры';
	@override String get pauseAll => 'Приостановить все';
	@override String get resumeAll => 'Запустить все';
	@override String remainingTime({required Object time}) => 'осталось ${time}';
	@override late final _TranslationsDownloadTimelineRu timeline = _TranslationsDownloadTimelineRu._(_root);
	@override late final _TranslationsDownloadErrorTypesRu errorTypes = _TranslationsDownloadErrorTypesRu._(_root);
	@override String get errorDetailCopied => 'Детали ошибки скопированы';
	@override String get errorDetailCopyHint => 'Нажмите и удерживайте, чтобы скопировать детали ошибки';
	@override late final _TranslationsDownloadRestoredPausedRu restoredPaused = _TranslationsDownloadRestoredPausedRu._(_root);
	@override late final _TranslationsDownloadActionsRu actions = _TranslationsDownloadActionsRu._(_root);
	@override late final _TranslationsDownloadNoticeRu notice = _TranslationsDownloadNoticeRu._(_root);
	@override String get emptyTaskList => 'Пока нет задач загрузки';
	@override String get noMatchingTasks => 'Нет подходящих задач';
	@override late final _TranslationsDownloadDeleteByDateRu deleteByDate = _TranslationsDownloadDeleteByDateRu._(_root);
	@override late final _TranslationsDownloadRelocationRu relocation = _TranslationsDownloadRelocationRu._(_root);
	@override late final _TranslationsDownloadCategoryRu category = _TranslationsDownloadCategoryRu._(_root);
	@override late final _TranslationsDownloadLocationRu location = _TranslationsDownloadLocationRu._(_root);
	@override String get maxConcurrentDownloads => 'Макс. одновременных загрузок';
	@override String get maxConcurrentDownloadsDesc => 'Число задач, загружаемых одновременно (1–5)';
	@override String get stillInDevelopment => 'Всё ещё в разработке';
	@override String get saveToAppDirectory => 'Сохранить в каталог приложения';
	@override String get alreadyDownloadedWithQuality => 'Уже скачано в том же качестве. Продолжить загрузку?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Уже скачано в качестве: ${qualities}. Продолжить загрузку?';
	@override String get otherQualities => 'Другое качество';
	@override late final _TranslationsDownloadBatchDownloadRu batchDownload = _TranslationsDownloadBatchDownloadRu._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsRu extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Загрузка завершена';
	@override String get failedTitle => 'Ошибка загрузки';
	@override String completedBody({required Object name}) => 'Загрузка ${name} успешно завершена';
	@override String failedBody({required Object name}) => 'Не удалось скачать ${name}';
	@override String completedToast({required Object name}) => '${name} скачан';
	@override String failedToast({required Object name}) => 'Ошибка загрузки ${name}';
	@override String savedToFolder({required Object dir}) => 'Сохранено в ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Сохранено как ${name} (файл с таким именем уже был)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Сохранено в папку приложения — не удалось записать ${target} (${reason})';
	@override String get viewFolder => 'Показать папку';
	@override String get fixInSettings => 'Исправить в настройках';
	@override String get channelName => 'Статус загрузки';
	@override String get channelDescription => 'Уведомления о завершённых и неудачных загрузках';
}

// Path: favorite
class _TranslationsFavoriteRu extends TranslationsFavoriteEn {
	_TranslationsFavoriteRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsRu errors = _TranslationsFavoriteErrorsRu._(_root);
	@override String get add => 'Добавить';
	@override String get addSuccess => 'Добавлено';
	@override String get addFailed => 'Не удалось добавить';
	@override String get remove => 'Убрать';
	@override String get removeSuccess => 'Убрано';
	@override String get removeFailed => 'Не удалось убрать';
	@override String get removeConfirmation => 'Вы уверены, что хотите убрать этот элемент из избранного?';
	@override String get removeConfirmationSuccess => 'Элемент убран из избранного';
	@override String get removeConfirmationFailed => 'Не удалось убрать элемент из избранного';
	@override String get createFolderSuccess => 'Папка успешно создана';
	@override String get createFolderFailed => 'Не удалось создать папку';
	@override String get createFolder => 'Создать папку';
	@override String get enterFolderName => 'Введите название папки';
	@override String get enterFolderNameHere => 'Введите название папки...';
	@override String get create => 'Создать';
	@override String get items => 'Элементы';
	@override String get newFolderName => 'Новая папка';
	@override String get searchFolders => 'Поиск папок...';
	@override String get searchItems => 'Поиск элементов...';
	@override String get createdAt => 'Дата создания';
	@override String get myFavorites => 'Моё избранное';
	@override String get deleteFolderTitle => 'Удалить папку';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'Вы уверены, что хотите удалить папку ${title}?';
	@override String get removeItemTitle => 'Убрать элемент';
	@override String removeItemConfirmWithTitle({required Object title}) => 'Вы уверены, что хотите удалить элемент ${title}?';
	@override String get removeItemSuccess => 'Элемент убран из избранного';
	@override String get removeItemFailed => 'Не удалось убрать элемент из избранного';
	@override String get localizeFavorite => 'Локальное избранное';
	@override String get editFolderTitle => 'Изменить папку';
	@override String get editFolderSuccess => 'Папка успешно обновлена';
	@override String get editFolderFailed => 'Не удалось обновить папку';
	@override String get searchTags => 'Поиск тегов';
	@override String get noTagsInFolder => 'В этой папке пока нет тегов у элементов';
	@override String get tagFilterMatchAll => 'Показывает только элементы со всеми выбранными тегами';
	@override String get clearSelectedTags => 'Сбросить выбранные теги';
	@override String selectedTagCount({required Object count}) => 'Выбрано: ${count}';
	@override String get noMatchingTags => 'Нет подходящих тегов';
}

// Path: translation
class _TranslationsTranslationRu extends TranslationsTranslationEn {
	_TranslationsTranslationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Текущий сервис';
	@override String get testConnection => 'Проверить подключение';
	@override String get testConnectionSuccess => 'Подключение успешно проверено';
	@override String get testConnectionFailed => 'Проверка подключения не пройдена';
	@override String testConnectionFailedWithMessage({required Object message}) => 'Проверка подключения не пройдена: ${message}';
	@override String get translation => 'Перевод';
	@override String get needVerification => 'Требуется проверка';
	@override String get needVerificationContent => 'Перед включением AI-перевода сначала проверьте подключение';
	@override String get confirm => 'Подтвердить';
	@override String get disclaimer => 'Отказ от ответственности';
	@override String get riskWarning => 'Предупреждение о рисках';
	@override String get dureToRisk1 => 'Поскольку текст создаётся пользователями, он может содержать контент, нарушающий политику контента поставщика AI-услуг';
	@override String get dureToRisk2 => 'Неприемлемый контент может привести к приостановке ключа API или прекращению обслуживания';
	@override String get operationSuggestion => 'Рекомендации по использованию';
	@override String get operationSuggestion1 => '1. Используйте перед строгой проверкой переводимого контента';
	@override String get operationSuggestion2 => '2. Избегайте перевода контента, связанного с насилием, взрослым контентом и т. п.';
	@override String get apiConfig => 'Конфигурация API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Изменение конфигурации автоматически отключит AI-перевод; после включения потребуется пройти тест заново';
	@override String get apiAddress => 'Адрес API';
	@override String get modelName => 'Название модели';
	@override String get modelNameHintText => 'Например: gpt-4-turbo';
	@override String get maxTokens => 'Макс. токенов';
	@override String get maxTokensHintText => 'Например: 32000';
	@override String get temperature => 'Температура';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Нажмите кнопку теста, чтобы проверить доступность подключения к API';
	@override String get requestPreview => 'Предпросмотр запроса';
	@override String get enableAITranslation => 'Включить AI';
	@override String get enabled => 'Включено';
	@override String get disabled => 'Отключено';
	@override String get testing => 'Проверка...';
	@override String get testNow => 'Проверить сейчас';
	@override String get connectionStatus => 'Статус подключения';
	@override String get success => 'Успешно';
	@override String get failed => 'Не удалось';
	@override String get information => 'Информация';
	@override String get viewRawResponse => 'Просмотреть исходный ответ';
	@override String get pleaseCheckInputParametersFormat => 'Проверьте формат входных параметров';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Заполните адрес API, название модели и ключ';
	@override String get pleaseFillInValidConfigurationParameters => 'Заполните корректные параметры конфигурации';
	@override String get pleaseCompleteConnectionTest => 'Пройдите тест подключения';
	@override String get notConfigured => 'Не настроено';
	@override String get apiEndpoint => 'Конечная точка API';
	@override String get configuredKey => 'Настроенный ключ';
	@override String get notConfiguredKey => 'Ключ не настроен';
	@override String get authenticationStatus => 'Статус аутентификации';
	@override String get thisFieldCannotBeEmpty => 'Это поле не может быть пустым';
	@override String get apiKey => 'Ключ API';
	@override String get apiKeyCannotBeEmpty => 'Ключ API не может быть пустым';
	@override String get pleaseEnterValidNumber => 'Введите корректное число';
	@override String get range => 'Диапазон';
	@override String get mustBeGreaterThan => 'Должно быть больше';
	@override String get invalidAPIResponse => 'Некорректный ответ API';
	@override String connectionFailedForMessage({required Object message}) => 'Не удалось подключиться: ${message}';
	@override String get aiTranslationNotEnabledHint => 'AI-перевод не включён, включите его в настройках';
	@override String get goToSettings => 'Перейти в настройки';
	@override String get disableAITranslation => 'Отключить AI-перевод';
	@override String get currentValue => 'Текущее значение';
	@override String get configureTranslationStrategy => 'Настройте стратегию перевода';
	@override String get advancedSettings => 'Расширенные настройки';
	@override String get translationPrompt => 'Подсказка перевода';
	@override String get promptHint => 'Введите подсказку перевода, используйте [TL] как заполнитель для целевого языка';
	@override String get promptHelperText => 'Подсказка должна содержать [TL] как заполнитель для целевого языка';
	@override String get promptMustContainTargetLang => 'Подсказка должна содержать заполнитель [TL]';
	@override String get aiTranslationWillBeDisabled => 'AI-перевод будет отключён';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'Из-за изменения базовой конфигурации AI-перевод будет отключён';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'Из-за изменения подсказки перевода AI-перевод будет отключён';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'Из-за изменения параметров конфигурации AI-перевод будет отключён';
	@override String get onlyOpenAIAPISupported => 'Сейчас поддерживается только OpenAI-совместимый формат API (тело запроса application/json)';
	@override String get streamingTranslation => 'Потоковый перевод';
	@override String get streamingTranslationSupported => 'Потоковый перевод поддерживается';
	@override String get streamingTranslationNotSupported => 'Потоковый перевод не поддерживается';
	@override String get streamingTranslationDescription => 'Потоковый перевод отображает результаты в реальном времени в процессе перевода, обеспечивая лучший пользовательский опыт';
	@override String get usingFullUrlWithHash => 'Используется полный URL (заканчивающийся на #)';
	@override String get baseUrlInputHelperText => 'Если заканчивается на #, будет использоваться как фактический адрес запроса';
	@override String currentActualUrl({required Object url}) => 'Текущий фактический URL: ${url}';
	@override String get urlEndingWithHashTip => 'URL, заканчивающийся на #, будет использоваться напрямую без добавления суффикса';
	@override String get streamingTranslationWarning => 'Примечание: для этой функции требуется поддержка потоковой передачи со стороны API-сервиса; некоторые модели могут её не поддерживать';
	@override String get translationService => 'Сервис перевода';
	@override String get translationServiceDescription => 'Выберите предпочитаемый сервис перевода';
	@override String get googleTranslation => 'Перевод Google';
	@override String get googleTranslationDescription => 'Бесплатный онлайн-сервис перевода с поддержкой множества языков';
	@override String get aiTranslation => 'AI-перевод';
	@override String get aiTranslationDescription => 'Интеллектуальный сервис перевода на основе больших языковых моделей';
	@override String get deeplxTranslation => 'Перевод DeepLX';
	@override String get deeplxTranslationDescription => 'Открытая реализация перевода DeepL, обеспечивающая высокое качество перевода';
	@override String get googleTranslationFeatures => 'Возможности';
	@override String get freeToUse => 'Бесплатно';
	@override String get freeToUseDescription => 'Настройка не требуется, готово к использованию';
	@override String get fastResponse => 'Быстрый отклик';
	@override String get fastResponseDescription => 'Высокая скорость перевода с низкой задержкой';
	@override String get stableAndReliable => 'Стабильно и надёжно';
	@override String get stableAndReliableDescription => 'На основе официального API Google';
	@override String get enabledDefaultService => 'Включено — сервис перевода по умолчанию';
	@override String get notEnabled => 'Не включено';
	@override String get deeplxTranslationService => 'Сервис перевода DeepLX';
	@override String get deeplxDescription => 'DeepLX — это открытая реализация перевода DeepL, поддерживающая режимы конечных точек Free, Pro и Official';
	@override String get serverAddress => 'Адрес сервера';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Базовый адрес сервера DeepLX';
	@override String get endpointType => 'Тип конечной точки';
	@override String get freeEndpoint => 'Free — бесплатная конечная точка, возможны ограничения частоты';
	@override String get proEndpoint => 'Pro — требуется dl_session, более стабильно';
	@override String get officialEndpoint => 'Official — официальный формат API';
	@override String get finalRequestUrl => 'Итоговый URL запроса';
	@override String get apiKeyOptional => 'Ключ API (необязательно)';
	@override String get apiKeyOptionalHint => 'Для доступа к защищённым сервисам DeepLX';
	@override String get apiKeyOptionalHelperText => 'Некоторые сервисы DeepLX требуют ключ API для аутентификации';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Параметр dl_session необходим для режима Pro';
	@override String get dlSessionHelperText => 'Параметр сессии, необходимый для конечной точки Pro; получается в аккаунте DeepL Pro';
	@override String get proModeRequiresDlSession => 'Для режима Pro требуется dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Нажмите кнопку теста, чтобы проверить подключение к API DeepLX';
	@override String get enableDeepLXTranslation => 'Включить перевод DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'Перевод DeepLX будет отключён из-за изменений конфигурации';
	@override String get translatedResult => 'Результат перевода';
	@override String get testSuccess => 'Тест пройден';
	@override String get pleaseFillInDeepLXServerAddress => 'Заполните адрес сервера DeepLX';
	@override String get invalidAPIResponseFormat => 'Некорректный формат ответа API';
	@override String get translationServiceReturnedError => 'Сервис перевода вернул ошибку или пустой результат';
	@override String get connectionFailed => 'Не удалось подключиться';
	@override String get translationFailed => 'Перевод не выполнен';
	@override String get aiTranslationFailed => 'AI-перевод не выполнен';
	@override String get deeplxTranslationFailed => 'Перевод DeepLX не выполнен';
	@override String get aiTranslationTestFailed => 'Тест AI-перевода не пройден';
	@override String get deeplxTranslationTestFailed => 'Тест перевода DeepLX не пройден';
	@override String get streamingTranslationTimeout => 'Тайм-аут потокового перевода, принудительная очистка ресурсов';
	@override String get translationRequestTimeout => 'Тайм-аут запроса перевода';
	@override String get streamingTranslationDataTimeout => 'Тайм-аут приёма данных потокового перевода';
	@override String get dataReceptionTimeout => 'Тайм-аут приёма данных';
	@override String get streamDataParseError => 'Ошибка разбора потоковых данных';
	@override String get streamingTranslationFailed => 'Потоковый перевод не выполнен';
	@override String get fallbackTranslationFailed => 'Резервный обычный перевод также не удался';
	@override String get translationSettings => 'Настройки перевода';
	@override String get enableGoogleTranslation => 'Включить перевод Google';
	@override String get thinking => 'Размышление...';
	@override String get thoughtProcess => 'Процесс рассуждения';
	@override String get modelCompatibility => 'Совместимость моделей';
	@override String get modelCompatibilityDescription => 'Адаптирует параметры запроса для современных моделей, таких как модели рассуждения (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'Модель рассуждений';
	@override String get reasoningModelDescription => 'Для o1/o3, DeepSeek-R1, QwQ и др. Объединяет подсказку с сообщением пользователя, пропускает temperature и использует max_completion_tokens';
	@override String get useMaxCompletionTokens => 'Использовать max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'Новые конечные точки OpenAI требуют max_completion_tokens вместо устаревшего max_tokens';
	@override String get sendTemperature => 'Отправлять temperature';
	@override String get sendTemperatureDescription => 'Отключите для моделей, отвергающих параметр temperature (большинство моделей рассуждений)';
	@override String get showReasoningProcess => 'Показывать процесс рассуждения';
	@override String get showReasoningProcessDescription => 'Показывать сворачиваемые рассуждения моделей рассуждений в диалоге перевода';
	@override String get provider => 'Провайдер';
	@override String get providerOpenAI => 'OpenAI (и совместимые)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Поддерживаются OpenAI (и любая OpenAI-совместимая конечная точка), Anthropic и Google через SDK dartantic_ai';
	@override String get baseUrlOptionalHelperText => 'Необязательно. Оставьте пустым, чтобы использовать конечную точку провайдера по умолчанию; заполните для OpenAI-совместимых/промежуточных точек';
	@override String get defaultEndpoint => 'Конечная точка по умолчанию';
	@override String get providerPreset => 'Пресет провайдера';
	@override String get selectProviderPreset => 'Выберите пресет';
	@override String get presetCustom => 'Пользовательский';
	@override String presetApplied({required Object name}) => 'Пресет применён: ${name}';
	@override late final _TranslationsTranslationPresetNamesRu presetNames = _TranslationsTranslationPresetNamesRu._(_root);
	@override String get fetchModelList => 'Получить список моделей';
	@override String get fetchingModels => 'Получение...';
	@override String get selectModel => 'Выберите модель';
	@override String get searchModel => 'Поиск модели';
	@override String get noModelsFound => 'Модели не найдены';
}

// Path: bottomNav
class _TranslationsBottomNavRu extends TranslationsBottomNavEn {
	_TranslationsBottomNavRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get video => 'Видео';
	@override String get gallery => 'Фото';
	@override String get subscription => 'Лента';
	@override String get community => 'Форум';
	@override String get localMedia => 'Файлы';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsRu extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки порядка навигации';
	@override String get customNavigationOrder => 'Свой порядок навигации';
	@override String get customNavigationOrderDesc => 'Перетащите, чтобы изменить порядок отображения страниц на нижней панели навигации и в боковом меню';
	@override String get restartRequired => 'Требуется перезапуск приложения';
	@override String get navigationItemSorting => 'Сортировка элементов навигации';
	@override String get done => 'Готово';
	@override String get edit => 'Изменить';
	@override String get reset => 'Сбросить';
	@override String get previewEffect => 'Предпросмотр';
	@override String get bottomNavigationPreview => 'Предпросмотр нижней навигации:';
	@override String get sidebarPreview => 'Предпросмотр бокового меню:';
	@override String get confirmResetNavigationOrder => 'Подтвердите сброс порядка навигации';
	@override String get confirmResetNavigationOrderDesc => 'Вы уверены, что хотите сбросить порядок навигации к настройкам по умолчанию?';
	@override String get cancel => 'Отмена';
	@override String get show => 'Показать';
	@override String get hide => 'Скрыть';
	@override String get hidden => 'Скрыто';
	@override String get hideHint => 'Нажмите значок глаза, чтобы показать или скрыть разделы «Сообщество» и локальные файлы';
	@override String get videoDescription => 'Просматривайте популярный видеоконтент';
	@override String get galleryDescription => 'Просматривайте изображения и галереи';
	@override String get subscriptionDescription => 'Смотрите последний контент от пользователей, на которых вы подписаны';
	@override String get forumDescription => 'Участвуйте в обсуждениях сообщества';
	@override String get newsDescription => 'Просматривайте официальные новости, статьи и трансляции';
	@override String get communityDescription => 'Обсуждения на форуме, а также официальные новости, статьи и трансляции';
	@override String get localMediaDescription => 'Просматривайте видео и изображения, хранящиеся на этом устройстве';
}

// Path: news
class _TranslationsNewsRu extends TranslationsNewsEn {
	_TranslationsNewsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Новости';
	@override String get newsUpdates => 'Обновления новостей';
	@override String get articles => 'Статьи';
	@override String get broadcast => 'Трансляция';
	@override String get openInBrowser => 'Открыть в браузере';
}

// Path: displaySettings
class _TranslationsDisplaySettingsRu extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки отображения';
	@override String get layoutSettings => 'Настройки макета';
	@override String get layoutSettingsDesc => 'Настройте число столбцов и точки перелома';
	@override String get gridLayout => 'Сетка';
	@override String get navigationOrderSettings => 'Настройки порядка навигации';
	@override String get customNavigationOrder => 'Свой порядок навигации';
	@override String get customNavigationOrderDesc => 'Настройте порядок отображения страниц на нижней панели навигации и в боковом меню';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsRu extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки макета';
	@override String get descriptionTitle => 'Описание настройки макета';
	@override String get descriptionContent => 'Настроенная здесь конфигурация определяет число столбцов на страницах списков видео и галерей. Выберите автоматический режим, чтобы система подстраивалась под ширину экрана, или ручной режим, чтобы зафиксировать число столбцов.';
	@override String get layoutMode => 'Режим макета';
	@override String get reset => 'Сбросить';
	@override String get autoMode => 'Автоматический режим';
	@override String get autoModeDesc => 'Автоматически подстраивается под ширину экрана';
	@override String get manualMode => 'Ручной режим';
	@override String get manualModeDesc => 'Использовать фиксированное число столбцов';
	@override String get manualSettings => 'Ручные настройки';
	@override String get fixedColumns => 'Фиксированные столбцы';
	@override String get columns => 'столбцов';
	@override String get breakpointConfig => 'Настройка точек перелома';
	@override String get add => 'Добавить';
	@override String get defaultColumns => 'Столбцы по умолчанию';
	@override String get defaultColumnsDesc => 'Отображение по умолчанию для больших экранов';
	@override String get previewEffect => 'Предпросмотр';
	@override String get screenWidth => 'Ширина экрана';
	@override String get addBreakpoint => 'Добавить точку перелома';
	@override String get editBreakpoint => 'Изменить точку перелома';
	@override String get deleteBreakpoint => 'Удалить точку перелома';
	@override String get screenWidthLabel => 'Ширина экрана';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Столбцы';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Введите ширину';
	@override String get enterValidWidth => 'Введите корректную ширину';
	@override String get widthCannotExceed9999 => 'Ширина не может превышать 9999';
	@override String get breakpointAlreadyExists => 'Точка перелома уже существует';
	@override String get enterColumns => 'Введите число столбцов';
	@override String get enterValidColumns => 'Введите корректное число столбцов';
	@override String get columnsCannotExceed12 => 'Число столбцов не может превышать 12';
	@override String get breakpointConflict => 'Точка перелома уже существует';
	@override String get confirmResetLayoutSettings => 'Сбросить настройки макета';
	@override String get confirmResetLayoutSettingsDesc => 'Вы уверены, что хотите сбросить все настройки макета до значений по умолчанию?\n\nБудет восстановлено:\n• Автоматический режим\n• Конфигурация точек перелома по умолчанию';
	@override String get resetToDefaults => 'Сбросить к значениям по умолчанию';
	@override String get confirmDeleteBreakpoint => 'Удалить точку перелома';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'Вы уверены, что хотите удалить точку перелома ${width}px?';
	@override String get noCustomBreakpoints => 'Нет пользовательских точек перелома, используются столбцы по умолчанию';
	@override String get breakpointRange => 'Диапазон точек перелома';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Изменить';
	@override String get delete => 'Удалить';
	@override String get cancel => 'Отмена';
	@override String get save => 'Сохранить';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerRu extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Ошибка видеоплеера';
	@override String get videoLoadFailed => 'Не удалось загрузить видео';
	@override String get videoCodecNotSupported => 'Видеокодек не поддерживается';
	@override String get networkConnectionIssue => 'Проблема с подключением к сети';
	@override String get insufficientPermission => 'Недостаточно прав';
	@override String get unsupportedVideoFormat => 'Неподдерживаемый формат видео';
	@override String get retry => 'Повторить';
	@override String get externalPlayer => 'Внешний плеер';
	@override String get detailedErrorInfo => 'Подробная информация об ошибке';
	@override String get format => 'Формат';
	@override String get suggestion => 'Рекомендация';
	@override String get androidWebmCompatibilityIssue => 'Устройства Android ограниченно поддерживают формат WEBM. Рекомендуется использовать внешний плеер или скачать приложение-плеер с поддержкой WEBM';
	@override String get currentDeviceCodecNotSupported => 'Текущее устройство не поддерживает кодек для этого формата видео';
	@override String get checkNetworkConnection => 'Проверьте подключение к сети и повторите попытку';
	@override String get appMayLackMediaPermission => 'Возможно, у приложения нет необходимых разрешений на воспроизведение медиа';
	@override String get tryOtherVideoPlayer => 'Попробуйте использовать другой видеоплеер';
	@override String get unrecognizedVideoFormat => 'Нераспознанный видеофайл';
	@override String get unrecognizedVideoFormatSuggestion => 'Возможно, ссылка устарела или ответ не является видео. Повторите попытку или откройте в другом приложении.';
	@override String get accessDenied => 'Сервер отклонил этот запрос (403)';
	@override String get accessDeniedSuggestion => 'Ссылка для воспроизведения, скорее всего, устарела. Нажмите «Повторить», чтобы получить её заново, или откройте в другом приложении.';
	@override String get mute => 'Без звука';
	@override String get unmute => 'Включить звук';
	@override String get video => 'ВИДЕО';
	@override String get serverSelector => 'Выбор CDN-сервера';
	@override String get serverSelectorDescription => 'Выберите сервер с наименьшей задержкой для наилучшего воспроизведения';
	@override String get retestSpeed => 'Повторить тест скорости';
	@override String get waitingForSpeedTest => 'Ожидание теста скорости';
	@override String get testingSpeed => 'Проверка скорости...';
	@override String get testFailed => 'Тест не пройден';
	@override String get loadingServerList => 'Загрузка списка серверов...';
	@override String get noAvailableServers => 'Нет доступных серверов';
	@override String get refreshServerList => 'Обновить список серверов';
	@override String get cannotGetSource => 'Не удаётся получить источник текущего видео';
	@override String switchedToServer({required Object serverName}) => 'Переключено на сервер: ${serverName}';
	@override String serverCount({required Object count}) => 'Всего серверов: ${count}';
	@override String statusCode({required Object code}) => 'Код состояния: ${code}';
	@override String get connectionFailed => 'Не удалось подключиться';
	@override String get connectionTimeout => 'Тайм-аут подключения';
	@override String get networkError => 'Ошибка сети';
	@override String get sslError => 'Ошибка SSL-сертификата';
	@override String get testCompleted => 'Тест завершён';
	@override String get local => 'Локально';
	@override String get unknown => 'Неизвестно';
	@override String get localVideoPathEmpty => 'Путь к локальному видео пуст';
	@override String localVideoFileNotExists({required Object path}) => 'Локальный видеофайл не существует: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'Не удалось воспроизвести локальное видео: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Перетащите сюда видеофайл для воспроизведения';
	@override String get supportedFormats => 'Поддерживаемые форматы: MP4, MKV, AVI, MOV, WEBM и др.';
	@override String get noSupportedVideoFile => 'Поддерживаемый видеофайл не найден';
	@override String get retryingOpenVideoLink => 'Не удалось открыть ссылку на видео, повторная попытка';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'Не удалось загрузить декодер: ${event}. Попробуйте переключиться на программное декодирование в настройках плеера и заново открыть страницу';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Ошибка загрузки видео: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Обнаружены повторяющиеся сбои воспроизведения. Перейдите в «Настройки» > «Диагностика и обратная связь», чтобы экспортировать логи.';
	@override String get openSettingsAction => 'Просмотреть';
	@override late final _TranslationsMediaPlayerNoticeRu notice = _TranslationsMediaPlayerNoticeRu._(_root);
	@override String get imageLoadFailed => 'Не удалось загрузить изображение';
	@override String get unsupportedImageFormat => 'Неподдерживаемый формат изображения';
	@override String get tryOtherViewer => 'Попробуйте использовать другой просмотрщик';
}

// Path: diagnostics
class _TranslationsDiagnosticsRu extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Сведения о диагностике';
	@override String get appVersionLabel => 'Версия приложения';
	@override String memoryUsage({required Object memMB}) => 'Использование памяти: ${memMB} МБ';
	@override String get deviceInfoUnavailable => 'Не удалось получить информацию об устройстве';
	@override String get secureStorageLabel => 'Защищённое хранилище';
	@override String get secureStorageHealthy => 'Доступно';
	@override String get secureStorageRecovered => 'Восстановлено сбросом (прежние данные удалены)';
	@override String get secureStorageUnavailable => 'Недоступно (вход сохранён с резервным шифрованием)';
	@override String get secureStoragePlatformOptOut => 'Локальное шифрование согласно политике платформы (в macOS системная связка ключей не используется)';
	@override String get secureStorageDualWrite => ' (включена защита двойной записью)';
	@override String get schemaHealthLabel => 'Схема базы данных';
	@override String get schemaHealthOk => 'ОК';
	@override String get schemaHealthRepairedNow => 'Восстановлена защитным механизмом при этом запуске (миграция не сработала)';
	@override String get schemaHealthRepairedBefore => 'Ранее была восстановлена защитным механизмом';
	@override String get logPolicySectionTitle => 'Политика логов';
	@override String get configServiceUnavailable => 'Служба конфигурации не инициализирована. Невозможно изменить политику логов.';
	@override String get enableLoggingTitle => 'Вести журнал';
	@override String get enableLoggingSubtitle => 'Отключите, чтобы прекратить запись новых логов';
	@override String get enableLogPersistenceTitle => 'Сохранять логи на диск';
	@override String get enableLogPersistenceSubtitle => 'Отключите, чтобы хранить логи только в памяти и прекратить запись на диск';
	@override String get minLogLevelTitle => 'Минимальный уровень логов';
	@override String get minLogLevelSubtitle => 'Логи ниже этого уровня будут отфильтрованы';
	@override String get maxFileSizeTitle => 'Ограничение размера одного файла';
	@override String get maxFileSizeSubtitle => 'Ротация при достижении порога';
	@override String get rotatedFileCountTitle => 'Число ротируемых файлов основного лога';
	@override String get rotatedFileCountSubtitle => 'Число сохраняемых файлов без учёта текущего';
	@override String get hangFileSizeTitle => 'Ограничение размера логов зависаний';
	@override String get hangFileSizeSubtitle => 'Управляйте ростом файла hang_events';
	@override String get hangRotatedFileCountTitle => 'Число ротируемых файлов логов зависаний';
	@override String get hangRotatedFileCountSubtitle => 'Управляйте объёмом сохраняемой истории hang_events';
	@override String get healthSectionTitle => 'Состояние логов';
	@override String get refreshMetrics => 'Обновить метрики';
	@override String get toolsSectionTitle => 'Инструменты';
	@override String get privacyNotice => 'Логи могут содержать конфиденциальную информацию, например данные аккаунта и параметры запросов. Не публикуйте полные логи в задачах; сначала проверьте их и отправьте по электронной почте.';
	@override String get exportLogsTitle => 'Экспорт логов';
	@override String get exportLogsSubtitle => 'Проверьте личные данные перед отправкой разработчикам';
	@override String get viewLogsTitle => 'Просмотр логов';
	@override String get viewLogsSubtitle => 'Просмотр логов выполнения в реальном времени';
	@override String get copySupportEmailTitle => 'Копировать адрес поддержки';
	@override String get reportIssueTitle => 'Сообщить о проблеме';
	@override String get reportIssueSubtitle => 'Опишите шаги воспроизведения на GitHub (не прикрепляйте полные логи)';
	@override String get healthSummaryUnavailable => 'Данных о состоянии логов пока нет';
	@override String get healthMetricsUnavailable => 'Метрики состояния ещё не собраны';
	@override String get healthNoRiskIndicators => 'Индикаторов риска не обнаружено';
	@override late final _TranslationsDiagnosticsHealthAlertRu healthAlert = _TranslationsDiagnosticsHealthAlertRu._(_root);
	@override late final _TranslationsDiagnosticsToastRu toast = _TranslationsDiagnosticsToastRu._(_root);
	@override String get shareSubject => 'Диагностические логи LoveIwara (содержат конфиденциальные данные, делитесь осторожно)';
}

// Path: logViewer
class _TranslationsLogViewerRu extends TranslationsLogViewerEn {
	_TranslationsLogViewerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Просмотр логов';
	@override String get searchHint => 'Поиск по логам...';
	@override String get emptyState => 'Нет логов';
	@override String get copiedToClipboard => 'Скопировано в буфер обмена';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogRu extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Приложение неожиданно закрылось';
	@override String get description => 'Мы обнаружили некорректное завершение в прошлом сеансе. Экспортируйте логи диагностики и отправьте их разработчику по электронной почте, чтобы помочь исправить проблему.';
	@override String previousVersion({required Object version}) => 'Прошлая версия: ${version}';
	@override String previousStart({required Object time}) => 'Прошлый запуск: ${time}';
	@override String lastException({required Object message}) => 'Последнее исключение: ${message}';
	@override String get lastHangRecovered => 'В прошлый раз было обнаружено зависание интерфейса, и оно было автоматически устранено';
	@override String lastHangStalled({required Object stalledMs}) => 'В прошлый раз было обнаружено возможное зависание интерфейса длительностью около ${stalledMs} мс';
	@override String get exportGuide => 'Перейдите в «Настройки» > «Диагностика и обратная связь» > «Экспорт логов».';
	@override String get privacyHint => 'Логи могут содержать личные данные. Проверьте их перед отправкой на адрес:';
	@override String get issueWarning => 'Не прикрепляйте полные логи публично в задачах GitHub';
	@override String get acknowledge => 'Понятно';
	@override String get supportEmailCopied => 'Адрес скопирован';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogRu extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ввод ссылки';
	@override String supportedLinksHint({required Object webName}) => 'Поддерживается распознавание нескольких ссылок ${webName} с быстрым переходом на соответствующую страницу в приложении (отделяйте ссылки от другого текста пробелами)';
	@override String inputHint({required Object webName}) => 'Введите ссылку ${webName}';
	@override String get validatorEmptyLink => 'Введите ссылку';
	@override String validatorNoIwaraLink({required Object webName}) => 'Действительная ссылка ${webName} не обнаружена';
	@override String get multipleLinksDetected => 'Обнаружено несколько ссылок, выберите одну:';
	@override String notIwaraLink({required Object webName}) => 'Недействительная ссылка ${webName}';
	@override String linkParseError({required Object error}) => 'Ошибка разбора ссылки: ${error}';
	@override String get unsupportedLinkDialogTitle => 'Неподдерживаемая ссылка';
	@override String get unsupportedLinkDialogContent => 'Этот тип ссылки нельзя открыть напрямую в приложении, требуется внешний браузер.\n\nОткрыть эту ссылку в браузере?';
	@override String get openInBrowser => 'Открыть в браузере';
	@override String get confirmOpenBrowserDialogTitle => 'Подтвердите открытие браузера';
	@override String get confirmOpenBrowserDialogContent => 'Следующая ссылка будет открыта во внешнем браузере:';
	@override String get confirmContinueBrowserOpen => 'Вы уверены, что хотите продолжить?';
	@override String get browserOpenFailed => 'Не удалось открыть ссылку';
	@override String get unsupportedLink => 'Неподдерживаемая ссылка';
	@override String get cancel => 'Отмена';
	@override String get confirm => 'Открыть в браузере';
}

// Path: log
class _TranslationsLogRu extends TranslationsLogEn {
	_TranslationsLogRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Управление логами';
	@override String get enableLogPersistence => 'Сохранять логи в базе данных';
	@override String get enableLogPersistenceDesc => 'Сохранять логи в базе данных для анализа';
	@override String get logDatabaseSizeLimit => 'Лимит размера базы данных логов';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Текущий: ${size}';
	@override String get exportCurrentLogs => 'Экспортировать текущие логи';
	@override String get exportCurrentLogsDesc => 'Экспортировать текущие логи приложения, чтобы помочь разработчикам диагностировать проблемы';
	@override String get exportHistoryLogs => 'Экспортировать историю логов';
	@override String get exportHistoryLogsDesc => 'Экспортировать логи за указанный диапазон дат';
	@override String get exportMergedLogs => 'Экспортировать объединённые логи';
	@override String get exportMergedLogsDesc => 'Экспортировать объединённые логи за указанный диапазон дат';
	@override String get showLogStats => 'Показать статистику логов';
	@override String get logExportSuccess => 'Экспорт логов выполнен';
	@override String logExportFailed({required Object error}) => 'Ошибка экспорта логов: ${error}';
	@override String get showLogStatsDesc => 'Просмотр статистики по различным типам логов';
	@override String logExtractFailed({required Object error}) => 'Не удалось получить статистику логов: ${error}';
	@override String get clearAllLogs => 'Очистить все логи';
	@override String get clearAllLogsDesc => 'Очистить все данные логов';
	@override String get confirmClearAllLogs => 'Подтвердите очистку';
	@override String get confirmClearAllLogsDesc => 'Вы уверены, что хотите очистить все данные логов? Это действие нельзя отменить.';
	@override String get clearAllLogsSuccess => 'Логи успешно очищены';
	@override String clearAllLogsFailed({required Object error}) => 'Не удалось очистить логи: ${error}';
	@override String get unableToGetLogSizeInfo => 'Не удалось получить информацию о размере логов';
	@override String get currentLogSize => 'Текущий размер логов:';
	@override String get logCount => 'Количество логов:';
	@override String get logCountUnit => 'логов';
	@override String get logSizeLimit => 'Лимит размера логов:';
	@override String get usageRate => 'Использование:';
	@override String get exceedLimit => 'Превышен лимит';
	@override String get remaining => 'Осталось';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Текущий размер логов превышен, очистите старые логи или увеличьте лимит размера';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Текущий размер логов почти достиг лимита, очистите старые логи';
	@override String get cleaningOldLogs => 'Очистка старых логов...';
	@override String get logCleaningCompleted => 'Очистка логов завершена';
	@override String get logCleaningProcessMayNotBeCompleted => 'Процесс очистки логов может быть не завершён';
	@override String get cleanExceededLogs => 'Очистить превышающие лимит логи';
	@override String get noLogsToExport => 'Нет логов для экспорта';
	@override String get exportingLogs => 'Экспорт логов...';
	@override String get noHistoryLogsToExport => 'Нет истории логов для экспорта, сначала некоторое время попользуйтесь приложением';
	@override String get selectLogDate => 'Выберите дату логов';
	@override String get today => 'Сегодня';
	@override String get selectMergeRange => 'Выберите диапазон объединения';
	@override String get selectMergeRangeHint => 'Выберите временной диапазон логов для объединения';
	@override String selectMergeRangeDays({required Object days}) => 'Последние ${days} дней';
	@override String get logStats => 'Статистика логов';
	@override String todayLogs({required Object count}) => 'Логи за сегодня: ${count}';
	@override String recent7DaysLogs({required Object count}) => 'Логи за последние 7 дней: ${count}';
	@override String totalLogs({required Object count}) => 'Всего логов: ${count}';
	@override String get setLogDatabaseSizeLimit => 'Задать лимит размера базы данных логов';
	@override String currentLogSizeWithSize({required Object size}) => 'Текущий размер логов: ${size}';
	@override String get warning => 'Предупреждение';
	@override String newSizeLimit({required Object size}) => 'Новый лимит размера: ${size}';
	@override String get confirmToContinue => 'Подтвердите для продолжения';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Лимит размера логов установлен: ${size}';
}

// Path: emoji
class _TranslationsEmojiRu extends TranslationsEmojiEn {
	_TranslationsEmojiRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get recentlyUsed => 'Недавние';
	@override String insertedCount({required Object count}) => 'Вставлено: ${count}';
	@override String get name => 'Эмодзи';
	@override String get size => 'Размер';
	@override String get small => 'Маленький';
	@override String get medium => 'Средний';
	@override String get large => 'Большой';
	@override String get extraLarge => 'Очень большой';
	@override String get copyEmojiLinkSuccess => 'Ссылка на эмодзи скопирована';
	@override String get preview => 'Просмотр эмодзи';
	@override String get library => 'Библиотека эмодзи';
	@override String get noEmojis => 'Нет эмодзи';
	@override String get clickToAddEmojis => 'Нажмите кнопку в правом верхнем углу, чтобы добавить эмодзи';
	@override String get addEmojis => 'Добавить эмодзи';
	@override String get imagePreview => 'Просмотр изображения';
	@override String get imageLoadFailed => 'Не удалось загрузить изображение';
	@override String get loading => 'Загрузка...';
	@override String get delete => 'Удалить';
	@override String get close => 'Закрыть';
	@override String get deleteImage => 'Удалить изображение';
	@override String get confirmDeleteImage => 'Вы уверены, что хотите удалить это изображение?';
	@override String get cancel => 'Отмена';
	@override String get batchDelete => 'Пакетное удаление';
	@override String confirmBatchDelete({required Object count}) => 'Вы уверены, что хотите удалить выбранные изображения (${count})? Это действие нельзя отменить.';
	@override String get deleteSuccess => 'Успешно удалено';
	@override String get addImage => 'Добавить изображение';
	@override String get addImageByUrl => 'Добавить по URL';
	@override String get addImageUrl => 'Добавить URL изображения';
	@override String get imageUrl => 'URL изображения';
	@override String get enterImageUrl => 'Введите URL изображения';
	@override String get add => 'Добавить';
	@override String get batchImport => 'Пакетный импорт';
	@override String get enterJsonUrlArray => 'Введите массив URL в формате JSON:';
	@override String get formatExample => 'Пример формата:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Вставьте массив URL в формате JSON';
	@override String get import => 'Импорт';
	@override String importSuccess({required Object count}) => 'Успешно импортировано изображений: ${count}';
	@override String get jsonFormatError => 'Ошибка формата JSON, проверьте ввод';
	@override String get createGroup => 'Создать группу эмодзи';
	@override String get groupName => 'Название группы';
	@override String get enterGroupName => 'Введите название группы';
	@override String get create => 'Создать';
	@override String get editGroupName => 'Изменить название группы';
	@override String get save => 'Сохранить';
	@override String get deleteGroup => 'Удалить группу';
	@override String get confirmDeleteGroup => 'Вы уверены, что хотите удалить эту группу эмодзи? Все изображения в группе также будут удалены.';
	@override String imageCount({required Object count}) => 'Изображений: ${count}';
	@override String get selectEmoji => 'Выберите эмодзи';
	@override String get noEmojisInGroup => 'В этой группе нет эмодзи';
	@override String get goToSettingsToAddEmojis => 'Перейдите в настройки, чтобы добавить эмодзи';
	@override String get emojiManagement => 'Управление эмодзи';
	@override String get manageEmojiGroupsAndImages => 'Управление группами и изображениями эмодзи';
	@override String get uploadLocalImages => 'Загрузить локальные изображения';
	@override String get uploadingImages => 'Загрузка изображений';
	@override String uploadingImagesProgress({required Object count}) => 'Загрузка изображений (${count}), подождите...';
	@override String get doNotCloseDialog => 'Не закрывайте это окно';
	@override String uploadSuccess({required Object count}) => 'Успешно загружено изображений: ${count}';
	@override String uploadFailed({required Object count}) => 'Не удалось: ${count}';
	@override String get uploadFailedMessage => 'Не удалось загрузить изображение, проверьте подключение к сети или формат файла';
	@override String uploadErrorMessage({required Object error}) => 'Произошла ошибка при загрузке: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterRu extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Выберите поле';
	@override String get add => 'Добавить';
	@override String get clear => 'Очистить';
	@override String get clearAll => 'Очистить всё';
	@override String get generatedQuery => 'Сформированный запрос';
	@override String get copyToClipboard => 'Копировать в буфер обмена';
	@override String get copied => 'Скопировано';
	@override String filterCount({required Object count}) => 'Фильтров: ${count}';
	@override String get filterSettings => 'Настройки фильтра';
	@override String get field => 'Поле';
	@override String get operator => 'Оператор';
	@override String get language => 'Язык';
	@override String get value => 'Значение';
	@override String get dateRange => 'Диапазон дат';
	@override String get numberRange => 'Диапазон чисел';
	@override String get from => 'От';
	@override String get to => 'До';
	@override String get date => 'Дата';
	@override String get number => 'Число';
	@override String get boolean => 'Логическое';
	@override String get tags => 'Теги';
	@override String get select => 'Выбрать';
	@override String get clickToSelectDate => 'Нажмите, чтобы выбрать дату';
	@override String get pleaseEnterValidNumber => 'Введите корректное число';
	@override String get pleaseEnterValidDate => 'Введите корректный формат даты (ГГГГ-ММ-ДД)';
	@override String get startValueMustBeLessThanEndValue => 'Начальное значение должно быть меньше конечного';
	@override String get startDateMustBeBeforeEndDate => 'Дата начала должна быть раньше даты окончания';
	@override String get pleaseFillStartValue => 'Укажите начальное значение';
	@override String get pleaseFillEndValue => 'Укажите конечное значение';
	@override String get rangeValueFormatError => 'Ошибка формата значения диапазона';
	@override String get contains => 'Содержит';
	@override String get equals => 'Равно';
	@override String get notEquals => 'Не равно';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Диапазон';
	@override String get kIn => 'Содержит любой из';
	@override String get notIn => 'Не содержит ни одного из';
	@override String get username => 'Имя пользователя';
	@override String get nickname => 'Псевдоним';
	@override String get registrationDate => 'Дата регистрации';
	@override String get description => 'Описание';
	@override String get title => 'Заголовок';
	@override String get body => 'Текст';
	@override String get author => 'Автор';
	@override String get publishDate => 'Дата публикации';
	@override String get private => 'Приватное';
	@override String get duration => 'Длительность (в секундах)';
	@override String get likes => 'Отметки «Нравится»';
	@override String get views => 'Просмотры';
	@override String get comments => 'Комментарии';
	@override String get rating => 'Рейтинг';
	@override String get imageCount => 'Количество изображений';
	@override String get videoCount => 'Количество видео';
	@override String get createDate => 'Дата создания';
	@override String get content => 'Контент';
	@override String get all => 'Все';
	@override String get adult => 'Для взрослых';
	@override String get general => 'Общее';
	@override String get yes => 'Да';
	@override String get no => 'Нет';
	@override String get users => 'Пользователи';
	@override String get videos => 'Видео';
	@override String get images => 'Изображения';
	@override String get posts => 'Публикации';
	@override String get forumThreads => 'Темы форума';
	@override String get forumPosts => 'Публикации форума';
	@override String get playlists => 'Плейлисты';
	@override late final _TranslationsSearchFilterSortTypesRu sortTypes = _TranslationsSearchFilterSortTypesRu._(_root);
	@override String get drawerSubtitle => 'Изменения применяются сразу';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupRu extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeRu welcome = _TranslationsFirstTimeSetupWelcomeRu._(_root);
	@override late final _TranslationsFirstTimeSetupBasicRu basic = _TranslationsFirstTimeSetupBasicRu._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkRu network = _TranslationsFirstTimeSetupNetworkRu._(_root);
	@override late final _TranslationsFirstTimeSetupThemeRu theme = _TranslationsFirstTimeSetupThemeRu._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerRu player = _TranslationsFirstTimeSetupPlayerRu._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialRu spatial = _TranslationsFirstTimeSetupSpatialRu._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionRu completion = _TranslationsFirstTimeSetupCompletionRu._(_root);
	@override late final _TranslationsFirstTimeSetupCommonRu common = _TranslationsFirstTimeSetupCommonRu._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperRu extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Обнаружен системный прокси';
	@override String get copied => 'Скопировано';
	@override String get copy => 'Копировать';
}

// Path: tagSelector
class _TranslationsTagSelectorRu extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Выбрать теги';
	@override String get clickToSelectTags => 'Нажмите, чтобы выбрать теги';
	@override String get addTag => 'Добавить тег';
	@override String get removeTag => 'Убрать тег';
	@override String get deleteTag => 'Удалить тег';
	@override String get usageInstructions => 'Сначала добавьте теги, затем нажимайте, чтобы выбрать из существующих тегов';
	@override String get usageInstructionsTooltip => 'Инструкция по использованию';
	@override String get addTagTooltip => 'Добавить тег';
	@override String get removeTagTooltip => 'Убрать тег';
	@override String get cancelSelection => 'Отменить выбор';
	@override String get selectAll => 'Выбрать все';
	@override String get cancelSelectAll => 'Отменить выбор всех';
	@override String get delete => 'Удалить';
}

// Path: anime4k
class _TranslationsAnime4kRu extends TranslationsAnime4kEn {
	_TranslationsAnime4kRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Масштабирование и шумоподавление видео в реальном времени для улучшения качества аниме';
	@override String get settings => 'Настройки Anime4K';
	@override String get preset => 'Пресет Anime4K';
	@override String get disable => 'Отключить Anime4K';
	@override String get disableDescription => 'Отключить эффекты улучшения видео';
	@override String get highQualityPresets => 'Пресеты высокого качества';
	@override String get fastPresets => 'Быстрые пресеты';
	@override String get litePresets => 'Облегчённые пресеты';
	@override String get moreLitePresets => 'Более облегчённые пресеты';
	@override String get customPresets => 'Пользовательские пресеты';
	@override late final _TranslationsAnime4kPresetGroupsRu presetGroups = _TranslationsAnime4kPresetGroupsRu._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsRu presetDescriptions = _TranslationsAnime4kPresetDescriptionsRu._(_root);
	@override late final _TranslationsAnime4kPresetNamesRu presetNames = _TranslationsAnime4kPresetNamesRu._(_root);
	@override String get performanceTip => '💡 Совет: выбирайте пресеты с учётом производительности устройства. На слабых устройствах рекомендуются облегчённые пресеты.';
	@override String get compatibilityTip => '⚠️ Некоторые мобильные GPU (например, Kirin 980 / Mali-G76) не могут отрисовывать пользовательские шейдеры. Если изображение становится чёрным, а звук продолжает воспроизводиться, отключите Anime4K здесь.';
	@override String get autoDisabledOnRenderFailure => 'GPU вашего устройства не смог отрисовать шейдер Anime4K, поэтому он был отключён автоматически.';
}

// Path: siteMode
class _TranslationsSiteModeRu extends TranslationsSiteModeEn {
	_TranslationsSiteModeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Режим сайта';
	@override String get mainSite => 'Основной';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Текущий ${currentSite} · нажмите, чтобы переключиться на ${nextSite}';
	@override String get dialogTitle => 'Переключить режим сайта';
	@override String get dialogDescription => 'Переключение обновит всё приложение и сбросит ранее загруженные списки и состояние страниц.';
	@override String get chooseLinkTargetTitle => 'Выберите целевой сайт';
	@override String get chooseLinkTargetDescription => 'Эта ссылка не содержит домена. Выберите, открыть её в «Основном» или «AI».';
	@override String get chooseLinkTargetHint => 'После открытия эта страница и последующие запросы деталей продолжат использовать выбранный сайт.';
	@override String get alreadyUsing => 'Вы уже используете этот режим сайта.';
	@override String openInSite({required Object site}) => 'Открыть в ${site}';
	@override String confirmUsing({required Object site}) => 'После подтверждения будущие запросы будут использовать режим ${site}.';
	@override String switched({required Object site}) => 'Переключено на ${site}. Приложение обновлено.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigRu extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сохранённые фильтры';
	@override String get empty => 'Сохранённых фильтров пока нет';
	@override String get saveTooltip => 'Сохранить текущий фильтр';
	@override String get namePromptTitle => 'Сохранить фильтр';
	@override String get nameLabel => 'Название';
	@override String get nameHint => 'Введите название';
	@override String get saveSuccess => 'Фильтр сохранён';
	@override String get deleteSuccess => 'Фильтр удалён';
	@override String get addCurrent => 'Сохранить текущий фильтр';
	@override String get reorderHint => 'Нажмите и удерживайте, затем перетащите для изменения порядка';
	@override String get rename => 'Переименовать';
	@override String get unnamed => 'Без названия';
	@override String get noConditions => 'Весь контент (без фильтра)';
	@override String tagsCount({required Object count}) => 'Тегов: ${count}';
}

// Path: savedSearch
class _TranslationsSavedSearchRu extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сохранённые поиски';
	@override String get empty => 'Сохранённых поисков пока нет';
	@override String get saveTooltip => 'Сохранить текущий поиск';
	@override String get namePromptTitle => 'Сохранить поиск';
	@override String get nameLabel => 'Название';
	@override String get nameHint => 'Введите название';
	@override String get saveSuccess => 'Поиск сохранён';
	@override String get deleteSuccess => 'Поиск удалён';
	@override String get addCurrent => 'Сохранить текущий поиск';
	@override String get reorderHint => 'Нажмите и удерживайте, затем перетащите для изменения порядка';
	@override String get rename => 'Переименовать';
	@override String get noKeyword => '(Без ключевого слова)';
	@override String filtersCount({required Object count}) => 'Фильтров: ${count}';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderRu extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Обнаружен чёрный список тегов по умолчанию';
	@override String get content => 'В вашем аккаунте всё ещё используется чёрный список тегов, который сайт автоматически применяет ко всем новым аккаунтам. Хотите просмотреть и настроить его?';
	@override String get goManage => 'Управлять';
	@override String get dismiss => 'Не сейчас';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistRu extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Помощь цветовосприятию';
	@override String get description => 'Корректирует цвета видео для пользователей с нарушениями цветовосприятия; можно использовать вместе с Anime4K';
	@override String get galleryDescription => 'Корректирует цвета изображений в галерее для пользователей с нарушениями цветовосприятия (независимо от переключателя плеера)';
	@override String get galleryDescriptionSpatial => 'Корректирует цвета изображений в галерее для пользователей с нарушениями цветовосприятия. Применяется только к 2D-просмотрщику в этой панели — изображения на пространственном экране отображаются нативно и не проходят через этот фильтр';
	@override String get disable => 'Выкл.';
	@override String get disableDescription => 'Без коррекции цвета';
	@override String get protanopia => 'Помощь с красным (протанопия)';
	@override String get protanopiaDescription => 'Для протанопии — сложность различения красного';
	@override String get deuteranopia => 'Помощь с зелёным (дейтеранопия)';
	@override String get deuteranopiaDescription => 'Для дейтеранопии — сложность различения зелёного';
	@override String get tritanopia => 'Помощь с синим (тританопия)';
	@override String get tritanopiaDescription => 'Для тританопии — сложность различения синего и жёлтого';
	@override String appliedToast({required Object filterName}) => 'Применён фильтр ${filterName}, действует сразу';
	@override String get disabledToast => 'Помощь цветовосприятию отключена';
}

// Path: externalPlayer
class _TranslationsExternalPlayerRu extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Открыть в другом приложении';
	@override String get description => 'Передайте текущее видео другому плееру на этом устройстве: например, Skybox или Pigasus на гарнитуре VR либо MX Player и VLC на телефоне';
	@override String get openWithOtherApp => 'Выбрать другое приложение';
	@override String get openWithOtherAppDescription => 'Показать системный выбор и указать плеер для передачи';
	@override String get openWithSystemPlayer => 'Открыть в плеере по умолчанию';
	@override String get openWithSystemPlayerDescription => 'Передать приложению для видео по умолчанию';
	@override String get copyLink => 'Копировать ссылку на видео';
	@override String get copyLinkDescription => 'Для плееров, которые принимают только вставку URL, например Skybox или DeoVR';
	@override String get linkCopied => 'Ссылка на видео скопирована';
	@override String get sourceLocal => 'Локальный файл';
	@override String get sourceOnline => 'Прямая ссылка';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Прямая ссылка · ${quality}';
	@override String get onlineLinkExpiryHint => 'Прямые ссылки истекают, поэтому внешний плеер может остановиться на середине. Надёжный способ — сначала скачать.';
	@override String get vrPlayerHint => 'Если вашего VR-плеера нет в списке выбора, используйте «Копировать ссылку на видео» и вставьте её в этом плеере.';
	@override String get noHandler => 'Ни одно приложение на этом устройстве не может открыть видео';
	@override String handoffFailed({required Object message}) => 'Не удалось передать: ${message}';
	@override String get handoffFailedUnknown => 'Не удалось передать';
	@override String get sourceUnavailable => 'Не удалось получить адрес текущего видео, повторите попытку';
	@override String get localFileMissing => 'Локальный файл больше не существует';
	@override String get handedOff => 'Передано внешнему плееру';
	@override String get desktopSectionTitle => 'Внешние плееры';
	@override String get managePlayers => 'Управление внешними плеерами';
	@override String get managePlayersDescWindows => 'Плееры для PCVR, такие как HereSphere, DeoVR и Whirligig, не являются приложением по умолчанию в системе. Укажите их .exe — и сможете передавать текущее видео прямо из плеера.';
	@override String get managePlayersDescMac => 'Укажите здесь такие плееры, как IINA, VLC или mpv, — и сможете передавать текущее видео прямо из плеера.';
	@override String get managePlayersDescLinux => 'Укажите здесь такие плееры, как mpv, VLC или Celluloid, — и сможете передавать текущее видео прямо из плеера.';
	@override String get pickExecutableHintWindows => 'Выберите основной файл .exe в папке установки плеера, например HereSphere.exe или vlc.exe. Ярлыки на рабочем столе (.lnk) не подойдут.';
	@override String get pickExecutableHintMac => 'Выберите приложение .app плеера в папке «Программы», например IINA.app, — настоящий исполняемый файл внутри будет найден автоматически.';
	@override String get pickExecutableHintLinux => 'Выберите исполняемый файл плеера, например /usr/bin/mpv. Команда which mpv покажет, где он находится.';
	@override String emptyStateGuide({required Object examples}) => 'После настройки он появится отдельным пунктом в разделе «Открыть в другом приложении» на странице плеера. Частые варианты: ${examples}';
	@override String get detectNothingFoundGuide => 'Установленные плееры не найдены. Пользовательские папки установки и портативные сборки не определяются — используйте «Добавить плеер», чтобы указать его вручную.';
	@override String get detectNothingNew => 'Новые плееры не найдены; всё установленное уже есть в списке';
	@override String get detectFailed => 'Не удалось выполнить поиск — используйте «Добавить плеер», чтобы указать его вручную';
	@override String get advancedOptions => 'Дополнительно';
	@override String get playerNameHint => 'Оставьте пустым, чтобы использовать имя файла';
	@override String get executablePathRequired => 'Сначала выберите исполняемый файл плеера';
	@override String playerCount({required Object count}) => 'Настроено: ${count}';
	@override String get noPlayerConfigured => 'Внешний плеер ещё не настроен';
	@override String get autoDetect => 'Автоопределение';
	@override String get detecting => 'Поиск…';
	@override String detectFound({required Object count}) => 'Найдено плееров: ${count}';
	@override String get detectNothingFound => 'Новые плееры не найдены, добавьте вручную';
	@override String get autoDetectedTag => 'обнаружен';
	@override String get addPlayer => 'Добавить плеер';
	@override String get editPlayer => 'Изменить плеер';
	@override String get playerName => 'Название';
	@override String get executablePath => 'Исполняемый файл';
	@override String get browse => 'Обзор';
	@override String get argumentTemplate => 'Аргументы запуска';
	@override String get argumentTemplateHint => 'Используйте {input} для пути к видео или URL. Оставьте пустым, чтобы передать его единственным аргументом.';
	@override String get nameAndPathRequired => 'Необходимо указать и название, и исполняемый файл';
	@override String get testLaunch => 'Пробный запуск';
	@override String get testLaunched => 'Плеер запущен';
	@override String get testFailed => 'Не удалось запустить, проверьте путь к исполняемому файлу';
	@override String get executableMissing => 'Исполняемый файл не найден';
	@override String openWithNamed({required Object name}) => 'Открыть в ${name}';
	@override String get managePlayersEntry => 'Управление внешними плеерами…';
}

// Path: watchLater
class _TranslationsWatchLaterRu extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Посмотреть позже';
	@override String get addToWatchLater => 'Посмотреть позже';
	@override String get removeFromWatchLater => 'Убрать из «Посмотреть позже»';
	@override String get addedToWatchLater => 'Добавлено в «Посмотреть позже»';
	@override String get alreadyInWatchLater => 'Уже в «Посмотреть позже»';
	@override String get removedFromWatchLater => 'Убрано из «Посмотреть позже»';
	@override String removedCount({required Object count}) => 'Удалено элементов: ${count}';
	@override String get viewWatchLaterList => 'Открыть список';
	@override String get addFailed => 'Не удалось добавить в «Посмотреть позже»';
	@override String get invalidItem => 'Недоступно';
	@override String get clearWatched => 'Очистить просмотренное';
	@override String watchedCleared({required Object count}) => 'Очищено просмотренных элементов: ${count}';
	@override String get noWatchedToClear => 'Нет просмотренного для очистки';
	@override String get emptyVideo => 'В «Посмотреть позже» пока нет видео';
	@override String get emptyGallery => 'В «Посмотреть позже» пока нет галерей';
	@override String get filterAll => 'Все';
	@override String get filterUnwatched => 'Непросмотренные';
	@override String get sortRecentlyAdded => 'Недавно добавленные';
	@override String get sortEarliestAdded => 'Добавленные раньше всех';
	@override String get watched => 'Просмотрено';
	@override String get playlistLoadFailed => 'Не удалось загрузить плейлисты';
	@override String get noPlaylists => 'Плейлистов пока нет';
	@override String get undo => 'Отменить';
	@override String get clearWatchedConfirm => 'Очистить всё просмотренное на этой вкладке? Это действие нельзя отменить.';
	@override String get emptyUnwatchedVideo => 'Здесь больше нечего смотреть';
	@override String get emptyUnwatchedGallery => 'Здесь больше нечего смотреть';
	@override String get queueLoadFailed => 'Не удалось загрузить, нажмите для повтора';
}

// Path: mediaMenu
class _TranslationsMediaMenuRu extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get like => 'Нравится';
	@override String get unlike => 'Убрать отметку «Нравится»';
	@override String get viewAuthor => 'Открыть автора';
	@override String inFolders({required Object count}) => 'Папок: ${count}';
	@override String inPlaylists({required Object count}) => 'Плейлистов: ${count}';
	@override String get downloaded => 'Скачано';
}

// Path: mediaPreview
class _TranslationsMediaPreviewRu extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Просмотр';
	@override String get openDetail => 'Открыть';
	@override String get moreActions => 'Дополнительные действия';
	@override String get previousImage => 'Предыдущее изображение';
	@override String get nextImage => 'Следующее изображение';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueRu extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => 'Изображений: ${count}';
	@override String get upNext => 'Далее';
	@override String get sourceTab => 'Источник';
	@override String get emptyQueue => 'В этой очереди нет ничего для воспроизведения';
	@override String get emptyGalleryQueue => 'В этой очереди нет галерей';
	@override String get nowPlaying => 'Сейчас играет';
	@override String get myPlaylists => 'Мои плейлисты';
	@override String get authorPlaylists => 'Плейлисты автора';
	@override String get openQueue => 'Далее';
	@override String get continueInQueue => 'Продолжать воспроизведение из текущей очереди';
	@override String get continueInQueueSubtitle => 'Автоматически воспроизводит следующий элемент; отключает «повтор по завершении»';
	@override String get repeatDisabledByQueue => 'Отключено, пока включено «продолжать воспроизведение из текущей очереди»';
	@override String get playNext => 'Играть следующим';
	@override String get queueEnded => 'Это последний элемент в очереди';
	@override String get playNextHint => 'Нажмите, чтобы воспроизвести следующий элемент; нажмите и удерживайте, чтобы открыть «Далее»';
	@override String get authorVideos => 'Видео автора';
	@override String get authorGalleries => 'Галереи автора';
	@override String get favoriteFolders => 'Избранные папки';
	@override String get localFiles => 'На этом устройстве';
	@override String get currentFolder => 'Папка этого файла';
	@override String get playThisFolder => 'Очередь видео этой папки';
	@override String get browseThisFolder => 'Очередь галерей этой папки';
	@override String get downloads => 'Скачанное';
	@override String get otherPlaylists => 'Плейлисты других пользователей';
	@override String get nothingHere => 'Здесь ничего нет';
}

// Path: vrFormat
class _TranslationsVrFormatRu extends TranslationsVrFormatEn {
	_TranslationsVrFormatRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Воспроизвести в пространственном плеере';
	@override String get handingOff => 'Передача в пространство…';
	@override String get title => 'Режим воспроизведения';
	@override String get spatialSectionTitle => 'Пространственное воспроизведение';
	@override String get spatialSectionDesc => 'На гарнитуре видео не отображается внутри этой панели — пространственный плеер выводит его на экран в комнате.';
	@override String get spatialPanelEntry => 'Пространственная панель управления';
	@override String get spatialPanelEntryDesc => 'Расстояние до экрана, размер и кривизна, фоновое окружение, а также скорость, повтор и автоскрытие — всё это находится в пространственной панели управления.';
	@override String get spatialGuideEntry => 'Руководство по управлению гарнитурой';
	@override String get spatialGuideEntryDesc => 'Кнопки контроллера, захват экрана, перемотка стиком и перелистывание страниц';
	@override String get spatialFlatOmitted => 'Сенсорные жесты, улучшение изображения и параметры аудио/видео применяются только к 2D-плееру; пространственный плеер работает на другом движке, поэтому здесь они не перечислены.';
	@override String get spatialGallerySectionTitle => 'Пространственная галерея';
	@override String get spatialGalleryPanelDesc => 'Интервал слайд-шоу, повтор одного клипа и кривизна экрана настраиваются в пространственной панели управления.';
	@override String get autoEnterGallery => 'Открывать изображения галереи в пространственной галерее';
	@override String get autoEnterGalleryDesc => 'На Quest нажатие на изображение открывает всю галерею на плавающем экране с лентой миниатюр, слайд-шоу и перелистыванием контроллером вместо просмотрщика внутри этой панели.';
	@override String get panelSettings => 'Панель и фон';
	@override String get panelSettingsDesc => 'На каком расстоянии находится панель приложения и насколько видна ваша комната позади неё';
	@override String get panelDistance => 'Расстояние до панели';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Сбросить размещение';
	@override String get panelResetBackground => 'Сбросить к значению по умолчанию';
	@override String get panelBackground => 'Прозрачность фона';
	@override String get panelBackgroundHint => '0%: чёрное окружение · 100%: ваша реальная комната с общим освещением';
	@override String get panelUnavailable => 'Панель сейчас не размещена — повторите попытку через мгновение';
	@override String get desc => 'Выберите геометрию, с которой должно воспроизводиться это видео. Сайт не предоставляет эту информацию, поэтому автоопределение лишь задаёт отправную точку — решает ваш выбор.';
	@override String get sectionFlat => 'Плоское';
	@override String get sectionStereo => 'Плоское 3D';
	@override String get sectionPanorama => 'VR-панорама';
	@override String get flat => 'Обычное видео';
	@override String get flatDesc => 'Воспроизводить как есть, без перепроецирования';
	@override String get flatSideBySide => 'Стерео 3D (side-by-side)';
	@override String get flatSideBySideDesc => 'По одному глазу на половину, слева и справа; показывает левый глаз и восстанавливает его соотношение сторон';
	@override String get flatTopBottom => 'Стерео 3D (over-under)';
	@override String get flatTopBottomDesc => 'По одному глазу на половину, сверху и снизу; показывает верхнюю половину и восстанавливает её соотношение сторон';
	@override String get vr180SideBySide => 'VR180 стерео (side-by-side)';
	@override String get vr180SideBySideDesc => 'Полусферическая панорама с двумя глазами — самый распространённый VR-источник';
	@override String get vr180Mono => 'VR180 моно';
	@override String get vr180MonoDesc => 'Полусферическая панорама, один глаз на кадр';
	@override String get vr360Mono => 'VR360 моно';
	@override String get vr360MonoDesc => 'Полноценная круговая панорама, один глаз на кадр';
	@override String get vr360TopBottom => 'VR360 стерео (over-under)';
	@override String get vr360TopBottomDesc => 'Полноценная круговая панорама с двумя расположенными друг над другом глазами';
	@override String get resetView => 'Сбросить вид';
	@override String get resetViewDesc => 'Вернуть направление взгляда и угол обзора к фронтальному положению';
	@override String get resetToAuto => 'Вернуть к автоопределению';
	@override String get resetToAutoDesc => 'Забыть ручной выбор для этого видео и снова доверить решение автоопределению';
	@override String get manualBadge => 'Задано вручную';
	@override String get panoramaHint => 'Перетаскивайте изображение, чтобы осмотреться, сведите пальцы, чтобы изменить угол обзора';
	@override String get panoramaGestureNotice => 'При осмотре перетаскивание поворачивает вид — для перемотки используйте полосу прогресса';
	@override String get shaderUnsupported => 'Это устройство не может отображать живую панораму; вместо этого показывается один глаз';
	@override String get handoffTooltip => 'Другой способ воспроизведения';
	@override String get suggestedBadge => 'Рекомендуется';
	@override String suggestedEntryDesc({required Object format}) => 'Похоже на ${format} — нажмите, чтобы переключить';
	@override String suggestionTitle({required Object format}) => 'Возможно, это VR-видео (${format})';
	@override String get suggestionTitleShort => 'Возможно, это VR-видео';
	@override String get suggestionAction => 'Воспроизвести как VR';
	@override String get suggestionDismiss => 'Закрыть';
}

// Path: localMedia
class _TranslationsLocalMediaRu extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseRu browse = _TranslationsLocalMediaBrowseRu._(_root);
	@override String get tabFolders => 'Папки';
	@override String get tabFavoriteVideos => 'Избранное';
	@override String get tabAllVideos => 'Все видео';
	@override String get tabAllImages => 'Все изображения';
	@override String get tabDownloadedVideos => 'Скачанные видео';
	@override String get tabDownloadedGalleries => 'Скачанные галереи';
	@override String get title => 'На этом устройстве';
	@override String get sourceOnline => 'Iwara онлайн';
	@override String get manageSources => 'Управление источниками';
	@override String get moveToCategory => 'Переместить в категорию';
	@override String get manageCategories => 'Управление категориями';
	@override String get suggestedFolders => 'Папки с видео';
	@override String get sortRecentlyAdded => 'Недавно добавленные';
	@override String get sortRecentlyPlayed => 'Недавно просмотренные';
	@override String get sortName => 'Название';
	@override String get sortDuration => 'Длительность';
	@override String get sortSize => 'Размер';
	@override String get sortFolder => 'Папка';
	@override String get sortRecentlyModified => 'Недавно изменённые';
	@override String get sortCount => 'Количество';
	@override String folderCardItemCount({required Object count}) => 'Изображений: ${count}';
	@override String get downloadsSource => 'Скачанное';
	@override String get builtInSourceHint => 'Раздел «Скачанное» управляется автоматически';
	@override String get filterByCategory => 'Фильтр по категории';
	@override String get longPressToCategorize => 'Нажмите и удерживайте, чтобы переместить в категорию';
	@override String get uncategorized => 'Без категории';
	@override String get setCategoryFailed => 'Не удалось задать категорию';
	@override String get categoryUpdated => 'Категория обновлена';
	@override String get addFolder => 'Добавить папку';
	@override String get addDeviceVideos => 'Сканировать видео на устройстве';
	@override String get mediaStoreSourceName => 'Видео устройства';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsRu itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsRu._(_root);
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
	@override late final _TranslationsLocalMediaMissingRu missing = _TranslationsLocalMediaMissingRu._(_root);
	@override late final _TranslationsLocalMediaWebdavRu webdav = _TranslationsLocalMediaWebdavRu._(_root);
	@override String get mediaStoreUnavailable => 'Индекс медиафайлов устройства доступен только на Android';
	@override String get mediaStorePermissionDenied => 'Доступ к видео не предоставлен';
	@override String get rescan => 'Пересканировать';
	@override String scanning({required Object count}) => 'Сканирование… найдено ${count}';
	@override String scanFailed({required Object reason}) => 'Ошибка сканирования: ${reason}';
	@override String scanTruncated({required Object count}) => 'Эта папка очень большая — добавлены только первые ${count} файлов.';
	@override String sourceOverlaps({required Object name}) => 'Уже охвачено папкой «${name}»';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '«${name}» находится внутри «${source}», поэтому добавлено в закреплённые папки';
	@override String alreadyPinnedFolder({required Object name}) => '«${name}» уже в закреплённых папках';
	@override String sourceAlreadyAdded({required Object name}) => '«${name}» уже добавлено';
	@override String sourceContainsExisting({required Object name}) => 'Он уже содержит добавленную папку «${name}»; добавление её родительской папки пока не поддерживается';
	@override String get addSourceFailed => 'Не удалось добавить эту папку';
	@override String get fileMissing => 'Этот файл больше не находится на диске';
	@override String get permissionDenied => 'Доступ к файлам не предоставлен · нажмите, чтобы предоставить';
	@override String get noVideosFound => 'В этой папке нет видео';
	@override String get emptyTitle => 'Добавьте папку, чтобы просматривать видео, уже имеющиеся на этом устройстве';
	@override String get emptyPrivacyNote => 'Файлы читаются только на этом устройстве. Ничего не загружается.';
	@override String removeSourceTitle({required Object name}) => 'Удалить «${name}»?';
	@override String get removeSourceBody => 'Файлы остаются на диске. Удаляется только эта запись в библиотеке.';
	@override String get remove => 'Удалить';
	@override String get removeFolder => 'Удалить папку';
	@override String get removeFolderSelectTitle => 'Выберите папку для удаления';
	@override String get longPressToRemove => 'Нажмите и удерживайте, чтобы удалить эту папку';
	@override String get clearProgress => 'Очистить локальную историю просмотров';
	@override String clearProgressCount({required Object count}) => 'Записей: ${count}';
	@override String get clearProgressEmpty => 'Локальной истории просмотров пока нет';
	@override String get clearProgressTitle => 'Очистить локальную историю просмотров?';
	@override String get clearProgressBody => 'Удаляются только позиции воспроизведения и отметки о просмотре. Ваши файлы и папки остаются без изменений.';
	@override String clearProgressDone({required Object count}) => 'Очищено записей локальной истории просмотров: ${count}';
	@override String get clearAction => 'Очистить';
	@override String get iosManualRescanNotice => 'iOS не обнаруживает новые файлы автоматически. После добавления или удаления файлов потребуется вручную запустить повторное сканирование.';
}

// Path: historyPage
class _TranslationsHistoryPageRu extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Удалить из истории';
	@override String get removed => 'Удалено из истории';
	@override String watchedTo({required Object time}) => 'Просмотрено до ${time}';
	@override String get finished => 'Просмотрено';
	@override String clearTabTitle({required Object tab}) => 'Очистить «${tab}»';
	@override String clearTabConfirm({required Object tab}) => 'Вся история в «${tab}» будет удалена вместе с прогрессом просмотра этих видео. Действие необратимо.';
	@override String get rangeByLastViewed => 'По времени последнего просмотра';
}

// Path: ai
class _TranslationsAiRu extends TranslationsAiEn {
	_TranslationsAiRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'ИИ';
	@override String get providers => 'Провайдеры';
	@override String get providersHint => 'Добавьте одного или нескольких провайдеров ИИ и назначьте их для нужных функций.';
	@override String get addProvider => 'Добавить провайдера';
	@override String get noProviders => 'Провайдеры пока не добавлены. Добавьте хотя бы одного, чтобы включить перевод, поиск и подпись с помощью ИИ.';
	@override String get pickPreset => 'Выбрать провайдера';
	@override String get providerNameLabel => 'Название';
	@override String get apiKey => 'API-ключ';
	@override String get baseUrl => 'Конечная точка';
	@override String get model => 'Модель';
	@override String get modelPick => 'Выбрать модель';
	@override String get modelEmpty => 'Не удалось загрузить список моделей — можно также ввести название модели вручную.';
	@override String get advanced => 'Расширенные';
	@override String get reasoning => 'Модель рассуждений';
	@override String get streaming => 'Потоковый вывод';
	@override String get structuredOutput => 'Структурированный вывод';
	@override String get structuredOutputHint => 'Требуется для поиска с ИИ. Многие сторонние прокси-эндпоинты не поддерживают эту функцию — отключите её, если поиск постоянно завершается ошибкой.';
	@override String get temperature => 'Температура';
	@override String get maxTokens => 'Макс. количество токенов';
	@override String get maxTokensAuto => 'Авто (лимит модели)';
	@override String get test => 'Проверить';
	@override String get testOk => 'Подключение успешно';
	@override String get deleteProvider => 'Удалить провайдера';
	@override String get usedBy => 'Используется в';
	@override String get taskBindings => 'Назначение функций';
	@override String get taskBindingsHint => 'Для каждой функции можно выбрать отдельного провайдера.';
	@override String get taskTranslate => 'Перевод';
	@override String get taskSearch => 'Поиск с ИИ';
	@override String get taskSignature => 'Подпись';
	@override String get taskAuto => 'Автоматически';
	@override String get usage => 'Использование';
	@override String get usageCalls => 'Вызовы';
	@override String get usageTokens => 'Токены';
	@override String get usageFailures => 'Ошибки';
	@override String get usageReset => 'Сбросить статистику';
	@override String get usageEmpty => 'Вызовов пока не было';
	@override String get openSettings => 'Открыть настройки ИИ';
	@override String get notConfigured => 'Не настроено';
	@override String get searchTitle => 'Поиск с ИИ';
	@override String get searchHint => 'Опишите, что вы ищете, и ИИ сам заполнит поисковые запросы и фильтры.';
	@override String get searchPlaceholder => 'Например: недавние MMD с более 10 тыс. просмотров';
	@override String get searchApply => 'Искать по этим условиям';
	@override String get searchEmpty => 'Не удалось сформировать поисковый запрос. Попробуйте описать иначе.';
	@override String get searchFilters => 'Фильтры';
	@override String searchSwitchSegment({required Object segment}) => 'Переключить на ${segment}';
	@override String get searchGenerating => 'Обработка…';
	@override String get searchRetrying => 'Предыдущая попытка не удалась, повтор…';
	@override String searchRetryReason({required Object reason}) => 'Причина: ${reason}';
	@override String get searchStageWaiting => 'Запрос отправлен, ждём ответа…';
	@override String get searchStageThinkingNext => 'Обдумывает следующий шаг…';
	@override String get searchStageReasoning => 'Рассуждает…';
	@override String get searchStageTool => 'Пробный поиск…';
	@override String searchStageDrafting({required Object chars}) => 'Пишет ответ · ${chars} симв.';
	@override String get searchStageParsing => 'Разбираем результат…';
	@override String get searchThinking => 'Ход рассуждений';
	@override String get searchKeywordNeedsQuotes => 'Запрос не взят в кавычки, поэтому Iwara сопоставляет его нестрого — при такой сортировке первая страница будет в основном нерелевантной. Возьмите его в "кавычки" или сортируйте по релевантности.';
	@override String searchToolProbing({required Object query}) => 'Пробую ${query}';
	@override String searchToolFound({required Object count, required Object titles}) => 'Результатов: ${count} · ${titles}';
	@override String searchToolFailed({required Object reason}) => 'Не удалось: ${reason}';
	@override String searchToolFilterCount({required Object count}) => 'Фильтров: ${count}';
	@override String searchToolExpanded({required Object tags}) => 'дополнено тегами ${tags}';
	@override String searchToolLookupTags({required Object terms}) => 'Поиск тегов ${terms}';
	@override String get searchToolTagMissing => 'не тег';
	@override String searchToolFindUser({required Object name}) => 'Поиск автора ${name}';
	@override String searchToolUsersFound({required Object count, required Object users}) => 'Пользователей: ${count} · ${users}';
	@override String get searchPlanTitle => 'План поиска';
	@override String searchPlanEstimate({required Object count}) => 'Около ${count}';
	@override String searchToolCount({required Object count}) => 'Запросов: ${count}';
	@override String get searchWillExpandTags => 'Также ищет по этим тегам';
	@override String get searchTraceReasoning => 'Рассуждение';
	@override String searchFiltersDropped({required Object count}) => 'Удалено фильтров, которых нет в этом разделе: ${count}.';
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
class _TranslationsCommonPaginationRu extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Всего: ${num}';
	@override String get jumpToPage => 'Перейти на страницу';
	@override String pleaseEnterPageNumber({required Object max}) => 'Введите номер страницы (1-${max})';
	@override String get pageNumber => 'Номер страницы';
	@override String get jump => 'Перейти';
	@override String invalidPageNumber({required Object max}) => 'Введите корректный номер страницы (1-${max})';
	@override String get invalidInput => 'Введите корректный номер страницы';
	@override String get waterfall => 'Лента';
	@override String get pagination => 'Страницы';
}

// Path: errors.network
class _TranslationsErrorsNetworkRu extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Ошибка сети — ';
	@override String get failedToConnectToServer => 'Не удалось подключиться к серверу';
	@override String get serverNotAvailable => 'Сервер недоступен';
	@override String get requestTimeout => 'Время ожидания запроса истекло';
	@override String get unexpectedError => 'Непредвиденная ошибка';
	@override String get invalidResponse => 'Некорректный ответ';
	@override String get invalidRequest => 'Некорректный запрос';
	@override String get invalidUrl => 'Некорректный URL';
	@override String get invalidMethod => 'Недопустимый метод';
	@override String get invalidHeader => 'Недопустимый заголовок';
	@override String get invalidBody => 'Недопустимое тело запроса';
	@override String get invalidStatusCode => 'Недопустимый код состояния';
	@override String get serverError => 'Ошибка сервера';
	@override String get requestCanceled => 'Запрос отменен';
	@override String get invalidPort => 'Недопустимый порт';
	@override String get proxyPortError => 'Ошибка порта прокси';
	@override String get connectionRefused => 'В соединении отказано';
	@override String get networkUnreachable => 'Сеть недоступна';
	@override String get noRouteToHost => 'Нет маршрута к хосту';
	@override String get connectionFailed => 'Сбой подключения';
	@override String get sslConnectionFailed => 'Сбой SSL-соединения, проверьте настройки сети';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingRu extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Горячие клавиши';
	@override String get entryLabel => 'Горячие клавиши';
	@override String get entryDesc => 'Настройка сочетаний клавиш (в основном для ПК)';
	@override String get desktopHint => 'Сочетания клавиш работают на клавиатуре ПК; на мобильных используются жесты.';
	@override String get resetAll => 'Сбросить все по умолчанию';
	@override String get resetAllConfirm => 'Сбросить все горячие клавиши к значениям по умолчанию?';
	@override String get resetToDefault => 'По умолчанию';
	@override String get resetScope => 'Сбросить этот раздел';
	@override String get notSet => 'Не назначено';
	@override String get addShortcut => 'Добавить клавишу';
	@override String get removeShortcut => 'Удалить это сочетание';
	@override String get pressNewShortcut => 'Нажмите новую клавишу…';
	@override String get recordingCancelHint => 'Нажмите Esc для отмены';
	@override String get mouseHint => 'Можно использовать боковые кнопки мыши (назад / вперед) или колесико';
	@override String get mouseNotSupportedInScope => 'В этой области кнопки мыши не поддерживаются, используйте клавиатуру';
	@override String get capabilityKeyboardOnly => 'Только клавиши клавиатуры';
	@override String get capabilityKeyboardAndMouse => 'Клавиатура, а также средняя и боковые кнопки мыши';
	@override String get capabilityKeyboardAndMouseMobile => 'Клавиатура, средняя и кнопка «вперед» мыши (кнопка «назад» занята системой)';
	@override String get rejectMultipleButtons => 'Нажимайте по одной кнопке мыши';
	@override String get rejectPlatformBack => 'Эта кнопка уже зарезервирована системой для «Назад»';
	@override String get detectedLabel => 'Обнаружено';
	@override String get reservedKey => 'Эта клавиша зарезервирована системой и не может быть назначена';
	@override String reservedForGlobalBack({required Object action}) => 'Эта клавиша назначена на «${action}» и зарезервирована для выхода из этого экрана';
	@override String get conflictTitle => 'Конфликт клавиш';
	@override String conflictMessage({required Object action}) => 'Это сочетание уже назначено на «${action}». Назначение удалит старую привязку.';
	@override String get conflictContinue => 'Все равно назначить';
	@override String get shadowWarningTitle => 'Перекрытие глобальной клавиши';
	@override String shadowWarningMessage({required Object action}) => 'Это сочетание глобально назначено на «${action}». Назначение здесь переопределит его только в этом разделе.';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'Это сочетание уже назначено на «${action}» в ${scope}. В этом разделе глобальная клавиша будет переопределена.';
	@override String get searchHint => 'Поиск сочетаний…';
	@override String get scopeGlobal => 'Глобальные';
	@override String get scopeGallery => 'Галерея';
	@override String get scopeVideo => 'Видео';
	@override String get categoryNavigation => 'Навигация';
	@override String get categoryZoom => 'Масштабирование';
	@override String get categoryPlayback => 'Воспроизведение';
	@override String get categorySeek => 'Перемотка';
	@override String get categoryVolume => 'Громкость';
	@override String get categoryDisplay => 'Отображение';
	@override String get actionGlobalBack => 'Назад';
	@override String get actionGalleryNext => 'Следующее фото';
	@override String get actionGalleryPrevious => 'Предыдущее фото';
	@override String get actionGalleryZoomIn => 'Приблизить';
	@override String get actionGalleryZoomOut => 'Отдалить';
	@override String get actionGalleryResetZoom => 'Сбросить масштаб';
	@override String get actionGalleryPlayPause => 'Воспроизведение / Пауза';
	@override String get actionGallerySeekBackward => 'Назад';
	@override String get actionGallerySeekForward => 'Вперед';
	@override String get actionGalleryToggleMute => 'Вкл./Выкл. звук';
	@override String get actionPlayPause => 'Воспроизведение / Пауза';
	@override String get actionSpeedUp => 'Увеличить скорость';
	@override String get actionSpeedDown => 'Уменьшить скорость';
	@override String get actionSeekForward => 'Вперед';
	@override String get actionSeekBackward => 'Назад';
	@override String get actionVolumeUp => 'Громче';
	@override String get actionVolumeDown => 'Тише';
	@override String get actionToggleMute => 'Вкл./Выкл. звук';
	@override String get actionToggleFullscreen => 'Полный экран';
	@override String get seekLongPressHint => 'Удерживайте клавишу перемотки для ускорения';
	@override String get zoomSectionTitle => 'Масштаб изображения (фиксировано)';
	@override String get zoomFixedNote => 'Сочетания ниже фиксированы и не могут быть изменены';
	@override String get zoomScaleLabel => 'Масштаб изображения';
	@override String get zoomScaleHint => 'Ctrl + колесико';
	@override String get zoomRotateLabel => 'Поворот изображения';
	@override String get zoomRotateHint => 'Shift + колесико';
	@override String get zoomPinchGesture => 'Сведение пальцев';
	@override String get zoomTwoFingerRotateGesture => 'Поворот двумя пальцами';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsRu extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get name => 'Форум';
	@override String get configureYourForumSettings => 'Настройки форума';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsRu extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Настройки галереи';
	@override String get gallerySettingsSubtitle => 'Параметры просмотра изображений';
	@override String get defaultViewerQuality => 'Качество при открытии';
	@override String get defaultViewerQualityDesc => 'Качество изображений по умолчанию при открытии галереи.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsRu extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Блокировка контента';
	@override String get subtitle => 'Автоматически скрывать видео и галереи по ключевым словам в заголовке или от заблокированных авторов. Фильтрация работает локально на устройстве.';
	@override String get blocked => 'Заблокировано';
	@override String get reveal => 'Показать';
	@override String get reblock => 'Заблокировать снова';
	@override String get why => 'Причина?';
	@override String get manageRules => 'Управление правилами';
	@override String reasonKeyword({required Object value}) => 'Заголовок содержит «${value}»';
	@override String reasonRegex({required Object value}) => 'Заголовок соответствует «${value}»';
	@override String get reasonUser => 'От заблокированного автора';
	@override String get addRule => 'Добавить правило';
	@override String get editRule => 'Изменить правило';
	@override String get deleteRule => 'Удалить правило';
	@override String get ruleType => 'Тип правила';
	@override String get keyword => 'Ключевое слово';
	@override String get regex => 'Регулярное выражение';
	@override String get userId => 'Пользователь';
	@override String get value => 'Текст для совпадения';
	@override String get caseSensitive => 'С учетом регистра';
	@override String get regexHint => 'напр. trailer|teaser';
	@override String get valueRequired => 'Введите текст правила';
	@override String get invalidRegex => 'Некорректное регулярное выражение';
	@override String get noRules => 'Нет правил. Нажмите +, чтобы добавить.';
	@override String get blockUser => 'Заблокировать';
	@override String get unblockUser => 'Разблокировать';
	@override String blockUserConfirm({required Object name}) => 'Заблокировать «${name}»? Публикации автора будут скрыты из списков и поиска.';
	@override String get userBlocked => 'Пользователь заблокирован';
	@override String get userUnblocked => 'Пользователь разблокирован';
	@override String get exportRules => 'Экспорт';
	@override String get importRules => 'Импорт';
	@override String get importExport => 'Импорт / Экспорт';
	@override String get exportSuccess => 'Правила экспортированы';
	@override String get exportFailed => 'Не удалось экспортировать правила';
	@override String importSuccess({required Object count}) => 'Импортировано правил: ${count}';
	@override String get importFailed => 'Не удалось импортировать правила';
	@override String get regexHelp => 'Справка по шаблонам';
	@override String get regexHelpTitle => 'Справка по Regex';
	@override String get regexHelpIntro => 'Регулярные выражения позволяют фильтровать точнее обычных слов. Примеры:';
	@override String get regexHelpTapHint => 'Нажмите на пример, чтобы вставить его.';
	@override String get regexEx1Pattern => 'трейлер|тизер|бонус';
	@override String get regexEx1Desc => 'Любое из этих слов («|» означает «или»)';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Заголовки, начинающиеся с [скобок]';
	@override String get regexEx3Pattern => 'Коллекция\$';
	@override String get regexEx3Desc => 'Заголовки, заканчивающиеся на «Коллекция»';
	@override String get regexEx4Pattern => 'Эп.[0-9]+';
	@override String get regexEx4Desc => '[0-9]+ — одна или более цифр (находит «Эп.12»)';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '\\d — цифра, {4} — четыре подряд (например, год)';
	@override String get regexEx1Sample => 'Тизер новой игры уже вышел';
	@override String get regexEx2Sample => '[Remux] Полный фильм';
	@override String get regexEx3Sample => 'Весенняя коллекция арта';
	@override String get regexEx4Sample => 'Обзор Эп.12 моего шоу';
	@override String get regexEx5Sample => 'Лучшее из 2024 года';
	@override String get regexHelpSampleLabel => 'Пример заголовка';
	@override String get regexHelpMatchedTag => 'Заблокировано';
	@override String get regexHelpNoMatch => 'Нет совпадений';
	@override String get regexEx6Pattern => '[Сс]езон';
	@override String get regexEx6Desc => '[Сс] — заглавная или строчная «С» (находит «Сезон»)';
	@override String get regexEx6Sample => 'Трейлер финального сезона';
	@override String get regexEx7Pattern => '(фильм|сериал)';
	@override String get regexEx7Desc => 'Круглые скобки () группируют варианты: «фильм» или «сериал»';
	@override String get regexEx7Sample => 'Смотрите сериал сейчас';
	@override String get regexEx8Pattern => 'сезон[ыа]?';
	@override String get regexEx8Desc => '«?» делает предыдущий символ необязательным: «сезон» и «сезоны»';
	@override String get regexEx8Sample => 'Набор из двух сезонов';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ означает один или более символов: !, !!, !!! ...';
	@override String get regexEx9Sample => 'Ого!!! Обязательно к просмотру';
	@override String get regexEx10Pattern => 'бонус.*сцен';
	@override String get regexEx10Desc => '«.*» означает любые символы между ними: «бонус … сцен»';
	@override String get regexEx10Sample => 'Удалённая бонусная сцена';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsRu extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get name => 'Чат';
	@override String get configureYourChatSettings => 'Настройки чата';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsRu extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Настройки загрузки';
	@override String get enableDownloadNotifications => 'Уведомления о загрузках';
	@override String get enableDownloadNotificationsDescription => 'Показывать системное уведомление при завершении или ошибке загрузки';
	@override String get notificationPermissionDenied => 'Нет разрешения на уведомления. Внутри приложения они работают; системные можно включить в настройках.';
	@override String get storagePermissionStatus => 'Доступ к памяти';
	@override String get accessPublicDirectoryNeedStoragePermission => 'Для общедоступных папок требуется разрешение на доступ к памяти';
	@override String get checkingPermissionStatus => 'Проверка разрешений...';
	@override String get storagePermissionGranted => 'Доступ к памяти предоставлен';
	@override String get storagePermissionNotGranted => 'Доступ к памяти не предоставлен';
	@override String get storagePermissionGrantSuccess => 'Разрешение успешно предоставлено';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Не удалось предоставить разрешение, некоторые функции могут быть ограничены';
	@override String get storagePermissionRationale => 'Для сохранения в выбранную папку приложению нужен доступ к памяти.\n\nНа Android 11+ требуется «Доступ ко всем файлам»; без него файлы сохраняются в изолированную папку приложения.';
	@override String get storagePermissionRationaleLegacy => 'Для сохранения в выбранную папку приложению нужен доступ к памяти.\n\nБез него файлы сохраняются в изолированную папку приложения.';
	@override String get grantStoragePermission => 'Предоставить доступ';
	@override String get customDownloadPath => 'Пользовательская папка загрузки';
	@override String get customDownloadPathDescription => 'Возможность выбрать свое место для сохранения файлов';
	@override String get customDownloadPathTip => '💡 Совет: Для общедоступных папок (например, Загрузки) нужно разрешение; рекомендуется использовать стандартные пути';
	@override String get androidWarning => 'Примечание для Android: Общедоступные папки (например, Downloads) требуют спецразрешений; лучше использовать папки приложения.';
	@override String get publicDirectoryPermissionTip => '⚠️ Внимание: Выбрана общая папка, требуется доступ к памяти для скачивания файлов';
	@override String get permissionRequiredForPublicDirectory => 'Требуется доступ к памяти для общих папок';
	@override String get currentDownloadPath => 'Текущая папка загрузки';
	@override String get actualDownloadPath => 'Фактический путь';
	@override String get defaultAppDirectory => 'Папка приложения по умолчанию';
	@override String get permissionGranted => 'Предоставлено';
	@override String get permissionRequired => 'Требуется разрешение';
	@override String get enableCustomDownloadPath => 'Свой путь загрузки';
	@override String get disableCustomDownloadPath => 'Использовать путь по умолчанию';
	@override String get customDownloadPathLabel => 'Пользовательский путь';
	@override String get selectDownloadFolder => 'Выбрать папку загрузки';
	@override String get recommendedPath => 'Рекомендуемый путь';
	@override String get selectFolder => 'Выбрать папку';
	@override String get filenameTemplate => 'Шаблон имени файла';
	@override String get filenameTemplateDescription => 'Правило именования скачиваемых файлов с поддержкой переменных';
	@override String get videoFilenameTemplate => 'Шаблон имени видео';
	@override String get galleryFolderTemplate => 'Шаблон папки галереи';
	@override String get imageFilenameTemplate => 'Шаблон имени изображения';
	@override String get resetToDefault => 'По умолчанию';
	@override String get supportedVariables => 'Доступные переменные';
	@override String get supportedVariablesDescription => 'В шаблонах имен можно использовать следующие переменные:';
	@override String get copyVariable => 'Копировать переменную';
	@override String get variableCopied => 'Переменная скопирована';
	@override String get warningPublicDirectory => 'Внимание: Выбранная общая папка может быть недоступна. Рекомендуется выбрать папку приложения.';
	@override String get downloadPathUpdated => 'Путь загрузки обновлен';
	@override String get selectPathFailed => 'Не удалось выбрать путь';
	@override String get pickerAlreadyActive => 'Выбор папки уже открыт';
	@override String get unsupportedStorageVolume => 'Неподдерживаемый накопитель. Выберите папку на внутреннем накопителе или SD-карте.';
	@override String get recommendedPathSet => 'Установлен рекомендуемый путь';
	@override String get setRecommendedPathFailed => 'Не удалось установить рекомендуемый путь';
	@override String get templateResetToDefault => 'Сброшено к шаблону по умолчанию';
	@override String get functionalTest => 'Проверка функций';
	@override String get testInProgress => 'Проверка...';
	@override String get runTest => 'Запустить тест';
	@override String get testDownloadPathAndPermissions => 'Проверка пути загрузки и корректности разрешений';
	@override String get testResults => 'Результаты теста';
	@override String get testCompleted => 'Проверка завершена';
	@override String get testMultisegmentDomain => 'Проверка домена значений (многосегментность / превышение / формы обхода)';
	@override String get testMultisegmentPaths => 'Рендер многосегментной структуры (issue #126)';
	@override String get testPassed => 'успешно';
	@override String get testFailed => 'Тест не пройден';
	@override String get testStoragePermissionCheck => 'Проверка доступа к памяти';
	@override String get testStoragePermissionGranted => 'Доступ к памяти предоставлен';
	@override String get testStoragePermissionMissing => 'Доступ к памяти отсутствует, функции могут быть ограничены';
	@override String get testPermissionCheckFailed => 'Ошибка проверки разрешений';
	@override String get testDownloadPathValidation => 'Проверка пути загрузки';
	@override String get testPathValidationFailed => 'Ошибка проверки пути';
	@override String get testFilenameTemplateValidation => 'Проверка шаблона имени';
	@override String get testAllTemplatesValid => 'Все шаблоны корректны';
	@override String get testSomeTemplatesInvalid => 'В шаблонах есть недопустимые символы';
	@override String get testTemplateValidationFailed => 'Ошибка проверки шаблона';
	@override String get testDirectoryOperationTest => 'Проверка операций с папками';
	@override String get testDirectoryOperationNormal => 'Создание папок и запись файлов работают штатно';
	@override String get testDirectoryOperationFailed => 'Ошибка работы с папкой';
	@override String get testVideoTemplate => 'Шаблон видео';
	@override String get testGalleryTemplate => 'Шаблон галереи';
	@override String get testImageTemplate => 'Шаблон изображения';
	@override String get testValid => 'Корректно';
	@override String get testInvalid => 'Некорректно';
	@override String get testSuccess => 'Успешно';
	@override String get testCorrect => 'Правильно';
	@override String get testError => 'Ошибка';
	@override String get testPath => 'Тестовый путь';
	@override String get testBasePath => 'Базовый путь';
	@override String get testDirectoryCreation => 'Создание папки';
	@override String get testFileWriting => 'Запись файла';
	@override String get testFileContent => 'Содержимое файла';
	@override String get checkingPathStatus => 'Проверка статуса пути...';
	@override String get unableToGetPathStatus => 'Не удалось получить статус пути';
	@override String get actualPathDifferentFromSelected => 'Примечание: Фактический путь отличается от выбранного';
	@override String get grantPermission => 'Предоставить разрешение';
	@override String get fixIssue => 'Исправить';
	@override String get issueFixed => 'Исправлено';
	@override String get fixFailed => 'Не удалось исправить, настройте вручную';
	@override String get lackStoragePermission => 'Нет доступа к памяти';
	@override String get cannotAccessPublicDirectory => 'Нет доступа к общей папке, требуется «Доступ ко всем файлам»';
	@override String get cannotCreateDirectory => 'Не удалось создать папку';
	@override String get directoryNotWritable => 'Папка недоступна для записи';
	@override String get insufficientSpace => 'Недостаточно свободного места';
	@override String get pathValid => 'Путь корректен';
	@override String get validationFailed => 'Проверка не пройдена';
	@override String get usingDefaultAppDirectory => 'Используется папка приложения по умолчанию';
	@override String get appPrivateDirectory => 'Изолированная папка приложения';
	@override String get appPrivateDirectoryDesc => 'Надежно и безопасно, дополнительных разрешений не требуется';
	@override String get downloadDirectory => 'Папка «Загрузки»';
	@override String get downloadDirectoryDesc => 'Системная папка загрузок, удобно для управления';
	@override String get moviesDirectory => 'Папка «Фильмы»';
	@override String get moviesDirectoryDesc => 'Системная папка видео, распознается медиаплеерами';
	@override String get documentsDirectory => 'Папка документов';
	@override String get documentsDirectoryDesc => 'Папка документов iOS';
	@override String get requiresStoragePermission => 'Для доступа требуется разрешение';
	@override String get recommendedPaths => 'Рекомендуемые пути';
	@override String get externalAppPrivateDirectory => 'Внешняя папка приложения';
	@override String get externalAppPrivateDirectoryDesc => 'Папка приложения на внешнем накопителе, доступна пользователю, больше места';
	@override String get internalAppPrivateDirectory => 'Внутренняя папка приложения';
	@override String get internalAppPrivateDirectoryDesc => 'Внутреннее хранилище приложения, без спецразрешений, меньше места';
	@override String get appDocumentsDirectory => 'Папка документов приложения';
	@override String get appDocumentsDirectoryDesc => 'Папка документов приложения, надежно и изолированно';
	@override String get downloadsFolder => 'Папка «Загрузки»';
	@override String get downloadsFolderDesc => 'Стандартная папка загрузок устройства';
	@override String get selectRecommendedDownloadLocation => 'Выберите рекомендуемую папку загрузки';
	@override String get noRecommendedPaths => 'Нет рекомендуемых путей';
	@override String get recommended => 'Рекомендуется';
	@override String get requiresPermission => 'Требуется разрешение';
	@override String get authorizeAndSelect => 'Разрешить и выбрать';
	@override String get select => 'Выбрать';
	@override String get permissionAuthorizationFailed => 'Не удалось получить разрешение, выбор пути невозможен';
	@override String get pathValidationFailed => 'Путь не прошел проверку';
	@override String get downloadPathSetTo => 'Путь загрузки установлен в';
	@override String get setPathFailed => 'Не удалось установить путь';
	@override String get variableTitle => 'Название';
	@override String get variableAuthorcache => 'Первое имя автора (стабильно при смене никнейма)';
	@override String get variableAuthor => 'Имя автора';
	@override String get variableUsername => 'Имя пользователя автора';
	@override String get variableQuality => 'Качество видео';
	@override String get variableFilename => 'Исходное имя файла';
	@override String get variableId => 'ID контента';
	@override String get variableCount => 'Количество изображений в галерее';
	@override String get variableDate => 'Текущая дата (ГГГГ-ММ-ДД)';
	@override String get variableTime => 'Текущее время (ЧЧ-ММ-СС)';
	@override String get variableDatetime => 'Дата и время (ГГГГ-ММ-ДД_ЧЧ-ММ-СС)';
	@override String get downloadSettingsTitle => 'Настройки загрузки';
	@override String get downloadSettingsSubtitle => 'Папка сохранения и правила именования файлов';
	@override String get suchAsTitleQuality => 'Например: %title_%quality';
	@override String get suchAsTitleId => 'Например: %title_%id';
	@override String get suchAsTitleFilename => 'Например: %title_%filename';
	@override String get structureSection => 'Структура сохранения и имена';
	@override String get structureSectionDescription => 'Скачанные файлы раскладываются по подпапкам согласно выбранной ниже схеме. Касается только новых загрузок; существующие файлы не трогаются.';
	@override String get structureNoticeTitle => 'Новое: автораскладка по авторам';
	@override String get structureNoticeBody => 'Выберите ниже · касается только новых загрузок, существующие файлы остаются на месте.';
	@override String get presetFlat => 'Плоско';
	@override String get presetFlatDesc => 'Все файлы лежат прямо в корневой папке загрузок';
	@override String get presetAuthor => 'По авторам';
	@override String get presetAuthorBadge => 'Рекомендуется';
	@override String get presetAuthorDesc => 'Папка на автора · переименование не разбивает архив';
	@override String get presetDate => 'По датам';
	@override String get presetDateDesc => 'Группировка по дате загрузки';
	@override String get presetCustomActive => 'Активно';
	@override String get structurePreviewLabel => 'Предпросмотр';
	@override String get structurePreviewNote => 'Цветные сегменты — уровни структуры, меняются вместе со схемой.';
	@override String get pathTooLongWarning => 'Относительный путь длиннее 200 символов — на части устройств сохранение может не удаться';
	@override String get pathTemplateEditorEntry => 'Свой шаблон пути';
	@override String get pathTemplateEditorEntryDesc => 'Самому решить, как делить папки и называть файлы';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorRu pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorRu._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesRu extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Популярные';
	@override String get favorites => 'В избранном';
	@override String get latest => 'Новые';
	@override String get popularity => 'Рейтинг';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsRu extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Ошибка запроса, код состояния';
	@override String get connectionTimeout => 'Время ожидания подключения истекло, проверьте сеть';
	@override String get sendTimeout => 'Время отправки запроса истекло';
	@override String get receiveTimeout => 'Время получения ответа истекло';
	@override String get badCertificate => 'Ошибка проверки сертификата';
	@override String get resourceNotFound => 'Запрошенный ресурс не найден';
	@override String get accessDenied => 'Доступ запрещен';
	@override String get serverError => 'Внутренняя ошибка сервера';
	@override String get serviceUnavailable => 'Сервис временно недоступен';
	@override String get requestCancelled => 'Запрос отменен';
	@override String get connectionError => 'Ошибка сетевого соединения, проверьте настройки сети';
	@override String get networkRequestFailed => 'Сбой сетевого запроса';
	@override String get searchVideoError => 'Ошибка поиска видео';
	@override String get getPopularVideoError => 'Ошибка загрузки популярных видео';
	@override String get getVideoDetailError => 'Ошибка получения сведений о видео';
	@override String get parseVideoDetailError => 'Ошибка обработки данных видео';
	@override String get downloadFileError => 'Ошибка скачивания файла';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingRu extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Получение информации о видео...';
	@override String get cancel => 'Отмена';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesRu extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Видео не найдено или удалено';
	@override String get unableToGetVideoPlayLink => 'Не удалось получить ссылку на видео';
	@override String get getVideoDetailFailed => 'Не удалось получить сведения о видео';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoRu extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Информация о видео';
	@override String get currentQuality => 'Текущее качество';
	@override String get duration => 'Длительность';
	@override String get resolution => 'Разрешение';
	@override String get fileInfo => 'О файле';
	@override String get fileName => 'Имя файла';
	@override String get fileSize => 'Размер файла';
	@override String get filePath => 'Путь к файлу';
	@override String get copyPath => 'Копировать путь';
	@override String get openFolder => 'Открыть папку';
	@override String get pathCopiedToClipboard => 'Путь скопирован в буфер';
	@override String get openFolderFailed => 'Не удалось открыть папку';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideRu extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Пример видео';
	@override String get title => 'Руководство по жестам';
	@override String get viewGuide => 'Жесты и управление';
	@override String get firstTimeIntro => 'Ознакомьтесь с жестами управления плеером. Вы всегда можете вернуться к этой справке в настройках плеера.';
	@override String get startWatching => 'Понятно, перейти к просмотру';
	@override String get basicTitle => 'Основное управление';
	@override String get zoomTitle => 'Зум / Поворот / Смещение';
	@override String get restoreTip => 'Нажмите «Сбросить» в правом нижнем углу для сброса масштаба, поворота и позиции.';
	@override String get mTap => 'Одиночное касание: показать/скрыть элементы управления';
	@override String get mDoubleTap => 'Двойное касание: назад (слева) / пауза (по центру) / вперед (справа)';
	@override String get mHorizontalDrag => 'Горизонтальное смахивание: перемотка';
	@override String get mVerticalDrag => 'Вертикальное смахивание: яркость (слева) / громкость (справа)';
	@override String get mLongPress => 'Долгое нажатие: ускорение';
	@override String get mPinch => 'Два пальца (щипок): масштаб кадра';
	@override String get mRotate => 'Два пальца (поворот): поворот кадра';
	@override String get dTap => 'Клик: показать/скрыть элементы управления';
	@override String get dDoubleTap => 'Двойной клик: назад (слева) / пауза (по центру) / вперед (справа)';
	@override String get dKeys => 'Стрелки перемотки: нажатие — шаг назад/вперед, удержание — ускорение; клавиши скорости: изменение скорости; Пробел: пауза/пуск';
	@override String get dTrackpadPinch => 'Жест трекпада: масштаб';
	@override String get dTrackpadRotate => 'Жест трекпада: поворот';
	@override String get dCtrlWheel => 'Ctrl + колесико: масштаб относительно курсора';
	@override String get dShiftWheel => 'Shift + колесико: поворот относительно курсора';
	@override late final _TranslationsVideoDetailGestureGuideQuestRu quest = _TranslationsVideoDetailGestureGuideQuestRu._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerRu extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Ошибка загрузки источника видео';
	@override String get errorWhileSettingUpListeners => 'Ошибка настройки слушателей';
	@override String get serverFaultDetectedAutoSwitched => 'Ошибка сервера, выполнен автоматический переход на другой маршрут';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonRu extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Загрузка информации о видео...';
	@override String get fetchingVideoSources => 'Загрузка источников видео...';
	@override String get loadingVideo => 'Загрузка видео...';
	@override String get applyingSolution => 'Применение решения...';
	@override String get addingListeners => 'Добавление слушателей...';
	@override String get successFecthVideoDurationInfo => 'Длительность видео получена, загрузка видео...';
	@override String get successFecthVideoHeightInfo => 'Загрузка завершена';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastRu extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Трансляция';
	@override String unableToStartCastingSearch({required Object error}) => 'Не удалось запустить поиск устройств: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Трансляция на ${deviceName}';
	@override String castFailed({required Object error}) => 'Ошибка трансляции: ${error}\nПовторите поиск устройств или смените сеть';
	@override String get castStopped => 'Трансляция остановлена';
	@override late final _TranslationsVideoDetailCastDeviceTypesRu deviceTypes = _TranslationsVideoDetailCastDeviceTypesRu._(_root);
	@override String get currentPlatformNotSupported => 'Трансляция не поддерживается на этой платформе';
	@override String get unableToGetVideoUrl => 'Не удалось получить адрес видео, повторите позже';
	@override String get stopCasting => 'Остановить трансляцию';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetRu dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetRu._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsRu extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Кто оценил';
	@override String get dialogDescription => 'Интересно, кто это? Посмотрите список оценивших~';
	@override String get closeTooltip => 'Закрыть';
	@override String get retry => 'Повторить';
	@override String get noLikesYet => 'Здесь пока никого нет. Будьте первым!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Страница ${page} / ${totalPages} · всего ${totalCount} чел.';
	@override String get prevPage => 'Предыдущая страница';
	@override String get nextPage => 'Следующая страница';
}

// Path: forum.sitewide
class _TranslationsForumSitewideRu extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get badge => 'По всему сайту';
	@override String get title => 'Объявление для всего сайта';
	@override String get readMore => 'Подробнее';
}

// Path: forum.errors
class _TranslationsForumErrorsRu extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Выберите категорию';
	@override String get threadLocked => 'Эта тема закрыта, ответить нельзя';
}

// Path: forum.groups
class _TranslationsForumGroupsRu extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Администрация';
	@override String get global => 'Глобальный';
	@override String get chinese => 'Китайский';
	@override String get japanese => 'Японский';
	@override String get korean => 'Корейский';
	@override String get other => 'Другое';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesRu extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Объявления';
	@override String get feedback => 'Отзывы';
	@override String get support => 'Поддержка';
	@override String get general => 'Общее';
	@override String get guides => 'Руководства';
	@override String get questions => 'Вопросы';
	@override String get requests => 'Запросы';
	@override String get sharing => 'Обмен';
	@override String get general_zh => 'Общее';
	@override String get questions_zh => 'Вопросы';
	@override String get requests_zh => 'Запросы';
	@override String get support_zh => 'Поддержка';
	@override String get general_ja => 'Общее';
	@override String get questions_ja => 'Вопросы';
	@override String get requests_ja => 'Запросы';
	@override String get support_ja => 'Поддержка';
	@override String get korean => 'Корейский';
	@override String get other => 'Прочее';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsRu extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Официальные важные уведомления и объявления';
	@override String get feedback => 'Отзывы о функциях и сервисах сайта';
	@override String get support => 'Помощь в решении проблем, связанных с сайтом';
	@override String get general => 'Обсуждение любых тем';
	@override String get guides => 'Делитесь опытом и руководствами';
	@override String get questions => 'Задавайте свои вопросы';
	@override String get requests => 'Публикуйте свои запросы';
	@override String get sharing => 'Делитесь интересным контентом';
	@override String get general_zh => 'Обсуждение любых тем';
	@override String get questions_zh => 'Задавайте свои вопросы';
	@override String get requests_zh => 'Публикуйте свои запросы';
	@override String get support_zh => 'Помощь в решении проблем, связанных с сайтом';
	@override String get general_ja => 'Обсуждение любых тем';
	@override String get questions_ja => 'Задавайте свои вопросы';
	@override String get requests_ja => 'Публикуйте свои запросы';
	@override String get support_ja => 'Помощь в решении проблем, связанных с сайтом';
	@override String get korean => 'Обсуждения, связанные с корейским';
	@override String get other => 'Прочий неклассифицированный контент';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsRu extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Неподдерживаемый тип уведомления';
	@override String get unknownUser => 'Неизвестный пользователь';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Неподдерживаемый тип уведомления: ${type}';
	@override String get unknownNotificationType => 'Неизвестный тип уведомления';
}

// Path: conversation.errors
class _TranslationsConversationErrorsRu extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Выберите пользователя';
	@override String get pleaseEnterATitle => 'Введите заголовок';
	@override String get clickToSelectAUser => 'Нажмите, чтобы выбрать пользователя';
	@override String get loadFailedClickToRetry => 'Ошибка загрузки, нажмите для повтора';
	@override String get loadFailed => 'Ошибка загрузки';
	@override String get clickToRetry => 'Нажмите, чтобы повторить';
	@override String get noMoreConversations => 'Больше нет бесед';
}

// Path: splash.errors
class _TranslationsSplashErrorsRu extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Ошибка инициализации, перезапустите приложение';
}

// Path: download.errors
class _TranslationsDownloadErrorsRu extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'Модель изображения не найдена';
	@override String get downloadFailed => 'Ошибка загрузки';
	@override String get videoInfoNotFound => 'Информация о видео не найдена';
	@override String get downloadTaskAlreadyExists => 'Задача загрузки уже существует';
	@override String get downloadTaskSavePathConflict => 'Путь сохранения уже используется другой задачей';
	@override String get videoAlreadyDownloaded => 'Видео уже скачано';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'Не удалось добавить задачу загрузки: ${errorInfo}';
	@override String get userPausedDownload => 'Загрузка приостановлена пользователем';
	@override String get unknown => 'Неизвестно';
	@override String fileSystemError({required Object errorInfo}) => 'Ошибка файловой системы: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Неизвестная ошибка: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'Не удалось записать файл: ${errorInfo}';
	@override String get connectionTimeout => 'Тайм-аут подключения';
	@override String get sendTimeout => 'Тайм-аут отправки';
	@override String get receiveTimeout => 'Тайм-аут приёма';
	@override String serverError({required Object errorInfo}) => 'Ошибка сервера: ${errorInfo}';
	@override String get unknownNetworkError => 'Неизвестная сетевая ошибка';
	@override String get sslHandshakeFailed => 'Ошибка SSL-рукопожатия, проверьте сеть';
	@override String get connectionFailed => 'Не удалось подключиться, проверьте сеть';
	@override String get serviceIsClosing => 'Служба загрузки закрывается';
	@override String get partialDownloadFailed => 'Не удалось загрузить часть содержимого';
	@override String get noDownloadTask => 'Нет задачи загрузки';
	@override String get taskNotFoundOrDataError => 'Задача не найдена или ошибка данных';
	@override String get fileNotFound => 'Файл не найден';
	@override String get openFolderFailed => 'Не удалось открыть папку';
	@override String get copyDownloadUrlFailed => 'Не удалось скопировать ссылку загрузки';
	@override String openFolderFailedWithMessage({required Object message}) => 'Не удалось открыть папку: ${message}';
	@override String get directoryNotFound => 'Каталог не найден';
	@override String get copyFailed => 'Не удалось скопировать';
	@override String get openFileFailed => 'Не удалось открыть файл';
	@override String openFileFailedWithMessage({required Object message}) => 'Не удалось открыть файл: ${message}';
	@override String get playLocallyFailed => 'Не удалось воспроизвести локально';
	@override String playLocallyFailedWithMessage({required Object message}) => 'Не удалось воспроизвести локально: ${message}';
	@override String get noDownloadSource => 'Нет источника загрузки';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'Нет источника загрузки, дождитесь завершения загрузки информации и повторите попытку';
	@override String get noActiveDownloadTask => 'Нет активных задач загрузки';
	@override String get noFailedDownloadTask => 'Нет неудачных задач загрузки';
	@override String get noCompletedDownloadTask => 'Нет завершённых задач загрузки';
	@override String get taskAlreadyCompletedDoNotAdd => 'Задача уже завершена, не добавляйте её снова';
	@override String get linkExpiredTryAgain => 'Ссылка устарела, получение новой ссылки загрузки';
	@override String get linkExpiredTryAgainSuccess => 'Ссылка устарела, новая ссылка загрузки успешно получена';
	@override String get linkExpiredTryAgainFailed => 'Ссылка устарела, не удалось получить новую ссылку загрузки';
	@override String get taskDeleted => 'Задача удалена';
	@override String unsupportedImageFormat({required Object format}) => 'Неподдерживаемый формат изображения: ${format}';
	@override String get deleteFileError => 'Не удалось удалить файл, возможно, он используется другим процессом';
	@override String get deleteTaskError => 'Не удалось удалить задачу';
	@override String get canNotRefreshVideoTask => 'Не удалось обновить задачу видео';
	@override String get videoRemovedCanNotRefresh => 'Видео удалено или больше не существует, поэтому ссылку загрузки нельзя обновить';
	@override String get videoInaccessibleCanNotRefresh => 'Это видео недоступно: возможно, оно приватное или нужно войти заново';
	@override String get videoQualityGone => 'Это качество больше не доступно, добавьте загрузку снова';
	@override String get refreshLinkNetworkFailed => 'Ошибка сети: сейчас не удаётся обновить ссылку загрузки, повторите попытку позже';
	@override String get taskAlreadyProcessing => 'Задача уже обрабатывается';
	@override String get taskNotFound => 'Задача не найдена';
	@override String get failedToLoadTasks => 'Не удалось загрузить задачи';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'Ошибка частичной загрузки: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Неподдерживаемый формат изображения: ${extension}. Попробуйте скачать его на устройство для просмотра';
	@override String get imageLoadFailed => 'Не удалось загрузить изображение';
	@override String get pleaseTryOtherViewer => 'Попробуйте открыть в другом просмотрщике';
}

// Path: download.timeline
class _TranslationsDownloadTimelineRu extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get today => 'Сегодня';
	@override String get yesterday => 'Вчера';
	@override String get thisWeek => 'На этой неделе';
	@override String get thisMonth => 'В этом месяце';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesRu extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get network => 'Проблема с сетью, повтор может помочь';
	@override String get serverRejected => 'Отклонено сервером, возможно, нужно войти заново';
	@override String get notFound => 'Ресурс отсутствует или был удалён';
	@override String get diskFull => 'Недостаточно места для хранения';
	@override String get fileInUse => 'Файл используется другой программой';
	@override String get permission => 'Нет разрешения на запись';
	@override String get cancelled => 'Отменено';
	@override String get unknown => 'Неизвестная ошибка';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedRu extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => 'Незавершённые задачи из прошлого сеанса (${num}) были приостановлены';
	@override String get resume => 'Возобновить все';
	@override String get dismiss => 'Закрыть';
}

// Path: download.actions
class _TranslationsDownloadActionsRu extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeRu extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateRu extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Удаление по дате';
	@override String get dialogTitle => 'Удаление по дате';
	@override String get description => 'Массовое удаление задач загрузки по дате создания. Задачи с используемыми файлами пропускаются; задачи с отсутствующими файлами очищаются.';
	@override String get modeRange => 'Диапазон дат';
	@override String get modeDays => 'Старше';
	@override String get startDate => 'Дата начала';
	@override String get endDate => 'Дата окончания';
	@override String get notSet => 'Не задано';
	@override String get daysUnit => 'дн.';
	@override String olderThanDaysHint({required Object days}) => 'Удалить задачи, созданные более ${days} дн. назад';
	@override String get noMatch => 'Нет задач, соответствующих выбранному условию';
	@override String get invalidRange => 'Дата начала должна быть не позже даты окончания';
	@override String get confirmTitle => 'Подтвердите удаление';
	@override String confirmContent({required Object count}) => 'Удалить задач загрузки (${count}) и их файлы? Это действие нельзя отменить.';
	@override String deleting({required Object done, required Object total}) => 'Удаление ${done}/${total}…';
	@override String resultSuccess({required Object count}) => 'Удалено задач: ${count}';
	@override String resultPartial({required Object deleted, required Object skipped}) => 'Удалено задач: ${deleted}; пропущено: ${skipped} (используются)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationRu extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryRu extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Управление категориями';
	@override String get label => 'Категории';
	@override String get uncategorized => 'Без категории';
	@override String get manage => 'Управление';
	@override String get createShortcut => 'Новая';
	@override String get newCategoryHint => 'Название новой категории';
	@override String get createSuccess => 'Категория создана';
	@override String get createFailed => 'Не удалось создать категорию';
	@override String get nameEmpty => 'Название категории не может быть пустым';
	@override String get emptyHint => 'Пока нет категорий. Создайте категорию для упорядочивания загрузок.';
	@override String get moveTo => 'Переместить в категорию';
	@override String moveToWithCount({required Object count}) => 'Переместить элементов (${count}) в…';
	@override String moveSuccess({required Object title}) => 'Перемещено в ${title}';
	@override String get moveToUncategorizedSuccess => 'Перемещено в «Без категории»';
	@override String get moveFailed => 'Не удалось переместить';
	@override String get renameTitle => 'Переименовать категорию';
	@override String get renameHint => 'Введите название категории';
	@override String get renameSuccess => 'Категория переименована';
	@override String get renameFailed => 'Не удалось переименовать категорию';
	@override String get deleteTitle => 'Удалить категорию';
	@override String deleteConfirm({required Object title, required Object count}) => 'Удалить категорию «${title}»? Элементы (${count}) перейдут в «Без категории». Файлы не удаляются.';
	@override String get deleteSuccess => 'Категория удалена';
	@override String get deleteFailed => 'Не удалось удалить категорию';
}

// Path: download.location
class _TranslationsDownloadLocationRu extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadRu extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Пакетная загрузка';
	@override String get downloadTaskAlreadyRunning => 'Задача уже выполняется, подождите.';
	@override String get userCancelled => 'Отменено пользователем';
	@override String get failedToGetVideoInfo => 'Не удалось получить информацию о видео';
	@override String get failedToGetVideoSource => 'Не удалось получить источник видео';
	@override String get failedToGetGalleryInfo => 'Не удалось получить информацию о галерее';
	@override String get galleryNoImages => 'В галерее нет изображений';
	@override String get failedToGetSavePath => 'Не удалось получить путь сохранения';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Ошибка пакетной загрузки: ${exception}';
	@override String get selectQuality => 'Выберите качество';
	@override String get downloading => 'Загрузка';
	@override String get downloadResult => 'Результат загрузки';
	@override String selectedVideosCount({required Object count}) => 'Выбрано видео: ${count}';
	@override String selectedGalleriesCount({required Object count}) => 'Выбрано галерей: ${count}';
	@override String get qualityNote => 'Если выбранное качество недоступно, будет использовано лучшее доступное';
	@override String progress({required Object current, required Object total}) => 'Обработка ${current}/${total}';
	@override String get queued => 'В очереди';
	@override String get success => 'Успешно';
	@override String get skipped => 'Пропущено';
	@override String get failed => 'Ошибка';
	@override String get failureDetails => 'Детали ошибок';
	@override String get reasonPrivateVideo => 'Приватное видео';
	@override String get reasonAlreadyExists => 'Уже существует';
	@override String get reasonNoSource => 'Нет источника загрузки';
	@override String get reasonNoSavePath => 'Не удаётся получить путь сохранения';
	@override String get reasonOther => 'Другая ошибка';
	@override String get startDownload => 'Начать загрузку';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsRu extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'Не удалось добавить';
	@override String get addSuccess => 'Добавлено';
	@override String get deleteFolderFailed => 'Не удалось удалить папку';
	@override String get deleteFolderSuccess => 'Папка удалена';
	@override String get folderNameCannotBeEmpty => 'Название папки не может быть пустым';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesRu extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI Рассуждение (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude Рассуждение (расширенное мышление)';
	@override String get gemini => 'Google Gemini (нативно)';
	@override String get geminiReasoning => 'Google Gemini Рассуждение (мышление)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek Рассуждение (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeRu extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Уведомление воспроизведения: ${message}';
	@override String get networkUnstable => 'Проверьте сеть; воспроизведение может прерываться';
	@override String get audioTrackUnavailable => 'Звук недоступен; видео продолжает воспроизводиться';
	@override String get hardwareDecodeFellBack => 'Переключено на программное декодирование; может расходовать больше энергии';
	@override String get videoDecodeProblem => 'Попробуйте другое качество; изображение может сбоить';
	@override String get repeatedPlaybackProblems => 'Экспортируйте логи, чтобы сообщить о повторяющихся проблемах воспроизведения';
	@override String get issuesSheetTitle => 'Проблемы воспроизведения';
	@override String issueOccurrences({required Object count}) => 'Произошло раз: ${count}';
	@override String issueAtPosition({required Object position}) => 'На ${position}';
	@override String get noIssuesRecorded => 'Проблемы не зафиксированы';
	@override String get exportLogsAction => 'Экспортировать логи';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertRu extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Сбои сброса на диск';
	@override String get sinkDegradedTitle => 'Запись логов деградировала';
	@override String get sinkDegradedDetail => 'Файловый приёмник в деградированном состоянии';
	@override String get queueBacklogTitle => 'Очередь записи переполнена';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (порог=${threshold}, может увеличить использование памяти)';
	@override String get highFlushLatencyTitle => 'Высокая задержка сброса';
	@override String get droppedTooManyTitle => 'Слишком много потерянных логов';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (порог=${threshold})';
	@override String get rateLimitedTitle => 'Сработало ограничение частоты';
	@override String get exportFailedTitle => 'Сбои экспорта логов';
	@override String get fileNearLimitTitle => 'Файл лога близок к пределу размера';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (высокое давление ротации ввода-вывода)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastRu extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'Служба логов не инициализирована';
	@override String get exportSuccess => 'Логи экспортированы. Проверьте личные данные перед отправкой по электронной почте.';
	@override String exportFailed({required Object error}) => 'Ошибка экспорта: ${error}';
	@override String get supportEmailCopied => 'Адрес поддержки скопирован. Вставьте его в почтовый клиент и прикрепите логи.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesRu extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'По релевантности';
	@override String get latest => 'Новые';
	@override String get views => 'По просмотрам';
	@override String get likes => 'По отметкам «Нравится»';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeRu extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Добро пожаловать';
	@override String get subtitle => 'Начнём персональную настройку';
	@override String get description => 'Всего несколько шагов, чтобы настроить всё под вас';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicRu extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Основные настройки';
	@override String get subtitle => 'Настройте под себя';
	@override String get description => 'Выберите подходящие вам предпочтения';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkRu extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки сети';
	@override String get subtitle => 'Настройте параметры сети';
	@override String get description => 'Настройте под свою сетевую среду';
	@override String get tip => 'Чтобы изменения вступили в силу, после успешной настройки требуется перезапуск';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeRu extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки темы';
	@override String get subtitle => 'Выберите предпочитаемый вид';
	@override String get description => 'Персонализируйте визуальное оформление';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerRu extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки плеера';
	@override String get subtitle => 'Настройте элементы управления воспроизведением';
	@override String get description => 'Быстрая настройка параметров воспроизведения';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialRu extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Пространственное воспроизведение';
	@override String get subtitle => 'Просмотр на гарнитуре';
	@override String get description => 'На гарнитуре видео и галереи появляются в окружающем пространстве, а не внутри этой плавающей панели';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionRu extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Завершение настройки';
	@override String get subtitle => 'Вы готовы начать';
	@override String get description => 'Прочитайте и примите соответствующие соглашения';
	@override String get agreementTitle => 'Пользовательское соглашение и правила сообщества';
	@override String get agreementDesc => 'Перед использованием приложения внимательно прочитайте и примите наше пользовательское соглашение и правила сообщества. Эти условия помогают поддерживать здоровую атмосферу.';
	@override String get checkboxTitle => 'Я прочитал(а) и принимаю пользовательское соглашение и правила сообщества';
	@override String get checkboxSubtitle => 'При несогласии использовать приложение нельзя';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonRu extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Эти настройки можно изменить в любое время в разделе «Настройки»';
	@override String get previousStep => 'Назад';
	@override String get nextStep => 'Далее';
	@override String get finishSetup => 'Завершить настройку';
	@override String get agreeAgreementSnackbar => 'Сначала примите пользовательское соглашение и правила сообщества';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsRu extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Высокое качество';
	@override String get fast => 'Быстрый';
	@override String get lite => 'Облегчённый';
	@override String get moreLite => 'Более облегчённый';
	@override String get custom => 'Пользовательский';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsRu extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Подходит для большинства аниме в 1080p, особенно при наличии размытия, артефактов ресемплинга и сжатия. Обеспечивает наивысшее воспринимаемое качество.';
	@override String get mode_b_hq => 'Подходит для аниме с лёгким размытием или звоном, вызванным масштабированием. Эффективно снижает звон и алиасинг.';
	@override String get mode_c_hq => 'Подходит для качественных источников (например, нативных аниме или фильмов в 1080p). Устраняет шум и обеспечивает наивысший PSNR.';
	@override String get mode_a_a_hq => 'Улучшенная версия режима A: максимальное воспринимаемое качество, позволяет восстановить почти все повреждённые линии. Возможно появление избыточной резкости или звона.';
	@override String get mode_b_b_hq => 'Улучшенная версия режима B: более высокое воспринимаемое качество, дополнительная оптимизация линий и снижение артефактов.';
	@override String get mode_c_a_hq => 'Версия режима C с повышенным воспринимаемым качеством: сохраняет высокий PSNR и пытается восстановить часть деталей линий.';
	@override String get mode_a_fast => 'Быстрая версия режима A: баланс качества и производительности, подходит для большинства аниме в 1080p.';
	@override String get mode_b_fast => 'Быстрая версия режима B: обработка лёгких артефактов и звона с меньшими затратами ресурсов.';
	@override String get mode_c_fast => 'Быстрая версия режима C: быстрое шумоподавление и масштабирование качественных источников.';
	@override String get mode_a_a_fast => 'Быстрая версия режима A+A: обеспечивает более высокое воспринимаемое качество на устройствах с ограниченной производительностью.';
	@override String get mode_b_b_fast => 'Быстрая версия режима B+B: улучшенное восстановление линий и обработка артефактов для устройств с ограниченной производительностью.';
	@override String get mode_c_a_fast => 'Быстрая версия режима C+A: быстро обрабатывает качественные источники и обеспечивает лёгкое восстановление линий.';
	@override String get upscale_only_s => 'Сверхбыстрое масштабирование x2 только с помощью самой быстрой CNN-модели: без восстановления и шумоподавления, минимальные затраты ресурсов.';
	@override String get upscale_deblur_fast => 'Быстрое масштабирование и устранение размытия с помощью традиционных алгоритмов без CNN: лучше стандартных алгоритмов плеера при очень низких затратах ресурсов.';
	@override String get restore_s_only => 'Только восстановление с помощью самой быстрой CNN-модели, без масштабирования. Подходит для воспроизведения в нативном разрешении, когда нужно улучшить качество.';
	@override String get denoise_bilateral_fast => 'Быстрое шумоподавление с помощью традиционной двусторонней фильтрации: очень быстро, подходит для обработки слабого шума.';
	@override String get upscale_non_cnn => 'Быстрое масштабирование традиционными алгоритмами: очень низкие затраты ресурсов, лучше стандартных настроек плеера.';
	@override String get mode_a_fast_darken => 'Режим A (быстрый) + затемнение линий: добавляет эффект затемнения линий к быстрому режиму A для более выразительных, стилизованных линий.';
	@override String get mode_a_hq_thin => 'Режим A (HQ) + утончение линий: добавляет эффект утончения линий к высококачественному режиму A для более изящного вида.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesRu extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'Масштабирование CNN (сверхбыстро)';
	@override String get upscale_deblur_fast => 'Масштабирование и устранение размытия (быстро)';
	@override String get restore_s_only => 'Восстановление (сверхбыстро)';
	@override String get denoise_bilateral_fast => 'Двустороннее шумоподавление (сверхбыстро)';
	@override String get upscale_non_cnn => 'Масштабирование без CNN (сверхбыстро)';
	@override String get mode_a_fast_darken => 'Режим A (быстрый) + затемнение линий';
	@override String get mode_a_hq_thin => 'Режим A (HQ) + утончение линий';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseRu extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Быстрый доступ';
	@override String get sourcesSection => 'Папки';
	@override String get pin => 'Добавить в быстрый доступ';
	@override String get unpin => 'Убрать из быстрого доступа';
	@override String get pinned => 'Добавлено в быстрый доступ';
	@override String get unpinned => 'Убрано из быстрого доступа';
	@override String folderCount({required Object count}) => 'Папок: ${count}';
	@override String videoCount({required Object count}) => 'Видео: ${count}';
	@override String imageCount({required Object count}) => 'Изображений: ${count}';
	@override String get emptyFolder => 'Эта папка пуста';
	@override String get videosSection => 'Видео';
	@override String get imagesSection => 'Изображения';
	@override String get galleriesSection => 'Галереи';
	@override String get filterAll => 'Все';
	@override String get searchInFolder => 'Поиск в этой папке';
	@override String get searchHint => 'Поиск по имени';
	@override String get clearSearch => 'Очистить поиск';
	@override String searchNoResult({required Object query}) => 'Ничего не найдено по запросу «${query}»';
	@override String viewAllFolders({required Object count}) => 'Показать все папки (${count})';
	@override String viewAllVideos({required Object count}) => 'Показать все видео (${count})';
	@override String viewAllImages({required Object count}) => 'Показать все изображения (${count})';
	@override String viewAllGalleries({required Object count}) => 'Показать все галереи (${count})';
	@override String get location => 'Расположение';
	@override String get sourceMissing => 'Этот источник недоступен';
	@override String get notScannedYet => 'Эта папка ещё не просканирована';
	@override String get scanning => 'Чтение папки…';
	@override String get deleteFileTitle => 'Удалить этот файл?';
	@override String deleteFileBody({required Object name}) => '«${name}» будет безвозвратно удалён с этого устройства. Это действие нельзя отменить.';
	@override String get hideFolder => 'Скрыть эту папку';
	@override String get unhideFolder => 'Показать снова';
	@override String get showHiddenFolders => 'Показывать скрытые папки';
	@override String get includeDotFolders => 'Сканировать папки, начинающиеся с .';
	@override String get dotFoldersIncluded => 'Папки, начинающиеся с ., теперь сканируются';
	@override String get dotFoldersExcluded => 'Папки, начинающиеся с ., больше не сканируются';
	@override String get showDotFolders => 'Показывать папки, начинающиеся с .';
	@override String dotFoldersSkipped({required Object count}) => 'Здесь есть ${count} несканированных папок, начинающихся с .';
	@override String get scanDotFoldersAction => 'Включить для этого источника';
	@override String get otherAppsPrivateNotice => 'Начиная с Android 11 ни одно приложение не может читать файлы других приложений в Android/data и Android/obb, и это приложение не может обойти запрет. Скачайте или экспортируйте видео в общую папку, например Download, в исходном приложении, а затем добавьте эту папку сюда. Кэш при просмотре обычно разбит на фрагменты и не воспроизводится, даже если его прочитать.';
	@override String get folderHidden => 'Скрыта — сканирование тоже её пропустит';
	@override String get folderUnhidden => 'Больше не скрыта';
	@override String get hiddenFolderBadge => 'Скрыта';
	@override String get deleteFolder => 'Удалить папку';
	@override String get deleteFolderTitle => 'Удалить эту папку?';
	@override String deleteFolderBody({required Object name}) => '«${name}» и всё её содержимое будут безвозвратно удалены с этого устройства. Отменить это нельзя.';
	@override String get deleteFolderIncludesOthers => 'Другие файлы внутри тоже будут удалены';
	@override String get folderDeleted => 'Папка удалена';
	@override String get deleteFolderFailed => 'Не удалось удалить: нет прав или файл внутри занят';
	@override String get deleteGalleryTitle => 'Удалить эту галерею?';
	@override String deleteGalleryBody({required Object name}) => 'Запись о загрузке и локальные файлы изображений «${name}» будут удалены. Это действие нельзя отменить.';
	@override String get galleryResourceMissing => 'Локальные файлы больше не существуют. Запись очищена.';
	@override String get viewDownloadDetail => 'Открыть детали загрузки';
	@override String get viewOnlineGallery => 'Открыть на сайте';
	@override String get pickFolderTitle => 'Выберите папку';
	@override String get useThisFolder => 'Использовать эту папку';
	@override String get noSubfolders => 'Здесь нет подпапок';
	@override String get storageRoot => 'Хранилище устройства';
	@override String get homeFolder => 'Домашняя';
	@override String get filesystemRoot => 'Корень файловой системы';
	@override String get folderUnreadable => 'Не удаётся прочитать эту папку';
	@override String get setCover => 'Задать обложку';
	@override String get setAsFolderCover => 'Использовать как обложку папки';
	@override String get folderCoverSet => 'Обложка папки обновлена';
	@override String get setFolderCoverPick => 'Задать обложку…';
	@override String get restoreAutoCover => 'Восстановить автоматическую обложку';
	@override String get autoCoverRestored => 'Автоматическая обложка восстановлена';
	@override String get rescanFolder => 'Пересканировать эту папку';
	@override String get coverPickerTitle => 'Выберите кадр';
	@override String get folderCoverPickerTitle => 'Выберите обложку';
	@override String get coverPickerEmpty => 'В этой папке пока нет изображений. Миниатюры видео могут ещё создаваться в фоне.';
	@override String get coverSaved => 'Обложка обновлена';
	@override String get coverSaveFailed => 'Не удалось сохранить обложку';
	@override String get coverUnavailable => 'Не удалось прочитать кадр видео из этого файла';
	@override String get deleted => 'Удалено';
	@override String get deleteFailed => 'Не удалось удалить — возможно, файл используется или защищён от записи';
	@override String get openFolder => 'Открыть';
	@override String get favorite => 'Добавить в избранное';
	@override String get unfavorite => 'Убрать из избранного';
	@override String get favorited => 'Добавлено в избранное';
	@override String get unfavorited => 'Убрано из избранного';
	@override String get sortBy => 'Сортировать по';
	@override String get sortAscending => 'По возрастанию';
	@override String get sortDescending => 'По убыванию';
	@override String get sortFieldName => 'Название';
	@override String get sortFieldModified => 'Дата изменения';
	@override String get sortFieldDuration => 'Длительность';
	@override String get sortFieldSize => 'Размер';
	@override String get sortFieldResolution => 'Разрешение';
	@override String get sortFieldFileType => 'Тип файла';
	@override String get sortFieldFps => 'Частота кадров';
	@override String get sortFieldFavorited => 'Дата добавления в избранное';
	@override String get emptyAllVideos => 'Видео не найдены. Добавьте папку в разделе «Папки», чтобы начать.';
	@override String get emptyAllImages => 'Изображения не найдены. Добавьте папку в разделе «Папки», чтобы начать.';
	@override String get emptyFavorites => 'Пока нет избранного. Добавьте из меню ⋮ на видео.';
	@override String get emptyPinned => 'Пока нет закреплённых папок. Нажмите и удерживайте папку в разделе «Папки» и выберите «Закрепить».';
	@override String get emptyDownloadedVideos => 'Пока нет завершённых загрузок видео.';
	@override String get emptyDownloadedGalleries => 'Пока нет завершённых загрузок галерей.';
	@override String get folderInfo => 'Сведения о папке';
	@override String get folderInfoName => 'Название';
	@override String get folderInfoPath => 'Путь';
	@override String get folderInfoSource => 'Источник';
	@override String get folderInfoContents => 'Содержимое';
	@override String get folderInfoSize => 'Размер на диске';
	@override String get folderInfoScannedAt => 'Последнее сканирование';
	@override String get folderInfoNeverScanned => 'Ещё не сканировалось';
	@override String get folderInfoNoPath => 'У этого источника нет папки для открытия';
	@override String get copyPath => 'Копировать путь';
	@override String get pathCopied => 'Путь скопирован';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsRu extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingRu extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavRu extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorRu extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Шаблон пути';
	@override String get subtitle => 'Автоматически раскладывает загрузки по подпапкам';
	@override String get tabVideo => 'Видео';
	@override String get tabGallery => 'Галерея';
	@override String get tabImage => 'Отдельное изображение';
	@override String get previewLabel => 'Предпросмотр · реальный результат после очистки';
	@override String get galleryPreviewLabel => 'Предпросмотр · шаблон галереи = имя папки (внутренние изображения именуются по ID)';
	@override String get addFolder => 'Добавить уровень папок';
	@override String get folderCapReached => 'Достигнут предел уровней папок';
	@override String get folderSegmentHint => '%authorcache, переменная или текст';
	@override String get fileSegmentHint => 'напр. %title_%quality';
	@override String videoCapNote({required Object max}) => 'Расширение .mp4 добавится само · ввод / внутри сегмента делит его на два уровня · максимум ${max} уровней';
	@override String imageCapNote({required Object max}) => 'Исходное расширение добавится само · ввод / внутри сегмента делит его на два уровня · максимум ${max} уровней';
	@override String galleryCapNote({required Object max}) => 'Шаблон галереи — только папки, максимум ${max} уровней · внутренние изображения именуются по ID';
	@override String get trayHint => 'Нажмите, чтобы вставить в позицию курсора · долгое нажатие — подробности';
	@override String get emptySegment => 'Пустой сегмент';
	@override String get emptySegmentSaveBlocked => 'Нельзя сохранить: есть пустые сегменты, заполните или удалите их';
	@override String get tooManySegmentsSaveBlocked => 'Нельзя сохранить: слишком много сегментов пути (макс. 4). Объедините или удалите лишние';
	@override String get templateInvalidSaveBlocked => 'Нельзя сохранить: шаблон содержит недопустимые символы';
	@override String get variableInserted => 'Переменная вставлена';
	@override String get savedToast => 'Сохранено · касается только новых загрузок';
	@override String get trayCategoryContent => 'Содержимое';
	@override String get trayCategoryAuthor => 'Автор';
	@override String get trayCategoryTime => 'Время';
	@override String get chipAuthorcache => 'Имя автора·фикс.';
	@override String get chipDate => 'Дата';
	@override String get chipTime => 'Время';
	@override String get chipDatetime => 'Дата и время';
	@override String get chipCount => 'Номер';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestRu extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Управление в Quest';
	@override String get intro => 'Познакомьтесь с элементами управления и попробуйте их в своем пространстве.';
	@override String get videoTab => 'Пространственное видео';
	@override String get galleryTab => 'Пространственная галерея';
	@override String get scopeNote => 'Для экранов и окон в пространстве Quest. Доступно в любое время в настройках плеера.';
	@override String get catalog => 'Обзор управления';
	@override String lessonCount({required Object current, required Object total}) => '${current} из ${total}';
	@override String get previous => 'Назад';
	@override String get next => 'Далее';
	@override String get replay => 'Повторить демо';
	@override String get pauseDemo => 'Пауза демо';
	@override String get resumeDemo => 'Продолжить демо';
	@override String get looping => 'Демонстрация';
	@override String get still => 'Иллюстрация';
	@override String get done => 'Понятно, продолжить';
	@override String get leftController => 'Левая рука';
	@override String get rightController => 'Правая рука';
	@override String get trigger => 'Триггер (курок)';
	@override String get grip => 'Боковая кнопка (хват)';
	@override String get bothGrips => 'Обе боковые кнопки';
	@override String get stick => 'Стик';
	@override String get handTracking => 'Отслеживание рук';
	@override String get ready => 'Готово';
	@override String get press => 'Нажать';
	@override String get hold => 'Удерживать';
	@override String get release => 'Отпустить';
	@override String get result => 'Результат';
	@override String get pinch => 'Щипок';
	@override String get selectTitle => 'Наведение и выбор';
	@override String get selectBody => 'Наведите луч на кнопку, затем нажмите и отпустите триггер. Используется для воспроизведения, настроек и ползунков.';
	@override String get selectHint => 'Триггер находится под указательным пальцем. Кнопка хвата на рукоятке перемещает окна.';
	@override String get panelTitle => 'Показать или скрыть панель';
	@override String get panelBody => 'Направьте луч мимо панели и нажмите триггер, чтобы скрыть или показать ее. При отслеживании рук выполните быстрый щипок в пустоте.';
	@override String get panelHint => 'Используйте короткое нажатие без перемещения. Удержание с движением перемещает экран.';
	@override String get playTitle => 'Воспроизведение и пауза';
	@override String get playBody => 'Направьте луч в сторону от панели и нажмите кнопку A (справа) или X (слева). Также можно нажать кнопку воспроизведения на панели.';
	@override String get playHint => 'Это сочетание можно отключить в настройках пространственного плеера. При наведении на панель нажатие управляет панелью.';
	@override String get seekTitle => 'Перемотка стиком';
	@override String get seekBody => 'Отклоните любой стик влево или вправо на 5 секунд. Удерживайте для быстрой перемотки с предпросмотром. Отпустите для применения.';
	@override String get seekHint => 'Удерживайте луч в стороне от панели управления, иначе стик будет прокручивать панель.';
	@override String get browseTitle => 'Просмотр стиком';
	@override String get browseBody => 'Отклоните стик влево/вправо для перехода к предыдущему или следующему элементу; удерживайте для непрерывного листания. Можно также выбрать миниатюру.';
	@override String get browseHint => 'Видео в галерее также считаются элементами. Наведение на панель переключает стик на ее прокрутку.';
	@override String get swipeTitle => 'Перелистывание перетаскиванием';
	@override String get swipeBody => 'Наведите на изображение, зажмите триггер и потяните влево. Отпустите после подсказки о смене страницы; потяните вправо для возврата. Щипок с перетаскиванием тоже работает.';
	@override String get swipeHint => 'Для перелистывания изображение должно быть в масштабе 1×. Поддерживаются и видео в галерее. Сцена остается на месте до отпускания.';
	@override String get zoomTitle => 'Масштабирование изображения';
	@override String get zoomBody => 'Наведите на деталь, зажмите триггер и отклоните стик вверх для приближения или вниз для отдаления. Центр зума фиксируется в точке нажатия.';
	@override String get zoomHint => 'Масштабирует изображение внутри его окна. Без зажатия изображения стик вверх/вниз меняет расстояние до экрана.';
	@override String get panTitle => 'Панорамирование и сброс';
	@override String get panBody => 'При приближении удерживайте триггер и двигайте руку для осмотра. Двойное нажатие по изображению увеличивает до 2.5× или сбрасывает масштаб. Руками: быстрый двойной щипок.';
	@override String get panHint => 'Перетаскивание перемещает увеличенное изображение. Сбросьте до 1× перед перелистыванием страниц.';
	@override String get slideshowTitle => 'Запуск слайд-шоу';
	@override String get slideshowBody => 'Кнопки A / X на изображении запускают слайд-шоу. На панели можно выбрать интервал (3, 5, 10 или 20 с) и качество.';
	@override String get slideshowHint => 'Для видео в галерее A / X управляют воспроизведением. Горячие клавиши контроллера должны быть включены в настройках.';
	@override String get moveTitle => 'Захват и перемещение экрана';
	@override String get moveBody => 'Зажмите кнопку хвата на внутренней стороне рукоятки, переместите экран контроллером и отпустите. При просмотре можно хватать экран, не целясь в него.';
	@override String get moveHint => 'Наведение на окно приложения или панель захватывает их в первую очередь. В панорамном видео хват вращает ракурс.';
	@override String get scaleTitle => 'Изменение размера двумя руками';
	@override String get scaleBody => 'Зажмите обе кнопки хвата. Разведите руки в стороны для увеличения или сведите для уменьшения. Руками: удерживайте щипок обеими руками.';
	@override String get scaleHint => 'Для плоских и изогнутых экранов, включая сцену галереи. Не наводите на панель. Изменяет размер экрана целиком.';
	@override String get distanceTitle => 'Расстояние просмотра';
	@override String get distanceBody => 'Отклоните стик вверх, чтобы отдалить экран, или вниз, чтобы приблизить. При захвате окна стик двигает это окно. Громкость настраивается на панели.';
	@override String get distanceHint => 'Направьте луч мимо панели управления. Удержание изображения переключает стик на зум; в панорамном видео настраивается угол обзора.';
	@override String get resizeTitle => 'Края и углы';
	@override String get resizeBody => 'Рамка подсвечивается при приближении луча к краю. Зажмите триггер или щипок на краю для перемещения; потяните за угол для масштабирования.';
	@override String get resizeHint => 'Работает для окна приложения, панели управления и экрана. Окно меняет ширину и высоту; экран сохраняет пропорции.';
	@override String get navigationTitle => 'Назад и открытие настроек';
	@override String get navigationBody => 'B / Y возвращает на шаг назад: закрывает всплывающее окно, скрывает панель и возвращает в приложение. Левая кнопка меню открывает настройки пространства.';
	@override String get navigationHint => 'Правая кнопка Meta зарезервирована системой. Системное центрирование возвращает экран перед вами с сохранением размера и расстояния.';
	@override String get handsTitle => 'Управление руками';
	@override String get handsBody => 'При включенном отслеживании рук наведите системный луч на кнопку, сомкните большой и указательный пальцы (щипок) и разомкните. Панель служит для воспроизведения, перемотки и галереи.';
	@override String get handsHint => 'Щипок в пустоте скрывает/показывает панель. Щипок за край перемещает, за угол меняет размер, щипок двумя руками масштабирует экран.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesRu extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Медиаплеер';
	@override String get mediaServer => 'Медиасервер';
	@override String get internetGatewayDevice => 'Маршрутизатор';
	@override String get basicDevice => 'Базовое устройство';
	@override String get dimmableLight => 'Умный светильник';
	@override String get wlanAccessPoint => 'Точка доступа WLAN';
	@override String get wlanConnectionDevice => 'Сетевое устройство WLAN';
	@override String get printer => 'Принтер';
	@override String get scanner => 'Сканер';
	@override String get digitalSecurityCamera => 'Камера безопасности';
	@override String get unknownDevice => 'Неизвестное устройство';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetRu extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Беспроводная трансляция';
	@override String get close => 'Закрыть';
	@override String get searchingDevices => 'Поиск устройств...';
	@override String get searchPrompt => 'Нажмите кнопку для повторного поиска устройств трансляции';
	@override String get searching => 'Поиск';
	@override String get searchAgain => 'Искать снова';
	@override String get noDevicesFound => 'Устройства трансляции не найдены\nУбедитесь, что устройства в одной сети';
	@override String get searchingDevicesPrompt => 'Поиск устройств, подождите...';
	@override String get cast => 'Транслировать';
	@override String connectedTo({required Object deviceName}) => 'Подключено к: ${deviceName}';
	@override String get notConnected => 'Нет подключенных устройств';
	@override String get stopCasting => 'Остановить трансляцию';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Профиль',
			'personalProfile.editPersonalProfile' => 'Редактировать профиль',
			'personalProfile.avatar' => 'Аватар',
			'personalProfile.background' => 'Фон',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'Не удалось загрузить профиль: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Рекомендуемое разрешение: ${resolution}, размер файла < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Поддерживаемые форматы: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Премиум-пользователи могут использовать анимированный ${type} (${formats})',
			'personalProfile.homepageBackground' => 'Фон главной страницы',
			'personalProfile.basicInfo' => 'Основная информация',
			'personalProfile.nickname' => 'Псевдоним',
			'personalProfile.username' => 'Имя пользователя',
			'personalProfile.copyUsername' => 'Копировать имя пользователя',
			'personalProfile.usernameCopied' => 'Имя пользователя скопировано',
			'personalProfile.personalIntroduction' => 'О себе',
			'personalProfile.noPersonalIntroduction' => 'Нет описания',
			'personalProfile.clickToEdit' => 'Нажмите для редактирования',
			'personalProfile.privacySettings' => 'Конфиденциальность',
			'personalProfile.hideSensitiveContent' => 'Скрывать деликатный контент',
			'personalProfile.hideSensitiveContentDesc' => 'Скрывать видео и изображения с деликатными тегами.',
			'personalProfile.notificationSettings' => 'Настройки уведомлений',
			'personalProfile.contentCommentNotification' => 'Комментарии к контенту',
			'personalProfile.contentCommentNotificationDesc' => 'Уведомлять о новых комментариях к вашему контенту.',
			'personalProfile.commentReplyNotification' => 'Ответы на комментарии',
			'personalProfile.commentReplyNotificationDesc' => 'Уведомлять об ответах на ваши комментарии.',
			'personalProfile.mentionNotification' => 'Упоминания',
			'personalProfile.mentionNotificationDesc' => 'Уведомлять, когда вас упоминают в контенте.',
			'personalProfile.accountInfo' => 'Данные аккаунта',
			'personalProfile.registrationTime' => 'Дата регистрации',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'Не удалось обновить настройки: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'Не удалось обновить настройки уведомлений: ${error}',
			'personalProfile.editNickname' => 'Изменить псевдоним',
			'personalProfile.nicknameCannotBeEmpty' => 'Псевдоним не может быть пустым',
			'personalProfile.changeSuccess' => 'Изменения сохранены',
			'personalProfile.unsupportedFileFormat' => 'Неподдерживаемый формат файла',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'Размер файла не может превышать ${size}',
			'personalProfile.uploadFailed' => 'Ошибка загрузки',
			'personalProfile.avatarUpdatedSuccessfully' => 'Аватар успешно обновлен',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'Не удалось обновить аватар: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Фон успешно обновлен',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'Не удалось обновить фон: ${error}',
			'personalProfile.editPersonalIntroduction' => 'Редактировать описание',
			'personalProfile.enterPersonalIntroduction' => 'Введите описание о себе',
			'tutorial.specialFollowFeature' => 'Особые подписки',
			'tutorial.specialFollowDescription' => 'Отмечайте любимых авторов как особые подписки, чтобы быстро переходить к их новым публикациям.',
			'tutorial.stepsTitle' => 'Три шага',
			'tutorial.stepFollowAuthor' => 'Нажмите «Подписаться» на странице автора, видео или галереи.',
			'tutorial.stepPickSpecial' => 'Нажмите «Подписан» еще раз и выберите «Особая подписка».',
			'tutorial.stepSwitchHere' => 'Вернитесь сюда и переключитесь на автора через панель аватаров выше.',
			'tutorial.specialFollowManagementTip' => 'Управление списком особых подписок: Боковое меню — Подписки — Особые подписки.',
			'tutorial.gotIt' => 'Понятно',
			'common.sort' => 'Сортировка',
			'common.filter' => 'Фильтр',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'ОК',
			'common.cancel' => 'Отмена',
			'common.select' => 'Выбрать',
			'common.save' => 'Сохранить',
			'common.delete' => 'Удалить',
			'common.visit' => 'Перейти',
			'common.loading' => 'Загрузка...',
			'common.scrollToTop' => 'Наверх',
			'common.privacyHint' => 'Включен приватный режим, контент скрыт',
			'common.latest' => 'Новые',
			'common.likesCount' => 'Отметки «Нравится»',
			'common.viewsCount' => 'Просмотры',
			'common.popular' => 'Популярные',
			'common.trending' => 'В тренде',
			'common.commentList' => 'Комментарии',
			'common.sendComment' => 'Написать комментарий',
			'common.send' => 'Отправить',
			'common.retry' => 'Повторить',
			'common.premium' => 'Премиум',
			'common.follower' => 'Подписчик',
			'common.friend' => 'Друг',
			'common.video' => 'Видео',
			'common.following' => 'Подписки',
			'common.expand' => 'Развернуть',
			'common.collapse' => 'Свернуть',
			'common.cancelFriendRequest' => 'Отменить заявку',
			'common.cancelSpecialFollow' => 'Отменить особую подписку',
			'common.addFriend' => 'Добавить в друзья',
			'common.removeFriend' => 'Удалить из друзей',
			'common.followed' => 'Вы подписаны',
			'common.follow' => 'Подписаться',
			'common.unfollow' => 'Отписаться',
			'common.specialFollow' => 'Особая подписка',
			'common.specialFollowed' => 'Особая подписка',
			'common.gallery' => 'Галерея',
			'common.playlist' => 'Плейлист',
			'common.commentPostedSuccessfully' => 'Комментарий опубликован',
			'common.commentPostedFailed' => 'Не удалось опубликовать комментарий',
			'common.success' => 'Успешно',
			'common.commentDeletedSuccessfully' => 'Комментарий удален',
			'common.commentUpdatedSuccessfully' => 'Комментарий обновлен',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: 'Комментарий: ${n}', other: 'Комментариев: ${n}', ), 
			'common.writeYourCommentHere' => 'Напишите комментарий...',
			'common.tmpNoReplies' => 'Ответов пока нет',
			'common.loadMore' => 'Загрузить еще',
			'common.loadingMore' => 'Загрузка...',
			'common.noMoreDatas' => 'Больше ничего нет',
			'common.selectTranslationLanguage' => 'Выберите язык перевода',
			'common.translate' => 'Перевести',
			'common.translateFailedPleaseTryAgainLater' => 'Ошибка перевода, повторите позже',
			'common.translationResult' => 'Результат перевода',
			'common.justNow' => 'Только что',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: '${n} мин. назад', other: '${n} мин. назад', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: '${n} ч. назад', other: '${n} ч. назад', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: '${n} дн. назад', other: '${n} дн. назад', ), 
			'common.editedAt' => ({required Object num}) => 'изменено: ${num}',
			'common.editComment' => 'Изменить комментарий',
			'common.commentUpdated' => 'Комментарий обновлен',
			'common.replyComment' => 'Ответить на комментарий',
			'common.reply' => 'Ответить',
			'common.edit' => 'Изменить',
			'common.unknownUser' => 'Неизвестный пользователь',
			'common.me' => 'Я',
			'common.author' => 'Автор',
			'common.admin' => 'Администратор',
			'common.viewReplies' => ({required Object num}) => 'Показать ответы (${num})',
			'common.hideReplies' => 'Скрыть ответы',
			'common.confirmDelete' => 'Подтверждение удаления',
			'common.areYouSureYouWantToDeleteThisItem' => 'Вы уверены, что хотите удалить этот элемент?',
			'common.tmpNoComments' => 'Комментариев пока нет',
			'common.refresh' => 'Обновить',
			'common.back' => 'Назад',
			'common.tips' => 'Подсказка',
			'common.linkIsEmpty' => 'Ссылка пуста',
			'common.linkCopiedToClipboard' => 'Ссылка скопирована',
			'common.imageCopiedToClipboard' => 'Изображение скопировано',
			'common.copyImageFailed' => 'Не удалось скопировать изображение',
			'common.mobileSaveImageIsUnderDevelopment' => 'Сохранение на мобильных в разработке',
			'common.imageSavedTo' => 'Изображение сохранено в',
			'common.saveImageFailed' => 'Не удалось сохранить изображение',
			'common.close' => 'Закрыть',
			'common.more' => 'Еще',
			'common.unknownError' => 'Неизвестная ошибка',
			'common.moreFeaturesToBeDeveloped' => 'Другие функции в разработке',
			'common.all' => 'Все',
			'common.selectedRecords' => ({required Object num}) => 'Выбрано записей: ${num}',
			'common.cancelSelectAll' => 'Снять выбор',
			'common.selectAll' => 'Выбрать все',
			'common.invertSelection' => 'Инвертировать выбор',
			'common.exitEditMode' => 'Выйти из режима выбора',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Удалить выбранные элементы (${num})?',
			'common.searchHistoryRecords' => 'Поиск в истории...',
			'common.settings' => 'Настройки',
			'common.subscriptions' => 'Подписки',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: 'Видео: ${n}', other: 'Видео: ${n}', ), 
			'common.share' => 'Поделиться',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Поделиться этим плейлистом?',
			'common.editTitle' => 'Изменить название',
			'common.editMode' => 'Режим редактирования',
			'common.pleaseEnterNewTitle' => 'Введите новое название',
			'common.createPlayList' => 'Создать плейлист',
			'common.create' => 'Создать',
			'common.checkNetworkSettings' => 'Проверьте настройки сети',
			'common.general' => 'Общее',
			'common.r18' => 'R18',
			'common.sensitive' => 'Деликатный',
			'common.year' => 'Год',
			'common.month' => 'Месяц',
			'common.tag' => 'Тег',
			'common.private' => 'Приватный',
			'common.noTitle' => 'Без названия',
			'common.search' => 'Поиск',
			'common.noContent' => 'Нет содержимого',
			'common.recording' => 'Запись',
			'common.paused' => 'На паузе',
			'common.clear' => 'Очистить',
			'common.clearSelection' => 'Снять выбор',
			'common.selectItemsToContinue' => 'Выберите элементы для продолжения',
			'common.andMoreItems' => ({required Object num}) => 'и еще ${num}',
			'common.batchDelete' => 'Пакетное удаление',
			'common.user' => 'Пользователь',
			'common.post' => 'Публикация',
			'common.seconds' => 'Секунды',
			'common.comingSoon' => 'Скоро',
			'common.confirm' => 'Подтвердить',
			'common.hour' => 'Час',
			'common.minute' => 'Минута',
			'common.clickToRefresh' => 'Нажмите для обновления',
			'common.history' => 'История',
			'common.favorites' => 'Избранное',
			'common.friends' => 'Друзья',
			'common.playList' => 'Плейлист',
			'common.checkLicense' => 'Лицензия',
			'common.logout' => 'Выйти',
			'common.fensi' => 'Подписчики',
			'common.accept' => 'Принять',
			'common.reject' => 'Отклонить',
			'common.clearAllHistory' => 'Очистить всю историю',
			'common.clearAllHistoryConfirm' => 'Вы уверены, что хотите очистить всю историю?',
			'common.followingList' => 'Подписки',
			'common.followersList' => 'Подписчики',
			'common.follows' => 'Подписки',
			'common.fans' => 'Подписчики',
			'common.followsAndFans' => 'Подписки и подписчики',
			'common.numViews' => 'Просмотры',
			'common.updatedAt' => 'Обновлено',
			'common.publishedAt' => 'Опубликовано',
			'common.externalVideo' => 'Внешнее видео',
			'common.originalText' => 'Исходный текст',
			'common.showOriginalText' => 'Показать оригинал',
			'common.showProcessedText' => 'Показать обработанный текст',
			'common.preview' => 'Предпросмотр',
			'common.rules' => 'Правила',
			'common.agree' => 'Принять',
			'common.disagree' => 'Отклонить',
			'common.agreeToRules' => 'Принять правила',
			'common.tapToReread' => 'Нажмите, чтобы перечитать',
			'common.markdownSyntaxHelp' => 'Справка по Markdown',
			'common.previewContent' => 'Предпросмотр',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Превышен лимит символов (${max})',
			'common.agreeToCommunityRules' => 'Принять правила сообщества',
			'common.createPost' => 'Создать запись',
			'common.title' => 'Заголовок',
			'common.enterTitle' => 'Введите заголовок',
			'common.content' => 'Содержимое',
			'common.enterContent' => 'Введите содержимое',
			'common.writeYourContentHere' => 'Введите текст...',
			'common.tagBlacklist' => 'Черный список тегов',
			'common.noData' => 'Нет данных',
			'common.tagLimit' => 'Лимит тегов',
			'common.enableFloatingButtons' => 'Включить плавающие кнопки',
			'common.disableFloatingButtons' => 'Отключить плавающие кнопки',
			'common.enabledFloatingButtons' => 'Плавающие кнопки включены',
			'common.disabledFloatingButtons' => 'Плавающие кнопки отключены',
			'common.pendingCommentCount' => 'Ожидает проверки',
			'common.joined' => ({required Object str}) => 'Регистрация: ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'В сети: ${str}',
			'common.download' => 'Скачать',
			'common.selectQuality' => 'Выберите качество',
			'common.videoQualitySource' => 'Исходное',
			'common.selectImageQuality' => 'Качество изображений',
			'common.imageQualityStandard' => 'Стандартное',
			'common.imageQualityOriginal' => 'Исходное',
			'common.selectDateRange' => 'Выбрать диапазон дат',
			'common.selectDateRangeHint' => 'Выберите диапазон дат (по умолч. 30 дней)',
			'common.clearDateRange' => 'Сбросить диапазон',
			'common.deleteRecordsInDateRange' => 'Удалить записи за этот период',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'Удалить ${num} записей за выбранный период? Действие необратимо.',
			'common.noHistoryRecordsInRange' => 'Нет записей за указанный период',
			'common.followSuccessClickAgainToSpecialFollow' => 'Вы подписались, нажмите еще раз для особой подписки',
			'common.specialFollowTip' => 'Добавлено в особые подписки — доступно в меню справа вверху на странице подписок',
			'common.exitConfirmTip' => 'Вы действительно хотите выйти?',
			'common.error' => 'Ошибка',
			'common.taskRunning' => 'Задача уже выполняется, подождите.',
			'common.operationCancelled' => 'Операция отменена.',
			'common.unsavedChanges' => 'Есть несохраненные изменения',
			'common.specialFollowsManagementTip' => 'Потяните за ручку для перемещения • Нажмите кнопку для удаления',
			'common.specialFollowsManagement' => 'Управление особыми подписками',
			'common.removeSpecialFollow' => 'Удалить особую подписку',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => 'Удалить ${name} из особых подписок?',
			'common.noSpecialFollows' => 'Нет особых подписок',
			'common.createTimeDesc' => 'Сначала новые',
			'common.createTimeAsc' => 'Сначала старые',
			'common.pagination.totalItems' => ({required Object num}) => 'Всего: ${num}',
			'common.pagination.jumpToPage' => 'Перейти на страницу',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Введите номер страницы (1-${max})',
			'common.pagination.pageNumber' => 'Номер страницы',
			'common.pagination.jump' => 'Перейти',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Введите корректный номер страницы (1-${max})',
			'common.pagination.invalidInput' => 'Введите корректный номер страницы',
			'common.pagination.waterfall' => 'Лента',
			'common.pagination.pagination' => 'Страницы',
			'common.notice' => 'Внимание',
			'common.detail' => 'Подробнее',
			'common.parseExceptionDestopHint' => ' - На ПК можно настроить прокси в настройках',
			'common.iwaraTags' => 'Теги Iwara',
			'common.tagInfo' => 'Информация о теге',
			'common.tagOriginalKey' => 'Исходный тег',
			'common.tagTranslation' => 'Перевод',
			'common.copy' => 'Копировать',
			'common.selectCopy' => 'Выбрать и скопировать',
			'common.copiedToClipboard' => 'Скопировано в буфер',
			'common.showOriginalTag' => 'Показать исходный тег',
			'common.showTranslatedTag' => 'Показать перевод',
			'common.tagTranslationFeedback' => 'Неточность в переводе? Отправьте отзыв',
			'common.tagLocalizationGuideTitle' => 'О локализации тегов',
			'common.tagLocalizationGuideContent' => 'Приложение отображает теги Iwara (например, mother) на выбранном вами языке.\n\n• При поиске учитываются как перевод, так и оригинал.\n• Удерживайте или нажмите правой кнопкой мыши по тегу, чтобы скопировать оригинал и перевод.\n• Переводы поддерживаются сообществом и могут содержать неточности.',
			'common.likeThisVideo' => 'Оценить видео',
			'common.likeThisGallery' => 'Оценить галерею',
			'common.operation' => 'Действие',
			'common.replies' => 'Ответы',
			'common.externalLinkWarning' => 'Переход по внешней ссылке',
			'common.externalLinkWarningMessage' => 'Вы переходите по ссылке, не относящейся к iwara.tv. Будьте осторожны и убедитесь в надежности ресурса.',
			'common.continueToExternalLink' => 'Продолжить',
			'common.cancelExternalLink' => 'Отмена',
			'auth.login' => 'Вход',
			'auth.logout' => 'Выход',
			'auth.email' => 'Эл. почта',
			'auth.password' => 'Пароль',
			'auth.loginOrRegister' => 'Вход / Регистрация',
			'auth.register' => 'Регистрация',
			'auth.pleaseEnterEmail' => 'Введите эл. почту',
			'auth.pleaseEnterPassword' => 'Введите пароль',
			'auth.passwordMustBeAtLeast6Characters' => 'Пароль должен содержать не менее 6 символов',
			'auth.pleaseEnterCaptcha' => 'Введите капчу',
			'auth.captcha' => 'Капча',
			'auth.refreshCaptcha' => 'Обновить капчу',
			'auth.captchaNotLoaded' => 'Капча не загружена',
			'auth.loginSuccess' => 'Вход выполнен',
			'auth.loginSuccessProfilePending' => 'Вход выполнен. Загрузка профиля…',
			'auth.emailVerificationSent' => 'Подтверждение отправлено на почту',
			'auth.notLoggedIn' => 'Вы не вошли в аккаунт',
			'auth.clickToLogin' => 'Нажмите для входа',
			'auth.logoutConfirmation' => 'Вы уверены, что хотите выйти из аккаунта?',
			'auth.logoutSuccess' => 'Выход выполнен',
			'auth.logoutFailed' => 'Не удалось выйти',
			'auth.usernameOrEmail' => 'Имя пользователя или эл. почта',
			'auth.pleaseEnterUsernameOrEmail' => 'Введите имя пользователя или эл. почту',
			'auth.rememberMe' => 'Запомнить имя пользователя',
			'auth.registerNoticeTitle' => 'Регистрация на официальном сайте',
			'auth.registerNoticeDescription' => 'Регистрация в приложении недоступна. Создайте аккаунт на официальном сайте Iwara, затем войдите здесь.',
			'auth.registerNoticeReturnTip' => 'После регистрации вернитесь сюда и выполните вход.',
			'auth.goToOfficialWebsite' => 'Перейти на сайт',
			'errors.error' => 'Ошибка',
			'errors.required' => 'Обязательное поле',
			'errors.invalidEmail' => 'Некорректный адрес эл. почты',
			'errors.networkError' => 'Ошибка сети, повторите попытку',
			'errors.errorWhileFetching' => 'Ошибка загрузки',
			'errors.commentCanNotBeEmpty' => 'Комментарий не может быть пустым',
			'errors.errorWhileFetchingReplies' => 'Ошибка загрузки ответов, проверьте подключение к сети',
			'errors.canNotFindCommentController' => 'Не удалось найти контроллер комментариев',
			'errors.errorWhileLoadingGallery' => 'Ошибка загрузки галереи',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'Данных нет? Этого не может быть :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Неподдерживаемый формат изображения: ${str}',
			'errors.invalidGalleryId' => 'Некорректный ID галереи',
			'errors.translationFailedPleaseTryAgainLater' => 'Ошибка перевода, повторите позже',
			'errors.errorOccurred' => 'Произошла ошибка, повторите попытку позже.',
			'errors.errorOccurredWhileProcessingRequest' => 'Произошла ошибка при обработке запроса',
			'errors.errorWhileFetchingDatas' => 'Ошибка при получении данных, повторите позже',
			'errors.serviceNotInitialized' => 'Сервис не инициализирован',
			'errors.unknownType' => 'Неизвестный тип',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Ошибка открытия ссылки: ${link}',
			'errors.invalidUrl' => 'Некорректный URL',
			'errors.failedToOperate' => 'Сбой операции',
			'errors.permissionDenied' => 'Доступ запрещен',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'У вас нет доступа к этому ресурсу',
			'errors.loginFailed' => 'Ошибка входа',
			'errors.unknownError' => 'Неизвестная ошибка',
			'errors.sessionExpired' => 'Сессия истекла',
			'errors.failedToFetchCaptcha' => 'Не удалось получить капчу',
			'errors.emailAlreadyExists' => 'Эл. почта уже используется',
			'errors.invalidCaptcha' => 'Неверная капча',
			'errors.registerFailed' => 'Ошибка регистрации',
			'errors.failedToFetchComments' => 'Не удалось загрузить комментарии',
			'errors.failedToFetchImageDetail' => 'Не удалось загрузить сведения об изображении',
			'errors.failedToFetchImageList' => 'Не удалось загрузить список изображений',
			'errors.failedToFetchData' => 'Не удалось получить данные',
			'errors.invalidParameter' => 'Недопустимый параметр',
			'errors.pleaseLoginFirst' => 'Сначала войдите в систему',
			'errors.errorWhileLoadingPost' => 'Ошибка загрузки публикации',
			'errors.errorWhileLoadingPostDetail' => 'Ошибка загрузки подробностей публикации',
			'errors.invalidPostId' => 'Некорректный ID публикации',
			'errors.forceUpdateNotPermittedToGoBack' => 'Обязательное обновление, вернуться нельзя',
			'errors.pleaseLoginAgain' => 'Пожалуйста, войдите снова',
			'errors.invalidLogin' => 'Ошибка входа. Проверьте эл. почту и пароль',
			'errors.tooManyRequests' => 'Слишком много запросов, повторите попытку позже',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Превышена максимальная длина: ${max}',
			'errors.contentCanNotBeEmpty' => 'Содержимое не может быть пустым',
			'errors.titleCanNotBeEmpty' => 'Заголовок не может быть пустым',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Слишком много запросов, повторите попытку позже, осталось: ',
			'errors.remainingHours' => ({required Object num}) => '${num} ч.',
			'errors.remainingMinutes' => ({required Object num}) => '${num} мин.',
			'errors.remainingSeconds' => ({required Object num}) => '${num} сек.',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Превышен лимит тегов (макс.: ${limit})',
			'errors.failedToRefresh' => 'Не удалось обновить',
			'errors.noPermission' => 'Нет прав',
			'errors.resourceNotFound' => 'Ресурс не найден',
			'errors.failedToSaveCredentials' => 'Не удалось сохранить учетные данные',
			'errors.failedToLoadSavedCredentials' => 'Не удалось загрузить сохраненные учетные данные',
			'errors.notFound' => 'Контент не найден или удален',
			'errors.network.basicPrefix' => 'Ошибка сети — ',
			'errors.network.failedToConnectToServer' => 'Не удалось подключиться к серверу',
			'errors.network.serverNotAvailable' => 'Сервер недоступен',
			'errors.network.requestTimeout' => 'Время ожидания запроса истекло',
			'errors.network.unexpectedError' => 'Непредвиденная ошибка',
			'errors.network.invalidResponse' => 'Некорректный ответ',
			'errors.network.invalidRequest' => 'Некорректный запрос',
			'errors.network.invalidUrl' => 'Некорректный URL',
			'errors.network.invalidMethod' => 'Недопустимый метод',
			'errors.network.invalidHeader' => 'Недопустимый заголовок',
			'errors.network.invalidBody' => 'Недопустимое тело запроса',
			'errors.network.invalidStatusCode' => 'Недопустимый код состояния',
			'errors.network.serverError' => 'Ошибка сервера',
			'errors.network.requestCanceled' => 'Запрос отменен',
			'errors.network.invalidPort' => 'Недопустимый порт',
			'errors.network.proxyPortError' => 'Ошибка порта прокси',
			'errors.network.connectionRefused' => 'В соединении отказано',
			'errors.network.networkUnreachable' => 'Сеть недоступна',
			'errors.network.noRouteToHost' => 'Нет маршрута к хосту',
			'errors.network.connectionFailed' => 'Сбой подключения',
			'errors.network.sslConnectionFailed' => 'Сбой SSL-соединения, проверьте настройки сети',
			'friends.clickToRestoreFriend' => 'Нажмите для восстановления',
			'friends.friendsList' => 'Список друзей',
			'friends.friendRequests' => 'Заявки в друзья',
			'friends.friendRequestsList' => 'Список заявок в друзья',
			'friends.removingFriend' => 'Удаление из друзей...',
			'friends.failedToRemoveFriend' => 'Не удалось удалить из друзей',
			'friends.cancelingRequest' => 'Отмена заявки...',
			'friends.failedToCancelRequest' => 'Не удалось отменить заявку',
			'authorProfile.noMoreDatas' => 'Больше ничего нет',
			'authorProfile.userProfile' => 'Профиль пользователя',
			'favorites.clickToRestoreFavorite' => 'Нажмите для восстановления',
			'favorites.myFavorites' => 'Мое избранное',
			'favorites.batchCancelFavorite' => 'Удалить выбранное из избранного',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'Удалить выбранные элементы (${count}) из избранного? Их можно восстановить нажатием на карточки.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => 'Удалено элементов: ${count}',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => 'Убрано элементов: ${success}, не удалось: ${failed}',
			'galleryDetail.browseInSpace' => 'Просмотр в пространстве',
			'galleryDetail.galleryDetail' => 'Сведения о галерее',
			'galleryDetail.viewGalleryDetail' => 'О галерее',
			'galleryDetail.zoomReset' => 'Сбросить масштаб',
			'galleryDetail.copyLink' => 'Копировать ссылку',
			'galleryDetail.copyImage' => 'Копировать изображение',
			'galleryDetail.saveAs' => 'Сохранить как',
			'galleryDetail.saveToAlbum' => 'Сохранить в альбом',
			'galleryDetail.publishedAt' => 'Опубликовано',
			'galleryDetail.viewsCount' => 'Просмотры',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Возможности галереи',
			'galleryDetail.rightClickToSaveSingleImage' => 'Правый клик для сохранения изображения',
			'galleryDetail.batchSave' => 'Пакетное сохранение',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Стрелки влево/вправо для переключения',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Стрелки вверх/вниз для масштабирования',
			'galleryDetail.mouseWheelToSwitch' => 'Колесико мыши для переключения',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + колесико мыши для зума',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'Больше возможностей впереди...',
			'galleryDetail.authorOtherGalleries' => 'Другие галереи автора',
			'galleryDetail.relatedGalleries' => 'Похожие галереи',
			'galleryDetail.authorNoOtherGalleries' => 'У автора больше нет галерей',
			'galleryDetail.noRelatedGalleries' => 'Нет похожих галерей',
			'galleryDetail.scrollLeft' => 'Прокрутка влево',
			'galleryDetail.scrollRight' => 'Прокрутка вправо',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Нажатие по краям экрана для перелистывания',
			'galleryDetail.rotateToLandscape' => 'В альбомный режим',
			'galleryDetail.backToPortrait' => 'В портретный режим',
			'playList.myPlayList' => 'Мои плейлисты',
			'playList.friendlyTips' => 'Обратите внимание',
			'playList.dearUser' => 'Уважаемый пользователь',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'Система плейлистов Iwara пока несовершенна',
			'playList.notSupportSetCover' => 'Нельзя установить обложку',
			'playList.notSupportDeleteList' => 'Нельзя удалить плейлист',
			'playList.notSupportSetPrivate' => 'Нельзя сделать приватным',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Созданный плейлист останется навсегда и будет виден всем',
			'playList.smallSuggestion' => 'Совет',
			'playList.useLikeToCollectContent' => 'Если вам важна приватность, рекомендуем сохранять через отметку «Нравится»',
			'playList.welcomeToDiscussOnGitHub' => 'Если у вас есть предложения или идеи, присоединяйтесь к обсуждению на GitHub!',
			'playList.iUnderstand' => 'Понятно',
			'playList.searchPlaylists' => 'Поиск плейлистов...',
			'playList.newPlaylistName' => 'Название нового плейлиста',
			'playList.createNewPlaylist' => 'Создать плейлист',
			'playList.videos' => 'Видео',
			'search.googleSearchScope' => 'Область поиска',
			'search.searchTags' => 'Поиск тегов...',
			'search.contentRating' => 'Возрастной рейтинг',
			'search.removeTag' => 'Удалить тег',
			'search.pleaseEnterSearchContent' => 'Введите поисковый запрос',
			'search.exactMatch' => 'Точно',
			'search.exactMatchOnHint' => 'Точное совпадение фразы, дополнительно ищем в китайских и японских заголовках. Нажмите для менее строгого поиска.',
			'search.exactMatchOffHint' => 'Нестрогое совпадение — Iwara разбивает слова. Нажмите для точной фразы.',
			'search.tagExpansion' => 'Искать и по тегу',
			'search.tagExpansionOnHint' => ({required Object tags}) => 'Также ищем по тегу «${tags}» и его японскому/английскому названию — во многих заголовках вашего слова нет.',
			'search.tagExpansionOffHint' => ({required Object tags}) => 'Ищем только ваши слова. Включите, чтобы искать также по тегу «${tags}» и его названиям на других языках.',
			'search.searchHistory' => 'История поиска',
			'search.searchSuggestion' => 'Подсказки поиска',
			'search.usedTimes' => 'Использований',
			'search.lastUsed' => 'Последний раз',
			'search.noSearchHistoryRecords' => 'История поиска пуста',
			'search.clearSearchHistoryConfirm' => 'Очистить всю историю поиска? Действие необратимо.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Тип поиска ${searchType} пока не поддерживается',
			'search.searchResult' => 'Результаты поиска',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Неподдерживаемый тип поиска: ${searchType}',
			'search.googleSearch' => 'Поиск в Google',
			'search.googleSearchHint' => ({required Object webName}) => 'Поиск на ${webName} работает неудобно? Попробуйте Google!',
			'search.googleSearchDescription' => 'Используйте оператор :site в Google для поиска по сайту. Это особенно удобно для видео, галерей, плейлистов и авторов.',
			'search.googleSearchKeywordsHint' => 'Введите ключевые слова для поиска',
			'search.openLinkJump' => 'Переход по ссылке',
			'search.googleSearchButton' => 'Поиск в Google',
			'search.pleaseEnterSearchKeywords' => 'Введите ключевые слова для поиска',
			'search.googleSearchQueryCopied' => 'Поисковый запрос скопирован',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Не удалось открыть браузер: ${error}',
			'search.searchRequestTimeout' => 'Время ожидания истекло, повторите попытку позже',
			'search.searchCannotConnectToServer' => 'Не удалось подключиться к серверу, проверьте сеть',
			'search.searchNetworkError' => 'Ошибка сетевого соединения, проверьте настройки сети',
			'search.searchFailedPleaseRetry' => 'Сбой поиска, повторите попытку позже',
			'mediaList.personalIntroduction' => 'Описание',
			'settings.listViewMode' => 'Режим отображения списка',
			'settings.previewEffect' => 'Эффект предпросмотра',
			'settings.useTraditionalPaginationMode' => 'Классическая пагинация',
			'settings.useTraditionalPaginationModeDesc' => 'Включает страницы вместо бесконечной ленты. Вступает в силу после перезагрузки страницы или перезапуска приложения',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Нижняя полоса прогресса при скрытой панели',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Показывать тонкую полосу прогресса видео внизу экрана, когда элементы управления скрыты.',
			'settings.seekPreviewSize' => 'Размер предпросмотра при перемотке',
			'settings.seekPreviewSizeDesc' => 'Размер окна предпросмотра над шкалой времени. Он уже зависит от размера плеера и пропорций видео; эта настройка лишь корректирует его.',
			'settings.seekPreviewSizeSmall' => 'Маленький',
			'settings.seekPreviewSizeStandard' => 'Стандартный',
			'settings.seekPreviewSizeLarge' => 'Большой',
			'settings.seekPreviewSizeStandardDesc' => 'Размер по умолчанию с учетом плеера и видео',
			'settings.showFullscreenUpNextHint' => 'Ярлык «Далее»',
			'settings.showFullscreenUpNextHintDesc' => 'Показывать ярлык справа в плеере для открытия очереди воспроизведения (источник / плейлист / смотреть позже). Если скрыть, доступ к очереди будет невозможен.',
			'settings.basicSettings' => 'Основные настройки',
			'settings.personalizedSettings' => 'Персонализация',
			'settings.otherSettings' => 'Прочие настройки',
			'settings.searchConfig' => 'Настройки поиска',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Использовать ли предыдущие параметры при повторном воспроизведении видео.',
			'settings.playControl' => 'Управление воспроизведением',
			'settings.playbackSpeedSettings' => 'Скорость воспроизведения',
			'settings.playbackBehaviorSettings' => 'Поведение воспроизведения',
			'settings.enhancementSettings' => 'Кинотеатр и улучшение',
			_ => null,
		} ?? switch (path) {
			'settings.fastForwardTime' => 'Время перемотки вперед',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'Время перемотки должно быть положительным целым числом.',
			'settings.rewindTime' => 'Время перемотки назад',
			'settings.rewindTimeMustBeAPositiveInteger' => 'Время перемотки должно быть положительным целым числом.',
			'settings.longPressPlaybackSpeed' => 'Скорость при долгом нажатии',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'Скорость при долгом нажатии должна быть положительным числом.',
			'settings.defaultPlaybackSpeed' => 'Скорость по умолчанию',
			'settings.rememberPlaybackSpeed' => 'Запоминать скорость воспроизведения',
			'settings.rememberPlaybackSpeedDesc' => 'Скорость, установленная в плеере, будет сохранена по умолчанию и применена к новым видео.',
			'settings.repeat' => 'Повтор',
			'settings.renderVerticalVideoInVerticalScreen' => 'Вертикальные видео в портретном режиме',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Отображать ли вертикальное видео на полный экран в портретной ориентации.',
			'settings.rememberVolume' => 'Запоминать громкость',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Сохранять ли уровень громкости для следующих видео.',
			'settings.rememberBrightness' => 'Запоминать яркость',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Сохранять ли уровень яркости для следующих видео.',
			'settings.playControlArea' => 'Область управления',
			'settings.leftAndRightControlAreaWidth' => 'Ширина боковых областей управления',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Определяет ширину областей управления слева и справа в плеере.',
			'settings.proxyAddressCannotBeEmpty' => 'Адрес прокси не может быть пустым.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Неверный формат адреса прокси. Используйте IP:порт или домен:порт.',
			'settings.proxyNormalWork' => 'Прокси работает нормально.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Проверка прокси не удалась, код состояния: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Проверка прокси не удалась: ${exception}',
			'settings.proxyConfig' => 'Настройки прокси',
			'settings.thisIsHttpProxyAddress' => 'Адрес HTTP-прокси',
			'settings.checkProxy' => 'Проверить прокси',
			'settings.proxyAddress' => 'Адрес прокси',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Введите адрес прокси-сервера, например 127.0.0.1:8080',
			'settings.enableProxy' => 'Включить прокси',
			'settings.left' => 'Слева',
			'settings.middle' => 'По центру',
			'settings.right' => 'Справа',
			'settings.playerSettings' => 'Настройки плеера',
			'settings.networkSettings' => 'Настройки сети',
			'settings.customizeYourPlaybackExperience' => 'Настройте параметры воспроизведения',
			'settings.chooseYourFavoriteAppAppearance' => 'Выберите внешний вид приложения',
			'settings.configureYourProxyServer' => 'Настройка прокси-сервера',
			'settings.settings' => 'Настройки',
			'settings.themeSettings' => 'Тема оформления',
			'settings.followSystem' => 'Как в системе',
			'settings.lightMode' => 'Светлая',
			'settings.darkMode' => 'Темная',
			'settings.presetTheme' => 'Готовые темы',
			'settings.basicTheme' => 'Базовая тема',
			'settings.needRestartToApply' => 'Требуется перезапуск приложения',
			'settings.themeNeedRestartDescription' => 'Для применения настроек темы необходимо перезапустить приложение',
			'settings.about' => 'О приложении',
			'settings.diagnosticsAndFeedback' => 'Диагностика и отзывы',
			'settings.currentVersion' => 'Текущая версия',
			'settings.latestVersion' => 'Последняя версия',
			'settings.checkForUpdates' => 'Проверить обновления',
			'settings.update' => 'Обновить',
			'settings.newVersionAvailable' => 'Доступна новая версия',
			'settings.projectHome' => 'Страница проекта',
			'settings.release' => 'Релизы',
			'settings.issueReport' => 'Сообщить об ошибке',
			'settings.openSourceLicense' => 'Лицензии открытого ПО',
			'settings.checkForUpdatesFailed' => 'Не удалось проверить обновления, повторите позже',
			'settings.autoCheckUpdate' => 'Автопроверка обновлений',
			'settings.updateContent' => 'Что нового',
			'settings.releaseDate' => 'Дата выпуска',
			'settings.ignoreThisVersion' => 'Пропустить эту версию',
			'settings.forceUpdateTip' => 'Это обязательное обновление. Пожалуйста, обновите приложение как можно скорее',
			'settings.viewChangelog' => 'Список изменений',
			'settings.alreadyLatestVersion' => 'У вас последняя версия',
			'settings.appSettings' => 'Настройки приложения',
			'settings.configureYourAppSettings' => 'Основные параметры приложения',
			'settings.history' => 'История',
			'settings.autoRecordHistory' => 'Автосохранение истории',
			'settings.autoRecordHistoryDesc' => 'Автоматически сохранять просмотренные видео и изображения',
			'settings.autoDeleteHistory' => 'Автоочистка истории',
			'settings.autoDeleteHistoryDesc' => 'Автоматически удалять историю старше указанного срока при запуске (по умолч. выкл.)',
			'settings.autoDeleteHistoryDays' => 'Срок хранения',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Хранить последние ${num} дн.',
			'settings.autoDeleteHistoryDaysInvalid' => 'Введите корректное число дней (не менее 1)',
			'settings.showUnprocessedMarkdownText' => 'Исходный текст Markdown',
			'settings.showUnprocessedMarkdownTextDesc' => 'Показывать сырой исходный текст разметки',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Приватный режим',
			'settings.activeBackgroundPrivacyModeDesc' => 'Блокировать скриншоты, запись экрана и скрывать приложение в фоне',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Скрывать экран приложения при переходе в фон (на этой платформе блокировка скриншотов недоступна)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Блокировать скриншоты и запись экрана',
			'settings.privacy' => 'Конфиденциальность',
			'settings.appLock' => 'Блокировка приложения',
			'settings.appLockEnabled' => 'Включить блокировку',
			'settings.appLockEnabledDesc' => 'Запрашивать PIN-код или биометрию при входе; превью в фоне скрывается автоматически',
			'settings.appLockEnabledSummary' => 'Вкл. · Защищено PIN-кодом',
			'settings.appLockDisabledSummary' => 'Выкл.',
			'settings.appLockTimeout' => 'Блокировать после выхода',
			'settings.appLockTimeoutDesc' => 'Время в фоне, после которого требуется повторная авторизация',
			'settings.appLockAfterScreenOff' => 'Блокировать при выключении экрана',
			'settings.appLockAfterScreenOffDesc' => 'Требовать авторизацию после блокировки экрана устройства',
			'settings.appLockTimeoutDisabled' => 'Отключено',
			'settings.appLockImmediately' => 'Немедленно',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} сек.',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} мин.',
			'settings.appLockUseBiometrics' => 'Использовать биометрию',
			'settings.appLockUseBiometricsDesc' => 'Разблокировка по отпечатку пальца или лицу',
			'settings.appLockBiometricsUnavailable' => 'На этом устройстве нет настроенной биометрии',
			'settings.appLockSetPin' => 'Установить PIN-код',
			'settings.appLockEnterPin' => 'Введите PIN-код',
			'settings.appLockConfirmPin' => 'Подтвердите PIN-код',
			'settings.appLockCurrentPin' => 'Введите текущий PIN-код',
			'settings.appLockNewPin' => 'Введите новый PIN-код',
			'settings.appLockPinRequirements' => 'PIN-код должен содержать от 4 до 8 цифр',
			'settings.appLockPinsDoNotMatch' => 'PIN-коды не совпадают',
			'settings.appLockInvalidPin' => 'Неверный PIN-код',
			'settings.appLockSetupFailed' => 'Не удалось безопасно сохранить PIN-код',
			'settings.appLockDisable' => 'Введите PIN-код для отключения блокировки',
			'settings.appLockChangePin' => 'Изменить PIN-код',
			'settings.appLockNow' => 'Заблокировать сейчас',
			'settings.appLockUnlock' => 'Разблокировать',
			'settings.appLockLockedTitle' => 'Заблокировано',
			'settings.appLockLockedDesc' => 'Авторизуйтесь для продолжения',
			'settings.appLockAuthenticateReason' => 'Авторизуйтесь для разблокировки',
			'settings.appLockEnableBiometricsReason' => 'Авторизуйтесь для включения биометрии',
			'settings.appLockBiometricFailed' => 'Сбой биометрической аутентификации',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Слишком много попыток. Повторите через ${seconds} с',
			'settings.appLockCredentialUnavailableTitle' => 'Не удалось прочитать данные блокировки',
			'settings.appLockCredentialUnavailableDesc' => 'Системное хранилище недоступно или данные повреждены. Приложение остается заблокированным. Повторите попытку; если ошибка повторяется, сбросьте блокировку (это отключит ее и сотрет PIN-код).',
			'settings.appLockRetry' => 'Повторить',
			'settings.appLockReset' => 'Сбросить блокировку',
			'settings.appLockResetAction' => 'Сбросить',
			'settings.appLockResetConfirmTitle' => 'Сбросить блокировку приложения?',
			'settings.appLockResetConfirmDesc' => 'Блокировка будет отключена, а сохраненный PIN-код и настройки биометрии — удалены. Вы сможете настроить ее заново.',
			'settings.appLockRetrySucceeded' => 'Данные прочитаны. Введите PIN-код.',
			'settings.appLockRetryFailed' => 'По-прежнему не удается прочитать данные',
			'settings.forum' => 'Форум',
			'settings.news' => 'Новости',
			'settings.community' => 'Сообщество',
			'settings.disableForumReplyQuote' => 'Отключить цитирование в ответах форума',
			'settings.disableForumReplyQuoteDesc' => 'Не добавлять информацию о цитируемом сообщении при ответе на форуме',
			'settings.theaterMode' => 'Режим кинотеатра',
			'settings.theaterModeDesc' => 'Размывать обложку видео в качестве фона плеера',
			'settings.appLinks' => 'Ссылки приложения',
			'settings.defaultBrowser' => 'Открытие ссылок',
			'settings.defaultBrowserDesc' => 'Откройте параметры ссылок по умолчанию в системных настройках и добавьте сайт iwara.tv',
			'settings.themeMode' => 'Режим темы',
			'settings.themeModeDesc' => 'Определяет тему оформления приложения',
			'settings.glassEffect' => 'Стиль интерфейса',
			'settings.glassEffectDesc' => 'Материал элементов интерфейса — заголовков, меню, кнопок и нижней панели',
			'settings.liquidGlassEffect' => 'Жидкое стекло',
			'settings.liquidGlassEffectDesc' => 'Настоящее размытие и преломление. Выглядит красивее всего, но на слабых устройствах может снижать плавность и повышать расход батареи',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Стандартный стиль Material 3 — непрозрачный, без размытия и теней. Максимальная производительность и автономность',
			'settings.glassEffectIntroTitle' => 'Выберите стиль интерфейса',
			'settings.glassEffectIntroContent' => 'Заголовки, панель вкладок и меню используют эффект стекла — настоящее размытие и преломление. Если интерфейс подтормаживает или вы предпочитаете простой стиль, выберите Material (непрозрачные поверхности, без размытия и теней).',
			'settings.glassEffectIntroHint' => 'Вы можете изменить это в любое время: Настройки → Тема → Стиль интерфейса.',
			'settings.glassEffectIntroDone' => 'Оставить',
			'settings.dynamicColor' => 'Динамические цвета',
			'settings.dynamicColorDesc' => 'Определяет, использует ли приложение динамические цвета системы',
			'settings.useDynamicColor' => 'Использовать динамические цвета',
			'settings.useDynamicColorDesc' => 'Использовать палитру системы Material You',
			'settings.presetColors' => 'Предустановленные цвета',
			'settings.customColors' => 'Пользовательские цвета',
			'settings.customColorsDisabledByDynamicColor' => 'Включены динамические цвета. Отключите их для выбора палитры вручную.',
			'settings.pickColor' => 'Выбрать цвет',
			'settings.cancel' => 'Отмена',
			'settings.confirm' => 'Подтвердить',
			'settings.noCustomColors' => 'Нет пользовательских цветов',
			'settings.recordAndRestorePlaybackProgress' => 'Запоминать позицию воспроизведения',
			'settings.autoPlayVideoOnFirstEnter' => 'Автовоспроизведение при открытии',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Запускать воспроизведение автоматически при переходе на страницу видео.',
			'settings.autoEnterFullscreen' => 'Автоматический полноэкранный режим',
			'settings.autoEnterFullscreenDesc' => 'Когда плеер должен автоматически переходить в полноэкранный режим. Приватные, удаленные, внешние видео и режим «картинка в картинке» игнорируются.',
			'settings.autoEnterFullscreenOff' => 'Выкл.',
			'settings.autoEnterFullscreenOffDesc' => 'Никогда не разворачивать автоматически',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'При старте воспроизведения',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Разворачивать сразу при фактическом начале воспроизведения',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'При открытии видео',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Разворачивать сразу при открытии страницы, не дожидаясь воспроизведения',
			'settings.autoEnterFullscreenKind' => 'Тип полноэкранного режима',
			'settings.autoEnterFullscreenKindDesc' => 'Вариант полноэкранного режима (только для ПК).',
			'settings.autoEnterFullscreenKindSystem' => 'Системный полноэкранный',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Разворачивать окно на весь экран средствами системы',
			'settings.autoEnterFullscreenKindApp' => 'Внутри приложения',
			'settings.autoEnterFullscreenKindAppDesc' => 'Окно остается прежним, плеер занимает все окно приложения',
			'settings.signature' => 'Подпись',
			'settings.enableSignature' => 'Включить подпись',
			'settings.enableSignatureDesc' => 'Добавлять ли подпись при публикации ответов',
			'settings.enterSignature' => 'Введите подпись',
			'settings.editSignature' => 'Изменить подпись',
			'settings.signatureContent' => 'Текст подписи',
			'settings.signaturePreview' => 'Предпросмотр',
			'settings.signatureSampleBody' => 'Здесь ваш текст',
			'settings.signatureRegenerate' => 'Обновить',
			'settings.signatureNotSet' => 'Не задано',
			'settings.signatureRuleHint' => 'Подпись добавляется после текста и отделяется горизонтальной линией. Линию добавляет приложение — вам нужно написать только строку ниже.',
			'settings.signatureInsertVariable' => 'Вставить переменную',
			'settings.varDate' => 'Дата',
			'settings.varTime' => 'Время',
			'settings.varDatetime' => 'Дата и время',
			'settings.varWeekday' => 'День недели',
			'settings.varPlatform' => 'Платформа',
			'settings.varPick' => 'Случайная строка',
			'settings.varTitle' => 'Заголовок',
			'settings.varAuthor' => 'Автор',
			'settings.varTags' => 'Теги',
			'settings.varSection' => 'Раздел',
			'settings.varReplyTo' => 'Кому отвечаете',
			'settings.varPlaytime' => 'Позиция воспроизведения',
			'settings.signatureContextGroup' => 'Контекстные переменные',
			'settings.signatureContextHint' => 'Значения берутся со страницы, с которой вы пишете: страница видео знает название, автора, теги и позицию воспроизведения, форум — раздел и номер сообщения. Справа показаны примеры; то, что подставить нельзя, при отправке просто исчезает.',
			'settings.signatureContextValue' => 'Зависит от страницы',
			'settings.varFloor' => 'Номер сообщения',
			'settings.varDuration' => 'Длительность видео',
			'settings.signatureRecipesHint' => 'Не знаете, что написать? Нажмите на любой вариант, возьмите его и поправьте. Ниже показано, как это будет выглядеть на самом деле.',
			'settings.recipeWatchingName' => 'Что смотрю',
			'settings.recipeWatchingTemplate' => 'Смотрю %title% · %date%',
			'settings.recipeTimestampName' => 'Докуда досмотрел',
			'settings.recipeTimestampTemplate' => 'На %playtime% из %duration%',
			'settings.recipeHitokotoName' => 'Цитата дня',
			'settings.recipeHitokotoTemplate' => 'Цитата дня: %hitokoto%',
			'settings.recipeAiName' => 'Пусть напишет ИИ',
			'settings.recipeAiTemplate' => '%ai_hitokoto%',
			'settings.recipeReplyName' => 'Поздороваться в ответе',
			'settings.recipeReplyTemplate' => 'Для %reply_to% · отправлено с %platform%',
			'settings.recipeMoodName' => 'Случайное настроение',
			'settings.recipeMoodTemplate' => 'Настроение: %pick:отличное|так себе|лучше не спрашивать%',
			'settings.signatureRecipesTitle' => 'Примеры',
			'settings.signatureRecipesMore' => 'Ещё примеры',
			'settings.signatureSceneVideo' => 'На странице видео',
			'settings.signatureSceneForum' => 'На форуме',
			'settings.signatureSceneAuthor' => 'В профиле',
			'settings.signatureSceneNone' => 'Без контекста',
			'settings.signatureSceneFromHistory' => 'Пример взят из того, что вы смотрели последним. При реальной отправке используется та страница, где вы находитесь.',
			'settings.signatureSceneFromDemo' => 'Истории пока нет, поэтому показан условный пример. При реальной отправке используется та страница, где вы находитесь.',
			'settings.signatureDemoVideoTitle' => 'Танец в лунном свете',
			'settings.signatureDemoAuthor' => 'Hoshino',
			'settings.signatureDemoTags' => 'mmd 4k 60fps',
			'settings.signatureDemoThreadTitle' => 'Посоветуйте настройки качества',
			'settings.signatureDemoSection' => 'Общий раздел',
			'settings.signatureDemoQuote' => 'Тише едешь — дальше будешь.',
			'settings.signatureDemoAiQuote' => 'Один этот разворот на третьей с половиной минуте уже всё оправдал.',
			'settings.signatureRecipeGroupWatching' => 'Когда смотрите',
			'settings.signatureRecipeGroupReplying' => 'Когда отвечаете',
			'settings.signatureRecipeGroupForum' => 'На форуме',
			'settings.signatureRecipeGroupDaily' => 'Каждый день новая строка',
			'settings.signatureRecipeGroupAi' => 'Пусть напишет ИИ',
			'settings.signaturePromptSampleContext' => 'Этот пробный запуск использует пример контекста страницы видео. При реальной отправке ИИ получает то, что вы смотрите.',
			'settings.recipeAuthorTagsName' => 'Автор и теги',
			'settings.recipeAuthorTagsTemplate' => '%author% · %tags%',
			'settings.recipeFloorName' => 'Ответ на сообщение',
			'settings.recipeFloorTemplate' => 'Из сообщения %floor% · для %reply_to%',
			'settings.recipeSectionName' => 'Указать раздел',
			'settings.recipeSectionTemplate' => 'Из раздела %section%',
			'settings.recipeDailyName' => 'Дата и цитата',
			'settings.recipeDailyTemplate' => '%date% %weekday% · %hitokoto%',
			'settings.signatureSources' => 'Источники данных',
			'settings.signatureAutoTranslate' => 'Переводить на мой язык',
			'settings.signatureAutoTranslateDesc' => 'Источники вроде Hitokoto пока отдают только китайский. Фраза переводится прямо перед отправкой.',
			'settings.signatureWizardTitle' => 'Добавить источник',
			'settings.signatureWizardUrlTitle' => 'Адрес запроса',
			'settings.signatureWizardUrlHint' => 'Укажите адрес, который возвращает строку текста. Кнопка ниже действительно обратится к нему, чтобы вы увидели ответ.',
			'settings.signatureWizardFetch' => 'Запросить',
			'settings.signatureWizardSkipTest' => 'Пропустить и только переименовать',
			'settings.signatureWizardPickTitle' => 'Выберите нужную часть',
			'settings.signatureWizardPickHint' => 'Вот что вернул этот адрес. Нажмите строку, которую должна показывать подпись.',
			'settings.signatureWizardPickPlainHint' => 'Ответ пришёл обычным текстом — он и будет показан целиком.',
			'settings.signatureWizardWholeBody' => 'Весь ответ',
			'settings.signatureWizardNameTitle' => 'Дайте ему имя',
			'settings.signatureWizardNameHint' => 'Имя нужно только вам. Подпись обращается к источнику по имени для ссылки ниже.',
			'settings.signatureWizardNext' => 'Далее',
			'settings.signatureWizardDone' => 'Готово',
			'settings.signatureWizardStripHtml' => 'Убрать HTML-теги',
			'settings.signatureWizardAdvanced' => 'Дополнительно: вытащить по шаблону',
			'settings.signatureWizardExtractHint' => 'Регулярное выражение; берётся первая группа',
			'settings.signatureWizardExtractMissed' => 'Шаблон ничего не нашёл — текст остался как есть',
			'settings.signatureWizardChooseTitle' => 'Выберите источник',
			'settings.signatureWizardChooseHint' => 'Нажмите на готовый — и всё. Либо укажите свой адрес.',
			'settings.signatureWizardCustomSource' => 'Свой адрес',
			'settings.signatureWizardWithOrigin' => 'Показывать источник цитаты',
			'settings.signatureWizardRandomItem' => 'Каждый раз брать другую',
			'settings.signatureWizardSuffixTitle' => 'Добавить ещё одно поле',
			'settings.signatureWizardSuffixNone' => 'Ничего',
			'settings.signatureOptFlavor' => 'Содержание',
			'settings.signatureOptFlavorAny' => 'Без ограничений',
			'settings.signatureOptFlavorOtaku' => 'Аниме, манга и игры',
			'settings.signatureOptFlavorLiterary' => 'Литература и поэзия',
			'settings.signatureOptFlavorMeme' => 'Интернет-культура',
			'settings.signatureOptLength' => 'Длина',
			'settings.signatureOptLengthAny' => 'Без ограничений',
			'settings.signatureOptLengthShort' => 'Только короткие',
			'settings.signatureRestoreDefault' => 'Вернуть по умолчанию',
			'settings.signatureSourceHitokoto' => 'Hitokoto (случайная цитата)',
			'settings.signatureAiSourceName' => 'Фраза от ИИ',
			'settings.signatureEditTextHint' => 'Это подпись, уже записанная в этот комментарий: фраза и дата теперь просто текст, правьте как угодно. Очистите поле, чтобы убрать подпись.',
			'settings.signatureResolving' => ({required Object name}) => 'Создаём ${name}…',
			'settings.signaturePendingValue' => '(создаётся при отправке)',
			'settings.signatureAiHint' => 'Фраза, которую ИИ пишет на месте — своя для каждого комментария, через настроенного вами провайдера. На страницах видео, галереи и форума он ещё и знает, что вы сейчас смотрите, и может написать об этом.',
			'settings.signatureAiUnavailable' => 'Провайдер ИИ ещё не настроен, поэтому этот источник не показывается в панели переменных.',
			'settings.signaturePromptTitle' => 'Промпт',
			'settings.signaturePromptHint' => 'Именно это уходит модели. Перепишите как угодно: тон, длину, тему. Правила, которые уже есть, стоит оставить.',
			'settings.signaturePromptReset' => 'Сбросить по умолчанию',
			'settings.signaturePromptTry' => 'Попробовать',
			'settings.signaturePromptSample' => 'Что получилось',
			'settings.signaturePromptLanguageHint' => 'заменяется языком интерфейса. Без него строка пойдёт на языке промпта.',
			'settings.signaturePromptEdited' => 'изменён',
			'settings.signatureVariablesGroup' => 'Встроенные переменные',
			'settings.signatureNeedsNetwork' => 'Нужна сеть',
			'settings.signatureBuiltinSource' => 'Встроенный',
			'settings.signatureSourceIdReserved' => 'Это имя занято встроенной переменной',
			'settings.signatureSourcesTitle' => 'Свои источники данных',
			'settings.signatureSourcesHint' => 'Укажите адрес, который возвращает строку текста, и её можно будет подставлять в подпись.',
			'settings.signatureSourcesEmpty' => 'Источников пока нет',
			'settings.signatureAddSource' => 'Добавить',
			'settings.signatureEditSource' => 'Изменить источник',
			'settings.signatureSourceName' => 'Название',
			'settings.signatureSourceId' => 'Имя для ссылки',
			'settings.signatureSourceIdHint' => 'Под этим именем подпись обращается к источнику',
			'settings.signatureSourceUrl' => 'Адрес запроса',
			'settings.signatureSourcePath' => 'Путь к значению',
			'settings.signatureSourcePathHint' => 'Оставьте пустым, если весь ответ — это текст. Укажите data.text, чтобы взять это поле из JSON.',
			'settings.signatureSourceTest' => 'Проверить',
			'settings.signatureSourceTestOk' => 'Получилось',
			'settings.signatureSourceTestFailed' => 'Ничего не пришло',
			'settings.signatureSourceIdInvalid' => 'В имени для ссылки допустимы только строчные буквы, цифры и подчёркивания',
			'settings.signatureSourceIdDuplicate' => 'Такое имя уже занято',
			'settings.signatureSourceUrlRequired' => 'Укажите адрес запроса',
			'settings.exportConfig' => 'Экспорт конфигурации',
			'settings.exportConfigDesc' => 'Экспорт настроек и истории (просмотры, позиция воспроизведения, избранное) в файл для резервного копирования или переноса. Загрузки не включаются.',
			'settings.importConfig' => 'Импорт конфигурации',
			'settings.importConfigDesc' => 'Импорт конфигурации приложения из файла',
			'settings.exportConfigSuccess' => 'Конфигурация успешно экспортирована!',
			'settings.exportConfigFailed' => 'Не удалось экспортировать конфигурацию',
			'settings.importConfigSuccess' => 'Конфигурация успешно импортирована!',
			'settings.importConfigFailed' => 'Не удалось импортировать конфигурацию',
			'settings.exportIncludeSensitive' => 'Включать конфиденциальные данные',
			'settings.exportIncludeSensitiveDesc' => 'Включает ключи API, токены сессий и адрес прокси. Включайте только для личных резервных копий.',
			'settings.importConfigOverwriteWarning' => 'Импорт перезапишет текущие настройки и историю (просмотры, прогресс, избранное). Продолжить?',
			'settings.importConfigRestartTitle' => 'Импорт выполнен',
			'settings.importConfigRestartContent' => 'Конфигурация импортирована. Полностью закройте и перезапустите приложение для применения изменений.',
			'settings.historyUpdateLogs' => 'История обновлений',
			'settings.noUpdateLogs' => 'Нет истории обновлений',
			'settings.versionLabel' => 'Версия: {version}',
			'settings.releaseDateLabel' => 'Дата выпуска: {date}',
			'settings.noChanges' => 'Нет описания изменений',
			'settings.interaction' => 'Взаимодействие',
			'settings.enableVibration' => 'Виброотклик',
			'settings.enableVibrationDesc' => 'Тактильный отклик при взаимодействии с приложением',
			'settings.defaultKeepVideoToolbarVisible' => 'Не скрывать панель управления видео',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Панель управления видео остается видимой при первом открытии страницы видео.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Режим кинотеатра на мобильных устройствах может вызывать просадку производительности. Включайте на свое усмотрение.',
			'settings.fullscreenOrientation' => 'Ориентация при переходе в полный экран',
			'settings.fullscreenOrientationDesc' => 'Ориентация экрана по умолчанию при разворачивании на весь экран (только для мобильных)',
			'settings.fullscreenOrientationLeftLandscape' => 'Альбомная влево',
			'settings.fullscreenOrientationRightLandscape' => 'Альбомная вправо',
			'settings.screenFit' => 'Масштаб видео',
			'settings.screenFitDesc' => 'Как видео заполняет область плеера.',
			'settings.rememberScreenFit' => 'Запоминать масштаб видео',
			'settings.rememberScreenFitDesc' => 'Применять выбранный масштаб к открываемым видео.',
			'settings.screenFitFit' => 'По размеру',
			'settings.screenFitFitDesc' => 'Поместить в экран с сохранением пропорций',
			'settings.screenFitStretch' => 'Растянуть',
			'settings.screenFitStretchDesc' => 'Заполнить область плеера с возможным искажением пропорций',
			'settings.screenFitCover' => 'Заполнить',
			'settings.screenFitCoverDesc' => 'Заполнить экран с сохранением пропорций и обрезкой краев',
			'settings.screenFitRatioDesc' => 'Принудительное соотношение сторон с возможным искажением',
			'settings.jumpLink' => 'Быстрый переход',
			'settings.language' => 'Язык',
			'settings.languageNativeName' => 'Русский',
			'settings.followSystemLanguage' => 'Как в системе',
			'settings.languageChangedMessage' => 'Язык изменён. Некоторые функции вступят в силу после перезапуска приложения.',
			'settings.languageChanged' => 'Язык изменен, перезапустите приложение для применения.',
			'settings.keybinding.title' => 'Горячие клавиши',
			'settings.keybinding.entryLabel' => 'Горячие клавиши',
			'settings.keybinding.entryDesc' => 'Настройка сочетаний клавиш (в основном для ПК)',
			'settings.keybinding.desktopHint' => 'Сочетания клавиш работают на клавиатуре ПК; на мобильных используются жесты.',
			'settings.keybinding.resetAll' => 'Сбросить все по умолчанию',
			'settings.keybinding.resetAllConfirm' => 'Сбросить все горячие клавиши к значениям по умолчанию?',
			'settings.keybinding.resetToDefault' => 'По умолчанию',
			'settings.keybinding.resetScope' => 'Сбросить этот раздел',
			'settings.keybinding.notSet' => 'Не назначено',
			'settings.keybinding.addShortcut' => 'Добавить клавишу',
			'settings.keybinding.removeShortcut' => 'Удалить это сочетание',
			'settings.keybinding.pressNewShortcut' => 'Нажмите новую клавишу…',
			'settings.keybinding.recordingCancelHint' => 'Нажмите Esc для отмены',
			'settings.keybinding.mouseHint' => 'Можно использовать боковые кнопки мыши (назад / вперед) или колесико',
			'settings.keybinding.mouseNotSupportedInScope' => 'В этой области кнопки мыши не поддерживаются, используйте клавиатуру',
			'settings.keybinding.capabilityKeyboardOnly' => 'Только клавиши клавиатуры',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Клавиатура, а также средняя и боковые кнопки мыши',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Клавиатура, средняя и кнопка «вперед» мыши (кнопка «назад» занята системой)',
			'settings.keybinding.rejectMultipleButtons' => 'Нажимайте по одной кнопке мыши',
			'settings.keybinding.rejectPlatformBack' => 'Эта кнопка уже зарезервирована системой для «Назад»',
			'settings.keybinding.detectedLabel' => 'Обнаружено',
			'settings.keybinding.reservedKey' => 'Эта клавиша зарезервирована системой и не может быть назначена',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Эта клавиша назначена на «${action}» и зарезервирована для выхода из этого экрана',
			'settings.keybinding.conflictTitle' => 'Конфликт клавиш',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Это сочетание уже назначено на «${action}». Назначение удалит старую привязку.',
			'settings.keybinding.conflictContinue' => 'Все равно назначить',
			'settings.keybinding.shadowWarningTitle' => 'Перекрытие глобальной клавиши',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Это сочетание глобально назначено на «${action}». Назначение здесь переопределит его только в этом разделе.',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'Это сочетание уже назначено на «${action}» в ${scope}. В этом разделе глобальная клавиша будет переопределена.',
			'settings.keybinding.searchHint' => 'Поиск сочетаний…',
			'settings.keybinding.scopeGlobal' => 'Глобальные',
			'settings.keybinding.scopeGallery' => 'Галерея',
			'settings.keybinding.scopeVideo' => 'Видео',
			'settings.keybinding.categoryNavigation' => 'Навигация',
			'settings.keybinding.categoryZoom' => 'Масштабирование',
			'settings.keybinding.categoryPlayback' => 'Воспроизведение',
			'settings.keybinding.categorySeek' => 'Перемотка',
			'settings.keybinding.categoryVolume' => 'Громкость',
			'settings.keybinding.categoryDisplay' => 'Отображение',
			'settings.keybinding.actionGlobalBack' => 'Назад',
			'settings.keybinding.actionGalleryNext' => 'Следующее фото',
			'settings.keybinding.actionGalleryPrevious' => 'Предыдущее фото',
			'settings.keybinding.actionGalleryZoomIn' => 'Приблизить',
			'settings.keybinding.actionGalleryZoomOut' => 'Отдалить',
			'settings.keybinding.actionGalleryResetZoom' => 'Сбросить масштаб',
			'settings.keybinding.actionGalleryPlayPause' => 'Воспроизведение / Пауза',
			'settings.keybinding.actionGallerySeekBackward' => 'Назад',
			'settings.keybinding.actionGallerySeekForward' => 'Вперед',
			'settings.keybinding.actionGalleryToggleMute' => 'Вкл./Выкл. звук',
			'settings.keybinding.actionPlayPause' => 'Воспроизведение / Пауза',
			'settings.keybinding.actionSpeedUp' => 'Увеличить скорость',
			'settings.keybinding.actionSpeedDown' => 'Уменьшить скорость',
			'settings.keybinding.actionSeekForward' => 'Вперед',
			'settings.keybinding.actionSeekBackward' => 'Назад',
			'settings.keybinding.actionVolumeUp' => 'Громче',
			'settings.keybinding.actionVolumeDown' => 'Тише',
			'settings.keybinding.actionToggleMute' => 'Вкл./Выкл. звук',
			'settings.keybinding.actionToggleFullscreen' => 'Полный экран',
			'settings.keybinding.seekLongPressHint' => 'Удерживайте клавишу перемотки для ускорения',
			'settings.keybinding.zoomSectionTitle' => 'Масштаб изображения (фиксировано)',
			'settings.keybinding.zoomFixedNote' => 'Сочетания ниже фиксированы и не могут быть изменены',
			'settings.keybinding.zoomScaleLabel' => 'Масштаб изображения',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + колесико',
			'settings.keybinding.zoomRotateLabel' => 'Поворот изображения',
			'settings.keybinding.zoomRotateHint' => 'Shift + колесико',
			'settings.keybinding.zoomPinchGesture' => 'Сведение пальцев',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Поворот двумя пальцами',
			'settings.gestureControl' => 'Управление жестами',
			'settings.leftDoubleTapRewind' => 'Двойное нажатие слева: перемотка назад',
			'settings.rightDoubleTapFastForward' => 'Двойное нажатие справа: перемотка вперед',
			'settings.doubleTapPause' => 'Двойное нажатие: пауза',
			'settings.rightVerticalSwipeVolume' => 'Смахивание справа по вертикали: громкость (при входе на новую страницу)',
			'settings.leftVerticalSwipeBrightness' => 'Смахивание слева по вертикали: яркость (при входе на новую страницу)',
			'settings.longPressFastForward' => 'Долгое нажатие: ускорение',
			'settings.enableMouseHoverShowToolbar' => 'Показывать панель при наведении мыши',
			'settings.enableMouseHoverShowToolbarInfo' => 'Панель управления видео появляется при наведении курсора и скрывается через 3 секунды бездействия.',
			'settings.enableHorizontalDragSeek' => 'Горизонтальный жест: перемотка',
			'settings.enableVideoGestureZoom' => 'Масштабирование кадра жестом',
			'settings.enableVideoGestureZoomInfo' => 'Сведите/разведите пальцы (или Ctrl + колесико мыши на ПК) для масштабирования кадра видео, затем перетаскивайте для перемещения.',
			'settings.showCenterPlayPauseButton' => 'Кнопка воспроизведения по центру',
			'settings.showCenterPlayPauseButtonDesc' => 'Показывать крупную кнопку воспроизведения/паузы в центре плеера.',
			'settings.audioVideoConfig' => 'Аудио и видео',
			'settings.expandBuffer' => 'Увеличенный буфер',
			'settings.expandBufferInfo' => 'Увеличивает размер буфера: загрузка длится дольше, но воспроизведение плавнее',
			'settings.videoSyncMode' => 'Режим синхронизации видео',
			'settings.videoSyncModeSubtitle' => 'Стратегия синхронизации звука и видео',
			'settings.hardwareDecodingMode' => 'Режим аппаратного декодирования',
			'settings.hardwareDecodingModeSubtitle' => 'Настройки аппаратного декодирования',
			'settings.enableHardwareAcceleration' => 'Аппаратное ускорение',
			'settings.enableHardwareAccelerationInfo' => 'Включение аппаратного ускорения может улучшить декодирование, но поддерживается не всеми устройствами',
			'settings.useOpenSLESAudioOutput' => 'Использовать вывод OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'Низкая задержка звука, может улучшить воспроизведение аудио',
			'settings.videoSyncAudio' => 'По звуку',
			'settings.videoSyncDisplayResample' => 'Передискретизация дисплея',
			'settings.videoSyncDisplayResampleVdrop' => 'Передискретизация (пропуск видеокадров)',
			'settings.videoSyncDisplayResampleDesync' => 'Передискретизация (рассинхрон)',
			'settings.videoSyncDisplayTempo' => 'Скорость дисплея',
			'settings.videoSyncDisplayVdrop' => 'Пропуск видеокадров',
			'settings.videoSyncDisplayAdrop' => 'Пропуск аудиокадров',
			'settings.videoSyncDisplayDesync' => 'Рассинхрон дисплея',
			'settings.videoSyncDesync' => 'Без синхронизации',
			'settings.forumSettings.name' => 'Форум',
			'settings.forumSettings.configureYourForumSettings' => 'Настройки форума',
			'settings.gallerySettings.gallerySettingsTitle' => 'Настройки галереи',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Параметры просмотра изображений',
			'settings.gallerySettings.defaultViewerQuality' => 'Качество при открытии',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Качество изображений по умолчанию при открытии галереи.',
			'settings.blockSettings.title' => 'Блокировка контента',
			'settings.blockSettings.subtitle' => 'Автоматически скрывать видео и галереи по ключевым словам в заголовке или от заблокированных авторов. Фильтрация работает локально на устройстве.',
			'settings.blockSettings.blocked' => 'Заблокировано',
			'settings.blockSettings.reveal' => 'Показать',
			'settings.blockSettings.reblock' => 'Заблокировать снова',
			'settings.blockSettings.why' => 'Причина?',
			'settings.blockSettings.manageRules' => 'Управление правилами',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'Заголовок содержит «${value}»',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'Заголовок соответствует «${value}»',
			'settings.blockSettings.reasonUser' => 'От заблокированного автора',
			'settings.blockSettings.addRule' => 'Добавить правило',
			'settings.blockSettings.editRule' => 'Изменить правило',
			'settings.blockSettings.deleteRule' => 'Удалить правило',
			'settings.blockSettings.ruleType' => 'Тип правила',
			'settings.blockSettings.keyword' => 'Ключевое слово',
			'settings.blockSettings.regex' => 'Регулярное выражение',
			'settings.blockSettings.userId' => 'Пользователь',
			'settings.blockSettings.value' => 'Текст для совпадения',
			'settings.blockSettings.caseSensitive' => 'С учетом регистра',
			'settings.blockSettings.regexHint' => 'напр. trailer|teaser',
			'settings.blockSettings.valueRequired' => 'Введите текст правила',
			'settings.blockSettings.invalidRegex' => 'Некорректное регулярное выражение',
			'settings.blockSettings.noRules' => 'Нет правил. Нажмите +, чтобы добавить.',
			'settings.blockSettings.blockUser' => 'Заблокировать',
			'settings.blockSettings.unblockUser' => 'Разблокировать',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => 'Заблокировать «${name}»? Публикации автора будут скрыты из списков и поиска.',
			'settings.blockSettings.userBlocked' => 'Пользователь заблокирован',
			'settings.blockSettings.userUnblocked' => 'Пользователь разблокирован',
			'settings.blockSettings.exportRules' => 'Экспорт',
			'settings.blockSettings.importRules' => 'Импорт',
			'settings.blockSettings.importExport' => 'Импорт / Экспорт',
			'settings.blockSettings.exportSuccess' => 'Правила экспортированы',
			'settings.blockSettings.exportFailed' => 'Не удалось экспортировать правила',
			'settings.blockSettings.importSuccess' => ({required Object count}) => 'Импортировано правил: ${count}',
			'settings.blockSettings.importFailed' => 'Не удалось импортировать правила',
			'settings.blockSettings.regexHelp' => 'Справка по шаблонам',
			'settings.blockSettings.regexHelpTitle' => 'Справка по Regex',
			'settings.blockSettings.regexHelpIntro' => 'Регулярные выражения позволяют фильтровать точнее обычных слов. Примеры:',
			'settings.blockSettings.regexHelpTapHint' => 'Нажмите на пример, чтобы вставить его.',
			'settings.blockSettings.regexEx1Pattern' => 'трейлер|тизер|бонус',
			_ => null,
		} ?? switch (path) {
			'settings.blockSettings.regexEx1Desc' => 'Любое из этих слов («|» означает «или»)',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Заголовки, начинающиеся с [скобок]',
			'settings.blockSettings.regexEx3Pattern' => 'Коллекция\$',
			'settings.blockSettings.regexEx3Desc' => 'Заголовки, заканчивающиеся на «Коллекция»',
			'settings.blockSettings.regexEx4Pattern' => 'Эп.[0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ — одна или более цифр (находит «Эп.12»)',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '\\d — цифра, {4} — четыре подряд (например, год)',
			'settings.blockSettings.regexEx1Sample' => 'Тизер новой игры уже вышел',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Полный фильм',
			'settings.blockSettings.regexEx3Sample' => 'Весенняя коллекция арта',
			'settings.blockSettings.regexEx4Sample' => 'Обзор Эп.12 моего шоу',
			'settings.blockSettings.regexEx5Sample' => 'Лучшее из 2024 года',
			'settings.blockSettings.regexHelpSampleLabel' => 'Пример заголовка',
			'settings.blockSettings.regexHelpMatchedTag' => 'Заблокировано',
			'settings.blockSettings.regexHelpNoMatch' => 'Нет совпадений',
			'settings.blockSettings.regexEx6Pattern' => '[Сс]езон',
			'settings.blockSettings.regexEx6Desc' => '[Сс] — заглавная или строчная «С» (находит «Сезон»)',
			'settings.blockSettings.regexEx6Sample' => 'Трейлер финального сезона',
			'settings.blockSettings.regexEx7Pattern' => '(фильм|сериал)',
			'settings.blockSettings.regexEx7Desc' => 'Круглые скобки () группируют варианты: «фильм» или «сериал»',
			'settings.blockSettings.regexEx7Sample' => 'Смотрите сериал сейчас',
			'settings.blockSettings.regexEx8Pattern' => 'сезон[ыа]?',
			'settings.blockSettings.regexEx8Desc' => '«?» делает предыдущий символ необязательным: «сезон» и «сезоны»',
			'settings.blockSettings.regexEx8Sample' => 'Набор из двух сезонов',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ означает один или более символов: !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'Ого!!! Обязательно к просмотру',
			'settings.blockSettings.regexEx10Pattern' => 'бонус.*сцен',
			'settings.blockSettings.regexEx10Desc' => '«.*» означает любые символы между ними: «бонус … сцен»',
			'settings.blockSettings.regexEx10Sample' => 'Удалённая бонусная сцена',
			'settings.chatSettings.name' => 'Чат',
			'settings.chatSettings.configureYourChatSettings' => 'Настройки чата',
			'settings.hardwareDecodingAuto' => 'Авто',
			'settings.hardwareDecodingAutoCopy' => 'Авто-копирование',
			'settings.hardwareDecodingAutoSafe' => 'Безопасное авто',
			'settings.hardwareDecodingNo' => 'Отключено',
			'settings.hardwareDecodingYes' => 'Принудительно',
			'settings.cdnDistributionStrategy' => 'Распределение CDN',
			'settings.cdnDistributionStrategyDesc' => 'Выбор стратегии распределения серверов для ускорения загрузки видео',
			'settings.cdnDistributionStrategyLabel' => 'Стратегия распределения',
			'settings.cdnDistributionStrategyNoChange' => 'Без изменений (исходный сервер)',
			'settings.cdnDistributionStrategyAuto' => 'Автоматически (самый быстрый)',
			'settings.cdnDistributionStrategySpecial' => 'Выбрать сервер вручную',
			'settings.cdnSpecialServer' => 'Выбрать сервер',
			'settings.cdnRefreshServerListHint' => 'Нажмите кнопку ниже для обновления списка серверов',
			'settings.cdnRefreshButton' => 'Обновить',
			'settings.cdnFastRingServers' => 'Быстрые серверы Fast Ring',
			'settings.cdnRefreshServerListTooltip' => 'Обновить список серверов',
			'settings.cdnSpeedTestButton' => 'Проверка скорости',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Проверка (${count})',
			'settings.cdnNoServerDataHint' => 'Нет данных о серверах, нажмите кнопку обновления',
			'settings.cdnTestingStatus' => 'Проверка',
			'settings.cdnUnreachableStatus' => 'Недоступен',
			'settings.cdnNotTestedStatus' => 'Не проверен',
			'settings.downloadSettings.downloadSettings' => 'Настройки загрузки',
			'settings.downloadSettings.enableDownloadNotifications' => 'Уведомления о загрузках',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Показывать системное уведомление при завершении или ошибке загрузки',
			'settings.downloadSettings.notificationPermissionDenied' => 'Нет разрешения на уведомления. Внутри приложения они работают; системные можно включить в настройках.',
			'settings.downloadSettings.storagePermissionStatus' => 'Доступ к памяти',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Для общедоступных папок требуется разрешение на доступ к памяти',
			'settings.downloadSettings.checkingPermissionStatus' => 'Проверка разрешений...',
			'settings.downloadSettings.storagePermissionGranted' => 'Доступ к памяти предоставлен',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Доступ к памяти не предоставлен',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Разрешение успешно предоставлено',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Не удалось предоставить разрешение, некоторые функции могут быть ограничены',
			'settings.downloadSettings.storagePermissionRationale' => 'Для сохранения в выбранную папку приложению нужен доступ к памяти.\n\nНа Android 11+ требуется «Доступ ко всем файлам»; без него файлы сохраняются в изолированную папку приложения.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Для сохранения в выбранную папку приложению нужен доступ к памяти.\n\nБез него файлы сохраняются в изолированную папку приложения.',
			'settings.downloadSettings.grantStoragePermission' => 'Предоставить доступ',
			'settings.downloadSettings.customDownloadPath' => 'Пользовательская папка загрузки',
			'settings.downloadSettings.customDownloadPathDescription' => 'Возможность выбрать свое место для сохранения файлов',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Совет: Для общедоступных папок (например, Загрузки) нужно разрешение; рекомендуется использовать стандартные пути',
			'settings.downloadSettings.androidWarning' => 'Примечание для Android: Общедоступные папки (например, Downloads) требуют спецразрешений; лучше использовать папки приложения.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Внимание: Выбрана общая папка, требуется доступ к памяти для скачивания файлов',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Требуется доступ к памяти для общих папок',
			'settings.downloadSettings.currentDownloadPath' => 'Текущая папка загрузки',
			'settings.downloadSettings.actualDownloadPath' => 'Фактический путь',
			'settings.downloadSettings.defaultAppDirectory' => 'Папка приложения по умолчанию',
			'settings.downloadSettings.permissionGranted' => 'Предоставлено',
			'settings.downloadSettings.permissionRequired' => 'Требуется разрешение',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Свой путь загрузки',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Использовать путь по умолчанию',
			'settings.downloadSettings.customDownloadPathLabel' => 'Пользовательский путь',
			'settings.downloadSettings.selectDownloadFolder' => 'Выбрать папку загрузки',
			'settings.downloadSettings.recommendedPath' => 'Рекомендуемый путь',
			'settings.downloadSettings.selectFolder' => 'Выбрать папку',
			'settings.downloadSettings.filenameTemplate' => 'Шаблон имени файла',
			'settings.downloadSettings.filenameTemplateDescription' => 'Правило именования скачиваемых файлов с поддержкой переменных',
			'settings.downloadSettings.videoFilenameTemplate' => 'Шаблон имени видео',
			'settings.downloadSettings.galleryFolderTemplate' => 'Шаблон папки галереи',
			'settings.downloadSettings.imageFilenameTemplate' => 'Шаблон имени изображения',
			'settings.downloadSettings.resetToDefault' => 'По умолчанию',
			'settings.downloadSettings.supportedVariables' => 'Доступные переменные',
			'settings.downloadSettings.supportedVariablesDescription' => 'В шаблонах имен можно использовать следующие переменные:',
			'settings.downloadSettings.copyVariable' => 'Копировать переменную',
			'settings.downloadSettings.variableCopied' => 'Переменная скопирована',
			'settings.downloadSettings.warningPublicDirectory' => 'Внимание: Выбранная общая папка может быть недоступна. Рекомендуется выбрать папку приложения.',
			'settings.downloadSettings.downloadPathUpdated' => 'Путь загрузки обновлен',
			'settings.downloadSettings.selectPathFailed' => 'Не удалось выбрать путь',
			'settings.downloadSettings.pickerAlreadyActive' => 'Выбор папки уже открыт',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Неподдерживаемый накопитель. Выберите папку на внутреннем накопителе или SD-карте.',
			'settings.downloadSettings.recommendedPathSet' => 'Установлен рекомендуемый путь',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Не удалось установить рекомендуемый путь',
			'settings.downloadSettings.templateResetToDefault' => 'Сброшено к шаблону по умолчанию',
			'settings.downloadSettings.functionalTest' => 'Проверка функций',
			'settings.downloadSettings.testInProgress' => 'Проверка...',
			'settings.downloadSettings.runTest' => 'Запустить тест',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Проверка пути загрузки и корректности разрешений',
			'settings.downloadSettings.testResults' => 'Результаты теста',
			'settings.downloadSettings.testCompleted' => 'Проверка завершена',
			'settings.downloadSettings.testMultisegmentDomain' => 'Проверка домена значений (многосегментность / превышение / формы обхода)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Рендер многосегментной структуры (issue #126)',
			'settings.downloadSettings.testPassed' => 'успешно',
			'settings.downloadSettings.testFailed' => 'Тест не пройден',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Проверка доступа к памяти',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Доступ к памяти предоставлен',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Доступ к памяти отсутствует, функции могут быть ограничены',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Ошибка проверки разрешений',
			'settings.downloadSettings.testDownloadPathValidation' => 'Проверка пути загрузки',
			'settings.downloadSettings.testPathValidationFailed' => 'Ошибка проверки пути',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Проверка шаблона имени',
			'settings.downloadSettings.testAllTemplatesValid' => 'Все шаблоны корректны',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'В шаблонах есть недопустимые символы',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Ошибка проверки шаблона',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Проверка операций с папками',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'Создание папок и запись файлов работают штатно',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Ошибка работы с папкой',
			'settings.downloadSettings.testVideoTemplate' => 'Шаблон видео',
			'settings.downloadSettings.testGalleryTemplate' => 'Шаблон галереи',
			'settings.downloadSettings.testImageTemplate' => 'Шаблон изображения',
			'settings.downloadSettings.testValid' => 'Корректно',
			'settings.downloadSettings.testInvalid' => 'Некорректно',
			'settings.downloadSettings.testSuccess' => 'Успешно',
			'settings.downloadSettings.testCorrect' => 'Правильно',
			'settings.downloadSettings.testError' => 'Ошибка',
			'settings.downloadSettings.testPath' => 'Тестовый путь',
			'settings.downloadSettings.testBasePath' => 'Базовый путь',
			'settings.downloadSettings.testDirectoryCreation' => 'Создание папки',
			'settings.downloadSettings.testFileWriting' => 'Запись файла',
			'settings.downloadSettings.testFileContent' => 'Содержимое файла',
			'settings.downloadSettings.checkingPathStatus' => 'Проверка статуса пути...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Не удалось получить статус пути',
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Примечание: Фактический путь отличается от выбранного',
			'settings.downloadSettings.grantPermission' => 'Предоставить разрешение',
			'settings.downloadSettings.fixIssue' => 'Исправить',
			'settings.downloadSettings.issueFixed' => 'Исправлено',
			'settings.downloadSettings.fixFailed' => 'Не удалось исправить, настройте вручную',
			'settings.downloadSettings.lackStoragePermission' => 'Нет доступа к памяти',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Нет доступа к общей папке, требуется «Доступ ко всем файлам»',
			'settings.downloadSettings.cannotCreateDirectory' => 'Не удалось создать папку',
			'settings.downloadSettings.directoryNotWritable' => 'Папка недоступна для записи',
			'settings.downloadSettings.insufficientSpace' => 'Недостаточно свободного места',
			'settings.downloadSettings.pathValid' => 'Путь корректен',
			'settings.downloadSettings.validationFailed' => 'Проверка не пройдена',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Используется папка приложения по умолчанию',
			'settings.downloadSettings.appPrivateDirectory' => 'Изолированная папка приложения',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Надежно и безопасно, дополнительных разрешений не требуется',
			'settings.downloadSettings.downloadDirectory' => 'Папка «Загрузки»',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Системная папка загрузок, удобно для управления',
			'settings.downloadSettings.moviesDirectory' => 'Папка «Фильмы»',
			'settings.downloadSettings.moviesDirectoryDesc' => 'Системная папка видео, распознается медиаплеерами',
			'settings.downloadSettings.documentsDirectory' => 'Папка документов',
			'settings.downloadSettings.documentsDirectoryDesc' => 'Папка документов iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'Для доступа требуется разрешение',
			'settings.downloadSettings.recommendedPaths' => 'Рекомендуемые пути',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Внешняя папка приложения',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Папка приложения на внешнем накопителе, доступна пользователю, больше места',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Внутренняя папка приложения',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Внутреннее хранилище приложения, без спецразрешений, меньше места',
			'settings.downloadSettings.appDocumentsDirectory' => 'Папка документов приложения',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'Папка документов приложения, надежно и изолированно',
			'settings.downloadSettings.downloadsFolder' => 'Папка «Загрузки»',
			'settings.downloadSettings.downloadsFolderDesc' => 'Стандартная папка загрузок устройства',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Выберите рекомендуемую папку загрузки',
			'settings.downloadSettings.noRecommendedPaths' => 'Нет рекомендуемых путей',
			'settings.downloadSettings.recommended' => 'Рекомендуется',
			'settings.downloadSettings.requiresPermission' => 'Требуется разрешение',
			'settings.downloadSettings.authorizeAndSelect' => 'Разрешить и выбрать',
			'settings.downloadSettings.select' => 'Выбрать',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Не удалось получить разрешение, выбор пути невозможен',
			'settings.downloadSettings.pathValidationFailed' => 'Путь не прошел проверку',
			'settings.downloadSettings.downloadPathSetTo' => 'Путь загрузки установлен в',
			'settings.downloadSettings.setPathFailed' => 'Не удалось установить путь',
			'settings.downloadSettings.variableTitle' => 'Название',
			'settings.downloadSettings.variableAuthorcache' => 'Первое имя автора (стабильно при смене никнейма)',
			'settings.downloadSettings.variableAuthor' => 'Имя автора',
			'settings.downloadSettings.variableUsername' => 'Имя пользователя автора',
			'settings.downloadSettings.variableQuality' => 'Качество видео',
			'settings.downloadSettings.variableFilename' => 'Исходное имя файла',
			'settings.downloadSettings.variableId' => 'ID контента',
			'settings.downloadSettings.variableCount' => 'Количество изображений в галерее',
			'settings.downloadSettings.variableDate' => 'Текущая дата (ГГГГ-ММ-ДД)',
			'settings.downloadSettings.variableTime' => 'Текущее время (ЧЧ-ММ-СС)',
			'settings.downloadSettings.variableDatetime' => 'Дата и время (ГГГГ-ММ-ДД_ЧЧ-ММ-СС)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Настройки загрузки',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Папка сохранения и правила именования файлов',
			'settings.downloadSettings.suchAsTitleQuality' => 'Например: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Например: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Например: %title_%filename',
			'settings.downloadSettings.structureSection' => 'Структура сохранения и имена',
			'settings.downloadSettings.structureSectionDescription' => 'Скачанные файлы раскладываются по подпапкам согласно выбранной ниже схеме. Касается только новых загрузок; существующие файлы не трогаются.',
			'settings.downloadSettings.structureNoticeTitle' => 'Новое: автораскладка по авторам',
			'settings.downloadSettings.structureNoticeBody' => 'Выберите ниже · касается только новых загрузок, существующие файлы остаются на месте.',
			'settings.downloadSettings.presetFlat' => 'Плоско',
			'settings.downloadSettings.presetFlatDesc' => 'Все файлы лежат прямо в корневой папке загрузок',
			'settings.downloadSettings.presetAuthor' => 'По авторам',
			'settings.downloadSettings.presetAuthorBadge' => 'Рекомендуется',
			'settings.downloadSettings.presetAuthorDesc' => 'Папка на автора · переименование не разбивает архив',
			'settings.downloadSettings.presetDate' => 'По датам',
			'settings.downloadSettings.presetDateDesc' => 'Группировка по дате загрузки',
			'settings.downloadSettings.presetCustomActive' => 'Активно',
			'settings.downloadSettings.structurePreviewLabel' => 'Предпросмотр',
			'settings.downloadSettings.structurePreviewNote' => 'Цветные сегменты — уровни структуры, меняются вместе со схемой.',
			'settings.downloadSettings.pathTooLongWarning' => 'Относительный путь длиннее 200 символов — на части устройств сохранение может не удаться',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Свой шаблон пути',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Самому решить, как делить папки и называть файлы',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Шаблон пути',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Автоматически раскладывает загрузки по подпапкам',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Видео',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Галерея',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Отдельное изображение',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Предпросмотр · реальный результат после очистки',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Предпросмотр · шаблон галереи = имя папки (внутренние изображения именуются по ID)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Добавить уровень папок',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Достигнут предел уровней папок',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, переменная или текст',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'напр. %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'Расширение .mp4 добавится само · ввод / внутри сегмента делит его на два уровня · максимум ${max} уровней',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'Исходное расширение добавится само · ввод / внутри сегмента делит его на два уровня · максимум ${max} уровней',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'Шаблон галереи — только папки, максимум ${max} уровней · внутренние изображения именуются по ID',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Нажмите, чтобы вставить в позицию курсора · долгое нажатие — подробности',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Пустой сегмент',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'Нельзя сохранить: есть пустые сегменты, заполните или удалите их',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'Нельзя сохранить: слишком много сегментов пути (макс. 4). Объедините или удалите лишние',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'Нельзя сохранить: шаблон содержит недопустимые символы',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Переменная вставлена',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Сохранено · касается только новых загрузок',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Содержимое',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Автор',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Время',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Имя автора·фикс.',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Дата',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Время',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Дата и время',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Номер',
			'favoriteTags.title' => 'Избранные теги',
			'favoriteTags.emptyIwara' => 'Нет избранных тегов Iwara',
			'favoriteTags.emptyOreno3d' => 'Нет избранных тегов',
			'favoriteTags.addIwaraTag' => 'Добавить тег Iwara',
			'favoriteTags.quickPickHint' => 'Избранные теги будут доступны для быстрого выбора в поиске.',
			'favoriteTags.pickerTitle' => 'Выбор Oreno3D',
			'favoriteTags.searchHint' => 'Поиск по названию или оригиналу',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ru'))(n, one: 'Работ: ${n}', other: 'Работ: ${n}', ), 
			'favoriteTags.browseEntry' => 'Обзор: оригинал / персонаж / тег',
			'favoriteTags.favoritesSection' => 'Избранное',
			'favoriteTags.addFavorite' => 'Добавить',
			'favoriteTags.iwaraTitle' => 'Избранные теги Iwara',
			'favoriteTags.oreno3dTitle' => 'Избранные теги Oreno3D',
			'favoriteTags.changeTag' => 'Изменить тег',
			'favoriteTags.switchToText' => 'Поиск по тексту',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Теги',
			'oreno3d.characters' => 'Персонажи',
			'oreno3d.origin' => 'Первоисточник',
			'oreno3d.thirdPartyTagsExplanation' => 'Информация о **тегах**, **персонажах** и **источнике**, показанная здесь, предоставлена сторонним сайтом **Oreno3D** исключительно для справки.\n\nЭтот источник доступен только на японском языке, поэтому пока не адаптирован под локализацию.\n\nЕсли вы хотите помочь с локализацией, перейдите в репозиторий.',
			'oreno3d.sortTypes.hot' => 'Популярные',
			'oreno3d.sortTypes.favorites' => 'В избранном',
			'oreno3d.sortTypes.latest' => 'Новые',
			'oreno3d.sortTypes.popularity' => 'Рейтинг',
			'oreno3d.errors.requestFailed' => 'Ошибка запроса, код состояния',
			'oreno3d.errors.connectionTimeout' => 'Время ожидания подключения истекло, проверьте сеть',
			'oreno3d.errors.sendTimeout' => 'Время отправки запроса истекло',
			'oreno3d.errors.receiveTimeout' => 'Время получения ответа истекло',
			'oreno3d.errors.badCertificate' => 'Ошибка проверки сертификата',
			'oreno3d.errors.resourceNotFound' => 'Запрошенный ресурс не найден',
			'oreno3d.errors.accessDenied' => 'Доступ запрещен',
			'oreno3d.errors.serverError' => 'Внутренняя ошибка сервера',
			'oreno3d.errors.serviceUnavailable' => 'Сервис временно недоступен',
			'oreno3d.errors.requestCancelled' => 'Запрос отменен',
			'oreno3d.errors.connectionError' => 'Ошибка сетевого соединения, проверьте настройки сети',
			'oreno3d.errors.networkRequestFailed' => 'Сбой сетевого запроса',
			'oreno3d.errors.searchVideoError' => 'Ошибка поиска видео',
			'oreno3d.errors.getPopularVideoError' => 'Ошибка загрузки популярных видео',
			'oreno3d.errors.getVideoDetailError' => 'Ошибка получения сведений о видео',
			'oreno3d.errors.parseVideoDetailError' => 'Ошибка обработки данных видео',
			'oreno3d.errors.downloadFileError' => 'Ошибка скачивания файла',
			'oreno3d.loading.gettingVideoInfo' => 'Получение информации о видео...',
			'oreno3d.loading.cancel' => 'Отмена',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Видео не найдено или удалено',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Не удалось получить ссылку на видео',
			'oreno3d.messages.getVideoDetailFailed' => 'Не удалось получить сведения о видео',
			'signIn.pleaseLoginFirst' => 'Сначала войдите в систему',
			'signIn.alreadySignedInToday' => 'Вы уже отметились сегодня!',
			'signIn.youDidNotStickToTheSignIn' => 'Серия отметок прервана.',
			'signIn.signInSuccess' => 'Отметка успешно поставлена!',
			'signIn.signInFailed' => 'Не удалось отметиться, повторите позже',
			'signIn.consecutiveSignIns' => 'Дней подряд',
			'signIn.failureReason' => 'Причина сбоя',
			'signIn.selectDateRange' => 'Выбрать диапазон дат',
			'signIn.startDate' => 'Начальная дата',
			'signIn.endDate' => 'Конечная дата',
			'signIn.invalidDate' => 'Неверная дата',
			'signIn.invalidDateRange' => 'Неверный диапазон дат',
			'signIn.errorFormatText' => 'Ошибка формата даты',
			'signIn.errorInvalidText' => 'Неверный диапазон дат',
			'signIn.errorInvalidRangeText' => 'Неверный диапазон дат',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'Диапазон дат не может превышать один год',
			'signIn.signIn' => 'Отметиться',
			'signIn.signInRecord' => 'История отметок',
			'signIn.totalSignIns' => 'Всего отметок',
			'signIn.pleaseSelectSignInStatus' => 'Выберите статус отметки',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Войдите в систему для просмотра подписок.',
			'subscriptions.selectUser' => 'Выбрать пользователя',
			'subscriptions.noSubscribedUsers' => 'Нет подписок',
			'subscriptions.showAllSubscribedUsersContent' => 'Контент всех авторов',
			'videoDetail.pipMode' => 'Режим «картинка в картинке»',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Продолжить с места остановки: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Воспроизведение с ${position}',
			'videoDetail.restartFromBeginning' => 'Начать сначала',
			'videoDetail.dismissResumeTip' => 'Скрыть',
			'videoDetail.localInfo.videoInfo' => 'Информация о видео',
			'videoDetail.localInfo.currentQuality' => 'Текущее качество',
			'videoDetail.localInfo.duration' => 'Длительность',
			'videoDetail.localInfo.resolution' => 'Разрешение',
			'videoDetail.localInfo.fileInfo' => 'О файле',
			'videoDetail.localInfo.fileName' => 'Имя файла',
			'videoDetail.localInfo.fileSize' => 'Размер файла',
			'videoDetail.localInfo.filePath' => 'Путь к файлу',
			'videoDetail.localInfo.copyPath' => 'Копировать путь',
			'videoDetail.localInfo.openFolder' => 'Открыть папку',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Путь скопирован в буфер',
			'videoDetail.localInfo.openFolderFailed' => 'Не удалось открыть папку',
			'videoDetail.videoIdIsEmpty' => 'ID видео пуст',
			'videoDetail.videoInfoIsEmpty' => 'Нет данных о видео',
			'videoDetail.thisIsAPrivateVideo' => 'Это приватное видео',
			'videoDetail.getVideoInfoFailed' => 'Не удалось получить данные о видео, повторите позже',
			'videoDetail.noVideoSourceFound' => 'Источник видео не найден',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Тег «${tagId}» скопирован',
			'videoDetail.errorLoadingVideo' => 'Ошибка загрузки видео',
			'videoDetail.play' => 'Воспроизвести',
			'videoDetail.pause' => 'Пауза',
			'videoDetail.exitAppFullscreen' => 'Выйти из полноэкранного режима',
			'videoDetail.enterAppFullscreen' => 'Полный экран в приложении',
			'videoDetail.exitSystemFullscreen' => 'Выйти из полного экрана',
			'videoDetail.enterSystemFullscreen' => 'Системный полный экран',
			'videoDetail.seekTo' => 'Перемотать на',
			'videoDetail.switchResolution' => 'Сменить качество',
			'videoDetail.switchPlaybackSpeed' => 'Сменить скорость',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Назад на ${num} сек.',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Вперед на ${num} сек.',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Скорость: ${rate}x',
			'videoDetail.brightness' => 'Яркость',
			'videoDetail.brightnessLowest' => 'Минимальная яркость',
			'videoDetail.volume' => 'Громкость',
			'videoDetail.volumeMuted' => 'Звук выключен',
			'videoDetail.restoreDefaultZoom' => 'Сбросить',
			'videoDetail.gestureGuide.sampleVideo' => 'Пример видео',
			'videoDetail.gestureGuide.title' => 'Руководство по жестам',
			'videoDetail.gestureGuide.viewGuide' => 'Жесты и управление',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Ознакомьтесь с жестами управления плеером. Вы всегда можете вернуться к этой справке в настройках плеера.',
			'videoDetail.gestureGuide.startWatching' => 'Понятно, перейти к просмотру',
			'videoDetail.gestureGuide.basicTitle' => 'Основное управление',
			'videoDetail.gestureGuide.zoomTitle' => 'Зум / Поворот / Смещение',
			'videoDetail.gestureGuide.restoreTip' => 'Нажмите «Сбросить» в правом нижнем углу для сброса масштаба, поворота и позиции.',
			'videoDetail.gestureGuide.mTap' => 'Одиночное касание: показать/скрыть элементы управления',
			'videoDetail.gestureGuide.mDoubleTap' => 'Двойное касание: назад (слева) / пауза (по центру) / вперед (справа)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Горизонтальное смахивание: перемотка',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Вертикальное смахивание: яркость (слева) / громкость (справа)',
			'videoDetail.gestureGuide.mLongPress' => 'Долгое нажатие: ускорение',
			'videoDetail.gestureGuide.mPinch' => 'Два пальца (щипок): масштаб кадра',
			'videoDetail.gestureGuide.mRotate' => 'Два пальца (поворот): поворот кадра',
			'videoDetail.gestureGuide.dTap' => 'Клик: показать/скрыть элементы управления',
			'videoDetail.gestureGuide.dDoubleTap' => 'Двойной клик: назад (слева) / пауза (по центру) / вперед (справа)',
			'videoDetail.gestureGuide.dKeys' => 'Стрелки перемотки: нажатие — шаг назад/вперед, удержание — ускорение; клавиши скорости: изменение скорости; Пробел: пауза/пуск',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Жест трекпада: масштаб',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Жест трекпада: поворот',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + колесико: масштаб относительно курсора',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + колесико: поворот относительно курсора',
			'videoDetail.gestureGuide.quest.title' => 'Управление в Quest',
			'videoDetail.gestureGuide.quest.intro' => 'Познакомьтесь с элементами управления и попробуйте их в своем пространстве.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Пространственное видео',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Пространственная галерея',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Для экранов и окон в пространстве Quest. Доступно в любое время в настройках плеера.',
			'videoDetail.gestureGuide.quest.catalog' => 'Обзор управления',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} из ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Назад',
			'videoDetail.gestureGuide.quest.next' => 'Далее',
			'videoDetail.gestureGuide.quest.replay' => 'Повторить демо',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Пауза демо',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Продолжить демо',
			'videoDetail.gestureGuide.quest.looping' => 'Демонстрация',
			'videoDetail.gestureGuide.quest.still' => 'Иллюстрация',
			'videoDetail.gestureGuide.quest.done' => 'Понятно, продолжить',
			'videoDetail.gestureGuide.quest.leftController' => 'Левая рука',
			'videoDetail.gestureGuide.quest.rightController' => 'Правая рука',
			'videoDetail.gestureGuide.quest.trigger' => 'Триггер (курок)',
			'videoDetail.gestureGuide.quest.grip' => 'Боковая кнопка (хват)',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Обе боковые кнопки',
			'videoDetail.gestureGuide.quest.stick' => 'Стик',
			'videoDetail.gestureGuide.quest.handTracking' => 'Отслеживание рук',
			'videoDetail.gestureGuide.quest.ready' => 'Готово',
			'videoDetail.gestureGuide.quest.press' => 'Нажать',
			'videoDetail.gestureGuide.quest.hold' => 'Удерживать',
			'videoDetail.gestureGuide.quest.release' => 'Отпустить',
			'videoDetail.gestureGuide.quest.result' => 'Результат',
			'videoDetail.gestureGuide.quest.pinch' => 'Щипок',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Наведение и выбор',
			'videoDetail.gestureGuide.quest.selectBody' => 'Наведите луч на кнопку, затем нажмите и отпустите триггер. Используется для воспроизведения, настроек и ползунков.',
			'videoDetail.gestureGuide.quest.selectHint' => 'Триггер находится под указательным пальцем. Кнопка хвата на рукоятке перемещает окна.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Показать или скрыть панель',
			'videoDetail.gestureGuide.quest.panelBody' => 'Направьте луч мимо панели и нажмите триггер, чтобы скрыть или показать ее. При отслеживании рук выполните быстрый щипок в пустоте.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Используйте короткое нажатие без перемещения. Удержание с движением перемещает экран.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Воспроизведение и пауза',
			'videoDetail.gestureGuide.quest.playBody' => 'Направьте луч в сторону от панели и нажмите кнопку A (справа) или X (слева). Также можно нажать кнопку воспроизведения на панели.',
			'videoDetail.gestureGuide.quest.playHint' => 'Это сочетание можно отключить в настройках пространственного плеера. При наведении на панель нажатие управляет панелью.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Перемотка стиком',
			'videoDetail.gestureGuide.quest.seekBody' => 'Отклоните любой стик влево или вправо на 5 секунд. Удерживайте для быстрой перемотки с предпросмотром. Отпустите для применения.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Удерживайте луч в стороне от панели управления, иначе стик будет прокручивать панель.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Просмотр стиком',
			'videoDetail.gestureGuide.quest.browseBody' => 'Отклоните стик влево/вправо для перехода к предыдущему или следующему элементу; удерживайте для непрерывного листания. Можно также выбрать миниатюру.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Видео в галерее также считаются элементами. Наведение на панель переключает стик на ее прокрутку.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Перелистывание перетаскиванием',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Наведите на изображение, зажмите триггер и потяните влево. Отпустите после подсказки о смене страницы; потяните вправо для возврата. Щипок с перетаскиванием тоже работает.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Для перелистывания изображение должно быть в масштабе 1×. Поддерживаются и видео в галерее. Сцена остается на месте до отпускания.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'Масштабирование изображения',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Наведите на деталь, зажмите триггер и отклоните стик вверх для приближения или вниз для отдаления. Центр зума фиксируется в точке нажатия.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Масштабирует изображение внутри его окна. Без зажатия изображения стик вверх/вниз меняет расстояние до экрана.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Панорамирование и сброс',
			'videoDetail.gestureGuide.quest.panBody' => 'При приближении удерживайте триггер и двигайте руку для осмотра. Двойное нажатие по изображению увеличивает до 2.5× или сбрасывает масштаб. Руками: быстрый двойной щипок.',
			'videoDetail.gestureGuide.quest.panHint' => 'Перетаскивание перемещает увеличенное изображение. Сбросьте до 1× перед перелистыванием страниц.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Запуск слайд-шоу',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'Кнопки A / X на изображении запускают слайд-шоу. На панели можно выбрать интервал (3, 5, 10 или 20 с) и качество.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'Для видео в галерее A / X управляют воспроизведением. Горячие клавиши контроллера должны быть включены в настройках.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Захват и перемещение экрана',
			'videoDetail.gestureGuide.quest.moveBody' => 'Зажмите кнопку хвата на внутренней стороне рукоятки, переместите экран контроллером и отпустите. При просмотре можно хватать экран, не целясь в него.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Наведение на окно приложения или панель захватывает их в первую очередь. В панорамном видео хват вращает ракурс.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Изменение размера двумя руками',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Зажмите обе кнопки хвата. Разведите руки в стороны для увеличения или сведите для уменьшения. Руками: удерживайте щипок обеими руками.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Для плоских и изогнутых экранов, включая сцену галереи. Не наводите на панель. Изменяет размер экрана целиком.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Расстояние просмотра',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Отклоните стик вверх, чтобы отдалить экран, или вниз, чтобы приблизить. При захвате окна стик двигает это окно. Громкость настраивается на панели.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Направьте луч мимо панели управления. Удержание изображения переключает стик на зум; в панорамном видео настраивается угол обзора.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Края и углы',
			'videoDetail.gestureGuide.quest.resizeBody' => 'Рамка подсвечивается при приближении луча к краю. Зажмите триггер или щипок на краю для перемещения; потяните за угол для масштабирования.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Работает для окна приложения, панели управления и экрана. Окно меняет ширину и высоту; экран сохраняет пропорции.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Назад и открытие настроек',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y возвращает на шаг назад: закрывает всплывающее окно, скрывает панель и возвращает в приложение. Левая кнопка меню открывает настройки пространства.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'Правая кнопка Meta зарезервирована системой. Системное центрирование возвращает экран перед вами с сохранением размера и расстояния.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Управление руками',
			'videoDetail.gestureGuide.quest.handsBody' => 'При включенном отслеживании рук наведите системный луч на кнопку, сомкните большой и указательный пальцы (щипок) и разомкните. Панель служит для воспроизведения, перемотки и галереи.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Щипок в пустоте скрывает/показывает панель. Щипок за край перемещает, за угол меняет размер, щипок двумя руками масштабирует экран.',
			'videoDetail.home' => 'Главная',
			'videoDetail.videoPlayer' => 'Видеоплеер',
			'videoDetail.videoPlayerInfo' => 'О видеоплеере',
			'videoDetail.moreSettings' => 'Дополнительные настройки',
			'videoDetail.videoPlayerFeatureInfo' => 'О возможностях плеера',
			'videoDetail.autoRewind' => 'Автоперемотка',
			'videoDetail.rewindAndFastForward' => 'Перемотка назад и вперед',
			'videoDetail.volumeAndBrightness' => 'Громкость и яркость',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Двойное нажатие по центру: пауза/воспроизведение',
			'videoDetail.showVerticalVideoInFullScreen' => 'Вертикальное видео на весь экран',
			'videoDetail.keepLastVolumeAndBrightness' => 'Запоминать громкость и яркость',
			'videoDetail.setProxy' => 'Настройка прокси',
			'videoDetail.moreFeaturesToBeDiscovered' => 'Больше возможностей впереди...',
			'videoDetail.videoPlayerSettings' => 'Настройки видеоплеера',
			'videoDetail.commentCount' => ({required Object num}) => 'Комментариев: ${num}',
			'videoDetail.writeYourCommentHere' => 'Напишите комментарий...',
			'videoDetail.authorOtherVideos' => 'Другие видео автора',
			'videoDetail.relatedVideos' => 'Похожие видео',
			'videoDetail.privateVideo' => 'Это приватное видео',
			'videoDetail.externalVideo' => 'Это внешнее видео',
			'videoDetail.openInBrowser' => 'Открыть в браузере',
			'videoDetail.resourceDeleted' => 'Похоже, это видео удалено :/',
			'videoDetail.noDownloadUrl' => 'Ссылка для скачивания отсутствует',
			'videoDetail.startDownloading' => 'Начать скачивание',
			'videoDetail.downloadFailed' => 'Ошибка скачивания, повторите позже',
			'videoDetail.downloadSuccess' => 'Скачивание завершено',
			'videoDetail.download' => 'Скачать',
			'videoDetail.downloadManager' => 'Менеджер загрузок',
			'videoDetail.resourceNotFound' => 'Ресурс не найден',
			'videoDetail.videoLoadError' => 'Ошибка загрузки видео',
			'videoDetail.authorNoOtherVideos' => 'У автора больше нет других видео',
			'videoDetail.noRelatedVideos' => 'Нет похожих видео',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Ошибка загрузки источника видео',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Ошибка настройки слушателей',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Ошибка сервера, выполнен автоматический переход на другой маршрут',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Загрузка информации о видео...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Загрузка источников видео...',
			'videoDetail.skeleton.loadingVideo' => 'Загрузка видео...',
			'videoDetail.skeleton.applyingSolution' => 'Применение решения...',
			'videoDetail.skeleton.addingListeners' => 'Добавление слушателей...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Длительность видео получена, загрузка видео...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Загрузка завершена',
			'videoDetail.cast.dlnaCast' => 'Трансляция',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Не удалось запустить поиск устройств: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Трансляция на ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Ошибка трансляции: ${error}\nПовторите поиск устройств или смените сеть',
			'videoDetail.cast.castStopped' => 'Трансляция остановлена',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Медиаплеер',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Медиасервер',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Маршрутизатор',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Базовое устройство',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Умный светильник',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'Точка доступа WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'Сетевое устройство WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'Принтер',
			'videoDetail.cast.deviceTypes.scanner' => 'Сканер',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Камера безопасности',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Неизвестное устройство',
			'videoDetail.cast.currentPlatformNotSupported' => 'Трансляция не поддерживается на этой платформе',
			'videoDetail.cast.unableToGetVideoUrl' => 'Не удалось получить адрес видео, повторите позже',
			_ => null,
		} ?? switch (path) {
			'videoDetail.cast.stopCasting' => 'Остановить трансляцию',
			'videoDetail.cast.dlnaCastSheet.title' => 'Беспроводная трансляция',
			'videoDetail.cast.dlnaCastSheet.close' => 'Закрыть',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Поиск устройств...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Нажмите кнопку для повторного поиска устройств трансляции',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Поиск',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Искать снова',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'Устройства трансляции не найдены\nУбедитесь, что устройства в одной сети',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Поиск устройств, подождите...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Транслировать',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Подключено к: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Нет подключенных устройств',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Остановить трансляцию',
			'videoDetail.likeAvatars.dialogTitle' => 'Кто оценил',
			'videoDetail.likeAvatars.dialogDescription' => 'Интересно, кто это? Посмотрите список оценивших~',
			'videoDetail.likeAvatars.closeTooltip' => 'Закрыть',
			'videoDetail.likeAvatars.retry' => 'Повторить',
			'videoDetail.likeAvatars.noLikesYet' => 'Здесь пока никого нет. Будьте первым!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Страница ${page} / ${totalPages} · всего ${totalCount} чел.',
			'videoDetail.likeAvatars.prevPage' => 'Предыдущая страница',
			'videoDetail.likeAvatars.nextPage' => 'Следующая страница',
			'share.sharePlayList' => 'Поделиться плейлистом',
			'share.wowDidYouSeeThis' => 'Вау, вы это видели?',
			'share.nameIs' => 'Название:',
			'share.clickLinkToView' => 'Нажмите ссылку для просмотра',
			'share.iReallyLikeThis' => 'Мне очень нравится',
			'share.shareFailed' => 'Не удалось поделиться, повторите попытку позже',
			'share.share' => 'Поделиться',
			'share.shareAsImage' => 'Поделиться изображением',
			'share.shareAsText' => 'Поделиться текстом',
			'share.shareAsImageDesc' => 'Поделиться обложкой видео как изображением',
			'share.shareAsTextDesc' => 'Поделиться деталями видео в виде текста',
			'share.shareAsImageFailed' => 'Не удалось поделиться обложкой видео как изображением, повторите попытку позже',
			'share.shareAsTextFailed' => 'Не удалось поделиться деталями видео в виде текста, повторите попытку позже',
			'share.shareVideo' => 'Поделиться видео',
			'share.authorIs' => 'Автор:',
			'share.shareGallery' => 'Поделиться галереей',
			'share.galleryTitleIs' => 'Название галереи:',
			'share.galleryAuthorIs' => 'Автор галереи:',
			'share.shareUser' => 'Поделиться пользователем',
			'share.userNameIs' => 'Имя пользователя:',
			'share.userAuthorIs' => 'Автор пользователя:',
			'share.comments' => 'Комментарии',
			'share.shareThread' => 'Поделиться темой',
			'share.views' => 'Просмотры',
			'share.sharePost' => 'Поделиться публикацией',
			'share.postTitleIs' => 'Заголовок публикации:',
			'share.postAuthorIs' => 'Автор публикации:',
			'markdown.markdownSyntax' => 'Синтаксис Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Особый синтаксис Markdown Iwara',
			'markdown.internalLink' => 'Внутренняя ссылка',
			'markdown.supportAutoConvertLinkBelow' => 'Поддерживается автоматическое преобразование следующих ссылок:',
			'markdown.convertLinkExample' => '🎬 Ссылка на видео\n🖼️ Ссылка на изображение\n👤 Ссылка на пользователя\n📌 Ссылка на форум\n🎵 Ссылка на плейлист\n💬 Ссылка на тему',
			'markdown.mentionUser' => 'Упоминание пользователя',
			'markdown.mentionUserDescription' => 'Введите @, а затем имя пользователя — оно автоматически преобразуется в ссылку на пользователя',
			'markdown.markdownBasicSyntax' => 'Основы синтаксиса Markdown',
			'markdown.paragraphAndLineBreak' => 'Абзац и перенос строки',
			'markdown.paragraphAndLineBreakDescription' => 'Абзацы разделяются пустой строкой, а два пробела в конце строки преобразуются в перенос строки',
			'markdown.paragraphAndLineBreakSyntax' => 'Это первый абзац\n\nЭто второй абзац\nЭта строка заканчивается двумя пробелами  \nпреобразуется в перенос строки',
			'markdown.textStyle' => 'Стиль текста',
			'markdown.textStyleDescription' => 'Окружите текст специальными символами, чтобы изменить стиль',
			'markdown.textStyleSyntax' => '**Жирный текст**\n*Курсив*\n~~Зачёркнутый текст~~\n`Код`',
			'markdown.quote' => 'Цитата',
			'markdown.quoteDescription' => 'Символ > создаёт цитату, несколько > — многоуровневую цитату',
			'markdown.quoteSyntax' => '> Это цитата первого уровня\n>> Это цитата второго уровня',
			'markdown.list' => 'Список',
			'markdown.listDescription' => 'Нумерованный список создаётся цифрой с точкой, маркированный — знаком -',
			'markdown.listSyntax' => '1. Первый пункт\n2. Второй пункт\n\n- Пункт маркированного списка\n  - Подпункт\n  - Ещё один подпункт',
			'markdown.linkAndImage' => 'Ссылка и изображение',
			'markdown.linkAndImageDescription' => 'Формат ссылки: [текст](URL)\nФормат изображения: ![описание](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[текст ссылки](${link})\n![описание изображения](${imgUrl})',
			'markdown.title' => 'Заголовок',
			'markdown.titleDescription' => 'Символ # создаёт заголовок, число символов # задаёт уровень',
			'markdown.titleSyntax' => '# Заголовок первого уровня\n## Заголовок второго уровня\n### Заголовок третьего уровня',
			'markdown.separator' => 'Разделитель',
			'markdown.separatorDescription' => 'Разделитель создаётся тремя или более символами -',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Синтаксис',
			'forum.attachQuote' => 'Прикрепить цитату',
			'forum.replyToFloor' => ({required Object floor, required Object username}) => 'Ответ на #${floor} @${username}',
			'forum.removeQuote' => 'Убрать цитату',
			'forum.recent' => 'Недавние',
			'forum.category' => 'Категория',
			'forum.lastReply' => 'Последний ответ',
			'forum.sitewide.badge' => 'По всему сайту',
			'forum.sitewide.title' => 'Объявление для всего сайта',
			'forum.sitewide.readMore' => 'Подробнее',
			'forum.errors.pleaseSelectCategory' => 'Выберите категорию',
			'forum.errors.threadLocked' => 'Эта тема закрыта, ответить нельзя',
			'forum.createPost' => 'Создать публикацию',
			'forum.title' => 'Заголовок',
			'forum.enterTitle' => 'Введите заголовок',
			'forum.content' => 'Содержание',
			'forum.enterContent' => 'Введите содержание',
			'forum.writeYourContentHere' => 'Напишите здесь свой текст...',
			'forum.posts' => 'Публикации',
			'forum.threads' => 'Темы',
			'forum.forum' => 'Форум',
			'forum.createThread' => 'Создать тему',
			'forum.selectCategory' => 'Выберите категорию',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Осталось ждать: ${minutes} мин ${seconds} с',
			'forum.groups.administration' => 'Администрация',
			'forum.groups.global' => 'Глобальный',
			'forum.groups.chinese' => 'Китайский',
			'forum.groups.japanese' => 'Японский',
			'forum.groups.korean' => 'Корейский',
			'forum.groups.other' => 'Другое',
			'forum.leafNames.announcements' => 'Объявления',
			'forum.leafNames.feedback' => 'Отзывы',
			'forum.leafNames.support' => 'Поддержка',
			'forum.leafNames.general' => 'Общее',
			'forum.leafNames.guides' => 'Руководства',
			'forum.leafNames.questions' => 'Вопросы',
			'forum.leafNames.requests' => 'Запросы',
			'forum.leafNames.sharing' => 'Обмен',
			'forum.leafNames.general_zh' => 'Общее',
			'forum.leafNames.questions_zh' => 'Вопросы',
			'forum.leafNames.requests_zh' => 'Запросы',
			'forum.leafNames.support_zh' => 'Поддержка',
			'forum.leafNames.general_ja' => 'Общее',
			'forum.leafNames.questions_ja' => 'Вопросы',
			'forum.leafNames.requests_ja' => 'Запросы',
			'forum.leafNames.support_ja' => 'Поддержка',
			'forum.leafNames.korean' => 'Корейский',
			'forum.leafNames.other' => 'Прочее',
			'forum.leafDescriptions.announcements' => 'Официальные важные уведомления и объявления',
			'forum.leafDescriptions.feedback' => 'Отзывы о функциях и сервисах сайта',
			'forum.leafDescriptions.support' => 'Помощь в решении проблем, связанных с сайтом',
			'forum.leafDescriptions.general' => 'Обсуждение любых тем',
			'forum.leafDescriptions.guides' => 'Делитесь опытом и руководствами',
			'forum.leafDescriptions.questions' => 'Задавайте свои вопросы',
			'forum.leafDescriptions.requests' => 'Публикуйте свои запросы',
			'forum.leafDescriptions.sharing' => 'Делитесь интересным контентом',
			'forum.leafDescriptions.general_zh' => 'Обсуждение любых тем',
			'forum.leafDescriptions.questions_zh' => 'Задавайте свои вопросы',
			'forum.leafDescriptions.requests_zh' => 'Публикуйте свои запросы',
			'forum.leafDescriptions.support_zh' => 'Помощь в решении проблем, связанных с сайтом',
			'forum.leafDescriptions.general_ja' => 'Обсуждение любых тем',
			'forum.leafDescriptions.questions_ja' => 'Задавайте свои вопросы',
			'forum.leafDescriptions.requests_ja' => 'Публикуйте свои запросы',
			'forum.leafDescriptions.support_ja' => 'Помощь в решении проблем, связанных с сайтом',
			'forum.leafDescriptions.korean' => 'Обсуждения, связанные с корейским',
			'forum.leafDescriptions.other' => 'Прочий неклассифицированный контент',
			'forum.reply' => 'Ответить',
			'forum.pendingReview' => 'На рассмотрении',
			'forum.floorNotFound' => 'Это сообщение не существует или удалено',
			'forum.floorNotLoadedYet' => 'Это сообщение выше — загрузите больше ответов, чтобы перейти к нему',
			'forum.editedAt' => 'Дата изменения',
			'forum.copySuccess' => 'Скопировано в буфер обмена',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Скопировано в буфер обмена: ${str}',
			'forum.editReply' => 'Изменить ответ',
			'forum.editTitle' => 'Изменить заголовок',
			'forum.submit' => 'Отправить',
			'notifications.errors.unsupportedNotificationType' => 'Неподдерживаемый тип уведомления',
			'notifications.errors.unknownUser' => 'Неизвестный пользователь',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Неподдерживаемый тип уведомления: ${type}',
			'notifications.errors.unknownNotificationType' => 'Неизвестный тип уведомления',
			'notifications.notifications' => 'Уведомления',
			'notifications.profile' => 'Профиль',
			'notifications.postedNewComment' => 'Опубликован новый комментарий',
			'notifications.inYour' => 'В вашем',
			'notifications.video' => 'Видео',
			'notifications.repliedYourVideoComment' => 'Ответил(а) на ваш комментарий к видео',
			'notifications.copyInfoToClipboard' => 'Скопировать информацию об уведомлении в буфер обмена',
			'notifications.copySuccess' => 'Скопировано в буфер обмена',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Скопировано в буфер обмена: ${str}',
			'notifications.markAllAsRead' => 'Отметить всё как прочитанное',
			'notifications.markAllAsReadSuccess' => 'Все уведомления отмечены как прочитанные',
			'notifications.markAllAsReadFailed' => 'Не удалось отметить всё как прочитанное',
			'notifications.markSelectedAsRead' => 'Отметить выбранные как прочитанные',
			'notifications.markSelectedAsReadSuccess' => 'Выбранные уведомления отмечены как прочитанные',
			'notifications.markSelectedAsReadFailed' => 'Не удалось отметить выбранные как прочитанные',
			'notifications.markAsRead' => 'Отметить как прочитанное',
			'notifications.markAsReadSuccess' => 'Уведомление отмечено как прочитанное',
			'notifications.markAsReadFailed' => 'Не удалось отметить уведомление как прочитанное',
			'notifications.notificationTypeHelp' => 'Справка по типам уведомлений',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Из-за отсутствия подробностей о типе уведомления поддерживаемые типы могут не охватывать получаемые вами сообщения',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Если вы хотите помочь нам улучшить поддержку типов уведомлений',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Скопируйте информацию об уведомлении\n2. 🐞 Создайте задачу в репозитории проекта\n\n⚠️ Примечание: информация об уведомлении может содержать личные данные; если вы не хотите публиковать её, можно отправить автору проекта по электронной почте.',
			'notifications.goToRepository' => 'Перейти в репозиторий',
			'notifications.copy' => 'Копировать',
			'notifications.commentApproved' => 'Комментарий одобрен',
			'notifications.repliedYourProfileComment' => 'Ответил(а) на ваш комментарий в профиле',
			'notifications.kReplied' => 'ответил(а) на ваш комментарий в',
			'notifications.kCommented' => 'оставил(а) комментарий к вашему',
			'notifications.kVideo' => 'видео',
			'notifications.kGallery' => 'галерее',
			'notifications.kProfile' => 'профиле',
			'notifications.kThread' => 'теме',
			'notifications.kPost' => 'публикации',
			'notifications.kCommentSection' => 'раздел комментариев',
			'notifications.kApprovedComment' => 'Комментарий одобрен',
			'notifications.kApprovedVideo' => 'Видео одобрено',
			'notifications.kApprovedGallery' => 'Галерея одобрена',
			'notifications.kApprovedThread' => 'Тема одобрена',
			'notifications.kApprovedPost' => 'Публикация одобрена',
			'notifications.kApprovedForumPost' => 'Публикация на форуме одобрена',
			'notifications.kRejectedContent' => 'Контент отклонён модерацией',
			'notifications.kUnknownType' => 'Неизвестный тип уведомления',
			'conversation.errors.pleaseSelectAUser' => 'Выберите пользователя',
			'conversation.errors.pleaseEnterATitle' => 'Введите заголовок',
			'conversation.errors.clickToSelectAUser' => 'Нажмите, чтобы выбрать пользователя',
			'conversation.errors.loadFailedClickToRetry' => 'Ошибка загрузки, нажмите для повтора',
			'conversation.errors.loadFailed' => 'Ошибка загрузки',
			'conversation.errors.clickToRetry' => 'Нажмите, чтобы повторить',
			'conversation.errors.noMoreConversations' => 'Больше нет бесед',
			'conversation.conversation' => 'Беседа',
			'conversation.startConversation' => 'Начать беседу',
			'conversation.noConversation' => 'Нет бесед',
			'conversation.selectFromLeftListAndStartConversation' => 'Выберите пользователя из списка слева и начните беседу',
			'conversation.title' => 'Заголовок',
			'conversation.body' => 'Текст',
			'conversation.selectAUser' => 'Выберите пользователя',
			'conversation.searchUsers' => 'Поиск пользователей...',
			'conversation.tmpNoConversions' => 'Нет бесед',
			'conversation.deleteThisMessage' => 'Удалить это сообщение',
			'conversation.deleteThisMessageSubtitle' => 'Это действие нельзя отменить',
			'conversation.writeMessageHere' => 'Введите сообщение...',
			'conversation.lastMessageFromMe' => 'Вы: ',
			'conversation.sendMessage' => 'Отправить сообщение',
			'splash.errors.initializationFailed' => 'Ошибка инициализации, перезапустите приложение',
			'splash.preparing' => 'Подготовка...',
			'splash.initializing' => 'Инициализация...',
			'splash.loading' => 'Загрузка...',
			'splash.ready' => 'Готово',
			'splash.initializingMessageService' => 'Инициализация службы сообщений...',
			'download.errors.imageModelNotFound' => 'Модель изображения не найдена',
			'download.errors.downloadFailed' => 'Ошибка загрузки',
			'download.errors.videoInfoNotFound' => 'Информация о видео не найдена',
			'download.errors.downloadTaskAlreadyExists' => 'Задача загрузки уже существует',
			'download.errors.downloadTaskSavePathConflict' => 'Путь сохранения уже используется другой задачей',
			'download.errors.videoAlreadyDownloaded' => 'Видео уже скачано',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Не удалось добавить задачу загрузки: ${errorInfo}',
			'download.errors.userPausedDownload' => 'Загрузка приостановлена пользователем',
			'download.errors.unknown' => 'Неизвестно',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Ошибка файловой системы: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Неизвестная ошибка: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'Не удалось записать файл: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Тайм-аут подключения',
			'download.errors.sendTimeout' => 'Тайм-аут отправки',
			'download.errors.receiveTimeout' => 'Тайм-аут приёма',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Ошибка сервера: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Неизвестная сетевая ошибка',
			'download.errors.sslHandshakeFailed' => 'Ошибка SSL-рукопожатия, проверьте сеть',
			'download.errors.connectionFailed' => 'Не удалось подключиться, проверьте сеть',
			'download.errors.serviceIsClosing' => 'Служба загрузки закрывается',
			'download.errors.partialDownloadFailed' => 'Не удалось загрузить часть содержимого',
			'download.errors.noDownloadTask' => 'Нет задачи загрузки',
			'download.errors.taskNotFoundOrDataError' => 'Задача не найдена или ошибка данных',
			'download.errors.fileNotFound' => 'Файл не найден',
			'download.errors.openFolderFailed' => 'Не удалось открыть папку',
			'download.errors.copyDownloadUrlFailed' => 'Не удалось скопировать ссылку загрузки',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Не удалось открыть папку: ${message}',
			'download.errors.directoryNotFound' => 'Каталог не найден',
			'download.errors.copyFailed' => 'Не удалось скопировать',
			'download.errors.openFileFailed' => 'Не удалось открыть файл',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Не удалось открыть файл: ${message}',
			'download.errors.playLocallyFailed' => 'Не удалось воспроизвести локально',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Не удалось воспроизвести локально: ${message}',
			'download.errors.noDownloadSource' => 'Нет источника загрузки',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'Нет источника загрузки, дождитесь завершения загрузки информации и повторите попытку',
			'download.errors.noActiveDownloadTask' => 'Нет активных задач загрузки',
			'download.errors.noFailedDownloadTask' => 'Нет неудачных задач загрузки',
			'download.errors.noCompletedDownloadTask' => 'Нет завершённых задач загрузки',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Задача уже завершена, не добавляйте её снова',
			'download.errors.linkExpiredTryAgain' => 'Ссылка устарела, получение новой ссылки загрузки',
			'download.errors.linkExpiredTryAgainSuccess' => 'Ссылка устарела, новая ссылка загрузки успешно получена',
			'download.errors.linkExpiredTryAgainFailed' => 'Ссылка устарела, не удалось получить новую ссылку загрузки',
			'download.errors.taskDeleted' => 'Задача удалена',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Неподдерживаемый формат изображения: ${format}',
			'download.errors.deleteFileError' => 'Не удалось удалить файл, возможно, он используется другим процессом',
			'download.errors.deleteTaskError' => 'Не удалось удалить задачу',
			'download.errors.canNotRefreshVideoTask' => 'Не удалось обновить задачу видео',
			'download.errors.videoRemovedCanNotRefresh' => 'Видео удалено или больше не существует, поэтому ссылку загрузки нельзя обновить',
			'download.errors.videoInaccessibleCanNotRefresh' => 'Это видео недоступно: возможно, оно приватное или нужно войти заново',
			'download.errors.videoQualityGone' => 'Это качество больше не доступно, добавьте загрузку снова',
			'download.errors.refreshLinkNetworkFailed' => 'Ошибка сети: сейчас не удаётся обновить ссылку загрузки, повторите попытку позже',
			'download.errors.taskAlreadyProcessing' => 'Задача уже обрабатывается',
			'download.errors.taskNotFound' => 'Задача не найдена',
			'download.errors.failedToLoadTasks' => 'Не удалось загрузить задачи',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Ошибка частичной загрузки: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Неподдерживаемый формат изображения: ${extension}. Попробуйте скачать его на устройство для просмотра',
			'download.errors.imageLoadFailed' => 'Не удалось загрузить изображение',
			'download.errors.pleaseTryOtherViewer' => 'Попробуйте открыть в другом просмотрщике',
			'download.downloadList' => 'Список загрузок',
			'download.viewDownloadList' => 'Открыть список загрузок',
			'download.download' => 'Скачать',
			'download.selectDownloadTitle' => 'Выбор загрузки',
			'download.qualitySectionLabel' => 'Качество',
			'download.categorySectionLabel' => 'Категория',
			'download.saveToPreviewLabel' => 'Будет сохранено в',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Предлагаемое имя файла: ${name} (можно изменить в системном диалоге)',
			'download.lastUsedBadge' => 'Недавно использованное',
			'download.pickedBadge' => 'Выбрано',
			'download.startDownloading' => 'Начать загрузку',
			'download.clearAllFailedTasks' => 'Очистить все неудачные задачи',
			'download.clearAllFailedTasksConfirmation' => 'Вы уверены, что хотите очистить все неудачные задачи загрузки? Файлы этих задач также будут удалены.',
			'download.clearAllFailedTasksSuccess' => 'Все неудачные задачи очищены',
			'download.clearAllFailedTasksError' => 'Произошла ошибка при очистке неудачных задач',
			'download.downloadStatus' => 'Статус загрузки',
			'download.imageList' => 'Список изображений',
			'download.retryDownload' => 'Повторить загрузку',
			'download.notDownloaded' => 'Не скачано',
			'download.downloaded' => 'Скачано',
			'download.waitingForDownload' => 'Ожидание загрузки',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Загрузка (${downloaded}/${total} изображений, ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Загрузка (${downloaded} изображений)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Приостановлено (${downloaded}/${total} изображений, ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'Приостановлено (${downloaded} изображений)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Скачано (всего изображений: ${total})',
			'download.viewVideoDetail' => 'Открыть детали видео',
			'download.viewGalleryDetail' => 'Открыть детали галереи',
			'download.moreOptions' => 'Дополнительно',
			'download.openFile' => 'Открыть файл',
			'download.playLocally' => 'Воспроизвести локально',
			'download.pause' => 'Пауза',
			'download.resume' => 'Продолжить',
			'download.copyDownloadUrl' => 'Копировать ссылку загрузки',
			'download.showInFolder' => 'Показать в папке',
			'download.deleteTask' => 'Удалить задачу',
			'download.deleteTaskConfirmation' => 'Вы уверены, что хотите удалить эту задачу загрузки?\nФайл задачи также будет удалён.',
			'download.forceDeleteTask' => 'Принудительно удалить задачу',
			'download.forceDeleteTaskConfirmation' => 'Вы уверены, что хотите принудительно удалить эту задачу загрузки?\nФайл задачи также будет удалён, даже если он используется.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Загрузка ${downloaded}/${total} (${progress}%) • ${speed} МБ/с',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Загрузка ${downloaded} • ${speed} МБ/с',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'Приостановлено ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'Приостановлено • скачано ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Скачано • ${size}',
			'download.copyDownloadUrlSuccess' => 'Ссылка загрузки скопирована',
			'download.totalImageNums' => ({required Object num}) => 'Изображений: ${num}',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Загрузка ${downloaded}/${total} (${progress}%) • ${speed} МБ/с',
			'download.downloading' => 'Загрузка',
			'download.failed' => 'Ошибка',
			'download.completed' => 'Завершено',
			'download.downloadDetail' => 'Детали загрузки',
			'download.copy' => 'Копировать',
			'download.copySuccess' => 'Скопировано',
			'download.waiting' => 'Ожидание',
			'download.paused' => 'Приостановлено',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Загрузка ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Загрузка галереи завершена: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Загрузка завершена: ${fileName}',
			'download.searchTasks' => 'Поиск задач...',
			'download.statusLabel' => ({required Object label}) => 'Статус: ${label}',
			'download.allStatus' => 'Все статусы',
			'download.typeLabel' => ({required Object label}) => 'Тип: ${label}',
			'download.allTypes' => 'Все типы',
			'download.taskType' => 'Тип',
			'download.video' => 'Видео',
			'download.gallery' => 'Галерея',
			'download.other' => 'Другое',
			'download.clearFilters' => 'Сбросить фильтры',
			'download.pauseAll' => 'Приостановить все',
			'download.resumeAll' => 'Запустить все',
			'download.remainingTime' => ({required Object time}) => 'осталось ${time}',
			'download.timeline.today' => 'Сегодня',
			'download.timeline.yesterday' => 'Вчера',
			'download.timeline.thisWeek' => 'На этой неделе',
			'download.timeline.thisMonth' => 'В этом месяце',
			'download.errorTypes.network' => 'Проблема с сетью, повтор может помочь',
			'download.errorTypes.serverRejected' => 'Отклонено сервером, возможно, нужно войти заново',
			'download.errorTypes.notFound' => 'Ресурс отсутствует или был удалён',
			'download.errorTypes.diskFull' => 'Недостаточно места для хранения',
			'download.errorTypes.fileInUse' => 'Файл используется другой программой',
			'download.errorTypes.permission' => 'Нет разрешения на запись',
			'download.errorTypes.cancelled' => 'Отменено',
			'download.errorTypes.unknown' => 'Неизвестная ошибка',
			'download.errorDetailCopied' => 'Детали ошибки скопированы',
			'download.errorDetailCopyHint' => 'Нажмите и удерживайте, чтобы скопировать детали ошибки',
			'download.restoredPaused.banner' => ({required Object num}) => 'Незавершённые задачи из прошлого сеанса (${num}) были приостановлены',
			'download.restoredPaused.resume' => 'Возобновить все',
			'download.restoredPaused.dismiss' => 'Закрыть',
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
			'download.emptyTaskList' => 'Пока нет задач загрузки',
			'download.noMatchingTasks' => 'Нет подходящих задач',
			'download.deleteByDate.menuTitle' => 'Удаление по дате',
			'download.deleteByDate.dialogTitle' => 'Удаление по дате',
			'download.deleteByDate.description' => 'Массовое удаление задач загрузки по дате создания. Задачи с используемыми файлами пропускаются; задачи с отсутствующими файлами очищаются.',
			'download.deleteByDate.modeRange' => 'Диапазон дат',
			'download.deleteByDate.modeDays' => 'Старше',
			'download.deleteByDate.startDate' => 'Дата начала',
			'download.deleteByDate.endDate' => 'Дата окончания',
			'download.deleteByDate.notSet' => 'Не задано',
			'download.deleteByDate.daysUnit' => 'дн.',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Удалить задачи, созданные более ${days} дн. назад',
			'download.deleteByDate.noMatch' => 'Нет задач, соответствующих выбранному условию',
			'download.deleteByDate.invalidRange' => 'Дата начала должна быть не позже даты окончания',
			'download.deleteByDate.confirmTitle' => 'Подтвердите удаление',
			'download.deleteByDate.confirmContent' => ({required Object count}) => 'Удалить задач загрузки (${count}) и их файлы? Это действие нельзя отменить.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Удаление ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => 'Удалено задач: ${count}',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => 'Удалено задач: ${deleted}; пропущено: ${skipped} (используются)',
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
			_ => null,
		} ?? switch (path) {
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
			'download.category.manageTitle' => 'Управление категориями',
			'download.category.label' => 'Категории',
			'download.category.uncategorized' => 'Без категории',
			'download.category.manage' => 'Управление',
			'download.category.createShortcut' => 'Новая',
			'download.category.newCategoryHint' => 'Название новой категории',
			'download.category.createSuccess' => 'Категория создана',
			'download.category.createFailed' => 'Не удалось создать категорию',
			'download.category.nameEmpty' => 'Название категории не может быть пустым',
			'download.category.emptyHint' => 'Пока нет категорий. Создайте категорию для упорядочивания загрузок.',
			'download.category.moveTo' => 'Переместить в категорию',
			'download.category.moveToWithCount' => ({required Object count}) => 'Переместить элементов (${count}) в…',
			'download.category.moveSuccess' => ({required Object title}) => 'Перемещено в ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Перемещено в «Без категории»',
			'download.category.moveFailed' => 'Не удалось переместить',
			'download.category.renameTitle' => 'Переименовать категорию',
			'download.category.renameHint' => 'Введите название категории',
			'download.category.renameSuccess' => 'Категория переименована',
			'download.category.renameFailed' => 'Не удалось переименовать категорию',
			'download.category.deleteTitle' => 'Удалить категорию',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'Удалить категорию «${title}»? Элементы (${count}) перейдут в «Без категории». Файлы не удаляются.',
			'download.category.deleteSuccess' => 'Категория удалена',
			'download.category.deleteFailed' => 'Не удалось удалить категорию',
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
			'download.maxConcurrentDownloads' => 'Макс. одновременных загрузок',
			'download.maxConcurrentDownloadsDesc' => 'Число задач, загружаемых одновременно (1–5)',
			'download.stillInDevelopment' => 'Всё ещё в разработке',
			'download.saveToAppDirectory' => 'Сохранить в каталог приложения',
			'download.alreadyDownloadedWithQuality' => 'Уже скачано в том же качестве. Продолжить загрузку?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Уже скачано в качестве: ${qualities}. Продолжить загрузку?',
			'download.otherQualities' => 'Другое качество',
			'download.batchDownload.title' => 'Пакетная загрузка',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Задача уже выполняется, подождите.',
			'download.batchDownload.userCancelled' => 'Отменено пользователем',
			'download.batchDownload.failedToGetVideoInfo' => 'Не удалось получить информацию о видео',
			'download.batchDownload.failedToGetVideoSource' => 'Не удалось получить источник видео',
			'download.batchDownload.failedToGetGalleryInfo' => 'Не удалось получить информацию о галерее',
			'download.batchDownload.galleryNoImages' => 'В галерее нет изображений',
			'download.batchDownload.failedToGetSavePath' => 'Не удалось получить путь сохранения',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Ошибка пакетной загрузки: ${exception}',
			'download.batchDownload.selectQuality' => 'Выберите качество',
			'download.batchDownload.downloading' => 'Загрузка',
			'download.batchDownload.downloadResult' => 'Результат загрузки',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => 'Выбрано видео: ${count}',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => 'Выбрано галерей: ${count}',
			'download.batchDownload.qualityNote' => 'Если выбранное качество недоступно, будет использовано лучшее доступное',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Обработка ${current}/${total}',
			'download.batchDownload.queued' => 'В очереди',
			'download.batchDownload.success' => 'Успешно',
			'download.batchDownload.skipped' => 'Пропущено',
			'download.batchDownload.failed' => 'Ошибка',
			'download.batchDownload.failureDetails' => 'Детали ошибок',
			'download.batchDownload.reasonPrivateVideo' => 'Приватное видео',
			'download.batchDownload.reasonAlreadyExists' => 'Уже существует',
			'download.batchDownload.reasonNoSource' => 'Нет источника загрузки',
			'download.batchDownload.reasonNoSavePath' => 'Не удаётся получить путь сохранения',
			'download.batchDownload.reasonOther' => 'Другая ошибка',
			'download.batchDownload.startDownload' => 'Начать загрузку',
			'downloadNotifications.completedTitle' => 'Загрузка завершена',
			'downloadNotifications.failedTitle' => 'Ошибка загрузки',
			'downloadNotifications.completedBody' => ({required Object name}) => 'Загрузка ${name} успешно завершена',
			'downloadNotifications.failedBody' => ({required Object name}) => 'Не удалось скачать ${name}',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} скачан',
			'downloadNotifications.failedToast' => ({required Object name}) => 'Ошибка загрузки ${name}',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Сохранено в ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Сохранено как ${name} (файл с таким именем уже был)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Сохранено в папку приложения — не удалось записать ${target} (${reason})',
			'downloadNotifications.viewFolder' => 'Показать папку',
			'downloadNotifications.fixInSettings' => 'Исправить в настройках',
			'downloadNotifications.channelName' => 'Статус загрузки',
			'downloadNotifications.channelDescription' => 'Уведомления о завершённых и неудачных загрузках',
			'favorite.errors.addFailed' => 'Не удалось добавить',
			'favorite.errors.addSuccess' => 'Добавлено',
			'favorite.errors.deleteFolderFailed' => 'Не удалось удалить папку',
			'favorite.errors.deleteFolderSuccess' => 'Папка удалена',
			'favorite.errors.folderNameCannotBeEmpty' => 'Название папки не может быть пустым',
			'favorite.add' => 'Добавить',
			'favorite.addSuccess' => 'Добавлено',
			'favorite.addFailed' => 'Не удалось добавить',
			'favorite.remove' => 'Убрать',
			'favorite.removeSuccess' => 'Убрано',
			'favorite.removeFailed' => 'Не удалось убрать',
			'favorite.removeConfirmation' => 'Вы уверены, что хотите убрать этот элемент из избранного?',
			'favorite.removeConfirmationSuccess' => 'Элемент убран из избранного',
			'favorite.removeConfirmationFailed' => 'Не удалось убрать элемент из избранного',
			'favorite.createFolderSuccess' => 'Папка успешно создана',
			'favorite.createFolderFailed' => 'Не удалось создать папку',
			'favorite.createFolder' => 'Создать папку',
			'favorite.enterFolderName' => 'Введите название папки',
			'favorite.enterFolderNameHere' => 'Введите название папки...',
			'favorite.create' => 'Создать',
			'favorite.items' => 'Элементы',
			'favorite.newFolderName' => 'Новая папка',
			'favorite.searchFolders' => 'Поиск папок...',
			'favorite.searchItems' => 'Поиск элементов...',
			'favorite.createdAt' => 'Дата создания',
			'favorite.myFavorites' => 'Моё избранное',
			'favorite.deleteFolderTitle' => 'Удалить папку',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Вы уверены, что хотите удалить папку ${title}?',
			'favorite.removeItemTitle' => 'Убрать элемент',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Вы уверены, что хотите удалить элемент ${title}?',
			'favorite.removeItemSuccess' => 'Элемент убран из избранного',
			'favorite.removeItemFailed' => 'Не удалось убрать элемент из избранного',
			'favorite.localizeFavorite' => 'Локальное избранное',
			'favorite.editFolderTitle' => 'Изменить папку',
			'favorite.editFolderSuccess' => 'Папка успешно обновлена',
			'favorite.editFolderFailed' => 'Не удалось обновить папку',
			'favorite.searchTags' => 'Поиск тегов',
			'favorite.noTagsInFolder' => 'В этой папке пока нет тегов у элементов',
			'favorite.tagFilterMatchAll' => 'Показывает только элементы со всеми выбранными тегами',
			'favorite.clearSelectedTags' => 'Сбросить выбранные теги',
			'favorite.selectedTagCount' => ({required Object count}) => 'Выбрано: ${count}',
			'favorite.noMatchingTags' => 'Нет подходящих тегов',
			'translation.currentService' => 'Текущий сервис',
			'translation.testConnection' => 'Проверить подключение',
			'translation.testConnectionSuccess' => 'Подключение успешно проверено',
			'translation.testConnectionFailed' => 'Проверка подключения не пройдена',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Проверка подключения не пройдена: ${message}',
			'translation.translation' => 'Перевод',
			'translation.needVerification' => 'Требуется проверка',
			'translation.needVerificationContent' => 'Перед включением AI-перевода сначала проверьте подключение',
			'translation.confirm' => 'Подтвердить',
			'translation.disclaimer' => 'Отказ от ответственности',
			'translation.riskWarning' => 'Предупреждение о рисках',
			'translation.dureToRisk1' => 'Поскольку текст создаётся пользователями, он может содержать контент, нарушающий политику контента поставщика AI-услуг',
			'translation.dureToRisk2' => 'Неприемлемый контент может привести к приостановке ключа API или прекращению обслуживания',
			'translation.operationSuggestion' => 'Рекомендации по использованию',
			'translation.operationSuggestion1' => '1. Используйте перед строгой проверкой переводимого контента',
			'translation.operationSuggestion2' => '2. Избегайте перевода контента, связанного с насилием, взрослым контентом и т. п.',
			'translation.apiConfig' => 'Конфигурация API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Изменение конфигурации автоматически отключит AI-перевод; после включения потребуется пройти тест заново',
			'translation.apiAddress' => 'Адрес API',
			'translation.modelName' => 'Название модели',
			'translation.modelNameHintText' => 'Например: gpt-4-turbo',
			'translation.maxTokens' => 'Макс. токенов',
			'translation.maxTokensHintText' => 'Например: 32000',
			'translation.temperature' => 'Температура',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Нажмите кнопку теста, чтобы проверить доступность подключения к API',
			'translation.requestPreview' => 'Предпросмотр запроса',
			'translation.enableAITranslation' => 'Включить AI',
			'translation.enabled' => 'Включено',
			'translation.disabled' => 'Отключено',
			'translation.testing' => 'Проверка...',
			'translation.testNow' => 'Проверить сейчас',
			'translation.connectionStatus' => 'Статус подключения',
			'translation.success' => 'Успешно',
			'translation.failed' => 'Не удалось',
			'translation.information' => 'Информация',
			'translation.viewRawResponse' => 'Просмотреть исходный ответ',
			'translation.pleaseCheckInputParametersFormat' => 'Проверьте формат входных параметров',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Заполните адрес API, название модели и ключ',
			'translation.pleaseFillInValidConfigurationParameters' => 'Заполните корректные параметры конфигурации',
			'translation.pleaseCompleteConnectionTest' => 'Пройдите тест подключения',
			'translation.notConfigured' => 'Не настроено',
			'translation.apiEndpoint' => 'Конечная точка API',
			'translation.configuredKey' => 'Настроенный ключ',
			'translation.notConfiguredKey' => 'Ключ не настроен',
			'translation.authenticationStatus' => 'Статус аутентификации',
			'translation.thisFieldCannotBeEmpty' => 'Это поле не может быть пустым',
			'translation.apiKey' => 'Ключ API',
			'translation.apiKeyCannotBeEmpty' => 'Ключ API не может быть пустым',
			'translation.pleaseEnterValidNumber' => 'Введите корректное число',
			'translation.range' => 'Диапазон',
			'translation.mustBeGreaterThan' => 'Должно быть больше',
			'translation.invalidAPIResponse' => 'Некорректный ответ API',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Не удалось подключиться: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI-перевод не включён, включите его в настройках',
			'translation.goToSettings' => 'Перейти в настройки',
			'translation.disableAITranslation' => 'Отключить AI-перевод',
			'translation.currentValue' => 'Текущее значение',
			'translation.configureTranslationStrategy' => 'Настройте стратегию перевода',
			'translation.advancedSettings' => 'Расширенные настройки',
			'translation.translationPrompt' => 'Подсказка перевода',
			'translation.promptHint' => 'Введите подсказку перевода, используйте [TL] как заполнитель для целевого языка',
			'translation.promptHelperText' => 'Подсказка должна содержать [TL] как заполнитель для целевого языка',
			'translation.promptMustContainTargetLang' => 'Подсказка должна содержать заполнитель [TL]',
			'translation.aiTranslationWillBeDisabled' => 'AI-перевод будет отключён',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Из-за изменения базовой конфигурации AI-перевод будет отключён',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Из-за изменения подсказки перевода AI-перевод будет отключён',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Из-за изменения параметров конфигурации AI-перевод будет отключён',
			'translation.onlyOpenAIAPISupported' => 'Сейчас поддерживается только OpenAI-совместимый формат API (тело запроса application/json)',
			'translation.streamingTranslation' => 'Потоковый перевод',
			'translation.streamingTranslationSupported' => 'Потоковый перевод поддерживается',
			'translation.streamingTranslationNotSupported' => 'Потоковый перевод не поддерживается',
			'translation.streamingTranslationDescription' => 'Потоковый перевод отображает результаты в реальном времени в процессе перевода, обеспечивая лучший пользовательский опыт',
			'translation.usingFullUrlWithHash' => 'Используется полный URL (заканчивающийся на #)',
			'translation.baseUrlInputHelperText' => 'Если заканчивается на #, будет использоваться как фактический адрес запроса',
			'translation.currentActualUrl' => ({required Object url}) => 'Текущий фактический URL: ${url}',
			'translation.urlEndingWithHashTip' => 'URL, заканчивающийся на #, будет использоваться напрямую без добавления суффикса',
			'translation.streamingTranslationWarning' => 'Примечание: для этой функции требуется поддержка потоковой передачи со стороны API-сервиса; некоторые модели могут её не поддерживать',
			'translation.translationService' => 'Сервис перевода',
			'translation.translationServiceDescription' => 'Выберите предпочитаемый сервис перевода',
			'translation.googleTranslation' => 'Перевод Google',
			'translation.googleTranslationDescription' => 'Бесплатный онлайн-сервис перевода с поддержкой множества языков',
			'translation.aiTranslation' => 'AI-перевод',
			'translation.aiTranslationDescription' => 'Интеллектуальный сервис перевода на основе больших языковых моделей',
			'translation.deeplxTranslation' => 'Перевод DeepLX',
			'translation.deeplxTranslationDescription' => 'Открытая реализация перевода DeepL, обеспечивающая высокое качество перевода',
			'translation.googleTranslationFeatures' => 'Возможности',
			'translation.freeToUse' => 'Бесплатно',
			'translation.freeToUseDescription' => 'Настройка не требуется, готово к использованию',
			'translation.fastResponse' => 'Быстрый отклик',
			'translation.fastResponseDescription' => 'Высокая скорость перевода с низкой задержкой',
			'translation.stableAndReliable' => 'Стабильно и надёжно',
			'translation.stableAndReliableDescription' => 'На основе официального API Google',
			'translation.enabledDefaultService' => 'Включено — сервис перевода по умолчанию',
			'translation.notEnabled' => 'Не включено',
			'translation.deeplxTranslationService' => 'Сервис перевода DeepLX',
			'translation.deeplxDescription' => 'DeepLX — это открытая реализация перевода DeepL, поддерживающая режимы конечных точек Free, Pro и Official',
			'translation.serverAddress' => 'Адрес сервера',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Базовый адрес сервера DeepLX',
			'translation.endpointType' => 'Тип конечной точки',
			'translation.freeEndpoint' => 'Free — бесплатная конечная точка, возможны ограничения частоты',
			'translation.proEndpoint' => 'Pro — требуется dl_session, более стабильно',
			'translation.officialEndpoint' => 'Official — официальный формат API',
			'translation.finalRequestUrl' => 'Итоговый URL запроса',
			'translation.apiKeyOptional' => 'Ключ API (необязательно)',
			'translation.apiKeyOptionalHint' => 'Для доступа к защищённым сервисам DeepLX',
			'translation.apiKeyOptionalHelperText' => 'Некоторые сервисы DeepLX требуют ключ API для аутентификации',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Параметр dl_session необходим для режима Pro',
			'translation.dlSessionHelperText' => 'Параметр сессии, необходимый для конечной точки Pro; получается в аккаунте DeepL Pro',
			'translation.proModeRequiresDlSession' => 'Для режима Pro требуется dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Нажмите кнопку теста, чтобы проверить подключение к API DeepLX',
			'translation.enableDeepLXTranslation' => 'Включить перевод DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'Перевод DeepLX будет отключён из-за изменений конфигурации',
			'translation.translatedResult' => 'Результат перевода',
			'translation.testSuccess' => 'Тест пройден',
			'translation.pleaseFillInDeepLXServerAddress' => 'Заполните адрес сервера DeepLX',
			'translation.invalidAPIResponseFormat' => 'Некорректный формат ответа API',
			'translation.translationServiceReturnedError' => 'Сервис перевода вернул ошибку или пустой результат',
			'translation.connectionFailed' => 'Не удалось подключиться',
			'translation.translationFailed' => 'Перевод не выполнен',
			'translation.aiTranslationFailed' => 'AI-перевод не выполнен',
			'translation.deeplxTranslationFailed' => 'Перевод DeepLX не выполнен',
			'translation.aiTranslationTestFailed' => 'Тест AI-перевода не пройден',
			'translation.deeplxTranslationTestFailed' => 'Тест перевода DeepLX не пройден',
			'translation.streamingTranslationTimeout' => 'Тайм-аут потокового перевода, принудительная очистка ресурсов',
			'translation.translationRequestTimeout' => 'Тайм-аут запроса перевода',
			'translation.streamingTranslationDataTimeout' => 'Тайм-аут приёма данных потокового перевода',
			'translation.dataReceptionTimeout' => 'Тайм-аут приёма данных',
			'translation.streamDataParseError' => 'Ошибка разбора потоковых данных',
			'translation.streamingTranslationFailed' => 'Потоковый перевод не выполнен',
			'translation.fallbackTranslationFailed' => 'Резервный обычный перевод также не удался',
			'translation.translationSettings' => 'Настройки перевода',
			'translation.enableGoogleTranslation' => 'Включить перевод Google',
			'translation.thinking' => 'Размышление...',
			'translation.thoughtProcess' => 'Процесс рассуждения',
			'translation.modelCompatibility' => 'Совместимость моделей',
			'translation.modelCompatibilityDescription' => 'Адаптирует параметры запроса для современных моделей, таких как модели рассуждения (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'Модель рассуждений',
			'translation.reasoningModelDescription' => 'Для o1/o3, DeepSeek-R1, QwQ и др. Объединяет подсказку с сообщением пользователя, пропускает temperature и использует max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'Использовать max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'Новые конечные точки OpenAI требуют max_completion_tokens вместо устаревшего max_tokens',
			'translation.sendTemperature' => 'Отправлять temperature',
			'translation.sendTemperatureDescription' => 'Отключите для моделей, отвергающих параметр temperature (большинство моделей рассуждений)',
			'translation.showReasoningProcess' => 'Показывать процесс рассуждения',
			'translation.showReasoningProcessDescription' => 'Показывать сворачиваемые рассуждения моделей рассуждений в диалоге перевода',
			'translation.provider' => 'Провайдер',
			'translation.providerOpenAI' => 'OpenAI (и совместимые)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Поддерживаются OpenAI (и любая OpenAI-совместимая конечная точка), Anthropic и Google через SDK dartantic_ai',
			'translation.baseUrlOptionalHelperText' => 'Необязательно. Оставьте пустым, чтобы использовать конечную точку провайдера по умолчанию; заполните для OpenAI-совместимых/промежуточных точек',
			'translation.defaultEndpoint' => 'Конечная точка по умолчанию',
			'translation.providerPreset' => 'Пресет провайдера',
			'translation.selectProviderPreset' => 'Выберите пресет',
			'translation.presetCustom' => 'Пользовательский',
			'translation.presetApplied' => ({required Object name}) => 'Пресет применён: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI Рассуждение (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude Рассуждение (расширенное мышление)',
			'translation.presetNames.gemini' => 'Google Gemini (нативно)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini Рассуждение (мышление)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek Рассуждение (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Получить список моделей',
			'translation.fetchingModels' => 'Получение...',
			'translation.selectModel' => 'Выберите модель',
			'translation.searchModel' => 'Поиск модели',
			'translation.noModelsFound' => 'Модели не найдены',
			'bottomNav.video' => 'Видео',
			'bottomNav.gallery' => 'Фото',
			'bottomNav.subscription' => 'Лента',
			'bottomNav.community' => 'Форум',
			'bottomNav.localMedia' => 'Файлы',
			'navigationOrderSettings.title' => 'Настройки порядка навигации',
			'navigationOrderSettings.customNavigationOrder' => 'Свой порядок навигации',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Перетащите, чтобы изменить порядок отображения страниц на нижней панели навигации и в боковом меню',
			'navigationOrderSettings.restartRequired' => 'Требуется перезапуск приложения',
			'navigationOrderSettings.navigationItemSorting' => 'Сортировка элементов навигации',
			'navigationOrderSettings.done' => 'Готово',
			'navigationOrderSettings.edit' => 'Изменить',
			'navigationOrderSettings.reset' => 'Сбросить',
			'navigationOrderSettings.previewEffect' => 'Предпросмотр',
			'navigationOrderSettings.bottomNavigationPreview' => 'Предпросмотр нижней навигации:',
			'navigationOrderSettings.sidebarPreview' => 'Предпросмотр бокового меню:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Подтвердите сброс порядка навигации',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Вы уверены, что хотите сбросить порядок навигации к настройкам по умолчанию?',
			'navigationOrderSettings.cancel' => 'Отмена',
			'navigationOrderSettings.show' => 'Показать',
			'navigationOrderSettings.hide' => 'Скрыть',
			'navigationOrderSettings.hidden' => 'Скрыто',
			'navigationOrderSettings.hideHint' => 'Нажмите значок глаза, чтобы показать или скрыть разделы «Сообщество» и локальные файлы',
			'navigationOrderSettings.videoDescription' => 'Просматривайте популярный видеоконтент',
			'navigationOrderSettings.galleryDescription' => 'Просматривайте изображения и галереи',
			'navigationOrderSettings.subscriptionDescription' => 'Смотрите последний контент от пользователей, на которых вы подписаны',
			'navigationOrderSettings.forumDescription' => 'Участвуйте в обсуждениях сообщества',
			'navigationOrderSettings.newsDescription' => 'Просматривайте официальные новости, статьи и трансляции',
			'navigationOrderSettings.communityDescription' => 'Обсуждения на форуме, а также официальные новости, статьи и трансляции',
			'navigationOrderSettings.localMediaDescription' => 'Просматривайте видео и изображения, хранящиеся на этом устройстве',
			'news.title' => 'Новости',
			'news.newsUpdates' => 'Обновления новостей',
			'news.articles' => 'Статьи',
			'news.broadcast' => 'Трансляция',
			'news.openInBrowser' => 'Открыть в браузере',
			'displaySettings.title' => 'Настройки отображения',
			'displaySettings.layoutSettings' => 'Настройки макета',
			'displaySettings.layoutSettingsDesc' => 'Настройте число столбцов и точки перелома',
			'displaySettings.gridLayout' => 'Сетка',
			'displaySettings.navigationOrderSettings' => 'Настройки порядка навигации',
			'displaySettings.customNavigationOrder' => 'Свой порядок навигации',
			'displaySettings.customNavigationOrderDesc' => 'Настройте порядок отображения страниц на нижней панели навигации и в боковом меню',
			'layoutSettings.title' => 'Настройки макета',
			'layoutSettings.descriptionTitle' => 'Описание настройки макета',
			'layoutSettings.descriptionContent' => 'Настроенная здесь конфигурация определяет число столбцов на страницах списков видео и галерей. Выберите автоматический режим, чтобы система подстраивалась под ширину экрана, или ручной режим, чтобы зафиксировать число столбцов.',
			'layoutSettings.layoutMode' => 'Режим макета',
			'layoutSettings.reset' => 'Сбросить',
			'layoutSettings.autoMode' => 'Автоматический режим',
			'layoutSettings.autoModeDesc' => 'Автоматически подстраивается под ширину экрана',
			'layoutSettings.manualMode' => 'Ручной режим',
			'layoutSettings.manualModeDesc' => 'Использовать фиксированное число столбцов',
			'layoutSettings.manualSettings' => 'Ручные настройки',
			'layoutSettings.fixedColumns' => 'Фиксированные столбцы',
			'layoutSettings.columns' => 'столбцов',
			'layoutSettings.breakpointConfig' => 'Настройка точек перелома',
			'layoutSettings.add' => 'Добавить',
			'layoutSettings.defaultColumns' => 'Столбцы по умолчанию',
			'layoutSettings.defaultColumnsDesc' => 'Отображение по умолчанию для больших экранов',
			'layoutSettings.previewEffect' => 'Предпросмотр',
			'layoutSettings.screenWidth' => 'Ширина экрана',
			'layoutSettings.addBreakpoint' => 'Добавить точку перелома',
			'layoutSettings.editBreakpoint' => 'Изменить точку перелома',
			'layoutSettings.deleteBreakpoint' => 'Удалить точку перелома',
			'layoutSettings.screenWidthLabel' => 'Ширина экрана',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Столбцы',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Введите ширину',
			'layoutSettings.enterValidWidth' => 'Введите корректную ширину',
			'layoutSettings.widthCannotExceed9999' => 'Ширина не может превышать 9999',
			'layoutSettings.breakpointAlreadyExists' => 'Точка перелома уже существует',
			'layoutSettings.enterColumns' => 'Введите число столбцов',
			'layoutSettings.enterValidColumns' => 'Введите корректное число столбцов',
			'layoutSettings.columnsCannotExceed12' => 'Число столбцов не может превышать 12',
			'layoutSettings.breakpointConflict' => 'Точка перелома уже существует',
			'layoutSettings.confirmResetLayoutSettings' => 'Сбросить настройки макета',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Вы уверены, что хотите сбросить все настройки макета до значений по умолчанию?\n\nБудет восстановлено:\n• Автоматический режим\n• Конфигурация точек перелома по умолчанию',
			'layoutSettings.resetToDefaults' => 'Сбросить к значениям по умолчанию',
			'layoutSettings.confirmDeleteBreakpoint' => 'Удалить точку перелома',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Вы уверены, что хотите удалить точку перелома ${width}px?',
			'layoutSettings.noCustomBreakpoints' => 'Нет пользовательских точек перелома, используются столбцы по умолчанию',
			'layoutSettings.breakpointRange' => 'Диапазон точек перелома',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Изменить',
			'layoutSettings.delete' => 'Удалить',
			'layoutSettings.cancel' => 'Отмена',
			'layoutSettings.save' => 'Сохранить',
			'mediaPlayer.videoPlayerError' => 'Ошибка видеоплеера',
			'mediaPlayer.videoLoadFailed' => 'Не удалось загрузить видео',
			'mediaPlayer.videoCodecNotSupported' => 'Видеокодек не поддерживается',
			'mediaPlayer.networkConnectionIssue' => 'Проблема с подключением к сети',
			'mediaPlayer.insufficientPermission' => 'Недостаточно прав',
			'mediaPlayer.unsupportedVideoFormat' => 'Неподдерживаемый формат видео',
			'mediaPlayer.retry' => 'Повторить',
			'mediaPlayer.externalPlayer' => 'Внешний плеер',
			'mediaPlayer.detailedErrorInfo' => 'Подробная информация об ошибке',
			'mediaPlayer.format' => 'Формат',
			'mediaPlayer.suggestion' => 'Рекомендация',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Устройства Android ограниченно поддерживают формат WEBM. Рекомендуется использовать внешний плеер или скачать приложение-плеер с поддержкой WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'Текущее устройство не поддерживает кодек для этого формата видео',
			'mediaPlayer.checkNetworkConnection' => 'Проверьте подключение к сети и повторите попытку',
			_ => null,
		} ?? switch (path) {
			'mediaPlayer.appMayLackMediaPermission' => 'Возможно, у приложения нет необходимых разрешений на воспроизведение медиа',
			'mediaPlayer.tryOtherVideoPlayer' => 'Попробуйте использовать другой видеоплеер',
			'mediaPlayer.unrecognizedVideoFormat' => 'Нераспознанный видеофайл',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Возможно, ссылка устарела или ответ не является видео. Повторите попытку или откройте в другом приложении.',
			'mediaPlayer.accessDenied' => 'Сервер отклонил этот запрос (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Ссылка для воспроизведения, скорее всего, устарела. Нажмите «Повторить», чтобы получить её заново, или откройте в другом приложении.',
			'mediaPlayer.mute' => 'Без звука',
			'mediaPlayer.unmute' => 'Включить звук',
			'mediaPlayer.video' => 'ВИДЕО',
			'mediaPlayer.serverSelector' => 'Выбор CDN-сервера',
			'mediaPlayer.serverSelectorDescription' => 'Выберите сервер с наименьшей задержкой для наилучшего воспроизведения',
			'mediaPlayer.retestSpeed' => 'Повторить тест скорости',
			'mediaPlayer.waitingForSpeedTest' => 'Ожидание теста скорости',
			'mediaPlayer.testingSpeed' => 'Проверка скорости...',
			'mediaPlayer.testFailed' => 'Тест не пройден',
			'mediaPlayer.loadingServerList' => 'Загрузка списка серверов...',
			'mediaPlayer.noAvailableServers' => 'Нет доступных серверов',
			'mediaPlayer.refreshServerList' => 'Обновить список серверов',
			'mediaPlayer.cannotGetSource' => 'Не удаётся получить источник текущего видео',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Переключено на сервер: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'Всего серверов: ${count}',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Код состояния: ${code}',
			'mediaPlayer.connectionFailed' => 'Не удалось подключиться',
			'mediaPlayer.connectionTimeout' => 'Тайм-аут подключения',
			'mediaPlayer.networkError' => 'Ошибка сети',
			'mediaPlayer.sslError' => 'Ошибка SSL-сертификата',
			'mediaPlayer.testCompleted' => 'Тест завершён',
			'mediaPlayer.local' => 'Локально',
			'mediaPlayer.unknown' => 'Неизвестно',
			'mediaPlayer.localVideoPathEmpty' => 'Путь к локальному видео пуст',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Локальный видеофайл не существует: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Не удалось воспроизвести локальное видео: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Перетащите сюда видеофайл для воспроизведения',
			'mediaPlayer.supportedFormats' => 'Поддерживаемые форматы: MP4, MKV, AVI, MOV, WEBM и др.',
			'mediaPlayer.noSupportedVideoFile' => 'Поддерживаемый видеофайл не найден',
			'mediaPlayer.retryingOpenVideoLink' => 'Не удалось открыть ссылку на видео, повторная попытка',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Не удалось загрузить декодер: ${event}. Попробуйте переключиться на программное декодирование в настройках плеера и заново открыть страницу',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Ошибка загрузки видео: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Обнаружены повторяющиеся сбои воспроизведения. Перейдите в «Настройки» > «Диагностика и обратная связь», чтобы экспортировать логи.',
			'mediaPlayer.openSettingsAction' => 'Просмотреть',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Уведомление воспроизведения: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Проверьте сеть; воспроизведение может прерываться',
			'mediaPlayer.notice.audioTrackUnavailable' => 'Звук недоступен; видео продолжает воспроизводиться',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Переключено на программное декодирование; может расходовать больше энергии',
			'mediaPlayer.notice.videoDecodeProblem' => 'Попробуйте другое качество; изображение может сбоить',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Экспортируйте логи, чтобы сообщить о повторяющихся проблемах воспроизведения',
			'mediaPlayer.notice.issuesSheetTitle' => 'Проблемы воспроизведения',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'Произошло раз: ${count}',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'На ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'Проблемы не зафиксированы',
			'mediaPlayer.notice.exportLogsAction' => 'Экспортировать логи',
			'mediaPlayer.imageLoadFailed' => 'Не удалось загрузить изображение',
			'mediaPlayer.unsupportedImageFormat' => 'Неподдерживаемый формат изображения',
			'mediaPlayer.tryOtherViewer' => 'Попробуйте использовать другой просмотрщик',
			'diagnostics.infoSectionTitle' => 'Сведения о диагностике',
			'diagnostics.appVersionLabel' => 'Версия приложения',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Использование памяти: ${memMB} МБ',
			'diagnostics.deviceInfoUnavailable' => 'Не удалось получить информацию об устройстве',
			'diagnostics.secureStorageLabel' => 'Защищённое хранилище',
			'diagnostics.secureStorageHealthy' => 'Доступно',
			'diagnostics.secureStorageRecovered' => 'Восстановлено сбросом (прежние данные удалены)',
			'diagnostics.secureStorageUnavailable' => 'Недоступно (вход сохранён с резервным шифрованием)',
			'diagnostics.secureStoragePlatformOptOut' => 'Локальное шифрование согласно политике платформы (в macOS системная связка ключей не используется)',
			'diagnostics.secureStorageDualWrite' => ' (включена защита двойной записью)',
			'diagnostics.schemaHealthLabel' => 'Схема базы данных',
			'diagnostics.schemaHealthOk' => 'ОК',
			'diagnostics.schemaHealthRepairedNow' => 'Восстановлена защитным механизмом при этом запуске (миграция не сработала)',
			'diagnostics.schemaHealthRepairedBefore' => 'Ранее была восстановлена защитным механизмом',
			'diagnostics.logPolicySectionTitle' => 'Политика логов',
			'diagnostics.configServiceUnavailable' => 'Служба конфигурации не инициализирована. Невозможно изменить политику логов.',
			'diagnostics.enableLoggingTitle' => 'Вести журнал',
			'diagnostics.enableLoggingSubtitle' => 'Отключите, чтобы прекратить запись новых логов',
			'diagnostics.enableLogPersistenceTitle' => 'Сохранять логи на диск',
			'diagnostics.enableLogPersistenceSubtitle' => 'Отключите, чтобы хранить логи только в памяти и прекратить запись на диск',
			'diagnostics.minLogLevelTitle' => 'Минимальный уровень логов',
			'diagnostics.minLogLevelSubtitle' => 'Логи ниже этого уровня будут отфильтрованы',
			'diagnostics.maxFileSizeTitle' => 'Ограничение размера одного файла',
			'diagnostics.maxFileSizeSubtitle' => 'Ротация при достижении порога',
			'diagnostics.rotatedFileCountTitle' => 'Число ротируемых файлов основного лога',
			'diagnostics.rotatedFileCountSubtitle' => 'Число сохраняемых файлов без учёта текущего',
			'diagnostics.hangFileSizeTitle' => 'Ограничение размера логов зависаний',
			'diagnostics.hangFileSizeSubtitle' => 'Управляйте ростом файла hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'Число ротируемых файлов логов зависаний',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Управляйте объёмом сохраняемой истории hang_events',
			'diagnostics.healthSectionTitle' => 'Состояние логов',
			'diagnostics.refreshMetrics' => 'Обновить метрики',
			'diagnostics.toolsSectionTitle' => 'Инструменты',
			'diagnostics.privacyNotice' => 'Логи могут содержать конфиденциальную информацию, например данные аккаунта и параметры запросов. Не публикуйте полные логи в задачах; сначала проверьте их и отправьте по электронной почте.',
			'diagnostics.exportLogsTitle' => 'Экспорт логов',
			'diagnostics.exportLogsSubtitle' => 'Проверьте личные данные перед отправкой разработчикам',
			'diagnostics.viewLogsTitle' => 'Просмотр логов',
			'diagnostics.viewLogsSubtitle' => 'Просмотр логов выполнения в реальном времени',
			'diagnostics.copySupportEmailTitle' => 'Копировать адрес поддержки',
			'diagnostics.reportIssueTitle' => 'Сообщить о проблеме',
			'diagnostics.reportIssueSubtitle' => 'Опишите шаги воспроизведения на GitHub (не прикрепляйте полные логи)',
			'diagnostics.healthSummaryUnavailable' => 'Данных о состоянии логов пока нет',
			'diagnostics.healthMetricsUnavailable' => 'Метрики состояния ещё не собраны',
			'diagnostics.healthNoRiskIndicators' => 'Индикаторов риска не обнаружено',
			'diagnostics.healthAlert.flushFailureTitle' => 'Сбои сброса на диск',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Запись логов деградировала',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'Файловый приёмник в деградированном состоянии',
			'diagnostics.healthAlert.queueBacklogTitle' => 'Очередь записи переполнена',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (порог=${threshold}, может увеличить использование памяти)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Высокая задержка сброса',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Слишком много потерянных логов',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (порог=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Сработало ограничение частоты',
			'diagnostics.healthAlert.exportFailedTitle' => 'Сбои экспорта логов',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'Файл лога близок к пределу размера',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (высокое давление ротации ввода-вывода)',
			'diagnostics.toast.logServiceNotInitialized' => 'Служба логов не инициализирована',
			'diagnostics.toast.exportSuccess' => 'Логи экспортированы. Проверьте личные данные перед отправкой по электронной почте.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'Ошибка экспорта: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'Адрес поддержки скопирован. Вставьте его в почтовый клиент и прикрепите логи.',
			'diagnostics.shareSubject' => 'Диагностические логи LoveIwara (содержат конфиденциальные данные, делитесь осторожно)',
			'logViewer.title' => 'Просмотр логов',
			'logViewer.searchHint' => 'Поиск по логам...',
			'logViewer.emptyState' => 'Нет логов',
			'logViewer.copiedToClipboard' => 'Скопировано в буфер обмена',
			'crashRecoveryDialog.title' => 'Приложение неожиданно закрылось',
			'crashRecoveryDialog.description' => 'Мы обнаружили некорректное завершение в прошлом сеансе. Экспортируйте логи диагностики и отправьте их разработчику по электронной почте, чтобы помочь исправить проблему.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Прошлая версия: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Прошлый запуск: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Последнее исключение: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'В прошлый раз было обнаружено зависание интерфейса, и оно было автоматически устранено',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'В прошлый раз было обнаружено возможное зависание интерфейса длительностью около ${stalledMs} мс',
			'crashRecoveryDialog.exportGuide' => 'Перейдите в «Настройки» > «Диагностика и обратная связь» > «Экспорт логов».',
			'crashRecoveryDialog.privacyHint' => 'Логи могут содержать личные данные. Проверьте их перед отправкой на адрес:',
			'crashRecoveryDialog.issueWarning' => 'Не прикрепляйте полные логи публично в задачах GitHub',
			'crashRecoveryDialog.acknowledge' => 'Понятно',
			'crashRecoveryDialog.supportEmailCopied' => 'Адрес скопирован',
			'linkInputDialog.title' => 'Ввод ссылки',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Поддерживается распознавание нескольких ссылок ${webName} с быстрым переходом на соответствующую страницу в приложении (отделяйте ссылки от другого текста пробелами)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Введите ссылку ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'Введите ссылку',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'Действительная ссылка ${webName} не обнаружена',
			'linkInputDialog.multipleLinksDetected' => 'Обнаружено несколько ссылок, выберите одну:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Недействительная ссылка ${webName}',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Ошибка разбора ссылки: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Неподдерживаемая ссылка',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Этот тип ссылки нельзя открыть напрямую в приложении, требуется внешний браузер.\n\nОткрыть эту ссылку в браузере?',
			'linkInputDialog.openInBrowser' => 'Открыть в браузере',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Подтвердите открытие браузера',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'Следующая ссылка будет открыта во внешнем браузере:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Вы уверены, что хотите продолжить?',
			'linkInputDialog.browserOpenFailed' => 'Не удалось открыть ссылку',
			'linkInputDialog.unsupportedLink' => 'Неподдерживаемая ссылка',
			'linkInputDialog.cancel' => 'Отмена',
			'linkInputDialog.confirm' => 'Открыть в браузере',
			'log.logManagement' => 'Управление логами',
			'log.enableLogPersistence' => 'Сохранять логи в базе данных',
			'log.enableLogPersistenceDesc' => 'Сохранять логи в базе данных для анализа',
			'log.logDatabaseSizeLimit' => 'Лимит размера базы данных логов',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Текущий: ${size}',
			'log.exportCurrentLogs' => 'Экспортировать текущие логи',
			'log.exportCurrentLogsDesc' => 'Экспортировать текущие логи приложения, чтобы помочь разработчикам диагностировать проблемы',
			'log.exportHistoryLogs' => 'Экспортировать историю логов',
			'log.exportHistoryLogsDesc' => 'Экспортировать логи за указанный диапазон дат',
			'log.exportMergedLogs' => 'Экспортировать объединённые логи',
			'log.exportMergedLogsDesc' => 'Экспортировать объединённые логи за указанный диапазон дат',
			'log.showLogStats' => 'Показать статистику логов',
			'log.logExportSuccess' => 'Экспорт логов выполнен',
			'log.logExportFailed' => ({required Object error}) => 'Ошибка экспорта логов: ${error}',
			'log.showLogStatsDesc' => 'Просмотр статистики по различным типам логов',
			'log.logExtractFailed' => ({required Object error}) => 'Не удалось получить статистику логов: ${error}',
			'log.clearAllLogs' => 'Очистить все логи',
			'log.clearAllLogsDesc' => 'Очистить все данные логов',
			'log.confirmClearAllLogs' => 'Подтвердите очистку',
			'log.confirmClearAllLogsDesc' => 'Вы уверены, что хотите очистить все данные логов? Это действие нельзя отменить.',
			'log.clearAllLogsSuccess' => 'Логи успешно очищены',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Не удалось очистить логи: ${error}',
			'log.unableToGetLogSizeInfo' => 'Не удалось получить информацию о размере логов',
			'log.currentLogSize' => 'Текущий размер логов:',
			'log.logCount' => 'Количество логов:',
			'log.logCountUnit' => 'логов',
			'log.logSizeLimit' => 'Лимит размера логов:',
			'log.usageRate' => 'Использование:',
			'log.exceedLimit' => 'Превышен лимит',
			'log.remaining' => 'Осталось',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Текущий размер логов превышен, очистите старые логи или увеличьте лимит размера',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'Текущий размер логов почти достиг лимита, очистите старые логи',
			'log.cleaningOldLogs' => 'Очистка старых логов...',
			'log.logCleaningCompleted' => 'Очистка логов завершена',
			'log.logCleaningProcessMayNotBeCompleted' => 'Процесс очистки логов может быть не завершён',
			'log.cleanExceededLogs' => 'Очистить превышающие лимит логи',
			'log.noLogsToExport' => 'Нет логов для экспорта',
			'log.exportingLogs' => 'Экспорт логов...',
			'log.noHistoryLogsToExport' => 'Нет истории логов для экспорта, сначала некоторое время попользуйтесь приложением',
			'log.selectLogDate' => 'Выберите дату логов',
			'log.today' => 'Сегодня',
			'log.selectMergeRange' => 'Выберите диапазон объединения',
			'log.selectMergeRangeHint' => 'Выберите временной диапазон логов для объединения',
			'log.selectMergeRangeDays' => ({required Object days}) => 'Последние ${days} дней',
			'log.logStats' => 'Статистика логов',
			'log.todayLogs' => ({required Object count}) => 'Логи за сегодня: ${count}',
			'log.recent7DaysLogs' => ({required Object count}) => 'Логи за последние 7 дней: ${count}',
			'log.totalLogs' => ({required Object count}) => 'Всего логов: ${count}',
			'log.setLogDatabaseSizeLimit' => 'Задать лимит размера базы данных логов',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Текущий размер логов: ${size}',
			'log.warning' => 'Предупреждение',
			'log.newSizeLimit' => ({required Object size}) => 'Новый лимит размера: ${size}',
			'log.confirmToContinue' => 'Подтвердите для продолжения',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Лимит размера логов установлен: ${size}',
			'emoji.recentlyUsed' => 'Недавние',
			'emoji.insertedCount' => ({required Object count}) => 'Вставлено: ${count}',
			'emoji.name' => 'Эмодзи',
			'emoji.size' => 'Размер',
			'emoji.small' => 'Маленький',
			'emoji.medium' => 'Средний',
			'emoji.large' => 'Большой',
			'emoji.extraLarge' => 'Очень большой',
			'emoji.copyEmojiLinkSuccess' => 'Ссылка на эмодзи скопирована',
			'emoji.preview' => 'Просмотр эмодзи',
			'emoji.library' => 'Библиотека эмодзи',
			'emoji.noEmojis' => 'Нет эмодзи',
			'emoji.clickToAddEmojis' => 'Нажмите кнопку в правом верхнем углу, чтобы добавить эмодзи',
			'emoji.addEmojis' => 'Добавить эмодзи',
			'emoji.imagePreview' => 'Просмотр изображения',
			'emoji.imageLoadFailed' => 'Не удалось загрузить изображение',
			'emoji.loading' => 'Загрузка...',
			'emoji.delete' => 'Удалить',
			'emoji.close' => 'Закрыть',
			'emoji.deleteImage' => 'Удалить изображение',
			'emoji.confirmDeleteImage' => 'Вы уверены, что хотите удалить это изображение?',
			'emoji.cancel' => 'Отмена',
			'emoji.batchDelete' => 'Пакетное удаление',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Вы уверены, что хотите удалить выбранные изображения (${count})? Это действие нельзя отменить.',
			'emoji.deleteSuccess' => 'Успешно удалено',
			'emoji.addImage' => 'Добавить изображение',
			'emoji.addImageByUrl' => 'Добавить по URL',
			'emoji.addImageUrl' => 'Добавить URL изображения',
			'emoji.imageUrl' => 'URL изображения',
			'emoji.enterImageUrl' => 'Введите URL изображения',
			'emoji.add' => 'Добавить',
			'emoji.batchImport' => 'Пакетный импорт',
			'emoji.enterJsonUrlArray' => 'Введите массив URL в формате JSON:',
			'emoji.formatExample' => 'Пример формата:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Вставьте массив URL в формате JSON',
			'emoji.import' => 'Импорт',
			'emoji.importSuccess' => ({required Object count}) => 'Успешно импортировано изображений: ${count}',
			'emoji.jsonFormatError' => 'Ошибка формата JSON, проверьте ввод',
			'emoji.createGroup' => 'Создать группу эмодзи',
			'emoji.groupName' => 'Название группы',
			'emoji.enterGroupName' => 'Введите название группы',
			'emoji.create' => 'Создать',
			'emoji.editGroupName' => 'Изменить название группы',
			'emoji.save' => 'Сохранить',
			'emoji.deleteGroup' => 'Удалить группу',
			'emoji.confirmDeleteGroup' => 'Вы уверены, что хотите удалить эту группу эмодзи? Все изображения в группе также будут удалены.',
			'emoji.imageCount' => ({required Object count}) => 'Изображений: ${count}',
			'emoji.selectEmoji' => 'Выберите эмодзи',
			'emoji.noEmojisInGroup' => 'В этой группе нет эмодзи',
			'emoji.goToSettingsToAddEmojis' => 'Перейдите в настройки, чтобы добавить эмодзи',
			'emoji.emojiManagement' => 'Управление эмодзи',
			'emoji.manageEmojiGroupsAndImages' => 'Управление группами и изображениями эмодзи',
			'emoji.uploadLocalImages' => 'Загрузить локальные изображения',
			'emoji.uploadingImages' => 'Загрузка изображений',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Загрузка изображений (${count}), подождите...',
			'emoji.doNotCloseDialog' => 'Не закрывайте это окно',
			'emoji.uploadSuccess' => ({required Object count}) => 'Успешно загружено изображений: ${count}',
			'emoji.uploadFailed' => ({required Object count}) => 'Не удалось: ${count}',
			'emoji.uploadFailedMessage' => 'Не удалось загрузить изображение, проверьте подключение к сети или формат файла',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Произошла ошибка при загрузке: ${error}',
			'searchFilter.selectField' => 'Выберите поле',
			'searchFilter.add' => 'Добавить',
			'searchFilter.clear' => 'Очистить',
			'searchFilter.clearAll' => 'Очистить всё',
			'searchFilter.generatedQuery' => 'Сформированный запрос',
			'searchFilter.copyToClipboard' => 'Копировать в буфер обмена',
			'searchFilter.copied' => 'Скопировано',
			'searchFilter.filterCount' => ({required Object count}) => 'Фильтров: ${count}',
			'searchFilter.filterSettings' => 'Настройки фильтра',
			'searchFilter.field' => 'Поле',
			'searchFilter.operator' => 'Оператор',
			'searchFilter.language' => 'Язык',
			'searchFilter.value' => 'Значение',
			'searchFilter.dateRange' => 'Диапазон дат',
			'searchFilter.numberRange' => 'Диапазон чисел',
			'searchFilter.from' => 'От',
			'searchFilter.to' => 'До',
			'searchFilter.date' => 'Дата',
			'searchFilter.number' => 'Число',
			'searchFilter.boolean' => 'Логическое',
			'searchFilter.tags' => 'Теги',
			'searchFilter.select' => 'Выбрать',
			'searchFilter.clickToSelectDate' => 'Нажмите, чтобы выбрать дату',
			'searchFilter.pleaseEnterValidNumber' => 'Введите корректное число',
			'searchFilter.pleaseEnterValidDate' => 'Введите корректный формат даты (ГГГГ-ММ-ДД)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'Начальное значение должно быть меньше конечного',
			'searchFilter.startDateMustBeBeforeEndDate' => 'Дата начала должна быть раньше даты окончания',
			'searchFilter.pleaseFillStartValue' => 'Укажите начальное значение',
			'searchFilter.pleaseFillEndValue' => 'Укажите конечное значение',
			'searchFilter.rangeValueFormatError' => 'Ошибка формата значения диапазона',
			'searchFilter.contains' => 'Содержит',
			'searchFilter.equals' => 'Равно',
			'searchFilter.notEquals' => 'Не равно',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Диапазон',
			'searchFilter.kIn' => 'Содержит любой из',
			'searchFilter.notIn' => 'Не содержит ни одного из',
			'searchFilter.username' => 'Имя пользователя',
			'searchFilter.nickname' => 'Псевдоним',
			'searchFilter.registrationDate' => 'Дата регистрации',
			'searchFilter.description' => 'Описание',
			'searchFilter.title' => 'Заголовок',
			'searchFilter.body' => 'Текст',
			'searchFilter.author' => 'Автор',
			'searchFilter.publishDate' => 'Дата публикации',
			'searchFilter.private' => 'Приватное',
			'searchFilter.duration' => 'Длительность (в секундах)',
			'searchFilter.likes' => 'Отметки «Нравится»',
			'searchFilter.views' => 'Просмотры',
			'searchFilter.comments' => 'Комментарии',
			'searchFilter.rating' => 'Рейтинг',
			'searchFilter.imageCount' => 'Количество изображений',
			'searchFilter.videoCount' => 'Количество видео',
			'searchFilter.createDate' => 'Дата создания',
			'searchFilter.content' => 'Контент',
			'searchFilter.all' => 'Все',
			'searchFilter.adult' => 'Для взрослых',
			'searchFilter.general' => 'Общее',
			'searchFilter.yes' => 'Да',
			'searchFilter.no' => 'Нет',
			'searchFilter.users' => 'Пользователи',
			'searchFilter.videos' => 'Видео',
			'searchFilter.images' => 'Изображения',
			'searchFilter.posts' => 'Публикации',
			'searchFilter.forumThreads' => 'Темы форума',
			'searchFilter.forumPosts' => 'Публикации форума',
			'searchFilter.playlists' => 'Плейлисты',
			'searchFilter.sortTypes.relevance' => 'По релевантности',
			'searchFilter.sortTypes.latest' => 'Новые',
			'searchFilter.sortTypes.views' => 'По просмотрам',
			'searchFilter.sortTypes.likes' => 'По отметкам «Нравится»',
			'searchFilter.drawerSubtitle' => 'Изменения применяются сразу',
			'firstTimeSetup.welcome.title' => 'Добро пожаловать',
			'firstTimeSetup.welcome.subtitle' => 'Начнём персональную настройку',
			'firstTimeSetup.welcome.description' => 'Всего несколько шагов, чтобы настроить всё под вас',
			'firstTimeSetup.basic.title' => 'Основные настройки',
			'firstTimeSetup.basic.subtitle' => 'Настройте под себя',
			'firstTimeSetup.basic.description' => 'Выберите подходящие вам предпочтения',
			'firstTimeSetup.network.title' => 'Настройки сети',
			'firstTimeSetup.network.subtitle' => 'Настройте параметры сети',
			'firstTimeSetup.network.description' => 'Настройте под свою сетевую среду',
			'firstTimeSetup.network.tip' => 'Чтобы изменения вступили в силу, после успешной настройки требуется перезапуск',
			'firstTimeSetup.theme.title' => 'Настройки темы',
			'firstTimeSetup.theme.subtitle' => 'Выберите предпочитаемый вид',
			'firstTimeSetup.theme.description' => 'Персонализируйте визуальное оформление',
			'firstTimeSetup.player.title' => 'Настройки плеера',
			'firstTimeSetup.player.subtitle' => 'Настройте элементы управления воспроизведением',
			'firstTimeSetup.player.description' => 'Быстрая настройка параметров воспроизведения',
			'firstTimeSetup.spatial.title' => 'Пространственное воспроизведение',
			'firstTimeSetup.spatial.subtitle' => 'Просмотр на гарнитуре',
			'firstTimeSetup.spatial.description' => 'На гарнитуре видео и галереи появляются в окружающем пространстве, а не внутри этой плавающей панели',
			'firstTimeSetup.completion.title' => 'Завершение настройки',
			'firstTimeSetup.completion.subtitle' => 'Вы готовы начать',
			'firstTimeSetup.completion.description' => 'Прочитайте и примите соответствующие соглашения',
			'firstTimeSetup.completion.agreementTitle' => 'Пользовательское соглашение и правила сообщества',
			'firstTimeSetup.completion.agreementDesc' => 'Перед использованием приложения внимательно прочитайте и примите наше пользовательское соглашение и правила сообщества. Эти условия помогают поддерживать здоровую атмосферу.',
			'firstTimeSetup.completion.checkboxTitle' => 'Я прочитал(а) и принимаю пользовательское соглашение и правила сообщества',
			'firstTimeSetup.completion.checkboxSubtitle' => 'При несогласии использовать приложение нельзя',
			'firstTimeSetup.common.settingsChangeableTip' => 'Эти настройки можно изменить в любое время в разделе «Настройки»',
			'firstTimeSetup.common.previousStep' => 'Назад',
			'firstTimeSetup.common.nextStep' => 'Далее',
			'firstTimeSetup.common.finishSetup' => 'Завершить настройку',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Сначала примите пользовательское соглашение и правила сообщества',
			'proxyHelper.systemProxyDetected' => 'Обнаружен системный прокси',
			'proxyHelper.copied' => 'Скопировано',
			'proxyHelper.copy' => 'Копировать',
			'tagSelector.selectTags' => 'Выбрать теги',
			'tagSelector.clickToSelectTags' => 'Нажмите, чтобы выбрать теги',
			'tagSelector.addTag' => 'Добавить тег',
			'tagSelector.removeTag' => 'Убрать тег',
			'tagSelector.deleteTag' => 'Удалить тег',
			'tagSelector.usageInstructions' => 'Сначала добавьте теги, затем нажимайте, чтобы выбрать из существующих тегов',
			'tagSelector.usageInstructionsTooltip' => 'Инструкция по использованию',
			'tagSelector.addTagTooltip' => 'Добавить тег',
			'tagSelector.removeTagTooltip' => 'Убрать тег',
			'tagSelector.cancelSelection' => 'Отменить выбор',
			'tagSelector.selectAll' => 'Выбрать все',
			'tagSelector.cancelSelectAll' => 'Отменить выбор всех',
			'tagSelector.delete' => 'Удалить',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Масштабирование и шумоподавление видео в реальном времени для улучшения качества аниме',
			'anime4k.settings' => 'Настройки Anime4K',
			'anime4k.preset' => 'Пресет Anime4K',
			'anime4k.disable' => 'Отключить Anime4K',
			'anime4k.disableDescription' => 'Отключить эффекты улучшения видео',
			'anime4k.highQualityPresets' => 'Пресеты высокого качества',
			'anime4k.fastPresets' => 'Быстрые пресеты',
			'anime4k.litePresets' => 'Облегчённые пресеты',
			'anime4k.moreLitePresets' => 'Более облегчённые пресеты',
			'anime4k.customPresets' => 'Пользовательские пресеты',
			'anime4k.presetGroups.highQuality' => 'Высокое качество',
			'anime4k.presetGroups.fast' => 'Быстрый',
			'anime4k.presetGroups.lite' => 'Облегчённый',
			'anime4k.presetGroups.moreLite' => 'Более облегчённый',
			'anime4k.presetGroups.custom' => 'Пользовательский',
			'anime4k.presetDescriptions.mode_a_hq' => 'Подходит для большинства аниме в 1080p, особенно при наличии размытия, артефактов ресемплинга и сжатия. Обеспечивает наивысшее воспринимаемое качество.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Подходит для аниме с лёгким размытием или звоном, вызванным масштабированием. Эффективно снижает звон и алиасинг.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Подходит для качественных источников (например, нативных аниме или фильмов в 1080p). Устраняет шум и обеспечивает наивысший PSNR.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Улучшенная версия режима A: максимальное воспринимаемое качество, позволяет восстановить почти все повреждённые линии. Возможно появление избыточной резкости или звона.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Улучшенная версия режима B: более высокое воспринимаемое качество, дополнительная оптимизация линий и снижение артефактов.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Версия режима C с повышенным воспринимаемым качеством: сохраняет высокий PSNR и пытается восстановить часть деталей линий.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Быстрая версия режима A: баланс качества и производительности, подходит для большинства аниме в 1080p.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Быстрая версия режима B: обработка лёгких артефактов и звона с меньшими затратами ресурсов.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Быстрая версия режима C: быстрое шумоподавление и масштабирование качественных источников.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Быстрая версия режима A+A: обеспечивает более высокое воспринимаемое качество на устройствах с ограниченной производительностью.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Быстрая версия режима B+B: улучшенное восстановление линий и обработка артефактов для устройств с ограниченной производительностью.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Быстрая версия режима C+A: быстро обрабатывает качественные источники и обеспечивает лёгкое восстановление линий.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Сверхбыстрое масштабирование x2 только с помощью самой быстрой CNN-модели: без восстановления и шумоподавления, минимальные затраты ресурсов.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Быстрое масштабирование и устранение размытия с помощью традиционных алгоритмов без CNN: лучше стандартных алгоритмов плеера при очень низких затратах ресурсов.',
			'anime4k.presetDescriptions.restore_s_only' => 'Только восстановление с помощью самой быстрой CNN-модели, без масштабирования. Подходит для воспроизведения в нативном разрешении, когда нужно улучшить качество.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Быстрое шумоподавление с помощью традиционной двусторонней фильтрации: очень быстро, подходит для обработки слабого шума.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Быстрое масштабирование традиционными алгоритмами: очень низкие затраты ресурсов, лучше стандартных настроек плеера.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Режим A (быстрый) + затемнение линий: добавляет эффект затемнения линий к быстрому режиму A для более выразительных, стилизованных линий.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Режим A (HQ) + утончение линий: добавляет эффект утончения линий к высококачественному режиму A для более изящного вида.',
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
			'anime4k.presetNames.upscale_only_s' => 'Масштабирование CNN (сверхбыстро)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Масштабирование и устранение размытия (быстро)',
			'anime4k.presetNames.restore_s_only' => 'Восстановление (сверхбыстро)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Двустороннее шумоподавление (сверхбыстро)',
			'anime4k.presetNames.upscale_non_cnn' => 'Масштабирование без CNN (сверхбыстро)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Режим A (быстрый) + затемнение линий',
			'anime4k.presetNames.mode_a_hq_thin' => 'Режим A (HQ) + утончение линий',
			'anime4k.performanceTip' => '💡 Совет: выбирайте пресеты с учётом производительности устройства. На слабых устройствах рекомендуются облегчённые пресеты.',
			'anime4k.compatibilityTip' => '⚠️ Некоторые мобильные GPU (например, Kirin 980 / Mali-G76) не могут отрисовывать пользовательские шейдеры. Если изображение становится чёрным, а звук продолжает воспроизводиться, отключите Anime4K здесь.',
			'anime4k.autoDisabledOnRenderFailure' => 'GPU вашего устройства не смог отрисовать шейдер Anime4K, поэтому он был отключён автоматически.',
			'siteMode.title' => 'Режим сайта',
			'siteMode.mainSite' => 'Основной',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Текущий ${currentSite} · нажмите, чтобы переключиться на ${nextSite}',
			'siteMode.dialogTitle' => 'Переключить режим сайта',
			'siteMode.dialogDescription' => 'Переключение обновит всё приложение и сбросит ранее загруженные списки и состояние страниц.',
			'siteMode.chooseLinkTargetTitle' => 'Выберите целевой сайт',
			'siteMode.chooseLinkTargetDescription' => 'Эта ссылка не содержит домена. Выберите, открыть её в «Основном» или «AI».',
			'siteMode.chooseLinkTargetHint' => 'После открытия эта страница и последующие запросы деталей продолжат использовать выбранный сайт.',
			'siteMode.alreadyUsing' => 'Вы уже используете этот режим сайта.',
			'siteMode.openInSite' => ({required Object site}) => 'Открыть в ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'После подтверждения будущие запросы будут использовать режим ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Переключено на ${site}. Приложение обновлено.',
			'savedSearchConfig.title' => 'Сохранённые фильтры',
			'savedSearchConfig.empty' => 'Сохранённых фильтров пока нет',
			'savedSearchConfig.saveTooltip' => 'Сохранить текущий фильтр',
			'savedSearchConfig.namePromptTitle' => 'Сохранить фильтр',
			'savedSearchConfig.nameLabel' => 'Название',
			'savedSearchConfig.nameHint' => 'Введите название',
			'savedSearchConfig.saveSuccess' => 'Фильтр сохранён',
			'savedSearchConfig.deleteSuccess' => 'Фильтр удалён',
			'savedSearchConfig.addCurrent' => 'Сохранить текущий фильтр',
			'savedSearchConfig.reorderHint' => 'Нажмите и удерживайте, затем перетащите для изменения порядка',
			'savedSearchConfig.rename' => 'Переименовать',
			'savedSearchConfig.unnamed' => 'Без названия',
			'savedSearchConfig.noConditions' => 'Весь контент (без фильтра)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => 'Тегов: ${count}',
			'savedSearch.title' => 'Сохранённые поиски',
			'savedSearch.empty' => 'Сохранённых поисков пока нет',
			'savedSearch.saveTooltip' => 'Сохранить текущий поиск',
			'savedSearch.namePromptTitle' => 'Сохранить поиск',
			'savedSearch.nameLabel' => 'Название',
			'savedSearch.nameHint' => 'Введите название',
			'savedSearch.saveSuccess' => 'Поиск сохранён',
			'savedSearch.deleteSuccess' => 'Поиск удалён',
			'savedSearch.addCurrent' => 'Сохранить текущий поиск',
			'savedSearch.reorderHint' => 'Нажмите и удерживайте, затем перетащите для изменения порядка',
			'savedSearch.rename' => 'Переименовать',
			'savedSearch.noKeyword' => '(Без ключевого слова)',
			'savedSearch.filtersCount' => ({required Object count}) => 'Фильтров: ${count}',
			'defaultBlacklistReminder.title' => 'Обнаружен чёрный список тегов по умолчанию',
			'defaultBlacklistReminder.content' => 'В вашем аккаунте всё ещё используется чёрный список тегов, который сайт автоматически применяет ко всем новым аккаунтам. Хотите просмотреть и настроить его?',
			'defaultBlacklistReminder.goManage' => 'Управлять',
			'defaultBlacklistReminder.dismiss' => 'Не сейчас',
			'colorVisionAssist.title' => 'Помощь цветовосприятию',
			'colorVisionAssist.description' => 'Корректирует цвета видео для пользователей с нарушениями цветовосприятия; можно использовать вместе с Anime4K',
			'colorVisionAssist.galleryDescription' => 'Корректирует цвета изображений в галерее для пользователей с нарушениями цветовосприятия (независимо от переключателя плеера)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Корректирует цвета изображений в галерее для пользователей с нарушениями цветовосприятия. Применяется только к 2D-просмотрщику в этой панели — изображения на пространственном экране отображаются нативно и не проходят через этот фильтр',
			'colorVisionAssist.disable' => 'Выкл.',
			'colorVisionAssist.disableDescription' => 'Без коррекции цвета',
			'colorVisionAssist.protanopia' => 'Помощь с красным (протанопия)',
			'colorVisionAssist.protanopiaDescription' => 'Для протанопии — сложность различения красного',
			'colorVisionAssist.deuteranopia' => 'Помощь с зелёным (дейтеранопия)',
			'colorVisionAssist.deuteranopiaDescription' => 'Для дейтеранопии — сложность различения зелёного',
			'colorVisionAssist.tritanopia' => 'Помощь с синим (тританопия)',
			'colorVisionAssist.tritanopiaDescription' => 'Для тританопии — сложность различения синего и жёлтого',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => 'Применён фильтр ${filterName}, действует сразу',
			'colorVisionAssist.disabledToast' => 'Помощь цветовосприятию отключена',
			'externalPlayer.title' => 'Открыть в другом приложении',
			'externalPlayer.description' => 'Передайте текущее видео другому плееру на этом устройстве: например, Skybox или Pigasus на гарнитуре VR либо MX Player и VLC на телефоне',
			'externalPlayer.openWithOtherApp' => 'Выбрать другое приложение',
			'externalPlayer.openWithOtherAppDescription' => 'Показать системный выбор и указать плеер для передачи',
			'externalPlayer.openWithSystemPlayer' => 'Открыть в плеере по умолчанию',
			'externalPlayer.openWithSystemPlayerDescription' => 'Передать приложению для видео по умолчанию',
			'externalPlayer.copyLink' => 'Копировать ссылку на видео',
			'externalPlayer.copyLinkDescription' => 'Для плееров, которые принимают только вставку URL, например Skybox или DeoVR',
			'externalPlayer.linkCopied' => 'Ссылка на видео скопирована',
			'externalPlayer.sourceLocal' => 'Локальный файл',
			'externalPlayer.sourceOnline' => 'Прямая ссылка',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Прямая ссылка · ${quality}',
			_ => null,
		} ?? switch (path) {
			'externalPlayer.onlineLinkExpiryHint' => 'Прямые ссылки истекают, поэтому внешний плеер может остановиться на середине. Надёжный способ — сначала скачать.',
			'externalPlayer.vrPlayerHint' => 'Если вашего VR-плеера нет в списке выбора, используйте «Копировать ссылку на видео» и вставьте её в этом плеере.',
			'externalPlayer.noHandler' => 'Ни одно приложение на этом устройстве не может открыть видео',
			'externalPlayer.handoffFailed' => ({required Object message}) => 'Не удалось передать: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'Не удалось передать',
			'externalPlayer.sourceUnavailable' => 'Не удалось получить адрес текущего видео, повторите попытку',
			'externalPlayer.localFileMissing' => 'Локальный файл больше не существует',
			'externalPlayer.handedOff' => 'Передано внешнему плееру',
			'externalPlayer.desktopSectionTitle' => 'Внешние плееры',
			'externalPlayer.managePlayers' => 'Управление внешними плеерами',
			'externalPlayer.managePlayersDescWindows' => 'Плееры для PCVR, такие как HereSphere, DeoVR и Whirligig, не являются приложением по умолчанию в системе. Укажите их .exe — и сможете передавать текущее видео прямо из плеера.',
			'externalPlayer.managePlayersDescMac' => 'Укажите здесь такие плееры, как IINA, VLC или mpv, — и сможете передавать текущее видео прямо из плеера.',
			'externalPlayer.managePlayersDescLinux' => 'Укажите здесь такие плееры, как mpv, VLC или Celluloid, — и сможете передавать текущее видео прямо из плеера.',
			'externalPlayer.pickExecutableHintWindows' => 'Выберите основной файл .exe в папке установки плеера, например HereSphere.exe или vlc.exe. Ярлыки на рабочем столе (.lnk) не подойдут.',
			'externalPlayer.pickExecutableHintMac' => 'Выберите приложение .app плеера в папке «Программы», например IINA.app, — настоящий исполняемый файл внутри будет найден автоматически.',
			'externalPlayer.pickExecutableHintLinux' => 'Выберите исполняемый файл плеера, например /usr/bin/mpv. Команда which mpv покажет, где он находится.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'После настройки он появится отдельным пунктом в разделе «Открыть в другом приложении» на странице плеера. Частые варианты: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'Установленные плееры не найдены. Пользовательские папки установки и портативные сборки не определяются — используйте «Добавить плеер», чтобы указать его вручную.',
			'externalPlayer.detectNothingNew' => 'Новые плееры не найдены; всё установленное уже есть в списке',
			'externalPlayer.detectFailed' => 'Не удалось выполнить поиск — используйте «Добавить плеер», чтобы указать его вручную',
			'externalPlayer.advancedOptions' => 'Дополнительно',
			'externalPlayer.playerNameHint' => 'Оставьте пустым, чтобы использовать имя файла',
			'externalPlayer.executablePathRequired' => 'Сначала выберите исполняемый файл плеера',
			'externalPlayer.playerCount' => ({required Object count}) => 'Настроено: ${count}',
			'externalPlayer.noPlayerConfigured' => 'Внешний плеер ещё не настроен',
			'externalPlayer.autoDetect' => 'Автоопределение',
			'externalPlayer.detecting' => 'Поиск…',
			'externalPlayer.detectFound' => ({required Object count}) => 'Найдено плееров: ${count}',
			'externalPlayer.detectNothingFound' => 'Новые плееры не найдены, добавьте вручную',
			'externalPlayer.autoDetectedTag' => 'обнаружен',
			'externalPlayer.addPlayer' => 'Добавить плеер',
			'externalPlayer.editPlayer' => 'Изменить плеер',
			'externalPlayer.playerName' => 'Название',
			'externalPlayer.executablePath' => 'Исполняемый файл',
			'externalPlayer.browse' => 'Обзор',
			'externalPlayer.argumentTemplate' => 'Аргументы запуска',
			'externalPlayer.argumentTemplateHint' => 'Используйте {input} для пути к видео или URL. Оставьте пустым, чтобы передать его единственным аргументом.',
			'externalPlayer.nameAndPathRequired' => 'Необходимо указать и название, и исполняемый файл',
			'externalPlayer.testLaunch' => 'Пробный запуск',
			'externalPlayer.testLaunched' => 'Плеер запущен',
			'externalPlayer.testFailed' => 'Не удалось запустить, проверьте путь к исполняемому файлу',
			'externalPlayer.executableMissing' => 'Исполняемый файл не найден',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'Открыть в ${name}',
			'externalPlayer.managePlayersEntry' => 'Управление внешними плеерами…',
			'watchLater.title' => 'Посмотреть позже',
			'watchLater.addToWatchLater' => 'Посмотреть позже',
			'watchLater.removeFromWatchLater' => 'Убрать из «Посмотреть позже»',
			'watchLater.addedToWatchLater' => 'Добавлено в «Посмотреть позже»',
			'watchLater.alreadyInWatchLater' => 'Уже в «Посмотреть позже»',
			'watchLater.removedFromWatchLater' => 'Убрано из «Посмотреть позже»',
			'watchLater.removedCount' => ({required Object count}) => 'Удалено элементов: ${count}',
			'watchLater.viewWatchLaterList' => 'Открыть список',
			'watchLater.addFailed' => 'Не удалось добавить в «Посмотреть позже»',
			'watchLater.invalidItem' => 'Недоступно',
			'watchLater.clearWatched' => 'Очистить просмотренное',
			'watchLater.watchedCleared' => ({required Object count}) => 'Очищено просмотренных элементов: ${count}',
			'watchLater.noWatchedToClear' => 'Нет просмотренного для очистки',
			'watchLater.emptyVideo' => 'В «Посмотреть позже» пока нет видео',
			'watchLater.emptyGallery' => 'В «Посмотреть позже» пока нет галерей',
			'watchLater.filterAll' => 'Все',
			'watchLater.filterUnwatched' => 'Непросмотренные',
			'watchLater.sortRecentlyAdded' => 'Недавно добавленные',
			'watchLater.sortEarliestAdded' => 'Добавленные раньше всех',
			'watchLater.watched' => 'Просмотрено',
			'watchLater.playlistLoadFailed' => 'Не удалось загрузить плейлисты',
			'watchLater.noPlaylists' => 'Плейлистов пока нет',
			'watchLater.undo' => 'Отменить',
			'watchLater.clearWatchedConfirm' => 'Очистить всё просмотренное на этой вкладке? Это действие нельзя отменить.',
			'watchLater.emptyUnwatchedVideo' => 'Здесь больше нечего смотреть',
			'watchLater.emptyUnwatchedGallery' => 'Здесь больше нечего смотреть',
			'watchLater.queueLoadFailed' => 'Не удалось загрузить, нажмите для повтора',
			'mediaMenu.like' => 'Нравится',
			'mediaMenu.unlike' => 'Убрать отметку «Нравится»',
			'mediaMenu.viewAuthor' => 'Открыть автора',
			'mediaMenu.inFolders' => ({required Object count}) => 'Папок: ${count}',
			'mediaMenu.inPlaylists' => ({required Object count}) => 'Плейлистов: ${count}',
			'mediaMenu.downloaded' => 'Скачано',
			'mediaPreview.preview' => 'Просмотр',
			'mediaPreview.openDetail' => 'Открыть',
			'mediaPreview.moreActions' => 'Дополнительные действия',
			'mediaPreview.previousImage' => 'Предыдущее изображение',
			'mediaPreview.nextImage' => 'Следующее изображение',
			'playbackQueue.galleryImageCount' => ({required Object count}) => 'Изображений: ${count}',
			'playbackQueue.upNext' => 'Далее',
			'playbackQueue.sourceTab' => 'Источник',
			'playbackQueue.emptyQueue' => 'В этой очереди нет ничего для воспроизведения',
			'playbackQueue.emptyGalleryQueue' => 'В этой очереди нет галерей',
			'playbackQueue.nowPlaying' => 'Сейчас играет',
			'playbackQueue.myPlaylists' => 'Мои плейлисты',
			'playbackQueue.authorPlaylists' => 'Плейлисты автора',
			'playbackQueue.openQueue' => 'Далее',
			'playbackQueue.continueInQueue' => 'Продолжать воспроизведение из текущей очереди',
			'playbackQueue.continueInQueueSubtitle' => 'Автоматически воспроизводит следующий элемент; отключает «повтор по завершении»',
			'playbackQueue.repeatDisabledByQueue' => 'Отключено, пока включено «продолжать воспроизведение из текущей очереди»',
			'playbackQueue.playNext' => 'Играть следующим',
			'playbackQueue.queueEnded' => 'Это последний элемент в очереди',
			'playbackQueue.playNextHint' => 'Нажмите, чтобы воспроизвести следующий элемент; нажмите и удерживайте, чтобы открыть «Далее»',
			'playbackQueue.authorVideos' => 'Видео автора',
			'playbackQueue.authorGalleries' => 'Галереи автора',
			'playbackQueue.favoriteFolders' => 'Избранные папки',
			'playbackQueue.localFiles' => 'На этом устройстве',
			'playbackQueue.currentFolder' => 'Папка этого файла',
			'playbackQueue.playThisFolder' => 'Очередь видео этой папки',
			'playbackQueue.browseThisFolder' => 'Очередь галерей этой папки',
			'playbackQueue.downloads' => 'Скачанное',
			'playbackQueue.otherPlaylists' => 'Плейлисты других пользователей',
			'playbackQueue.nothingHere' => 'Здесь ничего нет',
			'vrFormat.playInSpace' => 'Воспроизвести в пространственном плеере',
			'vrFormat.handingOff' => 'Передача в пространство…',
			'vrFormat.title' => 'Режим воспроизведения',
			'vrFormat.spatialSectionTitle' => 'Пространственное воспроизведение',
			'vrFormat.spatialSectionDesc' => 'На гарнитуре видео не отображается внутри этой панели — пространственный плеер выводит его на экран в комнате.',
			'vrFormat.spatialPanelEntry' => 'Пространственная панель управления',
			'vrFormat.spatialPanelEntryDesc' => 'Расстояние до экрана, размер и кривизна, фоновое окружение, а также скорость, повтор и автоскрытие — всё это находится в пространственной панели управления.',
			'vrFormat.spatialGuideEntry' => 'Руководство по управлению гарнитурой',
			'vrFormat.spatialGuideEntryDesc' => 'Кнопки контроллера, захват экрана, перемотка стиком и перелистывание страниц',
			'vrFormat.spatialFlatOmitted' => 'Сенсорные жесты, улучшение изображения и параметры аудио/видео применяются только к 2D-плееру; пространственный плеер работает на другом движке, поэтому здесь они не перечислены.',
			'vrFormat.spatialGallerySectionTitle' => 'Пространственная галерея',
			'vrFormat.spatialGalleryPanelDesc' => 'Интервал слайд-шоу, повтор одного клипа и кривизна экрана настраиваются в пространственной панели управления.',
			'vrFormat.autoEnterGallery' => 'Открывать изображения галереи в пространственной галерее',
			'vrFormat.autoEnterGalleryDesc' => 'На Quest нажатие на изображение открывает всю галерею на плавающем экране с лентой миниатюр, слайд-шоу и перелистыванием контроллером вместо просмотрщика внутри этой панели.',
			'vrFormat.panelSettings' => 'Панель и фон',
			'vrFormat.panelSettingsDesc' => 'На каком расстоянии находится панель приложения и насколько видна ваша комната позади неё',
			'vrFormat.panelDistance' => 'Расстояние до панели',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Сбросить размещение',
			'vrFormat.panelResetBackground' => 'Сбросить к значению по умолчанию',
			'vrFormat.panelBackground' => 'Прозрачность фона',
			'vrFormat.panelBackgroundHint' => '0%: чёрное окружение · 100%: ваша реальная комната с общим освещением',
			'vrFormat.panelUnavailable' => 'Панель сейчас не размещена — повторите попытку через мгновение',
			'vrFormat.desc' => 'Выберите геометрию, с которой должно воспроизводиться это видео. Сайт не предоставляет эту информацию, поэтому автоопределение лишь задаёт отправную точку — решает ваш выбор.',
			'vrFormat.sectionFlat' => 'Плоское',
			'vrFormat.sectionStereo' => 'Плоское 3D',
			'vrFormat.sectionPanorama' => 'VR-панорама',
			'vrFormat.flat' => 'Обычное видео',
			'vrFormat.flatDesc' => 'Воспроизводить как есть, без перепроецирования',
			'vrFormat.flatSideBySide' => 'Стерео 3D (side-by-side)',
			'vrFormat.flatSideBySideDesc' => 'По одному глазу на половину, слева и справа; показывает левый глаз и восстанавливает его соотношение сторон',
			'vrFormat.flatTopBottom' => 'Стерео 3D (over-under)',
			'vrFormat.flatTopBottomDesc' => 'По одному глазу на половину, сверху и снизу; показывает верхнюю половину и восстанавливает её соотношение сторон',
			'vrFormat.vr180SideBySide' => 'VR180 стерео (side-by-side)',
			'vrFormat.vr180SideBySideDesc' => 'Полусферическая панорама с двумя глазами — самый распространённый VR-источник',
			'vrFormat.vr180Mono' => 'VR180 моно',
			'vrFormat.vr180MonoDesc' => 'Полусферическая панорама, один глаз на кадр',
			'vrFormat.vr360Mono' => 'VR360 моно',
			'vrFormat.vr360MonoDesc' => 'Полноценная круговая панорама, один глаз на кадр',
			'vrFormat.vr360TopBottom' => 'VR360 стерео (over-under)',
			'vrFormat.vr360TopBottomDesc' => 'Полноценная круговая панорама с двумя расположенными друг над другом глазами',
			'vrFormat.resetView' => 'Сбросить вид',
			'vrFormat.resetViewDesc' => 'Вернуть направление взгляда и угол обзора к фронтальному положению',
			'vrFormat.resetToAuto' => 'Вернуть к автоопределению',
			'vrFormat.resetToAutoDesc' => 'Забыть ручной выбор для этого видео и снова доверить решение автоопределению',
			'vrFormat.manualBadge' => 'Задано вручную',
			'vrFormat.panoramaHint' => 'Перетаскивайте изображение, чтобы осмотреться, сведите пальцы, чтобы изменить угол обзора',
			'vrFormat.panoramaGestureNotice' => 'При осмотре перетаскивание поворачивает вид — для перемотки используйте полосу прогресса',
			'vrFormat.shaderUnsupported' => 'Это устройство не может отображать живую панораму; вместо этого показывается один глаз',
			'vrFormat.handoffTooltip' => 'Другой способ воспроизведения',
			'vrFormat.suggestedBadge' => 'Рекомендуется',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Похоже на ${format} — нажмите, чтобы переключить',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Возможно, это VR-видео (${format})',
			'vrFormat.suggestionTitleShort' => 'Возможно, это VR-видео',
			'vrFormat.suggestionAction' => 'Воспроизвести как VR',
			'vrFormat.suggestionDismiss' => 'Закрыть',
			'localMedia.browse.pinnedSection' => 'Быстрый доступ',
			'localMedia.browse.sourcesSection' => 'Папки',
			'localMedia.browse.pin' => 'Добавить в быстрый доступ',
			'localMedia.browse.unpin' => 'Убрать из быстрого доступа',
			'localMedia.browse.pinned' => 'Добавлено в быстрый доступ',
			'localMedia.browse.unpinned' => 'Убрано из быстрого доступа',
			'localMedia.browse.folderCount' => ({required Object count}) => 'Папок: ${count}',
			'localMedia.browse.videoCount' => ({required Object count}) => 'Видео: ${count}',
			'localMedia.browse.imageCount' => ({required Object count}) => 'Изображений: ${count}',
			'localMedia.browse.emptyFolder' => 'Эта папка пуста',
			'localMedia.browse.videosSection' => 'Видео',
			'localMedia.browse.imagesSection' => 'Изображения',
			'localMedia.browse.galleriesSection' => 'Галереи',
			'localMedia.browse.filterAll' => 'Все',
			'localMedia.browse.searchInFolder' => 'Поиск в этой папке',
			'localMedia.browse.searchHint' => 'Поиск по имени',
			'localMedia.browse.clearSearch' => 'Очистить поиск',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'Ничего не найдено по запросу «${query}»',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Показать все папки (${count})',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Показать все видео (${count})',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Показать все изображения (${count})',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Показать все галереи (${count})',
			'localMedia.browse.location' => 'Расположение',
			'localMedia.browse.sourceMissing' => 'Этот источник недоступен',
			'localMedia.browse.notScannedYet' => 'Эта папка ещё не просканирована',
			'localMedia.browse.scanning' => 'Чтение папки…',
			'localMedia.browse.deleteFileTitle' => 'Удалить этот файл?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '«${name}» будет безвозвратно удалён с этого устройства. Это действие нельзя отменить.',
			'localMedia.browse.hideFolder' => 'Скрыть эту папку',
			'localMedia.browse.unhideFolder' => 'Показать снова',
			'localMedia.browse.showHiddenFolders' => 'Показывать скрытые папки',
			'localMedia.browse.includeDotFolders' => 'Сканировать папки, начинающиеся с .',
			'localMedia.browse.dotFoldersIncluded' => 'Папки, начинающиеся с ., теперь сканируются',
			'localMedia.browse.dotFoldersExcluded' => 'Папки, начинающиеся с ., больше не сканируются',
			'localMedia.browse.showDotFolders' => 'Показывать папки, начинающиеся с .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'Здесь есть ${count} несканированных папок, начинающихся с .',
			'localMedia.browse.scanDotFoldersAction' => 'Включить для этого источника',
			'localMedia.browse.otherAppsPrivateNotice' => 'Начиная с Android 11 ни одно приложение не может читать файлы других приложений в Android/data и Android/obb, и это приложение не может обойти запрет. Скачайте или экспортируйте видео в общую папку, например Download, в исходном приложении, а затем добавьте эту папку сюда. Кэш при просмотре обычно разбит на фрагменты и не воспроизводится, даже если его прочитать.',
			'localMedia.browse.folderHidden' => 'Скрыта — сканирование тоже её пропустит',
			'localMedia.browse.folderUnhidden' => 'Больше не скрыта',
			'localMedia.browse.hiddenFolderBadge' => 'Скрыта',
			'localMedia.browse.deleteFolder' => 'Удалить папку',
			'localMedia.browse.deleteFolderTitle' => 'Удалить эту папку?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '«${name}» и всё её содержимое будут безвозвратно удалены с этого устройства. Отменить это нельзя.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Другие файлы внутри тоже будут удалены',
			'localMedia.browse.folderDeleted' => 'Папка удалена',
			'localMedia.browse.deleteFolderFailed' => 'Не удалось удалить: нет прав или файл внутри занят',
			'localMedia.browse.deleteGalleryTitle' => 'Удалить эту галерею?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'Запись о загрузке и локальные файлы изображений «${name}» будут удалены. Это действие нельзя отменить.',
			'localMedia.browse.galleryResourceMissing' => 'Локальные файлы больше не существуют. Запись очищена.',
			'localMedia.browse.viewDownloadDetail' => 'Открыть детали загрузки',
			'localMedia.browse.viewOnlineGallery' => 'Открыть на сайте',
			'localMedia.browse.pickFolderTitle' => 'Выберите папку',
			'localMedia.browse.useThisFolder' => 'Использовать эту папку',
			'localMedia.browse.noSubfolders' => 'Здесь нет подпапок',
			'localMedia.browse.storageRoot' => 'Хранилище устройства',
			'localMedia.browse.homeFolder' => 'Домашняя',
			'localMedia.browse.filesystemRoot' => 'Корень файловой системы',
			'localMedia.browse.folderUnreadable' => 'Не удаётся прочитать эту папку',
			'localMedia.browse.setCover' => 'Задать обложку',
			'localMedia.browse.setAsFolderCover' => 'Использовать как обложку папки',
			'localMedia.browse.folderCoverSet' => 'Обложка папки обновлена',
			'localMedia.browse.setFolderCoverPick' => 'Задать обложку…',
			'localMedia.browse.restoreAutoCover' => 'Восстановить автоматическую обложку',
			'localMedia.browse.autoCoverRestored' => 'Автоматическая обложка восстановлена',
			'localMedia.browse.rescanFolder' => 'Пересканировать эту папку',
			'localMedia.browse.coverPickerTitle' => 'Выберите кадр',
			'localMedia.browse.folderCoverPickerTitle' => 'Выберите обложку',
			'localMedia.browse.coverPickerEmpty' => 'В этой папке пока нет изображений. Миниатюры видео могут ещё создаваться в фоне.',
			'localMedia.browse.coverSaved' => 'Обложка обновлена',
			'localMedia.browse.coverSaveFailed' => 'Не удалось сохранить обложку',
			'localMedia.browse.coverUnavailable' => 'Не удалось прочитать кадр видео из этого файла',
			'localMedia.browse.deleted' => 'Удалено',
			'localMedia.browse.deleteFailed' => 'Не удалось удалить — возможно, файл используется или защищён от записи',
			'localMedia.browse.openFolder' => 'Открыть',
			'localMedia.browse.favorite' => 'Добавить в избранное',
			'localMedia.browse.unfavorite' => 'Убрать из избранного',
			'localMedia.browse.favorited' => 'Добавлено в избранное',
			'localMedia.browse.unfavorited' => 'Убрано из избранного',
			'localMedia.browse.sortBy' => 'Сортировать по',
			'localMedia.browse.sortAscending' => 'По возрастанию',
			'localMedia.browse.sortDescending' => 'По убыванию',
			'localMedia.browse.sortFieldName' => 'Название',
			'localMedia.browse.sortFieldModified' => 'Дата изменения',
			'localMedia.browse.sortFieldDuration' => 'Длительность',
			'localMedia.browse.sortFieldSize' => 'Размер',
			'localMedia.browse.sortFieldResolution' => 'Разрешение',
			'localMedia.browse.sortFieldFileType' => 'Тип файла',
			'localMedia.browse.sortFieldFps' => 'Частота кадров',
			'localMedia.browse.sortFieldFavorited' => 'Дата добавления в избранное',
			'localMedia.browse.emptyAllVideos' => 'Видео не найдены. Добавьте папку в разделе «Папки», чтобы начать.',
			'localMedia.browse.emptyAllImages' => 'Изображения не найдены. Добавьте папку в разделе «Папки», чтобы начать.',
			'localMedia.browse.emptyFavorites' => 'Пока нет избранного. Добавьте из меню ⋮ на видео.',
			'localMedia.browse.emptyPinned' => 'Пока нет закреплённых папок. Нажмите и удерживайте папку в разделе «Папки» и выберите «Закрепить».',
			'localMedia.browse.emptyDownloadedVideos' => 'Пока нет завершённых загрузок видео.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Пока нет завершённых загрузок галерей.',
			'localMedia.browse.folderInfo' => 'Сведения о папке',
			'localMedia.browse.folderInfoName' => 'Название',
			'localMedia.browse.folderInfoPath' => 'Путь',
			'localMedia.browse.folderInfoSource' => 'Источник',
			'localMedia.browse.folderInfoContents' => 'Содержимое',
			'localMedia.browse.folderInfoSize' => 'Размер на диске',
			'localMedia.browse.folderInfoScannedAt' => 'Последнее сканирование',
			'localMedia.browse.folderInfoNeverScanned' => 'Ещё не сканировалось',
			'localMedia.browse.folderInfoNoPath' => 'У этого источника нет папки для открытия',
			'localMedia.browse.copyPath' => 'Копировать путь',
			'localMedia.browse.pathCopied' => 'Путь скопирован',
			'localMedia.tabFolders' => 'Папки',
			'localMedia.tabFavoriteVideos' => 'Избранное',
			'localMedia.tabAllVideos' => 'Все видео',
			'localMedia.tabAllImages' => 'Все изображения',
			'localMedia.tabDownloadedVideos' => 'Скачанные видео',
			'localMedia.tabDownloadedGalleries' => 'Скачанные галереи',
			'localMedia.title' => 'На этом устройстве',
			'localMedia.sourceOnline' => 'Iwara онлайн',
			'localMedia.manageSources' => 'Управление источниками',
			'localMedia.moveToCategory' => 'Переместить в категорию',
			'localMedia.manageCategories' => 'Управление категориями',
			'localMedia.suggestedFolders' => 'Папки с видео',
			'localMedia.sortRecentlyAdded' => 'Недавно добавленные',
			'localMedia.sortRecentlyPlayed' => 'Недавно просмотренные',
			'localMedia.sortName' => 'Название',
			'localMedia.sortDuration' => 'Длительность',
			'localMedia.sortSize' => 'Размер',
			'localMedia.sortFolder' => 'Папка',
			'localMedia.sortRecentlyModified' => 'Недавно изменённые',
			'localMedia.sortCount' => 'Количество',
			'localMedia.folderCardItemCount' => ({required Object count}) => 'Изображений: ${count}',
			'localMedia.downloadsSource' => 'Скачанное',
			'localMedia.builtInSourceHint' => 'Раздел «Скачанное» управляется автоматически',
			'localMedia.filterByCategory' => 'Фильтр по категории',
			'localMedia.longPressToCategorize' => 'Нажмите и удерживайте, чтобы переместить в категорию',
			'localMedia.uncategorized' => 'Без категории',
			'localMedia.setCategoryFailed' => 'Не удалось задать категорию',
			'localMedia.categoryUpdated' => 'Категория обновлена',
			'localMedia.addFolder' => 'Добавить папку',
			'localMedia.addDeviceVideos' => 'Сканировать видео на устройстве',
			'localMedia.mediaStoreSourceName' => 'Видео устройства',
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
			'localMedia.mediaStoreUnavailable' => 'Индекс медиафайлов устройства доступен только на Android',
			'localMedia.mediaStorePermissionDenied' => 'Доступ к видео не предоставлен',
			'localMedia.rescan' => 'Пересканировать',
			'localMedia.scanning' => ({required Object count}) => 'Сканирование… найдено ${count}',
			'localMedia.scanFailed' => ({required Object reason}) => 'Ошибка сканирования: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Эта папка очень большая — добавлены только первые ${count} файлов.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Уже охвачено папкой «${name}»',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '«${name}» находится внутри «${source}», поэтому добавлено в закреплённые папки',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '«${name}» уже в закреплённых папках',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '«${name}» уже добавлено',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Он уже содержит добавленную папку «${name}»; добавление её родительской папки пока не поддерживается',
			'localMedia.addSourceFailed' => 'Не удалось добавить эту папку',
			'localMedia.fileMissing' => 'Этот файл больше не находится на диске',
			'localMedia.permissionDenied' => 'Доступ к файлам не предоставлен · нажмите, чтобы предоставить',
			'localMedia.noVideosFound' => 'В этой папке нет видео',
			'localMedia.emptyTitle' => 'Добавьте папку, чтобы просматривать видео, уже имеющиеся на этом устройстве',
			'localMedia.emptyPrivacyNote' => 'Файлы читаются только на этом устройстве. Ничего не загружается.',
			'localMedia.removeSourceTitle' => ({required Object name}) => 'Удалить «${name}»?',
			'localMedia.removeSourceBody' => 'Файлы остаются на диске. Удаляется только эта запись в библиотеке.',
			'localMedia.remove' => 'Удалить',
			'localMedia.removeFolder' => 'Удалить папку',
			'localMedia.removeFolderSelectTitle' => 'Выберите папку для удаления',
			'localMedia.longPressToRemove' => 'Нажмите и удерживайте, чтобы удалить эту папку',
			'localMedia.clearProgress' => 'Очистить локальную историю просмотров',
			'localMedia.clearProgressCount' => ({required Object count}) => 'Записей: ${count}',
			'localMedia.clearProgressEmpty' => 'Локальной истории просмотров пока нет',
			'localMedia.clearProgressTitle' => 'Очистить локальную историю просмотров?',
			'localMedia.clearProgressBody' => 'Удаляются только позиции воспроизведения и отметки о просмотре. Ваши файлы и папки остаются без изменений.',
			'localMedia.clearProgressDone' => ({required Object count}) => 'Очищено записей локальной истории просмотров: ${count}',
			'localMedia.clearAction' => 'Очистить',
			'localMedia.iosManualRescanNotice' => 'iOS не обнаруживает новые файлы автоматически. После добавления или удаления файлов потребуется вручную запустить повторное сканирование.',
			'historyPage.removeFromHistory' => 'Удалить из истории',
			'historyPage.removed' => 'Удалено из истории',
			'historyPage.watchedTo' => ({required Object time}) => 'Просмотрено до ${time}',
			'historyPage.finished' => 'Просмотрено',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'Очистить «${tab}»',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Вся история в «${tab}» будет удалена вместе с прогрессом просмотра этих видео. Действие необратимо.',
			'historyPage.rangeByLastViewed' => 'По времени последнего просмотра',
			'ai.title' => 'ИИ',
			'ai.providers' => 'Провайдеры',
			'ai.providersHint' => 'Добавьте одного или нескольких провайдеров ИИ и назначьте их для нужных функций.',
			'ai.addProvider' => 'Добавить провайдера',
			'ai.noProviders' => 'Провайдеры пока не добавлены. Добавьте хотя бы одного, чтобы включить перевод, поиск и подпись с помощью ИИ.',
			'ai.pickPreset' => 'Выбрать провайдера',
			'ai.providerNameLabel' => 'Название',
			'ai.apiKey' => 'API-ключ',
			'ai.baseUrl' => 'Конечная точка',
			'ai.model' => 'Модель',
			'ai.modelPick' => 'Выбрать модель',
			'ai.modelEmpty' => 'Не удалось загрузить список моделей — можно также ввести название модели вручную.',
			'ai.advanced' => 'Расширенные',
			'ai.reasoning' => 'Модель рассуждений',
			'ai.streaming' => 'Потоковый вывод',
			'ai.structuredOutput' => 'Структурированный вывод',
			'ai.structuredOutputHint' => 'Требуется для поиска с ИИ. Многие сторонние прокси-эндпоинты не поддерживают эту функцию — отключите её, если поиск постоянно завершается ошибкой.',
			'ai.temperature' => 'Температура',
			'ai.maxTokens' => 'Макс. количество токенов',
			'ai.maxTokensAuto' => 'Авто (лимит модели)',
			'ai.test' => 'Проверить',
			'ai.testOk' => 'Подключение успешно',
			'ai.deleteProvider' => 'Удалить провайдера',
			'ai.usedBy' => 'Используется в',
			'ai.taskBindings' => 'Назначение функций',
			'ai.taskBindingsHint' => 'Для каждой функции можно выбрать отдельного провайдера.',
			'ai.taskTranslate' => 'Перевод',
			'ai.taskSearch' => 'Поиск с ИИ',
			'ai.taskSignature' => 'Подпись',
			'ai.taskAuto' => 'Автоматически',
			'ai.usage' => 'Использование',
			'ai.usageCalls' => 'Вызовы',
			'ai.usageTokens' => 'Токены',
			'ai.usageFailures' => 'Ошибки',
			'ai.usageReset' => 'Сбросить статистику',
			'ai.usageEmpty' => 'Вызовов пока не было',
			'ai.openSettings' => 'Открыть настройки ИИ',
			'ai.notConfigured' => 'Не настроено',
			'ai.searchTitle' => 'Поиск с ИИ',
			'ai.searchHint' => 'Опишите, что вы ищете, и ИИ сам заполнит поисковые запросы и фильтры.',
			'ai.searchPlaceholder' => 'Например: недавние MMD с более 10 тыс. просмотров',
			'ai.searchApply' => 'Искать по этим условиям',
			'ai.searchEmpty' => 'Не удалось сформировать поисковый запрос. Попробуйте описать иначе.',
			'ai.searchFilters' => 'Фильтры',
			'ai.searchSwitchSegment' => ({required Object segment}) => 'Переключить на ${segment}',
			'ai.searchGenerating' => 'Обработка…',
			'ai.searchRetrying' => 'Предыдущая попытка не удалась, повтор…',
			'ai.searchRetryReason' => ({required Object reason}) => 'Причина: ${reason}',
			'ai.searchStageWaiting' => 'Запрос отправлен, ждём ответа…',
			'ai.searchStageThinkingNext' => 'Обдумывает следующий шаг…',
			'ai.searchStageReasoning' => 'Рассуждает…',
			'ai.searchStageTool' => 'Пробный поиск…',
			'ai.searchStageDrafting' => ({required Object chars}) => 'Пишет ответ · ${chars} симв.',
			'ai.searchStageParsing' => 'Разбираем результат…',
			'ai.searchThinking' => 'Ход рассуждений',
			'ai.searchKeywordNeedsQuotes' => 'Запрос не взят в кавычки, поэтому Iwara сопоставляет его нестрого — при такой сортировке первая страница будет в основном нерелевантной. Возьмите его в "кавычки" или сортируйте по релевантности.',
			'ai.searchToolProbing' => ({required Object query}) => 'Пробую ${query}',
			'ai.searchToolFound' => ({required Object count, required Object titles}) => 'Результатов: ${count} · ${titles}',
			'ai.searchToolFailed' => ({required Object reason}) => 'Не удалось: ${reason}',
			'ai.searchToolFilterCount' => ({required Object count}) => 'Фильтров: ${count}',
			'ai.searchToolExpanded' => ({required Object tags}) => 'дополнено тегами ${tags}',
			'ai.searchToolLookupTags' => ({required Object terms}) => 'Поиск тегов ${terms}',
			'ai.searchToolTagMissing' => 'не тег',
			'ai.searchToolFindUser' => ({required Object name}) => 'Поиск автора ${name}',
			'ai.searchToolUsersFound' => ({required Object count, required Object users}) => 'Пользователей: ${count} · ${users}',
			'ai.searchPlanTitle' => 'План поиска',
			'ai.searchPlanEstimate' => ({required Object count}) => 'Около ${count}',
			'ai.searchToolCount' => ({required Object count}) => 'Запросов: ${count}',
			'ai.searchWillExpandTags' => 'Также ищет по этим тегам',
			'ai.searchTraceReasoning' => 'Рассуждение',
			'ai.searchFiltersDropped' => ({required Object count}) => 'Удалено фильтров, которых нет в этом разделе: ${count}.',
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
			_ => null,
		} ?? switch (path) {
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
