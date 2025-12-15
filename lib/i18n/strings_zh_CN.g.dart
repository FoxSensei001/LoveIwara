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
class TranslationsZhCn with BaseTranslations<AppLocale, Translations> implements Translations {
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
	@override late final _TranslationsTutorialZhCn tutorial = _TranslationsTutorialZhCn._(_root);
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
	@override late final _TranslationsMediaPlayerZhCn mediaPlayer = _TranslationsMediaPlayerZhCn._(_root);
	@override late final _TranslationsLinkInputDialogZhCn linkInputDialog = _TranslationsLinkInputDialogZhCn._(_root);
	@override late final _TranslationsLogZhCn log = _TranslationsLogZhCn._(_root);
	@override late final _TranslationsEmojiZhCn emoji = _TranslationsEmojiZhCn._(_root);
	@override late final _TranslationsDisplaySettingsZhCn displaySettings = _TranslationsDisplaySettingsZhCn._(_root);
	@override late final _TranslationsLayoutSettingsZhCn layoutSettings = _TranslationsLayoutSettingsZhCn._(_root);
	@override late final _TranslationsNavigationOrderSettingsZhCn navigationOrderSettings = _TranslationsNavigationOrderSettingsZhCn._(_root);
	@override late final _TranslationsSearchFilterZhCn searchFilter = _TranslationsSearchFilterZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupZhCn firstTimeSetup = _TranslationsFirstTimeSetupZhCn._(_root);
	@override late final _TranslationsProxyHelperZhCn proxyHelper = _TranslationsProxyHelperZhCn._(_root);
	@override late final _TranslationsTagSelectorZhCn tagSelector = _TranslationsTagSelectorZhCn._(_root);
	@override late final _TranslationsAnime4kZhCn anime4k = _TranslationsAnime4kZhCn._(_root);
}

// Path: tutorial
class _TranslationsTutorialZhCn implements TranslationsTutorialEn {
	_TranslationsTutorialZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => '特别关注功能';
	@override String get specialFollowDescription => '这里显示你特别关注的作者。在视频、图库、作者详情页点击关注按钮，然后选择"添加为特别关注"即可。';
	@override String get exampleAuthorInfoRow => '示例：作者信息行';
	@override String get authorName => '作者名称';
	@override String get followed => '已关注';
	@override String get specialFollowInstruction => '点击"已关注"按钮 → 选择"添加为特别关注"';
	@override String get followButtonLocations => '关注按钮位置：';
	@override String get videoDetailPage => '视频详情页';
	@override String get galleryDetailPage => '图库详情页';
	@override String get authorDetailPage => '作者详情页';
	@override String get afterSpecialFollow => '特别关注后，可在此快速查看作者最新内容！';
	@override String get specialFollowManagementTip => '特别关注列表可在侧边抽屉栏-关注列表-特别关注列表页面里管理';
	@override String get skip => '跳过';
}

// Path: common
class _TranslationsCommonZhCn implements TranslationsCommonEn {
	_TranslationsCommonZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get sort => '排序';
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
	@override String get markdownSyntaxHelp => 'Markdown语法帮助';
	@override String get previewContent => '预览内容';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => '超过最大长度限制 (${max})';
	@override String get agreeToCommunityRules => '同意社区规则';
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
	@override String get createTimeDesc => '创建时间倒序';
	@override String get createTimeAsc => '创建时间正序';
	@override late final _TranslationsCommonPaginationZhCn pagination = _TranslationsCommonPaginationZhCn._(_root);
	@override String get notice => '通知';
	@override String get detail => '详情';
	@override String get parseExceptionDestopHint => ' - 桌面端用户可以在设置中配置代理';
	@override String get iwaraTags => 'Iwara 标签';
	@override String get likeThisVideo => '喜欢这个视频的人';
	@override String get operation => '操作';
	@override String get replies => '回复';
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
	@override String get fullscreenOrientation => '竖屏进入全屏后的屏幕方向';
	@override String get fullscreenOrientationDesc => '此设置决定竖屏进入全屏时屏幕的默认方向（仅移动端有效）';
	@override String get fullscreenOrientationLeftLandscape => '左侧横屏';
	@override String get fullscreenOrientationRightLandscape => '右侧横屏';
	@override String get jumpLink => '跳转链接';
	@override String get language => '语言';
	@override String get languageChanged => '语言设置已更改，请重启应用以生效。';
	@override String get gestureControl => '手势控制';
	@override String get leftDoubleTapRewind => '左侧双击后退';
	@override String get rightDoubleTapFastForward => '右侧双击快进';
	@override String get doubleTapPause => '双击暂停';
	@override String get rightVerticalSwipeVolume => '右侧上下滑动调整音量（进入新页面时生效）';
	@override String get leftVerticalSwipeBrightness => '左侧上下滑动调整亮度（进入新页面时生效）';
	@override String get longPressFastForward => '长按快进';
	@override String get enableMouseHoverShowToolbar => '鼠标悬浮时显示工具栏';
	@override String get enableMouseHoverShowToolbarInfo => '开启后，当鼠标悬浮在播放器上移动时会自动显示工具栏，停止移动3秒后自动隐藏';
	@override String get enableHorizontalDragSeek => '横向滑动调整进度';
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
	@override late final _TranslationsSettingsForumSettingsZhCn forumSettings = _TranslationsSettingsForumSettingsZhCn._(_root);
	@override late final _TranslationsSettingsChatSettingsZhCn chatSettings = _TranslationsSettingsChatSettingsZhCn._(_root);
	@override String get hardwareDecodingAuto => '自动';
	@override String get hardwareDecodingAutoCopy => '自动复制';
	@override String get hardwareDecodingAutoSafe => '自动安全';
	@override String get hardwareDecodingNo => '禁用';
	@override String get hardwareDecodingYes => '强制启用';
	@override String get cdnDistributionStrategy => '内容分发策略';
	@override String get cdnDistributionStrategyDesc => '选择视频源服务器的分发策略，可优化加载速度';
	@override String get cdnDistributionStrategyLabel => '分发策略';
	@override String get cdnDistributionStrategyNoChange => '不修改（使用原服务器）';
	@override String get cdnDistributionStrategyAuto => '自动选择（最快服务器）';
	@override String get cdnDistributionStrategySpecial => '指定服务器';
	@override String get cdnSpecialServer => '指定服务器';
	@override String get cdnRefreshServerListHint => '请先点击下方按钮刷新服务器列表';
	@override String get cdnRefreshButton => '刷新';
	@override String get cdnFastRingServers => '快速环服务器';
	@override String get cdnRefreshServerListTooltip => '刷新服务器列表';
	@override String get cdnSpeedTestButton => '测速';
	@override String cdnSpeedTestingButton({required Object count}) => '测速中 (${count})';
	@override String get cdnNoServerDataHint => '暂无服务器数据，请点击刷新按钮';
	@override String get cdnTestingStatus => '测速中';
	@override String get cdnUnreachableStatus => '不可达';
	@override String get cdnNotTestedStatus => '未测速';
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
	@override String get showAllSubscribedUsersContent => '显示所有已订阅用户的内容';
}

// Path: videoDetail
class _TranslationsVideoDetailZhCn implements TranslationsVideoDetailEn {
	_TranslationsVideoDetailZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get pipMode => '画中画模式';
	@override String resumeFromLastPosition({required Object position}) => '从上次播放位置继续播放: ${position}';
	@override late final _TranslationsVideoDetailLocalInfoZhCn localInfo = _TranslationsVideoDetailLocalInfoZhCn._(_root);
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
	@override late final _TranslationsVideoDetailPlayerZhCn player = _TranslationsVideoDetailPlayerZhCn._(_root);
	@override late final _TranslationsVideoDetailSkeletonZhCn skeleton = _TranslationsVideoDetailSkeletonZhCn._(_root);
	@override late final _TranslationsVideoDetailCastZhCn cast = _TranslationsVideoDetailCastZhCn._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsZhCn likeAvatars = _TranslationsVideoDetailLikeAvatarsZhCn._(_root);
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
	@override String get reply => '回复';
	@override String get pendingReview => '审核中';
	@override String get editedAt => '编辑时间';
	@override String get copySuccess => '已复制到剪贴板';
	@override String copySuccessForMessage({required Object str}) => '已复制到剪贴板: ${str}';
	@override String get editReply => '编辑回复';
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
	@override String get kApprovedForumPost => '论坛发言审核通过';
	@override String get kRejectedContent => '内容审核被拒绝';
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
	@override String get viewDownloadList => '查看下载列表';
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
	@override String get playLocally => '本地播放';
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
	@override String get alreadyDownloadedWithQuality => '已有相同清晰度的任务，是否继续下载？';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => '已有清晰度为${qualities}的任务，是否继续下载？';
	@override String get otherQualities => '其他清晰度';
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
	@override String get currentService => '当前服务';
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
	@override String get maxTokensHintText => '例如：32000';
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
	@override String get translationService => '翻译服务';
	@override String get translationServiceDescription => '选择您偏好的翻译服务';
	@override String get googleTranslation => 'Google 翻译';
	@override String get googleTranslationDescription => '免费的在线翻译服务，支持多种语言';
	@override String get aiTranslation => 'AI 翻译';
	@override String get aiTranslationDescription => '基于大语言模型的智能翻译服务';
	@override String get deeplxTranslation => 'DeepLX 翻译';
	@override String get deeplxTranslationDescription => 'DeepL 翻译的开源实现，提供高质量翻译';
	@override String get googleTranslationFeatures => '特性';
	@override String get freeToUse => '免费使用';
	@override String get freeToUseDescription => '无需配置，开箱即用';
	@override String get fastResponse => '快速响应';
	@override String get fastResponseDescription => '翻译速度快，延迟低';
	@override String get stableAndReliable => '稳定可靠';
	@override String get stableAndReliableDescription => '基于Google官方API';
	@override String get enabledDefaultService => '已启用 - 默认翻译服务';
	@override String get notEnabled => '未启用';
	@override String get deeplxTranslationService => 'DeepLX 翻译服务';
	@override String get deeplxDescription => 'DeepLX 是 DeepL 翻译的开源实现，支持 Free、Pro 和 Official 三种端点模式';
	@override String get serverAddress => '服务器地址';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'DeepLX 服务器的基础地址';
	@override String get endpointType => '端点类型';
	@override String get freeEndpoint => 'Free - 免费端点，可能有频率限制';
	@override String get proEndpoint => 'Pro - 需要 dl_session，更稳定';
	@override String get officialEndpoint => 'Official - 官方 API 格式';
	@override String get finalRequestUrl => '最终请求URL';
	@override String get apiKeyOptional => 'API Key (可选)';
	@override String get apiKeyOptionalHint => '用于访问受保护的 DeepLX 服务';
	@override String get apiKeyOptionalHelperText => '某些 DeepLX 服务需要 API Key 进行身份验证';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Pro 模式需要的 dl_session 参数';
	@override String get dlSessionHelperText => 'Pro 端点必需的会话参数，从 DeepL Pro 账户获取';
	@override String get proModeRequiresDlSession => 'Pro 模式需要填写 dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => '点击测试按钮验证 DeepLX API 连接';
	@override String get enableDeepLXTranslation => '启用 DeepLX 翻译';
	@override String get deepLXTranslationWillBeDisabled => 'DeepLX翻译将因配置更改而被禁用';
	@override String get translatedResult => '翻译结果';
	@override String get testSuccess => '测试成功';
	@override String get pleaseFillInDeepLXServerAddress => '请填写DeepLX服务器地址';
	@override String get invalidAPIResponseFormat => '无效的API响应格式';
	@override String get translationServiceReturnedError => '翻译服务返回错误或空结果';
	@override String get connectionFailed => '连接失败';
	@override String get translationFailed => '翻译失败';
	@override String get aiTranslationFailed => 'AI翻译失败';
	@override String get deeplxTranslationFailed => 'DeepLX翻译失败';
	@override String get aiTranslationTestFailed => 'AI翻译测试失败';
	@override String get deeplxTranslationTestFailed => 'DeepLX翻译测试失败';
	@override String get streamingTranslationTimeout => '流式翻译超时，强制关闭资源';
	@override String get translationRequestTimeout => '翻译请求超时';
	@override String get streamingTranslationDataTimeout => '流式翻译接收数据超时';
	@override String get dataReceptionTimeout => '接收数据超时';
	@override String get streamDataParseError => '解析流数据时出错';
	@override String get streamingTranslationFailed => '流式翻译失败';
	@override String get fallbackTranslationFailed => '降级到普通翻译也失败';
	@override String get translationSettings => '翻译设置';
	@override String get enableGoogleTranslation => '启用 Google 翻译';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerZhCn implements TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => '视频播放器错误';
	@override String get videoLoadFailed => '视频加载失败';
	@override String get videoCodecNotSupported => '视频编解码器不支持';
	@override String get networkConnectionIssue => '网络连接问题';
	@override String get insufficientPermission => '权限不足';
	@override String get unsupportedVideoFormat => '不支持的视频格式';
	@override String get retry => '重试';
	@override String get externalPlayer => '外部播放器';
	@override String get detailedErrorInfo => '详细错误信息';
	@override String get format => '格式';
	@override String get suggestion => '建议';
	@override String get androidWebmCompatibilityIssue => 'Android设备对WEBM格式支持有限，建议使用外部播放器或下载支持WEBM的播放器应用';
	@override String get currentDeviceCodecNotSupported => '当前设备不支持此视频格式的编解码器';
	@override String get checkNetworkConnection => '请检查网络连接后重试';
	@override String get appMayLackMediaPermission => '应用可能缺少必要的媒体播放权限';
	@override String get tryOtherVideoPlayer => '请尝试使用其他视频播放器';
	@override String get video => '视频';
	@override String get local => '本地';
	@override String get unknown => '未知';
	@override String get localVideoPathEmpty => '本地视频路径为空';
	@override String localVideoFileNotExists({required Object path}) => '本地视频文件不存在: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => '无法播放本地视频: ${error}';
	@override String get dropVideoFileHere => '拖放视频文件到此处播放';
	@override String get supportedFormats => '支持格式: MP4, MKV, AVI, MOV, WEBM 等';
	@override String get noSupportedVideoFile => '未找到支持的视频文件';
	@override String get imageLoadFailed => '图片加载失败';
	@override String get unsupportedImageFormat => '不支持的图片格式';
	@override String get tryOtherViewer => '请尝试使用其他查看器';
	@override String get retryingOpenVideoLink => '视频链接打开失败，重试中';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => '无法加载解码器: ${event}，可以通过在播放器设置里切换至软解，并重新进入页面尝试';
	@override String videoLoadErrorWithDetail({required Object event}) => '视频加载错误: ${event}';
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

// Path: emoji
class _TranslationsEmojiZhCn implements TranslationsEmojiEn {
	_TranslationsEmojiZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get name => '表情';
	@override String get size => '大小';
	@override String get small => '小';
	@override String get medium => '中';
	@override String get large => '大';
	@override String get extraLarge => '超大';
	@override String get copyEmojiLinkSuccess => '表情包链接已复制';
	@override String get preview => '表情包预览';
	@override String get library => '表情包库';
	@override String get noEmojis => '暂无表情包';
	@override String get clickToAddEmojis => '点击右上角按钮添加表情包';
	@override String get addEmojis => '添加表情包';
	@override String get imagePreview => '图片预览';
	@override String get imageLoadFailed => '图片加载失败';
	@override String get loading => '加载中...';
	@override String get delete => '删除';
	@override String get close => '关闭';
	@override String get deleteImage => '删除图片';
	@override String get confirmDeleteImage => '确定要删除这张图片吗？';
	@override String get cancel => '取消';
	@override String get batchDelete => '批量删除';
	@override String confirmBatchDelete({required Object count}) => '确定要删除选中的${count}张图片吗？此操作不可撤销。';
	@override String get deleteSuccess => '成功删除';
	@override String get addImage => '添加图片';
	@override String get addImageByUrl => '通过URL添加';
	@override String get addImageUrl => '添加图片URL';
	@override String get imageUrl => '图片URL';
	@override String get enterImageUrl => '请输入图片URL';
	@override String get add => '添加';
	@override String get batchImport => '批量导入';
	@override String get enterJsonUrlArray => '请输入JSON格式的URL数组:';
	@override String get formatExample => '格式示例:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => '请粘贴JSON格式的URL数组';
	@override String get import => '导入';
	@override String importSuccess({required Object count}) => '成功导入${count}张图片';
	@override String get jsonFormatError => 'JSON格式错误，请检查输入';
	@override String get createGroup => '创建表情包分组';
	@override String get groupName => '分组名称';
	@override String get enterGroupName => '请输入分组名称';
	@override String get create => '创建';
	@override String get editGroupName => '编辑分组名称';
	@override String get save => '保存';
	@override String get deleteGroup => '删除分组';
	@override String get confirmDeleteGroup => '确定要删除这个表情包分组吗？分组内的所有图片也会被删除。';
	@override String imageCount({required Object count}) => '${count}张图片';
	@override String get selectEmoji => '选择表情包';
	@override String get noEmojisInGroup => '该分组暂无表情包';
	@override String get goToSettingsToAddEmojis => '前往设置添加表情包';
	@override String get emojiManagement => '表情包管理';
	@override String get manageEmojiGroupsAndImages => '管理表情包分组和图片';
	@override String get uploadLocalImages => '上传本地图片';
	@override String get uploadingImages => '正在上传图片';
	@override String uploadingImagesProgress({required Object count}) => '正在上传 ${count} 张图片，请稍候...';
	@override String get doNotCloseDialog => '请不要关闭此对话框';
	@override String uploadSuccess({required Object count}) => '成功上传 ${count} 张图片';
	@override String uploadFailed({required Object count}) => '失败 ${count} 张';
	@override String get uploadFailedMessage => '图片上传失败，请检查网络连接或文件格式';
	@override String uploadErrorMessage({required Object error}) => '上传过程中发生错误: ${error}';
}

// Path: displaySettings
class _TranslationsDisplaySettingsZhCn implements TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '显示设置';
	@override String get layoutSettings => '布局设置';
	@override String get layoutSettingsDesc => '自定义列数和断点配置';
	@override String get gridLayout => '网格布局';
	@override String get navigationOrderSettings => '导航排序设置';
	@override String get customNavigationOrder => '自定义导航顺序';
	@override String get customNavigationOrderDesc => '调整底部导航栏和侧边栏中页面的显示顺序';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsZhCn implements TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '布局设置';
	@override String get descriptionTitle => '布局配置说明';
	@override String get descriptionContent => '这里的配置将决定视频、图库列表页面中显示的列数。您可以选择自动模式让系统根据屏幕宽度自动调整，或选择手动模式固定列数。';
	@override String get layoutMode => '布局模式';
	@override String get reset => '重置';
	@override String get autoMode => '自动模式';
	@override String get autoModeDesc => '根据屏幕宽度自动调整';
	@override String get manualMode => '手动模式';
	@override String get manualModeDesc => '使用固定列数';
	@override String get manualSettings => '手动设置';
	@override String get fixedColumns => '固定列数';
	@override String get columns => '列';
	@override String get breakpointConfig => '断点配置';
	@override String get add => '添加';
	@override String get defaultColumns => '默认列数';
	@override String get defaultColumnsDesc => '大屏幕默认显示';
	@override String get previewEffect => '预览效果';
	@override String get screenWidth => '屏幕宽度';
	@override String get addBreakpoint => '添加断点';
	@override String get editBreakpoint => '编辑断点';
	@override String get deleteBreakpoint => '删除断点';
	@override String get screenWidthLabel => '屏幕宽度';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => '列数';
	@override String get columnsHint => '3';
	@override String get enterWidth => '请输入宽度';
	@override String get enterValidWidth => '请输入有效宽度';
	@override String get widthCannotExceed9999 => '宽度不能超过9999';
	@override String get breakpointAlreadyExists => '断点已存在';
	@override String get enterColumns => '请输入列数';
	@override String get enterValidColumns => '请输入有效列数';
	@override String get columnsCannotExceed12 => '列数不能超过12';
	@override String get breakpointConflict => '断点已存在';
	@override String get confirmResetLayoutSettings => '重置布局设置';
	@override String get confirmResetLayoutSettingsDesc => '确定要重置所有布局设置到默认值吗？\n\n将恢复为：\n• 自动模式\n• 默认断点配置';
	@override String get resetToDefaults => '重置为默认值';
	@override String get confirmDeleteBreakpoint => '删除断点';
	@override String confirmDeleteBreakpointDesc({required Object width}) => '确定要删除 ${width}px 断点吗？';
	@override String get noCustomBreakpoints => '暂无自定义断点，使用默认列数';
	@override String get breakpointRange => '断点区间';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => '编辑';
	@override String get delete => '删除';
	@override String get cancel => '取消';
	@override String get save => '保存';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsZhCn implements TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '导航排序设置';
	@override String get customNavigationOrder => '自定义导航顺序';
	@override String get customNavigationOrderDesc => '拖拽调整底部导航栏和侧边栏中各个页面的显示顺序';
	@override String get restartRequired => '需重启应用生效';
	@override String get navigationItemSorting => '导航项排序';
	@override String get done => '完成';
	@override String get edit => '编辑';
	@override String get reset => '重置';
	@override String get previewEffect => '预览效果';
	@override String get bottomNavigationPreview => '底部导航栏预览：';
	@override String get sidebarPreview => '侧边栏预览：';
	@override String get confirmResetNavigationOrder => '确认重置导航顺序';
	@override String get confirmResetNavigationOrderDesc => '确定要将导航顺序重置为默认设置吗？';
	@override String get cancel => '取消';
	@override String get videoDescription => '浏览热门视频内容';
	@override String get galleryDescription => '浏览图片和画廊';
	@override String get subscriptionDescription => '查看关注用户的最新内容';
	@override String get forumDescription => '参与社区讨论';
}

// Path: searchFilter
class _TranslationsSearchFilterZhCn implements TranslationsSearchFilterEn {
	_TranslationsSearchFilterZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get selectField => '选择字段';
	@override String get add => '添加';
	@override String get clear => '清空';
	@override String get clearAll => '清空全部';
	@override String get generatedQuery => '生成的查询';
	@override String get copyToClipboard => '复制到剪贴板';
	@override String get copied => '已复制';
	@override String filterCount({required Object count}) => '${count} 个过滤器';
	@override String get filterSettings => '筛选项设置';
	@override String get field => '字段';
	@override String get operator => '操作符';
	@override String get language => '语言';
	@override String get value => '值';
	@override String get dateRange => '日期范围';
	@override String get numberRange => '数值范围';
	@override String get from => '从';
	@override String get to => '到';
	@override String get date => '日期';
	@override String get number => '数值';
	@override String get boolean => '布尔值';
	@override String get tags => '标签';
	@override String get select => '选择';
	@override String get clickToSelectDate => '点击选择日期';
	@override String get pleaseEnterValidNumber => '请输入有效的数值';
	@override String get pleaseEnterValidDate => '请输入有效的日期格式 (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => '起始值必须小于结束值';
	@override String get startDateMustBeBeforeEndDate => '起始日期必须早于结束日期';
	@override String get pleaseFillStartValue => '请填写起始值';
	@override String get pleaseFillEndValue => '请填写结束值';
	@override String get rangeValueFormatError => '范围值格式错误';
	@override String get contains => '包含';
	@override String get equals => '等于';
	@override String get notEquals => '不等于';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => '范围';
	@override String get kIn => '包含任意一项';
	@override String get notIn => '不包含任意一项';
	@override String get username => '用户名';
	@override String get nickname => '昵称';
	@override String get registrationDate => '注册日期';
	@override String get description => '描述';
	@override String get title => '标题';
	@override String get body => '内容';
	@override String get author => '作者';
	@override String get publishDate => '发布日期';
	@override String get private => '私密';
	@override String get duration => '时长(秒)';
	@override String get likes => '点赞数';
	@override String get views => '观看数';
	@override String get comments => '评论数';
	@override String get rating => '评级';
	@override String get imageCount => '图片数量';
	@override String get videoCount => '视频数量';
	@override String get createDate => '创建日期';
	@override String get content => '内容';
	@override String get all => '全部的';
	@override String get adult => '成人的';
	@override String get general => '大众的';
	@override String get yes => '是';
	@override String get no => '否';
	@override String get users => '用户';
	@override String get videos => '视频';
	@override String get images => '图片';
	@override String get posts => '帖子';
	@override String get forumThreads => '论坛主题';
	@override String get forumPosts => '论坛帖子';
	@override String get playlists => '播放列表';
	@override late final _TranslationsSearchFilterSortTypesZhCn sortTypes = _TranslationsSearchFilterSortTypesZhCn._(_root);
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupZhCn implements TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeZhCn welcome = _TranslationsFirstTimeSetupWelcomeZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupBasicZhCn basic = _TranslationsFirstTimeSetupBasicZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkZhCn network = _TranslationsFirstTimeSetupNetworkZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupThemeZhCn theme = _TranslationsFirstTimeSetupThemeZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerZhCn player = _TranslationsFirstTimeSetupPlayerZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionZhCn completion = _TranslationsFirstTimeSetupCompletionZhCn._(_root);
	@override late final _TranslationsFirstTimeSetupCommonZhCn common = _TranslationsFirstTimeSetupCommonZhCn._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperZhCn implements TranslationsProxyHelperEn {
	_TranslationsProxyHelperZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => '检测到系统代理';
	@override String get copied => '已复制';
	@override String get copy => '复制';
}

// Path: tagSelector
class _TranslationsTagSelectorZhCn implements TranslationsTagSelectorEn {
	_TranslationsTagSelectorZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get selectTags => '选择标签';
	@override String get clickToSelectTags => '点击选择标签';
	@override String get addTag => '添加标签';
	@override String get removeTag => '移除标签';
	@override String get deleteTag => '删除标签';
	@override String get usageInstructions => '需先添加标签，然后再从已有的标签中点击选中';
	@override String get usageInstructionsTooltip => '使用说明';
	@override String get addTagTooltip => '添加标签';
	@override String get removeTagTooltip => '删除标签';
	@override String get cancelSelection => '取消选择';
	@override String get selectAll => '全选';
	@override String get cancelSelectAll => '取消全选';
	@override String get delete => '删除';
}

// Path: anime4k
class _TranslationsAnime4kZhCn implements TranslationsAnime4kEn {
	_TranslationsAnime4kZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Anime4K 实时视频上采样和降噪，提升动画视频质量';
	@override String get settings => 'Anime4K 设置';
	@override String get preset => 'Anime4K 预设';
	@override String get disable => '关闭 Anime4K';
	@override String get disableDescription => '禁用视频增强效果';
	@override String get highQualityPresets => '高质量预设';
	@override String get fastPresets => '快速预设';
	@override String get litePresets => '轻量级预设';
	@override String get moreLitePresets => '更多轻量级预设';
	@override String get customPresets => '自定义预设';
	@override late final _TranslationsAnime4kPresetGroupsZhCn presetGroups = _TranslationsAnime4kPresetGroupsZhCn._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsZhCn presetDescriptions = _TranslationsAnime4kPresetDescriptionsZhCn._(_root);
	@override late final _TranslationsAnime4kPresetNamesZhCn presetNames = _TranslationsAnime4kPresetNamesZhCn._(_root);
	@override String get performanceTip => '💡 提示：根据设备性能选择合适的预设，低端设备建议选择轻量级预设。';
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
	@override String get sslConnectionFailed => 'SSL连接失败，请检查网络设置';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsZhCn implements TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get name => '论坛';
	@override String get configureYourForumSettings => '配置您的论坛设置';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsZhCn implements TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get name => '聊天';
	@override String get configureYourChatSettings => '配置您的聊天设置';
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
	@override String get actualDownloadPath => '实际下载路径';
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
	@override String get externalAppPrivateDirectory => '外部应用专用目录';
	@override String get externalAppPrivateDirectoryDesc => '外部存储的应用专用目录，用户可访问，空间较大';
	@override String get internalAppPrivateDirectory => '内部应用专用目录';
	@override String get internalAppPrivateDirectoryDesc => '应用内部存储，无需权限，空间较小';
	@override String get appDocumentsDirectory => '应用文档目录';
	@override String get appDocumentsDirectoryDesc => '应用专用文档目录，安全可靠';
	@override String get downloadsFolder => '下载文件夹';
	@override String get downloadsFolderDesc => '系统默认下载目录';
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
	@override String get hot => '热门';
	@override String get favorites => '高评价';
	@override String get latest => '最新';
	@override String get popularity => '人气';
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

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoZhCn implements TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => '视频信息';
	@override String get currentQuality => '当前清晰度';
	@override String get duration => '时长';
	@override String get resolution => '分辨率';
	@override String get fileInfo => '文件信息';
	@override String get fileName => '文件名';
	@override String get fileSize => '文件大小';
	@override String get filePath => '文件路径';
	@override String get copyPath => '复制路径';
	@override String get openFolder => '打开文件夹';
	@override String get pathCopiedToClipboard => '路径已复制到剪贴板';
	@override String get openFolderFailed => '打开文件夹失败';
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerZhCn implements TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => '在加载视频源时出现了错误';
	@override String get errorWhileSettingUpListeners => '在设置监听器时出现了错误';
	@override String get serverFaultDetectedAutoSwitched => '检测到服务器故障，已自动切换线路并重试';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonZhCn implements TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => '正在获取视频信息...';
	@override String get fetchingVideoSources => '正在获取视频源...';
	@override String get loadingVideo => '正在加载视频...';
	@override String get applyingSolution => '正在应用此分辨率...';
	@override String get addingListeners => '正在添加监听器...';
	@override String get successFecthVideoDurationInfo => '成功获取视频资源，开始加载视频...';
	@override String get successFecthVideoHeightInfo => '加载完成';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastZhCn implements TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => '投屏';
	@override String unableToStartCastingSearch({required Object error}) => '启动投屏搜索失败: ${error}';
	@override String startCastingTo({required Object deviceName}) => '开始投屏到 ${deviceName}';
	@override String castFailed({required Object error}) => '投屏失败: ${error}\n请尝试重新搜索设备或切换网络';
	@override String get castStopped => '已停止投屏';
	@override late final _TranslationsVideoDetailCastDeviceTypesZhCn deviceTypes = _TranslationsVideoDetailCastDeviceTypesZhCn._(_root);
	@override String get currentPlatformNotSupported => '当前平台不支持投屏功能';
	@override String get unableToGetVideoUrl => '无法获取视频地址，请稍后重试';
	@override String get stopCasting => '停止投屏';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetZhCn dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetZhCn._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsZhCn implements TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => '谁在偷偷喜欢';
	@override String get dialogDescription => '好奇他们是谁？翻翻这本「点赞相册」吧～';
	@override String get closeTooltip => '关闭';
	@override String get retry => '重试';
	@override String get noLikesYet => '还没有人出现在这里，来当第一个吧！';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => '第 ${page} / ${totalPages} 页 · 共 ${totalCount} 人';
	@override String get prevPage => '上一页';
	@override String get nextPage => '下一页';
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
	@override String get sslHandshakeFailed => 'SSL握手失败，请检查网络环境';
	@override String get connectionFailed => '连接失败，请检查网络';
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
	@override String get playLocallyFailed => '本地播放失败';
	@override String playLocallyFailedWithMessage({required Object message}) => '本地播放失败: ${message}';
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

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesZhCn implements TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get relevance => '相关性';
	@override String get latest => '最新';
	@override String get views => '观看次数';
	@override String get likes => '点赞数';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeZhCn implements TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '欢迎使用';
	@override String get subtitle => '让我们开始您的个性化设置之旅';
	@override String get description => '只需几步，即可为您量身定制最佳使用体验';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicZhCn implements TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '基础设置';
	@override String get subtitle => '个性化您的使用体验';
	@override String get description => '选择适合您的功能偏好';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkZhCn implements TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '网络设置';
	@override String get subtitle => '配置网络连接选项';
	@override String get description => '根据您的网络环境进行相应配置';
	@override String get tip => '需设置成功后重启应用才能生效';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeZhCn implements TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '主题设置';
	@override String get subtitle => '选择您喜欢的界面主题';
	@override String get description => '个性化您的视觉体验';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerZhCn implements TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '播放器设置';
	@override String get subtitle => '配置播放控制偏好';
	@override String get description => '你可以在此快速设置常用的播放体验';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionZhCn implements TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '完成设置';
	@override String get subtitle => '即将开始您的精彩之旅';
	@override String get description => '请阅读并同意相关协议';
	@override String get agreementTitle => '用户协议和社区规则';
	@override String get agreementDesc => '在使用本应用前，请您仔细阅读并同意我们的用户协议和社区规则。这些条款有助于维护良好的使用环境。';
	@override String get checkboxTitle => '我已阅读并同意用户协议和社区规则';
	@override String get checkboxSubtitle => '不同意将无法使用本应用';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonZhCn implements TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => '这些设置都可以在应用设置中随时修改';
	@override String get agreeAgreementSnackbar => '请先同意用户协议和社区规则';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsZhCn implements TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get highQuality => '高质量';
	@override String get fast => '快速';
	@override String get lite => '轻量级';
	@override String get moreLite => '更多轻量级';
	@override String get custom => '自定义';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsZhCn implements TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => '适用于大多数1080p动漫，特别是处理模糊、重采样和压缩瑕疵。提供最高的感知质量。';
	@override String get mode_b_hq => '适用于轻微模糊或因缩放产生的振铃效应的动漫。可以有效减少振铃和锯齿。';
	@override String get mode_c_hq => '适用于几乎没有瑕疵的高质量片源（如原生1080p的动画电影或壁纸）。降噪并提供最高的PSNR。';
	@override String get mode_a_a_hq => 'Mode A的强化版，提供极致的感知质量，能重建几乎所有退化的线条。可能产生过度锐化或振铃。';
	@override String get mode_b_b_hq => 'Mode B的强化版，提供更高的感知质量，进一步优化线条和减少瑕疵。';
	@override String get mode_c_a_hq => 'Mode C的感知质量增强版，在保持高PSNR的同时尝试重建一些线条细节。';
	@override String get mode_a_fast => 'Mode A的快速版本，平衡了质量与性能，适用于大多数1080p动漫。';
	@override String get mode_b_fast => 'Mode B的快速版本，用于处理轻微瑕疵和振铃，性能开销较低。';
	@override String get mode_c_fast => 'Mode C的快速版本，适用于高质量片源的快速降噪和放大。';
	@override String get mode_a_a_fast => 'Mode A+A的快速版本，在性能有限的设备上追求更高的感知质量。';
	@override String get mode_b_b_fast => 'Mode B+B的快速版本，为性能有限的设备提供增强的线条修复和瑕疵处理。';
	@override String get mode_c_a_fast => 'Mode C+A的快速版本，在快速处理高质量片源的同时，进行轻度的线条修复。';
	@override String get upscale_only_s => '仅使用最快的CNN模型进行x2放大，无修复和降噪，性能开销最低。';
	@override String get upscale_deblur_fast => '使用快速的非CNN算法进行放大和去模糊，效果优于传统算法，性能开销很低。';
	@override String get restore_s_only => '仅使用最快的CNN模型修复画面瑕疵，不进行放大。适用于原生分辨率播放，但希望改善画质的情况。';
	@override String get denoise_bilateral_fast => '使用传统的双边滤波器进行降噪，速度极快，适用于处理轻微噪点。';
	@override String get upscale_non_cnn => '使用快速的传统算法进行放大，性能开销极低，效果优于播放器自带算法。';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 线条加深，在快速模式A的基础上增加线条加深效果，使线条更突出，风格化处理。';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 线条细化，在高质量模式A的基础上增加线条细化效果，让画面看起来更精致。';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesZhCn implements TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

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
	@override String get restore_s_only => '修复 (超快)';
	@override String get denoise_bilateral_fast => '双边降噪 (极快)';
	@override String get upscale_non_cnn => '非CNN放大 (极快)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 线条加深';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 线条细化';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesZhCn implements TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => '媒体播放器';
	@override String get mediaServer => '媒体服务器';
	@override String get internetGatewayDevice => '路由器';
	@override String get basicDevice => '基础设备';
	@override String get dimmableLight => '智能灯';
	@override String get wlanAccessPoint => '无线接入点';
	@override String get wlanConnectionDevice => '无线连接设备';
	@override String get printer => '打印机';
	@override String get scanner => '扫描仪';
	@override String get digitalSecurityCamera => '摄像头';
	@override String get unknownDevice => '未知设备';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetZhCn implements TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetZhCn._(this._root);

	final TranslationsZhCn _root; // ignore: unused_field

	// Translations
	@override String get title => '远程投屏';
	@override String get close => '关闭';
	@override String get searchingDevices => '正在搜索设备...';
	@override String get searchPrompt => '点击搜索按钮重新搜索投屏设备';
	@override String get searching => '搜索中';
	@override String get searchAgain => '重新搜索';
	@override String get noDevicesFound => '未发现投屏设备\n请确保设备在同一网络下';
	@override String get searchingDevicesPrompt => '正在搜索设备，请稍候...';
	@override String get cast => '投屏';
	@override String connectedTo({required Object deviceName}) => '已连接到: ${deviceName}';
	@override String get notConnected => '未连接设备';
	@override String get stopCasting => '停止投屏';
}

/// The flat map containing all translations for locale <zh-CN>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZhCn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'tutorial.specialFollowFeature' => '特别关注功能',
			'tutorial.specialFollowDescription' => '这里显示你特别关注的作者。在视频、图库、作者详情页点击关注按钮，然后选择"添加为特别关注"即可。',
			'tutorial.exampleAuthorInfoRow' => '示例：作者信息行',
			'tutorial.authorName' => '作者名称',
			'tutorial.followed' => '已关注',
			'tutorial.specialFollowInstruction' => '点击"已关注"按钮 → 选择"添加为特别关注"',
			'tutorial.followButtonLocations' => '关注按钮位置：',
			'tutorial.videoDetailPage' => '视频详情页',
			'tutorial.galleryDetailPage' => '图库详情页',
			'tutorial.authorDetailPage' => '作者详情页',
			'tutorial.afterSpecialFollow' => '特别关注后，可在此快速查看作者最新内容！',
			'tutorial.specialFollowManagementTip' => '特别关注列表可在侧边抽屉栏-关注列表-特别关注列表页面里管理',
			'tutorial.skip' => '跳过',
			'common.sort' => '排序',
			'common.appName' => 'Love Iwara',
			'common.ok' => '确定',
			'common.cancel' => '取消',
			'common.save' => '保存',
			'common.delete' => '删除',
			'common.visit' => '访问',
			'common.loading' => '加载中...',
			'common.scrollToTop' => '滚动到顶部',
			'common.privacyHint' => '隐私内容，不与展示',
			'common.latest' => '最新',
			'common.likesCount' => '点赞数',
			'common.viewsCount' => '观看次数',
			'common.popular' => '受欢迎的',
			'common.trending' => '趋势',
			'common.commentList' => '评论列表',
			'common.sendComment' => '发表评论',
			'common.send' => '发表',
			'common.retry' => '重试',
			'common.premium' => '高级会员',
			'common.follower' => '粉丝',
			'common.friend' => '朋友',
			'common.video' => '视频',
			'common.following' => '关注',
			'common.expand' => '展开',
			'common.collapse' => '收起',
			'common.cancelFriendRequest' => '取消申请',
			'common.cancelSpecialFollow' => '取消特别关注',
			'common.addFriend' => '添加朋友',
			'common.removeFriend' => '解除朋友',
			'common.followed' => '已关注',
			'common.follow' => '关注',
			'common.unfollow' => '取消关注',
			'common.specialFollow' => '特别关注',
			'common.specialFollowed' => '已特别关注',
			'common.gallery' => '图库',
			'common.playlist' => '播放列表',
			'common.commentPostedSuccessfully' => '评论发表成功',
			'common.commentPostedFailed' => '评论发表失败',
			'common.success' => '成功',
			'common.commentDeletedSuccessfully' => '评论已删除',
			'common.commentUpdatedSuccessfully' => '评论已更新',
			'common.totalComments' => ({required Object count}) => '评论 ${count} 条',
			'common.writeYourCommentHere' => '在此输入评论...',
			'common.tmpNoReplies' => '暂无回复',
			'common.loadMore' => '加载更多',
			'common.noMoreDatas' => '没有更多数据了',
			'common.selectTranslationLanguage' => '选择翻译语言',
			'common.translate' => '翻译',
			'common.translateFailedPleaseTryAgainLater' => '翻译失败，请稍后重试',
			'common.translationResult' => '翻译结果',
			'common.justNow' => '刚刚',
			'common.minutesAgo' => ({required Object num}) => '${num}分钟前',
			'common.hoursAgo' => ({required Object num}) => '${num}小时前',
			'common.daysAgo' => ({required Object num}) => '${num}天前',
			'common.editedAt' => ({required Object num}) => '${num}编辑',
			'common.editComment' => '编辑评论',
			'common.commentUpdated' => '评论已更新',
			'common.replyComment' => '回复评论',
			'common.reply' => '回复',
			'common.edit' => '编辑',
			'common.unknownUser' => '未知用户',
			'common.me' => '我',
			'common.author' => '作者',
			'common.admin' => '管理员',
			'common.viewReplies' => ({required Object num}) => '查看回复 (${num})',
			'common.hideReplies' => '隐藏回复',
			'common.confirmDelete' => '确认删除',
			'common.areYouSureYouWantToDeleteThisItem' => '确定要删除这条记录吗？',
			'common.tmpNoComments' => '暂无评论',
			'common.refresh' => '刷新',
			'common.back' => '返回',
			'common.tips' => '提示',
			'common.linkIsEmpty' => '链接地址为空',
			'common.linkCopiedToClipboard' => '链接地址已复制到剪贴板',
			'common.imageCopiedToClipboard' => '图片已复制到剪贴板',
			'common.copyImageFailed' => '复制图片失败',
			'common.mobileSaveImageIsUnderDevelopment' => '移动端的保存图片功能还在开发中',
			'common.imageSavedTo' => '图片已保存到',
			'common.saveImageFailed' => '保存图片失败',
			'common.close' => '关闭',
			'common.more' => '更多',
			'common.moreFeaturesToBeDeveloped' => '更多功能待开发',
			'common.all' => '全部',
			'common.selectedRecords' => ({required Object num}) => '已选择 ${num} 条记录',
			'common.cancelSelectAll' => '取消全选',
			'common.selectAll' => '全选',
			'common.exitEditMode' => '退出编辑模式',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '确定要删除选中的 ${num} 条记录吗？',
			'common.searchHistoryRecords' => '搜索历史记录...',
			'common.settings' => '设置',
			'common.subscriptions' => '订阅',
			'common.videoCount' => ({required Object num}) => '${num} 个视频',
			'common.share' => '分享',
			'common.areYouSureYouWantToShareThisPlaylist' => '要分享这个播放列表吗?',
			'common.editTitle' => '编辑标题',
			'common.editMode' => '编辑模式',
			'common.pleaseEnterNewTitle' => '请输入新标题',
			'common.createPlayList' => '创建播放列表',
			'common.create' => '创建',
			'common.checkNetworkSettings' => '检查网络设置',
			'common.general' => '大众的',
			'common.r18' => 'R18',
			'common.sensitive' => '敏感',
			'common.year' => '年份',
			'common.month' => '月份',
			'common.tag' => '标签',
			'common.private' => '私密',
			'common.noTitle' => '无标题',
			'common.search' => '搜索',
			'common.noContent' => '没有内容哦',
			'common.recording' => '记录中',
			'common.paused' => '已暂停',
			'common.clear' => '清除',
			'common.user' => '用户',
			'common.post' => '投稿',
			'common.seconds' => '秒',
			'common.comingSoon' => '敬请期待',
			'common.confirm' => '确认',
			'common.hour' => '时',
			'common.minute' => '分',
			'common.clickToRefresh' => '点击刷新',
			'common.history' => '历史记录',
			'common.favorites' => '最爱',
			'common.friends' => '好友',
			'common.playList' => '播放列表',
			'common.checkLicense' => '查看许可',
			'common.logout' => '退出登录',
			'common.fensi' => '粉丝',
			'common.accept' => '接受',
			'common.reject' => '拒绝',
			'common.clearAllHistory' => '清空所有历史记录',
			'common.clearAllHistoryConfirm' => '确定要清空所有历史记录吗？',
			'common.followingList' => '关注列表',
			'common.followersList' => '粉丝列表',
			'common.followers' => '粉丝',
			'common.follows' => '关注',
			'common.fans' => '粉丝',
			'common.followsAndFans' => '关注与粉丝',
			'common.numViews' => '观看次数',
			'common.updatedAt' => '更新时间',
			'common.publishedAt' => '发布时间',
			'common.externalVideo' => '站外视频',
			'common.originalText' => '原文',
			'common.showOriginalText' => '显示原始文本',
			'common.showProcessedText' => '显示处理后文本',
			'common.preview' => '预览',
			'common.markdownSyntax' => 'Markdown 语法',
			'common.rules' => '规则',
			'common.agree' => '同意',
			'common.disagree' => '不同意',
			'common.agreeToRules' => '同意规则',
			'common.markdownSyntaxHelp' => 'Markdown语法帮助',
			'common.previewContent' => '预览内容',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => '超过最大长度限制 (${max})',
			'common.agreeToCommunityRules' => '同意社区规则',
			'common.createPost' => '创建投稿',
			'common.title' => '标题',
			'common.enterTitle' => '请输入标题',
			'common.content' => '内容',
			'common.enterContent' => '请输入内容',
			'common.writeYourContentHere' => '请输入内容...',
			'common.tagBlacklist' => '黑名单标签',
			'common.noData' => '没有数据',
			'common.tagLimit' => '标签上限',
			'common.enableFloatingButtons' => '启用浮动按钮',
			'common.disableFloatingButtons' => '禁用浮动按钮',
			'common.enabledFloatingButtons' => '已启用浮动按钮',
			'common.disabledFloatingButtons' => '已禁用浮动按钮',
			'common.pendingCommentCount' => '待审核评论',
			'common.joined' => ({required Object str}) => '加入于 ${str}',
			'common.download' => '下载',
			'common.selectQuality' => '选择画质',
			'common.selectDateRange' => '选择日期范围',
			'common.selectDateRangeHint' => '选择日期范围，默认选择最近30天',
			'common.clearDateRange' => '清除日期范围',
			'common.followSuccessClickAgainToSpecialFollow' => '已成功关注，再次点击以特别关注',
			'common.exitConfirmTip' => '确定要退出吗？',
			'common.error' => '错误',
			'common.taskRunning' => '任务正在进行中，请稍后再试。',
			'common.operationCancelled' => '操作已取消。',
			'common.unsavedChanges' => '您有未保存的更改',
			'common.specialFollowsManagementTip' => '拖动可重新排序 • 向左滑动可移除',
			'common.specialFollowsManagement' => '特别关注管理',
			'common.createTimeDesc' => '创建时间倒序',
			'common.createTimeAsc' => '创建时间正序',
			'common.pagination.totalItems' => ({required Object num}) => '共 ${num} 项',
			'common.pagination.jumpToPage' => '跳转到指定页面',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => '请输入页码 (1-${max})',
			'common.pagination.pageNumber' => '页码',
			'common.pagination.jump' => '跳转',
			'common.pagination.invalidPageNumber' => ({required Object max}) => '请输入有效页码 (1-${max})',
			'common.pagination.invalidInput' => '请输入有效页码',
			'common.pagination.waterfall' => '瀑布流',
			'common.pagination.pagination' => '分页',
			'common.notice' => '通知',
			'common.detail' => '详情',
			'common.parseExceptionDestopHint' => ' - 桌面端用户可以在设置中配置代理',
			'common.iwaraTags' => 'Iwara 标签',
			'common.likeThisVideo' => '喜欢这个视频的人',
			'common.operation' => '操作',
			'common.replies' => '回复',
			'auth.tagLimit' => '标签上限',
			'auth.login' => '登录',
			'auth.logout' => '退出登录',
			'auth.email' => '邮箱',
			'auth.password' => '密码',
			'auth.loginOrRegister' => '登录 / 注册',
			'auth.register' => '注册',
			'auth.pleaseEnterEmail' => '请输入邮箱',
			'auth.pleaseEnterPassword' => '请输入密码',
			'auth.passwordMustBeAtLeast6Characters' => '密码至少需要6位',
			'auth.pleaseEnterCaptcha' => '请输入验证码',
			'auth.captcha' => '验证码',
			'auth.refreshCaptcha' => '刷新验证码',
			'auth.captchaNotLoaded' => '无法加载验证码',
			'auth.loginSuccess' => '登录成功',
			'auth.emailVerificationSent' => '邮箱指令已发送',
			'auth.notLoggedIn' => '未登录',
			'auth.clickToLogin' => '点击此处登录',
			'auth.logoutConfirmation' => '你确定要退出登录吗？',
			'auth.logoutSuccess' => '退出登录成功',
			'auth.logoutFailed' => '退出登录失败',
			'auth.usernameOrEmail' => '用户名或邮箱',
			'auth.pleaseEnterUsernameOrEmail' => '请输入用户名或邮箱',
			'auth.username' => '用户名或邮箱',
			'auth.pleaseEnterUsername' => '请输入用户名或邮箱',
			'auth.rememberMe' => '记住账号和密码',
			'errors.error' => '错误',
			'errors.required' => '此项必填',
			'errors.invalidEmail' => '邮箱格式不正确',
			'errors.networkError' => '网络错误，请重试',
			'errors.errorWhileFetching' => '获取信息失败',
			'errors.commentCanNotBeEmpty' => '评论内容不能为空',
			'errors.errorWhileFetchingReplies' => '获取回复时出错，请检查网络连接',
			'errors.canNotFindCommentController' => '无法找到评论控制器',
			'errors.errorWhileLoadingGallery' => '在加载图库时出现了错误',
			'errors.howCouldThereBeNoDataItCantBePossible' => '啊？怎么会没有数据呢？出错了吧 :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => '不支持的图片格式: ${str}',
			'errors.invalidGalleryId' => '无效的图库ID',
			'errors.translationFailedPleaseTryAgainLater' => '翻译失败，请稍后重试',
			'errors.errorOccurred' => '发生错误，请稍后再试。',
			'errors.errorOccurredWhileProcessingRequest' => '处理请求时出错',
			'errors.errorWhileFetchingDatas' => '获取数据时出错，请稍后再试',
			'errors.serviceNotInitialized' => '服务未初始化',
			'errors.unknownType' => '未知类型',
			'errors.errorWhileOpeningLink' => ({required Object link}) => '无法打开链接: ${link}',
			'errors.invalidUrl' => '无效的URL',
			'errors.failedToOperate' => '操作失败',
			'errors.permissionDenied' => '权限不足',
			'errors.youDoNotHavePermissionToAccessThisResource' => '您没有权限访问此资源',
			'errors.loginFailed' => '登录失败',
			'errors.unknownError' => '未知错误',
			'errors.sessionExpired' => '会话已过期',
			'errors.failedToFetchCaptcha' => '获取验证码失败',
			'errors.emailAlreadyExists' => '邮箱已存在',
			'errors.invalidCaptcha' => '无效的验证码',
			'errors.registerFailed' => '注册失败',
			'errors.failedToFetchComments' => '获取评论失败',
			'errors.failedToFetchImageDetail' => '获取图库详情失败',
			'errors.failedToFetchImageList' => '获取图库列表失败',
			'errors.failedToFetchData' => '获取数据失败',
			'errors.invalidParameter' => '无效的参数',
			'errors.pleaseLoginFirst' => '请先登录',
			'errors.errorWhileLoadingPost' => '载入投稿内容时出错',
			'errors.errorWhileLoadingPostDetail' => '载入投稿详情时出错',
			'errors.invalidPostId' => '无效的投稿ID',
			'errors.forceUpdateNotPermittedToGoBack' => '目前处于强制更新状态，无法返回',
			'errors.pleaseLoginAgain' => '请重新登录',
			'errors.invalidLogin' => '登录失败，请检查邮箱和密码',
			'errors.tooManyRequests' => '请求过多，请稍后再试',
			'errors.exceedsMaxLength' => ({required Object max}) => '超出最大长度: ${max} 个字符',
			'errors.contentCanNotBeEmpty' => '内容不能为空',
			'errors.titleCanNotBeEmpty' => '标题不能为空',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => '请求过多，请稍后再试，剩余时间',
			'errors.remainingHours' => ({required Object num}) => '${num}小时',
			'errors.remainingMinutes' => ({required Object num}) => '${num}分钟',
			'errors.remainingSeconds' => ({required Object num}) => '${num}秒',
			'errors.tagLimitExceeded' => ({required Object limit}) => '标签上限超出，上限: ${limit}',
			'errors.failedToRefresh' => '更新失败',
			'errors.noPermission' => '权限不足',
			'errors.resourceNotFound' => '资源不存在',
			'errors.failedToSaveCredentials' => '无法安全保存登录信息',
			'errors.failedToLoadSavedCredentials' => '加载保存的登录信息失败',
			'errors.specialFollowLimitReached' => ({required Object cnt}) => '特别关注上限超出，上限: ${cnt}，请于关注列表页中调整',
			'errors.notFound' => '内容不存在或已被删除',
			'errors.network.basicPrefix' => '网络错误 - ',
			'errors.network.failedToConnectToServer' => '连接服务器失败',
			'errors.network.serverNotAvailable' => '服务器不可用',
			'errors.network.requestTimeout' => '请求超时',
			'errors.network.unexpectedError' => '意外错误',
			'errors.network.invalidResponse' => '无效响应',
			'errors.network.invalidRequest' => '无效请求',
			'errors.network.invalidUrl' => '无效URL',
			'errors.network.invalidMethod' => '无效方法',
			'errors.network.invalidHeader' => '无效头',
			'errors.network.invalidBody' => '无效体',
			'errors.network.invalidStatusCode' => '无效状态码',
			'errors.network.serverError' => '服务器错误',
			'errors.network.requestCanceled' => '请求已取消',
			'errors.network.invalidPort' => '无效端口',
			'errors.network.proxyPortError' => '代理端口设置异常',
			'errors.network.connectionRefused' => '连接被拒绝',
			'errors.network.networkUnreachable' => '网络不可达',
			'errors.network.noRouteToHost' => '无法找到主机',
			'errors.network.connectionFailed' => '连接失败',
			'errors.network.sslConnectionFailed' => 'SSL连接失败，请检查网络设置',
			'friends.clickToRestoreFriend' => '点击恢复好友',
			'friends.friendsList' => '好友列表',
			'friends.friendRequests' => '好友请求',
			'friends.friendRequestsList' => '好友请求列表',
			'friends.removingFriend' => '正在解除好友关系...',
			'friends.failedToRemoveFriend' => '解除好友关系失败',
			'friends.cancelingRequest' => '正在取消好友申请...',
			'friends.failedToCancelRequest' => '取消好友申请失败',
			'authorProfile.noMoreDatas' => '没有更多数据了',
			'authorProfile.userProfile' => '用户资料',
			'favorites.clickToRestoreFavorite' => '点击恢复最爱',
			'favorites.myFavorites' => '我的最爱',
			'galleryDetail.galleryDetail' => '图库详情',
			'galleryDetail.viewGalleryDetail' => '查看图库详情',
			'galleryDetail.copyLink' => '复制链接地址',
			'galleryDetail.copyImage' => '复制图片',
			'galleryDetail.saveAs' => '另存为',
			'galleryDetail.saveToAlbum' => '保存到相册',
			'galleryDetail.publishedAt' => '发布时间',
			'galleryDetail.viewsCount' => '观看次数',
			'galleryDetail.imageLibraryFunctionIntroduction' => '图库功能介绍',
			'galleryDetail.rightClickToSaveSingleImage' => '右键保存单张图片',
			'galleryDetail.batchSave' => '批量保存',
			'galleryDetail.keyboardLeftAndRightToSwitch' => '键盘的左右控制切换',
			'galleryDetail.keyboardUpAndDownToZoom' => '键盘的上下控制缩放',
			'galleryDetail.mouseWheelToSwitch' => '鼠标的滚轮滑动控制切换',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + 鼠标滚轮控制缩放',
			'galleryDetail.moreFeaturesToBeDiscovered' => '更多功能待发现...',
			'galleryDetail.authorOtherGalleries' => '作者的其他图库',
			'galleryDetail.relatedGalleries' => '相关图库',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => '点击左右边缘以切换图片',
			'playList.myPlayList' => '我的播放列表',
			'playList.friendlyTips' => '友情提示',
			'playList.dearUser' => '亲爱的用户',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'iwara的播放列表系统目前还不太完善',
			'playList.notSupportSetCover' => '不支持设置封面',
			'playList.notSupportDeleteList' => '不能删除列表',
			'playList.notSupportSetPrivate' => '无法设为私密',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => '没错...创建的列表会一直存在且对所有人可见',
			'playList.smallSuggestion' => '小建议',
			'playList.useLikeToCollectContent' => '如果您比较注重隐私，建议使用"点赞"功能来收藏内容',
			'playList.welcomeToDiscussOnGitHub' => '如果你有其他的建议或想法，欢迎来 GitHub 讨论!',
			'playList.iUnderstand' => '明白了',
			'playList.searchPlaylists' => '搜索播放列表...',
			'playList.newPlaylistName' => '新播放列表名称',
			'playList.createNewPlaylist' => '创建新播放列表',
			'playList.videos' => '视频',
			'search.googleSearchScope' => '搜索范围',
			'search.searchTags' => '搜索标签...',
			'search.contentRating' => '内容分级',
			'search.removeTag' => '移除标签',
			'search.pleaseEnterSearchContent' => '请输入搜索内容',
			'search.searchHistory' => '搜索历史',
			'search.searchSuggestion' => '搜索建议',
			'search.usedTimes' => '使用次数',
			'search.lastUsed' => '最后使用',
			'search.noSearchHistoryRecords' => '没有搜索历史',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => '暂未实现当前搜索类型 ${searchType}，敬请期待',
			'search.searchResult' => '搜索结果',
			'search.unsupportedSearchType' => ({required Object searchType}) => '不支持的搜索类型: ${searchType}',
			'search.googleSearch' => '谷歌搜索',
			'search.googleSearchHint' => ({required Object webName}) => '${webName} 的搜索功能不好用？尝试谷歌搜索！',
			'search.googleSearchDescription' => '借助谷歌搜索的 :site 搜索运算符，你可以通过外部引擎来对站内的内容进行检索，此功能在搜索 视频、图库、播放列表、用户 时非常有用。',
			'search.googleSearchKeywordsHint' => '输入要搜索的关键词',
			'search.openLinkJump' => '打开链接跳转',
			'search.googleSearchButton' => '谷歌搜索',
			'search.pleaseEnterSearchKeywords' => '请输入搜索关键词',
			'search.googleSearchQueryCopied' => '搜索语句已复制到剪贴板',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => '无法打开浏览器: ${error}',
			'mediaList.personalIntroduction' => '个人简介',
			'settings.listViewMode' => '列表显示模式',
			'settings.useTraditionalPaginationMode' => '使用传统分页模式',
			'settings.useTraditionalPaginationModeDesc' => '开启后列表将使用传统分页模式，关闭则使用瀑布流模式',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => '显示底部进度条',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => '此配置决定是否在工具栏隐藏时显示底部进度条',
			'settings.basicSettings' => '基础设置',
			'settings.personalizedSettings' => '个性化设置',
			'settings.otherSettings' => '其他设置',
			'settings.searchConfig' => '搜索配置',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => '此配置决定当你之后播放视频时是否会沿用之前的配置。',
			'settings.playControl' => '播放控制',
			'settings.fastForwardTime' => '快进时间',
			'settings.fastForwardTimeMustBeAPositiveInteger' => '快进时间必须是一个正整数。',
			'settings.rewindTime' => '后退时间',
			'settings.rewindTimeMustBeAPositiveInteger' => '后退时间必须是一个正整数。',
			'settings.longPressPlaybackSpeed' => '长按播放倍速',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => '长按播放倍速必须是一个正数。',
			'settings.repeat' => '循环播放',
			'settings.renderVerticalVideoInVerticalScreen' => '全屏播放时以竖屏模式渲染竖屏视频',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => '此配置决定当你在全屏播放时是否以竖屏模式渲染竖屏视频。',
			'settings.rememberVolume' => '记住音量',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => '此配置决定当你之后播放视频时是否会沿用之前的音量设置。',
			'settings.rememberBrightness' => '记住亮度',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => '此配置决定当你之后播放视频时是否会沿用之前的亮度设置。',
			'settings.playControlArea' => '播放控制区域',
			'settings.leftAndRightControlAreaWidth' => '左右控制区域宽度',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => '此配置决定播放器左右两侧的控制区域宽度。',
			'settings.proxyAddressCannotBeEmpty' => '代理地址不能为空。',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => '无效的代理地址格式。请使用 IP:端口 或 域名:端口 格式。',
			'settings.proxyNormalWork' => '代理正常工作。',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => '代理请求失败，状态码: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => '代理请求出错: ${exception}',
			'settings.proxyConfig' => '代理配置',
			'settings.thisIsHttpProxyAddress' => '此处为http代理地址',
			'settings.checkProxy' => '检查代理',
			'settings.proxyAddress' => '代理地址',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => '请输入代理服务器的URL，例如 127.0.0.1:8080',
			'settings.enableProxy' => '启用代理',
			'settings.left' => '左侧',
			'settings.middle' => '中间',
			'settings.right' => '右侧',
			'settings.playerSettings' => '播放器设置',
			'settings.networkSettings' => '网络设置',
			'settings.customizeYourPlaybackExperience' => '自定义您的播放体验',
			'settings.chooseYourFavoriteAppAppearance' => '选择您喜欢的应用外观',
			'settings.configureYourProxyServer' => '配置您的代理服务器',
			'settings.settings' => '设置',
			'settings.themeSettings' => '主题设置',
			'settings.followSystem' => '跟随系统',
			'settings.lightMode' => '浅色模式',
			'settings.darkMode' => '深色模式',
			'settings.presetTheme' => '预设主题',
			'settings.basicTheme' => '基础主题',
			'settings.needRestartToApply' => '需要重启应用以应用设置',
			'settings.themeNeedRestartDescription' => '主题设置需要重启应用以应用设置',
			'settings.about' => '关于',
			'settings.currentVersion' => '当前版本',
			'settings.latestVersion' => '最新版本',
			'settings.checkForUpdates' => '检查更新',
			'settings.update' => '更新',
			'settings.newVersionAvailable' => '发现新版本',
			'settings.projectHome' => '开源地址',
			'settings.release' => '版本发布',
			'settings.issueReport' => '问题反馈',
			'settings.openSourceLicense' => '开源许可',
			'settings.checkForUpdatesFailed' => '检查更新失败，请稍后重试',
			'settings.autoCheckUpdate' => '自动检查更新',
			'settings.updateContent' => '更新内容：',
			'settings.releaseDate' => '发布日期',
			'settings.ignoreThisVersion' => '忽略此版本',
			'settings.minVersionUpdateRequired' => '当前版本过低，请尽快更新',
			'settings.forceUpdateTip' => '此版本为强制更新，请尽快更新到最新版本',
			'settings.viewChangelog' => '查看更新日志',
			'settings.alreadyLatestVersion' => '已是最新版本',
			'settings.appSettings' => '应用设置',
			'settings.configureYourAppSettings' => '配置您的应用程序设置',
			'settings.history' => '历史记录',
			'settings.autoRecordHistory' => '自动记录历史记录',
			'settings.autoRecordHistoryDesc' => '自动记录您观看过的视频和图库等信息',
			'settings.showUnprocessedMarkdownText' => '显示未处理文本',
			'settings.showUnprocessedMarkdownTextDesc' => '显示Markdown的原始文本',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => '隐私模式',
			'settings.activeBackgroundPrivacyModeDesc' => '禁止截图、后台运行时隐藏画面...',
			'settings.privacy' => '隐私',
			'settings.forum' => '论坛',
			'settings.disableForumReplyQuote' => '禁用论坛回复引用',
			'settings.disableForumReplyQuoteDesc' => '禁用论坛回复时携带被回复楼层信息',
			'settings.theaterMode' => '剧院模式',
			'settings.theaterModeDesc' => '开启后，播放器背景会被设置为视频封面的模糊版本',
			'settings.appLinks' => '应用链接',
			'settings.defaultBrowser' => '默认浏览',
			'settings.defaultBrowserDesc' => '请在系统设置中打开默认链接配置项，并添加网站链接',
			'settings.themeMode' => '主题模式',
			'settings.themeModeDesc' => '此配置决定应用的主题模式',
			'settings.dynamicColor' => '动态颜色',
			'settings.dynamicColorDesc' => '此配置决定应用是否使用动态颜色',
			'settings.useDynamicColor' => '使用动态颜色',
			'settings.useDynamicColorDesc' => '此配置决定应用是否使用动态颜色',
			'settings.presetColors' => '预设颜色',
			'settings.customColors' => '自定义颜色',
			'settings.pickColor' => '选择颜色',
			'settings.cancel' => '取消',
			'settings.confirm' => '确认',
			'settings.noCustomColors' => '没有自定义颜色',
			'settings.recordAndRestorePlaybackProgress' => '记录和恢复播放进度',
			'settings.signature' => '小尾巴',
			'settings.enableSignature' => '小尾巴启用',
			'settings.enableSignatureDesc' => '此配置决定回复时是否自动添加小尾巴',
			'settings.enterSignature' => '输入小尾巴',
			'settings.editSignature' => '编辑小尾巴',
			'settings.signatureContent' => '小尾巴内容',
			'settings.exportConfig' => '导出应用配置',
			'settings.exportConfigDesc' => '将应用配置导出为文件（不包含下载记录）',
			'settings.importConfig' => '导入应用配置',
			'settings.importConfigDesc' => '从文件导入应用配置',
			'settings.exportConfigSuccess' => '配置导出成功！',
			'settings.exportConfigFailed' => '配置导出失败',
			'settings.importConfigSuccess' => '配置导入成功！',
			'settings.importConfigFailed' => '配置导入失败',
			'settings.historyUpdateLogs' => '历代更新日志',
			_ => null,
		} ?? switch (path) {
			'settings.noUpdateLogs' => '未获取到更新日志',
			'settings.versionLabel' => '版本: {version}',
			'settings.releaseDateLabel' => '发布日期: {date}',
			'settings.noChanges' => '暂无更新内容',
			'settings.interaction' => '交互',
			'settings.enableVibration' => '启用震动',
			'settings.enableVibrationDesc' => '启用应用交互时的震动反馈',
			'settings.defaultKeepVideoToolbarVisible' => '保持工具栏常驻',
			'settings.defaultKeepVideoToolbarVisibleDesc' => '此设置决定首次进入视频页面时是否保持工具栏常驻显示。',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => '移动端开启剧院模式可能会造成性能问题，可酌情开启。',
			'settings.lockButtonPosition' => '锁定按钮位置',
			'settings.lockButtonPositionBothSides' => '两侧显示',
			'settings.lockButtonPositionLeftSide' => '仅左侧显示',
			'settings.lockButtonPositionRightSide' => '仅右侧显示',
			'settings.fullscreenOrientation' => '竖屏进入全屏后的屏幕方向',
			'settings.fullscreenOrientationDesc' => '此设置决定竖屏进入全屏时屏幕的默认方向（仅移动端有效）',
			'settings.fullscreenOrientationLeftLandscape' => '左侧横屏',
			'settings.fullscreenOrientationRightLandscape' => '右侧横屏',
			'settings.jumpLink' => '跳转链接',
			'settings.language' => '语言',
			'settings.languageChanged' => '语言设置已更改，请重启应用以生效。',
			'settings.gestureControl' => '手势控制',
			'settings.leftDoubleTapRewind' => '左侧双击后退',
			'settings.rightDoubleTapFastForward' => '右侧双击快进',
			'settings.doubleTapPause' => '双击暂停',
			'settings.rightVerticalSwipeVolume' => '右侧上下滑动调整音量（进入新页面时生效）',
			'settings.leftVerticalSwipeBrightness' => '左侧上下滑动调整亮度（进入新页面时生效）',
			'settings.longPressFastForward' => '长按快进',
			'settings.enableMouseHoverShowToolbar' => '鼠标悬浮时显示工具栏',
			'settings.enableMouseHoverShowToolbarInfo' => '开启后，当鼠标悬浮在播放器上移动时会自动显示工具栏，停止移动3秒后自动隐藏',
			'settings.enableHorizontalDragSeek' => '横向滑动调整进度',
			'settings.audioVideoConfig' => '音视频配置',
			'settings.expandBuffer' => '扩大缓冲区',
			'settings.expandBufferInfo' => '开启后缓冲区增大，加载时间变长但播放更流畅',
			'settings.videoSyncMode' => '视频同步模式',
			'settings.videoSyncModeSubtitle' => '音视频同步策略',
			'settings.hardwareDecodingMode' => '硬解模式',
			'settings.hardwareDecodingModeSubtitle' => '硬件解码设置',
			'settings.enableHardwareAcceleration' => '启用硬件加速',
			'settings.enableHardwareAccelerationInfo' => '开启硬件加速可以提高解码性能，但某些设备可能不兼容',
			'settings.useOpenSLESAudioOutput' => '使用OpenSLES音频输出',
			'settings.useOpenSLESAudioOutputInfo' => '使用低延迟音频输出，可能提高音频性能',
			'settings.videoSyncAudio' => '音频同步',
			'settings.videoSyncDisplayResample' => '显示重采样',
			'settings.videoSyncDisplayResampleVdrop' => '显示重采样(丢帧)',
			'settings.videoSyncDisplayResampleDesync' => '显示重采样(去同步)',
			'settings.videoSyncDisplayTempo' => '显示节拍',
			'settings.videoSyncDisplayVdrop' => '显示丢视频帧',
			'settings.videoSyncDisplayAdrop' => '显示丢音频帧',
			'settings.videoSyncDisplayDesync' => '显示去同步',
			'settings.videoSyncDesync' => '去同步',
			'settings.forumSettings.name' => '论坛',
			'settings.forumSettings.configureYourForumSettings' => '配置您的论坛设置',
			'settings.chatSettings.name' => '聊天',
			'settings.chatSettings.configureYourChatSettings' => '配置您的聊天设置',
			'settings.hardwareDecodingAuto' => '自动',
			'settings.hardwareDecodingAutoCopy' => '自动复制',
			'settings.hardwareDecodingAutoSafe' => '自动安全',
			'settings.hardwareDecodingNo' => '禁用',
			'settings.hardwareDecodingYes' => '强制启用',
			'settings.cdnDistributionStrategy' => '内容分发策略',
			'settings.cdnDistributionStrategyDesc' => '选择视频源服务器的分发策略，可优化加载速度',
			'settings.cdnDistributionStrategyLabel' => '分发策略',
			'settings.cdnDistributionStrategyNoChange' => '不修改（使用原服务器）',
			'settings.cdnDistributionStrategyAuto' => '自动选择（最快服务器）',
			'settings.cdnDistributionStrategySpecial' => '指定服务器',
			'settings.cdnSpecialServer' => '指定服务器',
			'settings.cdnRefreshServerListHint' => '请先点击下方按钮刷新服务器列表',
			'settings.cdnRefreshButton' => '刷新',
			'settings.cdnFastRingServers' => '快速环服务器',
			'settings.cdnRefreshServerListTooltip' => '刷新服务器列表',
			'settings.cdnSpeedTestButton' => '测速',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => '测速中 (${count})',
			'settings.cdnNoServerDataHint' => '暂无服务器数据，请点击刷新按钮',
			'settings.cdnTestingStatus' => '测速中',
			'settings.cdnUnreachableStatus' => '不可达',
			'settings.cdnNotTestedStatus' => '未测速',
			'settings.downloadSettings.downloadSettings' => '下载设置',
			'settings.downloadSettings.storagePermissionStatus' => '存储权限状态',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => '访问公共目录需要存储权限',
			'settings.downloadSettings.checkingPermissionStatus' => '检查权限状态...',
			'settings.downloadSettings.storagePermissionGranted' => '已授权存储权限',
			'settings.downloadSettings.storagePermissionNotGranted' => '需要存储权限',
			'settings.downloadSettings.storagePermissionGrantSuccess' => '存储权限授权成功',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => '存储权限授权失败，部分功能可能受限',
			'settings.downloadSettings.grantStoragePermission' => '授权存储权限',
			'settings.downloadSettings.customDownloadPath' => '自定义下载位置',
			'settings.downloadSettings.customDownloadPathDescription' => '启用后可以为下载的文件选择自定义保存位置',
			'settings.downloadSettings.customDownloadPathTip' => '💡 提示：选择公共目录（如下载文件夹）需要授予存储权限，建议优先使用推荐路径',
			'settings.downloadSettings.androidWarning' => 'Android提示：避免选择公共目录（如下载文件夹），建议使用应用专用目录以确保访问权限。',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ 注意：您选择的是公共目录，需要存储权限才能正常下载文件',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => '选择公共目录需要存储权限',
			'settings.downloadSettings.currentDownloadPath' => '当前下载路径',
			'settings.downloadSettings.actualDownloadPath' => '实际下载路径',
			'settings.downloadSettings.defaultAppDirectory' => '应用默认目录',
			'settings.downloadSettings.permissionGranted' => '已授权',
			'settings.downloadSettings.permissionRequired' => '需要权限',
			'settings.downloadSettings.enableCustomDownloadPath' => '启用自定义下载路径',
			'settings.downloadSettings.disableCustomDownloadPath' => '关闭时使用应用默认路径',
			'settings.downloadSettings.customDownloadPathLabel' => '自定义下载路径',
			'settings.downloadSettings.selectDownloadFolder' => '选择下载文件夹',
			'settings.downloadSettings.recommendedPath' => '推荐路径',
			'settings.downloadSettings.selectFolder' => '选择文件夹',
			'settings.downloadSettings.filenameTemplate' => '文件命名模板',
			'settings.downloadSettings.filenameTemplateDescription' => '自定义下载文件的命名规则，支持变量替换',
			'settings.downloadSettings.videoFilenameTemplate' => '视频文件命名模板',
			'settings.downloadSettings.galleryFolderTemplate' => '图库文件夹命名模板',
			'settings.downloadSettings.imageFilenameTemplate' => '单张图片命名模板',
			'settings.downloadSettings.resetToDefault' => '重置为默认值',
			'settings.downloadSettings.supportedVariables' => '支持的变量',
			'settings.downloadSettings.supportedVariablesDescription' => '在文件命名模板中可以使用以下变量：',
			'settings.downloadSettings.copyVariable' => '复制变量',
			'settings.downloadSettings.variableCopied' => '变量已复制',
			'settings.downloadSettings.warningPublicDirectory' => '警告：选择的是公共目录，可能无法访问。建议选择应用专用目录。',
			'settings.downloadSettings.downloadPathUpdated' => '下载路径已更新',
			'settings.downloadSettings.selectPathFailed' => '选择路径失败',
			'settings.downloadSettings.recommendedPathSet' => '已设置为推荐路径',
			'settings.downloadSettings.setRecommendedPathFailed' => '设置推荐路径失败',
			'settings.downloadSettings.templateResetToDefault' => '已重置为默认模板',
			'settings.downloadSettings.functionalTest' => '功能测试',
			'settings.downloadSettings.testInProgress' => '测试中...',
			'settings.downloadSettings.runTest' => '运行测试',
			'settings.downloadSettings.testDownloadPathAndPermissions' => '测试下载路径和权限配置是否正常工作',
			'settings.downloadSettings.testResults' => '测试结果',
			'settings.downloadSettings.testCompleted' => '测试完成',
			'settings.downloadSettings.testPassed' => '项通过',
			'settings.downloadSettings.testFailed' => '测试失败',
			'settings.downloadSettings.testStoragePermissionCheck' => '存储权限检查',
			'settings.downloadSettings.testStoragePermissionGranted' => '已获得存储权限',
			'settings.downloadSettings.testStoragePermissionMissing' => '缺少存储权限，部分功能可能受限',
			'settings.downloadSettings.testPermissionCheckFailed' => '权限检查失败',
			'settings.downloadSettings.testDownloadPathValidation' => '下载路径验证',
			'settings.downloadSettings.testPathValidationFailed' => '路径验证失败',
			'settings.downloadSettings.testFilenameTemplateValidation' => '文件命名模板验证',
			'settings.downloadSettings.testAllTemplatesValid' => '所有模板都有效',
			'settings.downloadSettings.testSomeTemplatesInvalid' => '部分模板包含无效字符',
			'settings.downloadSettings.testTemplateValidationFailed' => '模板验证失败',
			'settings.downloadSettings.testDirectoryOperationTest' => '目录操作测试',
			'settings.downloadSettings.testDirectoryOperationNormal' => '目录创建和文件写入正常',
			'settings.downloadSettings.testDirectoryOperationFailed' => '目录操作失败',
			'settings.downloadSettings.testVideoTemplate' => '视频模板',
			'settings.downloadSettings.testGalleryTemplate' => '图库模板',
			'settings.downloadSettings.testImageTemplate' => '图片模板',
			'settings.downloadSettings.testValid' => '有效',
			'settings.downloadSettings.testInvalid' => '无效',
			'settings.downloadSettings.testSuccess' => '成功',
			'settings.downloadSettings.testCorrect' => '正确',
			'settings.downloadSettings.testError' => '错误',
			'settings.downloadSettings.testPath' => '测试路径',
			'settings.downloadSettings.testBasePath' => '基础路径',
			'settings.downloadSettings.testDirectoryCreation' => '目录创建',
			'settings.downloadSettings.testFileWriting' => '文件写入',
			'settings.downloadSettings.testFileContent' => '文件内容',
			'settings.downloadSettings.checkingPathStatus' => '检查路径状态...',
			'settings.downloadSettings.unableToGetPathStatus' => '无法获取路径状态',
			'settings.downloadSettings.actualPathDifferentFromSelected' => '注意：实际使用路径与选择路径不同',
			'settings.downloadSettings.grantPermission' => '授权权限',
			'settings.downloadSettings.fixIssue' => '修复问题',
			'settings.downloadSettings.issueFixed' => '问题已修复',
			'settings.downloadSettings.fixFailed' => '修复失败，请手动处理',
			'settings.downloadSettings.lackStoragePermission' => '缺少存储权限',
			'settings.downloadSettings.cannotAccessPublicDirectory' => '无法访问公共目录，需要"所有文件访问权限"',
			'settings.downloadSettings.cannotCreateDirectory' => '无法创建目录',
			'settings.downloadSettings.directoryNotWritable' => '目录不可写',
			'settings.downloadSettings.insufficientSpace' => '可用空间不足',
			'settings.downloadSettings.pathValid' => '路径有效',
			'settings.downloadSettings.validationFailed' => '验证失败',
			'settings.downloadSettings.usingDefaultAppDirectory' => '使用默认应用目录',
			'settings.downloadSettings.appPrivateDirectory' => '应用专用目录',
			'settings.downloadSettings.appPrivateDirectoryDesc' => '安全可靠，无需额外权限',
			'settings.downloadSettings.downloadDirectory' => '下载目录',
			'settings.downloadSettings.downloadDirectoryDesc' => '系统默认下载位置，便于管理',
			'settings.downloadSettings.moviesDirectory' => '影片目录',
			'settings.downloadSettings.moviesDirectoryDesc' => '系统影片目录，媒体应用可识别',
			'settings.downloadSettings.documentsDirectory' => '文档目录',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOS应用文档目录',
			'settings.downloadSettings.requiresStoragePermission' => '需要存储权限才能访问',
			'settings.downloadSettings.recommendedPaths' => '推荐路径',
			'settings.downloadSettings.externalAppPrivateDirectory' => '外部应用专用目录',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => '外部存储的应用专用目录，用户可访问，空间较大',
			'settings.downloadSettings.internalAppPrivateDirectory' => '内部应用专用目录',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => '应用内部存储，无需权限，空间较小',
			'settings.downloadSettings.appDocumentsDirectory' => '应用文档目录',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => '应用专用文档目录，安全可靠',
			'settings.downloadSettings.downloadsFolder' => '下载文件夹',
			'settings.downloadSettings.downloadsFolderDesc' => '系统默认下载目录',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => '选择一个推荐的下载位置',
			'settings.downloadSettings.noRecommendedPaths' => '暂无推荐路径',
			'settings.downloadSettings.recommended' => '推荐',
			'settings.downloadSettings.requiresPermission' => '需要权限',
			'settings.downloadSettings.authorizeAndSelect' => '授权并选择',
			'settings.downloadSettings.select' => '选择',
			'settings.downloadSettings.permissionAuthorizationFailed' => '权限授权失败，无法选择此路径',
			'settings.downloadSettings.pathValidationFailed' => '路径验证失败',
			'settings.downloadSettings.downloadPathSetTo' => '下载路径已设置为',
			'settings.downloadSettings.setPathFailed' => '设置路径失败',
			'settings.downloadSettings.variableTitle' => '标题',
			'settings.downloadSettings.variableAuthor' => '作者名称',
			'settings.downloadSettings.variableUsername' => '作者用户名',
			'settings.downloadSettings.variableQuality' => '视频质量',
			'settings.downloadSettings.variableFilename' => '原始文件名',
			'settings.downloadSettings.variableId' => '内容ID',
			'settings.downloadSettings.variableCount' => '图库图片数量',
			'settings.downloadSettings.variableDate' => '当前日期 (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => '当前时间 (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => '当前日期时间 (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => '下载设置',
			'settings.downloadSettings.downloadSettingsSubtitle' => '配置下载路径和文件命名规则',
			'settings.downloadSettings.suchAsTitleQuality' => '例如: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => '例如: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => '例如: %title_%filename',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => '标签',
			'oreno3d.characters' => '角色',
			'oreno3d.origin' => '原作',
			'oreno3d.thirdPartyTagsExplanation' => '此处显示的**标签**、**角色**和**原作**信息来自第三方站点 **Oreno3D**，仅供参考。\n\n由于此信息来源只有日文，目前缺乏国际化适配。\n\n如果你有兴趣参与国际化建设，欢迎访问相关仓库贡献你的力量！',
			'oreno3d.sortTypes.hot' => '热门',
			'oreno3d.sortTypes.favorites' => '高评价',
			'oreno3d.sortTypes.latest' => '最新',
			'oreno3d.sortTypes.popularity' => '人气',
			'oreno3d.errors.requestFailed' => '请求失败，状态码',
			'oreno3d.errors.connectionTimeout' => '连接超时，请检查网络连接',
			'oreno3d.errors.sendTimeout' => '发送请求超时',
			'oreno3d.errors.receiveTimeout' => '接收响应超时',
			'oreno3d.errors.badCertificate' => '证书验证失败',
			'oreno3d.errors.resourceNotFound' => '请求的资源不存在',
			'oreno3d.errors.accessDenied' => '访问被拒绝，可能需要验证或权限',
			'oreno3d.errors.serverError' => '服务器内部错误',
			'oreno3d.errors.serviceUnavailable' => '服务暂时不可用',
			'oreno3d.errors.requestCancelled' => '请求已取消',
			'oreno3d.errors.connectionError' => '网络连接错误，请检查网络设置',
			'oreno3d.errors.networkRequestFailed' => '网络请求失败',
			'oreno3d.errors.searchVideoError' => '搜索视频时发生未知错误',
			'oreno3d.errors.getPopularVideoError' => '获取热门视频时发生未知错误',
			'oreno3d.errors.getVideoDetailError' => '获取视频详情时发生未知错误',
			'oreno3d.errors.parseVideoDetailError' => '获取并解析视频详情时发生未知错误',
			'oreno3d.errors.downloadFileError' => '下载文件时发生未知错误',
			'oreno3d.loading.gettingVideoInfo' => '正在获取视频信息...',
			'oreno3d.loading.cancel' => '取消',
			'oreno3d.messages.videoNotFoundOrDeleted' => '视频不存在或已被删除',
			'oreno3d.messages.unableToGetVideoPlayLink' => '无法获取视频播放链接',
			'oreno3d.messages.getVideoDetailFailed' => '获取视频详情失败',
			'signIn.pleaseLoginFirst' => '请先登录',
			'signIn.alreadySignedInToday' => '您今天已经签到过了！',
			'signIn.youDidNotStickToTheSignIn' => '您未能坚持签到。',
			'signIn.signInSuccess' => '签到成功！',
			'signIn.signInFailed' => '签到失败，请稍后再试',
			'signIn.consecutiveSignIns' => '连续签到天数',
			'signIn.failureReason' => '未能坚持签到的原因',
			'signIn.selectDateRange' => '选择日期范围',
			'signIn.startDate' => '开始日期',
			'signIn.endDate' => '结束日期',
			'signIn.invalidDate' => '日期格式错误',
			'signIn.invalidDateRange' => '日期范围无效',
			'signIn.errorFormatText' => '日期格式错误',
			'signIn.errorInvalidText' => '日期范围无效',
			'signIn.errorInvalidRangeText' => '日期范围无效',
			'signIn.dateRangeCantBeMoreThanOneYear' => '日期范围不能超过1年',
			'signIn.signIn' => '签到',
			'signIn.signInRecord' => '签到记录',
			'signIn.totalSignIns' => '总成功签到',
			'signIn.pleaseSelectSignInStatus' => '请选择签到状态',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => '请登录以查看您的订阅内容。',
			'subscriptions.selectUser' => '选择用户',
			'subscriptions.noSubscribedUsers' => '暂无已订阅的用户',
			'subscriptions.showAllSubscribedUsersContent' => '显示所有已订阅用户的内容',
			'videoDetail.pipMode' => '画中画模式',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => '从上次播放位置继续播放: ${position}',
			'videoDetail.localInfo.videoInfo' => '视频信息',
			'videoDetail.localInfo.currentQuality' => '当前清晰度',
			'videoDetail.localInfo.duration' => '时长',
			'videoDetail.localInfo.resolution' => '分辨率',
			'videoDetail.localInfo.fileInfo' => '文件信息',
			'videoDetail.localInfo.fileName' => '文件名',
			'videoDetail.localInfo.fileSize' => '文件大小',
			'videoDetail.localInfo.filePath' => '文件路径',
			'videoDetail.localInfo.copyPath' => '复制路径',
			'videoDetail.localInfo.openFolder' => '打开文件夹',
			'videoDetail.localInfo.pathCopiedToClipboard' => '路径已复制到剪贴板',
			'videoDetail.localInfo.openFolderFailed' => '打开文件夹失败',
			'videoDetail.videoIdIsEmpty' => '视频ID为空',
			'videoDetail.videoInfoIsEmpty' => '视频信息为空',
			'videoDetail.thisIsAPrivateVideo' => '这是一个私密视频',
			'videoDetail.getVideoInfoFailed' => '获取视频信息失败，请稍后再试',
			'videoDetail.noVideoSourceFound' => '未找到对应的视频源',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => '标签 "${tagId}" 已复制到剪贴板',
			'videoDetail.errorLoadingVideo' => '在加载视频时出现了错误',
			'videoDetail.play' => '播放',
			'videoDetail.pause' => '暂停',
			'videoDetail.exitAppFullscreen' => '退出应用全屏',
			'videoDetail.enterAppFullscreen' => '应用全屏',
			'videoDetail.exitSystemFullscreen' => '退出系统全屏',
			'videoDetail.enterSystemFullscreen' => '系统全屏',
			'videoDetail.seekTo' => '跳转到指定时间',
			'videoDetail.switchResolution' => '切换分辨率',
			'videoDetail.switchPlaybackSpeed' => '切换播放倍速',
			'videoDetail.rewindSeconds' => ({required Object num}) => '后退${num}秒',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => '快进${num}秒',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => '正在以${rate}倍速播放',
			'videoDetail.brightness' => '亮度',
			'videoDetail.brightnessLowest' => '亮度已最低',
			'videoDetail.volume' => '音量',
			'videoDetail.volumeMuted' => '音量已静音',
			'videoDetail.home' => '主页',
			'videoDetail.videoPlayer' => '视频播放器',
			'videoDetail.videoPlayerInfo' => '播放器信息',
			'videoDetail.moreSettings' => '更多设置',
			'videoDetail.videoPlayerFeatureInfo' => '播放器功能介绍',
			'videoDetail.autoRewind' => '自动重播',
			'videoDetail.rewindAndFastForward' => '左右两侧双击快进或后退',
			'videoDetail.volumeAndBrightness' => '左右两侧垂直滑动调整音量、亮度',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => '中心区域双击暂停或播放',
			'videoDetail.showVerticalVideoInFullScreen' => '在全屏时可以以竖屏方式显示竖屏视频',
			'videoDetail.keepLastVolumeAndBrightness' => '保持上次调整的音量、亮度',
			'videoDetail.setProxy' => '设置代理',
			'videoDetail.moreFeaturesToBeDiscovered' => '更多功能待发现...',
			'videoDetail.videoPlayerSettings' => '播放器设置',
			'videoDetail.commentCount' => ({required Object num}) => '评论 ${num} 条',
			'videoDetail.writeYourCommentHere' => '写下你的评论...',
			'videoDetail.authorOtherVideos' => '作者的其他视频',
			'videoDetail.relatedVideos' => '相关视频',
			'videoDetail.privateVideo' => '这是一个私密视频',
			'videoDetail.externalVideo' => '这是一个站外视频',
			'videoDetail.openInBrowser' => '在浏览器中打开',
			'videoDetail.resourceDeleted' => '这个视频貌似被删除了 :/',
			'videoDetail.noDownloadUrl' => '没有下载链接',
			'videoDetail.startDownloading' => '开始下载',
			'videoDetail.downloadFailed' => '下载失败，请稍后再试',
			'videoDetail.downloadSuccess' => '下载成功',
			'videoDetail.download' => '下载',
			'videoDetail.downloadManager' => '下载管理',
			'videoDetail.videoLoadError' => '视频加载错误',
			'videoDetail.resourceNotFound' => '资源未找到',
			'videoDetail.authorNoOtherVideos' => '作者暂无其他视频',
			'videoDetail.noRelatedVideos' => '暂无相关视频',
			'videoDetail.player.errorWhileLoadingVideoSource' => '在加载视频源时出现了错误',
			'videoDetail.player.errorWhileSettingUpListeners' => '在设置监听器时出现了错误',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => '检测到服务器故障，已自动切换线路并重试',
			'videoDetail.skeleton.fetchingVideoInfo' => '正在获取视频信息...',
			'videoDetail.skeleton.fetchingVideoSources' => '正在获取视频源...',
			'videoDetail.skeleton.loadingVideo' => '正在加载视频...',
			'videoDetail.skeleton.applyingSolution' => '正在应用此分辨率...',
			'videoDetail.skeleton.addingListeners' => '正在添加监听器...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => '成功获取视频资源，开始加载视频...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => '加载完成',
			'videoDetail.cast.dlnaCast' => '投屏',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => '启动投屏搜索失败: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => '开始投屏到 ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => '投屏失败: ${error}\n请尝试重新搜索设备或切换网络',
			'videoDetail.cast.castStopped' => '已停止投屏',
			'videoDetail.cast.deviceTypes.mediaRenderer' => '媒体播放器',
			'videoDetail.cast.deviceTypes.mediaServer' => '媒体服务器',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => '路由器',
			'videoDetail.cast.deviceTypes.basicDevice' => '基础设备',
			'videoDetail.cast.deviceTypes.dimmableLight' => '智能灯',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => '无线接入点',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => '无线连接设备',
			'videoDetail.cast.deviceTypes.printer' => '打印机',
			'videoDetail.cast.deviceTypes.scanner' => '扫描仪',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => '摄像头',
			'videoDetail.cast.deviceTypes.unknownDevice' => '未知设备',
			'videoDetail.cast.currentPlatformNotSupported' => '当前平台不支持投屏功能',
			'videoDetail.cast.unableToGetVideoUrl' => '无法获取视频地址，请稍后重试',
			'videoDetail.cast.stopCasting' => '停止投屏',
			'videoDetail.cast.dlnaCastSheet.title' => '远程投屏',
			'videoDetail.cast.dlnaCastSheet.close' => '关闭',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => '正在搜索设备...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => '点击搜索按钮重新搜索投屏设备',
			'videoDetail.cast.dlnaCastSheet.searching' => '搜索中',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => '重新搜索',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => '未发现投屏设备\n请确保设备在同一网络下',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => '正在搜索设备，请稍候...',
			'videoDetail.cast.dlnaCastSheet.cast' => '投屏',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => '已连接到: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => '未连接设备',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => '停止投屏',
			'videoDetail.likeAvatars.dialogTitle' => '谁在偷偷喜欢',
			'videoDetail.likeAvatars.dialogDescription' => '好奇他们是谁？翻翻这本「点赞相册」吧～',
			'videoDetail.likeAvatars.closeTooltip' => '关闭',
			'videoDetail.likeAvatars.retry' => '重试',
			'videoDetail.likeAvatars.noLikesYet' => '还没有人出现在这里，来当第一个吧！',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => '第 ${page} / ${totalPages} 页 · 共 ${totalCount} 人',
			'videoDetail.likeAvatars.prevPage' => '上一页',
			'videoDetail.likeAvatars.nextPage' => '下一页',
			'share.sharePlayList' => '分享播放列表',
			'share.wowDidYouSeeThis' => '哇哦，你看过这个吗？',
			'share.nameIs' => '名字叫做',
			'share.clickLinkToView' => '点击链接查看',
			'share.iReallyLikeThis' => '我真的是太喜欢这个了，你也来看看吧！',
			'share.shareFailed' => '分享失败，请稍后再试',
			'share.share' => '分享',
			'share.shareAsImage' => '分享为图片',
			'share.shareAsText' => '分享为文本',
			'share.shareAsImageDesc' => '将视频封面分享为图片',
			'share.shareAsTextDesc' => '将视频详情分享为文本',
			'share.shareAsImageFailed' => '分享视频封面为图片失败，请稍后再试',
			'share.shareAsTextFailed' => '分享视频详情为文本失败，请稍后再试',
			'share.shareVideo' => '分享视频',
			'share.authorIs' => '作者是',
			'share.shareGallery' => '分享图库',
			'share.galleryTitleIs' => '图库名字叫做',
			'share.galleryAuthorIs' => '图库作者是',
			'share.shareUser' => '分享用户',
			'share.userNameIs' => '用户名字叫做',
			'share.userAuthorIs' => '用户作者是',
			'share.comments' => '评论',
			'share.shareThread' => '分享帖子',
			'share.views' => '浏览',
			'share.sharePost' => '分享投稿',
			'share.postTitleIs' => '投稿名字叫做',
			'share.postAuthorIs' => '投稿作者是',
			'markdown.markdownSyntax' => 'Markdown 语法',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara 专用语法',
			'markdown.internalLink' => '站内链接',
			'markdown.supportAutoConvertLinkBelow' => '支持自动转换以下类型的链接：',
			'markdown.convertLinkExample' => '🎬 视频链接\n🖼️ 图片链接\n👤 用户链接\n📌 论坛链接\n🎵 播放列表链接\n💬 投稿链接',
			'markdown.mentionUser' => '提及用户',
			'markdown.mentionUserDescription' => '输入@后跟用户名，将自动转换为用户链接',
			'markdown.markdownBasicSyntax' => 'Markdown 基本语法',
			'markdown.paragraphAndLineBreak' => '段落与换行',
			'markdown.paragraphAndLineBreakDescription' => '段落之间空一行，行末加两个空格实现换行',
			'markdown.paragraphAndLineBreakSyntax' => '这是第一段文字\n\n这是第二段文字\n这一行后面加两个空格  \n就能换行了',
			'markdown.textStyle' => '文本样式',
			'markdown.textStyleDescription' => '使用特殊符号包围文本来改变样式',
			'markdown.textStyleSyntax' => '**粗体文本**\n*斜体文本*\n~~删除线文本~~\n`代码文本`',
			'markdown.quote' => '引用',
			'markdown.quoteDescription' => '使用 > 符号创建引用，多个 > 创建多级引用',
			'markdown.quoteSyntax' => '> 这是一级引用\n>> 这是二级引用',
			'markdown.list' => '列表',
			'markdown.listDescription' => '使用数字+点号创建有序列表，使用 - 创建无序列表',
			'markdown.listSyntax' => '1. 第一项\n2. 第二项\n\n- 无序项\n  - 子项\n  - 另一个子项',
			'markdown.linkAndImage' => '链接与图片',
			'markdown.linkAndImageDescription' => '链接格式：[文字](URL)\n图片格式：![描述](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[链接文字](${link})\n![图片描述](${imgUrl})',
			'markdown.title' => '标题',
			'markdown.titleDescription' => '使用 # 号创建标题，数量表示级别',
			'markdown.titleSyntax' => '# 一级标题\n## 二级标题\n### 三级标题',
			'markdown.separator' => '分隔线',
			'markdown.separatorDescription' => '使用三个或更多 - 号创建分隔线',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => '语法',
			'forum.recent' => '最近',
			'forum.category' => '分类',
			'forum.lastReply' => '最后回复',
			'forum.errors.pleaseSelectCategory' => '请选择分类',
			'forum.errors.threadLocked' => '该主题已锁定，无法回复',
			'forum.createPost' => '创建帖子',
			'forum.title' => '标题',
			'forum.enterTitle' => '输入标题',
			'forum.content' => '内容',
			'forum.enterContent' => '输入内容',
			'forum.writeYourContentHere' => '在此输入内容...',
			'forum.posts' => '帖子',
			'forum.threads' => '主题',
			'forum.forum' => '论坛',
			'forum.createThread' => '创建主题',
			'forum.selectCategory' => '选择分类',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => '冷却剩余时间 ${minutes} 分 ${seconds} 秒',
			'forum.groups.administration' => '管理',
			'forum.groups.global' => '全球',
			'forum.groups.chinese' => '中文',
			'forum.groups.japanese' => '日语',
			'forum.groups.korean' => '韩语',
			'forum.groups.other' => '其他',
			'forum.leafNames.announcements' => '公告',
			'forum.leafNames.feedback' => '反馈',
			'forum.leafNames.support' => '帮助',
			'forum.leafNames.general' => '一般',
			'forum.leafNames.guides' => '指南',
			'forum.leafNames.questions' => '问题',
			'forum.leafNames.requests' => '请求',
			'forum.leafNames.sharing' => '分享',
			'forum.leafNames.general_zh' => '一般',
			'forum.leafNames.questions_zh' => '问题',
			'forum.leafNames.requests_zh' => '请求',
			'forum.leafNames.support_zh' => '帮助',
			'forum.leafNames.general_ja' => '一般',
			'forum.leafNames.questions_ja' => '问题',
			'forum.leafNames.requests_ja' => '请求',
			'forum.leafNames.support_ja' => '帮助',
			'forum.leafNames.korean' => '韩语',
			'forum.leafNames.other' => '其他',
			'forum.leafDescriptions.announcements' => '官方重要通知和公告',
			'forum.leafDescriptions.feedback' => '对网站功能和服务的反馈',
			'forum.leafDescriptions.support' => '帮助解决网站相关问题',
			'forum.leafDescriptions.general' => '讨论任何话题',
			'forum.leafDescriptions.guides' => '分享你的经验和教程',
			'forum.leafDescriptions.questions' => '提出你的疑问',
			'forum.leafDescriptions.requests' => '发布你的请求',
			'forum.leafDescriptions.sharing' => '分享有趣的内容',
			'forum.leafDescriptions.general_zh' => '讨论任何话题',
			'forum.leafDescriptions.questions_zh' => '提出你的疑问',
			'forum.leafDescriptions.requests_zh' => '发布你的请求',
			'forum.leafDescriptions.support_zh' => '帮助解决网站相关问题',
			'forum.leafDescriptions.general_ja' => '讨论任何话题',
			'forum.leafDescriptions.questions_ja' => '提出你的疑问',
			'forum.leafDescriptions.requests_ja' => '发布你的请求',
			'forum.leafDescriptions.support_ja' => '帮助解决网站相关问题',
			'forum.leafDescriptions.korean' => '韩语相关讨论',
			'forum.leafDescriptions.other' => '其他未分类的内容',
			'forum.reply' => '回复',
			'forum.pendingReview' => '审核中',
			'forum.editedAt' => '编辑时间',
			'forum.copySuccess' => '已复制到剪贴板',
			'forum.copySuccessForMessage' => ({required Object str}) => '已复制到剪贴板: ${str}',
			'forum.editReply' => '编辑回复',
			'forum.editTitle' => '编辑标题',
			'forum.submit' => '提交',
			'notifications.errors.unsupportedNotificationType' => '暂不支持的通知类型',
			'notifications.errors.unknownUser' => '未知用户',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => '暂不支持的通知类型: ${type}',
			'notifications.errors.unknownNotificationType' => '未知通知类型',
			_ => null,
		} ?? switch (path) {
			'notifications.notifications' => '通知',
			'notifications.video' => '视频',
			'notifications.profile' => '个人主页',
			'notifications.postedNewComment' => '发表了评论',
			'notifications.inYour' => '在您的',
			'notifications.copyInfoToClipboard' => '复制通知信息到剪贴簿',
			'notifications.copySuccess' => '已复制到剪贴板',
			'notifications.copySuccessForMessage' => ({required Object str}) => '已复制到剪贴板: ${str}',
			'notifications.markAllAsRead' => '全部标记已读',
			'notifications.markAllAsReadSuccess' => '所有通知已标记为已读',
			'notifications.markAllAsReadFailed' => '全部标记已读失败',
			'notifications.markSelectedAsRead' => '标记选中项为已读',
			'notifications.markSelectedAsReadSuccess' => '选中的通知已标记为已读',
			'notifications.markSelectedAsReadFailed' => '标记选中项为已读失败',
			'notifications.markAsRead' => '标记已读',
			'notifications.markAsReadSuccess' => '已标记为已读',
			'notifications.markAsReadFailed' => '标记已读失败',
			'notifications.notificationTypeHelp' => '通知类型帮助',
			'notifications.dueToLackOfNotificationTypeDetails' => '通知类型的详细信息不足，目前支持的类型可能没有覆盖到您当前收到的消息',
			'notifications.helpUsImproveNotificationTypeSupport' => '如果您愿意帮助我们完善通知类型的支持',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 复制通知信息\n2. 🐞 前往项目仓库提交 issue\n\n⚠️ 注意：通知信息可能包含个人隐私，如果你不想公开，也可以通过邮件发送给项目作者。',
			'notifications.goToRepository' => '前往项目仓库',
			'notifications.copy' => '复制',
			'notifications.commentApproved' => '评论已通过审核',
			'notifications.repliedYourProfileComment' => '回复了您的个人主页评论',
			'notifications.repliedYourVideoComment' => '回复了您的视频评论',
			'notifications.kReplied' => '回复了您在',
			'notifications.kCommented' => '评论了您的',
			'notifications.kVideo' => '视频',
			'notifications.kGallery' => '图库',
			'notifications.kProfile' => '主页',
			'notifications.kThread' => '主题',
			'notifications.kPost' => '投稿',
			'notifications.kCommentSection' => '下的评论',
			'notifications.kApprovedComment' => '评论审核通过',
			'notifications.kApprovedVideo' => '视频审核通过',
			'notifications.kApprovedGallery' => '图库审核通过',
			'notifications.kApprovedThread' => '帖子审核通过',
			'notifications.kApprovedPost' => '投稿审核通过',
			'notifications.kApprovedForumPost' => '论坛发言审核通过',
			'notifications.kRejectedContent' => '内容审核被拒绝',
			'notifications.kUnknownType' => '未知通知类型',
			'conversation.errors.pleaseSelectAUser' => '请选择一个用户',
			'conversation.errors.pleaseEnterATitle' => '请输入标题',
			'conversation.errors.clickToSelectAUser' => '点击选择用户',
			'conversation.errors.loadFailedClickToRetry' => '加载失败,点击重试',
			'conversation.errors.loadFailed' => '加载失败',
			'conversation.errors.clickToRetry' => '点击重试',
			'conversation.errors.noMoreConversations' => '没有更多消息了',
			'conversation.conversation' => '会话',
			'conversation.startConversation' => '发起会话',
			'conversation.noConversation' => '暂无会话',
			'conversation.selectFromLeftListAndStartConversation' => '从左侧的会话列表选择一个对话开始聊天',
			'conversation.title' => '标题',
			'conversation.body' => '内容',
			'conversation.selectAUser' => '选择用户',
			'conversation.searchUsers' => '搜索用户...',
			'conversation.tmpNoConversions' => '暂无会话',
			'conversation.deleteThisMessage' => '删除此消息',
			'conversation.deleteThisMessageSubtitle' => '此操作不可撤销',
			'conversation.writeMessageHere' => '在此处输入消息',
			'conversation.sendMessage' => '发送消息',
			'splash.errors.initializationFailed' => '初始化失败，请重启应用',
			'splash.preparing' => '准备中...',
			'splash.initializing' => '初始化中...',
			'splash.loading' => '加载中...',
			'splash.ready' => '准备完成',
			'splash.initializingMessageService' => '初始化消息服务中...',
			'download.errors.imageModelNotFound' => '图库信息不存在',
			'download.errors.downloadFailed' => '下载失败',
			'download.errors.videoInfoNotFound' => '视频信息不存在',
			'download.errors.unknown' => '未知',
			'download.errors.downloadTaskAlreadyExists' => '下载任务已存在',
			'download.errors.videoAlreadyDownloaded' => '该视频已下载',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => '添加下载任务失败: ${errorInfo}',
			'download.errors.userPausedDownload' => '用户暂停下载',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => '文件系统错误: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => '未知错误: ${errorInfo}',
			'download.errors.connectionTimeout' => '连接超时',
			'download.errors.sendTimeout' => '发送超时',
			'download.errors.receiveTimeout' => '接收超时',
			'download.errors.serverError' => ({required Object errorInfo}) => '服务器错误: ${errorInfo}',
			'download.errors.unknownNetworkError' => '未知网络错误',
			'download.errors.sslHandshakeFailed' => 'SSL握手失败，请检查网络环境',
			'download.errors.connectionFailed' => '连接失败，请检查网络',
			'download.errors.serviceIsClosing' => '下载服务正在关闭',
			'download.errors.partialDownloadFailed' => '部分内容下载失败',
			'download.errors.noDownloadTask' => '暂无下载任务',
			'download.errors.taskNotFoundOrDataError' => '任务不存在或数据错误',
			'download.errors.copyDownloadUrlFailed' => '复制下载链接失败',
			'download.errors.fileNotFound' => '文件不存在',
			'download.errors.openFolderFailed' => '打开文件夹失败',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => '打开文件夹失败: ${message}',
			'download.errors.directoryNotFound' => '目录不存在',
			'download.errors.copyFailed' => '复制失败',
			'download.errors.openFileFailed' => '打开文件失败',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => '打开文件失败: ${message}',
			'download.errors.playLocallyFailed' => '本地播放失败',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => '本地播放失败: ${message}',
			'download.errors.noDownloadSource' => '没有下载源',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => '暂无下载源，请等待信息加载完成后重试',
			'download.errors.noActiveDownloadTask' => '暂无正在下载的任务',
			'download.errors.noFailedDownloadTask' => '暂无失败的任务',
			'download.errors.noCompletedDownloadTask' => '暂无已完成的任务',
			'download.errors.taskAlreadyCompletedDoNotAdd' => '任务已完成，请勿重复添加',
			'download.errors.linkExpiredTryAgain' => '链接已过期，正在重新获取下载链接',
			'download.errors.linkExpiredTryAgainSuccess' => '链接已过期，正在重新获取下载链接成功',
			'download.errors.linkExpiredTryAgainFailed' => '链接已过期,正在重新获取下载链接失败',
			'download.errors.taskDeleted' => '任务已删除',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => '不支持的图片格式: ${format}',
			'download.errors.deleteFileError' => '文件删除失败，可能是因为文件被占用',
			'download.errors.deleteTaskError' => '任务删除失败',
			'download.errors.taskNotFound' => '任务未找到',
			'download.errors.canNotRefreshVideoTask' => '无法刷新视频任务',
			'download.errors.taskAlreadyProcessing' => '任务已处理中',
			'download.errors.failedToLoadTasks' => '加载任务失败',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => '部分下载失败: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => '不支持的图片格式: ${extension}, 可以尝试下载到设备上查看',
			'download.errors.imageLoadFailed' => '图片加载失败',
			'download.errors.pleaseTryOtherViewer' => '请尝试使用其他查看器打开',
			'download.downloadList' => '下载列表',
			'download.viewDownloadList' => '查看下载列表',
			'download.download' => '下载',
			'download.forceDeleteTask' => '强制删除任务',
			'download.startDownloading' => '开始下载...',
			'download.clearAllFailedTasks' => '清除全部失败任务',
			'download.clearAllFailedTasksConfirmation' => '确定要清除所有失败的下载任务吗？\n这些任务的文件也会被删除。',
			'download.clearAllFailedTasksSuccess' => '已清除所有失败任务',
			'download.clearAllFailedTasksError' => '清除失败任务时出错',
			'download.downloadStatus' => '下载状态',
			'download.imageList' => '图片列表',
			'download.retryDownload' => '重试下载',
			'download.notDownloaded' => '未下载',
			'download.downloaded' => '已下载',
			'download.waitingForDownload' => '等待下载...',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '下载中 (${downloaded}/${total}张 ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => '下载中 (${downloaded}张)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '已暂停 (${downloaded}/${total}张 ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => '已暂停 (已下载${downloaded}张)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => '下载完成 (共${total}张)',
			'download.viewVideoDetail' => '查看视频详情',
			'download.viewGalleryDetail' => '查看图库详情',
			'download.moreOptions' => '更多操作',
			'download.openFile' => '打开文件',
			'download.playLocally' => '本地播放',
			'download.pause' => '暂停',
			'download.resume' => '继续',
			'download.copyDownloadUrl' => '复制下载链接',
			'download.showInFolder' => '在文件夹中显示',
			'download.deleteTask' => '删除任务',
			'download.deleteTaskConfirmation' => '确定要删除这个下载任务吗？\n任务的文件也会被删除。',
			'download.forceDeleteTaskConfirmation' => '确定要强制删除这个下载任务吗？\n任务的文件也会被删除，即使文件被占用也会尝试删除。',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => '下载中 ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => '已暂停 • ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => '已暂停 • 已下载 ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => '下载完成 • ${size}',
			'download.copyDownloadUrlSuccess' => '已复制下载链接',
			'download.totalImageNums' => ({required Object num}) => '${num}张',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '下载中 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => '下载中',
			'download.failed' => '失败',
			'download.completed' => '已完成',
			'download.downloadDetail' => '下载详情',
			'download.copy' => '复制',
			'download.copySuccess' => '已复制',
			'download.waiting' => '等待中',
			'download.paused' => '暂停中',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => '下载中 ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => '图库下载完成: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => '下载完成: ${fileName}',
			'download.stillInDevelopment' => '开发中',
			'download.saveToAppDirectory' => '保存到应用目录',
			'download.alreadyDownloadedWithQuality' => '已有相同清晰度的任务，是否继续下载？',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => '已有清晰度为${qualities}的任务，是否继续下载？',
			'download.otherQualities' => '其他清晰度',
			'favorite.errors.addFailed' => '追加失败',
			'favorite.errors.addSuccess' => '追加成功',
			'favorite.errors.deleteFolderFailed' => '删除文件夹失败',
			'favorite.errors.deleteFolderSuccess' => '删除文件夹成功',
			'favorite.errors.folderNameCannotBeEmpty' => '文件夹名称不能为空',
			'favorite.add' => '追加',
			'favorite.addSuccess' => '追加成功',
			'favorite.addFailed' => '追加失败',
			'favorite.remove' => '删除',
			'favorite.removeSuccess' => '删除成功',
			'favorite.removeFailed' => '删除失败',
			'favorite.removeConfirmation' => '确定要删除这个项目吗？',
			'favorite.removeConfirmationSuccess' => '项目已从收藏夹中删除',
			'favorite.removeConfirmationFailed' => '删除项目失败',
			'favorite.createFolderSuccess' => '文件夹创建成功',
			'favorite.createFolderFailed' => '创建文件夹失败',
			'favorite.createFolder' => '创建文件夹',
			'favorite.enterFolderName' => '输入文件夹名称',
			'favorite.enterFolderNameHere' => '在此输入文件夹名称...',
			'favorite.create' => '创建',
			'favorite.items' => '项目',
			'favorite.newFolderName' => '新文件夹',
			'favorite.searchFolders' => '搜索文件夹...',
			'favorite.searchItems' => '搜索项目...',
			'favorite.createdAt' => '创建时间',
			'favorite.myFavorites' => '我的收藏',
			'favorite.deleteFolderTitle' => '删除文件夹',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => '确定要删除 ${title} 文件夹吗？',
			'favorite.removeItemTitle' => '删除项目',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => '确定要删除 ${title} 项目吗？',
			'favorite.removeItemSuccess' => '项目已从收藏夹中删除',
			'favorite.removeItemFailed' => '删除项目失败',
			'favorite.localizeFavorite' => '本地收藏',
			'favorite.editFolderTitle' => '编辑文件夹',
			'favorite.editFolderSuccess' => '文件夹更新成功',
			'favorite.editFolderFailed' => '文件夹更新失败',
			'favorite.searchTags' => '搜索标签',
			'translation.currentService' => '当前服务',
			'translation.testConnection' => '测试连接',
			'translation.testConnectionSuccess' => '测试连接成功',
			'translation.testConnectionFailed' => '测试连接失败',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => '测试连接失败: ${message}',
			'translation.translation' => '翻译',
			'translation.needVerification' => '需要验证',
			'translation.needVerificationContent' => '请先通过连接测试才能启用AI翻译',
			'translation.confirm' => '确定',
			'translation.disclaimer' => '使用须知',
			'translation.riskWarning' => '风险提示',
			'translation.dureToRisk1' => '由于评论等文本为用户生成，可能包含违反AI服务商内容政策的内容',
			'translation.dureToRisk2' => '不当内容可能导致API密钥封禁或服务终止',
			'translation.operationSuggestion' => '操作建议',
			'translation.operationSuggestion1' => '1. 使用前请严格审核待翻译内容',
			'translation.operationSuggestion2' => '2. 避免翻译涉及暴力、成人等敏感内容',
			'translation.apiConfig' => 'API配置',
			'translation.modifyConfigWillAutoCloseAITranslation' => '修改配置将自动关闭AI翻译，需重新测试后打开',
			'translation.apiAddress' => 'API地址',
			'translation.modelName' => '模型名称',
			'translation.modelNameHintText' => '例如：gpt-4-turbo',
			'translation.maxTokens' => '最大Token数',
			'translation.maxTokensHintText' => '例如：32000',
			'translation.temperature' => '温度系数',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => '点击测试按钮验证API连接有效性',
			'translation.requestPreview' => '请求预览',
			'translation.enableAITranslation' => 'AI翻译',
			'translation.enabled' => '已启用',
			'translation.disabled' => '已禁用',
			'translation.testing' => '测试中...',
			'translation.testNow' => '立即测试',
			'translation.connectionStatus' => '连接状态',
			'translation.success' => '成功',
			'translation.failed' => '失败',
			'translation.information' => '信息',
			'translation.viewRawResponse' => '查看原始响应',
			'translation.pleaseCheckInputParametersFormat' => '请检查输入参数格式',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => '请填写API地址、模型名称和密钥',
			'translation.pleaseFillInValidConfigurationParameters' => '请填写有效的配置参数',
			'translation.pleaseCompleteConnectionTest' => '请完成连接测试',
			'translation.notConfigured' => '未配置',
			'translation.apiEndpoint' => 'API端点',
			'translation.configuredKey' => '已配置密钥',
			'translation.notConfiguredKey' => '未配置密钥',
			'translation.authenticationStatus' => '认证状态',
			'translation.thisFieldCannotBeEmpty' => '此字段不能为空',
			'translation.apiKey' => 'API密钥',
			'translation.apiKeyCannotBeEmpty' => 'API密钥不能为空',
			'translation.pleaseEnterValidNumber' => '请输入有效数字',
			'translation.range' => '范围',
			'translation.mustBeGreaterThan' => '必须大于',
			'translation.invalidAPIResponse' => '无效的API响应',
			'translation.connectionFailedForMessage' => ({required Object message}) => '连接失败: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI翻译未启用，请在设置中启用',
			'translation.goToSettings' => '前往设置',
			'translation.disableAITranslation' => '禁用AI翻译',
			'translation.currentValue' => '当前值',
			'translation.configureTranslationStrategy' => '配置翻译策略',
			'translation.advancedSettings' => '高级设置',
			'translation.translationPrompt' => '翻译提示词',
			'translation.promptHint' => '请输入翻译提示词,使用[TL]作为目标语言的占位符',
			'translation.promptHelperText' => '提示词必须包含[TL]作为目标语言的占位符',
			'translation.promptMustContainTargetLang' => '提示词必须包含[TL]占位符',
			'translation.aiTranslationWillBeDisabled' => 'AI翻译将被自动关闭',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => '由于修改了基础配置,AI翻译将被自动关闭',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => '由于修改了翻译提示词,AI翻译将被自动关闭',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => '由于修改了参数配置,AI翻译将被自动关闭',
			'translation.onlyOpenAIAPISupported' => '当前仅支持OpenAI兼容的API格式（application/json请求体格式）',
			'translation.streamingTranslation' => '流式翻译',
			'translation.streamingTranslationSupported' => '支持流式翻译',
			'translation.streamingTranslationNotSupported' => '不支持流式翻译',
			'translation.streamingTranslationDescription' => '流式翻译可以在翻译过程中实时显示结果，提供更好的用户体验',
			'translation.usingFullUrlWithHash' => '使用完整URL（以#结尾）',
			'translation.baseUrlInputHelperText' => '当以#结尾时，将以输入的URL作为实际请求地址',
			'translation.currentActualUrl' => ({required Object url}) => '当前实际URL: ${url}',
			'translation.urlEndingWithHashTip' => 'URL以#结尾时，将以输入的URL作为实际请求地址',
			'translation.streamingTranslationWarning' => '注意：此功能需要API服务支持流式传输，部分模型可能不支持',
			'translation.translationService' => '翻译服务',
			'translation.translationServiceDescription' => '选择您偏好的翻译服务',
			'translation.googleTranslation' => 'Google 翻译',
			'translation.googleTranslationDescription' => '免费的在线翻译服务，支持多种语言',
			'translation.aiTranslation' => 'AI 翻译',
			'translation.aiTranslationDescription' => '基于大语言模型的智能翻译服务',
			'translation.deeplxTranslation' => 'DeepLX 翻译',
			'translation.deeplxTranslationDescription' => 'DeepL 翻译的开源实现，提供高质量翻译',
			'translation.googleTranslationFeatures' => '特性',
			'translation.freeToUse' => '免费使用',
			'translation.freeToUseDescription' => '无需配置，开箱即用',
			'translation.fastResponse' => '快速响应',
			'translation.fastResponseDescription' => '翻译速度快，延迟低',
			'translation.stableAndReliable' => '稳定可靠',
			'translation.stableAndReliableDescription' => '基于Google官方API',
			'translation.enabledDefaultService' => '已启用 - 默认翻译服务',
			'translation.notEnabled' => '未启用',
			'translation.deeplxTranslationService' => 'DeepLX 翻译服务',
			'translation.deeplxDescription' => 'DeepLX 是 DeepL 翻译的开源实现，支持 Free、Pro 和 Official 三种端点模式',
			'translation.serverAddress' => '服务器地址',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'DeepLX 服务器的基础地址',
			'translation.endpointType' => '端点类型',
			'translation.freeEndpoint' => 'Free - 免费端点，可能有频率限制',
			'translation.proEndpoint' => 'Pro - 需要 dl_session，更稳定',
			'translation.officialEndpoint' => 'Official - 官方 API 格式',
			'translation.finalRequestUrl' => '最终请求URL',
			'translation.apiKeyOptional' => 'API Key (可选)',
			'translation.apiKeyOptionalHint' => '用于访问受保护的 DeepLX 服务',
			'translation.apiKeyOptionalHelperText' => '某些 DeepLX 服务需要 API Key 进行身份验证',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Pro 模式需要的 dl_session 参数',
			'translation.dlSessionHelperText' => 'Pro 端点必需的会话参数，从 DeepL Pro 账户获取',
			'translation.proModeRequiresDlSession' => 'Pro 模式需要填写 dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => '点击测试按钮验证 DeepLX API 连接',
			'translation.enableDeepLXTranslation' => '启用 DeepLX 翻译',
			'translation.deepLXTranslationWillBeDisabled' => 'DeepLX翻译将因配置更改而被禁用',
			'translation.translatedResult' => '翻译结果',
			'translation.testSuccess' => '测试成功',
			'translation.pleaseFillInDeepLXServerAddress' => '请填写DeepLX服务器地址',
			'translation.invalidAPIResponseFormat' => '无效的API响应格式',
			'translation.translationServiceReturnedError' => '翻译服务返回错误或空结果',
			'translation.connectionFailed' => '连接失败',
			'translation.translationFailed' => '翻译失败',
			'translation.aiTranslationFailed' => 'AI翻译失败',
			'translation.deeplxTranslationFailed' => 'DeepLX翻译失败',
			'translation.aiTranslationTestFailed' => 'AI翻译测试失败',
			'translation.deeplxTranslationTestFailed' => 'DeepLX翻译测试失败',
			'translation.streamingTranslationTimeout' => '流式翻译超时，强制关闭资源',
			'translation.translationRequestTimeout' => '翻译请求超时',
			'translation.streamingTranslationDataTimeout' => '流式翻译接收数据超时',
			'translation.dataReceptionTimeout' => '接收数据超时',
			'translation.streamDataParseError' => '解析流数据时出错',
			'translation.streamingTranslationFailed' => '流式翻译失败',
			'translation.fallbackTranslationFailed' => '降级到普通翻译也失败',
			'translation.translationSettings' => '翻译设置',
			'translation.enableGoogleTranslation' => '启用 Google 翻译',
			'mediaPlayer.videoPlayerError' => '视频播放器错误',
			'mediaPlayer.videoLoadFailed' => '视频加载失败',
			'mediaPlayer.videoCodecNotSupported' => '视频编解码器不支持',
			'mediaPlayer.networkConnectionIssue' => '网络连接问题',
			'mediaPlayer.insufficientPermission' => '权限不足',
			'mediaPlayer.unsupportedVideoFormat' => '不支持的视频格式',
			'mediaPlayer.retry' => '重试',
			'mediaPlayer.externalPlayer' => '外部播放器',
			'mediaPlayer.detailedErrorInfo' => '详细错误信息',
			'mediaPlayer.format' => '格式',
			'mediaPlayer.suggestion' => '建议',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Android设备对WEBM格式支持有限，建议使用外部播放器或下载支持WEBM的播放器应用',
			'mediaPlayer.currentDeviceCodecNotSupported' => '当前设备不支持此视频格式的编解码器',
			'mediaPlayer.checkNetworkConnection' => '请检查网络连接后重试',
			'mediaPlayer.appMayLackMediaPermission' => '应用可能缺少必要的媒体播放权限',
			'mediaPlayer.tryOtherVideoPlayer' => '请尝试使用其他视频播放器',
			'mediaPlayer.video' => '视频',
			'mediaPlayer.local' => '本地',
			'mediaPlayer.unknown' => '未知',
			'mediaPlayer.localVideoPathEmpty' => '本地视频路径为空',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => '本地视频文件不存在: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => '无法播放本地视频: ${error}',
			'mediaPlayer.dropVideoFileHere' => '拖放视频文件到此处播放',
			'mediaPlayer.supportedFormats' => '支持格式: MP4, MKV, AVI, MOV, WEBM 等',
			'mediaPlayer.noSupportedVideoFile' => '未找到支持的视频文件',
			'mediaPlayer.imageLoadFailed' => '图片加载失败',
			'mediaPlayer.unsupportedImageFormat' => '不支持的图片格式',
			'mediaPlayer.tryOtherViewer' => '请尝试使用其他查看器',
			'mediaPlayer.retryingOpenVideoLink' => '视频链接打开失败，重试中',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => '无法加载解码器: ${event}，可以通过在播放器设置里切换至软解，并重新进入页面尝试',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => '视频加载错误: ${event}',
			'linkInputDialog.title' => '输入链接',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => '支持智能识别多个${webName}链接，并快速跳转到应用内对应页面(链接与其他文本之间用空格隔开)',
			'linkInputDialog.inputHint' => ({required Object webName}) => '请输入${webName}链接',
			'linkInputDialog.validatorEmptyLink' => '请输入链接',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => '未检测到有效的${webName}链接',
			'linkInputDialog.multipleLinksDetected' => '检测到多个链接，请选择一个：',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => '不是有效的${webName}链接',
			'linkInputDialog.linkParseError' => ({required Object error}) => '链接解析出错: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => '不支持的链接',
			'linkInputDialog.unsupportedLinkDialogContent' => '该链接类型当前应用无法直接打开，需要使用外部浏览器访问。\n\n是否使用浏览器打开此链接？',
			'linkInputDialog.openInBrowser' => '用浏览器打开',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => '确认打开浏览器',
			'linkInputDialog.confirmOpenBrowserDialogContent' => '即将使用外部浏览器打开以下链接：',
			'linkInputDialog.confirmContinueBrowserOpen' => '确定要继续吗？',
			'linkInputDialog.browserOpenFailed' => '无法打开链接',
			'linkInputDialog.unsupportedLink' => '不支持的链接',
			'linkInputDialog.cancel' => '取消',
			'linkInputDialog.confirm' => '用浏览器打开',
			'log.logManagement' => '日志管理',
			'log.enableLogPersistence' => '启用日志持久化',
			'log.enableLogPersistenceDesc' => '将日志保存到数据库以便于分析问题',
			'log.logDatabaseSizeLimit' => '日志数据库大小上限',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => '当前: ${size}',
			'log.exportCurrentLogs' => '导出当前日志',
			'log.exportCurrentLogsDesc' => '导出当天应用日志以帮助开发者诊断问题',
			'log.exportHistoryLogs' => '导出历史日志',
			'log.exportHistoryLogsDesc' => '导出指定日期范围的日志',
			'log.exportMergedLogs' => '导出合并日志',
			'log.exportMergedLogsDesc' => '导出指定日期范围的合并日志',
			'log.showLogStats' => '显示日志统计信息',
			'log.logExportSuccess' => '日志导出成功',
			'log.logExportFailed' => ({required Object error}) => '日志导出失败: ${error}',
			'log.showLogStatsDesc' => '查看各种类型日志的统计数据',
			'log.logExtractFailed' => ({required Object error}) => '获取日志统计失败: ${error}',
			'log.clearAllLogs' => '清理所有日志',
			'log.clearAllLogsDesc' => '清理所有日志数据',
			'log.confirmClearAllLogs' => '确认清理',
			'log.confirmClearAllLogsDesc' => '确定要清理所有日志数据吗？此操作不可撤销。',
			'log.clearAllLogsSuccess' => '日志清理成功',
			'log.clearAllLogsFailed' => ({required Object error}) => '清理日志失败: ${error}',
			'log.unableToGetLogSizeInfo' => '无法获取日志大小信息',
			'log.currentLogSize' => '当前日志大小:',
			'log.logCount' => '日志数量:',
			'log.logCountUnit' => '条',
			'log.logSizeLimit' => '大小上限:',
			'log.usageRate' => '使用率:',
			'log.exceedLimit' => '超出限制',
			'log.remaining' => '剩余',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => '当前日志大小已超出限制，建议立即清理旧日志或增加空间限制',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => '当前日志大小即将用尽，建议清理旧日志',
			'log.cleaningOldLogs' => '正在自动清理旧日志...',
			'log.logCleaningCompleted' => '日志清理完成',
			'log.logCleaningProcessMayNotBeCompleted' => '日志清理过程可能未完成',
			'log.cleanExceededLogs' => '清理超出限制的日志',
			'log.noLogsToExport' => '没有可导出的日志数据',
			'log.exportingLogs' => '正在导出日志...',
			'log.noHistoryLogsToExport' => '尚无可导出的历史日志，请先使用应用一段时间再尝试',
			'log.selectLogDate' => '选择日志日期',
			'log.today' => '今天',
			'log.selectMergeRange' => '选择合并范围',
			'log.selectMergeRangeHint' => '请选择要合并的日志时间范围',
			'log.selectMergeRangeDays' => ({required Object days}) => '最近 ${days} 天',
			'log.logStats' => '日志统计信息',
			'log.todayLogs' => ({required Object count}) => '今日日志: ${count} 条',
			'log.recent7DaysLogs' => ({required Object count}) => '最近7天: ${count} 条',
			'log.totalLogs' => ({required Object count}) => '总计日志: ${count} 条',
			'log.setLogDatabaseSizeLimit' => '设置日志数据库大小上限',
			'log.currentLogSizeWithSize' => ({required Object size}) => '当前日志大小: ${size}',
			'log.warning' => '警告',
			'log.newSizeLimit' => ({required Object size}) => '新的大小限制: ${size}',
			'log.confirmToContinue' => '确定要继续吗？',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => '日志大小上限已设置为 ${size}',
			'emoji.name' => '表情',
			'emoji.size' => '大小',
			'emoji.small' => '小',
			'emoji.medium' => '中',
			'emoji.large' => '大',
			'emoji.extraLarge' => '超大',
			'emoji.copyEmojiLinkSuccess' => '表情包链接已复制',
			'emoji.preview' => '表情包预览',
			'emoji.library' => '表情包库',
			'emoji.noEmojis' => '暂无表情包',
			'emoji.clickToAddEmojis' => '点击右上角按钮添加表情包',
			'emoji.addEmojis' => '添加表情包',
			'emoji.imagePreview' => '图片预览',
			'emoji.imageLoadFailed' => '图片加载失败',
			'emoji.loading' => '加载中...',
			'emoji.delete' => '删除',
			'emoji.close' => '关闭',
			'emoji.deleteImage' => '删除图片',
			'emoji.confirmDeleteImage' => '确定要删除这张图片吗？',
			'emoji.cancel' => '取消',
			'emoji.batchDelete' => '批量删除',
			'emoji.confirmBatchDelete' => ({required Object count}) => '确定要删除选中的${count}张图片吗？此操作不可撤销。',
			'emoji.deleteSuccess' => '成功删除',
			'emoji.addImage' => '添加图片',
			'emoji.addImageByUrl' => '通过URL添加',
			'emoji.addImageUrl' => '添加图片URL',
			'emoji.imageUrl' => '图片URL',
			'emoji.enterImageUrl' => '请输入图片URL',
			'emoji.add' => '添加',
			'emoji.batchImport' => '批量导入',
			'emoji.enterJsonUrlArray' => '请输入JSON格式的URL数组:',
			'emoji.formatExample' => '格式示例:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => '请粘贴JSON格式的URL数组',
			'emoji.import' => '导入',
			'emoji.importSuccess' => ({required Object count}) => '成功导入${count}张图片',
			'emoji.jsonFormatError' => 'JSON格式错误，请检查输入',
			'emoji.createGroup' => '创建表情包分组',
			'emoji.groupName' => '分组名称',
			'emoji.enterGroupName' => '请输入分组名称',
			'emoji.create' => '创建',
			'emoji.editGroupName' => '编辑分组名称',
			'emoji.save' => '保存',
			'emoji.deleteGroup' => '删除分组',
			'emoji.confirmDeleteGroup' => '确定要删除这个表情包分组吗？分组内的所有图片也会被删除。',
			'emoji.imageCount' => ({required Object count}) => '${count}张图片',
			'emoji.selectEmoji' => '选择表情包',
			'emoji.noEmojisInGroup' => '该分组暂无表情包',
			'emoji.goToSettingsToAddEmojis' => '前往设置添加表情包',
			'emoji.emojiManagement' => '表情包管理',
			'emoji.manageEmojiGroupsAndImages' => '管理表情包分组和图片',
			'emoji.uploadLocalImages' => '上传本地图片',
			'emoji.uploadingImages' => '正在上传图片',
			'emoji.uploadingImagesProgress' => ({required Object count}) => '正在上传 ${count} 张图片，请稍候...',
			'emoji.doNotCloseDialog' => '请不要关闭此对话框',
			'emoji.uploadSuccess' => ({required Object count}) => '成功上传 ${count} 张图片',
			'emoji.uploadFailed' => ({required Object count}) => '失败 ${count} 张',
			'emoji.uploadFailedMessage' => '图片上传失败，请检查网络连接或文件格式',
			'emoji.uploadErrorMessage' => ({required Object error}) => '上传过程中发生错误: ${error}',
			'displaySettings.title' => '显示设置',
			'displaySettings.layoutSettings' => '布局设置',
			'displaySettings.layoutSettingsDesc' => '自定义列数和断点配置',
			_ => null,
		} ?? switch (path) {
			'displaySettings.gridLayout' => '网格布局',
			'displaySettings.navigationOrderSettings' => '导航排序设置',
			'displaySettings.customNavigationOrder' => '自定义导航顺序',
			'displaySettings.customNavigationOrderDesc' => '调整底部导航栏和侧边栏中页面的显示顺序',
			'layoutSettings.title' => '布局设置',
			'layoutSettings.descriptionTitle' => '布局配置说明',
			'layoutSettings.descriptionContent' => '这里的配置将决定视频、图库列表页面中显示的列数。您可以选择自动模式让系统根据屏幕宽度自动调整，或选择手动模式固定列数。',
			'layoutSettings.layoutMode' => '布局模式',
			'layoutSettings.reset' => '重置',
			'layoutSettings.autoMode' => '自动模式',
			'layoutSettings.autoModeDesc' => '根据屏幕宽度自动调整',
			'layoutSettings.manualMode' => '手动模式',
			'layoutSettings.manualModeDesc' => '使用固定列数',
			'layoutSettings.manualSettings' => '手动设置',
			'layoutSettings.fixedColumns' => '固定列数',
			'layoutSettings.columns' => '列',
			'layoutSettings.breakpointConfig' => '断点配置',
			'layoutSettings.add' => '添加',
			'layoutSettings.defaultColumns' => '默认列数',
			'layoutSettings.defaultColumnsDesc' => '大屏幕默认显示',
			'layoutSettings.previewEffect' => '预览效果',
			'layoutSettings.screenWidth' => '屏幕宽度',
			'layoutSettings.addBreakpoint' => '添加断点',
			'layoutSettings.editBreakpoint' => '编辑断点',
			'layoutSettings.deleteBreakpoint' => '删除断点',
			'layoutSettings.screenWidthLabel' => '屏幕宽度',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => '列数',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => '请输入宽度',
			'layoutSettings.enterValidWidth' => '请输入有效宽度',
			'layoutSettings.widthCannotExceed9999' => '宽度不能超过9999',
			'layoutSettings.breakpointAlreadyExists' => '断点已存在',
			'layoutSettings.enterColumns' => '请输入列数',
			'layoutSettings.enterValidColumns' => '请输入有效列数',
			'layoutSettings.columnsCannotExceed12' => '列数不能超过12',
			'layoutSettings.breakpointConflict' => '断点已存在',
			'layoutSettings.confirmResetLayoutSettings' => '重置布局设置',
			'layoutSettings.confirmResetLayoutSettingsDesc' => '确定要重置所有布局设置到默认值吗？\n\n将恢复为：\n• 自动模式\n• 默认断点配置',
			'layoutSettings.resetToDefaults' => '重置为默认值',
			'layoutSettings.confirmDeleteBreakpoint' => '删除断点',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => '确定要删除 ${width}px 断点吗？',
			'layoutSettings.noCustomBreakpoints' => '暂无自定义断点，使用默认列数',
			'layoutSettings.breakpointRange' => '断点区间',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => '编辑',
			'layoutSettings.delete' => '删除',
			'layoutSettings.cancel' => '取消',
			'layoutSettings.save' => '保存',
			'navigationOrderSettings.title' => '导航排序设置',
			'navigationOrderSettings.customNavigationOrder' => '自定义导航顺序',
			'navigationOrderSettings.customNavigationOrderDesc' => '拖拽调整底部导航栏和侧边栏中各个页面的显示顺序',
			'navigationOrderSettings.restartRequired' => '需重启应用生效',
			'navigationOrderSettings.navigationItemSorting' => '导航项排序',
			'navigationOrderSettings.done' => '完成',
			'navigationOrderSettings.edit' => '编辑',
			'navigationOrderSettings.reset' => '重置',
			'navigationOrderSettings.previewEffect' => '预览效果',
			'navigationOrderSettings.bottomNavigationPreview' => '底部导航栏预览：',
			'navigationOrderSettings.sidebarPreview' => '侧边栏预览：',
			'navigationOrderSettings.confirmResetNavigationOrder' => '确认重置导航顺序',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => '确定要将导航顺序重置为默认设置吗？',
			'navigationOrderSettings.cancel' => '取消',
			'navigationOrderSettings.videoDescription' => '浏览热门视频内容',
			'navigationOrderSettings.galleryDescription' => '浏览图片和画廊',
			'navigationOrderSettings.subscriptionDescription' => '查看关注用户的最新内容',
			'navigationOrderSettings.forumDescription' => '参与社区讨论',
			'searchFilter.selectField' => '选择字段',
			'searchFilter.add' => '添加',
			'searchFilter.clear' => '清空',
			'searchFilter.clearAll' => '清空全部',
			'searchFilter.generatedQuery' => '生成的查询',
			'searchFilter.copyToClipboard' => '复制到剪贴板',
			'searchFilter.copied' => '已复制',
			'searchFilter.filterCount' => ({required Object count}) => '${count} 个过滤器',
			'searchFilter.filterSettings' => '筛选项设置',
			'searchFilter.field' => '字段',
			'searchFilter.operator' => '操作符',
			'searchFilter.language' => '语言',
			'searchFilter.value' => '值',
			'searchFilter.dateRange' => '日期范围',
			'searchFilter.numberRange' => '数值范围',
			'searchFilter.from' => '从',
			'searchFilter.to' => '到',
			'searchFilter.date' => '日期',
			'searchFilter.number' => '数值',
			'searchFilter.boolean' => '布尔值',
			'searchFilter.tags' => '标签',
			'searchFilter.select' => '选择',
			'searchFilter.clickToSelectDate' => '点击选择日期',
			'searchFilter.pleaseEnterValidNumber' => '请输入有效的数值',
			'searchFilter.pleaseEnterValidDate' => '请输入有效的日期格式 (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => '起始值必须小于结束值',
			'searchFilter.startDateMustBeBeforeEndDate' => '起始日期必须早于结束日期',
			'searchFilter.pleaseFillStartValue' => '请填写起始值',
			'searchFilter.pleaseFillEndValue' => '请填写结束值',
			'searchFilter.rangeValueFormatError' => '范围值格式错误',
			'searchFilter.contains' => '包含',
			'searchFilter.equals' => '等于',
			'searchFilter.notEquals' => '不等于',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => '范围',
			'searchFilter.kIn' => '包含任意一项',
			'searchFilter.notIn' => '不包含任意一项',
			'searchFilter.username' => '用户名',
			'searchFilter.nickname' => '昵称',
			'searchFilter.registrationDate' => '注册日期',
			'searchFilter.description' => '描述',
			'searchFilter.title' => '标题',
			'searchFilter.body' => '内容',
			'searchFilter.author' => '作者',
			'searchFilter.publishDate' => '发布日期',
			'searchFilter.private' => '私密',
			'searchFilter.duration' => '时长(秒)',
			'searchFilter.likes' => '点赞数',
			'searchFilter.views' => '观看数',
			'searchFilter.comments' => '评论数',
			'searchFilter.rating' => '评级',
			'searchFilter.imageCount' => '图片数量',
			'searchFilter.videoCount' => '视频数量',
			'searchFilter.createDate' => '创建日期',
			'searchFilter.content' => '内容',
			'searchFilter.all' => '全部的',
			'searchFilter.adult' => '成人的',
			'searchFilter.general' => '大众的',
			'searchFilter.yes' => '是',
			'searchFilter.no' => '否',
			'searchFilter.users' => '用户',
			'searchFilter.videos' => '视频',
			'searchFilter.images' => '图片',
			'searchFilter.posts' => '帖子',
			'searchFilter.forumThreads' => '论坛主题',
			'searchFilter.forumPosts' => '论坛帖子',
			'searchFilter.playlists' => '播放列表',
			'searchFilter.sortTypes.relevance' => '相关性',
			'searchFilter.sortTypes.latest' => '最新',
			'searchFilter.sortTypes.views' => '观看次数',
			'searchFilter.sortTypes.likes' => '点赞数',
			'firstTimeSetup.welcome.title' => '欢迎使用',
			'firstTimeSetup.welcome.subtitle' => '让我们开始您的个性化设置之旅',
			'firstTimeSetup.welcome.description' => '只需几步，即可为您量身定制最佳使用体验',
			'firstTimeSetup.basic.title' => '基础设置',
			'firstTimeSetup.basic.subtitle' => '个性化您的使用体验',
			'firstTimeSetup.basic.description' => '选择适合您的功能偏好',
			'firstTimeSetup.network.title' => '网络设置',
			'firstTimeSetup.network.subtitle' => '配置网络连接选项',
			'firstTimeSetup.network.description' => '根据您的网络环境进行相应配置',
			'firstTimeSetup.network.tip' => '需设置成功后重启应用才能生效',
			'firstTimeSetup.theme.title' => '主题设置',
			'firstTimeSetup.theme.subtitle' => '选择您喜欢的界面主题',
			'firstTimeSetup.theme.description' => '个性化您的视觉体验',
			'firstTimeSetup.player.title' => '播放器设置',
			'firstTimeSetup.player.subtitle' => '配置播放控制偏好',
			'firstTimeSetup.player.description' => '你可以在此快速设置常用的播放体验',
			'firstTimeSetup.completion.title' => '完成设置',
			'firstTimeSetup.completion.subtitle' => '即将开始您的精彩之旅',
			'firstTimeSetup.completion.description' => '请阅读并同意相关协议',
			'firstTimeSetup.completion.agreementTitle' => '用户协议和社区规则',
			'firstTimeSetup.completion.agreementDesc' => '在使用本应用前，请您仔细阅读并同意我们的用户协议和社区规则。这些条款有助于维护良好的使用环境。',
			'firstTimeSetup.completion.checkboxTitle' => '我已阅读并同意用户协议和社区规则',
			'firstTimeSetup.completion.checkboxSubtitle' => '不同意将无法使用本应用',
			'firstTimeSetup.common.settingsChangeableTip' => '这些设置都可以在应用设置中随时修改',
			'firstTimeSetup.common.agreeAgreementSnackbar' => '请先同意用户协议和社区规则',
			'proxyHelper.systemProxyDetected' => '检测到系统代理',
			'proxyHelper.copied' => '已复制',
			'proxyHelper.copy' => '复制',
			'tagSelector.selectTags' => '选择标签',
			'tagSelector.clickToSelectTags' => '点击选择标签',
			'tagSelector.addTag' => '添加标签',
			'tagSelector.removeTag' => '移除标签',
			'tagSelector.deleteTag' => '删除标签',
			'tagSelector.usageInstructions' => '需先添加标签，然后再从已有的标签中点击选中',
			'tagSelector.usageInstructionsTooltip' => '使用说明',
			'tagSelector.addTagTooltip' => '添加标签',
			'tagSelector.removeTagTooltip' => '删除标签',
			'tagSelector.cancelSelection' => '取消选择',
			'tagSelector.selectAll' => '全选',
			'tagSelector.cancelSelectAll' => '取消全选',
			'tagSelector.delete' => '删除',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Anime4K 实时视频上采样和降噪，提升动画视频质量',
			'anime4k.settings' => 'Anime4K 设置',
			'anime4k.preset' => 'Anime4K 预设',
			'anime4k.disable' => '关闭 Anime4K',
			'anime4k.disableDescription' => '禁用视频增强效果',
			'anime4k.highQualityPresets' => '高质量预设',
			'anime4k.fastPresets' => '快速预设',
			'anime4k.litePresets' => '轻量级预设',
			'anime4k.moreLitePresets' => '更多轻量级预设',
			'anime4k.customPresets' => '自定义预设',
			'anime4k.presetGroups.highQuality' => '高质量',
			'anime4k.presetGroups.fast' => '快速',
			'anime4k.presetGroups.lite' => '轻量级',
			'anime4k.presetGroups.moreLite' => '更多轻量级',
			'anime4k.presetGroups.custom' => '自定义',
			'anime4k.presetDescriptions.mode_a_hq' => '适用于大多数1080p动漫，特别是处理模糊、重采样和压缩瑕疵。提供最高的感知质量。',
			'anime4k.presetDescriptions.mode_b_hq' => '适用于轻微模糊或因缩放产生的振铃效应的动漫。可以有效减少振铃和锯齿。',
			'anime4k.presetDescriptions.mode_c_hq' => '适用于几乎没有瑕疵的高质量片源（如原生1080p的动画电影或壁纸）。降噪并提供最高的PSNR。',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Mode A的强化版，提供极致的感知质量，能重建几乎所有退化的线条。可能产生过度锐化或振铃。',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Mode B的强化版，提供更高的感知质量，进一步优化线条和减少瑕疵。',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Mode C的感知质量增强版，在保持高PSNR的同时尝试重建一些线条细节。',
			'anime4k.presetDescriptions.mode_a_fast' => 'Mode A的快速版本，平衡了质量与性能，适用于大多数1080p动漫。',
			'anime4k.presetDescriptions.mode_b_fast' => 'Mode B的快速版本，用于处理轻微瑕疵和振铃，性能开销较低。',
			'anime4k.presetDescriptions.mode_c_fast' => 'Mode C的快速版本，适用于高质量片源的快速降噪和放大。',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Mode A+A的快速版本，在性能有限的设备上追求更高的感知质量。',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Mode B+B的快速版本，为性能有限的设备提供增强的线条修复和瑕疵处理。',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Mode C+A的快速版本，在快速处理高质量片源的同时，进行轻度的线条修复。',
			'anime4k.presetDescriptions.upscale_only_s' => '仅使用最快的CNN模型进行x2放大，无修复和降噪，性能开销最低。',
			'anime4k.presetDescriptions.upscale_deblur_fast' => '使用快速的非CNN算法进行放大和去模糊，效果优于传统算法，性能开销很低。',
			'anime4k.presetDescriptions.restore_s_only' => '仅使用最快的CNN模型修复画面瑕疵，不进行放大。适用于原生分辨率播放，但希望改善画质的情况。',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => '使用传统的双边滤波器进行降噪，速度极快，适用于处理轻微噪点。',
			'anime4k.presetDescriptions.upscale_non_cnn' => '使用快速的传统算法进行放大，性能开销极低，效果优于播放器自带算法。',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + 线条加深，在快速模式A的基础上增加线条加深效果，使线条更突出，风格化处理。',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + 线条细化，在高质量模式A的基础上增加线条细化效果，让画面看起来更精致。',
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
			'anime4k.presetNames.restore_s_only' => '修复 (超快)',
			'anime4k.presetNames.denoise_bilateral_fast' => '双边降噪 (极快)',
			'anime4k.presetNames.upscale_non_cnn' => '非CNN放大 (极快)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + 线条加深',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + 线条细化',
			'anime4k.performanceTip' => '💡 提示：根据设备性能选择合适的预设，低端设备建议选择轻量级预设。',
			_ => null,
		};
	}
}
