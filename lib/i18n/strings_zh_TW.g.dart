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
class TranslationsZhTw implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhTw({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhTw,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-TW>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZhTw _root = this; // ignore: unused_field

	@override 
	TranslationsZhTw $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhTw(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonZhTw common = _TranslationsCommonZhTw._(_root);
	@override late final _TranslationsAuthZhTw auth = _TranslationsAuthZhTw._(_root);
	@override late final _TranslationsErrorsZhTw errors = _TranslationsErrorsZhTw._(_root);
	@override late final _TranslationsFriendsZhTw friends = _TranslationsFriendsZhTw._(_root);
	@override late final _TranslationsAuthorProfileZhTw authorProfile = _TranslationsAuthorProfileZhTw._(_root);
	@override late final _TranslationsFavoritesZhTw favorites = _TranslationsFavoritesZhTw._(_root);
	@override late final _TranslationsGalleryDetailZhTw galleryDetail = _TranslationsGalleryDetailZhTw._(_root);
	@override late final _TranslationsPlayListZhTw playList = _TranslationsPlayListZhTw._(_root);
	@override late final _TranslationsSearchZhTw search = _TranslationsSearchZhTw._(_root);
	@override late final _TranslationsMediaListZhTw mediaList = _TranslationsMediaListZhTw._(_root);
	@override late final _TranslationsSettingsZhTw settings = _TranslationsSettingsZhTw._(_root);
	@override late final _TranslationsOreno3dZhTw oreno3d = _TranslationsOreno3dZhTw._(_root);
	@override late final _TranslationsSignInZhTw signIn = _TranslationsSignInZhTw._(_root);
	@override late final _TranslationsSubscriptionsZhTw subscriptions = _TranslationsSubscriptionsZhTw._(_root);
	@override late final _TranslationsVideoDetailZhTw videoDetail = _TranslationsVideoDetailZhTw._(_root);
	@override late final _TranslationsShareZhTw share = _TranslationsShareZhTw._(_root);
	@override late final _TranslationsMarkdownZhTw markdown = _TranslationsMarkdownZhTw._(_root);
	@override late final _TranslationsForumZhTw forum = _TranslationsForumZhTw._(_root);
	@override late final _TranslationsNotificationsZhTw notifications = _TranslationsNotificationsZhTw._(_root);
	@override late final _TranslationsConversationZhTw conversation = _TranslationsConversationZhTw._(_root);
	@override late final _TranslationsSplashZhTw splash = _TranslationsSplashZhTw._(_root);
	@override late final _TranslationsDownloadZhTw download = _TranslationsDownloadZhTw._(_root);
	@override late final _TranslationsFavoriteZhTw favorite = _TranslationsFavoriteZhTw._(_root);
	@override late final _TranslationsTranslationZhTw translation = _TranslationsTranslationZhTw._(_root);
	@override late final _TranslationsMediaPlayerZhTw mediaPlayer = _TranslationsMediaPlayerZhTw._(_root);
	@override late final _TranslationsLinkInputDialogZhTw linkInputDialog = _TranslationsLinkInputDialogZhTw._(_root);
	@override late final _TranslationsLogZhTw log = _TranslationsLogZhTw._(_root);
}

// Path: common
class _TranslationsCommonZhTw implements TranslationsCommonEn {
	_TranslationsCommonZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Love Iwara';
	@override String get ok => '確定';
	@override String get cancel => '取消';
	@override String get save => '儲存';
	@override String get delete => '刪除';
	@override String get visit => '訪問';
	@override String get loading => '載入中...';
	@override String get scrollToTop => '滾動到頂部';
	@override String get privacyHint => '隱私內容，不與展示';
	@override String get latest => '最新';
	@override String get likesCount => '按讚數';
	@override String get viewsCount => '觀看次數';
	@override String get popular => '受歡迎的';
	@override String get trending => '趨勢';
	@override String get commentList => '評論列表';
	@override String get sendComment => '發表評論';
	@override String get send => '發表';
	@override String get retry => '重試';
	@override String get premium => '高級會員';
	@override String get follower => '粉絲';
	@override String get friend => '朋友';
	@override String get video => '影片';
	@override String get following => '追蹤中';
	@override String get expand => '展開';
	@override String get collapse => '收起';
	@override String get cancelFriendRequest => '取消申請';
	@override String get cancelSpecialFollow => '取消特別關注';
	@override String get addFriend => '加為朋友';
	@override String get removeFriend => '解除朋友';
	@override String get followed => '已追蹤';
	@override String get follow => '追蹤';
	@override String get unfollow => '取消追蹤';
	@override String get specialFollow => '特別關注';
	@override String get specialFollowed => '已特別關注';
	@override String get gallery => '圖庫';
	@override String get playlist => '播放清單';
	@override String get commentPostedSuccessfully => '評論發表成功';
	@override String get commentPostedFailed => '評論發表失敗';
	@override String get success => '成功';
	@override String get commentDeletedSuccessfully => '評論已刪除';
	@override String get commentUpdatedSuccessfully => '評論已更新';
	@override String totalComments({required Object count}) => '評論 ${count} 則';
	@override String get writeYourCommentHere => '請寫下你的評論...';
	@override String get tmpNoReplies => '暫無回覆';
	@override String get loadMore => '載入更多';
	@override String get noMoreDatas => '沒有更多資料了';
	@override String get selectTranslationLanguage => '選擇翻譯語言';
	@override String get translate => '翻譯';
	@override String get translateFailedPleaseTryAgainLater => '翻譯失敗，請稍後再試';
	@override String get translationResult => '翻譯結果';
	@override String get justNow => '剛剛';
	@override String minutesAgo({required Object num}) => '${num} 分鐘前';
	@override String hoursAgo({required Object num}) => '${num} 小時前';
	@override String daysAgo({required Object num}) => '${num} 天前';
	@override String editedAt({required Object num}) => '${num} 編輯';
	@override String get editComment => '編輯評論';
	@override String get commentUpdated => '評論已更新';
	@override String get replyComment => '回覆評論';
	@override String get reply => '回覆';
	@override String get edit => '編輯';
	@override String get unknownUser => '未知使用者';
	@override String get me => '我';
	@override String get author => '作者';
	@override String get admin => '管理員';
	@override String viewReplies({required Object num}) => '查看回覆 (${num})';
	@override String get hideReplies => '隱藏回覆';
	@override String get confirmDelete => '確認刪除';
	@override String get areYouSureYouWantToDeleteThisItem => '確定要刪除這筆資料嗎？';
	@override String get tmpNoComments => '暫無評論';
	@override String get refresh => '更新';
	@override String get back => '返回';
	@override String get tips => '提示';
	@override String get linkIsEmpty => '連結地址為空';
	@override String get linkCopiedToClipboard => '連結地址已複製到剪貼簿';
	@override String get imageCopiedToClipboard => '圖片已複製到剪貼簿';
	@override String get copyImageFailed => '複製圖片失敗';
	@override String get mobileSaveImageIsUnderDevelopment => '移動端的儲存圖片功能尚在開發中';
	@override String get imageSavedTo => '圖片已儲存至';
	@override String get saveImageFailed => '儲存圖片失敗';
	@override String get close => '關閉';
	@override String get more => '更多';
	@override String get moreFeaturesToBeDeveloped => '更多功能待開發';
	@override String get all => '全部';
	@override String selectedRecords({required Object num}) => '已選擇 ${num} 筆資料';
	@override String get cancelSelectAll => '取消全選';
	@override String get selectAll => '全選';
	@override String get exitEditMode => '退出編輯模式';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '確定要刪除選中的 ${num} 筆資料嗎？';
	@override String get searchHistoryRecords => '搜尋歷史紀錄...';
	@override String get settings => '設定';
	@override String get subscriptions => '訂閱';
	@override String videoCount({required Object num}) => '${num} 支影片';
	@override String get share => '分享';
	@override String get areYouSureYouWantToShareThisPlaylist => '要分享這個播放清單嗎？';
	@override String get editTitle => '編輯標題';
	@override String get editMode => '編輯模式';
	@override String get pleaseEnterNewTitle => '請輸入新標題';
	@override String get createPlayList => '創建播放清單';
	@override String get create => '創建';
	@override String get checkNetworkSettings => '檢查網路設定';
	@override String get general => '大眾';
	@override String get r18 => 'R18';
	@override String get sensitive => '敏感';
	@override String get year => '年份';
	@override String get month => '月份';
	@override String get tag => '標籤';
	@override String get private => '私密';
	@override String get noTitle => '無標題';
	@override String get search => '搜尋';
	@override String get noContent => '沒有內容哦';
	@override String get recording => '記錄中';
	@override String get paused => '已暫停';
	@override String get clear => '清除';
	@override String get user => '使用者';
	@override String get post => '投稿';
	@override String get seconds => '秒';
	@override String get comingSoon => '敬請期待';
	@override String get confirm => '確認';
	@override String get hour => '小時';
	@override String get minute => '分鐘';
	@override String get clickToRefresh => '點擊更新';
	@override String get history => '歷史紀錄';
	@override String get favorites => '最愛';
	@override String get friends => '朋友';
	@override String get playList => '播放清單';
	@override String get checkLicense => '查看授權';
	@override String get logout => '登出';
	@override String get fensi => '粉絲';
	@override String get accept => '接受';
	@override String get reject => '拒絕';
	@override String get clearAllHistory => '清空所有歷史紀錄';
	@override String get clearAllHistoryConfirm => '確定要清空所有歷史紀錄嗎？';
	@override String get followingList => '追蹤中列表';
	@override String get followersList => '粉絲列表';
	@override String get follows => '追蹤';
	@override String get fans => '粉絲';
	@override String get followsAndFans => '追蹤與粉絲';
	@override String get numViews => '觀看次數';
	@override String get updatedAt => '更新時間';
	@override String get publishedAt => '發布時間';
	@override String get download => '下載';
	@override String get selectQuality => '選擇畫質';
	@override String get externalVideo => '站外影片';
	@override String get originalText => '原文';
	@override String get showOriginalText => '顯示原始文本';
	@override String get showProcessedText => '顯示處理後文本';
	@override String get preview => '預覽';
	@override String get rules => '規則';
	@override String get agree => '同意';
	@override String get disagree => '不同意';
	@override String get agreeToRules => '同意規則';
	@override String get createPost => '創建投稿';
	@override String get title => '標題';
	@override String get enterTitle => '請輸入標題';
	@override String get content => '內容';
	@override String get enterContent => '請輸入內容';
	@override String get writeYourContentHere => '請輸入內容...';
	@override String get tagBlacklist => '黑名單標籤';
	@override String get noData => '沒有資料';
	@override String get tagLimit => '標籤上限';
	@override String get enableFloatingButtons => '啟用浮動按鈕';
	@override String get disableFloatingButtons => '禁用浮動按鈕';
	@override String get enabledFloatingButtons => '已啟用浮動按鈕';
	@override String get disabledFloatingButtons => '已禁用浮動按鈕';
	@override String get pendingCommentCount => '待審核評論';
	@override String joined({required Object str}) => '加入於 ${str}';
	@override String get selectDateRange => '選擇日期範圍';
	@override String get selectDateRangeHint => '選擇日期範圍，默認選擇最近30天';
	@override String get clearDateRange => '清除日期範圍';
	@override String get followSuccessClickAgainToSpecialFollow => '已成功關注，再次點擊以特別關注';
	@override String get exitConfirmTip => '確定要退出嗎？';
	@override String get error => '錯誤';
	@override String get taskRunning => '任務正在進行中，請稍後再試。';
	@override String get operationCancelled => '操作已取消。';
	@override String get unsavedChanges => '您有未儲存的更改';
	@override String get specialFollowsManagementTip => '拖動可重新排序 • 向左滑動可移除';
	@override String get specialFollowsManagement => '特別關注管理';
	@override late final _TranslationsCommonPaginationZhTw pagination = _TranslationsCommonPaginationZhTw._(_root);
	@override String get notice => '通知';
	@override String get detail => '詳情';
	@override String get parseExceptionDestopHint => ' - 桌面端用戶可以在設置中配置代理';
	@override String get iwaraTags => 'Iwara 標籤';
	@override String get likeThisVideo => '喜歡這個影片的人';
	@override String get operation => '操作';
	@override String get replies => '回覆';
}

// Path: auth
class _TranslationsAuthZhTw implements TranslationsAuthEn {
	_TranslationsAuthZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get login => '登入';
	@override String get logout => '登出';
	@override String get email => '電子郵件';
	@override String get password => '密碼';
	@override String get loginOrRegister => '登入 / 註冊';
	@override String get register => '註冊';
	@override String get pleaseEnterEmail => '請輸入電子郵件';
	@override String get pleaseEnterPassword => '請輸入密碼';
	@override String get passwordMustBeAtLeast6Characters => '密碼至少需要 6 位';
	@override String get pleaseEnterCaptcha => '請輸入驗證碼';
	@override String get captcha => '驗證碼';
	@override String get refreshCaptcha => '更新驗證碼';
	@override String get captchaNotLoaded => '無法載入驗證碼';
	@override String get loginSuccess => '登入成功';
	@override String get emailVerificationSent => '已發送郵件驗證指令';
	@override String get notLoggedIn => '尚未登入';
	@override String get clickToLogin => '點擊此處登入';
	@override String get logoutConfirmation => '你確定要登出嗎？';
	@override String get logoutSuccess => '登出成功';
	@override String get logoutFailed => '登出失敗';
	@override String get usernameOrEmail => '用戶名或電子郵件';
	@override String get pleaseEnterUsernameOrEmail => '請輸入用戶名或電子郵件';
	@override String get rememberMe => '記住帳號密碼';
}

// Path: errors
class _TranslationsErrorsZhTw implements TranslationsErrorsEn {
	_TranslationsErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get error => '錯誤';
	@override String get required => '此項為必填';
	@override String get invalidEmail => '電子郵件格式錯誤';
	@override String get networkError => '網路錯誤，請重試';
	@override String get errorWhileFetching => '取得資料失敗';
	@override String get commentCanNotBeEmpty => '評論內容不能為空';
	@override String get errorWhileFetchingReplies => '取得回覆時出錯，請檢查網路連線';
	@override String get canNotFindCommentController => '無法找到評論控制器';
	@override String get errorWhileLoadingGallery => '載入圖庫時出錯';
	@override String get howCouldThereBeNoDataItCantBePossible => '啊？怎麼會沒有資料呢？出錯了吧 :<';
	@override String unsupportedImageFormat({required Object str}) => '不支援的圖片格式: ${str}';
	@override String get invalidGalleryId => '無效的圖庫ID';
	@override String get translationFailedPleaseTryAgainLater => '翻譯失敗，請稍後再試';
	@override String get errorOccurred => '發生錯誤，請稍後再試。';
	@override String get errorOccurredWhileProcessingRequest => '處理請求時出錯';
	@override String get errorWhileFetchingDatas => '取得資料時出錯，請稍後再試';
	@override String get serviceNotInitialized => '服務未初始化';
	@override String get unknownType => '未知類型';
	@override String errorWhileOpeningLink({required Object link}) => '無法開啟連結: ${link}';
	@override String get invalidUrl => '無效的URL';
	@override String get failedToOperate => '操作失敗';
	@override String get permissionDenied => '權限不足';
	@override String get youDoNotHavePermissionToAccessThisResource => '您沒有權限訪問此資源';
	@override String get loginFailed => '登入失敗';
	@override String get unknownError => '未知錯誤';
	@override String get sessionExpired => '會話已過期';
	@override String get failedToFetchCaptcha => '獲取驗證碼失敗';
	@override String get emailAlreadyExists => '電子郵件已存在';
	@override String get invalidCaptcha => '無效的驗證碼';
	@override String get registerFailed => '註冊失敗';
	@override String get failedToFetchComments => '獲取評論失敗';
	@override String get failedToFetchImageDetail => '獲取圖庫詳情失敗';
	@override String get failedToFetchImageList => '獲取圖庫列表失敗';
	@override String get failedToFetchData => '獲取資料失敗';
	@override String get invalidParameter => '無效的參數';
	@override String get pleaseLoginFirst => '請先登入';
	@override String get errorWhileLoadingPost => '載入投稿內容時出錯';
	@override String get errorWhileLoadingPostDetail => '載入投稿詳情時出錯';
	@override String get invalidPostId => '無效的投稿ID';
	@override String get forceUpdateNotPermittedToGoBack => '目前處於強制更新狀態，無法返回';
	@override String get pleaseLoginAgain => '請重新登入';
	@override String get invalidLogin => '登入失敗，請檢查電子郵件和密碼';
	@override String get tooManyRequests => '請求過多，請稍後再試';
	@override String exceedsMaxLength({required Object max}) => '超出最大長度: ${max}';
	@override String get contentCanNotBeEmpty => '內容不能為空';
	@override String get titleCanNotBeEmpty => '標題不能為空';
	@override String get tooManyRequestsPleaseTryAgainLaterText => '請求過多，請稍後再試，剩餘時間';
	@override String remainingHours({required Object num}) => '${num}小時';
	@override String remainingMinutes({required Object num}) => '${num}分';
	@override String remainingSeconds({required Object num}) => '${num}秒';
	@override String tagLimitExceeded({required Object limit}) => '標籤上限超出，上限: ${limit}';
	@override String get failedToRefresh => '更新失敗';
	@override String get noPermission => '權限不足';
	@override String get resourceNotFound => '資源不存在';
	@override String get failedToSaveCredentials => '無法安全保存登入資訊';
	@override String get failedToLoadSavedCredentials => '載入保存的登入資訊失敗';
	@override String specialFollowLimitReached({required Object cnt}) => '特別關注上限超出，上限: ${cnt}，請於關注列表頁中調整';
	@override String get notFound => '內容不存在或已被刪除';
	@override late final _TranslationsErrorsNetworkZhTw network = _TranslationsErrorsNetworkZhTw._(_root);
}

// Path: friends
class _TranslationsFriendsZhTw implements TranslationsFriendsEn {
	_TranslationsFriendsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => '點擊恢復朋友';
	@override String get friendsList => '朋友列表';
	@override String get friendRequests => '朋友請求';
	@override String get friendRequestsList => '朋友請求列表';
	@override String get removingFriend => '正在解除好友關係...';
	@override String get failedToRemoveFriend => '解除好友關係失敗';
	@override String get cancelingRequest => '正在取消好友申請...';
	@override String get failedToCancelRequest => '取消好友申請失敗';
}

// Path: authorProfile
class _TranslationsAuthorProfileZhTw implements TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => '沒有更多資料了';
	@override String get userProfile => '使用者資料';
}

// Path: favorites
class _TranslationsFavoritesZhTw implements TranslationsFavoritesEn {
	_TranslationsFavoritesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => '點擊恢復最愛';
	@override String get myFavorites => '我的最愛';
}

// Path: galleryDetail
class _TranslationsGalleryDetailZhTw implements TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get galleryDetail => '圖庫詳情';
	@override String get viewGalleryDetail => '查看圖庫詳情';
	@override String get copyLink => '複製連結地址';
	@override String get copyImage => '複製圖片';
	@override String get saveAs => '另存為';
	@override String get saveToAlbum => '儲存到相簿';
	@override String get publishedAt => '發布時間';
	@override String get viewsCount => '觀看次數';
	@override String get imageLibraryFunctionIntroduction => '圖庫功能介紹';
	@override String get rightClickToSaveSingleImage => '右鍵儲存單張圖片';
	@override String get batchSave => '批次儲存';
	@override String get keyboardLeftAndRightToSwitch => '鍵盤左右控制切換';
	@override String get keyboardUpAndDownToZoom => '鍵盤上下控制縮放';
	@override String get mouseWheelToSwitch => '滑鼠滾輪控制切換';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + 滑鼠滾輪控制縮放';
	@override String get moreFeaturesToBeDiscovered => '更多功能待發掘...';
	@override String get authorOtherGalleries => '作者的其他圖庫';
	@override String get relatedGalleries => '相關圖庫';
	@override String get clickLeftAndRightEdgeToSwitchImage => '點擊左右邊緣以切換圖片';
}

// Path: playList
class _TranslationsPlayListZhTw implements TranslationsPlayListEn {
	_TranslationsPlayListZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => '我的播放清單';
	@override String get friendlyTips => '友情提示';
	@override String get dearUser => '親愛的使用者';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'iwara的播放清單系統目前還不太完善';
	@override String get notSupportSetCover => '不支援設定封面';
	@override String get notSupportDeleteList => '無法刪除播放清單';
	@override String get notSupportSetPrivate => '無法設為私密';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => '沒錯...創建的播放清單會一直存在且對所有人可見';
	@override String get smallSuggestion => '小建議';
	@override String get useLikeToCollectContent => '如果您比較注重隱私，建議使用"按讚"功能來收藏內容';
	@override String get welcomeToDiscussOnGitHub => '如果你有其他建議或想法，歡迎來 GitHub 討論！';
	@override String get iUnderstand => '明白了';
	@override String get searchPlaylists => '搜尋播放清單...';
	@override String get newPlaylistName => '新播放清單名稱';
	@override String get createNewPlaylist => '創建新播放清單';
	@override String get videos => '影片';
}

// Path: search
class _TranslationsSearchZhTw implements TranslationsSearchEn {
	_TranslationsSearchZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => '搜尋範圍';
	@override String get searchTags => '搜尋標籤...';
	@override String get contentRating => '內容分級';
	@override String get removeTag => '移除標籤';
	@override String get pleaseEnterSearchContent => '請輸入搜尋內容';
	@override String get searchHistory => '搜尋歷史';
	@override String get searchSuggestion => '搜尋建議';
	@override String get usedTimes => '使用次數';
	@override String get lastUsed => '最後使用';
	@override String get noSearchHistoryRecords => '沒有搜尋歷史';
	@override String notSupportCurrentSearchType({required Object searchType}) => '目前尚未支援此搜尋類型 ${searchType}，敬請期待';
	@override String get searchResult => '搜尋結果';
	@override String unsupportedSearchType({required Object searchType}) => '不支援的搜尋類型: ${searchType}';
	@override String get googleSearch => '谷歌搜尋';
	@override String googleSearchHint({required Object webName}) => '${webName} 的搜尋功能不好用？嘗試谷歌搜尋！';
	@override String get googleSearchDescription => '借助谷歌搜索的 :site 搜索運算符，您可以通過外部引擎來對站內的內容進行檢索，此功能在搜尋 影片、圖庫、播放清單、用戶 時非常有用。';
	@override String get googleSearchKeywordsHint => '輸入要搜尋的關鍵詞';
	@override String get openLinkJump => '打開連結跳轉';
	@override String get googleSearchButton => '谷歌搜尋';
	@override String get pleaseEnterSearchKeywords => '請輸入搜尋關鍵詞';
	@override String get googleSearchQueryCopied => '搜尋語句已複製到剪貼簿';
	@override String googleSearchBrowserOpenFailed({required Object error}) => '無法打開瀏覽器: ${error}';
}

// Path: mediaList
class _TranslationsMediaListZhTw implements TranslationsMediaListEn {
	_TranslationsMediaListZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => '個人簡介';
}

// Path: settings
class _TranslationsSettingsZhTw implements TranslationsSettingsEn {
	_TranslationsSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => '列表顯示模式';
	@override String get useTraditionalPaginationMode => '使用傳統分頁模式';
	@override String get useTraditionalPaginationModeDesc => '開啟後列表將使用傳統分頁模式，關閉則使用瀑布流模式';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => '顯示底部進度條';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => '此設定決定是否在工具欄隱藏時顯示底部進度條';
	@override String get basicSettings => '基礎設定';
	@override String get personalizedSettings => '個性化設定';
	@override String get otherSettings => '其他設定';
	@override String get searchConfig => '搜尋設定';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => '此設定將決定您之後播放影片時是否會沿用之前的設定。';
	@override String get playControl => '播放控制';
	@override String get fastForwardTime => '快進時間';
	@override String get fastForwardTimeMustBeAPositiveInteger => '快進時間必須是正整數。';
	@override String get rewindTime => '快退時間';
	@override String get rewindTimeMustBeAPositiveInteger => '快退時間必須是正整數。';
	@override String get longPressPlaybackSpeed => '長按播放倍速';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => '長按播放倍速必須是正數。';
	@override String get repeat => '循環播放';
	@override String get renderVerticalVideoInVerticalScreen => '全螢幕播放時以直向模式呈現直向影片';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => '此設定將決定當您在全螢幕播放時，是否以直向模式呈現直向影片。';
	@override String get rememberVolume => '記住音量';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => '此設定將決定當您之後播放影片時，是否會保留先前的音量設定。';
	@override String get rememberBrightness => '記住亮度';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => '此設定將決定當您之後播放影片時，是否會保留先前的亮度設定。';
	@override String get playControlArea => '播放控制區域';
	@override String get leftAndRightControlAreaWidth => '左右控制區域寬度';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => '此設定將決定播放器左右兩側控制區域的寬度。';
	@override String get proxyAddressCannotBeEmpty => '代理伺服器地址不能為空。';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => '無效的代理伺服器地址格式，請使用 IP:端口 或 域名:端口 格式。';
	@override String get proxyNormalWork => '代理伺服器正常工作。';
	@override String testProxyFailedWithStatusCode({required Object code}) => '代理請求失敗，狀態碼: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => '代理請求出錯: ${exception}';
	@override String get proxyConfig => '代理設定';
	@override String get thisIsHttpProxyAddress => '此為 HTTP 代理伺服器地址';
	@override String get checkProxy => '檢查代理';
	@override String get proxyAddress => '代理地址';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => '請輸入代理伺服器的 URL，例如 127.0.0.1:8080';
	@override String get enableProxy => '啟用代理';
	@override String get left => '左側';
	@override String get middle => '中間';
	@override String get right => '右側';
	@override String get playerSettings => '播放器設定';
	@override String get networkSettings => '網路設定';
	@override String get customizeYourPlaybackExperience => '自訂您的播放體驗';
	@override String get chooseYourFavoriteAppAppearance => '選擇您喜愛的應用程式外觀';
	@override String get configureYourProxyServer => '配置您的代理伺服器';
	@override String get settings => '設定';
	@override String get themeSettings => '主題設定';
	@override String get followSystem => '跟隨系統';
	@override String get lightMode => '淺色模式';
	@override String get darkMode => '深色模式';
	@override String get presetTheme => '預設主題';
	@override String get basicTheme => '基礎主題';
	@override String get needRestartToApply => '需要重啟應用以應用設定';
	@override String get themeNeedRestartDescription => '主題設定需要重啟應用以應用設定';
	@override String get about => '關於';
	@override String get currentVersion => '當前版本';
	@override String get latestVersion => '最新版本';
	@override String get checkForUpdates => '檢查更新';
	@override String get update => '更新';
	@override String get newVersionAvailable => '發現新版本';
	@override String get projectHome => '開源地址';
	@override String get release => '版本發布';
	@override String get issueReport => '問題回報';
	@override String get openSourceLicense => '開源許可';
	@override String get checkForUpdatesFailed => '檢查更新失敗，請稍後重試';
	@override String get autoCheckUpdate => '自動檢查更新';
	@override String get updateContent => '更新內容';
	@override String get releaseDate => '發布日期';
	@override String get ignoreThisVersion => '忽略此版本';
	@override String get minVersionUpdateRequired => '當前版本過低，請盡快更新';
	@override String get forceUpdateTip => '此版本為強制更新，請盡快更新到最新版本';
	@override String get viewChangelog => '查看更新日誌';
	@override String get alreadyLatestVersion => '已是最新版本';
	@override String get appSettings => '應用設定';
	@override String get configureYourAppSettings => '配置您的應用程式設定';
	@override String get history => '歷史記錄';
	@override String get autoRecordHistory => '自動記錄歷史記錄';
	@override String get autoRecordHistoryDesc => '自動記錄您觀看過的影片和圖庫等信息';
	@override String get showUnprocessedMarkdownText => '顯示未處理文本';
	@override String get showUnprocessedMarkdownTextDesc => '顯示Markdown的原始文本';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => '隱私模式';
	@override String get activeBackgroundPrivacyModeDesc => '禁止截圖、後台運行時隱藏畫面...';
	@override String get privacy => '隱私';
	@override String get forum => '論壇';
	@override String get disableForumReplyQuote => '禁用論壇回覆引用';
	@override String get disableForumReplyQuoteDesc => '禁用論壇回覆時攜帶被回覆樓層資訊';
	@override String get theaterMode => '劇院模式';
	@override String get theaterModeDesc => '開啟後，播放器背景會被設置為影片封面的模糊版本';
	@override String get appLinks => '應用鏈接';
	@override String get defaultBrowser => '預設瀏覽';
	@override String get defaultBrowserDesc => '請在系統設定中打開預設鏈接配置項，並添加iwara.tv網站鏈接';
	@override String get themeMode => '主題模式';
	@override String get themeModeDesc => '此配置決定應用的主題模式';
	@override String get dynamicColor => '動態顏色';
	@override String get dynamicColorDesc => '此配置決定應用是否使用動態顏色';
	@override String get useDynamicColor => '使用動態顏色';
	@override String get useDynamicColorDesc => '此配置決定應用是否使用動態顏色';
	@override String get presetColors => '預設顏色';
	@override String get customColors => '自定義顏色';
	@override String get pickColor => '選擇顏色';
	@override String get cancel => '取消';
	@override String get confirm => '確認';
	@override String get noCustomColors => '沒有自定義顏色';
	@override String get recordAndRestorePlaybackProgress => '記錄和恢復播放進度';
	@override String get signature => '小尾巴';
	@override String get enableSignature => '小尾巴啟用';
	@override String get enableSignatureDesc => '此配置決定回覆時是否自動添加小尾巴';
	@override String get enterSignature => '輸入小尾巴';
	@override String get editSignature => '編輯小尾巴';
	@override String get signatureContent => '小尾巴內容';
	@override String get exportConfig => '匯出應用配置';
	@override String get exportConfigDesc => '將應用配置匯出為文件（不包含下載記錄）';
	@override String get importConfig => '匯入應用配置';
	@override String get importConfigDesc => '從文件匯入應用配置';
	@override String get exportConfigSuccess => '配置匯出成功！';
	@override String get exportConfigFailed => '配置匯出失敗';
	@override String get importConfigSuccess => '配置匯入成功！';
	@override String get importConfigFailed => '配置匯入失敗';
	@override String get historyUpdateLogs => '歷代更新日誌';
	@override String get noUpdateLogs => '未獲取到更新日誌';
	@override String get versionLabel => '版本: {version}';
	@override String get releaseDateLabel => '發布日期: {date}';
	@override String get noChanges => '暫無更新內容';
	@override String get interaction => '互動';
	@override String get enableVibration => '啟用震動';
	@override String get enableVibrationDesc => '啟用應用互動時的震動反饋';
	@override String get defaultKeepVideoToolbarVisible => '保持工具列常駐';
	@override String get defaultKeepVideoToolbarVisibleDesc => '此設定決定首次進入影片頁面時是否保持工具列常駐顯示。';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => '移動端開啟劇院模式可能會造成性能問題，可酌情開啟。';
	@override String get lockButtonPosition => '鎖定按鈕位置';
	@override String get lockButtonPositionBothSides => '兩側顯示';
	@override String get lockButtonPositionLeftSide => '僅左側顯示';
	@override String get lockButtonPositionRightSide => '僅右側顯示';
	@override String get jumpLink => '跳轉連結';
	@override String get language => '語言';
	@override String get languageChanged => '語言設定已更改，請重新啟動應用以生效。';
	@override String get gestureControl => '手勢控制';
	@override String get leftDoubleTapRewind => '左側雙擊後退';
	@override String get rightDoubleTapFastForward => '右側雙擊快進';
	@override String get doubleTapPause => '雙擊暫停';
	@override String get rightVerticalSwipeVolume => '右側上下滑動調整音量（進入新頁面時生效）';
	@override String get leftVerticalSwipeBrightness => '左側上下滑動調整亮度（進入新頁面時生效）';
	@override String get longPressFastForward => '長按快進';
	@override String get enableMouseHoverShowToolbar => '鼠標懸停時顯示工具欄';
	@override String get enableMouseHoverShowToolbarInfo => '開啟後，當鼠標懸停在播放器上移動時會自動顯示工具欄，停止移動3秒後自動隱藏';
	@override String get audioVideoConfig => '音視頻配置';
	@override String get expandBuffer => '擴大緩衝區';
	@override String get expandBufferInfo => '開啟後緩衝區增大，載入時間變長但播放更流暢';
	@override String get videoSyncMode => '視頻同步模式';
	@override String get videoSyncModeSubtitle => '音視頻同步策略';
	@override String get hardwareDecodingMode => '硬解模式';
	@override String get hardwareDecodingModeSubtitle => '硬體解碼設定';
	@override String get enableHardwareAcceleration => '啟用硬體加速';
	@override String get enableHardwareAccelerationInfo => '開啟硬體加速可以提高解碼效能，但某些裝置可能不相容';
	@override String get useOpenSLESAudioOutput => '使用OpenSLES音頻輸出';
	@override String get useOpenSLESAudioOutputInfo => '使用低延遲音頻輸出，可能提高音頻效能';
	@override String get videoSyncAudio => '音頻同步';
	@override String get videoSyncDisplayResample => '顯示重採樣';
	@override String get videoSyncDisplayResampleVdrop => '顯示重採樣(丟幀)';
	@override String get videoSyncDisplayResampleDesync => '顯示重採樣(去同步)';
	@override String get videoSyncDisplayTempo => '顯示節拍';
	@override String get videoSyncDisplayVdrop => '顯示丟視頻幀';
	@override String get videoSyncDisplayAdrop => '顯示丟音頻幀';
	@override String get videoSyncDisplayDesync => '顯示去同步';
	@override String get videoSyncDesync => '去同步';
	@override String get hardwareDecodingAuto => '自動';
	@override String get hardwareDecodingAutoCopy => '自動複製';
	@override String get hardwareDecodingAutoSafe => '自動安全';
	@override String get hardwareDecodingNo => '禁用';
	@override String get hardwareDecodingYes => '強制啟用';
	@override late final _TranslationsSettingsDownloadSettingsZhTw downloadSettings = _TranslationsSettingsDownloadSettingsZhTw._(_root);
}

// Path: oreno3d
class _TranslationsOreno3dZhTw implements TranslationsOreno3dEn {
	_TranslationsOreno3dZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => '標籤';
	@override String get characters => '角色';
	@override String get origin => '原作';
	@override String get thirdPartyTagsExplanation => '此處顯示的**標籤**、**角色**和**原作**資訊來自第三方站點 **Oreno3D**，僅供參考。\n\n由於此資訊來源只有日文，目前缺乏國際化適配。\n\n如果你有興趣參與國際化建設，歡迎訪問相關倉庫貢獻你的力量！';
	@override late final _TranslationsOreno3dSortTypesZhTw sortTypes = _TranslationsOreno3dSortTypesZhTw._(_root);
	@override late final _TranslationsOreno3dErrorsZhTw errors = _TranslationsOreno3dErrorsZhTw._(_root);
	@override late final _TranslationsOreno3dLoadingZhTw loading = _TranslationsOreno3dLoadingZhTw._(_root);
	@override late final _TranslationsOreno3dMessagesZhTw messages = _TranslationsOreno3dMessagesZhTw._(_root);
}

// Path: signIn
class _TranslationsSignInZhTw implements TranslationsSignInEn {
	_TranslationsSignInZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => '請先登入';
	@override String get alreadySignedInToday => '您今天已經簽到過了！';
	@override String get youDidNotStickToTheSignIn => '您未能持續簽到。';
	@override String get signInSuccess => '簽到成功！';
	@override String get signInFailed => '簽到失敗，請稍後再試';
	@override String get consecutiveSignIns => '連續簽到天數';
	@override String get failureReason => '未能持續簽到的原因';
	@override String get selectDateRange => '選擇日期範圍';
	@override String get startDate => '開始日期';
	@override String get endDate => '結束日期';
	@override String get invalidDate => '日期格式錯誤';
	@override String get invalidDateRange => '日期範圍無效';
	@override String get errorFormatText => '日期格式錯誤';
	@override String get errorInvalidText => '日期範圍無效';
	@override String get errorInvalidRangeText => '日期範圍無效';
	@override String get dateRangeCantBeMoreThanOneYear => '日期範圍不能超過1年';
	@override String get signIn => '簽到';
	@override String get signInRecord => '簽到紀錄';
	@override String get totalSignIns => '總簽到次數';
	@override String get pleaseSelectSignInStatus => '請選擇簽到狀態';
}

// Path: subscriptions
class _TranslationsSubscriptionsZhTw implements TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => '請登入以查看您的訂閱內容。';
	@override String get selectUser => '選擇用戶';
	@override String get noSubscribedUsers => '尚無已訂閱用戶';
	@override String get showAllSubscribedUsersContent => '顯示所有已訂閱用戶的內容';
}

// Path: videoDetail
class _TranslationsVideoDetailZhTw implements TranslationsVideoDetailEn {
	_TranslationsVideoDetailZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pipMode => '畫中畫模式';
	@override String resumeFromLastPosition({required Object position}) => '從上次播放位置繼續播放: ${position}';
	@override String get videoIdIsEmpty => '影片ID為空';
	@override String get videoInfoIsEmpty => '影片資訊為空';
	@override String get thisIsAPrivateVideo => '這是私密影片';
	@override String get getVideoInfoFailed => '取得影片資訊失敗，請稍後再試';
	@override String get noVideoSourceFound => '未找到對應的影片來源';
	@override String tagCopiedToClipboard({required Object tagId}) => '標籤 "${tagId}" 已複製到剪貼簿';
	@override String get errorLoadingVideo => '載入影片時出錯';
	@override String get play => '播放';
	@override String get pause => '暫停';
	@override String get exitAppFullscreen => '退出應用全螢幕';
	@override String get enterAppFullscreen => '應用全螢幕';
	@override String get exitSystemFullscreen => '退出系統全螢幕';
	@override String get enterSystemFullscreen => '系統全螢幕';
	@override String get seekTo => '跳轉到指定時間';
	@override String get switchResolution => '切換解析度';
	@override String get switchPlaybackSpeed => '切換播放倍速';
	@override String rewindSeconds({required Object num}) => '快退 ${num} 秒';
	@override String fastForwardSeconds({required Object num}) => '快進 ${num} 秒';
	@override String playbackSpeedIng({required Object rate}) => '正在以 ${rate} 倍速播放';
	@override String get brightness => '亮度';
	@override String get brightnessLowest => '亮度已最低';
	@override String get volume => '音量';
	@override String get volumeMuted => '音量已靜音';
	@override String get home => '主頁';
	@override String get videoPlayer => '影片播放器';
	@override String get videoPlayerInfo => '播放器資訊';
	@override String get moreSettings => '更多設定';
	@override String get videoPlayerFeatureInfo => '播放器功能介紹';
	@override String get autoRewind => '自動重播';
	@override String get rewindAndFastForward => '左右雙擊快進或快退';
	@override String get volumeAndBrightness => '左右滑動調整音量、亮度';
	@override String get centerAreaDoubleTapPauseOrPlay => '中央區域雙擊暫停或播放';
	@override String get showVerticalVideoInFullScreen => '在全螢幕時顯示直向影片';
	@override String get keepLastVolumeAndBrightness => '保持最後調整的音量、亮度';
	@override String get setProxy => '設定代理';
	@override String get moreFeaturesToBeDiscovered => '更多功能待發掘...';
	@override String get videoPlayerSettings => '播放器設定';
	@override String commentCount({required Object num}) => '評論 ${num} 則';
	@override String get writeYourCommentHere => '請寫下您的評論...';
	@override String get authorOtherVideos => '作者的其他影片';
	@override String get relatedVideos => '相關影片';
	@override String get privateVideo => '這是一個私密影片';
	@override String get externalVideo => '這是一個站外影片';
	@override String get openInBrowser => '在瀏覽器中打開';
	@override String get resourceDeleted => '這個影片貌似被刪除了 :/';
	@override String get noDownloadUrl => '沒有下載連結';
	@override String get startDownloading => '開始下載';
	@override String get downloadFailed => '下載失敗，請稍後再試';
	@override String get downloadSuccess => '下載成功';
	@override String get download => '下載';
	@override String get downloadManager => '下載管理';
	@override String get videoLoadError => '影片加載錯誤';
	@override String get resourceNotFound => '資源未找到';
	@override String get authorNoOtherVideos => '作者暫無其他影片';
	@override String get noRelatedVideos => '暫無相關影片';
	@override late final _TranslationsVideoDetailSkeletonZhTw skeleton = _TranslationsVideoDetailSkeletonZhTw._(_root);
}

// Path: share
class _TranslationsShareZhTw implements TranslationsShareEn {
	_TranslationsShareZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => '分享播放列表';
	@override String get wowDidYouSeeThis => '哇哦，你看过这个吗？';
	@override String get nameIs => '名字叫做';
	@override String get clickLinkToView => '點擊連結查看';
	@override String get iReallyLikeThis => '我真的是太喜歡這個了，你也來看看吧！';
	@override String get shareFailed => '分享失敗，請稍後再試';
	@override String get share => '分享';
	@override String get shareAsImage => '分享為圖片';
	@override String get shareAsText => '分享為文本';
	@override String get shareAsImageDesc => '將影片封面分享為圖片';
	@override String get shareAsTextDesc => '將影片詳情分享為文本';
	@override String get shareAsImageFailed => '分享影片封面為圖片失敗，請稍後再試';
	@override String get shareAsTextFailed => '分享影片詳情為文本失敗，請稍後再試';
	@override String get shareVideo => '分享影片';
	@override String get authorIs => '作者是';
	@override String get shareGallery => '分享圖庫';
	@override String get galleryTitleIs => '圖庫名字叫做';
	@override String get galleryAuthorIs => '圖庫作者是';
	@override String get shareUser => '分享用戶';
	@override String get userNameIs => '用戶名字叫做';
	@override String get userAuthorIs => '用戶作者是';
	@override String get comments => '評論';
	@override String get shareThread => '分享帖子';
	@override String get views => '瀏覽';
	@override String get sharePost => '分享投稿';
	@override String get postTitleIs => '投稿名字叫做';
	@override String get postAuthorIs => '投稿作者是';
}

// Path: markdown
class _TranslationsMarkdownZhTw implements TranslationsMarkdownEn {
	_TranslationsMarkdownZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Markdown 語法';
	@override String get iwaraSpecialMarkdownSyntax => 'Iwara 專用語法';
	@override String get internalLink => '站內鏈接';
	@override String get supportAutoConvertLinkBelow => '支持自動轉換以下類型的鏈接：';
	@override String get convertLinkExample => '🎬 影片鏈接\n🖼️ 圖片鏈接\n👤 用戶鏈接\n📌 論壇鏈接\n🎵 播放列表鏈接\n💬 帖子鏈接';
	@override String get mentionUser => '提及用戶';
	@override String get mentionUserDescription => '輸入@後跟用戶名，將自動轉換為用戶鏈接';
	@override String get markdownBasicSyntax => 'Markdown 基本語法';
	@override String get paragraphAndLineBreak => '段落與換行';
	@override String get paragraphAndLineBreakDescription => '段落之間空一行，行末加兩個空格實現換行';
	@override String get paragraphAndLineBreakSyntax => '這是第一段文字\n\n這是第二段文字\n這一行後面加兩個空格  \n就能換行了';
	@override String get textStyle => '文本樣式';
	@override String get textStyleDescription => '使用特殊符號包圍文本来改變樣式';
	@override String get textStyleSyntax => '**粗體文本**\n*斜體文本*\n~~刪除線文本~~\n`代碼文本`';
	@override String get quote => '引用';
	@override String get quoteDescription => '使用 > 符號創建引用，多個 > 創建多級引用';
	@override String get quoteSyntax => '> 這是一級引用\n>> 這是二級引用';
	@override String get list => '列表';
	@override String get listDescription => '使用數字+點號創建有序列表，使用 - 創建無序列表';
	@override String get listSyntax => '1. 第一項\n2. 第二項\n\n- 無序項\n  - 子項\n  - 另一個子項';
	@override String get linkAndImage => '鏈接與圖片';
	@override String get linkAndImageDescription => '鏈接格式：[文字](URL)\n圖片格式：![描述](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[鏈接文字](${link})\n![圖片描述](${imgUrl})';
	@override String get title => '標題';
	@override String get titleDescription => '使用 # 號創建標題，數量表示級別';
	@override String get titleSyntax => '# 一級標題\n## 二級標題\n### 三級標題';
	@override String get separator => '分隔線';
	@override String get separatorDescription => '使用三個或更多 - 號創建分隔線';
	@override String get separatorSyntax => '---';
	@override String get syntax => '語法';
}

// Path: forum
class _TranslationsForumZhTw implements TranslationsForumEn {
	_TranslationsForumZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get recent => '最近';
	@override String get category => '分類';
	@override String get lastReply => '最終回覆';
	@override late final _TranslationsForumErrorsZhTw errors = _TranslationsForumErrorsZhTw._(_root);
	@override String get createPost => '創建帖子';
	@override String get title => '標題';
	@override String get enterTitle => '輸入標題';
	@override String get content => '內容';
	@override String get enterContent => '輸入內容';
	@override String get writeYourContentHere => '在此輸入內容...';
	@override String get posts => '帖子';
	@override String get threads => '主題';
	@override String get forum => '論壇';
	@override String get createThread => '創建主題';
	@override String get selectCategory => '選擇分類';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => '冷卻剩餘時間 ${minutes} 分 ${seconds} 秒';
	@override late final _TranslationsForumGroupsZhTw groups = _TranslationsForumGroupsZhTw._(_root);
	@override late final _TranslationsForumLeafNamesZhTw leafNames = _TranslationsForumLeafNamesZhTw._(_root);
	@override late final _TranslationsForumLeafDescriptionsZhTw leafDescriptions = _TranslationsForumLeafDescriptionsZhTw._(_root);
	@override String get reply => '回覆';
	@override String get pendingReview => '審核中';
	@override String get editedAt => '編輯時間';
	@override String get copySuccess => '已複製到剪貼簿';
	@override String copySuccessForMessage({required Object str}) => '已複製到剪貼簿: ${str}';
	@override String get editReply => '編輯回覆';
	@override String get editTitle => '編輯標題';
	@override String get submit => '提交';
}

// Path: notifications
class _TranslationsNotificationsZhTw implements TranslationsNotificationsEn {
	_TranslationsNotificationsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsZhTw errors = _TranslationsNotificationsErrorsZhTw._(_root);
	@override String get notifications => '通知';
	@override String get profile => '個人主頁';
	@override String get postedNewComment => '發表了評論';
	@override String get notifiedOn => '在您的個人主頁上發表了評論';
	@override String get inYour => '在您的';
	@override String get video => '影片';
	@override String get repliedYourVideoComment => '回覆了您的影片評論';
	@override String get copyInfoToClipboard => '複製通知信息到剪貼簿';
	@override String get copySuccess => '已複製到剪貼簿';
	@override String copySuccessForMessage({required Object str}) => '已複製到剪貼簿: ${str}';
	@override String get markAllAsRead => '全部標記已讀';
	@override String get markAllAsReadSuccess => '所有通知已標記為已讀';
	@override String get markAllAsReadFailed => '全部標記已讀失敗';
	@override String markAllAsReadFailedWithException({required Object exception}) => '全部標記已讀失敗: ${exception}';
	@override String get markSelectedAsRead => '標記已讀';
	@override String get markSelectedAsReadSuccess => '已標記為已讀';
	@override String get markSelectedAsReadFailed => '標記已讀失敗';
	@override String markSelectedAsReadFailedWithException({required Object exception}) => '標記已讀失敗: ${exception}';
	@override String get markAsRead => '標記已讀';
	@override String get markAsReadSuccess => '已標記為已讀';
	@override String get markAsReadFailed => '標記已讀失敗';
	@override String get notificationTypeHelp => '通知類型幫助';
	@override String get dueToLackOfNotificationTypeDetails => '通知類型的詳細信息不足，目前支持的類型可能沒有覆蓋到您當前收到的消息';
	@override String get helpUsImproveNotificationTypeSupport => '如果您願意幫助我們完善通知類型的支持：';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 複製通知信息\n2. 🐞 前往項目倉庫提交 issue\n\n⚠️ 注意：通知信息可能包含個人隱私，如果你不想公開，也可以通過郵件發送給項目作者。';
	@override String get goToRepository => '前往項目倉庫';
	@override String get copy => '複製';
	@override String get commentApproved => '評論已通過';
	@override String get repliedYourProfileComment => '回覆了您的個人主頁評論';
	@override String get kReplied => '回覆了您在';
	@override String get kCommented => '評論了您的';
	@override String get kVideo => '影片';
	@override String get kGallery => '圖庫';
	@override String get kProfile => '主頁';
	@override String get kThread => '主題';
	@override String get kPost => '投稿';
	@override String get kCommentSection => '下的評論';
	@override String get kApprovedComment => '評論已通過';
	@override String get kApprovedVideo => '影片已通過';
	@override String get kApprovedGallery => '圖庫已通過';
	@override String get kApprovedThread => '主題已審核';
	@override String get kApprovedPost => '投稿已審核';
	@override String get kUnknownType => '未知通知類型';
}

// Path: conversation
class _TranslationsConversationZhTw implements TranslationsConversationEn {
	_TranslationsConversationZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsZhTw errors = _TranslationsConversationErrorsZhTw._(_root);
	@override String get conversation => '會話';
	@override String get startConversation => '發起會話';
	@override String get noConversation => '暫無會話';
	@override String get selectFromLeftListAndStartConversation => '從左側列表選擇一個會話開始聊天';
	@override String get title => '標題';
	@override String get body => '內容';
	@override String get selectAUser => '選擇用戶';
	@override String get searchUsers => '搜索用戶...';
	@override String get tmpNoConversions => '暫無會話';
	@override String get deleteThisMessage => '刪除此消息';
	@override String get deleteThisMessageSubtitle => '此操作不可撤銷';
	@override String get writeMessageHere => '在此處輸入消息';
	@override String get sendMessage => '發送消息';
}

// Path: splash
class _TranslationsSplashZhTw implements TranslationsSplashEn {
	_TranslationsSplashZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsZhTw errors = _TranslationsSplashErrorsZhTw._(_root);
	@override String get preparing => '準備中...';
	@override String get initializing => '初始化中...';
	@override String get loading => '加載中...';
	@override String get ready => '準備完成';
	@override String get initializingMessageService => '初始化消息服務中...';
}

// Path: download
class _TranslationsDownloadZhTw implements TranslationsDownloadEn {
	_TranslationsDownloadZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsZhTw errors = _TranslationsDownloadErrorsZhTw._(_root);
	@override String get downloadList => '下載列表';
	@override String get download => '下載';
	@override String get forceDeleteTask => '強制刪除任務';
	@override String get startDownloading => '開始下載...';
	@override String get clearAllFailedTasks => '清除全部失敗任務';
	@override String get clearAllFailedTasksConfirmation => '確定要清除所有失敗的下載任務嗎？\n這些任務的文件也會被刪除。';
	@override String get clearAllFailedTasksSuccess => '已清除所有失敗任務';
	@override String get clearAllFailedTasksError => '清除失敗任務時出錯';
	@override String get downloadStatus => '下載狀態';
	@override String get imageList => '圖片列表';
	@override String get retryDownload => '重試下載';
	@override String get notDownloaded => '未下載';
	@override String get downloaded => '已下載';
	@override String get waitingForDownload => '等待下載...';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '下載中 (${downloaded}/${total}張 ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => '下載中 (${downloaded}張)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '已暫停 (${downloaded}/${total}張 ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => '已暫停 (已下載${downloaded}張)';
	@override String downloadedProgressForImageProgress({required Object total}) => '下載完成 (共${total}張)';
	@override String get viewVideoDetail => '查看影片詳情';
	@override String get viewGalleryDetail => '查看圖庫詳情';
	@override String get moreOptions => '更多操作';
	@override String get openFile => '打開文件';
	@override String get pause => '暫停';
	@override String get resume => '繼續';
	@override String get copyDownloadUrl => '複製下載連結';
	@override String get showInFolder => '在文件夾中顯示';
	@override String get deleteTask => '刪除任務';
	@override String get deleteTaskConfirmation => '確定要刪除這個下載任務嗎？\n任務的文件也會被刪除。';
	@override String get forceDeleteTaskConfirmation => '確定要強制刪除這個下載任務嗎？\n任務的文件也會被刪除，即使文件被佔用也會嘗試刪除。';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => '下載中 ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => '已暫停 • ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => '已暫停 • 已下載 ${downloaded}';
	@override String downloadedWithSize({required Object size}) => '下載完成 • ${size}';
	@override String get copyDownloadUrlSuccess => '已複製下載連結';
	@override String totalImageNums({required Object num}) => '${num}張';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => '下載中';
	@override String get failed => '失敗';
	@override String get completed => '已完成';
	@override String get downloadDetail => '下載詳情';
	@override String get copy => '複製';
	@override String get copySuccess => '已複製';
	@override String get waiting => '等待中';
	@override String get paused => '暫停中';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => '下載中 ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => '圖庫下載完成: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => '下載完成: ${fileName}';
	@override String get stillInDevelopment => '開發中';
	@override String get saveToAppDirectory => '保存到應用程序目錄';
}

// Path: favorite
class _TranslationsFavoriteZhTw implements TranslationsFavoriteEn {
	_TranslationsFavoriteZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsZhTw errors = _TranslationsFavoriteErrorsZhTw._(_root);
	@override String get add => '追加';
	@override String get addSuccess => '追加成功';
	@override String get addFailed => '追加失敗';
	@override String get remove => '刪除';
	@override String get removeSuccess => '刪除成功';
	@override String get removeFailed => '刪除失敗';
	@override String get removeConfirmation => '確定要刪除這個項目嗎？';
	@override String get removeConfirmationSuccess => '項目已從收藏夾中刪除';
	@override String get removeConfirmationFailed => '刪除項目失敗';
	@override String get createFolderSuccess => '文件夾創建成功';
	@override String get createFolderFailed => '創建文件夾失敗';
	@override String get createFolder => '創建文件夾';
	@override String get enterFolderName => '輸入文件夾名稱';
	@override String get enterFolderNameHere => '在此輸入文件夾名稱...';
	@override String get create => '創建';
	@override String get items => '項目';
	@override String get newFolderName => '新文件夾';
	@override String get searchFolders => '搜索文件夾...';
	@override String get searchItems => '搜索項目...';
	@override String get createdAt => '創建時間';
	@override String get myFavorites => '我的收藏';
	@override String get deleteFolderTitle => '刪除文件夾';
	@override String deleteFolderConfirmWithTitle({required Object title}) => '確定要刪除 ${title} 文件夾嗎？';
	@override String get removeItemTitle => '刪除項目';
	@override String removeItemConfirmWithTitle({required Object title}) => '確定要刪除 ${title} 項目嗎？';
	@override String get removeItemSuccess => '項目已從收藏夾中刪除';
	@override String get removeItemFailed => '刪除項目失敗';
	@override String get localizeFavorite => '本地收藏';
	@override String get editFolderTitle => '編輯資料夾';
	@override String get editFolderSuccess => '資料夾更新成功';
	@override String get editFolderFailed => '資料夾更新失敗';
	@override String get searchTags => '搜索標籤';
}

// Path: translation
class _TranslationsTranslationZhTw implements TranslationsTranslationEn {
	_TranslationsTranslationZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get testConnection => '測試連接';
	@override String get testConnectionSuccess => '測試連接成功';
	@override String get testConnectionFailed => '測試連接失敗';
	@override String testConnectionFailedWithMessage({required Object message}) => '測試連接失敗: ${message}';
	@override String get translation => '翻譯';
	@override String get needVerification => '需要驗證';
	@override String get needVerificationContent => '請先通過連接測試才能啟用AI翻譯';
	@override String get confirm => '確定';
	@override String get disclaimer => '使用須知';
	@override String get riskWarning => '風險提示';
	@override String get dureToRisk1 => '由於評論等文本為用戶生成，可能包含違反AI服務商內容政策的內容';
	@override String get dureToRisk2 => '不當內容可能導致API密鑰封禁或服務終止';
	@override String get operationSuggestion => '操作建議';
	@override String get operationSuggestion1 => '1. 使用前請嚴格審核待翻譯內容';
	@override String get operationSuggestion2 => '2. 避免翻譯涉及暴力、成人等敏感內容';
	@override String get apiConfig => 'API設定';
	@override String get modifyConfigWillAutoCloseAITranslation => '修改配置將自動關閉AI翻譯，需重新測試後打開';
	@override String get apiAddress => 'API地址';
	@override String get modelName => '模型名稱';
	@override String get modelNameHintText => '例如：gpt-4-turbo';
	@override String get maxTokens => '最大Token數';
	@override String get maxTokensHintText => '例如：1024';
	@override String get temperature => '溫度係數';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => '點擊測試按鈕驗證API連接有效性';
	@override String get requestPreview => '請求預覽';
	@override String get enableAITranslation => 'AI翻譯';
	@override String get enabled => '已啟用';
	@override String get disabled => '已禁用';
	@override String get testing => '測試中...';
	@override String get testNow => '立即測試';
	@override String get connectionStatus => '連接狀態';
	@override String get success => '成功';
	@override String get failed => '失敗';
	@override String get information => '信息';
	@override String get viewRawResponse => '查看原始響應';
	@override String get pleaseCheckInputParametersFormat => '請檢查輸入參數格式';
	@override String get pleaseFillInAPIAddressModelNameAndKey => '請填寫API地址、模型名稱和密鑰';
	@override String get pleaseFillInValidConfigurationParameters => '請填寫有效的配置參數';
	@override String get pleaseCompleteConnectionTest => '請完成連接測試';
	@override String get notConfigured => '未配置';
	@override String get apiEndpoint => 'API端點';
	@override String get configuredKey => '已配置密鑰';
	@override String get notConfiguredKey => '未配置密鑰';
	@override String get authenticationStatus => '認證狀態';
	@override String get thisFieldCannotBeEmpty => '此字段不能為空';
	@override String get apiKey => 'API密鑰';
	@override String get apiKeyCannotBeEmpty => 'API密鑰不能為空';
	@override String get range => '範圍';
	@override String get pleaseEnterValidNumber => '請輸入有效數字';
	@override String get mustBeGreaterThan => '必須大於';
	@override String get invalidAPIResponse => '無效的API響應';
	@override String connectionFailedForMessage({required Object message}) => '連接失敗: ${message}';
	@override String get aiTranslationNotEnabledHint => 'AI翻譯未啟用，請在設定中啟用';
	@override String get goToSettings => '前往設定';
	@override String get disableAITranslation => '禁用AI翻譯';
	@override String get currentValue => '現在值';
	@override String get configureTranslationStrategy => '配置翻譯策略';
	@override String get advancedSettings => '高級設定';
	@override String get translationPrompt => '翻譯提示詞';
	@override String get promptHint => '請輸入翻譯提示詞,使用[TL]作為目標語言的占位符';
	@override String get promptHelperText => '提示詞必須包含[TL]作為目標語言的占位符';
	@override String get promptMustContainTargetLang => '提示詞必須包含[TL]占位符';
	@override String get aiTranslationWillBeDisabled => 'AI翻譯將被自動關閉';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => '由於修改了基礎配置,AI翻譯將被自動關閉';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => '由於修改了翻譯提示詞,AI翻譯將被自動關閉';
	@override String get aiTranslationWillBeDisabledDueToParamChange => '由於修改了參數配置,AI翻譯將被自動關閉';
	@override String get onlyOpenAIAPISupported => '目前僅支持OpenAI兼容的API格式（application/json請求體格式）';
	@override String get streamingTranslation => '流式翻譯';
	@override String get streamingTranslationSupported => '支持流式翻譯';
	@override String get streamingTranslationNotSupported => '不支持流式翻譯';
	@override String get streamingTranslationDescription => '流式翻譯可以在翻譯過程中實時顯示結果，提供更好的用戶體驗';
	@override String get baseUrlInputHelperText => '當以#結尾時，將以輸入的URL作為實際請求地址';
	@override String get usingFullUrlWithHash => '使用完整URL（以#結尾）';
	@override String currentActualUrl({required Object url}) => '目前實際URL: ${url}';
	@override String get urlEndingWithHashTip => 'URL以#結尾時，將以輸入的URL作為實際請求地址';
	@override String get streamingTranslationWarning => '注意：此功能需要API服務支持流式傳輸，部分模型可能不支持';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerZhTw implements TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => '影片播放器錯誤';
	@override String get videoLoadFailed => '影片載入失敗';
	@override String get videoCodecNotSupported => '影片編解碼器不支援';
	@override String get networkConnectionIssue => '網路連線問題';
	@override String get insufficientPermission => '權限不足';
	@override String get unsupportedVideoFormat => '不支援的影片格式';
	@override String get retry => '重試';
	@override String get externalPlayer => '外部播放器';
	@override String get detailedErrorInfo => '詳細錯誤資訊';
	@override String get format => '格式';
	@override String get suggestion => '建議';
	@override String get androidWebmCompatibilityIssue => 'Android裝置對WEBM格式支援有限，建議使用外部播放器或下載支援WEBM的播放器應用';
	@override String get currentDeviceCodecNotSupported => '目前裝置不支援此影片格式的編解碼器';
	@override String get checkNetworkConnection => '請檢查網路連線後重試';
	@override String get appMayLackMediaPermission => '應用可能缺少必要的媒體播放權限';
	@override String get tryOtherVideoPlayer => '請嘗試使用其他影片播放器';
	@override String get video => '影片';
	@override String get imageLoadFailed => '圖片載入失敗';
	@override String get unsupportedImageFormat => '不支援的圖片格式';
	@override String get tryOtherViewer => '請嘗試使用其他檢視器';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogZhTw implements TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '輸入連結';
	@override String supportedLinksHint({required Object webName}) => '支持智能識別多個${webName}連結，並快速跳轉到應用內對應頁面(連結與其他文本之間用空格隔開)';
	@override String inputHint({required Object webName}) => '請輸入${webName}連結';
	@override String get validatorEmptyLink => '請輸入連結';
	@override String validatorNoIwaraLink({required Object webName}) => '未檢測到有效的${webName}連結';
	@override String get multipleLinksDetected => '檢測到多個連結，請選擇一個：';
	@override String notIwaraLink({required Object webName}) => '不是有效的${webName}連結';
	@override String linkParseError({required Object error}) => '連結解析出錯: ${error}';
	@override String get unsupportedLinkDialogTitle => '不支援的連結';
	@override String get unsupportedLinkDialogContent => '該連結類型當前應用無法直接打開，需要使用外部瀏覽器訪問。\n\n是否使用瀏覽器打開此連結？';
	@override String get openInBrowser => '用瀏覽器打開';
	@override String get confirmOpenBrowserDialogTitle => '確認打開瀏覽器';
	@override String get confirmOpenBrowserDialogContent => '即將使用外部瀏覽器打開以下連結：';
	@override String get confirmContinueBrowserOpen => '確定要繼續嗎？';
	@override String get browserOpenFailed => '無法打開連結';
	@override String get unsupportedLink => '不支援的連結';
	@override String get cancel => '取消';
	@override String get confirm => '用瀏覽器打開';
}

// Path: log
class _TranslationsLogZhTw implements TranslationsLogEn {
	_TranslationsLogZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get logManagement => '日志管理';
	@override String get enableLogPersistence => '持久化日志';
	@override String get enableLogPersistenceDesc => '將日志保存到數據庫以便於分析問題';
	@override String get logDatabaseSizeLimit => '日志數據庫大小上限';
	@override String logDatabaseSizeLimitDesc({required Object size}) => '當前: ${size}';
	@override String get exportCurrentLogs => '導出當前日志';
	@override String get exportCurrentLogsDesc => '導出當天應用日志以幫助開發者診斷問題';
	@override String get exportHistoryLogs => '導出歷史日志';
	@override String get exportHistoryLogsDesc => '導出指定日期範圍內的日志';
	@override String get exportMergedLogs => '導出合併日志';
	@override String get exportMergedLogsDesc => '導出指定日期範圍內的合併日志';
	@override String get showLogStats => '顯示日志統計信息';
	@override String get logExportSuccess => '日志導出成功';
	@override String logExportFailed({required Object error}) => '日志導出失敗: ${error}';
	@override String get showLogStatsDesc => '查看各種類型日志的統計數據';
	@override String logExtractFailed({required Object error}) => '獲取日志統計失敗: ${error}';
	@override String get clearAllLogs => '清理所有日志';
	@override String get clearAllLogsDesc => '清理所有日志數據';
	@override String get confirmClearAllLogs => '確認清理';
	@override String get confirmClearAllLogsDesc => '確定要清理所有日志數據嗎？此操作不可撤銷。';
	@override String get clearAllLogsSuccess => '日志清理成功';
	@override String clearAllLogsFailed({required Object error}) => '清理日志失敗: ${error}';
	@override String get unableToGetLogSizeInfo => '無法獲取日志大小信息';
	@override String get currentLogSize => '當前日志大小:';
	@override String get logCount => '日志數量:';
	@override String get logCountUnit => '條';
	@override String get logSizeLimit => '大小上限:';
	@override String get usageRate => '使用率:';
	@override String get exceedLimit => '超出限制';
	@override String get remaining => '剩餘';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => '日志空間已超出限制，建議立即清理舊日志或增加空間限制';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => '日志空間即將用盡，建議清理舊日志';
	@override String get cleaningOldLogs => '正在自動清理舊日志...';
	@override String get logCleaningCompleted => '日志清理完成';
	@override String get logCleaningProcessMayNotBeCompleted => '日志清理過程可能未完成';
	@override String get cleanExceededLogs => '清理超出限制的日志';
	@override String get noLogsToExport => '沒有可導出的日志數據';
	@override String get exportingLogs => '正在導出日志...';
	@override String get noHistoryLogsToExport => '尚無可導出的歷史日志，請先使用應用一段時間再嘗試';
	@override String get selectLogDate => '選擇日志日期';
	@override String get today => '今天';
	@override String get selectMergeRange => '選擇合併範圍';
	@override String get selectMergeRangeHint => '請選擇要合併的日志時間範圍';
	@override String selectMergeRangeDays({required Object days}) => '最近 ${days} 天';
	@override String get logStats => '日志統計信息';
	@override String todayLogs({required Object count}) => '今日日志: ${count} 條';
	@override String recent7DaysLogs({required Object count}) => '最近7天: ${count} 條';
	@override String totalLogs({required Object count}) => '總計日志: ${count} 條';
	@override String get setLogDatabaseSizeLimit => '設置日志數據庫大小上限';
	@override String currentLogSizeWithSize({required Object size}) => '當前日志大小: ${size}';
	@override String get warning => '警告';
	@override String newSizeLimit({required Object size}) => '新的大小限制: ${size}';
	@override String get confirmToContinue => '確定要繼續嗎？';
	@override String logSizeLimitSetSuccess({required Object size}) => '日志大小上限已設置為 ${size}';
}

// Path: common.pagination
class _TranslationsCommonPaginationZhTw implements TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => '共 ${num} 項';
	@override String get jumpToPage => '跳轉到指定頁面';
	@override String pleaseEnterPageNumber({required Object max}) => '請輸入頁碼 (1-${max})';
	@override String get pageNumber => '頁碼';
	@override String get jump => '跳轉';
	@override String invalidPageNumber({required Object max}) => '請輸入有效頁碼 (1-${max})';
	@override String get invalidInput => '請輸入有效頁碼';
	@override String get waterfall => '瀑布流';
	@override String get pagination => '分頁';
}

// Path: errors.network
class _TranslationsErrorsNetworkZhTw implements TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => '網路錯誤 - ';
	@override String get failedToConnectToServer => '連接伺服器失敗';
	@override String get serverNotAvailable => '伺服器不可用';
	@override String get requestTimeout => '請求超時';
	@override String get unexpectedError => '意外錯誤';
	@override String get invalidResponse => '無效的回應';
	@override String get invalidRequest => '無效的請求';
	@override String get invalidUrl => '無效的URL';
	@override String get invalidMethod => '無效的方法';
	@override String get invalidHeader => '無效的頭部';
	@override String get invalidBody => '無效的體';
	@override String get invalidStatusCode => '無效的狀態碼';
	@override String get serverError => '伺服器錯誤';
	@override String get requestCanceled => '請求已取消';
	@override String get invalidPort => '無効な埠口';
	@override String get proxyPortError => '代理埠口設定異常';
	@override String get connectionRefused => '連接被拒絕';
	@override String get networkUnreachable => '網路不可達';
	@override String get noRouteToHost => '無法找到主機';
	@override String get connectionFailed => '連接失敗';
	@override String get sslConnectionFailed => 'SSL連接失敗，請檢查網絡設置';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsZhTw implements TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => '下載設定';
	@override String get storagePermissionStatus => '存儲權限狀態';
	@override String get accessPublicDirectoryNeedStoragePermission => '訪問公共目錄需要存儲權限';
	@override String get checkingPermissionStatus => '檢查權限狀態...';
	@override String get storagePermissionGranted => '已授權存儲權限';
	@override String get storagePermissionNotGranted => '需要存儲權限';
	@override String get storagePermissionGrantSuccess => '存儲權限授權成功';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => '存儲權限授權失敗，部分功能可能受限';
	@override String get grantStoragePermission => '授權存儲權限';
	@override String get customDownloadPath => '自定義下載位置';
	@override String get customDownloadPathDescription => '啟用後可以為下載的檔案選擇自定義儲存位置';
	@override String get customDownloadPathTip => '💡 提示：選擇公共目錄（如下載資料夾）需要授予儲存權限，建議優先使用推薦路徑';
	@override String get androidWarning => 'Android提示：避免選擇公共目錄（如下載資料夾），建議使用應用程式專用目錄以確保存取權限。';
	@override String get publicDirectoryPermissionTip => '⚠️ 注意：您選擇的是公共目錄，需要儲存權限才能正常下載檔案';
	@override String get permissionRequiredForPublicDirectory => '選擇公共目錄需要儲存權限';
	@override String get currentDownloadPath => '目前下載路徑';
	@override String get defaultAppDirectory => '預設應用程式目錄';
	@override String get permissionGranted => '已授權';
	@override String get permissionRequired => '需要權限';
	@override String get enableCustomDownloadPath => '啟用自定義下載路徑';
	@override String get disableCustomDownloadPath => '關閉時使用應用程式預設路徑';
	@override String get customDownloadPathLabel => '自定義下載路徑';
	@override String get selectDownloadFolder => '選擇下載資料夾';
	@override String get recommendedPath => '推薦路徑';
	@override String get selectFolder => '選擇資料夾';
	@override String get filenameTemplate => '檔案命名範本';
	@override String get filenameTemplateDescription => '自定義下載檔案的命名規則，支援變數替換';
	@override String get videoFilenameTemplate => '影片檔案命名範本';
	@override String get galleryFolderTemplate => '圖庫資料夾範本';
	@override String get imageFilenameTemplate => '單張圖片命名範本';
	@override String get resetToDefault => '重設為預設值';
	@override String get supportedVariables => '支援的變數';
	@override String get supportedVariablesDescription => '在檔案命名範本中可以使用以下變數：';
	@override String get copyVariable => '複製變數';
	@override String get variableCopied => '變數已複製';
	@override String get warningPublicDirectory => '警告：選擇的是公共目錄，可能無法存取。建議選擇應用程式專用目錄。';
	@override String get downloadPathUpdated => '下載路徑已更新';
	@override String get selectPathFailed => '選擇路徑失敗';
	@override String get recommendedPathSet => '已設定為推薦路徑';
	@override String get setRecommendedPathFailed => '設定推薦路徑失敗';
	@override String get templateResetToDefault => '已重設為預設範本';
	@override String get functionalTest => '功能測試';
	@override String get testInProgress => '測試中...';
	@override String get runTest => '執行測試';
	@override String get testDownloadPathAndPermissions => '測試下載路徑和權限配置是否正常運作';
	@override String get testResults => '測試結果';
	@override String get testCompleted => '測試完成';
	@override String get testPassed => '項通過';
	@override String get testFailed => '測試失敗';
	@override String get testStoragePermissionCheck => '存儲權限檢查';
	@override String get testStoragePermissionGranted => '已獲得存儲權限';
	@override String get testStoragePermissionMissing => '缺少存儲權限，部分功能可能受限';
	@override String get testPermissionCheckFailed => '權限檢查失敗';
	@override String get testDownloadPathValidation => '下載路徑驗證';
	@override String get testPathValidationFailed => '路徑驗證失敗';
	@override String get testFilenameTemplateValidation => '檔案命名範本驗證';
	@override String get testAllTemplatesValid => '所有範本都有效';
	@override String get testSomeTemplatesInvalid => '部分範本包含無效字元';
	@override String get testTemplateValidationFailed => '範本驗證失敗';
	@override String get testDirectoryOperationTest => '目錄操作測試';
	@override String get testDirectoryOperationNormal => '目錄建立和檔案寫入正常';
	@override String get testDirectoryOperationFailed => '目錄操作失敗';
	@override String get testVideoTemplate => '視頻模板';
	@override String get testGalleryTemplate => '圖庫模板';
	@override String get testImageTemplate => '圖片模板';
	@override String get testValid => '有效';
	@override String get testInvalid => '無效';
	@override String get testSuccess => '成功';
	@override String get testCorrect => '正確';
	@override String get testError => '錯誤';
	@override String get testPath => '測試路徑';
	@override String get testBasePath => '基礎路徑';
	@override String get testDirectoryCreation => '目錄創建';
	@override String get testFileWriting => '檔案寫入';
	@override String get testFileContent => '檔案內容';
	@override String get checkingPathStatus => '檢查路徑狀態...';
	@override String get unableToGetPathStatus => '無法獲取路徑狀態';
	@override String get actualPathDifferentFromSelected => '注意：實際使用路徑與選擇路徑不同';
	@override String get grantPermission => '授權權限';
	@override String get fixIssue => '修復問題';
	@override String get issueFixed => '問題已修復';
	@override String get fixFailed => '修復失敗，請手動處理';
	@override String get lackStoragePermission => '缺少存儲權限';
	@override String get cannotAccessPublicDirectory => '無法訪問公共目錄，需要「所有檔案存取權限」';
	@override String get cannotCreateDirectory => '無法建立目錄';
	@override String get directoryNotWritable => '目錄不可寫入';
	@override String get insufficientSpace => '可用空間不足';
	@override String get pathValid => '路徑有效';
	@override String get validationFailed => '驗證失敗';
	@override String get usingDefaultAppDirectory => '使用預設應用程式目錄';
	@override String get appPrivateDirectory => '應用程式專用目錄';
	@override String get appPrivateDirectoryDesc => '安全可靠，無需額外權限';
	@override String get downloadDirectory => '下載目錄';
	@override String get downloadDirectoryDesc => '系統預設下載位置，便於管理';
	@override String get moviesDirectory => '影片目錄';
	@override String get moviesDirectoryDesc => '系統影片目錄，媒體應用程式可識別';
	@override String get documentsDirectory => '文件目錄';
	@override String get documentsDirectoryDesc => 'iOS應用程式文件目錄';
	@override String get requiresStoragePermission => '需要存儲權限才能存取';
	@override String get recommendedPaths => '推薦路徑';
	@override String get selectRecommendedDownloadLocation => '選擇一個推薦的下載位置';
	@override String get noRecommendedPaths => '暫無推薦路徑';
	@override String get recommended => '推薦';
	@override String get requiresPermission => '需要權限';
	@override String get authorizeAndSelect => '授權並選擇';
	@override String get select => '選擇';
	@override String get permissionAuthorizationFailed => '權限授權失敗，無法選擇此路徑';
	@override String get pathValidationFailed => '路徑驗證失敗';
	@override String get downloadPathSetTo => '下載路徑已設定為';
	@override String get setPathFailed => '設定路徑失敗';
	@override String get variableTitle => '標題';
	@override String get variableAuthor => '作者名稱';
	@override String get variableUsername => '作者使用者名稱';
	@override String get variableQuality => '影片品質';
	@override String get variableFilename => '原始檔案名稱';
	@override String get variableId => '內容ID';
	@override String get variableCount => '圖庫圖片數量';
	@override String get variableDate => '目前日期 (YYYY-MM-DD)';
	@override String get variableTime => '目前時間 (HH-MM-SS)';
	@override String get variableDatetime => '目前日期時間 (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => '下載設定';
	@override String get downloadSettingsSubtitle => '設定下載路徑和檔案命名規則';
	@override String get suchAsTitleQuality => '例如: %title_%quality';
	@override String get suchAsTitleId => '例如: %title_%id';
	@override String get suchAsTitleFilename => '例如: %title_%filename';
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesZhTw implements TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get hot => '熱門';
	@override String get favorites => '高評價';
	@override String get latest => '最新';
	@override String get popularity => '人氣';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsZhTw implements TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => '請求失敗，狀態碼';
	@override String get connectionTimeout => '連接超時，請檢查網路連接';
	@override String get sendTimeout => '發送請求超時';
	@override String get receiveTimeout => '接收響應超時';
	@override String get badCertificate => '證書驗證失敗';
	@override String get resourceNotFound => '請求的資源不存在';
	@override String get accessDenied => '訪問被拒絕，可能需要驗證或權限';
	@override String get serverError => '伺服器內部錯誤';
	@override String get serviceUnavailable => '服務暫時不可用';
	@override String get requestCancelled => '請求已取消';
	@override String get connectionError => '網路連接錯誤，請檢查網路設置';
	@override String get networkRequestFailed => '網路請求失敗';
	@override String get searchVideoError => '搜索視頻時發生未知錯誤';
	@override String get getPopularVideoError => '獲取熱門視頻時發生未知錯誤';
	@override String get getVideoDetailError => '獲取視頻詳情時發生未知錯誤';
	@override String get parseVideoDetailError => '獲取並解析視頻詳情時發生未知錯誤';
	@override String get downloadFileError => '下載文件時發生未知錯誤';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingZhTw implements TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => '正在獲取視頻信息...';
	@override String get cancel => '取消';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesZhTw implements TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => '視頻不存在或已被刪除';
	@override String get unableToGetVideoPlayLink => '無法獲取視頻播放鏈接';
	@override String get getVideoDetailFailed => '獲取視頻詳情失敗';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonZhTw implements TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => '取得影片資訊中...';
	@override String get fetchingVideoSources => '取得影片來源中...';
	@override String get loadingVideo => '正在加載影片...';
}

// Path: forum.errors
class _TranslationsForumErrorsZhTw implements TranslationsForumErrorsEn {
	_TranslationsForumErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => '請選擇分類';
	@override String get threadLocked => '該主題已鎖定，無法回覆';
}

// Path: forum.groups
class _TranslationsForumGroupsZhTw implements TranslationsForumGroupsEn {
	_TranslationsForumGroupsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get administration => '管理';
	@override String get global => '全球';
	@override String get chinese => '中文';
	@override String get japanese => '日語';
	@override String get korean => '韓語';
	@override String get other => '其他';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesZhTw implements TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get announcements => '公告';
	@override String get feedback => '反饋';
	@override String get support => '幫助';
	@override String get general => '一般';
	@override String get guides => '指南';
	@override String get questions => '問題';
	@override String get requests => '請求';
	@override String get sharing => '分享';
	@override String get general_zh => '一般';
	@override String get questions_zh => '問題';
	@override String get requests_zh => '請求';
	@override String get support_zh => '幫助';
	@override String get general_ja => '一般';
	@override String get questions_ja => '問題';
	@override String get requests_ja => '請求';
	@override String get support_ja => '幫助';
	@override String get korean => '韓語';
	@override String get other => '其他';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsZhTw implements TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get announcements => '官方重要通知和公告';
	@override String get feedback => '對網站功能和服務的反饋';
	@override String get support => '幫助解決網站相關問題';
	@override String get general => '討論任何話題';
	@override String get guides => '分享你的經驗和教程';
	@override String get questions => '提出你的疑問';
	@override String get requests => '發布你的請求';
	@override String get sharing => '分享有趣的內容';
	@override String get general_zh => '討論任何話題';
	@override String get questions_zh => '提出你的疑問';
	@override String get requests_zh => '發布你的請求';
	@override String get support_zh => '幫助解決網站相關問題';
	@override String get general_ja => '討論任何話題';
	@override String get questions_ja => '提出你的疑問';
	@override String get requests_ja => '發布你的請求';
	@override String get support_ja => '幫助解決網站相關問題';
	@override String get korean => '韓語相關討論';
	@override String get other => '其他未分類的內容';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsZhTw implements TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => '暫不支持的通知類型';
	@override String get unknownUser => '未知用戶';
	@override String unsupportedNotificationTypeWithType({required Object type}) => '暫不支持的通知類型: ${type}';
	@override String get unknownNotificationType => '未知通知類型';
}

// Path: conversation.errors
class _TranslationsConversationErrorsZhTw implements TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => '請選擇一個用戶';
	@override String get pleaseEnterATitle => '請輸入標題';
	@override String get clickToSelectAUser => '點擊選擇用戶';
	@override String get loadFailedClickToRetry => '加載失敗,點擊重試';
	@override String get loadFailed => '加載失敗';
	@override String get clickToRetry => '點擊重試';
	@override String get noMoreConversations => '沒有更多消息了';
}

// Path: splash.errors
class _TranslationsSplashErrorsZhTw implements TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => '初始化失敗，請重啟應用';
}

// Path: download.errors
class _TranslationsDownloadErrorsZhTw implements TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => '圖庫信息不存在';
	@override String get downloadFailed => '下載失敗';
	@override String get videoInfoNotFound => '影片信息不存在';
	@override String get unknown => '未知';
	@override String get downloadTaskAlreadyExists => '下載任務已存在';
	@override String get videoAlreadyDownloaded => '該影片已下載';
	@override String downloadFailedForMessage({required Object errorInfo}) => '添加下載任務失敗: ${errorInfo}';
	@override String get userPausedDownload => '用戶暫停下載';
	@override String fileSystemError({required Object errorInfo}) => '文件系統錯誤: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => '未知錯誤: ${errorInfo}';
	@override String get connectionTimeout => '連接超時';
	@override String get sendTimeout => '發送超時';
	@override String get receiveTimeout => '接收超時';
	@override String serverError({required Object errorInfo}) => '伺服器錯誤: ${errorInfo}';
	@override String get unknownNetworkError => '未知網路錯誤';
	@override String get serviceIsClosing => '下載服務正在關閉';
	@override String get partialDownloadFailed => '部分內容下載失敗';
	@override String get noDownloadTask => '暫無下載任務';
	@override String get taskNotFoundOrDataError => '任務不存在或資料錯誤';
	@override String get copyDownloadUrlFailed => '複製下載連結失敗';
	@override String get fileNotFound => '文件不存在';
	@override String get openFolderFailed => '打開文件夾失敗';
	@override String openFolderFailedWithMessage({required Object message}) => '打開文件夾失敗: ${message}';
	@override String get directoryNotFound => '目錄不存在';
	@override String get copyFailed => '複製失敗';
	@override String get openFileFailed => '打開文件失敗';
	@override String openFileFailedWithMessage({required Object message}) => '打開文件失敗: ${message}';
	@override String get noDownloadSource => '沒有下載源';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => '暫無下載源，請等待信息加載完成後重試';
	@override String get noActiveDownloadTask => '暫無正在下載的任務';
	@override String get noFailedDownloadTask => '暫無失敗的任務';
	@override String get noCompletedDownloadTask => '暫無已完成的任務';
	@override String get taskAlreadyCompletedDoNotAdd => '任務已完成，請勿重複添加';
	@override String get linkExpiredTryAgain => '連結已過期，正在重新獲取下載連結';
	@override String get linkExpiredTryAgainSuccess => '連結已過期，正在重新獲取下載連結成功';
	@override String get linkExpiredTryAgainFailed => '連結已過期，正在重新獲取下載連結失敗';
	@override String get taskDeleted => '任務已刪除';
	@override String unsupportedImageFormat({required Object format}) => '不支持的圖片格式: ${format}';
	@override String get deleteFileError => '文件删除失败，可能是因为文件被占用';
	@override String get deleteTaskError => '任务删除失败';
	@override String get taskNotFound => '任务未找到';
	@override String get canNotRefreshVideoTask => '無法刷新視頻任務';
	@override String get taskAlreadyProcessing => '任務已處理中';
	@override String get failedToLoadTasks => '加載任務失敗';
	@override String partialDownloadFailedWithMessage({required Object message}) => '部分下載失敗: ${message}';
	@override String get pleaseTryOtherViewer => '請嘗試使用其他查看器打開';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => '不支持的圖片格式: ${extension}, 可以嘗試下載到設備上查看';
	@override String get imageLoadFailed => '圖片加載失敗';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsZhTw implements TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get addFailed => '追加失敗';
	@override String get addSuccess => '追加成功';
	@override String get deleteFolderFailed => '刪除文件夾失敗';
	@override String get deleteFolderSuccess => '刪除文件夾成功';
	@override String get folderNameCannotBeEmpty => '資料夾名稱不能為空';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Love Iwara';
			case 'common.ok': return '確定';
			case 'common.cancel': return '取消';
			case 'common.save': return '儲存';
			case 'common.delete': return '刪除';
			case 'common.visit': return '訪問';
			case 'common.loading': return '載入中...';
			case 'common.scrollToTop': return '滾動到頂部';
			case 'common.privacyHint': return '隱私內容，不與展示';
			case 'common.latest': return '最新';
			case 'common.likesCount': return '按讚數';
			case 'common.viewsCount': return '觀看次數';
			case 'common.popular': return '受歡迎的';
			case 'common.trending': return '趨勢';
			case 'common.commentList': return '評論列表';
			case 'common.sendComment': return '發表評論';
			case 'common.send': return '發表';
			case 'common.retry': return '重試';
			case 'common.premium': return '高級會員';
			case 'common.follower': return '粉絲';
			case 'common.friend': return '朋友';
			case 'common.video': return '影片';
			case 'common.following': return '追蹤中';
			case 'common.expand': return '展開';
			case 'common.collapse': return '收起';
			case 'common.cancelFriendRequest': return '取消申請';
			case 'common.cancelSpecialFollow': return '取消特別關注';
			case 'common.addFriend': return '加為朋友';
			case 'common.removeFriend': return '解除朋友';
			case 'common.followed': return '已追蹤';
			case 'common.follow': return '追蹤';
			case 'common.unfollow': return '取消追蹤';
			case 'common.specialFollow': return '特別關注';
			case 'common.specialFollowed': return '已特別關注';
			case 'common.gallery': return '圖庫';
			case 'common.playlist': return '播放清單';
			case 'common.commentPostedSuccessfully': return '評論發表成功';
			case 'common.commentPostedFailed': return '評論發表失敗';
			case 'common.success': return '成功';
			case 'common.commentDeletedSuccessfully': return '評論已刪除';
			case 'common.commentUpdatedSuccessfully': return '評論已更新';
			case 'common.totalComments': return ({required Object count}) => '評論 ${count} 則';
			case 'common.writeYourCommentHere': return '請寫下你的評論...';
			case 'common.tmpNoReplies': return '暫無回覆';
			case 'common.loadMore': return '載入更多';
			case 'common.noMoreDatas': return '沒有更多資料了';
			case 'common.selectTranslationLanguage': return '選擇翻譯語言';
			case 'common.translate': return '翻譯';
			case 'common.translateFailedPleaseTryAgainLater': return '翻譯失敗，請稍後再試';
			case 'common.translationResult': return '翻譯結果';
			case 'common.justNow': return '剛剛';
			case 'common.minutesAgo': return ({required Object num}) => '${num} 分鐘前';
			case 'common.hoursAgo': return ({required Object num}) => '${num} 小時前';
			case 'common.daysAgo': return ({required Object num}) => '${num} 天前';
			case 'common.editedAt': return ({required Object num}) => '${num} 編輯';
			case 'common.editComment': return '編輯評論';
			case 'common.commentUpdated': return '評論已更新';
			case 'common.replyComment': return '回覆評論';
			case 'common.reply': return '回覆';
			case 'common.edit': return '編輯';
			case 'common.unknownUser': return '未知使用者';
			case 'common.me': return '我';
			case 'common.author': return '作者';
			case 'common.admin': return '管理員';
			case 'common.viewReplies': return ({required Object num}) => '查看回覆 (${num})';
			case 'common.hideReplies': return '隱藏回覆';
			case 'common.confirmDelete': return '確認刪除';
			case 'common.areYouSureYouWantToDeleteThisItem': return '確定要刪除這筆資料嗎？';
			case 'common.tmpNoComments': return '暫無評論';
			case 'common.refresh': return '更新';
			case 'common.back': return '返回';
			case 'common.tips': return '提示';
			case 'common.linkIsEmpty': return '連結地址為空';
			case 'common.linkCopiedToClipboard': return '連結地址已複製到剪貼簿';
			case 'common.imageCopiedToClipboard': return '圖片已複製到剪貼簿';
			case 'common.copyImageFailed': return '複製圖片失敗';
			case 'common.mobileSaveImageIsUnderDevelopment': return '移動端的儲存圖片功能尚在開發中';
			case 'common.imageSavedTo': return '圖片已儲存至';
			case 'common.saveImageFailed': return '儲存圖片失敗';
			case 'common.close': return '關閉';
			case 'common.more': return '更多';
			case 'common.moreFeaturesToBeDeveloped': return '更多功能待開發';
			case 'common.all': return '全部';
			case 'common.selectedRecords': return ({required Object num}) => '已選擇 ${num} 筆資料';
			case 'common.cancelSelectAll': return '取消全選';
			case 'common.selectAll': return '全選';
			case 'common.exitEditMode': return '退出編輯模式';
			case 'common.areYouSureYouWantToDeleteSelectedItems': return ({required Object num}) => '確定要刪除選中的 ${num} 筆資料嗎？';
			case 'common.searchHistoryRecords': return '搜尋歷史紀錄...';
			case 'common.settings': return '設定';
			case 'common.subscriptions': return '訂閱';
			case 'common.videoCount': return ({required Object num}) => '${num} 支影片';
			case 'common.share': return '分享';
			case 'common.areYouSureYouWantToShareThisPlaylist': return '要分享這個播放清單嗎？';
			case 'common.editTitle': return '編輯標題';
			case 'common.editMode': return '編輯模式';
			case 'common.pleaseEnterNewTitle': return '請輸入新標題';
			case 'common.createPlayList': return '創建播放清單';
			case 'common.create': return '創建';
			case 'common.checkNetworkSettings': return '檢查網路設定';
			case 'common.general': return '大眾';
			case 'common.r18': return 'R18';
			case 'common.sensitive': return '敏感';
			case 'common.year': return '年份';
			case 'common.month': return '月份';
			case 'common.tag': return '標籤';
			case 'common.private': return '私密';
			case 'common.noTitle': return '無標題';
			case 'common.search': return '搜尋';
			case 'common.noContent': return '沒有內容哦';
			case 'common.recording': return '記錄中';
			case 'common.paused': return '已暫停';
			case 'common.clear': return '清除';
			case 'common.user': return '使用者';
			case 'common.post': return '投稿';
			case 'common.seconds': return '秒';
			case 'common.comingSoon': return '敬請期待';
			case 'common.confirm': return '確認';
			case 'common.hour': return '小時';
			case 'common.minute': return '分鐘';
			case 'common.clickToRefresh': return '點擊更新';
			case 'common.history': return '歷史紀錄';
			case 'common.favorites': return '最愛';
			case 'common.friends': return '朋友';
			case 'common.playList': return '播放清單';
			case 'common.checkLicense': return '查看授權';
			case 'common.logout': return '登出';
			case 'common.fensi': return '粉絲';
			case 'common.accept': return '接受';
			case 'common.reject': return '拒絕';
			case 'common.clearAllHistory': return '清空所有歷史紀錄';
			case 'common.clearAllHistoryConfirm': return '確定要清空所有歷史紀錄嗎？';
			case 'common.followingList': return '追蹤中列表';
			case 'common.followersList': return '粉絲列表';
			case 'common.follows': return '追蹤';
			case 'common.fans': return '粉絲';
			case 'common.followsAndFans': return '追蹤與粉絲';
			case 'common.numViews': return '觀看次數';
			case 'common.updatedAt': return '更新時間';
			case 'common.publishedAt': return '發布時間';
			case 'common.download': return '下載';
			case 'common.selectQuality': return '選擇畫質';
			case 'common.externalVideo': return '站外影片';
			case 'common.originalText': return '原文';
			case 'common.showOriginalText': return '顯示原始文本';
			case 'common.showProcessedText': return '顯示處理後文本';
			case 'common.preview': return '預覽';
			case 'common.rules': return '規則';
			case 'common.agree': return '同意';
			case 'common.disagree': return '不同意';
			case 'common.agreeToRules': return '同意規則';
			case 'common.createPost': return '創建投稿';
			case 'common.title': return '標題';
			case 'common.enterTitle': return '請輸入標題';
			case 'common.content': return '內容';
			case 'common.enterContent': return '請輸入內容';
			case 'common.writeYourContentHere': return '請輸入內容...';
			case 'common.tagBlacklist': return '黑名單標籤';
			case 'common.noData': return '沒有資料';
			case 'common.tagLimit': return '標籤上限';
			case 'common.enableFloatingButtons': return '啟用浮動按鈕';
			case 'common.disableFloatingButtons': return '禁用浮動按鈕';
			case 'common.enabledFloatingButtons': return '已啟用浮動按鈕';
			case 'common.disabledFloatingButtons': return '已禁用浮動按鈕';
			case 'common.pendingCommentCount': return '待審核評論';
			case 'common.joined': return ({required Object str}) => '加入於 ${str}';
			case 'common.selectDateRange': return '選擇日期範圍';
			case 'common.selectDateRangeHint': return '選擇日期範圍，默認選擇最近30天';
			case 'common.clearDateRange': return '清除日期範圍';
			case 'common.followSuccessClickAgainToSpecialFollow': return '已成功關注，再次點擊以特別關注';
			case 'common.exitConfirmTip': return '確定要退出嗎？';
			case 'common.error': return '錯誤';
			case 'common.taskRunning': return '任務正在進行中，請稍後再試。';
			case 'common.operationCancelled': return '操作已取消。';
			case 'common.unsavedChanges': return '您有未儲存的更改';
			case 'common.specialFollowsManagementTip': return '拖動可重新排序 • 向左滑動可移除';
			case 'common.specialFollowsManagement': return '特別關注管理';
			case 'common.pagination.totalItems': return ({required Object num}) => '共 ${num} 項';
			case 'common.pagination.jumpToPage': return '跳轉到指定頁面';
			case 'common.pagination.pleaseEnterPageNumber': return ({required Object max}) => '請輸入頁碼 (1-${max})';
			case 'common.pagination.pageNumber': return '頁碼';
			case 'common.pagination.jump': return '跳轉';
			case 'common.pagination.invalidPageNumber': return ({required Object max}) => '請輸入有效頁碼 (1-${max})';
			case 'common.pagination.invalidInput': return '請輸入有效頁碼';
			case 'common.pagination.waterfall': return '瀑布流';
			case 'common.pagination.pagination': return '分頁';
			case 'common.notice': return '通知';
			case 'common.detail': return '詳情';
			case 'common.parseExceptionDestopHint': return ' - 桌面端用戶可以在設置中配置代理';
			case 'common.iwaraTags': return 'Iwara 標籤';
			case 'common.likeThisVideo': return '喜歡這個影片的人';
			case 'common.operation': return '操作';
			case 'common.replies': return '回覆';
			case 'auth.login': return '登入';
			case 'auth.logout': return '登出';
			case 'auth.email': return '電子郵件';
			case 'auth.password': return '密碼';
			case 'auth.loginOrRegister': return '登入 / 註冊';
			case 'auth.register': return '註冊';
			case 'auth.pleaseEnterEmail': return '請輸入電子郵件';
			case 'auth.pleaseEnterPassword': return '請輸入密碼';
			case 'auth.passwordMustBeAtLeast6Characters': return '密碼至少需要 6 位';
			case 'auth.pleaseEnterCaptcha': return '請輸入驗證碼';
			case 'auth.captcha': return '驗證碼';
			case 'auth.refreshCaptcha': return '更新驗證碼';
			case 'auth.captchaNotLoaded': return '無法載入驗證碼';
			case 'auth.loginSuccess': return '登入成功';
			case 'auth.emailVerificationSent': return '已發送郵件驗證指令';
			case 'auth.notLoggedIn': return '尚未登入';
			case 'auth.clickToLogin': return '點擊此處登入';
			case 'auth.logoutConfirmation': return '你確定要登出嗎？';
			case 'auth.logoutSuccess': return '登出成功';
			case 'auth.logoutFailed': return '登出失敗';
			case 'auth.usernameOrEmail': return '用戶名或電子郵件';
			case 'auth.pleaseEnterUsernameOrEmail': return '請輸入用戶名或電子郵件';
			case 'auth.rememberMe': return '記住帳號密碼';
			case 'errors.error': return '錯誤';
			case 'errors.required': return '此項為必填';
			case 'errors.invalidEmail': return '電子郵件格式錯誤';
			case 'errors.networkError': return '網路錯誤，請重試';
			case 'errors.errorWhileFetching': return '取得資料失敗';
			case 'errors.commentCanNotBeEmpty': return '評論內容不能為空';
			case 'errors.errorWhileFetchingReplies': return '取得回覆時出錯，請檢查網路連線';
			case 'errors.canNotFindCommentController': return '無法找到評論控制器';
			case 'errors.errorWhileLoadingGallery': return '載入圖庫時出錯';
			case 'errors.howCouldThereBeNoDataItCantBePossible': return '啊？怎麼會沒有資料呢？出錯了吧 :<';
			case 'errors.unsupportedImageFormat': return ({required Object str}) => '不支援的圖片格式: ${str}';
			case 'errors.invalidGalleryId': return '無效的圖庫ID';
			case 'errors.translationFailedPleaseTryAgainLater': return '翻譯失敗，請稍後再試';
			case 'errors.errorOccurred': return '發生錯誤，請稍後再試。';
			case 'errors.errorOccurredWhileProcessingRequest': return '處理請求時出錯';
			case 'errors.errorWhileFetchingDatas': return '取得資料時出錯，請稍後再試';
			case 'errors.serviceNotInitialized': return '服務未初始化';
			case 'errors.unknownType': return '未知類型';
			case 'errors.errorWhileOpeningLink': return ({required Object link}) => '無法開啟連結: ${link}';
			case 'errors.invalidUrl': return '無效的URL';
			case 'errors.failedToOperate': return '操作失敗';
			case 'errors.permissionDenied': return '權限不足';
			case 'errors.youDoNotHavePermissionToAccessThisResource': return '您沒有權限訪問此資源';
			case 'errors.loginFailed': return '登入失敗';
			case 'errors.unknownError': return '未知錯誤';
			case 'errors.sessionExpired': return '會話已過期';
			case 'errors.failedToFetchCaptcha': return '獲取驗證碼失敗';
			case 'errors.emailAlreadyExists': return '電子郵件已存在';
			case 'errors.invalidCaptcha': return '無效的驗證碼';
			case 'errors.registerFailed': return '註冊失敗';
			case 'errors.failedToFetchComments': return '獲取評論失敗';
			case 'errors.failedToFetchImageDetail': return '獲取圖庫詳情失敗';
			case 'errors.failedToFetchImageList': return '獲取圖庫列表失敗';
			case 'errors.failedToFetchData': return '獲取資料失敗';
			case 'errors.invalidParameter': return '無效的參數';
			case 'errors.pleaseLoginFirst': return '請先登入';
			case 'errors.errorWhileLoadingPost': return '載入投稿內容時出錯';
			case 'errors.errorWhileLoadingPostDetail': return '載入投稿詳情時出錯';
			case 'errors.invalidPostId': return '無效的投稿ID';
			case 'errors.forceUpdateNotPermittedToGoBack': return '目前處於強制更新狀態，無法返回';
			case 'errors.pleaseLoginAgain': return '請重新登入';
			case 'errors.invalidLogin': return '登入失敗，請檢查電子郵件和密碼';
			case 'errors.tooManyRequests': return '請求過多，請稍後再試';
			case 'errors.exceedsMaxLength': return ({required Object max}) => '超出最大長度: ${max}';
			case 'errors.contentCanNotBeEmpty': return '內容不能為空';
			case 'errors.titleCanNotBeEmpty': return '標題不能為空';
			case 'errors.tooManyRequestsPleaseTryAgainLaterText': return '請求過多，請稍後再試，剩餘時間';
			case 'errors.remainingHours': return ({required Object num}) => '${num}小時';
			case 'errors.remainingMinutes': return ({required Object num}) => '${num}分';
			case 'errors.remainingSeconds': return ({required Object num}) => '${num}秒';
			case 'errors.tagLimitExceeded': return ({required Object limit}) => '標籤上限超出，上限: ${limit}';
			case 'errors.failedToRefresh': return '更新失敗';
			case 'errors.noPermission': return '權限不足';
			case 'errors.resourceNotFound': return '資源不存在';
			case 'errors.failedToSaveCredentials': return '無法安全保存登入資訊';
			case 'errors.failedToLoadSavedCredentials': return '載入保存的登入資訊失敗';
			case 'errors.specialFollowLimitReached': return ({required Object cnt}) => '特別關注上限超出，上限: ${cnt}，請於關注列表頁中調整';
			case 'errors.notFound': return '內容不存在或已被刪除';
			case 'errors.network.basicPrefix': return '網路錯誤 - ';
			case 'errors.network.failedToConnectToServer': return '連接伺服器失敗';
			case 'errors.network.serverNotAvailable': return '伺服器不可用';
			case 'errors.network.requestTimeout': return '請求超時';
			case 'errors.network.unexpectedError': return '意外錯誤';
			case 'errors.network.invalidResponse': return '無效的回應';
			case 'errors.network.invalidRequest': return '無效的請求';
			case 'errors.network.invalidUrl': return '無效的URL';
			case 'errors.network.invalidMethod': return '無效的方法';
			case 'errors.network.invalidHeader': return '無效的頭部';
			case 'errors.network.invalidBody': return '無效的體';
			case 'errors.network.invalidStatusCode': return '無效的狀態碼';
			case 'errors.network.serverError': return '伺服器錯誤';
			case 'errors.network.requestCanceled': return '請求已取消';
			case 'errors.network.invalidPort': return '無効な埠口';
			case 'errors.network.proxyPortError': return '代理埠口設定異常';
			case 'errors.network.connectionRefused': return '連接被拒絕';
			case 'errors.network.networkUnreachable': return '網路不可達';
			case 'errors.network.noRouteToHost': return '無法找到主機';
			case 'errors.network.connectionFailed': return '連接失敗';
			case 'errors.network.sslConnectionFailed': return 'SSL連接失敗，請檢查網絡設置';
			case 'friends.clickToRestoreFriend': return '點擊恢復朋友';
			case 'friends.friendsList': return '朋友列表';
			case 'friends.friendRequests': return '朋友請求';
			case 'friends.friendRequestsList': return '朋友請求列表';
			case 'friends.removingFriend': return '正在解除好友關係...';
			case 'friends.failedToRemoveFriend': return '解除好友關係失敗';
			case 'friends.cancelingRequest': return '正在取消好友申請...';
			case 'friends.failedToCancelRequest': return '取消好友申請失敗';
			case 'authorProfile.noMoreDatas': return '沒有更多資料了';
			case 'authorProfile.userProfile': return '使用者資料';
			case 'favorites.clickToRestoreFavorite': return '點擊恢復最愛';
			case 'favorites.myFavorites': return '我的最愛';
			case 'galleryDetail.galleryDetail': return '圖庫詳情';
			case 'galleryDetail.viewGalleryDetail': return '查看圖庫詳情';
			case 'galleryDetail.copyLink': return '複製連結地址';
			case 'galleryDetail.copyImage': return '複製圖片';
			case 'galleryDetail.saveAs': return '另存為';
			case 'galleryDetail.saveToAlbum': return '儲存到相簿';
			case 'galleryDetail.publishedAt': return '發布時間';
			case 'galleryDetail.viewsCount': return '觀看次數';
			case 'galleryDetail.imageLibraryFunctionIntroduction': return '圖庫功能介紹';
			case 'galleryDetail.rightClickToSaveSingleImage': return '右鍵儲存單張圖片';
			case 'galleryDetail.batchSave': return '批次儲存';
			case 'galleryDetail.keyboardLeftAndRightToSwitch': return '鍵盤左右控制切換';
			case 'galleryDetail.keyboardUpAndDownToZoom': return '鍵盤上下控制縮放';
			case 'galleryDetail.mouseWheelToSwitch': return '滑鼠滾輪控制切換';
			case 'galleryDetail.ctrlAndMouseWheelToZoom': return 'CTRL + 滑鼠滾輪控制縮放';
			case 'galleryDetail.moreFeaturesToBeDiscovered': return '更多功能待發掘...';
			case 'galleryDetail.authorOtherGalleries': return '作者的其他圖庫';
			case 'galleryDetail.relatedGalleries': return '相關圖庫';
			case 'galleryDetail.clickLeftAndRightEdgeToSwitchImage': return '點擊左右邊緣以切換圖片';
			case 'playList.myPlayList': return '我的播放清單';
			case 'playList.friendlyTips': return '友情提示';
			case 'playList.dearUser': return '親愛的使用者';
			case 'playList.iwaraPlayListSystemIsNotPerfectYet': return 'iwara的播放清單系統目前還不太完善';
			case 'playList.notSupportSetCover': return '不支援設定封面';
			case 'playList.notSupportDeleteList': return '無法刪除播放清單';
			case 'playList.notSupportSetPrivate': return '無法設為私密';
			case 'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone': return '沒錯...創建的播放清單會一直存在且對所有人可見';
			case 'playList.smallSuggestion': return '小建議';
			case 'playList.useLikeToCollectContent': return '如果您比較注重隱私，建議使用"按讚"功能來收藏內容';
			case 'playList.welcomeToDiscussOnGitHub': return '如果你有其他建議或想法，歡迎來 GitHub 討論！';
			case 'playList.iUnderstand': return '明白了';
			case 'playList.searchPlaylists': return '搜尋播放清單...';
			case 'playList.newPlaylistName': return '新播放清單名稱';
			case 'playList.createNewPlaylist': return '創建新播放清單';
			case 'playList.videos': return '影片';
			case 'search.googleSearchScope': return '搜尋範圍';
			case 'search.searchTags': return '搜尋標籤...';
			case 'search.contentRating': return '內容分級';
			case 'search.removeTag': return '移除標籤';
			case 'search.pleaseEnterSearchContent': return '請輸入搜尋內容';
			case 'search.searchHistory': return '搜尋歷史';
			case 'search.searchSuggestion': return '搜尋建議';
			case 'search.usedTimes': return '使用次數';
			case 'search.lastUsed': return '最後使用';
			case 'search.noSearchHistoryRecords': return '沒有搜尋歷史';
			case 'search.notSupportCurrentSearchType': return ({required Object searchType}) => '目前尚未支援此搜尋類型 ${searchType}，敬請期待';
			case 'search.searchResult': return '搜尋結果';
			case 'search.unsupportedSearchType': return ({required Object searchType}) => '不支援的搜尋類型: ${searchType}';
			case 'search.googleSearch': return '谷歌搜尋';
			case 'search.googleSearchHint': return ({required Object webName}) => '${webName} 的搜尋功能不好用？嘗試谷歌搜尋！';
			case 'search.googleSearchDescription': return '借助谷歌搜索的 :site 搜索運算符，您可以通過外部引擎來對站內的內容進行檢索，此功能在搜尋 影片、圖庫、播放清單、用戶 時非常有用。';
			case 'search.googleSearchKeywordsHint': return '輸入要搜尋的關鍵詞';
			case 'search.openLinkJump': return '打開連結跳轉';
			case 'search.googleSearchButton': return '谷歌搜尋';
			case 'search.pleaseEnterSearchKeywords': return '請輸入搜尋關鍵詞';
			case 'search.googleSearchQueryCopied': return '搜尋語句已複製到剪貼簿';
			case 'search.googleSearchBrowserOpenFailed': return ({required Object error}) => '無法打開瀏覽器: ${error}';
			case 'mediaList.personalIntroduction': return '個人簡介';
			case 'settings.listViewMode': return '列表顯示模式';
			case 'settings.useTraditionalPaginationMode': return '使用傳統分頁模式';
			case 'settings.useTraditionalPaginationModeDesc': return '開啟後列表將使用傳統分頁模式，關閉則使用瀑布流模式';
			case 'settings.showVideoProgressBottomBarWhenToolbarHidden': return '顯示底部進度條';
			case 'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc': return '此設定決定是否在工具欄隱藏時顯示底部進度條';
			case 'settings.basicSettings': return '基礎設定';
			case 'settings.personalizedSettings': return '個性化設定';
			case 'settings.otherSettings': return '其他設定';
			case 'settings.searchConfig': return '搜尋設定';
			case 'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain': return '此設定將決定您之後播放影片時是否會沿用之前的設定。';
			case 'settings.playControl': return '播放控制';
			case 'settings.fastForwardTime': return '快進時間';
			case 'settings.fastForwardTimeMustBeAPositiveInteger': return '快進時間必須是正整數。';
			case 'settings.rewindTime': return '快退時間';
			case 'settings.rewindTimeMustBeAPositiveInteger': return '快退時間必須是正整數。';
			case 'settings.longPressPlaybackSpeed': return '長按播放倍速';
			case 'settings.longPressPlaybackSpeedMustBeAPositiveNumber': return '長按播放倍速必須是正數。';
			case 'settings.repeat': return '循環播放';
			case 'settings.renderVerticalVideoInVerticalScreen': return '全螢幕播放時以直向模式呈現直向影片';
			case 'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen': return '此設定將決定當您在全螢幕播放時，是否以直向模式呈現直向影片。';
			case 'settings.rememberVolume': return '記住音量';
			case 'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain': return '此設定將決定當您之後播放影片時，是否會保留先前的音量設定。';
			case 'settings.rememberBrightness': return '記住亮度';
			case 'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain': return '此設定將決定當您之後播放影片時，是否會保留先前的亮度設定。';
			case 'settings.playControlArea': return '播放控制區域';
			case 'settings.leftAndRightControlAreaWidth': return '左右控制區域寬度';
			case 'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer': return '此設定將決定播放器左右兩側控制區域的寬度。';
			case 'settings.proxyAddressCannotBeEmpty': return '代理伺服器地址不能為空。';
			case 'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort': return '無效的代理伺服器地址格式，請使用 IP:端口 或 域名:端口 格式。';
			case 'settings.proxyNormalWork': return '代理伺服器正常工作。';
			case 'settings.testProxyFailedWithStatusCode': return ({required Object code}) => '代理請求失敗，狀態碼: ${code}';
			case 'settings.testProxyFailedWithException': return ({required Object exception}) => '代理請求出錯: ${exception}';
			case 'settings.proxyConfig': return '代理設定';
			case 'settings.thisIsHttpProxyAddress': return '此為 HTTP 代理伺服器地址';
			case 'settings.checkProxy': return '檢查代理';
			case 'settings.proxyAddress': return '代理地址';
			case 'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080': return '請輸入代理伺服器的 URL，例如 127.0.0.1:8080';
			case 'settings.enableProxy': return '啟用代理';
			case 'settings.left': return '左側';
			case 'settings.middle': return '中間';
			case 'settings.right': return '右側';
			case 'settings.playerSettings': return '播放器設定';
			case 'settings.networkSettings': return '網路設定';
			case 'settings.customizeYourPlaybackExperience': return '自訂您的播放體驗';
			case 'settings.chooseYourFavoriteAppAppearance': return '選擇您喜愛的應用程式外觀';
			case 'settings.configureYourProxyServer': return '配置您的代理伺服器';
			case 'settings.settings': return '設定';
			case 'settings.themeSettings': return '主題設定';
			case 'settings.followSystem': return '跟隨系統';
			case 'settings.lightMode': return '淺色模式';
			case 'settings.darkMode': return '深色模式';
			case 'settings.presetTheme': return '預設主題';
			case 'settings.basicTheme': return '基礎主題';
			case 'settings.needRestartToApply': return '需要重啟應用以應用設定';
			case 'settings.themeNeedRestartDescription': return '主題設定需要重啟應用以應用設定';
			case 'settings.about': return '關於';
			case 'settings.currentVersion': return '當前版本';
			case 'settings.latestVersion': return '最新版本';
			case 'settings.checkForUpdates': return '檢查更新';
			case 'settings.update': return '更新';
			case 'settings.newVersionAvailable': return '發現新版本';
			case 'settings.projectHome': return '開源地址';
			case 'settings.release': return '版本發布';
			case 'settings.issueReport': return '問題回報';
			case 'settings.openSourceLicense': return '開源許可';
			case 'settings.checkForUpdatesFailed': return '檢查更新失敗，請稍後重試';
			case 'settings.autoCheckUpdate': return '自動檢查更新';
			case 'settings.updateContent': return '更新內容';
			case 'settings.releaseDate': return '發布日期';
			case 'settings.ignoreThisVersion': return '忽略此版本';
			case 'settings.minVersionUpdateRequired': return '當前版本過低，請盡快更新';
			case 'settings.forceUpdateTip': return '此版本為強制更新，請盡快更新到最新版本';
			case 'settings.viewChangelog': return '查看更新日誌';
			case 'settings.alreadyLatestVersion': return '已是最新版本';
			case 'settings.appSettings': return '應用設定';
			case 'settings.configureYourAppSettings': return '配置您的應用程式設定';
			case 'settings.history': return '歷史記錄';
			case 'settings.autoRecordHistory': return '自動記錄歷史記錄';
			case 'settings.autoRecordHistoryDesc': return '自動記錄您觀看過的影片和圖庫等信息';
			case 'settings.showUnprocessedMarkdownText': return '顯示未處理文本';
			case 'settings.showUnprocessedMarkdownTextDesc': return '顯示Markdown的原始文本';
			case 'settings.markdown': return 'Markdown';
			case 'settings.activeBackgroundPrivacyMode': return '隱私模式';
			case 'settings.activeBackgroundPrivacyModeDesc': return '禁止截圖、後台運行時隱藏畫面...';
			case 'settings.privacy': return '隱私';
			case 'settings.forum': return '論壇';
			case 'settings.disableForumReplyQuote': return '禁用論壇回覆引用';
			case 'settings.disableForumReplyQuoteDesc': return '禁用論壇回覆時攜帶被回覆樓層資訊';
			case 'settings.theaterMode': return '劇院模式';
			case 'settings.theaterModeDesc': return '開啟後，播放器背景會被設置為影片封面的模糊版本';
			case 'settings.appLinks': return '應用鏈接';
			case 'settings.defaultBrowser': return '預設瀏覽';
			case 'settings.defaultBrowserDesc': return '請在系統設定中打開預設鏈接配置項，並添加iwara.tv網站鏈接';
			case 'settings.themeMode': return '主題模式';
			case 'settings.themeModeDesc': return '此配置決定應用的主題模式';
			case 'settings.dynamicColor': return '動態顏色';
			case 'settings.dynamicColorDesc': return '此配置決定應用是否使用動態顏色';
			case 'settings.useDynamicColor': return '使用動態顏色';
			case 'settings.useDynamicColorDesc': return '此配置決定應用是否使用動態顏色';
			case 'settings.presetColors': return '預設顏色';
			case 'settings.customColors': return '自定義顏色';
			case 'settings.pickColor': return '選擇顏色';
			case 'settings.cancel': return '取消';
			case 'settings.confirm': return '確認';
			case 'settings.noCustomColors': return '沒有自定義顏色';
			case 'settings.recordAndRestorePlaybackProgress': return '記錄和恢復播放進度';
			case 'settings.signature': return '小尾巴';
			case 'settings.enableSignature': return '小尾巴啟用';
			case 'settings.enableSignatureDesc': return '此配置決定回覆時是否自動添加小尾巴';
			case 'settings.enterSignature': return '輸入小尾巴';
			case 'settings.editSignature': return '編輯小尾巴';
			case 'settings.signatureContent': return '小尾巴內容';
			case 'settings.exportConfig': return '匯出應用配置';
			case 'settings.exportConfigDesc': return '將應用配置匯出為文件（不包含下載記錄）';
			case 'settings.importConfig': return '匯入應用配置';
			case 'settings.importConfigDesc': return '從文件匯入應用配置';
			case 'settings.exportConfigSuccess': return '配置匯出成功！';
			case 'settings.exportConfigFailed': return '配置匯出失敗';
			case 'settings.importConfigSuccess': return '配置匯入成功！';
			case 'settings.importConfigFailed': return '配置匯入失敗';
			case 'settings.historyUpdateLogs': return '歷代更新日誌';
			case 'settings.noUpdateLogs': return '未獲取到更新日誌';
			case 'settings.versionLabel': return '版本: {version}';
			case 'settings.releaseDateLabel': return '發布日期: {date}';
			case 'settings.noChanges': return '暫無更新內容';
			case 'settings.interaction': return '互動';
			case 'settings.enableVibration': return '啟用震動';
			case 'settings.enableVibrationDesc': return '啟用應用互動時的震動反饋';
			case 'settings.defaultKeepVideoToolbarVisible': return '保持工具列常駐';
			case 'settings.defaultKeepVideoToolbarVisibleDesc': return '此設定決定首次進入影片頁面時是否保持工具列常駐顯示。';
			case 'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt': return '移動端開啟劇院模式可能會造成性能問題，可酌情開啟。';
			case 'settings.lockButtonPosition': return '鎖定按鈕位置';
			case 'settings.lockButtonPositionBothSides': return '兩側顯示';
			case 'settings.lockButtonPositionLeftSide': return '僅左側顯示';
			case 'settings.lockButtonPositionRightSide': return '僅右側顯示';
			case 'settings.jumpLink': return '跳轉連結';
			case 'settings.language': return '語言';
			case 'settings.languageChanged': return '語言設定已更改，請重新啟動應用以生效。';
			case 'settings.gestureControl': return '手勢控制';
			case 'settings.leftDoubleTapRewind': return '左側雙擊後退';
			case 'settings.rightDoubleTapFastForward': return '右側雙擊快進';
			case 'settings.doubleTapPause': return '雙擊暫停';
			case 'settings.rightVerticalSwipeVolume': return '右側上下滑動調整音量（進入新頁面時生效）';
			case 'settings.leftVerticalSwipeBrightness': return '左側上下滑動調整亮度（進入新頁面時生效）';
			case 'settings.longPressFastForward': return '長按快進';
			case 'settings.enableMouseHoverShowToolbar': return '鼠標懸停時顯示工具欄';
			case 'settings.enableMouseHoverShowToolbarInfo': return '開啟後，當鼠標懸停在播放器上移動時會自動顯示工具欄，停止移動3秒後自動隱藏';
			case 'settings.audioVideoConfig': return '音視頻配置';
			case 'settings.expandBuffer': return '擴大緩衝區';
			case 'settings.expandBufferInfo': return '開啟後緩衝區增大，載入時間變長但播放更流暢';
			case 'settings.videoSyncMode': return '視頻同步模式';
			case 'settings.videoSyncModeSubtitle': return '音視頻同步策略';
			case 'settings.hardwareDecodingMode': return '硬解模式';
			case 'settings.hardwareDecodingModeSubtitle': return '硬體解碼設定';
			case 'settings.enableHardwareAcceleration': return '啟用硬體加速';
			case 'settings.enableHardwareAccelerationInfo': return '開啟硬體加速可以提高解碼效能，但某些裝置可能不相容';
			case 'settings.useOpenSLESAudioOutput': return '使用OpenSLES音頻輸出';
			case 'settings.useOpenSLESAudioOutputInfo': return '使用低延遲音頻輸出，可能提高音頻效能';
			case 'settings.videoSyncAudio': return '音頻同步';
			case 'settings.videoSyncDisplayResample': return '顯示重採樣';
			case 'settings.videoSyncDisplayResampleVdrop': return '顯示重採樣(丟幀)';
			case 'settings.videoSyncDisplayResampleDesync': return '顯示重採樣(去同步)';
			case 'settings.videoSyncDisplayTempo': return '顯示節拍';
			case 'settings.videoSyncDisplayVdrop': return '顯示丟視頻幀';
			case 'settings.videoSyncDisplayAdrop': return '顯示丟音頻幀';
			case 'settings.videoSyncDisplayDesync': return '顯示去同步';
			case 'settings.videoSyncDesync': return '去同步';
			case 'settings.hardwareDecodingAuto': return '自動';
			case 'settings.hardwareDecodingAutoCopy': return '自動複製';
			case 'settings.hardwareDecodingAutoSafe': return '自動安全';
			case 'settings.hardwareDecodingNo': return '禁用';
			case 'settings.hardwareDecodingYes': return '強制啟用';
			case 'settings.downloadSettings.downloadSettings': return '下載設定';
			case 'settings.downloadSettings.storagePermissionStatus': return '存儲權限狀態';
			case 'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission': return '訪問公共目錄需要存儲權限';
			case 'settings.downloadSettings.checkingPermissionStatus': return '檢查權限狀態...';
			case 'settings.downloadSettings.storagePermissionGranted': return '已授權存儲權限';
			case 'settings.downloadSettings.storagePermissionNotGranted': return '需要存儲權限';
			case 'settings.downloadSettings.storagePermissionGrantSuccess': return '存儲權限授權成功';
			case 'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited': return '存儲權限授權失敗，部分功能可能受限';
			case 'settings.downloadSettings.grantStoragePermission': return '授權存儲權限';
			case 'settings.downloadSettings.customDownloadPath': return '自定義下載位置';
			case 'settings.downloadSettings.customDownloadPathDescription': return '啟用後可以為下載的檔案選擇自定義儲存位置';
			case 'settings.downloadSettings.customDownloadPathTip': return '💡 提示：選擇公共目錄（如下載資料夾）需要授予儲存權限，建議優先使用推薦路徑';
			case 'settings.downloadSettings.androidWarning': return 'Android提示：避免選擇公共目錄（如下載資料夾），建議使用應用程式專用目錄以確保存取權限。';
			case 'settings.downloadSettings.publicDirectoryPermissionTip': return '⚠️ 注意：您選擇的是公共目錄，需要儲存權限才能正常下載檔案';
			case 'settings.downloadSettings.permissionRequiredForPublicDirectory': return '選擇公共目錄需要儲存權限';
			case 'settings.downloadSettings.currentDownloadPath': return '目前下載路徑';
			case 'settings.downloadSettings.defaultAppDirectory': return '預設應用程式目錄';
			case 'settings.downloadSettings.permissionGranted': return '已授權';
			case 'settings.downloadSettings.permissionRequired': return '需要權限';
			case 'settings.downloadSettings.enableCustomDownloadPath': return '啟用自定義下載路徑';
			case 'settings.downloadSettings.disableCustomDownloadPath': return '關閉時使用應用程式預設路徑';
			case 'settings.downloadSettings.customDownloadPathLabel': return '自定義下載路徑';
			case 'settings.downloadSettings.selectDownloadFolder': return '選擇下載資料夾';
			case 'settings.downloadSettings.recommendedPath': return '推薦路徑';
			case 'settings.downloadSettings.selectFolder': return '選擇資料夾';
			case 'settings.downloadSettings.filenameTemplate': return '檔案命名範本';
			case 'settings.downloadSettings.filenameTemplateDescription': return '自定義下載檔案的命名規則，支援變數替換';
			case 'settings.downloadSettings.videoFilenameTemplate': return '影片檔案命名範本';
			case 'settings.downloadSettings.galleryFolderTemplate': return '圖庫資料夾範本';
			case 'settings.downloadSettings.imageFilenameTemplate': return '單張圖片命名範本';
			case 'settings.downloadSettings.resetToDefault': return '重設為預設值';
			case 'settings.downloadSettings.supportedVariables': return '支援的變數';
			case 'settings.downloadSettings.supportedVariablesDescription': return '在檔案命名範本中可以使用以下變數：';
			case 'settings.downloadSettings.copyVariable': return '複製變數';
			case 'settings.downloadSettings.variableCopied': return '變數已複製';
			case 'settings.downloadSettings.warningPublicDirectory': return '警告：選擇的是公共目錄，可能無法存取。建議選擇應用程式專用目錄。';
			case 'settings.downloadSettings.downloadPathUpdated': return '下載路徑已更新';
			case 'settings.downloadSettings.selectPathFailed': return '選擇路徑失敗';
			case 'settings.downloadSettings.recommendedPathSet': return '已設定為推薦路徑';
			case 'settings.downloadSettings.setRecommendedPathFailed': return '設定推薦路徑失敗';
			case 'settings.downloadSettings.templateResetToDefault': return '已重設為預設範本';
			case 'settings.downloadSettings.functionalTest': return '功能測試';
			case 'settings.downloadSettings.testInProgress': return '測試中...';
			case 'settings.downloadSettings.runTest': return '執行測試';
			case 'settings.downloadSettings.testDownloadPathAndPermissions': return '測試下載路徑和權限配置是否正常運作';
			case 'settings.downloadSettings.testResults': return '測試結果';
			case 'settings.downloadSettings.testCompleted': return '測試完成';
			case 'settings.downloadSettings.testPassed': return '項通過';
			case 'settings.downloadSettings.testFailed': return '測試失敗';
			case 'settings.downloadSettings.testStoragePermissionCheck': return '存儲權限檢查';
			case 'settings.downloadSettings.testStoragePermissionGranted': return '已獲得存儲權限';
			case 'settings.downloadSettings.testStoragePermissionMissing': return '缺少存儲權限，部分功能可能受限';
			case 'settings.downloadSettings.testPermissionCheckFailed': return '權限檢查失敗';
			case 'settings.downloadSettings.testDownloadPathValidation': return '下載路徑驗證';
			case 'settings.downloadSettings.testPathValidationFailed': return '路徑驗證失敗';
			case 'settings.downloadSettings.testFilenameTemplateValidation': return '檔案命名範本驗證';
			case 'settings.downloadSettings.testAllTemplatesValid': return '所有範本都有效';
			case 'settings.downloadSettings.testSomeTemplatesInvalid': return '部分範本包含無效字元';
			case 'settings.downloadSettings.testTemplateValidationFailed': return '範本驗證失敗';
			case 'settings.downloadSettings.testDirectoryOperationTest': return '目錄操作測試';
			case 'settings.downloadSettings.testDirectoryOperationNormal': return '目錄建立和檔案寫入正常';
			case 'settings.downloadSettings.testDirectoryOperationFailed': return '目錄操作失敗';
			case 'settings.downloadSettings.testVideoTemplate': return '視頻模板';
			case 'settings.downloadSettings.testGalleryTemplate': return '圖庫模板';
			case 'settings.downloadSettings.testImageTemplate': return '圖片模板';
			case 'settings.downloadSettings.testValid': return '有效';
			case 'settings.downloadSettings.testInvalid': return '無效';
			case 'settings.downloadSettings.testSuccess': return '成功';
			case 'settings.downloadSettings.testCorrect': return '正確';
			case 'settings.downloadSettings.testError': return '錯誤';
			case 'settings.downloadSettings.testPath': return '測試路徑';
			case 'settings.downloadSettings.testBasePath': return '基礎路徑';
			case 'settings.downloadSettings.testDirectoryCreation': return '目錄創建';
			case 'settings.downloadSettings.testFileWriting': return '檔案寫入';
			case 'settings.downloadSettings.testFileContent': return '檔案內容';
			case 'settings.downloadSettings.checkingPathStatus': return '檢查路徑狀態...';
			case 'settings.downloadSettings.unableToGetPathStatus': return '無法獲取路徑狀態';
			case 'settings.downloadSettings.actualPathDifferentFromSelected': return '注意：實際使用路徑與選擇路徑不同';
			case 'settings.downloadSettings.grantPermission': return '授權權限';
			case 'settings.downloadSettings.fixIssue': return '修復問題';
			case 'settings.downloadSettings.issueFixed': return '問題已修復';
			case 'settings.downloadSettings.fixFailed': return '修復失敗，請手動處理';
			case 'settings.downloadSettings.lackStoragePermission': return '缺少存儲權限';
			case 'settings.downloadSettings.cannotAccessPublicDirectory': return '無法訪問公共目錄，需要「所有檔案存取權限」';
			case 'settings.downloadSettings.cannotCreateDirectory': return '無法建立目錄';
			case 'settings.downloadSettings.directoryNotWritable': return '目錄不可寫入';
			case 'settings.downloadSettings.insufficientSpace': return '可用空間不足';
			case 'settings.downloadSettings.pathValid': return '路徑有效';
			case 'settings.downloadSettings.validationFailed': return '驗證失敗';
			case 'settings.downloadSettings.usingDefaultAppDirectory': return '使用預設應用程式目錄';
			case 'settings.downloadSettings.appPrivateDirectory': return '應用程式專用目錄';
			case 'settings.downloadSettings.appPrivateDirectoryDesc': return '安全可靠，無需額外權限';
			case 'settings.downloadSettings.downloadDirectory': return '下載目錄';
			case 'settings.downloadSettings.downloadDirectoryDesc': return '系統預設下載位置，便於管理';
			case 'settings.downloadSettings.moviesDirectory': return '影片目錄';
			case 'settings.downloadSettings.moviesDirectoryDesc': return '系統影片目錄，媒體應用程式可識別';
			case 'settings.downloadSettings.documentsDirectory': return '文件目錄';
			case 'settings.downloadSettings.documentsDirectoryDesc': return 'iOS應用程式文件目錄';
			case 'settings.downloadSettings.requiresStoragePermission': return '需要存儲權限才能存取';
			case 'settings.downloadSettings.recommendedPaths': return '推薦路徑';
			case 'settings.downloadSettings.selectRecommendedDownloadLocation': return '選擇一個推薦的下載位置';
			case 'settings.downloadSettings.noRecommendedPaths': return '暫無推薦路徑';
			case 'settings.downloadSettings.recommended': return '推薦';
			case 'settings.downloadSettings.requiresPermission': return '需要權限';
			case 'settings.downloadSettings.authorizeAndSelect': return '授權並選擇';
			case 'settings.downloadSettings.select': return '選擇';
			case 'settings.downloadSettings.permissionAuthorizationFailed': return '權限授權失敗，無法選擇此路徑';
			case 'settings.downloadSettings.pathValidationFailed': return '路徑驗證失敗';
			case 'settings.downloadSettings.downloadPathSetTo': return '下載路徑已設定為';
			case 'settings.downloadSettings.setPathFailed': return '設定路徑失敗';
			case 'settings.downloadSettings.variableTitle': return '標題';
			case 'settings.downloadSettings.variableAuthor': return '作者名稱';
			case 'settings.downloadSettings.variableUsername': return '作者使用者名稱';
			case 'settings.downloadSettings.variableQuality': return '影片品質';
			case 'settings.downloadSettings.variableFilename': return '原始檔案名稱';
			case 'settings.downloadSettings.variableId': return '內容ID';
			case 'settings.downloadSettings.variableCount': return '圖庫圖片數量';
			case 'settings.downloadSettings.variableDate': return '目前日期 (YYYY-MM-DD)';
			case 'settings.downloadSettings.variableTime': return '目前時間 (HH-MM-SS)';
			case 'settings.downloadSettings.variableDatetime': return '目前日期時間 (YYYY-MM-DD_HH-MM-SS)';
			case 'settings.downloadSettings.downloadSettingsTitle': return '下載設定';
			case 'settings.downloadSettings.downloadSettingsSubtitle': return '設定下載路徑和檔案命名規則';
			case 'settings.downloadSettings.suchAsTitleQuality': return '例如: %title_%quality';
			case 'settings.downloadSettings.suchAsTitleId': return '例如: %title_%id';
			case 'settings.downloadSettings.suchAsTitleFilename': return '例如: %title_%filename';
			case 'oreno3d.name': return 'Oreno3D';
			case 'oreno3d.tags': return '標籤';
			case 'oreno3d.characters': return '角色';
			case 'oreno3d.origin': return '原作';
			case 'oreno3d.thirdPartyTagsExplanation': return '此處顯示的**標籤**、**角色**和**原作**資訊來自第三方站點 **Oreno3D**，僅供參考。\n\n由於此資訊來源只有日文，目前缺乏國際化適配。\n\n如果你有興趣參與國際化建設，歡迎訪問相關倉庫貢獻你的力量！';
			case 'oreno3d.sortTypes.hot': return '熱門';
			case 'oreno3d.sortTypes.favorites': return '高評價';
			case 'oreno3d.sortTypes.latest': return '最新';
			case 'oreno3d.sortTypes.popularity': return '人氣';
			case 'oreno3d.errors.requestFailed': return '請求失敗，狀態碼';
			case 'oreno3d.errors.connectionTimeout': return '連接超時，請檢查網路連接';
			case 'oreno3d.errors.sendTimeout': return '發送請求超時';
			case 'oreno3d.errors.receiveTimeout': return '接收響應超時';
			case 'oreno3d.errors.badCertificate': return '證書驗證失敗';
			case 'oreno3d.errors.resourceNotFound': return '請求的資源不存在';
			case 'oreno3d.errors.accessDenied': return '訪問被拒絕，可能需要驗證或權限';
			case 'oreno3d.errors.serverError': return '伺服器內部錯誤';
			case 'oreno3d.errors.serviceUnavailable': return '服務暫時不可用';
			case 'oreno3d.errors.requestCancelled': return '請求已取消';
			case 'oreno3d.errors.connectionError': return '網路連接錯誤，請檢查網路設置';
			case 'oreno3d.errors.networkRequestFailed': return '網路請求失敗';
			case 'oreno3d.errors.searchVideoError': return '搜索視頻時發生未知錯誤';
			case 'oreno3d.errors.getPopularVideoError': return '獲取熱門視頻時發生未知錯誤';
			case 'oreno3d.errors.getVideoDetailError': return '獲取視頻詳情時發生未知錯誤';
			case 'oreno3d.errors.parseVideoDetailError': return '獲取並解析視頻詳情時發生未知錯誤';
			case 'oreno3d.errors.downloadFileError': return '下載文件時發生未知錯誤';
			case 'oreno3d.loading.gettingVideoInfo': return '正在獲取視頻信息...';
			case 'oreno3d.loading.cancel': return '取消';
			case 'oreno3d.messages.videoNotFoundOrDeleted': return '視頻不存在或已被刪除';
			case 'oreno3d.messages.unableToGetVideoPlayLink': return '無法獲取視頻播放鏈接';
			case 'oreno3d.messages.getVideoDetailFailed': return '獲取視頻詳情失敗';
			case 'signIn.pleaseLoginFirst': return '請先登入';
			case 'signIn.alreadySignedInToday': return '您今天已經簽到過了！';
			case 'signIn.youDidNotStickToTheSignIn': return '您未能持續簽到。';
			case 'signIn.signInSuccess': return '簽到成功！';
			case 'signIn.signInFailed': return '簽到失敗，請稍後再試';
			case 'signIn.consecutiveSignIns': return '連續簽到天數';
			case 'signIn.failureReason': return '未能持續簽到的原因';
			case 'signIn.selectDateRange': return '選擇日期範圍';
			case 'signIn.startDate': return '開始日期';
			case 'signIn.endDate': return '結束日期';
			case 'signIn.invalidDate': return '日期格式錯誤';
			case 'signIn.invalidDateRange': return '日期範圍無效';
			case 'signIn.errorFormatText': return '日期格式錯誤';
			case 'signIn.errorInvalidText': return '日期範圍無效';
			case 'signIn.errorInvalidRangeText': return '日期範圍無效';
			case 'signIn.dateRangeCantBeMoreThanOneYear': return '日期範圍不能超過1年';
			case 'signIn.signIn': return '簽到';
			case 'signIn.signInRecord': return '簽到紀錄';
			case 'signIn.totalSignIns': return '總簽到次數';
			case 'signIn.pleaseSelectSignInStatus': return '請選擇簽到狀態';
			case 'subscriptions.pleaseLoginFirstToViewYourSubscriptions': return '請登入以查看您的訂閱內容。';
			case 'subscriptions.selectUser': return '選擇用戶';
			case 'subscriptions.noSubscribedUsers': return '尚無已訂閱用戶';
			case 'subscriptions.showAllSubscribedUsersContent': return '顯示所有已訂閱用戶的內容';
			case 'videoDetail.pipMode': return '畫中畫模式';
			case 'videoDetail.resumeFromLastPosition': return ({required Object position}) => '從上次播放位置繼續播放: ${position}';
			case 'videoDetail.videoIdIsEmpty': return '影片ID為空';
			case 'videoDetail.videoInfoIsEmpty': return '影片資訊為空';
			case 'videoDetail.thisIsAPrivateVideo': return '這是私密影片';
			case 'videoDetail.getVideoInfoFailed': return '取得影片資訊失敗，請稍後再試';
			case 'videoDetail.noVideoSourceFound': return '未找到對應的影片來源';
			case 'videoDetail.tagCopiedToClipboard': return ({required Object tagId}) => '標籤 "${tagId}" 已複製到剪貼簿';
			case 'videoDetail.errorLoadingVideo': return '載入影片時出錯';
			case 'videoDetail.play': return '播放';
			case 'videoDetail.pause': return '暫停';
			case 'videoDetail.exitAppFullscreen': return '退出應用全螢幕';
			case 'videoDetail.enterAppFullscreen': return '應用全螢幕';
			case 'videoDetail.exitSystemFullscreen': return '退出系統全螢幕';
			case 'videoDetail.enterSystemFullscreen': return '系統全螢幕';
			case 'videoDetail.seekTo': return '跳轉到指定時間';
			case 'videoDetail.switchResolution': return '切換解析度';
			case 'videoDetail.switchPlaybackSpeed': return '切換播放倍速';
			case 'videoDetail.rewindSeconds': return ({required Object num}) => '快退 ${num} 秒';
			case 'videoDetail.fastForwardSeconds': return ({required Object num}) => '快進 ${num} 秒';
			case 'videoDetail.playbackSpeedIng': return ({required Object rate}) => '正在以 ${rate} 倍速播放';
			case 'videoDetail.brightness': return '亮度';
			case 'videoDetail.brightnessLowest': return '亮度已最低';
			case 'videoDetail.volume': return '音量';
			case 'videoDetail.volumeMuted': return '音量已靜音';
			case 'videoDetail.home': return '主頁';
			case 'videoDetail.videoPlayer': return '影片播放器';
			case 'videoDetail.videoPlayerInfo': return '播放器資訊';
			case 'videoDetail.moreSettings': return '更多設定';
			case 'videoDetail.videoPlayerFeatureInfo': return '播放器功能介紹';
			case 'videoDetail.autoRewind': return '自動重播';
			case 'videoDetail.rewindAndFastForward': return '左右雙擊快進或快退';
			case 'videoDetail.volumeAndBrightness': return '左右滑動調整音量、亮度';
			case 'videoDetail.centerAreaDoubleTapPauseOrPlay': return '中央區域雙擊暫停或播放';
			case 'videoDetail.showVerticalVideoInFullScreen': return '在全螢幕時顯示直向影片';
			case 'videoDetail.keepLastVolumeAndBrightness': return '保持最後調整的音量、亮度';
			case 'videoDetail.setProxy': return '設定代理';
			case 'videoDetail.moreFeaturesToBeDiscovered': return '更多功能待發掘...';
			case 'videoDetail.videoPlayerSettings': return '播放器設定';
			case 'videoDetail.commentCount': return ({required Object num}) => '評論 ${num} 則';
			case 'videoDetail.writeYourCommentHere': return '請寫下您的評論...';
			case 'videoDetail.authorOtherVideos': return '作者的其他影片';
			case 'videoDetail.relatedVideos': return '相關影片';
			case 'videoDetail.privateVideo': return '這是一個私密影片';
			case 'videoDetail.externalVideo': return '這是一個站外影片';
			case 'videoDetail.openInBrowser': return '在瀏覽器中打開';
			case 'videoDetail.resourceDeleted': return '這個影片貌似被刪除了 :/';
			case 'videoDetail.noDownloadUrl': return '沒有下載連結';
			case 'videoDetail.startDownloading': return '開始下載';
			case 'videoDetail.downloadFailed': return '下載失敗，請稍後再試';
			case 'videoDetail.downloadSuccess': return '下載成功';
			case 'videoDetail.download': return '下載';
			case 'videoDetail.downloadManager': return '下載管理';
			case 'videoDetail.videoLoadError': return '影片加載錯誤';
			case 'videoDetail.resourceNotFound': return '資源未找到';
			case 'videoDetail.authorNoOtherVideos': return '作者暫無其他影片';
			case 'videoDetail.noRelatedVideos': return '暫無相關影片';
			case 'videoDetail.skeleton.fetchingVideoInfo': return '取得影片資訊中...';
			case 'videoDetail.skeleton.fetchingVideoSources': return '取得影片來源中...';
			case 'videoDetail.skeleton.loadingVideo': return '正在加載影片...';
			case 'share.sharePlayList': return '分享播放列表';
			case 'share.wowDidYouSeeThis': return '哇哦，你看过这个吗？';
			case 'share.nameIs': return '名字叫做';
			case 'share.clickLinkToView': return '點擊連結查看';
			case 'share.iReallyLikeThis': return '我真的是太喜歡這個了，你也來看看吧！';
			case 'share.shareFailed': return '分享失敗，請稍後再試';
			case 'share.share': return '分享';
			case 'share.shareAsImage': return '分享為圖片';
			case 'share.shareAsText': return '分享為文本';
			case 'share.shareAsImageDesc': return '將影片封面分享為圖片';
			case 'share.shareAsTextDesc': return '將影片詳情分享為文本';
			case 'share.shareAsImageFailed': return '分享影片封面為圖片失敗，請稍後再試';
			case 'share.shareAsTextFailed': return '分享影片詳情為文本失敗，請稍後再試';
			case 'share.shareVideo': return '分享影片';
			case 'share.authorIs': return '作者是';
			case 'share.shareGallery': return '分享圖庫';
			case 'share.galleryTitleIs': return '圖庫名字叫做';
			case 'share.galleryAuthorIs': return '圖庫作者是';
			case 'share.shareUser': return '分享用戶';
			case 'share.userNameIs': return '用戶名字叫做';
			case 'share.userAuthorIs': return '用戶作者是';
			case 'share.comments': return '評論';
			case 'share.shareThread': return '分享帖子';
			case 'share.views': return '瀏覽';
			case 'share.sharePost': return '分享投稿';
			case 'share.postTitleIs': return '投稿名字叫做';
			case 'share.postAuthorIs': return '投稿作者是';
			case 'markdown.markdownSyntax': return 'Markdown 語法';
			case 'markdown.iwaraSpecialMarkdownSyntax': return 'Iwara 專用語法';
			case 'markdown.internalLink': return '站內鏈接';
			case 'markdown.supportAutoConvertLinkBelow': return '支持自動轉換以下類型的鏈接：';
			case 'markdown.convertLinkExample': return '🎬 影片鏈接\n🖼️ 圖片鏈接\n👤 用戶鏈接\n📌 論壇鏈接\n🎵 播放列表鏈接\n💬 帖子鏈接';
			case 'markdown.mentionUser': return '提及用戶';
			case 'markdown.mentionUserDescription': return '輸入@後跟用戶名，將自動轉換為用戶鏈接';
			case 'markdown.markdownBasicSyntax': return 'Markdown 基本語法';
			case 'markdown.paragraphAndLineBreak': return '段落與換行';
			case 'markdown.paragraphAndLineBreakDescription': return '段落之間空一行，行末加兩個空格實現換行';
			case 'markdown.paragraphAndLineBreakSyntax': return '這是第一段文字\n\n這是第二段文字\n這一行後面加兩個空格  \n就能換行了';
			case 'markdown.textStyle': return '文本樣式';
			case 'markdown.textStyleDescription': return '使用特殊符號包圍文本来改變樣式';
			case 'markdown.textStyleSyntax': return '**粗體文本**\n*斜體文本*\n~~刪除線文本~~\n`代碼文本`';
			case 'markdown.quote': return '引用';
			case 'markdown.quoteDescription': return '使用 > 符號創建引用，多個 > 創建多級引用';
			case 'markdown.quoteSyntax': return '> 這是一級引用\n>> 這是二級引用';
			case 'markdown.list': return '列表';
			case 'markdown.listDescription': return '使用數字+點號創建有序列表，使用 - 創建無序列表';
			case 'markdown.listSyntax': return '1. 第一項\n2. 第二項\n\n- 無序項\n  - 子項\n  - 另一個子項';
			case 'markdown.linkAndImage': return '鏈接與圖片';
			case 'markdown.linkAndImageDescription': return '鏈接格式：[文字](URL)\n圖片格式：![描述](URL)';
			case 'markdown.linkAndImageSyntax': return ({required Object link, required Object imgUrl}) => '[鏈接文字](${link})\n![圖片描述](${imgUrl})';
			case 'markdown.title': return '標題';
			case 'markdown.titleDescription': return '使用 # 號創建標題，數量表示級別';
			case 'markdown.titleSyntax': return '# 一級標題\n## 二級標題\n### 三級標題';
			case 'markdown.separator': return '分隔線';
			case 'markdown.separatorDescription': return '使用三個或更多 - 號創建分隔線';
			case 'markdown.separatorSyntax': return '---';
			case 'markdown.syntax': return '語法';
			case 'forum.recent': return '最近';
			case 'forum.category': return '分類';
			case 'forum.lastReply': return '最終回覆';
			case 'forum.errors.pleaseSelectCategory': return '請選擇分類';
			case 'forum.errors.threadLocked': return '該主題已鎖定，無法回覆';
			case 'forum.createPost': return '創建帖子';
			case 'forum.title': return '標題';
			case 'forum.enterTitle': return '輸入標題';
			case 'forum.content': return '內容';
			case 'forum.enterContent': return '輸入內容';
			case 'forum.writeYourContentHere': return '在此輸入內容...';
			case 'forum.posts': return '帖子';
			case 'forum.threads': return '主題';
			case 'forum.forum': return '論壇';
			case 'forum.createThread': return '創建主題';
			case 'forum.selectCategory': return '選擇分類';
			case 'forum.cooldownRemaining': return ({required Object minutes, required Object seconds}) => '冷卻剩餘時間 ${minutes} 分 ${seconds} 秒';
			case 'forum.groups.administration': return '管理';
			case 'forum.groups.global': return '全球';
			case 'forum.groups.chinese': return '中文';
			case 'forum.groups.japanese': return '日語';
			case 'forum.groups.korean': return '韓語';
			case 'forum.groups.other': return '其他';
			case 'forum.leafNames.announcements': return '公告';
			case 'forum.leafNames.feedback': return '反饋';
			case 'forum.leafNames.support': return '幫助';
			case 'forum.leafNames.general': return '一般';
			case 'forum.leafNames.guides': return '指南';
			case 'forum.leafNames.questions': return '問題';
			case 'forum.leafNames.requests': return '請求';
			case 'forum.leafNames.sharing': return '分享';
			case 'forum.leafNames.general_zh': return '一般';
			case 'forum.leafNames.questions_zh': return '問題';
			case 'forum.leafNames.requests_zh': return '請求';
			case 'forum.leafNames.support_zh': return '幫助';
			case 'forum.leafNames.general_ja': return '一般';
			case 'forum.leafNames.questions_ja': return '問題';
			case 'forum.leafNames.requests_ja': return '請求';
			case 'forum.leafNames.support_ja': return '幫助';
			case 'forum.leafNames.korean': return '韓語';
			case 'forum.leafNames.other': return '其他';
			case 'forum.leafDescriptions.announcements': return '官方重要通知和公告';
			case 'forum.leafDescriptions.feedback': return '對網站功能和服務的反饋';
			case 'forum.leafDescriptions.support': return '幫助解決網站相關問題';
			case 'forum.leafDescriptions.general': return '討論任何話題';
			case 'forum.leafDescriptions.guides': return '分享你的經驗和教程';
			case 'forum.leafDescriptions.questions': return '提出你的疑問';
			case 'forum.leafDescriptions.requests': return '發布你的請求';
			case 'forum.leafDescriptions.sharing': return '分享有趣的內容';
			case 'forum.leafDescriptions.general_zh': return '討論任何話題';
			case 'forum.leafDescriptions.questions_zh': return '提出你的疑問';
			case 'forum.leafDescriptions.requests_zh': return '發布你的請求';
			case 'forum.leafDescriptions.support_zh': return '幫助解決網站相關問題';
			case 'forum.leafDescriptions.general_ja': return '討論任何話題';
			case 'forum.leafDescriptions.questions_ja': return '提出你的疑問';
			case 'forum.leafDescriptions.requests_ja': return '發布你的請求';
			case 'forum.leafDescriptions.support_ja': return '幫助解決網站相關問題';
			case 'forum.leafDescriptions.korean': return '韓語相關討論';
			case 'forum.leafDescriptions.other': return '其他未分類的內容';
			case 'forum.reply': return '回覆';
			case 'forum.pendingReview': return '審核中';
			case 'forum.editedAt': return '編輯時間';
			case 'forum.copySuccess': return '已複製到剪貼簿';
			case 'forum.copySuccessForMessage': return ({required Object str}) => '已複製到剪貼簿: ${str}';
			case 'forum.editReply': return '編輯回覆';
			case 'forum.editTitle': return '編輯標題';
			case 'forum.submit': return '提交';
			case 'notifications.errors.unsupportedNotificationType': return '暫不支持的通知類型';
			case 'notifications.errors.unknownUser': return '未知用戶';
			case 'notifications.errors.unsupportedNotificationTypeWithType': return ({required Object type}) => '暫不支持的通知類型: ${type}';
			case 'notifications.errors.unknownNotificationType': return '未知通知類型';
			case 'notifications.notifications': return '通知';
			case 'notifications.profile': return '個人主頁';
			case 'notifications.postedNewComment': return '發表了評論';
			case 'notifications.notifiedOn': return '在您的個人主頁上發表了評論';
			case 'notifications.inYour': return '在您的';
			case 'notifications.video': return '影片';
			case 'notifications.repliedYourVideoComment': return '回覆了您的影片評論';
			case 'notifications.copyInfoToClipboard': return '複製通知信息到剪貼簿';
			case 'notifications.copySuccess': return '已複製到剪貼簿';
			case 'notifications.copySuccessForMessage': return ({required Object str}) => '已複製到剪貼簿: ${str}';
			case 'notifications.markAllAsRead': return '全部標記已讀';
			case 'notifications.markAllAsReadSuccess': return '所有通知已標記為已讀';
			case 'notifications.markAllAsReadFailed': return '全部標記已讀失敗';
			case 'notifications.markAllAsReadFailedWithException': return ({required Object exception}) => '全部標記已讀失敗: ${exception}';
			case 'notifications.markSelectedAsRead': return '標記已讀';
			case 'notifications.markSelectedAsReadSuccess': return '已標記為已讀';
			case 'notifications.markSelectedAsReadFailed': return '標記已讀失敗';
			case 'notifications.markSelectedAsReadFailedWithException': return ({required Object exception}) => '標記已讀失敗: ${exception}';
			case 'notifications.markAsRead': return '標記已讀';
			case 'notifications.markAsReadSuccess': return '已標記為已讀';
			case 'notifications.markAsReadFailed': return '標記已讀失敗';
			case 'notifications.notificationTypeHelp': return '通知類型幫助';
			case 'notifications.dueToLackOfNotificationTypeDetails': return '通知類型的詳細信息不足，目前支持的類型可能沒有覆蓋到您當前收到的消息';
			case 'notifications.helpUsImproveNotificationTypeSupport': return '如果您願意幫助我們完善通知類型的支持：';
			case 'notifications.helpUsImproveNotificationTypeSupportLongText': return '1. 📋 複製通知信息\n2. 🐞 前往項目倉庫提交 issue\n\n⚠️ 注意：通知信息可能包含個人隱私，如果你不想公開，也可以通過郵件發送給項目作者。';
			case 'notifications.goToRepository': return '前往項目倉庫';
			case 'notifications.copy': return '複製';
			case 'notifications.commentApproved': return '評論已通過';
			case 'notifications.repliedYourProfileComment': return '回覆了您的個人主頁評論';
			case 'notifications.kReplied': return '回覆了您在';
			case 'notifications.kCommented': return '評論了您的';
			case 'notifications.kVideo': return '影片';
			case 'notifications.kGallery': return '圖庫';
			case 'notifications.kProfile': return '主頁';
			case 'notifications.kThread': return '主題';
			case 'notifications.kPost': return '投稿';
			case 'notifications.kCommentSection': return '下的評論';
			case 'notifications.kApprovedComment': return '評論已通過';
			case 'notifications.kApprovedVideo': return '影片已通過';
			case 'notifications.kApprovedGallery': return '圖庫已通過';
			case 'notifications.kApprovedThread': return '主題已審核';
			case 'notifications.kApprovedPost': return '投稿已審核';
			case 'notifications.kUnknownType': return '未知通知類型';
			case 'conversation.errors.pleaseSelectAUser': return '請選擇一個用戶';
			case 'conversation.errors.pleaseEnterATitle': return '請輸入標題';
			case 'conversation.errors.clickToSelectAUser': return '點擊選擇用戶';
			case 'conversation.errors.loadFailedClickToRetry': return '加載失敗,點擊重試';
			case 'conversation.errors.loadFailed': return '加載失敗';
			case 'conversation.errors.clickToRetry': return '點擊重試';
			case 'conversation.errors.noMoreConversations': return '沒有更多消息了';
			case 'conversation.conversation': return '會話';
			case 'conversation.startConversation': return '發起會話';
			case 'conversation.noConversation': return '暫無會話';
			case 'conversation.selectFromLeftListAndStartConversation': return '從左側列表選擇一個會話開始聊天';
			case 'conversation.title': return '標題';
			case 'conversation.body': return '內容';
			case 'conversation.selectAUser': return '選擇用戶';
			case 'conversation.searchUsers': return '搜索用戶...';
			case 'conversation.tmpNoConversions': return '暫無會話';
			case 'conversation.deleteThisMessage': return '刪除此消息';
			case 'conversation.deleteThisMessageSubtitle': return '此操作不可撤銷';
			case 'conversation.writeMessageHere': return '在此處輸入消息';
			case 'conversation.sendMessage': return '發送消息';
			case 'splash.errors.initializationFailed': return '初始化失敗，請重啟應用';
			case 'splash.preparing': return '準備中...';
			case 'splash.initializing': return '初始化中...';
			case 'splash.loading': return '加載中...';
			case 'splash.ready': return '準備完成';
			case 'splash.initializingMessageService': return '初始化消息服務中...';
			case 'download.errors.imageModelNotFound': return '圖庫信息不存在';
			case 'download.errors.downloadFailed': return '下載失敗';
			case 'download.errors.videoInfoNotFound': return '影片信息不存在';
			case 'download.errors.unknown': return '未知';
			case 'download.errors.downloadTaskAlreadyExists': return '下載任務已存在';
			case 'download.errors.videoAlreadyDownloaded': return '該影片已下載';
			case 'download.errors.downloadFailedForMessage': return ({required Object errorInfo}) => '添加下載任務失敗: ${errorInfo}';
			case 'download.errors.userPausedDownload': return '用戶暫停下載';
			case 'download.errors.fileSystemError': return ({required Object errorInfo}) => '文件系統錯誤: ${errorInfo}';
			case 'download.errors.unknownError': return ({required Object errorInfo}) => '未知錯誤: ${errorInfo}';
			case 'download.errors.connectionTimeout': return '連接超時';
			case 'download.errors.sendTimeout': return '發送超時';
			case 'download.errors.receiveTimeout': return '接收超時';
			case 'download.errors.serverError': return ({required Object errorInfo}) => '伺服器錯誤: ${errorInfo}';
			case 'download.errors.unknownNetworkError': return '未知網路錯誤';
			case 'download.errors.serviceIsClosing': return '下載服務正在關閉';
			case 'download.errors.partialDownloadFailed': return '部分內容下載失敗';
			case 'download.errors.noDownloadTask': return '暫無下載任務';
			case 'download.errors.taskNotFoundOrDataError': return '任務不存在或資料錯誤';
			case 'download.errors.copyDownloadUrlFailed': return '複製下載連結失敗';
			case 'download.errors.fileNotFound': return '文件不存在';
			case 'download.errors.openFolderFailed': return '打開文件夾失敗';
			case 'download.errors.openFolderFailedWithMessage': return ({required Object message}) => '打開文件夾失敗: ${message}';
			case 'download.errors.directoryNotFound': return '目錄不存在';
			case 'download.errors.copyFailed': return '複製失敗';
			case 'download.errors.openFileFailed': return '打開文件失敗';
			case 'download.errors.openFileFailedWithMessage': return ({required Object message}) => '打開文件失敗: ${message}';
			case 'download.errors.noDownloadSource': return '沒有下載源';
			case 'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded': return '暫無下載源，請等待信息加載完成後重試';
			case 'download.errors.noActiveDownloadTask': return '暫無正在下載的任務';
			case 'download.errors.noFailedDownloadTask': return '暫無失敗的任務';
			case 'download.errors.noCompletedDownloadTask': return '暫無已完成的任務';
			case 'download.errors.taskAlreadyCompletedDoNotAdd': return '任務已完成，請勿重複添加';
			case 'download.errors.linkExpiredTryAgain': return '連結已過期，正在重新獲取下載連結';
			case 'download.errors.linkExpiredTryAgainSuccess': return '連結已過期，正在重新獲取下載連結成功';
			case 'download.errors.linkExpiredTryAgainFailed': return '連結已過期，正在重新獲取下載連結失敗';
			case 'download.errors.taskDeleted': return '任務已刪除';
			case 'download.errors.unsupportedImageFormat': return ({required Object format}) => '不支持的圖片格式: ${format}';
			case 'download.errors.deleteFileError': return '文件删除失败，可能是因为文件被占用';
			case 'download.errors.deleteTaskError': return '任务删除失败';
			case 'download.errors.taskNotFound': return '任务未找到';
			case 'download.errors.canNotRefreshVideoTask': return '無法刷新視頻任務';
			case 'download.errors.taskAlreadyProcessing': return '任務已處理中';
			case 'download.errors.failedToLoadTasks': return '加載任務失敗';
			case 'download.errors.partialDownloadFailedWithMessage': return ({required Object message}) => '部分下載失敗: ${message}';
			case 'download.errors.pleaseTryOtherViewer': return '請嘗試使用其他查看器打開';
			case 'download.errors.unsupportedImageFormatWithMessage': return ({required Object extension}) => '不支持的圖片格式: ${extension}, 可以嘗試下載到設備上查看';
			case 'download.errors.imageLoadFailed': return '圖片加載失敗';
			case 'download.downloadList': return '下載列表';
			case 'download.download': return '下載';
			case 'download.forceDeleteTask': return '強制刪除任務';
			case 'download.startDownloading': return '開始下載...';
			case 'download.clearAllFailedTasks': return '清除全部失敗任務';
			case 'download.clearAllFailedTasksConfirmation': return '確定要清除所有失敗的下載任務嗎？\n這些任務的文件也會被刪除。';
			case 'download.clearAllFailedTasksSuccess': return '已清除所有失敗任務';
			case 'download.clearAllFailedTasksError': return '清除失敗任務時出錯';
			case 'download.downloadStatus': return '下載狀態';
			case 'download.imageList': return '圖片列表';
			case 'download.retryDownload': return '重試下載';
			case 'download.notDownloaded': return '未下載';
			case 'download.downloaded': return '已下載';
			case 'download.waitingForDownload': return '等待下載...';
			case 'download.downloadingProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => '下載中 (${downloaded}/${total}張 ${progress}%)';
			case 'download.downloadingSingleImageProgress': return ({required Object downloaded}) => '下載中 (${downloaded}張)';
			case 'download.pausedProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => '已暫停 (${downloaded}/${total}張 ${progress}%)';
			case 'download.pausedSingleImageProgress': return ({required Object downloaded}) => '已暫停 (已下載${downloaded}張)';
			case 'download.downloadedProgressForImageProgress': return ({required Object total}) => '下載完成 (共${total}張)';
			case 'download.viewVideoDetail': return '查看影片詳情';
			case 'download.viewGalleryDetail': return '查看圖庫詳情';
			case 'download.moreOptions': return '更多操作';
			case 'download.openFile': return '打開文件';
			case 'download.pause': return '暫停';
			case 'download.resume': return '繼續';
			case 'download.copyDownloadUrl': return '複製下載連結';
			case 'download.showInFolder': return '在文件夾中顯示';
			case 'download.deleteTask': return '刪除任務';
			case 'download.deleteTaskConfirmation': return '確定要刪除這個下載任務嗎？\n任務的文件也會被刪除。';
			case 'download.forceDeleteTaskConfirmation': return '確定要強制刪除這個下載任務嗎？\n任務的文件也會被刪除，即使文件被佔用也會嘗試刪除。';
			case 'download.downloadingProgressForVideoTask': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloadingOnlyDownloadedAndSpeed': return ({required Object downloaded, required Object speed}) => '下載中 ${downloaded} • ${speed}MB/s';
			case 'download.pausedForDownloadedAndTotal': return ({required Object downloaded, required Object total, required Object progress}) => '已暫停 • ${downloaded}/${total} (${progress}%)';
			case 'download.pausedAndDownloaded': return ({required Object downloaded}) => '已暫停 • 已下載 ${downloaded}';
			case 'download.downloadedWithSize': return ({required Object size}) => '下載完成 • ${size}';
			case 'download.copyDownloadUrlSuccess': return '已複製下載連結';
			case 'download.totalImageNums': return ({required Object num}) => '${num}張';
			case 'download.downloadingDownloadedTotalProgressSpeed': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloading': return '下載中';
			case 'download.failed': return '失敗';
			case 'download.completed': return '已完成';
			case 'download.downloadDetail': return '下載詳情';
			case 'download.copy': return '複製';
			case 'download.copySuccess': return '已複製';
			case 'download.waiting': return '等待中';
			case 'download.paused': return '暫停中';
			case 'download.downloadingOnlyDownloaded': return ({required Object downloaded}) => '下載中 ${downloaded}';
			case 'download.galleryDownloadCompletedWithName': return ({required Object galleryName}) => '圖庫下載完成: ${galleryName}';
			case 'download.downloadCompletedWithName': return ({required Object fileName}) => '下載完成: ${fileName}';
			case 'download.stillInDevelopment': return '開發中';
			case 'download.saveToAppDirectory': return '保存到應用程序目錄';
			case 'favorite.errors.addFailed': return '追加失敗';
			case 'favorite.errors.addSuccess': return '追加成功';
			case 'favorite.errors.deleteFolderFailed': return '刪除文件夾失敗';
			case 'favorite.errors.deleteFolderSuccess': return '刪除文件夾成功';
			case 'favorite.errors.folderNameCannotBeEmpty': return '資料夾名稱不能為空';
			case 'favorite.add': return '追加';
			case 'favorite.addSuccess': return '追加成功';
			case 'favorite.addFailed': return '追加失敗';
			case 'favorite.remove': return '刪除';
			case 'favorite.removeSuccess': return '刪除成功';
			case 'favorite.removeFailed': return '刪除失敗';
			case 'favorite.removeConfirmation': return '確定要刪除這個項目嗎？';
			case 'favorite.removeConfirmationSuccess': return '項目已從收藏夾中刪除';
			case 'favorite.removeConfirmationFailed': return '刪除項目失敗';
			case 'favorite.createFolderSuccess': return '文件夾創建成功';
			case 'favorite.createFolderFailed': return '創建文件夾失敗';
			case 'favorite.createFolder': return '創建文件夾';
			case 'favorite.enterFolderName': return '輸入文件夾名稱';
			case 'favorite.enterFolderNameHere': return '在此輸入文件夾名稱...';
			case 'favorite.create': return '創建';
			case 'favorite.items': return '項目';
			case 'favorite.newFolderName': return '新文件夾';
			case 'favorite.searchFolders': return '搜索文件夾...';
			case 'favorite.searchItems': return '搜索項目...';
			case 'favorite.createdAt': return '創建時間';
			case 'favorite.myFavorites': return '我的收藏';
			case 'favorite.deleteFolderTitle': return '刪除文件夾';
			case 'favorite.deleteFolderConfirmWithTitle': return ({required Object title}) => '確定要刪除 ${title} 文件夾嗎？';
			case 'favorite.removeItemTitle': return '刪除項目';
			case 'favorite.removeItemConfirmWithTitle': return ({required Object title}) => '確定要刪除 ${title} 項目嗎？';
			case 'favorite.removeItemSuccess': return '項目已從收藏夾中刪除';
			case 'favorite.removeItemFailed': return '刪除項目失敗';
			case 'favorite.localizeFavorite': return '本地收藏';
			case 'favorite.editFolderTitle': return '編輯資料夾';
			case 'favorite.editFolderSuccess': return '資料夾更新成功';
			case 'favorite.editFolderFailed': return '資料夾更新失敗';
			case 'favorite.searchTags': return '搜索標籤';
			case 'translation.testConnection': return '測試連接';
			case 'translation.testConnectionSuccess': return '測試連接成功';
			case 'translation.testConnectionFailed': return '測試連接失敗';
			case 'translation.testConnectionFailedWithMessage': return ({required Object message}) => '測試連接失敗: ${message}';
			case 'translation.translation': return '翻譯';
			case 'translation.needVerification': return '需要驗證';
			case 'translation.needVerificationContent': return '請先通過連接測試才能啟用AI翻譯';
			case 'translation.confirm': return '確定';
			case 'translation.disclaimer': return '使用須知';
			case 'translation.riskWarning': return '風險提示';
			case 'translation.dureToRisk1': return '由於評論等文本為用戶生成，可能包含違反AI服務商內容政策的內容';
			case 'translation.dureToRisk2': return '不當內容可能導致API密鑰封禁或服務終止';
			case 'translation.operationSuggestion': return '操作建議';
			case 'translation.operationSuggestion1': return '1. 使用前請嚴格審核待翻譯內容';
			case 'translation.operationSuggestion2': return '2. 避免翻譯涉及暴力、成人等敏感內容';
			case 'translation.apiConfig': return 'API設定';
			case 'translation.modifyConfigWillAutoCloseAITranslation': return '修改配置將自動關閉AI翻譯，需重新測試後打開';
			case 'translation.apiAddress': return 'API地址';
			case 'translation.modelName': return '模型名稱';
			case 'translation.modelNameHintText': return '例如：gpt-4-turbo';
			case 'translation.maxTokens': return '最大Token數';
			case 'translation.maxTokensHintText': return '例如：1024';
			case 'translation.temperature': return '溫度係數';
			case 'translation.temperatureHintText': return '0.0-2.0';
			case 'translation.clickTestButtonToVerifyAPIConnection': return '點擊測試按鈕驗證API連接有效性';
			case 'translation.requestPreview': return '請求預覽';
			case 'translation.enableAITranslation': return 'AI翻譯';
			case 'translation.enabled': return '已啟用';
			case 'translation.disabled': return '已禁用';
			case 'translation.testing': return '測試中...';
			case 'translation.testNow': return '立即測試';
			case 'translation.connectionStatus': return '連接狀態';
			case 'translation.success': return '成功';
			case 'translation.failed': return '失敗';
			case 'translation.information': return '信息';
			case 'translation.viewRawResponse': return '查看原始響應';
			case 'translation.pleaseCheckInputParametersFormat': return '請檢查輸入參數格式';
			case 'translation.pleaseFillInAPIAddressModelNameAndKey': return '請填寫API地址、模型名稱和密鑰';
			case 'translation.pleaseFillInValidConfigurationParameters': return '請填寫有效的配置參數';
			case 'translation.pleaseCompleteConnectionTest': return '請完成連接測試';
			case 'translation.notConfigured': return '未配置';
			case 'translation.apiEndpoint': return 'API端點';
			case 'translation.configuredKey': return '已配置密鑰';
			case 'translation.notConfiguredKey': return '未配置密鑰';
			case 'translation.authenticationStatus': return '認證狀態';
			case 'translation.thisFieldCannotBeEmpty': return '此字段不能為空';
			case 'translation.apiKey': return 'API密鑰';
			case 'translation.apiKeyCannotBeEmpty': return 'API密鑰不能為空';
			case 'translation.range': return '範圍';
			case 'translation.pleaseEnterValidNumber': return '請輸入有效數字';
			case 'translation.mustBeGreaterThan': return '必須大於';
			case 'translation.invalidAPIResponse': return '無效的API響應';
			case 'translation.connectionFailedForMessage': return ({required Object message}) => '連接失敗: ${message}';
			case 'translation.aiTranslationNotEnabledHint': return 'AI翻譯未啟用，請在設定中啟用';
			case 'translation.goToSettings': return '前往設定';
			case 'translation.disableAITranslation': return '禁用AI翻譯';
			case 'translation.currentValue': return '現在值';
			case 'translation.configureTranslationStrategy': return '配置翻譯策略';
			case 'translation.advancedSettings': return '高級設定';
			case 'translation.translationPrompt': return '翻譯提示詞';
			case 'translation.promptHint': return '請輸入翻譯提示詞,使用[TL]作為目標語言的占位符';
			case 'translation.promptHelperText': return '提示詞必須包含[TL]作為目標語言的占位符';
			case 'translation.promptMustContainTargetLang': return '提示詞必須包含[TL]占位符';
			case 'translation.aiTranslationWillBeDisabled': return 'AI翻譯將被自動關閉';
			case 'translation.aiTranslationWillBeDisabledDueToConfigChange': return '由於修改了基礎配置,AI翻譯將被自動關閉';
			case 'translation.aiTranslationWillBeDisabledDueToPromptChange': return '由於修改了翻譯提示詞,AI翻譯將被自動關閉';
			case 'translation.aiTranslationWillBeDisabledDueToParamChange': return '由於修改了參數配置,AI翻譯將被自動關閉';
			case 'translation.onlyOpenAIAPISupported': return '目前僅支持OpenAI兼容的API格式（application/json請求體格式）';
			case 'translation.streamingTranslation': return '流式翻譯';
			case 'translation.streamingTranslationSupported': return '支持流式翻譯';
			case 'translation.streamingTranslationNotSupported': return '不支持流式翻譯';
			case 'translation.streamingTranslationDescription': return '流式翻譯可以在翻譯過程中實時顯示結果，提供更好的用戶體驗';
			case 'translation.baseUrlInputHelperText': return '當以#結尾時，將以輸入的URL作為實際請求地址';
			case 'translation.usingFullUrlWithHash': return '使用完整URL（以#結尾）';
			case 'translation.currentActualUrl': return ({required Object url}) => '目前實際URL: ${url}';
			case 'translation.urlEndingWithHashTip': return 'URL以#結尾時，將以輸入的URL作為實際請求地址';
			case 'translation.streamingTranslationWarning': return '注意：此功能需要API服務支持流式傳輸，部分模型可能不支持';
			case 'mediaPlayer.videoPlayerError': return '影片播放器錯誤';
			case 'mediaPlayer.videoLoadFailed': return '影片載入失敗';
			case 'mediaPlayer.videoCodecNotSupported': return '影片編解碼器不支援';
			case 'mediaPlayer.networkConnectionIssue': return '網路連線問題';
			case 'mediaPlayer.insufficientPermission': return '權限不足';
			case 'mediaPlayer.unsupportedVideoFormat': return '不支援的影片格式';
			case 'mediaPlayer.retry': return '重試';
			case 'mediaPlayer.externalPlayer': return '外部播放器';
			case 'mediaPlayer.detailedErrorInfo': return '詳細錯誤資訊';
			case 'mediaPlayer.format': return '格式';
			case 'mediaPlayer.suggestion': return '建議';
			case 'mediaPlayer.androidWebmCompatibilityIssue': return 'Android裝置對WEBM格式支援有限，建議使用外部播放器或下載支援WEBM的播放器應用';
			case 'mediaPlayer.currentDeviceCodecNotSupported': return '目前裝置不支援此影片格式的編解碼器';
			case 'mediaPlayer.checkNetworkConnection': return '請檢查網路連線後重試';
			case 'mediaPlayer.appMayLackMediaPermission': return '應用可能缺少必要的媒體播放權限';
			case 'mediaPlayer.tryOtherVideoPlayer': return '請嘗試使用其他影片播放器';
			case 'mediaPlayer.video': return '影片';
			case 'mediaPlayer.imageLoadFailed': return '圖片載入失敗';
			case 'mediaPlayer.unsupportedImageFormat': return '不支援的圖片格式';
			case 'mediaPlayer.tryOtherViewer': return '請嘗試使用其他檢視器';
			case 'linkInputDialog.title': return '輸入連結';
			case 'linkInputDialog.supportedLinksHint': return ({required Object webName}) => '支持智能識別多個${webName}連結，並快速跳轉到應用內對應頁面(連結與其他文本之間用空格隔開)';
			case 'linkInputDialog.inputHint': return ({required Object webName}) => '請輸入${webName}連結';
			case 'linkInputDialog.validatorEmptyLink': return '請輸入連結';
			case 'linkInputDialog.validatorNoIwaraLink': return ({required Object webName}) => '未檢測到有效的${webName}連結';
			case 'linkInputDialog.multipleLinksDetected': return '檢測到多個連結，請選擇一個：';
			case 'linkInputDialog.notIwaraLink': return ({required Object webName}) => '不是有效的${webName}連結';
			case 'linkInputDialog.linkParseError': return ({required Object error}) => '連結解析出錯: ${error}';
			case 'linkInputDialog.unsupportedLinkDialogTitle': return '不支援的連結';
			case 'linkInputDialog.unsupportedLinkDialogContent': return '該連結類型當前應用無法直接打開，需要使用外部瀏覽器訪問。\n\n是否使用瀏覽器打開此連結？';
			case 'linkInputDialog.openInBrowser': return '用瀏覽器打開';
			case 'linkInputDialog.confirmOpenBrowserDialogTitle': return '確認打開瀏覽器';
			case 'linkInputDialog.confirmOpenBrowserDialogContent': return '即將使用外部瀏覽器打開以下連結：';
			case 'linkInputDialog.confirmContinueBrowserOpen': return '確定要繼續嗎？';
			case 'linkInputDialog.browserOpenFailed': return '無法打開連結';
			case 'linkInputDialog.unsupportedLink': return '不支援的連結';
			case 'linkInputDialog.cancel': return '取消';
			case 'linkInputDialog.confirm': return '用瀏覽器打開';
			case 'log.logManagement': return '日志管理';
			case 'log.enableLogPersistence': return '持久化日志';
			case 'log.enableLogPersistenceDesc': return '將日志保存到數據庫以便於分析問題';
			case 'log.logDatabaseSizeLimit': return '日志數據庫大小上限';
			case 'log.logDatabaseSizeLimitDesc': return ({required Object size}) => '當前: ${size}';
			case 'log.exportCurrentLogs': return '導出當前日志';
			case 'log.exportCurrentLogsDesc': return '導出當天應用日志以幫助開發者診斷問題';
			case 'log.exportHistoryLogs': return '導出歷史日志';
			case 'log.exportHistoryLogsDesc': return '導出指定日期範圍內的日志';
			case 'log.exportMergedLogs': return '導出合併日志';
			case 'log.exportMergedLogsDesc': return '導出指定日期範圍內的合併日志';
			case 'log.showLogStats': return '顯示日志統計信息';
			case 'log.logExportSuccess': return '日志導出成功';
			case 'log.logExportFailed': return ({required Object error}) => '日志導出失敗: ${error}';
			case 'log.showLogStatsDesc': return '查看各種類型日志的統計數據';
			case 'log.logExtractFailed': return ({required Object error}) => '獲取日志統計失敗: ${error}';
			case 'log.clearAllLogs': return '清理所有日志';
			case 'log.clearAllLogsDesc': return '清理所有日志數據';
			case 'log.confirmClearAllLogs': return '確認清理';
			case 'log.confirmClearAllLogsDesc': return '確定要清理所有日志數據嗎？此操作不可撤銷。';
			case 'log.clearAllLogsSuccess': return '日志清理成功';
			case 'log.clearAllLogsFailed': return ({required Object error}) => '清理日志失敗: ${error}';
			case 'log.unableToGetLogSizeInfo': return '無法獲取日志大小信息';
			case 'log.currentLogSize': return '當前日志大小:';
			case 'log.logCount': return '日志數量:';
			case 'log.logCountUnit': return '條';
			case 'log.logSizeLimit': return '大小上限:';
			case 'log.usageRate': return '使用率:';
			case 'log.exceedLimit': return '超出限制';
			case 'log.remaining': return '剩餘';
			case 'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit': return '日志空間已超出限制，建議立即清理舊日志或增加空間限制';
			case 'log.currentLogSizeAlmostExceededPleaseCleanOldLogs': return '日志空間即將用盡，建議清理舊日志';
			case 'log.cleaningOldLogs': return '正在自動清理舊日志...';
			case 'log.logCleaningCompleted': return '日志清理完成';
			case 'log.logCleaningProcessMayNotBeCompleted': return '日志清理過程可能未完成';
			case 'log.cleanExceededLogs': return '清理超出限制的日志';
			case 'log.noLogsToExport': return '沒有可導出的日志數據';
			case 'log.exportingLogs': return '正在導出日志...';
			case 'log.noHistoryLogsToExport': return '尚無可導出的歷史日志，請先使用應用一段時間再嘗試';
			case 'log.selectLogDate': return '選擇日志日期';
			case 'log.today': return '今天';
			case 'log.selectMergeRange': return '選擇合併範圍';
			case 'log.selectMergeRangeHint': return '請選擇要合併的日志時間範圍';
			case 'log.selectMergeRangeDays': return ({required Object days}) => '最近 ${days} 天';
			case 'log.logStats': return '日志統計信息';
			case 'log.todayLogs': return ({required Object count}) => '今日日志: ${count} 條';
			case 'log.recent7DaysLogs': return ({required Object count}) => '最近7天: ${count} 條';
			case 'log.totalLogs': return ({required Object count}) => '總計日志: ${count} 條';
			case 'log.setLogDatabaseSizeLimit': return '設置日志數據庫大小上限';
			case 'log.currentLogSizeWithSize': return ({required Object size}) => '當前日志大小: ${size}';
			case 'log.warning': return '警告';
			case 'log.newSizeLimit': return ({required Object size}) => '新的大小限制: ${size}';
			case 'log.confirmToContinue': return '確定要繼續嗎？';
			case 'log.logSizeLimitSetSuccess': return ({required Object size}) => '日志大小上限已設置為 ${size}';
			default: return null;
		}
	}
}

