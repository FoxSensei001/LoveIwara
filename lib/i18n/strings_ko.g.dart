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
class TranslationsKo extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKo _root = this; // ignore: unused_field

	@override 
	TranslationsKo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileKo personalProfile = _TranslationsPersonalProfileKo._(_root);
	@override late final _TranslationsTutorialKo tutorial = _TranslationsTutorialKo._(_root);
	@override late final _TranslationsCommonKo common = _TranslationsCommonKo._(_root);
	@override late final _TranslationsAuthKo auth = _TranslationsAuthKo._(_root);
	@override late final _TranslationsErrorsKo errors = _TranslationsErrorsKo._(_root);
	@override late final _TranslationsFriendsKo friends = _TranslationsFriendsKo._(_root);
	@override late final _TranslationsAuthorProfileKo authorProfile = _TranslationsAuthorProfileKo._(_root);
	@override late final _TranslationsFavoritesKo favorites = _TranslationsFavoritesKo._(_root);
	@override late final _TranslationsGalleryDetailKo galleryDetail = _TranslationsGalleryDetailKo._(_root);
	@override late final _TranslationsPlayListKo playList = _TranslationsPlayListKo._(_root);
	@override late final _TranslationsSearchKo search = _TranslationsSearchKo._(_root);
	@override late final _TranslationsMediaListKo mediaList = _TranslationsMediaListKo._(_root);
	@override late final _TranslationsSettingsKo settings = _TranslationsSettingsKo._(_root);
	@override late final _TranslationsFavoriteTagsKo favoriteTags = _TranslationsFavoriteTagsKo._(_root);
	@override late final _TranslationsOreno3dKo oreno3d = _TranslationsOreno3dKo._(_root);
	@override late final _TranslationsSignInKo signIn = _TranslationsSignInKo._(_root);
	@override late final _TranslationsSubscriptionsKo subscriptions = _TranslationsSubscriptionsKo._(_root);
	@override late final _TranslationsVideoDetailKo videoDetail = _TranslationsVideoDetailKo._(_root);
	@override late final _TranslationsShareKo share = _TranslationsShareKo._(_root);
	@override late final _TranslationsMarkdownKo markdown = _TranslationsMarkdownKo._(_root);
	@override late final _TranslationsForumKo forum = _TranslationsForumKo._(_root);
	@override late final _TranslationsNotificationsKo notifications = _TranslationsNotificationsKo._(_root);
	@override late final _TranslationsConversationKo conversation = _TranslationsConversationKo._(_root);
	@override late final _TranslationsSplashKo splash = _TranslationsSplashKo._(_root);
	@override late final _TranslationsDownloadKo download = _TranslationsDownloadKo._(_root);
	@override late final _TranslationsDownloadNotificationsKo downloadNotifications = _TranslationsDownloadNotificationsKo._(_root);
	@override late final _TranslationsFavoriteKo favorite = _TranslationsFavoriteKo._(_root);
	@override late final _TranslationsTranslationKo translation = _TranslationsTranslationKo._(_root);
	@override late final _TranslationsBottomNavKo bottomNav = _TranslationsBottomNavKo._(_root);
	@override late final _TranslationsNavigationOrderSettingsKo navigationOrderSettings = _TranslationsNavigationOrderSettingsKo._(_root);
	@override late final _TranslationsNewsKo news = _TranslationsNewsKo._(_root);
	@override late final _TranslationsDisplaySettingsKo displaySettings = _TranslationsDisplaySettingsKo._(_root);
	@override late final _TranslationsLayoutSettingsKo layoutSettings = _TranslationsLayoutSettingsKo._(_root);
	@override late final _TranslationsMediaPlayerKo mediaPlayer = _TranslationsMediaPlayerKo._(_root);
	@override late final _TranslationsDiagnosticsKo diagnostics = _TranslationsDiagnosticsKo._(_root);
	@override late final _TranslationsLogViewerKo logViewer = _TranslationsLogViewerKo._(_root);
	@override late final _TranslationsCrashRecoveryDialogKo crashRecoveryDialog = _TranslationsCrashRecoveryDialogKo._(_root);
	@override late final _TranslationsLinkInputDialogKo linkInputDialog = _TranslationsLinkInputDialogKo._(_root);
	@override late final _TranslationsLogKo log = _TranslationsLogKo._(_root);
	@override late final _TranslationsEmojiKo emoji = _TranslationsEmojiKo._(_root);
	@override late final _TranslationsSearchFilterKo searchFilter = _TranslationsSearchFilterKo._(_root);
	@override late final _TranslationsFirstTimeSetupKo firstTimeSetup = _TranslationsFirstTimeSetupKo._(_root);
	@override late final _TranslationsProxyHelperKo proxyHelper = _TranslationsProxyHelperKo._(_root);
	@override late final _TranslationsTagSelectorKo tagSelector = _TranslationsTagSelectorKo._(_root);
	@override late final _TranslationsAnime4kKo anime4k = _TranslationsAnime4kKo._(_root);
	@override late final _TranslationsSiteModeKo siteMode = _TranslationsSiteModeKo._(_root);
	@override late final _TranslationsSavedSearchConfigKo savedSearchConfig = _TranslationsSavedSearchConfigKo._(_root);
	@override late final _TranslationsSavedSearchKo savedSearch = _TranslationsSavedSearchKo._(_root);
	@override late final _TranslationsDefaultBlacklistReminderKo defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderKo._(_root);
	@override late final _TranslationsColorVisionAssistKo colorVisionAssist = _TranslationsColorVisionAssistKo._(_root);
	@override late final _TranslationsExternalPlayerKo externalPlayer = _TranslationsExternalPlayerKo._(_root);
	@override late final _TranslationsWatchLaterKo watchLater = _TranslationsWatchLaterKo._(_root);
	@override late final _TranslationsMediaMenuKo mediaMenu = _TranslationsMediaMenuKo._(_root);
	@override late final _TranslationsMediaPreviewKo mediaPreview = _TranslationsMediaPreviewKo._(_root);
	@override late final _TranslationsPlaybackQueueKo playbackQueue = _TranslationsPlaybackQueueKo._(_root);
	@override late final _TranslationsVrFormatKo vrFormat = _TranslationsVrFormatKo._(_root);
	@override late final _TranslationsLocalMediaKo localMedia = _TranslationsLocalMediaKo._(_root);
	@override late final _TranslationsHistoryPageKo historyPage = _TranslationsHistoryPageKo._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileKo extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => '개인 프로필';
	@override String get editPersonalProfile => '개인 프로필 편집';
	@override String get avatar => '아바타';
	@override String get background => '배경';
	@override String fetchUserProfileFailed({required Object error}) => '사용자 프로필을 가져오지 못했습니다: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => '권장 해상도: ${resolution}, 파일 크기 < ${size}';
	@override String supportedFormats({required Object formats}) => '지원 형식: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => '프리미엄 사용자는 동적 ${type}(${formats})을 사용할 수 있습니다';
	@override String get homepageBackground => '홈페이지 배경';
	@override String get basicInfo => '기본 정보';
	@override String get nickname => '닉네임';
	@override String get username => '사용자 이름';
	@override String get copyUsername => '사용자 이름 복사';
	@override String get usernameCopied => '사용자 이름이 복사되었습니다';
	@override String get personalIntroduction => '자기소개';
	@override String get noPersonalIntroduction => '자기소개 없음';
	@override String get clickToEdit => '클릭하여 편집';
	@override String get privacySettings => '개인정보 설정';
	@override String get hideSensitiveContent => '민감한 콘텐츠 숨기기';
	@override String get hideSensitiveContentDesc => '민감한 태그가 포함된 동영상이나 이미지를 숨깁니다.';
	@override String get notificationSettings => '알림 설정';
	@override String get contentCommentNotification => '콘텐츠 댓글 알림';
	@override String get contentCommentNotificationDesc => '회원님의 콘텐츠에 댓글이 달리면 알려드립니다.';
	@override String get commentReplyNotification => '댓글 답글 알림';
	@override String get commentReplyNotificationDesc => '회원님의 댓글에 답글이 달리면 알려드립니다.';
	@override String get mentionNotification => '멘션 알림';
	@override String get mentionNotificationDesc => '콘텐츠에서 회원님을 멘션하면 알려드립니다.';
	@override String get accountInfo => '계정 정보';
	@override String get registrationTime => '가입 시간';
	@override String updateSettingsFailed({required Object error}) => '설정을 업데이트하지 못했습니다: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => '알림 설정을 업데이트하지 못했습니다: ${error}';
	@override String get editNickname => '닉네임 편집';
	@override String get nicknameCannotBeEmpty => '닉네임은 비워 둘 수 없습니다';
	@override String get changeSuccess => '변경되었습니다';
	@override String get unsupportedFileFormat => '지원되지 않는 파일 형식';
	@override String fileTooLarge({required Object size}) => '파일 크기는 ${size}를 초과할 수 없습니다';
	@override String get uploadFailed => '업로드 실패';
	@override String get avatarUpdatedSuccessfully => '아바타가 업데이트되었습니다';
	@override String updateAvatarFailed({required Object error}) => '아바타를 업데이트하지 못했습니다: ${error}';
	@override String get backgroundUpdatedSuccessfully => '배경이 업데이트되었습니다';
	@override String updateBackgroundFailed({required Object error}) => '배경을 업데이트하지 못했습니다: ${error}';
	@override String get editPersonalIntroduction => '자기소개 편집';
	@override String get enterPersonalIntroduction => '자기소개를 입력해 주세요';
}

// Path: tutorial
class _TranslationsTutorialKo extends TranslationsTutorialEn {
	_TranslationsTutorialKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => '특별 팔로우';
	@override String get specialFollowDescription => '가장 자주 보는 작성자를 특별 팔로우로 지정하면 여기서 바로 최신 업로드로 이동할 수 있습니다.';
	@override String get stepsTitle => '세 단계';
	@override String get stepFollowAuthor => '작성자의 동영상, 갤러리 또는 프로필 페이지에서 팔로우를 탭하세요.';
	@override String get stepPickSpecial => '팔로우됨을 다시 탭한 다음 메뉴에서 특별 팔로우를 선택하세요.';
	@override String get stepSwitchHere => '여기로 돌아와 위의 아바타 선택기로 해당 작성자로 전환하세요.';
	@override String get specialFollowManagementTip => '특별 팔로우 목록은 사이드바 - 팔로우 목록 - 특별 팔로우에서 관리합니다.';
	@override String get gotIt => '알겠습니다';
}

// Path: common
class _TranslationsCommonKo extends TranslationsCommonEn {
	_TranslationsCommonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get sort => '정렬';
	@override String get filter => '필터';
	@override String get appName => 'Love Iwara';
	@override String get ok => '확인';
	@override String get cancel => '취소';
	@override String get select => '선택';
	@override String get save => '저장';
	@override String get delete => '삭제';
	@override String get visit => '방문';
	@override String get loading => '로딩 중...';
	@override String get scrollToTop => '맨 위로';
	@override String get privacyHint => '개인정보 보호 모드가 켜져 있어 콘텐츠가 숨겨집니다';
	@override String get latest => '최신';
	@override String get likesCount => '좋아요';
	@override String get viewsCount => '조회수';
	@override String get popular => '인기';
	@override String get trending => '인기 급상승';
	@override String get commentList => '댓글 목록';
	@override String get sendComment => '댓글 보내기';
	@override String get send => '보내기';
	@override String get retry => '재시도';
	@override String get premium => '프리미엄';
	@override String get follower => '팔로워';
	@override String get friend => '친구';
	@override String get video => '동영상';
	@override String get following => '팔로잉';
	@override String get expand => '펼치기';
	@override String get collapse => '접기';
	@override String get cancelFriendRequest => '요청 취소';
	@override String get cancelSpecialFollow => '특별 팔로우 취소';
	@override String get addFriend => '친구 추가';
	@override String get removeFriend => '친구 삭제';
	@override String get followed => '팔로우함';
	@override String get follow => '팔로우';
	@override String get unfollow => '팔로우 취소';
	@override String get specialFollow => '특별 팔로우';
	@override String get specialFollowed => '특별 팔로우함';
	@override String get gallery => '갤러리';
	@override String get playlist => '재생목록';
	@override String get commentPostedSuccessfully => '댓글이 등록되었습니다';
	@override String get commentPostedFailed => '댓글 등록 실패';
	@override String get success => '성공';
	@override String get commentDeletedSuccessfully => '댓글이 삭제되었습니다';
	@override String get commentUpdatedSuccessfully => '댓글이 수정되었습니다';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '댓글 ${n}개',
		other: '댓글 ${n}개',
	);
	@override String get writeYourCommentHere => '여기에 댓글을 작성하세요...';
	@override String get tmpNoReplies => '아직 답글이 없습니다';
	@override String get loadMore => '더 보기';
	@override String get loadingMore => '더 불러오는 중...';
	@override String get noMoreDatas => '더 이상 데이터가 없습니다';
	@override String get selectTranslationLanguage => '번역 언어 선택';
	@override String get translate => '번역';
	@override String get translateFailedPleaseTryAgainLater => '번역 실패, 나중에 다시 시도해 주세요';
	@override String get translationResult => '번역 결과';
	@override String get justNow => '방금';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '${n}분 전',
		other: '${n}분 전',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '${n}시간 전',
		other: '${n}시간 전',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '${n}일 전',
		other: '${n}일 전',
	);
	@override String editedAt({required Object num}) => '${num} 수정됨';
	@override String get editComment => '댓글 수정';
	@override String get commentUpdated => '댓글 수정됨';
	@override String get replyComment => '댓글에 답글';
	@override String get reply => '답글';
	@override String get edit => '편집';
	@override String get unknownUser => '알 수 없는 사용자';
	@override String get me => '나';
	@override String get author => '작성자';
	@override String get admin => '관리자';
	@override String viewReplies({required Object num}) => '답글 보기(${num})';
	@override String get hideReplies => '답글 숨기기';
	@override String get confirmDelete => '삭제 확인';
	@override String get areYouSureYouWantToDeleteThisItem => '이 항목을 삭제하시겠습니까?';
	@override String get tmpNoComments => '아직 댓글이 없습니다';
	@override String get refresh => '새로 고침';
	@override String get back => '뒤로';
	@override String get tips => '팁';
	@override String get linkIsEmpty => '링크가 비어 있습니다';
	@override String get linkCopiedToClipboard => '링크가 클립보드에 복사되었습니다';
	@override String get imageCopiedToClipboard => '이미지가 클립보드에 복사되었습니다';
	@override String get copyImageFailed => '이미지 복사 실패';
	@override String get mobileSaveImageIsUnderDevelopment => '모바일 이미지 저장 기능은 개발 중입니다';
	@override String get imageSavedTo => '이미지 저장 위치:';
	@override String get saveImageFailed => '이미지 저장 실패';
	@override String get close => '닫기';
	@override String get more => '더보기';
	@override String get unknownError => '알 수 없는 오류';
	@override String get moreFeaturesToBeDeveloped => '더 많은 기능이 개발될 예정입니다';
	@override String get all => '전체';
	@override String selectedRecords({required Object num}) => '${num}개 기록 선택됨';
	@override String get cancelSelectAll => '전체 선택 해제';
	@override String get selectAll => '전체 선택';
	@override String get invertSelection => '선택 반전';
	@override String get exitEditMode => '편집 모드 종료';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '선택한 ${num}개 항목을 삭제하시겠습니까?';
	@override String get searchHistoryRecords => '기록 검색...';
	@override String get settings => '설정';
	@override String get subscriptions => '구독';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '동영상 ${n}개',
		other: '동영상 ${n}개',
	);
	@override String get share => '공유';
	@override String get areYouSureYouWantToShareThisPlaylist => '이 재생목록을 공유하시겠습니까?';
	@override String get editTitle => '제목 편집';
	@override String get editMode => '편집 모드';
	@override String get pleaseEnterNewTitle => '새 제목을 입력해 주세요';
	@override String get createPlayList => '재생목록 만들기';
	@override String get create => '만들기';
	@override String get checkNetworkSettings => '네트워크 설정 확인';
	@override String get general => '일반';
	@override String get r18 => 'R18';
	@override String get sensitive => '민감';
	@override String get year => '년';
	@override String get month => '월';
	@override String get tag => '태그';
	@override String get private => '비공개';
	@override String get noTitle => '제목 없음';
	@override String get search => '검색';
	@override String get noContent => '콘텐츠 없음';
	@override String get recording => '녹음 중';
	@override String get paused => '일시정지됨';
	@override String get clear => '지우기';
	@override String get clearSelection => '선택 해제';
	@override String get selectItemsToContinue => '계속하려면 항목을 선택하세요';
	@override String andMoreItems({required Object num}) => '그 외 ${num}개';
	@override String get batchDelete => '일괄 삭제';
	@override String get user => '사용자';
	@override String get post => '게시물';
	@override String get seconds => '초';
	@override String get comingSoon => '출시 예정';
	@override String get confirm => '확인';
	@override String get hour => '시간';
	@override String get minute => '분';
	@override String get clickToRefresh => '클릭하여 새로 고침';
	@override String get history => '기록';
	@override String get favorites => '즐겨찾기';
	@override String get friends => '친구';
	@override String get playList => '재생목록';
	@override String get checkLicense => '라이선스 확인';
	@override String get logout => '로그아웃';
	@override String get fensi => '팬';
	@override String get accept => '수락';
	@override String get reject => '거부';
	@override String get clearAllHistory => '모든 기록 지우기';
	@override String get clearAllHistoryConfirm => '모든 기록을 지우시겠습니까?';
	@override String get followingList => '팔로잉 목록';
	@override String get followersList => '팔로워 목록';
	@override String get follows => '팔로우';
	@override String get fans => '팬';
	@override String get followsAndFans => '팔로우 및 팬';
	@override String get numViews => '조회수';
	@override String get updatedAt => '수정일';
	@override String get publishedAt => '게시일';
	@override String get externalVideo => '외부 동영상';
	@override String get originalText => '원문';
	@override String get showOriginalText => '원문 표시';
	@override String get showProcessedText => '처리된 텍스트 표시';
	@override String get preview => '미리보기';
	@override String get rules => '규칙';
	@override String get agree => '동의';
	@override String get disagree => '동의하지 않음';
	@override String get agreeToRules => '규칙에 동의';
	@override String get markdownSyntaxHelp => 'Markdown 문법 도움말';
	@override String get previewContent => '내용 미리보기';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => '최대 길이 제한(${max})을 초과했습니다';
	@override String get agreeToCommunityRules => '커뮤니티 규칙에 동의';
	@override String get createPost => '게시물 작성';
	@override String get title => '제목';
	@override String get enterTitle => '제목을 입력해 주세요';
	@override String get content => '콘텐츠';
	@override String get enterContent => '내용을 입력해 주세요';
	@override String get writeYourContentHere => '내용을 입력해 주세요...';
	@override String get tagBlacklist => '태그 블랙리스트';
	@override String get noData => '데이터 없음';
	@override String get tagLimit => '태그 제한';
	@override String get enableFloatingButtons => '플로팅 버튼 켜기';
	@override String get disableFloatingButtons => '플로팅 버튼 끄기';
	@override String get enabledFloatingButtons => '플로팅 버튼 켜짐';
	@override String get disabledFloatingButtons => '플로팅 버튼 꺼짐';
	@override String get pendingCommentCount => '대기 중인 댓글 수';
	@override String joined({required Object str}) => '${str} 가입';
	@override String lastSeenAt({required Object str}) => '최근 활동: ${str}';
	@override String get download => '다운로드';
	@override String get selectQuality => '화질 선택';
	@override String get videoQualitySource => '원본';
	@override String get selectImageQuality => '이미지 화질 선택';
	@override String get imageQualityStandard => '표준';
	@override String get imageQualityOriginal => '원본';
	@override String get selectDateRange => '날짜 범위 선택';
	@override String get selectDateRangeHint => '날짜 범위를 선택하세요. 기본값은 최근 30일입니다';
	@override String get clearDateRange => '날짜 범위 지우기';
	@override String get deleteRecordsInDateRange => '이 범위의 기록 삭제';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => '이 날짜 범위의 기록 ${num}개를 삭제하시겠습니까? 되돌릴 수 없습니다.';
	@override String get noHistoryRecordsInRange => '이 날짜 범위에 기록이 없습니다';
	@override String get followSuccessClickAgainToSpecialFollow => '팔로우했습니다. 다시 클릭하면 특별 팔로우';
	@override String get specialFollowTip => '특별 팔로우에 추가되었습니다 — 구독 페이지 오른쪽 위 선택기에서 골라 빠르게 접근할 수 있습니다';
	@override String get exitConfirmTip => '종료하시겠습니까?';
	@override String get error => '오류';
	@override String get taskRunning => '이미 작업이 실행 중입니다. 잠시 기다려 주세요.';
	@override String get operationCancelled => '작업이 취소되었습니다.';
	@override String get unsavedChanges => '저장하지 않은 변경 사항이 있습니다';
	@override String get specialFollowsManagementTip => '핸들을 끌어 순서를 바꾸고 • 버튼을 눌러 삭제하세요';
	@override String get specialFollowsManagement => '특별 팔로우 관리';
	@override String get removeSpecialFollow => '특별 팔로우 해제';
	@override String removeSpecialFollowConfirm({required Object name}) => '${name}님을 특별 팔로우에서 해제하시겠습니까?';
	@override String get noSpecialFollows => '아직 특별 팔로우가 없습니다';
	@override String get createTimeDesc => '작성 시간 내림차순';
	@override String get createTimeAsc => '작성 시간 오름차순';
	@override late final _TranslationsCommonPaginationKo pagination = _TranslationsCommonPaginationKo._(_root);
	@override String get notice => '공지';
	@override String get detail => '상세';
	@override String get parseExceptionDestopHint => ' - 데스크톱 사용자는 설정에서 프록시를 구성할 수 있습니다';
	@override String get iwaraTags => 'Iwara 태그';
	@override String get tagInfo => '태그 정보';
	@override String get tagOriginalKey => '원본 태그';
	@override String get tagTranslation => '번역';
	@override String get copy => '복사';
	@override String get selectCopy => '선택 및 복사';
	@override String get copiedToClipboard => '클립보드에 복사되었습니다';
	@override String get showOriginalTag => '원본 태그 표시';
	@override String get showTranslatedTag => '번역 표시';
	@override String get tagTranslationFeedback => '번역이 의심스러우신가요? 피드백 보내기';
	@override String get tagLocalizationGuideTitle => '태그 번역 정보';
	@override String get tagLocalizationGuideContent => '앱은 Iwara의 원본 태그(예: mother)를 현재 언어의 이름으로 표시합니다.\n\n• 태그를 검색할 때 번역과 원본 태그가 모두 일치합니다.\n• 태그를 길게 누르거나 오른쪽 클릭하면 원본 키와 번역을 확인하고 복사할 수 있습니다.\n• 번역은 커뮤니티가 유지 관리하며 최선을 다한 결과로, 오류가 있을 수 있습니다.';
	@override String get likeThisVideo => '이 동영상 좋아요';
	@override String get likeThisGallery => '이 갤러리 좋아요';
	@override String get operation => '작업';
	@override String get replies => '답글';
	@override String get externalLinkWarning => '외부 링크 경고';
	@override String get externalLinkWarningMessage => 'iwara.tv에 속하지 않은 외부 링크를 열려고 합니다. 주의하고 링크가 안전한지 확인한 후 진행해 주세요.';
	@override String get continueToExternalLink => '계속';
	@override String get cancelExternalLink => '취소';
}

// Path: auth
class _TranslationsAuthKo extends TranslationsAuthEn {
	_TranslationsAuthKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get login => '로그인';
	@override String get logout => '로그아웃';
	@override String get email => '이메일';
	@override String get password => '비밀번호';
	@override String get loginOrRegister => '로그인 / 회원가입';
	@override String get register => '회원가입';
	@override String get pleaseEnterEmail => '이메일을 입력해 주세요';
	@override String get pleaseEnterPassword => '비밀번호를 입력해 주세요';
	@override String get passwordMustBeAtLeast6Characters => '비밀번호는 6자 이상이어야 합니다';
	@override String get pleaseEnterCaptcha => '인증 코드를 입력해 주세요';
	@override String get captcha => '인증 코드';
	@override String get refreshCaptcha => '인증 코드 새로 고침';
	@override String get captchaNotLoaded => '인증 코드가 로드되지 않았습니다';
	@override String get loginSuccess => '로그인 성공';
	@override String get loginSuccessProfilePending => '로그인되었습니다. 프로필을 불러오는 중…';
	@override String get emailVerificationSent => '이메일 인증이 전송되었습니다';
	@override String get notLoggedIn => '로그인하지 않음';
	@override String get clickToLogin => '클릭하여 로그인';
	@override String get logoutConfirmation => '로그아웃하시겠습니까?';
	@override String get logoutSuccess => '로그아웃 성공';
	@override String get logoutFailed => '로그아웃 실패';
	@override String get usernameOrEmail => '사용자 이름 또는 이메일';
	@override String get pleaseEnterUsernameOrEmail => '사용자 이름 또는 이메일을 입력해 주세요';
	@override String get rememberMe => '사용자 이름 기억';
	@override String get registerNoticeTitle => '공식 웹사이트에서 가입';
	@override String get registerNoticeDescription => '앱 내 회원가입은 더 이상 제공되지 않습니다. 공식 Iwara 웹사이트에서 계정을 만든 후 다시 돌아와 로그인해 주세요.';
	@override String get registerNoticeReturnTip => '가입 후 이곳으로 돌아와 계정으로 로그인해 주세요.';
	@override String get goToOfficialWebsite => '공식 웹사이트로 이동';
}

// Path: errors
class _TranslationsErrorsKo extends TranslationsErrorsEn {
	_TranslationsErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류';
	@override String get required => '필수 항목입니다';
	@override String get invalidEmail => '잘못된 이메일 주소';
	@override String get networkError => '네트워크 오류, 다시 시도해 주세요';
	@override String get errorWhileFetching => '가져오는 중 오류';
	@override String get commentCanNotBeEmpty => '댓글 내용은 비워 둘 수 없습니다';
	@override String get errorWhileFetchingReplies => '답글을 가져오는 중 오류가 발생했습니다. 네트워크 연결을 확인해 주세요';
	@override String get canNotFindCommentController => '댓글 컨트롤러를 찾을 수 없습니다';
	@override String get errorWhileLoadingGallery => '갤러리를 불러오는 중 오류';
	@override String get howCouldThereBeNoDataItCantBePossible => '데이터가 없을 리가 없는데요? 말도 안 돼요 :<';
	@override String unsupportedImageFormat({required Object str}) => '지원하지 않는 이미지 형식: ${str}';
	@override String get invalidGalleryId => '잘못된 갤러리 ID';
	@override String get translationFailedPleaseTryAgainLater => '번역 실패, 나중에 다시 시도해 주세요';
	@override String get errorOccurred => '오류가 발생했습니다. 나중에 다시 시도해 주세요.';
	@override String get errorOccurredWhileProcessingRequest => '요청 처리 중 오류가 발생했습니다';
	@override String get errorWhileFetchingDatas => '데이터를 가져오는 중 오류가 발생했습니다. 나중에 다시 시도해 주세요';
	@override String get serviceNotInitialized => '서비스가 초기화되지 않았습니다';
	@override String get unknownType => '알 수 없는 유형';
	@override String errorWhileOpeningLink({required Object link}) => '링크를 여는 중 오류: ${link}';
	@override String get invalidUrl => '잘못된 URL';
	@override String get failedToOperate => '작업 실패';
	@override String get permissionDenied => '권한 거부됨';
	@override String get youDoNotHavePermissionToAccessThisResource => '이 리소스에 접근할 권한이 없습니다';
	@override String get loginFailed => '로그인 실패';
	@override String get unknownError => '알 수 없는 오류';
	@override String get sessionExpired => '세션이 만료되었습니다';
	@override String get failedToFetchCaptcha => '인증 코드를 가져오지 못했습니다';
	@override String get emailAlreadyExists => '이메일이 이미 존재합니다';
	@override String get invalidCaptcha => '잘못된 인증 코드';
	@override String get registerFailed => '회원가입 실패';
	@override String get failedToFetchComments => '댓글을 가져오지 못했습니다';
	@override String get failedToFetchImageDetail => '이미지 상세를 가져오지 못했습니다';
	@override String get failedToFetchImageList => '이미지 목록을 가져오지 못했습니다';
	@override String get failedToFetchData => '데이터를 가져오지 못했습니다';
	@override String get invalidParameter => '잘못된 매개변수';
	@override String get pleaseLoginFirst => '먼저 로그인해 주세요';
	@override String get errorWhileLoadingPost => '게시물을 불러오는 중 오류';
	@override String get errorWhileLoadingPostDetail => '게시물 상세를 불러오는 중 오류';
	@override String get invalidPostId => '잘못된 게시물 ID';
	@override String get forceUpdateNotPermittedToGoBack => '현재 강제 업데이트 상태로 뒤로 갈 수 없습니다';
	@override String get pleaseLoginAgain => '다시 로그인해 주세요';
	@override String get invalidLogin => '로그인 정보가 잘못되었습니다. 이메일과 비밀번호를 확인해 주세요';
	@override String get tooManyRequests => '요청이 너무 많습니다. 나중에 다시 시도해 주세요';
	@override String exceedsMaxLength({required Object max}) => '최대 길이 초과: ${max}';
	@override String get contentCanNotBeEmpty => '내용은 비워 둘 수 없습니다';
	@override String get titleCanNotBeEmpty => '제목은 비워 둘 수 없습니다';
	@override String get tooManyRequestsPleaseTryAgainLaterText => '요청이 너무 많습니다. 나중에 다시 시도해 주세요. 남은 시간';
	@override String remainingHours({required Object num}) => '${num}시간';
	@override String remainingMinutes({required Object num}) => '${num}분';
	@override String remainingSeconds({required Object num}) => '${num}초';
	@override String tagLimitExceeded({required Object limit}) => '태그 제한을 초과했습니다. 제한: ${limit}';
	@override String get failedToRefresh => '새로 고침 실패';
	@override String get noPermission => '권한 없음';
	@override String get resourceNotFound => '리소스를 찾을 수 없습니다';
	@override String get failedToSaveCredentials => '로그인 자격 증명을 저장하지 못했습니다';
	@override String get failedToLoadSavedCredentials => '저장된 자격 증명을 불러오지 못했습니다';
	@override String get notFound => '콘텐츠를 찾을 수 없거나 삭제되었습니다';
	@override late final _TranslationsErrorsNetworkKo network = _TranslationsErrorsNetworkKo._(_root);
}

// Path: friends
class _TranslationsFriendsKo extends TranslationsFriendsEn {
	_TranslationsFriendsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => '클릭하여 친구 복원';
	@override String get friendsList => '친구 목록';
	@override String get friendRequests => '친구 요청';
	@override String get friendRequestsList => '친구 요청 목록';
	@override String get removingFriend => '친구 삭제 중...';
	@override String get failedToRemoveFriend => '친구를 삭제하지 못했습니다';
	@override String get cancelingRequest => '친구 요청 취소 중...';
	@override String get failedToCancelRequest => '친구 요청을 취소하지 못했습니다';
}

// Path: authorProfile
class _TranslationsAuthorProfileKo extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => '더 이상 데이터가 없습니다';
	@override String get userProfile => '사용자 프로필';
}

// Path: favorites
class _TranslationsFavoritesKo extends TranslationsFavoritesEn {
	_TranslationsFavoritesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => '클릭하여 즐겨찾기 복원';
	@override String get myFavorites => '내 즐겨찾기';
	@override String get batchCancelFavorite => '선택한 즐겨찾기 제거';
	@override String batchCancelFavoriteConfirm({required Object count}) => '선택한 ${count}개 항목을 즐겨찾기에서 제거하시겠습니까? 이후 카드를 탭하면 복원할 수 있습니다.';
	@override String batchCancelFavoriteSuccess({required Object count}) => '${count}개 항목을 즐겨찾기에서 제거했습니다';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => '${success}개 제거됨, ${failed}개 실패';
}

// Path: galleryDetail
class _TranslationsGalleryDetailKo extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => '공간에서 탐색';
	@override String get galleryDetail => '갤러리 상세';
	@override String get viewGalleryDetail => '갤러리 상세 보기';
	@override String get zoomReset => '확대/축소 초기화';
	@override String get copyLink => '링크 복사';
	@override String get copyImage => '이미지 복사';
	@override String get saveAs => '다른 이름으로 저장';
	@override String get saveToAlbum => '앨범에 저장';
	@override String get publishedAt => '게시일';
	@override String get viewsCount => '조회수';
	@override String get imageLibraryFunctionIntroduction => '이미지 라이브러리 기능 소개';
	@override String get rightClickToSaveSingleImage => '오른쪽 클릭으로 단일 이미지 저장';
	@override String get batchSave => '일괄 저장';
	@override String get keyboardLeftAndRightToSwitch => '키보드 좌우 키로 전환';
	@override String get keyboardUpAndDownToZoom => '키보드 상하 키로 확대/축소';
	@override String get mouseWheelToSwitch => '마우스 휠로 전환';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + 마우스 휠로 확대/축소';
	@override String get moreFeaturesToBeDiscovered => '더 많은 기능이 있습니다...';
	@override String get authorOtherGalleries => '작성자의 다른 갤러리';
	@override String get relatedGalleries => '관련 갤러리';
	@override String get authorNoOtherGalleries => '이 작성자의 다른 갤러리가 없습니다';
	@override String get noRelatedGalleries => '관련 갤러리가 없습니다';
	@override String get scrollLeft => '왼쪽으로 스크롤';
	@override String get scrollRight => '오른쪽으로 스크롤';
	@override String get clickLeftAndRightEdgeToSwitchImage => '이미지를 전환하려면 좌우 가장자리를 클릭하세요';
	@override String get rotateToLandscape => '가로 전체 화면';
	@override String get backToPortrait => '세로 모드로 돌아가기';
}

// Path: playList
class _TranslationsPlayListKo extends TranslationsPlayListEn {
	_TranslationsPlayListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => '내 재생목록';
	@override String get friendlyTips => '친절한 안내';
	@override String get dearUser => '사용자님께';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'iwara의 재생목록 시스템은 아직 완벽하지 않습니다';
	@override String get notSupportSetCover => '커버 설정은 지원되지 않습니다';
	@override String get notSupportDeleteList => '재생목록 삭제는 지원되지 않습니다';
	@override String get notSupportSetPrivate => '비공개 설정은 지원되지 않습니다';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => '예... 만든 재생목록은 항상 존재하며 모든 사람에게 공개됩니다';
	@override String get smallSuggestion => '작은 제안';
	@override String get useLikeToCollectContent => '개인정보 보호를 더 중시하신다면 "좋아요" 기능으로 콘텐츠를 수집하시길 권장합니다';
	@override String get welcomeToDiscussOnGitHub => '다른 제안이나 아이디어가 있으시면 GitHub에서 논의해 주세요!';
	@override String get iUnderstand => '이해했습니다';
	@override String get searchPlaylists => '재생목록 검색...';
	@override String get newPlaylistName => '새 재생목록 이름';
	@override String get createNewPlaylist => '새 재생목록 만들기';
	@override String get videos => '동영상';
}

// Path: search
class _TranslationsSearchKo extends TranslationsSearchEn {
	_TranslationsSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => '검색 범위';
	@override String get searchTags => '태그 검색...';
	@override String get contentRating => '콘텐츠 등급';
	@override String get removeTag => '태그 제거';
	@override String get pleaseEnterSearchContent => '검색 내용을 입력하세요';
	@override String get searchHistory => '검색 기록';
	@override String get searchSuggestion => '검색 제안';
	@override String get usedTimes => '사용 횟수';
	@override String get lastUsed => '마지막 사용';
	@override String get noSearchHistoryRecords => '검색 기록이 없습니다';
	@override String get clearSearchHistoryConfirm => '모든 검색 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String notSupportCurrentSearchType({required Object searchType}) => '현재 검색 유형 ${searchType}은 지원되지 않습니다. 업데이트를 기다려 주세요';
	@override String get searchResult => '검색 결과';
	@override String unsupportedSearchType({required Object searchType}) => '지원되지 않는 검색 유형: ${searchType}';
	@override String get googleSearch => 'Google 검색';
	@override String googleSearchHint({required Object webName}) => '${webName}의 검색 기능이 사용하기 불편하신가요? Google 검색을 사용해 보세요!';
	@override String get googleSearchDescription => 'Google 검색의 :site 검색 연산자를 사용하여 사이트의 콘텐츠를 검색합니다. 동영상, 갤러리, 재생목록, 사용자를 검색할 때 매우 유용합니다.';
	@override String get googleSearchKeywordsHint => '검색할 키워드를 입력하세요';
	@override String get openLinkJump => '링크 바로 열기';
	@override String get googleSearchButton => 'Google 검색';
	@override String get pleaseEnterSearchKeywords => '검색 키워드를 입력하세요';
	@override String get googleSearchQueryCopied => '검색어가 클립보드에 복사되었습니다';
	@override String googleSearchBrowserOpenFailed({required Object error}) => '브라우저를 열지 못했습니다: ${error}';
	@override String get searchRequestTimeout => '요청 시간이 초과되었습니다. 나중에 다시 시도해 주세요';
	@override String get searchCannotConnectToServer => '서버에 연결할 수 없습니다. 네트워크 연결을 확인해 주세요';
	@override String get searchNetworkError => '네트워크 연결에 실패했습니다. 네트워크 설정을 확인하거나 나중에 다시 시도해 주세요';
	@override String get searchFailedPleaseRetry => '검색에 실패했습니다. 나중에 다시 시도해 주세요';
}

// Path: mediaList
class _TranslationsMediaListKo extends TranslationsMediaListEn {
	_TranslationsMediaListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => '소개';
}

// Path: settings
class _TranslationsSettingsKo extends TranslationsSettingsEn {
	_TranslationsSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => '목록 보기 모드';
	@override String get previewEffect => '미리보기 효과';
	@override String get useTraditionalPaginationMode => '기존 페이지네이션 모드 사용';
	@override String get useTraditionalPaginationModeDesc => '기존 페이지네이션 모드를 활성화하고 워터폴 모드를 비활성화합니다. 페이지를 다시 렌더링하거나 앱을 다시 시작한 후 적용됩니다';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => '도구 모음 숨김 시 동영상 진행률 하단 바 표시';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => '이 설정은 도구 모음이 숨겨졌을 때 동영상 진행률 하단 바를 표시할지 여부를 결정합니다.';
	@override String get seekPreviewSize => '탐색 미리보기 크기';
	@override String get seekPreviewSizeDesc => '진행 표시줄 위 미리보기 창의 크기입니다. 이미 플레이어 크기와 동영상 화면 비율을 따르며, 이 설정은 이를 약간 조정할 뿐입니다.';
	@override String get seekPreviewSizeSmall => '작게';
	@override String get seekPreviewSizeStandard => '표준';
	@override String get seekPreviewSizeLarge => '크게';
	@override String get seekPreviewSizeStandardDesc => '플레이어와 동영상에서 산출된 크기';
	@override String get showFullscreenUpNextHint => '다음 항목 핸들 표시';
	@override String get showFullscreenUpNextHintDesc => '플레이어 오른쪽 가장자리에 대기열 서랍(소스/재생목록/나중에 볼 항목)을 여는 작은 핸들을 표시합니다. 꺼 두면 들어갈 다른 방법이 없습니다.';
	@override String get basicSettings => '기본 설정';
	@override String get personalizedSettings => '개인화 설정';
	@override String get otherSettings => '기타 설정';
	@override String get searchConfig => '검색 설정';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => '이 설정은 동영상을 다시 재생할 때 이전 설정을 사용할지 여부를 결정합니다.';
	@override String get playControl => '재생 제어';
	@override String get playbackSpeedSettings => '재생 및 속도';
	@override String get playbackBehaviorSettings => '재생 동작';
	@override String get enhancementSettings => '극장 및 향상';
	@override String get fastForwardTime => '빨리 감기 시간';
	@override String get fastForwardTimeMustBeAPositiveInteger => '빨리 감기 시간은 양의 정수여야 합니다.';
	@override String get rewindTime => '되감기 시간';
	@override String get rewindTimeMustBeAPositiveInteger => '되감기 시간은 양의 정수여야 합니다.';
	@override String get longPressPlaybackSpeed => '길게 누르기 재생 속도';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => '길게 누르기 재생 속도는 양수여야 합니다.';
	@override String get defaultPlaybackSpeed => '기본 재생 속도';
	@override String get rememberPlaybackSpeed => '재생 속도 기억';
	@override String get rememberPlaybackSpeedDesc => '활성화하면 플레이어에서 설정한 속도가 기본값으로 저장되어 새 동영상에 자동으로 적용됩니다.';
	@override String get repeat => '반복';
	@override String get renderVerticalVideoInVerticalScreen => '세로 화면에서 세로 동영상 렌더링';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => '이 설정은 전체 화면으로 재생할 때 동영상을 세로 화면으로 렌더링할지 여부를 결정합니다.';
	@override String get rememberVolume => '볼륨 기억';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => '이 설정은 동영상을 다시 재생할 때 볼륨을 유지할지 여부를 결정합니다.';
	@override String get rememberBrightness => '밝기 기억';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => '이 설정은 동영상을 다시 재생할 때 밝기를 유지할지 여부를 결정합니다.';
	@override String get playControlArea => '재생 제어 영역';
	@override String get leftAndRightControlAreaWidth => '좌우 제어 영역 너비';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => '이 설정은 플레이어 좌우 제어 영역의 너비를 결정합니다.';
	@override String get proxyAddressCannotBeEmpty => '프록시 주소는 비워 둘 수 없습니다.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => '프록시 주소 형식이 올바르지 않습니다. IP:포트 또는 도메인 이름:포트 형식을 사용해 주세요.';
	@override String get proxyNormalWork => '프록시가 정상 작동합니다.';
	@override String testProxyFailedWithStatusCode({required Object code}) => '프록시 테스트 실패, 상태 코드: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => '프록시 테스트 실패, 예외: ${exception}';
	@override String get proxyConfig => '프록시 설정';
	@override String get thisIsHttpProxyAddress => '이것은 http 프록시 주소입니다';
	@override String get checkProxy => '프록시 확인';
	@override String get proxyAddress => '프록시 주소';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => '프록시 서버의 URL을 입력하세요. 예: 127.0.0.1:8080';
	@override String get enableProxy => '프록시 사용';
	@override String get left => '왼쪽';
	@override String get middle => '가운데';
	@override String get right => '오른쪽';
	@override String get playerSettings => '플레이어 설정';
	@override String get networkSettings => '네트워크 설정';
	@override String get customizeYourPlaybackExperience => '재생 환경 사용자 지정';
	@override String get chooseYourFavoriteAppAppearance => '원하는 앱 테마를 선택하세요';
	@override String get configureYourProxyServer => '프록시 서버 구성';
	@override String get settings => '설정';
	@override String get themeSettings => '테마 설정';
	@override String get followSystem => '시스템 설정 따르기';
	@override String get lightMode => '라이트 모드';
	@override String get darkMode => '다크 모드';
	@override String get presetTheme => '사전 설정 테마';
	@override String get basicTheme => '기본 테마';
	@override String get needRestartToApply => '설정을 적용하려면 앱을 다시 시작해야 합니다';
	@override String get themeNeedRestartDescription => '테마 설정을 적용하려면 앱을 다시 시작해야 합니다';
	@override String get about => '정보';
	@override String get diagnosticsAndFeedback => '진단 및 피드백';
	@override String get currentVersion => '현재 버전';
	@override String get latestVersion => '최신 버전';
	@override String get checkForUpdates => '업데이트 확인';
	@override String get update => '업데이트';
	@override String get newVersionAvailable => '새 버전 사용 가능';
	@override String get projectHome => '프로젝트 홈';
	@override String get release => '릴리스';
	@override String get issueReport => '문제 신고';
	@override String get openSourceLicense => '오픈 소스 라이선스';
	@override String get checkForUpdatesFailed => '업데이트 확인에 실패했습니다. 나중에 다시 시도해 주세요';
	@override String get autoCheckUpdate => '자동 업데이트 확인';
	@override String get updateContent => '업데이트 내용';
	@override String get releaseDate => '릴리스 날짜';
	@override String get ignoreThisVersion => '이 버전 무시';
	@override String get forceUpdateTip => '필수 업데이트입니다. 가능한 한 빨리 최신 버전으로 업데이트해 주세요';
	@override String get viewChangelog => '변경 로그 보기';
	@override String get alreadyLatestVersion => '이미 최신 버전입니다';
	@override String get appSettings => '앱 설정';
	@override String get configureYourAppSettings => '앱 설정 구성';
	@override String get history => '기록';
	@override String get autoRecordHistory => '기록 자동 저장';
	@override String get autoRecordHistoryDesc => '시청한 동영상과 이미지를 자동으로 기록합니다';
	@override String get autoDeleteHistory => '기록 자동 정리';
	@override String get autoDeleteHistoryDesc => '시작 시 보관 일수를 초과한 검색 기록을 자동으로 삭제합니다 (기본값 꺼짐)';
	@override String get autoDeleteHistoryDays => '보관 일수';
	@override String autoDeleteHistoryDaysValue({required Object num}) => '최근 ${num}일 유지';
	@override String get autoDeleteHistoryDaysInvalid => '유효한 일수(최소 1)를 입력하세요';
	@override String get showUnprocessedMarkdownText => '처리되지 않은 Markdown 텍스트 표시';
	@override String get showUnprocessedMarkdownTextDesc => 'markdown 원본 텍스트를 표시합니다';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => '개인정보 보호 모드';
	@override String get activeBackgroundPrivacyModeDesc => '스크린샷과 화면 녹화를 차단하고 백그라운드에서 화면을 숨깁니다';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => '앱이 백그라운드로 전환되면 화면을 숨깁니다 (이 플랫폼은 스크린샷을 차단할 수 없습니다)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => '스크린샷과 화면 녹화를 차단합니다';
	@override String get privacy => '개인정보';
	@override String get appLock => '앱 잠금';
	@override String get appLockEnabled => '앱 잠금 사용';
	@override String get appLockEnabledDesc => '앱을 열 때 PIN 또는 생체 인증을 요구합니다. 백그라운드 미리보기는 자동으로 숨겨집니다';
	@override String get appLockEnabledSummary => '켜짐 · PIN 보호';
	@override String get appLockDisabledSummary => '꺼짐';
	@override String get appLockTimeout => '앱을 나간 후 잠금';
	@override String get appLockTimeoutDesc => '인증이 필요해지기까지 백그라운드에서 허용되는 시간';
	@override String get appLockAfterScreenOff => '화면 잠금 후 잠금';
	@override String get appLockAfterScreenOffDesc => '기기 화면이 잠긴 후 인증을 요구합니다';
	@override String get appLockTimeoutDisabled => '사용 안 함';
	@override String get appLockImmediately => '즉시';
	@override String appLockSeconds({required Object seconds}) => '${seconds}초';
	@override String appLockMinutes({required Object minutes}) => '${minutes}분';
	@override String get appLockUseBiometrics => '생체 인증 사용';
	@override String get appLockUseBiometricsDesc => '지문 또는 얼굴 인식으로 잠금 해제';
	@override String get appLockBiometricsUnavailable => '이 기기에 등록된 생체 인증 정보가 없습니다';
	@override String get appLockSetPin => 'PIN 설정';
	@override String get appLockEnterPin => 'PIN 입력';
	@override String get appLockConfirmPin => 'PIN 확인';
	@override String get appLockCurrentPin => '현재 PIN 입력';
	@override String get appLockNewPin => '새 PIN 입력';
	@override String get appLockPinRequirements => 'PIN은 4~8자리 숫자여야 합니다';
	@override String get appLockPinsDoNotMatch => 'PIN이 일치하지 않습니다';
	@override String get appLockInvalidPin => 'PIN이 올바르지 않습니다';
	@override String get appLockSetupFailed => 'PIN을 안전하게 저장하지 못했습니다';
	@override String get appLockDisable => '앱 잠금을 해제하려면 PIN을 입력하세요';
	@override String get appLockChangePin => 'PIN 변경';
	@override String get appLockNow => '지금 잠금';
	@override String get appLockUnlock => '잠금 해제';
	@override String get appLockLockedTitle => '잠김';
	@override String get appLockLockedDesc => '계속하려면 인증하세요';
	@override String get appLockAuthenticateReason => '잠금을 해제하려면 인증하세요';
	@override String get appLockEnableBiometricsReason => '생체 인증 잠금 해제를 사용하려면 인증하세요';
	@override String get appLockBiometricFailed => '생체 인증이 완료되지 않았습니다';
	@override String appLockTooManyAttempts({required Object seconds}) => '시도가 너무 많습니다. ${seconds}초 후에 다시 시도하세요';
	@override String get appLockCredentialUnavailableTitle => '앱 잠금 자격 증명을 읽을 수 없습니다';
	@override String get appLockCredentialUnavailableDesc => '시스템 보안 저장소를 일시적으로 사용할 수 없거나 자격 증명이 손상되었습니다. 앱은 잠긴 상태로 유지됩니다. 먼저 다시 시도하고, 계속 실패하면 앱 잠금을 재설정할 수 있으며, 이 경우 잠금이 해제되고 저장된 PIN이 삭제됩니다.';
	@override String get appLockRetry => '다시 시도';
	@override String get appLockReset => '앱 잠금 재설정';
	@override String get appLockResetAction => '재설정';
	@override String get appLockResetConfirmTitle => '앱 잠금을 재설정하시겠습니까?';
	@override String get appLockResetConfirmDesc => '앱 잠금을 끄고 저장된 PIN과 생체 인증 설정을 삭제합니다. 이후 다시 설정할 수 있습니다.';
	@override String get appLockRetrySucceeded => '자격 증명을 읽었습니다. PIN을 입력하세요.';
	@override String get appLockRetryFailed => '여전히 자격 증명을 읽을 수 없습니다';
	@override String get forum => '포럼';
	@override String get news => '뉴스';
	@override String get community => '커뮤니티';
	@override String get disableForumReplyQuote => '포럼 답글 인용 비활성화';
	@override String get disableForumReplyQuoteDesc => '포럼에서 답글을 작성할 때 답글 대상 층 정보를 함께 전송하지 않습니다';
	@override String get theaterMode => '극장 모드';
	@override String get theaterModeDesc => '켜면 플레이어 배경이 동영상 커버의 블러 처리된 버전으로 설정됩니다';
	@override String get appLinks => '앱 링크';
	@override String get defaultBrowser => '기본 브라우저';
	@override String get defaultBrowserDesc => '시스템 설정에서 기본 링크 설정 항목을 열고 iwara.tv 웹사이트 링크를 추가해 주세요';
	@override String get themeMode => '테마 모드';
	@override String get themeModeDesc => '이 설정은 앱의 테마 모드를 결정합니다';
	@override String get glassEffect => '인터페이스 재질';
	@override String get glassEffectDesc => '앱 전반에 사용할 재질을 선택합니다 — 헤더 캡슐, 메뉴, 대화 상자 버튼, 하단 내비게이션 바';
	@override String get liquidGlassEffect => '리퀴드 글래스';
	@override String get liquidGlassEffectDesc => '실제 블러와 굴절입니다. 가장 보기 좋지만 저사양 기기에서는 프레임이 떨어지고 전력을 조금 더 사용할 수 있습니다';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => '표준 Material 3 표면 — 불투명, 블러 없음, 그림자 없음. 최고의 성능과 배터리 수명';
	@override String get glassEffectIntroTitle => '인터페이스 재질을 선택하세요';
	@override String get glassEffectIntroContent => '헤더, 탭 바, 메뉴에 리퀴드 글래스가 사용됩니다 — 실제 블러와 굴절 효과입니다. 기기에서 느리게 느껴지거나 더 단순한 것을 선호하시면 지금 Material로 전환하세요 (불투명 표면, 블러 없음, 그림자 없음).';
	@override String get glassEffectIntroHint => '설정 → 테마 → 인터페이스 재질에서 언제든 변경할 수 있습니다.';
	@override String get glassEffectIntroDone => '유지';
	@override String get dynamicColor => '동적 색상';
	@override String get dynamicColorDesc => '이 설정은 앱이 동적 색상을 사용할지 여부를 결정합니다';
	@override String get useDynamicColor => '동적 색상 사용';
	@override String get useDynamicColorDesc => '이 설정은 앱이 동적 색상을 사용할지 여부를 결정합니다';
	@override String get presetColors => '사전 설정 색상';
	@override String get customColors => '사용자 지정 색상';
	@override String get customColorsDisabledByDynamicColor => '동적 색상이 켜져 있어 사전 설정/사용자 지정 색상을 사용할 수 없습니다. 먼저 동적 색상을 꺼 주세요.';
	@override String get pickColor => '색상 선택';
	@override String get cancel => '취소';
	@override String get confirm => '확인';
	@override String get noCustomColors => '사용자 지정 색상 없음';
	@override String get recordAndRestorePlaybackProgress => '재생 진행률 기록 및 복원';
	@override String get autoPlayVideoOnFirstEnter => '처음 진입 시 동영상 자동 재생';
	@override String get autoPlayVideoOnFirstEnterDesc => '이 설정은 동영상 페이지에 처음 진입할 때 동영상이 자동으로 재생되기 시작할지 여부를 결정합니다.';
	@override String get autoEnterFullscreen => '자동 전체 화면 진입';
	@override String get autoEnterFullscreenDesc => '플레이어가 스스로 전체 화면으로 전환되는 시점입니다. 비공개, 삭제됨, 외부 동영상과 화면 속 화면은 항상 제외됩니다.';
	@override String get autoEnterFullscreenOff => '꺼짐';
	@override String get autoEnterFullscreenOffDesc => '전체 화면으로 자동 전환하지 않습니다';
	@override String get autoEnterFullscreenOnPlaybackStart => '재생 시작 시';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => '재생이 실제로 시작되는 순간 전체 화면으로 전환합니다';
	@override String get autoEnterFullscreenOnDetailPageEnter => '동영상 열 때';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => '동영상 페이지가 열리면 재생을 기다리지 않고 바로 전체 화면으로 전환합니다';
	@override String get autoEnterFullscreenKind => '전체 화면 유형';
	@override String get autoEnterFullscreenKindDesc => '자동으로 진입할 전체 화면 유형입니다. 데스크톱 전용입니다.';
	@override String get autoEnterFullscreenKindSystem => '시스템 전체 화면';
	@override String get autoEnterFullscreenKindSystemDesc => '창 관리자가 창을 전체 화면으로 전환합니다';
	@override String get autoEnterFullscreenKindApp => '앱 전체 화면';
	@override String get autoEnterFullscreenKindAppDesc => '창은 그대로 두고 앱 전체를 플레이어로 전환합니다';
	@override String get signature => '서명';
	@override String get enableSignature => '서명 사용';
	@override String get enableSignatureDesc => '이 설정은 답글 작성 시 앱이 서명을 추가할지 여부를 결정합니다';
	@override String get enterSignature => '서명 입력';
	@override String get editSignature => '서명 편집';
	@override String get signatureContent => '서명 내용';
	@override String get exportConfig => '앱 설정 내보내기';
	@override String get exportConfigDesc => '설정과 기록(검색 기록, 재생 진행률, 즐겨찾기 등)을 파일로 내보내 백업하거나 다른 기기로 전송합니다. 다운로드 작업은 포함되지 않습니다.';
	@override String get importConfig => '앱 설정 가져오기';
	@override String get importConfigDesc => '파일에서 앱 설정 가져오기';
	@override String get exportConfigSuccess => '설정을 성공적으로 내보냈습니다!';
	@override String get exportConfigFailed => '설정을 내보내지 못했습니다';
	@override String get importConfigSuccess => '설정을 성공적으로 가져왔습니다!';
	@override String get importConfigFailed => '설정을 가져오지 못했습니다';
	@override String get exportIncludeSensitive => '민감한 정보 포함';
	@override String get exportIncludeSensitiveDesc => 'API 키, 세션 토큰, 프록시 주소를 포함합니다. 본인 기기로 백업할 때만 활성화하세요.';
	@override String get importConfigOverwriteWarning => '가져오면 현재 설정과 기록(검색 기록, 재생 진행률, 즐겨찾기 등)이 덮어씌워집니다. 계속하시겠습니까?';
	@override String get importConfigRestartTitle => '가져오기 성공';
	@override String get importConfigRestartContent => '설정을 가져왔습니다. 모든 변경 사항을 적용하려면 앱을 완전히 닫고 다시 열어 주세요.';
	@override String get historyUpdateLogs => '업데이트 기록';
	@override String get noUpdateLogs => '업데이트 기록이 없습니다';
	@override String get versionLabel => '버전: {version}';
	@override String get releaseDateLabel => '릴리스 날짜: {date}';
	@override String get noChanges => '업데이트 내용이 없습니다';
	@override String get interaction => '상호작용';
	@override String get enableVibration => '진동 사용';
	@override String get enableVibrationDesc => '앱과 상호작용할 때 진동 피드백을 사용합니다';
	@override String get defaultKeepVideoToolbarVisible => '동영상 도구 모음 항상 표시';
	@override String get defaultKeepVideoToolbarVisibleDesc => '이 설정은 동영상 페이지에 처음 진입할 때 동영상 도구 모음이 계속 표시될지 여부를 결정합니다.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => '모바일 기기에서 극장 모드를 활성화하면 성능 문제가 발생할 수 있습니다. 선택적으로 활성화할 수 있습니다.';
	@override String get fullscreenOrientation => '전체 화면 진입 후 세로 화면 방향';
	@override String get fullscreenOrientationDesc => '이 설정은 전체 화면 진입 시 기본 화면 방향을 결정합니다 (모바일 전용)';
	@override String get fullscreenOrientationLeftLandscape => '왼쪽 가로';
	@override String get fullscreenOrientationRightLandscape => '오른쪽 가로';
	@override String get screenFit => '화면 크기';
	@override String get screenFitDesc => '동영상이 플레이어 영역을 채우는 방식을 선택합니다.';
	@override String get rememberScreenFit => '화면 크기 기억';
	@override String get rememberScreenFitDesc => '선택한 크기를 이후에 여는 동영상에 적용합니다.';
	@override String get screenFitFit => '맞춤';
	@override String get screenFitFitDesc => '화면 비율을 유지하며 전체 프레임을 표시합니다';
	@override String get screenFitStretch => '늘이기';
	@override String get screenFitStretchDesc => '플레이어 영역을 채우며, 이미지가 왜곡될 수 있습니다';
	@override String get screenFitCover => '채우기';
	@override String get screenFitCoverDesc => '화면 비율을 유지하며 플레이어 영역을 채우고, 넘치는 부분은 잘라냅니다';
	@override String get screenFitRatioDesc => '이 화면 비율을 강제로 적용하며, 이미지가 왜곡될 수 있습니다';
	@override String get jumpLink => '링크 이동';
	@override String get language => '언어';
	@override String get languageNativeName => '한국어';
	@override String get followSystemLanguage => '시스템 언어 따르기';
	@override String get languageChangedMessage => '언어가 변경되었습니다. 일부 기능은 앱을 다시 시작해야 적용됩니다.';
	@override String get languageChanged => '언어 설정이 변경되었습니다. 적용하려면 앱을 다시 시작해 주세요.';
	@override late final _TranslationsSettingsKeybindingKo keybinding = _TranslationsSettingsKeybindingKo._(_root);
	@override String get gestureControl => '제스처 제어';
	@override String get leftDoubleTapRewind => '왼쪽 두 번 탭 되감기';
	@override String get rightDoubleTapFastForward => '오른쪽 두 번 탭 빨리 감기';
	@override String get doubleTapPause => '두 번 탭하여 일시정지';
	@override String get rightVerticalSwipeVolume => '오른쪽 세로 스와이프 볼륨 (새 페이지 진입 시 적용)';
	@override String get leftVerticalSwipeBrightness => '왼쪽 세로 스와이프 밝기 (새 페이지 진입 시 적용)';
	@override String get longPressFastForward => '길게 눌러 빨리 감기';
	@override String get enableMouseHoverShowToolbar => '마우스 오버 시 도구 모음 표시';
	@override String get enableMouseHoverShowToolbarInfo => '활성화하면 플레이어 위로 마우스를 올리면 동영상 도구 모음이 표시됩니다. 3초 동안 활동이 없으면 자동으로 숨겨집니다.';
	@override String get enableHorizontalDragSeek => '가로로 밀어 탐색';
	@override String get enableVideoGestureZoom => '핀치로 동영상 화면 확대';
	@override String get enableVideoGestureZoomInfo => '두 손가락으로 핀치(데스크톱에서는 Ctrl + 마우스 휠)하면 동영상 화면이 확대되며, 끌어서 이동할 수 있습니다.';
	@override String get showCenterPlayPauseButton => '중앙 재생/일시정지 버튼';
	@override String get showCenterPlayPauseButtonDesc => '플레이어 중앙에 큰 재생/일시정지 버튼을 표시합니다.';
	@override String get audioVideoConfig => '오디오·비디오 설정';
	@override String get expandBuffer => '버퍼 확장';
	@override String get expandBufferInfo => '활성화하면 버퍼 크기가 커져 로딩 시간은 길어지지만 재생이 더 부드러워집니다';
	@override String get videoSyncMode => '동영상 동기화 모드';
	@override String get videoSyncModeSubtitle => '오디오-비디오 동기화 전략';
	@override String get hardwareDecodingMode => '하드웨어 디코딩 모드';
	@override String get hardwareDecodingModeSubtitle => '하드웨어 디코딩 설정';
	@override String get enableHardwareAcceleration => '하드웨어 가속 사용';
	@override String get enableHardwareAccelerationInfo => '하드웨어 가속을 사용하면 디코딩 성능이 향상될 수 있지만 일부 기기는 호환되지 않을 수 있습니다';
	@override String get useOpenSLESAudioOutput => 'OpenSLES 오디오 출력 사용';
	@override String get useOpenSLESAudioOutputInfo => '저지연 오디오 출력을 사용하여 오디오 성능을 개선할 수 있습니다';
	@override String get videoSyncAudio => '오디오 동기화';
	@override String get videoSyncDisplayResample => '리샘플 표시';
	@override String get videoSyncDisplayResampleVdrop => '리샘플 표시 (프레임 드롭)';
	@override String get videoSyncDisplayResampleDesync => '리샘플 표시 (비동기화)';
	@override String get videoSyncDisplayTempo => '템포 표시';
	@override String get videoSyncDisplayVdrop => '동영상 프레임 드롭 표시';
	@override String get videoSyncDisplayAdrop => '오디오 프레임 드롭 표시';
	@override String get videoSyncDisplayDesync => '비동기화 표시';
	@override String get videoSyncDesync => '비동기화';
	@override late final _TranslationsSettingsForumSettingsKo forumSettings = _TranslationsSettingsForumSettingsKo._(_root);
	@override late final _TranslationsSettingsGallerySettingsKo gallerySettings = _TranslationsSettingsGallerySettingsKo._(_root);
	@override late final _TranslationsSettingsBlockSettingsKo blockSettings = _TranslationsSettingsBlockSettingsKo._(_root);
	@override late final _TranslationsSettingsChatSettingsKo chatSettings = _TranslationsSettingsChatSettingsKo._(_root);
	@override String get hardwareDecodingAuto => '자동';
	@override String get hardwareDecodingAutoCopy => '자동 복사';
	@override String get hardwareDecodingAutoSafe => '자동 안전';
	@override String get hardwareDecodingNo => '사용 안 함';
	@override String get hardwareDecodingYes => '강제 사용';
	@override String get cdnDistributionStrategy => '콘텐츠 배포 전략';
	@override String get cdnDistributionStrategyDesc => '동영상 소스 서버의 배포 전략을 선택하여 로딩 속도를 최적화합니다';
	@override String get cdnDistributionStrategyLabel => '배포 전략';
	@override String get cdnDistributionStrategyNoChange => '변경 안 함 (원본 서버 사용)';
	@override String get cdnDistributionStrategyAuto => '자동 선택 (가장 빠른 서버)';
	@override String get cdnDistributionStrategySpecial => '서버 지정';
	@override String get cdnSpecialServer => '서버 지정';
	@override String get cdnRefreshServerListHint => '아래 버튼을 눌러 서버 목록을 새로 고침하세요';
	@override String get cdnRefreshButton => '새로 고침';
	@override String get cdnFastRingServers => '패스트 링 서버';
	@override String get cdnRefreshServerListTooltip => '서버 목록 새로 고침';
	@override String get cdnSpeedTestButton => '속도 테스트';
	@override String cdnSpeedTestingButton({required Object count}) => '테스트 중 (${count})';
	@override String get cdnNoServerDataHint => '서버 데이터가 없습니다. 새로 고침 버튼을 눌러 주세요';
	@override String get cdnTestingStatus => '테스트 중';
	@override String get cdnUnreachableStatus => '연결할 수 없음';
	@override String get cdnNotTestedStatus => '테스트 안 됨';
	@override late final _TranslationsSettingsDownloadSettingsKo downloadSettings = _TranslationsSettingsDownloadSettingsKo._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsKo extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '즐겨찾기 태그';
	@override String get emptyIwara => '아직 즐겨찾기한 Iwara 태그가 없습니다';
	@override String get emptyOreno3d => '아직 즐겨찾기가 없습니다';
	@override String get addIwaraTag => 'Iwara 태그 추가';
	@override String get quickPickHint => '즐겨찾기한 항목은 검색에서 빠른 선택으로 표시됩니다.';
	@override String get pickerTitle => 'Oreno3D 선택';
	@override String get searchHint => '이름 또는 원본으로 검색';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n,
		one: '작품 ${n}개',
		other: '작품 ${n}개',
	);
	@override String get browseEntry => '원작 / 캐릭터 / 태그 찾아보기';
	@override String get favoritesSection => '즐겨찾기';
	@override String get addFavorite => '추가';
	@override String get iwaraTitle => '즐겨찾기 Iwara 태그';
	@override String get oreno3dTitle => '즐겨찾기 Oreno3D 태그';
	@override String get changeTag => '태그 변경';
	@override String get switchToText => '텍스트 검색';
}

// Path: oreno3d
class _TranslationsOreno3dKo extends TranslationsOreno3dEn {
	_TranslationsOreno3dKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => '태그';
	@override String get characters => '캐릭터';
	@override String get origin => '출처';
	@override String get thirdPartyTagsExplanation => '여기에 표시되는 **태그**, **캐릭터**, **출처** 정보는 서드파티 사이트 **Oreno3D**가 참고용으로 제공하는 것입니다.\n\n이 정보 출처는 일본어로만 제공되므로 현재 다국어 지원이 적용되어 있지 않습니다.\n\n다국어 지원에 기여하고 싶으시다면 리포지터리를 방문해 주세요.';
	@override late final _TranslationsOreno3dSortTypesKo sortTypes = _TranslationsOreno3dSortTypesKo._(_root);
	@override late final _TranslationsOreno3dErrorsKo errors = _TranslationsOreno3dErrorsKo._(_root);
	@override late final _TranslationsOreno3dLoadingKo loading = _TranslationsOreno3dLoadingKo._(_root);
	@override late final _TranslationsOreno3dMessagesKo messages = _TranslationsOreno3dMessagesKo._(_root);
}

// Path: signIn
class _TranslationsSignInKo extends TranslationsSignInEn {
	_TranslationsSignInKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => '먼저 로그인해 주세요';
	@override String get alreadySignedInToday => '오늘은 이미 출석했습니다!';
	@override String get youDidNotStickToTheSignIn => '출석을 이어가지 못했습니다.';
	@override String get signInSuccess => '출석 완료!';
	@override String get signInFailed => '출석에 실패했습니다. 나중에 다시 시도해 주세요';
	@override String get consecutiveSignIns => '연속 출석';
	@override String get failureReason => '실패 사유';
	@override String get selectDateRange => '날짜 범위 선택';
	@override String get startDate => '시작일';
	@override String get endDate => '종료일';
	@override String get invalidDate => '잘못된 날짜';
	@override String get invalidDateRange => '잘못된 날짜 범위';
	@override String get errorFormatText => '날짜 형식 오류';
	@override String get errorInvalidText => '잘못된 날짜 범위';
	@override String get errorInvalidRangeText => '잘못된 날짜 범위';
	@override String get dateRangeCantBeMoreThanOneYear => '날짜 범위는 1년을 초과할 수 없습니다';
	@override String get signIn => '출석';
	@override String get signInRecord => '출석 기록';
	@override String get totalSignIns => '총 출석';
	@override String get pleaseSelectSignInStatus => '출석 상태를 선택해 주세요';
}

// Path: subscriptions
class _TranslationsSubscriptionsKo extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => '구독 목록을 보려면 먼저 로그인해 주세요.';
	@override String get selectUser => '사용자 선택';
	@override String get noSubscribedUsers => '구독한 사용자가 없습니다';
	@override String get showAllSubscribedUsersContent => '구독한 사용자의 모든 콘텐츠 표시';
}

// Path: videoDetail
class _TranslationsVideoDetailKo extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'PiP 모드';
	@override String resumeFromLastPosition({required Object position}) => '마지막 위치에서 이어서 재생: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => '${position}에서 이어서 재생';
	@override String get restartFromBeginning => '처음부터 시작';
	@override String get dismissResumeTip => '닫기';
	@override late final _TranslationsVideoDetailLocalInfoKo localInfo = _TranslationsVideoDetailLocalInfoKo._(_root);
	@override String get videoIdIsEmpty => '동영상 ID가 비어 있습니다';
	@override String get videoInfoIsEmpty => '동영상 정보가 비어 있습니다';
	@override String get thisIsAPrivateVideo => '비공개 동영상입니다';
	@override String get getVideoInfoFailed => '동영상 정보를 가져오지 못했습니다. 나중에 다시 시도해 주세요';
	@override String get noVideoSourceFound => '동영상 소스를 찾을 수 없습니다';
	@override String tagCopiedToClipboard({required Object tagId}) => '태그 "${tagId}"이(가) 클립보드에 복사되었습니다';
	@override String get errorLoadingVideo => '동영상을 불러오는 중 오류';
	@override String get play => '재생';
	@override String get pause => '일시정지';
	@override String get exitAppFullscreen => '앱 전체 화면 종료';
	@override String get enterAppFullscreen => '앱 전체 화면 진입';
	@override String get exitSystemFullscreen => '시스템 전체 화면 종료';
	@override String get enterSystemFullscreen => '시스템 전체 화면 진입';
	@override String get seekTo => '이동';
	@override String get switchResolution => '해상도 전환';
	@override String get switchPlaybackSpeed => '재생 속도 전환';
	@override String rewindSeconds({required Object num}) => '${num}초 되감기';
	@override String fastForwardSeconds({required Object num}) => '${num}초 빨리 감기';
	@override String playbackSpeedIng({required Object rate}) => '${rate}x 속도로 재생 중';
	@override String get brightness => '밝기';
	@override String get brightnessLowest => '밝기가 최저입니다';
	@override String get volume => '볼륨';
	@override String get volumeMuted => '볼륨이 음소거되었습니다';
	@override String get restoreDefaultZoom => '복원';
	@override late final _TranslationsVideoDetailGestureGuideKo gestureGuide = _TranslationsVideoDetailGestureGuideKo._(_root);
	@override String get home => '홈';
	@override String get videoPlayer => '동영상 플레이어';
	@override String get videoPlayerInfo => '동영상 플레이어 정보';
	@override String get moreSettings => '더 많은 설정';
	@override String get videoPlayerFeatureInfo => '동영상 플레이어 기능 정보';
	@override String get autoRewind => '자동 되감기';
	@override String get rewindAndFastForward => '되감기 및 빨리 감기';
	@override String get volumeAndBrightness => '볼륨 및 밝기';
	@override String get centerAreaDoubleTapPauseOrPlay => '중앙 영역 두 번 탭 일시정지 또는 재생';
	@override String get showVerticalVideoInFullScreen => '전체 화면에서 세로 동영상 표시';
	@override String get keepLastVolumeAndBrightness => '마지막 볼륨과 밝기 유지';
	@override String get setProxy => '프록시 설정';
	@override String get moreFeaturesToBeDiscovered => '더 많은 기능이 숨어 있습니다...';
	@override String get videoPlayerSettings => '동영상 플레이어 설정';
	@override String commentCount({required Object num}) => '댓글 ${num}개';
	@override String get writeYourCommentHere => '여기에 댓글을 작성하세요...';
	@override String get authorOtherVideos => '작성자의 다른 동영상';
	@override String get relatedVideos => '관련 동영상';
	@override String get privateVideo => '비공개 동영상입니다';
	@override String get externalVideo => '외부 동영상입니다';
	@override String get openInBrowser => '브라우저에서 열기';
	@override String get resourceDeleted => '이 동영상은 삭제된 것 같습니다 :/';
	@override String get noDownloadUrl => '다운로드 URL이 없습니다';
	@override String get startDownloading => '다운로드 시작';
	@override String get downloadFailed => '다운로드에 실패했습니다. 나중에 다시 시도해 주세요';
	@override String get downloadSuccess => '다운로드 성공';
	@override String get download => '다운로드';
	@override String get downloadManager => '다운로드 관리자';
	@override String get resourceNotFound => '리소스를 찾을 수 없습니다';
	@override String get videoLoadError => '동영상 로드 오류';
	@override String get authorNoOtherVideos => '작성자의 다른 동영상이 없습니다';
	@override String get noRelatedVideos => '관련 동영상이 없습니다';
	@override late final _TranslationsVideoDetailPlayerKo player = _TranslationsVideoDetailPlayerKo._(_root);
	@override late final _TranslationsVideoDetailSkeletonKo skeleton = _TranslationsVideoDetailSkeletonKo._(_root);
	@override late final _TranslationsVideoDetailCastKo cast = _TranslationsVideoDetailCastKo._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsKo likeAvatars = _TranslationsVideoDetailLikeAvatarsKo._(_root);
}

// Path: share
class _TranslationsShareKo extends TranslationsShareEn {
	_TranslationsShareKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => '재생목록 공유';
	@override String get wowDidYouSeeThis => '와, 이거 보셨어요?';
	@override String get nameIs => '이름:';
	@override String get clickLinkToView => '링크를 클릭하여 보기';
	@override String get iReallyLikeThis => '이거 정말 좋아요';
	@override String get shareFailed => '공유에 실패했습니다. 나중에 다시 시도해 주세요';
	@override String get share => '공유';
	@override String get shareAsImage => '이미지로 공유';
	@override String get shareAsText => '텍스트로 공유';
	@override String get shareAsImageDesc => '동영상 커버를 이미지로 공유합니다';
	@override String get shareAsTextDesc => '동영상 세부 정보를 텍스트로 공유합니다';
	@override String get shareAsImageFailed => '동영상 커버를 이미지로 공유하지 못했습니다. 나중에 다시 시도해 주세요';
	@override String get shareAsTextFailed => '동영상 세부 정보를 텍스트로 공유하지 못했습니다. 나중에 다시 시도해 주세요';
	@override String get shareVideo => '동영상 공유';
	@override String get authorIs => '작성자:';
	@override String get shareGallery => '갤러리 공유';
	@override String get galleryTitleIs => '갤러리 제목:';
	@override String get galleryAuthorIs => '갤러리 작성자:';
	@override String get shareUser => '사용자 공유';
	@override String get userNameIs => '사용자 이름:';
	@override String get userAuthorIs => '사용자 작성자:';
	@override String get comments => '댓글';
	@override String get shareThread => '스레드 공유';
	@override String get views => '조회수';
	@override String get sharePost => '게시물 공유';
	@override String get postTitleIs => '게시물 제목:';
	@override String get postAuthorIs => '게시물 작성자:';
}

// Path: markdown
class _TranslationsMarkdownKo extends TranslationsMarkdownEn {
	_TranslationsMarkdownKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Markdown 문법';
	@override String get iwaraSpecialMarkdownSyntax => 'Iwara 전용 Markdown 문법';
	@override String get internalLink => '내부 링크';
	@override String get supportAutoConvertLinkBelow => '다음 링크의 자동 변환을 지원합니다:';
	@override String get convertLinkExample => '🎬 동영상 링크\n🖼️ 이미지 링크\n👤 사용자 링크\n📌 포럼 링크\n🎵 재생목록 링크\n💬 스레드 링크';
	@override String get mentionUser => '사용자 멘션';
	@override String get mentionUserDescription => '@ 뒤에 사용자 이름을 입력하면 자동으로 사용자 링크로 변환됩니다';
	@override String get markdownBasicSyntax => 'Markdown 기본 문법';
	@override String get paragraphAndLineBreak => '문단과 줄 바꿈';
	@override String get paragraphAndLineBreakDescription => '문단은 빈 줄로 구분되며, 줄 끝의 공백 두 칸은 줄 바꿈으로 변환됩니다';
	@override String get paragraphAndLineBreakSyntax => '첫 번째 문단입니다\n\n두 번째 문단입니다\n이 줄은 공백 두 칸으로 끝나며  \n줄 바꿈으로 변환됩니다';
	@override String get textStyle => '텍스트 스타일';
	@override String get textStyleDescription => '특수 기호로 텍스트를 감싸 스타일을 변경합니다';
	@override String get textStyleSyntax => '**굵은 텍스트**\n*기울임 텍스트*\n~~취소선 텍스트~~\n`코드 텍스트`';
	@override String get quote => '인용';
	@override String get quoteDescription => '> 기호로 인용을 만들고, >>로 여러 단계 인용을 만듭니다';
	@override String get quoteSyntax => '> 1단계 인용입니다\n>> 2단계 인용입니다';
	@override String get list => '목록';
	@override String get listDescription => '숫자+마침표로 순서 있는 목록을, -로 순서 없는 목록을 만듭니다';
	@override String get listSyntax => '1. 첫 번째 항목\n2. 두 번째 항목\n\n- 순서 없는 항목\n  - 하위 항목\n  - 또 다른 하위 항목';
	@override String get linkAndImage => '링크와 이미지';
	@override String get linkAndImageDescription => '링크 형식: [텍스트](URL)\n이미지 형식: ![설명](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[링크 텍스트](${link})\n![이미지 설명](${imgUrl})';
	@override String get title => '제목';
	@override String get titleDescription => '# 기호로 제목을 만들고, 개수로 수준을 표시합니다';
	@override String get titleSyntax => '# 1단계 제목\n## 2단계 제목\n### 3단계 제목';
	@override String get separator => '구분선';
	@override String get separatorDescription => '하이픈 세 개 이상으로 구분선을 만듭니다';
	@override String get separatorSyntax => '---';
	@override String get syntax => '문법';
}

// Path: forum
class _TranslationsForumKo extends TranslationsForumEn {
	_TranslationsForumKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get recent => '최근';
	@override String get category => '카테고리';
	@override String get lastReply => '마지막 답글';
	@override late final _TranslationsForumSitewideKo sitewide = _TranslationsForumSitewideKo._(_root);
	@override late final _TranslationsForumErrorsKo errors = _TranslationsForumErrorsKo._(_root);
	@override String get createPost => '게시물 작성';
	@override String get title => '제목';
	@override String get enterTitle => '제목 입력';
	@override String get content => '콘텐츠';
	@override String get enterContent => '내용 입력';
	@override String get writeYourContentHere => '여기에 내용을 작성하세요...';
	@override String get posts => '게시물';
	@override String get threads => '스레드';
	@override String get forum => '포럼';
	@override String get createThread => '스레드 만들기';
	@override String get selectCategory => '카테고리 선택';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => '남은 대기 시간 ${minutes}분 ${seconds}초';
	@override late final _TranslationsForumGroupsKo groups = _TranslationsForumGroupsKo._(_root);
	@override late final _TranslationsForumLeafNamesKo leafNames = _TranslationsForumLeafNamesKo._(_root);
	@override late final _TranslationsForumLeafDescriptionsKo leafDescriptions = _TranslationsForumLeafDescriptionsKo._(_root);
	@override String get reply => '답글';
	@override String get pendingReview => '검토 대기 중';
	@override String get editedAt => '수정일';
	@override String get copySuccess => '클립보드에 복사되었습니다';
	@override String copySuccessForMessage({required Object str}) => '클립보드에 복사됨: ${str}';
	@override String get editReply => '답글 편집';
	@override String get editTitle => '제목 편집';
	@override String get submit => '제출';
}

// Path: notifications
class _TranslationsNotificationsKo extends TranslationsNotificationsEn {
	_TranslationsNotificationsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsKo errors = _TranslationsNotificationsErrorsKo._(_root);
	@override String get notifications => '알림';
	@override String get profile => '프로필';
	@override String get postedNewComment => '새 댓글을 게시했습니다';
	@override String get inYour => '회원님의';
	@override String get video => '동영상';
	@override String get repliedYourVideoComment => '회원님의 동영상 댓글에 답글을 남겼습니다';
	@override String get copyInfoToClipboard => '알림 정보를 클립보드에 복사';
	@override String get copySuccess => '클립보드에 복사되었습니다';
	@override String copySuccessForMessage({required Object str}) => '클립보드에 복사되었습니다: ${str}';
	@override String get markAllAsRead => '모두 읽음으로 표시';
	@override String get markAllAsReadSuccess => '모든 알림을 읽음으로 표시했습니다';
	@override String get markAllAsReadFailed => '모두 읽음으로 표시하지 못했습니다';
	@override String get markSelectedAsRead => '선택 항목 읽음으로 표시';
	@override String get markSelectedAsReadSuccess => '선택한 알림을 읽음으로 표시했습니다';
	@override String get markSelectedAsReadFailed => '선택 항목을 읽음으로 표시하지 못했습니다';
	@override String get markAsRead => '읽음으로 표시';
	@override String get markAsReadSuccess => '알림을 읽음으로 표시했습니다';
	@override String get markAsReadFailed => '알림을 읽음으로 표시하지 못했습니다';
	@override String get notificationTypeHelp => '알림 유형 도움말';
	@override String get dueToLackOfNotificationTypeDetails => '알림 유형 정보가 부족하여 지원되는 유형이 현재 수신하는 메시지를 모두 포함하지 못할 수 있습니다';
	@override String get helpUsImproveNotificationTypeSupport => '알림 유형 지원 개선에 도움을 주시겠습니까';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 알림 정보를 복사합니다\n2. 🐞 프로젝트 리포지토리에 이슈를 제출합니다\n\n⚠️ 참고: 알림 정보에는 개인 정보가 포함될 수 있으므로 공개를 원하지 않으시면 프로젝트 작성자에게 이메일로 보내주셔도 됩니다.';
	@override String get goToRepository => '리포지토리로 이동';
	@override String get copy => '복사';
	@override String get commentApproved => '댓글 승인됨';
	@override String get repliedYourProfileComment => '회원님의 프로필 댓글에 답글을 남겼습니다';
	@override String get kReplied => '회원님의 댓글에 답글을 남겼습니다';
	@override String get kCommented => '회원님의 항목에 댓글을 남겼습니다';
	@override String get kVideo => '동영상';
	@override String get kGallery => '갤러리';
	@override String get kProfile => '프로필';
	@override String get kThread => '스레드';
	@override String get kPost => '게시물';
	@override String get kCommentSection => '댓글';
	@override String get kApprovedComment => '댓글 승인됨';
	@override String get kApprovedVideo => '동영상 승인됨';
	@override String get kApprovedGallery => '갤러리 승인됨';
	@override String get kApprovedThread => '스레드 승인됨';
	@override String get kApprovedPost => '게시물 승인됨';
	@override String get kApprovedForumPost => '포럼 게시물 승인됨';
	@override String get kRejectedContent => '콘텐츠 검토가 거부되었습니다';
	@override String get kUnknownType => '알 수 없는 알림 유형';
}

// Path: conversation
class _TranslationsConversationKo extends TranslationsConversationEn {
	_TranslationsConversationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsKo errors = _TranslationsConversationErrorsKo._(_root);
	@override String get conversation => '대화';
	@override String get startConversation => '대화 시작';
	@override String get noConversation => '대화 없음';
	@override String get selectFromLeftListAndStartConversation => '왼쪽 목록에서 선택하여 대화를 시작하세요';
	@override String get title => '제목';
	@override String get body => '본문';
	@override String get selectAUser => '사용자 선택';
	@override String get searchUsers => '사용자 검색...';
	@override String get tmpNoConversions => '변환 없음';
	@override String get deleteThisMessage => '이 메시지 삭제';
	@override String get deleteThisMessageSubtitle => '이 작업은 되돌릴 수 없습니다';
	@override String get writeMessageHere => '여기에 메시지를 작성하세요...';
	@override String get lastMessageFromMe => '나: ';
	@override String get sendMessage => '메시지 보내기';
}

// Path: splash
class _TranslationsSplashKo extends TranslationsSplashEn {
	_TranslationsSplashKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsKo errors = _TranslationsSplashErrorsKo._(_root);
	@override String get preparing => '준비 중...';
	@override String get initializing => '초기화 중...';
	@override String get loading => '로딩 중...';
	@override String get ready => '준비 완료';
	@override String get initializingMessageService => '메시지 서비스 초기화 중...';
}

// Path: download
class _TranslationsDownloadKo extends TranslationsDownloadEn {
	_TranslationsDownloadKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsKo errors = _TranslationsDownloadErrorsKo._(_root);
	@override String get downloadList => '다운로드 목록';
	@override String get viewDownloadList => '다운로드 목록 보기';
	@override String get download => '다운로드';
	@override String get selectDownloadTitle => '다운로드 선택';
	@override String get qualitySectionLabel => '화질';
	@override String get categorySectionLabel => '분류';
	@override String get saveToPreviewLabel => '저장될 위치';
	@override String saveToPreviewSuggested({required Object name}) => '추천 파일 이름: ${name}(시스템 대화상자에서 변경 가능)';
	@override String get lastUsedBadge => '최근 사용';
	@override String get pickedBadge => '선택됨';
	@override String get startDownloading => '다운로드 시작';
	@override String get clearAllFailedTasks => '실패한 작업 모두 지우기';
	@override String get clearAllFailedTasksConfirmation => '실패한 다운로드 작업을 모두 지우시겠습니까? 해당 작업의 파일도 함께 삭제됩니다.';
	@override String get clearAllFailedTasksSuccess => '실패한 작업을 모두 지웠습니다';
	@override String get clearAllFailedTasksError => '실패한 작업을 지우는 중 오류가 발생했습니다';
	@override String get downloadStatus => '다운로드 상태';
	@override String get imageList => '이미지 목록';
	@override String get retryDownload => '다운로드 재시도';
	@override String get notDownloaded => '다운로드 안 함';
	@override String get downloaded => '다운로드됨';
	@override String get waitingForDownload => '다운로드 대기 중';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '다운로드 중(${downloaded}/${total} 이미지 ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => '다운로드 중(${downloaded}개 이미지)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => '일시정지됨(${downloaded}/${total} 이미지 ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => '일시정지됨(${downloaded}개 이미지)';
	@override String downloadedProgressForImageProgress({required Object total}) => '다운로드 완료(총 ${total}개 이미지)';
	@override String get viewVideoDetail => '동영상 상세 보기';
	@override String get viewGalleryDetail => '갤러리 상세 보기';
	@override String get moreOptions => '더 많은 옵션';
	@override String get openFile => '파일 열기';
	@override String get playLocally => '로컬 재생';
	@override String get pause => '일시정지';
	@override String get resume => '재개';
	@override String get copyDownloadUrl => '다운로드 URL 복사';
	@override String get showInFolder => '폴더에서 보기';
	@override String get deleteTask => '작업 삭제';
	@override String get deleteTaskConfirmation => '이 다운로드 작업을 삭제하시겠습니까?\n작업 파일도 함께 삭제됩니다.';
	@override String get forceDeleteTask => '작업 강제 삭제';
	@override String get forceDeleteTaskConfirmation => '이 다운로드 작업을 강제 삭제하시겠습니까?\n파일이 사용 중이더라도 작업 파일이 삭제됩니다.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => '다운로드 중 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => '다운로드 중 ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => '일시정지됨 ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => '일시정지됨 • 다운로드됨 ${downloaded}';
	@override String downloadedWithSize({required Object size}) => '다운로드됨 • ${size}';
	@override String get copyDownloadUrlSuccess => '다운로드 URL이 복사되었습니다';
	@override String totalImageNums({required Object num}) => '이미지 ${num}개';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => '다운로드 중 ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => '다운로드 중';
	@override String get failed => '실패';
	@override String get completed => '완료됨';
	@override String get downloadDetail => '다운로드 상세';
	@override String get copy => '복사';
	@override String get copySuccess => '복사됨';
	@override String get waiting => '대기 중';
	@override String get paused => '일시정지됨';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => '다운로드 중 ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => '갤러리 다운로드 완료: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => '다운로드 완료: ${fileName}';
	@override String get searchTasks => '작업 검색...';
	@override String statusLabel({required Object label}) => '상태: ${label}';
	@override String get allStatus => '모든 상태';
	@override String typeLabel({required Object label}) => '유형: ${label}';
	@override String get allTypes => '모든 유형';
	@override String get taskType => '유형';
	@override String get video => '동영상';
	@override String get gallery => '갤러리';
	@override String get other => '기타';
	@override String get clearFilters => '필터 지우기';
	@override String get pauseAll => '모두 일시정지';
	@override String get resumeAll => '모두 시작';
	@override String remainingTime({required Object time}) => '${time} 남음';
	@override late final _TranslationsDownloadTimelineKo timeline = _TranslationsDownloadTimelineKo._(_root);
	@override late final _TranslationsDownloadErrorTypesKo errorTypes = _TranslationsDownloadErrorTypesKo._(_root);
	@override String get errorDetailCopied => '오류 세부 정보가 복사되었습니다';
	@override String get errorDetailCopyHint => '길게 눌러 오류 세부 정보 복사';
	@override late final _TranslationsDownloadRestoredPausedKo restoredPaused = _TranslationsDownloadRestoredPausedKo._(_root);
	@override late final _TranslationsDownloadActionsKo actions = _TranslationsDownloadActionsKo._(_root);
	@override late final _TranslationsDownloadNoticeKo notice = _TranslationsDownloadNoticeKo._(_root);
	@override String get emptyTaskList => '아직 다운로드 작업이 없습니다';
	@override String get noMatchingTasks => '일치하는 작업이 없습니다';
	@override late final _TranslationsDownloadDeleteByDateKo deleteByDate = _TranslationsDownloadDeleteByDateKo._(_root);
	@override late final _TranslationsDownloadRelocationKo relocation = _TranslationsDownloadRelocationKo._(_root);
	@override late final _TranslationsDownloadCategoryKo category = _TranslationsDownloadCategoryKo._(_root);
	@override late final _TranslationsDownloadLocationKo location = _TranslationsDownloadLocationKo._(_root);
	@override String get maxConcurrentDownloads => '최대 동시 다운로드 수';
	@override String get maxConcurrentDownloadsDesc => '동시에 다운로드하는 작업 수(1-5)';
	@override String get stillInDevelopment => '아직 개발 중';
	@override String get saveToAppDirectory => '앱 디렉터리에 저장';
	@override String get alreadyDownloadedWithQuality => '이미 같은 화질로 다운로드되었습니다. 계속 다운로드하시겠습니까?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => '이미 다음 화질로 다운로드됨: ${qualities}, 계속 다운로드하시겠습니까?';
	@override String get otherQualities => '기타 화질';
	@override late final _TranslationsDownloadBatchDownloadKo batchDownload = _TranslationsDownloadBatchDownloadKo._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsKo extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => '다운로드 완료';
	@override String get failedTitle => '다운로드 실패';
	@override String completedBody({required Object name}) => '${name} 다운로드 성공';
	@override String failedBody({required Object name}) => '${name} 다운로드 실패';
	@override String completedToast({required Object name}) => '${name} 다운로드됨';
	@override String failedToast({required Object name}) => '${name} 다운로드 실패';
	@override String savedToFolder({required Object dir}) => '${dir}에 저장됨';
	@override String savedAsRenamed({required Object name}) => '${name}(으)로 저장됨(같은 이름의 파일이 이미 있음)';
	@override String savedToAppFolder({required Object target, required Object reason}) => '앱 폴더에 저장됨 — ${target}에 쓸 수 없음(${reason})';
	@override String get viewFolder => '폴더 보기';
	@override String get fixInSettings => '설정에서 수정';
	@override String get channelName => '다운로드 상태';
	@override String get channelDescription => '완료 및 실패한 다운로드 알림';
}

// Path: favorite
class _TranslationsFavoriteKo extends TranslationsFavoriteEn {
	_TranslationsFavoriteKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsKo errors = _TranslationsFavoriteErrorsKo._(_root);
	@override String get add => '추가';
	@override String get addSuccess => '추가 성공';
	@override String get addFailed => '추가 실패';
	@override String get remove => '제거';
	@override String get removeSuccess => '제거 성공';
	@override String get removeFailed => '제거 실패';
	@override String get removeConfirmation => '이 항목을 즐겨찾기에서 제거하시겠습니까?';
	@override String get removeConfirmationSuccess => '즐겨찾기에서 항목을 제거했습니다';
	@override String get removeConfirmationFailed => '즐겨찾기에서 항목을 제거하지 못했습니다';
	@override String get createFolderSuccess => '폴더를 만들었습니다';
	@override String get createFolderFailed => '폴더를 만들지 못했습니다';
	@override String get createFolder => '폴더 만들기';
	@override String get enterFolderName => '폴더 이름 입력';
	@override String get enterFolderNameHere => '여기에 폴더 이름을 입력하세요...';
	@override String get create => '만들기';
	@override String get items => '항목';
	@override String get newFolderName => '새 폴더';
	@override String get searchFolders => '폴더 검색...';
	@override String get searchItems => '항목 검색...';
	@override String get createdAt => '생성일';
	@override String get myFavorites => '내 즐겨찾기';
	@override String get deleteFolderTitle => '폴더 삭제';
	@override String deleteFolderConfirmWithTitle({required Object title}) => '${title} 폴더를 삭제하시겠습니까?';
	@override String get removeItemTitle => '항목 제거';
	@override String removeItemConfirmWithTitle({required Object title}) => '${title} 항목을 삭제하시겠습니까?';
	@override String get removeItemSuccess => '즐겨찾기에서 항목을 제거했습니다';
	@override String get removeItemFailed => '즐겨찾기에서 항목을 제거하지 못했습니다';
	@override String get localizeFavorite => '로컬 즐겨찾기';
	@override String get editFolderTitle => '폴더 편집';
	@override String get editFolderSuccess => '폴더를 업데이트했습니다';
	@override String get editFolderFailed => '폴더를 업데이트하지 못했습니다';
	@override String get searchTags => '태그 검색';
	@override String get noTagsInFolder => '이 폴더의 항목에 아직 태그가 없습니다';
	@override String get tagFilterMatchAll => '선택한 모든 태그를 가진 항목만 표시';
	@override String get clearSelectedTags => '선택한 태그 지우기';
	@override String selectedTagCount({required Object count}) => '${count}개 선택됨';
	@override String get noMatchingTags => '일치하는 태그가 없습니다';
}

// Path: translation
class _TranslationsTranslationKo extends TranslationsTranslationEn {
	_TranslationsTranslationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get currentService => '현재 서비스';
	@override String get testConnection => '연결 테스트';
	@override String get testConnectionSuccess => '연결 테스트 성공';
	@override String get testConnectionFailed => '연결 테스트에 실패했습니다';
	@override String testConnectionFailedWithMessage({required Object message}) => '연결 테스트 실패: ${message}';
	@override String get translation => '번역';
	@override String get needVerification => '확인 필요';
	@override String get needVerificationContent => 'AI 번역을 활성화하기 전에 먼저 연결을 테스트해 주세요';
	@override String get confirm => '확인';
	@override String get disclaimer => '면책 조항';
	@override String get riskWarning => '위험 경고';
	@override String get dureToRisk1 => '사용자가 생성한 텍스트이므로 AI 서비스 제공자의 콘텐츠 정책을 위반하는 내용이 포함될 수 있습니다';
	@override String get dureToRisk2 => '부적절한 콘텐츠는 API 키 정지나 서비스 종료로 이어질 수 있습니다';
	@override String get operationSuggestion => '작업 제안';
	@override String get operationSuggestion1 => '1. 번역할 내용을 엄격히 검토하기 전에 사용하세요';
	@override String get operationSuggestion2 => '2. 폭력, 성인 콘텐츠 등이 포함된 내용은 번역하지 마세요';
	@override String get apiConfig => 'API 설정';
	@override String get modifyConfigWillAutoCloseAITranslation => '설정을 수정하면 AI 번역이 자동으로 꺼집니다. 켠 후 다시 테스트해야 합니다';
	@override String get apiAddress => 'API 주소';
	@override String get modelName => '모델 이름';
	@override String get modelNameHintText => '예: gpt-4-turbo';
	@override String get maxTokens => '최대 토큰';
	@override String get maxTokensHintText => '예: 32000';
	@override String get temperature => '온도';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => '테스트 버튼을 클릭하여 API 연결 유효성을 확인하세요';
	@override String get requestPreview => '요청 미리보기';
	@override String get enableAITranslation => 'AI 사용';
	@override String get enabled => '사용';
	@override String get disabled => '사용 안 함';
	@override String get testing => '테스트 중...';
	@override String get testNow => '지금 테스트';
	@override String get connectionStatus => '연결 상태';
	@override String get success => '성공';
	@override String get failed => '실패';
	@override String get information => '정보';
	@override String get viewRawResponse => '원시 응답 보기';
	@override String get pleaseCheckInputParametersFormat => '입력 매개변수 형식을 확인해 주세요';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'API 주소, 모델 이름, 키를 입력해 주세요';
	@override String get pleaseFillInValidConfigurationParameters => '유효한 설정 매개변수를 입력해 주세요';
	@override String get pleaseCompleteConnectionTest => '연결 테스트를 완료해 주세요';
	@override String get notConfigured => '설정되지 않음';
	@override String get apiEndpoint => 'API 엔드포인트';
	@override String get configuredKey => '설정된 키';
	@override String get notConfiguredKey => '설정되지 않은 키';
	@override String get authenticationStatus => '인증 상태';
	@override String get thisFieldCannotBeEmpty => '이 필드는 비워 둘 수 없습니다';
	@override String get apiKey => 'API 키';
	@override String get apiKeyCannotBeEmpty => 'API 키는 비워 둘 수 없습니다';
	@override String get pleaseEnterValidNumber => '유효한 숫자를 입력하세요';
	@override String get range => '범위';
	@override String get mustBeGreaterThan => '다음보다 커야 합니다';
	@override String get invalidAPIResponse => '잘못된 API 응답';
	@override String connectionFailedForMessage({required Object message}) => '연결 실패: ${message}';
	@override String get aiTranslationNotEnabledHint => 'AI 번역이 활성화되지 않았습니다. 설정에서 활성화해 주세요';
	@override String get goToSettings => '설정으로 이동';
	@override String get disableAITranslation => 'AI 번역 비활성화';
	@override String get currentValue => '현재 값';
	@override String get configureTranslationStrategy => '번역 전략 구성';
	@override String get advancedSettings => '고급 설정';
	@override String get translationPrompt => '번역 프롬프트';
	@override String get promptHint => '번역 프롬프트를 입력하고, 대상 언어의 자리 표시자로 [TL]을 사용하세요';
	@override String get promptHelperText => '프롬프트에는 대상 언어의 자리 표시자로 [TL]이 포함되어야 합니다';
	@override String get promptMustContainTargetLang => '프롬프트에 [TL] 자리 표시자가 있어야 합니다';
	@override String get aiTranslationWillBeDisabled => 'AI 번역이 비활성화됩니다';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => '기본 설정이 변경되어 AI 번역이 비활성화됩니다';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => '번역 프롬프트가 변경되어 AI 번역이 비활성화됩니다';
	@override String get aiTranslationWillBeDisabledDueToParamChange => '매개변수 설정이 변경되어 AI 번역이 비활성화됩니다';
	@override String get onlyOpenAIAPISupported => '현재 OpenAI 호환 API 형식(application/json 요청 본문)만 지원합니다';
	@override String get streamingTranslation => '스트리밍 번역';
	@override String get streamingTranslationSupported => '스트리밍 번역 지원됨';
	@override String get streamingTranslationNotSupported => '스트리밍 번역 지원 안 됨';
	@override String get streamingTranslationDescription => '스트리밍 번역은 번역 과정에서 결과를 실시간으로 표시하여 더 나은 사용자 경험을 제공합니다';
	@override String get usingFullUrlWithHash => '전체 URL 사용 (#으로 끝남)';
	@override String get baseUrlInputHelperText => '#으로 끝나면 실제 요청 주소로 사용됩니다';
	@override String currentActualUrl({required Object url}) => '현재 실제 URL: ${url}';
	@override String get urlEndingWithHashTip => '#으로 끝나는 URL은 아무 접미사도 추가하지 않고 그대로 사용됩니다';
	@override String get streamingTranslationWarning => '참고: 이 기능은 API 서비스의 스트리밍 전송 지원이 필요하며 일부 모델은 지원하지 않을 수 있습니다';
	@override String get translationService => '번역 서비스';
	@override String get translationServiceDescription => '사용할 번역 서비스를 선택하세요';
	@override String get googleTranslation => 'Google 번역';
	@override String get googleTranslationDescription => '여러 언어를 지원하는 무료 온라인 번역 서비스';
	@override String get aiTranslation => 'AI 번역';
	@override String get aiTranslationDescription => '대규모 언어 모델 기반 지능형 번역 서비스';
	@override String get deeplxTranslation => 'DeepLX 번역';
	@override String get deeplxTranslationDescription => '고품질 번역을 제공하는 DeepL 번역의 오픈 소스 구현';
	@override String get googleTranslationFeatures => '기능';
	@override String get freeToUse => '무료로 사용';
	@override String get freeToUseDescription => '설정이 필요 없으며 바로 사용할 수 있습니다';
	@override String get fastResponse => '빠른 응답';
	@override String get fastResponseDescription => '낮은 지연으로 빠른 번역 속도';
	@override String get stableAndReliable => '안정적이고 신뢰할 수 있음';
	@override String get stableAndReliableDescription => 'Google 공식 API 기반';
	@override String get enabledDefaultService => '사용 - 기본 번역 서비스';
	@override String get notEnabled => '사용 안 함';
	@override String get deeplxTranslationService => 'DeepLX 번역 서비스';
	@override String get deeplxDescription => 'DeepLX는 DeepL 번역의 오픈 소스 구현으로 Free, Pro 및 Official 엔드포인트 모드를 지원합니다';
	@override String get serverAddress => '서버 주소';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'DeepLX 서버의 기본 주소';
	@override String get endpointType => '엔드포인트 유형';
	@override String get freeEndpoint => 'Free - 무료 엔드포인트, 속도 제한이 있을 수 있습니다';
	@override String get proEndpoint => 'Pro - dl_session 필요, 더 안정적';
	@override String get officialEndpoint => 'Official - 공식 API 형식';
	@override String get finalRequestUrl => '최종 요청 URL';
	@override String get apiKeyOptional => 'API 키 (선택)';
	@override String get apiKeyOptionalHint => '보호된 DeepLX 서비스에 접근할 때 사용합니다';
	@override String get apiKeyOptionalHelperText => '일부 DeepLX 서비스는 인증을 위해 API 키가 필요합니다';
	@override String get dlSession => 'DL 세션';
	@override String get dlSessionHint => 'Pro 모드에 필요한 dl_session 매개변수';
	@override String get dlSessionHelperText => 'Pro 엔드포인트에 필요한 세션 매개변수로, DeepL Pro 계정에서 가져옵니다';
	@override String get proModeRequiresDlSession => 'Pro 모드는 dl_session이 필요합니다';
	@override String get clickTestButtonToVerifyDeepLXAPI => '테스트 버튼을 클릭하여 DeepLX API 연결을 확인하세요';
	@override String get enableDeepLXTranslation => 'DeepLX 번역 사용';
	@override String get deepLXTranslationWillBeDisabled => '설정 변경으로 인해 DeepLX 번역이 비활성화됩니다';
	@override String get translatedResult => '번역 결과';
	@override String get testSuccess => '테스트 성공';
	@override String get pleaseFillInDeepLXServerAddress => 'DeepLX 서버 주소를 입력해 주세요';
	@override String get invalidAPIResponseFormat => '잘못된 API 응답 형식';
	@override String get translationServiceReturnedError => '번역 서비스가 오류 또는 빈 결과를 반환했습니다';
	@override String get connectionFailed => '연결 실패';
	@override String get translationFailed => '번역에 실패했습니다';
	@override String get aiTranslationFailed => 'AI 번역에 실패했습니다';
	@override String get deeplxTranslationFailed => 'DeepLX 번역에 실패했습니다';
	@override String get aiTranslationTestFailed => 'AI 번역 테스트에 실패했습니다';
	@override String get deeplxTranslationTestFailed => 'DeepLX 번역 테스트에 실패했습니다';
	@override String get streamingTranslationTimeout => '스트리밍 번역 시간 초과, 리소스 강제 정리';
	@override String get translationRequestTimeout => '번역 요청 시간 초과';
	@override String get streamingTranslationDataTimeout => '스트리밍 번역 데이터 수신 시간 초과';
	@override String get dataReceptionTimeout => '데이터 수신 시간 초과';
	@override String get streamDataParseError => '스트림 데이터 구문 분석 오류';
	@override String get streamingTranslationFailed => '스트리밍 번역에 실패했습니다';
	@override String get fallbackTranslationFailed => '일반 번역으로의 대체도 실패했습니다';
	@override String get translationSettings => '번역 설정';
	@override String get enableGoogleTranslation => 'Google 번역 사용';
	@override String get thinking => '생각 중...';
	@override String get thoughtProcess => '사고 과정';
	@override String get modelCompatibility => '모델 호환성';
	@override String get modelCompatibilityDescription => '추론 모델(o1/o3, DeepSeek-R1, QwQ) 등 최신 모델에 맞게 요청 매개변수를 조정합니다';
	@override String get reasoningModel => '추론 모델';
	@override String get reasoningModelDescription => 'o1/o3, DeepSeek-R1, QwQ 등에 사용합니다. 프롬프트를 사용자 메시지에 합치고, 온도를 생략하며, max_completion_tokens를 사용합니다';
	@override String get useMaxCompletionTokens => 'max_completion_tokens 사용';
	@override String get useMaxCompletionTokensDescription => '최신 OpenAI 엔드포인트는 더 이상 사용되지 않는 max_tokens 대신 max_completion_tokens를 요구합니다';
	@override String get sendTemperature => '온도 전송';
	@override String get sendTemperatureDescription => '온도 매개변수를 거부하는 모델(대부분의 추론 모델)의 경우 끄세요';
	@override String get showReasoningProcess => '사고 과정 표시';
	@override String get showReasoningProcessDescription => '번역 대화 상자에서 추론 모델의 접을 수 있는 추론 과정을 표시합니다';
	@override String get provider => '제공자';
	@override String get providerOpenAI => 'OpenAI (및 호환)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'dartantic_ai SDK를 통해 OpenAI(및 모든 OpenAI 호환 엔드포인트), Anthropic, Google을 지원합니다';
	@override String get baseUrlOptionalHelperText => '선택 사항입니다. 비워 두면 제공자의 기본 엔드포인트를 사용하며, OpenAI 호환/중계 엔드포인트에는 입력하세요';
	@override String get defaultEndpoint => '기본 엔드포인트';
	@override String get providerPreset => '제공자 프리셋';
	@override String get selectProviderPreset => '프리셋 선택';
	@override String get presetCustom => '사용자 지정';
	@override String presetApplied({required Object name}) => '프리셋 적용됨: ${name}';
	@override late final _TranslationsTranslationPresetNamesKo presetNames = _TranslationsTranslationPresetNamesKo._(_root);
	@override String get fetchModelList => '모델 목록 가져오기';
	@override String get fetchingModels => '가져오는 중...';
	@override String get selectModel => '모델 선택';
	@override String get searchModel => '모델 검색';
	@override String get noModelsFound => '모델을 찾을 수 없습니다';
}

// Path: bottomNav
class _TranslationsBottomNavKo extends TranslationsBottomNavEn {
	_TranslationsBottomNavKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get video => '동영상';
	@override String get gallery => '갤러리';
	@override String get subscription => '피드';
	@override String get community => '포럼';
	@override String get localMedia => '로컬';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsKo extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '내비게이션 순서 설정';
	@override String get customNavigationOrder => '내비게이션 순서 사용자 지정';
	@override String get customNavigationOrderDesc => '하단 내비게이션 바와 사이드바에서 페이지 표시 순서를 조정하려면 드래그하세요';
	@override String get restartRequired => '앱 재시작 필요';
	@override String get navigationItemSorting => '내비게이션 항목 정렬';
	@override String get done => '완료';
	@override String get edit => '편집';
	@override String get reset => '초기화';
	@override String get previewEffect => '미리보기 효과';
	@override String get bottomNavigationPreview => '하단 내비게이션 미리보기:';
	@override String get sidebarPreview => '사이드바 미리보기:';
	@override String get confirmResetNavigationOrder => '내비게이션 순서 초기화 확인';
	@override String get confirmResetNavigationOrderDesc => '내비게이션 순서를 기본 설정으로 초기화하시겠습니까?';
	@override String get cancel => '취소';
	@override String get show => '표시';
	@override String get hide => '숨기기';
	@override String get hidden => '숨김';
	@override String get hideHint => '커뮤니티와 로컬 파일을 표시하거나 숨기려면 눈 아이콘을 탭하세요';
	@override String get videoDescription => '인기 동영상 콘텐츠 탐색';
	@override String get galleryDescription => '이미지와 갤러리 탐색';
	@override String get subscriptionDescription => '팔로우한 사용자의 최신 콘텐츠 보기';
	@override String get forumDescription => '커뮤니티 토론에 참여';
	@override String get newsDescription => '공식 뉴스, 기사 및 방송 탐색';
	@override String get communityDescription => '포럼 토론과 공식 뉴스, 기사 및 방송';
	@override String get localMediaDescription => '이 기기에 저장된 동영상과 이미지 탐색';
}

// Path: news
class _TranslationsNewsKo extends TranslationsNewsEn {
	_TranslationsNewsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '뉴스';
	@override String get newsUpdates => '뉴스 업데이트';
	@override String get articles => '기사';
	@override String get broadcast => '방송';
	@override String get openInBrowser => '브라우저에서 열기';
}

// Path: displaySettings
class _TranslationsDisplaySettingsKo extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '화면 설정';
	@override String get layoutSettings => '레이아웃 설정';
	@override String get layoutSettingsDesc => '열 수와 중단점 구성을 사용자 지정합니다';
	@override String get gridLayout => '그리드 레이아웃';
	@override String get navigationOrderSettings => '내비게이션 순서 설정';
	@override String get customNavigationOrder => '내비게이션 순서 사용자 지정';
	@override String get customNavigationOrderDesc => '하단 내비게이션 바와 사이드바에서 페이지 표시 순서를 조정합니다';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsKo extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '레이아웃 설정';
	@override String get descriptionTitle => '레이아웃 구성 설명';
	@override String get descriptionContent => '여기서의 구성은 동영상 및 갤러리 목록 페이지에 표시되는 열 수를 결정합니다. 자동 모드를 선택하면 시스템이 화면 너비에 따라 자동으로 조정하고, 수동 모드를 선택하면 열 수를 고정할 수 있습니다.';
	@override String get layoutMode => '레이아웃 모드';
	@override String get reset => '초기화';
	@override String get autoMode => '자동 모드';
	@override String get autoModeDesc => '화면 너비에 따라 자동으로 조정';
	@override String get manualMode => '수동 모드';
	@override String get manualModeDesc => '고정 열 수 사용';
	@override String get manualSettings => '수동 설정';
	@override String get fixedColumns => '고정 열';
	@override String get columns => '열';
	@override String get breakpointConfig => '중단점 구성';
	@override String get add => '추가';
	@override String get defaultColumns => '기본 열 수';
	@override String get defaultColumnsDesc => '대형 화면의 기본 표시';
	@override String get previewEffect => '미리보기 효과';
	@override String get screenWidth => '화면 너비';
	@override String get addBreakpoint => '중단점 추가';
	@override String get editBreakpoint => '중단점 편집';
	@override String get deleteBreakpoint => '중단점 삭제';
	@override String get screenWidthLabel => '화면 너비';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => '열';
	@override String get columnsHint => '3';
	@override String get enterWidth => '너비를 입력해 주세요';
	@override String get enterValidWidth => '올바른 너비를 입력해 주세요';
	@override String get widthCannotExceed9999 => '너비는 9999를 초과할 수 없습니다';
	@override String get breakpointAlreadyExists => '중단점이 이미 존재합니다';
	@override String get enterColumns => '열 수를 입력해 주세요';
	@override String get enterValidColumns => '올바른 열 수를 입력해 주세요';
	@override String get columnsCannotExceed12 => '열 수는 12를 초과할 수 없습니다';
	@override String get breakpointConflict => '중단점이 이미 존재합니다';
	@override String get confirmResetLayoutSettings => '레이아웃 설정 초기화';
	@override String get confirmResetLayoutSettingsDesc => '모든 레이아웃 설정을 기본값으로 초기화하시겠습니까?\n\n다음으로 복원됩니다:\n• 자동 모드\n• 기본 중단점 구성';
	@override String get resetToDefaults => '기본값으로 초기화';
	@override String get confirmDeleteBreakpoint => '중단점 삭제';
	@override String confirmDeleteBreakpointDesc({required Object width}) => '${width}px 중단점을 삭제하시겠습니까?';
	@override String get noCustomBreakpoints => '사용자 지정 중단점이 없어 기본 열 수를 사용합니다';
	@override String get breakpointRange => '중단점 범위';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => '편집';
	@override String get delete => '삭제';
	@override String get cancel => '취소';
	@override String get save => '저장';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerKo extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => '동영상 플레이어 오류';
	@override String get videoLoadFailed => '동영상 로드 실패';
	@override String get videoCodecNotSupported => '동영상 코덱을 지원하지 않음';
	@override String get networkConnectionIssue => '네트워크 연결 문제';
	@override String get insufficientPermission => '권한 부족';
	@override String get unsupportedVideoFormat => '지원하지 않는 동영상 형식';
	@override String get retry => '재시도';
	@override String get externalPlayer => '외부 플레이어';
	@override String get detailedErrorInfo => '상세 오류 정보';
	@override String get format => '형식';
	@override String get suggestion => '제안';
	@override String get androidWebmCompatibilityIssue => 'Android 기기는 WEBM 형식 지원이 제한적입니다. 외부 플레이어를 사용하거나 WEBM을 지원하는 플레이어 앱을 다운로드하는 것을 권장합니다';
	@override String get currentDeviceCodecNotSupported => '현재 기기는 이 동영상 형식의 코덱을 지원하지 않습니다';
	@override String get checkNetworkConnection => '네트워크 연결을 확인하고 다시 시도해 주세요';
	@override String get appMayLackMediaPermission => '앱에 필요한 미디어 재생 권한이 없을 수 있습니다';
	@override String get tryOtherVideoPlayer => '다른 동영상 플레이어를 사용해 보세요';
	@override String get unrecognizedVideoFormat => '인식할 수 없는 동영상 파일';
	@override String get unrecognizedVideoFormatSuggestion => '링크가 만료되었거나 응답이 동영상이 아닐 수 있습니다. 다시 시도하거나 다른 앱으로 여세요.';
	@override String get accessDenied => '서버가 이 요청을 거부했습니다(403)';
	@override String get accessDeniedSuggestion => '재생 링크가 만료되었을 가능성이 높습니다. 재시도를 눌러 다시 가져오거나 다른 앱으로 여세요.';
	@override String get mute => '음소거';
	@override String get unmute => '음소거 해제';
	@override String get video => '동영상';
	@override String get serverSelector => 'CDN 서버 선택';
	@override String get serverSelectorDescription => '최상의 재생 환경을 위해 지연이 가장 낮은 서버를 선택하세요';
	@override String get retestSpeed => '속도 다시 테스트';
	@override String get waitingForSpeedTest => '속도 테스트 대기 중';
	@override String get testingSpeed => '속도 테스트 중...';
	@override String get testFailed => '테스트 실패';
	@override String get loadingServerList => '서버 목록 불러오는 중...';
	@override String get noAvailableServers => '사용 가능한 서버가 없습니다';
	@override String get refreshServerList => '서버 목록 새로 고침';
	@override String get cannotGetSource => '현재 동영상 소스를 가져올 수 없습니다';
	@override String switchedToServer({required Object serverName}) => '서버 전환됨: ${serverName}';
	@override String serverCount({required Object count}) => '총 ${count}개 서버';
	@override String statusCode({required Object code}) => '상태 코드: ${code}';
	@override String get connectionFailed => '연결 실패';
	@override String get connectionTimeout => '연결 시간 초과';
	@override String get networkError => '네트워크 오류';
	@override String get sslError => 'SSL 인증서 오류';
	@override String get testCompleted => '테스트 완료';
	@override String get local => '로컬';
	@override String get unknown => '알 수 없음';
	@override String get localVideoPathEmpty => '로컬 동영상 경로가 비어 있습니다';
	@override String localVideoFileNotExists({required Object path}) => '로컬 동영상 파일이 존재하지 않습니다: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => '로컬 동영상을 재생할 수 없습니다: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => '재생할 동영상 파일을 여기에 놓으세요';
	@override String get supportedFormats => '지원 형식: MP4, MKV, AVI, MOV, WEBM 등';
	@override String get noSupportedVideoFile => '지원하는 동영상 파일을 찾을 수 없습니다';
	@override String get retryingOpenVideoLink => '동영상 링크 열기 실패, 재시도 중';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => '디코더를 불러올 수 없습니다: ${event}. 플레이어 설정에서 소프트웨어 디코딩으로 전환한 후 페이지를 다시 들어가 보세요';
	@override String videoLoadErrorWithDetail({required Object event}) => '동영상 로드 오류: ${event}';
	@override String get playbackFailureDiagnosticsHint => '반복되는 재생 실패가 감지되었습니다. 설정 > 진단 및 피드백에서 로그를 내보내세요.';
	@override String get openSettingsAction => '보기';
	@override late final _TranslationsMediaPlayerNoticeKo notice = _TranslationsMediaPlayerNoticeKo._(_root);
	@override String get imageLoadFailed => '이미지 로드 실패';
	@override String get unsupportedImageFormat => '지원하지 않는 이미지 형식';
	@override String get tryOtherViewer => '다른 뷰어를 사용해 보세요';
}

// Path: diagnostics
class _TranslationsDiagnosticsKo extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => '진단 정보';
	@override String get appVersionLabel => '앱 버전';
	@override String memoryUsage({required Object memMB}) => '메모리 사용량: ${memMB}MB';
	@override String get deviceInfoUnavailable => '기기 정보를 가져올 수 없습니다';
	@override String get secureStorageLabel => '보안 저장소';
	@override String get secureStorageHealthy => '사용 가능';
	@override String get secureStorageRecovered => '재설정으로 자체 복구됨(이전 데이터 삭제됨)';
	@override String get secureStorageUnavailable => '사용 불가(로그인이 대체 암호화로 저장됨)';
	@override String get secureStoragePlatformOptOut => '플랫폼 정책에 따라 로컬 암호화(macOS에서는 시스템 키체인을 사용하지 않음)';
	@override String get secureStorageDualWrite => ' (이중 쓰기 보호 켜짐)';
	@override String get schemaHealthLabel => '데이터베이스 스키마';
	@override String get schemaHealthOk => '확인';
	@override String get schemaHealthRepairedNow => '이번 실행에서 안전망으로 복구됨(마이그레이션이 적용되지 않음)';
	@override String get schemaHealthRepairedBefore => '이전에 안전망으로 복구됨';
	@override String get logPolicySectionTitle => '로그 정책';
	@override String get configServiceUnavailable => '구성 서비스가 초기화되지 않았습니다. 로그 정책을 조정할 수 없습니다.';
	@override String get enableLoggingTitle => '로그 기록 사용';
	@override String get enableLoggingSubtitle => '끄면 새 로그 쓰기를 중지합니다';
	@override String get enableLogPersistenceTitle => '로그 영구 저장 사용';
	@override String get enableLogPersistenceSubtitle => '끄면 로그를 메모리에만 유지하고 디스크 쓰기를 중지합니다';
	@override String get minLogLevelTitle => '최소 로그 수준';
	@override String get minLogLevelSubtitle => '이 수준 이하의 로그는 필터링됩니다';
	@override String get maxFileSizeTitle => '단일 파일 크기 제한';
	@override String get maxFileSizeSubtitle => '임계값에 도달하면 로테이션';
	@override String get rotatedFileCountTitle => '메인 로그 로테이션 파일 수';
	@override String get rotatedFileCountSubtitle => '현재 파일을 제외한 보관 파일 수';
	@override String get hangFileSizeTitle => '멈춤 로그 크기 제한';
	@override String get hangFileSizeSubtitle => 'hang_events 파일 증가 제어';
	@override String get hangRotatedFileCountTitle => '멈춤 로그 로테이션 파일 수';
	@override String get hangRotatedFileCountSubtitle => 'hang_events의 보관 기록 수 제어';
	@override String get healthSectionTitle => '로그 상태';
	@override String get refreshMetrics => '지표 새로 고침';
	@override String get toolsSectionTitle => '도구';
	@override String get privacyNotice => '로그에는 계정 데이터와 요청 매개변수 등 민감한 정보가 포함될 수 있습니다. 이슈에 전체 로그를 공개하지 말고, 먼저 검토한 후 이메일로 보내세요.';
	@override String get exportLogsTitle => '로그 내보내기';
	@override String get exportLogsSubtitle => '개발자에게 보내기 전에 개인정보 데이터를 검토하세요';
	@override String get viewLogsTitle => '로그 보기';
	@override String get viewLogsSubtitle => '실행 중인 로그를 실시간으로 확인';
	@override String get copySupportEmailTitle => '지원 이메일 복사';
	@override String get reportIssueTitle => '문제 신고';
	@override String get reportIssueSubtitle => 'GitHub에 재현 단계를 제공하세요(전체 로그 첨부 금지)';
	@override String get healthSummaryUnavailable => '아직 로그 상태 데이터가 없습니다';
	@override String get healthMetricsUnavailable => '상태 지표가 아직 수집되지 않았습니다';
	@override String get healthNoRiskIndicators => '감지된 위험 지표가 없습니다';
	@override late final _TranslationsDiagnosticsHealthAlertKo healthAlert = _TranslationsDiagnosticsHealthAlertKo._(_root);
	@override late final _TranslationsDiagnosticsToastKo toast = _TranslationsDiagnosticsToastKo._(_root);
	@override String get shareSubject => 'LoveIwara 진단 로그(민감한 데이터 포함, 주의해서 공유하세요)';
}

// Path: logViewer
class _TranslationsLogViewerKo extends TranslationsLogViewerEn {
	_TranslationsLogViewerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '로그 뷰어';
	@override String get searchHint => '로그 검색...';
	@override String get emptyState => '로그 없음';
	@override String get copiedToClipboard => '클립보드에 복사되었습니다';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogKo extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '앱이 예기치 않게 종료되었습니다';
	@override String get description => '지난 세션에서 비정상 종료가 감지되었습니다. 진단 로그를 내보내 개발자에게 이메일로 보내 문제 해결에 도움을 주세요.';
	@override String previousVersion({required Object version}) => '마지막 버전: ${version}';
	@override String previousStart({required Object time}) => '마지막 실행: ${time}';
	@override String lastException({required Object message}) => '마지막 예외: ${message}';
	@override String get lastHangRecovered => '지난번 UI 멈춤이 감지되어 자동으로 복구되었습니다';
	@override String lastHangStalled({required Object stalledMs}) => '지난번 UI 멈춤이 감지되었으며 약 ${stalledMs}ms 지속되었습니다';
	@override String get exportGuide => '설정 > 진단 및 피드백 > 로그 내보내기로 이동하세요.';
	@override String get privacyHint => '로그에 개인 정보가 포함되어 있을 수 있습니다. 이메일로 보내기 전에 검토해 주세요:';
	@override String get issueWarning => 'GitHub 이슈에 전체 로그를 공개적으로 첨부하지 마세요';
	@override String get acknowledge => '확인';
	@override String get supportEmailCopied => '이메일이 복사되었습니다';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogKo extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '링크 입력';
	@override String supportedLinksHint({required Object webName}) => '여러 ${webName} 링크를 지능적으로 인식하여 앱의 해당 페이지로 빠르게 이동합니다(링크와 다른 텍스트는 공백으로 구분하세요)';
	@override String inputHint({required Object webName}) => '${webName} 링크를 입력해 주세요';
	@override String get validatorEmptyLink => '링크를 입력해 주세요';
	@override String validatorNoIwaraLink({required Object webName}) => '유효한 ${webName} 링크가 감지되지 않았습니다';
	@override String get multipleLinksDetected => '여러 링크가 감지되었습니다. 하나를 선택해 주세요:';
	@override String notIwaraLink({required Object webName}) => '유효한 ${webName} 링크가 아닙니다';
	@override String linkParseError({required Object error}) => '링크 구문 분석 오류: ${error}';
	@override String get unsupportedLinkDialogTitle => '지원하지 않는 링크';
	@override String get unsupportedLinkDialogContent => '이 링크 유형은 앱에서 직접 열 수 없으며 외부 브라우저를 통해 접속해야 합니다.\n\n이 링크를 브라우저에서 여시겠습니까?';
	@override String get openInBrowser => '브라우저에서 열기';
	@override String get confirmOpenBrowserDialogTitle => '브라우저 열기 확인';
	@override String get confirmOpenBrowserDialogContent => '다음 링크를 외부 브라우저에서 열려고 합니다:';
	@override String get confirmContinueBrowserOpen => '계속하시겠습니까?';
	@override String get browserOpenFailed => '링크를 열지 못했습니다';
	@override String get unsupportedLink => '지원하지 않는 링크';
	@override String get cancel => '취소';
	@override String get confirm => '브라우저에서 열기';
}

// Path: log
class _TranslationsLogKo extends TranslationsLogEn {
	_TranslationsLogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get logManagement => '로그 관리';
	@override String get enableLogPersistence => '로그 영구 저장 사용';
	@override String get enableLogPersistenceDesc => '분석을 위해 로그를 데이터베이스에 저장';
	@override String get logDatabaseSizeLimit => '로그 데이터베이스 크기 제한';
	@override String logDatabaseSizeLimitDesc({required Object size}) => '현재: ${size}';
	@override String get exportCurrentLogs => '현재 로그 내보내기';
	@override String get exportCurrentLogsDesc => '개발자가 문제를 진단할 수 있도록 현재 애플리케이션 로그 내보내기';
	@override String get exportHistoryLogs => '기록 로그 내보내기';
	@override String get exportHistoryLogsDesc => '지정한 날짜 범위 내의 로그 내보내기';
	@override String get exportMergedLogs => '병합 로그 내보내기';
	@override String get exportMergedLogsDesc => '지정한 날짜 범위 내의 병합된 로그 내보내기';
	@override String get showLogStats => '로그 통계 보기';
	@override String get logExportSuccess => '로그 내보내기 성공';
	@override String logExportFailed({required Object error}) => '로그 내보내기 실패: ${error}';
	@override String get showLogStatsDesc => '다양한 유형의 로그 통계 보기';
	@override String logExtractFailed({required Object error}) => '로그 통계를 가져오지 못했습니다: ${error}';
	@override String get clearAllLogs => '모든 로그 지우기';
	@override String get clearAllLogsDesc => '모든 로그 데이터 지우기';
	@override String get confirmClearAllLogs => '지우기 확인';
	@override String get confirmClearAllLogsDesc => '모든 로그 데이터를 지우시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String get clearAllLogsSuccess => '로그를 지웠습니다';
	@override String clearAllLogsFailed({required Object error}) => '로그 지우기 실패: ${error}';
	@override String get unableToGetLogSizeInfo => '로그 크기 정보를 가져올 수 없습니다';
	@override String get currentLogSize => '현재 로그 크기:';
	@override String get logCount => '로그 수:';
	@override String get logCountUnit => '개';
	@override String get logSizeLimit => '로그 크기 제한:';
	@override String get usageRate => '사용률:';
	@override String get exceedLimit => '한도 초과';
	@override String get remaining => '남음';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => '현재 로그 크기가 초과되었습니다. 오래된 로그를 정리하거나 로그 크기 제한을 늘려 주세요';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => '현재 로그 크기가 거의 초과되었습니다. 오래된 로그를 정리해 주세요';
	@override String get cleaningOldLogs => '오래된 로그 정리 중...';
	@override String get logCleaningCompleted => '로그 정리 완료';
	@override String get logCleaningProcessMayNotBeCompleted => '로그 정리 과정이 완료되지 않았을 수 있습니다';
	@override String get cleanExceededLogs => '초과된 로그 정리';
	@override String get noLogsToExport => '내보낼 로그가 없습니다';
	@override String get exportingLogs => '로그 내보내는 중...';
	@override String get noHistoryLogsToExport => '내보낼 기록 로그가 없습니다. 먼저 앱을 잠시 사용해 보세요';
	@override String get selectLogDate => '로그 날짜 선택';
	@override String get today => '오늘';
	@override String get selectMergeRange => '병합 범위 선택';
	@override String get selectMergeRangeHint => '병합할 로그 시간 범위를 선택해 주세요';
	@override String selectMergeRangeDays({required Object days}) => '최근 ${days}일';
	@override String get logStats => '로그 통계';
	@override String todayLogs({required Object count}) => '오늘 로그: ${count}개';
	@override String recent7DaysLogs({required Object count}) => '최근 7일 로그: ${count}개';
	@override String totalLogs({required Object count}) => '전체 로그: ${count}개';
	@override String get setLogDatabaseSizeLimit => '로그 데이터베이스 크기 제한 설정';
	@override String currentLogSizeWithSize({required Object size}) => '현재 로그 크기: ${size}';
	@override String get warning => '경고';
	@override String newSizeLimit({required Object size}) => '새 크기 제한: ${size}';
	@override String get confirmToContinue => '계속하려면 확인';
	@override String logSizeLimitSetSuccess({required Object size}) => '로그 크기 제한을 ${size}로 설정했습니다';
}

// Path: emoji
class _TranslationsEmojiKo extends TranslationsEmojiEn {
	_TranslationsEmojiKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '이모지';
	@override String get size => '크기';
	@override String get small => '소';
	@override String get medium => '중';
	@override String get large => '대';
	@override String get extraLarge => '특대';
	@override String get copyEmojiLinkSuccess => '이모지 링크가 복사되었습니다';
	@override String get preview => '이모지 미리보기';
	@override String get library => '이모지 라이브러리';
	@override String get noEmojis => '이모지 없음';
	@override String get clickToAddEmojis => '오른쪽 위 버튼을 클릭하여 이모지를 추가하세요';
	@override String get addEmojis => '이모지 추가';
	@override String get imagePreview => '이미지 미리보기';
	@override String get imageLoadFailed => '이미지 로드 실패';
	@override String get loading => '로딩 중...';
	@override String get delete => '삭제';
	@override String get close => '닫기';
	@override String get deleteImage => '이미지 삭제';
	@override String get confirmDeleteImage => '이 이미지를 삭제하시겠습니까?';
	@override String get cancel => '취소';
	@override String get batchDelete => '일괄 삭제';
	@override String confirmBatchDelete({required Object count}) => '선택한 ${count}개 이미지를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String get deleteSuccess => '삭제되었습니다';
	@override String get addImage => '이미지 추가';
	@override String get addImageByUrl => 'URL로 추가';
	@override String get addImageUrl => '이미지 URL 추가';
	@override String get imageUrl => '이미지 URL';
	@override String get enterImageUrl => '이미지 URL을 입력해 주세요';
	@override String get add => '추가';
	@override String get batchImport => '일괄 가져오기';
	@override String get enterJsonUrlArray => 'JSON 형식의 URL 배열을 입력해 주세요:';
	@override String get formatExample => '형식 예시:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'JSON 형식의 URL 배열을 붙여 넣어 주세요';
	@override String get import => '가져오기';
	@override String importSuccess({required Object count}) => '이미지 ${count}개를 가져왔습니다';
	@override String get jsonFormatError => 'JSON 형식 오류입니다. 입력을 확인해 주세요';
	@override String get createGroup => '이모지 그룹 만들기';
	@override String get groupName => '그룹 이름';
	@override String get enterGroupName => '그룹 이름을 입력해 주세요';
	@override String get create => '만들기';
	@override String get editGroupName => '그룹 이름 편집';
	@override String get save => '저장';
	@override String get deleteGroup => '그룹 삭제';
	@override String get confirmDeleteGroup => '이 이모지 그룹을 삭제하시겠습니까? 그룹의 모든 이미지도 함께 삭제됩니다.';
	@override String imageCount({required Object count}) => '이미지 ${count}개';
	@override String get selectEmoji => '이모지 선택';
	@override String get noEmojisInGroup => '이 그룹에 이모지가 없습니다';
	@override String get goToSettingsToAddEmojis => '설정에서 이모지를 추가하세요';
	@override String get emojiManagement => '이모지 관리';
	@override String get manageEmojiGroupsAndImages => '이모지 그룹과 이미지 관리';
	@override String get uploadLocalImages => '로컬 이미지 업로드';
	@override String get uploadingImages => '이미지 업로드 중';
	@override String uploadingImagesProgress({required Object count}) => '이미지 ${count}개 업로드 중, 잠시 기다려 주세요...';
	@override String get doNotCloseDialog => '이 대화상자를 닫지 마세요';
	@override String uploadSuccess({required Object count}) => '이미지 ${count}개를 업로드했습니다';
	@override String uploadFailed({required Object count}) => '${count}개 실패';
	@override String get uploadFailedMessage => '이미지 업로드 실패, 네트워크 연결 또는 파일 형식을 확인해 주세요';
	@override String uploadErrorMessage({required Object error}) => '업로드 중 오류 발생: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterKo extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selectField => '필드 선택';
	@override String get add => '추가';
	@override String get clear => '지우기';
	@override String get clearAll => '모두 지우기';
	@override String get generatedQuery => '생성된 쿼리';
	@override String get copyToClipboard => '클립보드에 복사';
	@override String get copied => '복사됨';
	@override String filterCount({required Object count}) => '필터 ${count}개';
	@override String get filterSettings => '필터 설정';
	@override String get field => '필드';
	@override String get operator => '연산자';
	@override String get language => '언어';
	@override String get value => '값';
	@override String get dateRange => '날짜 범위';
	@override String get numberRange => '숫자 범위';
	@override String get from => '시작';
	@override String get to => '종료';
	@override String get date => '날짜';
	@override String get number => '숫자';
	@override String get boolean => '불리언';
	@override String get tags => '태그';
	@override String get select => '선택';
	@override String get clickToSelectDate => '클릭하여 날짜 선택';
	@override String get pleaseEnterValidNumber => '유효한 숫자를 입력하세요';
	@override String get pleaseEnterValidDate => '유효한 날짜 형식(YYYY-MM-DD)을 입력하세요';
	@override String get startValueMustBeLessThanEndValue => '시작 값은 끝 값보다 작아야 합니다';
	@override String get startDateMustBeBeforeEndDate => '시작 날짜는 종료 날짜보다 앞서야 합니다';
	@override String get pleaseFillStartValue => '시작 값을 입력하세요';
	@override String get pleaseFillEndValue => '끝 값을 입력하세요';
	@override String get rangeValueFormatError => '범위 값 형식 오류';
	@override String get contains => '포함';
	@override String get equals => '같음';
	@override String get notEquals => '같지 않음';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => '범위';
	@override String get kIn => '다음 중 하나 포함';
	@override String get notIn => '다음 중 하나도 포함하지 않음';
	@override String get username => '사용자 이름';
	@override String get nickname => '닉네임';
	@override String get registrationDate => '가입일';
	@override String get description => '설명';
	@override String get title => '제목';
	@override String get body => '본문';
	@override String get author => '작성자';
	@override String get publishDate => '게시일';
	@override String get private => '비공개';
	@override String get duration => '길이 (초)';
	@override String get likes => '좋아요';
	@override String get views => '조회수';
	@override String get comments => '댓글';
	@override String get rating => '등급';
	@override String get imageCount => '이미지 수';
	@override String get videoCount => '동영상 수';
	@override String get createDate => '생성일';
	@override String get content => '콘텐츠';
	@override String get all => '전체';
	@override String get adult => '성인';
	@override String get general => '일반';
	@override String get yes => '예';
	@override String get no => '아니요';
	@override String get users => '사용자';
	@override String get videos => '동영상';
	@override String get images => '이미지';
	@override String get posts => '게시물';
	@override String get forumThreads => '포럼 스레드';
	@override String get forumPosts => '포럼 게시물';
	@override String get playlists => '재생목록';
	@override late final _TranslationsSearchFilterSortTypesKo sortTypes = _TranslationsSearchFilterSortTypesKo._(_root);
	@override String get drawerSubtitle => '변경 사항이 즉시 적용됩니다';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupKo extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeKo welcome = _TranslationsFirstTimeSetupWelcomeKo._(_root);
	@override late final _TranslationsFirstTimeSetupBasicKo basic = _TranslationsFirstTimeSetupBasicKo._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkKo network = _TranslationsFirstTimeSetupNetworkKo._(_root);
	@override late final _TranslationsFirstTimeSetupThemeKo theme = _TranslationsFirstTimeSetupThemeKo._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerKo player = _TranslationsFirstTimeSetupPlayerKo._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialKo spatial = _TranslationsFirstTimeSetupSpatialKo._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionKo completion = _TranslationsFirstTimeSetupCompletionKo._(_root);
	@override late final _TranslationsFirstTimeSetupCommonKo common = _TranslationsFirstTimeSetupCommonKo._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperKo extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => '시스템 프록시 감지됨';
	@override String get copied => '복사됨';
	@override String get copy => '복사';
}

// Path: tagSelector
class _TranslationsTagSelectorKo extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selectTags => '태그 선택';
	@override String get clickToSelectTags => '클릭하여 태그 선택';
	@override String get addTag => '태그 추가';
	@override String get removeTag => '태그 제거';
	@override String get deleteTag => '태그 삭제';
	@override String get usageInstructions => '먼저 태그를 추가한 다음 기존 태그에서 클릭하여 선택하세요';
	@override String get usageInstructionsTooltip => '사용 방법';
	@override String get addTagTooltip => '태그 추가';
	@override String get removeTagTooltip => '태그 제거';
	@override String get cancelSelection => '선택 취소';
	@override String get selectAll => '전체 선택';
	@override String get cancelSelectAll => '전체 선택 취소';
	@override String get delete => '삭제';
}

// Path: anime4k
class _TranslationsAnime4kKo extends TranslationsAnime4kEn {
	_TranslationsAnime4kKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => '실시간 영상 업스케일링 및 노이즈 제거로 애니메이션 영상 화질 향상';
	@override String get settings => 'Anime4K 설정';
	@override String get preset => 'Anime4K 프리셋';
	@override String get disable => 'Anime4K 끄기';
	@override String get disableDescription => '영상 향상 효과 끄기';
	@override String get highQualityPresets => '고품질 프리셋';
	@override String get fastPresets => '고속 프리셋';
	@override String get litePresets => '경량 프리셋';
	@override String get moreLitePresets => '초경량 프리셋';
	@override String get customPresets => '사용자 지정 프리셋';
	@override late final _TranslationsAnime4kPresetGroupsKo presetGroups = _TranslationsAnime4kPresetGroupsKo._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsKo presetDescriptions = _TranslationsAnime4kPresetDescriptionsKo._(_root);
	@override late final _TranslationsAnime4kPresetNamesKo presetNames = _TranslationsAnime4kPresetNamesKo._(_root);
	@override String get performanceTip => '💡 팁: 기기 성능에 맞는 프리셋을 선택하세요. 저사양 기기에는 경량 프리셋을 권장합니다.';
	@override String get compatibilityTip => '⚠️ 일부 모바일 GPU(예: Kirin 980 / Mali-G76)는 사용자 지정 셰이더를 렌더링할 수 없습니다. 소리는 나오는데 화면이 검게 변하면 여기에서 Anime4K를 꺼 주세요.';
	@override String get autoDisabledOnRenderFailure => '기기의 GPU가 Anime4K 셰이더를 렌더링하지 못해 자동으로 꺼졌습니다.';
}

// Path: siteMode
class _TranslationsSiteModeKo extends TranslationsSiteModeEn {
	_TranslationsSiteModeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '사이트 모드';
	@override String get mainSite => '메인';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => '현재 ${currentSite} · 탭하여 ${nextSite} 모드로 전환';
	@override String get dialogTitle => '사이트 모드 전환';
	@override String get dialogDescription => '전환하면 앱 전체가 새로 고쳐지고 이전에 불러온 목록과 페이지 상태가 초기화됩니다.';
	@override String get chooseLinkTargetTitle => '대상 사이트 선택';
	@override String get chooseLinkTargetDescription => '이 링크에는 도메인이 없습니다. 메인 또는 AI로 열지 선택하세요.';
	@override String get chooseLinkTargetHint => '한 번 열면 이 페이지와 이후 세부 요청이 선택한 사이트를 계속 사용합니다.';
	@override String get alreadyUsing => '이미 이 사이트 모드를 사용 중입니다.';
	@override String openInSite({required Object site}) => '${site}에서 열기';
	@override String confirmUsing({required Object site}) => '확인하면 이후 요청은 ${site} 모드를 사용합니다.';
	@override String switched({required Object site}) => '${site} 모드로 전환했습니다. 앱이 새로 고쳐졌습니다.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigKo extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '저장된 필터';
	@override String get empty => '저장된 필터가 없습니다';
	@override String get saveTooltip => '현재 필터 저장';
	@override String get namePromptTitle => '필터 저장';
	@override String get nameLabel => '이름';
	@override String get nameHint => '이름을 입력하세요';
	@override String get saveSuccess => '필터가 저장되었습니다';
	@override String get deleteSuccess => '필터가 삭제되었습니다';
	@override String get addCurrent => '현재 필터 저장';
	@override String get reorderHint => '길게 눌러 끌어서 순서를 변경하세요';
	@override String get rename => '이름 바꾸기';
	@override String get unnamed => '이름 없음';
	@override String get noConditions => '모든 콘텐츠 (필터 없음)';
	@override String tagsCount({required Object count}) => '태그 ${count}개';
}

// Path: savedSearch
class _TranslationsSavedSearchKo extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '저장된 검색';
	@override String get empty => '저장된 검색이 없습니다';
	@override String get saveTooltip => '현재 검색 저장';
	@override String get namePromptTitle => '검색 저장';
	@override String get nameLabel => '이름';
	@override String get nameHint => '이름을 입력하세요';
	@override String get saveSuccess => '검색이 저장되었습니다';
	@override String get deleteSuccess => '검색이 삭제되었습니다';
	@override String get addCurrent => '현재 검색 저장';
	@override String get reorderHint => '길게 눌러 끌어서 순서를 변경하세요';
	@override String get rename => '이름 바꾸기';
	@override String get noKeyword => '(키워드 없음)';
	@override String filtersCount({required Object count}) => '필터 ${count}개';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderKo extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '기본 태그 블랙리스트가 감지되었습니다';
	@override String get content => '계정에 웹사이트가 모든 신규 계정에 자동 적용하는 태그 블랙리스트가 아직 사용 중입니다. 검토하고 관리하시겠습니까?';
	@override String get goManage => '관리';
	@override String get dismiss => '나중에';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistKo extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '색각 보조';
	@override String get description => '색각 이상 시청자를 위해 영상 색상을 보정하며, Anime4K와 함께 사용할 수 있습니다';
	@override String get galleryDescription => '색각 이상 시청자를 위해 갤러리 이미지 색상을 보정합니다(플레이어 스위치와 무관)';
	@override String get galleryDescriptionSpatial => '색각 이상 시청자를 위해 갤러리 이미지 색상을 보정합니다. 이 패널 내부의 2D 뷰어에만 적용되며, 공간 화면의 이미지는 네이티브로 렌더링되어 이 필터를 거치지 않습니다';
	@override String get disable => '끄기';
	@override String get disableDescription => '색상 보정 없음';
	@override String get protanopia => '적색 보정(제1색각이상)';
	@override String get protanopiaDescription => '제1색각이상(적색 구분 어려움)용';
	@override String get deuteranopia => '녹색 보정(제2색각이상)';
	@override String get deuteranopiaDescription => '제2색각이상(녹색 구분 어려움)용';
	@override String get tritanopia => '청색 보정(제3색각이상)';
	@override String get tritanopiaDescription => '제3색각이상(청색과 황색 구분 어려움)용';
	@override String appliedToast({required Object filterName}) => '${filterName} 적용됨, 즉시 적용됩니다';
	@override String get disabledToast => '색각 보조가 꺼졌습니다';
}

// Path: externalPlayer
class _TranslationsExternalPlayerKo extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '다른 앱으로 열기';
	@override String get description => '현재 동영상을 이 기기의 다른 플레이어로 전달합니다. VR 헤드셋의 Skybox나 Pigasus, 휴대폰의 MX Player, VLC 등이 있습니다';
	@override String get openWithOtherApp => '다른 앱 선택';
	@override String get openWithOtherAppDescription => '시스템 선택기를 표시하고 인계할 플레이어를 고릅니다';
	@override String get openWithSystemPlayer => '기본 플레이어로 열기';
	@override String get openWithSystemPlayerDescription => '시스템 기본 동영상 앱으로 전달합니다';
	@override String get copyLink => '동영상 링크 복사';
	@override String get copyLinkDescription => 'Skybox나 DeoVR처럼 URL 붙여넣기만 지원하는 플레이어용';
	@override String get linkCopied => '동영상 링크가 복사되었습니다';
	@override String get sourceLocal => '로컬 파일';
	@override String get sourceOnline => '직접 링크';
	@override String sourceOnlineWithQuality({required Object quality}) => '직접 링크 · ${quality}';
	@override String get onlineLinkExpiryHint => '직접 링크는 만료되므로 외부 플레이어가 중간에 멈출 수 있습니다. 먼저 다운로드하는 것이 안정적입니다.';
	@override String get vrPlayerHint => '선택기에 VR 플레이어가 없으면 동영상 링크 복사를 사용해 해당 플레이어 안에 붙여 넣으세요.';
	@override String get noHandler => '이 기기에서 동영상을 열 수 있는 앱이 없습니다';
	@override String handoffFailed({required Object message}) => '전달 실패: ${message}';
	@override String get handoffFailedUnknown => '전달 실패';
	@override String get sourceUnavailable => '현재 동영상 주소를 가져올 수 없습니다. 다시 시도해 주세요';
	@override String get localFileMissing => '로컬 파일이 더 이상 존재하지 않습니다';
	@override String get handedOff => '외부 플레이어로 전달했습니다';
	@override String get desktopSectionTitle => '외부 플레이어';
	@override String get managePlayers => '외부 플레이어 관리';
	@override String get managePlayersDescWindows => 'HereSphere, DeoVR, Whirligig 같은 PCVR 플레이어는 시스템 기본 앱이 아닙니다. 해당 .exe를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.';
	@override String get managePlayersDescMac => 'IINA, VLC, mpv 같은 플레이어를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.';
	@override String get managePlayersDescLinux => 'mpv, VLC, Celluloid 같은 플레이어를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.';
	@override String get pickExecutableHintWindows => '플레이어 설치 폴더 안의 기본 .exe를 선택하세요. 예: HereSphere.exe 또는 vlc.exe. 바탕화면 바로 가기(.lnk)는 작동하지 않습니다.';
	@override String get pickExecutableHintMac => 'Applications에서 플레이어의 .app을 선택하세요. 예: IINA.app — 내부의 실제 실행 파일은 자동으로 찾아집니다.';
	@override String get pickExecutableHintLinux => '플레이어의 실행 파일을 선택하세요. 예: /usr/bin/mpv. which mpv를 실행하면 위치를 알 수 있습니다.';
	@override String emptyStateGuide({required Object examples}) => '한 번 구성하면 플레이어 페이지의 다른 앱으로 열기 아래에 자체 항목으로 표시됩니다. 일반적인 예: ${examples}';
	@override String get detectNothingFoundGuide => '설치된 플레이어를 찾지 못했습니다. 사용자 지정 설치 폴더와 포터블 빌드는 감지할 수 없습니다 — 플레이어 추가로 직접 지정하세요.';
	@override String get detectNothingNew => '새 플레이어가 없습니다. 설치된 항목은 이미 목록에 있습니다';
	@override String get detectFailed => '감지 실패 — 플레이어 추가로 직접 지정하세요';
	@override String get advancedOptions => '고급';
	@override String get playerNameHint => '비워 두면 파일 이름을 사용합니다';
	@override String get executablePathRequired => '먼저 플레이어의 실행 파일을 선택하세요';
	@override String playerCount({required Object count}) => '${count}개 구성됨';
	@override String get noPlayerConfigured => '아직 구성된 외부 플레이어가 없습니다';
	@override String get autoDetect => '자동 감지';
	@override String get detecting => '감지 중…';
	@override String detectFound({required Object count}) => '플레이어 ${count}개 발견';
	@override String get detectNothingFound => '새 플레이어를 찾지 못했습니다. 직접 추가하세요';
	@override String get autoDetectedTag => '감지됨';
	@override String get addPlayer => '플레이어 추가';
	@override String get editPlayer => '플레이어 편집';
	@override String get playerName => '이름';
	@override String get executablePath => '실행 파일';
	@override String get browse => '찾아보기';
	@override String get argumentTemplate => '실행 인수';
	@override String get argumentTemplateHint => '동영상 경로나 URL에는 {input}을 사용하세요. 비워 두면 유일한 인수로 전달됩니다.';
	@override String get nameAndPathRequired => '이름과 실행 파일은 모두 필수입니다';
	@override String get testLaunch => '테스트 실행';
	@override String get testLaunched => '플레이어를 실행했습니다';
	@override String get testFailed => '실행 실패, 실행 파일 경로를 확인하세요';
	@override String get executableMissing => '실행 파일을 찾을 수 없습니다';
	@override String openWithNamed({required Object name}) => '${name}(으)로 열기';
	@override String get managePlayersEntry => '외부 플레이어 관리…';
}

// Path: watchLater
class _TranslationsWatchLaterKo extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '나중에 보기';
	@override String get addToWatchLater => '나중에 보기';
	@override String get removeFromWatchLater => '나중에 보기에서 제거';
	@override String get addedToWatchLater => '나중에 보기에 추가되었습니다';
	@override String get alreadyInWatchLater => '이미 나중에 보기에 있습니다';
	@override String get removedFromWatchLater => '나중에 보기에서 제거되었습니다';
	@override String removedCount({required Object count}) => '${count}개 항목을 제거했습니다';
	@override String get viewWatchLaterList => '목록 보기';
	@override String get addFailed => '나중에 보기에 추가하지 못했습니다';
	@override String get invalidItem => '사용할 수 없음';
	@override String get clearWatched => '시청한 항목 지우기';
	@override String watchedCleared({required Object count}) => '시청한 ${count}개 항목을 지웠습니다';
	@override String get noWatchedToClear => '지울 시청 항목이 없습니다';
	@override String get emptyVideo => '나중에 보기에 아직 동영상이 없습니다';
	@override String get emptyGallery => '나중에 보기에 아직 갤러리가 없습니다';
	@override String get filterAll => '전체';
	@override String get filterUnwatched => '시청 안 함';
	@override String get sortRecentlyAdded => '최근 추가됨';
	@override String get sortEarliestAdded => '가장 먼저 추가됨';
	@override String get watched => '시청함';
	@override String get playlistLoadFailed => '재생목록을 불러오지 못했습니다';
	@override String get noPlaylists => '아직 재생목록이 없습니다';
	@override String get undo => '실행 취소';
	@override String get clearWatchedConfirm => '이 탭에서 이미 시청한 항목을 모두 지우시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String get emptyUnwatchedVideo => '여기에 볼 남은 항목이 없습니다';
	@override String get emptyUnwatchedGallery => '여기에 볼 남은 항목이 없습니다';
	@override String get queueLoadFailed => '불러오지 못했습니다. 탭하여 다시 시도';
}

// Path: mediaMenu
class _TranslationsMediaMenuKo extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get like => '좋아요';
	@override String get unlike => '좋아요 취소';
	@override String get viewAuthor => '작성자 보기';
	@override String inFolders({required Object count}) => '폴더 ${count}개';
	@override String inPlaylists({required Object count}) => '재생목록 ${count}개';
	@override String get downloaded => '다운로드됨';
}

// Path: mediaPreview
class _TranslationsMediaPreviewKo extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get preview => '미리보기';
	@override String get openDetail => '열기';
	@override String get moreActions => '더 많은 작업';
	@override String get previousImage => '이전 이미지';
	@override String get nextImage => '다음 이미지';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueKo extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count}개 이미지';
	@override String get upNext => '다음 항목';
	@override String get sourceTab => '소스';
	@override String get emptyQueue => '이 대기열에 재생할 항목이 없습니다';
	@override String get emptyGalleryQueue => '이 대기열에 갤러리가 없습니다';
	@override String get nowPlaying => '재생 중';
	@override String get myPlaylists => '내 재생목록';
	@override String get authorPlaylists => '작성자의 재생목록';
	@override String get openQueue => '다음 항목';
	@override String get continueInQueue => '현재 대기열에서 계속 재생';
	@override String get continueInQueueSubtitle => '다음 항목을 자동으로 재생하며 "재생 완료 후 반복"을 비활성화합니다';
	@override String get repeatDisabledByQueue => '현재 대기열에서 계속 재생 기능이 켜져 있는 동안에는 비활성화됩니다';
	@override String get playNext => '다음 재생';
	@override String get queueEnded => '대기열의 마지막 항목입니다';
	@override String get playNextHint => '탭하면 다음 항목을 재생하고, 길게 누르면 다음 항목을 엽니다';
	@override String get authorVideos => '작성자의 동영상';
	@override String get authorGalleries => '작성자의 갤러리';
	@override String get favoriteFolders => '즐겨찾는 폴더';
	@override String get localFiles => '이 기기';
	@override String get currentFolder => '이 파일의 폴더';
	@override String get playThisFolder => '이 폴더의 동영상 대기열 보기';
	@override String get browseThisFolder => '이 폴더의 갤러리 대기열 보기';
	@override String get downloads => '다운로드됨';
	@override String get otherPlaylists => '다른 사용자의 재생목록';
	@override String get nothingHere => '여기에 아무것도 없습니다';
}

// Path: vrFormat
class _TranslationsVrFormatKo extends TranslationsVrFormatEn {
	_TranslationsVrFormatKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => '공간 플레이어에서 재생';
	@override String get handingOff => '공간으로 전환 중…';
	@override String get title => '재생 모드';
	@override String get spatialSectionTitle => '공간 재생';
	@override String get spatialSectionDesc => '헤드셋에서는 동영상이 이 패널 안에 그려지지 않습니다. 공간 플레이어가 방 안의 화면에 표시합니다.';
	@override String get spatialPanelEntry => '공간 컨트롤 패널';
	@override String get spatialPanelEntryDesc => '화면 거리, 크기, 곡률, 배경 환경과 속도, 반복, 자동 숨김은 모두 공간 컨트롤 패널에 있습니다.';
	@override String get spatialGuideEntry => '헤드셋 컨트롤 가이드';
	@override String get spatialGuideEntryDesc => '컨트롤러 버튼, 화면 잡기, 스틱 탐색, 페이지 넘김';
	@override String get spatialFlatOmitted => '터치 제스처, 이미지 향상, 오디오/비디오 매개변수는 2D 플레이어에만 적용됩니다. 공간 플레이어는 다른 엔진에서 실행되므로 여기에 나열되지 않습니다.';
	@override String get spatialGallerySectionTitle => '공간 갤러리';
	@override String get spatialGalleryPanelDesc => '슬라이드쇼 간격, 단일 클립 반복, 화면 곡률은 모두 공간 컨트롤 패널에서 조정합니다.';
	@override String get autoEnterGallery => '갤러리 이미지를 공간 갤러리에서 열기';
	@override String get autoEnterGalleryDesc => 'Quest에서는 이미지를 탭하면 이 패널 안의 뷰어 대신 필름스트립, 슬라이드쇼, 컨트롤러 페이지 넘김을 갖춘 공간 갤러리가 떠 있는 화면에 전체 갤러리를 엽니다.';
	@override String get panelSettings => '패널 및 배경';
	@override String get panelSettingsDesc => '이 앱 패널이 얼마나 떨어져 있는지, 뒤에 방이 얼마나 보이는지';
	@override String get panelDistance => '패널 거리';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => '배치 초기화';
	@override String get panelResetBackground => '기본값으로 재설정';
	@override String get panelBackground => '배경 투명도';
	@override String get panelBackgroundHint => '0%: 검은 주변 · 100%: 실제 방, 주변광 적용';
	@override String get panelUnavailable => '현재 패널이 제자리에 없습니다. 잠시 후 다시 시도하세요';
	@override String get desc => '이 동영상을 어떤 방식으로 재생할지 기하 구성을 선택합니다. 사이트에서 이 정보를 제공하지 않으므로 자동 감지는 시작점만 정하며, 선택한 값이 우선합니다.';
	@override String get sectionFlat => '일반';
	@override String get sectionStereo => '일반 3D';
	@override String get sectionPanorama => 'VR 파노라마';
	@override String get flat => '일반 동영상';
	@override String get flatDesc => '그대로 재생, 리매핑 없음';
	@override String get flatSideBySide => '나란히 3D';
	@override String get flatSideBySideDesc => '절반마다 한쪽 눈, 좌우로 나열; 왼쪽 눈을 표시하고 화면 비율을 복원합니다';
	@override String get flatTopBottom => '상하 3D';
	@override String get flatTopBottomDesc => '절반마다 한쪽 눈, 위아래로 배치; 위쪽 절반을 표시하고 화면 비율을 복원합니다';
	@override String get vr180SideBySide => 'VR180 나란히';
	@override String get vr180SideBySideDesc => '양안 반구형 파노라마 — 가장 흔한 VR 소스';
	@override String get vr180Mono => 'VR180 모노';
	@override String get vr180MonoDesc => '반구형 파노라마, 프레임당 단일 시점';
	@override String get vr360Mono => 'VR360 모노';
	@override String get vr360MonoDesc => '완전 몰입형 파노라마, 프레임당 단일 시점';
	@override String get vr360TopBottom => 'VR360 상하';
	@override String get vr360TopBottomDesc => '양안이 위아래로 쌓인 완전 몰입형 파노라마';
	@override String get resetView => '시야 초기화';
	@override String get resetViewDesc => '시선 방향과 시야각을 정면으로 되돌립니다';
	@override String get resetToAuto => '자동 감지로 되돌리기';
	@override String get resetToAutoDesc => '이 동영상의 수동 선택을 지우고 다시 감지하도록 합니다';
	@override String get manualBadge => '수동 설정됨';
	@override String get panoramaHint => '화면을 끌어 주변을 둘러보고, 핀치하여 시야각을 변경하세요';
	@override String get panoramaGestureNotice => '둘러보는 동안 끌면 시야가 돌아갑니다. 탐색은 진행 표시줄을 사용하세요';
	@override String get shaderUnsupported => '이 기기는 실시간 파노라마를 렌더링할 수 없어 단일 시점으로 표시합니다';
	@override String get handoffTooltip => '다른 방식으로 재생';
	@override String get suggestedBadge => '추천';
	@override String suggestedEntryDesc({required Object format}) => '${format}인 것 같습니다 — 탭하여 전환';
	@override String suggestionTitle({required Object format}) => 'VR 동영상일 수 있습니다 (${format})';
	@override String get suggestionTitleShort => 'VR 동영상일 수 있습니다';
	@override String get suggestionAction => 'VR로 재생';
	@override String get suggestionDismiss => '닫기';
}

// Path: localMedia
class _TranslationsLocalMediaKo extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseKo browse = _TranslationsLocalMediaBrowseKo._(_root);
	@override String get tabFolders => '폴더';
	@override String get tabFavoriteVideos => '즐겨찾기';
	@override String get tabAllVideos => '모든 동영상';
	@override String get tabAllImages => '모든 이미지';
	@override String get tabDownloadedVideos => '다운로드한 동영상';
	@override String get tabDownloadedGalleries => '다운로드한 갤러리';
	@override String get title => '이 기기에서';
	@override String get sourceOnline => 'Iwara 온라인';
	@override String get manageSources => '소스 관리';
	@override String get moveToCategory => '카테고리로 이동';
	@override String get manageCategories => '카테고리 관리';
	@override String get suggestedFolders => '동영상이 있는 폴더';
	@override String get sortRecentlyAdded => '최근 추가순';
	@override String get sortRecentlyPlayed => '최근 재생순';
	@override String get sortName => '이름';
	@override String get sortDuration => '재생 시간';
	@override String get sortSize => '크기';
	@override String get sortFolder => '폴더';
	@override String get sortRecentlyModified => '최근 수정순';
	@override String get sortCount => '개수';
	@override String folderCardItemCount({required Object count}) => '이미지 ${count}개';
	@override String get downloadsSource => '다운로드됨';
	@override String get builtInSourceHint => '다운로드는 자동으로 관리됩니다';
	@override String get filterByCategory => '카테고리로 필터';
	@override String get longPressToCategorize => '길게 눌러 카테고리로 이동';
	@override String get uncategorized => '미분류';
	@override String get setCategoryFailed => '카테고리를 설정할 수 없습니다';
	@override String get categoryUpdated => '카테고리가 업데이트되었습니다';
	@override String get addFolder => '폴더 추가';
	@override String get addDeviceVideos => '기기 동영상 검사';
	@override String get mediaStoreSourceName => '기기 동영상';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsKo itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsKo._(_root);
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
	@override late final _TranslationsLocalMediaMissingKo missing = _TranslationsLocalMediaMissingKo._(_root);
	@override late final _TranslationsLocalMediaWebdavKo webdav = _TranslationsLocalMediaWebdavKo._(_root);
	@override String get mediaStoreUnavailable => '기기 미디어 색인은 Android에서만 사용할 수 있습니다';
	@override String get mediaStorePermissionDenied => '동영상 접근 권한이 부여되지 않았습니다';
	@override String get rescan => '다시 검사';
	@override String scanning({required Object count}) => '검사 중… ${count}개 발견';
	@override String scanFailed({required Object reason}) => '검사 실패: ${reason}';
	@override String scanTruncated({required Object count}) => '해당 폴더가 너무 커서 처음 ${count}개 파일만 추가되었습니다.';
	@override String sourceOverlaps({required Object name}) => '이미 "${name}" 폴더에 포함되어 있습니다';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '"${name}"은(는) "${source}" 안에 있어 빠른 접근 폴더에 추가되었습니다';
	@override String alreadyPinnedFolder({required Object name}) => '"${name}"은(는) 이미 빠른 접근 폴더에 있습니다';
	@override String sourceAlreadyAdded({required Object name}) => '"${name}"은(는) 이미 추가되었습니다';
	@override String sourceContainsExisting({required Object name}) => '이미 추가된 폴더 "${name}"을(를) 포함하고 있어 상위 폴더 추가는 아직 지원되지 않습니다';
	@override String get addSourceFailed => '해당 폴더를 추가할 수 없습니다';
	@override String get fileMissing => '해당 파일이 더 이상 디스크에 없습니다';
	@override String get permissionDenied => '파일 접근 권한 없음 · 탭하여 허용';
	@override String get noVideosFound => '이 폴더에 동영상이 없습니다';
	@override String get emptyTitle => '폴더를 추가하여 이 기기에 이미 있는 동영상을 시청하세요';
	@override String get emptyPrivacyNote => '파일은 이 기기에서만 읽습니다. 아무것도 업로드되지 않습니다.';
	@override String removeSourceTitle({required Object name}) => '"${name}"을(를) 제거하시겠습니까?';
	@override String get removeSourceBody => '파일은 디스크에 그대로 남습니다. 이 라이브러리 항목만 제거됩니다.';
	@override String get remove => '제거';
	@override String get removeFolder => '폴더 제거';
	@override String get removeFolderSelectTitle => '제거할 폴더 선택';
	@override String get longPressToRemove => '길게 눌러 이 폴더 제거';
	@override String get clearProgress => '로컬 시청 기록 지우기';
	@override String clearProgressCount({required Object count}) => '${count}개 항목';
	@override String get clearProgressEmpty => '아직 로컬 시청 기록이 없습니다';
	@override String get clearProgressTitle => '로컬 시청 기록을 지우시겠습니까?';
	@override String get clearProgressBody => '재생 위치와 시청 표시만 삭제됩니다. 파일과 폴더는 그대로 유지됩니다.';
	@override String clearProgressDone({required Object count}) => '로컬 시청 기록 ${count}개를 지웠습니다';
	@override String get clearAction => '지우기';
	@override String get iosManualRescanNotice => 'iOS는 새 파일을 자동으로 감지하지 않습니다. 파일을 추가하거나 삭제한 후 수동으로 다시 검사해야 합니다.';
}

// Path: historyPage
class _TranslationsHistoryPageKo extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => '기록에서 삭제';
	@override String get removed => '기록에서 삭제했습니다';
	@override String watchedTo({required Object time}) => '${time}까지 시청';
	@override String get finished => '시청 완료';
	@override String clearTabTitle({required Object tab}) => '"${tab}" 지우기';
	@override String clearTabConfirm({required Object tab}) => '"${tab}"의 모든 기록과 해당 동영상의 시청 위치가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
	@override String get rangeByLastViewed => '마지막으로 본 시간 기준';
}

// Path: common.pagination
class _TranslationsCommonPaginationKo extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => '총 ${num}개';
	@override String get jumpToPage => '페이지로 이동';
	@override String pleaseEnterPageNumber({required Object max}) => '페이지 번호를 입력해 주세요(1-${max})';
	@override String get pageNumber => '페이지 번호';
	@override String get jump => '이동';
	@override String invalidPageNumber({required Object max}) => '올바른 페이지 번호를 입력해 주세요(1-${max})';
	@override String get invalidInput => '올바른 페이지 번호를 입력해 주세요';
	@override String get waterfall => '워터폴';
	@override String get pagination => '페이지';
}

// Path: errors.network
class _TranslationsErrorsNetworkKo extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => '네트워크 오류 - ';
	@override String get failedToConnectToServer => '서버에 연결하지 못했습니다';
	@override String get serverNotAvailable => '서버를 사용할 수 없음';
	@override String get requestTimeout => '요청 시간 초과';
	@override String get unexpectedError => '예기치 않은 오류';
	@override String get invalidResponse => '잘못된 응답';
	@override String get invalidRequest => '잘못된 요청';
	@override String get invalidUrl => '잘못된 URL';
	@override String get invalidMethod => '잘못된 메서드';
	@override String get invalidHeader => '잘못된 헤더';
	@override String get invalidBody => '잘못된 본문';
	@override String get invalidStatusCode => '잘못된 상태 코드';
	@override String get serverError => '서버 오류';
	@override String get requestCanceled => '요청이 취소되었습니다';
	@override String get invalidPort => '잘못된 포트';
	@override String get proxyPortError => '프록시 포트 오류';
	@override String get connectionRefused => '연결이 거부되었습니다';
	@override String get networkUnreachable => '네트워크에 연결할 수 없음';
	@override String get noRouteToHost => '호스트로 가는 경로 없음';
	@override String get connectionFailed => '연결 실패';
	@override String get sslConnectionFailed => 'SSL 연결 실패, 네트워크 설정을 확인해 주세요';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingKo extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '키보드 단축키';
	@override String get entryLabel => '키보드 단축키';
	@override String get entryDesc => '앱의 키보드 단축키를 사용자 지정합니다 (주로 데스크톱용)';
	@override String get desktopHint => '단축키는 주로 데스크톱 키보드에 적용되며, 모바일에서는 보통 제스처를 사용합니다.';
	@override String get resetAll => '모두 기본값으로 재설정';
	@override String get resetAllConfirm => '모든 앱 단축키를 기본값으로 재설정하시겠습니까?';
	@override String get resetToDefault => '기본값으로 재설정';
	@override String get resetScope => '이 섹션 재설정';
	@override String get notSet => '설정 안 됨';
	@override String get addShortcut => '단축키 추가';
	@override String get removeShortcut => '이 단축키 제거';
	@override String get pressNewShortcut => '새 단축키를 누르세요…';
	@override String get recordingCancelHint => 'Esc를 눌러 취소';
	@override String get mouseHint => '마우스 측면 버튼(뒤로/앞으로) 또는 가운데 버튼도 지정할 수 있습니다';
	@override String get mouseNotSupportedInScope => '이 영역은 마우스 버튼을 처리하지 않습니다. 대신 키보드를 사용하세요';
	@override String get capabilityKeyboardOnly => '이 영역은 키보드 키만 지원합니다';
	@override String get capabilityKeyboardAndMouse => '이 영역은 키보드 키와 마우스 가운데 및 측면 버튼을 지원합니다';
	@override String get capabilityKeyboardAndMouseMobile => '이 영역은 키보드 키와 마우스 가운데 및 앞으로 버튼을 지원합니다 (뒤로 버튼은 시스템이 사용합니다)';
	@override String get rejectMultipleButtons => '마우스 버튼은 한 번에 하나씩 누르세요';
	@override String get rejectPlatformBack => '시스템이 이미 뒤로 가기에 사용하고 있어 지정하면 두 번 뒤로 이동합니다';
	@override String get detectedLabel => '감지됨';
	@override String get reservedKey => '이 키는 시스템이 예약한 키라 지정할 수 없습니다';
	@override String reservedForGlobalBack({required Object action}) => '이 키는 "${action}"에 지정되어 있으며, 이 화면에서 나갈 수 있도록 여기서 예약된 상태로 유지됩니다';
	@override String get conflictTitle => '단축키 충돌';
	@override String conflictMessage({required Object action}) => '이 조합은 이미 "${action}"에 지정되어 있습니다. 계속하면 기존 지정이 제거됩니다.';
	@override String get conflictContinue => '그래도 지정';
	@override String get shadowWarningTitle => '전역 단축키 중복';
	@override String shadowWarningMessage({required Object action}) => '이 조합은 전역에서 "${action}"에 지정되어 있습니다. 여기에 지정하면 이 섹션 내에서만 해당 동작을 대체합니다.';
	@override String globalShadowedMessage({required Object scope, required Object action}) => '이 조합은 ${scope}에서 이미 "${action}"에 지정되어 있습니다. 해당 섹션에서는 이 전역 단축키가 그것으로 대체됩니다.';
	@override String get searchHint => '단축키 검색…';
	@override String get scopeGlobal => '전역';
	@override String get scopeGallery => '갤러리';
	@override String get scopeVideo => '동영상';
	@override String get categoryNavigation => '탐색';
	@override String get categoryZoom => '확대/축소';
	@override String get categoryPlayback => '재생';
	@override String get categorySeek => '탐색';
	@override String get categoryVolume => '볼륨';
	@override String get categoryDisplay => '표시';
	@override String get actionGlobalBack => '뒤로 가기';
	@override String get actionGalleryNext => '다음 사진';
	@override String get actionGalleryPrevious => '이전 사진';
	@override String get actionGalleryZoomIn => '확대';
	@override String get actionGalleryZoomOut => '축소';
	@override String get actionGalleryResetZoom => '확대/축소 초기화';
	@override String get actionGalleryPlayPause => '재생 / 일시정지';
	@override String get actionGallerySeekBackward => '되감기';
	@override String get actionGallerySeekForward => '빨리 감기';
	@override String get actionGalleryToggleMute => '음소거 전환';
	@override String get actionPlayPause => '재생 / 일시정지';
	@override String get actionSpeedUp => '속도 증가';
	@override String get actionSpeedDown => '속도 감소';
	@override String get actionSeekForward => '앞으로 탐색';
	@override String get actionSeekBackward => '뒤로 탐색';
	@override String get actionVolumeUp => '볼륨 높이기';
	@override String get actionVolumeDown => '볼륨 낮추기';
	@override String get actionToggleMute => '음소거 전환';
	@override String get actionToggleFullscreen => '전체 화면 전환';
	@override String get seekLongPressHint => '앞으로/뒤로 탐색 키를 길게 누르면 길게 누르기 배속 모드가 작동합니다';
	@override String get zoomSectionTitle => '화면 확대/축소 (고정)';
	@override String get zoomFixedNote => '아래 단축키는 고정되어 변경할 수 없습니다';
	@override String get zoomScaleLabel => '화면 확대';
	@override String get zoomScaleHint => 'Ctrl + 휠';
	@override String get zoomRotateLabel => '화면 회전';
	@override String get zoomRotateHint => 'Shift + 휠';
	@override String get zoomPinchGesture => '핀치';
	@override String get zoomTwoFingerRotateGesture => '두 손가락 회전';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsKo extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '포럼';
	@override String get configureYourForumSettings => '포럼 설정 구성';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsKo extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => '갤러리 설정';
	@override String get gallerySettingsSubtitle => '갤러리 뷰어 환경 설정';
	@override String get defaultViewerQuality => '기본 뷰어 화질';
	@override String get defaultViewerQualityDesc => '갤러리 뷰어를 열 때 기본으로 표시할 이미지 화질을 선택합니다.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsKo extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '콘텐츠 차단';
	@override String get subtitle => '제목이 키워드나 패턴과 일치하거나 차단된 사용자의 콘텐츠인 동영상과 갤러리를 자동으로 숨깁니다. 모든 일치 처리는 기기에서 이루어지며 아무것도 업로드되지 않습니다.';
	@override String get blocked => '차단됨';
	@override String get reveal => '표시';
	@override String get reblock => '다시 차단';
	@override String get why => '차단된 이유';
	@override String get manageRules => '규칙 관리';
	@override String reasonKeyword({required Object value}) => '제목에 "${value}" 포함';
	@override String reasonRegex({required Object value}) => '제목이 "${value}"과 일치';
	@override String get reasonUser => '차단된 사용자';
	@override String get addRule => '규칙 추가';
	@override String get editRule => '규칙 편집';
	@override String get deleteRule => '규칙 삭제';
	@override String get ruleType => '규칙 유형';
	@override String get keyword => '키워드';
	@override String get regex => '정규식';
	@override String get userId => '사용자';
	@override String get value => '일치할 텍스트';
	@override String get caseSensitive => '대소문자 구분';
	@override String get regexHint => '예: 예고|티저';
	@override String get valueRequired => '일치할 텍스트를 입력하세요';
	@override String get invalidRegex => '유효한 정규식이 아닙니다';
	@override String get noRules => '아직 규칙이 없습니다. +를 눌러 추가하세요.';
	@override String get blockUser => '차단';
	@override String get unblockUser => '차단 해제';
	@override String blockUserConfirm({required Object name}) => '"${name}"님을 차단하시겠습니까? 해당 사용자의 동영상과 갤러리가 목록과 검색에서 숨겨집니다.';
	@override String get userBlocked => '사용자를 차단했습니다';
	@override String get userUnblocked => '사용자 차단을 해제했습니다';
	@override String get exportRules => '내보내기';
	@override String get importRules => '가져오기';
	@override String get importExport => '가져오기 / 내보내기';
	@override String get exportSuccess => '규칙을 내보냈습니다';
	@override String get exportFailed => '규칙을 내보내지 못했습니다';
	@override String importSuccess({required Object count}) => '규칙 ${count}개를 가져왔습니다';
	@override String get importFailed => '규칙을 가져오지 못했습니다';
	@override String get regexHelp => '패턴 도움말';
	@override String get regexHelpTitle => '정규식 참고';
	@override String get regexHelpIntro => '정규식은 일반 키워드보다 제목을 더 유연하게 일치시킵니다. 몇 가지 일반적인 예시:';
	@override String get regexHelpTapHint => '예시를 탭하면 자동으로 입력됩니다.';
	@override String get regexEx1Pattern => '예고|티저|보너스';
	@override String get regexEx1Desc => '다음 단어 중 하나와 일치합니다 ("|"는 "또는"을 의미)';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => '대괄호로 시작하는 제목';
	@override String get regexEx3Pattern => '총집편\$';
	@override String get regexEx3Desc => '제목이 "총집편"으로 끝남';
	@override String get regexEx4Pattern => '제[0-9]+화';
	@override String get regexEx4Desc => '[0-9]+는 하나 이상의 숫자, "제12화"와 일치';
	@override String get regexEx5Pattern => '[0-9]{4}';
	@override String get regexEx5Desc => '[0-9]는 숫자, {4}는 4자리 연속을 의미합니다 (예: 연도)';
	@override String get regexEx1Sample => '신작 게임 티저 공개';
	@override String get regexEx2Sample => '[완결] 극장판';
	@override String get regexEx3Sample => '봄 아트 총집편';
	@override String get regexEx4Sample => '내 쇼 제12화 요약';
	@override String get regexEx5Sample => '2024 최고 하이라이트';
	@override String get regexHelpSampleLabel => '제목 예시';
	@override String get regexHelpMatchedTag => '차단 대상';
	@override String get regexHelpNoMatch => '일치 없음';
	@override String get regexEx6Pattern => '[완미]결';
	@override String get regexEx6Desc => '[완미]는 "완" 또는 "미" 중 한 글자, "완결"을 잡습니다';
	@override String get regexEx6Sample => '애니 완결 기념';
	@override String get regexEx7Pattern => '(예고|광고)영상';
	@override String get regexEx7Desc => '괄호 ()는 여러 단어를 묶습니다, "예고영상" 또는 "광고영상"과 일치';
	@override String get regexEx7Sample => '최신 광고영상';
	@override String get regexEx8Pattern => '예고(편)?';
	@override String get regexEx8Desc => '(편)?는 "편"이 있어도 없어도 됨, "예고" 또는 "예고편"과 일치';
	@override String get regexEx8Sample => '신작 예고 공개';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+는 하나 이상을 의미, ㅋ·ㅋㅋ·ㅋㅋㅋ와 일치';
	@override String get regexEx9Sample => '웃긴ㅋㅋ 동영상';
	@override String get regexEx10Pattern => '예고.*판';
	@override String get regexEx10Desc => '.*는 그 사이의 모든 문자와 일치합니다 — "예고 … 판"';
	@override String get regexEx10Sample => '예고 완전판 공개';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsKo extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '채팅';
	@override String get configureYourChatSettings => '채팅 설정 구성';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsKo extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => '다운로드 설정';
	@override String get enableDownloadNotifications => '다운로드 알림';
	@override String get enableDownloadNotificationsDescription => '단일 다운로드가 완료되거나 실패하면 시스템 알림을 표시합니다';
	@override String get notificationPermissionDenied => '알림 권한이 거부되었습니다. 인앱 알림은 계속 작동하지만, 시스템 알림을 사용하려면 설정에서 활성화하세요.';
	@override String get storagePermissionStatus => '저장소 권한 상태';
	@override String get accessPublicDirectoryNeedStoragePermission => '공용 디렉터리 접근에는 저장소 권한이 필요합니다';
	@override String get checkingPermissionStatus => '권한 상태 확인 중...';
	@override String get storagePermissionGranted => '저장소 권한 부여됨';
	@override String get storagePermissionNotGranted => '저장소 권한이 부여되지 않음';
	@override String get storagePermissionGrantSuccess => '저장소 권한 부여 성공';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => '저장소 권한 부여에 실패했지만 일부 기능은 제한될 수 있습니다';
	@override String get storagePermissionRationale => '선택한 폴더에 다운로드를 저장하려면 앱에 저장소 접근 권한이 필요합니다.\n\nAndroid 11 이상에서는 "모든 파일 접근" 권한을 의미하며, 이것이 없으면 파일은 대신 앱 비공개 폴더에 저장됩니다.';
	@override String get storagePermissionRationaleLegacy => '선택한 폴더에 다운로드를 저장하려면 앱에 저장소 접근 권한이 필요합니다.\n\n없으면 파일은 대신 앱 비공개 폴더에 저장됩니다.';
	@override String get grantStoragePermission => '저장소 권한 부여';
	@override String get customDownloadPath => '사용자 지정 다운로드 경로';
	@override String get customDownloadPathDescription => '활성화하면 다운로드한 파일의 저장 위치를 사용자 지정할 수 있습니다';
	@override String get customDownloadPathTip => '💡 팁: 공용 디렉터리(예: 다운로드 폴더) 선택에는 저장소 권한이 필요하므로 먼저 권장 경로를 사용하는 것이 좋습니다';
	@override String get androidWarning => 'Android 참고: 공용 디렉터리(예: 다운로드 폴더)를 선택하지 마세요. 접근 권한을 보장하려면 앱 전용 디렉터리를 사용하는 것이 좋습니다.';
	@override String get publicDirectoryPermissionTip => '⚠️ 알림: 공용 디렉터리를 선택하셨습니다. 정상적인 파일 다운로드를 위해서는 저장소 권한이 필요합니다';
	@override String get permissionRequiredForPublicDirectory => '공용 디렉터리에는 저장소 권한이 필요합니다';
	@override String get currentDownloadPath => '현재 다운로드 경로';
	@override String get actualDownloadPath => '실제 다운로드 경로';
	@override String get defaultAppDirectory => '기본 앱 디렉터리';
	@override String get permissionGranted => '부여됨';
	@override String get permissionRequired => '권한 필요';
	@override String get enableCustomDownloadPath => '사용자 지정 다운로드 경로 사용';
	@override String get disableCustomDownloadPath => '비활성화 시 앱 기본 경로 사용';
	@override String get customDownloadPathLabel => '사용자 지정 다운로드 경로';
	@override String get selectDownloadFolder => '다운로드 폴더 선택';
	@override String get recommendedPath => '권장 경로';
	@override String get selectFolder => '폴더 선택';
	@override String get filenameTemplate => '파일 이름 템플릿';
	@override String get filenameTemplateDescription => '다운로드한 파일의 이름 규칙을 사용자 지정하며 변수 치환을 지원합니다';
	@override String get videoFilenameTemplate => '동영상 파일 이름 템플릿';
	@override String get galleryFolderTemplate => '갤러리 폴더 템플릿';
	@override String get imageFilenameTemplate => '이미지 파일 이름 템플릿';
	@override String get resetToDefault => '기본값으로 재설정';
	@override String get supportedVariables => '지원되는 변수';
	@override String get supportedVariablesDescription => '파일 이름 템플릿에서 다음 변수를 사용할 수 있습니다:';
	@override String get copyVariable => '변수 복사';
	@override String get variableCopied => '변수가 복사되었습니다';
	@override String get warningPublicDirectory => '경고: 선택한 공용 디렉터리에 접근할 수 없을 수 있습니다. 앱 전용 디렉터리를 선택하는 것이 좋습니다.';
	@override String get downloadPathUpdated => '다운로드 경로가 업데이트되었습니다';
	@override String get selectPathFailed => '경로 선택에 실패했습니다';
	@override String get pickerAlreadyActive => '폴더 선택기가 이미 열려 있습니다';
	@override String get unsupportedStorageVolume => '지원되지 않는 저장 위치입니다. 기기 저장소나 SD 카드의 폴더를 선택하세요.';
	@override String get recommendedPathSet => '권장 경로로 설정됨';
	@override String get setRecommendedPathFailed => '권장 경로 설정에 실패했습니다';
	@override String get templateResetToDefault => '기본 템플릿으로 재설정';
	@override String get functionalTest => '기능 테스트';
	@override String get testInProgress => '테스트 중...';
	@override String get runTest => '테스트 실행';
	@override String get testDownloadPathAndPermissions => '다운로드 경로와 권한 설정이 제대로 작동하는지 테스트합니다';
	@override String get testResults => '테스트 결과';
	@override String get testCompleted => '테스트 완료';
	@override String get testMultisegmentDomain => '값 범위 검사(다중 세그먼트 / 초과 / 탈출 형태)';
	@override String get testMultisegmentPaths => '다중 세그먼트 구조 렌더링(issue #126)';
	@override String get testPassed => '개 항목 통과';
	@override String get testFailed => '테스트 실패';
	@override String get testStoragePermissionCheck => '저장소 권한 확인';
	@override String get testStoragePermissionGranted => '저장소 권한이 부여되었습니다';
	@override String get testStoragePermissionMissing => '저장소 권한이 없어 일부 기능이 제한될 수 있습니다';
	@override String get testPermissionCheckFailed => '권한 확인에 실패했습니다';
	@override String get testDownloadPathValidation => '다운로드 경로 검증';
	@override String get testPathValidationFailed => '경로 검증에 실패했습니다';
	@override String get testFilenameTemplateValidation => '파일 이름 템플릿 검증';
	@override String get testAllTemplatesValid => '모든 템플릿이 유효합니다';
	@override String get testSomeTemplatesInvalid => '일부 템플릿에 유효하지 않은 문자가 있습니다';
	@override String get testTemplateValidationFailed => '템플릿 검증에 실패했습니다';
	@override String get testDirectoryOperationTest => '디렉터리 작업 테스트';
	@override String get testDirectoryOperationNormal => '디렉터리 생성과 파일 쓰기가 정상입니다';
	@override String get testDirectoryOperationFailed => '디렉터리 작업에 실패했습니다';
	@override String get testVideoTemplate => '동영상 템플릿';
	@override String get testGalleryTemplate => '갤러리 템플릿';
	@override String get testImageTemplate => '이미지 템플릿';
	@override String get testValid => '유효함';
	@override String get testInvalid => '유효하지 않음';
	@override String get testSuccess => '성공';
	@override String get testCorrect => '정상';
	@override String get testError => '오류';
	@override String get testPath => '테스트 경로';
	@override String get testBasePath => '기본 경로';
	@override String get testDirectoryCreation => '디렉터리 생성';
	@override String get testFileWriting => '파일 쓰기';
	@override String get testFileContent => '파일 내용';
	@override String get checkingPathStatus => '경로 상태 확인 중...';
	@override String get unableToGetPathStatus => '경로 상태를 가져올 수 없습니다';
	@override String get actualPathDifferentFromSelected => '참고: 실제 경로가 선택한 경로와 다릅니다';
	@override String get grantPermission => '권한 부여';
	@override String get fixIssue => '문제 수정';
	@override String get issueFixed => '문제가 수정되었습니다';
	@override String get fixFailed => '수정에 실패했습니다. 수동으로 처리해 주세요';
	@override String get lackStoragePermission => '저장소 권한이 없습니다';
	@override String get cannotAccessPublicDirectory => '공용 디렉터리에 접근할 수 없습니다. "모든 파일 접근 권한"이 필요합니다';
	@override String get cannotCreateDirectory => '디렉터리를 만들 수 없습니다';
	@override String get directoryNotWritable => '디렉터리에 쓸 수 없습니다';
	@override String get insufficientSpace => '사용 가능한 공간이 부족합니다';
	@override String get pathValid => '경로가 유효합니다';
	@override String get validationFailed => '검증에 실패했습니다';
	@override String get usingDefaultAppDirectory => '기본 앱 디렉터리 사용 중';
	@override String get appPrivateDirectory => '앱 비공개 디렉터리';
	@override String get appPrivateDirectoryDesc => '안전하고 신뢰할 수 있으며 추가 권한이 필요하지 않습니다';
	@override String get downloadDirectory => '다운로드 디렉터리';
	@override String get downloadDirectoryDesc => '시스템 기본 다운로드 위치로 관리하기 쉽습니다';
	@override String get moviesDirectory => '동영상 디렉터리';
	@override String get moviesDirectoryDesc => '시스템 동영상 디렉터리로 미디어 앱에서 인식할 수 있습니다';
	@override String get documentsDirectory => '문서 디렉터리';
	@override String get documentsDirectoryDesc => 'iOS 앱 문서 디렉터리';
	@override String get requiresStoragePermission => '접근하려면 저장소 권한이 필요합니다';
	@override String get recommendedPaths => '권장 경로';
	@override String get externalAppPrivateDirectory => '외부 앱 비공개 디렉터리';
	@override String get externalAppPrivateDirectoryDesc => '외부 저장소 앱 비공개 디렉터리로 사용자가 접근할 수 있고 공간이 더 큽니다';
	@override String get internalAppPrivateDirectory => '내부 앱 비공개 디렉터리';
	@override String get internalAppPrivateDirectoryDesc => '앱 내부 저장소로 권한이 필요하지 않지만 공간이 더 작습니다';
	@override String get appDocumentsDirectory => '앱 문서 디렉터리';
	@override String get appDocumentsDirectoryDesc => '앱 전용 문서 디렉터리로 안전하고 신뢰할 수 있습니다';
	@override String get downloadsFolder => '다운로드 폴더';
	@override String get downloadsFolderDesc => '시스템 기본 다운로드 디렉터리';
	@override String get selectRecommendedDownloadLocation => '권장 다운로드 위치 선택';
	@override String get noRecommendedPaths => '사용 가능한 권장 경로가 없습니다';
	@override String get recommended => '권장';
	@override String get requiresPermission => '권한 필요';
	@override String get authorizeAndSelect => '권한 부여 및 선택';
	@override String get select => '선택';
	@override String get permissionAuthorizationFailed => '권한 승인에 실패했습니다. 이 경로를 선택할 수 없습니다';
	@override String get pathValidationFailed => '경로 검증에 실패했습니다';
	@override String get downloadPathSetTo => '다운로드 경로가 다음으로 설정됨';
	@override String get setPathFailed => '경로 설정에 실패했습니다';
	@override String get variableTitle => '제목';
	@override String get variableAuthorcache => '작성자 첫 이름(이름이 바뀌어도 유지)';
	@override String get variableAuthor => '작성자 이름';
	@override String get variableUsername => '작성자 사용자 이름';
	@override String get variableQuality => '동영상 화질';
	@override String get variableFilename => '원래 파일 이름';
	@override String get variableId => '콘텐츠 ID';
	@override String get variableCount => '갤러리 이미지 수';
	@override String get variableDate => '현재 날짜 (YYYY-MM-DD)';
	@override String get variableTime => '현재 시간 (HH-MM-SS)';
	@override String get variableDatetime => '현재 날짜 시간 (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => '다운로드 설정';
	@override String get downloadSettingsSubtitle => '다운로드 경로와 파일 이름 규칙을 설정합니다';
	@override String get suchAsTitleQuality => '예: %title_%quality';
	@override String get suchAsTitleId => '예: %title_%id';
	@override String get suchAsTitleFilename => '예: %title_%filename';
	@override String get structureSection => '저장 구조와 이름 설정';
	@override String get structureSectionDescription => '다운로드한 파일은 아래에서 선택한 방식에 따라 하위 폴더로 자동 정리됩니다. 이후 새 다운로드에만 적용되며 기존 파일은 그대로 유지됩니다.';
	@override String get structureNoticeTitle => '신규 기능: 작성자별 자동 정리';
	@override String get structureNoticeBody => '아래에서 선택하세요 · 새 다운로드에만 적용되고 기존 파일은 그대로입니다.';
	@override String get presetFlat => '플랫';
	@override String get presetFlatDesc => '모든 파일을 다운로드 루트에 바로 저장';
	@override String get presetAuthor => '작성자별';
	@override String get presetAuthorBadge => '추천';
	@override String get presetAuthorDesc => '작성자별 폴더로 정리 · 이름이 바뀌어도 유지';
	@override String get presetDate => '날짜별';
	@override String get presetDateDesc => '다운로드 날짜별로 정리';
	@override String get presetCustom => '사용자 지정';
	@override String get presetCustomDesc => '경로 템플릿을 자유롭게 편집';
	@override String get presetCustomHint => '사용자 지정: 경로 템플릿 편집기에서 수정하세요';
	@override String get structurePreviewLabel => '미리보기';
	@override String get structurePreviewNote => '색상 부분이 정리 계층이며 선택한 방식에 따라 바뀝니다.';
	@override String get pathTooLongWarning => '상대 경로가 200자를 초과하여 일부 기기에서는 저장이 실패할 수 있습니다';
	@override String get pathTemplateEditorEntry => '사용자 지정 경로 템플릿';
	@override String get pathTemplateEditorEntryDesc => '폴더 구조와 파일 이름을 직접 결정';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorKo pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorKo._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesKo extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get hot => '인기';
	@override String get favorites => '즐겨찾기';
	@override String get latest => '최신';
	@override String get popularity => '인기순';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsKo extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => '요청에 실패했습니다. 상태 코드';
	@override String get connectionTimeout => '연결 시간이 초과되었습니다. 네트워크 연결을 확인해 주세요';
	@override String get sendTimeout => '요청 전송 시간이 초과되었습니다';
	@override String get receiveTimeout => '응답 수신 시간이 초과되었습니다';
	@override String get badCertificate => '인증서 검증에 실패했습니다';
	@override String get resourceNotFound => '요청한 리소스를 찾을 수 없습니다';
	@override String get accessDenied => '액세스가 거부되었습니다. 인증 또는 권한이 필요할 수 있습니다';
	@override String get serverError => '서버 내부 오류';
	@override String get serviceUnavailable => '서비스를 일시적으로 사용할 수 없습니다';
	@override String get requestCancelled => '요청이 취소되었습니다';
	@override String get connectionError => '네트워크 연결 오류입니다. 네트워크 설정을 확인해 주세요';
	@override String get networkRequestFailed => '네트워크 요청에 실패했습니다';
	@override String get searchVideoError => '동영상을 검색하는 중 알 수 없는 오류가 발생했습니다';
	@override String get getPopularVideoError => '인기 동영상을 가져오는 중 알 수 없는 오류가 발생했습니다';
	@override String get getVideoDetailError => '동영상 세부 정보를 가져오는 중 알 수 없는 오류가 발생했습니다';
	@override String get parseVideoDetailError => '동영상 세부 정보를 가져와 분석하는 중 알 수 없는 오류가 발생했습니다';
	@override String get downloadFileError => '파일을 다운로드하는 중 알 수 없는 오류가 발생했습니다';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingKo extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => '동영상 정보를 가져오는 중...';
	@override String get cancel => '취소';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesKo extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => '동영상을 찾을 수 없거나 삭제되었습니다';
	@override String get unableToGetVideoPlayLink => '동영상 재생 링크를 가져올 수 없습니다';
	@override String get getVideoDetailFailed => '동영상 세부 정보를 가져오지 못했습니다';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoKo extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => '동영상 정보';
	@override String get currentQuality => '현재 화질';
	@override String get duration => '길이';
	@override String get resolution => '해상도';
	@override String get fileInfo => '파일 정보';
	@override String get fileName => '파일 이름';
	@override String get fileSize => '파일 크기';
	@override String get filePath => '파일 경로';
	@override String get copyPath => '경로 복사';
	@override String get openFolder => '폴더 열기';
	@override String get pathCopiedToClipboard => '경로가 클립보드에 복사되었습니다';
	@override String get openFolderFailed => '폴더를 열지 못했습니다';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideKo extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => '샘플 영상';
	@override String get title => '제스처 및 조작 가이드';
	@override String get viewGuide => '제스처 및 조작 가이드';
	@override String get firstTimeIntro => '플레이어 제스처를 익히는 데 몇 초만 투자하세요. 이 가이드는 플레이어 설정에서 언제든 다시 열 수 있습니다.';
	@override String get startWatching => '알겠습니다, 시청 시작';
	@override String get basicTitle => '기본 조작';
	@override String get zoomTitle => '확대 / 회전 / 이동';
	@override String get restoreTip => '오른쪽 아래의 "복원" 버튼을 탭하여 확대, 회전, 위치를 초기화하세요.';
	@override String get mTap => '한 번 탭: 컨트롤 표시 / 숨기기';
	@override String get mDoubleTap => '두 번 탭: 되감기(왼쪽) / 일시정지(가운데) / 빨리 감기(오른쪽)';
	@override String get mHorizontalDrag => '가로 스와이프: 탐색';
	@override String get mVerticalDrag => '세로 스와이프: 밝기(왼쪽) / 볼륨(오른쪽)';
	@override String get mLongPress => '길게 누르기: 임시 빨리 감기';
	@override String get mPinch => '두 손가락 핀치: 화면 확대/축소';
	@override String get mRotate => '두 손가락 회전: 화면 회전';
	@override String get dTap => '클릭: 컨트롤 표시 / 숨기기';
	@override String get dDoubleTap => '더블 클릭: 되감기(왼쪽) / 일시정지(가운데) / 빨리 감기(오른쪽)';
	@override String get dKeys => '탐색 키: 탭하여 뒤로/앞으로 이동, 길게 누르면 빨라짐; 속도 키: 일반 재생 중 재생 속도 단계 조절; Space: 재생 / 일시정지';
	@override String get dTrackpadPinch => '트랙패드 핀치: 화면 확대/축소';
	@override String get dTrackpadRotate => '트랙패드 회전: 화면 회전';
	@override String get dCtrlWheel => 'Ctrl + 휠: 커서 위치를 중심으로 확대/축소';
	@override String get dShiftWheel => 'Shift + 휠: 커서 위치를 중심으로 회전';
	@override late final _TranslationsVideoDetailGestureGuideQuestKo quest = _TranslationsVideoDetailGestureGuideQuestKo._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerKo extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => '동영상 소스를 불러오는 중 오류';
	@override String get errorWhileSettingUpListeners => '리스너를 설정하는 중 오류';
	@override String get serverFaultDetectedAutoSwitched => '서버 오류가 감지되어 경로를 자동으로 전환하고 다시 시도합니다';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonKo extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => '동영상 정보 가져오는 중...';
	@override String get fetchingVideoSources => '동영상 소스 가져오는 중...';
	@override String get loadingVideo => '동영상 불러오는 중...';
	@override String get applyingSolution => '해결 방법 적용 중...';
	@override String get addingListeners => '리스너 추가 중...';
	@override String get successFecthVideoDurationInfo => '동영상 길이를 가져왔습니다. 동영상 로드를 시작합니다...';
	@override String get successFecthVideoHeightInfo => '로딩 완료';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastKo extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => '캐스트';
	@override String unableToStartCastingSearch({required Object error}) => '캐스트 검색을 시작하지 못했습니다: ${error}';
	@override String startCastingTo({required Object deviceName}) => '${deviceName}(으)로 캐스트 시작';
	@override String castFailed({required Object error}) => '캐스트 실패: ${error}\n기기를 다시 검색하거나 네트워크를 전환해 보세요';
	@override String get castStopped => '캐스트가 중지되었습니다';
	@override late final _TranslationsVideoDetailCastDeviceTypesKo deviceTypes = _TranslationsVideoDetailCastDeviceTypesKo._(_root);
	@override String get currentPlatformNotSupported => '현재 플랫폼은 캐스트를 지원하지 않습니다';
	@override String get unableToGetVideoUrl => '동영상 URL을 가져올 수 없습니다. 나중에 다시 시도해 주세요';
	@override String get stopCasting => '캐스트 중지';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetKo dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetKo._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsKo extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => '몰래 좋아요를 누른 사람';
	@override String get dialogDescription => '누가 좋아하는지 궁금하신가요? 이 "좋아요 앨범"을 넘겨 보세요~';
	@override String get closeTooltip => '닫기';
	@override String get retry => '다시 시도';
	@override String get noLikesYet => '아직 아무도 나타나지 않았습니다. 첫 번째가 되어 보세요!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => '페이지 ${page} / ${totalPages} · 총 ${totalCount}명';
	@override String get prevPage => '이전 페이지';
	@override String get nextPage => '다음 페이지';
}

// Path: forum.sitewide
class _TranslationsForumSitewideKo extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get badge => '전체 공지';
	@override String get title => '전체 공지';
	@override String get readMore => '더 보기';
}

// Path: forum.errors
class _TranslationsForumErrorsKo extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => '카테고리를 선택해 주세요';
	@override String get threadLocked => '이 스레드는 잠겨 있어 답글을 달 수 없습니다';
}

// Path: forum.groups
class _TranslationsForumGroupsKo extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get administration => '관리';
	@override String get global => '글로벌';
	@override String get chinese => '중국어';
	@override String get japanese => '일본어';
	@override String get korean => '한국어';
	@override String get other => '기타';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesKo extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get announcements => '공지';
	@override String get feedback => '피드백';
	@override String get support => '지원';
	@override String get general => '일반';
	@override String get guides => '가이드';
	@override String get questions => '질문';
	@override String get requests => '요청';
	@override String get sharing => '공유';
	@override String get general_zh => '일반';
	@override String get questions_zh => '질문';
	@override String get requests_zh => '요청';
	@override String get support_zh => '지원';
	@override String get general_ja => '일반';
	@override String get questions_ja => '질문';
	@override String get requests_ja => '요청';
	@override String get support_ja => '지원';
	@override String get korean => '한국어';
	@override String get other => '기타';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsKo extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get announcements => '공식 중요 알림 및 공지';
	@override String get feedback => '웹사이트 기능과 서비스에 대한 피드백';
	@override String get support => '웹사이트 관련 문제 해결 지원';
	@override String get general => '모든 주제에 대해 토론';
	@override String get guides => '경험과 튜토리얼 공유';
	@override String get questions => '질문을 남기세요';
	@override String get requests => '요청을 올리세요';
	@override String get sharing => '흥미로운 콘텐츠 공유';
	@override String get general_zh => '모든 주제에 대해 토론';
	@override String get questions_zh => '질문을 남기세요';
	@override String get requests_zh => '요청을 올리세요';
	@override String get support_zh => '웹사이트 관련 문제 해결 지원';
	@override String get general_ja => '모든 주제에 대해 토론';
	@override String get questions_ja => '질문을 남기세요';
	@override String get requests_ja => '요청을 올리세요';
	@override String get support_ja => '웹사이트 관련 문제 해결 지원';
	@override String get korean => '한국어 관련 토론';
	@override String get other => '기타 분류되지 않은 콘텐츠';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsKo extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => '지원되지 않는 알림 유형';
	@override String get unknownUser => '알 수 없는 사용자';
	@override String unsupportedNotificationTypeWithType({required Object type}) => '지원되지 않는 알림 유형: ${type}';
	@override String get unknownNotificationType => '알 수 없는 알림 유형';
}

// Path: conversation.errors
class _TranslationsConversationErrorsKo extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => '사용자를 선택해 주세요';
	@override String get pleaseEnterATitle => '제목을 입력해 주세요';
	@override String get clickToSelectAUser => '클릭하여 사용자 선택';
	@override String get loadFailedClickToRetry => '불러오기 실패, 클릭하여 재시도';
	@override String get loadFailed => '불러오기 실패';
	@override String get clickToRetry => '클릭하여 재시도';
	@override String get noMoreConversations => '더 이상 대화가 없습니다';
}

// Path: splash.errors
class _TranslationsSplashErrorsKo extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => '초기화에 실패했습니다. 앱을 다시 시작해 주세요';
}

// Path: download.errors
class _TranslationsDownloadErrorsKo extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => '이미지 모델을 찾을 수 없습니다';
	@override String get downloadFailed => '다운로드 실패';
	@override String get videoInfoNotFound => '동영상 정보를 찾을 수 없습니다';
	@override String get downloadTaskAlreadyExists => '다운로드 작업이 이미 존재합니다';
	@override String get downloadTaskSavePathConflict => '저장 경로가 이미 다른 작업에서 사용 중입니다';
	@override String get videoAlreadyDownloaded => '동영상이 이미 다운로드되었습니다';
	@override String downloadFailedForMessage({required Object errorInfo}) => '다운로드 작업 추가 실패: ${errorInfo}';
	@override String get userPausedDownload => '사용자가 다운로드를 일시정지했습니다';
	@override String get unknown => '알 수 없음';
	@override String fileSystemError({required Object errorInfo}) => '파일 시스템 오류: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => '알 수 없는 오류: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => '파일 쓰기 실패: ${errorInfo}';
	@override String get connectionTimeout => '연결 시간 초과';
	@override String get sendTimeout => '전송 시간 초과';
	@override String get receiveTimeout => '수신 시간 초과';
	@override String serverError({required Object errorInfo}) => '서버 오류: ${errorInfo}';
	@override String get unknownNetworkError => '알 수 없는 네트워크 오류';
	@override String get sslHandshakeFailed => 'SSL 핸드셰이크 실패, 네트워크를 확인해 주세요';
	@override String get connectionFailed => '연결에 실패했습니다. 네트워크를 확인해 주세요';
	@override String get serviceIsClosing => '다운로드 서비스가 종료 중입니다';
	@override String get partialDownloadFailed => '부분 콘텐츠 다운로드 실패';
	@override String get noDownloadTask => '다운로드 작업이 없습니다';
	@override String get taskNotFoundOrDataError => '작업을 찾을 수 없거나 데이터 오류입니다';
	@override String get fileNotFound => '파일을 찾을 수 없습니다';
	@override String get openFolderFailed => '폴더를 열지 못했습니다';
	@override String get copyDownloadUrlFailed => '다운로드 URL을 복사하지 못했습니다';
	@override String openFolderFailedWithMessage({required Object message}) => '폴더를 열지 못했습니다: ${message}';
	@override String get directoryNotFound => '디렉터리를 찾을 수 없습니다';
	@override String get copyFailed => '복사 실패';
	@override String get openFileFailed => '파일을 열지 못했습니다';
	@override String openFileFailedWithMessage({required Object message}) => '파일을 열지 못했습니다: ${message}';
	@override String get playLocallyFailed => '로컬 재생 실패';
	@override String playLocallyFailedWithMessage({required Object message}) => '로컬 재생 실패: ${message}';
	@override String get noDownloadSource => '다운로드 소스가 없습니다';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => '다운로드 소스가 없습니다. 정보 로딩이 완료될 때까지 기다린 후 다시 시도해 주세요';
	@override String get noActiveDownloadTask => '활성 다운로드 작업이 없습니다';
	@override String get noFailedDownloadTask => '실패한 다운로드 작업이 없습니다';
	@override String get noCompletedDownloadTask => '완료된 다운로드 작업이 없습니다';
	@override String get taskAlreadyCompletedDoNotAdd => '작업이 이미 완료되었습니다. 다시 추가하지 마세요';
	@override String get linkExpiredTryAgain => '링크가 만료되어 새 다운로드 링크를 가져오는 중입니다';
	@override String get linkExpiredTryAgainSuccess => '링크 만료, 새 다운로드 링크 가져오기 성공';
	@override String get linkExpiredTryAgainFailed => '링크 만료, 새 다운로드 링크 가져오기 실패';
	@override String get taskDeleted => '작업이 삭제되었습니다';
	@override String unsupportedImageFormat({required Object format}) => '지원하지 않는 이미지 형식: ${format}';
	@override String get deleteFileError => '파일을 삭제하지 못했습니다. 다른 프로세스에서 파일을 사용 중일 수 있습니다';
	@override String get deleteTaskError => '작업을 삭제하지 못했습니다';
	@override String get canNotRefreshVideoTask => '동영상 작업을 새로 고치지 못했습니다';
	@override String get videoRemovedCanNotRefresh => '이 동영상이 삭제되었거나 더 이상 존재하지 않아 다운로드 링크를 새로 고칠 수 없습니다';
	@override String get videoInaccessibleCanNotRefresh => '이 동영상에 접근할 수 없습니다. 비공개이거나 다시 로그인해야 할 수 있습니다';
	@override String get videoQualityGone => '이 화질은 더 이상 제공되지 않습니다. 다운로드를 다시 추가해 주세요';
	@override String get refreshLinkNetworkFailed => '네트워크 오류로 지금은 다운로드 링크를 새로 고칠 수 없습니다. 나중에 다시 시도해 주세요';
	@override String get taskAlreadyProcessing => '작업이 이미 처리 중입니다';
	@override String get taskNotFound => '작업을 찾을 수 없습니다';
	@override String get failedToLoadTasks => '작업을 불러오지 못했습니다';
	@override String partialDownloadFailedWithMessage({required Object message}) => '부분 다운로드 실패: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => '지원하지 않는 이미지 형식: ${extension}. 기기에 다운로드하여 확인해 보세요';
	@override String get imageLoadFailed => '이미지를 불러오지 못했습니다';
	@override String get pleaseTryOtherViewer => '다른 뷰어로 열어 보세요';
}

// Path: download.timeline
class _TranslationsDownloadTimelineKo extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get today => '오늘';
	@override String get yesterday => '어제';
	@override String get thisWeek => '이번 주';
	@override String get thisMonth => '이번 달';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesKo extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get network => '네트워크 문제, 재시도하면 해결될 수 있습니다';
	@override String get serverRejected => '서버에서 거부했습니다. 다시 로그인해야 할 수 있습니다';
	@override String get notFound => '리소스가 사라졌거나 삭제되었습니다';
	@override String get diskFull => '저장 공간이 부족합니다';
	@override String get fileInUse => '다른 프로그램에서 파일을 사용 중입니다';
	@override String get permission => '쓰기 권한이 없습니다';
	@override String get cancelled => '취소됨';
	@override String get unknown => '알 수 없는 오류';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedKo extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '지난 세션의 미완료 작업 ${num}개가 일시정지되었습니다';
	@override String get resume => '모두 재개';
	@override String get dismiss => '닫기';
}

// Path: download.actions
class _TranslationsDownloadActionsKo extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeKo extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateKo extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => '날짜로 삭제';
	@override String get dialogTitle => '날짜로 삭제';
	@override String get description => '생성 날짜별로 다운로드 작업을 일괄 삭제합니다. 파일이 사용 중인 작업은 건너뛰고, 파일이 더 이상 없는 작업은 정리됩니다.';
	@override String get modeRange => '날짜 범위';
	@override String get modeDays => '다음보다 오래된';
	@override String get startDate => '시작일';
	@override String get endDate => '종료일';
	@override String get notSet => '설정 안 됨';
	@override String get daysUnit => '일';
	@override String olderThanDaysHint({required Object days}) => '${days}일보다 오래 전에 생성된 작업 삭제';
	@override String get noMatch => '선택한 조건에 맞는 작업이 없습니다';
	@override String get invalidRange => '시작일은 종료일과 같거나 그보다 앞서야 합니다';
	@override String get confirmTitle => '삭제 확인';
	@override String confirmContent({required Object count}) => '${count}개의 다운로드 작업과 해당 파일을 삭제하시겠습니까? 되돌릴 수 없습니다.';
	@override String deleting({required Object done, required Object total}) => '삭제 중 ${done}/${total}…';
	@override String resultSuccess({required Object count}) => '${count}개 작업 삭제됨';
	@override String resultPartial({required Object deleted, required Object skipped}) => '${deleted}개 작업 삭제됨, ${skipped}개 건너뜀(사용 중)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationKo extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryKo extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => '카테고리 관리';
	@override String get label => '카테고리';
	@override String get uncategorized => '미분류';
	@override String get manage => '관리';
	@override String get createShortcut => '새로 만들기';
	@override String get newCategoryHint => '새 카테고리 이름';
	@override String get createSuccess => '카테고리 생성됨';
	@override String get createFailed => '카테고리 생성 실패';
	@override String get nameEmpty => '카테고리 이름은 비워 둘 수 없습니다';
	@override String get emptyHint => '아직 카테고리가 없습니다. 다운로드를 정리할 카테고리를 만들어 보세요.';
	@override String get moveTo => '카테고리로 이동';
	@override String moveToWithCount({required Object count}) => '${count}개 항목 이동…';
	@override String moveSuccess({required Object title}) => '${title}(으)로 이동됨';
	@override String get moveToUncategorizedSuccess => '미분류로 이동됨';
	@override String get moveFailed => '이동 실패';
	@override String get renameTitle => '카테고리 이름 변경';
	@override String get renameHint => '카테고리 이름 입력';
	@override String get renameSuccess => '카테고리 이름 변경됨';
	@override String get renameFailed => '카테고리 이름 변경 실패';
	@override String get deleteTitle => '카테고리 삭제';
	@override String deleteConfirm({required Object title, required Object count}) => '"${title}" 카테고리를 삭제하시겠습니까? 안에 있는 ${count}개 항목은 미분류로 이동합니다. 파일은 삭제되지 않습니다.';
	@override String get deleteSuccess => '카테고리 삭제됨';
	@override String get deleteFailed => '카테고리 삭제 실패';
}

// Path: download.location
class _TranslationsDownloadLocationKo extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadKo extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '일괄 다운로드';
	@override String get downloadTaskAlreadyRunning => '이미 작업이 실행 중입니다. 잠시 기다려 주세요.';
	@override String get userCancelled => '사용자 취소';
	@override String get failedToGetVideoInfo => '동영상 정보를 가져오지 못했습니다';
	@override String get failedToGetVideoSource => '동영상 소스를 가져오지 못했습니다';
	@override String get failedToGetGalleryInfo => '갤러리 정보를 가져오지 못했습니다';
	@override String get galleryNoImages => '갤러리에 이미지가 없습니다';
	@override String get failedToGetSavePath => '저장 경로를 가져오지 못했습니다';
	@override String batchDownloadFailedWithException({required Object exception}) => '일괄 다운로드 실패: ${exception}';
	@override String get selectQuality => '화질 선택';
	@override String get downloading => '다운로드 중';
	@override String get downloadResult => '다운로드 결과';
	@override String selectedVideosCount({required Object count}) => '동영상 ${count}개 선택됨';
	@override String selectedGalleriesCount({required Object count}) => '갤러리 ${count}개 선택됨';
	@override String get qualityNote => '선택한 화질을 사용할 수 없으면 최상의 사용 가능한 화질이 사용됩니다';
	@override String progress({required Object current, required Object total}) => '처리 중 ${current}/${total}';
	@override String get queued => '대기 중';
	@override String get success => '성공';
	@override String get skipped => '건너뜀';
	@override String get failed => '실패';
	@override String get failureDetails => '실패 세부 정보';
	@override String get reasonPrivateVideo => '비공개 동영상';
	@override String get reasonAlreadyExists => '이미 존재함';
	@override String get reasonNoSource => '다운로드 소스 없음';
	@override String get reasonNoSavePath => '저장 경로를 가져올 수 없음';
	@override String get reasonOther => '기타 오류';
	@override String get startDownload => '다운로드 시작';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsKo extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get addFailed => '추가 실패';
	@override String get addSuccess => '추가 성공';
	@override String get deleteFolderFailed => '폴더 삭제 실패';
	@override String get deleteFolderSuccess => '폴더 삭제 성공';
	@override String get folderNameCannotBeEmpty => '폴더 이름은 비워 둘 수 없습니다';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesKo extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI 추론 (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude 추론 (확장 사고)';
	@override String get gemini => 'Google Gemini (네이티브)';
	@override String get geminiReasoning => 'Google Gemini 추론 (사고)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek 추론 (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeKo extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => '재생 알림: ${message}';
	@override String get networkUnstable => '네트워크를 확인하세요. 재생이 끊길 수 있습니다';
	@override String get audioTrackUnavailable => '사용 가능한 소리가 없습니다. 동영상은 계속 재생됩니다';
	@override String get hardwareDecodeFellBack => '소프트웨어 디코딩으로 전환했습니다. 전력을 더 사용할 수 있습니다';
	@override String get videoDecodeProblem => '다른 화질을 시도해 보세요. 화면이 깨질 수 있습니다';
	@override String get repeatedPlaybackProblems => '반복되는 재생 문제를 신고하려면 로그를 내보내세요';
	@override String get issuesSheetTitle => '재생 문제';
	@override String issueOccurrences({required Object count}) => '${count}회 발생';
	@override String issueAtPosition({required Object position}) => '${position} 지점';
	@override String get noIssuesRecorded => '기록된 문제가 없습니다';
	@override String get exportLogsAction => '로그 내보내기';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertKo extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => '플러시 실패';
	@override String get sinkDegradedTitle => '로그 쓰기 성능 저하';
	@override String get sinkDegradedDetail => '파일 싱크가 성능 저하 상태입니다';
	@override String get queueBacklogTitle => '쓰기 큐 적체';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (임계값=${threshold}, 메모리 사용량이 늘어날 수 있음)';
	@override String get highFlushLatencyTitle => '플러시 지연 높음';
	@override String get droppedTooManyTitle => '너무 많은 로그가 누락됨';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (임계값=${threshold})';
	@override String get rateLimitedTitle => '속도 제한 발동';
	@override String get exportFailedTitle => '로그 내보내기 실패';
	@override String get fileNearLimitTitle => '로그 파일이 크기 제한에 근접';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (IO 로테이션 부담 증가)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastKo extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => '로그 서비스가 초기화되지 않았습니다';
	@override String get exportSuccess => '로그를 내보냈습니다. 이메일로 보내기 전에 개인정보 데이터를 검토하세요.';
	@override String exportFailed({required Object error}) => '내보내기 실패: ${error}';
	@override String get supportEmailCopied => '지원 이메일이 복사되었습니다. 메일 클라이언트에 붙여 넣고 로그를 첨부하세요.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesKo extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get relevance => '관련도';
	@override String get latest => '최신';
	@override String get views => '조회수';
	@override String get likes => '좋아요';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeKo extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '환영합니다';
	@override String get subtitle => '맞춤 설정 여정을 시작해 볼까요';
	@override String get description => '몇 단계만 거치면 최적의 환경을 맞춤 설정할 수 있습니다';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicKo extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '기본 설정';
	@override String get subtitle => '환경을 개인화하세요';
	@override String get description => '나에게 맞는 설정을 선택하세요';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkKo extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '네트워크 설정';
	@override String get subtitle => '네트워크 옵션 구성';
	@override String get description => '네트워크 환경에 맞게 조정하세요';
	@override String get tip => '구성 성공 후 적용하려면 재시작이 필요합니다';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeKo extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '테마 설정';
	@override String get subtitle => '원하는 화면 모양을 선택하세요';
	@override String get description => '시각 경험을 개인화하세요';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerKo extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '플레이어 설정';
	@override String get subtitle => '재생 컨트롤 구성';
	@override String get description => '자주 사용하는 재생 설정을 빠르게 지정하세요';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialKo extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '공간 재생';
	@override String get subtitle => '헤드셋에서 시청 및 탐색';
	@override String get description => '헤드셋에서는 동영상과 갤러리가 이 떠 있는 패널 안이 아니라 주변 공간에 표시됩니다';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionKo extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '설정 완료';
	@override String get subtitle => '이제 여정을 시작할 준비가 되었습니다';
	@override String get description => '관련 약관을 읽고 동의해 주세요';
	@override String get agreementTitle => '사용자 약관 및 커뮤니티 규칙';
	@override String get agreementDesc => '이 앱을 사용하기 전에 사용자 약관과 커뮤니티 규칙을 주의 깊게 읽고 동의해 주세요. 이러한 약관은 좋은 환경을 유지하는 데 도움이 됩니다.';
	@override String get checkboxTitle => '사용자 약관과 커뮤니티 규칙을 읽었으며 이에 동의합니다';
	@override String get checkboxSubtitle => '동의하지 않으면 앱을 사용할 수 없습니다';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonKo extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => '이 설정은 언제든지 설정에서 변경할 수 있습니다';
	@override String get previousStep => '이전 단계';
	@override String get nextStep => '다음 단계';
	@override String get finishSetup => '설정 완료';
	@override String get agreeAgreementSnackbar => '먼저 사용자 약관과 커뮤니티 규칙에 동의해 주세요';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsKo extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get highQuality => '고품질';
	@override String get fast => '고속';
	@override String get lite => '경량';
	@override String get moreLite => '초경량';
	@override String get custom => '사용자 지정';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsKo extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => '대부분의 1080p 애니메이션, 특히 블러, 리샘플링 및 압축 아티팩트를 처리하는 영상에 적합합니다. 가장 높은 체감 화질을 제공합니다.';
	@override String get mode_b_hq => '스케일링으로 인한 약간의 블러나 링잉이 있는 애니메이션에 적합합니다. 링잉과 계단 현상을 효과적으로 줄일 수 있습니다.';
	@override String get mode_c_hq => '고품질 소스(예: 네이티브 1080p 애니메이션 또는 영화)에 적합합니다. 노이즈를 제거하고 가장 높은 PSNR을 제공합니다.';
	@override String get mode_a_a_hq => 'Mode A의 강화 버전으로, 최상의 체감 화질을 제공하며 거의 모든 손상된 선을 복원할 수 있습니다. 과도한 선명화나 링잉이 발생할 수 있습니다.';
	@override String get mode_b_b_hq => 'Mode B의 강화 버전으로, 더 높은 체감 화질을 제공하며 선을 더 최적화하고 아티팩트를 줄입니다.';
	@override String get mode_c_a_hq => 'Mode C의 체감 화질 강화 버전으로, 높은 PSNR을 유지하면서 일부 선 디테일을 복원합니다.';
	@override String get mode_a_fast => 'Mode A의 고속 버전으로, 화질과 성능의 균형을 맞추며 대부분의 1080p 애니메이션에 적합합니다.';
	@override String get mode_b_fast => 'Mode B의 고속 버전으로, 낮은 부하로 가벼운 아티팩트와 링잉을 처리합니다.';
	@override String get mode_c_fast => 'Mode C의 고속 버전으로, 고품질 소스를 빠르게 노이즈 제거하고 업스케일링합니다.';
	@override String get mode_a_a_fast => 'Mode A+A의 고속 버전으로, 성능이 제한된 기기에서 더 높은 체감 화질을 추구합니다.';
	@override String get mode_b_b_fast => 'Mode B+B의 고속 버전으로, 성능이 제한된 기기에 향상된 선 복원과 아티팩트 처리를 제공합니다.';
	@override String get mode_c_a_fast => 'Mode C+A의 고속 버전으로, 고품질 소스를 빠르게 처리하면서 가벼운 선 복원을 제공합니다.';
	@override String get upscale_only_s => '가장 빠른 CNN 모델만 사용한 초고속 x2 업스케일링으로, 복원과 노이즈 제거 없이 부하가 최소입니다.';
	@override String get upscale_deblur_fast => '기존 비 CNN 알고리즘을 사용한 고속 업스케일링 및 디블러로, 매우 낮은 부하로 기본 플레이어 알고리즘보다 우수합니다.';
	@override String get restore_s_only => '가장 빠른 CNN 모델만 사용해 복원하며 업스케일링은 하지 않습니다. 화질을 개선하고 싶은 네이티브 해상도 재생에 적합합니다.';
	@override String get denoise_bilateral_fast => '기존 양방향 필터를 사용한 고속 노이즈 제거로, 매우 빠르며 가벼운 노이즈 처리에 적합합니다.';
	@override String get upscale_non_cnn => '기존 알고리즘을 사용한 고속 업스케일링으로, 부하가 매우 낮고 플레이어 기본값보다 우수합니다.';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 선 어둡게 하기로, 고속 Mode A에 선을 더 진하게 만드는 효과를 추가해 선을 더 뚜렷하고 스타일리시하게 표현합니다.';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 선 얇게 하기로, 고품질 Mode A에 선을 더 가늘게 만드는 효과를 추가해 더 정교하게 표현합니다.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesKo extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'CNN 업스케일링(초고속)';
	@override String get upscale_deblur_fast => '업스케일링 & 디블러(고속)';
	@override String get restore_s_only => '복원(초고속)';
	@override String get denoise_bilateral_fast => '양방향 노이즈 제거(초고속)';
	@override String get upscale_non_cnn => '비 CNN 업스케일링(초고속)';
	@override String get mode_a_fast_darken => 'Mode A (Fast) + 선 어둡게';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + 선 얇게';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseKo extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => '빠른 접근';
	@override String get sourcesSection => '폴더';
	@override String get pin => '빠른 접근에 추가';
	@override String get unpin => '빠른 접근에서 제거';
	@override String get pinned => '빠른 접근에 추가됨';
	@override String get unpinned => '빠른 접근에서 제거됨';
	@override String folderCount({required Object count}) => '폴더 ${count}개';
	@override String videoCount({required Object count}) => '동영상 ${count}개';
	@override String imageCount({required Object count}) => '이미지 ${count}개';
	@override String get emptyFolder => '이 폴더는 비어 있습니다';
	@override String get videosSection => '동영상';
	@override String get imagesSection => '이미지';
	@override String get galleriesSection => '갤러리';
	@override String get filterAll => '전체';
	@override String get searchInFolder => '이 폴더에서 검색';
	@override String get searchHint => '이름으로 검색';
	@override String get clearSearch => '검색 지우기';
	@override String searchNoResult({required Object query}) => '"${query}"와 일치하는 항목이 없습니다';
	@override String viewAllFolders({required Object count}) => '폴더 ${count}개 모두 보기';
	@override String viewAllVideos({required Object count}) => '동영상 ${count}개 모두 보기';
	@override String viewAllImages({required Object count}) => '이미지 ${count}장 모두 보기';
	@override String viewAllGalleries({required Object count}) => '갤러리 ${count}개 모두 보기';
	@override String get location => '위치';
	@override String get sourceMissing => '이 소스가 사라졌습니다';
	@override String get notScannedYet => '이 폴더는 아직 검사되지 않았습니다';
	@override String get scanning => '이 폴더를 읽는 중…';
	@override String get deleteFileTitle => '이 파일을 삭제하시겠습니까?';
	@override String deleteFileBody({required Object name}) => '"${name}"이(가) 이 기기에서 영구적으로 삭제됩니다. 되돌릴 수 없습니다.';
	@override String get hideFolder => '이 폴더 숨기기';
	@override String get unhideFolder => '숨김 해제';
	@override String get showHiddenFolders => '숨긴 폴더 표시';
	@override String get includeDotFolders => '. 으로 시작하는 폴더도 스캔';
	@override String get dotFoldersIncluded => '. 으로 시작하는 폴더 스캔을 시작했습니다';
	@override String get dotFoldersExcluded => '. 으로 시작하는 폴더를 더 이상 스캔하지 않습니다';
	@override String get showDotFolders => '. 으로 시작하는 폴더 표시';
	@override String dotFoldersSkipped({required Object count}) => '여기에 스캔되지 않은 . 으로 시작하는 폴더가 ${count}개 있습니다';
	@override String get scanDotFoldersAction => '이 소스에서 켜기';
	@override String get otherAppsPrivateNotice => 'Android 11부터는 어떤 앱도 다른 앱의 Android/data, Android/obb 파일을 읽을 수 없으며 이 앱도 우회할 수 없습니다. 원래 앱에서 동영상을 Download 같은 공용 폴더로 다운로드하거나 내보낸 뒤 그 폴더를 추가하세요. 재생 중 캐시는 보통 조각으로 나뉘어 있어 읽더라도 재생할 수 없습니다.';
	@override String get folderHidden => '숨겼습니다. 검색에서도 건너뜁니다';
	@override String get folderUnhidden => '숨김을 해제했습니다';
	@override String get hiddenFolderBadge => '숨김';
	@override String get deleteFolder => '폴더 삭제';
	@override String get deleteFolderTitle => '이 폴더를 삭제할까요?';
	@override String deleteFolderBody({required Object name}) => '"${name}"와 그 안의 모든 항목이 이 기기에서 완전히 삭제됩니다. 되돌릴 수 없습니다.';
	@override String get deleteFolderIncludesOthers => '안에 있는 다른 파일도 함께 삭제됩니다';
	@override String get folderDeleted => '폴더를 삭제했습니다';
	@override String get deleteFolderFailed => '삭제하지 못했습니다. 권한이 없거나 안의 파일이 사용 중일 수 있습니다';
	@override String get deleteGalleryTitle => '이 갤러리를 삭제하시겠습니까?';
	@override String deleteGalleryBody({required Object name}) => '"${name}"의 다운로드 기록과 로컬 이미지 파일이 삭제됩니다. 되돌릴 수 없습니다.';
	@override String get galleryResourceMissing => '로컬 파일이 더 이상 존재하지 않습니다. 기록이 정리되었습니다.';
	@override String get viewDownloadDetail => '다운로드 세부 정보 보기';
	@override String get viewOnlineGallery => '웹사이트에서 보기';
	@override String get pickFolderTitle => '폴더 선택';
	@override String get useThisFolder => '이 폴더 사용';
	@override String get noSubfolders => '여기에는 하위 폴더가 없습니다';
	@override String get storageRoot => '기기 저장소';
	@override String get homeFolder => '홈';
	@override String get filesystemRoot => '파일 시스템 루트';
	@override String get folderUnreadable => '이 폴더를 읽을 수 없습니다';
	@override String get setCover => '커버 설정';
	@override String get setAsFolderCover => '폴더 커버로 사용';
	@override String get folderCoverSet => '폴더 커버가 업데이트되었습니다';
	@override String get setFolderCoverPick => '커버 설정…';
	@override String get restoreAutoCover => '자동 커버 복원';
	@override String get autoCoverRestored => '자동 커버가 복원되었습니다';
	@override String get rescanFolder => '이 폴더 다시 검사';
	@override String get coverPickerTitle => '프레임 선택';
	@override String get folderCoverPickerTitle => '커버 선택';
	@override String get coverPickerEmpty => '이 폴더에 아직 사용할 수 있는 이미지가 없습니다. 동영상 썸네일이 백그라운드에서 생성 중일 수 있습니다.';
	@override String get coverSaved => '커버가 업데이트되었습니다';
	@override String get coverSaveFailed => '커버를 저장할 수 없습니다';
	@override String get coverUnavailable => '이 파일에서 동영상 프레임을 읽을 수 없습니다';
	@override String get deleted => '삭제됨';
	@override String get deleteFailed => '삭제할 수 없습니다 — 파일이 사용 중이거나 쓰기 불가일 수 있습니다';
	@override String get openFolder => '열기';
	@override String get favorite => '즐겨찾기에 추가';
	@override String get unfavorite => '즐겨찾기에서 제거';
	@override String get favorited => '즐겨찾기에 추가됨';
	@override String get unfavorited => '즐겨찾기에서 제거됨';
	@override String get sortBy => '정렬 기준';
	@override String get sortAscending => '오름차순';
	@override String get sortDescending => '내림차순';
	@override String get sortFieldName => '이름';
	@override String get sortFieldModified => '수정한 날짜';
	@override String get sortFieldDuration => '재생 시간';
	@override String get sortFieldSize => '크기';
	@override String get sortFieldResolution => '해상도';
	@override String get sortFieldFileType => '파일 형식';
	@override String get sortFieldFps => '프레임 레이트';
	@override String get sortFieldFavorited => '즐겨찾기한 날짜';
	@override String get emptyAllVideos => '아직 동영상이 없습니다. 폴더에서 폴더를 추가하여 시작하세요.';
	@override String get emptyAllImages => '아직 이미지가 없습니다. 폴더에서 폴더를 추가하여 시작하세요.';
	@override String get emptyFavorites => '아직 즐겨찾기가 없습니다. 동영상의 ⋮ 메뉴에서 추가하세요.';
	@override String get emptyPinned => '아직 빠른 접근 폴더가 없습니다. 폴더에서 폴더를 길게 눌러 고정을 선택하세요.';
	@override String get emptyDownloadedVideos => '아직 완료된 동영상 다운로드가 없습니다.';
	@override String get emptyDownloadedGalleries => '아직 완료된 갤러리 다운로드가 없습니다.';
	@override String get folderInfo => '폴더 정보';
	@override String get folderInfoName => '이름';
	@override String get folderInfoPath => '경로';
	@override String get folderInfoSource => '소스';
	@override String get folderInfoContents => '내용';
	@override String get folderInfoSize => '디스크 사용량';
	@override String get folderInfoScannedAt => '마지막 검사';
	@override String get folderInfoNeverScanned => '아직 검사하지 않음';
	@override String get folderInfoNoPath => '이 소스에는 열 폴더가 없습니다';
	@override String get copyPath => '경로 복사';
	@override String get pathCopied => '경로가 복사되었습니다';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsKo extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingKo extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavKo extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorKo extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '경로 템플릿';
	@override String get subtitle => '다운로드 파일을 하위 폴더로 자동 정리';
	@override String get tabVideo => '동영상';
	@override String get tabGallery => '갤러리';
	@override String get tabImage => '개별 이미지';
	@override String get previewLabel => '미리보기 · 정리 후 실제 저장 결과';
	@override String get galleryPreviewLabel => '미리보기 · 갤러리 템플릿=폴더 이름(내부 이미지는 ID로 명명)';
	@override String addFolder({required Object current, required Object max}) => '폴더 계층 추가(${current}/${max})';
	@override String get folderCapReached => '폴더 계층 한도에 도달했습니다';
	@override String get folderSegmentHint => '%authorcache, 변수 또는 고정 텍스트';
	@override String get fileSegmentHint => '예: %title_%quality';
	@override String videoCapNote({required Object max}) => '확장자(.mp4)는 자동으로 추가됩니다 · 세그먼트 내에서 / 입력 시 두 계층으로 분할 · 최대 ${max}계층';
	@override String imageCapNote({required Object max}) => '원본 확장자는 자동으로 추가됩니다 · 세그먼트 내에서 / 입력 시 두 계층으로 분할 · 최대 ${max}계층';
	@override String galleryCapNote({required Object max}) => '갤러리 템플릿은 모두 폴더 세그먼트(최대 ${max}계층) · 내부 이미지는 이미지 ID로 명명';
	@override String get trayHint => '탭하여 커서 위치에 삽입 · 길게 눌러 설명 보기';
	@override String get emptySegment => '빈 세그먼트';
	@override String get emptySegmentSaveBlocked => '저장할 수 없습니다: 빈 세그먼트를 삭제하거나 내용을 입력하세요';
	@override String get tooManySegmentsSaveBlocked => '저장할 수 없습니다: 경로 세그먼트 수가 상한(최대 4개)을 초과했습니다. 병합하거나 줄여 주세요';
	@override String get templateInvalidSaveBlocked => '저장할 수 없습니다: 템플릿에 잘못된 문자가 포함되어 있습니다';
	@override String get variableInserted => '변수가 삽입되었습니다';
	@override String get savedToast => '저장됨 · 이후 새 다운로드에만 적용';
	@override String get trayCategoryContent => '콘텐츠';
	@override String get trayCategoryAuthor => '작성자';
	@override String get trayCategoryTime => '시간';
	@override String get chipAuthorcache => '작성자 이름·고정';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestKo extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'Quest에 익숙해지기';
	@override String get intro => '어떤 컨트롤이 무엇을 하는지 확인한 뒤 공간에서 사용해 보세요.';
	@override String get videoTab => '공간 동영상';
	@override String get galleryTab => '공간 갤러리';
	@override String get scopeNote => 'Quest 공간의 화면과 창에 적용됩니다. 플레이어 설정에서 언제든 다시 열 수 있습니다.';
	@override String get catalog => '컨트롤 살펴보기';
	@override String lessonCount({required Object total, required Object current}) => '${total}개 중 ${current}번째';
	@override String get previous => '이전';
	@override String get next => '다음 컨트롤';
	@override String get replay => '시연 다시 재생';
	@override String get pauseDemo => '시연 일시정지';
	@override String get resumeDemo => '시연 재개';
	@override String get looping => '컨트롤 시연';
	@override String get still => '정지 일러스트';
	@override String get done => '알겠습니다, 계속';
	@override String get leftController => '왼손';
	@override String get rightController => '오른손';
	@override String get trigger => '검지 트리거';
	@override String get grip => '그립 버튼';
	@override String get bothGrips => '양쪽 그립 버튼';
	@override String get stick => '썸스틱';
	@override String get handTracking => '핸드 트래킹';
	@override String get ready => '준비';
	@override String get press => '누르기';
	@override String get hold => '길게 누르기';
	@override String get release => '놓기';
	@override String get result => '결과 확인';
	@override String get pinch => '집기';
	@override String get selectTitle => '가리키고 선택';
	@override String get selectBody => '광선을 버튼에 맞춘 뒤 검지 트리거를 누르고 놓으세요. 컨트롤 패널의 재생, 설정, 슬라이더에 사용합니다.';
	@override String get selectHint => '검지 트리거는 버튼 면 뒤에 있습니다. 안쪽 핸들의 그립 버튼은 창을 잡습니다.';
	@override String get panelTitle => '패널 표시 또는 숨기기';
	@override String get panelBody => '컨트롤 패널 바깥을 가리킨 뒤 검지 트리거를 탭하여 표시하거나 숨깁니다. 핸드 트래킹에서는 패널 바깥을 빠르게 집어도 같은 동작이 됩니다.';
	@override String get panelHint => '끌지 않고 짧게 탭하세요. 누른 채 움직이면 드래그로 처리되어 패널 전환이 되지 않습니다.';
	@override String get playTitle => '재생 및 일시정지';
	@override String get playBody => '컨트롤 패널에서 벗어난 곳을 가리키고 오른쪽 A 또는 왼쪽 X를 누르면 재생하거나 일시정지합니다. 패널의 재생 버튼을 선택해도 됩니다.';
	@override String get playHint => '이 기본 단축키는 공간 플레이어 설정에서 비활성화할 수 있습니다. 패널을 가리키면 입력이 패널로 전달됩니다.';
	@override String get seekTitle => '스틱으로 스크럽';
	@override String get seekBody => '어느 한 스틱을 좌우로 살짝 밀면 5초 단위로 이동합니다. 계속 누르면 목표 시간을 미리 보며 더 빠르게 스크럽합니다. 놓으면 탐색이 확정됩니다.';
	@override String get seekHint => '해당 컨트롤러의 광선을 컨트롤 패널에서 벗어나게 유지하세요. 스틱이 패널을 가리키면 대신 패널이 스크롤됩니다.';
	@override String get browseTitle => '스틱으로 탐색';
	@override String get browseBody => '어느 한 스틱을 좌우로 움직여 이전/다음 항목으로 이동합니다. 계속 누르면 계속 탐색합니다. 필름스트립에서 썸네일을 선택할 수도 있습니다.';
	@override String get browseHint => '갤러리의 동영상도 항목입니다. 컨트롤 패널을 가리키면 스틱이 패널을 스크롤합니다.';
	@override String get swipeTitle => '옆으로 끌어 페이지 넘기기';
	@override String get swipeBody => '이미지에 광선을 맞추고 검지 트리거를 누른 채 왼쪽으로 끄세요. 페이지 넘김 신호 후 놓으면 넘어가고, 오른쪽으로 끌면 뒤로 갑니다. 집어서 끌어도 됩니다.';
	@override String get swipeHint => '이미지를 끌어 페이지를 넘기려면 1배 상태여야 합니다. 갤러리 동영상도 지원합니다. 놓을 때까지 스테이지는 그대로 유지됩니다.';
	@override String get zoomTitle => '이미지 확대';
	@override String get zoomBody => '이미지의 세부 부분에 광선을 맞추고 검지 트리거를 누른 뒤 스틱을 위로 밀면 확대, 아래로 밀면 축소됩니다. 확대는 누른 지점을 기준으로 고정됩니다.';
	@override String get zoomHint => '이미지 창 안의 이미지를 확대합니다. 이미지를 잡지 않은 상태에서는 위/아래가 시청 거리를 조정합니다.';
	@override String get panTitle => '이미지 이동 및 복원';
	@override String get panBody => '확대한 후 검지 트리거를 누른 채 끌면 주변을 둘러볼 수 있습니다. 이미지를 두 번 탭하면 2.5배로 확대하거나 원래대로 되돌립니다. 손을 사용할 때는 빠르게 두 번 집으세요.';
	@override String get panHint => '끌면 확대된 이미지가 이동합니다. 페이지를 넘기려면 1배로 되돌린 후 끌어야 합니다.';
	@override String get slideshowTitle => '슬라이드쇼 시작';
	@override String get slideshowBody => '이미지에서 A / X는 슬라이드쇼를 시작하거나 일시정지합니다. 패널에서 3초, 5초, 10초, 20초 간격과 일반 또는 원본 화질을 선택할 수 있습니다.';
	@override String get slideshowHint => '갤러리 동영상에서는 A / X가 해당 동영상의 재생을 제어합니다. 컨트롤러 단축키는 설정에서 활성화해야 합니다.';
	@override String get moveTitle => '화면 잡고 이동';
	@override String get moveBody => '안쪽 핸들의 그립 버튼을 누르고 컨트롤러를 움직여 화면을 배치한 뒤 놓으세요. 시청 중에는 화면을 가리키지 않고도 잡을 수 있습니다.';
	@override String get moveHint => '앱 창이나 컨트롤 패널을 가리키면 먼저 그 창을 잡습니다. 파노라마 동영상에서는 그립으로 방향을 조정합니다.';
	@override String get scaleTitle => '양손으로 크기 조절';
	@override String get scaleBody => '양쪽 그립 버튼을 누르세요. 손을 벌리면 화면이 커지고, 모으면 작아집니다. 핸드 트래킹에서는 양손으로 집은 상태를 유지하세요.';
	@override String get scaleHint => '갤러리 스테이지를 포함한 평면 및 곡면 화면에 적용됩니다. 광선은 컨트롤 패널에 두지 마세요. 화면 전체의 크기가 조절됩니다.';
	@override String get distanceTitle => '시청 거리 조정';
	@override String get distanceBody => '스틱을 위로 밀면 화면이 멀어지고, 아래로 밀면 가까워집니다. 창을 잡고 있으면 위/아래로 그 창이 움직입니다. 볼륨은 패널에서 조절하세요.';
	@override String get distanceHint => '컨트롤 패널에서 벗어난 곳을 가리키세요. 이미지를 잡고 있으면 위/아래가 이미지 확대/축소로 바뀌고, 파노라마 동영상은 대신 시야가 조정됩니다.';
	@override String get resizeTitle => '가장자리와 모서리 사용';
	@override String get resizeBody => '광선이 가장자리에 가까워지면 프레임이 빛납니다. 가장자리에서 트리거를 누르거나 집으면 창이 이동하고, 모서리를 끌면 크기가 조절됩니다.';
	@override String get resizeHint => '앱 창, 컨트롤 패널, 화면에서 작동합니다. 앱 창은 너비와 높이가 바뀌고, 화면은 화면 비율을 유지합니다.';
	@override String get navigationTitle => '뒤로 가기 및 설정 열기';
	@override String get navigationBody => 'B / Y는 한 단계 뒤로 갑니다: 팝업을 닫거나 패널 홈으로 돌아가고, 패널을 숨긴 다음 앱으로 돌아갑니다. 왼쪽 Menu 버튼은 공간 설정을 엽니다.';
	@override String get navigationHint => '오른쪽 Meta 버튼은 시스템에 속합니다. 시스템 리센터는 화면 크기와 거리를 유지하면서 시야를 정면으로 되돌립니다.';
	@override String get handsTitle => '손 사용하기';
	@override String get handsBody => '핸드 트래킹을 켜고 시스템 광선을 버튼에 맞춘 뒤 엄지와 검지를 집었다가 놓으세요. 재생, 탐색, 갤러리 이동은 패널을 사용하세요.';
	@override String get handsHint => '패널 바깥을 집으면 패널이 전환됩니다. 가장자리를 집으면 이동, 모서리를 집으면 크기 조절, 양손으로 집고 벌리면 화면이 커집니다.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesKo extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => '미디어 플레이어';
	@override String get mediaServer => '미디어 서버';
	@override String get internetGatewayDevice => '라우터';
	@override String get basicDevice => '기본 기기';
	@override String get dimmableLight => '스마트 조명';
	@override String get wlanAccessPoint => 'WLAN 액세스 포인트';
	@override String get wlanConnectionDevice => 'WLAN 연결 기기';
	@override String get printer => '프린터';
	@override String get scanner => '스캐너';
	@override String get digitalSecurityCamera => '디지털 보안 카메라';
	@override String get unknownDevice => '알 수 없는 기기';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetKo extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '원격 캐스트';
	@override String get close => '닫기';
	@override String get searchingDevices => '기기 검색 중...';
	@override String get searchPrompt => '검색 버튼을 클릭하여 캐스팅 기기를 다시 검색하세요';
	@override String get searching => '검색 중';
	@override String get searchAgain => '다시 검색';
	@override String get noDevicesFound => '캐스팅 기기를 찾을 수 없습니다\n기기가 같은 네트워크에 있는지 확인해 주세요';
	@override String get searchingDevicesPrompt => '기기를 검색하는 중입니다. 잠시 기다려 주세요...';
	@override String get cast => '캐스트';
	@override String connectedTo({required Object deviceName}) => '연결됨: ${deviceName}';
	@override String get notConnected => '연결된 기기가 없습니다';
	@override String get stopCasting => '캐스트 중지';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => '개인 프로필',
			'personalProfile.editPersonalProfile' => '개인 프로필 편집',
			'personalProfile.avatar' => '아바타',
			'personalProfile.background' => '배경',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => '사용자 프로필을 가져오지 못했습니다: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => '권장 해상도: ${resolution}, 파일 크기 < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => '지원 형식: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => '프리미엄 사용자는 동적 ${type}(${formats})을 사용할 수 있습니다',
			'personalProfile.homepageBackground' => '홈페이지 배경',
			'personalProfile.basicInfo' => '기본 정보',
			'personalProfile.nickname' => '닉네임',
			'personalProfile.username' => '사용자 이름',
			'personalProfile.copyUsername' => '사용자 이름 복사',
			'personalProfile.usernameCopied' => '사용자 이름이 복사되었습니다',
			'personalProfile.personalIntroduction' => '자기소개',
			'personalProfile.noPersonalIntroduction' => '자기소개 없음',
			'personalProfile.clickToEdit' => '클릭하여 편집',
			'personalProfile.privacySettings' => '개인정보 설정',
			'personalProfile.hideSensitiveContent' => '민감한 콘텐츠 숨기기',
			'personalProfile.hideSensitiveContentDesc' => '민감한 태그가 포함된 동영상이나 이미지를 숨깁니다.',
			'personalProfile.notificationSettings' => '알림 설정',
			'personalProfile.contentCommentNotification' => '콘텐츠 댓글 알림',
			'personalProfile.contentCommentNotificationDesc' => '회원님의 콘텐츠에 댓글이 달리면 알려드립니다.',
			'personalProfile.commentReplyNotification' => '댓글 답글 알림',
			'personalProfile.commentReplyNotificationDesc' => '회원님의 댓글에 답글이 달리면 알려드립니다.',
			'personalProfile.mentionNotification' => '멘션 알림',
			'personalProfile.mentionNotificationDesc' => '콘텐츠에서 회원님을 멘션하면 알려드립니다.',
			'personalProfile.accountInfo' => '계정 정보',
			'personalProfile.registrationTime' => '가입 시간',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => '설정을 업데이트하지 못했습니다: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => '알림 설정을 업데이트하지 못했습니다: ${error}',
			'personalProfile.editNickname' => '닉네임 편집',
			'personalProfile.nicknameCannotBeEmpty' => '닉네임은 비워 둘 수 없습니다',
			'personalProfile.changeSuccess' => '변경되었습니다',
			'personalProfile.unsupportedFileFormat' => '지원되지 않는 파일 형식',
			'personalProfile.fileTooLarge' => ({required Object size}) => '파일 크기는 ${size}를 초과할 수 없습니다',
			'personalProfile.uploadFailed' => '업로드 실패',
			'personalProfile.avatarUpdatedSuccessfully' => '아바타가 업데이트되었습니다',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => '아바타를 업데이트하지 못했습니다: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => '배경이 업데이트되었습니다',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => '배경을 업데이트하지 못했습니다: ${error}',
			'personalProfile.editPersonalIntroduction' => '자기소개 편집',
			'personalProfile.enterPersonalIntroduction' => '자기소개를 입력해 주세요',
			'tutorial.specialFollowFeature' => '특별 팔로우',
			'tutorial.specialFollowDescription' => '가장 자주 보는 작성자를 특별 팔로우로 지정하면 여기서 바로 최신 업로드로 이동할 수 있습니다.',
			'tutorial.stepsTitle' => '세 단계',
			'tutorial.stepFollowAuthor' => '작성자의 동영상, 갤러리 또는 프로필 페이지에서 팔로우를 탭하세요.',
			'tutorial.stepPickSpecial' => '팔로우됨을 다시 탭한 다음 메뉴에서 특별 팔로우를 선택하세요.',
			'tutorial.stepSwitchHere' => '여기로 돌아와 위의 아바타 선택기로 해당 작성자로 전환하세요.',
			'tutorial.specialFollowManagementTip' => '특별 팔로우 목록은 사이드바 - 팔로우 목록 - 특별 팔로우에서 관리합니다.',
			'tutorial.gotIt' => '알겠습니다',
			'common.sort' => '정렬',
			'common.filter' => '필터',
			'common.appName' => 'Love Iwara',
			'common.ok' => '확인',
			'common.cancel' => '취소',
			'common.select' => '선택',
			'common.save' => '저장',
			'common.delete' => '삭제',
			'common.visit' => '방문',
			'common.loading' => '로딩 중...',
			'common.scrollToTop' => '맨 위로',
			'common.privacyHint' => '개인정보 보호 모드가 켜져 있어 콘텐츠가 숨겨집니다',
			'common.latest' => '최신',
			'common.likesCount' => '좋아요',
			'common.viewsCount' => '조회수',
			'common.popular' => '인기',
			'common.trending' => '인기 급상승',
			'common.commentList' => '댓글 목록',
			'common.sendComment' => '댓글 보내기',
			'common.send' => '보내기',
			'common.retry' => '재시도',
			'common.premium' => '프리미엄',
			'common.follower' => '팔로워',
			'common.friend' => '친구',
			'common.video' => '동영상',
			'common.following' => '팔로잉',
			'common.expand' => '펼치기',
			'common.collapse' => '접기',
			'common.cancelFriendRequest' => '요청 취소',
			'common.cancelSpecialFollow' => '특별 팔로우 취소',
			'common.addFriend' => '친구 추가',
			'common.removeFriend' => '친구 삭제',
			'common.followed' => '팔로우함',
			'common.follow' => '팔로우',
			'common.unfollow' => '팔로우 취소',
			'common.specialFollow' => '특별 팔로우',
			'common.specialFollowed' => '특별 팔로우함',
			'common.gallery' => '갤러리',
			'common.playlist' => '재생목록',
			'common.commentPostedSuccessfully' => '댓글이 등록되었습니다',
			'common.commentPostedFailed' => '댓글 등록 실패',
			'common.success' => '성공',
			'common.commentDeletedSuccessfully' => '댓글이 삭제되었습니다',
			'common.commentUpdatedSuccessfully' => '댓글이 수정되었습니다',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '댓글 ${n}개', other: '댓글 ${n}개', ), 
			'common.writeYourCommentHere' => '여기에 댓글을 작성하세요...',
			'common.tmpNoReplies' => '아직 답글이 없습니다',
			'common.loadMore' => '더 보기',
			'common.loadingMore' => '더 불러오는 중...',
			'common.noMoreDatas' => '더 이상 데이터가 없습니다',
			'common.selectTranslationLanguage' => '번역 언어 선택',
			'common.translate' => '번역',
			'common.translateFailedPleaseTryAgainLater' => '번역 실패, 나중에 다시 시도해 주세요',
			'common.translationResult' => '번역 결과',
			'common.justNow' => '방금',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '${n}분 전', other: '${n}분 전', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '${n}시간 전', other: '${n}시간 전', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '${n}일 전', other: '${n}일 전', ), 
			'common.editedAt' => ({required Object num}) => '${num} 수정됨',
			'common.editComment' => '댓글 수정',
			'common.commentUpdated' => '댓글 수정됨',
			'common.replyComment' => '댓글에 답글',
			'common.reply' => '답글',
			'common.edit' => '편집',
			'common.unknownUser' => '알 수 없는 사용자',
			'common.me' => '나',
			'common.author' => '작성자',
			'common.admin' => '관리자',
			'common.viewReplies' => ({required Object num}) => '답글 보기(${num})',
			'common.hideReplies' => '답글 숨기기',
			'common.confirmDelete' => '삭제 확인',
			'common.areYouSureYouWantToDeleteThisItem' => '이 항목을 삭제하시겠습니까?',
			'common.tmpNoComments' => '아직 댓글이 없습니다',
			'common.refresh' => '새로 고침',
			'common.back' => '뒤로',
			'common.tips' => '팁',
			'common.linkIsEmpty' => '링크가 비어 있습니다',
			'common.linkCopiedToClipboard' => '링크가 클립보드에 복사되었습니다',
			'common.imageCopiedToClipboard' => '이미지가 클립보드에 복사되었습니다',
			'common.copyImageFailed' => '이미지 복사 실패',
			'common.mobileSaveImageIsUnderDevelopment' => '모바일 이미지 저장 기능은 개발 중입니다',
			'common.imageSavedTo' => '이미지 저장 위치:',
			'common.saveImageFailed' => '이미지 저장 실패',
			'common.close' => '닫기',
			'common.more' => '더보기',
			'common.unknownError' => '알 수 없는 오류',
			'common.moreFeaturesToBeDeveloped' => '더 많은 기능이 개발될 예정입니다',
			'common.all' => '전체',
			'common.selectedRecords' => ({required Object num}) => '${num}개 기록 선택됨',
			'common.cancelSelectAll' => '전체 선택 해제',
			'common.selectAll' => '전체 선택',
			'common.invertSelection' => '선택 반전',
			'common.exitEditMode' => '편집 모드 종료',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '선택한 ${num}개 항목을 삭제하시겠습니까?',
			'common.searchHistoryRecords' => '기록 검색...',
			'common.settings' => '설정',
			'common.subscriptions' => '구독',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '동영상 ${n}개', other: '동영상 ${n}개', ), 
			'common.share' => '공유',
			'common.areYouSureYouWantToShareThisPlaylist' => '이 재생목록을 공유하시겠습니까?',
			'common.editTitle' => '제목 편집',
			'common.editMode' => '편집 모드',
			'common.pleaseEnterNewTitle' => '새 제목을 입력해 주세요',
			'common.createPlayList' => '재생목록 만들기',
			'common.create' => '만들기',
			'common.checkNetworkSettings' => '네트워크 설정 확인',
			'common.general' => '일반',
			'common.r18' => 'R18',
			'common.sensitive' => '민감',
			'common.year' => '년',
			'common.month' => '월',
			'common.tag' => '태그',
			'common.private' => '비공개',
			'common.noTitle' => '제목 없음',
			'common.search' => '검색',
			'common.noContent' => '콘텐츠 없음',
			'common.recording' => '녹음 중',
			'common.paused' => '일시정지됨',
			'common.clear' => '지우기',
			'common.clearSelection' => '선택 해제',
			'common.selectItemsToContinue' => '계속하려면 항목을 선택하세요',
			'common.andMoreItems' => ({required Object num}) => '그 외 ${num}개',
			'common.batchDelete' => '일괄 삭제',
			'common.user' => '사용자',
			'common.post' => '게시물',
			'common.seconds' => '초',
			'common.comingSoon' => '출시 예정',
			'common.confirm' => '확인',
			'common.hour' => '시간',
			'common.minute' => '분',
			'common.clickToRefresh' => '클릭하여 새로 고침',
			'common.history' => '기록',
			'common.favorites' => '즐겨찾기',
			'common.friends' => '친구',
			'common.playList' => '재생목록',
			'common.checkLicense' => '라이선스 확인',
			'common.logout' => '로그아웃',
			'common.fensi' => '팬',
			'common.accept' => '수락',
			'common.reject' => '거부',
			'common.clearAllHistory' => '모든 기록 지우기',
			'common.clearAllHistoryConfirm' => '모든 기록을 지우시겠습니까?',
			'common.followingList' => '팔로잉 목록',
			'common.followersList' => '팔로워 목록',
			'common.follows' => '팔로우',
			'common.fans' => '팬',
			'common.followsAndFans' => '팔로우 및 팬',
			'common.numViews' => '조회수',
			'common.updatedAt' => '수정일',
			'common.publishedAt' => '게시일',
			'common.externalVideo' => '외부 동영상',
			'common.originalText' => '원문',
			'common.showOriginalText' => '원문 표시',
			'common.showProcessedText' => '처리된 텍스트 표시',
			'common.preview' => '미리보기',
			'common.rules' => '규칙',
			'common.agree' => '동의',
			'common.disagree' => '동의하지 않음',
			'common.agreeToRules' => '규칙에 동의',
			'common.markdownSyntaxHelp' => 'Markdown 문법 도움말',
			'common.previewContent' => '내용 미리보기',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => '최대 길이 제한(${max})을 초과했습니다',
			'common.agreeToCommunityRules' => '커뮤니티 규칙에 동의',
			'common.createPost' => '게시물 작성',
			'common.title' => '제목',
			'common.enterTitle' => '제목을 입력해 주세요',
			'common.content' => '콘텐츠',
			'common.enterContent' => '내용을 입력해 주세요',
			'common.writeYourContentHere' => '내용을 입력해 주세요...',
			'common.tagBlacklist' => '태그 블랙리스트',
			'common.noData' => '데이터 없음',
			'common.tagLimit' => '태그 제한',
			'common.enableFloatingButtons' => '플로팅 버튼 켜기',
			'common.disableFloatingButtons' => '플로팅 버튼 끄기',
			'common.enabledFloatingButtons' => '플로팅 버튼 켜짐',
			'common.disabledFloatingButtons' => '플로팅 버튼 꺼짐',
			'common.pendingCommentCount' => '대기 중인 댓글 수',
			'common.joined' => ({required Object str}) => '${str} 가입',
			'common.lastSeenAt' => ({required Object str}) => '최근 활동: ${str}',
			'common.download' => '다운로드',
			'common.selectQuality' => '화질 선택',
			'common.videoQualitySource' => '원본',
			'common.selectImageQuality' => '이미지 화질 선택',
			'common.imageQualityStandard' => '표준',
			'common.imageQualityOriginal' => '원본',
			'common.selectDateRange' => '날짜 범위 선택',
			'common.selectDateRangeHint' => '날짜 범위를 선택하세요. 기본값은 최근 30일입니다',
			'common.clearDateRange' => '날짜 범위 지우기',
			'common.deleteRecordsInDateRange' => '이 범위의 기록 삭제',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => '이 날짜 범위의 기록 ${num}개를 삭제하시겠습니까? 되돌릴 수 없습니다.',
			'common.noHistoryRecordsInRange' => '이 날짜 범위에 기록이 없습니다',
			'common.followSuccessClickAgainToSpecialFollow' => '팔로우했습니다. 다시 클릭하면 특별 팔로우',
			'common.specialFollowTip' => '특별 팔로우에 추가되었습니다 — 구독 페이지 오른쪽 위 선택기에서 골라 빠르게 접근할 수 있습니다',
			'common.exitConfirmTip' => '종료하시겠습니까?',
			'common.error' => '오류',
			'common.taskRunning' => '이미 작업이 실행 중입니다. 잠시 기다려 주세요.',
			'common.operationCancelled' => '작업이 취소되었습니다.',
			'common.unsavedChanges' => '저장하지 않은 변경 사항이 있습니다',
			'common.specialFollowsManagementTip' => '핸들을 끌어 순서를 바꾸고 • 버튼을 눌러 삭제하세요',
			'common.specialFollowsManagement' => '특별 팔로우 관리',
			'common.removeSpecialFollow' => '특별 팔로우 해제',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => '${name}님을 특별 팔로우에서 해제하시겠습니까?',
			'common.noSpecialFollows' => '아직 특별 팔로우가 없습니다',
			'common.createTimeDesc' => '작성 시간 내림차순',
			'common.createTimeAsc' => '작성 시간 오름차순',
			'common.pagination.totalItems' => ({required Object num}) => '총 ${num}개',
			'common.pagination.jumpToPage' => '페이지로 이동',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => '페이지 번호를 입력해 주세요(1-${max})',
			'common.pagination.pageNumber' => '페이지 번호',
			'common.pagination.jump' => '이동',
			'common.pagination.invalidPageNumber' => ({required Object max}) => '올바른 페이지 번호를 입력해 주세요(1-${max})',
			'common.pagination.invalidInput' => '올바른 페이지 번호를 입력해 주세요',
			'common.pagination.waterfall' => '워터폴',
			'common.pagination.pagination' => '페이지',
			'common.notice' => '공지',
			'common.detail' => '상세',
			'common.parseExceptionDestopHint' => ' - 데스크톱 사용자는 설정에서 프록시를 구성할 수 있습니다',
			'common.iwaraTags' => 'Iwara 태그',
			'common.tagInfo' => '태그 정보',
			'common.tagOriginalKey' => '원본 태그',
			'common.tagTranslation' => '번역',
			'common.copy' => '복사',
			'common.selectCopy' => '선택 및 복사',
			'common.copiedToClipboard' => '클립보드에 복사되었습니다',
			'common.showOriginalTag' => '원본 태그 표시',
			'common.showTranslatedTag' => '번역 표시',
			'common.tagTranslationFeedback' => '번역이 의심스러우신가요? 피드백 보내기',
			'common.tagLocalizationGuideTitle' => '태그 번역 정보',
			'common.tagLocalizationGuideContent' => '앱은 Iwara의 원본 태그(예: mother)를 현재 언어의 이름으로 표시합니다.\n\n• 태그를 검색할 때 번역과 원본 태그가 모두 일치합니다.\n• 태그를 길게 누르거나 오른쪽 클릭하면 원본 키와 번역을 확인하고 복사할 수 있습니다.\n• 번역은 커뮤니티가 유지 관리하며 최선을 다한 결과로, 오류가 있을 수 있습니다.',
			'common.likeThisVideo' => '이 동영상 좋아요',
			'common.likeThisGallery' => '이 갤러리 좋아요',
			'common.operation' => '작업',
			'common.replies' => '답글',
			'common.externalLinkWarning' => '외부 링크 경고',
			'common.externalLinkWarningMessage' => 'iwara.tv에 속하지 않은 외부 링크를 열려고 합니다. 주의하고 링크가 안전한지 확인한 후 진행해 주세요.',
			'common.continueToExternalLink' => '계속',
			'common.cancelExternalLink' => '취소',
			'auth.login' => '로그인',
			'auth.logout' => '로그아웃',
			'auth.email' => '이메일',
			'auth.password' => '비밀번호',
			'auth.loginOrRegister' => '로그인 / 회원가입',
			'auth.register' => '회원가입',
			'auth.pleaseEnterEmail' => '이메일을 입력해 주세요',
			'auth.pleaseEnterPassword' => '비밀번호를 입력해 주세요',
			'auth.passwordMustBeAtLeast6Characters' => '비밀번호는 6자 이상이어야 합니다',
			'auth.pleaseEnterCaptcha' => '인증 코드를 입력해 주세요',
			'auth.captcha' => '인증 코드',
			'auth.refreshCaptcha' => '인증 코드 새로 고침',
			'auth.captchaNotLoaded' => '인증 코드가 로드되지 않았습니다',
			'auth.loginSuccess' => '로그인 성공',
			'auth.loginSuccessProfilePending' => '로그인되었습니다. 프로필을 불러오는 중…',
			'auth.emailVerificationSent' => '이메일 인증이 전송되었습니다',
			'auth.notLoggedIn' => '로그인하지 않음',
			'auth.clickToLogin' => '클릭하여 로그인',
			'auth.logoutConfirmation' => '로그아웃하시겠습니까?',
			'auth.logoutSuccess' => '로그아웃 성공',
			'auth.logoutFailed' => '로그아웃 실패',
			'auth.usernameOrEmail' => '사용자 이름 또는 이메일',
			'auth.pleaseEnterUsernameOrEmail' => '사용자 이름 또는 이메일을 입력해 주세요',
			'auth.rememberMe' => '사용자 이름 기억',
			'auth.registerNoticeTitle' => '공식 웹사이트에서 가입',
			'auth.registerNoticeDescription' => '앱 내 회원가입은 더 이상 제공되지 않습니다. 공식 Iwara 웹사이트에서 계정을 만든 후 다시 돌아와 로그인해 주세요.',
			'auth.registerNoticeReturnTip' => '가입 후 이곳으로 돌아와 계정으로 로그인해 주세요.',
			'auth.goToOfficialWebsite' => '공식 웹사이트로 이동',
			'errors.error' => '오류',
			'errors.required' => '필수 항목입니다',
			'errors.invalidEmail' => '잘못된 이메일 주소',
			'errors.networkError' => '네트워크 오류, 다시 시도해 주세요',
			'errors.errorWhileFetching' => '가져오는 중 오류',
			'errors.commentCanNotBeEmpty' => '댓글 내용은 비워 둘 수 없습니다',
			'errors.errorWhileFetchingReplies' => '답글을 가져오는 중 오류가 발생했습니다. 네트워크 연결을 확인해 주세요',
			'errors.canNotFindCommentController' => '댓글 컨트롤러를 찾을 수 없습니다',
			'errors.errorWhileLoadingGallery' => '갤러리를 불러오는 중 오류',
			'errors.howCouldThereBeNoDataItCantBePossible' => '데이터가 없을 리가 없는데요? 말도 안 돼요 :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => '지원하지 않는 이미지 형식: ${str}',
			'errors.invalidGalleryId' => '잘못된 갤러리 ID',
			'errors.translationFailedPleaseTryAgainLater' => '번역 실패, 나중에 다시 시도해 주세요',
			'errors.errorOccurred' => '오류가 발생했습니다. 나중에 다시 시도해 주세요.',
			'errors.errorOccurredWhileProcessingRequest' => '요청 처리 중 오류가 발생했습니다',
			'errors.errorWhileFetchingDatas' => '데이터를 가져오는 중 오류가 발생했습니다. 나중에 다시 시도해 주세요',
			'errors.serviceNotInitialized' => '서비스가 초기화되지 않았습니다',
			'errors.unknownType' => '알 수 없는 유형',
			'errors.errorWhileOpeningLink' => ({required Object link}) => '링크를 여는 중 오류: ${link}',
			'errors.invalidUrl' => '잘못된 URL',
			'errors.failedToOperate' => '작업 실패',
			'errors.permissionDenied' => '권한 거부됨',
			'errors.youDoNotHavePermissionToAccessThisResource' => '이 리소스에 접근할 권한이 없습니다',
			'errors.loginFailed' => '로그인 실패',
			'errors.unknownError' => '알 수 없는 오류',
			'errors.sessionExpired' => '세션이 만료되었습니다',
			'errors.failedToFetchCaptcha' => '인증 코드를 가져오지 못했습니다',
			'errors.emailAlreadyExists' => '이메일이 이미 존재합니다',
			'errors.invalidCaptcha' => '잘못된 인증 코드',
			'errors.registerFailed' => '회원가입 실패',
			'errors.failedToFetchComments' => '댓글을 가져오지 못했습니다',
			'errors.failedToFetchImageDetail' => '이미지 상세를 가져오지 못했습니다',
			'errors.failedToFetchImageList' => '이미지 목록을 가져오지 못했습니다',
			'errors.failedToFetchData' => '데이터를 가져오지 못했습니다',
			'errors.invalidParameter' => '잘못된 매개변수',
			'errors.pleaseLoginFirst' => '먼저 로그인해 주세요',
			'errors.errorWhileLoadingPost' => '게시물을 불러오는 중 오류',
			'errors.errorWhileLoadingPostDetail' => '게시물 상세를 불러오는 중 오류',
			'errors.invalidPostId' => '잘못된 게시물 ID',
			'errors.forceUpdateNotPermittedToGoBack' => '현재 강제 업데이트 상태로 뒤로 갈 수 없습니다',
			'errors.pleaseLoginAgain' => '다시 로그인해 주세요',
			'errors.invalidLogin' => '로그인 정보가 잘못되었습니다. 이메일과 비밀번호를 확인해 주세요',
			'errors.tooManyRequests' => '요청이 너무 많습니다. 나중에 다시 시도해 주세요',
			'errors.exceedsMaxLength' => ({required Object max}) => '최대 길이 초과: ${max}',
			'errors.contentCanNotBeEmpty' => '내용은 비워 둘 수 없습니다',
			'errors.titleCanNotBeEmpty' => '제목은 비워 둘 수 없습니다',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => '요청이 너무 많습니다. 나중에 다시 시도해 주세요. 남은 시간',
			'errors.remainingHours' => ({required Object num}) => '${num}시간',
			'errors.remainingMinutes' => ({required Object num}) => '${num}분',
			'errors.remainingSeconds' => ({required Object num}) => '${num}초',
			'errors.tagLimitExceeded' => ({required Object limit}) => '태그 제한을 초과했습니다. 제한: ${limit}',
			'errors.failedToRefresh' => '새로 고침 실패',
			'errors.noPermission' => '권한 없음',
			'errors.resourceNotFound' => '리소스를 찾을 수 없습니다',
			'errors.failedToSaveCredentials' => '로그인 자격 증명을 저장하지 못했습니다',
			'errors.failedToLoadSavedCredentials' => '저장된 자격 증명을 불러오지 못했습니다',
			'errors.notFound' => '콘텐츠를 찾을 수 없거나 삭제되었습니다',
			'errors.network.basicPrefix' => '네트워크 오류 - ',
			'errors.network.failedToConnectToServer' => '서버에 연결하지 못했습니다',
			'errors.network.serverNotAvailable' => '서버를 사용할 수 없음',
			'errors.network.requestTimeout' => '요청 시간 초과',
			'errors.network.unexpectedError' => '예기치 않은 오류',
			'errors.network.invalidResponse' => '잘못된 응답',
			'errors.network.invalidRequest' => '잘못된 요청',
			'errors.network.invalidUrl' => '잘못된 URL',
			'errors.network.invalidMethod' => '잘못된 메서드',
			'errors.network.invalidHeader' => '잘못된 헤더',
			'errors.network.invalidBody' => '잘못된 본문',
			'errors.network.invalidStatusCode' => '잘못된 상태 코드',
			'errors.network.serverError' => '서버 오류',
			'errors.network.requestCanceled' => '요청이 취소되었습니다',
			'errors.network.invalidPort' => '잘못된 포트',
			'errors.network.proxyPortError' => '프록시 포트 오류',
			'errors.network.connectionRefused' => '연결이 거부되었습니다',
			'errors.network.networkUnreachable' => '네트워크에 연결할 수 없음',
			'errors.network.noRouteToHost' => '호스트로 가는 경로 없음',
			'errors.network.connectionFailed' => '연결 실패',
			'errors.network.sslConnectionFailed' => 'SSL 연결 실패, 네트워크 설정을 확인해 주세요',
			'friends.clickToRestoreFriend' => '클릭하여 친구 복원',
			'friends.friendsList' => '친구 목록',
			'friends.friendRequests' => '친구 요청',
			'friends.friendRequestsList' => '친구 요청 목록',
			'friends.removingFriend' => '친구 삭제 중...',
			'friends.failedToRemoveFriend' => '친구를 삭제하지 못했습니다',
			'friends.cancelingRequest' => '친구 요청 취소 중...',
			'friends.failedToCancelRequest' => '친구 요청을 취소하지 못했습니다',
			'authorProfile.noMoreDatas' => '더 이상 데이터가 없습니다',
			'authorProfile.userProfile' => '사용자 프로필',
			'favorites.clickToRestoreFavorite' => '클릭하여 즐겨찾기 복원',
			'favorites.myFavorites' => '내 즐겨찾기',
			'favorites.batchCancelFavorite' => '선택한 즐겨찾기 제거',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => '선택한 ${count}개 항목을 즐겨찾기에서 제거하시겠습니까? 이후 카드를 탭하면 복원할 수 있습니다.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => '${count}개 항목을 즐겨찾기에서 제거했습니다',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => '${success}개 제거됨, ${failed}개 실패',
			'galleryDetail.browseInSpace' => '공간에서 탐색',
			'galleryDetail.galleryDetail' => '갤러리 상세',
			'galleryDetail.viewGalleryDetail' => '갤러리 상세 보기',
			'galleryDetail.zoomReset' => '확대/축소 초기화',
			'galleryDetail.copyLink' => '링크 복사',
			'galleryDetail.copyImage' => '이미지 복사',
			'galleryDetail.saveAs' => '다른 이름으로 저장',
			'galleryDetail.saveToAlbum' => '앨범에 저장',
			'galleryDetail.publishedAt' => '게시일',
			'galleryDetail.viewsCount' => '조회수',
			'galleryDetail.imageLibraryFunctionIntroduction' => '이미지 라이브러리 기능 소개',
			'galleryDetail.rightClickToSaveSingleImage' => '오른쪽 클릭으로 단일 이미지 저장',
			'galleryDetail.batchSave' => '일괄 저장',
			'galleryDetail.keyboardLeftAndRightToSwitch' => '키보드 좌우 키로 전환',
			'galleryDetail.keyboardUpAndDownToZoom' => '키보드 상하 키로 확대/축소',
			'galleryDetail.mouseWheelToSwitch' => '마우스 휠로 전환',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + 마우스 휠로 확대/축소',
			'galleryDetail.moreFeaturesToBeDiscovered' => '더 많은 기능이 있습니다...',
			'galleryDetail.authorOtherGalleries' => '작성자의 다른 갤러리',
			'galleryDetail.relatedGalleries' => '관련 갤러리',
			'galleryDetail.authorNoOtherGalleries' => '이 작성자의 다른 갤러리가 없습니다',
			'galleryDetail.noRelatedGalleries' => '관련 갤러리가 없습니다',
			'galleryDetail.scrollLeft' => '왼쪽으로 스크롤',
			'galleryDetail.scrollRight' => '오른쪽으로 스크롤',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => '이미지를 전환하려면 좌우 가장자리를 클릭하세요',
			'galleryDetail.rotateToLandscape' => '가로 전체 화면',
			'galleryDetail.backToPortrait' => '세로 모드로 돌아가기',
			'playList.myPlayList' => '내 재생목록',
			'playList.friendlyTips' => '친절한 안내',
			'playList.dearUser' => '사용자님께',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'iwara의 재생목록 시스템은 아직 완벽하지 않습니다',
			'playList.notSupportSetCover' => '커버 설정은 지원되지 않습니다',
			'playList.notSupportDeleteList' => '재생목록 삭제는 지원되지 않습니다',
			'playList.notSupportSetPrivate' => '비공개 설정은 지원되지 않습니다',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => '예... 만든 재생목록은 항상 존재하며 모든 사람에게 공개됩니다',
			'playList.smallSuggestion' => '작은 제안',
			'playList.useLikeToCollectContent' => '개인정보 보호를 더 중시하신다면 "좋아요" 기능으로 콘텐츠를 수집하시길 권장합니다',
			'playList.welcomeToDiscussOnGitHub' => '다른 제안이나 아이디어가 있으시면 GitHub에서 논의해 주세요!',
			'playList.iUnderstand' => '이해했습니다',
			'playList.searchPlaylists' => '재생목록 검색...',
			'playList.newPlaylistName' => '새 재생목록 이름',
			'playList.createNewPlaylist' => '새 재생목록 만들기',
			'playList.videos' => '동영상',
			'search.googleSearchScope' => '검색 범위',
			'search.searchTags' => '태그 검색...',
			'search.contentRating' => '콘텐츠 등급',
			'search.removeTag' => '태그 제거',
			'search.pleaseEnterSearchContent' => '검색 내용을 입력하세요',
			'search.searchHistory' => '검색 기록',
			'search.searchSuggestion' => '검색 제안',
			'search.usedTimes' => '사용 횟수',
			'search.lastUsed' => '마지막 사용',
			'search.noSearchHistoryRecords' => '검색 기록이 없습니다',
			'search.clearSearchHistoryConfirm' => '모든 검색 기록을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => '현재 검색 유형 ${searchType}은 지원되지 않습니다. 업데이트를 기다려 주세요',
			'search.searchResult' => '검색 결과',
			'search.unsupportedSearchType' => ({required Object searchType}) => '지원되지 않는 검색 유형: ${searchType}',
			'search.googleSearch' => 'Google 검색',
			'search.googleSearchHint' => ({required Object webName}) => '${webName}의 검색 기능이 사용하기 불편하신가요? Google 검색을 사용해 보세요!',
			'search.googleSearchDescription' => 'Google 검색의 :site 검색 연산자를 사용하여 사이트의 콘텐츠를 검색합니다. 동영상, 갤러리, 재생목록, 사용자를 검색할 때 매우 유용합니다.',
			'search.googleSearchKeywordsHint' => '검색할 키워드를 입력하세요',
			'search.openLinkJump' => '링크 바로 열기',
			'search.googleSearchButton' => 'Google 검색',
			'search.pleaseEnterSearchKeywords' => '검색 키워드를 입력하세요',
			'search.googleSearchQueryCopied' => '검색어가 클립보드에 복사되었습니다',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => '브라우저를 열지 못했습니다: ${error}',
			'search.searchRequestTimeout' => '요청 시간이 초과되었습니다. 나중에 다시 시도해 주세요',
			'search.searchCannotConnectToServer' => '서버에 연결할 수 없습니다. 네트워크 연결을 확인해 주세요',
			'search.searchNetworkError' => '네트워크 연결에 실패했습니다. 네트워크 설정을 확인하거나 나중에 다시 시도해 주세요',
			'search.searchFailedPleaseRetry' => '검색에 실패했습니다. 나중에 다시 시도해 주세요',
			'mediaList.personalIntroduction' => '소개',
			'settings.listViewMode' => '목록 보기 모드',
			'settings.previewEffect' => '미리보기 효과',
			'settings.useTraditionalPaginationMode' => '기존 페이지네이션 모드 사용',
			'settings.useTraditionalPaginationModeDesc' => '기존 페이지네이션 모드를 활성화하고 워터폴 모드를 비활성화합니다. 페이지를 다시 렌더링하거나 앱을 다시 시작한 후 적용됩니다',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => '도구 모음 숨김 시 동영상 진행률 하단 바 표시',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => '이 설정은 도구 모음이 숨겨졌을 때 동영상 진행률 하단 바를 표시할지 여부를 결정합니다.',
			'settings.seekPreviewSize' => '탐색 미리보기 크기',
			'settings.seekPreviewSizeDesc' => '진행 표시줄 위 미리보기 창의 크기입니다. 이미 플레이어 크기와 동영상 화면 비율을 따르며, 이 설정은 이를 약간 조정할 뿐입니다.',
			'settings.seekPreviewSizeSmall' => '작게',
			'settings.seekPreviewSizeStandard' => '표준',
			'settings.seekPreviewSizeLarge' => '크게',
			'settings.seekPreviewSizeStandardDesc' => '플레이어와 동영상에서 산출된 크기',
			'settings.showFullscreenUpNextHint' => '다음 항목 핸들 표시',
			'settings.showFullscreenUpNextHintDesc' => '플레이어 오른쪽 가장자리에 대기열 서랍(소스/재생목록/나중에 볼 항목)을 여는 작은 핸들을 표시합니다. 꺼 두면 들어갈 다른 방법이 없습니다.',
			'settings.basicSettings' => '기본 설정',
			'settings.personalizedSettings' => '개인화 설정',
			'settings.otherSettings' => '기타 설정',
			'settings.searchConfig' => '검색 설정',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => '이 설정은 동영상을 다시 재생할 때 이전 설정을 사용할지 여부를 결정합니다.',
			'settings.playControl' => '재생 제어',
			'settings.playbackSpeedSettings' => '재생 및 속도',
			'settings.playbackBehaviorSettings' => '재생 동작',
			'settings.enhancementSettings' => '극장 및 향상',
			'settings.fastForwardTime' => '빨리 감기 시간',
			'settings.fastForwardTimeMustBeAPositiveInteger' => '빨리 감기 시간은 양의 정수여야 합니다.',
			'settings.rewindTime' => '되감기 시간',
			'settings.rewindTimeMustBeAPositiveInteger' => '되감기 시간은 양의 정수여야 합니다.',
			'settings.longPressPlaybackSpeed' => '길게 누르기 재생 속도',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => '길게 누르기 재생 속도는 양수여야 합니다.',
			'settings.defaultPlaybackSpeed' => '기본 재생 속도',
			_ => null,
		} ?? switch (path) {
			'settings.rememberPlaybackSpeed' => '재생 속도 기억',
			'settings.rememberPlaybackSpeedDesc' => '활성화하면 플레이어에서 설정한 속도가 기본값으로 저장되어 새 동영상에 자동으로 적용됩니다.',
			'settings.repeat' => '반복',
			'settings.renderVerticalVideoInVerticalScreen' => '세로 화면에서 세로 동영상 렌더링',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => '이 설정은 전체 화면으로 재생할 때 동영상을 세로 화면으로 렌더링할지 여부를 결정합니다.',
			'settings.rememberVolume' => '볼륨 기억',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => '이 설정은 동영상을 다시 재생할 때 볼륨을 유지할지 여부를 결정합니다.',
			'settings.rememberBrightness' => '밝기 기억',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => '이 설정은 동영상을 다시 재생할 때 밝기를 유지할지 여부를 결정합니다.',
			'settings.playControlArea' => '재생 제어 영역',
			'settings.leftAndRightControlAreaWidth' => '좌우 제어 영역 너비',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => '이 설정은 플레이어 좌우 제어 영역의 너비를 결정합니다.',
			'settings.proxyAddressCannotBeEmpty' => '프록시 주소는 비워 둘 수 없습니다.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => '프록시 주소 형식이 올바르지 않습니다. IP:포트 또는 도메인 이름:포트 형식을 사용해 주세요.',
			'settings.proxyNormalWork' => '프록시가 정상 작동합니다.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => '프록시 테스트 실패, 상태 코드: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => '프록시 테스트 실패, 예외: ${exception}',
			'settings.proxyConfig' => '프록시 설정',
			'settings.thisIsHttpProxyAddress' => '이것은 http 프록시 주소입니다',
			'settings.checkProxy' => '프록시 확인',
			'settings.proxyAddress' => '프록시 주소',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => '프록시 서버의 URL을 입력하세요. 예: 127.0.0.1:8080',
			'settings.enableProxy' => '프록시 사용',
			'settings.left' => '왼쪽',
			'settings.middle' => '가운데',
			'settings.right' => '오른쪽',
			'settings.playerSettings' => '플레이어 설정',
			'settings.networkSettings' => '네트워크 설정',
			'settings.customizeYourPlaybackExperience' => '재생 환경 사용자 지정',
			'settings.chooseYourFavoriteAppAppearance' => '원하는 앱 테마를 선택하세요',
			'settings.configureYourProxyServer' => '프록시 서버 구성',
			'settings.settings' => '설정',
			'settings.themeSettings' => '테마 설정',
			'settings.followSystem' => '시스템 설정 따르기',
			'settings.lightMode' => '라이트 모드',
			'settings.darkMode' => '다크 모드',
			'settings.presetTheme' => '사전 설정 테마',
			'settings.basicTheme' => '기본 테마',
			'settings.needRestartToApply' => '설정을 적용하려면 앱을 다시 시작해야 합니다',
			'settings.themeNeedRestartDescription' => '테마 설정을 적용하려면 앱을 다시 시작해야 합니다',
			'settings.about' => '정보',
			'settings.diagnosticsAndFeedback' => '진단 및 피드백',
			'settings.currentVersion' => '현재 버전',
			'settings.latestVersion' => '최신 버전',
			'settings.checkForUpdates' => '업데이트 확인',
			'settings.update' => '업데이트',
			'settings.newVersionAvailable' => '새 버전 사용 가능',
			'settings.projectHome' => '프로젝트 홈',
			'settings.release' => '릴리스',
			'settings.issueReport' => '문제 신고',
			'settings.openSourceLicense' => '오픈 소스 라이선스',
			'settings.checkForUpdatesFailed' => '업데이트 확인에 실패했습니다. 나중에 다시 시도해 주세요',
			'settings.autoCheckUpdate' => '자동 업데이트 확인',
			'settings.updateContent' => '업데이트 내용',
			'settings.releaseDate' => '릴리스 날짜',
			'settings.ignoreThisVersion' => '이 버전 무시',
			'settings.forceUpdateTip' => '필수 업데이트입니다. 가능한 한 빨리 최신 버전으로 업데이트해 주세요',
			'settings.viewChangelog' => '변경 로그 보기',
			'settings.alreadyLatestVersion' => '이미 최신 버전입니다',
			'settings.appSettings' => '앱 설정',
			'settings.configureYourAppSettings' => '앱 설정 구성',
			'settings.history' => '기록',
			'settings.autoRecordHistory' => '기록 자동 저장',
			'settings.autoRecordHistoryDesc' => '시청한 동영상과 이미지를 자동으로 기록합니다',
			'settings.autoDeleteHistory' => '기록 자동 정리',
			'settings.autoDeleteHistoryDesc' => '시작 시 보관 일수를 초과한 검색 기록을 자동으로 삭제합니다 (기본값 꺼짐)',
			'settings.autoDeleteHistoryDays' => '보관 일수',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => '최근 ${num}일 유지',
			'settings.autoDeleteHistoryDaysInvalid' => '유효한 일수(최소 1)를 입력하세요',
			'settings.showUnprocessedMarkdownText' => '처리되지 않은 Markdown 텍스트 표시',
			'settings.showUnprocessedMarkdownTextDesc' => 'markdown 원본 텍스트를 표시합니다',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => '개인정보 보호 모드',
			'settings.activeBackgroundPrivacyModeDesc' => '스크린샷과 화면 녹화를 차단하고 백그라운드에서 화면을 숨깁니다',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => '앱이 백그라운드로 전환되면 화면을 숨깁니다 (이 플랫폼은 스크린샷을 차단할 수 없습니다)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => '스크린샷과 화면 녹화를 차단합니다',
			'settings.privacy' => '개인정보',
			'settings.appLock' => '앱 잠금',
			'settings.appLockEnabled' => '앱 잠금 사용',
			'settings.appLockEnabledDesc' => '앱을 열 때 PIN 또는 생체 인증을 요구합니다. 백그라운드 미리보기는 자동으로 숨겨집니다',
			'settings.appLockEnabledSummary' => '켜짐 · PIN 보호',
			'settings.appLockDisabledSummary' => '꺼짐',
			'settings.appLockTimeout' => '앱을 나간 후 잠금',
			'settings.appLockTimeoutDesc' => '인증이 필요해지기까지 백그라운드에서 허용되는 시간',
			'settings.appLockAfterScreenOff' => '화면 잠금 후 잠금',
			'settings.appLockAfterScreenOffDesc' => '기기 화면이 잠긴 후 인증을 요구합니다',
			'settings.appLockTimeoutDisabled' => '사용 안 함',
			'settings.appLockImmediately' => '즉시',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds}초',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes}분',
			'settings.appLockUseBiometrics' => '생체 인증 사용',
			'settings.appLockUseBiometricsDesc' => '지문 또는 얼굴 인식으로 잠금 해제',
			'settings.appLockBiometricsUnavailable' => '이 기기에 등록된 생체 인증 정보가 없습니다',
			'settings.appLockSetPin' => 'PIN 설정',
			'settings.appLockEnterPin' => 'PIN 입력',
			'settings.appLockConfirmPin' => 'PIN 확인',
			'settings.appLockCurrentPin' => '현재 PIN 입력',
			'settings.appLockNewPin' => '새 PIN 입력',
			'settings.appLockPinRequirements' => 'PIN은 4~8자리 숫자여야 합니다',
			'settings.appLockPinsDoNotMatch' => 'PIN이 일치하지 않습니다',
			'settings.appLockInvalidPin' => 'PIN이 올바르지 않습니다',
			'settings.appLockSetupFailed' => 'PIN을 안전하게 저장하지 못했습니다',
			'settings.appLockDisable' => '앱 잠금을 해제하려면 PIN을 입력하세요',
			'settings.appLockChangePin' => 'PIN 변경',
			'settings.appLockNow' => '지금 잠금',
			'settings.appLockUnlock' => '잠금 해제',
			'settings.appLockLockedTitle' => '잠김',
			'settings.appLockLockedDesc' => '계속하려면 인증하세요',
			'settings.appLockAuthenticateReason' => '잠금을 해제하려면 인증하세요',
			'settings.appLockEnableBiometricsReason' => '생체 인증 잠금 해제를 사용하려면 인증하세요',
			'settings.appLockBiometricFailed' => '생체 인증이 완료되지 않았습니다',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => '시도가 너무 많습니다. ${seconds}초 후에 다시 시도하세요',
			'settings.appLockCredentialUnavailableTitle' => '앱 잠금 자격 증명을 읽을 수 없습니다',
			'settings.appLockCredentialUnavailableDesc' => '시스템 보안 저장소를 일시적으로 사용할 수 없거나 자격 증명이 손상되었습니다. 앱은 잠긴 상태로 유지됩니다. 먼저 다시 시도하고, 계속 실패하면 앱 잠금을 재설정할 수 있으며, 이 경우 잠금이 해제되고 저장된 PIN이 삭제됩니다.',
			'settings.appLockRetry' => '다시 시도',
			'settings.appLockReset' => '앱 잠금 재설정',
			'settings.appLockResetAction' => '재설정',
			'settings.appLockResetConfirmTitle' => '앱 잠금을 재설정하시겠습니까?',
			'settings.appLockResetConfirmDesc' => '앱 잠금을 끄고 저장된 PIN과 생체 인증 설정을 삭제합니다. 이후 다시 설정할 수 있습니다.',
			'settings.appLockRetrySucceeded' => '자격 증명을 읽었습니다. PIN을 입력하세요.',
			'settings.appLockRetryFailed' => '여전히 자격 증명을 읽을 수 없습니다',
			'settings.forum' => '포럼',
			'settings.news' => '뉴스',
			'settings.community' => '커뮤니티',
			'settings.disableForumReplyQuote' => '포럼 답글 인용 비활성화',
			'settings.disableForumReplyQuoteDesc' => '포럼에서 답글을 작성할 때 답글 대상 층 정보를 함께 전송하지 않습니다',
			'settings.theaterMode' => '극장 모드',
			'settings.theaterModeDesc' => '켜면 플레이어 배경이 동영상 커버의 블러 처리된 버전으로 설정됩니다',
			'settings.appLinks' => '앱 링크',
			'settings.defaultBrowser' => '기본 브라우저',
			'settings.defaultBrowserDesc' => '시스템 설정에서 기본 링크 설정 항목을 열고 iwara.tv 웹사이트 링크를 추가해 주세요',
			'settings.themeMode' => '테마 모드',
			'settings.themeModeDesc' => '이 설정은 앱의 테마 모드를 결정합니다',
			'settings.glassEffect' => '인터페이스 재질',
			'settings.glassEffectDesc' => '앱 전반에 사용할 재질을 선택합니다 — 헤더 캡슐, 메뉴, 대화 상자 버튼, 하단 내비게이션 바',
			'settings.liquidGlassEffect' => '리퀴드 글래스',
			'settings.liquidGlassEffectDesc' => '실제 블러와 굴절입니다. 가장 보기 좋지만 저사양 기기에서는 프레임이 떨어지고 전력을 조금 더 사용할 수 있습니다',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => '표준 Material 3 표면 — 불투명, 블러 없음, 그림자 없음. 최고의 성능과 배터리 수명',
			'settings.glassEffectIntroTitle' => '인터페이스 재질을 선택하세요',
			'settings.glassEffectIntroContent' => '헤더, 탭 바, 메뉴에 리퀴드 글래스가 사용됩니다 — 실제 블러와 굴절 효과입니다. 기기에서 느리게 느껴지거나 더 단순한 것을 선호하시면 지금 Material로 전환하세요 (불투명 표면, 블러 없음, 그림자 없음).',
			'settings.glassEffectIntroHint' => '설정 → 테마 → 인터페이스 재질에서 언제든 변경할 수 있습니다.',
			'settings.glassEffectIntroDone' => '유지',
			'settings.dynamicColor' => '동적 색상',
			'settings.dynamicColorDesc' => '이 설정은 앱이 동적 색상을 사용할지 여부를 결정합니다',
			'settings.useDynamicColor' => '동적 색상 사용',
			'settings.useDynamicColorDesc' => '이 설정은 앱이 동적 색상을 사용할지 여부를 결정합니다',
			'settings.presetColors' => '사전 설정 색상',
			'settings.customColors' => '사용자 지정 색상',
			'settings.customColorsDisabledByDynamicColor' => '동적 색상이 켜져 있어 사전 설정/사용자 지정 색상을 사용할 수 없습니다. 먼저 동적 색상을 꺼 주세요.',
			'settings.pickColor' => '색상 선택',
			'settings.cancel' => '취소',
			'settings.confirm' => '확인',
			'settings.noCustomColors' => '사용자 지정 색상 없음',
			'settings.recordAndRestorePlaybackProgress' => '재생 진행률 기록 및 복원',
			'settings.autoPlayVideoOnFirstEnter' => '처음 진입 시 동영상 자동 재생',
			'settings.autoPlayVideoOnFirstEnterDesc' => '이 설정은 동영상 페이지에 처음 진입할 때 동영상이 자동으로 재생되기 시작할지 여부를 결정합니다.',
			'settings.autoEnterFullscreen' => '자동 전체 화면 진입',
			'settings.autoEnterFullscreenDesc' => '플레이어가 스스로 전체 화면으로 전환되는 시점입니다. 비공개, 삭제됨, 외부 동영상과 화면 속 화면은 항상 제외됩니다.',
			'settings.autoEnterFullscreenOff' => '꺼짐',
			'settings.autoEnterFullscreenOffDesc' => '전체 화면으로 자동 전환하지 않습니다',
			'settings.autoEnterFullscreenOnPlaybackStart' => '재생 시작 시',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => '재생이 실제로 시작되는 순간 전체 화면으로 전환합니다',
			'settings.autoEnterFullscreenOnDetailPageEnter' => '동영상 열 때',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => '동영상 페이지가 열리면 재생을 기다리지 않고 바로 전체 화면으로 전환합니다',
			'settings.autoEnterFullscreenKind' => '전체 화면 유형',
			'settings.autoEnterFullscreenKindDesc' => '자동으로 진입할 전체 화면 유형입니다. 데스크톱 전용입니다.',
			'settings.autoEnterFullscreenKindSystem' => '시스템 전체 화면',
			'settings.autoEnterFullscreenKindSystemDesc' => '창 관리자가 창을 전체 화면으로 전환합니다',
			'settings.autoEnterFullscreenKindApp' => '앱 전체 화면',
			'settings.autoEnterFullscreenKindAppDesc' => '창은 그대로 두고 앱 전체를 플레이어로 전환합니다',
			'settings.signature' => '서명',
			'settings.enableSignature' => '서명 사용',
			'settings.enableSignatureDesc' => '이 설정은 답글 작성 시 앱이 서명을 추가할지 여부를 결정합니다',
			'settings.enterSignature' => '서명 입력',
			'settings.editSignature' => '서명 편집',
			'settings.signatureContent' => '서명 내용',
			'settings.exportConfig' => '앱 설정 내보내기',
			'settings.exportConfigDesc' => '설정과 기록(검색 기록, 재생 진행률, 즐겨찾기 등)을 파일로 내보내 백업하거나 다른 기기로 전송합니다. 다운로드 작업은 포함되지 않습니다.',
			'settings.importConfig' => '앱 설정 가져오기',
			'settings.importConfigDesc' => '파일에서 앱 설정 가져오기',
			'settings.exportConfigSuccess' => '설정을 성공적으로 내보냈습니다!',
			'settings.exportConfigFailed' => '설정을 내보내지 못했습니다',
			'settings.importConfigSuccess' => '설정을 성공적으로 가져왔습니다!',
			'settings.importConfigFailed' => '설정을 가져오지 못했습니다',
			'settings.exportIncludeSensitive' => '민감한 정보 포함',
			'settings.exportIncludeSensitiveDesc' => 'API 키, 세션 토큰, 프록시 주소를 포함합니다. 본인 기기로 백업할 때만 활성화하세요.',
			'settings.importConfigOverwriteWarning' => '가져오면 현재 설정과 기록(검색 기록, 재생 진행률, 즐겨찾기 등)이 덮어씌워집니다. 계속하시겠습니까?',
			'settings.importConfigRestartTitle' => '가져오기 성공',
			'settings.importConfigRestartContent' => '설정을 가져왔습니다. 모든 변경 사항을 적용하려면 앱을 완전히 닫고 다시 열어 주세요.',
			'settings.historyUpdateLogs' => '업데이트 기록',
			'settings.noUpdateLogs' => '업데이트 기록이 없습니다',
			'settings.versionLabel' => '버전: {version}',
			'settings.releaseDateLabel' => '릴리스 날짜: {date}',
			'settings.noChanges' => '업데이트 내용이 없습니다',
			'settings.interaction' => '상호작용',
			'settings.enableVibration' => '진동 사용',
			'settings.enableVibrationDesc' => '앱과 상호작용할 때 진동 피드백을 사용합니다',
			'settings.defaultKeepVideoToolbarVisible' => '동영상 도구 모음 항상 표시',
			'settings.defaultKeepVideoToolbarVisibleDesc' => '이 설정은 동영상 페이지에 처음 진입할 때 동영상 도구 모음이 계속 표시될지 여부를 결정합니다.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => '모바일 기기에서 극장 모드를 활성화하면 성능 문제가 발생할 수 있습니다. 선택적으로 활성화할 수 있습니다.',
			'settings.fullscreenOrientation' => '전체 화면 진입 후 세로 화면 방향',
			'settings.fullscreenOrientationDesc' => '이 설정은 전체 화면 진입 시 기본 화면 방향을 결정합니다 (모바일 전용)',
			'settings.fullscreenOrientationLeftLandscape' => '왼쪽 가로',
			'settings.fullscreenOrientationRightLandscape' => '오른쪽 가로',
			'settings.screenFit' => '화면 크기',
			'settings.screenFitDesc' => '동영상이 플레이어 영역을 채우는 방식을 선택합니다.',
			'settings.rememberScreenFit' => '화면 크기 기억',
			'settings.rememberScreenFitDesc' => '선택한 크기를 이후에 여는 동영상에 적용합니다.',
			'settings.screenFitFit' => '맞춤',
			'settings.screenFitFitDesc' => '화면 비율을 유지하며 전체 프레임을 표시합니다',
			'settings.screenFitStretch' => '늘이기',
			'settings.screenFitStretchDesc' => '플레이어 영역을 채우며, 이미지가 왜곡될 수 있습니다',
			'settings.screenFitCover' => '채우기',
			'settings.screenFitCoverDesc' => '화면 비율을 유지하며 플레이어 영역을 채우고, 넘치는 부분은 잘라냅니다',
			'settings.screenFitRatioDesc' => '이 화면 비율을 강제로 적용하며, 이미지가 왜곡될 수 있습니다',
			'settings.jumpLink' => '링크 이동',
			'settings.language' => '언어',
			'settings.languageNativeName' => '한국어',
			'settings.followSystemLanguage' => '시스템 언어 따르기',
			'settings.languageChangedMessage' => '언어가 변경되었습니다. 일부 기능은 앱을 다시 시작해야 적용됩니다.',
			'settings.languageChanged' => '언어 설정이 변경되었습니다. 적용하려면 앱을 다시 시작해 주세요.',
			'settings.keybinding.title' => '키보드 단축키',
			'settings.keybinding.entryLabel' => '키보드 단축키',
			'settings.keybinding.entryDesc' => '앱의 키보드 단축키를 사용자 지정합니다 (주로 데스크톱용)',
			'settings.keybinding.desktopHint' => '단축키는 주로 데스크톱 키보드에 적용되며, 모바일에서는 보통 제스처를 사용합니다.',
			'settings.keybinding.resetAll' => '모두 기본값으로 재설정',
			'settings.keybinding.resetAllConfirm' => '모든 앱 단축키를 기본값으로 재설정하시겠습니까?',
			'settings.keybinding.resetToDefault' => '기본값으로 재설정',
			'settings.keybinding.resetScope' => '이 섹션 재설정',
			'settings.keybinding.notSet' => '설정 안 됨',
			'settings.keybinding.addShortcut' => '단축키 추가',
			'settings.keybinding.removeShortcut' => '이 단축키 제거',
			'settings.keybinding.pressNewShortcut' => '새 단축키를 누르세요…',
			'settings.keybinding.recordingCancelHint' => 'Esc를 눌러 취소',
			'settings.keybinding.mouseHint' => '마우스 측면 버튼(뒤로/앞으로) 또는 가운데 버튼도 지정할 수 있습니다',
			'settings.keybinding.mouseNotSupportedInScope' => '이 영역은 마우스 버튼을 처리하지 않습니다. 대신 키보드를 사용하세요',
			'settings.keybinding.capabilityKeyboardOnly' => '이 영역은 키보드 키만 지원합니다',
			'settings.keybinding.capabilityKeyboardAndMouse' => '이 영역은 키보드 키와 마우스 가운데 및 측면 버튼을 지원합니다',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => '이 영역은 키보드 키와 마우스 가운데 및 앞으로 버튼을 지원합니다 (뒤로 버튼은 시스템이 사용합니다)',
			'settings.keybinding.rejectMultipleButtons' => '마우스 버튼은 한 번에 하나씩 누르세요',
			'settings.keybinding.rejectPlatformBack' => '시스템이 이미 뒤로 가기에 사용하고 있어 지정하면 두 번 뒤로 이동합니다',
			'settings.keybinding.detectedLabel' => '감지됨',
			'settings.keybinding.reservedKey' => '이 키는 시스템이 예약한 키라 지정할 수 없습니다',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => '이 키는 "${action}"에 지정되어 있으며, 이 화면에서 나갈 수 있도록 여기서 예약된 상태로 유지됩니다',
			'settings.keybinding.conflictTitle' => '단축키 충돌',
			'settings.keybinding.conflictMessage' => ({required Object action}) => '이 조합은 이미 "${action}"에 지정되어 있습니다. 계속하면 기존 지정이 제거됩니다.',
			'settings.keybinding.conflictContinue' => '그래도 지정',
			'settings.keybinding.shadowWarningTitle' => '전역 단축키 중복',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => '이 조합은 전역에서 "${action}"에 지정되어 있습니다. 여기에 지정하면 이 섹션 내에서만 해당 동작을 대체합니다.',
			'settings.keybinding.globalShadowedMessage' => ({required Object scope, required Object action}) => '이 조합은 ${scope}에서 이미 "${action}"에 지정되어 있습니다. 해당 섹션에서는 이 전역 단축키가 그것으로 대체됩니다.',
			'settings.keybinding.searchHint' => '단축키 검색…',
			'settings.keybinding.scopeGlobal' => '전역',
			'settings.keybinding.scopeGallery' => '갤러리',
			'settings.keybinding.scopeVideo' => '동영상',
			'settings.keybinding.categoryNavigation' => '탐색',
			'settings.keybinding.categoryZoom' => '확대/축소',
			'settings.keybinding.categoryPlayback' => '재생',
			'settings.keybinding.categorySeek' => '탐색',
			'settings.keybinding.categoryVolume' => '볼륨',
			'settings.keybinding.categoryDisplay' => '표시',
			'settings.keybinding.actionGlobalBack' => '뒤로 가기',
			'settings.keybinding.actionGalleryNext' => '다음 사진',
			'settings.keybinding.actionGalleryPrevious' => '이전 사진',
			'settings.keybinding.actionGalleryZoomIn' => '확대',
			'settings.keybinding.actionGalleryZoomOut' => '축소',
			'settings.keybinding.actionGalleryResetZoom' => '확대/축소 초기화',
			'settings.keybinding.actionGalleryPlayPause' => '재생 / 일시정지',
			'settings.keybinding.actionGallerySeekBackward' => '되감기',
			'settings.keybinding.actionGallerySeekForward' => '빨리 감기',
			'settings.keybinding.actionGalleryToggleMute' => '음소거 전환',
			'settings.keybinding.actionPlayPause' => '재생 / 일시정지',
			'settings.keybinding.actionSpeedUp' => '속도 증가',
			'settings.keybinding.actionSpeedDown' => '속도 감소',
			'settings.keybinding.actionSeekForward' => '앞으로 탐색',
			'settings.keybinding.actionSeekBackward' => '뒤로 탐색',
			'settings.keybinding.actionVolumeUp' => '볼륨 높이기',
			'settings.keybinding.actionVolumeDown' => '볼륨 낮추기',
			'settings.keybinding.actionToggleMute' => '음소거 전환',
			'settings.keybinding.actionToggleFullscreen' => '전체 화면 전환',
			'settings.keybinding.seekLongPressHint' => '앞으로/뒤로 탐색 키를 길게 누르면 길게 누르기 배속 모드가 작동합니다',
			'settings.keybinding.zoomSectionTitle' => '화면 확대/축소 (고정)',
			'settings.keybinding.zoomFixedNote' => '아래 단축키는 고정되어 변경할 수 없습니다',
			'settings.keybinding.zoomScaleLabel' => '화면 확대',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + 휠',
			'settings.keybinding.zoomRotateLabel' => '화면 회전',
			'settings.keybinding.zoomRotateHint' => 'Shift + 휠',
			'settings.keybinding.zoomPinchGesture' => '핀치',
			'settings.keybinding.zoomTwoFingerRotateGesture' => '두 손가락 회전',
			'settings.gestureControl' => '제스처 제어',
			'settings.leftDoubleTapRewind' => '왼쪽 두 번 탭 되감기',
			'settings.rightDoubleTapFastForward' => '오른쪽 두 번 탭 빨리 감기',
			'settings.doubleTapPause' => '두 번 탭하여 일시정지',
			'settings.rightVerticalSwipeVolume' => '오른쪽 세로 스와이프 볼륨 (새 페이지 진입 시 적용)',
			'settings.leftVerticalSwipeBrightness' => '왼쪽 세로 스와이프 밝기 (새 페이지 진입 시 적용)',
			'settings.longPressFastForward' => '길게 눌러 빨리 감기',
			'settings.enableMouseHoverShowToolbar' => '마우스 오버 시 도구 모음 표시',
			'settings.enableMouseHoverShowToolbarInfo' => '활성화하면 플레이어 위로 마우스를 올리면 동영상 도구 모음이 표시됩니다. 3초 동안 활동이 없으면 자동으로 숨겨집니다.',
			'settings.enableHorizontalDragSeek' => '가로로 밀어 탐색',
			'settings.enableVideoGestureZoom' => '핀치로 동영상 화면 확대',
			'settings.enableVideoGestureZoomInfo' => '두 손가락으로 핀치(데스크톱에서는 Ctrl + 마우스 휠)하면 동영상 화면이 확대되며, 끌어서 이동할 수 있습니다.',
			'settings.showCenterPlayPauseButton' => '중앙 재생/일시정지 버튼',
			'settings.showCenterPlayPauseButtonDesc' => '플레이어 중앙에 큰 재생/일시정지 버튼을 표시합니다.',
			'settings.audioVideoConfig' => '오디오·비디오 설정',
			'settings.expandBuffer' => '버퍼 확장',
			'settings.expandBufferInfo' => '활성화하면 버퍼 크기가 커져 로딩 시간은 길어지지만 재생이 더 부드러워집니다',
			'settings.videoSyncMode' => '동영상 동기화 모드',
			'settings.videoSyncModeSubtitle' => '오디오-비디오 동기화 전략',
			'settings.hardwareDecodingMode' => '하드웨어 디코딩 모드',
			'settings.hardwareDecodingModeSubtitle' => '하드웨어 디코딩 설정',
			'settings.enableHardwareAcceleration' => '하드웨어 가속 사용',
			'settings.enableHardwareAccelerationInfo' => '하드웨어 가속을 사용하면 디코딩 성능이 향상될 수 있지만 일부 기기는 호환되지 않을 수 있습니다',
			'settings.useOpenSLESAudioOutput' => 'OpenSLES 오디오 출력 사용',
			'settings.useOpenSLESAudioOutputInfo' => '저지연 오디오 출력을 사용하여 오디오 성능을 개선할 수 있습니다',
			'settings.videoSyncAudio' => '오디오 동기화',
			'settings.videoSyncDisplayResample' => '리샘플 표시',
			'settings.videoSyncDisplayResampleVdrop' => '리샘플 표시 (프레임 드롭)',
			'settings.videoSyncDisplayResampleDesync' => '리샘플 표시 (비동기화)',
			'settings.videoSyncDisplayTempo' => '템포 표시',
			'settings.videoSyncDisplayVdrop' => '동영상 프레임 드롭 표시',
			'settings.videoSyncDisplayAdrop' => '오디오 프레임 드롭 표시',
			'settings.videoSyncDisplayDesync' => '비동기화 표시',
			'settings.videoSyncDesync' => '비동기화',
			'settings.forumSettings.name' => '포럼',
			'settings.forumSettings.configureYourForumSettings' => '포럼 설정 구성',
			'settings.gallerySettings.gallerySettingsTitle' => '갤러리 설정',
			'settings.gallerySettings.gallerySettingsSubtitle' => '갤러리 뷰어 환경 설정',
			'settings.gallerySettings.defaultViewerQuality' => '기본 뷰어 화질',
			'settings.gallerySettings.defaultViewerQualityDesc' => '갤러리 뷰어를 열 때 기본으로 표시할 이미지 화질을 선택합니다.',
			'settings.blockSettings.title' => '콘텐츠 차단',
			'settings.blockSettings.subtitle' => '제목이 키워드나 패턴과 일치하거나 차단된 사용자의 콘텐츠인 동영상과 갤러리를 자동으로 숨깁니다. 모든 일치 처리는 기기에서 이루어지며 아무것도 업로드되지 않습니다.',
			'settings.blockSettings.blocked' => '차단됨',
			'settings.blockSettings.reveal' => '표시',
			'settings.blockSettings.reblock' => '다시 차단',
			'settings.blockSettings.why' => '차단된 이유',
			'settings.blockSettings.manageRules' => '규칙 관리',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => '제목에 "${value}" 포함',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => '제목이 "${value}"과 일치',
			'settings.blockSettings.reasonUser' => '차단된 사용자',
			'settings.blockSettings.addRule' => '규칙 추가',
			'settings.blockSettings.editRule' => '규칙 편집',
			'settings.blockSettings.deleteRule' => '규칙 삭제',
			'settings.blockSettings.ruleType' => '규칙 유형',
			'settings.blockSettings.keyword' => '키워드',
			'settings.blockSettings.regex' => '정규식',
			'settings.blockSettings.userId' => '사용자',
			'settings.blockSettings.value' => '일치할 텍스트',
			'settings.blockSettings.caseSensitive' => '대소문자 구분',
			'settings.blockSettings.regexHint' => '예: 예고|티저',
			'settings.blockSettings.valueRequired' => '일치할 텍스트를 입력하세요',
			'settings.blockSettings.invalidRegex' => '유효한 정규식이 아닙니다',
			'settings.blockSettings.noRules' => '아직 규칙이 없습니다. +를 눌러 추가하세요.',
			'settings.blockSettings.blockUser' => '차단',
			'settings.blockSettings.unblockUser' => '차단 해제',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => '"${name}"님을 차단하시겠습니까? 해당 사용자의 동영상과 갤러리가 목록과 검색에서 숨겨집니다.',
			'settings.blockSettings.userBlocked' => '사용자를 차단했습니다',
			'settings.blockSettings.userUnblocked' => '사용자 차단을 해제했습니다',
			'settings.blockSettings.exportRules' => '내보내기',
			'settings.blockSettings.importRules' => '가져오기',
			'settings.blockSettings.importExport' => '가져오기 / 내보내기',
			'settings.blockSettings.exportSuccess' => '규칙을 내보냈습니다',
			'settings.blockSettings.exportFailed' => '규칙을 내보내지 못했습니다',
			'settings.blockSettings.importSuccess' => ({required Object count}) => '규칙 ${count}개를 가져왔습니다',
			'settings.blockSettings.importFailed' => '규칙을 가져오지 못했습니다',
			'settings.blockSettings.regexHelp' => '패턴 도움말',
			'settings.blockSettings.regexHelpTitle' => '정규식 참고',
			'settings.blockSettings.regexHelpIntro' => '정규식은 일반 키워드보다 제목을 더 유연하게 일치시킵니다. 몇 가지 일반적인 예시:',
			'settings.blockSettings.regexHelpTapHint' => '예시를 탭하면 자동으로 입력됩니다.',
			'settings.blockSettings.regexEx1Pattern' => '예고|티저|보너스',
			'settings.blockSettings.regexEx1Desc' => '다음 단어 중 하나와 일치합니다 ("|"는 "또는"을 의미)',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => '대괄호로 시작하는 제목',
			'settings.blockSettings.regexEx3Pattern' => '총집편\$',
			'settings.blockSettings.regexEx3Desc' => '제목이 "총집편"으로 끝남',
			'settings.blockSettings.regexEx4Pattern' => '제[0-9]+화',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+는 하나 이상의 숫자, "제12화"와 일치',
			'settings.blockSettings.regexEx5Pattern' => '[0-9]{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9]는 숫자, {4}는 4자리 연속을 의미합니다 (예: 연도)',
			'settings.blockSettings.regexEx1Sample' => '신작 게임 티저 공개',
			'settings.blockSettings.regexEx2Sample' => '[완결] 극장판',
			'settings.blockSettings.regexEx3Sample' => '봄 아트 총집편',
			'settings.blockSettings.regexEx4Sample' => '내 쇼 제12화 요약',
			'settings.blockSettings.regexEx5Sample' => '2024 최고 하이라이트',
			'settings.blockSettings.regexHelpSampleLabel' => '제목 예시',
			'settings.blockSettings.regexHelpMatchedTag' => '차단 대상',
			'settings.blockSettings.regexHelpNoMatch' => '일치 없음',
			'settings.blockSettings.regexEx6Pattern' => '[완미]결',
			'settings.blockSettings.regexEx6Desc' => '[완미]는 "완" 또는 "미" 중 한 글자, "완결"을 잡습니다',
			'settings.blockSettings.regexEx6Sample' => '애니 완결 기념',
			'settings.blockSettings.regexEx7Pattern' => '(예고|광고)영상',
			'settings.blockSettings.regexEx7Desc' => '괄호 ()는 여러 단어를 묶습니다, "예고영상" 또는 "광고영상"과 일치',
			'settings.blockSettings.regexEx7Sample' => '최신 광고영상',
			'settings.blockSettings.regexEx8Pattern' => '예고(편)?',
			'settings.blockSettings.regexEx8Desc' => '(편)?는 "편"이 있어도 없어도 됨, "예고" 또는 "예고편"과 일치',
			'settings.blockSettings.regexEx8Sample' => '신작 예고 공개',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+는 하나 이상을 의미, ㅋ·ㅋㅋ·ㅋㅋㅋ와 일치',
			'settings.blockSettings.regexEx9Sample' => '웃긴ㅋㅋ 동영상',
			'settings.blockSettings.regexEx10Pattern' => '예고.*판',
			'settings.blockSettings.regexEx10Desc' => '.*는 그 사이의 모든 문자와 일치합니다 — "예고 … 판"',
			'settings.blockSettings.regexEx10Sample' => '예고 완전판 공개',
			'settings.chatSettings.name' => '채팅',
			'settings.chatSettings.configureYourChatSettings' => '채팅 설정 구성',
			'settings.hardwareDecodingAuto' => '자동',
			'settings.hardwareDecodingAutoCopy' => '자동 복사',
			'settings.hardwareDecodingAutoSafe' => '자동 안전',
			'settings.hardwareDecodingNo' => '사용 안 함',
			'settings.hardwareDecodingYes' => '강제 사용',
			'settings.cdnDistributionStrategy' => '콘텐츠 배포 전략',
			'settings.cdnDistributionStrategyDesc' => '동영상 소스 서버의 배포 전략을 선택하여 로딩 속도를 최적화합니다',
			'settings.cdnDistributionStrategyLabel' => '배포 전략',
			'settings.cdnDistributionStrategyNoChange' => '변경 안 함 (원본 서버 사용)',
			'settings.cdnDistributionStrategyAuto' => '자동 선택 (가장 빠른 서버)',
			'settings.cdnDistributionStrategySpecial' => '서버 지정',
			'settings.cdnSpecialServer' => '서버 지정',
			'settings.cdnRefreshServerListHint' => '아래 버튼을 눌러 서버 목록을 새로 고침하세요',
			'settings.cdnRefreshButton' => '새로 고침',
			'settings.cdnFastRingServers' => '패스트 링 서버',
			'settings.cdnRefreshServerListTooltip' => '서버 목록 새로 고침',
			'settings.cdnSpeedTestButton' => '속도 테스트',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => '테스트 중 (${count})',
			'settings.cdnNoServerDataHint' => '서버 데이터가 없습니다. 새로 고침 버튼을 눌러 주세요',
			'settings.cdnTestingStatus' => '테스트 중',
			'settings.cdnUnreachableStatus' => '연결할 수 없음',
			'settings.cdnNotTestedStatus' => '테스트 안 됨',
			'settings.downloadSettings.downloadSettings' => '다운로드 설정',
			'settings.downloadSettings.enableDownloadNotifications' => '다운로드 알림',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => '단일 다운로드가 완료되거나 실패하면 시스템 알림을 표시합니다',
			'settings.downloadSettings.notificationPermissionDenied' => '알림 권한이 거부되었습니다. 인앱 알림은 계속 작동하지만, 시스템 알림을 사용하려면 설정에서 활성화하세요.',
			'settings.downloadSettings.storagePermissionStatus' => '저장소 권한 상태',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => '공용 디렉터리 접근에는 저장소 권한이 필요합니다',
			'settings.downloadSettings.checkingPermissionStatus' => '권한 상태 확인 중...',
			'settings.downloadSettings.storagePermissionGranted' => '저장소 권한 부여됨',
			'settings.downloadSettings.storagePermissionNotGranted' => '저장소 권한이 부여되지 않음',
			'settings.downloadSettings.storagePermissionGrantSuccess' => '저장소 권한 부여 성공',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => '저장소 권한 부여에 실패했지만 일부 기능은 제한될 수 있습니다',
			'settings.downloadSettings.storagePermissionRationale' => '선택한 폴더에 다운로드를 저장하려면 앱에 저장소 접근 권한이 필요합니다.\n\nAndroid 11 이상에서는 "모든 파일 접근" 권한을 의미하며, 이것이 없으면 파일은 대신 앱 비공개 폴더에 저장됩니다.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => '선택한 폴더에 다운로드를 저장하려면 앱에 저장소 접근 권한이 필요합니다.\n\n없으면 파일은 대신 앱 비공개 폴더에 저장됩니다.',
			'settings.downloadSettings.grantStoragePermission' => '저장소 권한 부여',
			'settings.downloadSettings.customDownloadPath' => '사용자 지정 다운로드 경로',
			'settings.downloadSettings.customDownloadPathDescription' => '활성화하면 다운로드한 파일의 저장 위치를 사용자 지정할 수 있습니다',
			'settings.downloadSettings.customDownloadPathTip' => '💡 팁: 공용 디렉터리(예: 다운로드 폴더) 선택에는 저장소 권한이 필요하므로 먼저 권장 경로를 사용하는 것이 좋습니다',
			'settings.downloadSettings.androidWarning' => 'Android 참고: 공용 디렉터리(예: 다운로드 폴더)를 선택하지 마세요. 접근 권한을 보장하려면 앱 전용 디렉터리를 사용하는 것이 좋습니다.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ 알림: 공용 디렉터리를 선택하셨습니다. 정상적인 파일 다운로드를 위해서는 저장소 권한이 필요합니다',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => '공용 디렉터리에는 저장소 권한이 필요합니다',
			'settings.downloadSettings.currentDownloadPath' => '현재 다운로드 경로',
			'settings.downloadSettings.actualDownloadPath' => '실제 다운로드 경로',
			'settings.downloadSettings.defaultAppDirectory' => '기본 앱 디렉터리',
			'settings.downloadSettings.permissionGranted' => '부여됨',
			'settings.downloadSettings.permissionRequired' => '권한 필요',
			'settings.downloadSettings.enableCustomDownloadPath' => '사용자 지정 다운로드 경로 사용',
			'settings.downloadSettings.disableCustomDownloadPath' => '비활성화 시 앱 기본 경로 사용',
			'settings.downloadSettings.customDownloadPathLabel' => '사용자 지정 다운로드 경로',
			'settings.downloadSettings.selectDownloadFolder' => '다운로드 폴더 선택',
			'settings.downloadSettings.recommendedPath' => '권장 경로',
			'settings.downloadSettings.selectFolder' => '폴더 선택',
			'settings.downloadSettings.filenameTemplate' => '파일 이름 템플릿',
			'settings.downloadSettings.filenameTemplateDescription' => '다운로드한 파일의 이름 규칙을 사용자 지정하며 변수 치환을 지원합니다',
			'settings.downloadSettings.videoFilenameTemplate' => '동영상 파일 이름 템플릿',
			'settings.downloadSettings.galleryFolderTemplate' => '갤러리 폴더 템플릿',
			'settings.downloadSettings.imageFilenameTemplate' => '이미지 파일 이름 템플릿',
			'settings.downloadSettings.resetToDefault' => '기본값으로 재설정',
			'settings.downloadSettings.supportedVariables' => '지원되는 변수',
			'settings.downloadSettings.supportedVariablesDescription' => '파일 이름 템플릿에서 다음 변수를 사용할 수 있습니다:',
			'settings.downloadSettings.copyVariable' => '변수 복사',
			'settings.downloadSettings.variableCopied' => '변수가 복사되었습니다',
			'settings.downloadSettings.warningPublicDirectory' => '경고: 선택한 공용 디렉터리에 접근할 수 없을 수 있습니다. 앱 전용 디렉터리를 선택하는 것이 좋습니다.',
			'settings.downloadSettings.downloadPathUpdated' => '다운로드 경로가 업데이트되었습니다',
			'settings.downloadSettings.selectPathFailed' => '경로 선택에 실패했습니다',
			'settings.downloadSettings.pickerAlreadyActive' => '폴더 선택기가 이미 열려 있습니다',
			'settings.downloadSettings.unsupportedStorageVolume' => '지원되지 않는 저장 위치입니다. 기기 저장소나 SD 카드의 폴더를 선택하세요.',
			'settings.downloadSettings.recommendedPathSet' => '권장 경로로 설정됨',
			'settings.downloadSettings.setRecommendedPathFailed' => '권장 경로 설정에 실패했습니다',
			'settings.downloadSettings.templateResetToDefault' => '기본 템플릿으로 재설정',
			'settings.downloadSettings.functionalTest' => '기능 테스트',
			'settings.downloadSettings.testInProgress' => '테스트 중...',
			'settings.downloadSettings.runTest' => '테스트 실행',
			'settings.downloadSettings.testDownloadPathAndPermissions' => '다운로드 경로와 권한 설정이 제대로 작동하는지 테스트합니다',
			'settings.downloadSettings.testResults' => '테스트 결과',
			'settings.downloadSettings.testCompleted' => '테스트 완료',
			'settings.downloadSettings.testMultisegmentDomain' => '값 범위 검사(다중 세그먼트 / 초과 / 탈출 형태)',
			'settings.downloadSettings.testMultisegmentPaths' => '다중 세그먼트 구조 렌더링(issue #126)',
			'settings.downloadSettings.testPassed' => '개 항목 통과',
			'settings.downloadSettings.testFailed' => '테스트 실패',
			'settings.downloadSettings.testStoragePermissionCheck' => '저장소 권한 확인',
			'settings.downloadSettings.testStoragePermissionGranted' => '저장소 권한이 부여되었습니다',
			'settings.downloadSettings.testStoragePermissionMissing' => '저장소 권한이 없어 일부 기능이 제한될 수 있습니다',
			'settings.downloadSettings.testPermissionCheckFailed' => '권한 확인에 실패했습니다',
			'settings.downloadSettings.testDownloadPathValidation' => '다운로드 경로 검증',
			'settings.downloadSettings.testPathValidationFailed' => '경로 검증에 실패했습니다',
			'settings.downloadSettings.testFilenameTemplateValidation' => '파일 이름 템플릿 검증',
			'settings.downloadSettings.testAllTemplatesValid' => '모든 템플릿이 유효합니다',
			'settings.downloadSettings.testSomeTemplatesInvalid' => '일부 템플릿에 유효하지 않은 문자가 있습니다',
			'settings.downloadSettings.testTemplateValidationFailed' => '템플릿 검증에 실패했습니다',
			'settings.downloadSettings.testDirectoryOperationTest' => '디렉터리 작업 테스트',
			'settings.downloadSettings.testDirectoryOperationNormal' => '디렉터리 생성과 파일 쓰기가 정상입니다',
			'settings.downloadSettings.testDirectoryOperationFailed' => '디렉터리 작업에 실패했습니다',
			'settings.downloadSettings.testVideoTemplate' => '동영상 템플릿',
			'settings.downloadSettings.testGalleryTemplate' => '갤러리 템플릿',
			'settings.downloadSettings.testImageTemplate' => '이미지 템플릿',
			'settings.downloadSettings.testValid' => '유효함',
			'settings.downloadSettings.testInvalid' => '유효하지 않음',
			'settings.downloadSettings.testSuccess' => '성공',
			'settings.downloadSettings.testCorrect' => '정상',
			'settings.downloadSettings.testError' => '오류',
			'settings.downloadSettings.testPath' => '테스트 경로',
			'settings.downloadSettings.testBasePath' => '기본 경로',
			'settings.downloadSettings.testDirectoryCreation' => '디렉터리 생성',
			'settings.downloadSettings.testFileWriting' => '파일 쓰기',
			'settings.downloadSettings.testFileContent' => '파일 내용',
			'settings.downloadSettings.checkingPathStatus' => '경로 상태 확인 중...',
			'settings.downloadSettings.unableToGetPathStatus' => '경로 상태를 가져올 수 없습니다',
			_ => null,
		} ?? switch (path) {
			'settings.downloadSettings.actualPathDifferentFromSelected' => '참고: 실제 경로가 선택한 경로와 다릅니다',
			'settings.downloadSettings.grantPermission' => '권한 부여',
			'settings.downloadSettings.fixIssue' => '문제 수정',
			'settings.downloadSettings.issueFixed' => '문제가 수정되었습니다',
			'settings.downloadSettings.fixFailed' => '수정에 실패했습니다. 수동으로 처리해 주세요',
			'settings.downloadSettings.lackStoragePermission' => '저장소 권한이 없습니다',
			'settings.downloadSettings.cannotAccessPublicDirectory' => '공용 디렉터리에 접근할 수 없습니다. "모든 파일 접근 권한"이 필요합니다',
			'settings.downloadSettings.cannotCreateDirectory' => '디렉터리를 만들 수 없습니다',
			'settings.downloadSettings.directoryNotWritable' => '디렉터리에 쓸 수 없습니다',
			'settings.downloadSettings.insufficientSpace' => '사용 가능한 공간이 부족합니다',
			'settings.downloadSettings.pathValid' => '경로가 유효합니다',
			'settings.downloadSettings.validationFailed' => '검증에 실패했습니다',
			'settings.downloadSettings.usingDefaultAppDirectory' => '기본 앱 디렉터리 사용 중',
			'settings.downloadSettings.appPrivateDirectory' => '앱 비공개 디렉터리',
			'settings.downloadSettings.appPrivateDirectoryDesc' => '안전하고 신뢰할 수 있으며 추가 권한이 필요하지 않습니다',
			'settings.downloadSettings.downloadDirectory' => '다운로드 디렉터리',
			'settings.downloadSettings.downloadDirectoryDesc' => '시스템 기본 다운로드 위치로 관리하기 쉽습니다',
			'settings.downloadSettings.moviesDirectory' => '동영상 디렉터리',
			'settings.downloadSettings.moviesDirectoryDesc' => '시스템 동영상 디렉터리로 미디어 앱에서 인식할 수 있습니다',
			'settings.downloadSettings.documentsDirectory' => '문서 디렉터리',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOS 앱 문서 디렉터리',
			'settings.downloadSettings.requiresStoragePermission' => '접근하려면 저장소 권한이 필요합니다',
			'settings.downloadSettings.recommendedPaths' => '권장 경로',
			'settings.downloadSettings.externalAppPrivateDirectory' => '외부 앱 비공개 디렉터리',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => '외부 저장소 앱 비공개 디렉터리로 사용자가 접근할 수 있고 공간이 더 큽니다',
			'settings.downloadSettings.internalAppPrivateDirectory' => '내부 앱 비공개 디렉터리',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => '앱 내부 저장소로 권한이 필요하지 않지만 공간이 더 작습니다',
			'settings.downloadSettings.appDocumentsDirectory' => '앱 문서 디렉터리',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => '앱 전용 문서 디렉터리로 안전하고 신뢰할 수 있습니다',
			'settings.downloadSettings.downloadsFolder' => '다운로드 폴더',
			'settings.downloadSettings.downloadsFolderDesc' => '시스템 기본 다운로드 디렉터리',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => '권장 다운로드 위치 선택',
			'settings.downloadSettings.noRecommendedPaths' => '사용 가능한 권장 경로가 없습니다',
			'settings.downloadSettings.recommended' => '권장',
			'settings.downloadSettings.requiresPermission' => '권한 필요',
			'settings.downloadSettings.authorizeAndSelect' => '권한 부여 및 선택',
			'settings.downloadSettings.select' => '선택',
			'settings.downloadSettings.permissionAuthorizationFailed' => '권한 승인에 실패했습니다. 이 경로를 선택할 수 없습니다',
			'settings.downloadSettings.pathValidationFailed' => '경로 검증에 실패했습니다',
			'settings.downloadSettings.downloadPathSetTo' => '다운로드 경로가 다음으로 설정됨',
			'settings.downloadSettings.setPathFailed' => '경로 설정에 실패했습니다',
			'settings.downloadSettings.variableTitle' => '제목',
			'settings.downloadSettings.variableAuthorcache' => '작성자 첫 이름(이름이 바뀌어도 유지)',
			'settings.downloadSettings.variableAuthor' => '작성자 이름',
			'settings.downloadSettings.variableUsername' => '작성자 사용자 이름',
			'settings.downloadSettings.variableQuality' => '동영상 화질',
			'settings.downloadSettings.variableFilename' => '원래 파일 이름',
			'settings.downloadSettings.variableId' => '콘텐츠 ID',
			'settings.downloadSettings.variableCount' => '갤러리 이미지 수',
			'settings.downloadSettings.variableDate' => '현재 날짜 (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => '현재 시간 (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => '현재 날짜 시간 (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => '다운로드 설정',
			'settings.downloadSettings.downloadSettingsSubtitle' => '다운로드 경로와 파일 이름 규칙을 설정합니다',
			'settings.downloadSettings.suchAsTitleQuality' => '예: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => '예: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => '예: %title_%filename',
			'settings.downloadSettings.structureSection' => '저장 구조와 이름 설정',
			'settings.downloadSettings.structureSectionDescription' => '다운로드한 파일은 아래에서 선택한 방식에 따라 하위 폴더로 자동 정리됩니다. 이후 새 다운로드에만 적용되며 기존 파일은 그대로 유지됩니다.',
			'settings.downloadSettings.structureNoticeTitle' => '신규 기능: 작성자별 자동 정리',
			'settings.downloadSettings.structureNoticeBody' => '아래에서 선택하세요 · 새 다운로드에만 적용되고 기존 파일은 그대로입니다.',
			'settings.downloadSettings.presetFlat' => '플랫',
			'settings.downloadSettings.presetFlatDesc' => '모든 파일을 다운로드 루트에 바로 저장',
			'settings.downloadSettings.presetAuthor' => '작성자별',
			'settings.downloadSettings.presetAuthorBadge' => '추천',
			'settings.downloadSettings.presetAuthorDesc' => '작성자별 폴더로 정리 · 이름이 바뀌어도 유지',
			'settings.downloadSettings.presetDate' => '날짜별',
			'settings.downloadSettings.presetDateDesc' => '다운로드 날짜별로 정리',
			'settings.downloadSettings.presetCustom' => '사용자 지정',
			'settings.downloadSettings.presetCustomDesc' => '경로 템플릿을 자유롭게 편집',
			'settings.downloadSettings.presetCustomHint' => '사용자 지정: 경로 템플릿 편집기에서 수정하세요',
			'settings.downloadSettings.structurePreviewLabel' => '미리보기',
			'settings.downloadSettings.structurePreviewNote' => '색상 부분이 정리 계층이며 선택한 방식에 따라 바뀝니다.',
			'settings.downloadSettings.pathTooLongWarning' => '상대 경로가 200자를 초과하여 일부 기기에서는 저장이 실패할 수 있습니다',
			'settings.downloadSettings.pathTemplateEditorEntry' => '사용자 지정 경로 템플릿',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => '폴더 구조와 파일 이름을 직접 결정',
			'settings.downloadSettings.pathTemplateEditor.title' => '경로 템플릿',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => '다운로드 파일을 하위 폴더로 자동 정리',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => '동영상',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => '갤러리',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => '개별 이미지',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => '미리보기 · 정리 후 실제 저장 결과',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => '미리보기 · 갤러리 템플릿=폴더 이름(내부 이미지는 ID로 명명)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => ({required Object current, required Object max}) => '폴더 계층 추가(${current}/${max})',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => '폴더 계층 한도에 도달했습니다',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, 변수 또는 고정 텍스트',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => '예: %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => '확장자(.mp4)는 자동으로 추가됩니다 · 세그먼트 내에서 / 입력 시 두 계층으로 분할 · 최대 ${max}계층',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => '원본 확장자는 자동으로 추가됩니다 · 세그먼트 내에서 / 입력 시 두 계층으로 분할 · 최대 ${max}계층',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => '갤러리 템플릿은 모두 폴더 세그먼트(최대 ${max}계층) · 내부 이미지는 이미지 ID로 명명',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => '탭하여 커서 위치에 삽입 · 길게 눌러 설명 보기',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => '빈 세그먼트',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => '저장할 수 없습니다: 빈 세그먼트를 삭제하거나 내용을 입력하세요',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => '저장할 수 없습니다: 경로 세그먼트 수가 상한(최대 4개)을 초과했습니다. 병합하거나 줄여 주세요',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => '저장할 수 없습니다: 템플릿에 잘못된 문자가 포함되어 있습니다',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => '변수가 삽입되었습니다',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => '저장됨 · 이후 새 다운로드에만 적용',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => '콘텐츠',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => '작성자',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => '시간',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => '작성자 이름·고정',
			'favoriteTags.title' => '즐겨찾기 태그',
			'favoriteTags.emptyIwara' => '아직 즐겨찾기한 Iwara 태그가 없습니다',
			'favoriteTags.emptyOreno3d' => '아직 즐겨찾기가 없습니다',
			'favoriteTags.addIwaraTag' => 'Iwara 태그 추가',
			'favoriteTags.quickPickHint' => '즐겨찾기한 항목은 검색에서 빠른 선택으로 표시됩니다.',
			'favoriteTags.pickerTitle' => 'Oreno3D 선택',
			'favoriteTags.searchHint' => '이름 또는 원본으로 검색',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('ko'))(n, one: '작품 ${n}개', other: '작품 ${n}개', ), 
			'favoriteTags.browseEntry' => '원작 / 캐릭터 / 태그 찾아보기',
			'favoriteTags.favoritesSection' => '즐겨찾기',
			'favoriteTags.addFavorite' => '추가',
			'favoriteTags.iwaraTitle' => '즐겨찾기 Iwara 태그',
			'favoriteTags.oreno3dTitle' => '즐겨찾기 Oreno3D 태그',
			'favoriteTags.changeTag' => '태그 변경',
			'favoriteTags.switchToText' => '텍스트 검색',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => '태그',
			'oreno3d.characters' => '캐릭터',
			'oreno3d.origin' => '출처',
			'oreno3d.thirdPartyTagsExplanation' => '여기에 표시되는 **태그**, **캐릭터**, **출처** 정보는 서드파티 사이트 **Oreno3D**가 참고용으로 제공하는 것입니다.\n\n이 정보 출처는 일본어로만 제공되므로 현재 다국어 지원이 적용되어 있지 않습니다.\n\n다국어 지원에 기여하고 싶으시다면 리포지터리를 방문해 주세요.',
			'oreno3d.sortTypes.hot' => '인기',
			'oreno3d.sortTypes.favorites' => '즐겨찾기',
			'oreno3d.sortTypes.latest' => '최신',
			'oreno3d.sortTypes.popularity' => '인기순',
			'oreno3d.errors.requestFailed' => '요청에 실패했습니다. 상태 코드',
			'oreno3d.errors.connectionTimeout' => '연결 시간이 초과되었습니다. 네트워크 연결을 확인해 주세요',
			'oreno3d.errors.sendTimeout' => '요청 전송 시간이 초과되었습니다',
			'oreno3d.errors.receiveTimeout' => '응답 수신 시간이 초과되었습니다',
			'oreno3d.errors.badCertificate' => '인증서 검증에 실패했습니다',
			'oreno3d.errors.resourceNotFound' => '요청한 리소스를 찾을 수 없습니다',
			'oreno3d.errors.accessDenied' => '액세스가 거부되었습니다. 인증 또는 권한이 필요할 수 있습니다',
			'oreno3d.errors.serverError' => '서버 내부 오류',
			'oreno3d.errors.serviceUnavailable' => '서비스를 일시적으로 사용할 수 없습니다',
			'oreno3d.errors.requestCancelled' => '요청이 취소되었습니다',
			'oreno3d.errors.connectionError' => '네트워크 연결 오류입니다. 네트워크 설정을 확인해 주세요',
			'oreno3d.errors.networkRequestFailed' => '네트워크 요청에 실패했습니다',
			'oreno3d.errors.searchVideoError' => '동영상을 검색하는 중 알 수 없는 오류가 발생했습니다',
			'oreno3d.errors.getPopularVideoError' => '인기 동영상을 가져오는 중 알 수 없는 오류가 발생했습니다',
			'oreno3d.errors.getVideoDetailError' => '동영상 세부 정보를 가져오는 중 알 수 없는 오류가 발생했습니다',
			'oreno3d.errors.parseVideoDetailError' => '동영상 세부 정보를 가져와 분석하는 중 알 수 없는 오류가 발생했습니다',
			'oreno3d.errors.downloadFileError' => '파일을 다운로드하는 중 알 수 없는 오류가 발생했습니다',
			'oreno3d.loading.gettingVideoInfo' => '동영상 정보를 가져오는 중...',
			'oreno3d.loading.cancel' => '취소',
			'oreno3d.messages.videoNotFoundOrDeleted' => '동영상을 찾을 수 없거나 삭제되었습니다',
			'oreno3d.messages.unableToGetVideoPlayLink' => '동영상 재생 링크를 가져올 수 없습니다',
			'oreno3d.messages.getVideoDetailFailed' => '동영상 세부 정보를 가져오지 못했습니다',
			'signIn.pleaseLoginFirst' => '먼저 로그인해 주세요',
			'signIn.alreadySignedInToday' => '오늘은 이미 출석했습니다!',
			'signIn.youDidNotStickToTheSignIn' => '출석을 이어가지 못했습니다.',
			'signIn.signInSuccess' => '출석 완료!',
			'signIn.signInFailed' => '출석에 실패했습니다. 나중에 다시 시도해 주세요',
			'signIn.consecutiveSignIns' => '연속 출석',
			'signIn.failureReason' => '실패 사유',
			'signIn.selectDateRange' => '날짜 범위 선택',
			'signIn.startDate' => '시작일',
			'signIn.endDate' => '종료일',
			'signIn.invalidDate' => '잘못된 날짜',
			'signIn.invalidDateRange' => '잘못된 날짜 범위',
			'signIn.errorFormatText' => '날짜 형식 오류',
			'signIn.errorInvalidText' => '잘못된 날짜 범위',
			'signIn.errorInvalidRangeText' => '잘못된 날짜 범위',
			'signIn.dateRangeCantBeMoreThanOneYear' => '날짜 범위는 1년을 초과할 수 없습니다',
			'signIn.signIn' => '출석',
			'signIn.signInRecord' => '출석 기록',
			'signIn.totalSignIns' => '총 출석',
			'signIn.pleaseSelectSignInStatus' => '출석 상태를 선택해 주세요',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => '구독 목록을 보려면 먼저 로그인해 주세요.',
			'subscriptions.selectUser' => '사용자 선택',
			'subscriptions.noSubscribedUsers' => '구독한 사용자가 없습니다',
			'subscriptions.showAllSubscribedUsersContent' => '구독한 사용자의 모든 콘텐츠 표시',
			'videoDetail.pipMode' => 'PiP 모드',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => '마지막 위치에서 이어서 재생: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => '${position}에서 이어서 재생',
			'videoDetail.restartFromBeginning' => '처음부터 시작',
			'videoDetail.dismissResumeTip' => '닫기',
			'videoDetail.localInfo.videoInfo' => '동영상 정보',
			'videoDetail.localInfo.currentQuality' => '현재 화질',
			'videoDetail.localInfo.duration' => '길이',
			'videoDetail.localInfo.resolution' => '해상도',
			'videoDetail.localInfo.fileInfo' => '파일 정보',
			'videoDetail.localInfo.fileName' => '파일 이름',
			'videoDetail.localInfo.fileSize' => '파일 크기',
			'videoDetail.localInfo.filePath' => '파일 경로',
			'videoDetail.localInfo.copyPath' => '경로 복사',
			'videoDetail.localInfo.openFolder' => '폴더 열기',
			'videoDetail.localInfo.pathCopiedToClipboard' => '경로가 클립보드에 복사되었습니다',
			'videoDetail.localInfo.openFolderFailed' => '폴더를 열지 못했습니다',
			'videoDetail.videoIdIsEmpty' => '동영상 ID가 비어 있습니다',
			'videoDetail.videoInfoIsEmpty' => '동영상 정보가 비어 있습니다',
			'videoDetail.thisIsAPrivateVideo' => '비공개 동영상입니다',
			'videoDetail.getVideoInfoFailed' => '동영상 정보를 가져오지 못했습니다. 나중에 다시 시도해 주세요',
			'videoDetail.noVideoSourceFound' => '동영상 소스를 찾을 수 없습니다',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => '태그 "${tagId}"이(가) 클립보드에 복사되었습니다',
			'videoDetail.errorLoadingVideo' => '동영상을 불러오는 중 오류',
			'videoDetail.play' => '재생',
			'videoDetail.pause' => '일시정지',
			'videoDetail.exitAppFullscreen' => '앱 전체 화면 종료',
			'videoDetail.enterAppFullscreen' => '앱 전체 화면 진입',
			'videoDetail.exitSystemFullscreen' => '시스템 전체 화면 종료',
			'videoDetail.enterSystemFullscreen' => '시스템 전체 화면 진입',
			'videoDetail.seekTo' => '이동',
			'videoDetail.switchResolution' => '해상도 전환',
			'videoDetail.switchPlaybackSpeed' => '재생 속도 전환',
			'videoDetail.rewindSeconds' => ({required Object num}) => '${num}초 되감기',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => '${num}초 빨리 감기',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => '${rate}x 속도로 재생 중',
			'videoDetail.brightness' => '밝기',
			'videoDetail.brightnessLowest' => '밝기가 최저입니다',
			'videoDetail.volume' => '볼륨',
			'videoDetail.volumeMuted' => '볼륨이 음소거되었습니다',
			'videoDetail.restoreDefaultZoom' => '복원',
			'videoDetail.gestureGuide.sampleVideo' => '샘플 영상',
			'videoDetail.gestureGuide.title' => '제스처 및 조작 가이드',
			'videoDetail.gestureGuide.viewGuide' => '제스처 및 조작 가이드',
			'videoDetail.gestureGuide.firstTimeIntro' => '플레이어 제스처를 익히는 데 몇 초만 투자하세요. 이 가이드는 플레이어 설정에서 언제든 다시 열 수 있습니다.',
			'videoDetail.gestureGuide.startWatching' => '알겠습니다, 시청 시작',
			'videoDetail.gestureGuide.basicTitle' => '기본 조작',
			'videoDetail.gestureGuide.zoomTitle' => '확대 / 회전 / 이동',
			'videoDetail.gestureGuide.restoreTip' => '오른쪽 아래의 "복원" 버튼을 탭하여 확대, 회전, 위치를 초기화하세요.',
			'videoDetail.gestureGuide.mTap' => '한 번 탭: 컨트롤 표시 / 숨기기',
			'videoDetail.gestureGuide.mDoubleTap' => '두 번 탭: 되감기(왼쪽) / 일시정지(가운데) / 빨리 감기(오른쪽)',
			'videoDetail.gestureGuide.mHorizontalDrag' => '가로 스와이프: 탐색',
			'videoDetail.gestureGuide.mVerticalDrag' => '세로 스와이프: 밝기(왼쪽) / 볼륨(오른쪽)',
			'videoDetail.gestureGuide.mLongPress' => '길게 누르기: 임시 빨리 감기',
			'videoDetail.gestureGuide.mPinch' => '두 손가락 핀치: 화면 확대/축소',
			'videoDetail.gestureGuide.mRotate' => '두 손가락 회전: 화면 회전',
			'videoDetail.gestureGuide.dTap' => '클릭: 컨트롤 표시 / 숨기기',
			'videoDetail.gestureGuide.dDoubleTap' => '더블 클릭: 되감기(왼쪽) / 일시정지(가운데) / 빨리 감기(오른쪽)',
			'videoDetail.gestureGuide.dKeys' => '탐색 키: 탭하여 뒤로/앞으로 이동, 길게 누르면 빨라짐; 속도 키: 일반 재생 중 재생 속도 단계 조절; Space: 재생 / 일시정지',
			'videoDetail.gestureGuide.dTrackpadPinch' => '트랙패드 핀치: 화면 확대/축소',
			'videoDetail.gestureGuide.dTrackpadRotate' => '트랙패드 회전: 화면 회전',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + 휠: 커서 위치를 중심으로 확대/축소',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + 휠: 커서 위치를 중심으로 회전',
			'videoDetail.gestureGuide.quest.title' => 'Quest에 익숙해지기',
			'videoDetail.gestureGuide.quest.intro' => '어떤 컨트롤이 무엇을 하는지 확인한 뒤 공간에서 사용해 보세요.',
			'videoDetail.gestureGuide.quest.videoTab' => '공간 동영상',
			'videoDetail.gestureGuide.quest.galleryTab' => '공간 갤러리',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Quest 공간의 화면과 창에 적용됩니다. 플레이어 설정에서 언제든 다시 열 수 있습니다.',
			'videoDetail.gestureGuide.quest.catalog' => '컨트롤 살펴보기',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object total, required Object current}) => '${total}개 중 ${current}번째',
			'videoDetail.gestureGuide.quest.previous' => '이전',
			'videoDetail.gestureGuide.quest.next' => '다음 컨트롤',
			'videoDetail.gestureGuide.quest.replay' => '시연 다시 재생',
			'videoDetail.gestureGuide.quest.pauseDemo' => '시연 일시정지',
			'videoDetail.gestureGuide.quest.resumeDemo' => '시연 재개',
			'videoDetail.gestureGuide.quest.looping' => '컨트롤 시연',
			'videoDetail.gestureGuide.quest.still' => '정지 일러스트',
			'videoDetail.gestureGuide.quest.done' => '알겠습니다, 계속',
			'videoDetail.gestureGuide.quest.leftController' => '왼손',
			'videoDetail.gestureGuide.quest.rightController' => '오른손',
			'videoDetail.gestureGuide.quest.trigger' => '검지 트리거',
			'videoDetail.gestureGuide.quest.grip' => '그립 버튼',
			'videoDetail.gestureGuide.quest.bothGrips' => '양쪽 그립 버튼',
			'videoDetail.gestureGuide.quest.stick' => '썸스틱',
			'videoDetail.gestureGuide.quest.handTracking' => '핸드 트래킹',
			'videoDetail.gestureGuide.quest.ready' => '준비',
			'videoDetail.gestureGuide.quest.press' => '누르기',
			'videoDetail.gestureGuide.quest.hold' => '길게 누르기',
			'videoDetail.gestureGuide.quest.release' => '놓기',
			'videoDetail.gestureGuide.quest.result' => '결과 확인',
			'videoDetail.gestureGuide.quest.pinch' => '집기',
			'videoDetail.gestureGuide.quest.selectTitle' => '가리키고 선택',
			'videoDetail.gestureGuide.quest.selectBody' => '광선을 버튼에 맞춘 뒤 검지 트리거를 누르고 놓으세요. 컨트롤 패널의 재생, 설정, 슬라이더에 사용합니다.',
			'videoDetail.gestureGuide.quest.selectHint' => '검지 트리거는 버튼 면 뒤에 있습니다. 안쪽 핸들의 그립 버튼은 창을 잡습니다.',
			'videoDetail.gestureGuide.quest.panelTitle' => '패널 표시 또는 숨기기',
			'videoDetail.gestureGuide.quest.panelBody' => '컨트롤 패널 바깥을 가리킨 뒤 검지 트리거를 탭하여 표시하거나 숨깁니다. 핸드 트래킹에서는 패널 바깥을 빠르게 집어도 같은 동작이 됩니다.',
			'videoDetail.gestureGuide.quest.panelHint' => '끌지 않고 짧게 탭하세요. 누른 채 움직이면 드래그로 처리되어 패널 전환이 되지 않습니다.',
			'videoDetail.gestureGuide.quest.playTitle' => '재생 및 일시정지',
			'videoDetail.gestureGuide.quest.playBody' => '컨트롤 패널에서 벗어난 곳을 가리키고 오른쪽 A 또는 왼쪽 X를 누르면 재생하거나 일시정지합니다. 패널의 재생 버튼을 선택해도 됩니다.',
			'videoDetail.gestureGuide.quest.playHint' => '이 기본 단축키는 공간 플레이어 설정에서 비활성화할 수 있습니다. 패널을 가리키면 입력이 패널로 전달됩니다.',
			'videoDetail.gestureGuide.quest.seekTitle' => '스틱으로 스크럽',
			'videoDetail.gestureGuide.quest.seekBody' => '어느 한 스틱을 좌우로 살짝 밀면 5초 단위로 이동합니다. 계속 누르면 목표 시간을 미리 보며 더 빠르게 스크럽합니다. 놓으면 탐색이 확정됩니다.',
			'videoDetail.gestureGuide.quest.seekHint' => '해당 컨트롤러의 광선을 컨트롤 패널에서 벗어나게 유지하세요. 스틱이 패널을 가리키면 대신 패널이 스크롤됩니다.',
			'videoDetail.gestureGuide.quest.browseTitle' => '스틱으로 탐색',
			'videoDetail.gestureGuide.quest.browseBody' => '어느 한 스틱을 좌우로 움직여 이전/다음 항목으로 이동합니다. 계속 누르면 계속 탐색합니다. 필름스트립에서 썸네일을 선택할 수도 있습니다.',
			'videoDetail.gestureGuide.quest.browseHint' => '갤러리의 동영상도 항목입니다. 컨트롤 패널을 가리키면 스틱이 패널을 스크롤합니다.',
			'videoDetail.gestureGuide.quest.swipeTitle' => '옆으로 끌어 페이지 넘기기',
			'videoDetail.gestureGuide.quest.swipeBody' => '이미지에 광선을 맞추고 검지 트리거를 누른 채 왼쪽으로 끄세요. 페이지 넘김 신호 후 놓으면 넘어가고, 오른쪽으로 끌면 뒤로 갑니다. 집어서 끌어도 됩니다.',
			'videoDetail.gestureGuide.quest.swipeHint' => '이미지를 끌어 페이지를 넘기려면 1배 상태여야 합니다. 갤러리 동영상도 지원합니다. 놓을 때까지 스테이지는 그대로 유지됩니다.',
			'videoDetail.gestureGuide.quest.zoomTitle' => '이미지 확대',
			'videoDetail.gestureGuide.quest.zoomBody' => '이미지의 세부 부분에 광선을 맞추고 검지 트리거를 누른 뒤 스틱을 위로 밀면 확대, 아래로 밀면 축소됩니다. 확대는 누른 지점을 기준으로 고정됩니다.',
			'videoDetail.gestureGuide.quest.zoomHint' => '이미지 창 안의 이미지를 확대합니다. 이미지를 잡지 않은 상태에서는 위/아래가 시청 거리를 조정합니다.',
			'videoDetail.gestureGuide.quest.panTitle' => '이미지 이동 및 복원',
			'videoDetail.gestureGuide.quest.panBody' => '확대한 후 검지 트리거를 누른 채 끌면 주변을 둘러볼 수 있습니다. 이미지를 두 번 탭하면 2.5배로 확대하거나 원래대로 되돌립니다. 손을 사용할 때는 빠르게 두 번 집으세요.',
			'videoDetail.gestureGuide.quest.panHint' => '끌면 확대된 이미지가 이동합니다. 페이지를 넘기려면 1배로 되돌린 후 끌어야 합니다.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => '슬라이드쇼 시작',
			'videoDetail.gestureGuide.quest.slideshowBody' => '이미지에서 A / X는 슬라이드쇼를 시작하거나 일시정지합니다. 패널에서 3초, 5초, 10초, 20초 간격과 일반 또는 원본 화질을 선택할 수 있습니다.',
			'videoDetail.gestureGuide.quest.slideshowHint' => '갤러리 동영상에서는 A / X가 해당 동영상의 재생을 제어합니다. 컨트롤러 단축키는 설정에서 활성화해야 합니다.',
			'videoDetail.gestureGuide.quest.moveTitle' => '화면 잡고 이동',
			'videoDetail.gestureGuide.quest.moveBody' => '안쪽 핸들의 그립 버튼을 누르고 컨트롤러를 움직여 화면을 배치한 뒤 놓으세요. 시청 중에는 화면을 가리키지 않고도 잡을 수 있습니다.',
			'videoDetail.gestureGuide.quest.moveHint' => '앱 창이나 컨트롤 패널을 가리키면 먼저 그 창을 잡습니다. 파노라마 동영상에서는 그립으로 방향을 조정합니다.',
			'videoDetail.gestureGuide.quest.scaleTitle' => '양손으로 크기 조절',
			'videoDetail.gestureGuide.quest.scaleBody' => '양쪽 그립 버튼을 누르세요. 손을 벌리면 화면이 커지고, 모으면 작아집니다. 핸드 트래킹에서는 양손으로 집은 상태를 유지하세요.',
			'videoDetail.gestureGuide.quest.scaleHint' => '갤러리 스테이지를 포함한 평면 및 곡면 화면에 적용됩니다. 광선은 컨트롤 패널에 두지 마세요. 화면 전체의 크기가 조절됩니다.',
			'videoDetail.gestureGuide.quest.distanceTitle' => '시청 거리 조정',
			'videoDetail.gestureGuide.quest.distanceBody' => '스틱을 위로 밀면 화면이 멀어지고, 아래로 밀면 가까워집니다. 창을 잡고 있으면 위/아래로 그 창이 움직입니다. 볼륨은 패널에서 조절하세요.',
			'videoDetail.gestureGuide.quest.distanceHint' => '컨트롤 패널에서 벗어난 곳을 가리키세요. 이미지를 잡고 있으면 위/아래가 이미지 확대/축소로 바뀌고, 파노라마 동영상은 대신 시야가 조정됩니다.',
			'videoDetail.gestureGuide.quest.resizeTitle' => '가장자리와 모서리 사용',
			'videoDetail.gestureGuide.quest.resizeBody' => '광선이 가장자리에 가까워지면 프레임이 빛납니다. 가장자리에서 트리거를 누르거나 집으면 창이 이동하고, 모서리를 끌면 크기가 조절됩니다.',
			'videoDetail.gestureGuide.quest.resizeHint' => '앱 창, 컨트롤 패널, 화면에서 작동합니다. 앱 창은 너비와 높이가 바뀌고, 화면은 화면 비율을 유지합니다.',
			'videoDetail.gestureGuide.quest.navigationTitle' => '뒤로 가기 및 설정 열기',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y는 한 단계 뒤로 갑니다: 팝업을 닫거나 패널 홈으로 돌아가고, 패널을 숨긴 다음 앱으로 돌아갑니다. 왼쪽 Menu 버튼은 공간 설정을 엽니다.',
			'videoDetail.gestureGuide.quest.navigationHint' => '오른쪽 Meta 버튼은 시스템에 속합니다. 시스템 리센터는 화면 크기와 거리를 유지하면서 시야를 정면으로 되돌립니다.',
			'videoDetail.gestureGuide.quest.handsTitle' => '손 사용하기',
			'videoDetail.gestureGuide.quest.handsBody' => '핸드 트래킹을 켜고 시스템 광선을 버튼에 맞춘 뒤 엄지와 검지를 집었다가 놓으세요. 재생, 탐색, 갤러리 이동은 패널을 사용하세요.',
			'videoDetail.gestureGuide.quest.handsHint' => '패널 바깥을 집으면 패널이 전환됩니다. 가장자리를 집으면 이동, 모서리를 집으면 크기 조절, 양손으로 집고 벌리면 화면이 커집니다.',
			'videoDetail.home' => '홈',
			'videoDetail.videoPlayer' => '동영상 플레이어',
			'videoDetail.videoPlayerInfo' => '동영상 플레이어 정보',
			'videoDetail.moreSettings' => '더 많은 설정',
			'videoDetail.videoPlayerFeatureInfo' => '동영상 플레이어 기능 정보',
			'videoDetail.autoRewind' => '자동 되감기',
			'videoDetail.rewindAndFastForward' => '되감기 및 빨리 감기',
			'videoDetail.volumeAndBrightness' => '볼륨 및 밝기',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => '중앙 영역 두 번 탭 일시정지 또는 재생',
			'videoDetail.showVerticalVideoInFullScreen' => '전체 화면에서 세로 동영상 표시',
			'videoDetail.keepLastVolumeAndBrightness' => '마지막 볼륨과 밝기 유지',
			'videoDetail.setProxy' => '프록시 설정',
			'videoDetail.moreFeaturesToBeDiscovered' => '더 많은 기능이 숨어 있습니다...',
			'videoDetail.videoPlayerSettings' => '동영상 플레이어 설정',
			'videoDetail.commentCount' => ({required Object num}) => '댓글 ${num}개',
			'videoDetail.writeYourCommentHere' => '여기에 댓글을 작성하세요...',
			'videoDetail.authorOtherVideos' => '작성자의 다른 동영상',
			'videoDetail.relatedVideos' => '관련 동영상',
			'videoDetail.privateVideo' => '비공개 동영상입니다',
			'videoDetail.externalVideo' => '외부 동영상입니다',
			'videoDetail.openInBrowser' => '브라우저에서 열기',
			'videoDetail.resourceDeleted' => '이 동영상은 삭제된 것 같습니다 :/',
			'videoDetail.noDownloadUrl' => '다운로드 URL이 없습니다',
			'videoDetail.startDownloading' => '다운로드 시작',
			'videoDetail.downloadFailed' => '다운로드에 실패했습니다. 나중에 다시 시도해 주세요',
			'videoDetail.downloadSuccess' => '다운로드 성공',
			'videoDetail.download' => '다운로드',
			'videoDetail.downloadManager' => '다운로드 관리자',
			'videoDetail.resourceNotFound' => '리소스를 찾을 수 없습니다',
			'videoDetail.videoLoadError' => '동영상 로드 오류',
			'videoDetail.authorNoOtherVideos' => '작성자의 다른 동영상이 없습니다',
			'videoDetail.noRelatedVideos' => '관련 동영상이 없습니다',
			'videoDetail.player.errorWhileLoadingVideoSource' => '동영상 소스를 불러오는 중 오류',
			'videoDetail.player.errorWhileSettingUpListeners' => '리스너를 설정하는 중 오류',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => '서버 오류가 감지되어 경로를 자동으로 전환하고 다시 시도합니다',
			'videoDetail.skeleton.fetchingVideoInfo' => '동영상 정보 가져오는 중...',
			'videoDetail.skeleton.fetchingVideoSources' => '동영상 소스 가져오는 중...',
			'videoDetail.skeleton.loadingVideo' => '동영상 불러오는 중...',
			'videoDetail.skeleton.applyingSolution' => '해결 방법 적용 중...',
			'videoDetail.skeleton.addingListeners' => '리스너 추가 중...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => '동영상 길이를 가져왔습니다. 동영상 로드를 시작합니다...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => '로딩 완료',
			'videoDetail.cast.dlnaCast' => '캐스트',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => '캐스트 검색을 시작하지 못했습니다: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => '${deviceName}(으)로 캐스트 시작',
			'videoDetail.cast.castFailed' => ({required Object error}) => '캐스트 실패: ${error}\n기기를 다시 검색하거나 네트워크를 전환해 보세요',
			'videoDetail.cast.castStopped' => '캐스트가 중지되었습니다',
			'videoDetail.cast.deviceTypes.mediaRenderer' => '미디어 플레이어',
			'videoDetail.cast.deviceTypes.mediaServer' => '미디어 서버',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => '라우터',
			'videoDetail.cast.deviceTypes.basicDevice' => '기본 기기',
			'videoDetail.cast.deviceTypes.dimmableLight' => '스마트 조명',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'WLAN 액세스 포인트',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'WLAN 연결 기기',
			'videoDetail.cast.deviceTypes.printer' => '프린터',
			'videoDetail.cast.deviceTypes.scanner' => '스캐너',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => '디지털 보안 카메라',
			'videoDetail.cast.deviceTypes.unknownDevice' => '알 수 없는 기기',
			'videoDetail.cast.currentPlatformNotSupported' => '현재 플랫폼은 캐스트를 지원하지 않습니다',
			'videoDetail.cast.unableToGetVideoUrl' => '동영상 URL을 가져올 수 없습니다. 나중에 다시 시도해 주세요',
			'videoDetail.cast.stopCasting' => '캐스트 중지',
			'videoDetail.cast.dlnaCastSheet.title' => '원격 캐스트',
			'videoDetail.cast.dlnaCastSheet.close' => '닫기',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => '기기 검색 중...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => '검색 버튼을 클릭하여 캐스팅 기기를 다시 검색하세요',
			'videoDetail.cast.dlnaCastSheet.searching' => '검색 중',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => '다시 검색',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => '캐스팅 기기를 찾을 수 없습니다\n기기가 같은 네트워크에 있는지 확인해 주세요',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => '기기를 검색하는 중입니다. 잠시 기다려 주세요...',
			'videoDetail.cast.dlnaCastSheet.cast' => '캐스트',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => '연결됨: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => '연결된 기기가 없습니다',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => '캐스트 중지',
			'videoDetail.likeAvatars.dialogTitle' => '몰래 좋아요를 누른 사람',
			'videoDetail.likeAvatars.dialogDescription' => '누가 좋아하는지 궁금하신가요? 이 "좋아요 앨범"을 넘겨 보세요~',
			'videoDetail.likeAvatars.closeTooltip' => '닫기',
			'videoDetail.likeAvatars.retry' => '다시 시도',
			'videoDetail.likeAvatars.noLikesYet' => '아직 아무도 나타나지 않았습니다. 첫 번째가 되어 보세요!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => '페이지 ${page} / ${totalPages} · 총 ${totalCount}명',
			'videoDetail.likeAvatars.prevPage' => '이전 페이지',
			'videoDetail.likeAvatars.nextPage' => '다음 페이지',
			'share.sharePlayList' => '재생목록 공유',
			'share.wowDidYouSeeThis' => '와, 이거 보셨어요?',
			'share.nameIs' => '이름:',
			'share.clickLinkToView' => '링크를 클릭하여 보기',
			'share.iReallyLikeThis' => '이거 정말 좋아요',
			'share.shareFailed' => '공유에 실패했습니다. 나중에 다시 시도해 주세요',
			'share.share' => '공유',
			'share.shareAsImage' => '이미지로 공유',
			'share.shareAsText' => '텍스트로 공유',
			'share.shareAsImageDesc' => '동영상 커버를 이미지로 공유합니다',
			'share.shareAsTextDesc' => '동영상 세부 정보를 텍스트로 공유합니다',
			'share.shareAsImageFailed' => '동영상 커버를 이미지로 공유하지 못했습니다. 나중에 다시 시도해 주세요',
			'share.shareAsTextFailed' => '동영상 세부 정보를 텍스트로 공유하지 못했습니다. 나중에 다시 시도해 주세요',
			'share.shareVideo' => '동영상 공유',
			'share.authorIs' => '작성자:',
			'share.shareGallery' => '갤러리 공유',
			'share.galleryTitleIs' => '갤러리 제목:',
			'share.galleryAuthorIs' => '갤러리 작성자:',
			'share.shareUser' => '사용자 공유',
			'share.userNameIs' => '사용자 이름:',
			'share.userAuthorIs' => '사용자 작성자:',
			'share.comments' => '댓글',
			'share.shareThread' => '스레드 공유',
			'share.views' => '조회수',
			'share.sharePost' => '게시물 공유',
			'share.postTitleIs' => '게시물 제목:',
			'share.postAuthorIs' => '게시물 작성자:',
			'markdown.markdownSyntax' => 'Markdown 문법',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara 전용 Markdown 문법',
			'markdown.internalLink' => '내부 링크',
			'markdown.supportAutoConvertLinkBelow' => '다음 링크의 자동 변환을 지원합니다:',
			'markdown.convertLinkExample' => '🎬 동영상 링크\n🖼️ 이미지 링크\n👤 사용자 링크\n📌 포럼 링크\n🎵 재생목록 링크\n💬 스레드 링크',
			'markdown.mentionUser' => '사용자 멘션',
			'markdown.mentionUserDescription' => '@ 뒤에 사용자 이름을 입력하면 자동으로 사용자 링크로 변환됩니다',
			'markdown.markdownBasicSyntax' => 'Markdown 기본 문법',
			'markdown.paragraphAndLineBreak' => '문단과 줄 바꿈',
			'markdown.paragraphAndLineBreakDescription' => '문단은 빈 줄로 구분되며, 줄 끝의 공백 두 칸은 줄 바꿈으로 변환됩니다',
			'markdown.paragraphAndLineBreakSyntax' => '첫 번째 문단입니다\n\n두 번째 문단입니다\n이 줄은 공백 두 칸으로 끝나며  \n줄 바꿈으로 변환됩니다',
			'markdown.textStyle' => '텍스트 스타일',
			'markdown.textStyleDescription' => '특수 기호로 텍스트를 감싸 스타일을 변경합니다',
			'markdown.textStyleSyntax' => '**굵은 텍스트**\n*기울임 텍스트*\n~~취소선 텍스트~~\n`코드 텍스트`',
			'markdown.quote' => '인용',
			'markdown.quoteDescription' => '> 기호로 인용을 만들고, >>로 여러 단계 인용을 만듭니다',
			'markdown.quoteSyntax' => '> 1단계 인용입니다\n>> 2단계 인용입니다',
			'markdown.list' => '목록',
			'markdown.listDescription' => '숫자+마침표로 순서 있는 목록을, -로 순서 없는 목록을 만듭니다',
			'markdown.listSyntax' => '1. 첫 번째 항목\n2. 두 번째 항목\n\n- 순서 없는 항목\n  - 하위 항목\n  - 또 다른 하위 항목',
			'markdown.linkAndImage' => '링크와 이미지',
			'markdown.linkAndImageDescription' => '링크 형식: [텍스트](URL)\n이미지 형식: ![설명](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[링크 텍스트](${link})\n![이미지 설명](${imgUrl})',
			'markdown.title' => '제목',
			'markdown.titleDescription' => '# 기호로 제목을 만들고, 개수로 수준을 표시합니다',
			'markdown.titleSyntax' => '# 1단계 제목\n## 2단계 제목\n### 3단계 제목',
			'markdown.separator' => '구분선',
			'markdown.separatorDescription' => '하이픈 세 개 이상으로 구분선을 만듭니다',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => '문법',
			'forum.recent' => '최근',
			'forum.category' => '카테고리',
			'forum.lastReply' => '마지막 답글',
			'forum.sitewide.badge' => '전체 공지',
			'forum.sitewide.title' => '전체 공지',
			'forum.sitewide.readMore' => '더 보기',
			'forum.errors.pleaseSelectCategory' => '카테고리를 선택해 주세요',
			'forum.errors.threadLocked' => '이 스레드는 잠겨 있어 답글을 달 수 없습니다',
			'forum.createPost' => '게시물 작성',
			'forum.title' => '제목',
			'forum.enterTitle' => '제목 입력',
			'forum.content' => '콘텐츠',
			'forum.enterContent' => '내용 입력',
			'forum.writeYourContentHere' => '여기에 내용을 작성하세요...',
			'forum.posts' => '게시물',
			'forum.threads' => '스레드',
			'forum.forum' => '포럼',
			'forum.createThread' => '스레드 만들기',
			'forum.selectCategory' => '카테고리 선택',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => '남은 대기 시간 ${minutes}분 ${seconds}초',
			'forum.groups.administration' => '관리',
			'forum.groups.global' => '글로벌',
			'forum.groups.chinese' => '중국어',
			'forum.groups.japanese' => '일본어',
			'forum.groups.korean' => '한국어',
			'forum.groups.other' => '기타',
			'forum.leafNames.announcements' => '공지',
			'forum.leafNames.feedback' => '피드백',
			'forum.leafNames.support' => '지원',
			'forum.leafNames.general' => '일반',
			'forum.leafNames.guides' => '가이드',
			'forum.leafNames.questions' => '질문',
			'forum.leafNames.requests' => '요청',
			'forum.leafNames.sharing' => '공유',
			'forum.leafNames.general_zh' => '일반',
			'forum.leafNames.questions_zh' => '질문',
			'forum.leafNames.requests_zh' => '요청',
			'forum.leafNames.support_zh' => '지원',
			'forum.leafNames.general_ja' => '일반',
			'forum.leafNames.questions_ja' => '질문',
			'forum.leafNames.requests_ja' => '요청',
			'forum.leafNames.support_ja' => '지원',
			'forum.leafNames.korean' => '한국어',
			'forum.leafNames.other' => '기타',
			'forum.leafDescriptions.announcements' => '공식 중요 알림 및 공지',
			'forum.leafDescriptions.feedback' => '웹사이트 기능과 서비스에 대한 피드백',
			'forum.leafDescriptions.support' => '웹사이트 관련 문제 해결 지원',
			'forum.leafDescriptions.general' => '모든 주제에 대해 토론',
			'forum.leafDescriptions.guides' => '경험과 튜토리얼 공유',
			'forum.leafDescriptions.questions' => '질문을 남기세요',
			'forum.leafDescriptions.requests' => '요청을 올리세요',
			'forum.leafDescriptions.sharing' => '흥미로운 콘텐츠 공유',
			'forum.leafDescriptions.general_zh' => '모든 주제에 대해 토론',
			'forum.leafDescriptions.questions_zh' => '질문을 남기세요',
			'forum.leafDescriptions.requests_zh' => '요청을 올리세요',
			'forum.leafDescriptions.support_zh' => '웹사이트 관련 문제 해결 지원',
			'forum.leafDescriptions.general_ja' => '모든 주제에 대해 토론',
			'forum.leafDescriptions.questions_ja' => '질문을 남기세요',
			'forum.leafDescriptions.requests_ja' => '요청을 올리세요',
			'forum.leafDescriptions.support_ja' => '웹사이트 관련 문제 해결 지원',
			'forum.leafDescriptions.korean' => '한국어 관련 토론',
			'forum.leafDescriptions.other' => '기타 분류되지 않은 콘텐츠',
			'forum.reply' => '답글',
			'forum.pendingReview' => '검토 대기 중',
			'forum.editedAt' => '수정일',
			'forum.copySuccess' => '클립보드에 복사되었습니다',
			'forum.copySuccessForMessage' => ({required Object str}) => '클립보드에 복사됨: ${str}',
			_ => null,
		} ?? switch (path) {
			'forum.editReply' => '답글 편집',
			'forum.editTitle' => '제목 편집',
			'forum.submit' => '제출',
			'notifications.errors.unsupportedNotificationType' => '지원되지 않는 알림 유형',
			'notifications.errors.unknownUser' => '알 수 없는 사용자',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => '지원되지 않는 알림 유형: ${type}',
			'notifications.errors.unknownNotificationType' => '알 수 없는 알림 유형',
			'notifications.notifications' => '알림',
			'notifications.profile' => '프로필',
			'notifications.postedNewComment' => '새 댓글을 게시했습니다',
			'notifications.inYour' => '회원님의',
			'notifications.video' => '동영상',
			'notifications.repliedYourVideoComment' => '회원님의 동영상 댓글에 답글을 남겼습니다',
			'notifications.copyInfoToClipboard' => '알림 정보를 클립보드에 복사',
			'notifications.copySuccess' => '클립보드에 복사되었습니다',
			'notifications.copySuccessForMessage' => ({required Object str}) => '클립보드에 복사되었습니다: ${str}',
			'notifications.markAllAsRead' => '모두 읽음으로 표시',
			'notifications.markAllAsReadSuccess' => '모든 알림을 읽음으로 표시했습니다',
			'notifications.markAllAsReadFailed' => '모두 읽음으로 표시하지 못했습니다',
			'notifications.markSelectedAsRead' => '선택 항목 읽음으로 표시',
			'notifications.markSelectedAsReadSuccess' => '선택한 알림을 읽음으로 표시했습니다',
			'notifications.markSelectedAsReadFailed' => '선택 항목을 읽음으로 표시하지 못했습니다',
			'notifications.markAsRead' => '읽음으로 표시',
			'notifications.markAsReadSuccess' => '알림을 읽음으로 표시했습니다',
			'notifications.markAsReadFailed' => '알림을 읽음으로 표시하지 못했습니다',
			'notifications.notificationTypeHelp' => '알림 유형 도움말',
			'notifications.dueToLackOfNotificationTypeDetails' => '알림 유형 정보가 부족하여 지원되는 유형이 현재 수신하는 메시지를 모두 포함하지 못할 수 있습니다',
			'notifications.helpUsImproveNotificationTypeSupport' => '알림 유형 지원 개선에 도움을 주시겠습니까',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 알림 정보를 복사합니다\n2. 🐞 프로젝트 리포지토리에 이슈를 제출합니다\n\n⚠️ 참고: 알림 정보에는 개인 정보가 포함될 수 있으므로 공개를 원하지 않으시면 프로젝트 작성자에게 이메일로 보내주셔도 됩니다.',
			'notifications.goToRepository' => '리포지토리로 이동',
			'notifications.copy' => '복사',
			'notifications.commentApproved' => '댓글 승인됨',
			'notifications.repliedYourProfileComment' => '회원님의 프로필 댓글에 답글을 남겼습니다',
			'notifications.kReplied' => '회원님의 댓글에 답글을 남겼습니다',
			'notifications.kCommented' => '회원님의 항목에 댓글을 남겼습니다',
			'notifications.kVideo' => '동영상',
			'notifications.kGallery' => '갤러리',
			'notifications.kProfile' => '프로필',
			'notifications.kThread' => '스레드',
			'notifications.kPost' => '게시물',
			'notifications.kCommentSection' => '댓글',
			'notifications.kApprovedComment' => '댓글 승인됨',
			'notifications.kApprovedVideo' => '동영상 승인됨',
			'notifications.kApprovedGallery' => '갤러리 승인됨',
			'notifications.kApprovedThread' => '스레드 승인됨',
			'notifications.kApprovedPost' => '게시물 승인됨',
			'notifications.kApprovedForumPost' => '포럼 게시물 승인됨',
			'notifications.kRejectedContent' => '콘텐츠 검토가 거부되었습니다',
			'notifications.kUnknownType' => '알 수 없는 알림 유형',
			'conversation.errors.pleaseSelectAUser' => '사용자를 선택해 주세요',
			'conversation.errors.pleaseEnterATitle' => '제목을 입력해 주세요',
			'conversation.errors.clickToSelectAUser' => '클릭하여 사용자 선택',
			'conversation.errors.loadFailedClickToRetry' => '불러오기 실패, 클릭하여 재시도',
			'conversation.errors.loadFailed' => '불러오기 실패',
			'conversation.errors.clickToRetry' => '클릭하여 재시도',
			'conversation.errors.noMoreConversations' => '더 이상 대화가 없습니다',
			'conversation.conversation' => '대화',
			'conversation.startConversation' => '대화 시작',
			'conversation.noConversation' => '대화 없음',
			'conversation.selectFromLeftListAndStartConversation' => '왼쪽 목록에서 선택하여 대화를 시작하세요',
			'conversation.title' => '제목',
			'conversation.body' => '본문',
			'conversation.selectAUser' => '사용자 선택',
			'conversation.searchUsers' => '사용자 검색...',
			'conversation.tmpNoConversions' => '변환 없음',
			'conversation.deleteThisMessage' => '이 메시지 삭제',
			'conversation.deleteThisMessageSubtitle' => '이 작업은 되돌릴 수 없습니다',
			'conversation.writeMessageHere' => '여기에 메시지를 작성하세요...',
			'conversation.lastMessageFromMe' => '나: ',
			'conversation.sendMessage' => '메시지 보내기',
			'splash.errors.initializationFailed' => '초기화에 실패했습니다. 앱을 다시 시작해 주세요',
			'splash.preparing' => '준비 중...',
			'splash.initializing' => '초기화 중...',
			'splash.loading' => '로딩 중...',
			'splash.ready' => '준비 완료',
			'splash.initializingMessageService' => '메시지 서비스 초기화 중...',
			'download.errors.imageModelNotFound' => '이미지 모델을 찾을 수 없습니다',
			'download.errors.downloadFailed' => '다운로드 실패',
			'download.errors.videoInfoNotFound' => '동영상 정보를 찾을 수 없습니다',
			'download.errors.downloadTaskAlreadyExists' => '다운로드 작업이 이미 존재합니다',
			'download.errors.downloadTaskSavePathConflict' => '저장 경로가 이미 다른 작업에서 사용 중입니다',
			'download.errors.videoAlreadyDownloaded' => '동영상이 이미 다운로드되었습니다',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => '다운로드 작업 추가 실패: ${errorInfo}',
			'download.errors.userPausedDownload' => '사용자가 다운로드를 일시정지했습니다',
			'download.errors.unknown' => '알 수 없음',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => '파일 시스템 오류: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => '알 수 없는 오류: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => '파일 쓰기 실패: ${errorInfo}',
			'download.errors.connectionTimeout' => '연결 시간 초과',
			'download.errors.sendTimeout' => '전송 시간 초과',
			'download.errors.receiveTimeout' => '수신 시간 초과',
			'download.errors.serverError' => ({required Object errorInfo}) => '서버 오류: ${errorInfo}',
			'download.errors.unknownNetworkError' => '알 수 없는 네트워크 오류',
			'download.errors.sslHandshakeFailed' => 'SSL 핸드셰이크 실패, 네트워크를 확인해 주세요',
			'download.errors.connectionFailed' => '연결에 실패했습니다. 네트워크를 확인해 주세요',
			'download.errors.serviceIsClosing' => '다운로드 서비스가 종료 중입니다',
			'download.errors.partialDownloadFailed' => '부분 콘텐츠 다운로드 실패',
			'download.errors.noDownloadTask' => '다운로드 작업이 없습니다',
			'download.errors.taskNotFoundOrDataError' => '작업을 찾을 수 없거나 데이터 오류입니다',
			'download.errors.fileNotFound' => '파일을 찾을 수 없습니다',
			'download.errors.openFolderFailed' => '폴더를 열지 못했습니다',
			'download.errors.copyDownloadUrlFailed' => '다운로드 URL을 복사하지 못했습니다',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => '폴더를 열지 못했습니다: ${message}',
			'download.errors.directoryNotFound' => '디렉터리를 찾을 수 없습니다',
			'download.errors.copyFailed' => '복사 실패',
			'download.errors.openFileFailed' => '파일을 열지 못했습니다',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => '파일을 열지 못했습니다: ${message}',
			'download.errors.playLocallyFailed' => '로컬 재생 실패',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => '로컬 재생 실패: ${message}',
			'download.errors.noDownloadSource' => '다운로드 소스가 없습니다',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => '다운로드 소스가 없습니다. 정보 로딩이 완료될 때까지 기다린 후 다시 시도해 주세요',
			'download.errors.noActiveDownloadTask' => '활성 다운로드 작업이 없습니다',
			'download.errors.noFailedDownloadTask' => '실패한 다운로드 작업이 없습니다',
			'download.errors.noCompletedDownloadTask' => '완료된 다운로드 작업이 없습니다',
			'download.errors.taskAlreadyCompletedDoNotAdd' => '작업이 이미 완료되었습니다. 다시 추가하지 마세요',
			'download.errors.linkExpiredTryAgain' => '링크가 만료되어 새 다운로드 링크를 가져오는 중입니다',
			'download.errors.linkExpiredTryAgainSuccess' => '링크 만료, 새 다운로드 링크 가져오기 성공',
			'download.errors.linkExpiredTryAgainFailed' => '링크 만료, 새 다운로드 링크 가져오기 실패',
			'download.errors.taskDeleted' => '작업이 삭제되었습니다',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => '지원하지 않는 이미지 형식: ${format}',
			'download.errors.deleteFileError' => '파일을 삭제하지 못했습니다. 다른 프로세스에서 파일을 사용 중일 수 있습니다',
			'download.errors.deleteTaskError' => '작업을 삭제하지 못했습니다',
			'download.errors.canNotRefreshVideoTask' => '동영상 작업을 새로 고치지 못했습니다',
			'download.errors.videoRemovedCanNotRefresh' => '이 동영상이 삭제되었거나 더 이상 존재하지 않아 다운로드 링크를 새로 고칠 수 없습니다',
			'download.errors.videoInaccessibleCanNotRefresh' => '이 동영상에 접근할 수 없습니다. 비공개이거나 다시 로그인해야 할 수 있습니다',
			'download.errors.videoQualityGone' => '이 화질은 더 이상 제공되지 않습니다. 다운로드를 다시 추가해 주세요',
			'download.errors.refreshLinkNetworkFailed' => '네트워크 오류로 지금은 다운로드 링크를 새로 고칠 수 없습니다. 나중에 다시 시도해 주세요',
			'download.errors.taskAlreadyProcessing' => '작업이 이미 처리 중입니다',
			'download.errors.taskNotFound' => '작업을 찾을 수 없습니다',
			'download.errors.failedToLoadTasks' => '작업을 불러오지 못했습니다',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => '부분 다운로드 실패: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => '지원하지 않는 이미지 형식: ${extension}. 기기에 다운로드하여 확인해 보세요',
			'download.errors.imageLoadFailed' => '이미지를 불러오지 못했습니다',
			'download.errors.pleaseTryOtherViewer' => '다른 뷰어로 열어 보세요',
			'download.downloadList' => '다운로드 목록',
			'download.viewDownloadList' => '다운로드 목록 보기',
			'download.download' => '다운로드',
			'download.selectDownloadTitle' => '다운로드 선택',
			'download.qualitySectionLabel' => '화질',
			'download.categorySectionLabel' => '분류',
			'download.saveToPreviewLabel' => '저장될 위치',
			'download.saveToPreviewSuggested' => ({required Object name}) => '추천 파일 이름: ${name}(시스템 대화상자에서 변경 가능)',
			'download.lastUsedBadge' => '최근 사용',
			'download.pickedBadge' => '선택됨',
			'download.startDownloading' => '다운로드 시작',
			'download.clearAllFailedTasks' => '실패한 작업 모두 지우기',
			'download.clearAllFailedTasksConfirmation' => '실패한 다운로드 작업을 모두 지우시겠습니까? 해당 작업의 파일도 함께 삭제됩니다.',
			'download.clearAllFailedTasksSuccess' => '실패한 작업을 모두 지웠습니다',
			'download.clearAllFailedTasksError' => '실패한 작업을 지우는 중 오류가 발생했습니다',
			'download.downloadStatus' => '다운로드 상태',
			'download.imageList' => '이미지 목록',
			'download.retryDownload' => '다운로드 재시도',
			'download.notDownloaded' => '다운로드 안 함',
			'download.downloaded' => '다운로드됨',
			'download.waitingForDownload' => '다운로드 대기 중',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '다운로드 중(${downloaded}/${total} 이미지 ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => '다운로드 중(${downloaded}개 이미지)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => '일시정지됨(${downloaded}/${total} 이미지 ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => '일시정지됨(${downloaded}개 이미지)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => '다운로드 완료(총 ${total}개 이미지)',
			'download.viewVideoDetail' => '동영상 상세 보기',
			'download.viewGalleryDetail' => '갤러리 상세 보기',
			'download.moreOptions' => '더 많은 옵션',
			'download.openFile' => '파일 열기',
			'download.playLocally' => '로컬 재생',
			'download.pause' => '일시정지',
			'download.resume' => '재개',
			'download.copyDownloadUrl' => '다운로드 URL 복사',
			'download.showInFolder' => '폴더에서 보기',
			'download.deleteTask' => '작업 삭제',
			'download.deleteTaskConfirmation' => '이 다운로드 작업을 삭제하시겠습니까?\n작업 파일도 함께 삭제됩니다.',
			'download.forceDeleteTask' => '작업 강제 삭제',
			'download.forceDeleteTaskConfirmation' => '이 다운로드 작업을 강제 삭제하시겠습니까?\n파일이 사용 중이더라도 작업 파일이 삭제됩니다.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '다운로드 중 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => '다운로드 중 ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => '일시정지됨 ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => '일시정지됨 • 다운로드됨 ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => '다운로드됨 • ${size}',
			'download.copyDownloadUrlSuccess' => '다운로드 URL이 복사되었습니다',
			'download.totalImageNums' => ({required Object num}) => '이미지 ${num}개',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => '다운로드 중 ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => '다운로드 중',
			'download.failed' => '실패',
			'download.completed' => '완료됨',
			'download.downloadDetail' => '다운로드 상세',
			'download.copy' => '복사',
			'download.copySuccess' => '복사됨',
			'download.waiting' => '대기 중',
			'download.paused' => '일시정지됨',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => '다운로드 중 ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => '갤러리 다운로드 완료: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => '다운로드 완료: ${fileName}',
			'download.searchTasks' => '작업 검색...',
			'download.statusLabel' => ({required Object label}) => '상태: ${label}',
			'download.allStatus' => '모든 상태',
			'download.typeLabel' => ({required Object label}) => '유형: ${label}',
			'download.allTypes' => '모든 유형',
			'download.taskType' => '유형',
			'download.video' => '동영상',
			'download.gallery' => '갤러리',
			'download.other' => '기타',
			'download.clearFilters' => '필터 지우기',
			'download.pauseAll' => '모두 일시정지',
			'download.resumeAll' => '모두 시작',
			'download.remainingTime' => ({required Object time}) => '${time} 남음',
			'download.timeline.today' => '오늘',
			'download.timeline.yesterday' => '어제',
			'download.timeline.thisWeek' => '이번 주',
			'download.timeline.thisMonth' => '이번 달',
			'download.errorTypes.network' => '네트워크 문제, 재시도하면 해결될 수 있습니다',
			'download.errorTypes.serverRejected' => '서버에서 거부했습니다. 다시 로그인해야 할 수 있습니다',
			'download.errorTypes.notFound' => '리소스가 사라졌거나 삭제되었습니다',
			'download.errorTypes.diskFull' => '저장 공간이 부족합니다',
			'download.errorTypes.fileInUse' => '다른 프로그램에서 파일을 사용 중입니다',
			'download.errorTypes.permission' => '쓰기 권한이 없습니다',
			'download.errorTypes.cancelled' => '취소됨',
			'download.errorTypes.unknown' => '알 수 없는 오류',
			'download.errorDetailCopied' => '오류 세부 정보가 복사되었습니다',
			'download.errorDetailCopyHint' => '길게 눌러 오류 세부 정보 복사',
			'download.restoredPaused.banner' => ({required Object num}) => '지난 세션의 미완료 작업 ${num}개가 일시정지되었습니다',
			'download.restoredPaused.resume' => '모두 재개',
			'download.restoredPaused.dismiss' => '닫기',
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
			'download.emptyTaskList' => '아직 다운로드 작업이 없습니다',
			'download.noMatchingTasks' => '일치하는 작업이 없습니다',
			'download.deleteByDate.menuTitle' => '날짜로 삭제',
			'download.deleteByDate.dialogTitle' => '날짜로 삭제',
			'download.deleteByDate.description' => '생성 날짜별로 다운로드 작업을 일괄 삭제합니다. 파일이 사용 중인 작업은 건너뛰고, 파일이 더 이상 없는 작업은 정리됩니다.',
			'download.deleteByDate.modeRange' => '날짜 범위',
			'download.deleteByDate.modeDays' => '다음보다 오래된',
			'download.deleteByDate.startDate' => '시작일',
			'download.deleteByDate.endDate' => '종료일',
			'download.deleteByDate.notSet' => '설정 안 됨',
			'download.deleteByDate.daysUnit' => '일',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => '${days}일보다 오래 전에 생성된 작업 삭제',
			'download.deleteByDate.noMatch' => '선택한 조건에 맞는 작업이 없습니다',
			'download.deleteByDate.invalidRange' => '시작일은 종료일과 같거나 그보다 앞서야 합니다',
			'download.deleteByDate.confirmTitle' => '삭제 확인',
			'download.deleteByDate.confirmContent' => ({required Object count}) => '${count}개의 다운로드 작업과 해당 파일을 삭제하시겠습니까? 되돌릴 수 없습니다.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => '삭제 중 ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => '${count}개 작업 삭제됨',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => '${deleted}개 작업 삭제됨, ${skipped}개 건너뜀(사용 중)',
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
			'download.category.manageTitle' => '카테고리 관리',
			'download.category.label' => '카테고리',
			'download.category.uncategorized' => '미분류',
			'download.category.manage' => '관리',
			'download.category.createShortcut' => '새로 만들기',
			'download.category.newCategoryHint' => '새 카테고리 이름',
			'download.category.createSuccess' => '카테고리 생성됨',
			'download.category.createFailed' => '카테고리 생성 실패',
			'download.category.nameEmpty' => '카테고리 이름은 비워 둘 수 없습니다',
			'download.category.emptyHint' => '아직 카테고리가 없습니다. 다운로드를 정리할 카테고리를 만들어 보세요.',
			'download.category.moveTo' => '카테고리로 이동',
			'download.category.moveToWithCount' => ({required Object count}) => '${count}개 항목 이동…',
			'download.category.moveSuccess' => ({required Object title}) => '${title}(으)로 이동됨',
			'download.category.moveToUncategorizedSuccess' => '미분류로 이동됨',
			'download.category.moveFailed' => '이동 실패',
			'download.category.renameTitle' => '카테고리 이름 변경',
			'download.category.renameHint' => '카테고리 이름 입력',
			'download.category.renameSuccess' => '카테고리 이름 변경됨',
			'download.category.renameFailed' => '카테고리 이름 변경 실패',
			'download.category.deleteTitle' => '카테고리 삭제',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => '"${title}" 카테고리를 삭제하시겠습니까? 안에 있는 ${count}개 항목은 미분류로 이동합니다. 파일은 삭제되지 않습니다.',
			'download.category.deleteSuccess' => '카테고리 삭제됨',
			'download.category.deleteFailed' => '카테고리 삭제 실패',
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
			'download.maxConcurrentDownloads' => '최대 동시 다운로드 수',
			'download.maxConcurrentDownloadsDesc' => '동시에 다운로드하는 작업 수(1-5)',
			'download.stillInDevelopment' => '아직 개발 중',
			_ => null,
		} ?? switch (path) {
			'download.saveToAppDirectory' => '앱 디렉터리에 저장',
			'download.alreadyDownloadedWithQuality' => '이미 같은 화질로 다운로드되었습니다. 계속 다운로드하시겠습니까?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => '이미 다음 화질로 다운로드됨: ${qualities}, 계속 다운로드하시겠습니까?',
			'download.otherQualities' => '기타 화질',
			'download.batchDownload.title' => '일괄 다운로드',
			'download.batchDownload.downloadTaskAlreadyRunning' => '이미 작업이 실행 중입니다. 잠시 기다려 주세요.',
			'download.batchDownload.userCancelled' => '사용자 취소',
			'download.batchDownload.failedToGetVideoInfo' => '동영상 정보를 가져오지 못했습니다',
			'download.batchDownload.failedToGetVideoSource' => '동영상 소스를 가져오지 못했습니다',
			'download.batchDownload.failedToGetGalleryInfo' => '갤러리 정보를 가져오지 못했습니다',
			'download.batchDownload.galleryNoImages' => '갤러리에 이미지가 없습니다',
			'download.batchDownload.failedToGetSavePath' => '저장 경로를 가져오지 못했습니다',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => '일괄 다운로드 실패: ${exception}',
			'download.batchDownload.selectQuality' => '화질 선택',
			'download.batchDownload.downloading' => '다운로드 중',
			'download.batchDownload.downloadResult' => '다운로드 결과',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => '동영상 ${count}개 선택됨',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => '갤러리 ${count}개 선택됨',
			'download.batchDownload.qualityNote' => '선택한 화질을 사용할 수 없으면 최상의 사용 가능한 화질이 사용됩니다',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => '처리 중 ${current}/${total}',
			'download.batchDownload.queued' => '대기 중',
			'download.batchDownload.success' => '성공',
			'download.batchDownload.skipped' => '건너뜀',
			'download.batchDownload.failed' => '실패',
			'download.batchDownload.failureDetails' => '실패 세부 정보',
			'download.batchDownload.reasonPrivateVideo' => '비공개 동영상',
			'download.batchDownload.reasonAlreadyExists' => '이미 존재함',
			'download.batchDownload.reasonNoSource' => '다운로드 소스 없음',
			'download.batchDownload.reasonNoSavePath' => '저장 경로를 가져올 수 없음',
			'download.batchDownload.reasonOther' => '기타 오류',
			'download.batchDownload.startDownload' => '다운로드 시작',
			'downloadNotifications.completedTitle' => '다운로드 완료',
			'downloadNotifications.failedTitle' => '다운로드 실패',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} 다운로드 성공',
			'downloadNotifications.failedBody' => ({required Object name}) => '${name} 다운로드 실패',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} 다운로드됨',
			'downloadNotifications.failedToast' => ({required Object name}) => '${name} 다운로드 실패',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => '${dir}에 저장됨',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => '${name}(으)로 저장됨(같은 이름의 파일이 이미 있음)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => '앱 폴더에 저장됨 — ${target}에 쓸 수 없음(${reason})',
			'downloadNotifications.viewFolder' => '폴더 보기',
			'downloadNotifications.fixInSettings' => '설정에서 수정',
			'downloadNotifications.channelName' => '다운로드 상태',
			'downloadNotifications.channelDescription' => '완료 및 실패한 다운로드 알림',
			'favorite.errors.addFailed' => '추가 실패',
			'favorite.errors.addSuccess' => '추가 성공',
			'favorite.errors.deleteFolderFailed' => '폴더 삭제 실패',
			'favorite.errors.deleteFolderSuccess' => '폴더 삭제 성공',
			'favorite.errors.folderNameCannotBeEmpty' => '폴더 이름은 비워 둘 수 없습니다',
			'favorite.add' => '추가',
			'favorite.addSuccess' => '추가 성공',
			'favorite.addFailed' => '추가 실패',
			'favorite.remove' => '제거',
			'favorite.removeSuccess' => '제거 성공',
			'favorite.removeFailed' => '제거 실패',
			'favorite.removeConfirmation' => '이 항목을 즐겨찾기에서 제거하시겠습니까?',
			'favorite.removeConfirmationSuccess' => '즐겨찾기에서 항목을 제거했습니다',
			'favorite.removeConfirmationFailed' => '즐겨찾기에서 항목을 제거하지 못했습니다',
			'favorite.createFolderSuccess' => '폴더를 만들었습니다',
			'favorite.createFolderFailed' => '폴더를 만들지 못했습니다',
			'favorite.createFolder' => '폴더 만들기',
			'favorite.enterFolderName' => '폴더 이름 입력',
			'favorite.enterFolderNameHere' => '여기에 폴더 이름을 입력하세요...',
			'favorite.create' => '만들기',
			'favorite.items' => '항목',
			'favorite.newFolderName' => '새 폴더',
			'favorite.searchFolders' => '폴더 검색...',
			'favorite.searchItems' => '항목 검색...',
			'favorite.createdAt' => '생성일',
			'favorite.myFavorites' => '내 즐겨찾기',
			'favorite.deleteFolderTitle' => '폴더 삭제',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => '${title} 폴더를 삭제하시겠습니까?',
			'favorite.removeItemTitle' => '항목 제거',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => '${title} 항목을 삭제하시겠습니까?',
			'favorite.removeItemSuccess' => '즐겨찾기에서 항목을 제거했습니다',
			'favorite.removeItemFailed' => '즐겨찾기에서 항목을 제거하지 못했습니다',
			'favorite.localizeFavorite' => '로컬 즐겨찾기',
			'favorite.editFolderTitle' => '폴더 편집',
			'favorite.editFolderSuccess' => '폴더를 업데이트했습니다',
			'favorite.editFolderFailed' => '폴더를 업데이트하지 못했습니다',
			'favorite.searchTags' => '태그 검색',
			'favorite.noTagsInFolder' => '이 폴더의 항목에 아직 태그가 없습니다',
			'favorite.tagFilterMatchAll' => '선택한 모든 태그를 가진 항목만 표시',
			'favorite.clearSelectedTags' => '선택한 태그 지우기',
			'favorite.selectedTagCount' => ({required Object count}) => '${count}개 선택됨',
			'favorite.noMatchingTags' => '일치하는 태그가 없습니다',
			'translation.currentService' => '현재 서비스',
			'translation.testConnection' => '연결 테스트',
			'translation.testConnectionSuccess' => '연결 테스트 성공',
			'translation.testConnectionFailed' => '연결 테스트에 실패했습니다',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => '연결 테스트 실패: ${message}',
			'translation.translation' => '번역',
			'translation.needVerification' => '확인 필요',
			'translation.needVerificationContent' => 'AI 번역을 활성화하기 전에 먼저 연결을 테스트해 주세요',
			'translation.confirm' => '확인',
			'translation.disclaimer' => '면책 조항',
			'translation.riskWarning' => '위험 경고',
			'translation.dureToRisk1' => '사용자가 생성한 텍스트이므로 AI 서비스 제공자의 콘텐츠 정책을 위반하는 내용이 포함될 수 있습니다',
			'translation.dureToRisk2' => '부적절한 콘텐츠는 API 키 정지나 서비스 종료로 이어질 수 있습니다',
			'translation.operationSuggestion' => '작업 제안',
			'translation.operationSuggestion1' => '1. 번역할 내용을 엄격히 검토하기 전에 사용하세요',
			'translation.operationSuggestion2' => '2. 폭력, 성인 콘텐츠 등이 포함된 내용은 번역하지 마세요',
			'translation.apiConfig' => 'API 설정',
			'translation.modifyConfigWillAutoCloseAITranslation' => '설정을 수정하면 AI 번역이 자동으로 꺼집니다. 켠 후 다시 테스트해야 합니다',
			'translation.apiAddress' => 'API 주소',
			'translation.modelName' => '모델 이름',
			'translation.modelNameHintText' => '예: gpt-4-turbo',
			'translation.maxTokens' => '최대 토큰',
			'translation.maxTokensHintText' => '예: 32000',
			'translation.temperature' => '온도',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => '테스트 버튼을 클릭하여 API 연결 유효성을 확인하세요',
			'translation.requestPreview' => '요청 미리보기',
			'translation.enableAITranslation' => 'AI 사용',
			'translation.enabled' => '사용',
			'translation.disabled' => '사용 안 함',
			'translation.testing' => '테스트 중...',
			'translation.testNow' => '지금 테스트',
			'translation.connectionStatus' => '연결 상태',
			'translation.success' => '성공',
			'translation.failed' => '실패',
			'translation.information' => '정보',
			'translation.viewRawResponse' => '원시 응답 보기',
			'translation.pleaseCheckInputParametersFormat' => '입력 매개변수 형식을 확인해 주세요',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'API 주소, 모델 이름, 키를 입력해 주세요',
			'translation.pleaseFillInValidConfigurationParameters' => '유효한 설정 매개변수를 입력해 주세요',
			'translation.pleaseCompleteConnectionTest' => '연결 테스트를 완료해 주세요',
			'translation.notConfigured' => '설정되지 않음',
			'translation.apiEndpoint' => 'API 엔드포인트',
			'translation.configuredKey' => '설정된 키',
			'translation.notConfiguredKey' => '설정되지 않은 키',
			'translation.authenticationStatus' => '인증 상태',
			'translation.thisFieldCannotBeEmpty' => '이 필드는 비워 둘 수 없습니다',
			'translation.apiKey' => 'API 키',
			'translation.apiKeyCannotBeEmpty' => 'API 키는 비워 둘 수 없습니다',
			'translation.pleaseEnterValidNumber' => '유효한 숫자를 입력하세요',
			'translation.range' => '범위',
			'translation.mustBeGreaterThan' => '다음보다 커야 합니다',
			'translation.invalidAPIResponse' => '잘못된 API 응답',
			'translation.connectionFailedForMessage' => ({required Object message}) => '연결 실패: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI 번역이 활성화되지 않았습니다. 설정에서 활성화해 주세요',
			'translation.goToSettings' => '설정으로 이동',
			'translation.disableAITranslation' => 'AI 번역 비활성화',
			'translation.currentValue' => '현재 값',
			'translation.configureTranslationStrategy' => '번역 전략 구성',
			'translation.advancedSettings' => '고급 설정',
			'translation.translationPrompt' => '번역 프롬프트',
			'translation.promptHint' => '번역 프롬프트를 입력하고, 대상 언어의 자리 표시자로 [TL]을 사용하세요',
			'translation.promptHelperText' => '프롬프트에는 대상 언어의 자리 표시자로 [TL]이 포함되어야 합니다',
			'translation.promptMustContainTargetLang' => '프롬프트에 [TL] 자리 표시자가 있어야 합니다',
			'translation.aiTranslationWillBeDisabled' => 'AI 번역이 비활성화됩니다',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => '기본 설정이 변경되어 AI 번역이 비활성화됩니다',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => '번역 프롬프트가 변경되어 AI 번역이 비활성화됩니다',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => '매개변수 설정이 변경되어 AI 번역이 비활성화됩니다',
			'translation.onlyOpenAIAPISupported' => '현재 OpenAI 호환 API 형식(application/json 요청 본문)만 지원합니다',
			'translation.streamingTranslation' => '스트리밍 번역',
			'translation.streamingTranslationSupported' => '스트리밍 번역 지원됨',
			'translation.streamingTranslationNotSupported' => '스트리밍 번역 지원 안 됨',
			'translation.streamingTranslationDescription' => '스트리밍 번역은 번역 과정에서 결과를 실시간으로 표시하여 더 나은 사용자 경험을 제공합니다',
			'translation.usingFullUrlWithHash' => '전체 URL 사용 (#으로 끝남)',
			'translation.baseUrlInputHelperText' => '#으로 끝나면 실제 요청 주소로 사용됩니다',
			'translation.currentActualUrl' => ({required Object url}) => '현재 실제 URL: ${url}',
			'translation.urlEndingWithHashTip' => '#으로 끝나는 URL은 아무 접미사도 추가하지 않고 그대로 사용됩니다',
			'translation.streamingTranslationWarning' => '참고: 이 기능은 API 서비스의 스트리밍 전송 지원이 필요하며 일부 모델은 지원하지 않을 수 있습니다',
			'translation.translationService' => '번역 서비스',
			'translation.translationServiceDescription' => '사용할 번역 서비스를 선택하세요',
			'translation.googleTranslation' => 'Google 번역',
			'translation.googleTranslationDescription' => '여러 언어를 지원하는 무료 온라인 번역 서비스',
			'translation.aiTranslation' => 'AI 번역',
			'translation.aiTranslationDescription' => '대규모 언어 모델 기반 지능형 번역 서비스',
			'translation.deeplxTranslation' => 'DeepLX 번역',
			'translation.deeplxTranslationDescription' => '고품질 번역을 제공하는 DeepL 번역의 오픈 소스 구현',
			'translation.googleTranslationFeatures' => '기능',
			'translation.freeToUse' => '무료로 사용',
			'translation.freeToUseDescription' => '설정이 필요 없으며 바로 사용할 수 있습니다',
			'translation.fastResponse' => '빠른 응답',
			'translation.fastResponseDescription' => '낮은 지연으로 빠른 번역 속도',
			'translation.stableAndReliable' => '안정적이고 신뢰할 수 있음',
			'translation.stableAndReliableDescription' => 'Google 공식 API 기반',
			'translation.enabledDefaultService' => '사용 - 기본 번역 서비스',
			'translation.notEnabled' => '사용 안 함',
			'translation.deeplxTranslationService' => 'DeepLX 번역 서비스',
			'translation.deeplxDescription' => 'DeepLX는 DeepL 번역의 오픈 소스 구현으로 Free, Pro 및 Official 엔드포인트 모드를 지원합니다',
			'translation.serverAddress' => '서버 주소',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'DeepLX 서버의 기본 주소',
			'translation.endpointType' => '엔드포인트 유형',
			'translation.freeEndpoint' => 'Free - 무료 엔드포인트, 속도 제한이 있을 수 있습니다',
			'translation.proEndpoint' => 'Pro - dl_session 필요, 더 안정적',
			'translation.officialEndpoint' => 'Official - 공식 API 형식',
			'translation.finalRequestUrl' => '최종 요청 URL',
			'translation.apiKeyOptional' => 'API 키 (선택)',
			'translation.apiKeyOptionalHint' => '보호된 DeepLX 서비스에 접근할 때 사용합니다',
			'translation.apiKeyOptionalHelperText' => '일부 DeepLX 서비스는 인증을 위해 API 키가 필요합니다',
			'translation.dlSession' => 'DL 세션',
			'translation.dlSessionHint' => 'Pro 모드에 필요한 dl_session 매개변수',
			'translation.dlSessionHelperText' => 'Pro 엔드포인트에 필요한 세션 매개변수로, DeepL Pro 계정에서 가져옵니다',
			'translation.proModeRequiresDlSession' => 'Pro 모드는 dl_session이 필요합니다',
			'translation.clickTestButtonToVerifyDeepLXAPI' => '테스트 버튼을 클릭하여 DeepLX API 연결을 확인하세요',
			'translation.enableDeepLXTranslation' => 'DeepLX 번역 사용',
			'translation.deepLXTranslationWillBeDisabled' => '설정 변경으로 인해 DeepLX 번역이 비활성화됩니다',
			'translation.translatedResult' => '번역 결과',
			'translation.testSuccess' => '테스트 성공',
			'translation.pleaseFillInDeepLXServerAddress' => 'DeepLX 서버 주소를 입력해 주세요',
			'translation.invalidAPIResponseFormat' => '잘못된 API 응답 형식',
			'translation.translationServiceReturnedError' => '번역 서비스가 오류 또는 빈 결과를 반환했습니다',
			'translation.connectionFailed' => '연결 실패',
			'translation.translationFailed' => '번역에 실패했습니다',
			'translation.aiTranslationFailed' => 'AI 번역에 실패했습니다',
			'translation.deeplxTranslationFailed' => 'DeepLX 번역에 실패했습니다',
			'translation.aiTranslationTestFailed' => 'AI 번역 테스트에 실패했습니다',
			'translation.deeplxTranslationTestFailed' => 'DeepLX 번역 테스트에 실패했습니다',
			'translation.streamingTranslationTimeout' => '스트리밍 번역 시간 초과, 리소스 강제 정리',
			'translation.translationRequestTimeout' => '번역 요청 시간 초과',
			'translation.streamingTranslationDataTimeout' => '스트리밍 번역 데이터 수신 시간 초과',
			'translation.dataReceptionTimeout' => '데이터 수신 시간 초과',
			'translation.streamDataParseError' => '스트림 데이터 구문 분석 오류',
			'translation.streamingTranslationFailed' => '스트리밍 번역에 실패했습니다',
			'translation.fallbackTranslationFailed' => '일반 번역으로의 대체도 실패했습니다',
			'translation.translationSettings' => '번역 설정',
			'translation.enableGoogleTranslation' => 'Google 번역 사용',
			'translation.thinking' => '생각 중...',
			'translation.thoughtProcess' => '사고 과정',
			'translation.modelCompatibility' => '모델 호환성',
			'translation.modelCompatibilityDescription' => '추론 모델(o1/o3, DeepSeek-R1, QwQ) 등 최신 모델에 맞게 요청 매개변수를 조정합니다',
			'translation.reasoningModel' => '추론 모델',
			'translation.reasoningModelDescription' => 'o1/o3, DeepSeek-R1, QwQ 등에 사용합니다. 프롬프트를 사용자 메시지에 합치고, 온도를 생략하며, max_completion_tokens를 사용합니다',
			'translation.useMaxCompletionTokens' => 'max_completion_tokens 사용',
			'translation.useMaxCompletionTokensDescription' => '최신 OpenAI 엔드포인트는 더 이상 사용되지 않는 max_tokens 대신 max_completion_tokens를 요구합니다',
			'translation.sendTemperature' => '온도 전송',
			'translation.sendTemperatureDescription' => '온도 매개변수를 거부하는 모델(대부분의 추론 모델)의 경우 끄세요',
			'translation.showReasoningProcess' => '사고 과정 표시',
			'translation.showReasoningProcessDescription' => '번역 대화 상자에서 추론 모델의 접을 수 있는 추론 과정을 표시합니다',
			'translation.provider' => '제공자',
			'translation.providerOpenAI' => 'OpenAI (및 호환)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'dartantic_ai SDK를 통해 OpenAI(및 모든 OpenAI 호환 엔드포인트), Anthropic, Google을 지원합니다',
			'translation.baseUrlOptionalHelperText' => '선택 사항입니다. 비워 두면 제공자의 기본 엔드포인트를 사용하며, OpenAI 호환/중계 엔드포인트에는 입력하세요',
			'translation.defaultEndpoint' => '기본 엔드포인트',
			'translation.providerPreset' => '제공자 프리셋',
			'translation.selectProviderPreset' => '프리셋 선택',
			'translation.presetCustom' => '사용자 지정',
			'translation.presetApplied' => ({required Object name}) => '프리셋 적용됨: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI 추론 (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude 추론 (확장 사고)',
			'translation.presetNames.gemini' => 'Google Gemini (네이티브)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini 추론 (사고)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek 추론 (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => '모델 목록 가져오기',
			'translation.fetchingModels' => '가져오는 중...',
			'translation.selectModel' => '모델 선택',
			'translation.searchModel' => '모델 검색',
			'translation.noModelsFound' => '모델을 찾을 수 없습니다',
			'bottomNav.video' => '동영상',
			'bottomNav.gallery' => '갤러리',
			'bottomNav.subscription' => '피드',
			'bottomNav.community' => '포럼',
			'bottomNav.localMedia' => '로컬',
			'navigationOrderSettings.title' => '내비게이션 순서 설정',
			'navigationOrderSettings.customNavigationOrder' => '내비게이션 순서 사용자 지정',
			'navigationOrderSettings.customNavigationOrderDesc' => '하단 내비게이션 바와 사이드바에서 페이지 표시 순서를 조정하려면 드래그하세요',
			'navigationOrderSettings.restartRequired' => '앱 재시작 필요',
			'navigationOrderSettings.navigationItemSorting' => '내비게이션 항목 정렬',
			'navigationOrderSettings.done' => '완료',
			'navigationOrderSettings.edit' => '편집',
			'navigationOrderSettings.reset' => '초기화',
			'navigationOrderSettings.previewEffect' => '미리보기 효과',
			'navigationOrderSettings.bottomNavigationPreview' => '하단 내비게이션 미리보기:',
			'navigationOrderSettings.sidebarPreview' => '사이드바 미리보기:',
			'navigationOrderSettings.confirmResetNavigationOrder' => '내비게이션 순서 초기화 확인',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => '내비게이션 순서를 기본 설정으로 초기화하시겠습니까?',
			'navigationOrderSettings.cancel' => '취소',
			'navigationOrderSettings.show' => '표시',
			'navigationOrderSettings.hide' => '숨기기',
			'navigationOrderSettings.hidden' => '숨김',
			'navigationOrderSettings.hideHint' => '커뮤니티와 로컬 파일을 표시하거나 숨기려면 눈 아이콘을 탭하세요',
			'navigationOrderSettings.videoDescription' => '인기 동영상 콘텐츠 탐색',
			'navigationOrderSettings.galleryDescription' => '이미지와 갤러리 탐색',
			'navigationOrderSettings.subscriptionDescription' => '팔로우한 사용자의 최신 콘텐츠 보기',
			'navigationOrderSettings.forumDescription' => '커뮤니티 토론에 참여',
			'navigationOrderSettings.newsDescription' => '공식 뉴스, 기사 및 방송 탐색',
			'navigationOrderSettings.communityDescription' => '포럼 토론과 공식 뉴스, 기사 및 방송',
			'navigationOrderSettings.localMediaDescription' => '이 기기에 저장된 동영상과 이미지 탐색',
			'news.title' => '뉴스',
			'news.newsUpdates' => '뉴스 업데이트',
			'news.articles' => '기사',
			'news.broadcast' => '방송',
			'news.openInBrowser' => '브라우저에서 열기',
			'displaySettings.title' => '화면 설정',
			'displaySettings.layoutSettings' => '레이아웃 설정',
			'displaySettings.layoutSettingsDesc' => '열 수와 중단점 구성을 사용자 지정합니다',
			'displaySettings.gridLayout' => '그리드 레이아웃',
			'displaySettings.navigationOrderSettings' => '내비게이션 순서 설정',
			'displaySettings.customNavigationOrder' => '내비게이션 순서 사용자 지정',
			'displaySettings.customNavigationOrderDesc' => '하단 내비게이션 바와 사이드바에서 페이지 표시 순서를 조정합니다',
			'layoutSettings.title' => '레이아웃 설정',
			'layoutSettings.descriptionTitle' => '레이아웃 구성 설명',
			'layoutSettings.descriptionContent' => '여기서의 구성은 동영상 및 갤러리 목록 페이지에 표시되는 열 수를 결정합니다. 자동 모드를 선택하면 시스템이 화면 너비에 따라 자동으로 조정하고, 수동 모드를 선택하면 열 수를 고정할 수 있습니다.',
			'layoutSettings.layoutMode' => '레이아웃 모드',
			'layoutSettings.reset' => '초기화',
			'layoutSettings.autoMode' => '자동 모드',
			'layoutSettings.autoModeDesc' => '화면 너비에 따라 자동으로 조정',
			'layoutSettings.manualMode' => '수동 모드',
			'layoutSettings.manualModeDesc' => '고정 열 수 사용',
			'layoutSettings.manualSettings' => '수동 설정',
			'layoutSettings.fixedColumns' => '고정 열',
			'layoutSettings.columns' => '열',
			'layoutSettings.breakpointConfig' => '중단점 구성',
			'layoutSettings.add' => '추가',
			'layoutSettings.defaultColumns' => '기본 열 수',
			'layoutSettings.defaultColumnsDesc' => '대형 화면의 기본 표시',
			'layoutSettings.previewEffect' => '미리보기 효과',
			'layoutSettings.screenWidth' => '화면 너비',
			'layoutSettings.addBreakpoint' => '중단점 추가',
			'layoutSettings.editBreakpoint' => '중단점 편집',
			'layoutSettings.deleteBreakpoint' => '중단점 삭제',
			'layoutSettings.screenWidthLabel' => '화면 너비',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => '열',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => '너비를 입력해 주세요',
			'layoutSettings.enterValidWidth' => '올바른 너비를 입력해 주세요',
			'layoutSettings.widthCannotExceed9999' => '너비는 9999를 초과할 수 없습니다',
			'layoutSettings.breakpointAlreadyExists' => '중단점이 이미 존재합니다',
			'layoutSettings.enterColumns' => '열 수를 입력해 주세요',
			'layoutSettings.enterValidColumns' => '올바른 열 수를 입력해 주세요',
			'layoutSettings.columnsCannotExceed12' => '열 수는 12를 초과할 수 없습니다',
			'layoutSettings.breakpointConflict' => '중단점이 이미 존재합니다',
			'layoutSettings.confirmResetLayoutSettings' => '레이아웃 설정 초기화',
			'layoutSettings.confirmResetLayoutSettingsDesc' => '모든 레이아웃 설정을 기본값으로 초기화하시겠습니까?\n\n다음으로 복원됩니다:\n• 자동 모드\n• 기본 중단점 구성',
			'layoutSettings.resetToDefaults' => '기본값으로 초기화',
			'layoutSettings.confirmDeleteBreakpoint' => '중단점 삭제',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => '${width}px 중단점을 삭제하시겠습니까?',
			'layoutSettings.noCustomBreakpoints' => '사용자 지정 중단점이 없어 기본 열 수를 사용합니다',
			'layoutSettings.breakpointRange' => '중단점 범위',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => '편집',
			'layoutSettings.delete' => '삭제',
			'layoutSettings.cancel' => '취소',
			'layoutSettings.save' => '저장',
			'mediaPlayer.videoPlayerError' => '동영상 플레이어 오류',
			'mediaPlayer.videoLoadFailed' => '동영상 로드 실패',
			'mediaPlayer.videoCodecNotSupported' => '동영상 코덱을 지원하지 않음',
			'mediaPlayer.networkConnectionIssue' => '네트워크 연결 문제',
			'mediaPlayer.insufficientPermission' => '권한 부족',
			'mediaPlayer.unsupportedVideoFormat' => '지원하지 않는 동영상 형식',
			'mediaPlayer.retry' => '재시도',
			'mediaPlayer.externalPlayer' => '외부 플레이어',
			'mediaPlayer.detailedErrorInfo' => '상세 오류 정보',
			'mediaPlayer.format' => '형식',
			'mediaPlayer.suggestion' => '제안',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Android 기기는 WEBM 형식 지원이 제한적입니다. 외부 플레이어를 사용하거나 WEBM을 지원하는 플레이어 앱을 다운로드하는 것을 권장합니다',
			'mediaPlayer.currentDeviceCodecNotSupported' => '현재 기기는 이 동영상 형식의 코덱을 지원하지 않습니다',
			'mediaPlayer.checkNetworkConnection' => '네트워크 연결을 확인하고 다시 시도해 주세요',
			'mediaPlayer.appMayLackMediaPermission' => '앱에 필요한 미디어 재생 권한이 없을 수 있습니다',
			'mediaPlayer.tryOtherVideoPlayer' => '다른 동영상 플레이어를 사용해 보세요',
			'mediaPlayer.unrecognizedVideoFormat' => '인식할 수 없는 동영상 파일',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => '링크가 만료되었거나 응답이 동영상이 아닐 수 있습니다. 다시 시도하거나 다른 앱으로 여세요.',
			'mediaPlayer.accessDenied' => '서버가 이 요청을 거부했습니다(403)',
			'mediaPlayer.accessDeniedSuggestion' => '재생 링크가 만료되었을 가능성이 높습니다. 재시도를 눌러 다시 가져오거나 다른 앱으로 여세요.',
			'mediaPlayer.mute' => '음소거',
			'mediaPlayer.unmute' => '음소거 해제',
			'mediaPlayer.video' => '동영상',
			'mediaPlayer.serverSelector' => 'CDN 서버 선택',
			'mediaPlayer.serverSelectorDescription' => '최상의 재생 환경을 위해 지연이 가장 낮은 서버를 선택하세요',
			'mediaPlayer.retestSpeed' => '속도 다시 테스트',
			'mediaPlayer.waitingForSpeedTest' => '속도 테스트 대기 중',
			'mediaPlayer.testingSpeed' => '속도 테스트 중...',
			'mediaPlayer.testFailed' => '테스트 실패',
			'mediaPlayer.loadingServerList' => '서버 목록 불러오는 중...',
			'mediaPlayer.noAvailableServers' => '사용 가능한 서버가 없습니다',
			'mediaPlayer.refreshServerList' => '서버 목록 새로 고침',
			'mediaPlayer.cannotGetSource' => '현재 동영상 소스를 가져올 수 없습니다',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => '서버 전환됨: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => '총 ${count}개 서버',
			'mediaPlayer.statusCode' => ({required Object code}) => '상태 코드: ${code}',
			'mediaPlayer.connectionFailed' => '연결 실패',
			'mediaPlayer.connectionTimeout' => '연결 시간 초과',
			'mediaPlayer.networkError' => '네트워크 오류',
			'mediaPlayer.sslError' => 'SSL 인증서 오류',
			'mediaPlayer.testCompleted' => '테스트 완료',
			'mediaPlayer.local' => '로컬',
			'mediaPlayer.unknown' => '알 수 없음',
			'mediaPlayer.localVideoPathEmpty' => '로컬 동영상 경로가 비어 있습니다',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => '로컬 동영상 파일이 존재하지 않습니다: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => '로컬 동영상을 재생할 수 없습니다: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => '재생할 동영상 파일을 여기에 놓으세요',
			'mediaPlayer.supportedFormats' => '지원 형식: MP4, MKV, AVI, MOV, WEBM 등',
			'mediaPlayer.noSupportedVideoFile' => '지원하는 동영상 파일을 찾을 수 없습니다',
			'mediaPlayer.retryingOpenVideoLink' => '동영상 링크 열기 실패, 재시도 중',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => '디코더를 불러올 수 없습니다: ${event}. 플레이어 설정에서 소프트웨어 디코딩으로 전환한 후 페이지를 다시 들어가 보세요',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => '동영상 로드 오류: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => '반복되는 재생 실패가 감지되었습니다. 설정 > 진단 및 피드백에서 로그를 내보내세요.',
			'mediaPlayer.openSettingsAction' => '보기',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => '재생 알림: ${message}',
			'mediaPlayer.notice.networkUnstable' => '네트워크를 확인하세요. 재생이 끊길 수 있습니다',
			'mediaPlayer.notice.audioTrackUnavailable' => '사용 가능한 소리가 없습니다. 동영상은 계속 재생됩니다',
			'mediaPlayer.notice.hardwareDecodeFellBack' => '소프트웨어 디코딩으로 전환했습니다. 전력을 더 사용할 수 있습니다',
			'mediaPlayer.notice.videoDecodeProblem' => '다른 화질을 시도해 보세요. 화면이 깨질 수 있습니다',
			'mediaPlayer.notice.repeatedPlaybackProblems' => '반복되는 재생 문제를 신고하려면 로그를 내보내세요',
			'mediaPlayer.notice.issuesSheetTitle' => '재생 문제',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => '${count}회 발생',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => '${position} 지점',
			'mediaPlayer.notice.noIssuesRecorded' => '기록된 문제가 없습니다',
			'mediaPlayer.notice.exportLogsAction' => '로그 내보내기',
			'mediaPlayer.imageLoadFailed' => '이미지 로드 실패',
			'mediaPlayer.unsupportedImageFormat' => '지원하지 않는 이미지 형식',
			'mediaPlayer.tryOtherViewer' => '다른 뷰어를 사용해 보세요',
			'diagnostics.infoSectionTitle' => '진단 정보',
			'diagnostics.appVersionLabel' => '앱 버전',
			'diagnostics.memoryUsage' => ({required Object memMB}) => '메모리 사용량: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => '기기 정보를 가져올 수 없습니다',
			'diagnostics.secureStorageLabel' => '보안 저장소',
			'diagnostics.secureStorageHealthy' => '사용 가능',
			'diagnostics.secureStorageRecovered' => '재설정으로 자체 복구됨(이전 데이터 삭제됨)',
			'diagnostics.secureStorageUnavailable' => '사용 불가(로그인이 대체 암호화로 저장됨)',
			'diagnostics.secureStoragePlatformOptOut' => '플랫폼 정책에 따라 로컬 암호화(macOS에서는 시스템 키체인을 사용하지 않음)',
			'diagnostics.secureStorageDualWrite' => ' (이중 쓰기 보호 켜짐)',
			'diagnostics.schemaHealthLabel' => '데이터베이스 스키마',
			'diagnostics.schemaHealthOk' => '확인',
			'diagnostics.schemaHealthRepairedNow' => '이번 실행에서 안전망으로 복구됨(마이그레이션이 적용되지 않음)',
			'diagnostics.schemaHealthRepairedBefore' => '이전에 안전망으로 복구됨',
			'diagnostics.logPolicySectionTitle' => '로그 정책',
			'diagnostics.configServiceUnavailable' => '구성 서비스가 초기화되지 않았습니다. 로그 정책을 조정할 수 없습니다.',
			'diagnostics.enableLoggingTitle' => '로그 기록 사용',
			'diagnostics.enableLoggingSubtitle' => '끄면 새 로그 쓰기를 중지합니다',
			'diagnostics.enableLogPersistenceTitle' => '로그 영구 저장 사용',
			'diagnostics.enableLogPersistenceSubtitle' => '끄면 로그를 메모리에만 유지하고 디스크 쓰기를 중지합니다',
			'diagnostics.minLogLevelTitle' => '최소 로그 수준',
			'diagnostics.minLogLevelSubtitle' => '이 수준 이하의 로그는 필터링됩니다',
			'diagnostics.maxFileSizeTitle' => '단일 파일 크기 제한',
			'diagnostics.maxFileSizeSubtitle' => '임계값에 도달하면 로테이션',
			'diagnostics.rotatedFileCountTitle' => '메인 로그 로테이션 파일 수',
			'diagnostics.rotatedFileCountSubtitle' => '현재 파일을 제외한 보관 파일 수',
			'diagnostics.hangFileSizeTitle' => '멈춤 로그 크기 제한',
			'diagnostics.hangFileSizeSubtitle' => 'hang_events 파일 증가 제어',
			'diagnostics.hangRotatedFileCountTitle' => '멈춤 로그 로테이션 파일 수',
			'diagnostics.hangRotatedFileCountSubtitle' => 'hang_events의 보관 기록 수 제어',
			'diagnostics.healthSectionTitle' => '로그 상태',
			'diagnostics.refreshMetrics' => '지표 새로 고침',
			'diagnostics.toolsSectionTitle' => '도구',
			'diagnostics.privacyNotice' => '로그에는 계정 데이터와 요청 매개변수 등 민감한 정보가 포함될 수 있습니다. 이슈에 전체 로그를 공개하지 말고, 먼저 검토한 후 이메일로 보내세요.',
			'diagnostics.exportLogsTitle' => '로그 내보내기',
			'diagnostics.exportLogsSubtitle' => '개발자에게 보내기 전에 개인정보 데이터를 검토하세요',
			'diagnostics.viewLogsTitle' => '로그 보기',
			'diagnostics.viewLogsSubtitle' => '실행 중인 로그를 실시간으로 확인',
			'diagnostics.copySupportEmailTitle' => '지원 이메일 복사',
			'diagnostics.reportIssueTitle' => '문제 신고',
			'diagnostics.reportIssueSubtitle' => 'GitHub에 재현 단계를 제공하세요(전체 로그 첨부 금지)',
			'diagnostics.healthSummaryUnavailable' => '아직 로그 상태 데이터가 없습니다',
			'diagnostics.healthMetricsUnavailable' => '상태 지표가 아직 수집되지 않았습니다',
			'diagnostics.healthNoRiskIndicators' => '감지된 위험 지표가 없습니다',
			'diagnostics.healthAlert.flushFailureTitle' => '플러시 실패',
			'diagnostics.healthAlert.sinkDegradedTitle' => '로그 쓰기 성능 저하',
			'diagnostics.healthAlert.sinkDegradedDetail' => '파일 싱크가 성능 저하 상태입니다',
			'diagnostics.healthAlert.queueBacklogTitle' => '쓰기 큐 적체',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (임계값=${threshold}, 메모리 사용량이 늘어날 수 있음)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => '플러시 지연 높음',
			'diagnostics.healthAlert.droppedTooManyTitle' => '너무 많은 로그가 누락됨',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (임계값=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => '속도 제한 발동',
			'diagnostics.healthAlert.exportFailedTitle' => '로그 내보내기 실패',
			'diagnostics.healthAlert.fileNearLimitTitle' => '로그 파일이 크기 제한에 근접',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (IO 로테이션 부담 증가)',
			'diagnostics.toast.logServiceNotInitialized' => '로그 서비스가 초기화되지 않았습니다',
			'diagnostics.toast.exportSuccess' => '로그를 내보냈습니다. 이메일로 보내기 전에 개인정보 데이터를 검토하세요.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => '내보내기 실패: ${error}',
			'diagnostics.toast.supportEmailCopied' => '지원 이메일이 복사되었습니다. 메일 클라이언트에 붙여 넣고 로그를 첨부하세요.',
			'diagnostics.shareSubject' => 'LoveIwara 진단 로그(민감한 데이터 포함, 주의해서 공유하세요)',
			'logViewer.title' => '로그 뷰어',
			'logViewer.searchHint' => '로그 검색...',
			'logViewer.emptyState' => '로그 없음',
			'logViewer.copiedToClipboard' => '클립보드에 복사되었습니다',
			'crashRecoveryDialog.title' => '앱이 예기치 않게 종료되었습니다',
			'crashRecoveryDialog.description' => '지난 세션에서 비정상 종료가 감지되었습니다. 진단 로그를 내보내 개발자에게 이메일로 보내 문제 해결에 도움을 주세요.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => '마지막 버전: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => '마지막 실행: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => '마지막 예외: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => '지난번 UI 멈춤이 감지되어 자동으로 복구되었습니다',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => '지난번 UI 멈춤이 감지되었으며 약 ${stalledMs}ms 지속되었습니다',
			'crashRecoveryDialog.exportGuide' => '설정 > 진단 및 피드백 > 로그 내보내기로 이동하세요.',
			'crashRecoveryDialog.privacyHint' => '로그에 개인 정보가 포함되어 있을 수 있습니다. 이메일로 보내기 전에 검토해 주세요:',
			'crashRecoveryDialog.issueWarning' => 'GitHub 이슈에 전체 로그를 공개적으로 첨부하지 마세요',
			'crashRecoveryDialog.acknowledge' => '확인',
			'crashRecoveryDialog.supportEmailCopied' => '이메일이 복사되었습니다',
			'linkInputDialog.title' => '링크 입력',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => '여러 ${webName} 링크를 지능적으로 인식하여 앱의 해당 페이지로 빠르게 이동합니다(링크와 다른 텍스트는 공백으로 구분하세요)',
			'linkInputDialog.inputHint' => ({required Object webName}) => '${webName} 링크를 입력해 주세요',
			'linkInputDialog.validatorEmptyLink' => '링크를 입력해 주세요',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => '유효한 ${webName} 링크가 감지되지 않았습니다',
			'linkInputDialog.multipleLinksDetected' => '여러 링크가 감지되었습니다. 하나를 선택해 주세요:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => '유효한 ${webName} 링크가 아닙니다',
			'linkInputDialog.linkParseError' => ({required Object error}) => '링크 구문 분석 오류: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => '지원하지 않는 링크',
			'linkInputDialog.unsupportedLinkDialogContent' => '이 링크 유형은 앱에서 직접 열 수 없으며 외부 브라우저를 통해 접속해야 합니다.\n\n이 링크를 브라우저에서 여시겠습니까?',
			'linkInputDialog.openInBrowser' => '브라우저에서 열기',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => '브라우저 열기 확인',
			'linkInputDialog.confirmOpenBrowserDialogContent' => '다음 링크를 외부 브라우저에서 열려고 합니다:',
			'linkInputDialog.confirmContinueBrowserOpen' => '계속하시겠습니까?',
			'linkInputDialog.browserOpenFailed' => '링크를 열지 못했습니다',
			'linkInputDialog.unsupportedLink' => '지원하지 않는 링크',
			'linkInputDialog.cancel' => '취소',
			'linkInputDialog.confirm' => '브라우저에서 열기',
			_ => null,
		} ?? switch (path) {
			'log.logManagement' => '로그 관리',
			'log.enableLogPersistence' => '로그 영구 저장 사용',
			'log.enableLogPersistenceDesc' => '분석을 위해 로그를 데이터베이스에 저장',
			'log.logDatabaseSizeLimit' => '로그 데이터베이스 크기 제한',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => '현재: ${size}',
			'log.exportCurrentLogs' => '현재 로그 내보내기',
			'log.exportCurrentLogsDesc' => '개발자가 문제를 진단할 수 있도록 현재 애플리케이션 로그 내보내기',
			'log.exportHistoryLogs' => '기록 로그 내보내기',
			'log.exportHistoryLogsDesc' => '지정한 날짜 범위 내의 로그 내보내기',
			'log.exportMergedLogs' => '병합 로그 내보내기',
			'log.exportMergedLogsDesc' => '지정한 날짜 범위 내의 병합된 로그 내보내기',
			'log.showLogStats' => '로그 통계 보기',
			'log.logExportSuccess' => '로그 내보내기 성공',
			'log.logExportFailed' => ({required Object error}) => '로그 내보내기 실패: ${error}',
			'log.showLogStatsDesc' => '다양한 유형의 로그 통계 보기',
			'log.logExtractFailed' => ({required Object error}) => '로그 통계를 가져오지 못했습니다: ${error}',
			'log.clearAllLogs' => '모든 로그 지우기',
			'log.clearAllLogsDesc' => '모든 로그 데이터 지우기',
			'log.confirmClearAllLogs' => '지우기 확인',
			'log.confirmClearAllLogsDesc' => '모든 로그 데이터를 지우시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'log.clearAllLogsSuccess' => '로그를 지웠습니다',
			'log.clearAllLogsFailed' => ({required Object error}) => '로그 지우기 실패: ${error}',
			'log.unableToGetLogSizeInfo' => '로그 크기 정보를 가져올 수 없습니다',
			'log.currentLogSize' => '현재 로그 크기:',
			'log.logCount' => '로그 수:',
			'log.logCountUnit' => '개',
			'log.logSizeLimit' => '로그 크기 제한:',
			'log.usageRate' => '사용률:',
			'log.exceedLimit' => '한도 초과',
			'log.remaining' => '남음',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => '현재 로그 크기가 초과되었습니다. 오래된 로그를 정리하거나 로그 크기 제한을 늘려 주세요',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => '현재 로그 크기가 거의 초과되었습니다. 오래된 로그를 정리해 주세요',
			'log.cleaningOldLogs' => '오래된 로그 정리 중...',
			'log.logCleaningCompleted' => '로그 정리 완료',
			'log.logCleaningProcessMayNotBeCompleted' => '로그 정리 과정이 완료되지 않았을 수 있습니다',
			'log.cleanExceededLogs' => '초과된 로그 정리',
			'log.noLogsToExport' => '내보낼 로그가 없습니다',
			'log.exportingLogs' => '로그 내보내는 중...',
			'log.noHistoryLogsToExport' => '내보낼 기록 로그가 없습니다. 먼저 앱을 잠시 사용해 보세요',
			'log.selectLogDate' => '로그 날짜 선택',
			'log.today' => '오늘',
			'log.selectMergeRange' => '병합 범위 선택',
			'log.selectMergeRangeHint' => '병합할 로그 시간 범위를 선택해 주세요',
			'log.selectMergeRangeDays' => ({required Object days}) => '최근 ${days}일',
			'log.logStats' => '로그 통계',
			'log.todayLogs' => ({required Object count}) => '오늘 로그: ${count}개',
			'log.recent7DaysLogs' => ({required Object count}) => '최근 7일 로그: ${count}개',
			'log.totalLogs' => ({required Object count}) => '전체 로그: ${count}개',
			'log.setLogDatabaseSizeLimit' => '로그 데이터베이스 크기 제한 설정',
			'log.currentLogSizeWithSize' => ({required Object size}) => '현재 로그 크기: ${size}',
			'log.warning' => '경고',
			'log.newSizeLimit' => ({required Object size}) => '새 크기 제한: ${size}',
			'log.confirmToContinue' => '계속하려면 확인',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => '로그 크기 제한을 ${size}로 설정했습니다',
			'emoji.name' => '이모지',
			'emoji.size' => '크기',
			'emoji.small' => '소',
			'emoji.medium' => '중',
			'emoji.large' => '대',
			'emoji.extraLarge' => '특대',
			'emoji.copyEmojiLinkSuccess' => '이모지 링크가 복사되었습니다',
			'emoji.preview' => '이모지 미리보기',
			'emoji.library' => '이모지 라이브러리',
			'emoji.noEmojis' => '이모지 없음',
			'emoji.clickToAddEmojis' => '오른쪽 위 버튼을 클릭하여 이모지를 추가하세요',
			'emoji.addEmojis' => '이모지 추가',
			'emoji.imagePreview' => '이미지 미리보기',
			'emoji.imageLoadFailed' => '이미지 로드 실패',
			'emoji.loading' => '로딩 중...',
			'emoji.delete' => '삭제',
			'emoji.close' => '닫기',
			'emoji.deleteImage' => '이미지 삭제',
			'emoji.confirmDeleteImage' => '이 이미지를 삭제하시겠습니까?',
			'emoji.cancel' => '취소',
			'emoji.batchDelete' => '일괄 삭제',
			'emoji.confirmBatchDelete' => ({required Object count}) => '선택한 ${count}개 이미지를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'emoji.deleteSuccess' => '삭제되었습니다',
			'emoji.addImage' => '이미지 추가',
			'emoji.addImageByUrl' => 'URL로 추가',
			'emoji.addImageUrl' => '이미지 URL 추가',
			'emoji.imageUrl' => '이미지 URL',
			'emoji.enterImageUrl' => '이미지 URL을 입력해 주세요',
			'emoji.add' => '추가',
			'emoji.batchImport' => '일괄 가져오기',
			'emoji.enterJsonUrlArray' => 'JSON 형식의 URL 배열을 입력해 주세요:',
			'emoji.formatExample' => '형식 예시:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'JSON 형식의 URL 배열을 붙여 넣어 주세요',
			'emoji.import' => '가져오기',
			'emoji.importSuccess' => ({required Object count}) => '이미지 ${count}개를 가져왔습니다',
			'emoji.jsonFormatError' => 'JSON 형식 오류입니다. 입력을 확인해 주세요',
			'emoji.createGroup' => '이모지 그룹 만들기',
			'emoji.groupName' => '그룹 이름',
			'emoji.enterGroupName' => '그룹 이름을 입력해 주세요',
			'emoji.create' => '만들기',
			'emoji.editGroupName' => '그룹 이름 편집',
			'emoji.save' => '저장',
			'emoji.deleteGroup' => '그룹 삭제',
			'emoji.confirmDeleteGroup' => '이 이모지 그룹을 삭제하시겠습니까? 그룹의 모든 이미지도 함께 삭제됩니다.',
			'emoji.imageCount' => ({required Object count}) => '이미지 ${count}개',
			'emoji.selectEmoji' => '이모지 선택',
			'emoji.noEmojisInGroup' => '이 그룹에 이모지가 없습니다',
			'emoji.goToSettingsToAddEmojis' => '설정에서 이모지를 추가하세요',
			'emoji.emojiManagement' => '이모지 관리',
			'emoji.manageEmojiGroupsAndImages' => '이모지 그룹과 이미지 관리',
			'emoji.uploadLocalImages' => '로컬 이미지 업로드',
			'emoji.uploadingImages' => '이미지 업로드 중',
			'emoji.uploadingImagesProgress' => ({required Object count}) => '이미지 ${count}개 업로드 중, 잠시 기다려 주세요...',
			'emoji.doNotCloseDialog' => '이 대화상자를 닫지 마세요',
			'emoji.uploadSuccess' => ({required Object count}) => '이미지 ${count}개를 업로드했습니다',
			'emoji.uploadFailed' => ({required Object count}) => '${count}개 실패',
			'emoji.uploadFailedMessage' => '이미지 업로드 실패, 네트워크 연결 또는 파일 형식을 확인해 주세요',
			'emoji.uploadErrorMessage' => ({required Object error}) => '업로드 중 오류 발생: ${error}',
			'searchFilter.selectField' => '필드 선택',
			'searchFilter.add' => '추가',
			'searchFilter.clear' => '지우기',
			'searchFilter.clearAll' => '모두 지우기',
			'searchFilter.generatedQuery' => '생성된 쿼리',
			'searchFilter.copyToClipboard' => '클립보드에 복사',
			'searchFilter.copied' => '복사됨',
			'searchFilter.filterCount' => ({required Object count}) => '필터 ${count}개',
			'searchFilter.filterSettings' => '필터 설정',
			'searchFilter.field' => '필드',
			'searchFilter.operator' => '연산자',
			'searchFilter.language' => '언어',
			'searchFilter.value' => '값',
			'searchFilter.dateRange' => '날짜 범위',
			'searchFilter.numberRange' => '숫자 범위',
			'searchFilter.from' => '시작',
			'searchFilter.to' => '종료',
			'searchFilter.date' => '날짜',
			'searchFilter.number' => '숫자',
			'searchFilter.boolean' => '불리언',
			'searchFilter.tags' => '태그',
			'searchFilter.select' => '선택',
			'searchFilter.clickToSelectDate' => '클릭하여 날짜 선택',
			'searchFilter.pleaseEnterValidNumber' => '유효한 숫자를 입력하세요',
			'searchFilter.pleaseEnterValidDate' => '유효한 날짜 형식(YYYY-MM-DD)을 입력하세요',
			'searchFilter.startValueMustBeLessThanEndValue' => '시작 값은 끝 값보다 작아야 합니다',
			'searchFilter.startDateMustBeBeforeEndDate' => '시작 날짜는 종료 날짜보다 앞서야 합니다',
			'searchFilter.pleaseFillStartValue' => '시작 값을 입력하세요',
			'searchFilter.pleaseFillEndValue' => '끝 값을 입력하세요',
			'searchFilter.rangeValueFormatError' => '범위 값 형식 오류',
			'searchFilter.contains' => '포함',
			'searchFilter.equals' => '같음',
			'searchFilter.notEquals' => '같지 않음',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => '범위',
			'searchFilter.kIn' => '다음 중 하나 포함',
			'searchFilter.notIn' => '다음 중 하나도 포함하지 않음',
			'searchFilter.username' => '사용자 이름',
			'searchFilter.nickname' => '닉네임',
			'searchFilter.registrationDate' => '가입일',
			'searchFilter.description' => '설명',
			'searchFilter.title' => '제목',
			'searchFilter.body' => '본문',
			'searchFilter.author' => '작성자',
			'searchFilter.publishDate' => '게시일',
			'searchFilter.private' => '비공개',
			'searchFilter.duration' => '길이 (초)',
			'searchFilter.likes' => '좋아요',
			'searchFilter.views' => '조회수',
			'searchFilter.comments' => '댓글',
			'searchFilter.rating' => '등급',
			'searchFilter.imageCount' => '이미지 수',
			'searchFilter.videoCount' => '동영상 수',
			'searchFilter.createDate' => '생성일',
			'searchFilter.content' => '콘텐츠',
			'searchFilter.all' => '전체',
			'searchFilter.adult' => '성인',
			'searchFilter.general' => '일반',
			'searchFilter.yes' => '예',
			'searchFilter.no' => '아니요',
			'searchFilter.users' => '사용자',
			'searchFilter.videos' => '동영상',
			'searchFilter.images' => '이미지',
			'searchFilter.posts' => '게시물',
			'searchFilter.forumThreads' => '포럼 스레드',
			'searchFilter.forumPosts' => '포럼 게시물',
			'searchFilter.playlists' => '재생목록',
			'searchFilter.sortTypes.relevance' => '관련도',
			'searchFilter.sortTypes.latest' => '최신',
			'searchFilter.sortTypes.views' => '조회수',
			'searchFilter.sortTypes.likes' => '좋아요',
			'searchFilter.drawerSubtitle' => '변경 사항이 즉시 적용됩니다',
			'firstTimeSetup.welcome.title' => '환영합니다',
			'firstTimeSetup.welcome.subtitle' => '맞춤 설정 여정을 시작해 볼까요',
			'firstTimeSetup.welcome.description' => '몇 단계만 거치면 최적의 환경을 맞춤 설정할 수 있습니다',
			'firstTimeSetup.basic.title' => '기본 설정',
			'firstTimeSetup.basic.subtitle' => '환경을 개인화하세요',
			'firstTimeSetup.basic.description' => '나에게 맞는 설정을 선택하세요',
			'firstTimeSetup.network.title' => '네트워크 설정',
			'firstTimeSetup.network.subtitle' => '네트워크 옵션 구성',
			'firstTimeSetup.network.description' => '네트워크 환경에 맞게 조정하세요',
			'firstTimeSetup.network.tip' => '구성 성공 후 적용하려면 재시작이 필요합니다',
			'firstTimeSetup.theme.title' => '테마 설정',
			'firstTimeSetup.theme.subtitle' => '원하는 화면 모양을 선택하세요',
			'firstTimeSetup.theme.description' => '시각 경험을 개인화하세요',
			'firstTimeSetup.player.title' => '플레이어 설정',
			'firstTimeSetup.player.subtitle' => '재생 컨트롤 구성',
			'firstTimeSetup.player.description' => '자주 사용하는 재생 설정을 빠르게 지정하세요',
			'firstTimeSetup.spatial.title' => '공간 재생',
			'firstTimeSetup.spatial.subtitle' => '헤드셋에서 시청 및 탐색',
			'firstTimeSetup.spatial.description' => '헤드셋에서는 동영상과 갤러리가 이 떠 있는 패널 안이 아니라 주변 공간에 표시됩니다',
			'firstTimeSetup.completion.title' => '설정 완료',
			'firstTimeSetup.completion.subtitle' => '이제 여정을 시작할 준비가 되었습니다',
			'firstTimeSetup.completion.description' => '관련 약관을 읽고 동의해 주세요',
			'firstTimeSetup.completion.agreementTitle' => '사용자 약관 및 커뮤니티 규칙',
			'firstTimeSetup.completion.agreementDesc' => '이 앱을 사용하기 전에 사용자 약관과 커뮤니티 규칙을 주의 깊게 읽고 동의해 주세요. 이러한 약관은 좋은 환경을 유지하는 데 도움이 됩니다.',
			'firstTimeSetup.completion.checkboxTitle' => '사용자 약관과 커뮤니티 규칙을 읽었으며 이에 동의합니다',
			'firstTimeSetup.completion.checkboxSubtitle' => '동의하지 않으면 앱을 사용할 수 없습니다',
			'firstTimeSetup.common.settingsChangeableTip' => '이 설정은 언제든지 설정에서 변경할 수 있습니다',
			'firstTimeSetup.common.previousStep' => '이전 단계',
			'firstTimeSetup.common.nextStep' => '다음 단계',
			'firstTimeSetup.common.finishSetup' => '설정 완료',
			'firstTimeSetup.common.agreeAgreementSnackbar' => '먼저 사용자 약관과 커뮤니티 규칙에 동의해 주세요',
			'proxyHelper.systemProxyDetected' => '시스템 프록시 감지됨',
			'proxyHelper.copied' => '복사됨',
			'proxyHelper.copy' => '복사',
			'tagSelector.selectTags' => '태그 선택',
			'tagSelector.clickToSelectTags' => '클릭하여 태그 선택',
			'tagSelector.addTag' => '태그 추가',
			'tagSelector.removeTag' => '태그 제거',
			'tagSelector.deleteTag' => '태그 삭제',
			'tagSelector.usageInstructions' => '먼저 태그를 추가한 다음 기존 태그에서 클릭하여 선택하세요',
			'tagSelector.usageInstructionsTooltip' => '사용 방법',
			'tagSelector.addTagTooltip' => '태그 추가',
			'tagSelector.removeTagTooltip' => '태그 제거',
			'tagSelector.cancelSelection' => '선택 취소',
			'tagSelector.selectAll' => '전체 선택',
			'tagSelector.cancelSelectAll' => '전체 선택 취소',
			'tagSelector.delete' => '삭제',
			'anime4k.realTimeVideoUpscalingAndDenoising' => '실시간 영상 업스케일링 및 노이즈 제거로 애니메이션 영상 화질 향상',
			'anime4k.settings' => 'Anime4K 설정',
			'anime4k.preset' => 'Anime4K 프리셋',
			'anime4k.disable' => 'Anime4K 끄기',
			'anime4k.disableDescription' => '영상 향상 효과 끄기',
			'anime4k.highQualityPresets' => '고품질 프리셋',
			'anime4k.fastPresets' => '고속 프리셋',
			'anime4k.litePresets' => '경량 프리셋',
			'anime4k.moreLitePresets' => '초경량 프리셋',
			'anime4k.customPresets' => '사용자 지정 프리셋',
			'anime4k.presetGroups.highQuality' => '고품질',
			'anime4k.presetGroups.fast' => '고속',
			'anime4k.presetGroups.lite' => '경량',
			'anime4k.presetGroups.moreLite' => '초경량',
			'anime4k.presetGroups.custom' => '사용자 지정',
			'anime4k.presetDescriptions.mode_a_hq' => '대부분의 1080p 애니메이션, 특히 블러, 리샘플링 및 압축 아티팩트를 처리하는 영상에 적합합니다. 가장 높은 체감 화질을 제공합니다.',
			'anime4k.presetDescriptions.mode_b_hq' => '스케일링으로 인한 약간의 블러나 링잉이 있는 애니메이션에 적합합니다. 링잉과 계단 현상을 효과적으로 줄일 수 있습니다.',
			'anime4k.presetDescriptions.mode_c_hq' => '고품질 소스(예: 네이티브 1080p 애니메이션 또는 영화)에 적합합니다. 노이즈를 제거하고 가장 높은 PSNR을 제공합니다.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Mode A의 강화 버전으로, 최상의 체감 화질을 제공하며 거의 모든 손상된 선을 복원할 수 있습니다. 과도한 선명화나 링잉이 발생할 수 있습니다.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Mode B의 강화 버전으로, 더 높은 체감 화질을 제공하며 선을 더 최적화하고 아티팩트를 줄입니다.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Mode C의 체감 화질 강화 버전으로, 높은 PSNR을 유지하면서 일부 선 디테일을 복원합니다.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Mode A의 고속 버전으로, 화질과 성능의 균형을 맞추며 대부분의 1080p 애니메이션에 적합합니다.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Mode B의 고속 버전으로, 낮은 부하로 가벼운 아티팩트와 링잉을 처리합니다.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Mode C의 고속 버전으로, 고품질 소스를 빠르게 노이즈 제거하고 업스케일링합니다.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Mode A+A의 고속 버전으로, 성능이 제한된 기기에서 더 높은 체감 화질을 추구합니다.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Mode B+B의 고속 버전으로, 성능이 제한된 기기에 향상된 선 복원과 아티팩트 처리를 제공합니다.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Mode C+A의 고속 버전으로, 고품질 소스를 빠르게 처리하면서 가벼운 선 복원을 제공합니다.',
			'anime4k.presetDescriptions.upscale_only_s' => '가장 빠른 CNN 모델만 사용한 초고속 x2 업스케일링으로, 복원과 노이즈 제거 없이 부하가 최소입니다.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => '기존 비 CNN 알고리즘을 사용한 고속 업스케일링 및 디블러로, 매우 낮은 부하로 기본 플레이어 알고리즘보다 우수합니다.',
			'anime4k.presetDescriptions.restore_s_only' => '가장 빠른 CNN 모델만 사용해 복원하며 업스케일링은 하지 않습니다. 화질을 개선하고 싶은 네이티브 해상도 재생에 적합합니다.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => '기존 양방향 필터를 사용한 고속 노이즈 제거로, 매우 빠르며 가벼운 노이즈 처리에 적합합니다.',
			'anime4k.presetDescriptions.upscale_non_cnn' => '기존 알고리즘을 사용한 고속 업스케일링으로, 부하가 매우 낮고 플레이어 기본값보다 우수합니다.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + 선 어둡게 하기로, 고속 Mode A에 선을 더 진하게 만드는 효과를 추가해 선을 더 뚜렷하고 스타일리시하게 표현합니다.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + 선 얇게 하기로, 고품질 Mode A에 선을 더 가늘게 만드는 효과를 추가해 더 정교하게 표현합니다.',
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
			'anime4k.presetNames.upscale_only_s' => 'CNN 업스케일링(초고속)',
			'anime4k.presetNames.upscale_deblur_fast' => '업스케일링 & 디블러(고속)',
			'anime4k.presetNames.restore_s_only' => '복원(초고속)',
			'anime4k.presetNames.denoise_bilateral_fast' => '양방향 노이즈 제거(초고속)',
			'anime4k.presetNames.upscale_non_cnn' => '비 CNN 업스케일링(초고속)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + 선 어둡게',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + 선 얇게',
			'anime4k.performanceTip' => '💡 팁: 기기 성능에 맞는 프리셋을 선택하세요. 저사양 기기에는 경량 프리셋을 권장합니다.',
			'anime4k.compatibilityTip' => '⚠️ 일부 모바일 GPU(예: Kirin 980 / Mali-G76)는 사용자 지정 셰이더를 렌더링할 수 없습니다. 소리는 나오는데 화면이 검게 변하면 여기에서 Anime4K를 꺼 주세요.',
			'anime4k.autoDisabledOnRenderFailure' => '기기의 GPU가 Anime4K 셰이더를 렌더링하지 못해 자동으로 꺼졌습니다.',
			'siteMode.title' => '사이트 모드',
			'siteMode.mainSite' => '메인',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => '현재 ${currentSite} · 탭하여 ${nextSite} 모드로 전환',
			'siteMode.dialogTitle' => '사이트 모드 전환',
			'siteMode.dialogDescription' => '전환하면 앱 전체가 새로 고쳐지고 이전에 불러온 목록과 페이지 상태가 초기화됩니다.',
			'siteMode.chooseLinkTargetTitle' => '대상 사이트 선택',
			'siteMode.chooseLinkTargetDescription' => '이 링크에는 도메인이 없습니다. 메인 또는 AI로 열지 선택하세요.',
			'siteMode.chooseLinkTargetHint' => '한 번 열면 이 페이지와 이후 세부 요청이 선택한 사이트를 계속 사용합니다.',
			'siteMode.alreadyUsing' => '이미 이 사이트 모드를 사용 중입니다.',
			'siteMode.openInSite' => ({required Object site}) => '${site}에서 열기',
			'siteMode.confirmUsing' => ({required Object site}) => '확인하면 이후 요청은 ${site} 모드를 사용합니다.',
			'siteMode.switched' => ({required Object site}) => '${site} 모드로 전환했습니다. 앱이 새로 고쳐졌습니다.',
			'savedSearchConfig.title' => '저장된 필터',
			'savedSearchConfig.empty' => '저장된 필터가 없습니다',
			'savedSearchConfig.saveTooltip' => '현재 필터 저장',
			'savedSearchConfig.namePromptTitle' => '필터 저장',
			'savedSearchConfig.nameLabel' => '이름',
			'savedSearchConfig.nameHint' => '이름을 입력하세요',
			'savedSearchConfig.saveSuccess' => '필터가 저장되었습니다',
			'savedSearchConfig.deleteSuccess' => '필터가 삭제되었습니다',
			'savedSearchConfig.addCurrent' => '현재 필터 저장',
			'savedSearchConfig.reorderHint' => '길게 눌러 끌어서 순서를 변경하세요',
			'savedSearchConfig.rename' => '이름 바꾸기',
			'savedSearchConfig.unnamed' => '이름 없음',
			'savedSearchConfig.noConditions' => '모든 콘텐츠 (필터 없음)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '태그 ${count}개',
			'savedSearch.title' => '저장된 검색',
			'savedSearch.empty' => '저장된 검색이 없습니다',
			'savedSearch.saveTooltip' => '현재 검색 저장',
			'savedSearch.namePromptTitle' => '검색 저장',
			'savedSearch.nameLabel' => '이름',
			'savedSearch.nameHint' => '이름을 입력하세요',
			'savedSearch.saveSuccess' => '검색이 저장되었습니다',
			'savedSearch.deleteSuccess' => '검색이 삭제되었습니다',
			'savedSearch.addCurrent' => '현재 검색 저장',
			'savedSearch.reorderHint' => '길게 눌러 끌어서 순서를 변경하세요',
			'savedSearch.rename' => '이름 바꾸기',
			'savedSearch.noKeyword' => '(키워드 없음)',
			'savedSearch.filtersCount' => ({required Object count}) => '필터 ${count}개',
			'defaultBlacklistReminder.title' => '기본 태그 블랙리스트가 감지되었습니다',
			'defaultBlacklistReminder.content' => '계정에 웹사이트가 모든 신규 계정에 자동 적용하는 태그 블랙리스트가 아직 사용 중입니다. 검토하고 관리하시겠습니까?',
			'defaultBlacklistReminder.goManage' => '관리',
			'defaultBlacklistReminder.dismiss' => '나중에',
			'colorVisionAssist.title' => '색각 보조',
			'colorVisionAssist.description' => '색각 이상 시청자를 위해 영상 색상을 보정하며, Anime4K와 함께 사용할 수 있습니다',
			'colorVisionAssist.galleryDescription' => '색각 이상 시청자를 위해 갤러리 이미지 색상을 보정합니다(플레이어 스위치와 무관)',
			'colorVisionAssist.galleryDescriptionSpatial' => '색각 이상 시청자를 위해 갤러리 이미지 색상을 보정합니다. 이 패널 내부의 2D 뷰어에만 적용되며, 공간 화면의 이미지는 네이티브로 렌더링되어 이 필터를 거치지 않습니다',
			'colorVisionAssist.disable' => '끄기',
			'colorVisionAssist.disableDescription' => '색상 보정 없음',
			'colorVisionAssist.protanopia' => '적색 보정(제1색각이상)',
			'colorVisionAssist.protanopiaDescription' => '제1색각이상(적색 구분 어려움)용',
			'colorVisionAssist.deuteranopia' => '녹색 보정(제2색각이상)',
			'colorVisionAssist.deuteranopiaDescription' => '제2색각이상(녹색 구분 어려움)용',
			'colorVisionAssist.tritanopia' => '청색 보정(제3색각이상)',
			'colorVisionAssist.tritanopiaDescription' => '제3색각이상(청색과 황색 구분 어려움)용',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} 적용됨, 즉시 적용됩니다',
			'colorVisionAssist.disabledToast' => '색각 보조가 꺼졌습니다',
			'externalPlayer.title' => '다른 앱으로 열기',
			'externalPlayer.description' => '현재 동영상을 이 기기의 다른 플레이어로 전달합니다. VR 헤드셋의 Skybox나 Pigasus, 휴대폰의 MX Player, VLC 등이 있습니다',
			'externalPlayer.openWithOtherApp' => '다른 앱 선택',
			'externalPlayer.openWithOtherAppDescription' => '시스템 선택기를 표시하고 인계할 플레이어를 고릅니다',
			'externalPlayer.openWithSystemPlayer' => '기본 플레이어로 열기',
			'externalPlayer.openWithSystemPlayerDescription' => '시스템 기본 동영상 앱으로 전달합니다',
			'externalPlayer.copyLink' => '동영상 링크 복사',
			'externalPlayer.copyLinkDescription' => 'Skybox나 DeoVR처럼 URL 붙여넣기만 지원하는 플레이어용',
			'externalPlayer.linkCopied' => '동영상 링크가 복사되었습니다',
			'externalPlayer.sourceLocal' => '로컬 파일',
			'externalPlayer.sourceOnline' => '직접 링크',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => '직접 링크 · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => '직접 링크는 만료되므로 외부 플레이어가 중간에 멈출 수 있습니다. 먼저 다운로드하는 것이 안정적입니다.',
			'externalPlayer.vrPlayerHint' => '선택기에 VR 플레이어가 없으면 동영상 링크 복사를 사용해 해당 플레이어 안에 붙여 넣으세요.',
			'externalPlayer.noHandler' => '이 기기에서 동영상을 열 수 있는 앱이 없습니다',
			'externalPlayer.handoffFailed' => ({required Object message}) => '전달 실패: ${message}',
			'externalPlayer.handoffFailedUnknown' => '전달 실패',
			'externalPlayer.sourceUnavailable' => '현재 동영상 주소를 가져올 수 없습니다. 다시 시도해 주세요',
			'externalPlayer.localFileMissing' => '로컬 파일이 더 이상 존재하지 않습니다',
			'externalPlayer.handedOff' => '외부 플레이어로 전달했습니다',
			'externalPlayer.desktopSectionTitle' => '외부 플레이어',
			'externalPlayer.managePlayers' => '외부 플레이어 관리',
			'externalPlayer.managePlayersDescWindows' => 'HereSphere, DeoVR, Whirligig 같은 PCVR 플레이어는 시스템 기본 앱이 아닙니다. 해당 .exe를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.',
			'externalPlayer.managePlayersDescMac' => 'IINA, VLC, mpv 같은 플레이어를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.',
			'externalPlayer.managePlayersDescLinux' => 'mpv, VLC, Celluloid 같은 플레이어를 지정하면 플레이어에서 바로 현재 동영상을 전달할 수 있습니다.',
			'externalPlayer.pickExecutableHintWindows' => '플레이어 설치 폴더 안의 기본 .exe를 선택하세요. 예: HereSphere.exe 또는 vlc.exe. 바탕화면 바로 가기(.lnk)는 작동하지 않습니다.',
			'externalPlayer.pickExecutableHintMac' => 'Applications에서 플레이어의 .app을 선택하세요. 예: IINA.app — 내부의 실제 실행 파일은 자동으로 찾아집니다.',
			'externalPlayer.pickExecutableHintLinux' => '플레이어의 실행 파일을 선택하세요. 예: /usr/bin/mpv. which mpv를 실행하면 위치를 알 수 있습니다.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => '한 번 구성하면 플레이어 페이지의 다른 앱으로 열기 아래에 자체 항목으로 표시됩니다. 일반적인 예: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => '설치된 플레이어를 찾지 못했습니다. 사용자 지정 설치 폴더와 포터블 빌드는 감지할 수 없습니다 — 플레이어 추가로 직접 지정하세요.',
			'externalPlayer.detectNothingNew' => '새 플레이어가 없습니다. 설치된 항목은 이미 목록에 있습니다',
			'externalPlayer.detectFailed' => '감지 실패 — 플레이어 추가로 직접 지정하세요',
			'externalPlayer.advancedOptions' => '고급',
			'externalPlayer.playerNameHint' => '비워 두면 파일 이름을 사용합니다',
			'externalPlayer.executablePathRequired' => '먼저 플레이어의 실행 파일을 선택하세요',
			'externalPlayer.playerCount' => ({required Object count}) => '${count}개 구성됨',
			'externalPlayer.noPlayerConfigured' => '아직 구성된 외부 플레이어가 없습니다',
			'externalPlayer.autoDetect' => '자동 감지',
			'externalPlayer.detecting' => '감지 중…',
			'externalPlayer.detectFound' => ({required Object count}) => '플레이어 ${count}개 발견',
			'externalPlayer.detectNothingFound' => '새 플레이어를 찾지 못했습니다. 직접 추가하세요',
			'externalPlayer.autoDetectedTag' => '감지됨',
			'externalPlayer.addPlayer' => '플레이어 추가',
			'externalPlayer.editPlayer' => '플레이어 편집',
			'externalPlayer.playerName' => '이름',
			'externalPlayer.executablePath' => '실행 파일',
			'externalPlayer.browse' => '찾아보기',
			'externalPlayer.argumentTemplate' => '실행 인수',
			'externalPlayer.argumentTemplateHint' => '동영상 경로나 URL에는 {input}을 사용하세요. 비워 두면 유일한 인수로 전달됩니다.',
			'externalPlayer.nameAndPathRequired' => '이름과 실행 파일은 모두 필수입니다',
			'externalPlayer.testLaunch' => '테스트 실행',
			'externalPlayer.testLaunched' => '플레이어를 실행했습니다',
			'externalPlayer.testFailed' => '실행 실패, 실행 파일 경로를 확인하세요',
			'externalPlayer.executableMissing' => '실행 파일을 찾을 수 없습니다',
			'externalPlayer.openWithNamed' => ({required Object name}) => '${name}(으)로 열기',
			'externalPlayer.managePlayersEntry' => '외부 플레이어 관리…',
			'watchLater.title' => '나중에 보기',
			'watchLater.addToWatchLater' => '나중에 보기',
			'watchLater.removeFromWatchLater' => '나중에 보기에서 제거',
			'watchLater.addedToWatchLater' => '나중에 보기에 추가되었습니다',
			'watchLater.alreadyInWatchLater' => '이미 나중에 보기에 있습니다',
			'watchLater.removedFromWatchLater' => '나중에 보기에서 제거되었습니다',
			'watchLater.removedCount' => ({required Object count}) => '${count}개 항목을 제거했습니다',
			'watchLater.viewWatchLaterList' => '목록 보기',
			'watchLater.addFailed' => '나중에 보기에 추가하지 못했습니다',
			'watchLater.invalidItem' => '사용할 수 없음',
			'watchLater.clearWatched' => '시청한 항목 지우기',
			'watchLater.watchedCleared' => ({required Object count}) => '시청한 ${count}개 항목을 지웠습니다',
			'watchLater.noWatchedToClear' => '지울 시청 항목이 없습니다',
			'watchLater.emptyVideo' => '나중에 보기에 아직 동영상이 없습니다',
			'watchLater.emptyGallery' => '나중에 보기에 아직 갤러리가 없습니다',
			'watchLater.filterAll' => '전체',
			'watchLater.filterUnwatched' => '시청 안 함',
			'watchLater.sortRecentlyAdded' => '최근 추가됨',
			'watchLater.sortEarliestAdded' => '가장 먼저 추가됨',
			'watchLater.watched' => '시청함',
			'watchLater.playlistLoadFailed' => '재생목록을 불러오지 못했습니다',
			'watchLater.noPlaylists' => '아직 재생목록이 없습니다',
			'watchLater.undo' => '실행 취소',
			'watchLater.clearWatchedConfirm' => '이 탭에서 이미 시청한 항목을 모두 지우시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'watchLater.emptyUnwatchedVideo' => '여기에 볼 남은 항목이 없습니다',
			'watchLater.emptyUnwatchedGallery' => '여기에 볼 남은 항목이 없습니다',
			'watchLater.queueLoadFailed' => '불러오지 못했습니다. 탭하여 다시 시도',
			'mediaMenu.like' => '좋아요',
			'mediaMenu.unlike' => '좋아요 취소',
			'mediaMenu.viewAuthor' => '작성자 보기',
			'mediaMenu.inFolders' => ({required Object count}) => '폴더 ${count}개',
			'mediaMenu.inPlaylists' => ({required Object count}) => '재생목록 ${count}개',
			'mediaMenu.downloaded' => '다운로드됨',
			'mediaPreview.preview' => '미리보기',
			'mediaPreview.openDetail' => '열기',
			'mediaPreview.moreActions' => '더 많은 작업',
			'mediaPreview.previousImage' => '이전 이미지',
			'mediaPreview.nextImage' => '다음 이미지',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count}개 이미지',
			'playbackQueue.upNext' => '다음 항목',
			'playbackQueue.sourceTab' => '소스',
			'playbackQueue.emptyQueue' => '이 대기열에 재생할 항목이 없습니다',
			'playbackQueue.emptyGalleryQueue' => '이 대기열에 갤러리가 없습니다',
			'playbackQueue.nowPlaying' => '재생 중',
			'playbackQueue.myPlaylists' => '내 재생목록',
			'playbackQueue.authorPlaylists' => '작성자의 재생목록',
			'playbackQueue.openQueue' => '다음 항목',
			'playbackQueue.continueInQueue' => '현재 대기열에서 계속 재생',
			'playbackQueue.continueInQueueSubtitle' => '다음 항목을 자동으로 재생하며 "재생 완료 후 반복"을 비활성화합니다',
			'playbackQueue.repeatDisabledByQueue' => '현재 대기열에서 계속 재생 기능이 켜져 있는 동안에는 비활성화됩니다',
			'playbackQueue.playNext' => '다음 재생',
			'playbackQueue.queueEnded' => '대기열의 마지막 항목입니다',
			'playbackQueue.playNextHint' => '탭하면 다음 항목을 재생하고, 길게 누르면 다음 항목을 엽니다',
			'playbackQueue.authorVideos' => '작성자의 동영상',
			'playbackQueue.authorGalleries' => '작성자의 갤러리',
			'playbackQueue.favoriteFolders' => '즐겨찾는 폴더',
			'playbackQueue.localFiles' => '이 기기',
			'playbackQueue.currentFolder' => '이 파일의 폴더',
			'playbackQueue.playThisFolder' => '이 폴더의 동영상 대기열 보기',
			'playbackQueue.browseThisFolder' => '이 폴더의 갤러리 대기열 보기',
			'playbackQueue.downloads' => '다운로드됨',
			'playbackQueue.otherPlaylists' => '다른 사용자의 재생목록',
			'playbackQueue.nothingHere' => '여기에 아무것도 없습니다',
			'vrFormat.playInSpace' => '공간 플레이어에서 재생',
			'vrFormat.handingOff' => '공간으로 전환 중…',
			'vrFormat.title' => '재생 모드',
			'vrFormat.spatialSectionTitle' => '공간 재생',
			'vrFormat.spatialSectionDesc' => '헤드셋에서는 동영상이 이 패널 안에 그려지지 않습니다. 공간 플레이어가 방 안의 화면에 표시합니다.',
			'vrFormat.spatialPanelEntry' => '공간 컨트롤 패널',
			'vrFormat.spatialPanelEntryDesc' => '화면 거리, 크기, 곡률, 배경 환경과 속도, 반복, 자동 숨김은 모두 공간 컨트롤 패널에 있습니다.',
			'vrFormat.spatialGuideEntry' => '헤드셋 컨트롤 가이드',
			'vrFormat.spatialGuideEntryDesc' => '컨트롤러 버튼, 화면 잡기, 스틱 탐색, 페이지 넘김',
			'vrFormat.spatialFlatOmitted' => '터치 제스처, 이미지 향상, 오디오/비디오 매개변수는 2D 플레이어에만 적용됩니다. 공간 플레이어는 다른 엔진에서 실행되므로 여기에 나열되지 않습니다.',
			'vrFormat.spatialGallerySectionTitle' => '공간 갤러리',
			'vrFormat.spatialGalleryPanelDesc' => '슬라이드쇼 간격, 단일 클립 반복, 화면 곡률은 모두 공간 컨트롤 패널에서 조정합니다.',
			'vrFormat.autoEnterGallery' => '갤러리 이미지를 공간 갤러리에서 열기',
			'vrFormat.autoEnterGalleryDesc' => 'Quest에서는 이미지를 탭하면 이 패널 안의 뷰어 대신 필름스트립, 슬라이드쇼, 컨트롤러 페이지 넘김을 갖춘 공간 갤러리가 떠 있는 화면에 전체 갤러리를 엽니다.',
			'vrFormat.panelSettings' => '패널 및 배경',
			'vrFormat.panelSettingsDesc' => '이 앱 패널이 얼마나 떨어져 있는지, 뒤에 방이 얼마나 보이는지',
			'vrFormat.panelDistance' => '패널 거리',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => '배치 초기화',
			'vrFormat.panelResetBackground' => '기본값으로 재설정',
			'vrFormat.panelBackground' => '배경 투명도',
			'vrFormat.panelBackgroundHint' => '0%: 검은 주변 · 100%: 실제 방, 주변광 적용',
			'vrFormat.panelUnavailable' => '현재 패널이 제자리에 없습니다. 잠시 후 다시 시도하세요',
			'vrFormat.desc' => '이 동영상을 어떤 방식으로 재생할지 기하 구성을 선택합니다. 사이트에서 이 정보를 제공하지 않으므로 자동 감지는 시작점만 정하며, 선택한 값이 우선합니다.',
			'vrFormat.sectionFlat' => '일반',
			'vrFormat.sectionStereo' => '일반 3D',
			'vrFormat.sectionPanorama' => 'VR 파노라마',
			'vrFormat.flat' => '일반 동영상',
			'vrFormat.flatDesc' => '그대로 재생, 리매핑 없음',
			'vrFormat.flatSideBySide' => '나란히 3D',
			'vrFormat.flatSideBySideDesc' => '절반마다 한쪽 눈, 좌우로 나열; 왼쪽 눈을 표시하고 화면 비율을 복원합니다',
			'vrFormat.flatTopBottom' => '상하 3D',
			'vrFormat.flatTopBottomDesc' => '절반마다 한쪽 눈, 위아래로 배치; 위쪽 절반을 표시하고 화면 비율을 복원합니다',
			'vrFormat.vr180SideBySide' => 'VR180 나란히',
			'vrFormat.vr180SideBySideDesc' => '양안 반구형 파노라마 — 가장 흔한 VR 소스',
			'vrFormat.vr180Mono' => 'VR180 모노',
			'vrFormat.vr180MonoDesc' => '반구형 파노라마, 프레임당 단일 시점',
			'vrFormat.vr360Mono' => 'VR360 모노',
			'vrFormat.vr360MonoDesc' => '완전 몰입형 파노라마, 프레임당 단일 시점',
			'vrFormat.vr360TopBottom' => 'VR360 상하',
			'vrFormat.vr360TopBottomDesc' => '양안이 위아래로 쌓인 완전 몰입형 파노라마',
			'vrFormat.resetView' => '시야 초기화',
			'vrFormat.resetViewDesc' => '시선 방향과 시야각을 정면으로 되돌립니다',
			'vrFormat.resetToAuto' => '자동 감지로 되돌리기',
			'vrFormat.resetToAutoDesc' => '이 동영상의 수동 선택을 지우고 다시 감지하도록 합니다',
			_ => null,
		} ?? switch (path) {
			'vrFormat.manualBadge' => '수동 설정됨',
			'vrFormat.panoramaHint' => '화면을 끌어 주변을 둘러보고, 핀치하여 시야각을 변경하세요',
			'vrFormat.panoramaGestureNotice' => '둘러보는 동안 끌면 시야가 돌아갑니다. 탐색은 진행 표시줄을 사용하세요',
			'vrFormat.shaderUnsupported' => '이 기기는 실시간 파노라마를 렌더링할 수 없어 단일 시점으로 표시합니다',
			'vrFormat.handoffTooltip' => '다른 방식으로 재생',
			'vrFormat.suggestedBadge' => '추천',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => '${format}인 것 같습니다 — 탭하여 전환',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'VR 동영상일 수 있습니다 (${format})',
			'vrFormat.suggestionTitleShort' => 'VR 동영상일 수 있습니다',
			'vrFormat.suggestionAction' => 'VR로 재생',
			'vrFormat.suggestionDismiss' => '닫기',
			'localMedia.browse.pinnedSection' => '빠른 접근',
			'localMedia.browse.sourcesSection' => '폴더',
			'localMedia.browse.pin' => '빠른 접근에 추가',
			'localMedia.browse.unpin' => '빠른 접근에서 제거',
			'localMedia.browse.pinned' => '빠른 접근에 추가됨',
			'localMedia.browse.unpinned' => '빠른 접근에서 제거됨',
			'localMedia.browse.folderCount' => ({required Object count}) => '폴더 ${count}개',
			'localMedia.browse.videoCount' => ({required Object count}) => '동영상 ${count}개',
			'localMedia.browse.imageCount' => ({required Object count}) => '이미지 ${count}개',
			'localMedia.browse.emptyFolder' => '이 폴더는 비어 있습니다',
			'localMedia.browse.videosSection' => '동영상',
			'localMedia.browse.imagesSection' => '이미지',
			'localMedia.browse.galleriesSection' => '갤러리',
			'localMedia.browse.filterAll' => '전체',
			'localMedia.browse.searchInFolder' => '이 폴더에서 검색',
			'localMedia.browse.searchHint' => '이름으로 검색',
			'localMedia.browse.clearSearch' => '검색 지우기',
			'localMedia.browse.searchNoResult' => ({required Object query}) => '"${query}"와 일치하는 항목이 없습니다',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => '폴더 ${count}개 모두 보기',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => '동영상 ${count}개 모두 보기',
			'localMedia.browse.viewAllImages' => ({required Object count}) => '이미지 ${count}장 모두 보기',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => '갤러리 ${count}개 모두 보기',
			'localMedia.browse.location' => '위치',
			'localMedia.browse.sourceMissing' => '이 소스가 사라졌습니다',
			'localMedia.browse.notScannedYet' => '이 폴더는 아직 검사되지 않았습니다',
			'localMedia.browse.scanning' => '이 폴더를 읽는 중…',
			'localMedia.browse.deleteFileTitle' => '이 파일을 삭제하시겠습니까?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '"${name}"이(가) 이 기기에서 영구적으로 삭제됩니다. 되돌릴 수 없습니다.',
			'localMedia.browse.hideFolder' => '이 폴더 숨기기',
			'localMedia.browse.unhideFolder' => '숨김 해제',
			'localMedia.browse.showHiddenFolders' => '숨긴 폴더 표시',
			'localMedia.browse.includeDotFolders' => '. 으로 시작하는 폴더도 스캔',
			'localMedia.browse.dotFoldersIncluded' => '. 으로 시작하는 폴더 스캔을 시작했습니다',
			'localMedia.browse.dotFoldersExcluded' => '. 으로 시작하는 폴더를 더 이상 스캔하지 않습니다',
			'localMedia.browse.showDotFolders' => '. 으로 시작하는 폴더 표시',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => '여기에 스캔되지 않은 . 으로 시작하는 폴더가 ${count}개 있습니다',
			'localMedia.browse.scanDotFoldersAction' => '이 소스에서 켜기',
			'localMedia.browse.otherAppsPrivateNotice' => 'Android 11부터는 어떤 앱도 다른 앱의 Android/data, Android/obb 파일을 읽을 수 없으며 이 앱도 우회할 수 없습니다. 원래 앱에서 동영상을 Download 같은 공용 폴더로 다운로드하거나 내보낸 뒤 그 폴더를 추가하세요. 재생 중 캐시는 보통 조각으로 나뉘어 있어 읽더라도 재생할 수 없습니다.',
			'localMedia.browse.folderHidden' => '숨겼습니다. 검색에서도 건너뜁니다',
			'localMedia.browse.folderUnhidden' => '숨김을 해제했습니다',
			'localMedia.browse.hiddenFolderBadge' => '숨김',
			'localMedia.browse.deleteFolder' => '폴더 삭제',
			'localMedia.browse.deleteFolderTitle' => '이 폴더를 삭제할까요?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '"${name}"와 그 안의 모든 항목이 이 기기에서 완전히 삭제됩니다. 되돌릴 수 없습니다.',
			'localMedia.browse.deleteFolderIncludesOthers' => '안에 있는 다른 파일도 함께 삭제됩니다',
			'localMedia.browse.folderDeleted' => '폴더를 삭제했습니다',
			'localMedia.browse.deleteFolderFailed' => '삭제하지 못했습니다. 권한이 없거나 안의 파일이 사용 중일 수 있습니다',
			'localMedia.browse.deleteGalleryTitle' => '이 갤러리를 삭제하시겠습니까?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => '"${name}"의 다운로드 기록과 로컬 이미지 파일이 삭제됩니다. 되돌릴 수 없습니다.',
			'localMedia.browse.galleryResourceMissing' => '로컬 파일이 더 이상 존재하지 않습니다. 기록이 정리되었습니다.',
			'localMedia.browse.viewDownloadDetail' => '다운로드 세부 정보 보기',
			'localMedia.browse.viewOnlineGallery' => '웹사이트에서 보기',
			'localMedia.browse.pickFolderTitle' => '폴더 선택',
			'localMedia.browse.useThisFolder' => '이 폴더 사용',
			'localMedia.browse.noSubfolders' => '여기에는 하위 폴더가 없습니다',
			'localMedia.browse.storageRoot' => '기기 저장소',
			'localMedia.browse.homeFolder' => '홈',
			'localMedia.browse.filesystemRoot' => '파일 시스템 루트',
			'localMedia.browse.folderUnreadable' => '이 폴더를 읽을 수 없습니다',
			'localMedia.browse.setCover' => '커버 설정',
			'localMedia.browse.setAsFolderCover' => '폴더 커버로 사용',
			'localMedia.browse.folderCoverSet' => '폴더 커버가 업데이트되었습니다',
			'localMedia.browse.setFolderCoverPick' => '커버 설정…',
			'localMedia.browse.restoreAutoCover' => '자동 커버 복원',
			'localMedia.browse.autoCoverRestored' => '자동 커버가 복원되었습니다',
			'localMedia.browse.rescanFolder' => '이 폴더 다시 검사',
			'localMedia.browse.coverPickerTitle' => '프레임 선택',
			'localMedia.browse.folderCoverPickerTitle' => '커버 선택',
			'localMedia.browse.coverPickerEmpty' => '이 폴더에 아직 사용할 수 있는 이미지가 없습니다. 동영상 썸네일이 백그라운드에서 생성 중일 수 있습니다.',
			'localMedia.browse.coverSaved' => '커버가 업데이트되었습니다',
			'localMedia.browse.coverSaveFailed' => '커버를 저장할 수 없습니다',
			'localMedia.browse.coverUnavailable' => '이 파일에서 동영상 프레임을 읽을 수 없습니다',
			'localMedia.browse.deleted' => '삭제됨',
			'localMedia.browse.deleteFailed' => '삭제할 수 없습니다 — 파일이 사용 중이거나 쓰기 불가일 수 있습니다',
			'localMedia.browse.openFolder' => '열기',
			'localMedia.browse.favorite' => '즐겨찾기에 추가',
			'localMedia.browse.unfavorite' => '즐겨찾기에서 제거',
			'localMedia.browse.favorited' => '즐겨찾기에 추가됨',
			'localMedia.browse.unfavorited' => '즐겨찾기에서 제거됨',
			'localMedia.browse.sortBy' => '정렬 기준',
			'localMedia.browse.sortAscending' => '오름차순',
			'localMedia.browse.sortDescending' => '내림차순',
			'localMedia.browse.sortFieldName' => '이름',
			'localMedia.browse.sortFieldModified' => '수정한 날짜',
			'localMedia.browse.sortFieldDuration' => '재생 시간',
			'localMedia.browse.sortFieldSize' => '크기',
			'localMedia.browse.sortFieldResolution' => '해상도',
			'localMedia.browse.sortFieldFileType' => '파일 형식',
			'localMedia.browse.sortFieldFps' => '프레임 레이트',
			'localMedia.browse.sortFieldFavorited' => '즐겨찾기한 날짜',
			'localMedia.browse.emptyAllVideos' => '아직 동영상이 없습니다. 폴더에서 폴더를 추가하여 시작하세요.',
			'localMedia.browse.emptyAllImages' => '아직 이미지가 없습니다. 폴더에서 폴더를 추가하여 시작하세요.',
			'localMedia.browse.emptyFavorites' => '아직 즐겨찾기가 없습니다. 동영상의 ⋮ 메뉴에서 추가하세요.',
			'localMedia.browse.emptyPinned' => '아직 빠른 접근 폴더가 없습니다. 폴더에서 폴더를 길게 눌러 고정을 선택하세요.',
			'localMedia.browse.emptyDownloadedVideos' => '아직 완료된 동영상 다운로드가 없습니다.',
			'localMedia.browse.emptyDownloadedGalleries' => '아직 완료된 갤러리 다운로드가 없습니다.',
			'localMedia.browse.folderInfo' => '폴더 정보',
			'localMedia.browse.folderInfoName' => '이름',
			'localMedia.browse.folderInfoPath' => '경로',
			'localMedia.browse.folderInfoSource' => '소스',
			'localMedia.browse.folderInfoContents' => '내용',
			'localMedia.browse.folderInfoSize' => '디스크 사용량',
			'localMedia.browse.folderInfoScannedAt' => '마지막 검사',
			'localMedia.browse.folderInfoNeverScanned' => '아직 검사하지 않음',
			'localMedia.browse.folderInfoNoPath' => '이 소스에는 열 폴더가 없습니다',
			'localMedia.browse.copyPath' => '경로 복사',
			'localMedia.browse.pathCopied' => '경로가 복사되었습니다',
			'localMedia.tabFolders' => '폴더',
			'localMedia.tabFavoriteVideos' => '즐겨찾기',
			'localMedia.tabAllVideos' => '모든 동영상',
			'localMedia.tabAllImages' => '모든 이미지',
			'localMedia.tabDownloadedVideos' => '다운로드한 동영상',
			'localMedia.tabDownloadedGalleries' => '다운로드한 갤러리',
			'localMedia.title' => '이 기기에서',
			'localMedia.sourceOnline' => 'Iwara 온라인',
			'localMedia.manageSources' => '소스 관리',
			'localMedia.moveToCategory' => '카테고리로 이동',
			'localMedia.manageCategories' => '카테고리 관리',
			'localMedia.suggestedFolders' => '동영상이 있는 폴더',
			'localMedia.sortRecentlyAdded' => '최근 추가순',
			'localMedia.sortRecentlyPlayed' => '최근 재생순',
			'localMedia.sortName' => '이름',
			'localMedia.sortDuration' => '재생 시간',
			'localMedia.sortSize' => '크기',
			'localMedia.sortFolder' => '폴더',
			'localMedia.sortRecentlyModified' => '최근 수정순',
			'localMedia.sortCount' => '개수',
			'localMedia.folderCardItemCount' => ({required Object count}) => '이미지 ${count}개',
			'localMedia.downloadsSource' => '다운로드됨',
			'localMedia.builtInSourceHint' => '다운로드는 자동으로 관리됩니다',
			'localMedia.filterByCategory' => '카테고리로 필터',
			'localMedia.longPressToCategorize' => '길게 눌러 카테고리로 이동',
			'localMedia.uncategorized' => '미분류',
			'localMedia.setCategoryFailed' => '카테고리를 설정할 수 없습니다',
			'localMedia.categoryUpdated' => '카테고리가 업데이트되었습니다',
			'localMedia.addFolder' => '폴더 추가',
			'localMedia.addDeviceVideos' => '기기 동영상 검사',
			'localMedia.mediaStoreSourceName' => '기기 동영상',
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
			'localMedia.mediaStoreUnavailable' => '기기 미디어 색인은 Android에서만 사용할 수 있습니다',
			'localMedia.mediaStorePermissionDenied' => '동영상 접근 권한이 부여되지 않았습니다',
			'localMedia.rescan' => '다시 검사',
			'localMedia.scanning' => ({required Object count}) => '검사 중… ${count}개 발견',
			'localMedia.scanFailed' => ({required Object reason}) => '검사 실패: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => '해당 폴더가 너무 커서 처음 ${count}개 파일만 추가되었습니다.',
			'localMedia.sourceOverlaps' => ({required Object name}) => '이미 "${name}" 폴더에 포함되어 있습니다',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '"${name}"은(는) "${source}" 안에 있어 빠른 접근 폴더에 추가되었습니다',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '"${name}"은(는) 이미 빠른 접근 폴더에 있습니다',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '"${name}"은(는) 이미 추가되었습니다',
			'localMedia.sourceContainsExisting' => ({required Object name}) => '이미 추가된 폴더 "${name}"을(를) 포함하고 있어 상위 폴더 추가는 아직 지원되지 않습니다',
			'localMedia.addSourceFailed' => '해당 폴더를 추가할 수 없습니다',
			'localMedia.fileMissing' => '해당 파일이 더 이상 디스크에 없습니다',
			'localMedia.permissionDenied' => '파일 접근 권한 없음 · 탭하여 허용',
			'localMedia.noVideosFound' => '이 폴더에 동영상이 없습니다',
			'localMedia.emptyTitle' => '폴더를 추가하여 이 기기에 이미 있는 동영상을 시청하세요',
			'localMedia.emptyPrivacyNote' => '파일은 이 기기에서만 읽습니다. 아무것도 업로드되지 않습니다.',
			'localMedia.removeSourceTitle' => ({required Object name}) => '"${name}"을(를) 제거하시겠습니까?',
			'localMedia.removeSourceBody' => '파일은 디스크에 그대로 남습니다. 이 라이브러리 항목만 제거됩니다.',
			'localMedia.remove' => '제거',
			'localMedia.removeFolder' => '폴더 제거',
			'localMedia.removeFolderSelectTitle' => '제거할 폴더 선택',
			'localMedia.longPressToRemove' => '길게 눌러 이 폴더 제거',
			'localMedia.clearProgress' => '로컬 시청 기록 지우기',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count}개 항목',
			'localMedia.clearProgressEmpty' => '아직 로컬 시청 기록이 없습니다',
			'localMedia.clearProgressTitle' => '로컬 시청 기록을 지우시겠습니까?',
			'localMedia.clearProgressBody' => '재생 위치와 시청 표시만 삭제됩니다. 파일과 폴더는 그대로 유지됩니다.',
			'localMedia.clearProgressDone' => ({required Object count}) => '로컬 시청 기록 ${count}개를 지웠습니다',
			'localMedia.clearAction' => '지우기',
			'localMedia.iosManualRescanNotice' => 'iOS는 새 파일을 자동으로 감지하지 않습니다. 파일을 추가하거나 삭제한 후 수동으로 다시 검사해야 합니다.',
			'historyPage.removeFromHistory' => '기록에서 삭제',
			'historyPage.removed' => '기록에서 삭제했습니다',
			'historyPage.watchedTo' => ({required Object time}) => '${time}까지 시청',
			'historyPage.finished' => '시청 완료',
			'historyPage.clearTabTitle' => ({required Object tab}) => '"${tab}" 지우기',
			'historyPage.clearTabConfirm' => ({required Object tab}) => '"${tab}"의 모든 기록과 해당 동영상의 시청 위치가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.',
			'historyPage.rangeByLastViewed' => '마지막으로 본 시간 기준',
			_ => null,
		};
	}
}
