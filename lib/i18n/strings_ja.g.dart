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
class TranslationsJa extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsJa _root = this; // ignore: unused_field

	@override 
	TranslationsJa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileJa personalProfile = _TranslationsPersonalProfileJa._(_root);
	@override late final _TranslationsTutorialJa tutorial = _TranslationsTutorialJa._(_root);
	@override late final _TranslationsCommonJa common = _TranslationsCommonJa._(_root);
	@override late final _TranslationsAuthJa auth = _TranslationsAuthJa._(_root);
	@override late final _TranslationsErrorsJa errors = _TranslationsErrorsJa._(_root);
	@override late final _TranslationsFriendsJa friends = _TranslationsFriendsJa._(_root);
	@override late final _TranslationsAuthorProfileJa authorProfile = _TranslationsAuthorProfileJa._(_root);
	@override late final _TranslationsFavoritesJa favorites = _TranslationsFavoritesJa._(_root);
	@override late final _TranslationsGalleryDetailJa galleryDetail = _TranslationsGalleryDetailJa._(_root);
	@override late final _TranslationsPlayListJa playList = _TranslationsPlayListJa._(_root);
	@override late final _TranslationsSearchJa search = _TranslationsSearchJa._(_root);
	@override late final _TranslationsMediaListJa mediaList = _TranslationsMediaListJa._(_root);
	@override late final _TranslationsSettingsJa settings = _TranslationsSettingsJa._(_root);
	@override late final _TranslationsFavoriteTagsJa favoriteTags = _TranslationsFavoriteTagsJa._(_root);
	@override late final _TranslationsOreno3dJa oreno3d = _TranslationsOreno3dJa._(_root);
	@override late final _TranslationsSignInJa signIn = _TranslationsSignInJa._(_root);
	@override late final _TranslationsSubscriptionsJa subscriptions = _TranslationsSubscriptionsJa._(_root);
	@override late final _TranslationsVideoDetailJa videoDetail = _TranslationsVideoDetailJa._(_root);
	@override late final _TranslationsShareJa share = _TranslationsShareJa._(_root);
	@override late final _TranslationsMarkdownJa markdown = _TranslationsMarkdownJa._(_root);
	@override late final _TranslationsForumJa forum = _TranslationsForumJa._(_root);
	@override late final _TranslationsNotificationsJa notifications = _TranslationsNotificationsJa._(_root);
	@override late final _TranslationsConversationJa conversation = _TranslationsConversationJa._(_root);
	@override late final _TranslationsSplashJa splash = _TranslationsSplashJa._(_root);
	@override late final _TranslationsDownloadJa download = _TranslationsDownloadJa._(_root);
	@override late final _TranslationsDownloadNotificationsJa downloadNotifications = _TranslationsDownloadNotificationsJa._(_root);
	@override late final _TranslationsFavoriteJa favorite = _TranslationsFavoriteJa._(_root);
	@override late final _TranslationsTranslationJa translation = _TranslationsTranslationJa._(_root);
	@override late final _TranslationsMediaPlayerJa mediaPlayer = _TranslationsMediaPlayerJa._(_root);
	@override late final _TranslationsDiagnosticsJa diagnostics = _TranslationsDiagnosticsJa._(_root);
	@override late final _TranslationsLogViewerJa logViewer = _TranslationsLogViewerJa._(_root);
	@override late final _TranslationsCrashRecoveryDialogJa crashRecoveryDialog = _TranslationsCrashRecoveryDialogJa._(_root);
	@override late final _TranslationsLinkInputDialogJa linkInputDialog = _TranslationsLinkInputDialogJa._(_root);
	@override late final _TranslationsLogJa log = _TranslationsLogJa._(_root);
	@override late final _TranslationsEmojiJa emoji = _TranslationsEmojiJa._(_root);
	@override late final _TranslationsDisplaySettingsJa displaySettings = _TranslationsDisplaySettingsJa._(_root);
	@override late final _TranslationsLayoutSettingsJa layoutSettings = _TranslationsLayoutSettingsJa._(_root);
	@override late final _TranslationsBottomNavJa bottomNav = _TranslationsBottomNavJa._(_root);
	@override late final _TranslationsNavigationOrderSettingsJa navigationOrderSettings = _TranslationsNavigationOrderSettingsJa._(_root);
	@override late final _TranslationsNewsJa news = _TranslationsNewsJa._(_root);
	@override late final _TranslationsSearchFilterJa searchFilter = _TranslationsSearchFilterJa._(_root);
	@override late final _TranslationsFirstTimeSetupJa firstTimeSetup = _TranslationsFirstTimeSetupJa._(_root);
	@override late final _TranslationsProxyHelperJa proxyHelper = _TranslationsProxyHelperJa._(_root);
	@override late final _TranslationsTagSelectorJa tagSelector = _TranslationsTagSelectorJa._(_root);
	@override late final _TranslationsAnime4kJa anime4k = _TranslationsAnime4kJa._(_root);
	@override late final _TranslationsSiteModeJa siteMode = _TranslationsSiteModeJa._(_root);
	@override late final _TranslationsSavedSearchConfigJa savedSearchConfig = _TranslationsSavedSearchConfigJa._(_root);
	@override late final _TranslationsSavedSearchJa savedSearch = _TranslationsSavedSearchJa._(_root);
	@override late final _TranslationsDefaultBlacklistReminderJa defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderJa._(_root);
	@override late final _TranslationsColorVisionAssistJa colorVisionAssist = _TranslationsColorVisionAssistJa._(_root);
	@override late final _TranslationsExternalPlayerJa externalPlayer = _TranslationsExternalPlayerJa._(_root);
	@override late final _TranslationsWatchLaterJa watchLater = _TranslationsWatchLaterJa._(_root);
	@override late final _TranslationsMediaMenuJa mediaMenu = _TranslationsMediaMenuJa._(_root);
	@override late final _TranslationsMediaPreviewJa mediaPreview = _TranslationsMediaPreviewJa._(_root);
	@override late final _TranslationsPlaybackQueueJa playbackQueue = _TranslationsPlaybackQueueJa._(_root);
	@override late final _TranslationsVrFormatJa vrFormat = _TranslationsVrFormatJa._(_root);
	@override late final _TranslationsLocalMediaJa localMedia = _TranslationsLocalMediaJa._(_root);
	@override late final _TranslationsHistoryPageJa historyPage = _TranslationsHistoryPageJa._(_root);
	@override late final _TranslationsAiJa ai = _TranslationsAiJa._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileJa extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'プロフィール';
	@override String get editPersonalProfile => 'プロフィール編集';
	@override String get avatar => 'アバター';
	@override String get background => '背景';
	@override String fetchUserProfileFailed({required Object error}) => 'ユーザー情報の取得に失敗しました: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => '推奨解像度：${resolution}、ファイルサイズ < ${size}';
	@override String supportedFormats({required Object formats}) => 'サポート形式：${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'プレミアムユーザーは動的な${type} (${formats}) を使用できます';
	@override String get homepageBackground => 'プロフィール背景';
	@override String get basicInfo => '基本情報';
	@override String get nickname => 'ニックネーム';
	@override String get username => 'ユーザー名';
	@override String get copyUsername => 'ユーザー名をコピー';
	@override String get usernameCopied => 'ユーザー名をコピーしました';
	@override String get personalIntroduction => '自己紹介';
	@override String get noPersonalIntroduction => '自己紹介がありません';
	@override String get clickToEdit => 'クリックして編集';
	@override String get privacySettings => 'プライバシー設定';
	@override String get hideSensitiveContent => 'センシティブな内容を非表示';
	@override String get hideSensitiveContentDesc => 'センシティブなタグを含む動画や画像を非表示にします。';
	@override String get notificationSettings => '通知設定';
	@override String get contentCommentNotification => 'コンテンツへのコメント通知';
	@override String get contentCommentNotificationDesc => 'あなたのコンテンツにコメントがあったときに通知します。';
	@override String get commentReplyNotification => 'コメントへの返信通知';
	@override String get commentReplyNotificationDesc => 'あなたのコメントに返信があったときに通知します。';
	@override String get mentionNotification => 'メンション通知';
	@override String get mentionNotificationDesc => 'コンテンツ内であなたをメンションしたときに通知します。';
	@override String get accountInfo => 'アカウント情報';
	@override String get registrationTime => '登録日時';
	@override String updateSettingsFailed({required Object error}) => '設定の更新に失敗しました: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => '通知設定の更新に失敗しました: ${error}';
	@override String get editNickname => 'ニックネームの変更';
	@override String get nicknameCannotBeEmpty => 'ニックネームを空にすることはできません';
	@override String get changeSuccess => '変更に成功しました';
	@override String get unsupportedFileFormat => 'サポートされていないファイル形式';
	@override String fileTooLarge({required Object size}) => 'ファイルサイズは ${size} を超えることはできません';
	@override String get uploadFailed => 'アップロードに失敗しました';
	@override String get avatarUpdatedSuccessfully => 'アバターを更新しました';
	@override String updateAvatarFailed({required Object error}) => 'アバターの更新に失敗しました: ${error}';
	@override String get backgroundUpdatedSuccessfully => '背景を更新しました';
	@override String updateBackgroundFailed({required Object error}) => '背景の更新に失敗しました: ${error}';
	@override String get editPersonalIntroduction => '自己紹介の編集';
	@override String get enterPersonalIntroduction => '自己紹介を入力してください';
}

// Path: tutorial
class _TranslationsTutorialJa extends TranslationsTutorialEn {
	_TranslationsTutorialJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => '特別フォロー';
	@override String get specialFollowDescription => 'よく見る著者を特別フォローにしておくと、ここからワンタップで切り替えて最新の投稿だけを追えます。';
	@override String get stepsTitle => '3ステップで追加';
	@override String get stepFollowAuthor => '著者の動画・ギャラリー・プロフィールページで「フォロー」をタップ。';
	@override String get stepPickSpecial => 'もう一度「フォロー済み」をタップし、メニューから「特別フォロー」を選択。';
	@override String get stepSwitchHere => '購読ページに戻り、上のアイコン選択でその著者に切り替え。';
	@override String get specialFollowManagementTip => '特別フォローリストはサイドドロワー - フォローリスト - 特別フォローで管理できます。';
	@override String get gotIt => 'OK';
}

// Path: common
class _TranslationsCommonJa extends TranslationsCommonEn {
	_TranslationsCommonJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sort => '並び替え';
	@override String get filter => 'フィルター';
	@override String get appName => 'Love Iwara';
	@override String get ok => '確定';
	@override String get cancel => 'キャンセル';
	@override String get select => '選択';
	@override String get save => '保存';
	@override String get delete => '削除';
	@override String get visit => 'アクセス';
	@override String get loading => '読み込み中...';
	@override String get scrollToTop => 'トップに戻る';
	@override String get privacyHint => 'プライバシーモード中：内容は非表示です';
	@override String get latest => '最新';
	@override String get likesCount => 'いいね数';
	@override String get viewsCount => '視聴回数';
	@override String get popular => '人気';
	@override String get trending => 'トレンド';
	@override String get commentList => 'コメント一覧';
	@override String get sendComment => 'コメントを投稿';
	@override String get send => '送信';
	@override String get retry => '再試行';
	@override String get premium => 'プレミアム会員';
	@override String get follower => 'フォロワー';
	@override String get friend => '友達';
	@override String get video => 'ビデオ';
	@override String get following => 'フォロー中';
	@override String get expand => '展開';
	@override String get collapse => '收起';
	@override String get cancelFriendRequest => '友達申請を取り消す';
	@override String get cancelSpecialFollow => '特別フォローを解除';
	@override String get addFriend => '友達を追加';
	@override String get removeFriend => '友達を解除';
	@override String get followed => 'フォロー済み';
	@override String get follow => 'フォローする';
	@override String get unfollow => 'フォロー解除';
	@override String get specialFollow => '特別フォロー';
	@override String get specialFollowed => '特別フォロー済み';
	@override String get specialFollowsManagementTip => 'ハンドルをドラッグで並べ替え • 右のボタンで削除';
	@override String get specialFollowsManagement => '特別フォロー管理';
	@override String get removeSpecialFollow => '特別フォローを解除';
	@override String removeSpecialFollowConfirm({required Object name}) => '${name} を特別フォローから外しますか？';
	@override String get noSpecialFollows => '特別フォローはまだありません';
	@override String get createTimeDesc => '作成時間降順';
	@override String get createTimeAsc => '作成時間昇順';
	@override String get gallery => 'ギャラリー';
	@override String get playlist => 'プレイリスト';
	@override String get commentPostedSuccessfully => 'コメントが正常に投稿されました';
	@override String get commentPostedFailed => 'コメントの投稿に失敗しました';
	@override String get success => '成功';
	@override String get commentDeletedSuccessfully => 'コメントが削除されました';
	@override String get commentUpdatedSuccessfully => 'コメントが更新されました';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 件のコメント',
		other: '${n} 件のコメント',
	);
	@override String get writeYourCommentHere => 'ここにコメントを入力...';
	@override String get tmpNoReplies => '返信はありません';
	@override String get loadMore => 'もっと読み込む';
	@override String get loadingMore => 'さらに読み込み中...';
	@override String get noMoreDatas => 'これ以上データはありません';
	@override String get selectTranslationLanguage => '翻訳言語を選択';
	@override String get translate => '翻訳';
	@override String get translateFailedPleaseTryAgainLater => '翻訳に失敗しました。後でもう一度お試しください';
	@override String get translationResult => '翻訳結果';
	@override String get justNow => 'たった今';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 分前',
		other: '${n} 分前',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 時間前',
		other: '${n} 時間前',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 日前',
		other: '${n} 日前',
	);
	@override String editedAt({required Object num}) => '${num} 編集';
	@override String get editComment => 'コメントを編集';
	@override String get commentUpdated => 'コメントが更新されました';
	@override String get replyComment => 'コメントに返信';
	@override String get reply => '返信';
	@override String get edit => '編集';
	@override String get unknownUser => '不明なユーザー';
	@override String get me => '私';
	@override String get author => '作者';
	@override String get admin => '管理者';
	@override String viewReplies({required Object num}) => '返信を表示 (${num})';
	@override String get hideReplies => '返信を非表示';
	@override String get confirmDelete => '削除を確認';
	@override String get areYouSureYouWantToDeleteThisItem => 'この項目を削除してもよろしいですか？';
	@override String get tmpNoComments => 'コメントがありません';
	@override String get refresh => '更新';
	@override String get back => '戻る';
	@override String get tips => 'ヒント';
	@override String get linkIsEmpty => 'リンクアドレスが空です';
	@override String get linkCopiedToClipboard => 'リンクアドレスがクリップボードにコピーされました';
	@override String get imageCopiedToClipboard => '画像がクリップボードにコピーされました';
	@override String get copyImageFailed => '画像のコピーに失敗しました';
	@override String get mobileSaveImageIsUnderDevelopment => 'モバイル端末での画像保存機能は現在開発中です';
	@override String get imageSavedTo => '画像が保存されました';
	@override String get saveImageFailed => '画像の保存に失敗しました';
	@override String get close => '閉じる';
	@override String get more => 'もっと見る';
	@override String get unknownError => '未知のエラー';
	@override String get moreFeaturesToBeDeveloped => 'さらに機能が開発中です';
	@override String get all => 'すべて';
	@override String selectedRecords({required Object num}) => '${num} 件のレコードが選択されました';
	@override String get cancelSelectAll => 'すべての選択を解除';
	@override String get selectAll => 'すべて選択';
	@override String get invertSelection => '選択を反転';
	@override String get exitEditMode => '編集モードを終了';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '選択した ${num} 件のレコードを削除してもよろしいですか？';
	@override String get searchHistoryRecords => '検索履歴...';
	@override String get settings => '設定';
	@override String get subscriptions => 'サブスクリプション';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 本の動画',
		other: '${n} 本の動画',
	);
	@override String get share => '共有';
	@override String get areYouSureYouWantToShareThisPlaylist => 'このプレイリストを共有してもよろしいですか？';
	@override String get editTitle => 'タイトルを編集';
	@override String get editMode => '編集モード';
	@override String get pleaseEnterNewTitle => '新しいタイトルを入力してください';
	@override String get createPlayList => 'プレイリストを作成';
	@override String get create => '作成';
	@override String get checkNetworkSettings => 'ネットワーク設定を確認';
	@override String get general => '一般';
	@override String get r18 => 'R18';
	@override String get sensitive => 'センシティブ';
	@override String get year => '年';
	@override String get month => '月';
	@override String get tag => 'タグ';
	@override String get notice => 'お知らせ';
	@override String get private => 'プライベート';
	@override String get noTitle => 'タイトルなし';
	@override String get search => '検索';
	@override String get noContent => 'コンテンツがありません';
	@override String get recording => '録画中';
	@override String get paused => '一時停止';
	@override String get clear => 'クリア';
	@override String get clearSelection => '選択を解除';
	@override String get selectItemsToContinue => '項目を選択してください';
	@override String andMoreItems({required Object num}) => '他 ${num} 件';
	@override String get batchDelete => '一括削除';
	@override String get user => 'ユーザー';
	@override String get post => '投稿';
	@override String get seconds => '秒';
	@override String get comingSoon => '近日公開';
	@override String get confirm => '確認';
	@override String get hour => '時';
	@override String get minute => '分';
	@override String get clickToRefresh => 'クリックして更新';
	@override String get history => '履歴';
	@override String get favorites => 'お気に入り';
	@override String get friends => '友達';
	@override String get playList => 'プレイリスト';
	@override String get checkLicense => 'ライセンスを確認';
	@override String get logout => 'ログアウト';
	@override String get fensi => 'フォロワー';
	@override String get accept => '受け入れる';
	@override String get reject => '拒否';
	@override String get clearAllHistory => 'すべての履歴をクリア';
	@override String get clearAllHistoryConfirm => 'すべての履歴をクリアしてもよろしいですか？';
	@override String get followingList => 'フォロー中リスト';
	@override String get followersList => 'フォロワーリスト';
	@override String get follows => 'フォロー';
	@override String get fans => 'フォロワー';
	@override String get followsAndFans => 'フォローとフォロワー';
	@override String get numViews => '視聴回数';
	@override String get updatedAt => '更新時間';
	@override String get publishedAt => '発表時間';
	@override String get externalVideo => '站外動画';
	@override String get originalText => '原文';
	@override String get showOriginalText => '原文を表示';
	@override String get showProcessedText => '処理後の原文を表示';
	@override String get preview => 'プレビュー';
	@override String get rules => 'ルール';
	@override String get agree => '同意';
	@override String get disagree => '不同意';
	@override String get agreeToRules => '同意ルール';
	@override String get tapToReread => 'タップで全文を再読';
	@override String get markdownSyntaxHelp => 'Markdown構文ヘルプ';
	@override String get previewContent => '内容をプレビュー';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => '最大文字数制限を超過 (${max})';
	@override String get agreeToCommunityRules => 'コミュニティルールに同意';
	@override String get createPost => '投稿を作成';
	@override String get title => 'タイトル';
	@override String get enterTitle => 'タイトルを入力してください';
	@override String get content => '内容';
	@override String get enterContent => '内容を入力してください';
	@override String get writeYourContentHere => '内容を入力してください...';
	@override String get tagBlacklist => 'ブラックリストタグ';
	@override String get noData => 'データがありません';
	@override String get tagLimit => 'タグ上限';
	@override String get enableFloatingButtons => 'フローティングボタンを有効';
	@override String get disableFloatingButtons => 'フローティングボタンを無効';
	@override String get enabledFloatingButtons => 'フローティングボタンが有効';
	@override String get disabledFloatingButtons => 'フローティングボタンが無効';
	@override String get pendingCommentCount => '未審核コメント';
	@override String joined({required Object str}) => '${str} に参加';
	@override String lastSeenAt({required Object str}) => '最終オンライン ${str}';
	@override String get download => 'ダウンロード';
	@override String get selectQuality => '画質を選択';
	@override String get videoQualitySource => 'オリジナル';
	@override String get selectImageQuality => '画質を選択';
	@override String get imageQualityStandard => '標準';
	@override String get imageQualityOriginal => 'オリジナル';
	@override String get selectDateRange => '日付範囲を選択';
	@override String get selectDateRangeHint => '日付範囲を選択，デフォルトは最近30日';
	@override String get clearDateRange => '日付範囲をクリア';
	@override String get deleteRecordsInDateRange => 'この期間の記録を削除';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'この期間の ${num} 件の履歴を削除してもよろしいですか？この操作は取り消せません。';
	@override String get noHistoryRecordsInRange => 'この期間の履歴はありません';
	@override String get followSuccessClickAgainToSpecialFollow => 'フォローに成功しました。再度クリックして特別フォロー';
	@override String get specialFollowTip => '特別フォローに追加しました。購読ページ右上のセレクターで切り替えると、すぐに確認できます';
	@override String get exitConfirmTip => '本当に退出しますか？';
	@override String get error => 'エラー';
	@override String get taskRunning => '既にタスクが実行中です。しばらくお待ちください。';
	@override String get operationCancelled => '操作がキャンセルされました。';
	@override String get unsavedChanges => '未保存の変更があります';
	@override late final _TranslationsCommonPaginationJa pagination = _TranslationsCommonPaginationJa._(_root);
	@override String get detail => '詳細';
	@override String get parseExceptionDestopHint => ' - デスクトップユーザーは設定でプロキシを構成できます';
	@override String get iwaraTags => 'Iwara タグ';
	@override String get tagInfo => 'タグ情報';
	@override String get tagOriginalKey => '元のタグ';
	@override String get tagTranslation => '翻訳';
	@override String get copy => 'コピー';
	@override String get selectCopy => '選択してコピー';
	@override String get copiedToClipboard => 'クリップボードにコピーしました';
	@override String get showOriginalTag => '元のタグを表示';
	@override String get showTranslatedTag => '翻訳を表示';
	@override String get tagTranslationFeedback => '翻訳に疑問がありますか？フィードバック';
	@override String get tagLocalizationGuideTitle => 'タグの翻訳について';
	@override String get tagLocalizationGuideContent => 'アプリは Iwara の元のタグ（例：mother）を、現在の言語の訳名で表示します。\n\n• タグ検索では、訳名でも元のタグでも一致します。\n• タグを長押し / 右クリックすると、元のタグと訳名を確認・コピーできます。\n• 訳名はコミュニティによる有志翻訳であり、誤りが含まれる場合があります。';
	@override String get likeThisVideo => 'この動画が好きな人';
	@override String get likeThisGallery => 'このギャラリーが好きな人';
	@override String get operation => '操作';
	@override String get replies => '返信';
	@override String get externalLinkWarning => '外部リンク警告';
	@override String get externalLinkWarningMessage => 'iwara.tv 以外の外部リンクを開こうとしています。安全性に注意し、リンクが信頼できることを確認してから続行してください。';
	@override String get continueToExternalLink => '続行';
	@override String get cancelExternalLink => 'キャンセル';
}

// Path: auth
class _TranslationsAuthJa extends TranslationsAuthEn {
	_TranslationsAuthJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get login => 'ログイン';
	@override String get logout => 'ログアウト';
	@override String get email => 'メールアドレス';
	@override String get password => 'パスワード';
	@override String get loginOrRegister => 'ログイン / 新規登録';
	@override String get register => '新規登録';
	@override String get pleaseEnterEmail => 'メールアドレスを入力してください';
	@override String get pleaseEnterPassword => 'パスワードを入力してください';
	@override String get passwordMustBeAtLeast6Characters => 'パスワードは6文字以上必要です';
	@override String get pleaseEnterCaptcha => 'キャプチャを入力してください';
	@override String get captcha => 'キャプチャ';
	@override String get refreshCaptcha => 'キャプチャを更新';
	@override String get captchaNotLoaded => 'キャプチャを読み込めませんでした';
	@override String get loginSuccess => 'ログインに成功しました';
	@override String get loginSuccessProfilePending => 'ログインしました。プロフィールを読み込んでいます…';
	@override String get emailVerificationSent => 'メール認証が送信されました';
	@override String get notLoggedIn => 'ログインしていません';
	@override String get clickToLogin => 'こちらをクリックしてログイン';
	@override String get logoutConfirmation => '本当にログアウトしますか？';
	@override String get logoutSuccess => 'ログアウトに成功しました';
	@override String get logoutFailed => 'ログアウトに失敗しました';
	@override String get usernameOrEmail => 'ユーザー名またはメールアドレス';
	@override String get pleaseEnterUsernameOrEmail => 'ユーザー名またはメールアドレスを入力してください';
	@override String get rememberMe => 'ユーザー名を記憶';
	@override String get registerNoticeTitle => '公式サイトで新規登録';
	@override String get registerNoticeDescription => 'アプリ内での新規登録は提供されなくなりました。Iwara 公式サイトでアカウントを作成し、こちらに戻ってログインしてください。';
	@override String get registerNoticeReturnTip => '登録後、こちらに戻ってアカウントでログインしてください。';
	@override String get goToOfficialWebsite => '公式サイトを開く';
}

// Path: errors
class _TranslationsErrorsJa extends TranslationsErrorsEn {
	_TranslationsErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get error => 'エラー';
	@override String get required => 'この項目は必須です';
	@override String get invalidEmail => 'メールアドレスの形式が正しくありません';
	@override String get networkError => 'ネットワークエラーが発生しました。再試行してください';
	@override String get errorWhileFetching => '情報の取得に失敗しました';
	@override String get commentCanNotBeEmpty => 'コメント内容は空にできません';
	@override String get errorWhileFetchingReplies => '返信の取得中にエラーが発生しました。ネットワーク接続を確認してください';
	@override String get canNotFindCommentController => 'コメントコントローラーが見つかりません';
	@override String get errorWhileLoadingGallery => 'ギャラリーの読み込み中にエラーが発生しました';
	@override String get howCouldThereBeNoDataItCantBePossible => 'え？データがありません。エラーが発生した可能性があります :<';
	@override String unsupportedImageFormat({required Object str}) => 'サポートされていない画像形式: ${str}';
	@override String get invalidGalleryId => '無効なギャラリーIDです';
	@override String get translationFailedPleaseTryAgainLater => '翻訳に失敗しました。後でもう一度お試しください';
	@override String get errorOccurred => 'エラーが発生しました。しばらくしてから再試行してください。';
	@override String get errorOccurredWhileProcessingRequest => 'リクエストの処理中にエラーが発生しました';
	@override String get errorWhileFetchingDatas => 'データの取得中にエラーが発生しました。後でもう一度お試しください';
	@override String get serviceNotInitialized => 'サービスが初期化されていません';
	@override String get unknownType => '不明なタイプです';
	@override String errorWhileOpeningLink({required Object link}) => 'リンクを開けませんでした: ${link}';
	@override String get invalidUrl => '無効なURLです';
	@override String get failedToOperate => '操作に失敗しました';
	@override String get permissionDenied => '権限がありません';
	@override String get youDoNotHavePermissionToAccessThisResource => 'このリソースにアクセスする権限がありません';
	@override String get loginFailed => 'ログインに失敗しました';
	@override String get unknownError => '不明なエラーです';
	@override String get sessionExpired => 'セッションが期限切れです';
	@override String get failedToFetchCaptcha => 'キャプチャの取得に失敗しました';
	@override String get emailAlreadyExists => 'メールアドレスは既に存在します';
	@override String get invalidCaptcha => '無効なキャプチャです';
	@override String get registerFailed => '登録に失敗しました';
	@override String get failedToFetchComments => 'コメントの取得に失敗しました';
	@override String get failedToFetchImageDetail => '画像の取得に失敗しました';
	@override String get failedToFetchImageList => '画像の取得に失敗しました';
	@override String get failedToFetchData => 'データの取得に失敗しました';
	@override String get invalidParameter => '無効なパラメータです';
	@override String get pleaseLoginFirst => 'ログインしてください';
	@override String get errorWhileLoadingPost => '投稿の取得中にエラーが発生しました';
	@override String get errorWhileLoadingPostDetail => '投稿詳細の取得中にエラーが発生しました';
	@override String get invalidPostId => '無効な投稿IDです';
	@override String get forceUpdateNotPermittedToGoBack => '現在強制更新状態です。戻ることはできません';
	@override String get pleaseLoginAgain => 'ログインしてください';
	@override String get invalidLogin => 'ログインに失敗しました。メールアドレスとパスワードを確認してください';
	@override String get tooManyRequests => 'リクエストが多すぎます。後でもう一度お試しください';
	@override String exceedsMaxLength({required Object max}) => '最大長さを超えています: ${max}';
	@override String get contentCanNotBeEmpty => 'コンテンツは空にできません';
	@override String get titleCanNotBeEmpty => 'タイトルは空にできません';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'リクエストが多すぎます。後でもう一度お試しください。残り時間';
	@override String remainingHours({required Object num}) => '${num}時間';
	@override String remainingMinutes({required Object num}) => '${num}分';
	@override String remainingSeconds({required Object num}) => '${num}秒';
	@override String tagLimitExceeded({required Object limit}) => 'タグの上限を超えています。上限: ${limit}';
	@override String get failedToRefresh => '更新に失敗しました';
	@override String get noPermission => '権限がありません';
	@override String get resourceNotFound => 'リソースが見つかりません';
	@override String get failedToSaveCredentials => 'ログイン情報の保存に失敗しました';
	@override String get failedToLoadSavedCredentials => '保存されたログイン情報の読み込みに失敗しました';
	@override String get notFound => 'コンテンツが見つかりませんまたは削除されました';
	@override late final _TranslationsErrorsNetworkJa network = _TranslationsErrorsNetworkJa._(_root);
}

// Path: friends
class _TranslationsFriendsJa extends TranslationsFriendsEn {
	_TranslationsFriendsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => '友達を復元するにはクリックしてください';
	@override String get friendsList => '友達リスト';
	@override String get friendRequests => '友達リクエスト';
	@override String get friendRequestsList => '友達リクエスト一覧';
	@override String get removingFriend => 'フレンド解除中...';
	@override String get failedToRemoveFriend => 'フレンド解除に失敗しました';
	@override String get cancelingRequest => 'フレンド申請をキャンセル中...';
	@override String get failedToCancelRequest => 'フレンド申請のキャンセルに失敗しました';
}

// Path: authorProfile
class _TranslationsAuthorProfileJa extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'これ以上データはありません';
	@override String get userProfile => 'ユーザープロフィール';
}

// Path: favorites
class _TranslationsFavoritesJa extends TranslationsFavoritesEn {
	_TranslationsFavoritesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'お気に入りを復元するにはクリックしてください';
	@override String get myFavorites => '私のお気に入り';
	@override String get batchCancelFavorite => 'お気に入りを一括解除';
	@override String batchCancelFavoriteConfirm({required Object count}) => '選択した ${count} 件のお気に入りを解除しますか？解除後もカードをタップすれば復元できます。';
	@override String batchCancelFavoriteSuccess({required Object count}) => '${count} 件のお気に入りを解除しました';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => '${success} 件を解除しました。${failed} 件は失敗しました';
}

// Path: galleryDetail
class _TranslationsGalleryDetailJa extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => '空間で閲覧';
	@override String get galleryDetail => 'ギャラリー詳細';
	@override String get viewGalleryDetail => 'ギャラリー詳細を表示';
	@override String get zoomReset => 'ズームをリセット';
	@override String get copyLink => 'リンクをコピー';
	@override String get copyImage => '画像をコピー';
	@override String get saveAs => '名前を付けて保存';
	@override String get saveToAlbum => 'アルバムに保存';
	@override String get publishedAt => '公開日時';
	@override String get viewsCount => '視聴回数';
	@override String get imageLibraryFunctionIntroduction => 'ギャラリー機能の紹介';
	@override String get rightClickToSaveSingleImage => '右クリックで単一画像を保存';
	@override String get batchSave => 'バッチ保存';
	@override String get keyboardLeftAndRightToSwitch => 'キーボードの左右キーで切り替え';
	@override String get keyboardUpAndDownToZoom => 'キーボードの上下キーでズーム';
	@override String get mouseWheelToSwitch => 'マウスホイールで切り替え';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + マウスホイールでズーム';
	@override String get moreFeaturesToBeDiscovered => 'さらに機能が発見されます...';
	@override String get authorOtherGalleries => '作者の他のギャラリー';
	@override String get relatedGalleries => '関連ギャラリー';
	@override String get authorNoOtherGalleries => '他のギャラリーはありません';
	@override String get noRelatedGalleries => '関連するギャラリーはありません';
	@override String get scrollLeft => '左へスクロール';
	@override String get scrollRight => '右へスクロール';
	@override String get clickLeftAndRightEdgeToSwitchImage => '左端と右端をクリックして切り替え';
	@override String get rotateToLandscape => '横画面で全画面';
	@override String get backToPortrait => '縦画面に戻す';
}

// Path: playList
class _TranslationsPlayListJa extends TranslationsPlayListEn {
	_TranslationsPlayListJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => '私のプレイリスト';
	@override String get friendlyTips => 'フレンドリーティップス';
	@override String get dearUser => '親愛なるユーザー';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'iwaraのプレイリストシステムはまだ完全ではありません';
	@override String get notSupportSetCover => 'カバー設定はサポートされていません';
	@override String get notSupportDeleteList => 'リストの削除はできません';
	@override String get notSupportSetPrivate => 'プライベート設定はできません';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'はい...作成されたリストは常に存在し、全員に表示されます';
	@override String get smallSuggestion => '小さな提案';
	@override String get useLikeToCollectContent => 'プライバシーを重視する場合は、「いいね」機能を使用してコンテンツを収集することをお勧めします';
	@override String get welcomeToDiscussOnGitHub => 'その他の提案やアイデアがある場合は、GitHubでのディスカッションを歓迎します！';
	@override String get iUnderstand => 'わかりました';
	@override String get searchPlaylists => 'プレイリストを検索...';
	@override String get newPlaylistName => '新しいプレイリスト名';
	@override String get createNewPlaylist => '新しいプレイリストを作成';
	@override String get videos => '動画';
}

// Path: search
class _TranslationsSearchJa extends TranslationsSearchEn {
	_TranslationsSearchJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => '検索範囲';
	@override String get searchTags => 'タグを検索...';
	@override String get contentRating => 'コンテンツレーティング';
	@override String get removeTag => 'タグを削除';
	@override String get pleaseEnterSearchContent => '検索内容を入力してください';
	@override String get exactMatch => '完全一致';
	@override String get exactMatchOnHint => 'フレーズ全体で完全一致し、中国語・日本語のタイトルも併せて検索しています。タップで緩い検索に戻します。';
	@override String get exactMatchOffHint => '緩い一致です（iwara が語を分割します）。タップでフレーズ全体の完全一致に。';
	@override String get searchHistory => '検索履歴';
	@override String get searchSuggestion => '検索提案';
	@override String get usedTimes => '使用回数';
	@override String get lastUsed => '最後の使用';
	@override String get noSearchHistoryRecords => '検索履歴がありません';
	@override String get clearSearchHistoryConfirm => 'すべての検索履歴を消去してもよろしいですか？この操作は元に戻せません。';
	@override String notSupportCurrentSearchType({required Object searchType}) => '現在の検索タイプ ${searchType} はまだ実装されていません。お楽しみに';
	@override String get searchResult => '検索結果';
	@override String unsupportedSearchType({required Object searchType}) => 'サポートされていない検索タイプ: ${searchType}';
	@override String get googleSearch => 'グーグル検索';
	@override String googleSearchHint({required Object webName}) => '${webName} の検索機能は使いにくいですか？ グーグル検索を試してみてください！';
	@override String get googleSearchDescription => 'Google Search の :site 検索演算子を使用して、サイトのコンテンツを検索します。これは、動画、ギャラリー、プレイリスト、ユーザーを検索する際に非常に便利です。';
	@override String get googleSearchKeywordsHint => '検索するキーワードを入力してください';
	@override String get openLinkJump => 'リンクジャンプを開く';
	@override String get googleSearchButton => 'グーグル検索';
	@override String get pleaseEnterSearchKeywords => '検索するキーワードを入力してください';
	@override String get googleSearchQueryCopied => '検索語句をクリップボードにコピーしました';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'ブラウザを開けませんでした: ${error}';
	@override String get searchRequestTimeout => 'リクエストがタイムアウトしました。しばらくしてから再試行してください';
	@override String get searchCannotConnectToServer => 'サーバーに接続できません。ネットワーク接続を確認してください';
	@override String get searchNetworkError => 'ネットワーク接続に失敗しました。ネットワーク設定を確認するか、しばらくしてから再試行してください';
	@override String get searchFailedPleaseRetry => '検索に失敗しました。しばらくしてから再試行してください';
}

// Path: mediaList
class _TranslationsMediaListJa extends TranslationsMediaListEn {
	_TranslationsMediaListJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => '個人紹介';
}

// Path: settings
class _TranslationsSettingsJa extends TranslationsSettingsEn {
	_TranslationsSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'リスト表示モード';
	@override String get previewEffect => 'プレビュー効果';
	@override String get useTraditionalPaginationMode => '従来のページネーションモードを使用';
	@override String get useTraditionalPaginationModeDesc => '従来のページネーションモードを使用すると、ページネーションモードが無効になります。ページを再レンダリングまたはアプリを再起動した後に有効になります';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => '底部プログレスバー';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'この設定は、ツールバーが非表示のときに底部プログレスバーを表示するかどうかを決定します。';
	@override String get seekPreviewSize => 'シークプレビューのサイズ';
	@override String get seekPreviewSizeDesc => 'プログレスバーの上に表示されるプレビュー窓の大きさ。プレイヤーのサイズと動画の縦横比には元から追従します。ここではその上で少しだけ調整します。';
	@override String get seekPreviewSizeSmall => '小';
	@override String get seekPreviewSizeStandard => '標準';
	@override String get seekPreviewSizeLarge => '大';
	@override String get seekPreviewSizeStandardDesc => 'プレイヤーと動画から自動的に決まるサイズ';
	@override String get showFullscreenUpNextHint => '「次に見る」の取っ手を表示';
	@override String get showFullscreenUpNextHintDesc => 'プレイヤー右端に取っ手を表示し、キュー（元のリスト / 再生リスト / あとで見る）を開きます。オフにすると他の入口はありません。';
	@override String get basicSettings => '基本設定';
	@override String get personalizedSettings => '個性化設定';
	@override String get otherSettings => 'その他設定';
	@override String get searchConfig => '検索設定';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'この設定は、今後動画を再生する際に以前の設定を使用するかどうかを決定します。';
	@override String get playControl => '再生コントロール';
	@override String get playbackSpeedSettings => '再生と速度';
	@override String get playbackBehaviorSettings => '再生動作';
	@override String get enhancementSettings => 'シアターと画質強化';
	@override String get fastForwardTime => '早送り時間';
	@override String get fastForwardTimeMustBeAPositiveInteger => '早送り時間は正の整数でなければなりません。';
	@override String get rewindTime => '巻き戻し時間';
	@override String get rewindTimeMustBeAPositiveInteger => '巻き戻し時間は正の整数でなければなりません。';
	@override String get longPressPlaybackSpeed => '長押し再生速度';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => '長押し再生速度は正の数でなければなりません。';
	@override String get defaultPlaybackSpeed => 'デフォルト再生速度';
	@override String get rememberPlaybackSpeed => '再生速度を記憶する';
	@override String get rememberPlaybackSpeedDesc => '有効にすると、プレーヤーで調整した再生速度がデフォルトとして保存され、以降の新しい動画に自動的に適用されます。';
	@override String get repeat => 'リピート';
	@override String get renderVerticalVideoInVerticalScreen => '全画面再生時に縦向きビデオを縦画面モードでレンダリング';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'この設定は、全画面再生時に縦向きビデオを縦画面モードでレンダリングするかどうかを決定します。';
	@override String get rememberVolume => '音量を記憶';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'この設定は、今後動画を再生する際に以前の音量設定を使用するかどうかを決定します。';
	@override String get rememberBrightness => '明るさを記憶';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'この設定は、今後動画を再生する際に以前の明るさ設定を使用するかどうかを決定します。';
	@override String get playControlArea => '再生コントロールエリア';
	@override String get leftAndRightControlAreaWidth => '左右コントロールエリアの幅';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'この設定は、プレイヤーの左右にあるコントロールエリアの幅を決定します。';
	@override String get proxyAddressCannotBeEmpty => 'プロキシアドレスは空にできません。';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => '無効なプロキシアドレス形式です。IP:ポート または ドメイン名:ポート の形式を使用してください。';
	@override String get proxyNormalWork => 'プロキシが正常に動作しています。';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'プロキシリクエストが失敗しました。ステータスコード: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'プロキシリクエスト中にエラーが発生しました: ${exception}';
	@override String get proxyConfig => 'プロキシ設定';
	@override String get thisIsHttpProxyAddress => 'ここにHTTPプロキシアドレスを入力してください';
	@override String get checkProxy => 'プロキシを確認';
	@override String get proxyAddress => 'プロキシアドレス';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'プロキシサーバーのURLを入力してください（例: 127.0.0.1:8080）';
	@override String get enableProxy => 'プロキシを有効にする';
	@override String get left => '左';
	@override String get middle => '中央';
	@override String get right => '右';
	@override String get playerSettings => 'プレイヤー設定';
	@override String get networkSettings => 'ネットワーク設定';
	@override String get customizeYourPlaybackExperience => '再生体験をカスタマイズ';
	@override String get chooseYourFavoriteAppAppearance => 'お好みのアプリ外観を選択';
	@override String get configureYourProxyServer => 'プロキシサーバーを設定';
	@override String get settings => '設定';
	@override String get themeSettings => 'テーマ設定';
	@override String get followSystem => 'システムに従う';
	@override String get lightMode => 'ライトモード';
	@override String get darkMode => 'ダークモード';
	@override String get presetTheme => 'プリセットテーマ';
	@override String get basicTheme => 'ベーシックテーマ';
	@override String get needRestartToApply => 'アプリを再起動して設定を適用してください';
	@override String get themeNeedRestartDescription => 'テーマ設定はアプリを再起動して設定を適用してください';
	@override String get about => 'アバウト';
	@override String get diagnosticsAndFeedback => '診断とフィードバック';
	@override String get currentVersion => '現在のバージョン';
	@override String get latestVersion => '最新バージョン';
	@override String get checkForUpdates => '更新をチェック';
	@override String get update => '更新';
	@override String get newVersionAvailable => '新しいバージョンが利用可能です';
	@override String get projectHome => 'プロジェクトホーム';
	@override String get release => 'リリース';
	@override String get issueReport => '問題報告';
	@override String get openSourceLicense => 'オープンソースライセンス';
	@override String get checkForUpdatesFailed => '更新のチェックに失敗しました。後でもう一度お試しください';
	@override String get autoCheckUpdate => '自動更新';
	@override String get updateContent => '更新内容';
	@override String get releaseDate => 'リリース日';
	@override String get ignoreThisVersion => 'このバージョンを無視';
	@override String get forceUpdateTip => 'これは必須アップデートです。できるだけ早く最新バージョンにアップデートしてください';
	@override String get viewChangelog => '更新内容を表示';
	@override String get alreadyLatestVersion => 'すでに最新バージョンです';
	@override String get appSettings => 'アプリ設定';
	@override String get configureYourAppSettings => 'アプリ設定を設定';
	@override String get history => '履歴';
	@override String get autoRecordHistory => '自動記録履歴';
	@override String get autoRecordHistoryDesc => '視聴した動画やギャラリーなどの情報を自動的に記録します';
	@override String get autoDeleteHistory => '履歴の自動削除';
	@override String get autoDeleteHistoryDesc => '起動時に保存日数を超えた閲覧履歴を自動的に削除します（デフォルトはオフ）';
	@override String get autoDeleteHistoryDays => '保存日数';
	@override String autoDeleteHistoryDaysValue({required Object num}) => '直近 ${num} 日間を保存';
	@override String get autoDeleteHistoryDaysInvalid => '有効な日数を入力してください（1日以上）';
	@override String get showUnprocessedMarkdownText => '未処理のMarkdownテキストを表示';
	@override String get showUnprocessedMarkdownTextDesc => 'Markdownの元のテキストを表示';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'プライバシーモード';
	@override String get activeBackgroundPrivacyModeDesc => 'スクリーンショットと画面録画を禁止し、バックグラウンドでは画面を隠します';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'バックグラウンドに移ると画面を隠します（このプラットフォームではスクリーンショットを防げません）';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'スクリーンショットと画面録画を禁止します';
	@override String get privacy => 'プライバシー';
	@override String get appLock => 'アプリロック';
	@override String get appLockEnabled => 'アプリロックを有効にする';
	@override String get appLockEnabledDesc => 'アプリを開くときに PIN または生体認証を要求し、バックグラウンドの画面も自動的に隠します';
	@override String get appLockEnabledSummary => 'オン · PIN で保護';
	@override String get appLockDisabledSummary => 'オフ';
	@override String get appLockTimeout => 'アプリを離れた後にロック';
	@override String get appLockTimeoutDesc => 'バックグラウンド移行後、再認証を要求するまでの時間';
	@override String get appLockAfterScreenOff => '画面ロック後にロック';
	@override String get appLockAfterScreenOffDesc => '端末の画面ロック後、アプリに戻るときに再認証を要求します';
	@override String get appLockTimeoutDisabled => '無効';
	@override String get appLockImmediately => 'すぐに';
	@override String appLockSeconds({required Object seconds}) => '${seconds} 秒';
	@override String appLockMinutes({required Object minutes}) => '${minutes} 分';
	@override String get appLockUseBiometrics => '生体認証を使用';
	@override String get appLockUseBiometricsDesc => '指紋認証または顔認証でロックを解除します';
	@override String get appLockBiometricsUnavailable => 'この端末で利用できる生体認証がありません';
	@override String get appLockSetPin => 'PIN を設定';
	@override String get appLockEnterPin => 'PIN を入力';
	@override String get appLockConfirmPin => 'PIN を確認';
	@override String get appLockCurrentPin => '現在の PIN を入力';
	@override String get appLockNewPin => '新しい PIN を入力';
	@override String get appLockPinRequirements => 'PIN は 4～8 桁の数字にしてください';
	@override String get appLockPinsDoNotMatch => 'PIN が一致しません';
	@override String get appLockInvalidPin => 'PIN が正しくありません';
	@override String get appLockSetupFailed => 'PIN を安全に保存できませんでした';
	@override String get appLockDisable => 'アプリロックを無効にするには PIN を入力してください';
	@override String get appLockChangePin => 'PIN を変更';
	@override String get appLockNow => '今すぐロック';
	@override String get appLockUnlock => 'ロック解除';
	@override String get appLockLockedTitle => 'ロックされています';
	@override String get appLockLockedDesc => '続行するには認証してください';
	@override String get appLockAuthenticateReason => 'ロックを解除するために認証してください';
	@override String get appLockEnableBiometricsReason => '生体認証によるロック解除を有効にするために認証してください';
	@override String get appLockBiometricFailed => '生体認証を完了できませんでした';
	@override String appLockTooManyAttempts({required Object seconds}) => '試行回数が多すぎます。${seconds} 秒後に再試行してください';
	@override String get appLockCredentialUnavailableTitle => 'アプリロックの認証情報を読み取れません';
	@override String get appLockCredentialUnavailableDesc => 'システムのセキュアストレージが一時的に利用できないか、認証情報が破損しています。アプリはロックされたままです。まず再試行してください。それでも失敗する場合はアプリロックをリセットできます（アプリロックが無効になり、保存済みの PIN が削除されます）。';
	@override String get appLockRetry => '再試行';
	@override String get appLockReset => 'アプリロックをリセット';
	@override String get appLockResetAction => 'リセット';
	@override String get appLockResetConfirmTitle => 'アプリロックをリセットしますか？';
	@override String get appLockResetConfirmDesc => 'アプリロックを無効にし、保存済みの PIN と生体認証設定を削除します。後で再設定できます。';
	@override String get appLockRetrySucceeded => '認証情報を読み取れました。PIN を入力してください。';
	@override String get appLockRetryFailed => '認証情報を読み取れませんでした';
	@override String get forum => 'フォーラム';
	@override String get news => 'ニュース';
	@override String get community => 'コミュニティ';
	@override String get disableForumReplyQuote => 'フォーラム返信引用を無効にする';
	@override String get disableForumReplyQuoteDesc => 'フォーラム返信時の返信階層情報の携帯を無効にする';
	@override String get theaterMode => '劇院モード';
	@override String get theaterModeDesc => '開啟後、プレーヤー背景がビデオカバーのぼかしバージョンに設定されます';
	@override String get appLinks => 'アプリリンク';
	@override String get defaultBrowser => 'デフォルトブラウザ';
	@override String get defaultBrowserDesc => 'システム設定でデフォルトリンク設定項目を開き、iwara.tvサイトリンクを追加してください';
	@override String get themeMode => 'テーマモード';
	@override String get themeModeDesc => 'この設定はアプリのテーマモードを決定します';
	@override String get glassEffect => '画面のマテリアル';
	@override String get glassEffectDesc => 'アプリ全体（ヘッダーのカプセル、メニュー、ダイアログのボタン、ボトムナビゲーション）に使う素材を決めます';
	@override String get liquidGlassEffect => 'リキッドガラス';
	@override String get liquidGlassEffectDesc => '本物のぼかしと屈折を使う素材。見た目は最高ですが、低スペック端末ではコマ落ちや電池消費が増えることがあります';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => '標準的な Material 3 の画面。不透明でぼかしも影もなく、動作と電池持ちが最も良好です';
	@override String get glassEffectIntroTitle => '画面のマテリアルを選ぶ';
	@override String get glassEffectIntroContent => '現在はヘッダー・タブバー・メニューがリキッドガラス（本物のぼかしと屈折）です。端末で重いと感じる場合やシンプルな見た目が好みなら、今すぐ Material（不透明・ぼかしなし・影なし）に切り替えられます。';
	@override String get glassEffectIntroHint => '後からでも「設定 → テーマ設定 → 画面のマテリアル」でいつでも変更できます。';
	@override String get glassEffectIntroDone => 'これでOK';
	@override String get dynamicColor => 'ダイナミックカラー';
	@override String get dynamicColorDesc => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
	@override String get useDynamicColor => 'ダイナミックカラーを使用';
	@override String get useDynamicColorDesc => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
	@override String get presetColors => 'プリセットカラー';
	@override String get customColors => 'カスタムカラー';
	@override String get customColorsDisabledByDynamicColor => 'ダイナミックカラーが有効なため、プリセット/カスタムカラーは使用できません。先にダイナミックカラーをオフにしてください';
	@override String get pickColor => 'カラーを選択';
	@override String get cancel => 'キャンセル';
	@override String get confirm => '確認';
	@override String get noCustomColors => 'カスタムカラーがありません';
	@override String get recordAndRestorePlaybackProgress => '再生進度を記録して復元';
	@override String get autoPlayVideoOnFirstEnter => '初回入場時に動画を自動再生';
	@override String get autoPlayVideoOnFirstEnterDesc => 'この設定は、動画ページに初めて入った時に動画を自動再生するかどうかを決定します。';
	@override String get autoEnterFullscreen => '自動で全画面にする';
	@override String get autoEnterFullscreenDesc => 'プレイヤーが自動で全画面に移行するタイミング。非公開／削除済みの動画、外部サイトの動画、およびピクチャインピクチャ中は常に移行しません';
	@override String get autoEnterFullscreenOff => 'オフ';
	@override String get autoEnterFullscreenOffDesc => '自動では全画面にしない';
	@override String get autoEnterFullscreenOnPlaybackStart => '再生開始時';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => '再生が実際に始まった瞬間に全画面へ移行する';
	@override String get autoEnterFullscreenOnDetailPageEnter => '動画を開いた時';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => '再生を待たず、動画ページを開いた時点で全画面へ移行する';
	@override String get autoEnterFullscreenKind => '全画面の種類';
	@override String get autoEnterFullscreenKindDesc => '自動でどちらの全画面にするか。デスクトップ版のみ';
	@override String get autoEnterFullscreenKindSystem => 'システム全画面';
	@override String get autoEnterFullscreenKindSystemDesc => 'ウィンドウマネージャーにウィンドウを全画面にさせる';
	@override String get autoEnterFullscreenKindApp => 'アプリ全画面';
	@override String get autoEnterFullscreenKindAppDesc => 'ウィンドウの大きさは変えず、アプリ全体をプレイヤーにする';
	@override String get signature => '小尾巴';
	@override String get enableSignature => '小尾巴を有効にする';
	@override String get enableSignatureDesc => 'この設定はアプリが回覆時に小尾巴を有効にするかどうかを決定します';
	@override String get enterSignature => '小尾巴を入力';
	@override String get editSignature => '小尾巴を編集';
	@override String get signatureContent => '小尾巴の内容';
	@override String get signaturePreview => 'プレビュー';
	@override String get signatureSampleBody => 'ここに本文が入ります';
	@override String get signatureRegenerate => '別の一言にする';
	@override String get signatureNotSet => '未設定';
	@override String get signatureRuleHint => '署名は本文の後ろに、区切り線を挟んで付きます。区切り線はアプリが入れるので、下の一文だけ書いてください。';
	@override String get signatureInsertVariable => '変数を挿入';
	@override String get varDate => '日付';
	@override String get varTime => '時刻';
	@override String get varDatetime => '日付と時刻';
	@override String get varWeekday => '曜日';
	@override String get varApp => 'アプリ名';
	@override String get varVersion => 'バージョン';
	@override String get varPlatform => 'プラットフォーム';
	@override String get varTitle => '今見ている作品';
	@override String get varAuthor => 'その作者';
	@override String get varPick => 'ランダムな一文';
	@override String get signatureSources => 'データソース';
	@override String get signatureAutoTranslate => '自分の言語に翻訳する';
	@override String get signatureAutoTranslateDesc => '一言のようなデータソースは今のところ中国語だけです。取得した一文は送信の直前に翻訳されます。';
	@override String get signatureWizardTitle => 'データソースを追加';
	@override String get signatureWizardUrlTitle => 'エンドポイントのURL';
	@override String get signatureWizardUrlHint => '一文を返してくれるURLを入力してください。下のボタンで実際に一度呼び出して、何が返ってくるか確かめます。';
	@override String get signatureWizardFetch => '取得してみる';
	@override String get signatureWizardSkipTest => 'スキップして名前だけ変える';
	@override String get signatureWizardPickTitle => '使いたい部分を選ぶ';
	@override String get signatureWizardPickHint => 'これがそのエンドポイントから返ってきた内容です。署名に出したい行をタップしてください。';
	@override String get signatureWizardPickPlainHint => 'このエンドポイントはテキストをそのまま返しました。全体がそのまま表示されます。';
	@override String get signatureWizardWholeBody => 'レスポンス全体';
	@override String get signatureWizardNameTitle => '名前をつける';
	@override String get signatureWizardNameHint => '名前はあなたが見分けるためのものです。署名から指し示すのは下の参照名のほうです。';
	@override String get signatureWizardNext => '次へ';
	@override String get signatureWizardDone => '完了';
	@override String get signatureWizardStripHtml => 'HTMLタグを取り除く';
	@override String get signatureWizardAdvanced => '詳細：正規表現で抜き出す';
	@override String get signatureWizardExtractHint => '正規表現。最初のキャプチャグループを使います';
	@override String get signatureWizardExtractMissed => 'この式に一致しなかったので、そのままの文字列を使います';
	@override String get signatureWizardChooseTitle => '選んでください';
	@override String get signatureWizardChooseHint => '用意されたものを選べばそれで完了です。自分のエンドポイントを指定することもできます。';
	@override String get signatureWizardCustomSource => '自分のエンドポイントを使う';
	@override String get signatureWizardWithOrigin => '出典も付ける';
	@override String get signatureWizardRandomItem => '毎回ランダムに選ぶ';
	@override String get signatureWizardSuffixTitle => 'もう一つの項目をつなげる';
	@override String get signatureWizardSuffixNone => 'なし';
	@override String get signatureOptFlavor => '内容';
	@override String get signatureOptFlavorAny => '指定しない';
	@override String get signatureOptFlavorOtaku => 'アニメ・漫画・ゲーム';
	@override String get signatureOptFlavorLiterary => '文学・詩';
	@override String get signatureOptFlavorMeme => 'ネット文化';
	@override String get signatureOptLength => '長さ';
	@override String get signatureOptLengthAny => '指定しない';
	@override String get signatureOptLengthShort => '短い一文だけ';
	@override String get signatureRestoreDefault => '既定に戻す';
	@override String get signatureSourceHitokoto => 'ひとこと';
	@override String get signatureAiSourceName => 'AI ひとこと';
	@override String get signatureEditTextHint => 'このコメントに既に書かれている署名です。一言も日付も今はただの文字なので自由に直せます。空にすれば署名なしになります。';
	@override String signatureResolving({required Object name}) => '${name}を生成中…';
	@override String get signaturePendingValue => '（送信時に生成）';
	@override String get signatureAiHint => 'AI がその場で書く一言。コメントごとに新しくなります。設定した AI プロバイダーを使います。';
	@override String get signatureAiUnavailable => 'AI プロバイダーが未設定のため、変数パネルには表示されません。';
	@override String get signaturePromptTitle => 'プロンプト';
	@override String get signaturePromptHint => 'モデルに送られるのがこれです。口調も長さも題材も自由に書き換えてかまいません。既に入っているルールは残す価値があります。';
	@override String get signaturePromptReset => '既定に戻す';
	@override String get signaturePromptTry => '試す';
	@override String get signaturePromptSample => '書かれたもの';
	@override String get signaturePromptLanguageHint => 'は表示言語に置き換わります。削除するとプロンプトの言語に従います。';
	@override String get signaturePromptEdited => '変更済み';
	@override String get signatureVariablesGroup => '組み込み変数';
	@override String get signatureNeedsNetwork => 'ネットワークが必要';
	@override String get signatureBuiltinSource => '標準';
	@override String get signatureSourceIdReserved => 'その名前は組み込み変数が使っています';
	@override String get signatureSourcesTitle => 'カスタムデータソース';
	@override String get signatureSourcesHint => '一文を返すエンドポイントを指定すれば、その内容を署名に取り込めます。';
	@override String get signatureSourcesEmpty => 'データソースはまだありません';
	@override String get signatureAddSource => '追加';
	@override String get signatureEditSource => 'データソースを編集';
	@override String get signatureSourceName => '名前';
	@override String get signatureSourceId => '参照名';
	@override String get signatureSourceIdHint => '署名からこのデータソースを呼ぶときの名前';
	@override String get signatureSourceUrl => 'エンドポイントURL';
	@override String get signatureSourcePath => '値のパス';
	@override String get signatureSourcePathHint => 'レスポンス全体がその一文なら空のままに。JSON から取り出す場合は data.text のように指定します。';
	@override String get signatureSourceTest => 'テスト';
	@override String get signatureSourceTestOk => '取得できました';
	@override String get signatureSourceTestFailed => '何も返ってきませんでした';
	@override String get signatureSourceIdInvalid => '参照名に使えるのは小文字・数字・アンダースコアだけです';
	@override String get signatureSourceIdDuplicate => 'その参照名はすでに使われています';
	@override String get signatureSourceUrlRequired => 'エンドポイントURLを入力してください';
	@override String get exportConfig => 'アプリ設定をエクスポート';
	@override String get exportConfigDesc => '設定と履歴（閲覧履歴、再生進捗、お気に入りなど）をファイルにエクスポートし、バックアップや他のデバイスへの同期に利用できます。ダウンロードタスクは含まれません。';
	@override String get importConfig => 'アプリ設定をインポート';
	@override String get importConfigDesc => 'ファイルからアプリ設定をインポートします';
	@override String get exportConfigSuccess => '設定が正常にエクスポートされました';
	@override String get exportConfigFailed => '設定のエクスポートに失敗しました';
	@override String get importConfigSuccess => '設定が正常にインポートされました';
	@override String get importConfigFailed => '設定のインポートに失敗しました';
	@override String get exportIncludeSensitive => '機密情報を含める';
	@override String get exportIncludeSensitiveDesc => 'APIキー、セッショントークン、プロキシアドレスを含みます。自分のデバイスにバックアップする場合のみ有効にしてください。';
	@override String get importConfigOverwriteWarning => 'インポートすると現在の設定と履歴（閲覧履歴、再生進捗、お気に入りなど）が上書きされます。続行しますか？';
	@override String get importConfigRestartTitle => 'インポート完了';
	@override String get importConfigRestartContent => '設定をインポートしました。すべての変更を反映するには、アプリを完全に終了してから再起動してください。';
	@override String get historyUpdateLogs => '歴代アップデートログ';
	@override String get noUpdateLogs => 'アップデートログが取得できませんでした';
	@override String get versionLabel => 'バージョン: {version}';
	@override String get releaseDateLabel => 'リリース日: {date}';
	@override String get noChanges => '更新内容がありません';
	@override String get interaction => 'インタラクション';
	@override String get enableVibration => 'バイブレーション';
	@override String get enableVibrationDesc => 'アプリの操作時にバイブレーションフィードバックを有効にする';
	@override String get defaultKeepVideoToolbarVisible => 'ツールバーを常に表示';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'この設定は、動画ページに入った時にツールバーを常に表示するかどうかを決定します。';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'モバイル端でシアターモードを有効にすると、パフォーマンスの問題が発生する可能性があるため、状況に応じてご利用ください。';
	@override String get fullscreenOrientation => 'フルスクリーン時のデフォルト画面方向';
	@override String get fullscreenOrientationDesc => 'この設定は、フルスクリーン時のデフォルト画面方向を決定します（モバイルのみ）';
	@override String get fullscreenOrientationLeftLandscape => '左横画面';
	@override String get fullscreenOrientationRightLandscape => '右横画面';
	@override String get screenFit => '画面サイズ';
	@override String get screenFitDesc => 'プレイヤー内での映像の表示方法を選択します。';
	@override String get rememberScreenFit => '画面サイズを記憶';
	@override String get rememberScreenFitDesc => '有効にすると、以降開く動画に現在の選択が適用されます。';
	@override String get screenFitFit => 'フィット';
	@override String get screenFitFitDesc => 'アスペクト比を保ったまま全体を表示します';
	@override String get screenFitStretch => 'ストレッチ';
	@override String get screenFitStretchDesc => '再生領域いっぱいに引き伸ばします（変形する場合があります）';
	@override String get screenFitCover => 'クロップ';
	@override String get screenFitCoverDesc => 'アスペクト比を保ったまま領域を埋め、はみ出た部分は切り取られます';
	@override String get screenFitRatioDesc => 'この比率に引き伸ばして表示します（変形する場合があります）';
	@override String get jumpLink => 'リンクをジャンプ';
	@override String get language => '言語';
	@override String get languageNativeName => '日本語';
	@override String get followSystemLanguage => 'システムに従う';
	@override String get languageChangedMessage => '言語が正常に変更されました。一部の機能はアプリを再起動して有効にする必要があります。';
	@override String get languageChanged => '言語設定が変更されました。アプリを再起動して有効にしてください。';
	@override late final _TranslationsSettingsKeybindingJa keybinding = _TranslationsSettingsKeybindingJa._(_root);
	@override String get gestureControl => 'ジェスチャー制御';
	@override String get leftDoubleTapRewind => '左側ダブルタップリワインド';
	@override String get rightDoubleTapFastForward => '右側ダブルタップファストフォワード';
	@override String get doubleTapPause => 'ダブルタップポーズ';
	@override String get rightVerticalSwipeVolume => '右側垂直スワイプボリューム（新ページに入った時に有効）';
	@override String get leftVerticalSwipeBrightness => '左側垂直スワイプブライトネス（新ページに入った時に有効）';
	@override String get longPressFastForward => '長押しファストフォワード';
	@override String get enableMouseHoverShowToolbar => 'マウスホバー時にツールバーを表示';
	@override String get enableMouseHoverShowToolbarInfo => '有効にすると、マウスがプレーヤー上にあるときにツールバーが表示されます。3秒間の非アクティブ時に自動的に非表示になります。';
	@override String get enableHorizontalDragSeek => '横スワイプでシーク';
	@override String get enableVideoGestureZoom => 'ピンチで映像を拡大';
	@override String get enableVideoGestureZoomInfo => '2本指のピンチ（デスクトップでは Ctrl + マウスホイール）で映像を拡大し、拡大後はドラッグで移動できます。';
	@override String get showCenterPlayPauseButton => '中央の再生/一時停止ボタン';
	@override String get showCenterPlayPauseButtonDesc => 'プレーヤー中央の大きな再生/一時停止ボタンを表示します。';
	@override String get audioVideoConfig => 'オーディオビデオ設定';
	@override String get expandBuffer => 'バッファ拡張';
	@override String get expandBufferInfo => '有効にすると、バッファサイズが増加し、読み込み時間が長くなりますが、再生がスムーズになります';
	@override String get videoSyncMode => 'ビデオ同期モード';
	@override String get videoSyncModeSubtitle => 'オーディオビデオ同期戦略';
	@override String get hardwareDecodingMode => 'ハードウェアデコードモード';
	@override String get hardwareDecodingModeSubtitle => 'ハードウェアデコード設定';
	@override String get enableHardwareAcceleration => 'ハードウェアアクセラレーションを有効にする';
	@override String get enableHardwareAccelerationInfo => 'ハードウェアアクセラレーションを有効にすると、デコード性能が向上しますが、一部のデバイスでは互換性がない場合があります';
	@override String get useOpenSLESAudioOutput => 'OpenSLESオーディオ出力を使用';
	@override String get useOpenSLESAudioOutputInfo => '低遅延オーディオ出力を使用し、オーディオ性能が向上する可能性があります';
	@override String get videoSyncAudio => 'オーディオ同期';
	@override String get videoSyncDisplayResample => 'ディスプレイリサンプル';
	@override String get videoSyncDisplayResampleVdrop => 'ディスプレイリサンプル（フレームドロップ）';
	@override String get videoSyncDisplayResampleDesync => 'ディスプレイリサンプル（非同期）';
	@override String get videoSyncDisplayTempo => 'ディスプレイテンポ';
	@override String get videoSyncDisplayVdrop => 'ディスプレイビデオフレームドロップ';
	@override String get videoSyncDisplayAdrop => 'ディスプレイオーディオフレームドロップ';
	@override String get videoSyncDisplayDesync => 'ディスプレイ非同期';
	@override String get videoSyncDesync => '非同期';
	@override late final _TranslationsSettingsForumSettingsJa forumSettings = _TranslationsSettingsForumSettingsJa._(_root);
	@override late final _TranslationsSettingsGallerySettingsJa gallerySettings = _TranslationsSettingsGallerySettingsJa._(_root);
	@override late final _TranslationsSettingsBlockSettingsJa blockSettings = _TranslationsSettingsBlockSettingsJa._(_root);
	@override late final _TranslationsSettingsChatSettingsJa chatSettings = _TranslationsSettingsChatSettingsJa._(_root);
	@override String get hardwareDecodingAuto => '自動';
	@override String get hardwareDecodingAutoCopy => '自動コピー';
	@override String get hardwareDecodingAutoSafe => '自動セーフ';
	@override String get hardwareDecodingNo => '無効';
	@override String get hardwareDecodingYes => '強制有効';
	@override String get cdnDistributionStrategy => 'コンテンツ配信戦略';
	@override String get cdnDistributionStrategyDesc => '動画ソースサーバーの配信戦略を選択して、読み込み速度を最適化します';
	@override String get cdnDistributionStrategyLabel => '配信戦略';
	@override String get cdnDistributionStrategyNoChange => '変更なし（元のサーバーを使用）';
	@override String get cdnDistributionStrategyAuto => '自動選択（最速サーバー）';
	@override String get cdnDistributionStrategySpecial => 'サーバーを指定';
	@override String get cdnSpecialServer => 'サーバーを指定';
	@override String get cdnRefreshServerListHint => '下のボタンをクリックしてサーバーリストを更新してください';
	@override String get cdnRefreshButton => '更新';
	@override String get cdnFastRingServers => '高速リングサーバー';
	@override String get cdnRefreshServerListTooltip => 'サーバーリストを更新';
	@override String get cdnSpeedTestButton => '速度テスト';
	@override String cdnSpeedTestingButton({required Object count}) => 'テスト中 (${count})';
	@override String get cdnNoServerDataHint => 'サーバーデータがありません、更新ボタンをクリックしてください';
	@override String get cdnTestingStatus => 'テスト中';
	@override String get cdnUnreachableStatus => '到達不可';
	@override String get cdnNotTestedStatus => '未テスト';
	@override late final _TranslationsSettingsDownloadSettingsJa downloadSettings = _TranslationsSettingsDownloadSettingsJa._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsJa extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'お気に入りタグ';
	@override String get emptyIwara => 'お気に入りの Iwara タグはまだありません';
	@override String get emptyOreno3d => 'お気に入りはまだありません';
	@override String get addIwaraTag => 'Iwara タグを追加';
	@override String get quickPickHint => 'お気に入りは検索のクイック選択に表示されます。';
	@override String get pickerTitle => 'Oreno3D を選択';
	@override String get searchHint => '名前または原語で検索';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n,
		one: '${n} 作品',
		other: '${n} 作品',
	);
	@override String get browseEntry => '原作 / キャラ / タグを閲覧';
	@override String get favoritesSection => 'お気に入り';
	@override String get addFavorite => '追加';
	@override String get iwaraTitle => 'お気に入りの Iwara タグ';
	@override String get oreno3dTitle => 'お気に入りの Oreno3D タグ';
	@override String get changeTag => 'タグを変更';
	@override String get switchToText => 'テキスト検索';
}

// Path: oreno3d
class _TranslationsOreno3dJa extends TranslationsOreno3dEn {
	_TranslationsOreno3dJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'タグ';
	@override String get characters => 'キャラクター';
	@override String get origin => '原作';
	@override String get thirdPartyTagsExplanation => 'ここに表示される**タグ**、**キャラクター**、**原作**情報は第三者サイト **Oreno3D** が提供するものであり、参考情報です。\n\nこの情報ソースは日本語のみのため、現在国際化対応が不足しています。\n\nもし国際化開発にご興味があれば、ぜひリポジトリにアクセスしてご協力ください！';
	@override late final _TranslationsOreno3dSortTypesJa sortTypes = _TranslationsOreno3dSortTypesJa._(_root);
	@override late final _TranslationsOreno3dErrorsJa errors = _TranslationsOreno3dErrorsJa._(_root);
	@override late final _TranslationsOreno3dLoadingJa loading = _TranslationsOreno3dLoadingJa._(_root);
	@override late final _TranslationsOreno3dMessagesJa messages = _TranslationsOreno3dMessagesJa._(_root);
}

// Path: signIn
class _TranslationsSignInJa extends TranslationsSignInEn {
	_TranslationsSignInJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'サインインする前にログインしてください';
	@override String get alreadySignedInToday => '今日は既にサインインしています！';
	@override String get youDidNotStickToTheSignIn => 'サインインを続けることができませんでした。';
	@override String get signInSuccess => 'サインインに成功しました！';
	@override String get signInFailed => 'サインインに失敗しました。後でもう一度お試しください';
	@override String get consecutiveSignIns => '連続サインイン日数';
	@override String get failureReason => 'サインインに失敗した理由';
	@override String get selectDateRange => '日付範囲を選択';
	@override String get startDate => '開始日';
	@override String get endDate => '終了日';
	@override String get invalidDate => '日付形式が正しくありません';
	@override String get invalidDateRange => '日付範囲が無効です';
	@override String get errorFormatText => '日付形式が正しくありません';
	@override String get errorInvalidText => '日付範囲が無効です';
	@override String get errorInvalidRangeText => '日付範囲が無効です';
	@override String get dateRangeCantBeMoreThanOneYear => '日付範囲は1年を超えることはできません';
	@override String get signIn => 'サインイン';
	@override String get signInRecord => 'サインイン記録';
	@override String get totalSignIns => '合計サインイン数';
	@override String get pleaseSelectSignInStatus => 'サインインステータスを選択してください';
}

// Path: subscriptions
class _TranslationsSubscriptionsJa extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'サブスクリプションを表示するにはログインしてください。';
	@override String get selectUser => 'ユーザーを選択してください';
	@override String get noSubscribedUsers => '購読中のユーザーがいません';
	@override String get showAllSubscribedUsersContent => 'すべての購読中のユーザーのコンテンツを表示';
}

// Path: videoDetail
class _TranslationsVideoDetailJa extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'ピプモード';
	@override String resumeFromLastPosition({required Object position}) => '${position} から続けて再生';
	@override String resumedFromHistoryTip({required Object position}) => '${position} から再開しました';
	@override String get restartFromBeginning => '最初から';
	@override String get dismissResumeTip => '閉じる';
	@override late final _TranslationsVideoDetailLocalInfoJa localInfo = _TranslationsVideoDetailLocalInfoJa._(_root);
	@override String get videoIdIsEmpty => 'ビデオIDが空です';
	@override String get videoInfoIsEmpty => 'ビデオ情報が空です';
	@override String get thisIsAPrivateVideo => 'これはプライベートビデオです';
	@override String get getVideoInfoFailed => 'ビデオ情報の取得に失敗しました。後でもう一度お試しください';
	@override String get noVideoSourceFound => '対応するビデオソースが見つかりません';
	@override String tagCopiedToClipboard({required Object tagId}) => 'タグ "${tagId}" がクリップボードにコピーされました';
	@override String get errorLoadingVideo => 'ビデオの読み込み中にエラーが発生しました';
	@override String get play => '再生';
	@override String get pause => '一時停止';
	@override String get exitAppFullscreen => 'アプリの全画面表示を終了';
	@override String get enterAppFullscreen => 'アプリを全画面表示';
	@override String get exitSystemFullscreen => 'システム全画面表示を終了';
	@override String get enterSystemFullscreen => 'システム全画面表示';
	@override String get seekTo => '指定時間にシーク';
	@override String get switchResolution => '解像度を変更';
	@override String get switchPlaybackSpeed => '再生速度を変更';
	@override String rewindSeconds({required Object num}) => '${num} 秒巻き戻し';
	@override String fastForwardSeconds({required Object num}) => '${num} 秒早送り';
	@override String playbackSpeedIng({required Object rate}) => '${rate} 倍速で再生中';
	@override String get brightness => '明るさ';
	@override String get brightnessLowest => '明るさが最低になっています';
	@override String get volume => '音量';
	@override String get volumeMuted => '音量がミュートされています';
	@override String get restoreDefaultZoom => 'リセット';
	@override late final _TranslationsVideoDetailGestureGuideJa gestureGuide = _TranslationsVideoDetailGestureGuideJa._(_root);
	@override String get home => 'ホーム';
	@override String get videoPlayer => 'ビデオプレーヤー';
	@override String get videoPlayerInfo => 'プレーヤー情報';
	@override String get moreSettings => 'さらに設定';
	@override String get videoPlayerFeatureInfo => 'プレーヤー機能の紹介';
	@override String get autoRewind => '自動リワインド';
	@override String get rewindAndFastForward => '両側をダブルクリックして早送りまたは巻き戻し';
	@override String get volumeAndBrightness => '両側を上下にスワイプして音量と明るさを調整';
	@override String get centerAreaDoubleTapPauseOrPlay => '中央エリアをダブルタップして一時停止または再生';
	@override String get showVerticalVideoInFullScreen => '全画面表示時に縦向きビデオを表示';
	@override String get keepLastVolumeAndBrightness => '前回の音量と明るさを保持';
	@override String get setProxy => 'プロキシを設定';
	@override String get moreFeaturesToBeDiscovered => 'さらに機能が発見されます...';
	@override String get videoPlayerSettings => 'プレーヤー設定';
	@override String commentCount({required Object num}) => '${num} 件のコメント';
	@override String get writeYourCommentHere => 'ここにコメントを入力...';
	@override String get authorOtherVideos => '作者の他のビデオ';
	@override String get relatedVideos => '関連ビデオ';
	@override String get privateVideo => 'これはプライベートビデオです';
	@override String get externalVideo => 'これは站外ビデオです';
	@override String get openInBrowser => 'ブラウザで開く';
	@override String get resourceDeleted => 'このビデオは削除されたようです :/';
	@override String get noDownloadUrl => 'ダウンロードURLがありません';
	@override String get startDownloading => 'ダウンロードを開始';
	@override String get downloadFailed => 'ダウンロードに失敗しました。後でもう一度お試しください';
	@override String get downloadSuccess => 'ダウンロードに成功しました';
	@override String get download => 'ダウンロード';
	@override String get downloadManager => 'ダウンロード管理';
	@override String get videoLoadError => 'ビデオの読み込みに失敗しました';
	@override String get resourceNotFound => 'リソースが見つかりませんでした';
	@override String get authorNoOtherVideos => '作者は他のビデオを所有していません';
	@override String get noRelatedVideos => '関連するビデオはありません';
	@override late final _TranslationsVideoDetailPlayerJa player = _TranslationsVideoDetailPlayerJa._(_root);
	@override late final _TranslationsVideoDetailSkeletonJa skeleton = _TranslationsVideoDetailSkeletonJa._(_root);
	@override late final _TranslationsVideoDetailCastJa cast = _TranslationsVideoDetailCastJa._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsJa likeAvatars = _TranslationsVideoDetailLikeAvatarsJa._(_root);
}

// Path: share
class _TranslationsShareJa extends TranslationsShareEn {
	_TranslationsShareJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'プレイリストを共有';
	@override String get wowDidYouSeeThis => 'ああ、見たの？';
	@override String get nameIs => '名前は';
	@override String get clickLinkToView => 'リンクをクリックして見る';
	@override String get iReallyLikeThis => '本当に好きです';
	@override String get shareFailed => '共有に失敗しました。後でもう一度お試しください';
	@override String get share => '共有';
	@override String get shareAsImage => '画像として共有';
	@override String get shareAsText => 'テキストとして共有';
	@override String get shareAsImageDesc => '動画のサムネイルを画像として共有';
	@override String get shareAsTextDesc => '動画の詳細をテキストとして共有';
	@override String get shareAsImageFailed => 'サムネイルの共有に失敗しました。後でもう一度お試しください';
	@override String get shareAsTextFailed => '詳細の共有に失敗しました。後でもう一度お試しください';
	@override String get shareVideo => '動画を共有';
	@override String get authorIs => '作者は';
	@override String get shareGallery => 'ギャラリーを共有';
	@override String get galleryTitleIs => 'ギャラリーのタイトルは';
	@override String get galleryAuthorIs => 'ギャラリーの作者は';
	@override String get shareUser => 'ユーザーを共有';
	@override String get userNameIs => 'ユーザーの名前は';
	@override String get userAuthorIs => 'ユーザーの作者は';
	@override String get comments => 'コメント';
	@override String get shareThread => 'スレッドを共有';
	@override String get views => '閲覧';
	@override String get sharePost => '投稿を共有';
	@override String get postTitleIs => '投稿のタイトルは';
	@override String get postAuthorIs => '投稿の作者は';
}

// Path: markdown
class _TranslationsMarkdownJa extends TranslationsMarkdownEn {
	_TranslationsMarkdownJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Markdown 構文';
	@override String get iwaraSpecialMarkdownSyntax => 'Iwara 専用構文';
	@override String get internalLink => '站内鏈接';
	@override String get supportAutoConvertLinkBelow => '以下のタイプのリンクを自動変換します：';
	@override String get convertLinkExample => '🎬 ビデオリンク\n🖼️ 画像リンク\n👤 ユーザーリンク\n📌 フォーラムリンク\n🎵 プレイリストリンク\n💬 スレッドリンク';
	@override String get mentionUser => 'ユーザーを言及';
	@override String get mentionUserDescription => '@後にユーザー名を入力すると、ユーザーリンクに自動変換されます';
	@override String get markdownBasicSyntax => 'Markdown 基本構文';
	@override String get paragraphAndLineBreak => '段落と改行';
	@override String get paragraphAndLineBreakDescription => '段落間に空行を入れ、行末に2つのスペースを追加すると改行されます';
	@override String get paragraphAndLineBreakSyntax => 'これは第一段落です\n\nこれは第二段落です\nこの行の後に2つのスペースを追加して  \n改行されます';
	@override String get textStyle => 'テキストスタイル';
	@override String get textStyleDescription => '特殊記号でテキストのスタイルを変更';
	@override String get textStyleSyntax => '**太字テキスト**\n*斜体テキスト*\n~~削除線テキスト~~\n`コードテキスト`';
	@override String get quote => '引用';
	@override String get quoteDescription => '> 符号で引用を作成し、複数の > で多段引用を作成';
	@override String get quoteSyntax => '> これは一階引用です\n>> これは二階引用です';
	@override String get list => 'リスト';
	@override String get listDescription => '数字+点号で順序付きリストを作成し、- で順序なしリストを作成';
	@override String get listSyntax => '1. 第一項\n2. 第二項\n\n- 順序なし項\n  - 子項\n  - 別の子項';
	@override String get linkAndImage => 'リンクと画像';
	@override String get linkAndImageDescription => 'リンク形式：[テキスト](URL)\n画像形式：![説明](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[リンクテキスト](${link})\n![画像説明](${imgUrl})';
	@override String get title => 'タイトル';
	@override String get titleDescription => '＃ 号でタイトルを作成し、数でレベルを表示';
	@override String get titleSyntax => '# 一階タイトル\n## 二階タイトル\n### 三階タイトル';
	@override String get separator => '分隔線';
	@override String get separatorDescription => '三個以上の - 号で分隔線を作成';
	@override String get separatorSyntax => '---';
	@override String get syntax => '語法';
}

// Path: forum
class _TranslationsForumJa extends TranslationsForumEn {
	_TranslationsForumJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get attachQuote => '引用を付ける';
	@override String replyToFloor({required Object floor, required Object username}) => '#${floor} @${username} に返信';
	@override String get removeQuote => '引用を削除';
	@override String get recent => '最近';
	@override String get category => 'カテゴリ';
	@override String get lastReply => '最終返信';
	@override late final _TranslationsForumSitewideJa sitewide = _TranslationsForumSitewideJa._(_root);
	@override late final _TranslationsForumErrorsJa errors = _TranslationsForumErrorsJa._(_root);
	@override String get title => 'タイトル';
	@override String get createPost => '投稿を作成';
	@override String get enterTitle => 'タイトルを入力してください';
	@override String get content => 'コンテンツ';
	@override String get enterContent => 'コンテンツを入力してください';
	@override String get writeYourContentHere => 'ここにコンテンツを入力...';
	@override String get posts => '投稿';
	@override String get threads => 'スレッド';
	@override String get forum => 'フォーラム';
	@override String get createThread => 'スレッドを作成';
	@override String get selectCategory => 'カテゴリを選択';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'クールダウン残り時間 ${minutes} 分 ${seconds} 秒';
	@override late final _TranslationsForumGroupsJa groups = _TranslationsForumGroupsJa._(_root);
	@override late final _TranslationsForumLeafNamesJa leafNames = _TranslationsForumLeafNamesJa._(_root);
	@override late final _TranslationsForumLeafDescriptionsJa leafDescriptions = _TranslationsForumLeafDescriptionsJa._(_root);
	@override String get reply => '回覆';
	@override String get pendingReview => '審査中';
	@override String get floorNotFound => 'その投稿は存在しないか削除されました';
	@override String get floorNotLoadedYet => 'その投稿はさらに前にあります。続きを読み込むと移動できます';
	@override String get editedAt => '編集日時';
	@override String get copySuccess => 'クリップボードにコピーされました';
	@override String copySuccessForMessage({required Object str}) => 'クリップボードにコピーされました: ${str}';
	@override String get editReply => '編集回覆';
	@override String get editTitle => '編集タイトル';
	@override String get submit => '提出';
}

// Path: notifications
class _TranslationsNotificationsJa extends TranslationsNotificationsEn {
	_TranslationsNotificationsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsJa errors = _TranslationsNotificationsErrorsJa._(_root);
	@override String get notifications => '通知';
	@override String get profile => '個人主頁';
	@override String get postedNewComment => '新しいコメントを投稿';
	@override String get inYour => 'あなたの';
	@override String get video => 'ビデオ';
	@override String get repliedYourVideoComment => 'あなたのビデオコメントに返信しました';
	@override String get copyInfoToClipboard => '通知情報をクリップボードにコピー';
	@override String get copySuccess => 'クリップボードにコピーされました';
	@override String copySuccessForMessage({required Object str}) => 'クリップボードにコピーされました: ${str}';
	@override String get markAllAsRead => '全てを既読にする';
	@override String get markAllAsReadSuccess => '全ての通知が既読になりました';
	@override String get markAllAsReadFailed => '全てを既読にするに失敗しました';
	@override String get markSelectedAsRead => '選択した通知を既読にする';
	@override String get markSelectedAsReadSuccess => '選択した通知が既読になりました';
	@override String get markSelectedAsReadFailed => '選択した通知を既読にするに失敗しました';
	@override String get markAsRead => '既読にする';
	@override String get markAsReadSuccess => '通知が既読になりました';
	@override String get markAsReadFailed => '通知を既読にするに失敗しました';
	@override String get notificationTypeHelp => '通知タイプのヘルプ';
	@override String get dueToLackOfNotificationTypeDetails => '通知タイプの詳細情報が不足しているため、現在サポートされているタイプが受信したメッセージをカバーしていない可能性があります';
	@override String get helpUsImproveNotificationTypeSupport => '通知タイプのサポート改善にご協力いただける場合';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 通知情報をコピー\n2. 🐞 プロジェクトリポジトリに issue を提出\n\n⚠️ 注意：通知情報には個人情報が含まれている場合があります。公開したくない場合は、プロジェクト作者にメールで送信することもできます。';
	@override String get goToRepository => 'リポジトリに移動';
	@override String get copy => 'コピー';
	@override String get commentApproved => 'コメントが承認されました';
	@override String get repliedYourProfileComment => 'あなたの個人主頁コメントに返信しました';
	@override String get kReplied => 'さんが';
	@override String get kCommented => 'さんが';
	@override String get kVideo => 'ビデオ';
	@override String get kGallery => 'ギャラリー';
	@override String get kProfile => 'プロフィール';
	@override String get kThread => 'スレッド';
	@override String get kPost => '投稿';
	@override String get kCommentSection => '';
	@override String get kApprovedComment => 'コメントが承認されました';
	@override String get kApprovedVideo => '動画が承認されました';
	@override String get kApprovedGallery => 'ギャラリーが承認されました';
	@override String get kApprovedThread => 'スレッドが承認されました';
	@override String get kApprovedPost => '投稿が承認されました';
	@override String get kApprovedForumPost => 'フォーラム投稿が承認されました';
	@override String get kRejectedContent => 'コンテンツ審査が拒否されました';
	@override String get kUnknownType => '不明な通知タイプ';
}

// Path: conversation
class _TranslationsConversationJa extends TranslationsConversationEn {
	_TranslationsConversationJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsJa errors = _TranslationsConversationErrorsJa._(_root);
	@override String get conversation => '会話';
	@override String get startConversation => '会話を開始';
	@override String get noConversation => '会話がありません';
	@override String get selectFromLeftListAndStartConversation => '左側の会話リストから会話を選択して開始';
	@override String get title => 'タイトル';
	@override String get body => '内容';
	@override String get selectAUser => 'ユーザーを選択';
	@override String get searchUsers => 'ユーザーを検索...';
	@override String get tmpNoConversions => '会話がありません';
	@override String get deleteThisMessage => 'このメッセージを削除';
	@override String get deleteThisMessageSubtitle => 'この操作は取り消せません';
	@override String get writeMessageHere => 'ここにメッセージを入力...';
	@override String get lastMessageFromMe => '自分: ';
	@override String get sendMessage => 'メッセージを送信';
}

// Path: splash
class _TranslationsSplashJa extends TranslationsSplashEn {
	_TranslationsSplashJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsJa errors = _TranslationsSplashErrorsJa._(_root);
	@override String get preparing => '準備中...';
	@override String get initializing => '初期化中...';
	@override String get loading => '読み込み中...';
	@override String get ready => '準備完了';
	@override String get initializingMessageService => 'メッセージサービスを初期化中...';
}

// Path: download
class _TranslationsDownloadJa extends TranslationsDownloadEn {
	_TranslationsDownloadJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsJa errors = _TranslationsDownloadErrorsJa._(_root);
	@override String get downloadList => 'ダウンロードリスト';
	@override String get viewDownloadList => 'ダウンロードリストを表示';
	@override String get download => 'ダウンロード';
	@override String get selectDownloadTitle => 'ダウンロードを選択';
	@override String get qualitySectionLabel => '画質';
	@override String get categorySectionLabel => '分類';
	@override String get saveToPreviewLabel => '保存先';
	@override String saveToPreviewSuggested({required Object name}) => '推奨ファイル名：${name}（システムダイアログで変更可）';
	@override String get lastUsedBadge => '前回選択';
	@override String get pickedBadge => '選択中';
	@override String get forceDeleteTask => '強制削除タスク';
	@override String get startDownloading => 'ダウンロードを開始';
	@override String get clearAllFailedTasks => 'すべての失敗タスクをクリア';
	@override String get clearAllFailedTasksConfirmation => 'すべての失敗タスクをクリアしますか？\nこれらのタスクのファイルも削除されます。';
	@override String get clearAllFailedTasksSuccess => 'すべての失敗タスクをクリアしました';
	@override String get clearAllFailedTasksError => '失敗タスクのクリア中にエラーが発生しました';
	@override String get downloadStatus => 'ダウンロード状態';
	@override String get imageList => '画像リスト';
	@override String get retryDownload => '再試行ダウンロード';
	@override String get notDownloaded => '未ダウンロード';
	@override String get downloaded => 'ダウンロード済み';
	@override String get waitingForDownload => 'ダウンロード待機中';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード中 (${downloaded}/${total}枚 ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'ダウンロード中 (${downloaded}枚)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード一時停止中 (${downloaded}/${total}枚 ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'ダウンロード一時停止中 (${downloaded}枚)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'ダウンロード完了 (合計${total}枚)';
	@override String get viewVideoDetail => 'ビデオ詳細を表示';
	@override String get viewGalleryDetail => 'ギャラリー詳細を表示';
	@override String get moreOptions => 'もっと操作';
	@override String get openFile => 'ファイルを開く';
	@override String get playLocally => 'ローカル再生';
	@override String get pause => '一時停止';
	@override String get resume => '継続';
	@override String get copyDownloadUrl => 'ダウンロードリンクをコピー';
	@override String get showInFolder => 'フォルダーで表示';
	@override String get deleteTask => 'タスクを削除';
	@override String get deleteTaskConfirmation => 'このダウンロードタスクを削除しますか？\nタスクのファイルも削除されます。';
	@override String get forceDeleteTaskConfirmation => 'このダウンロードタスクを強制削除しますか？\nファイルが使用中でも削除を試行し、タスクのファイルも削除されます。';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'ダウンロード中 ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => '一時停止中 ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => '一時停止中 • ダウンロード済み ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'ダウンロード完了 • ${size}';
	@override String get copyDownloadUrlSuccess => 'ダウンロードリンクをコピーしました';
	@override String totalImageNums({required Object num}) => '${num}枚';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'ダウンロード中';
	@override String get failed => '失敗';
	@override String get completed => '完了';
	@override String get downloadDetail => 'ダウンロード詳細';
	@override String get copy => 'コピー';
	@override String get copySuccess => 'コピーしました';
	@override String get waiting => '待機中';
	@override String get paused => '一時停止中';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'ダウンロード中 ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'ギャラリーのダウンロードが完了しました: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'ダウンロードが完了しました: ${fileName}';
	@override String get searchTasks => 'タスクを検索...';
	@override String statusLabel({required Object label}) => 'ステータス: ${label}';
	@override String get allStatus => 'すべてのステータス';
	@override String typeLabel({required Object label}) => 'タイプ: ${label}';
	@override String get allTypes => 'すべてのタイプ';
	@override String get taskType => '種類';
	@override String get video => '動画';
	@override String get gallery => 'ギャラリー';
	@override String get other => 'その他';
	@override String get clearFilters => 'フィルターをクリア';
	@override String get pauseAll => 'すべて一時停止';
	@override String get resumeAll => 'すべて開始';
	@override String remainingTime({required Object time}) => '残り ${time}';
	@override late final _TranslationsDownloadTimelineJa timeline = _TranslationsDownloadTimelineJa._(_root);
	@override late final _TranslationsDownloadErrorTypesJa errorTypes = _TranslationsDownloadErrorTypesJa._(_root);
	@override String get errorDetailCopied => 'エラー詳細をコピーしました';
	@override String get errorDetailCopyHint => '長押しでエラー詳細をコピー';
	@override late final _TranslationsDownloadRestoredPausedJa restoredPaused = _TranslationsDownloadRestoredPausedJa._(_root);
	@override late final _TranslationsDownloadActionsJa actions = _TranslationsDownloadActionsJa._(_root);
	@override late final _TranslationsDownloadNoticeJa notice = _TranslationsDownloadNoticeJa._(_root);
	@override String get emptyTaskList => 'ダウンロードタスクがありません';
	@override String get noMatchingTasks => '一致するタスクがありません';
	@override late final _TranslationsDownloadDeleteByDateJa deleteByDate = _TranslationsDownloadDeleteByDateJa._(_root);
	@override late final _TranslationsDownloadRelocationJa relocation = _TranslationsDownloadRelocationJa._(_root);
	@override late final _TranslationsDownloadCategoryJa category = _TranslationsDownloadCategoryJa._(_root);
	@override late final _TranslationsDownloadLocationJa location = _TranslationsDownloadLocationJa._(_root);
	@override String get maxConcurrentDownloads => '最大同時ダウンロード数';
	@override String get maxConcurrentDownloadsDesc => '同時にダウンロードするタスク数（1-5）';
	@override String get stillInDevelopment => '開発中';
	@override String get saveToAppDirectory => 'アプリケーションディレクトリに保存';
	@override String get alreadyDownloadedWithQuality => 'すでに同じ品質のタスクがあります。続けてダウンロードしますか？';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'すでに品質が${qualities}のタスクがあります。続けてダウンロードしますか？';
	@override String get otherQualities => 'その他の品質';
	@override late final _TranslationsDownloadBatchDownloadJa batchDownload = _TranslationsDownloadBatchDownloadJa._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsJa extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'ダウンロード完了';
	@override String get failedTitle => 'ダウンロード失敗';
	@override String completedBody({required Object name}) => '${name} のダウンロードが完了しました';
	@override String failedBody({required Object name}) => '${name} のダウンロードに失敗しました';
	@override String completedToast({required Object name}) => '${name} をダウンロードしました';
	@override String failedToast({required Object name}) => '${name} のダウンロードに失敗しました';
	@override String savedToFolder({required Object dir}) => '${dir} に保存しました';
	@override String savedAsRenamed({required Object name}) => '${name} として保存しました（同名ファイルが既にあります）';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'アプリフォルダに保存しました — ${target} に書き込めません（${reason}）';
	@override String get viewFolder => 'フォルダを表示';
	@override String get fixInSettings => '設定で修正';
	@override String get channelName => 'ダウンロード状態';
	@override String get channelDescription => 'ダウンロードの完了と失敗の通知';
}

// Path: favorite
class _TranslationsFavoriteJa extends TranslationsFavoriteEn {
	_TranslationsFavoriteJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsJa errors = _TranslationsFavoriteErrorsJa._(_root);
	@override String get add => '追加';
	@override String get addSuccess => '追加に成功しました';
	@override String get addFailed => '追加に失敗しました';
	@override String get remove => '削除';
	@override String get removeSuccess => '削除に成功しました';
	@override String get removeFailed => '削除に失敗しました';
	@override String get removeConfirmation => 'このアイテムをお気に入りから削除しますか？';
	@override String get removeConfirmationSuccess => 'アイテムがお気に入りから削除されました';
	@override String get removeConfirmationFailed => 'アイテムをお気に入りから削除に失敗しました';
	@override String get createFolderSuccess => 'フォルダーが作成されました';
	@override String get createFolderFailed => 'フォルダーの作成に失敗しました';
	@override String get createFolder => 'フォルダーを作成';
	@override String get enterFolderName => 'フォルダー名を入力';
	@override String get enterFolderNameHere => 'フォルダー名を入力してください...';
	@override String get create => '作成';
	@override String get items => 'アイテム';
	@override String get newFolderName => '新しいフォルダー';
	@override String get searchFolders => 'フォルダーを検索...';
	@override String get searchItems => 'アイテムを検索...';
	@override String get createdAt => '作成日時';
	@override String get myFavorites => 'お気に入り';
	@override String get deleteFolderTitle => 'フォルダーを削除';
	@override String deleteFolderConfirmWithTitle({required Object title}) => '${title} フォルダーを削除しますか？';
	@override String get removeItemTitle => 'アイテムを削除';
	@override String removeItemConfirmWithTitle({required Object title}) => '${title} アイテムを削除しますか？';
	@override String get removeItemSuccess => 'アイテムがお気に入りから削除されました';
	@override String get removeItemFailed => 'アイテムをお気に入りから削除に失敗しました';
	@override String get localizeFavorite => 'ローカライズお気に入り';
	@override String get editFolderTitle => 'フォルダー名を編集';
	@override String get editFolderSuccess => 'フォルダー名を更新しました';
	@override String get editFolderFailed => 'フォルダー名の更新に失敗しました';
	@override String get searchTags => 'タグを検索';
	@override String get noTagsInFolder => 'このフォルダーの作品にはまだタグがありません';
	@override String get tagFilterMatchAll => '選択したタグをすべて含む作品のみ表示します';
	@override String get clearSelectedTags => '選択したタグをクリア';
	@override String selectedTagCount({required Object count}) => '${count} 件選択中';
	@override String get noMatchingTags => '一致するタグがありません';
}

// Path: translation
class _TranslationsTranslationJa extends TranslationsTranslationEn {
	_TranslationsTranslationJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get currentService => '現在のサービス';
	@override String get testConnection => 'テスト接続';
	@override String get testConnectionSuccess => 'テスト接続成功';
	@override String get testConnectionFailed => 'テスト接続失敗';
	@override String testConnectionFailedWithMessage({required Object message}) => 'テスト接続失敗: ${message}';
	@override String get translation => '翻訳';
	@override String get needVerification => '検証が必要です';
	@override String get needVerificationContent => 'まず接続テストを行ってからAI翻訳を有効にしてください';
	@override String get confirm => '確定';
	@override String get disclaimer => '使用須知';
	@override String get riskWarning => '風險提示';
	@override String get dureToRisk1 => 'ユーザーが生成したテキストが原因で、AIサービスプロバイダーのコンテンツポリシーに違反する内容が含まれる場合があります';
	@override String get dureToRisk2 => '不当なコンテンツはAPIキーの停止やサービスの終了を引き起こす可能性があります';
	@override String get operationSuggestion => '操作推奨';
	@override String get operationSuggestion1 => '1. 翻訳前に内容を厳格に審査してください';
	@override String get operationSuggestion2 => '2. 暴力、成人向けコンテンツなどを翻訳しないでください';
	@override String get apiConfig => 'API設定';
	@override String get modifyConfigWillAutoCloseAITranslation => '設定を変更するとAI翻訳が自動的に閉じられます。再度開くには接続テストを行ってください';
	@override String get apiAddress => 'APIアドレス';
	@override String get modelName => 'モデル名';
	@override String get modelNameHintText => '例：gpt-4-turbo';
	@override String get maxTokens => '最大トークン数';
	@override String get maxTokensHintText => '例：32000';
	@override String get temperature => '温度係数';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'テストボタンをクリックしてAPI接続を検証';
	@override String get requestPreview => 'リクエストプレビュー';
	@override String get enableAITranslation => 'AI翻訳';
	@override String get enabled => '有効';
	@override String get disabled => '無効';
	@override String get testing => 'テスト中...';
	@override String get testNow => '今すぐテスト';
	@override String get connectionStatus => '接続状態';
	@override String get success => '成功';
	@override String get failed => '失敗';
	@override String get information => '情報';
	@override String get viewRawResponse => '生の応答を表示';
	@override String get pleaseCheckInputParametersFormat => '入力パラメーターの形式を確認してください';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'APIアドレス、モデル名、およびキーを入力してください';
	@override String get pleaseFillInValidConfigurationParameters => '有効な設定パラメーターを入力してください';
	@override String get pleaseCompleteConnectionTest => '接続テストを完了してください';
	@override String get notConfigured => '未設定';
	@override String get apiEndpoint => 'APIエンドポイント';
	@override String get configuredKey => '設定済みキー';
	@override String get notConfiguredKey => '未設定キー';
	@override String get authenticationStatus => '認証状態';
	@override String get thisFieldCannotBeEmpty => 'このフィールドは空にできません';
	@override String get apiKey => 'APIキー';
	@override String get apiKeyCannotBeEmpty => 'APIキーは空にできません';
	@override String get pleaseEnterValidNumber => '有効な数値を入力してください';
	@override String get range => '範囲';
	@override String get mustBeGreaterThan => '以上';
	@override String get invalidAPIResponse => '無効なAPI応答';
	@override String connectionFailedForMessage({required Object message}) => '接続失敗: ${message}';
	@override String get aiTranslationNotEnabledHint => 'AI翻訳は有効にされていません。設定で有効にしてください';
	@override String get goToSettings => '設定に移動';
	@override String get disableAITranslation => 'AI翻訳を無効にする';
	@override String get currentValue => '現在値';
	@override String get configureTranslationStrategy => '翻訳戦略を設定';
	@override String get advancedSettings => '高度な設定';
	@override String get translationPrompt => '翻訳プロンプト';
	@override String get promptHint => '翻訳プロンプトを入力してください。[TL]を目標言語のプレースホルダーとして使用します';
	@override String get promptHelperText => 'プロンプトには[TL]を目標言語のプレースホルダーとして含めてください';
	@override String get promptMustContainTargetLang => 'プロンプトには[TL]プレースホルダーを含めてください';
	@override String get aiTranslationWillBeDisabled => 'AI翻訳が自動的に無効にされます';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => '基本設定を変更したため、AI翻訳が自動的に無効にされます';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => '翻訳プロンプトを変更したため、AI翻訳が自動的に無効にされます';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'パラメーター設定を変更したため、AI翻訳が自動的に無効にされます';
	@override String get onlyOpenAIAPISupported => '現在、OpenAI互換のAPI形式（application/jsonリクエストボディ形式）のみサポートされています';
	@override String get streamingTranslation => 'ストリーミング翻訳';
	@override String get streamingTranslationSupported => 'ストリーミング翻訳対応';
	@override String get streamingTranslationNotSupported => 'ストリーミング翻訳非対応';
	@override String get streamingTranslationDescription => 'ストリーミング翻訳は翻訳プロセス中にリアルタイムで結果を表示し、より良いユーザー体験を提供します';
	@override String get baseUrlInputHelperText => '末尾が#の場合、入力されたURLを実際のリクエストアドレスとして使用します';
	@override String currentActualUrl({required Object url}) => '現在の実際のURL: ${url}';
	@override String get usingFullUrlWithHash => '完全なURL（#で終わる）を使用';
	@override String get urlEndingWithHashTip => 'URLが#で終わる場合、入力されたURLを実際のリクエストアドレスとして使用します';
	@override String get streamingTranslationWarning => '注意：この機能はAPIサービスがストリーミング伝送をサポートする必要があり、一部のモデルではサポートされていない場合があります';
	@override String get translationService => '翻訳サービス';
	@override String get translationServiceDescription => 'お好みの翻訳サービスを選択してください';
	@override String get googleTranslation => 'Google 翻訳';
	@override String get googleTranslationDescription => '複数の言語をサポートする無料のオンライン翻訳サービス';
	@override String get aiTranslation => 'AI 翻訳';
	@override String get aiTranslationDescription => '大規模言語モデルに基づくインテリジェント翻訳サービス';
	@override String get deeplxTranslation => 'DeepLX 翻訳';
	@override String get deeplxTranslationDescription => 'DeepL翻訳のオープンソース実装、高品質な翻訳を提供';
	@override String get googleTranslationFeatures => '機能';
	@override String get freeToUse => '無料で使用';
	@override String get freeToUseDescription => '設定不要、すぐに使用可能';
	@override String get fastResponse => '高速応答';
	@override String get fastResponseDescription => '翻訳速度が速く、遅延が低い';
	@override String get stableAndReliable => '安定で信頼性が高い';
	@override String get stableAndReliableDescription => 'Google公式APIに基づく';
	@override String get enabledDefaultService => '有効 - デフォルト翻訳サービス';
	@override String get notEnabled => '無効';
	@override String get deeplxTranslationService => 'DeepLX 翻訳サービス';
	@override String get deeplxDescription => 'DeepLXはDeepL翻訳のオープンソース実装で、Free、Pro、Officialの3つのエンドポイントモードをサポートしています';
	@override String get serverAddress => 'サーバーアドレス';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'DeepLXサーバーのベースアドレス';
	@override String get endpointType => 'エンドポイントタイプ';
	@override String get freeEndpoint => 'Free - 無料エンドポイント、レート制限がある場合があります';
	@override String get proEndpoint => 'Pro - dl_sessionが必要、より安定';
	@override String get officialEndpoint => 'Official - 公式API形式';
	@override String get finalRequestUrl => '最終リクエストURL';
	@override String get apiKeyOptional => 'API Key (オプション)';
	@override String get apiKeyOptionalHint => '保護されたDeepLXサービスへのアクセス用';
	@override String get apiKeyOptionalHelperText => '一部のDeepLXサービスは認証にAPI Keyが必要です';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Proモードに必要なdl_sessionパラメーター';
	@override String get dlSessionHelperText => 'Proエンドポイントに必要なセッションパラメーター、DeepL Proアカウントから取得';
	@override String get proModeRequiresDlSession => 'Proモードにはdl_sessionの入力が必要です';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'テストボタンをクリックしてDeepLX API接続を検証';
	@override String get enableDeepLXTranslation => 'DeepLX翻訳を有効にする';
	@override String get deepLXTranslationWillBeDisabled => '設定変更によりDeepLX翻訳が無効になります';
	@override String get translatedResult => '翻訳結果';
	@override String get testSuccess => 'テスト成功';
	@override String get pleaseFillInDeepLXServerAddress => 'DeepLXサーバーアドレスを入力してください';
	@override String get invalidAPIResponseFormat => '無効なAPI応答形式';
	@override String get translationServiceReturnedError => '翻訳サービスがエラーまたは空の結果を返しました';
	@override String get connectionFailed => '接続失敗';
	@override String get translationFailed => '翻訳失敗';
	@override String get aiTranslationFailed => 'AI翻訳失敗';
	@override String get deeplxTranslationFailed => 'DeepLX翻訳失敗';
	@override String get aiTranslationTestFailed => 'AI翻訳テスト失敗';
	@override String get deeplxTranslationTestFailed => 'DeepLX翻訳テスト失敗';
	@override String get streamingTranslationTimeout => 'ストリーミング翻訳タイムアウト、リソース強制クリーンアップ';
	@override String get translationRequestTimeout => '翻訳リクエストタイムアウト';
	@override String get streamingTranslationDataTimeout => 'ストリーミング翻訳データ受信タイムアウト';
	@override String get dataReceptionTimeout => 'データ受信タイムアウト';
	@override String get streamDataParseError => 'ストリームデータ解析エラー';
	@override String get streamingTranslationFailed => 'ストリーミング翻訳失敗';
	@override String get fallbackTranslationFailed => '通常翻訳へのフォールバックも失敗';
	@override String get translationSettings => '翻訳設定';
	@override String get enableGoogleTranslation => 'Google翻訳を有効にする';
	@override String get thinking => '思考中…';
	@override String get thoughtProcess => '思考過程';
	@override String get modelCompatibility => 'モデル互換性';
	@override String get modelCompatibilityDescription => '推論モデル(o1/o3、DeepSeek-R1、QwQ など)など最新モデルにリクエストパラメータを適合させます';
	@override String get reasoningModel => '推論モデル';
	@override String get reasoningModelDescription => 'o1/o3、DeepSeek-R1、QwQ など向け：プロンプトをユーザーメッセージに統合し、temperature を送らず、max_completion_tokens を使用します';
	@override String get useMaxCompletionTokens => 'max_completion_tokens を使用';
	@override String get useMaxCompletionTokensDescription => '新しい OpenAI エンドポイントでは非推奨の max_tokens ではなく max_completion_tokens が必要です';
	@override String get sendTemperature => 'temperature を送信';
	@override String get sendTemperatureDescription => 'temperature パラメータを受け付けないモデル(多くの推論モデル)ではオフにしてください';
	@override String get showReasoningProcess => '思考過程を表示';
	@override String get showReasoningProcessDescription => '翻訳ダイアログで推論モデルの思考過程を折りたたみ表示します';
	@override String get provider => 'プロバイダー';
	@override String get providerOpenAI => 'OpenAI（および互換エンドポイント）';
	@override String get providerAnthropic => 'Anthropic（Claude）';
	@override String get providerGoogle => 'Google（Gemini）';
	@override String get multiProviderHint => 'dartantic_ai SDK により OpenAI（およびすべての OpenAI 互換エンドポイント）、Anthropic、Google に対応';
	@override String get baseUrlOptionalHelperText => '任意。空欄でプロバイダー既定のエンドポイントを使用。OpenAI 互換/中継先は入力してください';
	@override String get defaultEndpoint => '既定のエンドポイント';
	@override String get providerPreset => 'プロバイダープリセット';
	@override String get selectProviderPreset => 'プリセットを選択';
	@override String get presetCustom => 'カスタム';
	@override String presetApplied({required Object name}) => 'プリセットを適用しました：${name}';
	@override late final _TranslationsTranslationPresetNamesJa presetNames = _TranslationsTranslationPresetNamesJa._(_root);
	@override String get fetchModelList => 'モデル一覧を取得';
	@override String get fetchingModels => '取得中…';
	@override String get selectModel => 'モデルを選択';
	@override String get searchModel => 'モデルを検索';
	@override String get noModelsFound => 'モデルが見つかりません';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerJa extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'ビデオプレイヤーエラー';
	@override String get videoLoadFailed => 'ビデオ読み込み失敗';
	@override String get videoCodecNotSupported => 'ビデオコーデックがサポートされていません';
	@override String get networkConnectionIssue => 'ネットワーク接続の問題';
	@override String get insufficientPermission => '権限不足';
	@override String get unsupportedVideoFormat => 'サポートされていないビデオ形式';
	@override String get retry => '再試行';
	@override String get externalPlayer => '外部プレイヤー';
	@override String get detailedErrorInfo => '詳細エラー情報';
	@override String get format => '形式';
	@override String get suggestion => '提案';
	@override String get androidWebmCompatibilityIssue => 'AndroidデバイスはWEBM形式のサポートが限定的です。外部プレイヤーの使用またはWEBMをサポートするプレイヤーアプリのダウンロードをお勧めします';
	@override String get currentDeviceCodecNotSupported => '現在のデバイスはこのビデオ形式のコーデックをサポートしていません';
	@override String get checkNetworkConnection => 'ネットワーク接続を確認して再試行してください';
	@override String get appMayLackMediaPermission => 'アプリに必要なメディア再生権限が不足している可能性があります';
	@override String get tryOtherVideoPlayer => '他のビデオプレイヤーをお試しください';
	@override String get unrecognizedVideoFormat => '認識できない動画ファイル';
	@override String get unrecognizedVideoFormatSuggestion => 'リンクが失効したか、返ってきたものが動画ではない可能性があります。再試行するか、他のアプリで開いてください。';
	@override String get accessDenied => 'サーバーがこのアクセスを拒否しました（403）';
	@override String get accessDeniedSuggestion => '再生リンクの有効期限が切れている可能性が高いです。「再試行」で取り直すか、他のアプリで開いてください。';
	@override String get mute => 'ミュート';
	@override String get unmute => 'ミュート解除';
	@override String get video => 'ビデオ';
	@override String get serverSelector => 'CDNサーバー選択';
	@override String get serverSelectorDescription => '最適な再生体験のために、遅延の最も少ないサーバーを選択してください';
	@override String get retestSpeed => '再速度テスト';
	@override String get waitingForSpeedTest => '速度テスト待ち';
	@override String get testingSpeed => '速度テスト中...';
	@override String get testFailed => 'テスト失敗';
	@override String get loadingServerList => 'サーバーリストを読み込み中...';
	@override String get noAvailableServers => '利用可能なサーバーがありません';
	@override String get refreshServerList => 'サーバーリストを更新';
	@override String get cannotGetSource => '現在の再生ソースを取得できません';
	@override String switchedToServer({required Object serverName}) => 'サーバーを切り替えました: ${serverName}';
	@override String serverCount({required Object count}) => '合計 ${count} 台のサーバー';
	@override String statusCode({required Object code}) => 'ステータスコード: ${code}';
	@override String get connectionFailed => '接続失敗';
	@override String get connectionTimeout => '接続タイムアウト';
	@override String get networkError => 'ネットワークエラー';
	@override String get sslError => 'SSL証明書エラー';
	@override String get testCompleted => 'テスト完了';
	@override String get local => 'ローカル';
	@override String get unknown => '不明';
	@override String get localVideoPathEmpty => 'ローカルビデオパスが空です';
	@override String localVideoFileNotExists({required Object path}) => 'ローカルビデオファイルが存在しません: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'ローカルビデオを再生できません: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'NAS の動画を再生できません：${error}';
	@override String get dropVideoFileHere => 'ここにビデオファイルをドロップして再生';
	@override String get supportedFormats => '対応形式: MP4, MKV, AVI, MOV, WEBM など';
	@override String get noSupportedVideoFile => 'サポートされているビデオファイルが見つかりません';
	@override String get imageLoadFailed => '画像読み込み失敗';
	@override String get unsupportedImageFormat => 'サポートされていない画像形式';
	@override String get tryOtherViewer => '他のビューアーをお試しください';
	@override String get retryingOpenVideoLink => '動画リンクのオープンに失敗しました。再試行中';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'デコーダーを読み込めませんでした: ${event}。プレーヤー設定でソフトウェアデコードに切り替え、ページに再入場してお試しください';
	@override String videoLoadErrorWithDetail({required Object event}) => '動画読み込みエラー: ${event}';
	@override String get playbackFailureDiagnosticsHint => '再生失敗が続いています。設定 > 診断とフィードバック からログをエクスポートして報告してください';
	@override String get openSettingsAction => '表示';
	@override late final _TranslationsMediaPlayerNoticeJa notice = _TranslationsMediaPlayerNoticeJa._(_root);
}

// Path: diagnostics
class _TranslationsDiagnosticsJa extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => '診断情報';
	@override String get appVersionLabel => 'アプリバージョン';
	@override String memoryUsage({required Object memMB}) => 'メモリ使用量: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'デバイス情報を取得できません';
	@override String get secureStorageLabel => 'セキュアストレージ';
	@override String get secureStorageHealthy => '利用可能';
	@override String get secureStorageRecovered => 'リセットで自己修復済み（既存データは消去）';
	@override String get secureStorageUnavailable => '利用不可（ログイン状態は代替暗号化で保存）';
	@override String get secureStoragePlatformOptOut => 'プラットフォーム方針によりローカル暗号化（macOS ではシステムキーチェーンを使用しません）';
	@override String get secureStorageDualWrite => '（二重保存の保護が有効）';
	@override String get schemaHealthLabel => 'データベース構造';
	@override String get schemaHealthOk => '正常';
	@override String get schemaHealthRepairedNow => '今回の起動でセーフティネットにより修復（マイグレーション未適用）';
	@override String get schemaHealthRepairedBefore => '過去にセーフティネットにより修復';
	@override String get logPolicySectionTitle => 'ログポリシー';
	@override String get configServiceUnavailable => '設定サービスが未初期化のため、ログポリシーを調整できません';
	@override String get enableLoggingTitle => 'ログ記録を有効化';
	@override String get enableLoggingSubtitle => 'オフにすると新しいログ記録を停止します';
	@override String get enableLogPersistenceTitle => 'ログ永続化を有効化';
	@override String get enableLogPersistenceSubtitle => 'オフにするとメモリログのみ保持し、ディスクへ書き込みません';
	@override String get minLogLevelTitle => '最小記録レベル';
	@override String get minLogLevelSubtitle => 'このレベル未満のログは除外されます';
	@override String get maxFileSizeTitle => '単一ファイルの上限サイズ';
	@override String get maxFileSizeSubtitle => 'しきい値到達でローテーションします';
	@override String get rotatedFileCountTitle => 'メインログのローテーション数';
	@override String get rotatedFileCountSubtitle => '現在ファイルを除く保持数';
	@override String get hangFileSizeTitle => 'ハングログの上限サイズ';
	@override String get hangFileSizeSubtitle => 'hang_events ファイルの増加を制御';
	@override String get hangRotatedFileCountTitle => 'ハングログのローテーション数';
	@override String get hangRotatedFileCountSubtitle => 'hang_events の履歴保持数を制御';
	@override String get healthSectionTitle => 'ログヘルス';
	@override String get refreshMetrics => '指標を更新';
	@override String get toolsSectionTitle => 'ツール';
	@override String get privacyNotice => 'ログにはアカウント情報やリクエストパラメータなどの機密情報が含まれる可能性があります。Issue に完全なログを公開添付せず、確認後にメールで送信してください。';
	@override String get exportLogsTitle => 'ログをエクスポート';
	@override String get exportLogsSubtitle => '送信前にプライバシー情報を確認してください';
	@override String get viewLogsTitle => 'ログを表示';
	@override String get viewLogsSubtitle => 'アプリの実行ログをリアルタイム表示';
	@override String get copySupportEmailTitle => 'サポートメールをコピー';
	@override String get reportIssueTitle => '問題を報告';
	@override String get reportIssueSubtitle => 'GitHub に再現手順を記載（完全なログは添付しないでください）';
	@override String get healthSummaryUnavailable => 'ログヘルスデータがありません';
	@override String get healthMetricsUnavailable => 'ヘルス指標がまだ収集されていません';
	@override String get healthNoRiskIndicators => '現時点でリスク指標はありません';
	@override late final _TranslationsDiagnosticsHealthAlertJa healthAlert = _TranslationsDiagnosticsHealthAlertJa._(_root);
	@override late final _TranslationsDiagnosticsToastJa toast = _TranslationsDiagnosticsToastJa._(_root);
	@override String get shareSubject => 'LoveIwara 診断ログ（機密情報を含む可能性があるため共有注意）';
}

// Path: logViewer
class _TranslationsLogViewerJa extends TranslationsLogViewerEn {
	_TranslationsLogViewerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ログビューア';
	@override String get searchHint => 'ログを検索...';
	@override String get emptyState => 'ログはありません';
	@override String get copiedToClipboard => 'クリップボードにコピーしました';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogJa extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'アプリが異常終了しました';
	@override String get description => '前回セッションで異常終了を検出しました。診断ログをエクスポートして開発者にメール送信すると、問題修正に役立ちます。';
	@override String previousVersion({required Object version}) => '前回バージョン: ${version}';
	@override String previousStart({required Object time}) => '前回起動: ${time}';
	@override String lastException({required Object message}) => '最後の例外: ${message}';
	@override String get lastHangRecovered => '前回は画面フリーズを検出しましたが自動回復しました';
	@override String lastHangStalled({required Object stalledMs}) => '前回は画面が約 ${stalledMs}ms フリーズした可能性があります';
	@override String get exportGuide => '設定 > 診断とフィードバック > ログをエクスポート へ進んでください。';
	@override String get privacyHint => 'ログには機密情報が含まれる可能性があります。確認後、次の宛先へメール送信してください：';
	@override String get issueWarning => '完全なログを Issue に公開添付しないでください';
	@override String get acknowledge => '了解';
	@override String get supportEmailCopied => 'メールアドレスをコピーしました';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogJa extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'リンクを入力';
	@override String supportedLinksHint({required Object webName}) => '複数の${webName}リンクをインテリジェントに識別し、アプリ内の対応するページにすばやくジャンプすることをサポートします（リンクと他のテキストはスペースで区切ります）';
	@override String inputHint({required Object webName}) => '${webName}リンクを入力してください';
	@override String get validatorEmptyLink => 'リンクを入力してください';
	@override String validatorNoIwaraLink({required Object webName}) => '有効な${webName}リンクが検出されませんでした';
	@override String get multipleLinksDetected => '複数のリンクが検出されました。1つ選択してください：';
	@override String notIwaraLink({required Object webName}) => '有効な${webName}リンクではありません';
	@override String linkParseError({required Object error}) => 'リンク解析エラー: ${error}';
	@override String get unsupportedLinkDialogTitle => 'サポートされていないリンク';
	@override String get unsupportedLinkDialogContent => 'このリンクタイプは現在アプリ内で直接開くことができず、外部ブラウザを使用してアクセスする必要があります。\n\nブラウザでこのリンクを開きますか？';
	@override String get openInBrowser => 'ブラウザで開く';
	@override String get confirmOpenBrowserDialogTitle => 'ブラウザを開くことを確認';
	@override String get confirmOpenBrowserDialogContent => '次のリンクを外部ブラウザで開こうとしています：';
	@override String get confirmContinueBrowserOpen => '続行してもよろしいですか？';
	@override String get browserOpenFailed => 'リンクを開けませんでした';
	@override String get unsupportedLink => 'サポートされていないリンク';
	@override String get cancel => 'キャンセル';
	@override String get confirm => 'ブラウザで開く';
}

// Path: log
class _TranslationsLogJa extends TranslationsLogEn {
	_TranslationsLogJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'ログ管理';
	@override String get enableLogPersistence => 'ログ保存を有効にする';
	@override String get enableLogPersistenceDesc => 'ログをデータベースに保存して分析に使用';
	@override String get logDatabaseSizeLimit => 'ログデータベースサイズ上限';
	@override String logDatabaseSizeLimitDesc({required Object size}) => '現在: ${size}';
	@override String get exportCurrentLogs => '現在のログをエクスポート';
	@override String get exportCurrentLogsDesc => '現在のアプリケーションログを開発者が診断に使用できるようにエクスポート';
	@override String get exportHistoryLogs => '履歴ログをエクスポート';
	@override String get exportHistoryLogsDesc => '指定された日付範囲内のログをエクスポート';
	@override String get exportMergedLogs => 'マージログをエクスポート';
	@override String get exportMergedLogsDesc => '指定された日付範囲内のマージログをエクスポート';
	@override String get showLogStats => 'ログ統計情報を表示';
	@override String get logExportSuccess => 'ログエクスポート成功';
	@override String logExportFailed({required Object error}) => 'ログエクスポート失敗: ${error}';
	@override String get showLogStatsDesc => '様々なタイプのログの統計情報を表示';
	@override String logExtractFailed({required Object error}) => 'ログ統計情報の取得に失敗しました: ${error}';
	@override String get clearAllLogs => 'すべてのログをクリア';
	@override String get clearAllLogsDesc => 'すべてのログデータをクリア';
	@override String get confirmClearAllLogs => '確認クリア';
	@override String get confirmClearAllLogsDesc => 'すべてのログデータをクリアしますか？この操作は元に戻すことができません';
	@override String get clearAllLogsSuccess => 'ログクリア成功';
	@override String clearAllLogsFailed({required Object error}) => 'ログクリア失敗: ${error}';
	@override String get unableToGetLogSizeInfo => 'ログサイズ情報を取得できません';
	@override String get currentLogSize => '現在のログサイズ:';
	@override String get logCount => 'ログ数:';
	@override String get logCountUnit => 'ログ';
	@override String get logSizeLimit => 'ログサイズ上限:';
	@override String get usageRate => '使用率:';
	@override String get exceedLimit => '超過';
	@override String get remaining => '残り';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => '現在のログサイズが超過しています。古いログをクリアするか、ログサイズ上限を増加してください';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => '現在のログサイズがほぼ超過しています。古いログをクリアしてください';
	@override String get cleaningOldLogs => '古いログを自動的にクリアしています...';
	@override String get logCleaningCompleted => 'ログクリアが完了しました';
	@override String get logCleaningProcessMayNotBeCompleted => 'ログクリア過程が完了しない可能性があります';
	@override String get cleanExceededLogs => '超過ログをクリア';
	@override String get noLogsToExport => 'エクスポート可能なログデータがありません';
	@override String get exportingLogs => 'ログをエクスポートしています...';
	@override String get noHistoryLogsToExport => '履歴ログをエクスポートするのに十分なデータがありません。アプリを使用してからしばらくしてから再試行してください';
	@override String get selectLogDate => 'ログ日付を選択';
	@override String get today => '今日';
	@override String get selectMergeRange => 'マージ範囲を選択';
	@override String get selectMergeRangeHint => 'マージするログの日付範囲を選択してください';
	@override String selectMergeRangeDays({required Object days}) => '最近 ${days} 日';
	@override String get logStats => 'ログ統計情報';
	@override String todayLogs({required Object count}) => '今日のログ: ${count} 件';
	@override String recent7DaysLogs({required Object count}) => '最近7日のログ: ${count} 件';
	@override String totalLogs({required Object count}) => '合計ログ: ${count} 件';
	@override String get setLogDatabaseSizeLimit => 'ログデータベースサイズ上限を設定';
	@override String currentLogSizeWithSize({required Object size}) => '現在のログサイズ: ${size}';
	@override String get warning => '警告';
	@override String newSizeLimit({required Object size}) => '新しいサイズ上限: ${size}';
	@override String get confirmToContinue => '続行してもよろしいですか？';
	@override String logSizeLimitSetSuccess({required Object size}) => 'ログサイズ上限を ${size} に設定しました';
}

// Path: emoji
class _TranslationsEmojiJa extends TranslationsEmojiEn {
	_TranslationsEmojiJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get recentlyUsed => '最近使った';
	@override String insertedCount({required Object count}) => '${count} 個挿入しました';
	@override String get name => '絵文字';
	@override String get size => 'サイズ';
	@override String get small => '小';
	@override String get medium => '中';
	@override String get large => '大';
	@override String get extraLarge => '超大';
	@override String get copyEmojiLinkSuccess => '絵文字リンクをコピーしました';
	@override String get preview => '絵文字プレビュー';
	@override String get library => '絵文字ライブラリ';
	@override String get noEmojis => '絵文字がありません';
	@override String get clickToAddEmojis => '右上のボタンをクリックして絵文字を追加';
	@override String get addEmojis => '絵文字を追加';
	@override String get imagePreview => '画像プレビュー';
	@override String get imageLoadFailed => '画像の読み込みに失敗しました';
	@override String get loading => '読み込み中...';
	@override String get delete => '削除';
	@override String get close => '閉じる';
	@override String get deleteImage => '画像を削除';
	@override String get confirmDeleteImage => 'この画像を削除してもよろしいですか？';
	@override String get cancel => 'キャンセル';
	@override String get batchDelete => '一括削除';
	@override String confirmBatchDelete({required Object count}) => '選択された${count}枚の画像を削除してもよろしいですか？この操作は元に戻せません。';
	@override String get deleteSuccess => '削除しました';
	@override String get addImage => '画像を追加';
	@override String get addImageByUrl => 'URLで追加';
	@override String get addImageUrl => '画像URLを追加';
	@override String get imageUrl => '画像URL';
	@override String get enterImageUrl => '画像URLを入力してください';
	@override String get add => '追加';
	@override String get batchImport => '一括インポート';
	@override String get enterJsonUrlArray => 'JSON形式のURL配列を入力してください:';
	@override String get formatExample => '形式例:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'JSON形式のURL配列を貼り付けてください';
	@override String get import => 'インポート';
	@override String importSuccess({required Object count}) => '${count}枚の画像をインポートしました';
	@override String get jsonFormatError => 'JSON形式エラー、入力を確認してください';
	@override String get createGroup => '絵文字グループを作成';
	@override String get groupName => 'グループ名';
	@override String get enterGroupName => 'グループ名を入力してください';
	@override String get create => '作成';
	@override String get editGroupName => 'グループ名を編集';
	@override String get save => '保存';
	@override String get deleteGroup => 'グループを削除';
	@override String get confirmDeleteGroup => 'この絵文字グループを削除してもよろしいですか？グループ内のすべての画像も削除されます。';
	@override String imageCount({required Object count}) => '${count}枚の画像';
	@override String get selectEmoji => '絵文字を選択';
	@override String get noEmojisInGroup => 'このグループには絵文字がありません';
	@override String get goToSettingsToAddEmojis => '設定で絵文字を追加してください';
	@override String get emojiManagement => '絵文字管理';
	@override String get manageEmojiGroupsAndImages => '絵文字グループと画像を管理';
	@override String get uploadLocalImages => 'ローカル画像をアップロード';
	@override String get uploadingImages => '画像をアップロード中';
	@override String uploadingImagesProgress({required Object count}) => '${count} 枚の画像をアップロード中、お待ちください...';
	@override String get doNotCloseDialog => 'このダイアログを閉じないでください';
	@override String uploadSuccess({required Object count}) => '${count} 枚の画像をアップロードしました';
	@override String uploadFailed({required Object count}) => '${count} 枚失敗';
	@override String get uploadFailedMessage => '画像のアップロードに失敗しました。ネットワーク接続またはファイル形式を確認してください';
	@override String uploadErrorMessage({required Object error}) => 'アップロード中にエラーが発生しました: ${error}';
}

// Path: displaySettings
class _TranslationsDisplaySettingsJa extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '表示設定';
	@override String get layoutSettings => 'レイアウト設定';
	@override String get layoutSettingsDesc => 'カラム数とブレークポイント設定をカスタマイズ';
	@override String get gridLayout => 'グリッドレイアウト';
	@override String get navigationOrderSettings => 'ナビゲーション順序設定';
	@override String get customNavigationOrder => 'カスタムナビゲーション順序';
	@override String get customNavigationOrderDesc => 'ボトムナビゲーションバーとサイドバーのページ表示順序を調整';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsJa extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'レイアウト設定';
	@override String get descriptionTitle => 'レイアウト設定の説明';
	@override String get descriptionContent => 'ここでの設定は、動画とギャラリーリストページで表示されるカラム数を決定します。自動モードを選択して画面幅に基づいて自動調整するか、手動モードを選択してカラム数を固定できます。';
	@override String get layoutMode => 'レイアウトモード';
	@override String get reset => 'リセット';
	@override String get autoMode => '自動モード';
	@override String get autoModeDesc => '画面幅に基づいて自動調整';
	@override String get manualMode => '手動モード';
	@override String get manualModeDesc => '固定カラム数を使用';
	@override String get manualSettings => '手動設定';
	@override String get fixedColumns => '固定カラム数';
	@override String get columns => 'カラム';
	@override String get breakpointConfig => 'ブレークポイント設定';
	@override String get add => '追加';
	@override String get defaultColumns => 'デフォルトカラム数';
	@override String get defaultColumnsDesc => '大画面のデフォルト表示';
	@override String get previewEffect => 'プレビュー効果';
	@override String get screenWidth => '画面幅';
	@override String get addBreakpoint => 'ブレークポイントを追加';
	@override String get editBreakpoint => 'ブレークポイントを編集';
	@override String get deleteBreakpoint => 'ブレークポイントを削除';
	@override String get screenWidthLabel => '画面幅';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'カラム数';
	@override String get columnsHint => '3';
	@override String get enterWidth => '幅を入力してください';
	@override String get enterValidWidth => '有効な幅を入力してください';
	@override String get widthCannotExceed9999 => '幅は9999を超えることはできません';
	@override String get breakpointAlreadyExists => 'ブレークポイントが既に存在します';
	@override String get enterColumns => 'カラム数を入力してください';
	@override String get enterValidColumns => '有効なカラム数を入力してください';
	@override String get columnsCannotExceed12 => 'カラム数は12を超えることはできません';
	@override String get breakpointConflict => 'ブレークポイントが既に存在します';
	@override String get confirmResetLayoutSettings => 'レイアウト設定をリセット';
	@override String get confirmResetLayoutSettingsDesc => 'すべてのレイアウト設定をデフォルト値にリセットしてもよろしいですか？\n\n以下に復元されます：\n• 自動モード\n• デフォルトブレークポイント設定';
	@override String get resetToDefaults => 'デフォルトにリセット';
	@override String get confirmDeleteBreakpoint => 'ブレークポイントを削除';
	@override String confirmDeleteBreakpointDesc({required Object width}) => '${width}px のブレークポイントを削除してもよろしいですか？';
	@override String get noCustomBreakpoints => 'カスタムブレークポイントがありません、デフォルトカラム数を使用';
	@override String get breakpointRange => 'ブレークポイント範囲';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => '編集';
	@override String get delete => '削除';
	@override String get cancel => 'キャンセル';
	@override String get save => '保存';
}

// Path: bottomNav
class _TranslationsBottomNavJa extends TranslationsBottomNavEn {
	_TranslationsBottomNavJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get video => '動画';
	@override String get gallery => '画像';
	@override String get subscription => '購読';
	@override String get community => '広場';
	@override String get localMedia => '端末';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsJa extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ナビゲーション順序設定';
	@override String get customNavigationOrder => 'カスタムナビゲーション順序';
	@override String get customNavigationOrderDesc => 'ドラッグしてボトムナビゲーションバーとサイドバーの各ページの表示順序を調整';
	@override String get restartRequired => 'アプリの再起動が必要です';
	@override String get navigationItemSorting => 'ナビゲーション項目の並べ替え';
	@override String get done => '完了';
	@override String get edit => '編集';
	@override String get reset => 'リセット';
	@override String get previewEffect => 'プレビュー効果';
	@override String get bottomNavigationPreview => 'ボトムナビゲーションバーのプレビュー：';
	@override String get sidebarPreview => 'サイドバーのプレビュー：';
	@override String get confirmResetNavigationOrder => 'ナビゲーション順序のリセットを確認';
	@override String get confirmResetNavigationOrderDesc => 'ナビゲーション順序をデフォルト設定にリセットしてもよろしいですか？';
	@override String get cancel => 'キャンセル';
	@override String get show => '表示';
	@override String get hide => '非表示';
	@override String get hidden => '非表示中';
	@override String get hideHint => '目のアイコンをタップしてコミュニティと端末内のファイルの表示・非表示を切り替えます';
	@override String get videoDescription => '人気の動画コンテンツを閲覧';
	@override String get galleryDescription => '画像とギャラリーを閲覧';
	@override String get subscriptionDescription => 'フォローしているユーザーの最新コンテンツを表示';
	@override String get forumDescription => 'コミュニティディスカッションに参加';
	@override String get newsDescription => '公式ニュース、記事、放送を閲覧';
	@override String get communityDescription => 'フォーラムの議論と公式ニュース・記事・ブロードキャスト';
	@override String get localMediaDescription => 'この端末に保存された動画と画像を閲覧';
}

// Path: news
class _TranslationsNewsJa extends TranslationsNewsEn {
	_TranslationsNewsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ニュース';
	@override String get newsUpdates => '更新情報';
	@override String get articles => '記事';
	@override String get broadcast => '放送';
	@override String get openInBrowser => 'ブラウザで開く';
}

// Path: searchFilter
class _TranslationsSearchFilterJa extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'フィールドを選択';
	@override String get add => '追加';
	@override String get clear => 'クリア';
	@override String get clearAll => 'すべてクリア';
	@override String get generatedQuery => '生成されたクエリ';
	@override String get copyToClipboard => 'クリップボードにコピー';
	@override String get copied => 'コピーしました';
	@override String filterCount({required Object count}) => '${count} 個のフィルター';
	@override String get filterSettings => 'フィルター設定';
	@override String get field => 'フィールド';
	@override String get operator => '演算子';
	@override String get language => '言語';
	@override String get value => '値';
	@override String get dateRange => '日付範囲';
	@override String get numberRange => '数値範囲';
	@override String get from => 'から';
	@override String get to => 'まで';
	@override String get date => '日付';
	@override String get number => '数値';
	@override String get boolean => 'ブール値';
	@override String get tags => 'タグ';
	@override String get select => '選択';
	@override String get clickToSelectDate => '日付を選択するにはクリック';
	@override String get pleaseEnterValidNumber => '有効な数値を入力してください';
	@override String get pleaseEnterValidDate => '有効な日付形式を入力してください (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => '開始値は終了値より小さくする必要があります';
	@override String get startDateMustBeBeforeEndDate => '開始日は終了日より前である必要があります';
	@override String get pleaseFillStartValue => '開始値を入力してください';
	@override String get pleaseFillEndValue => '終了値を入力してください';
	@override String get rangeValueFormatError => '範囲値の形式エラー';
	@override String get contains => '含む';
	@override String get equals => '等しい';
	@override String get notEquals => '等しくない';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => '範囲';
	@override String get kIn => 'いずれかを含む';
	@override String get notIn => 'いずれも含まない';
	@override String get username => 'ユーザー名';
	@override String get nickname => 'ニックネーム';
	@override String get registrationDate => '登録日';
	@override String get description => '説明';
	@override String get title => 'タイトル';
	@override String get body => '本文';
	@override String get author => '作者';
	@override String get publishDate => '公開日';
	@override String get private => 'プライベート';
	@override String get duration => '時間（秒）';
	@override String get likes => 'いいね数';
	@override String get views => '視聴回数';
	@override String get comments => 'コメント数';
	@override String get rating => '評価';
	@override String get imageCount => '画像数';
	@override String get videoCount => '動画数';
	@override String get createDate => '作成日';
	@override String get content => 'コンテンツ';
	@override String get all => 'すべて';
	@override String get adult => '成人向け';
	@override String get general => '一般';
	@override String get yes => 'はい';
	@override String get no => 'いいえ';
	@override String get users => 'ユーザー';
	@override String get videos => '動画';
	@override String get images => '画像';
	@override String get posts => '投稿';
	@override String get forumThreads => 'フォーラムスレッド';
	@override String get forumPosts => 'フォーラム投稿';
	@override String get playlists => 'プレイリスト';
	@override late final _TranslationsSearchFilterSortTypesJa sortTypes = _TranslationsSearchFilterSortTypesJa._(_root);
	@override String get drawerSubtitle => '変更は即時反映されます';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupJa extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeJa welcome = _TranslationsFirstTimeSetupWelcomeJa._(_root);
	@override late final _TranslationsFirstTimeSetupBasicJa basic = _TranslationsFirstTimeSetupBasicJa._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkJa network = _TranslationsFirstTimeSetupNetworkJa._(_root);
	@override late final _TranslationsFirstTimeSetupThemeJa theme = _TranslationsFirstTimeSetupThemeJa._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerJa player = _TranslationsFirstTimeSetupPlayerJa._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialJa spatial = _TranslationsFirstTimeSetupSpatialJa._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionJa completion = _TranslationsFirstTimeSetupCompletionJa._(_root);
	@override late final _TranslationsFirstTimeSetupCommonJa common = _TranslationsFirstTimeSetupCommonJa._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperJa extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'システムプロキシを検出';
	@override String get copied => 'コピーしました';
	@override String get copy => 'コピー';
}

// Path: tagSelector
class _TranslationsTagSelectorJa extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'タグを選択';
	@override String get clickToSelectTags => 'タグを選択するにはクリック';
	@override String get addTag => 'タグを追加';
	@override String get removeTag => 'タグを削除';
	@override String get deleteTag => 'タグを削除';
	@override String get usageInstructions => 'まずタグを追加してから、既存のタグからクリックして選択してください';
	@override String get usageInstructionsTooltip => '使用方法';
	@override String get addTagTooltip => 'タグを追加';
	@override String get removeTagTooltip => 'タグを削除';
	@override String get cancelSelection => '選択をキャンセル';
	@override String get selectAll => 'すべて選択';
	@override String get cancelSelectAll => 'すべての選択をキャンセル';
	@override String get delete => '削除';
}

// Path: anime4k
class _TranslationsAnime4kJa extends TranslationsAnime4kEn {
	_TranslationsAnime4kJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Anime4K リアルタイムビデオアップスケーリングとノイズ除去、アニメーション動画の品質向上';
	@override String get settings => 'Anime4K 設定';
	@override String get preset => 'Anime4K プリセット';
	@override String get disable => 'Anime4K を無効にする';
	@override String get disableDescription => 'ビデオ強化効果を無効にする';
	@override String get highQualityPresets => '高品質プリセット';
	@override String get fastPresets => '高速プリセット';
	@override String get litePresets => '軽量プリセット';
	@override String get moreLitePresets => 'より軽量なプリセット';
	@override String get customPresets => 'カスタムプリセット';
	@override late final _TranslationsAnime4kPresetGroupsJa presetGroups = _TranslationsAnime4kPresetGroupsJa._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsJa presetDescriptions = _TranslationsAnime4kPresetDescriptionsJa._(_root);
	@override late final _TranslationsAnime4kPresetNamesJa presetNames = _TranslationsAnime4kPresetNamesJa._(_root);
	@override String get performanceTip => '💡 ヒント：デバイスのパフォーマンスに基づいて適切なプリセットを選択してください。ローエンドデバイスでは軽量プリセットをお勧めします。';
	@override String get compatibilityTip => '⚠️ 一部のモバイル GPU（Kirin 980 / Mali-G76 など）はカスタムシェーダーを一切描画できません。音声だけで画面が真っ暗になる場合は、ここで Anime4K をオフにしてください。';
	@override String get autoDisabledOnRenderFailure => 'お使いのデバイスの GPU が Anime4K シェーダーを描画できなかったため、自動的に無効化しました。';
}

// Path: siteMode
class _TranslationsSiteModeJa extends TranslationsSiteModeEn {
	_TranslationsSiteModeJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'サイトモード';
	@override String get mainSite => 'メイン';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => '現在 ${currentSite} ・ タップして ${nextSite} に切り替え';
	@override String get dialogTitle => 'サイトモードを切り替え';
	@override String get dialogDescription => '切り替えると、アプリ全体が再読み込みされ、これまでに読み込んだリストやページ状態がリセットされます。';
	@override String get chooseLinkTargetTitle => 'リンク先サイトを選択';
	@override String get chooseLinkTargetDescription => 'このリンクにはドメインが含まれていません。メインサイトか AI サイトのどちらで開くか選択してください。';
	@override String get chooseLinkTargetHint => '開いた後、このページと後続の詳細リクエストは選択したサイトを使い続けます。';
	@override String get alreadyUsing => 'すでにこのサイトモードを使用しています。';
	@override String openInSite({required Object site}) => '${site} で開く';
	@override String confirmUsing({required Object site}) => '確認すると、以降のリクエストは ${site} モードを使用します。';
	@override String switched({required Object site}) => '${site} に切り替えました。アプリは再読み込みされました。';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigJa extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '保存した絞り込み';
	@override String get empty => '保存した絞り込み設定はまだありません';
	@override String get saveTooltip => '現在の絞り込みを保存';
	@override String get namePromptTitle => '絞り込みを保存';
	@override String get nameLabel => '名前';
	@override String get nameHint => '名前を入力';
	@override String get saveSuccess => '絞り込みを保存しました';
	@override String get deleteSuccess => '絞り込みを削除しました';
	@override String get addCurrent => '現在の絞り込みを保存';
	@override String get reorderHint => '長押しでドラッグして並べ替え';
	@override String get rename => '名前を変更';
	@override String get unnamed => '無名';
	@override String get noConditions => 'すべてのコンテンツ（絞り込みなし）';
	@override String tagsCount({required Object count}) => '${count} 個のタグ';
}

// Path: savedSearch
class _TranslationsSavedSearchJa extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '保存した検索';
	@override String get empty => '保存した検索はまだありません';
	@override String get saveTooltip => '現在の検索を保存';
	@override String get namePromptTitle => '検索を保存';
	@override String get nameLabel => '名前';
	@override String get nameHint => '名前を入力';
	@override String get saveSuccess => '検索を保存しました';
	@override String get deleteSuccess => '検索を削除しました';
	@override String get addCurrent => '現在の検索を保存';
	@override String get reorderHint => '長押しでドラッグして並べ替え';
	@override String get rename => '名前を変更';
	@override String get noKeyword => '（キーワードなし）';
	@override String filtersCount({required Object count}) => '${count} 個の絞り込み';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderJa extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'デフォルトのタグブラックリストを検出しました';
	@override String get content => 'お使いのアカウントは、サイトが新規ユーザーごとに自動設定するデフォルトのタグブラックリストをそのまま使用しています。管理ページで確認・変更しますか？';
	@override String get goManage => '管理する';
	@override String get dismiss => '後で';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistJa extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '色覚アシスト';
	@override String get description => '色覚障がいのあるユーザー向けに動画の色を補正します。Anime4K と併用できます';
	@override String get galleryDescription => '色覚障がいのあるユーザー向けにギャラリー画像の色を補正します（プレイヤーの設定とは独立）';
	@override String get galleryDescriptionSpatial => '色覚障がいのあるユーザー向けにギャラリー画像の色を補正します。このパネル内の 2D ビューアーにのみ適用され、空間スクリーン上の画像はネイティブ描画のためこのフィルターを通りません';
	@override String get disable => 'オフ';
	@override String get disableDescription => '色補正を行いません';
	@override String get protanopia => '赤色覚アシスト（1型）';
	@override String get protanopiaDescription => '1型色覚（赤の識別が困難）向け';
	@override String get deuteranopia => '緑色覚アシスト（2型）';
	@override String get deuteranopiaDescription => '2型色覚（緑の識別が困難）向け';
	@override String get tritanopia => '青色覚アシスト（3型）';
	@override String get tritanopiaDescription => '3型色覚（青と黄の識別が困難）向け';
	@override String appliedToast({required Object filterName}) => '${filterName}を適用しました（即時反映）';
	@override String get disabledToast => '色覚アシストをオフにしました';
}

// Path: externalPlayer
class _TranslationsExternalPlayerJa extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '他のアプリで開く';
	@override String get description => '再生中の動画を端末内の別のプレイヤーに渡します（VR ヘッドセットの Skybox や Pigasus、スマホの MX Player や VLC など）';
	@override String get openWithOtherApp => '他のアプリを選んで開く';
	@override String get openWithOtherAppDescription => 'システムの選択画面からプレイヤーを選びます';
	@override String get openWithSystemPlayer => '既定のプレイヤーで開く';
	@override String get openWithSystemPlayerDescription => 'システムに関連付けられた既定の動画アプリに渡します';
	@override String get copyLink => '動画リンクをコピー';
	@override String get copyLinkDescription => 'URL の貼り付けにしか対応しないプレイヤー（Skybox、DeoVR など）向け';
	@override String get linkCopied => '動画リンクをコピーしました';
	@override String get sourceLocal => 'ローカルファイル';
	@override String get sourceOnline => '直リンク';
	@override String sourceOnlineWithQuality({required Object quality}) => '直リンク · ${quality}';
	@override String get onlineLinkExpiryHint => '直リンクには有効期限があり、外部プレイヤーで再生途中に切れることがあります。先にダウンロードしてから渡すのが確実です';
	@override String get vrPlayerHint => 'VR プレイヤーが選択画面に出てこない場合は「動画リンクをコピー」してプレイヤー内で貼り付けてください';
	@override String get noHandler => '動画を開けるアプリが見つかりません';
	@override String handoffFailed({required Object message}) => '受け渡しに失敗しました: ${message}';
	@override String get handoffFailedUnknown => '受け渡しに失敗しました';
	@override String get sourceUnavailable => '現在の動画のアドレスを取得できません。しばらくしてからお試しください';
	@override String get localFileMissing => 'ローカルファイルが存在しません。削除された可能性があります';
	@override String get handedOff => '外部プレイヤーに渡しました';
	@override String get desktopSectionTitle => '外部プレイヤー';
	@override String get managePlayers => '外部プレイヤーの管理';
	@override String get managePlayersDescWindows => 'HereSphere、DeoVR、Whirligig といった PCVR プレイヤーはシステムの既定アプリではありません。その .exe を指定すると、再生画面から現在の動画を直接渡せるようになります';
	@override String get managePlayersDescMac => 'IINA、VLC、mpv などのアプリケーションを指定すると、再生画面から現在の動画を直接渡せるようになります';
	@override String get managePlayersDescLinux => 'mpv、VLC、Celluloid などの実行ファイルを指定すると、再生画面から現在の動画を直接渡せるようになります';
	@override String get pickExecutableHintWindows => 'プレイヤーのインストール先にある .exe 本体を選んでください（例：HereSphere.exe、vlc.exe）。デスクトップのショートカット（.lnk）は使えません';
	@override String get pickExecutableHintMac => '「アプリケーション」からプレイヤーの .app を選んでください（例：IINA.app）。中の実行ファイルは自動で特定します';
	@override String get pickExecutableHintLinux => 'プレイヤーの実行ファイルを選んでください（例：/usr/bin/mpv）。which mpv で場所が分かります';
	@override String emptyStateGuide({required Object examples}) => '設定すると、再生画面の「他のアプリで開く」に項目として直接並びます。よく使われるもの：${examples}';
	@override String get detectNothingFoundGuide => 'インストール済みのプレイヤーは見つかりませんでした。独自のフォルダーやポータブル版は検出できないので、「プレイヤーを追加」から手動で指定してください';
	@override String get detectNothingNew => '新しいプレイヤーはありません。インストール済みのものはすべて一覧に入っています';
	@override String get detectFailed => '検出に失敗しました。「プレイヤーを追加」から手動で指定できます';
	@override String get advancedOptions => '詳細設定';
	@override String get playerNameHint => '空欄ならファイル名を使います';
	@override String get executablePathRequired => '先にプレイヤーの実行ファイルを選んでください';
	@override String playerCount({required Object count}) => '${count} 件設定済み';
	@override String get noPlayerConfigured => '外部プレイヤーはまだ設定されていません';
	@override String get autoDetect => '自動検出';
	@override String get detecting => '検出中…';
	@override String detectFound({required Object count}) => '${count} 件のプレイヤーを検出しました';
	@override String get detectNothingFound => '新しいプレイヤーは見つかりませんでした。手動で追加できます';
	@override String get autoDetectedTag => '自動検出';
	@override String get addPlayer => 'プレイヤーを追加';
	@override String get editPlayer => 'プレイヤーを編集';
	@override String get playerName => '名前';
	@override String get executablePath => '実行ファイル';
	@override String get browse => '参照';
	@override String get argumentTemplate => '起動オプション';
	@override String get argumentTemplateHint => '{input} が動画のパスまたは URL に置き換わります。空欄なら唯一の引数として渡します';
	@override String get nameAndPathRequired => '名前と実行ファイルは必須です';
	@override String get testLaunch => 'テスト起動';
	@override String get testLaunched => 'プレイヤーを起動しました';
	@override String get testFailed => '起動に失敗しました。実行ファイルのパスを確認してください';
	@override String get executableMissing => '実行ファイルが見つかりません';
	@override String openWithNamed({required Object name}) => '${name} で開く';
	@override String get managePlayersEntry => '外部プレイヤーを管理…';
}

// Path: watchLater
class _TranslationsWatchLaterJa extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'あとで見る';
	@override String get addToWatchLater => 'あとで見る';
	@override String get removeFromWatchLater => 'あとで見るから削除';
	@override String get addedToWatchLater => 'あとで見るに追加しました';
	@override String get alreadyInWatchLater => 'すでにあとで見るに入っています';
	@override String get removedFromWatchLater => 'あとで見るから削除しました';
	@override String removedCount({required Object count}) => '${count} 件を削除しました';
	@override String get viewWatchLaterList => 'リストを見る';
	@override String get addFailed => 'あとで見るへの追加に失敗しました';
	@override String get invalidItem => '利用できません';
	@override String get clearWatched => '視聴済みを削除';
	@override String watchedCleared({required Object count}) => '視聴済み ${count} 件を削除しました';
	@override String get noWatchedToClear => '視聴済みの項目はありません';
	@override String get emptyVideo => 'あとで見るに追加された動画はありません';
	@override String get emptyGallery => 'あとで見るに追加されたギャラリーはありません';
	@override String get filterAll => 'すべて';
	@override String get filterUnwatched => '未視聴';
	@override String get sortRecentlyAdded => '追加が新しい順';
	@override String get sortEarliestAdded => '追加が古い順';
	@override String get watched => '視聴済み';
	@override String get playlistLoadFailed => '再生リストの読み込みに失敗しました';
	@override String get noPlaylists => '再生リストがありません';
	@override String get undo => '元に戻す';
	@override String get clearWatchedConfirm => 'このタブの視聴済みをすべて削除しますか？元に戻せません。';
	@override String get emptyUnwatchedVideo => '未視聴の動画はありません';
	@override String get emptyUnwatchedGallery => '未視聴のギャラリーはありません';
	@override String get queueLoadFailed => '読み込みに失敗しました。タップで再試行';
}

// Path: mediaMenu
class _TranslationsMediaMenuJa extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get like => 'いいね';
	@override String get unlike => 'いいねを取り消す';
	@override String get viewAuthor => '作者ページを見る';
	@override String inFolders({required Object count}) => '${count} 個のフォルダ';
	@override String inPlaylists({required Object count}) => '${count} 個の再生リスト';
	@override String get downloaded => 'ダウンロード済み';
}

// Path: mediaPreview
class _TranslationsMediaPreviewJa extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get preview => 'プレビュー';
	@override String get openDetail => '開く';
	@override String get moreActions => 'その他の操作';
	@override String get previousImage => '前の画像';
	@override String get nextImage => '次の画像';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueJa extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} 枚';
	@override String get upNext => '次に見る';
	@override String get sourceTab => '元のリスト';
	@override String get emptyQueue => 'このキューに再生できる動画はありません';
	@override String get emptyGalleryQueue => 'このキューに画像集はありません';
	@override String get nowPlaying => '再生中';
	@override String get myPlaylists => '自分の再生リスト';
	@override String get authorPlaylists => '作者の再生リスト';
	@override String get openQueue => '次に見る';
	@override String get continueInQueue => '現在のキューで続けて再生';
	@override String get continueInQueueSubtitle => '1本終わると自動で次を再生します。オンの間は「再生終了後にリピート」は無効です';
	@override String get repeatDisabledByQueue => '「現在のキューで続けて再生」がオンのため無効です';
	@override String get playNext => '次を再生';
	@override String get queueEnded => 'このキューの最後の項目です';
	@override String get playNextHint => 'タップで次を再生、長押しで「次に見る」を開きます';
	@override String get authorVideos => '作者の動画';
	@override String get authorGalleries => '作者の画像集';
	@override String get favoriteFolders => 'お気に入りフォルダ';
	@override String get localFiles => 'この端末のファイル';
	@override String get currentFolder => 'このファイルのフォルダ';
	@override String get playThisFolder => 'このフォルダの動画キューを見る';
	@override String get browseThisFolder => 'このフォルダのギャラリーキューを見る';
	@override String get downloads => 'ダウンロード済み';
	@override String get otherPlaylists => '他の人の再生リスト';
	@override String get nothingHere => '何もありません';
}

// Path: vrFormat
class _TranslationsVrFormatJa extends TranslationsVrFormatEn {
	_TranslationsVrFormatJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => '空間プレイヤーで再生';
	@override String get handingOff => '空間へ引き渡し中…';
	@override String get title => '再生モード';
	@override String get spatialSectionTitle => '空間再生';
	@override String get spatialSectionDesc => 'ヘッドセットでは動画はこのパネル内には描かれず、空間プレイヤーがスクリーンに映します。';
	@override String get spatialPanelEntry => '空間コントロールパネル';
	@override String get spatialPanelEntryDesc => 'スクリーンの距離・大きさ・湾曲、背景環境、さらに再生速度・リピート・自動非表示は空間コントロールパネルで調整します。';
	@override String get spatialGuideEntry => 'ヘッドセット操作ガイド';
	@override String get spatialGuideEntryDesc => 'コントローラーのボタン、スクリーンを掴んで移動、スティックでシークとページ送り';
	@override String get spatialFlatOmitted => 'タッチ操作・画質補正・音声/映像パラメーターは 2D プレーヤー専用です。空間プレイヤーは別のエンジンで動くため、ここには表示されません。';
	@override String get spatialGallerySectionTitle => '空間ギャラリー';
	@override String get spatialGalleryPanelDesc => 'スライドショーの間隔、短い動画の単体リピート、スクリーンの湾曲は空間コントロールパネルで調整します。';
	@override String get autoEnterGallery => 'ギャラリー画像を空間ギャラリーで開く';
	@override String get autoEnterGalleryDesc => 'Quest では、画像をタップするとこのパネル内のビューアではなく、空間のスクリーンでギャラリー全体を閲覧します（フィルムストリップ・スライドショー・スティックでページ送り）。';
	@override String get panelSettings => 'パネルと背景';
	@override String get panelSettingsDesc => 'このアプリパネルの距離と、背後に透ける部屋の量';
	@override String get panelDistance => 'パネルの距離';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => '位置をリセット';
	@override String get panelResetBackground => '既定に戻す';
	@override String get panelBackground => '背景の不透明度';
	@override String get panelBackgroundHint => '0%：真っ黒な環境 · 100%：環境光に照らされた実際の部屋';
	@override String get panelUnavailable => 'パネルが今は表示されていません。少し待ってからお試しください';
	@override String get desc => 'この動画をどの形状で再生するかを選びます。サイト側に情報がないため、自動判定は初期値を示すだけで、最終的にはあなたの選択が優先されます。';
	@override String get sectionFlat => '平面';
	@override String get sectionStereo => '平面立体';
	@override String get sectionPanorama => 'VR パノラマ';
	@override String get flat => '通常の動画';
	@override String get flatDesc => '何も加工せずそのまま再生します';
	@override String get flatSideBySide => '左右 3D';
	@override String get flatSideBySideDesc => '1 フレームに左右の目が並ぶ形式。左目だけを表示し比率を戻します';
	@override String get flatTopBottom => '上下 3D';
	@override String get flatTopBottomDesc => '1 フレームに上下の目が並ぶ形式。上半分だけを表示し比率を戻します';
	@override String get vr180SideBySide => 'VR180 左右';
	@override String get vr180SideBySideDesc => '半球パノラマ + 左右両眼。最も一般的な VR 素材です';
	@override String get vr180Mono => 'VR180 単眼';
	@override String get vr180MonoDesc => '半球パノラマ。1 フレームに片目だけ';
	@override String get vr360Mono => 'VR360 単眼';
	@override String get vr360MonoDesc => '全周パノラマ。1 フレームに片目だけ';
	@override String get vr360TopBottom => 'VR360 上下';
	@override String get vr360TopBottomDesc => '全周パノラマ + 上下両眼';
	@override String get resetView => '視点をリセット';
	@override String get resetViewDesc => '見ている向きと視野角を正面に戻します';
	@override String get resetToAuto => '自動判定に戻す';
	@override String get resetToAutoDesc => 'この動画の手動設定を忘れ、自動判定に任せます';
	@override String get manualBadge => '手動で指定済み';
	@override String get panoramaHint => '画面をドラッグで見回し、ピンチで視野角を変更';
	@override String get panoramaGestureNotice => '見回し中は画面のドラッグが視点操作になります。シークはシークバーをお使いください';
	@override String get shaderUnsupported => 'この端末ではリアルタイムの見回しに対応していないため、片目表示に切り替えました';
	@override String get handoffTooltip => '別の方法で再生';
	@override String get suggestedBadge => 'おすすめ';
	@override String suggestedEntryDesc({required Object format}) => '${format} の可能性があります。タップで切り替え';
	@override String suggestionTitle({required Object format}) => 'これは VR 動画かもしれません（${format}）';
	@override String get suggestionTitleShort => 'これは VR 動画かもしれません';
	@override String get suggestionAction => 'VR で再生';
	@override String get suggestionDismiss => '表示しない';
}

// Path: localMedia
class _TranslationsLocalMediaJa extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseJa browse = _TranslationsLocalMediaBrowseJa._(_root);
	@override String get tabFolders => 'フォルダ';
	@override String get tabFavoriteVideos => 'お気に入り';
	@override String get tabAllVideos => 'すべての動画';
	@override String get tabAllImages => 'すべての画像';
	@override String get tabDownloadedVideos => 'ダウンロード済み動画';
	@override String get tabDownloadedGalleries => 'ダウンロード済みギャラリー';
	@override String get title => 'この端末のファイル';
	@override String get sourceOnline => 'Iwara オンライン';
	@override String get manageSources => 'ソースを管理';
	@override String get moveToCategory => 'カテゴリへ移動';
	@override String get manageCategories => 'カテゴリを管理';
	@override String get suggestedFolders => '動画が見つかったフォルダー';
	@override String get sortRecentlyAdded => '追加が新しい順';
	@override String get sortRecentlyPlayed => '最近再生した順';
	@override String get sortName => '名前';
	@override String get sortDuration => '長さ';
	@override String get sortSize => 'サイズ';
	@override String get sortFolder => 'フォルダー';
	@override String get sortRecentlyModified => '更新が新しい順';
	@override String get sortCount => '枚数';
	@override String folderCardItemCount({required Object count}) => '${count} 枚';
	@override String get downloadsSource => 'ダウンロード済み';
	@override String get builtInSourceHint => '「ダウンロード済み」は自動で管理されます';
	@override String get filterByCategory => 'カテゴリで絞り込む';
	@override String get longPressToCategorize => '長押しでカテゴリへ移動';
	@override String get uncategorized => '未分類';
	@override String get setCategoryFailed => 'カテゴリの設定に失敗しました';
	@override String get categoryUpdated => 'カテゴリを更新しました';
	@override String get addFolder => 'フォルダーを追加';
	@override String get addDeviceVideos => '端末の動画をスキャン';
	@override String get mediaStoreSourceName => '端末の動画';
	@override String get scanQueued => 'スキャン待ち';
	@override String get itemInfo => 'ファイル情報';
	@override String get revealInFolder => 'フォルダーで表示';
	@override String get rescanAll => 'すべて再スキャン';
	@override String rescanAllStarted({required Object count}) => '${count} 件のソースを再スキャンします';
	@override String get searchLibrary => '検索';
	@override String get searchIncludeSubfolders => 'サブフォルダーを含む';
	@override String get searchThisFolderOnly => 'このフォルダーのみ';
	@override String searchResultCount({required Object count}) => '${count} 件';
	@override String get savedServers => '保存済みの NAS';
	@override String get newServer => '新しい NAS に接続';
	@override late final _TranslationsLocalMediaItemInfoLabelsJa itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsJa._(_root);
	@override String get addSource => 'ソースを追加';
	@override String get addSourceKinds => 'フォルダー · NAS';
	@override String get openSettings => '設定を開く';
	@override String removeSourceLoses({required Object items}) => '次の内容も一緒に消え、追加し直しても戻りません：${items}';
	@override String loseProgress({required Object count}) => '視聴進捗 ${count} 件';
	@override String loseFavorites({required Object count}) => 'おすすめ ${count} 件';
	@override String losePinned({required Object count}) => 'よく使うフォルダー ${count} 件';
	@override String loseHidden({required Object count}) => '非表示設定 ${count} 件';
	@override String loseCovers({required Object count}) => '手動で選んだカバー ${count} 枚';
	@override String get renameSource => '名前を変更';
	@override String get renameSourceTitle => 'ソース名を変更';
	@override String get renameSourceLabel => '名前';
	@override String get renamed => '名前を変更しました';
	@override String get nasAggregateHint => 'NAS の内容は開いたことのあるフォルダーだけが対象です。開いていないフォルダーの動画や画像はここに表示されません。';
	@override String rescanDone({required Object name}) => '「${name}」を更新しました';
	@override String get unknownSourceHint => 'このソースを使うにはアプリの更新が必要です';
	@override late final _TranslationsLocalMediaMissingJa missing = _TranslationsLocalMediaMissingJa._(_root);
	@override late final _TranslationsLocalMediaWebdavJa webdav = _TranslationsLocalMediaWebdavJa._(_root);
	@override String get mediaStoreUnavailable => '端末のメディアインデックスは Android でのみ利用できます';
	@override String get mediaStorePermissionDenied => '動画へのアクセスが許可されていません';
	@override String get rescan => '再スキャン';
	@override String scanning({required Object count}) => 'スキャン中… ${count} 件見つかりました';
	@override String scanFailed({required Object reason}) => 'スキャンに失敗しました：${reason}';
	@override String scanTruncated({required Object count}) => 'このフォルダーは非常に大きいため、最初の ${count} 件のみ取り込みました。';
	@override String sourceOverlaps({required Object name}) => 'フォルダー「${name}」に既に含まれています';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '「${name}」は「${source}」の中にあるため、よく使うフォルダーに追加しました';
	@override String alreadyPinnedFolder({required Object name}) => '「${name}」は既によく使うフォルダーにあります';
	@override String sourceAlreadyAdded({required Object name}) => '「${name}」は既に追加されています';
	@override String sourceContainsExisting({required Object name}) => '追加済みのフォルダー「${name}」を含んでいるため、その親フォルダーはまだ追加できません';
	@override String get addSourceFailed => 'フォルダーを追加できませんでした';
	@override String get fileMissing => 'このファイルはディスク上にありません';
	@override String get permissionDenied => 'ファイルアクセスが許可されていません。フォルダーを追加する前に許可してください';
	@override String get noVideosFound => 'このフォルダーに動画はありません';
	@override String get emptyTitle => 'フォルダーを追加するか NAS に接続して、手元の動画を見る';
	@override String get emptyPrivacyNote => '端末内でのみ読み取ります。アップロードは一切ありません。';
	@override String removeSourceTitle({required Object name}) => '「${name}」を削除しますか？';
	@override String get removeSourceBody => 'ファイル自体はそのままです。ライブラリーから外すだけです。';
	@override String get remove => '削除';
	@override String get removeFolder => 'ソースを削除';
	@override String get removeFolderSelectTitle => '削除するソースを選択';
	@override String get longPressToRemove => '長押しでこのフォルダーを削除';
	@override String get clearProgress => 'ローカル視聴履歴を消去';
	@override String clearProgressCount({required Object count}) => '${count} 件';
	@override String get clearProgressEmpty => 'ローカル視聴履歴はまだありません';
	@override String get clearProgressTitle => 'ローカル視聴履歴を消去しますか？';
	@override String get clearProgressBody => '再生位置と「視聴済み」の印だけを削除します。ファイルとフォルダーはそのままです。';
	@override String clearProgressDone({required Object count}) => 'ローカル視聴履歴を ${count} 件消去しました';
	@override String get clearAction => '消去';
	@override String get iosManualRescanNotice => 'iOSでは新しいファイルは自動検出されません。ファイルを追加または削除した後は、手動で再スキャンする必要があります。';
}

// Path: historyPage
class _TranslationsHistoryPageJa extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => '履歴から削除';
	@override String get removed => '履歴から削除しました';
	@override String watchedTo({required Object time}) => '${time} まで視聴';
	@override String get finished => '視聴済み';
	@override String clearTabTitle({required Object tab}) => '「${tab}」を消去';
	@override String clearTabConfirm({required Object tab}) => '「${tab}」の履歴をすべて削除し、該当する動画の視聴位置も消去します。この操作は元に戻せません。';
	@override String get rangeByLastViewed => '最終閲覧日時で絞り込み';
}

// Path: ai
class _TranslationsAiJa extends TranslationsAiEn {
	_TranslationsAiJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI';
	@override String get providers => 'プロバイダー';
	@override String get providersHint => '1つ以上のAIプロバイダーを追加し、各機能で使用するプロバイダーを指定します。';
	@override String get addProvider => 'プロバイダーを追加';
	@override String get noProviders => 'プロバイダーがまだありません。追加するとAI翻訳・検索・署名機能が利用可能になります。';
	@override String get pickPreset => 'プロバイダーを選択';
	@override String get providerNameLabel => '名前';
	@override String get apiKey => 'APIキー';
	@override String get baseUrl => 'エンドポイント';
	@override String get model => 'モデル';
	@override String get modelPick => 'モデルを選択';
	@override String get modelEmpty => 'モデルリストを取得できませんでした。直接モデル名を入力しても利用できます。';
	@override String get advanced => '詳細設定';
	@override String get reasoning => '推論モデル';
	@override String get streaming => 'ストリーミング出力';
	@override String get structuredOutput => '構造化出力';
	@override String get structuredOutputHint => 'AI検索で必要です。多くの中継エンドポイントでは対応していないため、検索が失敗し続ける場合は無効にしてください。';
	@override String get temperature => 'サンプリング温度';
	@override String get maxTokens => '最大トークン数';
	@override String get maxTokensAuto => '自動（モデル上限）';
	@override String get test => 'テスト';
	@override String get testOk => '接続成功';
	@override String get deleteProvider => 'プロバイダーを削除';
	@override String get usedBy => '使用先';
	@override String get taskBindings => '機能の割り当て';
	@override String get taskBindingsHint => '機能ごとに異なるプロバイダーを指定できます。';
	@override String get taskTranslate => '翻訳';
	@override String get taskSearch => 'AI検索';
	@override String get taskSignature => '署名';
	@override String get taskAuto => '自動';
	@override String get usage => '使用状況';
	@override String get usageCalls => '呼び出し回数';
	@override String get usageTokens => 'トークン数';
	@override String get usageFailures => '失敗';
	@override String get usageReset => '統計をリセット';
	@override String get usageEmpty => '呼び出し履歴はまだありません';
	@override String get openSettings => 'AI設定を開く';
	@override String get notConfigured => '未設定';
	@override String get searchTitle => 'AI検索';
	@override String get searchHint => '探したいものを文章で説明すると、AIが検索キーワードと絞り込み条件を入力します。';
	@override String get searchPlaceholder => '例：再生回数1万回以上の最新MMD';
	@override String get searchApply => 'この条件で検索';
	@override String get searchEmpty => '検索条件を抽出できませんでした。別の表現で試してみてください。';
	@override String get searchFilters => 'フィルター';
	@override String searchSwitchSegment({required Object segment}) => '「${segment}」に切り替え';
	@override String get searchGenerating => '考え中…';
	@override String get searchRetrying => '前回は失敗しました。再試行中…';
	@override String searchRetryReason({required Object reason}) => '原因：${reason}';
	@override String get searchStageWaiting => 'リクエスト送信済み、応答待ち…';
	@override String get searchStageThinkingNext => '次の手を考えています…';
	@override String get searchStageReasoning => '推論中…';
	@override String get searchStageTool => '検索を試しています…';
	@override String searchStageDrafting({required Object chars}) => '回答を作成中 · ${chars} 文字';
	@override String get searchStageParsing => '結果を整理中…';
	@override String get searchThinking => '思考の過程';
	@override String get searchKeywordNeedsQuotes => 'このキーワードは引用符で囲まれていないため、iwara は細かく分解して緩く一致させます。この並び順だと1ページ目はほぼ無関係です。"引用符"で囲むか、関連度順にしてください。';
	@override String searchToolProbing({required Object query}) => '${query} で試し検索';
	@override String searchToolFound({required Object count, required Object titles}) => '${count} 件 · ${titles}';
	@override String searchToolFailed({required Object reason}) => '試し検索に失敗：${reason}';
	@override String searchFiltersDropped({required Object count}) => 'このセクションに無い絞り込みを ${count} 件削除しました。';
}

// Path: common.pagination
class _TranslationsCommonPaginationJa extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => '全 ${num} 件';
	@override String get jumpToPage => 'ページ指定';
	@override String pleaseEnterPageNumber({required Object max}) => 'ページ番号を入力してください (1-${max})';
	@override String get pageNumber => 'ページ番号';
	@override String get jump => '移動';
	@override String invalidPageNumber({required Object max}) => '有効なページ番号を入力してください (1-${max})';
	@override String get invalidInput => '有効なページ番号を入力してください';
	@override String get waterfall => 'ウォーターフォール';
	@override String get pagination => 'ページネーション';
}

// Path: errors.network
class _TranslationsErrorsNetworkJa extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'ネットワークエラー - ';
	@override String get failedToConnectToServer => 'サーバーへの接続に失敗しました';
	@override String get serverNotAvailable => 'サーバーが利用できません';
	@override String get requestTimeout => 'リクエストタイムアウト';
	@override String get unexpectedError => '予期しないエラー';
	@override String get invalidResponse => '無効なレスポンス';
	@override String get invalidRequest => '無効なリクエスト';
	@override String get invalidUrl => '無効なURL';
	@override String get invalidMethod => '無効なメソッド';
	@override String get invalidHeader => '無効なヘッダー';
	@override String get invalidBody => '無効なボディ';
	@override String get invalidStatusCode => '無効なステータスコード';
	@override String get serverError => 'サーバーエラー';
	@override String get requestCanceled => 'リクエストがキャンセルされました';
	@override String get invalidPort => '無効なポート';
	@override String get proxyPortError => 'プロキシポートエラー';
	@override String get connectionRefused => '接続が拒否されました';
	@override String get networkUnreachable => 'ネットワークに到達できません';
	@override String get noRouteToHost => 'ホストに到達できません';
	@override String get connectionFailed => '接続に失敗しました';
	@override String get sslConnectionFailed => 'SSL接続に失敗しました。ネットワーク設定を確認してください';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingJa extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'キーボードショートカット';
	@override String get entryLabel => 'キーボードショートカット';
	@override String get entryDesc => 'アプリのキーボードショートカットをカスタマイズ（主にデスクトップ向け）';
	@override String get desktopHint => 'ショートカットは主にデスクトップのキーボードで有効です。モバイルでは通常ジェスチャーを使用します。';
	@override String get resetAll => 'すべて既定に戻す';
	@override String get resetAllConfirm => 'すべてのショートカットを既定に戻しますか？';
	@override String get resetToDefault => '既定に戻す';
	@override String get resetScope => 'このセクションを既定に戻す';
	@override String get notSet => '未設定';
	@override String get addShortcut => 'ショートカットを追加';
	@override String get removeShortcut => 'このショートカットを削除';
	@override String get pressNewShortcut => '新しいショートカットを押してください…';
	@override String get recordingCancelHint => 'Esc でキャンセル';
	@override String get mouseHint => 'マウスのサイドボタン（戻る / 進む）や中ボタンも割り当て可能です';
	@override String get mouseNotSupportedInScope => 'このエリアはマウスボタンを処理しません。キーボードを使用してください';
	@override String get capabilityKeyboardOnly => 'このエリアはキーボードのみ受け付けます';
	@override String get capabilityKeyboardAndMouse => 'このエリアはキーボードと、マウスの中ボタン / サイドボタンを受け付けます';
	@override String get capabilityKeyboardAndMouseMobile => 'このエリアはキーボードと、マウスの中ボタン / 進むボタンを受け付けます（戻るボタンはシステムが使用中）';
	@override String get rejectMultipleButtons => 'マウスボタンは一度に一つだけ押してください';
	@override String get rejectPlatformBack => 'このキーはシステムが「戻る」に使用しており、割り当てると二重に戻ります';
	@override String get detectedLabel => '検出';
	@override String get reservedKey => 'このキーはシステム予約のため割り当てできません';
	@override String reservedForGlobalBack({required Object action}) => 'このキーは「${action}」に割り当てられています。ここから戻れなくなるため、この領域では予約されています';
	@override String get conflictTitle => 'ショートカットの競合';
	@override String conflictMessage({required Object action}) => 'この組み合わせは既に「${action}」に割り当てられています。続行すると既存の割り当ては解除されます。';
	@override String get conflictContinue => 'それでも割り当てる';
	@override String get shadowWarningTitle => 'グローバルショートカットの重複';
	@override String shadowWarningMessage({required Object action}) => 'この組み合わせは既に「${action}」にグローバル割り当てされています。ここで割り当てると、このセクション内ではその動作が上書きされます。';
	@override String globalShadowedMessage({required Object scope, required Object action}) => 'この組み合わせは既に「${scope}」で「${action}」に割り当てられています。そのセクション内では、このグローバルショートカットは上書きされます。';
	@override String get searchHint => 'ショートカットを検索…';
	@override String get scopeGlobal => 'グローバル';
	@override String get scopeGallery => 'ギャラリー';
	@override String get scopeVideo => '動画';
	@override String get categoryNavigation => 'ナビゲーション';
	@override String get categoryZoom => 'ズーム';
	@override String get categoryPlayback => '再生';
	@override String get categorySeek => 'シーク';
	@override String get categoryVolume => '音量';
	@override String get categoryDisplay => '表示';
	@override String get actionGlobalBack => '戻る';
	@override String get actionGalleryNext => '次の写真';
	@override String get actionGalleryPrevious => '前の写真';
	@override String get actionGalleryZoomIn => 'ズームイン';
	@override String get actionGalleryZoomOut => 'ズームアウト';
	@override String get actionGalleryResetZoom => 'ズームリセット';
	@override String get actionGalleryPlayPause => '再生 / 一時停止';
	@override String get actionGallerySeekBackward => '巻き戻し';
	@override String get actionGallerySeekForward => '早送り';
	@override String get actionGalleryToggleMute => 'ミュート切替';
	@override String get actionPlayPause => '再生 / 一時停止';
	@override String get actionSpeedUp => '再生速度を上げる';
	@override String get actionSpeedDown => '再生速度を下げる';
	@override String get actionSeekForward => '早送り';
	@override String get actionSeekBackward => '巻き戻し';
	@override String get actionVolumeUp => '音量を上げる';
	@override String get actionVolumeDown => '音量を下げる';
	@override String get actionToggleMute => 'ミュート切替';
	@override String get actionToggleFullscreen => '全画面切替';
	@override String get seekLongPressHint => '早送り / 巻き戻しキーを長押しすると長押し速度モードになります';
	@override String get zoomSectionTitle => '画面ズーム（固定）';
	@override String get zoomFixedNote => '以下のショートカットは固定で変更できません';
	@override String get zoomScaleLabel => '画面をズーム';
	@override String get zoomScaleHint => 'Ctrl + ホイール';
	@override String get zoomRotateLabel => '画面を回転';
	@override String get zoomRotateHint => 'Shift + ホイール';
	@override String get zoomPinchGesture => 'ピンチ';
	@override String get zoomTwoFingerRotateGesture => '2本指で回転';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsJa extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'フォーラム';
	@override String get configureYourForumSettings => 'フォーラム設定を構成する';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsJa extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'ギャラリー設定';
	@override String get gallerySettingsSubtitle => 'ギャラリービューアの設定';
	@override String get defaultViewerQuality => 'デフォルト画質';
	@override String get defaultViewerQualityDesc => 'ギャラリービューアを開いたときに表示する画質を選択します。';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsJa extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'コンテンツブロック';
	@override String get subtitle => 'タイトルがキーワードや正規表現に一致する、またはブロックしたユーザーの投稿を自動的に非表示にします。判定はすべて端末内で行われ、アップロードされません。';
	@override String get blocked => 'ブロック済み';
	@override String get reveal => '表示';
	@override String get reblock => '再ブロック';
	@override String get why => '非表示の理由';
	@override String get manageRules => 'ルールを管理';
	@override String reasonKeyword({required Object value}) => 'タイトルに「${value}」を含む';
	@override String reasonRegex({required Object value}) => 'タイトルが正規表現「${value}」に一致';
	@override String get reasonUser => 'ブロックしたユーザー';
	@override String get addRule => 'ルールを追加';
	@override String get editRule => 'ルールを編集';
	@override String get deleteRule => 'ルールを削除';
	@override String get ruleType => 'ルールの種類';
	@override String get keyword => 'キーワード';
	@override String get regex => '正規表現';
	@override String get userId => 'ユーザー';
	@override String get value => '一致させる内容';
	@override String get caseSensitive => '大文字小文字を区別';
	@override String get regexHint => '例 予告|特典';
	@override String get valueRequired => '一致させる内容を入力してください';
	@override String get invalidRegex => '正規表現の形式が正しくありません';
	@override String get noRules => 'ルールがありません。右下の + で追加できます。';
	@override String get blockUser => 'ブロック';
	@override String get unblockUser => 'ブロック解除';
	@override String blockUserConfirm({required Object name}) => '「${name}」をブロックしますか？その動画とギャラリーは一覧と検索で非表示になります。';
	@override String get userBlocked => 'ユーザーをブロックしました';
	@override String get userUnblocked => 'ブロックを解除しました';
	@override String get exportRules => 'エクスポート';
	@override String get importRules => 'インポート';
	@override String get importExport => 'インポート / エクスポート';
	@override String get exportSuccess => 'ルールをエクスポートしました';
	@override String get exportFailed => 'エクスポートに失敗しました';
	@override String importSuccess({required Object count}) => '${count} 件のルールをインポートしました';
	@override String get importFailed => 'インポートに失敗しました';
	@override String get regexHelp => '正規表現ヘルプ';
	@override String get regexHelpTitle => '正規表現リファレンス';
	@override String get regexHelpIntro => '正規表現はキーワードより柔軟にタイトルを照合できます。よく使う例：';
	@override String get regexHelpTapHint => '例をタップするとそのまま入力されます。';
	@override String get regexEx1Pattern => '予告|特典|おまけ';
	@override String get regexEx1Desc => '「|」でいずれかに一致（「または」の意味）';
	@override String get regexEx2Pattern => '^【.*】';
	@override String get regexEx2Desc => '【…】で始まるタイトルに一致';
	@override String get regexEx3Pattern => '総集編\$';
	@override String get regexEx3Desc => '「総集編」で終わるタイトルに一致';
	@override String get regexEx4Pattern => '第.話';
	@override String get regexEx4Desc => '「.」は任意の1文字（「第1話」「第X話」に一致）';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '「\\d」は数字、{4} は4桁（年など）';
	@override String get regexEx1Sample => '新作の予告公開中';
	@override String get regexEx2Sample => '【総集編】夏まつり';
	@override String get regexEx3Sample => '夏まつり 総集編';
	@override String get regexEx4Sample => '番外 第3話 配信';
	@override String get regexEx5Sample => '2024 年ベスト';
	@override String get regexHelpSampleLabel => 'タイトル例';
	@override String get regexHelpMatchedTag => 'ブロック対象';
	@override String get regexHelpNoMatch => '一致なし';
	@override String get regexEx6Pattern => '[完未]結';
	@override String get regexEx6Desc => '「[完未]」は「完」か「未」のどちらか1文字、完結 / 未結 に一致';
	@override String get regexEx6Sample => 'アニメ 完結 記念';
	@override String get regexEx7Pattern => '(予告|宣伝)映像';
	@override String get regexEx7Desc => '丸括弧 () で複数の語をグループ化、予告映像 か 宣伝映像 に一致';
	@override String get regexEx7Sample => '最新宣伝映像';
	@override String get regexEx8Pattern => '予告(編)?';
	@override String get regexEx8Desc => '(編)? は「編」があってもなくてもよい、予告 か 予告編 に一致';
	@override String get regexEx8Sample => '新作予告 公開';
	@override String get regexEx9Pattern => 'w+';
	@override String get regexEx9Desc => '「+」は1個以上、w・ww・www に一致';
	@override String get regexEx9Sample => '面白いwww 動画';
	@override String get regexEx10Pattern => '予告.*版';
	@override String get regexEx10Desc => '「.*」は間の任意の文字に一致、「予告…版」に一致';
	@override String get regexEx10Sample => '予告 完全版 公開';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsJa extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'チャット';
	@override String get configureYourChatSettings => 'チャット設定を構成する';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsJa extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'ダウンロード設定';
	@override String get enableDownloadNotifications => 'ダウンロード通知';
	@override String get enableDownloadNotificationsDescription => '単一のダウンロードが完了または失敗したときにシステム通知を表示します';
	@override String get notificationPermissionDenied => '通知権限が拒否されました。アプリ内通知は引き続き利用できます。システム通知が必要な場合は設定で有効にしてください。';
	@override String get storagePermissionStatus => 'ストレージ権限状態';
	@override String get accessPublicDirectoryNeedStoragePermission => 'パブリックディレクトリにアクセスするにはストレージ権限が必要です';
	@override String get checkingPermissionStatus => '権限状態を確認中...';
	@override String get storagePermissionGranted => 'ストレージ権限が付与されました';
	@override String get storagePermissionNotGranted => 'ストレージ権限が付与されていません';
	@override String get storagePermissionGrantSuccess => 'ストレージ権限が付与されました';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'ストレージ権限が付与されませんでしたが、一部の機能が制限される可能性があります';
	@override String get storagePermissionRationale => '選択した場所にファイルを保存するには、ストレージ権限が必要です。\n\nAndroid 11 以降では公開ディレクトリへの書き込みに「すべてのファイルへのアクセス」権限が必要です。許可しない場合、ファイルはアプリ専用ディレクトリに保存されます。';
	@override String get storagePermissionRationaleLegacy => '選択した場所にファイルを保存するには、ストレージ権限が必要です。\n\n許可しない場合、ファイルはアプリ専用ディレクトリに保存されます。';
	@override String get grantStoragePermission => 'ストレージ権限を付与';
	@override String get customDownloadPath => 'カスタムダウンロードパス';
	@override String get customDownloadPathDescription => '有効にすると、ダウンロードファイルのカスタム保存場所を選択できます';
	@override String get customDownloadPathTip => '💡 ヒント：パブリックディレクトリ（ダウンロードフォルダなど）を選択するにはストレージ権限が必要です。推奨パスの使用をお勧めします';
	@override String get androidWarning => 'Android注意：パブリックディレクトリ（ダウンロードフォルダなど）の選択を避け、アクセス権限を確保するためにアプリ専用ディレクトリの使用をお勧めします。';
	@override String get publicDirectoryPermissionTip => '⚠️ 注意：パブリックディレクトリを選択しました。正常にファイルをダウンロードするにはストレージ権限が必要です';
	@override String get permissionRequiredForPublicDirectory => 'パブリックディレクトリにはストレージ権限が必要です';
	@override String get currentDownloadPath => '現在のダウンロードパス';
	@override String get actualDownloadPath => '実際のダウンロードパス';
	@override String get defaultAppDirectory => 'デフォルトアプリディレクトリ';
	@override String get permissionGranted => '付与済み';
	@override String get permissionRequired => '権限が必要';
	@override String get enableCustomDownloadPath => 'カスタムダウンロードパスを有効にする';
	@override String get disableCustomDownloadPath => '無効時はアプリのデフォルトパスを使用';
	@override String get customDownloadPathLabel => 'カスタムダウンロードパス';
	@override String get selectDownloadFolder => 'ダウンロードフォルダを選択';
	@override String get recommendedPath => '推奨パス';
	@override String get selectFolder => 'フォルダを選択';
	@override String get filenameTemplate => 'ファイル名テンプレート';
	@override String get filenameTemplateDescription => 'ダウンロードファイルの命名規則をカスタマイズし、変数置換をサポート';
	@override String get videoFilenameTemplate => '動画ファイル名テンプレート';
	@override String get galleryFolderTemplate => 'ギャラリーフォルダテンプレート';
	@override String get imageFilenameTemplate => '画像ファイル名テンプレート';
	@override String get resetToDefault => 'デフォルトにリセット';
	@override String get supportedVariables => 'サポートされている変数';
	@override String get supportedVariablesDescription => 'ファイル名テンプレートで以下の変数を使用できます：';
	@override String get copyVariable => '変数をコピー';
	@override String get variableCopied => '変数がコピーされました';
	@override String get warningPublicDirectory => '警告：選択されたパブリックディレクトリにアクセスできない可能性があります。アプリ専用ディレクトリの選択をお勧めします。';
	@override String get downloadPathUpdated => 'ダウンロードパスが更新されました';
	@override String get selectPathFailed => 'パスの選択に失敗しました';
	@override String get pickerAlreadyActive => 'フォルダ選択画面はすでに開いています';
	@override String get unsupportedStorageVolume => 'この保存先には対応していません。本体ストレージまたは SD カード内のフォルダを選んでください。';
	@override String get recommendedPathSet => '推奨パスに設定されました';
	@override String get setRecommendedPathFailed => '推奨パスの設定に失敗しました';
	@override String get templateResetToDefault => 'デフォルトテンプレートにリセットされました';
	@override String get functionalTest => '機能テスト';
	@override String get testInProgress => 'テスト中...';
	@override String get runTest => 'テスト実行';
	@override String get testDownloadPathAndPermissions => 'ダウンロードパスと権限設定が正常に動作するかテストします';
	@override String get testResults => 'テスト結果';
	@override String get testCompleted => 'テスト完了';
	@override String get testMultisegmentDomain => '値域チェック（複数段 / 上限超え / 逸脱形）';
	@override String get testMultisegmentPaths => '複数段構造のレンダリング（issue #126）';
	@override String get testPassed => '項目が通過しました';
	@override String get testFailed => 'テスト失敗';
	@override String get testStoragePermissionCheck => 'ストレージ権限チェック';
	@override String get testStoragePermissionGranted => 'ストレージ権限が付与されています';
	@override String get testStoragePermissionMissing => 'ストレージ権限がありません、一部の機能が制限される可能性があります';
	@override String get testPermissionCheckFailed => '権限チェックに失敗しました';
	@override String get testDownloadPathValidation => 'ダウンロードパス検証';
	@override String get testPathValidationFailed => 'パス検証に失敗しました';
	@override String get testFilenameTemplateValidation => 'ファイル名テンプレート検証';
	@override String get testAllTemplatesValid => 'すべてのテンプレートが有効です';
	@override String get testSomeTemplatesInvalid => '一部のテンプレートに無効な文字が含まれています';
	@override String get testTemplateValidationFailed => 'テンプレート検証に失敗しました';
	@override String get testDirectoryOperationTest => 'ディレクトリ操作テスト';
	@override String get testDirectoryOperationNormal => 'ディレクトリ作成とファイル書き込みが正常です';
	@override String get testDirectoryOperationFailed => 'ディレクトリ操作に失敗しました';
	@override String get testVideoTemplate => '動画テンプレート';
	@override String get testGalleryTemplate => 'ギャラリーテンプレート';
	@override String get testImageTemplate => '画像テンプレート';
	@override String get testValid => '有効';
	@override String get testInvalid => '無効';
	@override String get testSuccess => '成功';
	@override String get testCorrect => '正しい';
	@override String get testError => 'エラー';
	@override String get testPath => 'テストパス';
	@override String get testBasePath => '基本パス';
	@override String get testDirectoryCreation => 'ディレクトリ作成';
	@override String get testFileWriting => 'ファイル書き込み';
	@override String get testFileContent => 'ファイル内容';
	@override String get checkingPathStatus => 'パス状態を確認中...';
	@override String get unableToGetPathStatus => 'パス状態を取得できません';
	@override String get actualPathDifferentFromSelected => '注意：実際のパスが選択されたパスと異なります';
	@override String get grantPermission => '権限を付与';
	@override String get fixIssue => '問題を修正';
	@override String get issueFixed => '問題が修正されました';
	@override String get fixFailed => '修正に失敗しました、手動で処理してください';
	@override String get lackStoragePermission => 'ストレージ権限がありません';
	@override String get cannotAccessPublicDirectory => 'パブリックディレクトリにアクセスできません、「すべてのファイルアクセス権限」が必要です';
	@override String get cannotCreateDirectory => 'ディレクトリを作成できません';
	@override String get directoryNotWritable => 'ディレクトリに書き込みできません';
	@override String get insufficientSpace => '利用可能な容量が不足しています';
	@override String get pathValid => 'パスが有効です';
	@override String get validationFailed => '検証に失敗しました';
	@override String get usingDefaultAppDirectory => 'デフォルトアプリディレクトリを使用';
	@override String get appPrivateDirectory => 'アプリ専用ディレクトリ';
	@override String get appPrivateDirectoryDesc => '安全で信頼性があり、追加の権限は不要';
	@override String get downloadDirectory => 'ダウンロードディレクトリ';
	@override String get downloadDirectoryDesc => 'システムデフォルトのダウンロード場所、管理が簡単';
	@override String get moviesDirectory => '動画ディレクトリ';
	@override String get moviesDirectoryDesc => 'システム動画ディレクトリ、メディアアプリで認識可能';
	@override String get documentsDirectory => 'ドキュメントディレクトリ';
	@override String get documentsDirectoryDesc => 'iOSアプリドキュメントディレクトリ';
	@override String get requiresStoragePermission => 'アクセスにはストレージ権限が必要';
	@override String get recommendedPaths => '推奨パス';
	@override String get externalAppPrivateDirectory => '外部アプリ専用ディレクトリ';
	@override String get externalAppPrivateDirectoryDesc => '外部ストレージのアプリ専用ディレクトリ、ユーザーがアクセス可能、容量が大きい';
	@override String get internalAppPrivateDirectory => '内部アプリ専用ディレクトリ';
	@override String get internalAppPrivateDirectoryDesc => 'アプリ内部ストレージ、権限不要、容量が小さい';
	@override String get appDocumentsDirectory => 'アプリドキュメントディレクトリ';
	@override String get appDocumentsDirectoryDesc => 'アプリ専用ドキュメントディレクトリ、安全で信頼性が高い';
	@override String get downloadsFolder => 'ダウンロードフォルダ';
	@override String get downloadsFolderDesc => 'システムデフォルトのダウンロードディレクトリ';
	@override String get selectRecommendedDownloadLocation => '推奨されるダウンロード場所を選択';
	@override String get noRecommendedPaths => '推奨パスがありません';
	@override String get recommended => '推奨';
	@override String get requiresPermission => '権限が必要';
	@override String get authorizeAndSelect => '認証して選択';
	@override String get select => '選択';
	@override String get permissionAuthorizationFailed => '権限認証に失敗しました、このパスを選択できません';
	@override String get pathValidationFailed => 'パス検証に失敗しました';
	@override String get downloadPathSetTo => 'ダウンロードパスが設定されました';
	@override String get setPathFailed => 'パスの設定に失敗しました';
	@override String get variableTitle => 'タイトル';
	@override String get variableAuthorcache => '作者の初回名（改名しても変わりません）';
	@override String get variableAuthor => '作者名';
	@override String get variableUsername => '作者ユーザー名';
	@override String get variableQuality => '動画品質';
	@override String get variableFilename => '元のファイル名';
	@override String get variableId => 'コンテンツID';
	@override String get variableCount => 'ギャラリー画像数';
	@override String get variableDate => '現在の日付 (YYYY-MM-DD)';
	@override String get variableTime => '現在の時刻 (HH-MM-SS)';
	@override String get variableDatetime => '現在の日時 (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'ダウンロード設定';
	@override String get downloadSettingsSubtitle => 'ダウンロードパスとファイル命名規則を設定';
	@override String get suchAsTitleQuality => '例: %title_%quality';
	@override String get suchAsTitleId => '例: %title_%id';
	@override String get suchAsTitleFilename => '例: %title_%filename';
	@override String get structureSection => '保存構造と命名';
	@override String get structureSectionDescription => 'ダウンロードしたファイルは、以下で選んだ方式に従ってサブフォルダへ自動整理されます。今後のダウンロードにのみ影響し、既存ファイルはそのままです。';
	@override String get structureNoticeTitle => '新機能：作者ごとに自動で整理';
	@override String get structureNoticeBody => '下から選ぶだけ · 今後のダウンロードにのみ影響し、既存ファイルはそのままです。';
	@override String get presetFlat => 'フラット';
	@override String get presetFlatDesc => 'すべてのファイルをダウンロードルート直下に置く';
	@override String get presetAuthor => '作者別';
	@override String get presetAuthorBadge => 'おすすめ';
	@override String get presetAuthorDesc => '作者ごとにフォルダ分け · 名前が変わっても迷子にならない';
	@override String get presetDate => '日付別';
	@override String get presetDateDesc => 'ダウンロード日ごとに整理';
	@override String get presetCustomActive => '使用中';
	@override String get structurePreviewLabel => 'プレビュー';
	@override String get structurePreviewNote => '色付きの部分が整理の階層です。選択した方式に応じて変わります。';
	@override String get pathTooLongWarning => '相対パスが200文字を超えています。一部の端末では保存できない場合があります';
	@override String get pathTemplateEditorEntry => 'パステンプレート';
	@override String get pathTemplateEditorEntryDesc => 'フォルダの階層とファイル名は自分で決められます';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorJa pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorJa._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesJa extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get hot => '急上昇';
	@override String get favorites => '高評価';
	@override String get latest => '新着';
	@override String get popularity => '人気';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsJa extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'リクエストが失敗しました、ステータスコード';
	@override String get connectionTimeout => '接続がタイムアウトしました、ネットワーク接続を確認してください';
	@override String get sendTimeout => 'リクエスト送信がタイムアウトしました';
	@override String get receiveTimeout => 'レスポンス受信がタイムアウトしました';
	@override String get badCertificate => '証明書の検証に失敗しました';
	@override String get resourceNotFound => '要求されたリソースが見つかりません';
	@override String get accessDenied => 'アクセスが拒否されました、認証または権限が必要な可能性があります';
	@override String get serverError => 'サーバー内部エラー';
	@override String get serviceUnavailable => 'サービスが一時的に利用できません';
	@override String get requestCancelled => 'リクエストがキャンセルされました';
	@override String get connectionError => 'ネットワーク接続エラー、ネットワーク設定を確認してください';
	@override String get networkRequestFailed => 'ネットワークリクエストが失敗しました';
	@override String get searchVideoError => '動画検索中に不明なエラーが発生しました';
	@override String get getPopularVideoError => '人気動画取得中に不明なエラーが発生しました';
	@override String get getVideoDetailError => '動画詳細取得中に不明なエラーが発生しました';
	@override String get parseVideoDetailError => '動画詳細の取得と解析中に不明なエラーが発生しました';
	@override String get downloadFileError => 'ファイルダウンロード中に不明なエラーが発生しました';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingJa extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => '動画情報を取得中...';
	@override String get cancel => 'キャンセル';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesJa extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => '動画が見つからないか削除されました';
	@override String get unableToGetVideoPlayLink => '動画再生リンクを取得できません';
	@override String get getVideoDetailFailed => '動画詳細の取得に失敗しました';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoJa extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'ビデオ情報';
	@override String get currentQuality => '現在の品質';
	@override String get duration => '再生時間';
	@override String get resolution => '解像度';
	@override String get fileInfo => 'ファイル情報';
	@override String get fileName => 'ファイル名';
	@override String get fileSize => 'ファイルサイズ';
	@override String get filePath => 'ファイルパス';
	@override String get copyPath => 'パスをコピー';
	@override String get openFolder => 'フォルダを開く';
	@override String get pathCopiedToClipboard => 'パスをクリップボードにコピーしました';
	@override String get openFolderFailed => 'フォルダを開けませんでした';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideJa extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'サンプル動画';
	@override String get title => 'ジェスチャー・操作ガイド';
	@override String get viewGuide => 'ジェスチャー・操作ガイドを見る';
	@override String get firstTimeIntro => 'プレーヤーのジェスチャーを数秒で確認しましょう。このガイドはプレーヤー設定からいつでも再表示できます。';
	@override String get startWatching => '確認して再生を始める';
	@override String get basicTitle => '基本操作';
	@override String get zoomTitle => '拡大 / 回転 / 移動';
	@override String get restoreTip => '右下の「リセット」ボタンで拡大・回転・位置を元に戻せます。';
	@override String get mTap => 'シングルタップ：コントロールの表示 / 非表示';
	@override String get mDoubleTap => 'ダブルタップ：左で巻き戻し / 中央で一時停止 / 右で早送り';
	@override String get mHorizontalDrag => '横スワイプ：シーク';
	@override String get mVerticalDrag => '縦スワイプ：左で明るさ / 右で音量';
	@override String get mLongPress => '長押し：一時的な倍速再生';
	@override String get mPinch => '2本指ピンチ：映像を拡大';
	@override String get mRotate => '2本指回転：映像を回転';
	@override String get dTap => 'クリック：コントロールの表示 / 非表示';
	@override String get dDoubleTap => 'ダブルクリック：左で巻き戻し / 中央で一時停止 / 右で早送り';
	@override String get dKeys => 'シークキー：シングルで巻き戻し / 早送り、長押しで倍速再生；速度キー：通常再生中に倍速を段階調整；スペース：再生 / 一時停止';
	@override String get dTrackpadPinch => 'トラックパッドのピンチ：映像を拡大';
	@override String get dTrackpadRotate => 'トラックパッドの回転：映像を回転';
	@override String get dCtrlWheel => 'Ctrl + ホイール：カーソル中心に拡大';
	@override String get dShiftWheel => 'Shift + ホイール：カーソル中心に回転';
	@override late final _TranslationsVideoDetailGestureGuideQuestJa quest = _TranslationsVideoDetailGestureGuideQuestJa._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerJa extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'ビデオソースの読み込み中にエラーが発生しました';
	@override String get errorWhileSettingUpListeners => '監視器の設定中にエラーが発生しました';
	@override String get serverFaultDetectedAutoSwitched => 'サーバー障害を検出しました。自動的にルートを切り替えて再試行しています';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonJa extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'ビデオ情報を取得中...';
	@override String get fetchingVideoSources => 'ビデオソースを取得中...';
	@override String get loadingVideo => 'ビデオを読み込み中...';
	@override String get applyingSolution => '解像度を適用中...';
	@override String get addingListeners => '監視器を追加中...';
	@override String get successFecthVideoDurationInfo => 'ビデオの総時間を取得しました、ビデオを読み込み中...';
	@override String get successFecthVideoHeightInfo => '読み込み完了';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastJa extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'キャスト';
	@override String unableToStartCastingSearch({required Object error}) => 'キャスト検索の開始に失敗しました: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'キャスト開始: ${deviceName}';
	@override String castFailed({required Object error}) => 'キャスト失敗: ${error}\n再検索してください';
	@override String get castStopped => 'キャスト停止';
	@override late final _TranslationsVideoDetailCastDeviceTypesJa deviceTypes = _TranslationsVideoDetailCastDeviceTypesJa._(_root);
	@override String get currentPlatformNotSupported => '現在のプラットフォームはキャスト機能をサポートしていません';
	@override String get unableToGetVideoUrl => 'ビデオのURLを取得できません、後でもう一度お試しください';
	@override String get stopCasting => 'キャスト停止';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetJa dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetJa._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsJa extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => '誰がこっそり「いいね」したの？';
	@override String get dialogDescription => '誰か気になる？この「いいねアルバム」をめくってみよう～';
	@override String get closeTooltip => '閉じる';
	@override String get retry => '再試行';
	@override String get noLikesYet => 'まだ誰もここに現れていません。最初の一人になりましょう！';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => '${page} / ${totalPages} ページ · 合計 ${totalCount} 人';
	@override String get prevPage => '前のページ';
	@override String get nextPage => '次のページ';
}

// Path: forum.sitewide
class _TranslationsForumSitewideJa extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get badge => '全体';
	@override String get title => '全体お知らせ';
	@override String get readMore => '全文表示';
}

// Path: forum.errors
class _TranslationsForumErrorsJa extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'カテゴリを選択してください';
	@override String get threadLocked => 'このスレッドはロックされています。';
}

// Path: forum.groups
class _TranslationsForumGroupsJa extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get administration => '管理';
	@override String get global => 'グローバル';
	@override String get chinese => '中国語';
	@override String get japanese => '日本語';
	@override String get korean => '韓国語';
	@override String get other => 'その他';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesJa extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'お知らせ';
	@override String get feedback => 'フィードバック';
	@override String get support => 'サポート';
	@override String get general => '一般';
	@override String get guides => 'ガイド';
	@override String get questions => '質問';
	@override String get requests => 'リクエスト';
	@override String get sharing => 'シェア';
	@override String get general_zh => '一般';
	@override String get questions_zh => '質問';
	@override String get requests_zh => 'リクエスト';
	@override String get support_zh => 'サポート';
	@override String get general_ja => '一般';
	@override String get questions_ja => '質問';
	@override String get requests_ja => 'リクエスト';
	@override String get support_ja => 'サポート';
	@override String get korean => '韓国語';
	@override String get other => 'その他';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsJa extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get announcements => '公式の重要なお知らせと通知';
	@override String get feedback => 'サイトの機能やサービスに対するフィードバック';
	@override String get support => 'サイト関連の問題を解決する手助け';
	@override String get general => 'あらゆる話題を議論する';
	@override String get guides => '経験やチュートリアルを共有する';
	@override String get questions => '疑問を提起する';
	@override String get requests => 'リクエストを投稿する';
	@override String get sharing => '面白いコンテンツを共有する';
	@override String get general_zh => 'あらゆる話題を議論する';
	@override String get questions_zh => '疑問を提起する';
	@override String get requests_zh => 'リクエストを投稿する';
	@override String get support_zh => 'サイト関連の問題を解決する手助け';
	@override String get general_ja => 'あらゆる話題を議論する';
	@override String get questions_ja => '疑問を提起する';
	@override String get requests_ja => 'リクエストを投稿する';
	@override String get support_ja => 'サイト関連の問題を解決する手助け';
	@override String get korean => '韓国語に関する議論';
	@override String get other => 'その他の未分類のコンテンツ';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsJa extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'サポートされていない通知タイプ';
	@override String get unknownUser => '未知ユーザー';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'サポートされていない通知タイプ: ${type}';
	@override String get unknownNotificationType => '未知通知タイプ';
}

// Path: conversation.errors
class _TranslationsConversationErrorsJa extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'ユーザーを選択してください';
	@override String get pleaseEnterATitle => 'タイトルを入力してください';
	@override String get clickToSelectAUser => 'ユーザーを選択してください';
	@override String get loadFailedClickToRetry => '読み込みに失敗しました。クリックして再試行';
	@override String get loadFailed => '読み込みに失敗しました';
	@override String get clickToRetry => 'クリックして再試行';
	@override String get noMoreConversations => 'もう会話がありません';
}

// Path: splash.errors
class _TranslationsSplashErrorsJa extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => '初期化に失敗しました。アプリを再起動してください';
}

// Path: download.errors
class _TranslationsDownloadErrorsJa extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => '画像モデルが見つかりません';
	@override String get downloadFailed => 'ダウンロードに失敗しました';
	@override String get videoInfoNotFound => 'ビデオ情報が見つかりません';
	@override String get unknown => '不明';
	@override String get downloadTaskAlreadyExists => 'ダウンロードタスクが既に存在します';
	@override String get downloadTaskSavePathConflict => '保存先パスは既に他のタスクで使用されています';
	@override String get videoAlreadyDownloaded => 'ビデオはすでにダウンロードされています';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'ダウンロードタスクの追加に失敗しました: ${errorInfo}';
	@override String get userPausedDownload => 'ユーザーがダウンロードを一時停止';
	@override String fileSystemError({required Object errorInfo}) => 'ファイルシステムエラー: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => '不明なエラー: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'ファイルの書き込みに失敗しました: ${errorInfo}';
	@override String get connectionTimeout => '接続タイムアウト';
	@override String get sendTimeout => '送信タイムアウト';
	@override String get receiveTimeout => '受信タイムアウト';
	@override String serverError({required Object errorInfo}) => 'サーバーエラー: ${errorInfo}';
	@override String get unknownNetworkError => '不明なネットワークエラー';
	@override String get sslHandshakeFailed => 'SSLハンドシェイクに失敗しました、ネットワーク環境を確認してください';
	@override String get connectionFailed => '接続に失敗しました、ネットワークを確認してください';
	@override String get serviceIsClosing => 'ダウンロードサービスが閉じています';
	@override String get partialDownloadFailed => '部分内容ダウンロード失敗';
	@override String get noDownloadTask => 'ダウンロードタスクがありません';
	@override String get taskNotFoundOrDataError => 'タスクが見つかりませんまたはデータが正しくありません';
	@override String get copyDownloadUrlFailed => 'ダウンロードリンクのコピーに失敗しました';
	@override String get fileNotFound => 'ファイルが見つかりません';
	@override String get openFolderFailed => 'ファイルフォルダーを開くのに失敗しました';
	@override String openFolderFailedWithMessage({required Object message}) => 'ファイルフォルダーを開くのに失敗しました: ${message}';
	@override String get directoryNotFound => 'ディレクトリが見つかりません';
	@override String get copyFailed => 'コピーに失敗しました';
	@override String get openFileFailed => 'ファイルを開くのに失敗しました';
	@override String openFileFailedWithMessage({required Object message}) => 'ファイルを開くのに失敗しました: ${message}';
	@override String get playLocallyFailed => 'ローカル再生に失敗しました';
	@override String playLocallyFailedWithMessage({required Object message}) => 'ローカル再生に失敗しました: ${message}';
	@override String get noDownloadSource => 'ダウンロードソースがありません';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'ダウンロードソースがありません。情報を読み込んだ後、もう一度お試しください。';
	@override String get noActiveDownloadTask => 'ダウンロード中のタスクがありません';
	@override String get noFailedDownloadTask => '失敗したタスクがありません';
	@override String get noCompletedDownloadTask => '完了したタスクがありません';
	@override String get taskAlreadyCompletedDoNotAdd => 'タスクはすでに完了しています。再度追加しないでください';
	@override String get linkExpiredTryAgain => 'リンクが期限切れです。新しいダウンロードリンクを取得しています';
	@override String get linkExpiredTryAgainSuccess => 'リンクが期限切れです。新しいダウンロードリンクを取得しました';
	@override String get linkExpiredTryAgainFailed => 'リンクが期限切れです。新しいダウンロードリンクを取得に失敗しました';
	@override String get taskDeleted => 'タスクが削除されました';
	@override String unsupportedImageFormat({required Object format}) => 'サポートされていない画像形式: ${format}';
	@override String get deleteFileError => 'ファイルの削除に失敗しました。ファイルが他のプロセスによって使用されている可能性があります';
	@override String get deleteTaskError => 'タスクの削除に失敗しました';
	@override String get taskNotFound => 'タスクが見つかりません';
	@override String get canNotRefreshVideoTask => 'ビデオタスクの更新に失敗しました';
	@override String get videoRemovedCanNotRefresh => 'この動画は削除されたか存在しないため、ダウンロードリンクを再取得できません';
	@override String get videoInaccessibleCanNotRefresh => 'この動画にアクセスできません。非公開になっているか、再ログインが必要な可能性があります';
	@override String get videoQualityGone => 'この画質は提供されなくなりました。ダウンロードを追加し直してください';
	@override String get refreshLinkNetworkFailed => 'ネットワークエラーのため、現在ダウンロードリンクを再取得できません。しばらくしてから再試行してください';
	@override String get taskAlreadyProcessing => 'タスクはすでに処理中です';
	@override String get failedToLoadTasks => 'タスクの読み込みに失敗しました';
	@override String partialDownloadFailedWithMessage({required Object message}) => '部分ダウンロードに失敗しました: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'サポートされていない画像形式: ${extension}, デバイスにダウンロードして表示することができます';
	@override String get imageLoadFailed => '画像の読み込みに失敗しました';
	@override String get pleaseTryOtherViewer => '他のビューアーを使用してみてください';
}

// Path: download.timeline
class _TranslationsDownloadTimelineJa extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get today => '今日';
	@override String get yesterday => '昨日';
	@override String get thisWeek => '今週';
	@override String get thisMonth => '今月';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesJa extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get network => 'ネットワークエラー、再試行できます';
	@override String get serverRejected => 'サーバーに拒否されました。再ログインが必要かもしれません';
	@override String get notFound => 'リソースが失効または削除されました';
	@override String get diskFull => 'ストレージの空き容量が不足しています';
	@override String get fileInUse => 'ファイルが他のプログラムに使用されています';
	@override String get permission => '書き込み権限がありません';
	@override String get cancelled => 'キャンセルされました';
	@override String get unknown => '不明なエラー';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedJa extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '前回終了時に未完了だったタスク ${num} 件を一時停止しました';
	@override String get resume => 'すべて再開';
	@override String get dismiss => '閉じる';
}

// Path: download.actions
class _TranslationsDownloadActionsJa extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get open => '開く';
	@override String get play => '再生';
	@override String get openWith => '他のアプリで開く';
	@override String get redownload => '再ダウンロード';
	@override String get relocate => 'ファイルを移動…';
	@override String get categorize => '分類…';
	@override String get viewOnline => 'オンラインページを見る';
	@override String get delete => '削除…';
	@override String redownloadStarted({required Object count}) => '${count} 件の再ダウンロードを開始しました';
	@override String get redownloadNone => '再ダウンロードできる項目がありません';
	@override String deleteTitle({required Object count}) => '${count} 件のダウンロードを削除しますか？';
	@override String deleteSummary({required Object count, required Object size}) => '${count} 件 · ${size}';
	@override String deleteSummaryNoSize({required Object count}) => '${count} 件';
	@override String deleteGalleryNote({required Object count}) => 'うち ${count} 件のギャラリーはサイズに含まれていません';
	@override String get deleteFiles => 'ディスク上のファイルも削除';
	@override String get deleteFilesDesc => 'オフにするとリストの記録だけを削除し、ファイルはそのまま残ります';
	@override String get deleteFilesAllMissing => 'ファイルはすでにないため、記録だけを削除します';
	@override String deleteDone({required Object count}) => '${count} 件を削除しました';
	@override String deletePartial({required Object failed}) => '${failed} 件のファイルを削除できませんでした（使用中の可能性があります）。記録は残しています';
	@override String get removeRecordAnyway => '記録だけ削除';
	@override String get fileMissing => 'ファイルが見つかりません';
	@override String get filePending => '今はファイルが見つかりません（復元できる可能性があります）';
	@override String get statusActive => '進行中';
	@override String get statusCompleted => '完了';
	@override String get needsAttention => '要対応';
	@override String needsAttentionCount({required Object count}) => '要対応 · ${count}';
	@override String get organize => '整理';
	@override String get checkIntegrity => 'ファイルの整合性をチェック…';
	@override String get migrateToCurrent => '現在のダウンロードフォルダへ移動…';
	@override String get migrateNone => 'すべてのダウンロード済みコンテンツは現在のダウンロードフォルダにあります';
}

// Path: download.notice
class _TranslationsDownloadNoticeJa extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String failed({required Object count}) => '${count} 件のダウンロードが失敗しました';
	@override String get retryAll => 'すべて再試行';
	@override String get view => '表示';
	@override String missing({required Object count}) => 'ダウンロード済みの ${count} 件のファイルが見つかりません';
	@override String get handle => '対処…';
	@override String outside({required Object count}) => '古いダウンロードフォルダに ${count} 件残っています';
	@override String get migrate => '移動';
	@override String get dismiss => '閉じる';
}

// Path: download.deleteByDate
class _TranslationsDownloadDeleteByDateJa extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => '日付で削除';
	@override String get dialogTitle => '日付で削除';
	@override String get description => '作成日でダウンロードタスクを一括削除します。使用中のファイルはスキップされ、ファイルが既に存在しないタスクは整理されます。';
	@override String get modeRange => '期間';
	@override String get modeDays => '日数で指定';
	@override String get startDate => '開始日';
	@override String get endDate => '終了日';
	@override String get notSet => '未設定';
	@override String get daysUnit => '日';
	@override String olderThanDaysHint({required Object days}) => '${days}日前より古いタスクを削除';
	@override String get noMatch => '条件に一致するタスクがありません';
	@override String get invalidRange => '開始日は終了日以前にしてください';
	@override String get confirmTitle => '削除の確認';
	@override String confirmContent({required Object count}) => '${count}件のダウンロードタスクとそのファイルを削除しますか？この操作は取り消せません。';
	@override String deleting({required Object done, required Object total}) => '削除中 ${done}/${total}…';
	@override String resultSuccess({required Object count}) => '${count}件のタスクを削除しました';
	@override String resultPartial({required Object deleted, required Object skipped}) => '${deleted}件を削除、${skipped}件をスキップ（使用中）';
}

// Path: download.relocation
class _TranslationsDownloadRelocationJa extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get moveFiles => 'ファイルを移動';
	@override String get moveFilesEllipsis => 'ファイルを移動…';
	@override String get chooseDestination => 'ファイルの移動先';
	@override String get currentDownloadDir => '現在のダウンロードフォルダ';
	@override String get otherFolder => '別のフォルダを選択…';
	@override String get pickerUnsupported => 'この端末ではフォルダを選択できません。ダウンロードはアプリ専用フォルダに保存されます。';
	@override String get planning => 'ファイルを確認しています…';
	@override String get confirmTitle => 'ファイルを移動しますか？';
	@override String get confirmNote => 'ディスク上でファイルを移動します。視聴位置、VR 設定、お気に入りも一緒に引き継がれます。';
	@override String get nothingToMove => '選択した項目はどれも移動できません。各項目の理由は下を確認してください。';
	@override String get move => '移動';
	@override String moving({required Object done, required Object total}) => '移動中 ${done}/${total}';
	@override String get stop => '停止';
	@override String get stopping => '現在の項目が終わったら停止します…';
	@override String get resultTitle => '移動が完了しました';
	@override String resultMoved({required Object count}) => '${count} 件を移動しました';
	@override String get cancelled => '停止しました。移動済みの項目はすべて完全です。';
	@override String get alreadyRunning => '別の移動がすでに実行中です';
	@override String get destination => '移動先';
	@override String get statMove => '移動予定';
	@override String get statSkip => 'スキップ';
	@override String get statRenamed => '名前変更';
	@override String get statMoved => '移動済み';
	@override String get statFailed => '未移動';
	@override String get statLeftover => '残存';
	@override String get sectionMove => '移動する項目';
	@override String get sectionSkip => 'スキップする項目';
	@override String get sectionMoved => '移動済み';
	@override String get sectionFailed => '移動されなかった項目（元の場所のまま）';
	@override String get sectionLeftover => '削除しきれなかった古いフォルダ';
	@override String get leftoverHint => '新しい場所のコピーは完全です。これらの残りは削除して構いません。';
	@override String get from => '移動元';
	@override String get to => '移動先';
	@override String renamedBadge({required Object name}) => '同じ名前があるため「${name}」として保存します';
	@override String get showPaths => 'パスを表示';
	@override String get hidePaths => 'パスを隠す';
	@override String get revealInFolder => 'フォルダで表示';
	@override String get copyPath => 'パスをコピー';
	@override String get pathCopied => 'パスをコピーしました';
	@override String stateDownloading({required Object percent}) => 'ダウンロード中 ${percent}%';
	@override String get statePending => 'ダウンロード待ち';
	@override String statePaused({required Object percent}) => '${percent}% で一時停止中';
	@override String get stateFailed => 'ダウンロード失敗';
	@override String get skipAlreadyThere => 'すでにこのフォルダにあります';
	@override String get skipInsideSource => '移動先がこのギャラリー自身のフォルダの中にあります';
	@override String get reasonBusy => '別の操作（削除または移動）を実行中';
	@override String get reasonSourceLocked => 'ファイルが使用中（再生中など）のため元の場所から削除できませんでした。何も変更していません。';
	@override String get reasonNoSpace => '移動先の空き容量が不足したため、残りをすべて停止しました。';
	@override String get reasonVerifyFailed => 'コピーしたファイルのサイズが元と一致しなかったため、コピーを破棄しました。';
	@override String get reasonIoError => 'ファイルの読み書きに失敗しました。何も変更していません。';
	@override String systemMessage({required Object message}) => 'システムメッセージ：${message}';
	@override String outsideTitle({required Object count}) => 'ダウンロード済みの ${count} 件がこのフォルダの外にあります';
	@override String get outsideSubtitle => '今の場所でもそのまま再生できます。ここへ移動するとひとまとめにできます。';
	@override String get moveHere => 'ここへ移動';
	@override String get missingTitle => 'ファイルが見つかりません';
	@override String get recordedLocation => '記録されている場所';
	@override String get legendExists => '存在する';
	@override String get legendMissing => '見つからない';
	@override String diagVolume({required Object volume}) => 'ストレージ「${volume}」が利用できません。SD カードや外付けドライブが接続されていない可能性があります。';
	@override String diagVolumeShort({required Object volume}) => 'ストレージ「${volume}」が未接続';
	@override String get diagContainer => 'アプリの更新後、システムがアプリの保存場所を移動しました。ファイルはここにあります：';
	@override String get diagContainerShort => '更新後に保存場所が変わりました';
	@override String get diagNoAccess => 'この場所を読み取る権限がありません。「すべてのファイルへのアクセス」を許可してから再確認してください。';
	@override String get diagNoAccessShort => 'この場所を読み取る権限がありません';
	@override String diagFolder({required Object folder}) => 'フォルダ「${folder}」はもう存在しません。';
	@override String diagFolderShort({required Object folder}) => 'フォルダ「${folder}」が存在しません';
	@override String diagFile({required Object name}) => 'フォルダはありますが、「${name}」が中にありません。';
	@override String get diagFileShort => '元のフォルダにありません';
	@override String get diagCandidates => 'そのフォルダに、これと思われるもの（名前が変わった可能性）が見つかりました：';
	@override String get diagNoCandidates => 'そのフォルダに同じサイズのファイルはありませんでした。';
	@override String get useThis => 'これを使う';
	@override String get fixPath => 'パスを修正';
	@override String get checkAgain => '再確認';
	@override String get grantPermission => '権限を許可';
	@override String get locate => '別のフォルダで探す…';
	@override String get deleteRecord => '記録を削除';
	@override String get locateNotFound => 'そのフォルダにこのダウンロードのファイルはありません';
	@override String get located => '見つかりました。記録を新しい場所に更新しました';
	@override String get stillMissing => 'まだ見つかりません';
	@override String downloadedOn({required Object date}) => '${date} にダウンロード';
	@override String galleryImages({required Object count}) => '${count} 枚';
	@override String unfinishedDownloading({required Object percent}) => 'ダウンロード中 ${percent}%：一時停止してから途中のデータごと移動し、移動後に再開';
	@override String get unfinishedPending => 'ダウンロード待ち：移動後にもう一度キューに入れます';
	@override String unfinishedPaused({required Object percent}) => '${percent}% で一時停止中：途中のデータごと移動し、一時停止のまま';
	@override String get unfinishedFailed => 'ダウンロード失敗：途中のデータごと移動';
	@override String get noDataYet => 'まだ何もダウンロードされていないため、保存先だけ変更します';
	@override String missingGroup({required Object count}) => 'ファイルが見つからない ${count} 件';
	@override String get missingSkip => 'そのまま';
	@override String get missingRedownload => '移動先に再ダウンロード';
	@override String get missingRemove => '記録を削除';
	@override String missingRemoveVolumeNote({required Object count}) => 'うち ${count} 件は未接続のストレージ上にあるため削除しません';
	@override String failedGroup({required Object count}) => 'ダウンロード失敗の ${count} 件';
	@override String get failedMoveOnly => '移動のみ';
	@override String get failedMoveAndRetry => '移動して再ダウンロード';
	@override String get failedRemove => 'タスクを削除';
	@override String get failedRemoveNote => '途中までダウンロードしたファイルも削除されます';
	@override String get execute => '実行';
	@override String get actionWillRedownload => '移動先に再ダウンロードします';
	@override String get actionWillRemove => 'この記録を削除します';
	@override String get actionWillKeep => 'ストレージ未接続のため残します';
	@override String get actionWillRetry => '移動後に再ダウンロード';
	@override String get actionWillRemoveTask => 'このタスクを削除します';
	@override String get statRedownload => '再ダウンロード';
	@override String get statRemoved => '削除済み';
	@override String get sectionRedownloaded => '再ダウンロードを開始しました';
	@override String get sectionRedownloadFailed => '再ダウンロードを開始できませんでした';
	@override String get redownloadFailedHint => 'ダウンロードリンクが無効になっている可能性があります（作品が削除または非公開）。後でダウンロード一覧から再試行できます。';
	@override String get sectionRemoved => '削除済み';
	@override String get sectionKept => '残した項目（ストレージ未接続）';
	@override String get redownload => '再ダウンロード';
	@override String get redownloadStarted => '再ダウンロードを開始しました';
	@override String get redownloadNotStarted => '再ダウンロードを開始できませんでした';
	@override String get diagFileShortWithCandidates => '元のフォルダに同じサイズのファイルがあります（名前変更の可能性）';
	@override String get cleanupMenu => '無効な記録を整理…';
	@override String cleanupScanning({required Object done, required Object total}) => '確認中 ${done}/${total}';
	@override String get cleanupTitle => '無効な記録を整理';
	@override String cleanupNone({required Object count}) => '完了済みの ${count} 件を確認しました。ファイルはすべてあります。';
	@override String get statChecked => '確認済み';
	@override String get statMissing => '見つからない';
	@override String get statKeep => '残す推奨';
	@override String get cleanupGroupGone => 'ファイルがありません';
	@override String get cleanupGroupRecoverable => 'まだ取り戻せる可能性あり';
	@override String get cleanupRecoverableHint => 'ストレージ未接続、権限なし、または名前変更の可能性があるため、既定では選択しません。項目を開くと詳細の確認と復旧ができます。';
	@override String get selectAll => 'すべて選択';
	@override String get selectNone => '選択解除';
	@override String removeSelected({required Object count}) => '選択を削除（${count}）';
	@override String redownloadSelected({required Object count}) => '選択を再ダウンロード（${count}）';
	@override String processing({required Object done, required Object total}) => '処理中 ${done}/${total}';
	@override String cleanupRemoved({required Object count}) => '${count} 件の記録を削除しました';
	@override String cleanupRedownloaded({required Object count}) => '${count} 件の再ダウンロードを開始しました';
	@override String get tapForDetail => '詳細';
	@override String get deleteRecordFailed => '記録を削除できませんでした。後でもう一度お試しください';
	@override String get sectionNotAttempted => '未処理（停止したため元のまま）';
	@override String unexpectedError({required Object message}) => 'エラーで停止しました：${message}。移動済みの項目はすべて完全です。';
}

// Path: download.category
class _TranslationsDownloadCategoryJa extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'カテゴリーの管理';
	@override String get label => 'カテゴリー';
	@override String get uncategorized => '未分類';
	@override String get manage => '管理';
	@override String get createShortcut => '新規作成';
	@override String get newCategoryHint => '新しいカテゴリー名';
	@override String get createSuccess => 'カテゴリーを作成しました';
	@override String get createFailed => 'カテゴリーの作成に失敗しました';
	@override String get nameEmpty => 'カテゴリー名を入力してください';
	@override String get emptyHint => 'カテゴリーがまだありません。作成してダウンロードを整理しましょう。';
	@override String get moveTo => 'カテゴリーへ移動';
	@override String moveToWithCount({required Object count}) => '${count}件をカテゴリーへ移動…';
	@override String moveSuccess({required Object title}) => '「${title}」へ移動しました';
	@override String get moveToUncategorizedSuccess => '「未分類」へ移動しました';
	@override String get moveFailed => '移動に失敗しました';
	@override String get renameTitle => 'カテゴリー名の変更';
	@override String get renameHint => 'カテゴリー名を入力';
	@override String get renameSuccess => '名前を変更しました';
	@override String get renameFailed => '名前の変更に失敗しました';
	@override String get deleteTitle => 'カテゴリーの削除';
	@override String deleteConfirm({required Object title, required Object count}) => 'カテゴリ「${title}」を削除しますか？中の ${count} 件は「未分類」へ移動し、ファイルは削除されません。';
	@override String get deleteSuccess => 'カテゴリーを削除しました';
	@override String get deleteFailed => 'カテゴリーの削除に失敗しました';
}

// Path: download.location
class _TranslationsDownloadLocationJa extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sectionTitle => '保存先';
	@override String get behaviorSection => 'ダウンロードの動作';
	@override String get namingSection => 'ファイル名';
	@override String get advancedSection => '詳細';
	@override String get advancedSubtitle => '書き込み診断などのツール';
	@override String get volumeInternal => '内部ストレージ';
	@override String get volumeSdCard => 'SD カード';
	@override String get volumeExternalDrive => '外付けドライブ';
	@override String get appSpace => 'アプリ専用領域';
	@override String get downloadsFolder => 'ダウンロード';
	@override String get askEveryTime => '毎回確認する';
	@override String askEveryTimeDesc({required Object location}) => 'ダウンロードのたびに保存先を選びます。一括ダウンロードは ${location} に保存されます';
	@override String freeSpace({required Object size}) => '空き ${size}';
	@override String get statusWritable => '書き込み可';
	@override String get statusNeedsPermission => '許可が必要';
	@override String get statusFallback => '一時的に別の場所へ保存';
	@override String get statusLowSpace => '空き容量不足';
	@override String get statusChecking => '確認中';
	@override String get grant => '許可';
	@override String get fix => '修復';
	@override String get changeLocation => '保存先を変更';
	@override String get openInFileManager => 'ファイルマネージャーで開く';
	@override String get moreActions => 'その他';
	@override String get copyPath => 'パスをコピー';
	@override String get pathCopied => 'パスをコピーしました';
	@override String get manualInput => 'パスを手動入力（上級者向け）';
	@override String get restoreDefault => 'デフォルトに戻す';
	@override String get runDiagnostics => '診断を実行';
	@override String get restoredDefault => 'デフォルトの保存先に戻しました';
	@override String get sheetTitle => '保存先を選択';
	@override String get chooseOtherFolder => '別のフォルダを選択…';
	@override String get chooseOtherFolderDesc => 'システムのファイル選択画面から選びます';
	@override String get optionRecommendedDesc => 'おすすめ · 許可不要';
	@override String get optionRecommendedLegacyDesc => 'おすすめ · ストレージの許可が必要';
	@override String get optionAppPrivateDesc => 'アンインストール時に削除 · ギャラリーに表示されません';
	@override String get optionRemovableDesc => '「全ファイルへのアクセス」が必要';
	@override String get optionDesktopDownloadsDesc => 'おすすめ · システムのダウンロードフォルダ';
	@override String get optionAskEveryTimeDesc => 'ダウンロードのたびにフォルダを選びます';
	@override String get current => '現在';
	@override String get fallbackBanner => '選択したフォルダが一時的に使えなかったため、前回のダウンロードはアプリ領域に保存されました。';
	@override String get fallbackReasonPermission => 'ストレージの許可がありません';
	@override String get fallbackReasonVolumeMissing => 'ストレージが接続されていません';
	@override String get fallbackReasonCannotCreate => 'フォルダを作成できません';
	@override String get fallbackReasonNotWritable => 'フォルダに書き込めません';
	@override String fallbackDetail({required Object reason}) => '一時的に別の場所へ保存中：${reason}';
	@override String get errorUnresolvable => 'この場所はクラウドドライブや他のアプリのもので、直接書き込めません。端末のストレージか SD カードのフォルダを選んでください。';
	@override String get errorNotWritable => 'このフォルダには書き込めません（読み取り専用、システムで保護されている、または切断されています）。保存先は変更されていません。';
	@override String get errorVolumeMissing => 'このストレージが見つかりません（取り外されたか、接続されていません）。保存先は変更されていません。';
	@override String get permissionTitle => '許可が必要です';
	@override String get permissionAllFiles => 'このフォルダに書き込むには「全ファイルへのアクセス」が必要です。許可したくない場合は「ダウンロード › LoveIwara」を使えます。';
	@override String get permissionLegacy => 'このフォルダに書き込むにはストレージの許可が必要です。許可したくない場合はアプリ専用領域を使えます。';
	@override String get useDownloadsInstead => 'ダウンロード › LoveIwara を使う';
	@override String get useAppSpaceInstead => 'アプリ専用領域を使う';
	@override String get goToSettings => '許可する';
	@override String get permissionDenied => '許可されなかったため、保存先は変更されていません。';
	@override String get checking => 'この場所を確認しています…';
	@override String get confirmTitle => 'この場所を使いますか？';
	@override String confirmFree({required Object size}) => '空き容量 ${size}';
	@override String confirmOutside({required Object count}) => 'ダウンロード済みの ${count} 件は元の場所に残っています';
	@override String get confirmOutsideDesc => '今後のダウンロードは新しい場所に保存されます。ダウンロード済みのものはどうしますか？';
	@override String get moveThem => '移動する';
	@override String get keepThem => '元の場所に残す';
	@override String get decideLater => 'あとで決める';
	@override String get useThisLocation => 'この場所を使う';
	@override String get locationChanged => '保存先を変更しました';
	@override String get manualTitle => 'パスを手動入力';
	@override String get manualLabel => 'フォルダのパス';
	@override String get manualHint => '例: /storage/emulated/0/Download/LoveIwara';
	@override String get manualSubmit => '確認して使う';
	@override String get manualEmpty => 'パスを入力してください';
	@override String get manualNotAbsolute => '完全な絶対パスを入力してください';
	@override String get fixStillFailing => 'この場所はまだ使えません。別の場所を選んでください。';
	@override String get fixed => '保存先が使えるようになりました';
}

// Path: download.batchDownload
class _TranslationsDownloadBatchDownloadJa extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '一括ダウンロード';
	@override String get downloadTaskAlreadyRunning => 'タスクが実行中です。しばらくお待ちください';
	@override String get userCancelled => 'ユーザーによるキャンセル';
	@override String get failedToGetVideoInfo => '動画情報の取得に失敗しました';
	@override String get failedToGetVideoSource => '動画ソースの取得に失敗しました';
	@override String get failedToGetGalleryInfo => 'ギャラリー情報の取得に失敗しました';
	@override String get galleryNoImages => 'ギャラリーに画像がありません';
	@override String get failedToGetSavePath => '保存パスの取得に失敗しました';
	@override String batchDownloadFailedWithException({required Object exception}) => '一括ダウンロードに失敗しました: ${exception}';
	@override String get selectQuality => '品質を選択';
	@override String get downloading => 'ダウンロード中';
	@override String get downloadResult => 'ダウンロード結果';
	@override String selectedVideosCount({required Object count}) => '${count}件の動画を選択';
	@override String selectedGalleriesCount({required Object count}) => '${count}件のギャラリーを選択';
	@override String get qualityNote => '選択した品質が利用できない場合は、最適な品質が使用されます';
	@override String progress({required Object current, required Object total}) => '処理中 ${current}/${total}';
	@override String get queued => 'キュー追加';
	@override String get success => '成功';
	@override String get skipped => 'スキップ';
	@override String get failed => '失敗';
	@override String get failureDetails => '失敗の詳細';
	@override String get reasonPrivateVideo => 'プライベート動画';
	@override String get reasonAlreadyExists => 'タスクが既に存在';
	@override String get reasonNoSource => 'ダウンロードソースなし';
	@override String get reasonNoSavePath => '保存パスを取得できません';
	@override String get reasonOther => 'その他のエラー';
	@override String get startDownload => 'ダウンロード開始';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsJa extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get addFailed => '追加に失敗しました';
	@override String get addSuccess => '追加に成功しました';
	@override String get deleteFolderFailed => 'フォルダーの削除に失敗しました';
	@override String get deleteFolderSuccess => 'フォルダーの削除に成功しました';
	@override String get folderNameCannotBeEmpty => 'フォルダー名を入力してください';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesJa extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI 推論 (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude 推論 (extended thinking)';
	@override String get gemini => 'Google Gemini (ネイティブ)';
	@override String get geminiReasoning => 'Google Gemini 推論 (thinking)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek 推論 (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeJa extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => '再生の通知: ${message}';
	@override String get networkUnstable => '通信をご確認ください。再生が途切れる場合があります';
	@override String get audioTrackUnavailable => '音声を再生できません。映像はこのまま続きます';
	@override String get hardwareDecodeFellBack => 'ソフトウェアデコードに切り替え。電池消費が増えます';
	@override String get videoDecodeProblem => '画質の切り替えをお試しください。映像が乱れます';
	@override String get repeatedPlaybackProblems => 'ログを書き出して報告してください。エラーが続いています';
	@override String get issuesSheetTitle => '再生の問題';
	@override String issueOccurrences({required Object count}) => '${count} 回発生';
	@override String issueAtPosition({required Object position}) => '位置 ${position}';
	@override String get noIssuesRecorded => '記録された問題はありません';
	@override String get exportLogsAction => 'ログを書き出す';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertJa extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => '書き込み失敗';
	@override String get sinkDegradedTitle => 'ログ書き込みが劣化';
	@override String get sinkDegradedDetail => 'ファイル sink が degraded 状態です';
	@override String get queueBacklogTitle => '書き込みキュー滞留';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (しきい値=${threshold}, メモリ使用量が増加する可能性)';
	@override String get highFlushLatencyTitle => '書き込み遅延が高い';
	@override String get droppedTooManyTitle => '破棄ログが多すぎます';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (しきい値=${threshold})';
	@override String get rateLimitedTitle => 'レート制限が発生';
	@override String get exportFailedTitle => 'ログエクスポート失敗';
	@override String get fileNearLimitTitle => 'ログファイルが上限付近';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (IO ローテーション負荷が増加)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastJa extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'ログサービスが初期化されていません';
	@override String get exportSuccess => 'ログをエクスポートしました。プライバシーを確認後、メールで送信してください';
	@override String exportFailed({required Object error}) => 'エクスポート失敗: ${error}';
	@override String get supportEmailCopied => 'メールアドレスをコピーしました。メールクライアントに貼り付けてログを添付してください';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesJa extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get relevance => '関連性';
	@override String get latest => '最新';
	@override String get views => '視聴回数';
	@override String get likes => 'いいね数';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeJa extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ようこそ';
	@override String get subtitle => 'パーソナライズ設定を始めましょう';
	@override String get description => '数ステップで最適な体験を提供します';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicJa extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '基本設定';
	@override String get subtitle => '体験をパーソナライズ';
	@override String get description => 'ご希望の機能設定を選択';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkJa extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ネットワーク設定';
	@override String get subtitle => 'ネットワークオプションを構成';
	@override String get description => 'ネットワーク環境に合わせて調整';
	@override String get tip => '設定後、再起動が必要です';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeJa extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'テーマ設定';
	@override String get subtitle => 'お好みの見た目を選択';
	@override String get description => 'ビジュアル体験をパーソナライズ';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerJa extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'プレーヤー設定';
	@override String get subtitle => '再生コントロールを構成';
	@override String get description => 'よく使う再生設定を素早く設定';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialJa extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '空間再生';
	@override String get subtitle => 'ヘッドセットでの再生と閲覧';
	@override String get description => 'ヘッドセットでは、動画もギャラリーもこの浮かぶパネル内ではなく空間に表示されます';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionJa extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '設定完了';
	@override String get subtitle => 'すぐに始められます';
	@override String get description => '関連規約をお読みの上ご同意ください';
	@override String get agreementTitle => '利用規約とコミュニティルール';
	@override String get agreementDesc => '本アプリをご利用になる前に、利用規約とコミュニティルールをよくお読みいただき、同意してください。良好な利用環境の維持に役立ちます。';
	@override String get checkboxTitle => '利用規約とコミュニティルールに同意しました';
	@override String get checkboxSubtitle => '不同意の場合、アプリを利用できません';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonJa extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'これらの設定はいつでも設定画面で変更できます';
	@override String get previousStep => '前のステップ';
	@override String get nextStep => '次のステップ';
	@override String get finishSetup => '設定を完了';
	@override String get agreeAgreementSnackbar => 'まず利用規約とコミュニティルールに同意してください';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsJa extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get highQuality => '高品質';
	@override String get fast => '高速';
	@override String get lite => '軽量';
	@override String get moreLite => 'より軽量';
	@override String get custom => 'カスタム';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsJa extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'ほとんどの1080pアニメ、特にぼかし、再サンプリング、圧縮アーティファクトを処理する場合に適しています。最高の知覚品質を提供します。';
	@override String get mode_b_hq => 'スケーリングによる軽度のぼかしやリンギング効果のあるアニメに適しています。リンギングとエイリアスを効果的に減らすことができます。';
	@override String get mode_c_hq => 'ほとんど欠陥のない高品質ソース（ネイティブ1080pアニメや映画など）に適しています。ノイズ除去を行い、最高のPSNRを提供します。';
	@override String get mode_a_a_hq => 'Mode Aの強化版で、究極の知覚品質を提供し、ほぼすべての劣化ラインを再構築できます。過度なシャープネスやリンギングが発生する可能性があります。';
	@override String get mode_b_b_hq => 'Mode Bの強化版で、より高い知覚品質を提供し、ラインをさらに最適化し、アーティファクトを減らします。';
	@override String get mode_c_a_hq => 'Mode Cの知覚品質強化版で、高いPSNRを維持しながら一部のラインデータルを再構築しようとします。';
	@override String get mode_a_fast => 'Mode Aの高速版で、品質とパフォーマンスのバランスが取れており、ほとんどの1080pアニメに適しています。';
	@override String get mode_b_fast => 'Mode Bの高速版で、軽度のアーティファクトとリンギングを処理し、オーバーヘッドが低い。';
	@override String get mode_c_fast => 'Mode Cの高速版で、高品質ソースの高速ノイズ除去とアップスケーリングに適しています。';
	@override String get mode_a_a_fast => 'Mode A+Aの高速版で、パフォーマンスに制約のあるデバイスでより高い知覚品質を追求します。';
	@override String get mode_b_b_fast => 'Mode B+Bの高速版で、パフォーマンスに制約のあるデバイスに強化されたライン修復とアーティファクト処理を提供します。';
	@override String get mode_c_a_fast => 'Mode C+Aの高速版で、高品質ソースを高速処理しながら軽度のライン修復を行います。';
	@override String get upscale_only_s => '最速のCNNモデルのみを使用してx2アップスケーリングを行い、修復とノイズ除去は行わず、最小限のパフォーマンスオーバーヘッド。';
	@override String get upscale_deblur_fast => '従来の非CNNアルゴリズムを使用して高速アップスケーリングとデブリングを行い、デフォルトのプレーヤーアルゴリズムよりも優れた効果で、非常に低いパフォーマンスオーバーヘッド。';
	@override String get restore_s_only => '最速のCNNモデルのみを使用して画像欠陥を修復し、アップスケーリングは行いません。ネイティブ解像度再生で品質を向上させたい場合に適しています。';
	@override String get denoise_bilateral_fast => '従来のバイラテラルフィルタリングを使用して高速ノイズ除去を行い、非常に高速で軽度のノイズ処理に適しています。';
	@override String get upscale_non_cnn => '従来の高速アルゴリズムを使用してアップスケーリングを行い、最小限のパフォーマンスオーバーヘッドでプレーヤーのデフォルトよりも優れた効果。';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + ライン暗化、高速モードAにライン暗化効果を追加し、ラインをより目立たせ、スタイライズ処理を行います。';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + ライン細化、高品質モードAにライン細化効果を追加し、より洗練された外観にします。';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesJa extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'CNNアップスケーリング (超高速)';
	@override String get upscale_deblur_fast => 'アップスケーリング & デブリング (高速)';
	@override String get restore_s_only => '復元 (超高速)';
	@override String get denoise_bilateral_fast => 'バイラテラルノイズ除去 (超高速)';
	@override String get upscale_non_cnn => '非CNNアップスケーリング (超高速)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + ライン暗化';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + ライン細化';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseJa extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'よく使う場所';
	@override String get sourcesSection => 'フォルダ';
	@override String get pin => 'よく使う場所に追加';
	@override String get unpin => 'よく使う場所から削除';
	@override String get pinned => 'よく使う場所に追加しました';
	@override String get unpinned => 'よく使う場所から削除しました';
	@override String folderCount({required Object count}) => '${count} 個のフォルダ';
	@override String videoCount({required Object count}) => '${count} 本の動画';
	@override String imageCount({required Object count}) => '${count} 枚の画像';
	@override String get emptyFolder => 'このフォルダは空です';
	@override String get videosSection => '動画';
	@override String get imagesSection => '画像';
	@override String get galleriesSection => 'ギャラリー';
	@override String get filterAll => 'すべて';
	@override String get searchInFolder => 'このフォルダ内を検索';
	@override String get searchHint => '名前で検索';
	@override String get clearSearch => '検索をクリア';
	@override String searchNoResult({required Object query}) => '「${query}」に一致するものはありません';
	@override String viewAllFolders({required Object count}) => '${count} 件のフォルダをすべて表示';
	@override String viewAllVideos({required Object count}) => '${count} 件の動画をすべて表示';
	@override String viewAllImages({required Object count}) => '${count} 枚の画像をすべて表示';
	@override String viewAllGalleries({required Object count}) => '${count} 件のギャラリーをすべて表示';
	@override String get location => '場所';
	@override String get sourceMissing => 'このソースはもうありません';
	@override String get notScannedYet => 'このフォルダはまだスキャンされていません';
	@override String get scanning => 'このフォルダーを読み込んでいます…';
	@override String get deleteFileTitle => 'このファイルを削除しますか？';
	@override String deleteFileBody({required Object name}) => '「${name}」はこの端末から完全に削除されます。元に戻せません。';
	@override String get hideFolder => 'このフォルダを隠す';
	@override String get unhideFolder => '非表示を解除';
	@override String get showHiddenFolders => '隠したフォルダを表示';
	@override String get includeDotFolders => '「.」で始まるフォルダもスキャン';
	@override String get dotFoldersIncluded => '「.」で始まるフォルダのスキャンを開始しました';
	@override String get dotFoldersExcluded => '「.」で始まるフォルダをスキャンしなくなりました';
	@override String get showDotFolders => '「.」で始まるフォルダを表示';
	@override String dotFoldersSkipped({required Object count}) => 'ここには「.」で始まる未スキャンのフォルダが ${count} 個あります';
	@override String get scanDotFoldersAction => 'このソースで有効にする';
	@override String get otherAppsPrivateNotice => 'Android 11 以降、他のアプリの Android/data・Android/obb 内のファイルはどのアプリからも読み取れず、本アプリでも回避できません。元のアプリで動画を Download などの共有フォルダにダウンロードまたはエクスポートしてから、そのフォルダを追加してください。再生中のキャッシュは通常分割されており、読み取れても再生できません。';
	@override String get folderHidden => '非表示にしました。スキャンもスキップします';
	@override String get folderUnhidden => '非表示を解除しました';
	@override String get hiddenFolderBadge => '非表示';
	@override String get deleteFolder => 'フォルダを削除';
	@override String get deleteFolderTitle => 'このフォルダを削除しますか？';
	@override String deleteFolderBody({required Object name}) => '「${name}」と中身のすべてがこの端末から完全に削除されます。元に戻せません。';
	@override String get deleteFolderIncludesOthers => '中にある他のファイルも一緒に削除されます';
	@override String get folderDeleted => 'フォルダを削除しました';
	@override String get deleteFolderFailed => '削除に失敗しました。権限がないか、中のファイルが使用中の可能性があります';
	@override String get deleteGalleryTitle => 'このギャラリーを削除しますか？';
	@override String deleteGalleryBody({required Object name}) => '「${name}」のダウンロード記録とローカル画像ファイルが削除されます。この操作は取り消せません。';
	@override String get galleryResourceMissing => 'ローカルリソースが存在しないため、記録を削除しました';
	@override String get viewDownloadDetail => 'ダウンロード詳細を表示';
	@override String get viewOnlineGallery => 'ウェブで表示';
	@override String get pickFolderTitle => 'フォルダーを選ぶ';
	@override String get useThisFolder => 'このフォルダーを使う';
	@override String get noSubfolders => 'サブフォルダーはありません';
	@override String get storageRoot => '端末のストレージ';
	@override String get homeFolder => 'ホームフォルダ';
	@override String get filesystemRoot => 'ルートディレクトリ';
	@override String get folderUnreadable => 'このフォルダーは読み取れません';
	@override String get setCover => 'サムネイルを設定';
	@override String get setAsFolderCover => 'フォルダーのサムネイルにする';
	@override String get folderCoverSet => 'フォルダーのサムネイルを更新しました';
	@override String get setFolderCoverPick => 'カバーに設定…';
	@override String get restoreAutoCover => '自動カバーに戻す';
	@override String get autoCoverRestored => '自動カバーに戻しました';
	@override String get rescanFolder => 'このフォルダを再スキャン';
	@override String get coverPickerTitle => 'フレームを選ぶ';
	@override String get folderCoverPickerTitle => 'カバーを選択';
	@override String get coverPickerEmpty => 'このフォルダにはまだ使える画像がありません。動画のサムネイルはバックグラウンドで生成中の可能性があります。';
	@override String get coverSaved => 'サムネイルを更新しました';
	@override String get coverSaveFailed => 'サムネイルを保存できませんでした';
	@override String get coverUnavailable => 'このファイルから映像を読み取れません';
	@override String get deleted => '削除しました';
	@override String get deleteFailed => '削除できませんでした。使用中か権限がない可能性があります';
	@override String get openFolder => '開く';
	@override String get favorite => 'お気に入りに追加';
	@override String get unfavorite => 'お気に入りから削除';
	@override String get favorited => 'お気に入りに追加しました';
	@override String get unfavorited => 'お気に入りから削除しました';
	@override String get sortBy => '並び替え';
	@override String get sortAscending => '昇順';
	@override String get sortDescending => '降順';
	@override String get sortFieldName => 'ファイル名';
	@override String get sortFieldModified => '更新日';
	@override String get sortFieldDuration => '再生時間';
	@override String get sortFieldSize => 'サイズ';
	@override String get sortFieldResolution => '解像度';
	@override String get sortFieldFileType => 'ファイル形式';
	@override String get sortFieldFps => 'フレームレート';
	@override String get sortFieldFavorited => 'お気に入り追加日';
	@override String get emptyAllVideos => '動画がまだ見つかりません。「フォルダ」から追加してください。';
	@override String get emptyAllImages => '画像がまだ見つかりません。「フォルダ」から追加してください。';
	@override String get emptyFavorites => 'お気に入りはまだありません。動画の「⋮」メニューから追加できます。';
	@override String get emptyPinned => 'よく使うフォルダはまだありません。「フォルダ」で長押しして「よく使う」に設定してください。';
	@override String get emptyDownloadedVideos => 'ダウンロード済みの動画はまだありません。';
	@override String get emptyDownloadedGalleries => 'ダウンロード済みのギャラリーはまだありません。';
	@override String get folderInfo => 'フォルダ情報';
	@override String get folderInfoName => '名前';
	@override String get folderInfoPath => 'パス';
	@override String get folderInfoSource => 'ソース';
	@override String get folderInfoContents => '内容';
	@override String get folderInfoSize => '使用容量';
	@override String get folderInfoScannedAt => '最終スキャン';
	@override String get folderInfoNeverScanned => 'まだスキャンしていません';
	@override String get folderInfoNoPath => 'このソースには開けるフォルダがありません';
	@override String get copyPath => 'パスをコピー';
	@override String get pathCopied => 'パスをコピーしました';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsJa extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get size => 'サイズ';
	@override String get resolution => '解像度';
	@override String get duration => '長さ';
	@override String get modified => '更新日時';
	@override String get lastPlayed => '最後に再生';
	@override String get neverPlayed => '未視聴';
	@override String get completed => '視聴済み';
}

// Path: localMedia.missing
class _TranslationsLocalMediaMissingJa extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'このファイルが見つかりません';
	@override String get rescanFolder => 'フォルダーを再スキャン';
	@override String get relistNas => 'このフォルダーを再読み込み';
	@override String get removeFromList => 'リストから削除';
	@override String get removed => 'リストから削除しました。ディスク上のファイルは変更していません';
	@override String get found => '見つかりました';
	@override String nasGone({required Object name}) => 'NAS 上に「${name}」が見つかりません。削除・移動・名前変更された可能性があります。このフォルダーを再読み込みすると、現在の中身を確認できます。';
}

// Path: localMedia.webdav
class _TranslationsLocalMediaWebdavJa extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get addNas => 'NAS に接続（WebDAV）';
	@override String get connectTitle => 'NAS に接続';
	@override String get editTitle => 'NAS に再ログイン';
	@override String get hint => 'NAS の管理画面で WebDAV サービスを有効にしてから、アドレスとアカウントを入力してください。';
	@override String get address => 'アドレス';
	@override String get addressHint => '例：192.168.1.10:5005';
	@override String get username => 'ユーザー名';
	@override String get password => 'パスワード';
	@override String get displayName => '名前（任意）';
	@override String get connect => '接続';
	@override String get invalidAddress => 'アドレスの形式が正しくありません';
	@override String get errorAuth => 'ユーザー名またはパスワードが違います';
	@override String get errorUnreachable => 'サーバーに接続できません。アドレスとポート、端末と NAS が同じネットワークにあるか確認してください';
	@override String get errorNotWebdav => 'このアドレスは WebDAV サービスではありません';
	@override String errorGeneric({required Object code}) => '接続に失敗しました（${code}）';
	@override String get errorCredUnreadable => '保存したパスワードを読み込めませんでした。しばらくしてから再試行してください';
	@override String get certTitle => 'このサーバーを信頼しますか？';
	@override String get certBody => 'サーバーの証明書はシステムに信頼されていません（NAS の自己署名証明書でよくあります）。下のフィンガープリントが NAS の管理画面の表示と一致するか確認してください：';
	@override String get certChangedBody => 'このサーバーの証明書は前回信頼したものと異なります。NAS の証明書を変更していない場合、なりすましの可能性があります。続行しないでください。';
	@override String get trust => '信頼する';
	@override String get pickRootTitle => '追加するフォルダーを選択';
	@override String get serverRoot => 'ルート';
	@override String get alreadyAdded => 'この NAS フォルダーは追加済みです';
	@override String get relogin => '再ログイン';
	@override String get stateAuthFailed => '再ログインが必要';
	@override String get stateCertUntrusted => 'サーバー証明書が変更されました';
	@override String get stateUnreachable => 'NAS に接続できません';
	@override String get stateCredUnreadable => 'パスワードを読み込めません';
	@override String get connected => '接続済み';
	@override String get errorForbidden => 'このアカウントには WebDAV のアクセス権がありません。NAS の WebDAV 設定で許可してください';
	@override String get errorTls => '安全な接続に失敗しました。アドレスの http:// / https:// が NAS の設定と一致しているか確認してください';
	@override String get errorTryHttps => 'NAS が HTTPS のみの場合は、アドレスの前に https:// を付けてください';
	@override String get previousStep => '戻る';
	@override String get bannerUnreachable => 'NAS に接続できません。前回の内容を表示しています';
	@override String get bannerAuthFailed => 'ログインが切れました。再ログインすると最新の内容が見られます';
	@override String get bannerCertUntrusted => 'NAS の証明書が変わりました。確認すると続行できます';
	@override String get bannerCredUnreadable => '保存したパスワードを読み取れませんでした。再ログインしてください';
}

// Path: settings.downloadSettings.pathTemplateEditor
class _TranslationsSettingsDownloadSettingsPathTemplateEditorJa extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'パステンプレート';
	@override String get subtitle => 'ダウンロードをサブフォルダへ自動整理';
	@override String get tabVideo => '動画';
	@override String get tabGallery => 'ギャラリー';
	@override String get tabImage => '単体画像';
	@override String get previewLabel => 'プレビュー · 実際に保存される名前';
	@override String get galleryPreviewLabel => 'プレビュー · ギャラリーテンプレート＝フォルダ名（内部画像はID名）';
	@override String get addFolder => 'フォルダ階層を追加';
	@override String get folderCapReached => 'フォルダ階層の上限に達しました';
	@override String get folderSegmentHint => '%authorcache・変数・固定文字列';
	@override String get fileSegmentHint => '例: %title_%quality';
	@override String videoCapNote({required Object max}) => '拡張子（.mp4）は自動で付きます · 段内で / を入力すると2階層に分かれます · 最大 ${max} 階層';
	@override String imageCapNote({required Object max}) => '元の拡張子は自動で付きます · 段内で / を入力すると2階層に分かれます · 最大 ${max} 階層';
	@override String galleryCapNote({required Object max}) => 'ギャラリーテンプレートはすべてフォルダ段（最大 ${max} 階層）· 内部画像は画像IDで命名されます';
	@override String get trayHint => 'タップでカーソル位置に挿入 · 長押しで説明';
	@override String get emptySegment => '空のセグメント';
	@override String get emptySegmentSaveBlocked => '保存できません：空のセグメントを削除するか内容を入力してください';
	@override String get tooManySegmentsSaveBlocked => '保存できません：パスのセグメント数が上限（最大4）を超えています。統合するか削減してください';
	@override String get templateInvalidSaveBlocked => '保存できません：テンプレートに使用できない文字が含まれています';
	@override String get variableInserted => '変数を挿入しました';
	@override String get savedToast => '保存しました · 今後のダウンロードにのみ影響します';
	@override String get trayCategoryContent => 'コンテンツ';
	@override String get trayCategoryAuthor => '作者';
	@override String get trayCategoryTime => '日時';
	@override String get chipAuthorcache => '作者名・固定';
	@override String get chipDate => '日付';
	@override String get chipTime => '時刻';
	@override String get chipDatetime => '日時';
	@override String get chipCount => '連番';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestJa extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quest の操作を覚えよう';
	@override String get intro => 'どのボタンで何ができるか確認して、空間で試してみましょう。';
	@override String get videoTab => '空間動画';
	@override String get galleryTab => '空間ギャラリー';
	@override String get scopeNote => 'Quest 空間のスクリーンとウィンドウのガイドです。プレーヤー設定からいつでも開けます。';
	@override String get catalog => '操作を選ぶ';
	@override String lessonCount({required Object current, required Object total}) => '${current} / ${total}';
	@override String get previous => '前へ';
	@override String get next => '次の操作';
	@override String get replay => 'もう一度見る';
	@override String get pauseDemo => 'デモを一時停止';
	@override String get resumeDemo => 'デモを再開';
	@override String get looping => '操作デモ';
	@override String get still => '静止図';
	@override String get done => '確認して続ける';
	@override String get leftController => '左手';
	@override String get rightController => '右手';
	@override String get trigger => '人差し指トリガー';
	@override String get grip => 'グリップボタン';
	@override String get bothGrips => '両手のグリップ';
	@override String get stick => 'スティック';
	@override String get handTracking => 'ハンドトラッキング';
	@override String get ready => '準備';
	@override String get press => '押す';
	@override String get hold => '押し続ける';
	@override String get release => '離す';
	@override String get result => '結果を見る';
	@override String get pinch => 'ピンチ';
	@override String get selectTitle => 'レイで選択する';
	@override String get selectBody => 'ボタンにレイを合わせ、人差し指トリガーを押して離すと選択できます。再生、設定、スライダーも同じ操作です。';
	@override String get selectHint => '人差し指トリガーはボタン面の裏側、グリップボタンは持ち手の内側にあります。';
	@override String get panelTitle => 'パネルを表示・非表示';
	@override String get panelBody => '操作パネルの外にレイを向けてトリガーを軽く押すと、表示を切り替えられます。手の場合はパネルの外で軽くピンチします。';
	@override String get panelHint => '動かさず短く押して離してください。押したまま動かすとドラッグになります。';
	@override String get playTitle => '再生・一時停止';
	@override String get playBody => '操作パネルからレイを外し、右手の A または左手の X で再生・一時停止します。パネルの再生ボタンも使えます。';
	@override String get playHint => 'このショートカットは空間プレーヤー設定で無効にできます。レイがパネル上にあるときは、パネルの操作が優先されます。';
	@override String get seekTitle => 'スティックでシーク';
	@override String get seekBody => '左右どちらのスティックでも、左・右に短く倒すと 5 秒移動します。倒し続けると加速し、離したときに表示中の時間へジャンプします。';
	@override String get seekHint => '操作するコントローラーのレイをパネルから外してください。パネル上ではスティックがスクロール操作になります。';
	@override String get browseTitle => 'スティックで画像を送る';
	@override String get browseBody => '左右どちらのスティックでも、左・右で前後の項目へ移動し、倒し続けると連続で送れます。フィルムストリップのサムネイルも選べます。';
	@override String get browseHint => 'ギャラリー内の動画も同じように送れます。レイが操作パネル上にあると、スティックはスクロールになります。';
	@override String get swipeTitle => '横ドラッグでページを送る';
	@override String get swipeBody => '画像にレイを合わせ、トリガーを押したまま左へドラッグします。ページ送りの表示が出たら離すと次へ、右へドラッグすると前へ戻ります。ピンチでも操作できます。';
	@override String get swipeHint => '画像は 1× のときにページ送りできます。ギャラリー内の動画にも対応しています。ドラッグ中は画面が動かず、離してから切り替わります。';
	@override String get zoomTitle => '画像の細部を拡大';
	@override String get zoomBody => '見たい部分にレイを合わせてトリガーを押し続け、スティックを上に倒すと拡大、下に倒すと縮小します。押した位置が拡大の中心になります。';
	@override String get zoomHint => 'ウィンドウの大きさは変わらず、中の画像だけが拡大します。画像を押していないときの上下操作は視聴距離を変えます。';
	@override String get panTitle => '拡大画像の移動とリセット';
	@override String get panBody => '拡大後はトリガーを押したままドラッグして、別の部分を見られます。画像をダブルクリックすると 2.5× 拡大とリセットを切り替えます。手の場合は素早く 2 回ピンチします。';
	@override String get panHint => '拡大中のドラッグは画像の移動です。ページ送りは 1× に戻してから行ってください。';
	@override String get slideshowTitle => 'スライドショーを開始';
	@override String get slideshowBody => '画像を表示中は A / X でスライドショーを開始・停止できます。パネルで 3・5・10・20 秒の間隔や標準・元画像の画質を選べます。';
	@override String get slideshowHint => 'ギャラリー内の動画では A / X がその動画の再生・一時停止になります。設定でショートカットを有効にしてください。';
	@override String get moveTitle => 'スクリーンをつかんで移動';
	@override String get moveBody => '持ち手の内側のグリップを押したままコントローラーを動かし、見やすい位置で離します。視聴中はスクリーンを狙わなくてもつかめます。';
	@override String get moveHint => 'アプリや操作パネルにレイを合わせると、そのウィンドウを優先してつかみます。パノラマ動画では向きを調整します。';
	@override String get scaleTitle => '両手でスクリーンの大きさを変更';
	@override String get scaleBody => '両方のグリップを押し続け、手を離すと拡大、近づけると縮小します。ハンドトラッキングでは両手でピンチを保って操作します。';
	@override String get scaleHint => '平面・曲面スクリーンとギャラリーの舞台に対応します。レイを操作パネルから外してください。画面全体の大きさが変わります。';
	@override String get distanceTitle => '視聴距離を調整';
	@override String get distanceBody => 'スティックを上に倒すと遠く、下に倒すと近くなります。ウィンドウをつかんでいる間はそのウィンドウの距離を調整します。音量はパネルで調整します。';
	@override String get distanceHint => 'レイを操作パネルから外してください。画像を押したままの上下操作は細部の拡大、パノラマ動画では見え方の調整になります。';
	@override String get resizeTitle => '枠や角をドラッグ';
	@override String get resizeBody => 'レイを端に近づけると枠が光ります。端をトリガーやピンチでつかむと移動、角をつかんでドラッグするとサイズ変更ができます。';
	@override String get resizeHint => 'アプリ、操作パネル、スクリーンで共通の操作です。アプリの幅と高さは自由に変えられ、スクリーンは縦横比を保ちます。';
	@override String get navigationTitle => '戻る・空間設定を開く';
	@override String get navigationBody => 'B / Y はポップアップを閉じる、パネルのホームへ戻る、パネルを隠す、アプリへ戻る、の順で一段ずつ戻ります。左手の Menu で空間設定を開けます。';
	@override String get navigationHint => '右手の Meta ボタンはシステム用です。システムの視点リセットで正面に戻せます。スクリーンの大きさと距離は保たれます。';
	@override String get handsTitle => 'コントローラーなしで操作';
	@override String get handsBody => 'ハンドトラッキングを有効にし、システムのレイをボタンに合わせ、親指と人差し指をピンチして離します。再生、シーク、画像送りはパネルで操作できます。';
	@override String get handsHint => 'パネル外で軽くピンチすると表示を切り替えます。端をつかんで移動、角でサイズ変更、両手でピンチして広げるとスクリーンを拡大できます。';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesJa extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'メディアレンダラー';
	@override String get mediaServer => 'メディアサーバー';
	@override String get internetGatewayDevice => 'ルーター';
	@override String get basicDevice => '基本デバイス';
	@override String get dimmableLight => 'スマートライト';
	@override String get wlanAccessPoint => '無線アクセスポイント';
	@override String get wlanConnectionDevice => '無線接続デバイス';
	@override String get printer => 'プリンター';
	@override String get scanner => 'スキャナー';
	@override String get digitalSecurityCamera => 'カメラ';
	@override String get unknownDevice => '不明なデバイス';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetJa extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'リモートキャスト';
	@override String get close => '閉じる';
	@override String get searchingDevices => 'デバイスを検索中...';
	@override String get searchPrompt => '検索ボタンをクリックしてキャストデバイスを再検索';
	@override String get searching => '検索中';
	@override String get searchAgain => '再検索';
	@override String get noDevicesFound => 'キャストデバイスが見つかりません\nデバイスが同じネットワークにあることを確認してください';
	@override String get searchingDevicesPrompt => 'デバイスを検索中です。お待ちください...';
	@override String get cast => 'キャスト';
	@override String connectedTo({required Object deviceName}) => '接続済み: ${deviceName}';
	@override String get notConnected => 'デバイス未接続';
	@override String get stopCasting => 'キャスト停止';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'プロフィール',
			'personalProfile.editPersonalProfile' => 'プロフィール編集',
			'personalProfile.avatar' => 'アバター',
			'personalProfile.background' => '背景',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'ユーザー情報の取得に失敗しました: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => '推奨解像度：${resolution}、ファイルサイズ < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'サポート形式：${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'プレミアムユーザーは動的な${type} (${formats}) を使用できます',
			'personalProfile.homepageBackground' => 'プロフィール背景',
			'personalProfile.basicInfo' => '基本情報',
			'personalProfile.nickname' => 'ニックネーム',
			'personalProfile.username' => 'ユーザー名',
			'personalProfile.copyUsername' => 'ユーザー名をコピー',
			'personalProfile.usernameCopied' => 'ユーザー名をコピーしました',
			'personalProfile.personalIntroduction' => '自己紹介',
			'personalProfile.noPersonalIntroduction' => '自己紹介がありません',
			'personalProfile.clickToEdit' => 'クリックして編集',
			'personalProfile.privacySettings' => 'プライバシー設定',
			'personalProfile.hideSensitiveContent' => 'センシティブな内容を非表示',
			'personalProfile.hideSensitiveContentDesc' => 'センシティブなタグを含む動画や画像を非表示にします。',
			'personalProfile.notificationSettings' => '通知設定',
			'personalProfile.contentCommentNotification' => 'コンテンツへのコメント通知',
			'personalProfile.contentCommentNotificationDesc' => 'あなたのコンテンツにコメントがあったときに通知します。',
			'personalProfile.commentReplyNotification' => 'コメントへの返信通知',
			'personalProfile.commentReplyNotificationDesc' => 'あなたのコメントに返信があったときに通知します。',
			'personalProfile.mentionNotification' => 'メンション通知',
			'personalProfile.mentionNotificationDesc' => 'コンテンツ内であなたをメンションしたときに通知します。',
			'personalProfile.accountInfo' => 'アカウント情報',
			'personalProfile.registrationTime' => '登録日時',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => '設定の更新に失敗しました: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => '通知設定の更新に失敗しました: ${error}',
			'personalProfile.editNickname' => 'ニックネームの変更',
			'personalProfile.nicknameCannotBeEmpty' => 'ニックネームを空にすることはできません',
			'personalProfile.changeSuccess' => '変更に成功しました',
			'personalProfile.unsupportedFileFormat' => 'サポートされていないファイル形式',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'ファイルサイズは ${size} を超えることはできません',
			'personalProfile.uploadFailed' => 'アップロードに失敗しました',
			'personalProfile.avatarUpdatedSuccessfully' => 'アバターを更新しました',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'アバターの更新に失敗しました: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => '背景を更新しました',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => '背景の更新に失敗しました: ${error}',
			'personalProfile.editPersonalIntroduction' => '自己紹介の編集',
			'personalProfile.enterPersonalIntroduction' => '自己紹介を入力してください',
			'tutorial.specialFollowFeature' => '特別フォロー',
			'tutorial.specialFollowDescription' => 'よく見る著者を特別フォローにしておくと、ここからワンタップで切り替えて最新の投稿だけを追えます。',
			'tutorial.stepsTitle' => '3ステップで追加',
			'tutorial.stepFollowAuthor' => '著者の動画・ギャラリー・プロフィールページで「フォロー」をタップ。',
			'tutorial.stepPickSpecial' => 'もう一度「フォロー済み」をタップし、メニューから「特別フォロー」を選択。',
			'tutorial.stepSwitchHere' => '購読ページに戻り、上のアイコン選択でその著者に切り替え。',
			'tutorial.specialFollowManagementTip' => '特別フォローリストはサイドドロワー - フォローリスト - 特別フォローで管理できます。',
			'tutorial.gotIt' => 'OK',
			'common.sort' => '並び替え',
			'common.filter' => 'フィルター',
			'common.appName' => 'Love Iwara',
			'common.ok' => '確定',
			'common.cancel' => 'キャンセル',
			'common.select' => '選択',
			'common.save' => '保存',
			'common.delete' => '削除',
			'common.visit' => 'アクセス',
			'common.loading' => '読み込み中...',
			'common.scrollToTop' => 'トップに戻る',
			'common.privacyHint' => 'プライバシーモード中：内容は非表示です',
			'common.latest' => '最新',
			'common.likesCount' => 'いいね数',
			'common.viewsCount' => '視聴回数',
			'common.popular' => '人気',
			'common.trending' => 'トレンド',
			'common.commentList' => 'コメント一覧',
			'common.sendComment' => 'コメントを投稿',
			'common.send' => '送信',
			'common.retry' => '再試行',
			'common.premium' => 'プレミアム会員',
			'common.follower' => 'フォロワー',
			'common.friend' => '友達',
			'common.video' => 'ビデオ',
			'common.following' => 'フォロー中',
			'common.expand' => '展開',
			'common.collapse' => '收起',
			'common.cancelFriendRequest' => '友達申請を取り消す',
			'common.cancelSpecialFollow' => '特別フォローを解除',
			'common.addFriend' => '友達を追加',
			'common.removeFriend' => '友達を解除',
			'common.followed' => 'フォロー済み',
			'common.follow' => 'フォローする',
			'common.unfollow' => 'フォロー解除',
			'common.specialFollow' => '特別フォロー',
			'common.specialFollowed' => '特別フォロー済み',
			'common.specialFollowsManagementTip' => 'ハンドルをドラッグで並べ替え • 右のボタンで削除',
			'common.specialFollowsManagement' => '特別フォロー管理',
			'common.removeSpecialFollow' => '特別フォローを解除',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => '${name} を特別フォローから外しますか？',
			'common.noSpecialFollows' => '特別フォローはまだありません',
			'common.createTimeDesc' => '作成時間降順',
			'common.createTimeAsc' => '作成時間昇順',
			'common.gallery' => 'ギャラリー',
			'common.playlist' => 'プレイリスト',
			'common.commentPostedSuccessfully' => 'コメントが正常に投稿されました',
			'common.commentPostedFailed' => 'コメントの投稿に失敗しました',
			'common.success' => '成功',
			'common.commentDeletedSuccessfully' => 'コメントが削除されました',
			'common.commentUpdatedSuccessfully' => 'コメントが更新されました',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 件のコメント', other: '${n} 件のコメント', ), 
			'common.writeYourCommentHere' => 'ここにコメントを入力...',
			'common.tmpNoReplies' => '返信はありません',
			'common.loadMore' => 'もっと読み込む',
			'common.loadingMore' => 'さらに読み込み中...',
			'common.noMoreDatas' => 'これ以上データはありません',
			'common.selectTranslationLanguage' => '翻訳言語を選択',
			'common.translate' => '翻訳',
			'common.translateFailedPleaseTryAgainLater' => '翻訳に失敗しました。後でもう一度お試しください',
			'common.translationResult' => '翻訳結果',
			'common.justNow' => 'たった今',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 分前', other: '${n} 分前', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 時間前', other: '${n} 時間前', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 日前', other: '${n} 日前', ), 
			'common.editedAt' => ({required Object num}) => '${num} 編集',
			'common.editComment' => 'コメントを編集',
			'common.commentUpdated' => 'コメントが更新されました',
			'common.replyComment' => 'コメントに返信',
			'common.reply' => '返信',
			'common.edit' => '編集',
			'common.unknownUser' => '不明なユーザー',
			'common.me' => '私',
			'common.author' => '作者',
			'common.admin' => '管理者',
			'common.viewReplies' => ({required Object num}) => '返信を表示 (${num})',
			'common.hideReplies' => '返信を非表示',
			'common.confirmDelete' => '削除を確認',
			'common.areYouSureYouWantToDeleteThisItem' => 'この項目を削除してもよろしいですか？',
			'common.tmpNoComments' => 'コメントがありません',
			'common.refresh' => '更新',
			'common.back' => '戻る',
			'common.tips' => 'ヒント',
			'common.linkIsEmpty' => 'リンクアドレスが空です',
			'common.linkCopiedToClipboard' => 'リンクアドレスがクリップボードにコピーされました',
			'common.imageCopiedToClipboard' => '画像がクリップボードにコピーされました',
			'common.copyImageFailed' => '画像のコピーに失敗しました',
			'common.mobileSaveImageIsUnderDevelopment' => 'モバイル端末での画像保存機能は現在開発中です',
			'common.imageSavedTo' => '画像が保存されました',
			'common.saveImageFailed' => '画像の保存に失敗しました',
			'common.close' => '閉じる',
			'common.more' => 'もっと見る',
			'common.unknownError' => '未知のエラー',
			'common.moreFeaturesToBeDeveloped' => 'さらに機能が開発中です',
			'common.all' => 'すべて',
			'common.selectedRecords' => ({required Object num}) => '${num} 件のレコードが選択されました',
			'common.cancelSelectAll' => 'すべての選択を解除',
			'common.selectAll' => 'すべて選択',
			'common.invertSelection' => '選択を反転',
			'common.exitEditMode' => '編集モードを終了',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '選択した ${num} 件のレコードを削除してもよろしいですか？',
			'common.searchHistoryRecords' => '検索履歴...',
			'common.settings' => '設定',
			'common.subscriptions' => 'サブスクリプション',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 本の動画', other: '${n} 本の動画', ), 
			'common.share' => '共有',
			'common.areYouSureYouWantToShareThisPlaylist' => 'このプレイリストを共有してもよろしいですか？',
			'common.editTitle' => 'タイトルを編集',
			'common.editMode' => '編集モード',
			'common.pleaseEnterNewTitle' => '新しいタイトルを入力してください',
			'common.createPlayList' => 'プレイリストを作成',
			'common.create' => '作成',
			'common.checkNetworkSettings' => 'ネットワーク設定を確認',
			'common.general' => '一般',
			'common.r18' => 'R18',
			'common.sensitive' => 'センシティブ',
			'common.year' => '年',
			'common.month' => '月',
			'common.tag' => 'タグ',
			'common.notice' => 'お知らせ',
			'common.private' => 'プライベート',
			'common.noTitle' => 'タイトルなし',
			'common.search' => '検索',
			'common.noContent' => 'コンテンツがありません',
			'common.recording' => '録画中',
			'common.paused' => '一時停止',
			'common.clear' => 'クリア',
			'common.clearSelection' => '選択を解除',
			'common.selectItemsToContinue' => '項目を選択してください',
			'common.andMoreItems' => ({required Object num}) => '他 ${num} 件',
			'common.batchDelete' => '一括削除',
			'common.user' => 'ユーザー',
			'common.post' => '投稿',
			'common.seconds' => '秒',
			'common.comingSoon' => '近日公開',
			'common.confirm' => '確認',
			'common.hour' => '時',
			'common.minute' => '分',
			'common.clickToRefresh' => 'クリックして更新',
			'common.history' => '履歴',
			'common.favorites' => 'お気に入り',
			'common.friends' => '友達',
			'common.playList' => 'プレイリスト',
			'common.checkLicense' => 'ライセンスを確認',
			'common.logout' => 'ログアウト',
			'common.fensi' => 'フォロワー',
			'common.accept' => '受け入れる',
			'common.reject' => '拒否',
			'common.clearAllHistory' => 'すべての履歴をクリア',
			'common.clearAllHistoryConfirm' => 'すべての履歴をクリアしてもよろしいですか？',
			'common.followingList' => 'フォロー中リスト',
			'common.followersList' => 'フォロワーリスト',
			'common.follows' => 'フォロー',
			'common.fans' => 'フォロワー',
			'common.followsAndFans' => 'フォローとフォロワー',
			'common.numViews' => '視聴回数',
			'common.updatedAt' => '更新時間',
			'common.publishedAt' => '発表時間',
			'common.externalVideo' => '站外動画',
			'common.originalText' => '原文',
			'common.showOriginalText' => '原文を表示',
			'common.showProcessedText' => '処理後の原文を表示',
			'common.preview' => 'プレビュー',
			'common.rules' => 'ルール',
			'common.agree' => '同意',
			'common.disagree' => '不同意',
			'common.agreeToRules' => '同意ルール',
			'common.tapToReread' => 'タップで全文を再読',
			'common.markdownSyntaxHelp' => 'Markdown構文ヘルプ',
			'common.previewContent' => '内容をプレビュー',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => '最大文字数制限を超過 (${max})',
			'common.agreeToCommunityRules' => 'コミュニティルールに同意',
			'common.createPost' => '投稿を作成',
			'common.title' => 'タイトル',
			'common.enterTitle' => 'タイトルを入力してください',
			'common.content' => '内容',
			'common.enterContent' => '内容を入力してください',
			'common.writeYourContentHere' => '内容を入力してください...',
			'common.tagBlacklist' => 'ブラックリストタグ',
			'common.noData' => 'データがありません',
			'common.tagLimit' => 'タグ上限',
			'common.enableFloatingButtons' => 'フローティングボタンを有効',
			'common.disableFloatingButtons' => 'フローティングボタンを無効',
			'common.enabledFloatingButtons' => 'フローティングボタンが有効',
			'common.disabledFloatingButtons' => 'フローティングボタンが無効',
			'common.pendingCommentCount' => '未審核コメント',
			'common.joined' => ({required Object str}) => '${str} に参加',
			'common.lastSeenAt' => ({required Object str}) => '最終オンライン ${str}',
			'common.download' => 'ダウンロード',
			'common.selectQuality' => '画質を選択',
			'common.videoQualitySource' => 'オリジナル',
			'common.selectImageQuality' => '画質を選択',
			'common.imageQualityStandard' => '標準',
			'common.imageQualityOriginal' => 'オリジナル',
			'common.selectDateRange' => '日付範囲を選択',
			'common.selectDateRangeHint' => '日付範囲を選択，デフォルトは最近30日',
			'common.clearDateRange' => '日付範囲をクリア',
			'common.deleteRecordsInDateRange' => 'この期間の記録を削除',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'この期間の ${num} 件の履歴を削除してもよろしいですか？この操作は取り消せません。',
			'common.noHistoryRecordsInRange' => 'この期間の履歴はありません',
			'common.followSuccessClickAgainToSpecialFollow' => 'フォローに成功しました。再度クリックして特別フォロー',
			'common.specialFollowTip' => '特別フォローに追加しました。購読ページ右上のセレクターで切り替えると、すぐに確認できます',
			'common.exitConfirmTip' => '本当に退出しますか？',
			'common.error' => 'エラー',
			'common.taskRunning' => '既にタスクが実行中です。しばらくお待ちください。',
			'common.operationCancelled' => '操作がキャンセルされました。',
			'common.unsavedChanges' => '未保存の変更があります',
			'common.pagination.totalItems' => ({required Object num}) => '全 ${num} 件',
			'common.pagination.jumpToPage' => 'ページ指定',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'ページ番号を入力してください (1-${max})',
			'common.pagination.pageNumber' => 'ページ番号',
			'common.pagination.jump' => '移動',
			'common.pagination.invalidPageNumber' => ({required Object max}) => '有効なページ番号を入力してください (1-${max})',
			'common.pagination.invalidInput' => '有効なページ番号を入力してください',
			'common.pagination.waterfall' => 'ウォーターフォール',
			'common.pagination.pagination' => 'ページネーション',
			'common.detail' => '詳細',
			'common.parseExceptionDestopHint' => ' - デスクトップユーザーは設定でプロキシを構成できます',
			'common.iwaraTags' => 'Iwara タグ',
			'common.tagInfo' => 'タグ情報',
			'common.tagOriginalKey' => '元のタグ',
			'common.tagTranslation' => '翻訳',
			'common.copy' => 'コピー',
			'common.selectCopy' => '選択してコピー',
			'common.copiedToClipboard' => 'クリップボードにコピーしました',
			'common.showOriginalTag' => '元のタグを表示',
			'common.showTranslatedTag' => '翻訳を表示',
			'common.tagTranslationFeedback' => '翻訳に疑問がありますか？フィードバック',
			'common.tagLocalizationGuideTitle' => 'タグの翻訳について',
			'common.tagLocalizationGuideContent' => 'アプリは Iwara の元のタグ（例：mother）を、現在の言語の訳名で表示します。\n\n• タグ検索では、訳名でも元のタグでも一致します。\n• タグを長押し / 右クリックすると、元のタグと訳名を確認・コピーできます。\n• 訳名はコミュニティによる有志翻訳であり、誤りが含まれる場合があります。',
			'common.likeThisVideo' => 'この動画が好きな人',
			'common.likeThisGallery' => 'このギャラリーが好きな人',
			'common.operation' => '操作',
			'common.replies' => '返信',
			'common.externalLinkWarning' => '外部リンク警告',
			'common.externalLinkWarningMessage' => 'iwara.tv 以外の外部リンクを開こうとしています。安全性に注意し、リンクが信頼できることを確認してから続行してください。',
			'common.continueToExternalLink' => '続行',
			'common.cancelExternalLink' => 'キャンセル',
			'auth.login' => 'ログイン',
			'auth.logout' => 'ログアウト',
			'auth.email' => 'メールアドレス',
			'auth.password' => 'パスワード',
			'auth.loginOrRegister' => 'ログイン / 新規登録',
			'auth.register' => '新規登録',
			'auth.pleaseEnterEmail' => 'メールアドレスを入力してください',
			'auth.pleaseEnterPassword' => 'パスワードを入力してください',
			'auth.passwordMustBeAtLeast6Characters' => 'パスワードは6文字以上必要です',
			'auth.pleaseEnterCaptcha' => 'キャプチャを入力してください',
			'auth.captcha' => 'キャプチャ',
			'auth.refreshCaptcha' => 'キャプチャを更新',
			'auth.captchaNotLoaded' => 'キャプチャを読み込めませんでした',
			'auth.loginSuccess' => 'ログインに成功しました',
			'auth.loginSuccessProfilePending' => 'ログインしました。プロフィールを読み込んでいます…',
			'auth.emailVerificationSent' => 'メール認証が送信されました',
			'auth.notLoggedIn' => 'ログインしていません',
			'auth.clickToLogin' => 'こちらをクリックしてログイン',
			'auth.logoutConfirmation' => '本当にログアウトしますか？',
			'auth.logoutSuccess' => 'ログアウトに成功しました',
			'auth.logoutFailed' => 'ログアウトに失敗しました',
			'auth.usernameOrEmail' => 'ユーザー名またはメールアドレス',
			'auth.pleaseEnterUsernameOrEmail' => 'ユーザー名またはメールアドレスを入力してください',
			'auth.rememberMe' => 'ユーザー名を記憶',
			'auth.registerNoticeTitle' => '公式サイトで新規登録',
			'auth.registerNoticeDescription' => 'アプリ内での新規登録は提供されなくなりました。Iwara 公式サイトでアカウントを作成し、こちらに戻ってログインしてください。',
			'auth.registerNoticeReturnTip' => '登録後、こちらに戻ってアカウントでログインしてください。',
			'auth.goToOfficialWebsite' => '公式サイトを開く',
			'errors.error' => 'エラー',
			'errors.required' => 'この項目は必須です',
			'errors.invalidEmail' => 'メールアドレスの形式が正しくありません',
			'errors.networkError' => 'ネットワークエラーが発生しました。再試行してください',
			'errors.errorWhileFetching' => '情報の取得に失敗しました',
			'errors.commentCanNotBeEmpty' => 'コメント内容は空にできません',
			'errors.errorWhileFetchingReplies' => '返信の取得中にエラーが発生しました。ネットワーク接続を確認してください',
			'errors.canNotFindCommentController' => 'コメントコントローラーが見つかりません',
			'errors.errorWhileLoadingGallery' => 'ギャラリーの読み込み中にエラーが発生しました',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'え？データがありません。エラーが発生した可能性があります :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'サポートされていない画像形式: ${str}',
			'errors.invalidGalleryId' => '無効なギャラリーIDです',
			'errors.translationFailedPleaseTryAgainLater' => '翻訳に失敗しました。後でもう一度お試しください',
			'errors.errorOccurred' => 'エラーが発生しました。しばらくしてから再試行してください。',
			'errors.errorOccurredWhileProcessingRequest' => 'リクエストの処理中にエラーが発生しました',
			'errors.errorWhileFetchingDatas' => 'データの取得中にエラーが発生しました。後でもう一度お試しください',
			'errors.serviceNotInitialized' => 'サービスが初期化されていません',
			'errors.unknownType' => '不明なタイプです',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'リンクを開けませんでした: ${link}',
			'errors.invalidUrl' => '無効なURLです',
			'errors.failedToOperate' => '操作に失敗しました',
			'errors.permissionDenied' => '権限がありません',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'このリソースにアクセスする権限がありません',
			'errors.loginFailed' => 'ログインに失敗しました',
			'errors.unknownError' => '不明なエラーです',
			'errors.sessionExpired' => 'セッションが期限切れです',
			'errors.failedToFetchCaptcha' => 'キャプチャの取得に失敗しました',
			'errors.emailAlreadyExists' => 'メールアドレスは既に存在します',
			'errors.invalidCaptcha' => '無効なキャプチャです',
			'errors.registerFailed' => '登録に失敗しました',
			'errors.failedToFetchComments' => 'コメントの取得に失敗しました',
			'errors.failedToFetchImageDetail' => '画像の取得に失敗しました',
			'errors.failedToFetchImageList' => '画像の取得に失敗しました',
			'errors.failedToFetchData' => 'データの取得に失敗しました',
			'errors.invalidParameter' => '無効なパラメータです',
			'errors.pleaseLoginFirst' => 'ログインしてください',
			'errors.errorWhileLoadingPost' => '投稿の取得中にエラーが発生しました',
			'errors.errorWhileLoadingPostDetail' => '投稿詳細の取得中にエラーが発生しました',
			'errors.invalidPostId' => '無効な投稿IDです',
			'errors.forceUpdateNotPermittedToGoBack' => '現在強制更新状態です。戻ることはできません',
			'errors.pleaseLoginAgain' => 'ログインしてください',
			'errors.invalidLogin' => 'ログインに失敗しました。メールアドレスとパスワードを確認してください',
			'errors.tooManyRequests' => 'リクエストが多すぎます。後でもう一度お試しください',
			'errors.exceedsMaxLength' => ({required Object max}) => '最大長さを超えています: ${max}',
			'errors.contentCanNotBeEmpty' => 'コンテンツは空にできません',
			'errors.titleCanNotBeEmpty' => 'タイトルは空にできません',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'リクエストが多すぎます。後でもう一度お試しください。残り時間',
			'errors.remainingHours' => ({required Object num}) => '${num}時間',
			'errors.remainingMinutes' => ({required Object num}) => '${num}分',
			'errors.remainingSeconds' => ({required Object num}) => '${num}秒',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'タグの上限を超えています。上限: ${limit}',
			'errors.failedToRefresh' => '更新に失敗しました',
			'errors.noPermission' => '権限がありません',
			'errors.resourceNotFound' => 'リソースが見つかりません',
			'errors.failedToSaveCredentials' => 'ログイン情報の保存に失敗しました',
			'errors.failedToLoadSavedCredentials' => '保存されたログイン情報の読み込みに失敗しました',
			'errors.notFound' => 'コンテンツが見つかりませんまたは削除されました',
			'errors.network.basicPrefix' => 'ネットワークエラー - ',
			'errors.network.failedToConnectToServer' => 'サーバーへの接続に失敗しました',
			'errors.network.serverNotAvailable' => 'サーバーが利用できません',
			'errors.network.requestTimeout' => 'リクエストタイムアウト',
			'errors.network.unexpectedError' => '予期しないエラー',
			'errors.network.invalidResponse' => '無効なレスポンス',
			'errors.network.invalidRequest' => '無効なリクエスト',
			'errors.network.invalidUrl' => '無効なURL',
			'errors.network.invalidMethod' => '無効なメソッド',
			'errors.network.invalidHeader' => '無効なヘッダー',
			'errors.network.invalidBody' => '無効なボディ',
			'errors.network.invalidStatusCode' => '無効なステータスコード',
			'errors.network.serverError' => 'サーバーエラー',
			'errors.network.requestCanceled' => 'リクエストがキャンセルされました',
			'errors.network.invalidPort' => '無効なポート',
			'errors.network.proxyPortError' => 'プロキシポートエラー',
			'errors.network.connectionRefused' => '接続が拒否されました',
			'errors.network.networkUnreachable' => 'ネットワークに到達できません',
			'errors.network.noRouteToHost' => 'ホストに到達できません',
			'errors.network.connectionFailed' => '接続に失敗しました',
			'errors.network.sslConnectionFailed' => 'SSL接続に失敗しました。ネットワーク設定を確認してください',
			'friends.clickToRestoreFriend' => '友達を復元するにはクリックしてください',
			'friends.friendsList' => '友達リスト',
			'friends.friendRequests' => '友達リクエスト',
			'friends.friendRequestsList' => '友達リクエスト一覧',
			'friends.removingFriend' => 'フレンド解除中...',
			'friends.failedToRemoveFriend' => 'フレンド解除に失敗しました',
			'friends.cancelingRequest' => 'フレンド申請をキャンセル中...',
			'friends.failedToCancelRequest' => 'フレンド申請のキャンセルに失敗しました',
			'authorProfile.noMoreDatas' => 'これ以上データはありません',
			'authorProfile.userProfile' => 'ユーザープロフィール',
			'favorites.clickToRestoreFavorite' => 'お気に入りを復元するにはクリックしてください',
			'favorites.myFavorites' => '私のお気に入り',
			'favorites.batchCancelFavorite' => 'お気に入りを一括解除',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => '選択した ${count} 件のお気に入りを解除しますか？解除後もカードをタップすれば復元できます。',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => '${count} 件のお気に入りを解除しました',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => '${success} 件を解除しました。${failed} 件は失敗しました',
			'galleryDetail.browseInSpace' => '空間で閲覧',
			'galleryDetail.galleryDetail' => 'ギャラリー詳細',
			'galleryDetail.viewGalleryDetail' => 'ギャラリー詳細を表示',
			'galleryDetail.zoomReset' => 'ズームをリセット',
			'galleryDetail.copyLink' => 'リンクをコピー',
			'galleryDetail.copyImage' => '画像をコピー',
			'galleryDetail.saveAs' => '名前を付けて保存',
			'galleryDetail.saveToAlbum' => 'アルバムに保存',
			'galleryDetail.publishedAt' => '公開日時',
			'galleryDetail.viewsCount' => '視聴回数',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'ギャラリー機能の紹介',
			'galleryDetail.rightClickToSaveSingleImage' => '右クリックで単一画像を保存',
			'galleryDetail.batchSave' => 'バッチ保存',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'キーボードの左右キーで切り替え',
			'galleryDetail.keyboardUpAndDownToZoom' => 'キーボードの上下キーでズーム',
			'galleryDetail.mouseWheelToSwitch' => 'マウスホイールで切り替え',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + マウスホイールでズーム',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'さらに機能が発見されます...',
			'galleryDetail.authorOtherGalleries' => '作者の他のギャラリー',
			'galleryDetail.relatedGalleries' => '関連ギャラリー',
			'galleryDetail.authorNoOtherGalleries' => '他のギャラリーはありません',
			'galleryDetail.noRelatedGalleries' => '関連するギャラリーはありません',
			'galleryDetail.scrollLeft' => '左へスクロール',
			'galleryDetail.scrollRight' => '右へスクロール',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => '左端と右端をクリックして切り替え',
			'galleryDetail.rotateToLandscape' => '横画面で全画面',
			'galleryDetail.backToPortrait' => '縦画面に戻す',
			'playList.myPlayList' => '私のプレイリスト',
			'playList.friendlyTips' => 'フレンドリーティップス',
			'playList.dearUser' => '親愛なるユーザー',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'iwaraのプレイリストシステムはまだ完全ではありません',
			'playList.notSupportSetCover' => 'カバー設定はサポートされていません',
			'playList.notSupportDeleteList' => 'リストの削除はできません',
			'playList.notSupportSetPrivate' => 'プライベート設定はできません',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'はい...作成されたリストは常に存在し、全員に表示されます',
			'playList.smallSuggestion' => '小さな提案',
			'playList.useLikeToCollectContent' => 'プライバシーを重視する場合は、「いいね」機能を使用してコンテンツを収集することをお勧めします',
			'playList.welcomeToDiscussOnGitHub' => 'その他の提案やアイデアがある場合は、GitHubでのディスカッションを歓迎します！',
			'playList.iUnderstand' => 'わかりました',
			'playList.searchPlaylists' => 'プレイリストを検索...',
			'playList.newPlaylistName' => '新しいプレイリスト名',
			'playList.createNewPlaylist' => '新しいプレイリストを作成',
			'playList.videos' => '動画',
			'search.googleSearchScope' => '検索範囲',
			'search.searchTags' => 'タグを検索...',
			'search.contentRating' => 'コンテンツレーティング',
			'search.removeTag' => 'タグを削除',
			'search.pleaseEnterSearchContent' => '検索内容を入力してください',
			'search.exactMatch' => '完全一致',
			'search.exactMatchOnHint' => 'フレーズ全体で完全一致し、中国語・日本語のタイトルも併せて検索しています。タップで緩い検索に戻します。',
			'search.exactMatchOffHint' => '緩い一致です（iwara が語を分割します）。タップでフレーズ全体の完全一致に。',
			'search.searchHistory' => '検索履歴',
			'search.searchSuggestion' => '検索提案',
			'search.usedTimes' => '使用回数',
			'search.lastUsed' => '最後の使用',
			'search.noSearchHistoryRecords' => '検索履歴がありません',
			'search.clearSearchHistoryConfirm' => 'すべての検索履歴を消去してもよろしいですか？この操作は元に戻せません。',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => '現在の検索タイプ ${searchType} はまだ実装されていません。お楽しみに',
			'search.searchResult' => '検索結果',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'サポートされていない検索タイプ: ${searchType}',
			'search.googleSearch' => 'グーグル検索',
			'search.googleSearchHint' => ({required Object webName}) => '${webName} の検索機能は使いにくいですか？ グーグル検索を試してみてください！',
			'search.googleSearchDescription' => 'Google Search の :site 検索演算子を使用して、サイトのコンテンツを検索します。これは、動画、ギャラリー、プレイリスト、ユーザーを検索する際に非常に便利です。',
			'search.googleSearchKeywordsHint' => '検索するキーワードを入力してください',
			'search.openLinkJump' => 'リンクジャンプを開く',
			'search.googleSearchButton' => 'グーグル検索',
			'search.pleaseEnterSearchKeywords' => '検索するキーワードを入力してください',
			'search.googleSearchQueryCopied' => '検索語句をクリップボードにコピーしました',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'ブラウザを開けませんでした: ${error}',
			'search.searchRequestTimeout' => 'リクエストがタイムアウトしました。しばらくしてから再試行してください',
			'search.searchCannotConnectToServer' => 'サーバーに接続できません。ネットワーク接続を確認してください',
			'search.searchNetworkError' => 'ネットワーク接続に失敗しました。ネットワーク設定を確認するか、しばらくしてから再試行してください',
			'search.searchFailedPleaseRetry' => '検索に失敗しました。しばらくしてから再試行してください',
			'mediaList.personalIntroduction' => '個人紹介',
			'settings.listViewMode' => 'リスト表示モード',
			'settings.previewEffect' => 'プレビュー効果',
			'settings.useTraditionalPaginationMode' => '従来のページネーションモードを使用',
			'settings.useTraditionalPaginationModeDesc' => '従来のページネーションモードを使用すると、ページネーションモードが無効になります。ページを再レンダリングまたはアプリを再起動した後に有効になります',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => '底部プログレスバー',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'この設定は、ツールバーが非表示のときに底部プログレスバーを表示するかどうかを決定します。',
			'settings.seekPreviewSize' => 'シークプレビューのサイズ',
			'settings.seekPreviewSizeDesc' => 'プログレスバーの上に表示されるプレビュー窓の大きさ。プレイヤーのサイズと動画の縦横比には元から追従します。ここではその上で少しだけ調整します。',
			'settings.seekPreviewSizeSmall' => '小',
			'settings.seekPreviewSizeStandard' => '標準',
			'settings.seekPreviewSizeLarge' => '大',
			'settings.seekPreviewSizeStandardDesc' => 'プレイヤーと動画から自動的に決まるサイズ',
			'settings.showFullscreenUpNextHint' => '「次に見る」の取っ手を表示',
			'settings.showFullscreenUpNextHintDesc' => 'プレイヤー右端に取っ手を表示し、キュー（元のリスト / 再生リスト / あとで見る）を開きます。オフにすると他の入口はありません。',
			'settings.basicSettings' => '基本設定',
			'settings.personalizedSettings' => '個性化設定',
			'settings.otherSettings' => 'その他設定',
			'settings.searchConfig' => '検索設定',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'この設定は、今後動画を再生する際に以前の設定を使用するかどうかを決定します。',
			'settings.playControl' => '再生コントロール',
			'settings.playbackSpeedSettings' => '再生と速度',
			'settings.playbackBehaviorSettings' => '再生動作',
			'settings.enhancementSettings' => 'シアターと画質強化',
			'settings.fastForwardTime' => '早送り時間',
			'settings.fastForwardTimeMustBeAPositiveInteger' => '早送り時間は正の整数でなければなりません。',
			'settings.rewindTime' => '巻き戻し時間',
			_ => null,
		} ?? switch (path) {
			'settings.rewindTimeMustBeAPositiveInteger' => '巻き戻し時間は正の整数でなければなりません。',
			'settings.longPressPlaybackSpeed' => '長押し再生速度',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => '長押し再生速度は正の数でなければなりません。',
			'settings.defaultPlaybackSpeed' => 'デフォルト再生速度',
			'settings.rememberPlaybackSpeed' => '再生速度を記憶する',
			'settings.rememberPlaybackSpeedDesc' => '有効にすると、プレーヤーで調整した再生速度がデフォルトとして保存され、以降の新しい動画に自動的に適用されます。',
			'settings.repeat' => 'リピート',
			'settings.renderVerticalVideoInVerticalScreen' => '全画面再生時に縦向きビデオを縦画面モードでレンダリング',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'この設定は、全画面再生時に縦向きビデオを縦画面モードでレンダリングするかどうかを決定します。',
			'settings.rememberVolume' => '音量を記憶',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'この設定は、今後動画を再生する際に以前の音量設定を使用するかどうかを決定します。',
			'settings.rememberBrightness' => '明るさを記憶',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'この設定は、今後動画を再生する際に以前の明るさ設定を使用するかどうかを決定します。',
			'settings.playControlArea' => '再生コントロールエリア',
			'settings.leftAndRightControlAreaWidth' => '左右コントロールエリアの幅',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'この設定は、プレイヤーの左右にあるコントロールエリアの幅を決定します。',
			'settings.proxyAddressCannotBeEmpty' => 'プロキシアドレスは空にできません。',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => '無効なプロキシアドレス形式です。IP:ポート または ドメイン名:ポート の形式を使用してください。',
			'settings.proxyNormalWork' => 'プロキシが正常に動作しています。',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'プロキシリクエストが失敗しました。ステータスコード: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'プロキシリクエスト中にエラーが発生しました: ${exception}',
			'settings.proxyConfig' => 'プロキシ設定',
			'settings.thisIsHttpProxyAddress' => 'ここにHTTPプロキシアドレスを入力してください',
			'settings.checkProxy' => 'プロキシを確認',
			'settings.proxyAddress' => 'プロキシアドレス',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'プロキシサーバーのURLを入力してください（例: 127.0.0.1:8080）',
			'settings.enableProxy' => 'プロキシを有効にする',
			'settings.left' => '左',
			'settings.middle' => '中央',
			'settings.right' => '右',
			'settings.playerSettings' => 'プレイヤー設定',
			'settings.networkSettings' => 'ネットワーク設定',
			'settings.customizeYourPlaybackExperience' => '再生体験をカスタマイズ',
			'settings.chooseYourFavoriteAppAppearance' => 'お好みのアプリ外観を選択',
			'settings.configureYourProxyServer' => 'プロキシサーバーを設定',
			'settings.settings' => '設定',
			'settings.themeSettings' => 'テーマ設定',
			'settings.followSystem' => 'システムに従う',
			'settings.lightMode' => 'ライトモード',
			'settings.darkMode' => 'ダークモード',
			'settings.presetTheme' => 'プリセットテーマ',
			'settings.basicTheme' => 'ベーシックテーマ',
			'settings.needRestartToApply' => 'アプリを再起動して設定を適用してください',
			'settings.themeNeedRestartDescription' => 'テーマ設定はアプリを再起動して設定を適用してください',
			'settings.about' => 'アバウト',
			'settings.diagnosticsAndFeedback' => '診断とフィードバック',
			'settings.currentVersion' => '現在のバージョン',
			'settings.latestVersion' => '最新バージョン',
			'settings.checkForUpdates' => '更新をチェック',
			'settings.update' => '更新',
			'settings.newVersionAvailable' => '新しいバージョンが利用可能です',
			'settings.projectHome' => 'プロジェクトホーム',
			'settings.release' => 'リリース',
			'settings.issueReport' => '問題報告',
			'settings.openSourceLicense' => 'オープンソースライセンス',
			'settings.checkForUpdatesFailed' => '更新のチェックに失敗しました。後でもう一度お試しください',
			'settings.autoCheckUpdate' => '自動更新',
			'settings.updateContent' => '更新内容',
			'settings.releaseDate' => 'リリース日',
			'settings.ignoreThisVersion' => 'このバージョンを無視',
			'settings.forceUpdateTip' => 'これは必須アップデートです。できるだけ早く最新バージョンにアップデートしてください',
			'settings.viewChangelog' => '更新内容を表示',
			'settings.alreadyLatestVersion' => 'すでに最新バージョンです',
			'settings.appSettings' => 'アプリ設定',
			'settings.configureYourAppSettings' => 'アプリ設定を設定',
			'settings.history' => '履歴',
			'settings.autoRecordHistory' => '自動記録履歴',
			'settings.autoRecordHistoryDesc' => '視聴した動画やギャラリーなどの情報を自動的に記録します',
			'settings.autoDeleteHistory' => '履歴の自動削除',
			'settings.autoDeleteHistoryDesc' => '起動時に保存日数を超えた閲覧履歴を自動的に削除します（デフォルトはオフ）',
			'settings.autoDeleteHistoryDays' => '保存日数',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => '直近 ${num} 日間を保存',
			'settings.autoDeleteHistoryDaysInvalid' => '有効な日数を入力してください（1日以上）',
			'settings.showUnprocessedMarkdownText' => '未処理のMarkdownテキストを表示',
			'settings.showUnprocessedMarkdownTextDesc' => 'Markdownの元のテキストを表示',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'プライバシーモード',
			'settings.activeBackgroundPrivacyModeDesc' => 'スクリーンショットと画面録画を禁止し、バックグラウンドでは画面を隠します',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'バックグラウンドに移ると画面を隠します（このプラットフォームではスクリーンショットを防げません）',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'スクリーンショットと画面録画を禁止します',
			'settings.privacy' => 'プライバシー',
			'settings.appLock' => 'アプリロック',
			'settings.appLockEnabled' => 'アプリロックを有効にする',
			'settings.appLockEnabledDesc' => 'アプリを開くときに PIN または生体認証を要求し、バックグラウンドの画面も自動的に隠します',
			'settings.appLockEnabledSummary' => 'オン · PIN で保護',
			'settings.appLockDisabledSummary' => 'オフ',
			'settings.appLockTimeout' => 'アプリを離れた後にロック',
			'settings.appLockTimeoutDesc' => 'バックグラウンド移行後、再認証を要求するまでの時間',
			'settings.appLockAfterScreenOff' => '画面ロック後にロック',
			'settings.appLockAfterScreenOffDesc' => '端末の画面ロック後、アプリに戻るときに再認証を要求します',
			'settings.appLockTimeoutDisabled' => '無効',
			'settings.appLockImmediately' => 'すぐに',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} 秒',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} 分',
			'settings.appLockUseBiometrics' => '生体認証を使用',
			'settings.appLockUseBiometricsDesc' => '指紋認証または顔認証でロックを解除します',
			'settings.appLockBiometricsUnavailable' => 'この端末で利用できる生体認証がありません',
			'settings.appLockSetPin' => 'PIN を設定',
			'settings.appLockEnterPin' => 'PIN を入力',
			'settings.appLockConfirmPin' => 'PIN を確認',
			'settings.appLockCurrentPin' => '現在の PIN を入力',
			'settings.appLockNewPin' => '新しい PIN を入力',
			'settings.appLockPinRequirements' => 'PIN は 4～8 桁の数字にしてください',
			'settings.appLockPinsDoNotMatch' => 'PIN が一致しません',
			'settings.appLockInvalidPin' => 'PIN が正しくありません',
			'settings.appLockSetupFailed' => 'PIN を安全に保存できませんでした',
			'settings.appLockDisable' => 'アプリロックを無効にするには PIN を入力してください',
			'settings.appLockChangePin' => 'PIN を変更',
			'settings.appLockNow' => '今すぐロック',
			'settings.appLockUnlock' => 'ロック解除',
			'settings.appLockLockedTitle' => 'ロックされています',
			'settings.appLockLockedDesc' => '続行するには認証してください',
			'settings.appLockAuthenticateReason' => 'ロックを解除するために認証してください',
			'settings.appLockEnableBiometricsReason' => '生体認証によるロック解除を有効にするために認証してください',
			'settings.appLockBiometricFailed' => '生体認証を完了できませんでした',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => '試行回数が多すぎます。${seconds} 秒後に再試行してください',
			'settings.appLockCredentialUnavailableTitle' => 'アプリロックの認証情報を読み取れません',
			'settings.appLockCredentialUnavailableDesc' => 'システムのセキュアストレージが一時的に利用できないか、認証情報が破損しています。アプリはロックされたままです。まず再試行してください。それでも失敗する場合はアプリロックをリセットできます（アプリロックが無効になり、保存済みの PIN が削除されます）。',
			'settings.appLockRetry' => '再試行',
			'settings.appLockReset' => 'アプリロックをリセット',
			'settings.appLockResetAction' => 'リセット',
			'settings.appLockResetConfirmTitle' => 'アプリロックをリセットしますか？',
			'settings.appLockResetConfirmDesc' => 'アプリロックを無効にし、保存済みの PIN と生体認証設定を削除します。後で再設定できます。',
			'settings.appLockRetrySucceeded' => '認証情報を読み取れました。PIN を入力してください。',
			'settings.appLockRetryFailed' => '認証情報を読み取れませんでした',
			'settings.forum' => 'フォーラム',
			'settings.news' => 'ニュース',
			'settings.community' => 'コミュニティ',
			'settings.disableForumReplyQuote' => 'フォーラム返信引用を無効にする',
			'settings.disableForumReplyQuoteDesc' => 'フォーラム返信時の返信階層情報の携帯を無効にする',
			'settings.theaterMode' => '劇院モード',
			'settings.theaterModeDesc' => '開啟後、プレーヤー背景がビデオカバーのぼかしバージョンに設定されます',
			'settings.appLinks' => 'アプリリンク',
			'settings.defaultBrowser' => 'デフォルトブラウザ',
			'settings.defaultBrowserDesc' => 'システム設定でデフォルトリンク設定項目を開き、iwara.tvサイトリンクを追加してください',
			'settings.themeMode' => 'テーマモード',
			'settings.themeModeDesc' => 'この設定はアプリのテーマモードを決定します',
			'settings.glassEffect' => '画面のマテリアル',
			'settings.glassEffectDesc' => 'アプリ全体（ヘッダーのカプセル、メニュー、ダイアログのボタン、ボトムナビゲーション）に使う素材を決めます',
			'settings.liquidGlassEffect' => 'リキッドガラス',
			'settings.liquidGlassEffectDesc' => '本物のぼかしと屈折を使う素材。見た目は最高ですが、低スペック端末ではコマ落ちや電池消費が増えることがあります',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => '標準的な Material 3 の画面。不透明でぼかしも影もなく、動作と電池持ちが最も良好です',
			'settings.glassEffectIntroTitle' => '画面のマテリアルを選ぶ',
			'settings.glassEffectIntroContent' => '現在はヘッダー・タブバー・メニューがリキッドガラス（本物のぼかしと屈折）です。端末で重いと感じる場合やシンプルな見た目が好みなら、今すぐ Material（不透明・ぼかしなし・影なし）に切り替えられます。',
			'settings.glassEffectIntroHint' => '後からでも「設定 → テーマ設定 → 画面のマテリアル」でいつでも変更できます。',
			'settings.glassEffectIntroDone' => 'これでOK',
			'settings.dynamicColor' => 'ダイナミックカラー',
			'settings.dynamicColorDesc' => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します',
			'settings.useDynamicColor' => 'ダイナミックカラーを使用',
			'settings.useDynamicColorDesc' => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します',
			'settings.presetColors' => 'プリセットカラー',
			'settings.customColors' => 'カスタムカラー',
			'settings.customColorsDisabledByDynamicColor' => 'ダイナミックカラーが有効なため、プリセット/カスタムカラーは使用できません。先にダイナミックカラーをオフにしてください',
			'settings.pickColor' => 'カラーを選択',
			'settings.cancel' => 'キャンセル',
			'settings.confirm' => '確認',
			'settings.noCustomColors' => 'カスタムカラーがありません',
			'settings.recordAndRestorePlaybackProgress' => '再生進度を記録して復元',
			'settings.autoPlayVideoOnFirstEnter' => '初回入場時に動画を自動再生',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'この設定は、動画ページに初めて入った時に動画を自動再生するかどうかを決定します。',
			'settings.autoEnterFullscreen' => '自動で全画面にする',
			'settings.autoEnterFullscreenDesc' => 'プレイヤーが自動で全画面に移行するタイミング。非公開／削除済みの動画、外部サイトの動画、およびピクチャインピクチャ中は常に移行しません',
			'settings.autoEnterFullscreenOff' => 'オフ',
			'settings.autoEnterFullscreenOffDesc' => '自動では全画面にしない',
			'settings.autoEnterFullscreenOnPlaybackStart' => '再生開始時',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => '再生が実際に始まった瞬間に全画面へ移行する',
			'settings.autoEnterFullscreenOnDetailPageEnter' => '動画を開いた時',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => '再生を待たず、動画ページを開いた時点で全画面へ移行する',
			'settings.autoEnterFullscreenKind' => '全画面の種類',
			'settings.autoEnterFullscreenKindDesc' => '自動でどちらの全画面にするか。デスクトップ版のみ',
			'settings.autoEnterFullscreenKindSystem' => 'システム全画面',
			'settings.autoEnterFullscreenKindSystemDesc' => 'ウィンドウマネージャーにウィンドウを全画面にさせる',
			'settings.autoEnterFullscreenKindApp' => 'アプリ全画面',
			'settings.autoEnterFullscreenKindAppDesc' => 'ウィンドウの大きさは変えず、アプリ全体をプレイヤーにする',
			'settings.signature' => '小尾巴',
			'settings.enableSignature' => '小尾巴を有効にする',
			'settings.enableSignatureDesc' => 'この設定はアプリが回覆時に小尾巴を有効にするかどうかを決定します',
			'settings.enterSignature' => '小尾巴を入力',
			'settings.editSignature' => '小尾巴を編集',
			'settings.signatureContent' => '小尾巴の内容',
			'settings.signaturePreview' => 'プレビュー',
			'settings.signatureSampleBody' => 'ここに本文が入ります',
			'settings.signatureRegenerate' => '別の一言にする',
			'settings.signatureNotSet' => '未設定',
			'settings.signatureRuleHint' => '署名は本文の後ろに、区切り線を挟んで付きます。区切り線はアプリが入れるので、下の一文だけ書いてください。',
			'settings.signatureInsertVariable' => '変数を挿入',
			'settings.varDate' => '日付',
			'settings.varTime' => '時刻',
			'settings.varDatetime' => '日付と時刻',
			'settings.varWeekday' => '曜日',
			'settings.varApp' => 'アプリ名',
			'settings.varVersion' => 'バージョン',
			'settings.varPlatform' => 'プラットフォーム',
			'settings.varTitle' => '今見ている作品',
			'settings.varAuthor' => 'その作者',
			'settings.varPick' => 'ランダムな一文',
			'settings.signatureSources' => 'データソース',
			'settings.signatureAutoTranslate' => '自分の言語に翻訳する',
			'settings.signatureAutoTranslateDesc' => '一言のようなデータソースは今のところ中国語だけです。取得した一文は送信の直前に翻訳されます。',
			'settings.signatureWizardTitle' => 'データソースを追加',
			'settings.signatureWizardUrlTitle' => 'エンドポイントのURL',
			'settings.signatureWizardUrlHint' => '一文を返してくれるURLを入力してください。下のボタンで実際に一度呼び出して、何が返ってくるか確かめます。',
			'settings.signatureWizardFetch' => '取得してみる',
			'settings.signatureWizardSkipTest' => 'スキップして名前だけ変える',
			'settings.signatureWizardPickTitle' => '使いたい部分を選ぶ',
			'settings.signatureWizardPickHint' => 'これがそのエンドポイントから返ってきた内容です。署名に出したい行をタップしてください。',
			'settings.signatureWizardPickPlainHint' => 'このエンドポイントはテキストをそのまま返しました。全体がそのまま表示されます。',
			'settings.signatureWizardWholeBody' => 'レスポンス全体',
			'settings.signatureWizardNameTitle' => '名前をつける',
			'settings.signatureWizardNameHint' => '名前はあなたが見分けるためのものです。署名から指し示すのは下の参照名のほうです。',
			'settings.signatureWizardNext' => '次へ',
			'settings.signatureWizardDone' => '完了',
			'settings.signatureWizardStripHtml' => 'HTMLタグを取り除く',
			'settings.signatureWizardAdvanced' => '詳細：正規表現で抜き出す',
			'settings.signatureWizardExtractHint' => '正規表現。最初のキャプチャグループを使います',
			'settings.signatureWizardExtractMissed' => 'この式に一致しなかったので、そのままの文字列を使います',
			'settings.signatureWizardChooseTitle' => '選んでください',
			'settings.signatureWizardChooseHint' => '用意されたものを選べばそれで完了です。自分のエンドポイントを指定することもできます。',
			'settings.signatureWizardCustomSource' => '自分のエンドポイントを使う',
			'settings.signatureWizardWithOrigin' => '出典も付ける',
			'settings.signatureWizardRandomItem' => '毎回ランダムに選ぶ',
			'settings.signatureWizardSuffixTitle' => 'もう一つの項目をつなげる',
			'settings.signatureWizardSuffixNone' => 'なし',
			'settings.signatureOptFlavor' => '内容',
			'settings.signatureOptFlavorAny' => '指定しない',
			'settings.signatureOptFlavorOtaku' => 'アニメ・漫画・ゲーム',
			'settings.signatureOptFlavorLiterary' => '文学・詩',
			'settings.signatureOptFlavorMeme' => 'ネット文化',
			'settings.signatureOptLength' => '長さ',
			'settings.signatureOptLengthAny' => '指定しない',
			'settings.signatureOptLengthShort' => '短い一文だけ',
			'settings.signatureRestoreDefault' => '既定に戻す',
			'settings.signatureSourceHitokoto' => 'ひとこと',
			'settings.signatureAiSourceName' => 'AI ひとこと',
			'settings.signatureEditTextHint' => 'このコメントに既に書かれている署名です。一言も日付も今はただの文字なので自由に直せます。空にすれば署名なしになります。',
			'settings.signatureResolving' => ({required Object name}) => '${name}を生成中…',
			'settings.signaturePendingValue' => '（送信時に生成）',
			'settings.signatureAiHint' => 'AI がその場で書く一言。コメントごとに新しくなります。設定した AI プロバイダーを使います。',
			'settings.signatureAiUnavailable' => 'AI プロバイダーが未設定のため、変数パネルには表示されません。',
			'settings.signaturePromptTitle' => 'プロンプト',
			'settings.signaturePromptHint' => 'モデルに送られるのがこれです。口調も長さも題材も自由に書き換えてかまいません。既に入っているルールは残す価値があります。',
			'settings.signaturePromptReset' => '既定に戻す',
			'settings.signaturePromptTry' => '試す',
			'settings.signaturePromptSample' => '書かれたもの',
			'settings.signaturePromptLanguageHint' => 'は表示言語に置き換わります。削除するとプロンプトの言語に従います。',
			'settings.signaturePromptEdited' => '変更済み',
			'settings.signatureVariablesGroup' => '組み込み変数',
			'settings.signatureNeedsNetwork' => 'ネットワークが必要',
			'settings.signatureBuiltinSource' => '標準',
			'settings.signatureSourceIdReserved' => 'その名前は組み込み変数が使っています',
			'settings.signatureSourcesTitle' => 'カスタムデータソース',
			'settings.signatureSourcesHint' => '一文を返すエンドポイントを指定すれば、その内容を署名に取り込めます。',
			'settings.signatureSourcesEmpty' => 'データソースはまだありません',
			'settings.signatureAddSource' => '追加',
			'settings.signatureEditSource' => 'データソースを編集',
			'settings.signatureSourceName' => '名前',
			'settings.signatureSourceId' => '参照名',
			'settings.signatureSourceIdHint' => '署名からこのデータソースを呼ぶときの名前',
			'settings.signatureSourceUrl' => 'エンドポイントURL',
			'settings.signatureSourcePath' => '値のパス',
			'settings.signatureSourcePathHint' => 'レスポンス全体がその一文なら空のままに。JSON から取り出す場合は data.text のように指定します。',
			'settings.signatureSourceTest' => 'テスト',
			'settings.signatureSourceTestOk' => '取得できました',
			'settings.signatureSourceTestFailed' => '何も返ってきませんでした',
			'settings.signatureSourceIdInvalid' => '参照名に使えるのは小文字・数字・アンダースコアだけです',
			'settings.signatureSourceIdDuplicate' => 'その参照名はすでに使われています',
			'settings.signatureSourceUrlRequired' => 'エンドポイントURLを入力してください',
			'settings.exportConfig' => 'アプリ設定をエクスポート',
			'settings.exportConfigDesc' => '設定と履歴（閲覧履歴、再生進捗、お気に入りなど）をファイルにエクスポートし、バックアップや他のデバイスへの同期に利用できます。ダウンロードタスクは含まれません。',
			'settings.importConfig' => 'アプリ設定をインポート',
			'settings.importConfigDesc' => 'ファイルからアプリ設定をインポートします',
			'settings.exportConfigSuccess' => '設定が正常にエクスポートされました',
			'settings.exportConfigFailed' => '設定のエクスポートに失敗しました',
			'settings.importConfigSuccess' => '設定が正常にインポートされました',
			'settings.importConfigFailed' => '設定のインポートに失敗しました',
			'settings.exportIncludeSensitive' => '機密情報を含める',
			'settings.exportIncludeSensitiveDesc' => 'APIキー、セッショントークン、プロキシアドレスを含みます。自分のデバイスにバックアップする場合のみ有効にしてください。',
			'settings.importConfigOverwriteWarning' => 'インポートすると現在の設定と履歴（閲覧履歴、再生進捗、お気に入りなど）が上書きされます。続行しますか？',
			'settings.importConfigRestartTitle' => 'インポート完了',
			'settings.importConfigRestartContent' => '設定をインポートしました。すべての変更を反映するには、アプリを完全に終了してから再起動してください。',
			'settings.historyUpdateLogs' => '歴代アップデートログ',
			'settings.noUpdateLogs' => 'アップデートログが取得できませんでした',
			'settings.versionLabel' => 'バージョン: {version}',
			'settings.releaseDateLabel' => 'リリース日: {date}',
			'settings.noChanges' => '更新内容がありません',
			'settings.interaction' => 'インタラクション',
			'settings.enableVibration' => 'バイブレーション',
			'settings.enableVibrationDesc' => 'アプリの操作時にバイブレーションフィードバックを有効にする',
			'settings.defaultKeepVideoToolbarVisible' => 'ツールバーを常に表示',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'この設定は、動画ページに入った時にツールバーを常に表示するかどうかを決定します。',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'モバイル端でシアターモードを有効にすると、パフォーマンスの問題が発生する可能性があるため、状況に応じてご利用ください。',
			'settings.fullscreenOrientation' => 'フルスクリーン時のデフォルト画面方向',
			'settings.fullscreenOrientationDesc' => 'この設定は、フルスクリーン時のデフォルト画面方向を決定します（モバイルのみ）',
			'settings.fullscreenOrientationLeftLandscape' => '左横画面',
			'settings.fullscreenOrientationRightLandscape' => '右横画面',
			'settings.screenFit' => '画面サイズ',
			'settings.screenFitDesc' => 'プレイヤー内での映像の表示方法を選択します。',
			'settings.rememberScreenFit' => '画面サイズを記憶',
			'settings.rememberScreenFitDesc' => '有効にすると、以降開く動画に現在の選択が適用されます。',
			'settings.screenFitFit' => 'フィット',
			'settings.screenFitFitDesc' => 'アスペクト比を保ったまま全体を表示します',
			'settings.screenFitStretch' => 'ストレッチ',
			'settings.screenFitStretchDesc' => '再生領域いっぱいに引き伸ばします（変形する場合があります）',
			'settings.screenFitCover' => 'クロップ',
			'settings.screenFitCoverDesc' => 'アスペクト比を保ったまま領域を埋め、はみ出た部分は切り取られます',
			'settings.screenFitRatioDesc' => 'この比率に引き伸ばして表示します（変形する場合があります）',
			'settings.jumpLink' => 'リンクをジャンプ',
			'settings.language' => '言語',
			'settings.languageNativeName' => '日本語',
			'settings.followSystemLanguage' => 'システムに従う',
			'settings.languageChangedMessage' => '言語が正常に変更されました。一部の機能はアプリを再起動して有効にする必要があります。',
			'settings.languageChanged' => '言語設定が変更されました。アプリを再起動して有効にしてください。',
			'settings.keybinding.title' => 'キーボードショートカット',
			'settings.keybinding.entryLabel' => 'キーボードショートカット',
			'settings.keybinding.entryDesc' => 'アプリのキーボードショートカットをカスタマイズ（主にデスクトップ向け）',
			'settings.keybinding.desktopHint' => 'ショートカットは主にデスクトップのキーボードで有効です。モバイルでは通常ジェスチャーを使用します。',
			'settings.keybinding.resetAll' => 'すべて既定に戻す',
			'settings.keybinding.resetAllConfirm' => 'すべてのショートカットを既定に戻しますか？',
			'settings.keybinding.resetToDefault' => '既定に戻す',
			'settings.keybinding.resetScope' => 'このセクションを既定に戻す',
			'settings.keybinding.notSet' => '未設定',
			'settings.keybinding.addShortcut' => 'ショートカットを追加',
			'settings.keybinding.removeShortcut' => 'このショートカットを削除',
			'settings.keybinding.pressNewShortcut' => '新しいショートカットを押してください…',
			'settings.keybinding.recordingCancelHint' => 'Esc でキャンセル',
			'settings.keybinding.mouseHint' => 'マウスのサイドボタン（戻る / 進む）や中ボタンも割り当て可能です',
			'settings.keybinding.mouseNotSupportedInScope' => 'このエリアはマウスボタンを処理しません。キーボードを使用してください',
			'settings.keybinding.capabilityKeyboardOnly' => 'このエリアはキーボードのみ受け付けます',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'このエリアはキーボードと、マウスの中ボタン / サイドボタンを受け付けます',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'このエリアはキーボードと、マウスの中ボタン / 進むボタンを受け付けます（戻るボタンはシステムが使用中）',
			'settings.keybinding.rejectMultipleButtons' => 'マウスボタンは一度に一つだけ押してください',
			'settings.keybinding.rejectPlatformBack' => 'このキーはシステムが「戻る」に使用しており、割り当てると二重に戻ります',
			'settings.keybinding.detectedLabel' => '検出',
			'settings.keybinding.reservedKey' => 'このキーはシステム予約のため割り当てできません',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'このキーは「${action}」に割り当てられています。ここから戻れなくなるため、この領域では予約されています',
			'settings.keybinding.conflictTitle' => 'ショートカットの競合',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'この組み合わせは既に「${action}」に割り当てられています。続行すると既存の割り当ては解除されます。',
			'settings.keybinding.conflictContinue' => 'それでも割り当てる',
			'settings.keybinding.shadowWarningTitle' => 'グローバルショートカットの重複',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'この組み合わせは既に「${action}」にグローバル割り当てされています。ここで割り当てると、このセクション内ではその動作が上書きされます。',
			'settings.keybinding.globalShadowedMessage' => ({required Object scope, required Object action}) => 'この組み合わせは既に「${scope}」で「${action}」に割り当てられています。そのセクション内では、このグローバルショートカットは上書きされます。',
			'settings.keybinding.searchHint' => 'ショートカットを検索…',
			'settings.keybinding.scopeGlobal' => 'グローバル',
			'settings.keybinding.scopeGallery' => 'ギャラリー',
			'settings.keybinding.scopeVideo' => '動画',
			'settings.keybinding.categoryNavigation' => 'ナビゲーション',
			'settings.keybinding.categoryZoom' => 'ズーム',
			'settings.keybinding.categoryPlayback' => '再生',
			'settings.keybinding.categorySeek' => 'シーク',
			'settings.keybinding.categoryVolume' => '音量',
			'settings.keybinding.categoryDisplay' => '表示',
			'settings.keybinding.actionGlobalBack' => '戻る',
			'settings.keybinding.actionGalleryNext' => '次の写真',
			'settings.keybinding.actionGalleryPrevious' => '前の写真',
			'settings.keybinding.actionGalleryZoomIn' => 'ズームイン',
			'settings.keybinding.actionGalleryZoomOut' => 'ズームアウト',
			'settings.keybinding.actionGalleryResetZoom' => 'ズームリセット',
			'settings.keybinding.actionGalleryPlayPause' => '再生 / 一時停止',
			'settings.keybinding.actionGallerySeekBackward' => '巻き戻し',
			'settings.keybinding.actionGallerySeekForward' => '早送り',
			'settings.keybinding.actionGalleryToggleMute' => 'ミュート切替',
			'settings.keybinding.actionPlayPause' => '再生 / 一時停止',
			'settings.keybinding.actionSpeedUp' => '再生速度を上げる',
			'settings.keybinding.actionSpeedDown' => '再生速度を下げる',
			'settings.keybinding.actionSeekForward' => '早送り',
			'settings.keybinding.actionSeekBackward' => '巻き戻し',
			'settings.keybinding.actionVolumeUp' => '音量を上げる',
			'settings.keybinding.actionVolumeDown' => '音量を下げる',
			'settings.keybinding.actionToggleMute' => 'ミュート切替',
			'settings.keybinding.actionToggleFullscreen' => '全画面切替',
			'settings.keybinding.seekLongPressHint' => '早送り / 巻き戻しキーを長押しすると長押し速度モードになります',
			'settings.keybinding.zoomSectionTitle' => '画面ズーム（固定）',
			'settings.keybinding.zoomFixedNote' => '以下のショートカットは固定で変更できません',
			'settings.keybinding.zoomScaleLabel' => '画面をズーム',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + ホイール',
			'settings.keybinding.zoomRotateLabel' => '画面を回転',
			'settings.keybinding.zoomRotateHint' => 'Shift + ホイール',
			'settings.keybinding.zoomPinchGesture' => 'ピンチ',
			'settings.keybinding.zoomTwoFingerRotateGesture' => '2本指で回転',
			'settings.gestureControl' => 'ジェスチャー制御',
			'settings.leftDoubleTapRewind' => '左側ダブルタップリワインド',
			'settings.rightDoubleTapFastForward' => '右側ダブルタップファストフォワード',
			'settings.doubleTapPause' => 'ダブルタップポーズ',
			'settings.rightVerticalSwipeVolume' => '右側垂直スワイプボリューム（新ページに入った時に有効）',
			'settings.leftVerticalSwipeBrightness' => '左側垂直スワイプブライトネス（新ページに入った時に有効）',
			'settings.longPressFastForward' => '長押しファストフォワード',
			'settings.enableMouseHoverShowToolbar' => 'マウスホバー時にツールバーを表示',
			'settings.enableMouseHoverShowToolbarInfo' => '有効にすると、マウスがプレーヤー上にあるときにツールバーが表示されます。3秒間の非アクティブ時に自動的に非表示になります。',
			'settings.enableHorizontalDragSeek' => '横スワイプでシーク',
			'settings.enableVideoGestureZoom' => 'ピンチで映像を拡大',
			'settings.enableVideoGestureZoomInfo' => '2本指のピンチ（デスクトップでは Ctrl + マウスホイール）で映像を拡大し、拡大後はドラッグで移動できます。',
			'settings.showCenterPlayPauseButton' => '中央の再生/一時停止ボタン',
			'settings.showCenterPlayPauseButtonDesc' => 'プレーヤー中央の大きな再生/一時停止ボタンを表示します。',
			'settings.audioVideoConfig' => 'オーディオビデオ設定',
			'settings.expandBuffer' => 'バッファ拡張',
			'settings.expandBufferInfo' => '有効にすると、バッファサイズが増加し、読み込み時間が長くなりますが、再生がスムーズになります',
			'settings.videoSyncMode' => 'ビデオ同期モード',
			'settings.videoSyncModeSubtitle' => 'オーディオビデオ同期戦略',
			'settings.hardwareDecodingMode' => 'ハードウェアデコードモード',
			'settings.hardwareDecodingModeSubtitle' => 'ハードウェアデコード設定',
			'settings.enableHardwareAcceleration' => 'ハードウェアアクセラレーションを有効にする',
			'settings.enableHardwareAccelerationInfo' => 'ハードウェアアクセラレーションを有効にすると、デコード性能が向上しますが、一部のデバイスでは互換性がない場合があります',
			'settings.useOpenSLESAudioOutput' => 'OpenSLESオーディオ出力を使用',
			'settings.useOpenSLESAudioOutputInfo' => '低遅延オーディオ出力を使用し、オーディオ性能が向上する可能性があります',
			'settings.videoSyncAudio' => 'オーディオ同期',
			'settings.videoSyncDisplayResample' => 'ディスプレイリサンプル',
			'settings.videoSyncDisplayResampleVdrop' => 'ディスプレイリサンプル（フレームドロップ）',
			'settings.videoSyncDisplayResampleDesync' => 'ディスプレイリサンプル（非同期）',
			'settings.videoSyncDisplayTempo' => 'ディスプレイテンポ',
			'settings.videoSyncDisplayVdrop' => 'ディスプレイビデオフレームドロップ',
			'settings.videoSyncDisplayAdrop' => 'ディスプレイオーディオフレームドロップ',
			'settings.videoSyncDisplayDesync' => 'ディスプレイ非同期',
			'settings.videoSyncDesync' => '非同期',
			'settings.forumSettings.name' => 'フォーラム',
			'settings.forumSettings.configureYourForumSettings' => 'フォーラム設定を構成する',
			'settings.gallerySettings.gallerySettingsTitle' => 'ギャラリー設定',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'ギャラリービューアの設定',
			'settings.gallerySettings.defaultViewerQuality' => 'デフォルト画質',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'ギャラリービューアを開いたときに表示する画質を選択します。',
			'settings.blockSettings.title' => 'コンテンツブロック',
			'settings.blockSettings.subtitle' => 'タイトルがキーワードや正規表現に一致する、またはブロックしたユーザーの投稿を自動的に非表示にします。判定はすべて端末内で行われ、アップロードされません。',
			'settings.blockSettings.blocked' => 'ブロック済み',
			'settings.blockSettings.reveal' => '表示',
			'settings.blockSettings.reblock' => '再ブロック',
			'settings.blockSettings.why' => '非表示の理由',
			'settings.blockSettings.manageRules' => 'ルールを管理',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'タイトルに「${value}」を含む',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'タイトルが正規表現「${value}」に一致',
			'settings.blockSettings.reasonUser' => 'ブロックしたユーザー',
			'settings.blockSettings.addRule' => 'ルールを追加',
			'settings.blockSettings.editRule' => 'ルールを編集',
			'settings.blockSettings.deleteRule' => 'ルールを削除',
			'settings.blockSettings.ruleType' => 'ルールの種類',
			'settings.blockSettings.keyword' => 'キーワード',
			'settings.blockSettings.regex' => '正規表現',
			'settings.blockSettings.userId' => 'ユーザー',
			'settings.blockSettings.value' => '一致させる内容',
			'settings.blockSettings.caseSensitive' => '大文字小文字を区別',
			'settings.blockSettings.regexHint' => '例 予告|特典',
			'settings.blockSettings.valueRequired' => '一致させる内容を入力してください',
			'settings.blockSettings.invalidRegex' => '正規表現の形式が正しくありません',
			'settings.blockSettings.noRules' => 'ルールがありません。右下の + で追加できます。',
			'settings.blockSettings.blockUser' => 'ブロック',
			'settings.blockSettings.unblockUser' => 'ブロック解除',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => '「${name}」をブロックしますか？その動画とギャラリーは一覧と検索で非表示になります。',
			'settings.blockSettings.userBlocked' => 'ユーザーをブロックしました',
			'settings.blockSettings.userUnblocked' => 'ブロックを解除しました',
			'settings.blockSettings.exportRules' => 'エクスポート',
			'settings.blockSettings.importRules' => 'インポート',
			'settings.blockSettings.importExport' => 'インポート / エクスポート',
			'settings.blockSettings.exportSuccess' => 'ルールをエクスポートしました',
			'settings.blockSettings.exportFailed' => 'エクスポートに失敗しました',
			'settings.blockSettings.importSuccess' => ({required Object count}) => '${count} 件のルールをインポートしました',
			'settings.blockSettings.importFailed' => 'インポートに失敗しました',
			'settings.blockSettings.regexHelp' => '正規表現ヘルプ',
			'settings.blockSettings.regexHelpTitle' => '正規表現リファレンス',
			'settings.blockSettings.regexHelpIntro' => '正規表現はキーワードより柔軟にタイトルを照合できます。よく使う例：',
			'settings.blockSettings.regexHelpTapHint' => '例をタップするとそのまま入力されます。',
			'settings.blockSettings.regexEx1Pattern' => '予告|特典|おまけ',
			'settings.blockSettings.regexEx1Desc' => '「|」でいずれかに一致（「または」の意味）',
			'settings.blockSettings.regexEx2Pattern' => '^【.*】',
			'settings.blockSettings.regexEx2Desc' => '【…】で始まるタイトルに一致',
			'settings.blockSettings.regexEx3Pattern' => '総集編\$',
			'settings.blockSettings.regexEx3Desc' => '「総集編」で終わるタイトルに一致',
			'settings.blockSettings.regexEx4Pattern' => '第.話',
			'settings.blockSettings.regexEx4Desc' => '「.」は任意の1文字（「第1話」「第X話」に一致）',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '「\\d」は数字、{4} は4桁（年など）',
			'settings.blockSettings.regexEx1Sample' => '新作の予告公開中',
			'settings.blockSettings.regexEx2Sample' => '【総集編】夏まつり',
			'settings.blockSettings.regexEx3Sample' => '夏まつり 総集編',
			'settings.blockSettings.regexEx4Sample' => '番外 第3話 配信',
			'settings.blockSettings.regexEx5Sample' => '2024 年ベスト',
			'settings.blockSettings.regexHelpSampleLabel' => 'タイトル例',
			'settings.blockSettings.regexHelpMatchedTag' => 'ブロック対象',
			'settings.blockSettings.regexHelpNoMatch' => '一致なし',
			'settings.blockSettings.regexEx6Pattern' => '[完未]結',
			'settings.blockSettings.regexEx6Desc' => '「[完未]」は「完」か「未」のどちらか1文字、完結 / 未結 に一致',
			'settings.blockSettings.regexEx6Sample' => 'アニメ 完結 記念',
			'settings.blockSettings.regexEx7Pattern' => '(予告|宣伝)映像',
			'settings.blockSettings.regexEx7Desc' => '丸括弧 () で複数の語をグループ化、予告映像 か 宣伝映像 に一致',
			'settings.blockSettings.regexEx7Sample' => '最新宣伝映像',
			'settings.blockSettings.regexEx8Pattern' => '予告(編)?',
			'settings.blockSettings.regexEx8Desc' => '(編)? は「編」があってもなくてもよい、予告 か 予告編 に一致',
			'settings.blockSettings.regexEx8Sample' => '新作予告 公開',
			'settings.blockSettings.regexEx9Pattern' => 'w+',
			'settings.blockSettings.regexEx9Desc' => '「+」は1個以上、w・ww・www に一致',
			'settings.blockSettings.regexEx9Sample' => '面白いwww 動画',
			'settings.blockSettings.regexEx10Pattern' => '予告.*版',
			'settings.blockSettings.regexEx10Desc' => '「.*」は間の任意の文字に一致、「予告…版」に一致',
			'settings.blockSettings.regexEx10Sample' => '予告 完全版 公開',
			'settings.chatSettings.name' => 'チャット',
			'settings.chatSettings.configureYourChatSettings' => 'チャット設定を構成する',
			'settings.hardwareDecodingAuto' => '自動',
			'settings.hardwareDecodingAutoCopy' => '自動コピー',
			'settings.hardwareDecodingAutoSafe' => '自動セーフ',
			'settings.hardwareDecodingNo' => '無効',
			'settings.hardwareDecodingYes' => '強制有効',
			'settings.cdnDistributionStrategy' => 'コンテンツ配信戦略',
			'settings.cdnDistributionStrategyDesc' => '動画ソースサーバーの配信戦略を選択して、読み込み速度を最適化します',
			'settings.cdnDistributionStrategyLabel' => '配信戦略',
			'settings.cdnDistributionStrategyNoChange' => '変更なし（元のサーバーを使用）',
			'settings.cdnDistributionStrategyAuto' => '自動選択（最速サーバー）',
			'settings.cdnDistributionStrategySpecial' => 'サーバーを指定',
			'settings.cdnSpecialServer' => 'サーバーを指定',
			'settings.cdnRefreshServerListHint' => '下のボタンをクリックしてサーバーリストを更新してください',
			'settings.cdnRefreshButton' => '更新',
			'settings.cdnFastRingServers' => '高速リングサーバー',
			'settings.cdnRefreshServerListTooltip' => 'サーバーリストを更新',
			'settings.cdnSpeedTestButton' => '速度テスト',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'テスト中 (${count})',
			_ => null,
		} ?? switch (path) {
			'settings.cdnNoServerDataHint' => 'サーバーデータがありません、更新ボタンをクリックしてください',
			'settings.cdnTestingStatus' => 'テスト中',
			'settings.cdnUnreachableStatus' => '到達不可',
			'settings.cdnNotTestedStatus' => '未テスト',
			'settings.downloadSettings.downloadSettings' => 'ダウンロード設定',
			'settings.downloadSettings.enableDownloadNotifications' => 'ダウンロード通知',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => '単一のダウンロードが完了または失敗したときにシステム通知を表示します',
			'settings.downloadSettings.notificationPermissionDenied' => '通知権限が拒否されました。アプリ内通知は引き続き利用できます。システム通知が必要な場合は設定で有効にしてください。',
			'settings.downloadSettings.storagePermissionStatus' => 'ストレージ権限状態',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'パブリックディレクトリにアクセスするにはストレージ権限が必要です',
			'settings.downloadSettings.checkingPermissionStatus' => '権限状態を確認中...',
			'settings.downloadSettings.storagePermissionGranted' => 'ストレージ権限が付与されました',
			'settings.downloadSettings.storagePermissionNotGranted' => 'ストレージ権限が付与されていません',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'ストレージ権限が付与されました',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'ストレージ権限が付与されませんでしたが、一部の機能が制限される可能性があります',
			'settings.downloadSettings.storagePermissionRationale' => '選択した場所にファイルを保存するには、ストレージ権限が必要です。\n\nAndroid 11 以降では公開ディレクトリへの書き込みに「すべてのファイルへのアクセス」権限が必要です。許可しない場合、ファイルはアプリ専用ディレクトリに保存されます。',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => '選択した場所にファイルを保存するには、ストレージ権限が必要です。\n\n許可しない場合、ファイルはアプリ専用ディレクトリに保存されます。',
			'settings.downloadSettings.grantStoragePermission' => 'ストレージ権限を付与',
			'settings.downloadSettings.customDownloadPath' => 'カスタムダウンロードパス',
			'settings.downloadSettings.customDownloadPathDescription' => '有効にすると、ダウンロードファイルのカスタム保存場所を選択できます',
			'settings.downloadSettings.customDownloadPathTip' => '💡 ヒント：パブリックディレクトリ（ダウンロードフォルダなど）を選択するにはストレージ権限が必要です。推奨パスの使用をお勧めします',
			'settings.downloadSettings.androidWarning' => 'Android注意：パブリックディレクトリ（ダウンロードフォルダなど）の選択を避け、アクセス権限を確保するためにアプリ専用ディレクトリの使用をお勧めします。',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ 注意：パブリックディレクトリを選択しました。正常にファイルをダウンロードするにはストレージ権限が必要です',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'パブリックディレクトリにはストレージ権限が必要です',
			'settings.downloadSettings.currentDownloadPath' => '現在のダウンロードパス',
			'settings.downloadSettings.actualDownloadPath' => '実際のダウンロードパス',
			'settings.downloadSettings.defaultAppDirectory' => 'デフォルトアプリディレクトリ',
			'settings.downloadSettings.permissionGranted' => '付与済み',
			'settings.downloadSettings.permissionRequired' => '権限が必要',
			'settings.downloadSettings.enableCustomDownloadPath' => 'カスタムダウンロードパスを有効にする',
			'settings.downloadSettings.disableCustomDownloadPath' => '無効時はアプリのデフォルトパスを使用',
			'settings.downloadSettings.customDownloadPathLabel' => 'カスタムダウンロードパス',
			'settings.downloadSettings.selectDownloadFolder' => 'ダウンロードフォルダを選択',
			'settings.downloadSettings.recommendedPath' => '推奨パス',
			'settings.downloadSettings.selectFolder' => 'フォルダを選択',
			'settings.downloadSettings.filenameTemplate' => 'ファイル名テンプレート',
			'settings.downloadSettings.filenameTemplateDescription' => 'ダウンロードファイルの命名規則をカスタマイズし、変数置換をサポート',
			'settings.downloadSettings.videoFilenameTemplate' => '動画ファイル名テンプレート',
			'settings.downloadSettings.galleryFolderTemplate' => 'ギャラリーフォルダテンプレート',
			'settings.downloadSettings.imageFilenameTemplate' => '画像ファイル名テンプレート',
			'settings.downloadSettings.resetToDefault' => 'デフォルトにリセット',
			'settings.downloadSettings.supportedVariables' => 'サポートされている変数',
			'settings.downloadSettings.supportedVariablesDescription' => 'ファイル名テンプレートで以下の変数を使用できます：',
			'settings.downloadSettings.copyVariable' => '変数をコピー',
			'settings.downloadSettings.variableCopied' => '変数がコピーされました',
			'settings.downloadSettings.warningPublicDirectory' => '警告：選択されたパブリックディレクトリにアクセスできない可能性があります。アプリ専用ディレクトリの選択をお勧めします。',
			'settings.downloadSettings.downloadPathUpdated' => 'ダウンロードパスが更新されました',
			'settings.downloadSettings.selectPathFailed' => 'パスの選択に失敗しました',
			'settings.downloadSettings.pickerAlreadyActive' => 'フォルダ選択画面はすでに開いています',
			'settings.downloadSettings.unsupportedStorageVolume' => 'この保存先には対応していません。本体ストレージまたは SD カード内のフォルダを選んでください。',
			'settings.downloadSettings.recommendedPathSet' => '推奨パスに設定されました',
			'settings.downloadSettings.setRecommendedPathFailed' => '推奨パスの設定に失敗しました',
			'settings.downloadSettings.templateResetToDefault' => 'デフォルトテンプレートにリセットされました',
			'settings.downloadSettings.functionalTest' => '機能テスト',
			'settings.downloadSettings.testInProgress' => 'テスト中...',
			'settings.downloadSettings.runTest' => 'テスト実行',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'ダウンロードパスと権限設定が正常に動作するかテストします',
			'settings.downloadSettings.testResults' => 'テスト結果',
			'settings.downloadSettings.testCompleted' => 'テスト完了',
			'settings.downloadSettings.testMultisegmentDomain' => '値域チェック（複数段 / 上限超え / 逸脱形）',
			'settings.downloadSettings.testMultisegmentPaths' => '複数段構造のレンダリング（issue #126）',
			'settings.downloadSettings.testPassed' => '項目が通過しました',
			'settings.downloadSettings.testFailed' => 'テスト失敗',
			'settings.downloadSettings.testStoragePermissionCheck' => 'ストレージ権限チェック',
			'settings.downloadSettings.testStoragePermissionGranted' => 'ストレージ権限が付与されています',
			'settings.downloadSettings.testStoragePermissionMissing' => 'ストレージ権限がありません、一部の機能が制限される可能性があります',
			'settings.downloadSettings.testPermissionCheckFailed' => '権限チェックに失敗しました',
			'settings.downloadSettings.testDownloadPathValidation' => 'ダウンロードパス検証',
			'settings.downloadSettings.testPathValidationFailed' => 'パス検証に失敗しました',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'ファイル名テンプレート検証',
			'settings.downloadSettings.testAllTemplatesValid' => 'すべてのテンプレートが有効です',
			'settings.downloadSettings.testSomeTemplatesInvalid' => '一部のテンプレートに無効な文字が含まれています',
			'settings.downloadSettings.testTemplateValidationFailed' => 'テンプレート検証に失敗しました',
			'settings.downloadSettings.testDirectoryOperationTest' => 'ディレクトリ操作テスト',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'ディレクトリ作成とファイル書き込みが正常です',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'ディレクトリ操作に失敗しました',
			'settings.downloadSettings.testVideoTemplate' => '動画テンプレート',
			'settings.downloadSettings.testGalleryTemplate' => 'ギャラリーテンプレート',
			'settings.downloadSettings.testImageTemplate' => '画像テンプレート',
			'settings.downloadSettings.testValid' => '有効',
			'settings.downloadSettings.testInvalid' => '無効',
			'settings.downloadSettings.testSuccess' => '成功',
			'settings.downloadSettings.testCorrect' => '正しい',
			'settings.downloadSettings.testError' => 'エラー',
			'settings.downloadSettings.testPath' => 'テストパス',
			'settings.downloadSettings.testBasePath' => '基本パス',
			'settings.downloadSettings.testDirectoryCreation' => 'ディレクトリ作成',
			'settings.downloadSettings.testFileWriting' => 'ファイル書き込み',
			'settings.downloadSettings.testFileContent' => 'ファイル内容',
			'settings.downloadSettings.checkingPathStatus' => 'パス状態を確認中...',
			'settings.downloadSettings.unableToGetPathStatus' => 'パス状態を取得できません',
			'settings.downloadSettings.actualPathDifferentFromSelected' => '注意：実際のパスが選択されたパスと異なります',
			'settings.downloadSettings.grantPermission' => '権限を付与',
			'settings.downloadSettings.fixIssue' => '問題を修正',
			'settings.downloadSettings.issueFixed' => '問題が修正されました',
			'settings.downloadSettings.fixFailed' => '修正に失敗しました、手動で処理してください',
			'settings.downloadSettings.lackStoragePermission' => 'ストレージ権限がありません',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'パブリックディレクトリにアクセスできません、「すべてのファイルアクセス権限」が必要です',
			'settings.downloadSettings.cannotCreateDirectory' => 'ディレクトリを作成できません',
			'settings.downloadSettings.directoryNotWritable' => 'ディレクトリに書き込みできません',
			'settings.downloadSettings.insufficientSpace' => '利用可能な容量が不足しています',
			'settings.downloadSettings.pathValid' => 'パスが有効です',
			'settings.downloadSettings.validationFailed' => '検証に失敗しました',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'デフォルトアプリディレクトリを使用',
			'settings.downloadSettings.appPrivateDirectory' => 'アプリ専用ディレクトリ',
			'settings.downloadSettings.appPrivateDirectoryDesc' => '安全で信頼性があり、追加の権限は不要',
			'settings.downloadSettings.downloadDirectory' => 'ダウンロードディレクトリ',
			'settings.downloadSettings.downloadDirectoryDesc' => 'システムデフォルトのダウンロード場所、管理が簡単',
			'settings.downloadSettings.moviesDirectory' => '動画ディレクトリ',
			'settings.downloadSettings.moviesDirectoryDesc' => 'システム動画ディレクトリ、メディアアプリで認識可能',
			'settings.downloadSettings.documentsDirectory' => 'ドキュメントディレクトリ',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOSアプリドキュメントディレクトリ',
			'settings.downloadSettings.requiresStoragePermission' => 'アクセスにはストレージ権限が必要',
			'settings.downloadSettings.recommendedPaths' => '推奨パス',
			'settings.downloadSettings.externalAppPrivateDirectory' => '外部アプリ専用ディレクトリ',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => '外部ストレージのアプリ専用ディレクトリ、ユーザーがアクセス可能、容量が大きい',
			'settings.downloadSettings.internalAppPrivateDirectory' => '内部アプリ専用ディレクトリ',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'アプリ内部ストレージ、権限不要、容量が小さい',
			'settings.downloadSettings.appDocumentsDirectory' => 'アプリドキュメントディレクトリ',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'アプリ専用ドキュメントディレクトリ、安全で信頼性が高い',
			'settings.downloadSettings.downloadsFolder' => 'ダウンロードフォルダ',
			'settings.downloadSettings.downloadsFolderDesc' => 'システムデフォルトのダウンロードディレクトリ',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => '推奨されるダウンロード場所を選択',
			'settings.downloadSettings.noRecommendedPaths' => '推奨パスがありません',
			'settings.downloadSettings.recommended' => '推奨',
			'settings.downloadSettings.requiresPermission' => '権限が必要',
			'settings.downloadSettings.authorizeAndSelect' => '認証して選択',
			'settings.downloadSettings.select' => '選択',
			'settings.downloadSettings.permissionAuthorizationFailed' => '権限認証に失敗しました、このパスを選択できません',
			'settings.downloadSettings.pathValidationFailed' => 'パス検証に失敗しました',
			'settings.downloadSettings.downloadPathSetTo' => 'ダウンロードパスが設定されました',
			'settings.downloadSettings.setPathFailed' => 'パスの設定に失敗しました',
			'settings.downloadSettings.variableTitle' => 'タイトル',
			'settings.downloadSettings.variableAuthorcache' => '作者の初回名（改名しても変わりません）',
			'settings.downloadSettings.variableAuthor' => '作者名',
			'settings.downloadSettings.variableUsername' => '作者ユーザー名',
			'settings.downloadSettings.variableQuality' => '動画品質',
			'settings.downloadSettings.variableFilename' => '元のファイル名',
			'settings.downloadSettings.variableId' => 'コンテンツID',
			'settings.downloadSettings.variableCount' => 'ギャラリー画像数',
			'settings.downloadSettings.variableDate' => '現在の日付 (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => '現在の時刻 (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => '現在の日時 (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'ダウンロード設定',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'ダウンロードパスとファイル命名規則を設定',
			'settings.downloadSettings.suchAsTitleQuality' => '例: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => '例: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => '例: %title_%filename',
			'settings.downloadSettings.structureSection' => '保存構造と命名',
			'settings.downloadSettings.structureSectionDescription' => 'ダウンロードしたファイルは、以下で選んだ方式に従ってサブフォルダへ自動整理されます。今後のダウンロードにのみ影響し、既存ファイルはそのままです。',
			'settings.downloadSettings.structureNoticeTitle' => '新機能：作者ごとに自動で整理',
			'settings.downloadSettings.structureNoticeBody' => '下から選ぶだけ · 今後のダウンロードにのみ影響し、既存ファイルはそのままです。',
			'settings.downloadSettings.presetFlat' => 'フラット',
			'settings.downloadSettings.presetFlatDesc' => 'すべてのファイルをダウンロードルート直下に置く',
			'settings.downloadSettings.presetAuthor' => '作者別',
			'settings.downloadSettings.presetAuthorBadge' => 'おすすめ',
			'settings.downloadSettings.presetAuthorDesc' => '作者ごとにフォルダ分け · 名前が変わっても迷子にならない',
			'settings.downloadSettings.presetDate' => '日付別',
			'settings.downloadSettings.presetDateDesc' => 'ダウンロード日ごとに整理',
			'settings.downloadSettings.presetCustomActive' => '使用中',
			'settings.downloadSettings.structurePreviewLabel' => 'プレビュー',
			'settings.downloadSettings.structurePreviewNote' => '色付きの部分が整理の階層です。選択した方式に応じて変わります。',
			'settings.downloadSettings.pathTooLongWarning' => '相対パスが200文字を超えています。一部の端末では保存できない場合があります',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'パステンプレート',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'フォルダの階層とファイル名は自分で決められます',
			'settings.downloadSettings.pathTemplateEditor.title' => 'パステンプレート',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'ダウンロードをサブフォルダへ自動整理',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => '動画',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'ギャラリー',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => '単体画像',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'プレビュー · 実際に保存される名前',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'プレビュー · ギャラリーテンプレート＝フォルダ名（内部画像はID名）',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'フォルダ階層を追加',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'フォルダ階層の上限に達しました',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache・変数・固定文字列',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => '例: %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => '拡張子（.mp4）は自動で付きます · 段内で / を入力すると2階層に分かれます · 最大 ${max} 階層',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => '元の拡張子は自動で付きます · 段内で / を入力すると2階層に分かれます · 最大 ${max} 階層',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'ギャラリーテンプレートはすべてフォルダ段（最大 ${max} 階層）· 内部画像は画像IDで命名されます',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'タップでカーソル位置に挿入 · 長押しで説明',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => '空のセグメント',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => '保存できません：空のセグメントを削除するか内容を入力してください',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => '保存できません：パスのセグメント数が上限（最大4）を超えています。統合するか削減してください',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => '保存できません：テンプレートに使用できない文字が含まれています',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => '変数を挿入しました',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => '保存しました · 今後のダウンロードにのみ影響します',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'コンテンツ',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => '作者',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => '日時',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => '作者名・固定',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => '日付',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => '時刻',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => '日時',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => '連番',
			'favoriteTags.title' => 'お気に入りタグ',
			'favoriteTags.emptyIwara' => 'お気に入りの Iwara タグはまだありません',
			'favoriteTags.emptyOreno3d' => 'お気に入りはまだありません',
			'favoriteTags.addIwaraTag' => 'Iwara タグを追加',
			'favoriteTags.quickPickHint' => 'お気に入りは検索のクイック選択に表示されます。',
			'favoriteTags.pickerTitle' => 'Oreno3D を選択',
			'favoriteTags.searchHint' => '名前または原語で検索',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ja'))(n, one: '${n} 作品', other: '${n} 作品', ), 
			'favoriteTags.browseEntry' => '原作 / キャラ / タグを閲覧',
			'favoriteTags.favoritesSection' => 'お気に入り',
			'favoriteTags.addFavorite' => '追加',
			'favoriteTags.iwaraTitle' => 'お気に入りの Iwara タグ',
			'favoriteTags.oreno3dTitle' => 'お気に入りの Oreno3D タグ',
			'favoriteTags.changeTag' => 'タグを変更',
			'favoriteTags.switchToText' => 'テキスト検索',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'タグ',
			'oreno3d.characters' => 'キャラクター',
			'oreno3d.origin' => '原作',
			'oreno3d.thirdPartyTagsExplanation' => 'ここに表示される**タグ**、**キャラクター**、**原作**情報は第三者サイト **Oreno3D** が提供するものであり、参考情報です。\n\nこの情報ソースは日本語のみのため、現在国際化対応が不足しています。\n\nもし国際化開発にご興味があれば、ぜひリポジトリにアクセスしてご協力ください！',
			'oreno3d.sortTypes.hot' => '急上昇',
			'oreno3d.sortTypes.favorites' => '高評価',
			'oreno3d.sortTypes.latest' => '新着',
			'oreno3d.sortTypes.popularity' => '人気',
			'oreno3d.errors.requestFailed' => 'リクエストが失敗しました、ステータスコード',
			'oreno3d.errors.connectionTimeout' => '接続がタイムアウトしました、ネットワーク接続を確認してください',
			'oreno3d.errors.sendTimeout' => 'リクエスト送信がタイムアウトしました',
			'oreno3d.errors.receiveTimeout' => 'レスポンス受信がタイムアウトしました',
			'oreno3d.errors.badCertificate' => '証明書の検証に失敗しました',
			'oreno3d.errors.resourceNotFound' => '要求されたリソースが見つかりません',
			'oreno3d.errors.accessDenied' => 'アクセスが拒否されました、認証または権限が必要な可能性があります',
			'oreno3d.errors.serverError' => 'サーバー内部エラー',
			'oreno3d.errors.serviceUnavailable' => 'サービスが一時的に利用できません',
			'oreno3d.errors.requestCancelled' => 'リクエストがキャンセルされました',
			'oreno3d.errors.connectionError' => 'ネットワーク接続エラー、ネットワーク設定を確認してください',
			'oreno3d.errors.networkRequestFailed' => 'ネットワークリクエストが失敗しました',
			'oreno3d.errors.searchVideoError' => '動画検索中に不明なエラーが発生しました',
			'oreno3d.errors.getPopularVideoError' => '人気動画取得中に不明なエラーが発生しました',
			'oreno3d.errors.getVideoDetailError' => '動画詳細取得中に不明なエラーが発生しました',
			'oreno3d.errors.parseVideoDetailError' => '動画詳細の取得と解析中に不明なエラーが発生しました',
			'oreno3d.errors.downloadFileError' => 'ファイルダウンロード中に不明なエラーが発生しました',
			'oreno3d.loading.gettingVideoInfo' => '動画情報を取得中...',
			'oreno3d.loading.cancel' => 'キャンセル',
			'oreno3d.messages.videoNotFoundOrDeleted' => '動画が見つからないか削除されました',
			'oreno3d.messages.unableToGetVideoPlayLink' => '動画再生リンクを取得できません',
			'oreno3d.messages.getVideoDetailFailed' => '動画詳細の取得に失敗しました',
			'signIn.pleaseLoginFirst' => 'サインインする前にログインしてください',
			'signIn.alreadySignedInToday' => '今日は既にサインインしています！',
			'signIn.youDidNotStickToTheSignIn' => 'サインインを続けることができませんでした。',
			'signIn.signInSuccess' => 'サインインに成功しました！',
			'signIn.signInFailed' => 'サインインに失敗しました。後でもう一度お試しください',
			'signIn.consecutiveSignIns' => '連続サインイン日数',
			'signIn.failureReason' => 'サインインに失敗した理由',
			'signIn.selectDateRange' => '日付範囲を選択',
			'signIn.startDate' => '開始日',
			'signIn.endDate' => '終了日',
			'signIn.invalidDate' => '日付形式が正しくありません',
			'signIn.invalidDateRange' => '日付範囲が無効です',
			'signIn.errorFormatText' => '日付形式が正しくありません',
			'signIn.errorInvalidText' => '日付範囲が無効です',
			'signIn.errorInvalidRangeText' => '日付範囲が無効です',
			'signIn.dateRangeCantBeMoreThanOneYear' => '日付範囲は1年を超えることはできません',
			'signIn.signIn' => 'サインイン',
			'signIn.signInRecord' => 'サインイン記録',
			'signIn.totalSignIns' => '合計サインイン数',
			'signIn.pleaseSelectSignInStatus' => 'サインインステータスを選択してください',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'サブスクリプションを表示するにはログインしてください。',
			'subscriptions.selectUser' => 'ユーザーを選択してください',
			'subscriptions.noSubscribedUsers' => '購読中のユーザーがいません',
			'subscriptions.showAllSubscribedUsersContent' => 'すべての購読中のユーザーのコンテンツを表示',
			'videoDetail.pipMode' => 'ピプモード',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => '${position} から続けて再生',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => '${position} から再開しました',
			'videoDetail.restartFromBeginning' => '最初から',
			'videoDetail.dismissResumeTip' => '閉じる',
			'videoDetail.localInfo.videoInfo' => 'ビデオ情報',
			'videoDetail.localInfo.currentQuality' => '現在の品質',
			'videoDetail.localInfo.duration' => '再生時間',
			'videoDetail.localInfo.resolution' => '解像度',
			'videoDetail.localInfo.fileInfo' => 'ファイル情報',
			'videoDetail.localInfo.fileName' => 'ファイル名',
			'videoDetail.localInfo.fileSize' => 'ファイルサイズ',
			'videoDetail.localInfo.filePath' => 'ファイルパス',
			'videoDetail.localInfo.copyPath' => 'パスをコピー',
			'videoDetail.localInfo.openFolder' => 'フォルダを開く',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'パスをクリップボードにコピーしました',
			'videoDetail.localInfo.openFolderFailed' => 'フォルダを開けませんでした',
			'videoDetail.videoIdIsEmpty' => 'ビデオIDが空です',
			'videoDetail.videoInfoIsEmpty' => 'ビデオ情報が空です',
			'videoDetail.thisIsAPrivateVideo' => 'これはプライベートビデオです',
			'videoDetail.getVideoInfoFailed' => 'ビデオ情報の取得に失敗しました。後でもう一度お試しください',
			'videoDetail.noVideoSourceFound' => '対応するビデオソースが見つかりません',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'タグ "${tagId}" がクリップボードにコピーされました',
			'videoDetail.errorLoadingVideo' => 'ビデオの読み込み中にエラーが発生しました',
			'videoDetail.play' => '再生',
			'videoDetail.pause' => '一時停止',
			'videoDetail.exitAppFullscreen' => 'アプリの全画面表示を終了',
			'videoDetail.enterAppFullscreen' => 'アプリを全画面表示',
			'videoDetail.exitSystemFullscreen' => 'システム全画面表示を終了',
			'videoDetail.enterSystemFullscreen' => 'システム全画面表示',
			'videoDetail.seekTo' => '指定時間にシーク',
			'videoDetail.switchResolution' => '解像度を変更',
			'videoDetail.switchPlaybackSpeed' => '再生速度を変更',
			'videoDetail.rewindSeconds' => ({required Object num}) => '${num} 秒巻き戻し',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => '${num} 秒早送り',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => '${rate} 倍速で再生中',
			'videoDetail.brightness' => '明るさ',
			'videoDetail.brightnessLowest' => '明るさが最低になっています',
			'videoDetail.volume' => '音量',
			'videoDetail.volumeMuted' => '音量がミュートされています',
			'videoDetail.restoreDefaultZoom' => 'リセット',
			'videoDetail.gestureGuide.sampleVideo' => 'サンプル動画',
			'videoDetail.gestureGuide.title' => 'ジェスチャー・操作ガイド',
			'videoDetail.gestureGuide.viewGuide' => 'ジェスチャー・操作ガイドを見る',
			'videoDetail.gestureGuide.firstTimeIntro' => 'プレーヤーのジェスチャーを数秒で確認しましょう。このガイドはプレーヤー設定からいつでも再表示できます。',
			'videoDetail.gestureGuide.startWatching' => '確認して再生を始める',
			'videoDetail.gestureGuide.basicTitle' => '基本操作',
			'videoDetail.gestureGuide.zoomTitle' => '拡大 / 回転 / 移動',
			'videoDetail.gestureGuide.restoreTip' => '右下の「リセット」ボタンで拡大・回転・位置を元に戻せます。',
			'videoDetail.gestureGuide.mTap' => 'シングルタップ：コントロールの表示 / 非表示',
			'videoDetail.gestureGuide.mDoubleTap' => 'ダブルタップ：左で巻き戻し / 中央で一時停止 / 右で早送り',
			'videoDetail.gestureGuide.mHorizontalDrag' => '横スワイプ：シーク',
			'videoDetail.gestureGuide.mVerticalDrag' => '縦スワイプ：左で明るさ / 右で音量',
			'videoDetail.gestureGuide.mLongPress' => '長押し：一時的な倍速再生',
			'videoDetail.gestureGuide.mPinch' => '2本指ピンチ：映像を拡大',
			'videoDetail.gestureGuide.mRotate' => '2本指回転：映像を回転',
			'videoDetail.gestureGuide.dTap' => 'クリック：コントロールの表示 / 非表示',
			'videoDetail.gestureGuide.dDoubleTap' => 'ダブルクリック：左で巻き戻し / 中央で一時停止 / 右で早送り',
			'videoDetail.gestureGuide.dKeys' => 'シークキー：シングルで巻き戻し / 早送り、長押しで倍速再生；速度キー：通常再生中に倍速を段階調整；スペース：再生 / 一時停止',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'トラックパッドのピンチ：映像を拡大',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'トラックパッドの回転：映像を回転',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + ホイール：カーソル中心に拡大',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + ホイール：カーソル中心に回転',
			'videoDetail.gestureGuide.quest.title' => 'Quest の操作を覚えよう',
			'videoDetail.gestureGuide.quest.intro' => 'どのボタンで何ができるか確認して、空間で試してみましょう。',
			'videoDetail.gestureGuide.quest.videoTab' => '空間動画',
			'videoDetail.gestureGuide.quest.galleryTab' => '空間ギャラリー',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Quest 空間のスクリーンとウィンドウのガイドです。プレーヤー設定からいつでも開けます。',
			'videoDetail.gestureGuide.quest.catalog' => '操作を選ぶ',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} / ${total}',
			'videoDetail.gestureGuide.quest.previous' => '前へ',
			'videoDetail.gestureGuide.quest.next' => '次の操作',
			'videoDetail.gestureGuide.quest.replay' => 'もう一度見る',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'デモを一時停止',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'デモを再開',
			'videoDetail.gestureGuide.quest.looping' => '操作デモ',
			'videoDetail.gestureGuide.quest.still' => '静止図',
			'videoDetail.gestureGuide.quest.done' => '確認して続ける',
			'videoDetail.gestureGuide.quest.leftController' => '左手',
			'videoDetail.gestureGuide.quest.rightController' => '右手',
			'videoDetail.gestureGuide.quest.trigger' => '人差し指トリガー',
			'videoDetail.gestureGuide.quest.grip' => 'グリップボタン',
			'videoDetail.gestureGuide.quest.bothGrips' => '両手のグリップ',
			'videoDetail.gestureGuide.quest.stick' => 'スティック',
			'videoDetail.gestureGuide.quest.handTracking' => 'ハンドトラッキング',
			'videoDetail.gestureGuide.quest.ready' => '準備',
			'videoDetail.gestureGuide.quest.press' => '押す',
			'videoDetail.gestureGuide.quest.hold' => '押し続ける',
			'videoDetail.gestureGuide.quest.release' => '離す',
			'videoDetail.gestureGuide.quest.result' => '結果を見る',
			'videoDetail.gestureGuide.quest.pinch' => 'ピンチ',
			'videoDetail.gestureGuide.quest.selectTitle' => 'レイで選択する',
			'videoDetail.gestureGuide.quest.selectBody' => 'ボタンにレイを合わせ、人差し指トリガーを押して離すと選択できます。再生、設定、スライダーも同じ操作です。',
			'videoDetail.gestureGuide.quest.selectHint' => '人差し指トリガーはボタン面の裏側、グリップボタンは持ち手の内側にあります。',
			'videoDetail.gestureGuide.quest.panelTitle' => 'パネルを表示・非表示',
			'videoDetail.gestureGuide.quest.panelBody' => '操作パネルの外にレイを向けてトリガーを軽く押すと、表示を切り替えられます。手の場合はパネルの外で軽くピンチします。',
			'videoDetail.gestureGuide.quest.panelHint' => '動かさず短く押して離してください。押したまま動かすとドラッグになります。',
			'videoDetail.gestureGuide.quest.playTitle' => '再生・一時停止',
			'videoDetail.gestureGuide.quest.playBody' => '操作パネルからレイを外し、右手の A または左手の X で再生・一時停止します。パネルの再生ボタンも使えます。',
			'videoDetail.gestureGuide.quest.playHint' => 'このショートカットは空間プレーヤー設定で無効にできます。レイがパネル上にあるときは、パネルの操作が優先されます。',
			'videoDetail.gestureGuide.quest.seekTitle' => 'スティックでシーク',
			'videoDetail.gestureGuide.quest.seekBody' => '左右どちらのスティックでも、左・右に短く倒すと 5 秒移動します。倒し続けると加速し、離したときに表示中の時間へジャンプします。',
			'videoDetail.gestureGuide.quest.seekHint' => '操作するコントローラーのレイをパネルから外してください。パネル上ではスティックがスクロール操作になります。',
			'videoDetail.gestureGuide.quest.browseTitle' => 'スティックで画像を送る',
			'videoDetail.gestureGuide.quest.browseBody' => '左右どちらのスティックでも、左・右で前後の項目へ移動し、倒し続けると連続で送れます。フィルムストリップのサムネイルも選べます。',
			'videoDetail.gestureGuide.quest.browseHint' => 'ギャラリー内の動画も同じように送れます。レイが操作パネル上にあると、スティックはスクロールになります。',
			'videoDetail.gestureGuide.quest.swipeTitle' => '横ドラッグでページを送る',
			'videoDetail.gestureGuide.quest.swipeBody' => '画像にレイを合わせ、トリガーを押したまま左へドラッグします。ページ送りの表示が出たら離すと次へ、右へドラッグすると前へ戻ります。ピンチでも操作できます。',
			'videoDetail.gestureGuide.quest.swipeHint' => '画像は 1× のときにページ送りできます。ギャラリー内の動画にも対応しています。ドラッグ中は画面が動かず、離してから切り替わります。',
			'videoDetail.gestureGuide.quest.zoomTitle' => '画像の細部を拡大',
			'videoDetail.gestureGuide.quest.zoomBody' => '見たい部分にレイを合わせてトリガーを押し続け、スティックを上に倒すと拡大、下に倒すと縮小します。押した位置が拡大の中心になります。',
			'videoDetail.gestureGuide.quest.zoomHint' => 'ウィンドウの大きさは変わらず、中の画像だけが拡大します。画像を押していないときの上下操作は視聴距離を変えます。',
			'videoDetail.gestureGuide.quest.panTitle' => '拡大画像の移動とリセット',
			'videoDetail.gestureGuide.quest.panBody' => '拡大後はトリガーを押したままドラッグして、別の部分を見られます。画像をダブルクリックすると 2.5× 拡大とリセットを切り替えます。手の場合は素早く 2 回ピンチします。',
			'videoDetail.gestureGuide.quest.panHint' => '拡大中のドラッグは画像の移動です。ページ送りは 1× に戻してから行ってください。',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'スライドショーを開始',
			'videoDetail.gestureGuide.quest.slideshowBody' => '画像を表示中は A / X でスライドショーを開始・停止できます。パネルで 3・5・10・20 秒の間隔や標準・元画像の画質を選べます。',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'ギャラリー内の動画では A / X がその動画の再生・一時停止になります。設定でショートカットを有効にしてください。',
			'videoDetail.gestureGuide.quest.moveTitle' => 'スクリーンをつかんで移動',
			'videoDetail.gestureGuide.quest.moveBody' => '持ち手の内側のグリップを押したままコントローラーを動かし、見やすい位置で離します。視聴中はスクリーンを狙わなくてもつかめます。',
			'videoDetail.gestureGuide.quest.moveHint' => 'アプリや操作パネルにレイを合わせると、そのウィンドウを優先してつかみます。パノラマ動画では向きを調整します。',
			'videoDetail.gestureGuide.quest.scaleTitle' => '両手でスクリーンの大きさを変更',
			'videoDetail.gestureGuide.quest.scaleBody' => '両方のグリップを押し続け、手を離すと拡大、近づけると縮小します。ハンドトラッキングでは両手でピンチを保って操作します。',
			'videoDetail.gestureGuide.quest.scaleHint' => '平面・曲面スクリーンとギャラリーの舞台に対応します。レイを操作パネルから外してください。画面全体の大きさが変わります。',
			'videoDetail.gestureGuide.quest.distanceTitle' => '視聴距離を調整',
			'videoDetail.gestureGuide.quest.distanceBody' => 'スティックを上に倒すと遠く、下に倒すと近くなります。ウィンドウをつかんでいる間はそのウィンドウの距離を調整します。音量はパネルで調整します。',
			'videoDetail.gestureGuide.quest.distanceHint' => 'レイを操作パネルから外してください。画像を押したままの上下操作は細部の拡大、パノラマ動画では見え方の調整になります。',
			'videoDetail.gestureGuide.quest.resizeTitle' => '枠や角をドラッグ',
			'videoDetail.gestureGuide.quest.resizeBody' => 'レイを端に近づけると枠が光ります。端をトリガーやピンチでつかむと移動、角をつかんでドラッグするとサイズ変更ができます。',
			'videoDetail.gestureGuide.quest.resizeHint' => 'アプリ、操作パネル、スクリーンで共通の操作です。アプリの幅と高さは自由に変えられ、スクリーンは縦横比を保ちます。',
			'videoDetail.gestureGuide.quest.navigationTitle' => '戻る・空間設定を開く',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y はポップアップを閉じる、パネルのホームへ戻る、パネルを隠す、アプリへ戻る、の順で一段ずつ戻ります。左手の Menu で空間設定を開けます。',
			'videoDetail.gestureGuide.quest.navigationHint' => '右手の Meta ボタンはシステム用です。システムの視点リセットで正面に戻せます。スクリーンの大きさと距離は保たれます。',
			'videoDetail.gestureGuide.quest.handsTitle' => 'コントローラーなしで操作',
			'videoDetail.gestureGuide.quest.handsBody' => 'ハンドトラッキングを有効にし、システムのレイをボタンに合わせ、親指と人差し指をピンチして離します。再生、シーク、画像送りはパネルで操作できます。',
			'videoDetail.gestureGuide.quest.handsHint' => 'パネル外で軽くピンチすると表示を切り替えます。端をつかんで移動、角でサイズ変更、両手でピンチして広げるとスクリーンを拡大できます。',
			'videoDetail.home' => 'ホーム',
			'videoDetail.videoPlayer' => 'ビデオプレーヤー',
			'videoDetail.videoPlayerInfo' => 'プレーヤー情報',
			'videoDetail.moreSettings' => 'さらに設定',
			'videoDetail.videoPlayerFeatureInfo' => 'プレーヤー機能の紹介',
			'videoDetail.autoRewind' => '自動リワインド',
			'videoDetail.rewindAndFastForward' => '両側をダブルクリックして早送りまたは巻き戻し',
			'videoDetail.volumeAndBrightness' => '両側を上下にスワイプして音量と明るさを調整',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => '中央エリアをダブルタップして一時停止または再生',
			'videoDetail.showVerticalVideoInFullScreen' => '全画面表示時に縦向きビデオを表示',
			'videoDetail.keepLastVolumeAndBrightness' => '前回の音量と明るさを保持',
			'videoDetail.setProxy' => 'プロキシを設定',
			'videoDetail.moreFeaturesToBeDiscovered' => 'さらに機能が発見されます...',
			'videoDetail.videoPlayerSettings' => 'プレーヤー設定',
			'videoDetail.commentCount' => ({required Object num}) => '${num} 件のコメント',
			'videoDetail.writeYourCommentHere' => 'ここにコメントを入力...',
			'videoDetail.authorOtherVideos' => '作者の他のビデオ',
			'videoDetail.relatedVideos' => '関連ビデオ',
			'videoDetail.privateVideo' => 'これはプライベートビデオです',
			'videoDetail.externalVideo' => 'これは站外ビデオです',
			'videoDetail.openInBrowser' => 'ブラウザで開く',
			'videoDetail.resourceDeleted' => 'このビデオは削除されたようです :/',
			'videoDetail.noDownloadUrl' => 'ダウンロードURLがありません',
			'videoDetail.startDownloading' => 'ダウンロードを開始',
			'videoDetail.downloadFailed' => 'ダウンロードに失敗しました。後でもう一度お試しください',
			'videoDetail.downloadSuccess' => 'ダウンロードに成功しました',
			'videoDetail.download' => 'ダウンロード',
			'videoDetail.downloadManager' => 'ダウンロード管理',
			'videoDetail.videoLoadError' => 'ビデオの読み込みに失敗しました',
			'videoDetail.resourceNotFound' => 'リソースが見つかりませんでした',
			'videoDetail.authorNoOtherVideos' => '作者は他のビデオを所有していません',
			'videoDetail.noRelatedVideos' => '関連するビデオはありません',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'ビデオソースの読み込み中にエラーが発生しました',
			'videoDetail.player.errorWhileSettingUpListeners' => '監視器の設定中にエラーが発生しました',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'サーバー障害を検出しました。自動的にルートを切り替えて再試行しています',
			'videoDetail.skeleton.fetchingVideoInfo' => 'ビデオ情報を取得中...',
			'videoDetail.skeleton.fetchingVideoSources' => 'ビデオソースを取得中...',
			'videoDetail.skeleton.loadingVideo' => 'ビデオを読み込み中...',
			'videoDetail.skeleton.applyingSolution' => '解像度を適用中...',
			'videoDetail.skeleton.addingListeners' => '監視器を追加中...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'ビデオの総時間を取得しました、ビデオを読み込み中...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => '読み込み完了',
			'videoDetail.cast.dlnaCast' => 'キャスト',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'キャスト検索の開始に失敗しました: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'キャスト開始: ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'キャスト失敗: ${error}\n再検索してください',
			'videoDetail.cast.castStopped' => 'キャスト停止',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'メディアレンダラー',
			'videoDetail.cast.deviceTypes.mediaServer' => 'メディアサーバー',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'ルーター',
			'videoDetail.cast.deviceTypes.basicDevice' => '基本デバイス',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'スマートライト',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => '無線アクセスポイント',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => '無線接続デバイス',
			'videoDetail.cast.deviceTypes.printer' => 'プリンター',
			'videoDetail.cast.deviceTypes.scanner' => 'スキャナー',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'カメラ',
			'videoDetail.cast.deviceTypes.unknownDevice' => '不明なデバイス',
			'videoDetail.cast.currentPlatformNotSupported' => '現在のプラットフォームはキャスト機能をサポートしていません',
			'videoDetail.cast.unableToGetVideoUrl' => 'ビデオのURLを取得できません、後でもう一度お試しください',
			'videoDetail.cast.stopCasting' => 'キャスト停止',
			'videoDetail.cast.dlnaCastSheet.title' => 'リモートキャスト',
			'videoDetail.cast.dlnaCastSheet.close' => '閉じる',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'デバイスを検索中...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => '検索ボタンをクリックしてキャストデバイスを再検索',
			'videoDetail.cast.dlnaCastSheet.searching' => '検索中',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => '再検索',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'キャストデバイスが見つかりません\nデバイスが同じネットワークにあることを確認してください',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'デバイスを検索中です。お待ちください...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'キャスト',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => '接続済み: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'デバイス未接続',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'キャスト停止',
			'videoDetail.likeAvatars.dialogTitle' => '誰がこっそり「いいね」したの？',
			'videoDetail.likeAvatars.dialogDescription' => '誰か気になる？この「いいねアルバム」をめくってみよう～',
			'videoDetail.likeAvatars.closeTooltip' => '閉じる',
			'videoDetail.likeAvatars.retry' => '再試行',
			'videoDetail.likeAvatars.noLikesYet' => 'まだ誰もここに現れていません。最初の一人になりましょう！',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => '${page} / ${totalPages} ページ · 合計 ${totalCount} 人',
			'videoDetail.likeAvatars.prevPage' => '前のページ',
			'videoDetail.likeAvatars.nextPage' => '次のページ',
			'share.sharePlayList' => 'プレイリストを共有',
			'share.wowDidYouSeeThis' => 'ああ、見たの？',
			'share.nameIs' => '名前は',
			'share.clickLinkToView' => 'リンクをクリックして見る',
			'share.iReallyLikeThis' => '本当に好きです',
			'share.shareFailed' => '共有に失敗しました。後でもう一度お試しください',
			'share.share' => '共有',
			'share.shareAsImage' => '画像として共有',
			'share.shareAsText' => 'テキストとして共有',
			'share.shareAsImageDesc' => '動画のサムネイルを画像として共有',
			'share.shareAsTextDesc' => '動画の詳細をテキストとして共有',
			'share.shareAsImageFailed' => 'サムネイルの共有に失敗しました。後でもう一度お試しください',
			'share.shareAsTextFailed' => '詳細の共有に失敗しました。後でもう一度お試しください',
			'share.shareVideo' => '動画を共有',
			'share.authorIs' => '作者は',
			'share.shareGallery' => 'ギャラリーを共有',
			'share.galleryTitleIs' => 'ギャラリーのタイトルは',
			'share.galleryAuthorIs' => 'ギャラリーの作者は',
			'share.shareUser' => 'ユーザーを共有',
			'share.userNameIs' => 'ユーザーの名前は',
			'share.userAuthorIs' => 'ユーザーの作者は',
			'share.comments' => 'コメント',
			'share.shareThread' => 'スレッドを共有',
			'share.views' => '閲覧',
			'share.sharePost' => '投稿を共有',
			'share.postTitleIs' => '投稿のタイトルは',
			'share.postAuthorIs' => '投稿の作者は',
			'markdown.markdownSyntax' => 'Markdown 構文',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara 専用構文',
			'markdown.internalLink' => '站内鏈接',
			'markdown.supportAutoConvertLinkBelow' => '以下のタイプのリンクを自動変換します：',
			_ => null,
		} ?? switch (path) {
			'markdown.convertLinkExample' => '🎬 ビデオリンク\n🖼️ 画像リンク\n👤 ユーザーリンク\n📌 フォーラムリンク\n🎵 プレイリストリンク\n💬 スレッドリンク',
			'markdown.mentionUser' => 'ユーザーを言及',
			'markdown.mentionUserDescription' => '@後にユーザー名を入力すると、ユーザーリンクに自動変換されます',
			'markdown.markdownBasicSyntax' => 'Markdown 基本構文',
			'markdown.paragraphAndLineBreak' => '段落と改行',
			'markdown.paragraphAndLineBreakDescription' => '段落間に空行を入れ、行末に2つのスペースを追加すると改行されます',
			'markdown.paragraphAndLineBreakSyntax' => 'これは第一段落です\n\nこれは第二段落です\nこの行の後に2つのスペースを追加して  \n改行されます',
			'markdown.textStyle' => 'テキストスタイル',
			'markdown.textStyleDescription' => '特殊記号でテキストのスタイルを変更',
			'markdown.textStyleSyntax' => '**太字テキスト**\n*斜体テキスト*\n~~削除線テキスト~~\n`コードテキスト`',
			'markdown.quote' => '引用',
			'markdown.quoteDescription' => '> 符号で引用を作成し、複数の > で多段引用を作成',
			'markdown.quoteSyntax' => '> これは一階引用です\n>> これは二階引用です',
			'markdown.list' => 'リスト',
			'markdown.listDescription' => '数字+点号で順序付きリストを作成し、- で順序なしリストを作成',
			'markdown.listSyntax' => '1. 第一項\n2. 第二項\n\n- 順序なし項\n  - 子項\n  - 別の子項',
			'markdown.linkAndImage' => 'リンクと画像',
			'markdown.linkAndImageDescription' => 'リンク形式：[テキスト](URL)\n画像形式：![説明](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[リンクテキスト](${link})\n![画像説明](${imgUrl})',
			'markdown.title' => 'タイトル',
			'markdown.titleDescription' => '＃ 号でタイトルを作成し、数でレベルを表示',
			'markdown.titleSyntax' => '# 一階タイトル\n## 二階タイトル\n### 三階タイトル',
			'markdown.separator' => '分隔線',
			'markdown.separatorDescription' => '三個以上の - 号で分隔線を作成',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => '語法',
			'forum.attachQuote' => '引用を付ける',
			'forum.replyToFloor' => ({required Object floor, required Object username}) => '#${floor} @${username} に返信',
			'forum.removeQuote' => '引用を削除',
			'forum.recent' => '最近',
			'forum.category' => 'カテゴリ',
			'forum.lastReply' => '最終返信',
			'forum.sitewide.badge' => '全体',
			'forum.sitewide.title' => '全体お知らせ',
			'forum.sitewide.readMore' => '全文表示',
			'forum.errors.pleaseSelectCategory' => 'カテゴリを選択してください',
			'forum.errors.threadLocked' => 'このスレッドはロックされています。',
			'forum.title' => 'タイトル',
			'forum.createPost' => '投稿を作成',
			'forum.enterTitle' => 'タイトルを入力してください',
			'forum.content' => 'コンテンツ',
			'forum.enterContent' => 'コンテンツを入力してください',
			'forum.writeYourContentHere' => 'ここにコンテンツを入力...',
			'forum.posts' => '投稿',
			'forum.threads' => 'スレッド',
			'forum.forum' => 'フォーラム',
			'forum.createThread' => 'スレッドを作成',
			'forum.selectCategory' => 'カテゴリを選択',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'クールダウン残り時間 ${minutes} 分 ${seconds} 秒',
			'forum.groups.administration' => '管理',
			'forum.groups.global' => 'グローバル',
			'forum.groups.chinese' => '中国語',
			'forum.groups.japanese' => '日本語',
			'forum.groups.korean' => '韓国語',
			'forum.groups.other' => 'その他',
			'forum.leafNames.announcements' => 'お知らせ',
			'forum.leafNames.feedback' => 'フィードバック',
			'forum.leafNames.support' => 'サポート',
			'forum.leafNames.general' => '一般',
			'forum.leafNames.guides' => 'ガイド',
			'forum.leafNames.questions' => '質問',
			'forum.leafNames.requests' => 'リクエスト',
			'forum.leafNames.sharing' => 'シェア',
			'forum.leafNames.general_zh' => '一般',
			'forum.leafNames.questions_zh' => '質問',
			'forum.leafNames.requests_zh' => 'リクエスト',
			'forum.leafNames.support_zh' => 'サポート',
			'forum.leafNames.general_ja' => '一般',
			'forum.leafNames.questions_ja' => '質問',
			'forum.leafNames.requests_ja' => 'リクエスト',
			'forum.leafNames.support_ja' => 'サポート',
			'forum.leafNames.korean' => '韓国語',
			'forum.leafNames.other' => 'その他',
			'forum.leafDescriptions.announcements' => '公式の重要なお知らせと通知',
			'forum.leafDescriptions.feedback' => 'サイトの機能やサービスに対するフィードバック',
			'forum.leafDescriptions.support' => 'サイト関連の問題を解決する手助け',
			'forum.leafDescriptions.general' => 'あらゆる話題を議論する',
			'forum.leafDescriptions.guides' => '経験やチュートリアルを共有する',
			'forum.leafDescriptions.questions' => '疑問を提起する',
			'forum.leafDescriptions.requests' => 'リクエストを投稿する',
			'forum.leafDescriptions.sharing' => '面白いコンテンツを共有する',
			'forum.leafDescriptions.general_zh' => 'あらゆる話題を議論する',
			'forum.leafDescriptions.questions_zh' => '疑問を提起する',
			'forum.leafDescriptions.requests_zh' => 'リクエストを投稿する',
			'forum.leafDescriptions.support_zh' => 'サイト関連の問題を解決する手助け',
			'forum.leafDescriptions.general_ja' => 'あらゆる話題を議論する',
			'forum.leafDescriptions.questions_ja' => '疑問を提起する',
			'forum.leafDescriptions.requests_ja' => 'リクエストを投稿する',
			'forum.leafDescriptions.support_ja' => 'サイト関連の問題を解決する手助け',
			'forum.leafDescriptions.korean' => '韓国語に関する議論',
			'forum.leafDescriptions.other' => 'その他の未分類のコンテンツ',
			'forum.reply' => '回覆',
			'forum.pendingReview' => '審査中',
			'forum.floorNotFound' => 'その投稿は存在しないか削除されました',
			'forum.floorNotLoadedYet' => 'その投稿はさらに前にあります。続きを読み込むと移動できます',
			'forum.editedAt' => '編集日時',
			'forum.copySuccess' => 'クリップボードにコピーされました',
			'forum.copySuccessForMessage' => ({required Object str}) => 'クリップボードにコピーされました: ${str}',
			'forum.editReply' => '編集回覆',
			'forum.editTitle' => '編集タイトル',
			'forum.submit' => '提出',
			'notifications.errors.unsupportedNotificationType' => 'サポートされていない通知タイプ',
			'notifications.errors.unknownUser' => '未知ユーザー',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'サポートされていない通知タイプ: ${type}',
			'notifications.errors.unknownNotificationType' => '未知通知タイプ',
			'notifications.notifications' => '通知',
			'notifications.profile' => '個人主頁',
			'notifications.postedNewComment' => '新しいコメントを投稿',
			'notifications.inYour' => 'あなたの',
			'notifications.video' => 'ビデオ',
			'notifications.repliedYourVideoComment' => 'あなたのビデオコメントに返信しました',
			'notifications.copyInfoToClipboard' => '通知情報をクリップボードにコピー',
			'notifications.copySuccess' => 'クリップボードにコピーされました',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'クリップボードにコピーされました: ${str}',
			'notifications.markAllAsRead' => '全てを既読にする',
			'notifications.markAllAsReadSuccess' => '全ての通知が既読になりました',
			'notifications.markAllAsReadFailed' => '全てを既読にするに失敗しました',
			'notifications.markSelectedAsRead' => '選択した通知を既読にする',
			'notifications.markSelectedAsReadSuccess' => '選択した通知が既読になりました',
			'notifications.markSelectedAsReadFailed' => '選択した通知を既読にするに失敗しました',
			'notifications.markAsRead' => '既読にする',
			'notifications.markAsReadSuccess' => '通知が既読になりました',
			'notifications.markAsReadFailed' => '通知を既読にするに失敗しました',
			'notifications.notificationTypeHelp' => '通知タイプのヘルプ',
			'notifications.dueToLackOfNotificationTypeDetails' => '通知タイプの詳細情報が不足しているため、現在サポートされているタイプが受信したメッセージをカバーしていない可能性があります',
			'notifications.helpUsImproveNotificationTypeSupport' => '通知タイプのサポート改善にご協力いただける場合',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 通知情報をコピー\n2. 🐞 プロジェクトリポジトリに issue を提出\n\n⚠️ 注意：通知情報には個人情報が含まれている場合があります。公開したくない場合は、プロジェクト作者にメールで送信することもできます。',
			'notifications.goToRepository' => 'リポジトリに移動',
			'notifications.copy' => 'コピー',
			'notifications.commentApproved' => 'コメントが承認されました',
			'notifications.repliedYourProfileComment' => 'あなたの個人主頁コメントに返信しました',
			'notifications.kReplied' => 'さんが',
			'notifications.kCommented' => 'さんが',
			'notifications.kVideo' => 'ビデオ',
			'notifications.kGallery' => 'ギャラリー',
			'notifications.kProfile' => 'プロフィール',
			'notifications.kThread' => 'スレッド',
			'notifications.kPost' => '投稿',
			'notifications.kCommentSection' => '',
			'notifications.kApprovedComment' => 'コメントが承認されました',
			'notifications.kApprovedVideo' => '動画が承認されました',
			'notifications.kApprovedGallery' => 'ギャラリーが承認されました',
			'notifications.kApprovedThread' => 'スレッドが承認されました',
			'notifications.kApprovedPost' => '投稿が承認されました',
			'notifications.kApprovedForumPost' => 'フォーラム投稿が承認されました',
			'notifications.kRejectedContent' => 'コンテンツ審査が拒否されました',
			'notifications.kUnknownType' => '不明な通知タイプ',
			'conversation.errors.pleaseSelectAUser' => 'ユーザーを選択してください',
			'conversation.errors.pleaseEnterATitle' => 'タイトルを入力してください',
			'conversation.errors.clickToSelectAUser' => 'ユーザーを選択してください',
			'conversation.errors.loadFailedClickToRetry' => '読み込みに失敗しました。クリックして再試行',
			'conversation.errors.loadFailed' => '読み込みに失敗しました',
			'conversation.errors.clickToRetry' => 'クリックして再試行',
			'conversation.errors.noMoreConversations' => 'もう会話がありません',
			'conversation.conversation' => '会話',
			'conversation.startConversation' => '会話を開始',
			'conversation.noConversation' => '会話がありません',
			'conversation.selectFromLeftListAndStartConversation' => '左側の会話リストから会話を選択して開始',
			'conversation.title' => 'タイトル',
			'conversation.body' => '内容',
			'conversation.selectAUser' => 'ユーザーを選択',
			'conversation.searchUsers' => 'ユーザーを検索...',
			'conversation.tmpNoConversions' => '会話がありません',
			'conversation.deleteThisMessage' => 'このメッセージを削除',
			'conversation.deleteThisMessageSubtitle' => 'この操作は取り消せません',
			'conversation.writeMessageHere' => 'ここにメッセージを入力...',
			'conversation.lastMessageFromMe' => '自分: ',
			'conversation.sendMessage' => 'メッセージを送信',
			'splash.errors.initializationFailed' => '初期化に失敗しました。アプリを再起動してください',
			'splash.preparing' => '準備中...',
			'splash.initializing' => '初期化中...',
			'splash.loading' => '読み込み中...',
			'splash.ready' => '準備完了',
			'splash.initializingMessageService' => 'メッセージサービスを初期化中...',
			'download.errors.imageModelNotFound' => '画像モデルが見つかりません',
			'download.errors.downloadFailed' => 'ダウンロードに失敗しました',
			'download.errors.videoInfoNotFound' => 'ビデオ情報が見つかりません',
			'download.errors.unknown' => '不明',
			'download.errors.downloadTaskAlreadyExists' => 'ダウンロードタスクが既に存在します',
			'download.errors.downloadTaskSavePathConflict' => '保存先パスは既に他のタスクで使用されています',
			'download.errors.videoAlreadyDownloaded' => 'ビデオはすでにダウンロードされています',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'ダウンロードタスクの追加に失敗しました: ${errorInfo}',
			'download.errors.userPausedDownload' => 'ユーザーがダウンロードを一時停止',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'ファイルシステムエラー: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => '不明なエラー: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'ファイルの書き込みに失敗しました: ${errorInfo}',
			'download.errors.connectionTimeout' => '接続タイムアウト',
			'download.errors.sendTimeout' => '送信タイムアウト',
			'download.errors.receiveTimeout' => '受信タイムアウト',
			'download.errors.serverError' => ({required Object errorInfo}) => 'サーバーエラー: ${errorInfo}',
			'download.errors.unknownNetworkError' => '不明なネットワークエラー',
			'download.errors.sslHandshakeFailed' => 'SSLハンドシェイクに失敗しました、ネットワーク環境を確認してください',
			'download.errors.connectionFailed' => '接続に失敗しました、ネットワークを確認してください',
			'download.errors.serviceIsClosing' => 'ダウンロードサービスが閉じています',
			'download.errors.partialDownloadFailed' => '部分内容ダウンロード失敗',
			'download.errors.noDownloadTask' => 'ダウンロードタスクがありません',
			'download.errors.taskNotFoundOrDataError' => 'タスクが見つかりませんまたはデータが正しくありません',
			'download.errors.copyDownloadUrlFailed' => 'ダウンロードリンクのコピーに失敗しました',
			'download.errors.fileNotFound' => 'ファイルが見つかりません',
			'download.errors.openFolderFailed' => 'ファイルフォルダーを開くのに失敗しました',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'ファイルフォルダーを開くのに失敗しました: ${message}',
			'download.errors.directoryNotFound' => 'ディレクトリが見つかりません',
			'download.errors.copyFailed' => 'コピーに失敗しました',
			'download.errors.openFileFailed' => 'ファイルを開くのに失敗しました',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'ファイルを開くのに失敗しました: ${message}',
			'download.errors.playLocallyFailed' => 'ローカル再生に失敗しました',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'ローカル再生に失敗しました: ${message}',
			'download.errors.noDownloadSource' => 'ダウンロードソースがありません',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'ダウンロードソースがありません。情報を読み込んだ後、もう一度お試しください。',
			'download.errors.noActiveDownloadTask' => 'ダウンロード中のタスクがありません',
			'download.errors.noFailedDownloadTask' => '失敗したタスクがありません',
			'download.errors.noCompletedDownloadTask' => '完了したタスクがありません',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'タスクはすでに完了しています。再度追加しないでください',
			'download.errors.linkExpiredTryAgain' => 'リンクが期限切れです。新しいダウンロードリンクを取得しています',
			'download.errors.linkExpiredTryAgainSuccess' => 'リンクが期限切れです。新しいダウンロードリンクを取得しました',
			'download.errors.linkExpiredTryAgainFailed' => 'リンクが期限切れです。新しいダウンロードリンクを取得に失敗しました',
			'download.errors.taskDeleted' => 'タスクが削除されました',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'サポートされていない画像形式: ${format}',
			'download.errors.deleteFileError' => 'ファイルの削除に失敗しました。ファイルが他のプロセスによって使用されている可能性があります',
			'download.errors.deleteTaskError' => 'タスクの削除に失敗しました',
			'download.errors.taskNotFound' => 'タスクが見つかりません',
			'download.errors.canNotRefreshVideoTask' => 'ビデオタスクの更新に失敗しました',
			'download.errors.videoRemovedCanNotRefresh' => 'この動画は削除されたか存在しないため、ダウンロードリンクを再取得できません',
			'download.errors.videoInaccessibleCanNotRefresh' => 'この動画にアクセスできません。非公開になっているか、再ログインが必要な可能性があります',
			'download.errors.videoQualityGone' => 'この画質は提供されなくなりました。ダウンロードを追加し直してください',
			'download.errors.refreshLinkNetworkFailed' => 'ネットワークエラーのため、現在ダウンロードリンクを再取得できません。しばらくしてから再試行してください',
			'download.errors.taskAlreadyProcessing' => 'タスクはすでに処理中です',
			'download.errors.failedToLoadTasks' => 'タスクの読み込みに失敗しました',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => '部分ダウンロードに失敗しました: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'サポートされていない画像形式: ${extension}, デバイスにダウンロードして表示することができます',
			'download.errors.imageLoadFailed' => '画像の読み込みに失敗しました',
			'download.errors.pleaseTryOtherViewer' => '他のビューアーを使用してみてください',
			'download.downloadList' => 'ダウンロードリスト',
			'download.viewDownloadList' => 'ダウンロードリストを表示',
			'download.download' => 'ダウンロード',
			'download.selectDownloadTitle' => 'ダウンロードを選択',
			'download.qualitySectionLabel' => '画質',
			'download.categorySectionLabel' => '分類',
			'download.saveToPreviewLabel' => '保存先',
			'download.saveToPreviewSuggested' => ({required Object name}) => '推奨ファイル名：${name}（システムダイアログで変更可）',
			'download.lastUsedBadge' => '前回選択',
			'download.pickedBadge' => '選択中',
			'download.forceDeleteTask' => '強制削除タスク',
			'download.startDownloading' => 'ダウンロードを開始',
			'download.clearAllFailedTasks' => 'すべての失敗タスクをクリア',
			'download.clearAllFailedTasksConfirmation' => 'すべての失敗タスクをクリアしますか？\nこれらのタスクのファイルも削除されます。',
			'download.clearAllFailedTasksSuccess' => 'すべての失敗タスクをクリアしました',
			'download.clearAllFailedTasksError' => '失敗タスクのクリア中にエラーが発生しました',
			'download.downloadStatus' => 'ダウンロード状態',
			'download.imageList' => '画像リスト',
			'download.retryDownload' => '再試行ダウンロード',
			'download.notDownloaded' => '未ダウンロード',
			'download.downloaded' => 'ダウンロード済み',
			'download.waitingForDownload' => 'ダウンロード待機中',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード中 (${downloaded}/${total}枚 ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'ダウンロード中 (${downloaded}枚)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード一時停止中 (${downloaded}/${total}枚 ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'ダウンロード一時停止中 (${downloaded}枚)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'ダウンロード完了 (合計${total}枚)',
			'download.viewVideoDetail' => 'ビデオ詳細を表示',
			'download.viewGalleryDetail' => 'ギャラリー詳細を表示',
			'download.moreOptions' => 'もっと操作',
			'download.openFile' => 'ファイルを開く',
			'download.playLocally' => 'ローカル再生',
			'download.pause' => '一時停止',
			'download.resume' => '継続',
			'download.copyDownloadUrl' => 'ダウンロードリンクをコピー',
			'download.showInFolder' => 'フォルダーで表示',
			'download.deleteTask' => 'タスクを削除',
			'download.deleteTaskConfirmation' => 'このダウンロードタスクを削除しますか？\nタスクのファイルも削除されます。',
			'download.forceDeleteTaskConfirmation' => 'このダウンロードタスクを強制削除しますか？\nファイルが使用中でも削除を試行し、タスクのファイルも削除されます。',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'ダウンロード中 ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => '一時停止中 ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => '一時停止中 • ダウンロード済み ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'ダウンロード完了 • ${size}',
			'download.copyDownloadUrlSuccess' => 'ダウンロードリンクをコピーしました',
			'download.totalImageNums' => ({required Object num}) => '${num}枚',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'ダウンロード中',
			'download.failed' => '失敗',
			'download.completed' => '完了',
			'download.downloadDetail' => 'ダウンロード詳細',
			'download.copy' => 'コピー',
			'download.copySuccess' => 'コピーしました',
			'download.waiting' => '待機中',
			'download.paused' => '一時停止中',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'ダウンロード中 ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'ギャラリーのダウンロードが完了しました: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'ダウンロードが完了しました: ${fileName}',
			'download.searchTasks' => 'タスクを検索...',
			'download.statusLabel' => ({required Object label}) => 'ステータス: ${label}',
			'download.allStatus' => 'すべてのステータス',
			'download.typeLabel' => ({required Object label}) => 'タイプ: ${label}',
			'download.allTypes' => 'すべてのタイプ',
			'download.taskType' => '種類',
			'download.video' => '動画',
			'download.gallery' => 'ギャラリー',
			'download.other' => 'その他',
			'download.clearFilters' => 'フィルターをクリア',
			'download.pauseAll' => 'すべて一時停止',
			'download.resumeAll' => 'すべて開始',
			'download.remainingTime' => ({required Object time}) => '残り ${time}',
			'download.timeline.today' => '今日',
			'download.timeline.yesterday' => '昨日',
			'download.timeline.thisWeek' => '今週',
			'download.timeline.thisMonth' => '今月',
			'download.errorTypes.network' => 'ネットワークエラー、再試行できます',
			'download.errorTypes.serverRejected' => 'サーバーに拒否されました。再ログインが必要かもしれません',
			'download.errorTypes.notFound' => 'リソースが失効または削除されました',
			'download.errorTypes.diskFull' => 'ストレージの空き容量が不足しています',
			'download.errorTypes.fileInUse' => 'ファイルが他のプログラムに使用されています',
			'download.errorTypes.permission' => '書き込み権限がありません',
			'download.errorTypes.cancelled' => 'キャンセルされました',
			'download.errorTypes.unknown' => '不明なエラー',
			'download.errorDetailCopied' => 'エラー詳細をコピーしました',
			'download.errorDetailCopyHint' => '長押しでエラー詳細をコピー',
			'download.restoredPaused.banner' => ({required Object num}) => '前回終了時に未完了だったタスク ${num} 件を一時停止しました',
			'download.restoredPaused.resume' => 'すべて再開',
			'download.restoredPaused.dismiss' => '閉じる',
			'download.actions.open' => '開く',
			'download.actions.play' => '再生',
			'download.actions.openWith' => '他のアプリで開く',
			'download.actions.redownload' => '再ダウンロード',
			'download.actions.relocate' => 'ファイルを移動…',
			'download.actions.categorize' => '分類…',
			'download.actions.viewOnline' => 'オンラインページを見る',
			'download.actions.delete' => '削除…',
			'download.actions.redownloadStarted' => ({required Object count}) => '${count} 件の再ダウンロードを開始しました',
			'download.actions.redownloadNone' => '再ダウンロードできる項目がありません',
			'download.actions.deleteTitle' => ({required Object count}) => '${count} 件のダウンロードを削除しますか？',
			'download.actions.deleteSummary' => ({required Object count, required Object size}) => '${count} 件 · ${size}',
			'download.actions.deleteSummaryNoSize' => ({required Object count}) => '${count} 件',
			'download.actions.deleteGalleryNote' => ({required Object count}) => 'うち ${count} 件のギャラリーはサイズに含まれていません',
			'download.actions.deleteFiles' => 'ディスク上のファイルも削除',
			'download.actions.deleteFilesDesc' => 'オフにするとリストの記録だけを削除し、ファイルはそのまま残ります',
			'download.actions.deleteFilesAllMissing' => 'ファイルはすでにないため、記録だけを削除します',
			'download.actions.deleteDone' => ({required Object count}) => '${count} 件を削除しました',
			'download.actions.deletePartial' => ({required Object failed}) => '${failed} 件のファイルを削除できませんでした（使用中の可能性があります）。記録は残しています',
			'download.actions.removeRecordAnyway' => '記録だけ削除',
			'download.actions.fileMissing' => 'ファイルが見つかりません',
			'download.actions.filePending' => '今はファイルが見つかりません（復元できる可能性があります）',
			'download.actions.statusActive' => '進行中',
			'download.actions.statusCompleted' => '完了',
			'download.actions.needsAttention' => '要対応',
			'download.actions.needsAttentionCount' => ({required Object count}) => '要対応 · ${count}',
			'download.actions.organize' => '整理',
			'download.actions.checkIntegrity' => 'ファイルの整合性をチェック…',
			'download.actions.migrateToCurrent' => '現在のダウンロードフォルダへ移動…',
			'download.actions.migrateNone' => 'すべてのダウンロード済みコンテンツは現在のダウンロードフォルダにあります',
			'download.notice.failed' => ({required Object count}) => '${count} 件のダウンロードが失敗しました',
			'download.notice.retryAll' => 'すべて再試行',
			'download.notice.view' => '表示',
			'download.notice.missing' => ({required Object count}) => 'ダウンロード済みの ${count} 件のファイルが見つかりません',
			'download.notice.handle' => '対処…',
			'download.notice.outside' => ({required Object count}) => '古いダウンロードフォルダに ${count} 件残っています',
			'download.notice.migrate' => '移動',
			'download.notice.dismiss' => '閉じる',
			'download.emptyTaskList' => 'ダウンロードタスクがありません',
			'download.noMatchingTasks' => '一致するタスクがありません',
			'download.deleteByDate.menuTitle' => '日付で削除',
			'download.deleteByDate.dialogTitle' => '日付で削除',
			'download.deleteByDate.description' => '作成日でダウンロードタスクを一括削除します。使用中のファイルはスキップされ、ファイルが既に存在しないタスクは整理されます。',
			'download.deleteByDate.modeRange' => '期間',
			'download.deleteByDate.modeDays' => '日数で指定',
			'download.deleteByDate.startDate' => '開始日',
			'download.deleteByDate.endDate' => '終了日',
			'download.deleteByDate.notSet' => '未設定',
			'download.deleteByDate.daysUnit' => '日',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => '${days}日前より古いタスクを削除',
			'download.deleteByDate.noMatch' => '条件に一致するタスクがありません',
			'download.deleteByDate.invalidRange' => '開始日は終了日以前にしてください',
			'download.deleteByDate.confirmTitle' => '削除の確認',
			'download.deleteByDate.confirmContent' => ({required Object count}) => '${count}件のダウンロードタスクとそのファイルを削除しますか？この操作は取り消せません。',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => '削除中 ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => '${count}件のタスクを削除しました',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => '${deleted}件を削除、${skipped}件をスキップ（使用中）',
			'download.relocation.moveFiles' => 'ファイルを移動',
			'download.relocation.moveFilesEllipsis' => 'ファイルを移動…',
			'download.relocation.chooseDestination' => 'ファイルの移動先',
			'download.relocation.currentDownloadDir' => '現在のダウンロードフォルダ',
			'download.relocation.otherFolder' => '別のフォルダを選択…',
			'download.relocation.pickerUnsupported' => 'この端末ではフォルダを選択できません。ダウンロードはアプリ専用フォルダに保存されます。',
			'download.relocation.planning' => 'ファイルを確認しています…',
			'download.relocation.confirmTitle' => 'ファイルを移動しますか？',
			'download.relocation.confirmNote' => 'ディスク上でファイルを移動します。視聴位置、VR 設定、お気に入りも一緒に引き継がれます。',
			'download.relocation.nothingToMove' => '選択した項目はどれも移動できません。各項目の理由は下を確認してください。',
			'download.relocation.move' => '移動',
			'download.relocation.moving' => ({required Object done, required Object total}) => '移動中 ${done}/${total}',
			'download.relocation.stop' => '停止',
			'download.relocation.stopping' => '現在の項目が終わったら停止します…',
			'download.relocation.resultTitle' => '移動が完了しました',
			'download.relocation.resultMoved' => ({required Object count}) => '${count} 件を移動しました',
			'download.relocation.cancelled' => '停止しました。移動済みの項目はすべて完全です。',
			'download.relocation.alreadyRunning' => '別の移動がすでに実行中です',
			'download.relocation.destination' => '移動先',
			'download.relocation.statMove' => '移動予定',
			'download.relocation.statSkip' => 'スキップ',
			'download.relocation.statRenamed' => '名前変更',
			'download.relocation.statMoved' => '移動済み',
			'download.relocation.statFailed' => '未移動',
			'download.relocation.statLeftover' => '残存',
			'download.relocation.sectionMove' => '移動する項目',
			'download.relocation.sectionSkip' => 'スキップする項目',
			'download.relocation.sectionMoved' => '移動済み',
			'download.relocation.sectionFailed' => '移動されなかった項目（元の場所のまま）',
			'download.relocation.sectionLeftover' => '削除しきれなかった古いフォルダ',
			'download.relocation.leftoverHint' => '新しい場所のコピーは完全です。これらの残りは削除して構いません。',
			'download.relocation.from' => '移動元',
			'download.relocation.to' => '移動先',
			'download.relocation.renamedBadge' => ({required Object name}) => '同じ名前があるため「${name}」として保存します',
			'download.relocation.showPaths' => 'パスを表示',
			'download.relocation.hidePaths' => 'パスを隠す',
			'download.relocation.revealInFolder' => 'フォルダで表示',
			'download.relocation.copyPath' => 'パスをコピー',
			'download.relocation.pathCopied' => 'パスをコピーしました',
			'download.relocation.stateDownloading' => ({required Object percent}) => 'ダウンロード中 ${percent}%',
			'download.relocation.statePending' => 'ダウンロード待ち',
			'download.relocation.statePaused' => ({required Object percent}) => '${percent}% で一時停止中',
			'download.relocation.stateFailed' => 'ダウンロード失敗',
			'download.relocation.skipAlreadyThere' => 'すでにこのフォルダにあります',
			'download.relocation.skipInsideSource' => '移動先がこのギャラリー自身のフォルダの中にあります',
			'download.relocation.reasonBusy' => '別の操作（削除または移動）を実行中',
			'download.relocation.reasonSourceLocked' => 'ファイルが使用中（再生中など）のため元の場所から削除できませんでした。何も変更していません。',
			'download.relocation.reasonNoSpace' => '移動先の空き容量が不足したため、残りをすべて停止しました。',
			'download.relocation.reasonVerifyFailed' => 'コピーしたファイルのサイズが元と一致しなかったため、コピーを破棄しました。',
			'download.relocation.reasonIoError' => 'ファイルの読み書きに失敗しました。何も変更していません。',
			'download.relocation.systemMessage' => ({required Object message}) => 'システムメッセージ：${message}',
			'download.relocation.outsideTitle' => ({required Object count}) => 'ダウンロード済みの ${count} 件がこのフォルダの外にあります',
			'download.relocation.outsideSubtitle' => '今の場所でもそのまま再生できます。ここへ移動するとひとまとめにできます。',
			'download.relocation.moveHere' => 'ここへ移動',
			'download.relocation.missingTitle' => 'ファイルが見つかりません',
			'download.relocation.recordedLocation' => '記録されている場所',
			'download.relocation.legendExists' => '存在する',
			'download.relocation.legendMissing' => '見つからない',
			'download.relocation.diagVolume' => ({required Object volume}) => 'ストレージ「${volume}」が利用できません。SD カードや外付けドライブが接続されていない可能性があります。',
			'download.relocation.diagVolumeShort' => ({required Object volume}) => 'ストレージ「${volume}」が未接続',
			'download.relocation.diagContainer' => 'アプリの更新後、システムがアプリの保存場所を移動しました。ファイルはここにあります：',
			'download.relocation.diagContainerShort' => '更新後に保存場所が変わりました',
			'download.relocation.diagNoAccess' => 'この場所を読み取る権限がありません。「すべてのファイルへのアクセス」を許可してから再確認してください。',
			'download.relocation.diagNoAccessShort' => 'この場所を読み取る権限がありません',
			'download.relocation.diagFolder' => ({required Object folder}) => 'フォルダ「${folder}」はもう存在しません。',
			'download.relocation.diagFolderShort' => ({required Object folder}) => 'フォルダ「${folder}」が存在しません',
			'download.relocation.diagFile' => ({required Object name}) => 'フォルダはありますが、「${name}」が中にありません。',
			'download.relocation.diagFileShort' => '元のフォルダにありません',
			'download.relocation.diagCandidates' => 'そのフォルダに、これと思われるもの（名前が変わった可能性）が見つかりました：',
			'download.relocation.diagNoCandidates' => 'そのフォルダに同じサイズのファイルはありませんでした。',
			'download.relocation.useThis' => 'これを使う',
			'download.relocation.fixPath' => 'パスを修正',
			'download.relocation.checkAgain' => '再確認',
			'download.relocation.grantPermission' => '権限を許可',
			'download.relocation.locate' => '別のフォルダで探す…',
			'download.relocation.deleteRecord' => '記録を削除',
			'download.relocation.locateNotFound' => 'そのフォルダにこのダウンロードのファイルはありません',
			'download.relocation.located' => '見つかりました。記録を新しい場所に更新しました',
			'download.relocation.stillMissing' => 'まだ見つかりません',
			'download.relocation.downloadedOn' => ({required Object date}) => '${date} にダウンロード',
			'download.relocation.galleryImages' => ({required Object count}) => '${count} 枚',
			'download.relocation.unfinishedDownloading' => ({required Object percent}) => 'ダウンロード中 ${percent}%：一時停止してから途中のデータごと移動し、移動後に再開',
			'download.relocation.unfinishedPending' => 'ダウンロード待ち：移動後にもう一度キューに入れます',
			'download.relocation.unfinishedPaused' => ({required Object percent}) => '${percent}% で一時停止中：途中のデータごと移動し、一時停止のまま',
			'download.relocation.unfinishedFailed' => 'ダウンロード失敗：途中のデータごと移動',
			'download.relocation.noDataYet' => 'まだ何もダウンロードされていないため、保存先だけ変更します',
			'download.relocation.missingGroup' => ({required Object count}) => 'ファイルが見つからない ${count} 件',
			'download.relocation.missingSkip' => 'そのまま',
			'download.relocation.missingRedownload' => '移動先に再ダウンロード',
			'download.relocation.missingRemove' => '記録を削除',
			'download.relocation.missingRemoveVolumeNote' => ({required Object count}) => 'うち ${count} 件は未接続のストレージ上にあるため削除しません',
			'download.relocation.failedGroup' => ({required Object count}) => 'ダウンロード失敗の ${count} 件',
			'download.relocation.failedMoveOnly' => '移動のみ',
			'download.relocation.failedMoveAndRetry' => '移動して再ダウンロード',
			'download.relocation.failedRemove' => 'タスクを削除',
			'download.relocation.failedRemoveNote' => '途中までダウンロードしたファイルも削除されます',
			'download.relocation.execute' => '実行',
			'download.relocation.actionWillRedownload' => '移動先に再ダウンロードします',
			'download.relocation.actionWillRemove' => 'この記録を削除します',
			'download.relocation.actionWillKeep' => 'ストレージ未接続のため残します',
			'download.relocation.actionWillRetry' => '移動後に再ダウンロード',
			'download.relocation.actionWillRemoveTask' => 'このタスクを削除します',
			'download.relocation.statRedownload' => '再ダウンロード',
			'download.relocation.statRemoved' => '削除済み',
			'download.relocation.sectionRedownloaded' => '再ダウンロードを開始しました',
			'download.relocation.sectionRedownloadFailed' => '再ダウンロードを開始できませんでした',
			'download.relocation.redownloadFailedHint' => 'ダウンロードリンクが無効になっている可能性があります（作品が削除または非公開）。後でダウンロード一覧から再試行できます。',
			'download.relocation.sectionRemoved' => '削除済み',
			'download.relocation.sectionKept' => '残した項目（ストレージ未接続）',
			'download.relocation.redownload' => '再ダウンロード',
			'download.relocation.redownloadStarted' => '再ダウンロードを開始しました',
			'download.relocation.redownloadNotStarted' => '再ダウンロードを開始できませんでした',
			'download.relocation.diagFileShortWithCandidates' => '元のフォルダに同じサイズのファイルがあります（名前変更の可能性）',
			'download.relocation.cleanupMenu' => '無効な記録を整理…',
			'download.relocation.cleanupScanning' => ({required Object done, required Object total}) => '確認中 ${done}/${total}',
			'download.relocation.cleanupTitle' => '無効な記録を整理',
			'download.relocation.cleanupNone' => ({required Object count}) => '完了済みの ${count} 件を確認しました。ファイルはすべてあります。',
			'download.relocation.statChecked' => '確認済み',
			'download.relocation.statMissing' => '見つからない',
			'download.relocation.statKeep' => '残す推奨',
			'download.relocation.cleanupGroupGone' => 'ファイルがありません',
			'download.relocation.cleanupGroupRecoverable' => 'まだ取り戻せる可能性あり',
			'download.relocation.cleanupRecoverableHint' => 'ストレージ未接続、権限なし、または名前変更の可能性があるため、既定では選択しません。項目を開くと詳細の確認と復旧ができます。',
			'download.relocation.selectAll' => 'すべて選択',
			'download.relocation.selectNone' => '選択解除',
			'download.relocation.removeSelected' => ({required Object count}) => '選択を削除（${count}）',
			'download.relocation.redownloadSelected' => ({required Object count}) => '選択を再ダウンロード（${count}）',
			'download.relocation.processing' => ({required Object done, required Object total}) => '処理中 ${done}/${total}',
			'download.relocation.cleanupRemoved' => ({required Object count}) => '${count} 件の記録を削除しました',
			'download.relocation.cleanupRedownloaded' => ({required Object count}) => '${count} 件の再ダウンロードを開始しました',
			'download.relocation.tapForDetail' => '詳細',
			'download.relocation.deleteRecordFailed' => '記録を削除できませんでした。後でもう一度お試しください',
			'download.relocation.sectionNotAttempted' => '未処理（停止したため元のまま）',
			'download.relocation.unexpectedError' => ({required Object message}) => 'エラーで停止しました：${message}。移動済みの項目はすべて完全です。',
			'download.category.manageTitle' => 'カテゴリーの管理',
			_ => null,
		} ?? switch (path) {
			'download.category.label' => 'カテゴリー',
			'download.category.uncategorized' => '未分類',
			'download.category.manage' => '管理',
			'download.category.createShortcut' => '新規作成',
			'download.category.newCategoryHint' => '新しいカテゴリー名',
			'download.category.createSuccess' => 'カテゴリーを作成しました',
			'download.category.createFailed' => 'カテゴリーの作成に失敗しました',
			'download.category.nameEmpty' => 'カテゴリー名を入力してください',
			'download.category.emptyHint' => 'カテゴリーがまだありません。作成してダウンロードを整理しましょう。',
			'download.category.moveTo' => 'カテゴリーへ移動',
			'download.category.moveToWithCount' => ({required Object count}) => '${count}件をカテゴリーへ移動…',
			'download.category.moveSuccess' => ({required Object title}) => '「${title}」へ移動しました',
			'download.category.moveToUncategorizedSuccess' => '「未分類」へ移動しました',
			'download.category.moveFailed' => '移動に失敗しました',
			'download.category.renameTitle' => 'カテゴリー名の変更',
			'download.category.renameHint' => 'カテゴリー名を入力',
			'download.category.renameSuccess' => '名前を変更しました',
			'download.category.renameFailed' => '名前の変更に失敗しました',
			'download.category.deleteTitle' => 'カテゴリーの削除',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'カテゴリ「${title}」を削除しますか？中の ${count} 件は「未分類」へ移動し、ファイルは削除されません。',
			'download.category.deleteSuccess' => 'カテゴリーを削除しました',
			'download.category.deleteFailed' => 'カテゴリーの削除に失敗しました',
			'download.location.sectionTitle' => '保存先',
			'download.location.behaviorSection' => 'ダウンロードの動作',
			'download.location.namingSection' => 'ファイル名',
			'download.location.advancedSection' => '詳細',
			'download.location.advancedSubtitle' => '書き込み診断などのツール',
			'download.location.volumeInternal' => '内部ストレージ',
			'download.location.volumeSdCard' => 'SD カード',
			'download.location.volumeExternalDrive' => '外付けドライブ',
			'download.location.appSpace' => 'アプリ専用領域',
			'download.location.downloadsFolder' => 'ダウンロード',
			'download.location.askEveryTime' => '毎回確認する',
			'download.location.askEveryTimeDesc' => ({required Object location}) => 'ダウンロードのたびに保存先を選びます。一括ダウンロードは ${location} に保存されます',
			'download.location.freeSpace' => ({required Object size}) => '空き ${size}',
			'download.location.statusWritable' => '書き込み可',
			'download.location.statusNeedsPermission' => '許可が必要',
			'download.location.statusFallback' => '一時的に別の場所へ保存',
			'download.location.statusLowSpace' => '空き容量不足',
			'download.location.statusChecking' => '確認中',
			'download.location.grant' => '許可',
			'download.location.fix' => '修復',
			'download.location.changeLocation' => '保存先を変更',
			'download.location.openInFileManager' => 'ファイルマネージャーで開く',
			'download.location.moreActions' => 'その他',
			'download.location.copyPath' => 'パスをコピー',
			'download.location.pathCopied' => 'パスをコピーしました',
			'download.location.manualInput' => 'パスを手動入力（上級者向け）',
			'download.location.restoreDefault' => 'デフォルトに戻す',
			'download.location.runDiagnostics' => '診断を実行',
			'download.location.restoredDefault' => 'デフォルトの保存先に戻しました',
			'download.location.sheetTitle' => '保存先を選択',
			'download.location.chooseOtherFolder' => '別のフォルダを選択…',
			'download.location.chooseOtherFolderDesc' => 'システムのファイル選択画面から選びます',
			'download.location.optionRecommendedDesc' => 'おすすめ · 許可不要',
			'download.location.optionRecommendedLegacyDesc' => 'おすすめ · ストレージの許可が必要',
			'download.location.optionAppPrivateDesc' => 'アンインストール時に削除 · ギャラリーに表示されません',
			'download.location.optionRemovableDesc' => '「全ファイルへのアクセス」が必要',
			'download.location.optionDesktopDownloadsDesc' => 'おすすめ · システムのダウンロードフォルダ',
			'download.location.optionAskEveryTimeDesc' => 'ダウンロードのたびにフォルダを選びます',
			'download.location.current' => '現在',
			'download.location.fallbackBanner' => '選択したフォルダが一時的に使えなかったため、前回のダウンロードはアプリ領域に保存されました。',
			'download.location.fallbackReasonPermission' => 'ストレージの許可がありません',
			'download.location.fallbackReasonVolumeMissing' => 'ストレージが接続されていません',
			'download.location.fallbackReasonCannotCreate' => 'フォルダを作成できません',
			'download.location.fallbackReasonNotWritable' => 'フォルダに書き込めません',
			'download.location.fallbackDetail' => ({required Object reason}) => '一時的に別の場所へ保存中：${reason}',
			'download.location.errorUnresolvable' => 'この場所はクラウドドライブや他のアプリのもので、直接書き込めません。端末のストレージか SD カードのフォルダを選んでください。',
			'download.location.errorNotWritable' => 'このフォルダには書き込めません（読み取り専用、システムで保護されている、または切断されています）。保存先は変更されていません。',
			'download.location.errorVolumeMissing' => 'このストレージが見つかりません（取り外されたか、接続されていません）。保存先は変更されていません。',
			'download.location.permissionTitle' => '許可が必要です',
			'download.location.permissionAllFiles' => 'このフォルダに書き込むには「全ファイルへのアクセス」が必要です。許可したくない場合は「ダウンロード › LoveIwara」を使えます。',
			'download.location.permissionLegacy' => 'このフォルダに書き込むにはストレージの許可が必要です。許可したくない場合はアプリ専用領域を使えます。',
			'download.location.useDownloadsInstead' => 'ダウンロード › LoveIwara を使う',
			'download.location.useAppSpaceInstead' => 'アプリ専用領域を使う',
			'download.location.goToSettings' => '許可する',
			'download.location.permissionDenied' => '許可されなかったため、保存先は変更されていません。',
			'download.location.checking' => 'この場所を確認しています…',
			'download.location.confirmTitle' => 'この場所を使いますか？',
			'download.location.confirmFree' => ({required Object size}) => '空き容量 ${size}',
			'download.location.confirmOutside' => ({required Object count}) => 'ダウンロード済みの ${count} 件は元の場所に残っています',
			'download.location.confirmOutsideDesc' => '今後のダウンロードは新しい場所に保存されます。ダウンロード済みのものはどうしますか？',
			'download.location.moveThem' => '移動する',
			'download.location.keepThem' => '元の場所に残す',
			'download.location.decideLater' => 'あとで決める',
			'download.location.useThisLocation' => 'この場所を使う',
			'download.location.locationChanged' => '保存先を変更しました',
			'download.location.manualTitle' => 'パスを手動入力',
			'download.location.manualLabel' => 'フォルダのパス',
			'download.location.manualHint' => '例: /storage/emulated/0/Download/LoveIwara',
			'download.location.manualSubmit' => '確認して使う',
			'download.location.manualEmpty' => 'パスを入力してください',
			'download.location.manualNotAbsolute' => '完全な絶対パスを入力してください',
			'download.location.fixStillFailing' => 'この場所はまだ使えません。別の場所を選んでください。',
			'download.location.fixed' => '保存先が使えるようになりました',
			'download.maxConcurrentDownloads' => '最大同時ダウンロード数',
			'download.maxConcurrentDownloadsDesc' => '同時にダウンロードするタスク数（1-5）',
			'download.stillInDevelopment' => '開発中',
			'download.saveToAppDirectory' => 'アプリケーションディレクトリに保存',
			'download.alreadyDownloadedWithQuality' => 'すでに同じ品質のタスクがあります。続けてダウンロードしますか？',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'すでに品質が${qualities}のタスクがあります。続けてダウンロードしますか？',
			'download.otherQualities' => 'その他の品質',
			'download.batchDownload.title' => '一括ダウンロード',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'タスクが実行中です。しばらくお待ちください',
			'download.batchDownload.userCancelled' => 'ユーザーによるキャンセル',
			'download.batchDownload.failedToGetVideoInfo' => '動画情報の取得に失敗しました',
			'download.batchDownload.failedToGetVideoSource' => '動画ソースの取得に失敗しました',
			'download.batchDownload.failedToGetGalleryInfo' => 'ギャラリー情報の取得に失敗しました',
			'download.batchDownload.galleryNoImages' => 'ギャラリーに画像がありません',
			'download.batchDownload.failedToGetSavePath' => '保存パスの取得に失敗しました',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => '一括ダウンロードに失敗しました: ${exception}',
			'download.batchDownload.selectQuality' => '品質を選択',
			'download.batchDownload.downloading' => 'ダウンロード中',
			'download.batchDownload.downloadResult' => 'ダウンロード結果',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => '${count}件の動画を選択',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => '${count}件のギャラリーを選択',
			'download.batchDownload.qualityNote' => '選択した品質が利用できない場合は、最適な品質が使用されます',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => '処理中 ${current}/${total}',
			'download.batchDownload.queued' => 'キュー追加',
			'download.batchDownload.success' => '成功',
			'download.batchDownload.skipped' => 'スキップ',
			'download.batchDownload.failed' => '失敗',
			'download.batchDownload.failureDetails' => '失敗の詳細',
			'download.batchDownload.reasonPrivateVideo' => 'プライベート動画',
			'download.batchDownload.reasonAlreadyExists' => 'タスクが既に存在',
			'download.batchDownload.reasonNoSource' => 'ダウンロードソースなし',
			'download.batchDownload.reasonNoSavePath' => '保存パスを取得できません',
			'download.batchDownload.reasonOther' => 'その他のエラー',
			'download.batchDownload.startDownload' => 'ダウンロード開始',
			'downloadNotifications.completedTitle' => 'ダウンロード完了',
			'downloadNotifications.failedTitle' => 'ダウンロード失敗',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} のダウンロードが完了しました',
			'downloadNotifications.failedBody' => ({required Object name}) => '${name} のダウンロードに失敗しました',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} をダウンロードしました',
			'downloadNotifications.failedToast' => ({required Object name}) => '${name} のダウンロードに失敗しました',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => '${dir} に保存しました',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => '${name} として保存しました（同名ファイルが既にあります）',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'アプリフォルダに保存しました — ${target} に書き込めません（${reason}）',
			'downloadNotifications.viewFolder' => 'フォルダを表示',
			'downloadNotifications.fixInSettings' => '設定で修正',
			'downloadNotifications.channelName' => 'ダウンロード状態',
			'downloadNotifications.channelDescription' => 'ダウンロードの完了と失敗の通知',
			'favorite.errors.addFailed' => '追加に失敗しました',
			'favorite.errors.addSuccess' => '追加に成功しました',
			'favorite.errors.deleteFolderFailed' => 'フォルダーの削除に失敗しました',
			'favorite.errors.deleteFolderSuccess' => 'フォルダーの削除に成功しました',
			'favorite.errors.folderNameCannotBeEmpty' => 'フォルダー名を入力してください',
			'favorite.add' => '追加',
			'favorite.addSuccess' => '追加に成功しました',
			'favorite.addFailed' => '追加に失敗しました',
			'favorite.remove' => '削除',
			'favorite.removeSuccess' => '削除に成功しました',
			'favorite.removeFailed' => '削除に失敗しました',
			'favorite.removeConfirmation' => 'このアイテムをお気に入りから削除しますか？',
			'favorite.removeConfirmationSuccess' => 'アイテムがお気に入りから削除されました',
			'favorite.removeConfirmationFailed' => 'アイテムをお気に入りから削除に失敗しました',
			'favorite.createFolderSuccess' => 'フォルダーが作成されました',
			'favorite.createFolderFailed' => 'フォルダーの作成に失敗しました',
			'favorite.createFolder' => 'フォルダーを作成',
			'favorite.enterFolderName' => 'フォルダー名を入力',
			'favorite.enterFolderNameHere' => 'フォルダー名を入力してください...',
			'favorite.create' => '作成',
			'favorite.items' => 'アイテム',
			'favorite.newFolderName' => '新しいフォルダー',
			'favorite.searchFolders' => 'フォルダーを検索...',
			'favorite.searchItems' => 'アイテムを検索...',
			'favorite.createdAt' => '作成日時',
			'favorite.myFavorites' => 'お気に入り',
			'favorite.deleteFolderTitle' => 'フォルダーを削除',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => '${title} フォルダーを削除しますか？',
			'favorite.removeItemTitle' => 'アイテムを削除',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => '${title} アイテムを削除しますか？',
			'favorite.removeItemSuccess' => 'アイテムがお気に入りから削除されました',
			'favorite.removeItemFailed' => 'アイテムをお気に入りから削除に失敗しました',
			'favorite.localizeFavorite' => 'ローカライズお気に入り',
			'favorite.editFolderTitle' => 'フォルダー名を編集',
			'favorite.editFolderSuccess' => 'フォルダー名を更新しました',
			'favorite.editFolderFailed' => 'フォルダー名の更新に失敗しました',
			'favorite.searchTags' => 'タグを検索',
			'favorite.noTagsInFolder' => 'このフォルダーの作品にはまだタグがありません',
			'favorite.tagFilterMatchAll' => '選択したタグをすべて含む作品のみ表示します',
			'favorite.clearSelectedTags' => '選択したタグをクリア',
			'favorite.selectedTagCount' => ({required Object count}) => '${count} 件選択中',
			'favorite.noMatchingTags' => '一致するタグがありません',
			'translation.currentService' => '現在のサービス',
			'translation.testConnection' => 'テスト接続',
			'translation.testConnectionSuccess' => 'テスト接続成功',
			'translation.testConnectionFailed' => 'テスト接続失敗',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'テスト接続失敗: ${message}',
			'translation.translation' => '翻訳',
			'translation.needVerification' => '検証が必要です',
			'translation.needVerificationContent' => 'まず接続テストを行ってからAI翻訳を有効にしてください',
			'translation.confirm' => '確定',
			'translation.disclaimer' => '使用須知',
			'translation.riskWarning' => '風險提示',
			'translation.dureToRisk1' => 'ユーザーが生成したテキストが原因で、AIサービスプロバイダーのコンテンツポリシーに違反する内容が含まれる場合があります',
			'translation.dureToRisk2' => '不当なコンテンツはAPIキーの停止やサービスの終了を引き起こす可能性があります',
			'translation.operationSuggestion' => '操作推奨',
			'translation.operationSuggestion1' => '1. 翻訳前に内容を厳格に審査してください',
			'translation.operationSuggestion2' => '2. 暴力、成人向けコンテンツなどを翻訳しないでください',
			'translation.apiConfig' => 'API設定',
			'translation.modifyConfigWillAutoCloseAITranslation' => '設定を変更するとAI翻訳が自動的に閉じられます。再度開くには接続テストを行ってください',
			'translation.apiAddress' => 'APIアドレス',
			'translation.modelName' => 'モデル名',
			'translation.modelNameHintText' => '例：gpt-4-turbo',
			'translation.maxTokens' => '最大トークン数',
			'translation.maxTokensHintText' => '例：32000',
			'translation.temperature' => '温度係数',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'テストボタンをクリックしてAPI接続を検証',
			'translation.requestPreview' => 'リクエストプレビュー',
			'translation.enableAITranslation' => 'AI翻訳',
			'translation.enabled' => '有効',
			'translation.disabled' => '無効',
			'translation.testing' => 'テスト中...',
			'translation.testNow' => '今すぐテスト',
			'translation.connectionStatus' => '接続状態',
			'translation.success' => '成功',
			'translation.failed' => '失敗',
			'translation.information' => '情報',
			'translation.viewRawResponse' => '生の応答を表示',
			'translation.pleaseCheckInputParametersFormat' => '入力パラメーターの形式を確認してください',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'APIアドレス、モデル名、およびキーを入力してください',
			'translation.pleaseFillInValidConfigurationParameters' => '有効な設定パラメーターを入力してください',
			'translation.pleaseCompleteConnectionTest' => '接続テストを完了してください',
			'translation.notConfigured' => '未設定',
			'translation.apiEndpoint' => 'APIエンドポイント',
			'translation.configuredKey' => '設定済みキー',
			'translation.notConfiguredKey' => '未設定キー',
			'translation.authenticationStatus' => '認証状態',
			'translation.thisFieldCannotBeEmpty' => 'このフィールドは空にできません',
			'translation.apiKey' => 'APIキー',
			'translation.apiKeyCannotBeEmpty' => 'APIキーは空にできません',
			'translation.pleaseEnterValidNumber' => '有効な数値を入力してください',
			'translation.range' => '範囲',
			'translation.mustBeGreaterThan' => '以上',
			'translation.invalidAPIResponse' => '無効なAPI応答',
			'translation.connectionFailedForMessage' => ({required Object message}) => '接続失敗: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI翻訳は有効にされていません。設定で有効にしてください',
			'translation.goToSettings' => '設定に移動',
			'translation.disableAITranslation' => 'AI翻訳を無効にする',
			'translation.currentValue' => '現在値',
			'translation.configureTranslationStrategy' => '翻訳戦略を設定',
			'translation.advancedSettings' => '高度な設定',
			'translation.translationPrompt' => '翻訳プロンプト',
			'translation.promptHint' => '翻訳プロンプトを入力してください。[TL]を目標言語のプレースホルダーとして使用します',
			'translation.promptHelperText' => 'プロンプトには[TL]を目標言語のプレースホルダーとして含めてください',
			'translation.promptMustContainTargetLang' => 'プロンプトには[TL]プレースホルダーを含めてください',
			'translation.aiTranslationWillBeDisabled' => 'AI翻訳が自動的に無効にされます',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => '基本設定を変更したため、AI翻訳が自動的に無効にされます',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => '翻訳プロンプトを変更したため、AI翻訳が自動的に無効にされます',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'パラメーター設定を変更したため、AI翻訳が自動的に無効にされます',
			'translation.onlyOpenAIAPISupported' => '現在、OpenAI互換のAPI形式（application/jsonリクエストボディ形式）のみサポートされています',
			'translation.streamingTranslation' => 'ストリーミング翻訳',
			'translation.streamingTranslationSupported' => 'ストリーミング翻訳対応',
			'translation.streamingTranslationNotSupported' => 'ストリーミング翻訳非対応',
			'translation.streamingTranslationDescription' => 'ストリーミング翻訳は翻訳プロセス中にリアルタイムで結果を表示し、より良いユーザー体験を提供します',
			'translation.baseUrlInputHelperText' => '末尾が#の場合、入力されたURLを実際のリクエストアドレスとして使用します',
			'translation.currentActualUrl' => ({required Object url}) => '現在の実際のURL: ${url}',
			'translation.usingFullUrlWithHash' => '完全なURL（#で終わる）を使用',
			'translation.urlEndingWithHashTip' => 'URLが#で終わる場合、入力されたURLを実際のリクエストアドレスとして使用します',
			'translation.streamingTranslationWarning' => '注意：この機能はAPIサービスがストリーミング伝送をサポートする必要があり、一部のモデルではサポートされていない場合があります',
			'translation.translationService' => '翻訳サービス',
			'translation.translationServiceDescription' => 'お好みの翻訳サービスを選択してください',
			'translation.googleTranslation' => 'Google 翻訳',
			'translation.googleTranslationDescription' => '複数の言語をサポートする無料のオンライン翻訳サービス',
			'translation.aiTranslation' => 'AI 翻訳',
			'translation.aiTranslationDescription' => '大規模言語モデルに基づくインテリジェント翻訳サービス',
			'translation.deeplxTranslation' => 'DeepLX 翻訳',
			'translation.deeplxTranslationDescription' => 'DeepL翻訳のオープンソース実装、高品質な翻訳を提供',
			'translation.googleTranslationFeatures' => '機能',
			'translation.freeToUse' => '無料で使用',
			'translation.freeToUseDescription' => '設定不要、すぐに使用可能',
			'translation.fastResponse' => '高速応答',
			'translation.fastResponseDescription' => '翻訳速度が速く、遅延が低い',
			'translation.stableAndReliable' => '安定で信頼性が高い',
			'translation.stableAndReliableDescription' => 'Google公式APIに基づく',
			'translation.enabledDefaultService' => '有効 - デフォルト翻訳サービス',
			'translation.notEnabled' => '無効',
			'translation.deeplxTranslationService' => 'DeepLX 翻訳サービス',
			'translation.deeplxDescription' => 'DeepLXはDeepL翻訳のオープンソース実装で、Free、Pro、Officialの3つのエンドポイントモードをサポートしています',
			'translation.serverAddress' => 'サーバーアドレス',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'DeepLXサーバーのベースアドレス',
			'translation.endpointType' => 'エンドポイントタイプ',
			'translation.freeEndpoint' => 'Free - 無料エンドポイント、レート制限がある場合があります',
			'translation.proEndpoint' => 'Pro - dl_sessionが必要、より安定',
			'translation.officialEndpoint' => 'Official - 公式API形式',
			'translation.finalRequestUrl' => '最終リクエストURL',
			'translation.apiKeyOptional' => 'API Key (オプション)',
			'translation.apiKeyOptionalHint' => '保護されたDeepLXサービスへのアクセス用',
			'translation.apiKeyOptionalHelperText' => '一部のDeepLXサービスは認証にAPI Keyが必要です',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Proモードに必要なdl_sessionパラメーター',
			'translation.dlSessionHelperText' => 'Proエンドポイントに必要なセッションパラメーター、DeepL Proアカウントから取得',
			'translation.proModeRequiresDlSession' => 'Proモードにはdl_sessionの入力が必要です',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'テストボタンをクリックしてDeepLX API接続を検証',
			'translation.enableDeepLXTranslation' => 'DeepLX翻訳を有効にする',
			'translation.deepLXTranslationWillBeDisabled' => '設定変更によりDeepLX翻訳が無効になります',
			'translation.translatedResult' => '翻訳結果',
			'translation.testSuccess' => 'テスト成功',
			'translation.pleaseFillInDeepLXServerAddress' => 'DeepLXサーバーアドレスを入力してください',
			'translation.invalidAPIResponseFormat' => '無効なAPI応答形式',
			'translation.translationServiceReturnedError' => '翻訳サービスがエラーまたは空の結果を返しました',
			'translation.connectionFailed' => '接続失敗',
			'translation.translationFailed' => '翻訳失敗',
			'translation.aiTranslationFailed' => 'AI翻訳失敗',
			'translation.deeplxTranslationFailed' => 'DeepLX翻訳失敗',
			'translation.aiTranslationTestFailed' => 'AI翻訳テスト失敗',
			'translation.deeplxTranslationTestFailed' => 'DeepLX翻訳テスト失敗',
			'translation.streamingTranslationTimeout' => 'ストリーミング翻訳タイムアウト、リソース強制クリーンアップ',
			'translation.translationRequestTimeout' => '翻訳リクエストタイムアウト',
			'translation.streamingTranslationDataTimeout' => 'ストリーミング翻訳データ受信タイムアウト',
			'translation.dataReceptionTimeout' => 'データ受信タイムアウト',
			'translation.streamDataParseError' => 'ストリームデータ解析エラー',
			'translation.streamingTranslationFailed' => 'ストリーミング翻訳失敗',
			'translation.fallbackTranslationFailed' => '通常翻訳へのフォールバックも失敗',
			'translation.translationSettings' => '翻訳設定',
			'translation.enableGoogleTranslation' => 'Google翻訳を有効にする',
			'translation.thinking' => '思考中…',
			'translation.thoughtProcess' => '思考過程',
			'translation.modelCompatibility' => 'モデル互換性',
			'translation.modelCompatibilityDescription' => '推論モデル(o1/o3、DeepSeek-R1、QwQ など)など最新モデルにリクエストパラメータを適合させます',
			'translation.reasoningModel' => '推論モデル',
			'translation.reasoningModelDescription' => 'o1/o3、DeepSeek-R1、QwQ など向け：プロンプトをユーザーメッセージに統合し、temperature を送らず、max_completion_tokens を使用します',
			'translation.useMaxCompletionTokens' => 'max_completion_tokens を使用',
			'translation.useMaxCompletionTokensDescription' => '新しい OpenAI エンドポイントでは非推奨の max_tokens ではなく max_completion_tokens が必要です',
			'translation.sendTemperature' => 'temperature を送信',
			'translation.sendTemperatureDescription' => 'temperature パラメータを受け付けないモデル(多くの推論モデル)ではオフにしてください',
			'translation.showReasoningProcess' => '思考過程を表示',
			'translation.showReasoningProcessDescription' => '翻訳ダイアログで推論モデルの思考過程を折りたたみ表示します',
			'translation.provider' => 'プロバイダー',
			'translation.providerOpenAI' => 'OpenAI（および互換エンドポイント）',
			'translation.providerAnthropic' => 'Anthropic（Claude）',
			'translation.providerGoogle' => 'Google（Gemini）',
			'translation.multiProviderHint' => 'dartantic_ai SDK により OpenAI（およびすべての OpenAI 互換エンドポイント）、Anthropic、Google に対応',
			'translation.baseUrlOptionalHelperText' => '任意。空欄でプロバイダー既定のエンドポイントを使用。OpenAI 互換/中継先は入力してください',
			'translation.defaultEndpoint' => '既定のエンドポイント',
			'translation.providerPreset' => 'プロバイダープリセット',
			'translation.selectProviderPreset' => 'プリセットを選択',
			'translation.presetCustom' => 'カスタム',
			'translation.presetApplied' => ({required Object name}) => 'プリセットを適用しました：${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI 推論 (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude 推論 (extended thinking)',
			'translation.presetNames.gemini' => 'Google Gemini (ネイティブ)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini 推論 (thinking)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek 推論 (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'モデル一覧を取得',
			'translation.fetchingModels' => '取得中…',
			'translation.selectModel' => 'モデルを選択',
			'translation.searchModel' => 'モデルを検索',
			'translation.noModelsFound' => 'モデルが見つかりません',
			'mediaPlayer.videoPlayerError' => 'ビデオプレイヤーエラー',
			'mediaPlayer.videoLoadFailed' => 'ビデオ読み込み失敗',
			'mediaPlayer.videoCodecNotSupported' => 'ビデオコーデックがサポートされていません',
			'mediaPlayer.networkConnectionIssue' => 'ネットワーク接続の問題',
			'mediaPlayer.insufficientPermission' => '権限不足',
			'mediaPlayer.unsupportedVideoFormat' => 'サポートされていないビデオ形式',
			'mediaPlayer.retry' => '再試行',
			'mediaPlayer.externalPlayer' => '外部プレイヤー',
			'mediaPlayer.detailedErrorInfo' => '詳細エラー情報',
			'mediaPlayer.format' => '形式',
			'mediaPlayer.suggestion' => '提案',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'AndroidデバイスはWEBM形式のサポートが限定的です。外部プレイヤーの使用またはWEBMをサポートするプレイヤーアプリのダウンロードをお勧めします',
			'mediaPlayer.currentDeviceCodecNotSupported' => '現在のデバイスはこのビデオ形式のコーデックをサポートしていません',
			'mediaPlayer.checkNetworkConnection' => 'ネットワーク接続を確認して再試行してください',
			'mediaPlayer.appMayLackMediaPermission' => 'アプリに必要なメディア再生権限が不足している可能性があります',
			'mediaPlayer.tryOtherVideoPlayer' => '他のビデオプレイヤーをお試しください',
			'mediaPlayer.unrecognizedVideoFormat' => '認識できない動画ファイル',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'リンクが失効したか、返ってきたものが動画ではない可能性があります。再試行するか、他のアプリで開いてください。',
			'mediaPlayer.accessDenied' => 'サーバーがこのアクセスを拒否しました（403）',
			'mediaPlayer.accessDeniedSuggestion' => '再生リンクの有効期限が切れている可能性が高いです。「再試行」で取り直すか、他のアプリで開いてください。',
			'mediaPlayer.mute' => 'ミュート',
			'mediaPlayer.unmute' => 'ミュート解除',
			'mediaPlayer.video' => 'ビデオ',
			'mediaPlayer.serverSelector' => 'CDNサーバー選択',
			'mediaPlayer.serverSelectorDescription' => '最適な再生体験のために、遅延の最も少ないサーバーを選択してください',
			'mediaPlayer.retestSpeed' => '再速度テスト',
			'mediaPlayer.waitingForSpeedTest' => '速度テスト待ち',
			'mediaPlayer.testingSpeed' => '速度テスト中...',
			'mediaPlayer.testFailed' => 'テスト失敗',
			'mediaPlayer.loadingServerList' => 'サーバーリストを読み込み中...',
			'mediaPlayer.noAvailableServers' => '利用可能なサーバーがありません',
			'mediaPlayer.refreshServerList' => 'サーバーリストを更新',
			'mediaPlayer.cannotGetSource' => '現在の再生ソースを取得できません',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'サーバーを切り替えました: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => '合計 ${count} 台のサーバー',
			'mediaPlayer.statusCode' => ({required Object code}) => 'ステータスコード: ${code}',
			'mediaPlayer.connectionFailed' => '接続失敗',
			'mediaPlayer.connectionTimeout' => '接続タイムアウト',
			'mediaPlayer.networkError' => 'ネットワークエラー',
			'mediaPlayer.sslError' => 'SSL証明書エラー',
			'mediaPlayer.testCompleted' => 'テスト完了',
			'mediaPlayer.local' => 'ローカル',
			'mediaPlayer.unknown' => '不明',
			'mediaPlayer.localVideoPathEmpty' => 'ローカルビデオパスが空です',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'ローカルビデオファイルが存在しません: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'ローカルビデオを再生できません: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'NAS の動画を再生できません：${error}',
			'mediaPlayer.dropVideoFileHere' => 'ここにビデオファイルをドロップして再生',
			'mediaPlayer.supportedFormats' => '対応形式: MP4, MKV, AVI, MOV, WEBM など',
			'mediaPlayer.noSupportedVideoFile' => 'サポートされているビデオファイルが見つかりません',
			'mediaPlayer.imageLoadFailed' => '画像読み込み失敗',
			'mediaPlayer.unsupportedImageFormat' => 'サポートされていない画像形式',
			'mediaPlayer.tryOtherViewer' => '他のビューアーをお試しください',
			'mediaPlayer.retryingOpenVideoLink' => '動画リンクのオープンに失敗しました。再試行中',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'デコーダーを読み込めませんでした: ${event}。プレーヤー設定でソフトウェアデコードに切り替え、ページに再入場してお試しください',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => '動画読み込みエラー: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => '再生失敗が続いています。設定 > 診断とフィードバック からログをエクスポートして報告してください',
			'mediaPlayer.openSettingsAction' => '表示',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => '再生の通知: ${message}',
			'mediaPlayer.notice.networkUnstable' => '通信をご確認ください。再生が途切れる場合があります',
			'mediaPlayer.notice.audioTrackUnavailable' => '音声を再生できません。映像はこのまま続きます',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'ソフトウェアデコードに切り替え。電池消費が増えます',
			'mediaPlayer.notice.videoDecodeProblem' => '画質の切り替えをお試しください。映像が乱れます',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'ログを書き出して報告してください。エラーが続いています',
			'mediaPlayer.notice.issuesSheetTitle' => '再生の問題',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => '${count} 回発生',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => '位置 ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => '記録された問題はありません',
			'mediaPlayer.notice.exportLogsAction' => 'ログを書き出す',
			'diagnostics.infoSectionTitle' => '診断情報',
			'diagnostics.appVersionLabel' => 'アプリバージョン',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'メモリ使用量: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'デバイス情報を取得できません',
			'diagnostics.secureStorageLabel' => 'セキュアストレージ',
			'diagnostics.secureStorageHealthy' => '利用可能',
			'diagnostics.secureStorageRecovered' => 'リセットで自己修復済み（既存データは消去）',
			'diagnostics.secureStorageUnavailable' => '利用不可（ログイン状態は代替暗号化で保存）',
			'diagnostics.secureStoragePlatformOptOut' => 'プラットフォーム方針によりローカル暗号化（macOS ではシステムキーチェーンを使用しません）',
			'diagnostics.secureStorageDualWrite' => '（二重保存の保護が有効）',
			'diagnostics.schemaHealthLabel' => 'データベース構造',
			'diagnostics.schemaHealthOk' => '正常',
			'diagnostics.schemaHealthRepairedNow' => '今回の起動でセーフティネットにより修復（マイグレーション未適用）',
			'diagnostics.schemaHealthRepairedBefore' => '過去にセーフティネットにより修復',
			'diagnostics.logPolicySectionTitle' => 'ログポリシー',
			'diagnostics.configServiceUnavailable' => '設定サービスが未初期化のため、ログポリシーを調整できません',
			'diagnostics.enableLoggingTitle' => 'ログ記録を有効化',
			'diagnostics.enableLoggingSubtitle' => 'オフにすると新しいログ記録を停止します',
			'diagnostics.enableLogPersistenceTitle' => 'ログ永続化を有効化',
			'diagnostics.enableLogPersistenceSubtitle' => 'オフにするとメモリログのみ保持し、ディスクへ書き込みません',
			'diagnostics.minLogLevelTitle' => '最小記録レベル',
			'diagnostics.minLogLevelSubtitle' => 'このレベル未満のログは除外されます',
			'diagnostics.maxFileSizeTitle' => '単一ファイルの上限サイズ',
			'diagnostics.maxFileSizeSubtitle' => 'しきい値到達でローテーションします',
			'diagnostics.rotatedFileCountTitle' => 'メインログのローテーション数',
			'diagnostics.rotatedFileCountSubtitle' => '現在ファイルを除く保持数',
			'diagnostics.hangFileSizeTitle' => 'ハングログの上限サイズ',
			'diagnostics.hangFileSizeSubtitle' => 'hang_events ファイルの増加を制御',
			'diagnostics.hangRotatedFileCountTitle' => 'ハングログのローテーション数',
			'diagnostics.hangRotatedFileCountSubtitle' => 'hang_events の履歴保持数を制御',
			'diagnostics.healthSectionTitle' => 'ログヘルス',
			'diagnostics.refreshMetrics' => '指標を更新',
			'diagnostics.toolsSectionTitle' => 'ツール',
			'diagnostics.privacyNotice' => 'ログにはアカウント情報やリクエストパラメータなどの機密情報が含まれる可能性があります。Issue に完全なログを公開添付せず、確認後にメールで送信してください。',
			'diagnostics.exportLogsTitle' => 'ログをエクスポート',
			'diagnostics.exportLogsSubtitle' => '送信前にプライバシー情報を確認してください',
			'diagnostics.viewLogsTitle' => 'ログを表示',
			'diagnostics.viewLogsSubtitle' => 'アプリの実行ログをリアルタイム表示',
			'diagnostics.copySupportEmailTitle' => 'サポートメールをコピー',
			'diagnostics.reportIssueTitle' => '問題を報告',
			'diagnostics.reportIssueSubtitle' => 'GitHub に再現手順を記載（完全なログは添付しないでください）',
			'diagnostics.healthSummaryUnavailable' => 'ログヘルスデータがありません',
			'diagnostics.healthMetricsUnavailable' => 'ヘルス指標がまだ収集されていません',
			'diagnostics.healthNoRiskIndicators' => '現時点でリスク指標はありません',
			'diagnostics.healthAlert.flushFailureTitle' => '書き込み失敗',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'ログ書き込みが劣化',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'ファイル sink が degraded 状態です',
			'diagnostics.healthAlert.queueBacklogTitle' => '書き込みキュー滞留',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (しきい値=${threshold}, メモリ使用量が増加する可能性)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => '書き込み遅延が高い',
			'diagnostics.healthAlert.droppedTooManyTitle' => '破棄ログが多すぎます',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (しきい値=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'レート制限が発生',
			'diagnostics.healthAlert.exportFailedTitle' => 'ログエクスポート失敗',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'ログファイルが上限付近',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (IO ローテーション負荷が増加)',
			'diagnostics.toast.logServiceNotInitialized' => 'ログサービスが初期化されていません',
			'diagnostics.toast.exportSuccess' => 'ログをエクスポートしました。プライバシーを確認後、メールで送信してください',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'エクスポート失敗: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'メールアドレスをコピーしました。メールクライアントに貼り付けてログを添付してください',
			'diagnostics.shareSubject' => 'LoveIwara 診断ログ（機密情報を含む可能性があるため共有注意）',
			'logViewer.title' => 'ログビューア',
			'logViewer.searchHint' => 'ログを検索...',
			'logViewer.emptyState' => 'ログはありません',
			'logViewer.copiedToClipboard' => 'クリップボードにコピーしました',
			'crashRecoveryDialog.title' => 'アプリが異常終了しました',
			'crashRecoveryDialog.description' => '前回セッションで異常終了を検出しました。診断ログをエクスポートして開発者にメール送信すると、問題修正に役立ちます。',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => '前回バージョン: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => '前回起動: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => '最後の例外: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => '前回は画面フリーズを検出しましたが自動回復しました',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => '前回は画面が約 ${stalledMs}ms フリーズした可能性があります',
			'crashRecoveryDialog.exportGuide' => '設定 > 診断とフィードバック > ログをエクスポート へ進んでください。',
			'crashRecoveryDialog.privacyHint' => 'ログには機密情報が含まれる可能性があります。確認後、次の宛先へメール送信してください：',
			'crashRecoveryDialog.issueWarning' => '完全なログを Issue に公開添付しないでください',
			'crashRecoveryDialog.acknowledge' => '了解',
			'crashRecoveryDialog.supportEmailCopied' => 'メールアドレスをコピーしました',
			'linkInputDialog.title' => 'リンクを入力',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => '複数の${webName}リンクをインテリジェントに識別し、アプリ内の対応するページにすばやくジャンプすることをサポートします（リンクと他のテキストはスペースで区切ります）',
			'linkInputDialog.inputHint' => ({required Object webName}) => '${webName}リンクを入力してください',
			'linkInputDialog.validatorEmptyLink' => 'リンクを入力してください',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => '有効な${webName}リンクが検出されませんでした',
			'linkInputDialog.multipleLinksDetected' => '複数のリンクが検出されました。1つ選択してください：',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => '有効な${webName}リンクではありません',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'リンク解析エラー: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'サポートされていないリンク',
			_ => null,
		} ?? switch (path) {
			'linkInputDialog.unsupportedLinkDialogContent' => 'このリンクタイプは現在アプリ内で直接開くことができず、外部ブラウザを使用してアクセスする必要があります。\n\nブラウザでこのリンクを開きますか？',
			'linkInputDialog.openInBrowser' => 'ブラウザで開く',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'ブラウザを開くことを確認',
			'linkInputDialog.confirmOpenBrowserDialogContent' => '次のリンクを外部ブラウザで開こうとしています：',
			'linkInputDialog.confirmContinueBrowserOpen' => '続行してもよろしいですか？',
			'linkInputDialog.browserOpenFailed' => 'リンクを開けませんでした',
			'linkInputDialog.unsupportedLink' => 'サポートされていないリンク',
			'linkInputDialog.cancel' => 'キャンセル',
			'linkInputDialog.confirm' => 'ブラウザで開く',
			'log.logManagement' => 'ログ管理',
			'log.enableLogPersistence' => 'ログ保存を有効にする',
			'log.enableLogPersistenceDesc' => 'ログをデータベースに保存して分析に使用',
			'log.logDatabaseSizeLimit' => 'ログデータベースサイズ上限',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => '現在: ${size}',
			'log.exportCurrentLogs' => '現在のログをエクスポート',
			'log.exportCurrentLogsDesc' => '現在のアプリケーションログを開発者が診断に使用できるようにエクスポート',
			'log.exportHistoryLogs' => '履歴ログをエクスポート',
			'log.exportHistoryLogsDesc' => '指定された日付範囲内のログをエクスポート',
			'log.exportMergedLogs' => 'マージログをエクスポート',
			'log.exportMergedLogsDesc' => '指定された日付範囲内のマージログをエクスポート',
			'log.showLogStats' => 'ログ統計情報を表示',
			'log.logExportSuccess' => 'ログエクスポート成功',
			'log.logExportFailed' => ({required Object error}) => 'ログエクスポート失敗: ${error}',
			'log.showLogStatsDesc' => '様々なタイプのログの統計情報を表示',
			'log.logExtractFailed' => ({required Object error}) => 'ログ統計情報の取得に失敗しました: ${error}',
			'log.clearAllLogs' => 'すべてのログをクリア',
			'log.clearAllLogsDesc' => 'すべてのログデータをクリア',
			'log.confirmClearAllLogs' => '確認クリア',
			'log.confirmClearAllLogsDesc' => 'すべてのログデータをクリアしますか？この操作は元に戻すことができません',
			'log.clearAllLogsSuccess' => 'ログクリア成功',
			'log.clearAllLogsFailed' => ({required Object error}) => 'ログクリア失敗: ${error}',
			'log.unableToGetLogSizeInfo' => 'ログサイズ情報を取得できません',
			'log.currentLogSize' => '現在のログサイズ:',
			'log.logCount' => 'ログ数:',
			'log.logCountUnit' => 'ログ',
			'log.logSizeLimit' => 'ログサイズ上限:',
			'log.usageRate' => '使用率:',
			'log.exceedLimit' => '超過',
			'log.remaining' => '残り',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => '現在のログサイズが超過しています。古いログをクリアするか、ログサイズ上限を増加してください',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => '現在のログサイズがほぼ超過しています。古いログをクリアしてください',
			'log.cleaningOldLogs' => '古いログを自動的にクリアしています...',
			'log.logCleaningCompleted' => 'ログクリアが完了しました',
			'log.logCleaningProcessMayNotBeCompleted' => 'ログクリア過程が完了しない可能性があります',
			'log.cleanExceededLogs' => '超過ログをクリア',
			'log.noLogsToExport' => 'エクスポート可能なログデータがありません',
			'log.exportingLogs' => 'ログをエクスポートしています...',
			'log.noHistoryLogsToExport' => '履歴ログをエクスポートするのに十分なデータがありません。アプリを使用してからしばらくしてから再試行してください',
			'log.selectLogDate' => 'ログ日付を選択',
			'log.today' => '今日',
			'log.selectMergeRange' => 'マージ範囲を選択',
			'log.selectMergeRangeHint' => 'マージするログの日付範囲を選択してください',
			'log.selectMergeRangeDays' => ({required Object days}) => '最近 ${days} 日',
			'log.logStats' => 'ログ統計情報',
			'log.todayLogs' => ({required Object count}) => '今日のログ: ${count} 件',
			'log.recent7DaysLogs' => ({required Object count}) => '最近7日のログ: ${count} 件',
			'log.totalLogs' => ({required Object count}) => '合計ログ: ${count} 件',
			'log.setLogDatabaseSizeLimit' => 'ログデータベースサイズ上限を設定',
			'log.currentLogSizeWithSize' => ({required Object size}) => '現在のログサイズ: ${size}',
			'log.warning' => '警告',
			'log.newSizeLimit' => ({required Object size}) => '新しいサイズ上限: ${size}',
			'log.confirmToContinue' => '続行してもよろしいですか？',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'ログサイズ上限を ${size} に設定しました',
			'emoji.recentlyUsed' => '最近使った',
			'emoji.insertedCount' => ({required Object count}) => '${count} 個挿入しました',
			'emoji.name' => '絵文字',
			'emoji.size' => 'サイズ',
			'emoji.small' => '小',
			'emoji.medium' => '中',
			'emoji.large' => '大',
			'emoji.extraLarge' => '超大',
			'emoji.copyEmojiLinkSuccess' => '絵文字リンクをコピーしました',
			'emoji.preview' => '絵文字プレビュー',
			'emoji.library' => '絵文字ライブラリ',
			'emoji.noEmojis' => '絵文字がありません',
			'emoji.clickToAddEmojis' => '右上のボタンをクリックして絵文字を追加',
			'emoji.addEmojis' => '絵文字を追加',
			'emoji.imagePreview' => '画像プレビュー',
			'emoji.imageLoadFailed' => '画像の読み込みに失敗しました',
			'emoji.loading' => '読み込み中...',
			'emoji.delete' => '削除',
			'emoji.close' => '閉じる',
			'emoji.deleteImage' => '画像を削除',
			'emoji.confirmDeleteImage' => 'この画像を削除してもよろしいですか？',
			'emoji.cancel' => 'キャンセル',
			'emoji.batchDelete' => '一括削除',
			'emoji.confirmBatchDelete' => ({required Object count}) => '選択された${count}枚の画像を削除してもよろしいですか？この操作は元に戻せません。',
			'emoji.deleteSuccess' => '削除しました',
			'emoji.addImage' => '画像を追加',
			'emoji.addImageByUrl' => 'URLで追加',
			'emoji.addImageUrl' => '画像URLを追加',
			'emoji.imageUrl' => '画像URL',
			'emoji.enterImageUrl' => '画像URLを入力してください',
			'emoji.add' => '追加',
			'emoji.batchImport' => '一括インポート',
			'emoji.enterJsonUrlArray' => 'JSON形式のURL配列を入力してください:',
			'emoji.formatExample' => '形式例:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'JSON形式のURL配列を貼り付けてください',
			'emoji.import' => 'インポート',
			'emoji.importSuccess' => ({required Object count}) => '${count}枚の画像をインポートしました',
			'emoji.jsonFormatError' => 'JSON形式エラー、入力を確認してください',
			'emoji.createGroup' => '絵文字グループを作成',
			'emoji.groupName' => 'グループ名',
			'emoji.enterGroupName' => 'グループ名を入力してください',
			'emoji.create' => '作成',
			'emoji.editGroupName' => 'グループ名を編集',
			'emoji.save' => '保存',
			'emoji.deleteGroup' => 'グループを削除',
			'emoji.confirmDeleteGroup' => 'この絵文字グループを削除してもよろしいですか？グループ内のすべての画像も削除されます。',
			'emoji.imageCount' => ({required Object count}) => '${count}枚の画像',
			'emoji.selectEmoji' => '絵文字を選択',
			'emoji.noEmojisInGroup' => 'このグループには絵文字がありません',
			'emoji.goToSettingsToAddEmojis' => '設定で絵文字を追加してください',
			'emoji.emojiManagement' => '絵文字管理',
			'emoji.manageEmojiGroupsAndImages' => '絵文字グループと画像を管理',
			'emoji.uploadLocalImages' => 'ローカル画像をアップロード',
			'emoji.uploadingImages' => '画像をアップロード中',
			'emoji.uploadingImagesProgress' => ({required Object count}) => '${count} 枚の画像をアップロード中、お待ちください...',
			'emoji.doNotCloseDialog' => 'このダイアログを閉じないでください',
			'emoji.uploadSuccess' => ({required Object count}) => '${count} 枚の画像をアップロードしました',
			'emoji.uploadFailed' => ({required Object count}) => '${count} 枚失敗',
			'emoji.uploadFailedMessage' => '画像のアップロードに失敗しました。ネットワーク接続またはファイル形式を確認してください',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'アップロード中にエラーが発生しました: ${error}',
			'displaySettings.title' => '表示設定',
			'displaySettings.layoutSettings' => 'レイアウト設定',
			'displaySettings.layoutSettingsDesc' => 'カラム数とブレークポイント設定をカスタマイズ',
			'displaySettings.gridLayout' => 'グリッドレイアウト',
			'displaySettings.navigationOrderSettings' => 'ナビゲーション順序設定',
			'displaySettings.customNavigationOrder' => 'カスタムナビゲーション順序',
			'displaySettings.customNavigationOrderDesc' => 'ボトムナビゲーションバーとサイドバーのページ表示順序を調整',
			'layoutSettings.title' => 'レイアウト設定',
			'layoutSettings.descriptionTitle' => 'レイアウト設定の説明',
			'layoutSettings.descriptionContent' => 'ここでの設定は、動画とギャラリーリストページで表示されるカラム数を決定します。自動モードを選択して画面幅に基づいて自動調整するか、手動モードを選択してカラム数を固定できます。',
			'layoutSettings.layoutMode' => 'レイアウトモード',
			'layoutSettings.reset' => 'リセット',
			'layoutSettings.autoMode' => '自動モード',
			'layoutSettings.autoModeDesc' => '画面幅に基づいて自動調整',
			'layoutSettings.manualMode' => '手動モード',
			'layoutSettings.manualModeDesc' => '固定カラム数を使用',
			'layoutSettings.manualSettings' => '手動設定',
			'layoutSettings.fixedColumns' => '固定カラム数',
			'layoutSettings.columns' => 'カラム',
			'layoutSettings.breakpointConfig' => 'ブレークポイント設定',
			'layoutSettings.add' => '追加',
			'layoutSettings.defaultColumns' => 'デフォルトカラム数',
			'layoutSettings.defaultColumnsDesc' => '大画面のデフォルト表示',
			'layoutSettings.previewEffect' => 'プレビュー効果',
			'layoutSettings.screenWidth' => '画面幅',
			'layoutSettings.addBreakpoint' => 'ブレークポイントを追加',
			'layoutSettings.editBreakpoint' => 'ブレークポイントを編集',
			'layoutSettings.deleteBreakpoint' => 'ブレークポイントを削除',
			'layoutSettings.screenWidthLabel' => '画面幅',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'カラム数',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => '幅を入力してください',
			'layoutSettings.enterValidWidth' => '有効な幅を入力してください',
			'layoutSettings.widthCannotExceed9999' => '幅は9999を超えることはできません',
			'layoutSettings.breakpointAlreadyExists' => 'ブレークポイントが既に存在します',
			'layoutSettings.enterColumns' => 'カラム数を入力してください',
			'layoutSettings.enterValidColumns' => '有効なカラム数を入力してください',
			'layoutSettings.columnsCannotExceed12' => 'カラム数は12を超えることはできません',
			'layoutSettings.breakpointConflict' => 'ブレークポイントが既に存在します',
			'layoutSettings.confirmResetLayoutSettings' => 'レイアウト設定をリセット',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'すべてのレイアウト設定をデフォルト値にリセットしてもよろしいですか？\n\n以下に復元されます：\n• 自動モード\n• デフォルトブレークポイント設定',
			'layoutSettings.resetToDefaults' => 'デフォルトにリセット',
			'layoutSettings.confirmDeleteBreakpoint' => 'ブレークポイントを削除',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => '${width}px のブレークポイントを削除してもよろしいですか？',
			'layoutSettings.noCustomBreakpoints' => 'カスタムブレークポイントがありません、デフォルトカラム数を使用',
			'layoutSettings.breakpointRange' => 'ブレークポイント範囲',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => '編集',
			'layoutSettings.delete' => '削除',
			'layoutSettings.cancel' => 'キャンセル',
			'layoutSettings.save' => '保存',
			'bottomNav.video' => '動画',
			'bottomNav.gallery' => '画像',
			'bottomNav.subscription' => '購読',
			'bottomNav.community' => '広場',
			'bottomNav.localMedia' => '端末',
			'navigationOrderSettings.title' => 'ナビゲーション順序設定',
			'navigationOrderSettings.customNavigationOrder' => 'カスタムナビゲーション順序',
			'navigationOrderSettings.customNavigationOrderDesc' => 'ドラッグしてボトムナビゲーションバーとサイドバーの各ページの表示順序を調整',
			'navigationOrderSettings.restartRequired' => 'アプリの再起動が必要です',
			'navigationOrderSettings.navigationItemSorting' => 'ナビゲーション項目の並べ替え',
			'navigationOrderSettings.done' => '完了',
			'navigationOrderSettings.edit' => '編集',
			'navigationOrderSettings.reset' => 'リセット',
			'navigationOrderSettings.previewEffect' => 'プレビュー効果',
			'navigationOrderSettings.bottomNavigationPreview' => 'ボトムナビゲーションバーのプレビュー：',
			'navigationOrderSettings.sidebarPreview' => 'サイドバーのプレビュー：',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'ナビゲーション順序のリセットを確認',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'ナビゲーション順序をデフォルト設定にリセットしてもよろしいですか？',
			'navigationOrderSettings.cancel' => 'キャンセル',
			'navigationOrderSettings.show' => '表示',
			'navigationOrderSettings.hide' => '非表示',
			'navigationOrderSettings.hidden' => '非表示中',
			'navigationOrderSettings.hideHint' => '目のアイコンをタップしてコミュニティと端末内のファイルの表示・非表示を切り替えます',
			'navigationOrderSettings.videoDescription' => '人気の動画コンテンツを閲覧',
			'navigationOrderSettings.galleryDescription' => '画像とギャラリーを閲覧',
			'navigationOrderSettings.subscriptionDescription' => 'フォローしているユーザーの最新コンテンツを表示',
			'navigationOrderSettings.forumDescription' => 'コミュニティディスカッションに参加',
			'navigationOrderSettings.newsDescription' => '公式ニュース、記事、放送を閲覧',
			'navigationOrderSettings.communityDescription' => 'フォーラムの議論と公式ニュース・記事・ブロードキャスト',
			'navigationOrderSettings.localMediaDescription' => 'この端末に保存された動画と画像を閲覧',
			'news.title' => 'ニュース',
			'news.newsUpdates' => '更新情報',
			'news.articles' => '記事',
			'news.broadcast' => '放送',
			'news.openInBrowser' => 'ブラウザで開く',
			'searchFilter.selectField' => 'フィールドを選択',
			'searchFilter.add' => '追加',
			'searchFilter.clear' => 'クリア',
			'searchFilter.clearAll' => 'すべてクリア',
			'searchFilter.generatedQuery' => '生成されたクエリ',
			'searchFilter.copyToClipboard' => 'クリップボードにコピー',
			'searchFilter.copied' => 'コピーしました',
			'searchFilter.filterCount' => ({required Object count}) => '${count} 個のフィルター',
			'searchFilter.filterSettings' => 'フィルター設定',
			'searchFilter.field' => 'フィールド',
			'searchFilter.operator' => '演算子',
			'searchFilter.language' => '言語',
			'searchFilter.value' => '値',
			'searchFilter.dateRange' => '日付範囲',
			'searchFilter.numberRange' => '数値範囲',
			'searchFilter.from' => 'から',
			'searchFilter.to' => 'まで',
			'searchFilter.date' => '日付',
			'searchFilter.number' => '数値',
			'searchFilter.boolean' => 'ブール値',
			'searchFilter.tags' => 'タグ',
			'searchFilter.select' => '選択',
			'searchFilter.clickToSelectDate' => '日付を選択するにはクリック',
			'searchFilter.pleaseEnterValidNumber' => '有効な数値を入力してください',
			'searchFilter.pleaseEnterValidDate' => '有効な日付形式を入力してください (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => '開始値は終了値より小さくする必要があります',
			'searchFilter.startDateMustBeBeforeEndDate' => '開始日は終了日より前である必要があります',
			'searchFilter.pleaseFillStartValue' => '開始値を入力してください',
			'searchFilter.pleaseFillEndValue' => '終了値を入力してください',
			'searchFilter.rangeValueFormatError' => '範囲値の形式エラー',
			'searchFilter.contains' => '含む',
			'searchFilter.equals' => '等しい',
			'searchFilter.notEquals' => '等しくない',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => '範囲',
			'searchFilter.kIn' => 'いずれかを含む',
			'searchFilter.notIn' => 'いずれも含まない',
			'searchFilter.username' => 'ユーザー名',
			'searchFilter.nickname' => 'ニックネーム',
			'searchFilter.registrationDate' => '登録日',
			'searchFilter.description' => '説明',
			'searchFilter.title' => 'タイトル',
			'searchFilter.body' => '本文',
			'searchFilter.author' => '作者',
			'searchFilter.publishDate' => '公開日',
			'searchFilter.private' => 'プライベート',
			'searchFilter.duration' => '時間（秒）',
			'searchFilter.likes' => 'いいね数',
			'searchFilter.views' => '視聴回数',
			'searchFilter.comments' => 'コメント数',
			'searchFilter.rating' => '評価',
			'searchFilter.imageCount' => '画像数',
			'searchFilter.videoCount' => '動画数',
			'searchFilter.createDate' => '作成日',
			'searchFilter.content' => 'コンテンツ',
			'searchFilter.all' => 'すべて',
			'searchFilter.adult' => '成人向け',
			'searchFilter.general' => '一般',
			'searchFilter.yes' => 'はい',
			'searchFilter.no' => 'いいえ',
			'searchFilter.users' => 'ユーザー',
			'searchFilter.videos' => '動画',
			'searchFilter.images' => '画像',
			'searchFilter.posts' => '投稿',
			'searchFilter.forumThreads' => 'フォーラムスレッド',
			'searchFilter.forumPosts' => 'フォーラム投稿',
			'searchFilter.playlists' => 'プレイリスト',
			'searchFilter.sortTypes.relevance' => '関連性',
			'searchFilter.sortTypes.latest' => '最新',
			'searchFilter.sortTypes.views' => '視聴回数',
			'searchFilter.sortTypes.likes' => 'いいね数',
			'searchFilter.drawerSubtitle' => '変更は即時反映されます',
			'firstTimeSetup.welcome.title' => 'ようこそ',
			'firstTimeSetup.welcome.subtitle' => 'パーソナライズ設定を始めましょう',
			'firstTimeSetup.welcome.description' => '数ステップで最適な体験を提供します',
			'firstTimeSetup.basic.title' => '基本設定',
			'firstTimeSetup.basic.subtitle' => '体験をパーソナライズ',
			'firstTimeSetup.basic.description' => 'ご希望の機能設定を選択',
			'firstTimeSetup.network.title' => 'ネットワーク設定',
			'firstTimeSetup.network.subtitle' => 'ネットワークオプションを構成',
			'firstTimeSetup.network.description' => 'ネットワーク環境に合わせて調整',
			'firstTimeSetup.network.tip' => '設定後、再起動が必要です',
			'firstTimeSetup.theme.title' => 'テーマ設定',
			'firstTimeSetup.theme.subtitle' => 'お好みの見た目を選択',
			'firstTimeSetup.theme.description' => 'ビジュアル体験をパーソナライズ',
			'firstTimeSetup.player.title' => 'プレーヤー設定',
			'firstTimeSetup.player.subtitle' => '再生コントロールを構成',
			'firstTimeSetup.player.description' => 'よく使う再生設定を素早く設定',
			'firstTimeSetup.spatial.title' => '空間再生',
			'firstTimeSetup.spatial.subtitle' => 'ヘッドセットでの再生と閲覧',
			'firstTimeSetup.spatial.description' => 'ヘッドセットでは、動画もギャラリーもこの浮かぶパネル内ではなく空間に表示されます',
			'firstTimeSetup.completion.title' => '設定完了',
			'firstTimeSetup.completion.subtitle' => 'すぐに始められます',
			'firstTimeSetup.completion.description' => '関連規約をお読みの上ご同意ください',
			'firstTimeSetup.completion.agreementTitle' => '利用規約とコミュニティルール',
			'firstTimeSetup.completion.agreementDesc' => '本アプリをご利用になる前に、利用規約とコミュニティルールをよくお読みいただき、同意してください。良好な利用環境の維持に役立ちます。',
			'firstTimeSetup.completion.checkboxTitle' => '利用規約とコミュニティルールに同意しました',
			'firstTimeSetup.completion.checkboxSubtitle' => '不同意の場合、アプリを利用できません',
			'firstTimeSetup.common.settingsChangeableTip' => 'これらの設定はいつでも設定画面で変更できます',
			'firstTimeSetup.common.previousStep' => '前のステップ',
			'firstTimeSetup.common.nextStep' => '次のステップ',
			'firstTimeSetup.common.finishSetup' => '設定を完了',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'まず利用規約とコミュニティルールに同意してください',
			'proxyHelper.systemProxyDetected' => 'システムプロキシを検出',
			'proxyHelper.copied' => 'コピーしました',
			'proxyHelper.copy' => 'コピー',
			'tagSelector.selectTags' => 'タグを選択',
			'tagSelector.clickToSelectTags' => 'タグを選択するにはクリック',
			'tagSelector.addTag' => 'タグを追加',
			'tagSelector.removeTag' => 'タグを削除',
			'tagSelector.deleteTag' => 'タグを削除',
			'tagSelector.usageInstructions' => 'まずタグを追加してから、既存のタグからクリックして選択してください',
			'tagSelector.usageInstructionsTooltip' => '使用方法',
			'tagSelector.addTagTooltip' => 'タグを追加',
			'tagSelector.removeTagTooltip' => 'タグを削除',
			'tagSelector.cancelSelection' => '選択をキャンセル',
			'tagSelector.selectAll' => 'すべて選択',
			'tagSelector.cancelSelectAll' => 'すべての選択をキャンセル',
			'tagSelector.delete' => '削除',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Anime4K リアルタイムビデオアップスケーリングとノイズ除去、アニメーション動画の品質向上',
			'anime4k.settings' => 'Anime4K 設定',
			'anime4k.preset' => 'Anime4K プリセット',
			'anime4k.disable' => 'Anime4K を無効にする',
			'anime4k.disableDescription' => 'ビデオ強化効果を無効にする',
			'anime4k.highQualityPresets' => '高品質プリセット',
			'anime4k.fastPresets' => '高速プリセット',
			'anime4k.litePresets' => '軽量プリセット',
			'anime4k.moreLitePresets' => 'より軽量なプリセット',
			'anime4k.customPresets' => 'カスタムプリセット',
			'anime4k.presetGroups.highQuality' => '高品質',
			'anime4k.presetGroups.fast' => '高速',
			'anime4k.presetGroups.lite' => '軽量',
			'anime4k.presetGroups.moreLite' => 'より軽量',
			'anime4k.presetGroups.custom' => 'カスタム',
			'anime4k.presetDescriptions.mode_a_hq' => 'ほとんどの1080pアニメ、特にぼかし、再サンプリング、圧縮アーティファクトを処理する場合に適しています。最高の知覚品質を提供します。',
			'anime4k.presetDescriptions.mode_b_hq' => 'スケーリングによる軽度のぼかしやリンギング効果のあるアニメに適しています。リンギングとエイリアスを効果的に減らすことができます。',
			'anime4k.presetDescriptions.mode_c_hq' => 'ほとんど欠陥のない高品質ソース（ネイティブ1080pアニメや映画など）に適しています。ノイズ除去を行い、最高のPSNRを提供します。',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Mode Aの強化版で、究極の知覚品質を提供し、ほぼすべての劣化ラインを再構築できます。過度なシャープネスやリンギングが発生する可能性があります。',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Mode Bの強化版で、より高い知覚品質を提供し、ラインをさらに最適化し、アーティファクトを減らします。',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Mode Cの知覚品質強化版で、高いPSNRを維持しながら一部のラインデータルを再構築しようとします。',
			'anime4k.presetDescriptions.mode_a_fast' => 'Mode Aの高速版で、品質とパフォーマンスのバランスが取れており、ほとんどの1080pアニメに適しています。',
			'anime4k.presetDescriptions.mode_b_fast' => 'Mode Bの高速版で、軽度のアーティファクトとリンギングを処理し、オーバーヘッドが低い。',
			'anime4k.presetDescriptions.mode_c_fast' => 'Mode Cの高速版で、高品質ソースの高速ノイズ除去とアップスケーリングに適しています。',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Mode A+Aの高速版で、パフォーマンスに制約のあるデバイスでより高い知覚品質を追求します。',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Mode B+Bの高速版で、パフォーマンスに制約のあるデバイスに強化されたライン修復とアーティファクト処理を提供します。',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Mode C+Aの高速版で、高品質ソースを高速処理しながら軽度のライン修復を行います。',
			'anime4k.presetDescriptions.upscale_only_s' => '最速のCNNモデルのみを使用してx2アップスケーリングを行い、修復とノイズ除去は行わず、最小限のパフォーマンスオーバーヘッド。',
			'anime4k.presetDescriptions.upscale_deblur_fast' => '従来の非CNNアルゴリズムを使用して高速アップスケーリングとデブリングを行い、デフォルトのプレーヤーアルゴリズムよりも優れた効果で、非常に低いパフォーマンスオーバーヘッド。',
			'anime4k.presetDescriptions.restore_s_only' => '最速のCNNモデルのみを使用して画像欠陥を修復し、アップスケーリングは行いません。ネイティブ解像度再生で品質を向上させたい場合に適しています。',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => '従来のバイラテラルフィルタリングを使用して高速ノイズ除去を行い、非常に高速で軽度のノイズ処理に適しています。',
			'anime4k.presetDescriptions.upscale_non_cnn' => '従来の高速アルゴリズムを使用してアップスケーリングを行い、最小限のパフォーマンスオーバーヘッドでプレーヤーのデフォルトよりも優れた効果。',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + ライン暗化、高速モードAにライン暗化効果を追加し、ラインをより目立たせ、スタイライズ処理を行います。',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + ライン細化、高品質モードAにライン細化効果を追加し、より洗練された外観にします。',
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
			'anime4k.presetNames.upscale_only_s' => 'CNNアップスケーリング (超高速)',
			'anime4k.presetNames.upscale_deblur_fast' => 'アップスケーリング & デブリング (高速)',
			'anime4k.presetNames.restore_s_only' => '復元 (超高速)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'バイラテラルノイズ除去 (超高速)',
			'anime4k.presetNames.upscale_non_cnn' => '非CNNアップスケーリング (超高速)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + ライン暗化',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + ライン細化',
			'anime4k.performanceTip' => '💡 ヒント：デバイスのパフォーマンスに基づいて適切なプリセットを選択してください。ローエンドデバイスでは軽量プリセットをお勧めします。',
			'anime4k.compatibilityTip' => '⚠️ 一部のモバイル GPU（Kirin 980 / Mali-G76 など）はカスタムシェーダーを一切描画できません。音声だけで画面が真っ暗になる場合は、ここで Anime4K をオフにしてください。',
			'anime4k.autoDisabledOnRenderFailure' => 'お使いのデバイスの GPU が Anime4K シェーダーを描画できなかったため、自動的に無効化しました。',
			'siteMode.title' => 'サイトモード',
			'siteMode.mainSite' => 'メイン',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => '現在 ${currentSite} ・ タップして ${nextSite} に切り替え',
			'siteMode.dialogTitle' => 'サイトモードを切り替え',
			'siteMode.dialogDescription' => '切り替えると、アプリ全体が再読み込みされ、これまでに読み込んだリストやページ状態がリセットされます。',
			'siteMode.chooseLinkTargetTitle' => 'リンク先サイトを選択',
			'siteMode.chooseLinkTargetDescription' => 'このリンクにはドメインが含まれていません。メインサイトか AI サイトのどちらで開くか選択してください。',
			'siteMode.chooseLinkTargetHint' => '開いた後、このページと後続の詳細リクエストは選択したサイトを使い続けます。',
			'siteMode.alreadyUsing' => 'すでにこのサイトモードを使用しています。',
			'siteMode.openInSite' => ({required Object site}) => '${site} で開く',
			'siteMode.confirmUsing' => ({required Object site}) => '確認すると、以降のリクエストは ${site} モードを使用します。',
			'siteMode.switched' => ({required Object site}) => '${site} に切り替えました。アプリは再読み込みされました。',
			'savedSearchConfig.title' => '保存した絞り込み',
			'savedSearchConfig.empty' => '保存した絞り込み設定はまだありません',
			'savedSearchConfig.saveTooltip' => '現在の絞り込みを保存',
			'savedSearchConfig.namePromptTitle' => '絞り込みを保存',
			'savedSearchConfig.nameLabel' => '名前',
			'savedSearchConfig.nameHint' => '名前を入力',
			'savedSearchConfig.saveSuccess' => '絞り込みを保存しました',
			'savedSearchConfig.deleteSuccess' => '絞り込みを削除しました',
			'savedSearchConfig.addCurrent' => '現在の絞り込みを保存',
			'savedSearchConfig.reorderHint' => '長押しでドラッグして並べ替え',
			'savedSearchConfig.rename' => '名前を変更',
			'savedSearchConfig.unnamed' => '無名',
			'savedSearchConfig.noConditions' => 'すべてのコンテンツ（絞り込みなし）',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} 個のタグ',
			'savedSearch.title' => '保存した検索',
			'savedSearch.empty' => '保存した検索はまだありません',
			'savedSearch.saveTooltip' => '現在の検索を保存',
			'savedSearch.namePromptTitle' => '検索を保存',
			'savedSearch.nameLabel' => '名前',
			'savedSearch.nameHint' => '名前を入力',
			'savedSearch.saveSuccess' => '検索を保存しました',
			'savedSearch.deleteSuccess' => '検索を削除しました',
			'savedSearch.addCurrent' => '現在の検索を保存',
			'savedSearch.reorderHint' => '長押しでドラッグして並べ替え',
			'savedSearch.rename' => '名前を変更',
			'savedSearch.noKeyword' => '（キーワードなし）',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} 個の絞り込み',
			'defaultBlacklistReminder.title' => 'デフォルトのタグブラックリストを検出しました',
			'defaultBlacklistReminder.content' => 'お使いのアカウントは、サイトが新規ユーザーごとに自動設定するデフォルトのタグブラックリストをそのまま使用しています。管理ページで確認・変更しますか？',
			'defaultBlacklistReminder.goManage' => '管理する',
			'defaultBlacklistReminder.dismiss' => '後で',
			'colorVisionAssist.title' => '色覚アシスト',
			'colorVisionAssist.description' => '色覚障がいのあるユーザー向けに動画の色を補正します。Anime4K と併用できます',
			'colorVisionAssist.galleryDescription' => '色覚障がいのあるユーザー向けにギャラリー画像の色を補正します（プレイヤーの設定とは独立）',
			'colorVisionAssist.galleryDescriptionSpatial' => '色覚障がいのあるユーザー向けにギャラリー画像の色を補正します。このパネル内の 2D ビューアーにのみ適用され、空間スクリーン上の画像はネイティブ描画のためこのフィルターを通りません',
			'colorVisionAssist.disable' => 'オフ',
			'colorVisionAssist.disableDescription' => '色補正を行いません',
			'colorVisionAssist.protanopia' => '赤色覚アシスト（1型）',
			'colorVisionAssist.protanopiaDescription' => '1型色覚（赤の識別が困難）向け',
			'colorVisionAssist.deuteranopia' => '緑色覚アシスト（2型）',
			'colorVisionAssist.deuteranopiaDescription' => '2型色覚（緑の識別が困難）向け',
			'colorVisionAssist.tritanopia' => '青色覚アシスト（3型）',
			'colorVisionAssist.tritanopiaDescription' => '3型色覚（青と黄の識別が困難）向け',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName}を適用しました（即時反映）',
			'colorVisionAssist.disabledToast' => '色覚アシストをオフにしました',
			'externalPlayer.title' => '他のアプリで開く',
			'externalPlayer.description' => '再生中の動画を端末内の別のプレイヤーに渡します（VR ヘッドセットの Skybox や Pigasus、スマホの MX Player や VLC など）',
			'externalPlayer.openWithOtherApp' => '他のアプリを選んで開く',
			'externalPlayer.openWithOtherAppDescription' => 'システムの選択画面からプレイヤーを選びます',
			'externalPlayer.openWithSystemPlayer' => '既定のプレイヤーで開く',
			'externalPlayer.openWithSystemPlayerDescription' => 'システムに関連付けられた既定の動画アプリに渡します',
			'externalPlayer.copyLink' => '動画リンクをコピー',
			'externalPlayer.copyLinkDescription' => 'URL の貼り付けにしか対応しないプレイヤー（Skybox、DeoVR など）向け',
			'externalPlayer.linkCopied' => '動画リンクをコピーしました',
			'externalPlayer.sourceLocal' => 'ローカルファイル',
			'externalPlayer.sourceOnline' => '直リンク',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => '直リンク · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => '直リンクには有効期限があり、外部プレイヤーで再生途中に切れることがあります。先にダウンロードしてから渡すのが確実です',
			'externalPlayer.vrPlayerHint' => 'VR プレイヤーが選択画面に出てこない場合は「動画リンクをコピー」してプレイヤー内で貼り付けてください',
			'externalPlayer.noHandler' => '動画を開けるアプリが見つかりません',
			'externalPlayer.handoffFailed' => ({required Object message}) => '受け渡しに失敗しました: ${message}',
			'externalPlayer.handoffFailedUnknown' => '受け渡しに失敗しました',
			'externalPlayer.sourceUnavailable' => '現在の動画のアドレスを取得できません。しばらくしてからお試しください',
			'externalPlayer.localFileMissing' => 'ローカルファイルが存在しません。削除された可能性があります',
			'externalPlayer.handedOff' => '外部プレイヤーに渡しました',
			'externalPlayer.desktopSectionTitle' => '外部プレイヤー',
			'externalPlayer.managePlayers' => '外部プレイヤーの管理',
			'externalPlayer.managePlayersDescWindows' => 'HereSphere、DeoVR、Whirligig といった PCVR プレイヤーはシステムの既定アプリではありません。その .exe を指定すると、再生画面から現在の動画を直接渡せるようになります',
			'externalPlayer.managePlayersDescMac' => 'IINA、VLC、mpv などのアプリケーションを指定すると、再生画面から現在の動画を直接渡せるようになります',
			'externalPlayer.managePlayersDescLinux' => 'mpv、VLC、Celluloid などの実行ファイルを指定すると、再生画面から現在の動画を直接渡せるようになります',
			'externalPlayer.pickExecutableHintWindows' => 'プレイヤーのインストール先にある .exe 本体を選んでください（例：HereSphere.exe、vlc.exe）。デスクトップのショートカット（.lnk）は使えません',
			'externalPlayer.pickExecutableHintMac' => '「アプリケーション」からプレイヤーの .app を選んでください（例：IINA.app）。中の実行ファイルは自動で特定します',
			'externalPlayer.pickExecutableHintLinux' => 'プレイヤーの実行ファイルを選んでください（例：/usr/bin/mpv）。which mpv で場所が分かります',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => '設定すると、再生画面の「他のアプリで開く」に項目として直接並びます。よく使われるもの：${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'インストール済みのプレイヤーは見つかりませんでした。独自のフォルダーやポータブル版は検出できないので、「プレイヤーを追加」から手動で指定してください',
			'externalPlayer.detectNothingNew' => '新しいプレイヤーはありません。インストール済みのものはすべて一覧に入っています',
			'externalPlayer.detectFailed' => '検出に失敗しました。「プレイヤーを追加」から手動で指定できます',
			'externalPlayer.advancedOptions' => '詳細設定',
			'externalPlayer.playerNameHint' => '空欄ならファイル名を使います',
			'externalPlayer.executablePathRequired' => '先にプレイヤーの実行ファイルを選んでください',
			'externalPlayer.playerCount' => ({required Object count}) => '${count} 件設定済み',
			'externalPlayer.noPlayerConfigured' => '外部プレイヤーはまだ設定されていません',
			'externalPlayer.autoDetect' => '自動検出',
			'externalPlayer.detecting' => '検出中…',
			'externalPlayer.detectFound' => ({required Object count}) => '${count} 件のプレイヤーを検出しました',
			'externalPlayer.detectNothingFound' => '新しいプレイヤーは見つかりませんでした。手動で追加できます',
			'externalPlayer.autoDetectedTag' => '自動検出',
			'externalPlayer.addPlayer' => 'プレイヤーを追加',
			'externalPlayer.editPlayer' => 'プレイヤーを編集',
			'externalPlayer.playerName' => '名前',
			'externalPlayer.executablePath' => '実行ファイル',
			'externalPlayer.browse' => '参照',
			'externalPlayer.argumentTemplate' => '起動オプション',
			'externalPlayer.argumentTemplateHint' => '{input} が動画のパスまたは URL に置き換わります。空欄なら唯一の引数として渡します',
			'externalPlayer.nameAndPathRequired' => '名前と実行ファイルは必須です',
			'externalPlayer.testLaunch' => 'テスト起動',
			'externalPlayer.testLaunched' => 'プレイヤーを起動しました',
			'externalPlayer.testFailed' => '起動に失敗しました。実行ファイルのパスを確認してください',
			'externalPlayer.executableMissing' => '実行ファイルが見つかりません',
			'externalPlayer.openWithNamed' => ({required Object name}) => '${name} で開く',
			'externalPlayer.managePlayersEntry' => '外部プレイヤーを管理…',
			'watchLater.title' => 'あとで見る',
			'watchLater.addToWatchLater' => 'あとで見る',
			'watchLater.removeFromWatchLater' => 'あとで見るから削除',
			'watchLater.addedToWatchLater' => 'あとで見るに追加しました',
			'watchLater.alreadyInWatchLater' => 'すでにあとで見るに入っています',
			'watchLater.removedFromWatchLater' => 'あとで見るから削除しました',
			'watchLater.removedCount' => ({required Object count}) => '${count} 件を削除しました',
			'watchLater.viewWatchLaterList' => 'リストを見る',
			_ => null,
		} ?? switch (path) {
			'watchLater.addFailed' => 'あとで見るへの追加に失敗しました',
			'watchLater.invalidItem' => '利用できません',
			'watchLater.clearWatched' => '視聴済みを削除',
			'watchLater.watchedCleared' => ({required Object count}) => '視聴済み ${count} 件を削除しました',
			'watchLater.noWatchedToClear' => '視聴済みの項目はありません',
			'watchLater.emptyVideo' => 'あとで見るに追加された動画はありません',
			'watchLater.emptyGallery' => 'あとで見るに追加されたギャラリーはありません',
			'watchLater.filterAll' => 'すべて',
			'watchLater.filterUnwatched' => '未視聴',
			'watchLater.sortRecentlyAdded' => '追加が新しい順',
			'watchLater.sortEarliestAdded' => '追加が古い順',
			'watchLater.watched' => '視聴済み',
			'watchLater.playlistLoadFailed' => '再生リストの読み込みに失敗しました',
			'watchLater.noPlaylists' => '再生リストがありません',
			'watchLater.undo' => '元に戻す',
			'watchLater.clearWatchedConfirm' => 'このタブの視聴済みをすべて削除しますか？元に戻せません。',
			'watchLater.emptyUnwatchedVideo' => '未視聴の動画はありません',
			'watchLater.emptyUnwatchedGallery' => '未視聴のギャラリーはありません',
			'watchLater.queueLoadFailed' => '読み込みに失敗しました。タップで再試行',
			'mediaMenu.like' => 'いいね',
			'mediaMenu.unlike' => 'いいねを取り消す',
			'mediaMenu.viewAuthor' => '作者ページを見る',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} 個のフォルダ',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} 個の再生リスト',
			'mediaMenu.downloaded' => 'ダウンロード済み',
			'mediaPreview.preview' => 'プレビュー',
			'mediaPreview.openDetail' => '開く',
			'mediaPreview.moreActions' => 'その他の操作',
			'mediaPreview.previousImage' => '前の画像',
			'mediaPreview.nextImage' => '次の画像',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} 枚',
			'playbackQueue.upNext' => '次に見る',
			'playbackQueue.sourceTab' => '元のリスト',
			'playbackQueue.emptyQueue' => 'このキューに再生できる動画はありません',
			'playbackQueue.emptyGalleryQueue' => 'このキューに画像集はありません',
			'playbackQueue.nowPlaying' => '再生中',
			'playbackQueue.myPlaylists' => '自分の再生リスト',
			'playbackQueue.authorPlaylists' => '作者の再生リスト',
			'playbackQueue.openQueue' => '次に見る',
			'playbackQueue.continueInQueue' => '現在のキューで続けて再生',
			'playbackQueue.continueInQueueSubtitle' => '1本終わると自動で次を再生します。オンの間は「再生終了後にリピート」は無効です',
			'playbackQueue.repeatDisabledByQueue' => '「現在のキューで続けて再生」がオンのため無効です',
			'playbackQueue.playNext' => '次を再生',
			'playbackQueue.queueEnded' => 'このキューの最後の項目です',
			'playbackQueue.playNextHint' => 'タップで次を再生、長押しで「次に見る」を開きます',
			'playbackQueue.authorVideos' => '作者の動画',
			'playbackQueue.authorGalleries' => '作者の画像集',
			'playbackQueue.favoriteFolders' => 'お気に入りフォルダ',
			'playbackQueue.localFiles' => 'この端末のファイル',
			'playbackQueue.currentFolder' => 'このファイルのフォルダ',
			'playbackQueue.playThisFolder' => 'このフォルダの動画キューを見る',
			'playbackQueue.browseThisFolder' => 'このフォルダのギャラリーキューを見る',
			'playbackQueue.downloads' => 'ダウンロード済み',
			'playbackQueue.otherPlaylists' => '他の人の再生リスト',
			'playbackQueue.nothingHere' => '何もありません',
			'vrFormat.playInSpace' => '空間プレイヤーで再生',
			'vrFormat.handingOff' => '空間へ引き渡し中…',
			'vrFormat.title' => '再生モード',
			'vrFormat.spatialSectionTitle' => '空間再生',
			'vrFormat.spatialSectionDesc' => 'ヘッドセットでは動画はこのパネル内には描かれず、空間プレイヤーがスクリーンに映します。',
			'vrFormat.spatialPanelEntry' => '空間コントロールパネル',
			'vrFormat.spatialPanelEntryDesc' => 'スクリーンの距離・大きさ・湾曲、背景環境、さらに再生速度・リピート・自動非表示は空間コントロールパネルで調整します。',
			'vrFormat.spatialGuideEntry' => 'ヘッドセット操作ガイド',
			'vrFormat.spatialGuideEntryDesc' => 'コントローラーのボタン、スクリーンを掴んで移動、スティックでシークとページ送り',
			'vrFormat.spatialFlatOmitted' => 'タッチ操作・画質補正・音声/映像パラメーターは 2D プレーヤー専用です。空間プレイヤーは別のエンジンで動くため、ここには表示されません。',
			'vrFormat.spatialGallerySectionTitle' => '空間ギャラリー',
			'vrFormat.spatialGalleryPanelDesc' => 'スライドショーの間隔、短い動画の単体リピート、スクリーンの湾曲は空間コントロールパネルで調整します。',
			'vrFormat.autoEnterGallery' => 'ギャラリー画像を空間ギャラリーで開く',
			'vrFormat.autoEnterGalleryDesc' => 'Quest では、画像をタップするとこのパネル内のビューアではなく、空間のスクリーンでギャラリー全体を閲覧します（フィルムストリップ・スライドショー・スティックでページ送り）。',
			'vrFormat.panelSettings' => 'パネルと背景',
			'vrFormat.panelSettingsDesc' => 'このアプリパネルの距離と、背後に透ける部屋の量',
			'vrFormat.panelDistance' => 'パネルの距離',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => '位置をリセット',
			'vrFormat.panelResetBackground' => '既定に戻す',
			'vrFormat.panelBackground' => '背景の不透明度',
			'vrFormat.panelBackgroundHint' => '0%：真っ黒な環境 · 100%：環境光に照らされた実際の部屋',
			'vrFormat.panelUnavailable' => 'パネルが今は表示されていません。少し待ってからお試しください',
			'vrFormat.desc' => 'この動画をどの形状で再生するかを選びます。サイト側に情報がないため、自動判定は初期値を示すだけで、最終的にはあなたの選択が優先されます。',
			'vrFormat.sectionFlat' => '平面',
			'vrFormat.sectionStereo' => '平面立体',
			'vrFormat.sectionPanorama' => 'VR パノラマ',
			'vrFormat.flat' => '通常の動画',
			'vrFormat.flatDesc' => '何も加工せずそのまま再生します',
			'vrFormat.flatSideBySide' => '左右 3D',
			'vrFormat.flatSideBySideDesc' => '1 フレームに左右の目が並ぶ形式。左目だけを表示し比率を戻します',
			'vrFormat.flatTopBottom' => '上下 3D',
			'vrFormat.flatTopBottomDesc' => '1 フレームに上下の目が並ぶ形式。上半分だけを表示し比率を戻します',
			'vrFormat.vr180SideBySide' => 'VR180 左右',
			'vrFormat.vr180SideBySideDesc' => '半球パノラマ + 左右両眼。最も一般的な VR 素材です',
			'vrFormat.vr180Mono' => 'VR180 単眼',
			'vrFormat.vr180MonoDesc' => '半球パノラマ。1 フレームに片目だけ',
			'vrFormat.vr360Mono' => 'VR360 単眼',
			'vrFormat.vr360MonoDesc' => '全周パノラマ。1 フレームに片目だけ',
			'vrFormat.vr360TopBottom' => 'VR360 上下',
			'vrFormat.vr360TopBottomDesc' => '全周パノラマ + 上下両眼',
			'vrFormat.resetView' => '視点をリセット',
			'vrFormat.resetViewDesc' => '見ている向きと視野角を正面に戻します',
			'vrFormat.resetToAuto' => '自動判定に戻す',
			'vrFormat.resetToAutoDesc' => 'この動画の手動設定を忘れ、自動判定に任せます',
			'vrFormat.manualBadge' => '手動で指定済み',
			'vrFormat.panoramaHint' => '画面をドラッグで見回し、ピンチで視野角を変更',
			'vrFormat.panoramaGestureNotice' => '見回し中は画面のドラッグが視点操作になります。シークはシークバーをお使いください',
			'vrFormat.shaderUnsupported' => 'この端末ではリアルタイムの見回しに対応していないため、片目表示に切り替えました',
			'vrFormat.handoffTooltip' => '別の方法で再生',
			'vrFormat.suggestedBadge' => 'おすすめ',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => '${format} の可能性があります。タップで切り替え',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'これは VR 動画かもしれません（${format}）',
			'vrFormat.suggestionTitleShort' => 'これは VR 動画かもしれません',
			'vrFormat.suggestionAction' => 'VR で再生',
			'vrFormat.suggestionDismiss' => '表示しない',
			'localMedia.browse.pinnedSection' => 'よく使う場所',
			'localMedia.browse.sourcesSection' => 'フォルダ',
			'localMedia.browse.pin' => 'よく使う場所に追加',
			'localMedia.browse.unpin' => 'よく使う場所から削除',
			'localMedia.browse.pinned' => 'よく使う場所に追加しました',
			'localMedia.browse.unpinned' => 'よく使う場所から削除しました',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} 個のフォルダ',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} 本の動画',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} 枚の画像',
			'localMedia.browse.emptyFolder' => 'このフォルダは空です',
			'localMedia.browse.videosSection' => '動画',
			'localMedia.browse.imagesSection' => '画像',
			'localMedia.browse.galleriesSection' => 'ギャラリー',
			'localMedia.browse.filterAll' => 'すべて',
			'localMedia.browse.searchInFolder' => 'このフォルダ内を検索',
			'localMedia.browse.searchHint' => '名前で検索',
			'localMedia.browse.clearSearch' => '検索をクリア',
			'localMedia.browse.searchNoResult' => ({required Object query}) => '「${query}」に一致するものはありません',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => '${count} 件のフォルダをすべて表示',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => '${count} 件の動画をすべて表示',
			'localMedia.browse.viewAllImages' => ({required Object count}) => '${count} 枚の画像をすべて表示',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => '${count} 件のギャラリーをすべて表示',
			'localMedia.browse.location' => '場所',
			'localMedia.browse.sourceMissing' => 'このソースはもうありません',
			'localMedia.browse.notScannedYet' => 'このフォルダはまだスキャンされていません',
			'localMedia.browse.scanning' => 'このフォルダーを読み込んでいます…',
			'localMedia.browse.deleteFileTitle' => 'このファイルを削除しますか？',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '「${name}」はこの端末から完全に削除されます。元に戻せません。',
			'localMedia.browse.hideFolder' => 'このフォルダを隠す',
			'localMedia.browse.unhideFolder' => '非表示を解除',
			'localMedia.browse.showHiddenFolders' => '隠したフォルダを表示',
			'localMedia.browse.includeDotFolders' => '「.」で始まるフォルダもスキャン',
			'localMedia.browse.dotFoldersIncluded' => '「.」で始まるフォルダのスキャンを開始しました',
			'localMedia.browse.dotFoldersExcluded' => '「.」で始まるフォルダをスキャンしなくなりました',
			'localMedia.browse.showDotFolders' => '「.」で始まるフォルダを表示',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'ここには「.」で始まる未スキャンのフォルダが ${count} 個あります',
			'localMedia.browse.scanDotFoldersAction' => 'このソースで有効にする',
			'localMedia.browse.otherAppsPrivateNotice' => 'Android 11 以降、他のアプリの Android/data・Android/obb 内のファイルはどのアプリからも読み取れず、本アプリでも回避できません。元のアプリで動画を Download などの共有フォルダにダウンロードまたはエクスポートしてから、そのフォルダを追加してください。再生中のキャッシュは通常分割されており、読み取れても再生できません。',
			'localMedia.browse.folderHidden' => '非表示にしました。スキャンもスキップします',
			'localMedia.browse.folderUnhidden' => '非表示を解除しました',
			'localMedia.browse.hiddenFolderBadge' => '非表示',
			'localMedia.browse.deleteFolder' => 'フォルダを削除',
			'localMedia.browse.deleteFolderTitle' => 'このフォルダを削除しますか？',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '「${name}」と中身のすべてがこの端末から完全に削除されます。元に戻せません。',
			'localMedia.browse.deleteFolderIncludesOthers' => '中にある他のファイルも一緒に削除されます',
			'localMedia.browse.folderDeleted' => 'フォルダを削除しました',
			'localMedia.browse.deleteFolderFailed' => '削除に失敗しました。権限がないか、中のファイルが使用中の可能性があります',
			'localMedia.browse.deleteGalleryTitle' => 'このギャラリーを削除しますか？',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => '「${name}」のダウンロード記録とローカル画像ファイルが削除されます。この操作は取り消せません。',
			'localMedia.browse.galleryResourceMissing' => 'ローカルリソースが存在しないため、記録を削除しました',
			'localMedia.browse.viewDownloadDetail' => 'ダウンロード詳細を表示',
			'localMedia.browse.viewOnlineGallery' => 'ウェブで表示',
			'localMedia.browse.pickFolderTitle' => 'フォルダーを選ぶ',
			'localMedia.browse.useThisFolder' => 'このフォルダーを使う',
			'localMedia.browse.noSubfolders' => 'サブフォルダーはありません',
			'localMedia.browse.storageRoot' => '端末のストレージ',
			'localMedia.browse.homeFolder' => 'ホームフォルダ',
			'localMedia.browse.filesystemRoot' => 'ルートディレクトリ',
			'localMedia.browse.folderUnreadable' => 'このフォルダーは読み取れません',
			'localMedia.browse.setCover' => 'サムネイルを設定',
			'localMedia.browse.setAsFolderCover' => 'フォルダーのサムネイルにする',
			'localMedia.browse.folderCoverSet' => 'フォルダーのサムネイルを更新しました',
			'localMedia.browse.setFolderCoverPick' => 'カバーに設定…',
			'localMedia.browse.restoreAutoCover' => '自動カバーに戻す',
			'localMedia.browse.autoCoverRestored' => '自動カバーに戻しました',
			'localMedia.browse.rescanFolder' => 'このフォルダを再スキャン',
			'localMedia.browse.coverPickerTitle' => 'フレームを選ぶ',
			'localMedia.browse.folderCoverPickerTitle' => 'カバーを選択',
			'localMedia.browse.coverPickerEmpty' => 'このフォルダにはまだ使える画像がありません。動画のサムネイルはバックグラウンドで生成中の可能性があります。',
			'localMedia.browse.coverSaved' => 'サムネイルを更新しました',
			'localMedia.browse.coverSaveFailed' => 'サムネイルを保存できませんでした',
			'localMedia.browse.coverUnavailable' => 'このファイルから映像を読み取れません',
			'localMedia.browse.deleted' => '削除しました',
			'localMedia.browse.deleteFailed' => '削除できませんでした。使用中か権限がない可能性があります',
			'localMedia.browse.openFolder' => '開く',
			'localMedia.browse.favorite' => 'お気に入りに追加',
			'localMedia.browse.unfavorite' => 'お気に入りから削除',
			'localMedia.browse.favorited' => 'お気に入りに追加しました',
			'localMedia.browse.unfavorited' => 'お気に入りから削除しました',
			'localMedia.browse.sortBy' => '並び替え',
			'localMedia.browse.sortAscending' => '昇順',
			'localMedia.browse.sortDescending' => '降順',
			'localMedia.browse.sortFieldName' => 'ファイル名',
			'localMedia.browse.sortFieldModified' => '更新日',
			'localMedia.browse.sortFieldDuration' => '再生時間',
			'localMedia.browse.sortFieldSize' => 'サイズ',
			'localMedia.browse.sortFieldResolution' => '解像度',
			'localMedia.browse.sortFieldFileType' => 'ファイル形式',
			'localMedia.browse.sortFieldFps' => 'フレームレート',
			'localMedia.browse.sortFieldFavorited' => 'お気に入り追加日',
			'localMedia.browse.emptyAllVideos' => '動画がまだ見つかりません。「フォルダ」から追加してください。',
			'localMedia.browse.emptyAllImages' => '画像がまだ見つかりません。「フォルダ」から追加してください。',
			'localMedia.browse.emptyFavorites' => 'お気に入りはまだありません。動画の「⋮」メニューから追加できます。',
			'localMedia.browse.emptyPinned' => 'よく使うフォルダはまだありません。「フォルダ」で長押しして「よく使う」に設定してください。',
			'localMedia.browse.emptyDownloadedVideos' => 'ダウンロード済みの動画はまだありません。',
			'localMedia.browse.emptyDownloadedGalleries' => 'ダウンロード済みのギャラリーはまだありません。',
			'localMedia.browse.folderInfo' => 'フォルダ情報',
			'localMedia.browse.folderInfoName' => '名前',
			'localMedia.browse.folderInfoPath' => 'パス',
			'localMedia.browse.folderInfoSource' => 'ソース',
			'localMedia.browse.folderInfoContents' => '内容',
			'localMedia.browse.folderInfoSize' => '使用容量',
			'localMedia.browse.folderInfoScannedAt' => '最終スキャン',
			'localMedia.browse.folderInfoNeverScanned' => 'まだスキャンしていません',
			'localMedia.browse.folderInfoNoPath' => 'このソースには開けるフォルダがありません',
			'localMedia.browse.copyPath' => 'パスをコピー',
			'localMedia.browse.pathCopied' => 'パスをコピーしました',
			'localMedia.tabFolders' => 'フォルダ',
			'localMedia.tabFavoriteVideos' => 'お気に入り',
			'localMedia.tabAllVideos' => 'すべての動画',
			'localMedia.tabAllImages' => 'すべての画像',
			'localMedia.tabDownloadedVideos' => 'ダウンロード済み動画',
			'localMedia.tabDownloadedGalleries' => 'ダウンロード済みギャラリー',
			'localMedia.title' => 'この端末のファイル',
			'localMedia.sourceOnline' => 'Iwara オンライン',
			'localMedia.manageSources' => 'ソースを管理',
			'localMedia.moveToCategory' => 'カテゴリへ移動',
			'localMedia.manageCategories' => 'カテゴリを管理',
			'localMedia.suggestedFolders' => '動画が見つかったフォルダー',
			'localMedia.sortRecentlyAdded' => '追加が新しい順',
			'localMedia.sortRecentlyPlayed' => '最近再生した順',
			'localMedia.sortName' => '名前',
			'localMedia.sortDuration' => '長さ',
			'localMedia.sortSize' => 'サイズ',
			'localMedia.sortFolder' => 'フォルダー',
			'localMedia.sortRecentlyModified' => '更新が新しい順',
			'localMedia.sortCount' => '枚数',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} 枚',
			'localMedia.downloadsSource' => 'ダウンロード済み',
			'localMedia.builtInSourceHint' => '「ダウンロード済み」は自動で管理されます',
			'localMedia.filterByCategory' => 'カテゴリで絞り込む',
			'localMedia.longPressToCategorize' => '長押しでカテゴリへ移動',
			'localMedia.uncategorized' => '未分類',
			'localMedia.setCategoryFailed' => 'カテゴリの設定に失敗しました',
			'localMedia.categoryUpdated' => 'カテゴリを更新しました',
			'localMedia.addFolder' => 'フォルダーを追加',
			'localMedia.addDeviceVideos' => '端末の動画をスキャン',
			'localMedia.mediaStoreSourceName' => '端末の動画',
			'localMedia.scanQueued' => 'スキャン待ち',
			'localMedia.itemInfo' => 'ファイル情報',
			'localMedia.revealInFolder' => 'フォルダーで表示',
			'localMedia.rescanAll' => 'すべて再スキャン',
			'localMedia.rescanAllStarted' => ({required Object count}) => '${count} 件のソースを再スキャンします',
			'localMedia.searchLibrary' => '検索',
			'localMedia.searchIncludeSubfolders' => 'サブフォルダーを含む',
			'localMedia.searchThisFolderOnly' => 'このフォルダーのみ',
			'localMedia.searchResultCount' => ({required Object count}) => '${count} 件',
			'localMedia.savedServers' => '保存済みの NAS',
			'localMedia.newServer' => '新しい NAS に接続',
			'localMedia.itemInfoLabels.size' => 'サイズ',
			'localMedia.itemInfoLabels.resolution' => '解像度',
			'localMedia.itemInfoLabels.duration' => '長さ',
			'localMedia.itemInfoLabels.modified' => '更新日時',
			'localMedia.itemInfoLabels.lastPlayed' => '最後に再生',
			'localMedia.itemInfoLabels.neverPlayed' => '未視聴',
			'localMedia.itemInfoLabels.completed' => '視聴済み',
			'localMedia.addSource' => 'ソースを追加',
			'localMedia.addSourceKinds' => 'フォルダー · NAS',
			'localMedia.openSettings' => '設定を開く',
			'localMedia.removeSourceLoses' => ({required Object items}) => '次の内容も一緒に消え、追加し直しても戻りません：${items}',
			'localMedia.loseProgress' => ({required Object count}) => '視聴進捗 ${count} 件',
			'localMedia.loseFavorites' => ({required Object count}) => 'おすすめ ${count} 件',
			'localMedia.losePinned' => ({required Object count}) => 'よく使うフォルダー ${count} 件',
			'localMedia.loseHidden' => ({required Object count}) => '非表示設定 ${count} 件',
			'localMedia.loseCovers' => ({required Object count}) => '手動で選んだカバー ${count} 枚',
			'localMedia.renameSource' => '名前を変更',
			'localMedia.renameSourceTitle' => 'ソース名を変更',
			'localMedia.renameSourceLabel' => '名前',
			'localMedia.renamed' => '名前を変更しました',
			'localMedia.nasAggregateHint' => 'NAS の内容は開いたことのあるフォルダーだけが対象です。開いていないフォルダーの動画や画像はここに表示されません。',
			'localMedia.rescanDone' => ({required Object name}) => '「${name}」を更新しました',
			'localMedia.unknownSourceHint' => 'このソースを使うにはアプリの更新が必要です',
			'localMedia.missing.title' => 'このファイルが見つかりません',
			'localMedia.missing.rescanFolder' => 'フォルダーを再スキャン',
			'localMedia.missing.relistNas' => 'このフォルダーを再読み込み',
			'localMedia.missing.removeFromList' => 'リストから削除',
			'localMedia.missing.removed' => 'リストから削除しました。ディスク上のファイルは変更していません',
			'localMedia.missing.found' => '見つかりました',
			'localMedia.missing.nasGone' => ({required Object name}) => 'NAS 上に「${name}」が見つかりません。削除・移動・名前変更された可能性があります。このフォルダーを再読み込みすると、現在の中身を確認できます。',
			'localMedia.webdav.addNas' => 'NAS に接続（WebDAV）',
			'localMedia.webdav.connectTitle' => 'NAS に接続',
			'localMedia.webdav.editTitle' => 'NAS に再ログイン',
			'localMedia.webdav.hint' => 'NAS の管理画面で WebDAV サービスを有効にしてから、アドレスとアカウントを入力してください。',
			'localMedia.webdav.address' => 'アドレス',
			'localMedia.webdav.addressHint' => '例：192.168.1.10:5005',
			'localMedia.webdav.username' => 'ユーザー名',
			'localMedia.webdav.password' => 'パスワード',
			'localMedia.webdav.displayName' => '名前（任意）',
			'localMedia.webdav.connect' => '接続',
			'localMedia.webdav.invalidAddress' => 'アドレスの形式が正しくありません',
			'localMedia.webdav.errorAuth' => 'ユーザー名またはパスワードが違います',
			'localMedia.webdav.errorUnreachable' => 'サーバーに接続できません。アドレスとポート、端末と NAS が同じネットワークにあるか確認してください',
			'localMedia.webdav.errorNotWebdav' => 'このアドレスは WebDAV サービスではありません',
			'localMedia.webdav.errorGeneric' => ({required Object code}) => '接続に失敗しました（${code}）',
			'localMedia.webdav.errorCredUnreadable' => '保存したパスワードを読み込めませんでした。しばらくしてから再試行してください',
			'localMedia.webdav.certTitle' => 'このサーバーを信頼しますか？',
			'localMedia.webdav.certBody' => 'サーバーの証明書はシステムに信頼されていません（NAS の自己署名証明書でよくあります）。下のフィンガープリントが NAS の管理画面の表示と一致するか確認してください：',
			'localMedia.webdav.certChangedBody' => 'このサーバーの証明書は前回信頼したものと異なります。NAS の証明書を変更していない場合、なりすましの可能性があります。続行しないでください。',
			'localMedia.webdav.trust' => '信頼する',
			'localMedia.webdav.pickRootTitle' => '追加するフォルダーを選択',
			'localMedia.webdav.serverRoot' => 'ルート',
			'localMedia.webdav.alreadyAdded' => 'この NAS フォルダーは追加済みです',
			'localMedia.webdav.relogin' => '再ログイン',
			'localMedia.webdav.stateAuthFailed' => '再ログインが必要',
			'localMedia.webdav.stateCertUntrusted' => 'サーバー証明書が変更されました',
			'localMedia.webdav.stateUnreachable' => 'NAS に接続できません',
			'localMedia.webdav.stateCredUnreadable' => 'パスワードを読み込めません',
			'localMedia.webdav.connected' => '接続済み',
			'localMedia.webdav.errorForbidden' => 'このアカウントには WebDAV のアクセス権がありません。NAS の WebDAV 設定で許可してください',
			'localMedia.webdav.errorTls' => '安全な接続に失敗しました。アドレスの http:// / https:// が NAS の設定と一致しているか確認してください',
			'localMedia.webdav.errorTryHttps' => 'NAS が HTTPS のみの場合は、アドレスの前に https:// を付けてください',
			'localMedia.webdav.previousStep' => '戻る',
			'localMedia.webdav.bannerUnreachable' => 'NAS に接続できません。前回の内容を表示しています',
			'localMedia.webdav.bannerAuthFailed' => 'ログインが切れました。再ログインすると最新の内容が見られます',
			'localMedia.webdav.bannerCertUntrusted' => 'NAS の証明書が変わりました。確認すると続行できます',
			'localMedia.webdav.bannerCredUnreadable' => '保存したパスワードを読み取れませんでした。再ログインしてください',
			'localMedia.mediaStoreUnavailable' => '端末のメディアインデックスは Android でのみ利用できます',
			'localMedia.mediaStorePermissionDenied' => '動画へのアクセスが許可されていません',
			'localMedia.rescan' => '再スキャン',
			'localMedia.scanning' => ({required Object count}) => 'スキャン中… ${count} 件見つかりました',
			'localMedia.scanFailed' => ({required Object reason}) => 'スキャンに失敗しました：${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'このフォルダーは非常に大きいため、最初の ${count} 件のみ取り込みました。',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'フォルダー「${name}」に既に含まれています',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '「${name}」は「${source}」の中にあるため、よく使うフォルダーに追加しました',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '「${name}」は既によく使うフォルダーにあります',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '「${name}」は既に追加されています',
			'localMedia.sourceContainsExisting' => ({required Object name}) => '追加済みのフォルダー「${name}」を含んでいるため、その親フォルダーはまだ追加できません',
			'localMedia.addSourceFailed' => 'フォルダーを追加できませんでした',
			'localMedia.fileMissing' => 'このファイルはディスク上にありません',
			'localMedia.permissionDenied' => 'ファイルアクセスが許可されていません。フォルダーを追加する前に許可してください',
			'localMedia.noVideosFound' => 'このフォルダーに動画はありません',
			'localMedia.emptyTitle' => 'フォルダーを追加するか NAS に接続して、手元の動画を見る',
			'localMedia.emptyPrivacyNote' => '端末内でのみ読み取ります。アップロードは一切ありません。',
			'localMedia.removeSourceTitle' => ({required Object name}) => '「${name}」を削除しますか？',
			'localMedia.removeSourceBody' => 'ファイル自体はそのままです。ライブラリーから外すだけです。',
			'localMedia.remove' => '削除',
			'localMedia.removeFolder' => 'ソースを削除',
			'localMedia.removeFolderSelectTitle' => '削除するソースを選択',
			'localMedia.longPressToRemove' => '長押しでこのフォルダーを削除',
			'localMedia.clearProgress' => 'ローカル視聴履歴を消去',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} 件',
			'localMedia.clearProgressEmpty' => 'ローカル視聴履歴はまだありません',
			'localMedia.clearProgressTitle' => 'ローカル視聴履歴を消去しますか？',
			'localMedia.clearProgressBody' => '再生位置と「視聴済み」の印だけを削除します。ファイルとフォルダーはそのままです。',
			'localMedia.clearProgressDone' => ({required Object count}) => 'ローカル視聴履歴を ${count} 件消去しました',
			'localMedia.clearAction' => '消去',
			'localMedia.iosManualRescanNotice' => 'iOSでは新しいファイルは自動検出されません。ファイルを追加または削除した後は、手動で再スキャンする必要があります。',
			'historyPage.removeFromHistory' => '履歴から削除',
			'historyPage.removed' => '履歴から削除しました',
			'historyPage.watchedTo' => ({required Object time}) => '${time} まで視聴',
			'historyPage.finished' => '視聴済み',
			'historyPage.clearTabTitle' => ({required Object tab}) => '「${tab}」を消去',
			'historyPage.clearTabConfirm' => ({required Object tab}) => '「${tab}」の履歴をすべて削除し、該当する動画の視聴位置も消去します。この操作は元に戻せません。',
			'historyPage.rangeByLastViewed' => '最終閲覧日時で絞り込み',
			'ai.title' => 'AI',
			'ai.providers' => 'プロバイダー',
			'ai.providersHint' => '1つ以上のAIプロバイダーを追加し、各機能で使用するプロバイダーを指定します。',
			'ai.addProvider' => 'プロバイダーを追加',
			'ai.noProviders' => 'プロバイダーがまだありません。追加するとAI翻訳・検索・署名機能が利用可能になります。',
			'ai.pickPreset' => 'プロバイダーを選択',
			'ai.providerNameLabel' => '名前',
			'ai.apiKey' => 'APIキー',
			'ai.baseUrl' => 'エンドポイント',
			'ai.model' => 'モデル',
			'ai.modelPick' => 'モデルを選択',
			'ai.modelEmpty' => 'モデルリストを取得できませんでした。直接モデル名を入力しても利用できます。',
			'ai.advanced' => '詳細設定',
			'ai.reasoning' => '推論モデル',
			'ai.streaming' => 'ストリーミング出力',
			'ai.structuredOutput' => '構造化出力',
			'ai.structuredOutputHint' => 'AI検索で必要です。多くの中継エンドポイントでは対応していないため、検索が失敗し続ける場合は無効にしてください。',
			'ai.temperature' => 'サンプリング温度',
			'ai.maxTokens' => '最大トークン数',
			'ai.maxTokensAuto' => '自動（モデル上限）',
			'ai.test' => 'テスト',
			'ai.testOk' => '接続成功',
			'ai.deleteProvider' => 'プロバイダーを削除',
			'ai.usedBy' => '使用先',
			'ai.taskBindings' => '機能の割り当て',
			'ai.taskBindingsHint' => '機能ごとに異なるプロバイダーを指定できます。',
			'ai.taskTranslate' => '翻訳',
			'ai.taskSearch' => 'AI検索',
			'ai.taskSignature' => '署名',
			'ai.taskAuto' => '自動',
			'ai.usage' => '使用状況',
			'ai.usageCalls' => '呼び出し回数',
			'ai.usageTokens' => 'トークン数',
			'ai.usageFailures' => '失敗',
			'ai.usageReset' => '統計をリセット',
			'ai.usageEmpty' => '呼び出し履歴はまだありません',
			'ai.openSettings' => 'AI設定を開く',
			'ai.notConfigured' => '未設定',
			'ai.searchTitle' => 'AI検索',
			'ai.searchHint' => '探したいものを文章で説明すると、AIが検索キーワードと絞り込み条件を入力します。',
			'ai.searchPlaceholder' => '例：再生回数1万回以上の最新MMD',
			'ai.searchApply' => 'この条件で検索',
			'ai.searchEmpty' => '検索条件を抽出できませんでした。別の表現で試してみてください。',
			'ai.searchFilters' => 'フィルター',
			'ai.searchSwitchSegment' => ({required Object segment}) => '「${segment}」に切り替え',
			'ai.searchGenerating' => '考え中…',
			'ai.searchRetrying' => '前回は失敗しました。再試行中…',
			'ai.searchRetryReason' => ({required Object reason}) => '原因：${reason}',
			'ai.searchStageWaiting' => 'リクエスト送信済み、応答待ち…',
			'ai.searchStageThinkingNext' => '次の手を考えています…',
			'ai.searchStageReasoning' => '推論中…',
			'ai.searchStageTool' => '検索を試しています…',
			'ai.searchStageDrafting' => ({required Object chars}) => '回答を作成中 · ${chars} 文字',
			'ai.searchStageParsing' => '結果を整理中…',
			'ai.searchThinking' => '思考の過程',
			'ai.searchKeywordNeedsQuotes' => 'このキーワードは引用符で囲まれていないため、iwara は細かく分解して緩く一致させます。この並び順だと1ページ目はほぼ無関係です。"引用符"で囲むか、関連度順にしてください。',
			'ai.searchToolProbing' => ({required Object query}) => '${query} で試し検索',
			'ai.searchToolFound' => ({required Object count, required Object titles}) => '${count} 件 · ${titles}',
			'ai.searchToolFailed' => ({required Object reason}) => '試し検索に失敗：${reason}',
			'ai.searchFiltersDropped' => ({required Object count}) => 'このセクションに無い絞り込みを ${count} 件削除しました。',
			_ => null,
		};
	}
}
