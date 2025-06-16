///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsJa implements Translations {
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
	@override late final _TranslationsLinkInputDialogJa linkInputDialog = _TranslationsLinkInputDialogJa._(_root);
	@override late final _TranslationsLogJa log = _TranslationsLogJa._(_root);
}

// Path: common
class _TranslationsCommonJa implements TranslationsCommonEn {
	_TranslationsCommonJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Love Iwara';
	@override String get ok => '確定';
	@override String get cancel => 'キャンセル';
	@override String get save => '保存';
	@override String get delete => '削除';
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
	@override String get private => 'プライベート';
	@override String get noTitle => 'タイトルなし';
	@override String get search => '検索';
	@override String get noContent => 'コンテンツがありません';
	@override String get recording => '録画中';
	@override String get paused => '一時停止';
	@override String get clear => 'クリア';
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
	@override String specialFollowLimitReached({required Object cnt}) => '特別フォローの上限を超えています。上限: ${cnt}，フォローリストページで調整してください';
	@override String get notFound => 'コンテンツが見つかりませんまたは削除されました';
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
	@override String get useTraditionalPaginationMode => '従来のページネーションモードを使用';
	@override String get useTraditionalPaginationModeDesc => '従来のページネーションモードを使用すると、ページネーションモードが無効になります。';
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
	@override String get jumpLink => 'リンクをジャンプ';
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
}

// Path: videoDetail
class _TranslationsVideoDetailJa implements TranslationsVideoDetailEn {
	_TranslationsVideoDetailJa._(this._root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'ピプモード';
	@override String resumeFromLastPosition({required Object position}) => '${position} から続けて再生';
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
	@override String get pause => '一時停止';
	@override String get resume => '継続';
	@override String get copyDownloadUrl => 'ダウンロードリンクをコピー';
	@override String get showInFolder => 'フォルダーで表示';
	@override String get deleteTask => 'タスクを削除';
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
	@override String get stillInDevelopment => '開発中';
	@override String get saveToAppDirectory => 'アプリケーションディレクトリに保存';
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
	@override String get maxTokensHintText => '例：1024';
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

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsJa {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Love Iwara';
			case 'common.ok': return '確定';
			case 'common.cancel': return 'キャンセル';
			case 'common.save': return '保存';
			case 'common.delete': return '削除';
			case 'common.loading': return '読み込み中...';
			case 'common.scrollToTop': return 'トップに戻る';
			case 'common.privacyHint': return 'プライバシー内容、表示しません';
			case 'common.latest': return '最新';
			case 'common.likesCount': return 'いいね数';
			case 'common.viewsCount': return '視聴回数';
			case 'common.popular': return '人気';
			case 'common.trending': return 'トレンド';
			case 'common.commentList': return 'コメント一覧';
			case 'common.sendComment': return 'コメントを投稿';
			case 'common.send': return '送信';
			case 'common.retry': return '再試行';
			case 'common.premium': return 'プレミアム会員';
			case 'common.follower': return 'フォロワー';
			case 'common.friend': return '友達';
			case 'common.video': return 'ビデオ';
			case 'common.following': return 'フォロー中';
			case 'common.expand': return '展開';
			case 'common.collapse': return '收起';
			case 'common.cancelFriendRequest': return '友達申請を取り消す';
			case 'common.cancelSpecialFollow': return '特別フォローを解除';
			case 'common.addFriend': return '友達を追加';
			case 'common.removeFriend': return '友達を解除';
			case 'common.followed': return 'フォロー済み';
			case 'common.follow': return 'フォローする';
			case 'common.unfollow': return 'フォロー解除';
			case 'common.specialFollow': return '特別フォロー';
			case 'common.specialFollowed': return '特別フォロー済み';
			case 'common.specialFollowsManagementTip': return 'ドラッグして並べ替え • 左スワイプで削除';
			case 'common.specialFollowsManagement': return '特別フォロー管理';
			case 'common.gallery': return 'ギャラリー';
			case 'common.playlist': return 'プレイリスト';
			case 'common.commentPostedSuccessfully': return 'コメントが正常に投稿されました';
			case 'common.commentPostedFailed': return 'コメントの投稿に失敗しました';
			case 'common.success': return '成功';
			case 'common.commentDeletedSuccessfully': return 'コメントが削除されました';
			case 'common.commentUpdatedSuccessfully': return 'コメントが更新されました';
			case 'common.totalComments': return ({required Object count}) => '${count} 件のコメント';
			case 'common.writeYourCommentHere': return 'ここにコメントを入力...';
			case 'common.tmpNoReplies': return '返信はありません';
			case 'common.loadMore': return 'もっと読み込む';
			case 'common.noMoreDatas': return 'これ以上データはありません';
			case 'common.selectTranslationLanguage': return '翻訳言語を選択';
			case 'common.translate': return '翻訳';
			case 'common.translateFailedPleaseTryAgainLater': return '翻訳に失敗しました。後でもう一度お試しください';
			case 'common.translationResult': return '翻訳結果';
			case 'common.justNow': return 'たった今';
			case 'common.minutesAgo': return ({required Object num}) => '${num} 分前';
			case 'common.hoursAgo': return ({required Object num}) => '${num} 時間前';
			case 'common.daysAgo': return ({required Object num}) => '${num} 日前';
			case 'common.editedAt': return ({required Object num}) => '${num} 編集';
			case 'common.editComment': return 'コメントを編集';
			case 'common.commentUpdated': return 'コメントが更新されました';
			case 'common.replyComment': return 'コメントに返信';
			case 'common.reply': return '返信';
			case 'common.edit': return '編集';
			case 'common.unknownUser': return '不明なユーザー';
			case 'common.me': return '私';
			case 'common.author': return '作者';
			case 'common.admin': return '管理者';
			case 'common.viewReplies': return ({required Object num}) => '返信を表示 (${num})';
			case 'common.hideReplies': return '返信を非表示';
			case 'common.confirmDelete': return '削除を確認';
			case 'common.areYouSureYouWantToDeleteThisItem': return 'この項目を削除してもよろしいですか？';
			case 'common.tmpNoComments': return 'コメントがありません';
			case 'common.refresh': return '更新';
			case 'common.back': return '戻る';
			case 'common.tips': return 'ヒント';
			case 'common.linkIsEmpty': return 'リンクアドレスが空です';
			case 'common.linkCopiedToClipboard': return 'リンクアドレスがクリップボードにコピーされました';
			case 'common.imageCopiedToClipboard': return '画像がクリップボードにコピーされました';
			case 'common.copyImageFailed': return '画像のコピーに失敗しました';
			case 'common.mobileSaveImageIsUnderDevelopment': return 'モバイル端末での画像保存機能は現在開発中です';
			case 'common.imageSavedTo': return '画像が保存されました';
			case 'common.saveImageFailed': return '画像の保存に失敗しました';
			case 'common.close': return '閉じる';
			case 'common.more': return 'もっと見る';
			case 'common.moreFeaturesToBeDeveloped': return 'さらに機能が開発中です';
			case 'common.all': return 'すべて';
			case 'common.selectedRecords': return ({required Object num}) => '${num} 件のレコードが選択されました';
			case 'common.cancelSelectAll': return 'すべての選択を解除';
			case 'common.selectAll': return 'すべて選択';
			case 'common.exitEditMode': return '編集モードを終了';
			case 'common.areYouSureYouWantToDeleteSelectedItems': return ({required Object num}) => '選択した ${num} 件のレコードを削除してもよろしいですか？';
			case 'common.searchHistoryRecords': return '検索履歴...';
			case 'common.settings': return '設定';
			case 'common.subscriptions': return 'サブスクリプション';
			case 'common.videoCount': return ({required Object num}) => '${num} 本の動画';
			case 'common.share': return '共有';
			case 'common.areYouSureYouWantToShareThisPlaylist': return 'このプレイリストを共有してもよろしいですか？';
			case 'common.editTitle': return 'タイトルを編集';
			case 'common.editMode': return '編集モード';
			case 'common.pleaseEnterNewTitle': return '新しいタイトルを入力してください';
			case 'common.createPlayList': return 'プレイリストを作成';
			case 'common.create': return '作成';
			case 'common.checkNetworkSettings': return 'ネットワーク設定を確認';
			case 'common.general': return '一般';
			case 'common.r18': return 'R18';
			case 'common.sensitive': return 'センシティブ';
			case 'common.year': return '年';
			case 'common.month': return '月';
			case 'common.tag': return 'タグ';
			case 'common.private': return 'プライベート';
			case 'common.noTitle': return 'タイトルなし';
			case 'common.search': return '検索';
			case 'common.noContent': return 'コンテンツがありません';
			case 'common.recording': return '録画中';
			case 'common.paused': return '一時停止';
			case 'common.clear': return 'クリア';
			case 'common.user': return 'ユーザー';
			case 'common.post': return '投稿';
			case 'common.seconds': return '秒';
			case 'common.comingSoon': return '近日公開';
			case 'common.confirm': return '確認';
			case 'common.hour': return '時';
			case 'common.minute': return '分';
			case 'common.clickToRefresh': return 'クリックして更新';
			case 'common.history': return '履歴';
			case 'common.favorites': return 'お気に入り';
			case 'common.friends': return '友達';
			case 'common.playList': return 'プレイリスト';
			case 'common.checkLicense': return 'ライセンスを確認';
			case 'common.logout': return 'ログアウト';
			case 'common.fensi': return 'フォロワー';
			case 'common.accept': return '受け入れる';
			case 'common.reject': return '拒否';
			case 'common.clearAllHistory': return 'すべての履歴をクリア';
			case 'common.clearAllHistoryConfirm': return 'すべての履歴をクリアしてもよろしいですか？';
			case 'common.followingList': return 'フォロー中リスト';
			case 'common.followersList': return 'フォロワーリスト';
			case 'common.follows': return 'フォロー';
			case 'common.fans': return 'フォロワー';
			case 'common.followsAndFans': return 'フォローとフォロワー';
			case 'common.numViews': return '視聴回数';
			case 'common.updatedAt': return '更新時間';
			case 'common.publishedAt': return '発表時間';
			case 'common.externalVideo': return '站外動画';
			case 'common.originalText': return '原文';
			case 'common.showOriginalText': return '原文を表示';
			case 'common.showProcessedText': return '処理後の原文を表示';
			case 'common.preview': return 'プレビュー';
			case 'common.rules': return 'ルール';
			case 'common.agree': return '同意';
			case 'common.disagree': return '不同意';
			case 'common.agreeToRules': return '同意ルール';
			case 'common.createPost': return '投稿を作成';
			case 'common.title': return 'タイトル';
			case 'common.enterTitle': return 'タイトルを入力してください';
			case 'common.content': return '内容';
			case 'common.enterContent': return '内容を入力してください';
			case 'common.writeYourContentHere': return '内容を入力してください...';
			case 'common.tagBlacklist': return 'ブラックリストタグ';
			case 'common.noData': return 'データがありません';
			case 'common.tagLimit': return 'タグ上限';
			case 'common.enableFloatingButtons': return 'フローティングボタンを有効';
			case 'common.disableFloatingButtons': return 'フローティングボタンを無効';
			case 'common.enabledFloatingButtons': return 'フローティングボタンが有効';
			case 'common.disabledFloatingButtons': return 'フローティングボタンが無効';
			case 'common.pendingCommentCount': return '未審核コメント';
			case 'common.joined': return ({required Object str}) => '${str} に参加';
			case 'common.download': return 'ダウンロード';
			case 'common.selectQuality': return '画質を選択';
			case 'common.selectDateRange': return '日付範囲を選択';
			case 'common.selectDateRangeHint': return '日付範囲を選択，デフォルトは最近30日';
			case 'common.clearDateRange': return '日付範囲をクリア';
			case 'common.followSuccessClickAgainToSpecialFollow': return 'フォローに成功しました。再度クリックして特別フォロー';
			case 'common.exitConfirmTip': return '本当に退出しますか？';
			case 'common.error': return 'エラー';
			case 'common.taskRunning': return '既にタスクが実行中です。しばらくお待ちください。';
			case 'common.operationCancelled': return '操作がキャンセルされました。';
			case 'common.unsavedChanges': return '未保存の変更があります';
			case 'common.pagination.totalItems': return ({required Object num}) => '全 ${num} 件';
			case 'common.pagination.jumpToPage': return 'ページ指定';
			case 'common.pagination.pleaseEnterPageNumber': return ({required Object max}) => 'ページ番号を入力してください (1-${max})';
			case 'common.pagination.pageNumber': return 'ページ番号';
			case 'common.pagination.jump': return '移動';
			case 'common.pagination.invalidPageNumber': return ({required Object max}) => '有効なページ番号を入力してください (1-${max})';
			case 'common.pagination.invalidInput': return '有効なページ番号を入力してください';
			case 'common.pagination.waterfall': return 'ウォーターフォール';
			case 'common.pagination.pagination': return 'ページネーション';
			case 'auth.login': return 'ログイン';
			case 'auth.logout': return 'ログアウト';
			case 'auth.email': return 'メールアドレス';
			case 'auth.password': return 'パスワード';
			case 'auth.loginOrRegister': return 'ログイン / 新規登録';
			case 'auth.register': return '新規登録';
			case 'auth.pleaseEnterEmail': return 'メールアドレスを入力してください';
			case 'auth.pleaseEnterPassword': return 'パスワードを入力してください';
			case 'auth.passwordMustBeAtLeast6Characters': return 'パスワードは6文字以上必要です';
			case 'auth.pleaseEnterCaptcha': return 'キャプチャを入力してください';
			case 'auth.captcha': return 'キャプチャ';
			case 'auth.refreshCaptcha': return 'キャプチャを更新';
			case 'auth.captchaNotLoaded': return 'キャプチャを読み込めませんでした';
			case 'auth.loginSuccess': return 'ログインに成功しました';
			case 'auth.emailVerificationSent': return 'メール認証が送信されました';
			case 'auth.notLoggedIn': return 'ログインしていません';
			case 'auth.clickToLogin': return 'こちらをクリックしてログイン';
			case 'auth.logoutConfirmation': return '本当にログアウトしますか？';
			case 'auth.logoutSuccess': return 'ログアウトに成功しました';
			case 'auth.logoutFailed': return 'ログアウトに失敗しました';
			case 'auth.usernameOrEmail': return 'ユーザー名またはメールアドレス';
			case 'auth.pleaseEnterUsernameOrEmail': return 'ユーザー名またはメールアドレスを入力してください';
			case 'auth.rememberMe': return 'ユーザー名とパスワードを記憶';
			case 'errors.error': return 'エラー';
			case 'errors.required': return 'この項目は必須です';
			case 'errors.invalidEmail': return 'メールアドレスの形式が正しくありません';
			case 'errors.networkError': return 'ネットワークエラーが発生しました。再試行してください';
			case 'errors.errorWhileFetching': return '情報の取得に失敗しました';
			case 'errors.commentCanNotBeEmpty': return 'コメント内容は空にできません';
			case 'errors.errorWhileFetchingReplies': return '返信の取得中にエラーが発生しました。ネットワーク接続を確認してください';
			case 'errors.canNotFindCommentController': return 'コメントコントローラーが見つかりません';
			case 'errors.errorWhileLoadingGallery': return 'ギャラリーの読み込み中にエラーが発生しました';
			case 'errors.howCouldThereBeNoDataItCantBePossible': return 'え？データがありません。エラーが発生した可能性があります :<';
			case 'errors.unsupportedImageFormat': return ({required Object str}) => 'サポートされていない画像形式: ${str}';
			case 'errors.invalidGalleryId': return '無効なギャラリーIDです';
			case 'errors.translationFailedPleaseTryAgainLater': return '翻訳に失敗しました。後でもう一度お試しください';
			case 'errors.errorOccurred': return 'エラーが発生しました。しばらくしてから再試行してください。';
			case 'errors.errorOccurredWhileProcessingRequest': return 'リクエストの処理中にエラーが発生しました';
			case 'errors.errorWhileFetchingDatas': return 'データの取得中にエラーが発生しました。後でもう一度お試しください';
			case 'errors.serviceNotInitialized': return 'サービスが初期化されていません';
			case 'errors.unknownType': return '不明なタイプです';
			case 'errors.errorWhileOpeningLink': return ({required Object link}) => 'リンクを開けませんでした: ${link}';
			case 'errors.invalidUrl': return '無効なURLです';
			case 'errors.failedToOperate': return '操作に失敗しました';
			case 'errors.permissionDenied': return '権限がありません';
			case 'errors.youDoNotHavePermissionToAccessThisResource': return 'このリソースにアクセスする権限がありません';
			case 'errors.loginFailed': return 'ログインに失敗しました';
			case 'errors.unknownError': return '不明なエラーです';
			case 'errors.sessionExpired': return 'セッションが期限切れです';
			case 'errors.failedToFetchCaptcha': return 'キャプチャの取得に失敗しました';
			case 'errors.emailAlreadyExists': return 'メールアドレスは既に存在します';
			case 'errors.invalidCaptcha': return '無効なキャプチャです';
			case 'errors.registerFailed': return '登録に失敗しました';
			case 'errors.failedToFetchComments': return 'コメントの取得に失敗しました';
			case 'errors.failedToFetchImageDetail': return '画像の取得に失敗しました';
			case 'errors.failedToFetchImageList': return '画像の取得に失敗しました';
			case 'errors.failedToFetchData': return 'データの取得に失敗しました';
			case 'errors.invalidParameter': return '無効なパラメータです';
			case 'errors.pleaseLoginFirst': return 'ログインしてください';
			case 'errors.errorWhileLoadingPost': return '投稿の取得中にエラーが発生しました';
			case 'errors.errorWhileLoadingPostDetail': return '投稿詳細の取得中にエラーが発生しました';
			case 'errors.invalidPostId': return '無効な投稿IDです';
			case 'errors.forceUpdateNotPermittedToGoBack': return '現在強制更新状態です。戻ることはできません';
			case 'errors.pleaseLoginAgain': return 'ログインしてください';
			case 'errors.invalidLogin': return 'ログインに失敗しました。メールアドレスとパスワードを確認してください';
			case 'errors.tooManyRequests': return 'リクエストが多すぎます。後でもう一度お試しください';
			case 'errors.exceedsMaxLength': return ({required Object max}) => '最大長さを超えています: ${max}';
			case 'errors.contentCanNotBeEmpty': return 'コンテンツは空にできません';
			case 'errors.titleCanNotBeEmpty': return 'タイトルは空にできません';
			case 'errors.tooManyRequestsPleaseTryAgainLaterText': return 'リクエストが多すぎます。後でもう一度お試しください。残り時間';
			case 'errors.remainingHours': return ({required Object num}) => '${num}時間';
			case 'errors.remainingMinutes': return ({required Object num}) => '${num}分';
			case 'errors.remainingSeconds': return ({required Object num}) => '${num}秒';
			case 'errors.tagLimitExceeded': return ({required Object limit}) => 'タグの上限を超えています。上限: ${limit}';
			case 'errors.failedToRefresh': return '更新に失敗しました';
			case 'errors.noPermission': return '権限がありません';
			case 'errors.resourceNotFound': return 'リソースが見つかりません';
			case 'errors.failedToSaveCredentials': return 'ログイン情報の保存に失敗しました';
			case 'errors.failedToLoadSavedCredentials': return '保存されたログイン情報の読み込みに失敗しました';
			case 'errors.specialFollowLimitReached': return ({required Object cnt}) => '特別フォローの上限を超えています。上限: ${cnt}，フォローリストページで調整してください';
			case 'errors.notFound': return 'コンテンツが見つかりませんまたは削除されました';
			case 'friends.clickToRestoreFriend': return '友達を復元するにはクリックしてください';
			case 'friends.friendsList': return '友達リスト';
			case 'friends.friendRequests': return '友達リクエスト';
			case 'friends.friendRequestsList': return '友達リクエスト一覧';
			case 'friends.removingFriend': return 'フレンド解除中...';
			case 'friends.failedToRemoveFriend': return 'フレンド解除に失敗しました';
			case 'friends.cancelingRequest': return 'フレンド申請をキャンセル中...';
			case 'friends.failedToCancelRequest': return 'フレンド申請のキャンセルに失敗しました';
			case 'authorProfile.noMoreDatas': return 'これ以上データはありません';
			case 'authorProfile.userProfile': return 'ユーザープロフィール';
			case 'favorites.clickToRestoreFavorite': return 'お気に入りを復元するにはクリックしてください';
			case 'favorites.myFavorites': return '私のお気に入り';
			case 'galleryDetail.galleryDetail': return 'ギャラリー詳細';
			case 'galleryDetail.viewGalleryDetail': return 'ギャラリー詳細を表示';
			case 'galleryDetail.copyLink': return 'リンクをコピー';
			case 'galleryDetail.copyImage': return '画像をコピー';
			case 'galleryDetail.saveAs': return '名前を付けて保存';
			case 'galleryDetail.saveToAlbum': return 'アルバムに保存';
			case 'galleryDetail.publishedAt': return '公開日時';
			case 'galleryDetail.viewsCount': return '視聴回数';
			case 'galleryDetail.imageLibraryFunctionIntroduction': return 'ギャラリー機能の紹介';
			case 'galleryDetail.rightClickToSaveSingleImage': return '右クリックで単一画像を保存';
			case 'galleryDetail.batchSave': return 'バッチ保存';
			case 'galleryDetail.keyboardLeftAndRightToSwitch': return 'キーボードの左右キーで切り替え';
			case 'galleryDetail.keyboardUpAndDownToZoom': return 'キーボードの上下キーでズーム';
			case 'galleryDetail.mouseWheelToSwitch': return 'マウスホイールで切り替え';
			case 'galleryDetail.ctrlAndMouseWheelToZoom': return 'CTRL + マウスホイールでズーム';
			case 'galleryDetail.moreFeaturesToBeDiscovered': return 'さらに機能が発見されます...';
			case 'galleryDetail.authorOtherGalleries': return '作者の他のギャラリー';
			case 'galleryDetail.relatedGalleries': return '関連ギャラリー';
			case 'galleryDetail.clickLeftAndRightEdgeToSwitchImage': return '左端と右端をクリックして切り替え';
			case 'playList.myPlayList': return '私のプレイリスト';
			case 'playList.friendlyTips': return 'フレンドリーティップス';
			case 'playList.dearUser': return '親愛なるユーザー';
			case 'playList.iwaraPlayListSystemIsNotPerfectYet': return 'iwaraのプレイリストシステムはまだ完全ではありません';
			case 'playList.notSupportSetCover': return 'カバー設定はサポートされていません';
			case 'playList.notSupportDeleteList': return 'リストの削除はできません';
			case 'playList.notSupportSetPrivate': return 'プライベート設定はできません';
			case 'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone': return 'はい...作成されたリストは常に存在し、全員に表示されます';
			case 'playList.smallSuggestion': return '小さな提案';
			case 'playList.useLikeToCollectContent': return 'プライバシーを重視する場合は、「いいね」機能を使用してコンテンツを収集することをお勧めします';
			case 'playList.welcomeToDiscussOnGitHub': return 'その他の提案やアイデアがある場合は、GitHubでのディスカッションを歓迎します！';
			case 'playList.iUnderstand': return 'わかりました';
			case 'playList.searchPlaylists': return 'プレイリストを検索...';
			case 'playList.newPlaylistName': return '新しいプレイリスト名';
			case 'playList.createNewPlaylist': return '新しいプレイリストを作成';
			case 'playList.videos': return '動画';
			case 'search.googleSearchScope': return '検索範囲';
			case 'search.searchTags': return 'タグを検索...';
			case 'search.contentRating': return 'コンテンツレーティング';
			case 'search.removeTag': return 'タグを削除';
			case 'search.pleaseEnterSearchContent': return '検索内容を入力してください';
			case 'search.searchHistory': return '検索履歴';
			case 'search.searchSuggestion': return '検索提案';
			case 'search.usedTimes': return '使用回数';
			case 'search.lastUsed': return '最後の使用';
			case 'search.noSearchHistoryRecords': return '検索履歴がありません';
			case 'search.notSupportCurrentSearchType': return ({required Object searchType}) => '現在の検索タイプ ${searchType} はまだ実装されていません。お楽しみに';
			case 'search.searchResult': return '検索結果';
			case 'search.unsupportedSearchType': return ({required Object searchType}) => 'サポートされていない検索タイプ: ${searchType}';
			case 'search.googleSearch': return 'グーグル検索';
			case 'search.googleSearchHint': return ({required Object webName}) => '${webName} の検索機能は使いにくいですか？ グーグル検索を試してみてください！';
			case 'search.googleSearchDescription': return 'Google Search の :site 検索演算子を使用して、サイトのコンテンツを検索します。これは、動画、ギャラリー、プレイリスト、ユーザーを検索する際に非常に便利です。';
			case 'search.googleSearchKeywordsHint': return '検索するキーワードを入力してください';
			case 'search.openLinkJump': return 'リンクジャンプを開く';
			case 'search.googleSearchButton': return 'グーグル検索';
			case 'search.pleaseEnterSearchKeywords': return '検索するキーワードを入力してください';
			case 'search.googleSearchQueryCopied': return '検索語句をクリップボードにコピーしました';
			case 'search.googleSearchBrowserOpenFailed': return ({required Object error}) => 'ブラウザを開けませんでした: ${error}';
			case 'mediaList.personalIntroduction': return '個人紹介';
			case 'settings.listViewMode': return 'リスト表示モード';
			case 'settings.useTraditionalPaginationMode': return '従来のページネーションモードを使用';
			case 'settings.useTraditionalPaginationModeDesc': return '従来のページネーションモードを使用すると、ページネーションモードが無効になります。';
			case 'settings.showVideoProgressBottomBarWhenToolbarHidden': return '底部プログレスバー';
			case 'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc': return 'この設定は、ツールバーが非表示のときに底部プログレスバーを表示するかどうかを決定します。';
			case 'settings.basicSettings': return '基本設定';
			case 'settings.personalizedSettings': return '個性化設定';
			case 'settings.otherSettings': return 'その他設定';
			case 'settings.searchConfig': return '検索設定';
			case 'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain': return 'この設定は、今後動画を再生する際に以前の設定を使用するかどうかを決定します。';
			case 'settings.playControl': return '再生コントロール';
			case 'settings.fastForwardTime': return '早送り時間';
			case 'settings.fastForwardTimeMustBeAPositiveInteger': return '早送り時間は正の整数でなければなりません。';
			case 'settings.rewindTime': return '巻き戻し時間';
			case 'settings.rewindTimeMustBeAPositiveInteger': return '巻き戻し時間は正の整数でなければなりません。';
			case 'settings.longPressPlaybackSpeed': return '長押し再生速度';
			case 'settings.longPressPlaybackSpeedMustBeAPositiveNumber': return '長押し再生速度は正の数でなければなりません。';
			case 'settings.repeat': return 'リピート';
			case 'settings.renderVerticalVideoInVerticalScreen': return '全画面再生時に縦向きビデオを縦画面モードでレンダリング';
			case 'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen': return 'この設定は、全画面再生時に縦向きビデオを縦画面モードでレンダリングするかどうかを決定します。';
			case 'settings.rememberVolume': return '音量を記憶';
			case 'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain': return 'この設定は、今後動画を再生する際に以前の音量設定を使用するかどうかを決定します。';
			case 'settings.rememberBrightness': return '明るさを記憶';
			case 'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain': return 'この設定は、今後動画を再生する際に以前の明るさ設定を使用するかどうかを決定します。';
			case 'settings.playControlArea': return '再生コントロールエリア';
			case 'settings.leftAndRightControlAreaWidth': return '左右コントロールエリアの幅';
			case 'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer': return 'この設定は、プレイヤーの左右にあるコントロールエリアの幅を決定します。';
			case 'settings.proxyAddressCannotBeEmpty': return 'プロキシアドレスは空にできません。';
			case 'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort': return '無効なプロキシアドレス形式です。IP:ポート または ドメイン名:ポート の形式を使用してください。';
			case 'settings.proxyNormalWork': return 'プロキシが正常に動作しています。';
			case 'settings.testProxyFailedWithStatusCode': return ({required Object code}) => 'プロキシリクエストが失敗しました。ステータスコード: ${code}';
			case 'settings.testProxyFailedWithException': return ({required Object exception}) => 'プロキシリクエスト中にエラーが発生しました: ${exception}';
			case 'settings.proxyConfig': return 'プロキシ設定';
			case 'settings.thisIsHttpProxyAddress': return 'ここにHTTPプロキシアドレスを入力してください';
			case 'settings.checkProxy': return 'プロキシを確認';
			case 'settings.proxyAddress': return 'プロキシアドレス';
			case 'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080': return 'プロキシサーバーのURLを入力してください（例: 127.0.0.1:8080）';
			case 'settings.enableProxy': return 'プロキシを有効にする';
			case 'settings.left': return '左';
			case 'settings.middle': return '中央';
			case 'settings.right': return '右';
			case 'settings.playerSettings': return 'プレイヤー設定';
			case 'settings.networkSettings': return 'ネットワーク設定';
			case 'settings.customizeYourPlaybackExperience': return '再生体験をカスタマイズ';
			case 'settings.chooseYourFavoriteAppAppearance': return 'お好みのアプリ外観を選択';
			case 'settings.configureYourProxyServer': return 'プロキシサーバーを設定';
			case 'settings.settings': return '設定';
			case 'settings.themeSettings': return 'テーマ設定';
			case 'settings.followSystem': return 'システムに従う';
			case 'settings.lightMode': return 'ライトモード';
			case 'settings.darkMode': return 'ダークモード';
			case 'settings.presetTheme': return 'プリセットテーマ';
			case 'settings.basicTheme': return 'ベーシックテーマ';
			case 'settings.needRestartToApply': return 'アプリを再起動して設定を適用してください';
			case 'settings.themeNeedRestartDescription': return 'テーマ設定はアプリを再起動して設定を適用してください';
			case 'settings.about': return 'アバウト';
			case 'settings.currentVersion': return '現在のバージョン';
			case 'settings.latestVersion': return '最新バージョン';
			case 'settings.checkForUpdates': return '更新をチェック';
			case 'settings.update': return '更新';
			case 'settings.newVersionAvailable': return '新しいバージョンが利用可能です';
			case 'settings.projectHome': return 'プロジェクトホーム';
			case 'settings.release': return 'リリース';
			case 'settings.issueReport': return '問題報告';
			case 'settings.openSourceLicense': return 'オープンソースライセンス';
			case 'settings.checkForUpdatesFailed': return '更新のチェックに失敗しました。後でもう一度お試しください';
			case 'settings.autoCheckUpdate': return '自動更新';
			case 'settings.updateContent': return '更新内容';
			case 'settings.releaseDate': return 'リリース日';
			case 'settings.ignoreThisVersion': return 'このバージョンを無視';
			case 'settings.minVersionUpdateRequired': return '現在のバージョンが低すぎます。すぐに更新してください';
			case 'settings.forceUpdateTip': return 'これは必須アップデートです。できるだけ早く最新バージョンにアップデートしてください';
			case 'settings.viewChangelog': return '更新内容を表示';
			case 'settings.alreadyLatestVersion': return 'すでに最新バージョンです';
			case 'settings.appSettings': return 'アプリ設定';
			case 'settings.configureYourAppSettings': return 'アプリ設定を設定';
			case 'settings.history': return '履歴';
			case 'settings.autoRecordHistory': return '自動記録履歴';
			case 'settings.autoRecordHistoryDesc': return '視聴した動画やギャラリーなどの情報を自動的に記録します';
			case 'settings.showUnprocessedMarkdownText': return '未処理のMarkdownテキストを表示';
			case 'settings.showUnprocessedMarkdownTextDesc': return 'Markdownの元のテキストを表示';
			case 'settings.markdown': return 'Markdown';
			case 'settings.activeBackgroundPrivacyMode': return 'プライバシーモード';
			case 'settings.activeBackgroundPrivacyModeDesc': return 'スクリーンショットを禁止し、バックグラウンド実行時に画面を隠す...';
			case 'settings.privacy': return 'プライバシー';
			case 'settings.forum': return 'フォーラム';
			case 'settings.disableForumReplyQuote': return 'フォーラム返信引用を無効にする';
			case 'settings.disableForumReplyQuoteDesc': return 'フォーラム返信時の返信階層情報の携帯を無効にする';
			case 'settings.theaterMode': return '劇院モード';
			case 'settings.theaterModeDesc': return '開啟後、プレーヤー背景がビデオカバーのぼかしバージョンに設定されます';
			case 'settings.appLinks': return 'アプリリンク';
			case 'settings.defaultBrowser': return 'デフォルトブラウザ';
			case 'settings.defaultBrowserDesc': return 'システム設定でデフォルトリンク設定項目を開き、iwara.tvサイトリンクを追加してください';
			case 'settings.themeMode': return 'テーマモード';
			case 'settings.themeModeDesc': return 'この設定はアプリのテーマモードを決定します';
			case 'settings.dynamicColor': return 'ダイナミックカラー';
			case 'settings.dynamicColorDesc': return 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
			case 'settings.useDynamicColor': return 'ダイナミックカラーを使用';
			case 'settings.useDynamicColorDesc': return 'この設定はアプリがダイナミックカラーを使用するかどうかを決定します';
			case 'settings.presetColors': return 'プリセットカラー';
			case 'settings.customColors': return 'カスタムカラー';
			case 'settings.pickColor': return 'カラーを選択';
			case 'settings.cancel': return 'キャンセル';
			case 'settings.confirm': return '確認';
			case 'settings.noCustomColors': return 'カスタムカラーがありません';
			case 'settings.recordAndRestorePlaybackProgress': return '再生進度を記録して復元';
			case 'settings.signature': return '小尾巴';
			case 'settings.enableSignature': return '小尾巴を有効にする';
			case 'settings.enableSignatureDesc': return 'この設定はアプリが回覆時に小尾巴を有効にするかどうかを決定します';
			case 'settings.enterSignature': return '小尾巴を入力';
			case 'settings.editSignature': return '小尾巴を編集';
			case 'settings.signatureContent': return '小尾巴の内容';
			case 'settings.exportConfig': return 'アプリ設定をエクスポート';
			case 'settings.exportConfigDesc': return 'ダウンロード記録を除いたアプリ設定をファイルにエクスポートします';
			case 'settings.importConfig': return 'アプリ設定をインポート';
			case 'settings.importConfigDesc': return 'ファイルからアプリ設定をインポートします';
			case 'settings.exportConfigSuccess': return '設定が正常にエクスポートされました';
			case 'settings.exportConfigFailed': return '設定のエクスポートに失敗しました';
			case 'settings.importConfigSuccess': return '設定が正常にインポートされました';
			case 'settings.importConfigFailed': return '設定のインポートに失敗しました';
			case 'settings.historyUpdateLogs': return '歴代アップデートログ';
			case 'settings.noUpdateLogs': return 'アップデートログが取得できませんでした';
			case 'settings.versionLabel': return 'バージョン: {version}';
			case 'settings.releaseDateLabel': return 'リリース日: {date}';
			case 'settings.noChanges': return '更新内容がありません';
			case 'settings.interaction': return 'インタラクション';
			case 'settings.enableVibration': return 'バイブレーション';
			case 'settings.enableVibrationDesc': return 'アプリの操作時にバイブレーションフィードバックを有効にする';
			case 'settings.defaultKeepVideoToolbarVisible': return 'ツールバーを常に表示';
			case 'settings.defaultKeepVideoToolbarVisibleDesc': return 'この設定は、動画ページに入った時にツールバーを常に表示するかどうかを決定します。';
			case 'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt': return 'モバイル端でシアターモードを有効にすると、パフォーマンスの問題が発生する可能性があるため、状況に応じてご利用ください。';
			case 'settings.lockButtonPosition': return 'ロックボタンの位置';
			case 'settings.lockButtonPositionBothSides': return '両側に表示';
			case 'settings.lockButtonPositionLeftSide': return '左側のみ表示';
			case 'settings.lockButtonPositionRightSide': return '右側のみ表示';
			case 'settings.jumpLink': return 'リンクをジャンプ';
			case 'signIn.pleaseLoginFirst': return 'サインインする前にログインしてください';
			case 'signIn.alreadySignedInToday': return '今日は既にサインインしています！';
			case 'signIn.youDidNotStickToTheSignIn': return 'サインインを続けることができませんでした。';
			case 'signIn.signInSuccess': return 'サインインに成功しました！';
			case 'signIn.signInFailed': return 'サインインに失敗しました。後でもう一度お試しください';
			case 'signIn.consecutiveSignIns': return '連続サインイン日数';
			case 'signIn.failureReason': return 'サインインに失敗した理由';
			case 'signIn.selectDateRange': return '日付範囲を選択';
			case 'signIn.startDate': return '開始日';
			case 'signIn.endDate': return '終了日';
			case 'signIn.invalidDate': return '日付形式が正しくありません';
			case 'signIn.invalidDateRange': return '日付範囲が無効です';
			case 'signIn.errorFormatText': return '日付形式が正しくありません';
			case 'signIn.errorInvalidText': return '日付範囲が無効です';
			case 'signIn.errorInvalidRangeText': return '日付範囲が無効です';
			case 'signIn.dateRangeCantBeMoreThanOneYear': return '日付範囲は1年を超えることはできません';
			case 'signIn.signIn': return 'サインイン';
			case 'signIn.signInRecord': return 'サインイン記録';
			case 'signIn.totalSignIns': return '合計サインイン数';
			case 'signIn.pleaseSelectSignInStatus': return 'サインインステータスを選択してください';
			case 'subscriptions.pleaseLoginFirstToViewYourSubscriptions': return 'サブスクリプションを表示するにはログインしてください。';
			case 'videoDetail.pipMode': return 'ピプモード';
			case 'videoDetail.resumeFromLastPosition': return ({required Object position}) => '${position} から続けて再生';
			case 'videoDetail.videoIdIsEmpty': return 'ビデオIDが空です';
			case 'videoDetail.videoInfoIsEmpty': return 'ビデオ情報が空です';
			case 'videoDetail.thisIsAPrivateVideo': return 'これはプライベートビデオです';
			case 'videoDetail.getVideoInfoFailed': return 'ビデオ情報の取得に失敗しました。後でもう一度お試しください';
			case 'videoDetail.noVideoSourceFound': return '対応するビデオソースが見つかりません';
			case 'videoDetail.tagCopiedToClipboard': return ({required Object tagId}) => 'タグ "${tagId}" がクリップボードにコピーされました';
			case 'videoDetail.errorLoadingVideo': return 'ビデオの読み込み中にエラーが発生しました';
			case 'videoDetail.play': return '再生';
			case 'videoDetail.pause': return '一時停止';
			case 'videoDetail.exitAppFullscreen': return 'アプリの全画面表示を終了';
			case 'videoDetail.enterAppFullscreen': return 'アプリを全画面表示';
			case 'videoDetail.exitSystemFullscreen': return 'システム全画面表示を終了';
			case 'videoDetail.enterSystemFullscreen': return 'システム全画面表示';
			case 'videoDetail.seekTo': return '指定時間にシーク';
			case 'videoDetail.switchResolution': return '解像度を変更';
			case 'videoDetail.switchPlaybackSpeed': return '再生速度を変更';
			case 'videoDetail.rewindSeconds': return ({required Object num}) => '${num} 秒巻き戻し';
			case 'videoDetail.fastForwardSeconds': return ({required Object num}) => '${num} 秒早送り';
			case 'videoDetail.playbackSpeedIng': return ({required Object rate}) => '${rate} 倍速で再生中';
			case 'videoDetail.brightness': return '明るさ';
			case 'videoDetail.brightnessLowest': return '明るさが最低になっています';
			case 'videoDetail.volume': return '音量';
			case 'videoDetail.volumeMuted': return '音量がミュートされています';
			case 'videoDetail.home': return 'ホーム';
			case 'videoDetail.videoPlayer': return 'ビデオプレーヤー';
			case 'videoDetail.videoPlayerInfo': return 'プレーヤー情報';
			case 'videoDetail.moreSettings': return 'さらに設定';
			case 'videoDetail.videoPlayerFeatureInfo': return 'プレーヤー機能の紹介';
			case 'videoDetail.autoRewind': return '自動リワインド';
			case 'videoDetail.rewindAndFastForward': return '両側をダブルクリックして早送りまたは巻き戻し';
			case 'videoDetail.volumeAndBrightness': return '両側を上下にスワイプして音量と明るさを調整';
			case 'videoDetail.centerAreaDoubleTapPauseOrPlay': return '中央エリアをダブルタップして一時停止または再生';
			case 'videoDetail.showVerticalVideoInFullScreen': return '全画面表示時に縦向きビデオを表示';
			case 'videoDetail.keepLastVolumeAndBrightness': return '前回の音量と明るさを保持';
			case 'videoDetail.setProxy': return 'プロキシを設定';
			case 'videoDetail.moreFeaturesToBeDiscovered': return 'さらに機能が発見されます...';
			case 'videoDetail.videoPlayerSettings': return 'プレーヤー設定';
			case 'videoDetail.commentCount': return ({required Object num}) => '${num} 件のコメント';
			case 'videoDetail.writeYourCommentHere': return 'ここにコメントを入力...';
			case 'videoDetail.authorOtherVideos': return '作者の他のビデオ';
			case 'videoDetail.relatedVideos': return '関連ビデオ';
			case 'videoDetail.privateVideo': return 'これはプライベートビデオです';
			case 'videoDetail.externalVideo': return 'これは站外ビデオです';
			case 'videoDetail.openInBrowser': return 'ブラウザで開く';
			case 'videoDetail.resourceDeleted': return 'このビデオは削除されたようです :/';
			case 'videoDetail.noDownloadUrl': return 'ダウンロードURLがありません';
			case 'videoDetail.startDownloading': return 'ダウンロードを開始';
			case 'videoDetail.downloadFailed': return 'ダウンロードに失敗しました。後でもう一度お試しください';
			case 'videoDetail.downloadSuccess': return 'ダウンロードに成功しました';
			case 'videoDetail.download': return 'ダウンロード';
			case 'videoDetail.downloadManager': return 'ダウンロード管理';
			case 'share.sharePlayList': return 'プレイリストを共有';
			case 'share.wowDidYouSeeThis': return 'ああ、見たの？';
			case 'share.nameIs': return '名前は';
			case 'share.clickLinkToView': return 'リンクをクリックして見る';
			case 'share.iReallyLikeThis': return '本当に好きです';
			case 'share.shareFailed': return '共有に失敗しました。後でもう一度お試しください';
			case 'share.share': return '共有';
			case 'share.shareAsImage': return '画像として共有';
			case 'share.shareAsText': return 'テキストとして共有';
			case 'share.shareAsImageDesc': return '動画のサムネイルを画像として共有';
			case 'share.shareAsTextDesc': return '動画の詳細をテキストとして共有';
			case 'share.shareAsImageFailed': return 'サムネイルの共有に失敗しました。後でもう一度お試しください';
			case 'share.shareAsTextFailed': return '詳細の共有に失敗しました。後でもう一度お試しください';
			case 'share.shareVideo': return '動画を共有';
			case 'share.authorIs': return '作者は';
			case 'share.shareGallery': return 'ギャラリーを共有';
			case 'share.galleryTitleIs': return 'ギャラリーのタイトルは';
			case 'share.galleryAuthorIs': return 'ギャラリーの作者は';
			case 'share.shareUser': return 'ユーザーを共有';
			case 'share.userNameIs': return 'ユーザーの名前は';
			case 'share.userAuthorIs': return 'ユーザーの作者は';
			case 'share.comments': return 'コメント';
			case 'share.shareThread': return 'スレッドを共有';
			case 'share.views': return '閲覧';
			case 'share.sharePost': return '投稿を共有';
			case 'share.postTitleIs': return '投稿のタイトルは';
			case 'share.postAuthorIs': return '投稿の作者は';
			case 'markdown.markdownSyntax': return 'Markdown 構文';
			case 'markdown.iwaraSpecialMarkdownSyntax': return 'Iwara 専用構文';
			case 'markdown.internalLink': return '站内鏈接';
			case 'markdown.supportAutoConvertLinkBelow': return '以下のタイプのリンクを自動変換します：';
			case 'markdown.convertLinkExample': return '🎬 ビデオリンク\n🖼️ 画像リンク\n👤 ユーザーリンク\n📌 フォーラムリンク\n🎵 プレイリストリンク\n💬 スレッドリンク';
			case 'markdown.mentionUser': return 'ユーザーを言及';
			case 'markdown.mentionUserDescription': return '@後にユーザー名を入力すると、ユーザーリンクに自動変換されます';
			case 'markdown.markdownBasicSyntax': return 'Markdown 基本構文';
			case 'markdown.paragraphAndLineBreak': return '段落と改行';
			case 'markdown.paragraphAndLineBreakDescription': return '段落間に空行を入れ、行末に2つのスペースを追加すると改行されます';
			case 'markdown.paragraphAndLineBreakSyntax': return 'これは第一段落です\n\nこれは第二段落です\nこの行の後に2つのスペースを追加して  \n改行されます';
			case 'markdown.textStyle': return 'テキストスタイル';
			case 'markdown.textStyleDescription': return '特殊記号でテキストのスタイルを変更';
			case 'markdown.textStyleSyntax': return '**太字テキスト**\n*斜体テキスト*\n~~削除線テキスト~~\n`コードテキスト`';
			case 'markdown.quote': return '引用';
			case 'markdown.quoteDescription': return '> 符号で引用を作成し、複数の > で多段引用を作成';
			case 'markdown.quoteSyntax': return '> これは一階引用です\n>> これは二階引用です';
			case 'markdown.list': return 'リスト';
			case 'markdown.listDescription': return '数字+点号で順序付きリストを作成し、- で順序なしリストを作成';
			case 'markdown.listSyntax': return '1. 第一項\n2. 第二項\n\n- 順序なし項\n  - 子項\n  - 別の子項';
			case 'markdown.linkAndImage': return 'リンクと画像';
			case 'markdown.linkAndImageDescription': return 'リンク形式：[テキスト](URL)\n画像形式：![説明](URL)';
			case 'markdown.linkAndImageSyntax': return ({required Object link, required Object imgUrl}) => '[リンクテキスト](${link})\n![画像説明](${imgUrl})';
			case 'markdown.title': return 'タイトル';
			case 'markdown.titleDescription': return '＃ 号でタイトルを作成し、数でレベルを表示';
			case 'markdown.titleSyntax': return '# 一階タイトル\n## 二階タイトル\n### 三階タイトル';
			case 'markdown.separator': return '分隔線';
			case 'markdown.separatorDescription': return '三個以上の - 号で分隔線を作成';
			case 'markdown.separatorSyntax': return '---';
			case 'markdown.syntax': return '語法';
			case 'forum.recent': return '最近';
			case 'forum.category': return 'カテゴリ';
			case 'forum.lastReply': return '最終返信';
			case 'forum.errors.pleaseSelectCategory': return 'カテゴリを選択してください';
			case 'forum.errors.threadLocked': return 'このスレッドはロックされています。';
			case 'forum.title': return 'タイトル';
			case 'forum.createPost': return '投稿を作成';
			case 'forum.enterTitle': return 'タイトルを入力してください';
			case 'forum.content': return 'コンテンツ';
			case 'forum.enterContent': return 'コンテンツを入力してください';
			case 'forum.writeYourContentHere': return 'ここにコンテンツを入力...';
			case 'forum.posts': return '投稿';
			case 'forum.threads': return 'スレッド';
			case 'forum.forum': return 'フォーラム';
			case 'forum.createThread': return 'スレッドを作成';
			case 'forum.selectCategory': return 'カテゴリを選択';
			case 'forum.cooldownRemaining': return ({required Object minutes, required Object seconds}) => 'クールダウン残り時間 ${minutes} 分 ${seconds} 秒';
			case 'forum.groups.administration': return '管理';
			case 'forum.groups.global': return 'グローバル';
			case 'forum.groups.chinese': return '中国語';
			case 'forum.groups.japanese': return '日本語';
			case 'forum.groups.korean': return '韓国語';
			case 'forum.groups.other': return 'その他';
			case 'forum.leafNames.announcements': return 'お知らせ';
			case 'forum.leafNames.feedback': return 'フィードバック';
			case 'forum.leafNames.support': return 'サポート';
			case 'forum.leafNames.general': return '一般';
			case 'forum.leafNames.guides': return 'ガイド';
			case 'forum.leafNames.questions': return '質問';
			case 'forum.leafNames.requests': return 'リクエスト';
			case 'forum.leafNames.sharing': return 'シェア';
			case 'forum.leafNames.general_zh': return '一般';
			case 'forum.leafNames.questions_zh': return '質問';
			case 'forum.leafNames.requests_zh': return 'リクエスト';
			case 'forum.leafNames.support_zh': return 'サポート';
			case 'forum.leafNames.general_ja': return '一般';
			case 'forum.leafNames.questions_ja': return '質問';
			case 'forum.leafNames.requests_ja': return 'リクエスト';
			case 'forum.leafNames.support_ja': return 'サポート';
			case 'forum.leafNames.korean': return '韓国語';
			case 'forum.leafNames.other': return 'その他';
			case 'forum.leafDescriptions.announcements': return '公式の重要なお知らせと通知';
			case 'forum.leafDescriptions.feedback': return 'サイトの機能やサービスに対するフィードバック';
			case 'forum.leafDescriptions.support': return 'サイト関連の問題を解決する手助け';
			case 'forum.leafDescriptions.general': return 'あらゆる話題を議論する';
			case 'forum.leafDescriptions.guides': return '経験やチュートリアルを共有する';
			case 'forum.leafDescriptions.questions': return '疑問を提起する';
			case 'forum.leafDescriptions.requests': return 'リクエストを投稿する';
			case 'forum.leafDescriptions.sharing': return '面白いコンテンツを共有する';
			case 'forum.leafDescriptions.general_zh': return 'あらゆる話題を議論する';
			case 'forum.leafDescriptions.questions_zh': return '疑問を提起する';
			case 'forum.leafDescriptions.requests_zh': return 'リクエストを投稿する';
			case 'forum.leafDescriptions.support_zh': return 'サイト関連の問題を解決する手助け';
			case 'forum.leafDescriptions.general_ja': return 'あらゆる話題を議論する';
			case 'forum.leafDescriptions.questions_ja': return '疑問を提起する';
			case 'forum.leafDescriptions.requests_ja': return 'リクエストを投稿する';
			case 'forum.leafDescriptions.support_ja': return 'サイト関連の問題を解決する手助け';
			case 'forum.leafDescriptions.korean': return '韓国語に関する議論';
			case 'forum.leafDescriptions.other': return 'その他の未分類のコンテンツ';
			case 'forum.reply': return '回覆';
			case 'forum.pendingReview': return '審査中';
			case 'forum.editedAt': return '編集日時';
			case 'forum.copySuccess': return 'クリップボードにコピーされました';
			case 'forum.copySuccessForMessage': return ({required Object str}) => 'クリップボードにコピーされました: ${str}';
			case 'forum.editReply': return '編集回覆';
			case 'forum.editTitle': return '編集タイトル';
			case 'forum.submit': return '提出';
			case 'notifications.errors.unsupportedNotificationType': return 'サポートされていない通知タイプ';
			case 'notifications.errors.unknownUser': return '未知ユーザー';
			case 'notifications.errors.unsupportedNotificationTypeWithType': return ({required Object type}) => 'サポートされていない通知タイプ: ${type}';
			case 'notifications.errors.unknownNotificationType': return '未知通知タイプ';
			case 'notifications.notifications': return '通知';
			case 'notifications.profile': return '個人主頁';
			case 'notifications.postedNewComment': return '新しいコメントを投稿';
			case 'notifications.inYour': return 'あなたの';
			case 'notifications.video': return 'ビデオ';
			case 'notifications.repliedYourVideoComment': return 'あなたのビデオコメントに返信しました';
			case 'notifications.copyInfoToClipboard': return '通知情報をクリップボードにコピー';
			case 'notifications.copySuccess': return 'クリップボードにコピーされました';
			case 'notifications.copySuccessForMessage': return ({required Object str}) => 'クリップボードにコピーされました: ${str}';
			case 'notifications.markAllAsRead': return '全てを既読にする';
			case 'notifications.markAllAsReadSuccess': return '全ての通知が既読になりました';
			case 'notifications.markAllAsReadFailed': return '全てを既読にするに失敗しました';
			case 'notifications.markSelectedAsRead': return '選択した通知を既読にする';
			case 'notifications.markSelectedAsReadSuccess': return '選択した通知が既読になりました';
			case 'notifications.markSelectedAsReadFailed': return '選択した通知を既読にするに失敗しました';
			case 'notifications.markAsRead': return '既読にする';
			case 'notifications.markAsReadSuccess': return '通知が既読になりました';
			case 'notifications.markAsReadFailed': return '通知を既読にするに失敗しました';
			case 'notifications.notificationTypeHelp': return '通知タイプのヘルプ';
			case 'notifications.dueToLackOfNotificationTypeDetails': return '通知タイプの詳細情報が不足しているため、現在サポートされているタイプが受信したメッセージをカバーしていない可能性があります';
			case 'notifications.helpUsImproveNotificationTypeSupport': return '通知タイプのサポート改善にご協力いただける場合';
			case 'notifications.helpUsImproveNotificationTypeSupportLongText': return '1. 📋 通知情報をコピー\n2. 🐞 プロジェクトリポジトリに issue を提出\n\n⚠️ 注意：通知情報には個人情報が含まれている場合があります。公開したくない場合は、プロジェクト作者にメールで送信することもできます。';
			case 'notifications.goToRepository': return 'リポジトリに移動';
			case 'notifications.copy': return 'コピー';
			case 'notifications.commentApproved': return 'コメントが承認されました';
			case 'notifications.repliedYourProfileComment': return 'あなたの個人主頁コメントに返信しました';
			case 'notifications.kReplied': return 'さんが';
			case 'notifications.kCommented': return 'さんが';
			case 'notifications.kVideo': return 'ビデオ';
			case 'notifications.kGallery': return 'ギャラリー';
			case 'notifications.kProfile': return 'プロフィール';
			case 'notifications.kThread': return 'スレッド';
			case 'notifications.kPost': return '投稿';
			case 'notifications.kCommentSection': return '';
			case 'notifications.kApprovedComment': return 'コメントが承認されました';
			case 'notifications.kApprovedVideo': return '動画が承認されました';
			case 'notifications.kApprovedGallery': return 'ギャラリーが承認されました';
			case 'notifications.kApprovedThread': return 'スレッドが承認されました';
			case 'notifications.kApprovedPost': return '投稿が承認されました';
			case 'notifications.kUnknownType': return '不明な通知タイプ';
			case 'conversation.errors.pleaseSelectAUser': return 'ユーザーを選択してください';
			case 'conversation.errors.pleaseEnterATitle': return 'タイトルを入力してください';
			case 'conversation.errors.clickToSelectAUser': return 'ユーザーを選択してください';
			case 'conversation.errors.loadFailedClickToRetry': return '読み込みに失敗しました。クリックして再試行';
			case 'conversation.errors.loadFailed': return '読み込みに失敗しました';
			case 'conversation.errors.clickToRetry': return 'クリックして再試行';
			case 'conversation.errors.noMoreConversations': return 'もう会話がありません';
			case 'conversation.conversation': return '会話';
			case 'conversation.startConversation': return '会話を開始';
			case 'conversation.noConversation': return '会話がありません';
			case 'conversation.selectFromLeftListAndStartConversation': return '左側の会話リストから会話を選択して開始';
			case 'conversation.title': return 'タイトル';
			case 'conversation.body': return '内容';
			case 'conversation.selectAUser': return 'ユーザーを選択';
			case 'conversation.searchUsers': return 'ユーザーを検索...';
			case 'conversation.tmpNoConversions': return '会話がありません';
			case 'conversation.deleteThisMessage': return 'このメッセージを削除';
			case 'conversation.deleteThisMessageSubtitle': return 'この操作は取り消せません';
			case 'conversation.writeMessageHere': return 'ここにメッセージを入力...';
			case 'conversation.sendMessage': return 'メッセージを送信';
			case 'splash.errors.initializationFailed': return '初期化に失敗しました。アプリを再起動してください';
			case 'splash.preparing': return '準備中...';
			case 'splash.initializing': return '初期化中...';
			case 'splash.loading': return '読み込み中...';
			case 'splash.ready': return '準備完了';
			case 'splash.initializingMessageService': return 'メッセージサービスを初期化中...';
			case 'download.errors.imageModelNotFound': return '画像モデルが見つかりません';
			case 'download.errors.downloadFailed': return 'ダウンロードに失敗しました';
			case 'download.errors.videoInfoNotFound': return 'ビデオ情報が見つかりません';
			case 'download.errors.unknown': return '不明';
			case 'download.errors.downloadTaskAlreadyExists': return 'ダウンロードタスクが既に存在します';
			case 'download.errors.videoAlreadyDownloaded': return 'ビデオはすでにダウンロードされています';
			case 'download.errors.downloadFailedForMessage': return ({required Object errorInfo}) => 'ダウンロードタスクの追加に失敗しました: ${errorInfo}';
			case 'download.errors.userPausedDownload': return 'ユーザーがダウンロードを一時停止';
			case 'download.errors.fileSystemError': return ({required Object errorInfo}) => 'ファイルシステムエラー: ${errorInfo}';
			case 'download.errors.unknownError': return ({required Object errorInfo}) => '不明なエラー: ${errorInfo}';
			case 'download.errors.connectionTimeout': return '接続タイムアウト';
			case 'download.errors.sendTimeout': return '送信タイムアウト';
			case 'download.errors.receiveTimeout': return '受信タイムアウト';
			case 'download.errors.serverError': return ({required Object errorInfo}) => 'サーバーエラー: ${errorInfo}';
			case 'download.errors.unknownNetworkError': return '不明なネットワークエラー';
			case 'download.errors.serviceIsClosing': return 'ダウンロードサービスが閉じています';
			case 'download.errors.partialDownloadFailed': return '部分内容ダウンロード失敗';
			case 'download.errors.noDownloadTask': return 'ダウンロードタスクがありません';
			case 'download.errors.taskNotFoundOrDataError': return 'タスクが見つかりませんまたはデータが正しくありません';
			case 'download.errors.copyDownloadUrlFailed': return 'ダウンロードリンクのコピーに失敗しました';
			case 'download.errors.fileNotFound': return 'ファイルが見つかりません';
			case 'download.errors.openFolderFailed': return 'ファイルフォルダーを開くのに失敗しました';
			case 'download.errors.openFolderFailedWithMessage': return ({required Object message}) => 'ファイルフォルダーを開くのに失敗しました: ${message}';
			case 'download.errors.directoryNotFound': return 'ディレクトリが見つかりません';
			case 'download.errors.copyFailed': return 'コピーに失敗しました';
			case 'download.errors.openFileFailed': return 'ファイルを開くのに失敗しました';
			case 'download.errors.openFileFailedWithMessage': return ({required Object message}) => 'ファイルを開くのに失敗しました: ${message}';
			case 'download.errors.noDownloadSource': return 'ダウンロードソースがありません';
			case 'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded': return 'ダウンロードソースがありません。情報を読み込んだ後、もう一度お試しください。';
			case 'download.errors.noActiveDownloadTask': return 'ダウンロード中のタスクがありません';
			case 'download.errors.noFailedDownloadTask': return '失敗したタスクがありません';
			case 'download.errors.noCompletedDownloadTask': return '完了したタスクがありません';
			case 'download.errors.taskAlreadyCompletedDoNotAdd': return 'タスクはすでに完了しています。再度追加しないでください';
			case 'download.errors.linkExpiredTryAgain': return 'リンクが期限切れです。新しいダウンロードリンクを取得しています';
			case 'download.errors.linkExpiredTryAgainSuccess': return 'リンクが期限切れです。新しいダウンロードリンクを取得しました';
			case 'download.errors.linkExpiredTryAgainFailed': return 'リンクが期限切れです。新しいダウンロードリンクを取得に失敗しました';
			case 'download.errors.taskDeleted': return 'タスクが削除されました';
			case 'download.errors.unsupportedImageFormat': return ({required Object format}) => 'サポートされていない画像形式: ${format}';
			case 'download.errors.deleteFileError': return 'ファイルの削除に失敗しました。ファイルが他のプロセスによって使用されている可能性があります';
			case 'download.errors.deleteTaskError': return 'タスクの削除に失敗しました';
			case 'download.errors.taskNotFound': return 'タスクが見つかりません';
			case 'download.errors.canNotRefreshVideoTask': return 'ビデオタスクの更新に失敗しました';
			case 'download.errors.taskAlreadyProcessing': return 'タスクはすでに処理中です';
			case 'download.errors.failedToLoadTasks': return 'タスクの読み込みに失敗しました';
			case 'download.errors.partialDownloadFailedWithMessage': return ({required Object message}) => '部分ダウンロードに失敗しました: ${message}';
			case 'download.errors.unsupportedImageFormatWithMessage': return ({required Object extension}) => 'サポートされていない画像形式: ${extension}, デバイスにダウンロードして表示することができます';
			case 'download.errors.imageLoadFailed': return '画像の読み込みに失敗しました';
			case 'download.errors.pleaseTryOtherViewer': return '他のビューアーを使用してみてください';
			case 'download.downloadList': return 'ダウンロードリスト';
			case 'download.download': return 'ダウンロード';
			case 'download.forceDeleteTask': return '強制削除タスク';
			case 'download.startDownloading': return 'ダウンロードを開始';
			case 'download.clearAllFailedTasks': return 'すべての失敗タスクをクリア';
			case 'download.clearAllFailedTasksConfirmation': return 'すべての失敗タスクをクリアしますか？\nこれらのタスクのファイルも削除されます。';
			case 'download.clearAllFailedTasksSuccess': return 'すべての失敗タスクをクリアしました';
			case 'download.clearAllFailedTasksError': return '失敗タスクのクリア中にエラーが発生しました';
			case 'download.downloadStatus': return 'ダウンロード状態';
			case 'download.imageList': return '画像リスト';
			case 'download.retryDownload': return '再試行ダウンロード';
			case 'download.notDownloaded': return '未ダウンロード';
			case 'download.downloaded': return 'ダウンロード済み';
			case 'download.waitingForDownload': return 'ダウンロード待機中';
			case 'download.downloadingProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード中 (${downloaded}/${total}枚 ${progress}%)';
			case 'download.downloadingSingleImageProgress': return ({required Object downloaded}) => 'ダウンロード中 (${downloaded}枚)';
			case 'download.pausedProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => 'ダウンロード一時停止中 (${downloaded}/${total}枚 ${progress}%)';
			case 'download.pausedSingleImageProgress': return ({required Object downloaded}) => 'ダウンロード一時停止中 (${downloaded}枚)';
			case 'download.downloadedProgressForImageProgress': return ({required Object total}) => 'ダウンロード完了 (合計${total}枚)';
			case 'download.viewVideoDetail': return 'ビデオ詳細を表示';
			case 'download.viewGalleryDetail': return 'ギャラリー詳細を表示';
			case 'download.moreOptions': return 'もっと操作';
			case 'download.openFile': return 'ファイルを開く';
			case 'download.pause': return '一時停止';
			case 'download.resume': return '継続';
			case 'download.copyDownloadUrl': return 'ダウンロードリンクをコピー';
			case 'download.showInFolder': return 'フォルダーで表示';
			case 'download.deleteTask': return 'タスクを削除';
			case 'download.downloadingProgressForVideoTask': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloadingOnlyDownloadedAndSpeed': return ({required Object downloaded, required Object speed}) => 'ダウンロード中 ${downloaded} • ${speed}MB/s';
			case 'download.pausedForDownloadedAndTotal': return ({required Object downloaded, required Object total, required Object progress}) => '一時停止中 ${downloaded}/${total} (${progress}%)';
			case 'download.pausedAndDownloaded': return ({required Object downloaded}) => '一時停止中 • ダウンロード済み ${downloaded}';
			case 'download.downloadedWithSize': return ({required Object size}) => 'ダウンロード完了 • ${size}';
			case 'download.copyDownloadUrlSuccess': return 'ダウンロードリンクをコピーしました';
			case 'download.totalImageNums': return ({required Object num}) => '${num}枚';
			case 'download.downloadingDownloadedTotalProgressSpeed': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'ダウンロード中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloading': return 'ダウンロード中';
			case 'download.failed': return '失敗';
			case 'download.completed': return '完了';
			case 'download.downloadDetail': return 'ダウンロード詳細';
			case 'download.copy': return 'コピー';
			case 'download.copySuccess': return 'コピーしました';
			case 'download.waiting': return '待機中';
			case 'download.paused': return '一時停止中';
			case 'download.downloadingOnlyDownloaded': return ({required Object downloaded}) => 'ダウンロード中 ${downloaded}';
			case 'download.galleryDownloadCompletedWithName': return ({required Object galleryName}) => 'ギャラリーのダウンロードが完了しました: ${galleryName}';
			case 'download.downloadCompletedWithName': return ({required Object fileName}) => 'ダウンロードが完了しました: ${fileName}';
			case 'download.stillInDevelopment': return '開発中';
			case 'download.saveToAppDirectory': return 'アプリケーションディレクトリに保存';
			case 'favorite.errors.addFailed': return '追加に失敗しました';
			case 'favorite.errors.addSuccess': return '追加に成功しました';
			case 'favorite.errors.deleteFolderFailed': return 'フォルダーの削除に失敗しました';
			case 'favorite.errors.deleteFolderSuccess': return 'フォルダーの削除に成功しました';
			case 'favorite.errors.folderNameCannotBeEmpty': return 'フォルダー名を入力してください';
			case 'favorite.add': return '追加';
			case 'favorite.addSuccess': return '追加に成功しました';
			case 'favorite.addFailed': return '追加に失敗しました';
			case 'favorite.remove': return '削除';
			case 'favorite.removeSuccess': return '削除に成功しました';
			case 'favorite.removeFailed': return '削除に失敗しました';
			case 'favorite.removeConfirmation': return 'このアイテムをお気に入りから削除しますか？';
			case 'favorite.removeConfirmationSuccess': return 'アイテムがお気に入りから削除されました';
			case 'favorite.removeConfirmationFailed': return 'アイテムをお気に入りから削除に失敗しました';
			case 'favorite.createFolderSuccess': return 'フォルダーが作成されました';
			case 'favorite.createFolderFailed': return 'フォルダーの作成に失敗しました';
			case 'favorite.createFolder': return 'フォルダーを作成';
			case 'favorite.enterFolderName': return 'フォルダー名を入力';
			case 'favorite.enterFolderNameHere': return 'フォルダー名を入力してください...';
			case 'favorite.create': return '作成';
			case 'favorite.items': return 'アイテム';
			case 'favorite.newFolderName': return '新しいフォルダー';
			case 'favorite.searchFolders': return 'フォルダーを検索...';
			case 'favorite.searchItems': return 'アイテムを検索...';
			case 'favorite.createdAt': return '作成日時';
			case 'favorite.myFavorites': return 'お気に入り';
			case 'favorite.deleteFolderTitle': return 'フォルダーを削除';
			case 'favorite.deleteFolderConfirmWithTitle': return ({required Object title}) => '${title} フォルダーを削除しますか？';
			case 'favorite.removeItemTitle': return 'アイテムを削除';
			case 'favorite.removeItemConfirmWithTitle': return ({required Object title}) => '${title} アイテムを削除しますか？';
			case 'favorite.removeItemSuccess': return 'アイテムがお気に入りから削除されました';
			case 'favorite.removeItemFailed': return 'アイテムをお気に入りから削除に失敗しました';
			case 'favorite.localizeFavorite': return 'ローカライズお気に入り';
			case 'favorite.editFolderTitle': return 'フォルダー名を編集';
			case 'favorite.editFolderSuccess': return 'フォルダー名を更新しました';
			case 'favorite.editFolderFailed': return 'フォルダー名の更新に失敗しました';
			case 'favorite.searchTags': return 'タグを検索';
			case 'translation.testConnection': return 'テスト接続';
			case 'translation.testConnectionSuccess': return 'テスト接続成功';
			case 'translation.testConnectionFailed': return 'テスト接続失敗';
			case 'translation.testConnectionFailedWithMessage': return ({required Object message}) => 'テスト接続失敗: ${message}';
			case 'translation.translation': return '翻訳';
			case 'translation.needVerification': return '検証が必要です';
			case 'translation.needVerificationContent': return 'まず接続テストを行ってからAI翻訳を有効にしてください';
			case 'translation.confirm': return '確定';
			case 'translation.disclaimer': return '使用須知';
			case 'translation.riskWarning': return '風險提示';
			case 'translation.dureToRisk1': return 'ユーザーが生成したテキストが原因で、AIサービスプロバイダーのコンテンツポリシーに違反する内容が含まれる場合があります';
			case 'translation.dureToRisk2': return '不当なコンテンツはAPIキーの停止やサービスの終了を引き起こす可能性があります';
			case 'translation.operationSuggestion': return '操作推奨';
			case 'translation.operationSuggestion1': return '1. 翻訳前に内容を厳格に審査してください';
			case 'translation.operationSuggestion2': return '2. 暴力、成人向けコンテンツなどを翻訳しないでください';
			case 'translation.apiConfig': return 'API設定';
			case 'translation.modifyConfigWillAutoCloseAITranslation': return '設定を変更するとAI翻訳が自動的に閉じられます。再度開くには接続テストを行ってください';
			case 'translation.apiAddress': return 'APIアドレス';
			case 'translation.modelName': return 'モデル名';
			case 'translation.modelNameHintText': return '例：gpt-4-turbo';
			case 'translation.maxTokens': return '最大トークン数';
			case 'translation.maxTokensHintText': return '例：1024';
			case 'translation.temperature': return '温度係数';
			case 'translation.temperatureHintText': return '0.0-2.0';
			case 'translation.clickTestButtonToVerifyAPIConnection': return 'テストボタンをクリックしてAPI接続を検証';
			case 'translation.requestPreview': return 'リクエストプレビュー';
			case 'translation.enableAITranslation': return 'AI翻訳';
			case 'translation.enabled': return '有効';
			case 'translation.disabled': return '無効';
			case 'translation.testing': return 'テスト中...';
			case 'translation.testNow': return '今すぐテスト';
			case 'translation.connectionStatus': return '接続状態';
			case 'translation.success': return '成功';
			case 'translation.failed': return '失敗';
			case 'translation.information': return '情報';
			case 'translation.viewRawResponse': return '生の応答を表示';
			case 'translation.pleaseCheckInputParametersFormat': return '入力パラメーターの形式を確認してください';
			case 'translation.pleaseFillInAPIAddressModelNameAndKey': return 'APIアドレス、モデル名、およびキーを入力してください';
			case 'translation.pleaseFillInValidConfigurationParameters': return '有効な設定パラメーターを入力してください';
			case 'translation.pleaseCompleteConnectionTest': return '接続テストを完了してください';
			case 'translation.notConfigured': return '未設定';
			case 'translation.apiEndpoint': return 'APIエンドポイント';
			case 'translation.configuredKey': return '設定済みキー';
			case 'translation.notConfiguredKey': return '未設定キー';
			case 'translation.authenticationStatus': return '認証状態';
			case 'translation.thisFieldCannotBeEmpty': return 'このフィールドは空にできません';
			case 'translation.apiKey': return 'APIキー';
			case 'translation.apiKeyCannotBeEmpty': return 'APIキーは空にできません';
			case 'translation.pleaseEnterValidNumber': return '有効な数値を入力してください';
			case 'translation.range': return '範囲';
			case 'translation.mustBeGreaterThan': return '以上';
			case 'translation.invalidAPIResponse': return '無効なAPI応答';
			case 'translation.connectionFailedForMessage': return ({required Object message}) => '接続失敗: ${message}';
			case 'translation.aiTranslationNotEnabledHint': return 'AI翻訳は有効にされていません。設定で有効にしてください';
			case 'translation.goToSettings': return '設定に移動';
			case 'translation.disableAITranslation': return 'AI翻訳を無効にする';
			case 'translation.currentValue': return '現在値';
			case 'translation.configureTranslationStrategy': return '翻訳戦略を設定';
			case 'translation.advancedSettings': return '高度な設定';
			case 'translation.translationPrompt': return '翻訳プロンプト';
			case 'translation.promptHint': return '翻訳プロンプトを入力してください。[TL]を目標言語のプレースホルダーとして使用します';
			case 'translation.promptHelperText': return 'プロンプトには[TL]を目標言語のプレースホルダーとして含めてください';
			case 'translation.promptMustContainTargetLang': return 'プロンプトには[TL]プレースホルダーを含めてください';
			case 'translation.aiTranslationWillBeDisabled': return 'AI翻訳が自動的に無効にされます';
			case 'translation.aiTranslationWillBeDisabledDueToConfigChange': return '基本設定を変更したため、AI翻訳が自動的に無効にされます';
			case 'translation.aiTranslationWillBeDisabledDueToPromptChange': return '翻訳プロンプトを変更したため、AI翻訳が自動的に無効にされます';
			case 'translation.aiTranslationWillBeDisabledDueToParamChange': return 'パラメーター設定を変更したため、AI翻訳が自動的に無効にされます';
			case 'translation.onlyOpenAIAPISupported': return '現在、OpenAI互換のAPI形式（application/jsonリクエストボディ形式）のみサポートされています';
			case 'translation.streamingTranslation': return 'ストリーミング翻訳';
			case 'translation.streamingTranslationSupported': return 'ストリーミング翻訳対応';
			case 'translation.streamingTranslationNotSupported': return 'ストリーミング翻訳非対応';
			case 'translation.streamingTranslationDescription': return 'ストリーミング翻訳は翻訳プロセス中にリアルタイムで結果を表示し、より良いユーザー体験を提供します';
			case 'translation.baseUrlInputHelperText': return '末尾が#の場合、入力されたURLを実際のリクエストアドレスとして使用します';
			case 'translation.currentActualUrl': return ({required Object url}) => '現在の実際のURL: ${url}';
			case 'translation.usingFullUrlWithHash': return '完全なURL（#で終わる）を使用';
			case 'translation.urlEndingWithHashTip': return 'URLが#で終わる場合、入力されたURLを実際のリクエストアドレスとして使用します';
			case 'translation.streamingTranslationWarning': return '注意：この機能はAPIサービスがストリーミング伝送をサポートする必要があり、一部のモデルではサポートされていない場合があります';
			case 'linkInputDialog.title': return 'リンクを入力';
			case 'linkInputDialog.supportedLinksHint': return ({required Object webName}) => '複数の${webName}リンクをインテリジェントに識別し、アプリ内の対応するページにすばやくジャンプすることをサポートします（リンクと他のテキストはスペースで区切ります）';
			case 'linkInputDialog.inputHint': return ({required Object webName}) => '${webName}リンクを入力してください';
			case 'linkInputDialog.validatorEmptyLink': return 'リンクを入力してください';
			case 'linkInputDialog.validatorNoIwaraLink': return ({required Object webName}) => '有効な${webName}リンクが検出されませんでした';
			case 'linkInputDialog.multipleLinksDetected': return '複数のリンクが検出されました。1つ選択してください：';
			case 'linkInputDialog.notIwaraLink': return ({required Object webName}) => '有効な${webName}リンクではありません';
			case 'linkInputDialog.linkParseError': return ({required Object error}) => 'リンク解析エラー: ${error}';
			case 'linkInputDialog.unsupportedLinkDialogTitle': return 'サポートされていないリンク';
			case 'linkInputDialog.unsupportedLinkDialogContent': return 'このリンクタイプは現在アプリ内で直接開くことができず、外部ブラウザを使用してアクセスする必要があります。\n\nブラウザでこのリンクを開きますか？';
			case 'linkInputDialog.openInBrowser': return 'ブラウザで開く';
			case 'linkInputDialog.confirmOpenBrowserDialogTitle': return 'ブラウザを開くことを確認';
			case 'linkInputDialog.confirmOpenBrowserDialogContent': return '次のリンクを外部ブラウザで開こうとしています：';
			case 'linkInputDialog.confirmContinueBrowserOpen': return '続行してもよろしいですか？';
			case 'linkInputDialog.browserOpenFailed': return 'リンクを開けませんでした';
			case 'linkInputDialog.unsupportedLink': return 'サポートされていないリンク';
			case 'linkInputDialog.cancel': return 'キャンセル';
			case 'linkInputDialog.confirm': return 'ブラウザで開く';
			case 'log.logManagement': return 'ログ管理';
			case 'log.enableLogPersistence': return 'ログ保存を有効にする';
			case 'log.enableLogPersistenceDesc': return 'ログをデータベースに保存して分析に使用';
			case 'log.logDatabaseSizeLimit': return 'ログデータベースサイズ上限';
			case 'log.logDatabaseSizeLimitDesc': return ({required Object size}) => '現在: ${size}';
			case 'log.exportCurrentLogs': return '現在のログをエクスポート';
			case 'log.exportCurrentLogsDesc': return '現在のアプリケーションログを開発者が診断に使用できるようにエクスポート';
			case 'log.exportHistoryLogs': return '履歴ログをエクスポート';
			case 'log.exportHistoryLogsDesc': return '指定された日付範囲内のログをエクスポート';
			case 'log.exportMergedLogs': return 'マージログをエクスポート';
			case 'log.exportMergedLogsDesc': return '指定された日付範囲内のマージログをエクスポート';
			case 'log.showLogStats': return 'ログ統計情報を表示';
			case 'log.logExportSuccess': return 'ログエクスポート成功';
			case 'log.logExportFailed': return ({required Object error}) => 'ログエクスポート失敗: ${error}';
			case 'log.showLogStatsDesc': return '様々なタイプのログの統計情報を表示';
			case 'log.logExtractFailed': return ({required Object error}) => 'ログ統計情報の取得に失敗しました: ${error}';
			case 'log.clearAllLogs': return 'すべてのログをクリア';
			case 'log.clearAllLogsDesc': return 'すべてのログデータをクリア';
			case 'log.confirmClearAllLogs': return '確認クリア';
			case 'log.confirmClearAllLogsDesc': return 'すべてのログデータをクリアしますか？この操作は元に戻すことができません';
			case 'log.clearAllLogsSuccess': return 'ログクリア成功';
			case 'log.clearAllLogsFailed': return ({required Object error}) => 'ログクリア失敗: ${error}';
			case 'log.unableToGetLogSizeInfo': return 'ログサイズ情報を取得できません';
			case 'log.currentLogSize': return '現在のログサイズ:';
			case 'log.logCount': return 'ログ数:';
			case 'log.logCountUnit': return 'ログ';
			case 'log.logSizeLimit': return 'ログサイズ上限:';
			case 'log.usageRate': return '使用率:';
			case 'log.exceedLimit': return '超過';
			case 'log.remaining': return '残り';
			case 'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit': return '現在のログサイズが超過しています。古いログをクリアするか、ログサイズ上限を増加してください';
			case 'log.currentLogSizeAlmostExceededPleaseCleanOldLogs': return '現在のログサイズがほぼ超過しています。古いログをクリアしてください';
			case 'log.cleaningOldLogs': return '古いログを自動的にクリアしています...';
			case 'log.logCleaningCompleted': return 'ログクリアが完了しました';
			case 'log.logCleaningProcessMayNotBeCompleted': return 'ログクリア過程が完了しない可能性があります';
			case 'log.cleanExceededLogs': return '超過ログをクリア';
			case 'log.noLogsToExport': return 'エクスポート可能なログデータがありません';
			case 'log.exportingLogs': return 'ログをエクスポートしています...';
			case 'log.noHistoryLogsToExport': return '履歴ログをエクスポートするのに十分なデータがありません。アプリを使用してからしばらくしてから再試行してください';
			case 'log.selectLogDate': return 'ログ日付を選択';
			case 'log.today': return '今日';
			case 'log.selectMergeRange': return 'マージ範囲を選択';
			case 'log.selectMergeRangeHint': return 'マージするログの日付範囲を選択してください';
			case 'log.selectMergeRangeDays': return ({required Object days}) => '最近 ${days} 日';
			case 'log.logStats': return 'ログ統計情報';
			case 'log.todayLogs': return ({required Object count}) => '今日のログ: ${count} 件';
			case 'log.recent7DaysLogs': return ({required Object count}) => '最近7日のログ: ${count} 件';
			case 'log.totalLogs': return ({required Object count}) => '合計ログ: ${count} 件';
			case 'log.setLogDatabaseSizeLimit': return 'ログデータベースサイズ上限を設定';
			case 'log.currentLogSizeWithSize': return ({required Object size}) => '現在のログサイズ: ${size}';
			case 'log.warning': return '警告';
			case 'log.newSizeLimit': return ({required Object size}) => '新しいサイズ上限: ${size}';
			case 'log.confirmToContinue': return '続行してもよろしいですか？';
			case 'log.logSizeLimitSetSuccess': return ({required Object size}) => 'ログサイズ上限を ${size} に設定しました';
			default: return null;
		}
	}
}

