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
class TranslationsVi extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsVi({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.vi,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <vi>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsVi _root = this; // ignore: unused_field

	@override 
	TranslationsVi $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsVi(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileVi personalProfile = _TranslationsPersonalProfileVi._(_root);
	@override late final _TranslationsTutorialVi tutorial = _TranslationsTutorialVi._(_root);
	@override late final _TranslationsCommonVi common = _TranslationsCommonVi._(_root);
	@override late final _TranslationsAuthVi auth = _TranslationsAuthVi._(_root);
	@override late final _TranslationsErrorsVi errors = _TranslationsErrorsVi._(_root);
	@override late final _TranslationsFriendsVi friends = _TranslationsFriendsVi._(_root);
	@override late final _TranslationsAuthorProfileVi authorProfile = _TranslationsAuthorProfileVi._(_root);
	@override late final _TranslationsFavoritesVi favorites = _TranslationsFavoritesVi._(_root);
	@override late final _TranslationsGalleryDetailVi galleryDetail = _TranslationsGalleryDetailVi._(_root);
	@override late final _TranslationsPlayListVi playList = _TranslationsPlayListVi._(_root);
	@override late final _TranslationsSearchVi search = _TranslationsSearchVi._(_root);
	@override late final _TranslationsMediaListVi mediaList = _TranslationsMediaListVi._(_root);
	@override late final _TranslationsSettingsVi settings = _TranslationsSettingsVi._(_root);
	@override late final _TranslationsFavoriteTagsVi favoriteTags = _TranslationsFavoriteTagsVi._(_root);
	@override late final _TranslationsOreno3dVi oreno3d = _TranslationsOreno3dVi._(_root);
	@override late final _TranslationsSignInVi signIn = _TranslationsSignInVi._(_root);
	@override late final _TranslationsSubscriptionsVi subscriptions = _TranslationsSubscriptionsVi._(_root);
	@override late final _TranslationsVideoDetailVi videoDetail = _TranslationsVideoDetailVi._(_root);
	@override late final _TranslationsShareVi share = _TranslationsShareVi._(_root);
	@override late final _TranslationsMarkdownVi markdown = _TranslationsMarkdownVi._(_root);
	@override late final _TranslationsForumVi forum = _TranslationsForumVi._(_root);
	@override late final _TranslationsNotificationsVi notifications = _TranslationsNotificationsVi._(_root);
	@override late final _TranslationsConversationVi conversation = _TranslationsConversationVi._(_root);
	@override late final _TranslationsSplashVi splash = _TranslationsSplashVi._(_root);
	@override late final _TranslationsDownloadVi download = _TranslationsDownloadVi._(_root);
	@override late final _TranslationsDownloadNotificationsVi downloadNotifications = _TranslationsDownloadNotificationsVi._(_root);
	@override late final _TranslationsFavoriteVi favorite = _TranslationsFavoriteVi._(_root);
	@override late final _TranslationsTranslationVi translation = _TranslationsTranslationVi._(_root);
	@override late final _TranslationsBottomNavVi bottomNav = _TranslationsBottomNavVi._(_root);
	@override late final _TranslationsNavigationOrderSettingsVi navigationOrderSettings = _TranslationsNavigationOrderSettingsVi._(_root);
	@override late final _TranslationsNewsVi news = _TranslationsNewsVi._(_root);
	@override late final _TranslationsDisplaySettingsVi displaySettings = _TranslationsDisplaySettingsVi._(_root);
	@override late final _TranslationsLayoutSettingsVi layoutSettings = _TranslationsLayoutSettingsVi._(_root);
	@override late final _TranslationsMediaPlayerVi mediaPlayer = _TranslationsMediaPlayerVi._(_root);
	@override late final _TranslationsDiagnosticsVi diagnostics = _TranslationsDiagnosticsVi._(_root);
	@override late final _TranslationsLogViewerVi logViewer = _TranslationsLogViewerVi._(_root);
	@override late final _TranslationsCrashRecoveryDialogVi crashRecoveryDialog = _TranslationsCrashRecoveryDialogVi._(_root);
	@override late final _TranslationsLinkInputDialogVi linkInputDialog = _TranslationsLinkInputDialogVi._(_root);
	@override late final _TranslationsLogVi log = _TranslationsLogVi._(_root);
	@override late final _TranslationsEmojiVi emoji = _TranslationsEmojiVi._(_root);
	@override late final _TranslationsSearchFilterVi searchFilter = _TranslationsSearchFilterVi._(_root);
	@override late final _TranslationsFirstTimeSetupVi firstTimeSetup = _TranslationsFirstTimeSetupVi._(_root);
	@override late final _TranslationsProxyHelperVi proxyHelper = _TranslationsProxyHelperVi._(_root);
	@override late final _TranslationsTagSelectorVi tagSelector = _TranslationsTagSelectorVi._(_root);
	@override late final _TranslationsAnime4kVi anime4k = _TranslationsAnime4kVi._(_root);
	@override late final _TranslationsSiteModeVi siteMode = _TranslationsSiteModeVi._(_root);
	@override late final _TranslationsSavedSearchConfigVi savedSearchConfig = _TranslationsSavedSearchConfigVi._(_root);
	@override late final _TranslationsSavedSearchVi savedSearch = _TranslationsSavedSearchVi._(_root);
	@override late final _TranslationsDefaultBlacklistReminderVi defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderVi._(_root);
	@override late final _TranslationsColorVisionAssistVi colorVisionAssist = _TranslationsColorVisionAssistVi._(_root);
	@override late final _TranslationsExternalPlayerVi externalPlayer = _TranslationsExternalPlayerVi._(_root);
	@override late final _TranslationsWatchLaterVi watchLater = _TranslationsWatchLaterVi._(_root);
	@override late final _TranslationsMediaMenuVi mediaMenu = _TranslationsMediaMenuVi._(_root);
	@override late final _TranslationsMediaPreviewVi mediaPreview = _TranslationsMediaPreviewVi._(_root);
	@override late final _TranslationsPlaybackQueueVi playbackQueue = _TranslationsPlaybackQueueVi._(_root);
	@override late final _TranslationsVrFormatVi vrFormat = _TranslationsVrFormatVi._(_root);
	@override late final _TranslationsLocalMediaVi localMedia = _TranslationsLocalMediaVi._(_root);
	@override late final _TranslationsHistoryPageVi historyPage = _TranslationsHistoryPageVi._(_root);
	@override late final _TranslationsAiVi ai = _TranslationsAiVi._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileVi extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Trang cá nhân';
	@override String get editPersonalProfile => 'Chỉnh sửa trang cá nhân';
	@override String get avatar => 'Ảnh đại diện';
	@override String get background => 'Ảnh nền';
	@override String fetchUserProfileFailed({required Object error}) => 'Không lấy được trang cá nhân: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Độ phân giải đề xuất: ${resolution}, kích thước tệp < ${size}';
	@override String supportedFormats({required Object formats}) => 'Định dạng được hỗ trợ: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Người dùng Premium có thể dùng ${type} động (${formats})';
	@override String get homepageBackground => 'Ảnh nền trang chủ';
	@override String get basicInfo => 'Thông tin cơ bản';
	@override String get nickname => 'Biệt danh';
	@override String get username => 'Tên người dùng';
	@override String get copyUsername => 'Sao chép tên người dùng';
	@override String get usernameCopied => 'Đã sao chép tên người dùng';
	@override String get personalIntroduction => 'Giới thiệu cá nhân';
	@override String get noPersonalIntroduction => 'Không có giới thiệu cá nhân';
	@override String get clickToEdit => 'Nhấn để chỉnh sửa';
	@override String get privacySettings => 'Cài đặt quyền riêng tư';
	@override String get hideSensitiveContent => 'Ẩn nội dung nhạy cảm';
	@override String get hideSensitiveContentDesc => 'Ẩn mọi video hoặc hình ảnh chứa thẻ nhạy cảm.';
	@override String get notificationSettings => 'Cài đặt thông báo';
	@override String get contentCommentNotification => 'Thông báo bình luận nội dung';
	@override String get contentCommentNotificationDesc => 'Thông báo khi có người bình luận về nội dung của bạn.';
	@override String get commentReplyNotification => 'Thông báo trả lời bình luận';
	@override String get commentReplyNotificationDesc => 'Thông báo khi có người trả lời bình luận của bạn.';
	@override String get mentionNotification => 'Thông báo nhắc đến';
	@override String get mentionNotificationDesc => 'Thông báo khi có người nhắc đến bạn trong nội dung.';
	@override String get accountInfo => 'Thông tin tài khoản';
	@override String get registrationTime => 'Thời gian đăng ký';
	@override String updateSettingsFailed({required Object error}) => 'Cập nhật cài đặt thất bại: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'Cập nhật cài đặt thông báo thất bại: ${error}';
	@override String get editNickname => 'Chỉnh sửa biệt danh';
	@override String get nicknameCannotBeEmpty => 'Biệt danh không được để trống';
	@override String get changeSuccess => 'Thay đổi thành công';
	@override String get unsupportedFileFormat => 'Định dạng tệp không được hỗ trợ';
	@override String fileTooLarge({required Object size}) => 'Kích thước tệp không được vượt quá ${size}';
	@override String get uploadFailed => 'Tải lên thất bại';
	@override String get avatarUpdatedSuccessfully => 'Cập nhật ảnh đại diện thành công';
	@override String updateAvatarFailed({required Object error}) => 'Cập nhật ảnh đại diện thất bại: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Cập nhật ảnh nền thành công';
	@override String updateBackgroundFailed({required Object error}) => 'Cập nhật ảnh nền thất bại: ${error}';
	@override String get editPersonalIntroduction => 'Chỉnh sửa giới thiệu cá nhân';
	@override String get enterPersonalIntroduction => 'Vui lòng nhập giới thiệu cá nhân';
}

// Path: tutorial
class _TranslationsTutorialVi extends TranslationsTutorialEn {
	_TranslationsTutorialVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Theo dõi đặc biệt';
	@override String get specialFollowDescription => 'Đánh dấu những tác giả bạn xem nhiều nhất là theo dõi đặc biệt, rồi vào thẳng video mới nhất của họ từ đây.';
	@override String get stepsTitle => 'Ba bước';
	@override String get stepFollowAuthor => 'Nhấn Theo dõi trên trang video, thư viện hoặc trang cá nhân của tác giả.';
	@override String get stepPickSpecial => 'Nhấn Đã theo dõi lần nữa, rồi chọn Theo dõi đặc biệt từ menu.';
	@override String get stepSwitchHere => 'Quay lại đây và chuyển sang tác giả đó bằng trình chọn ảnh đại diện ở trên.';
	@override String get specialFollowManagementTip => 'Quản lý danh sách theo dõi đặc biệt trong Thanh bên - Danh sách theo dõi - Theo dõi đặc biệt.';
	@override String get gotIt => 'Đã hiểu';
}

// Path: common
class _TranslationsCommonVi extends TranslationsCommonEn {
	_TranslationsCommonVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Sắp xếp';
	@override String get filter => 'Bộ lọc';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'OK';
	@override String get cancel => 'Hủy';
	@override String get select => 'Chọn';
	@override String get save => 'Lưu';
	@override String get delete => 'Xóa';
	@override String get visit => 'Truy cập';
	@override String get loading => 'Đang tải...';
	@override String get scrollToTop => 'Lên đầu trang';
	@override String get privacyHint => 'Chế độ riêng tư đang bật, nội dung bị ẩn';
	@override String get latest => 'Mới nhất';
	@override String get likesCount => 'Lượt thích';
	@override String get viewsCount => 'Lượt xem';
	@override String get popular => 'Phổ biến';
	@override String get trending => 'Xu hướng';
	@override String get commentList => 'Danh sách bình luận';
	@override String get sendComment => 'Gửi bình luận';
	@override String get send => 'Gửi';
	@override String get retry => 'Thử lại';
	@override String get premium => 'Cao cấp';
	@override String get follower => 'Người theo dõi';
	@override String get friend => 'Bạn bè';
	@override String get video => 'Video';
	@override String get following => 'Đang theo dõi';
	@override String get expand => 'Mở rộng';
	@override String get collapse => 'Thu gọn';
	@override String get cancelFriendRequest => 'Hủy yêu cầu';
	@override String get cancelSpecialFollow => 'Hủy theo dõi đặc biệt';
	@override String get addFriend => 'Thêm bạn';
	@override String get removeFriend => 'Xóa bạn';
	@override String get followed => 'Đã theo dõi';
	@override String get follow => 'Theo dõi';
	@override String get unfollow => 'Bỏ theo dõi';
	@override String get specialFollow => 'Theo dõi đặc biệt';
	@override String get specialFollowed => 'Đã theo dõi đặc biệt';
	@override String get gallery => 'Thư viện';
	@override String get playlist => 'Danh sách phát';
	@override String get commentPostedSuccessfully => 'Đã đăng bình luận';
	@override String get commentPostedFailed => 'Đăng bình luận thất bại';
	@override String get success => 'Thành công';
	@override String get commentDeletedSuccessfully => 'Đã xóa bình luận';
	@override String get commentUpdatedSuccessfully => 'Cập nhật bình luận thành công';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} bình luận',
		other: '${n} bình luận',
	);
	@override String get writeYourCommentHere => 'Viết bình luận tại đây...';
	@override String get tmpNoReplies => 'Chưa có trả lời';
	@override String get loadMore => 'Tải thêm';
	@override String get loadingMore => 'Đang tải thêm...';
	@override String get noMoreDatas => 'Không còn dữ liệu';
	@override String get selectTranslationLanguage => 'Chọn ngôn ngữ dịch';
	@override String get translate => 'Dịch';
	@override String get translateFailedPleaseTryAgainLater => 'Dịch thất bại, vui lòng thử lại sau';
	@override String get translationResult => 'Kết quả dịch';
	@override String get justNow => 'Vừa xong';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} phút trước',
		other: '${n} phút trước',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} giờ trước',
		other: '${n} giờ trước',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} ngày trước',
		other: '${n} ngày trước',
	);
	@override String editedAt({required Object num}) => 'Đã chỉnh sửa ${num}';
	@override String get editComment => 'Chỉnh sửa bình luận';
	@override String get commentUpdated => 'Đã cập nhật bình luận';
	@override String get replyComment => 'Trả lời bình luận';
	@override String get reply => 'Trả lời';
	@override String get edit => 'Chỉnh sửa';
	@override String get unknownUser => 'Người dùng không xác định';
	@override String get me => 'Tôi';
	@override String get author => 'Tác giả';
	@override String get admin => 'Quản trị viên';
	@override String viewReplies({required Object num}) => 'Xem trả lời (${num})';
	@override String get hideReplies => 'Ẩn trả lời';
	@override String get confirmDelete => 'Xác nhận xóa';
	@override String get areYouSureYouWantToDeleteThisItem => 'Bạn có chắc muốn xóa mục này?';
	@override String get tmpNoComments => 'Chưa có bình luận';
	@override String get refresh => 'Làm mới';
	@override String get back => 'Quay lại';
	@override String get tips => 'Mẹo';
	@override String get linkIsEmpty => 'Liên kết trống';
	@override String get linkCopiedToClipboard => 'Đã sao chép liên kết';
	@override String get imageCopiedToClipboard => 'Đã sao chép ảnh vào clipboard';
	@override String get copyImageFailed => 'Sao chép ảnh thất bại';
	@override String get mobileSaveImageIsUnderDevelopment => 'Tính năng lưu ảnh trên di động đang được phát triển';
	@override String get imageSavedTo => 'Đã lưu ảnh vào';
	@override String get saveImageFailed => 'Lưu ảnh thất bại';
	@override String get close => 'Đóng';
	@override String get more => 'Thêm';
	@override String get unknownError => 'Lỗi không xác định';
	@override String get moreFeaturesToBeDeveloped => 'Nhiều tính năng khác đang được phát triển';
	@override String get all => 'Tất cả';
	@override String selectedRecords({required Object num}) => 'Đã chọn ${num} bản ghi';
	@override String get cancelSelectAll => 'Bỏ chọn tất cả';
	@override String get selectAll => 'Chọn tất cả';
	@override String get invertSelection => 'Đảo lựa chọn';
	@override String get exitEditMode => 'Thoát chế độ chỉnh sửa';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Bạn có chắc muốn xóa ${num} mục đã chọn?';
	@override String get searchHistoryRecords => 'Tìm kiếm bản ghi lịch sử...';
	@override String get settings => 'Cài đặt';
	@override String get subscriptions => 'Đăng ký';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} video',
		other: '${n} video',
	);
	@override String get share => 'Chia sẻ';
	@override String get areYouSureYouWantToShareThisPlaylist => 'Bạn có chắc muốn chia sẻ danh sách phát này?';
	@override String get editTitle => 'Chỉnh sửa tiêu đề';
	@override String get editMode => 'Chế độ chỉnh sửa';
	@override String get pleaseEnterNewTitle => 'Vui lòng nhập tiêu đề mới';
	@override String get createPlayList => 'Tạo danh sách phát';
	@override String get create => 'Tạo';
	@override String get checkNetworkSettings => 'Kiểm tra cài đặt mạng';
	@override String get general => 'Chung';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Nhạy cảm';
	@override String get year => 'Năm';
	@override String get month => 'Tháng';
	@override String get tag => 'Thẻ';
	@override String get private => 'Riêng tư';
	@override String get noTitle => 'Không có tiêu đề';
	@override String get search => 'Tìm kiếm';
	@override String get noContent => 'Không có nội dung';
	@override String get recording => 'Đang ghi';
	@override String get paused => 'Đã tạm dừng';
	@override String get clear => 'Xóa';
	@override String get clearSelection => 'Bỏ chọn';
	@override String get selectItemsToContinue => 'Chọn mục để tiếp tục';
	@override String andMoreItems({required Object num}) => 'và ${num} mục nữa';
	@override String get batchDelete => 'Xóa hàng loạt';
	@override String get user => 'Người dùng';
	@override String get post => 'Bài viết';
	@override String get seconds => 'Giây';
	@override String get comingSoon => 'Sắp ra mắt';
	@override String get confirm => 'Xác nhận';
	@override String get hour => 'Giờ';
	@override String get minute => 'Phút';
	@override String get clickToRefresh => 'Nhấn để làm mới';
	@override String get history => 'Lịch sử';
	@override String get favorites => 'Yêu thích';
	@override String get friends => 'Bạn bè';
	@override String get playList => 'Danh sách phát';
	@override String get checkLicense => 'Kiểm tra giấy phép';
	@override String get logout => 'Đăng xuất';
	@override String get fensi => 'Người hâm mộ';
	@override String get accept => 'Chấp nhận';
	@override String get reject => 'Từ chối';
	@override String get clearAllHistory => 'Xóa toàn bộ lịch sử';
	@override String get clearAllHistoryConfirm => 'Bạn có chắc muốn xóa toàn bộ lịch sử?';
	@override String get followingList => 'Danh sách đang theo dõi';
	@override String get followersList => 'Danh sách người theo dõi';
	@override String get follows => 'Đang theo dõi';
	@override String get fans => 'Người hâm mộ';
	@override String get followsAndFans => 'Đang theo dõi và người hâm mộ';
	@override String get numViews => 'Lượt xem';
	@override String get updatedAt => 'Cập nhật lúc';
	@override String get publishedAt => 'Đăng lúc';
	@override String get externalVideo => 'Video ngoài';
	@override String get originalText => 'Văn bản gốc';
	@override String get showOriginalText => 'Hiện văn bản gốc';
	@override String get showProcessedText => 'Hiện văn bản đã xử lý';
	@override String get preview => 'Xem trước';
	@override String get rules => 'Quy tắc';
	@override String get agree => 'Đồng ý';
	@override String get disagree => 'Không đồng ý';
	@override String get agreeToRules => 'Đồng ý với quy tắc';
	@override String get tapToReread => 'Chạm để đọc lại';
	@override String get markdownSyntaxHelp => 'Trợ giúp cú pháp Markdown';
	@override String get previewContent => 'Xem trước nội dung';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Vượt quá giới hạn độ dài tối đa (${max})';
	@override String get agreeToCommunityRules => 'Đồng ý với quy tắc cộng đồng';
	@override String get createPost => 'Tạo bài viết';
	@override String get title => 'Tiêu đề';
	@override String get enterTitle => 'Vui lòng nhập tiêu đề';
	@override String get content => 'Nội dung';
	@override String get enterContent => 'Vui lòng nhập nội dung';
	@override String get writeYourContentHere => 'Vui lòng nhập nội dung...';
	@override String get tagBlacklist => 'Danh sách thẻ chặn';
	@override String get noData => 'Không có dữ liệu';
	@override String get tagLimit => 'Giới hạn thẻ';
	@override String get enableFloatingButtons => 'Bật nút nổi';
	@override String get disableFloatingButtons => 'Tắt nút nổi';
	@override String get enabledFloatingButtons => 'Đã bật nút nổi';
	@override String get disabledFloatingButtons => 'Đã tắt nút nổi';
	@override String get pendingCommentCount => 'Số bình luận đang chờ';
	@override String joined({required Object str}) => 'Tham gia ${str}';
	@override String lastSeenAt({required Object str}) => 'Hoạt động lần cuối ${str}';
	@override String get download => 'Tải xuống';
	@override String get selectQuality => 'Chọn chất lượng';
	@override String get videoQualitySource => 'Nguồn';
	@override String get selectImageQuality => 'Chọn chất lượng ảnh';
	@override String get imageQualityStandard => 'Tiêu chuẩn';
	@override String get imageQualityOriginal => 'Nguyên bản';
	@override String get selectDateRange => 'Chọn khoảng ngày';
	@override String get selectDateRangeHint => 'Chọn khoảng ngày, mặc định là 30 ngày gần nhất';
	@override String get clearDateRange => 'Xóa khoảng ngày';
	@override String get deleteRecordsInDateRange => 'Xóa bản ghi trong khoảng này';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'Bạn có chắc muốn xóa ${num} bản ghi lịch sử trong khoảng ngày này? Thao tác này không thể hoàn tác.';
	@override String get noHistoryRecordsInRange => 'Không có bản ghi lịch sử trong khoảng ngày này';
	@override String get followSuccessClickAgainToSpecialFollow => 'Đã theo dõi, nhấn lần nữa để theo dõi đặc biệt';
	@override String get specialFollowTip => 'Đã thêm vào theo dõi đặc biệt — chọn từ danh sách ở góc trên bên phải trang Đăng ký để truy cập nhanh';
	@override String get exitConfirmTip => 'Bạn có chắc muốn thoát?';
	@override String get error => 'Lỗi';
	@override String get taskRunning => 'Đang có tác vụ chạy, vui lòng đợi.';
	@override String get operationCancelled => 'Đã hủy thao tác.';
	@override String get unsavedChanges => 'Có thay đổi chưa lưu';
	@override String get specialFollowsManagementTip => 'Kéo tay cầm để sắp xếp lại • Nhấn nút để xóa';
	@override String get specialFollowsManagement => 'Quản lý theo dõi đặc biệt';
	@override String get removeSpecialFollow => 'Hủy theo dõi đặc biệt';
	@override String removeSpecialFollowConfirm({required Object name}) => 'Hủy theo dõi đặc biệt với ${name}?';
	@override String get noSpecialFollows => 'Chưa có theo dõi đặc biệt';
	@override String get createTimeDesc => 'Thời gian tạo giảm dần';
	@override String get createTimeAsc => 'Thời gian tạo tăng dần';
	@override late final _TranslationsCommonPaginationVi pagination = _TranslationsCommonPaginationVi._(_root);
	@override String get notice => 'Thông báo';
	@override String get detail => 'Chi tiết';
	@override String get parseExceptionDestopHint => ' - Người dùng máy tính có thể cấu hình proxy trong cài đặt';
	@override String get iwaraTags => 'Thẻ Iwara';
	@override String get tagInfo => 'Thông tin thẻ';
	@override String get tagOriginalKey => 'Thẻ gốc';
	@override String get tagTranslation => 'Bản dịch';
	@override String get copy => 'Sao chép';
	@override String get selectCopy => 'Chọn & Sao chép';
	@override String get copiedToClipboard => 'Đã sao chép vào clipboard';
	@override String get showOriginalTag => 'Hiện thẻ gốc';
	@override String get showTranslatedTag => 'Hiện bản dịch';
	@override String get tagTranslationFeedback => 'Còn nghi ngờ về bản dịch? Gửi phản hồi';
	@override String get tagLocalizationGuideTitle => 'Về bản địa hóa thẻ';
	@override String get tagLocalizationGuideContent => 'Ứng dụng hiển thị thẻ gốc của Iwara (ví dụ: mother) bằng tên theo ngôn ngữ hiện tại của bạn.\n\n• Khi tìm kiếm thẻ, cả bản dịch và thẻ gốc đều được khớp.\n• Nhấn giữ / nhấp chuột phải vào thẻ để xem và sao chép khóa gốc cùng bản dịch.\n• Bản dịch do cộng đồng duy trì và chỉ ở mức tốt nhất có thể — có thể còn sai sót.';
	@override String get likeThisVideo => 'Thích video này';
	@override String get likeThisGallery => 'Thích thư viện này';
	@override String get operation => 'Thao tác';
	@override String get replies => 'Trả lời';
	@override String get externalLinkWarning => 'Cảnh báo liên kết ngoài';
	@override String get externalLinkWarningMessage => 'Bạn sắp mở một liên kết ngoài không thuộc iwara.tv. Hãy cẩn trọng và đảm bảo liên kết an toàn trước khi tiếp tục.';
	@override String get continueToExternalLink => 'Tiếp tục';
	@override String get cancelExternalLink => 'Hủy';
}

// Path: auth
class _TranslationsAuthVi extends TranslationsAuthEn {
	_TranslationsAuthVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get login => 'Đăng nhập';
	@override String get logout => 'Đăng xuất';
	@override String get email => 'Email';
	@override String get password => 'Mật khẩu';
	@override String get loginOrRegister => 'Đăng nhập / Đăng ký';
	@override String get register => 'Đăng ký';
	@override String get pleaseEnterEmail => 'Vui lòng nhập email';
	@override String get pleaseEnterPassword => 'Vui lòng nhập mật khẩu';
	@override String get passwordMustBeAtLeast6Characters => 'Mật khẩu phải có ít nhất 6 ký tự';
	@override String get pleaseEnterCaptcha => 'Vui lòng nhập mã xác nhận';
	@override String get captcha => 'Mã xác nhận';
	@override String get refreshCaptcha => 'Làm mới mã xác nhận';
	@override String get captchaNotLoaded => 'Chưa tải mã xác nhận';
	@override String get loginSuccess => 'Đăng nhập thành công';
	@override String get loginSuccessProfilePending => 'Đã đăng nhập. Đang tải hồ sơ…';
	@override String get emailVerificationSent => 'Đã gửi email xác minh';
	@override String get notLoggedIn => 'Chưa đăng nhập';
	@override String get clickToLogin => 'Nhấn để đăng nhập';
	@override String get logoutConfirmation => 'Bạn có chắc muốn đăng xuất?';
	@override String get logoutSuccess => 'Đăng xuất thành công';
	@override String get logoutFailed => 'Đăng xuất thất bại';
	@override String get usernameOrEmail => 'Tên người dùng hoặc Email';
	@override String get pleaseEnterUsernameOrEmail => 'Vui lòng nhập tên người dùng hoặc email';
	@override String get rememberMe => 'Ghi nhớ tên người dùng';
	@override String get registerNoticeTitle => 'Đăng ký trên trang web chính thức';
	@override String get registerNoticeDescription => 'Không còn hỗ trợ đăng ký trong ứng dụng. Vui lòng tới trang web chính thức của Iwara để tạo tài khoản, sau đó quay lại đây để đăng nhập.';
	@override String get registerNoticeReturnTip => 'Sau khi đăng ký, hãy quay lại đây và đăng nhập bằng tài khoản.';
	@override String get goToOfficialWebsite => 'Tới trang web chính thức';
}

// Path: errors
class _TranslationsErrorsVi extends TranslationsErrorsEn {
	_TranslationsErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get error => 'Lỗi';
	@override String get required => 'Trường này là bắt buộc';
	@override String get invalidEmail => 'Địa chỉ email không hợp lệ';
	@override String get networkError => 'Lỗi mạng, vui lòng thử lại';
	@override String get errorWhileFetching => 'Đã xảy ra lỗi khi tải';
	@override String get commentCanNotBeEmpty => 'Nội dung bình luận không được để trống';
	@override String get errorWhileFetchingReplies => 'Lỗi khi tải trả lời, vui lòng kiểm tra kết nối mạng';
	@override String get canNotFindCommentController => 'Không tìm thấy bộ điều khiển bình luận';
	@override String get errorWhileLoadingGallery => 'Lỗi khi tải thư viện';
	@override String get howCouldThereBeNoDataItCantBePossible => 'Sao lại không có dữ liệu? Không thể như vậy được :<';
	@override String unsupportedImageFormat({required Object str}) => 'Định dạng ảnh không được hỗ trợ: ${str}';
	@override String get invalidGalleryId => 'ID thư viện không hợp lệ';
	@override String get translationFailedPleaseTryAgainLater => 'Dịch thất bại, vui lòng thử lại sau';
	@override String get errorOccurred => 'Đã xảy ra lỗi, vui lòng thử lại sau.';
	@override String get errorOccurredWhileProcessingRequest => 'Đã xảy ra lỗi khi xử lý yêu cầu';
	@override String get errorWhileFetchingDatas => 'Lỗi khi tải dữ liệu, vui lòng thử lại sau';
	@override String get serviceNotInitialized => 'Dịch vụ chưa được khởi tạo';
	@override String get unknownType => 'Loại không xác định';
	@override String errorWhileOpeningLink({required Object link}) => 'Lỗi khi mở liên kết: ${link}';
	@override String get invalidUrl => 'URL không hợp lệ';
	@override String get failedToOperate => 'Thao tác thất bại';
	@override String get permissionDenied => 'Quyền bị từ chối';
	@override String get youDoNotHavePermissionToAccessThisResource => 'Bạn không có quyền truy cập tài nguyên này';
	@override String get loginFailed => 'Đăng nhập thất bại';
	@override String get unknownError => 'Lỗi không xác định';
	@override String get sessionExpired => 'Phiên đã hết hạn';
	@override String get failedToFetchCaptcha => 'Lấy mã xác nhận thất bại';
	@override String get emailAlreadyExists => 'Email đã tồn tại';
	@override String get invalidCaptcha => 'Mã xác nhận không hợp lệ';
	@override String get registerFailed => 'Đăng ký thất bại';
	@override String get failedToFetchComments => 'Lấy bình luận thất bại';
	@override String get failedToFetchImageDetail => 'Lấy chi tiết ảnh thất bại';
	@override String get failedToFetchImageList => 'Lấy danh sách ảnh thất bại';
	@override String get failedToFetchData => 'Lấy dữ liệu thất bại';
	@override String get invalidParameter => 'Tham số không hợp lệ';
	@override String get pleaseLoginFirst => 'Vui lòng đăng nhập trước';
	@override String get errorWhileLoadingPost => 'Lỗi khi tải bài viết';
	@override String get errorWhileLoadingPostDetail => 'Lỗi khi tải chi tiết bài viết';
	@override String get invalidPostId => 'ID bài viết không hợp lệ';
	@override String get forceUpdateNotPermittedToGoBack => 'Đang ở trạng thái buộc cập nhật, không thể quay lại';
	@override String get pleaseLoginAgain => 'Vui lòng đăng nhập lại';
	@override String get invalidLogin => 'Đăng nhập không hợp lệ, vui lòng kiểm tra email và mật khẩu';
	@override String get tooManyRequests => 'Quá nhiều yêu cầu, vui lòng thử lại sau';
	@override String exceedsMaxLength({required Object max}) => 'Vượt quá độ dài tối đa: ${max}';
	@override String get contentCanNotBeEmpty => 'Nội dung không được để trống';
	@override String get titleCanNotBeEmpty => 'Tiêu đề không được để trống';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Quá nhiều yêu cầu, vui lòng thử lại sau, còn lại';
	@override String remainingHours({required Object num}) => '${num} giờ';
	@override String remainingMinutes({required Object num}) => '${num} phút';
	@override String remainingSeconds({required Object num}) => '${num} giây';
	@override String tagLimitExceeded({required Object limit}) => 'Vượt quá giới hạn thẻ, giới hạn: ${limit}';
	@override String get failedToRefresh => 'Làm mới thất bại';
	@override String get noPermission => 'Không có quyền';
	@override String get resourceNotFound => 'Không tìm thấy tài nguyên';
	@override String get failedToSaveCredentials => 'Lưu thông tin đăng nhập thất bại';
	@override String get failedToLoadSavedCredentials => 'Tải thông tin đăng nhập đã lưu thất bại';
	@override String get notFound => 'Không tìm thấy nội dung hoặc nội dung đã bị xóa';
	@override late final _TranslationsErrorsNetworkVi network = _TranslationsErrorsNetworkVi._(_root);
}

// Path: friends
class _TranslationsFriendsVi extends TranslationsFriendsEn {
	_TranslationsFriendsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Nhấn để khôi phục bạn bè';
	@override String get friendsList => 'Danh sách bạn bè';
	@override String get friendRequests => 'Yêu cầu kết bạn';
	@override String get friendRequestsList => 'Danh sách yêu cầu kết bạn';
	@override String get removingFriend => 'Đang xóa bạn bè...';
	@override String get failedToRemoveFriend => 'Xóa bạn bè thất bại';
	@override String get cancelingRequest => 'Đang hủy yêu cầu kết bạn...';
	@override String get failedToCancelRequest => 'Hủy yêu cầu kết bạn thất bại';
}

// Path: authorProfile
class _TranslationsAuthorProfileVi extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'Không còn dữ liệu';
	@override String get userProfile => 'Hồ sơ người dùng';
}

// Path: favorites
class _TranslationsFavoritesVi extends TranslationsFavoritesEn {
	_TranslationsFavoritesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Nhấn để khôi phục yêu thích';
	@override String get myFavorites => 'Yêu thích của tôi';
	@override String get batchCancelFavorite => 'Xóa các mục yêu thích đã chọn';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'Xóa ${count} mục đã chọn khỏi yêu thích? Sau đó có thể khôi phục bằng cách nhấn vào thẻ.';
	@override String batchCancelFavoriteSuccess({required Object count}) => 'Đã xóa ${count} mục khỏi yêu thích';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => 'Đã xóa ${success} mục, ${failed} mục thất bại';
}

// Path: galleryDetail
class _TranslationsGalleryDetailVi extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Duyệt trong không gian';
	@override String get galleryDetail => 'Chi tiết thư viện';
	@override String get viewGalleryDetail => 'Xem chi tiết thư viện';
	@override String get zoomReset => 'Đặt lại thu phóng';
	@override String get copyLink => 'Sao chép liên kết';
	@override String get copyImage => 'Sao chép ảnh';
	@override String get saveAs => 'Lưu thành';
	@override String get saveToAlbum => 'Lưu vào album';
	@override String get publishedAt => 'Đăng lúc';
	@override String get viewsCount => 'Số lượt xem';
	@override String get imageLibraryFunctionIntroduction => 'Giới thiệu chức năng thư viện ảnh';
	@override String get rightClickToSaveSingleImage => 'Nhấp chuột phải để lưu ảnh đơn';
	@override String get batchSave => 'Lưu hàng loạt';
	@override String get keyboardLeftAndRightToSwitch => 'Phím trái và phải để chuyển';
	@override String get keyboardUpAndDownToZoom => 'Phím lên và xuống để thu phóng';
	@override String get mouseWheelToSwitch => 'Con lăn chuột để chuyển';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + Con lăn chuột để thu phóng';
	@override String get moreFeaturesToBeDiscovered => 'Nhiều tính năng khác đang chờ khám phá...';
	@override String get authorOtherGalleries => 'Thư viện khác của tác giả';
	@override String get relatedGalleries => 'Thư viện liên quan';
	@override String get authorNoOtherGalleries => 'Tác giả này không có thư viện nào khác';
	@override String get noRelatedGalleries => 'Không có thư viện liên quan';
	@override String get scrollLeft => 'Cuộn sang trái';
	@override String get scrollRight => 'Cuộn sang phải';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Nhấn vào mép trái và phải để chuyển ảnh';
	@override String get rotateToLandscape => 'Toàn màn hình ngang';
	@override String get backToPortrait => 'Quay lại dọc';
}

// Path: playList
class _TranslationsPlayListVi extends TranslationsPlayListEn {
	_TranslationsPlayListVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Danh sách phát của tôi';
	@override String get friendlyTips => 'Gợi ý hữu ích';
	@override String get dearUser => 'Người dùng thân mến';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'Hệ thống danh sách phát của Iwara vẫn chưa hoàn thiện';
	@override String get notSupportSetCover => 'Không hỗ trợ đặt ảnh bìa';
	@override String get notSupportDeleteList => 'Không hỗ trợ xóa danh sách';
	@override String get notSupportSetPrivate => 'Không hỗ trợ đặt riêng tư';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Có... danh sách đã tạo sẽ luôn tồn tại và hiển thị với mọi người';
	@override String get smallSuggestion => 'Gợi ý nhỏ';
	@override String get useLikeToCollectContent => 'Nếu bạn quan tâm đến quyền riêng tư hơn, nên dùng chức năng "thích" để lưu nội dung';
	@override String get welcomeToDiscussOnGitHub => 'Nếu bạn có gợi ý hoặc ý tưởng khác, hoan nghênh thảo luận trên GitHub!';
	@override String get iUnderstand => 'Đã hiểu';
	@override String get searchPlaylists => 'Tìm kiếm danh sách phát...';
	@override String get newPlaylistName => 'Tên danh sách phát mới';
	@override String get createNewPlaylist => 'Tạo danh sách phát mới';
	@override String get videos => 'Video';
}

// Path: search
class _TranslationsSearchVi extends TranslationsSearchEn {
	_TranslationsSearchVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Phạm vi tìm kiếm';
	@override String get searchTags => 'Tìm kiếm thẻ...';
	@override String get contentRating => 'Xếp hạng nội dung';
	@override String get removeTag => 'Xóa thẻ';
	@override String get pleaseEnterSearchContent => 'Vui lòng nhập nội dung tìm kiếm';
	@override String get exactMatch => 'Chính xác';
	@override String get exactMatchOnHint => 'Đang khớp chính xác cụm từ, đồng thời tìm cả tiêu đề tiếng Trung và tiếng Nhật. Chạm để tìm rộng hơn.';
	@override String get exactMatchOffHint => 'Đang khớp lỏng — Iwara tách các từ ra. Chạm để khớp chính xác cụm từ.';
	@override String get searchHistory => 'Lịch sử tìm kiếm';
	@override String get searchSuggestion => 'Gợi ý tìm kiếm';
	@override String get usedTimes => 'Số lần sử dụng';
	@override String get lastUsed => 'Dùng gần đây';
	@override String get noSearchHistoryRecords => 'Không có lịch sử tìm kiếm';
	@override String get clearSearchHistoryConfirm => 'Bạn có chắc muốn xóa toàn bộ lịch sử tìm kiếm? Thao tác này không thể hoàn tác.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Chưa hỗ trợ loại tìm kiếm hiện tại ${searchType}, vui lòng chờ bản cập nhật';
	@override String get searchResult => 'Kết quả tìm kiếm';
	@override String unsupportedSearchType({required Object searchType}) => 'Loại tìm kiếm không được hỗ trợ: ${searchType}';
	@override String get googleSearch => 'Tìm kiếm Google';
	@override String googleSearchHint({required Object webName}) => 'Chức năng tìm kiếm của ${webName} không dễ dùng? Hãy thử Tìm kiếm Google!';
	@override String get googleSearchDescription => 'Dùng toán tử tìm kiếm :site của Google Search để tìm nội dung trên trang web. Rất hữu ích khi tìm video, thư viện, danh sách phát và người dùng.';
	@override String get googleSearchKeywordsHint => 'Nhập từ khóa để tìm kiếm';
	@override String get openLinkJump => 'Mở chuyển tiếp liên kết';
	@override String get googleSearchButton => 'Tìm kiếm Google';
	@override String get pleaseEnterSearchKeywords => 'Vui lòng nhập từ khóa tìm kiếm';
	@override String get googleSearchQueryCopied => 'Đã sao chép truy vấn tìm kiếm vào bộ nhớ tạm';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'Không mở được trình duyệt: ${error}';
	@override String get searchRequestTimeout => 'Yêu cầu quá thời gian, vui lòng thử lại sau';
	@override String get searchCannotConnectToServer => 'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng';
	@override String get searchNetworkError => 'Kết nối mạng thất bại, vui lòng kiểm tra cài đặt mạng hoặc thử lại sau';
	@override String get searchFailedPleaseRetry => 'Tìm kiếm thất bại, vui lòng thử lại sau';
}

// Path: mediaList
class _TranslationsMediaListVi extends TranslationsMediaListEn {
	_TranslationsMediaListVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Giới thiệu';
}

// Path: settings
class _TranslationsSettingsVi extends TranslationsSettingsEn {
	_TranslationsSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Chế độ xem danh sách';
	@override String get previewEffect => 'Xem trước hiệu ứng';
	@override String get useTraditionalPaginationMode => 'Dùng chế độ phân trang truyền thống';
	@override String get useTraditionalPaginationModeDesc => 'Bật chế độ phân trang truyền thống, tắt chế độ thác nước. Có hiệu lực sau khi hiển thị lại trang hoặc khởi động lại ứng dụng';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Hiển thị thanh tiến trình video khi ẩn thanh công cụ';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Cấu hình này quyết định thanh tiến trình video có hiển thị khi thanh công cụ bị ẩn hay không.';
	@override String get seekPreviewSize => 'Kích thước xem trước khi tua';
	@override String get seekPreviewSizeDesc => 'Cửa sổ xem trước phía trên thanh tiến trình lớn đến mức nào. Nó vốn đã theo kích thước trình phát và tỉ lệ khung hình của video; mục này chỉ tinh chỉnh thêm.';
	@override String get seekPreviewSizeSmall => 'Nhỏ';
	@override String get seekPreviewSizeStandard => 'Tiêu chuẩn';
	@override String get seekPreviewSizeLarge => 'Lớn';
	@override String get seekPreviewSizeStandardDesc => 'Kích thước suy ra từ trình phát và video';
	@override String get showFullscreenUpNextHint => 'Hiển thị tay cầm "Tiếp theo"';
	@override String get showFullscreenUpNextHintDesc => 'Hiển thị một tay cầm nhỏ ở cạnh phải trình phát để mở ngăn hàng đợi (nguồn / danh sách phát / xem sau). Khi tắt, không còn cách nào khác để mở.';
	@override String get basicSettings => 'Cài đặt cơ bản';
	@override String get personalizedSettings => 'Cài đặt cá nhân hóa';
	@override String get otherSettings => 'Cài đặt khác';
	@override String get searchConfig => 'Cấu hình tìm kiếm';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Cấu hình này quyết định cấu hình trước đó có được dùng lại khi phát video lần nữa hay không.';
	@override String get playControl => 'Điều khiển phát';
	@override String get playbackSpeedSettings => 'Phát và tốc độ';
	@override String get playbackBehaviorSettings => 'Hành vi phát';
	@override String get enhancementSettings => 'Rạp hát và nâng cao';
	@override String get fastForwardTime => 'Thời gian tua tới';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'Thời gian tua tới phải là số nguyên dương.';
	@override String get rewindTime => 'Thời gian tua lại';
	@override String get rewindTimeMustBeAPositiveInteger => 'Thời gian tua lại phải là số nguyên dương.';
	@override String get longPressPlaybackSpeed => 'Tốc độ phát khi nhấn giữ';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Tốc độ phát khi nhấn giữ phải là số dương.';
	@override String get defaultPlaybackSpeed => 'Tốc độ phát mặc định';
	@override String get rememberPlaybackSpeed => 'Ghi nhớ tốc độ phát';
	@override String get rememberPlaybackSpeedDesc => 'Khi bật, tốc độ bạn đặt trong trình phát sẽ được lưu làm mặc định và tự động áp dụng cho video mới.';
	@override String get repeat => 'Lặp lại';
	@override String get renderVerticalVideoInVerticalScreen => 'Hiển thị video dọc trên màn hình dọc';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Cấu hình này quyết định video có được hiển thị trên màn hình dọc khi phát toàn màn hình hay không.';
	@override String get rememberVolume => 'Ghi nhớ âm lượng';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Cấu hình này quyết định âm lượng có được giữ lại khi phát video lần nữa hay không.';
	@override String get rememberBrightness => 'Ghi nhớ độ sáng';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Cấu hình này quyết định độ sáng có được giữ lại khi phát video lần nữa hay không.';
	@override String get playControlArea => 'Vùng điều khiển phát';
	@override String get leftAndRightControlAreaWidth => 'Chiều rộng vùng điều khiển trái và phải';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Cấu hình này quyết định chiều rộng của các vùng điều khiển ở bên trái và bên phải trình phát.';
	@override String get proxyAddressCannotBeEmpty => 'Địa chỉ proxy không được để trống.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Định dạng địa chỉ proxy không hợp lệ. Vui lòng dùng định dạng IP:cổng hoặc tên miền:cổng.';
	@override String get proxyNormalWork => 'Proxy hoạt động bình thường.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Kiểm tra proxy thất bại, mã trạng thái: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Kiểm tra proxy thất bại, ngoại lệ: ${exception}';
	@override String get proxyConfig => 'Cấu hình proxy';
	@override String get thisIsHttpProxyAddress => 'Đây là địa chỉ proxy http';
	@override String get checkProxy => 'Kiểm tra proxy';
	@override String get proxyAddress => 'Địa chỉ proxy';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Vui lòng nhập URL của máy chủ proxy, ví dụ 127.0.0.1:8080';
	@override String get enableProxy => 'Bật proxy';
	@override String get left => 'Trái';
	@override String get middle => 'Giữa';
	@override String get right => 'Phải';
	@override String get playerSettings => 'Cài đặt trình phát';
	@override String get networkSettings => 'Cài đặt mạng';
	@override String get customizeYourPlaybackExperience => 'Tùy chỉnh trải nghiệm phát';
	@override String get chooseYourFavoriteAppAppearance => 'Chọn giao diện ứng dụng yêu thích';
	@override String get configureYourProxyServer => 'Cấu hình máy chủ proxy';
	@override String get settings => 'Cài đặt';
	@override String get themeSettings => 'Cài đặt giao diện';
	@override String get followSystem => 'Theo hệ thống';
	@override String get lightMode => 'Chế độ sáng';
	@override String get darkMode => 'Chế độ tối';
	@override String get presetTheme => 'Giao diện đặt trước';
	@override String get basicTheme => 'Giao diện cơ bản';
	@override String get needRestartToApply => 'Cần khởi động lại ứng dụng để áp dụng cài đặt';
	@override String get themeNeedRestartDescription => 'Cài đặt giao diện cần khởi động lại ứng dụng để áp dụng';
	@override String get about => 'Giới thiệu';
	@override String get diagnosticsAndFeedback => 'Chẩn đoán và phản hồi';
	@override String get currentVersion => 'Phiên bản hiện tại';
	@override String get latestVersion => 'Phiên bản mới nhất';
	@override String get checkForUpdates => 'Kiểm tra cập nhật';
	@override String get update => 'Cập nhật';
	@override String get newVersionAvailable => 'Có phiên bản mới';
	@override String get projectHome => 'Trang chủ dự án';
	@override String get release => 'Phát hành';
	@override String get issueReport => 'Báo cáo sự cố';
	@override String get openSourceLicense => 'Giấy phép mã nguồn mở';
	@override String get checkForUpdatesFailed => 'Kiểm tra cập nhật thất bại, vui lòng thử lại sau';
	@override String get autoCheckUpdate => 'Tự động kiểm tra cập nhật';
	@override String get updateContent => 'Nội dung cập nhật';
	@override String get releaseDate => 'Ngày phát hành';
	@override String get ignoreThisVersion => 'Bỏ qua phiên bản này';
	@override String get forceUpdateTip => 'Đây là bản cập nhật bắt buộc. Vui lòng cập nhật lên phiên bản mới nhất càng sớm càng tốt';
	@override String get viewChangelog => 'Xem nhật ký thay đổi';
	@override String get alreadyLatestVersion => 'Đã là phiên bản mới nhất';
	@override String get appSettings => 'Cài đặt ứng dụng';
	@override String get configureYourAppSettings => 'Cấu hình cài đặt ứng dụng';
	@override String get history => 'Lịch sử';
	@override String get autoRecordHistory => 'Tự động ghi lịch sử';
	@override String get autoRecordHistoryDesc => 'Tự động ghi lại video và hình ảnh bạn đã xem';
	@override String get autoDeleteHistory => 'Tự động dọn lịch sử';
	@override String get autoDeleteHistoryDesc => 'Tự động xóa lịch sử duyệt web cũ hơn số ngày lưu giữ khi khởi động (mặc định tắt)';
	@override String get autoDeleteHistoryDays => 'Số ngày lưu giữ';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Giữ ${num} ngày gần nhất';
	@override String get autoDeleteHistoryDaysInvalid => 'Vui lòng nhập số ngày hợp lệ (tối thiểu 1)';
	@override String get showUnprocessedMarkdownText => 'Hiển thị văn bản Markdown chưa xử lý';
	@override String get showUnprocessedMarkdownTextDesc => 'Hiển thị văn bản gốc của markdown';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Chế độ riêng tư';
	@override String get activeBackgroundPrivacyModeDesc => 'Chặn chụp màn hình và ghi màn hình, đồng thời ẩn màn hình khi chạy nền';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Ẩn màn hình khi ứng dụng chuyển sang chạy nền (nền tảng này không thể chặn chụp màn hình)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Chặn chụp màn hình và ghi màn hình';
	@override String get privacy => 'Quyền riêng tư';
	@override String get appLock => 'Khóa ứng dụng';
	@override String get appLockEnabled => 'Bật khóa ứng dụng';
	@override String get appLockEnabledDesc => 'Yêu cầu mã PIN hoặc sinh trắc học để mở ứng dụng; bản xem trước khi chạy nền sẽ tự động bị ẩn';
	@override String get appLockEnabledSummary => 'Bật · Bảo vệ bằng mã PIN';
	@override String get appLockDisabledSummary => 'Tắt';
	@override String get appLockTimeout => 'Khóa sau khi rời ứng dụng';
	@override String get appLockTimeoutDesc => 'Thời gian cho phép chạy nền trước khi yêu cầu xác thực';
	@override String get appLockAfterScreenOff => 'Khóa sau khi tắt màn hình';
	@override String get appLockAfterScreenOffDesc => 'Yêu cầu xác thực sau khi màn hình thiết bị bị khóa';
	@override String get appLockTimeoutDisabled => 'Đã tắt';
	@override String get appLockImmediately => 'Ngay lập tức';
	@override String appLockSeconds({required Object seconds}) => '${seconds} giây';
	@override String appLockMinutes({required Object minutes}) => '${minutes} phút';
	@override String get appLockUseBiometrics => 'Dùng sinh trắc học';
	@override String get appLockUseBiometricsDesc => 'Mở khóa bằng vân tay hoặc nhận diện khuôn mặt';
	@override String get appLockBiometricsUnavailable => 'Thiết bị này chưa đăng ký dữ liệu sinh trắc học nào';
	@override String get appLockSetPin => 'Đặt mã PIN';
	@override String get appLockEnterPin => 'Nhập mã PIN';
	@override String get appLockConfirmPin => 'Xác nhận mã PIN';
	@override String get appLockCurrentPin => 'Nhập mã PIN hiện tại';
	@override String get appLockNewPin => 'Nhập mã PIN mới';
	@override String get appLockPinRequirements => 'Mã PIN phải gồm 4–8 chữ số';
	@override String get appLockPinsDoNotMatch => 'Mã PIN không khớp';
	@override String get appLockInvalidPin => 'Mã PIN không đúng';
	@override String get appLockSetupFailed => 'Không thể lưu mã PIN một cách an toàn';
	@override String get appLockDisable => 'Nhập mã PIN để tắt khóa ứng dụng';
	@override String get appLockChangePin => 'Đổi mã PIN';
	@override String get appLockNow => 'Khóa ngay';
	@override String get appLockUnlock => 'Mở khóa';
	@override String get appLockLockedTitle => 'Đã khóa';
	@override String get appLockLockedDesc => 'Xác thực để tiếp tục';
	@override String get appLockAuthenticateReason => 'Xác thực để mở khóa';
	@override String get appLockEnableBiometricsReason => 'Xác thực để bật mở khóa bằng sinh trắc học';
	@override String get appLockBiometricFailed => 'Xác thực sinh trắc học chưa hoàn tất';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Quá nhiều lần thử. Thử lại sau ${seconds} giây';
	@override String get appLockCredentialUnavailableTitle => 'Không đọc được thông tin xác thực khóa ứng dụng';
	@override String get appLockCredentialUnavailableDesc => 'Kho lưu trữ bảo mật của hệ thống tạm thời không khả dụng, hoặc thông tin xác thực đã bị hỏng. Ứng dụng vẫn bị khóa. Hãy thử lại trước; nếu vẫn thất bại, bạn có thể đặt lại khóa ứng dụng, thao tác này sẽ tắt khóa và xóa mã PIN đã lưu.';
	@override String get appLockRetry => 'Thử lại';
	@override String get appLockReset => 'Đặt lại khóa ứng dụng';
	@override String get appLockResetAction => 'Đặt lại';
	@override String get appLockResetConfirmTitle => 'Đặt lại khóa ứng dụng?';
	@override String get appLockResetConfirmDesc => 'Thao tác này sẽ tắt khóa ứng dụng và xóa mã PIN cùng cài đặt sinh trắc học đã lưu. Sau đó bạn có thể thiết lập lại.';
	@override String get appLockRetrySucceeded => 'Đọc thông tin xác thực thành công. Hãy nhập mã PIN.';
	@override String get appLockRetryFailed => 'Vẫn không đọc được thông tin xác thực';
	@override String get forum => 'Diễn đàn';
	@override String get news => 'Tin tức';
	@override String get community => 'Cộng đồng';
	@override String get disableForumReplyQuote => 'Tắt trích dẫn trả lời diễn đàn';
	@override String get disableForumReplyQuoteDesc => 'Tắt việc mang theo thông tin tầng đã trả lời khi trả lời trên diễn đàn';
	@override String get theaterMode => 'Chế độ rạp hát';
	@override String get theaterModeDesc => 'Sau khi bật, nền trình phát sẽ được đặt thành phiên bản làm mờ của ảnh bìa video';
	@override String get appLinks => 'Liên kết ứng dụng';
	@override String get defaultBrowser => 'Trình duyệt mặc định';
	@override String get defaultBrowserDesc => 'Vui lòng mở mục cấu hình liên kết mặc định trong cài đặt hệ thống và thêm liên kết trang web iwara.tv';
	@override String get themeMode => 'Chế độ giao diện';
	@override String get themeModeDesc => 'Cấu hình này quyết định chế độ giao diện của ứng dụng';
	@override String get glassEffect => 'Vật liệu giao diện';
	@override String get glassEffectDesc => 'Chọn vật liệu dùng xuyên suốt ứng dụng — thanh tiêu đề, menu, nút hộp thoại và thanh điều hướng dưới';
	@override String get liquidGlassEffect => 'Kính lỏng';
	@override String get liquidGlassEffectDesc => 'Làm mờ và khúc xạ thật. Trông đẹp nhất, nhưng có thể rớt khung hình và tốn thêm chút pin trên thiết bị yếu';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Bề mặt Material 3 tiêu chuẩn — đục, không mờ, không đổ bóng. Hiệu năng và pin tốt nhất';
	@override String get glassEffectIntroTitle => 'Chọn vật liệu giao diện';
	@override String get glassEffectIntroContent => 'Thanh tiêu đề, thanh tab và menu dùng kính lỏng — làm mờ và khúc xạ thật. Nếu cảm thấy chậm trên thiết bị của bạn, hoặc muốn đơn giản hơn, hãy chuyển sang Material ngay (bề mặt đục, không mờ, không đổ bóng).';
	@override String get glassEffectIntroHint => 'Bạn có thể thay đổi bất cứ lúc nào trong Cài đặt → Giao diện → Vật liệu giao diện.';
	@override String get glassEffectIntroDone => 'Giữ nguyên';
	@override String get dynamicColor => 'Màu động';
	@override String get dynamicColorDesc => 'Cấu hình này quyết định ứng dụng có dùng màu động hay không';
	@override String get useDynamicColor => 'Dùng màu động';
	@override String get useDynamicColorDesc => 'Cấu hình này quyết định ứng dụng có dùng màu động hay không';
	@override String get presetColors => 'Màu đặt trước';
	@override String get customColors => 'Màu tùy chỉnh';
	@override String get customColorsDisabledByDynamicColor => 'Màu động đang bật nên không thể dùng màu đặt trước hoặc tùy chỉnh. Hãy tắt màu động trước.';
	@override String get pickColor => 'Chọn màu';
	@override String get cancel => 'Hủy';
	@override String get confirm => 'Xác nhận';
	@override String get noCustomColors => 'Không có màu tùy chỉnh';
	@override String get recordAndRestorePlaybackProgress => 'Ghi và khôi phục tiến trình phát';
	@override String get autoPlayVideoOnFirstEnter => 'Tự động phát video khi mở lần đầu';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Cài đặt này quyết định video có tự động phát khi lần đầu mở trang video hay không.';
	@override String get autoEnterFullscreen => 'Tự động vào toàn màn hình';
	@override String get autoEnterFullscreenDesc => 'Khi trình phát nên tự vào toàn màn hình. Video riêng tư, đã xóa và video bên ngoài luôn được giữ nguyên, tương tự với chế độ hình trong hình.';
	@override String get autoEnterFullscreenOff => 'Tắt';
	@override String get autoEnterFullscreenOffDesc => 'Không bao giờ tự vào toàn màn hình';
	@override String get autoEnterFullscreenOnPlaybackStart => 'Khi bắt đầu phát';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Vào toàn màn hình ngay khi quá trình phát thực sự bắt đầu';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'Khi mở video';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Vào toàn màn hình ngay khi trang video mở ra, không cần chờ phát video';
	@override String get autoEnterFullscreenKind => 'Kiểu toàn màn hình';
	@override String get autoEnterFullscreenKindDesc => 'Kiểu toàn màn hình sẽ tự động vào. Chỉ trên máy tính để bàn.';
	@override String get autoEnterFullscreenKindSystem => 'Toàn màn hình hệ thống';
	@override String get autoEnterFullscreenKindSystemDesc => 'Để trình quản lý cửa sổ đưa cửa sổ vào chế độ toàn màn hình';
	@override String get autoEnterFullscreenKindApp => 'Toàn màn hình ứng dụng';
	@override String get autoEnterFullscreenKindAppDesc => 'Giữ nguyên cửa sổ và biến toàn bộ ứng dụng thành trình phát';
	@override String get signature => 'Chữ ký';
	@override String get enableSignature => 'Bật chữ ký';
	@override String get enableSignatureDesc => 'Cấu hình này quyết định ứng dụng có thêm chữ ký khi trả lời hay không';
	@override String get enterSignature => 'Nhập chữ ký';
	@override String get editSignature => 'Chỉnh sửa chữ ký';
	@override String get signatureContent => 'Nội dung chữ ký';
	@override String get signaturePreview => 'Xem trước';
	@override String get signatureSampleBody => 'Nội dung của bạn ở đây';
	@override String get signatureRegenerate => 'Tạo lại';
	@override String get signatureNotSet => 'Chưa đặt';
	@override String get signatureRuleHint => 'Chữ ký được thêm sau nội dung, ngăn cách bằng một đường kẻ ngang. Ứng dụng tự thêm đường kẻ — bạn chỉ cần viết dòng bên dưới.';
	@override String get signatureInsertVariable => 'Chèn biến';
	@override String get varDate => 'Ngày';
	@override String get varTime => 'Giờ';
	@override String get varDatetime => 'Ngày giờ';
	@override String get varWeekday => 'Thứ';
	@override String get varApp => 'Tên ứng dụng';
	@override String get varVersion => 'Phiên bản';
	@override String get varPlatform => 'Nền tảng';
	@override String get varTitle => 'Thứ bạn đang xem';
	@override String get varAuthor => 'Tác giả của nó';
	@override String get varPick => 'Câu ngẫu nhiên';
	@override String get signatureSources => 'Nguồn dữ liệu';
	@override String get signatureAutoTranslate => 'Dịch sang ngôn ngữ của tôi';
	@override String get signatureAutoTranslateDesc => 'Các nguồn như Hitokoto hiện chỉ có tiếng Trung. Câu lấy về sẽ được dịch ngay trước khi gửi đi.';
	@override String get signatureWizardTitle => 'Thêm một nguồn dữ liệu';
	@override String get signatureWizardUrlTitle => 'Địa chỉ điểm cuối';
	@override String get signatureWizardUrlHint => 'Nhập một địa chỉ trả về một dòng chữ. Nút bên dưới sẽ gọi thật một lần để bạn thấy nó trả về gì.';
	@override String get signatureWizardFetch => 'Gọi thử';
	@override String get signatureWizardSkipTest => 'Bỏ qua, chỉ đổi tên';
	@override String get signatureWizardPickTitle => 'Chọn phần bạn muốn';
	@override String get signatureWizardPickHint => 'Đây là thứ điểm cuối đó trả về. Chạm vào dòng bạn muốn chữ ký hiển thị.';
	@override String get signatureWizardPickPlainHint => 'Điểm cuối này trả về văn bản thuần, nên toàn bộ sẽ được hiển thị.';
	@override String get signatureWizardWholeBody => 'Toàn bộ phản hồi';
	@override String get signatureWizardNameTitle => 'Đặt cho nó một cái tên';
	@override String get signatureWizardNameHint => 'Tên chỉ để bạn dễ nhận ra. Thứ chữ ký dùng để trỏ tới là tên tham chiếu bên dưới.';
	@override String get signatureWizardNext => 'Tiếp';
	@override String get signatureWizardDone => 'Xong';
	@override String get signatureWizardStripHtml => 'Bỏ thẻ HTML';
	@override String get signatureWizardAdvanced => 'Nâng cao: trích bằng mẫu';
	@override String get signatureWizardExtractHint => 'Biểu thức chính quy; lấy nhóm bắt đầu tiên';
	@override String get signatureWizardExtractMissed => 'Mẫu này không khớp, nên giữ nguyên văn bản';
	@override String get signatureWizardChooseTitle => 'Chọn một nguồn';
	@override String get signatureWizardChooseHint => 'Chạm vào một nguồn có sẵn là xong. Hoặc trỏ tới endpoint của riêng bạn.';
	@override String get signatureWizardCustomSource => 'Dùng endpoint của tôi';
	@override String get signatureWizardWithOrigin => 'Hiện cả xuất xứ';
	@override String get signatureWizardRandomItem => 'Mỗi lần lấy một câu khác';
	@override String get signatureWizardSuffixTitle => 'Nối thêm một trường nữa';
	@override String get signatureWizardSuffixNone => 'Không nối';
	@override String get signatureOptFlavor => 'Nội dung';
	@override String get signatureOptFlavorAny => 'Không giới hạn';
	@override String get signatureOptFlavorOtaku => 'Anime, manga và game';
	@override String get signatureOptFlavorLiterary => 'Văn học và thơ';
	@override String get signatureOptFlavorMeme => 'Văn hoá mạng';
	@override String get signatureOptLength => 'Độ dài';
	@override String get signatureOptLengthAny => 'Không giới hạn';
	@override String get signatureOptLengthShort => 'Chỉ câu ngắn';
	@override String get signatureRestoreDefault => 'Khôi phục mặc định';
	@override String get signatureSourceHitokoto => 'Hitokoto (câu ngẫu nhiên)';
	@override String get signatureAiSourceName => 'Câu chữ tạo bởi AI';
	@override String get signatureEditTextHint => 'Đây là chữ ký đã có sẵn trong bình luận này — câu trích và ngày giờ giờ chỉ là chữ thường, sửa tuỳ ý. Xoá trống là bỏ chữ ký.';
	@override String signatureResolving({required Object name}) => 'Đang tạo ${name}…';
	@override String get signaturePendingValue => '(tạo khi gửi)';
	@override String get signatureAiHint => 'Một câu do AI viết ngay lúc đó, mỗi bình luận một câu mới. Dùng nhà cung cấp AI bạn đã thiết lập.';
	@override String get signatureAiUnavailable => 'Chưa thiết lập nhà cung cấp AI nên nguồn này không hiện trong bảng biến.';
	@override String get signaturePromptTitle => 'Prompt';
	@override String get signaturePromptHint => 'Đây là thứ được gửi cho mô hình. Viết lại tuỳ ý: giọng điệu, độ dài, chủ đề. Các quy tắc có sẵn trong đó nên giữ lại.';
	@override String get signaturePromptReset => 'Khôi phục mặc định';
	@override String get signaturePromptTry => 'Thử';
	@override String get signaturePromptSample => 'Kết quả';
	@override String get signaturePromptLanguageHint => 'sẽ được thay bằng ngôn ngữ giao diện. Bỏ nó đi thì câu sẽ theo ngôn ngữ của prompt.';
	@override String get signaturePromptEdited => 'đã sửa';
	@override String get signatureVariablesGroup => 'Biến có sẵn';
	@override String get signatureNeedsNetwork => 'Cần mạng';
	@override String get signatureBuiltinSource => 'Có sẵn';
	@override String get signatureSourceIdReserved => 'Tên này đã thuộc về một biến có sẵn';
	@override String get signatureSourcesTitle => 'Nguồn dữ liệu tự thêm';
	@override String get signatureSourcesHint => 'Trỏ tới một địa chỉ trả về một dòng chữ là bạn có thể đưa nó vào chữ ký.';
	@override String get signatureSourcesEmpty => 'Chưa có nguồn dữ liệu nào';
	@override String get signatureAddSource => 'Thêm';
	@override String get signatureEditSource => 'Sửa nguồn dữ liệu';
	@override String get signatureSourceName => 'Tên';
	@override String get signatureSourceId => 'Tên tham chiếu';
	@override String get signatureSourceIdHint => 'Tên mà chữ ký dùng để gọi nguồn này';
	@override String get signatureSourceUrl => 'Địa chỉ điểm cuối';
	@override String get signatureSourcePath => 'Đường dẫn giá trị';
	@override String get signatureSourcePathHint => 'Để trống nếu toàn bộ phản hồi chính là dòng chữ đó. Dùng data.text để lấy trường đó từ phản hồi JSON.';
	@override String get signatureSourceTest => 'Kiểm tra';
	@override String get signatureSourceTestOk => 'Lấy được rồi';
	@override String get signatureSourceTestFailed => 'Không có gì trả về';
	@override String get signatureSourceIdInvalid => 'Tên tham chiếu chỉ dùng chữ thường, chữ số và gạch dưới';
	@override String get signatureSourceIdDuplicate => 'Tên tham chiếu này đã có người dùng';
	@override String get signatureSourceUrlRequired => 'Cần nhập địa chỉ điểm cuối';
	@override String get exportConfig => 'Xuất cấu hình ứng dụng';
	@override String get exportConfigDesc => 'Xuất cài đặt và lịch sử (lịch sử duyệt web, tiến trình phát, yêu thích, v.v.) ra tệp để sao lưu hoặc chuyển sang thiết bị khác. Không bao gồm tác vụ tải xuống.';
	@override String get importConfig => 'Nhập cấu hình ứng dụng';
	@override String get importConfigDesc => 'Nhập cấu hình ứng dụng từ tệp';
	@override String get exportConfigSuccess => 'Đã xuất cấu hình thành công!';
	@override String get exportConfigFailed => 'Xuất cấu hình thất bại';
	@override String get importConfigSuccess => 'Đã nhập cấu hình thành công!';
	@override String get importConfigFailed => 'Nhập cấu hình thất bại';
	@override String get exportIncludeSensitive => 'Bao gồm thông tin nhạy cảm';
	@override String get exportIncludeSensitiveDesc => 'Bao gồm khóa API, token phiên và địa chỉ proxy. Chỉ bật khi sao lưu vào thiết bị của chính bạn.';
	@override String get importConfigOverwriteWarning => 'Nhập sẽ ghi đè cài đặt và lịch sử hiện tại (lịch sử duyệt web, tiến trình phát, yêu thích, v.v.). Tiếp tục?';
	@override String get importConfigRestartTitle => 'Nhập thành công';
	@override String get importConfigRestartContent => 'Cấu hình của bạn đã được nhập. Vui lòng đóng hoàn toàn và mở lại ứng dụng để mọi thay đổi có hiệu lực.';
	@override String get historyUpdateLogs => 'Nhật ký cập nhật lịch sử';
	@override String get noUpdateLogs => 'Không có nhật ký cập nhật';
	@override String get versionLabel => 'Phiên bản: {version}';
	@override String get releaseDateLabel => 'Ngày phát hành: {date}';
	@override String get noChanges => 'Không có nội dung cập nhật';
	@override String get interaction => 'Tương tác';
	@override String get enableVibration => 'Bật rung';
	@override String get enableVibrationDesc => 'Bật phản hồi rung khi tương tác với ứng dụng';
	@override String get defaultKeepVideoToolbarVisible => 'Giữ thanh công cụ video luôn hiển thị';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Cài đặt này quyết định thanh công cụ video có luôn hiển thị khi lần đầu mở trang video hay không.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Thiết bị di động bật chế độ rạp hát có thể gây vấn đề về hiệu năng. Bạn có thể chọn bật.';
	@override String get fullscreenOrientation => 'Hướng màn hình dọc sau khi vào toàn màn hình';
	@override String get fullscreenOrientationDesc => 'Cài đặt này quyết định hướng màn hình mặc định khi vào toàn màn hình (chỉ trên di động)';
	@override String get fullscreenOrientationLeftLandscape => 'Ngang trái';
	@override String get fullscreenOrientationRightLandscape => 'Ngang phải';
	@override String get screenFit => 'Kích thước màn hình';
	@override String get screenFitDesc => 'Chọn cách video lấp đầy vùng trình phát.';
	@override String get rememberScreenFit => 'Ghi nhớ kích thước màn hình';
	@override String get rememberScreenFitDesc => 'Áp dụng kích thước đã chọn cho các video mở sau này.';
	@override String get screenFitFit => 'Vừa khung';
	@override String get screenFitFitDesc => 'Hiển thị toàn bộ khung hình mà giữ nguyên tỉ lệ';
	@override String get screenFitStretch => 'Kéo giãn';
	@override String get screenFitStretchDesc => 'Lấp đầy vùng trình phát; hình ảnh có thể bị méo';
	@override String get screenFitCover => 'Lấp đầy';
	@override String get screenFitCoverDesc => 'Lấp đầy vùng trình phát mà giữ nguyên tỉ lệ khung hình; phần tràn sẽ bị cắt';
	@override String get screenFitRatioDesc => 'Buộc dùng tỉ lệ khung hình này; hình ảnh có thể bị méo';
	@override String get jumpLink => 'Liên kết nhảy';
	@override String get language => 'Ngôn ngữ';
	@override String get languageNativeName => 'Tiếng Việt';
	@override String get followSystemLanguage => 'Theo hệ thống';
	@override String get languageChangedMessage => 'Đã đổi ngôn ngữ. Một số tính năng cần khởi động lại ứng dụng để có hiệu lực.';
	@override String get languageChanged => 'Đã thay đổi cài đặt ngôn ngữ, vui lòng khởi động lại ứng dụng để có hiệu lực.';
	@override late final _TranslationsSettingsKeybindingVi keybinding = _TranslationsSettingsKeybindingVi._(_root);
	@override String get gestureControl => 'Điều khiển bằng cử chỉ';
	@override String get leftDoubleTapRewind => 'Nhấn đúp bên trái để tua lại';
	@override String get rightDoubleTapFastForward => 'Nhấn đúp bên phải để tua nhanh';
	@override String get doubleTapPause => 'Nhấn đúp để tạm dừng';
	@override String get rightVerticalSwipeVolume => 'Vuốt dọc bên phải để chỉnh âm lượng (có hiệu lực khi vào trang mới)';
	@override String get leftVerticalSwipeBrightness => 'Vuốt dọc bên trái để chỉnh độ sáng (có hiệu lực khi vào trang mới)';
	@override String get longPressFastForward => 'Nhấn giữ để tua nhanh';
	@override String get enableMouseHoverShowToolbar => 'Hiện thanh công cụ khi di chuột';
	@override String get enableMouseHoverShowToolbarInfo => 'Khi bật, thanh công cụ video sẽ hiện khi con trỏ chuột ở trên trình phát. Thanh này sẽ tự động ẩn sau 3 giây không thao tác.';
	@override String get enableHorizontalDragSeek => 'Vuốt ngang để tua';
	@override String get enableVideoGestureZoom => 'Chụm để thu phóng khung hình video';
	@override String get enableVideoGestureZoomInfo => 'Dùng hai ngón tay chụm (hoặc Ctrl + con lăn chuột trên máy tính) để thu phóng hình video, sau đó kéo để di chuyển.';
	@override String get showCenterPlayPauseButton => 'Nút phát/tạm dừng ở giữa';
	@override String get showCenterPlayPauseButtonDesc => 'Hiển thị nút phát/tạm dừng lớn ở giữa trình phát.';
	@override String get audioVideoConfig => 'Cấu hình âm thanh và video';
	@override String get expandBuffer => 'Mở rộng bộ đệm';
	@override String get expandBufferInfo => 'Khi bật, kích thước bộ đệm tăng lên, thời gian tải lâu hơn nhưng phát mượt hơn';
	@override String get videoSyncMode => 'Chế độ đồng bộ video';
	@override String get videoSyncModeSubtitle => 'Chiến lược đồng bộ âm thanh - video';
	@override String get hardwareDecodingMode => 'Chế độ giải mã phần cứng';
	@override String get hardwareDecodingModeSubtitle => 'Cài đặt giải mã phần cứng';
	@override String get enableHardwareAcceleration => 'Bật tăng tốc phần cứng';
	@override String get enableHardwareAccelerationInfo => 'Bật tăng tốc phần cứng có thể cải thiện hiệu năng giải mã, nhưng một số thiết bị có thể không tương thích';
	@override String get useOpenSLESAudioOutput => 'Dùng đầu ra âm thanh OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'Dùng đầu ra âm thanh độ trễ thấp, có thể cải thiện hiệu năng âm thanh';
	@override String get videoSyncAudio => 'Đồng bộ âm thanh';
	@override String get videoSyncDisplayResample => 'Lấy mẫu lại';
	@override String get videoSyncDisplayResampleVdrop => 'Lấy mẫu lại (bỏ khung hình)';
	@override String get videoSyncDisplayResampleDesync => 'Lấy mẫu lại (mất đồng bộ)';
	@override String get videoSyncDisplayTempo => 'Nhịp độ';
	@override String get videoSyncDisplayVdrop => 'Bỏ khung hình video';
	@override String get videoSyncDisplayAdrop => 'Bỏ khung hình âm thanh';
	@override String get videoSyncDisplayDesync => 'Hiển thị mất đồng bộ';
	@override String get videoSyncDesync => 'Mất đồng bộ';
	@override late final _TranslationsSettingsForumSettingsVi forumSettings = _TranslationsSettingsForumSettingsVi._(_root);
	@override late final _TranslationsSettingsGallerySettingsVi gallerySettings = _TranslationsSettingsGallerySettingsVi._(_root);
	@override late final _TranslationsSettingsBlockSettingsVi blockSettings = _TranslationsSettingsBlockSettingsVi._(_root);
	@override late final _TranslationsSettingsChatSettingsVi chatSettings = _TranslationsSettingsChatSettingsVi._(_root);
	@override String get hardwareDecodingAuto => 'Tự động';
	@override String get hardwareDecodingAutoCopy => 'Tự động sao chép';
	@override String get hardwareDecodingAutoSafe => 'Tự động an toàn';
	@override String get hardwareDecodingNo => 'Đã tắt';
	@override String get hardwareDecodingYes => 'Buộc bật';
	@override String get cdnDistributionStrategy => 'Chiến lược phân phối nội dung';
	@override String get cdnDistributionStrategyDesc => 'Chọn chiến lược phân phối máy chủ nguồn video để tối ưu tốc độ tải';
	@override String get cdnDistributionStrategyLabel => 'Chiến lược phân phối';
	@override String get cdnDistributionStrategyNoChange => 'Không thay đổi (dùng máy chủ gốc)';
	@override String get cdnDistributionStrategyAuto => 'Tự động chọn (máy chủ nhanh nhất)';
	@override String get cdnDistributionStrategySpecial => 'Chỉ định máy chủ';
	@override String get cdnSpecialServer => 'Chỉ định máy chủ';
	@override String get cdnRefreshServerListHint => 'Vui lòng nhấn nút bên dưới để làm mới danh sách máy chủ';
	@override String get cdnRefreshButton => 'Làm mới';
	@override String get cdnFastRingServers => 'Máy chủ vòng nhanh';
	@override String get cdnRefreshServerListTooltip => 'Làm mới danh sách máy chủ';
	@override String get cdnSpeedTestButton => 'Kiểm tra tốc độ';
	@override String cdnSpeedTestingButton({required Object count}) => 'Đang kiểm tra (${count})';
	@override String get cdnNoServerDataHint => 'Không có dữ liệu máy chủ, vui lòng nhấn nút làm mới';
	@override String get cdnTestingStatus => 'Đang kiểm tra';
	@override String get cdnUnreachableStatus => 'Không thể kết nối';
	@override String get cdnNotTestedStatus => 'Chưa kiểm tra';
	@override late final _TranslationsSettingsDownloadSettingsVi downloadSettings = _TranslationsSettingsDownloadSettingsVi._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsVi extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Thẻ yêu thích';
	@override String get emptyIwara => 'Chưa có thẻ Iwara yêu thích';
	@override String get emptyOreno3d => 'Chưa có mục yêu thích';
	@override String get addIwaraTag => 'Thêm thẻ Iwara';
	@override String get quickPickHint => 'Các mục đã yêu thích sẽ xuất hiện dưới dạng gợi ý nhanh khi tìm kiếm.';
	@override String get pickerTitle => 'Chọn Oreno3D';
	@override String get searchHint => 'Tìm theo tên hoặc tên gốc';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n,
		one: '${n} tác phẩm',
		other: '${n} tác phẩm',
	);
	@override String get browseEntry => 'Duyệt theo nguồn gốc / nhân vật / thẻ';
	@override String get favoritesSection => 'Yêu thích';
	@override String get addFavorite => 'Thêm';
	@override String get iwaraTitle => 'Thẻ Iwara yêu thích';
	@override String get oreno3dTitle => 'Thẻ Oreno3D yêu thích';
	@override String get changeTag => 'Đổi thẻ';
	@override String get switchToText => 'Tìm kiếm văn bản';
}

// Path: oreno3d
class _TranslationsOreno3dVi extends TranslationsOreno3dEn {
	_TranslationsOreno3dVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Thẻ';
	@override String get characters => 'Nhân vật';
	@override String get origin => 'Nguồn gốc';
	@override String get thirdPartyTagsExplanation => 'Thông tin **thẻ**, **nhân vật** và **nguồn gốc** hiển thị ở đây được cung cấp bởi trang web bên thứ ba **Oreno3D** chỉ để tham khảo.\n\nVì nguồn thông tin này chỉ có tiếng Nhật, hiện tại nó chưa có bản địa hóa.\n\nNếu bạn muốn đóng góp cho nỗ lực bản địa hóa, hãy truy cập kho lưu trữ để giúp cải thiện!';
	@override late final _TranslationsOreno3dSortTypesVi sortTypes = _TranslationsOreno3dSortTypesVi._(_root);
	@override late final _TranslationsOreno3dErrorsVi errors = _TranslationsOreno3dErrorsVi._(_root);
	@override late final _TranslationsOreno3dLoadingVi loading = _TranslationsOreno3dLoadingVi._(_root);
	@override late final _TranslationsOreno3dMessagesVi messages = _TranslationsOreno3dMessagesVi._(_root);
}

// Path: signIn
class _TranslationsSignInVi extends TranslationsSignInEn {
	_TranslationsSignInVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Vui lòng đăng nhập trước';
	@override String get alreadySignedInToday => 'Hôm nay bạn đã điểm danh rồi!';
	@override String get youDidNotStickToTheSignIn => 'Bạn đã không duy trì việc điểm danh.';
	@override String get signInSuccess => 'Điểm danh thành công!';
	@override String get signInFailed => 'Điểm danh thất bại, vui lòng thử lại sau';
	@override String get consecutiveSignIns => 'Điểm danh liên tiếp';
	@override String get failureReason => 'Lý do thất bại';
	@override String get selectDateRange => 'Chọn khoảng ngày';
	@override String get startDate => 'Ngày bắt đầu';
	@override String get endDate => 'Ngày kết thúc';
	@override String get invalidDate => 'Ngày không hợp lệ';
	@override String get invalidDateRange => 'Khoảng ngày không hợp lệ';
	@override String get errorFormatText => 'Lỗi định dạng ngày';
	@override String get errorInvalidText => 'Khoảng ngày không hợp lệ';
	@override String get errorInvalidRangeText => 'Khoảng ngày không hợp lệ';
	@override String get dateRangeCantBeMoreThanOneYear => 'Khoảng ngày không được vượt quá một năm';
	@override String get signIn => 'Điểm danh';
	@override String get signInRecord => 'Lịch sử điểm danh';
	@override String get totalSignIns => 'Tổng số lần điểm danh';
	@override String get pleaseSelectSignInStatus => 'Vui lòng chọn trạng thái điểm danh';
}

// Path: subscriptions
class _TranslationsSubscriptionsVi extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Vui lòng đăng nhập trước để xem các đăng ký của bạn.';
	@override String get selectUser => 'Chọn người dùng';
	@override String get noSubscribedUsers => 'Không có người dùng đã đăng ký';
	@override String get showAllSubscribedUsersContent => 'Hiển thị nội dung của tất cả người dùng đã đăng ký';
}

// Path: videoDetail
class _TranslationsVideoDetailVi extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'Chế độ PiP';
	@override String resumeFromLastPosition({required Object position}) => 'Tiếp tục từ vị trí lần trước: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Đã tiếp tục từ ${position}';
	@override String get restartFromBeginning => 'Bắt đầu lại';
	@override String get dismissResumeTip => 'Bỏ qua';
	@override late final _TranslationsVideoDetailLocalInfoVi localInfo = _TranslationsVideoDetailLocalInfoVi._(_root);
	@override String get videoIdIsEmpty => 'ID video trống';
	@override String get videoInfoIsEmpty => 'Thông tin video trống';
	@override String get thisIsAPrivateVideo => 'Đây là video riêng tư';
	@override String get getVideoInfoFailed => 'Lấy thông tin video thất bại, vui lòng thử lại sau';
	@override String get noVideoSourceFound => 'Không tìm thấy nguồn video';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Đã sao chép thẻ "${tagId}" vào bộ nhớ tạm';
	@override String get errorLoadingVideo => 'Lỗi khi tải video';
	@override String get play => 'Phát';
	@override String get pause => 'Tạm dừng';
	@override String get exitAppFullscreen => 'Thoát toàn màn hình ứng dụng';
	@override String get enterAppFullscreen => 'Vào toàn màn hình ứng dụng';
	@override String get exitSystemFullscreen => 'Thoát toàn màn hình hệ thống';
	@override String get enterSystemFullscreen => 'Vào toàn màn hình hệ thống';
	@override String get seekTo => 'Tua tới';
	@override String get switchResolution => 'Chuyển độ phân giải';
	@override String get switchPlaybackSpeed => 'Chuyển tốc độ phát';
	@override String rewindSeconds({required Object num}) => 'Tua lại ${num} giây';
	@override String fastForwardSeconds({required Object num}) => 'Tua tới ${num} giây';
	@override String playbackSpeedIng({required Object rate}) => 'Đang phát với tốc độ ${rate}x';
	@override String get brightness => 'Độ sáng';
	@override String get brightnessLowest => 'Độ sáng ở mức thấp nhất';
	@override String get volume => 'Âm lượng';
	@override String get volumeMuted => 'Âm lượng đã tắt tiếng';
	@override String get restoreDefaultZoom => 'Khôi phục';
	@override late final _TranslationsVideoDetailGestureGuideVi gestureGuide = _TranslationsVideoDetailGestureGuideVi._(_root);
	@override String get home => 'Trang chủ';
	@override String get videoPlayer => 'Trình phát video';
	@override String get videoPlayerInfo => 'Thông tin trình phát video';
	@override String get moreSettings => 'Cài đặt thêm';
	@override String get videoPlayerFeatureInfo => 'Thông tin tính năng trình phát video';
	@override String get autoRewind => 'Tự động tua lại';
	@override String get rewindAndFastForward => 'Tua lại và tua tới';
	@override String get volumeAndBrightness => 'Âm lượng và độ sáng';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Nhấn đúp vùng giữa để tạm dừng hoặc phát';
	@override String get showVerticalVideoInFullScreen => 'Hiển thị video dọc ở chế độ toàn màn hình';
	@override String get keepLastVolumeAndBrightness => 'Giữ âm lượng và độ sáng lần trước';
	@override String get setProxy => 'Đặt proxy';
	@override String get moreFeaturesToBeDiscovered => 'Còn nhiều tính năng đang chờ khám phá...';
	@override String get videoPlayerSettings => 'Cài đặt trình phát video';
	@override String commentCount({required Object num}) => '${num} bình luận';
	@override String get writeYourCommentHere => 'Viết bình luận của bạn ở đây...';
	@override String get authorOtherVideos => 'Video khác của tác giả';
	@override String get relatedVideos => 'Video liên quan';
	@override String get privateVideo => 'Đây là video riêng tư';
	@override String get externalVideo => 'Đây là video bên ngoài';
	@override String get openInBrowser => 'Mở trong trình duyệt';
	@override String get resourceDeleted => 'Video này có vẻ đã bị xóa :/';
	@override String get noDownloadUrl => 'Không có URL tải xuống';
	@override String get startDownloading => 'Bắt đầu tải xuống';
	@override String get downloadFailed => 'Tải xuống thất bại, vui lòng thử lại sau';
	@override String get downloadSuccess => 'Tải xuống thành công';
	@override String get download => 'Tải xuống';
	@override String get downloadManager => 'Trình quản lý tải xuống';
	@override String get resourceNotFound => 'Không tìm thấy tài nguyên';
	@override String get videoLoadError => 'Lỗi tải video';
	@override String get authorNoOtherVideos => 'Tác giả không có video khác';
	@override String get noRelatedVideos => 'Không có video liên quan';
	@override late final _TranslationsVideoDetailPlayerVi player = _TranslationsVideoDetailPlayerVi._(_root);
	@override late final _TranslationsVideoDetailSkeletonVi skeleton = _TranslationsVideoDetailSkeletonVi._(_root);
	@override late final _TranslationsVideoDetailCastVi cast = _TranslationsVideoDetailCastVi._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsVi likeAvatars = _TranslationsVideoDetailLikeAvatarsVi._(_root);
}

// Path: share
class _TranslationsShareVi extends TranslationsShareEn {
	_TranslationsShareVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Chia sẻ danh sách phát';
	@override String get wowDidYouSeeThis => 'Chà, bạn thấy cái này chưa?';
	@override String get nameIs => 'Tên là';
	@override String get clickLinkToView => 'Nhấn liên kết để xem';
	@override String get iReallyLikeThis => 'Tôi rất thích cái này';
	@override String get shareFailed => 'Chia sẻ thất bại, vui lòng thử lại sau';
	@override String get share => 'Chia sẻ';
	@override String get shareAsImage => 'Chia sẻ dưới dạng hình ảnh';
	@override String get shareAsText => 'Chia sẻ dưới dạng văn bản';
	@override String get shareAsImageDesc => 'Chia sẻ ảnh bìa video dưới dạng hình ảnh';
	@override String get shareAsTextDesc => 'Chia sẻ thông tin chi tiết video dưới dạng văn bản';
	@override String get shareAsImageFailed => 'Chia sẻ ảnh bìa video dưới dạng hình ảnh thất bại, vui lòng thử lại sau';
	@override String get shareAsTextFailed => 'Chia sẻ thông tin chi tiết video dưới dạng văn bản thất bại, vui lòng thử lại sau';
	@override String get shareVideo => 'Chia sẻ video';
	@override String get authorIs => 'Tác giả là';
	@override String get shareGallery => 'Chia sẻ thư viện';
	@override String get galleryTitleIs => 'Tiêu đề thư viện là';
	@override String get galleryAuthorIs => 'Tác giả thư viện là';
	@override String get shareUser => 'Chia sẻ người dùng';
	@override String get userNameIs => 'Tên người dùng là';
	@override String get userAuthorIs => 'Tác giả người dùng là';
	@override String get comments => 'Bình luận';
	@override String get shareThread => 'Chia sẻ chủ đề';
	@override String get views => 'Lượt xem';
	@override String get sharePost => 'Chia sẻ bài viết';
	@override String get postTitleIs => 'Tiêu đề bài viết là';
	@override String get postAuthorIs => 'Tác giả bài viết là';
}

// Path: markdown
class _TranslationsMarkdownVi extends TranslationsMarkdownEn {
	_TranslationsMarkdownVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Cú pháp Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'Cú pháp Markdown đặc biệt của Iwara';
	@override String get internalLink => 'Liên kết nội bộ';
	@override String get supportAutoConvertLinkBelow => 'Hỗ trợ tự động chuyển đổi liên kết dưới đây:';
	@override String get convertLinkExample => '🎬 Liên kết video\n🖼️ Liên kết ảnh\n👤 Liên kết người dùng\n📌 Liên kết diễn đàn\n🎵 Liên kết danh sách phát\n💬 Liên kết chủ đề';
	@override String get mentionUser => 'Nhắc tên người dùng';
	@override String get mentionUserDescription => 'Nhập @ theo sau là tên người dùng, sẽ tự động chuyển thành liên kết người dùng';
	@override String get markdownBasicSyntax => 'Cú pháp Markdown cơ bản';
	@override String get paragraphAndLineBreak => 'Đoạn văn và ngắt dòng';
	@override String get paragraphAndLineBreakDescription => 'Các đoạn văn được phân tách bằng một dòng, và hai dấu cách ở cuối dòng sẽ được chuyển thành ngắt dòng';
	@override String get paragraphAndLineBreakSyntax => 'Đây là đoạn văn thứ nhất\n\nĐây là đoạn văn thứ hai\nDòng này kết thúc bằng hai dấu cách  \nsẽ được chuyển thành ngắt dòng';
	@override String get textStyle => 'Kiểu chữ';
	@override String get textStyleDescription => 'Dùng ký hiệu đặc biệt bao quanh văn bản để đổi kiểu';
	@override String get textStyleSyntax => '**Chữ đậm**\n*Chữ nghiêng*\n~~Chữ gạch ngang~~\n`Chữ mã`';
	@override String get quote => 'Trích dẫn';
	@override String get quoteDescription => 'Dùng ký hiệu > để tạo trích dẫn, nhiều > để tạo trích dẫn nhiều cấp';
	@override String get quoteSyntax => '> Đây là trích dẫn cấp một\n>> Đây là trích dẫn cấp hai';
	@override String get list => 'Danh sách';
	@override String get listDescription => 'Tạo danh sách có thứ tự bằng số + dấu chấm, tạo danh sách không thứ tự bằng dấu -';
	@override String get listSyntax => '1. Mục thứ nhất\n2. Mục thứ hai\n\n- Mục không thứ tự\n  - Mục con\n  - Mục con khác';
	@override String get linkAndImage => 'Liên kết và hình ảnh';
	@override String get linkAndImageDescription => 'Định dạng liên kết: [văn bản](URL)\nĐịnh dạng ảnh: ![mô tả](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[văn bản liên kết](${link})\n![mô tả ảnh](${imgUrl})';
	@override String get title => 'Tiêu đề';
	@override String get titleDescription => 'Dùng ký hiệu # để tạo tiêu đề, số lượng # thể hiện cấp';
	@override String get titleSyntax => '# Tiêu đề cấp một\n## Tiêu đề cấp hai\n### Tiêu đề cấp ba';
	@override String get separator => 'Đường phân cách';
	@override String get separatorDescription => 'Tạo đường phân cách bằng ba ký hiệu - trở lên';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Cú pháp';
}

// Path: forum
class _TranslationsForumVi extends TranslationsForumEn {
	_TranslationsForumVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get attachQuote => 'Đính kèm trích dẫn';
	@override String replyToFloor({required Object floor, required Object username}) => 'Trả lời #${floor} @${username}';
	@override String get removeQuote => 'Xóa trích dẫn';
	@override String get recent => 'Gần đây';
	@override String get category => 'Danh mục';
	@override String get lastReply => 'Trả lời gần nhất';
	@override late final _TranslationsForumSitewideVi sitewide = _TranslationsForumSitewideVi._(_root);
	@override late final _TranslationsForumErrorsVi errors = _TranslationsForumErrorsVi._(_root);
	@override String get createPost => 'Tạo bài viết';
	@override String get title => 'Tiêu đề';
	@override String get enterTitle => 'Nhập tiêu đề';
	@override String get content => 'Nội dung';
	@override String get enterContent => 'Nhập nội dung';
	@override String get writeYourContentHere => 'Viết nội dung tại đây...';
	@override String get posts => 'Bài viết';
	@override String get threads => 'Chủ đề';
	@override String get forum => 'Diễn đàn';
	@override String get createThread => 'Tạo chủ đề';
	@override String get selectCategory => 'Chọn danh mục';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Thời gian chờ còn lại ${minutes} phút ${seconds} giây';
	@override late final _TranslationsForumGroupsVi groups = _TranslationsForumGroupsVi._(_root);
	@override late final _TranslationsForumLeafNamesVi leafNames = _TranslationsForumLeafNamesVi._(_root);
	@override late final _TranslationsForumLeafDescriptionsVi leafDescriptions = _TranslationsForumLeafDescriptionsVi._(_root);
	@override String get reply => 'Trả lời';
	@override String get pendingReview => 'Đang chờ duyệt';
	@override String get floorNotFound => 'Bài trả lời đó không tồn tại hoặc đã bị xóa';
	@override String get floorNotLoadedYet => 'Bài đó ở phía trên — tải thêm để nhảy tới';
	@override String get editedAt => 'Chỉnh sửa lúc';
	@override String get copySuccess => 'Đã sao chép vào clipboard';
	@override String copySuccessForMessage({required Object str}) => 'Đã sao chép vào clipboard: ${str}';
	@override String get editReply => 'Chỉnh sửa trả lời';
	@override String get editTitle => 'Chỉnh sửa tiêu đề';
	@override String get submit => 'Gửi';
}

// Path: notifications
class _TranslationsNotificationsVi extends TranslationsNotificationsEn {
	_TranslationsNotificationsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsVi errors = _TranslationsNotificationsErrorsVi._(_root);
	@override String get notifications => 'Thông báo';
	@override String get profile => 'Trang cá nhân';
	@override String get postedNewComment => 'Đã đăng bình luận mới';
	@override String get inYour => 'trong';
	@override String get video => 'Video';
	@override String get repliedYourVideoComment => 'Đã trả lời bình luận video của bạn';
	@override String get copyInfoToClipboard => 'Sao chép thông tin thông báo vào bộ nhớ tạm';
	@override String get copySuccess => 'Đã sao chép vào bộ nhớ tạm';
	@override String copySuccessForMessage({required Object str}) => 'Đã sao chép vào bộ nhớ tạm: ${str}';
	@override String get markAllAsRead => 'Đánh dấu tất cả là đã đọc';
	@override String get markAllAsReadSuccess => 'Tất cả thông báo đã được đánh dấu là đã đọc';
	@override String get markAllAsReadFailed => 'Đánh dấu tất cả là đã đọc thất bại';
	@override String get markSelectedAsRead => 'Đánh dấu mục đã chọn là đã đọc';
	@override String get markSelectedAsReadSuccess => 'Các thông báo đã chọn đã được đánh dấu là đã đọc';
	@override String get markSelectedAsReadFailed => 'Đánh dấu mục đã chọn là đã đọc thất bại';
	@override String get markAsRead => 'Đánh dấu là đã đọc';
	@override String get markAsReadSuccess => 'Thông báo đã được đánh dấu là đã đọc';
	@override String get markAsReadFailed => 'Đánh dấu thông báo là đã đọc thất bại';
	@override String get notificationTypeHelp => 'Trợ giúp về loại thông báo';
	@override String get dueToLackOfNotificationTypeDetails => 'Do thiếu chi tiết loại thông báo, các loại được hỗ trợ có thể không bao quát hết những thông báo bạn đang nhận';
	@override String get helpUsImproveNotificationTypeSupport => 'Nếu bạn sẵn lòng giúp chúng tôi cải thiện hỗ trợ loại thông báo';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Sao chép thông tin thông báo\n2. 🐞 Gửi issue tới kho lưu trữ dự án\n\n⚠️ Lưu ý: Thông tin thông báo có thể chứa thông tin riêng tư cá nhân, nếu bạn không muốn công khai, bạn cũng có thể gửi cho tác giả dự án qua email.';
	@override String get goToRepository => 'Đi tới kho lưu trữ';
	@override String get copy => 'Sao chép';
	@override String get commentApproved => 'Bình luận đã được duyệt';
	@override String get repliedYourProfileComment => 'Đã trả lời bình luận trang cá nhân của bạn';
	@override String get kReplied => 'đã trả lời bình luận của bạn về';
	@override String get kCommented => 'đã bình luận về';
	@override String get kVideo => 'video';
	@override String get kGallery => 'thư viện';
	@override String get kProfile => 'trang cá nhân';
	@override String get kThread => 'chủ đề';
	@override String get kPost => 'bài viết';
	@override String get kCommentSection => 'mục bình luận';
	@override String get kApprovedComment => 'Bình luận đã được duyệt';
	@override String get kApprovedVideo => 'Video đã được duyệt';
	@override String get kApprovedGallery => 'Thư viện đã được duyệt';
	@override String get kApprovedThread => 'Chủ đề đã được duyệt';
	@override String get kApprovedPost => 'Bài viết đã được duyệt';
	@override String get kApprovedForumPost => 'Bài viết diễn đàn đã được duyệt';
	@override String get kRejectedContent => 'Nội dung bị từ chối phê duyệt';
	@override String get kUnknownType => 'Loại thông báo không xác định';
}

// Path: conversation
class _TranslationsConversationVi extends TranslationsConversationEn {
	_TranslationsConversationVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsVi errors = _TranslationsConversationErrorsVi._(_root);
	@override String get conversation => 'Hội thoại';
	@override String get startConversation => 'Bắt đầu hội thoại';
	@override String get noConversation => 'Không có hội thoại';
	@override String get selectFromLeftListAndStartConversation => 'Chọn từ danh sách bên trái và bắt đầu hội thoại';
	@override String get title => 'Tiêu đề';
	@override String get body => 'Nội dung';
	@override String get selectAUser => 'Chọn một người dùng';
	@override String get searchUsers => 'Tìm kiếm người dùng...';
	@override String get tmpNoConversions => 'Không có hội thoại';
	@override String get deleteThisMessage => 'Xóa tin nhắn này';
	@override String get deleteThisMessageSubtitle => 'Thao tác này không thể hoàn tác';
	@override String get writeMessageHere => 'Viết tin nhắn tại đây...';
	@override String get lastMessageFromMe => 'Bạn: ';
	@override String get sendMessage => 'Gửi tin nhắn';
}

// Path: splash
class _TranslationsSplashVi extends TranslationsSplashEn {
	_TranslationsSplashVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsVi errors = _TranslationsSplashErrorsVi._(_root);
	@override String get preparing => 'Đang chuẩn bị...';
	@override String get initializing => 'Đang khởi tạo...';
	@override String get loading => 'Đang tải...';
	@override String get ready => 'Sẵn sàng';
	@override String get initializingMessageService => 'Đang khởi tạo dịch vụ tin nhắn...';
}

// Path: download
class _TranslationsDownloadVi extends TranslationsDownloadEn {
	_TranslationsDownloadVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsVi errors = _TranslationsDownloadErrorsVi._(_root);
	@override String get downloadList => 'Danh sách tải xuống';
	@override String get viewDownloadList => 'Xem danh sách tải xuống';
	@override String get download => 'Tải xuống';
	@override String get selectDownloadTitle => 'Chọn tải xuống';
	@override String get qualitySectionLabel => 'Chất lượng';
	@override String get categorySectionLabel => 'Phân loại';
	@override String get saveToPreviewLabel => 'Sẽ lưu vào';
	@override String saveToPreviewSuggested({required Object name}) => 'Tên tệp gợi ý: ${name} (có thể sửa trong hộp thoại hệ thống)';
	@override String get lastUsedBadge => 'Dùng gần nhất';
	@override String get pickedBadge => 'Đã chọn';
	@override String get startDownloading => 'Bắt đầu tải xuống';
	@override String get clearAllFailedTasks => 'Xóa toàn bộ tác vụ thất bại';
	@override String get clearAllFailedTasksConfirmation => 'Bạn có chắc muốn xóa toàn bộ tác vụ tải xuống thất bại? Tệp của các tác vụ này cũng sẽ bị xóa.';
	@override String get clearAllFailedTasksSuccess => 'Đã xóa toàn bộ tác vụ thất bại';
	@override String get clearAllFailedTasksError => 'Đã xảy ra lỗi khi xóa tác vụ thất bại';
	@override String get downloadStatus => 'Trạng thái tải xuống';
	@override String get imageList => 'Danh sách ảnh';
	@override String get retryDownload => 'Thử tải lại';
	@override String get notDownloaded => 'Chưa tải xuống';
	@override String get downloaded => 'Đã tải xuống';
	@override String get waitingForDownload => 'Đang chờ tải xuống';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Đang tải (${downloaded}/${total} ảnh ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Đang tải (${downloaded} ảnh)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Đã tạm dừng (${downloaded}/${total} ảnh ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'Đã tạm dừng (${downloaded} ảnh)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Đã tải xuống (tổng ${total} ảnh)';
	@override String get viewVideoDetail => 'Xem chi tiết video';
	@override String get viewGalleryDetail => 'Xem chi tiết thư viện';
	@override String get moreOptions => 'Tùy chọn khác';
	@override String get openFile => 'Mở tệp';
	@override String get playLocally => 'Phát cục bộ';
	@override String get pause => 'Tạm dừng';
	@override String get resume => 'Tiếp tục';
	@override String get copyDownloadUrl => 'Sao chép URL tải xuống';
	@override String get showInFolder => 'Hiện trong thư mục';
	@override String get deleteTask => 'Xóa tác vụ';
	@override String get deleteTaskConfirmation => 'Bạn có chắc muốn xóa tác vụ tải xuống này?\nTệp của tác vụ cũng sẽ bị xóa.';
	@override String get forceDeleteTask => 'Buộc xóa tác vụ';
	@override String get forceDeleteTaskConfirmation => 'Bạn có chắc muốn buộc xóa tác vụ tải xuống này?\nTệp của tác vụ cũng sẽ bị xóa, kể cả khi tệp đang được sử dụng.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Đang tải ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Đang tải ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Đã tạm dừng ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'Đã tạm dừng • Đã tải ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Đã tải xuống • ${size}';
	@override String get copyDownloadUrlSuccess => 'Đã sao chép URL tải xuống';
	@override String totalImageNums({required Object num}) => '${num} ảnh';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Đang tải ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'Đang tải xuống';
	@override String get failed => 'Thất bại';
	@override String get completed => 'Đã hoàn thành';
	@override String get downloadDetail => 'Chi tiết tải xuống';
	@override String get copy => 'Sao chép';
	@override String get copySuccess => 'Đã sao chép';
	@override String get waiting => 'Đang chờ';
	@override String get paused => 'Đã tạm dừng';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Đang tải ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Tải thư viện hoàn tất: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Tải xuống hoàn tất: ${fileName}';
	@override String get searchTasks => 'Tìm kiếm tác vụ...';
	@override String statusLabel({required Object label}) => 'Trạng thái: ${label}';
	@override String get allStatus => 'Mọi trạng thái';
	@override String typeLabel({required Object label}) => 'Loại: ${label}';
	@override String get allTypes => 'Mọi loại';
	@override String get taskType => 'Loại';
	@override String get video => 'Video';
	@override String get gallery => 'Thư viện';
	@override String get other => 'Khác';
	@override String get clearFilters => 'Xóa bộ lọc';
	@override String get pauseAll => 'Tạm dừng tất cả';
	@override String get resumeAll => 'Bắt đầu tất cả';
	@override String remainingTime({required Object time}) => 'còn ${time}';
	@override late final _TranslationsDownloadTimelineVi timeline = _TranslationsDownloadTimelineVi._(_root);
	@override late final _TranslationsDownloadErrorTypesVi errorTypes = _TranslationsDownloadErrorTypesVi._(_root);
	@override String get errorDetailCopied => 'Đã sao chép chi tiết lỗi';
	@override String get errorDetailCopyHint => 'Nhấn giữ để sao chép chi tiết lỗi';
	@override late final _TranslationsDownloadRestoredPausedVi restoredPaused = _TranslationsDownloadRestoredPausedVi._(_root);
	@override late final _TranslationsDownloadActionsVi actions = _TranslationsDownloadActionsVi._(_root);
	@override late final _TranslationsDownloadNoticeVi notice = _TranslationsDownloadNoticeVi._(_root);
	@override String get emptyTaskList => 'Chưa có tác vụ tải xuống';
	@override String get noMatchingTasks => 'Không có tác vụ nào khớp';
	@override late final _TranslationsDownloadDeleteByDateVi deleteByDate = _TranslationsDownloadDeleteByDateVi._(_root);
	@override late final _TranslationsDownloadRelocationVi relocation = _TranslationsDownloadRelocationVi._(_root);
	@override late final _TranslationsDownloadCategoryVi category = _TranslationsDownloadCategoryVi._(_root);
	@override late final _TranslationsDownloadLocationVi location = _TranslationsDownloadLocationVi._(_root);
	@override String get maxConcurrentDownloads => 'Số tải xuống đồng thời tối đa';
	@override String get maxConcurrentDownloadsDesc => 'Số tác vụ tải xuống cùng lúc (1-5)';
	@override String get stillInDevelopment => 'Vẫn đang phát triển';
	@override String get saveToAppDirectory => 'Lưu vào thư mục ứng dụng';
	@override String get alreadyDownloadedWithQuality => 'Đã tải xuống với cùng chất lượng, tiếp tục tải?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Đã tải xuống với chất lượng: ${qualities}, tiếp tục tải?';
	@override String get otherQualities => 'Chất lượng khác';
	@override late final _TranslationsDownloadBatchDownloadVi batchDownload = _TranslationsDownloadBatchDownloadVi._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsVi extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Tải xuống hoàn tất';
	@override String get failedTitle => 'Tải xuống thất bại';
	@override String completedBody({required Object name}) => '${name} đã tải xuống thành công';
	@override String failedBody({required Object name}) => '${name} tải xuống thất bại';
	@override String completedToast({required Object name}) => 'Đã tải xuống ${name}';
	@override String failedToast({required Object name}) => '${name} tải xuống thất bại';
	@override String savedToFolder({required Object dir}) => 'Đã lưu vào ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Đã lưu thành ${name} (đã có tệp trùng tên)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Đã lưu vào thư mục ứng dụng — không thể ghi ${target} (${reason})';
	@override String get viewFolder => 'Xem thư mục';
	@override String get fixInSettings => 'Sửa trong Cài đặt';
	@override String get channelName => 'Trạng thái tải xuống';
	@override String get channelDescription => 'Thông báo cho các tải xuống đã hoàn thành và thất bại';
}

// Path: favorite
class _TranslationsFavoriteVi extends TranslationsFavoriteEn {
	_TranslationsFavoriteVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsVi errors = _TranslationsFavoriteErrorsVi._(_root);
	@override String get add => 'Thêm';
	@override String get addSuccess => 'Thêm thành công';
	@override String get addFailed => 'Thêm thất bại';
	@override String get remove => 'Xóa';
	@override String get removeSuccess => 'Xóa thành công';
	@override String get removeFailed => 'Xóa thất bại';
	@override String get removeConfirmation => 'Bạn có chắc muốn xóa mục này khỏi yêu thích?';
	@override String get removeConfirmationSuccess => 'Đã xóa mục khỏi yêu thích';
	@override String get removeConfirmationFailed => 'Xóa mục khỏi yêu thích thất bại';
	@override String get createFolderSuccess => 'Đã tạo thư mục thành công';
	@override String get createFolderFailed => 'Tạo thư mục thất bại';
	@override String get createFolder => 'Tạo thư mục';
	@override String get enterFolderName => 'Nhập tên thư mục';
	@override String get enterFolderNameHere => 'Nhập tên thư mục tại đây...';
	@override String get create => 'Tạo';
	@override String get items => 'Mục';
	@override String get newFolderName => 'Thư mục mới';
	@override String get searchFolders => 'Tìm kiếm thư mục...';
	@override String get searchItems => 'Tìm kiếm mục...';
	@override String get createdAt => 'Ngày tạo';
	@override String get myFavorites => 'Yêu thích của tôi';
	@override String get deleteFolderTitle => 'Xóa thư mục';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'Bạn có chắc muốn xóa thư mục ${title}?';
	@override String get removeItemTitle => 'Xóa mục';
	@override String removeItemConfirmWithTitle({required Object title}) => 'Bạn có chắc muốn xóa mục ${title}?';
	@override String get removeItemSuccess => 'Đã xóa mục khỏi yêu thích';
	@override String get removeItemFailed => 'Xóa mục khỏi yêu thích thất bại';
	@override String get localizeFavorite => 'Yêu thích cục bộ';
	@override String get editFolderTitle => 'Chỉnh sửa thư mục';
	@override String get editFolderSuccess => 'Đã cập nhật thư mục thành công';
	@override String get editFolderFailed => 'Cập nhật thư mục thất bại';
	@override String get searchTags => 'Tìm kiếm thẻ';
	@override String get noTagsInFolder => 'Chưa có thẻ nào trên các mục trong thư mục này';
	@override String get tagFilterMatchAll => 'Chỉ hiện các mục có đủ mọi thẻ đã chọn';
	@override String get clearSelectedTags => 'Xóa thẻ đã chọn';
	@override String selectedTagCount({required Object count}) => 'Đã chọn ${count}';
	@override String get noMatchingTags => 'Không có thẻ nào khớp';
}

// Path: translation
class _TranslationsTranslationVi extends TranslationsTranslationEn {
	_TranslationsTranslationVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Dịch vụ hiện tại';
	@override String get testConnection => 'Kiểm tra kết nối';
	@override String get testConnectionSuccess => 'Kiểm tra kết nối thành công';
	@override String get testConnectionFailed => 'Kiểm tra kết nối thất bại';
	@override String testConnectionFailedWithMessage({required Object message}) => 'Kiểm tra kết nối thất bại: ${message}';
	@override String get translation => 'Dịch';
	@override String get needVerification => 'Cần xác minh';
	@override String get needVerificationContent => 'Vui lòng kiểm tra kết nối trước khi bật dịch bằng AI';
	@override String get confirm => 'Xác nhận';
	@override String get disclaimer => 'Miễn trừ trách nhiệm';
	@override String get riskWarning => 'Cảnh báo rủi ro';
	@override String get dureToRisk1 => 'Do văn bản do người dùng tạo, có thể chứa nội dung vi phạm chính sách nội dung của nhà cung cấp dịch vụ AI';
	@override String get dureToRisk2 => 'Nội dung không phù hợp có thể dẫn đến việc khóa API key hoặc chấm dứt dịch vụ';
	@override String get operationSuggestion => 'Gợi ý thao tác';
	@override String get operationSuggestion1 => '1. Dùng trước khi kiểm duyệt kỹ nội dung cần dịch';
	@override String get operationSuggestion2 => '2. Tránh dịch nội dung liên quan đến bạo lực, nội dung người lớn, v.v.';
	@override String get apiConfig => 'Cấu hình API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Sửa cấu hình sẽ tự động tắt dịch bằng AI, cần kiểm tra lại sau khi bật';
	@override String get apiAddress => 'Địa chỉ API';
	@override String get modelName => 'Tên mô hình';
	@override String get modelNameHintText => 'Ví dụ: gpt-4-turbo';
	@override String get maxTokens => 'Số token tối đa';
	@override String get maxTokensHintText => 'Ví dụ: 32000';
	@override String get temperature => 'Nhiệt độ';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Nhấn nút kiểm tra để xác minh kết nối API có hợp lệ không';
	@override String get requestPreview => 'Xem trước yêu cầu';
	@override String get enableAITranslation => 'Bật AI';
	@override String get enabled => 'Đã bật';
	@override String get disabled => 'Đã tắt';
	@override String get testing => 'Đang kiểm tra...';
	@override String get testNow => 'Kiểm tra ngay';
	@override String get connectionStatus => 'Trạng thái kết nối';
	@override String get success => 'Thành công';
	@override String get failed => 'Thất bại';
	@override String get information => 'Thông tin';
	@override String get viewRawResponse => 'Xem phản hồi thô';
	@override String get pleaseCheckInputParametersFormat => 'Vui lòng kiểm tra định dạng tham số đầu vào';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Vui lòng điền địa chỉ API, tên mô hình và khóa';
	@override String get pleaseFillInValidConfigurationParameters => 'Vui lòng điền các tham số cấu hình hợp lệ';
	@override String get pleaseCompleteConnectionTest => 'Vui lòng hoàn tất kiểm tra kết nối';
	@override String get notConfigured => 'Chưa cấu hình';
	@override String get apiEndpoint => 'Điểm cuối API';
	@override String get configuredKey => 'Khóa đã cấu hình';
	@override String get notConfiguredKey => 'Khóa chưa cấu hình';
	@override String get authenticationStatus => 'Trạng thái xác thực';
	@override String get thisFieldCannotBeEmpty => 'Trường này không được để trống';
	@override String get apiKey => 'Khóa API';
	@override String get apiKeyCannotBeEmpty => 'Khóa API không được để trống';
	@override String get pleaseEnterValidNumber => 'Vui lòng nhập số hợp lệ';
	@override String get range => 'Khoảng';
	@override String get mustBeGreaterThan => 'Phải lớn hơn';
	@override String get invalidAPIResponse => 'Phản hồi API không hợp lệ';
	@override String connectionFailedForMessage({required Object message}) => 'Kết nối thất bại: ${message}';
	@override String get aiTranslationNotEnabledHint => 'Tính năng dịch bằng AI chưa được bật, vui lòng bật trong cài đặt';
	@override String get goToSettings => 'Đi tới Cài đặt';
	@override String get disableAITranslation => 'Tắt dịch bằng AI';
	@override String get currentValue => 'Giá trị hiện tại';
	@override String get configureTranslationStrategy => 'Cấu hình chiến lược dịch';
	@override String get advancedSettings => 'Cài đặt nâng cao';
	@override String get translationPrompt => 'Câu lệnh dịch';
	@override String get promptHint => 'Vui lòng nhập câu lệnh dịch, dùng [TL] làm chỗ giữ chỗ cho ngôn ngữ đích';
	@override String get promptHelperText => 'Câu lệnh phải chứa [TL] làm chỗ giữ chỗ cho ngôn ngữ đích';
	@override String get promptMustContainTargetLang => 'Câu lệnh phải chứa chỗ giữ chỗ [TL]';
	@override String get aiTranslationWillBeDisabled => 'Dịch bằng AI sẽ bị tắt';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'Do thay đổi cấu hình cơ bản, dịch bằng AI sẽ bị tắt';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'Do thay đổi câu lệnh dịch, dịch bằng AI sẽ bị tắt';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'Do thay đổi cấu hình tham số, dịch bằng AI sẽ bị tắt';
	@override String get onlyOpenAIAPISupported => 'Hiện chỉ hỗ trợ định dạng API tương thích OpenAI (phần thân yêu cầu application/json)';
	@override String get streamingTranslation => 'Dịch theo luồng';
	@override String get streamingTranslationSupported => 'Hỗ trợ dịch theo luồng';
	@override String get streamingTranslationNotSupported => 'Không hỗ trợ dịch theo luồng';
	@override String get streamingTranslationDescription => 'Dịch theo luồng có thể hiển thị kết quả theo thời gian thực trong quá trình dịch, mang lại trải nghiệm tốt hơn';
	@override String get usingFullUrlWithHash => 'Đang dùng URL đầy đủ (kết thúc bằng #)';
	@override String get baseUrlInputHelperText => 'Khi kết thúc bằng #, nó sẽ được dùng làm địa chỉ yêu cầu thực tế';
	@override String currentActualUrl({required Object url}) => 'URL thực tế hiện tại: ${url}';
	@override String get urlEndingWithHashTip => 'URL kết thúc bằng # sẽ được dùng trực tiếp mà không thêm hậu tố nào';
	@override String get streamingTranslationWarning => 'Lưu ý: Tính năng này yêu cầu dịch vụ API hỗ trợ truyền theo luồng, một số mô hình có thể không hỗ trợ';
	@override String get translationService => 'Dịch vụ dịch';
	@override String get translationServiceDescription => 'Chọn dịch vụ dịch bạn muốn dùng';
	@override String get googleTranslation => 'Dịch Google';
	@override String get googleTranslationDescription => 'Dịch vụ dịch trực tuyến miễn phí hỗ trợ nhiều ngôn ngữ';
	@override String get aiTranslation => 'Dịch bằng AI';
	@override String get aiTranslationDescription => 'Dịch vụ dịch thông minh dựa trên mô hình ngôn ngữ lớn';
	@override String get deeplxTranslation => 'Dịch DeepLX';
	@override String get deeplxTranslationDescription => 'Bản triển khai mã nguồn mở của DeepL, cung cấp bản dịch chất lượng cao';
	@override String get googleTranslationFeatures => 'Tính năng';
	@override String get freeToUse => 'Miễn phí sử dụng';
	@override String get freeToUseDescription => 'Không cần cấu hình, dùng được ngay';
	@override String get fastResponse => 'Phản hồi nhanh';
	@override String get fastResponseDescription => 'Tốc độ dịch nhanh với độ trễ thấp';
	@override String get stableAndReliable => 'Ổn định và đáng tin cậy';
	@override String get stableAndReliableDescription => 'Dựa trên API chính thức của Google';
	@override String get enabledDefaultService => 'Đã bật - Dịch vụ dịch mặc định';
	@override String get notEnabled => 'Chưa bật';
	@override String get deeplxTranslationService => 'Dịch vụ dịch DeepLX';
	@override String get deeplxDescription => 'DeepLX là bản triển khai mã nguồn mở của DeepL, hỗ trợ các chế độ điểm cuối Free, Pro và Official';
	@override String get serverAddress => 'Địa chỉ máy chủ';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Địa chỉ gốc của máy chủ DeepLX';
	@override String get endpointType => 'Loại điểm cuối';
	@override String get freeEndpoint => 'Free - Điểm cuối miễn phí, có thể bị giới hạn tốc độ';
	@override String get proEndpoint => 'Pro - Cần dl_session, ổn định hơn';
	@override String get officialEndpoint => 'Official - Định dạng API chính thức';
	@override String get finalRequestUrl => 'URL yêu cầu cuối cùng';
	@override String get apiKeyOptional => 'Khóa API (tùy chọn)';
	@override String get apiKeyOptionalHint => 'Để truy cập các dịch vụ DeepLX được bảo vệ';
	@override String get apiKeyOptionalHelperText => 'Một số dịch vụ DeepLX yêu cầu Khóa API để xác thực';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Tham số dl_session bắt buộc cho chế độ Pro';
	@override String get dlSessionHelperText => 'Tham số session bắt buộc cho điểm cuối Pro, lấy từ tài khoản DeepL Pro';
	@override String get proModeRequiresDlSession => 'Chế độ Pro cần dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Nhấn nút kiểm tra để xác minh kết nối API DeepLX';
	@override String get enableDeepLXTranslation => 'Bật dịch DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'Dịch DeepLX sẽ bị tắt do thay đổi cấu hình';
	@override String get translatedResult => 'Kết quả dịch';
	@override String get testSuccess => 'Kiểm tra thành công';
	@override String get pleaseFillInDeepLXServerAddress => 'Vui lòng điền địa chỉ máy chủ DeepLX';
	@override String get invalidAPIResponseFormat => 'Định dạng phản hồi API không hợp lệ';
	@override String get translationServiceReturnedError => 'Dịch vụ dịch trả về lỗi hoặc kết quả rỗng';
	@override String get connectionFailed => 'Kết nối thất bại';
	@override String get translationFailed => 'Dịch thất bại';
	@override String get aiTranslationFailed => 'Dịch bằng AI thất bại';
	@override String get deeplxTranslationFailed => 'Dịch DeepLX thất bại';
	@override String get aiTranslationTestFailed => 'Kiểm tra dịch bằng AI thất bại';
	@override String get deeplxTranslationTestFailed => 'Kiểm tra dịch DeepLX thất bại';
	@override String get streamingTranslationTimeout => 'Dịch theo luồng quá thời gian, buộc dọn tài nguyên';
	@override String get translationRequestTimeout => 'Yêu cầu dịch quá thời gian';
	@override String get streamingTranslationDataTimeout => 'Hết thời gian nhận dữ liệu dịch theo luồng';
	@override String get dataReceptionTimeout => 'Hết thời gian nhận dữ liệu';
	@override String get streamDataParseError => 'Lỗi phân tích dữ liệu luồng';
	@override String get streamingTranslationFailed => 'Dịch theo luồng thất bại';
	@override String get fallbackTranslationFailed => 'Dịch dự phòng thông thường cũng thất bại';
	@override String get translationSettings => 'Cài đặt dịch';
	@override String get enableGoogleTranslation => 'Bật dịch Google';
	@override String get thinking => 'Đang suy nghĩ...';
	@override String get thoughtProcess => 'Quá trình suy nghĩ';
	@override String get modelCompatibility => 'Tương thích mô hình';
	@override String get modelCompatibilityDescription => 'Điều chỉnh tham số yêu cầu cho các mô hình hiện đại như mô hình suy luận (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'Mô hình suy luận';
	@override String get reasoningModelDescription => 'Cho o1/o3, DeepSeek-R1, QwQ, v.v. Gộp câu lệnh vào tin nhắn người dùng, bỏ temperature và dùng max_completion_tokens';
	@override String get useMaxCompletionTokens => 'Dùng max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'Các điểm cuối OpenAI mới hơn yêu cầu max_completion_tokens thay cho max_tokens đã lỗi thời';
	@override String get sendTemperature => 'Gửi temperature';
	@override String get sendTemperatureDescription => 'Tắt cho các mô hình từ chối tham số temperature (hầu hết mô hình suy luận)';
	@override String get showReasoningProcess => 'Hiển thị quá trình suy nghĩ';
	@override String get showReasoningProcessDescription => 'Hiển thị phần suy luận có thể thu gọn của mô hình suy luận trong hộp thoại dịch';
	@override String get provider => 'Nhà cung cấp';
	@override String get providerOpenAI => 'OpenAI (và tương thích)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Hỗ trợ OpenAI (và mọi điểm cuối tương thích OpenAI), Anthropic và Google qua SDK dartantic_ai';
	@override String get baseUrlOptionalHelperText => 'Tùy chọn. Để trống để dùng điểm cuối mặc định của nhà cung cấp; điền vào cho các điểm cuối tương thích OpenAI hoặc trung chuyển';
	@override String get defaultEndpoint => 'Điểm cuối mặc định';
	@override String get providerPreset => 'Đặt trước nhà cung cấp';
	@override String get selectProviderPreset => 'Chọn một đặt trước';
	@override String get presetCustom => 'Tùy chỉnh';
	@override String presetApplied({required Object name}) => 'Đã áp dụng đặt trước: ${name}';
	@override late final _TranslationsTranslationPresetNamesVi presetNames = _TranslationsTranslationPresetNamesVi._(_root);
	@override String get fetchModelList => 'Tải danh sách mô hình';
	@override String get fetchingModels => 'Đang tải...';
	@override String get selectModel => 'Chọn mô hình';
	@override String get searchModel => 'Tìm kiếm mô hình';
	@override String get noModelsFound => 'Không tìm thấy mô hình nào';
}

// Path: bottomNav
class _TranslationsBottomNavVi extends TranslationsBottomNavEn {
	_TranslationsBottomNavVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get video => 'Video';
	@override String get gallery => 'Ảnh';
	@override String get subscription => 'Feed';
	@override String get community => 'Forum';
	@override String get localMedia => 'Cục bộ';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsVi extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt thứ tự điều hướng';
	@override String get customNavigationOrder => 'Thứ tự điều hướng tùy chỉnh';
	@override String get customNavigationOrderDesc => 'Kéo để điều chỉnh thứ tự hiển thị của các trang trong thanh điều hướng dưới và thanh bên';
	@override String get restartRequired => 'Cần khởi động lại ứng dụng';
	@override String get navigationItemSorting => 'Sắp xếp mục điều hướng';
	@override String get done => 'Xong';
	@override String get edit => 'Chỉnh sửa';
	@override String get reset => 'Đặt lại';
	@override String get previewEffect => 'Xem trước hiệu ứng';
	@override String get bottomNavigationPreview => 'Xem trước thanh điều hướng dưới:';
	@override String get sidebarPreview => 'Xem trước thanh bên:';
	@override String get confirmResetNavigationOrder => 'Xác nhận đặt lại thứ tự điều hướng';
	@override String get confirmResetNavigationOrderDesc => 'Bạn có chắc muốn đặt lại thứ tự điều hướng về mặc định?';
	@override String get cancel => 'Hủy';
	@override String get show => 'Hiện';
	@override String get hide => 'Ẩn';
	@override String get hidden => 'Đã ẩn';
	@override String get hideHint => 'Nhấn biểu tượng con mắt để hiện hoặc ẩn Cộng đồng và tệp cục bộ';
	@override String get videoDescription => 'Duyệt nội dung video phổ biến';
	@override String get galleryDescription => 'Duyệt ảnh và thư viện';
	@override String get subscriptionDescription => 'Xem nội dung mới nhất từ những người bạn theo dõi';
	@override String get forumDescription => 'Tham gia thảo luận cộng đồng';
	@override String get newsDescription => 'Duyệt tin tức, bài viết và phát sóng chính thức';
	@override String get communityDescription => 'Thảo luận diễn đàn cùng tin tức, bài viết và phát sóng chính thức';
	@override String get localMediaDescription => 'Duyệt video và ảnh lưu trên thiết bị này';
}

// Path: news
class _TranslationsNewsVi extends TranslationsNewsEn {
	_TranslationsNewsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tin tức';
	@override String get newsUpdates => 'Cập nhật tin tức';
	@override String get articles => 'Bài viết';
	@override String get broadcast => 'Phát sóng';
	@override String get openInBrowser => 'Mở trong trình duyệt';
}

// Path: displaySettings
class _TranslationsDisplaySettingsVi extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt hiển thị';
	@override String get layoutSettings => 'Cài đặt bố cục';
	@override String get layoutSettingsDesc => 'Tùy chỉnh số cột và cấu hình điểm ngắt';
	@override String get gridLayout => 'Bố cục lưới';
	@override String get navigationOrderSettings => 'Cài đặt thứ tự điều hướng';
	@override String get customNavigationOrder => 'Thứ tự điều hướng tùy chỉnh';
	@override String get customNavigationOrderDesc => 'Điều chỉnh thứ tự hiển thị của các trang trong thanh điều hướng dưới và thanh bên';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsVi extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt bố cục';
	@override String get descriptionTitle => 'Mô tả cấu hình bố cục';
	@override String get descriptionContent => 'Cấu hình tại đây quyết định số cột hiển thị trong trang danh sách video và thư viện. Có thể chọn chế độ tự động để hệ thống tự điều chỉnh theo chiều rộng màn hình, hoặc chọn chế độ thủ công để cố định số cột.';
	@override String get layoutMode => 'Chế độ bố cục';
	@override String get reset => 'Đặt lại';
	@override String get autoMode => 'Chế độ tự động';
	@override String get autoModeDesc => 'Tự động điều chỉnh theo chiều rộng màn hình';
	@override String get manualMode => 'Chế độ thủ công';
	@override String get manualModeDesc => 'Dùng số cột cố định';
	@override String get manualSettings => 'Cài đặt thủ công';
	@override String get fixedColumns => 'Số cột cố định';
	@override String get columns => 'cột';
	@override String get breakpointConfig => 'Cấu hình điểm ngắt';
	@override String get add => 'Thêm';
	@override String get defaultColumns => 'Số cột mặc định';
	@override String get defaultColumnsDesc => 'Hiển thị mặc định cho màn hình lớn';
	@override String get previewEffect => 'Xem trước hiệu ứng';
	@override String get screenWidth => 'Chiều rộng màn hình';
	@override String get addBreakpoint => 'Thêm điểm ngắt';
	@override String get editBreakpoint => 'Chỉnh sửa điểm ngắt';
	@override String get deleteBreakpoint => 'Xóa điểm ngắt';
	@override String get screenWidthLabel => 'Chiều rộng màn hình';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Số cột';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Vui lòng nhập chiều rộng';
	@override String get enterValidWidth => 'Vui lòng nhập chiều rộng hợp lệ';
	@override String get widthCannotExceed9999 => 'Chiều rộng không được vượt quá 9999';
	@override String get breakpointAlreadyExists => 'Điểm ngắt đã tồn tại';
	@override String get enterColumns => 'Vui lòng nhập số cột';
	@override String get enterValidColumns => 'Vui lòng nhập số cột hợp lệ';
	@override String get columnsCannotExceed12 => 'Số cột không được vượt quá 12';
	@override String get breakpointConflict => 'Điểm ngắt đã tồn tại';
	@override String get confirmResetLayoutSettings => 'Đặt lại cài đặt bố cục';
	@override String get confirmResetLayoutSettingsDesc => 'Bạn có chắc muốn đặt lại toàn bộ cài đặt bố cục về giá trị mặc định?\n\nSẽ khôi phục về:\n• Chế độ tự động\n• Cấu hình điểm ngắt mặc định';
	@override String get resetToDefaults => 'Đặt lại về mặc định';
	@override String get confirmDeleteBreakpoint => 'Xóa điểm ngắt';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'Bạn có chắc muốn xóa điểm ngắt ${width}px?';
	@override String get noCustomBreakpoints => 'Không có điểm ngắt tùy chỉnh, đang dùng số cột mặc định';
	@override String get breakpointRange => 'Phạm vi điểm ngắt';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Chỉnh sửa';
	@override String get delete => 'Xóa';
	@override String get cancel => 'Hủy';
	@override String get save => 'Lưu';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerVi extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Lỗi trình phát video';
	@override String get videoLoadFailed => 'Tải video thất bại';
	@override String get videoCodecNotSupported => 'Không hỗ trợ codec video';
	@override String get networkConnectionIssue => 'Vấn đề kết nối mạng';
	@override String get insufficientPermission => 'Quyền không đủ';
	@override String get unsupportedVideoFormat => 'Định dạng video không được hỗ trợ';
	@override String get retry => 'Thử lại';
	@override String get externalPlayer => 'Trình phát ngoài';
	@override String get detailedErrorInfo => 'Thông tin lỗi chi tiết';
	@override String get format => 'Định dạng';
	@override String get suggestion => 'Gợi ý';
	@override String get androidWebmCompatibilityIssue => 'Thiết bị Android hỗ trợ hạn chế định dạng WEBM. Nên dùng trình phát ngoài hoặc tải ứng dụng trình phát hỗ trợ WEBM';
	@override String get currentDeviceCodecNotSupported => 'Thiết bị hiện tại không hỗ trợ codec cho định dạng video này';
	@override String get checkNetworkConnection => 'Vui lòng kiểm tra kết nối mạng và thử lại';
	@override String get appMayLackMediaPermission => 'Ứng dụng có thể thiếu quyền phát media cần thiết';
	@override String get tryOtherVideoPlayer => 'Vui lòng thử dùng trình phát video khác';
	@override String get unrecognizedVideoFormat => 'Tệp video không nhận dạng được';
	@override String get unrecognizedVideoFormatSuggestion => 'Liên kết có thể đã hết hạn, hoặc phản hồi không phải video. Hãy thử lại, hoặc mở bằng ứng dụng khác.';
	@override String get accessDenied => 'Máy chủ từ chối yêu cầu này (403)';
	@override String get accessDeniedSuggestion => 'Liên kết phát nhiều khả năng đã hết hạn. Nhấn Thử lại để lấy lại, hoặc mở bằng ứng dụng khác.';
	@override String get mute => 'Tắt tiếng';
	@override String get unmute => 'Bật tiếng';
	@override String get video => 'VIDEO';
	@override String get serverSelector => 'Chọn máy chủ CDN';
	@override String get serverSelectorDescription => 'Chọn máy chủ có độ trễ thấp nhất để có trải nghiệm phát tốt nhất';
	@override String get retestSpeed => 'Đo lại tốc độ';
	@override String get waitingForSpeedTest => 'Đang chờ đo tốc độ';
	@override String get testingSpeed => 'Đang đo tốc độ...';
	@override String get testFailed => 'Đo thất bại';
	@override String get loadingServerList => 'Đang tải danh sách máy chủ...';
	@override String get noAvailableServers => 'Không có máy chủ khả dụng';
	@override String get refreshServerList => 'Làm mới danh sách máy chủ';
	@override String get cannotGetSource => 'Không lấy được nguồn video hiện tại';
	@override String switchedToServer({required Object serverName}) => 'Đã chuyển sang máy chủ: ${serverName}';
	@override String serverCount({required Object count}) => 'Tổng ${count} máy chủ';
	@override String statusCode({required Object code}) => 'Mã trạng thái: ${code}';
	@override String get connectionFailed => 'Kết nối thất bại';
	@override String get connectionTimeout => 'Kết nối quá thời gian';
	@override String get networkError => 'Lỗi mạng';
	@override String get sslError => 'Lỗi chứng chỉ SSL';
	@override String get testCompleted => 'Đã đo xong';
	@override String get local => 'Cục bộ';
	@override String get unknown => 'Không xác định';
	@override String get localVideoPathEmpty => 'Đường dẫn video cục bộ trống';
	@override String localVideoFileNotExists({required Object path}) => 'Tệp video cục bộ không tồn tại: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'Không thể phát video cục bộ: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Kéo tệp video vào đây để phát';
	@override String get supportedFormats => 'Định dạng được hỗ trợ: MP4, MKV, AVI, MOV, WEBM, v.v.';
	@override String get noSupportedVideoFile => 'Không tìm thấy tệp video được hỗ trợ';
	@override String get retryingOpenVideoLink => 'Mở liên kết video thất bại, đang thử lại';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'Không thể tải bộ giải mã: ${event}. Hãy thử chuyển sang giải mã phần mềm trong cài đặt trình phát rồi vào lại trang';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Lỗi tải video: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Phát hiện lỗi phát lặp lại. Vào Cài đặt > Chẩn đoán & Phản hồi để xuất nhật ký.';
	@override String get openSettingsAction => 'Xem';
	@override late final _TranslationsMediaPlayerNoticeVi notice = _TranslationsMediaPlayerNoticeVi._(_root);
	@override String get imageLoadFailed => 'Tải ảnh thất bại';
	@override String get unsupportedImageFormat => 'Định dạng ảnh không được hỗ trợ';
	@override String get tryOtherViewer => 'Vui lòng thử dùng trình xem khác';
}

// Path: diagnostics
class _TranslationsDiagnosticsVi extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Thông tin chẩn đoán';
	@override String get appVersionLabel => 'Phiên bản ứng dụng';
	@override String memoryUsage({required Object memMB}) => 'Mức dùng bộ nhớ: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'Không thể lấy thông tin thiết bị';
	@override String get secureStorageLabel => 'Lưu trữ an toàn';
	@override String get secureStorageHealthy => 'Khả dụng';
	@override String get secureStorageRecovered => 'Tự phục hồi bằng cách đặt lại (đã xóa dữ liệu trước đó)';
	@override String get secureStorageUnavailable => 'Không khả dụng (đăng nhập được lưu bằng mã hóa dự phòng)';
	@override String get secureStoragePlatformOptOut => 'Mã hóa cục bộ theo chính sách nền tảng (macOS không dùng chuỗi khóa hệ thống)';
	@override String get secureStorageDualWrite => ' (bật bảo vệ ghi kép)';
	@override String get schemaHealthLabel => 'Lược đồ cơ sở dữ liệu';
	@override String get schemaHealthOk => 'OK';
	@override String get schemaHealthRepairedNow => 'Được lưới an toàn sửa chữa trong lần khởi chạy này (di trú chưa có hiệu lực)';
	@override String get schemaHealthRepairedBefore => 'Trước đây đã được lưới an toàn sửa chữa';
	@override String get logPolicySectionTitle => 'Chính sách nhật ký';
	@override String get configServiceUnavailable => 'Dịch vụ cấu hình chưa được khởi tạo. Không thể điều chỉnh chính sách nhật ký.';
	@override String get enableLoggingTitle => 'Bật ghi nhật ký';
	@override String get enableLoggingSubtitle => 'Tắt để ngừng ghi nhật ký mới';
	@override String get enableLogPersistenceTitle => 'Bật lưu nhật ký lâu dài';
	@override String get enableLogPersistenceSubtitle => 'Tắt để chỉ giữ nhật ký trong bộ nhớ và ngừng ghi ra đĩa';
	@override String get minLogLevelTitle => 'Cấp nhật ký tối thiểu';
	@override String get minLogLevelSubtitle => 'Nhật ký dưới mức này sẽ bị lọc bỏ';
	@override String get maxFileSizeTitle => 'Giới hạn kích thước một tệp';
	@override String get maxFileSizeSubtitle => 'Xoay vòng khi đạt ngưỡng';
	@override String get rotatedFileCountTitle => 'Số tệp xoay vòng nhật ký chính';
	@override String get rotatedFileCountSubtitle => 'Số tệp được giữ lại, không tính tệp hiện tại';
	@override String get hangFileSizeTitle => 'Giới hạn kích thước nhật ký treo';
	@override String get hangFileSizeSubtitle => 'Kiểm soát mức tăng của tệp hang_events';
	@override String get hangRotatedFileCountTitle => 'Số tệp xoay vòng nhật ký treo';
	@override String get hangRotatedFileCountSubtitle => 'Kiểm soát lịch sử lưu giữ cho hang_events';
	@override String get healthSectionTitle => 'Sức khỏe nhật ký';
	@override String get refreshMetrics => 'Làm mới chỉ số';
	@override String get toolsSectionTitle => 'Công cụ';
	@override String get privacyNotice => 'Nhật ký có thể chứa thông tin nhạy cảm như dữ liệu tài khoản và tham số yêu cầu. Không đăng toàn bộ nhật ký công khai trong issue; hãy xem lại trước và gửi qua email.';
	@override String get exportLogsTitle => 'Xuất nhật ký';
	@override String get exportLogsSubtitle => 'Xem lại dữ liệu riêng tư trước khi gửi cho nhà phát triển';
	@override String get viewLogsTitle => 'Xem nhật ký';
	@override String get viewLogsSubtitle => 'Xem nhật ký chạy theo thời gian thực';
	@override String get copySupportEmailTitle => 'Sao chép email hỗ trợ';
	@override String get reportIssueTitle => 'Báo lỗi';
	@override String get reportIssueSubtitle => 'Cung cấp các bước tái hiện trên GitHub (không đính kèm toàn bộ nhật ký)';
	@override String get healthSummaryUnavailable => 'Chưa có dữ liệu sức khỏe nhật ký';
	@override String get healthMetricsUnavailable => 'Chưa thu thập chỉ số sức khỏe';
	@override String get healthNoRiskIndicators => 'Không phát hiện chỉ báo rủi ro';
	@override late final _TranslationsDiagnosticsHealthAlertVi healthAlert = _TranslationsDiagnosticsHealthAlertVi._(_root);
	@override late final _TranslationsDiagnosticsToastVi toast = _TranslationsDiagnosticsToastVi._(_root);
	@override String get shareSubject => 'Nhật ký chẩn đoán LoveIwara (chứa dữ liệu nhạy cảm, chia sẻ cẩn trọng)';
}

// Path: logViewer
class _TranslationsLogViewerVi extends TranslationsLogViewerEn {
	_TranslationsLogViewerVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Trình xem nhật ký';
	@override String get searchHint => 'Tìm kiếm nhật ký...';
	@override String get emptyState => 'Không có nhật ký';
	@override String get copiedToClipboard => 'Đã sao chép vào clipboard';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogVi extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ứng dụng đã thoát bất ngờ';
	@override String get description => 'Chúng tôi phát hiện phiên trước đã thoát không bình thường. Vui lòng xuất nhật ký chẩn đoán và gửi email cho nhà phát triển để giúp khắc phục sự cố.';
	@override String previousVersion({required Object version}) => 'Phiên bản trước: ${version}';
	@override String previousStart({required Object time}) => 'Lần khởi chạy trước: ${time}';
	@override String lastException({required Object message}) => 'Ngoại lệ gần nhất: ${message}';
	@override String get lastHangRecovered => 'Lần trước phát hiện giao diện bị treo và đã tự động khôi phục';
	@override String lastHangStalled({required Object stalledMs}) => 'Lần trước phát hiện giao diện có thể bị đơ, kéo dài khoảng ${stalledMs}ms';
	@override String get exportGuide => 'Vào Cài đặt > Chẩn đoán & Phản hồi > Xuất nhật ký.';
	@override String get privacyHint => 'Nhật ký có thể chứa dữ liệu riêng tư. Vui lòng xem lại trước khi gửi email tới:';
	@override String get issueWarning => 'Không đính kèm toàn bộ nhật ký công khai trong issue trên GitHub';
	@override String get acknowledge => 'Đã hiểu';
	@override String get supportEmailCopied => 'Đã sao chép email';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogVi extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nhập liên kết';
	@override String supportedLinksHint({required Object webName}) => 'Hỗ trợ nhận diện thông minh nhiều liên kết ${webName} và nhanh chóng chuyển tới trang tương ứng trong ứng dụng (phân tách liên kết với văn bản khác bằng dấu cách)';
	@override String inputHint({required Object webName}) => 'Vui lòng nhập liên kết ${webName}';
	@override String get validatorEmptyLink => 'Vui lòng nhập liên kết';
	@override String validatorNoIwaraLink({required Object webName}) => 'Không phát hiện liên kết ${webName} hợp lệ';
	@override String get multipleLinksDetected => 'Phát hiện nhiều liên kết, vui lòng chọn một:';
	@override String notIwaraLink({required Object webName}) => 'Không phải liên kết ${webName} hợp lệ';
	@override String linkParseError({required Object error}) => 'Lỗi phân tích liên kết: ${error}';
	@override String get unsupportedLinkDialogTitle => 'Liên kết không được hỗ trợ';
	@override String get unsupportedLinkDialogContent => 'Loại liên kết này không thể mở trực tiếp trong ứng dụng và cần truy cập bằng trình duyệt bên ngoài.\n\nBạn có muốn mở liên kết này trong trình duyệt không?';
	@override String get openInBrowser => 'Mở trong trình duyệt';
	@override String get confirmOpenBrowserDialogTitle => 'Xác nhận mở trình duyệt';
	@override String get confirmOpenBrowserDialogContent => 'Liên kết sau sắp được mở trong trình duyệt bên ngoài:';
	@override String get confirmContinueBrowserOpen => 'Bạn có chắc muốn tiếp tục?';
	@override String get browserOpenFailed => 'Mở liên kết thất bại';
	@override String get unsupportedLink => 'Liên kết không được hỗ trợ';
	@override String get cancel => 'Hủy';
	@override String get confirm => 'Mở trong trình duyệt';
}

// Path: log
class _TranslationsLogVi extends TranslationsLogEn {
	_TranslationsLogVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Quản lý nhật ký';
	@override String get enableLogPersistence => 'Bật lưu nhật ký lâu dài';
	@override String get enableLogPersistenceDesc => 'Lưu nhật ký vào cơ sở dữ liệu để phân tích';
	@override String get logDatabaseSizeLimit => 'Giới hạn kích thước cơ sở dữ liệu nhật ký';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Hiện tại: ${size}';
	@override String get exportCurrentLogs => 'Xuất nhật ký hiện tại';
	@override String get exportCurrentLogsDesc => 'Xuất nhật ký ứng dụng hiện tại để giúp nhà phát triển chẩn đoán vấn đề';
	@override String get exportHistoryLogs => 'Xuất nhật ký lịch sử';
	@override String get exportHistoryLogsDesc => 'Xuất nhật ký trong khoảng ngày được chỉ định';
	@override String get exportMergedLogs => 'Xuất nhật ký hợp nhất';
	@override String get exportMergedLogsDesc => 'Xuất nhật ký hợp nhất trong khoảng ngày được chỉ định';
	@override String get showLogStats => 'Hiện thống kê nhật ký';
	@override String get logExportSuccess => 'Xuất nhật ký thành công';
	@override String logExportFailed({required Object error}) => 'Xuất nhật ký thất bại: ${error}';
	@override String get showLogStatsDesc => 'Xem thống kê các loại nhật ký khác nhau';
	@override String logExtractFailed({required Object error}) => 'Lấy thống kê nhật ký thất bại: ${error}';
	@override String get clearAllLogs => 'Xóa toàn bộ nhật ký';
	@override String get clearAllLogsDesc => 'Xóa toàn bộ dữ liệu nhật ký';
	@override String get confirmClearAllLogs => 'Xác nhận xóa';
	@override String get confirmClearAllLogsDesc => 'Bạn có chắc muốn xóa toàn bộ dữ liệu nhật ký? Thao tác này không thể hoàn tác.';
	@override String get clearAllLogsSuccess => 'Đã xóa nhật ký thành công';
	@override String clearAllLogsFailed({required Object error}) => 'Xóa nhật ký thất bại: ${error}';
	@override String get unableToGetLogSizeInfo => 'Không thể lấy thông tin kích thước nhật ký';
	@override String get currentLogSize => 'Kích thước nhật ký hiện tại:';
	@override String get logCount => 'Số nhật ký:';
	@override String get logCountUnit => 'nhật ký';
	@override String get logSizeLimit => 'Giới hạn kích thước nhật ký:';
	@override String get usageRate => 'Tỉ lệ sử dụng:';
	@override String get exceedLimit => 'Vượt hạn mức';
	@override String get remaining => 'Còn lại';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Kích thước nhật ký hiện tại đã vượt hạn mức, vui lòng dọn nhật ký cũ hoặc tăng giới hạn kích thước nhật ký';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Kích thước nhật ký hiện tại gần vượt hạn mức, vui lòng dọn nhật ký cũ';
	@override String get cleaningOldLogs => 'Đang dọn nhật ký cũ...';
	@override String get logCleaningCompleted => 'Đã dọn nhật ký xong';
	@override String get logCleaningProcessMayNotBeCompleted => 'Quá trình dọn nhật ký có thể chưa hoàn tất';
	@override String get cleanExceededLogs => 'Dọn nhật ký vượt hạn mức';
	@override String get noLogsToExport => 'Không có nhật ký để xuất';
	@override String get exportingLogs => 'Đang xuất nhật ký...';
	@override String get noHistoryLogsToExport => 'Không có nhật ký lịch sử để xuất, vui lòng dùng ứng dụng một lúc trước';
	@override String get selectLogDate => 'Chọn ngày nhật ký';
	@override String get today => 'Hôm nay';
	@override String get selectMergeRange => 'Chọn khoảng hợp nhất';
	@override String get selectMergeRangeHint => 'Vui lòng chọn khoảng thời gian nhật ký cần hợp nhất';
	@override String selectMergeRangeDays({required Object days}) => '${days} ngày gần đây';
	@override String get logStats => 'Thống kê nhật ký';
	@override String todayLogs({required Object count}) => 'Nhật ký hôm nay: ${count} nhật ký';
	@override String recent7DaysLogs({required Object count}) => 'Nhật ký 7 ngày gần đây: ${count} nhật ký';
	@override String totalLogs({required Object count}) => 'Tổng nhật ký: ${count} nhật ký';
	@override String get setLogDatabaseSizeLimit => 'Đặt giới hạn kích thước cơ sở dữ liệu nhật ký';
	@override String currentLogSizeWithSize({required Object size}) => 'Kích thước nhật ký hiện tại: ${size}';
	@override String get warning => 'Cảnh báo';
	@override String newSizeLimit({required Object size}) => 'Giới hạn kích thước mới: ${size}';
	@override String get confirmToContinue => 'Xác nhận để tiếp tục';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Đã đặt giới hạn kích thước nhật ký thành ${size}';
}

// Path: emoji
class _TranslationsEmojiVi extends TranslationsEmojiEn {
	_TranslationsEmojiVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get recentlyUsed => 'Gần đây';
	@override String insertedCount({required Object count}) => 'Đã chèn ${count}';
	@override String get name => 'Biểu tượng cảm xúc';
	@override String get size => 'Kích thước';
	@override String get small => 'Nhỏ';
	@override String get medium => 'Vừa';
	@override String get large => 'Lớn';
	@override String get extraLarge => 'Rất lớn';
	@override String get copyEmojiLinkSuccess => 'Đã sao chép liên kết biểu tượng cảm xúc';
	@override String get preview => 'Xem trước biểu tượng cảm xúc';
	@override String get library => 'Thư viện biểu tượng cảm xúc';
	@override String get noEmojis => 'Không có biểu tượng cảm xúc';
	@override String get clickToAddEmojis => 'Nhấn nút ở góc trên bên phải để thêm biểu tượng cảm xúc';
	@override String get addEmojis => 'Thêm biểu tượng cảm xúc';
	@override String get imagePreview => 'Xem trước ảnh';
	@override String get imageLoadFailed => 'Tải ảnh thất bại';
	@override String get loading => 'Đang tải...';
	@override String get delete => 'Xóa';
	@override String get close => 'Đóng';
	@override String get deleteImage => 'Xóa ảnh';
	@override String get confirmDeleteImage => 'Bạn có chắc muốn xóa ảnh này?';
	@override String get cancel => 'Hủy';
	@override String get batchDelete => 'Xóa hàng loạt';
	@override String confirmBatchDelete({required Object count}) => 'Bạn có chắc muốn xóa ${count} ảnh đã chọn? Thao tác này không thể hoàn tác.';
	@override String get deleteSuccess => 'Đã xóa thành công';
	@override String get addImage => 'Thêm ảnh';
	@override String get addImageByUrl => 'Thêm bằng URL';
	@override String get addImageUrl => 'Thêm URL ảnh';
	@override String get imageUrl => 'URL ảnh';
	@override String get enterImageUrl => 'Vui lòng nhập URL ảnh';
	@override String get add => 'Thêm';
	@override String get batchImport => 'Nhập hàng loạt';
	@override String get enterJsonUrlArray => 'Vui lòng nhập mảng URL định dạng JSON:';
	@override String get formatExample => 'Ví dụ định dạng:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Vui lòng dán mảng URL định dạng JSON';
	@override String get import => 'Nhập';
	@override String importSuccess({required Object count}) => 'Đã nhập thành công ${count} ảnh';
	@override String get jsonFormatError => 'Lỗi định dạng JSON, vui lòng kiểm tra nội dung nhập';
	@override String get createGroup => 'Tạo nhóm biểu tượng cảm xúc';
	@override String get groupName => 'Tên nhóm';
	@override String get enterGroupName => 'Vui lòng nhập tên nhóm';
	@override String get create => 'Tạo';
	@override String get editGroupName => 'Chỉnh sửa tên nhóm';
	@override String get save => 'Lưu';
	@override String get deleteGroup => 'Xóa nhóm';
	@override String get confirmDeleteGroup => 'Bạn có chắc muốn xóa nhóm biểu tượng cảm xúc này? Tất cả ảnh trong nhóm cũng sẽ bị xóa.';
	@override String imageCount({required Object count}) => '${count} ảnh';
	@override String get selectEmoji => 'Chọn biểu tượng cảm xúc';
	@override String get noEmojisInGroup => 'Không có biểu tượng cảm xúc trong nhóm này';
	@override String get goToSettingsToAddEmojis => 'Vào cài đặt để thêm biểu tượng cảm xúc';
	@override String get emojiManagement => 'Quản lý biểu tượng cảm xúc';
	@override String get manageEmojiGroupsAndImages => 'Quản lý nhóm và ảnh biểu tượng cảm xúc';
	@override String get uploadLocalImages => 'Tải ảnh cục bộ lên';
	@override String get uploadingImages => 'Đang tải ảnh lên';
	@override String uploadingImagesProgress({required Object count}) => 'Đang tải lên ${count} ảnh, vui lòng đợi...';
	@override String get doNotCloseDialog => 'Vui lòng không đóng hộp thoại này';
	@override String uploadSuccess({required Object count}) => 'Đã tải lên thành công ${count} ảnh';
	@override String uploadFailed({required Object count}) => 'Thất bại ${count}';
	@override String get uploadFailedMessage => 'Tải ảnh lên thất bại, vui lòng kiểm tra kết nối mạng hoặc định dạng tệp';
	@override String uploadErrorMessage({required Object error}) => 'Đã xảy ra lỗi trong khi tải lên: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterVi extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Chọn trường';
	@override String get add => 'Thêm';
	@override String get clear => 'Xóa';
	@override String get clearAll => 'Xóa tất cả';
	@override String get generatedQuery => 'Truy vấn đã tạo';
	@override String get copyToClipboard => 'Sao chép vào bộ nhớ tạm';
	@override String get copied => 'Đã sao chép';
	@override String filterCount({required Object count}) => '${count} bộ lọc';
	@override String get filterSettings => 'Cài đặt bộ lọc';
	@override String get field => 'Trường';
	@override String get operator => 'Toán tử';
	@override String get language => 'Ngôn ngữ';
	@override String get value => 'Giá trị';
	@override String get dateRange => 'Khoảng ngày';
	@override String get numberRange => 'Khoảng số';
	@override String get from => 'Từ';
	@override String get to => 'Đến';
	@override String get date => 'Ngày';
	@override String get number => 'Số';
	@override String get boolean => 'Boolean';
	@override String get tags => 'Thẻ';
	@override String get select => 'Chọn';
	@override String get clickToSelectDate => 'Nhấn để chọn ngày';
	@override String get pleaseEnterValidNumber => 'Vui lòng nhập số hợp lệ';
	@override String get pleaseEnterValidDate => 'Vui lòng nhập định dạng ngày hợp lệ (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => 'Giá trị bắt đầu phải nhỏ hơn giá trị kết thúc';
	@override String get startDateMustBeBeforeEndDate => 'Ngày bắt đầu phải trước ngày kết thúc';
	@override String get pleaseFillStartValue => 'Vui lòng nhập giá trị bắt đầu';
	@override String get pleaseFillEndValue => 'Vui lòng nhập giá trị kết thúc';
	@override String get rangeValueFormatError => 'Lỗi định dạng giá trị khoảng';
	@override String get contains => 'Chứa';
	@override String get equals => 'Bằng';
	@override String get notEquals => 'Không bằng';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Khoảng';
	@override String get kIn => 'Chứa bất kỳ';
	@override String get notIn => 'Không chứa bất kỳ';
	@override String get username => 'Tên người dùng';
	@override String get nickname => 'Biệt danh';
	@override String get registrationDate => 'Ngày đăng ký';
	@override String get description => 'Mô tả';
	@override String get title => 'Tiêu đề';
	@override String get body => 'Nội dung';
	@override String get author => 'Tác giả';
	@override String get publishDate => 'Ngày đăng';
	@override String get private => 'Riêng tư';
	@override String get duration => 'Thời lượng (giây)';
	@override String get likes => 'Lượt thích';
	@override String get views => 'Lượt xem';
	@override String get comments => 'Bình luận';
	@override String get rating => 'Xếp hạng';
	@override String get imageCount => 'Số hình ảnh';
	@override String get videoCount => 'Số video';
	@override String get createDate => 'Ngày tạo';
	@override String get content => 'Nội dung';
	@override String get all => 'Tất cả';
	@override String get adult => 'Người lớn';
	@override String get general => 'Chung';
	@override String get yes => 'Có';
	@override String get no => 'Không';
	@override String get users => 'Người dùng';
	@override String get videos => 'Video';
	@override String get images => 'Hình ảnh';
	@override String get posts => 'Bài viết';
	@override String get forumThreads => 'Chủ đề diễn đàn';
	@override String get forumPosts => 'Bài viết diễn đàn';
	@override String get playlists => 'Danh sách phát';
	@override late final _TranslationsSearchFilterSortTypesVi sortTypes = _TranslationsSearchFilterSortTypesVi._(_root);
	@override String get drawerSubtitle => 'Thay đổi được áp dụng ngay';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupVi extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeVi welcome = _TranslationsFirstTimeSetupWelcomeVi._(_root);
	@override late final _TranslationsFirstTimeSetupBasicVi basic = _TranslationsFirstTimeSetupBasicVi._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkVi network = _TranslationsFirstTimeSetupNetworkVi._(_root);
	@override late final _TranslationsFirstTimeSetupThemeVi theme = _TranslationsFirstTimeSetupThemeVi._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerVi player = _TranslationsFirstTimeSetupPlayerVi._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialVi spatial = _TranslationsFirstTimeSetupSpatialVi._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionVi completion = _TranslationsFirstTimeSetupCompletionVi._(_root);
	@override late final _TranslationsFirstTimeSetupCommonVi common = _TranslationsFirstTimeSetupCommonVi._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperVi extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Đã phát hiện proxy hệ thống';
	@override String get copied => 'Đã sao chép';
	@override String get copy => 'Sao chép';
}

// Path: tagSelector
class _TranslationsTagSelectorVi extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Chọn thẻ';
	@override String get clickToSelectTags => 'Nhấn để chọn thẻ';
	@override String get addTag => 'Thêm thẻ';
	@override String get removeTag => 'Bỏ thẻ';
	@override String get deleteTag => 'Xóa thẻ';
	@override String get usageInstructions => 'Trước tiên thêm thẻ, sau đó nhấn để chọn từ các thẻ hiện có';
	@override String get usageInstructionsTooltip => 'Hướng dẫn sử dụng';
	@override String get addTagTooltip => 'Thêm thẻ';
	@override String get removeTagTooltip => 'Bỏ thẻ';
	@override String get cancelSelection => 'Hủy lựa chọn';
	@override String get selectAll => 'Chọn tất cả';
	@override String get cancelSelectAll => 'Hủy chọn tất cả';
	@override String get delete => 'Xóa';
}

// Path: anime4k
class _TranslationsAnime4kVi extends TranslationsAnime4kEn {
	_TranslationsAnime4kVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Nâng tỉ lệ và khử nhiễu video theo thời gian thực, nâng cao chất lượng video hoạt hình';
	@override String get settings => 'Cài đặt Anime4K';
	@override String get preset => 'Cấu hình Anime4K';
	@override String get disable => 'Tắt Anime4K';
	@override String get disableDescription => 'Tắt hiệu ứng nâng cao chất lượng video';
	@override String get highQualityPresets => 'Cấu hình chất lượng cao';
	@override String get fastPresets => 'Cấu hình nhanh';
	@override String get litePresets => 'Cấu hình nhẹ';
	@override String get moreLitePresets => 'Cấu hình nhẹ hơn';
	@override String get customPresets => 'Cấu hình tùy chỉnh';
	@override late final _TranslationsAnime4kPresetGroupsVi presetGroups = _TranslationsAnime4kPresetGroupsVi._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsVi presetDescriptions = _TranslationsAnime4kPresetDescriptionsVi._(_root);
	@override late final _TranslationsAnime4kPresetNamesVi presetNames = _TranslationsAnime4kPresetNamesVi._(_root);
	@override String get performanceTip => '💡 Mẹo: chọn cấu hình phù hợp với hiệu năng thiết bị. Thiết bị cấu hình thấp nên dùng cấu hình nhẹ.';
	@override String get compatibilityTip => '⚠️ Một số GPU di động (ví dụ Kirin 980 / Mali-G76) không kết xuất được shader tùy chỉnh. Nếu hình ảnh chuyển đen trong khi âm thanh vẫn phát, hãy tắt Anime4K tại đây.';
	@override String get autoDisabledOnRenderFailure => 'GPU của thiết bị không kết xuất được shader Anime4K nên tính năng đã tự động tắt.';
}

// Path: siteMode
class _TranslationsSiteModeVi extends TranslationsSiteModeEn {
	_TranslationsSiteModeVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chế độ trang';
	@override String get mainSite => 'Main';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Hiện tại ${currentSite} · Nhấn để chuyển sang ${nextSite}';
	@override String get dialogTitle => 'Chuyển chế độ trang';
	@override String get dialogDescription => 'Việc chuyển đổi sẽ làm mới toàn bộ ứng dụng và đặt lại các danh sách cùng trạng thái trang đã tải trước đó.';
	@override String get chooseLinkTargetTitle => 'Chọn trang đích';
	@override String get chooseLinkTargetDescription => 'Liên kết này không bao gồm tên miền. Vui lòng chọn mở trong Main hay AI.';
	@override String get chooseLinkTargetHint => 'Sau khi mở, trang này và các yêu cầu chi tiết tiếp theo sẽ tiếp tục dùng trang đã chọn.';
	@override String get alreadyUsing => 'Bạn đang dùng chế độ trang này rồi.';
	@override String openInSite({required Object site}) => 'Mở trong ${site}';
	@override String confirmUsing({required Object site}) => 'Sau khi xác nhận, các yêu cầu tiếp theo sẽ dùng chế độ ${site}.';
	@override String switched({required Object site}) => 'Đã chuyển sang ${site}. Ứng dụng đã được làm mới.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigVi extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bộ lọc đã lưu';
	@override String get empty => 'Chưa có bộ lọc đã lưu';
	@override String get saveTooltip => 'Lưu bộ lọc hiện tại';
	@override String get namePromptTitle => 'Lưu bộ lọc';
	@override String get nameLabel => 'Tên';
	@override String get nameHint => 'Nhập tên';
	@override String get saveSuccess => 'Đã lưu bộ lọc';
	@override String get deleteSuccess => 'Đã xóa bộ lọc';
	@override String get addCurrent => 'Lưu bộ lọc hiện tại';
	@override String get reorderHint => 'Nhấn giữ và kéo để sắp xếp lại';
	@override String get rename => 'Đổi tên';
	@override String get unnamed => 'Chưa đặt tên';
	@override String get noConditions => 'Tất cả nội dung (không lọc)';
	@override String tagsCount({required Object count}) => '${count} thẻ';
}

// Path: savedSearch
class _TranslationsSavedSearchVi extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tìm kiếm đã lưu';
	@override String get empty => 'Chưa có tìm kiếm đã lưu';
	@override String get saveTooltip => 'Lưu tìm kiếm hiện tại';
	@override String get namePromptTitle => 'Lưu tìm kiếm';
	@override String get nameLabel => 'Tên';
	@override String get nameHint => 'Nhập tên';
	@override String get saveSuccess => 'Đã lưu tìm kiếm';
	@override String get deleteSuccess => 'Đã xóa tìm kiếm';
	@override String get addCurrent => 'Lưu tìm kiếm hiện tại';
	@override String get reorderHint => 'Nhấn giữ và kéo để sắp xếp lại';
	@override String get rename => 'Đổi tên';
	@override String get noKeyword => '(Không có từ khóa)';
	@override String filtersCount({required Object count}) => '${count} bộ lọc';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderVi extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Phát hiện danh sách thẻ chặn mặc định';
	@override String get content => 'Tài khoản của bạn vẫn đang dùng danh sách thẻ chặn mà trang web tự động áp dụng cho mọi tài khoản mới. Bạn có muốn xem lại và quản lý không?';
	@override String get goManage => 'Quản lý';
	@override String get dismiss => 'Để sau';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistVi extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hỗ trợ phân biệt màu';
	@override String get description => 'Hiệu chỉnh màu video cho người mắc chứng khó phân biệt màu, có thể dùng cùng Anime4K';
	@override String get galleryDescription => 'Hiệu chỉnh màu ảnh trong thư viện cho người mắc chứng khó phân biệt màu (độc lập với công tắc của trình phát)';
	@override String get galleryDescriptionSpatial => 'Hiệu chỉnh màu ảnh trong thư viện cho người mắc chứng khó phân biệt màu. Chỉ áp dụng cho trình xem 2D trong bảng này — ảnh trên màn hình không gian được kết xuất nguyên bản và không đi qua bộ lọc này';
	@override String get disable => 'Tắt';
	@override String get disableDescription => 'Không hiệu chỉnh màu';
	@override String get protanopia => 'Hỗ trợ màu đỏ (Protanopia)';
	@override String get protanopiaDescription => 'Dành cho người mù màu đỏ — khó phân biệt màu đỏ';
	@override String get deuteranopia => 'Hỗ trợ màu xanh lá (Deuteranopia)';
	@override String get deuteranopiaDescription => 'Dành cho người mù màu lục — khó phân biệt màu xanh lá';
	@override String get tritanopia => 'Hỗ trợ màu xanh dương (Tritanopia)';
	@override String get tritanopiaDescription => 'Dành cho người mù màu lam — khó phân biệt màu xanh dương và vàng';
	@override String appliedToast({required Object filterName}) => '${filterName} đã áp dụng, có hiệu lực ngay';
	@override String get disabledToast => 'Đã tắt hỗ trợ phân biệt màu';
}

// Path: externalPlayer
class _TranslationsExternalPlayerVi extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mở bằng ứng dụng khác';
	@override String get description => 'Chuyển video hiện tại sang trình phát khác trên thiết bị này, chẳng hạn Skybox hoặc Pigasus trên kính VR, hoặc MX Player và VLC trên điện thoại';
	@override String get openWithOtherApp => 'Chọn ứng dụng khác';
	@override String get openWithOtherAppDescription => 'Hiện bảng chọn của hệ thống và chọn trình phát để tiếp nhận';
	@override String get openWithSystemPlayer => 'Mở bằng trình phát mặc định';
	@override String get openWithSystemPlayerDescription => 'Chuyển cho ứng dụng video mặc định của hệ thống';
	@override String get copyLink => 'Sao chép liên kết video';
	@override String get copyLinkDescription => 'Dành cho trình phát chỉ có thể dán URL, chẳng hạn Skybox hoặc DeoVR';
	@override String get linkCopied => 'Đã sao chép liên kết video';
	@override String get sourceLocal => 'Tệp cục bộ';
	@override String get sourceOnline => 'Liên kết trực tiếp';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Liên kết trực tiếp · ${quality}';
	@override String get onlineLinkExpiryHint => 'Liên kết trực tiếp sẽ hết hạn nên trình phát ngoài có thể dừng giữa chừng. Tải xuống trước là cách đáng tin cậy hơn.';
	@override String get vrPlayerHint => 'Nếu trình phát VR của bạn không có trong bảng chọn, hãy dùng Sao chép liên kết video và dán vào trình phát đó.';
	@override String get noHandler => 'Không có ứng dụng nào trên thiết bị này mở được video';
	@override String handoffFailed({required Object message}) => 'Chuyển giao thất bại: ${message}';
	@override String get handoffFailedUnknown => 'Chuyển giao thất bại';
	@override String get sourceUnavailable => 'Không lấy được địa chỉ video hiện tại, vui lòng thử lại';
	@override String get localFileMissing => 'Tệp cục bộ không còn tồn tại';
	@override String get handedOff => 'Đã chuyển sang trình phát ngoài';
	@override String get desktopSectionTitle => 'Trình phát ngoài';
	@override String get managePlayers => 'Quản lý trình phát ngoài';
	@override String get managePlayersDescWindows => 'Các trình phát PCVR như HereSphere, DeoVR và Whirligig không phải ứng dụng mặc định của hệ thống. Hãy chỉ định tới tệp .exe của chúng để có thể chuyển video hiện tại ngay từ trình phát.';
	@override String get managePlayersDescMac => 'Chỉ định tới các trình phát như IINA, VLC hoặc mpv để có thể chuyển video hiện tại ngay từ trình phát.';
	@override String get managePlayersDescLinux => 'Chỉ định tới các trình phát như mpv, VLC hoặc Celluloid để có thể chuyển video hiện tại ngay từ trình phát.';
	@override String get pickExecutableHintWindows => 'Chọn tệp .exe chính trong thư mục cài đặt của trình phát, ví dụ HereSphere.exe hoặc vlc.exe. Lối tắt trên màn hình (.lnk) sẽ không hoạt động.';
	@override String get pickExecutableHintMac => 'Chọn tệp .app của trình phát trong thư mục Ứng dụng, ví dụ IINA.app — tệp thực thi thật bên trong sẽ được tự động định vị.';
	@override String get pickExecutableHintLinux => 'Chọn tệp thực thi của trình phát, ví dụ /usr/bin/mpv. Chạy lệnh which mpv sẽ cho biết vị trí của nó.';
	@override String emptyStateGuide({required Object examples}) => 'Sau khi cấu hình, nó sẽ xuất hiện như một mục riêng trong Mở bằng ứng dụng khác trên trang trình phát. Một số trình phát phổ biến: ${examples}';
	@override String get detectNothingFoundGuide => 'Không tìm thấy trình phát nào đã cài. Không thể phát hiện thư mục cài đặt tùy chỉnh và bản portable — hãy dùng Thêm trình phát để tự chỉ định.';
	@override String get detectNothingNew => 'Không tìm thấy trình phát mới; mọi thứ đã cài đều có trong danh sách';
	@override String get detectFailed => 'Phát hiện thất bại — hãy dùng Thêm trình phát để tự chỉ định';
	@override String get advancedOptions => 'Nâng cao';
	@override String get playerNameHint => 'Để trống để dùng tên tệp';
	@override String get executablePathRequired => 'Hãy chọn tệp thực thi của trình phát trước';
	@override String playerCount({required Object count}) => 'Đã cấu hình ${count}';
	@override String get noPlayerConfigured => 'Chưa cấu hình trình phát ngoài nào';
	@override String get autoDetect => 'Tự động phát hiện';
	@override String get detecting => 'Đang phát hiện…';
	@override String detectFound({required Object count}) => 'Đã tìm thấy ${count} trình phát';
	@override String get detectNothingFound => 'Không tìm thấy trình phát mới, hãy thêm thủ công';
	@override String get autoDetectedTag => 'đã phát hiện';
	@override String get addPlayer => 'Thêm trình phát';
	@override String get editPlayer => 'Chỉnh sửa trình phát';
	@override String get playerName => 'Tên';
	@override String get executablePath => 'Tệp thực thi';
	@override String get browse => 'Duyệt';
	@override String get argumentTemplate => 'Tham số khởi chạy';
	@override String get argumentTemplateHint => 'Dùng {input} cho đường dẫn hoặc URL video. Để trống để truyền nó làm tham số duy nhất.';
	@override String get nameAndPathRequired => 'Cần nhập cả tên và tệp thực thi';
	@override String get testLaunch => 'Thử khởi chạy';
	@override String get testLaunched => 'Đã khởi chạy trình phát';
	@override String get testFailed => 'Khởi chạy thất bại, hãy kiểm tra đường dẫn tệp thực thi';
	@override String get executableMissing => 'Không tìm thấy tệp thực thi';
	@override String openWithNamed({required Object name}) => 'Mở bằng ${name}';
	@override String get managePlayersEntry => 'Quản lý trình phát ngoài…';
}

// Path: watchLater
class _TranslationsWatchLaterVi extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Xem sau';
	@override String get addToWatchLater => 'Xem sau';
	@override String get removeFromWatchLater => 'Xóa khỏi Xem sau';
	@override String get addedToWatchLater => 'Đã thêm vào Xem sau';
	@override String get alreadyInWatchLater => 'Đã có trong Xem sau';
	@override String get removedFromWatchLater => 'Đã xóa khỏi Xem sau';
	@override String removedCount({required Object count}) => 'Đã xóa ${count} mục';
	@override String get viewWatchLaterList => 'Xem danh sách';
	@override String get addFailed => 'Thêm vào Xem sau thất bại';
	@override String get invalidItem => 'Không khả dụng';
	@override String get clearWatched => 'Xóa các mục đã xem';
	@override String watchedCleared({required Object count}) => 'Đã xóa ${count} mục đã xem';
	@override String get noWatchedToClear => 'Không có mục đã xem nào để xóa';
	@override String get emptyVideo => 'Chưa có video nào trong Xem sau';
	@override String get emptyGallery => 'Chưa có thư viện nào trong Xem sau';
	@override String get filterAll => 'Tất cả';
	@override String get filterUnwatched => 'Chưa xem';
	@override String get sortRecentlyAdded => 'Thêm gần đây';
	@override String get sortEarliestAdded => 'Thêm sớm nhất';
	@override String get watched => 'Đã xem';
	@override String get playlistLoadFailed => 'Tải danh sách phát thất bại';
	@override String get noPlaylists => 'Chưa có danh sách phát nào';
	@override String get undo => 'Hoàn tác';
	@override String get clearWatchedConfirm => 'Xóa mọi thứ bạn đã xem trong tab này? Thao tác này không thể hoàn tác.';
	@override String get emptyUnwatchedVideo => 'Không còn gì để xem ở đây';
	@override String get emptyUnwatchedGallery => 'Không còn gì để xem ở đây';
	@override String get queueLoadFailed => 'Tải thất bại, nhấn để thử lại';
}

// Path: mediaMenu
class _TranslationsMediaMenuVi extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get like => 'Thích';
	@override String get unlike => 'Bỏ thích';
	@override String get viewAuthor => 'Xem tác giả';
	@override String inFolders({required Object count}) => '${count} thư mục';
	@override String inPlaylists({required Object count}) => '${count} danh sách phát';
	@override String get downloaded => 'Đã tải xuống';
}

// Path: mediaPreview
class _TranslationsMediaPreviewVi extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Xem trước';
	@override String get openDetail => 'Mở';
	@override String get moreActions => 'Thao tác khác';
	@override String get previousImage => 'Ảnh trước';
	@override String get nextImage => 'Ảnh tiếp theo';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueVi extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} hình ảnh';
	@override String get upNext => 'Tiếp theo';
	@override String get sourceTab => 'Nguồn';
	@override String get emptyQueue => 'Không có gì có thể phát trong hàng đợi này';
	@override String get emptyGalleryQueue => 'Không có thư viện nào trong hàng đợi này';
	@override String get nowPlaying => 'Đang phát';
	@override String get myPlaylists => 'Danh sách phát của tôi';
	@override String get authorPlaylists => 'Danh sách phát của tác giả';
	@override String get openQueue => 'Tiếp theo';
	@override String get continueInQueue => 'Tiếp tục phát từ hàng đợi hiện tại';
	@override String get continueInQueueSubtitle => 'Tự động phát mục tiếp theo; tắt "lặp lại khi kết thúc"';
	@override String get repeatDisabledByQueue => 'Bị tắt khi bật "tiếp tục phát từ hàng đợi hiện tại"';
	@override String get playNext => 'Phát tiếp theo';
	@override String get queueEnded => 'Đây là mục cuối cùng trong hàng đợi';
	@override String get playNextHint => 'Nhấn để phát mục tiếp theo, nhấn giữ để mở Tiếp theo';
	@override String get authorVideos => 'Video của tác giả';
	@override String get authorGalleries => 'Thư viện của tác giả';
	@override String get favoriteFolders => 'Thư mục yêu thích';
	@override String get localFiles => 'Trên thiết bị này';
	@override String get currentFolder => 'Thư mục của tệp này';
	@override String get playThisFolder => 'Xem hàng đợi video của thư mục này';
	@override String get browseThisFolder => 'Xem hàng đợi thư viện của thư mục này';
	@override String get downloads => 'Đã tải xuống';
	@override String get otherPlaylists => 'Danh sách phát của người dùng khác';
	@override String get nothingHere => 'Không có gì ở đây';
}

// Path: vrFormat
class _TranslationsVrFormatVi extends TranslationsVrFormatEn {
	_TranslationsVrFormatVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Phát trong trình phát không gian';
	@override String get handingOff => 'Đang chuyển sang không gian…';
	@override String get title => 'Chế độ phát';
	@override String get spatialSectionTitle => 'Phát không gian';
	@override String get spatialSectionDesc => 'Trên tai nghe, video không được vẽ trong bảng này — trình phát không gian đặt nó lên một màn hình trong phòng.';
	@override String get spatialPanelEntry => 'Bảng điều khiển không gian';
	@override String get spatialPanelEntryDesc => 'Khoảng cách, kích thước và độ cong màn hình, môi trường nền, cùng tốc độ, lặp lại và tự động ẩn đều nằm trong bảng điều khiển không gian.';
	@override String get spatialGuideEntry => 'Hướng dẫn điều khiển tai nghe';
	@override String get spatialGuideEntryDesc => 'Nút bộ điều khiển, nắm màn hình, tua bằng cần gạt và lật trang';
	@override String get spatialFlatOmitted => 'Cử chỉ cảm ứng, nâng cao hình ảnh và tham số âm thanh/video chỉ áp dụng cho trình phát 2D; trình phát không gian chạy trên một engine khác nên không được liệt kê ở đây.';
	@override String get spatialGallerySectionTitle => 'Thư viện không gian';
	@override String get spatialGalleryPanelDesc => 'Khoảng thời gian trình chiếu, lặp một clip và độ cong màn hình đều được điều chỉnh trong bảng điều khiển không gian.';
	@override String get autoEnterGallery => 'Mở hình ảnh thư viện trong thư viện không gian';
	@override String get autoEnterGalleryDesc => 'Trên Quest, nhấn vào một hình ảnh sẽ mở toàn bộ thư viện trên màn hình nổi với dải phim, trình chiếu và lật trang bằng bộ điều khiển thay vì trình xem trong bảng này.';
	@override String get panelSettings => 'Bảng và nền';
	@override String get panelSettingsDesc => 'Bảng ứng dụng này đặt cách bao xa, và phòng của bạn hiện ra phía sau bao nhiêu';
	@override String get panelDistance => 'Khoảng cách bảng';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Đặt lại vị trí';
	@override String get panelResetBackground => 'Đặt lại mặc định';
	@override String get panelBackground => 'Độ trong suốt nền';
	@override String get panelBackgroundHint => '0%: môi trường xung quanh màu đen · 100%: phòng thật của bạn, có ánh sáng xung quanh';
	@override String get panelUnavailable => 'Bảng hiện không ở đúng vị trí — vui lòng thử lại sau giây lát';
	@override String get desc => 'Chọn hình học để phát video này. Trang web không cung cấp thông tin này, nên tính năng tự động phát hiện chỉ chọn một điểm khởi đầu — lựa chọn của bạn sẽ được ưu tiên.';
	@override String get sectionFlat => 'Phẳng';
	@override String get sectionStereo => '3D phẳng';
	@override String get sectionPanorama => 'Toàn cảnh VR';
	@override String get flat => 'Video thường';
	@override String get flatDesc => 'Phát nguyên bản, không ánh xạ lại';
	@override String get flatSideBySide => '3D cạnh nhau';
	@override String get flatSideBySideDesc => 'Mỗi mắt một nửa, trái và phải; hiển thị mắt trái và khôi phục tỉ lệ khung hình';
	@override String get flatTopBottom => '3D trên dưới';
	@override String get flatTopBottomDesc => 'Mỗi mắt một nửa, trên và dưới; hiển thị nửa trên và khôi phục tỉ lệ khung hình';
	@override String get vr180SideBySide => 'VR180 cạnh nhau';
	@override String get vr180SideBySideDesc => 'Toàn cảnh bán cầu với cả hai mắt — nguồn VR phổ biến nhất';
	@override String get vr180Mono => 'VR180 mono';
	@override String get vr180MonoDesc => 'Toàn cảnh bán cầu, một mắt mỗi khung hình';
	@override String get vr360Mono => 'VR360 mono';
	@override String get vr360MonoDesc => 'Toàn cảnh bao quanh đầy đủ, một mắt mỗi khung hình';
	@override String get vr360TopBottom => 'VR360 trên dưới';
	@override String get vr360TopBottomDesc => 'Toàn cảnh bao quanh đầy đủ với cả hai mắt xếp chồng';
	@override String get resetView => 'Đặt lại tầm nhìn';
	@override String get resetViewDesc => 'Đưa hướng nhìn và trường nhìn về phía trước';
	@override String get resetToAuto => 'Quay lại tự động phát hiện';
	@override String get resetToAutoDesc => 'Quên lựa chọn thủ công cho video này và để tính năng phát hiện quyết định lại';
	@override String get manualBadge => 'Đặt thủ công';
	@override String get panoramaHint => 'Kéo hình để nhìn quanh, chụm để thay đổi trường nhìn';
	@override String get panoramaGestureNotice => 'Trong khi nhìn quanh, kéo sẽ xoay tầm nhìn — hãy dùng thanh tiến trình để tua';
	@override String get shaderUnsupported => 'Thiết bị này không thể hiển thị toàn cảnh trực tiếp; thay vào đó hiển thị một mắt';
	@override String get handoffTooltip => 'Phát theo cách khác';
	@override String get suggestedBadge => 'Đề xuất';
	@override String suggestedEntryDesc({required Object format}) => 'Có vẻ là ${format} — nhấn để chuyển';
	@override String suggestionTitle({required Object format}) => 'Đây có thể là video VR (${format})';
	@override String get suggestionTitleShort => 'Đây có thể là video VR';
	@override String get suggestionAction => 'Phát dạng VR';
	@override String get suggestionDismiss => 'Bỏ qua';
}

// Path: localMedia
class _TranslationsLocalMediaVi extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseVi browse = _TranslationsLocalMediaBrowseVi._(_root);
	@override String get tabFolders => 'Thư mục';
	@override String get tabFavoriteVideos => 'Yêu thích';
	@override String get tabAllVideos => 'Tất cả video';
	@override String get tabAllImages => 'Tất cả ảnh';
	@override String get tabDownloadedVideos => 'Video đã tải';
	@override String get tabDownloadedGalleries => 'Thư viện đã tải';
	@override String get title => 'Trên thiết bị này';
	@override String get sourceOnline => 'Iwara trực tuyến';
	@override String get manageSources => 'Quản lý nguồn';
	@override String get moveToCategory => 'Chuyển vào danh mục';
	@override String get manageCategories => 'Quản lý danh mục';
	@override String get suggestedFolders => 'Thư mục có video';
	@override String get sortRecentlyAdded => 'Thêm gần đây';
	@override String get sortRecentlyPlayed => 'Phát gần đây';
	@override String get sortName => 'Tên';
	@override String get sortDuration => 'Thời lượng';
	@override String get sortSize => 'Kích thước';
	@override String get sortFolder => 'Thư mục';
	@override String get sortRecentlyModified => 'Sửa đổi gần đây';
	@override String get sortCount => 'Số lượng';
	@override String folderCardItemCount({required Object count}) => '${count} ảnh';
	@override String get downloadsSource => 'Đã tải xuống';
	@override String get builtInSourceHint => 'Mục Đã tải xuống được quản lý tự động';
	@override String get filterByCategory => 'Lọc theo danh mục';
	@override String get longPressToCategorize => 'Nhấn giữ để chuyển vào danh mục';
	@override String get uncategorized => 'Chưa phân loại';
	@override String get setCategoryFailed => 'Không thể đặt danh mục';
	@override String get categoryUpdated => 'Đã cập nhật danh mục';
	@override String get addFolder => 'Thêm thư mục';
	@override String get addDeviceVideos => 'Quét video trên thiết bị';
	@override String get mediaStoreSourceName => 'Video trên thiết bị';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsVi itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsVi._(_root);
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
	@override late final _TranslationsLocalMediaMissingVi missing = _TranslationsLocalMediaMissingVi._(_root);
	@override late final _TranslationsLocalMediaWebdavVi webdav = _TranslationsLocalMediaWebdavVi._(_root);
	@override String get mediaStoreUnavailable => 'Chỉ mục media của thiết bị chỉ khả dụng trên Android';
	@override String get mediaStorePermissionDenied => 'Quyền truy cập video chưa được cấp';
	@override String get rescan => 'Quét lại';
	@override String scanning({required Object count}) => 'Đang quét… đã tìm thấy ${count}';
	@override String scanFailed({required Object reason}) => 'Quét thất bại: ${reason}';
	@override String scanTruncated({required Object count}) => 'Thư mục đó rất lớn — chỉ ${count} tệp đầu tiên được thêm.';
	@override String sourceOverlaps({required Object name}) => 'Đã được bao phủ bởi thư mục "${name}"';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '"${name}" nằm trong "${source}", nên đã được thêm vào thư mục ghim';
	@override String alreadyPinnedFolder({required Object name}) => '"${name}" đã có trong thư mục ghim';
	@override String sourceAlreadyAdded({required Object name}) => '"${name}" đã được thêm rồi';
	@override String sourceContainsExisting({required Object name}) => 'Đã chứa thư mục đã thêm "${name}"; chưa hỗ trợ thêm thư mục cha của nó';
	@override String get addSourceFailed => 'Không thể thêm thư mục đó';
	@override String get fileMissing => 'Tệp đó không còn trên đĩa';
	@override String get permissionDenied => 'Chưa được cấp quyền truy cập tệp · nhấn để cấp';
	@override String get noVideosFound => 'Không có video trong thư mục này';
	@override String get emptyTitle => 'Thêm thư mục để xem các video đã có trên thiết bị này';
	@override String get emptyPrivacyNote => 'Tệp chỉ được đọc trên thiết bị này. Không có gì được tải lên.';
	@override String removeSourceTitle({required Object name}) => 'Xóa "${name}"?';
	@override String get removeSourceBody => 'Các tệp vẫn còn trên đĩa. Chỉ mục thư viện này bị xóa.';
	@override String get remove => 'Xóa';
	@override String get removeFolder => 'Xóa thư mục';
	@override String get removeFolderSelectTitle => 'Chọn thư mục để xóa';
	@override String get longPressToRemove => 'Nhấn giữ để xóa thư mục này';
	@override String get clearProgress => 'Xóa lịch sử xem cục bộ';
	@override String clearProgressCount({required Object count}) => '${count} mục';
	@override String get clearProgressEmpty => 'Chưa có lịch sử xem cục bộ';
	@override String get clearProgressTitle => 'Xóa lịch sử xem cục bộ?';
	@override String get clearProgressBody => 'Chỉ vị trí phát và dấu đã xem bị xóa. Các tệp và thư mục của bạn vẫn giữ nguyên.';
	@override String clearProgressDone({required Object count}) => 'Đã xóa ${count} mục lịch sử xem cục bộ';
	@override String get clearAction => 'Xóa';
	@override String get iosManualRescanNotice => 'iOS không tự động phát hiện tệp mới. Cần quét lại thủ công sau khi thêm hoặc xóa tệp.';
}

// Path: historyPage
class _TranslationsHistoryPageVi extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Xóa khỏi lịch sử';
	@override String get removed => 'Đã xóa khỏi lịch sử';
	@override String watchedTo({required Object time}) => 'Đã xem đến ${time}';
	@override String get finished => 'Đã xem xong';
	@override String clearTabTitle({required Object tab}) => 'Xóa "${tab}"';
	@override String clearTabConfirm({required Object tab}) => 'Toàn bộ lịch sử trong "${tab}" sẽ bị xóa, kèm tiến độ xem của các video đó. Không thể hoàn tác.';
	@override String get rangeByLastViewed => 'Lọc theo thời gian xem gần nhất';
}

// Path: ai
class _TranslationsAiVi extends TranslationsAiEn {
	_TranslationsAiVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI';
	@override String get providers => 'Nhà cung cấp';
	@override String get providersHint => 'Thêm một hoặc nhiều nhà cung cấp AI, sau đó chọn nhà cung cấp cho từng tính năng.';
	@override String get addProvider => 'Thêm nhà cung cấp';
	@override String get noProviders => 'Chưa có nhà cung cấp nào. Hãy thêm để bật tính năng dịch, tìm kiếm và chữ ký bằng AI.';
	@override String get pickPreset => 'Chọn nhà cung cấp';
	@override String get providerNameLabel => 'Tên';
	@override String get apiKey => 'Khóa API';
	@override String get baseUrl => 'Điểm cuối';
	@override String get model => 'Mô hình';
	@override String get modelPick => 'Chọn mô hình';
	@override String get modelEmpty => 'Không thể tải danh sách mô hình — bạn cũng có thể nhập trực tiếp tên mô hình.';
	@override String get advanced => 'Nâng cao';
	@override String get reasoning => 'Mô hình suy luận';
	@override String get streaming => 'Đầu ra dạng luồng';
	@override String get structuredOutput => 'Đầu ra có cấu trúc';
	@override String get structuredOutputHint => 'Cần thiết cho tìm kiếm AI. Nhiều endpoint trung gian không hỗ trợ — hãy tắt nếu tìm kiếm liên tục thất bại.';
	@override String get temperature => 'Nhiệt độ';
	@override String get maxTokens => 'Token tối đa';
	@override String get maxTokensAuto => 'Tự động (giới hạn mô hình)';
	@override String get test => 'Kiểm tra';
	@override String get testOk => 'Kết nối thành công';
	@override String get deleteProvider => 'Xóa nhà cung cấp';
	@override String get usedBy => 'Đang dùng cho';
	@override String get taskBindings => 'Phân bổ tính năng';
	@override String get taskBindingsHint => 'Mỗi tính năng có thể dùng một nhà cung cấp khác nhau.';
	@override String get taskTranslate => 'Dịch thuật';
	@override String get taskSearch => 'Tìm kiếm AI';
	@override String get taskSignature => 'Chữ ký';
	@override String get taskAuto => 'Tự động';
	@override String get usage => 'Mức sử dụng';
	@override String get usageCalls => 'Lượt gọi';
	@override String get usageTokens => 'Số token';
	@override String get usageFailures => 'Thất bại';
	@override String get usageReset => 'Xóa thống kê';
	@override String get usageEmpty => 'Chưa có lượt gọi nào';
	@override String get openSettings => 'Mở cài đặt AI';
	@override String get notConfigured => 'Chưa định cấu hình';
	@override String get searchTitle => 'Tìm kiếm AI';
	@override String get searchHint => 'Mô tả nội dung bạn muốn tìm; AI sẽ điền các từ khóa tìm kiếm và bộ lọc.';
	@override String get searchPlaceholder => 'vd: MMD mới nhất có hơn 10k lượt xem';
	@override String get searchApply => 'Tìm kiếm bằng các điều kiện này';
	@override String get searchEmpty => 'Không thể tạo từ khóa tìm kiếm từ mô tả này. Hãy thử diễn đạt theo cách khác.';
	@override String get searchFilters => 'Bộ lọc';
	@override String searchSwitchSegment({required Object segment}) => 'Chuyển sang ${segment}';
	@override String get searchGenerating => 'Đang suy nghĩ…';
	@override String get searchRetrying => 'Lần trước thất bại, đang thử lại…';
	@override String searchRetryReason({required Object reason}) => 'Lý do: ${reason}';
	@override String get searchStageWaiting => 'Đã gửi yêu cầu, đang chờ phản hồi…';
	@override String get searchStageThinkingNext => 'Đang nghĩ bước tiếp theo…';
	@override String get searchStageReasoning => 'Đang suy luận…';
	@override String get searchStageTool => 'Đang thử tìm kiếm…';
	@override String searchStageDrafting({required Object chars}) => 'Đang viết câu trả lời · ${chars} ký tự';
	@override String get searchStageParsing => 'Đang sắp xếp kết quả…';
	@override String get searchThinking => 'Quá trình suy luận';
	@override String get searchKeywordNeedsQuotes => 'Từ khoá này không đặt trong dấu ngoặc kép nên Iwara khớp lỏng lẻo — với kiểu sắp xếp này trang đầu phần lớn sẽ không liên quan. Hãy đặt nó trong "dấu ngoặc kép", hoặc sắp xếp theo độ liên quan.';
	@override String searchToolProbing({required Object query}) => 'Thử tìm ${query}';
	@override String searchToolFound({required Object count, required Object titles}) => '${count} kết quả · ${titles}';
	@override String searchToolFailed({required Object reason}) => 'Không chạy được: ${reason}';
	@override String searchFiltersDropped({required Object count}) => 'Đã bỏ ${count} bộ lọc không có trong mục này.';
}

// Path: common.pagination
class _TranslationsCommonPaginationVi extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Tổng ${num} mục';
	@override String get jumpToPage => 'Chuyển tới trang';
	@override String pleaseEnterPageNumber({required Object max}) => 'Vui lòng nhập số trang (1-${max})';
	@override String get pageNumber => 'Số trang';
	@override String get jump => 'Chuyển';
	@override String invalidPageNumber({required Object max}) => 'Vui lòng nhập số trang hợp lệ (1-${max})';
	@override String get invalidInput => 'Vui lòng nhập số trang hợp lệ';
	@override String get waterfall => 'Thác nước';
	@override String get pagination => 'Phân trang';
}

// Path: errors.network
class _TranslationsErrorsNetworkVi extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Lỗi mạng - ';
	@override String get failedToConnectToServer => 'Kết nối tới máy chủ thất bại';
	@override String get serverNotAvailable => 'Máy chủ không khả dụng';
	@override String get requestTimeout => 'Yêu cầu quá thời gian';
	@override String get unexpectedError => 'Lỗi không mong đợi';
	@override String get invalidResponse => 'Phản hồi không hợp lệ';
	@override String get invalidRequest => 'Yêu cầu không hợp lệ';
	@override String get invalidUrl => 'URL không hợp lệ';
	@override String get invalidMethod => 'Phương thức không hợp lệ';
	@override String get invalidHeader => 'Header không hợp lệ';
	@override String get invalidBody => 'Nội dung không hợp lệ';
	@override String get invalidStatusCode => 'Mã trạng thái không hợp lệ';
	@override String get serverError => 'Lỗi máy chủ';
	@override String get requestCanceled => 'Yêu cầu đã bị hủy';
	@override String get invalidPort => 'Cổng không hợp lệ';
	@override String get proxyPortError => 'Lỗi cổng proxy';
	@override String get connectionRefused => 'Kết nối bị từ chối';
	@override String get networkUnreachable => 'Không thể truy cập mạng';
	@override String get noRouteToHost => 'Không có tuyến tới máy chủ';
	@override String get connectionFailed => 'Kết nối thất bại';
	@override String get sslConnectionFailed => 'Kết nối SSL thất bại, vui lòng kiểm tra cài đặt mạng';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingVi extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Phím tắt bàn phím';
	@override String get entryLabel => 'Phím tắt bàn phím';
	@override String get entryDesc => 'Tùy chỉnh phím tắt bàn phím của ứng dụng (chủ yếu cho máy tính)';
	@override String get desktopHint => 'Phím tắt chủ yếu áp dụng cho bàn phím máy tính; trên di động thường dùng cử chỉ.';
	@override String get resetAll => 'Đặt lại tất cả về mặc định';
	@override String get resetAllConfirm => 'Đặt lại tất cả phím tắt ứng dụng về mặc định?';
	@override String get resetToDefault => 'Đặt lại mặc định';
	@override String get resetScope => 'Đặt lại mục này';
	@override String get notSet => 'Chưa đặt';
	@override String get addShortcut => 'Thêm phím tắt';
	@override String get removeShortcut => 'Xóa phím tắt này';
	@override String get pressNewShortcut => 'Nhấn phím tắt mới…';
	@override String get recordingCancelHint => 'Nhấn Esc để hủy';
	@override String get mouseHint => 'Bạn cũng có thể gán nút bên của chuột (lùi / tiến) hoặc nút giữa';
	@override String get mouseNotSupportedInScope => 'Khu vực này không xử lý nút chuột; hãy dùng bàn phím';
	@override String get capabilityKeyboardOnly => 'Khu vực này chỉ nhận phím bàn phím';
	@override String get capabilityKeyboardAndMouse => 'Khu vực này nhận phím bàn phím, cùng nút giữa và nút bên của chuột';
	@override String get capabilityKeyboardAndMouseMobile => 'Khu vực này nhận phím bàn phím, cùng nút giữa và nút tiến của chuột (nút lùi do hệ thống chiếm)';
	@override String get rejectMultipleButtons => 'Mỗi lần chỉ nhấn một nút chuột';
	@override String get rejectPlatformBack => 'Hệ thống đã dùng phím này cho Quay lại; gán nó sẽ khiến quay lại hai lần';
	@override String get detectedLabel => 'Đã phát hiện';
	@override String get reservedKey => 'Phím này do hệ thống giữ riêng, không thể gán';
	@override String reservedForGlobalBack({required Object action}) => 'Phím này được gán cho "${action}"; nó vẫn được giữ riêng ở đây để bạn có thể rời màn hình này';
	@override String get conflictTitle => 'Xung đột phím tắt';
	@override String conflictMessage({required Object action}) => 'Tổ hợp này đã được gán cho "${action}". Tiếp tục sẽ xóa liên kết hiện có.';
	@override String get conflictContinue => 'Vẫn gán';
	@override String get shadowWarningTitle => 'Trùng phím tắt toàn cục';
	@override String shadowWarningMessage({required Object action}) => 'Tổ hợp này được gán cho "${action}" trên toàn cục. Gán nó ở đây sẽ chỉ ghi đè hành động đó bên trong mục này.';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'Tổ hợp này đã được gán cho "${action}" trong ${scope}. Trong mục đó, phím tắt toàn cục này sẽ bị ghi đè.';
	@override String get searchHint => 'Tìm kiếm phím tắt…';
	@override String get scopeGlobal => 'Toàn cục';
	@override String get scopeGallery => 'Thư viện';
	@override String get scopeVideo => 'Video';
	@override String get categoryNavigation => 'Điều hướng';
	@override String get categoryZoom => 'Thu phóng';
	@override String get categoryPlayback => 'Phát';
	@override String get categorySeek => 'Tua';
	@override String get categoryVolume => 'Âm lượng';
	@override String get categoryDisplay => 'Hiển thị';
	@override String get actionGlobalBack => 'Quay lại';
	@override String get actionGalleryNext => 'Ảnh tiếp theo';
	@override String get actionGalleryPrevious => 'Ảnh trước';
	@override String get actionGalleryZoomIn => 'Phóng to';
	@override String get actionGalleryZoomOut => 'Thu nhỏ';
	@override String get actionGalleryResetZoom => 'Đặt lại thu phóng';
	@override String get actionGalleryPlayPause => 'Phát / Tạm dừng';
	@override String get actionGallerySeekBackward => 'Tua lại';
	@override String get actionGallerySeekForward => 'Tua tới';
	@override String get actionGalleryToggleMute => 'Bật/tắt tiếng';
	@override String get actionPlayPause => 'Phát / Tạm dừng';
	@override String get actionSpeedUp => 'Tăng tốc độ';
	@override String get actionSpeedDown => 'Giảm tốc độ';
	@override String get actionSeekForward => 'Tua tới';
	@override String get actionSeekBackward => 'Tua lại';
	@override String get actionVolumeUp => 'Tăng âm lượng';
	@override String get actionVolumeDown => 'Giảm âm lượng';
	@override String get actionToggleMute => 'Bật/tắt tiếng';
	@override String get actionToggleFullscreen => 'Bật/tắt toàn màn hình';
	@override String get seekLongPressHint => 'Giữ phím tua tới / tua lại để kích hoạt chế độ tốc độ khi nhấn giữ';
	@override String get zoomSectionTitle => 'Thu phóng hình (cố định)';
	@override String get zoomFixedNote => 'Các phím tắt bên dưới là cố định, không thể thay đổi';
	@override String get zoomScaleLabel => 'Thu phóng hình';
	@override String get zoomScaleHint => 'Ctrl + Con lăn';
	@override String get zoomRotateLabel => 'Xoay hình';
	@override String get zoomRotateHint => 'Shift + Con lăn';
	@override String get zoomPinchGesture => 'Chụm';
	@override String get zoomTwoFingerRotateGesture => 'Xoay bằng hai ngón';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsVi extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get name => 'Diễn đàn';
	@override String get configureYourForumSettings => 'Cấu hình cài đặt diễn đàn';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsVi extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Cài đặt thư viện';
	@override String get gallerySettingsSubtitle => 'Cấu hình tùy chọn trình xem thư viện';
	@override String get defaultViewerQuality => 'Chất lượng xem mặc định';
	@override String get defaultViewerQualityDesc => 'Chọn chất lượng hình ảnh hiển thị mặc định khi mở trình xem thư viện.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsVi extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chặn nội dung';
	@override String get subtitle => 'Tự động ẩn video và thư viện có tiêu đề khớp với từ khóa hoặc mẫu, hoặc đến từ người dùng bị chặn. Mọi quá trình khớp đều diễn ra trên thiết bị của bạn — không có gì được tải lên.';
	@override String get blocked => 'Đã chặn';
	@override String get reveal => 'Hiện';
	@override String get reblock => 'Chặn lại';
	@override String get why => 'Vì sao bị chặn?';
	@override String get manageRules => 'Quản lý quy tắc';
	@override String reasonKeyword({required Object value}) => 'Tiêu đề chứa "${value}"';
	@override String reasonRegex({required Object value}) => 'Tiêu đề khớp "${value}"';
	@override String get reasonUser => 'Từ người dùng bị chặn';
	@override String get addRule => 'Thêm quy tắc';
	@override String get editRule => 'Chỉnh sửa quy tắc';
	@override String get deleteRule => 'Xóa quy tắc';
	@override String get ruleType => 'Loại quy tắc';
	@override String get keyword => 'Từ khóa';
	@override String get regex => 'Regex';
	@override String get userId => 'Người dùng';
	@override String get value => 'Văn bản cần khớp';
	@override String get caseSensitive => 'Phân biệt chữ hoa chữ thường';
	@override String get regexHint => 'ví dụ: trailer|hậu trường';
	@override String get valueRequired => 'Vui lòng nhập văn bản cần khớp';
	@override String get invalidRegex => 'Đó không phải là biểu thức chính quy hợp lệ';
	@override String get noRules => 'Chưa có quy tắc nào. Nhấn + để thêm.';
	@override String get blockUser => 'Chặn';
	@override String get unblockUser => 'Bỏ chặn';
	@override String blockUserConfirm({required Object name}) => 'Chặn "${name}"? Video và thư viện của họ sẽ bị ẩn khỏi danh sách và tìm kiếm.';
	@override String get userBlocked => 'Đã chặn người dùng';
	@override String get userUnblocked => 'Đã bỏ chặn người dùng';
	@override String get exportRules => 'Xuất';
	@override String get importRules => 'Nhập';
	@override String get importExport => 'Nhập / Xuất';
	@override String get exportSuccess => 'Đã xuất quy tắc';
	@override String get exportFailed => 'Không thể xuất quy tắc';
	@override String importSuccess({required Object count}) => 'Đã nhập ${count} quy tắc';
	@override String get importFailed => 'Không thể nhập quy tắc';
	@override String get regexHelp => 'Trợ giúp về mẫu';
	@override String get regexHelpTitle => 'Tham khảo Regex';
	@override String get regexHelpIntro => 'Biểu thức chính quy khớp tiêu đề linh hoạt hơn từ khóa thông thường. Một số ví dụ phổ biến:';
	@override String get regexHelpTapHint => 'Nhấn vào một ví dụ để điền vào.';
	@override String get regexEx1Pattern => 'trailer|hậu trường|tặng kèm';
	@override String get regexEx1Desc => 'Khớp với bất kỳ từ nào sau đây ("|" nghĩa là "hoặc")';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Tiêu đề bắt đầu bằng [ngoặc vuông]';
	@override String get regexEx3Pattern => 'Tuyển tập\$';
	@override String get regexEx3Desc => 'Tiêu đề kết thúc bằng "Tuyển tập"';
	@override String get regexEx4Pattern => 'Tập [0-9]+';
	@override String get regexEx4Desc => '[0-9]+ là một hoặc nhiều chữ số — khớp với "Tập 12"';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '[0-9] là một chữ số và {4} nghĩa là bốn chữ số liên tiếp (ví dụ: một năm)';
	@override String get regexEx1Sample => 'Video trailer mới ra mắt';
	@override String get regexEx2Sample => '[Remux] Phim đầy đủ';
	@override String get regexEx3Sample => 'Ảnh mùa xuân Tuyển tập';
	@override String get regexEx4Sample => 'Phim của tôi Tập 12 tóm tắt';
	@override String get regexEx5Sample => 'Tuyển chọn hay nhất 2024';
	@override String get regexHelpSampleLabel => 'Tiêu đề ví dụ';
	@override String get regexHelpMatchedTag => 'Đã chặn';
	@override String get regexHelpNoMatch => 'Không khớp';
	@override String get regexEx6Pattern => '[Mm]ùa';
	@override String get regexEx6Desc => '[Mm] khớp với chữ M viết hoa hoặc viết thường — ở đây bắt được "Mùa"';
	@override String get regexEx6Sample => 'Mùa cuối trailer';
	@override String get regexEx7Pattern => 'xem (phim|bộ)';
	@override String get regexEx7Desc => 'Dấu ngoặc đơn () nhóm các lựa chọn — khớp với "xem phim" hoặc "xem bộ"';
	@override String get regexEx7Sample => 'Hãy xem bộ ngay';
	@override String get regexEx8Pattern => 'xem( ngay)?';
	@override String get regexEx8Desc => 'Phần trong ngoặc () là tùy chọn — khớp với "xem" và "xem ngay"';
	@override String get regexEx8Sample => 'Hãy xem ngay bây giờ';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '"+" nghĩa là một hoặc nhiều — khớp với !, !!, !!! ...';
	@override String get regexEx9Sample => 'Quá đỉnh!!! Nhất định phải xem';
	@override String get regexEx10Pattern => 'trailer.*mới';
	@override String get regexEx10Desc => '".*" khớp với mọi thứ ở giữa — "trailer … mới"';
	@override String get regexEx10Sample => 'Xem trailer hấp dẫn mới';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsVi extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get name => 'Trò chuyện';
	@override String get configureYourChatSettings => 'Cấu hình cài đặt trò chuyện';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsVi extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Cài đặt tải xuống';
	@override String get enableDownloadNotifications => 'Thông báo tải xuống';
	@override String get enableDownloadNotificationsDescription => 'Hiển thị thông báo hệ thống khi một lượt tải xuống hoàn tất hoặc thất bại';
	@override String get notificationPermissionDenied => 'Quyền thông báo bị từ chối. Thông báo trong ứng dụng vẫn hoạt động; hãy bật thông báo hệ thống trong cài đặt.';
	@override String get storagePermissionStatus => 'Trạng thái quyền lưu trữ';
	@override String get accessPublicDirectoryNeedStoragePermission => 'Truy cập thư mục công khai cần quyền lưu trữ';
	@override String get checkingPermissionStatus => 'Đang kiểm tra trạng thái quyền...';
	@override String get storagePermissionGranted => 'Đã được cấp quyền lưu trữ';
	@override String get storagePermissionNotGranted => 'Chưa được cấp quyền lưu trữ';
	@override String get storagePermissionGrantSuccess => 'Cấp quyền lưu trữ thành công';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Cấp quyền lưu trữ thất bại nhưng một số tính năng có thể bị hạn chế';
	@override String get storagePermissionRationale => 'Để lưu tệp tải xuống vào thư mục bạn chọn, ứng dụng cần quyền truy cập bộ nhớ.\n\nTrên Android 11 trở lên, điều này có nghĩa là quyền "truy cập mọi tệp"; nếu không có, tệp sẽ được lưu vào thư mục riêng của ứng dụng.';
	@override String get storagePermissionRationaleLegacy => 'Để lưu tệp tải xuống vào thư mục bạn chọn, ứng dụng cần quyền truy cập bộ nhớ.\n\nNếu không có, tệp sẽ được lưu vào thư mục riêng của ứng dụng.';
	@override String get grantStoragePermission => 'Cấp quyền lưu trữ';
	@override String get customDownloadPath => 'Đường dẫn tải xuống tùy chỉnh';
	@override String get customDownloadPathDescription => 'Khi bật, bạn có thể chọn vị trí lưu tùy chỉnh cho tệp tải xuống';
	@override String get customDownloadPathTip => '💡 Gợi ý: Chọn thư mục công khai (như thư mục Tải xuống) cần quyền lưu trữ, nên ưu tiên dùng các đường dẫn được đề xuất';
	@override String get androidWarning => 'Lưu ý cho Android: Tránh chọn thư mục công khai (như thư mục Tải xuống), nên dùng thư mục riêng của ứng dụng để đảm bảo quyền truy cập.';
	@override String get publicDirectoryPermissionTip => '⚠️ Lưu ý: Bạn đã chọn thư mục công khai, cần quyền lưu trữ để tải tệp xuống bình thường';
	@override String get permissionRequiredForPublicDirectory => 'Cần quyền lưu trữ cho thư mục công khai';
	@override String get currentDownloadPath => 'Đường dẫn tải xuống hiện tại';
	@override String get actualDownloadPath => 'Đường dẫn tải xuống thực tế';
	@override String get defaultAppDirectory => 'Thư mục ứng dụng mặc định';
	@override String get permissionGranted => 'Đã cấp';
	@override String get permissionRequired => 'Cần quyền';
	@override String get enableCustomDownloadPath => 'Bật đường dẫn tải xuống tùy chỉnh';
	@override String get disableCustomDownloadPath => 'Dùng đường dẫn mặc định của ứng dụng khi tắt';
	@override String get customDownloadPathLabel => 'Đường dẫn tải xuống tùy chỉnh';
	@override String get selectDownloadFolder => 'Chọn thư mục tải xuống';
	@override String get recommendedPath => 'Đường dẫn đề xuất';
	@override String get selectFolder => 'Chọn thư mục';
	@override String get filenameTemplate => 'Mẫu tên tệp';
	@override String get filenameTemplateDescription => 'Tùy chỉnh quy tắc đặt tên cho tệp tải xuống, hỗ trợ thay thế biến';
	@override String get videoFilenameTemplate => 'Mẫu tên tệp video';
	@override String get galleryFolderTemplate => 'Mẫu thư mục thư viện';
	@override String get imageFilenameTemplate => 'Mẫu tên tệp hình ảnh';
	@override String get resetToDefault => 'Đặt lại mặc định';
	@override String get supportedVariables => 'Biến được hỗ trợ';
	@override String get supportedVariablesDescription => 'Các biến sau có thể dùng trong mẫu tên tệp:';
	@override String get copyVariable => 'Sao chép biến';
	@override String get variableCopied => 'Đã sao chép biến';
	@override String get warningPublicDirectory => 'Cảnh báo: Thư mục công khai đã chọn có thể không truy cập được. Nên chọn thư mục riêng của ứng dụng.';
	@override String get downloadPathUpdated => 'Đã cập nhật đường dẫn tải xuống';
	@override String get selectPathFailed => 'Chọn đường dẫn thất bại';
	@override String get pickerAlreadyActive => 'Trình chọn thư mục đang mở';
	@override String get unsupportedStorageVolume => 'Vị trí lưu trữ không được hỗ trợ. Hãy chọn thư mục trên bộ nhớ thiết bị hoặc thẻ SD.';
	@override String get recommendedPathSet => 'Đã đặt thành đường dẫn đề xuất';
	@override String get setRecommendedPathFailed => 'Đặt đường dẫn đề xuất thất bại';
	@override String get templateResetToDefault => 'Đặt lại mẫu mặc định';
	@override String get functionalTest => 'Kiểm tra chức năng';
	@override String get testInProgress => 'Đang kiểm tra...';
	@override String get runTest => 'Chạy kiểm tra';
	@override String get testDownloadPathAndPermissions => 'Kiểm tra xem đường dẫn tải xuống và cấu hình quyền có hoạt động đúng hay không';
	@override String get testResults => 'Kết quả kiểm tra';
	@override String get testCompleted => 'Kiểm tra hoàn tất';
	@override String get testMultisegmentDomain => 'Kiểm tra miền giá trị (đa đoạn / vượt giới hạn / dạng thoát)';
	@override String get testMultisegmentPaths => 'Kết cấu đa đoạn (issue #126)';
	@override String get testPassed => 'mục đạt';
	@override String get testFailed => 'Kiểm tra thất bại';
	@override String get testStoragePermissionCheck => 'Kiểm tra quyền lưu trữ';
	@override String get testStoragePermissionGranted => 'Đã được cấp quyền lưu trữ';
	@override String get testStoragePermissionMissing => 'Thiếu quyền lưu trữ, một số tính năng có thể bị hạn chế';
	@override String get testPermissionCheckFailed => 'Kiểm tra quyền thất bại';
	@override String get testDownloadPathValidation => 'Kiểm tra đường dẫn tải xuống';
	@override String get testPathValidationFailed => 'Kiểm tra đường dẫn thất bại';
	@override String get testFilenameTemplateValidation => 'Kiểm tra mẫu tên tệp';
	@override String get testAllTemplatesValid => 'Tất cả mẫu đều hợp lệ';
	@override String get testSomeTemplatesInvalid => 'Một số mẫu chứa ký tự không hợp lệ';
	@override String get testTemplateValidationFailed => 'Kiểm tra mẫu thất bại';
	@override String get testDirectoryOperationTest => 'Kiểm tra thao tác thư mục';
	@override String get testDirectoryOperationNormal => 'Tạo thư mục và ghi tệp diễn ra bình thường';
	@override String get testDirectoryOperationFailed => 'Thao tác thư mục thất bại';
	@override String get testVideoTemplate => 'Mẫu video';
	@override String get testGalleryTemplate => 'Mẫu thư viện';
	@override String get testImageTemplate => 'Mẫu hình ảnh';
	@override String get testValid => 'Hợp lệ';
	@override String get testInvalid => 'Không hợp lệ';
	@override String get testSuccess => 'Thành công';
	@override String get testCorrect => 'Đúng';
	@override String get testError => 'Lỗi';
	@override String get testPath => 'Đường dẫn kiểm tra';
	@override String get testBasePath => 'Đường dẫn cơ sở';
	@override String get testDirectoryCreation => 'Tạo thư mục';
	@override String get testFileWriting => 'Ghi tệp';
	@override String get testFileContent => 'Nội dung tệp';
	@override String get checkingPathStatus => 'Đang kiểm tra trạng thái đường dẫn...';
	@override String get unableToGetPathStatus => 'Không lấy được trạng thái đường dẫn';
	@override String get actualPathDifferentFromSelected => 'Lưu ý: Đường dẫn thực tế khác với đường dẫn đã chọn';
	@override String get grantPermission => 'Cấp quyền';
	@override String get fixIssue => 'Khắc phục sự cố';
	@override String get issueFixed => 'Đã khắc phục sự cố';
	@override String get fixFailed => 'Sửa thất bại, vui lòng xử lý thủ công';
	@override String get lackStoragePermission => 'Thiếu quyền lưu trữ';
	@override String get cannotAccessPublicDirectory => 'Không thể truy cập thư mục công khai, cần "quyền truy cập mọi tệp"';
	@override String get cannotCreateDirectory => 'Không thể tạo thư mục';
	@override String get directoryNotWritable => 'Thư mục không ghi được';
	@override String get insufficientSpace => 'Không đủ dung lượng trống';
	@override String get pathValid => 'Đường dẫn hợp lệ';
	@override String get validationFailed => 'Kiểm tra hợp lệ thất bại';
	@override String get usingDefaultAppDirectory => 'Đang dùng thư mục ứng dụng mặc định';
	@override String get appPrivateDirectory => 'Thư mục riêng của ứng dụng';
	@override String get appPrivateDirectoryDesc => 'An toàn và đáng tin cậy, không cần quyền bổ sung';
	@override String get downloadDirectory => 'Thư mục tải xuống';
	@override String get downloadDirectoryDesc => 'Vị trí tải xuống mặc định của hệ thống, dễ quản lý';
	@override String get moviesDirectory => 'Thư mục phim';
	@override String get moviesDirectoryDesc => 'Thư mục phim của hệ thống, ứng dụng media có thể nhận diện';
	@override String get documentsDirectory => 'Thư mục tài liệu';
	@override String get documentsDirectoryDesc => 'Thư mục tài liệu của ứng dụng iOS';
	@override String get requiresStoragePermission => 'Cần quyền lưu trữ để truy cập';
	@override String get recommendedPaths => 'Đường dẫn đề xuất';
	@override String get externalAppPrivateDirectory => 'Thư mục riêng ứng dụng trên bộ nhớ ngoài';
	@override String get externalAppPrivateDirectoryDesc => 'Thư mục riêng của ứng dụng trên bộ nhớ ngoài, người dùng có thể truy cập, dung lượng lớn hơn';
	@override String get internalAppPrivateDirectory => 'Thư mục riêng ứng dụng trên bộ nhớ trong';
	@override String get internalAppPrivateDirectoryDesc => 'Bộ nhớ trong của ứng dụng, không cần quyền, dung lượng nhỏ hơn';
	@override String get appDocumentsDirectory => 'Thư mục tài liệu ứng dụng';
	@override String get appDocumentsDirectoryDesc => 'Thư mục tài liệu riêng của ứng dụng, an toàn và đáng tin cậy';
	@override String get downloadsFolder => 'Thư mục Tải xuống';
	@override String get downloadsFolderDesc => 'Thư mục tải xuống mặc định của hệ thống';
	@override String get selectRecommendedDownloadLocation => 'Chọn một vị trí tải xuống được đề xuất';
	@override String get noRecommendedPaths => 'Không có đường dẫn đề xuất nào';
	@override String get recommended => 'Đề xuất';
	@override String get requiresPermission => 'Cần quyền';
	@override String get authorizeAndSelect => 'Cấp quyền và chọn';
	@override String get select => 'Chọn';
	@override String get permissionAuthorizationFailed => 'Cấp quyền thất bại, không thể chọn đường dẫn này';
	@override String get pathValidationFailed => 'Kiểm tra đường dẫn thất bại';
	@override String get downloadPathSetTo => 'Đã đặt đường dẫn tải xuống thành';
	@override String get setPathFailed => 'Đặt đường dẫn thất bại';
	@override String get variableTitle => 'Tiêu đề';
	@override String get variableAuthorcache => 'Tên đầu tiên của tác giả (không đổi khi tác giả đổi tên)';
	@override String get variableAuthor => 'Tên tác giả';
	@override String get variableUsername => 'Tên người dùng tác giả';
	@override String get variableQuality => 'Chất lượng video';
	@override String get variableFilename => 'Tên tệp gốc';
	@override String get variableId => 'ID nội dung';
	@override String get variableCount => 'Số hình ảnh trong thư viện';
	@override String get variableDate => 'Ngày hiện tại (YYYY-MM-DD)';
	@override String get variableTime => 'Giờ hiện tại (HH-MM-SS)';
	@override String get variableDatetime => 'Ngày giờ hiện tại (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'Cài đặt tải xuống';
	@override String get downloadSettingsSubtitle => 'Cấu hình đường dẫn tải xuống và quy tắc đặt tên tệp';
	@override String get suchAsTitleQuality => 'Ví dụ: %title_%quality';
	@override String get suchAsTitleId => 'Ví dụ: %title_%id';
	@override String get suchAsTitleFilename => 'Ví dụ: %title_%filename';
	@override String get structureSection => 'Cấu trúc lưu & đặt tên';
	@override String get structureSectionDescription => 'Tệp tải về sẽ tự động vào thư mục con theo cách chọn bên dưới. Chỉ ảnh hưởng đến các lượt tải mới; tệp đã có giữ nguyên.';
	@override String get structureNoticeTitle => 'Tính năng mới: tự động gộp theo tác giả';
	@override String get structureNoticeBody => 'Chọn bên dưới · chỉ ảnh hưởng tệp tải mới, tệp đã có giữ nguyên.';
	@override String get presetFlat => 'Phẳng';
	@override String get presetFlatDesc => 'Mọi tệp nằm ngay thư mục gốc tải về';
	@override String get presetAuthor => 'Theo tác giả';
	@override String get presetAuthorBadge => 'Đề xuất';
	@override String get presetAuthorDesc => 'Mỗi tác giả một thư mục · đổi tên không tách rời';
	@override String get presetDate => 'Theo ngày';
	@override String get presetDateDesc => 'Nhóm theo ngày tải';
	@override String get presetCustomActive => 'Đang dùng';
	@override String get structurePreviewLabel => 'Xem trước';
	@override String get structurePreviewNote => 'Đoạn màu là cấp tổ chức, đổi theo cách đã chọn.';
	@override String get pathTooLongWarning => 'Đường dẫn tương đối vượt 200 ký tự, một số thiết bị có thể không lưu được';
	@override String get pathTemplateEditorEntry => 'Mẫu đường dẫn tùy chỉnh';
	@override String get pathTemplateEditorEntryDesc => 'Tự quyết định cấu trúc thư mục và tên tệp';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorVi pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorVi._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesVi extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Nổi bật';
	@override String get favorites => 'Yêu thích';
	@override String get latest => 'Mới nhất';
	@override String get popularity => 'Phổ biến';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsVi extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Yêu cầu thất bại, mã trạng thái';
	@override String get connectionTimeout => 'Hết thời gian kết nối, vui lòng kiểm tra kết nối mạng';
	@override String get sendTimeout => 'Hết thời gian gửi yêu cầu';
	@override String get receiveTimeout => 'Hết thời gian nhận phản hồi';
	@override String get badCertificate => 'Xác minh chứng chỉ thất bại';
	@override String get resourceNotFound => 'Không tìm thấy tài nguyên được yêu cầu';
	@override String get accessDenied => 'Truy cập bị từ chối, có thể cần xác thực hoặc quyền';
	@override String get serverError => 'Lỗi máy chủ nội bộ';
	@override String get serviceUnavailable => 'Dịch vụ tạm thời không khả dụng';
	@override String get requestCancelled => 'Yêu cầu đã bị hủy';
	@override String get connectionError => 'Lỗi kết nối mạng, vui lòng kiểm tra cài đặt mạng';
	@override String get networkRequestFailed => 'Yêu cầu mạng thất bại';
	@override String get searchVideoError => 'Đã xảy ra lỗi không xác định khi tìm kiếm video';
	@override String get getPopularVideoError => 'Đã xảy ra lỗi không xác định khi lấy video phổ biến';
	@override String get getVideoDetailError => 'Đã xảy ra lỗi không xác định khi lấy chi tiết video';
	@override String get parseVideoDetailError => 'Đã xảy ra lỗi không xác định khi lấy và phân tích chi tiết video';
	@override String get downloadFileError => 'Đã xảy ra lỗi không xác định khi tải tệp xuống';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingVi extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Đang lấy thông tin video...';
	@override String get cancel => 'Hủy';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesVi extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Không tìm thấy video hoặc video đã bị xóa';
	@override String get unableToGetVideoPlayLink => 'Không thể lấy liên kết phát video';
	@override String get getVideoDetailFailed => 'Không lấy được chi tiết video';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoVi extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Thông tin video';
	@override String get currentQuality => 'Chất lượng hiện tại';
	@override String get duration => 'Thời lượng';
	@override String get resolution => 'Độ phân giải';
	@override String get fileInfo => 'Thông tin tệp';
	@override String get fileName => 'Tên tệp';
	@override String get fileSize => 'Kích thước tệp';
	@override String get filePath => 'Đường dẫn tệp';
	@override String get copyPath => 'Sao chép đường dẫn';
	@override String get openFolder => 'Mở thư mục';
	@override String get pathCopiedToClipboard => 'Đã sao chép đường dẫn vào bộ nhớ tạm';
	@override String get openFolderFailed => 'Mở thư mục thất bại';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideVi extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Video mẫu';
	@override String get title => 'Hướng dẫn cử chỉ và tương tác';
	@override String get viewGuide => 'Hướng dẫn cử chỉ và tương tác';
	@override String get firstTimeIntro => 'Dành vài giây để tìm hiểu cử chỉ của trình phát. Bạn có thể mở lại hướng dẫn này bất cứ lúc nào từ cài đặt trình phát.';
	@override String get startWatching => 'Đã hiểu, bắt đầu xem';
	@override String get basicTitle => 'Điều khiển cơ bản';
	@override String get zoomTitle => 'Thu phóng / Xoay / Di chuyển';
	@override String get restoreTip => 'Nhấn nút "Khôi phục" ở góc dưới bên phải để đặt lại thu phóng, xoay và vị trí.';
	@override String get mTap => 'Nhấn một lần: hiện / ẩn điều khiển';
	@override String get mDoubleTap => 'Nhấn đúp: tua lại (trái) / tạm dừng (giữa) / tua tới (phải)';
	@override String get mHorizontalDrag => 'Vuốt ngang: tua';
	@override String get mVerticalDrag => 'Vuốt dọc: độ sáng (trái) / âm lượng (phải)';
	@override String get mLongPress => 'Nhấn giữ: tăng tốc tạm thời';
	@override String get mPinch => 'Chụm hai ngón: thu phóng hình';
	@override String get mRotate => 'Xoay hai ngón: xoay hình';
	@override String get dTap => 'Nhấp: hiện / ẩn điều khiển';
	@override String get dDoubleTap => 'Nhấp đúp: tua lại (trái) / tạm dừng (giữa) / tua tới (phải)';
	@override String get dKeys => 'Phím tua: nhấn để nhảy lùi / tiến, giữ để tăng tốc; phím tốc độ: điều chỉnh tốc độ phát khi phát bình thường; Space: phát / tạm dừng';
	@override String get dTrackpadPinch => 'Chụm trên bàn di chuột: thu phóng hình';
	@override String get dTrackpadRotate => 'Xoay trên bàn di chuột: xoay hình';
	@override String get dCtrlWheel => 'Ctrl + con lăn: thu phóng quanh con trỏ';
	@override String get dShiftWheel => 'Shift + con lăn: xoay quanh con trỏ';
	@override late final _TranslationsVideoDetailGestureGuideQuestVi quest = _TranslationsVideoDetailGestureGuideQuestVi._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerVi extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Lỗi khi tải nguồn video';
	@override String get errorWhileSettingUpListeners => 'Lỗi khi thiết lập trình lắng nghe';
	@override String get serverFaultDetectedAutoSwitched => 'Phát hiện lỗi máy chủ, tự động chuyển tuyến và thử lại';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonVi extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Đang lấy thông tin video...';
	@override String get fetchingVideoSources => 'Đang lấy nguồn video...';
	@override String get loadingVideo => 'Đang tải video...';
	@override String get applyingSolution => 'Đang áp dụng giải pháp...';
	@override String get addingListeners => 'Đang thêm trình lắng nghe...';
	@override String get successFecthVideoDurationInfo => 'Đã lấy thành công thời lượng video, bắt đầu tải video...';
	@override String get successFecthVideoHeightInfo => 'Tải hoàn tất';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastVi extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Truyền phát';
	@override String unableToStartCastingSearch({required Object error}) => 'Không thể bắt đầu tìm kiếm truyền phát: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Bắt đầu truyền phát tới ${deviceName}';
	@override String castFailed({required Object error}) => 'Truyền phát thất bại: ${error}\nVui lòng thử tìm lại thiết bị hoặc chuyển mạng';
	@override String get castStopped => 'Đã dừng truyền phát';
	@override late final _TranslationsVideoDetailCastDeviceTypesVi deviceTypes = _TranslationsVideoDetailCastDeviceTypesVi._(_root);
	@override String get currentPlatformNotSupported => 'Nền tảng hiện tại không hỗ trợ truyền phát';
	@override String get unableToGetVideoUrl => 'Không lấy được URL video, vui lòng thử lại sau';
	@override String get stopCasting => 'Dừng truyền phát';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetVi dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetVi._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsVi extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Ai đang âm thầm thích';
	@override String get dialogDescription => 'Tò mò họ là ai? Lật xem "Album lượt thích" này~';
	@override String get closeTooltip => 'Đóng';
	@override String get retry => 'Thử lại';
	@override String get noLikesYet => 'Chưa có ai xuất hiện ở đây. Hãy là người đầu tiên!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Trang ${page} / ${totalPages} · Tổng ${totalCount} người';
	@override String get prevPage => 'Trang trước';
	@override String get nextPage => 'Trang sau';
}

// Path: forum.sitewide
class _TranslationsForumSitewideVi extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get badge => 'Toàn trang';
	@override String get title => 'Thông báo toàn trang';
	@override String get readMore => 'Đọc thêm';
}

// Path: forum.errors
class _TranslationsForumErrorsVi extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Vui lòng chọn một danh mục';
	@override String get threadLocked => 'Chủ đề này đã bị khóa, không thể trả lời';
}

// Path: forum.groups
class _TranslationsForumGroupsVi extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Quản trị';
	@override String get global => 'Toàn cầu';
	@override String get chinese => 'Tiếng Trung';
	@override String get japanese => 'Tiếng Nhật';
	@override String get korean => 'Tiếng Hàn';
	@override String get other => 'Khác';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesVi extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Thông báo';
	@override String get feedback => 'Phản hồi';
	@override String get support => 'Hỗ trợ';
	@override String get general => 'Chung';
	@override String get guides => 'Hướng dẫn';
	@override String get questions => 'Câu hỏi';
	@override String get requests => 'Yêu cầu';
	@override String get sharing => 'Chia sẻ';
	@override String get general_zh => 'Chung';
	@override String get questions_zh => 'Câu hỏi';
	@override String get requests_zh => 'Yêu cầu';
	@override String get support_zh => 'Hỗ trợ';
	@override String get general_ja => 'Chung';
	@override String get questions_ja => 'Câu hỏi';
	@override String get requests_ja => 'Yêu cầu';
	@override String get support_ja => 'Hỗ trợ';
	@override String get korean => 'Tiếng Hàn';
	@override String get other => 'Khác';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsVi extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Thông báo và tin tức chính thức quan trọng';
	@override String get feedback => 'Phản hồi về tính năng và dịch vụ của trang web';
	@override String get support => 'Giúp giải quyết các vấn đề liên quan tới trang web';
	@override String get general => 'Thảo luận mọi chủ đề';
	@override String get guides => 'Chia sẻ kinh nghiệm và hướng dẫn';
	@override String get questions => 'Đặt câu hỏi của bạn';
	@override String get requests => 'Đăng yêu cầu của bạn';
	@override String get sharing => 'Chia sẻ nội dung thú vị';
	@override String get general_zh => 'Thảo luận mọi chủ đề';
	@override String get questions_zh => 'Đặt câu hỏi của bạn';
	@override String get requests_zh => 'Đăng yêu cầu của bạn';
	@override String get support_zh => 'Giúp giải quyết các vấn đề liên quan tới trang web';
	@override String get general_ja => 'Thảo luận mọi chủ đề';
	@override String get questions_ja => 'Đặt câu hỏi của bạn';
	@override String get requests_ja => 'Đăng yêu cầu của bạn';
	@override String get support_ja => 'Giúp giải quyết các vấn đề liên quan tới trang web';
	@override String get korean => 'Thảo luận liên quan tới tiếng Hàn';
	@override String get other => 'Nội dung khác chưa được phân loại';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsVi extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Loại thông báo không được hỗ trợ';
	@override String get unknownUser => 'Người dùng không xác định';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Loại thông báo không được hỗ trợ: ${type}';
	@override String get unknownNotificationType => 'Loại thông báo không xác định';
}

// Path: conversation.errors
class _TranslationsConversationErrorsVi extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Vui lòng chọn một người dùng';
	@override String get pleaseEnterATitle => 'Vui lòng nhập tiêu đề';
	@override String get clickToSelectAUser => 'Nhấn để chọn người dùng';
	@override String get loadFailedClickToRetry => 'Tải thất bại, nhấn để thử lại';
	@override String get loadFailed => 'Tải thất bại';
	@override String get clickToRetry => 'Nhấn để thử lại';
	@override String get noMoreConversations => 'Không còn hội thoại';
}

// Path: splash.errors
class _TranslationsSplashErrorsVi extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Khởi tạo thất bại, vui lòng khởi động lại ứng dụng';
}

// Path: download.errors
class _TranslationsDownloadErrorsVi extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'Không tìm thấy mẫu ảnh';
	@override String get downloadFailed => 'Tải xuống thất bại';
	@override String get videoInfoNotFound => 'Không tìm thấy thông tin video';
	@override String get downloadTaskAlreadyExists => 'Tác vụ tải xuống đã tồn tại';
	@override String get downloadTaskSavePathConflict => 'Đường dẫn lưu đang được tác vụ khác sử dụng';
	@override String get videoAlreadyDownloaded => 'Video đã được tải xuống';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'Thêm tác vụ tải xuống thất bại: ${errorInfo}';
	@override String get userPausedDownload => 'Người dùng đã tạm dừng tải xuống';
	@override String get unknown => 'Không xác định';
	@override String fileSystemError({required Object errorInfo}) => 'Lỗi hệ thống tệp: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Lỗi không xác định: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'Ghi tệp thất bại: ${errorInfo}';
	@override String get connectionTimeout => 'Kết nối quá thời gian';
	@override String get sendTimeout => 'Gửi quá thời gian';
	@override String get receiveTimeout => 'Nhận quá thời gian';
	@override String serverError({required Object errorInfo}) => 'Lỗi máy chủ: ${errorInfo}';
	@override String get unknownNetworkError => 'Lỗi mạng không xác định';
	@override String get sslHandshakeFailed => 'Bắt tay SSL thất bại, vui lòng kiểm tra mạng';
	@override String get connectionFailed => 'Kết nối thất bại, vui lòng kiểm tra mạng';
	@override String get serviceIsClosing => 'Dịch vụ tải xuống đang đóng';
	@override String get partialDownloadFailed => 'Tải nội dung một phần thất bại';
	@override String get noDownloadTask => 'Không có tác vụ tải xuống';
	@override String get taskNotFoundOrDataError => 'Không tìm thấy tác vụ hoặc lỗi dữ liệu';
	@override String get fileNotFound => 'Không tìm thấy tệp';
	@override String get openFolderFailed => 'Mở thư mục thất bại';
	@override String get copyDownloadUrlFailed => 'Sao chép URL tải xuống thất bại';
	@override String openFolderFailedWithMessage({required Object message}) => 'Mở thư mục thất bại: ${message}';
	@override String get directoryNotFound => 'Không tìm thấy thư mục';
	@override String get copyFailed => 'Sao chép thất bại';
	@override String get openFileFailed => 'Mở tệp thất bại';
	@override String openFileFailedWithMessage({required Object message}) => 'Mở tệp thất bại: ${message}';
	@override String get playLocallyFailed => 'Phát cục bộ thất bại';
	@override String playLocallyFailedWithMessage({required Object message}) => 'Phát cục bộ thất bại: ${message}';
	@override String get noDownloadSource => 'Không có nguồn tải xuống';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'Không có nguồn tải xuống, vui lòng đợi tải xong thông tin rồi thử lại';
	@override String get noActiveDownloadTask => 'Không có tác vụ tải xuống đang hoạt động';
	@override String get noFailedDownloadTask => 'Không có tác vụ tải xuống thất bại';
	@override String get noCompletedDownloadTask => 'Không có tác vụ tải xuống đã hoàn thành';
	@override String get taskAlreadyCompletedDoNotAdd => 'Tác vụ đã hoàn thành, không thêm lại';
	@override String get linkExpiredTryAgain => 'Liên kết đã hết hạn, đang thử lấy liên kết tải xuống mới';
	@override String get linkExpiredTryAgainSuccess => 'Liên kết đã hết hạn, lấy liên kết tải xuống mới thành công';
	@override String get linkExpiredTryAgainFailed => 'Liên kết đã hết hạn, lấy liên kết tải xuống mới thất bại';
	@override String get taskDeleted => 'Đã xóa tác vụ';
	@override String unsupportedImageFormat({required Object format}) => 'Định dạng ảnh không được hỗ trợ: ${format}';
	@override String get deleteFileError => 'Xóa tệp thất bại, có thể do tệp đang được tiến trình khác sử dụng';
	@override String get deleteTaskError => 'Xóa tác vụ thất bại';
	@override String get canNotRefreshVideoTask => 'Làm mới tác vụ video thất bại';
	@override String get videoRemovedCanNotRefresh => 'Video này đã bị xóa hoặc không còn tồn tại nên không thể làm mới liên kết tải xuống';
	@override String get videoInaccessibleCanNotRefresh => 'Không thể truy cập video này, có thể video ở chế độ riêng tư hoặc cần đăng nhập lại';
	@override String get videoQualityGone => 'Chất lượng này không còn được cung cấp, vui lòng thêm lại tác vụ tải xuống';
	@override String get refreshLinkNetworkFailed => 'Lỗi mạng, hiện không thể làm mới liên kết tải xuống, vui lòng thử lại sau';
	@override String get taskAlreadyProcessing => 'Tác vụ đang được xử lý';
	@override String get taskNotFound => 'Không tìm thấy tác vụ';
	@override String get failedToLoadTasks => 'Tải danh sách tác vụ thất bại';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'Tải một phần thất bại: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Định dạng ảnh không được hỗ trợ: ${extension}, có thể thử tải về thiết bị để xem';
	@override String get imageLoadFailed => 'Tải ảnh thất bại';
	@override String get pleaseTryOtherViewer => 'Vui lòng thử dùng trình xem khác để mở';
}

// Path: download.timeline
class _TranslationsDownloadTimelineVi extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get today => 'Hôm nay';
	@override String get yesterday => 'Hôm qua';
	@override String get thisWeek => 'Tuần này';
	@override String get thisMonth => 'Tháng này';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesVi extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get network => 'Vấn đề mạng, thử lại có thể giúp ích';
	@override String get serverRejected => 'Bị máy chủ từ chối, có thể cần đăng nhập lại';
	@override String get notFound => 'Tài nguyên không còn tồn tại hoặc đã bị xóa';
	@override String get diskFull => 'Không đủ dung lượng lưu trữ';
	@override String get fileInUse => 'Tệp đang được chương trình khác sử dụng';
	@override String get permission => 'Không có quyền ghi';
	@override String get cancelled => 'Đã hủy';
	@override String get unknown => 'Lỗi không xác định';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedVi extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '${num} tác vụ chưa hoàn thành từ phiên trước đã được tạm dừng';
	@override String get resume => 'Tiếp tục tất cả';
	@override String get dismiss => 'Bỏ qua';
}

// Path: download.actions
class _TranslationsDownloadActionsVi extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeVi extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateVi extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Xóa theo ngày';
	@override String get dialogTitle => 'Xóa theo ngày';
	@override String get description => 'Xóa hàng loạt tác vụ tải xuống theo ngày tạo. Các tác vụ có tệp đang được dùng sẽ bị bỏ qua; tác vụ có tệp không còn tồn tại sẽ được dọn dẹp.';
	@override String get modeRange => 'Khoảng ngày';
	@override String get modeDays => 'Cũ hơn';
	@override String get startDate => 'Ngày bắt đầu';
	@override String get endDate => 'Ngày kết thúc';
	@override String get notSet => 'Chưa đặt';
	@override String get daysUnit => 'ngày';
	@override String olderThanDaysHint({required Object days}) => 'Xóa các tác vụ được tạo cách đây hơn ${days} ngày';
	@override String get noMatch => 'Không có tác vụ nào khớp điều kiện đã chọn';
	@override String get invalidRange => 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc';
	@override String get confirmTitle => 'Xác nhận xóa';
	@override String confirmContent({required Object count}) => 'Xóa ${count} tác vụ tải xuống và tệp của chúng? Thao tác này không thể hoàn tác.';
	@override String deleting({required Object done, required Object total}) => 'Đang xóa ${done}/${total}…';
	@override String resultSuccess({required Object count}) => 'Đã xóa ${count} tác vụ';
	@override String resultPartial({required Object deleted, required Object skipped}) => 'Đã xóa ${deleted} tác vụ; bỏ qua ${skipped} (đang được dùng)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationVi extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryVi extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Quản lý danh mục';
	@override String get label => 'Danh mục';
	@override String get uncategorized => 'Chưa phân loại';
	@override String get manage => 'Quản lý';
	@override String get createShortcut => 'Mới';
	@override String get newCategoryHint => 'Tên danh mục mới';
	@override String get createSuccess => 'Đã tạo danh mục';
	@override String get createFailed => 'Tạo danh mục thất bại';
	@override String get nameEmpty => 'Tên danh mục không được để trống';
	@override String get emptyHint => 'Chưa có danh mục nào. Hãy tạo một danh mục để sắp xếp các mục đã tải xuống.';
	@override String get moveTo => 'Chuyển vào danh mục';
	@override String moveToWithCount({required Object count}) => 'Chuyển ${count} mục vào…';
	@override String moveSuccess({required Object title}) => 'Đã chuyển vào ${title}';
	@override String get moveToUncategorizedSuccess => 'Đã chuyển vào Chưa phân loại';
	@override String get moveFailed => 'Di chuyển thất bại';
	@override String get renameTitle => 'Đổi tên danh mục';
	@override String get renameHint => 'Nhập tên danh mục';
	@override String get renameSuccess => 'Đã đổi tên danh mục';
	@override String get renameFailed => 'Đổi tên danh mục thất bại';
	@override String get deleteTitle => 'Xóa danh mục';
	@override String deleteConfirm({required Object title, required Object count}) => 'Xóa danh mục "${title}"? ${count} mục bên trong sẽ chuyển vào Chưa phân loại. Không có tệp nào bị xóa.';
	@override String get deleteSuccess => 'Đã xóa danh mục';
	@override String get deleteFailed => 'Xóa danh mục thất bại';
}

// Path: download.location
class _TranslationsDownloadLocationVi extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadVi extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tải hàng loạt';
	@override String get downloadTaskAlreadyRunning => 'Đang có tác vụ chạy, vui lòng đợi.';
	@override String get userCancelled => 'Người dùng đã hủy';
	@override String get failedToGetVideoInfo => 'Không lấy được thông tin video';
	@override String get failedToGetVideoSource => 'Không lấy được nguồn video';
	@override String get failedToGetGalleryInfo => 'Không lấy được thông tin thư viện';
	@override String get galleryNoImages => 'Thư viện không có ảnh';
	@override String get failedToGetSavePath => 'Không lấy được đường dẫn lưu';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Tải hàng loạt thất bại: ${exception}';
	@override String get selectQuality => 'Chọn chất lượng';
	@override String get downloading => 'Đang tải xuống';
	@override String get downloadResult => 'Kết quả tải xuống';
	@override String selectedVideosCount({required Object count}) => 'Đã chọn ${count} video';
	@override String selectedGalleriesCount({required Object count}) => 'Đã chọn ${count} thư viện';
	@override String get qualityNote => 'Nếu chất lượng đã chọn không khả dụng, chất lượng tốt nhất hiện có sẽ được dùng';
	@override String progress({required Object current, required Object total}) => 'Đang xử lý ${current}/${total}';
	@override String get queued => 'Trong hàng đợi';
	@override String get success => 'Thành công';
	@override String get skipped => 'Đã bỏ qua';
	@override String get failed => 'Thất bại';
	@override String get failureDetails => 'Chi tiết lỗi';
	@override String get reasonPrivateVideo => 'Video riêng tư';
	@override String get reasonAlreadyExists => 'Đã tồn tại';
	@override String get reasonNoSource => 'Không có nguồn tải xuống';
	@override String get reasonNoSavePath => 'Không lấy được đường dẫn lưu';
	@override String get reasonOther => 'Lỗi khác';
	@override String get startDownload => 'Bắt đầu tải xuống';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsVi extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'Thêm thất bại';
	@override String get addSuccess => 'Thêm thành công';
	@override String get deleteFolderFailed => 'Xóa thư mục thất bại';
	@override String get deleteFolderSuccess => 'Xóa thư mục thành công';
	@override String get folderNameCannotBeEmpty => 'Tên thư mục không được để trống';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesVi extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI Reasoning (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude Reasoning (suy luận mở rộng)';
	@override String get gemini => 'Google Gemini (gốc)';
	@override String get geminiReasoning => 'Google Gemini Reasoning (suy nghĩ)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek Reasoning (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeVi extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Thông báo phát: ${message}';
	@override String get networkUnstable => 'Kiểm tra mạng; phát có thể bị giật';
	@override String get audioTrackUnavailable => 'Không có âm thanh; video vẫn tiếp tục phát';
	@override String get hardwareDecodeFellBack => 'Đã chuyển sang giải mã phần mềm; có thể tốn pin hơn';
	@override String get videoDecodeProblem => 'Hãy thử chất lượng khác; hình ảnh có thể bị lỗi';
	@override String get repeatedPlaybackProblems => 'Xuất nhật ký để báo cáo các vấn đề phát lặp lại';
	@override String get issuesSheetTitle => 'Vấn đề khi phát';
	@override String issueOccurrences({required Object count}) => 'Đã xảy ra ${count} lần';
	@override String issueAtPosition({required Object position}) => 'Tại ${position}';
	@override String get noIssuesRecorded => 'Không ghi nhận vấn đề nào';
	@override String get exportLogsAction => 'Xuất nhật ký';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertVi extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Lỗi ghi đệm';
	@override String get sinkDegradedTitle => 'Ghi nhật ký bị suy giảm';
	@override String get sinkDegradedDetail => 'Bộ ghi tệp đang ở trạng thái suy giảm';
	@override String get queueBacklogTitle => 'Hàng đợi ghi bị tồn đọng';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (ngưỡng=${threshold}, có thể làm tăng mức dùng bộ nhớ)';
	@override String get highFlushLatencyTitle => 'Độ trễ ghi đệm cao';
	@override String get droppedTooManyTitle => 'Quá nhiều nhật ký bị bỏ';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (ngưỡng=${threshold})';
	@override String get rateLimitedTitle => 'Đã kích hoạt giới hạn tần suất';
	@override String get exportFailedTitle => 'Lỗi xuất nhật ký';
	@override String get fileNearLimitTitle => 'Tệp nhật ký gần đạt giới hạn kích thước';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (áp lực xoay vòng IO cao hơn)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastVi extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'Dịch vụ nhật ký chưa được khởi tạo';
	@override String get exportSuccess => 'Đã xuất nhật ký. Vui lòng xem lại dữ liệu riêng tư trước khi gửi qua email.';
	@override String exportFailed({required Object error}) => 'Xuất thất bại: ${error}';
	@override String get supportEmailCopied => 'Đã sao chép email hỗ trợ. Dán vào ứng dụng thư và đính kèm nhật ký.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesVi extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'Liên quan';
	@override String get latest => 'Mới nhất';
	@override String get views => 'Lượt xem';
	@override String get likes => 'Lượt thích';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeVi extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Chào mừng';
	@override String get subtitle => 'Hãy bắt đầu hành trình thiết lập cá nhân hóa';
	@override String get description => 'Chỉ vài bước để tùy chỉnh trải nghiệm tốt nhất';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicVi extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt cơ bản';
	@override String get subtitle => 'Cá nhân hóa trải nghiệm của bạn';
	@override String get description => 'Chọn các tùy chọn phù hợp';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkVi extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt mạng';
	@override String get subtitle => 'Cấu hình tùy chọn mạng';
	@override String get description => 'Điều chỉnh theo môi trường mạng';
	@override String get tip => 'Cần khởi động lại sau khi cấu hình thành công để có hiệu lực';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeVi extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt chủ đề';
	@override String get subtitle => 'Chọn giao diện bạn thích';
	@override String get description => 'Cá nhân hóa trải nghiệm hình ảnh';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerVi extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cài đặt trình phát';
	@override String get subtitle => 'Cấu hình điều khiển phát';
	@override String get description => 'Thiết lập nhanh các tùy chọn phát thường dùng';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialVi extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Phát trong không gian';
	@override String get subtitle => 'Xem và duyệt trên kính';
	@override String get description => 'Trên kính, video và thư viện xuất hiện trong không gian quanh bạn thay vì bên trong bảng nổi này';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionVi extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hoàn tất thiết lập';
	@override String get subtitle => 'Bạn đã sẵn sàng bắt đầu hành trình';
	@override String get description => 'Vui lòng đọc và đồng ý với các thỏa thuận liên quan';
	@override String get agreementTitle => 'Thỏa thuận người dùng và quy tắc cộng đồng';
	@override String get agreementDesc => 'Trước khi dùng ứng dụng này, vui lòng đọc kỹ và đồng ý với thỏa thuận người dùng và quy tắc cộng đồng. Các điều khoản này giúp duy trì môi trường tốt.';
	@override String get checkboxTitle => 'Tôi đã đọc và đồng ý với thỏa thuận người dùng và quy tắc cộng đồng';
	@override String get checkboxSubtitle => 'Không đồng ý thì không thể dùng ứng dụng';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonVi extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Các cài đặt này có thể thay đổi bất cứ lúc nào trong Cài đặt';
	@override String get previousStep => 'Bước trước';
	@override String get nextStep => 'Bước tiếp theo';
	@override String get finishSetup => 'Hoàn tất thiết lập';
	@override String get agreeAgreementSnackbar => 'Vui lòng đồng ý với thỏa thuận người dùng và quy tắc cộng đồng trước';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsVi extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Chất lượng cao';
	@override String get fast => 'Nhanh';
	@override String get lite => 'Nhẹ';
	@override String get moreLite => 'Nhẹ hơn';
	@override String get custom => 'Tùy chỉnh';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsVi extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Phù hợp với hầu hết video hoạt hình 1080p, đặc biệt là các trường hợp bị mờ, lấy mẫu lại và nén. Mang lại chất lượng cảm nhận cao nhất.';
	@override String get mode_b_hq => 'Phù hợp với video hoạt hình bị mờ nhẹ hoặc có viền răng cưa do nâng tỉ lệ. Giảm hiệu quả viền răng cưa và hiện tượng răng cưa.';
	@override String get mode_c_hq => 'Phù hợp với nguồn chất lượng cao (như video hoạt hình hoặc phim 1080p gốc). Khử nhiễu và mang lại PSNR cao nhất.';
	@override String get mode_a_a_hq => 'Phiên bản nâng cao của Mode A, mang lại chất lượng cảm nhận tối đa và có thể tái tạo gần như toàn bộ đường nét bị suy giảm. Có thể gây quá sắc hoặc viền răng cưa.';
	@override String get mode_b_b_hq => 'Phiên bản nâng cao của Mode B, mang lại chất lượng cảm nhận cao hơn, tối ưu đường nét và giảm lỗi hình.';
	@override String get mode_c_a_hq => 'Phiên bản nâng cao chất lượng cảm nhận của Mode C, duy trì PSNR cao đồng thời cố tái tạo một số chi tiết đường nét.';
	@override String get mode_a_fast => 'Phiên bản nhanh của Mode A, cân bằng giữa chất lượng và hiệu năng, phù hợp với hầu hết video hoạt hình 1080p.';
	@override String get mode_b_fast => 'Phiên bản nhanh của Mode B, xử lý lỗi hình nhẹ và viền răng cưa với chi phí thấp hơn.';
	@override String get mode_c_fast => 'Phiên bản nhanh của Mode C, khử nhiễu và nâng tỉ lệ nhanh cho nguồn chất lượng cao.';
	@override String get mode_a_a_fast => 'Phiên bản nhanh của Mode A+A, hướng tới chất lượng cảm nhận cao hơn trên thiết bị hạn chế hiệu năng.';
	@override String get mode_b_b_fast => 'Phiên bản nhanh của Mode B+B, tăng cường sửa đường nét và xử lý lỗi hình cho thiết bị hạn chế hiệu năng.';
	@override String get mode_c_a_fast => 'Phiên bản nhanh của Mode C+A, xử lý nhanh nguồn chất lượng cao đồng thời sửa đường nét nhẹ.';
	@override String get upscale_only_s => 'Nâng tỉ lệ x2 cực nhanh chỉ bằng mô hình CNN nhanh nhất, không phục hồi hay khử nhiễu, chi phí hiệu năng tối thiểu.';
	@override String get upscale_deblur_fast => 'Nâng tỉ lệ và làm nét nhanh bằng thuật toán truyền thống không dùng CNN, tốt hơn thuật toán mặc định của trình phát với chi phí hiệu năng rất thấp.';
	@override String get restore_s_only => 'Chỉ phục hồi bằng mô hình CNN nhanh nhất, không nâng tỉ lệ. Phù hợp khi phát ở độ phân giải gốc mà muốn nâng cao chất lượng.';
	@override String get denoise_bilateral_fast => 'Khử nhiễu nhanh bằng lọc song phương truyền thống, cực nhanh, phù hợp xử lý nhiễu nhẹ.';
	@override String get upscale_non_cnn => 'Nâng tỉ lệ nhanh bằng thuật toán truyền thống, chi phí hiệu năng rất thấp, tốt hơn mặc định của trình phát.';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + làm đậm đường nét, bổ sung hiệu ứng làm đậm đường nét cho Mode A nhanh, giúp đường nét nổi bật và cách điệu hơn.';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + làm mảnh đường nét, bổ sung hiệu ứng làm mảnh đường nét cho Mode A chất lượng cao, giúp hình ảnh tinh tế hơn.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesVi extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'Nâng tỉ lệ CNN (cực nhanh)';
	@override String get upscale_deblur_fast => 'Nâng tỉ lệ & làm nét (nhanh)';
	@override String get restore_s_only => 'Phục hồi (cực nhanh)';
	@override String get denoise_bilateral_fast => 'Khử nhiễu song phương (cực nhanh)';
	@override String get upscale_non_cnn => 'Nâng tỉ lệ không CNN (cực nhanh)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + làm đậm đường nét';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + làm mảnh đường nét';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseVi extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Truy cập nhanh';
	@override String get sourcesSection => 'Thư mục';
	@override String get pin => 'Thêm vào truy cập nhanh';
	@override String get unpin => 'Xóa khỏi truy cập nhanh';
	@override String get pinned => 'Đã thêm vào truy cập nhanh';
	@override String get unpinned => 'Đã xóa khỏi truy cập nhanh';
	@override String folderCount({required Object count}) => '${count} thư mục';
	@override String videoCount({required Object count}) => '${count} video';
	@override String imageCount({required Object count}) => '${count} ảnh';
	@override String get emptyFolder => 'Thư mục này trống';
	@override String get videosSection => 'Video';
	@override String get imagesSection => 'Ảnh';
	@override String get galleriesSection => 'Thư viện';
	@override String get filterAll => 'Tất cả';
	@override String get searchInFolder => 'Tìm trong thư mục này';
	@override String get searchHint => 'Tìm theo tên';
	@override String get clearSearch => 'Xóa tìm kiếm';
	@override String searchNoResult({required Object query}) => 'Không có kết quả cho "${query}"';
	@override String viewAllFolders({required Object count}) => 'Xem tất cả ${count} thư mục';
	@override String viewAllVideos({required Object count}) => 'Xem tất cả ${count} video';
	@override String viewAllImages({required Object count}) => 'Xem tất cả ${count} ảnh';
	@override String viewAllGalleries({required Object count}) => 'Xem tất cả ${count} thư viện';
	@override String get location => 'Vị trí';
	@override String get sourceMissing => 'Nguồn này không còn tồn tại';
	@override String get notScannedYet => 'Thư mục này chưa được quét';
	@override String get scanning => 'Đang đọc thư mục này…';
	@override String get deleteFileTitle => 'Xóa tệp này?';
	@override String deleteFileBody({required Object name}) => '"${name}" sẽ bị xóa vĩnh viễn khỏi thiết bị này. Không thể hoàn tác.';
	@override String get hideFolder => 'Ẩn thư mục này';
	@override String get unhideFolder => 'Bỏ ẩn';
	@override String get showHiddenFolders => 'Hiện thư mục đã ẩn';
	@override String get includeDotFolders => 'Quét thư mục bắt đầu bằng .';
	@override String get dotFoldersIncluded => 'Đã bắt đầu quét thư mục bắt đầu bằng .';
	@override String get dotFoldersExcluded => 'Không còn quét thư mục bắt đầu bằng .';
	@override String get showDotFolders => 'Hiện thư mục bắt đầu bằng .';
	@override String dotFoldersSkipped({required Object count}) => 'Ở đây còn ${count} thư mục bắt đầu bằng . chưa được quét';
	@override String get scanDotFoldersAction => 'Bật cho nguồn này';
	@override String get otherAppsPrivateNotice => 'Từ Android 11, không ứng dụng nào đọc được tệp của ứng dụng khác trong Android/data hoặc Android/obb, ứng dụng này cũng không thể vượt qua. Hãy tải xuống hoặc xuất video sang thư mục công khai như Download trong ứng dụng gốc, rồi thêm thư mục đó vào đây. Bộ nhớ đệm khi xem thường bị chia nhỏ và không phát được dù đọc được.';
	@override String get folderHidden => 'Đã ẩn — quá trình quét cũng sẽ bỏ qua';
	@override String get folderUnhidden => 'Đã bỏ ẩn';
	@override String get hiddenFolderBadge => 'Đã ẩn';
	@override String get deleteFolder => 'Xóa thư mục';
	@override String get deleteFolderTitle => 'Xóa thư mục này?';
	@override String deleteFolderBody({required Object name}) => '"${name}" cùng toàn bộ nội dung bên trong sẽ bị xóa vĩnh viễn khỏi thiết bị này. Không thể hoàn tác.';
	@override String get deleteFolderIncludesOthers => 'Các tệp khác bên trong cũng sẽ bị xóa';
	@override String get folderDeleted => 'Đã xóa thư mục';
	@override String get deleteFolderFailed => 'Xóa thất bại — không có quyền, hoặc tệp bên trong đang được sử dụng';
	@override String get deleteGalleryTitle => 'Xóa thư viện này?';
	@override String deleteGalleryBody({required Object name}) => 'Bản ghi tải xuống và các tệp ảnh cục bộ của "${name}" sẽ bị xóa. Không thể hoàn tác.';
	@override String get galleryResourceMissing => 'Tệp cục bộ không còn tồn tại. Đã dọn bản ghi.';
	@override String get viewDownloadDetail => 'Xem chi tiết tải xuống';
	@override String get viewOnlineGallery => 'Xem trên trang web';
	@override String get pickFolderTitle => 'Chọn một thư mục';
	@override String get useThisFolder => 'Dùng thư mục này';
	@override String get noSubfolders => 'Không có thư mục con ở đây';
	@override String get storageRoot => 'Bộ nhớ thiết bị';
	@override String get homeFolder => 'Trang chủ';
	@override String get filesystemRoot => 'Gốc hệ thống tệp';
	@override String get folderUnreadable => 'Không thể đọc thư mục này';
	@override String get setCover => 'Đặt ảnh bìa';
	@override String get setAsFolderCover => 'Dùng làm ảnh bìa thư mục';
	@override String get folderCoverSet => 'Đã cập nhật ảnh bìa thư mục';
	@override String get setFolderCoverPick => 'Đặt ảnh bìa…';
	@override String get restoreAutoCover => 'Khôi phục ảnh bìa tự động';
	@override String get autoCoverRestored => 'Đã khôi phục ảnh bìa tự động';
	@override String get rescanFolder => 'Quét lại thư mục này';
	@override String get coverPickerTitle => 'Chọn một khung hình';
	@override String get folderCoverPickerTitle => 'Chọn ảnh bìa';
	@override String get coverPickerEmpty => 'Thư mục này chưa có ảnh nào. Ảnh thu nhỏ của video có thể vẫn đang được tạo ở chế độ nền.';
	@override String get coverSaved => 'Đã cập nhật ảnh bìa';
	@override String get coverSaveFailed => 'Không thể lưu ảnh bìa';
	@override String get coverUnavailable => 'Không đọc được khung hình video từ tệp này';
	@override String get deleted => 'Đã xóa';
	@override String get deleteFailed => 'Không thể xóa — tệp có thể đang được dùng hoặc không ghi được';
	@override String get openFolder => 'Mở';
	@override String get favorite => 'Thêm vào yêu thích';
	@override String get unfavorite => 'Xóa khỏi yêu thích';
	@override String get favorited => 'Đã thêm vào yêu thích';
	@override String get unfavorited => 'Đã xóa khỏi yêu thích';
	@override String get sortBy => 'Sắp xếp theo';
	@override String get sortAscending => 'Tăng dần';
	@override String get sortDescending => 'Giảm dần';
	@override String get sortFieldName => 'Tên';
	@override String get sortFieldModified => 'Ngày sửa đổi';
	@override String get sortFieldDuration => 'Thời lượng';
	@override String get sortFieldSize => 'Kích thước';
	@override String get sortFieldResolution => 'Độ phân giải';
	@override String get sortFieldFileType => 'Loại tệp';
	@override String get sortFieldFps => 'Tốc độ khung hình';
	@override String get sortFieldFavorited => 'Ngày yêu thích';
	@override String get emptyAllVideos => 'Chưa tìm thấy video nào. Hãy thêm thư mục trong mục Thư mục để bắt đầu.';
	@override String get emptyAllImages => 'Chưa tìm thấy ảnh nào. Hãy thêm thư mục trong mục Thư mục để bắt đầu.';
	@override String get emptyFavorites => 'Chưa có mục yêu thích. Thêm từ menu ⋮ của video.';
	@override String get emptyPinned => 'Chưa có thư mục ghim. Nhấn giữ một thư mục trong mục Thư mục và chọn Ghim.';
	@override String get emptyDownloadedVideos => 'Chưa có video nào tải xuống hoàn tất.';
	@override String get emptyDownloadedGalleries => 'Chưa có thư viện nào tải xuống hoàn tất.';
	@override String get folderInfo => 'Thông tin thư mục';
	@override String get folderInfoName => 'Tên';
	@override String get folderInfoPath => 'Đường dẫn';
	@override String get folderInfoSource => 'Nguồn';
	@override String get folderInfoContents => 'Nội dung';
	@override String get folderInfoSize => 'Kích thước trên đĩa';
	@override String get folderInfoScannedAt => 'Quét lần cuối';
	@override String get folderInfoNeverScanned => 'Chưa quét';
	@override String get folderInfoNoPath => 'Nguồn này không có thư mục để mở';
	@override String get copyPath => 'Sao chép đường dẫn';
	@override String get pathCopied => 'Đã sao chép đường dẫn';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsVi extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingVi extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavVi extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorVi extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mẫu đường dẫn';
	@override String get subtitle => 'Tự động phân thư mục cho tệp tải về';
	@override String get tabVideo => 'Video';
	@override String get tabGallery => 'Thư viện ảnh';
	@override String get tabImage => 'Ảnh đơn';
	@override String get previewLabel => 'Xem trước · kết quả lưu thực sau khi làm sạch';
	@override String get galleryPreviewLabel => 'Xem trước · mẫu thư viện = tên thư mục (ảnh bên trong đặt theo ID)';
	@override String get addFolder => 'Thêm một cấp thư mục';
	@override String get folderCapReached => 'Đã đến giới hạn cấp thư mục';
	@override String get folderSegmentHint => '%authorcache, biến hoặc văn bản cố định';
	@override String get fileSegmentHint => 'vd: %title_%quality';
	@override String videoCapNote({required Object max}) => 'Phần mở rộng (.mp4) tự động thêm · gõ / trong đoạn sẽ tách hai cấp · tối đa ${max} cấp';
	@override String imageCapNote({required Object max}) => 'Phần mở rộng gốc tự động thêm · gõ / trong đoạn sẽ tách hai cấp · tối đa ${max} cấp';
	@override String galleryCapNote({required Object max}) => 'Mẫu thư viện toàn bộ là đoạn thư mục, tối đa ${max} cấp · ảnh bên trong đặt tên theo ID ảnh';
	@override String get trayHint => 'Chạm để chèn tại con trỏ · giữ để xem giải thích';
	@override String get emptySegment => 'Đoạn trống';
	@override String get emptySegmentSaveBlocked => 'Không thể lưu: còn đoạn trống, hãy xóa hoặc điền nội dung';
	@override String get tooManySegmentsSaveBlocked => 'Không thể lưu: quá nhiều đoạn đường dẫn (tối đa 4), hãy gộp hoặc xóa bớt';
	@override String get templateInvalidSaveBlocked => 'Không thể lưu: mẫu có chứa ký tự không hợp lệ';
	@override String get variableInserted => 'Đã chèn biến';
	@override String get savedToast => 'Đã lưu · chỉ ảnh hưởng các lượt tải sau';
	@override String get trayCategoryContent => 'Nội dung';
	@override String get trayCategoryAuthor => 'Tác giả';
	@override String get trayCategoryTime => 'Thời gian';
	@override String get chipAuthorcache => 'Tên tác giả·cố định';
	@override String get chipDate => 'Ngày';
	@override String get chipTime => 'Giờ';
	@override String get chipDatetime => 'Ngày giờ';
	@override String get chipCount => 'Số thứ tự';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestVi extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Làm quen với Quest';
	@override String get intro => 'Xem điều khiển nào làm gì, rồi thử ngay trong không gian của bạn.';
	@override String get videoTab => 'Video không gian';
	@override String get galleryTab => 'Thư viện không gian';
	@override String get scopeNote => 'Dành cho màn hình và cửa sổ trong không gian Quest của bạn. Mở lại bất cứ lúc nào từ cài đặt trình phát.';
	@override String get catalog => 'Khám phá các điều khiển';
	@override String lessonCount({required Object current, required Object total}) => '${current} / ${total}';
	@override String get previous => 'Trước';
	@override String get next => 'Điều khiển tiếp theo';
	@override String get replay => 'Phát lại demo';
	@override String get pauseDemo => 'Tạm dừng demo';
	@override String get resumeDemo => 'Tiếp tục demo';
	@override String get looping => 'Bản demo điều khiển';
	@override String get still => 'Ảnh minh họa tĩnh';
	@override String get done => 'Đã hiểu, tiếp tục';
	@override String get leftController => 'Tay trái';
	@override String get rightController => 'Tay phải';
	@override String get trigger => 'Cò ngón trỏ';
	@override String get grip => 'Nút cầm';
	@override String get bothGrips => 'Cả hai nút cầm';
	@override String get stick => 'Cần điều khiển';
	@override String get handTracking => 'Theo dõi bàn tay';
	@override String get ready => 'Sẵn sàng';
	@override String get press => 'Nhấn';
	@override String get hold => 'Giữ';
	@override String get release => 'Thả';
	@override String get result => 'Xem kết quả';
	@override String get pinch => 'Chụm';
	@override String get selectTitle => 'Chỉ và chọn';
	@override String get selectBody => 'Hướng tia vào một nút, rồi nhấn và thả cò ngón trỏ. Dùng cho phát, cài đặt và thanh trượt trên bảng điều khiển.';
	@override String get selectHint => 'Cò ngón trỏ nằm sau mặt nút. Nút cầm ở tay cầm bên trong dùng để nắm cửa sổ.';
	@override String get panelTitle => 'Hiện hoặc ẩn bảng';
	@override String get panelBody => 'Chỉ ra ngoài bảng điều khiển, rồi nhấn cò ngón trỏ để hiện hoặc ẩn bảng. Với theo dõi bàn tay, chụm nhanh bên ngoài bảng cũng làm điều tương tự.';
	@override String get panelHint => 'Dùng một cú nhấn ngắn, không kéo. Giữ và di chuyển là thao tác kéo, không phải bật/tắt bảng.';
	@override String get playTitle => 'Phát và tạm dừng';
	@override String get playBody => 'Chỉ ra xa bảng điều khiển và nhấn A bên phải hoặc X bên trái để phát hoặc tạm dừng. Bạn cũng có thể chọn nút phát trên bảng.';
	@override String get playHint => 'Phím tắt mặc định này có thể tắt trong cài đặt trình phát không gian. Khi chỉ vào bảng, dữ liệu nhập sẽ chuyển cho bảng.';
	@override String get seekTitle => 'Tua bằng cần gạt';
	@override String get seekBody => 'Đẩy cần gạt sang trái hoặc phải để nhảy 5 giây. Giữ để tua nhanh hơn trong khi xem trước thời điểm đích. Thả ra để xác nhận tua.';
	@override String get seekHint => 'Giữ tia của bộ điều khiển đó ngoài bảng điều khiển. Cần gạt chỉ vào bảng sẽ cuộn bảng thay vào đó.';
	@override String get browseTitle => 'Duyệt bằng cần gạt';
	@override String get browseBody => 'Đẩy cần gạt sang trái hoặc phải để chuyển mục trước hoặc sau; giữ để tiếp tục duyệt. Bạn cũng có thể chọn một ảnh thu nhỏ trong dải phim.';
	@override String get browseHint => 'Video trong thư viện cũng là các mục. Chỉ vào bảng điều khiển sẽ khiến cần gạt cuộn bảng.';
	@override String get swipeTitle => 'Kéo ngang để lật trang';
	@override String get swipeBody => 'Hướng vào hình ảnh, giữ cò ngón trỏ và kéo sang trái. Thả ra sau tín hiệu lật trang để chuyển tiếp; kéo sang phải để lùi lại. Chụm và kéo cũng hoạt động.';
	@override String get swipeHint => 'Hình ảnh phải ở mức 1× để lật trang bằng cách kéo. Video trong thư viện cũng hỗ trợ. Sân khấu đứng yên cho đến khi bạn thả ra.';
	@override String get zoomTitle => 'Thu phóng vào hình ảnh';
	@override String get zoomBody => 'Hướng vào một chi tiết trong hình ảnh, giữ cò ngón trỏ, rồi đẩy cần gạt lên để phóng to hoặc xuống để thu nhỏ. Thu phóng neo tại điểm bạn nhấn.';
	@override String get zoomHint => 'Thao tác này phóng to hình ảnh bên trong cửa sổ của nó. Nếu không giữ hình ảnh, lên/xuống sẽ điều chỉnh khoảng cách xem.';
	@override String get panTitle => 'Di chuyển và khôi phục hình ảnh';
	@override String get panBody => 'Sau khi đã thu phóng, giữ cò ngón trỏ và kéo để nhìn quanh. Nhấn đúp vào hình ảnh để thu phóng lên 2.5× hoặc khôi phục. Với bàn tay, chụm hai lần thật nhanh.';
	@override String get panHint => 'Kéo để di chuyển một hình ảnh đã thu phóng. Khôi phục về 1× trước khi kéo để lật trang.';
	@override String get slideshowTitle => 'Bắt đầu trình chiếu';
	@override String get slideshowBody => 'Trên một hình ảnh, A / X bắt đầu hoặc tạm dừng trình chiếu. Bảng cung cấp khoảng thời gian 3, 5, 10 hoặc 20 giây và chất lượng hình ảnh tiêu chuẩn hoặc gốc.';
	@override String get slideshowHint => 'Trên video trong thư viện, A / X điều khiển việc phát video đó. Phím tắt bộ điều khiển phải được bật trong cài đặt.';
	@override String get moveTitle => 'Nắm và di chuyển màn hình';
	@override String get moveBody => 'Giữ nút cầm ở tay cầm bên trong, di chuyển bộ điều khiển để đặt vị trí màn hình, rồi thả ra. Khi đang xem, bạn có thể nắm màn hình mà không cần chỉ vào nó.';
	@override String get moveHint => 'Chỉ vào cửa sổ ứng dụng hoặc bảng điều khiển sẽ nắm cửa sổ đó trước. Trong video toàn cảnh, việc cầm nắm sẽ điều chỉnh hướng.';
	@override String get scaleTitle => 'Đổi kích thước bằng cả hai tay';
	@override String get scaleBody => 'Giữ cả hai nút cầm. Dang hai tay ra để phóng to màn hình, hoặc chụm lại để thu nhỏ. Với theo dõi bàn tay, giữ thao tác chụm ở cả hai tay.';
	@override String get scaleHint => 'Cho màn hình phẳng hoặc cong, kể cả sân khấu thư viện. Giữ tia ngoài bảng điều khiển. Thao tác này đổi kích thước toàn bộ màn hình.';
	@override String get distanceTitle => 'Điều chỉnh khoảng cách xem';
	@override String get distanceBody => 'Đẩy cần gạt lên để đưa màn hình ra xa, hoặc xuống để kéo lại gần. Khi đang nắm một cửa sổ, lên/xuống sẽ di chuyển cửa sổ đó. Điều chỉnh âm lượng trên bảng.';
	@override String get distanceHint => 'Chỉ ra xa bảng điều khiển. Giữ một hình ảnh sẽ đổi lên/xuống thành thu phóng hình ảnh; video toàn cảnh sẽ điều chỉnh tầm nhìn thay vào đó.';
	@override String get resizeTitle => 'Dùng các cạnh và góc';
	@override String get resizeBody => 'Khung sẽ sáng lên khi tia của bạn tiến gần một cạnh. Giữ cò hoặc chụm vào một cạnh để di chuyển cửa sổ; kéo một góc để đổi kích thước.';
	@override String get resizeHint => 'Hoạt động trên cửa sổ ứng dụng, bảng điều khiển và màn hình. Cửa sổ ứng dụng thay đổi chiều rộng và chiều cao; màn hình giữ nguyên tỉ lệ khung hình.';
	@override String get navigationTitle => 'Quay lại và mở cài đặt';
	@override String get navigationBody => 'B / Y lùi một cấp: đóng cửa sổ bật lên hoặc quay về trang chính của bảng, ẩn bảng, rồi quay về ứng dụng. Nút Menu bên trái mở cài đặt không gian.';
	@override String get navigationHint => 'Nút Meta bên phải thuộc về hệ thống. Chức năng định vị lại của hệ thống đưa tầm nhìn về phía trước trong khi giữ nguyên kích thước và khoảng cách màn hình.';
	@override String get handsTitle => 'Dùng bàn tay';
	@override String get handsBody => 'Khi bật theo dõi bàn tay, hướng tia của hệ thống vào một nút, chụm ngón cái và ngón trỏ, rồi thả ra. Dùng bảng để phát, tua và điều hướng thư viện.';
	@override String get handsHint => 'Chụm bên ngoài để bật/tắt bảng. Chụm một cạnh để di chuyển, một góc để đổi kích thước, hoặc chụm bằng cả hai tay rồi dang ra để phóng to màn hình.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesVi extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Trình phát media';
	@override String get mediaServer => 'Máy chủ media';
	@override String get internetGatewayDevice => 'Bộ định tuyến';
	@override String get basicDevice => 'Thiết bị cơ bản';
	@override String get dimmableLight => 'Đèn thông minh';
	@override String get wlanAccessPoint => 'Điểm truy cập WLAN';
	@override String get wlanConnectionDevice => 'Thiết bị kết nối WLAN';
	@override String get printer => 'Máy in';
	@override String get scanner => 'Máy quét';
	@override String get digitalSecurityCamera => 'Camera an ninh kỹ thuật số';
	@override String get unknownDevice => 'Thiết bị không xác định';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetVi extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetVi._(TranslationsVi root) : this._root = root, super.internal(root);

	final TranslationsVi _root; // ignore: unused_field

	// Translations
	@override String get title => 'Truyền phát từ xa';
	@override String get close => 'Đóng';
	@override String get searchingDevices => 'Đang tìm thiết bị...';
	@override String get searchPrompt => 'Nhấn nút tìm kiếm để tìm lại thiết bị truyền phát';
	@override String get searching => 'Đang tìm kiếm';
	@override String get searchAgain => 'Tìm lại';
	@override String get noDevicesFound => 'Không tìm thấy thiết bị truyền phát nào\nVui lòng đảm bảo các thiết bị cùng mạng';
	@override String get searchingDevicesPrompt => 'Đang tìm thiết bị, vui lòng chờ...';
	@override String get cast => 'Truyền phát';
	@override String connectedTo({required Object deviceName}) => 'Đã kết nối với: ${deviceName}';
	@override String get notConnected => 'Chưa kết nối thiết bị nào';
	@override String get stopCasting => 'Dừng truyền phát';
}

/// The flat map containing all translations for locale <vi>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsVi {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Trang cá nhân',
			'personalProfile.editPersonalProfile' => 'Chỉnh sửa trang cá nhân',
			'personalProfile.avatar' => 'Ảnh đại diện',
			'personalProfile.background' => 'Ảnh nền',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'Không lấy được trang cá nhân: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Độ phân giải đề xuất: ${resolution}, kích thước tệp < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Định dạng được hỗ trợ: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Người dùng Premium có thể dùng ${type} động (${formats})',
			'personalProfile.homepageBackground' => 'Ảnh nền trang chủ',
			'personalProfile.basicInfo' => 'Thông tin cơ bản',
			'personalProfile.nickname' => 'Biệt danh',
			'personalProfile.username' => 'Tên người dùng',
			'personalProfile.copyUsername' => 'Sao chép tên người dùng',
			'personalProfile.usernameCopied' => 'Đã sao chép tên người dùng',
			'personalProfile.personalIntroduction' => 'Giới thiệu cá nhân',
			'personalProfile.noPersonalIntroduction' => 'Không có giới thiệu cá nhân',
			'personalProfile.clickToEdit' => 'Nhấn để chỉnh sửa',
			'personalProfile.privacySettings' => 'Cài đặt quyền riêng tư',
			'personalProfile.hideSensitiveContent' => 'Ẩn nội dung nhạy cảm',
			'personalProfile.hideSensitiveContentDesc' => 'Ẩn mọi video hoặc hình ảnh chứa thẻ nhạy cảm.',
			'personalProfile.notificationSettings' => 'Cài đặt thông báo',
			'personalProfile.contentCommentNotification' => 'Thông báo bình luận nội dung',
			'personalProfile.contentCommentNotificationDesc' => 'Thông báo khi có người bình luận về nội dung của bạn.',
			'personalProfile.commentReplyNotification' => 'Thông báo trả lời bình luận',
			'personalProfile.commentReplyNotificationDesc' => 'Thông báo khi có người trả lời bình luận của bạn.',
			'personalProfile.mentionNotification' => 'Thông báo nhắc đến',
			'personalProfile.mentionNotificationDesc' => 'Thông báo khi có người nhắc đến bạn trong nội dung.',
			'personalProfile.accountInfo' => 'Thông tin tài khoản',
			'personalProfile.registrationTime' => 'Thời gian đăng ký',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'Cập nhật cài đặt thất bại: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'Cập nhật cài đặt thông báo thất bại: ${error}',
			'personalProfile.editNickname' => 'Chỉnh sửa biệt danh',
			'personalProfile.nicknameCannotBeEmpty' => 'Biệt danh không được để trống',
			'personalProfile.changeSuccess' => 'Thay đổi thành công',
			'personalProfile.unsupportedFileFormat' => 'Định dạng tệp không được hỗ trợ',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'Kích thước tệp không được vượt quá ${size}',
			'personalProfile.uploadFailed' => 'Tải lên thất bại',
			'personalProfile.avatarUpdatedSuccessfully' => 'Cập nhật ảnh đại diện thành công',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'Cập nhật ảnh đại diện thất bại: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Cập nhật ảnh nền thành công',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'Cập nhật ảnh nền thất bại: ${error}',
			'personalProfile.editPersonalIntroduction' => 'Chỉnh sửa giới thiệu cá nhân',
			'personalProfile.enterPersonalIntroduction' => 'Vui lòng nhập giới thiệu cá nhân',
			'tutorial.specialFollowFeature' => 'Theo dõi đặc biệt',
			'tutorial.specialFollowDescription' => 'Đánh dấu những tác giả bạn xem nhiều nhất là theo dõi đặc biệt, rồi vào thẳng video mới nhất của họ từ đây.',
			'tutorial.stepsTitle' => 'Ba bước',
			'tutorial.stepFollowAuthor' => 'Nhấn Theo dõi trên trang video, thư viện hoặc trang cá nhân của tác giả.',
			'tutorial.stepPickSpecial' => 'Nhấn Đã theo dõi lần nữa, rồi chọn Theo dõi đặc biệt từ menu.',
			'tutorial.stepSwitchHere' => 'Quay lại đây và chuyển sang tác giả đó bằng trình chọn ảnh đại diện ở trên.',
			'tutorial.specialFollowManagementTip' => 'Quản lý danh sách theo dõi đặc biệt trong Thanh bên - Danh sách theo dõi - Theo dõi đặc biệt.',
			'tutorial.gotIt' => 'Đã hiểu',
			'common.sort' => 'Sắp xếp',
			'common.filter' => 'Bộ lọc',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Hủy',
			'common.select' => 'Chọn',
			'common.save' => 'Lưu',
			'common.delete' => 'Xóa',
			'common.visit' => 'Truy cập',
			'common.loading' => 'Đang tải...',
			'common.scrollToTop' => 'Lên đầu trang',
			'common.privacyHint' => 'Chế độ riêng tư đang bật, nội dung bị ẩn',
			'common.latest' => 'Mới nhất',
			'common.likesCount' => 'Lượt thích',
			'common.viewsCount' => 'Lượt xem',
			'common.popular' => 'Phổ biến',
			'common.trending' => 'Xu hướng',
			'common.commentList' => 'Danh sách bình luận',
			'common.sendComment' => 'Gửi bình luận',
			'common.send' => 'Gửi',
			'common.retry' => 'Thử lại',
			'common.premium' => 'Cao cấp',
			'common.follower' => 'Người theo dõi',
			'common.friend' => 'Bạn bè',
			'common.video' => 'Video',
			'common.following' => 'Đang theo dõi',
			'common.expand' => 'Mở rộng',
			'common.collapse' => 'Thu gọn',
			'common.cancelFriendRequest' => 'Hủy yêu cầu',
			'common.cancelSpecialFollow' => 'Hủy theo dõi đặc biệt',
			'common.addFriend' => 'Thêm bạn',
			'common.removeFriend' => 'Xóa bạn',
			'common.followed' => 'Đã theo dõi',
			'common.follow' => 'Theo dõi',
			'common.unfollow' => 'Bỏ theo dõi',
			'common.specialFollow' => 'Theo dõi đặc biệt',
			'common.specialFollowed' => 'Đã theo dõi đặc biệt',
			'common.gallery' => 'Thư viện',
			'common.playlist' => 'Danh sách phát',
			'common.commentPostedSuccessfully' => 'Đã đăng bình luận',
			'common.commentPostedFailed' => 'Đăng bình luận thất bại',
			'common.success' => 'Thành công',
			'common.commentDeletedSuccessfully' => 'Đã xóa bình luận',
			'common.commentUpdatedSuccessfully' => 'Cập nhật bình luận thành công',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} bình luận', other: '${n} bình luận', ), 
			'common.writeYourCommentHere' => 'Viết bình luận tại đây...',
			'common.tmpNoReplies' => 'Chưa có trả lời',
			'common.loadMore' => 'Tải thêm',
			'common.loadingMore' => 'Đang tải thêm...',
			'common.noMoreDatas' => 'Không còn dữ liệu',
			'common.selectTranslationLanguage' => 'Chọn ngôn ngữ dịch',
			'common.translate' => 'Dịch',
			'common.translateFailedPleaseTryAgainLater' => 'Dịch thất bại, vui lòng thử lại sau',
			'common.translationResult' => 'Kết quả dịch',
			'common.justNow' => 'Vừa xong',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} phút trước', other: '${n} phút trước', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} giờ trước', other: '${n} giờ trước', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} ngày trước', other: '${n} ngày trước', ), 
			'common.editedAt' => ({required Object num}) => 'Đã chỉnh sửa ${num}',
			'common.editComment' => 'Chỉnh sửa bình luận',
			'common.commentUpdated' => 'Đã cập nhật bình luận',
			'common.replyComment' => 'Trả lời bình luận',
			'common.reply' => 'Trả lời',
			'common.edit' => 'Chỉnh sửa',
			'common.unknownUser' => 'Người dùng không xác định',
			'common.me' => 'Tôi',
			'common.author' => 'Tác giả',
			'common.admin' => 'Quản trị viên',
			'common.viewReplies' => ({required Object num}) => 'Xem trả lời (${num})',
			'common.hideReplies' => 'Ẩn trả lời',
			'common.confirmDelete' => 'Xác nhận xóa',
			'common.areYouSureYouWantToDeleteThisItem' => 'Bạn có chắc muốn xóa mục này?',
			'common.tmpNoComments' => 'Chưa có bình luận',
			'common.refresh' => 'Làm mới',
			'common.back' => 'Quay lại',
			'common.tips' => 'Mẹo',
			'common.linkIsEmpty' => 'Liên kết trống',
			'common.linkCopiedToClipboard' => 'Đã sao chép liên kết',
			'common.imageCopiedToClipboard' => 'Đã sao chép ảnh vào clipboard',
			'common.copyImageFailed' => 'Sao chép ảnh thất bại',
			'common.mobileSaveImageIsUnderDevelopment' => 'Tính năng lưu ảnh trên di động đang được phát triển',
			'common.imageSavedTo' => 'Đã lưu ảnh vào',
			'common.saveImageFailed' => 'Lưu ảnh thất bại',
			'common.close' => 'Đóng',
			'common.more' => 'Thêm',
			'common.unknownError' => 'Lỗi không xác định',
			'common.moreFeaturesToBeDeveloped' => 'Nhiều tính năng khác đang được phát triển',
			'common.all' => 'Tất cả',
			'common.selectedRecords' => ({required Object num}) => 'Đã chọn ${num} bản ghi',
			'common.cancelSelectAll' => 'Bỏ chọn tất cả',
			'common.selectAll' => 'Chọn tất cả',
			'common.invertSelection' => 'Đảo lựa chọn',
			'common.exitEditMode' => 'Thoát chế độ chỉnh sửa',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Bạn có chắc muốn xóa ${num} mục đã chọn?',
			'common.searchHistoryRecords' => 'Tìm kiếm bản ghi lịch sử...',
			'common.settings' => 'Cài đặt',
			'common.subscriptions' => 'Đăng ký',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} video', other: '${n} video', ), 
			'common.share' => 'Chia sẻ',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Bạn có chắc muốn chia sẻ danh sách phát này?',
			'common.editTitle' => 'Chỉnh sửa tiêu đề',
			'common.editMode' => 'Chế độ chỉnh sửa',
			'common.pleaseEnterNewTitle' => 'Vui lòng nhập tiêu đề mới',
			'common.createPlayList' => 'Tạo danh sách phát',
			'common.create' => 'Tạo',
			'common.checkNetworkSettings' => 'Kiểm tra cài đặt mạng',
			'common.general' => 'Chung',
			'common.r18' => 'R18',
			'common.sensitive' => 'Nhạy cảm',
			'common.year' => 'Năm',
			'common.month' => 'Tháng',
			'common.tag' => 'Thẻ',
			'common.private' => 'Riêng tư',
			'common.noTitle' => 'Không có tiêu đề',
			'common.search' => 'Tìm kiếm',
			'common.noContent' => 'Không có nội dung',
			'common.recording' => 'Đang ghi',
			'common.paused' => 'Đã tạm dừng',
			'common.clear' => 'Xóa',
			'common.clearSelection' => 'Bỏ chọn',
			'common.selectItemsToContinue' => 'Chọn mục để tiếp tục',
			'common.andMoreItems' => ({required Object num}) => 'và ${num} mục nữa',
			'common.batchDelete' => 'Xóa hàng loạt',
			'common.user' => 'Người dùng',
			'common.post' => 'Bài viết',
			'common.seconds' => 'Giây',
			'common.comingSoon' => 'Sắp ra mắt',
			'common.confirm' => 'Xác nhận',
			'common.hour' => 'Giờ',
			'common.minute' => 'Phút',
			'common.clickToRefresh' => 'Nhấn để làm mới',
			'common.history' => 'Lịch sử',
			'common.favorites' => 'Yêu thích',
			'common.friends' => 'Bạn bè',
			'common.playList' => 'Danh sách phát',
			'common.checkLicense' => 'Kiểm tra giấy phép',
			'common.logout' => 'Đăng xuất',
			'common.fensi' => 'Người hâm mộ',
			'common.accept' => 'Chấp nhận',
			'common.reject' => 'Từ chối',
			'common.clearAllHistory' => 'Xóa toàn bộ lịch sử',
			'common.clearAllHistoryConfirm' => 'Bạn có chắc muốn xóa toàn bộ lịch sử?',
			'common.followingList' => 'Danh sách đang theo dõi',
			'common.followersList' => 'Danh sách người theo dõi',
			'common.follows' => 'Đang theo dõi',
			'common.fans' => 'Người hâm mộ',
			'common.followsAndFans' => 'Đang theo dõi và người hâm mộ',
			'common.numViews' => 'Lượt xem',
			'common.updatedAt' => 'Cập nhật lúc',
			'common.publishedAt' => 'Đăng lúc',
			'common.externalVideo' => 'Video ngoài',
			'common.originalText' => 'Văn bản gốc',
			'common.showOriginalText' => 'Hiện văn bản gốc',
			'common.showProcessedText' => 'Hiện văn bản đã xử lý',
			'common.preview' => 'Xem trước',
			'common.rules' => 'Quy tắc',
			'common.agree' => 'Đồng ý',
			'common.disagree' => 'Không đồng ý',
			'common.agreeToRules' => 'Đồng ý với quy tắc',
			'common.tapToReread' => 'Chạm để đọc lại',
			'common.markdownSyntaxHelp' => 'Trợ giúp cú pháp Markdown',
			'common.previewContent' => 'Xem trước nội dung',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Vượt quá giới hạn độ dài tối đa (${max})',
			'common.agreeToCommunityRules' => 'Đồng ý với quy tắc cộng đồng',
			'common.createPost' => 'Tạo bài viết',
			'common.title' => 'Tiêu đề',
			'common.enterTitle' => 'Vui lòng nhập tiêu đề',
			'common.content' => 'Nội dung',
			'common.enterContent' => 'Vui lòng nhập nội dung',
			'common.writeYourContentHere' => 'Vui lòng nhập nội dung...',
			'common.tagBlacklist' => 'Danh sách thẻ chặn',
			'common.noData' => 'Không có dữ liệu',
			'common.tagLimit' => 'Giới hạn thẻ',
			'common.enableFloatingButtons' => 'Bật nút nổi',
			'common.disableFloatingButtons' => 'Tắt nút nổi',
			'common.enabledFloatingButtons' => 'Đã bật nút nổi',
			'common.disabledFloatingButtons' => 'Đã tắt nút nổi',
			'common.pendingCommentCount' => 'Số bình luận đang chờ',
			'common.joined' => ({required Object str}) => 'Tham gia ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Hoạt động lần cuối ${str}',
			'common.download' => 'Tải xuống',
			'common.selectQuality' => 'Chọn chất lượng',
			'common.videoQualitySource' => 'Nguồn',
			'common.selectImageQuality' => 'Chọn chất lượng ảnh',
			'common.imageQualityStandard' => 'Tiêu chuẩn',
			'common.imageQualityOriginal' => 'Nguyên bản',
			'common.selectDateRange' => 'Chọn khoảng ngày',
			'common.selectDateRangeHint' => 'Chọn khoảng ngày, mặc định là 30 ngày gần nhất',
			'common.clearDateRange' => 'Xóa khoảng ngày',
			'common.deleteRecordsInDateRange' => 'Xóa bản ghi trong khoảng này',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'Bạn có chắc muốn xóa ${num} bản ghi lịch sử trong khoảng ngày này? Thao tác này không thể hoàn tác.',
			'common.noHistoryRecordsInRange' => 'Không có bản ghi lịch sử trong khoảng ngày này',
			'common.followSuccessClickAgainToSpecialFollow' => 'Đã theo dõi, nhấn lần nữa để theo dõi đặc biệt',
			'common.specialFollowTip' => 'Đã thêm vào theo dõi đặc biệt — chọn từ danh sách ở góc trên bên phải trang Đăng ký để truy cập nhanh',
			'common.exitConfirmTip' => 'Bạn có chắc muốn thoát?',
			'common.error' => 'Lỗi',
			'common.taskRunning' => 'Đang có tác vụ chạy, vui lòng đợi.',
			'common.operationCancelled' => 'Đã hủy thao tác.',
			'common.unsavedChanges' => 'Có thay đổi chưa lưu',
			'common.specialFollowsManagementTip' => 'Kéo tay cầm để sắp xếp lại • Nhấn nút để xóa',
			'common.specialFollowsManagement' => 'Quản lý theo dõi đặc biệt',
			'common.removeSpecialFollow' => 'Hủy theo dõi đặc biệt',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => 'Hủy theo dõi đặc biệt với ${name}?',
			'common.noSpecialFollows' => 'Chưa có theo dõi đặc biệt',
			'common.createTimeDesc' => 'Thời gian tạo giảm dần',
			'common.createTimeAsc' => 'Thời gian tạo tăng dần',
			'common.pagination.totalItems' => ({required Object num}) => 'Tổng ${num} mục',
			'common.pagination.jumpToPage' => 'Chuyển tới trang',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Vui lòng nhập số trang (1-${max})',
			'common.pagination.pageNumber' => 'Số trang',
			'common.pagination.jump' => 'Chuyển',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Vui lòng nhập số trang hợp lệ (1-${max})',
			'common.pagination.invalidInput' => 'Vui lòng nhập số trang hợp lệ',
			'common.pagination.waterfall' => 'Thác nước',
			'common.pagination.pagination' => 'Phân trang',
			'common.notice' => 'Thông báo',
			'common.detail' => 'Chi tiết',
			'common.parseExceptionDestopHint' => ' - Người dùng máy tính có thể cấu hình proxy trong cài đặt',
			'common.iwaraTags' => 'Thẻ Iwara',
			'common.tagInfo' => 'Thông tin thẻ',
			'common.tagOriginalKey' => 'Thẻ gốc',
			'common.tagTranslation' => 'Bản dịch',
			'common.copy' => 'Sao chép',
			'common.selectCopy' => 'Chọn & Sao chép',
			'common.copiedToClipboard' => 'Đã sao chép vào clipboard',
			'common.showOriginalTag' => 'Hiện thẻ gốc',
			'common.showTranslatedTag' => 'Hiện bản dịch',
			'common.tagTranslationFeedback' => 'Còn nghi ngờ về bản dịch? Gửi phản hồi',
			'common.tagLocalizationGuideTitle' => 'Về bản địa hóa thẻ',
			'common.tagLocalizationGuideContent' => 'Ứng dụng hiển thị thẻ gốc của Iwara (ví dụ: mother) bằng tên theo ngôn ngữ hiện tại của bạn.\n\n• Khi tìm kiếm thẻ, cả bản dịch và thẻ gốc đều được khớp.\n• Nhấn giữ / nhấp chuột phải vào thẻ để xem và sao chép khóa gốc cùng bản dịch.\n• Bản dịch do cộng đồng duy trì và chỉ ở mức tốt nhất có thể — có thể còn sai sót.',
			'common.likeThisVideo' => 'Thích video này',
			'common.likeThisGallery' => 'Thích thư viện này',
			'common.operation' => 'Thao tác',
			'common.replies' => 'Trả lời',
			'common.externalLinkWarning' => 'Cảnh báo liên kết ngoài',
			'common.externalLinkWarningMessage' => 'Bạn sắp mở một liên kết ngoài không thuộc iwara.tv. Hãy cẩn trọng và đảm bảo liên kết an toàn trước khi tiếp tục.',
			'common.continueToExternalLink' => 'Tiếp tục',
			'common.cancelExternalLink' => 'Hủy',
			'auth.login' => 'Đăng nhập',
			'auth.logout' => 'Đăng xuất',
			'auth.email' => 'Email',
			'auth.password' => 'Mật khẩu',
			'auth.loginOrRegister' => 'Đăng nhập / Đăng ký',
			'auth.register' => 'Đăng ký',
			'auth.pleaseEnterEmail' => 'Vui lòng nhập email',
			'auth.pleaseEnterPassword' => 'Vui lòng nhập mật khẩu',
			'auth.passwordMustBeAtLeast6Characters' => 'Mật khẩu phải có ít nhất 6 ký tự',
			'auth.pleaseEnterCaptcha' => 'Vui lòng nhập mã xác nhận',
			'auth.captcha' => 'Mã xác nhận',
			'auth.refreshCaptcha' => 'Làm mới mã xác nhận',
			'auth.captchaNotLoaded' => 'Chưa tải mã xác nhận',
			'auth.loginSuccess' => 'Đăng nhập thành công',
			'auth.loginSuccessProfilePending' => 'Đã đăng nhập. Đang tải hồ sơ…',
			'auth.emailVerificationSent' => 'Đã gửi email xác minh',
			'auth.notLoggedIn' => 'Chưa đăng nhập',
			'auth.clickToLogin' => 'Nhấn để đăng nhập',
			'auth.logoutConfirmation' => 'Bạn có chắc muốn đăng xuất?',
			'auth.logoutSuccess' => 'Đăng xuất thành công',
			'auth.logoutFailed' => 'Đăng xuất thất bại',
			'auth.usernameOrEmail' => 'Tên người dùng hoặc Email',
			'auth.pleaseEnterUsernameOrEmail' => 'Vui lòng nhập tên người dùng hoặc email',
			'auth.rememberMe' => 'Ghi nhớ tên người dùng',
			'auth.registerNoticeTitle' => 'Đăng ký trên trang web chính thức',
			'auth.registerNoticeDescription' => 'Không còn hỗ trợ đăng ký trong ứng dụng. Vui lòng tới trang web chính thức của Iwara để tạo tài khoản, sau đó quay lại đây để đăng nhập.',
			'auth.registerNoticeReturnTip' => 'Sau khi đăng ký, hãy quay lại đây và đăng nhập bằng tài khoản.',
			'auth.goToOfficialWebsite' => 'Tới trang web chính thức',
			'errors.error' => 'Lỗi',
			'errors.required' => 'Trường này là bắt buộc',
			'errors.invalidEmail' => 'Địa chỉ email không hợp lệ',
			'errors.networkError' => 'Lỗi mạng, vui lòng thử lại',
			'errors.errorWhileFetching' => 'Đã xảy ra lỗi khi tải',
			'errors.commentCanNotBeEmpty' => 'Nội dung bình luận không được để trống',
			'errors.errorWhileFetchingReplies' => 'Lỗi khi tải trả lời, vui lòng kiểm tra kết nối mạng',
			'errors.canNotFindCommentController' => 'Không tìm thấy bộ điều khiển bình luận',
			'errors.errorWhileLoadingGallery' => 'Lỗi khi tải thư viện',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'Sao lại không có dữ liệu? Không thể như vậy được :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Định dạng ảnh không được hỗ trợ: ${str}',
			'errors.invalidGalleryId' => 'ID thư viện không hợp lệ',
			'errors.translationFailedPleaseTryAgainLater' => 'Dịch thất bại, vui lòng thử lại sau',
			'errors.errorOccurred' => 'Đã xảy ra lỗi, vui lòng thử lại sau.',
			'errors.errorOccurredWhileProcessingRequest' => 'Đã xảy ra lỗi khi xử lý yêu cầu',
			'errors.errorWhileFetchingDatas' => 'Lỗi khi tải dữ liệu, vui lòng thử lại sau',
			'errors.serviceNotInitialized' => 'Dịch vụ chưa được khởi tạo',
			'errors.unknownType' => 'Loại không xác định',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Lỗi khi mở liên kết: ${link}',
			'errors.invalidUrl' => 'URL không hợp lệ',
			'errors.failedToOperate' => 'Thao tác thất bại',
			'errors.permissionDenied' => 'Quyền bị từ chối',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'Bạn không có quyền truy cập tài nguyên này',
			'errors.loginFailed' => 'Đăng nhập thất bại',
			'errors.unknownError' => 'Lỗi không xác định',
			'errors.sessionExpired' => 'Phiên đã hết hạn',
			'errors.failedToFetchCaptcha' => 'Lấy mã xác nhận thất bại',
			'errors.emailAlreadyExists' => 'Email đã tồn tại',
			'errors.invalidCaptcha' => 'Mã xác nhận không hợp lệ',
			'errors.registerFailed' => 'Đăng ký thất bại',
			'errors.failedToFetchComments' => 'Lấy bình luận thất bại',
			'errors.failedToFetchImageDetail' => 'Lấy chi tiết ảnh thất bại',
			'errors.failedToFetchImageList' => 'Lấy danh sách ảnh thất bại',
			'errors.failedToFetchData' => 'Lấy dữ liệu thất bại',
			'errors.invalidParameter' => 'Tham số không hợp lệ',
			'errors.pleaseLoginFirst' => 'Vui lòng đăng nhập trước',
			'errors.errorWhileLoadingPost' => 'Lỗi khi tải bài viết',
			'errors.errorWhileLoadingPostDetail' => 'Lỗi khi tải chi tiết bài viết',
			'errors.invalidPostId' => 'ID bài viết không hợp lệ',
			'errors.forceUpdateNotPermittedToGoBack' => 'Đang ở trạng thái buộc cập nhật, không thể quay lại',
			'errors.pleaseLoginAgain' => 'Vui lòng đăng nhập lại',
			'errors.invalidLogin' => 'Đăng nhập không hợp lệ, vui lòng kiểm tra email và mật khẩu',
			'errors.tooManyRequests' => 'Quá nhiều yêu cầu, vui lòng thử lại sau',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Vượt quá độ dài tối đa: ${max}',
			'errors.contentCanNotBeEmpty' => 'Nội dung không được để trống',
			'errors.titleCanNotBeEmpty' => 'Tiêu đề không được để trống',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Quá nhiều yêu cầu, vui lòng thử lại sau, còn lại',
			'errors.remainingHours' => ({required Object num}) => '${num} giờ',
			'errors.remainingMinutes' => ({required Object num}) => '${num} phút',
			'errors.remainingSeconds' => ({required Object num}) => '${num} giây',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Vượt quá giới hạn thẻ, giới hạn: ${limit}',
			'errors.failedToRefresh' => 'Làm mới thất bại',
			'errors.noPermission' => 'Không có quyền',
			'errors.resourceNotFound' => 'Không tìm thấy tài nguyên',
			'errors.failedToSaveCredentials' => 'Lưu thông tin đăng nhập thất bại',
			'errors.failedToLoadSavedCredentials' => 'Tải thông tin đăng nhập đã lưu thất bại',
			'errors.notFound' => 'Không tìm thấy nội dung hoặc nội dung đã bị xóa',
			'errors.network.basicPrefix' => 'Lỗi mạng - ',
			'errors.network.failedToConnectToServer' => 'Kết nối tới máy chủ thất bại',
			'errors.network.serverNotAvailable' => 'Máy chủ không khả dụng',
			'errors.network.requestTimeout' => 'Yêu cầu quá thời gian',
			'errors.network.unexpectedError' => 'Lỗi không mong đợi',
			'errors.network.invalidResponse' => 'Phản hồi không hợp lệ',
			'errors.network.invalidRequest' => 'Yêu cầu không hợp lệ',
			'errors.network.invalidUrl' => 'URL không hợp lệ',
			'errors.network.invalidMethod' => 'Phương thức không hợp lệ',
			'errors.network.invalidHeader' => 'Header không hợp lệ',
			'errors.network.invalidBody' => 'Nội dung không hợp lệ',
			'errors.network.invalidStatusCode' => 'Mã trạng thái không hợp lệ',
			'errors.network.serverError' => 'Lỗi máy chủ',
			'errors.network.requestCanceled' => 'Yêu cầu đã bị hủy',
			'errors.network.invalidPort' => 'Cổng không hợp lệ',
			'errors.network.proxyPortError' => 'Lỗi cổng proxy',
			'errors.network.connectionRefused' => 'Kết nối bị từ chối',
			'errors.network.networkUnreachable' => 'Không thể truy cập mạng',
			'errors.network.noRouteToHost' => 'Không có tuyến tới máy chủ',
			'errors.network.connectionFailed' => 'Kết nối thất bại',
			'errors.network.sslConnectionFailed' => 'Kết nối SSL thất bại, vui lòng kiểm tra cài đặt mạng',
			'friends.clickToRestoreFriend' => 'Nhấn để khôi phục bạn bè',
			'friends.friendsList' => 'Danh sách bạn bè',
			'friends.friendRequests' => 'Yêu cầu kết bạn',
			'friends.friendRequestsList' => 'Danh sách yêu cầu kết bạn',
			'friends.removingFriend' => 'Đang xóa bạn bè...',
			'friends.failedToRemoveFriend' => 'Xóa bạn bè thất bại',
			'friends.cancelingRequest' => 'Đang hủy yêu cầu kết bạn...',
			'friends.failedToCancelRequest' => 'Hủy yêu cầu kết bạn thất bại',
			'authorProfile.noMoreDatas' => 'Không còn dữ liệu',
			'authorProfile.userProfile' => 'Hồ sơ người dùng',
			'favorites.clickToRestoreFavorite' => 'Nhấn để khôi phục yêu thích',
			'favorites.myFavorites' => 'Yêu thích của tôi',
			'favorites.batchCancelFavorite' => 'Xóa các mục yêu thích đã chọn',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'Xóa ${count} mục đã chọn khỏi yêu thích? Sau đó có thể khôi phục bằng cách nhấn vào thẻ.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => 'Đã xóa ${count} mục khỏi yêu thích',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => 'Đã xóa ${success} mục, ${failed} mục thất bại',
			'galleryDetail.browseInSpace' => 'Duyệt trong không gian',
			'galleryDetail.galleryDetail' => 'Chi tiết thư viện',
			'galleryDetail.viewGalleryDetail' => 'Xem chi tiết thư viện',
			'galleryDetail.zoomReset' => 'Đặt lại thu phóng',
			'galleryDetail.copyLink' => 'Sao chép liên kết',
			'galleryDetail.copyImage' => 'Sao chép ảnh',
			'galleryDetail.saveAs' => 'Lưu thành',
			'galleryDetail.saveToAlbum' => 'Lưu vào album',
			'galleryDetail.publishedAt' => 'Đăng lúc',
			'galleryDetail.viewsCount' => 'Số lượt xem',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Giới thiệu chức năng thư viện ảnh',
			'galleryDetail.rightClickToSaveSingleImage' => 'Nhấp chuột phải để lưu ảnh đơn',
			'galleryDetail.batchSave' => 'Lưu hàng loạt',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Phím trái và phải để chuyển',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Phím lên và xuống để thu phóng',
			'galleryDetail.mouseWheelToSwitch' => 'Con lăn chuột để chuyển',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + Con lăn chuột để thu phóng',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'Nhiều tính năng khác đang chờ khám phá...',
			'galleryDetail.authorOtherGalleries' => 'Thư viện khác của tác giả',
			'galleryDetail.relatedGalleries' => 'Thư viện liên quan',
			'galleryDetail.authorNoOtherGalleries' => 'Tác giả này không có thư viện nào khác',
			'galleryDetail.noRelatedGalleries' => 'Không có thư viện liên quan',
			'galleryDetail.scrollLeft' => 'Cuộn sang trái',
			'galleryDetail.scrollRight' => 'Cuộn sang phải',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Nhấn vào mép trái và phải để chuyển ảnh',
			'galleryDetail.rotateToLandscape' => 'Toàn màn hình ngang',
			'galleryDetail.backToPortrait' => 'Quay lại dọc',
			'playList.myPlayList' => 'Danh sách phát của tôi',
			'playList.friendlyTips' => 'Gợi ý hữu ích',
			'playList.dearUser' => 'Người dùng thân mến',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'Hệ thống danh sách phát của Iwara vẫn chưa hoàn thiện',
			'playList.notSupportSetCover' => 'Không hỗ trợ đặt ảnh bìa',
			'playList.notSupportDeleteList' => 'Không hỗ trợ xóa danh sách',
			'playList.notSupportSetPrivate' => 'Không hỗ trợ đặt riêng tư',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Có... danh sách đã tạo sẽ luôn tồn tại và hiển thị với mọi người',
			'playList.smallSuggestion' => 'Gợi ý nhỏ',
			'playList.useLikeToCollectContent' => 'Nếu bạn quan tâm đến quyền riêng tư hơn, nên dùng chức năng "thích" để lưu nội dung',
			'playList.welcomeToDiscussOnGitHub' => 'Nếu bạn có gợi ý hoặc ý tưởng khác, hoan nghênh thảo luận trên GitHub!',
			'playList.iUnderstand' => 'Đã hiểu',
			'playList.searchPlaylists' => 'Tìm kiếm danh sách phát...',
			'playList.newPlaylistName' => 'Tên danh sách phát mới',
			'playList.createNewPlaylist' => 'Tạo danh sách phát mới',
			'playList.videos' => 'Video',
			'search.googleSearchScope' => 'Phạm vi tìm kiếm',
			'search.searchTags' => 'Tìm kiếm thẻ...',
			'search.contentRating' => 'Xếp hạng nội dung',
			'search.removeTag' => 'Xóa thẻ',
			'search.pleaseEnterSearchContent' => 'Vui lòng nhập nội dung tìm kiếm',
			'search.exactMatch' => 'Chính xác',
			'search.exactMatchOnHint' => 'Đang khớp chính xác cụm từ, đồng thời tìm cả tiêu đề tiếng Trung và tiếng Nhật. Chạm để tìm rộng hơn.',
			'search.exactMatchOffHint' => 'Đang khớp lỏng — Iwara tách các từ ra. Chạm để khớp chính xác cụm từ.',
			'search.searchHistory' => 'Lịch sử tìm kiếm',
			'search.searchSuggestion' => 'Gợi ý tìm kiếm',
			'search.usedTimes' => 'Số lần sử dụng',
			'search.lastUsed' => 'Dùng gần đây',
			'search.noSearchHistoryRecords' => 'Không có lịch sử tìm kiếm',
			'search.clearSearchHistoryConfirm' => 'Bạn có chắc muốn xóa toàn bộ lịch sử tìm kiếm? Thao tác này không thể hoàn tác.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Chưa hỗ trợ loại tìm kiếm hiện tại ${searchType}, vui lòng chờ bản cập nhật',
			'search.searchResult' => 'Kết quả tìm kiếm',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Loại tìm kiếm không được hỗ trợ: ${searchType}',
			'search.googleSearch' => 'Tìm kiếm Google',
			'search.googleSearchHint' => ({required Object webName}) => 'Chức năng tìm kiếm của ${webName} không dễ dùng? Hãy thử Tìm kiếm Google!',
			'search.googleSearchDescription' => 'Dùng toán tử tìm kiếm :site của Google Search để tìm nội dung trên trang web. Rất hữu ích khi tìm video, thư viện, danh sách phát và người dùng.',
			'search.googleSearchKeywordsHint' => 'Nhập từ khóa để tìm kiếm',
			'search.openLinkJump' => 'Mở chuyển tiếp liên kết',
			'search.googleSearchButton' => 'Tìm kiếm Google',
			'search.pleaseEnterSearchKeywords' => 'Vui lòng nhập từ khóa tìm kiếm',
			'search.googleSearchQueryCopied' => 'Đã sao chép truy vấn tìm kiếm vào bộ nhớ tạm',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Không mở được trình duyệt: ${error}',
			'search.searchRequestTimeout' => 'Yêu cầu quá thời gian, vui lòng thử lại sau',
			'search.searchCannotConnectToServer' => 'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng',
			'search.searchNetworkError' => 'Kết nối mạng thất bại, vui lòng kiểm tra cài đặt mạng hoặc thử lại sau',
			'search.searchFailedPleaseRetry' => 'Tìm kiếm thất bại, vui lòng thử lại sau',
			'mediaList.personalIntroduction' => 'Giới thiệu',
			'settings.listViewMode' => 'Chế độ xem danh sách',
			'settings.previewEffect' => 'Xem trước hiệu ứng',
			'settings.useTraditionalPaginationMode' => 'Dùng chế độ phân trang truyền thống',
			'settings.useTraditionalPaginationModeDesc' => 'Bật chế độ phân trang truyền thống, tắt chế độ thác nước. Có hiệu lực sau khi hiển thị lại trang hoặc khởi động lại ứng dụng',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Hiển thị thanh tiến trình video khi ẩn thanh công cụ',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Cấu hình này quyết định thanh tiến trình video có hiển thị khi thanh công cụ bị ẩn hay không.',
			'settings.seekPreviewSize' => 'Kích thước xem trước khi tua',
			'settings.seekPreviewSizeDesc' => 'Cửa sổ xem trước phía trên thanh tiến trình lớn đến mức nào. Nó vốn đã theo kích thước trình phát và tỉ lệ khung hình của video; mục này chỉ tinh chỉnh thêm.',
			'settings.seekPreviewSizeSmall' => 'Nhỏ',
			'settings.seekPreviewSizeStandard' => 'Tiêu chuẩn',
			'settings.seekPreviewSizeLarge' => 'Lớn',
			'settings.seekPreviewSizeStandardDesc' => 'Kích thước suy ra từ trình phát và video',
			'settings.showFullscreenUpNextHint' => 'Hiển thị tay cầm "Tiếp theo"',
			'settings.showFullscreenUpNextHintDesc' => 'Hiển thị một tay cầm nhỏ ở cạnh phải trình phát để mở ngăn hàng đợi (nguồn / danh sách phát / xem sau). Khi tắt, không còn cách nào khác để mở.',
			'settings.basicSettings' => 'Cài đặt cơ bản',
			'settings.personalizedSettings' => 'Cài đặt cá nhân hóa',
			'settings.otherSettings' => 'Cài đặt khác',
			'settings.searchConfig' => 'Cấu hình tìm kiếm',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Cấu hình này quyết định cấu hình trước đó có được dùng lại khi phát video lần nữa hay không.',
			'settings.playControl' => 'Điều khiển phát',
			'settings.playbackSpeedSettings' => 'Phát và tốc độ',
			'settings.playbackBehaviorSettings' => 'Hành vi phát',
			'settings.enhancementSettings' => 'Rạp hát và nâng cao',
			'settings.fastForwardTime' => 'Thời gian tua tới',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'Thời gian tua tới phải là số nguyên dương.',
			'settings.rewindTime' => 'Thời gian tua lại',
			_ => null,
		} ?? switch (path) {
			'settings.rewindTimeMustBeAPositiveInteger' => 'Thời gian tua lại phải là số nguyên dương.',
			'settings.longPressPlaybackSpeed' => 'Tốc độ phát khi nhấn giữ',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'Tốc độ phát khi nhấn giữ phải là số dương.',
			'settings.defaultPlaybackSpeed' => 'Tốc độ phát mặc định',
			'settings.rememberPlaybackSpeed' => 'Ghi nhớ tốc độ phát',
			'settings.rememberPlaybackSpeedDesc' => 'Khi bật, tốc độ bạn đặt trong trình phát sẽ được lưu làm mặc định và tự động áp dụng cho video mới.',
			'settings.repeat' => 'Lặp lại',
			'settings.renderVerticalVideoInVerticalScreen' => 'Hiển thị video dọc trên màn hình dọc',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Cấu hình này quyết định video có được hiển thị trên màn hình dọc khi phát toàn màn hình hay không.',
			'settings.rememberVolume' => 'Ghi nhớ âm lượng',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Cấu hình này quyết định âm lượng có được giữ lại khi phát video lần nữa hay không.',
			'settings.rememberBrightness' => 'Ghi nhớ độ sáng',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Cấu hình này quyết định độ sáng có được giữ lại khi phát video lần nữa hay không.',
			'settings.playControlArea' => 'Vùng điều khiển phát',
			'settings.leftAndRightControlAreaWidth' => 'Chiều rộng vùng điều khiển trái và phải',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Cấu hình này quyết định chiều rộng của các vùng điều khiển ở bên trái và bên phải trình phát.',
			'settings.proxyAddressCannotBeEmpty' => 'Địa chỉ proxy không được để trống.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Định dạng địa chỉ proxy không hợp lệ. Vui lòng dùng định dạng IP:cổng hoặc tên miền:cổng.',
			'settings.proxyNormalWork' => 'Proxy hoạt động bình thường.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Kiểm tra proxy thất bại, mã trạng thái: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Kiểm tra proxy thất bại, ngoại lệ: ${exception}',
			'settings.proxyConfig' => 'Cấu hình proxy',
			'settings.thisIsHttpProxyAddress' => 'Đây là địa chỉ proxy http',
			'settings.checkProxy' => 'Kiểm tra proxy',
			'settings.proxyAddress' => 'Địa chỉ proxy',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Vui lòng nhập URL của máy chủ proxy, ví dụ 127.0.0.1:8080',
			'settings.enableProxy' => 'Bật proxy',
			'settings.left' => 'Trái',
			'settings.middle' => 'Giữa',
			'settings.right' => 'Phải',
			'settings.playerSettings' => 'Cài đặt trình phát',
			'settings.networkSettings' => 'Cài đặt mạng',
			'settings.customizeYourPlaybackExperience' => 'Tùy chỉnh trải nghiệm phát',
			'settings.chooseYourFavoriteAppAppearance' => 'Chọn giao diện ứng dụng yêu thích',
			'settings.configureYourProxyServer' => 'Cấu hình máy chủ proxy',
			'settings.settings' => 'Cài đặt',
			'settings.themeSettings' => 'Cài đặt giao diện',
			'settings.followSystem' => 'Theo hệ thống',
			'settings.lightMode' => 'Chế độ sáng',
			'settings.darkMode' => 'Chế độ tối',
			'settings.presetTheme' => 'Giao diện đặt trước',
			'settings.basicTheme' => 'Giao diện cơ bản',
			'settings.needRestartToApply' => 'Cần khởi động lại ứng dụng để áp dụng cài đặt',
			'settings.themeNeedRestartDescription' => 'Cài đặt giao diện cần khởi động lại ứng dụng để áp dụng',
			'settings.about' => 'Giới thiệu',
			'settings.diagnosticsAndFeedback' => 'Chẩn đoán và phản hồi',
			'settings.currentVersion' => 'Phiên bản hiện tại',
			'settings.latestVersion' => 'Phiên bản mới nhất',
			'settings.checkForUpdates' => 'Kiểm tra cập nhật',
			'settings.update' => 'Cập nhật',
			'settings.newVersionAvailable' => 'Có phiên bản mới',
			'settings.projectHome' => 'Trang chủ dự án',
			'settings.release' => 'Phát hành',
			'settings.issueReport' => 'Báo cáo sự cố',
			'settings.openSourceLicense' => 'Giấy phép mã nguồn mở',
			'settings.checkForUpdatesFailed' => 'Kiểm tra cập nhật thất bại, vui lòng thử lại sau',
			'settings.autoCheckUpdate' => 'Tự động kiểm tra cập nhật',
			'settings.updateContent' => 'Nội dung cập nhật',
			'settings.releaseDate' => 'Ngày phát hành',
			'settings.ignoreThisVersion' => 'Bỏ qua phiên bản này',
			'settings.forceUpdateTip' => 'Đây là bản cập nhật bắt buộc. Vui lòng cập nhật lên phiên bản mới nhất càng sớm càng tốt',
			'settings.viewChangelog' => 'Xem nhật ký thay đổi',
			'settings.alreadyLatestVersion' => 'Đã là phiên bản mới nhất',
			'settings.appSettings' => 'Cài đặt ứng dụng',
			'settings.configureYourAppSettings' => 'Cấu hình cài đặt ứng dụng',
			'settings.history' => 'Lịch sử',
			'settings.autoRecordHistory' => 'Tự động ghi lịch sử',
			'settings.autoRecordHistoryDesc' => 'Tự động ghi lại video và hình ảnh bạn đã xem',
			'settings.autoDeleteHistory' => 'Tự động dọn lịch sử',
			'settings.autoDeleteHistoryDesc' => 'Tự động xóa lịch sử duyệt web cũ hơn số ngày lưu giữ khi khởi động (mặc định tắt)',
			'settings.autoDeleteHistoryDays' => 'Số ngày lưu giữ',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Giữ ${num} ngày gần nhất',
			'settings.autoDeleteHistoryDaysInvalid' => 'Vui lòng nhập số ngày hợp lệ (tối thiểu 1)',
			'settings.showUnprocessedMarkdownText' => 'Hiển thị văn bản Markdown chưa xử lý',
			'settings.showUnprocessedMarkdownTextDesc' => 'Hiển thị văn bản gốc của markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Chế độ riêng tư',
			'settings.activeBackgroundPrivacyModeDesc' => 'Chặn chụp màn hình và ghi màn hình, đồng thời ẩn màn hình khi chạy nền',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Ẩn màn hình khi ứng dụng chuyển sang chạy nền (nền tảng này không thể chặn chụp màn hình)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Chặn chụp màn hình và ghi màn hình',
			'settings.privacy' => 'Quyền riêng tư',
			'settings.appLock' => 'Khóa ứng dụng',
			'settings.appLockEnabled' => 'Bật khóa ứng dụng',
			'settings.appLockEnabledDesc' => 'Yêu cầu mã PIN hoặc sinh trắc học để mở ứng dụng; bản xem trước khi chạy nền sẽ tự động bị ẩn',
			'settings.appLockEnabledSummary' => 'Bật · Bảo vệ bằng mã PIN',
			'settings.appLockDisabledSummary' => 'Tắt',
			'settings.appLockTimeout' => 'Khóa sau khi rời ứng dụng',
			'settings.appLockTimeoutDesc' => 'Thời gian cho phép chạy nền trước khi yêu cầu xác thực',
			'settings.appLockAfterScreenOff' => 'Khóa sau khi tắt màn hình',
			'settings.appLockAfterScreenOffDesc' => 'Yêu cầu xác thực sau khi màn hình thiết bị bị khóa',
			'settings.appLockTimeoutDisabled' => 'Đã tắt',
			'settings.appLockImmediately' => 'Ngay lập tức',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} giây',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} phút',
			'settings.appLockUseBiometrics' => 'Dùng sinh trắc học',
			'settings.appLockUseBiometricsDesc' => 'Mở khóa bằng vân tay hoặc nhận diện khuôn mặt',
			'settings.appLockBiometricsUnavailable' => 'Thiết bị này chưa đăng ký dữ liệu sinh trắc học nào',
			'settings.appLockSetPin' => 'Đặt mã PIN',
			'settings.appLockEnterPin' => 'Nhập mã PIN',
			'settings.appLockConfirmPin' => 'Xác nhận mã PIN',
			'settings.appLockCurrentPin' => 'Nhập mã PIN hiện tại',
			'settings.appLockNewPin' => 'Nhập mã PIN mới',
			'settings.appLockPinRequirements' => 'Mã PIN phải gồm 4–8 chữ số',
			'settings.appLockPinsDoNotMatch' => 'Mã PIN không khớp',
			'settings.appLockInvalidPin' => 'Mã PIN không đúng',
			'settings.appLockSetupFailed' => 'Không thể lưu mã PIN một cách an toàn',
			'settings.appLockDisable' => 'Nhập mã PIN để tắt khóa ứng dụng',
			'settings.appLockChangePin' => 'Đổi mã PIN',
			'settings.appLockNow' => 'Khóa ngay',
			'settings.appLockUnlock' => 'Mở khóa',
			'settings.appLockLockedTitle' => 'Đã khóa',
			'settings.appLockLockedDesc' => 'Xác thực để tiếp tục',
			'settings.appLockAuthenticateReason' => 'Xác thực để mở khóa',
			'settings.appLockEnableBiometricsReason' => 'Xác thực để bật mở khóa bằng sinh trắc học',
			'settings.appLockBiometricFailed' => 'Xác thực sinh trắc học chưa hoàn tất',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Quá nhiều lần thử. Thử lại sau ${seconds} giây',
			'settings.appLockCredentialUnavailableTitle' => 'Không đọc được thông tin xác thực khóa ứng dụng',
			'settings.appLockCredentialUnavailableDesc' => 'Kho lưu trữ bảo mật của hệ thống tạm thời không khả dụng, hoặc thông tin xác thực đã bị hỏng. Ứng dụng vẫn bị khóa. Hãy thử lại trước; nếu vẫn thất bại, bạn có thể đặt lại khóa ứng dụng, thao tác này sẽ tắt khóa và xóa mã PIN đã lưu.',
			'settings.appLockRetry' => 'Thử lại',
			'settings.appLockReset' => 'Đặt lại khóa ứng dụng',
			'settings.appLockResetAction' => 'Đặt lại',
			'settings.appLockResetConfirmTitle' => 'Đặt lại khóa ứng dụng?',
			'settings.appLockResetConfirmDesc' => 'Thao tác này sẽ tắt khóa ứng dụng và xóa mã PIN cùng cài đặt sinh trắc học đã lưu. Sau đó bạn có thể thiết lập lại.',
			'settings.appLockRetrySucceeded' => 'Đọc thông tin xác thực thành công. Hãy nhập mã PIN.',
			'settings.appLockRetryFailed' => 'Vẫn không đọc được thông tin xác thực',
			'settings.forum' => 'Diễn đàn',
			'settings.news' => 'Tin tức',
			'settings.community' => 'Cộng đồng',
			'settings.disableForumReplyQuote' => 'Tắt trích dẫn trả lời diễn đàn',
			'settings.disableForumReplyQuoteDesc' => 'Tắt việc mang theo thông tin tầng đã trả lời khi trả lời trên diễn đàn',
			'settings.theaterMode' => 'Chế độ rạp hát',
			'settings.theaterModeDesc' => 'Sau khi bật, nền trình phát sẽ được đặt thành phiên bản làm mờ của ảnh bìa video',
			'settings.appLinks' => 'Liên kết ứng dụng',
			'settings.defaultBrowser' => 'Trình duyệt mặc định',
			'settings.defaultBrowserDesc' => 'Vui lòng mở mục cấu hình liên kết mặc định trong cài đặt hệ thống và thêm liên kết trang web iwara.tv',
			'settings.themeMode' => 'Chế độ giao diện',
			'settings.themeModeDesc' => 'Cấu hình này quyết định chế độ giao diện của ứng dụng',
			'settings.glassEffect' => 'Vật liệu giao diện',
			'settings.glassEffectDesc' => 'Chọn vật liệu dùng xuyên suốt ứng dụng — thanh tiêu đề, menu, nút hộp thoại và thanh điều hướng dưới',
			'settings.liquidGlassEffect' => 'Kính lỏng',
			'settings.liquidGlassEffectDesc' => 'Làm mờ và khúc xạ thật. Trông đẹp nhất, nhưng có thể rớt khung hình và tốn thêm chút pin trên thiết bị yếu',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Bề mặt Material 3 tiêu chuẩn — đục, không mờ, không đổ bóng. Hiệu năng và pin tốt nhất',
			'settings.glassEffectIntroTitle' => 'Chọn vật liệu giao diện',
			'settings.glassEffectIntroContent' => 'Thanh tiêu đề, thanh tab và menu dùng kính lỏng — làm mờ và khúc xạ thật. Nếu cảm thấy chậm trên thiết bị của bạn, hoặc muốn đơn giản hơn, hãy chuyển sang Material ngay (bề mặt đục, không mờ, không đổ bóng).',
			'settings.glassEffectIntroHint' => 'Bạn có thể thay đổi bất cứ lúc nào trong Cài đặt → Giao diện → Vật liệu giao diện.',
			'settings.glassEffectIntroDone' => 'Giữ nguyên',
			'settings.dynamicColor' => 'Màu động',
			'settings.dynamicColorDesc' => 'Cấu hình này quyết định ứng dụng có dùng màu động hay không',
			'settings.useDynamicColor' => 'Dùng màu động',
			'settings.useDynamicColorDesc' => 'Cấu hình này quyết định ứng dụng có dùng màu động hay không',
			'settings.presetColors' => 'Màu đặt trước',
			'settings.customColors' => 'Màu tùy chỉnh',
			'settings.customColorsDisabledByDynamicColor' => 'Màu động đang bật nên không thể dùng màu đặt trước hoặc tùy chỉnh. Hãy tắt màu động trước.',
			'settings.pickColor' => 'Chọn màu',
			'settings.cancel' => 'Hủy',
			'settings.confirm' => 'Xác nhận',
			'settings.noCustomColors' => 'Không có màu tùy chỉnh',
			'settings.recordAndRestorePlaybackProgress' => 'Ghi và khôi phục tiến trình phát',
			'settings.autoPlayVideoOnFirstEnter' => 'Tự động phát video khi mở lần đầu',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Cài đặt này quyết định video có tự động phát khi lần đầu mở trang video hay không.',
			'settings.autoEnterFullscreen' => 'Tự động vào toàn màn hình',
			'settings.autoEnterFullscreenDesc' => 'Khi trình phát nên tự vào toàn màn hình. Video riêng tư, đã xóa và video bên ngoài luôn được giữ nguyên, tương tự với chế độ hình trong hình.',
			'settings.autoEnterFullscreenOff' => 'Tắt',
			'settings.autoEnterFullscreenOffDesc' => 'Không bao giờ tự vào toàn màn hình',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'Khi bắt đầu phát',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Vào toàn màn hình ngay khi quá trình phát thực sự bắt đầu',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'Khi mở video',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Vào toàn màn hình ngay khi trang video mở ra, không cần chờ phát video',
			'settings.autoEnterFullscreenKind' => 'Kiểu toàn màn hình',
			'settings.autoEnterFullscreenKindDesc' => 'Kiểu toàn màn hình sẽ tự động vào. Chỉ trên máy tính để bàn.',
			'settings.autoEnterFullscreenKindSystem' => 'Toàn màn hình hệ thống',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Để trình quản lý cửa sổ đưa cửa sổ vào chế độ toàn màn hình',
			'settings.autoEnterFullscreenKindApp' => 'Toàn màn hình ứng dụng',
			'settings.autoEnterFullscreenKindAppDesc' => 'Giữ nguyên cửa sổ và biến toàn bộ ứng dụng thành trình phát',
			'settings.signature' => 'Chữ ký',
			'settings.enableSignature' => 'Bật chữ ký',
			'settings.enableSignatureDesc' => 'Cấu hình này quyết định ứng dụng có thêm chữ ký khi trả lời hay không',
			'settings.enterSignature' => 'Nhập chữ ký',
			'settings.editSignature' => 'Chỉnh sửa chữ ký',
			'settings.signatureContent' => 'Nội dung chữ ký',
			'settings.signaturePreview' => 'Xem trước',
			'settings.signatureSampleBody' => 'Nội dung của bạn ở đây',
			'settings.signatureRegenerate' => 'Tạo lại',
			'settings.signatureNotSet' => 'Chưa đặt',
			'settings.signatureRuleHint' => 'Chữ ký được thêm sau nội dung, ngăn cách bằng một đường kẻ ngang. Ứng dụng tự thêm đường kẻ — bạn chỉ cần viết dòng bên dưới.',
			'settings.signatureInsertVariable' => 'Chèn biến',
			'settings.varDate' => 'Ngày',
			'settings.varTime' => 'Giờ',
			'settings.varDatetime' => 'Ngày giờ',
			'settings.varWeekday' => 'Thứ',
			'settings.varApp' => 'Tên ứng dụng',
			'settings.varVersion' => 'Phiên bản',
			'settings.varPlatform' => 'Nền tảng',
			'settings.varTitle' => 'Thứ bạn đang xem',
			'settings.varAuthor' => 'Tác giả của nó',
			'settings.varPick' => 'Câu ngẫu nhiên',
			'settings.signatureSources' => 'Nguồn dữ liệu',
			'settings.signatureAutoTranslate' => 'Dịch sang ngôn ngữ của tôi',
			'settings.signatureAutoTranslateDesc' => 'Các nguồn như Hitokoto hiện chỉ có tiếng Trung. Câu lấy về sẽ được dịch ngay trước khi gửi đi.',
			'settings.signatureWizardTitle' => 'Thêm một nguồn dữ liệu',
			'settings.signatureWizardUrlTitle' => 'Địa chỉ điểm cuối',
			'settings.signatureWizardUrlHint' => 'Nhập một địa chỉ trả về một dòng chữ. Nút bên dưới sẽ gọi thật một lần để bạn thấy nó trả về gì.',
			'settings.signatureWizardFetch' => 'Gọi thử',
			'settings.signatureWizardSkipTest' => 'Bỏ qua, chỉ đổi tên',
			'settings.signatureWizardPickTitle' => 'Chọn phần bạn muốn',
			'settings.signatureWizardPickHint' => 'Đây là thứ điểm cuối đó trả về. Chạm vào dòng bạn muốn chữ ký hiển thị.',
			'settings.signatureWizardPickPlainHint' => 'Điểm cuối này trả về văn bản thuần, nên toàn bộ sẽ được hiển thị.',
			'settings.signatureWizardWholeBody' => 'Toàn bộ phản hồi',
			'settings.signatureWizardNameTitle' => 'Đặt cho nó một cái tên',
			'settings.signatureWizardNameHint' => 'Tên chỉ để bạn dễ nhận ra. Thứ chữ ký dùng để trỏ tới là tên tham chiếu bên dưới.',
			'settings.signatureWizardNext' => 'Tiếp',
			'settings.signatureWizardDone' => 'Xong',
			'settings.signatureWizardStripHtml' => 'Bỏ thẻ HTML',
			'settings.signatureWizardAdvanced' => 'Nâng cao: trích bằng mẫu',
			'settings.signatureWizardExtractHint' => 'Biểu thức chính quy; lấy nhóm bắt đầu tiên',
			'settings.signatureWizardExtractMissed' => 'Mẫu này không khớp, nên giữ nguyên văn bản',
			'settings.signatureWizardChooseTitle' => 'Chọn một nguồn',
			'settings.signatureWizardChooseHint' => 'Chạm vào một nguồn có sẵn là xong. Hoặc trỏ tới endpoint của riêng bạn.',
			'settings.signatureWizardCustomSource' => 'Dùng endpoint của tôi',
			'settings.signatureWizardWithOrigin' => 'Hiện cả xuất xứ',
			'settings.signatureWizardRandomItem' => 'Mỗi lần lấy một câu khác',
			'settings.signatureWizardSuffixTitle' => 'Nối thêm một trường nữa',
			'settings.signatureWizardSuffixNone' => 'Không nối',
			'settings.signatureOptFlavor' => 'Nội dung',
			'settings.signatureOptFlavorAny' => 'Không giới hạn',
			'settings.signatureOptFlavorOtaku' => 'Anime, manga và game',
			'settings.signatureOptFlavorLiterary' => 'Văn học và thơ',
			'settings.signatureOptFlavorMeme' => 'Văn hoá mạng',
			'settings.signatureOptLength' => 'Độ dài',
			'settings.signatureOptLengthAny' => 'Không giới hạn',
			'settings.signatureOptLengthShort' => 'Chỉ câu ngắn',
			'settings.signatureRestoreDefault' => 'Khôi phục mặc định',
			'settings.signatureSourceHitokoto' => 'Hitokoto (câu ngẫu nhiên)',
			'settings.signatureAiSourceName' => 'Câu chữ tạo bởi AI',
			'settings.signatureEditTextHint' => 'Đây là chữ ký đã có sẵn trong bình luận này — câu trích và ngày giờ giờ chỉ là chữ thường, sửa tuỳ ý. Xoá trống là bỏ chữ ký.',
			'settings.signatureResolving' => ({required Object name}) => 'Đang tạo ${name}…',
			'settings.signaturePendingValue' => '(tạo khi gửi)',
			'settings.signatureAiHint' => 'Một câu do AI viết ngay lúc đó, mỗi bình luận một câu mới. Dùng nhà cung cấp AI bạn đã thiết lập.',
			'settings.signatureAiUnavailable' => 'Chưa thiết lập nhà cung cấp AI nên nguồn này không hiện trong bảng biến.',
			'settings.signaturePromptTitle' => 'Prompt',
			'settings.signaturePromptHint' => 'Đây là thứ được gửi cho mô hình. Viết lại tuỳ ý: giọng điệu, độ dài, chủ đề. Các quy tắc có sẵn trong đó nên giữ lại.',
			'settings.signaturePromptReset' => 'Khôi phục mặc định',
			'settings.signaturePromptTry' => 'Thử',
			'settings.signaturePromptSample' => 'Kết quả',
			'settings.signaturePromptLanguageHint' => 'sẽ được thay bằng ngôn ngữ giao diện. Bỏ nó đi thì câu sẽ theo ngôn ngữ của prompt.',
			'settings.signaturePromptEdited' => 'đã sửa',
			'settings.signatureVariablesGroup' => 'Biến có sẵn',
			'settings.signatureNeedsNetwork' => 'Cần mạng',
			'settings.signatureBuiltinSource' => 'Có sẵn',
			'settings.signatureSourceIdReserved' => 'Tên này đã thuộc về một biến có sẵn',
			'settings.signatureSourcesTitle' => 'Nguồn dữ liệu tự thêm',
			'settings.signatureSourcesHint' => 'Trỏ tới một địa chỉ trả về một dòng chữ là bạn có thể đưa nó vào chữ ký.',
			'settings.signatureSourcesEmpty' => 'Chưa có nguồn dữ liệu nào',
			'settings.signatureAddSource' => 'Thêm',
			'settings.signatureEditSource' => 'Sửa nguồn dữ liệu',
			'settings.signatureSourceName' => 'Tên',
			'settings.signatureSourceId' => 'Tên tham chiếu',
			'settings.signatureSourceIdHint' => 'Tên mà chữ ký dùng để gọi nguồn này',
			'settings.signatureSourceUrl' => 'Địa chỉ điểm cuối',
			'settings.signatureSourcePath' => 'Đường dẫn giá trị',
			'settings.signatureSourcePathHint' => 'Để trống nếu toàn bộ phản hồi chính là dòng chữ đó. Dùng data.text để lấy trường đó từ phản hồi JSON.',
			'settings.signatureSourceTest' => 'Kiểm tra',
			'settings.signatureSourceTestOk' => 'Lấy được rồi',
			'settings.signatureSourceTestFailed' => 'Không có gì trả về',
			'settings.signatureSourceIdInvalid' => 'Tên tham chiếu chỉ dùng chữ thường, chữ số và gạch dưới',
			'settings.signatureSourceIdDuplicate' => 'Tên tham chiếu này đã có người dùng',
			'settings.signatureSourceUrlRequired' => 'Cần nhập địa chỉ điểm cuối',
			'settings.exportConfig' => 'Xuất cấu hình ứng dụng',
			'settings.exportConfigDesc' => 'Xuất cài đặt và lịch sử (lịch sử duyệt web, tiến trình phát, yêu thích, v.v.) ra tệp để sao lưu hoặc chuyển sang thiết bị khác. Không bao gồm tác vụ tải xuống.',
			'settings.importConfig' => 'Nhập cấu hình ứng dụng',
			'settings.importConfigDesc' => 'Nhập cấu hình ứng dụng từ tệp',
			'settings.exportConfigSuccess' => 'Đã xuất cấu hình thành công!',
			'settings.exportConfigFailed' => 'Xuất cấu hình thất bại',
			'settings.importConfigSuccess' => 'Đã nhập cấu hình thành công!',
			'settings.importConfigFailed' => 'Nhập cấu hình thất bại',
			'settings.exportIncludeSensitive' => 'Bao gồm thông tin nhạy cảm',
			'settings.exportIncludeSensitiveDesc' => 'Bao gồm khóa API, token phiên và địa chỉ proxy. Chỉ bật khi sao lưu vào thiết bị của chính bạn.',
			'settings.importConfigOverwriteWarning' => 'Nhập sẽ ghi đè cài đặt và lịch sử hiện tại (lịch sử duyệt web, tiến trình phát, yêu thích, v.v.). Tiếp tục?',
			'settings.importConfigRestartTitle' => 'Nhập thành công',
			'settings.importConfigRestartContent' => 'Cấu hình của bạn đã được nhập. Vui lòng đóng hoàn toàn và mở lại ứng dụng để mọi thay đổi có hiệu lực.',
			'settings.historyUpdateLogs' => 'Nhật ký cập nhật lịch sử',
			'settings.noUpdateLogs' => 'Không có nhật ký cập nhật',
			'settings.versionLabel' => 'Phiên bản: {version}',
			'settings.releaseDateLabel' => 'Ngày phát hành: {date}',
			'settings.noChanges' => 'Không có nội dung cập nhật',
			'settings.interaction' => 'Tương tác',
			'settings.enableVibration' => 'Bật rung',
			'settings.enableVibrationDesc' => 'Bật phản hồi rung khi tương tác với ứng dụng',
			'settings.defaultKeepVideoToolbarVisible' => 'Giữ thanh công cụ video luôn hiển thị',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Cài đặt này quyết định thanh công cụ video có luôn hiển thị khi lần đầu mở trang video hay không.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Thiết bị di động bật chế độ rạp hát có thể gây vấn đề về hiệu năng. Bạn có thể chọn bật.',
			'settings.fullscreenOrientation' => 'Hướng màn hình dọc sau khi vào toàn màn hình',
			'settings.fullscreenOrientationDesc' => 'Cài đặt này quyết định hướng màn hình mặc định khi vào toàn màn hình (chỉ trên di động)',
			'settings.fullscreenOrientationLeftLandscape' => 'Ngang trái',
			'settings.fullscreenOrientationRightLandscape' => 'Ngang phải',
			'settings.screenFit' => 'Kích thước màn hình',
			'settings.screenFitDesc' => 'Chọn cách video lấp đầy vùng trình phát.',
			'settings.rememberScreenFit' => 'Ghi nhớ kích thước màn hình',
			'settings.rememberScreenFitDesc' => 'Áp dụng kích thước đã chọn cho các video mở sau này.',
			'settings.screenFitFit' => 'Vừa khung',
			'settings.screenFitFitDesc' => 'Hiển thị toàn bộ khung hình mà giữ nguyên tỉ lệ',
			'settings.screenFitStretch' => 'Kéo giãn',
			'settings.screenFitStretchDesc' => 'Lấp đầy vùng trình phát; hình ảnh có thể bị méo',
			'settings.screenFitCover' => 'Lấp đầy',
			'settings.screenFitCoverDesc' => 'Lấp đầy vùng trình phát mà giữ nguyên tỉ lệ khung hình; phần tràn sẽ bị cắt',
			'settings.screenFitRatioDesc' => 'Buộc dùng tỉ lệ khung hình này; hình ảnh có thể bị méo',
			'settings.jumpLink' => 'Liên kết nhảy',
			'settings.language' => 'Ngôn ngữ',
			'settings.languageNativeName' => 'Tiếng Việt',
			'settings.followSystemLanguage' => 'Theo hệ thống',
			'settings.languageChangedMessage' => 'Đã đổi ngôn ngữ. Một số tính năng cần khởi động lại ứng dụng để có hiệu lực.',
			'settings.languageChanged' => 'Đã thay đổi cài đặt ngôn ngữ, vui lòng khởi động lại ứng dụng để có hiệu lực.',
			'settings.keybinding.title' => 'Phím tắt bàn phím',
			'settings.keybinding.entryLabel' => 'Phím tắt bàn phím',
			'settings.keybinding.entryDesc' => 'Tùy chỉnh phím tắt bàn phím của ứng dụng (chủ yếu cho máy tính)',
			'settings.keybinding.desktopHint' => 'Phím tắt chủ yếu áp dụng cho bàn phím máy tính; trên di động thường dùng cử chỉ.',
			'settings.keybinding.resetAll' => 'Đặt lại tất cả về mặc định',
			'settings.keybinding.resetAllConfirm' => 'Đặt lại tất cả phím tắt ứng dụng về mặc định?',
			'settings.keybinding.resetToDefault' => 'Đặt lại mặc định',
			'settings.keybinding.resetScope' => 'Đặt lại mục này',
			'settings.keybinding.notSet' => 'Chưa đặt',
			'settings.keybinding.addShortcut' => 'Thêm phím tắt',
			'settings.keybinding.removeShortcut' => 'Xóa phím tắt này',
			'settings.keybinding.pressNewShortcut' => 'Nhấn phím tắt mới…',
			'settings.keybinding.recordingCancelHint' => 'Nhấn Esc để hủy',
			'settings.keybinding.mouseHint' => 'Bạn cũng có thể gán nút bên của chuột (lùi / tiến) hoặc nút giữa',
			'settings.keybinding.mouseNotSupportedInScope' => 'Khu vực này không xử lý nút chuột; hãy dùng bàn phím',
			'settings.keybinding.capabilityKeyboardOnly' => 'Khu vực này chỉ nhận phím bàn phím',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Khu vực này nhận phím bàn phím, cùng nút giữa và nút bên của chuột',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Khu vực này nhận phím bàn phím, cùng nút giữa và nút tiến của chuột (nút lùi do hệ thống chiếm)',
			'settings.keybinding.rejectMultipleButtons' => 'Mỗi lần chỉ nhấn một nút chuột',
			'settings.keybinding.rejectPlatformBack' => 'Hệ thống đã dùng phím này cho Quay lại; gán nó sẽ khiến quay lại hai lần',
			'settings.keybinding.detectedLabel' => 'Đã phát hiện',
			'settings.keybinding.reservedKey' => 'Phím này do hệ thống giữ riêng, không thể gán',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Phím này được gán cho "${action}"; nó vẫn được giữ riêng ở đây để bạn có thể rời màn hình này',
			'settings.keybinding.conflictTitle' => 'Xung đột phím tắt',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Tổ hợp này đã được gán cho "${action}". Tiếp tục sẽ xóa liên kết hiện có.',
			'settings.keybinding.conflictContinue' => 'Vẫn gán',
			'settings.keybinding.shadowWarningTitle' => 'Trùng phím tắt toàn cục',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Tổ hợp này được gán cho "${action}" trên toàn cục. Gán nó ở đây sẽ chỉ ghi đè hành động đó bên trong mục này.',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'Tổ hợp này đã được gán cho "${action}" trong ${scope}. Trong mục đó, phím tắt toàn cục này sẽ bị ghi đè.',
			'settings.keybinding.searchHint' => 'Tìm kiếm phím tắt…',
			'settings.keybinding.scopeGlobal' => 'Toàn cục',
			'settings.keybinding.scopeGallery' => 'Thư viện',
			'settings.keybinding.scopeVideo' => 'Video',
			'settings.keybinding.categoryNavigation' => 'Điều hướng',
			'settings.keybinding.categoryZoom' => 'Thu phóng',
			'settings.keybinding.categoryPlayback' => 'Phát',
			'settings.keybinding.categorySeek' => 'Tua',
			'settings.keybinding.categoryVolume' => 'Âm lượng',
			'settings.keybinding.categoryDisplay' => 'Hiển thị',
			'settings.keybinding.actionGlobalBack' => 'Quay lại',
			'settings.keybinding.actionGalleryNext' => 'Ảnh tiếp theo',
			'settings.keybinding.actionGalleryPrevious' => 'Ảnh trước',
			'settings.keybinding.actionGalleryZoomIn' => 'Phóng to',
			'settings.keybinding.actionGalleryZoomOut' => 'Thu nhỏ',
			'settings.keybinding.actionGalleryResetZoom' => 'Đặt lại thu phóng',
			'settings.keybinding.actionGalleryPlayPause' => 'Phát / Tạm dừng',
			'settings.keybinding.actionGallerySeekBackward' => 'Tua lại',
			'settings.keybinding.actionGallerySeekForward' => 'Tua tới',
			'settings.keybinding.actionGalleryToggleMute' => 'Bật/tắt tiếng',
			'settings.keybinding.actionPlayPause' => 'Phát / Tạm dừng',
			'settings.keybinding.actionSpeedUp' => 'Tăng tốc độ',
			'settings.keybinding.actionSpeedDown' => 'Giảm tốc độ',
			'settings.keybinding.actionSeekForward' => 'Tua tới',
			'settings.keybinding.actionSeekBackward' => 'Tua lại',
			'settings.keybinding.actionVolumeUp' => 'Tăng âm lượng',
			'settings.keybinding.actionVolumeDown' => 'Giảm âm lượng',
			'settings.keybinding.actionToggleMute' => 'Bật/tắt tiếng',
			'settings.keybinding.actionToggleFullscreen' => 'Bật/tắt toàn màn hình',
			'settings.keybinding.seekLongPressHint' => 'Giữ phím tua tới / tua lại để kích hoạt chế độ tốc độ khi nhấn giữ',
			'settings.keybinding.zoomSectionTitle' => 'Thu phóng hình (cố định)',
			'settings.keybinding.zoomFixedNote' => 'Các phím tắt bên dưới là cố định, không thể thay đổi',
			'settings.keybinding.zoomScaleLabel' => 'Thu phóng hình',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + Con lăn',
			'settings.keybinding.zoomRotateLabel' => 'Xoay hình',
			'settings.keybinding.zoomRotateHint' => 'Shift + Con lăn',
			'settings.keybinding.zoomPinchGesture' => 'Chụm',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Xoay bằng hai ngón',
			'settings.gestureControl' => 'Điều khiển bằng cử chỉ',
			'settings.leftDoubleTapRewind' => 'Nhấn đúp bên trái để tua lại',
			'settings.rightDoubleTapFastForward' => 'Nhấn đúp bên phải để tua nhanh',
			'settings.doubleTapPause' => 'Nhấn đúp để tạm dừng',
			'settings.rightVerticalSwipeVolume' => 'Vuốt dọc bên phải để chỉnh âm lượng (có hiệu lực khi vào trang mới)',
			'settings.leftVerticalSwipeBrightness' => 'Vuốt dọc bên trái để chỉnh độ sáng (có hiệu lực khi vào trang mới)',
			'settings.longPressFastForward' => 'Nhấn giữ để tua nhanh',
			'settings.enableMouseHoverShowToolbar' => 'Hiện thanh công cụ khi di chuột',
			'settings.enableMouseHoverShowToolbarInfo' => 'Khi bật, thanh công cụ video sẽ hiện khi con trỏ chuột ở trên trình phát. Thanh này sẽ tự động ẩn sau 3 giây không thao tác.',
			'settings.enableHorizontalDragSeek' => 'Vuốt ngang để tua',
			'settings.enableVideoGestureZoom' => 'Chụm để thu phóng khung hình video',
			'settings.enableVideoGestureZoomInfo' => 'Dùng hai ngón tay chụm (hoặc Ctrl + con lăn chuột trên máy tính) để thu phóng hình video, sau đó kéo để di chuyển.',
			'settings.showCenterPlayPauseButton' => 'Nút phát/tạm dừng ở giữa',
			'settings.showCenterPlayPauseButtonDesc' => 'Hiển thị nút phát/tạm dừng lớn ở giữa trình phát.',
			'settings.audioVideoConfig' => 'Cấu hình âm thanh và video',
			'settings.expandBuffer' => 'Mở rộng bộ đệm',
			'settings.expandBufferInfo' => 'Khi bật, kích thước bộ đệm tăng lên, thời gian tải lâu hơn nhưng phát mượt hơn',
			'settings.videoSyncMode' => 'Chế độ đồng bộ video',
			'settings.videoSyncModeSubtitle' => 'Chiến lược đồng bộ âm thanh - video',
			'settings.hardwareDecodingMode' => 'Chế độ giải mã phần cứng',
			'settings.hardwareDecodingModeSubtitle' => 'Cài đặt giải mã phần cứng',
			'settings.enableHardwareAcceleration' => 'Bật tăng tốc phần cứng',
			'settings.enableHardwareAccelerationInfo' => 'Bật tăng tốc phần cứng có thể cải thiện hiệu năng giải mã, nhưng một số thiết bị có thể không tương thích',
			'settings.useOpenSLESAudioOutput' => 'Dùng đầu ra âm thanh OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'Dùng đầu ra âm thanh độ trễ thấp, có thể cải thiện hiệu năng âm thanh',
			'settings.videoSyncAudio' => 'Đồng bộ âm thanh',
			'settings.videoSyncDisplayResample' => 'Lấy mẫu lại',
			'settings.videoSyncDisplayResampleVdrop' => 'Lấy mẫu lại (bỏ khung hình)',
			'settings.videoSyncDisplayResampleDesync' => 'Lấy mẫu lại (mất đồng bộ)',
			'settings.videoSyncDisplayTempo' => 'Nhịp độ',
			'settings.videoSyncDisplayVdrop' => 'Bỏ khung hình video',
			'settings.videoSyncDisplayAdrop' => 'Bỏ khung hình âm thanh',
			'settings.videoSyncDisplayDesync' => 'Hiển thị mất đồng bộ',
			'settings.videoSyncDesync' => 'Mất đồng bộ',
			'settings.forumSettings.name' => 'Diễn đàn',
			'settings.forumSettings.configureYourForumSettings' => 'Cấu hình cài đặt diễn đàn',
			'settings.gallerySettings.gallerySettingsTitle' => 'Cài đặt thư viện',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Cấu hình tùy chọn trình xem thư viện',
			'settings.gallerySettings.defaultViewerQuality' => 'Chất lượng xem mặc định',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Chọn chất lượng hình ảnh hiển thị mặc định khi mở trình xem thư viện.',
			'settings.blockSettings.title' => 'Chặn nội dung',
			'settings.blockSettings.subtitle' => 'Tự động ẩn video và thư viện có tiêu đề khớp với từ khóa hoặc mẫu, hoặc đến từ người dùng bị chặn. Mọi quá trình khớp đều diễn ra trên thiết bị của bạn — không có gì được tải lên.',
			'settings.blockSettings.blocked' => 'Đã chặn',
			'settings.blockSettings.reveal' => 'Hiện',
			'settings.blockSettings.reblock' => 'Chặn lại',
			'settings.blockSettings.why' => 'Vì sao bị chặn?',
			'settings.blockSettings.manageRules' => 'Quản lý quy tắc',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'Tiêu đề chứa "${value}"',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'Tiêu đề khớp "${value}"',
			'settings.blockSettings.reasonUser' => 'Từ người dùng bị chặn',
			'settings.blockSettings.addRule' => 'Thêm quy tắc',
			'settings.blockSettings.editRule' => 'Chỉnh sửa quy tắc',
			'settings.blockSettings.deleteRule' => 'Xóa quy tắc',
			'settings.blockSettings.ruleType' => 'Loại quy tắc',
			'settings.blockSettings.keyword' => 'Từ khóa',
			'settings.blockSettings.regex' => 'Regex',
			'settings.blockSettings.userId' => 'Người dùng',
			'settings.blockSettings.value' => 'Văn bản cần khớp',
			'settings.blockSettings.caseSensitive' => 'Phân biệt chữ hoa chữ thường',
			'settings.blockSettings.regexHint' => 'ví dụ: trailer|hậu trường',
			'settings.blockSettings.valueRequired' => 'Vui lòng nhập văn bản cần khớp',
			'settings.blockSettings.invalidRegex' => 'Đó không phải là biểu thức chính quy hợp lệ',
			'settings.blockSettings.noRules' => 'Chưa có quy tắc nào. Nhấn + để thêm.',
			'settings.blockSettings.blockUser' => 'Chặn',
			'settings.blockSettings.unblockUser' => 'Bỏ chặn',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => 'Chặn "${name}"? Video và thư viện của họ sẽ bị ẩn khỏi danh sách và tìm kiếm.',
			'settings.blockSettings.userBlocked' => 'Đã chặn người dùng',
			'settings.blockSettings.userUnblocked' => 'Đã bỏ chặn người dùng',
			'settings.blockSettings.exportRules' => 'Xuất',
			'settings.blockSettings.importRules' => 'Nhập',
			'settings.blockSettings.importExport' => 'Nhập / Xuất',
			'settings.blockSettings.exportSuccess' => 'Đã xuất quy tắc',
			'settings.blockSettings.exportFailed' => 'Không thể xuất quy tắc',
			'settings.blockSettings.importSuccess' => ({required Object count}) => 'Đã nhập ${count} quy tắc',
			'settings.blockSettings.importFailed' => 'Không thể nhập quy tắc',
			'settings.blockSettings.regexHelp' => 'Trợ giúp về mẫu',
			'settings.blockSettings.regexHelpTitle' => 'Tham khảo Regex',
			'settings.blockSettings.regexHelpIntro' => 'Biểu thức chính quy khớp tiêu đề linh hoạt hơn từ khóa thông thường. Một số ví dụ phổ biến:',
			'settings.blockSettings.regexHelpTapHint' => 'Nhấn vào một ví dụ để điền vào.',
			'settings.blockSettings.regexEx1Pattern' => 'trailer|hậu trường|tặng kèm',
			'settings.blockSettings.regexEx1Desc' => 'Khớp với bất kỳ từ nào sau đây ("|" nghĩa là "hoặc")',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Tiêu đề bắt đầu bằng [ngoặc vuông]',
			'settings.blockSettings.regexEx3Pattern' => 'Tuyển tập\$',
			'settings.blockSettings.regexEx3Desc' => 'Tiêu đề kết thúc bằng "Tuyển tập"',
			'settings.blockSettings.regexEx4Pattern' => 'Tập [0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ là một hoặc nhiều chữ số — khớp với "Tập 12"',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9] là một chữ số và {4} nghĩa là bốn chữ số liên tiếp (ví dụ: một năm)',
			'settings.blockSettings.regexEx1Sample' => 'Video trailer mới ra mắt',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Phim đầy đủ',
			'settings.blockSettings.regexEx3Sample' => 'Ảnh mùa xuân Tuyển tập',
			'settings.blockSettings.regexEx4Sample' => 'Phim của tôi Tập 12 tóm tắt',
			'settings.blockSettings.regexEx5Sample' => 'Tuyển chọn hay nhất 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'Tiêu đề ví dụ',
			'settings.blockSettings.regexHelpMatchedTag' => 'Đã chặn',
			'settings.blockSettings.regexHelpNoMatch' => 'Không khớp',
			'settings.blockSettings.regexEx6Pattern' => '[Mm]ùa',
			'settings.blockSettings.regexEx6Desc' => '[Mm] khớp với chữ M viết hoa hoặc viết thường — ở đây bắt được "Mùa"',
			'settings.blockSettings.regexEx6Sample' => 'Mùa cuối trailer',
			'settings.blockSettings.regexEx7Pattern' => 'xem (phim|bộ)',
			'settings.blockSettings.regexEx7Desc' => 'Dấu ngoặc đơn () nhóm các lựa chọn — khớp với "xem phim" hoặc "xem bộ"',
			'settings.blockSettings.regexEx7Sample' => 'Hãy xem bộ ngay',
			'settings.blockSettings.regexEx8Pattern' => 'xem( ngay)?',
			'settings.blockSettings.regexEx8Desc' => 'Phần trong ngoặc () là tùy chọn — khớp với "xem" và "xem ngay"',
			'settings.blockSettings.regexEx8Sample' => 'Hãy xem ngay bây giờ',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '"+" nghĩa là một hoặc nhiều — khớp với !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'Quá đỉnh!!! Nhất định phải xem',
			'settings.blockSettings.regexEx10Pattern' => 'trailer.*mới',
			'settings.blockSettings.regexEx10Desc' => '".*" khớp với mọi thứ ở giữa — "trailer … mới"',
			'settings.blockSettings.regexEx10Sample' => 'Xem trailer hấp dẫn mới',
			'settings.chatSettings.name' => 'Trò chuyện',
			'settings.chatSettings.configureYourChatSettings' => 'Cấu hình cài đặt trò chuyện',
			'settings.hardwareDecodingAuto' => 'Tự động',
			'settings.hardwareDecodingAutoCopy' => 'Tự động sao chép',
			'settings.hardwareDecodingAutoSafe' => 'Tự động an toàn',
			'settings.hardwareDecodingNo' => 'Đã tắt',
			'settings.hardwareDecodingYes' => 'Buộc bật',
			'settings.cdnDistributionStrategy' => 'Chiến lược phân phối nội dung',
			'settings.cdnDistributionStrategyDesc' => 'Chọn chiến lược phân phối máy chủ nguồn video để tối ưu tốc độ tải',
			'settings.cdnDistributionStrategyLabel' => 'Chiến lược phân phối',
			'settings.cdnDistributionStrategyNoChange' => 'Không thay đổi (dùng máy chủ gốc)',
			'settings.cdnDistributionStrategyAuto' => 'Tự động chọn (máy chủ nhanh nhất)',
			'settings.cdnDistributionStrategySpecial' => 'Chỉ định máy chủ',
			'settings.cdnSpecialServer' => 'Chỉ định máy chủ',
			'settings.cdnRefreshServerListHint' => 'Vui lòng nhấn nút bên dưới để làm mới danh sách máy chủ',
			'settings.cdnRefreshButton' => 'Làm mới',
			'settings.cdnFastRingServers' => 'Máy chủ vòng nhanh',
			'settings.cdnRefreshServerListTooltip' => 'Làm mới danh sách máy chủ',
			'settings.cdnSpeedTestButton' => 'Kiểm tra tốc độ',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Đang kiểm tra (${count})',
			_ => null,
		} ?? switch (path) {
			'settings.cdnNoServerDataHint' => 'Không có dữ liệu máy chủ, vui lòng nhấn nút làm mới',
			'settings.cdnTestingStatus' => 'Đang kiểm tra',
			'settings.cdnUnreachableStatus' => 'Không thể kết nối',
			'settings.cdnNotTestedStatus' => 'Chưa kiểm tra',
			'settings.downloadSettings.downloadSettings' => 'Cài đặt tải xuống',
			'settings.downloadSettings.enableDownloadNotifications' => 'Thông báo tải xuống',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Hiển thị thông báo hệ thống khi một lượt tải xuống hoàn tất hoặc thất bại',
			'settings.downloadSettings.notificationPermissionDenied' => 'Quyền thông báo bị từ chối. Thông báo trong ứng dụng vẫn hoạt động; hãy bật thông báo hệ thống trong cài đặt.',
			'settings.downloadSettings.storagePermissionStatus' => 'Trạng thái quyền lưu trữ',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Truy cập thư mục công khai cần quyền lưu trữ',
			'settings.downloadSettings.checkingPermissionStatus' => 'Đang kiểm tra trạng thái quyền...',
			'settings.downloadSettings.storagePermissionGranted' => 'Đã được cấp quyền lưu trữ',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Chưa được cấp quyền lưu trữ',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Cấp quyền lưu trữ thành công',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Cấp quyền lưu trữ thất bại nhưng một số tính năng có thể bị hạn chế',
			'settings.downloadSettings.storagePermissionRationale' => 'Để lưu tệp tải xuống vào thư mục bạn chọn, ứng dụng cần quyền truy cập bộ nhớ.\n\nTrên Android 11 trở lên, điều này có nghĩa là quyền "truy cập mọi tệp"; nếu không có, tệp sẽ được lưu vào thư mục riêng của ứng dụng.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Để lưu tệp tải xuống vào thư mục bạn chọn, ứng dụng cần quyền truy cập bộ nhớ.\n\nNếu không có, tệp sẽ được lưu vào thư mục riêng của ứng dụng.',
			'settings.downloadSettings.grantStoragePermission' => 'Cấp quyền lưu trữ',
			'settings.downloadSettings.customDownloadPath' => 'Đường dẫn tải xuống tùy chỉnh',
			'settings.downloadSettings.customDownloadPathDescription' => 'Khi bật, bạn có thể chọn vị trí lưu tùy chỉnh cho tệp tải xuống',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Gợi ý: Chọn thư mục công khai (như thư mục Tải xuống) cần quyền lưu trữ, nên ưu tiên dùng các đường dẫn được đề xuất',
			'settings.downloadSettings.androidWarning' => 'Lưu ý cho Android: Tránh chọn thư mục công khai (như thư mục Tải xuống), nên dùng thư mục riêng của ứng dụng để đảm bảo quyền truy cập.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Lưu ý: Bạn đã chọn thư mục công khai, cần quyền lưu trữ để tải tệp xuống bình thường',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Cần quyền lưu trữ cho thư mục công khai',
			'settings.downloadSettings.currentDownloadPath' => 'Đường dẫn tải xuống hiện tại',
			'settings.downloadSettings.actualDownloadPath' => 'Đường dẫn tải xuống thực tế',
			'settings.downloadSettings.defaultAppDirectory' => 'Thư mục ứng dụng mặc định',
			'settings.downloadSettings.permissionGranted' => 'Đã cấp',
			'settings.downloadSettings.permissionRequired' => 'Cần quyền',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Bật đường dẫn tải xuống tùy chỉnh',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Dùng đường dẫn mặc định của ứng dụng khi tắt',
			'settings.downloadSettings.customDownloadPathLabel' => 'Đường dẫn tải xuống tùy chỉnh',
			'settings.downloadSettings.selectDownloadFolder' => 'Chọn thư mục tải xuống',
			'settings.downloadSettings.recommendedPath' => 'Đường dẫn đề xuất',
			'settings.downloadSettings.selectFolder' => 'Chọn thư mục',
			'settings.downloadSettings.filenameTemplate' => 'Mẫu tên tệp',
			'settings.downloadSettings.filenameTemplateDescription' => 'Tùy chỉnh quy tắc đặt tên cho tệp tải xuống, hỗ trợ thay thế biến',
			'settings.downloadSettings.videoFilenameTemplate' => 'Mẫu tên tệp video',
			'settings.downloadSettings.galleryFolderTemplate' => 'Mẫu thư mục thư viện',
			'settings.downloadSettings.imageFilenameTemplate' => 'Mẫu tên tệp hình ảnh',
			'settings.downloadSettings.resetToDefault' => 'Đặt lại mặc định',
			'settings.downloadSettings.supportedVariables' => 'Biến được hỗ trợ',
			'settings.downloadSettings.supportedVariablesDescription' => 'Các biến sau có thể dùng trong mẫu tên tệp:',
			'settings.downloadSettings.copyVariable' => 'Sao chép biến',
			'settings.downloadSettings.variableCopied' => 'Đã sao chép biến',
			'settings.downloadSettings.warningPublicDirectory' => 'Cảnh báo: Thư mục công khai đã chọn có thể không truy cập được. Nên chọn thư mục riêng của ứng dụng.',
			'settings.downloadSettings.downloadPathUpdated' => 'Đã cập nhật đường dẫn tải xuống',
			'settings.downloadSettings.selectPathFailed' => 'Chọn đường dẫn thất bại',
			'settings.downloadSettings.pickerAlreadyActive' => 'Trình chọn thư mục đang mở',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Vị trí lưu trữ không được hỗ trợ. Hãy chọn thư mục trên bộ nhớ thiết bị hoặc thẻ SD.',
			'settings.downloadSettings.recommendedPathSet' => 'Đã đặt thành đường dẫn đề xuất',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Đặt đường dẫn đề xuất thất bại',
			'settings.downloadSettings.templateResetToDefault' => 'Đặt lại mẫu mặc định',
			'settings.downloadSettings.functionalTest' => 'Kiểm tra chức năng',
			'settings.downloadSettings.testInProgress' => 'Đang kiểm tra...',
			'settings.downloadSettings.runTest' => 'Chạy kiểm tra',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Kiểm tra xem đường dẫn tải xuống và cấu hình quyền có hoạt động đúng hay không',
			'settings.downloadSettings.testResults' => 'Kết quả kiểm tra',
			'settings.downloadSettings.testCompleted' => 'Kiểm tra hoàn tất',
			'settings.downloadSettings.testMultisegmentDomain' => 'Kiểm tra miền giá trị (đa đoạn / vượt giới hạn / dạng thoát)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Kết cấu đa đoạn (issue #126)',
			'settings.downloadSettings.testPassed' => 'mục đạt',
			'settings.downloadSettings.testFailed' => 'Kiểm tra thất bại',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Kiểm tra quyền lưu trữ',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Đã được cấp quyền lưu trữ',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Thiếu quyền lưu trữ, một số tính năng có thể bị hạn chế',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Kiểm tra quyền thất bại',
			'settings.downloadSettings.testDownloadPathValidation' => 'Kiểm tra đường dẫn tải xuống',
			'settings.downloadSettings.testPathValidationFailed' => 'Kiểm tra đường dẫn thất bại',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Kiểm tra mẫu tên tệp',
			'settings.downloadSettings.testAllTemplatesValid' => 'Tất cả mẫu đều hợp lệ',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Một số mẫu chứa ký tự không hợp lệ',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Kiểm tra mẫu thất bại',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Kiểm tra thao tác thư mục',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'Tạo thư mục và ghi tệp diễn ra bình thường',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Thao tác thư mục thất bại',
			'settings.downloadSettings.testVideoTemplate' => 'Mẫu video',
			'settings.downloadSettings.testGalleryTemplate' => 'Mẫu thư viện',
			'settings.downloadSettings.testImageTemplate' => 'Mẫu hình ảnh',
			'settings.downloadSettings.testValid' => 'Hợp lệ',
			'settings.downloadSettings.testInvalid' => 'Không hợp lệ',
			'settings.downloadSettings.testSuccess' => 'Thành công',
			'settings.downloadSettings.testCorrect' => 'Đúng',
			'settings.downloadSettings.testError' => 'Lỗi',
			'settings.downloadSettings.testPath' => 'Đường dẫn kiểm tra',
			'settings.downloadSettings.testBasePath' => 'Đường dẫn cơ sở',
			'settings.downloadSettings.testDirectoryCreation' => 'Tạo thư mục',
			'settings.downloadSettings.testFileWriting' => 'Ghi tệp',
			'settings.downloadSettings.testFileContent' => 'Nội dung tệp',
			'settings.downloadSettings.checkingPathStatus' => 'Đang kiểm tra trạng thái đường dẫn...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Không lấy được trạng thái đường dẫn',
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Lưu ý: Đường dẫn thực tế khác với đường dẫn đã chọn',
			'settings.downloadSettings.grantPermission' => 'Cấp quyền',
			'settings.downloadSettings.fixIssue' => 'Khắc phục sự cố',
			'settings.downloadSettings.issueFixed' => 'Đã khắc phục sự cố',
			'settings.downloadSettings.fixFailed' => 'Sửa thất bại, vui lòng xử lý thủ công',
			'settings.downloadSettings.lackStoragePermission' => 'Thiếu quyền lưu trữ',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Không thể truy cập thư mục công khai, cần "quyền truy cập mọi tệp"',
			'settings.downloadSettings.cannotCreateDirectory' => 'Không thể tạo thư mục',
			'settings.downloadSettings.directoryNotWritable' => 'Thư mục không ghi được',
			'settings.downloadSettings.insufficientSpace' => 'Không đủ dung lượng trống',
			'settings.downloadSettings.pathValid' => 'Đường dẫn hợp lệ',
			'settings.downloadSettings.validationFailed' => 'Kiểm tra hợp lệ thất bại',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Đang dùng thư mục ứng dụng mặc định',
			'settings.downloadSettings.appPrivateDirectory' => 'Thư mục riêng của ứng dụng',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'An toàn và đáng tin cậy, không cần quyền bổ sung',
			'settings.downloadSettings.downloadDirectory' => 'Thư mục tải xuống',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Vị trí tải xuống mặc định của hệ thống, dễ quản lý',
			'settings.downloadSettings.moviesDirectory' => 'Thư mục phim',
			'settings.downloadSettings.moviesDirectoryDesc' => 'Thư mục phim của hệ thống, ứng dụng media có thể nhận diện',
			'settings.downloadSettings.documentsDirectory' => 'Thư mục tài liệu',
			'settings.downloadSettings.documentsDirectoryDesc' => 'Thư mục tài liệu của ứng dụng iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'Cần quyền lưu trữ để truy cập',
			'settings.downloadSettings.recommendedPaths' => 'Đường dẫn đề xuất',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Thư mục riêng ứng dụng trên bộ nhớ ngoài',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Thư mục riêng của ứng dụng trên bộ nhớ ngoài, người dùng có thể truy cập, dung lượng lớn hơn',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Thư mục riêng ứng dụng trên bộ nhớ trong',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Bộ nhớ trong của ứng dụng, không cần quyền, dung lượng nhỏ hơn',
			'settings.downloadSettings.appDocumentsDirectory' => 'Thư mục tài liệu ứng dụng',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'Thư mục tài liệu riêng của ứng dụng, an toàn và đáng tin cậy',
			'settings.downloadSettings.downloadsFolder' => 'Thư mục Tải xuống',
			'settings.downloadSettings.downloadsFolderDesc' => 'Thư mục tải xuống mặc định của hệ thống',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Chọn một vị trí tải xuống được đề xuất',
			'settings.downloadSettings.noRecommendedPaths' => 'Không có đường dẫn đề xuất nào',
			'settings.downloadSettings.recommended' => 'Đề xuất',
			'settings.downloadSettings.requiresPermission' => 'Cần quyền',
			'settings.downloadSettings.authorizeAndSelect' => 'Cấp quyền và chọn',
			'settings.downloadSettings.select' => 'Chọn',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Cấp quyền thất bại, không thể chọn đường dẫn này',
			'settings.downloadSettings.pathValidationFailed' => 'Kiểm tra đường dẫn thất bại',
			'settings.downloadSettings.downloadPathSetTo' => 'Đã đặt đường dẫn tải xuống thành',
			'settings.downloadSettings.setPathFailed' => 'Đặt đường dẫn thất bại',
			'settings.downloadSettings.variableTitle' => 'Tiêu đề',
			'settings.downloadSettings.variableAuthorcache' => 'Tên đầu tiên của tác giả (không đổi khi tác giả đổi tên)',
			'settings.downloadSettings.variableAuthor' => 'Tên tác giả',
			'settings.downloadSettings.variableUsername' => 'Tên người dùng tác giả',
			'settings.downloadSettings.variableQuality' => 'Chất lượng video',
			'settings.downloadSettings.variableFilename' => 'Tên tệp gốc',
			'settings.downloadSettings.variableId' => 'ID nội dung',
			'settings.downloadSettings.variableCount' => 'Số hình ảnh trong thư viện',
			'settings.downloadSettings.variableDate' => 'Ngày hiện tại (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'Giờ hiện tại (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Ngày giờ hiện tại (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Cài đặt tải xuống',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Cấu hình đường dẫn tải xuống và quy tắc đặt tên tệp',
			'settings.downloadSettings.suchAsTitleQuality' => 'Ví dụ: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Ví dụ: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Ví dụ: %title_%filename',
			'settings.downloadSettings.structureSection' => 'Cấu trúc lưu & đặt tên',
			'settings.downloadSettings.structureSectionDescription' => 'Tệp tải về sẽ tự động vào thư mục con theo cách chọn bên dưới. Chỉ ảnh hưởng đến các lượt tải mới; tệp đã có giữ nguyên.',
			'settings.downloadSettings.structureNoticeTitle' => 'Tính năng mới: tự động gộp theo tác giả',
			'settings.downloadSettings.structureNoticeBody' => 'Chọn bên dưới · chỉ ảnh hưởng tệp tải mới, tệp đã có giữ nguyên.',
			'settings.downloadSettings.presetFlat' => 'Phẳng',
			'settings.downloadSettings.presetFlatDesc' => 'Mọi tệp nằm ngay thư mục gốc tải về',
			'settings.downloadSettings.presetAuthor' => 'Theo tác giả',
			'settings.downloadSettings.presetAuthorBadge' => 'Đề xuất',
			'settings.downloadSettings.presetAuthorDesc' => 'Mỗi tác giả một thư mục · đổi tên không tách rời',
			'settings.downloadSettings.presetDate' => 'Theo ngày',
			'settings.downloadSettings.presetDateDesc' => 'Nhóm theo ngày tải',
			'settings.downloadSettings.presetCustomActive' => 'Đang dùng',
			'settings.downloadSettings.structurePreviewLabel' => 'Xem trước',
			'settings.downloadSettings.structurePreviewNote' => 'Đoạn màu là cấp tổ chức, đổi theo cách đã chọn.',
			'settings.downloadSettings.pathTooLongWarning' => 'Đường dẫn tương đối vượt 200 ký tự, một số thiết bị có thể không lưu được',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Mẫu đường dẫn tùy chỉnh',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Tự quyết định cấu trúc thư mục và tên tệp',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Mẫu đường dẫn',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Tự động phân thư mục cho tệp tải về',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Video',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Thư viện ảnh',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Ảnh đơn',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Xem trước · kết quả lưu thực sau khi làm sạch',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Xem trước · mẫu thư viện = tên thư mục (ảnh bên trong đặt theo ID)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Thêm một cấp thư mục',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Đã đến giới hạn cấp thư mục',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, biến hoặc văn bản cố định',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'vd: %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'Phần mở rộng (.mp4) tự động thêm · gõ / trong đoạn sẽ tách hai cấp · tối đa ${max} cấp',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'Phần mở rộng gốc tự động thêm · gõ / trong đoạn sẽ tách hai cấp · tối đa ${max} cấp',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'Mẫu thư viện toàn bộ là đoạn thư mục, tối đa ${max} cấp · ảnh bên trong đặt tên theo ID ảnh',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Chạm để chèn tại con trỏ · giữ để xem giải thích',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Đoạn trống',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'Không thể lưu: còn đoạn trống, hãy xóa hoặc điền nội dung',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'Không thể lưu: quá nhiều đoạn đường dẫn (tối đa 4), hãy gộp hoặc xóa bớt',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'Không thể lưu: mẫu có chứa ký tự không hợp lệ',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Đã chèn biến',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Đã lưu · chỉ ảnh hưởng các lượt tải sau',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Nội dung',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Tác giả',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Thời gian',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Tên tác giả·cố định',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Ngày',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Giờ',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Ngày giờ',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Số thứ tự',
			'favoriteTags.title' => 'Thẻ yêu thích',
			'favoriteTags.emptyIwara' => 'Chưa có thẻ Iwara yêu thích',
			'favoriteTags.emptyOreno3d' => 'Chưa có mục yêu thích',
			'favoriteTags.addIwaraTag' => 'Thêm thẻ Iwara',
			'favoriteTags.quickPickHint' => 'Các mục đã yêu thích sẽ xuất hiện dưới dạng gợi ý nhanh khi tìm kiếm.',
			'favoriteTags.pickerTitle' => 'Chọn Oreno3D',
			'favoriteTags.searchHint' => 'Tìm theo tên hoặc tên gốc',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('vi'))(n, one: '${n} tác phẩm', other: '${n} tác phẩm', ), 
			'favoriteTags.browseEntry' => 'Duyệt theo nguồn gốc / nhân vật / thẻ',
			'favoriteTags.favoritesSection' => 'Yêu thích',
			'favoriteTags.addFavorite' => 'Thêm',
			'favoriteTags.iwaraTitle' => 'Thẻ Iwara yêu thích',
			'favoriteTags.oreno3dTitle' => 'Thẻ Oreno3D yêu thích',
			'favoriteTags.changeTag' => 'Đổi thẻ',
			'favoriteTags.switchToText' => 'Tìm kiếm văn bản',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Thẻ',
			'oreno3d.characters' => 'Nhân vật',
			'oreno3d.origin' => 'Nguồn gốc',
			'oreno3d.thirdPartyTagsExplanation' => 'Thông tin **thẻ**, **nhân vật** và **nguồn gốc** hiển thị ở đây được cung cấp bởi trang web bên thứ ba **Oreno3D** chỉ để tham khảo.\n\nVì nguồn thông tin này chỉ có tiếng Nhật, hiện tại nó chưa có bản địa hóa.\n\nNếu bạn muốn đóng góp cho nỗ lực bản địa hóa, hãy truy cập kho lưu trữ để giúp cải thiện!',
			'oreno3d.sortTypes.hot' => 'Nổi bật',
			'oreno3d.sortTypes.favorites' => 'Yêu thích',
			'oreno3d.sortTypes.latest' => 'Mới nhất',
			'oreno3d.sortTypes.popularity' => 'Phổ biến',
			'oreno3d.errors.requestFailed' => 'Yêu cầu thất bại, mã trạng thái',
			'oreno3d.errors.connectionTimeout' => 'Hết thời gian kết nối, vui lòng kiểm tra kết nối mạng',
			'oreno3d.errors.sendTimeout' => 'Hết thời gian gửi yêu cầu',
			'oreno3d.errors.receiveTimeout' => 'Hết thời gian nhận phản hồi',
			'oreno3d.errors.badCertificate' => 'Xác minh chứng chỉ thất bại',
			'oreno3d.errors.resourceNotFound' => 'Không tìm thấy tài nguyên được yêu cầu',
			'oreno3d.errors.accessDenied' => 'Truy cập bị từ chối, có thể cần xác thực hoặc quyền',
			'oreno3d.errors.serverError' => 'Lỗi máy chủ nội bộ',
			'oreno3d.errors.serviceUnavailable' => 'Dịch vụ tạm thời không khả dụng',
			'oreno3d.errors.requestCancelled' => 'Yêu cầu đã bị hủy',
			'oreno3d.errors.connectionError' => 'Lỗi kết nối mạng, vui lòng kiểm tra cài đặt mạng',
			'oreno3d.errors.networkRequestFailed' => 'Yêu cầu mạng thất bại',
			'oreno3d.errors.searchVideoError' => 'Đã xảy ra lỗi không xác định khi tìm kiếm video',
			'oreno3d.errors.getPopularVideoError' => 'Đã xảy ra lỗi không xác định khi lấy video phổ biến',
			'oreno3d.errors.getVideoDetailError' => 'Đã xảy ra lỗi không xác định khi lấy chi tiết video',
			'oreno3d.errors.parseVideoDetailError' => 'Đã xảy ra lỗi không xác định khi lấy và phân tích chi tiết video',
			'oreno3d.errors.downloadFileError' => 'Đã xảy ra lỗi không xác định khi tải tệp xuống',
			'oreno3d.loading.gettingVideoInfo' => 'Đang lấy thông tin video...',
			'oreno3d.loading.cancel' => 'Hủy',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Không tìm thấy video hoặc video đã bị xóa',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Không thể lấy liên kết phát video',
			'oreno3d.messages.getVideoDetailFailed' => 'Không lấy được chi tiết video',
			'signIn.pleaseLoginFirst' => 'Vui lòng đăng nhập trước',
			'signIn.alreadySignedInToday' => 'Hôm nay bạn đã điểm danh rồi!',
			'signIn.youDidNotStickToTheSignIn' => 'Bạn đã không duy trì việc điểm danh.',
			'signIn.signInSuccess' => 'Điểm danh thành công!',
			'signIn.signInFailed' => 'Điểm danh thất bại, vui lòng thử lại sau',
			'signIn.consecutiveSignIns' => 'Điểm danh liên tiếp',
			'signIn.failureReason' => 'Lý do thất bại',
			'signIn.selectDateRange' => 'Chọn khoảng ngày',
			'signIn.startDate' => 'Ngày bắt đầu',
			'signIn.endDate' => 'Ngày kết thúc',
			'signIn.invalidDate' => 'Ngày không hợp lệ',
			'signIn.invalidDateRange' => 'Khoảng ngày không hợp lệ',
			'signIn.errorFormatText' => 'Lỗi định dạng ngày',
			'signIn.errorInvalidText' => 'Khoảng ngày không hợp lệ',
			'signIn.errorInvalidRangeText' => 'Khoảng ngày không hợp lệ',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'Khoảng ngày không được vượt quá một năm',
			'signIn.signIn' => 'Điểm danh',
			'signIn.signInRecord' => 'Lịch sử điểm danh',
			'signIn.totalSignIns' => 'Tổng số lần điểm danh',
			'signIn.pleaseSelectSignInStatus' => 'Vui lòng chọn trạng thái điểm danh',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Vui lòng đăng nhập trước để xem các đăng ký của bạn.',
			'subscriptions.selectUser' => 'Chọn người dùng',
			'subscriptions.noSubscribedUsers' => 'Không có người dùng đã đăng ký',
			'subscriptions.showAllSubscribedUsersContent' => 'Hiển thị nội dung của tất cả người dùng đã đăng ký',
			'videoDetail.pipMode' => 'Chế độ PiP',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Tiếp tục từ vị trí lần trước: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Đã tiếp tục từ ${position}',
			'videoDetail.restartFromBeginning' => 'Bắt đầu lại',
			'videoDetail.dismissResumeTip' => 'Bỏ qua',
			'videoDetail.localInfo.videoInfo' => 'Thông tin video',
			'videoDetail.localInfo.currentQuality' => 'Chất lượng hiện tại',
			'videoDetail.localInfo.duration' => 'Thời lượng',
			'videoDetail.localInfo.resolution' => 'Độ phân giải',
			'videoDetail.localInfo.fileInfo' => 'Thông tin tệp',
			'videoDetail.localInfo.fileName' => 'Tên tệp',
			'videoDetail.localInfo.fileSize' => 'Kích thước tệp',
			'videoDetail.localInfo.filePath' => 'Đường dẫn tệp',
			'videoDetail.localInfo.copyPath' => 'Sao chép đường dẫn',
			'videoDetail.localInfo.openFolder' => 'Mở thư mục',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Đã sao chép đường dẫn vào bộ nhớ tạm',
			'videoDetail.localInfo.openFolderFailed' => 'Mở thư mục thất bại',
			'videoDetail.videoIdIsEmpty' => 'ID video trống',
			'videoDetail.videoInfoIsEmpty' => 'Thông tin video trống',
			'videoDetail.thisIsAPrivateVideo' => 'Đây là video riêng tư',
			'videoDetail.getVideoInfoFailed' => 'Lấy thông tin video thất bại, vui lòng thử lại sau',
			'videoDetail.noVideoSourceFound' => 'Không tìm thấy nguồn video',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Đã sao chép thẻ "${tagId}" vào bộ nhớ tạm',
			'videoDetail.errorLoadingVideo' => 'Lỗi khi tải video',
			'videoDetail.play' => 'Phát',
			'videoDetail.pause' => 'Tạm dừng',
			'videoDetail.exitAppFullscreen' => 'Thoát toàn màn hình ứng dụng',
			'videoDetail.enterAppFullscreen' => 'Vào toàn màn hình ứng dụng',
			'videoDetail.exitSystemFullscreen' => 'Thoát toàn màn hình hệ thống',
			'videoDetail.enterSystemFullscreen' => 'Vào toàn màn hình hệ thống',
			'videoDetail.seekTo' => 'Tua tới',
			'videoDetail.switchResolution' => 'Chuyển độ phân giải',
			'videoDetail.switchPlaybackSpeed' => 'Chuyển tốc độ phát',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Tua lại ${num} giây',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Tua tới ${num} giây',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Đang phát với tốc độ ${rate}x',
			'videoDetail.brightness' => 'Độ sáng',
			'videoDetail.brightnessLowest' => 'Độ sáng ở mức thấp nhất',
			'videoDetail.volume' => 'Âm lượng',
			'videoDetail.volumeMuted' => 'Âm lượng đã tắt tiếng',
			'videoDetail.restoreDefaultZoom' => 'Khôi phục',
			'videoDetail.gestureGuide.sampleVideo' => 'Video mẫu',
			'videoDetail.gestureGuide.title' => 'Hướng dẫn cử chỉ và tương tác',
			'videoDetail.gestureGuide.viewGuide' => 'Hướng dẫn cử chỉ và tương tác',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Dành vài giây để tìm hiểu cử chỉ của trình phát. Bạn có thể mở lại hướng dẫn này bất cứ lúc nào từ cài đặt trình phát.',
			'videoDetail.gestureGuide.startWatching' => 'Đã hiểu, bắt đầu xem',
			'videoDetail.gestureGuide.basicTitle' => 'Điều khiển cơ bản',
			'videoDetail.gestureGuide.zoomTitle' => 'Thu phóng / Xoay / Di chuyển',
			'videoDetail.gestureGuide.restoreTip' => 'Nhấn nút "Khôi phục" ở góc dưới bên phải để đặt lại thu phóng, xoay và vị trí.',
			'videoDetail.gestureGuide.mTap' => 'Nhấn một lần: hiện / ẩn điều khiển',
			'videoDetail.gestureGuide.mDoubleTap' => 'Nhấn đúp: tua lại (trái) / tạm dừng (giữa) / tua tới (phải)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Vuốt ngang: tua',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Vuốt dọc: độ sáng (trái) / âm lượng (phải)',
			'videoDetail.gestureGuide.mLongPress' => 'Nhấn giữ: tăng tốc tạm thời',
			'videoDetail.gestureGuide.mPinch' => 'Chụm hai ngón: thu phóng hình',
			'videoDetail.gestureGuide.mRotate' => 'Xoay hai ngón: xoay hình',
			'videoDetail.gestureGuide.dTap' => 'Nhấp: hiện / ẩn điều khiển',
			'videoDetail.gestureGuide.dDoubleTap' => 'Nhấp đúp: tua lại (trái) / tạm dừng (giữa) / tua tới (phải)',
			'videoDetail.gestureGuide.dKeys' => 'Phím tua: nhấn để nhảy lùi / tiến, giữ để tăng tốc; phím tốc độ: điều chỉnh tốc độ phát khi phát bình thường; Space: phát / tạm dừng',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Chụm trên bàn di chuột: thu phóng hình',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Xoay trên bàn di chuột: xoay hình',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + con lăn: thu phóng quanh con trỏ',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + con lăn: xoay quanh con trỏ',
			'videoDetail.gestureGuide.quest.title' => 'Làm quen với Quest',
			'videoDetail.gestureGuide.quest.intro' => 'Xem điều khiển nào làm gì, rồi thử ngay trong không gian của bạn.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Video không gian',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Thư viện không gian',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Dành cho màn hình và cửa sổ trong không gian Quest của bạn. Mở lại bất cứ lúc nào từ cài đặt trình phát.',
			'videoDetail.gestureGuide.quest.catalog' => 'Khám phá các điều khiển',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} / ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Trước',
			'videoDetail.gestureGuide.quest.next' => 'Điều khiển tiếp theo',
			'videoDetail.gestureGuide.quest.replay' => 'Phát lại demo',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Tạm dừng demo',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Tiếp tục demo',
			'videoDetail.gestureGuide.quest.looping' => 'Bản demo điều khiển',
			'videoDetail.gestureGuide.quest.still' => 'Ảnh minh họa tĩnh',
			'videoDetail.gestureGuide.quest.done' => 'Đã hiểu, tiếp tục',
			'videoDetail.gestureGuide.quest.leftController' => 'Tay trái',
			'videoDetail.gestureGuide.quest.rightController' => 'Tay phải',
			'videoDetail.gestureGuide.quest.trigger' => 'Cò ngón trỏ',
			'videoDetail.gestureGuide.quest.grip' => 'Nút cầm',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Cả hai nút cầm',
			'videoDetail.gestureGuide.quest.stick' => 'Cần điều khiển',
			'videoDetail.gestureGuide.quest.handTracking' => 'Theo dõi bàn tay',
			'videoDetail.gestureGuide.quest.ready' => 'Sẵn sàng',
			'videoDetail.gestureGuide.quest.press' => 'Nhấn',
			'videoDetail.gestureGuide.quest.hold' => 'Giữ',
			'videoDetail.gestureGuide.quest.release' => 'Thả',
			'videoDetail.gestureGuide.quest.result' => 'Xem kết quả',
			'videoDetail.gestureGuide.quest.pinch' => 'Chụm',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Chỉ và chọn',
			'videoDetail.gestureGuide.quest.selectBody' => 'Hướng tia vào một nút, rồi nhấn và thả cò ngón trỏ. Dùng cho phát, cài đặt và thanh trượt trên bảng điều khiển.',
			'videoDetail.gestureGuide.quest.selectHint' => 'Cò ngón trỏ nằm sau mặt nút. Nút cầm ở tay cầm bên trong dùng để nắm cửa sổ.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Hiện hoặc ẩn bảng',
			'videoDetail.gestureGuide.quest.panelBody' => 'Chỉ ra ngoài bảng điều khiển, rồi nhấn cò ngón trỏ để hiện hoặc ẩn bảng. Với theo dõi bàn tay, chụm nhanh bên ngoài bảng cũng làm điều tương tự.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Dùng một cú nhấn ngắn, không kéo. Giữ và di chuyển là thao tác kéo, không phải bật/tắt bảng.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Phát và tạm dừng',
			'videoDetail.gestureGuide.quest.playBody' => 'Chỉ ra xa bảng điều khiển và nhấn A bên phải hoặc X bên trái để phát hoặc tạm dừng. Bạn cũng có thể chọn nút phát trên bảng.',
			'videoDetail.gestureGuide.quest.playHint' => 'Phím tắt mặc định này có thể tắt trong cài đặt trình phát không gian. Khi chỉ vào bảng, dữ liệu nhập sẽ chuyển cho bảng.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Tua bằng cần gạt',
			'videoDetail.gestureGuide.quest.seekBody' => 'Đẩy cần gạt sang trái hoặc phải để nhảy 5 giây. Giữ để tua nhanh hơn trong khi xem trước thời điểm đích. Thả ra để xác nhận tua.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Giữ tia của bộ điều khiển đó ngoài bảng điều khiển. Cần gạt chỉ vào bảng sẽ cuộn bảng thay vào đó.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Duyệt bằng cần gạt',
			'videoDetail.gestureGuide.quest.browseBody' => 'Đẩy cần gạt sang trái hoặc phải để chuyển mục trước hoặc sau; giữ để tiếp tục duyệt. Bạn cũng có thể chọn một ảnh thu nhỏ trong dải phim.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Video trong thư viện cũng là các mục. Chỉ vào bảng điều khiển sẽ khiến cần gạt cuộn bảng.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Kéo ngang để lật trang',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Hướng vào hình ảnh, giữ cò ngón trỏ và kéo sang trái. Thả ra sau tín hiệu lật trang để chuyển tiếp; kéo sang phải để lùi lại. Chụm và kéo cũng hoạt động.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Hình ảnh phải ở mức 1× để lật trang bằng cách kéo. Video trong thư viện cũng hỗ trợ. Sân khấu đứng yên cho đến khi bạn thả ra.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'Thu phóng vào hình ảnh',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Hướng vào một chi tiết trong hình ảnh, giữ cò ngón trỏ, rồi đẩy cần gạt lên để phóng to hoặc xuống để thu nhỏ. Thu phóng neo tại điểm bạn nhấn.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Thao tác này phóng to hình ảnh bên trong cửa sổ của nó. Nếu không giữ hình ảnh, lên/xuống sẽ điều chỉnh khoảng cách xem.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Di chuyển và khôi phục hình ảnh',
			'videoDetail.gestureGuide.quest.panBody' => 'Sau khi đã thu phóng, giữ cò ngón trỏ và kéo để nhìn quanh. Nhấn đúp vào hình ảnh để thu phóng lên 2.5× hoặc khôi phục. Với bàn tay, chụm hai lần thật nhanh.',
			'videoDetail.gestureGuide.quest.panHint' => 'Kéo để di chuyển một hình ảnh đã thu phóng. Khôi phục về 1× trước khi kéo để lật trang.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Bắt đầu trình chiếu',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'Trên một hình ảnh, A / X bắt đầu hoặc tạm dừng trình chiếu. Bảng cung cấp khoảng thời gian 3, 5, 10 hoặc 20 giây và chất lượng hình ảnh tiêu chuẩn hoặc gốc.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'Trên video trong thư viện, A / X điều khiển việc phát video đó. Phím tắt bộ điều khiển phải được bật trong cài đặt.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Nắm và di chuyển màn hình',
			'videoDetail.gestureGuide.quest.moveBody' => 'Giữ nút cầm ở tay cầm bên trong, di chuyển bộ điều khiển để đặt vị trí màn hình, rồi thả ra. Khi đang xem, bạn có thể nắm màn hình mà không cần chỉ vào nó.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Chỉ vào cửa sổ ứng dụng hoặc bảng điều khiển sẽ nắm cửa sổ đó trước. Trong video toàn cảnh, việc cầm nắm sẽ điều chỉnh hướng.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Đổi kích thước bằng cả hai tay',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Giữ cả hai nút cầm. Dang hai tay ra để phóng to màn hình, hoặc chụm lại để thu nhỏ. Với theo dõi bàn tay, giữ thao tác chụm ở cả hai tay.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Cho màn hình phẳng hoặc cong, kể cả sân khấu thư viện. Giữ tia ngoài bảng điều khiển. Thao tác này đổi kích thước toàn bộ màn hình.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Điều chỉnh khoảng cách xem',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Đẩy cần gạt lên để đưa màn hình ra xa, hoặc xuống để kéo lại gần. Khi đang nắm một cửa sổ, lên/xuống sẽ di chuyển cửa sổ đó. Điều chỉnh âm lượng trên bảng.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Chỉ ra xa bảng điều khiển. Giữ một hình ảnh sẽ đổi lên/xuống thành thu phóng hình ảnh; video toàn cảnh sẽ điều chỉnh tầm nhìn thay vào đó.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Dùng các cạnh và góc',
			'videoDetail.gestureGuide.quest.resizeBody' => 'Khung sẽ sáng lên khi tia của bạn tiến gần một cạnh. Giữ cò hoặc chụm vào một cạnh để di chuyển cửa sổ; kéo một góc để đổi kích thước.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Hoạt động trên cửa sổ ứng dụng, bảng điều khiển và màn hình. Cửa sổ ứng dụng thay đổi chiều rộng và chiều cao; màn hình giữ nguyên tỉ lệ khung hình.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Quay lại và mở cài đặt',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y lùi một cấp: đóng cửa sổ bật lên hoặc quay về trang chính của bảng, ẩn bảng, rồi quay về ứng dụng. Nút Menu bên trái mở cài đặt không gian.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'Nút Meta bên phải thuộc về hệ thống. Chức năng định vị lại của hệ thống đưa tầm nhìn về phía trước trong khi giữ nguyên kích thước và khoảng cách màn hình.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Dùng bàn tay',
			'videoDetail.gestureGuide.quest.handsBody' => 'Khi bật theo dõi bàn tay, hướng tia của hệ thống vào một nút, chụm ngón cái và ngón trỏ, rồi thả ra. Dùng bảng để phát, tua và điều hướng thư viện.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Chụm bên ngoài để bật/tắt bảng. Chụm một cạnh để di chuyển, một góc để đổi kích thước, hoặc chụm bằng cả hai tay rồi dang ra để phóng to màn hình.',
			'videoDetail.home' => 'Trang chủ',
			'videoDetail.videoPlayer' => 'Trình phát video',
			'videoDetail.videoPlayerInfo' => 'Thông tin trình phát video',
			'videoDetail.moreSettings' => 'Cài đặt thêm',
			'videoDetail.videoPlayerFeatureInfo' => 'Thông tin tính năng trình phát video',
			'videoDetail.autoRewind' => 'Tự động tua lại',
			'videoDetail.rewindAndFastForward' => 'Tua lại và tua tới',
			'videoDetail.volumeAndBrightness' => 'Âm lượng và độ sáng',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Nhấn đúp vùng giữa để tạm dừng hoặc phát',
			'videoDetail.showVerticalVideoInFullScreen' => 'Hiển thị video dọc ở chế độ toàn màn hình',
			'videoDetail.keepLastVolumeAndBrightness' => 'Giữ âm lượng và độ sáng lần trước',
			'videoDetail.setProxy' => 'Đặt proxy',
			'videoDetail.moreFeaturesToBeDiscovered' => 'Còn nhiều tính năng đang chờ khám phá...',
			'videoDetail.videoPlayerSettings' => 'Cài đặt trình phát video',
			'videoDetail.commentCount' => ({required Object num}) => '${num} bình luận',
			'videoDetail.writeYourCommentHere' => 'Viết bình luận của bạn ở đây...',
			'videoDetail.authorOtherVideos' => 'Video khác của tác giả',
			'videoDetail.relatedVideos' => 'Video liên quan',
			'videoDetail.privateVideo' => 'Đây là video riêng tư',
			'videoDetail.externalVideo' => 'Đây là video bên ngoài',
			'videoDetail.openInBrowser' => 'Mở trong trình duyệt',
			'videoDetail.resourceDeleted' => 'Video này có vẻ đã bị xóa :/',
			'videoDetail.noDownloadUrl' => 'Không có URL tải xuống',
			'videoDetail.startDownloading' => 'Bắt đầu tải xuống',
			'videoDetail.downloadFailed' => 'Tải xuống thất bại, vui lòng thử lại sau',
			'videoDetail.downloadSuccess' => 'Tải xuống thành công',
			'videoDetail.download' => 'Tải xuống',
			'videoDetail.downloadManager' => 'Trình quản lý tải xuống',
			'videoDetail.resourceNotFound' => 'Không tìm thấy tài nguyên',
			'videoDetail.videoLoadError' => 'Lỗi tải video',
			'videoDetail.authorNoOtherVideos' => 'Tác giả không có video khác',
			'videoDetail.noRelatedVideos' => 'Không có video liên quan',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Lỗi khi tải nguồn video',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Lỗi khi thiết lập trình lắng nghe',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Phát hiện lỗi máy chủ, tự động chuyển tuyến và thử lại',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Đang lấy thông tin video...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Đang lấy nguồn video...',
			'videoDetail.skeleton.loadingVideo' => 'Đang tải video...',
			'videoDetail.skeleton.applyingSolution' => 'Đang áp dụng giải pháp...',
			'videoDetail.skeleton.addingListeners' => 'Đang thêm trình lắng nghe...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Đã lấy thành công thời lượng video, bắt đầu tải video...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Tải hoàn tất',
			'videoDetail.cast.dlnaCast' => 'Truyền phát',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Không thể bắt đầu tìm kiếm truyền phát: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Bắt đầu truyền phát tới ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Truyền phát thất bại: ${error}\nVui lòng thử tìm lại thiết bị hoặc chuyển mạng',
			'videoDetail.cast.castStopped' => 'Đã dừng truyền phát',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Trình phát media',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Máy chủ media',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Bộ định tuyến',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Thiết bị cơ bản',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Đèn thông minh',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'Điểm truy cập WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'Thiết bị kết nối WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'Máy in',
			'videoDetail.cast.deviceTypes.scanner' => 'Máy quét',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Camera an ninh kỹ thuật số',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Thiết bị không xác định',
			'videoDetail.cast.currentPlatformNotSupported' => 'Nền tảng hiện tại không hỗ trợ truyền phát',
			'videoDetail.cast.unableToGetVideoUrl' => 'Không lấy được URL video, vui lòng thử lại sau',
			'videoDetail.cast.stopCasting' => 'Dừng truyền phát',
			'videoDetail.cast.dlnaCastSheet.title' => 'Truyền phát từ xa',
			'videoDetail.cast.dlnaCastSheet.close' => 'Đóng',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Đang tìm thiết bị...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Nhấn nút tìm kiếm để tìm lại thiết bị truyền phát',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Đang tìm kiếm',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Tìm lại',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'Không tìm thấy thiết bị truyền phát nào\nVui lòng đảm bảo các thiết bị cùng mạng',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Đang tìm thiết bị, vui lòng chờ...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Truyền phát',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Đã kết nối với: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Chưa kết nối thiết bị nào',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Dừng truyền phát',
			'videoDetail.likeAvatars.dialogTitle' => 'Ai đang âm thầm thích',
			'videoDetail.likeAvatars.dialogDescription' => 'Tò mò họ là ai? Lật xem "Album lượt thích" này~',
			'videoDetail.likeAvatars.closeTooltip' => 'Đóng',
			'videoDetail.likeAvatars.retry' => 'Thử lại',
			'videoDetail.likeAvatars.noLikesYet' => 'Chưa có ai xuất hiện ở đây. Hãy là người đầu tiên!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Trang ${page} / ${totalPages} · Tổng ${totalCount} người',
			'videoDetail.likeAvatars.prevPage' => 'Trang trước',
			'videoDetail.likeAvatars.nextPage' => 'Trang sau',
			'share.sharePlayList' => 'Chia sẻ danh sách phát',
			'share.wowDidYouSeeThis' => 'Chà, bạn thấy cái này chưa?',
			'share.nameIs' => 'Tên là',
			'share.clickLinkToView' => 'Nhấn liên kết để xem',
			'share.iReallyLikeThis' => 'Tôi rất thích cái này',
			'share.shareFailed' => 'Chia sẻ thất bại, vui lòng thử lại sau',
			'share.share' => 'Chia sẻ',
			'share.shareAsImage' => 'Chia sẻ dưới dạng hình ảnh',
			'share.shareAsText' => 'Chia sẻ dưới dạng văn bản',
			'share.shareAsImageDesc' => 'Chia sẻ ảnh bìa video dưới dạng hình ảnh',
			'share.shareAsTextDesc' => 'Chia sẻ thông tin chi tiết video dưới dạng văn bản',
			'share.shareAsImageFailed' => 'Chia sẻ ảnh bìa video dưới dạng hình ảnh thất bại, vui lòng thử lại sau',
			'share.shareAsTextFailed' => 'Chia sẻ thông tin chi tiết video dưới dạng văn bản thất bại, vui lòng thử lại sau',
			'share.shareVideo' => 'Chia sẻ video',
			'share.authorIs' => 'Tác giả là',
			'share.shareGallery' => 'Chia sẻ thư viện',
			'share.galleryTitleIs' => 'Tiêu đề thư viện là',
			'share.galleryAuthorIs' => 'Tác giả thư viện là',
			'share.shareUser' => 'Chia sẻ người dùng',
			'share.userNameIs' => 'Tên người dùng là',
			'share.userAuthorIs' => 'Tác giả người dùng là',
			'share.comments' => 'Bình luận',
			'share.shareThread' => 'Chia sẻ chủ đề',
			'share.views' => 'Lượt xem',
			'share.sharePost' => 'Chia sẻ bài viết',
			'share.postTitleIs' => 'Tiêu đề bài viết là',
			'share.postAuthorIs' => 'Tác giả bài viết là',
			'markdown.markdownSyntax' => 'Cú pháp Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Cú pháp Markdown đặc biệt của Iwara',
			'markdown.internalLink' => 'Liên kết nội bộ',
			'markdown.supportAutoConvertLinkBelow' => 'Hỗ trợ tự động chuyển đổi liên kết dưới đây:',
			_ => null,
		} ?? switch (path) {
			'markdown.convertLinkExample' => '🎬 Liên kết video\n🖼️ Liên kết ảnh\n👤 Liên kết người dùng\n📌 Liên kết diễn đàn\n🎵 Liên kết danh sách phát\n💬 Liên kết chủ đề',
			'markdown.mentionUser' => 'Nhắc tên người dùng',
			'markdown.mentionUserDescription' => 'Nhập @ theo sau là tên người dùng, sẽ tự động chuyển thành liên kết người dùng',
			'markdown.markdownBasicSyntax' => 'Cú pháp Markdown cơ bản',
			'markdown.paragraphAndLineBreak' => 'Đoạn văn và ngắt dòng',
			'markdown.paragraphAndLineBreakDescription' => 'Các đoạn văn được phân tách bằng một dòng, và hai dấu cách ở cuối dòng sẽ được chuyển thành ngắt dòng',
			'markdown.paragraphAndLineBreakSyntax' => 'Đây là đoạn văn thứ nhất\n\nĐây là đoạn văn thứ hai\nDòng này kết thúc bằng hai dấu cách  \nsẽ được chuyển thành ngắt dòng',
			'markdown.textStyle' => 'Kiểu chữ',
			'markdown.textStyleDescription' => 'Dùng ký hiệu đặc biệt bao quanh văn bản để đổi kiểu',
			'markdown.textStyleSyntax' => '**Chữ đậm**\n*Chữ nghiêng*\n~~Chữ gạch ngang~~\n`Chữ mã`',
			'markdown.quote' => 'Trích dẫn',
			'markdown.quoteDescription' => 'Dùng ký hiệu > để tạo trích dẫn, nhiều > để tạo trích dẫn nhiều cấp',
			'markdown.quoteSyntax' => '> Đây là trích dẫn cấp một\n>> Đây là trích dẫn cấp hai',
			'markdown.list' => 'Danh sách',
			'markdown.listDescription' => 'Tạo danh sách có thứ tự bằng số + dấu chấm, tạo danh sách không thứ tự bằng dấu -',
			'markdown.listSyntax' => '1. Mục thứ nhất\n2. Mục thứ hai\n\n- Mục không thứ tự\n  - Mục con\n  - Mục con khác',
			'markdown.linkAndImage' => 'Liên kết và hình ảnh',
			'markdown.linkAndImageDescription' => 'Định dạng liên kết: [văn bản](URL)\nĐịnh dạng ảnh: ![mô tả](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[văn bản liên kết](${link})\n![mô tả ảnh](${imgUrl})',
			'markdown.title' => 'Tiêu đề',
			'markdown.titleDescription' => 'Dùng ký hiệu # để tạo tiêu đề, số lượng # thể hiện cấp',
			'markdown.titleSyntax' => '# Tiêu đề cấp một\n## Tiêu đề cấp hai\n### Tiêu đề cấp ba',
			'markdown.separator' => 'Đường phân cách',
			'markdown.separatorDescription' => 'Tạo đường phân cách bằng ba ký hiệu - trở lên',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Cú pháp',
			'forum.attachQuote' => 'Đính kèm trích dẫn',
			'forum.replyToFloor' => ({required Object floor, required Object username}) => 'Trả lời #${floor} @${username}',
			'forum.removeQuote' => 'Xóa trích dẫn',
			'forum.recent' => 'Gần đây',
			'forum.category' => 'Danh mục',
			'forum.lastReply' => 'Trả lời gần nhất',
			'forum.sitewide.badge' => 'Toàn trang',
			'forum.sitewide.title' => 'Thông báo toàn trang',
			'forum.sitewide.readMore' => 'Đọc thêm',
			'forum.errors.pleaseSelectCategory' => 'Vui lòng chọn một danh mục',
			'forum.errors.threadLocked' => 'Chủ đề này đã bị khóa, không thể trả lời',
			'forum.createPost' => 'Tạo bài viết',
			'forum.title' => 'Tiêu đề',
			'forum.enterTitle' => 'Nhập tiêu đề',
			'forum.content' => 'Nội dung',
			'forum.enterContent' => 'Nhập nội dung',
			'forum.writeYourContentHere' => 'Viết nội dung tại đây...',
			'forum.posts' => 'Bài viết',
			'forum.threads' => 'Chủ đề',
			'forum.forum' => 'Diễn đàn',
			'forum.createThread' => 'Tạo chủ đề',
			'forum.selectCategory' => 'Chọn danh mục',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Thời gian chờ còn lại ${minutes} phút ${seconds} giây',
			'forum.groups.administration' => 'Quản trị',
			'forum.groups.global' => 'Toàn cầu',
			'forum.groups.chinese' => 'Tiếng Trung',
			'forum.groups.japanese' => 'Tiếng Nhật',
			'forum.groups.korean' => 'Tiếng Hàn',
			'forum.groups.other' => 'Khác',
			'forum.leafNames.announcements' => 'Thông báo',
			'forum.leafNames.feedback' => 'Phản hồi',
			'forum.leafNames.support' => 'Hỗ trợ',
			'forum.leafNames.general' => 'Chung',
			'forum.leafNames.guides' => 'Hướng dẫn',
			'forum.leafNames.questions' => 'Câu hỏi',
			'forum.leafNames.requests' => 'Yêu cầu',
			'forum.leafNames.sharing' => 'Chia sẻ',
			'forum.leafNames.general_zh' => 'Chung',
			'forum.leafNames.questions_zh' => 'Câu hỏi',
			'forum.leafNames.requests_zh' => 'Yêu cầu',
			'forum.leafNames.support_zh' => 'Hỗ trợ',
			'forum.leafNames.general_ja' => 'Chung',
			'forum.leafNames.questions_ja' => 'Câu hỏi',
			'forum.leafNames.requests_ja' => 'Yêu cầu',
			'forum.leafNames.support_ja' => 'Hỗ trợ',
			'forum.leafNames.korean' => 'Tiếng Hàn',
			'forum.leafNames.other' => 'Khác',
			'forum.leafDescriptions.announcements' => 'Thông báo và tin tức chính thức quan trọng',
			'forum.leafDescriptions.feedback' => 'Phản hồi về tính năng và dịch vụ của trang web',
			'forum.leafDescriptions.support' => 'Giúp giải quyết các vấn đề liên quan tới trang web',
			'forum.leafDescriptions.general' => 'Thảo luận mọi chủ đề',
			'forum.leafDescriptions.guides' => 'Chia sẻ kinh nghiệm và hướng dẫn',
			'forum.leafDescriptions.questions' => 'Đặt câu hỏi của bạn',
			'forum.leafDescriptions.requests' => 'Đăng yêu cầu của bạn',
			'forum.leafDescriptions.sharing' => 'Chia sẻ nội dung thú vị',
			'forum.leafDescriptions.general_zh' => 'Thảo luận mọi chủ đề',
			'forum.leafDescriptions.questions_zh' => 'Đặt câu hỏi của bạn',
			'forum.leafDescriptions.requests_zh' => 'Đăng yêu cầu của bạn',
			'forum.leafDescriptions.support_zh' => 'Giúp giải quyết các vấn đề liên quan tới trang web',
			'forum.leafDescriptions.general_ja' => 'Thảo luận mọi chủ đề',
			'forum.leafDescriptions.questions_ja' => 'Đặt câu hỏi của bạn',
			'forum.leafDescriptions.requests_ja' => 'Đăng yêu cầu của bạn',
			'forum.leafDescriptions.support_ja' => 'Giúp giải quyết các vấn đề liên quan tới trang web',
			'forum.leafDescriptions.korean' => 'Thảo luận liên quan tới tiếng Hàn',
			'forum.leafDescriptions.other' => 'Nội dung khác chưa được phân loại',
			'forum.reply' => 'Trả lời',
			'forum.pendingReview' => 'Đang chờ duyệt',
			'forum.floorNotFound' => 'Bài trả lời đó không tồn tại hoặc đã bị xóa',
			'forum.floorNotLoadedYet' => 'Bài đó ở phía trên — tải thêm để nhảy tới',
			'forum.editedAt' => 'Chỉnh sửa lúc',
			'forum.copySuccess' => 'Đã sao chép vào clipboard',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Đã sao chép vào clipboard: ${str}',
			'forum.editReply' => 'Chỉnh sửa trả lời',
			'forum.editTitle' => 'Chỉnh sửa tiêu đề',
			'forum.submit' => 'Gửi',
			'notifications.errors.unsupportedNotificationType' => 'Loại thông báo không được hỗ trợ',
			'notifications.errors.unknownUser' => 'Người dùng không xác định',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Loại thông báo không được hỗ trợ: ${type}',
			'notifications.errors.unknownNotificationType' => 'Loại thông báo không xác định',
			'notifications.notifications' => 'Thông báo',
			'notifications.profile' => 'Trang cá nhân',
			'notifications.postedNewComment' => 'Đã đăng bình luận mới',
			'notifications.inYour' => 'trong',
			'notifications.video' => 'Video',
			'notifications.repliedYourVideoComment' => 'Đã trả lời bình luận video của bạn',
			'notifications.copyInfoToClipboard' => 'Sao chép thông tin thông báo vào bộ nhớ tạm',
			'notifications.copySuccess' => 'Đã sao chép vào bộ nhớ tạm',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Đã sao chép vào bộ nhớ tạm: ${str}',
			'notifications.markAllAsRead' => 'Đánh dấu tất cả là đã đọc',
			'notifications.markAllAsReadSuccess' => 'Tất cả thông báo đã được đánh dấu là đã đọc',
			'notifications.markAllAsReadFailed' => 'Đánh dấu tất cả là đã đọc thất bại',
			'notifications.markSelectedAsRead' => 'Đánh dấu mục đã chọn là đã đọc',
			'notifications.markSelectedAsReadSuccess' => 'Các thông báo đã chọn đã được đánh dấu là đã đọc',
			'notifications.markSelectedAsReadFailed' => 'Đánh dấu mục đã chọn là đã đọc thất bại',
			'notifications.markAsRead' => 'Đánh dấu là đã đọc',
			'notifications.markAsReadSuccess' => 'Thông báo đã được đánh dấu là đã đọc',
			'notifications.markAsReadFailed' => 'Đánh dấu thông báo là đã đọc thất bại',
			'notifications.notificationTypeHelp' => 'Trợ giúp về loại thông báo',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Do thiếu chi tiết loại thông báo, các loại được hỗ trợ có thể không bao quát hết những thông báo bạn đang nhận',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Nếu bạn sẵn lòng giúp chúng tôi cải thiện hỗ trợ loại thông báo',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Sao chép thông tin thông báo\n2. 🐞 Gửi issue tới kho lưu trữ dự án\n\n⚠️ Lưu ý: Thông tin thông báo có thể chứa thông tin riêng tư cá nhân, nếu bạn không muốn công khai, bạn cũng có thể gửi cho tác giả dự án qua email.',
			'notifications.goToRepository' => 'Đi tới kho lưu trữ',
			'notifications.copy' => 'Sao chép',
			'notifications.commentApproved' => 'Bình luận đã được duyệt',
			'notifications.repliedYourProfileComment' => 'Đã trả lời bình luận trang cá nhân của bạn',
			'notifications.kReplied' => 'đã trả lời bình luận của bạn về',
			'notifications.kCommented' => 'đã bình luận về',
			'notifications.kVideo' => 'video',
			'notifications.kGallery' => 'thư viện',
			'notifications.kProfile' => 'trang cá nhân',
			'notifications.kThread' => 'chủ đề',
			'notifications.kPost' => 'bài viết',
			'notifications.kCommentSection' => 'mục bình luận',
			'notifications.kApprovedComment' => 'Bình luận đã được duyệt',
			'notifications.kApprovedVideo' => 'Video đã được duyệt',
			'notifications.kApprovedGallery' => 'Thư viện đã được duyệt',
			'notifications.kApprovedThread' => 'Chủ đề đã được duyệt',
			'notifications.kApprovedPost' => 'Bài viết đã được duyệt',
			'notifications.kApprovedForumPost' => 'Bài viết diễn đàn đã được duyệt',
			'notifications.kRejectedContent' => 'Nội dung bị từ chối phê duyệt',
			'notifications.kUnknownType' => 'Loại thông báo không xác định',
			'conversation.errors.pleaseSelectAUser' => 'Vui lòng chọn một người dùng',
			'conversation.errors.pleaseEnterATitle' => 'Vui lòng nhập tiêu đề',
			'conversation.errors.clickToSelectAUser' => 'Nhấn để chọn người dùng',
			'conversation.errors.loadFailedClickToRetry' => 'Tải thất bại, nhấn để thử lại',
			'conversation.errors.loadFailed' => 'Tải thất bại',
			'conversation.errors.clickToRetry' => 'Nhấn để thử lại',
			'conversation.errors.noMoreConversations' => 'Không còn hội thoại',
			'conversation.conversation' => 'Hội thoại',
			'conversation.startConversation' => 'Bắt đầu hội thoại',
			'conversation.noConversation' => 'Không có hội thoại',
			'conversation.selectFromLeftListAndStartConversation' => 'Chọn từ danh sách bên trái và bắt đầu hội thoại',
			'conversation.title' => 'Tiêu đề',
			'conversation.body' => 'Nội dung',
			'conversation.selectAUser' => 'Chọn một người dùng',
			'conversation.searchUsers' => 'Tìm kiếm người dùng...',
			'conversation.tmpNoConversions' => 'Không có hội thoại',
			'conversation.deleteThisMessage' => 'Xóa tin nhắn này',
			'conversation.deleteThisMessageSubtitle' => 'Thao tác này không thể hoàn tác',
			'conversation.writeMessageHere' => 'Viết tin nhắn tại đây...',
			'conversation.lastMessageFromMe' => 'Bạn: ',
			'conversation.sendMessage' => 'Gửi tin nhắn',
			'splash.errors.initializationFailed' => 'Khởi tạo thất bại, vui lòng khởi động lại ứng dụng',
			'splash.preparing' => 'Đang chuẩn bị...',
			'splash.initializing' => 'Đang khởi tạo...',
			'splash.loading' => 'Đang tải...',
			'splash.ready' => 'Sẵn sàng',
			'splash.initializingMessageService' => 'Đang khởi tạo dịch vụ tin nhắn...',
			'download.errors.imageModelNotFound' => 'Không tìm thấy mẫu ảnh',
			'download.errors.downloadFailed' => 'Tải xuống thất bại',
			'download.errors.videoInfoNotFound' => 'Không tìm thấy thông tin video',
			'download.errors.downloadTaskAlreadyExists' => 'Tác vụ tải xuống đã tồn tại',
			'download.errors.downloadTaskSavePathConflict' => 'Đường dẫn lưu đang được tác vụ khác sử dụng',
			'download.errors.videoAlreadyDownloaded' => 'Video đã được tải xuống',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Thêm tác vụ tải xuống thất bại: ${errorInfo}',
			'download.errors.userPausedDownload' => 'Người dùng đã tạm dừng tải xuống',
			'download.errors.unknown' => 'Không xác định',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Lỗi hệ thống tệp: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Lỗi không xác định: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'Ghi tệp thất bại: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Kết nối quá thời gian',
			'download.errors.sendTimeout' => 'Gửi quá thời gian',
			'download.errors.receiveTimeout' => 'Nhận quá thời gian',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Lỗi máy chủ: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Lỗi mạng không xác định',
			'download.errors.sslHandshakeFailed' => 'Bắt tay SSL thất bại, vui lòng kiểm tra mạng',
			'download.errors.connectionFailed' => 'Kết nối thất bại, vui lòng kiểm tra mạng',
			'download.errors.serviceIsClosing' => 'Dịch vụ tải xuống đang đóng',
			'download.errors.partialDownloadFailed' => 'Tải nội dung một phần thất bại',
			'download.errors.noDownloadTask' => 'Không có tác vụ tải xuống',
			'download.errors.taskNotFoundOrDataError' => 'Không tìm thấy tác vụ hoặc lỗi dữ liệu',
			'download.errors.fileNotFound' => 'Không tìm thấy tệp',
			'download.errors.openFolderFailed' => 'Mở thư mục thất bại',
			'download.errors.copyDownloadUrlFailed' => 'Sao chép URL tải xuống thất bại',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Mở thư mục thất bại: ${message}',
			'download.errors.directoryNotFound' => 'Không tìm thấy thư mục',
			'download.errors.copyFailed' => 'Sao chép thất bại',
			'download.errors.openFileFailed' => 'Mở tệp thất bại',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Mở tệp thất bại: ${message}',
			'download.errors.playLocallyFailed' => 'Phát cục bộ thất bại',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Phát cục bộ thất bại: ${message}',
			'download.errors.noDownloadSource' => 'Không có nguồn tải xuống',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'Không có nguồn tải xuống, vui lòng đợi tải xong thông tin rồi thử lại',
			'download.errors.noActiveDownloadTask' => 'Không có tác vụ tải xuống đang hoạt động',
			'download.errors.noFailedDownloadTask' => 'Không có tác vụ tải xuống thất bại',
			'download.errors.noCompletedDownloadTask' => 'Không có tác vụ tải xuống đã hoàn thành',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Tác vụ đã hoàn thành, không thêm lại',
			'download.errors.linkExpiredTryAgain' => 'Liên kết đã hết hạn, đang thử lấy liên kết tải xuống mới',
			'download.errors.linkExpiredTryAgainSuccess' => 'Liên kết đã hết hạn, lấy liên kết tải xuống mới thành công',
			'download.errors.linkExpiredTryAgainFailed' => 'Liên kết đã hết hạn, lấy liên kết tải xuống mới thất bại',
			'download.errors.taskDeleted' => 'Đã xóa tác vụ',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Định dạng ảnh không được hỗ trợ: ${format}',
			'download.errors.deleteFileError' => 'Xóa tệp thất bại, có thể do tệp đang được tiến trình khác sử dụng',
			'download.errors.deleteTaskError' => 'Xóa tác vụ thất bại',
			'download.errors.canNotRefreshVideoTask' => 'Làm mới tác vụ video thất bại',
			'download.errors.videoRemovedCanNotRefresh' => 'Video này đã bị xóa hoặc không còn tồn tại nên không thể làm mới liên kết tải xuống',
			'download.errors.videoInaccessibleCanNotRefresh' => 'Không thể truy cập video này, có thể video ở chế độ riêng tư hoặc cần đăng nhập lại',
			'download.errors.videoQualityGone' => 'Chất lượng này không còn được cung cấp, vui lòng thêm lại tác vụ tải xuống',
			'download.errors.refreshLinkNetworkFailed' => 'Lỗi mạng, hiện không thể làm mới liên kết tải xuống, vui lòng thử lại sau',
			'download.errors.taskAlreadyProcessing' => 'Tác vụ đang được xử lý',
			'download.errors.taskNotFound' => 'Không tìm thấy tác vụ',
			'download.errors.failedToLoadTasks' => 'Tải danh sách tác vụ thất bại',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Tải một phần thất bại: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Định dạng ảnh không được hỗ trợ: ${extension}, có thể thử tải về thiết bị để xem',
			'download.errors.imageLoadFailed' => 'Tải ảnh thất bại',
			'download.errors.pleaseTryOtherViewer' => 'Vui lòng thử dùng trình xem khác để mở',
			'download.downloadList' => 'Danh sách tải xuống',
			'download.viewDownloadList' => 'Xem danh sách tải xuống',
			'download.download' => 'Tải xuống',
			'download.selectDownloadTitle' => 'Chọn tải xuống',
			'download.qualitySectionLabel' => 'Chất lượng',
			'download.categorySectionLabel' => 'Phân loại',
			'download.saveToPreviewLabel' => 'Sẽ lưu vào',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Tên tệp gợi ý: ${name} (có thể sửa trong hộp thoại hệ thống)',
			'download.lastUsedBadge' => 'Dùng gần nhất',
			'download.pickedBadge' => 'Đã chọn',
			'download.startDownloading' => 'Bắt đầu tải xuống',
			'download.clearAllFailedTasks' => 'Xóa toàn bộ tác vụ thất bại',
			'download.clearAllFailedTasksConfirmation' => 'Bạn có chắc muốn xóa toàn bộ tác vụ tải xuống thất bại? Tệp của các tác vụ này cũng sẽ bị xóa.',
			'download.clearAllFailedTasksSuccess' => 'Đã xóa toàn bộ tác vụ thất bại',
			'download.clearAllFailedTasksError' => 'Đã xảy ra lỗi khi xóa tác vụ thất bại',
			'download.downloadStatus' => 'Trạng thái tải xuống',
			'download.imageList' => 'Danh sách ảnh',
			'download.retryDownload' => 'Thử tải lại',
			'download.notDownloaded' => 'Chưa tải xuống',
			'download.downloaded' => 'Đã tải xuống',
			'download.waitingForDownload' => 'Đang chờ tải xuống',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Đang tải (${downloaded}/${total} ảnh ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Đang tải (${downloaded} ảnh)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Đã tạm dừng (${downloaded}/${total} ảnh ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'Đã tạm dừng (${downloaded} ảnh)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Đã tải xuống (tổng ${total} ảnh)',
			'download.viewVideoDetail' => 'Xem chi tiết video',
			'download.viewGalleryDetail' => 'Xem chi tiết thư viện',
			'download.moreOptions' => 'Tùy chọn khác',
			'download.openFile' => 'Mở tệp',
			'download.playLocally' => 'Phát cục bộ',
			'download.pause' => 'Tạm dừng',
			'download.resume' => 'Tiếp tục',
			'download.copyDownloadUrl' => 'Sao chép URL tải xuống',
			'download.showInFolder' => 'Hiện trong thư mục',
			'download.deleteTask' => 'Xóa tác vụ',
			'download.deleteTaskConfirmation' => 'Bạn có chắc muốn xóa tác vụ tải xuống này?\nTệp của tác vụ cũng sẽ bị xóa.',
			'download.forceDeleteTask' => 'Buộc xóa tác vụ',
			'download.forceDeleteTaskConfirmation' => 'Bạn có chắc muốn buộc xóa tác vụ tải xuống này?\nTệp của tác vụ cũng sẽ bị xóa, kể cả khi tệp đang được sử dụng.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Đang tải ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Đang tải ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'Đã tạm dừng ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'Đã tạm dừng • Đã tải ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Đã tải xuống • ${size}',
			'download.copyDownloadUrlSuccess' => 'Đã sao chép URL tải xuống',
			'download.totalImageNums' => ({required Object num}) => '${num} ảnh',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Đang tải ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'Đang tải xuống',
			'download.failed' => 'Thất bại',
			'download.completed' => 'Đã hoàn thành',
			'download.downloadDetail' => 'Chi tiết tải xuống',
			'download.copy' => 'Sao chép',
			'download.copySuccess' => 'Đã sao chép',
			'download.waiting' => 'Đang chờ',
			'download.paused' => 'Đã tạm dừng',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Đang tải ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Tải thư viện hoàn tất: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Tải xuống hoàn tất: ${fileName}',
			'download.searchTasks' => 'Tìm kiếm tác vụ...',
			'download.statusLabel' => ({required Object label}) => 'Trạng thái: ${label}',
			'download.allStatus' => 'Mọi trạng thái',
			'download.typeLabel' => ({required Object label}) => 'Loại: ${label}',
			'download.allTypes' => 'Mọi loại',
			'download.taskType' => 'Loại',
			'download.video' => 'Video',
			'download.gallery' => 'Thư viện',
			'download.other' => 'Khác',
			'download.clearFilters' => 'Xóa bộ lọc',
			'download.pauseAll' => 'Tạm dừng tất cả',
			'download.resumeAll' => 'Bắt đầu tất cả',
			'download.remainingTime' => ({required Object time}) => 'còn ${time}',
			'download.timeline.today' => 'Hôm nay',
			'download.timeline.yesterday' => 'Hôm qua',
			'download.timeline.thisWeek' => 'Tuần này',
			'download.timeline.thisMonth' => 'Tháng này',
			'download.errorTypes.network' => 'Vấn đề mạng, thử lại có thể giúp ích',
			'download.errorTypes.serverRejected' => 'Bị máy chủ từ chối, có thể cần đăng nhập lại',
			'download.errorTypes.notFound' => 'Tài nguyên không còn tồn tại hoặc đã bị xóa',
			'download.errorTypes.diskFull' => 'Không đủ dung lượng lưu trữ',
			'download.errorTypes.fileInUse' => 'Tệp đang được chương trình khác sử dụng',
			'download.errorTypes.permission' => 'Không có quyền ghi',
			'download.errorTypes.cancelled' => 'Đã hủy',
			'download.errorTypes.unknown' => 'Lỗi không xác định',
			'download.errorDetailCopied' => 'Đã sao chép chi tiết lỗi',
			'download.errorDetailCopyHint' => 'Nhấn giữ để sao chép chi tiết lỗi',
			'download.restoredPaused.banner' => ({required Object num}) => '${num} tác vụ chưa hoàn thành từ phiên trước đã được tạm dừng',
			'download.restoredPaused.resume' => 'Tiếp tục tất cả',
			'download.restoredPaused.dismiss' => 'Bỏ qua',
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
			'download.emptyTaskList' => 'Chưa có tác vụ tải xuống',
			'download.noMatchingTasks' => 'Không có tác vụ nào khớp',
			'download.deleteByDate.menuTitle' => 'Xóa theo ngày',
			'download.deleteByDate.dialogTitle' => 'Xóa theo ngày',
			'download.deleteByDate.description' => 'Xóa hàng loạt tác vụ tải xuống theo ngày tạo. Các tác vụ có tệp đang được dùng sẽ bị bỏ qua; tác vụ có tệp không còn tồn tại sẽ được dọn dẹp.',
			'download.deleteByDate.modeRange' => 'Khoảng ngày',
			'download.deleteByDate.modeDays' => 'Cũ hơn',
			'download.deleteByDate.startDate' => 'Ngày bắt đầu',
			'download.deleteByDate.endDate' => 'Ngày kết thúc',
			'download.deleteByDate.notSet' => 'Chưa đặt',
			'download.deleteByDate.daysUnit' => 'ngày',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Xóa các tác vụ được tạo cách đây hơn ${days} ngày',
			'download.deleteByDate.noMatch' => 'Không có tác vụ nào khớp điều kiện đã chọn',
			'download.deleteByDate.invalidRange' => 'Ngày bắt đầu phải trước hoặc bằng ngày kết thúc',
			'download.deleteByDate.confirmTitle' => 'Xác nhận xóa',
			'download.deleteByDate.confirmContent' => ({required Object count}) => 'Xóa ${count} tác vụ tải xuống và tệp của chúng? Thao tác này không thể hoàn tác.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Đang xóa ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => 'Đã xóa ${count} tác vụ',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => 'Đã xóa ${deleted} tác vụ; bỏ qua ${skipped} (đang được dùng)',
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
			'download.category.manageTitle' => 'Quản lý danh mục',
			_ => null,
		} ?? switch (path) {
			'download.category.label' => 'Danh mục',
			'download.category.uncategorized' => 'Chưa phân loại',
			'download.category.manage' => 'Quản lý',
			'download.category.createShortcut' => 'Mới',
			'download.category.newCategoryHint' => 'Tên danh mục mới',
			'download.category.createSuccess' => 'Đã tạo danh mục',
			'download.category.createFailed' => 'Tạo danh mục thất bại',
			'download.category.nameEmpty' => 'Tên danh mục không được để trống',
			'download.category.emptyHint' => 'Chưa có danh mục nào. Hãy tạo một danh mục để sắp xếp các mục đã tải xuống.',
			'download.category.moveTo' => 'Chuyển vào danh mục',
			'download.category.moveToWithCount' => ({required Object count}) => 'Chuyển ${count} mục vào…',
			'download.category.moveSuccess' => ({required Object title}) => 'Đã chuyển vào ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Đã chuyển vào Chưa phân loại',
			'download.category.moveFailed' => 'Di chuyển thất bại',
			'download.category.renameTitle' => 'Đổi tên danh mục',
			'download.category.renameHint' => 'Nhập tên danh mục',
			'download.category.renameSuccess' => 'Đã đổi tên danh mục',
			'download.category.renameFailed' => 'Đổi tên danh mục thất bại',
			'download.category.deleteTitle' => 'Xóa danh mục',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'Xóa danh mục "${title}"? ${count} mục bên trong sẽ chuyển vào Chưa phân loại. Không có tệp nào bị xóa.',
			'download.category.deleteSuccess' => 'Đã xóa danh mục',
			'download.category.deleteFailed' => 'Xóa danh mục thất bại',
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
			'download.maxConcurrentDownloads' => 'Số tải xuống đồng thời tối đa',
			'download.maxConcurrentDownloadsDesc' => 'Số tác vụ tải xuống cùng lúc (1-5)',
			'download.stillInDevelopment' => 'Vẫn đang phát triển',
			'download.saveToAppDirectory' => 'Lưu vào thư mục ứng dụng',
			'download.alreadyDownloadedWithQuality' => 'Đã tải xuống với cùng chất lượng, tiếp tục tải?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Đã tải xuống với chất lượng: ${qualities}, tiếp tục tải?',
			'download.otherQualities' => 'Chất lượng khác',
			'download.batchDownload.title' => 'Tải hàng loạt',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Đang có tác vụ chạy, vui lòng đợi.',
			'download.batchDownload.userCancelled' => 'Người dùng đã hủy',
			'download.batchDownload.failedToGetVideoInfo' => 'Không lấy được thông tin video',
			'download.batchDownload.failedToGetVideoSource' => 'Không lấy được nguồn video',
			'download.batchDownload.failedToGetGalleryInfo' => 'Không lấy được thông tin thư viện',
			'download.batchDownload.galleryNoImages' => 'Thư viện không có ảnh',
			'download.batchDownload.failedToGetSavePath' => 'Không lấy được đường dẫn lưu',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Tải hàng loạt thất bại: ${exception}',
			'download.batchDownload.selectQuality' => 'Chọn chất lượng',
			'download.batchDownload.downloading' => 'Đang tải xuống',
			'download.batchDownload.downloadResult' => 'Kết quả tải xuống',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => 'Đã chọn ${count} video',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => 'Đã chọn ${count} thư viện',
			'download.batchDownload.qualityNote' => 'Nếu chất lượng đã chọn không khả dụng, chất lượng tốt nhất hiện có sẽ được dùng',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Đang xử lý ${current}/${total}',
			'download.batchDownload.queued' => 'Trong hàng đợi',
			'download.batchDownload.success' => 'Thành công',
			'download.batchDownload.skipped' => 'Đã bỏ qua',
			'download.batchDownload.failed' => 'Thất bại',
			'download.batchDownload.failureDetails' => 'Chi tiết lỗi',
			'download.batchDownload.reasonPrivateVideo' => 'Video riêng tư',
			'download.batchDownload.reasonAlreadyExists' => 'Đã tồn tại',
			'download.batchDownload.reasonNoSource' => 'Không có nguồn tải xuống',
			'download.batchDownload.reasonNoSavePath' => 'Không lấy được đường dẫn lưu',
			'download.batchDownload.reasonOther' => 'Lỗi khác',
			'download.batchDownload.startDownload' => 'Bắt đầu tải xuống',
			'downloadNotifications.completedTitle' => 'Tải xuống hoàn tất',
			'downloadNotifications.failedTitle' => 'Tải xuống thất bại',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} đã tải xuống thành công',
			'downloadNotifications.failedBody' => ({required Object name}) => '${name} tải xuống thất bại',
			'downloadNotifications.completedToast' => ({required Object name}) => 'Đã tải xuống ${name}',
			'downloadNotifications.failedToast' => ({required Object name}) => '${name} tải xuống thất bại',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Đã lưu vào ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Đã lưu thành ${name} (đã có tệp trùng tên)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Đã lưu vào thư mục ứng dụng — không thể ghi ${target} (${reason})',
			'downloadNotifications.viewFolder' => 'Xem thư mục',
			'downloadNotifications.fixInSettings' => 'Sửa trong Cài đặt',
			'downloadNotifications.channelName' => 'Trạng thái tải xuống',
			'downloadNotifications.channelDescription' => 'Thông báo cho các tải xuống đã hoàn thành và thất bại',
			'favorite.errors.addFailed' => 'Thêm thất bại',
			'favorite.errors.addSuccess' => 'Thêm thành công',
			'favorite.errors.deleteFolderFailed' => 'Xóa thư mục thất bại',
			'favorite.errors.deleteFolderSuccess' => 'Xóa thư mục thành công',
			'favorite.errors.folderNameCannotBeEmpty' => 'Tên thư mục không được để trống',
			'favorite.add' => 'Thêm',
			'favorite.addSuccess' => 'Thêm thành công',
			'favorite.addFailed' => 'Thêm thất bại',
			'favorite.remove' => 'Xóa',
			'favorite.removeSuccess' => 'Xóa thành công',
			'favorite.removeFailed' => 'Xóa thất bại',
			'favorite.removeConfirmation' => 'Bạn có chắc muốn xóa mục này khỏi yêu thích?',
			'favorite.removeConfirmationSuccess' => 'Đã xóa mục khỏi yêu thích',
			'favorite.removeConfirmationFailed' => 'Xóa mục khỏi yêu thích thất bại',
			'favorite.createFolderSuccess' => 'Đã tạo thư mục thành công',
			'favorite.createFolderFailed' => 'Tạo thư mục thất bại',
			'favorite.createFolder' => 'Tạo thư mục',
			'favorite.enterFolderName' => 'Nhập tên thư mục',
			'favorite.enterFolderNameHere' => 'Nhập tên thư mục tại đây...',
			'favorite.create' => 'Tạo',
			'favorite.items' => 'Mục',
			'favorite.newFolderName' => 'Thư mục mới',
			'favorite.searchFolders' => 'Tìm kiếm thư mục...',
			'favorite.searchItems' => 'Tìm kiếm mục...',
			'favorite.createdAt' => 'Ngày tạo',
			'favorite.myFavorites' => 'Yêu thích của tôi',
			'favorite.deleteFolderTitle' => 'Xóa thư mục',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Bạn có chắc muốn xóa thư mục ${title}?',
			'favorite.removeItemTitle' => 'Xóa mục',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Bạn có chắc muốn xóa mục ${title}?',
			'favorite.removeItemSuccess' => 'Đã xóa mục khỏi yêu thích',
			'favorite.removeItemFailed' => 'Xóa mục khỏi yêu thích thất bại',
			'favorite.localizeFavorite' => 'Yêu thích cục bộ',
			'favorite.editFolderTitle' => 'Chỉnh sửa thư mục',
			'favorite.editFolderSuccess' => 'Đã cập nhật thư mục thành công',
			'favorite.editFolderFailed' => 'Cập nhật thư mục thất bại',
			'favorite.searchTags' => 'Tìm kiếm thẻ',
			'favorite.noTagsInFolder' => 'Chưa có thẻ nào trên các mục trong thư mục này',
			'favorite.tagFilterMatchAll' => 'Chỉ hiện các mục có đủ mọi thẻ đã chọn',
			'favorite.clearSelectedTags' => 'Xóa thẻ đã chọn',
			'favorite.selectedTagCount' => ({required Object count}) => 'Đã chọn ${count}',
			'favorite.noMatchingTags' => 'Không có thẻ nào khớp',
			'translation.currentService' => 'Dịch vụ hiện tại',
			'translation.testConnection' => 'Kiểm tra kết nối',
			'translation.testConnectionSuccess' => 'Kiểm tra kết nối thành công',
			'translation.testConnectionFailed' => 'Kiểm tra kết nối thất bại',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Kiểm tra kết nối thất bại: ${message}',
			'translation.translation' => 'Dịch',
			'translation.needVerification' => 'Cần xác minh',
			'translation.needVerificationContent' => 'Vui lòng kiểm tra kết nối trước khi bật dịch bằng AI',
			'translation.confirm' => 'Xác nhận',
			'translation.disclaimer' => 'Miễn trừ trách nhiệm',
			'translation.riskWarning' => 'Cảnh báo rủi ro',
			'translation.dureToRisk1' => 'Do văn bản do người dùng tạo, có thể chứa nội dung vi phạm chính sách nội dung của nhà cung cấp dịch vụ AI',
			'translation.dureToRisk2' => 'Nội dung không phù hợp có thể dẫn đến việc khóa API key hoặc chấm dứt dịch vụ',
			'translation.operationSuggestion' => 'Gợi ý thao tác',
			'translation.operationSuggestion1' => '1. Dùng trước khi kiểm duyệt kỹ nội dung cần dịch',
			'translation.operationSuggestion2' => '2. Tránh dịch nội dung liên quan đến bạo lực, nội dung người lớn, v.v.',
			'translation.apiConfig' => 'Cấu hình API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Sửa cấu hình sẽ tự động tắt dịch bằng AI, cần kiểm tra lại sau khi bật',
			'translation.apiAddress' => 'Địa chỉ API',
			'translation.modelName' => 'Tên mô hình',
			'translation.modelNameHintText' => 'Ví dụ: gpt-4-turbo',
			'translation.maxTokens' => 'Số token tối đa',
			'translation.maxTokensHintText' => 'Ví dụ: 32000',
			'translation.temperature' => 'Nhiệt độ',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Nhấn nút kiểm tra để xác minh kết nối API có hợp lệ không',
			'translation.requestPreview' => 'Xem trước yêu cầu',
			'translation.enableAITranslation' => 'Bật AI',
			'translation.enabled' => 'Đã bật',
			'translation.disabled' => 'Đã tắt',
			'translation.testing' => 'Đang kiểm tra...',
			'translation.testNow' => 'Kiểm tra ngay',
			'translation.connectionStatus' => 'Trạng thái kết nối',
			'translation.success' => 'Thành công',
			'translation.failed' => 'Thất bại',
			'translation.information' => 'Thông tin',
			'translation.viewRawResponse' => 'Xem phản hồi thô',
			'translation.pleaseCheckInputParametersFormat' => 'Vui lòng kiểm tra định dạng tham số đầu vào',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Vui lòng điền địa chỉ API, tên mô hình và khóa',
			'translation.pleaseFillInValidConfigurationParameters' => 'Vui lòng điền các tham số cấu hình hợp lệ',
			'translation.pleaseCompleteConnectionTest' => 'Vui lòng hoàn tất kiểm tra kết nối',
			'translation.notConfigured' => 'Chưa cấu hình',
			'translation.apiEndpoint' => 'Điểm cuối API',
			'translation.configuredKey' => 'Khóa đã cấu hình',
			'translation.notConfiguredKey' => 'Khóa chưa cấu hình',
			'translation.authenticationStatus' => 'Trạng thái xác thực',
			'translation.thisFieldCannotBeEmpty' => 'Trường này không được để trống',
			'translation.apiKey' => 'Khóa API',
			'translation.apiKeyCannotBeEmpty' => 'Khóa API không được để trống',
			'translation.pleaseEnterValidNumber' => 'Vui lòng nhập số hợp lệ',
			'translation.range' => 'Khoảng',
			'translation.mustBeGreaterThan' => 'Phải lớn hơn',
			'translation.invalidAPIResponse' => 'Phản hồi API không hợp lệ',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Kết nối thất bại: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'Tính năng dịch bằng AI chưa được bật, vui lòng bật trong cài đặt',
			'translation.goToSettings' => 'Đi tới Cài đặt',
			'translation.disableAITranslation' => 'Tắt dịch bằng AI',
			'translation.currentValue' => 'Giá trị hiện tại',
			'translation.configureTranslationStrategy' => 'Cấu hình chiến lược dịch',
			'translation.advancedSettings' => 'Cài đặt nâng cao',
			'translation.translationPrompt' => 'Câu lệnh dịch',
			'translation.promptHint' => 'Vui lòng nhập câu lệnh dịch, dùng [TL] làm chỗ giữ chỗ cho ngôn ngữ đích',
			'translation.promptHelperText' => 'Câu lệnh phải chứa [TL] làm chỗ giữ chỗ cho ngôn ngữ đích',
			'translation.promptMustContainTargetLang' => 'Câu lệnh phải chứa chỗ giữ chỗ [TL]',
			'translation.aiTranslationWillBeDisabled' => 'Dịch bằng AI sẽ bị tắt',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Do thay đổi cấu hình cơ bản, dịch bằng AI sẽ bị tắt',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Do thay đổi câu lệnh dịch, dịch bằng AI sẽ bị tắt',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Do thay đổi cấu hình tham số, dịch bằng AI sẽ bị tắt',
			'translation.onlyOpenAIAPISupported' => 'Hiện chỉ hỗ trợ định dạng API tương thích OpenAI (phần thân yêu cầu application/json)',
			'translation.streamingTranslation' => 'Dịch theo luồng',
			'translation.streamingTranslationSupported' => 'Hỗ trợ dịch theo luồng',
			'translation.streamingTranslationNotSupported' => 'Không hỗ trợ dịch theo luồng',
			'translation.streamingTranslationDescription' => 'Dịch theo luồng có thể hiển thị kết quả theo thời gian thực trong quá trình dịch, mang lại trải nghiệm tốt hơn',
			'translation.usingFullUrlWithHash' => 'Đang dùng URL đầy đủ (kết thúc bằng #)',
			'translation.baseUrlInputHelperText' => 'Khi kết thúc bằng #, nó sẽ được dùng làm địa chỉ yêu cầu thực tế',
			'translation.currentActualUrl' => ({required Object url}) => 'URL thực tế hiện tại: ${url}',
			'translation.urlEndingWithHashTip' => 'URL kết thúc bằng # sẽ được dùng trực tiếp mà không thêm hậu tố nào',
			'translation.streamingTranslationWarning' => 'Lưu ý: Tính năng này yêu cầu dịch vụ API hỗ trợ truyền theo luồng, một số mô hình có thể không hỗ trợ',
			'translation.translationService' => 'Dịch vụ dịch',
			'translation.translationServiceDescription' => 'Chọn dịch vụ dịch bạn muốn dùng',
			'translation.googleTranslation' => 'Dịch Google',
			'translation.googleTranslationDescription' => 'Dịch vụ dịch trực tuyến miễn phí hỗ trợ nhiều ngôn ngữ',
			'translation.aiTranslation' => 'Dịch bằng AI',
			'translation.aiTranslationDescription' => 'Dịch vụ dịch thông minh dựa trên mô hình ngôn ngữ lớn',
			'translation.deeplxTranslation' => 'Dịch DeepLX',
			'translation.deeplxTranslationDescription' => 'Bản triển khai mã nguồn mở của DeepL, cung cấp bản dịch chất lượng cao',
			'translation.googleTranslationFeatures' => 'Tính năng',
			'translation.freeToUse' => 'Miễn phí sử dụng',
			'translation.freeToUseDescription' => 'Không cần cấu hình, dùng được ngay',
			'translation.fastResponse' => 'Phản hồi nhanh',
			'translation.fastResponseDescription' => 'Tốc độ dịch nhanh với độ trễ thấp',
			'translation.stableAndReliable' => 'Ổn định và đáng tin cậy',
			'translation.stableAndReliableDescription' => 'Dựa trên API chính thức của Google',
			'translation.enabledDefaultService' => 'Đã bật - Dịch vụ dịch mặc định',
			'translation.notEnabled' => 'Chưa bật',
			'translation.deeplxTranslationService' => 'Dịch vụ dịch DeepLX',
			'translation.deeplxDescription' => 'DeepLX là bản triển khai mã nguồn mở của DeepL, hỗ trợ các chế độ điểm cuối Free, Pro và Official',
			'translation.serverAddress' => 'Địa chỉ máy chủ',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Địa chỉ gốc của máy chủ DeepLX',
			'translation.endpointType' => 'Loại điểm cuối',
			'translation.freeEndpoint' => 'Free - Điểm cuối miễn phí, có thể bị giới hạn tốc độ',
			'translation.proEndpoint' => 'Pro - Cần dl_session, ổn định hơn',
			'translation.officialEndpoint' => 'Official - Định dạng API chính thức',
			'translation.finalRequestUrl' => 'URL yêu cầu cuối cùng',
			'translation.apiKeyOptional' => 'Khóa API (tùy chọn)',
			'translation.apiKeyOptionalHint' => 'Để truy cập các dịch vụ DeepLX được bảo vệ',
			'translation.apiKeyOptionalHelperText' => 'Một số dịch vụ DeepLX yêu cầu Khóa API để xác thực',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Tham số dl_session bắt buộc cho chế độ Pro',
			'translation.dlSessionHelperText' => 'Tham số session bắt buộc cho điểm cuối Pro, lấy từ tài khoản DeepL Pro',
			'translation.proModeRequiresDlSession' => 'Chế độ Pro cần dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Nhấn nút kiểm tra để xác minh kết nối API DeepLX',
			'translation.enableDeepLXTranslation' => 'Bật dịch DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'Dịch DeepLX sẽ bị tắt do thay đổi cấu hình',
			'translation.translatedResult' => 'Kết quả dịch',
			'translation.testSuccess' => 'Kiểm tra thành công',
			'translation.pleaseFillInDeepLXServerAddress' => 'Vui lòng điền địa chỉ máy chủ DeepLX',
			'translation.invalidAPIResponseFormat' => 'Định dạng phản hồi API không hợp lệ',
			'translation.translationServiceReturnedError' => 'Dịch vụ dịch trả về lỗi hoặc kết quả rỗng',
			'translation.connectionFailed' => 'Kết nối thất bại',
			'translation.translationFailed' => 'Dịch thất bại',
			'translation.aiTranslationFailed' => 'Dịch bằng AI thất bại',
			'translation.deeplxTranslationFailed' => 'Dịch DeepLX thất bại',
			'translation.aiTranslationTestFailed' => 'Kiểm tra dịch bằng AI thất bại',
			'translation.deeplxTranslationTestFailed' => 'Kiểm tra dịch DeepLX thất bại',
			'translation.streamingTranslationTimeout' => 'Dịch theo luồng quá thời gian, buộc dọn tài nguyên',
			'translation.translationRequestTimeout' => 'Yêu cầu dịch quá thời gian',
			'translation.streamingTranslationDataTimeout' => 'Hết thời gian nhận dữ liệu dịch theo luồng',
			'translation.dataReceptionTimeout' => 'Hết thời gian nhận dữ liệu',
			'translation.streamDataParseError' => 'Lỗi phân tích dữ liệu luồng',
			'translation.streamingTranslationFailed' => 'Dịch theo luồng thất bại',
			'translation.fallbackTranslationFailed' => 'Dịch dự phòng thông thường cũng thất bại',
			'translation.translationSettings' => 'Cài đặt dịch',
			'translation.enableGoogleTranslation' => 'Bật dịch Google',
			'translation.thinking' => 'Đang suy nghĩ...',
			'translation.thoughtProcess' => 'Quá trình suy nghĩ',
			'translation.modelCompatibility' => 'Tương thích mô hình',
			'translation.modelCompatibilityDescription' => 'Điều chỉnh tham số yêu cầu cho các mô hình hiện đại như mô hình suy luận (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'Mô hình suy luận',
			'translation.reasoningModelDescription' => 'Cho o1/o3, DeepSeek-R1, QwQ, v.v. Gộp câu lệnh vào tin nhắn người dùng, bỏ temperature và dùng max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'Dùng max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'Các điểm cuối OpenAI mới hơn yêu cầu max_completion_tokens thay cho max_tokens đã lỗi thời',
			'translation.sendTemperature' => 'Gửi temperature',
			'translation.sendTemperatureDescription' => 'Tắt cho các mô hình từ chối tham số temperature (hầu hết mô hình suy luận)',
			'translation.showReasoningProcess' => 'Hiển thị quá trình suy nghĩ',
			'translation.showReasoningProcessDescription' => 'Hiển thị phần suy luận có thể thu gọn của mô hình suy luận trong hộp thoại dịch',
			'translation.provider' => 'Nhà cung cấp',
			'translation.providerOpenAI' => 'OpenAI (và tương thích)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Hỗ trợ OpenAI (và mọi điểm cuối tương thích OpenAI), Anthropic và Google qua SDK dartantic_ai',
			'translation.baseUrlOptionalHelperText' => 'Tùy chọn. Để trống để dùng điểm cuối mặc định của nhà cung cấp; điền vào cho các điểm cuối tương thích OpenAI hoặc trung chuyển',
			'translation.defaultEndpoint' => 'Điểm cuối mặc định',
			'translation.providerPreset' => 'Đặt trước nhà cung cấp',
			'translation.selectProviderPreset' => 'Chọn một đặt trước',
			'translation.presetCustom' => 'Tùy chỉnh',
			'translation.presetApplied' => ({required Object name}) => 'Đã áp dụng đặt trước: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI Reasoning (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude Reasoning (suy luận mở rộng)',
			'translation.presetNames.gemini' => 'Google Gemini (gốc)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini Reasoning (suy nghĩ)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek Reasoning (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Tải danh sách mô hình',
			'translation.fetchingModels' => 'Đang tải...',
			'translation.selectModel' => 'Chọn mô hình',
			'translation.searchModel' => 'Tìm kiếm mô hình',
			'translation.noModelsFound' => 'Không tìm thấy mô hình nào',
			'bottomNav.video' => 'Video',
			'bottomNav.gallery' => 'Ảnh',
			'bottomNav.subscription' => 'Feed',
			'bottomNav.community' => 'Forum',
			'bottomNav.localMedia' => 'Cục bộ',
			'navigationOrderSettings.title' => 'Cài đặt thứ tự điều hướng',
			'navigationOrderSettings.customNavigationOrder' => 'Thứ tự điều hướng tùy chỉnh',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Kéo để điều chỉnh thứ tự hiển thị của các trang trong thanh điều hướng dưới và thanh bên',
			'navigationOrderSettings.restartRequired' => 'Cần khởi động lại ứng dụng',
			'navigationOrderSettings.navigationItemSorting' => 'Sắp xếp mục điều hướng',
			'navigationOrderSettings.done' => 'Xong',
			'navigationOrderSettings.edit' => 'Chỉnh sửa',
			'navigationOrderSettings.reset' => 'Đặt lại',
			'navigationOrderSettings.previewEffect' => 'Xem trước hiệu ứng',
			'navigationOrderSettings.bottomNavigationPreview' => 'Xem trước thanh điều hướng dưới:',
			'navigationOrderSettings.sidebarPreview' => 'Xem trước thanh bên:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Xác nhận đặt lại thứ tự điều hướng',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Bạn có chắc muốn đặt lại thứ tự điều hướng về mặc định?',
			'navigationOrderSettings.cancel' => 'Hủy',
			'navigationOrderSettings.show' => 'Hiện',
			'navigationOrderSettings.hide' => 'Ẩn',
			'navigationOrderSettings.hidden' => 'Đã ẩn',
			'navigationOrderSettings.hideHint' => 'Nhấn biểu tượng con mắt để hiện hoặc ẩn Cộng đồng và tệp cục bộ',
			'navigationOrderSettings.videoDescription' => 'Duyệt nội dung video phổ biến',
			'navigationOrderSettings.galleryDescription' => 'Duyệt ảnh và thư viện',
			'navigationOrderSettings.subscriptionDescription' => 'Xem nội dung mới nhất từ những người bạn theo dõi',
			'navigationOrderSettings.forumDescription' => 'Tham gia thảo luận cộng đồng',
			'navigationOrderSettings.newsDescription' => 'Duyệt tin tức, bài viết và phát sóng chính thức',
			'navigationOrderSettings.communityDescription' => 'Thảo luận diễn đàn cùng tin tức, bài viết và phát sóng chính thức',
			'navigationOrderSettings.localMediaDescription' => 'Duyệt video và ảnh lưu trên thiết bị này',
			'news.title' => 'Tin tức',
			'news.newsUpdates' => 'Cập nhật tin tức',
			'news.articles' => 'Bài viết',
			'news.broadcast' => 'Phát sóng',
			'news.openInBrowser' => 'Mở trong trình duyệt',
			'displaySettings.title' => 'Cài đặt hiển thị',
			'displaySettings.layoutSettings' => 'Cài đặt bố cục',
			'displaySettings.layoutSettingsDesc' => 'Tùy chỉnh số cột và cấu hình điểm ngắt',
			'displaySettings.gridLayout' => 'Bố cục lưới',
			'displaySettings.navigationOrderSettings' => 'Cài đặt thứ tự điều hướng',
			'displaySettings.customNavigationOrder' => 'Thứ tự điều hướng tùy chỉnh',
			'displaySettings.customNavigationOrderDesc' => 'Điều chỉnh thứ tự hiển thị của các trang trong thanh điều hướng dưới và thanh bên',
			'layoutSettings.title' => 'Cài đặt bố cục',
			'layoutSettings.descriptionTitle' => 'Mô tả cấu hình bố cục',
			'layoutSettings.descriptionContent' => 'Cấu hình tại đây quyết định số cột hiển thị trong trang danh sách video và thư viện. Có thể chọn chế độ tự động để hệ thống tự điều chỉnh theo chiều rộng màn hình, hoặc chọn chế độ thủ công để cố định số cột.',
			'layoutSettings.layoutMode' => 'Chế độ bố cục',
			'layoutSettings.reset' => 'Đặt lại',
			'layoutSettings.autoMode' => 'Chế độ tự động',
			'layoutSettings.autoModeDesc' => 'Tự động điều chỉnh theo chiều rộng màn hình',
			'layoutSettings.manualMode' => 'Chế độ thủ công',
			'layoutSettings.manualModeDesc' => 'Dùng số cột cố định',
			'layoutSettings.manualSettings' => 'Cài đặt thủ công',
			'layoutSettings.fixedColumns' => 'Số cột cố định',
			'layoutSettings.columns' => 'cột',
			'layoutSettings.breakpointConfig' => 'Cấu hình điểm ngắt',
			'layoutSettings.add' => 'Thêm',
			'layoutSettings.defaultColumns' => 'Số cột mặc định',
			'layoutSettings.defaultColumnsDesc' => 'Hiển thị mặc định cho màn hình lớn',
			'layoutSettings.previewEffect' => 'Xem trước hiệu ứng',
			'layoutSettings.screenWidth' => 'Chiều rộng màn hình',
			'layoutSettings.addBreakpoint' => 'Thêm điểm ngắt',
			'layoutSettings.editBreakpoint' => 'Chỉnh sửa điểm ngắt',
			'layoutSettings.deleteBreakpoint' => 'Xóa điểm ngắt',
			'layoutSettings.screenWidthLabel' => 'Chiều rộng màn hình',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Số cột',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Vui lòng nhập chiều rộng',
			'layoutSettings.enterValidWidth' => 'Vui lòng nhập chiều rộng hợp lệ',
			'layoutSettings.widthCannotExceed9999' => 'Chiều rộng không được vượt quá 9999',
			'layoutSettings.breakpointAlreadyExists' => 'Điểm ngắt đã tồn tại',
			'layoutSettings.enterColumns' => 'Vui lòng nhập số cột',
			'layoutSettings.enterValidColumns' => 'Vui lòng nhập số cột hợp lệ',
			'layoutSettings.columnsCannotExceed12' => 'Số cột không được vượt quá 12',
			'layoutSettings.breakpointConflict' => 'Điểm ngắt đã tồn tại',
			'layoutSettings.confirmResetLayoutSettings' => 'Đặt lại cài đặt bố cục',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Bạn có chắc muốn đặt lại toàn bộ cài đặt bố cục về giá trị mặc định?\n\nSẽ khôi phục về:\n• Chế độ tự động\n• Cấu hình điểm ngắt mặc định',
			'layoutSettings.resetToDefaults' => 'Đặt lại về mặc định',
			'layoutSettings.confirmDeleteBreakpoint' => 'Xóa điểm ngắt',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Bạn có chắc muốn xóa điểm ngắt ${width}px?',
			'layoutSettings.noCustomBreakpoints' => 'Không có điểm ngắt tùy chỉnh, đang dùng số cột mặc định',
			'layoutSettings.breakpointRange' => 'Phạm vi điểm ngắt',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Chỉnh sửa',
			'layoutSettings.delete' => 'Xóa',
			'layoutSettings.cancel' => 'Hủy',
			'layoutSettings.save' => 'Lưu',
			'mediaPlayer.videoPlayerError' => 'Lỗi trình phát video',
			'mediaPlayer.videoLoadFailed' => 'Tải video thất bại',
			'mediaPlayer.videoCodecNotSupported' => 'Không hỗ trợ codec video',
			'mediaPlayer.networkConnectionIssue' => 'Vấn đề kết nối mạng',
			'mediaPlayer.insufficientPermission' => 'Quyền không đủ',
			'mediaPlayer.unsupportedVideoFormat' => 'Định dạng video không được hỗ trợ',
			'mediaPlayer.retry' => 'Thử lại',
			'mediaPlayer.externalPlayer' => 'Trình phát ngoài',
			'mediaPlayer.detailedErrorInfo' => 'Thông tin lỗi chi tiết',
			'mediaPlayer.format' => 'Định dạng',
			'mediaPlayer.suggestion' => 'Gợi ý',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Thiết bị Android hỗ trợ hạn chế định dạng WEBM. Nên dùng trình phát ngoài hoặc tải ứng dụng trình phát hỗ trợ WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'Thiết bị hiện tại không hỗ trợ codec cho định dạng video này',
			'mediaPlayer.checkNetworkConnection' => 'Vui lòng kiểm tra kết nối mạng và thử lại',
			'mediaPlayer.appMayLackMediaPermission' => 'Ứng dụng có thể thiếu quyền phát media cần thiết',
			'mediaPlayer.tryOtherVideoPlayer' => 'Vui lòng thử dùng trình phát video khác',
			'mediaPlayer.unrecognizedVideoFormat' => 'Tệp video không nhận dạng được',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Liên kết có thể đã hết hạn, hoặc phản hồi không phải video. Hãy thử lại, hoặc mở bằng ứng dụng khác.',
			'mediaPlayer.accessDenied' => 'Máy chủ từ chối yêu cầu này (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Liên kết phát nhiều khả năng đã hết hạn. Nhấn Thử lại để lấy lại, hoặc mở bằng ứng dụng khác.',
			'mediaPlayer.mute' => 'Tắt tiếng',
			'mediaPlayer.unmute' => 'Bật tiếng',
			'mediaPlayer.video' => 'VIDEO',
			'mediaPlayer.serverSelector' => 'Chọn máy chủ CDN',
			'mediaPlayer.serverSelectorDescription' => 'Chọn máy chủ có độ trễ thấp nhất để có trải nghiệm phát tốt nhất',
			'mediaPlayer.retestSpeed' => 'Đo lại tốc độ',
			'mediaPlayer.waitingForSpeedTest' => 'Đang chờ đo tốc độ',
			'mediaPlayer.testingSpeed' => 'Đang đo tốc độ...',
			'mediaPlayer.testFailed' => 'Đo thất bại',
			'mediaPlayer.loadingServerList' => 'Đang tải danh sách máy chủ...',
			'mediaPlayer.noAvailableServers' => 'Không có máy chủ khả dụng',
			'mediaPlayer.refreshServerList' => 'Làm mới danh sách máy chủ',
			'mediaPlayer.cannotGetSource' => 'Không lấy được nguồn video hiện tại',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Đã chuyển sang máy chủ: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'Tổng ${count} máy chủ',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Mã trạng thái: ${code}',
			'mediaPlayer.connectionFailed' => 'Kết nối thất bại',
			'mediaPlayer.connectionTimeout' => 'Kết nối quá thời gian',
			'mediaPlayer.networkError' => 'Lỗi mạng',
			'mediaPlayer.sslError' => 'Lỗi chứng chỉ SSL',
			'mediaPlayer.testCompleted' => 'Đã đo xong',
			'mediaPlayer.local' => 'Cục bộ',
			'mediaPlayer.unknown' => 'Không xác định',
			'mediaPlayer.localVideoPathEmpty' => 'Đường dẫn video cục bộ trống',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Tệp video cục bộ không tồn tại: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Không thể phát video cục bộ: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Kéo tệp video vào đây để phát',
			'mediaPlayer.supportedFormats' => 'Định dạng được hỗ trợ: MP4, MKV, AVI, MOV, WEBM, v.v.',
			'mediaPlayer.noSupportedVideoFile' => 'Không tìm thấy tệp video được hỗ trợ',
			'mediaPlayer.retryingOpenVideoLink' => 'Mở liên kết video thất bại, đang thử lại',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Không thể tải bộ giải mã: ${event}. Hãy thử chuyển sang giải mã phần mềm trong cài đặt trình phát rồi vào lại trang',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Lỗi tải video: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Phát hiện lỗi phát lặp lại. Vào Cài đặt > Chẩn đoán & Phản hồi để xuất nhật ký.',
			'mediaPlayer.openSettingsAction' => 'Xem',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Thông báo phát: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Kiểm tra mạng; phát có thể bị giật',
			'mediaPlayer.notice.audioTrackUnavailable' => 'Không có âm thanh; video vẫn tiếp tục phát',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Đã chuyển sang giải mã phần mềm; có thể tốn pin hơn',
			'mediaPlayer.notice.videoDecodeProblem' => 'Hãy thử chất lượng khác; hình ảnh có thể bị lỗi',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Xuất nhật ký để báo cáo các vấn đề phát lặp lại',
			'mediaPlayer.notice.issuesSheetTitle' => 'Vấn đề khi phát',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'Đã xảy ra ${count} lần',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'Tại ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'Không ghi nhận vấn đề nào',
			'mediaPlayer.notice.exportLogsAction' => 'Xuất nhật ký',
			_ => null,
		} ?? switch (path) {
			'mediaPlayer.imageLoadFailed' => 'Tải ảnh thất bại',
			'mediaPlayer.unsupportedImageFormat' => 'Định dạng ảnh không được hỗ trợ',
			'mediaPlayer.tryOtherViewer' => 'Vui lòng thử dùng trình xem khác',
			'diagnostics.infoSectionTitle' => 'Thông tin chẩn đoán',
			'diagnostics.appVersionLabel' => 'Phiên bản ứng dụng',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Mức dùng bộ nhớ: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'Không thể lấy thông tin thiết bị',
			'diagnostics.secureStorageLabel' => 'Lưu trữ an toàn',
			'diagnostics.secureStorageHealthy' => 'Khả dụng',
			'diagnostics.secureStorageRecovered' => 'Tự phục hồi bằng cách đặt lại (đã xóa dữ liệu trước đó)',
			'diagnostics.secureStorageUnavailable' => 'Không khả dụng (đăng nhập được lưu bằng mã hóa dự phòng)',
			'diagnostics.secureStoragePlatformOptOut' => 'Mã hóa cục bộ theo chính sách nền tảng (macOS không dùng chuỗi khóa hệ thống)',
			'diagnostics.secureStorageDualWrite' => ' (bật bảo vệ ghi kép)',
			'diagnostics.schemaHealthLabel' => 'Lược đồ cơ sở dữ liệu',
			'diagnostics.schemaHealthOk' => 'OK',
			'diagnostics.schemaHealthRepairedNow' => 'Được lưới an toàn sửa chữa trong lần khởi chạy này (di trú chưa có hiệu lực)',
			'diagnostics.schemaHealthRepairedBefore' => 'Trước đây đã được lưới an toàn sửa chữa',
			'diagnostics.logPolicySectionTitle' => 'Chính sách nhật ký',
			'diagnostics.configServiceUnavailable' => 'Dịch vụ cấu hình chưa được khởi tạo. Không thể điều chỉnh chính sách nhật ký.',
			'diagnostics.enableLoggingTitle' => 'Bật ghi nhật ký',
			'diagnostics.enableLoggingSubtitle' => 'Tắt để ngừng ghi nhật ký mới',
			'diagnostics.enableLogPersistenceTitle' => 'Bật lưu nhật ký lâu dài',
			'diagnostics.enableLogPersistenceSubtitle' => 'Tắt để chỉ giữ nhật ký trong bộ nhớ và ngừng ghi ra đĩa',
			'diagnostics.minLogLevelTitle' => 'Cấp nhật ký tối thiểu',
			'diagnostics.minLogLevelSubtitle' => 'Nhật ký dưới mức này sẽ bị lọc bỏ',
			'diagnostics.maxFileSizeTitle' => 'Giới hạn kích thước một tệp',
			'diagnostics.maxFileSizeSubtitle' => 'Xoay vòng khi đạt ngưỡng',
			'diagnostics.rotatedFileCountTitle' => 'Số tệp xoay vòng nhật ký chính',
			'diagnostics.rotatedFileCountSubtitle' => 'Số tệp được giữ lại, không tính tệp hiện tại',
			'diagnostics.hangFileSizeTitle' => 'Giới hạn kích thước nhật ký treo',
			'diagnostics.hangFileSizeSubtitle' => 'Kiểm soát mức tăng của tệp hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'Số tệp xoay vòng nhật ký treo',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Kiểm soát lịch sử lưu giữ cho hang_events',
			'diagnostics.healthSectionTitle' => 'Sức khỏe nhật ký',
			'diagnostics.refreshMetrics' => 'Làm mới chỉ số',
			'diagnostics.toolsSectionTitle' => 'Công cụ',
			'diagnostics.privacyNotice' => 'Nhật ký có thể chứa thông tin nhạy cảm như dữ liệu tài khoản và tham số yêu cầu. Không đăng toàn bộ nhật ký công khai trong issue; hãy xem lại trước và gửi qua email.',
			'diagnostics.exportLogsTitle' => 'Xuất nhật ký',
			'diagnostics.exportLogsSubtitle' => 'Xem lại dữ liệu riêng tư trước khi gửi cho nhà phát triển',
			'diagnostics.viewLogsTitle' => 'Xem nhật ký',
			'diagnostics.viewLogsSubtitle' => 'Xem nhật ký chạy theo thời gian thực',
			'diagnostics.copySupportEmailTitle' => 'Sao chép email hỗ trợ',
			'diagnostics.reportIssueTitle' => 'Báo lỗi',
			'diagnostics.reportIssueSubtitle' => 'Cung cấp các bước tái hiện trên GitHub (không đính kèm toàn bộ nhật ký)',
			'diagnostics.healthSummaryUnavailable' => 'Chưa có dữ liệu sức khỏe nhật ký',
			'diagnostics.healthMetricsUnavailable' => 'Chưa thu thập chỉ số sức khỏe',
			'diagnostics.healthNoRiskIndicators' => 'Không phát hiện chỉ báo rủi ro',
			'diagnostics.healthAlert.flushFailureTitle' => 'Lỗi ghi đệm',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Ghi nhật ký bị suy giảm',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'Bộ ghi tệp đang ở trạng thái suy giảm',
			'diagnostics.healthAlert.queueBacklogTitle' => 'Hàng đợi ghi bị tồn đọng',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (ngưỡng=${threshold}, có thể làm tăng mức dùng bộ nhớ)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Độ trễ ghi đệm cao',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Quá nhiều nhật ký bị bỏ',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (ngưỡng=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Đã kích hoạt giới hạn tần suất',
			'diagnostics.healthAlert.exportFailedTitle' => 'Lỗi xuất nhật ký',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'Tệp nhật ký gần đạt giới hạn kích thước',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (áp lực xoay vòng IO cao hơn)',
			'diagnostics.toast.logServiceNotInitialized' => 'Dịch vụ nhật ký chưa được khởi tạo',
			'diagnostics.toast.exportSuccess' => 'Đã xuất nhật ký. Vui lòng xem lại dữ liệu riêng tư trước khi gửi qua email.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'Xuất thất bại: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'Đã sao chép email hỗ trợ. Dán vào ứng dụng thư và đính kèm nhật ký.',
			'diagnostics.shareSubject' => 'Nhật ký chẩn đoán LoveIwara (chứa dữ liệu nhạy cảm, chia sẻ cẩn trọng)',
			'logViewer.title' => 'Trình xem nhật ký',
			'logViewer.searchHint' => 'Tìm kiếm nhật ký...',
			'logViewer.emptyState' => 'Không có nhật ký',
			'logViewer.copiedToClipboard' => 'Đã sao chép vào clipboard',
			'crashRecoveryDialog.title' => 'Ứng dụng đã thoát bất ngờ',
			'crashRecoveryDialog.description' => 'Chúng tôi phát hiện phiên trước đã thoát không bình thường. Vui lòng xuất nhật ký chẩn đoán và gửi email cho nhà phát triển để giúp khắc phục sự cố.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Phiên bản trước: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Lần khởi chạy trước: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Ngoại lệ gần nhất: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'Lần trước phát hiện giao diện bị treo và đã tự động khôi phục',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'Lần trước phát hiện giao diện có thể bị đơ, kéo dài khoảng ${stalledMs}ms',
			'crashRecoveryDialog.exportGuide' => 'Vào Cài đặt > Chẩn đoán & Phản hồi > Xuất nhật ký.',
			'crashRecoveryDialog.privacyHint' => 'Nhật ký có thể chứa dữ liệu riêng tư. Vui lòng xem lại trước khi gửi email tới:',
			'crashRecoveryDialog.issueWarning' => 'Không đính kèm toàn bộ nhật ký công khai trong issue trên GitHub',
			'crashRecoveryDialog.acknowledge' => 'Đã hiểu',
			'crashRecoveryDialog.supportEmailCopied' => 'Đã sao chép email',
			'linkInputDialog.title' => 'Nhập liên kết',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Hỗ trợ nhận diện thông minh nhiều liên kết ${webName} và nhanh chóng chuyển tới trang tương ứng trong ứng dụng (phân tách liên kết với văn bản khác bằng dấu cách)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Vui lòng nhập liên kết ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'Vui lòng nhập liên kết',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'Không phát hiện liên kết ${webName} hợp lệ',
			'linkInputDialog.multipleLinksDetected' => 'Phát hiện nhiều liên kết, vui lòng chọn một:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Không phải liên kết ${webName} hợp lệ',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Lỗi phân tích liên kết: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Liên kết không được hỗ trợ',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Loại liên kết này không thể mở trực tiếp trong ứng dụng và cần truy cập bằng trình duyệt bên ngoài.\n\nBạn có muốn mở liên kết này trong trình duyệt không?',
			'linkInputDialog.openInBrowser' => 'Mở trong trình duyệt',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Xác nhận mở trình duyệt',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'Liên kết sau sắp được mở trong trình duyệt bên ngoài:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Bạn có chắc muốn tiếp tục?',
			'linkInputDialog.browserOpenFailed' => 'Mở liên kết thất bại',
			'linkInputDialog.unsupportedLink' => 'Liên kết không được hỗ trợ',
			'linkInputDialog.cancel' => 'Hủy',
			'linkInputDialog.confirm' => 'Mở trong trình duyệt',
			'log.logManagement' => 'Quản lý nhật ký',
			'log.enableLogPersistence' => 'Bật lưu nhật ký lâu dài',
			'log.enableLogPersistenceDesc' => 'Lưu nhật ký vào cơ sở dữ liệu để phân tích',
			'log.logDatabaseSizeLimit' => 'Giới hạn kích thước cơ sở dữ liệu nhật ký',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Hiện tại: ${size}',
			'log.exportCurrentLogs' => 'Xuất nhật ký hiện tại',
			'log.exportCurrentLogsDesc' => 'Xuất nhật ký ứng dụng hiện tại để giúp nhà phát triển chẩn đoán vấn đề',
			'log.exportHistoryLogs' => 'Xuất nhật ký lịch sử',
			'log.exportHistoryLogsDesc' => 'Xuất nhật ký trong khoảng ngày được chỉ định',
			'log.exportMergedLogs' => 'Xuất nhật ký hợp nhất',
			'log.exportMergedLogsDesc' => 'Xuất nhật ký hợp nhất trong khoảng ngày được chỉ định',
			'log.showLogStats' => 'Hiện thống kê nhật ký',
			'log.logExportSuccess' => 'Xuất nhật ký thành công',
			'log.logExportFailed' => ({required Object error}) => 'Xuất nhật ký thất bại: ${error}',
			'log.showLogStatsDesc' => 'Xem thống kê các loại nhật ký khác nhau',
			'log.logExtractFailed' => ({required Object error}) => 'Lấy thống kê nhật ký thất bại: ${error}',
			'log.clearAllLogs' => 'Xóa toàn bộ nhật ký',
			'log.clearAllLogsDesc' => 'Xóa toàn bộ dữ liệu nhật ký',
			'log.confirmClearAllLogs' => 'Xác nhận xóa',
			'log.confirmClearAllLogsDesc' => 'Bạn có chắc muốn xóa toàn bộ dữ liệu nhật ký? Thao tác này không thể hoàn tác.',
			'log.clearAllLogsSuccess' => 'Đã xóa nhật ký thành công',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Xóa nhật ký thất bại: ${error}',
			'log.unableToGetLogSizeInfo' => 'Không thể lấy thông tin kích thước nhật ký',
			'log.currentLogSize' => 'Kích thước nhật ký hiện tại:',
			'log.logCount' => 'Số nhật ký:',
			'log.logCountUnit' => 'nhật ký',
			'log.logSizeLimit' => 'Giới hạn kích thước nhật ký:',
			'log.usageRate' => 'Tỉ lệ sử dụng:',
			'log.exceedLimit' => 'Vượt hạn mức',
			'log.remaining' => 'Còn lại',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Kích thước nhật ký hiện tại đã vượt hạn mức, vui lòng dọn nhật ký cũ hoặc tăng giới hạn kích thước nhật ký',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'Kích thước nhật ký hiện tại gần vượt hạn mức, vui lòng dọn nhật ký cũ',
			'log.cleaningOldLogs' => 'Đang dọn nhật ký cũ...',
			'log.logCleaningCompleted' => 'Đã dọn nhật ký xong',
			'log.logCleaningProcessMayNotBeCompleted' => 'Quá trình dọn nhật ký có thể chưa hoàn tất',
			'log.cleanExceededLogs' => 'Dọn nhật ký vượt hạn mức',
			'log.noLogsToExport' => 'Không có nhật ký để xuất',
			'log.exportingLogs' => 'Đang xuất nhật ký...',
			'log.noHistoryLogsToExport' => 'Không có nhật ký lịch sử để xuất, vui lòng dùng ứng dụng một lúc trước',
			'log.selectLogDate' => 'Chọn ngày nhật ký',
			'log.today' => 'Hôm nay',
			'log.selectMergeRange' => 'Chọn khoảng hợp nhất',
			'log.selectMergeRangeHint' => 'Vui lòng chọn khoảng thời gian nhật ký cần hợp nhất',
			'log.selectMergeRangeDays' => ({required Object days}) => '${days} ngày gần đây',
			'log.logStats' => 'Thống kê nhật ký',
			'log.todayLogs' => ({required Object count}) => 'Nhật ký hôm nay: ${count} nhật ký',
			'log.recent7DaysLogs' => ({required Object count}) => 'Nhật ký 7 ngày gần đây: ${count} nhật ký',
			'log.totalLogs' => ({required Object count}) => 'Tổng nhật ký: ${count} nhật ký',
			'log.setLogDatabaseSizeLimit' => 'Đặt giới hạn kích thước cơ sở dữ liệu nhật ký',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Kích thước nhật ký hiện tại: ${size}',
			'log.warning' => 'Cảnh báo',
			'log.newSizeLimit' => ({required Object size}) => 'Giới hạn kích thước mới: ${size}',
			'log.confirmToContinue' => 'Xác nhận để tiếp tục',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Đã đặt giới hạn kích thước nhật ký thành ${size}',
			'emoji.recentlyUsed' => 'Gần đây',
			'emoji.insertedCount' => ({required Object count}) => 'Đã chèn ${count}',
			'emoji.name' => 'Biểu tượng cảm xúc',
			'emoji.size' => 'Kích thước',
			'emoji.small' => 'Nhỏ',
			'emoji.medium' => 'Vừa',
			'emoji.large' => 'Lớn',
			'emoji.extraLarge' => 'Rất lớn',
			'emoji.copyEmojiLinkSuccess' => 'Đã sao chép liên kết biểu tượng cảm xúc',
			'emoji.preview' => 'Xem trước biểu tượng cảm xúc',
			'emoji.library' => 'Thư viện biểu tượng cảm xúc',
			'emoji.noEmojis' => 'Không có biểu tượng cảm xúc',
			'emoji.clickToAddEmojis' => 'Nhấn nút ở góc trên bên phải để thêm biểu tượng cảm xúc',
			'emoji.addEmojis' => 'Thêm biểu tượng cảm xúc',
			'emoji.imagePreview' => 'Xem trước ảnh',
			'emoji.imageLoadFailed' => 'Tải ảnh thất bại',
			'emoji.loading' => 'Đang tải...',
			'emoji.delete' => 'Xóa',
			'emoji.close' => 'Đóng',
			'emoji.deleteImage' => 'Xóa ảnh',
			'emoji.confirmDeleteImage' => 'Bạn có chắc muốn xóa ảnh này?',
			'emoji.cancel' => 'Hủy',
			'emoji.batchDelete' => 'Xóa hàng loạt',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Bạn có chắc muốn xóa ${count} ảnh đã chọn? Thao tác này không thể hoàn tác.',
			'emoji.deleteSuccess' => 'Đã xóa thành công',
			'emoji.addImage' => 'Thêm ảnh',
			'emoji.addImageByUrl' => 'Thêm bằng URL',
			'emoji.addImageUrl' => 'Thêm URL ảnh',
			'emoji.imageUrl' => 'URL ảnh',
			'emoji.enterImageUrl' => 'Vui lòng nhập URL ảnh',
			'emoji.add' => 'Thêm',
			'emoji.batchImport' => 'Nhập hàng loạt',
			'emoji.enterJsonUrlArray' => 'Vui lòng nhập mảng URL định dạng JSON:',
			'emoji.formatExample' => 'Ví dụ định dạng:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Vui lòng dán mảng URL định dạng JSON',
			'emoji.import' => 'Nhập',
			'emoji.importSuccess' => ({required Object count}) => 'Đã nhập thành công ${count} ảnh',
			'emoji.jsonFormatError' => 'Lỗi định dạng JSON, vui lòng kiểm tra nội dung nhập',
			'emoji.createGroup' => 'Tạo nhóm biểu tượng cảm xúc',
			'emoji.groupName' => 'Tên nhóm',
			'emoji.enterGroupName' => 'Vui lòng nhập tên nhóm',
			'emoji.create' => 'Tạo',
			'emoji.editGroupName' => 'Chỉnh sửa tên nhóm',
			'emoji.save' => 'Lưu',
			'emoji.deleteGroup' => 'Xóa nhóm',
			'emoji.confirmDeleteGroup' => 'Bạn có chắc muốn xóa nhóm biểu tượng cảm xúc này? Tất cả ảnh trong nhóm cũng sẽ bị xóa.',
			'emoji.imageCount' => ({required Object count}) => '${count} ảnh',
			'emoji.selectEmoji' => 'Chọn biểu tượng cảm xúc',
			'emoji.noEmojisInGroup' => 'Không có biểu tượng cảm xúc trong nhóm này',
			'emoji.goToSettingsToAddEmojis' => 'Vào cài đặt để thêm biểu tượng cảm xúc',
			'emoji.emojiManagement' => 'Quản lý biểu tượng cảm xúc',
			'emoji.manageEmojiGroupsAndImages' => 'Quản lý nhóm và ảnh biểu tượng cảm xúc',
			'emoji.uploadLocalImages' => 'Tải ảnh cục bộ lên',
			'emoji.uploadingImages' => 'Đang tải ảnh lên',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Đang tải lên ${count} ảnh, vui lòng đợi...',
			'emoji.doNotCloseDialog' => 'Vui lòng không đóng hộp thoại này',
			'emoji.uploadSuccess' => ({required Object count}) => 'Đã tải lên thành công ${count} ảnh',
			'emoji.uploadFailed' => ({required Object count}) => 'Thất bại ${count}',
			'emoji.uploadFailedMessage' => 'Tải ảnh lên thất bại, vui lòng kiểm tra kết nối mạng hoặc định dạng tệp',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Đã xảy ra lỗi trong khi tải lên: ${error}',
			'searchFilter.selectField' => 'Chọn trường',
			'searchFilter.add' => 'Thêm',
			'searchFilter.clear' => 'Xóa',
			'searchFilter.clearAll' => 'Xóa tất cả',
			'searchFilter.generatedQuery' => 'Truy vấn đã tạo',
			'searchFilter.copyToClipboard' => 'Sao chép vào bộ nhớ tạm',
			'searchFilter.copied' => 'Đã sao chép',
			'searchFilter.filterCount' => ({required Object count}) => '${count} bộ lọc',
			'searchFilter.filterSettings' => 'Cài đặt bộ lọc',
			'searchFilter.field' => 'Trường',
			'searchFilter.operator' => 'Toán tử',
			'searchFilter.language' => 'Ngôn ngữ',
			'searchFilter.value' => 'Giá trị',
			'searchFilter.dateRange' => 'Khoảng ngày',
			'searchFilter.numberRange' => 'Khoảng số',
			'searchFilter.from' => 'Từ',
			'searchFilter.to' => 'Đến',
			'searchFilter.date' => 'Ngày',
			'searchFilter.number' => 'Số',
			'searchFilter.boolean' => 'Boolean',
			'searchFilter.tags' => 'Thẻ',
			'searchFilter.select' => 'Chọn',
			'searchFilter.clickToSelectDate' => 'Nhấn để chọn ngày',
			'searchFilter.pleaseEnterValidNumber' => 'Vui lòng nhập số hợp lệ',
			'searchFilter.pleaseEnterValidDate' => 'Vui lòng nhập định dạng ngày hợp lệ (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'Giá trị bắt đầu phải nhỏ hơn giá trị kết thúc',
			'searchFilter.startDateMustBeBeforeEndDate' => 'Ngày bắt đầu phải trước ngày kết thúc',
			'searchFilter.pleaseFillStartValue' => 'Vui lòng nhập giá trị bắt đầu',
			'searchFilter.pleaseFillEndValue' => 'Vui lòng nhập giá trị kết thúc',
			'searchFilter.rangeValueFormatError' => 'Lỗi định dạng giá trị khoảng',
			'searchFilter.contains' => 'Chứa',
			'searchFilter.equals' => 'Bằng',
			'searchFilter.notEquals' => 'Không bằng',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Khoảng',
			'searchFilter.kIn' => 'Chứa bất kỳ',
			'searchFilter.notIn' => 'Không chứa bất kỳ',
			'searchFilter.username' => 'Tên người dùng',
			'searchFilter.nickname' => 'Biệt danh',
			'searchFilter.registrationDate' => 'Ngày đăng ký',
			'searchFilter.description' => 'Mô tả',
			'searchFilter.title' => 'Tiêu đề',
			'searchFilter.body' => 'Nội dung',
			'searchFilter.author' => 'Tác giả',
			'searchFilter.publishDate' => 'Ngày đăng',
			'searchFilter.private' => 'Riêng tư',
			'searchFilter.duration' => 'Thời lượng (giây)',
			'searchFilter.likes' => 'Lượt thích',
			'searchFilter.views' => 'Lượt xem',
			'searchFilter.comments' => 'Bình luận',
			'searchFilter.rating' => 'Xếp hạng',
			'searchFilter.imageCount' => 'Số hình ảnh',
			'searchFilter.videoCount' => 'Số video',
			'searchFilter.createDate' => 'Ngày tạo',
			'searchFilter.content' => 'Nội dung',
			'searchFilter.all' => 'Tất cả',
			'searchFilter.adult' => 'Người lớn',
			'searchFilter.general' => 'Chung',
			'searchFilter.yes' => 'Có',
			'searchFilter.no' => 'Không',
			'searchFilter.users' => 'Người dùng',
			'searchFilter.videos' => 'Video',
			'searchFilter.images' => 'Hình ảnh',
			'searchFilter.posts' => 'Bài viết',
			'searchFilter.forumThreads' => 'Chủ đề diễn đàn',
			'searchFilter.forumPosts' => 'Bài viết diễn đàn',
			'searchFilter.playlists' => 'Danh sách phát',
			'searchFilter.sortTypes.relevance' => 'Liên quan',
			'searchFilter.sortTypes.latest' => 'Mới nhất',
			'searchFilter.sortTypes.views' => 'Lượt xem',
			'searchFilter.sortTypes.likes' => 'Lượt thích',
			'searchFilter.drawerSubtitle' => 'Thay đổi được áp dụng ngay',
			'firstTimeSetup.welcome.title' => 'Chào mừng',
			'firstTimeSetup.welcome.subtitle' => 'Hãy bắt đầu hành trình thiết lập cá nhân hóa',
			'firstTimeSetup.welcome.description' => 'Chỉ vài bước để tùy chỉnh trải nghiệm tốt nhất',
			'firstTimeSetup.basic.title' => 'Cài đặt cơ bản',
			'firstTimeSetup.basic.subtitle' => 'Cá nhân hóa trải nghiệm của bạn',
			'firstTimeSetup.basic.description' => 'Chọn các tùy chọn phù hợp',
			'firstTimeSetup.network.title' => 'Cài đặt mạng',
			'firstTimeSetup.network.subtitle' => 'Cấu hình tùy chọn mạng',
			'firstTimeSetup.network.description' => 'Điều chỉnh theo môi trường mạng',
			'firstTimeSetup.network.tip' => 'Cần khởi động lại sau khi cấu hình thành công để có hiệu lực',
			'firstTimeSetup.theme.title' => 'Cài đặt chủ đề',
			'firstTimeSetup.theme.subtitle' => 'Chọn giao diện bạn thích',
			'firstTimeSetup.theme.description' => 'Cá nhân hóa trải nghiệm hình ảnh',
			'firstTimeSetup.player.title' => 'Cài đặt trình phát',
			'firstTimeSetup.player.subtitle' => 'Cấu hình điều khiển phát',
			'firstTimeSetup.player.description' => 'Thiết lập nhanh các tùy chọn phát thường dùng',
			'firstTimeSetup.spatial.title' => 'Phát trong không gian',
			'firstTimeSetup.spatial.subtitle' => 'Xem và duyệt trên kính',
			'firstTimeSetup.spatial.description' => 'Trên kính, video và thư viện xuất hiện trong không gian quanh bạn thay vì bên trong bảng nổi này',
			'firstTimeSetup.completion.title' => 'Hoàn tất thiết lập',
			'firstTimeSetup.completion.subtitle' => 'Bạn đã sẵn sàng bắt đầu hành trình',
			'firstTimeSetup.completion.description' => 'Vui lòng đọc và đồng ý với các thỏa thuận liên quan',
			'firstTimeSetup.completion.agreementTitle' => 'Thỏa thuận người dùng và quy tắc cộng đồng',
			'firstTimeSetup.completion.agreementDesc' => 'Trước khi dùng ứng dụng này, vui lòng đọc kỹ và đồng ý với thỏa thuận người dùng và quy tắc cộng đồng. Các điều khoản này giúp duy trì môi trường tốt.',
			'firstTimeSetup.completion.checkboxTitle' => 'Tôi đã đọc và đồng ý với thỏa thuận người dùng và quy tắc cộng đồng',
			'firstTimeSetup.completion.checkboxSubtitle' => 'Không đồng ý thì không thể dùng ứng dụng',
			'firstTimeSetup.common.settingsChangeableTip' => 'Các cài đặt này có thể thay đổi bất cứ lúc nào trong Cài đặt',
			'firstTimeSetup.common.previousStep' => 'Bước trước',
			'firstTimeSetup.common.nextStep' => 'Bước tiếp theo',
			'firstTimeSetup.common.finishSetup' => 'Hoàn tất thiết lập',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Vui lòng đồng ý với thỏa thuận người dùng và quy tắc cộng đồng trước',
			'proxyHelper.systemProxyDetected' => 'Đã phát hiện proxy hệ thống',
			'proxyHelper.copied' => 'Đã sao chép',
			'proxyHelper.copy' => 'Sao chép',
			'tagSelector.selectTags' => 'Chọn thẻ',
			'tagSelector.clickToSelectTags' => 'Nhấn để chọn thẻ',
			'tagSelector.addTag' => 'Thêm thẻ',
			'tagSelector.removeTag' => 'Bỏ thẻ',
			'tagSelector.deleteTag' => 'Xóa thẻ',
			'tagSelector.usageInstructions' => 'Trước tiên thêm thẻ, sau đó nhấn để chọn từ các thẻ hiện có',
			'tagSelector.usageInstructionsTooltip' => 'Hướng dẫn sử dụng',
			'tagSelector.addTagTooltip' => 'Thêm thẻ',
			'tagSelector.removeTagTooltip' => 'Bỏ thẻ',
			'tagSelector.cancelSelection' => 'Hủy lựa chọn',
			'tagSelector.selectAll' => 'Chọn tất cả',
			'tagSelector.cancelSelectAll' => 'Hủy chọn tất cả',
			'tagSelector.delete' => 'Xóa',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Nâng tỉ lệ và khử nhiễu video theo thời gian thực, nâng cao chất lượng video hoạt hình',
			'anime4k.settings' => 'Cài đặt Anime4K',
			'anime4k.preset' => 'Cấu hình Anime4K',
			'anime4k.disable' => 'Tắt Anime4K',
			'anime4k.disableDescription' => 'Tắt hiệu ứng nâng cao chất lượng video',
			'anime4k.highQualityPresets' => 'Cấu hình chất lượng cao',
			'anime4k.fastPresets' => 'Cấu hình nhanh',
			'anime4k.litePresets' => 'Cấu hình nhẹ',
			'anime4k.moreLitePresets' => 'Cấu hình nhẹ hơn',
			'anime4k.customPresets' => 'Cấu hình tùy chỉnh',
			'anime4k.presetGroups.highQuality' => 'Chất lượng cao',
			'anime4k.presetGroups.fast' => 'Nhanh',
			'anime4k.presetGroups.lite' => 'Nhẹ',
			'anime4k.presetGroups.moreLite' => 'Nhẹ hơn',
			'anime4k.presetGroups.custom' => 'Tùy chỉnh',
			'anime4k.presetDescriptions.mode_a_hq' => 'Phù hợp với hầu hết video hoạt hình 1080p, đặc biệt là các trường hợp bị mờ, lấy mẫu lại và nén. Mang lại chất lượng cảm nhận cao nhất.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Phù hợp với video hoạt hình bị mờ nhẹ hoặc có viền răng cưa do nâng tỉ lệ. Giảm hiệu quả viền răng cưa và hiện tượng răng cưa.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Phù hợp với nguồn chất lượng cao (như video hoạt hình hoặc phim 1080p gốc). Khử nhiễu và mang lại PSNR cao nhất.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Phiên bản nâng cao của Mode A, mang lại chất lượng cảm nhận tối đa và có thể tái tạo gần như toàn bộ đường nét bị suy giảm. Có thể gây quá sắc hoặc viền răng cưa.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Phiên bản nâng cao của Mode B, mang lại chất lượng cảm nhận cao hơn, tối ưu đường nét và giảm lỗi hình.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Phiên bản nâng cao chất lượng cảm nhận của Mode C, duy trì PSNR cao đồng thời cố tái tạo một số chi tiết đường nét.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Phiên bản nhanh của Mode A, cân bằng giữa chất lượng và hiệu năng, phù hợp với hầu hết video hoạt hình 1080p.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Phiên bản nhanh của Mode B, xử lý lỗi hình nhẹ và viền răng cưa với chi phí thấp hơn.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Phiên bản nhanh của Mode C, khử nhiễu và nâng tỉ lệ nhanh cho nguồn chất lượng cao.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Phiên bản nhanh của Mode A+A, hướng tới chất lượng cảm nhận cao hơn trên thiết bị hạn chế hiệu năng.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Phiên bản nhanh của Mode B+B, tăng cường sửa đường nét và xử lý lỗi hình cho thiết bị hạn chế hiệu năng.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Phiên bản nhanh của Mode C+A, xử lý nhanh nguồn chất lượng cao đồng thời sửa đường nét nhẹ.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Nâng tỉ lệ x2 cực nhanh chỉ bằng mô hình CNN nhanh nhất, không phục hồi hay khử nhiễu, chi phí hiệu năng tối thiểu.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Nâng tỉ lệ và làm nét nhanh bằng thuật toán truyền thống không dùng CNN, tốt hơn thuật toán mặc định của trình phát với chi phí hiệu năng rất thấp.',
			'anime4k.presetDescriptions.restore_s_only' => 'Chỉ phục hồi bằng mô hình CNN nhanh nhất, không nâng tỉ lệ. Phù hợp khi phát ở độ phân giải gốc mà muốn nâng cao chất lượng.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Khử nhiễu nhanh bằng lọc song phương truyền thống, cực nhanh, phù hợp xử lý nhiễu nhẹ.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Nâng tỉ lệ nhanh bằng thuật toán truyền thống, chi phí hiệu năng rất thấp, tốt hơn mặc định của trình phát.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + làm đậm đường nét, bổ sung hiệu ứng làm đậm đường nét cho Mode A nhanh, giúp đường nét nổi bật và cách điệu hơn.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + làm mảnh đường nét, bổ sung hiệu ứng làm mảnh đường nét cho Mode A chất lượng cao, giúp hình ảnh tinh tế hơn.',
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
			'anime4k.presetNames.upscale_only_s' => 'Nâng tỉ lệ CNN (cực nhanh)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Nâng tỉ lệ & làm nét (nhanh)',
			'anime4k.presetNames.restore_s_only' => 'Phục hồi (cực nhanh)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Khử nhiễu song phương (cực nhanh)',
			'anime4k.presetNames.upscale_non_cnn' => 'Nâng tỉ lệ không CNN (cực nhanh)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + làm đậm đường nét',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + làm mảnh đường nét',
			'anime4k.performanceTip' => '💡 Mẹo: chọn cấu hình phù hợp với hiệu năng thiết bị. Thiết bị cấu hình thấp nên dùng cấu hình nhẹ.',
			'anime4k.compatibilityTip' => '⚠️ Một số GPU di động (ví dụ Kirin 980 / Mali-G76) không kết xuất được shader tùy chỉnh. Nếu hình ảnh chuyển đen trong khi âm thanh vẫn phát, hãy tắt Anime4K tại đây.',
			'anime4k.autoDisabledOnRenderFailure' => 'GPU của thiết bị không kết xuất được shader Anime4K nên tính năng đã tự động tắt.',
			'siteMode.title' => 'Chế độ trang',
			'siteMode.mainSite' => 'Main',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Hiện tại ${currentSite} · Nhấn để chuyển sang ${nextSite}',
			'siteMode.dialogTitle' => 'Chuyển chế độ trang',
			'siteMode.dialogDescription' => 'Việc chuyển đổi sẽ làm mới toàn bộ ứng dụng và đặt lại các danh sách cùng trạng thái trang đã tải trước đó.',
			'siteMode.chooseLinkTargetTitle' => 'Chọn trang đích',
			'siteMode.chooseLinkTargetDescription' => 'Liên kết này không bao gồm tên miền. Vui lòng chọn mở trong Main hay AI.',
			'siteMode.chooseLinkTargetHint' => 'Sau khi mở, trang này và các yêu cầu chi tiết tiếp theo sẽ tiếp tục dùng trang đã chọn.',
			'siteMode.alreadyUsing' => 'Bạn đang dùng chế độ trang này rồi.',
			'siteMode.openInSite' => ({required Object site}) => 'Mở trong ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'Sau khi xác nhận, các yêu cầu tiếp theo sẽ dùng chế độ ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Đã chuyển sang ${site}. Ứng dụng đã được làm mới.',
			'savedSearchConfig.title' => 'Bộ lọc đã lưu',
			'savedSearchConfig.empty' => 'Chưa có bộ lọc đã lưu',
			'savedSearchConfig.saveTooltip' => 'Lưu bộ lọc hiện tại',
			'savedSearchConfig.namePromptTitle' => 'Lưu bộ lọc',
			'savedSearchConfig.nameLabel' => 'Tên',
			'savedSearchConfig.nameHint' => 'Nhập tên',
			'savedSearchConfig.saveSuccess' => 'Đã lưu bộ lọc',
			'savedSearchConfig.deleteSuccess' => 'Đã xóa bộ lọc',
			'savedSearchConfig.addCurrent' => 'Lưu bộ lọc hiện tại',
			'savedSearchConfig.reorderHint' => 'Nhấn giữ và kéo để sắp xếp lại',
			'savedSearchConfig.rename' => 'Đổi tên',
			'savedSearchConfig.unnamed' => 'Chưa đặt tên',
			'savedSearchConfig.noConditions' => 'Tất cả nội dung (không lọc)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} thẻ',
			'savedSearch.title' => 'Tìm kiếm đã lưu',
			'savedSearch.empty' => 'Chưa có tìm kiếm đã lưu',
			'savedSearch.saveTooltip' => 'Lưu tìm kiếm hiện tại',
			'savedSearch.namePromptTitle' => 'Lưu tìm kiếm',
			'savedSearch.nameLabel' => 'Tên',
			'savedSearch.nameHint' => 'Nhập tên',
			'savedSearch.saveSuccess' => 'Đã lưu tìm kiếm',
			'savedSearch.deleteSuccess' => 'Đã xóa tìm kiếm',
			'savedSearch.addCurrent' => 'Lưu tìm kiếm hiện tại',
			'savedSearch.reorderHint' => 'Nhấn giữ và kéo để sắp xếp lại',
			'savedSearch.rename' => 'Đổi tên',
			'savedSearch.noKeyword' => '(Không có từ khóa)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} bộ lọc',
			'defaultBlacklistReminder.title' => 'Phát hiện danh sách thẻ chặn mặc định',
			'defaultBlacklistReminder.content' => 'Tài khoản của bạn vẫn đang dùng danh sách thẻ chặn mà trang web tự động áp dụng cho mọi tài khoản mới. Bạn có muốn xem lại và quản lý không?',
			'defaultBlacklistReminder.goManage' => 'Quản lý',
			'defaultBlacklistReminder.dismiss' => 'Để sau',
			'colorVisionAssist.title' => 'Hỗ trợ phân biệt màu',
			'colorVisionAssist.description' => 'Hiệu chỉnh màu video cho người mắc chứng khó phân biệt màu, có thể dùng cùng Anime4K',
			'colorVisionAssist.galleryDescription' => 'Hiệu chỉnh màu ảnh trong thư viện cho người mắc chứng khó phân biệt màu (độc lập với công tắc của trình phát)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Hiệu chỉnh màu ảnh trong thư viện cho người mắc chứng khó phân biệt màu. Chỉ áp dụng cho trình xem 2D trong bảng này — ảnh trên màn hình không gian được kết xuất nguyên bản và không đi qua bộ lọc này',
			'colorVisionAssist.disable' => 'Tắt',
			'colorVisionAssist.disableDescription' => 'Không hiệu chỉnh màu',
			'colorVisionAssist.protanopia' => 'Hỗ trợ màu đỏ (Protanopia)',
			'colorVisionAssist.protanopiaDescription' => 'Dành cho người mù màu đỏ — khó phân biệt màu đỏ',
			'colorVisionAssist.deuteranopia' => 'Hỗ trợ màu xanh lá (Deuteranopia)',
			'colorVisionAssist.deuteranopiaDescription' => 'Dành cho người mù màu lục — khó phân biệt màu xanh lá',
			'colorVisionAssist.tritanopia' => 'Hỗ trợ màu xanh dương (Tritanopia)',
			'colorVisionAssist.tritanopiaDescription' => 'Dành cho người mù màu lam — khó phân biệt màu xanh dương và vàng',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} đã áp dụng, có hiệu lực ngay',
			'colorVisionAssist.disabledToast' => 'Đã tắt hỗ trợ phân biệt màu',
			'externalPlayer.title' => 'Mở bằng ứng dụng khác',
			'externalPlayer.description' => 'Chuyển video hiện tại sang trình phát khác trên thiết bị này, chẳng hạn Skybox hoặc Pigasus trên kính VR, hoặc MX Player và VLC trên điện thoại',
			'externalPlayer.openWithOtherApp' => 'Chọn ứng dụng khác',
			'externalPlayer.openWithOtherAppDescription' => 'Hiện bảng chọn của hệ thống và chọn trình phát để tiếp nhận',
			'externalPlayer.openWithSystemPlayer' => 'Mở bằng trình phát mặc định',
			'externalPlayer.openWithSystemPlayerDescription' => 'Chuyển cho ứng dụng video mặc định của hệ thống',
			'externalPlayer.copyLink' => 'Sao chép liên kết video',
			'externalPlayer.copyLinkDescription' => 'Dành cho trình phát chỉ có thể dán URL, chẳng hạn Skybox hoặc DeoVR',
			'externalPlayer.linkCopied' => 'Đã sao chép liên kết video',
			'externalPlayer.sourceLocal' => 'Tệp cục bộ',
			'externalPlayer.sourceOnline' => 'Liên kết trực tiếp',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Liên kết trực tiếp · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'Liên kết trực tiếp sẽ hết hạn nên trình phát ngoài có thể dừng giữa chừng. Tải xuống trước là cách đáng tin cậy hơn.',
			'externalPlayer.vrPlayerHint' => 'Nếu trình phát VR của bạn không có trong bảng chọn, hãy dùng Sao chép liên kết video và dán vào trình phát đó.',
			'externalPlayer.noHandler' => 'Không có ứng dụng nào trên thiết bị này mở được video',
			'externalPlayer.handoffFailed' => ({required Object message}) => 'Chuyển giao thất bại: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'Chuyển giao thất bại',
			'externalPlayer.sourceUnavailable' => 'Không lấy được địa chỉ video hiện tại, vui lòng thử lại',
			'externalPlayer.localFileMissing' => 'Tệp cục bộ không còn tồn tại',
			'externalPlayer.handedOff' => 'Đã chuyển sang trình phát ngoài',
			'externalPlayer.desktopSectionTitle' => 'Trình phát ngoài',
			'externalPlayer.managePlayers' => 'Quản lý trình phát ngoài',
			'externalPlayer.managePlayersDescWindows' => 'Các trình phát PCVR như HereSphere, DeoVR và Whirligig không phải ứng dụng mặc định của hệ thống. Hãy chỉ định tới tệp .exe của chúng để có thể chuyển video hiện tại ngay từ trình phát.',
			'externalPlayer.managePlayersDescMac' => 'Chỉ định tới các trình phát như IINA, VLC hoặc mpv để có thể chuyển video hiện tại ngay từ trình phát.',
			'externalPlayer.managePlayersDescLinux' => 'Chỉ định tới các trình phát như mpv, VLC hoặc Celluloid để có thể chuyển video hiện tại ngay từ trình phát.',
			'externalPlayer.pickExecutableHintWindows' => 'Chọn tệp .exe chính trong thư mục cài đặt của trình phát, ví dụ HereSphere.exe hoặc vlc.exe. Lối tắt trên màn hình (.lnk) sẽ không hoạt động.',
			'externalPlayer.pickExecutableHintMac' => 'Chọn tệp .app của trình phát trong thư mục Ứng dụng, ví dụ IINA.app — tệp thực thi thật bên trong sẽ được tự động định vị.',
			'externalPlayer.pickExecutableHintLinux' => 'Chọn tệp thực thi của trình phát, ví dụ /usr/bin/mpv. Chạy lệnh which mpv sẽ cho biết vị trí của nó.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'Sau khi cấu hình, nó sẽ xuất hiện như một mục riêng trong Mở bằng ứng dụng khác trên trang trình phát. Một số trình phát phổ biến: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'Không tìm thấy trình phát nào đã cài. Không thể phát hiện thư mục cài đặt tùy chỉnh và bản portable — hãy dùng Thêm trình phát để tự chỉ định.',
			'externalPlayer.detectNothingNew' => 'Không tìm thấy trình phát mới; mọi thứ đã cài đều có trong danh sách',
			'externalPlayer.detectFailed' => 'Phát hiện thất bại — hãy dùng Thêm trình phát để tự chỉ định',
			'externalPlayer.advancedOptions' => 'Nâng cao',
			'externalPlayer.playerNameHint' => 'Để trống để dùng tên tệp',
			'externalPlayer.executablePathRequired' => 'Hãy chọn tệp thực thi của trình phát trước',
			'externalPlayer.playerCount' => ({required Object count}) => 'Đã cấu hình ${count}',
			'externalPlayer.noPlayerConfigured' => 'Chưa cấu hình trình phát ngoài nào',
			'externalPlayer.autoDetect' => 'Tự động phát hiện',
			'externalPlayer.detecting' => 'Đang phát hiện…',
			'externalPlayer.detectFound' => ({required Object count}) => 'Đã tìm thấy ${count} trình phát',
			'externalPlayer.detectNothingFound' => 'Không tìm thấy trình phát mới, hãy thêm thủ công',
			'externalPlayer.autoDetectedTag' => 'đã phát hiện',
			'externalPlayer.addPlayer' => 'Thêm trình phát',
			'externalPlayer.editPlayer' => 'Chỉnh sửa trình phát',
			'externalPlayer.playerName' => 'Tên',
			'externalPlayer.executablePath' => 'Tệp thực thi',
			'externalPlayer.browse' => 'Duyệt',
			'externalPlayer.argumentTemplate' => 'Tham số khởi chạy',
			'externalPlayer.argumentTemplateHint' => 'Dùng {input} cho đường dẫn hoặc URL video. Để trống để truyền nó làm tham số duy nhất.',
			'externalPlayer.nameAndPathRequired' => 'Cần nhập cả tên và tệp thực thi',
			'externalPlayer.testLaunch' => 'Thử khởi chạy',
			'externalPlayer.testLaunched' => 'Đã khởi chạy trình phát',
			'externalPlayer.testFailed' => 'Khởi chạy thất bại, hãy kiểm tra đường dẫn tệp thực thi',
			'externalPlayer.executableMissing' => 'Không tìm thấy tệp thực thi',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'Mở bằng ${name}',
			'externalPlayer.managePlayersEntry' => 'Quản lý trình phát ngoài…',
			'watchLater.title' => 'Xem sau',
			'watchLater.addToWatchLater' => 'Xem sau',
			'watchLater.removeFromWatchLater' => 'Xóa khỏi Xem sau',
			'watchLater.addedToWatchLater' => 'Đã thêm vào Xem sau',
			'watchLater.alreadyInWatchLater' => 'Đã có trong Xem sau',
			'watchLater.removedFromWatchLater' => 'Đã xóa khỏi Xem sau',
			'watchLater.removedCount' => ({required Object count}) => 'Đã xóa ${count} mục',
			'watchLater.viewWatchLaterList' => 'Xem danh sách',
			_ => null,
		} ?? switch (path) {
			'watchLater.addFailed' => 'Thêm vào Xem sau thất bại',
			'watchLater.invalidItem' => 'Không khả dụng',
			'watchLater.clearWatched' => 'Xóa các mục đã xem',
			'watchLater.watchedCleared' => ({required Object count}) => 'Đã xóa ${count} mục đã xem',
			'watchLater.noWatchedToClear' => 'Không có mục đã xem nào để xóa',
			'watchLater.emptyVideo' => 'Chưa có video nào trong Xem sau',
			'watchLater.emptyGallery' => 'Chưa có thư viện nào trong Xem sau',
			'watchLater.filterAll' => 'Tất cả',
			'watchLater.filterUnwatched' => 'Chưa xem',
			'watchLater.sortRecentlyAdded' => 'Thêm gần đây',
			'watchLater.sortEarliestAdded' => 'Thêm sớm nhất',
			'watchLater.watched' => 'Đã xem',
			'watchLater.playlistLoadFailed' => 'Tải danh sách phát thất bại',
			'watchLater.noPlaylists' => 'Chưa có danh sách phát nào',
			'watchLater.undo' => 'Hoàn tác',
			'watchLater.clearWatchedConfirm' => 'Xóa mọi thứ bạn đã xem trong tab này? Thao tác này không thể hoàn tác.',
			'watchLater.emptyUnwatchedVideo' => 'Không còn gì để xem ở đây',
			'watchLater.emptyUnwatchedGallery' => 'Không còn gì để xem ở đây',
			'watchLater.queueLoadFailed' => 'Tải thất bại, nhấn để thử lại',
			'mediaMenu.like' => 'Thích',
			'mediaMenu.unlike' => 'Bỏ thích',
			'mediaMenu.viewAuthor' => 'Xem tác giả',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} thư mục',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} danh sách phát',
			'mediaMenu.downloaded' => 'Đã tải xuống',
			'mediaPreview.preview' => 'Xem trước',
			'mediaPreview.openDetail' => 'Mở',
			'mediaPreview.moreActions' => 'Thao tác khác',
			'mediaPreview.previousImage' => 'Ảnh trước',
			'mediaPreview.nextImage' => 'Ảnh tiếp theo',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} hình ảnh',
			'playbackQueue.upNext' => 'Tiếp theo',
			'playbackQueue.sourceTab' => 'Nguồn',
			'playbackQueue.emptyQueue' => 'Không có gì có thể phát trong hàng đợi này',
			'playbackQueue.emptyGalleryQueue' => 'Không có thư viện nào trong hàng đợi này',
			'playbackQueue.nowPlaying' => 'Đang phát',
			'playbackQueue.myPlaylists' => 'Danh sách phát của tôi',
			'playbackQueue.authorPlaylists' => 'Danh sách phát của tác giả',
			'playbackQueue.openQueue' => 'Tiếp theo',
			'playbackQueue.continueInQueue' => 'Tiếp tục phát từ hàng đợi hiện tại',
			'playbackQueue.continueInQueueSubtitle' => 'Tự động phát mục tiếp theo; tắt "lặp lại khi kết thúc"',
			'playbackQueue.repeatDisabledByQueue' => 'Bị tắt khi bật "tiếp tục phát từ hàng đợi hiện tại"',
			'playbackQueue.playNext' => 'Phát tiếp theo',
			'playbackQueue.queueEnded' => 'Đây là mục cuối cùng trong hàng đợi',
			'playbackQueue.playNextHint' => 'Nhấn để phát mục tiếp theo, nhấn giữ để mở Tiếp theo',
			'playbackQueue.authorVideos' => 'Video của tác giả',
			'playbackQueue.authorGalleries' => 'Thư viện của tác giả',
			'playbackQueue.favoriteFolders' => 'Thư mục yêu thích',
			'playbackQueue.localFiles' => 'Trên thiết bị này',
			'playbackQueue.currentFolder' => 'Thư mục của tệp này',
			'playbackQueue.playThisFolder' => 'Xem hàng đợi video của thư mục này',
			'playbackQueue.browseThisFolder' => 'Xem hàng đợi thư viện của thư mục này',
			'playbackQueue.downloads' => 'Đã tải xuống',
			'playbackQueue.otherPlaylists' => 'Danh sách phát của người dùng khác',
			'playbackQueue.nothingHere' => 'Không có gì ở đây',
			'vrFormat.playInSpace' => 'Phát trong trình phát không gian',
			'vrFormat.handingOff' => 'Đang chuyển sang không gian…',
			'vrFormat.title' => 'Chế độ phát',
			'vrFormat.spatialSectionTitle' => 'Phát không gian',
			'vrFormat.spatialSectionDesc' => 'Trên tai nghe, video không được vẽ trong bảng này — trình phát không gian đặt nó lên một màn hình trong phòng.',
			'vrFormat.spatialPanelEntry' => 'Bảng điều khiển không gian',
			'vrFormat.spatialPanelEntryDesc' => 'Khoảng cách, kích thước và độ cong màn hình, môi trường nền, cùng tốc độ, lặp lại và tự động ẩn đều nằm trong bảng điều khiển không gian.',
			'vrFormat.spatialGuideEntry' => 'Hướng dẫn điều khiển tai nghe',
			'vrFormat.spatialGuideEntryDesc' => 'Nút bộ điều khiển, nắm màn hình, tua bằng cần gạt và lật trang',
			'vrFormat.spatialFlatOmitted' => 'Cử chỉ cảm ứng, nâng cao hình ảnh và tham số âm thanh/video chỉ áp dụng cho trình phát 2D; trình phát không gian chạy trên một engine khác nên không được liệt kê ở đây.',
			'vrFormat.spatialGallerySectionTitle' => 'Thư viện không gian',
			'vrFormat.spatialGalleryPanelDesc' => 'Khoảng thời gian trình chiếu, lặp một clip và độ cong màn hình đều được điều chỉnh trong bảng điều khiển không gian.',
			'vrFormat.autoEnterGallery' => 'Mở hình ảnh thư viện trong thư viện không gian',
			'vrFormat.autoEnterGalleryDesc' => 'Trên Quest, nhấn vào một hình ảnh sẽ mở toàn bộ thư viện trên màn hình nổi với dải phim, trình chiếu và lật trang bằng bộ điều khiển thay vì trình xem trong bảng này.',
			'vrFormat.panelSettings' => 'Bảng và nền',
			'vrFormat.panelSettingsDesc' => 'Bảng ứng dụng này đặt cách bao xa, và phòng của bạn hiện ra phía sau bao nhiêu',
			'vrFormat.panelDistance' => 'Khoảng cách bảng',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Đặt lại vị trí',
			'vrFormat.panelResetBackground' => 'Đặt lại mặc định',
			'vrFormat.panelBackground' => 'Độ trong suốt nền',
			'vrFormat.panelBackgroundHint' => '0%: môi trường xung quanh màu đen · 100%: phòng thật của bạn, có ánh sáng xung quanh',
			'vrFormat.panelUnavailable' => 'Bảng hiện không ở đúng vị trí — vui lòng thử lại sau giây lát',
			'vrFormat.desc' => 'Chọn hình học để phát video này. Trang web không cung cấp thông tin này, nên tính năng tự động phát hiện chỉ chọn một điểm khởi đầu — lựa chọn của bạn sẽ được ưu tiên.',
			'vrFormat.sectionFlat' => 'Phẳng',
			'vrFormat.sectionStereo' => '3D phẳng',
			'vrFormat.sectionPanorama' => 'Toàn cảnh VR',
			'vrFormat.flat' => 'Video thường',
			'vrFormat.flatDesc' => 'Phát nguyên bản, không ánh xạ lại',
			'vrFormat.flatSideBySide' => '3D cạnh nhau',
			'vrFormat.flatSideBySideDesc' => 'Mỗi mắt một nửa, trái và phải; hiển thị mắt trái và khôi phục tỉ lệ khung hình',
			'vrFormat.flatTopBottom' => '3D trên dưới',
			'vrFormat.flatTopBottomDesc' => 'Mỗi mắt một nửa, trên và dưới; hiển thị nửa trên và khôi phục tỉ lệ khung hình',
			'vrFormat.vr180SideBySide' => 'VR180 cạnh nhau',
			'vrFormat.vr180SideBySideDesc' => 'Toàn cảnh bán cầu với cả hai mắt — nguồn VR phổ biến nhất',
			'vrFormat.vr180Mono' => 'VR180 mono',
			'vrFormat.vr180MonoDesc' => 'Toàn cảnh bán cầu, một mắt mỗi khung hình',
			'vrFormat.vr360Mono' => 'VR360 mono',
			'vrFormat.vr360MonoDesc' => 'Toàn cảnh bao quanh đầy đủ, một mắt mỗi khung hình',
			'vrFormat.vr360TopBottom' => 'VR360 trên dưới',
			'vrFormat.vr360TopBottomDesc' => 'Toàn cảnh bao quanh đầy đủ với cả hai mắt xếp chồng',
			'vrFormat.resetView' => 'Đặt lại tầm nhìn',
			'vrFormat.resetViewDesc' => 'Đưa hướng nhìn và trường nhìn về phía trước',
			'vrFormat.resetToAuto' => 'Quay lại tự động phát hiện',
			'vrFormat.resetToAutoDesc' => 'Quên lựa chọn thủ công cho video này và để tính năng phát hiện quyết định lại',
			'vrFormat.manualBadge' => 'Đặt thủ công',
			'vrFormat.panoramaHint' => 'Kéo hình để nhìn quanh, chụm để thay đổi trường nhìn',
			'vrFormat.panoramaGestureNotice' => 'Trong khi nhìn quanh, kéo sẽ xoay tầm nhìn — hãy dùng thanh tiến trình để tua',
			'vrFormat.shaderUnsupported' => 'Thiết bị này không thể hiển thị toàn cảnh trực tiếp; thay vào đó hiển thị một mắt',
			'vrFormat.handoffTooltip' => 'Phát theo cách khác',
			'vrFormat.suggestedBadge' => 'Đề xuất',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Có vẻ là ${format} — nhấn để chuyển',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Đây có thể là video VR (${format})',
			'vrFormat.suggestionTitleShort' => 'Đây có thể là video VR',
			'vrFormat.suggestionAction' => 'Phát dạng VR',
			'vrFormat.suggestionDismiss' => 'Bỏ qua',
			'localMedia.browse.pinnedSection' => 'Truy cập nhanh',
			'localMedia.browse.sourcesSection' => 'Thư mục',
			'localMedia.browse.pin' => 'Thêm vào truy cập nhanh',
			'localMedia.browse.unpin' => 'Xóa khỏi truy cập nhanh',
			'localMedia.browse.pinned' => 'Đã thêm vào truy cập nhanh',
			'localMedia.browse.unpinned' => 'Đã xóa khỏi truy cập nhanh',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} thư mục',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} video',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} ảnh',
			'localMedia.browse.emptyFolder' => 'Thư mục này trống',
			'localMedia.browse.videosSection' => 'Video',
			'localMedia.browse.imagesSection' => 'Ảnh',
			'localMedia.browse.galleriesSection' => 'Thư viện',
			'localMedia.browse.filterAll' => 'Tất cả',
			'localMedia.browse.searchInFolder' => 'Tìm trong thư mục này',
			'localMedia.browse.searchHint' => 'Tìm theo tên',
			'localMedia.browse.clearSearch' => 'Xóa tìm kiếm',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'Không có kết quả cho "${query}"',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Xem tất cả ${count} thư mục',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Xem tất cả ${count} video',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Xem tất cả ${count} ảnh',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Xem tất cả ${count} thư viện',
			'localMedia.browse.location' => 'Vị trí',
			'localMedia.browse.sourceMissing' => 'Nguồn này không còn tồn tại',
			'localMedia.browse.notScannedYet' => 'Thư mục này chưa được quét',
			'localMedia.browse.scanning' => 'Đang đọc thư mục này…',
			'localMedia.browse.deleteFileTitle' => 'Xóa tệp này?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '"${name}" sẽ bị xóa vĩnh viễn khỏi thiết bị này. Không thể hoàn tác.',
			'localMedia.browse.hideFolder' => 'Ẩn thư mục này',
			'localMedia.browse.unhideFolder' => 'Bỏ ẩn',
			'localMedia.browse.showHiddenFolders' => 'Hiện thư mục đã ẩn',
			'localMedia.browse.includeDotFolders' => 'Quét thư mục bắt đầu bằng .',
			'localMedia.browse.dotFoldersIncluded' => 'Đã bắt đầu quét thư mục bắt đầu bằng .',
			'localMedia.browse.dotFoldersExcluded' => 'Không còn quét thư mục bắt đầu bằng .',
			'localMedia.browse.showDotFolders' => 'Hiện thư mục bắt đầu bằng .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'Ở đây còn ${count} thư mục bắt đầu bằng . chưa được quét',
			'localMedia.browse.scanDotFoldersAction' => 'Bật cho nguồn này',
			'localMedia.browse.otherAppsPrivateNotice' => 'Từ Android 11, không ứng dụng nào đọc được tệp của ứng dụng khác trong Android/data hoặc Android/obb, ứng dụng này cũng không thể vượt qua. Hãy tải xuống hoặc xuất video sang thư mục công khai như Download trong ứng dụng gốc, rồi thêm thư mục đó vào đây. Bộ nhớ đệm khi xem thường bị chia nhỏ và không phát được dù đọc được.',
			'localMedia.browse.folderHidden' => 'Đã ẩn — quá trình quét cũng sẽ bỏ qua',
			'localMedia.browse.folderUnhidden' => 'Đã bỏ ẩn',
			'localMedia.browse.hiddenFolderBadge' => 'Đã ẩn',
			'localMedia.browse.deleteFolder' => 'Xóa thư mục',
			'localMedia.browse.deleteFolderTitle' => 'Xóa thư mục này?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '"${name}" cùng toàn bộ nội dung bên trong sẽ bị xóa vĩnh viễn khỏi thiết bị này. Không thể hoàn tác.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Các tệp khác bên trong cũng sẽ bị xóa',
			'localMedia.browse.folderDeleted' => 'Đã xóa thư mục',
			'localMedia.browse.deleteFolderFailed' => 'Xóa thất bại — không có quyền, hoặc tệp bên trong đang được sử dụng',
			'localMedia.browse.deleteGalleryTitle' => 'Xóa thư viện này?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'Bản ghi tải xuống và các tệp ảnh cục bộ của "${name}" sẽ bị xóa. Không thể hoàn tác.',
			'localMedia.browse.galleryResourceMissing' => 'Tệp cục bộ không còn tồn tại. Đã dọn bản ghi.',
			'localMedia.browse.viewDownloadDetail' => 'Xem chi tiết tải xuống',
			'localMedia.browse.viewOnlineGallery' => 'Xem trên trang web',
			'localMedia.browse.pickFolderTitle' => 'Chọn một thư mục',
			'localMedia.browse.useThisFolder' => 'Dùng thư mục này',
			'localMedia.browse.noSubfolders' => 'Không có thư mục con ở đây',
			'localMedia.browse.storageRoot' => 'Bộ nhớ thiết bị',
			'localMedia.browse.homeFolder' => 'Trang chủ',
			'localMedia.browse.filesystemRoot' => 'Gốc hệ thống tệp',
			'localMedia.browse.folderUnreadable' => 'Không thể đọc thư mục này',
			'localMedia.browse.setCover' => 'Đặt ảnh bìa',
			'localMedia.browse.setAsFolderCover' => 'Dùng làm ảnh bìa thư mục',
			'localMedia.browse.folderCoverSet' => 'Đã cập nhật ảnh bìa thư mục',
			'localMedia.browse.setFolderCoverPick' => 'Đặt ảnh bìa…',
			'localMedia.browse.restoreAutoCover' => 'Khôi phục ảnh bìa tự động',
			'localMedia.browse.autoCoverRestored' => 'Đã khôi phục ảnh bìa tự động',
			'localMedia.browse.rescanFolder' => 'Quét lại thư mục này',
			'localMedia.browse.coverPickerTitle' => 'Chọn một khung hình',
			'localMedia.browse.folderCoverPickerTitle' => 'Chọn ảnh bìa',
			'localMedia.browse.coverPickerEmpty' => 'Thư mục này chưa có ảnh nào. Ảnh thu nhỏ của video có thể vẫn đang được tạo ở chế độ nền.',
			'localMedia.browse.coverSaved' => 'Đã cập nhật ảnh bìa',
			'localMedia.browse.coverSaveFailed' => 'Không thể lưu ảnh bìa',
			'localMedia.browse.coverUnavailable' => 'Không đọc được khung hình video từ tệp này',
			'localMedia.browse.deleted' => 'Đã xóa',
			'localMedia.browse.deleteFailed' => 'Không thể xóa — tệp có thể đang được dùng hoặc không ghi được',
			'localMedia.browse.openFolder' => 'Mở',
			'localMedia.browse.favorite' => 'Thêm vào yêu thích',
			'localMedia.browse.unfavorite' => 'Xóa khỏi yêu thích',
			'localMedia.browse.favorited' => 'Đã thêm vào yêu thích',
			'localMedia.browse.unfavorited' => 'Đã xóa khỏi yêu thích',
			'localMedia.browse.sortBy' => 'Sắp xếp theo',
			'localMedia.browse.sortAscending' => 'Tăng dần',
			'localMedia.browse.sortDescending' => 'Giảm dần',
			'localMedia.browse.sortFieldName' => 'Tên',
			'localMedia.browse.sortFieldModified' => 'Ngày sửa đổi',
			'localMedia.browse.sortFieldDuration' => 'Thời lượng',
			'localMedia.browse.sortFieldSize' => 'Kích thước',
			'localMedia.browse.sortFieldResolution' => 'Độ phân giải',
			'localMedia.browse.sortFieldFileType' => 'Loại tệp',
			'localMedia.browse.sortFieldFps' => 'Tốc độ khung hình',
			'localMedia.browse.sortFieldFavorited' => 'Ngày yêu thích',
			'localMedia.browse.emptyAllVideos' => 'Chưa tìm thấy video nào. Hãy thêm thư mục trong mục Thư mục để bắt đầu.',
			'localMedia.browse.emptyAllImages' => 'Chưa tìm thấy ảnh nào. Hãy thêm thư mục trong mục Thư mục để bắt đầu.',
			'localMedia.browse.emptyFavorites' => 'Chưa có mục yêu thích. Thêm từ menu ⋮ của video.',
			'localMedia.browse.emptyPinned' => 'Chưa có thư mục ghim. Nhấn giữ một thư mục trong mục Thư mục và chọn Ghim.',
			'localMedia.browse.emptyDownloadedVideos' => 'Chưa có video nào tải xuống hoàn tất.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Chưa có thư viện nào tải xuống hoàn tất.',
			'localMedia.browse.folderInfo' => 'Thông tin thư mục',
			'localMedia.browse.folderInfoName' => 'Tên',
			'localMedia.browse.folderInfoPath' => 'Đường dẫn',
			'localMedia.browse.folderInfoSource' => 'Nguồn',
			'localMedia.browse.folderInfoContents' => 'Nội dung',
			'localMedia.browse.folderInfoSize' => 'Kích thước trên đĩa',
			'localMedia.browse.folderInfoScannedAt' => 'Quét lần cuối',
			'localMedia.browse.folderInfoNeverScanned' => 'Chưa quét',
			'localMedia.browse.folderInfoNoPath' => 'Nguồn này không có thư mục để mở',
			'localMedia.browse.copyPath' => 'Sao chép đường dẫn',
			'localMedia.browse.pathCopied' => 'Đã sao chép đường dẫn',
			'localMedia.tabFolders' => 'Thư mục',
			'localMedia.tabFavoriteVideos' => 'Yêu thích',
			'localMedia.tabAllVideos' => 'Tất cả video',
			'localMedia.tabAllImages' => 'Tất cả ảnh',
			'localMedia.tabDownloadedVideos' => 'Video đã tải',
			'localMedia.tabDownloadedGalleries' => 'Thư viện đã tải',
			'localMedia.title' => 'Trên thiết bị này',
			'localMedia.sourceOnline' => 'Iwara trực tuyến',
			'localMedia.manageSources' => 'Quản lý nguồn',
			'localMedia.moveToCategory' => 'Chuyển vào danh mục',
			'localMedia.manageCategories' => 'Quản lý danh mục',
			'localMedia.suggestedFolders' => 'Thư mục có video',
			'localMedia.sortRecentlyAdded' => 'Thêm gần đây',
			'localMedia.sortRecentlyPlayed' => 'Phát gần đây',
			'localMedia.sortName' => 'Tên',
			'localMedia.sortDuration' => 'Thời lượng',
			'localMedia.sortSize' => 'Kích thước',
			'localMedia.sortFolder' => 'Thư mục',
			'localMedia.sortRecentlyModified' => 'Sửa đổi gần đây',
			'localMedia.sortCount' => 'Số lượng',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} ảnh',
			'localMedia.downloadsSource' => 'Đã tải xuống',
			'localMedia.builtInSourceHint' => 'Mục Đã tải xuống được quản lý tự động',
			'localMedia.filterByCategory' => 'Lọc theo danh mục',
			'localMedia.longPressToCategorize' => 'Nhấn giữ để chuyển vào danh mục',
			'localMedia.uncategorized' => 'Chưa phân loại',
			'localMedia.setCategoryFailed' => 'Không thể đặt danh mục',
			'localMedia.categoryUpdated' => 'Đã cập nhật danh mục',
			'localMedia.addFolder' => 'Thêm thư mục',
			'localMedia.addDeviceVideos' => 'Quét video trên thiết bị',
			'localMedia.mediaStoreSourceName' => 'Video trên thiết bị',
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
			'localMedia.mediaStoreUnavailable' => 'Chỉ mục media của thiết bị chỉ khả dụng trên Android',
			'localMedia.mediaStorePermissionDenied' => 'Quyền truy cập video chưa được cấp',
			'localMedia.rescan' => 'Quét lại',
			'localMedia.scanning' => ({required Object count}) => 'Đang quét… đã tìm thấy ${count}',
			'localMedia.scanFailed' => ({required Object reason}) => 'Quét thất bại: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Thư mục đó rất lớn — chỉ ${count} tệp đầu tiên được thêm.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Đã được bao phủ bởi thư mục "${name}"',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '"${name}" nằm trong "${source}", nên đã được thêm vào thư mục ghim',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '"${name}" đã có trong thư mục ghim',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '"${name}" đã được thêm rồi',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Đã chứa thư mục đã thêm "${name}"; chưa hỗ trợ thêm thư mục cha của nó',
			'localMedia.addSourceFailed' => 'Không thể thêm thư mục đó',
			'localMedia.fileMissing' => 'Tệp đó không còn trên đĩa',
			'localMedia.permissionDenied' => 'Chưa được cấp quyền truy cập tệp · nhấn để cấp',
			'localMedia.noVideosFound' => 'Không có video trong thư mục này',
			'localMedia.emptyTitle' => 'Thêm thư mục để xem các video đã có trên thiết bị này',
			'localMedia.emptyPrivacyNote' => 'Tệp chỉ được đọc trên thiết bị này. Không có gì được tải lên.',
			'localMedia.removeSourceTitle' => ({required Object name}) => 'Xóa "${name}"?',
			'localMedia.removeSourceBody' => 'Các tệp vẫn còn trên đĩa. Chỉ mục thư viện này bị xóa.',
			'localMedia.remove' => 'Xóa',
			'localMedia.removeFolder' => 'Xóa thư mục',
			'localMedia.removeFolderSelectTitle' => 'Chọn thư mục để xóa',
			'localMedia.longPressToRemove' => 'Nhấn giữ để xóa thư mục này',
			'localMedia.clearProgress' => 'Xóa lịch sử xem cục bộ',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} mục',
			'localMedia.clearProgressEmpty' => 'Chưa có lịch sử xem cục bộ',
			'localMedia.clearProgressTitle' => 'Xóa lịch sử xem cục bộ?',
			'localMedia.clearProgressBody' => 'Chỉ vị trí phát và dấu đã xem bị xóa. Các tệp và thư mục của bạn vẫn giữ nguyên.',
			'localMedia.clearProgressDone' => ({required Object count}) => 'Đã xóa ${count} mục lịch sử xem cục bộ',
			'localMedia.clearAction' => 'Xóa',
			'localMedia.iosManualRescanNotice' => 'iOS không tự động phát hiện tệp mới. Cần quét lại thủ công sau khi thêm hoặc xóa tệp.',
			'historyPage.removeFromHistory' => 'Xóa khỏi lịch sử',
			'historyPage.removed' => 'Đã xóa khỏi lịch sử',
			'historyPage.watchedTo' => ({required Object time}) => 'Đã xem đến ${time}',
			'historyPage.finished' => 'Đã xem xong',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'Xóa "${tab}"',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Toàn bộ lịch sử trong "${tab}" sẽ bị xóa, kèm tiến độ xem của các video đó. Không thể hoàn tác.',
			'historyPage.rangeByLastViewed' => 'Lọc theo thời gian xem gần nhất',
			'ai.title' => 'AI',
			'ai.providers' => 'Nhà cung cấp',
			'ai.providersHint' => 'Thêm một hoặc nhiều nhà cung cấp AI, sau đó chọn nhà cung cấp cho từng tính năng.',
			'ai.addProvider' => 'Thêm nhà cung cấp',
			'ai.noProviders' => 'Chưa có nhà cung cấp nào. Hãy thêm để bật tính năng dịch, tìm kiếm và chữ ký bằng AI.',
			'ai.pickPreset' => 'Chọn nhà cung cấp',
			'ai.providerNameLabel' => 'Tên',
			'ai.apiKey' => 'Khóa API',
			'ai.baseUrl' => 'Điểm cuối',
			'ai.model' => 'Mô hình',
			'ai.modelPick' => 'Chọn mô hình',
			'ai.modelEmpty' => 'Không thể tải danh sách mô hình — bạn cũng có thể nhập trực tiếp tên mô hình.',
			'ai.advanced' => 'Nâng cao',
			'ai.reasoning' => 'Mô hình suy luận',
			'ai.streaming' => 'Đầu ra dạng luồng',
			'ai.structuredOutput' => 'Đầu ra có cấu trúc',
			'ai.structuredOutputHint' => 'Cần thiết cho tìm kiếm AI. Nhiều endpoint trung gian không hỗ trợ — hãy tắt nếu tìm kiếm liên tục thất bại.',
			'ai.temperature' => 'Nhiệt độ',
			'ai.maxTokens' => 'Token tối đa',
			'ai.maxTokensAuto' => 'Tự động (giới hạn mô hình)',
			'ai.test' => 'Kiểm tra',
			'ai.testOk' => 'Kết nối thành công',
			'ai.deleteProvider' => 'Xóa nhà cung cấp',
			'ai.usedBy' => 'Đang dùng cho',
			'ai.taskBindings' => 'Phân bổ tính năng',
			'ai.taskBindingsHint' => 'Mỗi tính năng có thể dùng một nhà cung cấp khác nhau.',
			'ai.taskTranslate' => 'Dịch thuật',
			'ai.taskSearch' => 'Tìm kiếm AI',
			'ai.taskSignature' => 'Chữ ký',
			'ai.taskAuto' => 'Tự động',
			'ai.usage' => 'Mức sử dụng',
			'ai.usageCalls' => 'Lượt gọi',
			'ai.usageTokens' => 'Số token',
			'ai.usageFailures' => 'Thất bại',
			'ai.usageReset' => 'Xóa thống kê',
			'ai.usageEmpty' => 'Chưa có lượt gọi nào',
			'ai.openSettings' => 'Mở cài đặt AI',
			'ai.notConfigured' => 'Chưa định cấu hình',
			'ai.searchTitle' => 'Tìm kiếm AI',
			'ai.searchHint' => 'Mô tả nội dung bạn muốn tìm; AI sẽ điền các từ khóa tìm kiếm và bộ lọc.',
			'ai.searchPlaceholder' => 'vd: MMD mới nhất có hơn 10k lượt xem',
			'ai.searchApply' => 'Tìm kiếm bằng các điều kiện này',
			'ai.searchEmpty' => 'Không thể tạo từ khóa tìm kiếm từ mô tả này. Hãy thử diễn đạt theo cách khác.',
			'ai.searchFilters' => 'Bộ lọc',
			'ai.searchSwitchSegment' => ({required Object segment}) => 'Chuyển sang ${segment}',
			'ai.searchGenerating' => 'Đang suy nghĩ…',
			'ai.searchRetrying' => 'Lần trước thất bại, đang thử lại…',
			'ai.searchRetryReason' => ({required Object reason}) => 'Lý do: ${reason}',
			'ai.searchStageWaiting' => 'Đã gửi yêu cầu, đang chờ phản hồi…',
			'ai.searchStageThinkingNext' => 'Đang nghĩ bước tiếp theo…',
			'ai.searchStageReasoning' => 'Đang suy luận…',
			'ai.searchStageTool' => 'Đang thử tìm kiếm…',
			'ai.searchStageDrafting' => ({required Object chars}) => 'Đang viết câu trả lời · ${chars} ký tự',
			'ai.searchStageParsing' => 'Đang sắp xếp kết quả…',
			'ai.searchThinking' => 'Quá trình suy luận',
			'ai.searchKeywordNeedsQuotes' => 'Từ khoá này không đặt trong dấu ngoặc kép nên Iwara khớp lỏng lẻo — với kiểu sắp xếp này trang đầu phần lớn sẽ không liên quan. Hãy đặt nó trong "dấu ngoặc kép", hoặc sắp xếp theo độ liên quan.',
			'ai.searchToolProbing' => ({required Object query}) => 'Thử tìm ${query}',
			'ai.searchToolFound' => ({required Object count, required Object titles}) => '${count} kết quả · ${titles}',
			'ai.searchToolFailed' => ({required Object reason}) => 'Không chạy được: ${reason}',
			'ai.searchFiltersDropped' => ({required Object count}) => 'Đã bỏ ${count} bộ lọc không có trong mục này.',
			_ => null,
		};
	}
}
