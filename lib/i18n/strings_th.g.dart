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
class TranslationsTh extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.th,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <th>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsTh _root = this; // ignore: unused_field

	@override 
	TranslationsTh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTh(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileTh personalProfile = _TranslationsPersonalProfileTh._(_root);
	@override late final _TranslationsTutorialTh tutorial = _TranslationsTutorialTh._(_root);
	@override late final _TranslationsCommonTh common = _TranslationsCommonTh._(_root);
	@override late final _TranslationsAuthTh auth = _TranslationsAuthTh._(_root);
	@override late final _TranslationsErrorsTh errors = _TranslationsErrorsTh._(_root);
	@override late final _TranslationsFriendsTh friends = _TranslationsFriendsTh._(_root);
	@override late final _TranslationsAuthorProfileTh authorProfile = _TranslationsAuthorProfileTh._(_root);
	@override late final _TranslationsFavoritesTh favorites = _TranslationsFavoritesTh._(_root);
	@override late final _TranslationsGalleryDetailTh galleryDetail = _TranslationsGalleryDetailTh._(_root);
	@override late final _TranslationsPlayListTh playList = _TranslationsPlayListTh._(_root);
	@override late final _TranslationsSearchTh search = _TranslationsSearchTh._(_root);
	@override late final _TranslationsMediaListTh mediaList = _TranslationsMediaListTh._(_root);
	@override late final _TranslationsSettingsTh settings = _TranslationsSettingsTh._(_root);
	@override late final _TranslationsFavoriteTagsTh favoriteTags = _TranslationsFavoriteTagsTh._(_root);
	@override late final _TranslationsOreno3dTh oreno3d = _TranslationsOreno3dTh._(_root);
	@override late final _TranslationsSignInTh signIn = _TranslationsSignInTh._(_root);
	@override late final _TranslationsSubscriptionsTh subscriptions = _TranslationsSubscriptionsTh._(_root);
	@override late final _TranslationsVideoDetailTh videoDetail = _TranslationsVideoDetailTh._(_root);
	@override late final _TranslationsShareTh share = _TranslationsShareTh._(_root);
	@override late final _TranslationsMarkdownTh markdown = _TranslationsMarkdownTh._(_root);
	@override late final _TranslationsForumTh forum = _TranslationsForumTh._(_root);
	@override late final _TranslationsNotificationsTh notifications = _TranslationsNotificationsTh._(_root);
	@override late final _TranslationsConversationTh conversation = _TranslationsConversationTh._(_root);
	@override late final _TranslationsSplashTh splash = _TranslationsSplashTh._(_root);
	@override late final _TranslationsDownloadTh download = _TranslationsDownloadTh._(_root);
	@override late final _TranslationsDownloadNotificationsTh downloadNotifications = _TranslationsDownloadNotificationsTh._(_root);
	@override late final _TranslationsFavoriteTh favorite = _TranslationsFavoriteTh._(_root);
	@override late final _TranslationsTranslationTh translation = _TranslationsTranslationTh._(_root);
	@override late final _TranslationsBottomNavTh bottomNav = _TranslationsBottomNavTh._(_root);
	@override late final _TranslationsNavigationOrderSettingsTh navigationOrderSettings = _TranslationsNavigationOrderSettingsTh._(_root);
	@override late final _TranslationsNewsTh news = _TranslationsNewsTh._(_root);
	@override late final _TranslationsDisplaySettingsTh displaySettings = _TranslationsDisplaySettingsTh._(_root);
	@override late final _TranslationsLayoutSettingsTh layoutSettings = _TranslationsLayoutSettingsTh._(_root);
	@override late final _TranslationsMediaPlayerTh mediaPlayer = _TranslationsMediaPlayerTh._(_root);
	@override late final _TranslationsDiagnosticsTh diagnostics = _TranslationsDiagnosticsTh._(_root);
	@override late final _TranslationsLogViewerTh logViewer = _TranslationsLogViewerTh._(_root);
	@override late final _TranslationsCrashRecoveryDialogTh crashRecoveryDialog = _TranslationsCrashRecoveryDialogTh._(_root);
	@override late final _TranslationsLinkInputDialogTh linkInputDialog = _TranslationsLinkInputDialogTh._(_root);
	@override late final _TranslationsLogTh log = _TranslationsLogTh._(_root);
	@override late final _TranslationsEmojiTh emoji = _TranslationsEmojiTh._(_root);
	@override late final _TranslationsSearchFilterTh searchFilter = _TranslationsSearchFilterTh._(_root);
	@override late final _TranslationsFirstTimeSetupTh firstTimeSetup = _TranslationsFirstTimeSetupTh._(_root);
	@override late final _TranslationsProxyHelperTh proxyHelper = _TranslationsProxyHelperTh._(_root);
	@override late final _TranslationsTagSelectorTh tagSelector = _TranslationsTagSelectorTh._(_root);
	@override late final _TranslationsAnime4kTh anime4k = _TranslationsAnime4kTh._(_root);
	@override late final _TranslationsSiteModeTh siteMode = _TranslationsSiteModeTh._(_root);
	@override late final _TranslationsSavedSearchConfigTh savedSearchConfig = _TranslationsSavedSearchConfigTh._(_root);
	@override late final _TranslationsSavedSearchTh savedSearch = _TranslationsSavedSearchTh._(_root);
	@override late final _TranslationsDefaultBlacklistReminderTh defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderTh._(_root);
	@override late final _TranslationsColorVisionAssistTh colorVisionAssist = _TranslationsColorVisionAssistTh._(_root);
	@override late final _TranslationsExternalPlayerTh externalPlayer = _TranslationsExternalPlayerTh._(_root);
	@override late final _TranslationsWatchLaterTh watchLater = _TranslationsWatchLaterTh._(_root);
	@override late final _TranslationsMediaMenuTh mediaMenu = _TranslationsMediaMenuTh._(_root);
	@override late final _TranslationsMediaPreviewTh mediaPreview = _TranslationsMediaPreviewTh._(_root);
	@override late final _TranslationsPlaybackQueueTh playbackQueue = _TranslationsPlaybackQueueTh._(_root);
	@override late final _TranslationsVrFormatTh vrFormat = _TranslationsVrFormatTh._(_root);
	@override late final _TranslationsLocalMediaTh localMedia = _TranslationsLocalMediaTh._(_root);
	@override late final _TranslationsHistoryPageTh historyPage = _TranslationsHistoryPageTh._(_root);
	@override late final _TranslationsAiTh ai = _TranslationsAiTh._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileTh extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'ข้อมูลส่วนตัว';
	@override String get editPersonalProfile => 'แก้ไขข้อมูลส่วนตัว';
	@override String get avatar => 'รูปโปรไฟล์';
	@override String get background => 'พื้นหลัง';
	@override String fetchUserProfileFailed({required Object error}) => 'รับข้อมูลโปรไฟล์ผู้ใช้ล้มเหลว: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'ความละเอียดที่แนะนำ: ${resolution}, ขนาดไฟล์ < ${size}';
	@override String supportedFormats({required Object formats}) => 'รูปแบบที่รองรับ: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'ผู้ใช้พรีเมียมสามารถใช้ ${type} เคลื่อนไหวได้ (${formats})';
	@override String get homepageBackground => 'พื้นหลังหน้าแรก';
	@override String get basicInfo => 'ข้อมูลพื้นฐาน';
	@override String get nickname => 'ชื่อเล่น';
	@override String get username => 'ชื่อผู้ใช้';
	@override String get copyUsername => 'คัดลอกชื่อผู้ใช้';
	@override String get usernameCopied => 'คัดลอกชื่อผู้ใช้แล้ว';
	@override String get personalIntroduction => 'ประวัติส่วนตัว';
	@override String get noPersonalIntroduction => 'ไม่มีประวัติส่วนตัว';
	@override String get clickToEdit => 'แตะเพื่อแก้ไข';
	@override String get privacySettings => 'การตั้งค่าความเป็นส่วนตัว';
	@override String get hideSensitiveContent => 'ซ่อนเนื้อหาที่ละเอียดอ่อน';
	@override String get hideSensitiveContentDesc => 'ซ่อนวิดีโอหรือรูปภาพที่มีแท็กละเอียดอ่อน';
	@override String get notificationSettings => 'การตั้งค่าการแจ้งเตือน';
	@override String get contentCommentNotification => 'การแจ้งเตือนความคิดเห็นบนเนื้อหา';
	@override String get contentCommentNotificationDesc => 'แจ้งเตือนเมื่อมีคนแสดงความคิดเห็นบนเนื้อหาของคุณ';
	@override String get commentReplyNotification => 'การแจ้งเตือนการตอบกลับความคิดเห็น';
	@override String get commentReplyNotificationDesc => 'แจ้งเตือนเมื่อมีคนตอบกลับความคิดเห็นของคุณ';
	@override String get mentionNotification => 'การแจ้งเตือนการกล่าวถึง';
	@override String get mentionNotificationDesc => 'แจ้งเตือนเมื่อมีคนกล่าวถึงคุณในเนื้อหา';
	@override String get accountInfo => 'ข้อมูลบัญชี';
	@override String get registrationTime => 'เวลาลงทะเบียน';
	@override String updateSettingsFailed({required Object error}) => 'อัปเดตการตั้งค่าล้มเหลว: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'อัปเดตการตั้งค่าการแจ้งเตือนล้มเหลว: ${error}';
	@override String get editNickname => 'แก้ไขชื่อเล่น';
	@override String get nicknameCannotBeEmpty => 'ชื่อเล่นต้องไม่ว่างเปล่า';
	@override String get changeSuccess => 'เปลี่ยนแปลงสำเร็จ';
	@override String get unsupportedFileFormat => 'รูปแบบไฟล์ไม่รองรับ';
	@override String fileTooLarge({required Object size}) => 'ขนาดไฟล์ต้องไม่เกิน ${size}';
	@override String get uploadFailed => 'อัปโหลดล้มเหลว';
	@override String get avatarUpdatedSuccessfully => 'อัปเดตรูปโปรไฟล์สำเร็จ';
	@override String updateAvatarFailed({required Object error}) => 'อัปเดตรูปโปรไฟล์ล้มเหลว: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'อัปเดตพื้นหลังสำเร็จ';
	@override String updateBackgroundFailed({required Object error}) => 'อัปเดตพื้นหลังล้มเหลว: ${error}';
	@override String get editPersonalIntroduction => 'แก้ไขประวัติส่วนตัว';
	@override String get enterPersonalIntroduction => 'โปรดป้อนประวัติส่วนตัว';
}

// Path: tutorial
class _TranslationsTutorialTh extends TranslationsTutorialEn {
	_TranslationsTutorialTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'ติดตามพิเศษ';
	@override String get specialFollowDescription => 'ตั้งผู้สร้างที่คุณดูบ่อยเป็นติดตามพิเศษ เพื่อข้ามไปยังผลงานล่าสุดจากที่นี่ได้ทันที';
	@override String get stepsTitle => 'สามขั้นตอน';
	@override String get stepFollowAuthor => 'แตะติดตามในหน้าวิดีโอ แกลเลอรี หรือโปรไฟล์ของผู้สร้าง';
	@override String get stepPickSpecial => 'แตะติดตามแล้วอีกครั้ง จากนั้นเลือกติดตามพิเศษจากเมนู';
	@override String get stepSwitchHere => 'กลับมาที่นี่แล้วสลับไปยังผู้สร้างคนนั้นด้วยตัวเลือกรูปโปรไฟล์ด้านบน';
	@override String get specialFollowManagementTip => 'จัดการรายการติดตามพิเศษได้ที่ แถบด้านข้าง - รายการติดตาม - ติดตามพิเศษ';
	@override String get gotIt => 'เข้าใจแล้ว';
}

// Path: common
class _TranslationsCommonTh extends TranslationsCommonEn {
	_TranslationsCommonTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get sort => 'จัดเรียง';
	@override String get filter => 'ตัวกรอง';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'ตกลง';
	@override String get cancel => 'ยกเลิก';
	@override String get select => 'เลือก';
	@override String get save => 'บันทึก';
	@override String get delete => 'ลบ';
	@override String get visit => 'เยี่ยมชม';
	@override String get loading => 'กำลังโหลด...';
	@override String get scrollToTop => 'เลื่อนขึ้นด้านบน';
	@override String get privacyHint => 'เปิดโหมดความเป็นส่วนตัวอยู่ เนื้อหาถูกซ่อนไว้';
	@override String get latest => 'ล่าสุด';
	@override String get likesCount => 'ถูกใจ';
	@override String get viewsCount => 'การดู';
	@override String get popular => 'ยอดนิยม';
	@override String get trending => 'มาแรง';
	@override String get commentList => 'รายการความคิดเห็น';
	@override String get sendComment => 'ส่งความคิดเห็น';
	@override String get send => 'ส่ง';
	@override String get retry => 'ลองใหม่';
	@override String get premium => 'พรีเมียม';
	@override String get follower => 'ผู้ติดตาม';
	@override String get friend => 'เพื่อน';
	@override String get video => 'วิดีโอ';
	@override String get following => 'กำลังติดตาม';
	@override String get expand => 'ขยาย';
	@override String get collapse => 'ยุบ';
	@override String get cancelFriendRequest => 'ยกเลิกคำขอ';
	@override String get cancelSpecialFollow => 'ยกเลิกการติดตามพิเศษ';
	@override String get addFriend => 'เพิ่มเพื่อน';
	@override String get removeFriend => 'ลบเพื่อน';
	@override String get followed => 'ติดตามแล้ว';
	@override String get follow => 'ติดตาม';
	@override String get unfollow => 'เลิกติดตาม';
	@override String get specialFollow => 'ติดตามพิเศษ';
	@override String get specialFollowed => 'ติดตามพิเศษแล้ว';
	@override String get gallery => 'แกลเลอรี';
	@override String get playlist => 'เพลย์ลิสต์';
	@override String get commentPostedSuccessfully => 'โพสต์ความคิดเห็นสำเร็จ';
	@override String get commentPostedFailed => 'โพสต์ความคิดเห็นล้มเหลว';
	@override String get success => 'สำเร็จ';
	@override String get commentDeletedSuccessfully => 'ลบความคิดเห็นสำเร็จ';
	@override String get commentUpdatedSuccessfully => 'อัปเดตความคิดเห็นสำเร็จ';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} ความคิดเห็น',
		other: '${n} ความคิดเห็น',
	);
	@override String get writeYourCommentHere => 'เขียนความคิดเห็นของคุณที่นี่...';
	@override String get tmpNoReplies => 'ยังไม่มีการตอบกลับ';
	@override String get loadMore => 'โหลดเพิ่มเติม';
	@override String get loadingMore => 'กำลังโหลดเพิ่มเติม...';
	@override String get noMoreDatas => 'ไม่มีข้อมูลเพิ่มเติม';
	@override String get selectTranslationLanguage => 'เลือกภาษาที่ต้องการแปล';
	@override String get translate => 'แปล';
	@override String get translateFailedPleaseTryAgainLater => 'การแปลล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get translationResult => 'ผลการแปล';
	@override String get justNow => 'เมื่อสักครู่';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} นาทีที่แล้ว',
		other: '${n} นาทีที่แล้ว',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} ชั่วโมงที่แล้ว',
		other: '${n} ชั่วโมงที่แล้ว',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} วันที่แล้ว',
		other: '${n} วันที่แล้ว',
	);
	@override String editedAt({required Object num}) => 'แก้ไขเมื่อ ${num}';
	@override String get editComment => 'แก้ไขความคิดเห็น';
	@override String get commentUpdated => 'อัปเดตความคิดเห็นแล้ว';
	@override String get replyComment => 'ตอบกลับความคิดเห็น';
	@override String get reply => 'ตอบกลับ';
	@override String get edit => 'แก้ไข';
	@override String get unknownUser => 'ผู้ใช้ที่ไม่รู้จัก';
	@override String get me => 'ฉัน';
	@override String get author => 'ผู้สร้าง';
	@override String get admin => 'ผู้ดูแลระบบ';
	@override String viewReplies({required Object num}) => 'ดูการตอบกลับ (${num})';
	@override String get hideReplies => 'ซ่อนการตอบกลับ';
	@override String get confirmDelete => 'ยืนยันการลบ';
	@override String get areYouSureYouWantToDeleteThisItem => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?';
	@override String get tmpNoComments => 'ยังไม่มีความคิดเห็น';
	@override String get refresh => 'รีเฟรช';
	@override String get back => 'ย้อนกลับ';
	@override String get tips => 'เคล็ดลับ';
	@override String get linkIsEmpty => 'ลิงก์ว่างเปล่า';
	@override String get linkCopiedToClipboard => 'คัดลอกลิงก์ไปยังคลิปบอร์ดแล้ว';
	@override String get imageCopiedToClipboard => 'คัดลอกรูปภาพไปยังคลิปบอร์ดแล้ว';
	@override String get copyImageFailed => 'คัดลอกรูปภาพล้มเหลว';
	@override String get mobileSaveImageIsUnderDevelopment => 'ฟังก์ชันบันทึกรูปภาพบนมือถือกำลังพัฒนา';
	@override String get imageSavedTo => 'บันทึกรูปภาพไปที่';
	@override String get saveImageFailed => 'บันทึกรูปภาพล้มเหลว';
	@override String get close => 'ปิด';
	@override String get more => 'เพิ่มเติม';
	@override String get unknownError => 'ข้อผิดพลาดที่ไม่รู้จัก';
	@override String get moreFeaturesToBeDeveloped => 'ฟีเจอร์เพิ่มเติมอยู่ระหว่างการพัฒนา';
	@override String get all => 'ทั้งหมด';
	@override String selectedRecords({required Object num}) => 'เลือกแล้ว ${num} รายการ';
	@override String get cancelSelectAll => 'ยกเลิกการเลือกทั้งหมด';
	@override String get selectAll => 'เลือกทั้งหมด';
	@override String get invertSelection => 'สลับการเลือก';
	@override String get exitEditMode => 'ออกจากโหมดแก้ไข';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการที่เลือก ${num} รายการ?';
	@override String get searchHistoryRecords => 'ประวัติการค้นหา...';
	@override String get settings => 'การตั้งค่า';
	@override String get subscriptions => 'การติดตาม';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} วิดีโอ',
		other: '${n} วิดีโอ',
	);
	@override String get share => 'แชร์';
	@override String get areYouSureYouWantToShareThisPlaylist => 'คุณแน่ใจหรือไม่ว่าต้องการแชร์เพลย์ลิสต์นี้?';
	@override String get editTitle => 'แก้ไขชื่อเรื่อง';
	@override String get editMode => 'โหมดแก้ไข';
	@override String get pleaseEnterNewTitle => 'โปรดป้อนชื่อเรื่องใหม่';
	@override String get createPlayList => 'สร้างเพลย์ลิสต์';
	@override String get create => 'สร้าง';
	@override String get checkNetworkSettings => 'ตรวจสอบการตั้งค่าเครือข่าย';
	@override String get general => 'ทั่วไป';
	@override String get r18 => 'R18';
	@override String get sensitive => 'ละเอียดอ่อน';
	@override String get year => 'ปี';
	@override String get month => 'เดือน';
	@override String get tag => 'แท็ก';
	@override String get private => 'ส่วนตัว';
	@override String get noTitle => 'ไม่มีชื่อเรื่อง';
	@override String get search => 'ค้นหา';
	@override String get noContent => 'ไม่มีเนื้อหา';
	@override String get recording => 'กำลังบันทึก';
	@override String get paused => 'หยุดชั่วคราว';
	@override String get clear => 'ล้าง';
	@override String get clearSelection => 'ล้างการเลือก';
	@override String get selectItemsToContinue => 'เลือกรายการเพื่อดำเนินการต่อ';
	@override String andMoreItems({required Object num}) => 'และอีก ${num} รายการ';
	@override String get batchDelete => 'ลบเป็นชุด';
	@override String get user => 'ผู้ใช้';
	@override String get post => 'โพสต์';
	@override String get seconds => 'วินาที';
	@override String get comingSoon => 'เร็วๆ นี้';
	@override String get confirm => 'ยืนยัน';
	@override String get hour => 'ชั่วโมง';
	@override String get minute => 'นาที';
	@override String get clickToRefresh => 'แตะเพื่อรีเฟรช';
	@override String get history => 'ประวัติ';
	@override String get favorites => 'รายการโปรด';
	@override String get friends => 'เพื่อน';
	@override String get playList => 'เพลย์ลิสต์';
	@override String get checkLicense => 'ตรวจสอบใบอนุญาต';
	@override String get logout => 'ออกจากระบบ';
	@override String get fensi => 'แฟนๆ';
	@override String get accept => 'ยอมรับ';
	@override String get reject => 'ปฏิเสธ';
	@override String get clearAllHistory => 'ล้างประวัติทั้งหมด';
	@override String get clearAllHistoryConfirm => 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติทั้งหมด?';
	@override String get followingList => 'รายชื่อที่กำลังติดตาม';
	@override String get followersList => 'รายชื่อผู้ติดตาม';
	@override String get follows => 'การติดตาม';
	@override String get fans => 'แฟนๆ';
	@override String get followsAndFans => 'การติดตามและแฟนๆ';
	@override String get numViews => 'การดู';
	@override String get updatedAt => 'อัปเดตเมื่อ';
	@override String get publishedAt => 'เผยแพร่เมื่อ';
	@override String get externalVideo => 'วิดีโอภายนอก';
	@override String get originalText => 'ข้อความต้นฉบับ';
	@override String get showOriginalText => 'แสดงข้อความต้นฉบับ';
	@override String get showProcessedText => 'แสดงข้อความที่ประมวลผลแล้ว';
	@override String get preview => 'ตัวอย่าง';
	@override String get rules => 'กฎระเบียบ';
	@override String get agree => 'ยอมรับ';
	@override String get disagree => 'ไม่ยอมรับ';
	@override String get agreeToRules => 'ยอมรับกฎระเบียบ';
	@override String get tapToReread => 'แตะเพื่ออ่านอีกครั้ง';
	@override String get markdownSyntaxHelp => 'วิธีใช้ไวยากรณ์ Markdown';
	@override String get previewContent => 'แสดงตัวอย่างเนื้อหา';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'ความยาวเกินขีดจำกัดสูงสุด (${max})';
	@override String get agreeToCommunityRules => 'ยอมรับกฎของชุมชน';
	@override String get createPost => 'สร้างโพสต์';
	@override String get title => 'ชื่อเรื่อง';
	@override String get enterTitle => 'โปรดป้อนชื่อเรื่อง';
	@override String get content => 'เนื้อหา';
	@override String get enterContent => 'โปรดป้อนเนื้อหา';
	@override String get writeYourContentHere => 'โปรดป้อนเนื้อหาที่นี่...';
	@override String get tagBlacklist => 'บัญชีดำแท็ก';
	@override String get noData => 'ไม่มีข้อมูล';
	@override String get tagLimit => 'ขีดจำกัดแท็ก';
	@override String get enableFloatingButtons => 'เปิดใช้ปุ่มลอย';
	@override String get disableFloatingButtons => 'ปิดใช้ปุ่มลอย';
	@override String get enabledFloatingButtons => 'เปิดใช้งานปุ่มลอยแล้ว';
	@override String get disabledFloatingButtons => 'ปิดใช้งานปุ่มลอยแล้ว';
	@override String get pendingCommentCount => 'จำนวนความคิดเห็นที่รอดำเนินการ';
	@override String joined({required Object str}) => 'เข้าร่วมเมื่อ ${str}';
	@override String lastSeenAt({required Object str}) => 'เห็นล่าสุด ${str}';
	@override String get download => 'ดาวน์โหลด';
	@override String get selectQuality => 'เลือกคุณภาพ';
	@override String get videoQualitySource => 'ต้นฉบับ';
	@override String get selectImageQuality => 'เลือกคุณภาพของรูปภาพ';
	@override String get imageQualityStandard => 'มาตรฐาน';
	@override String get imageQualityOriginal => 'ต้นฉบับ';
	@override String get selectDateRange => 'เลือกช่วงวันที่';
	@override String get selectDateRangeHint => 'เลือกช่วงวันที่ ค่าเริ่มต้นคือ 30 วันที่ผ่านมา';
	@override String get clearDateRange => 'ล้างช่วงวันที่';
	@override String get deleteRecordsInDateRange => 'ลบบันทึกในช่วงนี้';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบบันทึกประวัติ ${num} รายการในช่วงนี้? การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String get noHistoryRecordsInRange => 'ไม่มีบันทึกประวัติในช่วงนี้';
	@override String get followSuccessClickAgainToSpecialFollow => 'ติดตามสำเร็จแล้ว แตะอีกครั้งเพื่อติดตามพิเศษ';
	@override String get specialFollowTip => 'เพิ่มในรายการติดตามพิเศษแล้ว — เลือกได้จากเมนูด้านขวาบนของหน้าการติดตามเพื่อเข้าถึงอย่างรวดเร็ว';
	@override String get exitConfirmTip => 'คุณแน่ใจหรือไม่ว่าต้องการออก?';
	@override String get error => 'ข้อผิดพลาด';
	@override String get taskRunning => 'มีงานกำลังทำงานอยู่ โปรดรอสักครู่';
	@override String get operationCancelled => 'การดำเนินการถูกยกเลิก';
	@override String get unsavedChanges => 'คุณมีการเปลี่ยนแปลงที่ยังไม่ได้บันทึก';
	@override String get specialFollowsManagementTip => 'ลากที่จับเพื่อจัดลำดับใหม่ • แตะปุ่มเพื่อลบออก';
	@override String get specialFollowsManagement => 'การจัดการการติดตามพิเศษ';
	@override String get removeSpecialFollow => 'ลบการติดตามพิเศษ';
	@override String removeSpecialFollowConfirm({required Object name}) => 'ลบ ${name} ออกจากการติดตามพิเศษหรือไม่?';
	@override String get noSpecialFollows => 'ยังไม่มีการติดตามพิเศษ';
	@override String get createTimeDesc => 'เรียงตามเวลาสร้างจากใหม่ไปเก่า';
	@override String get createTimeAsc => 'เรียงตามเวลาสร้างจากเก่าไปใหม่';
	@override late final _TranslationsCommonPaginationTh pagination = _TranslationsCommonPaginationTh._(_root);
	@override String get notice => 'ประกาศ';
	@override String get detail => 'รายละเอียด';
	@override String get parseExceptionDestopHint => ' - ผู้ใช้เดสก์ท็อปสามารถกำหนดค่าพร็อกซีได้ในการตั้งค่า';
	@override String get iwaraTags => 'แท็ก Iwara';
	@override String get tagInfo => 'ข้อมูลแท็ก';
	@override String get tagOriginalKey => 'แท็กต้นฉบับ';
	@override String get tagTranslation => 'คำแปล';
	@override String get copy => 'คัดลอก';
	@override String get selectCopy => 'เลือกและคัดลอก';
	@override String get copiedToClipboard => 'คัดลอกไปยังคลิปบอร์ดแล้ว';
	@override String get showOriginalTag => 'แสดงแท็กต้นฉบับ';
	@override String get showTranslatedTag => 'แสดงคำแปล';
	@override String get tagTranslationFeedback => 'มีข้อสงสัยเกี่ยวกับคำแปลหรือไม่? ส่งคำติชม';
	@override String get tagLocalizationGuideTitle => 'เกี่ยวกับการแปลแท็ก';
	@override String get tagLocalizationGuideContent => 'แอปจะแสดงแท็กดิบของ Iwara (เช่น mother) โดยใช้ชื่อในภาษาปัจจุบันของคุณ\n\n• เมื่อค้นหาแท็ก ระบบจะจับคู่ทั้งคำแปลและแท็กต้นฉบับ\n• แตะค้าง / คลิกขวาที่แท็กเพื่อดูและคัดลอกคีย์ต้นฉบับและคำแปล\n• คำแปลได้รับการดูแลโดยชุมชนตามความสามารถ — อาจมีข้อผิดพลาดได้';
	@override String get likeThisVideo => 'ถูกใจวิดีโอนี้';
	@override String get likeThisGallery => 'ถูกใจแกลเลอรีนี้';
	@override String get operation => 'การดำเนินการ';
	@override String get replies => 'การตอบกลับ';
	@override String get externalLinkWarning => 'คำเตือนลิงก์ภายนอก';
	@override String get externalLinkWarningMessage => 'คุณกำลังจะเปิดลิงก์ภายนอกที่ไม่ได้เป็นส่วนหนึ่งของ iwara.tv โปรดใช้ความระมัดระวังและตรวจสอบให้แน่ใจว่าลิงก์ปลอดภัยก่อนดำเนินการต่อ';
	@override String get continueToExternalLink => 'ดำเนินการต่อ';
	@override String get cancelExternalLink => 'ยกเลิก';
}

// Path: auth
class _TranslationsAuthTh extends TranslationsAuthEn {
	_TranslationsAuthTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get login => 'เข้าสู่ระบบ';
	@override String get logout => 'ออกจากระบบ';
	@override String get email => 'อีเมล';
	@override String get password => 'รหัสผ่าน';
	@override String get loginOrRegister => 'เข้าสู่ระบบ / ลงทะเบียน';
	@override String get register => 'ลงทะเบียน';
	@override String get pleaseEnterEmail => 'โปรดป้อนอีเมล';
	@override String get pleaseEnterPassword => 'โปรดป้อนรหัสผ่าน';
	@override String get passwordMustBeAtLeast6Characters => 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
	@override String get pleaseEnterCaptcha => 'โปรดป้อนรหัสยืนยัน';
	@override String get captcha => 'รหัสยืนยัน';
	@override String get refreshCaptcha => 'รีเฟรชรหัสยืนยัน';
	@override String get captchaNotLoaded => 'ยังไม่ได้โหลดรหัสยืนยัน';
	@override String get loginSuccess => 'เข้าสู่ระบบสำเร็จ';
	@override String get loginSuccessProfilePending => 'เข้าสู่ระบบแล้ว กำลังโหลดโปรไฟล์ของคุณ…';
	@override String get emailVerificationSent => 'ส่งอีเมลยืนยันแล้ว';
	@override String get notLoggedIn => 'ยังไม่ได้เข้าสู่ระบบ';
	@override String get clickToLogin => 'แตะเพื่อเข้าสู่ระบบ';
	@override String get logoutConfirmation => 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?';
	@override String get logoutSuccess => 'ออกจากระบบสำเร็จ';
	@override String get logoutFailed => 'ออกจากระบบล้มเหลว';
	@override String get usernameOrEmail => 'ชื่อผู้ใช้หรืออีเมล';
	@override String get pleaseEnterUsernameOrEmail => 'โปรดป้อนชื่อผู้ใช้หรืออีเมล';
	@override String get rememberMe => 'จำชื่อผู้ใช้';
	@override String get registerNoticeTitle => 'ลงทะเบียนบนเว็บไซต์ทางการ';
	@override String get registerNoticeDescription => 'ไม่รองรับการลงทะเบียนในแอปแล้ว โปรดไปที่เว็บไซต์ทางการของ Iwara เพื่อสร้างบัญชีของคุณ จากนั้นกลับมาเข้าสู่ระบบที่นี่';
	@override String get registerNoticeReturnTip => 'หลังจากลงทะเบียนแล้ว ให้กลับมาที่นี่และเข้าสู่ระบบด้วยบัญชีของคุณ';
	@override String get goToOfficialWebsite => 'ไปยังเว็บไซต์ทางการ';
}

// Path: errors
class _TranslationsErrorsTh extends TranslationsErrorsEn {
	_TranslationsErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get error => 'ข้อผิดพลาด';
	@override String get required => 'ฟิลด์นี้จำเป็นต้องกรอก';
	@override String get invalidEmail => 'ที่อยู่อีเมลไม่ถูกต้อง';
	@override String get networkError => 'เครือข่ายผิดพลาด โปรดลองใหม่อีกครั้ง';
	@override String get errorWhileFetching => 'เกิดข้อผิดพลาดขณะดึงข้อมูล';
	@override String get commentCanNotBeEmpty => 'เนื้อหาความคิดเห็นต้องไม่ว่างเปล่า';
	@override String get errorWhileFetchingReplies => 'เกิดข้อผิดพลาดขณะดึงการตอบกลับ โปรดตรวจสอบการเชื่อมต่อเครือข่าย';
	@override String get canNotFindCommentController => 'ไม่พบคอนโทรลเลอร์ความคิดเห็น';
	@override String get errorWhileLoadingGallery => 'เกิดข้อผิดพลาดขณะโหลดแกลเลอรี';
	@override String get howCouldThereBeNoDataItCantBePossible => 'ไม่มีข้อมูลได้อย่างไร? เป็นไปไม่ได้ :<';
	@override String unsupportedImageFormat({required Object str}) => 'รูปแบบรูปภาพไม่รองรับ: ${str}';
	@override String get invalidGalleryId => 'รหัสแกลเลอรีไม่ถูกต้อง';
	@override String get translationFailedPleaseTryAgainLater => 'การแปลล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get errorOccurred => 'เกิดข้อผิดพลาด โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get errorOccurredWhileProcessingRequest => 'เกิดข้อผิดพลาดขณะประมวลผลคำขอ';
	@override String get errorWhileFetchingDatas => 'เกิดข้อผิดพลาดขณะดึงข้อมูล โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get serviceNotInitialized => 'ยังไม่ได้เริ่มต้นบริการ';
	@override String get unknownType => 'ประเภทที่ไม่รู้จัก';
	@override String errorWhileOpeningLink({required Object link}) => 'เกิดข้อผิดพลาดขณะเปิดลิงก์: ${link}';
	@override String get invalidUrl => 'URL ไม่ถูกต้อง';
	@override String get failedToOperate => 'ดำเนินการล้มเหลว';
	@override String get permissionDenied => 'การอนุญาตถูกปฏิเสธ';
	@override String get youDoNotHavePermissionToAccessThisResource => 'คุณไม่มีสิทธิ์เข้าถึงทรัพยากรนี้';
	@override String get loginFailed => 'เข้าสู่ระบบล้มเหลว';
	@override String get unknownError => 'ข้อผิดพลาดที่ไม่รู้จัก';
	@override String get sessionExpired => 'เซสชันหมดอายุ';
	@override String get failedToFetchCaptcha => 'ดึงรหัสยืนยันล้มเหลว';
	@override String get emailAlreadyExists => 'อีเมลนี้มีอยู่แล้ว';
	@override String get invalidCaptcha => 'รหัสยืนยันไม่ถูกต้อง';
	@override String get registerFailed => 'ลงทะเบียนล้มเหลว';
	@override String get failedToFetchComments => 'ดึงความคิดเห็นล้มเหลว';
	@override String get failedToFetchImageDetail => 'ดึงรายละเอียดรูปภาพล้มเหลว';
	@override String get failedToFetchImageList => 'ดึงรายการรูปภาพล้มเหลว';
	@override String get failedToFetchData => 'ดึงข้อมูลล้มเหลว';
	@override String get invalidParameter => 'พารามิเตอร์ไม่ถูกต้อง';
	@override String get pleaseLoginFirst => 'โปรดเข้าสู่ระบบก่อน';
	@override String get errorWhileLoadingPost => 'เกิดข้อผิดพลาดขณะโหลดโพสต์';
	@override String get errorWhileLoadingPostDetail => 'เกิดข้อผิดพลาดขณะโหลดรายละเอียดโพสต์';
	@override String get invalidPostId => 'รหัสโพสต์ไม่ถูกต้อง';
	@override String get forceUpdateNotPermittedToGoBack => 'อยู่ในสถานะบังคับอัปเดต ไม่สามารถย้อนกลับได้';
	@override String get pleaseLoginAgain => 'โปรดเข้าสู่ระบบอีกครั้ง';
	@override String get invalidLogin => 'การเข้าสู่ระบบไม่ถูกต้อง โปรดตรวจสอบอีเมลและรหัสผ่านของคุณ';
	@override String get tooManyRequests => 'มีคำขอมากเกินไป โปรดลองใหม่ในภายหลัง';
	@override String exceedsMaxLength({required Object max}) => 'ความยาวเกินกำหนด: ${max}';
	@override String get contentCanNotBeEmpty => 'เนื้อหาต้องไม่ว่างเปล่า';
	@override String get titleCanNotBeEmpty => 'ชื่อเรื่องต้องไม่ว่างเปล่า';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'มีคำขอมากเกินไป โปรดลองใหม่ในภายหลัง เหลือเวลาอีก';
	@override String remainingHours({required Object num}) => '${num} ชั่วโมง';
	@override String remainingMinutes({required Object num}) => '${num} นาที';
	@override String remainingSeconds({required Object num}) => '${num} วินาที';
	@override String tagLimitExceeded({required Object limit}) => 'แท็กเกินขีดจำกัด ขีดจำกัดคือ: ${limit}';
	@override String get failedToRefresh => 'รีเฟรชล้มเหลว';
	@override String get noPermission => 'ไม่มีสิทธิ์';
	@override String get resourceNotFound => 'ไม่พบทรัพยากร';
	@override String get failedToSaveCredentials => 'บันทึกข้อมูลการเข้าสู่ระบบล้มเหลว';
	@override String get failedToLoadSavedCredentials => 'โหลดข้อมูลการเข้าสู่ระบบที่บันทึกไว้ล้มเหลว';
	@override String get notFound => 'ไม่พบเนื้อหาหรือเนื้อหาถูกลบไปแล้ว';
	@override late final _TranslationsErrorsNetworkTh network = _TranslationsErrorsNetworkTh._(_root);
}

// Path: friends
class _TranslationsFriendsTh extends TranslationsFriendsEn {
	_TranslationsFriendsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'แตะเพื่อคืนค่าเพื่อน';
	@override String get friendsList => 'รายชื่อเพื่อน';
	@override String get friendRequests => 'คำขอเป็นเพื่อน';
	@override String get friendRequestsList => 'รายการคำขอเป็นเพื่อน';
	@override String get removingFriend => 'กำลังลบเพื่อน...';
	@override String get failedToRemoveFriend => 'ลบเพื่อนล้มเหลว';
	@override String get cancelingRequest => 'กำลังยกเลิกคำขอเป็นเพื่อน...';
	@override String get failedToCancelRequest => 'ยกเลิกคำขอเป็นเพื่อนล้มเหลว';
}

// Path: authorProfile
class _TranslationsAuthorProfileTh extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'ไม่มีข้อมูลเพิ่มเติม';
	@override String get userProfile => 'โปรไฟล์ผู้ใช้';
}

// Path: favorites
class _TranslationsFavoritesTh extends TranslationsFavoritesEn {
	_TranslationsFavoritesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'แตะเพื่อคืนค่ารายการโปรด';
	@override String get myFavorites => 'รายการโปรดของฉัน';
	@override String get batchCancelFavorite => 'ลบรายการโปรดที่เลือก';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'ต้องการลบ ${count} รายการที่เลือกออกจากรายการโปรดหรือไม่? คุณสามารถคืนค่าได้โดยแตะที่การ์ดในภายหลัง';
	@override String batchCancelFavoriteSuccess({required Object count}) => 'ลบ ${count} รายการออกจากรายการโปรดแล้ว';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => 'ลบออกแล้ว ${success} รายการ ล้มเหลว ${failed} รายการ';
}

// Path: galleryDetail
class _TranslationsGalleryDetailTh extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'เรียกดูในพื้นที่เสมือน';
	@override String get galleryDetail => 'รายละเอียดแกลเลอรี';
	@override String get viewGalleryDetail => 'ดูรายละเอียดแกลเลอรี';
	@override String get zoomReset => 'รีเซ็ตการซูม';
	@override String get copyLink => 'คัดลอกลิงก์';
	@override String get copyImage => 'คัดลอกรูปภาพ';
	@override String get saveAs => 'บันทึกเป็น';
	@override String get saveToAlbum => 'บันทึกลงอัลบั้ม';
	@override String get publishedAt => 'เผยแพร่เมื่อ';
	@override String get viewsCount => 'จำนวนการดู';
	@override String get imageLibraryFunctionIntroduction => 'แนะนำฟังก์ชันคลังภาพ';
	@override String get rightClickToSaveSingleImage => 'คลิกขวาเพื่อบันทึกรูปภาพเดี่ยว';
	@override String get batchSave => 'บันทึกเป็นชุด';
	@override String get keyboardLeftAndRightToSwitch => 'ใช้ปุ่มซ้ายและขวาบนคีย์บอร์ดเพื่อสลับ';
	@override String get keyboardUpAndDownToZoom => 'ใช้ปุ่มขึ้นและลงบนคีย์บอร์ดเพื่อซูม';
	@override String get mouseWheelToSwitch => 'ใช้ล้อเลื่อนเมาส์เพื่อสลับ';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + ล้อเลื่อนเมาส์เพื่อซูม';
	@override String get moreFeaturesToBeDiscovered => 'ฟีเจอร์เพิ่มเติมรอให้คุณค้นพบ...';
	@override String get authorOtherGalleries => 'แกลเลอรีอื่นของผู้สร้าง';
	@override String get relatedGalleries => 'แกลเลอรีที่เกี่ยวข้อง';
	@override String get authorNoOtherGalleries => 'ไม่มีแกลเลอรีอื่นจากผู้สร้างคนนี้';
	@override String get noRelatedGalleries => 'ไม่มีแกลเลอรีที่เกี่ยวข้อง';
	@override String get scrollLeft => 'เลื่อนไปทางซ้าย';
	@override String get scrollRight => 'เลื่อนไปทางขวา';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'แตะขอบซ้ายและขวาเพื่อสลับรูปภาพ';
	@override String get rotateToLandscape => 'แนวนอนเต็มจอ';
	@override String get backToPortrait => 'กลับสู่แนวตั้ง';
}

// Path: playList
class _TranslationsPlayListTh extends TranslationsPlayListEn {
	_TranslationsPlayListTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'เพลย์ลิสต์ของฉัน';
	@override String get friendlyTips => 'คำแนะนำที่เป็นประโยชน์';
	@override String get dearUser => 'ผู้ใช้ที่เคารพ';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'ระบบเพลย์ลิสต์ของ Iwara ยังไม่สมบูรณ์ในขณะนี้';
	@override String get notSupportSetCover => 'ไม่รองรับการตั้งค่าภาพหน้าปก';
	@override String get notSupportDeleteList => 'ไม่รองรับการลบเพลย์ลิสต์';
	@override String get notSupportSetPrivate => 'ไม่รองรับการตั้งเป็นส่วนตัว';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'ใช่แล้ว... เพลย์ลิสต์ที่สร้างขึ้นจะคงอยู่ถาวรและทุกคนสามารถมองเห็นได้';
	@override String get smallSuggestion => 'คำแนะนำเล็กน้อย';
	@override String get useLikeToCollectContent => 'หากคุณให้ความสำคัญกับความเป็นส่วนตัว ขอแนะนำให้ใช้ฟังก์ชัน "ถูกใจ" เพื่อบันทึกเนื้อหา';
	@override String get welcomeToDiscussOnGitHub => 'หากคุณมีข้อเสนอแนะหรือความคิดเห็นอื่นๆ ยินดีต้อนรับสู่การพูดคุยบน GitHub!';
	@override String get iUnderstand => 'ฉันเข้าใจแล้ว';
	@override String get searchPlaylists => 'ค้นหาเพลย์ลิสต์...';
	@override String get newPlaylistName => 'ชื่อเพลย์ลิสต์ใหม่';
	@override String get createNewPlaylist => 'สร้างเพลย์ลิสต์ใหม่';
	@override String get videos => 'วิดีโอ';
}

// Path: search
class _TranslationsSearchTh extends TranslationsSearchEn {
	_TranslationsSearchTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'ขอบเขตการค้นหา';
	@override String get searchTags => 'ค้นหาแท็ก...';
	@override String get contentRating => 'การจัดระดับเนื้อหา';
	@override String get removeTag => 'ลบแท็ก';
	@override String get pleaseEnterSearchContent => 'โปรดป้อนเนื้อหาที่จะค้นหา';
	@override String get exactMatch => 'ตรงทุกคำ';
	@override String get exactMatchOnHint => 'กำลังจับคู่ทั้งวลีแบบตรงทุกคำ และค้นหาชื่อเรื่องภาษาจีนกับญี่ปุ่นด้วย แตะเพื่อค้นแบบกว้างขึ้น';
	@override String get exactMatchOffHint => 'จับคู่แบบหลวม — Iwara จะแยกคำออก แตะเพื่อจับคู่ทั้งวลีแบบตรงทุกคำ';
	@override String get searchHistory => 'ประวัติการค้นหา';
	@override String get searchSuggestion => 'คำแนะนำการค้นหา';
	@override String get usedTimes => 'จำนวนครั้งที่ใช้';
	@override String get lastUsed => 'ใช้งานล่าสุด';
	@override String get noSearchHistoryRecords => 'ไม่มีประวัติการค้นหา';
	@override String get clearSearchHistoryConfirm => 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติการค้นหาทั้งหมด? การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'ยังไม่รองรับประเภทการค้นหา ${searchType} ในปัจจุบัน โปรดรอการอัปเดต';
	@override String get searchResult => 'ผลการค้นหา';
	@override String unsupportedSearchType({required Object searchType}) => 'ไม่รองรับประเภทการค้นหา: ${searchType}';
	@override String get googleSearch => 'ค้นหาด้วย Google';
	@override String googleSearchHint({required Object webName}) => 'ฟังก์ชันการค้นหาของ ${webName} ใช้งานยากใช่ไหม? ลองใช้การค้นหาด้วย Google!';
	@override String get googleSearchDescription => 'ใช้ตัวดำเนินการค้นหา :site ของ Google เพื่อค้นหาเนื้อหาภายในเว็บไซต์ ซึ่งมีประโยชน์มากเมื่อค้นหาวิดีโอ แกลเลอรี เพลย์ลิสต์ และผู้ใช้';
	@override String get googleSearchKeywordsHint => 'ป้อนคำค้นหา';
	@override String get openLinkJump => 'เปิดลิงก์เพื่อข้ามไป';
	@override String get googleSearchButton => 'ค้นหาด้วย Google';
	@override String get pleaseEnterSearchKeywords => 'โปรดป้อนคำค้นหา';
	@override String get googleSearchQueryCopied => 'คัดลอกคำค้นหาไปยังคลิปบอร์ดแล้ว';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'เปิดเบราว์เซอร์ล้มเหลว: ${error}';
	@override String get searchRequestTimeout => 'หมดเวลาคำขอ โปรดลองใหม่ในภายหลัง';
	@override String get searchCannotConnectToServer => 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่อเครือข่ายของคุณ';
	@override String get searchNetworkError => 'การเชื่อมต่อเครือข่ายล้มเหลว โปรดตรวจสอบการตั้งค่าเครือข่ายหรือลองใหม่ในภายหลัง';
	@override String get searchFailedPleaseRetry => 'การค้นหาล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
}

// Path: mediaList
class _TranslationsMediaListTh extends TranslationsMediaListEn {
	_TranslationsMediaListTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'ข้อมูลเบื้องต้น';
}

// Path: settings
class _TranslationsSettingsTh extends TranslationsSettingsEn {
	_TranslationsSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'โหมดมุมมองรายการ';
	@override String get previewEffect => 'เอฟเฟกต์แสดงตัวอย่าง';
	@override String get useTraditionalPaginationMode => 'ใช้โหมดแบ่งหน้าแบบดั้งเดิม';
	@override String get useTraditionalPaginationModeDesc => 'เปิดใช้โหมดแบ่งหน้าแบบดั้งเดิม และปิดโหมดน้ำตก จะมีผลหลังจากเรนเดอร์หน้าใหม่หรือรีสตาร์ตแอป';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'แสดงแถบความคืบหน้าวิดีโอด้านล่างเมื่อแถบเครื่องมือถูกซ่อน';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'การกำหนดค่านี้กำหนดว่าจะแสดงแถบความคืบหน้าวิดีโอด้านล่างเมื่อแถบเครื่องมือถูกซ่อนหรือไม่';
	@override String get seekPreviewSize => 'ขนาดหน้าต่างแสดงตัวอย่างการเลื่อน';
	@override String get seekPreviewSizeDesc => 'ขนาดของหน้าต่างแสดงตัวอย่างเหนือแถบความคืบหน้า โดยปกติจะปรับตามขนาดของเครื่องเล่นและอัตราส่วนของวิดีโออยู่แล้ว ค่านี้ใช้เพื่อปรับเพิ่มลดเล็กน้อย';
	@override String get seekPreviewSizeSmall => 'เล็ก';
	@override String get seekPreviewSizeStandard => 'มาตรฐาน';
	@override String get seekPreviewSizeLarge => 'ใหญ่';
	@override String get seekPreviewSizeStandardDesc => 'ขนาดที่คำนวณจากเครื่องเล่นและวิดีโอ';
	@override String get showFullscreenUpNextHint => 'แสดงที่จับ "เล่นต่อไป"';
	@override String get showFullscreenUpNextHintDesc => 'แสดงที่จับเล็กๆ ที่ขอบขวาของเครื่องเล่นเพื่อเปิดลิ้นชักคิว (แหล่งที่มา / เพลย์ลิสต์ / ดูภายหลัง) หากปิดจะไม่มีทางเข้าอื่นอีก';
	@override String get basicSettings => 'การตั้งค่าพื้นฐาน';
	@override String get personalizedSettings => 'การตั้งค่าส่วนบุคคล';
	@override String get otherSettings => 'การตั้งค่าอื่นๆ';
	@override String get searchConfig => 'การกำหนดค่าการค้นหา';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'การกำหนดค่านี้กำหนดว่าจะใช้การกำหนดค่าก่อนหน้าซ้ำหรือไม่เมื่อเล่นวิดีโออีกครั้ง';
	@override String get playControl => 'การควบคุมการเล่น';
	@override String get playbackSpeedSettings => 'การเล่นและความเร็ว';
	@override String get playbackBehaviorSettings => 'พฤติกรรมการเล่น';
	@override String get enhancementSettings => 'โหมดโรงภาพยนตร์และการเพิ่มประสิทธิภาพ';
	@override String get fastForwardTime => 'เวลาเดินหน้าอย่างเร็ว';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'เวลาเดินหน้าอย่างเร็วต้องเป็นจำนวนเต็มบวก';
	@override String get rewindTime => 'เวลาย้อนกลับ';
	@override String get rewindTimeMustBeAPositiveInteger => 'เวลาย้อนกลับต้องเป็นจำนวนเต็มบวก';
	@override String get longPressPlaybackSpeed => 'ความเร็วการเล่นเมื่อกดค้าง';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'ความเร็วการเล่นเมื่อกดค้างต้องเป็นตัวเลขบวก';
	@override String get defaultPlaybackSpeed => 'ความเร็วการเล่นเริ่มต้น';
	@override String get rememberPlaybackSpeed => 'จำความเร็วการเล่น';
	@override String get rememberPlaybackSpeedDesc => 'เมื่อเปิดใช้งาน ความเร็วที่คุณตั้งในเครื่องเล่นจะถูกบันทึกเป็นค่าเริ่มต้นและใช้กับวิดีโอใหม่โดยอัตโนมัติ';
	@override String get repeat => 'เล่นซ้ำ';
	@override String get renderVerticalVideoInVerticalScreen => 'แสดงผลวิดีโอแนวตั้งในโหมดแนวตั้ง';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'การกำหนดค่านี้กำหนดว่าจะแสดงผลวิดีโอในโหมดแนวตั้งหรือไม่เมื่อเล่นแบบเต็มหน้าจอ';
	@override String get rememberVolume => 'จำระดับเสียง';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'การกำหนดค่านี้กำหนดว่าจะรักษาระดับเสียงไว้หรือไม่เมื่อเล่นวิดีโออีกครั้ง';
	@override String get rememberBrightness => 'จำความสว่าง';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'การกำหนดค่านี้กำหนดว่าจะรักษาความสว่างไว้หรือไม่เมื่อเล่นวิดีโออีกครั้ง';
	@override String get playControlArea => 'พื้นที่ควบคุมการเล่น';
	@override String get leftAndRightControlAreaWidth => 'ความกว้างของพื้นที่ควบคุมซ้ายและขวา';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'การกำหนดค่านี้กำหนดความกว้างของพื้นที่ควบคุมทางด้านซ้ายและขวาของเครื่องเล่น';
	@override String get proxyAddressCannotBeEmpty => 'ที่อยู่พร็อกซีต้องไม่ว่างเปล่า';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'รูปแบบที่อยู่พร็อกซีไม่ถูกต้อง โปรดใช้รูปแบบ IP:พอร์ต หรือ ชื่อโดเมน:พอร์ต';
	@override String get proxyNormalWork => 'พร็อกซีทำงานปกติ';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'ทดสอบพร็อกซีล้มเหลว รหัสสถานะ: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'ทดสอบพร็อกซีล้มเหลว ข้อผิดพลาด: ${exception}';
	@override String get proxyConfig => 'การกำหนดค่าพร็อกซี';
	@override String get thisIsHttpProxyAddress => 'นี่คือที่อยู่ HTTP พร็อกซี';
	@override String get checkProxy => 'ตรวจสอบพร็อกซี';
	@override String get proxyAddress => 'ที่อยู่พร็อกซี';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'โปรดป้อน URL ของเซิร์ฟเวอร์พร็อกซี เช่น 127.0.0.1:8080';
	@override String get enableProxy => 'เปิดใช้พร็อกซี';
	@override String get left => 'ซ้าย';
	@override String get middle => 'กลาง';
	@override String get right => 'ขวา';
	@override String get playerSettings => 'การตั้งค่าเครื่องเล่น';
	@override String get networkSettings => 'การตั้งค่าเครือข่าย';
	@override String get customizeYourPlaybackExperience => 'ปรับแต่งประสบการณ์การเล่นของคุณ';
	@override String get chooseYourFavoriteAppAppearance => 'เลือกรูปลักษณ์ของแอปที่คุณชื่นชอบ';
	@override String get configureYourProxyServer => 'กำหนดค่าเซิร์ฟเวอร์พร็อกซีของคุณ';
	@override String get settings => 'การตั้งค่า';
	@override String get themeSettings => 'การตั้งค่าธีม';
	@override String get followSystem => 'ตามระบบ';
	@override String get lightMode => 'โหมดสว่าง';
	@override String get darkMode => 'โหมดมืด';
	@override String get presetTheme => 'ธีมที่ตั้งไว้ล่วงหน้า';
	@override String get basicTheme => 'ธีมพื้นฐาน';
	@override String get needRestartToApply => 'จำเป็นต้องรีสตาร์ตแอปเพื่อใช้การตั้งค่า';
	@override String get themeNeedRestartDescription => 'การตั้งค่าธีมจำเป็นต้องรีสตาร์ตแอปเพื่อให้มีผล';
	@override String get about => 'เกี่ยวกับ';
	@override String get diagnosticsAndFeedback => 'การวินิจฉัยและคำติชม';
	@override String get currentVersion => 'เวอร์ชันปัจจุบัน';
	@override String get latestVersion => 'เวอร์ชันล่าสุด';
	@override String get checkForUpdates => 'ตรวจสอบการอัปเดต';
	@override String get update => 'อัปเดต';
	@override String get newVersionAvailable => 'มีเวอร์ชันใหม่พร้อมใช้งาน';
	@override String get projectHome => 'หน้าแรกของโปรเจกต์';
	@override String get release => 'การเผยแพร่';
	@override String get issueReport => 'รายงานปัญหา';
	@override String get openSourceLicense => 'ใบอนุญาตโอเพนซอร์ส';
	@override String get checkForUpdatesFailed => 'ตรวจสอบการอัปเดตล้มเหลว โปรดลองอีกครั้งในภายหลัง';
	@override String get autoCheckUpdate => 'ตรวจสอบการอัปเดตอัตโนมัติ';
	@override String get updateContent => 'เนื้อหาการอัปเดต';
	@override String get releaseDate => 'วันที่เผยแพร่';
	@override String get ignoreThisVersion => 'ข้ามเวอร์ชันนี้';
	@override String get forceUpdateTip => 'นี่คือการอัปเดตที่จำเป็น โปรดอัปเดตเป็นเวอร์ชันล่าสุดโดยเร็วที่สุด';
	@override String get viewChangelog => 'ดูบันทึกการเปลี่ยนแปลง';
	@override String get alreadyLatestVersion => 'เป็นเวอร์ชันล่าสุดแล้ว';
	@override String get appSettings => 'การตั้งค่าแอป';
	@override String get configureYourAppSettings => 'กำหนดค่าการตั้งค่าแอปของคุณ';
	@override String get history => 'ประวัติ';
	@override String get autoRecordHistory => 'บันทึกประวัติอัตโนมัติ';
	@override String get autoRecordHistoryDesc => 'บันทึกวิดีโอและรูปภาพที่คุณดูโดยอัตโนมัติ';
	@override String get autoDeleteHistory => 'ล้างประวัติอัตโนมัติ';
	@override String get autoDeleteHistoryDesc => 'ลบประวัติการท่องเว็บที่เก่ากว่าจำนวนวันที่เก็บรักษาโดยอัตโนมัติเมื่อเริ่มต้น (ปิดอยู่โดยค่าเริ่มต้น)';
	@override String get autoDeleteHistoryDays => 'วันที่เก็บรักษา';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'เก็บไว้ ${num} วันล่าสุด';
	@override String get autoDeleteHistoryDaysInvalid => 'โปรดป้อนจำนวนวันที่ถูกต้อง (อย่างน้อย 1 วัน)';
	@override String get showUnprocessedMarkdownText => 'แสดงข้อความ Markdown ดิบ';
	@override String get showUnprocessedMarkdownTextDesc => 'แสดงข้อความต้นฉบับของ Markdown';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'โหมดความเป็นส่วนตัว';
	@override String get activeBackgroundPrivacyModeDesc => 'บล็อกการจับภาพหน้าจอและการบันทึกหน้าจอ และซ่อนหน้าจอเมื่อทำงานอยู่เบื้องหลัง';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'ซ่อนหน้าจอเมื่อแอปไปอยู่เบื้องหลัง (แพลตฟอร์มนี้ไม่สามารถบล็อกการจับภาพหน้าจอได้)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'บล็อกการจับภาพหน้าจอและการบันทึกหน้าจอ';
	@override String get privacy => 'ความเป็นส่วนตัว';
	@override String get appLock => 'การล็อกแอป';
	@override String get appLockEnabled => 'เปิดใช้การล็อกแอป';
	@override String get appLockEnabledDesc => 'กำหนดให้ต้องใช้ PIN หรือข้อมูลไบโอเมตริกเพื่อเปิดแอป และซ่อนตัวอย่างพื้นหลังโดยอัตโนมัติ';
	@override String get appLockEnabledSummary => 'เปิดอยู่ · ป้องกันด้วย PIN';
	@override String get appLockDisabledSummary => 'ปิดอยู่';
	@override String get appLockTimeout => 'ล็อกหลังจากออกจากแอป';
	@override String get appLockTimeoutDesc => 'ระยะเวลาที่อนุญาตให้อยู่เบื้องหลังก่อนที่จะต้องยืนยันตัวตน';
	@override String get appLockAfterScreenOff => 'ล็อกหลังจากล็อกหน้าจอ';
	@override String get appLockAfterScreenOffDesc => 'กำหนดให้ยืนยันตัวตนหลังจากหน้าจอของอุปกรณ์ถูกล็อก';
	@override String get appLockTimeoutDisabled => 'ปิดใช้งาน';
	@override String get appLockImmediately => 'ทันที';
	@override String appLockSeconds({required Object seconds}) => '${seconds} วินาที';
	@override String appLockMinutes({required Object minutes}) => '${minutes} นาที';
	@override String get appLockUseBiometrics => 'ใช้ข้อมูลไบโอเมตริก';
	@override String get appLockUseBiometricsDesc => 'ปลดล็อกด้วยลายนิ้วมือหรือการจดจำใบหน้า';
	@override String get appLockBiometricsUnavailable => 'ไม่มีข้อมูลไบโอเมตริกที่ลงทะเบียนไว้ในอุปกรณ์นี้';
	@override String get appLockSetPin => 'ตั้งค่า PIN';
	@override String get appLockEnterPin => 'ป้อน PIN';
	@override String get appLockConfirmPin => 'ยืนยัน PIN';
	@override String get appLockCurrentPin => 'ป้อน PIN ปัจจุบัน';
	@override String get appLockNewPin => 'ป้อน PIN ใหม่';
	@override String get appLockPinRequirements => 'PIN ต้องประกอบด้วยตัวเลข 4–8 หลัก';
	@override String get appLockPinsDoNotMatch => 'PIN ไม่ตรงกัน';
	@override String get appLockInvalidPin => 'PIN ไม่ถูกต้อง';
	@override String get appLockSetupFailed => 'ไม่สามารถบันทึก PIN ได้อย่างปลอดภัย';
	@override String get appLockDisable => 'ป้อน PIN เพื่อปิดการล็อกแอป';
	@override String get appLockChangePin => 'เปลี่ยน PIN';
	@override String get appLockNow => 'ล็อกทันที';
	@override String get appLockUnlock => 'ปลดล็อก';
	@override String get appLockLockedTitle => 'ล็อกอยู่';
	@override String get appLockLockedDesc => 'ยืนยันตัวตนเพื่อดำเนินการต่อ';
	@override String get appLockAuthenticateReason => 'ยืนยันตัวตนเพื่อปลดล็อก';
	@override String get appLockEnableBiometricsReason => 'ยืนยันตัวตนเพื่อเปิดใช้การปลดล็อกด้วยไบโอเมตริก';
	@override String get appLockBiometricFailed => 'การยืนยันตัวตนด้วยไบโอเมตริกไม่เสร็จสมบูรณ์';
	@override String appLockTooManyAttempts({required Object seconds}) => 'พยายามมากเกินไป ลองใหม่อีกครั้งในอีก ${seconds} วินาที';
	@override String get appLockCredentialUnavailableTitle => 'ไม่สามารถอ่านข้อมูลรับรองการล็อกแอปได้';
	@override String get appLockCredentialUnavailableDesc => 'ที่จัดเก็บข้อมูลที่ปลอดภัยของระบบไม่พร้อมใช้งานชั่วคราว หรือข้อมูลรับรองเสียหาย แอปจะยังคงล็อกอยู่ โปรดลองใหม่อีกครั้งก่อน หากยังคงล้มเหลว คุณสามารถรีเซ็ตการล็อกแอปได้ ซึ่งจะเป็นการปิดใช้งานและล้าง PIN ที่บันทึกไว้';
	@override String get appLockRetry => 'ลองใหม่';
	@override String get appLockReset => 'รีเซ็ตการล็อกแอป';
	@override String get appLockResetAction => 'รีเซ็ต';
	@override String get appLockResetConfirmTitle => 'รีเซ็ตการล็อกแอปหรือไม่?';
	@override String get appLockResetConfirmDesc => 'การดำเนินการนี้จะปิดการล็อกแอปและล้าง PIN ที่บันทึกไว้รวมถึงการตั้งค่าไบโอเมตริก คุณสามารถตั้งค่าใหม่ได้ในภายหลัง';
	@override String get appLockRetrySucceeded => 'อ่านข้อมูลรับรองสำเร็จแล้ว โปรดป้อน PIN ของคุณ';
	@override String get appLockRetryFailed => 'ยังคงไม่สามารถอ่านข้อมูลรับรองได้';
	@override String get forum => 'ฟอรัม';
	@override String get news => 'ข่าวสาร';
	@override String get community => 'ชุมชน';
	@override String get disableForumReplyQuote => 'ปิดใช้การอ้างอิงการตอบกลับฟอรัม';
	@override String get disableForumReplyQuoteDesc => 'ปิดการแนบข้อมูลชั้นที่ตอบกลับเมื่อตอบกลับในฟอรัม';
	@override String get theaterMode => 'โหมดโรงภาพยนตร์';
	@override String get theaterModeDesc => 'หลังจากเปิดใช้งาน พื้นหลังของเครื่องเล่นจะถูกตั้งเป็นเวอร์ชันเบลอของภาพปกวิดีโอ';
	@override String get appLinks => 'ลิงก์แอป';
	@override String get defaultBrowser => 'เรียกดูเริ่มต้น';
	@override String get defaultBrowserDesc => 'โปรดเปิดรายการกำหนดค่าลิงก์เริ่มต้นในการตั้งค่าระบบและเพิ่มลิงก์เว็บไซต์ iwara.tv';
	@override String get themeMode => 'โหมดธีม';
	@override String get themeModeDesc => 'การกำหนดค่านี้กำหนดโหมดธีมของแอป';
	@override String get glassEffect => 'วัสดุอินเทอร์เฟซ';
	@override String get glassEffectDesc => 'เลือกวัสดุที่ใช้ทั่วทั้งแอป — แคปซูลส่วนหัว เมนู ปุ่มกล่องโต้ตอบ และแถบนำทางด้านล่าง';
	@override String get liquidGlassEffect => 'กระจกเหลว';
	@override String get liquidGlassEffectDesc => 'การเบลอและการหักเหแสงจริง สวยงามที่สุด แต่อาจมีเฟรมดรอปและเปลืองพลังงานเพิ่มขึ้นเล็กน้อยบนอุปกรณ์ระดับเริ่มต้น';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'พื้นผิว Material 3 มาตรฐาน — ทึบแสง ไม่มีการเบลอ ไม่มีเงา ประสิทธิภาพและอายุการใช้งานแบตเตอรี่ดีที่สุด';
	@override String get glassEffectIntroTitle => 'เลือกวัสดุอินเทอร์เฟซของคุณ';
	@override String get glassEffectIntroContent => 'ส่วนหัว แถบแท็บ และเมนูใช้กระจกเหลว — การเบลอและการหักเหแสงจริง หากรู้สึกว่าอุปกรณ์ของคุณช้า หรือชอบอะไรที่เรียบง่ายกว่า สามารถเปลี่ยนเป็น Material ได้ตอนนี้ (พื้นผิวทึบแสง ไม่เบลอ ไม่มีเงา)';
	@override String get glassEffectIntroHint => 'คุณสามารถเปลี่ยนค่านี้ได้ตลอดเวลาใน การตั้งค่า → ธีม → วัสดุอินเทอร์เฟซ';
	@override String get glassEffectIntroDone => 'ใช้แบบนี้';
	@override String get dynamicColor => 'สีแบบไดนามิก';
	@override String get dynamicColorDesc => 'การกำหนดค่านี้กำหนดว่าแอปจะใช้สีแบบไดนามิกหรือไม่';
	@override String get useDynamicColor => 'ใช้สีแบบไดนามิก';
	@override String get useDynamicColorDesc => 'การกำหนดค่านี้กำหนดว่าแอปจะใช้สีแบบไดนามิกหรือไม่';
	@override String get presetColors => 'สีที่ตั้งไว้ล่วงหน้า';
	@override String get customColors => 'สีที่กำหนดเอง';
	@override String get customColorsDisabledByDynamicColor => 'เปิดใช้งานสีแบบไดนามิกอยู่ สีที่ตั้งไว้ล่วงหน้า/สีที่กำหนดเองจึงไม่พร้อมใช้งาน โปรดปิดสีแบบไดนามิกก่อน';
	@override String get pickColor => 'เลือกสี';
	@override String get cancel => 'ยกเลิก';
	@override String get confirm => 'ยืนยัน';
	@override String get noCustomColors => 'ไม่มีสีที่กำหนดเอง';
	@override String get recordAndRestorePlaybackProgress => 'บันทึกและคืนค่าความคืบหน้าการเล่น';
	@override String get autoPlayVideoOnFirstEnter => 'เล่นวิดีโออัตโนมัติเมื่อเข้าครั้งแรก';
	@override String get autoPlayVideoOnFirstEnterDesc => 'การตั้งค่านี้กำหนดว่าวิดีโอจะเริ่มเล่นโดยอัตโนมัติหรือไม่เมื่อเข้าสู่หน้าวิดีโอเป็นครั้งแรก';
	@override String get autoEnterFullscreen => 'เข้าสู่โหมดเต็มหน้าจอโดยอัตโนมัติ';
	@override String get autoEnterFullscreenDesc => 'กำหนดเวลาที่เครื่องเล่นควรเข้าสู่โหมดเต็มหน้าจอเอง วิดีโอส่วนตัว วิดีโอที่ถูกลบ วิดีโอภายนอก และขณะใช้การแสดงภาพซ้อนภาพจะไม่เข้าสู่โหมดเต็มหน้าจออัตโนมัติ';
	@override String get autoEnterFullscreenOff => 'ปิด';
	@override String get autoEnterFullscreenOffDesc => 'ไม่เข้าสู่โหมดเต็มหน้าจอเองโดยอัตโนมัติ';
	@override String get autoEnterFullscreenOnPlaybackStart => 'เมื่อเริ่มเล่น';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'เข้าสู่โหมดเต็มหน้าจอทันทีที่เริ่มเล่นวิดีโอจริง';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'เมื่อเปิดหน้าวิดีโอ';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'เข้าสู่โหมดเต็มหน้าจอทันทีที่เปิดหน้าวิดีโอโดยไม่ต้องรอให้เริ่มเล่น';
	@override String get autoEnterFullscreenKind => 'ประเภทเต็มหน้าจอ';
	@override String get autoEnterFullscreenKindDesc => 'ประเภทของโหมดเต็มหน้าจอที่จะเข้าอัตโนมัติ สำหรับเดสก์ท็อปเท่านั้น';
	@override String get autoEnterFullscreenKindSystem => 'เต็มหน้าจอระบบ';
	@override String get autoEnterFullscreenKindSystemDesc => 'ให้ตัวจัดการหน้าต่างขยายหน้าต่างเป็นแบบเต็มหน้าจอ';
	@override String get autoEnterFullscreenKindApp => 'เต็มหน้าจอแอป';
	@override String get autoEnterFullscreenKindAppDesc => 'คงขนาดหน้าต่างไว้เหมือนเดิมและเปลี่ยนทั้งแอปให้กลายเป็นเครื่องเล่น';
	@override String get signature => 'ลายเซ็น';
	@override String get enableSignature => 'เปิดใช้ลายเซ็น';
	@override String get enableSignatureDesc => 'การกำหนดค่านี้กำหนดว่าแอปจะเพิ่มลายเซ็นเมื่อตอบกลับหรือไม่';
	@override String get enterSignature => 'ป้อนลายเซ็น';
	@override String get editSignature => 'แก้ไขลายเซ็น';
	@override String get signatureContent => 'เนื้อหาลายเซ็น';
	@override String get signaturePreview => 'ตัวอย่าง';
	@override String get signatureSampleBody => 'ข้อความของคุณอยู่ตรงนี้';
	@override String get signatureRegenerate => 'สร้างใหม่';
	@override String get signatureNotSet => 'ยังไม่ได้ตั้งค่า';
	@override String get signatureRuleHint => 'ลายเซ็นจะต่อท้ายเนื้อหาโดยมีเส้นคั่น แอปจะใส่เส้นคั่นให้เอง คุณแค่เขียนข้อความด้านล่าง';
	@override String get signatureInsertVariable => 'แทรกตัวแปร';
	@override String get varDate => 'วันที่';
	@override String get varTime => 'เวลา';
	@override String get varDatetime => 'วันที่และเวลา';
	@override String get varWeekday => 'วันในสัปดาห์';
	@override String get varPlatform => 'แพลตฟอร์ม';
	@override String get varPick => 'ข้อความสุ่ม';
	@override String get varTitle => 'ชื่อเรื่อง';
	@override String get varAuthor => 'ผู้สร้าง';
	@override String get varTags => 'แท็ก';
	@override String get varSection => 'หมวด';
	@override String get varReplyTo => 'กำลังตอบถึง';
	@override String get varPlaytime => 'ตำแหน่งการเล่น';
	@override String get signatureContextGroup => 'ตัวแปรบริบท';
	@override String get signatureContextHint => 'ค่าต่าง ๆ มาจากหน้าที่คุณกำลังโพสต์อยู่ หน้าวิดีโอรู้ชื่อเรื่อง ผู้สร้าง แท็ก และตำแหน่งที่เล่นอยู่ ส่วนฟอรัมรู้หมวดและเลขชั้น ด้านขวาคือค่าตัวอย่าง ส่วนที่เติมไม่ได้จะหายไปเองตอนส่ง';
	@override String get signatureContextValue => 'แล้วแต่หน้า';
	@override String get varFloor => 'ลำดับความเห็น';
	@override String get varDuration => 'ความยาววิดีโอ';
	@override String get signatureRecipesHint => 'ไม่รู้จะเขียนอะไรดี? แตะสักอันเพื่อใช้เลย แล้วค่อยแก้ ข้างล่างคือหน้าตาจริงเวลาส่งออกไป';
	@override String get recipeWatchingName => 'กำลังดูอะไรอยู่';
	@override String get recipeWatchingTemplate => 'กำลังดู %title% · %date%';
	@override String get recipeTimestampName => 'ดูถึงตรงนี้';
	@override String get recipeTimestampTemplate => 'ดูถึง %playtime% จาก %duration%';
	@override String get recipeHitokotoName => 'คำคมประจำวัน';
	@override String get recipeHitokotoTemplate => 'คำคมประจำวัน: %hitokoto%';
	@override String get recipeAiName => 'ให้ AI เขียนให้';
	@override String get recipeAiTemplate => '%ai_hitokoto%';
	@override String get recipeReplyName => 'ทักทายตอนตอบกลับ';
	@override String get recipeReplyTemplate => 'ถึง %reply_to% · ส่งจาก %platform%';
	@override String get recipeMoodName => 'อารมณ์แบบสุ่ม';
	@override String get recipeMoodTemplate => 'อารมณ์วันนี้: %pick:ดีมาก|เฉย ๆ|ไม่บอก%';
	@override String get signatureRecipesTitle => 'ตัวอย่าง';
	@override String get signatureRecipesMore => 'ตัวอย่างเพิ่มเติม';
	@override String get signatureSceneVideo => 'ในหน้าวิดีโอ';
	@override String get signatureSceneForum => 'ในฟอรัม';
	@override String get signatureSceneAuthor => 'ในหน้าโปรไฟล์';
	@override String get signatureSceneNone => 'ไม่มีบริบท';
	@override String get signatureSceneFromHistory => 'เนื้อหาตัวอย่างมาจากสิ่งที่คุณดูล่าสุด เวลาส่งจริงจะใช้หน้าที่คุณอยู่ตอนนั้น';
	@override String get signatureSceneFromDemo => 'ยังไม่มีประวัติการดู จึงใช้ตัวอย่างสำรองไปก่อน เวลาส่งจริงจะใช้หน้าที่คุณอยู่ตอนนั้น';
	@override String get signatureDemoVideoTitle => 'เต้นรำใต้แสงจันทร์';
	@override String get signatureDemoAuthor => 'Hoshino';
	@override String get signatureDemoTags => 'mmd 4k 60fps';
	@override String get signatureDemoThreadTitle => 'ขอคำแนะนำการตั้งค่าคุณภาพ';
	@override String get signatureDemoSection => 'ทั่วไป';
	@override String get signatureDemoQuote => 'ช้า ๆ ได้พร้าเล่มงาม';
	@override String get signatureDemoAiQuote => 'แค่ท่าหมุนตอนสามนาทีครึ่งก็คุ้มแล้ว';
	@override String get signatureRecipeGroupWatching => 'ตอนดูวิดีโอ';
	@override String get signatureRecipeGroupReplying => 'ตอนตอบกลับ';
	@override String get signatureRecipeGroupForum => 'ตอนอยู่ในฟอรัม';
	@override String get signatureRecipeGroupDaily => 'วันละหนึ่งประโยค';
	@override String get signatureRecipeGroupAi => 'ให้ AI เขียนให้';
	@override String get signaturePromptSampleContext => 'การลองเขียนครั้งนี้ใช้บริบทตัวอย่างของหน้าวิดีโอ เวลาส่งจริง AI จะได้รับสิ่งที่คุณกำลังดูอยู่';
	@override String get recipeAuthorTagsName => 'ผู้สร้างและแท็ก';
	@override String get recipeAuthorTagsTemplate => '%author% · %tags%';
	@override String get recipeFloorName => 'ตอบชั้นที่ระบุ';
	@override String get recipeFloorTemplate => 'จากชั้น %floor% · ถึง %reply_to%';
	@override String get recipeSectionName => 'บอกหมวดที่อยู่';
	@override String get recipeSectionTemplate => 'จากหมวด %section%';
	@override String get recipeDailyName => 'วันที่กับหนึ่งประโยค';
	@override String get recipeDailyTemplate => '%date% %weekday% · %hitokoto%';
	@override String get signatureSources => 'แหล่งข้อมูล';
	@override String get signatureAutoTranslate => 'แปลเป็นภาษาของฉัน';
	@override String get signatureAutoTranslateDesc => 'แหล่งข้อมูลอย่าง Hitokoto ตอนนี้มีแต่ภาษาจีน ประโยคที่ได้จะถูกแปลก่อนส่งออกไป';
	@override String get signatureWizardTitle => 'เพิ่มแหล่งข้อมูล';
	@override String get signatureWizardUrlTitle => 'ที่อยู่ปลายทาง';
	@override String get signatureWizardUrlHint => 'ใส่ที่อยู่ที่คืนค่าข้อความหนึ่งบรรทัด ปุ่มด้านล่างจะเรียกจริงหนึ่งครั้งเพื่อให้คุณเห็นว่าได้อะไรกลับมา';
	@override String get signatureWizardFetch => 'ลองเรียกดู';
	@override String get signatureWizardSkipTest => 'ข้ามไป แค่เปลี่ยนชื่อ';
	@override String get signatureWizardPickTitle => 'เลือกส่วนที่ต้องการ';
	@override String get signatureWizardPickHint => 'นี่คือสิ่งที่ปลายทางนั้นส่งกลับมา แตะบรรทัดที่อยากให้ลายเซ็นแสดง';
	@override String get signatureWizardPickPlainHint => 'ปลายทางนี้ส่งข้อความธรรมดากลับมา ทั้งก้อนคือสิ่งที่จะแสดง';
	@override String get signatureWizardWholeBody => 'คำตอบทั้งหมด';
	@override String get signatureWizardNameTitle => 'ตั้งชื่อให้มัน';
	@override String get signatureWizardNameHint => 'ชื่อมีไว้ให้คุณจำเอง ส่วนที่ลายเซ็นใช้อ้างถึงคือชื่ออ้างอิงด้านล่าง';
	@override String get signatureWizardNext => 'ถัดไป';
	@override String get signatureWizardDone => 'เสร็จ';
	@override String get signatureWizardStripHtml => 'เอาแท็ก HTML ออก';
	@override String get signatureWizardAdvanced => 'ขั้นสูง: ดึงด้วยรูปแบบ';
	@override String get signatureWizardExtractHint => 'นิพจน์ทั่วไป ใช้กลุ่มที่จับได้กลุ่มแรก';
	@override String get signatureWizardExtractMissed => 'รูปแบบนี้ไม่ตรงกับอะไรเลย จึงใช้ข้อความเดิม';
	@override String get signatureWizardChooseTitle => 'เลือกสักแหล่ง';
	@override String get signatureWizardChooseHint => 'แตะแหล่งที่เตรียมไว้ให้ก็เสร็จแล้ว หรือจะชี้ไปที่ปลายทางของคุณเองก็ได้';
	@override String get signatureWizardCustomSource => 'ใช้ปลายทางของฉันเอง';
	@override String get signatureWizardWithOrigin => 'แสดงที่มาด้วย';
	@override String get signatureWizardRandomItem => 'สุ่มใหม่ทุกครั้ง';
	@override String get signatureWizardSuffixTitle => 'ต่อท้ายด้วยอีกฟิลด์';
	@override String get signatureWizardSuffixNone => 'ไม่ต่อ';
	@override String get signatureOptFlavor => 'เนื้อหา';
	@override String get signatureOptFlavorAny => 'ไม่จำกัด';
	@override String get signatureOptFlavorOtaku => 'อนิเมะ มังงะ และเกม';
	@override String get signatureOptFlavorLiterary => 'วรรณกรรมและบทกวี';
	@override String get signatureOptFlavorMeme => 'วัฒนธรรมอินเทอร์เน็ต';
	@override String get signatureOptLength => 'ความยาว';
	@override String get signatureOptLengthAny => 'ไม่จำกัด';
	@override String get signatureOptLengthShort => 'เอาเฉพาะประโยคสั้น';
	@override String get signatureRestoreDefault => 'คืนค่าเริ่มต้น';
	@override String get signatureSourceHitokoto => 'Hitokoto (ข้อความสุ่ม)';
	@override String get signatureAiSourceName => 'ข้อความจาก AI';
	@override String get signatureEditTextHint => 'นี่คือลายเซ็นที่เขียนอยู่ในความเห็นนี้แล้ว ทั้งวรรคทองและวันที่ตอนนี้เป็นแค่ข้อความธรรมดา แก้ได้ตามใจ ล้างให้ว่างคือไม่เอาลายเซ็น';
	@override String signatureResolving({required Object name}) => 'กำลังสร้าง ${name}…';
	@override String get signaturePendingValue => '(สร้างตอนส่ง)';
	@override String get signatureAiHint => 'ประโยคที่ AI เขียนสด ใหม่ทุกความคิดเห็น โดยใช้ผู้ให้บริการ AI ที่คุณตั้งไว้ เมื่อส่งจากหน้าวิดีโอ แกลเลอรี หรือฟอรัม AI จะรู้ด้วยว่าคุณกำลังดูอะไรและเขียนให้เข้ากับสิ่งนั้น';
	@override String get signatureAiUnavailable => 'ยังไม่ได้ตั้งค่าผู้ให้บริการ AI แหล่งนี้จึงยังไม่ปรากฏในแผงตัวแปร';
	@override String get signaturePromptTitle => 'พรอมต์';
	@override String get signaturePromptHint => 'นี่คือสิ่งที่ส่งให้โมเดล เขียนใหม่ได้ตามใจ ทั้งน้ำเสียง ความยาว และหัวข้อ กฎที่มีอยู่แล้วควรเก็บไว้';
	@override String get signaturePromptReset => 'คืนค่าเริ่มต้น';
	@override String get signaturePromptTry => 'ลองดู';
	@override String get signaturePromptSample => 'สิ่งที่เขียนออกมา';
	@override String get signaturePromptLanguageHint => 'จะถูกแทนด้วยภาษาอินเทอร์เฟซของคุณ ถ้าลบออก ข้อความจะใช้ภาษาตามพรอมต์';
	@override String get signaturePromptEdited => 'แก้แล้ว';
	@override String get signatureVariablesGroup => 'ตัวแปรในตัว';
	@override String get signatureNeedsNetwork => 'ต้องใช้เครือข่าย';
	@override String get signatureBuiltinSource => 'ในตัว';
	@override String get signatureSourceIdReserved => 'ชื่อนี้ถูกตัวแปรในตัวใช้อยู่';
	@override String get signatureSourcesTitle => 'แหล่งข้อมูลที่กำหนดเอง';
	@override String get signatureSourcesHint => 'ใส่ที่อยู่ที่คืนค่าข้อความหนึ่งบรรทัด แล้วคุณจะดึงมาใส่ในลายเซ็นได้';
	@override String get signatureSourcesEmpty => 'ยังไม่มีแหล่งข้อมูล';
	@override String get signatureAddSource => 'เพิ่ม';
	@override String get signatureEditSource => 'แก้ไขแหล่งข้อมูล';
	@override String get signatureSourceName => 'ชื่อ';
	@override String get signatureSourceId => 'ชื่อที่ใช้อ้างอิง';
	@override String get signatureSourceIdHint => 'ชื่อที่ลายเซ็นใช้เรียกแหล่งข้อมูลนี้';
	@override String get signatureSourceUrl => 'ที่อยู่ปลายทาง';
	@override String get signatureSourcePath => 'เส้นทางของค่า';
	@override String get signatureSourcePathHint => 'เว้นว่างไว้ถ้าทั้งคำตอบคือข้อความนั้น ใส่ data.text เพื่อดึงฟิลด์นั้นจากคำตอบแบบ JSON';
	@override String get signatureSourceTest => 'ทดสอบ';
	@override String get signatureSourceTestOk => 'ดึงมาได้แล้ว';
	@override String get signatureSourceTestFailed => 'ไม่มีอะไรกลับมา';
	@override String get signatureSourceIdInvalid => 'ชื่ออ้างอิงใช้ได้เฉพาะตัวพิมพ์เล็ก ตัวเลข และขีดล่าง';
	@override String get signatureSourceIdDuplicate => 'ชื่ออ้างอิงนี้ถูกใช้ไปแล้ว';
	@override String get signatureSourceUrlRequired => 'กรุณาใส่ที่อยู่ปลายทาง';
	@override String get exportConfig => 'ส่งออกการกำหนดค่าแอป';
	@override String get exportConfigDesc => 'ส่งออกการตั้งค่าและประวัติ (ประวัติการเข้าชม ความคืบหน้าการเล่น รายการโปรด ฯลฯ) ไปยังไฟล์เพื่อสำรองข้อมูลหรือถ่ายโอนไปยังอุปกรณ์อื่น ไม่รวมงานดาวน์โหลด';
	@override String get importConfig => 'นำเข้าการกำหนดค่าแอป';
	@override String get importConfigDesc => 'นำเข้าการกำหนดค่าแอปจากไฟล์';
	@override String get exportConfigSuccess => 'ส่งออกการกำหนดค่าสำเร็จ!';
	@override String get exportConfigFailed => 'ส่งออกการกำหนดค่าล้มเหลว';
	@override String get importConfigSuccess => 'นำเข้าการกำหนดค่าสำเร็จ!';
	@override String get importConfigFailed => 'นำเข้าการกำหนดค่าล้มเหลว';
	@override String get exportIncludeSensitive => 'รวมข้อมูลที่ละเอียดอ่อน';
	@override String get exportIncludeSensitiveDesc => 'รวมคีย์ API โทเค็นเซสชัน และที่อยู่พร็อกซี เปิดใช้งานเมื่อสำรองข้อมูลไปยังอุปกรณ์ของคุณเองเท่านั้น';
	@override String get importConfigOverwriteWarning => 'การนำเข้าจะเขียนทับการตั้งค่าและประวัติปัจจุบันของคุณ (ประวัติการเข้าชม ความคืบหน้าการเล่น รายการโปรด ฯลฯ) ดำเนินการต่อหรือไม่?';
	@override String get importConfigRestartTitle => 'นำเข้าสำเร็จ';
	@override String get importConfigRestartContent => 'นำเข้าการกำหนดค่าของคุณเรียบร้อยแล้ว โปรดปิดและเปิดแอปใหม่อีกครั้งเพื่อให้การเปลี่ยนแปลงทั้งหมดมีผล';
	@override String get historyUpdateLogs => 'บันทึกการอัปเดตประวัติ';
	@override String get noUpdateLogs => 'ไม่มีบันทึกการอัปเดต';
	@override String get versionLabel => 'เวอร์ชัน: {version}';
	@override String get releaseDateLabel => 'วันที่เผยแพร่: {date}';
	@override String get noChanges => 'ไม่มีเนื้อหาการอัปเดต';
	@override String get interaction => 'การโต้ตอบ';
	@override String get enableVibration => 'เปิดใช้การสั่น';
	@override String get enableVibrationDesc => 'เปิดใช้การตอบสนองแบบสั่นเมื่อโต้ตอบกับแอป';
	@override String get defaultKeepVideoToolbarVisible => 'คงแถบเครื่องมือวิดีโอไว้เสมอ';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'การตั้งค่านี้กำหนดว่าจะให้แถบเครื่องมือวิดีโอแสดงอยู่เสมอหรือไม่เมื่อเข้าสู่หน้าวิดีโอเป็นครั้งแรก';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'การเปิดใช้โหมดโรงภาพยนตร์บนอุปกรณ์เคลื่อนที่อาจทำให้เกิดปัญหาด้านประสิทธิภาพ คุณสามารถเลือกเปิดใช้งานได้ตามความเหมาะสม';
	@override String get fullscreenOrientation => 'การวางแนวหน้าจอแนวตั้งหลังจากเข้าสู่โหมดเต็มหน้าจอ';
	@override String get fullscreenOrientationDesc => 'การตั้งค่านี้กำหนดทิศทางหน้าจอเริ่มต้นเมื่อเข้าสู่โหมดเต็มหน้าจอ (สำหรับมือถือเท่านั้น)';
	@override String get fullscreenOrientationLeftLandscape => 'แนวนอนซ้าย';
	@override String get fullscreenOrientationRightLandscape => 'แนวนอนขวา';
	@override String get screenFit => 'ขนาดหน้าจอ';
	@override String get screenFitDesc => 'เลือกว่าจะให้วิดีโอแสดงผลในพื้นที่ของเครื่องเล่นอย่างไร';
	@override String get rememberScreenFit => 'จำขนาดหน้าจอ';
	@override String get rememberScreenFitDesc => 'ใช้ขนาดที่เลือกกับวิดีโอที่เปิดในภายหลัง';
	@override String get screenFitFit => 'พอดี';
	@override String get screenFitFitDesc => 'แสดงภาพทั้งเฟรมโดยรักษาอัตราส่วนเดิมไว้';
	@override String get screenFitStretch => 'ยืด';
	@override String get screenFitStretchDesc => 'ขยายให้เต็มพื้นที่เครื่องเล่น ภาพอาจผิดเพี้ยน';
	@override String get screenFitCover => 'เติมเต็ม';
	@override String get screenFitCoverDesc => 'ขยายให้เต็มพื้นที่เครื่องเล่นโดยรักษาอัตราส่วนเดิมไว้ ส่วนที่เกินจะถูกครอบตัด';
	@override String get screenFitRatioDesc => 'บังคับใช้อัตราส่วนนี้ ภาพอาจผิดเพี้ยน';
	@override String get jumpLink => 'ลิงก์กระโดด';
	@override String get language => 'ภาษา';
	@override String get languageNativeName => 'ไทย';
	@override String get followSystemLanguage => 'ตามภาษาระบบ';
	@override String get languageChangedMessage => 'เปลี่ยนภาษาสำเร็จ ฟีเจอร์บางอย่างต้องรีสตาร์ทแอปจึงจะมีผล';
	@override String get languageChanged => 'การตั้งค่าภาษาถูกเปลี่ยนแปลงแล้ว โปรดรีสตาร์ตแอปเพื่อให้มีผล';
	@override late final _TranslationsSettingsKeybindingTh keybinding = _TranslationsSettingsKeybindingTh._(_root);
	@override String get gestureControl => 'การควบคุมด้วยท่าทาง';
	@override String get leftDoubleTapRewind => 'แตะสองครั้งด้านซ้ายเพื่อย้อนกลับ';
	@override String get rightDoubleTapFastForward => 'แตะสองครั้งด้านขวาเพื่อเดินหน้าอย่างเร็ว';
	@override String get doubleTapPause => 'แตะสองครั้งเพื่อหยุดชั่วคราว';
	@override String get rightVerticalSwipeVolume => 'ปัดแนวตั้งด้านขวาเพื่อปรับระดับเสียง (มีผลเมื่อเข้าสู่หน้าใหม่)';
	@override String get leftVerticalSwipeBrightness => 'ปัดแนวตั้งด้านซ้ายเพื่อปรับความสว่าง (มีผลเมื่อเข้าสู่หน้าใหม่)';
	@override String get longPressFastForward => 'กดค้างเพื่อเดินหน้าอย่างเร็ว';
	@override String get enableMouseHoverShowToolbar => 'เปิดใช้การชี้เมาส์เพื่อแสดงแถบเครื่องมือ';
	@override String get enableMouseHoverShowToolbarInfo => 'เมื่อเปิดใช้งาน แถบเครื่องมือวิดีโอจะแสดงขึ้นเมื่อเลื่อนเมาส์ไปเหนือเครื่องเล่น และจะซ่อนโดยอัตโนมัติหลังจากไม่มีการใช้งานเป็นเวลา 3 วินาที';
	@override String get enableHorizontalDragSeek => 'ปัดในแนวนอนเพื่อเลื่อนหาตำแหน่ง';
	@override String get enableVideoGestureZoom => 'หนีบนิ้วเพื่อซูมเฟรมวิดีโอ';
	@override String get enableVideoGestureZoomInfo => 'หนีบนิ้วด้วยสองนิ้ว (หรือ Ctrl + ล้อเลื่อนเมาส์บนเดสก์ท็อป) เพื่อซูมภาพวิดีโอ จากนั้นลากเพื่อเลื่อนตำแหน่งภาพ';
	@override String get showCenterPlayPauseButton => 'ปุ่มเล่น/หยุดชั่วคราวตรงกลาง';
	@override String get showCenterPlayPauseButtonDesc => 'แสดงปุ่มเล่น/หยุดชั่วคราวขนาดใหญ่ตรงกลางเครื่องเล่น';
	@override String get audioVideoConfig => 'การกำหนดค่าเสียงและวิดีโอ';
	@override String get expandBuffer => 'ขยายบัฟเฟอร์';
	@override String get expandBufferInfo => 'เมื่อเปิดใช้งาน ขนาดบัฟเฟอร์จะเพิ่มขึ้น เวลาในการโหลดจะนานขึ้น แต่การเล่นจะราบรื่นยิ่งขึ้น';
	@override String get videoSyncMode => 'โหมดการซิงค์วิดีโอ';
	@override String get videoSyncModeSubtitle => 'กลยุทธ์การซิงโครไนซ์เสียงและวิดีโอ';
	@override String get hardwareDecodingMode => 'โหมดการถอดรหัสฮาร์ดแวร์';
	@override String get hardwareDecodingModeSubtitle => 'การตั้งค่าการถอดรหัสฮาร์ดแวร์';
	@override String get enableHardwareAcceleration => 'เปิดใช้การเร่งความเร็วด้วยฮาร์ดแวร์';
	@override String get enableHardwareAccelerationInfo => 'การเปิดใช้การเร่งความเร็วด้วยฮาร์ดแวร์สามารถปรับปรุงประสิทธิภาพการถอดรหัสได้ แต่อุปกรณ์บางรุ่นอาจไม่รองรับ';
	@override String get useOpenSLESAudioOutput => 'ใช้เอาต์พุตเสียง OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'ใช้เอาต์พุตเสียงที่มีความหน่วงต่ำ อาจช่วยปรับปรุงประสิทธิภาพของเสียงได้';
	@override String get videoSyncAudio => 'การซิงค์เสียง';
	@override String get videoSyncDisplayResample => 'การสุ่มตัวอย่างใหม่ในการแสดงผล';
	@override String get videoSyncDisplayResampleVdrop => 'การสุ่มตัวอย่างใหม่ในการแสดงผล (ดรอปเฟรม)';
	@override String get videoSyncDisplayResampleDesync => 'การสุ่มตัวอย่างใหม่ในการแสดงผล (ไม่ซิงค์)';
	@override String get videoSyncDisplayTempo => 'จังหวะการแสดงผล';
	@override String get videoSyncDisplayVdrop => 'แสดงผลโดยดรอปเฟรมวิดีโอ';
	@override String get videoSyncDisplayAdrop => 'แสดงผลโดยดรอปเฟรมเสียง';
	@override String get videoSyncDisplayDesync => 'แสดงผลแบบไม่ซิงค์';
	@override String get videoSyncDesync => 'ไม่ซิงค์';
	@override late final _TranslationsSettingsForumSettingsTh forumSettings = _TranslationsSettingsForumSettingsTh._(_root);
	@override late final _TranslationsSettingsGallerySettingsTh gallerySettings = _TranslationsSettingsGallerySettingsTh._(_root);
	@override late final _TranslationsSettingsBlockSettingsTh blockSettings = _TranslationsSettingsBlockSettingsTh._(_root);
	@override late final _TranslationsSettingsChatSettingsTh chatSettings = _TranslationsSettingsChatSettingsTh._(_root);
	@override String get hardwareDecodingAuto => 'อัตโนมัติ';
	@override String get hardwareDecodingAutoCopy => 'คัดลอกอัตโนมัติ';
	@override String get hardwareDecodingAutoSafe => 'ปลอดภัยอัตโนมัติ';
	@override String get hardwareDecodingNo => 'ปิดใช้งาน';
	@override String get hardwareDecodingYes => 'บังคับเปิดใช้งาน';
	@override String get cdnDistributionStrategy => 'กลยุทธ์การกระจายเนื้อหา';
	@override String get cdnDistributionStrategyDesc => 'เลือกกลยุทธ์การกระจายของเซิร์ฟเวอร์แหล่งที่มาของวิดีโอเพื่อปรับปรุงความเร็วในการโหลด';
	@override String get cdnDistributionStrategyLabel => 'กลยุทธ์การกระจาย';
	@override String get cdnDistributionStrategyNoChange => 'ไม่เปลี่ยนแปลง (ใช้เซิร์ฟเวอร์เดิม)';
	@override String get cdnDistributionStrategyAuto => 'เลือกอัตโนมัติ (เซิร์ฟเวอร์ที่เร็วที่สุด)';
	@override String get cdnDistributionStrategySpecial => 'ระบุเซิร์ฟเวอร์';
	@override String get cdnSpecialServer => 'ระบุเซิร์ฟเวอร์';
	@override String get cdnRefreshServerListHint => 'โปรดคลิกปุ่มด้านล่างเพื่อรีเฟรชรายการเซิร์ฟเวอร์';
	@override String get cdnRefreshButton => 'รีเฟรช';
	@override String get cdnFastRingServers => 'เซิร์ฟเวอร์วงแหวนเร็ว (Fast Ring)';
	@override String get cdnRefreshServerListTooltip => 'รีเฟรชรายการเซิร์ฟเวอร์';
	@override String get cdnSpeedTestButton => 'ทดสอบความเร็ว';
	@override String cdnSpeedTestingButton({required Object count}) => 'กำลังทดสอบ (${count})';
	@override String get cdnNoServerDataHint => 'ไม่มีข้อมูลเซิร์ฟเวอร์ โปรดคลิกปุ่มรีเฟรช';
	@override String get cdnTestingStatus => 'กำลังทดสอบ';
	@override String get cdnUnreachableStatus => 'ไม่สามารถเข้าถึงได้';
	@override String get cdnNotTestedStatus => 'ยังไม่ได้ทดสอบ';
	@override late final _TranslationsSettingsDownloadSettingsTh downloadSettings = _TranslationsSettingsDownloadSettingsTh._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsTh extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'แท็กโปรด';
	@override String get emptyIwara => 'ยังไม่มีแท็ก Iwara ที่ชื่นชอบ';
	@override String get emptyOreno3d => 'ยังไม่มีรายการโปรด';
	@override String get addIwaraTag => 'เพิ่มแท็ก Iwara';
	@override String get quickPickHint => 'รายการโปรดจะปรากฏเป็นตัวเลือกด่วนในการค้นหา';
	@override String get pickerTitle => 'เลือก Oreno3D';
	@override String get searchHint => 'ค้นหาด้วยชื่อหรือต้นฉบับ';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n,
		one: '${n} ผลงาน',
		other: '${n} ผลงาน',
	);
	@override String get browseEntry => 'เรียกดู ต้นฉบับ / ตัวละคร / แท็ก';
	@override String get favoritesSection => 'รายการโปรด';
	@override String get addFavorite => 'เพิ่ม';
	@override String get iwaraTitle => 'แท็กโปรดของ Iwara';
	@override String get oreno3dTitle => 'แท็กโปรดของ Oreno3D';
	@override String get changeTag => 'เปลี่ยนแท็ก';
	@override String get switchToText => 'ค้นหาด้วยข้อความ';
}

// Path: oreno3d
class _TranslationsOreno3dTh extends TranslationsOreno3dEn {
	_TranslationsOreno3dTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'แท็ก';
	@override String get characters => 'ตัวละคร';
	@override String get origin => 'ต้นฉบับ';
	@override String get thirdPartyTagsExplanation => 'ข้อมูล **แท็ก** **ตัวละคร** และ **ที่มา** ที่แสดงที่นี่จัดทำโดยเว็บไซต์บุคคลที่สาม **Oreno3D** เพื่อใช้อ้างอิงเท่านั้น\n\nเนื่องจากแหล่งข้อมูลนี้มีเฉพาะภาษาญี่ปุ่น จึงยังไม่รองรับการแปลหลายภาษา\n\nหากสนใจร่วมพัฒนาการแปลหลายภาษา เชิญที่รีโพซิทอรี';
	@override late final _TranslationsOreno3dSortTypesTh sortTypes = _TranslationsOreno3dSortTypesTh._(_root);
	@override late final _TranslationsOreno3dErrorsTh errors = _TranslationsOreno3dErrorsTh._(_root);
	@override late final _TranslationsOreno3dLoadingTh loading = _TranslationsOreno3dLoadingTh._(_root);
	@override late final _TranslationsOreno3dMessagesTh messages = _TranslationsOreno3dMessagesTh._(_root);
}

// Path: signIn
class _TranslationsSignInTh extends TranslationsSignInEn {
	_TranslationsSignInTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'โปรดเข้าสู่ระบบก่อน';
	@override String get alreadySignedInToday => 'วันนี้คุณได้ลงชื่อเข้าใช้แล้ว!';
	@override String get youDidNotStickToTheSignIn => 'คุณไม่ได้ลงชื่อเข้าใช้อย่างต่อเนื่อง';
	@override String get signInSuccess => 'ลงชื่อเข้าใช้สำเร็จ!';
	@override String get signInFailed => 'ลงชื่อเข้าใช้ล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get consecutiveSignIns => 'การลงชื่อเข้าใช้ติดต่อกัน';
	@override String get failureReason => 'เหตุผลที่ล้มเหลว';
	@override String get selectDateRange => 'เลือกช่วงวันที่';
	@override String get startDate => 'วันที่เริ่มต้น';
	@override String get endDate => 'วันที่สิ้นสุด';
	@override String get invalidDate => 'รูปแบบวันที่ไม่ถูกต้อง';
	@override String get invalidDateRange => 'ช่วงวันที่ไม่ถูกต้อง';
	@override String get errorFormatText => 'รูปแบบวันที่ไม่ถูกต้อง';
	@override String get errorInvalidText => 'ช่วงวันที่ไม่ถูกต้อง';
	@override String get errorInvalidRangeText => 'ช่วงวันที่ไม่ถูกต้อง';
	@override String get dateRangeCantBeMoreThanOneYear => 'ช่วงวันที่ต้องไม่เกิน 1 ปี';
	@override String get signIn => 'เช็คอิน';
	@override String get signInRecord => 'บันทึกการเช็คอิน';
	@override String get totalSignIns => 'การเช็คอินทั้งหมด';
	@override String get pleaseSelectSignInStatus => 'โปรดเลือกสถานะการเช็คอิน';
}

// Path: subscriptions
class _TranslationsSubscriptionsTh extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'โปรดเข้าสู่ระบบก่อนเพื่อดูการติดตามของคุณ';
	@override String get selectUser => 'เลือกผู้ใช้';
	@override String get noSubscribedUsers => 'ไม่มีผู้ใช้ที่ติดตาม';
	@override String get showAllSubscribedUsersContent => 'แสดงเนื้อหาของผู้ใช้ที่ติดตามทั้งหมด';
}

// Path: videoDetail
class _TranslationsVideoDetailTh extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'โหมดภาพซ้อนภาพ (PiP)';
	@override String resumeFromLastPosition({required Object position}) => 'เล่นต่อจากตำแหน่งล่าสุด: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'เล่นต่อจาก ${position}';
	@override String get restartFromBeginning => 'เริ่มใหม่ตั้งแต่ต้น';
	@override String get dismissResumeTip => 'รับทราบ';
	@override late final _TranslationsVideoDetailLocalInfoTh localInfo = _TranslationsVideoDetailLocalInfoTh._(_root);
	@override String get videoIdIsEmpty => 'รหัสวิดีโอว่างเปล่า';
	@override String get videoInfoIsEmpty => 'ข้อมูลวิดีโอว่างเปล่า';
	@override String get thisIsAPrivateVideo => 'นี่เป็นวิดีโอส่วนตัว';
	@override String get getVideoInfoFailed => 'รับข้อมูลวิดีโอล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get noVideoSourceFound => 'ไม่พบแหล่งที่มาของวิดีโอ';
	@override String tagCopiedToClipboard({required Object tagId}) => 'คัดลอกแท็ก "${tagId}" ไปยังคลิปบอร์ดแล้ว';
	@override String get errorLoadingVideo => 'เกิดข้อผิดพลาดขณะโหลดวิดีโอ';
	@override String get play => 'เล่น';
	@override String get pause => 'หยุดชั่วคราว';
	@override String get exitAppFullscreen => 'ออกจากเต็มหน้าจอแอป';
	@override String get enterAppFullscreen => 'เต็มหน้าจอแอป';
	@override String get exitSystemFullscreen => 'ออกจากเต็มหน้าจอระบบ';
	@override String get enterSystemFullscreen => 'เต็มหน้าจอระบบ';
	@override String get seekTo => 'ข้ามไปยัง';
	@override String get switchResolution => 'สลับความละเอียด';
	@override String get switchPlaybackSpeed => 'สลับความเร็วการเล่น';
	@override String rewindSeconds({required Object num}) => 'ย้อนกลับ ${num} วินาที';
	@override String fastForwardSeconds({required Object num}) => 'เดินหน้า ${num} วินาที';
	@override String playbackSpeedIng({required Object rate}) => 'กำลังเล่นที่ความเร็ว ${rate}x';
	@override String get brightness => 'ความสว่าง';
	@override String get brightnessLowest => 'ความสว่างต่ำสุดแล้ว';
	@override String get volume => 'ระดับเสียง';
	@override String get volumeMuted => 'ปิดเสียงแล้ว';
	@override String get restoreDefaultZoom => 'คืนค่าเดิม';
	@override late final _TranslationsVideoDetailGestureGuideTh gestureGuide = _TranslationsVideoDetailGestureGuideTh._(_root);
	@override String get home => 'หน้าแรก';
	@override String get videoPlayer => 'เครื่องเล่นวิดีโอ';
	@override String get videoPlayerInfo => 'ข้อมูลเครื่องเล่นวิดีโอ';
	@override String get moreSettings => 'การตั้งค่าเพิ่มเติม';
	@override String get videoPlayerFeatureInfo => 'ข้อมูลฟีเจอร์ของเครื่องเล่นวิดีโอ';
	@override String get autoRewind => 'กรอถอยหลังอัตโนมัติ';
	@override String get rewindAndFastForward => 'ย้อนกลับและเดินหน้าอย่างเร็ว';
	@override String get volumeAndBrightness => 'ระดับเสียงและความสว่าง';
	@override String get centerAreaDoubleTapPauseOrPlay => 'แตะสองครั้งบริเวณตรงกลางเพื่อหยุดหรือเล่น';
	@override String get showVerticalVideoInFullScreen => 'แสดงวิดีโอแนวตั้งในโหมดเต็มหน้าจอ';
	@override String get keepLastVolumeAndBrightness => 'รักษาระดับเสียงและความสว่างล่าสุดไว้';
	@override String get setProxy => 'ตั้งค่าพร็อกซี';
	@override String get moreFeaturesToBeDiscovered => 'ฟีเจอร์เพิ่มเติมรอให้คุณค้นพบ...';
	@override String get videoPlayerSettings => 'การตั้งค่าเครื่องเล่นวิดีโอ';
	@override String commentCount({required Object num}) => '${num} ความคิดเห็น';
	@override String get writeYourCommentHere => 'เขียนความคิดเห็นของคุณที่นี่...';
	@override String get authorOtherVideos => 'วิดีโออื่นของผู้สร้าง';
	@override String get relatedVideos => 'วิดีโอที่เกี่ยวข้อง';
	@override String get privateVideo => 'นี่เป็นวิดีโอส่วนตัว';
	@override String get externalVideo => 'นี่เป็นวิดีโอภายนอก';
	@override String get openInBrowser => 'เปิดในเบราว์เซอร์';
	@override String get resourceDeleted => 'วิดีโอนี้ดูเหมือนจะถูกลบไปแล้ว :/';
	@override String get noDownloadUrl => 'ไม่มี URL ดาวน์โหลด';
	@override String get startDownloading => 'เริ่มดาวน์โหลด';
	@override String get downloadFailed => 'ดาวน์โหลดล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get downloadSuccess => 'ดาวน์โหลดสำเร็จ';
	@override String get download => 'ดาวน์โหลด';
	@override String get downloadManager => 'ตัวจัดการการดาวน์โหลด';
	@override String get resourceNotFound => 'ไม่พบทรัพยากร';
	@override String get videoLoadError => 'เกิดข้อผิดพลาดในการโหลดวิดีโอ';
	@override String get authorNoOtherVideos => 'ผู้สร้างไม่มีวิดีโออื่น';
	@override String get noRelatedVideos => 'ไม่มีวิดีโอที่เกี่ยวข้อง';
	@override late final _TranslationsVideoDetailPlayerTh player = _TranslationsVideoDetailPlayerTh._(_root);
	@override late final _TranslationsVideoDetailSkeletonTh skeleton = _TranslationsVideoDetailSkeletonTh._(_root);
	@override late final _TranslationsVideoDetailCastTh cast = _TranslationsVideoDetailCastTh._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsTh likeAvatars = _TranslationsVideoDetailLikeAvatarsTh._(_root);
}

// Path: share
class _TranslationsShareTh extends TranslationsShareEn {
	_TranslationsShareTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'แชร์เพลย์ลิสต์';
	@override String get wowDidYouSeeThis => 'ว้าว คุณเคยดูอันนี้หรือยัง?';
	@override String get nameIs => 'ชื่อคือ';
	@override String get clickLinkToView => 'คลิกที่ลิงก์เพื่อดู';
	@override String get iReallyLikeThis => 'ฉันชอบสิ่งนี้จริงๆ คุณก็ลองมาดูสิ!';
	@override String get shareFailed => 'การแชร์ล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get share => 'แชร์';
	@override String get shareAsImage => 'แชร์เป็นรูปภาพ';
	@override String get shareAsText => 'แชร์เป็นข้อความ';
	@override String get shareAsImageDesc => 'แชร์หน้าปกวิดีโอเป็นรูปภาพ';
	@override String get shareAsTextDesc => 'แชร์รายละเอียดวิดีโอเป็นข้อความ';
	@override String get shareAsImageFailed => 'แชร์หน้าปกวิดีโอเป็นรูปภาพล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get shareAsTextFailed => 'แชร์รายละเอียดวิดีโอเป็นข้อความล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get shareVideo => 'แชร์วิดีโอ';
	@override String get authorIs => 'ผู้สร้างคือ';
	@override String get shareGallery => 'แชร์แกลเลอรี';
	@override String get galleryTitleIs => 'ชื่อแกลเลอรีคือ';
	@override String get galleryAuthorIs => 'ผู้สร้างแกลเลอรีคือ';
	@override String get shareUser => 'แชร์ผู้ใช้';
	@override String get userNameIs => 'ชื่อผู้ใช้คือ';
	@override String get userAuthorIs => 'ผู้สร้างคือ';
	@override String get comments => 'ความคิดเห็น';
	@override String get shareThread => 'แชร์กระทู้';
	@override String get views => 'การดู';
	@override String get sharePost => 'แชร์โพสต์';
	@override String get postTitleIs => 'ชื่อเรื่องของโพสต์คือ';
	@override String get postAuthorIs => 'ผู้สร้างโพสต์คือ';
}

// Path: markdown
class _TranslationsMarkdownTh extends TranslationsMarkdownEn {
	_TranslationsMarkdownTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'ไวยากรณ์ Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'ไวยากรณ์ Markdown พิเศษของ Iwara';
	@override String get internalLink => 'ลิงก์ภายในเว็บไซต์';
	@override String get supportAutoConvertLinkBelow => 'รองรับการแปลงลิงก์ต่อไปนี้โดยอัตโนมัติ:';
	@override String get convertLinkExample => '🎬 ลิงก์วิดีโอ\n🖼️ ลิงก์รูปภาพ\n👤 ลิงก์ผู้ใช้\n📌 ลิงก์ฟอรัม\n🎵 ลิงก์เพลย์ลิสต์\n💬 ลิงก์กระทู้';
	@override String get mentionUser => 'กล่าวถึงผู้ใช้';
	@override String get mentionUserDescription => 'พิมพ์ @ ตามด้วยชื่อผู้ใช้ ระบบจะแปลงเป็นลิงก์ผู้ใช้โดยอัตโนมัติ';
	@override String get markdownBasicSyntax => 'ไวยากรณ์พื้นฐานของ Markdown';
	@override String get paragraphAndLineBreak => 'ย่อหน้าและการขึ้นบรรทัดใหม่';
	@override String get paragraphAndLineBreakDescription => 'แยกย่อหน้าด้วยการเว้นหนึ่งบรรทัด และการเว้นสองช่องว่างที่ท้ายบรรทัดจะแปลงเป็นการขึ้นบรรทัดใหม่';
	@override String get paragraphAndLineBreakSyntax => 'นี่คือย่อหน้าแรก\n\nนี่คือย่อหน้าที่สอง\nบรรทัดนี้ลงท้ายด้วยสองช่องว่าง  \nจะถูกแปลงเป็นการขึ้นบรรทัดใหม่';
	@override String get textStyle => 'สไตล์ข้อความ';
	@override String get textStyleDescription => 'ใช้สัญลักษณ์พิเศษล้อมรอบข้อความเพื่อเปลี่ยนรูปแบบ';
	@override String get textStyleSyntax => '**ข้อความตัวหนา**\n*ข้อความตัวเอียง*\n~~ข้อความขีดฆ่า~~\n`ข้อความโค้ด`';
	@override String get quote => 'การอ้างอิง';
	@override String get quoteDescription => 'ใช้สัญลักษณ์ > เพื่อสร้างการอ้างอิง ใช้หลายตัว > เพื่อสร้างการอ้างอิงหลายระดับ';
	@override String get quoteSyntax => '> นี่คือการอ้างอิงระดับแรก\n>> นี่คือการอ้างอิงระดับที่สอง';
	@override String get list => 'รายการ';
	@override String get listDescription => 'สร้างรายการแบบมีลำดับด้วย ตัวเลข+จุด สร้างรายการแบบไม่มีลำดับด้วย -';
	@override String get listSyntax => '1. รายการแรก\n2. รายการที่สอง\n\n- รายการแบบไม่มีลำดับ\n  - รายการย่อย\n  - อีกหนึ่งรายการย่อย';
	@override String get linkAndImage => 'ลิงก์และรูปภาพ';
	@override String get linkAndImageDescription => 'รูปแบบลิงก์: [ข้อความ](URL)\nรูปแบบรูปภาพ: ![คำอธิบาย](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[ข้อความลิงก์](${link})\n![คำอธิบายรูปภาพ](${imgUrl})';
	@override String get title => 'หัวข้อ';
	@override String get titleDescription => 'ใช้สัญลักษณ์ # เพื่อสร้างหัวข้อ จำนวนสัญลักษณ์แสดงถึงระดับ';
	@override String get titleSyntax => '# หัวข้อระดับ 1\n## หัวข้อระดับ 2\n### หัวข้อระดับ 3';
	@override String get separator => 'เส้นคั่น';
	@override String get separatorDescription => 'สร้างเส้นคั่นด้วยสัญลักษณ์ - สามตัวขึ้นไป';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'ไวยากรณ์';
}

// Path: forum
class _TranslationsForumTh extends TranslationsForumEn {
	_TranslationsForumTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get attachQuote => 'แนบการอ้างอิง';
	@override String replyToFloor({required Object floor, required Object username}) => 'ตอบกลับ #${floor} @${username}';
	@override String get removeQuote => 'ลบการอ้างอิง';
	@override String get recent => 'ล่าสุด';
	@override String get category => 'หมวดหมู่';
	@override String get lastReply => 'ตอบกลับล่าสุด';
	@override late final _TranslationsForumSitewideTh sitewide = _TranslationsForumSitewideTh._(_root);
	@override late final _TranslationsForumErrorsTh errors = _TranslationsForumErrorsTh._(_root);
	@override String get createPost => 'สร้างโพสต์';
	@override String get title => 'ชื่อเรื่อง';
	@override String get enterTitle => 'ป้อนชื่อเรื่อง';
	@override String get content => 'เนื้อหา';
	@override String get enterContent => 'ป้อนเนื้อหา';
	@override String get writeYourContentHere => 'เขียนเนื้อหาของคุณที่นี่...';
	@override String get posts => 'โพสต์';
	@override String get threads => 'กระทู้';
	@override String get forum => 'ฟอรัม';
	@override String get createThread => 'สร้างกระทู้';
	@override String get selectCategory => 'เลือกหมวดหมู่';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'เหลือเวลาคูลดาวน์อีก ${minutes} นาที ${seconds} วินาที';
	@override late final _TranslationsForumGroupsTh groups = _TranslationsForumGroupsTh._(_root);
	@override late final _TranslationsForumLeafNamesTh leafNames = _TranslationsForumLeafNamesTh._(_root);
	@override late final _TranslationsForumLeafDescriptionsTh leafDescriptions = _TranslationsForumLeafDescriptionsTh._(_root);
	@override String get reply => 'ตอบกลับ';
	@override String get pendingReview => 'กำลังรอการตรวจสอบ';
	@override String get floorNotFound => 'ไม่พบความคิดเห็นนี้หรือถูกลบไปแล้ว';
	@override String get floorNotLoadedYet => 'ความคิดเห็นนี้อยู่ด้านบน โหลดเพิ่มเติมเพื่อข้ามไป';
	@override String get editedAt => 'แก้ไขเมื่อ';
	@override String get copySuccess => 'คัดลอกไปยังคลิปบอร์ดแล้ว';
	@override String copySuccessForMessage({required Object str}) => 'คัดลอกไปยังคลิปบอร์ดแล้ว: ${str}';
	@override String get editReply => 'แก้ไขการตอบกลับ';
	@override String get editTitle => 'แก้ไขชื่อเรื่อง';
	@override String get submit => 'ส่ง';
}

// Path: notifications
class _TranslationsNotificationsTh extends TranslationsNotificationsEn {
	_TranslationsNotificationsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsTh errors = _TranslationsNotificationsErrorsTh._(_root);
	@override String get notifications => 'การแจ้งเตือน';
	@override String get profile => 'หน้าโปรไฟล์';
	@override String get postedNewComment => 'แสดงความคิดเห็นใหม่';
	@override String get inYour => 'ใน';
	@override String get video => 'วิดีโอ';
	@override String get repliedYourVideoComment => 'ตอบกลับความคิดเห็นวิดีโอของคุณ';
	@override String get copyInfoToClipboard => 'คัดลอกข้อมูลการแจ้งเตือนไปยังคลิปบอร์ด';
	@override String get copySuccess => 'คัดลอกไปยังคลิปบอร์ดแล้ว';
	@override String copySuccessForMessage({required Object str}) => 'คัดลอกไปยังคลิปบอร์ดแล้ว: ${str}';
	@override String get markAllAsRead => 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมด';
	@override String get markAllAsReadSuccess => 'ทำเครื่องหมายว่าอ่านแล้วทุกการแจ้งเตือน';
	@override String get markAllAsReadFailed => 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมดล้มเหลว';
	@override String get markSelectedAsRead => 'ทำเครื่องหมายรายการที่เลือกว่าอ่านแล้ว';
	@override String get markSelectedAsReadSuccess => 'ทำเครื่องหมายการแจ้งเตือนที่เลือกว่าอ่านแล้ว';
	@override String get markSelectedAsReadFailed => 'ทำเครื่องหมายรายการที่เลือกว่าอ่านแล้วล้มเหลว';
	@override String get markAsRead => 'ทำเครื่องหมายว่าอ่านแล้ว';
	@override String get markAsReadSuccess => 'ทำเครื่องหมายการแจ้งเตือนว่าอ่านแล้ว';
	@override String get markAsReadFailed => 'ทำเครื่องหมายการแจ้งเตือนว่าอ่านแล้วล้มเหลว';
	@override String get notificationTypeHelp => 'ความช่วยเหลือเกี่ยวกับประเภทการแจ้งเตือน';
	@override String get dueToLackOfNotificationTypeDetails => 'เนื่องจากขาดรายละเอียดของประเภทการแจ้งเตือน ประเภทที่รองรับในปัจจุบันอาจไม่ครอบคลุมข้อความที่คุณได้รับ';
	@override String get helpUsImproveNotificationTypeSupport => 'หากคุณยินดีที่จะช่วยเราปรับปรุงการรองรับประเภทการแจ้งเตือน';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 คัดลอกข้อมูลการแจ้งเตือน\n2. 🐞 ส่ง issue ไปยังที่เก็บข้อมูลโปรเจกต์\n\n⚠️ หมายเหตุ: ข้อมูลการแจ้งเตือนอาจมีความเป็นส่วนตัว หากคุณไม่ต้องการเปิดเผยสู่สาธารณะ คุณสามารถส่งไปยังอีเมลของผู้สร้างโปรเจกต์ได้';
	@override String get goToRepository => 'ไปยังคลังเก็บโค้ด (Repository)';
	@override String get copy => 'คัดลอก';
	@override String get commentApproved => 'ความคิดเห็นได้รับการอนุมัติแล้ว';
	@override String get repliedYourProfileComment => 'ตอบกลับความคิดเห็นในหน้าโปรไฟล์ของคุณ';
	@override String get kReplied => 'ตอบกลับความคิดเห็นของคุณบน';
	@override String get kCommented => 'แสดงความคิดเห็นบน';
	@override String get kVideo => 'วิดีโอ';
	@override String get kGallery => 'แกลเลอรี';
	@override String get kProfile => 'โปรไฟล์';
	@override String get kThread => 'กระทู้';
	@override String get kPost => 'โพสต์';
	@override String get kCommentSection => 'ในส่วนความคิดเห็น';
	@override String get kApprovedComment => 'อนุมัติความคิดเห็นแล้ว';
	@override String get kApprovedVideo => 'อนุมัติวิดีโอแล้ว';
	@override String get kApprovedGallery => 'อนุมัติแกลเลอรีแล้ว';
	@override String get kApprovedThread => 'อนุมัติกระทู้แล้ว';
	@override String get kApprovedPost => 'อนุมัติโพสต์แล้ว';
	@override String get kApprovedForumPost => 'อนุมัติโพสต์ฟอรัมแล้ว';
	@override String get kRejectedContent => 'การตรวจสอบเนื้อหาถูกปฏิเสธ';
	@override String get kUnknownType => 'ประเภทการแจ้งเตือนที่ไม่รู้จัก';
}

// Path: conversation
class _TranslationsConversationTh extends TranslationsConversationEn {
	_TranslationsConversationTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsTh errors = _TranslationsConversationErrorsTh._(_root);
	@override String get conversation => 'บทสนทนา';
	@override String get startConversation => 'เริ่มต้นบทสนทนา';
	@override String get noConversation => 'ไม่มีบทสนทนา';
	@override String get selectFromLeftListAndStartConversation => 'เลือกจากรายการด้านซ้ายและเริ่มการสนทนา';
	@override String get title => 'ชื่อเรื่อง';
	@override String get body => 'เนื้อหา';
	@override String get selectAUser => 'เลือกผู้ใช้';
	@override String get searchUsers => 'ค้นหาผู้ใช้...';
	@override String get tmpNoConversions => 'ยังไม่มีบทสนทนา';
	@override String get deleteThisMessage => 'ลบข้อความนี้';
	@override String get deleteThisMessageSubtitle => 'การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String get writeMessageHere => 'เขียนข้อความที่นี่...';
	@override String get lastMessageFromMe => 'คุณ: ';
	@override String get sendMessage => 'ส่งข้อความ';
}

// Path: splash
class _TranslationsSplashTh extends TranslationsSplashEn {
	_TranslationsSplashTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsTh errors = _TranslationsSplashErrorsTh._(_root);
	@override String get preparing => 'กำลังเตรียมการ...';
	@override String get initializing => 'กำลังเริ่มต้นระบบ...';
	@override String get loading => 'กำลังโหลด...';
	@override String get ready => 'พร้อมใช้งาน';
	@override String get initializingMessageService => 'กำลังเริ่มต้นบริการข้อความ...';
}

// Path: download
class _TranslationsDownloadTh extends TranslationsDownloadEn {
	_TranslationsDownloadTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsTh errors = _TranslationsDownloadErrorsTh._(_root);
	@override String get downloadList => 'รายการดาวน์โหลด';
	@override String get viewDownloadList => 'ดูรายการดาวน์โหลด';
	@override String get download => 'ดาวน์โหลด';
	@override String get selectDownloadTitle => 'เลือกการดาวน์โหลด';
	@override String get qualitySectionLabel => 'ความละเอียด';
	@override String get categorySectionLabel => 'หมวดหมู่';
	@override String get saveToPreviewLabel => 'จะบันทึกไปที่';
	@override String saveToPreviewSuggested({required Object name}) => 'ชื่อไฟล์ที่แนะนำ: ${name} (แก้ไขได้ในกล่องโต้ตอบระบบ)';
	@override String get lastUsedBadge => 'ใช้ล่าสุด';
	@override String get pickedBadge => 'เลือกแล้ว';
	@override String get startDownloading => 'เริ่มการดาวน์โหลด';
	@override String get clearAllFailedTasks => 'ล้างงานที่ล้มเหลวทั้งหมด';
	@override String get clearAllFailedTasksConfirmation => 'คุณแน่ใจหรือไม่ว่าต้องการล้างงานดาวน์โหลดที่ล้มเหลวทั้งหมด? ไฟล์ของงานเหล่านี้จะถูกลบไปด้วย';
	@override String get clearAllFailedTasksSuccess => 'ล้างงานที่ล้มเหลวทั้งหมดแล้ว';
	@override String get clearAllFailedTasksError => 'เกิดข้อผิดพลาดขณะล้างงานที่ล้มเหลว';
	@override String get downloadStatus => 'สถานะการดาวน์โหลด';
	@override String get imageList => 'รายการรูปภาพ';
	@override String get retryDownload => 'ลองดาวน์โหลดใหม่';
	@override String get notDownloaded => 'ยังไม่ได้ดาวน์โหลด';
	@override String get downloaded => 'ดาวน์โหลดแล้ว';
	@override String get waitingForDownload => 'กำลังรอการดาวน์โหลด';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'กำลังดาวน์โหลด (${downloaded}/${total} ภาพ ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'กำลังดาวน์โหลด (${downloaded} ภาพ)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'หยุดชั่วคราว (${downloaded}/${total} ภาพ ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'หยุดชั่วคราว (${downloaded} ภาพ)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'ดาวน์โหลดเสร็จสมบูรณ์ (ทั้งหมด ${total} ภาพ)';
	@override String get viewVideoDetail => 'ดูรายละเอียดวิดีโอ';
	@override String get viewGalleryDetail => 'ดูรายละเอียดแกลเลอรี';
	@override String get moreOptions => 'ตัวเลือกเพิ่มเติม';
	@override String get openFile => 'เปิดไฟล์';
	@override String get playLocally => 'เล่นในเครื่อง';
	@override String get pause => 'หยุดชั่วคราว';
	@override String get resume => 'ทำต่อ';
	@override String get copyDownloadUrl => 'คัดลอก URL ดาวน์โหลด';
	@override String get showInFolder => 'แสดงในโฟลเดอร์';
	@override String get deleteTask => 'ลบงาน';
	@override String get deleteTaskConfirmation => 'คุณแน่ใจหรือไม่ว่าต้องการลบงานดาวน์โหลดนี้?\nไฟล์ของงานจะถูกลบไปด้วย';
	@override String get forceDeleteTask => 'บังคับลบงาน';
	@override String get forceDeleteTaskConfirmation => 'คุณแน่ใจหรือไม่ว่าต้องการบังคับลบงานดาวน์โหลดนี้?\nไฟล์ของงานจะถูกลบไปด้วย แม้ว่าไฟล์นั้นกำลังถูกใช้งานอยู่ก็ตาม';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'หยุดชั่วคราว ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'หยุดชั่วคราว • ดาวน์โหลดแล้ว ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'ดาวน์โหลดเสร็จสมบูรณ์ • ${size}';
	@override String get copyDownloadUrlSuccess => 'คัดลอก URL ดาวน์โหลดแล้ว';
	@override String totalImageNums({required Object num}) => '${num} ภาพ';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'กำลังดาวน์โหลด';
	@override String get failed => 'ล้มเหลว';
	@override String get completed => 'เสร็จสมบูรณ์';
	@override String get downloadDetail => 'รายละเอียดการดาวน์โหลด';
	@override String get copy => 'คัดลอก';
	@override String get copySuccess => 'คัดลอกแล้ว';
	@override String get waiting => 'กำลังรอ';
	@override String get paused => 'หยุดชั่วคราว';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'กำลังดาวน์โหลด ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'ดาวน์โหลดแกลเลอรีเสร็จสมบูรณ์: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'ดาวน์โหลดเสร็จสมบูรณ์: ${fileName}';
	@override String get searchTasks => 'ค้นหางาน...';
	@override String statusLabel({required Object label}) => 'สถานะ: ${label}';
	@override String get allStatus => 'ทุกสถานะ';
	@override String typeLabel({required Object label}) => 'ประเภท: ${label}';
	@override String get allTypes => 'ทุกประเภท';
	@override String get taskType => 'ประเภท';
	@override String get video => 'วิดีโอ';
	@override String get gallery => 'แกลเลอรี';
	@override String get other => 'อื่นๆ';
	@override String get clearFilters => 'ล้างตัวกรอง';
	@override String get pauseAll => 'หยุดชั่วคราวทั้งหมด';
	@override String get resumeAll => 'เริ่มทั้งหมด';
	@override String remainingTime({required Object time}) => 'เหลือ ${time}';
	@override late final _TranslationsDownloadTimelineTh timeline = _TranslationsDownloadTimelineTh._(_root);
	@override late final _TranslationsDownloadErrorTypesTh errorTypes = _TranslationsDownloadErrorTypesTh._(_root);
	@override String get errorDetailCopied => 'คัดลอกรายละเอียดข้อผิดพลาดแล้ว';
	@override String get errorDetailCopyHint => 'กดค้างเพื่อคัดลอกรายละเอียดข้อผิดพลาด';
	@override late final _TranslationsDownloadRestoredPausedTh restoredPaused = _TranslationsDownloadRestoredPausedTh._(_root);
	@override late final _TranslationsDownloadActionsTh actions = _TranslationsDownloadActionsTh._(_root);
	@override late final _TranslationsDownloadNoticeTh notice = _TranslationsDownloadNoticeTh._(_root);
	@override String get emptyTaskList => 'ยังไม่มีงานดาวน์โหลด';
	@override String get noMatchingTasks => 'ไม่มีงานที่ตรงกัน';
	@override late final _TranslationsDownloadDeleteByDateTh deleteByDate = _TranslationsDownloadDeleteByDateTh._(_root);
	@override late final _TranslationsDownloadRelocationTh relocation = _TranslationsDownloadRelocationTh._(_root);
	@override late final _TranslationsDownloadCategoryTh category = _TranslationsDownloadCategoryTh._(_root);
	@override late final _TranslationsDownloadLocationTh location = _TranslationsDownloadLocationTh._(_root);
	@override String get maxConcurrentDownloads => 'จำนวนการดาวน์โหลดพร้อมกันสูงสุด';
	@override String get maxConcurrentDownloadsDesc => 'จำนวนงานที่ดาวน์โหลดในเวลาเดียวกัน (1-5)';
	@override String get stillInDevelopment => 'ยังอยู่ระหว่างการพัฒนา';
	@override String get saveToAppDirectory => 'บันทึกไปยังโฟลเดอร์ของแอป';
	@override String get alreadyDownloadedWithQuality => 'ดาวน์โหลดด้วยความละเอียดเดียวกันนี้แล้ว ดำเนินการดาวน์โหลดต่อหรือไม่?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'ดาวน์โหลดด้วยความละเอียดต่อไปนี้แล้ว: ${qualities} ดำเนินการดาวน์โหลดต่อหรือไม่?';
	@override String get otherQualities => 'ความละเอียดอื่นๆ';
	@override late final _TranslationsDownloadBatchDownloadTh batchDownload = _TranslationsDownloadBatchDownloadTh._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsTh extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'การดาวน์โหลดเสร็จสมบูรณ์';
	@override String get failedTitle => 'การดาวน์โหลดล้มเหลว';
	@override String completedBody({required Object name}) => 'ดาวน์โหลด ${name} สำเร็จแล้ว';
	@override String failedBody({required Object name}) => 'ดาวน์โหลด ${name} ล้มเหลว';
	@override String completedToast({required Object name}) => 'ดาวน์โหลด ${name} แล้ว';
	@override String failedToast({required Object name}) => 'ดาวน์โหลด ${name} ล้มเหลว';
	@override String savedToFolder({required Object dir}) => 'บันทึกไปที่ ${dir} แล้ว';
	@override String savedAsRenamed({required Object name}) => 'บันทึกเป็น ${name} แล้ว (มีไฟล์ชื่อเดียวกันอยู่แล้ว)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'บันทึกไปที่โฟลเดอร์ของแอปแล้ว — เขียนลง ${target} ไม่ได้ (${reason})';
	@override String get viewFolder => 'ดูโฟลเดอร์';
	@override String get fixInSettings => 'แก้ไขในการตั้งค่า';
	@override String get channelName => 'สถานะการดาวน์โหลด';
	@override String get channelDescription => 'การแจ้งเตือนสำหรับการดาวน์โหลดที่เสร็จสมบูรณ์และล้มเหลว';
}

// Path: favorite
class _TranslationsFavoriteTh extends TranslationsFavoriteEn {
	_TranslationsFavoriteTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsTh errors = _TranslationsFavoriteErrorsTh._(_root);
	@override String get add => 'เพิ่ม';
	@override String get addSuccess => 'เพิ่มสำเร็จ';
	@override String get addFailed => 'เพิ่มไม่สำเร็จ';
	@override String get remove => 'ลบออก';
	@override String get removeSuccess => 'ลบออกสำเร็จ';
	@override String get removeFailed => 'ลบออกไม่สำเร็จ';
	@override String get removeConfirmation => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้ออกจากรายการโปรด?';
	@override String get removeConfirmationSuccess => 'ลบรายการออกจากรายการโปรดแล้ว';
	@override String get removeConfirmationFailed => 'ลบรายการออกจากรายการโปรดไม่สำเร็จ';
	@override String get createFolderSuccess => 'สร้างโฟลเดอร์สำเร็จแล้ว';
	@override String get createFolderFailed => 'สร้างโฟลเดอร์ไม่สำเร็จ';
	@override String get createFolder => 'สร้างโฟลเดอร์';
	@override String get enterFolderName => 'ป้อนชื่อโฟลเดอร์';
	@override String get enterFolderNameHere => 'ป้อนชื่อโฟลเดอร์ที่นี่...';
	@override String get create => 'สร้าง';
	@override String get items => 'รายการ';
	@override String get newFolderName => 'โฟลเดอร์ใหม่';
	@override String get searchFolders => 'ค้นหาโฟลเดอร์...';
	@override String get searchItems => 'ค้นหารายการ...';
	@override String get createdAt => 'สร้างเมื่อ';
	@override String get myFavorites => 'รายการโปรดของฉัน';
	@override String get deleteFolderTitle => 'ลบโฟลเดอร์';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบโฟลเดอร์ ${title}?';
	@override String get removeItemTitle => 'ลบรายการ';
	@override String removeItemConfirmWithTitle({required Object title}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการ ${title}?';
	@override String get removeItemSuccess => 'ลบรายการออกจากรายการโปรดแล้ว';
	@override String get removeItemFailed => 'ลบรายการออกจากรายการโปรดไม่สำเร็จ';
	@override String get localizeFavorite => 'รายการโปรดในเครื่อง';
	@override String get editFolderTitle => 'แก้ไขโฟลเดอร์';
	@override String get editFolderSuccess => 'อัปเดตโฟลเดอร์สำเร็จแล้ว';
	@override String get editFolderFailed => 'อัปเดตโฟลเดอร์ไม่สำเร็จ';
	@override String get searchTags => 'ค้นหาแท็ก';
	@override String get noTagsInFolder => 'ยังไม่มีแท็กในรายการของโฟลเดอร์นี้';
	@override String get tagFilterMatchAll => 'แสดงเฉพาะรายการที่มีครบทุกแท็กที่เลือก';
	@override String get clearSelectedTags => 'ล้างแท็กที่เลือก';
	@override String selectedTagCount({required Object count}) => 'เลือกแล้ว ${count} แท็ก';
	@override String get noMatchingTags => 'ไม่มีแท็กที่ตรงกัน';
}

// Path: translation
class _TranslationsTranslationTh extends TranslationsTranslationEn {
	_TranslationsTranslationTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'บริการปัจจุบัน';
	@override String get testConnection => 'ทดสอบการเชื่อมต่อ';
	@override String get testConnectionSuccess => 'ทดสอบการเชื่อมต่อสำเร็จ';
	@override String get testConnectionFailed => 'ทดสอบการเชื่อมต่อล้มเหลว';
	@override String testConnectionFailedWithMessage({required Object message}) => 'ทดสอบการเชื่อมต่อล้มเหลว: ${message}';
	@override String get translation => 'การแปลภาษา';
	@override String get needVerification => 'จำเป็นต้องยืนยัน';
	@override String get needVerificationContent => 'โปรดทดสอบการเชื่อมต่อก่อนเปิดใช้งานการแปลภาษาด้วย AI';
	@override String get confirm => 'ยืนยัน';
	@override String get disclaimer => 'ข้อจำกัดความรับผิดชอบ';
	@override String get riskWarning => 'คำเตือนเกี่ยวกับความเสี่ยง';
	@override String get dureToRisk1 => 'เนื่องจากข้อความถูกสร้างโดยผู้ใช้ จึงอาจมีเนื้อหาที่ละเมิดนโยบายเนื้อหาของผู้ให้บริการ AI';
	@override String get dureToRisk2 => 'เนื้อหาที่ไม่เหมาะสมอาจนำไปสู่การระงับคีย์ API หรือการยุติบริการ';
	@override String get operationSuggestion => 'คำแนะนำการใช้งาน';
	@override String get operationSuggestion1 => '1. ตรวจสอบเนื้อหาที่จะแปลอย่างรอบคอบก่อนใช้งาน';
	@override String get operationSuggestion2 => '2. หลีกเลี่ยงการแปลเนื้อหาเกี่ยวกับความรุนแรง เนื้อหาสำหรับผู้ใหญ่ ฯลฯ';
	@override String get apiConfig => 'การกำหนดค่า API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'การแก้ไขการกำหนดค่าจะปิดการแปลด้วย AI โดยอัตโนมัติ และต้องทดสอบใหม่อีกครั้งหลังจากเปิด';
	@override String get apiAddress => 'ที่อยู่ API';
	@override String get modelName => 'ชื่อโมเดล';
	@override String get modelNameHintText => 'ตัวอย่างเช่น: gpt-4-turbo';
	@override String get maxTokens => 'โทเค็นสูงสุด (Max Tokens)';
	@override String get maxTokensHintText => 'ตัวอย่างเช่น: 32000';
	@override String get temperature => 'อุณหภูมิ (Temperature)';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'คลิกปุ่มทดสอบเพื่อยืนยันความถูกต้องของการเชื่อมต่อ API';
	@override String get requestPreview => 'ตัวอย่างคำขอ';
	@override String get enableAITranslation => 'เปิดใช้งาน AI';
	@override String get enabled => 'เปิดใช้งานแล้ว';
	@override String get disabled => 'ปิดใช้งานแล้ว';
	@override String get testing => 'กำลังทดสอบ...';
	@override String get testNow => 'ทดสอบทันที';
	@override String get connectionStatus => 'สถานะการเชื่อมต่อ';
	@override String get success => 'สำเร็จ';
	@override String get failed => 'ล้มเหลว';
	@override String get information => 'ข้อมูล';
	@override String get viewRawResponse => 'ดูการตอบกลับดิบ';
	@override String get pleaseCheckInputParametersFormat => 'โปรดตรวจสอบรูปแบบพารามิเตอร์ที่ป้อน';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'โปรดกรอกที่อยู่ API ชื่อโมเดล และคีย์';
	@override String get pleaseFillInValidConfigurationParameters => 'โปรดกรอกพารามิเตอร์การกำหนดค่าที่ถูกต้อง';
	@override String get pleaseCompleteConnectionTest => 'โปรดทำการทดสอบการเชื่อมต่อให้เสร็จสิ้น';
	@override String get notConfigured => 'ยังไม่ได้กำหนดค่า';
	@override String get apiEndpoint => 'ปลายทาง API (Endpoint)';
	@override String get configuredKey => 'กำหนดค่าคีย์แล้ว';
	@override String get notConfiguredKey => 'ยังไม่ได้กำหนดค่าคีย์';
	@override String get authenticationStatus => 'สถานะการรับรองความถูกต้อง';
	@override String get thisFieldCannotBeEmpty => 'ฟิลด์นี้ต้องไม่ว่างเปล่า';
	@override String get apiKey => 'คีย์ API';
	@override String get apiKeyCannotBeEmpty => 'คีย์ API ต้องไม่ว่างเปล่า';
	@override String get pleaseEnterValidNumber => 'โปรดป้อนตัวเลขที่ถูกต้อง';
	@override String get range => 'ช่วง';
	@override String get mustBeGreaterThan => 'ต้องมากกว่า';
	@override String get invalidAPIResponse => 'การตอบกลับของ API ไม่ถูกต้อง';
	@override String connectionFailedForMessage({required Object message}) => 'การเชื่อมต่อล้มเหลว: ${message}';
	@override String get aiTranslationNotEnabledHint => 'การแปลด้วย AI ยังไม่ได้เปิดใช้งาน โปรดเปิดใช้งานในการตั้งค่า';
	@override String get goToSettings => 'ไปที่การตั้งค่า';
	@override String get disableAITranslation => 'ปิดใช้งานการแปลด้วย AI';
	@override String get currentValue => 'ค่าปัจจุบัน';
	@override String get configureTranslationStrategy => 'กำหนดค่ากลยุทธ์การแปล';
	@override String get advancedSettings => 'การตั้งค่าขั้นสูง';
	@override String get translationPrompt => 'พรอมต์การแปลภาษา';
	@override String get promptHint => 'โปรดป้อนพรอมต์การแปล โดยใช้ [TL] เป็นตัวแทนสำหรับภาษาเป้าหมาย';
	@override String get promptHelperText => 'พรอมต์ต้องมี [TL] เป็นตัวแทนสำหรับภาษาเป้าหมาย';
	@override String get promptMustContainTargetLang => 'พรอมต์ต้องมีตัวแทน [TL]';
	@override String get aiTranslationWillBeDisabled => 'การแปลด้วย AI จะถูกปิดใช้งาน';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'เนื่องจากมีการเปลี่ยนแปลงการกำหนดค่าพื้นฐาน การแปลด้วย AI จะถูกปิดใช้งาน';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'เนื่องจากมีการเปลี่ยนแปลงพรอมต์การแปล การแปลด้วย AI จะถูกปิดใช้งาน';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'เนื่องจากมีการเปลี่ยนแปลงการกำหนดค่าพารามิเตอร์ การแปลด้วย AI จะถูกปิดใช้งาน';
	@override String get onlyOpenAIAPISupported => 'ขณะนี้รองรับเฉพาะรูปแบบ API ที่เข้ากันได้กับ OpenAI เท่านั้น (เนื้อหาคำขอแบบ application/json)';
	@override String get streamingTranslation => 'การแปลแบบสตรีมมิง';
	@override String get streamingTranslationSupported => 'รองรับการแปลแบบสตรีมมิง';
	@override String get streamingTranslationNotSupported => 'ไม่รองรับการแปลแบบสตรีมมิง';
	@override String get streamingTranslationDescription => 'การแปลแบบสตรีมมิงสามารถแสดงผลลัพธ์แบบเรียลไทม์ระหว่างกระบวนการแปล ทำให้ผู้ใช้ได้รับประสบการณ์ที่ดียิ่งขึ้น';
	@override String get usingFullUrlWithHash => 'ใช้ URL แบบเต็ม (ลงท้ายด้วย #)';
	@override String get baseUrlInputHelperText => 'เมื่อลงท้ายด้วย # จะถูกใช้เป็นที่อยู่คำขอจริง';
	@override String currentActualUrl({required Object url}) => 'URL จริงในปัจจุบัน: ${url}';
	@override String get urlEndingWithHashTip => 'URL ที่ลงท้ายด้วย # จะถูกใช้โดยตรงโดยไม่มีการต่อท้ายใดๆ';
	@override String get streamingTranslationWarning => 'หมายเหตุ: คุณสมบัตินี้ต้องการบริการ API ที่รองรับการส่งข้อมูลแบบสตรีมมิง โมเดลบางตัวอาจไม่รองรับ';
	@override String get translationService => 'บริการแปลภาษา';
	@override String get translationServiceDescription => 'เลือกบริการแปลภาษาที่คุณต้องการ';
	@override String get googleTranslation => 'การแปลภาษาของ Google';
	@override String get googleTranslationDescription => 'บริการแปลภาษาออนไลน์ฟรีที่รองรับหลายภาษา';
	@override String get aiTranslation => 'การแปลภาษาด้วย AI';
	@override String get aiTranslationDescription => 'บริการแปลภาษาอัจฉริยะที่ใช้โมเดลภาษาขนาดใหญ่';
	@override String get deeplxTranslation => 'การแปลภาษา DeepLX';
	@override String get deeplxTranslationDescription => 'การนำ DeepL ไปใช้แบบโอเพนซอร์ส ให้การแปลคุณภาพสูง';
	@override String get googleTranslationFeatures => 'คุณสมบัติ';
	@override String get freeToUse => 'ใช้งานฟรี';
	@override String get freeToUseDescription => 'ไม่ต้องกำหนดค่าใดๆ พร้อมใช้งานทันที';
	@override String get fastResponse => 'ตอบสนองรวดเร็ว';
	@override String get fastResponseDescription => 'ความเร็วในการแปลรวดเร็ว มีความหน่วงต่ำ';
	@override String get stableAndReliable => 'เสถียรและเชื่อถือได้';
	@override String get stableAndReliableDescription => 'ทำงานบน API ทางการของ Google';
	@override String get enabledDefaultService => 'เปิดใช้งานแล้ว - บริการแปลภาษาเริ่มต้น';
	@override String get notEnabled => 'ยังไม่เปิดใช้งาน';
	@override String get deeplxTranslationService => 'บริการแปลภาษา DeepLX';
	@override String get deeplxDescription => 'DeepLX คือการนำ DeepL ไปใช้แบบโอเพนซอร์ส รองรับโหมดปลายทางแบบ Free, Pro และ Official';
	@override String get serverAddress => 'ที่อยู่เซิร์ฟเวอร์';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'ที่อยู่พื้นฐานของเซิร์ฟเวอร์ DeepLX';
	@override String get endpointType => 'ประเภทปลายทาง (Endpoint)';
	@override String get freeEndpoint => 'Free - ปลายทางฟรี อาจมีการจำกัดอัตราการเรียกใช้';
	@override String get proEndpoint => 'Pro - ต้องใช้ dl_session มีความเสถียรมากกว่า';
	@override String get officialEndpoint => 'Official - รูปแบบ API ทางการ';
	@override String get finalRequestUrl => 'URL คำขอขั้นสุดท้าย';
	@override String get apiKeyOptional => 'คีย์ API (ไม่บังคับ)';
	@override String get apiKeyOptionalHint => 'สำหรับเข้าถึงบริการ DeepLX ที่ได้รับการปกป้อง';
	@override String get apiKeyOptionalHelperText => 'บริการ DeepLX บางแห่งจำเป็นต้องใช้คีย์ API ในการตรวจสอบสิทธิ์';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'พารามิเตอร์ dl_session ที่จำเป็นสำหรับโหมด Pro';
	@override String get dlSessionHelperText => 'พารามิเตอร์เซสชันที่จำเป็นสำหรับปลายทาง Pro โดยรับได้จากบัญชี DeepL Pro';
	@override String get proModeRequiresDlSession => 'โหมด Pro ต้องระบุ dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'คลิกปุ่มทดสอบเพื่อตรวจสอบการเชื่อมต่อ DeepLX API';
	@override String get enableDeepLXTranslation => 'เปิดใช้งานการแปลภาษา DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'การแปลภาษา DeepLX จะถูกปิดใช้งานเนื่องจากการเปลี่ยนแปลงการกำหนดค่า';
	@override String get translatedResult => 'ผลลัพธ์การแปล';
	@override String get testSuccess => 'การทดสอบสำเร็จ';
	@override String get pleaseFillInDeepLXServerAddress => 'โปรดกรอกที่อยู่เซิร์ฟเวอร์ DeepLX';
	@override String get invalidAPIResponseFormat => 'รูปแบบการตอบกลับของ API ไม่ถูกต้อง';
	@override String get translationServiceReturnedError => 'บริการแปลส่งคืนข้อผิดพลาดหรือผลลัพธ์ว่างเปล่า';
	@override String get connectionFailed => 'การเชื่อมต่อล้มเหลว';
	@override String get translationFailed => 'การแปลภาษาล้มเหลว';
	@override String get aiTranslationFailed => 'การแปลด้วย AI ล้มเหลว';
	@override String get deeplxTranslationFailed => 'การแปลด้วย DeepLX ล้มเหลว';
	@override String get aiTranslationTestFailed => 'การทดสอบการแปลด้วย AI ล้มเหลว';
	@override String get deeplxTranslationTestFailed => 'การทดสอบการแปลด้วย DeepLX ล้มเหลว';
	@override String get streamingTranslationTimeout => 'การแปลแบบสตรีมมิงหมดเวลา บังคับล้างทรัพยากร';
	@override String get translationRequestTimeout => 'คำขอการแปลภาษาหมดเวลา';
	@override String get streamingTranslationDataTimeout => 'การรับข้อมูลการแปลแบบสตรีมมิงหมดเวลา';
	@override String get dataReceptionTimeout => 'การรับข้อมูลหมดเวลา';
	@override String get streamDataParseError => 'เกิดข้อผิดพลาดในการแยกวิเคราะห์ข้อมูลสตรีม';
	@override String get streamingTranslationFailed => 'การแปลแบบสตรีมมิงล้มเหลว';
	@override String get fallbackTranslationFailed => 'การเปลี่ยนกลับไปใช้การแปลแบบปกติก็ล้มเหลวเช่นกัน';
	@override String get translationSettings => 'การตั้งค่าการแปลภาษา';
	@override String get enableGoogleTranslation => 'เปิดใช้งาน Google Translation';
	@override String get thinking => 'กำลังคิด…';
	@override String get thoughtProcess => 'กระบวนการคิด';
	@override String get modelCompatibility => 'ความเข้ากันได้ของโมเดล';
	@override String get modelCompatibilityDescription => 'ปรับพารามิเตอร์คำขอสำหรับโมเดลสมัยใหม่ เช่น โมเดลการให้เหตุผล (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'โมเดลการให้เหตุผล (Reasoning Model)';
	@override String get reasoningModelDescription => 'สำหรับ o1/o3, DeepSeek-R1, QwQ ฯลฯ รวมพรอมต์เข้ากับข้อความของผู้ใช้ ละเว้น temperature และใช้ max_completion_tokens แทน';
	@override String get useMaxCompletionTokens => 'ใช้ max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'ปลายทาง OpenAI รุ่นใหม่ต้องการ max_completion_tokens แทน max_tokens ที่เลิกใช้แล้ว';
	@override String get sendTemperature => 'ส่ง temperature';
	@override String get sendTemperatureDescription => 'ปิดสำหรับโมเดลที่ปฏิเสธพารามิเตอร์ temperature (โมเดลการให้เหตุผลส่วนใหญ่)';
	@override String get showReasoningProcess => 'แสดงกระบวนการคิด';
	@override String get showReasoningProcessDescription => 'แสดงการให้เหตุผลที่สามารถยุบเก็บได้ของโมเดลการให้เหตุผลในกล่องโต้ตอบการแปล';
	@override String get provider => 'ผู้ให้บริการ';
	@override String get providerOpenAI => 'OpenAI (และที่เข้ากันได้)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'รองรับ OpenAI (และปลายทางใดๆ ที่เข้ากันได้กับ OpenAI), Anthropic และ Google ผ่าน dartantic_ai SDK';
	@override String get baseUrlOptionalHelperText => 'ไม่บังคับ เว้นว่างไว้เพื่อใช้ปลายทางเริ่มต้นของผู้ให้บริการ กรอกสำหรับปลายทางที่เข้ากันได้กับ OpenAI หรือรีเลย์';
	@override String get defaultEndpoint => 'ปลายทางเริ่มต้น';
	@override String get providerPreset => 'ค่าที่ตั้งล่วงหน้าของผู้ให้บริการ';
	@override String get selectProviderPreset => 'เลือกค่าที่ตั้งล่วงหน้า';
	@override String get presetCustom => 'กำหนดเอง';
	@override String presetApplied({required Object name}) => 'ใช้ค่าที่ตั้งล่วงหน้าแล้ว: ${name}';
	@override late final _TranslationsTranslationPresetNamesTh presetNames = _TranslationsTranslationPresetNamesTh._(_root);
	@override String get fetchModelList => 'ดึงรายการโมเดล';
	@override String get fetchingModels => 'กำลังดึงข้อมูล…';
	@override String get selectModel => 'เลือกโมเดล';
	@override String get searchModel => 'ค้นหาโมเดล';
	@override String get noModelsFound => 'ไม่พบโมเดล';
}

// Path: bottomNav
class _TranslationsBottomNavTh extends TranslationsBottomNavEn {
	_TranslationsBottomNavTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get video => 'วิดีโอ';
	@override String get gallery => 'แกลเลอรี';
	@override String get subscription => 'ติดตาม';
	@override String get community => 'ชุมชน';
	@override String get localMedia => 'ไฟล์';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsTh extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าลำดับการนำทาง';
	@override String get customNavigationOrder => 'กำหนดลำดับการนำทางเอง';
	@override String get customNavigationOrderDesc => 'ลากเพื่อปรับลำดับการแสดงผลของหน้าต่างๆ ในแถบนำทางด้านล่างและแถบด้านข้าง';
	@override String get restartRequired => 'จำเป็นต้องรีสตาร์ทแอป';
	@override String get navigationItemSorting => 'การเรียงลำดับรายการนำทาง';
	@override String get done => 'เสร็จสิ้น';
	@override String get edit => 'แก้ไข';
	@override String get reset => 'รีเซ็ต';
	@override String get previewEffect => 'ตัวอย่างผลลัพธ์';
	@override String get bottomNavigationPreview => 'ตัวอย่างแถบนำทางด้านล่าง:';
	@override String get sidebarPreview => 'ตัวอย่างแถบด้านข้าง:';
	@override String get confirmResetNavigationOrder => 'ยืนยันการรีเซ็ตลำดับการนำทาง';
	@override String get confirmResetNavigationOrderDesc => 'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตลำดับการนำทางกลับเป็นค่าเริ่มต้น?';
	@override String get cancel => 'ยกเลิก';
	@override String get show => 'แสดง';
	@override String get hide => 'ซ่อน';
	@override String get hidden => 'ซ่อนอยู่';
	@override String get hideHint => 'แตะไอคอนรูปตาเพื่อแสดงหรือซ่อนชุมชนและไฟล์ในเครื่อง';
	@override String get videoDescription => 'เรียกดูเนื้อหาวิดีโอยอดนิยม';
	@override String get galleryDescription => 'เรียกดูรูปภาพและแกลเลอรี';
	@override String get subscriptionDescription => 'ดูเนื้อหาล่าสุดจากผู้ใช้ที่คุณติดตาม';
	@override String get forumDescription => 'เข้าร่วมการสนทนาในชุมชน';
	@override String get newsDescription => 'เรียกดูข่าวสาร บทความ และประกาศทางการ';
	@override String get communityDescription => 'การสนทนาในฟอรัมพร้อมข่าวสาร บทความ และประกาศทางการ';
	@override String get localMediaDescription => 'เรียกดูวิดีโอและรูปภาพที่จัดเก็บไว้ในอุปกรณ์นี้';
}

// Path: news
class _TranslationsNewsTh extends TranslationsNewsEn {
	_TranslationsNewsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ข่าวสาร';
	@override String get newsUpdates => 'อัปเดตข่าวสาร';
	@override String get articles => 'บทความ';
	@override String get broadcast => 'ประกาศ';
	@override String get openInBrowser => 'เปิดในเบราว์เซอร์';
}

// Path: displaySettings
class _TranslationsDisplaySettingsTh extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าการแสดงผล';
	@override String get layoutSettings => 'การตั้งค่าเลย์เอาต์';
	@override String get layoutSettingsDesc => 'ปรับแต่งจำนวนคอลัมน์และการกำหนดค่าจุดแบ่งหน้าจอ (Breakpoint)';
	@override String get gridLayout => 'เลย์เอาต์ตาราง';
	@override String get navigationOrderSettings => 'การตั้งค่าลำดับการนำทาง';
	@override String get customNavigationOrder => 'กำหนดลำดับการนำทางเอง';
	@override String get customNavigationOrderDesc => 'ปรับลำดับการแสดงผลของหน้าต่างๆ ในแถบนำทางด้านล่างและแถบด้านข้าง';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsTh extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าเลย์เอาต์';
	@override String get descriptionTitle => 'คำอธิบายการกำหนดค่าเลย์เอาต์';
	@override String get descriptionContent => 'การกำหนดค่าที่นี่จะเป็นตัวกำหนดจำนวนคอลัมน์ที่แสดงในหน้ารายการวิดีโอและแกลเลอรี คุณสามารถเลือกโหมดอัตโนมัติเพื่อให้ระบบปรับตามความกว้างหน้าจอโดยอัตโนมัติ หรือเลือกโหมดกำหนดเองเพื่อกำหนดจำนวนคอลัมน์แบบคงที่';
	@override String get layoutMode => 'โหมดเลย์เอาต์';
	@override String get reset => 'รีเซ็ต';
	@override String get autoMode => 'โหมดอัตโนมัติ';
	@override String get autoModeDesc => 'ปรับโดยอัตโนมัติตามความกว้างของหน้าจอ';
	@override String get manualMode => 'โหมดกำหนดเอง';
	@override String get manualModeDesc => 'ใช้จำนวนคอลัมน์คงที่';
	@override String get manualSettings => 'การตั้งค่ากำหนดเอง';
	@override String get fixedColumns => 'จำนวนคอลัมน์คงที่';
	@override String get columns => 'คอลัมน์';
	@override String get breakpointConfig => 'การกำหนดค่าจุดแบ่งหน้าจอ';
	@override String get add => 'เพิ่ม';
	@override String get defaultColumns => 'คอลัมน์เริ่มต้น';
	@override String get defaultColumnsDesc => 'การแสดงผลเริ่มต้นสำหรับหน้าจอขนาดใหญ่';
	@override String get previewEffect => 'ตัวอย่างผลลัพธ์';
	@override String get screenWidth => 'ความกว้างหน้าจอ';
	@override String get addBreakpoint => 'เพิ่มจุดแบ่ง';
	@override String get editBreakpoint => 'แก้ไขจุดแบ่ง';
	@override String get deleteBreakpoint => 'ลบจุดแบ่ง';
	@override String get screenWidthLabel => 'ความกว้างหน้าจอ';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'คอลัมน์';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'โปรดป้อนความกว้าง';
	@override String get enterValidWidth => 'โปรดป้อนความกว้างที่ถูกต้อง';
	@override String get widthCannotExceed9999 => 'ความกว้างต้องไม่เกิน 9999';
	@override String get breakpointAlreadyExists => 'จุดแบ่งมีอยู่แล้ว';
	@override String get enterColumns => 'โปรดป้อนจำนวนคอลัมน์';
	@override String get enterValidColumns => 'โปรดป้อนจำนวนคอลัมน์ที่ถูกต้อง';
	@override String get columnsCannotExceed12 => 'คอลัมน์ต้องไม่เกิน 12';
	@override String get breakpointConflict => 'จุดแบ่งมีอยู่แล้ว';
	@override String get confirmResetLayoutSettings => 'รีเซ็ตการตั้งค่าเลย์เอาต์';
	@override String get confirmResetLayoutSettingsDesc => 'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตการตั้งค่าเลย์เอาต์ทั้งหมดกลับเป็นค่าเริ่มต้น?\n\nจะคืนค่าเป็น:\n• โหมดอัตโนมัติ\n• การกำหนดค่าจุดแบ่งเริ่มต้น';
	@override String get resetToDefaults => 'รีเซ็ตเป็นค่าเริ่มต้น';
	@override String get confirmDeleteBreakpoint => 'ลบจุดแบ่ง';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบจุดแบ่ง ${width}px?';
	@override String get noCustomBreakpoints => 'ไม่มีจุดแบ่งที่กำหนดเอง ใช้คอลัมน์เริ่มต้น';
	@override String get breakpointRange => 'ช่วงจุดแบ่ง';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'แก้ไข';
	@override String get delete => 'ลบ';
	@override String get cancel => 'ยกเลิก';
	@override String get save => 'บันทึก';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerTh extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'ข้อผิดพลาดของเครื่องเล่นวิดีโอ';
	@override String get videoLoadFailed => 'โหลดวิดีโอล้มเหลว';
	@override String get videoCodecNotSupported => 'ไม่รองรับตัวแปลงสัญญาณวิดีโอนี้';
	@override String get networkConnectionIssue => 'ปัญหาการเชื่อมต่อเครือข่าย';
	@override String get insufficientPermission => 'สิทธิ์ไม่เพียงพอ';
	@override String get unsupportedVideoFormat => 'รูปแบบวิดีโอที่ไม่รองรับ';
	@override String get retry => 'ลองใหม่อีกครั้ง';
	@override String get externalPlayer => 'เครื่องเล่นภายนอก';
	@override String get detailedErrorInfo => 'ข้อมูลข้อผิดพลาดโดยละเอียด';
	@override String get format => 'รูปแบบ';
	@override String get suggestion => 'คำแนะนำ';
	@override String get androidWebmCompatibilityIssue => 'อุปกรณ์ Android มีการรองรับรูปแบบ WEBM อย่างจำกัด แนะนำให้ใช้เครื่องเล่นภายนอกหรือดาวน์โหลดแอปเครื่องเล่นที่รองรับ WEBM';
	@override String get currentDeviceCodecNotSupported => 'อุปกรณ์ปัจจุบันไม่รองรับตัวแปลงสัญญาณสำหรับรูปแบบวิดีโอนี้';
	@override String get checkNetworkConnection => 'โปรดตรวจสอบการเชื่อมต่อเครือข่ายของคุณแล้วลองใหม่อีกครั้ง';
	@override String get appMayLackMediaPermission => 'แอปอาจไม่มีสิทธิ์ในการเล่นสื่อที่จำเป็น';
	@override String get tryOtherVideoPlayer => 'โปรดลองใช้โปรแกรมเล่นวิดีโออื่น';
	@override String get unrecognizedVideoFormat => 'ไม่รู้จักไฟล์วิดีโอ';
	@override String get unrecognizedVideoFormatSuggestion => 'ลิงก์อาจหมดอายุแล้ว หรือการตอบกลับไม่ใช่วิดีโอ โปรดลองอีกครั้งหรือเปิดด้วยแอปอื่น';
	@override String get accessDenied => 'เซิร์ฟเวอร์ปฏิเสธคำขอนี้ (403)';
	@override String get accessDeniedSuggestion => 'ลิงก์เล่นน่าจะหมดอายุแล้ว แตะลองใหม่เพื่อดึงลิงก์อีกครั้ง หรือเปิดด้วยแอปอื่น';
	@override String get mute => 'ปิดเสียง';
	@override String get unmute => 'เปิดเสียง';
	@override String get video => 'วิดีโอ';
	@override String get serverSelector => 'การเลือกเซิร์ฟเวอร์ CDN';
	@override String get serverSelectorDescription => 'เลือกเซิร์ฟเวอร์ที่มีความหน่วงต่ำที่สุดเพื่อประสบการณ์การเล่นที่ดีที่สุด';
	@override String get retestSpeed => 'ทดสอบความเร็วใหม่';
	@override String get waitingForSpeedTest => 'กำลังรอการทดสอบความเร็ว';
	@override String get testingSpeed => 'กำลังทดสอบความเร็ว...';
	@override String get testFailed => 'การทดสอบล้มเหลว';
	@override String get loadingServerList => 'กำลังโหลดรายการเซิร์ฟเวอร์...';
	@override String get noAvailableServers => 'ไม่มีเซิร์ฟเวอร์ที่พร้อมใช้งาน';
	@override String get refreshServerList => 'รีเฟรชรายการเซิร์ฟเวอร์';
	@override String get cannotGetSource => 'ไม่สามารถรับแหล่งวิดีโอปัจจุบันได้';
	@override String switchedToServer({required Object serverName}) => 'สลับไปยังเซิร์ฟเวอร์: ${serverName}';
	@override String serverCount({required Object count}) => 'ทั้งหมด ${count} เซิร์ฟเวอร์';
	@override String statusCode({required Object code}) => 'รหัสสถานะ: ${code}';
	@override String get connectionFailed => 'การเชื่อมต่อล้มเหลว';
	@override String get connectionTimeout => 'หมดเวลาการเชื่อมต่อ';
	@override String get networkError => 'ข้อผิดพลาดเครือข่าย';
	@override String get sslError => 'ข้อผิดพลาดใบรับรอง SSL';
	@override String get testCompleted => 'การทดสอบเสร็จสมบูรณ์';
	@override String get local => 'ในเครื่อง';
	@override String get unknown => 'ไม่รู้จัก';
	@override String get localVideoPathEmpty => 'เส้นทางวิดีโอในเครื่องว่างเปล่า';
	@override String localVideoFileNotExists({required Object path}) => 'ไม่มีไฟล์วิดีโอในเครื่อง: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'ไม่สามารถเล่นวิดีโอในเครื่องได้: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'ลากไฟล์วิดีโอมาวางที่นี่เพื่อเล่น';
	@override String get supportedFormats => 'รูปแบบที่รองรับ: MP4, MKV, AVI, MOV, WEBM ฯลฯ';
	@override String get noSupportedVideoFile => 'ไม่พบไฟล์วิดีโอที่รองรับ';
	@override String get retryingOpenVideoLink => 'เปิดลิงก์วิดีโอล้มเหลว กำลังลองใหม่';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'ไม่สามารถโหลดตัวถอดรหัส: ${event} ลองสลับไปใช้การถอดรหัสด้วยซอฟต์แวร์ในการตั้งค่าเครื่องเล่น แล้วเข้าสู่หน้านี้ใหม่อีกครั้ง';
	@override String videoLoadErrorWithDetail({required Object event}) => 'ข้อผิดพลาดในการโหลดวิดีโอ: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'ตรวจพบข้อผิดพลาดในการเล่นซ้ำหลายครั้ง ไปที่ การตั้งค่า > การวินิจฉัยและข้อเสนอแนะ เพื่อส่งออกบันทึก';
	@override String get openSettingsAction => 'ดู';
	@override late final _TranslationsMediaPlayerNoticeTh notice = _TranslationsMediaPlayerNoticeTh._(_root);
	@override String get imageLoadFailed => 'โหลดรูปภาพไม่สำเร็จ';
	@override String get unsupportedImageFormat => 'รูปแบบรูปภาพที่ไม่รองรับ';
	@override String get tryOtherViewer => 'โปรดลองใช้โปรแกรมดูภาพอื่น';
}

// Path: diagnostics
class _TranslationsDiagnosticsTh extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'ข้อมูลการวินิจฉัย';
	@override String get appVersionLabel => 'เวอร์ชันแอป';
	@override String memoryUsage({required Object memMB}) => 'การใช้หน่วยความจำ: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'ไม่สามารถรับข้อมูลอุปกรณ์ได้';
	@override String get secureStorageLabel => 'พื้นที่จัดเก็บที่ปลอดภัย';
	@override String get secureStorageHealthy => 'พร้อมใช้งาน';
	@override String get secureStorageRecovered => 'กู้คืนตัวเองด้วยการรีเซ็ตแล้ว (ข้อมูลก่อนหน้าถูกล้าง)';
	@override String get secureStorageUnavailable => 'ไม่พร้อมใช้งาน (บันทึกสถานะการเข้าสู่ระบบด้วยการเข้ารหัสสำรอง)';
	@override String get secureStoragePlatformOptOut => 'การเข้ารหัสในเครื่องตามนโยบายแพลตฟอร์ม (ไม่ได้ใช้พวงกุญแจระบบบน macOS)';
	@override String get secureStorageDualWrite => ' (เปิดการป้องกันการเขียนคู่)';
	@override String get schemaHealthLabel => 'โครงสร้างฐานข้อมูล';
	@override String get schemaHealthOk => 'ปกติ';
	@override String get schemaHealthRepairedNow => 'ได้รับการซ่อมแซมโดยเครือข่ายความปลอดภัยในการเปิดตัวครั้งนี้ (การโยกย้ายไม่มีผล)';
	@override String get schemaHealthRepairedBefore => 'เคยได้รับการซ่อมแซมโดยเครือข่ายความปลอดภัยมาก่อน';
	@override String get logPolicySectionTitle => 'นโยบายบันทึก';
	@override String get configServiceUnavailable => 'บริการกำหนดค่ายังไม่ได้เริ่มต้น ไม่สามารถปรับนโยบายบันทึกได้';
	@override String get enableLoggingTitle => 'เปิดใช้งานการบันทึก';
	@override String get enableLoggingSubtitle => 'ปิดใช้งานเพื่อหยุดการเขียนบันทึกใหม่';
	@override String get enableLogPersistenceTitle => 'เปิดใช้งานการคงอยู่ของบันทึก';
	@override String get enableLogPersistenceSubtitle => 'ปิดใช้งานเพื่อเก็บบันทึกไว้ในหน่วยความจำเท่านั้นและหยุดการเขียนลงดิสก์';
	@override String get minLogLevelTitle => 'ระดับบันทึกขั้นต่ำ';
	@override String get minLogLevelSubtitle => 'บันทึกที่ต่ำกว่าระดับนี้จะถูกกรองออก';
	@override String get maxFileSizeTitle => 'จำกัดขนาดไฟล์เดี่ยว';
	@override String get maxFileSizeSubtitle => 'หมุนเวียนไฟล์เมื่อถึงเกณฑ์';
	@override String get rotatedFileCountTitle => 'จำนวนไฟล์หมุนเวียนบันทึกหลัก';
	@override String get rotatedFileCountSubtitle => 'จำนวนไฟล์ที่เก็บรักษาไว้ไม่รวมไฟล์ปัจจุบัน';
	@override String get hangFileSizeTitle => 'จำกัดขนาดบันทึกอาการค้าง';
	@override String get hangFileSizeSubtitle => 'ควบคุมการเติบโตของไฟล์ hang_events';
	@override String get hangRotatedFileCountTitle => 'จำนวนไฟล์หมุนเวียนบันทึกอาการค้าง';
	@override String get hangRotatedFileCountSubtitle => 'ควบคุมประวัติที่เก็บรักษาไว้สำหรับ hang_events';
	@override String get healthSectionTitle => 'ความสมบูรณ์ของบันทึก';
	@override String get refreshMetrics => 'รีเฟรชเมตริก';
	@override String get toolsSectionTitle => 'เครื่องมือ';
	@override String get privacyNotice => 'บันทึกอาจมีข้อมูลที่ละเอียดอ่อน เช่น ข้อมูลบัญชีและพารามิเตอร์คำขอ โปรดอย่าโพสต์บันทึกฉบับเต็มต่อสาธารณะใน Issues ตรวจสอบก่อนแล้วจึงส่งทางอีเมล';
	@override String get exportLogsTitle => 'ส่งออกบันทึก';
	@override String get exportLogsSubtitle => 'ตรวจสอบข้อมูลความเป็นส่วนตัวก่อนส่งให้นักพัฒนา';
	@override String get viewLogsTitle => 'ดูบันทึก';
	@override String get viewLogsSubtitle => 'ดูบันทึกขณะรันไทม์แบบเรียลไทม์';
	@override String get copySupportEmailTitle => 'คัดลอกอีเมลสนับสนุน';
	@override String get reportIssueTitle => 'รายงานปัญหา';
	@override String get reportIssueSubtitle => 'ระบุขั้นตอนการจำลองปัญหาบน GitHub (แนบเฉพาะบันทึกที่จำเป็น ไม่แนบบันทึกฉบับเต็ม)';
	@override String get healthSummaryUnavailable => 'ยังไม่มีข้อมูลความสมบูรณ์ของบันทึก';
	@override String get healthMetricsUnavailable => 'ยังไม่ได้รวบรวมเมตริกความสมบูรณ์';
	@override String get healthNoRiskIndicators => 'ตรวจไม่พบตัวบ่งชี้ความเสี่ยง';
	@override late final _TranslationsDiagnosticsHealthAlertTh healthAlert = _TranslationsDiagnosticsHealthAlertTh._(_root);
	@override late final _TranslationsDiagnosticsToastTh toast = _TranslationsDiagnosticsToastTh._(_root);
	@override String get shareSubject => 'บันทึกการวินิจฉัย LoveIwara (มีข้อมูลที่ละเอียดอ่อน โปรดแชร์ด้วยความระมัดระวัง)';
}

// Path: logViewer
class _TranslationsLogViewerTh extends TranslationsLogViewerEn {
	_TranslationsLogViewerTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'โปรแกรมดูบันทึก';
	@override String get searchHint => 'ค้นหาบันทึก...';
	@override String get emptyState => 'ไม่มีบันทึก';
	@override String get copiedToClipboard => 'คัดลอกไปยังคลิปบอร์ดแล้ว';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogTh extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'แอปปิดตัวลงอย่างไม่คาดคิด';
	@override String get description => 'เราตรวจพบการปิดตัวลงอย่างผิดปกติในเซสชันล่าสุด โปรดส่งออกบันทึกการวินิจฉัยและส่งอีเมลไปยังนักพัฒนาเพื่อช่วยเราแก้ไขปัญหา';
	@override String previousVersion({required Object version}) => 'เวอร์ชันล่าสุด: ${version}';
	@override String previousStart({required Object time}) => 'เปิดใช้งานล่าสุด: ${time}';
	@override String lastException({required Object message}) => 'ข้อยกเว้นล่าสุด: ${message}';
	@override String get lastHangRecovered => 'ตรวจพบอาการค้างของ UI ในครั้งล่าสุด และกู้คืนโดยอัตโนมัติแล้ว';
	@override String lastHangStalled({required Object stalledMs}) => 'ตรวจพบความเป็นไปได้ที่ UI จะค้างในครั้งล่าสุด โดยกินเวลาประมาณ ${stalledMs}ms';
	@override String get exportGuide => 'ไปที่ การตั้งค่า > การวินิจฉัยและข้อเสนอแนะ > ส่งออกบันทึก';
	@override String get privacyHint => 'บันทึกอาจมีข้อมูลส่วนตัว โปรดตรวจสอบก่อนส่งอีเมลไปที่:';
	@override String get issueWarning => 'อย่าแนบบันทึกฉบับเต็มต่อสาธารณะใน GitHub Issues';
	@override String get acknowledge => 'รับทราบ';
	@override String get supportEmailCopied => 'คัดลอกอีเมลแล้ว';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogTh extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ป้อนลิงก์';
	@override String supportedLinksHint({required Object webName}) => 'รองรับการระบุลิงก์ ${webName} หลายรายการอย่างชาญฉลาด และข้ามไปยังหน้าที่เกี่ยวข้องในแอปอย่างรวดเร็ว (คั่นลิงก์ออกจากข้อความอื่นด้วยการเว้นวรรค)';
	@override String inputHint({required Object webName}) => 'โปรดป้อนลิงก์ ${webName}';
	@override String get validatorEmptyLink => 'โปรดป้อนลิงก์';
	@override String validatorNoIwaraLink({required Object webName}) => 'ตรวจไม่พบลิงก์ ${webName} ที่ถูกต้อง';
	@override String get multipleLinksDetected => 'ตรวจพบหลายลิงก์ โปรดเลือกหนึ่งรายการ:';
	@override String notIwaraLink({required Object webName}) => 'ไม่ใช่ลิงก์ ${webName} ที่ถูกต้อง';
	@override String linkParseError({required Object error}) => 'ข้อผิดพลาดในการแยกวิเคราะห์ลิงก์: ${error}';
	@override String get unsupportedLinkDialogTitle => 'ลิงก์ที่ไม่รองรับ';
	@override String get unsupportedLinkDialogContent => 'ประเภทลิงก์นี้ไม่สามารถเปิดได้โดยตรงในแอป และจำเป็นต้องเข้าถึงโดยใช้เบราว์เซอร์ภายนอก\n\nคุณต้องการเปิดลิงก์นี้ในเบราว์เซอร์หรือไม่?';
	@override String get openInBrowser => 'เปิดในเบราว์เซอร์';
	@override String get confirmOpenBrowserDialogTitle => 'ยืนยันการเปิดเบราว์เซอร์';
	@override String get confirmOpenBrowserDialogContent => 'ลิงก์ต่อไปนี้กำลังจะถูกเปิดในเบราว์เซอร์ภายนอก:';
	@override String get confirmContinueBrowserOpen => 'คุณแน่ใจหรือไม่ว่าต้องการดำเนินการต่อ?';
	@override String get browserOpenFailed => 'เปิดลิงก์ไม่สำเร็จ';
	@override String get unsupportedLink => 'ลิงก์ที่ไม่รองรับ';
	@override String get cancel => 'ยกเลิก';
	@override String get confirm => 'เปิดในเบราว์เซอร์';
}

// Path: log
class _TranslationsLogTh extends TranslationsLogEn {
	_TranslationsLogTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'การจัดการบันทึก';
	@override String get enableLogPersistence => 'เปิดใช้งานการคงอยู่ของบันทึก';
	@override String get enableLogPersistenceDesc => 'บันทึกประวัติลงในฐานข้อมูลเพื่อนำไปวิเคราะห์';
	@override String get logDatabaseSizeLimit => 'จำกัดขนาดฐานข้อมูลบันทึก';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'ปัจจุบัน: ${size}';
	@override String get exportCurrentLogs => 'ส่งออกบันทึกปัจจุบัน';
	@override String get exportCurrentLogsDesc => 'ส่งออกบันทึกแอปพลิเคชันปัจจุบันเพื่อช่วยนักพัฒนาวินิจฉัยปัญหา';
	@override String get exportHistoryLogs => 'ส่งออกบันทึกย้อนหลัง';
	@override String get exportHistoryLogsDesc => 'ส่งออกบันทึกภายในช่วงวันที่ที่ระบุ';
	@override String get exportMergedLogs => 'ส่งออกบันทึกรวม';
	@override String get exportMergedLogsDesc => 'ส่งออกบันทึกรวมภายในช่วงวันที่ที่ระบุ';
	@override String get showLogStats => 'แสดงสถิติต่างๆ ของบันทึก';
	@override String get logExportSuccess => 'ส่งออกบันทึกสำเร็จ';
	@override String logExportFailed({required Object error}) => 'ส่งออกบันทึกล้มเหลว: ${error}';
	@override String get showLogStatsDesc => 'ดูสถิติของบันทึกประเภทต่างๆ';
	@override String logExtractFailed({required Object error}) => 'รับสถิติบันทึกไม่สำเร็จ: ${error}';
	@override String get clearAllLogs => 'ล้างบันทึกทั้งหมด';
	@override String get clearAllLogsDesc => 'ล้างข้อมูลบันทึกทั้งหมด';
	@override String get confirmClearAllLogs => 'ยืนยันการล้าง';
	@override String get confirmClearAllLogsDesc => 'คุณแน่ใจหรือไม่ว่าต้องการล้างข้อมูลบันทึกทั้งหมด? การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String get clearAllLogsSuccess => 'ล้างบันทึกสำเร็จแล้ว';
	@override String clearAllLogsFailed({required Object error}) => 'ล้างบันทึกไม่สำเร็จ: ${error}';
	@override String get unableToGetLogSizeInfo => 'ไม่สามารถรับข้อมูลขนาดบันทึกได้';
	@override String get currentLogSize => 'ขนาดบันทึกปัจจุบัน:';
	@override String get logCount => 'จำนวนบันทึก:';
	@override String get logCountUnit => 'รายการ';
	@override String get logSizeLimit => 'ขีดจำกัดขนาดบันทึก:';
	@override String get usageRate => 'อัตราการใช้งาน:';
	@override String get exceedLimit => 'เกินขีดจำกัด';
	@override String get remaining => 'ที่เหลือ';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'ขนาดบันทึกปัจจุบันเกินขีดจำกัดแล้ว โปรดล้างบันทึกเก่าหรือเพิ่มขีดจำกัดขนาดบันทึก';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'ขนาดบันทึกปัจจุบันใกล้เต็มแล้ว โปรดล้างบันทึกเก่า';
	@override String get cleaningOldLogs => 'กำลังล้างบันทึกเก่า...';
	@override String get logCleaningCompleted => 'ล้างบันทึกเสร็จสมบูรณ์แล้ว';
	@override String get logCleaningProcessMayNotBeCompleted => 'กระบวนการล้างบันทึกอาจยังไม่เสร็จสมบูรณ์';
	@override String get cleanExceededLogs => 'ล้างบันทึกที่เกินขีดจำกัด';
	@override String get noLogsToExport => 'ไม่มีบันทึกที่จะส่งออก';
	@override String get exportingLogs => 'กำลังส่งออกบันทึก...';
	@override String get noHistoryLogsToExport => 'ไม่มีประวัติบันทึกให้ส่งออก โปรดลองใช้แอปสักระยะหนึ่งก่อน';
	@override String get selectLogDate => 'เลือกวันที่บันทึก';
	@override String get today => 'วันนี้';
	@override String get selectMergeRange => 'เลือกช่วงที่จะรวม';
	@override String get selectMergeRangeHint => 'โปรดเลือกช่วงเวลาบันทึกที่จะรวม';
	@override String selectMergeRangeDays({required Object days}) => '${days} วันล่าสุด';
	@override String get logStats => 'สถิติต่างๆ ของบันทึก';
	@override String todayLogs({required Object count}) => 'บันทึกของวันนี้: ${count} รายการ';
	@override String recent7DaysLogs({required Object count}) => 'บันทึก 7 วันล่าสุด: ${count} รายการ';
	@override String totalLogs({required Object count}) => 'บันทึกทั้งหมด: ${count} รายการ';
	@override String get setLogDatabaseSizeLimit => 'ตั้งค่าขีดจำกัดขนาดฐานข้อมูลบันทึก';
	@override String currentLogSizeWithSize({required Object size}) => 'ขนาดบันทึกปัจจุบัน: ${size}';
	@override String get warning => 'คำเตือน';
	@override String newSizeLimit({required Object size}) => 'ขีดจำกัดขนาดใหม่: ${size}';
	@override String get confirmToContinue => 'ยืนยันเพื่อดำเนินการต่อ';
	@override String logSizeLimitSetSuccess({required Object size}) => 'ตั้งค่าขีดจำกัดขนาดบันทึกเป็น ${size} แล้ว';
}

// Path: emoji
class _TranslationsEmojiTh extends TranslationsEmojiEn {
	_TranslationsEmojiTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get recentlyUsed => 'ใช้ล่าสุด';
	@override String insertedCount({required Object count}) => 'แทรกแล้ว ${count} รายการ';
	@override String get name => 'อีโมจิ';
	@override String get size => 'ขนาด';
	@override String get small => 'เล็ก';
	@override String get medium => 'ปานกลาง';
	@override String get large => 'ใหญ่';
	@override String get extraLarge => 'ใหญ่พิเศษ';
	@override String get copyEmojiLinkSuccess => 'คัดลอกลิงก์อีโมจิแล้ว';
	@override String get preview => 'ตัวอย่างอีโมจิ';
	@override String get library => 'คลังอีโมจิ';
	@override String get noEmojis => 'ไม่มีอีโมจิ';
	@override String get clickToAddEmojis => 'คลิกปุ่มที่มุมขวาบนเพื่อเพิ่มอีโมจิ';
	@override String get addEmojis => 'เพิ่มอีโมจิ';
	@override String get imagePreview => 'ตัวอย่างรูปภาพ';
	@override String get imageLoadFailed => 'โหลดรูปภาพไม่สำเร็จ';
	@override String get loading => 'กำลังโหลด...';
	@override String get delete => 'ลบ';
	@override String get close => 'ปิด';
	@override String get deleteImage => 'ลบรูปภาพ';
	@override String get confirmDeleteImage => 'คุณแน่ใจหรือไม่ว่าต้องการลบรูปภาพนี้?';
	@override String get cancel => 'ยกเลิก';
	@override String get batchDelete => 'ลบเป็นชุด';
	@override String confirmBatchDelete({required Object count}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรูปภาพที่เลือก ${count} รูป? การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String get deleteSuccess => 'ลบสำเร็จแล้ว';
	@override String get addImage => 'เพิ่มรูปภาพ';
	@override String get addImageByUrl => 'เพิ่มด้วย URL';
	@override String get addImageUrl => 'เพิ่ม URL รูปภาพ';
	@override String get imageUrl => 'URL รูปภาพ';
	@override String get enterImageUrl => 'โปรดป้อน URL รูปภาพ';
	@override String get add => 'เพิ่ม';
	@override String get batchImport => 'นำเข้าเป็นชุด';
	@override String get enterJsonUrlArray => 'โปรดป้อนอาร์เรย์ URL รูปแบบ JSON:';
	@override String get formatExample => 'ตัวอย่างรูปแบบ:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'โปรดวางอาร์เรย์ URL รูปแบบ JSON';
	@override String get import => 'นำเข้า';
	@override String importSuccess({required Object count}) => 'นำเข้ารูปภาพ ${count} รูปสำเร็จแล้ว';
	@override String get jsonFormatError => 'รูปแบบ JSON ผิดพลาด โปรดตรวจสอบข้อมูลที่ป้อน';
	@override String get createGroup => 'สร้างกลุ่มอีโมจิ';
	@override String get groupName => 'ชื่อกลุ่ม';
	@override String get enterGroupName => 'โปรดป้อนชื่อกลุ่ม';
	@override String get create => 'สร้าง';
	@override String get editGroupName => 'แก้ไขชื่อกลุ่ม';
	@override String get save => 'บันทึก';
	@override String get deleteGroup => 'ลบกลุ่ม';
	@override String get confirmDeleteGroup => 'คุณแน่ใจหรือไม่ว่าต้องการลบกลุ่มอีโมจินี้? รูปภาพทั้งหมดในกลุ่มจะถูกลบไปด้วย';
	@override String imageCount({required Object count}) => '${count} รูปภาพ';
	@override String get selectEmoji => 'เลือกอีโมจิ';
	@override String get noEmojisInGroup => 'ไม่มีอีโมจิในกลุ่มนี้';
	@override String get goToSettingsToAddEmojis => 'ไปที่การตั้งค่าเพื่อเพิ่มอีโมจิ';
	@override String get emojiManagement => 'การจัดการอีโมจิ';
	@override String get manageEmojiGroupsAndImages => 'จัดการกลุ่มอีโมจิและรูปภาพ';
	@override String get uploadLocalImages => 'อัปโหลดรูปภาพในเครื่อง';
	@override String get uploadingImages => 'กำลังอัปโหลดรูปภาพ';
	@override String uploadingImagesProgress({required Object count}) => 'กำลังอัปโหลดรูปภาพ ${count} รูป โปรดรอสักครู่...';
	@override String get doNotCloseDialog => 'โปรดอย่าปิดกล่องโต้ตอบนี้';
	@override String uploadSuccess({required Object count}) => 'อัปโหลดรูปภาพ ${count} รูปสำเร็จแล้ว';
	@override String uploadFailed({required Object count}) => 'ล้มเหลว ${count} รูป';
	@override String get uploadFailedMessage => 'อัปโหลดรูปภาพไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อเครือข่ายหรือรูปแบบไฟล์';
	@override String uploadErrorMessage({required Object error}) => 'เกิดข้อผิดพลาดระหว่างการอัปโหลด: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterTh extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'เลือกฟิลด์';
	@override String get add => 'เพิ่ม';
	@override String get clear => 'ล้าง';
	@override String get clearAll => 'ล้างทั้งหมด';
	@override String get generatedQuery => 'คำค้นที่สร้างขึ้น';
	@override String get copyToClipboard => 'คัดลอกไปยังคลิปบอร์ด';
	@override String get copied => 'คัดลอกแล้ว';
	@override String filterCount({required Object count}) => '${count} ตัวกรอง';
	@override String get filterSettings => 'การตั้งค่าตัวกรอง';
	@override String get field => 'ฟิลด์';
	@override String get operator => 'ตัวดำเนินการ';
	@override String get language => 'ภาษา';
	@override String get value => 'ค่า';
	@override String get dateRange => 'ช่วงวันที่';
	@override String get numberRange => 'ช่วงตัวเลข';
	@override String get from => 'จาก';
	@override String get to => 'ถึง';
	@override String get date => 'วันที่';
	@override String get number => 'ตัวเลข';
	@override String get boolean => 'บูลีน';
	@override String get tags => 'แท็ก';
	@override String get select => 'เลือก';
	@override String get clickToSelectDate => 'คลิกเพื่อเลือกวันที่';
	@override String get pleaseEnterValidNumber => 'โปรดกรอกตัวเลขที่ถูกต้อง';
	@override String get pleaseEnterValidDate => 'โปรดกรอกวันที่ในรูปแบบที่ถูกต้อง (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => 'ค่าเริ่มต้นต้องน้อยกว่าค่าสิ้นสุด';
	@override String get startDateMustBeBeforeEndDate => 'วันที่เริ่มต้นต้องอยู่ก่อนวันที่สิ้นสุด';
	@override String get pleaseFillStartValue => 'โปรดกรอกค่าเริ่มต้น';
	@override String get pleaseFillEndValue => 'โปรดกรอกค่าสิ้นสุด';
	@override String get rangeValueFormatError => 'รูปแบบค่าช่วงไม่ถูกต้อง';
	@override String get contains => 'มีคำว่า';
	@override String get equals => 'เท่ากับ';
	@override String get notEquals => 'ไม่เท่ากับ';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'ช่วง';
	@override String get kIn => 'มีอย่างใดอย่างหนึ่ง';
	@override String get notIn => 'ไม่มีอย่างใดอย่างหนึ่ง';
	@override String get username => 'ชื่อผู้ใช้';
	@override String get nickname => 'ชื่อเล่น';
	@override String get registrationDate => 'วันที่ลงทะเบียน';
	@override String get description => 'คำอธิบาย';
	@override String get title => 'ชื่อเรื่อง';
	@override String get body => 'เนื้อหา';
	@override String get author => 'ผู้สร้าง';
	@override String get publishDate => 'วันที่เผยแพร่';
	@override String get private => 'ส่วนตัว';
	@override String get duration => 'ระยะเวลา (วินาที)';
	@override String get likes => 'ถูกใจ';
	@override String get views => 'ยอดชม';
	@override String get comments => 'ความคิดเห็น';
	@override String get rating => 'คะแนน';
	@override String get imageCount => 'จำนวนรูปภาพ';
	@override String get videoCount => 'จำนวนวิดีโอ';
	@override String get createDate => 'วันที่สร้าง';
	@override String get content => 'เนื้อหา';
	@override String get all => 'ทั้งหมด';
	@override String get adult => 'ผู้ใหญ่';
	@override String get general => 'ทั่วไป';
	@override String get yes => 'ใช่';
	@override String get no => 'ไม่';
	@override String get users => 'ผู้ใช้';
	@override String get videos => 'วิดีโอ';
	@override String get images => 'รูปภาพ';
	@override String get posts => 'โพสต์';
	@override String get forumThreads => 'กระทู้ในฟอรัม';
	@override String get forumPosts => 'โพสต์ในฟอรัม';
	@override String get playlists => 'เพลย์ลิสต์';
	@override late final _TranslationsSearchFilterSortTypesTh sortTypes = _TranslationsSearchFilterSortTypesTh._(_root);
	@override String get drawerSubtitle => 'การเปลี่ยนแปลงมีผลทันที';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupTh extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeTh welcome = _TranslationsFirstTimeSetupWelcomeTh._(_root);
	@override late final _TranslationsFirstTimeSetupBasicTh basic = _TranslationsFirstTimeSetupBasicTh._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkTh network = _TranslationsFirstTimeSetupNetworkTh._(_root);
	@override late final _TranslationsFirstTimeSetupThemeTh theme = _TranslationsFirstTimeSetupThemeTh._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerTh player = _TranslationsFirstTimeSetupPlayerTh._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialTh spatial = _TranslationsFirstTimeSetupSpatialTh._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionTh completion = _TranslationsFirstTimeSetupCompletionTh._(_root);
	@override late final _TranslationsFirstTimeSetupCommonTh common = _TranslationsFirstTimeSetupCommonTh._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperTh extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'ตรวจพบพร็อกซีของระบบ';
	@override String get copied => 'คัดลอกแล้ว';
	@override String get copy => 'คัดลอก';
}

// Path: tagSelector
class _TranslationsTagSelectorTh extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'เลือกแท็ก';
	@override String get clickToSelectTags => 'คลิกเพื่อเลือกแท็ก';
	@override String get addTag => 'เพิ่มแท็ก';
	@override String get removeTag => 'เอาแท็กออก';
	@override String get deleteTag => 'ลบแท็ก';
	@override String get usageInstructions => 'เพิ่มแท็กก่อน จากนั้นจึงคลิกเลือกจากแท็กที่มีอยู่';
	@override String get usageInstructionsTooltip => 'คำแนะนำการใช้งาน';
	@override String get addTagTooltip => 'เพิ่มแท็ก';
	@override String get removeTagTooltip => 'เอาแท็กออก';
	@override String get cancelSelection => 'ยกเลิกการเลือก';
	@override String get selectAll => 'เลือกทั้งหมด';
	@override String get cancelSelectAll => 'ยกเลิกเลือกทั้งหมด';
	@override String get delete => 'ลบ';
}

// Path: anime4k
class _TranslationsAnime4kTh extends TranslationsAnime4kEn {
	_TranslationsAnime4kTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'การขยายภาพและลดสัญญาณรบกวนวิดีโอแบบเรียลไทม์ ช่วยยกระดับคุณภาพวิดีโออนิเมชัน';
	@override String get settings => 'การตั้งค่า Anime4K';
	@override String get preset => 'พรีเซ็ต Anime4K';
	@override String get disable => 'ปิด Anime4K';
	@override String get disableDescription => 'ปิดเอฟเฟกต์เพิ่มคุณภาพวิดีโอ';
	@override String get highQualityPresets => 'พรีเซ็ตคุณภาพสูง';
	@override String get fastPresets => 'พรีเซ็ตแบบเร็ว';
	@override String get litePresets => 'พรีเซ็ตแบบเบา';
	@override String get moreLitePresets => 'พรีเซ็ตแบบเบายิ่งขึ้น';
	@override String get customPresets => 'พรีเซ็ตกำหนดเอง';
	@override late final _TranslationsAnime4kPresetGroupsTh presetGroups = _TranslationsAnime4kPresetGroupsTh._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsTh presetDescriptions = _TranslationsAnime4kPresetDescriptionsTh._(_root);
	@override late final _TranslationsAnime4kPresetNamesTh presetNames = _TranslationsAnime4kPresetNamesTh._(_root);
	@override String get performanceTip => '💡 เคล็ดลับ: เลือกพรีเซ็ตให้เหมาะกับสมรรถนะของอุปกรณ์ อุปกรณ์สเปกต่ำแนะนำให้ใช้พรีเซ็ตแบบเบา';
	@override String get compatibilityTip => '⚠️ GPU บนมือถือบางรุ่น (เช่น Kirin 980 / Mali-G76) ไม่สามารถเรนเดอร์เชดเดอร์แบบกำหนดเองได้ หากภาพกลายเป็นสีดำแต่เสียงยังเล่นต่อ ให้ปิด Anime4K ที่นี่';
	@override String get autoDisabledOnRenderFailure => 'GPU ของอุปกรณ์ไม่สามารถเรนเดอร์เชดเดอร์ Anime4K ได้ จึงปิดใช้งานโดยอัตโนมัติ';
}

// Path: siteMode
class _TranslationsSiteModeTh extends TranslationsSiteModeEn {
	_TranslationsSiteModeTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'โหมดไซต์';
	@override String get mainSite => 'ไซต์หลัก';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'ปัจจุบัน ${currentSite} · แตะเพื่อสลับเป็น ${nextSite}';
	@override String get dialogTitle => 'สลับโหมดไซต์';
	@override String get dialogDescription => 'การสลับจะรีเฟรชทั้งแอป และรีเซ็ตรายการที่โหลดไว้ก่อนหน้ากับสถานะของหน้า';
	@override String get chooseLinkTargetTitle => 'เลือกไซต์ปลายทาง';
	@override String get chooseLinkTargetDescription => 'ลิงก์นี้ไม่มีโดเมน โปรดเลือกว่าจะเปิดในไซต์หลักหรือ AI';
	@override String get chooseLinkTargetHint => 'เมื่อเปิดแล้ว หน้านี้และคำขอรายละเอียดที่ตามมาจะใช้ไซต์ที่เลือกต่อไป';
	@override String get alreadyUsing => 'คุณกำลังใช้โหมดไซต์นี้อยู่แล้ว';
	@override String openInSite({required Object site}) => 'เปิดใน ${site}';
	@override String confirmUsing({required Object site}) => 'หลังยืนยัน คำขอต่อๆ ไปจะใช้โหมด ${site}';
	@override String switched({required Object site}) => 'สลับเป็น ${site} แล้ว แอปได้รีเฟรชเรียบร้อย';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigTh extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ตัวกรองที่บันทึกไว้';
	@override String get empty => 'ยังไม่มีตัวกรองที่บันทึกไว้';
	@override String get saveTooltip => 'บันทึกตัวกรองปัจจุบัน';
	@override String get namePromptTitle => 'บันทึกตัวกรอง';
	@override String get nameLabel => 'ชื่อ';
	@override String get nameHint => 'กรอกชื่อ';
	@override String get saveSuccess => 'บันทึกตัวกรองแล้ว';
	@override String get deleteSuccess => 'ลบตัวกรองแล้ว';
	@override String get addCurrent => 'บันทึกตัวกรองปัจจุบัน';
	@override String get reorderHint => 'กดค้างแล้วลากเพื่อจัดลำดับใหม่';
	@override String get rename => 'เปลี่ยนชื่อ';
	@override String get unnamed => 'ไม่มีชื่อ';
	@override String get noConditions => 'เนื้อหาทั้งหมด (ไม่มีตัวกรอง)';
	@override String tagsCount({required Object count}) => '${count} แท็ก';
}

// Path: savedSearch
class _TranslationsSavedSearchTh extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การค้นหาที่บันทึกไว้';
	@override String get empty => 'ยังไม่มีการค้นหาที่บันทึกไว้';
	@override String get saveTooltip => 'บันทึกการค้นหาปัจจุบัน';
	@override String get namePromptTitle => 'บันทึกการค้นหา';
	@override String get nameLabel => 'ชื่อ';
	@override String get nameHint => 'กรอกชื่อ';
	@override String get saveSuccess => 'บันทึกการค้นหาแล้ว';
	@override String get deleteSuccess => 'ลบการค้นหาแล้ว';
	@override String get addCurrent => 'บันทึกการค้นหาปัจจุบัน';
	@override String get reorderHint => 'กดค้างแล้วลากเพื่อจัดลำดับใหม่';
	@override String get rename => 'เปลี่ยนชื่อ';
	@override String get noKeyword => '(ไม่มีคำค้น)';
	@override String filtersCount({required Object count}) => '${count} ตัวกรอง';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderTh extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ตรวจพบบัญชีดำแท็กเริ่มต้น';
	@override String get content => 'บัญชีของคุณยังใช้บัญชีดำแท็กที่เว็บไซต์ตั้งให้อัตโนมัติกับทุกบัญชีใหม่ ต้องการตรวจสอบและจัดการหรือไม่';
	@override String get goManage => 'จัดการ';
	@override String get dismiss => 'ไว้ก่อน';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistTh extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ช่วยการมองเห็นสี';
	@override String get description => 'ปรับสีวิดีโอให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี ใช้ร่วมกับ Anime4K ได้';
	@override String get galleryDescription => 'ปรับสีภาพในแกลเลอรีให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี (ทำงานอิสระจากสวิตช์ของโปรแกรมเล่น)';
	@override String get galleryDescriptionSpatial => 'ปรับสีภาพในแกลเลอรีให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี ใช้ได้เฉพาะกับตัวดูภาพ 2D ในแผงนี้เท่านั้น — ภาพบนจอเชิงพื้นที่เรนเดอร์แบบเนทีฟและไม่ผ่านตัวกรองนี้';
	@override String get disable => 'ปิด';
	@override String get disableDescription => 'ไม่ปรับสี';
	@override String get protanopia => 'ช่วยมองสีแดง (Protanopia)';
	@override String get protanopiaDescription => 'สำหรับผู้ที่มี Protanopia — แยกแยะสีแดงได้ยาก';
	@override String get deuteranopia => 'ช่วยมองสีเขียว (Deuteranopia)';
	@override String get deuteranopiaDescription => 'สำหรับผู้ที่มี Deuteranopia — แยกแยะสีเขียวได้ยาก';
	@override String get tritanopia => 'ช่วยมองสีน้ำเงิน (Tritanopia)';
	@override String get tritanopiaDescription => 'สำหรับผู้ที่มี Tritanopia — แยกแยะสีน้ำเงินและสีเหลืองได้ยาก';
	@override String appliedToast({required Object filterName}) => 'นำ ${filterName} ไปใช้แล้ว มีผลทันที';
	@override String get disabledToast => 'ปิดการช่วยการมองเห็นสีแล้ว';
}

// Path: externalPlayer
class _TranslationsExternalPlayerTh extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'เปิดด้วยแอปอื่น';
	@override String get description => 'ส่งวิดีโอปัจจุบันไปยังโปรแกรมเล่นอื่นบนอุปกรณ์นี้ เช่น Skybox หรือ Pigasus บนชุดหูฟัง VR หรือ MX Player และ VLC บนมือถือ';
	@override String get openWithOtherApp => 'เลือกแอปอื่น';
	@override String get openWithOtherAppDescription => 'เปิดตัวเลือกของระบบแล้วเลือกโปรแกรมเล่นที่จะรับช่วงต่อ';
	@override String get openWithSystemPlayer => 'เปิดในโปรแกรมเล่นเริ่มต้น';
	@override String get openWithSystemPlayerDescription => 'ส่งต่อให้แอปวิดีโอเริ่มต้นของระบบ';
	@override String get copyLink => 'คัดลอกลิงก์วิดีโอ';
	@override String get copyLinkDescription => 'สำหรับโปรแกรมเล่นที่วาง URL ได้เท่านั้น เช่น Skybox หรือ DeoVR';
	@override String get linkCopied => 'คัดลอกลิงก์วิดีโอแล้ว';
	@override String get sourceLocal => 'ไฟล์ในเครื่อง';
	@override String get sourceOnline => 'ลิงก์ตรง';
	@override String sourceOnlineWithQuality({required Object quality}) => 'ลิงก์ตรง · ${quality}';
	@override String get onlineLinkExpiryHint => 'ลิงก์ตรงมีอายุจำกัด โปรแกรมเล่นภายนอกอาจหยุดกลางคันได้ การดาวน์โหลดไว้ก่อนเป็นวิธีที่เชื่อถือได้';
	@override String get vrPlayerHint => 'หากไม่มีโปรแกรมเล่น VR ของคุณในตัวเลือก ให้ใช้ คัดลอกลิงก์วิดีโอ แล้ววางในโปรแกรมเล่นนั้น';
	@override String get noHandler => 'ไม่มีแอปบนอุปกรณ์นี้ที่เปิดวิดีโอได้';
	@override String handoffFailed({required Object message}) => 'ส่งต่อไม่สำเร็จ: ${message}';
	@override String get handoffFailedUnknown => 'ส่งต่อไม่สำเร็จ';
	@override String get sourceUnavailable => 'ไม่สามารถดึงที่อยู่ของวิดีโอปัจจุบันได้ โปรดลองอีกครั้ง';
	@override String get localFileMissing => 'ไฟล์ในเครื่องไม่มีอยู่แล้ว';
	@override String get handedOff => 'ส่งต่อให้โปรแกรมเล่นภายนอกแล้ว';
	@override String get desktopSectionTitle => 'โปรแกรมเล่นภายนอก';
	@override String get managePlayers => 'จัดการโปรแกรมเล่นภายนอก';
	@override String get managePlayersDescWindows => 'โปรแกรมเล่น PCVR อย่าง HereSphere, DeoVR และ Whirligig ไม่ใช่แอปเริ่มต้นของระบบ ชี้ไปที่ไฟล์ .exe ของโปรแกรมเหล่านั้น แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย';
	@override String get managePlayersDescMac => 'ชี้ไปที่โปรแกรมเล่นอย่าง IINA, VLC หรือ mpv แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย';
	@override String get managePlayersDescLinux => 'ชี้ไปที่โปรแกรมเล่นอย่าง mpv, VLC หรือ Celluloid แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย';
	@override String get pickExecutableHintWindows => 'เลือกไฟล์ .exe หลักในโฟลเดอร์ติดตั้งของโปรแกรมเล่น เช่น HereSphere.exe หรือ vlc.exe ทางลัดบนเดสก์ท็อป (.lnk) ใช้ไม่ได้';
	@override String get pickExecutableHintMac => 'เลือกไฟล์ .app ของโปรแกรมเล่นใน Applications เช่น IINA.app — ระบบจะค้นหาไฟล์เรียกใช้งานจริงภายในให้เอง';
	@override String get pickExecutableHintLinux => 'เลือกไฟล์เรียกใช้งานของโปรแกรมเล่น เช่น /usr/bin/mpv การรัน which mpv จะบอกตำแหน่งของมัน';
	@override String emptyStateGuide({required Object examples}) => 'เมื่อตั้งค่าแล้วจะปรากฏเป็นรายการของตัวเองใต้ เปิดด้วยแอปอื่น ในหน้าโปรแกรมเล่น ที่ใช้บ่อยเช่น: ${examples}';
	@override String get detectNothingFoundGuide => 'ไม่พบโปรแกรมเล่นที่ติดตั้งไว้ โฟลเดอร์ติดตั้งแบบกำหนดเองและเวอร์ชันพกพาจะตรวจจับไม่ได้ — ใช้ เพิ่มโปรแกรมเล่น เพื่อระบุเอง';
	@override String get detectNothingNew => 'ไม่พบโปรแกรมเล่นใหม่ ทุกอย่างที่ติดตั้งอยู่มีในรายการแล้ว';
	@override String get detectFailed => 'ตรวจจับไม่สำเร็จ — ใช้ เพิ่มโปรแกรมเล่น เพื่อระบุเอง';
	@override String get advancedOptions => 'ขั้นสูง';
	@override String get playerNameHint => 'เว้นว่างไว้เพื่อใช้ชื่อไฟล์';
	@override String get executablePathRequired => 'เลือกไฟล์เรียกใช้งานของโปรแกรมเล่นก่อน';
	@override String playerCount({required Object count}) => 'ตั้งค่าแล้ว ${count} รายการ';
	@override String get noPlayerConfigured => 'ยังไม่ได้ตั้งค่าโปรแกรมเล่นภายนอก';
	@override String get autoDetect => 'ตรวจจับอัตโนมัติ';
	@override String get detecting => 'กำลังตรวจจับ…';
	@override String detectFound({required Object count}) => 'พบโปรแกรมเล่น ${count} รายการ';
	@override String get detectNothingFound => 'ไม่พบโปรแกรมเล่นใหม่ เพิ่มเองได้เลย';
	@override String get autoDetectedTag => 'ตรวจพบ';
	@override String get addPlayer => 'เพิ่มโปรแกรมเล่น';
	@override String get editPlayer => 'แก้ไขโปรแกรมเล่น';
	@override String get playerName => 'ชื่อ';
	@override String get executablePath => 'ไฟล์เรียกใช้งาน';
	@override String get browse => 'เลือกไฟล์';
	@override String get argumentTemplate => 'อาร์กิวเมนต์ตอนเปิด';
	@override String get argumentTemplateHint => 'ใช้ {input} แทนเส้นทางหรือ URL ของวิดีโอ เว้นว่างไว้เพื่อส่งเป็นอาร์กิวเมนต์เดียว';
	@override String get nameAndPathRequired => 'ต้องกรอกทั้งชื่อและไฟล์เรียกใช้งาน';
	@override String get testLaunch => 'ทดสอบเปิด';
	@override String get testLaunched => 'เปิดโปรแกรมเล่นแล้ว';
	@override String get testFailed => 'เปิดไม่สำเร็จ ตรวจสอบเส้นทางไฟล์เรียกใช้งาน';
	@override String get executableMissing => 'ไม่พบไฟล์เรียกใช้งาน';
	@override String openWithNamed({required Object name}) => 'เปิดใน ${name}';
	@override String get managePlayersEntry => 'จัดการโปรแกรมเล่นภายนอก…';
}

// Path: watchLater
class _TranslationsWatchLaterTh extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ดูภายหลัง';
	@override String get addToWatchLater => 'ดูภายหลัง';
	@override String get removeFromWatchLater => 'เอาออกจากดูภายหลัง';
	@override String get addedToWatchLater => 'เพิ่มในดูภายหลังแล้ว';
	@override String get alreadyInWatchLater => 'อยู่ในดูภายหลังแล้ว';
	@override String get removedFromWatchLater => 'เอาออกจากดูภายหลังแล้ว';
	@override String removedCount({required Object count}) => 'ลบออกแล้ว ${count} รายการ';
	@override String get viewWatchLaterList => 'ดูรายการ';
	@override String get addFailed => 'เพิ่มในดูภายหลังไม่สำเร็จ';
	@override String get invalidItem => 'ไม่พร้อมใช้งาน';
	@override String get clearWatched => 'ล้างรายการที่ดูแล้ว';
	@override String watchedCleared({required Object count}) => 'ล้างรายการที่ดูแล้ว ${count} รายการ';
	@override String get noWatchedToClear => 'ไม่มีรายการที่ดูแล้วให้ล้าง';
	@override String get emptyVideo => 'ยังไม่มีวิดีโอในดูภายหลัง';
	@override String get emptyGallery => 'ยังไม่มีแกลเลอรีในดูภายหลัง';
	@override String get filterAll => 'ทั้งหมด';
	@override String get filterUnwatched => 'ยังไม่ดู';
	@override String get sortRecentlyAdded => 'เพิ่มล่าสุด';
	@override String get sortEarliestAdded => 'เพิ่มก่อนสุด';
	@override String get watched => 'ดูแล้ว';
	@override String get playlistLoadFailed => 'โหลดเพลย์ลิสต์ไม่สำเร็จ';
	@override String get noPlaylists => 'ยังไม่มีเพลย์ลิสต์';
	@override String get undo => 'เลิกทำ';
	@override String get clearWatchedConfirm => 'ล้างทุกอย่างที่คุณดูแล้วในแท็บนี้หรือไม่ การกระทำนี้ย้อนกลับไม่ได้';
	@override String get emptyUnwatchedVideo => 'ไม่มีอะไรเหลือให้รับชมที่นี่';
	@override String get emptyUnwatchedGallery => 'ไม่มีอะไรเหลือให้ดูที่นี่';
	@override String get queueLoadFailed => 'โหลดไม่สำเร็จ แตะเพื่อลองใหม่';
}

// Path: mediaMenu
class _TranslationsMediaMenuTh extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get like => 'ถูกใจ';
	@override String get unlike => 'เลิกถูกใจ';
	@override String get viewAuthor => 'ดูผู้สร้าง';
	@override String inFolders({required Object count}) => '${count} โฟลเดอร์';
	@override String inPlaylists({required Object count}) => '${count} เพลย์ลิสต์';
	@override String get downloaded => 'ดาวน์โหลดแล้ว';
}

// Path: mediaPreview
class _TranslationsMediaPreviewTh extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get preview => 'ตัวอย่าง';
	@override String get openDetail => 'เปิด';
	@override String get moreActions => 'การกระทำเพิ่มเติม';
	@override String get previousImage => 'รูปก่อนหน้า';
	@override String get nextImage => 'รูปถัดไป';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueTh extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} รูป';
	@override String get upNext => 'ถัดไป';
	@override String get sourceTab => 'แหล่งที่มา';
	@override String get emptyQueue => 'ไม่มีรายการที่เล่นได้ในคิวนี้';
	@override String get emptyGalleryQueue => 'ไม่มีแกลเลอรีในคิวนี้';
	@override String get nowPlaying => 'กำลังเล่น';
	@override String get myPlaylists => 'เพลย์ลิสต์ของฉัน';
	@override String get authorPlaylists => 'เพลย์ลิสต์ของผู้สร้าง';
	@override String get openQueue => 'ถัดไป';
	@override String get continueInQueue => 'เล่นต่อจากคิวปัจจุบัน';
	@override String get continueInQueueSubtitle => 'เล่นรายการถัดไปโดยอัตโนมัติ ปิดการทำงานของ “เล่นซ้ำเมื่อจบ”';
	@override String get repeatDisabledByQueue => 'ปิดใช้งานขณะที่ “เล่นต่อจากคิวปัจจุบัน” เปิดอยู่';
	@override String get playNext => 'เล่นถัดไป';
	@override String get queueEnded => 'นี่คือรายการสุดท้ายในคิว';
	@override String get playNextHint => 'แตะเพื่อเล่นรายการถัดไป กดค้างเพื่อเปิด ถัดไป';
	@override String get authorVideos => 'วิดีโอของผู้สร้าง';
	@override String get authorGalleries => 'แกลเลอรีของผู้สร้าง';
	@override String get favoriteFolders => 'โฟลเดอร์โปรด';
	@override String get localFiles => 'บนอุปกรณ์นี้';
	@override String get currentFolder => 'โฟลเดอร์ของไฟล์นี้';
	@override String get playThisFolder => 'ดูคิววิดีโอของโฟลเดอร์นี้';
	@override String get browseThisFolder => 'ดูคิวแกลเลอรีของโฟลเดอร์นี้';
	@override String get downloads => 'ดาวน์โหลด';
	@override String get otherPlaylists => 'เพลย์ลิสต์ของผู้ใช้อื่น';
	@override String get nothingHere => 'ไม่มีอะไรที่นี่';
}

// Path: vrFormat
class _TranslationsVrFormatTh extends TranslationsVrFormatEn {
	_TranslationsVrFormatTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'เล่นในโปรแกรมเล่นเชิงพื้นที่';
	@override String get handingOff => 'กำลังส่งต่อไปยังพื้นที่…';
	@override String get title => 'โหมดการเล่น';
	@override String get spatialSectionTitle => 'การเล่นแบบเชิงพื้นที่';
	@override String get spatialSectionDesc => 'บนชุดหูฟัง วิดีโอไม่ได้ถูกวาดในแผงนี้ — โปรแกรมเล่นเชิงพื้นที่จะวางไว้บนจอในห้อง';
	@override String get spatialPanelEntry => 'แผงควบคุมเชิงพื้นที่';
	@override String get spatialPanelEntryDesc => 'ระยะห่างของจอ ขนาดและความโค้ง สภาพแวดล้อมพื้นหลัง ตลอดจนความเร็ว การเล่นซ้ำ และการซ่อนอัตโนมัติ อยู่ในแผงควบคุมเชิงพื้นที่ทั้งหมด';
	@override String get spatialGuideEntry => 'คู่มือการควบคุมด้วยชุดหูฟัง';
	@override String get spatialGuideEntryDesc => 'ปุ่มบนคอนโทรลเลอร์ การคว้าจอ การเลื่อนด้วยก้านควบคุม และการเปลี่ยนหน้า';
	@override String get spatialFlatOmitted => 'ท่าทางการสัมผัส การเพิ่มคุณภาพภาพ และพารามิเตอร์เสียง/วิดีโอ ใช้ได้เฉพาะกับโปรแกรมเล่น 2D เท่านั้น โปรแกรมเล่นเชิงพื้นที่ทำงานบนเอนจินอื่น จึงไม่แสดงไว้ที่นี่';
	@override String get spatialGallerySectionTitle => 'แกลเลอรีเชิงพื้นที่';
	@override String get spatialGalleryPanelDesc => 'ช่วงเวลาสไลด์โชว์ การเล่นซ้ำคลิปเดียว และความโค้งของจอ ปรับได้ทั้งหมดในแผงควบคุมเชิงพื้นที่';
	@override String get autoEnterGallery => 'เปิดภาพในแกลเลอรีเชิงพื้นที่';
	@override String get autoEnterGalleryDesc => 'บน Quest การแตะที่ภาพจะเปิดทั้งแกลเลอรีบนจอลอยพร้อมฟิล์มสตริป สไลด์โชว์ และการเปลี่ยนหน้าด้วยคอนโทรลเลอร์ แทนที่จะเป็นตัวดูภาพในแผงนี้';
	@override String get panelSettings => 'แผงและพื้นหลัง';
	@override String get panelSettingsDesc => 'แผงของแอปนี้อยู่ห่างแค่ไหน และเห็นห้องของคุณด้านหลังมากน้อยเพียงใด';
	@override String get panelDistance => 'ระยะห่างของแผง';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'รีเซ็ตตำแหน่ง';
	@override String get panelResetBackground => 'คืนค่าเริ่มต้น';
	@override String get panelBackground => 'ความโปร่งใสของพื้นหลัง';
	@override String get panelBackgroundHint => '0%: รอบข้างเป็นสีดำ · 100%: ห้องจริงของคุณพร้อมแสงแวดล้อม';
	@override String get panelUnavailable => 'ตอนนี้แผงไม่ได้อยู่ในตำแหน่ง — โปรดลองอีกครั้งในอีกสักครู่';
	@override String get desc => 'เลือกรูปแบบเรขาคณิตที่จะใช้เล่นวิดีโอนี้ ไซต์ไม่ได้ให้ข้อมูลนี้ การตรวจจับอัตโนมัติจึงเลือกเพียงจุดเริ่มต้นเท่านั้น — การเลือกของคุณเป็นตัวตัดสิน';
	@override String get sectionFlat => 'แบน';
	@override String get sectionStereo => 'แบน 3D';
	@override String get sectionPanorama => 'พาโนรามา VR';
	@override String get flat => 'วิดีโอปกติ';
	@override String get flatDesc => 'เล่นตามเดิม ไม่มีการปรับรูปแบบภาพ';
	@override String get flatSideBySide => '3D แบบข้างเคียง';
	@override String get flatSideBySideDesc => 'หนึ่งตาต่อครึ่งซ้ายและขวา แสดงตาซ้ายและคืนสัดส่วนภาพเดิม';
	@override String get flatTopBottom => '3D แบบบนล่าง';
	@override String get flatTopBottomDesc => 'หนึ่งตาต่อครึ่งบนและล่าง แสดงครึ่งบนและคืนสัดส่วนภาพเดิม';
	@override String get vr180SideBySide => 'VR180 แบบข้างเคียง';
	@override String get vr180SideBySideDesc => 'พาโนรามาซีกโลกพร้อมสองตา — แหล่ง VR ที่พบมากที่สุด';
	@override String get vr180Mono => 'VR180 ภาพเดียว';
	@override String get vr180MonoDesc => 'พาโนรามาซีกโลก หนึ่งตาต่อเฟรม';
	@override String get vr360Mono => 'VR360 ภาพเดียว';
	@override String get vr360MonoDesc => 'พาโนรามาแบบรอบทิศ หนึ่งตาต่อเฟรม';
	@override String get vr360TopBottom => 'VR360 แบบบนล่าง';
	@override String get vr360TopBottomDesc => 'พาโนรามาแบบรอบทิศพร้อมสองตาซ้อนกัน';
	@override String get resetView => 'รีเซ็ตมุมมอง';
	@override String get resetViewDesc => 'คืนทิศทางการมองและมุมมองกลับไปด้านหน้า';
	@override String get resetToAuto => 'กลับสู่การตรวจจับอัตโนมัติ';
	@override String get resetToAutoDesc => 'ลืมการเลือกเองสำหรับวิดีโอนี้ แล้วให้การตรวจจับตัดสินใจใหม่';
	@override String get manualBadge => 'ตั้งค่าเอง';
	@override String get panoramaHint => 'ลากภาพเพื่อมองไปรอบๆ บีบนิ้วเพื่อเปลี่ยนมุมมอง';
	@override String get panoramaGestureNotice => 'ขณะมองไปรอบๆ การลากจะหมุนมุมมอง — ใช้แถบความคืบหน้าเพื่อเลื่อนไปยังตำแหน่ง';
	@override String get shaderUnsupported => 'อุปกรณ์นี้ไม่สามารถเรนเดอร์พาโนรามาแบบสดได้ จึงแสดงเพียงตาเดียว';
	@override String get handoffTooltip => 'เล่นด้วยวิธีอื่น';
	@override String get suggestedBadge => 'แนะนำ';
	@override String suggestedEntryDesc({required Object format}) => 'ดูเหมือนเป็น ${format} — แตะเพื่อสลับ';
	@override String suggestionTitle({required Object format}) => 'วิดีโอนี้อาจเป็นวิดีโอ VR (${format})';
	@override String get suggestionTitleShort => 'วิดีโอนี้อาจเป็นวิดีโอ VR';
	@override String get suggestionAction => 'เล่นเป็น VR';
	@override String get suggestionDismiss => 'ปิด';
}

// Path: localMedia
class _TranslationsLocalMediaTh extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseTh browse = _TranslationsLocalMediaBrowseTh._(_root);
	@override String get tabFolders => 'โฟลเดอร์';
	@override String get tabFavoriteVideos => 'รายการโปรด';
	@override String get tabAllVideos => 'วิดีโอทั้งหมด';
	@override String get tabAllImages => 'รูปภาพทั้งหมด';
	@override String get tabDownloadedVideos => 'วิดีโอที่ดาวน์โหลด';
	@override String get tabDownloadedGalleries => 'แกลเลอรีที่ดาวน์โหลด';
	@override String get title => 'บนอุปกรณ์นี้';
	@override String get sourceOnline => 'Iwara ออนไลน์';
	@override String get manageSources => 'จัดการแหล่งที่มา';
	@override String get moveToCategory => 'ย้ายไปยังหมวดหมู่';
	@override String get manageCategories => 'จัดการหมวดหมู่';
	@override String get suggestedFolders => 'โฟลเดอร์ที่มีวิดีโอ';
	@override String get sortRecentlyAdded => 'เพิ่มล่าสุด';
	@override String get sortRecentlyPlayed => 'เล่นล่าสุด';
	@override String get sortName => 'ชื่อ';
	@override String get sortDuration => 'ระยะเวลา';
	@override String get sortSize => 'ขนาด';
	@override String get sortFolder => 'โฟลเดอร์';
	@override String get sortRecentlyModified => 'แก้ไขล่าสุด';
	@override String get sortCount => 'จำนวน';
	@override String folderCardItemCount({required Object count}) => '${count} รูป';
	@override String get downloadsSource => 'ดาวน์โหลด';
	@override String get builtInSourceHint => 'รายการดาวน์โหลดถูกจัดการโดยอัตโนมัติ';
	@override String get filterByCategory => 'กรองตามหมวดหมู่';
	@override String get longPressToCategorize => 'กดค้างเพื่อย้ายไปยังหมวดหมู่';
	@override String get uncategorized => 'ไม่มีหมวดหมู่';
	@override String get setCategoryFailed => 'ไม่สามารถตั้งค่าหมวดหมู่ได้';
	@override String get categoryUpdated => 'อัปเดตหมวดหมู่แล้ว';
	@override String get addFolder => 'เพิ่มโฟลเดอร์';
	@override String get addDeviceVideos => 'สแกนวิดีโอในอุปกรณ์';
	@override String get mediaStoreSourceName => 'วิดีโอในอุปกรณ์';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsTh itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsTh._(_root);
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
	@override late final _TranslationsLocalMediaMissingTh missing = _TranslationsLocalMediaMissingTh._(_root);
	@override late final _TranslationsLocalMediaWebdavTh webdav = _TranslationsLocalMediaWebdavTh._(_root);
	@override String get mediaStoreUnavailable => 'ดัชนีสื่อของอุปกรณ์ใช้ได้เฉพาะบน Android';
	@override String get mediaStorePermissionDenied => 'ไม่ได้รับอนุญาตให้เข้าถึงวิดีโอ';
	@override String get rescan => 'สแกนใหม่';
	@override String scanning({required Object count}) => 'กำลังสแกน… พบ ${count} รายการ';
	@override String scanFailed({required Object reason}) => 'สแกนไม่สำเร็จ: ${reason}';
	@override String scanTruncated({required Object count}) => 'โฟลเดอร์นั้นใหญ่โตมาก — เพิ่มเฉพาะ ${count} ไฟล์แรกเท่านั้น';
	@override String sourceOverlaps({required Object name}) => 'ถูกครอบคลุมโดยโฟลเดอร์ “${name}” อยู่แล้ว';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '“${name}” อยู่ภายใน “${source}” จึงถูกเพิ่มไปยังโฟลเดอร์ปักหมุด';
	@override String alreadyPinnedFolder({required Object name}) => '“${name}” อยู่ในโฟลเดอร์ปักหมุดแล้ว';
	@override String sourceAlreadyAdded({required Object name}) => '“${name}” ถูกเพิ่มไปแล้ว';
	@override String sourceContainsExisting({required Object name}) => 'มีโฟลเดอร์ที่เพิ่มไว้แล้ว “${name}” อยู่ภายใน การเพิ่มโฟลเดอร์แม่ยังไม่รองรับในขณะนี้';
	@override String get addSourceFailed => 'ไม่สามารถเพิ่มโฟลเดอร์นั้นได้';
	@override String get fileMissing => 'ไฟล์นั้นไม่มีอยู่ในดิสก์แล้ว';
	@override String get permissionDenied => 'ไม่ได้รับอนุญาตให้เข้าถึงไฟล์ · แตะเพื่ออนุญาต';
	@override String get noVideosFound => 'ไม่มีวิดีโอในโฟลเดอร์นี้';
	@override String get emptyTitle => 'เพิ่มโฟลเดอร์เพื่อรับชมวิดีโอที่มีอยู่แล้วในอุปกรณ์นี้';
	@override String get emptyPrivacyNote => 'ไฟล์ถูกอ่านบนอุปกรณ์นี้เท่านั้น ไม่มีการอัปโหลดใดๆ';
	@override String removeSourceTitle({required Object name}) => 'ลบ “${name}” หรือไม่';
	@override String get removeSourceBody => 'ไฟล์ยังคงอยู่ในดิสก์ ลบเฉพาะรายการในคลังนี้เท่านั้น';
	@override String get remove => 'ลบ';
	@override String get removeFolder => 'ลบโฟลเดอร์';
	@override String get removeFolderSelectTitle => 'เลือกโฟลเดอร์ที่จะลบ';
	@override String get longPressToRemove => 'กดค้างเพื่อลบโฟลเดอร์นี้';
	@override String get clearProgress => 'ล้างประวัติการรับชมในเครื่อง';
	@override String clearProgressCount({required Object count}) => '${count} รายการ';
	@override String get clearProgressEmpty => 'ยังไม่มีประวัติการรับชมในเครื่อง';
	@override String get clearProgressTitle => 'ล้างประวัติการรับชมในเครื่องหรือไม่';
	@override String get clearProgressBody => 'จะลบเฉพาะตำแหน่งการเล่นและเครื่องหมายรับชมแล้วเท่านั้น ไฟล์และโฟลเดอร์ของคุณจะคงอยู่เหมือนเดิม';
	@override String clearProgressDone({required Object count}) => 'ล้างประวัติการรับชมในเครื่องแล้ว ${count} รายการ';
	@override String get clearAction => 'ล้าง';
	@override String get iosManualRescanNotice => 'iOS ไม่ตรวจจับไฟล์ใหม่โดยอัตโนมัติ คุณจะต้องสแกนใหม่ด้วยตนเองหลังเพิ่มหรือลบไฟล์';
}

// Path: historyPage
class _TranslationsHistoryPageTh extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'ลบออกจากประวัติ';
	@override String get removed => 'ลบออกจากประวัติแล้ว';
	@override String watchedTo({required Object time}) => 'ดูถึง ${time}';
	@override String get finished => 'ดูจบแล้ว';
	@override String clearTabTitle({required Object tab}) => 'ล้าง "${tab}"';
	@override String clearTabConfirm({required Object tab}) => 'ประวัติทั้งหมดใน "${tab}" จะถูกลบ รวมถึงตำแหน่งการรับชมของวิดีโอเหล่านั้น ไม่สามารถย้อนกลับได้';
	@override String get rangeByLastViewed => 'กรองตามเวลาที่ดูล่าสุด';
}

// Path: ai
class _TranslationsAiTh extends TranslationsAiEn {
	_TranslationsAiTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI';
	@override String get providers => 'ผู้ให้บริการ';
	@override String get providersHint => 'เพิ่มผู้ให้บริการ AI อย่างน้อยหนึ่งราย แล้วเลือกผู้ให้บริการสำหรับแต่ละฟีเจอร์';
	@override String get addProvider => 'เพิ่มผู้ให้บริการ';
	@override String get noProviders => 'ยังไม่มีผู้ให้บริการ เพิ่มผู้ให้บริการเพื่อเปิดใช้งานการแปล การค้นหา และลายเซ็นด้วย AI';
	@override String get pickPreset => 'เลือกผู้ให้บริการ';
	@override String get providerNameLabel => 'ชื่อ';
	@override String get apiKey => 'คีย์ API';
	@override String get baseUrl => 'ปลายทาง API';
	@override String get model => 'โมเดล';
	@override String get modelPick => 'เลือกโมเดล';
	@override String get modelEmpty => 'ไม่สามารถโหลดรายการโมเดลได้ คุณยังสามารถพิมพ์ชื่อโมเดลได้โดยตรง';
	@override String get advanced => 'ขั้นสูง';
	@override String get reasoning => 'โมเดลการให้เหตุผล';
	@override String get streaming => 'เอาต์พุตแบบสตรีม';
	@override String get structuredOutput => 'เอาต์พุตที่มีโครงสร้าง';
	@override String get structuredOutputHint => 'จำเป็นสำหรับการค้นหาด้วย AI ปลายทางรีเลย์หลายแห่งไม่รองรับ ให้ปิดตัวเลือกนี้หากการค้นหาล้มเหลวบ่อยครั้ง';
	@override String get temperature => 'อุณหภูมิ';
	@override String get maxTokens => 'โทเค็นสูงสุด';
	@override String get maxTokensAuto => 'อัตโนมัติ (ขีดจำกัดของโมเดล)';
	@override String get test => 'ทดสอบ';
	@override String get testOk => 'เชื่อมต่อสำเร็จ';
	@override String get deleteProvider => 'ลบผู้ให้บริการ';
	@override String get usedBy => 'ใช้งานโดย';
	@override String get taskBindings => 'การกำหนดฟีเจอร์';
	@override String get taskBindingsHint => 'แต่ละฟีเจอร์สามารถใช้ผู้ให้บริการที่แตกต่างกันได้';
	@override String get taskTranslate => 'การแปล';
	@override String get taskSearch => 'ค้นหาด้วย AI';
	@override String get taskSignature => 'ลายเซ็น';
	@override String get taskAuto => 'อัตโนมัติ';
	@override String get usage => 'การใช้งาน';
	@override String get usageCalls => 'การเรียกใช้';
	@override String get usageTokens => 'โทเค็น';
	@override String get usageFailures => 'ล้มเหลว';
	@override String get usageReset => 'ล้างสถิติ';
	@override String get usageEmpty => 'ยังไม่มีประวัติการเรียกใช้';
	@override String get openSettings => 'เปิดการตั้งค่า AI';
	@override String get notConfigured => 'ยังไม่ได้กำหนดค่า';
	@override String get searchTitle => 'ค้นหาด้วย AI';
	@override String get searchHint => 'อธิบายสิ่งที่คุณกำลังค้นหา แล้ว AI จะช่วยกรอกคำค้นหาและตัวกรองให้';
	@override String get searchPlaceholder => 'เช่น MMD ล่าสุดที่มียอดดูมากกว่า 10,000 ครั้ง';
	@override String get searchApply => 'ค้นหาด้วยเงื่อนไขเหล่านี้';
	@override String get searchEmpty => 'ไม่สามารถแปลงเป็นเงื่อนไขการค้นหาได้ ลองอธิบายด้วยวิธีอื่นดู';
	@override String get searchFilters => 'ตัวกรอง';
	@override String searchSwitchSegment({required Object segment}) => 'สลับไปที่ ${segment}';
	@override String get searchGenerating => 'กำลังประมวลผล…';
	@override String get searchRetrying => 'ครั้งก่อนล้มเหลว กำลังลองใหม่…';
	@override String searchRetryReason({required Object reason}) => 'สาเหตุ: ${reason}';
	@override String get searchStageWaiting => 'ส่งคำขอแล้ว กำลังรอการตอบกลับ…';
	@override String get searchStageThinkingNext => 'กำลังคิดขั้นต่อไป…';
	@override String get searchStageReasoning => 'กำลังให้เหตุผล…';
	@override String get searchStageTool => 'กำลังลองค้นหา…';
	@override String searchStageDrafting({required Object chars}) => 'กำลังเขียนคำตอบ · ${chars} ตัวอักษร';
	@override String get searchStageParsing => 'กำลังจัดระเบียบผลลัพธ์…';
	@override String get searchThinking => 'กระบวนการคิด';
	@override String get searchKeywordNeedsQuotes => 'คำค้นนี้ไม่ได้ใส่เครื่องหมายคำพูด Iwara จึงจับคู่แบบหลวม ๆ — เมื่อเรียงแบบนี้ หน้าแรกจะแทบไม่เกี่ยวข้อง ใส่ "เครื่องหมายคำพูด" หรือเรียงตามความเกี่ยวข้อง';
	@override String searchToolProbing({required Object query}) => 'ลองค้น ${query}';
	@override String searchToolFound({required Object count, required Object titles}) => '${count} รายการ · ${titles}';
	@override String searchToolFailed({required Object reason}) => 'ล้มเหลว: ${reason}';
	@override String searchFiltersDropped({required Object count}) => 'ลบตัวกรอง ${count} รายการที่ไม่มีในส่วนนี้แล้ว';
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
class _TranslationsCommonPaginationTh extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'ทั้งหมด ${num} รายการ';
	@override String get jumpToPage => 'ข้ามไปที่หน้า';
	@override String pleaseEnterPageNumber({required Object max}) => 'โปรดป้อนหมายเลขหน้า (1-${max})';
	@override String get pageNumber => 'หมายเลขหน้า';
	@override String get jump => 'ข้ามไป';
	@override String invalidPageNumber({required Object max}) => 'โปรดป้อนหมายเลขหน้าที่ถูกต้อง (1-${max})';
	@override String get invalidInput => 'โปรดป้อนหมายเลขหน้าที่ถูกต้อง';
	@override String get waterfall => 'แบบน้ำตก';
	@override String get pagination => 'แบบแบ่งหน้า';
}

// Path: errors.network
class _TranslationsErrorsNetworkTh extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'ข้อผิดพลาดเครือข่าย - ';
	@override String get failedToConnectToServer => 'เชื่อมต่อกับเซิร์ฟเวอร์ล้มเหลว';
	@override String get serverNotAvailable => 'เซิร์ฟเวอร์ไม่พร้อมใช้งาน';
	@override String get requestTimeout => 'หมดเวลาการร้องขอ';
	@override String get unexpectedError => 'ข้อผิดพลาดที่ไม่คาดคิด';
	@override String get invalidResponse => 'การตอบสนองไม่ถูกต้อง';
	@override String get invalidRequest => 'คำขอไม่ถูกต้อง';
	@override String get invalidUrl => 'URL ไม่ถูกต้อง';
	@override String get invalidMethod => 'เมธอดไม่ถูกต้อง';
	@override String get invalidHeader => 'ส่วนหัวไม่ถูกต้อง';
	@override String get invalidBody => 'เนื้อหาคำขอไม่ถูกต้อง';
	@override String get invalidStatusCode => 'รหัสสถานะไม่ถูกต้อง';
	@override String get serverError => 'เซิร์ฟเวอร์เกิดข้อผิดพลาด';
	@override String get requestCanceled => 'คำขอถูกยกเลิก';
	@override String get invalidPort => 'พอร์ตไม่ถูกต้อง';
	@override String get proxyPortError => 'พอร์ตพร็อกซีไม่ถูกต้อง';
	@override String get connectionRefused => 'การเชื่อมต่อถูกปฏิเสธ';
	@override String get networkUnreachable => 'ไม่สามารถเข้าถึงเครือข่ายได้';
	@override String get noRouteToHost => 'ไม่มีเส้นทางไปยังโฮสต์';
	@override String get connectionFailed => 'การเชื่อมต่อล้มเหลว';
	@override String get sslConnectionFailed => 'การเชื่อมต่อ SSL ล้มเหลว โปรดตรวจสอบการตั้งค่าเครือข่ายของคุณ';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingTh extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'แป้นพิมพ์ลัด';
	@override String get entryLabel => 'แป้นพิมพ์ลัด';
	@override String get entryDesc => 'กำหนดค่าแป้นพิมพ์ลัดของแอปเอง (หลักๆ สำหรับเดสก์ท็อป)';
	@override String get desktopHint => 'แป้นพิมพ์ลัดใช้ได้กับแป้นพิมพ์เดสก์ท็อปเป็นหลัก บนมือถือมักใช้ท่าทางสัมผัส';
	@override String get resetAll => 'รีเซ็ตทั้งหมดเป็นค่าเริ่มต้น';
	@override String get resetAllConfirm => 'รีเซ็ตแป้นพิมพ์ลัดทั้งหมดของแอปกลับเป็นค่าเริ่มต้นหรือไม่?';
	@override String get resetToDefault => 'รีเซ็ตเป็นค่าเริ่มต้น';
	@override String get resetScope => 'รีเซ็ตส่วนนี้';
	@override String get notSet => 'ไม่ได้ตั้งค่า';
	@override String get addShortcut => 'เพิ่มแป้นพิมพ์ลัด';
	@override String get removeShortcut => 'ลบแป้นพิมพ์ลัดนี้';
	@override String get pressNewShortcut => 'กดแป้นพิมพ์ลัดใหม่…';
	@override String get recordingCancelHint => 'กด Esc เพื่อยกเลิก';
	@override String get mouseHint => 'คุณยังสามารถผูกปุ่มด้านข้างของเมาส์ (ย้อนกลับ / ไปข้างหน้า) หรือปุ่มกลางได้ด้วย';
	@override String get mouseNotSupportedInScope => 'พื้นที่นี้ไม่รองรับปุ่มเมาส์ โปรดใช้แป้นพิมพ์แทน';
	@override String get capabilityKeyboardOnly => 'พื้นที่นี้ยอมรับเฉพาะแป้นบนแป้นพิมพ์เท่านั้น';
	@override String get capabilityKeyboardAndMouse => 'พื้นที่นี้ยอมรับแป้นบนแป้นพิมพ์ รวมถึงปุ่มกลางและปุ่มด้านข้างของเมาส์';
	@override String get capabilityKeyboardAndMouseMobile => 'พื้นที่นี้ยอมรับแป้นบนแป้นพิมพ์ รวมถึงปุ่มกลางและปุ่มไปข้างหน้าของเมาส์ (ปุ่มย้อนกลับถูกระบบใช้งานแล้ว)';
	@override String get rejectMultipleButtons => 'กดปุ่มเมาส์ทีละปุ่ม';
	@override String get rejectPlatformBack => 'ระบบใช้ปุ่มนี้สำหรับ "ย้อนกลับ" แล้ว การผูกปุ่มนี้จะทำให้ย้อนกลับซ้ำสองครั้ง';
	@override String get detectedLabel => 'ตรวจพบแล้ว';
	@override String get reservedKey => 'แป้นนี้สงวนไว้โดยระบบและไม่สามารถผูกได้';
	@override String reservedForGlobalBack({required Object action}) => 'แป้นนี้ผูกกับ "${action}" ไว้ จึงสงวนไว้ที่นี่เพื่อให้คุณยังสามารถออกจากหน้านี้ได้';
	@override String get conflictTitle => 'ความขัดแย้งของแป้นพิมพ์ลัด';
	@override String conflictMessage({required Object action}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" แล้ว การดำเนินการต่อจะเป็นการลบการผูกเดิมออก';
	@override String get conflictContinue => 'ผูกต่อไป';
	@override String get shadowWarningTitle => 'แป้นพิมพ์ลัดส่วนกลางซ้ำซ้อน';
	@override String shadowWarningMessage({required Object action}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" ในระดับส่วนกลาง การผูกที่นี่จะแทนที่การกระทำดังกล่าวเฉพาะภายในส่วนนี้เท่านั้น';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" ใน ${scope} แล้ว เมื่อเข้าสู่ส่วนนั้น แป้นพิมพ์ลัดส่วนกลางนี้จะถูกแทนที่';
	@override String get searchHint => 'ค้นหาแป้นพิมพ์ลัด…';
	@override String get scopeGlobal => 'ส่วนกลาง';
	@override String get scopeGallery => 'แกลเลอรี';
	@override String get scopeVideo => 'วิดีโอ';
	@override String get categoryNavigation => 'การนำทาง';
	@override String get categoryZoom => 'การซูม';
	@override String get categoryPlayback => 'การเล่น';
	@override String get categorySeek => 'การเลื่อนเวลา';
	@override String get categoryVolume => 'ระดับเสียง';
	@override String get categoryDisplay => 'การแสดงผล';
	@override String get actionGlobalBack => 'ย้อนกลับ';
	@override String get actionGalleryNext => 'รูปถัดไป';
	@override String get actionGalleryPrevious => 'รูปก่อนหน้า';
	@override String get actionGalleryZoomIn => 'ซูมเข้า';
	@override String get actionGalleryZoomOut => 'ซูมออก';
	@override String get actionGalleryResetZoom => 'รีเซ็ตการซูม';
	@override String get actionGalleryPlayPause => 'เล่น / หยุดชั่วคราว';
	@override String get actionGallerySeekBackward => 'ย้อนกลับ';
	@override String get actionGallerySeekForward => 'เดินหน้าอย่างเร็ว';
	@override String get actionGalleryToggleMute => 'สลับปิด/เปิดเสียง';
	@override String get actionPlayPause => 'เล่น / หยุดชั่วคราว';
	@override String get actionSpeedUp => 'เพิ่มความเร็ว';
	@override String get actionSpeedDown => 'ลดความเร็ว';
	@override String get actionSeekForward => 'เลื่อนไปข้างหน้า';
	@override String get actionSeekBackward => 'เลื่อนถอยหลัง';
	@override String get actionVolumeUp => 'เพิ่มระดับเสียง';
	@override String get actionVolumeDown => 'ลดระดับเสียง';
	@override String get actionToggleMute => 'สลับปิด/เปิดเสียง';
	@override String get actionToggleFullscreen => 'สลับโหมดเต็มหน้าจอ';
	@override String get seekLongPressHint => 'กดปุ่มเลื่อนไปข้างหน้า / ถอยหลังค้างไว้เพื่อเข้าสู่โหมดความเร็วด้วยการกดค้าง';
	@override String get zoomSectionTitle => 'การซูมรูปภาพ (คงที่)';
	@override String get zoomFixedNote => 'แป้นพิมพ์ลัดด้านล่างนี้ได้รับการกำหนดไว้แล้วและไม่สามารถเปลี่ยนแปลงได้';
	@override String get zoomScaleLabel => 'ซูมรูปภาพ';
	@override String get zoomScaleHint => 'Ctrl + ล้อเลื่อน';
	@override String get zoomRotateLabel => 'หมุนรูปภาพ';
	@override String get zoomRotateHint => 'Shift + ล้อเลื่อน';
	@override String get zoomPinchGesture => 'หนีบนิ้ว';
	@override String get zoomTwoFingerRotateGesture => 'หมุนด้วยสองนิ้ว';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsTh extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get name => 'ฟอรัม';
	@override String get configureYourForumSettings => 'กำหนดค่าการตั้งค่าฟอรัมของคุณ';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsTh extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'การตั้งค่าแกลเลอรี';
	@override String get gallerySettingsSubtitle => 'กำหนดค่ากำหนดของโปรแกรมดูแกลเลอรี';
	@override String get defaultViewerQuality => 'คุณภาพเริ่มต้นของโปรแกรมดู';
	@override String get defaultViewerQualityDesc => 'เลือกคุณภาพของรูปภาพที่จะแสดงเป็นค่าเริ่มต้นเมื่อเปิดโปรแกรมดูแกลเลอรี';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsTh extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การบล็อกเนื้อหา';
	@override String get subtitle => 'ซ่อนวิดีโอและแกลเลอรีที่มีชื่อเรื่องตรงกับคำสำคัญหรือรูปแบบ หรือมาจากผู้ใช้ที่ถูกบล็อกโดยอัตโนมัติ การจับคู่ทั้งหมดเกิดขึ้นบนอุปกรณ์ของคุณ — ไม่มีการอัปโหลดข้อมูลใดๆ';
	@override String get blocked => 'บล็อกแล้ว';
	@override String get reveal => 'แสดง';
	@override String get reblock => 'บล็อกอีกครั้ง';
	@override String get why => 'ทำไมจึงถูกบล็อก?';
	@override String get manageRules => 'จัดการกฎ';
	@override String reasonKeyword({required Object value}) => 'ชื่อเรื่องประกอบด้วย "${value}"';
	@override String reasonRegex({required Object value}) => 'ชื่อเรื่องตรงกับนิพจน์ "${value}"';
	@override String get reasonUser => 'มาจากผู้ใช้ที่ถูกบล็อก';
	@override String get addRule => 'เพิ่มกฎ';
	@override String get editRule => 'แก้ไขกฎ';
	@override String get deleteRule => 'ลบกฎ';
	@override String get ruleType => 'ประเภทกฎ';
	@override String get keyword => 'คำสำคัญ';
	@override String get regex => 'นิพจน์ทั่วไป (Regex)';
	@override String get userId => 'ผู้ใช้';
	@override String get value => 'ข้อความที่ต้องการจับคู่';
	@override String get caseSensitive => 'ตรงตามตัวพิมพ์ใหญ่-เล็ก';
	@override String get regexHint => 'เช่น trailer|teaser';
	@override String get valueRequired => 'โปรดป้อนข้อความที่ต้องการจับคู่';
	@override String get invalidRegex => 'นิพจน์ทั่วไปไม่ถูกต้อง';
	@override String get noRules => 'ยังไม่มีกฎ แตะ + เพื่อเพิ่ม';
	@override String get blockUser => 'บล็อก';
	@override String get unblockUser => 'เลิกบล็อก';
	@override String blockUserConfirm({required Object name}) => 'บล็อก "${name}" หรือไม่? วิดีโอและแกลเลอรีของพวกเขาจะถูกซ่อนจากรายการและการค้นหา';
	@override String get userBlocked => 'บล็อกผู้ใช้แล้ว';
	@override String get userUnblocked => 'เลิกบล็อกผู้ใช้แล้ว';
	@override String get exportRules => 'ส่งออก';
	@override String get importRules => 'นำเข้า';
	@override String get importExport => 'นำเข้า / ส่งออก';
	@override String get exportSuccess => 'ส่งออกกฎแล้ว';
	@override String get exportFailed => 'ไม่สามารถส่งออกกฎได้';
	@override String importSuccess({required Object count}) => 'นำเข้า ${count} กฎเรียบร้อยแล้ว';
	@override String get importFailed => 'ไม่สามารถนำเข้ากฎได้';
	@override String get regexHelp => 'ความช่วยเหลือเกี่ยวกับรูปแบบ';
	@override String get regexHelpTitle => 'เอกสารอ้างอิง Regex';
	@override String get regexHelpIntro => 'นิพจน์ทั่วไปสามารถจับคู่ชื่อเรื่องได้อย่างยืดหยุ่นมากกว่าคำสำคัญธรรมดา ตัวอย่างทั่วไปบางส่วน:';
	@override String get regexHelpTapHint => 'แตะตัวอย่างเพื่อนำไปใช้';
	@override String get regexEx1Pattern => 'ตัวอย่าง|ทีเซอร์|โบนัส';
	@override String get regexEx1Desc => 'ตรงกับคำใดคำหนึ่งเหล่านี้ ("|" หมายถึง "หรือ")';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'ชื่อเรื่องที่ขึ้นต้นด้วย [วงเล็บ]';
	@override String get regexEx3Pattern => 'คอลเลกชัน\$';
	@override String get regexEx3Desc => 'ชื่อเรื่องที่ลงท้ายด้วย "Collection"';
	@override String get regexEx4Pattern => 'ตอนที่.';
	@override String get regexEx4Desc => '\\d+ คือตัวเลขตั้งแต่หนึ่งหลักขึ้นไป — ตรงกับ "Ep.12"';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '\\d คือตัวเลข และ {4} หมายถึงตัวเลขสี่หลักเรียงกัน (เช่น ปี)';
	@override String get regexEx1Sample => 'ทีเซอร์เกมใหม่มาแล้ว';
	@override String get regexEx2Sample => '[Remux] ภาพยนตร์เต็มเรื่อง';
	@override String get regexEx3Sample => 'คอลเลกชันงานศิลปะฤดูใบไม้ผลิ';
	@override String get regexEx4Sample => 'รายการของฉัน ตอนที่12 สรุป';
	@override String get regexEx5Sample => 'ที่สุดแห่งปี 2024';
	@override String get regexHelpSampleLabel => 'ตัวอย่างชื่อเรื่อง';
	@override String get regexHelpMatchedTag => 'ถูกบล็อก';
	@override String get regexHelpNoMatch => 'ไม่ตรงกัน';
	@override String get regexEx6Pattern => '[ซส]ีซั่น';
	@override String get regexEx6Desc => '[Ss] ตรงกับตัว S พิมพ์ใหญ่หรือพิมพ์เล็ก — ในที่นี้ใช้จับคำว่า "Season"';
	@override String get regexEx6Sample => 'ตัวอย่างซีซั่นสุดท้าย';
	@override String get regexEx7Pattern => '(ภาพยนตร์|ซีรีส์)';
	@override String get regexEx7Desc => 'วงเล็บ () จัดกลุ่มทางเลือก — ตรงกับ "the movie" หรือ "the series"';
	@override String get regexEx7Sample => 'รับชมซีรีส์ตอนนี้';
	@override String get regexEx8Pattern => 'ซีซั่น?';
	@override String get regexEx8Desc => 's? ทำให้ตัวอักษรก่อนหน้าเป็นตัวเลือกเพิ่มเติม — ตรงกับ "season" และ "seasons"';
	@override String get regexEx8Sample => 'แพ็กเกจสองซีซั่น';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ หมายถึงมีหนึ่งตัวหรือมากกว่า — ตรงกับ !, !!, !!! ...';
	@override String get regexEx9Sample => 'สุดยอด!!! ต้องดู';
	@override String get regexEx10Pattern => 'ตัวอย่าง.*ฉาก';
	@override String get regexEx10Desc => '.* ตรงกับข้อความใดๆ ที่อยู่ระหว่างกลาง — "bonus … scene"';
	@override String get regexEx10Sample => 'ตัวอย่าง ฉากที่ถูกลบ';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsTh extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get name => 'แชท';
	@override String get configureYourChatSettings => 'กำหนดค่าการตั้งค่าแชทของคุณ';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsTh extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'การตั้งค่าการดาวน์โหลด';
	@override String get enableDownloadNotifications => 'การแจ้งเตือนการดาวน์โหลด';
	@override String get enableDownloadNotificationsDescription => 'แสดงการแจ้งเตือนของระบบเมื่อการดาวน์โหลดรายการหนึ่งเสร็จสิ้นหรือล้มเหลว';
	@override String get notificationPermissionDenied => 'การอนุญาตการแจ้งเตือนถูกปฏิเสธ การแจ้งเตือนในแอปยังคงทำงานอยู่ โปรดเปิดใช้การแจ้งเตือนของระบบในการตั้งค่า';
	@override String get storagePermissionStatus => 'สถานะสิทธิ์การจัดเก็บข้อมูล';
	@override String get accessPublicDirectoryNeedStoragePermission => 'การเข้าถึงโฟลเดอร์สาธารณะจำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูล';
	@override String get checkingPermissionStatus => 'กำลังตรวจสอบสถานะสิทธิ์...';
	@override String get storagePermissionGranted => 'ได้รับสิทธิ์การจัดเก็บข้อมูลแล้ว';
	@override String get storagePermissionNotGranted => 'ยังไม่ได้รับสิทธิ์การจัดเก็บข้อมูล';
	@override String get storagePermissionGrantSuccess => 'อนุญาตสิทธิ์การจัดเก็บข้อมูลสำเร็จ';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'การอนุญาตสิทธิ์การจัดเก็บข้อมูลล้มเหลว ฟีเจอร์บางอย่างอาจถูกจำกัด';
	@override String get storagePermissionRationale => 'ในการบันทึกไฟล์ดาวน์โหลดลงในโฟลเดอร์ที่คุณเลือก แอปต้องได้รับสิทธิ์การจัดเก็บข้อมูล\n\nบน Android 11 ขึ้นไป หมายถึงสิทธิ์ "การเข้าถึงไฟล์ทั้งหมด" หากไม่มีสิทธิ์นี้ ไฟล์จะถูกบันทึกลงในโฟลเดอร์ส่วนตัวของแอปแทน';
	@override String get storagePermissionRationaleLegacy => 'ในการบันทึกไฟล์ดาวน์โหลดลงในโฟลเดอร์ที่คุณเลือก แอปต้องได้รับสิทธิ์การจัดเก็บข้อมูล\n\nหากไม่ได้รับสิทธิ์ ไฟล์จะถูกบันทึกลงในโฟลเดอร์ส่วนตัวของแอปแทน';
	@override String get grantStoragePermission => 'อนุญาตสิทธิ์การจัดเก็บข้อมูล';
	@override String get customDownloadPath => 'เส้นทางดาวน์โหลดที่กำหนดเอง';
	@override String get customDownloadPathDescription => 'เมื่อเปิดใช้งาน คุณสามารถเลือกตำแหน่งบันทึกที่กำหนดเองสำหรับไฟล์ที่ดาวน์โหลดได้';
	@override String get customDownloadPathTip => '💡 คำแนะนำ: การเลือกไดเรกทอรีสาธารณะ (เช่น โฟลเดอร์ดาวน์โหลด) จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูล ขอแนะนำให้ใช้เส้นทางที่แนะนำก่อน';
	@override String get androidWarning => 'หมายเหตุ Android: หลีกเลี่ยงการเลือกไดเรกทอรีสาธารณะ (เช่น โฟลเดอร์ดาวน์โหลด) แนะนำให้ใช้ไดเรกทอรีเฉพาะของแอปเพื่อให้มั่นใจในสิทธิ์การเข้าถึง';
	@override String get publicDirectoryPermissionTip => '⚠️ ประกาศ: คุณเลือกไดเรกทอรีสาธารณะ จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลสำหรับการดาวน์โหลดไฟล์ตามปกติ';
	@override String get permissionRequiredForPublicDirectory => 'จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลสำหรับไดเรกทอรีสาธารณะ';
	@override String get currentDownloadPath => 'เส้นทางดาวน์โหลดปัจจุบัน';
	@override String get actualDownloadPath => 'เส้นทางดาวน์โหลดจริง';
	@override String get defaultAppDirectory => 'ไดเรกทอรีเริ่มต้นของแอป';
	@override String get permissionGranted => 'ได้รับอนุญาตแล้ว';
	@override String get permissionRequired => 'จำเป็นต้องมีสิทธิ์';
	@override String get enableCustomDownloadPath => 'เปิดใช้เส้นทางดาวน์โหลดที่กำหนดเอง';
	@override String get disableCustomDownloadPath => 'ใช้เส้นทางเริ่มต้นของแอปเมื่อปิดใช้งาน';
	@override String get customDownloadPathLabel => 'เส้นทางดาวน์โหลดที่กำหนดเอง';
	@override String get selectDownloadFolder => 'เลือกโฟลเดอร์ดาวน์โหลด';
	@override String get recommendedPath => 'เส้นทางที่แนะนำ';
	@override String get selectFolder => 'เลือกโฟลเดอร์';
	@override String get filenameTemplate => 'แม่แบบชื่อไฟล์';
	@override String get filenameTemplateDescription => 'ปรับแต่งกฎการตั้งชื่อสำหรับไฟล์ที่ดาวน์โหลด รองรับการแทนที่ตัวแปร';
	@override String get videoFilenameTemplate => 'แม่แบบชื่อไฟล์วิดีโอ';
	@override String get galleryFolderTemplate => 'แม่แบบโฟลเดอร์แกลเลอรี';
	@override String get imageFilenameTemplate => 'แม่แบบชื่อไฟล์รูปภาพ';
	@override String get resetToDefault => 'รีเซ็ตเป็นค่าเริ่มต้น';
	@override String get supportedVariables => 'ตัวแปรที่รองรับ';
	@override String get supportedVariablesDescription => 'สามารถใช้ตัวแปรต่อไปนี้ในแม่แบบชื่อไฟล์ได้:';
	@override String get copyVariable => 'คัดลอกตัวแปร';
	@override String get variableCopied => 'คัดลอกตัวแปรแล้ว';
	@override String get warningPublicDirectory => 'คำเตือน: ไดเรกทอรีสาธารณะที่เลือกอาจไม่สามารถเข้าถึงได้ แนะนำให้เลือกไดเรกทอรีเฉพาะของแอป';
	@override String get downloadPathUpdated => 'อัปเดตเส้นทางดาวน์โหลดแล้ว';
	@override String get selectPathFailed => 'เลือกเส้นทางล้มเหลว';
	@override String get pickerAlreadyActive => 'ตัวเลือกโฟลเดอร์เปิดอยู่แล้ว';
	@override String get unsupportedStorageVolume => 'ไม่รองรับตำแหน่งจัดเก็บข้อมูลนี้ โปรดเลือกโฟลเดอร์ในที่จัดเก็บข้อมูลของอุปกรณ์หรือการ์ด SD';
	@override String get recommendedPathSet => 'ตั้งเป็นเส้นทางที่แนะนำแล้ว';
	@override String get setRecommendedPathFailed => 'ตั้งค่าเส้นทางที่แนะนำล้มเหลว';
	@override String get templateResetToDefault => 'รีเซ็ตเป็นแม่แบบเริ่มต้นแล้ว';
	@override String get functionalTest => 'การทดสอบการทำงาน';
	@override String get testInProgress => 'กำลังทดสอบ...';
	@override String get runTest => 'เรียกใช้การทดสอบ';
	@override String get testDownloadPathAndPermissions => 'ทดสอบว่าเส้นทางดาวน์โหลดและการกำหนดค่าสิทธิ์ทำงานได้อย่างถูกต้องหรือไม่';
	@override String get testResults => 'ผลการทดสอบ';
	@override String get testCompleted => 'การทดสอบเสร็จสมบูรณ์';
	@override String get testMultisegmentDomain => 'ตรวจสอบโดเมนค่า (หลายส่วน / เกินขีดจำกัด / รูปแบบหลบหนี)';
	@override String get testMultisegmentPaths => 'การเรนเดอร์โครงสร้างหลายส่วน (issue #126)';
	@override String get testPassed => 'รายการผ่าน';
	@override String get testFailed => 'การทดสอบล้มเหลว';
	@override String get testStoragePermissionCheck => 'การตรวจสอบสิทธิ์การจัดเก็บข้อมูล';
	@override String get testStoragePermissionGranted => 'ได้รับสิทธิ์การจัดเก็บข้อมูลแล้ว';
	@override String get testStoragePermissionMissing => 'ขาดสิทธิ์การจัดเก็บข้อมูล ฟีเจอร์บางอย่างอาจถูกจำกัด';
	@override String get testPermissionCheckFailed => 'ตรวจสอบสิทธิ์ล้มเหลว';
	@override String get testDownloadPathValidation => 'การตรวจสอบความถูกต้องของเส้นทางดาวน์โหลด';
	@override String get testPathValidationFailed => 'การตรวจสอบความถูกต้องของเส้นทางล้มเหลว';
	@override String get testFilenameTemplateValidation => 'การตรวจสอบความถูกต้องของแม่แบบชื่อไฟล์';
	@override String get testAllTemplatesValid => 'แม่แบบทั้งหมดถูกต้อง';
	@override String get testSomeTemplatesInvalid => 'บางแม่แบบมีอักขระที่ไม่ถูกต้อง';
	@override String get testTemplateValidationFailed => 'การตรวจสอบแม่แบบล้มเหลว';
	@override String get testDirectoryOperationTest => 'การทดสอบการทำงานกับไดเรกทอรี';
	@override String get testDirectoryOperationNormal => 'การสร้างไดเรกทอรีและการเขียนไฟล์เป็นปกติ';
	@override String get testDirectoryOperationFailed => 'การดำเนินการกับไดเรกทอรีล้มเหลว';
	@override String get testVideoTemplate => 'แม่แบบวิดีโอ';
	@override String get testGalleryTemplate => 'แม่แบบแกลเลอรี';
	@override String get testImageTemplate => 'แม่แบบรูปภาพ';
	@override String get testValid => 'ถูกต้อง';
	@override String get testInvalid => 'ไม่ถูกต้อง';
	@override String get testSuccess => 'สำเร็จ';
	@override String get testCorrect => 'ถูกต้อง';
	@override String get testError => 'ข้อผิดพลาด';
	@override String get testPath => 'เส้นทางการทดสอบ';
	@override String get testBasePath => 'เส้นทางฐาน';
	@override String get testDirectoryCreation => 'การสร้างไดเรกทอรี';
	@override String get testFileWriting => 'การเขียนไฟล์';
	@override String get testFileContent => 'เนื้อหาไฟล์';
	@override String get checkingPathStatus => 'กำลังตรวจสอบสถานะเส้นทาง...';
	@override String get unableToGetPathStatus => 'ไม่สามารถรับสถานะเส้นทางได้';
	@override String get actualPathDifferentFromSelected => 'หมายเหตุ: เส้นทางจริงแตกต่างจากเส้นทางที่เลือก';
	@override String get grantPermission => 'อนุญาตสิทธิ์';
	@override String get fixIssue => 'แก้ไขปัญหา';
	@override String get issueFixed => 'แก้ไขปัญหาแล้ว';
	@override String get fixFailed => 'แก้ไขล้มเหลว โปรดจัดการด้วยตนเอง';
	@override String get lackStoragePermission => 'ขาดสิทธิ์การจัดเก็บข้อมูล';
	@override String get cannotAccessPublicDirectory => 'ไม่สามารถเข้าถึงไดเรกทอรีสาธารณะได้ จำเป็นต้องมี "สิทธิ์การเข้าถึงไฟล์ทั้งหมด"';
	@override String get cannotCreateDirectory => 'ไม่สามารถสร้างไดเรกทอรีได้';
	@override String get directoryNotWritable => 'ไม่สามารถเขียนลงในไดเรกทอรีได้';
	@override String get insufficientSpace => 'พื้นที่ว่างไม่เพียงพอ';
	@override String get pathValid => 'เส้นทางถูกต้อง';
	@override String get validationFailed => 'การตรวจสอบล้มเหลว';
	@override String get usingDefaultAppDirectory => 'กำลังใช้ไดเรกทอรีเริ่มต้นของแอป';
	@override String get appPrivateDirectory => 'ไดเรกทอรีส่วนตัวของแอป';
	@override String get appPrivateDirectoryDesc => 'ปลอดภัยและเชื่อถือได้ ไม่ต้องใช้สิทธิ์เพิ่มเติม';
	@override String get downloadDirectory => 'ไดเรกทอรีดาวน์โหลด';
	@override String get downloadDirectoryDesc => 'ตำแหน่งดาวน์โหลดเริ่มต้นของระบบ จัดการง่าย';
	@override String get moviesDirectory => 'ไดเรกทอรีภาพยนตร์';
	@override String get moviesDirectoryDesc => 'ไดเรกทอรีภาพยนตร์ของระบบ แอปสื่อสามารถรับรู้ได้';
	@override String get documentsDirectory => 'ไดเรกทอรีเอกสาร';
	@override String get documentsDirectoryDesc => 'ไดเรกทอรีเอกสารของแอป iOS';
	@override String get requiresStoragePermission => 'จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลเพื่อเข้าถึง';
	@override String get recommendedPaths => 'เส้นทางที่แนะนำ';
	@override String get externalAppPrivateDirectory => 'ไดเรกทอรีส่วนตัวของแอปในพื้นที่จัดเก็บภายนอก';
	@override String get externalAppPrivateDirectoryDesc => 'ไดเรกทอรีส่วนตัวของแอปในที่จัดเก็บภายนอก ผู้ใช้เข้าถึงได้ มีพื้นที่ขนาดใหญ่กว่า';
	@override String get internalAppPrivateDirectory => 'ไดเรกทอรีส่วนตัวของแอปในพื้นที่จัดเก็บภายใน';
	@override String get internalAppPrivateDirectoryDesc => 'ที่จัดเก็บภายในของแอป ไม่จำเป็นต้องมีสิทธิ์ มีขนาดพื้นที่น้อยกว่า';
	@override String get appDocumentsDirectory => 'ไดเรกทอรีเอกสารของแอป';
	@override String get appDocumentsDirectoryDesc => 'ไดเรกทอรีเอกสารเฉพาะของแอป ปลอดภัยและเชื่อถือได้';
	@override String get downloadsFolder => 'โฟลเดอร์ดาวน์โหลด';
	@override String get downloadsFolderDesc => 'ไดเรกทอรีดาวน์โหลดเริ่มต้นของระบบ';
	@override String get selectRecommendedDownloadLocation => 'เลือกตำแหน่งดาวน์โหลดที่แนะนำ';
	@override String get noRecommendedPaths => 'ไม่มีเส้นทางที่แนะนำ';
	@override String get recommended => 'แนะนำ';
	@override String get requiresPermission => 'ต้องใช้สิทธิ์';
	@override String get authorizeAndSelect => 'อนุญาตสิทธิ์และเลือก';
	@override String get select => 'เลือก';
	@override String get permissionAuthorizationFailed => 'การอนุญาตสิทธิ์ล้มเหลว ไม่สามารถเลือกเส้นทางนี้ได้';
	@override String get pathValidationFailed => 'การตรวจสอบเส้นทางล้มเหลว';
	@override String get downloadPathSetTo => 'ตั้งค่าเส้นทางดาวน์โหลดเป็น';
	@override String get setPathFailed => 'ตั้งค่าเส้นทางล้มเหลว';
	@override String get variableTitle => 'ชื่อเรื่อง';
	@override String get variableAuthorcache => 'ชื่อแรกที่เคยเห็นของผู้สร้าง (ไม่เปลี่ยนตามการเปลี่ยนชื่อ)';
	@override String get variableAuthor => 'ชื่อผู้สร้าง';
	@override String get variableUsername => 'ชื่อผู้ใช้ของผู้สร้าง';
	@override String get variableQuality => 'คุณภาพวิดีโอ';
	@override String get variableFilename => 'ชื่อไฟล์ต้นฉบับ';
	@override String get variableId => 'รหัสเนื้อหา';
	@override String get variableCount => 'จำนวนรูปภาพในแกลเลอรี';
	@override String get variableDate => 'วันที่ปัจจุบัน (YYYY-MM-DD)';
	@override String get variableTime => 'เวลาปัจจุบัน (HH-MM-SS)';
	@override String get variableDatetime => 'วันที่และเวลาปัจจุบัน (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'การตั้งค่าการดาวน์โหลด';
	@override String get downloadSettingsSubtitle => 'กำหนดค่าเส้นทางดาวน์โหลดและกฎการตั้งชื่อไฟล์';
	@override String get suchAsTitleQuality => 'ตัวอย่างเช่น: %title_%quality';
	@override String get suchAsTitleId => 'ตัวอย่างเช่น: %title_%id';
	@override String get suchAsTitleFilename => 'ตัวอย่างเช่น: %title_%filename';
	@override String get structureSection => 'โครงสร้างการบันทึกและการตั้งชื่อ';
	@override String get structureSectionDescription => 'ไฟล์ที่ดาวน์โหลดจะถูกจัดเรียงลงโฟลเดอร์ย่อยตามรูปแบบที่เลือกด้านล่าง มีผลเฉพาะการดาวน์โหลดครั้งใหม่เท่านั้น ไฟล์เดิมไม่ถูกยุ่ง';
	@override String get structureNoticeTitle => 'ฟีเจอร์ใหม่: จัดเรียงตามผู้สร้างอัตโนมัติ';
	@override String get structureNoticeBody => 'เลือกด้านล่างได้เลย · มีผลเฉพาะไฟล์ที่ดาวน์โหลดใหม่ ไฟล์เดิมไม่ถูกยุ่ง';
	@override String get presetFlat => 'แบบราบ';
	@override String get presetFlatDesc => 'ไฟล์ทั้งหมดวางไว้ที่รากของโฟลเดอร์ดาวน์โหลดโดยตรง';
	@override String get presetAuthor => 'ตามผู้สร้าง';
	@override String get presetAuthorBadge => 'แนะนำ';
	@override String get presetAuthorDesc => 'โฟลเดอร์ละหนึ่งผู้สร้าง · เปลี่ยนชื่อแล้วไม่แยกโฟลเดอร์';
	@override String get presetDate => 'ตามวันที่';
	@override String get presetDateDesc => 'จัดเรียงตามวันที่ดาวน์โหลด';
	@override String get presetCustomActive => 'ใช้งานอยู่';
	@override String get structurePreviewLabel => 'ตัวอย่าง';
	@override String get structurePreviewNote => 'ส่วนที่มีสีคือระดับการจัดระเบียบ เปลี่ยนตามรูปแบบที่เลือกทันที';
	@override String get pathTooLongWarning => 'เส้นทางสัมพัทธ์เกิน 200 ตัวอักษร อาจบันทึกไม่สำเร็จบนอุปกรณ์บางรุ่น';
	@override String get pathTemplateEditorEntry => 'เทมเพลตเส้นทางแบบกำหนดเอง';
	@override String get pathTemplateEditorEntryDesc => 'กำหนดโครงสร้างโฟลเดอร์และชื่อไฟล์ด้วยตัวเอง';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorTh pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorTh._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesTh extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get hot => 'กำลังฮิต';
	@override String get favorites => 'ถูกใจมาก';
	@override String get latest => 'ล่าสุด';
	@override String get popularity => 'ยอดนิยม';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsTh extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'คำขอล้มเหลว รหัสสถานะ';
	@override String get connectionTimeout => 'หมดเวลาการเชื่อมต่อ โปรดตรวจสอบการเชื่อมต่อเครือข่าย';
	@override String get sendTimeout => 'หมดเวลาส่งคำขอ';
	@override String get receiveTimeout => 'หมดเวลาการรับคำตอบ';
	@override String get badCertificate => 'การตรวจสอบใบรับรองล้มเหลว';
	@override String get resourceNotFound => 'ไม่พบทรัพยากรที่ร้องขอ';
	@override String get accessDenied => 'การเข้าถึงถูกปฏิเสธ อาจต้องมีการตรวจสอบสิทธิ์หรือการอนุญาต';
	@override String get serverError => 'เซิร์ฟเวอร์เกิดข้อผิดพลาดภายใน';
	@override String get serviceUnavailable => 'บริการไม่พร้อมใช้งานชั่วคราว';
	@override String get requestCancelled => 'คำขอถูกยกเลิก';
	@override String get connectionError => 'เกิดข้อผิดพลาดในการเชื่อมต่อเครือข่าย โปรดตรวจสอบการตั้งค่าเครือข่าย';
	@override String get networkRequestFailed => 'คำขอเครือข่ายล้มเหลว';
	@override String get searchVideoError => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะค้นหาวิดีโอ';
	@override String get getPopularVideoError => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงข้อมูลวิดีโอยอดนิยม';
	@override String get getVideoDetailError => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงรายละเอียดวิดีโอ';
	@override String get parseVideoDetailError => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงและแยกวิเคราะห์รายละเอียดวิดีโอ';
	@override String get downloadFileError => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดาวน์โหลดไฟล์';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingTh extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'กำลังรับข้อมูลวิดีโอ...';
	@override String get cancel => 'ยกเลิก';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesTh extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'ไม่พบวิดีโอหรือวิดีโอถูกลบไปแล้ว';
	@override String get unableToGetVideoPlayLink => 'ไม่สามารถรับลิงก์สำหรับเล่นวิดีโอได้';
	@override String get getVideoDetailFailed => 'รับรายละเอียดวิดีโอล้มเหลว';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoTh extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'ข้อมูลวิดีโอ';
	@override String get currentQuality => 'คุณภาพปัจจุบัน';
	@override String get duration => 'ความยาว';
	@override String get resolution => 'ความละเอียด';
	@override String get fileInfo => 'ข้อมูลไฟล์';
	@override String get fileName => 'ชื่อไฟล์';
	@override String get fileSize => 'ขนาดไฟล์';
	@override String get filePath => 'เส้นทางไฟล์';
	@override String get copyPath => 'คัดลอกเส้นทาง';
	@override String get openFolder => 'เปิดโฟลเดอร์';
	@override String get pathCopiedToClipboard => 'คัดลอกเส้นทางไปยังคลิปบอร์ดแล้ว';
	@override String get openFolderFailed => 'เปิดโฟลเดอร์ล้มเหลว';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideTh extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'ตัวอย่างวิดีโอ';
	@override String get title => 'คำแนะนำท่าทางและการโต้ตอบ';
	@override String get viewGuide => 'คำแนะนำท่าทางและการโต้ตอบ';
	@override String get firstTimeIntro => 'ใช้เวลาสักครู่เพื่อเรียนรู้ท่าทางควบคุมเครื่องเล่น คุณสามารถเปิดคู่มือนี้ได้ทุกเมื่อจากการตั้งค่าเครื่องเล่น';
	@override String get startWatching => 'เข้าใจแล้ว เริ่มรับชม';
	@override String get basicTitle => 'การควบคุมพื้นฐาน';
	@override String get zoomTitle => 'ซูม / หมุน / เลื่อนภาพ';
	@override String get restoreTip => 'แตะปุ่ม "คืนค่าเดิม" ที่ด้านล่างขวาเพื่อรีเซ็ตการซูม การหมุน และตำแหน่ง';
	@override String get mTap => 'แตะครั้งเดียว: แสดง / ซ่อนส่วนควบคุม';
	@override String get mDoubleTap => 'แตะสองครั้ง: ย้อนกลับ (ซ้าย) / หยุดชั่วคราว (กลาง) / เดินหน้า (ขวา)';
	@override String get mHorizontalDrag => 'ปัดแนวนอน: เลื่อนหาตำแหน่ง';
	@override String get mVerticalDrag => 'ปัดแนวตั้ง: ความสว่าง (ซ้าย) / ระดับเสียง (ขวา)';
	@override String get mLongPress => 'กดค้าง: เร่งความเร็วชั่วคราว';
	@override String get mPinch => 'หนีบสองนิ้ว: ซูมภาพ';
	@override String get mRotate => 'หมุนสองนิ้ว: หมุนภาพ';
	@override String get dTap => 'คลิก: แสดง / ซ่อนส่วนควบคุม';
	@override String get dDoubleTap => 'ดับเบิลคลิก: ย้อนกลับ (ซ้าย) / หยุดชั่วคราว (กลาง) / เดินหน้า (ขวา)';
	@override String get dKeys => 'แป้นเลื่อนหาตำแหน่ง: แตะเพื่อข้ามถอยหลัง / เดินหน้า กดค้างเพื่อเร่งความเร็ว; แป้นปรับความเร็ว: ปรับระดับความเร็วระหว่างการเล่นปกติ; Space: เล่น / หยุดชั่วคราว';
	@override String get dTrackpadPinch => 'หนีบนิ้วบนแทร็กแพด: ซูมภาพ';
	@override String get dTrackpadRotate => 'หมุนนิ้วบนแทร็กแพด: หมุนภาพ';
	@override String get dCtrlWheel => 'Ctrl + ล้อเลื่อน: ซูมโดยอิงตามตำแหน่งเคอร์เซอร์';
	@override String get dShiftWheel => 'Shift + ล้อเลื่อน: หมุนโดยอิงตามตำแหน่งเคอร์เซอร์';
	@override late final _TranslationsVideoDetailGestureGuideQuestTh quest = _TranslationsVideoDetailGestureGuideQuestTh._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerTh extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'เกิดข้อผิดพลาดขณะโหลดแหล่งที่มาของวิดีโอ';
	@override String get errorWhileSettingUpListeners => 'เกิดข้อผิดพลาดขณะตั้งค่าตัวรับฟังเหตุการณ์';
	@override String get serverFaultDetectedAutoSwitched => 'ตรวจพบข้อผิดพลาดของเซิร์ฟเวอร์ สลับเส้นทางและลองใหม่โดยอัตโนมัติ';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonTh extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'กำลังดึงข้อมูลวิดีโอ...';
	@override String get fetchingVideoSources => 'กำลังดึงแหล่งที่มาของวิดีโอ...';
	@override String get loadingVideo => 'กำลังโหลดวิดีโอ...';
	@override String get applyingSolution => 'กำลังนำการตั้งค่าความละเอียดนี้ไปใช้...';
	@override String get addingListeners => 'กำลังเพิ่มตัวรับฟังเหตุการณ์...';
	@override String get successFecthVideoDurationInfo => 'ดึงข้อมูลความยาววิดีโอสำเร็จ เริ่มโหลดวิดีโอ...';
	@override String get successFecthVideoHeightInfo => 'โหลดเสร็จสมบูรณ์';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastTh extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'แคสต์';
	@override String unableToStartCastingSearch({required Object error}) => 'เริ่มค้นหาอุปกรณ์แคสต์ล้มเหลว: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'เริ่มแคสต์ไปยัง ${deviceName}';
	@override String castFailed({required Object error}) => 'แคสต์ล้มเหลว: ${error}\nโปรดลองค้นหาอุปกรณ์ใหม่อีกครั้งหรือเปลี่ยนเครือข่าย';
	@override String get castStopped => 'หยุดแคสต์แล้ว';
	@override late final _TranslationsVideoDetailCastDeviceTypesTh deviceTypes = _TranslationsVideoDetailCastDeviceTypesTh._(_root);
	@override String get currentPlatformNotSupported => 'แพลตฟอร์มปัจจุบันไม่รองรับการแคสต์';
	@override String get unableToGetVideoUrl => 'ไม่สามารถรับที่อยู่วิดีโอได้ โปรดลองอีกครั้งในภายหลัง';
	@override String get stopCasting => 'หยุดแคสต์';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetTh dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetTh._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsTh extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'ใครแอบมากดถูกใจ';
	@override String get dialogDescription => 'สงสัยไหมว่าพวกเขาคือใคร? ลองเปิดดู "อัลบั้มการกดถูกใจ" นี้สิ~';
	@override String get closeTooltip => 'ปิด';
	@override String get retry => 'ลองใหม่';
	@override String get noLikesYet => 'ยังไม่มีใครปรากฏที่นี่ มาเป็นคนแรกกันเถอะ!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'หน้า ${page} / ${totalPages} · รวม ${totalCount} คน';
	@override String get prevPage => 'หน้าก่อนหน้า';
	@override String get nextPage => 'หน้าถัดไป';
}

// Path: forum.sitewide
class _TranslationsForumSitewideTh extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get badge => 'ทั้งเว็บไซต์';
	@override String get title => 'ประกาศทั่วทั้งเว็บไซต์';
	@override String get readMore => 'อ่านเพิ่มเติม';
}

// Path: forum.errors
class _TranslationsForumErrorsTh extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'โปรดเลือกหมวดหมู่';
	@override String get threadLocked => 'กระทู้นี้ถูกล็อก ไม่สามารถตอบกลับได้';
}

// Path: forum.groups
class _TranslationsForumGroupsTh extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get administration => 'ฝ่ายบริหาร';
	@override String get global => 'ทั่วโลก';
	@override String get chinese => 'ภาษาจีน';
	@override String get japanese => 'ภาษาญี่ปุ่น';
	@override String get korean => 'ภาษาเกาหลี';
	@override String get other => 'อื่นๆ';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesTh extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'ประกาศ';
	@override String get feedback => 'ข้อเสนอแนะ';
	@override String get support => 'ความช่วยเหลือ';
	@override String get general => 'ทั่วไป';
	@override String get guides => 'คู่มือ';
	@override String get questions => 'คำถาม';
	@override String get requests => 'คำขอ';
	@override String get sharing => 'การแบ่งปัน';
	@override String get general_zh => 'ทั่วไป';
	@override String get questions_zh => 'คำถาม';
	@override String get requests_zh => 'คำขอ';
	@override String get support_zh => 'ความช่วยเหลือ';
	@override String get general_ja => 'ทั่วไป';
	@override String get questions_ja => 'คำถาม';
	@override String get requests_ja => 'คำขอ';
	@override String get support_ja => 'ความช่วยเหลือ';
	@override String get korean => 'ภาษาเกาหลี';
	@override String get other => 'อื่นๆ';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsTh extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'ประกาศและแจ้งเตือนสำคัญอย่างเป็นทางการ';
	@override String get feedback => 'ข้อเสนอแนะเกี่ยวกับฟีเจอร์และบริการของเว็บไซต์';
	@override String get support => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์';
	@override String get general => 'พูดคุยในทุกหัวข้อ';
	@override String get guides => 'แบ่งปันประสบการณ์และบทเรียนของคุณ';
	@override String get questions => 'สอบถามข้อสงสัยของคุณ';
	@override String get requests => 'โพสต์คำขอของคุณ';
	@override String get sharing => 'แบ่งปันเนื้อหาที่น่าสนใจ';
	@override String get general_zh => 'พูดคุยในทุกหัวข้อ';
	@override String get questions_zh => 'สอบถามข้อสงสัยของคุณ';
	@override String get requests_zh => 'โพสต์คำขอของคุณ';
	@override String get support_zh => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์';
	@override String get general_ja => 'พูดคุยในทุกหัวข้อ';
	@override String get questions_ja => 'สอบถามข้อสงสัยของคุณ';
	@override String get requests_ja => 'โพสต์คำขอของคุณ';
	@override String get support_ja => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์';
	@override String get korean => 'การพูดคุยที่เกี่ยวข้องกับภาษาเกาหลี';
	@override String get other => 'เนื้อหาอื่นๆ ที่ไม่ได้จัดหมวดหมู่';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsTh extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'ไม่รองรับประเภทการแจ้งเตือนนี้';
	@override String get unknownUser => 'ผู้ใช้ที่ไม่รู้จัก';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'ไม่รองรับประเภทการแจ้งเตือน: ${type}';
	@override String get unknownNotificationType => 'ประเภทการแจ้งเตือนที่ไม่รู้จัก';
}

// Path: conversation.errors
class _TranslationsConversationErrorsTh extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'โปรดเลือกผู้ใช้';
	@override String get pleaseEnterATitle => 'โปรดป้อนชื่อเรื่อง';
	@override String get clickToSelectAUser => 'คลิกเพื่อเลือกผู้ใช้';
	@override String get loadFailedClickToRetry => 'โหลดล้มเหลว คลิกเพื่อลองใหม่';
	@override String get loadFailed => 'โหลดล้มเหลว';
	@override String get clickToRetry => 'คลิกเพื่อลองใหม่';
	@override String get noMoreConversations => 'ไม่มีบทสนทนาเพิ่มเติม';
}

// Path: splash.errors
class _TranslationsSplashErrorsTh extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'การเริ่มต้นล้มเหลว โปรดรีสตาร์ตแอป';
}

// Path: download.errors
class _TranslationsDownloadErrorsTh extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'ไม่พบข้อมูลแกลเลอรี';
	@override String get downloadFailed => 'การดาวน์โหลดล้มเหลว';
	@override String get videoInfoNotFound => 'ไม่พบข้อมูลวิดีโอ';
	@override String get downloadTaskAlreadyExists => 'งานดาวน์โหลดมีอยู่แล้ว';
	@override String get downloadTaskSavePathConflict => 'เส้นทางบันทึกนี้ถูกใช้งานโดยงานอื่นแล้ว';
	@override String get videoAlreadyDownloaded => 'วิดีโอนี้ถูกดาวน์โหลดแล้ว';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'เพิ่มงานดาวน์โหลดล้มเหลว: ${errorInfo}';
	@override String get userPausedDownload => 'ผู้ใช้หยุดการดาวน์โหลดชั่วคราว';
	@override String get unknown => 'ไม่ทราบสาเหตุ';
	@override String fileSystemError({required Object errorInfo}) => 'ข้อผิดพลาดระบบไฟล์: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'ข้อผิดพลาดที่ไม่รู้จัก: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'เขียนไฟล์ไม่สำเร็จ: ${errorInfo}';
	@override String get connectionTimeout => 'หมดเวลาการเชื่อมต่อ';
	@override String get sendTimeout => 'หมดเวลาการส่งข้อมูล';
	@override String get receiveTimeout => 'หมดเวลาการรับข้อมูล';
	@override String serverError({required Object errorInfo}) => 'ข้อผิดพลาดเซิร์ฟเวอร์: ${errorInfo}';
	@override String get unknownNetworkError => 'ข้อผิดพลาดเครือข่ายที่ไม่รู้จัก';
	@override String get sslHandshakeFailed => 'SSL handshake ล้มเหลว โปรดตรวจสอบเครือข่ายของคุณ';
	@override String get connectionFailed => 'การเชื่อมต่อล้มเหลว โปรดตรวจสอบเครือข่ายของคุณ';
	@override String get serviceIsClosing => 'บริการดาวน์โหลดกำลังปิดตัวลง';
	@override String get partialDownloadFailed => 'ดาวน์โหลดเนื้อหาบางส่วนล้มเหลว';
	@override String get noDownloadTask => 'ไม่มีงานดาวน์โหลด';
	@override String get taskNotFoundOrDataError => 'ไม่พบงานหรือข้อมูลผิดพลาด';
	@override String get fileNotFound => 'ไม่พบไฟล์';
	@override String get openFolderFailed => 'เปิดโฟลเดอร์ไม่สำเร็จ';
	@override String get copyDownloadUrlFailed => 'คัดลอก URL ดาวน์โหลดไม่สำเร็จ';
	@override String openFolderFailedWithMessage({required Object message}) => 'เปิดโฟลเดอร์ไม่สำเร็จ: ${message}';
	@override String get directoryNotFound => 'ไม่พบโฟลเดอร์';
	@override String get copyFailed => 'คัดลอกไม่สำเร็จ';
	@override String get openFileFailed => 'เปิดไฟล์ไม่สำเร็จ';
	@override String openFileFailedWithMessage({required Object message}) => 'เปิดไฟล์ไม่สำเร็จ: ${message}';
	@override String get playLocallyFailed => 'เล่นในเครื่องไม่สำเร็จ';
	@override String playLocallyFailedWithMessage({required Object message}) => 'เล่นในเครื่องไม่สำเร็จ: ${message}';
	@override String get noDownloadSource => 'ไม่มีแหล่งดาวน์โหลด';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'ยังไม่มีแหล่งดาวน์โหลด โปรดรอให้โหลดข้อมูลเสร็จสิ้นแล้วลองใหม่อีกครั้ง';
	@override String get noActiveDownloadTask => 'ไม่มีงานที่กำลังดาวน์โหลด';
	@override String get noFailedDownloadTask => 'ไม่มีงานที่ดาวน์โหลดล้มเหลว';
	@override String get noCompletedDownloadTask => 'ไม่มีงานที่ดาวน์โหลดเสร็จสมบูรณ์';
	@override String get taskAlreadyCompletedDoNotAdd => 'งานเสร็จสมบูรณ์แล้ว อย่าเพิ่มซ้ำ';
	@override String get linkExpiredTryAgain => 'ลิงก์หมดอายุ กำลังขอรับลิงก์ดาวน์โหลดใหม่';
	@override String get linkExpiredTryAgainSuccess => 'ลิงก์หมดอายุ ขอรับลิงก์ดาวน์โหลดใหม่สำเร็จ';
	@override String get linkExpiredTryAgainFailed => 'ลิงก์หมดอายุ ขอรับลิงก์ดาวน์โหลดใหม่ล้มเหลว';
	@override String get taskDeleted => 'ลบงานแล้ว';
	@override String unsupportedImageFormat({required Object format}) => 'รูปแบบรูปภาพที่ไม่รองรับ: ${format}';
	@override String get deleteFileError => 'ลบไฟล์ไม่สำเร็จ อาจเป็นเพราะไฟล์กำลังถูกใช้งานโดยกระบวนการอื่น';
	@override String get deleteTaskError => 'ลบงานไม่สำเร็จ';
	@override String get canNotRefreshVideoTask => 'ไม่สามารถรีเฟรชงานวิดีโอได้';
	@override String get videoRemovedCanNotRefresh => 'วิดีโอนี้ถูกลบหรือไม่มีอยู่อีกต่อไป จึงไม่สามารถรีเฟรชลิงก์ดาวน์โหลดได้';
	@override String get videoInaccessibleCanNotRefresh => 'ไม่สามารถเข้าถึงวิดีโอนี้ได้ อาจเป็นวิดีโอส่วนตัวหรือคุณอาจต้องลงชื่อเข้าใช้อีกครั้ง';
	@override String get videoQualityGone => 'ความละเอียดนี้ไม่มีให้บริการแล้ว โปรดเพิ่มการดาวน์โหลดใหม่อีกครั้ง';
	@override String get refreshLinkNetworkFailed => 'ข้อผิดพลาดเครือข่าย ไม่สามารถรีเฟรชลิงก์ดาวน์โหลดได้ในขณะนี้ โปรดลองใหม่อีกครั้งในภายหลัง';
	@override String get taskAlreadyProcessing => 'งานกำลังดำเนินการอยู่แล้ว';
	@override String get taskNotFound => 'ไม่พบงาน';
	@override String get failedToLoadTasks => 'โหลดงานไม่สำเร็จ';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'ดาวน์โหลดบางส่วนล้มเหลว: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'รูปแบบรูปภาพที่ไม่รองรับ: ${extension} คุณสามารถลองดาวน์โหลดลงในอุปกรณ์ของคุณเพื่อดูได้';
	@override String get imageLoadFailed => 'โหลดรูปภาพไม่สำเร็จ';
	@override String get pleaseTryOtherViewer => 'โปรดลองใช้โปรแกรมดูภาพอื่นเพื่อเปิด';
}

// Path: download.timeline
class _TranslationsDownloadTimelineTh extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get today => 'วันนี้';
	@override String get yesterday => 'เมื่อวาน';
	@override String get thisWeek => 'สัปดาห์นี้';
	@override String get thisMonth => 'เดือนนี้';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesTh extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get network => 'ปัญหาเครือข่าย การลองใหม่อาจช่วยได้';
	@override String get serverRejected => 'เซิร์ฟเวอร์ปฏิเสธ คุณอาจต้องลงชื่อเข้าใช้อีกครั้ง';
	@override String get notFound => 'ทรัพยากรหมดอายุหรือถูกลบแล้ว';
	@override String get diskFull => 'พื้นที่จัดเก็บข้อมูลไม่เพียงพอ';
	@override String get fileInUse => 'ไฟล์กำลังถูกใช้งานโดยโปรแกรมอื่น';
	@override String get permission => 'ไม่มีสิทธิ์ในการเขียน';
	@override String get cancelled => 'ยกเลิกแล้ว';
	@override String get unknown => 'ข้อผิดพลาดที่ไม่รู้จัก';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedTh extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => 'มี ${num} งานที่ยังไม่เสร็จจากเซสชันก่อนหน้าถูกหยุดชั่วคราวไว้';
	@override String get resume => 'ดำเนินการต่อทั้งหมด';
	@override String get dismiss => 'ปัดทิ้ง';
}

// Path: download.actions
class _TranslationsDownloadActionsTh extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeTh extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateTh extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'ลบตามวันที่';
	@override String get dialogTitle => 'ลบตามวันที่';
	@override String get description => 'ลบงานดาวน์โหลดเป็นชุดตามวันที่สร้าง งานที่ไฟล์กำลังถูกใช้งานจะถูกข้ามไป ส่วนงานที่ไฟล์ไม่มีอยู่อีกต่อไปจะถูกล้างออก';
	@override String get modeRange => 'ช่วงวันที่';
	@override String get modeDays => 'เก่ากว่า';
	@override String get startDate => 'วันที่เริ่มต้น';
	@override String get endDate => 'วันที่สิ้นสุด';
	@override String get notSet => 'ไม่ได้ตั้งค่า';
	@override String get daysUnit => 'วัน';
	@override String olderThanDaysHint({required Object days}) => 'ลบงานที่สร้างมากกว่า ${days} วันที่แล้ว';
	@override String get noMatch => 'ไม่มีงานที่ตรงกับเงื่อนไขที่เลือก';
	@override String get invalidRange => 'วันที่เริ่มต้นต้องตรงกับหรือก่อนหน้าวันที่สิ้นสุด';
	@override String get confirmTitle => 'ยืนยันการลบ';
	@override String confirmContent({required Object count}) => 'ลบ ${count} งานดาวน์โหลดและไฟล์ของงานเหล่านั้นหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้';
	@override String deleting({required Object done, required Object total}) => 'กำลังลบ ${done}/${total}…';
	@override String resultSuccess({required Object count}) => 'ลบ ${count} งานแล้ว';
	@override String resultPartial({required Object deleted, required Object skipped}) => 'ลบ ${deleted} งานแล้ว; ข้าม ${skipped} งาน (กำลังถูกใช้งาน)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationTh extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryTh extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'จัดการหมวดหมู่';
	@override String get label => 'หมวดหมู่';
	@override String get uncategorized => 'ไม่ได้จัดหมวดหมู่';
	@override String get manage => 'จัดการ';
	@override String get createShortcut => 'สร้างใหม่';
	@override String get newCategoryHint => 'ชื่อหมวดหมู่ใหม่';
	@override String get createSuccess => 'สร้างหมวดหมู่แล้ว';
	@override String get createFailed => 'สร้างหมวดหมู่ไม่สำเร็จ';
	@override String get nameEmpty => 'ชื่อหมวดหมู่ต้องไม่ว่างเปล่า';
	@override String get emptyHint => 'ยังไม่มีหมวดหมู่ สร้างหมวดหมู่เพื่อจัดระเบียบการดาวน์โหลดของคุณ';
	@override String get moveTo => 'ย้ายไปยังหมวดหมู่';
	@override String moveToWithCount({required Object count}) => 'ย้าย ${count} รายการไปยัง…';
	@override String moveSuccess({required Object title}) => 'ย้ายไปยัง ${title} แล้ว';
	@override String get moveToUncategorizedSuccess => 'ย้ายไปยังไม่ได้จัดหมวดหมู่แล้ว';
	@override String get moveFailed => 'ย้ายไม่สำเร็จ';
	@override String get renameTitle => 'เปลี่ยนชื่อหมวดหมู่';
	@override String get renameHint => 'ป้อนชื่อหมวดหมู่';
	@override String get renameSuccess => 'เปลี่ยนชื่อหมวดหมู่แล้ว';
	@override String get renameFailed => 'เปลี่ยนชื่อหมวดหมู่ไม่สำเร็จ';
	@override String get deleteTitle => 'ลบหมวดหมู่';
	@override String deleteConfirm({required Object title, required Object count}) => 'ลบหมวดหมู่ "${title}" หรือไม่? รายการ ${count} รายการในหมวดหมู่นี้จะถูกย้ายไปที่ "ไม่ได้จัดหมวดหมู่" ไฟล์จะไม่ถูกลบ';
	@override String get deleteSuccess => 'ลบหมวดหมู่แล้ว';
	@override String get deleteFailed => 'ลบหมวดหมู่ไม่สำเร็จ';
}

// Path: download.location
class _TranslationsDownloadLocationTh extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadTh extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การดาวน์โหลดเป็นชุด';
	@override String get downloadTaskAlreadyRunning => 'มีงานกำลังทำงานอยู่แล้ว โปรดรอสักครู่';
	@override String get userCancelled => 'ผู้ใช้ยกเลิก';
	@override String get failedToGetVideoInfo => 'รับข้อมูลวิดีโอไม่สำเร็จ';
	@override String get failedToGetVideoSource => 'รับแหล่งที่มาของวิดีโอไม่สำเร็จ';
	@override String get failedToGetGalleryInfo => 'รับข้อมูลแกลเลอรีไม่สำเร็จ';
	@override String get galleryNoImages => 'แกลเลอรีไม่มีรูปภาพ';
	@override String get failedToGetSavePath => 'รับเส้นทางบันทึกไม่สำเร็จ';
	@override String batchDownloadFailedWithException({required Object exception}) => 'การดาวน์โหลดเป็นชุดล้มเหลว: ${exception}';
	@override String get selectQuality => 'เลือกความละเอียด';
	@override String get downloading => 'กำลังดาวน์โหลด';
	@override String get downloadResult => 'ผลลัพธ์การดาวน์โหลด';
	@override String selectedVideosCount({required Object count}) => 'เลือกแล้ว ${count} วิดีโอ';
	@override String selectedGalleriesCount({required Object count}) => 'เลือกแล้ว ${count} แกลเลอรี';
	@override String get qualityNote => 'หากไม่มีความละเอียดที่เลือกไว้ ระบบจะใช้ความละเอียดที่ดีที่สุดที่มีอยู่แทน';
	@override String progress({required Object current, required Object total}) => 'กำลังประมวลผล ${current}/${total}';
	@override String get queued => 'อยู่ในคิว';
	@override String get success => 'สำเร็จ';
	@override String get skipped => 'ข้ามแล้ว';
	@override String get failed => 'ล้มเหลว';
	@override String get failureDetails => 'รายละเอียดความล้มเหลว';
	@override String get reasonPrivateVideo => 'วิดีโอส่วนตัว';
	@override String get reasonAlreadyExists => 'มีอยู่แล้ว';
	@override String get reasonNoSource => 'ไม่มีแหล่งดาวน์โหลด';
	@override String get reasonNoSavePath => 'ไม่สามารถรับเส้นทางบันทึกได้';
	@override String get reasonOther => 'ข้อผิดพลาดอื่นๆ';
	@override String get startDownload => 'เริ่มการดาวน์โหลด';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsTh extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'เพิ่มไม่สำเร็จ';
	@override String get addSuccess => 'เพิ่มสำเร็จ';
	@override String get deleteFolderFailed => 'ลบโฟลเดอร์ไม่สำเร็จ';
	@override String get deleteFolderSuccess => 'ลบโฟลเดอร์สำเร็จ';
	@override String get folderNameCannotBeEmpty => 'ชื่อโฟลเดอร์ต้องไม่ว่างเปล่า';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesTh extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI การให้เหตุผล (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude การให้เหตุผล (extended thinking)';
	@override String get gemini => 'Google Gemini (เนทีฟ)';
	@override String get geminiReasoning => 'Google Gemini การให้เหตุผล (thinking)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek การให้เหตุผล (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeTh extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'การแจ้งเตือนการเล่น: ${message}';
	@override String get networkUnstable => 'โปรดตรวจสอบเครือข่าย การเล่นอาจกระตุก';
	@override String get audioTrackUnavailable => 'ไม่มีเสียง วิดีโอยังคงเล่นต่อไป';
	@override String get hardwareDecodeFellBack => 'สลับไปใช้การถอดรหัสด้วยซอฟต์แวร์ อาจใช้พลังงานแบตเตอรี่มากขึ้น';
	@override String get videoDecodeProblem => 'ลองเปลี่ยนความละเอียด ภาพอาจมีอาการกระตุกหรือแตก';
	@override String get repeatedPlaybackProblems => 'ส่งออกบันทึกเพื่อรายงานปัญหาการเล่นซ้ำๆ';
	@override String get issuesSheetTitle => 'ปัญหาการเล่น';
	@override String issueOccurrences({required Object count}) => 'เกิดขึ้น ${count} ครั้ง';
	@override String issueAtPosition({required Object position}) => 'ที่ตำแหน่ง ${position}';
	@override String get noIssuesRecorded => 'ไม่มีบันทึกปัญหา';
	@override String get exportLogsAction => 'ส่งออกบันทึก';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertTh extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'การล้างข้อมูลบันทึก (Flush) ล้มเหลว';
	@override String get sinkDegradedTitle => 'ประสิทธิภาพการเขียนบันทึกลดลง';
	@override String get sinkDegradedDetail => 'File sink อยู่ในสถานะประสิทธิภาพลดลง';
	@override String get queueBacklogTitle => 'คิวการเขียนค้างสะสม';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (threshold=${threshold}, อาจเพิ่มการใช้หน่วยความจำ)';
	@override String get highFlushLatencyTitle => 'เวลาแฝงในการล้างข้อมูลบันทึกสูง';
	@override String get droppedTooManyTitle => 'บันทึกถูกทิ้งมากเกินไป';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (เกณฑ์=${threshold})';
	@override String get rateLimitedTitle => 'ถูกจำกัดอัตราการเขียน';
	@override String get exportFailedTitle => 'ส่งออกบันทึกล้มเหลว';
	@override String get fileNearLimitTitle => 'ไฟล์บันทึกใกล้ถึงขีดจำกัดขนาด';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (แรงกดดันการหมุนเวียน IO สูงขึ้น)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastTh extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'บริการบันทึกยังไม่ได้เริ่มต้น';
	@override String get exportSuccess => 'ส่งออกบันทึกแล้ว โปรดตรวจสอบข้อมูลความเป็นส่วนตัวก่อนส่งทางอีเมล';
	@override String exportFailed({required Object error}) => 'ส่งออกล้มเหลว: ${error}';
	@override String get supportEmailCopied => 'คัดลอกอีเมลสนับสนุนแล้ว วางลงในโปรแกรมรับส่งอีเมลของคุณและแนบบันทึก';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesTh extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'ความเกี่ยวข้อง';
	@override String get latest => 'ล่าสุด';
	@override String get views => 'ยอดชม';
	@override String get likes => 'ถูกใจ';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeTh extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ยินดีต้อนรับ';
	@override String get subtitle => 'มาเริ่มต้นการตั้งค่าเฉพาะบุคคลของคุณกัน';
	@override String get description => 'เพียงไม่กี่ขั้นตอนเพื่อปรับแต่งประสบการณ์ที่ดีที่สุดให้คุณ';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicTh extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าพื้นฐาน';
	@override String get subtitle => 'ปรับแต่งประสบการณ์ของคุณ';
	@override String get description => 'เลือกการตั้งค่าที่เหมาะกับคุณ';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkTh extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าเครือข่าย';
	@override String get subtitle => 'ตั้งค่าตัวเลือกเครือข่าย';
	@override String get description => 'ปรับตามสภาพเครือข่ายของคุณ';
	@override String get tip => 'ต้องรีสตาร์ทหลังตั้งค่าสำเร็จจึงจะมีผล';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeTh extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าธีม';
	@override String get subtitle => 'เลือกธีมที่คุณชื่นชอบ';
	@override String get description => 'ปรับแต่งประสบการณ์ทางสายตาของคุณ';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerTh extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การตั้งค่าโปรแกรมเล่น';
	@override String get subtitle => 'ตั้งค่าการควบคุมการเล่น';
	@override String get description => 'ตั้งค่าการเล่นที่ใช้บ่อยได้อย่างรวดเร็ว';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialTh extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'การเล่นแบบเชิงพื้นที่';
	@override String get subtitle => 'การรับชมและเรียกดูบนชุดหูฟัง';
	@override String get description => 'บนชุดหูฟัง วิดีโอและแกลเลอรีจะปรากฏในพื้นที่รอบตัวคุณแทนที่จะอยู่ในแผงลอยนี้';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionTh extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'ตั้งค่าเสร็จสมบูรณ์';
	@override String get subtitle => 'คุณพร้อมที่จะเริ่มต้นการเดินทางแล้ว';
	@override String get description => 'โปรดอ่านและยอมรับข้อตกลงที่เกี่ยวข้อง';
	@override String get agreementTitle => 'ข้อตกลงผู้ใช้และกฎของชุมชน';
	@override String get agreementDesc => 'ก่อนใช้แอปนี้ โปรดอ่านและยอมรับข้อตกลงผู้ใช้และกฎของชุมชนอย่างละเอียด ข้อกำหนดเหล่านี้ช่วยรักษาสภาพแวดล้อมที่ดี';
	@override String get checkboxTitle => 'ข้าพเจ้าได้อ่านและยอมรับข้อตกลงผู้ใช้และกฎของชุมชนแล้ว';
	@override String get checkboxSubtitle => 'หากไม่ยอมรับจะไม่สามารถใช้แอปได้';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonTh extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'การตั้งค่าเหล่านี้เปลี่ยนได้ทุกเมื่อในการตั้งค่า';
	@override String get previousStep => 'ขั้นตอนก่อนหน้า';
	@override String get nextStep => 'ขั้นตอนถัดไป';
	@override String get finishSetup => 'เสร็จสิ้นการตั้งค่า';
	@override String get agreeAgreementSnackbar => 'โปรดยอมรับข้อตกลงผู้ใช้และกฎของชุมชนก่อน';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsTh extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'คุณภาพสูง';
	@override String get fast => 'เร็ว';
	@override String get lite => 'เบา';
	@override String get moreLite => 'เบายิ่งขึ้น';
	@override String get custom => 'กำหนดเอง';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsTh extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'เหมาะกับอนิเมชัน 1080p ส่วนใหญ่ โดยเฉพาะที่ต้องรับมือกับความเบลอ การรีแซมเพิล และอาร์ติแฟกต์จากการบีบอัด ให้คุณภาพที่รับรู้ได้สูงสุด';
	@override String get mode_b_hq => 'เหมาะกับอนิเมชันที่มีความเบลอหรือเงาสะท้อนเล็กน้อยจากการปรับขนาด ช่วยลดเงาสะท้อนและรอยหยักได้อย่างมีประสิทธิภาพ';
	@override String get mode_c_hq => 'เหมาะกับแหล่งคุณภาพสูง (เช่น อนิเมชันหรือภาพยนตร์ 1080p แท้) ลดสัญญาณรบกวนและให้ค่า PSNR สูงสุด';
	@override String get mode_a_a_hq => 'เวอร์ชันเสริมของ Mode A ให้คุณภาพที่รับรู้ได้สูงสุดและสามารถสร้างเส้นที่เสื่อมสภาพเกือบทั้งหมดขึ้นมาใหม่ อาจเกิดภาพคมเกินไปหรือเงาสะท้อน';
	@override String get mode_b_b_hq => 'เวอร์ชันเสริมของ Mode B ให้คุณภาพที่รับรู้ได้สูงขึ้น ปรับแต่งเส้นให้ดียิ่งขึ้นและลดอาร์ติแฟกต์';
	@override String get mode_c_a_hq => 'เวอร์ชันเสริมคุณภาพที่รับรู้ได้ของ Mode C รักษาค่า PSNR ให้สูงพร้อมพยายามสร้างรายละเอียดเส้นบางส่วนขึ้นมาใหม่';
	@override String get mode_a_fast => 'เวอร์ชันเร็วของ Mode A สมดุลระหว่างคุณภาพและสมรรถนะ เหมาะกับอนิเมชัน 1080p ส่วนใหญ่';
	@override String get mode_b_fast => 'เวอร์ชันเร็วของ Mode B สำหรับจัดการอาร์ติแฟกต์และเงาสะท้อนเล็กน้อยด้วยภาระที่ต่ำลง';
	@override String get mode_c_fast => 'เวอร์ชันเร็วของ Mode C สำหรับการลดสัญญาณรบกวนและขยายภาพของแหล่งคุณภาพสูงอย่างรวดเร็ว';
	@override String get mode_a_a_fast => 'เวอร์ชันเร็วของ Mode A+A เน้นคุณภาพที่รับรู้ได้สูงขึ้นบนอุปกรณ์ที่มีข้อจำกัดด้านสมรรถนะ';
	@override String get mode_b_b_fast => 'เวอร์ชันเร็วของ Mode B+B ให้การซ่อมแซมเส้นและการจัดการอาร์ติแฟกต์ที่ดีขึ้นสำหรับอุปกรณ์ที่มีข้อจำกัดด้านสมรรถนะ';
	@override String get mode_c_a_fast => 'เวอร์ชันเร็วของ Mode C+A ประมวลผลแหล่งคุณภาพสูงได้อย่างรวดเร็วพร้อมให้การซ่อมแซมเส้นแบบเบา';
	@override String get upscale_only_s => 'การขยายภาพเป็น 2 เท่าความเร็วสูงสุดโดยใช้เฉพาะโมเดล CNN ที่เร็วที่สุด ไม่มีการซ่อมแซมและลดสัญญาณรบกวน ภาระต่ำสุด';
	@override String get upscale_deblur_fast => 'การขยายภาพและลดความเบลอแบบเร็วด้วยอัลกอริทึมดั้งเดิมที่ไม่ใช้ CNN ดีกว่าอัลกอริทึมเริ่มต้นของโปรแกรมเล่นด้วยภาระที่ต่ำมาก';
	@override String get restore_s_only => 'ซ่อมแซมเท่านั้นโดยใช้โมเดล CNN ที่เร็วที่สุด ไม่ขยายภาพ เหมาะกับการเล่นที่ความละเอียดแท้ที่ต้องการเพิ่มคุณภาพ';
	@override String get denoise_bilateral_fast => 'การลดสัญญาณรบกวนแบบเร็วด้วยตัวกรอง bilateral แบบดั้งเดิม เร็วมาก เหมาะกับการจัดการสัญญาณรบกวนเล็กน้อย';
	@override String get upscale_non_cnn => 'การขยายภาพแบบเร็วด้วยอัลกอริทึมดั้งเดิม ภาระต่ำมาก ดีกว่าค่าเริ่มต้นของโปรแกรมเล่น';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + การทำให้เส้นเข้มขึ้น เพิ่มเอฟเฟกต์ทำให้เส้นเข้มขึ้นบน Mode A แบบเร็ว เพื่อให้เส้นเด่นชัดและมีสไตล์ยิ่งขึ้น';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + การทำให้เส้นบางลง เพิ่มเอฟเฟกต์ทำให้เส้นบางลงบน Mode A คุณภาพสูง เพื่อให้ดูประณีตยิ่งขึ้น';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesTh extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'ขยายภาพด้วย CNN (เร็วมาก)';
	@override String get upscale_deblur_fast => 'ขยายภาพและลดความเบลอ (เร็ว)';
	@override String get restore_s_only => 'การซ่อมแซม (เร็วมาก)';
	@override String get denoise_bilateral_fast => 'ลดสัญญาณรบกวนแบบ Bilateral (เร็วมาก)';
	@override String get upscale_non_cnn => 'ขยายภาพแบบไม่ใช้ CNN (เร็วมาก)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + ทำให้เส้นเข้มขึ้น';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + ทำให้เส้นบางลง';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseTh extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'การเข้าถึงด่วน';
	@override String get sourcesSection => 'โฟลเดอร์';
	@override String get pin => 'เพิ่มในการเข้าถึงด่วน';
	@override String get unpin => 'ลบออกจากการเข้าถึงด่วน';
	@override String get pinned => 'เพิ่มในการเข้าถึงด่วนแล้ว';
	@override String get unpinned => 'ลบออกจากการเข้าถึงด่วนแล้ว';
	@override String folderCount({required Object count}) => '${count} โฟลเดอร์';
	@override String videoCount({required Object count}) => '${count} วิดีโอ';
	@override String imageCount({required Object count}) => '${count} รูป';
	@override String get emptyFolder => 'โฟลเดอร์นี้ว่างเปล่า';
	@override String get videosSection => 'วิดีโอ';
	@override String get imagesSection => 'รูปภาพ';
	@override String get galleriesSection => 'แกลเลอรี';
	@override String get filterAll => 'ทั้งหมด';
	@override String get searchInFolder => 'ค้นหาในโฟลเดอร์นี้';
	@override String get searchHint => 'ค้นหาตามชื่อ';
	@override String get clearSearch => 'ล้างการค้นหา';
	@override String searchNoResult({required Object query}) => 'ไม่พบรายการที่ตรงกับ "${query}"';
	@override String viewAllFolders({required Object count}) => 'ดูโฟลเดอร์ทั้งหมด ${count} รายการ';
	@override String viewAllVideos({required Object count}) => 'ดูวิดีโอทั้งหมด ${count} รายการ';
	@override String viewAllImages({required Object count}) => 'ดูรูปภาพทั้งหมด ${count} รายการ';
	@override String viewAllGalleries({required Object count}) => 'ดูแกลเลอรีทั้งหมด ${count} รายการ';
	@override String get location => 'ตำแหน่ง';
	@override String get sourceMissing => 'แหล่งนี้หายไปแล้ว';
	@override String get notScannedYet => 'โฟลเดอร์นี้ยังไม่ได้สแกน';
	@override String get scanning => 'กำลังอ่านโฟลเดอร์นี้…';
	@override String get deleteFileTitle => 'ลบไฟล์นี้หรือไม่';
	@override String deleteFileBody({required Object name}) => '“${name}” จะถูกลบออกจากอุปกรณ์นี้อย่างถาวร การกระทำนี้ย้อนกลับไม่ได้';
	@override String get hideFolder => 'ซ่อนโฟลเดอร์นี้';
	@override String get unhideFolder => 'เลิกซ่อน';
	@override String get showHiddenFolders => 'แสดงโฟลเดอร์ที่ซ่อนไว้';
	@override String get includeDotFolders => 'สแกนโฟลเดอร์ที่ขึ้นต้นด้วย .';
	@override String get dotFoldersIncluded => 'เริ่มสแกนโฟลเดอร์ที่ขึ้นต้นด้วย . แล้ว';
	@override String get dotFoldersExcluded => 'ไม่สแกนโฟลเดอร์ที่ขึ้นต้นด้วย . อีกต่อไป';
	@override String get showDotFolders => 'แสดงโฟลเดอร์ที่ขึ้นต้นด้วย .';
	@override String dotFoldersSkipped({required Object count}) => 'ที่นี่มีโฟลเดอร์ที่ขึ้นต้นด้วย . อีก ${count} โฟลเดอร์ที่ยังไม่ได้สแกน';
	@override String get scanDotFoldersAction => 'เปิดสำหรับแหล่งนี้';
	@override String get otherAppsPrivateNotice => 'ตั้งแต่ Android 11 ไม่มีแอปใดอ่านไฟล์ของแอปอื่นใน Android/data หรือ Android/obb ได้ และแอปนี้ก็หลีกเลี่ยงไม่ได้ โปรดดาวน์โหลดหรือส่งออกวิดีโอไปยังโฟลเดอร์สาธารณะ เช่น Download ในแอปต้นทาง แล้วเพิ่มโฟลเดอร์นั้นที่นี่ แคชระหว่างดูมักถูกแบ่งเป็นชิ้นและเล่นไม่ได้แม้จะอ่านได้';
	@override String get folderHidden => 'ซ่อนแล้ว การสแกนจะข้ามโฟลเดอร์นี้ด้วย';
	@override String get folderUnhidden => 'เลิกซ่อนแล้ว';
	@override String get hiddenFolderBadge => 'ซ่อนอยู่';
	@override String get deleteFolder => 'ลบโฟลเดอร์';
	@override String get deleteFolderTitle => 'ลบโฟลเดอร์นี้หรือไม่';
	@override String deleteFolderBody({required Object name}) => '"${name}" และทุกอย่างข้างในจะถูกลบออกจากอุปกรณ์นี้อย่างถาวร ไม่สามารถกู้คืนได้';
	@override String get deleteFolderIncludesOthers => 'ไฟล์อื่นที่อยู่ข้างในจะถูกลบไปด้วย';
	@override String get folderDeleted => 'ลบโฟลเดอร์แล้ว';
	@override String get deleteFolderFailed => 'ลบไม่สำเร็จ อาจไม่มีสิทธิ์ หรือมีไฟล์ข้างในกำลังถูกใช้งาน';
	@override String get deleteGalleryTitle => 'ลบแกลเลอรีนี้หรือไม่';
	@override String deleteGalleryBody({required Object name}) => 'ประวัติการดาวน์โหลดและไฟล์ภาพในเครื่องของ “${name}” จะถูกลบ การกระทำนี้ย้อนกลับไม่ได้';
	@override String get galleryResourceMissing => 'ไฟล์ในเครื่องไม่มีอยู่แล้ว ล้างข้อมูลเรียบร้อย';
	@override String get viewDownloadDetail => 'ดูรายละเอียดการดาวน์โหลด';
	@override String get viewOnlineGallery => 'ดูบนเว็บไซต์';
	@override String get pickFolderTitle => 'เลือกโฟลเดอร์';
	@override String get useThisFolder => 'ใช้โฟลเดอร์นี้';
	@override String get noSubfolders => 'ไม่มีโฟลเดอร์ย่อยที่นี่';
	@override String get storageRoot => 'ที่เก็บข้อมูลของอุปกรณ์';
	@override String get homeFolder => 'หน้าหลัก';
	@override String get filesystemRoot => 'รากของระบบไฟล์';
	@override String get folderUnreadable => 'ไม่สามารถอ่านโฟลเดอร์นี้ได้';
	@override String get setCover => 'ตั้งเป็นปก';
	@override String get setAsFolderCover => 'ใช้เป็นปกโฟลเดอร์';
	@override String get folderCoverSet => 'อัปเดตปกโฟลเดอร์แล้ว';
	@override String get setFolderCoverPick => 'ตั้งเป็นปก…';
	@override String get restoreAutoCover => 'คืนค่าปกอัตโนมัติ';
	@override String get autoCoverRestored => 'คืนค่าปกอัตโนมัติแล้ว';
	@override String get rescanFolder => 'สแกนโฟลเดอร์นี้ใหม่';
	@override String get coverPickerTitle => 'เลือกเฟรมภาพ';
	@override String get folderCoverPickerTitle => 'เลือกปก';
	@override String get coverPickerEmpty => 'ยังไม่มีรูปภาพในโฟลเดอร์นี้ ภาพตัวอย่างวิดีโออาจยังสร้างอยู่เบื้องหลัง';
	@override String get coverSaved => 'อัปเดตปกแล้ว';
	@override String get coverSaveFailed => 'ไม่สามารถบันทึกปกได้';
	@override String get coverUnavailable => 'ไม่สามารถอ่านเฟรมจากไฟล์นี้ได้';
	@override String get deleted => 'ลบแล้ว';
	@override String get deleteFailed => 'ลบไม่ได้ — ไฟล์อาจถูกใช้งานอยู่หรือเขียนไม่ได้';
	@override String get openFolder => 'เปิด';
	@override String get favorite => 'เพิ่มในรายการโปรด';
	@override String get unfavorite => 'ลบออกจากรายการโปรด';
	@override String get favorited => 'เพิ่มในรายการโปรดแล้ว';
	@override String get unfavorited => 'ลบออกจากรายการโปรดแล้ว';
	@override String get sortBy => 'เรียงตาม';
	@override String get sortAscending => 'น้อยไปมาก';
	@override String get sortDescending => 'มากไปน้อย';
	@override String get sortFieldName => 'ชื่อ';
	@override String get sortFieldModified => 'วันที่แก้ไข';
	@override String get sortFieldDuration => 'ระยะเวลา';
	@override String get sortFieldSize => 'ขนาด';
	@override String get sortFieldResolution => 'ความละเอียด';
	@override String get sortFieldFileType => 'ชนิดไฟล์';
	@override String get sortFieldFps => 'อัตราเฟรม';
	@override String get sortFieldFavorited => 'วันที่เพิ่มในรายการโปรด';
	@override String get emptyAllVideos => 'ยังไม่พบวิดีโอ เพิ่มโฟลเดอร์ใต้ โฟลเดอร์ เพื่อเริ่มต้น';
	@override String get emptyAllImages => 'ยังไม่พบรูปภาพ เพิ่มโฟลเดอร์ใต้ โฟลเดอร์ เพื่อเริ่มต้น';
	@override String get emptyFavorites => 'ยังไม่มีรายการโปรด เพิ่มได้จากเมนู ⋮ ของวิดีโอ';
	@override String get emptyPinned => 'ยังไม่มีโฟลเดอร์ปักหมุด กดค้างที่โฟลเดอร์ใต้ โฟลเดอร์ แล้วเลือก ปักหมุด';
	@override String get emptyDownloadedVideos => 'ยังไม่มีการดาวน์โหลดวิดีโอที่เสร็จสมบูรณ์';
	@override String get emptyDownloadedGalleries => 'ยังไม่มีการดาวน์โหลดแกลเลอรีที่เสร็จสมบูรณ์';
	@override String get folderInfo => 'ข้อมูลโฟลเดอร์';
	@override String get folderInfoName => 'ชื่อ';
	@override String get folderInfoPath => 'เส้นทาง';
	@override String get folderInfoSource => 'แหล่งที่มา';
	@override String get folderInfoContents => 'เนื้อหา';
	@override String get folderInfoSize => 'ขนาดบนดิสก์';
	@override String get folderInfoScannedAt => 'สแกนล่าสุด';
	@override String get folderInfoNeverScanned => 'ยังไม่ได้สแกน';
	@override String get folderInfoNoPath => 'แหล่งนี้ไม่มีโฟลเดอร์ให้เปิด';
	@override String get copyPath => 'คัดลอกเส้นทาง';
	@override String get pathCopied => 'คัดลอกเส้นทางแล้ว';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsTh extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingTh extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavTh extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorTh extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'เทมเพลตเส้นทาง';
	@override String get subtitle => 'จัดโฟลเดอร์ให้ไฟล์ดาวน์โหลดอัตโนมัติ';
	@override String get tabVideo => 'วิดีโอ';
	@override String get tabGallery => 'แกลเลอรี';
	@override String get tabImage => 'ภาพเดี่ยว';
	@override String get previewLabel => 'ตัวอย่าง · ผลลัพธ์จริงหลังทำความสะอาด';
	@override String get galleryPreviewLabel => 'ตัวอย่าง · เทมเพลตแกลเลอรีคือชื่อโฟลเดอร์ (ภายในใช้ชื่อตามรหัสภาพ)';
	@override String get addFolder => 'เพิ่มระดับโฟลเดอร์';
	@override String get folderCapReached => 'ถึงขีดจำกัดระดับโฟลเดอร์แล้ว';
	@override String get folderSegmentHint => '%authorcache ตัวแปรหรือข้อความคงที่';
	@override String get fileSegmentHint => 'เช่น %title_%quality';
	@override String videoCapNote({required Object max}) => 'นามสกุล (.mp4) จะถูกเพิ่มอัตโนมัติ · พิมพ์ / ในส่วนจะแยกเป็นสองระดับ · สูงสุด ${max} ระดับ';
	@override String imageCapNote({required Object max}) => 'นามสกุลเดิมจะถูกเพิ่มอัตโนมัติ · พิมพ์ / ในส่วนจะแยกเป็นสองระดับ · สูงสุด ${max} ระดับ';
	@override String galleryCapNote({required Object max}) => 'เทมเพลตแกลเลอรีเป็นส่วนโฟลเดอร์ทั้งหมด สูงสุด ${max} ระดับ · ภาพภายในใช้ชื่อตามรหัสภาพ';
	@override String get trayHint => 'แตะเพื่อแทรกที่ตำแหน่งเคอร์เซอร์ · กดค้างเพื่อดูรายละเอียด';
	@override String get emptySegment => 'ส่วนว่าง';
	@override String get emptySegmentSaveBlocked => 'บันทึกไม่ได้: มีส่วนว่าง โปรดลบหรือกรอกเนื้อหา';
	@override String get tooManySegmentsSaveBlocked => 'บันทึกไม่ได้: ส่วนของพาธเกินขีดจำกัด (สูงสุด 4 ส่วน) โปรดรวมหรือลดลง';
	@override String get templateInvalidSaveBlocked => 'บันทึกไม่ได้: เทมเพลตมีอักขระที่ไม่อนุญาต';
	@override String get variableInserted => 'แทรกตัวแปรแล้ว';
	@override String get savedToast => 'บันทึกแล้ว · มีผลเฉพาะการดาวน์โหลดใหม่เท่านั้น';
	@override String get trayCategoryContent => 'เนื้อหา';
	@override String get trayCategoryAuthor => 'ผู้สร้าง';
	@override String get trayCategoryTime => 'เวลา';
	@override String get chipAuthorcache => 'ชื่อผู้สร้าง·คงที่';
	@override String get chipDate => 'วันที่';
	@override String get chipTime => 'เวลา';
	@override String get chipDatetime => 'วันที่และเวลา';
	@override String get chipCount => 'ลำดับ';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestTh extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'คุ้นเคยกับการควบคุมบน Quest';
	@override String get intro => 'ดูว่าการควบคุมแต่ละอย่างทำอะไรได้บ้าง จากนั้นลองใช้งานในพื้นที่เสมือนของคุณ';
	@override String get videoTab => 'วิดีโอเชิงพื้นที่';
	@override String get galleryTab => 'แกลเลอรีเชิงพื้นที่';
	@override String get scopeNote => 'สำหรับหน้าจอและหน้าต่างในพื้นที่ Quest ของคุณ เปิดใหม่ได้ทุกเมื่อจากการตั้งค่าเครื่องเล่น';
	@override String get catalog => 'สำรวจการควบคุม';
	@override String lessonCount({required Object current, required Object total}) => '${current} จาก ${total}';
	@override String get previous => 'ก่อนหน้า';
	@override String get next => 'การควบคุมถัดไป';
	@override String get replay => 'เล่นการสาธิตซ้ำ';
	@override String get pauseDemo => 'หยุดการสาธิตชั่วคราว';
	@override String get resumeDemo => 'เล่นการสาธิตต่อ';
	@override String get looping => 'สาธิตการควบคุม';
	@override String get still => 'ภาพประกอบนิ่ง';
	@override String get done => 'เข้าใจแล้ว ดำเนินการต่อ';
	@override String get leftController => 'มือซ้าย';
	@override String get rightController => 'มือขวา';
	@override String get trigger => 'ไกชี้';
	@override String get grip => 'ปุ่มกริป';
	@override String get bothGrips => 'ปุ่มกริปทั้งสองข้าง';
	@override String get stick => 'ก้านอนาล็อก';
	@override String get handTracking => 'การติดตามมือ';
	@override String get ready => 'พร้อม';
	@override String get press => 'กด';
	@override String get hold => 'กดค้าง';
	@override String get release => 'ปล่อย';
	@override String get result => 'ดูผลลัพธ์';
	@override String get pinch => 'จีบนิ้ว';
	@override String get selectTitle => 'ชี้และเลือก';
	@override String get selectBody => 'เล็งลำแสงไปที่ปุ่ม จากนั้นกดแล้วปล่อยไกชี้ ใช้สำหรับเล่น ตั้งค่า และเลื่อนแถบเลื่อนบนแผงควบคุม';
	@override String get selectHint => 'ไกชี้อยู่ด้านหลังของปุ่ม ปุ่มกริปที่ด้ามจับด้านในใช้สำหรับจับหน้าต่าง';
	@override String get panelTitle => 'แสดงหรือซ่อนแผงควบคุม';
	@override String get panelBody => 'ชี้ออกไปนอกแผงควบคุม จากนั้นแตะไกชี้เพื่อแสดงหรือซ่อน เมื่อใช้การติดตามมือ การจีบนิ้วสั้นๆ นอกแผงควบคุมจะให้ผลเช่นเดียวกัน';
	@override String get panelHint => 'ใช้การแตะสั้นๆ โดยไม่ลาก การกดค้างแล้วขยับคือการลาก ไม่ใช่การสลับแผงควบคุม';
	@override String get playTitle => 'เล่นและหยุดชั่วคราว';
	@override String get playBody => 'ชี้ออกจากแผงควบคุมแล้วกดปุ่ม A ทางขวา หรือปุ่ม X ทางซ้ายเพื่อเล่นหรือหยุดชั่วคราว คุณยังสามารถเลือกปุ่มเล่นบนแผงควบคุมได้ด้วย';
	@override String get playHint => 'สามารถปิดแป้นพิมพ์ลัดเริ่มต้นนี้ได้ในการตั้งค่าเครื่องเล่นเชิงพื้นที่ เมื่อชี้ไปที่แผงควบคุม การป้อนข้อมูลจะส่งไปยังแผงควบคุม';
	@override String get seekTitle => 'เลื่อนตำแหน่งด้วยก้านอนาล็อก';
	@override String get seekBody => 'ดันก้านอนาล็อกไปทางซ้ายหรือขวาเพื่อข้ามทีละ 5 วินาที ดันค้างไว้เพื่อเลื่อนเร็วขึ้นพร้อมดูตัวอย่างเวลา ปล่อยเพื่อไปยังตำแหน่งที่เลือก';
	@override String get seekHint => 'อย่าให้ลำแสงของคอนโทรลเลอร์นั้นชี้ไปที่แผงควบคุม หากก้านอนาล็อกชี้ไปที่แผงควบคุมจะเป็นการเลื่อนแผงแทน';
	@override String get browseTitle => 'เรียกดูด้วยก้านอนาล็อก';
	@override String get browseBody => 'ขยับก้านอนาล็อกข้างใดก็ได้ไปทางซ้ายหรือขวาเพื่อดูรายการก่อนหน้าหรือถัดไป ดันค้างไว้เพื่อเรียกดูต่อเนื่อง คุณยังสามารถเลือกภาพขนาดย่อในแถบฟิล์มได้ด้วย';
	@override String get browseHint => 'วิดีโอในแกลเลอรีก็ถือเป็นรายการเช่นกัน การชี้ไปที่แผงควบคุมจะทำให้ก้านอนาล็อกเลื่อนเนื้อหาในแผงแทน';
	@override String get swipeTitle => 'ลากเพื่อพลิกหน้า';
	@override String get swipeBody => 'เล็งไปที่รูปภาพ กดไกชี้ค้างไว้แล้วลากไปทางซ้าย ปล่อยหลังจากมีสัญญาณเปลี่ยนหน้าเพื่อไปข้างหน้า ลากไปทางขวาเพื่อย้อนกลับ การจีบนิ้วแล้วลากก็ใช้ได้เช่นกัน';
	@override String get swipeHint => 'รูปภาพต้องอยู่ที่ขนาด 1× จึงจะเปลี่ยนหน้าด้วยการลากได้ วิดีโอในแกลเลอรีก็รองรับเช่นกัน หน้าจอจะอยู่นิ่งจนกว่าคุณจะปล่อย';
	@override String get zoomTitle => 'ซูมดูรายละเอียดรูปภาพ';
	@override String get zoomBody => 'เล็งไปที่รายละเอียดในภาพ กดไกชี้ค้างไว้ แล้วดันก้านอนาล็อกขึ้นเพื่อซูมเข้า หรือลงเพื่อซูมออก การซูมจะยึดตำแหน่งที่คุณกดไว้';
	@override String get zoomHint => 'การดำเนินการนี้จะขยายรูปภาพภายในหน้าต่าง หากไม่ได้จับรูปภาพไว้ การดันขึ้น/ลงจะเป็นการปรับระยะการมอง';
	@override String get panTitle => 'เลื่อนและคืนค่ารูปภาพ';
	@override String get panBody => 'เมื่อซูมเข้าแล้ว ให้กดไกชี้ค้างไว้แล้วลากเพื่อดูรอบๆ แตะสองครั้งที่รูปภาพเพื่อซูมเป็น 2.5× หรือคืนค่าเดิม สำหรับมือ ให้จีบนิ้วสองครั้งอย่างรวดเร็ว';
	@override String get panHint => 'การลากจะเป็นการเลื่อนดูภาพที่ซูมอยู่ คืนค่าเป็น 1× ก่อนลากเพื่อเปลี่ยนหน้า';
	@override String get slideshowTitle => 'เริ่มการฉายสไลด์';
	@override String get slideshowBody => 'เมื่อดูรูปภาพ กดปุ่ม A / X เพื่อเริ่มหรือหยุดการฉายสไลด์ชั่วคราว แผงควบคุมมีช่วงเวลา 3, 5, 10 หรือ 20 วินาที และคุณภาพของภาพแบบมาตรฐานหรือต้นฉบับ';
	@override String get slideshowHint => 'ในวิดีโอของแกลเลอรี ปุ่ม A / X จะควบคุมการเล่นของวิดีโอนั้น ต้องเปิดใช้งานปุ่มลัดของคอนโทรลเลอร์ในการตั้งค่าก่อน';
	@override String get moveTitle => 'จับและย้ายหน้าจอ';
	@override String get moveBody => 'กดปุ่มกริปที่ด้ามจับด้านในค้างไว้ ขยับคอนโทรลเลอร์เพื่อจัดตำแหน่งหน้าจอ จากนั้นจึงปล่อย ขณะรับชม คุณสามารถจับหน้าจอได้โดยไม่ต้องเล็งไปที่หน้าจอ';
	@override String get moveHint => 'การเล็งไปที่หน้าต่างแอปหรือแผงควบคุมจะจับหน้าต่างนั้นก่อน ในวิดีโอแบบพาโนรามา การจับจะใช้ปรับทิศทางการมอง';
	@override String get scaleTitle => 'ปรับขนาดด้วยสองมือ';
	@override String get scaleBody => 'กดปุ่มกริปทั้งสองข้างค้างไว้ กางมือออกเพื่อขยายหน้าจอ หรือดึงมือเข้าหากันเพื่อย่อหน้าจอ เมื่อใช้การติดตามมือ ให้จีบนิ้วค้างไว้ทั้งสองมือ';
	@override String get scaleHint => 'สำหรับหน้าจอแบนหรือโค้ง รวมถึงเวทีแกลเลอรี อย่าให้ลำแสงชี้ไปที่แผงควบคุม การทำเช่นนี้จะปรับขนาดของทั้งหน้าจอ';
	@override String get distanceTitle => 'ปรับระยะการมอง';
	@override String get distanceBody => 'ดันก้านอนาล็อกขึ้นเพื่อเลื่อนหน้าจอออกไปไกลขึ้น หรือดันลงเพื่อดึงเข้ามาใกล้ขึ้น ขณะจับหน้าต่าง การดันขึ้น/ลงจะเลื่อนหน้าต่างนั้น ปรับระดับเสียงได้ที่แผงควบคุม';
	@override String get distanceHint => 'ชี้ออกจากแผงควบคุม การจับรูปภาพไว้จะเปลี่ยนการดันขึ้น/ลงเป็นการซูมรูปภาพ ส่วนวิดีโอพาโนรามาจะปรับมุมมองแทน';
	@override String get resizeTitle => 'ใช้ขอบและมุม';
	@override String get resizeBody => 'กรอบจะสว่างขึ้นเมื่อลำแสงของคุณเข้าใกล้ขอบ กดไกชี้ค้างไว้หรือจีบนิ้วที่ขอบเพื่อย้ายหน้าต่าง ลากมุมเพื่อปรับขนาด';
	@override String get resizeHint => 'ใช้ได้กับหน้าต่างแอป แผงควบคุม และหน้าจอ หน้าต่างแอปสามารถปรับความกว้างและความสูงได้ ส่วนหน้าจอจะรักษาอัตราส่วนภาพไว้';
	@override String get navigationTitle => 'ย้อนกลับและเปิดการตั้งค่า';
	@override String get navigationBody => 'ปุ่ม B / Y ใช้ย้อนกลับหนึ่งระดับ: ปิดป๊อปอัปหรือกลับสู่หน้าแรกของแผงควบคุม ซ่อนแผงควบคุม แล้วกลับสู่แอป ปุ่ม Menu ด้านซ้ายเปิดการตั้งค่าเชิงพื้นที่';
	@override String get navigationHint => 'ปุ่ม Meta ด้านขวาเป็นของระบบ การตั้งศูนย์ระบบใหม่จะนำมุมมองกลับมาอยู่ข้างหน้าโดยยังคงขนาดและระยะห่างของหน้าจอไว้';
	@override String get handsTitle => 'ใช้มือของคุณ';
	@override String get handsBody => 'เมื่อเปิดใช้งานการติดตามมือ ให้เล็งลำแสงของระบบไปที่ปุ่ม จีบนิ้วหัวแม่มือและนิ้วชี้เข้าหากัน แล้วปล่อย ใช้แผงควบคุมสำหรับการเล่น การเลื่อนหาตำแหน่ง และการนำทางแกลเลอรี';
	@override String get handsHint => 'จีบนิ้วนอกจากแผงควบคุมเพื่อเปิด/ปิดแผง จีบนิ้วที่ขอบเพื่อย้าย ที่มุมเพื่อปรับขนาด หรือจีบนิ้วทั้งสองมือแล้วกางออกเพื่อขยายหน้าจอ';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesTh extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'เครื่องเล่นสื่อ';
	@override String get mediaServer => 'เซิร์ฟเวอร์สื่อ';
	@override String get internetGatewayDevice => 'เราเตอร์';
	@override String get basicDevice => 'อุปกรณ์พื้นฐาน';
	@override String get dimmableLight => 'ไฟอัจฉริยะ';
	@override String get wlanAccessPoint => 'จุดเชื่อมต่อ WLAN';
	@override String get wlanConnectionDevice => 'อุปกรณ์เชื่อมต่อ WLAN';
	@override String get printer => 'เครื่องพิมพ์';
	@override String get scanner => 'เครื่องสแกน';
	@override String get digitalSecurityCamera => 'กล้องวงจรปิดดิจิทัล';
	@override String get unknownDevice => 'อุปกรณ์ที่ไม่รู้จัก';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetTh extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetTh._(TranslationsTh root) : this._root = root, super.internal(root);

	final TranslationsTh _root; // ignore: unused_field

	// Translations
	@override String get title => 'รีโมตแคสต์';
	@override String get close => 'ปิด';
	@override String get searchingDevices => 'กำลังค้นหาอุปกรณ์...';
	@override String get searchPrompt => 'คลิกปุ่มค้นหาเพื่อค้นหาอุปกรณ์แคสต์อีกครั้ง';
	@override String get searching => 'กำลังค้นหา';
	@override String get searchAgain => 'ค้นหาอีกครั้ง';
	@override String get noDevicesFound => 'ไม่พบอุปกรณ์แคสต์\nโปรดตรวจสอบให้แน่ใจว่าอุปกรณ์อยู่ในเครือข่ายเดียวกัน';
	@override String get searchingDevicesPrompt => 'กำลังค้นหาอุปกรณ์ โปรดรอสักครู่...';
	@override String get cast => 'แคสต์';
	@override String connectedTo({required Object deviceName}) => 'เชื่อมต่อกับ: ${deviceName}';
	@override String get notConnected => 'ไม่ได้เชื่อมต่ออุปกรณ์';
	@override String get stopCasting => 'หยุดแคสต์';
}

/// The flat map containing all translations for locale <th>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'ข้อมูลส่วนตัว',
			'personalProfile.editPersonalProfile' => 'แก้ไขข้อมูลส่วนตัว',
			'personalProfile.avatar' => 'รูปโปรไฟล์',
			'personalProfile.background' => 'พื้นหลัง',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'รับข้อมูลโปรไฟล์ผู้ใช้ล้มเหลว: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'ความละเอียดที่แนะนำ: ${resolution}, ขนาดไฟล์ < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'รูปแบบที่รองรับ: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'ผู้ใช้พรีเมียมสามารถใช้ ${type} เคลื่อนไหวได้ (${formats})',
			'personalProfile.homepageBackground' => 'พื้นหลังหน้าแรก',
			'personalProfile.basicInfo' => 'ข้อมูลพื้นฐาน',
			'personalProfile.nickname' => 'ชื่อเล่น',
			'personalProfile.username' => 'ชื่อผู้ใช้',
			'personalProfile.copyUsername' => 'คัดลอกชื่อผู้ใช้',
			'personalProfile.usernameCopied' => 'คัดลอกชื่อผู้ใช้แล้ว',
			'personalProfile.personalIntroduction' => 'ประวัติส่วนตัว',
			'personalProfile.noPersonalIntroduction' => 'ไม่มีประวัติส่วนตัว',
			'personalProfile.clickToEdit' => 'แตะเพื่อแก้ไข',
			'personalProfile.privacySettings' => 'การตั้งค่าความเป็นส่วนตัว',
			'personalProfile.hideSensitiveContent' => 'ซ่อนเนื้อหาที่ละเอียดอ่อน',
			'personalProfile.hideSensitiveContentDesc' => 'ซ่อนวิดีโอหรือรูปภาพที่มีแท็กละเอียดอ่อน',
			'personalProfile.notificationSettings' => 'การตั้งค่าการแจ้งเตือน',
			'personalProfile.contentCommentNotification' => 'การแจ้งเตือนความคิดเห็นบนเนื้อหา',
			'personalProfile.contentCommentNotificationDesc' => 'แจ้งเตือนเมื่อมีคนแสดงความคิดเห็นบนเนื้อหาของคุณ',
			'personalProfile.commentReplyNotification' => 'การแจ้งเตือนการตอบกลับความคิดเห็น',
			'personalProfile.commentReplyNotificationDesc' => 'แจ้งเตือนเมื่อมีคนตอบกลับความคิดเห็นของคุณ',
			'personalProfile.mentionNotification' => 'การแจ้งเตือนการกล่าวถึง',
			'personalProfile.mentionNotificationDesc' => 'แจ้งเตือนเมื่อมีคนกล่าวถึงคุณในเนื้อหา',
			'personalProfile.accountInfo' => 'ข้อมูลบัญชี',
			'personalProfile.registrationTime' => 'เวลาลงทะเบียน',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'อัปเดตการตั้งค่าล้มเหลว: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'อัปเดตการตั้งค่าการแจ้งเตือนล้มเหลว: ${error}',
			'personalProfile.editNickname' => 'แก้ไขชื่อเล่น',
			'personalProfile.nicknameCannotBeEmpty' => 'ชื่อเล่นต้องไม่ว่างเปล่า',
			'personalProfile.changeSuccess' => 'เปลี่ยนแปลงสำเร็จ',
			'personalProfile.unsupportedFileFormat' => 'รูปแบบไฟล์ไม่รองรับ',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'ขนาดไฟล์ต้องไม่เกิน ${size}',
			'personalProfile.uploadFailed' => 'อัปโหลดล้มเหลว',
			'personalProfile.avatarUpdatedSuccessfully' => 'อัปเดตรูปโปรไฟล์สำเร็จ',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'อัปเดตรูปโปรไฟล์ล้มเหลว: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'อัปเดตพื้นหลังสำเร็จ',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'อัปเดตพื้นหลังล้มเหลว: ${error}',
			'personalProfile.editPersonalIntroduction' => 'แก้ไขประวัติส่วนตัว',
			'personalProfile.enterPersonalIntroduction' => 'โปรดป้อนประวัติส่วนตัว',
			'tutorial.specialFollowFeature' => 'ติดตามพิเศษ',
			'tutorial.specialFollowDescription' => 'ตั้งผู้สร้างที่คุณดูบ่อยเป็นติดตามพิเศษ เพื่อข้ามไปยังผลงานล่าสุดจากที่นี่ได้ทันที',
			'tutorial.stepsTitle' => 'สามขั้นตอน',
			'tutorial.stepFollowAuthor' => 'แตะติดตามในหน้าวิดีโอ แกลเลอรี หรือโปรไฟล์ของผู้สร้าง',
			'tutorial.stepPickSpecial' => 'แตะติดตามแล้วอีกครั้ง จากนั้นเลือกติดตามพิเศษจากเมนู',
			'tutorial.stepSwitchHere' => 'กลับมาที่นี่แล้วสลับไปยังผู้สร้างคนนั้นด้วยตัวเลือกรูปโปรไฟล์ด้านบน',
			'tutorial.specialFollowManagementTip' => 'จัดการรายการติดตามพิเศษได้ที่ แถบด้านข้าง - รายการติดตาม - ติดตามพิเศษ',
			'tutorial.gotIt' => 'เข้าใจแล้ว',
			'common.sort' => 'จัดเรียง',
			'common.filter' => 'ตัวกรอง',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'ตกลง',
			'common.cancel' => 'ยกเลิก',
			'common.select' => 'เลือก',
			'common.save' => 'บันทึก',
			'common.delete' => 'ลบ',
			'common.visit' => 'เยี่ยมชม',
			'common.loading' => 'กำลังโหลด...',
			'common.scrollToTop' => 'เลื่อนขึ้นด้านบน',
			'common.privacyHint' => 'เปิดโหมดความเป็นส่วนตัวอยู่ เนื้อหาถูกซ่อนไว้',
			'common.latest' => 'ล่าสุด',
			'common.likesCount' => 'ถูกใจ',
			'common.viewsCount' => 'การดู',
			'common.popular' => 'ยอดนิยม',
			'common.trending' => 'มาแรง',
			'common.commentList' => 'รายการความคิดเห็น',
			'common.sendComment' => 'ส่งความคิดเห็น',
			'common.send' => 'ส่ง',
			'common.retry' => 'ลองใหม่',
			'common.premium' => 'พรีเมียม',
			'common.follower' => 'ผู้ติดตาม',
			'common.friend' => 'เพื่อน',
			'common.video' => 'วิดีโอ',
			'common.following' => 'กำลังติดตาม',
			'common.expand' => 'ขยาย',
			'common.collapse' => 'ยุบ',
			'common.cancelFriendRequest' => 'ยกเลิกคำขอ',
			'common.cancelSpecialFollow' => 'ยกเลิกการติดตามพิเศษ',
			'common.addFriend' => 'เพิ่มเพื่อน',
			'common.removeFriend' => 'ลบเพื่อน',
			'common.followed' => 'ติดตามแล้ว',
			'common.follow' => 'ติดตาม',
			'common.unfollow' => 'เลิกติดตาม',
			'common.specialFollow' => 'ติดตามพิเศษ',
			'common.specialFollowed' => 'ติดตามพิเศษแล้ว',
			'common.gallery' => 'แกลเลอรี',
			'common.playlist' => 'เพลย์ลิสต์',
			'common.commentPostedSuccessfully' => 'โพสต์ความคิดเห็นสำเร็จ',
			'common.commentPostedFailed' => 'โพสต์ความคิดเห็นล้มเหลว',
			'common.success' => 'สำเร็จ',
			'common.commentDeletedSuccessfully' => 'ลบความคิดเห็นสำเร็จ',
			'common.commentUpdatedSuccessfully' => 'อัปเดตความคิดเห็นสำเร็จ',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} ความคิดเห็น', other: '${n} ความคิดเห็น', ), 
			'common.writeYourCommentHere' => 'เขียนความคิดเห็นของคุณที่นี่...',
			'common.tmpNoReplies' => 'ยังไม่มีการตอบกลับ',
			'common.loadMore' => 'โหลดเพิ่มเติม',
			'common.loadingMore' => 'กำลังโหลดเพิ่มเติม...',
			'common.noMoreDatas' => 'ไม่มีข้อมูลเพิ่มเติม',
			'common.selectTranslationLanguage' => 'เลือกภาษาที่ต้องการแปล',
			'common.translate' => 'แปล',
			'common.translateFailedPleaseTryAgainLater' => 'การแปลล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'common.translationResult' => 'ผลการแปล',
			'common.justNow' => 'เมื่อสักครู่',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} นาทีที่แล้ว', other: '${n} นาทีที่แล้ว', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} ชั่วโมงที่แล้ว', other: '${n} ชั่วโมงที่แล้ว', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} วันที่แล้ว', other: '${n} วันที่แล้ว', ), 
			'common.editedAt' => ({required Object num}) => 'แก้ไขเมื่อ ${num}',
			'common.editComment' => 'แก้ไขความคิดเห็น',
			'common.commentUpdated' => 'อัปเดตความคิดเห็นแล้ว',
			'common.replyComment' => 'ตอบกลับความคิดเห็น',
			'common.reply' => 'ตอบกลับ',
			'common.edit' => 'แก้ไข',
			'common.unknownUser' => 'ผู้ใช้ที่ไม่รู้จัก',
			'common.me' => 'ฉัน',
			'common.author' => 'ผู้สร้าง',
			'common.admin' => 'ผู้ดูแลระบบ',
			'common.viewReplies' => ({required Object num}) => 'ดูการตอบกลับ (${num})',
			'common.hideReplies' => 'ซ่อนการตอบกลับ',
			'common.confirmDelete' => 'ยืนยันการลบ',
			'common.areYouSureYouWantToDeleteThisItem' => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้?',
			'common.tmpNoComments' => 'ยังไม่มีความคิดเห็น',
			'common.refresh' => 'รีเฟรช',
			'common.back' => 'ย้อนกลับ',
			'common.tips' => 'เคล็ดลับ',
			'common.linkIsEmpty' => 'ลิงก์ว่างเปล่า',
			'common.linkCopiedToClipboard' => 'คัดลอกลิงก์ไปยังคลิปบอร์ดแล้ว',
			'common.imageCopiedToClipboard' => 'คัดลอกรูปภาพไปยังคลิปบอร์ดแล้ว',
			'common.copyImageFailed' => 'คัดลอกรูปภาพล้มเหลว',
			'common.mobileSaveImageIsUnderDevelopment' => 'ฟังก์ชันบันทึกรูปภาพบนมือถือกำลังพัฒนา',
			'common.imageSavedTo' => 'บันทึกรูปภาพไปที่',
			'common.saveImageFailed' => 'บันทึกรูปภาพล้มเหลว',
			'common.close' => 'ปิด',
			'common.more' => 'เพิ่มเติม',
			'common.unknownError' => 'ข้อผิดพลาดที่ไม่รู้จัก',
			'common.moreFeaturesToBeDeveloped' => 'ฟีเจอร์เพิ่มเติมอยู่ระหว่างการพัฒนา',
			'common.all' => 'ทั้งหมด',
			'common.selectedRecords' => ({required Object num}) => 'เลือกแล้ว ${num} รายการ',
			'common.cancelSelectAll' => 'ยกเลิกการเลือกทั้งหมด',
			'common.selectAll' => 'เลือกทั้งหมด',
			'common.invertSelection' => 'สลับการเลือก',
			'common.exitEditMode' => 'ออกจากโหมดแก้ไข',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการที่เลือก ${num} รายการ?',
			'common.searchHistoryRecords' => 'ประวัติการค้นหา...',
			'common.settings' => 'การตั้งค่า',
			'common.subscriptions' => 'การติดตาม',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} วิดีโอ', other: '${n} วิดีโอ', ), 
			'common.share' => 'แชร์',
			'common.areYouSureYouWantToShareThisPlaylist' => 'คุณแน่ใจหรือไม่ว่าต้องการแชร์เพลย์ลิสต์นี้?',
			'common.editTitle' => 'แก้ไขชื่อเรื่อง',
			'common.editMode' => 'โหมดแก้ไข',
			'common.pleaseEnterNewTitle' => 'โปรดป้อนชื่อเรื่องใหม่',
			'common.createPlayList' => 'สร้างเพลย์ลิสต์',
			'common.create' => 'สร้าง',
			'common.checkNetworkSettings' => 'ตรวจสอบการตั้งค่าเครือข่าย',
			'common.general' => 'ทั่วไป',
			'common.r18' => 'R18',
			'common.sensitive' => 'ละเอียดอ่อน',
			'common.year' => 'ปี',
			'common.month' => 'เดือน',
			'common.tag' => 'แท็ก',
			'common.private' => 'ส่วนตัว',
			'common.noTitle' => 'ไม่มีชื่อเรื่อง',
			'common.search' => 'ค้นหา',
			'common.noContent' => 'ไม่มีเนื้อหา',
			'common.recording' => 'กำลังบันทึก',
			'common.paused' => 'หยุดชั่วคราว',
			'common.clear' => 'ล้าง',
			'common.clearSelection' => 'ล้างการเลือก',
			'common.selectItemsToContinue' => 'เลือกรายการเพื่อดำเนินการต่อ',
			'common.andMoreItems' => ({required Object num}) => 'และอีก ${num} รายการ',
			'common.batchDelete' => 'ลบเป็นชุด',
			'common.user' => 'ผู้ใช้',
			'common.post' => 'โพสต์',
			'common.seconds' => 'วินาที',
			'common.comingSoon' => 'เร็วๆ นี้',
			'common.confirm' => 'ยืนยัน',
			'common.hour' => 'ชั่วโมง',
			'common.minute' => 'นาที',
			'common.clickToRefresh' => 'แตะเพื่อรีเฟรช',
			'common.history' => 'ประวัติ',
			'common.favorites' => 'รายการโปรด',
			'common.friends' => 'เพื่อน',
			'common.playList' => 'เพลย์ลิสต์',
			'common.checkLicense' => 'ตรวจสอบใบอนุญาต',
			'common.logout' => 'ออกจากระบบ',
			'common.fensi' => 'แฟนๆ',
			'common.accept' => 'ยอมรับ',
			'common.reject' => 'ปฏิเสธ',
			'common.clearAllHistory' => 'ล้างประวัติทั้งหมด',
			'common.clearAllHistoryConfirm' => 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติทั้งหมด?',
			'common.followingList' => 'รายชื่อที่กำลังติดตาม',
			'common.followersList' => 'รายชื่อผู้ติดตาม',
			'common.follows' => 'การติดตาม',
			'common.fans' => 'แฟนๆ',
			'common.followsAndFans' => 'การติดตามและแฟนๆ',
			'common.numViews' => 'การดู',
			'common.updatedAt' => 'อัปเดตเมื่อ',
			'common.publishedAt' => 'เผยแพร่เมื่อ',
			'common.externalVideo' => 'วิดีโอภายนอก',
			'common.originalText' => 'ข้อความต้นฉบับ',
			'common.showOriginalText' => 'แสดงข้อความต้นฉบับ',
			'common.showProcessedText' => 'แสดงข้อความที่ประมวลผลแล้ว',
			'common.preview' => 'ตัวอย่าง',
			'common.rules' => 'กฎระเบียบ',
			'common.agree' => 'ยอมรับ',
			'common.disagree' => 'ไม่ยอมรับ',
			'common.agreeToRules' => 'ยอมรับกฎระเบียบ',
			'common.tapToReread' => 'แตะเพื่ออ่านอีกครั้ง',
			'common.markdownSyntaxHelp' => 'วิธีใช้ไวยากรณ์ Markdown',
			'common.previewContent' => 'แสดงตัวอย่างเนื้อหา',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'ความยาวเกินขีดจำกัดสูงสุด (${max})',
			'common.agreeToCommunityRules' => 'ยอมรับกฎของชุมชน',
			'common.createPost' => 'สร้างโพสต์',
			'common.title' => 'ชื่อเรื่อง',
			'common.enterTitle' => 'โปรดป้อนชื่อเรื่อง',
			'common.content' => 'เนื้อหา',
			'common.enterContent' => 'โปรดป้อนเนื้อหา',
			'common.writeYourContentHere' => 'โปรดป้อนเนื้อหาที่นี่...',
			'common.tagBlacklist' => 'บัญชีดำแท็ก',
			'common.noData' => 'ไม่มีข้อมูล',
			'common.tagLimit' => 'ขีดจำกัดแท็ก',
			'common.enableFloatingButtons' => 'เปิดใช้ปุ่มลอย',
			'common.disableFloatingButtons' => 'ปิดใช้ปุ่มลอย',
			'common.enabledFloatingButtons' => 'เปิดใช้งานปุ่มลอยแล้ว',
			'common.disabledFloatingButtons' => 'ปิดใช้งานปุ่มลอยแล้ว',
			'common.pendingCommentCount' => 'จำนวนความคิดเห็นที่รอดำเนินการ',
			'common.joined' => ({required Object str}) => 'เข้าร่วมเมื่อ ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'เห็นล่าสุด ${str}',
			'common.download' => 'ดาวน์โหลด',
			'common.selectQuality' => 'เลือกคุณภาพ',
			'common.videoQualitySource' => 'ต้นฉบับ',
			'common.selectImageQuality' => 'เลือกคุณภาพของรูปภาพ',
			'common.imageQualityStandard' => 'มาตรฐาน',
			'common.imageQualityOriginal' => 'ต้นฉบับ',
			'common.selectDateRange' => 'เลือกช่วงวันที่',
			'common.selectDateRangeHint' => 'เลือกช่วงวันที่ ค่าเริ่มต้นคือ 30 วันที่ผ่านมา',
			'common.clearDateRange' => 'ล้างช่วงวันที่',
			'common.deleteRecordsInDateRange' => 'ลบบันทึกในช่วงนี้',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบบันทึกประวัติ ${num} รายการในช่วงนี้? การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'common.noHistoryRecordsInRange' => 'ไม่มีบันทึกประวัติในช่วงนี้',
			'common.followSuccessClickAgainToSpecialFollow' => 'ติดตามสำเร็จแล้ว แตะอีกครั้งเพื่อติดตามพิเศษ',
			'common.specialFollowTip' => 'เพิ่มในรายการติดตามพิเศษแล้ว — เลือกได้จากเมนูด้านขวาบนของหน้าการติดตามเพื่อเข้าถึงอย่างรวดเร็ว',
			'common.exitConfirmTip' => 'คุณแน่ใจหรือไม่ว่าต้องการออก?',
			'common.error' => 'ข้อผิดพลาด',
			'common.taskRunning' => 'มีงานกำลังทำงานอยู่ โปรดรอสักครู่',
			'common.operationCancelled' => 'การดำเนินการถูกยกเลิก',
			'common.unsavedChanges' => 'คุณมีการเปลี่ยนแปลงที่ยังไม่ได้บันทึก',
			'common.specialFollowsManagementTip' => 'ลากที่จับเพื่อจัดลำดับใหม่ • แตะปุ่มเพื่อลบออก',
			'common.specialFollowsManagement' => 'การจัดการการติดตามพิเศษ',
			'common.removeSpecialFollow' => 'ลบการติดตามพิเศษ',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => 'ลบ ${name} ออกจากการติดตามพิเศษหรือไม่?',
			'common.noSpecialFollows' => 'ยังไม่มีการติดตามพิเศษ',
			'common.createTimeDesc' => 'เรียงตามเวลาสร้างจากใหม่ไปเก่า',
			'common.createTimeAsc' => 'เรียงตามเวลาสร้างจากเก่าไปใหม่',
			'common.pagination.totalItems' => ({required Object num}) => 'ทั้งหมด ${num} รายการ',
			'common.pagination.jumpToPage' => 'ข้ามไปที่หน้า',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'โปรดป้อนหมายเลขหน้า (1-${max})',
			'common.pagination.pageNumber' => 'หมายเลขหน้า',
			'common.pagination.jump' => 'ข้ามไป',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'โปรดป้อนหมายเลขหน้าที่ถูกต้อง (1-${max})',
			'common.pagination.invalidInput' => 'โปรดป้อนหมายเลขหน้าที่ถูกต้อง',
			'common.pagination.waterfall' => 'แบบน้ำตก',
			'common.pagination.pagination' => 'แบบแบ่งหน้า',
			'common.notice' => 'ประกาศ',
			'common.detail' => 'รายละเอียด',
			'common.parseExceptionDestopHint' => ' - ผู้ใช้เดสก์ท็อปสามารถกำหนดค่าพร็อกซีได้ในการตั้งค่า',
			'common.iwaraTags' => 'แท็ก Iwara',
			'common.tagInfo' => 'ข้อมูลแท็ก',
			'common.tagOriginalKey' => 'แท็กต้นฉบับ',
			'common.tagTranslation' => 'คำแปล',
			'common.copy' => 'คัดลอก',
			'common.selectCopy' => 'เลือกและคัดลอก',
			'common.copiedToClipboard' => 'คัดลอกไปยังคลิปบอร์ดแล้ว',
			'common.showOriginalTag' => 'แสดงแท็กต้นฉบับ',
			'common.showTranslatedTag' => 'แสดงคำแปล',
			'common.tagTranslationFeedback' => 'มีข้อสงสัยเกี่ยวกับคำแปลหรือไม่? ส่งคำติชม',
			'common.tagLocalizationGuideTitle' => 'เกี่ยวกับการแปลแท็ก',
			'common.tagLocalizationGuideContent' => 'แอปจะแสดงแท็กดิบของ Iwara (เช่น mother) โดยใช้ชื่อในภาษาปัจจุบันของคุณ\n\n• เมื่อค้นหาแท็ก ระบบจะจับคู่ทั้งคำแปลและแท็กต้นฉบับ\n• แตะค้าง / คลิกขวาที่แท็กเพื่อดูและคัดลอกคีย์ต้นฉบับและคำแปล\n• คำแปลได้รับการดูแลโดยชุมชนตามความสามารถ — อาจมีข้อผิดพลาดได้',
			'common.likeThisVideo' => 'ถูกใจวิดีโอนี้',
			'common.likeThisGallery' => 'ถูกใจแกลเลอรีนี้',
			'common.operation' => 'การดำเนินการ',
			'common.replies' => 'การตอบกลับ',
			'common.externalLinkWarning' => 'คำเตือนลิงก์ภายนอก',
			'common.externalLinkWarningMessage' => 'คุณกำลังจะเปิดลิงก์ภายนอกที่ไม่ได้เป็นส่วนหนึ่งของ iwara.tv โปรดใช้ความระมัดระวังและตรวจสอบให้แน่ใจว่าลิงก์ปลอดภัยก่อนดำเนินการต่อ',
			'common.continueToExternalLink' => 'ดำเนินการต่อ',
			'common.cancelExternalLink' => 'ยกเลิก',
			'auth.login' => 'เข้าสู่ระบบ',
			'auth.logout' => 'ออกจากระบบ',
			'auth.email' => 'อีเมล',
			'auth.password' => 'รหัสผ่าน',
			'auth.loginOrRegister' => 'เข้าสู่ระบบ / ลงทะเบียน',
			'auth.register' => 'ลงทะเบียน',
			'auth.pleaseEnterEmail' => 'โปรดป้อนอีเมล',
			'auth.pleaseEnterPassword' => 'โปรดป้อนรหัสผ่าน',
			'auth.passwordMustBeAtLeast6Characters' => 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร',
			'auth.pleaseEnterCaptcha' => 'โปรดป้อนรหัสยืนยัน',
			'auth.captcha' => 'รหัสยืนยัน',
			'auth.refreshCaptcha' => 'รีเฟรชรหัสยืนยัน',
			'auth.captchaNotLoaded' => 'ยังไม่ได้โหลดรหัสยืนยัน',
			'auth.loginSuccess' => 'เข้าสู่ระบบสำเร็จ',
			'auth.loginSuccessProfilePending' => 'เข้าสู่ระบบแล้ว กำลังโหลดโปรไฟล์ของคุณ…',
			'auth.emailVerificationSent' => 'ส่งอีเมลยืนยันแล้ว',
			'auth.notLoggedIn' => 'ยังไม่ได้เข้าสู่ระบบ',
			'auth.clickToLogin' => 'แตะเพื่อเข้าสู่ระบบ',
			'auth.logoutConfirmation' => 'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?',
			'auth.logoutSuccess' => 'ออกจากระบบสำเร็จ',
			'auth.logoutFailed' => 'ออกจากระบบล้มเหลว',
			'auth.usernameOrEmail' => 'ชื่อผู้ใช้หรืออีเมล',
			'auth.pleaseEnterUsernameOrEmail' => 'โปรดป้อนชื่อผู้ใช้หรืออีเมล',
			'auth.rememberMe' => 'จำชื่อผู้ใช้',
			'auth.registerNoticeTitle' => 'ลงทะเบียนบนเว็บไซต์ทางการ',
			'auth.registerNoticeDescription' => 'ไม่รองรับการลงทะเบียนในแอปแล้ว โปรดไปที่เว็บไซต์ทางการของ Iwara เพื่อสร้างบัญชีของคุณ จากนั้นกลับมาเข้าสู่ระบบที่นี่',
			'auth.registerNoticeReturnTip' => 'หลังจากลงทะเบียนแล้ว ให้กลับมาที่นี่และเข้าสู่ระบบด้วยบัญชีของคุณ',
			'auth.goToOfficialWebsite' => 'ไปยังเว็บไซต์ทางการ',
			'errors.error' => 'ข้อผิดพลาด',
			'errors.required' => 'ฟิลด์นี้จำเป็นต้องกรอก',
			'errors.invalidEmail' => 'ที่อยู่อีเมลไม่ถูกต้อง',
			'errors.networkError' => 'เครือข่ายผิดพลาด โปรดลองใหม่อีกครั้ง',
			'errors.errorWhileFetching' => 'เกิดข้อผิดพลาดขณะดึงข้อมูล',
			'errors.commentCanNotBeEmpty' => 'เนื้อหาความคิดเห็นต้องไม่ว่างเปล่า',
			'errors.errorWhileFetchingReplies' => 'เกิดข้อผิดพลาดขณะดึงการตอบกลับ โปรดตรวจสอบการเชื่อมต่อเครือข่าย',
			'errors.canNotFindCommentController' => 'ไม่พบคอนโทรลเลอร์ความคิดเห็น',
			'errors.errorWhileLoadingGallery' => 'เกิดข้อผิดพลาดขณะโหลดแกลเลอรี',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'ไม่มีข้อมูลได้อย่างไร? เป็นไปไม่ได้ :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'รูปแบบรูปภาพไม่รองรับ: ${str}',
			'errors.invalidGalleryId' => 'รหัสแกลเลอรีไม่ถูกต้อง',
			'errors.translationFailedPleaseTryAgainLater' => 'การแปลล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'errors.errorOccurred' => 'เกิดข้อผิดพลาด โปรดลองใหม่อีกครั้งในภายหลัง',
			'errors.errorOccurredWhileProcessingRequest' => 'เกิดข้อผิดพลาดขณะประมวลผลคำขอ',
			'errors.errorWhileFetchingDatas' => 'เกิดข้อผิดพลาดขณะดึงข้อมูล โปรดลองใหม่อีกครั้งในภายหลัง',
			'errors.serviceNotInitialized' => 'ยังไม่ได้เริ่มต้นบริการ',
			'errors.unknownType' => 'ประเภทที่ไม่รู้จัก',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'เกิดข้อผิดพลาดขณะเปิดลิงก์: ${link}',
			'errors.invalidUrl' => 'URL ไม่ถูกต้อง',
			'errors.failedToOperate' => 'ดำเนินการล้มเหลว',
			'errors.permissionDenied' => 'การอนุญาตถูกปฏิเสธ',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'คุณไม่มีสิทธิ์เข้าถึงทรัพยากรนี้',
			'errors.loginFailed' => 'เข้าสู่ระบบล้มเหลว',
			'errors.unknownError' => 'ข้อผิดพลาดที่ไม่รู้จัก',
			'errors.sessionExpired' => 'เซสชันหมดอายุ',
			'errors.failedToFetchCaptcha' => 'ดึงรหัสยืนยันล้มเหลว',
			'errors.emailAlreadyExists' => 'อีเมลนี้มีอยู่แล้ว',
			'errors.invalidCaptcha' => 'รหัสยืนยันไม่ถูกต้อง',
			'errors.registerFailed' => 'ลงทะเบียนล้มเหลว',
			'errors.failedToFetchComments' => 'ดึงความคิดเห็นล้มเหลว',
			'errors.failedToFetchImageDetail' => 'ดึงรายละเอียดรูปภาพล้มเหลว',
			'errors.failedToFetchImageList' => 'ดึงรายการรูปภาพล้มเหลว',
			'errors.failedToFetchData' => 'ดึงข้อมูลล้มเหลว',
			'errors.invalidParameter' => 'พารามิเตอร์ไม่ถูกต้อง',
			'errors.pleaseLoginFirst' => 'โปรดเข้าสู่ระบบก่อน',
			'errors.errorWhileLoadingPost' => 'เกิดข้อผิดพลาดขณะโหลดโพสต์',
			'errors.errorWhileLoadingPostDetail' => 'เกิดข้อผิดพลาดขณะโหลดรายละเอียดโพสต์',
			'errors.invalidPostId' => 'รหัสโพสต์ไม่ถูกต้อง',
			'errors.forceUpdateNotPermittedToGoBack' => 'อยู่ในสถานะบังคับอัปเดต ไม่สามารถย้อนกลับได้',
			'errors.pleaseLoginAgain' => 'โปรดเข้าสู่ระบบอีกครั้ง',
			'errors.invalidLogin' => 'การเข้าสู่ระบบไม่ถูกต้อง โปรดตรวจสอบอีเมลและรหัสผ่านของคุณ',
			'errors.tooManyRequests' => 'มีคำขอมากเกินไป โปรดลองใหม่ในภายหลัง',
			'errors.exceedsMaxLength' => ({required Object max}) => 'ความยาวเกินกำหนด: ${max}',
			'errors.contentCanNotBeEmpty' => 'เนื้อหาต้องไม่ว่างเปล่า',
			'errors.titleCanNotBeEmpty' => 'ชื่อเรื่องต้องไม่ว่างเปล่า',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'มีคำขอมากเกินไป โปรดลองใหม่ในภายหลัง เหลือเวลาอีก',
			'errors.remainingHours' => ({required Object num}) => '${num} ชั่วโมง',
			'errors.remainingMinutes' => ({required Object num}) => '${num} นาที',
			'errors.remainingSeconds' => ({required Object num}) => '${num} วินาที',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'แท็กเกินขีดจำกัด ขีดจำกัดคือ: ${limit}',
			'errors.failedToRefresh' => 'รีเฟรชล้มเหลว',
			'errors.noPermission' => 'ไม่มีสิทธิ์',
			'errors.resourceNotFound' => 'ไม่พบทรัพยากร',
			'errors.failedToSaveCredentials' => 'บันทึกข้อมูลการเข้าสู่ระบบล้มเหลว',
			'errors.failedToLoadSavedCredentials' => 'โหลดข้อมูลการเข้าสู่ระบบที่บันทึกไว้ล้มเหลว',
			'errors.notFound' => 'ไม่พบเนื้อหาหรือเนื้อหาถูกลบไปแล้ว',
			'errors.network.basicPrefix' => 'ข้อผิดพลาดเครือข่าย - ',
			'errors.network.failedToConnectToServer' => 'เชื่อมต่อกับเซิร์ฟเวอร์ล้มเหลว',
			'errors.network.serverNotAvailable' => 'เซิร์ฟเวอร์ไม่พร้อมใช้งาน',
			'errors.network.requestTimeout' => 'หมดเวลาการร้องขอ',
			'errors.network.unexpectedError' => 'ข้อผิดพลาดที่ไม่คาดคิด',
			'errors.network.invalidResponse' => 'การตอบสนองไม่ถูกต้อง',
			'errors.network.invalidRequest' => 'คำขอไม่ถูกต้อง',
			'errors.network.invalidUrl' => 'URL ไม่ถูกต้อง',
			'errors.network.invalidMethod' => 'เมธอดไม่ถูกต้อง',
			'errors.network.invalidHeader' => 'ส่วนหัวไม่ถูกต้อง',
			'errors.network.invalidBody' => 'เนื้อหาคำขอไม่ถูกต้อง',
			'errors.network.invalidStatusCode' => 'รหัสสถานะไม่ถูกต้อง',
			'errors.network.serverError' => 'เซิร์ฟเวอร์เกิดข้อผิดพลาด',
			'errors.network.requestCanceled' => 'คำขอถูกยกเลิก',
			'errors.network.invalidPort' => 'พอร์ตไม่ถูกต้อง',
			'errors.network.proxyPortError' => 'พอร์ตพร็อกซีไม่ถูกต้อง',
			'errors.network.connectionRefused' => 'การเชื่อมต่อถูกปฏิเสธ',
			'errors.network.networkUnreachable' => 'ไม่สามารถเข้าถึงเครือข่ายได้',
			'errors.network.noRouteToHost' => 'ไม่มีเส้นทางไปยังโฮสต์',
			'errors.network.connectionFailed' => 'การเชื่อมต่อล้มเหลว',
			'errors.network.sslConnectionFailed' => 'การเชื่อมต่อ SSL ล้มเหลว โปรดตรวจสอบการตั้งค่าเครือข่ายของคุณ',
			'friends.clickToRestoreFriend' => 'แตะเพื่อคืนค่าเพื่อน',
			'friends.friendsList' => 'รายชื่อเพื่อน',
			'friends.friendRequests' => 'คำขอเป็นเพื่อน',
			'friends.friendRequestsList' => 'รายการคำขอเป็นเพื่อน',
			'friends.removingFriend' => 'กำลังลบเพื่อน...',
			'friends.failedToRemoveFriend' => 'ลบเพื่อนล้มเหลว',
			'friends.cancelingRequest' => 'กำลังยกเลิกคำขอเป็นเพื่อน...',
			'friends.failedToCancelRequest' => 'ยกเลิกคำขอเป็นเพื่อนล้มเหลว',
			'authorProfile.noMoreDatas' => 'ไม่มีข้อมูลเพิ่มเติม',
			'authorProfile.userProfile' => 'โปรไฟล์ผู้ใช้',
			'favorites.clickToRestoreFavorite' => 'แตะเพื่อคืนค่ารายการโปรด',
			'favorites.myFavorites' => 'รายการโปรดของฉัน',
			'favorites.batchCancelFavorite' => 'ลบรายการโปรดที่เลือก',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'ต้องการลบ ${count} รายการที่เลือกออกจากรายการโปรดหรือไม่? คุณสามารถคืนค่าได้โดยแตะที่การ์ดในภายหลัง',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => 'ลบ ${count} รายการออกจากรายการโปรดแล้ว',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => 'ลบออกแล้ว ${success} รายการ ล้มเหลว ${failed} รายการ',
			'galleryDetail.browseInSpace' => 'เรียกดูในพื้นที่เสมือน',
			'galleryDetail.galleryDetail' => 'รายละเอียดแกลเลอรี',
			'galleryDetail.viewGalleryDetail' => 'ดูรายละเอียดแกลเลอรี',
			'galleryDetail.zoomReset' => 'รีเซ็ตการซูม',
			'galleryDetail.copyLink' => 'คัดลอกลิงก์',
			'galleryDetail.copyImage' => 'คัดลอกรูปภาพ',
			'galleryDetail.saveAs' => 'บันทึกเป็น',
			'galleryDetail.saveToAlbum' => 'บันทึกลงอัลบั้ม',
			'galleryDetail.publishedAt' => 'เผยแพร่เมื่อ',
			'galleryDetail.viewsCount' => 'จำนวนการดู',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'แนะนำฟังก์ชันคลังภาพ',
			'galleryDetail.rightClickToSaveSingleImage' => 'คลิกขวาเพื่อบันทึกรูปภาพเดี่ยว',
			'galleryDetail.batchSave' => 'บันทึกเป็นชุด',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'ใช้ปุ่มซ้ายและขวาบนคีย์บอร์ดเพื่อสลับ',
			'galleryDetail.keyboardUpAndDownToZoom' => 'ใช้ปุ่มขึ้นและลงบนคีย์บอร์ดเพื่อซูม',
			'galleryDetail.mouseWheelToSwitch' => 'ใช้ล้อเลื่อนเมาส์เพื่อสลับ',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + ล้อเลื่อนเมาส์เพื่อซูม',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'ฟีเจอร์เพิ่มเติมรอให้คุณค้นพบ...',
			'galleryDetail.authorOtherGalleries' => 'แกลเลอรีอื่นของผู้สร้าง',
			'galleryDetail.relatedGalleries' => 'แกลเลอรีที่เกี่ยวข้อง',
			'galleryDetail.authorNoOtherGalleries' => 'ไม่มีแกลเลอรีอื่นจากผู้สร้างคนนี้',
			'galleryDetail.noRelatedGalleries' => 'ไม่มีแกลเลอรีที่เกี่ยวข้อง',
			'galleryDetail.scrollLeft' => 'เลื่อนไปทางซ้าย',
			'galleryDetail.scrollRight' => 'เลื่อนไปทางขวา',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'แตะขอบซ้ายและขวาเพื่อสลับรูปภาพ',
			'galleryDetail.rotateToLandscape' => 'แนวนอนเต็มจอ',
			'galleryDetail.backToPortrait' => 'กลับสู่แนวตั้ง',
			'playList.myPlayList' => 'เพลย์ลิสต์ของฉัน',
			'playList.friendlyTips' => 'คำแนะนำที่เป็นประโยชน์',
			'playList.dearUser' => 'ผู้ใช้ที่เคารพ',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'ระบบเพลย์ลิสต์ของ Iwara ยังไม่สมบูรณ์ในขณะนี้',
			'playList.notSupportSetCover' => 'ไม่รองรับการตั้งค่าภาพหน้าปก',
			'playList.notSupportDeleteList' => 'ไม่รองรับการลบเพลย์ลิสต์',
			'playList.notSupportSetPrivate' => 'ไม่รองรับการตั้งเป็นส่วนตัว',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'ใช่แล้ว... เพลย์ลิสต์ที่สร้างขึ้นจะคงอยู่ถาวรและทุกคนสามารถมองเห็นได้',
			'playList.smallSuggestion' => 'คำแนะนำเล็กน้อย',
			'playList.useLikeToCollectContent' => 'หากคุณให้ความสำคัญกับความเป็นส่วนตัว ขอแนะนำให้ใช้ฟังก์ชัน "ถูกใจ" เพื่อบันทึกเนื้อหา',
			'playList.welcomeToDiscussOnGitHub' => 'หากคุณมีข้อเสนอแนะหรือความคิดเห็นอื่นๆ ยินดีต้อนรับสู่การพูดคุยบน GitHub!',
			'playList.iUnderstand' => 'ฉันเข้าใจแล้ว',
			'playList.searchPlaylists' => 'ค้นหาเพลย์ลิสต์...',
			'playList.newPlaylistName' => 'ชื่อเพลย์ลิสต์ใหม่',
			'playList.createNewPlaylist' => 'สร้างเพลย์ลิสต์ใหม่',
			'playList.videos' => 'วิดีโอ',
			'search.googleSearchScope' => 'ขอบเขตการค้นหา',
			'search.searchTags' => 'ค้นหาแท็ก...',
			'search.contentRating' => 'การจัดระดับเนื้อหา',
			'search.removeTag' => 'ลบแท็ก',
			'search.pleaseEnterSearchContent' => 'โปรดป้อนเนื้อหาที่จะค้นหา',
			'search.exactMatch' => 'ตรงทุกคำ',
			'search.exactMatchOnHint' => 'กำลังจับคู่ทั้งวลีแบบตรงทุกคำ และค้นหาชื่อเรื่องภาษาจีนกับญี่ปุ่นด้วย แตะเพื่อค้นแบบกว้างขึ้น',
			'search.exactMatchOffHint' => 'จับคู่แบบหลวม — Iwara จะแยกคำออก แตะเพื่อจับคู่ทั้งวลีแบบตรงทุกคำ',
			'search.searchHistory' => 'ประวัติการค้นหา',
			'search.searchSuggestion' => 'คำแนะนำการค้นหา',
			'search.usedTimes' => 'จำนวนครั้งที่ใช้',
			'search.lastUsed' => 'ใช้งานล่าสุด',
			'search.noSearchHistoryRecords' => 'ไม่มีประวัติการค้นหา',
			'search.clearSearchHistoryConfirm' => 'คุณแน่ใจหรือไม่ว่าต้องการล้างประวัติการค้นหาทั้งหมด? การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'ยังไม่รองรับประเภทการค้นหา ${searchType} ในปัจจุบัน โปรดรอการอัปเดต',
			'search.searchResult' => 'ผลการค้นหา',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'ไม่รองรับประเภทการค้นหา: ${searchType}',
			'search.googleSearch' => 'ค้นหาด้วย Google',
			'search.googleSearchHint' => ({required Object webName}) => 'ฟังก์ชันการค้นหาของ ${webName} ใช้งานยากใช่ไหม? ลองใช้การค้นหาด้วย Google!',
			'search.googleSearchDescription' => 'ใช้ตัวดำเนินการค้นหา :site ของ Google เพื่อค้นหาเนื้อหาภายในเว็บไซต์ ซึ่งมีประโยชน์มากเมื่อค้นหาวิดีโอ แกลเลอรี เพลย์ลิสต์ และผู้ใช้',
			'search.googleSearchKeywordsHint' => 'ป้อนคำค้นหา',
			'search.openLinkJump' => 'เปิดลิงก์เพื่อข้ามไป',
			'search.googleSearchButton' => 'ค้นหาด้วย Google',
			'search.pleaseEnterSearchKeywords' => 'โปรดป้อนคำค้นหา',
			'search.googleSearchQueryCopied' => 'คัดลอกคำค้นหาไปยังคลิปบอร์ดแล้ว',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'เปิดเบราว์เซอร์ล้มเหลว: ${error}',
			'search.searchRequestTimeout' => 'หมดเวลาคำขอ โปรดลองใหม่ในภายหลัง',
			'search.searchCannotConnectToServer' => 'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ โปรดตรวจสอบการเชื่อมต่อเครือข่ายของคุณ',
			'search.searchNetworkError' => 'การเชื่อมต่อเครือข่ายล้มเหลว โปรดตรวจสอบการตั้งค่าเครือข่ายหรือลองใหม่ในภายหลัง',
			'search.searchFailedPleaseRetry' => 'การค้นหาล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'mediaList.personalIntroduction' => 'ข้อมูลเบื้องต้น',
			'settings.listViewMode' => 'โหมดมุมมองรายการ',
			'settings.previewEffect' => 'เอฟเฟกต์แสดงตัวอย่าง',
			'settings.useTraditionalPaginationMode' => 'ใช้โหมดแบ่งหน้าแบบดั้งเดิม',
			'settings.useTraditionalPaginationModeDesc' => 'เปิดใช้โหมดแบ่งหน้าแบบดั้งเดิม และปิดโหมดน้ำตก จะมีผลหลังจากเรนเดอร์หน้าใหม่หรือรีสตาร์ตแอป',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'แสดงแถบความคืบหน้าวิดีโอด้านล่างเมื่อแถบเครื่องมือถูกซ่อน',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'การกำหนดค่านี้กำหนดว่าจะแสดงแถบความคืบหน้าวิดีโอด้านล่างเมื่อแถบเครื่องมือถูกซ่อนหรือไม่',
			'settings.seekPreviewSize' => 'ขนาดหน้าต่างแสดงตัวอย่างการเลื่อน',
			'settings.seekPreviewSizeDesc' => 'ขนาดของหน้าต่างแสดงตัวอย่างเหนือแถบความคืบหน้า โดยปกติจะปรับตามขนาดของเครื่องเล่นและอัตราส่วนของวิดีโออยู่แล้ว ค่านี้ใช้เพื่อปรับเพิ่มลดเล็กน้อย',
			'settings.seekPreviewSizeSmall' => 'เล็ก',
			'settings.seekPreviewSizeStandard' => 'มาตรฐาน',
			'settings.seekPreviewSizeLarge' => 'ใหญ่',
			'settings.seekPreviewSizeStandardDesc' => 'ขนาดที่คำนวณจากเครื่องเล่นและวิดีโอ',
			'settings.showFullscreenUpNextHint' => 'แสดงที่จับ "เล่นต่อไป"',
			'settings.showFullscreenUpNextHintDesc' => 'แสดงที่จับเล็กๆ ที่ขอบขวาของเครื่องเล่นเพื่อเปิดลิ้นชักคิว (แหล่งที่มา / เพลย์ลิสต์ / ดูภายหลัง) หากปิดจะไม่มีทางเข้าอื่นอีก',
			'settings.basicSettings' => 'การตั้งค่าพื้นฐาน',
			'settings.personalizedSettings' => 'การตั้งค่าส่วนบุคคล',
			'settings.otherSettings' => 'การตั้งค่าอื่นๆ',
			'settings.searchConfig' => 'การกำหนดค่าการค้นหา',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'การกำหนดค่านี้กำหนดว่าจะใช้การกำหนดค่าก่อนหน้าซ้ำหรือไม่เมื่อเล่นวิดีโออีกครั้ง',
			'settings.playControl' => 'การควบคุมการเล่น',
			'settings.playbackSpeedSettings' => 'การเล่นและความเร็ว',
			'settings.playbackBehaviorSettings' => 'พฤติกรรมการเล่น',
			'settings.enhancementSettings' => 'โหมดโรงภาพยนตร์และการเพิ่มประสิทธิภาพ',
			'settings.fastForwardTime' => 'เวลาเดินหน้าอย่างเร็ว',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'เวลาเดินหน้าอย่างเร็วต้องเป็นจำนวนเต็มบวก',
			'settings.rewindTime' => 'เวลาย้อนกลับ',
			_ => null,
		} ?? switch (path) {
			'settings.rewindTimeMustBeAPositiveInteger' => 'เวลาย้อนกลับต้องเป็นจำนวนเต็มบวก',
			'settings.longPressPlaybackSpeed' => 'ความเร็วการเล่นเมื่อกดค้าง',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'ความเร็วการเล่นเมื่อกดค้างต้องเป็นตัวเลขบวก',
			'settings.defaultPlaybackSpeed' => 'ความเร็วการเล่นเริ่มต้น',
			'settings.rememberPlaybackSpeed' => 'จำความเร็วการเล่น',
			'settings.rememberPlaybackSpeedDesc' => 'เมื่อเปิดใช้งาน ความเร็วที่คุณตั้งในเครื่องเล่นจะถูกบันทึกเป็นค่าเริ่มต้นและใช้กับวิดีโอใหม่โดยอัตโนมัติ',
			'settings.repeat' => 'เล่นซ้ำ',
			'settings.renderVerticalVideoInVerticalScreen' => 'แสดงผลวิดีโอแนวตั้งในโหมดแนวตั้ง',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'การกำหนดค่านี้กำหนดว่าจะแสดงผลวิดีโอในโหมดแนวตั้งหรือไม่เมื่อเล่นแบบเต็มหน้าจอ',
			'settings.rememberVolume' => 'จำระดับเสียง',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'การกำหนดค่านี้กำหนดว่าจะรักษาระดับเสียงไว้หรือไม่เมื่อเล่นวิดีโออีกครั้ง',
			'settings.rememberBrightness' => 'จำความสว่าง',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'การกำหนดค่านี้กำหนดว่าจะรักษาความสว่างไว้หรือไม่เมื่อเล่นวิดีโออีกครั้ง',
			'settings.playControlArea' => 'พื้นที่ควบคุมการเล่น',
			'settings.leftAndRightControlAreaWidth' => 'ความกว้างของพื้นที่ควบคุมซ้ายและขวา',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'การกำหนดค่านี้กำหนดความกว้างของพื้นที่ควบคุมทางด้านซ้ายและขวาของเครื่องเล่น',
			'settings.proxyAddressCannotBeEmpty' => 'ที่อยู่พร็อกซีต้องไม่ว่างเปล่า',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'รูปแบบที่อยู่พร็อกซีไม่ถูกต้อง โปรดใช้รูปแบบ IP:พอร์ต หรือ ชื่อโดเมน:พอร์ต',
			'settings.proxyNormalWork' => 'พร็อกซีทำงานปกติ',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'ทดสอบพร็อกซีล้มเหลว รหัสสถานะ: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'ทดสอบพร็อกซีล้มเหลว ข้อผิดพลาด: ${exception}',
			'settings.proxyConfig' => 'การกำหนดค่าพร็อกซี',
			'settings.thisIsHttpProxyAddress' => 'นี่คือที่อยู่ HTTP พร็อกซี',
			'settings.checkProxy' => 'ตรวจสอบพร็อกซี',
			'settings.proxyAddress' => 'ที่อยู่พร็อกซี',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'โปรดป้อน URL ของเซิร์ฟเวอร์พร็อกซี เช่น 127.0.0.1:8080',
			'settings.enableProxy' => 'เปิดใช้พร็อกซี',
			'settings.left' => 'ซ้าย',
			'settings.middle' => 'กลาง',
			'settings.right' => 'ขวา',
			'settings.playerSettings' => 'การตั้งค่าเครื่องเล่น',
			'settings.networkSettings' => 'การตั้งค่าเครือข่าย',
			'settings.customizeYourPlaybackExperience' => 'ปรับแต่งประสบการณ์การเล่นของคุณ',
			'settings.chooseYourFavoriteAppAppearance' => 'เลือกรูปลักษณ์ของแอปที่คุณชื่นชอบ',
			'settings.configureYourProxyServer' => 'กำหนดค่าเซิร์ฟเวอร์พร็อกซีของคุณ',
			'settings.settings' => 'การตั้งค่า',
			'settings.themeSettings' => 'การตั้งค่าธีม',
			'settings.followSystem' => 'ตามระบบ',
			'settings.lightMode' => 'โหมดสว่าง',
			'settings.darkMode' => 'โหมดมืด',
			'settings.presetTheme' => 'ธีมที่ตั้งไว้ล่วงหน้า',
			'settings.basicTheme' => 'ธีมพื้นฐาน',
			'settings.needRestartToApply' => 'จำเป็นต้องรีสตาร์ตแอปเพื่อใช้การตั้งค่า',
			'settings.themeNeedRestartDescription' => 'การตั้งค่าธีมจำเป็นต้องรีสตาร์ตแอปเพื่อให้มีผล',
			'settings.about' => 'เกี่ยวกับ',
			'settings.diagnosticsAndFeedback' => 'การวินิจฉัยและคำติชม',
			'settings.currentVersion' => 'เวอร์ชันปัจจุบัน',
			'settings.latestVersion' => 'เวอร์ชันล่าสุด',
			'settings.checkForUpdates' => 'ตรวจสอบการอัปเดต',
			'settings.update' => 'อัปเดต',
			'settings.newVersionAvailable' => 'มีเวอร์ชันใหม่พร้อมใช้งาน',
			'settings.projectHome' => 'หน้าแรกของโปรเจกต์',
			'settings.release' => 'การเผยแพร่',
			'settings.issueReport' => 'รายงานปัญหา',
			'settings.openSourceLicense' => 'ใบอนุญาตโอเพนซอร์ส',
			'settings.checkForUpdatesFailed' => 'ตรวจสอบการอัปเดตล้มเหลว โปรดลองอีกครั้งในภายหลัง',
			'settings.autoCheckUpdate' => 'ตรวจสอบการอัปเดตอัตโนมัติ',
			'settings.updateContent' => 'เนื้อหาการอัปเดต',
			'settings.releaseDate' => 'วันที่เผยแพร่',
			'settings.ignoreThisVersion' => 'ข้ามเวอร์ชันนี้',
			'settings.forceUpdateTip' => 'นี่คือการอัปเดตที่จำเป็น โปรดอัปเดตเป็นเวอร์ชันล่าสุดโดยเร็วที่สุด',
			'settings.viewChangelog' => 'ดูบันทึกการเปลี่ยนแปลง',
			'settings.alreadyLatestVersion' => 'เป็นเวอร์ชันล่าสุดแล้ว',
			'settings.appSettings' => 'การตั้งค่าแอป',
			'settings.configureYourAppSettings' => 'กำหนดค่าการตั้งค่าแอปของคุณ',
			'settings.history' => 'ประวัติ',
			'settings.autoRecordHistory' => 'บันทึกประวัติอัตโนมัติ',
			'settings.autoRecordHistoryDesc' => 'บันทึกวิดีโอและรูปภาพที่คุณดูโดยอัตโนมัติ',
			'settings.autoDeleteHistory' => 'ล้างประวัติอัตโนมัติ',
			'settings.autoDeleteHistoryDesc' => 'ลบประวัติการท่องเว็บที่เก่ากว่าจำนวนวันที่เก็บรักษาโดยอัตโนมัติเมื่อเริ่มต้น (ปิดอยู่โดยค่าเริ่มต้น)',
			'settings.autoDeleteHistoryDays' => 'วันที่เก็บรักษา',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'เก็บไว้ ${num} วันล่าสุด',
			'settings.autoDeleteHistoryDaysInvalid' => 'โปรดป้อนจำนวนวันที่ถูกต้อง (อย่างน้อย 1 วัน)',
			'settings.showUnprocessedMarkdownText' => 'แสดงข้อความ Markdown ดิบ',
			'settings.showUnprocessedMarkdownTextDesc' => 'แสดงข้อความต้นฉบับของ Markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'โหมดความเป็นส่วนตัว',
			'settings.activeBackgroundPrivacyModeDesc' => 'บล็อกการจับภาพหน้าจอและการบันทึกหน้าจอ และซ่อนหน้าจอเมื่อทำงานอยู่เบื้องหลัง',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'ซ่อนหน้าจอเมื่อแอปไปอยู่เบื้องหลัง (แพลตฟอร์มนี้ไม่สามารถบล็อกการจับภาพหน้าจอได้)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'บล็อกการจับภาพหน้าจอและการบันทึกหน้าจอ',
			'settings.privacy' => 'ความเป็นส่วนตัว',
			'settings.appLock' => 'การล็อกแอป',
			'settings.appLockEnabled' => 'เปิดใช้การล็อกแอป',
			'settings.appLockEnabledDesc' => 'กำหนดให้ต้องใช้ PIN หรือข้อมูลไบโอเมตริกเพื่อเปิดแอป และซ่อนตัวอย่างพื้นหลังโดยอัตโนมัติ',
			'settings.appLockEnabledSummary' => 'เปิดอยู่ · ป้องกันด้วย PIN',
			'settings.appLockDisabledSummary' => 'ปิดอยู่',
			'settings.appLockTimeout' => 'ล็อกหลังจากออกจากแอป',
			'settings.appLockTimeoutDesc' => 'ระยะเวลาที่อนุญาตให้อยู่เบื้องหลังก่อนที่จะต้องยืนยันตัวตน',
			'settings.appLockAfterScreenOff' => 'ล็อกหลังจากล็อกหน้าจอ',
			'settings.appLockAfterScreenOffDesc' => 'กำหนดให้ยืนยันตัวตนหลังจากหน้าจอของอุปกรณ์ถูกล็อก',
			'settings.appLockTimeoutDisabled' => 'ปิดใช้งาน',
			'settings.appLockImmediately' => 'ทันที',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} วินาที',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} นาที',
			'settings.appLockUseBiometrics' => 'ใช้ข้อมูลไบโอเมตริก',
			'settings.appLockUseBiometricsDesc' => 'ปลดล็อกด้วยลายนิ้วมือหรือการจดจำใบหน้า',
			'settings.appLockBiometricsUnavailable' => 'ไม่มีข้อมูลไบโอเมตริกที่ลงทะเบียนไว้ในอุปกรณ์นี้',
			'settings.appLockSetPin' => 'ตั้งค่า PIN',
			'settings.appLockEnterPin' => 'ป้อน PIN',
			'settings.appLockConfirmPin' => 'ยืนยัน PIN',
			'settings.appLockCurrentPin' => 'ป้อน PIN ปัจจุบัน',
			'settings.appLockNewPin' => 'ป้อน PIN ใหม่',
			'settings.appLockPinRequirements' => 'PIN ต้องประกอบด้วยตัวเลข 4–8 หลัก',
			'settings.appLockPinsDoNotMatch' => 'PIN ไม่ตรงกัน',
			'settings.appLockInvalidPin' => 'PIN ไม่ถูกต้อง',
			'settings.appLockSetupFailed' => 'ไม่สามารถบันทึก PIN ได้อย่างปลอดภัย',
			'settings.appLockDisable' => 'ป้อน PIN เพื่อปิดการล็อกแอป',
			'settings.appLockChangePin' => 'เปลี่ยน PIN',
			'settings.appLockNow' => 'ล็อกทันที',
			'settings.appLockUnlock' => 'ปลดล็อก',
			'settings.appLockLockedTitle' => 'ล็อกอยู่',
			'settings.appLockLockedDesc' => 'ยืนยันตัวตนเพื่อดำเนินการต่อ',
			'settings.appLockAuthenticateReason' => 'ยืนยันตัวตนเพื่อปลดล็อก',
			'settings.appLockEnableBiometricsReason' => 'ยืนยันตัวตนเพื่อเปิดใช้การปลดล็อกด้วยไบโอเมตริก',
			'settings.appLockBiometricFailed' => 'การยืนยันตัวตนด้วยไบโอเมตริกไม่เสร็จสมบูรณ์',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'พยายามมากเกินไป ลองใหม่อีกครั้งในอีก ${seconds} วินาที',
			'settings.appLockCredentialUnavailableTitle' => 'ไม่สามารถอ่านข้อมูลรับรองการล็อกแอปได้',
			'settings.appLockCredentialUnavailableDesc' => 'ที่จัดเก็บข้อมูลที่ปลอดภัยของระบบไม่พร้อมใช้งานชั่วคราว หรือข้อมูลรับรองเสียหาย แอปจะยังคงล็อกอยู่ โปรดลองใหม่อีกครั้งก่อน หากยังคงล้มเหลว คุณสามารถรีเซ็ตการล็อกแอปได้ ซึ่งจะเป็นการปิดใช้งานและล้าง PIN ที่บันทึกไว้',
			'settings.appLockRetry' => 'ลองใหม่',
			'settings.appLockReset' => 'รีเซ็ตการล็อกแอป',
			'settings.appLockResetAction' => 'รีเซ็ต',
			'settings.appLockResetConfirmTitle' => 'รีเซ็ตการล็อกแอปหรือไม่?',
			'settings.appLockResetConfirmDesc' => 'การดำเนินการนี้จะปิดการล็อกแอปและล้าง PIN ที่บันทึกไว้รวมถึงการตั้งค่าไบโอเมตริก คุณสามารถตั้งค่าใหม่ได้ในภายหลัง',
			'settings.appLockRetrySucceeded' => 'อ่านข้อมูลรับรองสำเร็จแล้ว โปรดป้อน PIN ของคุณ',
			'settings.appLockRetryFailed' => 'ยังคงไม่สามารถอ่านข้อมูลรับรองได้',
			'settings.forum' => 'ฟอรัม',
			'settings.news' => 'ข่าวสาร',
			'settings.community' => 'ชุมชน',
			'settings.disableForumReplyQuote' => 'ปิดใช้การอ้างอิงการตอบกลับฟอรัม',
			'settings.disableForumReplyQuoteDesc' => 'ปิดการแนบข้อมูลชั้นที่ตอบกลับเมื่อตอบกลับในฟอรัม',
			'settings.theaterMode' => 'โหมดโรงภาพยนตร์',
			'settings.theaterModeDesc' => 'หลังจากเปิดใช้งาน พื้นหลังของเครื่องเล่นจะถูกตั้งเป็นเวอร์ชันเบลอของภาพปกวิดีโอ',
			'settings.appLinks' => 'ลิงก์แอป',
			'settings.defaultBrowser' => 'เรียกดูเริ่มต้น',
			'settings.defaultBrowserDesc' => 'โปรดเปิดรายการกำหนดค่าลิงก์เริ่มต้นในการตั้งค่าระบบและเพิ่มลิงก์เว็บไซต์ iwara.tv',
			'settings.themeMode' => 'โหมดธีม',
			'settings.themeModeDesc' => 'การกำหนดค่านี้กำหนดโหมดธีมของแอป',
			'settings.glassEffect' => 'วัสดุอินเทอร์เฟซ',
			'settings.glassEffectDesc' => 'เลือกวัสดุที่ใช้ทั่วทั้งแอป — แคปซูลส่วนหัว เมนู ปุ่มกล่องโต้ตอบ และแถบนำทางด้านล่าง',
			'settings.liquidGlassEffect' => 'กระจกเหลว',
			'settings.liquidGlassEffectDesc' => 'การเบลอและการหักเหแสงจริง สวยงามที่สุด แต่อาจมีเฟรมดรอปและเปลืองพลังงานเพิ่มขึ้นเล็กน้อยบนอุปกรณ์ระดับเริ่มต้น',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'พื้นผิว Material 3 มาตรฐาน — ทึบแสง ไม่มีการเบลอ ไม่มีเงา ประสิทธิภาพและอายุการใช้งานแบตเตอรี่ดีที่สุด',
			'settings.glassEffectIntroTitle' => 'เลือกวัสดุอินเทอร์เฟซของคุณ',
			'settings.glassEffectIntroContent' => 'ส่วนหัว แถบแท็บ และเมนูใช้กระจกเหลว — การเบลอและการหักเหแสงจริง หากรู้สึกว่าอุปกรณ์ของคุณช้า หรือชอบอะไรที่เรียบง่ายกว่า สามารถเปลี่ยนเป็น Material ได้ตอนนี้ (พื้นผิวทึบแสง ไม่เบลอ ไม่มีเงา)',
			'settings.glassEffectIntroHint' => 'คุณสามารถเปลี่ยนค่านี้ได้ตลอดเวลาใน การตั้งค่า → ธีม → วัสดุอินเทอร์เฟซ',
			'settings.glassEffectIntroDone' => 'ใช้แบบนี้',
			'settings.dynamicColor' => 'สีแบบไดนามิก',
			'settings.dynamicColorDesc' => 'การกำหนดค่านี้กำหนดว่าแอปจะใช้สีแบบไดนามิกหรือไม่',
			'settings.useDynamicColor' => 'ใช้สีแบบไดนามิก',
			'settings.useDynamicColorDesc' => 'การกำหนดค่านี้กำหนดว่าแอปจะใช้สีแบบไดนามิกหรือไม่',
			'settings.presetColors' => 'สีที่ตั้งไว้ล่วงหน้า',
			'settings.customColors' => 'สีที่กำหนดเอง',
			'settings.customColorsDisabledByDynamicColor' => 'เปิดใช้งานสีแบบไดนามิกอยู่ สีที่ตั้งไว้ล่วงหน้า/สีที่กำหนดเองจึงไม่พร้อมใช้งาน โปรดปิดสีแบบไดนามิกก่อน',
			'settings.pickColor' => 'เลือกสี',
			'settings.cancel' => 'ยกเลิก',
			'settings.confirm' => 'ยืนยัน',
			'settings.noCustomColors' => 'ไม่มีสีที่กำหนดเอง',
			'settings.recordAndRestorePlaybackProgress' => 'บันทึกและคืนค่าความคืบหน้าการเล่น',
			'settings.autoPlayVideoOnFirstEnter' => 'เล่นวิดีโออัตโนมัติเมื่อเข้าครั้งแรก',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'การตั้งค่านี้กำหนดว่าวิดีโอจะเริ่มเล่นโดยอัตโนมัติหรือไม่เมื่อเข้าสู่หน้าวิดีโอเป็นครั้งแรก',
			'settings.autoEnterFullscreen' => 'เข้าสู่โหมดเต็มหน้าจอโดยอัตโนมัติ',
			'settings.autoEnterFullscreenDesc' => 'กำหนดเวลาที่เครื่องเล่นควรเข้าสู่โหมดเต็มหน้าจอเอง วิดีโอส่วนตัว วิดีโอที่ถูกลบ วิดีโอภายนอก และขณะใช้การแสดงภาพซ้อนภาพจะไม่เข้าสู่โหมดเต็มหน้าจออัตโนมัติ',
			'settings.autoEnterFullscreenOff' => 'ปิด',
			'settings.autoEnterFullscreenOffDesc' => 'ไม่เข้าสู่โหมดเต็มหน้าจอเองโดยอัตโนมัติ',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'เมื่อเริ่มเล่น',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'เข้าสู่โหมดเต็มหน้าจอทันทีที่เริ่มเล่นวิดีโอจริง',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'เมื่อเปิดหน้าวิดีโอ',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'เข้าสู่โหมดเต็มหน้าจอทันทีที่เปิดหน้าวิดีโอโดยไม่ต้องรอให้เริ่มเล่น',
			'settings.autoEnterFullscreenKind' => 'ประเภทเต็มหน้าจอ',
			'settings.autoEnterFullscreenKindDesc' => 'ประเภทของโหมดเต็มหน้าจอที่จะเข้าอัตโนมัติ สำหรับเดสก์ท็อปเท่านั้น',
			'settings.autoEnterFullscreenKindSystem' => 'เต็มหน้าจอระบบ',
			'settings.autoEnterFullscreenKindSystemDesc' => 'ให้ตัวจัดการหน้าต่างขยายหน้าต่างเป็นแบบเต็มหน้าจอ',
			'settings.autoEnterFullscreenKindApp' => 'เต็มหน้าจอแอป',
			'settings.autoEnterFullscreenKindAppDesc' => 'คงขนาดหน้าต่างไว้เหมือนเดิมและเปลี่ยนทั้งแอปให้กลายเป็นเครื่องเล่น',
			'settings.signature' => 'ลายเซ็น',
			'settings.enableSignature' => 'เปิดใช้ลายเซ็น',
			'settings.enableSignatureDesc' => 'การกำหนดค่านี้กำหนดว่าแอปจะเพิ่มลายเซ็นเมื่อตอบกลับหรือไม่',
			'settings.enterSignature' => 'ป้อนลายเซ็น',
			'settings.editSignature' => 'แก้ไขลายเซ็น',
			'settings.signatureContent' => 'เนื้อหาลายเซ็น',
			'settings.signaturePreview' => 'ตัวอย่าง',
			'settings.signatureSampleBody' => 'ข้อความของคุณอยู่ตรงนี้',
			'settings.signatureRegenerate' => 'สร้างใหม่',
			'settings.signatureNotSet' => 'ยังไม่ได้ตั้งค่า',
			'settings.signatureRuleHint' => 'ลายเซ็นจะต่อท้ายเนื้อหาโดยมีเส้นคั่น แอปจะใส่เส้นคั่นให้เอง คุณแค่เขียนข้อความด้านล่าง',
			'settings.signatureInsertVariable' => 'แทรกตัวแปร',
			'settings.varDate' => 'วันที่',
			'settings.varTime' => 'เวลา',
			'settings.varDatetime' => 'วันที่และเวลา',
			'settings.varWeekday' => 'วันในสัปดาห์',
			'settings.varPlatform' => 'แพลตฟอร์ม',
			'settings.varPick' => 'ข้อความสุ่ม',
			'settings.varTitle' => 'ชื่อเรื่อง',
			'settings.varAuthor' => 'ผู้สร้าง',
			'settings.varTags' => 'แท็ก',
			'settings.varSection' => 'หมวด',
			'settings.varReplyTo' => 'กำลังตอบถึง',
			'settings.varPlaytime' => 'ตำแหน่งการเล่น',
			'settings.signatureContextGroup' => 'ตัวแปรบริบท',
			'settings.signatureContextHint' => 'ค่าต่าง ๆ มาจากหน้าที่คุณกำลังโพสต์อยู่ หน้าวิดีโอรู้ชื่อเรื่อง ผู้สร้าง แท็ก และตำแหน่งที่เล่นอยู่ ส่วนฟอรัมรู้หมวดและเลขชั้น ด้านขวาคือค่าตัวอย่าง ส่วนที่เติมไม่ได้จะหายไปเองตอนส่ง',
			'settings.signatureContextValue' => 'แล้วแต่หน้า',
			'settings.varFloor' => 'ลำดับความเห็น',
			'settings.varDuration' => 'ความยาววิดีโอ',
			'settings.signatureRecipesHint' => 'ไม่รู้จะเขียนอะไรดี? แตะสักอันเพื่อใช้เลย แล้วค่อยแก้ ข้างล่างคือหน้าตาจริงเวลาส่งออกไป',
			'settings.recipeWatchingName' => 'กำลังดูอะไรอยู่',
			'settings.recipeWatchingTemplate' => 'กำลังดู %title% · %date%',
			'settings.recipeTimestampName' => 'ดูถึงตรงนี้',
			'settings.recipeTimestampTemplate' => 'ดูถึง %playtime% จาก %duration%',
			'settings.recipeHitokotoName' => 'คำคมประจำวัน',
			'settings.recipeHitokotoTemplate' => 'คำคมประจำวัน: %hitokoto%',
			'settings.recipeAiName' => 'ให้ AI เขียนให้',
			'settings.recipeAiTemplate' => '%ai_hitokoto%',
			'settings.recipeReplyName' => 'ทักทายตอนตอบกลับ',
			'settings.recipeReplyTemplate' => 'ถึง %reply_to% · ส่งจาก %platform%',
			'settings.recipeMoodName' => 'อารมณ์แบบสุ่ม',
			'settings.recipeMoodTemplate' => 'อารมณ์วันนี้: %pick:ดีมาก|เฉย ๆ|ไม่บอก%',
			'settings.signatureRecipesTitle' => 'ตัวอย่าง',
			'settings.signatureRecipesMore' => 'ตัวอย่างเพิ่มเติม',
			'settings.signatureSceneVideo' => 'ในหน้าวิดีโอ',
			'settings.signatureSceneForum' => 'ในฟอรัม',
			'settings.signatureSceneAuthor' => 'ในหน้าโปรไฟล์',
			'settings.signatureSceneNone' => 'ไม่มีบริบท',
			'settings.signatureSceneFromHistory' => 'เนื้อหาตัวอย่างมาจากสิ่งที่คุณดูล่าสุด เวลาส่งจริงจะใช้หน้าที่คุณอยู่ตอนนั้น',
			'settings.signatureSceneFromDemo' => 'ยังไม่มีประวัติการดู จึงใช้ตัวอย่างสำรองไปก่อน เวลาส่งจริงจะใช้หน้าที่คุณอยู่ตอนนั้น',
			'settings.signatureDemoVideoTitle' => 'เต้นรำใต้แสงจันทร์',
			'settings.signatureDemoAuthor' => 'Hoshino',
			'settings.signatureDemoTags' => 'mmd 4k 60fps',
			'settings.signatureDemoThreadTitle' => 'ขอคำแนะนำการตั้งค่าคุณภาพ',
			'settings.signatureDemoSection' => 'ทั่วไป',
			'settings.signatureDemoQuote' => 'ช้า ๆ ได้พร้าเล่มงาม',
			'settings.signatureDemoAiQuote' => 'แค่ท่าหมุนตอนสามนาทีครึ่งก็คุ้มแล้ว',
			'settings.signatureRecipeGroupWatching' => 'ตอนดูวิดีโอ',
			'settings.signatureRecipeGroupReplying' => 'ตอนตอบกลับ',
			'settings.signatureRecipeGroupForum' => 'ตอนอยู่ในฟอรัม',
			'settings.signatureRecipeGroupDaily' => 'วันละหนึ่งประโยค',
			'settings.signatureRecipeGroupAi' => 'ให้ AI เขียนให้',
			'settings.signaturePromptSampleContext' => 'การลองเขียนครั้งนี้ใช้บริบทตัวอย่างของหน้าวิดีโอ เวลาส่งจริง AI จะได้รับสิ่งที่คุณกำลังดูอยู่',
			'settings.recipeAuthorTagsName' => 'ผู้สร้างและแท็ก',
			'settings.recipeAuthorTagsTemplate' => '%author% · %tags%',
			'settings.recipeFloorName' => 'ตอบชั้นที่ระบุ',
			'settings.recipeFloorTemplate' => 'จากชั้น %floor% · ถึง %reply_to%',
			'settings.recipeSectionName' => 'บอกหมวดที่อยู่',
			'settings.recipeSectionTemplate' => 'จากหมวด %section%',
			'settings.recipeDailyName' => 'วันที่กับหนึ่งประโยค',
			'settings.recipeDailyTemplate' => '%date% %weekday% · %hitokoto%',
			'settings.signatureSources' => 'แหล่งข้อมูล',
			'settings.signatureAutoTranslate' => 'แปลเป็นภาษาของฉัน',
			'settings.signatureAutoTranslateDesc' => 'แหล่งข้อมูลอย่าง Hitokoto ตอนนี้มีแต่ภาษาจีน ประโยคที่ได้จะถูกแปลก่อนส่งออกไป',
			'settings.signatureWizardTitle' => 'เพิ่มแหล่งข้อมูล',
			'settings.signatureWizardUrlTitle' => 'ที่อยู่ปลายทาง',
			'settings.signatureWizardUrlHint' => 'ใส่ที่อยู่ที่คืนค่าข้อความหนึ่งบรรทัด ปุ่มด้านล่างจะเรียกจริงหนึ่งครั้งเพื่อให้คุณเห็นว่าได้อะไรกลับมา',
			'settings.signatureWizardFetch' => 'ลองเรียกดู',
			'settings.signatureWizardSkipTest' => 'ข้ามไป แค่เปลี่ยนชื่อ',
			'settings.signatureWizardPickTitle' => 'เลือกส่วนที่ต้องการ',
			'settings.signatureWizardPickHint' => 'นี่คือสิ่งที่ปลายทางนั้นส่งกลับมา แตะบรรทัดที่อยากให้ลายเซ็นแสดง',
			'settings.signatureWizardPickPlainHint' => 'ปลายทางนี้ส่งข้อความธรรมดากลับมา ทั้งก้อนคือสิ่งที่จะแสดง',
			'settings.signatureWizardWholeBody' => 'คำตอบทั้งหมด',
			'settings.signatureWizardNameTitle' => 'ตั้งชื่อให้มัน',
			'settings.signatureWizardNameHint' => 'ชื่อมีไว้ให้คุณจำเอง ส่วนที่ลายเซ็นใช้อ้างถึงคือชื่ออ้างอิงด้านล่าง',
			'settings.signatureWizardNext' => 'ถัดไป',
			'settings.signatureWizardDone' => 'เสร็จ',
			'settings.signatureWizardStripHtml' => 'เอาแท็ก HTML ออก',
			'settings.signatureWizardAdvanced' => 'ขั้นสูง: ดึงด้วยรูปแบบ',
			'settings.signatureWizardExtractHint' => 'นิพจน์ทั่วไป ใช้กลุ่มที่จับได้กลุ่มแรก',
			'settings.signatureWizardExtractMissed' => 'รูปแบบนี้ไม่ตรงกับอะไรเลย จึงใช้ข้อความเดิม',
			'settings.signatureWizardChooseTitle' => 'เลือกสักแหล่ง',
			'settings.signatureWizardChooseHint' => 'แตะแหล่งที่เตรียมไว้ให้ก็เสร็จแล้ว หรือจะชี้ไปที่ปลายทางของคุณเองก็ได้',
			'settings.signatureWizardCustomSource' => 'ใช้ปลายทางของฉันเอง',
			'settings.signatureWizardWithOrigin' => 'แสดงที่มาด้วย',
			'settings.signatureWizardRandomItem' => 'สุ่มใหม่ทุกครั้ง',
			'settings.signatureWizardSuffixTitle' => 'ต่อท้ายด้วยอีกฟิลด์',
			'settings.signatureWizardSuffixNone' => 'ไม่ต่อ',
			'settings.signatureOptFlavor' => 'เนื้อหา',
			'settings.signatureOptFlavorAny' => 'ไม่จำกัด',
			'settings.signatureOptFlavorOtaku' => 'อนิเมะ มังงะ และเกม',
			'settings.signatureOptFlavorLiterary' => 'วรรณกรรมและบทกวี',
			'settings.signatureOptFlavorMeme' => 'วัฒนธรรมอินเทอร์เน็ต',
			'settings.signatureOptLength' => 'ความยาว',
			'settings.signatureOptLengthAny' => 'ไม่จำกัด',
			'settings.signatureOptLengthShort' => 'เอาเฉพาะประโยคสั้น',
			'settings.signatureRestoreDefault' => 'คืนค่าเริ่มต้น',
			'settings.signatureSourceHitokoto' => 'Hitokoto (ข้อความสุ่ม)',
			'settings.signatureAiSourceName' => 'ข้อความจาก AI',
			'settings.signatureEditTextHint' => 'นี่คือลายเซ็นที่เขียนอยู่ในความเห็นนี้แล้ว ทั้งวรรคทองและวันที่ตอนนี้เป็นแค่ข้อความธรรมดา แก้ได้ตามใจ ล้างให้ว่างคือไม่เอาลายเซ็น',
			'settings.signatureResolving' => ({required Object name}) => 'กำลังสร้าง ${name}…',
			'settings.signaturePendingValue' => '(สร้างตอนส่ง)',
			'settings.signatureAiHint' => 'ประโยคที่ AI เขียนสด ใหม่ทุกความคิดเห็น โดยใช้ผู้ให้บริการ AI ที่คุณตั้งไว้ เมื่อส่งจากหน้าวิดีโอ แกลเลอรี หรือฟอรัม AI จะรู้ด้วยว่าคุณกำลังดูอะไรและเขียนให้เข้ากับสิ่งนั้น',
			'settings.signatureAiUnavailable' => 'ยังไม่ได้ตั้งค่าผู้ให้บริการ AI แหล่งนี้จึงยังไม่ปรากฏในแผงตัวแปร',
			'settings.signaturePromptTitle' => 'พรอมต์',
			'settings.signaturePromptHint' => 'นี่คือสิ่งที่ส่งให้โมเดล เขียนใหม่ได้ตามใจ ทั้งน้ำเสียง ความยาว และหัวข้อ กฎที่มีอยู่แล้วควรเก็บไว้',
			'settings.signaturePromptReset' => 'คืนค่าเริ่มต้น',
			'settings.signaturePromptTry' => 'ลองดู',
			'settings.signaturePromptSample' => 'สิ่งที่เขียนออกมา',
			'settings.signaturePromptLanguageHint' => 'จะถูกแทนด้วยภาษาอินเทอร์เฟซของคุณ ถ้าลบออก ข้อความจะใช้ภาษาตามพรอมต์',
			'settings.signaturePromptEdited' => 'แก้แล้ว',
			'settings.signatureVariablesGroup' => 'ตัวแปรในตัว',
			'settings.signatureNeedsNetwork' => 'ต้องใช้เครือข่าย',
			'settings.signatureBuiltinSource' => 'ในตัว',
			'settings.signatureSourceIdReserved' => 'ชื่อนี้ถูกตัวแปรในตัวใช้อยู่',
			'settings.signatureSourcesTitle' => 'แหล่งข้อมูลที่กำหนดเอง',
			'settings.signatureSourcesHint' => 'ใส่ที่อยู่ที่คืนค่าข้อความหนึ่งบรรทัด แล้วคุณจะดึงมาใส่ในลายเซ็นได้',
			'settings.signatureSourcesEmpty' => 'ยังไม่มีแหล่งข้อมูล',
			'settings.signatureAddSource' => 'เพิ่ม',
			'settings.signatureEditSource' => 'แก้ไขแหล่งข้อมูล',
			'settings.signatureSourceName' => 'ชื่อ',
			'settings.signatureSourceId' => 'ชื่อที่ใช้อ้างอิง',
			'settings.signatureSourceIdHint' => 'ชื่อที่ลายเซ็นใช้เรียกแหล่งข้อมูลนี้',
			'settings.signatureSourceUrl' => 'ที่อยู่ปลายทาง',
			'settings.signatureSourcePath' => 'เส้นทางของค่า',
			'settings.signatureSourcePathHint' => 'เว้นว่างไว้ถ้าทั้งคำตอบคือข้อความนั้น ใส่ data.text เพื่อดึงฟิลด์นั้นจากคำตอบแบบ JSON',
			'settings.signatureSourceTest' => 'ทดสอบ',
			'settings.signatureSourceTestOk' => 'ดึงมาได้แล้ว',
			'settings.signatureSourceTestFailed' => 'ไม่มีอะไรกลับมา',
			'settings.signatureSourceIdInvalid' => 'ชื่ออ้างอิงใช้ได้เฉพาะตัวพิมพ์เล็ก ตัวเลข และขีดล่าง',
			'settings.signatureSourceIdDuplicate' => 'ชื่ออ้างอิงนี้ถูกใช้ไปแล้ว',
			'settings.signatureSourceUrlRequired' => 'กรุณาใส่ที่อยู่ปลายทาง',
			'settings.exportConfig' => 'ส่งออกการกำหนดค่าแอป',
			'settings.exportConfigDesc' => 'ส่งออกการตั้งค่าและประวัติ (ประวัติการเข้าชม ความคืบหน้าการเล่น รายการโปรด ฯลฯ) ไปยังไฟล์เพื่อสำรองข้อมูลหรือถ่ายโอนไปยังอุปกรณ์อื่น ไม่รวมงานดาวน์โหลด',
			'settings.importConfig' => 'นำเข้าการกำหนดค่าแอป',
			'settings.importConfigDesc' => 'นำเข้าการกำหนดค่าแอปจากไฟล์',
			'settings.exportConfigSuccess' => 'ส่งออกการกำหนดค่าสำเร็จ!',
			'settings.exportConfigFailed' => 'ส่งออกการกำหนดค่าล้มเหลว',
			'settings.importConfigSuccess' => 'นำเข้าการกำหนดค่าสำเร็จ!',
			'settings.importConfigFailed' => 'นำเข้าการกำหนดค่าล้มเหลว',
			'settings.exportIncludeSensitive' => 'รวมข้อมูลที่ละเอียดอ่อน',
			'settings.exportIncludeSensitiveDesc' => 'รวมคีย์ API โทเค็นเซสชัน และที่อยู่พร็อกซี เปิดใช้งานเมื่อสำรองข้อมูลไปยังอุปกรณ์ของคุณเองเท่านั้น',
			'settings.importConfigOverwriteWarning' => 'การนำเข้าจะเขียนทับการตั้งค่าและประวัติปัจจุบันของคุณ (ประวัติการเข้าชม ความคืบหน้าการเล่น รายการโปรด ฯลฯ) ดำเนินการต่อหรือไม่?',
			'settings.importConfigRestartTitle' => 'นำเข้าสำเร็จ',
			'settings.importConfigRestartContent' => 'นำเข้าการกำหนดค่าของคุณเรียบร้อยแล้ว โปรดปิดและเปิดแอปใหม่อีกครั้งเพื่อให้การเปลี่ยนแปลงทั้งหมดมีผล',
			'settings.historyUpdateLogs' => 'บันทึกการอัปเดตประวัติ',
			'settings.noUpdateLogs' => 'ไม่มีบันทึกการอัปเดต',
			'settings.versionLabel' => 'เวอร์ชัน: {version}',
			'settings.releaseDateLabel' => 'วันที่เผยแพร่: {date}',
			'settings.noChanges' => 'ไม่มีเนื้อหาการอัปเดต',
			'settings.interaction' => 'การโต้ตอบ',
			'settings.enableVibration' => 'เปิดใช้การสั่น',
			'settings.enableVibrationDesc' => 'เปิดใช้การตอบสนองแบบสั่นเมื่อโต้ตอบกับแอป',
			'settings.defaultKeepVideoToolbarVisible' => 'คงแถบเครื่องมือวิดีโอไว้เสมอ',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'การตั้งค่านี้กำหนดว่าจะให้แถบเครื่องมือวิดีโอแสดงอยู่เสมอหรือไม่เมื่อเข้าสู่หน้าวิดีโอเป็นครั้งแรก',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'การเปิดใช้โหมดโรงภาพยนตร์บนอุปกรณ์เคลื่อนที่อาจทำให้เกิดปัญหาด้านประสิทธิภาพ คุณสามารถเลือกเปิดใช้งานได้ตามความเหมาะสม',
			'settings.fullscreenOrientation' => 'การวางแนวหน้าจอแนวตั้งหลังจากเข้าสู่โหมดเต็มหน้าจอ',
			'settings.fullscreenOrientationDesc' => 'การตั้งค่านี้กำหนดทิศทางหน้าจอเริ่มต้นเมื่อเข้าสู่โหมดเต็มหน้าจอ (สำหรับมือถือเท่านั้น)',
			'settings.fullscreenOrientationLeftLandscape' => 'แนวนอนซ้าย',
			'settings.fullscreenOrientationRightLandscape' => 'แนวนอนขวา',
			'settings.screenFit' => 'ขนาดหน้าจอ',
			'settings.screenFitDesc' => 'เลือกว่าจะให้วิดีโอแสดงผลในพื้นที่ของเครื่องเล่นอย่างไร',
			'settings.rememberScreenFit' => 'จำขนาดหน้าจอ',
			'settings.rememberScreenFitDesc' => 'ใช้ขนาดที่เลือกกับวิดีโอที่เปิดในภายหลัง',
			'settings.screenFitFit' => 'พอดี',
			'settings.screenFitFitDesc' => 'แสดงภาพทั้งเฟรมโดยรักษาอัตราส่วนเดิมไว้',
			'settings.screenFitStretch' => 'ยืด',
			'settings.screenFitStretchDesc' => 'ขยายให้เต็มพื้นที่เครื่องเล่น ภาพอาจผิดเพี้ยน',
			'settings.screenFitCover' => 'เติมเต็ม',
			'settings.screenFitCoverDesc' => 'ขยายให้เต็มพื้นที่เครื่องเล่นโดยรักษาอัตราส่วนเดิมไว้ ส่วนที่เกินจะถูกครอบตัด',
			'settings.screenFitRatioDesc' => 'บังคับใช้อัตราส่วนนี้ ภาพอาจผิดเพี้ยน',
			'settings.jumpLink' => 'ลิงก์กระโดด',
			'settings.language' => 'ภาษา',
			'settings.languageNativeName' => 'ไทย',
			'settings.followSystemLanguage' => 'ตามภาษาระบบ',
			'settings.languageChangedMessage' => 'เปลี่ยนภาษาสำเร็จ ฟีเจอร์บางอย่างต้องรีสตาร์ทแอปจึงจะมีผล',
			'settings.languageChanged' => 'การตั้งค่าภาษาถูกเปลี่ยนแปลงแล้ว โปรดรีสตาร์ตแอปเพื่อให้มีผล',
			'settings.keybinding.title' => 'แป้นพิมพ์ลัด',
			'settings.keybinding.entryLabel' => 'แป้นพิมพ์ลัด',
			'settings.keybinding.entryDesc' => 'กำหนดค่าแป้นพิมพ์ลัดของแอปเอง (หลักๆ สำหรับเดสก์ท็อป)',
			'settings.keybinding.desktopHint' => 'แป้นพิมพ์ลัดใช้ได้กับแป้นพิมพ์เดสก์ท็อปเป็นหลัก บนมือถือมักใช้ท่าทางสัมผัส',
			'settings.keybinding.resetAll' => 'รีเซ็ตทั้งหมดเป็นค่าเริ่มต้น',
			'settings.keybinding.resetAllConfirm' => 'รีเซ็ตแป้นพิมพ์ลัดทั้งหมดของแอปกลับเป็นค่าเริ่มต้นหรือไม่?',
			'settings.keybinding.resetToDefault' => 'รีเซ็ตเป็นค่าเริ่มต้น',
			'settings.keybinding.resetScope' => 'รีเซ็ตส่วนนี้',
			'settings.keybinding.notSet' => 'ไม่ได้ตั้งค่า',
			'settings.keybinding.addShortcut' => 'เพิ่มแป้นพิมพ์ลัด',
			'settings.keybinding.removeShortcut' => 'ลบแป้นพิมพ์ลัดนี้',
			'settings.keybinding.pressNewShortcut' => 'กดแป้นพิมพ์ลัดใหม่…',
			'settings.keybinding.recordingCancelHint' => 'กด Esc เพื่อยกเลิก',
			'settings.keybinding.mouseHint' => 'คุณยังสามารถผูกปุ่มด้านข้างของเมาส์ (ย้อนกลับ / ไปข้างหน้า) หรือปุ่มกลางได้ด้วย',
			'settings.keybinding.mouseNotSupportedInScope' => 'พื้นที่นี้ไม่รองรับปุ่มเมาส์ โปรดใช้แป้นพิมพ์แทน',
			'settings.keybinding.capabilityKeyboardOnly' => 'พื้นที่นี้ยอมรับเฉพาะแป้นบนแป้นพิมพ์เท่านั้น',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'พื้นที่นี้ยอมรับแป้นบนแป้นพิมพ์ รวมถึงปุ่มกลางและปุ่มด้านข้างของเมาส์',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'พื้นที่นี้ยอมรับแป้นบนแป้นพิมพ์ รวมถึงปุ่มกลางและปุ่มไปข้างหน้าของเมาส์ (ปุ่มย้อนกลับถูกระบบใช้งานแล้ว)',
			'settings.keybinding.rejectMultipleButtons' => 'กดปุ่มเมาส์ทีละปุ่ม',
			'settings.keybinding.rejectPlatformBack' => 'ระบบใช้ปุ่มนี้สำหรับ "ย้อนกลับ" แล้ว การผูกปุ่มนี้จะทำให้ย้อนกลับซ้ำสองครั้ง',
			'settings.keybinding.detectedLabel' => 'ตรวจพบแล้ว',
			'settings.keybinding.reservedKey' => 'แป้นนี้สงวนไว้โดยระบบและไม่สามารถผูกได้',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'แป้นนี้ผูกกับ "${action}" ไว้ จึงสงวนไว้ที่นี่เพื่อให้คุณยังสามารถออกจากหน้านี้ได้',
			'settings.keybinding.conflictTitle' => 'ความขัดแย้งของแป้นพิมพ์ลัด',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" แล้ว การดำเนินการต่อจะเป็นการลบการผูกเดิมออก',
			'settings.keybinding.conflictContinue' => 'ผูกต่อไป',
			'settings.keybinding.shadowWarningTitle' => 'แป้นพิมพ์ลัดส่วนกลางซ้ำซ้อน',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" ในระดับส่วนกลาง การผูกที่นี่จะแทนที่การกระทำดังกล่าวเฉพาะภายในส่วนนี้เท่านั้น',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'แป้นพิมพ์ลัดชุดนี้ผูกไว้กับ "${action}" ใน ${scope} แล้ว เมื่อเข้าสู่ส่วนนั้น แป้นพิมพ์ลัดส่วนกลางนี้จะถูกแทนที่',
			'settings.keybinding.searchHint' => 'ค้นหาแป้นพิมพ์ลัด…',
			'settings.keybinding.scopeGlobal' => 'ส่วนกลาง',
			'settings.keybinding.scopeGallery' => 'แกลเลอรี',
			'settings.keybinding.scopeVideo' => 'วิดีโอ',
			'settings.keybinding.categoryNavigation' => 'การนำทาง',
			'settings.keybinding.categoryZoom' => 'การซูม',
			'settings.keybinding.categoryPlayback' => 'การเล่น',
			'settings.keybinding.categorySeek' => 'การเลื่อนเวลา',
			'settings.keybinding.categoryVolume' => 'ระดับเสียง',
			'settings.keybinding.categoryDisplay' => 'การแสดงผล',
			'settings.keybinding.actionGlobalBack' => 'ย้อนกลับ',
			'settings.keybinding.actionGalleryNext' => 'รูปถัดไป',
			'settings.keybinding.actionGalleryPrevious' => 'รูปก่อนหน้า',
			'settings.keybinding.actionGalleryZoomIn' => 'ซูมเข้า',
			'settings.keybinding.actionGalleryZoomOut' => 'ซูมออก',
			'settings.keybinding.actionGalleryResetZoom' => 'รีเซ็ตการซูม',
			'settings.keybinding.actionGalleryPlayPause' => 'เล่น / หยุดชั่วคราว',
			'settings.keybinding.actionGallerySeekBackward' => 'ย้อนกลับ',
			'settings.keybinding.actionGallerySeekForward' => 'เดินหน้าอย่างเร็ว',
			'settings.keybinding.actionGalleryToggleMute' => 'สลับปิด/เปิดเสียง',
			'settings.keybinding.actionPlayPause' => 'เล่น / หยุดชั่วคราว',
			'settings.keybinding.actionSpeedUp' => 'เพิ่มความเร็ว',
			'settings.keybinding.actionSpeedDown' => 'ลดความเร็ว',
			'settings.keybinding.actionSeekForward' => 'เลื่อนไปข้างหน้า',
			'settings.keybinding.actionSeekBackward' => 'เลื่อนถอยหลัง',
			'settings.keybinding.actionVolumeUp' => 'เพิ่มระดับเสียง',
			'settings.keybinding.actionVolumeDown' => 'ลดระดับเสียง',
			'settings.keybinding.actionToggleMute' => 'สลับปิด/เปิดเสียง',
			'settings.keybinding.actionToggleFullscreen' => 'สลับโหมดเต็มหน้าจอ',
			'settings.keybinding.seekLongPressHint' => 'กดปุ่มเลื่อนไปข้างหน้า / ถอยหลังค้างไว้เพื่อเข้าสู่โหมดความเร็วด้วยการกดค้าง',
			'settings.keybinding.zoomSectionTitle' => 'การซูมรูปภาพ (คงที่)',
			'settings.keybinding.zoomFixedNote' => 'แป้นพิมพ์ลัดด้านล่างนี้ได้รับการกำหนดไว้แล้วและไม่สามารถเปลี่ยนแปลงได้',
			'settings.keybinding.zoomScaleLabel' => 'ซูมรูปภาพ',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + ล้อเลื่อน',
			'settings.keybinding.zoomRotateLabel' => 'หมุนรูปภาพ',
			'settings.keybinding.zoomRotateHint' => 'Shift + ล้อเลื่อน',
			'settings.keybinding.zoomPinchGesture' => 'หนีบนิ้ว',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'หมุนด้วยสองนิ้ว',
			'settings.gestureControl' => 'การควบคุมด้วยท่าทาง',
			'settings.leftDoubleTapRewind' => 'แตะสองครั้งด้านซ้ายเพื่อย้อนกลับ',
			'settings.rightDoubleTapFastForward' => 'แตะสองครั้งด้านขวาเพื่อเดินหน้าอย่างเร็ว',
			'settings.doubleTapPause' => 'แตะสองครั้งเพื่อหยุดชั่วคราว',
			'settings.rightVerticalSwipeVolume' => 'ปัดแนวตั้งด้านขวาเพื่อปรับระดับเสียง (มีผลเมื่อเข้าสู่หน้าใหม่)',
			'settings.leftVerticalSwipeBrightness' => 'ปัดแนวตั้งด้านซ้ายเพื่อปรับความสว่าง (มีผลเมื่อเข้าสู่หน้าใหม่)',
			'settings.longPressFastForward' => 'กดค้างเพื่อเดินหน้าอย่างเร็ว',
			'settings.enableMouseHoverShowToolbar' => 'เปิดใช้การชี้เมาส์เพื่อแสดงแถบเครื่องมือ',
			'settings.enableMouseHoverShowToolbarInfo' => 'เมื่อเปิดใช้งาน แถบเครื่องมือวิดีโอจะแสดงขึ้นเมื่อเลื่อนเมาส์ไปเหนือเครื่องเล่น และจะซ่อนโดยอัตโนมัติหลังจากไม่มีการใช้งานเป็นเวลา 3 วินาที',
			'settings.enableHorizontalDragSeek' => 'ปัดในแนวนอนเพื่อเลื่อนหาตำแหน่ง',
			'settings.enableVideoGestureZoom' => 'หนีบนิ้วเพื่อซูมเฟรมวิดีโอ',
			'settings.enableVideoGestureZoomInfo' => 'หนีบนิ้วด้วยสองนิ้ว (หรือ Ctrl + ล้อเลื่อนเมาส์บนเดสก์ท็อป) เพื่อซูมภาพวิดีโอ จากนั้นลากเพื่อเลื่อนตำแหน่งภาพ',
			'settings.showCenterPlayPauseButton' => 'ปุ่มเล่น/หยุดชั่วคราวตรงกลาง',
			'settings.showCenterPlayPauseButtonDesc' => 'แสดงปุ่มเล่น/หยุดชั่วคราวขนาดใหญ่ตรงกลางเครื่องเล่น',
			'settings.audioVideoConfig' => 'การกำหนดค่าเสียงและวิดีโอ',
			'settings.expandBuffer' => 'ขยายบัฟเฟอร์',
			'settings.expandBufferInfo' => 'เมื่อเปิดใช้งาน ขนาดบัฟเฟอร์จะเพิ่มขึ้น เวลาในการโหลดจะนานขึ้น แต่การเล่นจะราบรื่นยิ่งขึ้น',
			'settings.videoSyncMode' => 'โหมดการซิงค์วิดีโอ',
			'settings.videoSyncModeSubtitle' => 'กลยุทธ์การซิงโครไนซ์เสียงและวิดีโอ',
			'settings.hardwareDecodingMode' => 'โหมดการถอดรหัสฮาร์ดแวร์',
			'settings.hardwareDecodingModeSubtitle' => 'การตั้งค่าการถอดรหัสฮาร์ดแวร์',
			'settings.enableHardwareAcceleration' => 'เปิดใช้การเร่งความเร็วด้วยฮาร์ดแวร์',
			'settings.enableHardwareAccelerationInfo' => 'การเปิดใช้การเร่งความเร็วด้วยฮาร์ดแวร์สามารถปรับปรุงประสิทธิภาพการถอดรหัสได้ แต่อุปกรณ์บางรุ่นอาจไม่รองรับ',
			'settings.useOpenSLESAudioOutput' => 'ใช้เอาต์พุตเสียง OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'ใช้เอาต์พุตเสียงที่มีความหน่วงต่ำ อาจช่วยปรับปรุงประสิทธิภาพของเสียงได้',
			'settings.videoSyncAudio' => 'การซิงค์เสียง',
			'settings.videoSyncDisplayResample' => 'การสุ่มตัวอย่างใหม่ในการแสดงผล',
			'settings.videoSyncDisplayResampleVdrop' => 'การสุ่มตัวอย่างใหม่ในการแสดงผล (ดรอปเฟรม)',
			'settings.videoSyncDisplayResampleDesync' => 'การสุ่มตัวอย่างใหม่ในการแสดงผล (ไม่ซิงค์)',
			'settings.videoSyncDisplayTempo' => 'จังหวะการแสดงผล',
			'settings.videoSyncDisplayVdrop' => 'แสดงผลโดยดรอปเฟรมวิดีโอ',
			'settings.videoSyncDisplayAdrop' => 'แสดงผลโดยดรอปเฟรมเสียง',
			'settings.videoSyncDisplayDesync' => 'แสดงผลแบบไม่ซิงค์',
			'settings.videoSyncDesync' => 'ไม่ซิงค์',
			'settings.forumSettings.name' => 'ฟอรัม',
			'settings.forumSettings.configureYourForumSettings' => 'กำหนดค่าการตั้งค่าฟอรัมของคุณ',
			'settings.gallerySettings.gallerySettingsTitle' => 'การตั้งค่าแกลเลอรี',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'กำหนดค่ากำหนดของโปรแกรมดูแกลเลอรี',
			'settings.gallerySettings.defaultViewerQuality' => 'คุณภาพเริ่มต้นของโปรแกรมดู',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'เลือกคุณภาพของรูปภาพที่จะแสดงเป็นค่าเริ่มต้นเมื่อเปิดโปรแกรมดูแกลเลอรี',
			'settings.blockSettings.title' => 'การบล็อกเนื้อหา',
			'settings.blockSettings.subtitle' => 'ซ่อนวิดีโอและแกลเลอรีที่มีชื่อเรื่องตรงกับคำสำคัญหรือรูปแบบ หรือมาจากผู้ใช้ที่ถูกบล็อกโดยอัตโนมัติ การจับคู่ทั้งหมดเกิดขึ้นบนอุปกรณ์ของคุณ — ไม่มีการอัปโหลดข้อมูลใดๆ',
			'settings.blockSettings.blocked' => 'บล็อกแล้ว',
			'settings.blockSettings.reveal' => 'แสดง',
			'settings.blockSettings.reblock' => 'บล็อกอีกครั้ง',
			'settings.blockSettings.why' => 'ทำไมจึงถูกบล็อก?',
			'settings.blockSettings.manageRules' => 'จัดการกฎ',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'ชื่อเรื่องประกอบด้วย "${value}"',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'ชื่อเรื่องตรงกับนิพจน์ "${value}"',
			'settings.blockSettings.reasonUser' => 'มาจากผู้ใช้ที่ถูกบล็อก',
			'settings.blockSettings.addRule' => 'เพิ่มกฎ',
			'settings.blockSettings.editRule' => 'แก้ไขกฎ',
			'settings.blockSettings.deleteRule' => 'ลบกฎ',
			'settings.blockSettings.ruleType' => 'ประเภทกฎ',
			'settings.blockSettings.keyword' => 'คำสำคัญ',
			'settings.blockSettings.regex' => 'นิพจน์ทั่วไป (Regex)',
			'settings.blockSettings.userId' => 'ผู้ใช้',
			'settings.blockSettings.value' => 'ข้อความที่ต้องการจับคู่',
			'settings.blockSettings.caseSensitive' => 'ตรงตามตัวพิมพ์ใหญ่-เล็ก',
			'settings.blockSettings.regexHint' => 'เช่น trailer|teaser',
			'settings.blockSettings.valueRequired' => 'โปรดป้อนข้อความที่ต้องการจับคู่',
			'settings.blockSettings.invalidRegex' => 'นิพจน์ทั่วไปไม่ถูกต้อง',
			'settings.blockSettings.noRules' => 'ยังไม่มีกฎ แตะ + เพื่อเพิ่ม',
			'settings.blockSettings.blockUser' => 'บล็อก',
			'settings.blockSettings.unblockUser' => 'เลิกบล็อก',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => 'บล็อก "${name}" หรือไม่? วิดีโอและแกลเลอรีของพวกเขาจะถูกซ่อนจากรายการและการค้นหา',
			'settings.blockSettings.userBlocked' => 'บล็อกผู้ใช้แล้ว',
			'settings.blockSettings.userUnblocked' => 'เลิกบล็อกผู้ใช้แล้ว',
			'settings.blockSettings.exportRules' => 'ส่งออก',
			'settings.blockSettings.importRules' => 'นำเข้า',
			'settings.blockSettings.importExport' => 'นำเข้า / ส่งออก',
			'settings.blockSettings.exportSuccess' => 'ส่งออกกฎแล้ว',
			'settings.blockSettings.exportFailed' => 'ไม่สามารถส่งออกกฎได้',
			'settings.blockSettings.importSuccess' => ({required Object count}) => 'นำเข้า ${count} กฎเรียบร้อยแล้ว',
			'settings.blockSettings.importFailed' => 'ไม่สามารถนำเข้ากฎได้',
			'settings.blockSettings.regexHelp' => 'ความช่วยเหลือเกี่ยวกับรูปแบบ',
			'settings.blockSettings.regexHelpTitle' => 'เอกสารอ้างอิง Regex',
			'settings.blockSettings.regexHelpIntro' => 'นิพจน์ทั่วไปสามารถจับคู่ชื่อเรื่องได้อย่างยืดหยุ่นมากกว่าคำสำคัญธรรมดา ตัวอย่างทั่วไปบางส่วน:',
			'settings.blockSettings.regexHelpTapHint' => 'แตะตัวอย่างเพื่อนำไปใช้',
			'settings.blockSettings.regexEx1Pattern' => 'ตัวอย่าง|ทีเซอร์|โบนัส',
			'settings.blockSettings.regexEx1Desc' => 'ตรงกับคำใดคำหนึ่งเหล่านี้ ("|" หมายถึง "หรือ")',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'ชื่อเรื่องที่ขึ้นต้นด้วย [วงเล็บ]',
			_ => null,
		} ?? switch (path) {
			'settings.blockSettings.regexEx3Pattern' => 'คอลเลกชัน\$',
			'settings.blockSettings.regexEx3Desc' => 'ชื่อเรื่องที่ลงท้ายด้วย "Collection"',
			'settings.blockSettings.regexEx4Pattern' => 'ตอนที่.',
			'settings.blockSettings.regexEx4Desc' => '\\d+ คือตัวเลขตั้งแต่หนึ่งหลักขึ้นไป — ตรงกับ "Ep.12"',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '\\d คือตัวเลข และ {4} หมายถึงตัวเลขสี่หลักเรียงกัน (เช่น ปี)',
			'settings.blockSettings.regexEx1Sample' => 'ทีเซอร์เกมใหม่มาแล้ว',
			'settings.blockSettings.regexEx2Sample' => '[Remux] ภาพยนตร์เต็มเรื่อง',
			'settings.blockSettings.regexEx3Sample' => 'คอลเลกชันงานศิลปะฤดูใบไม้ผลิ',
			'settings.blockSettings.regexEx4Sample' => 'รายการของฉัน ตอนที่12 สรุป',
			'settings.blockSettings.regexEx5Sample' => 'ที่สุดแห่งปี 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'ตัวอย่างชื่อเรื่อง',
			'settings.blockSettings.regexHelpMatchedTag' => 'ถูกบล็อก',
			'settings.blockSettings.regexHelpNoMatch' => 'ไม่ตรงกัน',
			'settings.blockSettings.regexEx6Pattern' => '[ซส]ีซั่น',
			'settings.blockSettings.regexEx6Desc' => '[Ss] ตรงกับตัว S พิมพ์ใหญ่หรือพิมพ์เล็ก — ในที่นี้ใช้จับคำว่า "Season"',
			'settings.blockSettings.regexEx6Sample' => 'ตัวอย่างซีซั่นสุดท้าย',
			'settings.blockSettings.regexEx7Pattern' => '(ภาพยนตร์|ซีรีส์)',
			'settings.blockSettings.regexEx7Desc' => 'วงเล็บ () จัดกลุ่มทางเลือก — ตรงกับ "the movie" หรือ "the series"',
			'settings.blockSettings.regexEx7Sample' => 'รับชมซีรีส์ตอนนี้',
			'settings.blockSettings.regexEx8Pattern' => 'ซีซั่น?',
			'settings.blockSettings.regexEx8Desc' => 's? ทำให้ตัวอักษรก่อนหน้าเป็นตัวเลือกเพิ่มเติม — ตรงกับ "season" และ "seasons"',
			'settings.blockSettings.regexEx8Sample' => 'แพ็กเกจสองซีซั่น',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ หมายถึงมีหนึ่งตัวหรือมากกว่า — ตรงกับ !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'สุดยอด!!! ต้องดู',
			'settings.blockSettings.regexEx10Pattern' => 'ตัวอย่าง.*ฉาก',
			'settings.blockSettings.regexEx10Desc' => '.* ตรงกับข้อความใดๆ ที่อยู่ระหว่างกลาง — "bonus … scene"',
			'settings.blockSettings.regexEx10Sample' => 'ตัวอย่าง ฉากที่ถูกลบ',
			'settings.chatSettings.name' => 'แชท',
			'settings.chatSettings.configureYourChatSettings' => 'กำหนดค่าการตั้งค่าแชทของคุณ',
			'settings.hardwareDecodingAuto' => 'อัตโนมัติ',
			'settings.hardwareDecodingAutoCopy' => 'คัดลอกอัตโนมัติ',
			'settings.hardwareDecodingAutoSafe' => 'ปลอดภัยอัตโนมัติ',
			'settings.hardwareDecodingNo' => 'ปิดใช้งาน',
			'settings.hardwareDecodingYes' => 'บังคับเปิดใช้งาน',
			'settings.cdnDistributionStrategy' => 'กลยุทธ์การกระจายเนื้อหา',
			'settings.cdnDistributionStrategyDesc' => 'เลือกกลยุทธ์การกระจายของเซิร์ฟเวอร์แหล่งที่มาของวิดีโอเพื่อปรับปรุงความเร็วในการโหลด',
			'settings.cdnDistributionStrategyLabel' => 'กลยุทธ์การกระจาย',
			'settings.cdnDistributionStrategyNoChange' => 'ไม่เปลี่ยนแปลง (ใช้เซิร์ฟเวอร์เดิม)',
			'settings.cdnDistributionStrategyAuto' => 'เลือกอัตโนมัติ (เซิร์ฟเวอร์ที่เร็วที่สุด)',
			'settings.cdnDistributionStrategySpecial' => 'ระบุเซิร์ฟเวอร์',
			'settings.cdnSpecialServer' => 'ระบุเซิร์ฟเวอร์',
			'settings.cdnRefreshServerListHint' => 'โปรดคลิกปุ่มด้านล่างเพื่อรีเฟรชรายการเซิร์ฟเวอร์',
			'settings.cdnRefreshButton' => 'รีเฟรช',
			'settings.cdnFastRingServers' => 'เซิร์ฟเวอร์วงแหวนเร็ว (Fast Ring)',
			'settings.cdnRefreshServerListTooltip' => 'รีเฟรชรายการเซิร์ฟเวอร์',
			'settings.cdnSpeedTestButton' => 'ทดสอบความเร็ว',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'กำลังทดสอบ (${count})',
			'settings.cdnNoServerDataHint' => 'ไม่มีข้อมูลเซิร์ฟเวอร์ โปรดคลิกปุ่มรีเฟรช',
			'settings.cdnTestingStatus' => 'กำลังทดสอบ',
			'settings.cdnUnreachableStatus' => 'ไม่สามารถเข้าถึงได้',
			'settings.cdnNotTestedStatus' => 'ยังไม่ได้ทดสอบ',
			'settings.downloadSettings.downloadSettings' => 'การตั้งค่าการดาวน์โหลด',
			'settings.downloadSettings.enableDownloadNotifications' => 'การแจ้งเตือนการดาวน์โหลด',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'แสดงการแจ้งเตือนของระบบเมื่อการดาวน์โหลดรายการหนึ่งเสร็จสิ้นหรือล้มเหลว',
			'settings.downloadSettings.notificationPermissionDenied' => 'การอนุญาตการแจ้งเตือนถูกปฏิเสธ การแจ้งเตือนในแอปยังคงทำงานอยู่ โปรดเปิดใช้การแจ้งเตือนของระบบในการตั้งค่า',
			'settings.downloadSettings.storagePermissionStatus' => 'สถานะสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'การเข้าถึงโฟลเดอร์สาธารณะจำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.checkingPermissionStatus' => 'กำลังตรวจสอบสถานะสิทธิ์...',
			'settings.downloadSettings.storagePermissionGranted' => 'ได้รับสิทธิ์การจัดเก็บข้อมูลแล้ว',
			'settings.downloadSettings.storagePermissionNotGranted' => 'ยังไม่ได้รับสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'อนุญาตสิทธิ์การจัดเก็บข้อมูลสำเร็จ',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'การอนุญาตสิทธิ์การจัดเก็บข้อมูลล้มเหลว ฟีเจอร์บางอย่างอาจถูกจำกัด',
			'settings.downloadSettings.storagePermissionRationale' => 'ในการบันทึกไฟล์ดาวน์โหลดลงในโฟลเดอร์ที่คุณเลือก แอปต้องได้รับสิทธิ์การจัดเก็บข้อมูล\n\nบน Android 11 ขึ้นไป หมายถึงสิทธิ์ "การเข้าถึงไฟล์ทั้งหมด" หากไม่มีสิทธิ์นี้ ไฟล์จะถูกบันทึกลงในโฟลเดอร์ส่วนตัวของแอปแทน',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'ในการบันทึกไฟล์ดาวน์โหลดลงในโฟลเดอร์ที่คุณเลือก แอปต้องได้รับสิทธิ์การจัดเก็บข้อมูล\n\nหากไม่ได้รับสิทธิ์ ไฟล์จะถูกบันทึกลงในโฟลเดอร์ส่วนตัวของแอปแทน',
			'settings.downloadSettings.grantStoragePermission' => 'อนุญาตสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.customDownloadPath' => 'เส้นทางดาวน์โหลดที่กำหนดเอง',
			'settings.downloadSettings.customDownloadPathDescription' => 'เมื่อเปิดใช้งาน คุณสามารถเลือกตำแหน่งบันทึกที่กำหนดเองสำหรับไฟล์ที่ดาวน์โหลดได้',
			'settings.downloadSettings.customDownloadPathTip' => '💡 คำแนะนำ: การเลือกไดเรกทอรีสาธารณะ (เช่น โฟลเดอร์ดาวน์โหลด) จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูล ขอแนะนำให้ใช้เส้นทางที่แนะนำก่อน',
			'settings.downloadSettings.androidWarning' => 'หมายเหตุ Android: หลีกเลี่ยงการเลือกไดเรกทอรีสาธารณะ (เช่น โฟลเดอร์ดาวน์โหลด) แนะนำให้ใช้ไดเรกทอรีเฉพาะของแอปเพื่อให้มั่นใจในสิทธิ์การเข้าถึง',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ ประกาศ: คุณเลือกไดเรกทอรีสาธารณะ จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลสำหรับการดาวน์โหลดไฟล์ตามปกติ',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลสำหรับไดเรกทอรีสาธารณะ',
			'settings.downloadSettings.currentDownloadPath' => 'เส้นทางดาวน์โหลดปัจจุบัน',
			'settings.downloadSettings.actualDownloadPath' => 'เส้นทางดาวน์โหลดจริง',
			'settings.downloadSettings.defaultAppDirectory' => 'ไดเรกทอรีเริ่มต้นของแอป',
			'settings.downloadSettings.permissionGranted' => 'ได้รับอนุญาตแล้ว',
			'settings.downloadSettings.permissionRequired' => 'จำเป็นต้องมีสิทธิ์',
			'settings.downloadSettings.enableCustomDownloadPath' => 'เปิดใช้เส้นทางดาวน์โหลดที่กำหนดเอง',
			'settings.downloadSettings.disableCustomDownloadPath' => 'ใช้เส้นทางเริ่มต้นของแอปเมื่อปิดใช้งาน',
			'settings.downloadSettings.customDownloadPathLabel' => 'เส้นทางดาวน์โหลดที่กำหนดเอง',
			'settings.downloadSettings.selectDownloadFolder' => 'เลือกโฟลเดอร์ดาวน์โหลด',
			'settings.downloadSettings.recommendedPath' => 'เส้นทางที่แนะนำ',
			'settings.downloadSettings.selectFolder' => 'เลือกโฟลเดอร์',
			'settings.downloadSettings.filenameTemplate' => 'แม่แบบชื่อไฟล์',
			'settings.downloadSettings.filenameTemplateDescription' => 'ปรับแต่งกฎการตั้งชื่อสำหรับไฟล์ที่ดาวน์โหลด รองรับการแทนที่ตัวแปร',
			'settings.downloadSettings.videoFilenameTemplate' => 'แม่แบบชื่อไฟล์วิดีโอ',
			'settings.downloadSettings.galleryFolderTemplate' => 'แม่แบบโฟลเดอร์แกลเลอรี',
			'settings.downloadSettings.imageFilenameTemplate' => 'แม่แบบชื่อไฟล์รูปภาพ',
			'settings.downloadSettings.resetToDefault' => 'รีเซ็ตเป็นค่าเริ่มต้น',
			'settings.downloadSettings.supportedVariables' => 'ตัวแปรที่รองรับ',
			'settings.downloadSettings.supportedVariablesDescription' => 'สามารถใช้ตัวแปรต่อไปนี้ในแม่แบบชื่อไฟล์ได้:',
			'settings.downloadSettings.copyVariable' => 'คัดลอกตัวแปร',
			'settings.downloadSettings.variableCopied' => 'คัดลอกตัวแปรแล้ว',
			'settings.downloadSettings.warningPublicDirectory' => 'คำเตือน: ไดเรกทอรีสาธารณะที่เลือกอาจไม่สามารถเข้าถึงได้ แนะนำให้เลือกไดเรกทอรีเฉพาะของแอป',
			'settings.downloadSettings.downloadPathUpdated' => 'อัปเดตเส้นทางดาวน์โหลดแล้ว',
			'settings.downloadSettings.selectPathFailed' => 'เลือกเส้นทางล้มเหลว',
			'settings.downloadSettings.pickerAlreadyActive' => 'ตัวเลือกโฟลเดอร์เปิดอยู่แล้ว',
			'settings.downloadSettings.unsupportedStorageVolume' => 'ไม่รองรับตำแหน่งจัดเก็บข้อมูลนี้ โปรดเลือกโฟลเดอร์ในที่จัดเก็บข้อมูลของอุปกรณ์หรือการ์ด SD',
			'settings.downloadSettings.recommendedPathSet' => 'ตั้งเป็นเส้นทางที่แนะนำแล้ว',
			'settings.downloadSettings.setRecommendedPathFailed' => 'ตั้งค่าเส้นทางที่แนะนำล้มเหลว',
			'settings.downloadSettings.templateResetToDefault' => 'รีเซ็ตเป็นแม่แบบเริ่มต้นแล้ว',
			'settings.downloadSettings.functionalTest' => 'การทดสอบการทำงาน',
			'settings.downloadSettings.testInProgress' => 'กำลังทดสอบ...',
			'settings.downloadSettings.runTest' => 'เรียกใช้การทดสอบ',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'ทดสอบว่าเส้นทางดาวน์โหลดและการกำหนดค่าสิทธิ์ทำงานได้อย่างถูกต้องหรือไม่',
			'settings.downloadSettings.testResults' => 'ผลการทดสอบ',
			'settings.downloadSettings.testCompleted' => 'การทดสอบเสร็จสมบูรณ์',
			'settings.downloadSettings.testMultisegmentDomain' => 'ตรวจสอบโดเมนค่า (หลายส่วน / เกินขีดจำกัด / รูปแบบหลบหนี)',
			'settings.downloadSettings.testMultisegmentPaths' => 'การเรนเดอร์โครงสร้างหลายส่วน (issue #126)',
			'settings.downloadSettings.testPassed' => 'รายการผ่าน',
			'settings.downloadSettings.testFailed' => 'การทดสอบล้มเหลว',
			'settings.downloadSettings.testStoragePermissionCheck' => 'การตรวจสอบสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.testStoragePermissionGranted' => 'ได้รับสิทธิ์การจัดเก็บข้อมูลแล้ว',
			'settings.downloadSettings.testStoragePermissionMissing' => 'ขาดสิทธิ์การจัดเก็บข้อมูล ฟีเจอร์บางอย่างอาจถูกจำกัด',
			'settings.downloadSettings.testPermissionCheckFailed' => 'ตรวจสอบสิทธิ์ล้มเหลว',
			'settings.downloadSettings.testDownloadPathValidation' => 'การตรวจสอบความถูกต้องของเส้นทางดาวน์โหลด',
			'settings.downloadSettings.testPathValidationFailed' => 'การตรวจสอบความถูกต้องของเส้นทางล้มเหลว',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'การตรวจสอบความถูกต้องของแม่แบบชื่อไฟล์',
			'settings.downloadSettings.testAllTemplatesValid' => 'แม่แบบทั้งหมดถูกต้อง',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'บางแม่แบบมีอักขระที่ไม่ถูกต้อง',
			'settings.downloadSettings.testTemplateValidationFailed' => 'การตรวจสอบแม่แบบล้มเหลว',
			'settings.downloadSettings.testDirectoryOperationTest' => 'การทดสอบการทำงานกับไดเรกทอรี',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'การสร้างไดเรกทอรีและการเขียนไฟล์เป็นปกติ',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'การดำเนินการกับไดเรกทอรีล้มเหลว',
			'settings.downloadSettings.testVideoTemplate' => 'แม่แบบวิดีโอ',
			'settings.downloadSettings.testGalleryTemplate' => 'แม่แบบแกลเลอรี',
			'settings.downloadSettings.testImageTemplate' => 'แม่แบบรูปภาพ',
			'settings.downloadSettings.testValid' => 'ถูกต้อง',
			'settings.downloadSettings.testInvalid' => 'ไม่ถูกต้อง',
			'settings.downloadSettings.testSuccess' => 'สำเร็จ',
			'settings.downloadSettings.testCorrect' => 'ถูกต้อง',
			'settings.downloadSettings.testError' => 'ข้อผิดพลาด',
			'settings.downloadSettings.testPath' => 'เส้นทางการทดสอบ',
			'settings.downloadSettings.testBasePath' => 'เส้นทางฐาน',
			'settings.downloadSettings.testDirectoryCreation' => 'การสร้างไดเรกทอรี',
			'settings.downloadSettings.testFileWriting' => 'การเขียนไฟล์',
			'settings.downloadSettings.testFileContent' => 'เนื้อหาไฟล์',
			'settings.downloadSettings.checkingPathStatus' => 'กำลังตรวจสอบสถานะเส้นทาง...',
			'settings.downloadSettings.unableToGetPathStatus' => 'ไม่สามารถรับสถานะเส้นทางได้',
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'หมายเหตุ: เส้นทางจริงแตกต่างจากเส้นทางที่เลือก',
			'settings.downloadSettings.grantPermission' => 'อนุญาตสิทธิ์',
			'settings.downloadSettings.fixIssue' => 'แก้ไขปัญหา',
			'settings.downloadSettings.issueFixed' => 'แก้ไขปัญหาแล้ว',
			'settings.downloadSettings.fixFailed' => 'แก้ไขล้มเหลว โปรดจัดการด้วยตนเอง',
			'settings.downloadSettings.lackStoragePermission' => 'ขาดสิทธิ์การจัดเก็บข้อมูล',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'ไม่สามารถเข้าถึงไดเรกทอรีสาธารณะได้ จำเป็นต้องมี "สิทธิ์การเข้าถึงไฟล์ทั้งหมด"',
			'settings.downloadSettings.cannotCreateDirectory' => 'ไม่สามารถสร้างไดเรกทอรีได้',
			'settings.downloadSettings.directoryNotWritable' => 'ไม่สามารถเขียนลงในไดเรกทอรีได้',
			'settings.downloadSettings.insufficientSpace' => 'พื้นที่ว่างไม่เพียงพอ',
			'settings.downloadSettings.pathValid' => 'เส้นทางถูกต้อง',
			'settings.downloadSettings.validationFailed' => 'การตรวจสอบล้มเหลว',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'กำลังใช้ไดเรกทอรีเริ่มต้นของแอป',
			'settings.downloadSettings.appPrivateDirectory' => 'ไดเรกทอรีส่วนตัวของแอป',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'ปลอดภัยและเชื่อถือได้ ไม่ต้องใช้สิทธิ์เพิ่มเติม',
			'settings.downloadSettings.downloadDirectory' => 'ไดเรกทอรีดาวน์โหลด',
			'settings.downloadSettings.downloadDirectoryDesc' => 'ตำแหน่งดาวน์โหลดเริ่มต้นของระบบ จัดการง่าย',
			'settings.downloadSettings.moviesDirectory' => 'ไดเรกทอรีภาพยนตร์',
			'settings.downloadSettings.moviesDirectoryDesc' => 'ไดเรกทอรีภาพยนตร์ของระบบ แอปสื่อสามารถรับรู้ได้',
			'settings.downloadSettings.documentsDirectory' => 'ไดเรกทอรีเอกสาร',
			'settings.downloadSettings.documentsDirectoryDesc' => 'ไดเรกทอรีเอกสารของแอป iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'จำเป็นต้องมีสิทธิ์การจัดเก็บข้อมูลเพื่อเข้าถึง',
			'settings.downloadSettings.recommendedPaths' => 'เส้นทางที่แนะนำ',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'ไดเรกทอรีส่วนตัวของแอปในพื้นที่จัดเก็บภายนอก',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'ไดเรกทอรีส่วนตัวของแอปในที่จัดเก็บภายนอก ผู้ใช้เข้าถึงได้ มีพื้นที่ขนาดใหญ่กว่า',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'ไดเรกทอรีส่วนตัวของแอปในพื้นที่จัดเก็บภายใน',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'ที่จัดเก็บภายในของแอป ไม่จำเป็นต้องมีสิทธิ์ มีขนาดพื้นที่น้อยกว่า',
			'settings.downloadSettings.appDocumentsDirectory' => 'ไดเรกทอรีเอกสารของแอป',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'ไดเรกทอรีเอกสารเฉพาะของแอป ปลอดภัยและเชื่อถือได้',
			'settings.downloadSettings.downloadsFolder' => 'โฟลเดอร์ดาวน์โหลด',
			'settings.downloadSettings.downloadsFolderDesc' => 'ไดเรกทอรีดาวน์โหลดเริ่มต้นของระบบ',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'เลือกตำแหน่งดาวน์โหลดที่แนะนำ',
			'settings.downloadSettings.noRecommendedPaths' => 'ไม่มีเส้นทางที่แนะนำ',
			'settings.downloadSettings.recommended' => 'แนะนำ',
			'settings.downloadSettings.requiresPermission' => 'ต้องใช้สิทธิ์',
			'settings.downloadSettings.authorizeAndSelect' => 'อนุญาตสิทธิ์และเลือก',
			'settings.downloadSettings.select' => 'เลือก',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'การอนุญาตสิทธิ์ล้มเหลว ไม่สามารถเลือกเส้นทางนี้ได้',
			'settings.downloadSettings.pathValidationFailed' => 'การตรวจสอบเส้นทางล้มเหลว',
			'settings.downloadSettings.downloadPathSetTo' => 'ตั้งค่าเส้นทางดาวน์โหลดเป็น',
			'settings.downloadSettings.setPathFailed' => 'ตั้งค่าเส้นทางล้มเหลว',
			'settings.downloadSettings.variableTitle' => 'ชื่อเรื่อง',
			'settings.downloadSettings.variableAuthorcache' => 'ชื่อแรกที่เคยเห็นของผู้สร้าง (ไม่เปลี่ยนตามการเปลี่ยนชื่อ)',
			'settings.downloadSettings.variableAuthor' => 'ชื่อผู้สร้าง',
			'settings.downloadSettings.variableUsername' => 'ชื่อผู้ใช้ของผู้สร้าง',
			'settings.downloadSettings.variableQuality' => 'คุณภาพวิดีโอ',
			'settings.downloadSettings.variableFilename' => 'ชื่อไฟล์ต้นฉบับ',
			'settings.downloadSettings.variableId' => 'รหัสเนื้อหา',
			'settings.downloadSettings.variableCount' => 'จำนวนรูปภาพในแกลเลอรี',
			'settings.downloadSettings.variableDate' => 'วันที่ปัจจุบัน (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'เวลาปัจจุบัน (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'วันที่และเวลาปัจจุบัน (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'การตั้งค่าการดาวน์โหลด',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'กำหนดค่าเส้นทางดาวน์โหลดและกฎการตั้งชื่อไฟล์',
			'settings.downloadSettings.suchAsTitleQuality' => 'ตัวอย่างเช่น: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'ตัวอย่างเช่น: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'ตัวอย่างเช่น: %title_%filename',
			'settings.downloadSettings.structureSection' => 'โครงสร้างการบันทึกและการตั้งชื่อ',
			'settings.downloadSettings.structureSectionDescription' => 'ไฟล์ที่ดาวน์โหลดจะถูกจัดเรียงลงโฟลเดอร์ย่อยตามรูปแบบที่เลือกด้านล่าง มีผลเฉพาะการดาวน์โหลดครั้งใหม่เท่านั้น ไฟล์เดิมไม่ถูกยุ่ง',
			'settings.downloadSettings.structureNoticeTitle' => 'ฟีเจอร์ใหม่: จัดเรียงตามผู้สร้างอัตโนมัติ',
			'settings.downloadSettings.structureNoticeBody' => 'เลือกด้านล่างได้เลย · มีผลเฉพาะไฟล์ที่ดาวน์โหลดใหม่ ไฟล์เดิมไม่ถูกยุ่ง',
			'settings.downloadSettings.presetFlat' => 'แบบราบ',
			'settings.downloadSettings.presetFlatDesc' => 'ไฟล์ทั้งหมดวางไว้ที่รากของโฟลเดอร์ดาวน์โหลดโดยตรง',
			'settings.downloadSettings.presetAuthor' => 'ตามผู้สร้าง',
			'settings.downloadSettings.presetAuthorBadge' => 'แนะนำ',
			'settings.downloadSettings.presetAuthorDesc' => 'โฟลเดอร์ละหนึ่งผู้สร้าง · เปลี่ยนชื่อแล้วไม่แยกโฟลเดอร์',
			'settings.downloadSettings.presetDate' => 'ตามวันที่',
			'settings.downloadSettings.presetDateDesc' => 'จัดเรียงตามวันที่ดาวน์โหลด',
			'settings.downloadSettings.presetCustomActive' => 'ใช้งานอยู่',
			'settings.downloadSettings.structurePreviewLabel' => 'ตัวอย่าง',
			'settings.downloadSettings.structurePreviewNote' => 'ส่วนที่มีสีคือระดับการจัดระเบียบ เปลี่ยนตามรูปแบบที่เลือกทันที',
			'settings.downloadSettings.pathTooLongWarning' => 'เส้นทางสัมพัทธ์เกิน 200 ตัวอักษร อาจบันทึกไม่สำเร็จบนอุปกรณ์บางรุ่น',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'เทมเพลตเส้นทางแบบกำหนดเอง',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'กำหนดโครงสร้างโฟลเดอร์และชื่อไฟล์ด้วยตัวเอง',
			'settings.downloadSettings.pathTemplateEditor.title' => 'เทมเพลตเส้นทาง',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'จัดโฟลเดอร์ให้ไฟล์ดาวน์โหลดอัตโนมัติ',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'วิดีโอ',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'แกลเลอรี',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'ภาพเดี่ยว',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'ตัวอย่าง · ผลลัพธ์จริงหลังทำความสะอาด',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'ตัวอย่าง · เทมเพลตแกลเลอรีคือชื่อโฟลเดอร์ (ภายในใช้ชื่อตามรหัสภาพ)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'เพิ่มระดับโฟลเดอร์',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'ถึงขีดจำกัดระดับโฟลเดอร์แล้ว',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache ตัวแปรหรือข้อความคงที่',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'เช่น %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'นามสกุล (.mp4) จะถูกเพิ่มอัตโนมัติ · พิมพ์ / ในส่วนจะแยกเป็นสองระดับ · สูงสุด ${max} ระดับ',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'นามสกุลเดิมจะถูกเพิ่มอัตโนมัติ · พิมพ์ / ในส่วนจะแยกเป็นสองระดับ · สูงสุด ${max} ระดับ',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'เทมเพลตแกลเลอรีเป็นส่วนโฟลเดอร์ทั้งหมด สูงสุด ${max} ระดับ · ภาพภายในใช้ชื่อตามรหัสภาพ',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'แตะเพื่อแทรกที่ตำแหน่งเคอร์เซอร์ · กดค้างเพื่อดูรายละเอียด',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'ส่วนว่าง',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'บันทึกไม่ได้: มีส่วนว่าง โปรดลบหรือกรอกเนื้อหา',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'บันทึกไม่ได้: ส่วนของพาธเกินขีดจำกัด (สูงสุด 4 ส่วน) โปรดรวมหรือลดลง',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'บันทึกไม่ได้: เทมเพลตมีอักขระที่ไม่อนุญาต',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'แทรกตัวแปรแล้ว',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'บันทึกแล้ว · มีผลเฉพาะการดาวน์โหลดใหม่เท่านั้น',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'เนื้อหา',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'ผู้สร้าง',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'เวลา',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'ชื่อผู้สร้าง·คงที่',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'วันที่',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'เวลา',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'วันที่และเวลา',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'ลำดับ',
			'favoriteTags.title' => 'แท็กโปรด',
			'favoriteTags.emptyIwara' => 'ยังไม่มีแท็ก Iwara ที่ชื่นชอบ',
			'favoriteTags.emptyOreno3d' => 'ยังไม่มีรายการโปรด',
			'favoriteTags.addIwaraTag' => 'เพิ่มแท็ก Iwara',
			'favoriteTags.quickPickHint' => 'รายการโปรดจะปรากฏเป็นตัวเลือกด่วนในการค้นหา',
			'favoriteTags.pickerTitle' => 'เลือก Oreno3D',
			'favoriteTags.searchHint' => 'ค้นหาด้วยชื่อหรือต้นฉบับ',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('th'))(n, one: '${n} ผลงาน', other: '${n} ผลงาน', ), 
			'favoriteTags.browseEntry' => 'เรียกดู ต้นฉบับ / ตัวละคร / แท็ก',
			'favoriteTags.favoritesSection' => 'รายการโปรด',
			'favoriteTags.addFavorite' => 'เพิ่ม',
			'favoriteTags.iwaraTitle' => 'แท็กโปรดของ Iwara',
			'favoriteTags.oreno3dTitle' => 'แท็กโปรดของ Oreno3D',
			'favoriteTags.changeTag' => 'เปลี่ยนแท็ก',
			'favoriteTags.switchToText' => 'ค้นหาด้วยข้อความ',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'แท็ก',
			'oreno3d.characters' => 'ตัวละคร',
			'oreno3d.origin' => 'ต้นฉบับ',
			'oreno3d.thirdPartyTagsExplanation' => 'ข้อมูล **แท็ก** **ตัวละคร** และ **ที่มา** ที่แสดงที่นี่จัดทำโดยเว็บไซต์บุคคลที่สาม **Oreno3D** เพื่อใช้อ้างอิงเท่านั้น\n\nเนื่องจากแหล่งข้อมูลนี้มีเฉพาะภาษาญี่ปุ่น จึงยังไม่รองรับการแปลหลายภาษา\n\nหากสนใจร่วมพัฒนาการแปลหลายภาษา เชิญที่รีโพซิทอรี',
			'oreno3d.sortTypes.hot' => 'กำลังฮิต',
			'oreno3d.sortTypes.favorites' => 'ถูกใจมาก',
			'oreno3d.sortTypes.latest' => 'ล่าสุด',
			'oreno3d.sortTypes.popularity' => 'ยอดนิยม',
			'oreno3d.errors.requestFailed' => 'คำขอล้มเหลว รหัสสถานะ',
			'oreno3d.errors.connectionTimeout' => 'หมดเวลาการเชื่อมต่อ โปรดตรวจสอบการเชื่อมต่อเครือข่าย',
			'oreno3d.errors.sendTimeout' => 'หมดเวลาส่งคำขอ',
			'oreno3d.errors.receiveTimeout' => 'หมดเวลาการรับคำตอบ',
			'oreno3d.errors.badCertificate' => 'การตรวจสอบใบรับรองล้มเหลว',
			'oreno3d.errors.resourceNotFound' => 'ไม่พบทรัพยากรที่ร้องขอ',
			'oreno3d.errors.accessDenied' => 'การเข้าถึงถูกปฏิเสธ อาจต้องมีการตรวจสอบสิทธิ์หรือการอนุญาต',
			'oreno3d.errors.serverError' => 'เซิร์ฟเวอร์เกิดข้อผิดพลาดภายใน',
			'oreno3d.errors.serviceUnavailable' => 'บริการไม่พร้อมใช้งานชั่วคราว',
			'oreno3d.errors.requestCancelled' => 'คำขอถูกยกเลิก',
			'oreno3d.errors.connectionError' => 'เกิดข้อผิดพลาดในการเชื่อมต่อเครือข่าย โปรดตรวจสอบการตั้งค่าเครือข่าย',
			'oreno3d.errors.networkRequestFailed' => 'คำขอเครือข่ายล้มเหลว',
			'oreno3d.errors.searchVideoError' => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะค้นหาวิดีโอ',
			'oreno3d.errors.getPopularVideoError' => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงข้อมูลวิดีโอยอดนิยม',
			'oreno3d.errors.getVideoDetailError' => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงรายละเอียดวิดีโอ',
			'oreno3d.errors.parseVideoDetailError' => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดึงและแยกวิเคราะห์รายละเอียดวิดีโอ',
			'oreno3d.errors.downloadFileError' => 'เกิดข้อผิดพลาดที่ไม่รู้จักขณะดาวน์โหลดไฟล์',
			'oreno3d.loading.gettingVideoInfo' => 'กำลังรับข้อมูลวิดีโอ...',
			'oreno3d.loading.cancel' => 'ยกเลิก',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'ไม่พบวิดีโอหรือวิดีโอถูกลบไปแล้ว',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'ไม่สามารถรับลิงก์สำหรับเล่นวิดีโอได้',
			'oreno3d.messages.getVideoDetailFailed' => 'รับรายละเอียดวิดีโอล้มเหลว',
			'signIn.pleaseLoginFirst' => 'โปรดเข้าสู่ระบบก่อน',
			'signIn.alreadySignedInToday' => 'วันนี้คุณได้ลงชื่อเข้าใช้แล้ว!',
			'signIn.youDidNotStickToTheSignIn' => 'คุณไม่ได้ลงชื่อเข้าใช้อย่างต่อเนื่อง',
			'signIn.signInSuccess' => 'ลงชื่อเข้าใช้สำเร็จ!',
			'signIn.signInFailed' => 'ลงชื่อเข้าใช้ล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'signIn.consecutiveSignIns' => 'การลงชื่อเข้าใช้ติดต่อกัน',
			'signIn.failureReason' => 'เหตุผลที่ล้มเหลว',
			'signIn.selectDateRange' => 'เลือกช่วงวันที่',
			'signIn.startDate' => 'วันที่เริ่มต้น',
			'signIn.endDate' => 'วันที่สิ้นสุด',
			'signIn.invalidDate' => 'รูปแบบวันที่ไม่ถูกต้อง',
			'signIn.invalidDateRange' => 'ช่วงวันที่ไม่ถูกต้อง',
			'signIn.errorFormatText' => 'รูปแบบวันที่ไม่ถูกต้อง',
			'signIn.errorInvalidText' => 'ช่วงวันที่ไม่ถูกต้อง',
			'signIn.errorInvalidRangeText' => 'ช่วงวันที่ไม่ถูกต้อง',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'ช่วงวันที่ต้องไม่เกิน 1 ปี',
			'signIn.signIn' => 'เช็คอิน',
			'signIn.signInRecord' => 'บันทึกการเช็คอิน',
			'signIn.totalSignIns' => 'การเช็คอินทั้งหมด',
			'signIn.pleaseSelectSignInStatus' => 'โปรดเลือกสถานะการเช็คอิน',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'โปรดเข้าสู่ระบบก่อนเพื่อดูการติดตามของคุณ',
			'subscriptions.selectUser' => 'เลือกผู้ใช้',
			'subscriptions.noSubscribedUsers' => 'ไม่มีผู้ใช้ที่ติดตาม',
			'subscriptions.showAllSubscribedUsersContent' => 'แสดงเนื้อหาของผู้ใช้ที่ติดตามทั้งหมด',
			'videoDetail.pipMode' => 'โหมดภาพซ้อนภาพ (PiP)',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'เล่นต่อจากตำแหน่งล่าสุด: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'เล่นต่อจาก ${position}',
			'videoDetail.restartFromBeginning' => 'เริ่มใหม่ตั้งแต่ต้น',
			'videoDetail.dismissResumeTip' => 'รับทราบ',
			'videoDetail.localInfo.videoInfo' => 'ข้อมูลวิดีโอ',
			'videoDetail.localInfo.currentQuality' => 'คุณภาพปัจจุบัน',
			'videoDetail.localInfo.duration' => 'ความยาว',
			'videoDetail.localInfo.resolution' => 'ความละเอียด',
			'videoDetail.localInfo.fileInfo' => 'ข้อมูลไฟล์',
			'videoDetail.localInfo.fileName' => 'ชื่อไฟล์',
			'videoDetail.localInfo.fileSize' => 'ขนาดไฟล์',
			'videoDetail.localInfo.filePath' => 'เส้นทางไฟล์',
			'videoDetail.localInfo.copyPath' => 'คัดลอกเส้นทาง',
			'videoDetail.localInfo.openFolder' => 'เปิดโฟลเดอร์',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'คัดลอกเส้นทางไปยังคลิปบอร์ดแล้ว',
			'videoDetail.localInfo.openFolderFailed' => 'เปิดโฟลเดอร์ล้มเหลว',
			'videoDetail.videoIdIsEmpty' => 'รหัสวิดีโอว่างเปล่า',
			'videoDetail.videoInfoIsEmpty' => 'ข้อมูลวิดีโอว่างเปล่า',
			'videoDetail.thisIsAPrivateVideo' => 'นี่เป็นวิดีโอส่วนตัว',
			'videoDetail.getVideoInfoFailed' => 'รับข้อมูลวิดีโอล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'videoDetail.noVideoSourceFound' => 'ไม่พบแหล่งที่มาของวิดีโอ',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'คัดลอกแท็ก "${tagId}" ไปยังคลิปบอร์ดแล้ว',
			'videoDetail.errorLoadingVideo' => 'เกิดข้อผิดพลาดขณะโหลดวิดีโอ',
			'videoDetail.play' => 'เล่น',
			'videoDetail.pause' => 'หยุดชั่วคราว',
			'videoDetail.exitAppFullscreen' => 'ออกจากเต็มหน้าจอแอป',
			'videoDetail.enterAppFullscreen' => 'เต็มหน้าจอแอป',
			'videoDetail.exitSystemFullscreen' => 'ออกจากเต็มหน้าจอระบบ',
			'videoDetail.enterSystemFullscreen' => 'เต็มหน้าจอระบบ',
			'videoDetail.seekTo' => 'ข้ามไปยัง',
			'videoDetail.switchResolution' => 'สลับความละเอียด',
			'videoDetail.switchPlaybackSpeed' => 'สลับความเร็วการเล่น',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'ย้อนกลับ ${num} วินาที',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'เดินหน้า ${num} วินาที',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'กำลังเล่นที่ความเร็ว ${rate}x',
			'videoDetail.brightness' => 'ความสว่าง',
			'videoDetail.brightnessLowest' => 'ความสว่างต่ำสุดแล้ว',
			'videoDetail.volume' => 'ระดับเสียง',
			'videoDetail.volumeMuted' => 'ปิดเสียงแล้ว',
			'videoDetail.restoreDefaultZoom' => 'คืนค่าเดิม',
			'videoDetail.gestureGuide.sampleVideo' => 'ตัวอย่างวิดีโอ',
			'videoDetail.gestureGuide.title' => 'คำแนะนำท่าทางและการโต้ตอบ',
			'videoDetail.gestureGuide.viewGuide' => 'คำแนะนำท่าทางและการโต้ตอบ',
			'videoDetail.gestureGuide.firstTimeIntro' => 'ใช้เวลาสักครู่เพื่อเรียนรู้ท่าทางควบคุมเครื่องเล่น คุณสามารถเปิดคู่มือนี้ได้ทุกเมื่อจากการตั้งค่าเครื่องเล่น',
			'videoDetail.gestureGuide.startWatching' => 'เข้าใจแล้ว เริ่มรับชม',
			'videoDetail.gestureGuide.basicTitle' => 'การควบคุมพื้นฐาน',
			'videoDetail.gestureGuide.zoomTitle' => 'ซูม / หมุน / เลื่อนภาพ',
			'videoDetail.gestureGuide.restoreTip' => 'แตะปุ่ม "คืนค่าเดิม" ที่ด้านล่างขวาเพื่อรีเซ็ตการซูม การหมุน และตำแหน่ง',
			'videoDetail.gestureGuide.mTap' => 'แตะครั้งเดียว: แสดง / ซ่อนส่วนควบคุม',
			'videoDetail.gestureGuide.mDoubleTap' => 'แตะสองครั้ง: ย้อนกลับ (ซ้าย) / หยุดชั่วคราว (กลาง) / เดินหน้า (ขวา)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'ปัดแนวนอน: เลื่อนหาตำแหน่ง',
			'videoDetail.gestureGuide.mVerticalDrag' => 'ปัดแนวตั้ง: ความสว่าง (ซ้าย) / ระดับเสียง (ขวา)',
			'videoDetail.gestureGuide.mLongPress' => 'กดค้าง: เร่งความเร็วชั่วคราว',
			'videoDetail.gestureGuide.mPinch' => 'หนีบสองนิ้ว: ซูมภาพ',
			'videoDetail.gestureGuide.mRotate' => 'หมุนสองนิ้ว: หมุนภาพ',
			'videoDetail.gestureGuide.dTap' => 'คลิก: แสดง / ซ่อนส่วนควบคุม',
			'videoDetail.gestureGuide.dDoubleTap' => 'ดับเบิลคลิก: ย้อนกลับ (ซ้าย) / หยุดชั่วคราว (กลาง) / เดินหน้า (ขวา)',
			'videoDetail.gestureGuide.dKeys' => 'แป้นเลื่อนหาตำแหน่ง: แตะเพื่อข้ามถอยหลัง / เดินหน้า กดค้างเพื่อเร่งความเร็ว; แป้นปรับความเร็ว: ปรับระดับความเร็วระหว่างการเล่นปกติ; Space: เล่น / หยุดชั่วคราว',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'หนีบนิ้วบนแทร็กแพด: ซูมภาพ',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'หมุนนิ้วบนแทร็กแพด: หมุนภาพ',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + ล้อเลื่อน: ซูมโดยอิงตามตำแหน่งเคอร์เซอร์',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + ล้อเลื่อน: หมุนโดยอิงตามตำแหน่งเคอร์เซอร์',
			'videoDetail.gestureGuide.quest.title' => 'คุ้นเคยกับการควบคุมบน Quest',
			'videoDetail.gestureGuide.quest.intro' => 'ดูว่าการควบคุมแต่ละอย่างทำอะไรได้บ้าง จากนั้นลองใช้งานในพื้นที่เสมือนของคุณ',
			'videoDetail.gestureGuide.quest.videoTab' => 'วิดีโอเชิงพื้นที่',
			'videoDetail.gestureGuide.quest.galleryTab' => 'แกลเลอรีเชิงพื้นที่',
			'videoDetail.gestureGuide.quest.scopeNote' => 'สำหรับหน้าจอและหน้าต่างในพื้นที่ Quest ของคุณ เปิดใหม่ได้ทุกเมื่อจากการตั้งค่าเครื่องเล่น',
			'videoDetail.gestureGuide.quest.catalog' => 'สำรวจการควบคุม',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} จาก ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'ก่อนหน้า',
			'videoDetail.gestureGuide.quest.next' => 'การควบคุมถัดไป',
			'videoDetail.gestureGuide.quest.replay' => 'เล่นการสาธิตซ้ำ',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'หยุดการสาธิตชั่วคราว',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'เล่นการสาธิตต่อ',
			'videoDetail.gestureGuide.quest.looping' => 'สาธิตการควบคุม',
			'videoDetail.gestureGuide.quest.still' => 'ภาพประกอบนิ่ง',
			'videoDetail.gestureGuide.quest.done' => 'เข้าใจแล้ว ดำเนินการต่อ',
			'videoDetail.gestureGuide.quest.leftController' => 'มือซ้าย',
			'videoDetail.gestureGuide.quest.rightController' => 'มือขวา',
			'videoDetail.gestureGuide.quest.trigger' => 'ไกชี้',
			'videoDetail.gestureGuide.quest.grip' => 'ปุ่มกริป',
			'videoDetail.gestureGuide.quest.bothGrips' => 'ปุ่มกริปทั้งสองข้าง',
			'videoDetail.gestureGuide.quest.stick' => 'ก้านอนาล็อก',
			'videoDetail.gestureGuide.quest.handTracking' => 'การติดตามมือ',
			'videoDetail.gestureGuide.quest.ready' => 'พร้อม',
			'videoDetail.gestureGuide.quest.press' => 'กด',
			'videoDetail.gestureGuide.quest.hold' => 'กดค้าง',
			'videoDetail.gestureGuide.quest.release' => 'ปล่อย',
			'videoDetail.gestureGuide.quest.result' => 'ดูผลลัพธ์',
			'videoDetail.gestureGuide.quest.pinch' => 'จีบนิ้ว',
			'videoDetail.gestureGuide.quest.selectTitle' => 'ชี้และเลือก',
			'videoDetail.gestureGuide.quest.selectBody' => 'เล็งลำแสงไปที่ปุ่ม จากนั้นกดแล้วปล่อยไกชี้ ใช้สำหรับเล่น ตั้งค่า และเลื่อนแถบเลื่อนบนแผงควบคุม',
			'videoDetail.gestureGuide.quest.selectHint' => 'ไกชี้อยู่ด้านหลังของปุ่ม ปุ่มกริปที่ด้ามจับด้านในใช้สำหรับจับหน้าต่าง',
			'videoDetail.gestureGuide.quest.panelTitle' => 'แสดงหรือซ่อนแผงควบคุม',
			'videoDetail.gestureGuide.quest.panelBody' => 'ชี้ออกไปนอกแผงควบคุม จากนั้นแตะไกชี้เพื่อแสดงหรือซ่อน เมื่อใช้การติดตามมือ การจีบนิ้วสั้นๆ นอกแผงควบคุมจะให้ผลเช่นเดียวกัน',
			'videoDetail.gestureGuide.quest.panelHint' => 'ใช้การแตะสั้นๆ โดยไม่ลาก การกดค้างแล้วขยับคือการลาก ไม่ใช่การสลับแผงควบคุม',
			'videoDetail.gestureGuide.quest.playTitle' => 'เล่นและหยุดชั่วคราว',
			'videoDetail.gestureGuide.quest.playBody' => 'ชี้ออกจากแผงควบคุมแล้วกดปุ่ม A ทางขวา หรือปุ่ม X ทางซ้ายเพื่อเล่นหรือหยุดชั่วคราว คุณยังสามารถเลือกปุ่มเล่นบนแผงควบคุมได้ด้วย',
			'videoDetail.gestureGuide.quest.playHint' => 'สามารถปิดแป้นพิมพ์ลัดเริ่มต้นนี้ได้ในการตั้งค่าเครื่องเล่นเชิงพื้นที่ เมื่อชี้ไปที่แผงควบคุม การป้อนข้อมูลจะส่งไปยังแผงควบคุม',
			'videoDetail.gestureGuide.quest.seekTitle' => 'เลื่อนตำแหน่งด้วยก้านอนาล็อก',
			'videoDetail.gestureGuide.quest.seekBody' => 'ดันก้านอนาล็อกไปทางซ้ายหรือขวาเพื่อข้ามทีละ 5 วินาที ดันค้างไว้เพื่อเลื่อนเร็วขึ้นพร้อมดูตัวอย่างเวลา ปล่อยเพื่อไปยังตำแหน่งที่เลือก',
			'videoDetail.gestureGuide.quest.seekHint' => 'อย่าให้ลำแสงของคอนโทรลเลอร์นั้นชี้ไปที่แผงควบคุม หากก้านอนาล็อกชี้ไปที่แผงควบคุมจะเป็นการเลื่อนแผงแทน',
			'videoDetail.gestureGuide.quest.browseTitle' => 'เรียกดูด้วยก้านอนาล็อก',
			'videoDetail.gestureGuide.quest.browseBody' => 'ขยับก้านอนาล็อกข้างใดก็ได้ไปทางซ้ายหรือขวาเพื่อดูรายการก่อนหน้าหรือถัดไป ดันค้างไว้เพื่อเรียกดูต่อเนื่อง คุณยังสามารถเลือกภาพขนาดย่อในแถบฟิล์มได้ด้วย',
			'videoDetail.gestureGuide.quest.browseHint' => 'วิดีโอในแกลเลอรีก็ถือเป็นรายการเช่นกัน การชี้ไปที่แผงควบคุมจะทำให้ก้านอนาล็อกเลื่อนเนื้อหาในแผงแทน',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'ลากเพื่อพลิกหน้า',
			'videoDetail.gestureGuide.quest.swipeBody' => 'เล็งไปที่รูปภาพ กดไกชี้ค้างไว้แล้วลากไปทางซ้าย ปล่อยหลังจากมีสัญญาณเปลี่ยนหน้าเพื่อไปข้างหน้า ลากไปทางขวาเพื่อย้อนกลับ การจีบนิ้วแล้วลากก็ใช้ได้เช่นกัน',
			'videoDetail.gestureGuide.quest.swipeHint' => 'รูปภาพต้องอยู่ที่ขนาด 1× จึงจะเปลี่ยนหน้าด้วยการลากได้ วิดีโอในแกลเลอรีก็รองรับเช่นกัน หน้าจอจะอยู่นิ่งจนกว่าคุณจะปล่อย',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'ซูมดูรายละเอียดรูปภาพ',
			'videoDetail.gestureGuide.quest.zoomBody' => 'เล็งไปที่รายละเอียดในภาพ กดไกชี้ค้างไว้ แล้วดันก้านอนาล็อกขึ้นเพื่อซูมเข้า หรือลงเพื่อซูมออก การซูมจะยึดตำแหน่งที่คุณกดไว้',
			'videoDetail.gestureGuide.quest.zoomHint' => 'การดำเนินการนี้จะขยายรูปภาพภายในหน้าต่าง หากไม่ได้จับรูปภาพไว้ การดันขึ้น/ลงจะเป็นการปรับระยะการมอง',
			'videoDetail.gestureGuide.quest.panTitle' => 'เลื่อนและคืนค่ารูปภาพ',
			'videoDetail.gestureGuide.quest.panBody' => 'เมื่อซูมเข้าแล้ว ให้กดไกชี้ค้างไว้แล้วลากเพื่อดูรอบๆ แตะสองครั้งที่รูปภาพเพื่อซูมเป็น 2.5× หรือคืนค่าเดิม สำหรับมือ ให้จีบนิ้วสองครั้งอย่างรวดเร็ว',
			'videoDetail.gestureGuide.quest.panHint' => 'การลากจะเป็นการเลื่อนดูภาพที่ซูมอยู่ คืนค่าเป็น 1× ก่อนลากเพื่อเปลี่ยนหน้า',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'เริ่มการฉายสไลด์',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'เมื่อดูรูปภาพ กดปุ่ม A / X เพื่อเริ่มหรือหยุดการฉายสไลด์ชั่วคราว แผงควบคุมมีช่วงเวลา 3, 5, 10 หรือ 20 วินาที และคุณภาพของภาพแบบมาตรฐานหรือต้นฉบับ',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'ในวิดีโอของแกลเลอรี ปุ่ม A / X จะควบคุมการเล่นของวิดีโอนั้น ต้องเปิดใช้งานปุ่มลัดของคอนโทรลเลอร์ในการตั้งค่าก่อน',
			'videoDetail.gestureGuide.quest.moveTitle' => 'จับและย้ายหน้าจอ',
			'videoDetail.gestureGuide.quest.moveBody' => 'กดปุ่มกริปที่ด้ามจับด้านในค้างไว้ ขยับคอนโทรลเลอร์เพื่อจัดตำแหน่งหน้าจอ จากนั้นจึงปล่อย ขณะรับชม คุณสามารถจับหน้าจอได้โดยไม่ต้องเล็งไปที่หน้าจอ',
			'videoDetail.gestureGuide.quest.moveHint' => 'การเล็งไปที่หน้าต่างแอปหรือแผงควบคุมจะจับหน้าต่างนั้นก่อน ในวิดีโอแบบพาโนรามา การจับจะใช้ปรับทิศทางการมอง',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'ปรับขนาดด้วยสองมือ',
			'videoDetail.gestureGuide.quest.scaleBody' => 'กดปุ่มกริปทั้งสองข้างค้างไว้ กางมือออกเพื่อขยายหน้าจอ หรือดึงมือเข้าหากันเพื่อย่อหน้าจอ เมื่อใช้การติดตามมือ ให้จีบนิ้วค้างไว้ทั้งสองมือ',
			'videoDetail.gestureGuide.quest.scaleHint' => 'สำหรับหน้าจอแบนหรือโค้ง รวมถึงเวทีแกลเลอรี อย่าให้ลำแสงชี้ไปที่แผงควบคุม การทำเช่นนี้จะปรับขนาดของทั้งหน้าจอ',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'ปรับระยะการมอง',
			'videoDetail.gestureGuide.quest.distanceBody' => 'ดันก้านอนาล็อกขึ้นเพื่อเลื่อนหน้าจอออกไปไกลขึ้น หรือดันลงเพื่อดึงเข้ามาใกล้ขึ้น ขณะจับหน้าต่าง การดันขึ้น/ลงจะเลื่อนหน้าต่างนั้น ปรับระดับเสียงได้ที่แผงควบคุม',
			'videoDetail.gestureGuide.quest.distanceHint' => 'ชี้ออกจากแผงควบคุม การจับรูปภาพไว้จะเปลี่ยนการดันขึ้น/ลงเป็นการซูมรูปภาพ ส่วนวิดีโอพาโนรามาจะปรับมุมมองแทน',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'ใช้ขอบและมุม',
			'videoDetail.gestureGuide.quest.resizeBody' => 'กรอบจะสว่างขึ้นเมื่อลำแสงของคุณเข้าใกล้ขอบ กดไกชี้ค้างไว้หรือจีบนิ้วที่ขอบเพื่อย้ายหน้าต่าง ลากมุมเพื่อปรับขนาด',
			'videoDetail.gestureGuide.quest.resizeHint' => 'ใช้ได้กับหน้าต่างแอป แผงควบคุม และหน้าจอ หน้าต่างแอปสามารถปรับความกว้างและความสูงได้ ส่วนหน้าจอจะรักษาอัตราส่วนภาพไว้',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'ย้อนกลับและเปิดการตั้งค่า',
			'videoDetail.gestureGuide.quest.navigationBody' => 'ปุ่ม B / Y ใช้ย้อนกลับหนึ่งระดับ: ปิดป๊อปอัปหรือกลับสู่หน้าแรกของแผงควบคุม ซ่อนแผงควบคุม แล้วกลับสู่แอป ปุ่ม Menu ด้านซ้ายเปิดการตั้งค่าเชิงพื้นที่',
			'videoDetail.gestureGuide.quest.navigationHint' => 'ปุ่ม Meta ด้านขวาเป็นของระบบ การตั้งศูนย์ระบบใหม่จะนำมุมมองกลับมาอยู่ข้างหน้าโดยยังคงขนาดและระยะห่างของหน้าจอไว้',
			'videoDetail.gestureGuide.quest.handsTitle' => 'ใช้มือของคุณ',
			'videoDetail.gestureGuide.quest.handsBody' => 'เมื่อเปิดใช้งานการติดตามมือ ให้เล็งลำแสงของระบบไปที่ปุ่ม จีบนิ้วหัวแม่มือและนิ้วชี้เข้าหากัน แล้วปล่อย ใช้แผงควบคุมสำหรับการเล่น การเลื่อนหาตำแหน่ง และการนำทางแกลเลอรี',
			'videoDetail.gestureGuide.quest.handsHint' => 'จีบนิ้วนอกจากแผงควบคุมเพื่อเปิด/ปิดแผง จีบนิ้วที่ขอบเพื่อย้าย ที่มุมเพื่อปรับขนาด หรือจีบนิ้วทั้งสองมือแล้วกางออกเพื่อขยายหน้าจอ',
			'videoDetail.home' => 'หน้าแรก',
			'videoDetail.videoPlayer' => 'เครื่องเล่นวิดีโอ',
			'videoDetail.videoPlayerInfo' => 'ข้อมูลเครื่องเล่นวิดีโอ',
			'videoDetail.moreSettings' => 'การตั้งค่าเพิ่มเติม',
			'videoDetail.videoPlayerFeatureInfo' => 'ข้อมูลฟีเจอร์ของเครื่องเล่นวิดีโอ',
			'videoDetail.autoRewind' => 'กรอถอยหลังอัตโนมัติ',
			'videoDetail.rewindAndFastForward' => 'ย้อนกลับและเดินหน้าอย่างเร็ว',
			'videoDetail.volumeAndBrightness' => 'ระดับเสียงและความสว่าง',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'แตะสองครั้งบริเวณตรงกลางเพื่อหยุดหรือเล่น',
			'videoDetail.showVerticalVideoInFullScreen' => 'แสดงวิดีโอแนวตั้งในโหมดเต็มหน้าจอ',
			'videoDetail.keepLastVolumeAndBrightness' => 'รักษาระดับเสียงและความสว่างล่าสุดไว้',
			'videoDetail.setProxy' => 'ตั้งค่าพร็อกซี',
			'videoDetail.moreFeaturesToBeDiscovered' => 'ฟีเจอร์เพิ่มเติมรอให้คุณค้นพบ...',
			'videoDetail.videoPlayerSettings' => 'การตั้งค่าเครื่องเล่นวิดีโอ',
			'videoDetail.commentCount' => ({required Object num}) => '${num} ความคิดเห็น',
			'videoDetail.writeYourCommentHere' => 'เขียนความคิดเห็นของคุณที่นี่...',
			'videoDetail.authorOtherVideos' => 'วิดีโออื่นของผู้สร้าง',
			'videoDetail.relatedVideos' => 'วิดีโอที่เกี่ยวข้อง',
			'videoDetail.privateVideo' => 'นี่เป็นวิดีโอส่วนตัว',
			'videoDetail.externalVideo' => 'นี่เป็นวิดีโอภายนอก',
			'videoDetail.openInBrowser' => 'เปิดในเบราว์เซอร์',
			'videoDetail.resourceDeleted' => 'วิดีโอนี้ดูเหมือนจะถูกลบไปแล้ว :/',
			'videoDetail.noDownloadUrl' => 'ไม่มี URL ดาวน์โหลด',
			'videoDetail.startDownloading' => 'เริ่มดาวน์โหลด',
			'videoDetail.downloadFailed' => 'ดาวน์โหลดล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'videoDetail.downloadSuccess' => 'ดาวน์โหลดสำเร็จ',
			'videoDetail.download' => 'ดาวน์โหลด',
			'videoDetail.downloadManager' => 'ตัวจัดการการดาวน์โหลด',
			'videoDetail.resourceNotFound' => 'ไม่พบทรัพยากร',
			'videoDetail.videoLoadError' => 'เกิดข้อผิดพลาดในการโหลดวิดีโอ',
			'videoDetail.authorNoOtherVideos' => 'ผู้สร้างไม่มีวิดีโออื่น',
			'videoDetail.noRelatedVideos' => 'ไม่มีวิดีโอที่เกี่ยวข้อง',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'เกิดข้อผิดพลาดขณะโหลดแหล่งที่มาของวิดีโอ',
			'videoDetail.player.errorWhileSettingUpListeners' => 'เกิดข้อผิดพลาดขณะตั้งค่าตัวรับฟังเหตุการณ์',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'ตรวจพบข้อผิดพลาดของเซิร์ฟเวอร์ สลับเส้นทางและลองใหม่โดยอัตโนมัติ',
			'videoDetail.skeleton.fetchingVideoInfo' => 'กำลังดึงข้อมูลวิดีโอ...',
			'videoDetail.skeleton.fetchingVideoSources' => 'กำลังดึงแหล่งที่มาของวิดีโอ...',
			'videoDetail.skeleton.loadingVideo' => 'กำลังโหลดวิดีโอ...',
			'videoDetail.skeleton.applyingSolution' => 'กำลังนำการตั้งค่าความละเอียดนี้ไปใช้...',
			'videoDetail.skeleton.addingListeners' => 'กำลังเพิ่มตัวรับฟังเหตุการณ์...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'ดึงข้อมูลความยาววิดีโอสำเร็จ เริ่มโหลดวิดีโอ...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'โหลดเสร็จสมบูรณ์',
			'videoDetail.cast.dlnaCast' => 'แคสต์',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'เริ่มค้นหาอุปกรณ์แคสต์ล้มเหลว: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'เริ่มแคสต์ไปยัง ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'แคสต์ล้มเหลว: ${error}\nโปรดลองค้นหาอุปกรณ์ใหม่อีกครั้งหรือเปลี่ยนเครือข่าย',
			'videoDetail.cast.castStopped' => 'หยุดแคสต์แล้ว',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'เครื่องเล่นสื่อ',
			'videoDetail.cast.deviceTypes.mediaServer' => 'เซิร์ฟเวอร์สื่อ',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'เราเตอร์',
			'videoDetail.cast.deviceTypes.basicDevice' => 'อุปกรณ์พื้นฐาน',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'ไฟอัจฉริยะ',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'จุดเชื่อมต่อ WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'อุปกรณ์เชื่อมต่อ WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'เครื่องพิมพ์',
			'videoDetail.cast.deviceTypes.scanner' => 'เครื่องสแกน',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'กล้องวงจรปิดดิจิทัล',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'อุปกรณ์ที่ไม่รู้จัก',
			'videoDetail.cast.currentPlatformNotSupported' => 'แพลตฟอร์มปัจจุบันไม่รองรับการแคสต์',
			'videoDetail.cast.unableToGetVideoUrl' => 'ไม่สามารถรับที่อยู่วิดีโอได้ โปรดลองอีกครั้งในภายหลัง',
			'videoDetail.cast.stopCasting' => 'หยุดแคสต์',
			'videoDetail.cast.dlnaCastSheet.title' => 'รีโมตแคสต์',
			'videoDetail.cast.dlnaCastSheet.close' => 'ปิด',
			_ => null,
		} ?? switch (path) {
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'กำลังค้นหาอุปกรณ์...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'คลิกปุ่มค้นหาเพื่อค้นหาอุปกรณ์แคสต์อีกครั้ง',
			'videoDetail.cast.dlnaCastSheet.searching' => 'กำลังค้นหา',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'ค้นหาอีกครั้ง',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'ไม่พบอุปกรณ์แคสต์\nโปรดตรวจสอบให้แน่ใจว่าอุปกรณ์อยู่ในเครือข่ายเดียวกัน',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'กำลังค้นหาอุปกรณ์ โปรดรอสักครู่...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'แคสต์',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'เชื่อมต่อกับ: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'ไม่ได้เชื่อมต่ออุปกรณ์',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'หยุดแคสต์',
			'videoDetail.likeAvatars.dialogTitle' => 'ใครแอบมากดถูกใจ',
			'videoDetail.likeAvatars.dialogDescription' => 'สงสัยไหมว่าพวกเขาคือใคร? ลองเปิดดู "อัลบั้มการกดถูกใจ" นี้สิ~',
			'videoDetail.likeAvatars.closeTooltip' => 'ปิด',
			'videoDetail.likeAvatars.retry' => 'ลองใหม่',
			'videoDetail.likeAvatars.noLikesYet' => 'ยังไม่มีใครปรากฏที่นี่ มาเป็นคนแรกกันเถอะ!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'หน้า ${page} / ${totalPages} · รวม ${totalCount} คน',
			'videoDetail.likeAvatars.prevPage' => 'หน้าก่อนหน้า',
			'videoDetail.likeAvatars.nextPage' => 'หน้าถัดไป',
			'share.sharePlayList' => 'แชร์เพลย์ลิสต์',
			'share.wowDidYouSeeThis' => 'ว้าว คุณเคยดูอันนี้หรือยัง?',
			'share.nameIs' => 'ชื่อคือ',
			'share.clickLinkToView' => 'คลิกที่ลิงก์เพื่อดู',
			'share.iReallyLikeThis' => 'ฉันชอบสิ่งนี้จริงๆ คุณก็ลองมาดูสิ!',
			'share.shareFailed' => 'การแชร์ล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'share.share' => 'แชร์',
			'share.shareAsImage' => 'แชร์เป็นรูปภาพ',
			'share.shareAsText' => 'แชร์เป็นข้อความ',
			'share.shareAsImageDesc' => 'แชร์หน้าปกวิดีโอเป็นรูปภาพ',
			'share.shareAsTextDesc' => 'แชร์รายละเอียดวิดีโอเป็นข้อความ',
			'share.shareAsImageFailed' => 'แชร์หน้าปกวิดีโอเป็นรูปภาพล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'share.shareAsTextFailed' => 'แชร์รายละเอียดวิดีโอเป็นข้อความล้มเหลว โปรดลองใหม่อีกครั้งในภายหลัง',
			'share.shareVideo' => 'แชร์วิดีโอ',
			'share.authorIs' => 'ผู้สร้างคือ',
			'share.shareGallery' => 'แชร์แกลเลอรี',
			'share.galleryTitleIs' => 'ชื่อแกลเลอรีคือ',
			'share.galleryAuthorIs' => 'ผู้สร้างแกลเลอรีคือ',
			'share.shareUser' => 'แชร์ผู้ใช้',
			'share.userNameIs' => 'ชื่อผู้ใช้คือ',
			'share.userAuthorIs' => 'ผู้สร้างคือ',
			'share.comments' => 'ความคิดเห็น',
			'share.shareThread' => 'แชร์กระทู้',
			'share.views' => 'การดู',
			'share.sharePost' => 'แชร์โพสต์',
			'share.postTitleIs' => 'ชื่อเรื่องของโพสต์คือ',
			'share.postAuthorIs' => 'ผู้สร้างโพสต์คือ',
			'markdown.markdownSyntax' => 'ไวยากรณ์ Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'ไวยากรณ์ Markdown พิเศษของ Iwara',
			'markdown.internalLink' => 'ลิงก์ภายในเว็บไซต์',
			'markdown.supportAutoConvertLinkBelow' => 'รองรับการแปลงลิงก์ต่อไปนี้โดยอัตโนมัติ:',
			'markdown.convertLinkExample' => '🎬 ลิงก์วิดีโอ\n🖼️ ลิงก์รูปภาพ\n👤 ลิงก์ผู้ใช้\n📌 ลิงก์ฟอรัม\n🎵 ลิงก์เพลย์ลิสต์\n💬 ลิงก์กระทู้',
			'markdown.mentionUser' => 'กล่าวถึงผู้ใช้',
			'markdown.mentionUserDescription' => 'พิมพ์ @ ตามด้วยชื่อผู้ใช้ ระบบจะแปลงเป็นลิงก์ผู้ใช้โดยอัตโนมัติ',
			'markdown.markdownBasicSyntax' => 'ไวยากรณ์พื้นฐานของ Markdown',
			'markdown.paragraphAndLineBreak' => 'ย่อหน้าและการขึ้นบรรทัดใหม่',
			'markdown.paragraphAndLineBreakDescription' => 'แยกย่อหน้าด้วยการเว้นหนึ่งบรรทัด และการเว้นสองช่องว่างที่ท้ายบรรทัดจะแปลงเป็นการขึ้นบรรทัดใหม่',
			'markdown.paragraphAndLineBreakSyntax' => 'นี่คือย่อหน้าแรก\n\nนี่คือย่อหน้าที่สอง\nบรรทัดนี้ลงท้ายด้วยสองช่องว่าง  \nจะถูกแปลงเป็นการขึ้นบรรทัดใหม่',
			'markdown.textStyle' => 'สไตล์ข้อความ',
			'markdown.textStyleDescription' => 'ใช้สัญลักษณ์พิเศษล้อมรอบข้อความเพื่อเปลี่ยนรูปแบบ',
			'markdown.textStyleSyntax' => '**ข้อความตัวหนา**\n*ข้อความตัวเอียง*\n~~ข้อความขีดฆ่า~~\n`ข้อความโค้ด`',
			'markdown.quote' => 'การอ้างอิง',
			'markdown.quoteDescription' => 'ใช้สัญลักษณ์ > เพื่อสร้างการอ้างอิง ใช้หลายตัว > เพื่อสร้างการอ้างอิงหลายระดับ',
			'markdown.quoteSyntax' => '> นี่คือการอ้างอิงระดับแรก\n>> นี่คือการอ้างอิงระดับที่สอง',
			'markdown.list' => 'รายการ',
			'markdown.listDescription' => 'สร้างรายการแบบมีลำดับด้วย ตัวเลข+จุด สร้างรายการแบบไม่มีลำดับด้วย -',
			'markdown.listSyntax' => '1. รายการแรก\n2. รายการที่สอง\n\n- รายการแบบไม่มีลำดับ\n  - รายการย่อย\n  - อีกหนึ่งรายการย่อย',
			'markdown.linkAndImage' => 'ลิงก์และรูปภาพ',
			'markdown.linkAndImageDescription' => 'รูปแบบลิงก์: [ข้อความ](URL)\nรูปแบบรูปภาพ: ![คำอธิบาย](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[ข้อความลิงก์](${link})\n![คำอธิบายรูปภาพ](${imgUrl})',
			'markdown.title' => 'หัวข้อ',
			'markdown.titleDescription' => 'ใช้สัญลักษณ์ # เพื่อสร้างหัวข้อ จำนวนสัญลักษณ์แสดงถึงระดับ',
			'markdown.titleSyntax' => '# หัวข้อระดับ 1\n## หัวข้อระดับ 2\n### หัวข้อระดับ 3',
			'markdown.separator' => 'เส้นคั่น',
			'markdown.separatorDescription' => 'สร้างเส้นคั่นด้วยสัญลักษณ์ - สามตัวขึ้นไป',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'ไวยากรณ์',
			'forum.attachQuote' => 'แนบการอ้างอิง',
			'forum.replyToFloor' => ({required Object floor, required Object username}) => 'ตอบกลับ #${floor} @${username}',
			'forum.removeQuote' => 'ลบการอ้างอิง',
			'forum.recent' => 'ล่าสุด',
			'forum.category' => 'หมวดหมู่',
			'forum.lastReply' => 'ตอบกลับล่าสุด',
			'forum.sitewide.badge' => 'ทั้งเว็บไซต์',
			'forum.sitewide.title' => 'ประกาศทั่วทั้งเว็บไซต์',
			'forum.sitewide.readMore' => 'อ่านเพิ่มเติม',
			'forum.errors.pleaseSelectCategory' => 'โปรดเลือกหมวดหมู่',
			'forum.errors.threadLocked' => 'กระทู้นี้ถูกล็อก ไม่สามารถตอบกลับได้',
			'forum.createPost' => 'สร้างโพสต์',
			'forum.title' => 'ชื่อเรื่อง',
			'forum.enterTitle' => 'ป้อนชื่อเรื่อง',
			'forum.content' => 'เนื้อหา',
			'forum.enterContent' => 'ป้อนเนื้อหา',
			'forum.writeYourContentHere' => 'เขียนเนื้อหาของคุณที่นี่...',
			'forum.posts' => 'โพสต์',
			'forum.threads' => 'กระทู้',
			'forum.forum' => 'ฟอรัม',
			'forum.createThread' => 'สร้างกระทู้',
			'forum.selectCategory' => 'เลือกหมวดหมู่',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'เหลือเวลาคูลดาวน์อีก ${minutes} นาที ${seconds} วินาที',
			'forum.groups.administration' => 'ฝ่ายบริหาร',
			'forum.groups.global' => 'ทั่วโลก',
			'forum.groups.chinese' => 'ภาษาจีน',
			'forum.groups.japanese' => 'ภาษาญี่ปุ่น',
			'forum.groups.korean' => 'ภาษาเกาหลี',
			'forum.groups.other' => 'อื่นๆ',
			'forum.leafNames.announcements' => 'ประกาศ',
			'forum.leafNames.feedback' => 'ข้อเสนอแนะ',
			'forum.leafNames.support' => 'ความช่วยเหลือ',
			'forum.leafNames.general' => 'ทั่วไป',
			'forum.leafNames.guides' => 'คู่มือ',
			'forum.leafNames.questions' => 'คำถาม',
			'forum.leafNames.requests' => 'คำขอ',
			'forum.leafNames.sharing' => 'การแบ่งปัน',
			'forum.leafNames.general_zh' => 'ทั่วไป',
			'forum.leafNames.questions_zh' => 'คำถาม',
			'forum.leafNames.requests_zh' => 'คำขอ',
			'forum.leafNames.support_zh' => 'ความช่วยเหลือ',
			'forum.leafNames.general_ja' => 'ทั่วไป',
			'forum.leafNames.questions_ja' => 'คำถาม',
			'forum.leafNames.requests_ja' => 'คำขอ',
			'forum.leafNames.support_ja' => 'ความช่วยเหลือ',
			'forum.leafNames.korean' => 'ภาษาเกาหลี',
			'forum.leafNames.other' => 'อื่นๆ',
			'forum.leafDescriptions.announcements' => 'ประกาศและแจ้งเตือนสำคัญอย่างเป็นทางการ',
			'forum.leafDescriptions.feedback' => 'ข้อเสนอแนะเกี่ยวกับฟีเจอร์และบริการของเว็บไซต์',
			'forum.leafDescriptions.support' => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์',
			'forum.leafDescriptions.general' => 'พูดคุยในทุกหัวข้อ',
			'forum.leafDescriptions.guides' => 'แบ่งปันประสบการณ์และบทเรียนของคุณ',
			'forum.leafDescriptions.questions' => 'สอบถามข้อสงสัยของคุณ',
			'forum.leafDescriptions.requests' => 'โพสต์คำขอของคุณ',
			'forum.leafDescriptions.sharing' => 'แบ่งปันเนื้อหาที่น่าสนใจ',
			'forum.leafDescriptions.general_zh' => 'พูดคุยในทุกหัวข้อ',
			'forum.leafDescriptions.questions_zh' => 'สอบถามข้อสงสัยของคุณ',
			'forum.leafDescriptions.requests_zh' => 'โพสต์คำขอของคุณ',
			'forum.leafDescriptions.support_zh' => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์',
			'forum.leafDescriptions.general_ja' => 'พูดคุยในทุกหัวข้อ',
			'forum.leafDescriptions.questions_ja' => 'สอบถามข้อสงสัยของคุณ',
			'forum.leafDescriptions.requests_ja' => 'โพสต์คำขอของคุณ',
			'forum.leafDescriptions.support_ja' => 'ช่วยเหลือในการแก้ไขปัญหาที่เกี่ยวข้องกับเว็บไซต์',
			'forum.leafDescriptions.korean' => 'การพูดคุยที่เกี่ยวข้องกับภาษาเกาหลี',
			'forum.leafDescriptions.other' => 'เนื้อหาอื่นๆ ที่ไม่ได้จัดหมวดหมู่',
			'forum.reply' => 'ตอบกลับ',
			'forum.pendingReview' => 'กำลังรอการตรวจสอบ',
			'forum.floorNotFound' => 'ไม่พบความคิดเห็นนี้หรือถูกลบไปแล้ว',
			'forum.floorNotLoadedYet' => 'ความคิดเห็นนี้อยู่ด้านบน โหลดเพิ่มเติมเพื่อข้ามไป',
			'forum.editedAt' => 'แก้ไขเมื่อ',
			'forum.copySuccess' => 'คัดลอกไปยังคลิปบอร์ดแล้ว',
			'forum.copySuccessForMessage' => ({required Object str}) => 'คัดลอกไปยังคลิปบอร์ดแล้ว: ${str}',
			'forum.editReply' => 'แก้ไขการตอบกลับ',
			'forum.editTitle' => 'แก้ไขชื่อเรื่อง',
			'forum.submit' => 'ส่ง',
			'notifications.errors.unsupportedNotificationType' => 'ไม่รองรับประเภทการแจ้งเตือนนี้',
			'notifications.errors.unknownUser' => 'ผู้ใช้ที่ไม่รู้จัก',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'ไม่รองรับประเภทการแจ้งเตือน: ${type}',
			'notifications.errors.unknownNotificationType' => 'ประเภทการแจ้งเตือนที่ไม่รู้จัก',
			'notifications.notifications' => 'การแจ้งเตือน',
			'notifications.profile' => 'หน้าโปรไฟล์',
			'notifications.postedNewComment' => 'แสดงความคิดเห็นใหม่',
			'notifications.inYour' => 'ใน',
			'notifications.video' => 'วิดีโอ',
			'notifications.repliedYourVideoComment' => 'ตอบกลับความคิดเห็นวิดีโอของคุณ',
			'notifications.copyInfoToClipboard' => 'คัดลอกข้อมูลการแจ้งเตือนไปยังคลิปบอร์ด',
			'notifications.copySuccess' => 'คัดลอกไปยังคลิปบอร์ดแล้ว',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'คัดลอกไปยังคลิปบอร์ดแล้ว: ${str}',
			'notifications.markAllAsRead' => 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมด',
			'notifications.markAllAsReadSuccess' => 'ทำเครื่องหมายว่าอ่านแล้วทุกการแจ้งเตือน',
			'notifications.markAllAsReadFailed' => 'ทำเครื่องหมายว่าอ่านแล้วทั้งหมดล้มเหลว',
			'notifications.markSelectedAsRead' => 'ทำเครื่องหมายรายการที่เลือกว่าอ่านแล้ว',
			'notifications.markSelectedAsReadSuccess' => 'ทำเครื่องหมายการแจ้งเตือนที่เลือกว่าอ่านแล้ว',
			'notifications.markSelectedAsReadFailed' => 'ทำเครื่องหมายรายการที่เลือกว่าอ่านแล้วล้มเหลว',
			'notifications.markAsRead' => 'ทำเครื่องหมายว่าอ่านแล้ว',
			'notifications.markAsReadSuccess' => 'ทำเครื่องหมายการแจ้งเตือนว่าอ่านแล้ว',
			'notifications.markAsReadFailed' => 'ทำเครื่องหมายการแจ้งเตือนว่าอ่านแล้วล้มเหลว',
			'notifications.notificationTypeHelp' => 'ความช่วยเหลือเกี่ยวกับประเภทการแจ้งเตือน',
			'notifications.dueToLackOfNotificationTypeDetails' => 'เนื่องจากขาดรายละเอียดของประเภทการแจ้งเตือน ประเภทที่รองรับในปัจจุบันอาจไม่ครอบคลุมข้อความที่คุณได้รับ',
			'notifications.helpUsImproveNotificationTypeSupport' => 'หากคุณยินดีที่จะช่วยเราปรับปรุงการรองรับประเภทการแจ้งเตือน',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 คัดลอกข้อมูลการแจ้งเตือน\n2. 🐞 ส่ง issue ไปยังที่เก็บข้อมูลโปรเจกต์\n\n⚠️ หมายเหตุ: ข้อมูลการแจ้งเตือนอาจมีความเป็นส่วนตัว หากคุณไม่ต้องการเปิดเผยสู่สาธารณะ คุณสามารถส่งไปยังอีเมลของผู้สร้างโปรเจกต์ได้',
			'notifications.goToRepository' => 'ไปยังคลังเก็บโค้ด (Repository)',
			'notifications.copy' => 'คัดลอก',
			'notifications.commentApproved' => 'ความคิดเห็นได้รับการอนุมัติแล้ว',
			'notifications.repliedYourProfileComment' => 'ตอบกลับความคิดเห็นในหน้าโปรไฟล์ของคุณ',
			'notifications.kReplied' => 'ตอบกลับความคิดเห็นของคุณบน',
			'notifications.kCommented' => 'แสดงความคิดเห็นบน',
			'notifications.kVideo' => 'วิดีโอ',
			'notifications.kGallery' => 'แกลเลอรี',
			'notifications.kProfile' => 'โปรไฟล์',
			'notifications.kThread' => 'กระทู้',
			'notifications.kPost' => 'โพสต์',
			'notifications.kCommentSection' => 'ในส่วนความคิดเห็น',
			'notifications.kApprovedComment' => 'อนุมัติความคิดเห็นแล้ว',
			'notifications.kApprovedVideo' => 'อนุมัติวิดีโอแล้ว',
			'notifications.kApprovedGallery' => 'อนุมัติแกลเลอรีแล้ว',
			'notifications.kApprovedThread' => 'อนุมัติกระทู้แล้ว',
			'notifications.kApprovedPost' => 'อนุมัติโพสต์แล้ว',
			'notifications.kApprovedForumPost' => 'อนุมัติโพสต์ฟอรัมแล้ว',
			'notifications.kRejectedContent' => 'การตรวจสอบเนื้อหาถูกปฏิเสธ',
			'notifications.kUnknownType' => 'ประเภทการแจ้งเตือนที่ไม่รู้จัก',
			'conversation.errors.pleaseSelectAUser' => 'โปรดเลือกผู้ใช้',
			'conversation.errors.pleaseEnterATitle' => 'โปรดป้อนชื่อเรื่อง',
			'conversation.errors.clickToSelectAUser' => 'คลิกเพื่อเลือกผู้ใช้',
			'conversation.errors.loadFailedClickToRetry' => 'โหลดล้มเหลว คลิกเพื่อลองใหม่',
			'conversation.errors.loadFailed' => 'โหลดล้มเหลว',
			'conversation.errors.clickToRetry' => 'คลิกเพื่อลองใหม่',
			'conversation.errors.noMoreConversations' => 'ไม่มีบทสนทนาเพิ่มเติม',
			'conversation.conversation' => 'บทสนทนา',
			'conversation.startConversation' => 'เริ่มต้นบทสนทนา',
			'conversation.noConversation' => 'ไม่มีบทสนทนา',
			'conversation.selectFromLeftListAndStartConversation' => 'เลือกจากรายการด้านซ้ายและเริ่มการสนทนา',
			'conversation.title' => 'ชื่อเรื่อง',
			'conversation.body' => 'เนื้อหา',
			'conversation.selectAUser' => 'เลือกผู้ใช้',
			'conversation.searchUsers' => 'ค้นหาผู้ใช้...',
			'conversation.tmpNoConversions' => 'ยังไม่มีบทสนทนา',
			'conversation.deleteThisMessage' => 'ลบข้อความนี้',
			'conversation.deleteThisMessageSubtitle' => 'การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'conversation.writeMessageHere' => 'เขียนข้อความที่นี่...',
			'conversation.lastMessageFromMe' => 'คุณ: ',
			'conversation.sendMessage' => 'ส่งข้อความ',
			'splash.errors.initializationFailed' => 'การเริ่มต้นล้มเหลว โปรดรีสตาร์ตแอป',
			'splash.preparing' => 'กำลังเตรียมการ...',
			'splash.initializing' => 'กำลังเริ่มต้นระบบ...',
			'splash.loading' => 'กำลังโหลด...',
			'splash.ready' => 'พร้อมใช้งาน',
			'splash.initializingMessageService' => 'กำลังเริ่มต้นบริการข้อความ...',
			'download.errors.imageModelNotFound' => 'ไม่พบข้อมูลแกลเลอรี',
			'download.errors.downloadFailed' => 'การดาวน์โหลดล้มเหลว',
			'download.errors.videoInfoNotFound' => 'ไม่พบข้อมูลวิดีโอ',
			'download.errors.downloadTaskAlreadyExists' => 'งานดาวน์โหลดมีอยู่แล้ว',
			'download.errors.downloadTaskSavePathConflict' => 'เส้นทางบันทึกนี้ถูกใช้งานโดยงานอื่นแล้ว',
			'download.errors.videoAlreadyDownloaded' => 'วิดีโอนี้ถูกดาวน์โหลดแล้ว',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'เพิ่มงานดาวน์โหลดล้มเหลว: ${errorInfo}',
			'download.errors.userPausedDownload' => 'ผู้ใช้หยุดการดาวน์โหลดชั่วคราว',
			'download.errors.unknown' => 'ไม่ทราบสาเหตุ',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'ข้อผิดพลาดระบบไฟล์: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'ข้อผิดพลาดที่ไม่รู้จัก: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'เขียนไฟล์ไม่สำเร็จ: ${errorInfo}',
			'download.errors.connectionTimeout' => 'หมดเวลาการเชื่อมต่อ',
			'download.errors.sendTimeout' => 'หมดเวลาการส่งข้อมูล',
			'download.errors.receiveTimeout' => 'หมดเวลาการรับข้อมูล',
			'download.errors.serverError' => ({required Object errorInfo}) => 'ข้อผิดพลาดเซิร์ฟเวอร์: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'ข้อผิดพลาดเครือข่ายที่ไม่รู้จัก',
			'download.errors.sslHandshakeFailed' => 'SSL handshake ล้มเหลว โปรดตรวจสอบเครือข่ายของคุณ',
			'download.errors.connectionFailed' => 'การเชื่อมต่อล้มเหลว โปรดตรวจสอบเครือข่ายของคุณ',
			'download.errors.serviceIsClosing' => 'บริการดาวน์โหลดกำลังปิดตัวลง',
			'download.errors.partialDownloadFailed' => 'ดาวน์โหลดเนื้อหาบางส่วนล้มเหลว',
			'download.errors.noDownloadTask' => 'ไม่มีงานดาวน์โหลด',
			'download.errors.taskNotFoundOrDataError' => 'ไม่พบงานหรือข้อมูลผิดพลาด',
			'download.errors.fileNotFound' => 'ไม่พบไฟล์',
			'download.errors.openFolderFailed' => 'เปิดโฟลเดอร์ไม่สำเร็จ',
			'download.errors.copyDownloadUrlFailed' => 'คัดลอก URL ดาวน์โหลดไม่สำเร็จ',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'เปิดโฟลเดอร์ไม่สำเร็จ: ${message}',
			'download.errors.directoryNotFound' => 'ไม่พบโฟลเดอร์',
			'download.errors.copyFailed' => 'คัดลอกไม่สำเร็จ',
			'download.errors.openFileFailed' => 'เปิดไฟล์ไม่สำเร็จ',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'เปิดไฟล์ไม่สำเร็จ: ${message}',
			'download.errors.playLocallyFailed' => 'เล่นในเครื่องไม่สำเร็จ',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'เล่นในเครื่องไม่สำเร็จ: ${message}',
			'download.errors.noDownloadSource' => 'ไม่มีแหล่งดาวน์โหลด',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'ยังไม่มีแหล่งดาวน์โหลด โปรดรอให้โหลดข้อมูลเสร็จสิ้นแล้วลองใหม่อีกครั้ง',
			'download.errors.noActiveDownloadTask' => 'ไม่มีงานที่กำลังดาวน์โหลด',
			'download.errors.noFailedDownloadTask' => 'ไม่มีงานที่ดาวน์โหลดล้มเหลว',
			'download.errors.noCompletedDownloadTask' => 'ไม่มีงานที่ดาวน์โหลดเสร็จสมบูรณ์',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'งานเสร็จสมบูรณ์แล้ว อย่าเพิ่มซ้ำ',
			'download.errors.linkExpiredTryAgain' => 'ลิงก์หมดอายุ กำลังขอรับลิงก์ดาวน์โหลดใหม่',
			'download.errors.linkExpiredTryAgainSuccess' => 'ลิงก์หมดอายุ ขอรับลิงก์ดาวน์โหลดใหม่สำเร็จ',
			'download.errors.linkExpiredTryAgainFailed' => 'ลิงก์หมดอายุ ขอรับลิงก์ดาวน์โหลดใหม่ล้มเหลว',
			'download.errors.taskDeleted' => 'ลบงานแล้ว',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'รูปแบบรูปภาพที่ไม่รองรับ: ${format}',
			'download.errors.deleteFileError' => 'ลบไฟล์ไม่สำเร็จ อาจเป็นเพราะไฟล์กำลังถูกใช้งานโดยกระบวนการอื่น',
			'download.errors.deleteTaskError' => 'ลบงานไม่สำเร็จ',
			'download.errors.canNotRefreshVideoTask' => 'ไม่สามารถรีเฟรชงานวิดีโอได้',
			'download.errors.videoRemovedCanNotRefresh' => 'วิดีโอนี้ถูกลบหรือไม่มีอยู่อีกต่อไป จึงไม่สามารถรีเฟรชลิงก์ดาวน์โหลดได้',
			'download.errors.videoInaccessibleCanNotRefresh' => 'ไม่สามารถเข้าถึงวิดีโอนี้ได้ อาจเป็นวิดีโอส่วนตัวหรือคุณอาจต้องลงชื่อเข้าใช้อีกครั้ง',
			'download.errors.videoQualityGone' => 'ความละเอียดนี้ไม่มีให้บริการแล้ว โปรดเพิ่มการดาวน์โหลดใหม่อีกครั้ง',
			'download.errors.refreshLinkNetworkFailed' => 'ข้อผิดพลาดเครือข่าย ไม่สามารถรีเฟรชลิงก์ดาวน์โหลดได้ในขณะนี้ โปรดลองใหม่อีกครั้งในภายหลัง',
			'download.errors.taskAlreadyProcessing' => 'งานกำลังดำเนินการอยู่แล้ว',
			'download.errors.taskNotFound' => 'ไม่พบงาน',
			'download.errors.failedToLoadTasks' => 'โหลดงานไม่สำเร็จ',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'ดาวน์โหลดบางส่วนล้มเหลว: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'รูปแบบรูปภาพที่ไม่รองรับ: ${extension} คุณสามารถลองดาวน์โหลดลงในอุปกรณ์ของคุณเพื่อดูได้',
			'download.errors.imageLoadFailed' => 'โหลดรูปภาพไม่สำเร็จ',
			'download.errors.pleaseTryOtherViewer' => 'โปรดลองใช้โปรแกรมดูภาพอื่นเพื่อเปิด',
			'download.downloadList' => 'รายการดาวน์โหลด',
			'download.viewDownloadList' => 'ดูรายการดาวน์โหลด',
			'download.download' => 'ดาวน์โหลด',
			'download.selectDownloadTitle' => 'เลือกการดาวน์โหลด',
			'download.qualitySectionLabel' => 'ความละเอียด',
			'download.categorySectionLabel' => 'หมวดหมู่',
			'download.saveToPreviewLabel' => 'จะบันทึกไปที่',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'ชื่อไฟล์ที่แนะนำ: ${name} (แก้ไขได้ในกล่องโต้ตอบระบบ)',
			'download.lastUsedBadge' => 'ใช้ล่าสุด',
			'download.pickedBadge' => 'เลือกแล้ว',
			'download.startDownloading' => 'เริ่มการดาวน์โหลด',
			'download.clearAllFailedTasks' => 'ล้างงานที่ล้มเหลวทั้งหมด',
			'download.clearAllFailedTasksConfirmation' => 'คุณแน่ใจหรือไม่ว่าต้องการล้างงานดาวน์โหลดที่ล้มเหลวทั้งหมด? ไฟล์ของงานเหล่านี้จะถูกลบไปด้วย',
			'download.clearAllFailedTasksSuccess' => 'ล้างงานที่ล้มเหลวทั้งหมดแล้ว',
			'download.clearAllFailedTasksError' => 'เกิดข้อผิดพลาดขณะล้างงานที่ล้มเหลว',
			'download.downloadStatus' => 'สถานะการดาวน์โหลด',
			'download.imageList' => 'รายการรูปภาพ',
			'download.retryDownload' => 'ลองดาวน์โหลดใหม่',
			'download.notDownloaded' => 'ยังไม่ได้ดาวน์โหลด',
			'download.downloaded' => 'ดาวน์โหลดแล้ว',
			'download.waitingForDownload' => 'กำลังรอการดาวน์โหลด',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'กำลังดาวน์โหลด (${downloaded}/${total} ภาพ ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'กำลังดาวน์โหลด (${downloaded} ภาพ)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'หยุดชั่วคราว (${downloaded}/${total} ภาพ ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'หยุดชั่วคราว (${downloaded} ภาพ)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'ดาวน์โหลดเสร็จสมบูรณ์ (ทั้งหมด ${total} ภาพ)',
			'download.viewVideoDetail' => 'ดูรายละเอียดวิดีโอ',
			'download.viewGalleryDetail' => 'ดูรายละเอียดแกลเลอรี',
			'download.moreOptions' => 'ตัวเลือกเพิ่มเติม',
			'download.openFile' => 'เปิดไฟล์',
			'download.playLocally' => 'เล่นในเครื่อง',
			'download.pause' => 'หยุดชั่วคราว',
			'download.resume' => 'ทำต่อ',
			'download.copyDownloadUrl' => 'คัดลอก URL ดาวน์โหลด',
			'download.showInFolder' => 'แสดงในโฟลเดอร์',
			'download.deleteTask' => 'ลบงาน',
			'download.deleteTaskConfirmation' => 'คุณแน่ใจหรือไม่ว่าต้องการลบงานดาวน์โหลดนี้?\nไฟล์ของงานจะถูกลบไปด้วย',
			'download.forceDeleteTask' => 'บังคับลบงาน',
			'download.forceDeleteTaskConfirmation' => 'คุณแน่ใจหรือไม่ว่าต้องการบังคับลบงานดาวน์โหลดนี้?\nไฟล์ของงานจะถูกลบไปด้วย แม้ว่าไฟล์นั้นกำลังถูกใช้งานอยู่ก็ตาม',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'หยุดชั่วคราว ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'หยุดชั่วคราว • ดาวน์โหลดแล้ว ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'ดาวน์โหลดเสร็จสมบูรณ์ • ${size}',
			'download.copyDownloadUrlSuccess' => 'คัดลอก URL ดาวน์โหลดแล้ว',
			'download.totalImageNums' => ({required Object num}) => '${num} ภาพ',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'กำลังดาวน์โหลด ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'กำลังดาวน์โหลด',
			'download.failed' => 'ล้มเหลว',
			'download.completed' => 'เสร็จสมบูรณ์',
			'download.downloadDetail' => 'รายละเอียดการดาวน์โหลด',
			'download.copy' => 'คัดลอก',
			'download.copySuccess' => 'คัดลอกแล้ว',
			'download.waiting' => 'กำลังรอ',
			'download.paused' => 'หยุดชั่วคราว',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'กำลังดาวน์โหลด ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'ดาวน์โหลดแกลเลอรีเสร็จสมบูรณ์: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'ดาวน์โหลดเสร็จสมบูรณ์: ${fileName}',
			'download.searchTasks' => 'ค้นหางาน...',
			'download.statusLabel' => ({required Object label}) => 'สถานะ: ${label}',
			'download.allStatus' => 'ทุกสถานะ',
			'download.typeLabel' => ({required Object label}) => 'ประเภท: ${label}',
			'download.allTypes' => 'ทุกประเภท',
			'download.taskType' => 'ประเภท',
			'download.video' => 'วิดีโอ',
			'download.gallery' => 'แกลเลอรี',
			'download.other' => 'อื่นๆ',
			'download.clearFilters' => 'ล้างตัวกรอง',
			'download.pauseAll' => 'หยุดชั่วคราวทั้งหมด',
			'download.resumeAll' => 'เริ่มทั้งหมด',
			'download.remainingTime' => ({required Object time}) => 'เหลือ ${time}',
			'download.timeline.today' => 'วันนี้',
			'download.timeline.yesterday' => 'เมื่อวาน',
			'download.timeline.thisWeek' => 'สัปดาห์นี้',
			'download.timeline.thisMonth' => 'เดือนนี้',
			'download.errorTypes.network' => 'ปัญหาเครือข่าย การลองใหม่อาจช่วยได้',
			'download.errorTypes.serverRejected' => 'เซิร์ฟเวอร์ปฏิเสธ คุณอาจต้องลงชื่อเข้าใช้อีกครั้ง',
			'download.errorTypes.notFound' => 'ทรัพยากรหมดอายุหรือถูกลบแล้ว',
			'download.errorTypes.diskFull' => 'พื้นที่จัดเก็บข้อมูลไม่เพียงพอ',
			'download.errorTypes.fileInUse' => 'ไฟล์กำลังถูกใช้งานโดยโปรแกรมอื่น',
			'download.errorTypes.permission' => 'ไม่มีสิทธิ์ในการเขียน',
			'download.errorTypes.cancelled' => 'ยกเลิกแล้ว',
			'download.errorTypes.unknown' => 'ข้อผิดพลาดที่ไม่รู้จัก',
			'download.errorDetailCopied' => 'คัดลอกรายละเอียดข้อผิดพลาดแล้ว',
			'download.errorDetailCopyHint' => 'กดค้างเพื่อคัดลอกรายละเอียดข้อผิดพลาด',
			'download.restoredPaused.banner' => ({required Object num}) => 'มี ${num} งานที่ยังไม่เสร็จจากเซสชันก่อนหน้าถูกหยุดชั่วคราวไว้',
			'download.restoredPaused.resume' => 'ดำเนินการต่อทั้งหมด',
			'download.restoredPaused.dismiss' => 'ปัดทิ้ง',
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
			'download.emptyTaskList' => 'ยังไม่มีงานดาวน์โหลด',
			'download.noMatchingTasks' => 'ไม่มีงานที่ตรงกัน',
			'download.deleteByDate.menuTitle' => 'ลบตามวันที่',
			'download.deleteByDate.dialogTitle' => 'ลบตามวันที่',
			'download.deleteByDate.description' => 'ลบงานดาวน์โหลดเป็นชุดตามวันที่สร้าง งานที่ไฟล์กำลังถูกใช้งานจะถูกข้ามไป ส่วนงานที่ไฟล์ไม่มีอยู่อีกต่อไปจะถูกล้างออก',
			'download.deleteByDate.modeRange' => 'ช่วงวันที่',
			'download.deleteByDate.modeDays' => 'เก่ากว่า',
			'download.deleteByDate.startDate' => 'วันที่เริ่มต้น',
			'download.deleteByDate.endDate' => 'วันที่สิ้นสุด',
			'download.deleteByDate.notSet' => 'ไม่ได้ตั้งค่า',
			'download.deleteByDate.daysUnit' => 'วัน',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'ลบงานที่สร้างมากกว่า ${days} วันที่แล้ว',
			'download.deleteByDate.noMatch' => 'ไม่มีงานที่ตรงกับเงื่อนไขที่เลือก',
			'download.deleteByDate.invalidRange' => 'วันที่เริ่มต้นต้องตรงกับหรือก่อนหน้าวันที่สิ้นสุด',
			'download.deleteByDate.confirmTitle' => 'ยืนยันการลบ',
			'download.deleteByDate.confirmContent' => ({required Object count}) => 'ลบ ${count} งานดาวน์โหลดและไฟล์ของงานเหล่านั้นหรือไม่? การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'กำลังลบ ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => 'ลบ ${count} งานแล้ว',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => 'ลบ ${deleted} งานแล้ว; ข้าม ${skipped} งาน (กำลังถูกใช้งาน)',
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
			_ => null,
		} ?? switch (path) {
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
			'download.category.manageTitle' => 'จัดการหมวดหมู่',
			'download.category.label' => 'หมวดหมู่',
			'download.category.uncategorized' => 'ไม่ได้จัดหมวดหมู่',
			'download.category.manage' => 'จัดการ',
			'download.category.createShortcut' => 'สร้างใหม่',
			'download.category.newCategoryHint' => 'ชื่อหมวดหมู่ใหม่',
			'download.category.createSuccess' => 'สร้างหมวดหมู่แล้ว',
			'download.category.createFailed' => 'สร้างหมวดหมู่ไม่สำเร็จ',
			'download.category.nameEmpty' => 'ชื่อหมวดหมู่ต้องไม่ว่างเปล่า',
			'download.category.emptyHint' => 'ยังไม่มีหมวดหมู่ สร้างหมวดหมู่เพื่อจัดระเบียบการดาวน์โหลดของคุณ',
			'download.category.moveTo' => 'ย้ายไปยังหมวดหมู่',
			'download.category.moveToWithCount' => ({required Object count}) => 'ย้าย ${count} รายการไปยัง…',
			'download.category.moveSuccess' => ({required Object title}) => 'ย้ายไปยัง ${title} แล้ว',
			'download.category.moveToUncategorizedSuccess' => 'ย้ายไปยังไม่ได้จัดหมวดหมู่แล้ว',
			'download.category.moveFailed' => 'ย้ายไม่สำเร็จ',
			'download.category.renameTitle' => 'เปลี่ยนชื่อหมวดหมู่',
			'download.category.renameHint' => 'ป้อนชื่อหมวดหมู่',
			'download.category.renameSuccess' => 'เปลี่ยนชื่อหมวดหมู่แล้ว',
			'download.category.renameFailed' => 'เปลี่ยนชื่อหมวดหมู่ไม่สำเร็จ',
			'download.category.deleteTitle' => 'ลบหมวดหมู่',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'ลบหมวดหมู่ "${title}" หรือไม่? รายการ ${count} รายการในหมวดหมู่นี้จะถูกย้ายไปที่ "ไม่ได้จัดหมวดหมู่" ไฟล์จะไม่ถูกลบ',
			'download.category.deleteSuccess' => 'ลบหมวดหมู่แล้ว',
			'download.category.deleteFailed' => 'ลบหมวดหมู่ไม่สำเร็จ',
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
			'download.maxConcurrentDownloads' => 'จำนวนการดาวน์โหลดพร้อมกันสูงสุด',
			'download.maxConcurrentDownloadsDesc' => 'จำนวนงานที่ดาวน์โหลดในเวลาเดียวกัน (1-5)',
			'download.stillInDevelopment' => 'ยังอยู่ระหว่างการพัฒนา',
			'download.saveToAppDirectory' => 'บันทึกไปยังโฟลเดอร์ของแอป',
			'download.alreadyDownloadedWithQuality' => 'ดาวน์โหลดด้วยความละเอียดเดียวกันนี้แล้ว ดำเนินการดาวน์โหลดต่อหรือไม่?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'ดาวน์โหลดด้วยความละเอียดต่อไปนี้แล้ว: ${qualities} ดำเนินการดาวน์โหลดต่อหรือไม่?',
			'download.otherQualities' => 'ความละเอียดอื่นๆ',
			'download.batchDownload.title' => 'การดาวน์โหลดเป็นชุด',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'มีงานกำลังทำงานอยู่แล้ว โปรดรอสักครู่',
			'download.batchDownload.userCancelled' => 'ผู้ใช้ยกเลิก',
			'download.batchDownload.failedToGetVideoInfo' => 'รับข้อมูลวิดีโอไม่สำเร็จ',
			'download.batchDownload.failedToGetVideoSource' => 'รับแหล่งที่มาของวิดีโอไม่สำเร็จ',
			'download.batchDownload.failedToGetGalleryInfo' => 'รับข้อมูลแกลเลอรีไม่สำเร็จ',
			'download.batchDownload.galleryNoImages' => 'แกลเลอรีไม่มีรูปภาพ',
			'download.batchDownload.failedToGetSavePath' => 'รับเส้นทางบันทึกไม่สำเร็จ',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'การดาวน์โหลดเป็นชุดล้มเหลว: ${exception}',
			'download.batchDownload.selectQuality' => 'เลือกความละเอียด',
			'download.batchDownload.downloading' => 'กำลังดาวน์โหลด',
			'download.batchDownload.downloadResult' => 'ผลลัพธ์การดาวน์โหลด',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => 'เลือกแล้ว ${count} วิดีโอ',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => 'เลือกแล้ว ${count} แกลเลอรี',
			'download.batchDownload.qualityNote' => 'หากไม่มีความละเอียดที่เลือกไว้ ระบบจะใช้ความละเอียดที่ดีที่สุดที่มีอยู่แทน',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'กำลังประมวลผล ${current}/${total}',
			'download.batchDownload.queued' => 'อยู่ในคิว',
			'download.batchDownload.success' => 'สำเร็จ',
			'download.batchDownload.skipped' => 'ข้ามแล้ว',
			'download.batchDownload.failed' => 'ล้มเหลว',
			'download.batchDownload.failureDetails' => 'รายละเอียดความล้มเหลว',
			'download.batchDownload.reasonPrivateVideo' => 'วิดีโอส่วนตัว',
			'download.batchDownload.reasonAlreadyExists' => 'มีอยู่แล้ว',
			'download.batchDownload.reasonNoSource' => 'ไม่มีแหล่งดาวน์โหลด',
			'download.batchDownload.reasonNoSavePath' => 'ไม่สามารถรับเส้นทางบันทึกได้',
			'download.batchDownload.reasonOther' => 'ข้อผิดพลาดอื่นๆ',
			'download.batchDownload.startDownload' => 'เริ่มการดาวน์โหลด',
			'downloadNotifications.completedTitle' => 'การดาวน์โหลดเสร็จสมบูรณ์',
			'downloadNotifications.failedTitle' => 'การดาวน์โหลดล้มเหลว',
			'downloadNotifications.completedBody' => ({required Object name}) => 'ดาวน์โหลด ${name} สำเร็จแล้ว',
			'downloadNotifications.failedBody' => ({required Object name}) => 'ดาวน์โหลด ${name} ล้มเหลว',
			'downloadNotifications.completedToast' => ({required Object name}) => 'ดาวน์โหลด ${name} แล้ว',
			'downloadNotifications.failedToast' => ({required Object name}) => 'ดาวน์โหลด ${name} ล้มเหลว',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'บันทึกไปที่ ${dir} แล้ว',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'บันทึกเป็น ${name} แล้ว (มีไฟล์ชื่อเดียวกันอยู่แล้ว)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'บันทึกไปที่โฟลเดอร์ของแอปแล้ว — เขียนลง ${target} ไม่ได้ (${reason})',
			'downloadNotifications.viewFolder' => 'ดูโฟลเดอร์',
			'downloadNotifications.fixInSettings' => 'แก้ไขในการตั้งค่า',
			'downloadNotifications.channelName' => 'สถานะการดาวน์โหลด',
			'downloadNotifications.channelDescription' => 'การแจ้งเตือนสำหรับการดาวน์โหลดที่เสร็จสมบูรณ์และล้มเหลว',
			'favorite.errors.addFailed' => 'เพิ่มไม่สำเร็จ',
			'favorite.errors.addSuccess' => 'เพิ่มสำเร็จ',
			'favorite.errors.deleteFolderFailed' => 'ลบโฟลเดอร์ไม่สำเร็จ',
			'favorite.errors.deleteFolderSuccess' => 'ลบโฟลเดอร์สำเร็จ',
			'favorite.errors.folderNameCannotBeEmpty' => 'ชื่อโฟลเดอร์ต้องไม่ว่างเปล่า',
			'favorite.add' => 'เพิ่ม',
			'favorite.addSuccess' => 'เพิ่มสำเร็จ',
			'favorite.addFailed' => 'เพิ่มไม่สำเร็จ',
			'favorite.remove' => 'ลบออก',
			'favorite.removeSuccess' => 'ลบออกสำเร็จ',
			'favorite.removeFailed' => 'ลบออกไม่สำเร็จ',
			'favorite.removeConfirmation' => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการนี้ออกจากรายการโปรด?',
			'favorite.removeConfirmationSuccess' => 'ลบรายการออกจากรายการโปรดแล้ว',
			'favorite.removeConfirmationFailed' => 'ลบรายการออกจากรายการโปรดไม่สำเร็จ',
			'favorite.createFolderSuccess' => 'สร้างโฟลเดอร์สำเร็จแล้ว',
			'favorite.createFolderFailed' => 'สร้างโฟลเดอร์ไม่สำเร็จ',
			'favorite.createFolder' => 'สร้างโฟลเดอร์',
			'favorite.enterFolderName' => 'ป้อนชื่อโฟลเดอร์',
			'favorite.enterFolderNameHere' => 'ป้อนชื่อโฟลเดอร์ที่นี่...',
			'favorite.create' => 'สร้าง',
			'favorite.items' => 'รายการ',
			'favorite.newFolderName' => 'โฟลเดอร์ใหม่',
			'favorite.searchFolders' => 'ค้นหาโฟลเดอร์...',
			'favorite.searchItems' => 'ค้นหารายการ...',
			'favorite.createdAt' => 'สร้างเมื่อ',
			'favorite.myFavorites' => 'รายการโปรดของฉัน',
			'favorite.deleteFolderTitle' => 'ลบโฟลเดอร์',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบโฟลเดอร์ ${title}?',
			'favorite.removeItemTitle' => 'ลบรายการ',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรายการ ${title}?',
			'favorite.removeItemSuccess' => 'ลบรายการออกจากรายการโปรดแล้ว',
			'favorite.removeItemFailed' => 'ลบรายการออกจากรายการโปรดไม่สำเร็จ',
			'favorite.localizeFavorite' => 'รายการโปรดในเครื่อง',
			'favorite.editFolderTitle' => 'แก้ไขโฟลเดอร์',
			'favorite.editFolderSuccess' => 'อัปเดตโฟลเดอร์สำเร็จแล้ว',
			'favorite.editFolderFailed' => 'อัปเดตโฟลเดอร์ไม่สำเร็จ',
			'favorite.searchTags' => 'ค้นหาแท็ก',
			'favorite.noTagsInFolder' => 'ยังไม่มีแท็กในรายการของโฟลเดอร์นี้',
			'favorite.tagFilterMatchAll' => 'แสดงเฉพาะรายการที่มีครบทุกแท็กที่เลือก',
			'favorite.clearSelectedTags' => 'ล้างแท็กที่เลือก',
			'favorite.selectedTagCount' => ({required Object count}) => 'เลือกแล้ว ${count} แท็ก',
			'favorite.noMatchingTags' => 'ไม่มีแท็กที่ตรงกัน',
			'translation.currentService' => 'บริการปัจจุบัน',
			'translation.testConnection' => 'ทดสอบการเชื่อมต่อ',
			'translation.testConnectionSuccess' => 'ทดสอบการเชื่อมต่อสำเร็จ',
			'translation.testConnectionFailed' => 'ทดสอบการเชื่อมต่อล้มเหลว',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'ทดสอบการเชื่อมต่อล้มเหลว: ${message}',
			'translation.translation' => 'การแปลภาษา',
			'translation.needVerification' => 'จำเป็นต้องยืนยัน',
			'translation.needVerificationContent' => 'โปรดทดสอบการเชื่อมต่อก่อนเปิดใช้งานการแปลภาษาด้วย AI',
			'translation.confirm' => 'ยืนยัน',
			'translation.disclaimer' => 'ข้อจำกัดความรับผิดชอบ',
			'translation.riskWarning' => 'คำเตือนเกี่ยวกับความเสี่ยง',
			'translation.dureToRisk1' => 'เนื่องจากข้อความถูกสร้างโดยผู้ใช้ จึงอาจมีเนื้อหาที่ละเมิดนโยบายเนื้อหาของผู้ให้บริการ AI',
			'translation.dureToRisk2' => 'เนื้อหาที่ไม่เหมาะสมอาจนำไปสู่การระงับคีย์ API หรือการยุติบริการ',
			'translation.operationSuggestion' => 'คำแนะนำการใช้งาน',
			'translation.operationSuggestion1' => '1. ตรวจสอบเนื้อหาที่จะแปลอย่างรอบคอบก่อนใช้งาน',
			'translation.operationSuggestion2' => '2. หลีกเลี่ยงการแปลเนื้อหาเกี่ยวกับความรุนแรง เนื้อหาสำหรับผู้ใหญ่ ฯลฯ',
			'translation.apiConfig' => 'การกำหนดค่า API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'การแก้ไขการกำหนดค่าจะปิดการแปลด้วย AI โดยอัตโนมัติ และต้องทดสอบใหม่อีกครั้งหลังจากเปิด',
			'translation.apiAddress' => 'ที่อยู่ API',
			'translation.modelName' => 'ชื่อโมเดล',
			'translation.modelNameHintText' => 'ตัวอย่างเช่น: gpt-4-turbo',
			'translation.maxTokens' => 'โทเค็นสูงสุด (Max Tokens)',
			'translation.maxTokensHintText' => 'ตัวอย่างเช่น: 32000',
			'translation.temperature' => 'อุณหภูมิ (Temperature)',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'คลิกปุ่มทดสอบเพื่อยืนยันความถูกต้องของการเชื่อมต่อ API',
			'translation.requestPreview' => 'ตัวอย่างคำขอ',
			'translation.enableAITranslation' => 'เปิดใช้งาน AI',
			'translation.enabled' => 'เปิดใช้งานแล้ว',
			'translation.disabled' => 'ปิดใช้งานแล้ว',
			'translation.testing' => 'กำลังทดสอบ...',
			'translation.testNow' => 'ทดสอบทันที',
			'translation.connectionStatus' => 'สถานะการเชื่อมต่อ',
			'translation.success' => 'สำเร็จ',
			'translation.failed' => 'ล้มเหลว',
			'translation.information' => 'ข้อมูล',
			'translation.viewRawResponse' => 'ดูการตอบกลับดิบ',
			'translation.pleaseCheckInputParametersFormat' => 'โปรดตรวจสอบรูปแบบพารามิเตอร์ที่ป้อน',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'โปรดกรอกที่อยู่ API ชื่อโมเดล และคีย์',
			'translation.pleaseFillInValidConfigurationParameters' => 'โปรดกรอกพารามิเตอร์การกำหนดค่าที่ถูกต้อง',
			'translation.pleaseCompleteConnectionTest' => 'โปรดทำการทดสอบการเชื่อมต่อให้เสร็จสิ้น',
			'translation.notConfigured' => 'ยังไม่ได้กำหนดค่า',
			'translation.apiEndpoint' => 'ปลายทาง API (Endpoint)',
			'translation.configuredKey' => 'กำหนดค่าคีย์แล้ว',
			'translation.notConfiguredKey' => 'ยังไม่ได้กำหนดค่าคีย์',
			'translation.authenticationStatus' => 'สถานะการรับรองความถูกต้อง',
			'translation.thisFieldCannotBeEmpty' => 'ฟิลด์นี้ต้องไม่ว่างเปล่า',
			'translation.apiKey' => 'คีย์ API',
			'translation.apiKeyCannotBeEmpty' => 'คีย์ API ต้องไม่ว่างเปล่า',
			'translation.pleaseEnterValidNumber' => 'โปรดป้อนตัวเลขที่ถูกต้อง',
			'translation.range' => 'ช่วง',
			'translation.mustBeGreaterThan' => 'ต้องมากกว่า',
			'translation.invalidAPIResponse' => 'การตอบกลับของ API ไม่ถูกต้อง',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'การเชื่อมต่อล้มเหลว: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'การแปลด้วย AI ยังไม่ได้เปิดใช้งาน โปรดเปิดใช้งานในการตั้งค่า',
			'translation.goToSettings' => 'ไปที่การตั้งค่า',
			'translation.disableAITranslation' => 'ปิดใช้งานการแปลด้วย AI',
			'translation.currentValue' => 'ค่าปัจจุบัน',
			'translation.configureTranslationStrategy' => 'กำหนดค่ากลยุทธ์การแปล',
			'translation.advancedSettings' => 'การตั้งค่าขั้นสูง',
			'translation.translationPrompt' => 'พรอมต์การแปลภาษา',
			'translation.promptHint' => 'โปรดป้อนพรอมต์การแปล โดยใช้ [TL] เป็นตัวแทนสำหรับภาษาเป้าหมาย',
			'translation.promptHelperText' => 'พรอมต์ต้องมี [TL] เป็นตัวแทนสำหรับภาษาเป้าหมาย',
			'translation.promptMustContainTargetLang' => 'พรอมต์ต้องมีตัวแทน [TL]',
			'translation.aiTranslationWillBeDisabled' => 'การแปลด้วย AI จะถูกปิดใช้งาน',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'เนื่องจากมีการเปลี่ยนแปลงการกำหนดค่าพื้นฐาน การแปลด้วย AI จะถูกปิดใช้งาน',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'เนื่องจากมีการเปลี่ยนแปลงพรอมต์การแปล การแปลด้วย AI จะถูกปิดใช้งาน',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'เนื่องจากมีการเปลี่ยนแปลงการกำหนดค่าพารามิเตอร์ การแปลด้วย AI จะถูกปิดใช้งาน',
			'translation.onlyOpenAIAPISupported' => 'ขณะนี้รองรับเฉพาะรูปแบบ API ที่เข้ากันได้กับ OpenAI เท่านั้น (เนื้อหาคำขอแบบ application/json)',
			'translation.streamingTranslation' => 'การแปลแบบสตรีมมิง',
			'translation.streamingTranslationSupported' => 'รองรับการแปลแบบสตรีมมิง',
			'translation.streamingTranslationNotSupported' => 'ไม่รองรับการแปลแบบสตรีมมิง',
			'translation.streamingTranslationDescription' => 'การแปลแบบสตรีมมิงสามารถแสดงผลลัพธ์แบบเรียลไทม์ระหว่างกระบวนการแปล ทำให้ผู้ใช้ได้รับประสบการณ์ที่ดียิ่งขึ้น',
			'translation.usingFullUrlWithHash' => 'ใช้ URL แบบเต็ม (ลงท้ายด้วย #)',
			'translation.baseUrlInputHelperText' => 'เมื่อลงท้ายด้วย # จะถูกใช้เป็นที่อยู่คำขอจริง',
			'translation.currentActualUrl' => ({required Object url}) => 'URL จริงในปัจจุบัน: ${url}',
			'translation.urlEndingWithHashTip' => 'URL ที่ลงท้ายด้วย # จะถูกใช้โดยตรงโดยไม่มีการต่อท้ายใดๆ',
			'translation.streamingTranslationWarning' => 'หมายเหตุ: คุณสมบัตินี้ต้องการบริการ API ที่รองรับการส่งข้อมูลแบบสตรีมมิง โมเดลบางตัวอาจไม่รองรับ',
			'translation.translationService' => 'บริการแปลภาษา',
			'translation.translationServiceDescription' => 'เลือกบริการแปลภาษาที่คุณต้องการ',
			'translation.googleTranslation' => 'การแปลภาษาของ Google',
			'translation.googleTranslationDescription' => 'บริการแปลภาษาออนไลน์ฟรีที่รองรับหลายภาษา',
			'translation.aiTranslation' => 'การแปลภาษาด้วย AI',
			'translation.aiTranslationDescription' => 'บริการแปลภาษาอัจฉริยะที่ใช้โมเดลภาษาขนาดใหญ่',
			'translation.deeplxTranslation' => 'การแปลภาษา DeepLX',
			'translation.deeplxTranslationDescription' => 'การนำ DeepL ไปใช้แบบโอเพนซอร์ส ให้การแปลคุณภาพสูง',
			'translation.googleTranslationFeatures' => 'คุณสมบัติ',
			'translation.freeToUse' => 'ใช้งานฟรี',
			'translation.freeToUseDescription' => 'ไม่ต้องกำหนดค่าใดๆ พร้อมใช้งานทันที',
			'translation.fastResponse' => 'ตอบสนองรวดเร็ว',
			'translation.fastResponseDescription' => 'ความเร็วในการแปลรวดเร็ว มีความหน่วงต่ำ',
			'translation.stableAndReliable' => 'เสถียรและเชื่อถือได้',
			'translation.stableAndReliableDescription' => 'ทำงานบน API ทางการของ Google',
			'translation.enabledDefaultService' => 'เปิดใช้งานแล้ว - บริการแปลภาษาเริ่มต้น',
			'translation.notEnabled' => 'ยังไม่เปิดใช้งาน',
			'translation.deeplxTranslationService' => 'บริการแปลภาษา DeepLX',
			'translation.deeplxDescription' => 'DeepLX คือการนำ DeepL ไปใช้แบบโอเพนซอร์ส รองรับโหมดปลายทางแบบ Free, Pro และ Official',
			'translation.serverAddress' => 'ที่อยู่เซิร์ฟเวอร์',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'ที่อยู่พื้นฐานของเซิร์ฟเวอร์ DeepLX',
			'translation.endpointType' => 'ประเภทปลายทาง (Endpoint)',
			'translation.freeEndpoint' => 'Free - ปลายทางฟรี อาจมีการจำกัดอัตราการเรียกใช้',
			'translation.proEndpoint' => 'Pro - ต้องใช้ dl_session มีความเสถียรมากกว่า',
			'translation.officialEndpoint' => 'Official - รูปแบบ API ทางการ',
			'translation.finalRequestUrl' => 'URL คำขอขั้นสุดท้าย',
			'translation.apiKeyOptional' => 'คีย์ API (ไม่บังคับ)',
			'translation.apiKeyOptionalHint' => 'สำหรับเข้าถึงบริการ DeepLX ที่ได้รับการปกป้อง',
			'translation.apiKeyOptionalHelperText' => 'บริการ DeepLX บางแห่งจำเป็นต้องใช้คีย์ API ในการตรวจสอบสิทธิ์',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'พารามิเตอร์ dl_session ที่จำเป็นสำหรับโหมด Pro',
			'translation.dlSessionHelperText' => 'พารามิเตอร์เซสชันที่จำเป็นสำหรับปลายทาง Pro โดยรับได้จากบัญชี DeepL Pro',
			'translation.proModeRequiresDlSession' => 'โหมด Pro ต้องระบุ dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'คลิกปุ่มทดสอบเพื่อตรวจสอบการเชื่อมต่อ DeepLX API',
			'translation.enableDeepLXTranslation' => 'เปิดใช้งานการแปลภาษา DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'การแปลภาษา DeepLX จะถูกปิดใช้งานเนื่องจากการเปลี่ยนแปลงการกำหนดค่า',
			'translation.translatedResult' => 'ผลลัพธ์การแปล',
			'translation.testSuccess' => 'การทดสอบสำเร็จ',
			'translation.pleaseFillInDeepLXServerAddress' => 'โปรดกรอกที่อยู่เซิร์ฟเวอร์ DeepLX',
			'translation.invalidAPIResponseFormat' => 'รูปแบบการตอบกลับของ API ไม่ถูกต้อง',
			'translation.translationServiceReturnedError' => 'บริการแปลส่งคืนข้อผิดพลาดหรือผลลัพธ์ว่างเปล่า',
			'translation.connectionFailed' => 'การเชื่อมต่อล้มเหลว',
			'translation.translationFailed' => 'การแปลภาษาล้มเหลว',
			'translation.aiTranslationFailed' => 'การแปลด้วย AI ล้มเหลว',
			'translation.deeplxTranslationFailed' => 'การแปลด้วย DeepLX ล้มเหลว',
			'translation.aiTranslationTestFailed' => 'การทดสอบการแปลด้วย AI ล้มเหลว',
			'translation.deeplxTranslationTestFailed' => 'การทดสอบการแปลด้วย DeepLX ล้มเหลว',
			'translation.streamingTranslationTimeout' => 'การแปลแบบสตรีมมิงหมดเวลา บังคับล้างทรัพยากร',
			'translation.translationRequestTimeout' => 'คำขอการแปลภาษาหมดเวลา',
			'translation.streamingTranslationDataTimeout' => 'การรับข้อมูลการแปลแบบสตรีมมิงหมดเวลา',
			'translation.dataReceptionTimeout' => 'การรับข้อมูลหมดเวลา',
			'translation.streamDataParseError' => 'เกิดข้อผิดพลาดในการแยกวิเคราะห์ข้อมูลสตรีม',
			'translation.streamingTranslationFailed' => 'การแปลแบบสตรีมมิงล้มเหลว',
			'translation.fallbackTranslationFailed' => 'การเปลี่ยนกลับไปใช้การแปลแบบปกติก็ล้มเหลวเช่นกัน',
			'translation.translationSettings' => 'การตั้งค่าการแปลภาษา',
			'translation.enableGoogleTranslation' => 'เปิดใช้งาน Google Translation',
			'translation.thinking' => 'กำลังคิด…',
			'translation.thoughtProcess' => 'กระบวนการคิด',
			'translation.modelCompatibility' => 'ความเข้ากันได้ของโมเดล',
			'translation.modelCompatibilityDescription' => 'ปรับพารามิเตอร์คำขอสำหรับโมเดลสมัยใหม่ เช่น โมเดลการให้เหตุผล (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'โมเดลการให้เหตุผล (Reasoning Model)',
			'translation.reasoningModelDescription' => 'สำหรับ o1/o3, DeepSeek-R1, QwQ ฯลฯ รวมพรอมต์เข้ากับข้อความของผู้ใช้ ละเว้น temperature และใช้ max_completion_tokens แทน',
			'translation.useMaxCompletionTokens' => 'ใช้ max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'ปลายทาง OpenAI รุ่นใหม่ต้องการ max_completion_tokens แทน max_tokens ที่เลิกใช้แล้ว',
			'translation.sendTemperature' => 'ส่ง temperature',
			'translation.sendTemperatureDescription' => 'ปิดสำหรับโมเดลที่ปฏิเสธพารามิเตอร์ temperature (โมเดลการให้เหตุผลส่วนใหญ่)',
			'translation.showReasoningProcess' => 'แสดงกระบวนการคิด',
			'translation.showReasoningProcessDescription' => 'แสดงการให้เหตุผลที่สามารถยุบเก็บได้ของโมเดลการให้เหตุผลในกล่องโต้ตอบการแปล',
			'translation.provider' => 'ผู้ให้บริการ',
			'translation.providerOpenAI' => 'OpenAI (และที่เข้ากันได้)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'รองรับ OpenAI (และปลายทางใดๆ ที่เข้ากันได้กับ OpenAI), Anthropic และ Google ผ่าน dartantic_ai SDK',
			'translation.baseUrlOptionalHelperText' => 'ไม่บังคับ เว้นว่างไว้เพื่อใช้ปลายทางเริ่มต้นของผู้ให้บริการ กรอกสำหรับปลายทางที่เข้ากันได้กับ OpenAI หรือรีเลย์',
			'translation.defaultEndpoint' => 'ปลายทางเริ่มต้น',
			'translation.providerPreset' => 'ค่าที่ตั้งล่วงหน้าของผู้ให้บริการ',
			'translation.selectProviderPreset' => 'เลือกค่าที่ตั้งล่วงหน้า',
			'translation.presetCustom' => 'กำหนดเอง',
			'translation.presetApplied' => ({required Object name}) => 'ใช้ค่าที่ตั้งล่วงหน้าแล้ว: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI การให้เหตุผล (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude การให้เหตุผล (extended thinking)',
			'translation.presetNames.gemini' => 'Google Gemini (เนทีฟ)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini การให้เหตุผล (thinking)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek การให้เหตุผล (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'ดึงรายการโมเดล',
			'translation.fetchingModels' => 'กำลังดึงข้อมูล…',
			'translation.selectModel' => 'เลือกโมเดล',
			'translation.searchModel' => 'ค้นหาโมเดล',
			'translation.noModelsFound' => 'ไม่พบโมเดล',
			'bottomNav.video' => 'วิดีโอ',
			'bottomNav.gallery' => 'แกลเลอรี',
			'bottomNav.subscription' => 'ติดตาม',
			'bottomNav.community' => 'ชุมชน',
			'bottomNav.localMedia' => 'ไฟล์',
			'navigationOrderSettings.title' => 'การตั้งค่าลำดับการนำทาง',
			'navigationOrderSettings.customNavigationOrder' => 'กำหนดลำดับการนำทางเอง',
			'navigationOrderSettings.customNavigationOrderDesc' => 'ลากเพื่อปรับลำดับการแสดงผลของหน้าต่างๆ ในแถบนำทางด้านล่างและแถบด้านข้าง',
			'navigationOrderSettings.restartRequired' => 'จำเป็นต้องรีสตาร์ทแอป',
			'navigationOrderSettings.navigationItemSorting' => 'การเรียงลำดับรายการนำทาง',
			'navigationOrderSettings.done' => 'เสร็จสิ้น',
			'navigationOrderSettings.edit' => 'แก้ไข',
			'navigationOrderSettings.reset' => 'รีเซ็ต',
			'navigationOrderSettings.previewEffect' => 'ตัวอย่างผลลัพธ์',
			'navigationOrderSettings.bottomNavigationPreview' => 'ตัวอย่างแถบนำทางด้านล่าง:',
			'navigationOrderSettings.sidebarPreview' => 'ตัวอย่างแถบด้านข้าง:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'ยืนยันการรีเซ็ตลำดับการนำทาง',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตลำดับการนำทางกลับเป็นค่าเริ่มต้น?',
			'navigationOrderSettings.cancel' => 'ยกเลิก',
			'navigationOrderSettings.show' => 'แสดง',
			'navigationOrderSettings.hide' => 'ซ่อน',
			'navigationOrderSettings.hidden' => 'ซ่อนอยู่',
			'navigationOrderSettings.hideHint' => 'แตะไอคอนรูปตาเพื่อแสดงหรือซ่อนชุมชนและไฟล์ในเครื่อง',
			'navigationOrderSettings.videoDescription' => 'เรียกดูเนื้อหาวิดีโอยอดนิยม',
			'navigationOrderSettings.galleryDescription' => 'เรียกดูรูปภาพและแกลเลอรี',
			'navigationOrderSettings.subscriptionDescription' => 'ดูเนื้อหาล่าสุดจากผู้ใช้ที่คุณติดตาม',
			'navigationOrderSettings.forumDescription' => 'เข้าร่วมการสนทนาในชุมชน',
			'navigationOrderSettings.newsDescription' => 'เรียกดูข่าวสาร บทความ และประกาศทางการ',
			'navigationOrderSettings.communityDescription' => 'การสนทนาในฟอรัมพร้อมข่าวสาร บทความ และประกาศทางการ',
			'navigationOrderSettings.localMediaDescription' => 'เรียกดูวิดีโอและรูปภาพที่จัดเก็บไว้ในอุปกรณ์นี้',
			'news.title' => 'ข่าวสาร',
			'news.newsUpdates' => 'อัปเดตข่าวสาร',
			'news.articles' => 'บทความ',
			'news.broadcast' => 'ประกาศ',
			'news.openInBrowser' => 'เปิดในเบราว์เซอร์',
			'displaySettings.title' => 'การตั้งค่าการแสดงผล',
			'displaySettings.layoutSettings' => 'การตั้งค่าเลย์เอาต์',
			'displaySettings.layoutSettingsDesc' => 'ปรับแต่งจำนวนคอลัมน์และการกำหนดค่าจุดแบ่งหน้าจอ (Breakpoint)',
			'displaySettings.gridLayout' => 'เลย์เอาต์ตาราง',
			'displaySettings.navigationOrderSettings' => 'การตั้งค่าลำดับการนำทาง',
			'displaySettings.customNavigationOrder' => 'กำหนดลำดับการนำทางเอง',
			'displaySettings.customNavigationOrderDesc' => 'ปรับลำดับการแสดงผลของหน้าต่างๆ ในแถบนำทางด้านล่างและแถบด้านข้าง',
			'layoutSettings.title' => 'การตั้งค่าเลย์เอาต์',
			'layoutSettings.descriptionTitle' => 'คำอธิบายการกำหนดค่าเลย์เอาต์',
			'layoutSettings.descriptionContent' => 'การกำหนดค่าที่นี่จะเป็นตัวกำหนดจำนวนคอลัมน์ที่แสดงในหน้ารายการวิดีโอและแกลเลอรี คุณสามารถเลือกโหมดอัตโนมัติเพื่อให้ระบบปรับตามความกว้างหน้าจอโดยอัตโนมัติ หรือเลือกโหมดกำหนดเองเพื่อกำหนดจำนวนคอลัมน์แบบคงที่',
			'layoutSettings.layoutMode' => 'โหมดเลย์เอาต์',
			'layoutSettings.reset' => 'รีเซ็ต',
			'layoutSettings.autoMode' => 'โหมดอัตโนมัติ',
			'layoutSettings.autoModeDesc' => 'ปรับโดยอัตโนมัติตามความกว้างของหน้าจอ',
			'layoutSettings.manualMode' => 'โหมดกำหนดเอง',
			'layoutSettings.manualModeDesc' => 'ใช้จำนวนคอลัมน์คงที่',
			'layoutSettings.manualSettings' => 'การตั้งค่ากำหนดเอง',
			'layoutSettings.fixedColumns' => 'จำนวนคอลัมน์คงที่',
			'layoutSettings.columns' => 'คอลัมน์',
			'layoutSettings.breakpointConfig' => 'การกำหนดค่าจุดแบ่งหน้าจอ',
			'layoutSettings.add' => 'เพิ่ม',
			'layoutSettings.defaultColumns' => 'คอลัมน์เริ่มต้น',
			'layoutSettings.defaultColumnsDesc' => 'การแสดงผลเริ่มต้นสำหรับหน้าจอขนาดใหญ่',
			'layoutSettings.previewEffect' => 'ตัวอย่างผลลัพธ์',
			'layoutSettings.screenWidth' => 'ความกว้างหน้าจอ',
			'layoutSettings.addBreakpoint' => 'เพิ่มจุดแบ่ง',
			'layoutSettings.editBreakpoint' => 'แก้ไขจุดแบ่ง',
			'layoutSettings.deleteBreakpoint' => 'ลบจุดแบ่ง',
			'layoutSettings.screenWidthLabel' => 'ความกว้างหน้าจอ',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'คอลัมน์',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'โปรดป้อนความกว้าง',
			'layoutSettings.enterValidWidth' => 'โปรดป้อนความกว้างที่ถูกต้อง',
			'layoutSettings.widthCannotExceed9999' => 'ความกว้างต้องไม่เกิน 9999',
			'layoutSettings.breakpointAlreadyExists' => 'จุดแบ่งมีอยู่แล้ว',
			'layoutSettings.enterColumns' => 'โปรดป้อนจำนวนคอลัมน์',
			'layoutSettings.enterValidColumns' => 'โปรดป้อนจำนวนคอลัมน์ที่ถูกต้อง',
			'layoutSettings.columnsCannotExceed12' => 'คอลัมน์ต้องไม่เกิน 12',
			'layoutSettings.breakpointConflict' => 'จุดแบ่งมีอยู่แล้ว',
			'layoutSettings.confirmResetLayoutSettings' => 'รีเซ็ตการตั้งค่าเลย์เอาต์',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตการตั้งค่าเลย์เอาต์ทั้งหมดกลับเป็นค่าเริ่มต้น?\n\nจะคืนค่าเป็น:\n• โหมดอัตโนมัติ\n• การกำหนดค่าจุดแบ่งเริ่มต้น',
			'layoutSettings.resetToDefaults' => 'รีเซ็ตเป็นค่าเริ่มต้น',
			'layoutSettings.confirmDeleteBreakpoint' => 'ลบจุดแบ่ง',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบจุดแบ่ง ${width}px?',
			'layoutSettings.noCustomBreakpoints' => 'ไม่มีจุดแบ่งที่กำหนดเอง ใช้คอลัมน์เริ่มต้น',
			'layoutSettings.breakpointRange' => 'ช่วงจุดแบ่ง',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'แก้ไข',
			'layoutSettings.delete' => 'ลบ',
			'layoutSettings.cancel' => 'ยกเลิก',
			'layoutSettings.save' => 'บันทึก',
			'mediaPlayer.videoPlayerError' => 'ข้อผิดพลาดของเครื่องเล่นวิดีโอ',
			'mediaPlayer.videoLoadFailed' => 'โหลดวิดีโอล้มเหลว',
			'mediaPlayer.videoCodecNotSupported' => 'ไม่รองรับตัวแปลงสัญญาณวิดีโอนี้',
			'mediaPlayer.networkConnectionIssue' => 'ปัญหาการเชื่อมต่อเครือข่าย',
			'mediaPlayer.insufficientPermission' => 'สิทธิ์ไม่เพียงพอ',
			'mediaPlayer.unsupportedVideoFormat' => 'รูปแบบวิดีโอที่ไม่รองรับ',
			'mediaPlayer.retry' => 'ลองใหม่อีกครั้ง',
			'mediaPlayer.externalPlayer' => 'เครื่องเล่นภายนอก',
			'mediaPlayer.detailedErrorInfo' => 'ข้อมูลข้อผิดพลาดโดยละเอียด',
			'mediaPlayer.format' => 'รูปแบบ',
			'mediaPlayer.suggestion' => 'คำแนะนำ',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'อุปกรณ์ Android มีการรองรับรูปแบบ WEBM อย่างจำกัด แนะนำให้ใช้เครื่องเล่นภายนอกหรือดาวน์โหลดแอปเครื่องเล่นที่รองรับ WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'อุปกรณ์ปัจจุบันไม่รองรับตัวแปลงสัญญาณสำหรับรูปแบบวิดีโอนี้',
			'mediaPlayer.checkNetworkConnection' => 'โปรดตรวจสอบการเชื่อมต่อเครือข่ายของคุณแล้วลองใหม่อีกครั้ง',
			'mediaPlayer.appMayLackMediaPermission' => 'แอปอาจไม่มีสิทธิ์ในการเล่นสื่อที่จำเป็น',
			'mediaPlayer.tryOtherVideoPlayer' => 'โปรดลองใช้โปรแกรมเล่นวิดีโออื่น',
			'mediaPlayer.unrecognizedVideoFormat' => 'ไม่รู้จักไฟล์วิดีโอ',
			_ => null,
		} ?? switch (path) {
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'ลิงก์อาจหมดอายุแล้ว หรือการตอบกลับไม่ใช่วิดีโอ โปรดลองอีกครั้งหรือเปิดด้วยแอปอื่น',
			'mediaPlayer.accessDenied' => 'เซิร์ฟเวอร์ปฏิเสธคำขอนี้ (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'ลิงก์เล่นน่าจะหมดอายุแล้ว แตะลองใหม่เพื่อดึงลิงก์อีกครั้ง หรือเปิดด้วยแอปอื่น',
			'mediaPlayer.mute' => 'ปิดเสียง',
			'mediaPlayer.unmute' => 'เปิดเสียง',
			'mediaPlayer.video' => 'วิดีโอ',
			'mediaPlayer.serverSelector' => 'การเลือกเซิร์ฟเวอร์ CDN',
			'mediaPlayer.serverSelectorDescription' => 'เลือกเซิร์ฟเวอร์ที่มีความหน่วงต่ำที่สุดเพื่อประสบการณ์การเล่นที่ดีที่สุด',
			'mediaPlayer.retestSpeed' => 'ทดสอบความเร็วใหม่',
			'mediaPlayer.waitingForSpeedTest' => 'กำลังรอการทดสอบความเร็ว',
			'mediaPlayer.testingSpeed' => 'กำลังทดสอบความเร็ว...',
			'mediaPlayer.testFailed' => 'การทดสอบล้มเหลว',
			'mediaPlayer.loadingServerList' => 'กำลังโหลดรายการเซิร์ฟเวอร์...',
			'mediaPlayer.noAvailableServers' => 'ไม่มีเซิร์ฟเวอร์ที่พร้อมใช้งาน',
			'mediaPlayer.refreshServerList' => 'รีเฟรชรายการเซิร์ฟเวอร์',
			'mediaPlayer.cannotGetSource' => 'ไม่สามารถรับแหล่งวิดีโอปัจจุบันได้',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'สลับไปยังเซิร์ฟเวอร์: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'ทั้งหมด ${count} เซิร์ฟเวอร์',
			'mediaPlayer.statusCode' => ({required Object code}) => 'รหัสสถานะ: ${code}',
			'mediaPlayer.connectionFailed' => 'การเชื่อมต่อล้มเหลว',
			'mediaPlayer.connectionTimeout' => 'หมดเวลาการเชื่อมต่อ',
			'mediaPlayer.networkError' => 'ข้อผิดพลาดเครือข่าย',
			'mediaPlayer.sslError' => 'ข้อผิดพลาดใบรับรอง SSL',
			'mediaPlayer.testCompleted' => 'การทดสอบเสร็จสมบูรณ์',
			'mediaPlayer.local' => 'ในเครื่อง',
			'mediaPlayer.unknown' => 'ไม่รู้จัก',
			'mediaPlayer.localVideoPathEmpty' => 'เส้นทางวิดีโอในเครื่องว่างเปล่า',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'ไม่มีไฟล์วิดีโอในเครื่อง: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'ไม่สามารถเล่นวิดีโอในเครื่องได้: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'ลากไฟล์วิดีโอมาวางที่นี่เพื่อเล่น',
			'mediaPlayer.supportedFormats' => 'รูปแบบที่รองรับ: MP4, MKV, AVI, MOV, WEBM ฯลฯ',
			'mediaPlayer.noSupportedVideoFile' => 'ไม่พบไฟล์วิดีโอที่รองรับ',
			'mediaPlayer.retryingOpenVideoLink' => 'เปิดลิงก์วิดีโอล้มเหลว กำลังลองใหม่',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'ไม่สามารถโหลดตัวถอดรหัส: ${event} ลองสลับไปใช้การถอดรหัสด้วยซอฟต์แวร์ในการตั้งค่าเครื่องเล่น แล้วเข้าสู่หน้านี้ใหม่อีกครั้ง',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'ข้อผิดพลาดในการโหลดวิดีโอ: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'ตรวจพบข้อผิดพลาดในการเล่นซ้ำหลายครั้ง ไปที่ การตั้งค่า > การวินิจฉัยและข้อเสนอแนะ เพื่อส่งออกบันทึก',
			'mediaPlayer.openSettingsAction' => 'ดู',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'การแจ้งเตือนการเล่น: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'โปรดตรวจสอบเครือข่าย การเล่นอาจกระตุก',
			'mediaPlayer.notice.audioTrackUnavailable' => 'ไม่มีเสียง วิดีโอยังคงเล่นต่อไป',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'สลับไปใช้การถอดรหัสด้วยซอฟต์แวร์ อาจใช้พลังงานแบตเตอรี่มากขึ้น',
			'mediaPlayer.notice.videoDecodeProblem' => 'ลองเปลี่ยนความละเอียด ภาพอาจมีอาการกระตุกหรือแตก',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'ส่งออกบันทึกเพื่อรายงานปัญหาการเล่นซ้ำๆ',
			'mediaPlayer.notice.issuesSheetTitle' => 'ปัญหาการเล่น',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'เกิดขึ้น ${count} ครั้ง',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'ที่ตำแหน่ง ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'ไม่มีบันทึกปัญหา',
			'mediaPlayer.notice.exportLogsAction' => 'ส่งออกบันทึก',
			'mediaPlayer.imageLoadFailed' => 'โหลดรูปภาพไม่สำเร็จ',
			'mediaPlayer.unsupportedImageFormat' => 'รูปแบบรูปภาพที่ไม่รองรับ',
			'mediaPlayer.tryOtherViewer' => 'โปรดลองใช้โปรแกรมดูภาพอื่น',
			'diagnostics.infoSectionTitle' => 'ข้อมูลการวินิจฉัย',
			'diagnostics.appVersionLabel' => 'เวอร์ชันแอป',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'การใช้หน่วยความจำ: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'ไม่สามารถรับข้อมูลอุปกรณ์ได้',
			'diagnostics.secureStorageLabel' => 'พื้นที่จัดเก็บที่ปลอดภัย',
			'diagnostics.secureStorageHealthy' => 'พร้อมใช้งาน',
			'diagnostics.secureStorageRecovered' => 'กู้คืนตัวเองด้วยการรีเซ็ตแล้ว (ข้อมูลก่อนหน้าถูกล้าง)',
			'diagnostics.secureStorageUnavailable' => 'ไม่พร้อมใช้งาน (บันทึกสถานะการเข้าสู่ระบบด้วยการเข้ารหัสสำรอง)',
			'diagnostics.secureStoragePlatformOptOut' => 'การเข้ารหัสในเครื่องตามนโยบายแพลตฟอร์ม (ไม่ได้ใช้พวงกุญแจระบบบน macOS)',
			'diagnostics.secureStorageDualWrite' => ' (เปิดการป้องกันการเขียนคู่)',
			'diagnostics.schemaHealthLabel' => 'โครงสร้างฐานข้อมูล',
			'diagnostics.schemaHealthOk' => 'ปกติ',
			'diagnostics.schemaHealthRepairedNow' => 'ได้รับการซ่อมแซมโดยเครือข่ายความปลอดภัยในการเปิดตัวครั้งนี้ (การโยกย้ายไม่มีผล)',
			'diagnostics.schemaHealthRepairedBefore' => 'เคยได้รับการซ่อมแซมโดยเครือข่ายความปลอดภัยมาก่อน',
			'diagnostics.logPolicySectionTitle' => 'นโยบายบันทึก',
			'diagnostics.configServiceUnavailable' => 'บริการกำหนดค่ายังไม่ได้เริ่มต้น ไม่สามารถปรับนโยบายบันทึกได้',
			'diagnostics.enableLoggingTitle' => 'เปิดใช้งานการบันทึก',
			'diagnostics.enableLoggingSubtitle' => 'ปิดใช้งานเพื่อหยุดการเขียนบันทึกใหม่',
			'diagnostics.enableLogPersistenceTitle' => 'เปิดใช้งานการคงอยู่ของบันทึก',
			'diagnostics.enableLogPersistenceSubtitle' => 'ปิดใช้งานเพื่อเก็บบันทึกไว้ในหน่วยความจำเท่านั้นและหยุดการเขียนลงดิสก์',
			'diagnostics.minLogLevelTitle' => 'ระดับบันทึกขั้นต่ำ',
			'diagnostics.minLogLevelSubtitle' => 'บันทึกที่ต่ำกว่าระดับนี้จะถูกกรองออก',
			'diagnostics.maxFileSizeTitle' => 'จำกัดขนาดไฟล์เดี่ยว',
			'diagnostics.maxFileSizeSubtitle' => 'หมุนเวียนไฟล์เมื่อถึงเกณฑ์',
			'diagnostics.rotatedFileCountTitle' => 'จำนวนไฟล์หมุนเวียนบันทึกหลัก',
			'diagnostics.rotatedFileCountSubtitle' => 'จำนวนไฟล์ที่เก็บรักษาไว้ไม่รวมไฟล์ปัจจุบัน',
			'diagnostics.hangFileSizeTitle' => 'จำกัดขนาดบันทึกอาการค้าง',
			'diagnostics.hangFileSizeSubtitle' => 'ควบคุมการเติบโตของไฟล์ hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'จำนวนไฟล์หมุนเวียนบันทึกอาการค้าง',
			'diagnostics.hangRotatedFileCountSubtitle' => 'ควบคุมประวัติที่เก็บรักษาไว้สำหรับ hang_events',
			'diagnostics.healthSectionTitle' => 'ความสมบูรณ์ของบันทึก',
			'diagnostics.refreshMetrics' => 'รีเฟรชเมตริก',
			'diagnostics.toolsSectionTitle' => 'เครื่องมือ',
			'diagnostics.privacyNotice' => 'บันทึกอาจมีข้อมูลที่ละเอียดอ่อน เช่น ข้อมูลบัญชีและพารามิเตอร์คำขอ โปรดอย่าโพสต์บันทึกฉบับเต็มต่อสาธารณะใน Issues ตรวจสอบก่อนแล้วจึงส่งทางอีเมล',
			'diagnostics.exportLogsTitle' => 'ส่งออกบันทึก',
			'diagnostics.exportLogsSubtitle' => 'ตรวจสอบข้อมูลความเป็นส่วนตัวก่อนส่งให้นักพัฒนา',
			'diagnostics.viewLogsTitle' => 'ดูบันทึก',
			'diagnostics.viewLogsSubtitle' => 'ดูบันทึกขณะรันไทม์แบบเรียลไทม์',
			'diagnostics.copySupportEmailTitle' => 'คัดลอกอีเมลสนับสนุน',
			'diagnostics.reportIssueTitle' => 'รายงานปัญหา',
			'diagnostics.reportIssueSubtitle' => 'ระบุขั้นตอนการจำลองปัญหาบน GitHub (แนบเฉพาะบันทึกที่จำเป็น ไม่แนบบันทึกฉบับเต็ม)',
			'diagnostics.healthSummaryUnavailable' => 'ยังไม่มีข้อมูลความสมบูรณ์ของบันทึก',
			'diagnostics.healthMetricsUnavailable' => 'ยังไม่ได้รวบรวมเมตริกความสมบูรณ์',
			'diagnostics.healthNoRiskIndicators' => 'ตรวจไม่พบตัวบ่งชี้ความเสี่ยง',
			'diagnostics.healthAlert.flushFailureTitle' => 'การล้างข้อมูลบันทึก (Flush) ล้มเหลว',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'ประสิทธิภาพการเขียนบันทึกลดลง',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'File sink อยู่ในสถานะประสิทธิภาพลดลง',
			'diagnostics.healthAlert.queueBacklogTitle' => 'คิวการเขียนค้างสะสม',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (threshold=${threshold}, อาจเพิ่มการใช้หน่วยความจำ)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'เวลาแฝงในการล้างข้อมูลบันทึกสูง',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'บันทึกถูกทิ้งมากเกินไป',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (เกณฑ์=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'ถูกจำกัดอัตราการเขียน',
			'diagnostics.healthAlert.exportFailedTitle' => 'ส่งออกบันทึกล้มเหลว',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'ไฟล์บันทึกใกล้ถึงขีดจำกัดขนาด',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (แรงกดดันการหมุนเวียน IO สูงขึ้น)',
			'diagnostics.toast.logServiceNotInitialized' => 'บริการบันทึกยังไม่ได้เริ่มต้น',
			'diagnostics.toast.exportSuccess' => 'ส่งออกบันทึกแล้ว โปรดตรวจสอบข้อมูลความเป็นส่วนตัวก่อนส่งทางอีเมล',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'ส่งออกล้มเหลว: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'คัดลอกอีเมลสนับสนุนแล้ว วางลงในโปรแกรมรับส่งอีเมลของคุณและแนบบันทึก',
			'diagnostics.shareSubject' => 'บันทึกการวินิจฉัย LoveIwara (มีข้อมูลที่ละเอียดอ่อน โปรดแชร์ด้วยความระมัดระวัง)',
			'logViewer.title' => 'โปรแกรมดูบันทึก',
			'logViewer.searchHint' => 'ค้นหาบันทึก...',
			'logViewer.emptyState' => 'ไม่มีบันทึก',
			'logViewer.copiedToClipboard' => 'คัดลอกไปยังคลิปบอร์ดแล้ว',
			'crashRecoveryDialog.title' => 'แอปปิดตัวลงอย่างไม่คาดคิด',
			'crashRecoveryDialog.description' => 'เราตรวจพบการปิดตัวลงอย่างผิดปกติในเซสชันล่าสุด โปรดส่งออกบันทึกการวินิจฉัยและส่งอีเมลไปยังนักพัฒนาเพื่อช่วยเราแก้ไขปัญหา',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'เวอร์ชันล่าสุด: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'เปิดใช้งานล่าสุด: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'ข้อยกเว้นล่าสุด: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'ตรวจพบอาการค้างของ UI ในครั้งล่าสุด และกู้คืนโดยอัตโนมัติแล้ว',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'ตรวจพบความเป็นไปได้ที่ UI จะค้างในครั้งล่าสุด โดยกินเวลาประมาณ ${stalledMs}ms',
			'crashRecoveryDialog.exportGuide' => 'ไปที่ การตั้งค่า > การวินิจฉัยและข้อเสนอแนะ > ส่งออกบันทึก',
			'crashRecoveryDialog.privacyHint' => 'บันทึกอาจมีข้อมูลส่วนตัว โปรดตรวจสอบก่อนส่งอีเมลไปที่:',
			'crashRecoveryDialog.issueWarning' => 'อย่าแนบบันทึกฉบับเต็มต่อสาธารณะใน GitHub Issues',
			'crashRecoveryDialog.acknowledge' => 'รับทราบ',
			'crashRecoveryDialog.supportEmailCopied' => 'คัดลอกอีเมลแล้ว',
			'linkInputDialog.title' => 'ป้อนลิงก์',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'รองรับการระบุลิงก์ ${webName} หลายรายการอย่างชาญฉลาด และข้ามไปยังหน้าที่เกี่ยวข้องในแอปอย่างรวดเร็ว (คั่นลิงก์ออกจากข้อความอื่นด้วยการเว้นวรรค)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'โปรดป้อนลิงก์ ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'โปรดป้อนลิงก์',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'ตรวจไม่พบลิงก์ ${webName} ที่ถูกต้อง',
			'linkInputDialog.multipleLinksDetected' => 'ตรวจพบหลายลิงก์ โปรดเลือกหนึ่งรายการ:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'ไม่ใช่ลิงก์ ${webName} ที่ถูกต้อง',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'ข้อผิดพลาดในการแยกวิเคราะห์ลิงก์: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'ลิงก์ที่ไม่รองรับ',
			'linkInputDialog.unsupportedLinkDialogContent' => 'ประเภทลิงก์นี้ไม่สามารถเปิดได้โดยตรงในแอป และจำเป็นต้องเข้าถึงโดยใช้เบราว์เซอร์ภายนอก\n\nคุณต้องการเปิดลิงก์นี้ในเบราว์เซอร์หรือไม่?',
			'linkInputDialog.openInBrowser' => 'เปิดในเบราว์เซอร์',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'ยืนยันการเปิดเบราว์เซอร์',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'ลิงก์ต่อไปนี้กำลังจะถูกเปิดในเบราว์เซอร์ภายนอก:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'คุณแน่ใจหรือไม่ว่าต้องการดำเนินการต่อ?',
			'linkInputDialog.browserOpenFailed' => 'เปิดลิงก์ไม่สำเร็จ',
			'linkInputDialog.unsupportedLink' => 'ลิงก์ที่ไม่รองรับ',
			'linkInputDialog.cancel' => 'ยกเลิก',
			'linkInputDialog.confirm' => 'เปิดในเบราว์เซอร์',
			'log.logManagement' => 'การจัดการบันทึก',
			'log.enableLogPersistence' => 'เปิดใช้งานการคงอยู่ของบันทึก',
			'log.enableLogPersistenceDesc' => 'บันทึกประวัติลงในฐานข้อมูลเพื่อนำไปวิเคราะห์',
			'log.logDatabaseSizeLimit' => 'จำกัดขนาดฐานข้อมูลบันทึก',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'ปัจจุบัน: ${size}',
			'log.exportCurrentLogs' => 'ส่งออกบันทึกปัจจุบัน',
			'log.exportCurrentLogsDesc' => 'ส่งออกบันทึกแอปพลิเคชันปัจจุบันเพื่อช่วยนักพัฒนาวินิจฉัยปัญหา',
			'log.exportHistoryLogs' => 'ส่งออกบันทึกย้อนหลัง',
			'log.exportHistoryLogsDesc' => 'ส่งออกบันทึกภายในช่วงวันที่ที่ระบุ',
			'log.exportMergedLogs' => 'ส่งออกบันทึกรวม',
			'log.exportMergedLogsDesc' => 'ส่งออกบันทึกรวมภายในช่วงวันที่ที่ระบุ',
			'log.showLogStats' => 'แสดงสถิติต่างๆ ของบันทึก',
			'log.logExportSuccess' => 'ส่งออกบันทึกสำเร็จ',
			'log.logExportFailed' => ({required Object error}) => 'ส่งออกบันทึกล้มเหลว: ${error}',
			'log.showLogStatsDesc' => 'ดูสถิติของบันทึกประเภทต่างๆ',
			'log.logExtractFailed' => ({required Object error}) => 'รับสถิติบันทึกไม่สำเร็จ: ${error}',
			'log.clearAllLogs' => 'ล้างบันทึกทั้งหมด',
			'log.clearAllLogsDesc' => 'ล้างข้อมูลบันทึกทั้งหมด',
			'log.confirmClearAllLogs' => 'ยืนยันการล้าง',
			'log.confirmClearAllLogsDesc' => 'คุณแน่ใจหรือไม่ว่าต้องการล้างข้อมูลบันทึกทั้งหมด? การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'log.clearAllLogsSuccess' => 'ล้างบันทึกสำเร็จแล้ว',
			'log.clearAllLogsFailed' => ({required Object error}) => 'ล้างบันทึกไม่สำเร็จ: ${error}',
			'log.unableToGetLogSizeInfo' => 'ไม่สามารถรับข้อมูลขนาดบันทึกได้',
			'log.currentLogSize' => 'ขนาดบันทึกปัจจุบัน:',
			'log.logCount' => 'จำนวนบันทึก:',
			'log.logCountUnit' => 'รายการ',
			'log.logSizeLimit' => 'ขีดจำกัดขนาดบันทึก:',
			'log.usageRate' => 'อัตราการใช้งาน:',
			'log.exceedLimit' => 'เกินขีดจำกัด',
			'log.remaining' => 'ที่เหลือ',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'ขนาดบันทึกปัจจุบันเกินขีดจำกัดแล้ว โปรดล้างบันทึกเก่าหรือเพิ่มขีดจำกัดขนาดบันทึก',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'ขนาดบันทึกปัจจุบันใกล้เต็มแล้ว โปรดล้างบันทึกเก่า',
			'log.cleaningOldLogs' => 'กำลังล้างบันทึกเก่า...',
			'log.logCleaningCompleted' => 'ล้างบันทึกเสร็จสมบูรณ์แล้ว',
			'log.logCleaningProcessMayNotBeCompleted' => 'กระบวนการล้างบันทึกอาจยังไม่เสร็จสมบูรณ์',
			'log.cleanExceededLogs' => 'ล้างบันทึกที่เกินขีดจำกัด',
			'log.noLogsToExport' => 'ไม่มีบันทึกที่จะส่งออก',
			'log.exportingLogs' => 'กำลังส่งออกบันทึก...',
			'log.noHistoryLogsToExport' => 'ไม่มีประวัติบันทึกให้ส่งออก โปรดลองใช้แอปสักระยะหนึ่งก่อน',
			'log.selectLogDate' => 'เลือกวันที่บันทึก',
			'log.today' => 'วันนี้',
			'log.selectMergeRange' => 'เลือกช่วงที่จะรวม',
			'log.selectMergeRangeHint' => 'โปรดเลือกช่วงเวลาบันทึกที่จะรวม',
			'log.selectMergeRangeDays' => ({required Object days}) => '${days} วันล่าสุด',
			'log.logStats' => 'สถิติต่างๆ ของบันทึก',
			'log.todayLogs' => ({required Object count}) => 'บันทึกของวันนี้: ${count} รายการ',
			'log.recent7DaysLogs' => ({required Object count}) => 'บันทึก 7 วันล่าสุด: ${count} รายการ',
			'log.totalLogs' => ({required Object count}) => 'บันทึกทั้งหมด: ${count} รายการ',
			'log.setLogDatabaseSizeLimit' => 'ตั้งค่าขีดจำกัดขนาดฐานข้อมูลบันทึก',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'ขนาดบันทึกปัจจุบัน: ${size}',
			'log.warning' => 'คำเตือน',
			'log.newSizeLimit' => ({required Object size}) => 'ขีดจำกัดขนาดใหม่: ${size}',
			'log.confirmToContinue' => 'ยืนยันเพื่อดำเนินการต่อ',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'ตั้งค่าขีดจำกัดขนาดบันทึกเป็น ${size} แล้ว',
			'emoji.recentlyUsed' => 'ใช้ล่าสุด',
			'emoji.insertedCount' => ({required Object count}) => 'แทรกแล้ว ${count} รายการ',
			'emoji.name' => 'อีโมจิ',
			'emoji.size' => 'ขนาด',
			'emoji.small' => 'เล็ก',
			'emoji.medium' => 'ปานกลาง',
			'emoji.large' => 'ใหญ่',
			'emoji.extraLarge' => 'ใหญ่พิเศษ',
			'emoji.copyEmojiLinkSuccess' => 'คัดลอกลิงก์อีโมจิแล้ว',
			'emoji.preview' => 'ตัวอย่างอีโมจิ',
			'emoji.library' => 'คลังอีโมจิ',
			'emoji.noEmojis' => 'ไม่มีอีโมจิ',
			'emoji.clickToAddEmojis' => 'คลิกปุ่มที่มุมขวาบนเพื่อเพิ่มอีโมจิ',
			'emoji.addEmojis' => 'เพิ่มอีโมจิ',
			'emoji.imagePreview' => 'ตัวอย่างรูปภาพ',
			'emoji.imageLoadFailed' => 'โหลดรูปภาพไม่สำเร็จ',
			'emoji.loading' => 'กำลังโหลด...',
			'emoji.delete' => 'ลบ',
			'emoji.close' => 'ปิด',
			'emoji.deleteImage' => 'ลบรูปภาพ',
			'emoji.confirmDeleteImage' => 'คุณแน่ใจหรือไม่ว่าต้องการลบรูปภาพนี้?',
			'emoji.cancel' => 'ยกเลิก',
			'emoji.batchDelete' => 'ลบเป็นชุด',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'คุณแน่ใจหรือไม่ว่าต้องการลบรูปภาพที่เลือก ${count} รูป? การดำเนินการนี้ไม่สามารถยกเลิกได้',
			'emoji.deleteSuccess' => 'ลบสำเร็จแล้ว',
			'emoji.addImage' => 'เพิ่มรูปภาพ',
			'emoji.addImageByUrl' => 'เพิ่มด้วย URL',
			'emoji.addImageUrl' => 'เพิ่ม URL รูปภาพ',
			'emoji.imageUrl' => 'URL รูปภาพ',
			'emoji.enterImageUrl' => 'โปรดป้อน URL รูปภาพ',
			'emoji.add' => 'เพิ่ม',
			'emoji.batchImport' => 'นำเข้าเป็นชุด',
			'emoji.enterJsonUrlArray' => 'โปรดป้อนอาร์เรย์ URL รูปแบบ JSON:',
			'emoji.formatExample' => 'ตัวอย่างรูปแบบ:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'โปรดวางอาร์เรย์ URL รูปแบบ JSON',
			'emoji.import' => 'นำเข้า',
			'emoji.importSuccess' => ({required Object count}) => 'นำเข้ารูปภาพ ${count} รูปสำเร็จแล้ว',
			'emoji.jsonFormatError' => 'รูปแบบ JSON ผิดพลาด โปรดตรวจสอบข้อมูลที่ป้อน',
			'emoji.createGroup' => 'สร้างกลุ่มอีโมจิ',
			'emoji.groupName' => 'ชื่อกลุ่ม',
			'emoji.enterGroupName' => 'โปรดป้อนชื่อกลุ่ม',
			'emoji.create' => 'สร้าง',
			'emoji.editGroupName' => 'แก้ไขชื่อกลุ่ม',
			'emoji.save' => 'บันทึก',
			'emoji.deleteGroup' => 'ลบกลุ่ม',
			'emoji.confirmDeleteGroup' => 'คุณแน่ใจหรือไม่ว่าต้องการลบกลุ่มอีโมจินี้? รูปภาพทั้งหมดในกลุ่มจะถูกลบไปด้วย',
			'emoji.imageCount' => ({required Object count}) => '${count} รูปภาพ',
			'emoji.selectEmoji' => 'เลือกอีโมจิ',
			'emoji.noEmojisInGroup' => 'ไม่มีอีโมจิในกลุ่มนี้',
			'emoji.goToSettingsToAddEmojis' => 'ไปที่การตั้งค่าเพื่อเพิ่มอีโมจิ',
			'emoji.emojiManagement' => 'การจัดการอีโมจิ',
			'emoji.manageEmojiGroupsAndImages' => 'จัดการกลุ่มอีโมจิและรูปภาพ',
			'emoji.uploadLocalImages' => 'อัปโหลดรูปภาพในเครื่อง',
			'emoji.uploadingImages' => 'กำลังอัปโหลดรูปภาพ',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'กำลังอัปโหลดรูปภาพ ${count} รูป โปรดรอสักครู่...',
			'emoji.doNotCloseDialog' => 'โปรดอย่าปิดกล่องโต้ตอบนี้',
			'emoji.uploadSuccess' => ({required Object count}) => 'อัปโหลดรูปภาพ ${count} รูปสำเร็จแล้ว',
			'emoji.uploadFailed' => ({required Object count}) => 'ล้มเหลว ${count} รูป',
			'emoji.uploadFailedMessage' => 'อัปโหลดรูปภาพไม่สำเร็จ โปรดตรวจสอบการเชื่อมต่อเครือข่ายหรือรูปแบบไฟล์',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'เกิดข้อผิดพลาดระหว่างการอัปโหลด: ${error}',
			'searchFilter.selectField' => 'เลือกฟิลด์',
			'searchFilter.add' => 'เพิ่ม',
			'searchFilter.clear' => 'ล้าง',
			'searchFilter.clearAll' => 'ล้างทั้งหมด',
			'searchFilter.generatedQuery' => 'คำค้นที่สร้างขึ้น',
			'searchFilter.copyToClipboard' => 'คัดลอกไปยังคลิปบอร์ด',
			'searchFilter.copied' => 'คัดลอกแล้ว',
			'searchFilter.filterCount' => ({required Object count}) => '${count} ตัวกรอง',
			'searchFilter.filterSettings' => 'การตั้งค่าตัวกรอง',
			'searchFilter.field' => 'ฟิลด์',
			'searchFilter.operator' => 'ตัวดำเนินการ',
			'searchFilter.language' => 'ภาษา',
			'searchFilter.value' => 'ค่า',
			'searchFilter.dateRange' => 'ช่วงวันที่',
			'searchFilter.numberRange' => 'ช่วงตัวเลข',
			'searchFilter.from' => 'จาก',
			'searchFilter.to' => 'ถึง',
			'searchFilter.date' => 'วันที่',
			'searchFilter.number' => 'ตัวเลข',
			'searchFilter.boolean' => 'บูลีน',
			'searchFilter.tags' => 'แท็ก',
			'searchFilter.select' => 'เลือก',
			'searchFilter.clickToSelectDate' => 'คลิกเพื่อเลือกวันที่',
			'searchFilter.pleaseEnterValidNumber' => 'โปรดกรอกตัวเลขที่ถูกต้อง',
			'searchFilter.pleaseEnterValidDate' => 'โปรดกรอกวันที่ในรูปแบบที่ถูกต้อง (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'ค่าเริ่มต้นต้องน้อยกว่าค่าสิ้นสุด',
			'searchFilter.startDateMustBeBeforeEndDate' => 'วันที่เริ่มต้นต้องอยู่ก่อนวันที่สิ้นสุด',
			'searchFilter.pleaseFillStartValue' => 'โปรดกรอกค่าเริ่มต้น',
			'searchFilter.pleaseFillEndValue' => 'โปรดกรอกค่าสิ้นสุด',
			'searchFilter.rangeValueFormatError' => 'รูปแบบค่าช่วงไม่ถูกต้อง',
			'searchFilter.contains' => 'มีคำว่า',
			'searchFilter.equals' => 'เท่ากับ',
			'searchFilter.notEquals' => 'ไม่เท่ากับ',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'ช่วง',
			'searchFilter.kIn' => 'มีอย่างใดอย่างหนึ่ง',
			'searchFilter.notIn' => 'ไม่มีอย่างใดอย่างหนึ่ง',
			'searchFilter.username' => 'ชื่อผู้ใช้',
			'searchFilter.nickname' => 'ชื่อเล่น',
			'searchFilter.registrationDate' => 'วันที่ลงทะเบียน',
			'searchFilter.description' => 'คำอธิบาย',
			'searchFilter.title' => 'ชื่อเรื่อง',
			'searchFilter.body' => 'เนื้อหา',
			'searchFilter.author' => 'ผู้สร้าง',
			'searchFilter.publishDate' => 'วันที่เผยแพร่',
			'searchFilter.private' => 'ส่วนตัว',
			'searchFilter.duration' => 'ระยะเวลา (วินาที)',
			'searchFilter.likes' => 'ถูกใจ',
			'searchFilter.views' => 'ยอดชม',
			'searchFilter.comments' => 'ความคิดเห็น',
			'searchFilter.rating' => 'คะแนน',
			'searchFilter.imageCount' => 'จำนวนรูปภาพ',
			'searchFilter.videoCount' => 'จำนวนวิดีโอ',
			'searchFilter.createDate' => 'วันที่สร้าง',
			'searchFilter.content' => 'เนื้อหา',
			'searchFilter.all' => 'ทั้งหมด',
			'searchFilter.adult' => 'ผู้ใหญ่',
			'searchFilter.general' => 'ทั่วไป',
			'searchFilter.yes' => 'ใช่',
			'searchFilter.no' => 'ไม่',
			'searchFilter.users' => 'ผู้ใช้',
			'searchFilter.videos' => 'วิดีโอ',
			'searchFilter.images' => 'รูปภาพ',
			'searchFilter.posts' => 'โพสต์',
			'searchFilter.forumThreads' => 'กระทู้ในฟอรัม',
			'searchFilter.forumPosts' => 'โพสต์ในฟอรัม',
			'searchFilter.playlists' => 'เพลย์ลิสต์',
			'searchFilter.sortTypes.relevance' => 'ความเกี่ยวข้อง',
			'searchFilter.sortTypes.latest' => 'ล่าสุด',
			'searchFilter.sortTypes.views' => 'ยอดชม',
			'searchFilter.sortTypes.likes' => 'ถูกใจ',
			'searchFilter.drawerSubtitle' => 'การเปลี่ยนแปลงมีผลทันที',
			'firstTimeSetup.welcome.title' => 'ยินดีต้อนรับ',
			'firstTimeSetup.welcome.subtitle' => 'มาเริ่มต้นการตั้งค่าเฉพาะบุคคลของคุณกัน',
			'firstTimeSetup.welcome.description' => 'เพียงไม่กี่ขั้นตอนเพื่อปรับแต่งประสบการณ์ที่ดีที่สุดให้คุณ',
			'firstTimeSetup.basic.title' => 'การตั้งค่าพื้นฐาน',
			'firstTimeSetup.basic.subtitle' => 'ปรับแต่งประสบการณ์ของคุณ',
			'firstTimeSetup.basic.description' => 'เลือกการตั้งค่าที่เหมาะกับคุณ',
			'firstTimeSetup.network.title' => 'การตั้งค่าเครือข่าย',
			'firstTimeSetup.network.subtitle' => 'ตั้งค่าตัวเลือกเครือข่าย',
			'firstTimeSetup.network.description' => 'ปรับตามสภาพเครือข่ายของคุณ',
			'firstTimeSetup.network.tip' => 'ต้องรีสตาร์ทหลังตั้งค่าสำเร็จจึงจะมีผล',
			'firstTimeSetup.theme.title' => 'การตั้งค่าธีม',
			'firstTimeSetup.theme.subtitle' => 'เลือกธีมที่คุณชื่นชอบ',
			'firstTimeSetup.theme.description' => 'ปรับแต่งประสบการณ์ทางสายตาของคุณ',
			'firstTimeSetup.player.title' => 'การตั้งค่าโปรแกรมเล่น',
			'firstTimeSetup.player.subtitle' => 'ตั้งค่าการควบคุมการเล่น',
			'firstTimeSetup.player.description' => 'ตั้งค่าการเล่นที่ใช้บ่อยได้อย่างรวดเร็ว',
			'firstTimeSetup.spatial.title' => 'การเล่นแบบเชิงพื้นที่',
			'firstTimeSetup.spatial.subtitle' => 'การรับชมและเรียกดูบนชุดหูฟัง',
			'firstTimeSetup.spatial.description' => 'บนชุดหูฟัง วิดีโอและแกลเลอรีจะปรากฏในพื้นที่รอบตัวคุณแทนที่จะอยู่ในแผงลอยนี้',
			'firstTimeSetup.completion.title' => 'ตั้งค่าเสร็จสมบูรณ์',
			'firstTimeSetup.completion.subtitle' => 'คุณพร้อมที่จะเริ่มต้นการเดินทางแล้ว',
			'firstTimeSetup.completion.description' => 'โปรดอ่านและยอมรับข้อตกลงที่เกี่ยวข้อง',
			'firstTimeSetup.completion.agreementTitle' => 'ข้อตกลงผู้ใช้และกฎของชุมชน',
			'firstTimeSetup.completion.agreementDesc' => 'ก่อนใช้แอปนี้ โปรดอ่านและยอมรับข้อตกลงผู้ใช้และกฎของชุมชนอย่างละเอียด ข้อกำหนดเหล่านี้ช่วยรักษาสภาพแวดล้อมที่ดี',
			'firstTimeSetup.completion.checkboxTitle' => 'ข้าพเจ้าได้อ่านและยอมรับข้อตกลงผู้ใช้และกฎของชุมชนแล้ว',
			'firstTimeSetup.completion.checkboxSubtitle' => 'หากไม่ยอมรับจะไม่สามารถใช้แอปได้',
			'firstTimeSetup.common.settingsChangeableTip' => 'การตั้งค่าเหล่านี้เปลี่ยนได้ทุกเมื่อในการตั้งค่า',
			'firstTimeSetup.common.previousStep' => 'ขั้นตอนก่อนหน้า',
			'firstTimeSetup.common.nextStep' => 'ขั้นตอนถัดไป',
			'firstTimeSetup.common.finishSetup' => 'เสร็จสิ้นการตั้งค่า',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'โปรดยอมรับข้อตกลงผู้ใช้และกฎของชุมชนก่อน',
			'proxyHelper.systemProxyDetected' => 'ตรวจพบพร็อกซีของระบบ',
			'proxyHelper.copied' => 'คัดลอกแล้ว',
			'proxyHelper.copy' => 'คัดลอก',
			'tagSelector.selectTags' => 'เลือกแท็ก',
			'tagSelector.clickToSelectTags' => 'คลิกเพื่อเลือกแท็ก',
			'tagSelector.addTag' => 'เพิ่มแท็ก',
			'tagSelector.removeTag' => 'เอาแท็กออก',
			'tagSelector.deleteTag' => 'ลบแท็ก',
			'tagSelector.usageInstructions' => 'เพิ่มแท็กก่อน จากนั้นจึงคลิกเลือกจากแท็กที่มีอยู่',
			'tagSelector.usageInstructionsTooltip' => 'คำแนะนำการใช้งาน',
			'tagSelector.addTagTooltip' => 'เพิ่มแท็ก',
			'tagSelector.removeTagTooltip' => 'เอาแท็กออก',
			'tagSelector.cancelSelection' => 'ยกเลิกการเลือก',
			'tagSelector.selectAll' => 'เลือกทั้งหมด',
			'tagSelector.cancelSelectAll' => 'ยกเลิกเลือกทั้งหมด',
			'tagSelector.delete' => 'ลบ',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'การขยายภาพและลดสัญญาณรบกวนวิดีโอแบบเรียลไทม์ ช่วยยกระดับคุณภาพวิดีโออนิเมชัน',
			'anime4k.settings' => 'การตั้งค่า Anime4K',
			'anime4k.preset' => 'พรีเซ็ต Anime4K',
			'anime4k.disable' => 'ปิด Anime4K',
			'anime4k.disableDescription' => 'ปิดเอฟเฟกต์เพิ่มคุณภาพวิดีโอ',
			'anime4k.highQualityPresets' => 'พรีเซ็ตคุณภาพสูง',
			'anime4k.fastPresets' => 'พรีเซ็ตแบบเร็ว',
			'anime4k.litePresets' => 'พรีเซ็ตแบบเบา',
			'anime4k.moreLitePresets' => 'พรีเซ็ตแบบเบายิ่งขึ้น',
			'anime4k.customPresets' => 'พรีเซ็ตกำหนดเอง',
			'anime4k.presetGroups.highQuality' => 'คุณภาพสูง',
			'anime4k.presetGroups.fast' => 'เร็ว',
			'anime4k.presetGroups.lite' => 'เบา',
			'anime4k.presetGroups.moreLite' => 'เบายิ่งขึ้น',
			'anime4k.presetGroups.custom' => 'กำหนดเอง',
			'anime4k.presetDescriptions.mode_a_hq' => 'เหมาะกับอนิเมชัน 1080p ส่วนใหญ่ โดยเฉพาะที่ต้องรับมือกับความเบลอ การรีแซมเพิล และอาร์ติแฟกต์จากการบีบอัด ให้คุณภาพที่รับรู้ได้สูงสุด',
			'anime4k.presetDescriptions.mode_b_hq' => 'เหมาะกับอนิเมชันที่มีความเบลอหรือเงาสะท้อนเล็กน้อยจากการปรับขนาด ช่วยลดเงาสะท้อนและรอยหยักได้อย่างมีประสิทธิภาพ',
			'anime4k.presetDescriptions.mode_c_hq' => 'เหมาะกับแหล่งคุณภาพสูง (เช่น อนิเมชันหรือภาพยนตร์ 1080p แท้) ลดสัญญาณรบกวนและให้ค่า PSNR สูงสุด',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'เวอร์ชันเสริมของ Mode A ให้คุณภาพที่รับรู้ได้สูงสุดและสามารถสร้างเส้นที่เสื่อมสภาพเกือบทั้งหมดขึ้นมาใหม่ อาจเกิดภาพคมเกินไปหรือเงาสะท้อน',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'เวอร์ชันเสริมของ Mode B ให้คุณภาพที่รับรู้ได้สูงขึ้น ปรับแต่งเส้นให้ดียิ่งขึ้นและลดอาร์ติแฟกต์',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'เวอร์ชันเสริมคุณภาพที่รับรู้ได้ของ Mode C รักษาค่า PSNR ให้สูงพร้อมพยายามสร้างรายละเอียดเส้นบางส่วนขึ้นมาใหม่',
			'anime4k.presetDescriptions.mode_a_fast' => 'เวอร์ชันเร็วของ Mode A สมดุลระหว่างคุณภาพและสมรรถนะ เหมาะกับอนิเมชัน 1080p ส่วนใหญ่',
			'anime4k.presetDescriptions.mode_b_fast' => 'เวอร์ชันเร็วของ Mode B สำหรับจัดการอาร์ติแฟกต์และเงาสะท้อนเล็กน้อยด้วยภาระที่ต่ำลง',
			'anime4k.presetDescriptions.mode_c_fast' => 'เวอร์ชันเร็วของ Mode C สำหรับการลดสัญญาณรบกวนและขยายภาพของแหล่งคุณภาพสูงอย่างรวดเร็ว',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'เวอร์ชันเร็วของ Mode A+A เน้นคุณภาพที่รับรู้ได้สูงขึ้นบนอุปกรณ์ที่มีข้อจำกัดด้านสมรรถนะ',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'เวอร์ชันเร็วของ Mode B+B ให้การซ่อมแซมเส้นและการจัดการอาร์ติแฟกต์ที่ดีขึ้นสำหรับอุปกรณ์ที่มีข้อจำกัดด้านสมรรถนะ',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'เวอร์ชันเร็วของ Mode C+A ประมวลผลแหล่งคุณภาพสูงได้อย่างรวดเร็วพร้อมให้การซ่อมแซมเส้นแบบเบา',
			'anime4k.presetDescriptions.upscale_only_s' => 'การขยายภาพเป็น 2 เท่าความเร็วสูงสุดโดยใช้เฉพาะโมเดล CNN ที่เร็วที่สุด ไม่มีการซ่อมแซมและลดสัญญาณรบกวน ภาระต่ำสุด',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'การขยายภาพและลดความเบลอแบบเร็วด้วยอัลกอริทึมดั้งเดิมที่ไม่ใช้ CNN ดีกว่าอัลกอริทึมเริ่มต้นของโปรแกรมเล่นด้วยภาระที่ต่ำมาก',
			'anime4k.presetDescriptions.restore_s_only' => 'ซ่อมแซมเท่านั้นโดยใช้โมเดล CNN ที่เร็วที่สุด ไม่ขยายภาพ เหมาะกับการเล่นที่ความละเอียดแท้ที่ต้องการเพิ่มคุณภาพ',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'การลดสัญญาณรบกวนแบบเร็วด้วยตัวกรอง bilateral แบบดั้งเดิม เร็วมาก เหมาะกับการจัดการสัญญาณรบกวนเล็กน้อย',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'การขยายภาพแบบเร็วด้วยอัลกอริทึมดั้งเดิม ภาระต่ำมาก ดีกว่าค่าเริ่มต้นของโปรแกรมเล่น',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + การทำให้เส้นเข้มขึ้น เพิ่มเอฟเฟกต์ทำให้เส้นเข้มขึ้นบน Mode A แบบเร็ว เพื่อให้เส้นเด่นชัดและมีสไตล์ยิ่งขึ้น',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + การทำให้เส้นบางลง เพิ่มเอฟเฟกต์ทำให้เส้นบางลงบน Mode A คุณภาพสูง เพื่อให้ดูประณีตยิ่งขึ้น',
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
			'anime4k.presetNames.upscale_only_s' => 'ขยายภาพด้วย CNN (เร็วมาก)',
			'anime4k.presetNames.upscale_deblur_fast' => 'ขยายภาพและลดความเบลอ (เร็ว)',
			'anime4k.presetNames.restore_s_only' => 'การซ่อมแซม (เร็วมาก)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'ลดสัญญาณรบกวนแบบ Bilateral (เร็วมาก)',
			'anime4k.presetNames.upscale_non_cnn' => 'ขยายภาพแบบไม่ใช้ CNN (เร็วมาก)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + ทำให้เส้นเข้มขึ้น',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + ทำให้เส้นบางลง',
			'anime4k.performanceTip' => '💡 เคล็ดลับ: เลือกพรีเซ็ตให้เหมาะกับสมรรถนะของอุปกรณ์ อุปกรณ์สเปกต่ำแนะนำให้ใช้พรีเซ็ตแบบเบา',
			'anime4k.compatibilityTip' => '⚠️ GPU บนมือถือบางรุ่น (เช่น Kirin 980 / Mali-G76) ไม่สามารถเรนเดอร์เชดเดอร์แบบกำหนดเองได้ หากภาพกลายเป็นสีดำแต่เสียงยังเล่นต่อ ให้ปิด Anime4K ที่นี่',
			'anime4k.autoDisabledOnRenderFailure' => 'GPU ของอุปกรณ์ไม่สามารถเรนเดอร์เชดเดอร์ Anime4K ได้ จึงปิดใช้งานโดยอัตโนมัติ',
			'siteMode.title' => 'โหมดไซต์',
			'siteMode.mainSite' => 'ไซต์หลัก',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'ปัจจุบัน ${currentSite} · แตะเพื่อสลับเป็น ${nextSite}',
			'siteMode.dialogTitle' => 'สลับโหมดไซต์',
			'siteMode.dialogDescription' => 'การสลับจะรีเฟรชทั้งแอป และรีเซ็ตรายการที่โหลดไว้ก่อนหน้ากับสถานะของหน้า',
			'siteMode.chooseLinkTargetTitle' => 'เลือกไซต์ปลายทาง',
			'siteMode.chooseLinkTargetDescription' => 'ลิงก์นี้ไม่มีโดเมน โปรดเลือกว่าจะเปิดในไซต์หลักหรือ AI',
			'siteMode.chooseLinkTargetHint' => 'เมื่อเปิดแล้ว หน้านี้และคำขอรายละเอียดที่ตามมาจะใช้ไซต์ที่เลือกต่อไป',
			'siteMode.alreadyUsing' => 'คุณกำลังใช้โหมดไซต์นี้อยู่แล้ว',
			'siteMode.openInSite' => ({required Object site}) => 'เปิดใน ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'หลังยืนยัน คำขอต่อๆ ไปจะใช้โหมด ${site}',
			'siteMode.switched' => ({required Object site}) => 'สลับเป็น ${site} แล้ว แอปได้รีเฟรชเรียบร้อย',
			'savedSearchConfig.title' => 'ตัวกรองที่บันทึกไว้',
			'savedSearchConfig.empty' => 'ยังไม่มีตัวกรองที่บันทึกไว้',
			'savedSearchConfig.saveTooltip' => 'บันทึกตัวกรองปัจจุบัน',
			'savedSearchConfig.namePromptTitle' => 'บันทึกตัวกรอง',
			'savedSearchConfig.nameLabel' => 'ชื่อ',
			'savedSearchConfig.nameHint' => 'กรอกชื่อ',
			'savedSearchConfig.saveSuccess' => 'บันทึกตัวกรองแล้ว',
			'savedSearchConfig.deleteSuccess' => 'ลบตัวกรองแล้ว',
			'savedSearchConfig.addCurrent' => 'บันทึกตัวกรองปัจจุบัน',
			'savedSearchConfig.reorderHint' => 'กดค้างแล้วลากเพื่อจัดลำดับใหม่',
			'savedSearchConfig.rename' => 'เปลี่ยนชื่อ',
			'savedSearchConfig.unnamed' => 'ไม่มีชื่อ',
			'savedSearchConfig.noConditions' => 'เนื้อหาทั้งหมด (ไม่มีตัวกรอง)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} แท็ก',
			'savedSearch.title' => 'การค้นหาที่บันทึกไว้',
			'savedSearch.empty' => 'ยังไม่มีการค้นหาที่บันทึกไว้',
			'savedSearch.saveTooltip' => 'บันทึกการค้นหาปัจจุบัน',
			'savedSearch.namePromptTitle' => 'บันทึกการค้นหา',
			'savedSearch.nameLabel' => 'ชื่อ',
			'savedSearch.nameHint' => 'กรอกชื่อ',
			'savedSearch.saveSuccess' => 'บันทึกการค้นหาแล้ว',
			'savedSearch.deleteSuccess' => 'ลบการค้นหาแล้ว',
			'savedSearch.addCurrent' => 'บันทึกการค้นหาปัจจุบัน',
			'savedSearch.reorderHint' => 'กดค้างแล้วลากเพื่อจัดลำดับใหม่',
			'savedSearch.rename' => 'เปลี่ยนชื่อ',
			'savedSearch.noKeyword' => '(ไม่มีคำค้น)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} ตัวกรอง',
			'defaultBlacklistReminder.title' => 'ตรวจพบบัญชีดำแท็กเริ่มต้น',
			'defaultBlacklistReminder.content' => 'บัญชีของคุณยังใช้บัญชีดำแท็กที่เว็บไซต์ตั้งให้อัตโนมัติกับทุกบัญชีใหม่ ต้องการตรวจสอบและจัดการหรือไม่',
			'defaultBlacklistReminder.goManage' => 'จัดการ',
			'defaultBlacklistReminder.dismiss' => 'ไว้ก่อน',
			'colorVisionAssist.title' => 'ช่วยการมองเห็นสี',
			'colorVisionAssist.description' => 'ปรับสีวิดีโอให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี ใช้ร่วมกับ Anime4K ได้',
			'colorVisionAssist.galleryDescription' => 'ปรับสีภาพในแกลเลอรีให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี (ทำงานอิสระจากสวิตช์ของโปรแกรมเล่น)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'ปรับสีภาพในแกลเลอรีให้ผู้ชมที่มีความบกพร่องทางการมองเห็นสี ใช้ได้เฉพาะกับตัวดูภาพ 2D ในแผงนี้เท่านั้น — ภาพบนจอเชิงพื้นที่เรนเดอร์แบบเนทีฟและไม่ผ่านตัวกรองนี้',
			'colorVisionAssist.disable' => 'ปิด',
			'colorVisionAssist.disableDescription' => 'ไม่ปรับสี',
			'colorVisionAssist.protanopia' => 'ช่วยมองสีแดง (Protanopia)',
			'colorVisionAssist.protanopiaDescription' => 'สำหรับผู้ที่มี Protanopia — แยกแยะสีแดงได้ยาก',
			'colorVisionAssist.deuteranopia' => 'ช่วยมองสีเขียว (Deuteranopia)',
			'colorVisionAssist.deuteranopiaDescription' => 'สำหรับผู้ที่มี Deuteranopia — แยกแยะสีเขียวได้ยาก',
			'colorVisionAssist.tritanopia' => 'ช่วยมองสีน้ำเงิน (Tritanopia)',
			'colorVisionAssist.tritanopiaDescription' => 'สำหรับผู้ที่มี Tritanopia — แยกแยะสีน้ำเงินและสีเหลืองได้ยาก',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => 'นำ ${filterName} ไปใช้แล้ว มีผลทันที',
			'colorVisionAssist.disabledToast' => 'ปิดการช่วยการมองเห็นสีแล้ว',
			'externalPlayer.title' => 'เปิดด้วยแอปอื่น',
			'externalPlayer.description' => 'ส่งวิดีโอปัจจุบันไปยังโปรแกรมเล่นอื่นบนอุปกรณ์นี้ เช่น Skybox หรือ Pigasus บนชุดหูฟัง VR หรือ MX Player และ VLC บนมือถือ',
			'externalPlayer.openWithOtherApp' => 'เลือกแอปอื่น',
			'externalPlayer.openWithOtherAppDescription' => 'เปิดตัวเลือกของระบบแล้วเลือกโปรแกรมเล่นที่จะรับช่วงต่อ',
			'externalPlayer.openWithSystemPlayer' => 'เปิดในโปรแกรมเล่นเริ่มต้น',
			'externalPlayer.openWithSystemPlayerDescription' => 'ส่งต่อให้แอปวิดีโอเริ่มต้นของระบบ',
			'externalPlayer.copyLink' => 'คัดลอกลิงก์วิดีโอ',
			'externalPlayer.copyLinkDescription' => 'สำหรับโปรแกรมเล่นที่วาง URL ได้เท่านั้น เช่น Skybox หรือ DeoVR',
			'externalPlayer.linkCopied' => 'คัดลอกลิงก์วิดีโอแล้ว',
			'externalPlayer.sourceLocal' => 'ไฟล์ในเครื่อง',
			'externalPlayer.sourceOnline' => 'ลิงก์ตรง',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'ลิงก์ตรง · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'ลิงก์ตรงมีอายุจำกัด โปรแกรมเล่นภายนอกอาจหยุดกลางคันได้ การดาวน์โหลดไว้ก่อนเป็นวิธีที่เชื่อถือได้',
			'externalPlayer.vrPlayerHint' => 'หากไม่มีโปรแกรมเล่น VR ของคุณในตัวเลือก ให้ใช้ คัดลอกลิงก์วิดีโอ แล้ววางในโปรแกรมเล่นนั้น',
			'externalPlayer.noHandler' => 'ไม่มีแอปบนอุปกรณ์นี้ที่เปิดวิดีโอได้',
			_ => null,
		} ?? switch (path) {
			'externalPlayer.handoffFailed' => ({required Object message}) => 'ส่งต่อไม่สำเร็จ: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'ส่งต่อไม่สำเร็จ',
			'externalPlayer.sourceUnavailable' => 'ไม่สามารถดึงที่อยู่ของวิดีโอปัจจุบันได้ โปรดลองอีกครั้ง',
			'externalPlayer.localFileMissing' => 'ไฟล์ในเครื่องไม่มีอยู่แล้ว',
			'externalPlayer.handedOff' => 'ส่งต่อให้โปรแกรมเล่นภายนอกแล้ว',
			'externalPlayer.desktopSectionTitle' => 'โปรแกรมเล่นภายนอก',
			'externalPlayer.managePlayers' => 'จัดการโปรแกรมเล่นภายนอก',
			'externalPlayer.managePlayersDescWindows' => 'โปรแกรมเล่น PCVR อย่าง HereSphere, DeoVR และ Whirligig ไม่ใช่แอปเริ่มต้นของระบบ ชี้ไปที่ไฟล์ .exe ของโปรแกรมเหล่านั้น แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย',
			'externalPlayer.managePlayersDescMac' => 'ชี้ไปที่โปรแกรมเล่นอย่าง IINA, VLC หรือ mpv แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย',
			'externalPlayer.managePlayersDescLinux' => 'ชี้ไปที่โปรแกรมเล่นอย่าง mpv, VLC หรือ Celluloid แล้วคุณจะส่งวิดีโอปัจจุบันต่อได้จากหน้าโปรแกรมเล่นเลย',
			'externalPlayer.pickExecutableHintWindows' => 'เลือกไฟล์ .exe หลักในโฟลเดอร์ติดตั้งของโปรแกรมเล่น เช่น HereSphere.exe หรือ vlc.exe ทางลัดบนเดสก์ท็อป (.lnk) ใช้ไม่ได้',
			'externalPlayer.pickExecutableHintMac' => 'เลือกไฟล์ .app ของโปรแกรมเล่นใน Applications เช่น IINA.app — ระบบจะค้นหาไฟล์เรียกใช้งานจริงภายในให้เอง',
			'externalPlayer.pickExecutableHintLinux' => 'เลือกไฟล์เรียกใช้งานของโปรแกรมเล่น เช่น /usr/bin/mpv การรัน which mpv จะบอกตำแหน่งของมัน',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'เมื่อตั้งค่าแล้วจะปรากฏเป็นรายการของตัวเองใต้ เปิดด้วยแอปอื่น ในหน้าโปรแกรมเล่น ที่ใช้บ่อยเช่น: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'ไม่พบโปรแกรมเล่นที่ติดตั้งไว้ โฟลเดอร์ติดตั้งแบบกำหนดเองและเวอร์ชันพกพาจะตรวจจับไม่ได้ — ใช้ เพิ่มโปรแกรมเล่น เพื่อระบุเอง',
			'externalPlayer.detectNothingNew' => 'ไม่พบโปรแกรมเล่นใหม่ ทุกอย่างที่ติดตั้งอยู่มีในรายการแล้ว',
			'externalPlayer.detectFailed' => 'ตรวจจับไม่สำเร็จ — ใช้ เพิ่มโปรแกรมเล่น เพื่อระบุเอง',
			'externalPlayer.advancedOptions' => 'ขั้นสูง',
			'externalPlayer.playerNameHint' => 'เว้นว่างไว้เพื่อใช้ชื่อไฟล์',
			'externalPlayer.executablePathRequired' => 'เลือกไฟล์เรียกใช้งานของโปรแกรมเล่นก่อน',
			'externalPlayer.playerCount' => ({required Object count}) => 'ตั้งค่าแล้ว ${count} รายการ',
			'externalPlayer.noPlayerConfigured' => 'ยังไม่ได้ตั้งค่าโปรแกรมเล่นภายนอก',
			'externalPlayer.autoDetect' => 'ตรวจจับอัตโนมัติ',
			'externalPlayer.detecting' => 'กำลังตรวจจับ…',
			'externalPlayer.detectFound' => ({required Object count}) => 'พบโปรแกรมเล่น ${count} รายการ',
			'externalPlayer.detectNothingFound' => 'ไม่พบโปรแกรมเล่นใหม่ เพิ่มเองได้เลย',
			'externalPlayer.autoDetectedTag' => 'ตรวจพบ',
			'externalPlayer.addPlayer' => 'เพิ่มโปรแกรมเล่น',
			'externalPlayer.editPlayer' => 'แก้ไขโปรแกรมเล่น',
			'externalPlayer.playerName' => 'ชื่อ',
			'externalPlayer.executablePath' => 'ไฟล์เรียกใช้งาน',
			'externalPlayer.browse' => 'เลือกไฟล์',
			'externalPlayer.argumentTemplate' => 'อาร์กิวเมนต์ตอนเปิด',
			'externalPlayer.argumentTemplateHint' => 'ใช้ {input} แทนเส้นทางหรือ URL ของวิดีโอ เว้นว่างไว้เพื่อส่งเป็นอาร์กิวเมนต์เดียว',
			'externalPlayer.nameAndPathRequired' => 'ต้องกรอกทั้งชื่อและไฟล์เรียกใช้งาน',
			'externalPlayer.testLaunch' => 'ทดสอบเปิด',
			'externalPlayer.testLaunched' => 'เปิดโปรแกรมเล่นแล้ว',
			'externalPlayer.testFailed' => 'เปิดไม่สำเร็จ ตรวจสอบเส้นทางไฟล์เรียกใช้งาน',
			'externalPlayer.executableMissing' => 'ไม่พบไฟล์เรียกใช้งาน',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'เปิดใน ${name}',
			'externalPlayer.managePlayersEntry' => 'จัดการโปรแกรมเล่นภายนอก…',
			'watchLater.title' => 'ดูภายหลัง',
			'watchLater.addToWatchLater' => 'ดูภายหลัง',
			'watchLater.removeFromWatchLater' => 'เอาออกจากดูภายหลัง',
			'watchLater.addedToWatchLater' => 'เพิ่มในดูภายหลังแล้ว',
			'watchLater.alreadyInWatchLater' => 'อยู่ในดูภายหลังแล้ว',
			'watchLater.removedFromWatchLater' => 'เอาออกจากดูภายหลังแล้ว',
			'watchLater.removedCount' => ({required Object count}) => 'ลบออกแล้ว ${count} รายการ',
			'watchLater.viewWatchLaterList' => 'ดูรายการ',
			'watchLater.addFailed' => 'เพิ่มในดูภายหลังไม่สำเร็จ',
			'watchLater.invalidItem' => 'ไม่พร้อมใช้งาน',
			'watchLater.clearWatched' => 'ล้างรายการที่ดูแล้ว',
			'watchLater.watchedCleared' => ({required Object count}) => 'ล้างรายการที่ดูแล้ว ${count} รายการ',
			'watchLater.noWatchedToClear' => 'ไม่มีรายการที่ดูแล้วให้ล้าง',
			'watchLater.emptyVideo' => 'ยังไม่มีวิดีโอในดูภายหลัง',
			'watchLater.emptyGallery' => 'ยังไม่มีแกลเลอรีในดูภายหลัง',
			'watchLater.filterAll' => 'ทั้งหมด',
			'watchLater.filterUnwatched' => 'ยังไม่ดู',
			'watchLater.sortRecentlyAdded' => 'เพิ่มล่าสุด',
			'watchLater.sortEarliestAdded' => 'เพิ่มก่อนสุด',
			'watchLater.watched' => 'ดูแล้ว',
			'watchLater.playlistLoadFailed' => 'โหลดเพลย์ลิสต์ไม่สำเร็จ',
			'watchLater.noPlaylists' => 'ยังไม่มีเพลย์ลิสต์',
			'watchLater.undo' => 'เลิกทำ',
			'watchLater.clearWatchedConfirm' => 'ล้างทุกอย่างที่คุณดูแล้วในแท็บนี้หรือไม่ การกระทำนี้ย้อนกลับไม่ได้',
			'watchLater.emptyUnwatchedVideo' => 'ไม่มีอะไรเหลือให้รับชมที่นี่',
			'watchLater.emptyUnwatchedGallery' => 'ไม่มีอะไรเหลือให้ดูที่นี่',
			'watchLater.queueLoadFailed' => 'โหลดไม่สำเร็จ แตะเพื่อลองใหม่',
			'mediaMenu.like' => 'ถูกใจ',
			'mediaMenu.unlike' => 'เลิกถูกใจ',
			'mediaMenu.viewAuthor' => 'ดูผู้สร้าง',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} โฟลเดอร์',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} เพลย์ลิสต์',
			'mediaMenu.downloaded' => 'ดาวน์โหลดแล้ว',
			'mediaPreview.preview' => 'ตัวอย่าง',
			'mediaPreview.openDetail' => 'เปิด',
			'mediaPreview.moreActions' => 'การกระทำเพิ่มเติม',
			'mediaPreview.previousImage' => 'รูปก่อนหน้า',
			'mediaPreview.nextImage' => 'รูปถัดไป',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} รูป',
			'playbackQueue.upNext' => 'ถัดไป',
			'playbackQueue.sourceTab' => 'แหล่งที่มา',
			'playbackQueue.emptyQueue' => 'ไม่มีรายการที่เล่นได้ในคิวนี้',
			'playbackQueue.emptyGalleryQueue' => 'ไม่มีแกลเลอรีในคิวนี้',
			'playbackQueue.nowPlaying' => 'กำลังเล่น',
			'playbackQueue.myPlaylists' => 'เพลย์ลิสต์ของฉัน',
			'playbackQueue.authorPlaylists' => 'เพลย์ลิสต์ของผู้สร้าง',
			'playbackQueue.openQueue' => 'ถัดไป',
			'playbackQueue.continueInQueue' => 'เล่นต่อจากคิวปัจจุบัน',
			'playbackQueue.continueInQueueSubtitle' => 'เล่นรายการถัดไปโดยอัตโนมัติ ปิดการทำงานของ “เล่นซ้ำเมื่อจบ”',
			'playbackQueue.repeatDisabledByQueue' => 'ปิดใช้งานขณะที่ “เล่นต่อจากคิวปัจจุบัน” เปิดอยู่',
			'playbackQueue.playNext' => 'เล่นถัดไป',
			'playbackQueue.queueEnded' => 'นี่คือรายการสุดท้ายในคิว',
			'playbackQueue.playNextHint' => 'แตะเพื่อเล่นรายการถัดไป กดค้างเพื่อเปิด ถัดไป',
			'playbackQueue.authorVideos' => 'วิดีโอของผู้สร้าง',
			'playbackQueue.authorGalleries' => 'แกลเลอรีของผู้สร้าง',
			'playbackQueue.favoriteFolders' => 'โฟลเดอร์โปรด',
			'playbackQueue.localFiles' => 'บนอุปกรณ์นี้',
			'playbackQueue.currentFolder' => 'โฟลเดอร์ของไฟล์นี้',
			'playbackQueue.playThisFolder' => 'ดูคิววิดีโอของโฟลเดอร์นี้',
			'playbackQueue.browseThisFolder' => 'ดูคิวแกลเลอรีของโฟลเดอร์นี้',
			'playbackQueue.downloads' => 'ดาวน์โหลด',
			'playbackQueue.otherPlaylists' => 'เพลย์ลิสต์ของผู้ใช้อื่น',
			'playbackQueue.nothingHere' => 'ไม่มีอะไรที่นี่',
			'vrFormat.playInSpace' => 'เล่นในโปรแกรมเล่นเชิงพื้นที่',
			'vrFormat.handingOff' => 'กำลังส่งต่อไปยังพื้นที่…',
			'vrFormat.title' => 'โหมดการเล่น',
			'vrFormat.spatialSectionTitle' => 'การเล่นแบบเชิงพื้นที่',
			'vrFormat.spatialSectionDesc' => 'บนชุดหูฟัง วิดีโอไม่ได้ถูกวาดในแผงนี้ — โปรแกรมเล่นเชิงพื้นที่จะวางไว้บนจอในห้อง',
			'vrFormat.spatialPanelEntry' => 'แผงควบคุมเชิงพื้นที่',
			'vrFormat.spatialPanelEntryDesc' => 'ระยะห่างของจอ ขนาดและความโค้ง สภาพแวดล้อมพื้นหลัง ตลอดจนความเร็ว การเล่นซ้ำ และการซ่อนอัตโนมัติ อยู่ในแผงควบคุมเชิงพื้นที่ทั้งหมด',
			'vrFormat.spatialGuideEntry' => 'คู่มือการควบคุมด้วยชุดหูฟัง',
			'vrFormat.spatialGuideEntryDesc' => 'ปุ่มบนคอนโทรลเลอร์ การคว้าจอ การเลื่อนด้วยก้านควบคุม และการเปลี่ยนหน้า',
			'vrFormat.spatialFlatOmitted' => 'ท่าทางการสัมผัส การเพิ่มคุณภาพภาพ และพารามิเตอร์เสียง/วิดีโอ ใช้ได้เฉพาะกับโปรแกรมเล่น 2D เท่านั้น โปรแกรมเล่นเชิงพื้นที่ทำงานบนเอนจินอื่น จึงไม่แสดงไว้ที่นี่',
			'vrFormat.spatialGallerySectionTitle' => 'แกลเลอรีเชิงพื้นที่',
			'vrFormat.spatialGalleryPanelDesc' => 'ช่วงเวลาสไลด์โชว์ การเล่นซ้ำคลิปเดียว และความโค้งของจอ ปรับได้ทั้งหมดในแผงควบคุมเชิงพื้นที่',
			'vrFormat.autoEnterGallery' => 'เปิดภาพในแกลเลอรีเชิงพื้นที่',
			'vrFormat.autoEnterGalleryDesc' => 'บน Quest การแตะที่ภาพจะเปิดทั้งแกลเลอรีบนจอลอยพร้อมฟิล์มสตริป สไลด์โชว์ และการเปลี่ยนหน้าด้วยคอนโทรลเลอร์ แทนที่จะเป็นตัวดูภาพในแผงนี้',
			'vrFormat.panelSettings' => 'แผงและพื้นหลัง',
			'vrFormat.panelSettingsDesc' => 'แผงของแอปนี้อยู่ห่างแค่ไหน และเห็นห้องของคุณด้านหลังมากน้อยเพียงใด',
			'vrFormat.panelDistance' => 'ระยะห่างของแผง',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'รีเซ็ตตำแหน่ง',
			'vrFormat.panelResetBackground' => 'คืนค่าเริ่มต้น',
			'vrFormat.panelBackground' => 'ความโปร่งใสของพื้นหลัง',
			'vrFormat.panelBackgroundHint' => '0%: รอบข้างเป็นสีดำ · 100%: ห้องจริงของคุณพร้อมแสงแวดล้อม',
			'vrFormat.panelUnavailable' => 'ตอนนี้แผงไม่ได้อยู่ในตำแหน่ง — โปรดลองอีกครั้งในอีกสักครู่',
			'vrFormat.desc' => 'เลือกรูปแบบเรขาคณิตที่จะใช้เล่นวิดีโอนี้ ไซต์ไม่ได้ให้ข้อมูลนี้ การตรวจจับอัตโนมัติจึงเลือกเพียงจุดเริ่มต้นเท่านั้น — การเลือกของคุณเป็นตัวตัดสิน',
			'vrFormat.sectionFlat' => 'แบน',
			'vrFormat.sectionStereo' => 'แบน 3D',
			'vrFormat.sectionPanorama' => 'พาโนรามา VR',
			'vrFormat.flat' => 'วิดีโอปกติ',
			'vrFormat.flatDesc' => 'เล่นตามเดิม ไม่มีการปรับรูปแบบภาพ',
			'vrFormat.flatSideBySide' => '3D แบบข้างเคียง',
			'vrFormat.flatSideBySideDesc' => 'หนึ่งตาต่อครึ่งซ้ายและขวา แสดงตาซ้ายและคืนสัดส่วนภาพเดิม',
			'vrFormat.flatTopBottom' => '3D แบบบนล่าง',
			'vrFormat.flatTopBottomDesc' => 'หนึ่งตาต่อครึ่งบนและล่าง แสดงครึ่งบนและคืนสัดส่วนภาพเดิม',
			'vrFormat.vr180SideBySide' => 'VR180 แบบข้างเคียง',
			'vrFormat.vr180SideBySideDesc' => 'พาโนรามาซีกโลกพร้อมสองตา — แหล่ง VR ที่พบมากที่สุด',
			'vrFormat.vr180Mono' => 'VR180 ภาพเดียว',
			'vrFormat.vr180MonoDesc' => 'พาโนรามาซีกโลก หนึ่งตาต่อเฟรม',
			'vrFormat.vr360Mono' => 'VR360 ภาพเดียว',
			'vrFormat.vr360MonoDesc' => 'พาโนรามาแบบรอบทิศ หนึ่งตาต่อเฟรม',
			'vrFormat.vr360TopBottom' => 'VR360 แบบบนล่าง',
			'vrFormat.vr360TopBottomDesc' => 'พาโนรามาแบบรอบทิศพร้อมสองตาซ้อนกัน',
			'vrFormat.resetView' => 'รีเซ็ตมุมมอง',
			'vrFormat.resetViewDesc' => 'คืนทิศทางการมองและมุมมองกลับไปด้านหน้า',
			'vrFormat.resetToAuto' => 'กลับสู่การตรวจจับอัตโนมัติ',
			'vrFormat.resetToAutoDesc' => 'ลืมการเลือกเองสำหรับวิดีโอนี้ แล้วให้การตรวจจับตัดสินใจใหม่',
			'vrFormat.manualBadge' => 'ตั้งค่าเอง',
			'vrFormat.panoramaHint' => 'ลากภาพเพื่อมองไปรอบๆ บีบนิ้วเพื่อเปลี่ยนมุมมอง',
			'vrFormat.panoramaGestureNotice' => 'ขณะมองไปรอบๆ การลากจะหมุนมุมมอง — ใช้แถบความคืบหน้าเพื่อเลื่อนไปยังตำแหน่ง',
			'vrFormat.shaderUnsupported' => 'อุปกรณ์นี้ไม่สามารถเรนเดอร์พาโนรามาแบบสดได้ จึงแสดงเพียงตาเดียว',
			'vrFormat.handoffTooltip' => 'เล่นด้วยวิธีอื่น',
			'vrFormat.suggestedBadge' => 'แนะนำ',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'ดูเหมือนเป็น ${format} — แตะเพื่อสลับ',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'วิดีโอนี้อาจเป็นวิดีโอ VR (${format})',
			'vrFormat.suggestionTitleShort' => 'วิดีโอนี้อาจเป็นวิดีโอ VR',
			'vrFormat.suggestionAction' => 'เล่นเป็น VR',
			'vrFormat.suggestionDismiss' => 'ปิด',
			'localMedia.browse.pinnedSection' => 'การเข้าถึงด่วน',
			'localMedia.browse.sourcesSection' => 'โฟลเดอร์',
			'localMedia.browse.pin' => 'เพิ่มในการเข้าถึงด่วน',
			'localMedia.browse.unpin' => 'ลบออกจากการเข้าถึงด่วน',
			'localMedia.browse.pinned' => 'เพิ่มในการเข้าถึงด่วนแล้ว',
			'localMedia.browse.unpinned' => 'ลบออกจากการเข้าถึงด่วนแล้ว',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} โฟลเดอร์',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} วิดีโอ',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} รูป',
			'localMedia.browse.emptyFolder' => 'โฟลเดอร์นี้ว่างเปล่า',
			'localMedia.browse.videosSection' => 'วิดีโอ',
			'localMedia.browse.imagesSection' => 'รูปภาพ',
			'localMedia.browse.galleriesSection' => 'แกลเลอรี',
			'localMedia.browse.filterAll' => 'ทั้งหมด',
			'localMedia.browse.searchInFolder' => 'ค้นหาในโฟลเดอร์นี้',
			'localMedia.browse.searchHint' => 'ค้นหาตามชื่อ',
			'localMedia.browse.clearSearch' => 'ล้างการค้นหา',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'ไม่พบรายการที่ตรงกับ "${query}"',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'ดูโฟลเดอร์ทั้งหมด ${count} รายการ',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'ดูวิดีโอทั้งหมด ${count} รายการ',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'ดูรูปภาพทั้งหมด ${count} รายการ',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'ดูแกลเลอรีทั้งหมด ${count} รายการ',
			'localMedia.browse.location' => 'ตำแหน่ง',
			'localMedia.browse.sourceMissing' => 'แหล่งนี้หายไปแล้ว',
			'localMedia.browse.notScannedYet' => 'โฟลเดอร์นี้ยังไม่ได้สแกน',
			'localMedia.browse.scanning' => 'กำลังอ่านโฟลเดอร์นี้…',
			'localMedia.browse.deleteFileTitle' => 'ลบไฟล์นี้หรือไม่',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '“${name}” จะถูกลบออกจากอุปกรณ์นี้อย่างถาวร การกระทำนี้ย้อนกลับไม่ได้',
			'localMedia.browse.hideFolder' => 'ซ่อนโฟลเดอร์นี้',
			'localMedia.browse.unhideFolder' => 'เลิกซ่อน',
			'localMedia.browse.showHiddenFolders' => 'แสดงโฟลเดอร์ที่ซ่อนไว้',
			'localMedia.browse.includeDotFolders' => 'สแกนโฟลเดอร์ที่ขึ้นต้นด้วย .',
			'localMedia.browse.dotFoldersIncluded' => 'เริ่มสแกนโฟลเดอร์ที่ขึ้นต้นด้วย . แล้ว',
			'localMedia.browse.dotFoldersExcluded' => 'ไม่สแกนโฟลเดอร์ที่ขึ้นต้นด้วย . อีกต่อไป',
			'localMedia.browse.showDotFolders' => 'แสดงโฟลเดอร์ที่ขึ้นต้นด้วย .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'ที่นี่มีโฟลเดอร์ที่ขึ้นต้นด้วย . อีก ${count} โฟลเดอร์ที่ยังไม่ได้สแกน',
			'localMedia.browse.scanDotFoldersAction' => 'เปิดสำหรับแหล่งนี้',
			'localMedia.browse.otherAppsPrivateNotice' => 'ตั้งแต่ Android 11 ไม่มีแอปใดอ่านไฟล์ของแอปอื่นใน Android/data หรือ Android/obb ได้ และแอปนี้ก็หลีกเลี่ยงไม่ได้ โปรดดาวน์โหลดหรือส่งออกวิดีโอไปยังโฟลเดอร์สาธารณะ เช่น Download ในแอปต้นทาง แล้วเพิ่มโฟลเดอร์นั้นที่นี่ แคชระหว่างดูมักถูกแบ่งเป็นชิ้นและเล่นไม่ได้แม้จะอ่านได้',
			'localMedia.browse.folderHidden' => 'ซ่อนแล้ว การสแกนจะข้ามโฟลเดอร์นี้ด้วย',
			'localMedia.browse.folderUnhidden' => 'เลิกซ่อนแล้ว',
			'localMedia.browse.hiddenFolderBadge' => 'ซ่อนอยู่',
			'localMedia.browse.deleteFolder' => 'ลบโฟลเดอร์',
			'localMedia.browse.deleteFolderTitle' => 'ลบโฟลเดอร์นี้หรือไม่',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '"${name}" และทุกอย่างข้างในจะถูกลบออกจากอุปกรณ์นี้อย่างถาวร ไม่สามารถกู้คืนได้',
			'localMedia.browse.deleteFolderIncludesOthers' => 'ไฟล์อื่นที่อยู่ข้างในจะถูกลบไปด้วย',
			'localMedia.browse.folderDeleted' => 'ลบโฟลเดอร์แล้ว',
			'localMedia.browse.deleteFolderFailed' => 'ลบไม่สำเร็จ อาจไม่มีสิทธิ์ หรือมีไฟล์ข้างในกำลังถูกใช้งาน',
			'localMedia.browse.deleteGalleryTitle' => 'ลบแกลเลอรีนี้หรือไม่',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'ประวัติการดาวน์โหลดและไฟล์ภาพในเครื่องของ “${name}” จะถูกลบ การกระทำนี้ย้อนกลับไม่ได้',
			'localMedia.browse.galleryResourceMissing' => 'ไฟล์ในเครื่องไม่มีอยู่แล้ว ล้างข้อมูลเรียบร้อย',
			'localMedia.browse.viewDownloadDetail' => 'ดูรายละเอียดการดาวน์โหลด',
			'localMedia.browse.viewOnlineGallery' => 'ดูบนเว็บไซต์',
			'localMedia.browse.pickFolderTitle' => 'เลือกโฟลเดอร์',
			'localMedia.browse.useThisFolder' => 'ใช้โฟลเดอร์นี้',
			'localMedia.browse.noSubfolders' => 'ไม่มีโฟลเดอร์ย่อยที่นี่',
			'localMedia.browse.storageRoot' => 'ที่เก็บข้อมูลของอุปกรณ์',
			'localMedia.browse.homeFolder' => 'หน้าหลัก',
			'localMedia.browse.filesystemRoot' => 'รากของระบบไฟล์',
			'localMedia.browse.folderUnreadable' => 'ไม่สามารถอ่านโฟลเดอร์นี้ได้',
			'localMedia.browse.setCover' => 'ตั้งเป็นปก',
			'localMedia.browse.setAsFolderCover' => 'ใช้เป็นปกโฟลเดอร์',
			'localMedia.browse.folderCoverSet' => 'อัปเดตปกโฟลเดอร์แล้ว',
			'localMedia.browse.setFolderCoverPick' => 'ตั้งเป็นปก…',
			'localMedia.browse.restoreAutoCover' => 'คืนค่าปกอัตโนมัติ',
			'localMedia.browse.autoCoverRestored' => 'คืนค่าปกอัตโนมัติแล้ว',
			'localMedia.browse.rescanFolder' => 'สแกนโฟลเดอร์นี้ใหม่',
			'localMedia.browse.coverPickerTitle' => 'เลือกเฟรมภาพ',
			'localMedia.browse.folderCoverPickerTitle' => 'เลือกปก',
			'localMedia.browse.coverPickerEmpty' => 'ยังไม่มีรูปภาพในโฟลเดอร์นี้ ภาพตัวอย่างวิดีโออาจยังสร้างอยู่เบื้องหลัง',
			'localMedia.browse.coverSaved' => 'อัปเดตปกแล้ว',
			'localMedia.browse.coverSaveFailed' => 'ไม่สามารถบันทึกปกได้',
			'localMedia.browse.coverUnavailable' => 'ไม่สามารถอ่านเฟรมจากไฟล์นี้ได้',
			'localMedia.browse.deleted' => 'ลบแล้ว',
			'localMedia.browse.deleteFailed' => 'ลบไม่ได้ — ไฟล์อาจถูกใช้งานอยู่หรือเขียนไม่ได้',
			'localMedia.browse.openFolder' => 'เปิด',
			'localMedia.browse.favorite' => 'เพิ่มในรายการโปรด',
			'localMedia.browse.unfavorite' => 'ลบออกจากรายการโปรด',
			'localMedia.browse.favorited' => 'เพิ่มในรายการโปรดแล้ว',
			'localMedia.browse.unfavorited' => 'ลบออกจากรายการโปรดแล้ว',
			'localMedia.browse.sortBy' => 'เรียงตาม',
			'localMedia.browse.sortAscending' => 'น้อยไปมาก',
			'localMedia.browse.sortDescending' => 'มากไปน้อย',
			'localMedia.browse.sortFieldName' => 'ชื่อ',
			'localMedia.browse.sortFieldModified' => 'วันที่แก้ไข',
			'localMedia.browse.sortFieldDuration' => 'ระยะเวลา',
			'localMedia.browse.sortFieldSize' => 'ขนาด',
			'localMedia.browse.sortFieldResolution' => 'ความละเอียด',
			'localMedia.browse.sortFieldFileType' => 'ชนิดไฟล์',
			'localMedia.browse.sortFieldFps' => 'อัตราเฟรม',
			'localMedia.browse.sortFieldFavorited' => 'วันที่เพิ่มในรายการโปรด',
			'localMedia.browse.emptyAllVideos' => 'ยังไม่พบวิดีโอ เพิ่มโฟลเดอร์ใต้ โฟลเดอร์ เพื่อเริ่มต้น',
			'localMedia.browse.emptyAllImages' => 'ยังไม่พบรูปภาพ เพิ่มโฟลเดอร์ใต้ โฟลเดอร์ เพื่อเริ่มต้น',
			'localMedia.browse.emptyFavorites' => 'ยังไม่มีรายการโปรด เพิ่มได้จากเมนู ⋮ ของวิดีโอ',
			'localMedia.browse.emptyPinned' => 'ยังไม่มีโฟลเดอร์ปักหมุด กดค้างที่โฟลเดอร์ใต้ โฟลเดอร์ แล้วเลือก ปักหมุด',
			'localMedia.browse.emptyDownloadedVideos' => 'ยังไม่มีการดาวน์โหลดวิดีโอที่เสร็จสมบูรณ์',
			'localMedia.browse.emptyDownloadedGalleries' => 'ยังไม่มีการดาวน์โหลดแกลเลอรีที่เสร็จสมบูรณ์',
			'localMedia.browse.folderInfo' => 'ข้อมูลโฟลเดอร์',
			'localMedia.browse.folderInfoName' => 'ชื่อ',
			'localMedia.browse.folderInfoPath' => 'เส้นทาง',
			'localMedia.browse.folderInfoSource' => 'แหล่งที่มา',
			'localMedia.browse.folderInfoContents' => 'เนื้อหา',
			'localMedia.browse.folderInfoSize' => 'ขนาดบนดิสก์',
			'localMedia.browse.folderInfoScannedAt' => 'สแกนล่าสุด',
			'localMedia.browse.folderInfoNeverScanned' => 'ยังไม่ได้สแกน',
			'localMedia.browse.folderInfoNoPath' => 'แหล่งนี้ไม่มีโฟลเดอร์ให้เปิด',
			'localMedia.browse.copyPath' => 'คัดลอกเส้นทาง',
			'localMedia.browse.pathCopied' => 'คัดลอกเส้นทางแล้ว',
			'localMedia.tabFolders' => 'โฟลเดอร์',
			'localMedia.tabFavoriteVideos' => 'รายการโปรด',
			'localMedia.tabAllVideos' => 'วิดีโอทั้งหมด',
			'localMedia.tabAllImages' => 'รูปภาพทั้งหมด',
			'localMedia.tabDownloadedVideos' => 'วิดีโอที่ดาวน์โหลด',
			'localMedia.tabDownloadedGalleries' => 'แกลเลอรีที่ดาวน์โหลด',
			'localMedia.title' => 'บนอุปกรณ์นี้',
			'localMedia.sourceOnline' => 'Iwara ออนไลน์',
			'localMedia.manageSources' => 'จัดการแหล่งที่มา',
			'localMedia.moveToCategory' => 'ย้ายไปยังหมวดหมู่',
			'localMedia.manageCategories' => 'จัดการหมวดหมู่',
			'localMedia.suggestedFolders' => 'โฟลเดอร์ที่มีวิดีโอ',
			'localMedia.sortRecentlyAdded' => 'เพิ่มล่าสุด',
			'localMedia.sortRecentlyPlayed' => 'เล่นล่าสุด',
			'localMedia.sortName' => 'ชื่อ',
			'localMedia.sortDuration' => 'ระยะเวลา',
			'localMedia.sortSize' => 'ขนาด',
			'localMedia.sortFolder' => 'โฟลเดอร์',
			'localMedia.sortRecentlyModified' => 'แก้ไขล่าสุด',
			'localMedia.sortCount' => 'จำนวน',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} รูป',
			'localMedia.downloadsSource' => 'ดาวน์โหลด',
			'localMedia.builtInSourceHint' => 'รายการดาวน์โหลดถูกจัดการโดยอัตโนมัติ',
			'localMedia.filterByCategory' => 'กรองตามหมวดหมู่',
			'localMedia.longPressToCategorize' => 'กดค้างเพื่อย้ายไปยังหมวดหมู่',
			'localMedia.uncategorized' => 'ไม่มีหมวดหมู่',
			'localMedia.setCategoryFailed' => 'ไม่สามารถตั้งค่าหมวดหมู่ได้',
			'localMedia.categoryUpdated' => 'อัปเดตหมวดหมู่แล้ว',
			'localMedia.addFolder' => 'เพิ่มโฟลเดอร์',
			'localMedia.addDeviceVideos' => 'สแกนวิดีโอในอุปกรณ์',
			'localMedia.mediaStoreSourceName' => 'วิดีโอในอุปกรณ์',
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
			'localMedia.mediaStoreUnavailable' => 'ดัชนีสื่อของอุปกรณ์ใช้ได้เฉพาะบน Android',
			'localMedia.mediaStorePermissionDenied' => 'ไม่ได้รับอนุญาตให้เข้าถึงวิดีโอ',
			'localMedia.rescan' => 'สแกนใหม่',
			'localMedia.scanning' => ({required Object count}) => 'กำลังสแกน… พบ ${count} รายการ',
			'localMedia.scanFailed' => ({required Object reason}) => 'สแกนไม่สำเร็จ: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'โฟลเดอร์นั้นใหญ่โตมาก — เพิ่มเฉพาะ ${count} ไฟล์แรกเท่านั้น',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'ถูกครอบคลุมโดยโฟลเดอร์ “${name}” อยู่แล้ว',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '“${name}” อยู่ภายใน “${source}” จึงถูกเพิ่มไปยังโฟลเดอร์ปักหมุด',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '“${name}” อยู่ในโฟลเดอร์ปักหมุดแล้ว',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '“${name}” ถูกเพิ่มไปแล้ว',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'มีโฟลเดอร์ที่เพิ่มไว้แล้ว “${name}” อยู่ภายใน การเพิ่มโฟลเดอร์แม่ยังไม่รองรับในขณะนี้',
			'localMedia.addSourceFailed' => 'ไม่สามารถเพิ่มโฟลเดอร์นั้นได้',
			'localMedia.fileMissing' => 'ไฟล์นั้นไม่มีอยู่ในดิสก์แล้ว',
			'localMedia.permissionDenied' => 'ไม่ได้รับอนุญาตให้เข้าถึงไฟล์ · แตะเพื่ออนุญาต',
			'localMedia.noVideosFound' => 'ไม่มีวิดีโอในโฟลเดอร์นี้',
			'localMedia.emptyTitle' => 'เพิ่มโฟลเดอร์เพื่อรับชมวิดีโอที่มีอยู่แล้วในอุปกรณ์นี้',
			'localMedia.emptyPrivacyNote' => 'ไฟล์ถูกอ่านบนอุปกรณ์นี้เท่านั้น ไม่มีการอัปโหลดใดๆ',
			'localMedia.removeSourceTitle' => ({required Object name}) => 'ลบ “${name}” หรือไม่',
			'localMedia.removeSourceBody' => 'ไฟล์ยังคงอยู่ในดิสก์ ลบเฉพาะรายการในคลังนี้เท่านั้น',
			'localMedia.remove' => 'ลบ',
			'localMedia.removeFolder' => 'ลบโฟลเดอร์',
			'localMedia.removeFolderSelectTitle' => 'เลือกโฟลเดอร์ที่จะลบ',
			'localMedia.longPressToRemove' => 'กดค้างเพื่อลบโฟลเดอร์นี้',
			'localMedia.clearProgress' => 'ล้างประวัติการรับชมในเครื่อง',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} รายการ',
			'localMedia.clearProgressEmpty' => 'ยังไม่มีประวัติการรับชมในเครื่อง',
			'localMedia.clearProgressTitle' => 'ล้างประวัติการรับชมในเครื่องหรือไม่',
			'localMedia.clearProgressBody' => 'จะลบเฉพาะตำแหน่งการเล่นและเครื่องหมายรับชมแล้วเท่านั้น ไฟล์และโฟลเดอร์ของคุณจะคงอยู่เหมือนเดิม',
			'localMedia.clearProgressDone' => ({required Object count}) => 'ล้างประวัติการรับชมในเครื่องแล้ว ${count} รายการ',
			'localMedia.clearAction' => 'ล้าง',
			'localMedia.iosManualRescanNotice' => 'iOS ไม่ตรวจจับไฟล์ใหม่โดยอัตโนมัติ คุณจะต้องสแกนใหม่ด้วยตนเองหลังเพิ่มหรือลบไฟล์',
			'historyPage.removeFromHistory' => 'ลบออกจากประวัติ',
			'historyPage.removed' => 'ลบออกจากประวัติแล้ว',
			'historyPage.watchedTo' => ({required Object time}) => 'ดูถึง ${time}',
			'historyPage.finished' => 'ดูจบแล้ว',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'ล้าง "${tab}"',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'ประวัติทั้งหมดใน "${tab}" จะถูกลบ รวมถึงตำแหน่งการรับชมของวิดีโอเหล่านั้น ไม่สามารถย้อนกลับได้',
			'historyPage.rangeByLastViewed' => 'กรองตามเวลาที่ดูล่าสุด',
			'ai.title' => 'AI',
			'ai.providers' => 'ผู้ให้บริการ',
			'ai.providersHint' => 'เพิ่มผู้ให้บริการ AI อย่างน้อยหนึ่งราย แล้วเลือกผู้ให้บริการสำหรับแต่ละฟีเจอร์',
			'ai.addProvider' => 'เพิ่มผู้ให้บริการ',
			'ai.noProviders' => 'ยังไม่มีผู้ให้บริการ เพิ่มผู้ให้บริการเพื่อเปิดใช้งานการแปล การค้นหา และลายเซ็นด้วย AI',
			'ai.pickPreset' => 'เลือกผู้ให้บริการ',
			'ai.providerNameLabel' => 'ชื่อ',
			'ai.apiKey' => 'คีย์ API',
			'ai.baseUrl' => 'ปลายทาง API',
			'ai.model' => 'โมเดล',
			'ai.modelPick' => 'เลือกโมเดล',
			'ai.modelEmpty' => 'ไม่สามารถโหลดรายการโมเดลได้ คุณยังสามารถพิมพ์ชื่อโมเดลได้โดยตรง',
			'ai.advanced' => 'ขั้นสูง',
			'ai.reasoning' => 'โมเดลการให้เหตุผล',
			'ai.streaming' => 'เอาต์พุตแบบสตรีม',
			'ai.structuredOutput' => 'เอาต์พุตที่มีโครงสร้าง',
			'ai.structuredOutputHint' => 'จำเป็นสำหรับการค้นหาด้วย AI ปลายทางรีเลย์หลายแห่งไม่รองรับ ให้ปิดตัวเลือกนี้หากการค้นหาล้มเหลวบ่อยครั้ง',
			'ai.temperature' => 'อุณหภูมิ',
			'ai.maxTokens' => 'โทเค็นสูงสุด',
			'ai.maxTokensAuto' => 'อัตโนมัติ (ขีดจำกัดของโมเดล)',
			'ai.test' => 'ทดสอบ',
			'ai.testOk' => 'เชื่อมต่อสำเร็จ',
			'ai.deleteProvider' => 'ลบผู้ให้บริการ',
			'ai.usedBy' => 'ใช้งานโดย',
			'ai.taskBindings' => 'การกำหนดฟีเจอร์',
			'ai.taskBindingsHint' => 'แต่ละฟีเจอร์สามารถใช้ผู้ให้บริการที่แตกต่างกันได้',
			'ai.taskTranslate' => 'การแปล',
			'ai.taskSearch' => 'ค้นหาด้วย AI',
			'ai.taskSignature' => 'ลายเซ็น',
			'ai.taskAuto' => 'อัตโนมัติ',
			'ai.usage' => 'การใช้งาน',
			'ai.usageCalls' => 'การเรียกใช้',
			'ai.usageTokens' => 'โทเค็น',
			'ai.usageFailures' => 'ล้มเหลว',
			'ai.usageReset' => 'ล้างสถิติ',
			'ai.usageEmpty' => 'ยังไม่มีประวัติการเรียกใช้',
			'ai.openSettings' => 'เปิดการตั้งค่า AI',
			'ai.notConfigured' => 'ยังไม่ได้กำหนดค่า',
			'ai.searchTitle' => 'ค้นหาด้วย AI',
			'ai.searchHint' => 'อธิบายสิ่งที่คุณกำลังค้นหา แล้ว AI จะช่วยกรอกคำค้นหาและตัวกรองให้',
			'ai.searchPlaceholder' => 'เช่น MMD ล่าสุดที่มียอดดูมากกว่า 10,000 ครั้ง',
			'ai.searchApply' => 'ค้นหาด้วยเงื่อนไขเหล่านี้',
			'ai.searchEmpty' => 'ไม่สามารถแปลงเป็นเงื่อนไขการค้นหาได้ ลองอธิบายด้วยวิธีอื่นดู',
			'ai.searchFilters' => 'ตัวกรอง',
			'ai.searchSwitchSegment' => ({required Object segment}) => 'สลับไปที่ ${segment}',
			'ai.searchGenerating' => 'กำลังประมวลผล…',
			'ai.searchRetrying' => 'ครั้งก่อนล้มเหลว กำลังลองใหม่…',
			'ai.searchRetryReason' => ({required Object reason}) => 'สาเหตุ: ${reason}',
			'ai.searchStageWaiting' => 'ส่งคำขอแล้ว กำลังรอการตอบกลับ…',
			'ai.searchStageThinkingNext' => 'กำลังคิดขั้นต่อไป…',
			'ai.searchStageReasoning' => 'กำลังให้เหตุผล…',
			'ai.searchStageTool' => 'กำลังลองค้นหา…',
			'ai.searchStageDrafting' => ({required Object chars}) => 'กำลังเขียนคำตอบ · ${chars} ตัวอักษร',
			'ai.searchStageParsing' => 'กำลังจัดระเบียบผลลัพธ์…',
			'ai.searchThinking' => 'กระบวนการคิด',
			'ai.searchKeywordNeedsQuotes' => 'คำค้นนี้ไม่ได้ใส่เครื่องหมายคำพูด Iwara จึงจับคู่แบบหลวม ๆ — เมื่อเรียงแบบนี้ หน้าแรกจะแทบไม่เกี่ยวข้อง ใส่ "เครื่องหมายคำพูด" หรือเรียงตามความเกี่ยวข้อง',
			'ai.searchToolProbing' => ({required Object query}) => 'ลองค้น ${query}',
			'ai.searchToolFound' => ({required Object count, required Object titles}) => '${count} รายการ · ${titles}',
			'ai.searchToolFailed' => ({required Object reason}) => 'ล้มเหลว: ${reason}',
			'ai.searchFiltersDropped' => ({required Object count}) => 'ลบตัวกรอง ${count} รายการที่ไม่มีในส่วนนี้แล้ว',
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
			_ => null,
		} ?? switch (path) {
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
