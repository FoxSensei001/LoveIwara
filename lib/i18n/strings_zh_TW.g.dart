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
	@override late final _TranslationsTutorialZhTw tutorial = _TranslationsTutorialZhTw._(_root);
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
	@override late final _TranslationsFirstTimeSetupZhTw firstTimeSetup = _TranslationsFirstTimeSetupZhTw._(_root);
	@override late final _TranslationsProxyHelperZhTw proxyHelper = _TranslationsProxyHelperZhTw._(_root);
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
	@override late final _TranslationsEmojiZhTw emoji = _TranslationsEmojiZhTw._(_root);
	@override late final _TranslationsDisplaySettingsZhTw displaySettings = _TranslationsDisplaySettingsZhTw._(_root);
	@override late final _TranslationsLayoutSettingsZhTw layoutSettings = _TranslationsLayoutSettingsZhTw._(_root);
	@override late final _TranslationsNavigationOrderSettingsZhTw navigationOrderSettings = _TranslationsNavigationOrderSettingsZhTw._(_root);
	@override late final _TranslationsSearchFilterZhTw searchFilter = _TranslationsSearchFilterZhTw._(_root);
	@override late final _TranslationsTagSelectorZhTw tagSelector = _TranslationsTagSelectorZhTw._(_root);
	@override late final _TranslationsAnime4kZhTw anime4k = _TranslationsAnime4kZhTw._(_root);
}

// Path: tutorial
class _TranslationsTutorialZhTw implements TranslationsTutorialEn {
	_TranslationsTutorialZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => '特別關注功能';
	@override String get specialFollowDescription => '這裡顯示你特別關注的作者。在影片、圖庫、作者詳情頁點擊關注按鈕，然後選擇"添加為特別關注"即可。';
	@override String get exampleAuthorInfoRow => '示例：作者信息行';
	@override String get authorName => '作者名稱';
	@override String get followed => '已關注';
	@override String get specialFollowInstruction => '點擊"已關注"按鈕 → 選擇"添加為特別關注"';
	@override String get followButtonLocations => '關注按鈕位置：';
	@override String get videoDetailPage => '影片詳情頁';
	@override String get galleryDetailPage => '圖庫詳情頁';
	@override String get authorDetailPage => '作者詳情頁';
	@override String get afterSpecialFollow => '特別關注後，可在此快速查看作者最新內容！';
	@override String get specialFollowManagementTip => '特別關注列表可在側邊抽屜欄-關注列表-特別關注列表頁面裡管理';
	@override String get skip => '跳過';
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
	@override String get markdownSyntaxHelp => 'Markdown語法幫助';
	@override String get previewContent => '預覽內容';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => '超過最大長度限制 (${max})';
	@override String get agreeToCommunityRules => '同意社群規則';
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
	@override String get createTimeDesc => '創建時間倒序';
	@override String get createTimeAsc => '創建時間正序';
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
	@override String get fullscreenOrientation => '豎屏進入全屏後的螢幕方向';
	@override String get fullscreenOrientationDesc => '此設定決定豎屏進入全屏時螢幕的預設方向（僅移動端有效）';
	@override String get fullscreenOrientationLeftLandscape => '左側橫螢幕';
	@override String get fullscreenOrientationRightLandscape => '右側橫螢幕';
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
	@override String get enableHorizontalDragSeek => '橫向滑動調整進度';
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
	@override late final _TranslationsSettingsForumSettingsZhTw forumSettings = _TranslationsSettingsForumSettingsZhTw._(_root);
	@override late final _TranslationsSettingsChatSettingsZhTw chatSettings = _TranslationsSettingsChatSettingsZhTw._(_root);
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

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupZhTw implements TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeZhTw welcome = _TranslationsFirstTimeSetupWelcomeZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupBasicZhTw basic = _TranslationsFirstTimeSetupBasicZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkZhTw network = _TranslationsFirstTimeSetupNetworkZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupThemeZhTw theme = _TranslationsFirstTimeSetupThemeZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerZhTw player = _TranslationsFirstTimeSetupPlayerZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionZhTw completion = _TranslationsFirstTimeSetupCompletionZhTw._(_root);
	@override late final _TranslationsFirstTimeSetupCommonZhTw common = _TranslationsFirstTimeSetupCommonZhTw._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperZhTw implements TranslationsProxyHelperEn {
	_TranslationsProxyHelperZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => '檢測到系統代理';
	@override String get copied => '已複製';
	@override String get copy => '複製';
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
	@override late final _TranslationsVideoDetailPlayerZhTw player = _TranslationsVideoDetailPlayerZhTw._(_root);
	@override late final _TranslationsVideoDetailSkeletonZhTw skeleton = _TranslationsVideoDetailSkeletonZhTw._(_root);
	@override late final _TranslationsVideoDetailCastZhTw cast = _TranslationsVideoDetailCastZhTw._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsZhTw likeAvatars = _TranslationsVideoDetailLikeAvatarsZhTw._(_root);
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
	@override String get kApprovedForumPost => '論壇發言審核通過';
	@override String get kRejectedContent => '內容審核被拒絕';
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
	@override String get viewDownloadList => '查看下載列表';
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
	@override String get alreadyDownloadedWithQuality => '已有相同清晰度的任務，是否繼續下載？';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => '此視頻已有${qualities}清晰度的任務，是否繼續下載？';
	@override String get otherQualities => '其他清晰度';
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
	@override String get translationService => '翻譯服務';
	@override String get translationServiceDescription => '選擇您偏好的翻譯服務';
	@override String get googleTranslation => 'Google 翻譯';
	@override String get googleTranslationDescription => '免費的線上翻譯服務，支援多種語言';
	@override String get aiTranslation => 'AI 翻譯';
	@override String get aiTranslationDescription => '基於大語言模型的智慧翻譯服務';
	@override String get deeplxTranslation => 'DeepLX 翻譯';
	@override String get deeplxTranslationDescription => 'DeepL 翻譯的開源實現，提供高品質翻譯';
	@override String get googleTranslationFeatures => '特性';
	@override String get freeToUse => '免費使用';
	@override String get freeToUseDescription => '無需配置，開箱即用';
	@override String get fastResponse => '快速響應';
	@override String get fastResponseDescription => '翻譯速度快，延遲低';
	@override String get stableAndReliable => '穩定可靠';
	@override String get stableAndReliableDescription => '基於Google官方API';
	@override String get enabledDefaultService => '已啟用 - 預設翻譯服務';
	@override String get notEnabled => '未啟用';
	@override String get deeplxTranslationService => 'DeepLX 翻譯服務';
	@override String get deeplxDescription => 'DeepLX 是 DeepL 翻譯的開源實現，支援 Free、Pro 和 Official 三種端點模式';
	@override String get serverAddress => '伺服器地址';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'DeepLX 伺服器的基礎地址';
	@override String get endpointType => '端點類型';
	@override String get freeEndpoint => 'Free - 免費端點，可能有頻率限制';
	@override String get proEndpoint => 'Pro - 需要 dl_session，更穩定';
	@override String get officialEndpoint => 'Official - 官方 API 格式';
	@override String get finalRequestUrl => '最終請求URL';
	@override String get apiKeyOptional => 'API Key (可選)';
	@override String get apiKeyOptionalHint => '用於訪問受保護的 DeepLX 服務';
	@override String get apiKeyOptionalHelperText => '某些 DeepLX 服務需要 API Key 進行身份驗證';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Pro 模式需要的 dl_session 參數';
	@override String get dlSessionHelperText => 'Pro 端點必需的會話參數，從 DeepL Pro 帳戶獲取';
	@override String get proModeRequiresDlSession => 'Pro 模式需要填寫 dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => '點擊測試按鈕驗證 DeepLX API 連接';
	@override String get enableDeepLXTranslation => '啟用 DeepLX 翻譯';
	@override String get deepLXTranslationWillBeDisabled => 'DeepLX翻譯將因配置更改而被禁用';
	@override String get translatedResult => '翻譯結果';
	@override String get testSuccess => '測試成功';
	@override String get pleaseFillInDeepLXServerAddress => '請填寫DeepLX伺服器地址';
	@override String get invalidAPIResponseFormat => '無效的API響應格式';
	@override String get translationServiceReturnedError => '翻譯服務返回錯誤或空結果';
	@override String get connectionFailed => '連接失敗';
	@override String get translationFailed => '翻譯失敗';
	@override String get aiTranslationFailed => 'AI翻譯失敗';
	@override String get deeplxTranslationFailed => 'DeepLX翻譯失敗';
	@override String get aiTranslationTestFailed => 'AI翻譯測試失敗';
	@override String get deeplxTranslationTestFailed => 'DeepLX翻譯測試失敗';
	@override String get streamingTranslationTimeout => '流式翻譯超時，強制關閉資源';
	@override String get translationRequestTimeout => '翻譯請求超時';
	@override String get streamingTranslationDataTimeout => '流式翻譯接收數據超時';
	@override String get dataReceptionTimeout => '接收數據超時';
	@override String get streamDataParseError => '解析流數據時出錯';
	@override String get streamingTranslationFailed => '流式翻譯失敗';
	@override String get fallbackTranslationFailed => '降級到普通翻譯也失敗';
	@override String get translationSettings => '翻譯設定';
	@override String get enableGoogleTranslation => '啟用 Google 翻譯';
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
	@override String get retryingOpenVideoLink => '影片連結開啟失敗，重試中';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => '無法載入解碼器: ${event}，可在播放器設定切換為軟解，並重新進入頁面嘗試';
	@override String videoLoadErrorWithDetail({required Object event}) => '影片載入錯誤: ${event}';
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

// Path: emoji
class _TranslationsEmojiZhTw implements TranslationsEmojiEn {
	_TranslationsEmojiZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get name => '表情';
	@override String get size => '大小';
	@override String get small => '小';
	@override String get medium => '中';
	@override String get large => '大';
	@override String get extraLarge => '超大';
	@override String get copyEmojiLinkSuccess => '表情包連結已複製';
	@override String get preview => '表情包預覽';
	@override String get library => '表情包庫';
	@override String get noEmojis => '暫無表情包';
	@override String get clickToAddEmojis => '點擊右上角按鈕添加表情包';
	@override String get addEmojis => '添加表情包';
	@override String get imagePreview => '圖片預覽';
	@override String get imageLoadFailed => '圖片載入失敗';
	@override String get loading => '載入中...';
	@override String get delete => '刪除';
	@override String get close => '關閉';
	@override String get deleteImage => '刪除圖片';
	@override String get confirmDeleteImage => '確定要刪除這張圖片嗎？';
	@override String get cancel => '取消';
	@override String get batchDelete => '批量刪除';
	@override String confirmBatchDelete({required Object count}) => '確定要刪除選中的${count}張圖片嗎？此操作不可撤銷。';
	@override String get deleteSuccess => '成功刪除';
	@override String get addImage => '添加圖片';
	@override String get addImageByUrl => '通過URL添加';
	@override String get addImageUrl => '添加圖片URL';
	@override String get imageUrl => '圖片URL';
	@override String get enterImageUrl => '請輸入圖片URL';
	@override String get add => '添加';
	@override String get batchImport => '批量導入';
	@override String get enterJsonUrlArray => '請輸入JSON格式的URL數組:';
	@override String get formatExample => '格式示例:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => '請粘貼JSON格式的URL數組';
	@override String get import => '導入';
	@override String importSuccess({required Object count}) => '成功導入${count}張圖片';
	@override String get jsonFormatError => 'JSON格式錯誤，請檢查輸入';
	@override String get createGroup => '創建表情包分組';
	@override String get groupName => '分組名稱';
	@override String get enterGroupName => '請輸入分組名稱';
	@override String get create => '創建';
	@override String get editGroupName => '編輯分組名稱';
	@override String get save => '保存';
	@override String get deleteGroup => '刪除分組';
	@override String get confirmDeleteGroup => '確定要刪除這個表情包分組嗎？分組內的所有圖片也會被刪除。';
	@override String imageCount({required Object count}) => '${count}張圖片';
	@override String get selectEmoji => '選擇表情包';
	@override String get noEmojisInGroup => '該分組暫無表情包';
	@override String get goToSettingsToAddEmojis => '前往設置添加表情包';
	@override String get emojiManagement => '表情包管理';
	@override String get manageEmojiGroupsAndImages => '管理表情包分組和圖片';
	@override String get uploadLocalImages => '上傳本地圖片';
	@override String get uploadingImages => '正在上傳圖片';
	@override String uploadingImagesProgress({required Object count}) => '正在上傳 ${count} 張圖片，請稍候...';
	@override String get doNotCloseDialog => '請不要關閉此對話框';
	@override String uploadSuccess({required Object count}) => '成功上傳 ${count} 張圖片';
	@override String uploadFailed({required Object count}) => '失敗 ${count} 張';
	@override String get uploadFailedMessage => '圖片上傳失敗，請檢查網路連接或檔案格式';
	@override String uploadErrorMessage({required Object error}) => '上傳過程中發生錯誤: ${error}';
}

// Path: displaySettings
class _TranslationsDisplaySettingsZhTw implements TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '顯示設定';
	@override String get layoutSettings => '版面配置設定';
	@override String get layoutSettingsDesc => '自訂欄數和斷點配置';
	@override String get gridLayout => '網格版面配置';
	@override String get navigationOrderSettings => '導航排序設定';
	@override String get customNavigationOrder => '自訂導航順序';
	@override String get customNavigationOrderDesc => '調整底部導航欄和側邊欄中頁面的顯示順序';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsZhTw implements TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '版面配置設定';
	@override String get descriptionTitle => '版面配置說明';
	@override String get descriptionContent => '這裡的配置將決定影片、圖庫列表頁面中顯示的欄數。您可以選擇自動模式讓系統根據螢幕寬度自動調整，或選擇手動模式固定欄數。';
	@override String get layoutMode => '版面配置模式';
	@override String get reset => '重設';
	@override String get autoMode => '自動模式';
	@override String get autoModeDesc => '根據螢幕寬度自動調整';
	@override String get manualMode => '手動模式';
	@override String get manualModeDesc => '使用固定欄數';
	@override String get manualSettings => '手動設定';
	@override String get fixedColumns => '固定欄數';
	@override String get columns => '欄';
	@override String get breakpointConfig => '斷點配置';
	@override String get add => '新增';
	@override String get defaultColumns => '預設欄數';
	@override String get defaultColumnsDesc => '大螢幕預設顯示';
	@override String get previewEffect => '預覽效果';
	@override String get screenWidth => '螢幕寬度';
	@override String get addBreakpoint => '新增斷點';
	@override String get editBreakpoint => '編輯斷點';
	@override String get deleteBreakpoint => '刪除斷點';
	@override String get screenWidthLabel => '螢幕寬度';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => '欄數';
	@override String get columnsHint => '3';
	@override String get enterWidth => '請輸入寬度';
	@override String get enterValidWidth => '請輸入有效寬度';
	@override String get widthCannotExceed9999 => '寬度不能超過9999';
	@override String get breakpointAlreadyExists => '斷點已存在';
	@override String get enterColumns => '請輸入欄數';
	@override String get enterValidColumns => '請輸入有效欄數';
	@override String get columnsCannotExceed12 => '欄數不能超過12';
	@override String get breakpointConflict => '斷點已存在';
	@override String get confirmResetLayoutSettings => '重設版面配置設定';
	@override String get confirmResetLayoutSettingsDesc => '確定要重設所有版面配置設定到預設值嗎？\n\n將恢復為：\n• 自動模式\n• 預設斷點配置';
	@override String get resetToDefaults => '重設為預設值';
	@override String get confirmDeleteBreakpoint => '刪除斷點';
	@override String confirmDeleteBreakpointDesc({required Object width}) => '確定要刪除 ${width}px 斷點嗎？';
	@override String get noCustomBreakpoints => '暫無自訂斷點，使用預設欄數';
	@override String get breakpointRange => '斷點區間';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => '編輯';
	@override String get delete => '刪除';
	@override String get cancel => '取消';
	@override String get save => '儲存';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsZhTw implements TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '導航排序設定';
	@override String get customNavigationOrder => '自訂導航順序';
	@override String get customNavigationOrderDesc => '拖拽調整底部導航欄和側邊欄中各個頁面的顯示順序';
	@override String get restartRequired => '需重啟應用生效';
	@override String get navigationItemSorting => '導航項目排序';
	@override String get done => '完成';
	@override String get edit => '編輯';
	@override String get reset => '重設';
	@override String get previewEffect => '預覽效果';
	@override String get bottomNavigationPreview => '底部導航欄預覽：';
	@override String get sidebarPreview => '側邊欄預覽：';
	@override String get confirmResetNavigationOrder => '確認重設導航順序';
	@override String get confirmResetNavigationOrderDesc => '確定要將導航順序重設為預設設定嗎？';
	@override String get cancel => '取消';
	@override String get videoDescription => '瀏覽熱門影片內容';
	@override String get galleryDescription => '瀏覽圖片和畫廊';
	@override String get subscriptionDescription => '查看追蹤用戶的最新內容';
	@override String get forumDescription => '參與社群討論';
}

// Path: searchFilter
class _TranslationsSearchFilterZhTw implements TranslationsSearchFilterEn {
	_TranslationsSearchFilterZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get selectField => '選擇欄位';
	@override String get add => '新增';
	@override String get clear => '清空';
	@override String get clearAll => '清空全部';
	@override String get generatedQuery => '產生的查詢';
	@override String get copyToClipboard => '複製到剪貼簿';
	@override String get copied => '已複製';
	@override String filterCount({required Object count}) => '${count} 個過濾器';
	@override String get filterSettings => '篩選項設定';
	@override String get field => '欄位';
	@override String get operator => '運算子';
	@override String get language => '語言';
	@override String get value => '值';
	@override String get dateRange => '日期範圍';
	@override String get numberRange => '數值範圍';
	@override String get from => '從';
	@override String get to => '到';
	@override String get date => '日期';
	@override String get number => '數值';
	@override String get boolean => '布林值';
	@override String get tags => '標籤';
	@override String get select => '選擇';
	@override String get clickToSelectDate => '點擊選擇日期';
	@override String get pleaseEnterValidNumber => '請輸入有效的數值';
	@override String get pleaseEnterValidDate => '請輸入有效的日期格式 (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => '起始值必須小於結束值';
	@override String get startDateMustBeBeforeEndDate => '起始日期必須早於結束日期';
	@override String get pleaseFillStartValue => '請填寫起始值';
	@override String get pleaseFillEndValue => '請填寫結束值';
	@override String get rangeValueFormatError => '範圍值格式錯誤';
	@override String get contains => '包含';
	@override String get equals => '等於';
	@override String get notEquals => '不等於';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => '範圍';
	@override String get kIn => '包含任意一項';
	@override String get notIn => '不包含任意一項';
	@override String get username => '使用者名稱';
	@override String get nickname => '暱稱';
	@override String get registrationDate => '註冊日期';
	@override String get description => '描述';
	@override String get title => '標題';
	@override String get body => '內容';
	@override String get author => '作者';
	@override String get publishDate => '發布日期';
	@override String get private => '私密';
	@override String get duration => '時長(秒)';
	@override String get likes => '讚數';
	@override String get views => '觀看數';
	@override String get comments => '評論數';
	@override String get rating => '評級';
	@override String get imageCount => '圖片數量';
	@override String get videoCount => '影片數量';
	@override String get createDate => '建立日期';
	@override String get content => '內容';
	@override String get all => '全部的';
	@override String get adult => '成人的';
	@override String get general => '大眾的';
	@override String get yes => '是';
	@override String get no => '否';
	@override String get users => '使用者';
	@override String get videos => '影片';
	@override String get images => '圖片';
	@override String get posts => '貼文';
	@override String get forumThreads => '論壇主題';
	@override String get forumPosts => '論壇貼文';
	@override String get playlists => '播放清單';
	@override late final _TranslationsSearchFilterSortTypesZhTw sortTypes = _TranslationsSearchFilterSortTypesZhTw._(_root);
}

// Path: tagSelector
class _TranslationsTagSelectorZhTw implements TranslationsTagSelectorEn {
	_TranslationsTagSelectorZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get selectTags => '選擇標籤';
	@override String get clickToSelectTags => '點擊選擇標籤';
	@override String get addTag => '新增標籤';
	@override String get removeTag => '移除標籤';
	@override String get deleteTag => '刪除標籤';
	@override String get usageInstructions => '需先新增標籤，然後再從已有的標籤中點擊選中';
	@override String get usageInstructionsTooltip => '使用說明';
	@override String get addTagTooltip => '新增標籤';
	@override String get removeTagTooltip => '刪除標籤';
	@override String get cancelSelection => '取消選擇';
	@override String get selectAll => '全選';
	@override String get cancelSelectAll => '取消全選';
	@override String get delete => '刪除';
}

// Path: anime4k
class _TranslationsAnime4kZhTw implements TranslationsAnime4kEn {
	_TranslationsAnime4kZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Anime4K 即時視頻上採樣和降噪，提升動畫視頻品質';
	@override String get settings => 'Anime4K 設定';
	@override String get preset => 'Anime4K 預設';
	@override String get disable => '關閉 Anime4K';
	@override String get disableDescription => '禁用視頻增強效果';
	@override String get highQualityPresets => '高品質預設';
	@override String get fastPresets => '快速預設';
	@override String get litePresets => '輕量級預設';
	@override String get moreLitePresets => '更多輕量級預設';
	@override String get customPresets => '自定義預設';
	@override late final _TranslationsAnime4kPresetGroupsZhTw presetGroups = _TranslationsAnime4kPresetGroupsZhTw._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsZhTw presetDescriptions = _TranslationsAnime4kPresetDescriptionsZhTw._(_root);
	@override late final _TranslationsAnime4kPresetNamesZhTw presetNames = _TranslationsAnime4kPresetNamesZhTw._(_root);
	@override String get performanceTip => '💡 提示：根據設備性能選擇合適的預設，低端設備建議選擇輕量級預設。';
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

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsZhTw implements TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get name => '論壇';
	@override String get configureYourForumSettings => '配置您的論壇設定';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsZhTw implements TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get name => '聊天';
	@override String get configureYourChatSettings => '配置您的聊天設定';
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
	@override String get actualDownloadPath => '實際下載路徑';
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
	@override String get externalAppPrivateDirectory => '外部應用程式專用目錄';
	@override String get externalAppPrivateDirectoryDesc => '外部儲存應用程式專用目錄，使用者可存取，空間較大';
	@override String get internalAppPrivateDirectory => '內部應用程式專用目錄';
	@override String get internalAppPrivateDirectoryDesc => '應用程式內部儲存，無需權限，空間較小';
	@override String get appDocumentsDirectory => '應用程式文件目錄';
	@override String get appDocumentsDirectoryDesc => '應用程式專用文件目錄，安全可靠';
	@override String get downloadsFolder => '下載資料夾';
	@override String get downloadsFolderDesc => '系統預設下載目錄';
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

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeZhTw implements TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '歡迎使用';
	@override String get subtitle => '讓我們開始您的個人化設定之旅';
	@override String get description => '只需幾步，即可為您量身打造最佳使用體驗';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicZhTw implements TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '基礎設定';
	@override String get subtitle => '個人化您的使用體驗';
	@override String get description => '選擇適合您的功能偏好';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkZhTw implements TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '網路設定';
	@override String get subtitle => '配置網路連線選項';
	@override String get description => '根據您的網路環境進行相應配置';
	@override String get tip => '設定成功後需重啟應用才會生效';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeZhTw implements TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '主題設定';
	@override String get subtitle => '選擇您喜歡的介面主題';
	@override String get description => '個人化您的視覺體驗';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerZhTw implements TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '播放器設定';
	@override String get subtitle => '配置播放控制偏好';
	@override String get description => '您可以在此快速設定常用的播放體驗';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionZhTw implements TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '完成設定';
	@override String get subtitle => '即將開始您的精彩旅程';
	@override String get description => '請閱讀並同意相關協議';
	@override String get agreementTitle => '使用者協議與社群規則';
	@override String get agreementDesc => '在使用本應用前，請您仔細閱讀並同意我們的使用者協議與社群規則。這些條款有助於維護良好的使用環境。';
	@override String get checkboxTitle => '我已閱讀並同意使用者協議與社群規則';
	@override String get checkboxSubtitle => '不同意將無法使用本應用';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonZhTw implements TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => '這些設定可在應用設定中隨時修改';
	@override String get agreeAgreementSnackbar => '請先同意使用者協議與社群規則';
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerZhTw implements TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => '在加載影片來源時出現了錯誤';
	@override String get errorWhileSettingUpListeners => '在設置監聽器時出現了錯誤';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonZhTw implements TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => '取得影片資訊中...';
	@override String get fetchingVideoSources => '取得影片來源中...';
	@override String get loadingVideo => '正在加載影片...';
	@override String get applyingSolution => '正在應用此解析度...';
	@override String get addingListeners => '正在添加監聽器...';
	@override String get successFecthVideoDurationInfo => '成功獲取影片資源，開始加載影片...';
	@override String get successFecthVideoHeightInfo => '加載完成';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastZhTw implements TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => '投屏';
	@override String unableToStartCastingSearch({required Object error}) => '啟動投屏搜索失敗: ${error}';
	@override String startCastingTo({required Object deviceName}) => '開始投屏到 ${deviceName}';
	@override String castFailed({required Object error}) => '投屏失敗: ${error}\n請嘗試重新搜索設備或切換網絡';
	@override String get castStopped => '已停止投屏';
	@override late final _TranslationsVideoDetailCastDeviceTypesZhTw deviceTypes = _TranslationsVideoDetailCastDeviceTypesZhTw._(_root);
	@override String get currentPlatformNotSupported => '當前平台不支援投屏功能';
	@override String get unableToGetVideoUrl => '無法獲取影片地址，請稍後重試';
	@override String get stopCasting => '停止投屏';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetZhTw dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetZhTw._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsZhTw implements TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => '誰悄悄地喜歡';
	@override String get dialogDescription => '好奇他們是誰？來翻翻這本「按讚相簿」吧～';
	@override String get closeTooltip => '關閉';
	@override String get retry => '重試';
	@override String get noLikesYet => '還沒有人出現在這裡，來當第一個吧！';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => '第 ${page} / ${totalPages} 頁 · 共 ${totalCount} 人';
	@override String get prevPage => '上一頁';
	@override String get nextPage => '下一頁';
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
	@override String get sslHandshakeFailed => 'SSL握手失敗，請檢查網路環境';
	@override String get connectionFailed => '連接失敗，請檢查網路';
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

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesZhTw implements TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get relevance => '相關性';
	@override String get latest => '最新';
	@override String get views => '觀看次數';
	@override String get likes => '按讚數';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsZhTw implements TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get highQuality => '高品質';
	@override String get fast => '快速';
	@override String get lite => '輕量級';
	@override String get moreLite => '更多輕量級';
	@override String get custom => '自定義';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsZhTw implements TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => '適用於大多數1080p動漫，特別是處理模糊、重採樣和壓縮瑕疵。提供最高的感知品質。';
	@override String get mode_b_hq => '適用於輕微模糊或因縮放產生的振鈴效應的動漫。可以有效減少振鈴和鋸齒。';
	@override String get mode_c_hq => '適用於幾乎沒有瑕疵的高品質片源（如原生1080p的動畫電影或壁紙）。降噪並提供最高的PSNR。';
	@override String get mode_a_a_hq => 'Mode A的強化版，提供極致的感知品質，能重建幾乎所有退化的線條。可能產生過度銳化或振鈴。';
	@override String get mode_b_b_hq => 'Mode B的強化版，提供更高的感知品質，進一步優化線條和減少瑕疵。';
	@override String get mode_c_a_hq => 'Mode C的感知品質增強版，在保持高PSNR的同時嘗試重建一些線條細節。';
	@override String get mode_a_fast => 'Mode A的快速版本，平衡了品質與性能，適用於大多數1080p動漫。';
	@override String get mode_b_fast => 'Mode B的快速版本，用於處理輕微瑕疵和振鈴，性能開銷較低。';
	@override String get mode_c_fast => 'Mode C的快速版本，適用於高品質片源的快速降噪和放大。';
	@override String get mode_a_a_fast => 'Mode A+A的快速版本，在性能有限的設備上追求更高的感知品質。';
	@override String get mode_b_b_fast => 'Mode B+B的快速版本，為性能有限的設備提供增強的線條修復和瑕疵處理。';
	@override String get mode_c_a_fast => 'Mode C+A的快速版本，在快速處理高品質片源的同時，進行輕度的線條修復。';
	@override String get upscale_only_s => '僅使用最快的CNN模型進行x2放大，無修復和降噪，性能開銷最低。';
	@override String get upscale_deblur_fast => '使用快速的非CNN算法進行放大和去模糊，效果優於傳統算法，性能開銷很低。';
	@override String get restore_s_only => '僅使用最快的CNN模型修復畫面瑕疵，不進行放大。適用於原生分辨率播放，但希望改善畫質的情況。';
	@override String get denoise_bilateral_fast => '使用傳統的雙邊濾波器進行降噪，速度極快，適用於處理輕微噪點。';
	@override String get upscale_non_cnn => '使用快速的傳統算法進行放大，性能開銷極低，效果優於播放器自帶算法。';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 線條加深，在快速模式A的基礎上增加線條加深效果，使線條更突出，風格化處理。';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 線條細化，在高品質模式A的基礎上增加線條細化效果，讓畫面看起來更精緻。';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesZhTw implements TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'CNN放大 (超快)';
	@override String get upscale_deblur_fast => '放大 & 去模糊 (快速)';
	@override String get restore_s_only => '修復 (超快)';
	@override String get denoise_bilateral_fast => '雙邊降噪 (極快)';
	@override String get upscale_non_cnn => '非CNN放大 (極快)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 線條加深';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 線條細化';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesZhTw implements TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => '媒體播放器';
	@override String get mediaServer => '媒體伺服器';
	@override String get internetGatewayDevice => '路由器';
	@override String get basicDevice => '基礎設備';
	@override String get dimmableLight => '智能燈';
	@override String get wlanAccessPoint => '無線接入點';
	@override String get wlanConnectionDevice => '無線連接設備';
	@override String get printer => '打印機';
	@override String get scanner => '掃描儀';
	@override String get digitalSecurityCamera => '攝像頭';
	@override String get unknownDevice => '未知設備';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetZhTw implements TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetZhTw._(this._root);

	final TranslationsZhTw _root; // ignore: unused_field

	// Translations
	@override String get title => '遠程投屏';
	@override String get close => '關閉';
	@override String get searchingDevices => '正在搜索設備...';
	@override String get searchPrompt => '點擊搜索按鈕重新搜索投屏設備';
	@override String get searching => '搜索中';
	@override String get searchAgain => '重新搜索';
	@override String get noDevicesFound => '未發現投屏設備\n請確保設備在同一網絡下';
	@override String get searchingDevicesPrompt => '正在搜索設備，請稍候...';
	@override String get cast => '投屏';
	@override String connectedTo({required Object deviceName}) => '已連接到: ${deviceName}';
	@override String get notConnected => '未連接設備';
	@override String get stopCasting => '停止投屏';
}

/// The flat map containing all translations for locale <zh-TW>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhTw {
	dynamic _flatMapFunction(String path) {
		return _flatMapFunction$0(path)
			?? _flatMapFunction$1(path)
			?? _flatMapFunction$2(path)
			?? _flatMapFunction$3(path);
	}

	dynamic _flatMapFunction$0(String path) {
		return switch (path) {
			'tutorial.specialFollowFeature' => '特別關注功能',
			'tutorial.specialFollowDescription' => '這裡顯示你特別關注的作者。在影片、圖庫、作者詳情頁點擊關注按鈕，然後選擇"添加為特別關注"即可。',
			'tutorial.exampleAuthorInfoRow' => '示例：作者信息行',
			'tutorial.authorName' => '作者名稱',
			'tutorial.followed' => '已關注',
			'tutorial.specialFollowInstruction' => '點擊"已關注"按鈕 → 選擇"添加為特別關注"',
			'tutorial.followButtonLocations' => '關注按鈕位置：',
			'tutorial.videoDetailPage' => '影片詳情頁',
			'tutorial.galleryDetailPage' => '圖庫詳情頁',
			'tutorial.authorDetailPage' => '作者詳情頁',
			'tutorial.afterSpecialFollow' => '特別關注後，可在此快速查看作者最新內容！',
			'tutorial.specialFollowManagementTip' => '特別關注列表可在側邊抽屜欄-關注列表-特別關注列表頁面裡管理',
			'tutorial.skip' => '跳過',
			'common.appName' => 'Love Iwara',
			'common.ok' => '確定',
			'common.cancel' => '取消',
			'common.save' => '儲存',
			'common.delete' => '刪除',
			'common.visit' => '訪問',
			'common.loading' => '載入中...',
			'common.scrollToTop' => '滾動到頂部',
			'common.privacyHint' => '隱私內容，不與展示',
			'common.latest' => '最新',
			'common.likesCount' => '按讚數',
			'common.viewsCount' => '觀看次數',
			'common.popular' => '受歡迎的',
			'common.trending' => '趨勢',
			'common.commentList' => '評論列表',
			'common.sendComment' => '發表評論',
			'common.send' => '發表',
			'common.retry' => '重試',
			'common.premium' => '高級會員',
			'common.follower' => '粉絲',
			'common.friend' => '朋友',
			'common.video' => '影片',
			'common.following' => '追蹤中',
			'common.expand' => '展開',
			'common.collapse' => '收起',
			'common.cancelFriendRequest' => '取消申請',
			'common.cancelSpecialFollow' => '取消特別關注',
			'common.addFriend' => '加為朋友',
			'common.removeFriend' => '解除朋友',
			'common.followed' => '已追蹤',
			'common.follow' => '追蹤',
			'common.unfollow' => '取消追蹤',
			'common.specialFollow' => '特別關注',
			'common.specialFollowed' => '已特別關注',
			'common.gallery' => '圖庫',
			'common.playlist' => '播放清單',
			'common.commentPostedSuccessfully' => '評論發表成功',
			'common.commentPostedFailed' => '評論發表失敗',
			'common.success' => '成功',
			'common.commentDeletedSuccessfully' => '評論已刪除',
			'common.commentUpdatedSuccessfully' => '評論已更新',
			'common.totalComments' => ({required Object count}) => '評論 ${count} 則',
			'common.writeYourCommentHere' => '請寫下你的評論...',
			'common.tmpNoReplies' => '暫無回覆',
			'common.loadMore' => '載入更多',
			'common.noMoreDatas' => '沒有更多資料了',
			'common.selectTranslationLanguage' => '選擇翻譯語言',
			'common.translate' => '翻譯',
			'common.translateFailedPleaseTryAgainLater' => '翻譯失敗，請稍後再試',
			'common.translationResult' => '翻譯結果',
			'common.justNow' => '剛剛',
			'common.minutesAgo' => ({required Object num}) => '${num} 分鐘前',
			'common.hoursAgo' => ({required Object num}) => '${num} 小時前',
			'common.daysAgo' => ({required Object num}) => '${num} 天前',
			'common.editedAt' => ({required Object num}) => '${num} 編輯',
			'common.editComment' => '編輯評論',
			'common.commentUpdated' => '評論已更新',
			'common.replyComment' => '回覆評論',
			'common.reply' => '回覆',
			'common.edit' => '編輯',
			'common.unknownUser' => '未知使用者',
			'common.me' => '我',
			'common.author' => '作者',
			'common.admin' => '管理員',
			'common.viewReplies' => ({required Object num}) => '查看回覆 (${num})',
			'common.hideReplies' => '隱藏回覆',
			'common.confirmDelete' => '確認刪除',
			'common.areYouSureYouWantToDeleteThisItem' => '確定要刪除這筆資料嗎？',
			'common.tmpNoComments' => '暫無評論',
			'common.refresh' => '更新',
			'common.back' => '返回',
			'common.tips' => '提示',
			'common.linkIsEmpty' => '連結地址為空',
			'common.linkCopiedToClipboard' => '連結地址已複製到剪貼簿',
			'common.imageCopiedToClipboard' => '圖片已複製到剪貼簿',
			'common.copyImageFailed' => '複製圖片失敗',
			'common.mobileSaveImageIsUnderDevelopment' => '移動端的儲存圖片功能尚在開發中',
			'common.imageSavedTo' => '圖片已儲存至',
			'common.saveImageFailed' => '儲存圖片失敗',
			'common.close' => '關閉',
			'common.more' => '更多',
			'common.moreFeaturesToBeDeveloped' => '更多功能待開發',
			'common.all' => '全部',
			'common.selectedRecords' => ({required Object num}) => '已選擇 ${num} 筆資料',
			'common.cancelSelectAll' => '取消全選',
			'common.selectAll' => '全選',
			'common.exitEditMode' => '退出編輯模式',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '確定要刪除選中的 ${num} 筆資料嗎？',
			'common.searchHistoryRecords' => '搜尋歷史紀錄...',
			'common.settings' => '設定',
			'common.subscriptions' => '訂閱',
			'common.videoCount' => ({required Object num}) => '${num} 支影片',
			'common.share' => '分享',
			'common.areYouSureYouWantToShareThisPlaylist' => '要分享這個播放清單嗎？',
			'common.editTitle' => '編輯標題',
			'common.editMode' => '編輯模式',
			'common.pleaseEnterNewTitle' => '請輸入新標題',
			'common.createPlayList' => '創建播放清單',
			'common.create' => '創建',
			'common.checkNetworkSettings' => '檢查網路設定',
			'common.general' => '大眾',
			'common.r18' => 'R18',
			'common.sensitive' => '敏感',
			'common.year' => '年份',
			'common.month' => '月份',
			'common.tag' => '標籤',
			'common.private' => '私密',
			'common.noTitle' => '無標題',
			'common.search' => '搜尋',
			'common.noContent' => '沒有內容哦',
			'common.recording' => '記錄中',
			'common.paused' => '已暫停',
			'common.clear' => '清除',
			'common.user' => '使用者',
			'common.post' => '投稿',
			'common.seconds' => '秒',
			'common.comingSoon' => '敬請期待',
			'common.confirm' => '確認',
			'common.hour' => '小時',
			'common.minute' => '分鐘',
			'common.clickToRefresh' => '點擊更新',
			'common.history' => '歷史紀錄',
			'common.favorites' => '最愛',
			'common.friends' => '朋友',
			'common.playList' => '播放清單',
			'common.checkLicense' => '查看授權',
			'common.logout' => '登出',
			'common.fensi' => '粉絲',
			'common.accept' => '接受',
			'common.reject' => '拒絕',
			'common.clearAllHistory' => '清空所有歷史紀錄',
			'common.clearAllHistoryConfirm' => '確定要清空所有歷史紀錄嗎？',
			'common.followingList' => '追蹤中列表',
			'common.followersList' => '粉絲列表',
			'common.follows' => '追蹤',
			'common.fans' => '粉絲',
			'common.followsAndFans' => '追蹤與粉絲',
			'common.numViews' => '觀看次數',
			'common.updatedAt' => '更新時間',
			'common.publishedAt' => '發布時間',
			'common.download' => '下載',
			'common.selectQuality' => '選擇畫質',
			'common.externalVideo' => '站外影片',
			'common.originalText' => '原文',
			'common.showOriginalText' => '顯示原始文本',
			'common.showProcessedText' => '顯示處理後文本',
			'common.preview' => '預覽',
			'common.rules' => '規則',
			'common.agree' => '同意',
			'common.disagree' => '不同意',
			'common.agreeToRules' => '同意規則',
			'common.markdownSyntaxHelp' => 'Markdown語法幫助',
			'common.previewContent' => '預覽內容',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => '超過最大長度限制 (${max})',
			'common.agreeToCommunityRules' => '同意社群規則',
			'common.createPost' => '創建投稿',
			'common.title' => '標題',
			'common.enterTitle' => '請輸入標題',
			'common.content' => '內容',
			'common.enterContent' => '請輸入內容',
			'common.writeYourContentHere' => '請輸入內容...',
			'common.tagBlacklist' => '黑名單標籤',
			'common.noData' => '沒有資料',
			'common.tagLimit' => '標籤上限',
			'common.enableFloatingButtons' => '啟用浮動按鈕',
			'common.disableFloatingButtons' => '禁用浮動按鈕',
			'common.enabledFloatingButtons' => '已啟用浮動按鈕',
			'common.disabledFloatingButtons' => '已禁用浮動按鈕',
			'common.pendingCommentCount' => '待審核評論',
			'common.joined' => ({required Object str}) => '加入於 ${str}',
			'common.selectDateRange' => '選擇日期範圍',
			'common.selectDateRangeHint' => '選擇日期範圍，默認選擇最近30天',
			'common.clearDateRange' => '清除日期範圍',
			'common.followSuccessClickAgainToSpecialFollow' => '已成功關注，再次點擊以特別關注',
			'common.exitConfirmTip' => '確定要退出嗎？',
			'common.error' => '錯誤',
			'common.taskRunning' => '任務正在進行中，請稍後再試。',
			'common.operationCancelled' => '操作已取消。',
			'common.unsavedChanges' => '您有未儲存的更改',
			'common.specialFollowsManagementTip' => '拖動可重新排序 • 向左滑動可移除',
			'common.specialFollowsManagement' => '特別關注管理',
			'common.createTimeDesc' => '創建時間倒序',
			'common.createTimeAsc' => '創建時間正序',
			'common.pagination.totalItems' => ({required Object num}) => '共 ${num} 項',
			'common.pagination.jumpToPage' => '跳轉到指定頁面',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => '請輸入頁碼 (1-${max})',
			'common.pagination.pageNumber' => '頁碼',
			'common.pagination.jump' => '跳轉',
			'common.pagination.invalidPageNumber' => ({required Object max}) => '請輸入有效頁碼 (1-${max})',
			'common.pagination.invalidInput' => '請輸入有效頁碼',
			'common.pagination.waterfall' => '瀑布流',
			'common.pagination.pagination' => '分頁',
			'common.notice' => '通知',
			'common.detail' => '詳情',
			'common.parseExceptionDestopHint' => ' - 桌面端用戶可以在設置中配置代理',
			'common.iwaraTags' => 'Iwara 標籤',
			'common.likeThisVideo' => '喜歡這個影片的人',
			'common.operation' => '操作',
			'common.replies' => '回覆',
			'auth.login' => '登入',
			'auth.logout' => '登出',
			'auth.email' => '電子郵件',
			'auth.password' => '密碼',
			'auth.loginOrRegister' => '登入 / 註冊',
			'auth.register' => '註冊',
			'auth.pleaseEnterEmail' => '請輸入電子郵件',
			'auth.pleaseEnterPassword' => '請輸入密碼',
			'auth.passwordMustBeAtLeast6Characters' => '密碼至少需要 6 位',
			'auth.pleaseEnterCaptcha' => '請輸入驗證碼',
			'auth.captcha' => '驗證碼',
			'auth.refreshCaptcha' => '更新驗證碼',
			'auth.captchaNotLoaded' => '無法載入驗證碼',
			'auth.loginSuccess' => '登入成功',
			'auth.emailVerificationSent' => '已發送郵件驗證指令',
			'auth.notLoggedIn' => '尚未登入',
			'auth.clickToLogin' => '點擊此處登入',
			'auth.logoutConfirmation' => '你確定要登出嗎？',
			'auth.logoutSuccess' => '登出成功',
			'auth.logoutFailed' => '登出失敗',
			'auth.usernameOrEmail' => '用戶名或電子郵件',
			'auth.pleaseEnterUsernameOrEmail' => '請輸入用戶名或電子郵件',
			'auth.rememberMe' => '記住帳號密碼',
			'errors.error' => '錯誤',
			'errors.required' => '此項為必填',
			'errors.invalidEmail' => '電子郵件格式錯誤',
			'errors.networkError' => '網路錯誤，請重試',
			'errors.errorWhileFetching' => '取得資料失敗',
			'errors.commentCanNotBeEmpty' => '評論內容不能為空',
			'errors.errorWhileFetchingReplies' => '取得回覆時出錯，請檢查網路連線',
			'errors.canNotFindCommentController' => '無法找到評論控制器',
			'errors.errorWhileLoadingGallery' => '載入圖庫時出錯',
			'errors.howCouldThereBeNoDataItCantBePossible' => '啊？怎麼會沒有資料呢？出錯了吧 :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => '不支援的圖片格式: ${str}',
			'errors.invalidGalleryId' => '無效的圖庫ID',
			'errors.translationFailedPleaseTryAgainLater' => '翻譯失敗，請稍後再試',
			'errors.errorOccurred' => '發生錯誤，請稍後再試。',
			'errors.errorOccurredWhileProcessingRequest' => '處理請求時出錯',
			'errors.errorWhileFetchingDatas' => '取得資料時出錯，請稍後再試',
			'errors.serviceNotInitialized' => '服務未初始化',
			'errors.unknownType' => '未知類型',
			'errors.errorWhileOpeningLink' => ({required Object link}) => '無法開啟連結: ${link}',
			'errors.invalidUrl' => '無效的URL',
			'errors.failedToOperate' => '操作失敗',
			'errors.permissionDenied' => '權限不足',
			'errors.youDoNotHavePermissionToAccessThisResource' => '您沒有權限訪問此資源',
			'errors.loginFailed' => '登入失敗',
			'errors.unknownError' => '未知錯誤',
			'errors.sessionExpired' => '會話已過期',
			'errors.failedToFetchCaptcha' => '獲取驗證碼失敗',
			'errors.emailAlreadyExists' => '電子郵件已存在',
			'errors.invalidCaptcha' => '無效的驗證碼',
			'errors.registerFailed' => '註冊失敗',
			'errors.failedToFetchComments' => '獲取評論失敗',
			'errors.failedToFetchImageDetail' => '獲取圖庫詳情失敗',
			'errors.failedToFetchImageList' => '獲取圖庫列表失敗',
			'errors.failedToFetchData' => '獲取資料失敗',
			'errors.invalidParameter' => '無效的參數',
			'errors.pleaseLoginFirst' => '請先登入',
			'errors.errorWhileLoadingPost' => '載入投稿內容時出錯',
			'errors.errorWhileLoadingPostDetail' => '載入投稿詳情時出錯',
			'errors.invalidPostId' => '無效的投稿ID',
			'errors.forceUpdateNotPermittedToGoBack' => '目前處於強制更新狀態，無法返回',
			'errors.pleaseLoginAgain' => '請重新登入',
			'errors.invalidLogin' => '登入失敗，請檢查電子郵件和密碼',
			'errors.tooManyRequests' => '請求過多，請稍後再試',
			'errors.exceedsMaxLength' => ({required Object max}) => '超出最大長度: ${max}',
			'errors.contentCanNotBeEmpty' => '內容不能為空',
			'errors.titleCanNotBeEmpty' => '標題不能為空',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => '請求過多，請稍後再試，剩餘時間',
			'errors.remainingHours' => ({required Object num}) => '${num}小時',
			'errors.remainingMinutes' => ({required Object num}) => '${num}分',
			'errors.remainingSeconds' => ({required Object num}) => '${num}秒',
			'errors.tagLimitExceeded' => ({required Object limit}) => '標籤上限超出，上限: ${limit}',
			'errors.failedToRefresh' => '更新失敗',
			'errors.noPermission' => '權限不足',
			'errors.resourceNotFound' => '資源不存在',
			'errors.failedToSaveCredentials' => '無法安全保存登入資訊',
			'errors.failedToLoadSavedCredentials' => '載入保存的登入資訊失敗',
			'errors.specialFollowLimitReached' => ({required Object cnt}) => '特別關注上限超出，上限: ${cnt}，請於關注列表頁中調整',
			'errors.notFound' => '內容不存在或已被刪除',
			'errors.network.basicPrefix' => '網路錯誤 - ',
			'errors.network.failedToConnectToServer' => '連接伺服器失敗',
			'errors.network.serverNotAvailable' => '伺服器不可用',
			'errors.network.requestTimeout' => '請求超時',
			'errors.network.unexpectedError' => '意外錯誤',
			'errors.network.invalidResponse' => '無效的回應',
			'errors.network.invalidRequest' => '無效的請求',
			'errors.network.invalidUrl' => '無效的URL',
			'errors.network.invalidMethod' => '無效的方法',
			'errors.network.invalidHeader' => '無效的頭部',
			'errors.network.invalidBody' => '無效的體',
			'errors.network.invalidStatusCode' => '無效的狀態碼',
			'errors.network.serverError' => '伺服器錯誤',
			'errors.network.requestCanceled' => '請求已取消',
			'errors.network.invalidPort' => '無効な埠口',
			'errors.network.proxyPortError' => '代理埠口設定異常',
			'errors.network.connectionRefused' => '連接被拒絕',
			'errors.network.networkUnreachable' => '網路不可達',
			'errors.network.noRouteToHost' => '無法找到主機',
			'errors.network.connectionFailed' => '連接失敗',
			'errors.network.sslConnectionFailed' => 'SSL連接失敗，請檢查網絡設置',
			'friends.clickToRestoreFriend' => '點擊恢復朋友',
			'friends.friendsList' => '朋友列表',
			'friends.friendRequests' => '朋友請求',
			'friends.friendRequestsList' => '朋友請求列表',
			'friends.removingFriend' => '正在解除好友關係...',
			'friends.failedToRemoveFriend' => '解除好友關係失敗',
			'friends.cancelingRequest' => '正在取消好友申請...',
			'friends.failedToCancelRequest' => '取消好友申請失敗',
			'authorProfile.noMoreDatas' => '沒有更多資料了',
			'authorProfile.userProfile' => '使用者資料',
			'favorites.clickToRestoreFavorite' => '點擊恢復最愛',
			'favorites.myFavorites' => '我的最愛',
			'galleryDetail.galleryDetail' => '圖庫詳情',
			'galleryDetail.viewGalleryDetail' => '查看圖庫詳情',
			'galleryDetail.copyLink' => '複製連結地址',
			'galleryDetail.copyImage' => '複製圖片',
			'galleryDetail.saveAs' => '另存為',
			'galleryDetail.saveToAlbum' => '儲存到相簿',
			'galleryDetail.publishedAt' => '發布時間',
			'galleryDetail.viewsCount' => '觀看次數',
			'galleryDetail.imageLibraryFunctionIntroduction' => '圖庫功能介紹',
			'galleryDetail.rightClickToSaveSingleImage' => '右鍵儲存單張圖片',
			'galleryDetail.batchSave' => '批次儲存',
			'galleryDetail.keyboardLeftAndRightToSwitch' => '鍵盤左右控制切換',
			'galleryDetail.keyboardUpAndDownToZoom' => '鍵盤上下控制縮放',
			'galleryDetail.mouseWheelToSwitch' => '滑鼠滾輪控制切換',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + 滑鼠滾輪控制縮放',
			'galleryDetail.moreFeaturesToBeDiscovered' => '更多功能待發掘...',
			'galleryDetail.authorOtherGalleries' => '作者的其他圖庫',
			'galleryDetail.relatedGalleries' => '相關圖庫',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => '點擊左右邊緣以切換圖片',
			'playList.myPlayList' => '我的播放清單',
			'playList.friendlyTips' => '友情提示',
			'playList.dearUser' => '親愛的使用者',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'iwara的播放清單系統目前還不太完善',
			'playList.notSupportSetCover' => '不支援設定封面',
			'playList.notSupportDeleteList' => '無法刪除播放清單',
			'playList.notSupportSetPrivate' => '無法設為私密',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => '沒錯...創建的播放清單會一直存在且對所有人可見',
			'playList.smallSuggestion' => '小建議',
			'playList.useLikeToCollectContent' => '如果您比較注重隱私，建議使用"按讚"功能來收藏內容',
			'playList.welcomeToDiscussOnGitHub' => '如果你有其他建議或想法，歡迎來 GitHub 討論！',
			'playList.iUnderstand' => '明白了',
			'playList.searchPlaylists' => '搜尋播放清單...',
			'playList.newPlaylistName' => '新播放清單名稱',
			'playList.createNewPlaylist' => '創建新播放清單',
			'playList.videos' => '影片',
			'search.googleSearchScope' => '搜尋範圍',
			'search.searchTags' => '搜尋標籤...',
			'search.contentRating' => '內容分級',
			'search.removeTag' => '移除標籤',
			'search.pleaseEnterSearchContent' => '請輸入搜尋內容',
			'search.searchHistory' => '搜尋歷史',
			'search.searchSuggestion' => '搜尋建議',
			'search.usedTimes' => '使用次數',
			'search.lastUsed' => '最後使用',
			'search.noSearchHistoryRecords' => '沒有搜尋歷史',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => '目前尚未支援此搜尋類型 ${searchType}，敬請期待',
			'search.searchResult' => '搜尋結果',
			'search.unsupportedSearchType' => ({required Object searchType}) => '不支援的搜尋類型: ${searchType}',
			'search.googleSearch' => '谷歌搜尋',
			'search.googleSearchHint' => ({required Object webName}) => '${webName} 的搜尋功能不好用？嘗試谷歌搜尋！',
			'search.googleSearchDescription' => '借助谷歌搜索的 :site 搜索運算符，您可以通過外部引擎來對站內的內容進行檢索，此功能在搜尋 影片、圖庫、播放清單、用戶 時非常有用。',
			'search.googleSearchKeywordsHint' => '輸入要搜尋的關鍵詞',
			'search.openLinkJump' => '打開連結跳轉',
			'search.googleSearchButton' => '谷歌搜尋',
			'search.pleaseEnterSearchKeywords' => '請輸入搜尋關鍵詞',
			'search.googleSearchQueryCopied' => '搜尋語句已複製到剪貼簿',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => '無法打開瀏覽器: ${error}',
			'mediaList.personalIntroduction' => '個人簡介',
			'settings.listViewMode' => '列表顯示模式',
			'settings.useTraditionalPaginationMode' => '使用傳統分頁模式',
			'settings.useTraditionalPaginationModeDesc' => '開啟後列表將使用傳統分頁模式，關閉則使用瀑布流模式',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => '顯示底部進度條',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => '此設定決定是否在工具欄隱藏時顯示底部進度條',
			'settings.basicSettings' => '基礎設定',
			'settings.personalizedSettings' => '個性化設定',
			'settings.otherSettings' => '其他設定',
			'settings.searchConfig' => '搜尋設定',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => '此設定將決定您之後播放影片時是否會沿用之前的設定。',
			'settings.playControl' => '播放控制',
			'settings.fastForwardTime' => '快進時間',
			'settings.fastForwardTimeMustBeAPositiveInteger' => '快進時間必須是正整數。',
			'settings.rewindTime' => '快退時間',
			'settings.rewindTimeMustBeAPositiveInteger' => '快退時間必須是正整數。',
			'settings.longPressPlaybackSpeed' => '長按播放倍速',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => '長按播放倍速必須是正數。',
			'settings.repeat' => '循環播放',
			'settings.renderVerticalVideoInVerticalScreen' => '全螢幕播放時以直向模式呈現直向影片',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => '此設定將決定當您在全螢幕播放時，是否以直向模式呈現直向影片。',
			'settings.rememberVolume' => '記住音量',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => '此設定將決定當您之後播放影片時，是否會保留先前的音量設定。',
			'settings.rememberBrightness' => '記住亮度',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => '此設定將決定當您之後播放影片時，是否會保留先前的亮度設定。',
			'settings.playControlArea' => '播放控制區域',
			'settings.leftAndRightControlAreaWidth' => '左右控制區域寬度',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => '此設定將決定播放器左右兩側控制區域的寬度。',
			'settings.proxyAddressCannotBeEmpty' => '代理伺服器地址不能為空。',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => '無效的代理伺服器地址格式，請使用 IP:端口 或 域名:端口 格式。',
			'settings.proxyNormalWork' => '代理伺服器正常工作。',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => '代理請求失敗，狀態碼: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => '代理請求出錯: ${exception}',
			'settings.proxyConfig' => '代理設定',
			'settings.thisIsHttpProxyAddress' => '此為 HTTP 代理伺服器地址',
			'settings.checkProxy' => '檢查代理',
			'settings.proxyAddress' => '代理地址',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => '請輸入代理伺服器的 URL，例如 127.0.0.1:8080',
			'settings.enableProxy' => '啟用代理',
			'settings.left' => '左側',
			'settings.middle' => '中間',
			'settings.right' => '右側',
			'settings.playerSettings' => '播放器設定',
			'settings.networkSettings' => '網路設定',
			'settings.customizeYourPlaybackExperience' => '自訂您的播放體驗',
			'settings.chooseYourFavoriteAppAppearance' => '選擇您喜愛的應用程式外觀',
			'settings.configureYourProxyServer' => '配置您的代理伺服器',
			'settings.settings' => '設定',
			'settings.themeSettings' => '主題設定',
			'settings.followSystem' => '跟隨系統',
			'settings.lightMode' => '淺色模式',
			'settings.darkMode' => '深色模式',
			'settings.presetTheme' => '預設主題',
			'settings.basicTheme' => '基礎主題',
			'settings.needRestartToApply' => '需要重啟應用以應用設定',
			'settings.themeNeedRestartDescription' => '主題設定需要重啟應用以應用設定',
			'settings.about' => '關於',
			'settings.currentVersion' => '當前版本',
			'settings.latestVersion' => '最新版本',
			'settings.checkForUpdates' => '檢查更新',
			'settings.update' => '更新',
			'settings.newVersionAvailable' => '發現新版本',
			'settings.projectHome' => '開源地址',
			'settings.release' => '版本發布',
			'settings.issueReport' => '問題回報',
			'settings.openSourceLicense' => '開源許可',
			'settings.checkForUpdatesFailed' => '檢查更新失敗，請稍後重試',
			'settings.autoCheckUpdate' => '自動檢查更新',
			'settings.updateContent' => '更新內容',
			'settings.releaseDate' => '發布日期',
			'settings.ignoreThisVersion' => '忽略此版本',
			'settings.minVersionUpdateRequired' => '當前版本過低，請盡快更新',
			'settings.forceUpdateTip' => '此版本為強制更新，請盡快更新到最新版本',
			'settings.viewChangelog' => '查看更新日誌',
			'settings.alreadyLatestVersion' => '已是最新版本',
			'settings.appSettings' => '應用設定',
			'settings.configureYourAppSettings' => '配置您的應用程式設定',
			'settings.history' => '歷史記錄',
			'settings.autoRecordHistory' => '自動記錄歷史記錄',
			'settings.autoRecordHistoryDesc' => '自動記錄您觀看過的影片和圖庫等信息',
			'settings.showUnprocessedMarkdownText' => '顯示未處理文本',
			'settings.showUnprocessedMarkdownTextDesc' => '顯示Markdown的原始文本',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => '隱私模式',
			'settings.activeBackgroundPrivacyModeDesc' => '禁止截圖、後台運行時隱藏畫面...',
			'settings.privacy' => '隱私',
			'settings.forum' => '論壇',
			'settings.disableForumReplyQuote' => '禁用論壇回覆引用',
			'settings.disableForumReplyQuoteDesc' => '禁用論壇回覆時攜帶被回覆樓層資訊',
			'settings.theaterMode' => '劇院模式',
			'settings.theaterModeDesc' => '開啟後，播放器背景會被設置為影片封面的模糊版本',
			'settings.appLinks' => '應用鏈接',
			'settings.defaultBrowser' => '預設瀏覽',
			'settings.defaultBrowserDesc' => '請在系統設定中打開預設鏈接配置項，並添加iwara.tv網站鏈接',
			'settings.themeMode' => '主題模式',
			'settings.themeModeDesc' => '此配置決定應用的主題模式',
			'settings.dynamicColor' => '動態顏色',
			'settings.dynamicColorDesc' => '此配置決定應用是否使用動態顏色',
			'settings.useDynamicColor' => '使用動態顏色',
			'settings.useDynamicColorDesc' => '此配置決定應用是否使用動態顏色',
			'settings.presetColors' => '預設顏色',
			'settings.customColors' => '自定義顏色',
			'settings.pickColor' => '選擇顏色',
			'settings.cancel' => '取消',
			'settings.confirm' => '確認',
			'settings.noCustomColors' => '沒有自定義顏色',
			'settings.recordAndRestorePlaybackProgress' => '記錄和恢復播放進度',
			'settings.signature' => '小尾巴',
			'settings.enableSignature' => '小尾巴啟用',
			'settings.enableSignatureDesc' => '此配置決定回覆時是否自動添加小尾巴',
			'settings.enterSignature' => '輸入小尾巴',
			'settings.editSignature' => '編輯小尾巴',
			'settings.signatureContent' => '小尾巴內容',
			'settings.exportConfig' => '匯出應用配置',
			'settings.exportConfigDesc' => '將應用配置匯出為文件（不包含下載記錄）',
			'settings.importConfig' => '匯入應用配置',
			'settings.importConfigDesc' => '從文件匯入應用配置',
			'settings.exportConfigSuccess' => '配置匯出成功！',
			'settings.exportConfigFailed' => '配置匯出失敗',
			'settings.importConfigSuccess' => '配置匯入成功！',
			'settings.importConfigFailed' => '配置匯入失敗',
			'settings.historyUpdateLogs' => '歷代更新日誌',
			'settings.noUpdateLogs' => '未獲取到更新日誌',
			'settings.versionLabel' => '版本: {version}',
			'settings.releaseDateLabel' => '發布日期: {date}',
			'settings.noChanges' => '暫無更新內容',
			'settings.interaction' => '互動',
			'settings.enableVibration' => '啟用震動',
			_ => null,
		};
	}

	dynamic _flatMapFunction$1(String path) {
		return switch (path) {
			'settings.enableVibrationDesc' => '啟用應用互動時的震動反饋',
			'settings.defaultKeepVideoToolbarVisible' => '保持工具列常駐',
			'settings.defaultKeepVideoToolbarVisibleDesc' => '此設定決定首次進入影片頁面時是否保持工具列常駐顯示。',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => '移動端開啟劇院模式可能會造成性能問題，可酌情開啟。',
			'settings.lockButtonPosition' => '鎖定按鈕位置',
			'settings.lockButtonPositionBothSides' => '兩側顯示',
			'settings.lockButtonPositionLeftSide' => '僅左側顯示',
			'settings.lockButtonPositionRightSide' => '僅右側顯示',
			'settings.fullscreenOrientation' => '豎屏進入全屏後的螢幕方向',
			'settings.fullscreenOrientationDesc' => '此設定決定豎屏進入全屏時螢幕的預設方向（僅移動端有效）',
			'settings.fullscreenOrientationLeftLandscape' => '左側橫螢幕',
			'settings.fullscreenOrientationRightLandscape' => '右側橫螢幕',
			'settings.jumpLink' => '跳轉連結',
			'settings.language' => '語言',
			'settings.languageChanged' => '語言設定已更改，請重新啟動應用以生效。',
			'settings.gestureControl' => '手勢控制',
			'settings.leftDoubleTapRewind' => '左側雙擊後退',
			'settings.rightDoubleTapFastForward' => '右側雙擊快進',
			'settings.doubleTapPause' => '雙擊暫停',
			'settings.rightVerticalSwipeVolume' => '右側上下滑動調整音量（進入新頁面時生效）',
			'settings.leftVerticalSwipeBrightness' => '左側上下滑動調整亮度（進入新頁面時生效）',
			'settings.longPressFastForward' => '長按快進',
			'settings.enableMouseHoverShowToolbar' => '鼠標懸停時顯示工具欄',
			'settings.enableMouseHoverShowToolbarInfo' => '開啟後，當鼠標懸停在播放器上移動時會自動顯示工具欄，停止移動3秒後自動隱藏',
			'settings.enableHorizontalDragSeek' => '橫向滑動調整進度',
			'settings.audioVideoConfig' => '音視頻配置',
			'settings.expandBuffer' => '擴大緩衝區',
			'settings.expandBufferInfo' => '開啟後緩衝區增大，載入時間變長但播放更流暢',
			'settings.videoSyncMode' => '視頻同步模式',
			'settings.videoSyncModeSubtitle' => '音視頻同步策略',
			'settings.hardwareDecodingMode' => '硬解模式',
			'settings.hardwareDecodingModeSubtitle' => '硬體解碼設定',
			'settings.enableHardwareAcceleration' => '啟用硬體加速',
			'settings.enableHardwareAccelerationInfo' => '開啟硬體加速可以提高解碼效能，但某些裝置可能不相容',
			'settings.useOpenSLESAudioOutput' => '使用OpenSLES音頻輸出',
			'settings.useOpenSLESAudioOutputInfo' => '使用低延遲音頻輸出，可能提高音頻效能',
			'settings.videoSyncAudio' => '音頻同步',
			'settings.videoSyncDisplayResample' => '顯示重採樣',
			'settings.videoSyncDisplayResampleVdrop' => '顯示重採樣(丟幀)',
			'settings.videoSyncDisplayResampleDesync' => '顯示重採樣(去同步)',
			'settings.videoSyncDisplayTempo' => '顯示節拍',
			'settings.videoSyncDisplayVdrop' => '顯示丟視頻幀',
			'settings.videoSyncDisplayAdrop' => '顯示丟音頻幀',
			'settings.videoSyncDisplayDesync' => '顯示去同步',
			'settings.videoSyncDesync' => '去同步',
			'settings.forumSettings.name' => '論壇',
			'settings.forumSettings.configureYourForumSettings' => '配置您的論壇設定',
			'settings.chatSettings.name' => '聊天',
			'settings.chatSettings.configureYourChatSettings' => '配置您的聊天設定',
			'settings.hardwareDecodingAuto' => '自動',
			'settings.hardwareDecodingAutoCopy' => '自動複製',
			'settings.hardwareDecodingAutoSafe' => '自動安全',
			'settings.hardwareDecodingNo' => '禁用',
			'settings.hardwareDecodingYes' => '強制啟用',
			'settings.downloadSettings.downloadSettings' => '下載設定',
			'settings.downloadSettings.storagePermissionStatus' => '存儲權限狀態',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => '訪問公共目錄需要存儲權限',
			'settings.downloadSettings.checkingPermissionStatus' => '檢查權限狀態...',
			'settings.downloadSettings.storagePermissionGranted' => '已授權存儲權限',
			'settings.downloadSettings.storagePermissionNotGranted' => '需要存儲權限',
			'settings.downloadSettings.storagePermissionGrantSuccess' => '存儲權限授權成功',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => '存儲權限授權失敗，部分功能可能受限',
			'settings.downloadSettings.grantStoragePermission' => '授權存儲權限',
			'settings.downloadSettings.customDownloadPath' => '自定義下載位置',
			'settings.downloadSettings.customDownloadPathDescription' => '啟用後可以為下載的檔案選擇自定義儲存位置',
			'settings.downloadSettings.customDownloadPathTip' => '💡 提示：選擇公共目錄（如下載資料夾）需要授予儲存權限，建議優先使用推薦路徑',
			'settings.downloadSettings.androidWarning' => 'Android提示：避免選擇公共目錄（如下載資料夾），建議使用應用程式專用目錄以確保存取權限。',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ 注意：您選擇的是公共目錄，需要儲存權限才能正常下載檔案',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => '選擇公共目錄需要儲存權限',
			'settings.downloadSettings.currentDownloadPath' => '目前下載路徑',
			'settings.downloadSettings.actualDownloadPath' => '實際下載路徑',
			'settings.downloadSettings.defaultAppDirectory' => '預設應用程式目錄',
			'settings.downloadSettings.permissionGranted' => '已授權',
			'settings.downloadSettings.permissionRequired' => '需要權限',
			'settings.downloadSettings.enableCustomDownloadPath' => '啟用自定義下載路徑',
			'settings.downloadSettings.disableCustomDownloadPath' => '關閉時使用應用程式預設路徑',
			'settings.downloadSettings.customDownloadPathLabel' => '自定義下載路徑',
			'settings.downloadSettings.selectDownloadFolder' => '選擇下載資料夾',
			'settings.downloadSettings.recommendedPath' => '推薦路徑',
			'settings.downloadSettings.selectFolder' => '選擇資料夾',
			'settings.downloadSettings.filenameTemplate' => '檔案命名範本',
			'settings.downloadSettings.filenameTemplateDescription' => '自定義下載檔案的命名規則，支援變數替換',
			'settings.downloadSettings.videoFilenameTemplate' => '影片檔案命名範本',
			'settings.downloadSettings.galleryFolderTemplate' => '圖庫資料夾範本',
			'settings.downloadSettings.imageFilenameTemplate' => '單張圖片命名範本',
			'settings.downloadSettings.resetToDefault' => '重設為預設值',
			'settings.downloadSettings.supportedVariables' => '支援的變數',
			'settings.downloadSettings.supportedVariablesDescription' => '在檔案命名範本中可以使用以下變數：',
			'settings.downloadSettings.copyVariable' => '複製變數',
			'settings.downloadSettings.variableCopied' => '變數已複製',
			'settings.downloadSettings.warningPublicDirectory' => '警告：選擇的是公共目錄，可能無法存取。建議選擇應用程式專用目錄。',
			'settings.downloadSettings.downloadPathUpdated' => '下載路徑已更新',
			'settings.downloadSettings.selectPathFailed' => '選擇路徑失敗',
			'settings.downloadSettings.recommendedPathSet' => '已設定為推薦路徑',
			'settings.downloadSettings.setRecommendedPathFailed' => '設定推薦路徑失敗',
			'settings.downloadSettings.templateResetToDefault' => '已重設為預設範本',
			'settings.downloadSettings.functionalTest' => '功能測試',
			'settings.downloadSettings.testInProgress' => '測試中...',
			'settings.downloadSettings.runTest' => '執行測試',
			'settings.downloadSettings.testDownloadPathAndPermissions' => '測試下載路徑和權限配置是否正常運作',
			'settings.downloadSettings.testResults' => '測試結果',
			'settings.downloadSettings.testCompleted' => '測試完成',
			'settings.downloadSettings.testPassed' => '項通過',
			'settings.downloadSettings.testFailed' => '測試失敗',
			'settings.downloadSettings.testStoragePermissionCheck' => '存儲權限檢查',
			'settings.downloadSettings.testStoragePermissionGranted' => '已獲得存儲權限',
			'settings.downloadSettings.testStoragePermissionMissing' => '缺少存儲權限，部分功能可能受限',
			'settings.downloadSettings.testPermissionCheckFailed' => '權限檢查失敗',
			'settings.downloadSettings.testDownloadPathValidation' => '下載路徑驗證',
			'settings.downloadSettings.testPathValidationFailed' => '路徑驗證失敗',
			'settings.downloadSettings.testFilenameTemplateValidation' => '檔案命名範本驗證',
			'settings.downloadSettings.testAllTemplatesValid' => '所有範本都有效',
			'settings.downloadSettings.testSomeTemplatesInvalid' => '部分範本包含無效字元',
			'settings.downloadSettings.testTemplateValidationFailed' => '範本驗證失敗',
			'settings.downloadSettings.testDirectoryOperationTest' => '目錄操作測試',
			'settings.downloadSettings.testDirectoryOperationNormal' => '目錄建立和檔案寫入正常',
			'settings.downloadSettings.testDirectoryOperationFailed' => '目錄操作失敗',
			'settings.downloadSettings.testVideoTemplate' => '視頻模板',
			'settings.downloadSettings.testGalleryTemplate' => '圖庫模板',
			'settings.downloadSettings.testImageTemplate' => '圖片模板',
			'settings.downloadSettings.testValid' => '有效',
			'settings.downloadSettings.testInvalid' => '無效',
			'settings.downloadSettings.testSuccess' => '成功',
			'settings.downloadSettings.testCorrect' => '正確',
			'settings.downloadSettings.testError' => '錯誤',
			'settings.downloadSettings.testPath' => '測試路徑',
			'settings.downloadSettings.testBasePath' => '基礎路徑',
			'settings.downloadSettings.testDirectoryCreation' => '目錄創建',
			'settings.downloadSettings.testFileWriting' => '檔案寫入',
			'settings.downloadSettings.testFileContent' => '檔案內容',
			'settings.downloadSettings.checkingPathStatus' => '檢查路徑狀態...',
			'settings.downloadSettings.unableToGetPathStatus' => '無法獲取路徑狀態',
			'settings.downloadSettings.actualPathDifferentFromSelected' => '注意：實際使用路徑與選擇路徑不同',
			'settings.downloadSettings.grantPermission' => '授權權限',
			'settings.downloadSettings.fixIssue' => '修復問題',
			'settings.downloadSettings.issueFixed' => '問題已修復',
			'settings.downloadSettings.fixFailed' => '修復失敗，請手動處理',
			'settings.downloadSettings.lackStoragePermission' => '缺少存儲權限',
			'settings.downloadSettings.cannotAccessPublicDirectory' => '無法訪問公共目錄，需要「所有檔案存取權限」',
			'settings.downloadSettings.cannotCreateDirectory' => '無法建立目錄',
			'settings.downloadSettings.directoryNotWritable' => '目錄不可寫入',
			'settings.downloadSettings.insufficientSpace' => '可用空間不足',
			'settings.downloadSettings.pathValid' => '路徑有效',
			'settings.downloadSettings.validationFailed' => '驗證失敗',
			'settings.downloadSettings.usingDefaultAppDirectory' => '使用預設應用程式目錄',
			'settings.downloadSettings.appPrivateDirectory' => '應用程式專用目錄',
			'settings.downloadSettings.appPrivateDirectoryDesc' => '安全可靠，無需額外權限',
			'settings.downloadSettings.downloadDirectory' => '下載目錄',
			'settings.downloadSettings.downloadDirectoryDesc' => '系統預設下載位置，便於管理',
			'settings.downloadSettings.moviesDirectory' => '影片目錄',
			'settings.downloadSettings.moviesDirectoryDesc' => '系統影片目錄，媒體應用程式可識別',
			'settings.downloadSettings.documentsDirectory' => '文件目錄',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOS應用程式文件目錄',
			'settings.downloadSettings.requiresStoragePermission' => '需要存儲權限才能存取',
			'settings.downloadSettings.recommendedPaths' => '推薦路徑',
			'settings.downloadSettings.externalAppPrivateDirectory' => '外部應用程式專用目錄',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => '外部儲存應用程式專用目錄，使用者可存取，空間較大',
			'settings.downloadSettings.internalAppPrivateDirectory' => '內部應用程式專用目錄',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => '應用程式內部儲存，無需權限，空間較小',
			'settings.downloadSettings.appDocumentsDirectory' => '應用程式文件目錄',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => '應用程式專用文件目錄，安全可靠',
			'settings.downloadSettings.downloadsFolder' => '下載資料夾',
			'settings.downloadSettings.downloadsFolderDesc' => '系統預設下載目錄',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => '選擇一個推薦的下載位置',
			'settings.downloadSettings.noRecommendedPaths' => '暫無推薦路徑',
			'settings.downloadSettings.recommended' => '推薦',
			'settings.downloadSettings.requiresPermission' => '需要權限',
			'settings.downloadSettings.authorizeAndSelect' => '授權並選擇',
			'settings.downloadSettings.select' => '選擇',
			'settings.downloadSettings.permissionAuthorizationFailed' => '權限授權失敗，無法選擇此路徑',
			'settings.downloadSettings.pathValidationFailed' => '路徑驗證失敗',
			'settings.downloadSettings.downloadPathSetTo' => '下載路徑已設定為',
			'settings.downloadSettings.setPathFailed' => '設定路徑失敗',
			'settings.downloadSettings.variableTitle' => '標題',
			'settings.downloadSettings.variableAuthor' => '作者名稱',
			'settings.downloadSettings.variableUsername' => '作者使用者名稱',
			'settings.downloadSettings.variableQuality' => '影片品質',
			'settings.downloadSettings.variableFilename' => '原始檔案名稱',
			'settings.downloadSettings.variableId' => '內容ID',
			'settings.downloadSettings.variableCount' => '圖庫圖片數量',
			'settings.downloadSettings.variableDate' => '目前日期 (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => '目前時間 (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => '目前日期時間 (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => '下載設定',
			'settings.downloadSettings.downloadSettingsSubtitle' => '設定下載路徑和檔案命名規則',
			'settings.downloadSettings.suchAsTitleQuality' => '例如: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => '例如: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => '例如: %title_%filename',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => '標籤',
			'oreno3d.characters' => '角色',
			'oreno3d.origin' => '原作',
			'oreno3d.thirdPartyTagsExplanation' => '此處顯示的**標籤**、**角色**和**原作**資訊來自第三方站點 **Oreno3D**，僅供參考。\n\n由於此資訊來源只有日文，目前缺乏國際化適配。\n\n如果你有興趣參與國際化建設，歡迎訪問相關倉庫貢獻你的力量！',
			'oreno3d.sortTypes.hot' => '熱門',
			'oreno3d.sortTypes.favorites' => '高評價',
			'oreno3d.sortTypes.latest' => '最新',
			'oreno3d.sortTypes.popularity' => '人氣',
			'oreno3d.errors.requestFailed' => '請求失敗，狀態碼',
			'oreno3d.errors.connectionTimeout' => '連接超時，請檢查網路連接',
			'oreno3d.errors.sendTimeout' => '發送請求超時',
			'oreno3d.errors.receiveTimeout' => '接收響應超時',
			'oreno3d.errors.badCertificate' => '證書驗證失敗',
			'oreno3d.errors.resourceNotFound' => '請求的資源不存在',
			'oreno3d.errors.accessDenied' => '訪問被拒絕，可能需要驗證或權限',
			'oreno3d.errors.serverError' => '伺服器內部錯誤',
			'oreno3d.errors.serviceUnavailable' => '服務暫時不可用',
			'oreno3d.errors.requestCancelled' => '請求已取消',
			'oreno3d.errors.connectionError' => '網路連接錯誤，請檢查網路設置',
			'oreno3d.errors.networkRequestFailed' => '網路請求失敗',
			'oreno3d.errors.searchVideoError' => '搜索視頻時發生未知錯誤',
			'oreno3d.errors.getPopularVideoError' => '獲取熱門視頻時發生未知錯誤',
			'oreno3d.errors.getVideoDetailError' => '獲取視頻詳情時發生未知錯誤',
			'oreno3d.errors.parseVideoDetailError' => '獲取並解析視頻詳情時發生未知錯誤',
			'oreno3d.errors.downloadFileError' => '下載文件時發生未知錯誤',
			'oreno3d.loading.gettingVideoInfo' => '正在獲取視頻信息...',
			'oreno3d.loading.cancel' => '取消',
			'oreno3d.messages.videoNotFoundOrDeleted' => '視頻不存在或已被刪除',
			'oreno3d.messages.unableToGetVideoPlayLink' => '無法獲取視頻播放鏈接',
			'oreno3d.messages.getVideoDetailFailed' => '獲取視頻詳情失敗',
			'firstTimeSetup.welcome.title' => '歡迎使用',
			'firstTimeSetup.welcome.subtitle' => '讓我們開始您的個人化設定之旅',
			'firstTimeSetup.welcome.description' => '只需幾步，即可為您量身打造最佳使用體驗',
			'firstTimeSetup.basic.title' => '基礎設定',
			'firstTimeSetup.basic.subtitle' => '個人化您的使用體驗',
			'firstTimeSetup.basic.description' => '選擇適合您的功能偏好',
			'firstTimeSetup.network.title' => '網路設定',
			'firstTimeSetup.network.subtitle' => '配置網路連線選項',
			'firstTimeSetup.network.description' => '根據您的網路環境進行相應配置',
			'firstTimeSetup.network.tip' => '設定成功後需重啟應用才會生效',
			'firstTimeSetup.theme.title' => '主題設定',
			'firstTimeSetup.theme.subtitle' => '選擇您喜歡的介面主題',
			'firstTimeSetup.theme.description' => '個人化您的視覺體驗',
			'firstTimeSetup.player.title' => '播放器設定',
			'firstTimeSetup.player.subtitle' => '配置播放控制偏好',
			'firstTimeSetup.player.description' => '您可以在此快速設定常用的播放體驗',
			'firstTimeSetup.completion.title' => '完成設定',
			'firstTimeSetup.completion.subtitle' => '即將開始您的精彩旅程',
			'firstTimeSetup.completion.description' => '請閱讀並同意相關協議',
			'firstTimeSetup.completion.agreementTitle' => '使用者協議與社群規則',
			'firstTimeSetup.completion.agreementDesc' => '在使用本應用前，請您仔細閱讀並同意我們的使用者協議與社群規則。這些條款有助於維護良好的使用環境。',
			'firstTimeSetup.completion.checkboxTitle' => '我已閱讀並同意使用者協議與社群規則',
			'firstTimeSetup.completion.checkboxSubtitle' => '不同意將無法使用本應用',
			'firstTimeSetup.common.settingsChangeableTip' => '這些設定可在應用設定中隨時修改',
			'firstTimeSetup.common.agreeAgreementSnackbar' => '請先同意使用者協議與社群規則',
			'proxyHelper.systemProxyDetected' => '檢測到系統代理',
			'proxyHelper.copied' => '已複製',
			'proxyHelper.copy' => '複製',
			'signIn.pleaseLoginFirst' => '請先登入',
			'signIn.alreadySignedInToday' => '您今天已經簽到過了！',
			'signIn.youDidNotStickToTheSignIn' => '您未能持續簽到。',
			'signIn.signInSuccess' => '簽到成功！',
			'signIn.signInFailed' => '簽到失敗，請稍後再試',
			'signIn.consecutiveSignIns' => '連續簽到天數',
			'signIn.failureReason' => '未能持續簽到的原因',
			'signIn.selectDateRange' => '選擇日期範圍',
			'signIn.startDate' => '開始日期',
			'signIn.endDate' => '結束日期',
			'signIn.invalidDate' => '日期格式錯誤',
			'signIn.invalidDateRange' => '日期範圍無效',
			'signIn.errorFormatText' => '日期格式錯誤',
			'signIn.errorInvalidText' => '日期範圍無效',
			'signIn.errorInvalidRangeText' => '日期範圍無效',
			'signIn.dateRangeCantBeMoreThanOneYear' => '日期範圍不能超過1年',
			'signIn.signIn' => '簽到',
			'signIn.signInRecord' => '簽到紀錄',
			'signIn.totalSignIns' => '總簽到次數',
			'signIn.pleaseSelectSignInStatus' => '請選擇簽到狀態',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => '請登入以查看您的訂閱內容。',
			'subscriptions.selectUser' => '選擇用戶',
			'subscriptions.noSubscribedUsers' => '尚無已訂閱用戶',
			'subscriptions.showAllSubscribedUsersContent' => '顯示所有已訂閱用戶的內容',
			'videoDetail.pipMode' => '畫中畫模式',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => '從上次播放位置繼續播放: ${position}',
			'videoDetail.videoIdIsEmpty' => '影片ID為空',
			'videoDetail.videoInfoIsEmpty' => '影片資訊為空',
			'videoDetail.thisIsAPrivateVideo' => '這是私密影片',
			'videoDetail.getVideoInfoFailed' => '取得影片資訊失敗，請稍後再試',
			'videoDetail.noVideoSourceFound' => '未找到對應的影片來源',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => '標籤 "${tagId}" 已複製到剪貼簿',
			'videoDetail.errorLoadingVideo' => '載入影片時出錯',
			'videoDetail.play' => '播放',
			'videoDetail.pause' => '暫停',
			'videoDetail.exitAppFullscreen' => '退出應用全螢幕',
			'videoDetail.enterAppFullscreen' => '應用全螢幕',
			'videoDetail.exitSystemFullscreen' => '退出系統全螢幕',
			'videoDetail.enterSystemFullscreen' => '系統全螢幕',
			'videoDetail.seekTo' => '跳轉到指定時間',
			'videoDetail.switchResolution' => '切換解析度',
			'videoDetail.switchPlaybackSpeed' => '切換播放倍速',
			'videoDetail.rewindSeconds' => ({required Object num}) => '快退 ${num} 秒',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => '快進 ${num} 秒',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => '正在以 ${rate} 倍速播放',
			'videoDetail.brightness' => '亮度',
			'videoDetail.brightnessLowest' => '亮度已最低',
			'videoDetail.volume' => '音量',
			'videoDetail.volumeMuted' => '音量已靜音',
			'videoDetail.home' => '主頁',
			'videoDetail.videoPlayer' => '影片播放器',
			'videoDetail.videoPlayerInfo' => '播放器資訊',
			'videoDetail.moreSettings' => '更多設定',
			'videoDetail.videoPlayerFeatureInfo' => '播放器功能介紹',
			'videoDetail.autoRewind' => '自動重播',
			'videoDetail.rewindAndFastForward' => '左右雙擊快進或快退',
			'videoDetail.volumeAndBrightness' => '左右滑動調整音量、亮度',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => '中央區域雙擊暫停或播放',
			'videoDetail.showVerticalVideoInFullScreen' => '在全螢幕時顯示直向影片',
			'videoDetail.keepLastVolumeAndBrightness' => '保持最後調整的音量、亮度',
			'videoDetail.setProxy' => '設定代理',
			'videoDetail.moreFeaturesToBeDiscovered' => '更多功能待發掘...',
			'videoDetail.videoPlayerSettings' => '播放器設定',
			'videoDetail.commentCount' => ({required Object num}) => '評論 ${num} 則',
			'videoDetail.writeYourCommentHere' => '請寫下您的評論...',
			'videoDetail.authorOtherVideos' => '作者的其他影片',
			'videoDetail.relatedVideos' => '相關影片',
			'videoDetail.privateVideo' => '這是一個私密影片',
			'videoDetail.externalVideo' => '這是一個站外影片',
			'videoDetail.openInBrowser' => '在瀏覽器中打開',
			'videoDetail.resourceDeleted' => '這個影片貌似被刪除了 :/',
			'videoDetail.noDownloadUrl' => '沒有下載連結',
			'videoDetail.startDownloading' => '開始下載',
			'videoDetail.downloadFailed' => '下載失敗，請稍後再試',
			'videoDetail.downloadSuccess' => '下載成功',
			'videoDetail.download' => '下載',
			'videoDetail.downloadManager' => '下載管理',
			'videoDetail.videoLoadError' => '影片加載錯誤',
			'videoDetail.resourceNotFound' => '資源未找到',
			'videoDetail.authorNoOtherVideos' => '作者暫無其他影片',
			'videoDetail.noRelatedVideos' => '暫無相關影片',
			'videoDetail.player.errorWhileLoadingVideoSource' => '在加載影片來源時出現了錯誤',
			'videoDetail.player.errorWhileSettingUpListeners' => '在設置監聽器時出現了錯誤',
			'videoDetail.skeleton.fetchingVideoInfo' => '取得影片資訊中...',
			'videoDetail.skeleton.fetchingVideoSources' => '取得影片來源中...',
			'videoDetail.skeleton.loadingVideo' => '正在加載影片...',
			'videoDetail.skeleton.applyingSolution' => '正在應用此解析度...',
			'videoDetail.skeleton.addingListeners' => '正在添加監聽器...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => '成功獲取影片資源，開始加載影片...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => '加載完成',
			'videoDetail.cast.dlnaCast' => '投屏',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => '啟動投屏搜索失敗: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => '開始投屏到 ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => '投屏失敗: ${error}\n請嘗試重新搜索設備或切換網絡',
			'videoDetail.cast.castStopped' => '已停止投屏',
			'videoDetail.cast.deviceTypes.mediaRenderer' => '媒體播放器',
			'videoDetail.cast.deviceTypes.mediaServer' => '媒體伺服器',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => '路由器',
			'videoDetail.cast.deviceTypes.basicDevice' => '基礎設備',
			'videoDetail.cast.deviceTypes.dimmableLight' => '智能燈',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => '無線接入點',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => '無線連接設備',
			'videoDetail.cast.deviceTypes.printer' => '打印機',
			'videoDetail.cast.deviceTypes.scanner' => '掃描儀',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => '攝像頭',
			'videoDetail.cast.deviceTypes.unknownDevice' => '未知設備',
			'videoDetail.cast.currentPlatformNotSupported' => '當前平台不支援投屏功能',
			'videoDetail.cast.unableToGetVideoUrl' => '無法獲取影片地址，請稍後重試',
			'videoDetail.cast.stopCasting' => '停止投屏',
			'videoDetail.cast.dlnaCastSheet.title' => '遠程投屏',
			'videoDetail.cast.dlnaCastSheet.close' => '關閉',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => '正在搜索設備...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => '點擊搜索按鈕重新搜索投屏設備',
			'videoDetail.cast.dlnaCastSheet.searching' => '搜索中',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => '重新搜索',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => '未發現投屏設備\n請確保設備在同一網絡下',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => '正在搜索設備，請稍候...',
			'videoDetail.cast.dlnaCastSheet.cast' => '投屏',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => '已連接到: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => '未連接設備',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => '停止投屏',
			'videoDetail.likeAvatars.dialogTitle' => '誰悄悄地喜歡',
			'videoDetail.likeAvatars.dialogDescription' => '好奇他們是誰？來翻翻這本「按讚相簿」吧～',
			'videoDetail.likeAvatars.closeTooltip' => '關閉',
			'videoDetail.likeAvatars.retry' => '重試',
			'videoDetail.likeAvatars.noLikesYet' => '還沒有人出現在這裡，來當第一個吧！',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => '第 ${page} / ${totalPages} 頁 · 共 ${totalCount} 人',
			'videoDetail.likeAvatars.prevPage' => '上一頁',
			'videoDetail.likeAvatars.nextPage' => '下一頁',
			'share.sharePlayList' => '分享播放列表',
			'share.wowDidYouSeeThis' => '哇哦，你看过这个吗？',
			'share.nameIs' => '名字叫做',
			'share.clickLinkToView' => '點擊連結查看',
			'share.iReallyLikeThis' => '我真的是太喜歡這個了，你也來看看吧！',
			'share.shareFailed' => '分享失敗，請稍後再試',
			'share.share' => '分享',
			'share.shareAsImage' => '分享為圖片',
			'share.shareAsText' => '分享為文本',
			'share.shareAsImageDesc' => '將影片封面分享為圖片',
			'share.shareAsTextDesc' => '將影片詳情分享為文本',
			'share.shareAsImageFailed' => '分享影片封面為圖片失敗，請稍後再試',
			'share.shareAsTextFailed' => '分享影片詳情為文本失敗，請稍後再試',
			'share.shareVideo' => '分享影片',
			'share.authorIs' => '作者是',
			'share.shareGallery' => '分享圖庫',
			'share.galleryTitleIs' => '圖庫名字叫做',
			'share.galleryAuthorIs' => '圖庫作者是',
			'share.shareUser' => '分享用戶',
			'share.userNameIs' => '用戶名字叫做',
			'share.userAuthorIs' => '用戶作者是',
			'share.comments' => '評論',
			'share.shareThread' => '分享帖子',
			'share.views' => '瀏覽',
			'share.sharePost' => '分享投稿',
			'share.postTitleIs' => '投稿名字叫做',
			'share.postAuthorIs' => '投稿作者是',
			'markdown.markdownSyntax' => 'Markdown 語法',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara 專用語法',
			'markdown.internalLink' => '站內鏈接',
			'markdown.supportAutoConvertLinkBelow' => '支持自動轉換以下類型的鏈接：',
			'markdown.convertLinkExample' => '🎬 影片鏈接\n🖼️ 圖片鏈接\n👤 用戶鏈接\n📌 論壇鏈接\n🎵 播放列表鏈接\n💬 帖子鏈接',
			'markdown.mentionUser' => '提及用戶',
			'markdown.mentionUserDescription' => '輸入@後跟用戶名，將自動轉換為用戶鏈接',
			'markdown.markdownBasicSyntax' => 'Markdown 基本語法',
			'markdown.paragraphAndLineBreak' => '段落與換行',
			'markdown.paragraphAndLineBreakDescription' => '段落之間空一行，行末加兩個空格實現換行',
			'markdown.paragraphAndLineBreakSyntax' => '這是第一段文字\n\n這是第二段文字\n這一行後面加兩個空格  \n就能換行了',
			'markdown.textStyle' => '文本樣式',
			'markdown.textStyleDescription' => '使用特殊符號包圍文本来改變樣式',
			'markdown.textStyleSyntax' => '**粗體文本**\n*斜體文本*\n~~刪除線文本~~\n`代碼文本`',
			'markdown.quote' => '引用',
			'markdown.quoteDescription' => '使用 > 符號創建引用，多個 > 創建多級引用',
			'markdown.quoteSyntax' => '> 這是一級引用\n>> 這是二級引用',
			'markdown.list' => '列表',
			'markdown.listDescription' => '使用數字+點號創建有序列表，使用 - 創建無序列表',
			'markdown.listSyntax' => '1. 第一項\n2. 第二項\n\n- 無序項\n  - 子項\n  - 另一個子項',
			'markdown.linkAndImage' => '鏈接與圖片',
			'markdown.linkAndImageDescription' => '鏈接格式：[文字](URL)\n圖片格式：![描述](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[鏈接文字](${link})\n![圖片描述](${imgUrl})',
			'markdown.title' => '標題',
			'markdown.titleDescription' => '使用 # 號創建標題，數量表示級別',
			'markdown.titleSyntax' => '# 一級標題\n## 二級標題\n### 三級標題',
			'markdown.separator' => '分隔線',
			'markdown.separatorDescription' => '使用三個或更多 - 號創建分隔線',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => '語法',
			'forum.recent' => '最近',
			'forum.category' => '分類',
			'forum.lastReply' => '最終回覆',
			'forum.errors.pleaseSelectCategory' => '請選擇分類',
			'forum.errors.threadLocked' => '該主題已鎖定，無法回覆',
			'forum.createPost' => '創建帖子',
			'forum.title' => '標題',
			'forum.enterTitle' => '輸入標題',
			'forum.content' => '內容',
			'forum.enterContent' => '輸入內容',
			'forum.writeYourContentHere' => '在此輸入內容...',
			'forum.posts' => '帖子',
			'forum.threads' => '主題',
			'forum.forum' => '論壇',
			'forum.createThread' => '創建主題',
			'forum.selectCategory' => '選擇分類',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => '冷卻剩餘時間 ${minutes} 分 ${seconds} 秒',
			'forum.groups.administration' => '管理',
			'forum.groups.global' => '全球',
			'forum.groups.chinese' => '中文',
			'forum.groups.japanese' => '日語',
			'forum.groups.korean' => '韓語',
			'forum.groups.other' => '其他',
			'forum.leafNames.announcements' => '公告',
			'forum.leafNames.feedback' => '反饋',
			'forum.leafNames.support' => '幫助',
			'forum.leafNames.general' => '一般',
			'forum.leafNames.guides' => '指南',
			'forum.leafNames.questions' => '問題',
			'forum.leafNames.requests' => '請求',
			'forum.leafNames.sharing' => '分享',
			'forum.leafNames.general_zh' => '一般',
			'forum.leafNames.questions_zh' => '問題',
			'forum.leafNames.requests_zh' => '請求',
			'forum.leafNames.support_zh' => '幫助',
			'forum.leafNames.general_ja' => '一般',
			'forum.leafNames.questions_ja' => '問題',
			'forum.leafNames.requests_ja' => '請求',
			'forum.leafNames.support_ja' => '幫助',
			'forum.leafNames.korean' => '韓語',
			'forum.leafNames.other' => '其他',
			'forum.leafDescriptions.announcements' => '官方重要通知和公告',
			'forum.leafDescriptions.feedback' => '對網站功能和服務的反饋',
			'forum.leafDescriptions.support' => '幫助解決網站相關問題',
			'forum.leafDescriptions.general' => '討論任何話題',
			'forum.leafDescriptions.guides' => '分享你的經驗和教程',
			'forum.leafDescriptions.questions' => '提出你的疑問',
			'forum.leafDescriptions.requests' => '發布你的請求',
			'forum.leafDescriptions.sharing' => '分享有趣的內容',
			'forum.leafDescriptions.general_zh' => '討論任何話題',
			'forum.leafDescriptions.questions_zh' => '提出你的疑問',
			'forum.leafDescriptions.requests_zh' => '發布你的請求',
			'forum.leafDescriptions.support_zh' => '幫助解決網站相關問題',
			'forum.leafDescriptions.general_ja' => '討論任何話題',
			'forum.leafDescriptions.questions_ja' => '提出你的疑問',
			'forum.leafDescriptions.requests_ja' => '發布你的請求',
			'forum.leafDescriptions.support_ja' => '幫助解決網站相關問題',
			'forum.leafDescriptions.korean' => '韓語相關討論',
			'forum.leafDescriptions.other' => '其他未分類的內容',
			'forum.reply' => '回覆',
			'forum.pendingReview' => '審核中',
			'forum.editedAt' => '編輯時間',
			'forum.copySuccess' => '已複製到剪貼簿',
			'forum.copySuccessForMessage' => ({required Object str}) => '已複製到剪貼簿: ${str}',
			'forum.editReply' => '編輯回覆',
			'forum.editTitle' => '編輯標題',
			'forum.submit' => '提交',
			'notifications.errors.unsupportedNotificationType' => '暫不支持的通知類型',
			'notifications.errors.unknownUser' => '未知用戶',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => '暫不支持的通知類型: ${type}',
			'notifications.errors.unknownNotificationType' => '未知通知類型',
			'notifications.notifications' => '通知',
			'notifications.profile' => '個人主頁',
			'notifications.postedNewComment' => '發表了評論',
			'notifications.notifiedOn' => '在您的個人主頁上發表了評論',
			'notifications.inYour' => '在您的',
			'notifications.video' => '影片',
			'notifications.repliedYourVideoComment' => '回覆了您的影片評論',
			'notifications.copyInfoToClipboard' => '複製通知信息到剪貼簿',
			_ => null,
		};
	}

	dynamic _flatMapFunction$2(String path) {
		return switch (path) {
			'notifications.copySuccess' => '已複製到剪貼簿',
			'notifications.copySuccessForMessage' => ({required Object str}) => '已複製到剪貼簿: ${str}',
			'notifications.markAllAsRead' => '全部標記已讀',
			'notifications.markAllAsReadSuccess' => '所有通知已標記為已讀',
			'notifications.markAllAsReadFailed' => '全部標記已讀失敗',
			'notifications.markAllAsReadFailedWithException' => ({required Object exception}) => '全部標記已讀失敗: ${exception}',
			'notifications.markSelectedAsRead' => '標記已讀',
			'notifications.markSelectedAsReadSuccess' => '已標記為已讀',
			'notifications.markSelectedAsReadFailed' => '標記已讀失敗',
			'notifications.markSelectedAsReadFailedWithException' => ({required Object exception}) => '標記已讀失敗: ${exception}',
			'notifications.markAsRead' => '標記已讀',
			'notifications.markAsReadSuccess' => '已標記為已讀',
			'notifications.markAsReadFailed' => '標記已讀失敗',
			'notifications.notificationTypeHelp' => '通知類型幫助',
			'notifications.dueToLackOfNotificationTypeDetails' => '通知類型的詳細信息不足，目前支持的類型可能沒有覆蓋到您當前收到的消息',
			'notifications.helpUsImproveNotificationTypeSupport' => '如果您願意幫助我們完善通知類型的支持：',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 複製通知信息\n2. 🐞 前往項目倉庫提交 issue\n\n⚠️ 注意：通知信息可能包含個人隱私，如果你不想公開，也可以通過郵件發送給項目作者。',
			'notifications.goToRepository' => '前往項目倉庫',
			'notifications.copy' => '複製',
			'notifications.commentApproved' => '評論已通過',
			'notifications.repliedYourProfileComment' => '回覆了您的個人主頁評論',
			'notifications.kReplied' => '回覆了您在',
			'notifications.kCommented' => '評論了您的',
			'notifications.kVideo' => '影片',
			'notifications.kGallery' => '圖庫',
			'notifications.kProfile' => '主頁',
			'notifications.kThread' => '主題',
			'notifications.kPost' => '投稿',
			'notifications.kCommentSection' => '下的評論',
			'notifications.kApprovedComment' => '評論已通過',
			'notifications.kApprovedVideo' => '影片已通過',
			'notifications.kApprovedGallery' => '圖庫已通過',
			'notifications.kApprovedThread' => '主題已審核',
			'notifications.kApprovedPost' => '投稿已審核',
			'notifications.kApprovedForumPost' => '論壇發言審核通過',
			'notifications.kRejectedContent' => '內容審核被拒絕',
			'notifications.kUnknownType' => '未知通知類型',
			'conversation.errors.pleaseSelectAUser' => '請選擇一個用戶',
			'conversation.errors.pleaseEnterATitle' => '請輸入標題',
			'conversation.errors.clickToSelectAUser' => '點擊選擇用戶',
			'conversation.errors.loadFailedClickToRetry' => '加載失敗,點擊重試',
			'conversation.errors.loadFailed' => '加載失敗',
			'conversation.errors.clickToRetry' => '點擊重試',
			'conversation.errors.noMoreConversations' => '沒有更多消息了',
			'conversation.conversation' => '會話',
			'conversation.startConversation' => '發起會話',
			'conversation.noConversation' => '暫無會話',
			'conversation.selectFromLeftListAndStartConversation' => '從左側列表選擇一個會話開始聊天',
			'conversation.title' => '標題',
			'conversation.body' => '內容',
			'conversation.selectAUser' => '選擇用戶',
			'conversation.searchUsers' => '搜索用戶...',
			'conversation.tmpNoConversions' => '暫無會話',
			'conversation.deleteThisMessage' => '刪除此消息',
			'conversation.deleteThisMessageSubtitle' => '此操作不可撤銷',
			'conversation.writeMessageHere' => '在此處輸入消息',
			'conversation.sendMessage' => '發送消息',
			'splash.errors.initializationFailed' => '初始化失敗，請重啟應用',
			'splash.preparing' => '準備中...',
			'splash.initializing' => '初始化中...',
			'splash.loading' => '加載中...',
			'splash.ready' => '準備完成',
			'splash.initializingMessageService' => '初始化消息服務中...',
			'download.errors.imageModelNotFound' => '圖庫信息不存在',
			'download.errors.downloadFailed' => '下載失敗',
			'download.errors.videoInfoNotFound' => '影片信息不存在',
			'download.errors.unknown' => '未知',
			'download.errors.downloadTaskAlreadyExists' => '下載任務已存在',
			'download.errors.videoAlreadyDownloaded' => '該影片已下載',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => '添加下載任務失敗: ${errorInfo}',
			'download.errors.userPausedDownload' => '用戶暫停下載',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => '文件系統錯誤: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => '未知錯誤: ${errorInfo}',
			'download.errors.connectionTimeout' => '連接超時',
			'download.errors.sendTimeout' => '發送超時',
			'download.errors.receiveTimeout' => '接收超時',
			'download.errors.serverError' => ({required Object errorInfo}) => '伺服器錯誤: ${errorInfo}',
			'download.errors.unknownNetworkError' => '未知網路錯誤',
			'download.errors.sslHandshakeFailed' => 'SSL握手失敗，請檢查網路環境',
			'download.errors.connectionFailed' => '連接失敗，請檢查網路',
			'download.errors.serviceIsClosing' => '下載服務正在關閉',
			'download.errors.partialDownloadFailed' => '部分內容下載失敗',
			'download.errors.noDownloadTask' => '暫無下載任務',
			'download.errors.taskNotFoundOrDataError' => '任務不存在或資料錯誤',
			'download.errors.copyDownloadUrlFailed' => '複製下載連結失敗',
			'download.errors.fileNotFound' => '文件不存在',
			'download.errors.openFolderFailed' => '打開文件夾失敗',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => '打開文件夾失敗: ${message}',
			'download.errors.directoryNotFound' => '目錄不存在',
			'download.errors.copyFailed' => '複製失敗',
			'download.errors.openFileFailed' => '打開文件失敗',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => '打開文件失敗: ${message}',
			'download.errors.noDownloadSource' => '沒有下載源',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => '暫無下載源，請等待信息加載完成後重試',
			'download.errors.noActiveDownloadTask' => '暫無正在下載的任務',
			'download.errors.noFailedDownloadTask' => '暫無失敗的任務',
			'download.errors.noCompletedDownloadTask' => '暫無已完成的任務',
			'download.errors.taskAlreadyCompletedDoNotAdd' => '任務已完成，請勿重複添加',
			'download.errors.linkExpiredTryAgain' => '連結已過期，正在重新獲取下載連結',
			'download.errors.linkExpiredTryAgainSuccess' => '連結已過期，正在重新獲取下載連結成功',
			'download.errors.linkExpiredTryAgainFailed' => '連結已過期，正在重新獲取下載連結失敗',
			'download.errors.taskDeleted' => '任務已刪除',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => '不支持的圖片格式: ${format}',
			'download.errors.deleteFileError' => '文件删除失败，可能是因为文件被占用',
			'download.errors.deleteTaskError' => '任务删除失败',
			'download.errors.taskNotFound' => '任务未找到',
			'download.errors.canNotRefreshVideoTask' => '無法刷新視頻任務',
			'download.errors.taskAlreadyProcessing' => '任務已處理中',
			'download.errors.failedToLoadTasks' => '加載任務失敗',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => '部分下載失敗: ${message}',
			'download.errors.pleaseTryOtherViewer' => '請嘗試使用其他查看器打開',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => '不支持的圖片格式: ${extension}, 可以嘗試下載到設備上查看',
			'download.errors.imageLoadFailed' => '圖片加載失敗',
			'download.downloadList' => '下載列表',
			'download.viewDownloadList' => '查看下載列表',
			'download.download' => '下載',
			'download.forceDeleteTask' => '強制刪除任務',
			'download.startDownloading' => '開始下載...',
			'download.clearAllFailedTasks' => '清除全部失敗任務',
			'download.clearAllFailedTasksConfirmation' => '確定要清除所有失敗的下載任務嗎？\n這些任務的文件也會被刪除。',
			'download.clearAllFailedTasksSuccess' => '已清除所有失敗任務',
			'download.clearAllFailedTasksError' => '清除失敗任務時出錯',
			'download.downloadStatus' => '下載狀態',
			'download.imageList' => '圖片列表',
			'download.retryDownload' => '重試下載',
			'download.notDownloaded' => '未下載',
			'download.downloaded' => '已下載',
			'download.waitingForDownload' => '等待下載...',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '下載中 (${downloaded}/${total}張 ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => '下載中 (${downloaded}張)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '已暫停 (${downloaded}/${total}張 ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => '已暫停 (已下載${downloaded}張)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => '下載完成 (共${total}張)',
			'download.viewVideoDetail' => '查看影片詳情',
			'download.viewGalleryDetail' => '查看圖庫詳情',
			'download.moreOptions' => '更多操作',
			'download.openFile' => '打開文件',
			'download.pause' => '暫停',
			'download.resume' => '繼續',
			'download.copyDownloadUrl' => '複製下載連結',
			'download.showInFolder' => '在文件夾中顯示',
			'download.deleteTask' => '刪除任務',
			'download.deleteTaskConfirmation' => '確定要刪除這個下載任務嗎？\n任務的文件也會被刪除。',
			'download.forceDeleteTaskConfirmation' => '確定要強制刪除這個下載任務嗎？\n任務的文件也會被刪除，即使文件被佔用也會嘗試刪除。',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => '下載中 ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => '已暫停 • ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => '已暫停 • 已下載 ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => '下載完成 • ${size}',
			'download.copyDownloadUrlSuccess' => '已複製下載連結',
			'download.totalImageNums' => ({required Object num}) => '${num}張',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下載中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => '下載中',
			'download.failed' => '失敗',
			'download.completed' => '已完成',
			'download.downloadDetail' => '下載詳情',
			'download.copy' => '複製',
			'download.copySuccess' => '已複製',
			'download.waiting' => '等待中',
			'download.paused' => '暫停中',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => '下載中 ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => '圖庫下載完成: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => '下載完成: ${fileName}',
			'download.stillInDevelopment' => '開發中',
			'download.saveToAppDirectory' => '保存到應用程序目錄',
			'download.alreadyDownloadedWithQuality' => '已有相同清晰度的任務，是否繼續下載？',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => '此視頻已有${qualities}清晰度的任務，是否繼續下載？',
			'download.otherQualities' => '其他清晰度',
			'favorite.errors.addFailed' => '追加失敗',
			'favorite.errors.addSuccess' => '追加成功',
			'favorite.errors.deleteFolderFailed' => '刪除文件夾失敗',
			'favorite.errors.deleteFolderSuccess' => '刪除文件夾成功',
			'favorite.errors.folderNameCannotBeEmpty' => '資料夾名稱不能為空',
			'favorite.add' => '追加',
			'favorite.addSuccess' => '追加成功',
			'favorite.addFailed' => '追加失敗',
			'favorite.remove' => '刪除',
			'favorite.removeSuccess' => '刪除成功',
			'favorite.removeFailed' => '刪除失敗',
			'favorite.removeConfirmation' => '確定要刪除這個項目嗎？',
			'favorite.removeConfirmationSuccess' => '項目已從收藏夾中刪除',
			'favorite.removeConfirmationFailed' => '刪除項目失敗',
			'favorite.createFolderSuccess' => '文件夾創建成功',
			'favorite.createFolderFailed' => '創建文件夾失敗',
			'favorite.createFolder' => '創建文件夾',
			'favorite.enterFolderName' => '輸入文件夾名稱',
			'favorite.enterFolderNameHere' => '在此輸入文件夾名稱...',
			'favorite.create' => '創建',
			'favorite.items' => '項目',
			'favorite.newFolderName' => '新文件夾',
			'favorite.searchFolders' => '搜索文件夾...',
			'favorite.searchItems' => '搜索項目...',
			'favorite.createdAt' => '創建時間',
			'favorite.myFavorites' => '我的收藏',
			'favorite.deleteFolderTitle' => '刪除文件夾',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => '確定要刪除 ${title} 文件夾嗎？',
			'favorite.removeItemTitle' => '刪除項目',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => '確定要刪除 ${title} 項目嗎？',
			'favorite.removeItemSuccess' => '項目已從收藏夾中刪除',
			'favorite.removeItemFailed' => '刪除項目失敗',
			'favorite.localizeFavorite' => '本地收藏',
			'favorite.editFolderTitle' => '編輯資料夾',
			'favorite.editFolderSuccess' => '資料夾更新成功',
			'favorite.editFolderFailed' => '資料夾更新失敗',
			'favorite.searchTags' => '搜索標籤',
			'translation.testConnection' => '測試連接',
			'translation.testConnectionSuccess' => '測試連接成功',
			'translation.testConnectionFailed' => '測試連接失敗',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => '測試連接失敗: ${message}',
			'translation.translation' => '翻譯',
			'translation.needVerification' => '需要驗證',
			'translation.needVerificationContent' => '請先通過連接測試才能啟用AI翻譯',
			'translation.confirm' => '確定',
			'translation.disclaimer' => '使用須知',
			'translation.riskWarning' => '風險提示',
			'translation.dureToRisk1' => '由於評論等文本為用戶生成，可能包含違反AI服務商內容政策的內容',
			'translation.dureToRisk2' => '不當內容可能導致API密鑰封禁或服務終止',
			'translation.operationSuggestion' => '操作建議',
			'translation.operationSuggestion1' => '1. 使用前請嚴格審核待翻譯內容',
			'translation.operationSuggestion2' => '2. 避免翻譯涉及暴力、成人等敏感內容',
			'translation.apiConfig' => 'API設定',
			'translation.modifyConfigWillAutoCloseAITranslation' => '修改配置將自動關閉AI翻譯，需重新測試後打開',
			'translation.apiAddress' => 'API地址',
			'translation.modelName' => '模型名稱',
			'translation.modelNameHintText' => '例如：gpt-4-turbo',
			'translation.maxTokens' => '最大Token數',
			'translation.maxTokensHintText' => '例如：1024',
			'translation.temperature' => '溫度係數',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => '點擊測試按鈕驗證API連接有效性',
			'translation.requestPreview' => '請求預覽',
			'translation.enableAITranslation' => 'AI翻譯',
			'translation.enabled' => '已啟用',
			'translation.disabled' => '已禁用',
			'translation.testing' => '測試中...',
			'translation.testNow' => '立即測試',
			'translation.connectionStatus' => '連接狀態',
			'translation.success' => '成功',
			'translation.failed' => '失敗',
			'translation.information' => '信息',
			'translation.viewRawResponse' => '查看原始響應',
			'translation.pleaseCheckInputParametersFormat' => '請檢查輸入參數格式',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => '請填寫API地址、模型名稱和密鑰',
			'translation.pleaseFillInValidConfigurationParameters' => '請填寫有效的配置參數',
			'translation.pleaseCompleteConnectionTest' => '請完成連接測試',
			'translation.notConfigured' => '未配置',
			'translation.apiEndpoint' => 'API端點',
			'translation.configuredKey' => '已配置密鑰',
			'translation.notConfiguredKey' => '未配置密鑰',
			'translation.authenticationStatus' => '認證狀態',
			'translation.thisFieldCannotBeEmpty' => '此字段不能為空',
			'translation.apiKey' => 'API密鑰',
			'translation.apiKeyCannotBeEmpty' => 'API密鑰不能為空',
			'translation.range' => '範圍',
			'translation.pleaseEnterValidNumber' => '請輸入有效數字',
			'translation.mustBeGreaterThan' => '必須大於',
			'translation.invalidAPIResponse' => '無效的API響應',
			'translation.connectionFailedForMessage' => ({required Object message}) => '連接失敗: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI翻譯未啟用，請在設定中啟用',
			'translation.goToSettings' => '前往設定',
			'translation.disableAITranslation' => '禁用AI翻譯',
			'translation.currentValue' => '現在值',
			'translation.configureTranslationStrategy' => '配置翻譯策略',
			'translation.advancedSettings' => '高級設定',
			'translation.translationPrompt' => '翻譯提示詞',
			'translation.promptHint' => '請輸入翻譯提示詞,使用[TL]作為目標語言的占位符',
			'translation.promptHelperText' => '提示詞必須包含[TL]作為目標語言的占位符',
			'translation.promptMustContainTargetLang' => '提示詞必須包含[TL]占位符',
			'translation.aiTranslationWillBeDisabled' => 'AI翻譯將被自動關閉',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => '由於修改了基礎配置,AI翻譯將被自動關閉',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => '由於修改了翻譯提示詞,AI翻譯將被自動關閉',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => '由於修改了參數配置,AI翻譯將被自動關閉',
			'translation.onlyOpenAIAPISupported' => '目前僅支持OpenAI兼容的API格式（application/json請求體格式）',
			'translation.streamingTranslation' => '流式翻譯',
			'translation.streamingTranslationSupported' => '支持流式翻譯',
			'translation.streamingTranslationNotSupported' => '不支持流式翻譯',
			'translation.streamingTranslationDescription' => '流式翻譯可以在翻譯過程中實時顯示結果，提供更好的用戶體驗',
			'translation.baseUrlInputHelperText' => '當以#結尾時，將以輸入的URL作為實際請求地址',
			'translation.usingFullUrlWithHash' => '使用完整URL（以#結尾）',
			'translation.currentActualUrl' => ({required Object url}) => '目前實際URL: ${url}',
			'translation.urlEndingWithHashTip' => 'URL以#結尾時，將以輸入的URL作為實際請求地址',
			'translation.streamingTranslationWarning' => '注意：此功能需要API服務支持流式傳輸，部分模型可能不支持',
			'translation.translationService' => '翻譯服務',
			'translation.translationServiceDescription' => '選擇您偏好的翻譯服務',
			'translation.googleTranslation' => 'Google 翻譯',
			'translation.googleTranslationDescription' => '免費的線上翻譯服務，支援多種語言',
			'translation.aiTranslation' => 'AI 翻譯',
			'translation.aiTranslationDescription' => '基於大語言模型的智慧翻譯服務',
			'translation.deeplxTranslation' => 'DeepLX 翻譯',
			'translation.deeplxTranslationDescription' => 'DeepL 翻譯的開源實現，提供高品質翻譯',
			'translation.googleTranslationFeatures' => '特性',
			'translation.freeToUse' => '免費使用',
			'translation.freeToUseDescription' => '無需配置，開箱即用',
			'translation.fastResponse' => '快速響應',
			'translation.fastResponseDescription' => '翻譯速度快，延遲低',
			'translation.stableAndReliable' => '穩定可靠',
			'translation.stableAndReliableDescription' => '基於Google官方API',
			'translation.enabledDefaultService' => '已啟用 - 預設翻譯服務',
			'translation.notEnabled' => '未啟用',
			'translation.deeplxTranslationService' => 'DeepLX 翻譯服務',
			'translation.deeplxDescription' => 'DeepLX 是 DeepL 翻譯的開源實現，支援 Free、Pro 和 Official 三種端點模式',
			'translation.serverAddress' => '伺服器地址',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'DeepLX 伺服器的基礎地址',
			'translation.endpointType' => '端點類型',
			'translation.freeEndpoint' => 'Free - 免費端點，可能有頻率限制',
			'translation.proEndpoint' => 'Pro - 需要 dl_session，更穩定',
			'translation.officialEndpoint' => 'Official - 官方 API 格式',
			'translation.finalRequestUrl' => '最終請求URL',
			'translation.apiKeyOptional' => 'API Key (可選)',
			'translation.apiKeyOptionalHint' => '用於訪問受保護的 DeepLX 服務',
			'translation.apiKeyOptionalHelperText' => '某些 DeepLX 服務需要 API Key 進行身份驗證',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Pro 模式需要的 dl_session 參數',
			'translation.dlSessionHelperText' => 'Pro 端點必需的會話參數，從 DeepL Pro 帳戶獲取',
			'translation.proModeRequiresDlSession' => 'Pro 模式需要填寫 dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => '點擊測試按鈕驗證 DeepLX API 連接',
			'translation.enableDeepLXTranslation' => '啟用 DeepLX 翻譯',
			'translation.deepLXTranslationWillBeDisabled' => 'DeepLX翻譯將因配置更改而被禁用',
			'translation.translatedResult' => '翻譯結果',
			'translation.testSuccess' => '測試成功',
			'translation.pleaseFillInDeepLXServerAddress' => '請填寫DeepLX伺服器地址',
			'translation.invalidAPIResponseFormat' => '無效的API響應格式',
			'translation.translationServiceReturnedError' => '翻譯服務返回錯誤或空結果',
			'translation.connectionFailed' => '連接失敗',
			'translation.translationFailed' => '翻譯失敗',
			'translation.aiTranslationFailed' => 'AI翻譯失敗',
			'translation.deeplxTranslationFailed' => 'DeepLX翻譯失敗',
			'translation.aiTranslationTestFailed' => 'AI翻譯測試失敗',
			'translation.deeplxTranslationTestFailed' => 'DeepLX翻譯測試失敗',
			'translation.streamingTranslationTimeout' => '流式翻譯超時，強制關閉資源',
			'translation.translationRequestTimeout' => '翻譯請求超時',
			'translation.streamingTranslationDataTimeout' => '流式翻譯接收數據超時',
			'translation.dataReceptionTimeout' => '接收數據超時',
			'translation.streamDataParseError' => '解析流數據時出錯',
			'translation.streamingTranslationFailed' => '流式翻譯失敗',
			'translation.fallbackTranslationFailed' => '降級到普通翻譯也失敗',
			'translation.translationSettings' => '翻譯設定',
			'translation.enableGoogleTranslation' => '啟用 Google 翻譯',
			'mediaPlayer.videoPlayerError' => '影片播放器錯誤',
			'mediaPlayer.videoLoadFailed' => '影片載入失敗',
			'mediaPlayer.videoCodecNotSupported' => '影片編解碼器不支援',
			'mediaPlayer.networkConnectionIssue' => '網路連線問題',
			'mediaPlayer.insufficientPermission' => '權限不足',
			'mediaPlayer.unsupportedVideoFormat' => '不支援的影片格式',
			'mediaPlayer.retry' => '重試',
			'mediaPlayer.externalPlayer' => '外部播放器',
			'mediaPlayer.detailedErrorInfo' => '詳細錯誤資訊',
			'mediaPlayer.format' => '格式',
			'mediaPlayer.suggestion' => '建議',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Android裝置對WEBM格式支援有限，建議使用外部播放器或下載支援WEBM的播放器應用',
			'mediaPlayer.currentDeviceCodecNotSupported' => '目前裝置不支援此影片格式的編解碼器',
			'mediaPlayer.checkNetworkConnection' => '請檢查網路連線後重試',
			'mediaPlayer.appMayLackMediaPermission' => '應用可能缺少必要的媒體播放權限',
			'mediaPlayer.tryOtherVideoPlayer' => '請嘗試使用其他影片播放器',
			'mediaPlayer.video' => '影片',
			'mediaPlayer.imageLoadFailed' => '圖片載入失敗',
			'mediaPlayer.unsupportedImageFormat' => '不支援的圖片格式',
			'mediaPlayer.tryOtherViewer' => '請嘗試使用其他檢視器',
			'mediaPlayer.retryingOpenVideoLink' => '影片連結開啟失敗，重試中',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => '無法載入解碼器: ${event}，可在播放器設定切換為軟解，並重新進入頁面嘗試',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => '影片載入錯誤: ${event}',
			'linkInputDialog.title' => '輸入連結',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => '支持智能識別多個${webName}連結，並快速跳轉到應用內對應頁面(連結與其他文本之間用空格隔開)',
			'linkInputDialog.inputHint' => ({required Object webName}) => '請輸入${webName}連結',
			'linkInputDialog.validatorEmptyLink' => '請輸入連結',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => '未檢測到有效的${webName}連結',
			'linkInputDialog.multipleLinksDetected' => '檢測到多個連結，請選擇一個：',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => '不是有效的${webName}連結',
			'linkInputDialog.linkParseError' => ({required Object error}) => '連結解析出錯: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => '不支援的連結',
			'linkInputDialog.unsupportedLinkDialogContent' => '該連結類型當前應用無法直接打開，需要使用外部瀏覽器訪問。\n\n是否使用瀏覽器打開此連結？',
			'linkInputDialog.openInBrowser' => '用瀏覽器打開',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => '確認打開瀏覽器',
			'linkInputDialog.confirmOpenBrowserDialogContent' => '即將使用外部瀏覽器打開以下連結：',
			'linkInputDialog.confirmContinueBrowserOpen' => '確定要繼續嗎？',
			'linkInputDialog.browserOpenFailed' => '無法打開連結',
			'linkInputDialog.unsupportedLink' => '不支援的連結',
			'linkInputDialog.cancel' => '取消',
			'linkInputDialog.confirm' => '用瀏覽器打開',
			'log.logManagement' => '日志管理',
			'log.enableLogPersistence' => '持久化日志',
			'log.enableLogPersistenceDesc' => '將日志保存到數據庫以便於分析問題',
			'log.logDatabaseSizeLimit' => '日志數據庫大小上限',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => '當前: ${size}',
			'log.exportCurrentLogs' => '導出當前日志',
			'log.exportCurrentLogsDesc' => '導出當天應用日志以幫助開發者診斷問題',
			'log.exportHistoryLogs' => '導出歷史日志',
			'log.exportHistoryLogsDesc' => '導出指定日期範圍內的日志',
			'log.exportMergedLogs' => '導出合併日志',
			'log.exportMergedLogsDesc' => '導出指定日期範圍內的合併日志',
			'log.showLogStats' => '顯示日志統計信息',
			'log.logExportSuccess' => '日志導出成功',
			'log.logExportFailed' => ({required Object error}) => '日志導出失敗: ${error}',
			'log.showLogStatsDesc' => '查看各種類型日志的統計數據',
			'log.logExtractFailed' => ({required Object error}) => '獲取日志統計失敗: ${error}',
			'log.clearAllLogs' => '清理所有日志',
			'log.clearAllLogsDesc' => '清理所有日志數據',
			'log.confirmClearAllLogs' => '確認清理',
			'log.confirmClearAllLogsDesc' => '確定要清理所有日志數據嗎？此操作不可撤銷。',
			'log.clearAllLogsSuccess' => '日志清理成功',
			'log.clearAllLogsFailed' => ({required Object error}) => '清理日志失敗: ${error}',
			'log.unableToGetLogSizeInfo' => '無法獲取日志大小信息',
			'log.currentLogSize' => '當前日志大小:',
			'log.logCount' => '日志數量:',
			'log.logCountUnit' => '條',
			'log.logSizeLimit' => '大小上限:',
			'log.usageRate' => '使用率:',
			'log.exceedLimit' => '超出限制',
			'log.remaining' => '剩餘',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => '日志空間已超出限制，建議立即清理舊日志或增加空間限制',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => '日志空間即將用盡，建議清理舊日志',
			'log.cleaningOldLogs' => '正在自動清理舊日志...',
			'log.logCleaningCompleted' => '日志清理完成',
			'log.logCleaningProcessMayNotBeCompleted' => '日志清理過程可能未完成',
			'log.cleanExceededLogs' => '清理超出限制的日志',
			'log.noLogsToExport' => '沒有可導出的日志數據',
			'log.exportingLogs' => '正在導出日志...',
			'log.noHistoryLogsToExport' => '尚無可導出的歷史日志，請先使用應用一段時間再嘗試',
			'log.selectLogDate' => '選擇日志日期',
			'log.today' => '今天',
			'log.selectMergeRange' => '選擇合併範圍',
			'log.selectMergeRangeHint' => '請選擇要合併的日志時間範圍',
			'log.selectMergeRangeDays' => ({required Object days}) => '最近 ${days} 天',
			'log.logStats' => '日志統計信息',
			'log.todayLogs' => ({required Object count}) => '今日日志: ${count} 條',
			'log.recent7DaysLogs' => ({required Object count}) => '最近7天: ${count} 條',
			'log.totalLogs' => ({required Object count}) => '總計日志: ${count} 條',
			'log.setLogDatabaseSizeLimit' => '設置日志數據庫大小上限',
			'log.currentLogSizeWithSize' => ({required Object size}) => '當前日志大小: ${size}',
			'log.warning' => '警告',
			'log.newSizeLimit' => ({required Object size}) => '新的大小限制: ${size}',
			'log.confirmToContinue' => '確定要繼續嗎？',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => '日志大小上限已設置為 ${size}',
			'emoji.name' => '表情',
			'emoji.size' => '大小',
			'emoji.small' => '小',
			'emoji.medium' => '中',
			'emoji.large' => '大',
			'emoji.extraLarge' => '超大',
			'emoji.copyEmojiLinkSuccess' => '表情包連結已複製',
			'emoji.preview' => '表情包預覽',
			'emoji.library' => '表情包庫',
			'emoji.noEmojis' => '暫無表情包',
			'emoji.clickToAddEmojis' => '點擊右上角按鈕添加表情包',
			'emoji.addEmojis' => '添加表情包',
			'emoji.imagePreview' => '圖片預覽',
			'emoji.imageLoadFailed' => '圖片載入失敗',
			'emoji.loading' => '載入中...',
			'emoji.delete' => '刪除',
			'emoji.close' => '關閉',
			'emoji.deleteImage' => '刪除圖片',
			'emoji.confirmDeleteImage' => '確定要刪除這張圖片嗎？',
			'emoji.cancel' => '取消',
			'emoji.batchDelete' => '批量刪除',
			'emoji.confirmBatchDelete' => ({required Object count}) => '確定要刪除選中的${count}張圖片嗎？此操作不可撤銷。',
			'emoji.deleteSuccess' => '成功刪除',
			'emoji.addImage' => '添加圖片',
			'emoji.addImageByUrl' => '通過URL添加',
			'emoji.addImageUrl' => '添加圖片URL',
			'emoji.imageUrl' => '圖片URL',
			'emoji.enterImageUrl' => '請輸入圖片URL',
			'emoji.add' => '添加',
			'emoji.batchImport' => '批量導入',
			'emoji.enterJsonUrlArray' => '請輸入JSON格式的URL數組:',
			'emoji.formatExample' => '格式示例:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => '請粘貼JSON格式的URL數組',
			'emoji.import' => '導入',
			'emoji.importSuccess' => ({required Object count}) => '成功導入${count}張圖片',
			'emoji.jsonFormatError' => 'JSON格式錯誤，請檢查輸入',
			'emoji.createGroup' => '創建表情包分組',
			'emoji.groupName' => '分組名稱',
			'emoji.enterGroupName' => '請輸入分組名稱',
			'emoji.create' => '創建',
			'emoji.editGroupName' => '編輯分組名稱',
			'emoji.save' => '保存',
			'emoji.deleteGroup' => '刪除分組',
			'emoji.confirmDeleteGroup' => '確定要刪除這個表情包分組嗎？分組內的所有圖片也會被刪除。',
			'emoji.imageCount' => ({required Object count}) => '${count}張圖片',
			'emoji.selectEmoji' => '選擇表情包',
			'emoji.noEmojisInGroup' => '該分組暫無表情包',
			'emoji.goToSettingsToAddEmojis' => '前往設置添加表情包',
			'emoji.emojiManagement' => '表情包管理',
			'emoji.manageEmojiGroupsAndImages' => '管理表情包分組和圖片',
			'emoji.uploadLocalImages' => '上傳本地圖片',
			'emoji.uploadingImages' => '正在上傳圖片',
			'emoji.uploadingImagesProgress' => ({required Object count}) => '正在上傳 ${count} 張圖片，請稍候...',
			'emoji.doNotCloseDialog' => '請不要關閉此對話框',
			'emoji.uploadSuccess' => ({required Object count}) => '成功上傳 ${count} 張圖片',
			'emoji.uploadFailed' => ({required Object count}) => '失敗 ${count} 張',
			'emoji.uploadFailedMessage' => '圖片上傳失敗，請檢查網路連接或檔案格式',
			'emoji.uploadErrorMessage' => ({required Object error}) => '上傳過程中發生錯誤: ${error}',
			'displaySettings.title' => '顯示設定',
			'displaySettings.layoutSettings' => '版面配置設定',
			'displaySettings.layoutSettingsDesc' => '自訂欄數和斷點配置',
			'displaySettings.gridLayout' => '網格版面配置',
			'displaySettings.navigationOrderSettings' => '導航排序設定',
			'displaySettings.customNavigationOrder' => '自訂導航順序',
			'displaySettings.customNavigationOrderDesc' => '調整底部導航欄和側邊欄中頁面的顯示順序',
			'layoutSettings.title' => '版面配置設定',
			'layoutSettings.descriptionTitle' => '版面配置說明',
			'layoutSettings.descriptionContent' => '這裡的配置將決定影片、圖庫列表頁面中顯示的欄數。您可以選擇自動模式讓系統根據螢幕寬度自動調整，或選擇手動模式固定欄數。',
			'layoutSettings.layoutMode' => '版面配置模式',
			'layoutSettings.reset' => '重設',
			'layoutSettings.autoMode' => '自動模式',
			'layoutSettings.autoModeDesc' => '根據螢幕寬度自動調整',
			'layoutSettings.manualMode' => '手動模式',
			'layoutSettings.manualModeDesc' => '使用固定欄數',
			'layoutSettings.manualSettings' => '手動設定',
			'layoutSettings.fixedColumns' => '固定欄數',
			'layoutSettings.columns' => '欄',
			'layoutSettings.breakpointConfig' => '斷點配置',
			_ => null,
		};
	}

	dynamic _flatMapFunction$3(String path) {
		return switch (path) {
			'layoutSettings.add' => '新增',
			'layoutSettings.defaultColumns' => '預設欄數',
			'layoutSettings.defaultColumnsDesc' => '大螢幕預設顯示',
			'layoutSettings.previewEffect' => '預覽效果',
			'layoutSettings.screenWidth' => '螢幕寬度',
			'layoutSettings.addBreakpoint' => '新增斷點',
			'layoutSettings.editBreakpoint' => '編輯斷點',
			'layoutSettings.deleteBreakpoint' => '刪除斷點',
			'layoutSettings.screenWidthLabel' => '螢幕寬度',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => '欄數',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => '請輸入寬度',
			'layoutSettings.enterValidWidth' => '請輸入有效寬度',
			'layoutSettings.widthCannotExceed9999' => '寬度不能超過9999',
			'layoutSettings.breakpointAlreadyExists' => '斷點已存在',
			'layoutSettings.enterColumns' => '請輸入欄數',
			'layoutSettings.enterValidColumns' => '請輸入有效欄數',
			'layoutSettings.columnsCannotExceed12' => '欄數不能超過12',
			'layoutSettings.breakpointConflict' => '斷點已存在',
			'layoutSettings.confirmResetLayoutSettings' => '重設版面配置設定',
			'layoutSettings.confirmResetLayoutSettingsDesc' => '確定要重設所有版面配置設定到預設值嗎？\n\n將恢復為：\n• 自動模式\n• 預設斷點配置',
			'layoutSettings.resetToDefaults' => '重設為預設值',
			'layoutSettings.confirmDeleteBreakpoint' => '刪除斷點',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => '確定要刪除 ${width}px 斷點嗎？',
			'layoutSettings.noCustomBreakpoints' => '暫無自訂斷點，使用預設欄數',
			'layoutSettings.breakpointRange' => '斷點區間',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => '編輯',
			'layoutSettings.delete' => '刪除',
			'layoutSettings.cancel' => '取消',
			'layoutSettings.save' => '儲存',
			'navigationOrderSettings.title' => '導航排序設定',
			'navigationOrderSettings.customNavigationOrder' => '自訂導航順序',
			'navigationOrderSettings.customNavigationOrderDesc' => '拖拽調整底部導航欄和側邊欄中各個頁面的顯示順序',
			'navigationOrderSettings.restartRequired' => '需重啟應用生效',
			'navigationOrderSettings.navigationItemSorting' => '導航項目排序',
			'navigationOrderSettings.done' => '完成',
			'navigationOrderSettings.edit' => '編輯',
			'navigationOrderSettings.reset' => '重設',
			'navigationOrderSettings.previewEffect' => '預覽效果',
			'navigationOrderSettings.bottomNavigationPreview' => '底部導航欄預覽：',
			'navigationOrderSettings.sidebarPreview' => '側邊欄預覽：',
			'navigationOrderSettings.confirmResetNavigationOrder' => '確認重設導航順序',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => '確定要將導航順序重設為預設設定嗎？',
			'navigationOrderSettings.cancel' => '取消',
			'navigationOrderSettings.videoDescription' => '瀏覽熱門影片內容',
			'navigationOrderSettings.galleryDescription' => '瀏覽圖片和畫廊',
			'navigationOrderSettings.subscriptionDescription' => '查看追蹤用戶的最新內容',
			'navigationOrderSettings.forumDescription' => '參與社群討論',
			'searchFilter.selectField' => '選擇欄位',
			'searchFilter.add' => '新增',
			'searchFilter.clear' => '清空',
			'searchFilter.clearAll' => '清空全部',
			'searchFilter.generatedQuery' => '產生的查詢',
			'searchFilter.copyToClipboard' => '複製到剪貼簿',
			'searchFilter.copied' => '已複製',
			'searchFilter.filterCount' => ({required Object count}) => '${count} 個過濾器',
			'searchFilter.filterSettings' => '篩選項設定',
			'searchFilter.field' => '欄位',
			'searchFilter.operator' => '運算子',
			'searchFilter.language' => '語言',
			'searchFilter.value' => '值',
			'searchFilter.dateRange' => '日期範圍',
			'searchFilter.numberRange' => '數值範圍',
			'searchFilter.from' => '從',
			'searchFilter.to' => '到',
			'searchFilter.date' => '日期',
			'searchFilter.number' => '數值',
			'searchFilter.boolean' => '布林值',
			'searchFilter.tags' => '標籤',
			'searchFilter.select' => '選擇',
			'searchFilter.clickToSelectDate' => '點擊選擇日期',
			'searchFilter.pleaseEnterValidNumber' => '請輸入有效的數值',
			'searchFilter.pleaseEnterValidDate' => '請輸入有效的日期格式 (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => '起始值必須小於結束值',
			'searchFilter.startDateMustBeBeforeEndDate' => '起始日期必須早於結束日期',
			'searchFilter.pleaseFillStartValue' => '請填寫起始值',
			'searchFilter.pleaseFillEndValue' => '請填寫結束值',
			'searchFilter.rangeValueFormatError' => '範圍值格式錯誤',
			'searchFilter.contains' => '包含',
			'searchFilter.equals' => '等於',
			'searchFilter.notEquals' => '不等於',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => '範圍',
			'searchFilter.kIn' => '包含任意一項',
			'searchFilter.notIn' => '不包含任意一項',
			'searchFilter.username' => '使用者名稱',
			'searchFilter.nickname' => '暱稱',
			'searchFilter.registrationDate' => '註冊日期',
			'searchFilter.description' => '描述',
			'searchFilter.title' => '標題',
			'searchFilter.body' => '內容',
			'searchFilter.author' => '作者',
			'searchFilter.publishDate' => '發布日期',
			'searchFilter.private' => '私密',
			'searchFilter.duration' => '時長(秒)',
			'searchFilter.likes' => '讚數',
			'searchFilter.views' => '觀看數',
			'searchFilter.comments' => '評論數',
			'searchFilter.rating' => '評級',
			'searchFilter.imageCount' => '圖片數量',
			'searchFilter.videoCount' => '影片數量',
			'searchFilter.createDate' => '建立日期',
			'searchFilter.content' => '內容',
			'searchFilter.all' => '全部的',
			'searchFilter.adult' => '成人的',
			'searchFilter.general' => '大眾的',
			'searchFilter.yes' => '是',
			'searchFilter.no' => '否',
			'searchFilter.users' => '使用者',
			'searchFilter.videos' => '影片',
			'searchFilter.images' => '圖片',
			'searchFilter.posts' => '貼文',
			'searchFilter.forumThreads' => '論壇主題',
			'searchFilter.forumPosts' => '論壇貼文',
			'searchFilter.playlists' => '播放清單',
			'searchFilter.sortTypes.relevance' => '相關性',
			'searchFilter.sortTypes.latest' => '最新',
			'searchFilter.sortTypes.views' => '觀看次數',
			'searchFilter.sortTypes.likes' => '按讚數',
			'tagSelector.selectTags' => '選擇標籤',
			'tagSelector.clickToSelectTags' => '點擊選擇標籤',
			'tagSelector.addTag' => '新增標籤',
			'tagSelector.removeTag' => '移除標籤',
			'tagSelector.deleteTag' => '刪除標籤',
			'tagSelector.usageInstructions' => '需先新增標籤，然後再從已有的標籤中點擊選中',
			'tagSelector.usageInstructionsTooltip' => '使用說明',
			'tagSelector.addTagTooltip' => '新增標籤',
			'tagSelector.removeTagTooltip' => '刪除標籤',
			'tagSelector.cancelSelection' => '取消選擇',
			'tagSelector.selectAll' => '全選',
			'tagSelector.cancelSelectAll' => '取消全選',
			'tagSelector.delete' => '刪除',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Anime4K 即時視頻上採樣和降噪，提升動畫視頻品質',
			'anime4k.settings' => 'Anime4K 設定',
			'anime4k.preset' => 'Anime4K 預設',
			'anime4k.disable' => '關閉 Anime4K',
			'anime4k.disableDescription' => '禁用視頻增強效果',
			'anime4k.highQualityPresets' => '高品質預設',
			'anime4k.fastPresets' => '快速預設',
			'anime4k.litePresets' => '輕量級預設',
			'anime4k.moreLitePresets' => '更多輕量級預設',
			'anime4k.customPresets' => '自定義預設',
			'anime4k.presetGroups.highQuality' => '高品質',
			'anime4k.presetGroups.fast' => '快速',
			'anime4k.presetGroups.lite' => '輕量級',
			'anime4k.presetGroups.moreLite' => '更多輕量級',
			'anime4k.presetGroups.custom' => '自定義',
			'anime4k.presetDescriptions.mode_a_hq' => '適用於大多數1080p動漫，特別是處理模糊、重採樣和壓縮瑕疵。提供最高的感知品質。',
			'anime4k.presetDescriptions.mode_b_hq' => '適用於輕微模糊或因縮放產生的振鈴效應的動漫。可以有效減少振鈴和鋸齒。',
			'anime4k.presetDescriptions.mode_c_hq' => '適用於幾乎沒有瑕疵的高品質片源（如原生1080p的動畫電影或壁紙）。降噪並提供最高的PSNR。',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Mode A的強化版，提供極致的感知品質，能重建幾乎所有退化的線條。可能產生過度銳化或振鈴。',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Mode B的強化版，提供更高的感知品質，進一步優化線條和減少瑕疵。',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Mode C的感知品質增強版，在保持高PSNR的同時嘗試重建一些線條細節。',
			'anime4k.presetDescriptions.mode_a_fast' => 'Mode A的快速版本，平衡了品質與性能，適用於大多數1080p動漫。',
			'anime4k.presetDescriptions.mode_b_fast' => 'Mode B的快速版本，用於處理輕微瑕疵和振鈴，性能開銷較低。',
			'anime4k.presetDescriptions.mode_c_fast' => 'Mode C的快速版本，適用於高品質片源的快速降噪和放大。',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Mode A+A的快速版本，在性能有限的設備上追求更高的感知品質。',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Mode B+B的快速版本，為性能有限的設備提供增強的線條修復和瑕疵處理。',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Mode C+A的快速版本，在快速處理高品質片源的同時，進行輕度的線條修復。',
			'anime4k.presetDescriptions.upscale_only_s' => '僅使用最快的CNN模型進行x2放大，無修復和降噪，性能開銷最低。',
			'anime4k.presetDescriptions.upscale_deblur_fast' => '使用快速的非CNN算法進行放大和去模糊，效果優於傳統算法，性能開銷很低。',
			'anime4k.presetDescriptions.restore_s_only' => '僅使用最快的CNN模型修復畫面瑕疵，不進行放大。適用於原生分辨率播放，但希望改善畫質的情況。',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => '使用傳統的雙邊濾波器進行降噪，速度極快，適用於處理輕微噪點。',
			'anime4k.presetDescriptions.upscale_non_cnn' => '使用快速的傳統算法進行放大，性能開銷極低，效果優於播放器自帶算法。',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + 線條加深，在快速模式A的基礎上增加線條加深效果，使線條更突出，風格化處理。',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + 線條細化，在高品質模式A的基礎上增加線條細化效果，讓畫面看起來更精緻。',
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
			'anime4k.presetNames.upscale_only_s' => 'CNN放大 (超快)',
			'anime4k.presetNames.upscale_deblur_fast' => '放大 & 去模糊 (快速)',
			'anime4k.presetNames.restore_s_only' => '修復 (超快)',
			'anime4k.presetNames.denoise_bilateral_fast' => '雙邊降噪 (極快)',
			'anime4k.presetNames.upscale_non_cnn' => '非CNN放大 (極快)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + 線條加深',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + 線條細化',
			'anime4k.performanceTip' => '💡 提示：根據設備性能選擇合適的預設，低端設備建議選擇輕量級預設。',
			_ => null,
		};
	}
}

