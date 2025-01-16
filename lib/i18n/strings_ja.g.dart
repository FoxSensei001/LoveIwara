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
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
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
	@override String get errorOccurred => 'エラーが発生しました。後でもう一度お試しください';
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
	@override String get searchTags => 'タグを検索...';
	@override String get contentRating => 'コンテンツ評価';
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
			case 'errors.errorOccurred': return 'エラーが発生しました。後でもう一度お試しください';
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
			case 'friends.clickToRestoreFriend': return '友達を復元するにはクリックしてください';
			case 'friends.friendsList': return '友達リスト';
			case 'friends.friendRequests': return '友達リクエスト';
			case 'friends.friendRequestsList': return '友達リクエスト一覧';
			case 'authorProfile.noMoreDatas': return 'これ以上データはありません';
			case 'authorProfile.userProfile': return 'ユーザープロフィール';
			case 'favorites.clickToRestoreFavorite': return 'お気に入りを復元するにはクリックしてください';
			case 'favorites.myFavorites': return '私のお気に入り';
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
			case 'search.searchTags': return 'タグを検索...';
			case 'search.contentRating': return 'コンテンツ評価';
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
			case 'mediaList.personalIntroduction': return '個人紹介';
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
			case 'share.sharePlayList': return 'プレイリストを共有';
			case 'share.wowDidYouSeeThis': return 'ああ、見たの？';
			case 'share.nameIs': return '名前は';
			case 'share.clickLinkToView': return 'リンクをクリックして見る';
			case 'share.iReallyLikeThis': return '本当に好きです';
			case 'share.shareFailed': return '共有に失敗しました。後でもう一度お試しください';
			case 'share.share': return '共有';
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
			default: return null;
		}
	}
}

