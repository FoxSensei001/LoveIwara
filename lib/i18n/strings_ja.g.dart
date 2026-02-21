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
class TranslationsJa with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

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
	@override late final _TranslationsNavigationOrderSettingsJa navigationOrderSettings = _TranslationsNavigationOrderSettingsJa._(_root);
	@override late final _TranslationsSearchFilterJa searchFilter = _TranslationsSearchFilterJa._(_root);
	@override late final _TranslationsFirstTimeSetupJa firstTimeSetup = _TranslationsFirstTimeSetupJa._(_root);
	@override late final _TranslationsProxyHelperJa proxyHelper = _TranslationsProxyHelperJa._(_root);
	@override late final _TranslationsTagSelectorJa tagSelector = _TranslationsTagSelectorJa._(_root);
	@override late final _TranslationsAnime4kJa anime4k = _TranslationsAnime4kJa._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileJa implements TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileJa._(this._root);

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
class _TranslationsTutorialJa implements TranslationsTutorialEn {
	_TranslationsTutorialJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => '特別フォロー機能';
	@override String get specialFollowDescription => 'ここには特別にフォローしている著者が表示されます。動画、ギャラリー、著者詳細ページでフォローボタンをクリックし、「特別フォローとして追加」を選択してください。';
	@override String get exampleAuthorInfoRow => '例：著者情報行';
	@override String get authorName => '著者名';
	@override String get followed => 'フォロー済み';
	@override String get specialFollowInstruction => '"フォロー済み"ボタンをクリック → "特別フォローとして追加"を選択';
	@override String get followButtonLocations => 'フォローボタンの場所：';
	@override String get videoDetailPage => '動画詳細ページ';
	@override String get galleryDetailPage => 'ギャラリー詳細ページ';
	@override String get authorDetailPage => '著者詳細ページ';
	@override String get afterSpecialFollow => '特別フォロー後、著者の最新コンテンツをすばやく確認できます！';
	@override String get specialFollowManagementTip => '特別フォローリストはサイドバードロワー - フォローリスト - 特別フォローリストページで管理できます';
	@override String get skip => 'スキップ';
}

// Path: common
class _TranslationsCommonJa implements TranslationsCommonEn {
	_TranslationsCommonJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get sort => '並び替え';
	@override String get appName => 'Love Iwara';
	@override String get ok => '確定';
	@override String get cancel => 'キャンセル';
	@override String get select => '選択';
	@override String get save => '保存';
	@override String get delete => '削除';
	@override String get visit => 'アクセス';
	@override String get loading => '読み込み中...';
	@override String get scrollToTop => 'トップに戻る';
	@override String get privacyHint => 'プライバシー内容、表示しません';
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
	@override String get specialFollowsManagementTip => 'ドラッグして並べ替え • 左スワイプで削除';
	@override String get specialFollowsManagement => '特別フォロー管理';
	@override String get createTimeDesc => '作成時間降順';
	@override String get createTimeAsc => '作成時間昇順';
	@override String get gallery => 'ギャラリー';
	@override String get playlist => 'プレイリスト';
	@override String get commentPostedSuccessfully => 'コメントが正常に投稿されました';
	@override String get commentPostedFailed => 'コメントの投稿に失敗しました';
	@override String get success => '成功';
	@override String get commentDeletedSuccessfully => 'コメントが削除されました';
	@override String get commentUpdatedSuccessfully => 'コメントが更新されました';
	@override String totalComments({required Object count}) => '${count} 件のコメント';
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
	@override String minutesAgo({required Object num}) => '${num} 分前';
	@override String hoursAgo({required Object num}) => '${num} 時間前';
	@override String daysAgo({required Object num}) => '${num} 日前';
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
	@override String get exitEditMode => '編集モードを終了';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '選択した ${num} 件のレコードを削除してもよろしいですか？';
	@override String get searchHistoryRecords => '検索履歴...';
	@override String get settings => '設定';
	@override String get subscriptions => 'サブスクリプション';
	@override String videoCount({required Object num}) => '${num} 本の動画';
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
	@override String get selectDateRange => '日付範囲を選択';
	@override String get selectDateRangeHint => '日付範囲を選択，デフォルトは最近30日';
	@override String get clearDateRange => '日付範囲をクリア';
	@override String get followSuccessClickAgainToSpecialFollow => 'フォローに成功しました。再度クリックして特別フォロー';
	@override String get exitConfirmTip => '本当に退出しますか？';
	@override String get error => 'エラー';
	@override String get taskRunning => '既にタスクが実行中です。しばらくお待ちください。';
	@override String get operationCancelled => '操作がキャンセルされました。';
	@override String get unsavedChanges => '未保存の変更があります';
	@override late final _TranslationsCommonPaginationJa pagination = _TranslationsCommonPaginationJa._(_root);
	@override String get detail => '詳細';
	@override String get parseExceptionDestopHint => ' - デスクトップユーザーは設定でプロキシを構成できます';
	@override String get iwaraTags => 'Iwara タグ';
	@override String get likeThisVideo => 'この動画が好きな人';
	@override String get operation => '操作';
	@override String get replies => '返信';
	@override String get externalLinkWarning => '外部リンク警告';
	@override String get externalLinkWarningMessage => 'iwara.tv 以外の外部リンクを開こうとしています。安全性に注意し、リンクが信頼できることを確認してから続行してください。';
	@override String get continueToExternalLink => '続行';
	@override String get cancelExternalLink => 'キャンセル';
}

// Path: auth
class _TranslationsAuthJa implements TranslationsAuthEn {
	_TranslationsAuthJa._(this._root);

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
	@override String get emailVerificationSent => 'メール認証が送信されました';
	@override String get notLoggedIn => 'ログインしていません';
	@override String get clickToLogin => 'こちらをクリックしてログイン';
	@override String get logoutConfirmation => '本当にログアウトしますか？';
	@override String get logoutSuccess => 'ログアウトに成功しました';
	@override String get logoutFailed => 'ログアウトに失敗しました';
	@override String get usernameOrEmail => 'ユーザー名またはメールアドレス';
	@override String get pleaseEnterUsernameOrEmail => 'ユーザー名またはメールアドレスを入力してください';
	@override String get rememberMe => 'ユーザー名とパスワードを記憶';
}

// Path: errors
class _TranslationsErrorsJa implements TranslationsErrorsEn {
	_TranslationsErrorsJa._(this._root);

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
class _TranslationsFriendsJa implements TranslationsFriendsEn {
	_TranslationsFriendsJa._(this._root);

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
class _TranslationsAuthorProfileJa implements TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'これ以上データはありません';
	@override String get userProfile => 'ユーザープロフィール';
}

// Path: favorites
class _TranslationsFavoritesJa implements TranslationsFavoritesEn {
	_TranslationsFavoritesJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'お気に入りを復元するにはクリックしてください';
	@override String get myFavorites => '私のお気に入り';
}

// Path: galleryDetail
class _TranslationsGalleryDetailJa implements TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get galleryDetail => 'ギャラリー詳細';
	@override String get viewGalleryDetail => 'ギャラリー詳細を表示';
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
	@override String get clickLeftAndRightEdgeToSwitchImage => '左端と右端をクリックして切り替え';
}

// Path: playList
class _TranslationsPlayListJa implements TranslationsPlayListEn {
	_TranslationsPlayListJa._(this._root);

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
class _TranslationsSearchJa implements TranslationsSearchEn {
	_TranslationsSearchJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => '検索範囲';
	@override String get searchTags => 'タグを検索...';
	@override String get contentRating => 'コンテンツレーティング';
	@override String get removeTag => 'タグを削除';
	@override String get pleaseEnterSearchContent => '検索内容を入力してください';
	@override String get searchHistory => '検索履歴';
	@override String get searchSuggestion => '検索提案';
	@override String get usedTimes => '使用回数';
	@override String get lastUsed => '最後の使用';
	@override String get noSearchHistoryRecords => '検索履歴がありません';
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
}

// Path: mediaList
class _TranslationsMediaListJa implements TranslationsMediaListEn {
	_TranslationsMediaListJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => '個人紹介';
}

// Path: settings
class _TranslationsSettingsJa implements TranslationsSettingsEn {
	_TranslationsSettingsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'リスト表示モード';
	@override String get previewEffect => 'プレビュー効果';
	@override String get useTraditionalPaginationMode => '従来のページネーションモードを使用';
	@override String get useTraditionalPaginationModeDesc => '従来のページネーションモードを使用すると、ページネーションモードが無効になります。ページを再レンダリングまたはアプリを再起動した後に有効になります';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => '底部プログレスバー';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'この設定は、ツールバーが非表示のときに底部プログレスバーを表示するかどうかを決定します。';
	@override String get basicSettings => '基本設定';
	@override String get personalizedSettings => '個性化設定';
	@override String get otherSettings => 'その他設定';
	@override String get searchConfig => '検索設定';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'この設定は、今後動画を再生する際に以前の設定を使用するかどうかを決定します。';
	@override String get playControl => '再生コントロール';
	@override String get fastForwardTime => '早送り時間';
	@override String get fastForwardTimeMustBeAPositiveInteger => '早送り時間は正の整数でなければなりません。';
	@override String get rewindTime => '巻き戻し時間';
	@override String get rewindTimeMustBeAPositiveInteger => '巻き戻し時間は正の整数でなければなりません。';
	@override String get longPressPlaybackSpeed => '長押し再生速度';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => '長押し再生速度は正の数でなければなりません。';
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
	@override String get minVersionUpdateRequired => '現在のバージョンが低すぎます。すぐに更新してください';
	@override String get forceUpdateTip => 'これは必須アップデートです。できるだけ早く最新バージョンにアップデートしてください';
	@override String get viewChangelog => '更新内容を表示';
	@override String get alreadyLatestVersion => 'すでに最新バージョンです';
	@override String get appSettings => 'アプリ設定';
	@override String get configureYourAppSettings => 'アプリ設定を設定';
	@override String get history => '履歴';
	@override String get autoRecordHistory => '自動記録履歴';
	@override String get autoRecordHistoryDesc => '視聴した動画やギャラリーなどの情報を自動的に記録します';
	@override String get showUnprocessedMarkdownText => '未処理のMarkdownテキストを表示';
	@override String get showUnprocessedMarkdownTextDesc => 'Markdownの元のテキストを表示';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'プライバシーモード';
	@override String get activeBackgroundPrivacyModeDesc => 'スクリーンショットを禁止し、バックグラウンド実行時に画面を隠す...';
	@override String get privacy => 'プライバシー';
	@override String get forum => 'フォーラム';
	@override String get disableForumReplyQuote => 'フォーラム返信引用を無効にする';
	@override String get disableForumReplyQuoteDesc => 'フォーラム返信時の返信階層情報の携帯を無効にする';
	@override String get theaterMode => '劇院モード';
	@override String get theaterModeDesc => '開啟後、プレーヤー背景がビデオカバーのぼかしバージョンに設定されます';
	@override String get appLinks => 'アプリリンク';
	@override String get defaultBrowser => 'デフォルトブラウザ';
	@override String get defaultBrowserDesc => 'システム設定でデフォルトリンク設定項目を開き、iwara.tvサイトリンクを追加してください';
	@override String get themeMode => 'テーマモード';
	@override String get themeModeDesc => 'この設定はアプリのテーマモードを決定します';
	@override String get dynamicColor => 'ダイナミックカラー';
	@override String get dynamicColorDesc => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
	@override String get useDynamicColor => 'ダイナミックカラーを使用';
	@override String get useDynamicColorDesc => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
	@override String get presetColors => 'プリセットカラー';
	@override String get customColors => 'カスタムカラー';
	@override String get pickColor => 'カラーを選択';
	@override String get cancel => 'キャンセル';
	@override String get confirm => '確認';
	@override String get noCustomColors => 'カスタムカラーがありません';
	@override String get recordAndRestorePlaybackProgress => '再生進度を記録して復元';
	@override String get signature => '小尾巴';
	@override String get enableSignature => '小尾巴を有効にする';
	@override String get enableSignatureDesc => 'この設定はアプリが回覆時に小尾巴を有効にするかどうかを決定します';
	@override String get enterSignature => '小尾巴を入力';
	@override String get editSignature => '小尾巴を編集';
	@override String get signatureContent => '小尾巴の内容';
	@override String get exportConfig => 'アプリ設定をエクスポート';
	@override String get exportConfigDesc => 'ダウンロード記録を除いたアプリ設定をファイルにエクスポートします';
	@override String get importConfig => 'アプリ設定をインポート';
	@override String get importConfigDesc => 'ファイルからアプリ設定をインポートします';
	@override String get exportConfigSuccess => '設定が正常にエクスポートされました';
	@override String get exportConfigFailed => '設定のエクスポートに失敗しました';
	@override String get importConfigSuccess => '設定が正常にインポートされました';
	@override String get importConfigFailed => '設定のインポートに失敗しました';
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
	@override String get lockButtonPosition => 'ロックボタンの位置';
	@override String get lockButtonPositionBothSides => '両側に表示';
	@override String get lockButtonPositionLeftSide => '左側のみ表示';
	@override String get lockButtonPositionRightSide => '右側のみ表示';
	@override String get fullscreenOrientation => 'フルスクリーン時のデフォルト画面方向';
	@override String get fullscreenOrientationDesc => 'この設定は、フルスクリーン時のデフォルト画面方向を決定します（モバイルのみ）';
	@override String get fullscreenOrientationLeftLandscape => '左横画面';
	@override String get fullscreenOrientationRightLandscape => '右横画面';
	@override String get jumpLink => 'リンクをジャンプ';
	@override String get language => '言語';
	@override String get languageChanged => '言語設定が変更されました。アプリを再起動して有効にしてください。';
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

// Path: oreno3d
class _TranslationsOreno3dJa implements TranslationsOreno3dEn {
	_TranslationsOreno3dJa._(this._root);

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
class _TranslationsSignInJa implements TranslationsSignInEn {
	_TranslationsSignInJa._(this._root);

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
class _TranslationsSubscriptionsJa implements TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'サブスクリプションを表示するにはログインしてください。';
	@override String get selectUser => 'ユーザーを選択してください';
	@override String get noSubscribedUsers => '購読中のユーザーがいません';
	@override String get showAllSubscribedUsersContent => 'すべての購読中のユーザーのコンテンツを表示';
}

// Path: videoDetail
class _TranslationsVideoDetailJa implements TranslationsVideoDetailEn {
	_TranslationsVideoDetailJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'ピプモード';
	@override String resumeFromLastPosition({required Object position}) => '${position} から続けて再生';
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
class _TranslationsShareJa implements TranslationsShareEn {
	_TranslationsShareJa._(this._root);

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
class _TranslationsMarkdownJa implements TranslationsMarkdownEn {
	_TranslationsMarkdownJa._(this._root);

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
class _TranslationsForumJa implements TranslationsForumEn {
	_TranslationsForumJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
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
	@override String get editedAt => '編集日時';
	@override String get copySuccess => 'クリップボードにコピーされました';
	@override String copySuccessForMessage({required Object str}) => 'クリップボードにコピーされました: ${str}';
	@override String get editReply => '編集回覆';
	@override String get editTitle => '編集タイトル';
	@override String get submit => '提出';
}

// Path: notifications
class _TranslationsNotificationsJa implements TranslationsNotificationsEn {
	_TranslationsNotificationsJa._(this._root);

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
class _TranslationsConversationJa implements TranslationsConversationEn {
	_TranslationsConversationJa._(this._root);

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
	@override String get sendMessage => 'メッセージを送信';
}

// Path: splash
class _TranslationsSplashJa implements TranslationsSplashEn {
	_TranslationsSplashJa._(this._root);

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
class _TranslationsDownloadJa implements TranslationsDownloadEn {
	_TranslationsDownloadJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsJa errors = _TranslationsDownloadErrorsJa._(_root);
	@override String get downloadList => 'ダウンロードリスト';
	@override String get viewDownloadList => 'ダウンロードリストを表示';
	@override String get download => 'ダウンロード';
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
	@override String get video => '動画';
	@override String get gallery => 'ギャラリー';
	@override String get other => 'その他';
	@override String get clearFilters => 'フィルターをクリア';
	@override String get stillInDevelopment => '開発中';
	@override String get saveToAppDirectory => 'アプリケーションディレクトリに保存';
	@override String get alreadyDownloadedWithQuality => 'すでに同じ品質のタスクがあります。続けてダウンロードしますか？';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'すでに品質が${qualities}のタスクがあります。続けてダウンロードしますか？';
	@override String get otherQualities => 'その他の品質';
	@override late final _TranslationsDownloadBatchDownloadJa batchDownload = _TranslationsDownloadBatchDownloadJa._(_root);
}

// Path: favorite
class _TranslationsFavoriteJa implements TranslationsFavoriteEn {
	_TranslationsFavoriteJa._(this._root);

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
}

// Path: translation
class _TranslationsTranslationJa implements TranslationsTranslationEn {
	_TranslationsTranslationJa._(this._root);

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
}

// Path: mediaPlayer
class _TranslationsMediaPlayerJa implements TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerJa._(this._root);

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
}

// Path: diagnostics
class _TranslationsDiagnosticsJa implements TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => '診断情報';
	@override String get appVersionLabel => 'アプリバージョン';
	@override String memoryUsage({required Object memMB}) => 'メモリ使用量: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'デバイス情報を取得できません';
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
class _TranslationsLogViewerJa implements TranslationsLogViewerEn {
	_TranslationsLogViewerJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ログビューア';
	@override String get searchHint => 'ログを検索...';
	@override String get emptyState => 'ログはありません';
	@override String get copiedToClipboard => 'クリップボードにコピーしました';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogJa implements TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogJa._(this._root);

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
class _TranslationsLinkInputDialogJa implements TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogJa._(this._root);

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
class _TranslationsLogJa implements TranslationsLogEn {
	_TranslationsLogJa._(this._root);

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
class _TranslationsEmojiJa implements TranslationsEmojiEn {
	_TranslationsEmojiJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
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
class _TranslationsDisplaySettingsJa implements TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsJa._(this._root);

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
class _TranslationsLayoutSettingsJa implements TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsJa._(this._root);

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

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsJa implements TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsJa._(this._root);

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
	@override String get videoDescription => '人気の動画コンテンツを閲覧';
	@override String get galleryDescription => '画像とギャラリーを閲覧';
	@override String get subscriptionDescription => 'フォローしているユーザーの最新コンテンツを表示';
	@override String get forumDescription => 'コミュニティディスカッションに参加';
}

// Path: searchFilter
class _TranslationsSearchFilterJa implements TranslationsSearchFilterEn {
	_TranslationsSearchFilterJa._(this._root);

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
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupJa implements TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeJa welcome = _TranslationsFirstTimeSetupWelcomeJa._(_root);
	@override late final _TranslationsFirstTimeSetupBasicJa basic = _TranslationsFirstTimeSetupBasicJa._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkJa network = _TranslationsFirstTimeSetupNetworkJa._(_root);
	@override late final _TranslationsFirstTimeSetupThemeJa theme = _TranslationsFirstTimeSetupThemeJa._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerJa player = _TranslationsFirstTimeSetupPlayerJa._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionJa completion = _TranslationsFirstTimeSetupCompletionJa._(_root);
	@override late final _TranslationsFirstTimeSetupCommonJa common = _TranslationsFirstTimeSetupCommonJa._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperJa implements TranslationsProxyHelperEn {
	_TranslationsProxyHelperJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'システムプロキシを検出';
	@override String get copied => 'コピーしました';
	@override String get copy => 'コピー';
}

// Path: tagSelector
class _TranslationsTagSelectorJa implements TranslationsTagSelectorEn {
	_TranslationsTagSelectorJa._(this._root);

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
class _TranslationsAnime4kJa implements TranslationsAnime4kEn {
	_TranslationsAnime4kJa._(this._root);

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
}

// Path: common.pagination
class _TranslationsCommonPaginationJa implements TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationJa._(this._root);

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
class _TranslationsErrorsNetworkJa implements TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkJa._(this._root);

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

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsJa implements TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'フォーラム';
	@override String get configureYourForumSettings => 'フォーラム設定を構成する';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsJa implements TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'チャット';
	@override String get configureYourChatSettings => 'チャット設定を構成する';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsJa implements TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'ダウンロード設定';
	@override String get storagePermissionStatus => 'ストレージ権限状態';
	@override String get accessPublicDirectoryNeedStoragePermission => 'パブリックディレクトリにアクセスするにはストレージ権限が必要です';
	@override String get checkingPermissionStatus => '権限状態を確認中...';
	@override String get storagePermissionGranted => 'ストレージ権限が付与されました';
	@override String get storagePermissionNotGranted => 'ストレージ権限が付与されていません';
	@override String get storagePermissionGrantSuccess => 'ストレージ権限が付与されました';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'ストレージ権限が付与されませんでしたが、一部の機能が制限される可能性があります';
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
	@override String get recommendedPathSet => '推奨パスに設定されました';
	@override String get setRecommendedPathFailed => '推奨パスの設定に失敗しました';
	@override String get templateResetToDefault => 'デフォルトテンプレートにリセットされました';
	@override String get functionalTest => '機能テスト';
	@override String get testInProgress => 'テスト中...';
	@override String get runTest => 'テスト実行';
	@override String get testDownloadPathAndPermissions => 'ダウンロードパスと権限設定が正常に動作するかテストします';
	@override String get testResults => 'テスト結果';
	@override String get testCompleted => 'テスト完了';
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
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesJa implements TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get hot => '急上昇';
	@override String get favorites => '高評価';
	@override String get latest => '新着';
	@override String get popularity => '人気';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsJa implements TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsJa._(this._root);

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
class _TranslationsOreno3dLoadingJa implements TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => '動画情報を取得中...';
	@override String get cancel => 'キャンセル';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesJa implements TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => '動画が見つからないか削除されました';
	@override String get unableToGetVideoPlayLink => '動画再生リンクを取得できません';
	@override String get getVideoDetailFailed => '動画詳細の取得に失敗しました';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoJa implements TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoJa._(this._root);

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

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerJa implements TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'ビデオソースの読み込み中にエラーが発生しました';
	@override String get errorWhileSettingUpListeners => '監視器の設定中にエラーが発生しました';
	@override String get serverFaultDetectedAutoSwitched => 'サーバー障害を検出しました。自動的にルートを切り替えて再試行しています';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonJa implements TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonJa._(this._root);

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
class _TranslationsVideoDetailCastJa implements TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastJa._(this._root);

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
class _TranslationsVideoDetailLikeAvatarsJa implements TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsJa._(this._root);

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
class _TranslationsForumSitewideJa implements TranslationsForumSitewideEn {
	_TranslationsForumSitewideJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get badge => '全体';
	@override String get title => '全体お知らせ';
	@override String get readMore => '全文表示';
}

// Path: forum.errors
class _TranslationsForumErrorsJa implements TranslationsForumErrorsEn {
	_TranslationsForumErrorsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'カテゴリを選択してください';
	@override String get threadLocked => 'このスレッドはロックされています。';
}

// Path: forum.groups
class _TranslationsForumGroupsJa implements TranslationsForumGroupsEn {
	_TranslationsForumGroupsJa._(this._root);

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
class _TranslationsForumLeafNamesJa implements TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesJa._(this._root);

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
class _TranslationsForumLeafDescriptionsJa implements TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsJa._(this._root);

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
class _TranslationsNotificationsErrorsJa implements TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'サポートされていない通知タイプ';
	@override String get unknownUser => '未知ユーザー';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'サポートされていない通知タイプ: ${type}';
	@override String get unknownNotificationType => '未知通知タイプ';
}

// Path: conversation.errors
class _TranslationsConversationErrorsJa implements TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsJa._(this._root);

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
class _TranslationsSplashErrorsJa implements TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => '初期化に失敗しました。アプリを再起動してください';
}

// Path: download.errors
class _TranslationsDownloadErrorsJa implements TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => '画像モデルが見つかりません';
	@override String get downloadFailed => 'ダウンロードに失敗しました';
	@override String get videoInfoNotFound => 'ビデオ情報が見つかりません';
	@override String get unknown => '不明';
	@override String get downloadTaskAlreadyExists => 'ダウンロードタスクが既に存在します';
	@override String get videoAlreadyDownloaded => 'ビデオはすでにダウンロードされています';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'ダウンロードタスクの追加に失敗しました: ${errorInfo}';
	@override String get userPausedDownload => 'ユーザーがダウンロードを一時停止';
	@override String fileSystemError({required Object errorInfo}) => 'ファイルシステムエラー: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => '不明なエラー: ${errorInfo}';
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
	@override String get taskAlreadyProcessing => 'タスクはすでに処理中です';
	@override String get failedToLoadTasks => 'タスクの読み込みに失敗しました';
	@override String partialDownloadFailedWithMessage({required Object message}) => '部分ダウンロードに失敗しました: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'サポートされていない画像形式: ${extension}, デバイスにダウンロードして表示することができます';
	@override String get imageLoadFailed => '画像の読み込みに失敗しました';
	@override String get pleaseTryOtherViewer => '他のビューアーを使用してみてください';
}

// Path: download.batchDownload
class _TranslationsDownloadBatchDownloadJa implements TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadJa._(this._root);

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
class _TranslationsFavoriteErrorsJa implements TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get addFailed => '追加に失敗しました';
	@override String get addSuccess => '追加に成功しました';
	@override String get deleteFolderFailed => 'フォルダーの削除に失敗しました';
	@override String get deleteFolderSuccess => 'フォルダーの削除に成功しました';
	@override String get folderNameCannotBeEmpty => 'フォルダー名を入力してください';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertJa implements TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertJa._(this._root);

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
class _TranslationsDiagnosticsToastJa implements TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'ログサービスが初期化されていません';
	@override String get exportSuccess => 'ログをエクスポートしました。プライバシーを確認後、メールで送信してください';
	@override String exportFailed({required Object error}) => 'エクスポート失敗: ${error}';
	@override String get supportEmailCopied => 'メールアドレスをコピーしました。メールクライアントに貼り付けてログを添付してください';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesJa implements TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get relevance => '関連性';
	@override String get latest => '最新';
	@override String get views => '視聴回数';
	@override String get likes => 'いいね数';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeJa implements TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ようこそ';
	@override String get subtitle => 'パーソナライズ設定を始めましょう';
	@override String get description => '数ステップで最適な体験を提供します';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicJa implements TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '基本設定';
	@override String get subtitle => '体験をパーソナライズ';
	@override String get description => 'ご希望の機能設定を選択';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkJa implements TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ネットワーク設定';
	@override String get subtitle => 'ネットワークオプションを構成';
	@override String get description => 'ネットワーク環境に合わせて調整';
	@override String get tip => '設定後、再起動が必要です';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeJa implements TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'テーマ設定';
	@override String get subtitle => 'お好みの見た目を選択';
	@override String get description => 'ビジュアル体験をパーソナライズ';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerJa implements TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'プレーヤー設定';
	@override String get subtitle => '再生コントロールを構成';
	@override String get description => 'よく使う再生設定を素早く設定';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionJa implements TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionJa._(this._root);

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
class _TranslationsFirstTimeSetupCommonJa implements TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'これらの設定はいつでも設定画面で変更できます';
	@override String get agreeAgreementSnackbar => 'まず利用規約とコミュニティルールに同意してください';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsJa implements TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get highQuality => '高品質';
	@override String get fast => '高速';
	@override String get lite => '軽量';
	@override String get moreLite => 'より軽量';
	@override String get custom => 'カスタム';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsJa implements TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsJa._(this._root);

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
class _TranslationsAnime4kPresetNamesJa implements TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesJa._(this._root);

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

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesJa implements TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesJa._(this._root);

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
class _TranslationsVideoDetailCastDlnaCastSheetJa implements TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetJa._(this._root);

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
			'tutorial.specialFollowFeature' => '特別フォロー機能',
			'tutorial.specialFollowDescription' => 'ここには特別にフォローしている著者が表示されます。動画、ギャラリー、著者詳細ページでフォローボタンをクリックし、「特別フォローとして追加」を選択してください。',
			'tutorial.exampleAuthorInfoRow' => '例：著者情報行',
			'tutorial.authorName' => '著者名',
			'tutorial.followed' => 'フォロー済み',
			'tutorial.specialFollowInstruction' => '"フォロー済み"ボタンをクリック → "特別フォローとして追加"を選択',
			'tutorial.followButtonLocations' => 'フォローボタンの場所：',
			'tutorial.videoDetailPage' => '動画詳細ページ',
			'tutorial.galleryDetailPage' => 'ギャラリー詳細ページ',
			'tutorial.authorDetailPage' => '著者詳細ページ',
			'tutorial.afterSpecialFollow' => '特別フォロー後、著者の最新コンテンツをすばやく確認できます！',
			'tutorial.specialFollowManagementTip' => '特別フォローリストはサイドバードロワー - フォローリスト - 特別フォローリストページで管理できます',
			'tutorial.skip' => 'スキップ',
			'common.sort' => '並び替え',
			'common.appName' => 'Love Iwara',
			'common.ok' => '確定',
			'common.cancel' => 'キャンセル',
			'common.select' => '選択',
			'common.save' => '保存',
			'common.delete' => '削除',
			'common.visit' => 'アクセス',
			'common.loading' => '読み込み中...',
			'common.scrollToTop' => 'トップに戻る',
			'common.privacyHint' => 'プライバシー内容、表示しません',
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
			'common.specialFollowsManagementTip' => 'ドラッグして並べ替え • 左スワイプで削除',
			'common.specialFollowsManagement' => '特別フォロー管理',
			'common.createTimeDesc' => '作成時間降順',
			'common.createTimeAsc' => '作成時間昇順',
			'common.gallery' => 'ギャラリー',
			'common.playlist' => 'プレイリスト',
			'common.commentPostedSuccessfully' => 'コメントが正常に投稿されました',
			'common.commentPostedFailed' => 'コメントの投稿に失敗しました',
			'common.success' => '成功',
			'common.commentDeletedSuccessfully' => 'コメントが削除されました',
			'common.commentUpdatedSuccessfully' => 'コメントが更新されました',
			'common.totalComments' => ({required Object count}) => '${count} 件のコメント',
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
			'common.minutesAgo' => ({required Object num}) => '${num} 分前',
			'common.hoursAgo' => ({required Object num}) => '${num} 時間前',
			'common.daysAgo' => ({required Object num}) => '${num} 日前',
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
			'common.exitEditMode' => '編集モードを終了',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '選択した ${num} 件のレコードを削除してもよろしいですか？',
			'common.searchHistoryRecords' => '検索履歴...',
			'common.settings' => '設定',
			'common.subscriptions' => 'サブスクリプション',
			'common.videoCount' => ({required Object num}) => '${num} 本の動画',
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
			'common.selectDateRange' => '日付範囲を選択',
			'common.selectDateRangeHint' => '日付範囲を選択，デフォルトは最近30日',
			'common.clearDateRange' => '日付範囲をクリア',
			'common.followSuccessClickAgainToSpecialFollow' => 'フォローに成功しました。再度クリックして特別フォロー',
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
			'common.likeThisVideo' => 'この動画が好きな人',
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
			'auth.emailVerificationSent' => 'メール認証が送信されました',
			'auth.notLoggedIn' => 'ログインしていません',
			'auth.clickToLogin' => 'こちらをクリックしてログイン',
			'auth.logoutConfirmation' => '本当にログアウトしますか？',
			'auth.logoutSuccess' => 'ログアウトに成功しました',
			'auth.logoutFailed' => 'ログアウトに失敗しました',
			'auth.usernameOrEmail' => 'ユーザー名またはメールアドレス',
			'auth.pleaseEnterUsernameOrEmail' => 'ユーザー名またはメールアドレスを入力してください',
			'auth.rememberMe' => 'ユーザー名とパスワードを記憶',
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
			'galleryDetail.galleryDetail' => 'ギャラリー詳細',
			'galleryDetail.viewGalleryDetail' => 'ギャラリー詳細を表示',
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
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => '左端と右端をクリックして切り替え',
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
			'search.searchHistory' => '検索履歴',
			'search.searchSuggestion' => '検索提案',
			'search.usedTimes' => '使用回数',
			'search.lastUsed' => '最後の使用',
			'search.noSearchHistoryRecords' => '検索履歴がありません',
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
			'mediaList.personalIntroduction' => '個人紹介',
			'settings.listViewMode' => 'リスト表示モード',
			'settings.previewEffect' => 'プレビュー効果',
			'settings.useTraditionalPaginationMode' => '従来のページネーションモードを使用',
			'settings.useTraditionalPaginationModeDesc' => '従来のページネーションモードを使用すると、ページネーションモードが無効になります。ページを再レンダリングまたはアプリを再起動した後に有効になります',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => '底部プログレスバー',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'この設定は、ツールバーが非表示のときに底部プログレスバーを表示するかどうかを決定します。',
			'settings.basicSettings' => '基本設定',
			'settings.personalizedSettings' => '個性化設定',
			'settings.otherSettings' => 'その他設定',
			'settings.searchConfig' => '検索設定',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'この設定は、今後動画を再生する際に以前の設定を使用するかどうかを決定します。',
			'settings.playControl' => '再生コントロール',
			'settings.fastForwardTime' => '早送り時間',
			'settings.fastForwardTimeMustBeAPositiveInteger' => '早送り時間は正の整数でなければなりません。',
			'settings.rewindTime' => '巻き戻し時間',
			'settings.rewindTimeMustBeAPositiveInteger' => '巻き戻し時間は正の整数でなければなりません。',
			'settings.longPressPlaybackSpeed' => '長押し再生速度',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => '長押し再生速度は正の数でなければなりません。',
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
			'settings.minVersionUpdateRequired' => '現在のバージョンが低すぎます。すぐに更新してください',
			'settings.forceUpdateTip' => 'これは必須アップデートです。できるだけ早く最新バージョンにアップデートしてください',
			_ => null,
		} ?? switch (path) {
			'settings.viewChangelog' => '更新内容を表示',
			'settings.alreadyLatestVersion' => 'すでに最新バージョンです',
			'settings.appSettings' => 'アプリ設定',
			'settings.configureYourAppSettings' => 'アプリ設定を設定',
			'settings.history' => '履歴',
			'settings.autoRecordHistory' => '自動記録履歴',
			'settings.autoRecordHistoryDesc' => '視聴した動画やギャラリーなどの情報を自動的に記録します',
			'settings.showUnprocessedMarkdownText' => '未処理のMarkdownテキストを表示',
			'settings.showUnprocessedMarkdownTextDesc' => 'Markdownの元のテキストを表示',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'プライバシーモード',
			'settings.activeBackgroundPrivacyModeDesc' => 'スクリーンショットを禁止し、バックグラウンド実行時に画面を隠す...',
			'settings.privacy' => 'プライバシー',
			'settings.forum' => 'フォーラム',
			'settings.disableForumReplyQuote' => 'フォーラム返信引用を無効にする',
			'settings.disableForumReplyQuoteDesc' => 'フォーラム返信時の返信階層情報の携帯を無効にする',
			'settings.theaterMode' => '劇院モード',
			'settings.theaterModeDesc' => '開啟後、プレーヤー背景がビデオカバーのぼかしバージョンに設定されます',
			'settings.appLinks' => 'アプリリンク',
			'settings.defaultBrowser' => 'デフォルトブラウザ',
			'settings.defaultBrowserDesc' => 'システム設定でデフォルトリンク設定項目を開き、iwara.tvサイトリンクを追加してください',
			'settings.themeMode' => 'テーマモード',
			'settings.themeModeDesc' => 'この設定はアプリのテーマモードを決定します',
			'settings.dynamicColor' => 'ダイナミックカラー',
			'settings.dynamicColorDesc' => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します',
			'settings.useDynamicColor' => 'ダイナミックカラーを使用',
			'settings.useDynamicColorDesc' => 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します',
			'settings.presetColors' => 'プリセットカラー',
			'settings.customColors' => 'カスタムカラー',
			'settings.pickColor' => 'カラーを選択',
			'settings.cancel' => 'キャンセル',
			'settings.confirm' => '確認',
			'settings.noCustomColors' => 'カスタムカラーがありません',
			'settings.recordAndRestorePlaybackProgress' => '再生進度を記録して復元',
			'settings.signature' => '小尾巴',
			'settings.enableSignature' => '小尾巴を有効にする',
			'settings.enableSignatureDesc' => 'この設定はアプリが回覆時に小尾巴を有効にするかどうかを決定します',
			'settings.enterSignature' => '小尾巴を入力',
			'settings.editSignature' => '小尾巴を編集',
			'settings.signatureContent' => '小尾巴の内容',
			'settings.exportConfig' => 'アプリ設定をエクスポート',
			'settings.exportConfigDesc' => 'ダウンロード記録を除いたアプリ設定をファイルにエクスポートします',
			'settings.importConfig' => 'アプリ設定をインポート',
			'settings.importConfigDesc' => 'ファイルからアプリ設定をインポートします',
			'settings.exportConfigSuccess' => '設定が正常にエクスポートされました',
			'settings.exportConfigFailed' => '設定のエクスポートに失敗しました',
			'settings.importConfigSuccess' => '設定が正常にインポートされました',
			'settings.importConfigFailed' => '設定のインポートに失敗しました',
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
			'settings.lockButtonPosition' => 'ロックボタンの位置',
			'settings.lockButtonPositionBothSides' => '両側に表示',
			'settings.lockButtonPositionLeftSide' => '左側のみ表示',
			'settings.lockButtonPositionRightSide' => '右側のみ表示',
			'settings.fullscreenOrientation' => 'フルスクリーン時のデフォルト画面方向',
			'settings.fullscreenOrientationDesc' => 'この設定は、フルスクリーン時のデフォルト画面方向を決定します（モバイルのみ）',
			'settings.fullscreenOrientationLeftLandscape' => '左横画面',
			'settings.fullscreenOrientationRightLandscape' => '右横画面',
			'settings.jumpLink' => 'リンクをジャンプ',
			'settings.language' => '言語',
			'settings.languageChanged' => '言語設定が変更されました。アプリを再起動して有効にしてください。',
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
			'settings.cdnNoServerDataHint' => 'サーバーデータがありません、更新ボタンをクリックしてください',
			'settings.cdnTestingStatus' => 'テスト中',
			'settings.cdnUnreachableStatus' => '到達不可',
			'settings.cdnNotTestedStatus' => '未テスト',
			'settings.downloadSettings.downloadSettings' => 'ダウンロード設定',
			'settings.downloadSettings.storagePermissionStatus' => 'ストレージ権限状態',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'パブリックディレクトリにアクセスするにはストレージ権限が必要です',
			'settings.downloadSettings.checkingPermissionStatus' => '権限状態を確認中...',
			'settings.downloadSettings.storagePermissionGranted' => 'ストレージ権限が付与されました',
			'settings.downloadSettings.storagePermissionNotGranted' => 'ストレージ権限が付与されていません',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'ストレージ権限が付与されました',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'ストレージ権限が付与されませんでしたが、一部の機能が制限される可能性があります',
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
			'settings.downloadSettings.recommendedPathSet' => '推奨パスに設定されました',
			'settings.downloadSettings.setRecommendedPathFailed' => '推奨パスの設定に失敗しました',
			'settings.downloadSettings.templateResetToDefault' => 'デフォルトテンプレートにリセットされました',
			'settings.downloadSettings.functionalTest' => '機能テスト',
			'settings.downloadSettings.testInProgress' => 'テスト中...',
			'settings.downloadSettings.runTest' => 'テスト実行',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'ダウンロードパスと権限設定が正常に動作するかテストします',
			'settings.downloadSettings.testResults' => 'テスト結果',
			'settings.downloadSettings.testCompleted' => 'テスト完了',
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
			_ => null,
		} ?? switch (path) {
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
			'download.errors.videoAlreadyDownloaded' => 'ビデオはすでにダウンロードされています',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'ダウンロードタスクの追加に失敗しました: ${errorInfo}',
			'download.errors.userPausedDownload' => 'ユーザーがダウンロードを一時停止',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'ファイルシステムエラー: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => '不明なエラー: ${errorInfo}',
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
			'download.errors.taskAlreadyProcessing' => 'タスクはすでに処理中です',
			'download.errors.failedToLoadTasks' => 'タスクの読み込みに失敗しました',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => '部分ダウンロードに失敗しました: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'サポートされていない画像形式: ${extension}, デバイスにダウンロードして表示することができます',
			'download.errors.imageLoadFailed' => '画像の読み込みに失敗しました',
			'download.errors.pleaseTryOtherViewer' => '他のビューアーを使用してみてください',
			'download.downloadList' => 'ダウンロードリスト',
			'download.viewDownloadList' => 'ダウンロードリストを表示',
			'download.download' => 'ダウンロード',
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
			'download.video' => '動画',
			'download.gallery' => 'ギャラリー',
			'download.other' => 'その他',
			'download.clearFilters' => 'フィルターをクリア',
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
			'diagnostics.infoSectionTitle' => '診断情報',
			'diagnostics.appVersionLabel' => 'アプリバージョン',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'メモリ使用量: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'デバイス情報を取得できません',
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
			_ => null,
		} ?? switch (path) {
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
			'navigationOrderSettings.videoDescription' => '人気の動画コンテンツを閲覧',
			'navigationOrderSettings.galleryDescription' => '画像とギャラリーを閲覧',
			'navigationOrderSettings.subscriptionDescription' => 'フォローしているユーザーの最新コンテンツを表示',
			'navigationOrderSettings.forumDescription' => 'コミュニティディスカッションに参加',
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
			'firstTimeSetup.completion.title' => '設定完了',
			'firstTimeSetup.completion.subtitle' => 'すぐに始められます',
			'firstTimeSetup.completion.description' => '関連規約をお読みの上ご同意ください',
			'firstTimeSetup.completion.agreementTitle' => '利用規約とコミュニティルール',
			'firstTimeSetup.completion.agreementDesc' => '本アプリをご利用になる前に、利用規約とコミュニティルールをよくお読みいただき、同意してください。良好な利用環境の維持に役立ちます。',
			'firstTimeSetup.completion.checkboxTitle' => '利用規約とコミュニティルールに同意しました',
			'firstTimeSetup.completion.checkboxSubtitle' => '不同意の場合、アプリを利用できません',
			'firstTimeSetup.common.settingsChangeableTip' => 'これらの設定はいつでも設定画面で変更できます',
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
			_ => null,
		};
	}
}
