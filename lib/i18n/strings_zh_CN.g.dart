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
class TranslationsZhCn implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZhCn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zhCn,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh-CN>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsZhCn _root = this; // ignore: unused_field

	@override 
	TranslationsZhCn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZhCn(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonZhCn common = _TranslationsCommonZhCn._(_root);
	@override late final _TranslationsAuthZhCn auth = _TranslationsAuthZhCn._(_root);
	@override late final _TranslationsErrorsZhCn errors = _TranslationsErrorsZhCn._(_root);
	@override late final _TranslationsFriendsZhCn friends = _TranslationsFriendsZhCn._(_root);
	@override late final _TranslationsAuthorProfileZhCn authorProfile = _TranslationsAuthorProfileZhCn._(_root);
	@override late final _TranslationsFavoritesZhCn favorites = _TranslationsFavoritesZhCn._(_root);
	@override late final _TranslationsGalleryDetailZhCn galleryDetail = _TranslationsGalleryDetailZhCn._(_root);
	@override late final _TranslationsPlayListZhCn playList = _TranslationsPlayListZhCn._(_root);
	@override late final _TranslationsSearchZhCn search = _TranslationsSearchZhCn._(_root);
	@override late final _TranslationsMediaListZhCn mediaList = _TranslationsMediaListZhCn._(_root);
	@override late final _TranslationsSettingsZhCn settings = _TranslationsSettingsZhCn._(_root);
	@override late final _TranslationsOreno3dZhCn oreno3d = _TranslationsOreno3dZhCn._(_root);
	@override late final _TranslationsSignInZhCn signIn = _TranslationsSignInZhCn._(_root);
	@override late final _TranslationsSubscriptionsZhCn subscriptions = _TranslationsSubscriptionsZhCn._(_root);
	@override late final _TranslationsVideoDetailZhCn videoDetail = _TranslationsVideoDetailZhCn._(_root);
	@override late final _TranslationsShareZhCn share = _TranslationsShareZhCn._(_root);
	@override late final _TranslationsMarkdownZhCn markdown = _TranslationsMarkdownZhCn._(_root);
	@override late final _TranslationsForumZhCn forum = _TranslationsForumZhCn._(_root);
	@override late final _TranslationsNotificationsZhCn notifications = _TranslationsNotificationsZhCn._(_root);
	@override late final _TranslationsConversationZhCn conversation = _TranslationsConversationZhCn._(_root);
	@override late final _TranslationsSplashZhCn splash = _TranslationsSplashZhCn._(_root);
	@override late final _TranslationsDownloadZhCn download = _TranslationsDownloadZhCn._(_root);
	@override late final _TranslationsFavoriteZhCn favorite = _TranslationsFavoriteZhCn._(_root);
	@override late final _TranslationsTranslationZhCn translation = _TranslationsTranslationZhCn._(_root);
	@override late final _TranslationsLinkInputDialogZhCn linkInputDialog = _TranslationsLinkInputDialogZhCn._(_root);
	@override late final _TranslationsLogZhCn log = _TranslationsLogZhCn._(_root);
}

// Path: common
class _TranslationsCommonZhCn implements TranslationsCommonEn {
	_TranslationsCommonZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get appName => 'Love Iwara';
	@override String get ok => '确定';
	@override String get cancel => '取消';
	@override String get save => '保存';
	@override String get delete => '删除';
	@override String get visit => '访问';
	@override String get loading => '加载中...';
	@override String get scrollToTop => '滚动到顶部';
	@override String get privacyHint => '隐私内容，不与展示';
	@override String get latest => '最新';
	@override String get likesCount => '点赞数';
	@override String get viewsCount => '观看次数';
	@override String get popular => '受欢迎的';
	@override String get trending => '趋势';
	@override String get commentList => '评论列表';
	@override String get sendComment => '发表评论';
	@override String get send => '发表';
	@override String get retry => '重试';
	@override String get premium => '高级会员';
	@override String get follower => '粉丝';
	@override String get friend => '朋友';
	@override String get video => '视频';
	@override String get following => '关注';
	@override String get expand => '展开';
	@override String get collapse => '收起';
	@override String get cancelFriendRequest => '取消申请';
	@override String get cancelSpecialFollow => '取消特别关注';
	@override String get addFriend => '添加朋友';
	@override String get removeFriend => '解除朋友';
	@override String get followed => '已关注';
	@override String get follow => '关注';
	@override String get unfollow => '取消关注';
	@override String get specialFollow => '特别关注';
	@override String get specialFollowed => '已特别关注';
	@override String get gallery => '图库';
	@override String get playlist => '播放列表';
	@override String get commentPostedSuccessfully => '评论发表成功';
	@override String get commentPostedFailed => '评论发表失败';
	@override String get success => '成功';
	@override String get commentDeletedSuccessfully => '评论已删除';
	@override String get commentUpdatedSuccessfully => '评论已更新';
	@override String totalComments({required Object count}) => '评论 ${count} 条';
	@override String get writeYourCommentHere => '在此输入评论...';
	@override String get tmpNoReplies => '暂无回复';
	@override String get loadMore => '加载更多';
	@override String get noMoreDatas => '没有更多数据了';
	@override String get selectTranslationLanguage => '选择翻译语言';
	@override String get translate => '翻译';
	@override String get translateFailedPleaseTryAgainLater => '翻译失败，请稍后重试';
	@override String get translationResult => '翻译结果';
	@override String get justNow => '刚刚';
	@override String minutesAgo({required Object num}) => '${num}分钟前';
	@override String hoursAgo({required Object num}) => '${num}小时前';
	@override String daysAgo({required Object num}) => '${num}天前';
	@override String editedAt({required Object num}) => '${num}编辑';
	@override String get editComment => '编辑评论';
	@override String get commentUpdated => '评论已更新';
	@override String get replyComment => '回复评论';
	@override String get reply => '回复';
	@override String get edit => '编辑';
	@override String get unknownUser => '未知用户';
	@override String get me => '我';
	@override String get author => '作者';
	@override String get admin => '管理员';
	@override String viewReplies({required Object num}) => '查看回复 (${num})';
	@override String get hideReplies => '隐藏回复';
	@override String get confirmDelete => '确认删除';
	@override String get areYouSureYouWantToDeleteThisItem => '确定要删除这条记录吗？';
	@override String get tmpNoComments => '暂无评论';
	@override String get refresh => '刷新';
	@override String get back => '返回';
	@override String get tips => '提示';
	@override String get linkIsEmpty => '链接地址为空';
	@override String get linkCopiedToClipboard => '链接地址已复制到剪贴板';
	@override String get imageCopiedToClipboard => '图片已复制到剪贴板';
	@override String get copyImageFailed => '复制图片失败';
	@override String get mobileSaveImageIsUnderDevelopment => '移动端的保存图片功能还在开发中';
	@override String get imageSavedTo => '图片已保存到';
	@override String get saveImageFailed => '保存图片失败';
	@override String get close => '关闭';
	@override String get more => '更多';
	@override String get moreFeaturesToBeDeveloped => '更多功能待开发';
	@override String get all => '全部';
	@override String selectedRecords({required Object num}) => '已选择 ${num} 条记录';
	@override String get cancelSelectAll => '取消全选';
	@override String get selectAll => '全选';
	@override String get exitEditMode => '退出编辑模式';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '确定要删除选中的 ${num} 条记录吗？';
	@override String get searchHistoryRecords => '搜索历史记录...';
	@override String get settings => '设置';
	@override String get subscriptions => '订阅';
	@override String videoCount({required Object num}) => '${num} 个视频';
	@override String get share => '分享';
	@override String get areYouSureYouWantToShareThisPlaylist => '要分享这个播放列表吗?';
	@override String get editTitle => '编辑标题';
	@override String get editMode => '编辑模式';
	@override String get pleaseEnterNewTitle => '请输入新标题';
	@override String get createPlayList => '创建播放列表';
	@override String get create => '创建';
	@override String get checkNetworkSettings => '检查网络设置';
	@override String get general => '大众的';
	@override String get r18 => 'R18';
	@override String get sensitive => '敏感';
	@override String get year => '年份';
	@override String get month => '月份';
	@override String get tag => '标签';
	@override String get private => '私密';
	@override String get noTitle => '无标题';
	@override String get search => '搜索';
	@override String get noContent => '没有内容哦';
	@override String get recording => '记录中';
	@override String get paused => '已暂停';
	@override String get clear => '清除';
	@override String get user => '用户';
	@override String get post => '投稿';
	@override String get seconds => '秒';
	@override String get comingSoon => '敬请期待';
	@override String get confirm => '确认';
	@override String get hour => '时';
	@override String get minute => '分';
	@override String get clickToRefresh => '点击刷新';
	@override String get history => '历史记录';
	@override String get favorites => '最爱';
	@override String get friends => '好友';
	@override String get playList => '播放列表';
	@override String get checkLicense => '查看许可';
	@override String get logout => '退出登录';
	@override String get fensi => '粉丝';
	@override String get accept => '接受';
	@override String get reject => '拒绝';
	@override String get clearAllHistory => '清空所有历史记录';
	@override String get clearAllHistoryConfirm => '确定要清空所有历史记录吗？';
	@override String get followingList => '关注列表';
	@override String get followersList => '粉丝列表';
	@override String get followers => '粉丝';
	@override String get follows => '关注';
	@override String get fans => '粉丝';
	@override String get followsAndFans => '关注与粉丝';
	@override String get numViews => '观看次数';
	@override String get updatedAt => '更新时间';
	@override String get publishedAt => '发布时间';
	@override String get externalVideo => '站外视频';
	@override String get originalText => '原文';
	@override String get showOriginalText => '显示原始文本';
	@override String get showProcessedText => '显示处理后文本';
	@override String get preview => '预览';
	@override String get markdownSyntax => 'Markdown 语法';
	@override String get rules => '规则';
	@override String get agree => '同意';
	@override String get disagree => '不同意';
	@override String get agreeToRules => '同意规则';
	@override String get createPost => '创建投稿';
	@override String get title => '标题';
	@override String get enterTitle => '请输入标题';
	@override String get content => '内容';
	@override String get enterContent => '请输入内容';
	@override String get writeYourContentHere => '请输入内容...';
	@override String get tagBlacklist => '黑名单标签';
	@override String get noData => '没有数据';
	@override String get tagLimit => '标签上限';
	@override String get enableFloatingButtons => '启用浮动按钮';
	@override String get disableFloatingButtons => '禁用浮动按钮';
	@override String get enabledFloatingButtons => '已启用浮动按钮';
	@override String get disabledFloatingButtons => '已禁用浮动按钮';
	@override String get pendingCommentCount => '待审核评论';
	@override String joined({required Object str}) => '加入于 ${str}';
	@override String get download => '下载';
	@override String get selectQuality => '选择画质';
	@override String get selectDateRange => '选择日期范围';
	@override String get selectDateRangeHint => '选择日期范围，默认选择最近30天';
	@override String get clearDateRange => '清除日期范围';
	@override String get followSuccessClickAgainToSpecialFollow => '已成功关注，再次点击以特别关注';
	@override String get exitConfirmTip => '确定要退出吗？';
	@override String get error => '错误';
	@override String get taskRunning => '任务正在进行中，请稍后再试。';
	@override String get operationCancelled => '操作已取消。';
	@override String get unsavedChanges => '您有未保存的更改';
	@override String get specialFollowsManagementTip => '拖动可重新排序 • 向左滑动可移除';
	@override String get specialFollowsManagement => '特别关注管理';
	@override late final _TranslationsCommonPaginationZhCn pagination = _TranslationsCommonPaginationZhCn._(_root);
	@override String get notice => '通知';
	@override String get detail => '详情';
	@override String get parseExceptionDestopHint => ' - 桌面端用户可以在设置中配置代理';
	@override String get iwaraTags => 'Iwara 标签';
	@override String get likeThisVideo => '喜欢这个视频的人';
	@override String get operation => '操作';
}

// Path: auth
class _TranslationsAuthZhCn implements TranslationsAuthEn {
	_TranslationsAuthZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get tagLimit => '标签上限';
	@override String get login => '登录';
	@override String get logout => '退出登录';
	@override String get email => '邮箱';
	@override String get password => '密码';
	@override String get loginOrRegister => '登录 / 注册';
	@override String get register => '注册';
	@override String get pleaseEnterEmail => '请输入邮箱';
	@override String get pleaseEnterPassword => '请输入密码';
	@override String get passwordMustBeAtLeast6Characters => '密码至少需要6位';
	@override String get pleaseEnterCaptcha => '请输入验证码';
	@override String get captcha => '验证码';
	@override String get refreshCaptcha => '刷新验证码';
	@override String get captchaNotLoaded => '无法加载验证码';
	@override String get loginSuccess => '登录成功';
	@override String get emailVerificationSent => '邮箱指令已发送';
	@override String get notLoggedIn => '未登录';
	@override String get clickToLogin => '点击此处登录';
	@override String get logoutConfirmation => '你确定要退出登录吗？';
	@override String get logoutSuccess => '退出登录成功';
	@override String get logoutFailed => '退出登录失败';
	@override String get usernameOrEmail => '用户名或邮箱';
	@override String get pleaseEnterUsernameOrEmail => '请输入用户名或邮箱';
	@override String get username => '用户名或邮箱';
	@override String get pleaseEnterUsername => '请输入用户名或邮箱';
	@override String get rememberMe => '记住账号和密码';
}

// Path: errors
class _TranslationsErrorsZhCn implements TranslationsErrorsEn {
	_TranslationsErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get error => '错误';
	@override String get required => '此项必填';
	@override String get invalidEmail => '邮箱格式不正确';
	@override String get networkError => '网络错误，请重试';
	@override String get errorWhileFetching => '获取信息失败';
	@override String get commentCanNotBeEmpty => '评论内容不能为空';
	@override String get errorWhileFetchingReplies => '获取回复时出错，请检查网络连接';
	@override String get canNotFindCommentController => '无法找到评论控制器';
	@override String get errorWhileLoadingGallery => '在加载图库时出现了错误';
	@override String get howCouldThereBeNoDataItCantBePossible => '啊？怎么会没有数据呢？出错了吧 :<';
	@override String unsupportedImageFormat({required Object str}) => '不支持的图片格式: ${str}';
	@override String get invalidGalleryId => '无效的图库ID';
	@override String get translationFailedPleaseTryAgainLater => '翻译失败，请稍后重试';
	@override String get errorOccurred => '发生错误，请稍后再试。';
	@override String get errorOccurredWhileProcessingRequest => '处理请求时出错';
	@override String get errorWhileFetchingDatas => '获取数据时出错，请稍后再试';
	@override String get serviceNotInitialized => '服务未初始化';
	@override String get unknownType => '未知类型';
	@override String errorWhileOpeningLink({required Object link}) => '无法打开链接: ${link}';
	@override String get invalidUrl => '无效的URL';
	@override String get failedToOperate => '操作失败';
	@override String get permissionDenied => '权限不足';
	@override String get youDoNotHavePermissionToAccessThisResource => '您没有权限访问此资源';
	@override String get loginFailed => '登录失败';
	@override String get unknownError => '未知错误';
	@override String get sessionExpired => '会话已过期';
	@override String get failedToFetchCaptcha => '获取验证码失败';
	@override String get emailAlreadyExists => '邮箱已存在';
	@override String get invalidCaptcha => '无效的验证码';
	@override String get registerFailed => '注册失败';
	@override String get failedToFetchComments => '获取评论失败';
	@override String get failedToFetchImageDetail => '获取图库详情失败';
	@override String get failedToFetchImageList => '获取图库列表失败';
	@override String get failedToFetchData => '获取数据失败';
	@override String get invalidParameter => '无效的参数';
	@override String get pleaseLoginFirst => '请先登录';
	@override String get errorWhileLoadingPost => '载入投稿内容时出错';
	@override String get errorWhileLoadingPostDetail => '载入投稿详情时出错';
	@override String get invalidPostId => '无效的投稿ID';
	@override String get forceUpdateNotPermittedToGoBack => '目前处于强制更新状态，无法返回';
	@override String get pleaseLoginAgain => '请重新登录';
	@override String get invalidLogin => '登录失败，请检查邮箱和密码';
	@override String get tooManyRequests => '请求过多，请稍后再试';
	@override String exceedsMaxLength({required Object max}) => '超出最大长度: ${max} 个字符';
	@override String get contentCanNotBeEmpty => '内容不能为空';
	@override String get titleCanNotBeEmpty => '标题不能为空';
	@override String get tooManyRequestsPleaseTryAgainLaterText => '请求过多，请稍后再试，剩余时间';
	@override String remainingHours({required Object num}) => '${num}小时';
	@override String remainingMinutes({required Object num}) => '${num}分钟';
	@override String remainingSeconds({required Object num}) => '${num}秒';
	@override String tagLimitExceeded({required Object limit}) => '标签上限超出，上限: ${limit}';
	@override String get failedToRefresh => '更新失败';
	@override String get noPermission => '权限不足';
	@override String get resourceNotFound => '资源不存在';
	@override String get failedToSaveCredentials => '无法安全保存登录信息';
	@override String get failedToLoadSavedCredentials => '加载保存的登录信息失败';
	@override String specialFollowLimitReached({required Object cnt}) => '特别关注上限超出，上限: ${cnt}，请于关注列表页中调整';
	@override String get notFound => '内容不存在或已被删除';
	@override late final _TranslationsErrorsNetworkZhCn network = _TranslationsErrorsNetworkZhCn._(_root);
}

// Path: friends
class _TranslationsFriendsZhCn implements TranslationsFriendsEn {
	_TranslationsFriendsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => '点击恢复好友';
	@override String get friendsList => '好友列表';
	@override String get friendRequests => '好友请求';
	@override String get friendRequestsList => '好友请求列表';
	@override String get removingFriend => '正在解除好友关系...';
	@override String get failedToRemoveFriend => '解除好友关系失败';
	@override String get cancelingRequest => '正在取消好友申请...';
	@override String get failedToCancelRequest => '取消好友申请失败';
}

// Path: authorProfile
class _TranslationsAuthorProfileZhCn implements TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => '没有更多数据了';
	@override String get userProfile => '用户资料';
}

// Path: favorites
class _TranslationsFavoritesZhCn implements TranslationsFavoritesEn {
	_TranslationsFavoritesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => '点击恢复最爱';
	@override String get myFavorites => '我的最爱';
}

// Path: galleryDetail
class _TranslationsGalleryDetailZhCn implements TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get galleryDetail => '图库详情';
	@override String get viewGalleryDetail => '查看图库详情';
	@override String get copyLink => '复制链接地址';
	@override String get copyImage => '复制图片';
	@override String get saveAs => '另存为';
	@override String get saveToAlbum => '保存到相册';
	@override String get publishedAt => '发布时间';
	@override String get viewsCount => '观看次数';
	@override String get imageLibraryFunctionIntroduction => '图库功能介绍';
	@override String get rightClickToSaveSingleImage => '右键保存单张图片';
	@override String get batchSave => '批量保存';
	@override String get keyboardLeftAndRightToSwitch => '键盘的左右控制切换';
	@override String get keyboardUpAndDownToZoom => '键盘的上下控制缩放';
	@override String get mouseWheelToSwitch => '鼠标的滚轮滑动控制切换';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + 鼠标滚轮控制缩放';
	@override String get moreFeaturesToBeDiscovered => '更多功能待发现...';
	@override String get authorOtherGalleries => '作者的其他图库';
	@override String get relatedGalleries => '相关图库';
	@override String get clickLeftAndRightEdgeToSwitchImage => '点击左右边缘以切换图片';
}

// Path: playList
class _TranslationsPlayListZhCn implements TranslationsPlayListEn {
	_TranslationsPlayListZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => '我的播放列表';
	@override String get friendlyTips => '友情提示';
	@override String get dearUser => '亲爱的用户';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'iwara的播放列表系统目前还不太完善';
	@override String get notSupportSetCover => '不支持设置封面';
	@override String get notSupportDeleteList => '不能删除列表';
	@override String get notSupportSetPrivate => '无法设为私密';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => '没错...创建的列表会一直存在且对所有人可见';
	@override String get smallSuggestion => '小建议';
	@override String get useLikeToCollectContent => '如果您比较注重隐私，建议使用"点赞"功能来收藏内容';
	@override String get welcomeToDiscussOnGitHub => '如果你有其他的建议或想法，欢迎来 GitHub 讨论!';
	@override String get iUnderstand => '明白了';
	@override String get searchPlaylists => '搜索播放列表...';
	@override String get newPlaylistName => '新播放列表名称';
	@override String get createNewPlaylist => '创建新播放列表';
	@override String get videos => '视频';
}

// Path: search
class _TranslationsSearchZhCn implements TranslationsSearchEn {
	_TranslationsSearchZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => '搜索范围';
	@override String get searchTags => '搜索标签...';
	@override String get contentRating => '内容分级';
	@override String get removeTag => '移除标签';
	@override String get pleaseEnterSearchContent => '请输入搜索内容';
	@override String get searchHistory => '搜索历史';
	@override String get searchSuggestion => '搜索建议';
	@override String get usedTimes => '使用次数';
	@override String get lastUsed => '最后使用';
	@override String get noSearchHistoryRecords => '没有搜索历史';
	@override String notSupportCurrentSearchType({required Object searchType}) => '暂未实现当前搜索类型 ${searchType}，敬请期待';
	@override String get searchResult => '搜索结果';
	@override String unsupportedSearchType({required Object searchType}) => '不支持的搜索类型: ${searchType}';
	@override String get googleSearch => '谷歌搜索';
	@override String googleSearchHint({required Object webName}) => '${webName} 的搜索功能不好用？尝试谷歌搜索！';
	@override String get googleSearchDescription => '借助谷歌搜索的 :site 搜索运算符，你可以通过外部引擎来对站内的内容进行检索，此功能在搜索 视频、图库、播放列表、用户 时非常有用。';
	@override String get googleSearchKeywordsHint => '输入要搜索的关键词';
	@override String get openLinkJump => '打开链接跳转';
	@override String get googleSearchButton => '谷歌搜索';
	@override String get pleaseEnterSearchKeywords => '请输入搜索关键词';
	@override String get googleSearchQueryCopied => '搜索语句已复制到剪贴板';
	@override String googleSearchBrowserOpenFailed({required Object error}) => '无法打开浏览器: ${error}';
}

// Path: mediaList
class _TranslationsMediaListZhCn implements TranslationsMediaListEn {
	_TranslationsMediaListZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => '个人简介';
}

// Path: settings
class _TranslationsSettingsZhCn implements TranslationsSettingsEn {
	_TranslationsSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => '列表显示模式';
	@override String get useTraditionalPaginationMode => '使用传统分页模式';
	@override String get useTraditionalPaginationModeDesc => '开启后列表将使用传统分页模式，关闭则使用瀑布流模式';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => '显示底部进度条';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => '此配置决定是否在工具栏隐藏时显示底部进度条';
	@override String get basicSettings => '基础设置';
	@override String get personalizedSettings => '个性化设置';
	@override String get otherSettings => '其他设置';
	@override String get searchConfig => '搜索配置';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => '此配置决定当你之后播放视频时是否会沿用之前的配置。';
	@override String get playControl => '播放控制';
	@override String get fastForwardTime => '快进时间';
	@override String get fastForwardTimeMustBeAPositiveInteger => '快进时间必须是一个正整数。';
	@override String get rewindTime => '后退时间';
	@override String get rewindTimeMustBeAPositiveInteger => '后退时间必须是一个正整数。';
	@override String get longPressPlaybackSpeed => '长按播放倍速';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => '长按播放倍速必须是一个正数。';
	@override String get repeat => '循环播放';
	@override String get renderVerticalVideoInVerticalScreen => '全屏播放时以竖屏模式渲染竖屏视频';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => '此配置决定当你在全屏播放时是否以竖屏模式渲染竖屏视频。';
	@override String get rememberVolume => '记住音量';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => '此配置决定当你之后播放视频时是否会沿用之前的音量设置。';
	@override String get rememberBrightness => '记住亮度';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => '此配置决定当你之后播放视频时是否会沿用之前的亮度设置。';
	@override String get playControlArea => '播放控制区域';
	@override String get leftAndRightControlAreaWidth => '左右控制区域宽度';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => '此配置决定播放器左右两侧的控制区域宽度。';
	@override String get proxyAddressCannotBeEmpty => '代理地址不能为空。';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => '无效的代理地址格式。请使用 IP:端口 或 域名:端口 格式。';
	@override String get proxyNormalWork => '代理正常工作。';
	@override String testProxyFailedWithStatusCode({required Object code}) => '代理请求失败，状态码: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => '代理请求出错: ${exception}';
	@override String get proxyConfig => '代理配置';
	@override String get thisIsHttpProxyAddress => '此处为http代理地址';
	@override String get checkProxy => '检查代理';
	@override String get proxyAddress => '代理地址';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => '请输入代理服务器的URL，例如 127.0.0.1:8080';
	@override String get enableProxy => '启用代理';
	@override String get left => '左侧';
	@override String get middle => '中间';
	@override String get right => '右侧';
	@override String get playerSettings => '播放器设置';
	@override String get networkSettings => '网络设置';
	@override String get customizeYourPlaybackExperience => '自定义您的播放体验';
	@override String get chooseYourFavoriteAppAppearance => '选择您喜欢的应用外观';
	@override String get configureYourProxyServer => '配置您的代理服务器';
	@override String get settings => '设置';
	@override String get themeSettings => '主题设置';
	@override String get followSystem => '跟随系统';
	@override String get lightMode => '浅色模式';
	@override String get darkMode => '深色模式';
	@override String get presetTheme => '预设主题';
	@override String get basicTheme => '基础主题';
	@override String get needRestartToApply => '需要重启应用以应用设置';
	@override String get themeNeedRestartDescription => '主题设置需要重启应用以应用设置';
	@override String get about => '关于';
	@override String get currentVersion => '当前版本';
	@override String get latestVersion => '最新版本';
	@override String get checkForUpdates => '检查更新';
	@override String get update => '更新';
	@override String get newVersionAvailable => '发现新版本';
	@override String get projectHome => '开源地址';
	@override String get release => '版本发布';
	@override String get issueReport => '问题反馈';
	@override String get openSourceLicense => '开源许可';
	@override String get checkForUpdatesFailed => '检查更新失败，请稍后重试';
	@override String get autoCheckUpdate => '自动检查更新';
	@override String get updateContent => '更新内容：';
	@override String get releaseDate => '发布日期';
	@override String get ignoreThisVersion => '忽略此版本';
	@override String get minVersionUpdateRequired => '当前版本过低，请尽快更新';
	@override String get forceUpdateTip => '此版本为强制更新，请尽快更新到最新版本';
	@override String get viewChangelog => '查看更新日志';
	@override String get alreadyLatestVersion => '已是最新版本';
	@override String get appSettings => '应用设置';
	@override String get configureYourAppSettings => '配置您的应用程序设置';
	@override String get history => '历史记录';
	@override String get autoRecordHistory => '自动记录历史记录';
	@override String get autoRecordHistoryDesc => '自动记录您观看过的视频和图库等信息';
	@override String get showUnprocessedMarkdownText => '显示未处理文本';
	@override String get showUnprocessedMarkdownTextDesc => '显示Markdown的原始文本';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => '隐私模式';
	@override String get activeBackgroundPrivacyModeDesc => '禁止截图、后台运行时隐藏画面...';
	@override String get privacy => '隐私';
	@override String get forum => '论坛';
	@override String get disableForumReplyQuote => '禁用论坛回复引用';
	@override String get disableForumReplyQuoteDesc => '禁用论坛回复时携带被回复楼层信息';
	@override String get theaterMode => '剧院模式';
	@override String get theaterModeDesc => '开启后，播放器背景会被设置为视频封面的模糊版本';
	@override String get appLinks => '应用链接';
	@override String get defaultBrowser => '默认浏览';
	@override String get defaultBrowserDesc => '请在系统设置中打开默认链接配置项，并添加网站链接';
	@override String get themeMode => '主题模式';
	@override String get themeModeDesc => '此配置决定应用的主题模式';
	@override String get dynamicColor => '动态颜色';
	@override String get dynamicColorDesc => '此配置决定应用是否使用动态颜色';
	@override String get useDynamicColor => '使用动态颜色';
	@override String get useDynamicColorDesc => '此配置决定应用是否使用动态颜色';
	@override String get presetColors => '预设颜色';
	@override String get customColors => '自定义颜色';
	@override String get pickColor => '选择颜色';
	@override String get cancel => '取消';
	@override String get confirm => '确认';
	@override String get noCustomColors => '没有自定义颜色';
	@override String get recordAndRestorePlaybackProgress => '记录和恢复播放进度';
	@override String get signature => '小尾巴';
	@override String get enableSignature => '小尾巴启用';
	@override String get enableSignatureDesc => '此配置决定回复时是否自动添加小尾巴';
	@override String get enterSignature => '输入小尾巴';
	@override String get editSignature => '编辑小尾巴';
	@override String get signatureContent => '小尾巴内容';
	@override String get exportConfig => '导出应用配置';
	@override String get exportConfigDesc => '将应用配置导出为文件（不包含下载记录）';
	@override String get importConfig => '导入应用配置';
	@override String get importConfigDesc => '从文件导入应用配置';
	@override String get exportConfigSuccess => '配置导出成功！';
	@override String get exportConfigFailed => '配置导出失败';
	@override String get importConfigSuccess => '配置导入成功！';
	@override String get importConfigFailed => '配置导入失败';
	@override String get historyUpdateLogs => '历代更新日志';
	@override String get noUpdateLogs => '未获取到更新日志';
	@override String get versionLabel => '版本: {version}';
	@override String get releaseDateLabel => '发布日期: {date}';
	@override String get noChanges => '暂无更新内容';
	@override String get interaction => '交互';
	@override String get enableVibration => '启用震动';
	@override String get enableVibrationDesc => '启用应用交互时的震动反馈';
	@override String get defaultKeepVideoToolbarVisible => '保持工具栏常驻';
	@override String get defaultKeepVideoToolbarVisibleDesc => '此设置决定首次进入视频页面时是否保持工具栏常驻显示。';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => '移动端开启剧院模式可能会造成性能问题，可酌情开启。';
	@override String get lockButtonPosition => '锁定按钮位置';
	@override String get lockButtonPositionBothSides => '两侧显示';
	@override String get lockButtonPositionLeftSide => '仅左侧显示';
	@override String get lockButtonPositionRightSide => '仅右侧显示';
	@override String get jumpLink => '跳转链接';
	@override String get language => '语言';
	@override String get languageChanged => '语言设置已更改，请重启应用以生效。';
	@override String get gestureControl => '手势控制';
	@override String get leftDoubleTapRewind => '左侧双击后退';
	@override String get rightDoubleTapFastForward => '右侧双击快进';
	@override String get doubleTapPause => '双击暂停';
	@override String get leftVerticalSwipeVolume => '左侧上下滑动调整音量（进入新页面时生效）';
	@override String get rightVerticalSwipeBrightness => '右侧上下滑动调整亮度（进入新页面时生效）';
	@override String get longPressFastForward => '长按快进';
	@override String get enableMouseHoverShowToolbar => '鼠标悬浮时显示工具栏';
	@override String get enableMouseHoverShowToolbarInfo => '开启后，当鼠标悬浮在播放器上移动时会自动显示工具栏，停止移动3秒后自动隐藏';
	@override String get audioVideoConfig => '音视频配置';
	@override String get expandBuffer => '扩大缓冲区';
	@override String get expandBufferInfo => '开启后缓冲区增大，加载时间变长但播放更流畅';
	@override String get videoSyncMode => '视频同步模式';
	@override String get videoSyncModeSubtitle => '音视频同步策略';
	@override String get hardwareDecodingMode => '硬解模式';
	@override String get hardwareDecodingModeSubtitle => '硬件解码设置';
	@override String get enableHardwareAcceleration => '启用硬件加速';
	@override String get enableHardwareAccelerationInfo => '开启硬件加速可以提高解码性能，但某些设备可能不兼容';
	@override String get useOpenSLESAudioOutput => '使用OpenSLES音频输出';
	@override String get useOpenSLESAudioOutputInfo => '使用低延迟音频输出，可能提高音频性能';
	@override String get videoSyncAudio => '音频同步';
	@override String get videoSyncDisplayResample => '显示重采样';
	@override String get videoSyncDisplayResampleVdrop => '显示重采样(丢帧)';
	@override String get videoSyncDisplayResampleDesync => '显示重采样(去同步)';
	@override String get videoSyncDisplayTempo => '显示节拍';
	@override String get videoSyncDisplayVdrop => '显示丢视频帧';
	@override String get videoSyncDisplayAdrop => '显示丢音频帧';
	@override String get videoSyncDisplayDesync => '显示去同步';
	@override String get videoSyncDesync => '去同步';
	@override String get hardwareDecodingAuto => '自动';
	@override String get hardwareDecodingAutoCopy => '自动复制';
	@override String get hardwareDecodingAutoSafe => '自动安全';
	@override String get hardwareDecodingNo => '禁用';
	@override String get hardwareDecodingYes => '强制启用';
	@override late final _TranslationsSettingsDownloadSettingsZhCn downloadSettings = _TranslationsSettingsDownloadSettingsZhCn._(_root);
}

// Path: oreno3d
class _TranslationsOreno3dZhCn implements TranslationsOreno3dEn {
	_TranslationsOreno3dZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => '标签';
	@override String get characters => '角色';
	@override String get origin => '原作';
	@override String get thirdPartyTagsExplanation => '此处显示的**标签**、**角色**和**原作**信息来自第三方站点 **Oreno3D**，仅供参考。\n\n由于此信息来源只有日文，目前缺乏国际化适配。\n\n如果你有兴趣参与国际化建设，欢迎访问相关仓库贡献你的力量！';
	@override late final _TranslationsOreno3dSortTypesZhCn sortTypes = _TranslationsOreno3dSortTypesZhCn._(_root);
	@override late final _TranslationsOreno3dErrorsZhCn errors = _TranslationsOreno3dErrorsZhCn._(_root);
	@override late final _TranslationsOreno3dLoadingZhCn loading = _TranslationsOreno3dLoadingZhCn._(_root);
	@override late final _TranslationsOreno3dMessagesZhCn messages = _TranslationsOreno3dMessagesZhCn._(_root);
}

// Path: signIn
class _TranslationsSignInZhCn implements TranslationsSignInEn {
	_TranslationsSignInZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => '请先登录';
	@override String get alreadySignedInToday => '您今天已经签到过了！';
	@override String get youDidNotStickToTheSignIn => '您未能坚持签到。';
	@override String get signInSuccess => '签到成功！';
	@override String get signInFailed => '签到失败，请稍后再试';
	@override String get consecutiveSignIns => '连续签到天数';
	@override String get failureReason => '未能坚持签到的原因';
	@override String get selectDateRange => '选择日期范围';
	@override String get startDate => '开始日期';
	@override String get endDate => '结束日期';
	@override String get invalidDate => '日期格式错误';
	@override String get invalidDateRange => '日期范围无效';
	@override String get errorFormatText => '日期格式错误';
	@override String get errorInvalidText => '日期范围无效';
	@override String get errorInvalidRangeText => '日期范围无效';
	@override String get dateRangeCantBeMoreThanOneYear => '日期范围不能超过1年';
	@override String get signIn => '签到';
	@override String get signInRecord => '签到记录';
	@override String get totalSignIns => '总成功签到';
	@override String get pleaseSelectSignInStatus => '请选择签到状态';
}

// Path: subscriptions
class _TranslationsSubscriptionsZhCn implements TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => '请登录以查看您的订阅内容。';
	@override String get selectUser => '选择用户';
	@override String get noSubscribedUsers => '暂无已订阅的用户';
}

// Path: videoDetail
class _TranslationsVideoDetailZhCn implements TranslationsVideoDetailEn {
	_TranslationsVideoDetailZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pipMode => '画中画模式';
	@override String resumeFromLastPosition({required Object position}) => '从上次播放位置继续播放: ${position}';
	@override String get videoIdIsEmpty => '视频ID为空';
	@override String get videoInfoIsEmpty => '视频信息为空';
	@override String get thisIsAPrivateVideo => '这是一个私密视频';
	@override String get getVideoInfoFailed => '获取视频信息失败，请稍后再试';
	@override String get noVideoSourceFound => '未找到对应的视频源';
	@override String tagCopiedToClipboard({required Object tagId}) => '标签 "${tagId}" 已复制到剪贴板';
	@override String get errorLoadingVideo => '在加载视频时出现了错误';
	@override String get play => '播放';
	@override String get pause => '暂停';
	@override String get exitAppFullscreen => '退出应用全屏';
	@override String get enterAppFullscreen => '应用全屏';
	@override String get exitSystemFullscreen => '退出系统全屏';
	@override String get enterSystemFullscreen => '系统全屏';
	@override String get seekTo => '跳转到指定时间';
	@override String get switchResolution => '切换分辨率';
	@override String get switchPlaybackSpeed => '切换播放倍速';
	@override String rewindSeconds({required Object num}) => '后退${num}秒';
	@override String fastForwardSeconds({required Object num}) => '快进${num}秒';
	@override String playbackSpeedIng({required Object rate}) => '正在以${rate}倍速播放';
	@override String get brightness => '亮度';
	@override String get brightnessLowest => '亮度已最低';
	@override String get volume => '音量';
	@override String get volumeMuted => '音量已静音';
	@override String get home => '主页';
	@override String get videoPlayer => '视频播放器';
	@override String get videoPlayerInfo => '播放器信息';
	@override String get moreSettings => '更多设置';
	@override String get videoPlayerFeatureInfo => '播放器功能介绍';
	@override String get autoRewind => '自动重播';
	@override String get rewindAndFastForward => '左右两侧双击快进或后退';
	@override String get volumeAndBrightness => '左右两侧垂直滑动调整音量、亮度';
	@override String get centerAreaDoubleTapPauseOrPlay => '中心区域双击暂停或播放';
	@override String get showVerticalVideoInFullScreen => '在全屏时可以以竖屏方式显示竖屏视频';
	@override String get keepLastVolumeAndBrightness => '保持上次调整的音量、亮度';
	@override String get setProxy => '设置代理';
	@override String get moreFeaturesToBeDiscovered => '更多功能待发现...';
	@override String get videoPlayerSettings => '播放器设置';
	@override String commentCount({required Object num}) => '评论 ${num} 条';
	@override String get writeYourCommentHere => '写下你的评论...';
	@override String get authorOtherVideos => '作者的其他视频';
	@override String get relatedVideos => '相关视频';
	@override String get privateVideo => '这是一个私密视频';
	@override String get externalVideo => '这是一个站外视频';
	@override String get openInBrowser => '在浏览器中打开';
	@override String get resourceDeleted => '这个视频貌似被删除了 :/';
	@override String get noDownloadUrl => '没有下载链接';
	@override String get startDownloading => '开始下载';
	@override String get downloadFailed => '下载失败，请稍后再试';
	@override String get downloadSuccess => '下载成功';
	@override String get download => '下载';
	@override String get downloadManager => '下载管理';
	@override String get videoLoadError => '视频加载错误';
	@override String get resourceNotFound => '资源未找到';
	@override String get authorNoOtherVideos => '作者暂无其他视频';
	@override String get noRelatedVideos => '暂无相关视频';
}

// Path: share
class _TranslationsShareZhCn implements TranslationsShareEn {
	_TranslationsShareZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => '分享播放列表';
	@override String get wowDidYouSeeThis => '哇哦，你看过这个吗？';
	@override String get nameIs => '名字叫做';
	@override String get clickLinkToView => '点击链接查看';
	@override String get iReallyLikeThis => '我真的是太喜欢这个了，你也来看看吧！';
	@override String get shareFailed => '分享失败，请稍后再试';
	@override String get share => '分享';
	@override String get shareAsImage => '分享为图片';
	@override String get shareAsText => '分享为文本';
	@override String get shareAsImageDesc => '将视频封面分享为图片';
	@override String get shareAsTextDesc => '将视频详情分享为文本';
	@override String get shareAsImageFailed => '分享视频封面为图片失败，请稍后再试';
	@override String get shareAsTextFailed => '分享视频详情为文本失败，请稍后再试';
	@override String get shareVideo => '分享视频';
	@override String get authorIs => '作者是';
	@override String get shareGallery => '分享图库';
	@override String get galleryTitleIs => '图库名字叫做';
	@override String get galleryAuthorIs => '图库作者是';
	@override String get shareUser => '分享用户';
	@override String get userNameIs => '用户名字叫做';
	@override String get userAuthorIs => '用户作者是';
	@override String get comments => '评论';
	@override String get shareThread => '分享帖子';
	@override String get views => '浏览';
	@override String get sharePost => '分享投稿';
	@override String get postTitleIs => '投稿名字叫做';
	@override String get postAuthorIs => '投稿作者是';
}

// Path: markdown
class _TranslationsMarkdownZhCn implements TranslationsMarkdownEn {
	_TranslationsMarkdownZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Markdown 语法';
	@override String get iwaraSpecialMarkdownSyntax => 'Iwara 专用语法';
	@override String get internalLink => '站内链接';
	@override String get supportAutoConvertLinkBelow => '支持自动转换以下类型的链接：';
	@override String get convertLinkExample => '🎬 视频链接\n🖼️ 图片链接\n👤 用户链接\n📌 论坛链接\n🎵 播放列表链接\n💬 投稿链接';
	@override String get mentionUser => '提及用户';
	@override String get mentionUserDescription => '输入@后跟用户名，将自动转换为用户链接';
	@override String get markdownBasicSyntax => 'Markdown 基本语法';
	@override String get paragraphAndLineBreak => '段落与换行';
	@override String get paragraphAndLineBreakDescription => '段落之间空一行，行末加两个空格实现换行';
	@override String get paragraphAndLineBreakSyntax => '这是第一段文字\n\n这是第二段文字\n这一行后面加两个空格  \n就能换行了';
	@override String get textStyle => '文本样式';
	@override String get textStyleDescription => '使用特殊符号包围文本来改变样式';
	@override String get textStyleSyntax => '**粗体文本**\n*斜体文本*\n~~删除线文本~~\n`代码文本`';
	@override String get quote => '引用';
	@override String get quoteDescription => '使用 > 符号创建引用，多个 > 创建多级引用';
	@override String get quoteSyntax => '> 这是一级引用\n>> 这是二级引用';
	@override String get list => '列表';
	@override String get listDescription => '使用数字+点号创建有序列表，使用 - 创建无序列表';
	@override String get listSyntax => '1. 第一项\n2. 第二项\n\n- 无序项\n  - 子项\n  - 另一个子项';
	@override String get linkAndImage => '链接与图片';
	@override String get linkAndImageDescription => '链接格式：[文字](URL)\n图片格式：![描述](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[链接文字](${link})\n![图片描述](${imgUrl})';
	@override String get title => '标题';
	@override String get titleDescription => '使用 # 号创建标题，数量表示级别';
	@override String get titleSyntax => '# 一级标题\n## 二级标题\n### 三级标题';
	@override String get separator => '分隔线';
	@override String get separatorDescription => '使用三个或更多 - 号创建分隔线';
	@override String get separatorSyntax => '---';
	@override String get syntax => '语法';
}

// Path: forum
class _TranslationsForumZhCn implements TranslationsForumEn {
	_TranslationsForumZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get recent => '最近';
	@override String get category => '分类';
	@override String get lastReply => '最后回复';
	@override late final _TranslationsForumErrorsZhCn errors = _TranslationsForumErrorsZhCn._(_root);
	@override String get createPost => '创建帖子';
	@override String get title => '标题';
	@override String get enterTitle => '输入标题';
	@override String get content => '内容';
	@override String get enterContent => '输入内容';
	@override String get writeYourContentHere => '在此输入内容...';
	@override String get posts => '帖子';
	@override String get threads => '主题';
	@override String get forum => '论坛';
	@override String get createThread => '创建主题';
	@override String get selectCategory => '选择分类';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => '冷却剩余时间 ${minutes} 分 ${seconds} 秒';
	@override late final _TranslationsForumGroupsZhCn groups = _TranslationsForumGroupsZhCn._(_root);
	@override late final _TranslationsForumLeafNamesZhCn leafNames = _TranslationsForumLeafNamesZhCn._(_root);
	@override late final _TranslationsForumLeafDescriptionsZhCn leafDescriptions = _TranslationsForumLeafDescriptionsZhCn._(_root);
	@override String get reply => '回覆';
	@override String get pendingReview => '审核中';
	@override String get editedAt => '编辑时间';
	@override String get copySuccess => '已复制到剪贴板';
	@override String copySuccessForMessage({required Object str}) => '已复制到剪贴板: ${str}';
	@override String get editReply => '编辑回覆';
	@override String get editTitle => '编辑标题';
	@override String get submit => '提交';
}

// Path: notifications
class _TranslationsNotificationsZhCn implements TranslationsNotificationsEn {
	_TranslationsNotificationsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsZhCn errors = _TranslationsNotificationsErrorsZhCn._(_root);
	@override String get notifications => '通知';
	@override String get video => '视频';
	@override String get profile => '个人主页';
	@override String get postedNewComment => '发表了评论';
	@override String get inYour => '在您的';
	@override String get copyInfoToClipboard => '复制通知信息到剪贴簿';
	@override String get copySuccess => '已复制到剪贴板';
	@override String copySuccessForMessage({required Object str}) => '已复制到剪贴板: ${str}';
	@override String get markAllAsRead => '全部标记已读';
	@override String get markAllAsReadSuccess => '所有通知已标记为已读';
	@override String get markAllAsReadFailed => '全部标记已读失败';
	@override String get markSelectedAsRead => '标记选中项为已读';
	@override String get markSelectedAsReadSuccess => '选中的通知已标记为已读';
	@override String get markSelectedAsReadFailed => '标记选中项为已读失败';
	@override String get markAsRead => '标记已读';
	@override String get markAsReadSuccess => '已标记为已读';
	@override String get markAsReadFailed => '标记已读失败';
	@override String get notificationTypeHelp => '通知类型帮助';
	@override String get dueToLackOfNotificationTypeDetails => '通知类型的详细信息不足，目前支持的类型可能没有覆盖到您当前收到的消息';
	@override String get helpUsImproveNotificationTypeSupport => '如果您愿意帮助我们完善通知类型的支持';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 复制通知信息\n2. 🐞 前往项目仓库提交 issue\n\n⚠️ 注意：通知信息可能包含个人隐私，如果你不想公开，也可以通过邮件发送给项目作者。';
	@override String get goToRepository => '前往项目仓库';
	@override String get copy => '复制';
	@override String get commentApproved => '评论已通过审核';
	@override String get repliedYourProfileComment => '回复了您的个人主页评论';
	@override String get repliedYourVideoComment => '回复了您的视频评论';
	@override String get kReplied => '回复了您在';
	@override String get kCommented => '评论了您的';
	@override String get kVideo => '视频';
	@override String get kGallery => '图库';
	@override String get kProfile => '主页';
	@override String get kThread => '主题';
	@override String get kPost => '投稿';
	@override String get kCommentSection => '下的评论';
	@override String get kApprovedComment => '评论审核通过';
	@override String get kApprovedVideo => '视频审核通过';
	@override String get kApprovedGallery => '图库审核通过';
	@override String get kApprovedThread => '帖子审核通过';
	@override String get kApprovedPost => '投稿审核通过';
	@override String get kUnknownType => '未知通知类型';
}

// Path: conversation
class _TranslationsConversationZhCn implements TranslationsConversationEn {
	_TranslationsConversationZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsZhCn errors = _TranslationsConversationErrorsZhCn._(_root);
	@override String get conversation => '会话';
	@override String get startConversation => '发起会话';
	@override String get noConversation => '暂无会话';
	@override String get selectFromLeftListAndStartConversation => '从左侧的会话列表选择一个对话开始聊天';
	@override String get title => '标题';
	@override String get body => '内容';
	@override String get selectAUser => '选择用户';
	@override String get searchUsers => '搜索用户...';
	@override String get tmpNoConversions => '暂无会话';
	@override String get deleteThisMessage => '删除此消息';
	@override String get deleteThisMessageSubtitle => '此操作不可撤销';
	@override String get writeMessageHere => '在此处输入消息';
	@override String get sendMessage => '发送消息';
}

// Path: splash
class _TranslationsSplashZhCn implements TranslationsSplashEn {
	_TranslationsSplashZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsZhCn errors = _TranslationsSplashErrorsZhCn._(_root);
	@override String get preparing => '准备中...';
	@override String get initializing => '初始化中...';
	@override String get loading => '加载中...';
	@override String get ready => '准备完成';
	@override String get initializingMessageService => '初始化消息服务中...';
}

// Path: download
class _TranslationsDownloadZhCn implements TranslationsDownloadEn {
	_TranslationsDownloadZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsZhCn errors = _TranslationsDownloadErrorsZhCn._(_root);
	@override String get downloadList => '下载列表';
	@override String get download => '下载';
	@override String get forceDeleteTask => '强制删除任务';
	@override String get startDownloading => '开始下载...';
	@override String get clearAllFailedTasks => '清除全部失败任务';
	@override String get clearAllFailedTasksConfirmation => '确定要清除所有失败的下载任务吗？\n这些任务的文件也会被删除。';
	@override String get clearAllFailedTasksSuccess => '已清除所有失败任务';
	@override String get clearAllFailedTasksError => '清除失败任务时出错';
	@override String get downloadStatus => '下载状态';
	@override String get imageList => '图片列表';
	@override String get retryDownload => '重试下载';
	@override String get notDownloaded => '未下载';
	@override String get downloaded => '已下载';
	@override String get waitingForDownload => '等待下载...';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '下载中 (${downloaded}/${total}张 ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => '下载中 (${downloaded}张)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '已暂停 (${downloaded}/${total}张 ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => '已暂停 (已下载${downloaded}张)';
	@override String downloadedProgressForImageProgress({required Object total}) => '下载完成 (共${total}张)';
	@override String get viewVideoDetail => '查看视频详情';
	@override String get viewGalleryDetail => '查看图库详情';
	@override String get moreOptions => '更多操作';
	@override String get openFile => '打开文件';
	@override String get pause => '暂停';
	@override String get resume => '继续';
	@override String get copyDownloadUrl => '复制下载链接';
	@override String get showInFolder => '在文件夹中显示';
	@override String get deleteTask => '删除任务';
	@override String get deleteTaskConfirmation => '确定要删除这个下载任务吗？\n任务的文件也会被删除。';
	@override String get forceDeleteTaskConfirmation => '确定要强制删除这个下载任务吗？\n任务的文件也会被删除，即使文件被占用也会尝试删除。';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => '下载中 ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => '已暂停 • ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => '已暂停 • 已下载 ${downloaded}';
	@override String downloadedWithSize({required Object size}) => '下载完成 • ${size}';
	@override String get copyDownloadUrlSuccess => '已复制下载链接';
	@override String totalImageNums({required Object num}) => '${num}张';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => '下载中';
	@override String get failed => '失败';
	@override String get completed => '已完成';
	@override String get downloadDetail => '下载详情';
	@override String get copy => '复制';
	@override String get copySuccess => '已复制';
	@override String get waiting => '等待中';
	@override String get paused => '暂停中';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => '下载中 ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => '图库下载完成: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => '下载完成: ${fileName}';
	@override String get stillInDevelopment => '开发中';
	@override String get saveToAppDirectory => '保存到应用目录';
}

// Path: favorite
class _TranslationsFavoriteZhCn implements TranslationsFavoriteEn {
	_TranslationsFavoriteZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsZhCn errors = _TranslationsFavoriteErrorsZhCn._(_root);
	@override String get add => '追加';
	@override String get addSuccess => '追加成功';
	@override String get addFailed => '追加失败';
	@override String get remove => '删除';
	@override String get removeSuccess => '删除成功';
	@override String get removeFailed => '删除失败';
	@override String get removeConfirmation => '确定要删除这个项目吗？';
	@override String get removeConfirmationSuccess => '项目已从收藏夹中删除';
	@override String get removeConfirmationFailed => '删除项目失败';
	@override String get createFolderSuccess => '文件夹创建成功';
	@override String get createFolderFailed => '创建文件夹失败';
	@override String get createFolder => '创建文件夹';
	@override String get enterFolderName => '输入文件夹名称';
	@override String get enterFolderNameHere => '在此输入文件夹名称...';
	@override String get create => '创建';
	@override String get items => '项目';
	@override String get newFolderName => '新文件夹';
	@override String get searchFolders => '搜索文件夹...';
	@override String get searchItems => '搜索项目...';
	@override String get createdAt => '创建时间';
	@override String get myFavorites => '我的收藏';
	@override String get deleteFolderTitle => '删除文件夹';
	@override String deleteFolderConfirmWithTitle({required Object title}) => '确定要删除 ${title} 文件夹吗？';
	@override String get removeItemTitle => '删除项目';
	@override String removeItemConfirmWithTitle({required Object title}) => '确定要删除 ${title} 项目吗？';
	@override String get removeItemSuccess => '项目已从收藏夹中删除';
	@override String get removeItemFailed => '删除项目失败';
	@override String get localizeFavorite => '本地收藏';
	@override String get editFolderTitle => '编辑文件夹';
	@override String get editFolderSuccess => '文件夹更新成功';
	@override String get editFolderFailed => '文件夹更新失败';
	@override String get searchTags => '搜索标签';
}

// Path: translation
class _TranslationsTranslationZhCn implements TranslationsTranslationEn {
	_TranslationsTranslationZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get testConnection => '测试连接';
	@override String get testConnectionSuccess => '测试连接成功';
	@override String get testConnectionFailed => '测试连接失败';
	@override String testConnectionFailedWithMessage({required Object message}) => '测试连接失败: ${message}';
	@override String get translation => '翻译';
	@override String get needVerification => '需要验证';
	@override String get needVerificationContent => '请先通过连接测试才能启用AI翻译';
	@override String get confirm => '确定';
	@override String get disclaimer => '使用须知';
	@override String get riskWarning => '风险提示';
	@override String get dureToRisk1 => '由于评论等文本为用户生成，可能包含违反AI服务商内容政策的内容';
	@override String get dureToRisk2 => '不当内容可能导致API密钥封禁或服务终止';
	@override String get operationSuggestion => '操作建议';
	@override String get operationSuggestion1 => '1. 使用前请严格审核待翻译内容';
	@override String get operationSuggestion2 => '2. 避免翻译涉及暴力、成人等敏感内容';
	@override String get apiConfig => 'API配置';
	@override String get modifyConfigWillAutoCloseAITranslation => '修改配置将自动关闭AI翻译，需重新测试后打开';
	@override String get apiAddress => 'API地址';
	@override String get modelName => '模型名称';
	@override String get modelNameHintText => '例如：gpt-4-turbo';
	@override String get maxTokens => '最大Token数';
	@override String get maxTokensHintText => '例如：1024';
	@override String get temperature => '温度系数';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => '点击测试按钮验证API连接有效性';
	@override String get requestPreview => '请求预览';
	@override String get enableAITranslation => 'AI翻译';
	@override String get enabled => '已启用';
	@override String get disabled => '已禁用';
	@override String get testing => '测试中...';
	@override String get testNow => '立即测试';
	@override String get connectionStatus => '连接状态';
	@override String get success => '成功';
	@override String get failed => '失败';
	@override String get information => '信息';
	@override String get viewRawResponse => '查看原始响应';
	@override String get pleaseCheckInputParametersFormat => '请检查输入参数格式';
	@override String get pleaseFillInAPIAddressModelNameAndKey => '请填写API地址、模型名称和密钥';
	@override String get pleaseFillInValidConfigurationParameters => '请填写有效的配置参数';
	@override String get pleaseCompleteConnectionTest => '请完成连接测试';
	@override String get notConfigured => '未配置';
	@override String get apiEndpoint => 'API端点';
	@override String get configuredKey => '已配置密钥';
	@override String get notConfiguredKey => '未配置密钥';
	@override String get authenticationStatus => '认证状态';
	@override String get thisFieldCannotBeEmpty => '此字段不能为空';
	@override String get apiKey => 'API密钥';
	@override String get apiKeyCannotBeEmpty => 'API密钥不能为空';
	@override String get pleaseEnterValidNumber => '请输入有效数字';
	@override String get range => '范围';
	@override String get mustBeGreaterThan => '必须大于';
	@override String get invalidAPIResponse => '无效的API响应';
	@override String connectionFailedForMessage({required Object message}) => '连接失败: ${message}';
	@override String get aiTranslationNotEnabledHint => 'AI翻译未启用，请在设置中启用';
	@override String get goToSettings => '前往设置';
	@override String get disableAITranslation => '禁用AI翻译';
	@override String get currentValue => '当前值';
	@override String get configureTranslationStrategy => '配置翻译策略';
	@override String get advancedSettings => '高级设置';
	@override String get translationPrompt => '翻译提示词';
	@override String get promptHint => '请输入翻译提示词,使用[TL]作为目标语言的占位符';
	@override String get promptHelperText => '提示词必须包含[TL]作为目标语言的占位符';
	@override String get promptMustContainTargetLang => '提示词必须包含[TL]占位符';
	@override String get aiTranslationWillBeDisabled => 'AI翻译将被自动关闭';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => '由于修改了基础配置,AI翻译将被自动关闭';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => '由于修改了翻译提示词,AI翻译将被自动关闭';
	@override String get aiTranslationWillBeDisabledDueToParamChange => '由于修改了参数配置,AI翻译将被自动关闭';
	@override String get onlyOpenAIAPISupported => '当前仅支持OpenAI兼容的API格式（application/json请求体格式）';
	@override String get streamingTranslation => '流式翻译';
	@override String get streamingTranslationSupported => '支持流式翻译';
	@override String get streamingTranslationNotSupported => '不支持流式翻译';
	@override String get streamingTranslationDescription => '流式翻译可以在翻译过程中实时显示结果，提供更好的用户体验';
	@override String get usingFullUrlWithHash => '使用完整URL（以#结尾）';
	@override String get baseUrlInputHelperText => '当以#结尾时，将以输入的URL作为实际请求地址';
	@override String currentActualUrl({required Object url}) => '当前实际URL: ${url}';
	@override String get urlEndingWithHashTip => 'URL以#结尾时，将以输入的URL作为实际请求地址';
	@override String get streamingTranslationWarning => '注意：此功能需要API服务支持流式传输，部分模型可能不支持';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogZhCn implements TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '输入链接';
	@override String supportedLinksHint({required Object webName}) => '支持智能识别多个${webName}链接，并快速跳转到应用内对应页面(链接与其他文本之间用空格隔开)';
	@override String inputHint({required Object webName}) => '请输入${webName}链接';
	@override String get validatorEmptyLink => '请输入链接';
	@override String validatorNoIwaraLink({required Object webName}) => '未检测到有效的${webName}链接';
	@override String get multipleLinksDetected => '检测到多个链接，请选择一个：';
	@override String notIwaraLink({required Object webName}) => '不是有效的${webName}链接';
	@override String linkParseError({required Object error}) => '链接解析出错: ${error}';
	@override String get unsupportedLinkDialogTitle => '不支持的链接';
	@override String get unsupportedLinkDialogContent => '该链接类型当前应用无法直接打开，需要使用外部浏览器访问。\n\n是否使用浏览器打开此链接？';
	@override String get openInBrowser => '用浏览器打开';
	@override String get confirmOpenBrowserDialogTitle => '确认打开浏览器';
	@override String get confirmOpenBrowserDialogContent => '即将使用外部浏览器打开以下链接：';
	@override String get confirmContinueBrowserOpen => '确定要继续吗？';
	@override String get browserOpenFailed => '无法打开链接';
	@override String get unsupportedLink => '不支持的链接';
	@override String get cancel => '取消';
	@override String get confirm => '用浏览器打开';
}

// Path: log
class _TranslationsLogZhCn implements TranslationsLogEn {
	_TranslationsLogZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get logManagement => '日志管理';
	@override String get enableLogPersistence => '启用日志持久化';
	@override String get enableLogPersistenceDesc => '将日志保存到数据库以便于分析问题';
	@override String get logDatabaseSizeLimit => '日志数据库大小上限';
	@override String logDatabaseSizeLimitDesc({required Object size}) => '当前: ${size}';
	@override String get exportCurrentLogs => '导出当前日志';
	@override String get exportCurrentLogsDesc => '导出当天应用日志以帮助开发者诊断问题';
	@override String get exportHistoryLogs => '导出历史日志';
	@override String get exportHistoryLogsDesc => '导出指定日期范围的日志';
	@override String get exportMergedLogs => '导出合并日志';
	@override String get exportMergedLogsDesc => '导出指定日期范围的合并日志';
	@override String get showLogStats => '显示日志统计信息';
	@override String get logExportSuccess => '日志导出成功';
	@override String logExportFailed({required Object error}) => '日志导出失败: ${error}';
	@override String get showLogStatsDesc => '查看各种类型日志的统计数据';
	@override String logExtractFailed({required Object error}) => '获取日志统计失败: ${error}';
	@override String get clearAllLogs => '清理所有日志';
	@override String get clearAllLogsDesc => '清理所有日志数据';
	@override String get confirmClearAllLogs => '确认清理';
	@override String get confirmClearAllLogsDesc => '确定要清理所有日志数据吗？此操作不可撤销。';
	@override String get clearAllLogsSuccess => '日志清理成功';
	@override String clearAllLogsFailed({required Object error}) => '清理日志失败: ${error}';
	@override String get unableToGetLogSizeInfo => '无法获取日志大小信息';
	@override String get currentLogSize => '当前日志大小:';
	@override String get logCount => '日志数量:';
	@override String get logCountUnit => '条';
	@override String get logSizeLimit => '大小上限:';
	@override String get usageRate => '使用率:';
	@override String get exceedLimit => '超出限制';
	@override String get remaining => '剩余';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => '当前日志大小已超出限制，建议立即清理旧日志或增加空间限制';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => '当前日志大小即将用尽，建议清理旧日志';
	@override String get cleaningOldLogs => '正在自动清理旧日志...';
	@override String get logCleaningCompleted => '日志清理完成';
	@override String get logCleaningProcessMayNotBeCompleted => '日志清理过程可能未完成';
	@override String get cleanExceededLogs => '清理超出限制的日志';
	@override String get noLogsToExport => '没有可导出的日志数据';
	@override String get exportingLogs => '正在导出日志...';
	@override String get noHistoryLogsToExport => '尚无可导出的历史日志，请先使用应用一段时间再尝试';
	@override String get selectLogDate => '选择日志日期';
	@override String get today => '今天';
	@override String get selectMergeRange => '选择合并范围';
	@override String get selectMergeRangeHint => '请选择要合并的日志时间范围';
	@override String selectMergeRangeDays({required Object days}) => '最近 ${days} 天';
	@override String get logStats => '日志统计信息';
	@override String todayLogs({required Object count}) => '今日日志: ${count} 条';
	@override String recent7DaysLogs({required Object count}) => '最近7天: ${count} 条';
	@override String totalLogs({required Object count}) => '总计日志: ${count} 条';
	@override String get setLogDatabaseSizeLimit => '设置日志数据库大小上限';
	@override String currentLogSizeWithSize({required Object size}) => '当前日志大小: ${size}';
	@override String get warning => '警告';
	@override String newSizeLimit({required Object size}) => '新的大小限制: ${size}';
	@override String get confirmToContinue => '确定要继续吗？';
	@override String logSizeLimitSetSuccess({required Object size}) => '日志大小上限已设置为 ${size}';
}

// Path: common.pagination
class _TranslationsCommonPaginationZhCn implements TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => '共 ${num} 项';
	@override String get jumpToPage => '跳转到指定页面';
	@override String pleaseEnterPageNumber({required Object max}) => '请输入页码 (1-${max})';
	@override String get pageNumber => '页码';
	@override String get jump => '跳转';
	@override String invalidPageNumber({required Object max}) => '请输入有效页码 (1-${max})';
	@override String get invalidInput => '请输入有效页码';
	@override String get waterfall => '瀑布流';
	@override String get pagination => '分页';
}

// Path: errors.network
class _TranslationsErrorsNetworkZhCn implements TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => '网络错误 - ';
	@override String get failedToConnectToServer => '连接服务器失败';
	@override String get serverNotAvailable => '服务器不可用';
	@override String get requestTimeout => '请求超时';
	@override String get unexpectedError => '意外错误';
	@override String get invalidResponse => '无效响应';
	@override String get invalidRequest => '无效请求';
	@override String get invalidUrl => '无效URL';
	@override String get invalidMethod => '无效方法';
	@override String get invalidHeader => '无效头';
	@override String get invalidBody => '无效体';
	@override String get invalidStatusCode => '无效状态码';
	@override String get serverError => '服务器错误';
	@override String get requestCanceled => '请求已取消';
	@override String get invalidPort => '无效端口';
	@override String get proxyPortError => '代理端口设置异常';
	@override String get connectionRefused => '连接被拒绝';
	@override String get networkUnreachable => '网络不可达';
	@override String get noRouteToHost => '无法找到主机';
	@override String get connectionFailed => '连接失败';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsZhCn implements TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => '下载设置';
	@override String get storagePermissionStatus => '存储权限状态';
	@override String get accessPublicDirectoryNeedStoragePermission => '访问公共目录需要存储权限';
	@override String get checkingPermissionStatus => '检查权限状态...';
	@override String get storagePermissionGranted => '已授权存储权限';
	@override String get storagePermissionNotGranted => '需要存储权限';
	@override String get storagePermissionGrantSuccess => '存储权限授权成功';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => '存储权限授权失败，部分功能可能受限';
	@override String get grantStoragePermission => '授权存储权限';
	@override String get customDownloadPath => '自定义下载位置';
	@override String get customDownloadPathDescription => '启用后可以为下载的文件选择自定义保存位置';
	@override String get customDownloadPathTip => '💡 提示：选择公共目录（如下载文件夹）需要授予存储权限，建议优先使用推荐路径';
	@override String get androidWarning => 'Android提示：避免选择公共目录（如下载文件夹），建议使用应用专用目录以确保访问权限。';
	@override String get publicDirectoryPermissionTip => '⚠️ 注意：您选择的是公共目录，需要存储权限才能正常下载文件';
	@override String get permissionRequiredForPublicDirectory => '选择公共目录需要存储权限';
	@override String get currentDownloadPath => '当前下载路径';
	@override String get defaultAppDirectory => '应用默认目录';
	@override String get permissionGranted => '已授权';
	@override String get permissionRequired => '需要权限';
	@override String get enableCustomDownloadPath => '启用自定义下载路径';
	@override String get disableCustomDownloadPath => '关闭时使用应用默认路径';
	@override String get customDownloadPathLabel => '自定义下载路径';
	@override String get selectDownloadFolder => '选择下载文件夹';
	@override String get recommendedPath => '推荐路径';
	@override String get selectFolder => '选择文件夹';
	@override String get filenameTemplate => '文件命名模板';
	@override String get filenameTemplateDescription => '自定义下载文件的命名规则，支持变量替换';
	@override String get videoFilenameTemplate => '视频文件命名模板';
	@override String get galleryFolderTemplate => '图库文件夹命名模板';
	@override String get imageFilenameTemplate => '单张图片命名模板';
	@override String get resetToDefault => '重置为默认值';
	@override String get supportedVariables => '支持的变量';
	@override String get supportedVariablesDescription => '在文件命名模板中可以使用以下变量：';
	@override String get copyVariable => '复制变量';
	@override String get variableCopied => '变量已复制';
	@override String get warningPublicDirectory => '警告：选择的是公共目录，可能无法访问。建议选择应用专用目录。';
	@override String get downloadPathUpdated => '下载路径已更新';
	@override String get selectPathFailed => '选择路径失败';
	@override String get recommendedPathSet => '已设置为推荐路径';
	@override String get setRecommendedPathFailed => '设置推荐路径失败';
	@override String get templateResetToDefault => '已重置为默认模板';
	@override String get functionalTest => '功能测试';
	@override String get testInProgress => '测试中...';
	@override String get runTest => '运行测试';
	@override String get testDownloadPathAndPermissions => '测试下载路径和权限配置是否正常工作';
	@override String get testResults => '测试结果';
	@override String get testCompleted => '测试完成';
	@override String get testPassed => '项通过';
	@override String get testFailed => '测试失败';
	@override String get testStoragePermissionCheck => '存储权限检查';
	@override String get testStoragePermissionGranted => '已获得存储权限';
	@override String get testStoragePermissionMissing => '缺少存储权限，部分功能可能受限';
	@override String get testPermissionCheckFailed => '权限检查失败';
	@override String get testDownloadPathValidation => '下载路径验证';
	@override String get testPathValidationFailed => '路径验证失败';
	@override String get testFilenameTemplateValidation => '文件命名模板验证';
	@override String get testAllTemplatesValid => '所有模板都有效';
	@override String get testSomeTemplatesInvalid => '部分模板包含无效字符';
	@override String get testTemplateValidationFailed => '模板验证失败';
	@override String get testDirectoryOperationTest => '目录操作测试';
	@override String get testDirectoryOperationNormal => '目录创建和文件写入正常';
	@override String get testDirectoryOperationFailed => '目录操作失败';
	@override String get testVideoTemplate => '视频模板';
	@override String get testGalleryTemplate => '图库模板';
	@override String get testImageTemplate => '图片模板';
	@override String get testValid => '有效';
	@override String get testInvalid => '无效';
	@override String get testSuccess => '成功';
	@override String get testCorrect => '正确';
	@override String get testError => '错误';
	@override String get testPath => '测试路径';
	@override String get testBasePath => '基础路径';
	@override String get testDirectoryCreation => '目录创建';
	@override String get testFileWriting => '文件写入';
	@override String get testFileContent => '文件内容';
	@override String get checkingPathStatus => '检查路径状态...';
	@override String get unableToGetPathStatus => '无法获取路径状态';
	@override String get actualPathDifferentFromSelected => '注意：实际使用路径与选择路径不同';
	@override String get grantPermission => '授权权限';
	@override String get fixIssue => '修复问题';
	@override String get issueFixed => '问题已修复';
	@override String get fixFailed => '修复失败，请手动处理';
	@override String get lackStoragePermission => '缺少存储权限';
	@override String get cannotAccessPublicDirectory => '无法访问公共目录，需要"所有文件访问权限"';
	@override String get cannotCreateDirectory => '无法创建目录';
	@override String get directoryNotWritable => '目录不可写';
	@override String get insufficientSpace => '可用空间不足';
	@override String get pathValid => '路径有效';
	@override String get validationFailed => '验证失败';
	@override String get usingDefaultAppDirectory => '使用默认应用目录';
	@override String get appPrivateDirectory => '应用专用目录';
	@override String get appPrivateDirectoryDesc => '安全可靠，无需额外权限';
	@override String get downloadDirectory => '下载目录';
	@override String get downloadDirectoryDesc => '系统默认下载位置，便于管理';
	@override String get moviesDirectory => '影片目录';
	@override String get moviesDirectoryDesc => '系统影片目录，媒体应用可识别';
	@override String get documentsDirectory => '文档目录';
	@override String get documentsDirectoryDesc => 'iOS应用文档目录';
	@override String get requiresStoragePermission => '需要存储权限才能访问';
	@override String get recommendedPaths => '推荐路径';
	@override String get selectRecommendedDownloadLocation => '选择一个推荐的下载位置';
	@override String get noRecommendedPaths => '暂无推荐路径';
	@override String get recommended => '推荐';
	@override String get requiresPermission => '需要权限';
	@override String get authorizeAndSelect => '授权并选择';
	@override String get select => '选择';
	@override String get permissionAuthorizationFailed => '权限授权失败，无法选择此路径';
	@override String get pathValidationFailed => '路径验证失败';
	@override String get downloadPathSetTo => '下载路径已设置为';
	@override String get setPathFailed => '设置路径失败';
	@override String get variableTitle => '标题';
	@override String get variableAuthor => '作者名称';
	@override String get variableUsername => '作者用户名';
	@override String get variableQuality => '视频质量';
	@override String get variableFilename => '原始文件名';
	@override String get variableId => '内容ID';
	@override String get variableCount => '图库图片数量';
	@override String get variableDate => '当前日期 (YYYY-MM-DD)';
	@override String get variableTime => '当前时间 (HH-MM-SS)';
	@override String get variableDatetime => '当前日期时间 (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => '下载设置';
	@override String get downloadSettingsSubtitle => '配置下载路径和文件命名规则';
	@override String get suchAsTitleQuality => '例如: %title_%quality';
	@override String get suchAsTitleId => '例如: %title_%id';
	@override String get suchAsTitleFilename => '例如: %title_%filename';
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesZhCn implements TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get hot => '急上昇';
	@override String get favorites => '高評価';
	@override String get latest => '新着';
	@override String get popularity => '人気';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsZhCn implements TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => '请求失败，状态码';
	@override String get connectionTimeout => '连接超时，请检查网络连接';
	@override String get sendTimeout => '发送请求超时';
	@override String get receiveTimeout => '接收响应超时';
	@override String get badCertificate => '证书验证失败';
	@override String get resourceNotFound => '请求的资源不存在';
	@override String get accessDenied => '访问被拒绝，可能需要验证或权限';
	@override String get serverError => '服务器内部错误';
	@override String get serviceUnavailable => '服务暂时不可用';
	@override String get requestCancelled => '请求已取消';
	@override String get connectionError => '网络连接错误，请检查网络设置';
	@override String get networkRequestFailed => '网络请求失败';
	@override String get searchVideoError => '搜索视频时发生未知错误';
	@override String get getPopularVideoError => '获取热门视频时发生未知错误';
	@override String get getVideoDetailError => '获取视频详情时发生未知错误';
	@override String get parseVideoDetailError => '获取并解析视频详情时发生未知错误';
	@override String get downloadFileError => '下载文件时发生未知错误';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingZhCn implements TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => '正在获取视频信息...';
	@override String get cancel => '取消';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesZhCn implements TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => '视频不存在或已被删除';
	@override String get unableToGetVideoPlayLink => '无法获取视频播放链接';
	@override String get getVideoDetailFailed => '获取视频详情失败';
}

// Path: forum.errors
class _TranslationsForumErrorsZhCn implements TranslationsForumErrorsEn {
	_TranslationsForumErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => '请选择分类';
	@override String get threadLocked => '该主题已锁定，无法回复';
}

// Path: forum.groups
class _TranslationsForumGroupsZhCn implements TranslationsForumGroupsEn {
	_TranslationsForumGroupsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get administration => '管理';
	@override String get global => '全球';
	@override String get chinese => '中文';
	@override String get japanese => '日语';
	@override String get korean => '韩语';
	@override String get other => '其他';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesZhCn implements TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get announcements => '公告';
	@override String get feedback => '反馈';
	@override String get support => '帮助';
	@override String get general => '一般';
	@override String get guides => '指南';
	@override String get questions => '问题';
	@override String get requests => '请求';
	@override String get sharing => '分享';
	@override String get general_zh => '一般';
	@override String get questions_zh => '问题';
	@override String get requests_zh => '请求';
	@override String get support_zh => '帮助';
	@override String get general_ja => '一般';
	@override String get questions_ja => '问题';
	@override String get requests_ja => '请求';
	@override String get support_ja => '帮助';
	@override String get korean => '韩语';
	@override String get other => '其他';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsZhCn implements TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get announcements => '官方重要通知和公告';
	@override String get feedback => '对网站功能和服务的反馈';
	@override String get support => '帮助解决网站相关问题';
	@override String get general => '讨论任何话题';
	@override String get guides => '分享你的经验和教程';
	@override String get questions => '提出你的疑问';
	@override String get requests => '发布你的请求';
	@override String get sharing => '分享有趣的内容';
	@override String get general_zh => '讨论任何话题';
	@override String get questions_zh => '提出你的疑问';
	@override String get requests_zh => '发布你的请求';
	@override String get support_zh => '帮助解决网站相关问题';
	@override String get general_ja => '讨论任何话题';
	@override String get questions_ja => '提出你的疑问';
	@override String get requests_ja => '发布你的请求';
	@override String get support_ja => '帮助解决网站相关问题';
	@override String get korean => '韩语相关讨论';
	@override String get other => '其他未分类的内容';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsZhCn implements TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => '暂不支持的通知类型';
	@override String get unknownUser => '未知用户';
	@override String unsupportedNotificationTypeWithType({required Object type}) => '暂不支持的通知类型: ${type}';
	@override String get unknownNotificationType => '未知通知类型';
}

// Path: conversation.errors
class _TranslationsConversationErrorsZhCn implements TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => '请选择一个用户';
	@override String get pleaseEnterATitle => '请输入标题';
	@override String get clickToSelectAUser => '点击选择用户';
	@override String get loadFailedClickToRetry => '加载失败,点击重试';
	@override String get loadFailed => '加载失败';
	@override String get clickToRetry => '点击重试';
	@override String get noMoreConversations => '没有更多消息了';
}

// Path: splash.errors
class _TranslationsSplashErrorsZhCn implements TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => '初始化失败，请重启应用';
}

// Path: download.errors
class _TranslationsDownloadErrorsZhCn implements TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => '图库信息不存在';
	@override String get downloadFailed => '下载失败';
	@override String get videoInfoNotFound => '视频信息不存在';
	@override String get unknown => '未知';
	@override String get downloadTaskAlreadyExists => '下载任务已存在';
	@override String get videoAlreadyDownloaded => '该视频已下载';
	@override String downloadFailedForMessage({required Object errorInfo}) => '添加下载任务失败: ${errorInfo}';
	@override String get userPausedDownload => '用户暂停下载';
	@override String fileSystemError({required Object errorInfo}) => '文件系统错误: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => '未知错误: ${errorInfo}';
	@override String get connectionTimeout => '连接超时';
	@override String get sendTimeout => '发送超时';
	@override String get receiveTimeout => '接收超时';
	@override String serverError({required Object errorInfo}) => '服务器错误: ${errorInfo}';
	@override String get unknownNetworkError => '未知网络错误';
	@override String get serviceIsClosing => '下载服务正在关闭';
	@override String get partialDownloadFailed => '部分内容下载失败';
	@override String get noDownloadTask => '暂无下载任务';
	@override String get taskNotFoundOrDataError => '任务不存在或数据错误';
	@override String get copyDownloadUrlFailed => '复制下载链接失败';
	@override String get fileNotFound => '文件不存在';
	@override String get openFolderFailed => '打开文件夹失败';
	@override String openFolderFailedWithMessage({required Object message}) => '打开文件夹失败: ${message}';
	@override String get directoryNotFound => '目录不存在';
	@override String get copyFailed => '复制失败';
	@override String get openFileFailed => '打开文件失败';
	@override String openFileFailedWithMessage({required Object message}) => '打开文件失败: ${message}';
	@override String get noDownloadSource => '没有下载源';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => '暂无下载源，请等待信息加载完成后重试';
	@override String get noActiveDownloadTask => '暂无正在下载的任务';
	@override String get noFailedDownloadTask => '暂无失败的任务';
	@override String get noCompletedDownloadTask => '暂无已完成的任务';
	@override String get taskAlreadyCompletedDoNotAdd => '任务已完成，请勿重复添加';
	@override String get linkExpiredTryAgain => '链接已过期，正在重新获取下载链接';
	@override String get linkExpiredTryAgainSuccess => '链接已过期，正在重新获取下载链接成功';
	@override String get linkExpiredTryAgainFailed => '链接已过期,正在重新获取下载链接失败';
	@override String get taskDeleted => '任务已删除';
	@override String unsupportedImageFormat({required Object format}) => '不支持的图片格式: ${format}';
	@override String get deleteFileError => '文件删除失败，可能是因为文件被占用';
	@override String get deleteTaskError => '任务删除失败';
	@override String get taskNotFound => '任务未找到';
	@override String get canNotRefreshVideoTask => '无法刷新视频任务';
	@override String get taskAlreadyProcessing => '任务已处理中';
	@override String get failedToLoadTasks => '加载任务失败';
	@override String partialDownloadFailedWithMessage({required Object message}) => '部分下载失败: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => '不支持的图片格式: ${extension}, 可以尝试下载到设备上查看';
	@override String get imageLoadFailed => '图片加载失败';
	@override String get pleaseTryOtherViewer => '请尝试使用其他查看器打开';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsZhCn implements TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get addFailed => '追加失败';
	@override String get addSuccess => '追加成功';
	@override String get deleteFolderFailed => '删除文件夹失败';
	@override String get deleteFolderSuccess => '删除文件夹成功';
	@override String get folderNameCannotBeEmpty => '文件夹名称不能为空';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on TranslationsZhCn {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Love Iwara';
			case 'common.ok': return '确定';
			case 'common.cancel': return '取消';
			case 'common.save': return '保存';
			case 'common.delete': return '删除';
			case 'common.visit': return '访问';
			case 'common.loading': return '加载中...';
			case 'common.scrollToTop': return '滚动到顶部';
			case 'common.privacyHint': return '隐私内容，不与展示';
			case 'common.latest': return '最新';
			case 'common.likesCount': return '点赞数';
			case 'common.viewsCount': return '观看次数';
			case 'common.popular': return '受欢迎的';
			case 'common.trending': return '趋势';
			case 'common.commentList': return '评论列表';
			case 'common.sendComment': return '发表评论';
			case 'common.send': return '发表';
			case 'common.retry': return '重试';
			case 'common.premium': return '高级会员';
			case 'common.follower': return '粉丝';
			case 'common.friend': return '朋友';
			case 'common.video': return '视频';
			case 'common.following': return '关注';
			case 'common.expand': return '展开';
			case 'common.collapse': return '收起';
			case 'common.cancelFriendRequest': return '取消申请';
			case 'common.cancelSpecialFollow': return '取消特别关注';
			case 'common.addFriend': return '添加朋友';
			case 'common.removeFriend': return '解除朋友';
			case 'common.followed': return '已关注';
			case 'common.follow': return '关注';
			case 'common.unfollow': return '取消关注';
			case 'common.specialFollow': return '特别关注';
			case 'common.specialFollowed': return '已特别关注';
			case 'common.gallery': return '图库';
			case 'common.playlist': return '播放列表';
			case 'common.commentPostedSuccessfully': return '评论发表成功';
			case 'common.commentPostedFailed': return '评论发表失败';
			case 'common.success': return '成功';
			case 'common.commentDeletedSuccessfully': return '评论已删除';
			case 'common.commentUpdatedSuccessfully': return '评论已更新';
			case 'common.totalComments': return ({required Object count}) => '评论 ${count} 条';
			case 'common.writeYourCommentHere': return '在此输入评论...';
			case 'common.tmpNoReplies': return '暂无回复';
			case 'common.loadMore': return '加载更多';
			case 'common.noMoreDatas': return '没有更多数据了';
			case 'common.selectTranslationLanguage': return '选择翻译语言';
			case 'common.translate': return '翻译';
			case 'common.translateFailedPleaseTryAgainLater': return '翻译失败，请稍后重试';
			case 'common.translationResult': return '翻译结果';
			case 'common.justNow': return '刚刚';
			case 'common.minutesAgo': return ({required Object num}) => '${num}分钟前';
			case 'common.hoursAgo': return ({required Object num}) => '${num}小时前';
			case 'common.daysAgo': return ({required Object num}) => '${num}天前';
			case 'common.editedAt': return ({required Object num}) => '${num}编辑';
			case 'common.editComment': return '编辑评论';
			case 'common.commentUpdated': return '评论已更新';
			case 'common.replyComment': return '回复评论';
			case 'common.reply': return '回复';
			case 'common.edit': return '编辑';
			case 'common.unknownUser': return '未知用户';
			case 'common.me': return '我';
			case 'common.author': return '作者';
			case 'common.admin': return '管理员';
			case 'common.viewReplies': return ({required Object num}) => '查看回复 (${num})';
			case 'common.hideReplies': return '隐藏回复';
			case 'common.confirmDelete': return '确认删除';
			case 'common.areYouSureYouWantToDeleteThisItem': return '确定要删除这条记录吗？';
			case 'common.tmpNoComments': return '暂无评论';
			case 'common.refresh': return '刷新';
			case 'common.back': return '返回';
			case 'common.tips': return '提示';
			case 'common.linkIsEmpty': return '链接地址为空';
			case 'common.linkCopiedToClipboard': return '链接地址已复制到剪贴板';
			case 'common.imageCopiedToClipboard': return '图片已复制到剪贴板';
			case 'common.copyImageFailed': return '复制图片失败';
			case 'common.mobileSaveImageIsUnderDevelopment': return '移动端的保存图片功能还在开发中';
			case 'common.imageSavedTo': return '图片已保存到';
			case 'common.saveImageFailed': return '保存图片失败';
			case 'common.close': return '关闭';
			case 'common.more': return '更多';
			case 'common.moreFeaturesToBeDeveloped': return '更多功能待开发';
			case 'common.all': return '全部';
			case 'common.selectedRecords': return ({required Object num}) => '已选择 ${num} 条记录';
			case 'common.cancelSelectAll': return '取消全选';
			case 'common.selectAll': return '全选';
			case 'common.exitEditMode': return '退出编辑模式';
			case 'common.areYouSureYouWantToDeleteSelectedItems': return ({required Object num}) => '确定要删除选中的 ${num} 条记录吗？';
			case 'common.searchHistoryRecords': return '搜索历史记录...';
			case 'common.settings': return '设置';
			case 'common.subscriptions': return '订阅';
			case 'common.videoCount': return ({required Object num}) => '${num} 个视频';
			case 'common.share': return '分享';
			case 'common.areYouSureYouWantToShareThisPlaylist': return '要分享这个播放列表吗?';
			case 'common.editTitle': return '编辑标题';
			case 'common.editMode': return '编辑模式';
			case 'common.pleaseEnterNewTitle': return '请输入新标题';
			case 'common.createPlayList': return '创建播放列表';
			case 'common.create': return '创建';
			case 'common.checkNetworkSettings': return '检查网络设置';
			case 'common.general': return '大众的';
			case 'common.r18': return 'R18';
			case 'common.sensitive': return '敏感';
			case 'common.year': return '年份';
			case 'common.month': return '月份';
			case 'common.tag': return '标签';
			case 'common.private': return '私密';
			case 'common.noTitle': return '无标题';
			case 'common.search': return '搜索';
			case 'common.noContent': return '没有内容哦';
			case 'common.recording': return '记录中';
			case 'common.paused': return '已暂停';
			case 'common.clear': return '清除';
			case 'common.user': return '用户';
			case 'common.post': return '投稿';
			case 'common.seconds': return '秒';
			case 'common.comingSoon': return '敬请期待';
			case 'common.confirm': return '确认';
			case 'common.hour': return '时';
			case 'common.minute': return '分';
			case 'common.clickToRefresh': return '点击刷新';
			case 'common.history': return '历史记录';
			case 'common.favorites': return '最爱';
			case 'common.friends': return '好友';
			case 'common.playList': return '播放列表';
			case 'common.checkLicense': return '查看许可';
			case 'common.logout': return '退出登录';
			case 'common.fensi': return '粉丝';
			case 'common.accept': return '接受';
			case 'common.reject': return '拒绝';
			case 'common.clearAllHistory': return '清空所有历史记录';
			case 'common.clearAllHistoryConfirm': return '确定要清空所有历史记录吗？';
			case 'common.followingList': return '关注列表';
			case 'common.followersList': return '粉丝列表';
			case 'common.followers': return '粉丝';
			case 'common.follows': return '关注';
			case 'common.fans': return '粉丝';
			case 'common.followsAndFans': return '关注与粉丝';
			case 'common.numViews': return '观看次数';
			case 'common.updatedAt': return '更新时间';
			case 'common.publishedAt': return '发布时间';
			case 'common.externalVideo': return '站外视频';
			case 'common.originalText': return '原文';
			case 'common.showOriginalText': return '显示原始文本';
			case 'common.showProcessedText': return '显示处理后文本';
			case 'common.preview': return '预览';
			case 'common.markdownSyntax': return 'Markdown 语法';
			case 'common.rules': return '规则';
			case 'common.agree': return '同意';
			case 'common.disagree': return '不同意';
			case 'common.agreeToRules': return '同意规则';
			case 'common.createPost': return '创建投稿';
			case 'common.title': return '标题';
			case 'common.enterTitle': return '请输入标题';
			case 'common.content': return '内容';
			case 'common.enterContent': return '请输入内容';
			case 'common.writeYourContentHere': return '请输入内容...';
			case 'common.tagBlacklist': return '黑名单标签';
			case 'common.noData': return '没有数据';
			case 'common.tagLimit': return '标签上限';
			case 'common.enableFloatingButtons': return '启用浮动按钮';
			case 'common.disableFloatingButtons': return '禁用浮动按钮';
			case 'common.enabledFloatingButtons': return '已启用浮动按钮';
			case 'common.disabledFloatingButtons': return '已禁用浮动按钮';
			case 'common.pendingCommentCount': return '待审核评论';
			case 'common.joined': return ({required Object str}) => '加入于 ${str}';
			case 'common.download': return '下载';
			case 'common.selectQuality': return '选择画质';
			case 'common.selectDateRange': return '选择日期范围';
			case 'common.selectDateRangeHint': return '选择日期范围，默认选择最近30天';
			case 'common.clearDateRange': return '清除日期范围';
			case 'common.followSuccessClickAgainToSpecialFollow': return '已成功关注，再次点击以特别关注';
			case 'common.exitConfirmTip': return '确定要退出吗？';
			case 'common.error': return '错误';
			case 'common.taskRunning': return '任务正在进行中，请稍后再试。';
			case 'common.operationCancelled': return '操作已取消。';
			case 'common.unsavedChanges': return '您有未保存的更改';
			case 'common.specialFollowsManagementTip': return '拖动可重新排序 • 向左滑动可移除';
			case 'common.specialFollowsManagement': return '特别关注管理';
			case 'common.pagination.totalItems': return ({required Object num}) => '共 ${num} 项';
			case 'common.pagination.jumpToPage': return '跳转到指定页面';
			case 'common.pagination.pleaseEnterPageNumber': return ({required Object max}) => '请输入页码 (1-${max})';
			case 'common.pagination.pageNumber': return '页码';
			case 'common.pagination.jump': return '跳转';
			case 'common.pagination.invalidPageNumber': return ({required Object max}) => '请输入有效页码 (1-${max})';
			case 'common.pagination.invalidInput': return '请输入有效页码';
			case 'common.pagination.waterfall': return '瀑布流';
			case 'common.pagination.pagination': return '分页';
			case 'common.notice': return '通知';
			case 'common.detail': return '详情';
			case 'common.parseExceptionDestopHint': return ' - 桌面端用户可以在设置中配置代理';
			case 'common.iwaraTags': return 'Iwara 标签';
			case 'common.likeThisVideo': return '喜欢这个视频的人';
			case 'common.operation': return '操作';
			case 'auth.tagLimit': return '标签上限';
			case 'auth.login': return '登录';
			case 'auth.logout': return '退出登录';
			case 'auth.email': return '邮箱';
			case 'auth.password': return '密码';
			case 'auth.loginOrRegister': return '登录 / 注册';
			case 'auth.register': return '注册';
			case 'auth.pleaseEnterEmail': return '请输入邮箱';
			case 'auth.pleaseEnterPassword': return '请输入密码';
			case 'auth.passwordMustBeAtLeast6Characters': return '密码至少需要6位';
			case 'auth.pleaseEnterCaptcha': return '请输入验证码';
			case 'auth.captcha': return '验证码';
			case 'auth.refreshCaptcha': return '刷新验证码';
			case 'auth.captchaNotLoaded': return '无法加载验证码';
			case 'auth.loginSuccess': return '登录成功';
			case 'auth.emailVerificationSent': return '邮箱指令已发送';
			case 'auth.notLoggedIn': return '未登录';
			case 'auth.clickToLogin': return '点击此处登录';
			case 'auth.logoutConfirmation': return '你确定要退出登录吗？';
			case 'auth.logoutSuccess': return '退出登录成功';
			case 'auth.logoutFailed': return '退出登录失败';
			case 'auth.usernameOrEmail': return '用户名或邮箱';
			case 'auth.pleaseEnterUsernameOrEmail': return '请输入用户名或邮箱';
			case 'auth.username': return '用户名或邮箱';
			case 'auth.pleaseEnterUsername': return '请输入用户名或邮箱';
			case 'auth.rememberMe': return '记住账号和密码';
			case 'errors.error': return '错误';
			case 'errors.required': return '此项必填';
			case 'errors.invalidEmail': return '邮箱格式不正确';
			case 'errors.networkError': return '网络错误，请重试';
			case 'errors.errorWhileFetching': return '获取信息失败';
			case 'errors.commentCanNotBeEmpty': return '评论内容不能为空';
			case 'errors.errorWhileFetchingReplies': return '获取回复时出错，请检查网络连接';
			case 'errors.canNotFindCommentController': return '无法找到评论控制器';
			case 'errors.errorWhileLoadingGallery': return '在加载图库时出现了错误';
			case 'errors.howCouldThereBeNoDataItCantBePossible': return '啊？怎么会没有数据呢？出错了吧 :<';
			case 'errors.unsupportedImageFormat': return ({required Object str}) => '不支持的图片格式: ${str}';
			case 'errors.invalidGalleryId': return '无效的图库ID';
			case 'errors.translationFailedPleaseTryAgainLater': return '翻译失败，请稍后重试';
			case 'errors.errorOccurred': return '发生错误，请稍后再试。';
			case 'errors.errorOccurredWhileProcessingRequest': return '处理请求时出错';
			case 'errors.errorWhileFetchingDatas': return '获取数据时出错，请稍后再试';
			case 'errors.serviceNotInitialized': return '服务未初始化';
			case 'errors.unknownType': return '未知类型';
			case 'errors.errorWhileOpeningLink': return ({required Object link}) => '无法打开链接: ${link}';
			case 'errors.invalidUrl': return '无效的URL';
			case 'errors.failedToOperate': return '操作失败';
			case 'errors.permissionDenied': return '权限不足';
			case 'errors.youDoNotHavePermissionToAccessThisResource': return '您没有权限访问此资源';
			case 'errors.loginFailed': return '登录失败';
			case 'errors.unknownError': return '未知错误';
			case 'errors.sessionExpired': return '会话已过期';
			case 'errors.failedToFetchCaptcha': return '获取验证码失败';
			case 'errors.emailAlreadyExists': return '邮箱已存在';
			case 'errors.invalidCaptcha': return '无效的验证码';
			case 'errors.registerFailed': return '注册失败';
			case 'errors.failedToFetchComments': return '获取评论失败';
			case 'errors.failedToFetchImageDetail': return '获取图库详情失败';
			case 'errors.failedToFetchImageList': return '获取图库列表失败';
			case 'errors.failedToFetchData': return '获取数据失败';
			case 'errors.invalidParameter': return '无效的参数';
			case 'errors.pleaseLoginFirst': return '请先登录';
			case 'errors.errorWhileLoadingPost': return '载入投稿内容时出错';
			case 'errors.errorWhileLoadingPostDetail': return '载入投稿详情时出错';
			case 'errors.invalidPostId': return '无效的投稿ID';
			case 'errors.forceUpdateNotPermittedToGoBack': return '目前处于强制更新状态，无法返回';
			case 'errors.pleaseLoginAgain': return '请重新登录';
			case 'errors.invalidLogin': return '登录失败，请检查邮箱和密码';
			case 'errors.tooManyRequests': return '请求过多，请稍后再试';
			case 'errors.exceedsMaxLength': return ({required Object max}) => '超出最大长度: ${max} 个字符';
			case 'errors.contentCanNotBeEmpty': return '内容不能为空';
			case 'errors.titleCanNotBeEmpty': return '标题不能为空';
			case 'errors.tooManyRequestsPleaseTryAgainLaterText': return '请求过多，请稍后再试，剩余时间';
			case 'errors.remainingHours': return ({required Object num}) => '${num}小时';
			case 'errors.remainingMinutes': return ({required Object num}) => '${num}分钟';
			case 'errors.remainingSeconds': return ({required Object num}) => '${num}秒';
			case 'errors.tagLimitExceeded': return ({required Object limit}) => '标签上限超出，上限: ${limit}';
			case 'errors.failedToRefresh': return '更新失败';
			case 'errors.noPermission': return '权限不足';
			case 'errors.resourceNotFound': return '资源不存在';
			case 'errors.failedToSaveCredentials': return '无法安全保存登录信息';
			case 'errors.failedToLoadSavedCredentials': return '加载保存的登录信息失败';
			case 'errors.specialFollowLimitReached': return ({required Object cnt}) => '特别关注上限超出，上限: ${cnt}，请于关注列表页中调整';
			case 'errors.notFound': return '内容不存在或已被删除';
			case 'errors.network.basicPrefix': return '网络错误 - ';
			case 'errors.network.failedToConnectToServer': return '连接服务器失败';
			case 'errors.network.serverNotAvailable': return '服务器不可用';
			case 'errors.network.requestTimeout': return '请求超时';
			case 'errors.network.unexpectedError': return '意外错误';
			case 'errors.network.invalidResponse': return '无效响应';
			case 'errors.network.invalidRequest': return '无效请求';
			case 'errors.network.invalidUrl': return '无效URL';
			case 'errors.network.invalidMethod': return '无效方法';
			case 'errors.network.invalidHeader': return '无效头';
			case 'errors.network.invalidBody': return '无效体';
			case 'errors.network.invalidStatusCode': return '无效状态码';
			case 'errors.network.serverError': return '服务器错误';
			case 'errors.network.requestCanceled': return '请求已取消';
			case 'errors.network.invalidPort': return '无效端口';
			case 'errors.network.proxyPortError': return '代理端口设置异常';
			case 'errors.network.connectionRefused': return '连接被拒绝';
			case 'errors.network.networkUnreachable': return '网络不可达';
			case 'errors.network.noRouteToHost': return '无法找到主机';
			case 'errors.network.connectionFailed': return '连接失败';
			case 'friends.clickToRestoreFriend': return '点击恢复好友';
			case 'friends.friendsList': return '好友列表';
			case 'friends.friendRequests': return '好友请求';
			case 'friends.friendRequestsList': return '好友请求列表';
			case 'friends.removingFriend': return '正在解除好友关系...';
			case 'friends.failedToRemoveFriend': return '解除好友关系失败';
			case 'friends.cancelingRequest': return '正在取消好友申请...';
			case 'friends.failedToCancelRequest': return '取消好友申请失败';
			case 'authorProfile.noMoreDatas': return '没有更多数据了';
			case 'authorProfile.userProfile': return '用户资料';
			case 'favorites.clickToRestoreFavorite': return '点击恢复最爱';
			case 'favorites.myFavorites': return '我的最爱';
			case 'galleryDetail.galleryDetail': return '图库详情';
			case 'galleryDetail.viewGalleryDetail': return '查看图库详情';
			case 'galleryDetail.copyLink': return '复制链接地址';
			case 'galleryDetail.copyImage': return '复制图片';
			case 'galleryDetail.saveAs': return '另存为';
			case 'galleryDetail.saveToAlbum': return '保存到相册';
			case 'galleryDetail.publishedAt': return '发布时间';
			case 'galleryDetail.viewsCount': return '观看次数';
			case 'galleryDetail.imageLibraryFunctionIntroduction': return '图库功能介绍';
			case 'galleryDetail.rightClickToSaveSingleImage': return '右键保存单张图片';
			case 'galleryDetail.batchSave': return '批量保存';
			case 'galleryDetail.keyboardLeftAndRightToSwitch': return '键盘的左右控制切换';
			case 'galleryDetail.keyboardUpAndDownToZoom': return '键盘的上下控制缩放';
			case 'galleryDetail.mouseWheelToSwitch': return '鼠标的滚轮滑动控制切换';
			case 'galleryDetail.ctrlAndMouseWheelToZoom': return 'CTRL + 鼠标滚轮控制缩放';
			case 'galleryDetail.moreFeaturesToBeDiscovered': return '更多功能待发现...';
			case 'galleryDetail.authorOtherGalleries': return '作者的其他图库';
			case 'galleryDetail.relatedGalleries': return '相关图库';
			case 'galleryDetail.clickLeftAndRightEdgeToSwitchImage': return '点击左右边缘以切换图片';
			case 'playList.myPlayList': return '我的播放列表';
			case 'playList.friendlyTips': return '友情提示';
			case 'playList.dearUser': return '亲爱的用户';
			case 'playList.iwaraPlayListSystemIsNotPerfectYet': return 'iwara的播放列表系统目前还不太完善';
			case 'playList.notSupportSetCover': return '不支持设置封面';
			case 'playList.notSupportDeleteList': return '不能删除列表';
			case 'playList.notSupportSetPrivate': return '无法设为私密';
			case 'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone': return '没错...创建的列表会一直存在且对所有人可见';
			case 'playList.smallSuggestion': return '小建议';
			case 'playList.useLikeToCollectContent': return '如果您比较注重隐私，建议使用"点赞"功能来收藏内容';
			case 'playList.welcomeToDiscussOnGitHub': return '如果你有其他的建议或想法，欢迎来 GitHub 讨论!';
			case 'playList.iUnderstand': return '明白了';
			case 'playList.searchPlaylists': return '搜索播放列表...';
			case 'playList.newPlaylistName': return '新播放列表名称';
			case 'playList.createNewPlaylist': return '创建新播放列表';
			case 'playList.videos': return '视频';
			case 'search.googleSearchScope': return '搜索范围';
			case 'search.searchTags': return '搜索标签...';
			case 'search.contentRating': return '内容分级';
			case 'search.removeTag': return '移除标签';
			case 'search.pleaseEnterSearchContent': return '请输入搜索内容';
			case 'search.searchHistory': return '搜索历史';
			case 'search.searchSuggestion': return '搜索建议';
			case 'search.usedTimes': return '使用次数';
			case 'search.lastUsed': return '最后使用';
			case 'search.noSearchHistoryRecords': return '没有搜索历史';
			case 'search.notSupportCurrentSearchType': return ({required Object searchType}) => '暂未实现当前搜索类型 ${searchType}，敬请期待';
			case 'search.searchResult': return '搜索结果';
			case 'search.unsupportedSearchType': return ({required Object searchType}) => '不支持的搜索类型: ${searchType}';
			case 'search.googleSearch': return '谷歌搜索';
			case 'search.googleSearchHint': return ({required Object webName}) => '${webName} 的搜索功能不好用？尝试谷歌搜索！';
			case 'search.googleSearchDescription': return '借助谷歌搜索的 :site 搜索运算符，你可以通过外部引擎来对站内的内容进行检索，此功能在搜索 视频、图库、播放列表、用户 时非常有用。';
			case 'search.googleSearchKeywordsHint': return '输入要搜索的关键词';
			case 'search.openLinkJump': return '打开链接跳转';
			case 'search.googleSearchButton': return '谷歌搜索';
			case 'search.pleaseEnterSearchKeywords': return '请输入搜索关键词';
			case 'search.googleSearchQueryCopied': return '搜索语句已复制到剪贴板';
			case 'search.googleSearchBrowserOpenFailed': return ({required Object error}) => '无法打开浏览器: ${error}';
			case 'mediaList.personalIntroduction': return '个人简介';
			case 'settings.listViewMode': return '列表显示模式';
			case 'settings.useTraditionalPaginationMode': return '使用传统分页模式';
			case 'settings.useTraditionalPaginationModeDesc': return '开启后列表将使用传统分页模式，关闭则使用瀑布流模式';
			case 'settings.showVideoProgressBottomBarWhenToolbarHidden': return '显示底部进度条';
			case 'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc': return '此配置决定是否在工具栏隐藏时显示底部进度条';
			case 'settings.basicSettings': return '基础设置';
			case 'settings.personalizedSettings': return '个性化设置';
			case 'settings.otherSettings': return '其他设置';
			case 'settings.searchConfig': return '搜索配置';
			case 'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain': return '此配置决定当你之后播放视频时是否会沿用之前的配置。';
			case 'settings.playControl': return '播放控制';
			case 'settings.fastForwardTime': return '快进时间';
			case 'settings.fastForwardTimeMustBeAPositiveInteger': return '快进时间必须是一个正整数。';
			case 'settings.rewindTime': return '后退时间';
			case 'settings.rewindTimeMustBeAPositiveInteger': return '后退时间必须是一个正整数。';
			case 'settings.longPressPlaybackSpeed': return '长按播放倍速';
			case 'settings.longPressPlaybackSpeedMustBeAPositiveNumber': return '长按播放倍速必须是一个正数。';
			case 'settings.repeat': return '循环播放';
			case 'settings.renderVerticalVideoInVerticalScreen': return '全屏播放时以竖屏模式渲染竖屏视频';
			case 'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen': return '此配置决定当你在全屏播放时是否以竖屏模式渲染竖屏视频。';
			case 'settings.rememberVolume': return '记住音量';
			case 'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain': return '此配置决定当你之后播放视频时是否会沿用之前的音量设置。';
			case 'settings.rememberBrightness': return '记住亮度';
			case 'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain': return '此配置决定当你之后播放视频时是否会沿用之前的亮度设置。';
			case 'settings.playControlArea': return '播放控制区域';
			case 'settings.leftAndRightControlAreaWidth': return '左右控制区域宽度';
			case 'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer': return '此配置决定播放器左右两侧的控制区域宽度。';
			case 'settings.proxyAddressCannotBeEmpty': return '代理地址不能为空。';
			case 'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort': return '无效的代理地址格式。请使用 IP:端口 或 域名:端口 格式。';
			case 'settings.proxyNormalWork': return '代理正常工作。';
			case 'settings.testProxyFailedWithStatusCode': return ({required Object code}) => '代理请求失败，状态码: ${code}';
			case 'settings.testProxyFailedWithException': return ({required Object exception}) => '代理请求出错: ${exception}';
			case 'settings.proxyConfig': return '代理配置';
			case 'settings.thisIsHttpProxyAddress': return '此处为http代理地址';
			case 'settings.checkProxy': return '检查代理';
			case 'settings.proxyAddress': return '代理地址';
			case 'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080': return '请输入代理服务器的URL，例如 127.0.0.1:8080';
			case 'settings.enableProxy': return '启用代理';
			case 'settings.left': return '左侧';
			case 'settings.middle': return '中间';
			case 'settings.right': return '右侧';
			case 'settings.playerSettings': return '播放器设置';
			case 'settings.networkSettings': return '网络设置';
			case 'settings.customizeYourPlaybackExperience': return '自定义您的播放体验';
			case 'settings.chooseYourFavoriteAppAppearance': return '选择您喜欢的应用外观';
			case 'settings.configureYourProxyServer': return '配置您的代理服务器';
			case 'settings.settings': return '设置';
			case 'settings.themeSettings': return '主题设置';
			case 'settings.followSystem': return '跟随系统';
			case 'settings.lightMode': return '浅色模式';
			case 'settings.darkMode': return '深色模式';
			case 'settings.presetTheme': return '预设主题';
			case 'settings.basicTheme': return '基础主题';
			case 'settings.needRestartToApply': return '需要重启应用以应用设置';
			case 'settings.themeNeedRestartDescription': return '主题设置需要重启应用以应用设置';
			case 'settings.about': return '关于';
			case 'settings.currentVersion': return '当前版本';
			case 'settings.latestVersion': return '最新版本';
			case 'settings.checkForUpdates': return '检查更新';
			case 'settings.update': return '更新';
			case 'settings.newVersionAvailable': return '发现新版本';
			case 'settings.projectHome': return '开源地址';
			case 'settings.release': return '版本发布';
			case 'settings.issueReport': return '问题反馈';
			case 'settings.openSourceLicense': return '开源许可';
			case 'settings.checkForUpdatesFailed': return '检查更新失败，请稍后重试';
			case 'settings.autoCheckUpdate': return '自动检查更新';
			case 'settings.updateContent': return '更新内容：';
			case 'settings.releaseDate': return '发布日期';
			case 'settings.ignoreThisVersion': return '忽略此版本';
			case 'settings.minVersionUpdateRequired': return '当前版本过低，请尽快更新';
			case 'settings.forceUpdateTip': return '此版本为强制更新，请尽快更新到最新版本';
			case 'settings.viewChangelog': return '查看更新日志';
			case 'settings.alreadyLatestVersion': return '已是最新版本';
			case 'settings.appSettings': return '应用设置';
			case 'settings.configureYourAppSettings': return '配置您的应用程序设置';
			case 'settings.history': return '历史记录';
			case 'settings.autoRecordHistory': return '自动记录历史记录';
			case 'settings.autoRecordHistoryDesc': return '自动记录您观看过的视频和图库等信息';
			case 'settings.showUnprocessedMarkdownText': return '显示未处理文本';
			case 'settings.showUnprocessedMarkdownTextDesc': return '显示Markdown的原始文本';
			case 'settings.markdown': return 'Markdown';
			case 'settings.activeBackgroundPrivacyMode': return '隐私模式';
			case 'settings.activeBackgroundPrivacyModeDesc': return '禁止截图、后台运行时隐藏画面...';
			case 'settings.privacy': return '隐私';
			case 'settings.forum': return '论坛';
			case 'settings.disableForumReplyQuote': return '禁用论坛回复引用';
			case 'settings.disableForumReplyQuoteDesc': return '禁用论坛回复时携带被回复楼层信息';
			case 'settings.theaterMode': return '剧院模式';
			case 'settings.theaterModeDesc': return '开启后，播放器背景会被设置为视频封面的模糊版本';
			case 'settings.appLinks': return '应用链接';
			case 'settings.defaultBrowser': return '默认浏览';
			case 'settings.defaultBrowserDesc': return '请在系统设置中打开默认链接配置项，并添加网站链接';
			case 'settings.themeMode': return '主题模式';
			case 'settings.themeModeDesc': return '此配置决定应用的主题模式';
			case 'settings.dynamicColor': return '动态颜色';
			case 'settings.dynamicColorDesc': return '此配置决定应用是否使用动态颜色';
			case 'settings.useDynamicColor': return '使用动态颜色';
			case 'settings.useDynamicColorDesc': return '此配置决定应用是否使用动态颜色';
			case 'settings.presetColors': return '预设颜色';
			case 'settings.customColors': return '自定义颜色';
			case 'settings.pickColor': return '选择颜色';
			case 'settings.cancel': return '取消';
			case 'settings.confirm': return '确认';
			case 'settings.noCustomColors': return '没有自定义颜色';
			case 'settings.recordAndRestorePlaybackProgress': return '记录和恢复播放进度';
			case 'settings.signature': return '小尾巴';
			case 'settings.enableSignature': return '小尾巴启用';
			case 'settings.enableSignatureDesc': return '此配置决定回复时是否自动添加小尾巴';
			case 'settings.enterSignature': return '输入小尾巴';
			case 'settings.editSignature': return '编辑小尾巴';
			case 'settings.signatureContent': return '小尾巴内容';
			case 'settings.exportConfig': return '导出应用配置';
			case 'settings.exportConfigDesc': return '将应用配置导出为文件（不包含下载记录）';
			case 'settings.importConfig': return '导入应用配置';
			case 'settings.importConfigDesc': return '从文件导入应用配置';
			case 'settings.exportConfigSuccess': return '配置导出成功！';
			case 'settings.exportConfigFailed': return '配置导出失败';
			case 'settings.importConfigSuccess': return '配置导入成功！';
			case 'settings.importConfigFailed': return '配置导入失败';
			case 'settings.historyUpdateLogs': return '历代更新日志';
			case 'settings.noUpdateLogs': return '未获取到更新日志';
			case 'settings.versionLabel': return '版本: {version}';
			case 'settings.releaseDateLabel': return '发布日期: {date}';
			case 'settings.noChanges': return '暂无更新内容';
			case 'settings.interaction': return '交互';
			case 'settings.enableVibration': return '启用震动';
			case 'settings.enableVibrationDesc': return '启用应用交互时的震动反馈';
			case 'settings.defaultKeepVideoToolbarVisible': return '保持工具栏常驻';
			case 'settings.defaultKeepVideoToolbarVisibleDesc': return '此设置决定首次进入视频页面时是否保持工具栏常驻显示。';
			case 'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt': return '移动端开启剧院模式可能会造成性能问题，可酌情开启。';
			case 'settings.lockButtonPosition': return '锁定按钮位置';
			case 'settings.lockButtonPositionBothSides': return '两侧显示';
			case 'settings.lockButtonPositionLeftSide': return '仅左侧显示';
			case 'settings.lockButtonPositionRightSide': return '仅右侧显示';
			case 'settings.jumpLink': return '跳转链接';
			case 'settings.language': return '语言';
			case 'settings.languageChanged': return '语言设置已更改，请重启应用以生效。';
			case 'settings.gestureControl': return '手势控制';
			case 'settings.leftDoubleTapRewind': return '左侧双击后退';
			case 'settings.rightDoubleTapFastForward': return '右侧双击快进';
			case 'settings.doubleTapPause': return '双击暂停';
			case 'settings.leftVerticalSwipeVolume': return '左侧上下滑动调整音量（进入新页面时生效）';
			case 'settings.rightVerticalSwipeBrightness': return '右侧上下滑动调整亮度（进入新页面时生效）';
			case 'settings.longPressFastForward': return '长按快进';
			case 'settings.enableMouseHoverShowToolbar': return '鼠标悬浮时显示工具栏';
			case 'settings.enableMouseHoverShowToolbarInfo': return '开启后，当鼠标悬浮在播放器上移动时会自动显示工具栏，停止移动3秒后自动隐藏';
			case 'settings.audioVideoConfig': return '音视频配置';
			case 'settings.expandBuffer': return '扩大缓冲区';
			case 'settings.expandBufferInfo': return '开启后缓冲区增大，加载时间变长但播放更流畅';
			case 'settings.videoSyncMode': return '视频同步模式';
			case 'settings.videoSyncModeSubtitle': return '音视频同步策略';
			case 'settings.hardwareDecodingMode': return '硬解模式';
			case 'settings.hardwareDecodingModeSubtitle': return '硬件解码设置';
			case 'settings.enableHardwareAcceleration': return '启用硬件加速';
			case 'settings.enableHardwareAccelerationInfo': return '开启硬件加速可以提高解码性能，但某些设备可能不兼容';
			case 'settings.useOpenSLESAudioOutput': return '使用OpenSLES音频输出';
			case 'settings.useOpenSLESAudioOutputInfo': return '使用低延迟音频输出，可能提高音频性能';
			case 'settings.videoSyncAudio': return '音频同步';
			case 'settings.videoSyncDisplayResample': return '显示重采样';
			case 'settings.videoSyncDisplayResampleVdrop': return '显示重采样(丢帧)';
			case 'settings.videoSyncDisplayResampleDesync': return '显示重采样(去同步)';
			case 'settings.videoSyncDisplayTempo': return '显示节拍';
			case 'settings.videoSyncDisplayVdrop': return '显示丢视频帧';
			case 'settings.videoSyncDisplayAdrop': return '显示丢音频帧';
			case 'settings.videoSyncDisplayDesync': return '显示去同步';
			case 'settings.videoSyncDesync': return '去同步';
			case 'settings.hardwareDecodingAuto': return '自动';
			case 'settings.hardwareDecodingAutoCopy': return '自动复制';
			case 'settings.hardwareDecodingAutoSafe': return '自动安全';
			case 'settings.hardwareDecodingNo': return '禁用';
			case 'settings.hardwareDecodingYes': return '强制启用';
			case 'settings.downloadSettings.downloadSettings': return '下载设置';
			case 'settings.downloadSettings.storagePermissionStatus': return '存储权限状态';
			case 'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission': return '访问公共目录需要存储权限';
			case 'settings.downloadSettings.checkingPermissionStatus': return '检查权限状态...';
			case 'settings.downloadSettings.storagePermissionGranted': return '已授权存储权限';
			case 'settings.downloadSettings.storagePermissionNotGranted': return '需要存储权限';
			case 'settings.downloadSettings.storagePermissionGrantSuccess': return '存储权限授权成功';
			case 'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited': return '存储权限授权失败，部分功能可能受限';
			case 'settings.downloadSettings.grantStoragePermission': return '授权存储权限';
			case 'settings.downloadSettings.customDownloadPath': return '自定义下载位置';
			case 'settings.downloadSettings.customDownloadPathDescription': return '启用后可以为下载的文件选择自定义保存位置';
			case 'settings.downloadSettings.customDownloadPathTip': return '💡 提示：选择公共目录（如下载文件夹）需要授予存储权限，建议优先使用推荐路径';
			case 'settings.downloadSettings.androidWarning': return 'Android提示：避免选择公共目录（如下载文件夹），建议使用应用专用目录以确保访问权限。';
			case 'settings.downloadSettings.publicDirectoryPermissionTip': return '⚠️ 注意：您选择的是公共目录，需要存储权限才能正常下载文件';
			case 'settings.downloadSettings.permissionRequiredForPublicDirectory': return '选择公共目录需要存储权限';
			case 'settings.downloadSettings.currentDownloadPath': return '当前下载路径';
			case 'settings.downloadSettings.defaultAppDirectory': return '应用默认目录';
			case 'settings.downloadSettings.permissionGranted': return '已授权';
			case 'settings.downloadSettings.permissionRequired': return '需要权限';
			case 'settings.downloadSettings.enableCustomDownloadPath': return '启用自定义下载路径';
			case 'settings.downloadSettings.disableCustomDownloadPath': return '关闭时使用应用默认路径';
			case 'settings.downloadSettings.customDownloadPathLabel': return '自定义下载路径';
			case 'settings.downloadSettings.selectDownloadFolder': return '选择下载文件夹';
			case 'settings.downloadSettings.recommendedPath': return '推荐路径';
			case 'settings.downloadSettings.selectFolder': return '选择文件夹';
			case 'settings.downloadSettings.filenameTemplate': return '文件命名模板';
			case 'settings.downloadSettings.filenameTemplateDescription': return '自定义下载文件的命名规则，支持变量替换';
			case 'settings.downloadSettings.videoFilenameTemplate': return '视频文件命名模板';
			case 'settings.downloadSettings.galleryFolderTemplate': return '图库文件夹命名模板';
			case 'settings.downloadSettings.imageFilenameTemplate': return '单张图片命名模板';
			case 'settings.downloadSettings.resetToDefault': return '重置为默认值';
			case 'settings.downloadSettings.supportedVariables': return '支持的变量';
			case 'settings.downloadSettings.supportedVariablesDescription': return '在文件命名模板中可以使用以下变量：';
			case 'settings.downloadSettings.copyVariable': return '复制变量';
			case 'settings.downloadSettings.variableCopied': return '变量已复制';
			case 'settings.downloadSettings.warningPublicDirectory': return '警告：选择的是公共目录，可能无法访问。建议选择应用专用目录。';
			case 'settings.downloadSettings.downloadPathUpdated': return '下载路径已更新';
			case 'settings.downloadSettings.selectPathFailed': return '选择路径失败';
			case 'settings.downloadSettings.recommendedPathSet': return '已设置为推荐路径';
			case 'settings.downloadSettings.setRecommendedPathFailed': return '设置推荐路径失败';
			case 'settings.downloadSettings.templateResetToDefault': return '已重置为默认模板';
			case 'settings.downloadSettings.functionalTest': return '功能测试';
			case 'settings.downloadSettings.testInProgress': return '测试中...';
			case 'settings.downloadSettings.runTest': return '运行测试';
			case 'settings.downloadSettings.testDownloadPathAndPermissions': return '测试下载路径和权限配置是否正常工作';
			case 'settings.downloadSettings.testResults': return '测试结果';
			case 'settings.downloadSettings.testCompleted': return '测试完成';
			case 'settings.downloadSettings.testPassed': return '项通过';
			case 'settings.downloadSettings.testFailed': return '测试失败';
			case 'settings.downloadSettings.testStoragePermissionCheck': return '存储权限检查';
			case 'settings.downloadSettings.testStoragePermissionGranted': return '已获得存储权限';
			case 'settings.downloadSettings.testStoragePermissionMissing': return '缺少存储权限，部分功能可能受限';
			case 'settings.downloadSettings.testPermissionCheckFailed': return '权限检查失败';
			case 'settings.downloadSettings.testDownloadPathValidation': return '下载路径验证';
			case 'settings.downloadSettings.testPathValidationFailed': return '路径验证失败';
			case 'settings.downloadSettings.testFilenameTemplateValidation': return '文件命名模板验证';
			case 'settings.downloadSettings.testAllTemplatesValid': return '所有模板都有效';
			case 'settings.downloadSettings.testSomeTemplatesInvalid': return '部分模板包含无效字符';
			case 'settings.downloadSettings.testTemplateValidationFailed': return '模板验证失败';
			case 'settings.downloadSettings.testDirectoryOperationTest': return '目录操作测试';
			case 'settings.downloadSettings.testDirectoryOperationNormal': return '目录创建和文件写入正常';
			case 'settings.downloadSettings.testDirectoryOperationFailed': return '目录操作失败';
			case 'settings.downloadSettings.testVideoTemplate': return '视频模板';
			case 'settings.downloadSettings.testGalleryTemplate': return '图库模板';
			case 'settings.downloadSettings.testImageTemplate': return '图片模板';
			case 'settings.downloadSettings.testValid': return '有效';
			case 'settings.downloadSettings.testInvalid': return '无效';
			case 'settings.downloadSettings.testSuccess': return '成功';
			case 'settings.downloadSettings.testCorrect': return '正确';
			case 'settings.downloadSettings.testError': return '错误';
			case 'settings.downloadSettings.testPath': return '测试路径';
			case 'settings.downloadSettings.testBasePath': return '基础路径';
			case 'settings.downloadSettings.testDirectoryCreation': return '目录创建';
			case 'settings.downloadSettings.testFileWriting': return '文件写入';
			case 'settings.downloadSettings.testFileContent': return '文件内容';
			case 'settings.downloadSettings.checkingPathStatus': return '检查路径状态...';
			case 'settings.downloadSettings.unableToGetPathStatus': return '无法获取路径状态';
			case 'settings.downloadSettings.actualPathDifferentFromSelected': return '注意：实际使用路径与选择路径不同';
			case 'settings.downloadSettings.grantPermission': return '授权权限';
			case 'settings.downloadSettings.fixIssue': return '修复问题';
			case 'settings.downloadSettings.issueFixed': return '问题已修复';
			case 'settings.downloadSettings.fixFailed': return '修复失败，请手动处理';
			case 'settings.downloadSettings.lackStoragePermission': return '缺少存储权限';
			case 'settings.downloadSettings.cannotAccessPublicDirectory': return '无法访问公共目录，需要"所有文件访问权限"';
			case 'settings.downloadSettings.cannotCreateDirectory': return '无法创建目录';
			case 'settings.downloadSettings.directoryNotWritable': return '目录不可写';
			case 'settings.downloadSettings.insufficientSpace': return '可用空间不足';
			case 'settings.downloadSettings.pathValid': return '路径有效';
			case 'settings.downloadSettings.validationFailed': return '验证失败';
			case 'settings.downloadSettings.usingDefaultAppDirectory': return '使用默认应用目录';
			case 'settings.downloadSettings.appPrivateDirectory': return '应用专用目录';
			case 'settings.downloadSettings.appPrivateDirectoryDesc': return '安全可靠，无需额外权限';
			case 'settings.downloadSettings.downloadDirectory': return '下载目录';
			case 'settings.downloadSettings.downloadDirectoryDesc': return '系统默认下载位置，便于管理';
			case 'settings.downloadSettings.moviesDirectory': return '影片目录';
			case 'settings.downloadSettings.moviesDirectoryDesc': return '系统影片目录，媒体应用可识别';
			case 'settings.downloadSettings.documentsDirectory': return '文档目录';
			case 'settings.downloadSettings.documentsDirectoryDesc': return 'iOS应用文档目录';
			case 'settings.downloadSettings.requiresStoragePermission': return '需要存储权限才能访问';
			case 'settings.downloadSettings.recommendedPaths': return '推荐路径';
			case 'settings.downloadSettings.selectRecommendedDownloadLocation': return '选择一个推荐的下载位置';
			case 'settings.downloadSettings.noRecommendedPaths': return '暂无推荐路径';
			case 'settings.downloadSettings.recommended': return '推荐';
			case 'settings.downloadSettings.requiresPermission': return '需要权限';
			case 'settings.downloadSettings.authorizeAndSelect': return '授权并选择';
			case 'settings.downloadSettings.select': return '选择';
			case 'settings.downloadSettings.permissionAuthorizationFailed': return '权限授权失败，无法选择此路径';
			case 'settings.downloadSettings.pathValidationFailed': return '路径验证失败';
			case 'settings.downloadSettings.downloadPathSetTo': return '下载路径已设置为';
			case 'settings.downloadSettings.setPathFailed': return '设置路径失败';
			case 'settings.downloadSettings.variableTitle': return '标题';
			case 'settings.downloadSettings.variableAuthor': return '作者名称';
			case 'settings.downloadSettings.variableUsername': return '作者用户名';
			case 'settings.downloadSettings.variableQuality': return '视频质量';
			case 'settings.downloadSettings.variableFilename': return '原始文件名';
			case 'settings.downloadSettings.variableId': return '内容ID';
			case 'settings.downloadSettings.variableCount': return '图库图片数量';
			case 'settings.downloadSettings.variableDate': return '当前日期 (YYYY-MM-DD)';
			case 'settings.downloadSettings.variableTime': return '当前时间 (HH-MM-SS)';
			case 'settings.downloadSettings.variableDatetime': return '当前日期时间 (YYYY-MM-DD_HH-MM-SS)';
			case 'settings.downloadSettings.downloadSettingsTitle': return '下载设置';
			case 'settings.downloadSettings.downloadSettingsSubtitle': return '配置下载路径和文件命名规则';
			case 'settings.downloadSettings.suchAsTitleQuality': return '例如: %title_%quality';
			case 'settings.downloadSettings.suchAsTitleId': return '例如: %title_%id';
			case 'settings.downloadSettings.suchAsTitleFilename': return '例如: %title_%filename';
			case 'oreno3d.name': return 'Oreno3D';
			case 'oreno3d.tags': return '标签';
			case 'oreno3d.characters': return '角色';
			case 'oreno3d.origin': return '原作';
			case 'oreno3d.thirdPartyTagsExplanation': return '此处显示的**标签**、**角色**和**原作**信息来自第三方站点 **Oreno3D**，仅供参考。\n\n由于此信息来源只有日文，目前缺乏国际化适配。\n\n如果你有兴趣参与国际化建设，欢迎访问相关仓库贡献你的力量！';
			case 'oreno3d.sortTypes.hot': return '急上昇';
			case 'oreno3d.sortTypes.favorites': return '高評価';
			case 'oreno3d.sortTypes.latest': return '新着';
			case 'oreno3d.sortTypes.popularity': return '人気';
			case 'oreno3d.errors.requestFailed': return '请求失败，状态码';
			case 'oreno3d.errors.connectionTimeout': return '连接超时，请检查网络连接';
			case 'oreno3d.errors.sendTimeout': return '发送请求超时';
			case 'oreno3d.errors.receiveTimeout': return '接收响应超时';
			case 'oreno3d.errors.badCertificate': return '证书验证失败';
			case 'oreno3d.errors.resourceNotFound': return '请求的资源不存在';
			case 'oreno3d.errors.accessDenied': return '访问被拒绝，可能需要验证或权限';
			case 'oreno3d.errors.serverError': return '服务器内部错误';
			case 'oreno3d.errors.serviceUnavailable': return '服务暂时不可用';
			case 'oreno3d.errors.requestCancelled': return '请求已取消';
			case 'oreno3d.errors.connectionError': return '网络连接错误，请检查网络设置';
			case 'oreno3d.errors.networkRequestFailed': return '网络请求失败';
			case 'oreno3d.errors.searchVideoError': return '搜索视频时发生未知错误';
			case 'oreno3d.errors.getPopularVideoError': return '获取热门视频时发生未知错误';
			case 'oreno3d.errors.getVideoDetailError': return '获取视频详情时发生未知错误';
			case 'oreno3d.errors.parseVideoDetailError': return '获取并解析视频详情时发生未知错误';
			case 'oreno3d.errors.downloadFileError': return '下载文件时发生未知错误';
			case 'oreno3d.loading.gettingVideoInfo': return '正在获取视频信息...';
			case 'oreno3d.loading.cancel': return '取消';
			case 'oreno3d.messages.videoNotFoundOrDeleted': return '视频不存在或已被删除';
			case 'oreno3d.messages.unableToGetVideoPlayLink': return '无法获取视频播放链接';
			case 'oreno3d.messages.getVideoDetailFailed': return '获取视频详情失败';
			case 'signIn.pleaseLoginFirst': return '请先登录';
			case 'signIn.alreadySignedInToday': return '您今天已经签到过了！';
			case 'signIn.youDidNotStickToTheSignIn': return '您未能坚持签到。';
			case 'signIn.signInSuccess': return '签到成功！';
			case 'signIn.signInFailed': return '签到失败，请稍后再试';
			case 'signIn.consecutiveSignIns': return '连续签到天数';
			case 'signIn.failureReason': return '未能坚持签到的原因';
			case 'signIn.selectDateRange': return '选择日期范围';
			case 'signIn.startDate': return '开始日期';
			case 'signIn.endDate': return '结束日期';
			case 'signIn.invalidDate': return '日期格式错误';
			case 'signIn.invalidDateRange': return '日期范围无效';
			case 'signIn.errorFormatText': return '日期格式错误';
			case 'signIn.errorInvalidText': return '日期范围无效';
			case 'signIn.errorInvalidRangeText': return '日期范围无效';
			case 'signIn.dateRangeCantBeMoreThanOneYear': return '日期范围不能超过1年';
			case 'signIn.signIn': return '签到';
			case 'signIn.signInRecord': return '签到记录';
			case 'signIn.totalSignIns': return '总成功签到';
			case 'signIn.pleaseSelectSignInStatus': return '请选择签到状态';
			case 'subscriptions.pleaseLoginFirstToViewYourSubscriptions': return '请登录以查看您的订阅内容。';
			case 'subscriptions.selectUser': return '选择用户';
			case 'subscriptions.noSubscribedUsers': return '暂无已订阅的用户';
			case 'videoDetail.pipMode': return '画中画模式';
			case 'videoDetail.resumeFromLastPosition': return ({required Object position}) => '从上次播放位置继续播放: ${position}';
			case 'videoDetail.videoIdIsEmpty': return '视频ID为空';
			case 'videoDetail.videoInfoIsEmpty': return '视频信息为空';
			case 'videoDetail.thisIsAPrivateVideo': return '这是一个私密视频';
			case 'videoDetail.getVideoInfoFailed': return '获取视频信息失败，请稍后再试';
			case 'videoDetail.noVideoSourceFound': return '未找到对应的视频源';
			case 'videoDetail.tagCopiedToClipboard': return ({required Object tagId}) => '标签 "${tagId}" 已复制到剪贴板';
			case 'videoDetail.errorLoadingVideo': return '在加载视频时出现了错误';
			case 'videoDetail.play': return '播放';
			case 'videoDetail.pause': return '暂停';
			case 'videoDetail.exitAppFullscreen': return '退出应用全屏';
			case 'videoDetail.enterAppFullscreen': return '应用全屏';
			case 'videoDetail.exitSystemFullscreen': return '退出系统全屏';
			case 'videoDetail.enterSystemFullscreen': return '系统全屏';
			case 'videoDetail.seekTo': return '跳转到指定时间';
			case 'videoDetail.switchResolution': return '切换分辨率';
			case 'videoDetail.switchPlaybackSpeed': return '切换播放倍速';
			case 'videoDetail.rewindSeconds': return ({required Object num}) => '后退${num}秒';
			case 'videoDetail.fastForwardSeconds': return ({required Object num}) => '快进${num}秒';
			case 'videoDetail.playbackSpeedIng': return ({required Object rate}) => '正在以${rate}倍速播放';
			case 'videoDetail.brightness': return '亮度';
			case 'videoDetail.brightnessLowest': return '亮度已最低';
			case 'videoDetail.volume': return '音量';
			case 'videoDetail.volumeMuted': return '音量已静音';
			case 'videoDetail.home': return '主页';
			case 'videoDetail.videoPlayer': return '视频播放器';
			case 'videoDetail.videoPlayerInfo': return '播放器信息';
			case 'videoDetail.moreSettings': return '更多设置';
			case 'videoDetail.videoPlayerFeatureInfo': return '播放器功能介绍';
			case 'videoDetail.autoRewind': return '自动重播';
			case 'videoDetail.rewindAndFastForward': return '左右两侧双击快进或后退';
			case 'videoDetail.volumeAndBrightness': return '左右两侧垂直滑动调整音量、亮度';
			case 'videoDetail.centerAreaDoubleTapPauseOrPlay': return '中心区域双击暂停或播放';
			case 'videoDetail.showVerticalVideoInFullScreen': return '在全屏时可以以竖屏方式显示竖屏视频';
			case 'videoDetail.keepLastVolumeAndBrightness': return '保持上次调整的音量、亮度';
			case 'videoDetail.setProxy': return '设置代理';
			case 'videoDetail.moreFeaturesToBeDiscovered': return '更多功能待发现...';
			case 'videoDetail.videoPlayerSettings': return '播放器设置';
			case 'videoDetail.commentCount': return ({required Object num}) => '评论 ${num} 条';
			case 'videoDetail.writeYourCommentHere': return '写下你的评论...';
			case 'videoDetail.authorOtherVideos': return '作者的其他视频';
			case 'videoDetail.relatedVideos': return '相关视频';
			case 'videoDetail.privateVideo': return '这是一个私密视频';
			case 'videoDetail.externalVideo': return '这是一个站外视频';
			case 'videoDetail.openInBrowser': return '在浏览器中打开';
			case 'videoDetail.resourceDeleted': return '这个视频貌似被删除了 :/';
			case 'videoDetail.noDownloadUrl': return '没有下载链接';
			case 'videoDetail.startDownloading': return '开始下载';
			case 'videoDetail.downloadFailed': return '下载失败，请稍后再试';
			case 'videoDetail.downloadSuccess': return '下载成功';
			case 'videoDetail.download': return '下载';
			case 'videoDetail.downloadManager': return '下载管理';
			case 'videoDetail.videoLoadError': return '视频加载错误';
			case 'videoDetail.resourceNotFound': return '资源未找到';
			case 'videoDetail.authorNoOtherVideos': return '作者暂无其他视频';
			case 'videoDetail.noRelatedVideos': return '暂无相关视频';
			case 'share.sharePlayList': return '分享播放列表';
			case 'share.wowDidYouSeeThis': return '哇哦，你看过这个吗？';
			case 'share.nameIs': return '名字叫做';
			case 'share.clickLinkToView': return '点击链接查看';
			case 'share.iReallyLikeThis': return '我真的是太喜欢这个了，你也来看看吧！';
			case 'share.shareFailed': return '分享失败，请稍后再试';
			case 'share.share': return '分享';
			case 'share.shareAsImage': return '分享为图片';
			case 'share.shareAsText': return '分享为文本';
			case 'share.shareAsImageDesc': return '将视频封面分享为图片';
			case 'share.shareAsTextDesc': return '将视频详情分享为文本';
			case 'share.shareAsImageFailed': return '分享视频封面为图片失败，请稍后再试';
			case 'share.shareAsTextFailed': return '分享视频详情为文本失败，请稍后再试';
			case 'share.shareVideo': return '分享视频';
			case 'share.authorIs': return '作者是';
			case 'share.shareGallery': return '分享图库';
			case 'share.galleryTitleIs': return '图库名字叫做';
			case 'share.galleryAuthorIs': return '图库作者是';
			case 'share.shareUser': return '分享用户';
			case 'share.userNameIs': return '用户名字叫做';
			case 'share.userAuthorIs': return '用户作者是';
			case 'share.comments': return '评论';
			case 'share.shareThread': return '分享帖子';
			case 'share.views': return '浏览';
			case 'share.sharePost': return '分享投稿';
			case 'share.postTitleIs': return '投稿名字叫做';
			case 'share.postAuthorIs': return '投稿作者是';
			case 'markdown.markdownSyntax': return 'Markdown 语法';
			case 'markdown.iwaraSpecialMarkdownSyntax': return 'Iwara 专用语法';
			case 'markdown.internalLink': return '站内链接';
			case 'markdown.supportAutoConvertLinkBelow': return '支持自动转换以下类型的链接：';
			case 'markdown.convertLinkExample': return '🎬 视频链接\n🖼️ 图片链接\n👤 用户链接\n📌 论坛链接\n🎵 播放列表链接\n💬 投稿链接';
			case 'markdown.mentionUser': return '提及用户';
			case 'markdown.mentionUserDescription': return '输入@后跟用户名，将自动转换为用户链接';
			case 'markdown.markdownBasicSyntax': return 'Markdown 基本语法';
			case 'markdown.paragraphAndLineBreak': return '段落与换行';
			case 'markdown.paragraphAndLineBreakDescription': return '段落之间空一行，行末加两个空格实现换行';
			case 'markdown.paragraphAndLineBreakSyntax': return '这是第一段文字\n\n这是第二段文字\n这一行后面加两个空格  \n就能换行了';
			case 'markdown.textStyle': return '文本样式';
			case 'markdown.textStyleDescription': return '使用特殊符号包围文本来改变样式';
			case 'markdown.textStyleSyntax': return '**粗体文本**\n*斜体文本*\n~~删除线文本~~\n`代码文本`';
			case 'markdown.quote': return '引用';
			case 'markdown.quoteDescription': return '使用 > 符号创建引用，多个 > 创建多级引用';
			case 'markdown.quoteSyntax': return '> 这是一级引用\n>> 这是二级引用';
			case 'markdown.list': return '列表';
			case 'markdown.listDescription': return '使用数字+点号创建有序列表，使用 - 创建无序列表';
			case 'markdown.listSyntax': return '1. 第一项\n2. 第二项\n\n- 无序项\n  - 子项\n  - 另一个子项';
			case 'markdown.linkAndImage': return '链接与图片';
			case 'markdown.linkAndImageDescription': return '链接格式：[文字](URL)\n图片格式：![描述](URL)';
			case 'markdown.linkAndImageSyntax': return ({required Object link, required Object imgUrl}) => '[链接文字](${link})\n![图片描述](${imgUrl})';
			case 'markdown.title': return '标题';
			case 'markdown.titleDescription': return '使用 # 号创建标题，数量表示级别';
			case 'markdown.titleSyntax': return '# 一级标题\n## 二级标题\n### 三级标题';
			case 'markdown.separator': return '分隔线';
			case 'markdown.separatorDescription': return '使用三个或更多 - 号创建分隔线';
			case 'markdown.separatorSyntax': return '---';
			case 'markdown.syntax': return '语法';
			case 'forum.recent': return '最近';
			case 'forum.category': return '分类';
			case 'forum.lastReply': return '最后回复';
			case 'forum.errors.pleaseSelectCategory': return '请选择分类';
			case 'forum.errors.threadLocked': return '该主题已锁定，无法回复';
			case 'forum.createPost': return '创建帖子';
			case 'forum.title': return '标题';
			case 'forum.enterTitle': return '输入标题';
			case 'forum.content': return '内容';
			case 'forum.enterContent': return '输入内容';
			case 'forum.writeYourContentHere': return '在此输入内容...';
			case 'forum.posts': return '帖子';
			case 'forum.threads': return '主题';
			case 'forum.forum': return '论坛';
			case 'forum.createThread': return '创建主题';
			case 'forum.selectCategory': return '选择分类';
			case 'forum.cooldownRemaining': return ({required Object minutes, required Object seconds}) => '冷却剩余时间 ${minutes} 分 ${seconds} 秒';
			case 'forum.groups.administration': return '管理';
			case 'forum.groups.global': return '全球';
			case 'forum.groups.chinese': return '中文';
			case 'forum.groups.japanese': return '日语';
			case 'forum.groups.korean': return '韩语';
			case 'forum.groups.other': return '其他';
			case 'forum.leafNames.announcements': return '公告';
			case 'forum.leafNames.feedback': return '反馈';
			case 'forum.leafNames.support': return '帮助';
			case 'forum.leafNames.general': return '一般';
			case 'forum.leafNames.guides': return '指南';
			case 'forum.leafNames.questions': return '问题';
			case 'forum.leafNames.requests': return '请求';
			case 'forum.leafNames.sharing': return '分享';
			case 'forum.leafNames.general_zh': return '一般';
			case 'forum.leafNames.questions_zh': return '问题';
			case 'forum.leafNames.requests_zh': return '请求';
			case 'forum.leafNames.support_zh': return '帮助';
			case 'forum.leafNames.general_ja': return '一般';
			case 'forum.leafNames.questions_ja': return '问题';
			case 'forum.leafNames.requests_ja': return '请求';
			case 'forum.leafNames.support_ja': return '帮助';
			case 'forum.leafNames.korean': return '韩语';
			case 'forum.leafNames.other': return '其他';
			case 'forum.leafDescriptions.announcements': return '官方重要通知和公告';
			case 'forum.leafDescriptions.feedback': return '对网站功能和服务的反馈';
			case 'forum.leafDescriptions.support': return '帮助解决网站相关问题';
			case 'forum.leafDescriptions.general': return '讨论任何话题';
			case 'forum.leafDescriptions.guides': return '分享你的经验和教程';
			case 'forum.leafDescriptions.questions': return '提出你的疑问';
			case 'forum.leafDescriptions.requests': return '发布你的请求';
			case 'forum.leafDescriptions.sharing': return '分享有趣的内容';
			case 'forum.leafDescriptions.general_zh': return '讨论任何话题';
			case 'forum.leafDescriptions.questions_zh': return '提出你的疑问';
			case 'forum.leafDescriptions.requests_zh': return '发布你的请求';
			case 'forum.leafDescriptions.support_zh': return '帮助解决网站相关问题';
			case 'forum.leafDescriptions.general_ja': return '讨论任何话题';
			case 'forum.leafDescriptions.questions_ja': return '提出你的疑问';
			case 'forum.leafDescriptions.requests_ja': return '发布你的请求';
			case 'forum.leafDescriptions.support_ja': return '帮助解决网站相关问题';
			case 'forum.leafDescriptions.korean': return '韩语相关讨论';
			case 'forum.leafDescriptions.other': return '其他未分类的内容';
			case 'forum.reply': return '回覆';
			case 'forum.pendingReview': return '审核中';
			case 'forum.editedAt': return '编辑时间';
			case 'forum.copySuccess': return '已复制到剪贴板';
			case 'forum.copySuccessForMessage': return ({required Object str}) => '已复制到剪贴板: ${str}';
			case 'forum.editReply': return '编辑回覆';
			case 'forum.editTitle': return '编辑标题';
			case 'forum.submit': return '提交';
			case 'notifications.errors.unsupportedNotificationType': return '暂不支持的通知类型';
			case 'notifications.errors.unknownUser': return '未知用户';
			case 'notifications.errors.unsupportedNotificationTypeWithType': return ({required Object type}) => '暂不支持的通知类型: ${type}';
			case 'notifications.errors.unknownNotificationType': return '未知通知类型';
			case 'notifications.notifications': return '通知';
			case 'notifications.video': return '视频';
			case 'notifications.profile': return '个人主页';
			case 'notifications.postedNewComment': return '发表了评论';
			case 'notifications.inYour': return '在您的';
			case 'notifications.copyInfoToClipboard': return '复制通知信息到剪贴簿';
			case 'notifications.copySuccess': return '已复制到剪贴板';
			case 'notifications.copySuccessForMessage': return ({required Object str}) => '已复制到剪贴板: ${str}';
			case 'notifications.markAllAsRead': return '全部标记已读';
			case 'notifications.markAllAsReadSuccess': return '所有通知已标记为已读';
			case 'notifications.markAllAsReadFailed': return '全部标记已读失败';
			case 'notifications.markSelectedAsRead': return '标记选中项为已读';
			case 'notifications.markSelectedAsReadSuccess': return '选中的通知已标记为已读';
			case 'notifications.markSelectedAsReadFailed': return '标记选中项为已读失败';
			case 'notifications.markAsRead': return '标记已读';
			case 'notifications.markAsReadSuccess': return '已标记为已读';
			case 'notifications.markAsReadFailed': return '标记已读失败';
			case 'notifications.notificationTypeHelp': return '通知类型帮助';
			case 'notifications.dueToLackOfNotificationTypeDetails': return '通知类型的详细信息不足，目前支持的类型可能没有覆盖到您当前收到的消息';
			case 'notifications.helpUsImproveNotificationTypeSupport': return '如果您愿意帮助我们完善通知类型的支持';
			case 'notifications.helpUsImproveNotificationTypeSupportLongText': return '1. 📋 复制通知信息\n2. 🐞 前往项目仓库提交 issue\n\n⚠️ 注意：通知信息可能包含个人隐私，如果你不想公开，也可以通过邮件发送给项目作者。';
			case 'notifications.goToRepository': return '前往项目仓库';
			case 'notifications.copy': return '复制';
			case 'notifications.commentApproved': return '评论已通过审核';
			case 'notifications.repliedYourProfileComment': return '回复了您的个人主页评论';
			case 'notifications.repliedYourVideoComment': return '回复了您的视频评论';
			case 'notifications.kReplied': return '回复了您在';
			case 'notifications.kCommented': return '评论了您的';
			case 'notifications.kVideo': return '视频';
			case 'notifications.kGallery': return '图库';
			case 'notifications.kProfile': return '主页';
			case 'notifications.kThread': return '主题';
			case 'notifications.kPost': return '投稿';
			case 'notifications.kCommentSection': return '下的评论';
			case 'notifications.kApprovedComment': return '评论审核通过';
			case 'notifications.kApprovedVideo': return '视频审核通过';
			case 'notifications.kApprovedGallery': return '图库审核通过';
			case 'notifications.kApprovedThread': return '帖子审核通过';
			case 'notifications.kApprovedPost': return '投稿审核通过';
			case 'notifications.kUnknownType': return '未知通知类型';
			case 'conversation.errors.pleaseSelectAUser': return '请选择一个用户';
			case 'conversation.errors.pleaseEnterATitle': return '请输入标题';
			case 'conversation.errors.clickToSelectAUser': return '点击选择用户';
			case 'conversation.errors.loadFailedClickToRetry': return '加载失败,点击重试';
			case 'conversation.errors.loadFailed': return '加载失败';
			case 'conversation.errors.clickToRetry': return '点击重试';
			case 'conversation.errors.noMoreConversations': return '没有更多消息了';
			case 'conversation.conversation': return '会话';
			case 'conversation.startConversation': return '发起会话';
			case 'conversation.noConversation': return '暂无会话';
			case 'conversation.selectFromLeftListAndStartConversation': return '从左侧的会话列表选择一个对话开始聊天';
			case 'conversation.title': return '标题';
			case 'conversation.body': return '内容';
			case 'conversation.selectAUser': return '选择用户';
			case 'conversation.searchUsers': return '搜索用户...';
			case 'conversation.tmpNoConversions': return '暂无会话';
			case 'conversation.deleteThisMessage': return '删除此消息';
			case 'conversation.deleteThisMessageSubtitle': return '此操作不可撤销';
			case 'conversation.writeMessageHere': return '在此处输入消息';
			case 'conversation.sendMessage': return '发送消息';
			case 'splash.errors.initializationFailed': return '初始化失败，请重启应用';
			case 'splash.preparing': return '准备中...';
			case 'splash.initializing': return '初始化中...';
			case 'splash.loading': return '加载中...';
			case 'splash.ready': return '准备完成';
			case 'splash.initializingMessageService': return '初始化消息服务中...';
			case 'download.errors.imageModelNotFound': return '图库信息不存在';
			case 'download.errors.downloadFailed': return '下载失败';
			case 'download.errors.videoInfoNotFound': return '视频信息不存在';
			case 'download.errors.unknown': return '未知';
			case 'download.errors.downloadTaskAlreadyExists': return '下载任务已存在';
			case 'download.errors.videoAlreadyDownloaded': return '该视频已下载';
			case 'download.errors.downloadFailedForMessage': return ({required Object errorInfo}) => '添加下载任务失败: ${errorInfo}';
			case 'download.errors.userPausedDownload': return '用户暂停下载';
			case 'download.errors.fileSystemError': return ({required Object errorInfo}) => '文件系统错误: ${errorInfo}';
			case 'download.errors.unknownError': return ({required Object errorInfo}) => '未知错误: ${errorInfo}';
			case 'download.errors.connectionTimeout': return '连接超时';
			case 'download.errors.sendTimeout': return '发送超时';
			case 'download.errors.receiveTimeout': return '接收超时';
			case 'download.errors.serverError': return ({required Object errorInfo}) => '服务器错误: ${errorInfo}';
			case 'download.errors.unknownNetworkError': return '未知网络错误';
			case 'download.errors.serviceIsClosing': return '下载服务正在关闭';
			case 'download.errors.partialDownloadFailed': return '部分内容下载失败';
			case 'download.errors.noDownloadTask': return '暂无下载任务';
			case 'download.errors.taskNotFoundOrDataError': return '任务不存在或数据错误';
			case 'download.errors.copyDownloadUrlFailed': return '复制下载链接失败';
			case 'download.errors.fileNotFound': return '文件不存在';
			case 'download.errors.openFolderFailed': return '打开文件夹失败';
			case 'download.errors.openFolderFailedWithMessage': return ({required Object message}) => '打开文件夹失败: ${message}';
			case 'download.errors.directoryNotFound': return '目录不存在';
			case 'download.errors.copyFailed': return '复制失败';
			case 'download.errors.openFileFailed': return '打开文件失败';
			case 'download.errors.openFileFailedWithMessage': return ({required Object message}) => '打开文件失败: ${message}';
			case 'download.errors.noDownloadSource': return '没有下载源';
			case 'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded': return '暂无下载源，请等待信息加载完成后重试';
			case 'download.errors.noActiveDownloadTask': return '暂无正在下载的任务';
			case 'download.errors.noFailedDownloadTask': return '暂无失败的任务';
			case 'download.errors.noCompletedDownloadTask': return '暂无已完成的任务';
			case 'download.errors.taskAlreadyCompletedDoNotAdd': return '任务已完成，请勿重复添加';
			case 'download.errors.linkExpiredTryAgain': return '链接已过期，正在重新获取下载链接';
			case 'download.errors.linkExpiredTryAgainSuccess': return '链接已过期，正在重新获取下载链接成功';
			case 'download.errors.linkExpiredTryAgainFailed': return '链接已过期,正在重新获取下载链接失败';
			case 'download.errors.taskDeleted': return '任务已删除';
			case 'download.errors.unsupportedImageFormat': return ({required Object format}) => '不支持的图片格式: ${format}';
			case 'download.errors.deleteFileError': return '文件删除失败，可能是因为文件被占用';
			case 'download.errors.deleteTaskError': return '任务删除失败';
			case 'download.errors.taskNotFound': return '任务未找到';
			case 'download.errors.canNotRefreshVideoTask': return '无法刷新视频任务';
			case 'download.errors.taskAlreadyProcessing': return '任务已处理中';
			case 'download.errors.failedToLoadTasks': return '加载任务失败';
			case 'download.errors.partialDownloadFailedWithMessage': return ({required Object message}) => '部分下载失败: ${message}';
			case 'download.errors.unsupportedImageFormatWithMessage': return ({required Object extension}) => '不支持的图片格式: ${extension}, 可以尝试下载到设备上查看';
			case 'download.errors.imageLoadFailed': return '图片加载失败';
			case 'download.errors.pleaseTryOtherViewer': return '请尝试使用其他查看器打开';
			case 'download.downloadList': return '下载列表';
			case 'download.download': return '下载';
			case 'download.forceDeleteTask': return '强制删除任务';
			case 'download.startDownloading': return '开始下载...';
			case 'download.clearAllFailedTasks': return '清除全部失败任务';
			case 'download.clearAllFailedTasksConfirmation': return '确定要清除所有失败的下载任务吗？\n这些任务的文件也会被删除。';
			case 'download.clearAllFailedTasksSuccess': return '已清除所有失败任务';
			case 'download.clearAllFailedTasksError': return '清除失败任务时出错';
			case 'download.downloadStatus': return '下载状态';
			case 'download.imageList': return '图片列表';
			case 'download.retryDownload': return '重试下载';
			case 'download.notDownloaded': return '未下载';
			case 'download.downloaded': return '已下载';
			case 'download.waitingForDownload': return '等待下载...';
			case 'download.downloadingProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => '下载中 (${downloaded}/${total}张 ${progress}%)';
			case 'download.downloadingSingleImageProgress': return ({required Object downloaded}) => '下载中 (${downloaded}张)';
			case 'download.pausedProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => '已暂停 (${downloaded}/${total}张 ${progress}%)';
			case 'download.pausedSingleImageProgress': return ({required Object downloaded}) => '已暂停 (已下载${downloaded}张)';
			case 'download.downloadedProgressForImageProgress': return ({required Object total}) => '下载完成 (共${total}张)';
			case 'download.viewVideoDetail': return '查看视频详情';
			case 'download.viewGalleryDetail': return '查看图库详情';
			case 'download.moreOptions': return '更多操作';
			case 'download.openFile': return '打开文件';
			case 'download.pause': return '暂停';
			case 'download.resume': return '继续';
			case 'download.copyDownloadUrl': return '复制下载链接';
			case 'download.showInFolder': return '在文件夹中显示';
			case 'download.deleteTask': return '删除任务';
			case 'download.deleteTaskConfirmation': return '确定要删除这个下载任务吗？\n任务的文件也会被删除。';
			case 'download.forceDeleteTaskConfirmation': return '确定要强制删除这个下载任务吗？\n任务的文件也会被删除，即使文件被占用也会尝试删除。';
			case 'download.downloadingProgressForVideoTask': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloadingOnlyDownloadedAndSpeed': return ({required Object downloaded, required Object speed}) => '下载中 ${downloaded} • ${speed}MB/s';
			case 'download.pausedForDownloadedAndTotal': return ({required Object downloaded, required Object total, required Object progress}) => '已暂停 • ${downloaded}/${total} (${progress}%)';
			case 'download.pausedAndDownloaded': return ({required Object downloaded}) => '已暂停 • 已下载 ${downloaded}';
			case 'download.downloadedWithSize': return ({required Object size}) => '下载完成 • ${size}';
			case 'download.copyDownloadUrlSuccess': return '已复制下载链接';
			case 'download.totalImageNums': return ({required Object num}) => '${num}张';
			case 'download.downloadingDownloadedTotalProgressSpeed': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloading': return '下载中';
			case 'download.failed': return '失败';
			case 'download.completed': return '已完成';
			case 'download.downloadDetail': return '下载详情';
			case 'download.copy': return '复制';
			case 'download.copySuccess': return '已复制';
			case 'download.waiting': return '等待中';
			case 'download.paused': return '暂停中';
			case 'download.downloadingOnlyDownloaded': return ({required Object downloaded}) => '下载中 ${downloaded}';
			case 'download.galleryDownloadCompletedWithName': return ({required Object galleryName}) => '图库下载完成: ${galleryName}';
			case 'download.downloadCompletedWithName': return ({required Object fileName}) => '下载完成: ${fileName}';
			case 'download.stillInDevelopment': return '开发中';
			case 'download.saveToAppDirectory': return '保存到应用目录';
			case 'favorite.errors.addFailed': return '追加失败';
			case 'favorite.errors.addSuccess': return '追加成功';
			case 'favorite.errors.deleteFolderFailed': return '删除文件夹失败';
			case 'favorite.errors.deleteFolderSuccess': return '删除文件夹成功';
			case 'favorite.errors.folderNameCannotBeEmpty': return '文件夹名称不能为空';
			case 'favorite.add': return '追加';
			case 'favorite.addSuccess': return '追加成功';
			case 'favorite.addFailed': return '追加失败';
			case 'favorite.remove': return '删除';
			case 'favorite.removeSuccess': return '删除成功';
			case 'favorite.removeFailed': return '删除失败';
			case 'favorite.removeConfirmation': return '确定要删除这个项目吗？';
			case 'favorite.removeConfirmationSuccess': return '项目已从收藏夹中删除';
			case 'favorite.removeConfirmationFailed': return '删除项目失败';
			case 'favorite.createFolderSuccess': return '文件夹创建成功';
			case 'favorite.createFolderFailed': return '创建文件夹失败';
			case 'favorite.createFolder': return '创建文件夹';
			case 'favorite.enterFolderName': return '输入文件夹名称';
			case 'favorite.enterFolderNameHere': return '在此输入文件夹名称...';
			case 'favorite.create': return '创建';
			case 'favorite.items': return '项目';
			case 'favorite.newFolderName': return '新文件夹';
			case 'favorite.searchFolders': return '搜索文件夹...';
			case 'favorite.searchItems': return '搜索项目...';
			case 'favorite.createdAt': return '创建时间';
			case 'favorite.myFavorites': return '我的收藏';
			case 'favorite.deleteFolderTitle': return '删除文件夹';
			case 'favorite.deleteFolderConfirmWithTitle': return ({required Object title}) => '确定要删除 ${title} 文件夹吗？';
			case 'favorite.removeItemTitle': return '删除项目';
			case 'favorite.removeItemConfirmWithTitle': return ({required Object title}) => '确定要删除 ${title} 项目吗？';
			case 'favorite.removeItemSuccess': return '项目已从收藏夹中删除';
			case 'favorite.removeItemFailed': return '删除项目失败';
			case 'favorite.localizeFavorite': return '本地收藏';
			case 'favorite.editFolderTitle': return '编辑文件夹';
			case 'favorite.editFolderSuccess': return '文件夹更新成功';
			case 'favorite.editFolderFailed': return '文件夹更新失败';
			case 'favorite.searchTags': return '搜索标签';
			case 'translation.testConnection': return '测试连接';
			case 'translation.testConnectionSuccess': return '测试连接成功';
			case 'translation.testConnectionFailed': return '测试连接失败';
			case 'translation.testConnectionFailedWithMessage': return ({required Object message}) => '测试连接失败: ${message}';
			case 'translation.translation': return '翻译';
			case 'translation.needVerification': return '需要验证';
			case 'translation.needVerificationContent': return '请先通过连接测试才能启用AI翻译';
			case 'translation.confirm': return '确定';
			case 'translation.disclaimer': return '使用须知';
			case 'translation.riskWarning': return '风险提示';
			case 'translation.dureToRisk1': return '由于评论等文本为用户生成，可能包含违反AI服务商内容政策的内容';
			case 'translation.dureToRisk2': return '不当内容可能导致API密钥封禁或服务终止';
			case 'translation.operationSuggestion': return '操作建议';
			case 'translation.operationSuggestion1': return '1. 使用前请严格审核待翻译内容';
			case 'translation.operationSuggestion2': return '2. 避免翻译涉及暴力、成人等敏感内容';
			case 'translation.apiConfig': return 'API配置';
			case 'translation.modifyConfigWillAutoCloseAITranslation': return '修改配置将自动关闭AI翻译，需重新测试后打开';
			case 'translation.apiAddress': return 'API地址';
			case 'translation.modelName': return '模型名称';
			case 'translation.modelNameHintText': return '例如：gpt-4-turbo';
			case 'translation.maxTokens': return '最大Token数';
			case 'translation.maxTokensHintText': return '例如：1024';
			case 'translation.temperature': return '温度系数';
			case 'translation.temperatureHintText': return '0.0-2.0';
			case 'translation.clickTestButtonToVerifyAPIConnection': return '点击测试按钮验证API连接有效性';
			case 'translation.requestPreview': return '请求预览';
			case 'translation.enableAITranslation': return 'AI翻译';
			case 'translation.enabled': return '已启用';
			case 'translation.disabled': return '已禁用';
			case 'translation.testing': return '测试中...';
			case 'translation.testNow': return '立即测试';
			case 'translation.connectionStatus': return '连接状态';
			case 'translation.success': return '成功';
			case 'translation.failed': return '失败';
			case 'translation.information': return '信息';
			case 'translation.viewRawResponse': return '查看原始响应';
			case 'translation.pleaseCheckInputParametersFormat': return '请检查输入参数格式';
			case 'translation.pleaseFillInAPIAddressModelNameAndKey': return '请填写API地址、模型名称和密钥';
			case 'translation.pleaseFillInValidConfigurationParameters': return '请填写有效的配置参数';
			case 'translation.pleaseCompleteConnectionTest': return '请完成连接测试';
			case 'translation.notConfigured': return '未配置';
			case 'translation.apiEndpoint': return 'API端点';
			case 'translation.configuredKey': return '已配置密钥';
			case 'translation.notConfiguredKey': return '未配置密钥';
			case 'translation.authenticationStatus': return '认证状态';
			case 'translation.thisFieldCannotBeEmpty': return '此字段不能为空';
			case 'translation.apiKey': return 'API密钥';
			case 'translation.apiKeyCannotBeEmpty': return 'API密钥不能为空';
			case 'translation.pleaseEnterValidNumber': return '请输入有效数字';
			case 'translation.range': return '范围';
			case 'translation.mustBeGreaterThan': return '必须大于';
			case 'translation.invalidAPIResponse': return '无效的API响应';
			case 'translation.connectionFailedForMessage': return ({required Object message}) => '连接失败: ${message}';
			case 'translation.aiTranslationNotEnabledHint': return 'AI翻译未启用，请在设置中启用';
			case 'translation.goToSettings': return '前往设置';
			case 'translation.disableAITranslation': return '禁用AI翻译';
			case 'translation.currentValue': return '当前值';
			case 'translation.configureTranslationStrategy': return '配置翻译策略';
			case 'translation.advancedSettings': return '高级设置';
			case 'translation.translationPrompt': return '翻译提示词';
			case 'translation.promptHint': return '请输入翻译提示词,使用[TL]作为目标语言的占位符';
			case 'translation.promptHelperText': return '提示词必须包含[TL]作为目标语言的占位符';
			case 'translation.promptMustContainTargetLang': return '提示词必须包含[TL]占位符';
			case 'translation.aiTranslationWillBeDisabled': return 'AI翻译将被自动关闭';
			case 'translation.aiTranslationWillBeDisabledDueToConfigChange': return '由于修改了基础配置,AI翻译将被自动关闭';
			case 'translation.aiTranslationWillBeDisabledDueToPromptChange': return '由于修改了翻译提示词,AI翻译将被自动关闭';
			case 'translation.aiTranslationWillBeDisabledDueToParamChange': return '由于修改了参数配置,AI翻译将被自动关闭';
			case 'translation.onlyOpenAIAPISupported': return '当前仅支持OpenAI兼容的API格式（application/json请求体格式）';
			case 'translation.streamingTranslation': return '流式翻译';
			case 'translation.streamingTranslationSupported': return '支持流式翻译';
			case 'translation.streamingTranslationNotSupported': return '不支持流式翻译';
			case 'translation.streamingTranslationDescription': return '流式翻译可以在翻译过程中实时显示结果，提供更好的用户体验';
			case 'translation.usingFullUrlWithHash': return '使用完整URL（以#结尾）';
			case 'translation.baseUrlInputHelperText': return '当以#结尾时，将以输入的URL作为实际请求地址';
			case 'translation.currentActualUrl': return ({required Object url}) => '当前实际URL: ${url}';
			case 'translation.urlEndingWithHashTip': return 'URL以#结尾时，将以输入的URL作为实际请求地址';
			case 'translation.streamingTranslationWarning': return '注意：此功能需要API服务支持流式传输，部分模型可能不支持';
			case 'linkInputDialog.title': return '输入链接';
			case 'linkInputDialog.supportedLinksHint': return ({required Object webName}) => '支持智能识别多个${webName}链接，并快速跳转到应用内对应页面(链接与其他文本之间用空格隔开)';
			case 'linkInputDialog.inputHint': return ({required Object webName}) => '请输入${webName}链接';
			case 'linkInputDialog.validatorEmptyLink': return '请输入链接';
			case 'linkInputDialog.validatorNoIwaraLink': return ({required Object webName}) => '未检测到有效的${webName}链接';
			case 'linkInputDialog.multipleLinksDetected': return '检测到多个链接，请选择一个：';
			case 'linkInputDialog.notIwaraLink': return ({required Object webName}) => '不是有效的${webName}链接';
			case 'linkInputDialog.linkParseError': return ({required Object error}) => '链接解析出错: ${error}';
			case 'linkInputDialog.unsupportedLinkDialogTitle': return '不支持的链接';
			case 'linkInputDialog.unsupportedLinkDialogContent': return '该链接类型当前应用无法直接打开，需要使用外部浏览器访问。\n\n是否使用浏览器打开此链接？';
			case 'linkInputDialog.openInBrowser': return '用浏览器打开';
			case 'linkInputDialog.confirmOpenBrowserDialogTitle': return '确认打开浏览器';
			case 'linkInputDialog.confirmOpenBrowserDialogContent': return '即将使用外部浏览器打开以下链接：';
			case 'linkInputDialog.confirmContinueBrowserOpen': return '确定要继续吗？';
			case 'linkInputDialog.browserOpenFailed': return '无法打开链接';
			case 'linkInputDialog.unsupportedLink': return '不支持的链接';
			case 'linkInputDialog.cancel': return '取消';
			case 'linkInputDialog.confirm': return '用浏览器打开';
			case 'log.logManagement': return '日志管理';
			case 'log.enableLogPersistence': return '启用日志持久化';
			case 'log.enableLogPersistenceDesc': return '将日志保存到数据库以便于分析问题';
			case 'log.logDatabaseSizeLimit': return '日志数据库大小上限';
			case 'log.logDatabaseSizeLimitDesc': return ({required Object size}) => '当前: ${size}';
			case 'log.exportCurrentLogs': return '导出当前日志';
			case 'log.exportCurrentLogsDesc': return '导出当天应用日志以帮助开发者诊断问题';
			case 'log.exportHistoryLogs': return '导出历史日志';
			case 'log.exportHistoryLogsDesc': return '导出指定日期范围的日志';
			case 'log.exportMergedLogs': return '导出合并日志';
			case 'log.exportMergedLogsDesc': return '导出指定日期范围的合并日志';
			case 'log.showLogStats': return '显示日志统计信息';
			case 'log.logExportSuccess': return '日志导出成功';
			case 'log.logExportFailed': return ({required Object error}) => '日志导出失败: ${error}';
			case 'log.showLogStatsDesc': return '查看各种类型日志的统计数据';
			case 'log.logExtractFailed': return ({required Object error}) => '获取日志统计失败: ${error}';
			case 'log.clearAllLogs': return '清理所有日志';
			case 'log.clearAllLogsDesc': return '清理所有日志数据';
			case 'log.confirmClearAllLogs': return '确认清理';
			case 'log.confirmClearAllLogsDesc': return '确定要清理所有日志数据吗？此操作不可撤销。';
			case 'log.clearAllLogsSuccess': return '日志清理成功';
			case 'log.clearAllLogsFailed': return ({required Object error}) => '清理日志失败: ${error}';
			case 'log.unableToGetLogSizeInfo': return '无法获取日志大小信息';
			case 'log.currentLogSize': return '当前日志大小:';
			case 'log.logCount': return '日志数量:';
			case 'log.logCountUnit': return '条';
			case 'log.logSizeLimit': return '大小上限:';
			case 'log.usageRate': return '使用率:';
			case 'log.exceedLimit': return '超出限制';
			case 'log.remaining': return '剩余';
			case 'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit': return '当前日志大小已超出限制，建议立即清理旧日志或增加空间限制';
			case 'log.currentLogSizeAlmostExceededPleaseCleanOldLogs': return '当前日志大小即将用尽，建议清理旧日志';
			case 'log.cleaningOldLogs': return '正在自动清理旧日志...';
			case 'log.logCleaningCompleted': return '日志清理完成';
			case 'log.logCleaningProcessMayNotBeCompleted': return '日志清理过程可能未完成';
			case 'log.cleanExceededLogs': return '清理超出限制的日志';
			case 'log.noLogsToExport': return '没有可导出的日志数据';
			case 'log.exportingLogs': return '正在导出日志...';
			case 'log.noHistoryLogsToExport': return '尚无可导出的历史日志，请先使用应用一段时间再尝试';
			case 'log.selectLogDate': return '选择日志日期';
			case 'log.today': return '今天';
			case 'log.selectMergeRange': return '选择合并范围';
			case 'log.selectMergeRangeHint': return '请选择要合并的日志时间范围';
			case 'log.selectMergeRangeDays': return ({required Object days}) => '最近 ${days} 天';
			case 'log.logStats': return '日志统计信息';
			case 'log.todayLogs': return ({required Object count}) => '今日日志: ${count} 条';
			case 'log.recent7DaysLogs': return ({required Object count}) => '最近7天: ${count} 条';
			case 'log.totalLogs': return ({required Object count}) => '总计日志: ${count} 条';
			case 'log.setLogDatabaseSizeLimit': return '设置日志数据库大小上限';
			case 'log.currentLogSizeWithSize': return ({required Object size}) => '当前日志大小: ${size}';
			case 'log.warning': return '警告';
			case 'log.newSizeLimit': return ({required Object size}) => '新的大小限制: ${size}';
			case 'log.confirmToContinue': return '确定要继续吗？';
			case 'log.logSizeLimitSetSuccess': return ({required Object size}) => '日志大小上限已设置为 ${size}';
			default: return null;
		}
	}
}

