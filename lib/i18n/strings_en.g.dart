///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn._(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn._(_root);
	late final TranslationsErrorsEn errors = TranslationsErrorsEn._(_root);
	late final TranslationsFriendsEn friends = TranslationsFriendsEn._(_root);
	late final TranslationsAuthorProfileEn authorProfile = TranslationsAuthorProfileEn._(_root);
	late final TranslationsFavoritesEn favorites = TranslationsFavoritesEn._(_root);
	late final TranslationsGalleryDetailEn galleryDetail = TranslationsGalleryDetailEn._(_root);
	late final TranslationsPlayListEn playList = TranslationsPlayListEn._(_root);
	late final TranslationsSearchEn search = TranslationsSearchEn._(_root);
	late final TranslationsMediaListEn mediaList = TranslationsMediaListEn._(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn._(_root);
	late final TranslationsOreno3dEn oreno3d = TranslationsOreno3dEn._(_root);
	late final TranslationsSignInEn signIn = TranslationsSignInEn._(_root);
	late final TranslationsSubscriptionsEn subscriptions = TranslationsSubscriptionsEn._(_root);
	late final TranslationsVideoDetailEn videoDetail = TranslationsVideoDetailEn._(_root);
	late final TranslationsShareEn share = TranslationsShareEn._(_root);
	late final TranslationsMarkdownEn markdown = TranslationsMarkdownEn._(_root);
	late final TranslationsForumEn forum = TranslationsForumEn._(_root);
	late final TranslationsNotificationsEn notifications = TranslationsNotificationsEn._(_root);
	late final TranslationsConversationEn conversation = TranslationsConversationEn._(_root);
	late final TranslationsSplashEn splash = TranslationsSplashEn._(_root);
	late final TranslationsDownloadEn download = TranslationsDownloadEn._(_root);
	late final TranslationsFavoriteEn favorite = TranslationsFavoriteEn._(_root);
	late final TranslationsTranslationEn translation = TranslationsTranslationEn._(_root);
	late final TranslationsMediaPlayerEn mediaPlayer = TranslationsMediaPlayerEn._(_root);
	late final TranslationsLinkInputDialogEn linkInputDialog = TranslationsLinkInputDialogEn._(_root);
	late final TranslationsLogEn log = TranslationsLogEn._(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Love Iwara'
	String get appName => 'Love Iwara';

	/// en: 'OK'
	String get ok => 'OK';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Visit'
	String get visit => 'Visit';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Scroll to Top'
	String get scrollToTop => 'Scroll to Top';

	/// en: 'Privacy content, not displayed'
	String get privacyHint => 'Privacy content, not displayed';

	/// en: 'Latest'
	String get latest => 'Latest';

	/// en: 'Likes'
	String get likesCount => 'Likes';

	/// en: 'Views'
	String get viewsCount => 'Views';

	/// en: 'Popular'
	String get popular => 'Popular';

	/// en: 'Trending'
	String get trending => 'Trending';

	/// en: 'Comment List'
	String get commentList => 'Comment List';

	/// en: 'Send Comment'
	String get sendComment => 'Send Comment';

	/// en: 'Send'
	String get send => 'Send';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'Premium'
	String get premium => 'Premium';

	/// en: 'Follower'
	String get follower => 'Follower';

	/// en: 'Friend'
	String get friend => 'Friend';

	/// en: 'Video'
	String get video => 'Video';

	/// en: 'Following'
	String get following => 'Following';

	/// en: 'Expand'
	String get expand => 'Expand';

	/// en: 'Collapse'
	String get collapse => 'Collapse';

	/// en: 'Cancel Request'
	String get cancelFriendRequest => 'Cancel Request';

	/// en: 'Cancel Special Follow'
	String get cancelSpecialFollow => 'Cancel Special Follow';

	/// en: 'Add Friend'
	String get addFriend => 'Add Friend';

	/// en: 'Remove Friend'
	String get removeFriend => 'Remove Friend';

	/// en: 'Followed'
	String get followed => 'Followed';

	/// en: 'Follow'
	String get follow => 'Follow';

	/// en: 'Unfollow'
	String get unfollow => 'Unfollow';

	/// en: 'Special Follow'
	String get specialFollow => 'Special Follow';

	/// en: 'Special Followed'
	String get specialFollowed => 'Special Followed';

	/// en: 'Gallery'
	String get gallery => 'Gallery';

	/// en: 'Playlist'
	String get playlist => 'Playlist';

	/// en: 'Comment Posted Successfully'
	String get commentPostedSuccessfully => 'Comment Posted Successfully';

	/// en: 'Comment Posted Failed'
	String get commentPostedFailed => 'Comment Posted Failed';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Comment Deleted Successfully'
	String get commentDeletedSuccessfully => 'Comment Deleted Successfully';

	/// en: 'Comment Updated Successfully'
	String get commentUpdatedSuccessfully => 'Comment Updated Successfully';

	/// en: '${count} Comments'
	String totalComments({required Object count}) => '${count} Comments';

	/// en: 'Write your comment here...'
	String get writeYourCommentHere => 'Write your comment here...';

	/// en: 'No replies yet'
	String get tmpNoReplies => 'No replies yet';

	/// en: 'Load More'
	String get loadMore => 'Load More';

	/// en: 'No more data'
	String get noMoreDatas => 'No more data';

	/// en: 'Select Translation Language'
	String get selectTranslationLanguage => 'Select Translation Language';

	/// en: 'Translate'
	String get translate => 'Translate';

	/// en: 'Translate failed, please try again later'
	String get translateFailedPleaseTryAgainLater => 'Translate failed, please try again later';

	/// en: 'Translation Result'
	String get translationResult => 'Translation Result';

	/// en: 'Just Now'
	String get justNow => 'Just Now';

	/// en: '${num} minutes ago'
	String minutesAgo({required Object num}) => '${num} minutes ago';

	/// en: '${num} hours ago'
	String hoursAgo({required Object num}) => '${num} hours ago';

	/// en: '${num} days ago'
	String daysAgo({required Object num}) => '${num} days ago';

	/// en: '${num} edited'
	String editedAt({required Object num}) => '${num} edited';

	/// en: 'Edit Comment'
	String get editComment => 'Edit Comment';

	/// en: 'Comment Updated'
	String get commentUpdated => 'Comment Updated';

	/// en: 'Reply Comment'
	String get replyComment => 'Reply Comment';

	/// en: 'Reply'
	String get reply => 'Reply';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Unknown User'
	String get unknownUser => 'Unknown User';

	/// en: 'Me'
	String get me => 'Me';

	/// en: 'Author'
	String get author => 'Author';

	/// en: 'Admin'
	String get admin => 'Admin';

	/// en: 'View Replies (${num})'
	String viewReplies({required Object num}) => 'View Replies (${num})';

	/// en: 'Hide Replies'
	String get hideReplies => 'Hide Replies';

	/// en: 'Confirm Delete'
	String get confirmDelete => 'Confirm Delete';

	/// en: 'Are you sure you want to delete this item?'
	String get areYouSureYouWantToDeleteThisItem => 'Are you sure you want to delete this item?';

	/// en: 'No comments yet'
	String get tmpNoComments => 'No comments yet';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Tips'
	String get tips => 'Tips';

	/// en: 'Link is empty'
	String get linkIsEmpty => 'Link is empty';

	/// en: 'Link copied to clipboard'
	String get linkCopiedToClipboard => 'Link copied to clipboard';

	/// en: 'Image copied to clipboard'
	String get imageCopiedToClipboard => 'Image copied to clipboard';

	/// en: 'Copy image failed'
	String get copyImageFailed => 'Copy image failed';

	/// en: 'Mobile save image is under development'
	String get mobileSaveImageIsUnderDevelopment => 'Mobile save image is under development';

	/// en: 'Image saved to'
	String get imageSavedTo => 'Image saved to';

	/// en: 'Save image failed'
	String get saveImageFailed => 'Save image failed';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'More'
	String get more => 'More';

	/// en: 'More features to be developed'
	String get moreFeaturesToBeDeveloped => 'More features to be developed';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Selected ${num} records'
	String selectedRecords({required Object num}) => 'Selected ${num} records';

	/// en: 'Cancel Select All'
	String get cancelSelectAll => 'Cancel Select All';

	/// en: 'Select All'
	String get selectAll => 'Select All';

	/// en: 'Exit Edit Mode'
	String get exitEditMode => 'Exit Edit Mode';

	/// en: 'Are you sure you want to delete selected ${num} items?'
	String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Are you sure you want to delete selected ${num} items?';

	/// en: 'Search History Records...'
	String get searchHistoryRecords => 'Search History Records...';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Subscriptions'
	String get subscriptions => 'Subscriptions';

	/// en: '${num} videos'
	String videoCount({required Object num}) => '${num} videos';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Are you sure you want to share this playlist?'
	String get areYouSureYouWantToShareThisPlaylist => 'Are you sure you want to share this playlist?';

	/// en: 'Edit Title'
	String get editTitle => 'Edit Title';

	/// en: 'Edit Mode'
	String get editMode => 'Edit Mode';

	/// en: 'Please enter new title'
	String get pleaseEnterNewTitle => 'Please enter new title';

	/// en: 'Create Play List'
	String get createPlayList => 'Create Play List';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Check Network Settings'
	String get checkNetworkSettings => 'Check Network Settings';

	/// en: 'General'
	String get general => 'General';

	/// en: 'R18'
	String get r18 => 'R18';

	/// en: 'Sensitive'
	String get sensitive => 'Sensitive';

	/// en: 'Year'
	String get year => 'Year';

	/// en: 'Month'
	String get month => 'Month';

	/// en: 'Tag'
	String get tag => 'Tag';

	/// en: 'Private'
	String get private => 'Private';

	/// en: 'No Title'
	String get noTitle => 'No Title';

	/// en: 'Search'
	String get search => 'Search';

	/// en: 'No content'
	String get noContent => 'No content';

	/// en: 'Recording'
	String get recording => 'Recording';

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'User'
	String get user => 'User';

	/// en: 'Post'
	String get post => 'Post';

	/// en: 'Seconds'
	String get seconds => 'Seconds';

	/// en: 'Coming Soon'
	String get comingSoon => 'Coming Soon';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Hour'
	String get hour => 'Hour';

	/// en: 'Minute'
	String get minute => 'Minute';

	/// en: 'Click to Refresh'
	String get clickToRefresh => 'Click to Refresh';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Friends'
	String get friends => 'Friends';

	/// en: 'Play List'
	String get playList => 'Play List';

	/// en: 'Check License'
	String get checkLicense => 'Check License';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Fans'
	String get fensi => 'Fans';

	/// en: 'Accept'
	String get accept => 'Accept';

	/// en: 'Reject'
	String get reject => 'Reject';

	/// en: 'Clear All History'
	String get clearAllHistory => 'Clear All History';

	/// en: 'Are you sure you want to clear all history?'
	String get clearAllHistoryConfirm => 'Are you sure you want to clear all history?';

	/// en: 'Following List'
	String get followingList => 'Following List';

	/// en: 'Followers List'
	String get followersList => 'Followers List';

	/// en: 'Follows'
	String get follows => 'Follows';

	/// en: 'Fans'
	String get fans => 'Fans';

	/// en: 'Follows and Fans'
	String get followsAndFans => 'Follows and Fans';

	/// en: 'Views'
	String get numViews => 'Views';

	/// en: 'Updated At'
	String get updatedAt => 'Updated At';

	/// en: 'Published At'
	String get publishedAt => 'Published At';

	/// en: 'External Video'
	String get externalVideo => 'External Video';

	/// en: 'Original Text'
	String get originalText => 'Original Text';

	/// en: 'Show Original Text'
	String get showOriginalText => 'Show Original Text';

	/// en: 'Show Processed Text'
	String get showProcessedText => 'Show Processed Text';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Rules'
	String get rules => 'Rules';

	/// en: 'Agree'
	String get agree => 'Agree';

	/// en: 'Disagree'
	String get disagree => 'Disagree';

	/// en: 'Agree to Rules'
	String get agreeToRules => 'Agree to Rules';

	/// en: 'Create Post'
	String get createPost => 'Create Post';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Please enter title'
	String get enterTitle => 'Please enter title';

	/// en: 'Content'
	String get content => 'Content';

	/// en: 'Please enter content'
	String get enterContent => 'Please enter content';

	/// en: 'Please enter content...'
	String get writeYourContentHere => 'Please enter content...';

	/// en: 'Tag Blacklist'
	String get tagBlacklist => 'Tag Blacklist';

	/// en: 'No data'
	String get noData => 'No data';

	/// en: 'Tag Limit'
	String get tagLimit => 'Tag Limit';

	/// en: 'Enable Floating Buttons'
	String get enableFloatingButtons => 'Enable Floating Buttons';

	/// en: 'Disable Floating Buttons'
	String get disableFloatingButtons => 'Disable Floating Buttons';

	/// en: 'Enabled Floating Buttons'
	String get enabledFloatingButtons => 'Enabled Floating Buttons';

	/// en: 'Disabled Floating Buttons'
	String get disabledFloatingButtons => 'Disabled Floating Buttons';

	/// en: 'Pending Comment Count'
	String get pendingCommentCount => 'Pending Comment Count';

	/// en: 'Joined at ${str}'
	String joined({required Object str}) => 'Joined at ${str}';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Select Quality'
	String get selectQuality => 'Select Quality';

	/// en: 'Select Date Range'
	String get selectDateRange => 'Select Date Range';

	/// en: 'Select date range, default is recent 30 days'
	String get selectDateRangeHint => 'Select date range, default is recent 30 days';

	/// en: 'Clear Date Range'
	String get clearDateRange => 'Clear Date Range';

	/// en: 'Followed successfully, click again to special follow'
	String get followSuccessClickAgainToSpecialFollow => 'Followed successfully, click again to special follow';

	/// en: 'Are you sure you want to exit?'
	String get exitConfirmTip => 'Are you sure you want to exit?';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'A task is already running, please wait.'
	String get taskRunning => 'A task is already running, please wait.';

	/// en: 'Operation cancelled.'
	String get operationCancelled => 'Operation cancelled.';

	/// en: 'You have unsaved changes'
	String get unsavedChanges => 'You have unsaved changes';

	/// en: 'Drag to reorder • Swipe left to remove'
	String get specialFollowsManagementTip => 'Drag to reorder • Swipe left to remove';

	/// en: 'Special Follows Management'
	String get specialFollowsManagement => 'Special Follows Management';

	late final TranslationsCommonPaginationEn pagination = TranslationsCommonPaginationEn._(_root);

	/// en: 'Notice'
	String get notice => 'Notice';

	/// en: 'Detail'
	String get detail => 'Detail';

	/// en: ' - Desktop users can configure proxy in settings'
	String get parseExceptionDestopHint => ' - Desktop users can configure proxy in settings';

	/// en: 'Iwara Tags'
	String get iwaraTags => 'Iwara Tags';

	/// en: 'Like This Video'
	String get likeThisVideo => 'Like This Video';

	/// en: 'Operation'
	String get operation => 'Operation';

	/// en: 'Replies'
	String get replies => 'Replies';
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Login'
	String get login => 'Login';

	/// en: 'Logout'
	String get logout => 'Logout';

	/// en: 'Email'
	String get email => 'Email';

	/// en: 'Password'
	String get password => 'Password';

	/// en: 'Login / Register'
	String get loginOrRegister => 'Login / Register';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Please enter email'
	String get pleaseEnterEmail => 'Please enter email';

	/// en: 'Please enter password'
	String get pleaseEnterPassword => 'Please enter password';

	/// en: 'Password must be at least 6 characters'
	String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';

	/// en: 'Please enter captcha'
	String get pleaseEnterCaptcha => 'Please enter captcha';

	/// en: 'Captcha'
	String get captcha => 'Captcha';

	/// en: 'Refresh Captcha'
	String get refreshCaptcha => 'Refresh Captcha';

	/// en: 'Captcha not loaded'
	String get captchaNotLoaded => 'Captcha not loaded';

	/// en: 'Login Success'
	String get loginSuccess => 'Login Success';

	/// en: 'Email verification sent'
	String get emailVerificationSent => 'Email verification sent';

	/// en: 'Not Logged In'
	String get notLoggedIn => 'Not Logged In';

	/// en: 'Click to Login'
	String get clickToLogin => 'Click to Login';

	/// en: 'Are you sure you want to logout?'
	String get logoutConfirmation => 'Are you sure you want to logout?';

	/// en: 'Logout Success'
	String get logoutSuccess => 'Logout Success';

	/// en: 'Logout Failed'
	String get logoutFailed => 'Logout Failed';

	/// en: 'Username or Email'
	String get usernameOrEmail => 'Username or Email';

	/// en: 'Please enter username or email'
	String get pleaseEnterUsernameOrEmail => 'Please enter username or email';

	/// en: 'Remember Username and Password'
	String get rememberMe => 'Remember Username and Password';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'This field is required'
	String get required => 'This field is required';

	/// en: 'Invalid email address'
	String get invalidEmail => 'Invalid email address';

	/// en: 'Network error, please try again'
	String get networkError => 'Network error, please try again';

	/// en: 'Error while fetching'
	String get errorWhileFetching => 'Error while fetching';

	/// en: 'Comment content cannot be empty'
	String get commentCanNotBeEmpty => 'Comment content cannot be empty';

	/// en: 'Error while fetching replies, please check network connection'
	String get errorWhileFetchingReplies => 'Error while fetching replies, please check network connection';

	/// en: 'Can not find comment controller'
	String get canNotFindCommentController => 'Can not find comment controller';

	/// en: 'Error while loading gallery'
	String get errorWhileLoadingGallery => 'Error while loading gallery';

	/// en: 'How could there be no data? It can't be possible :<'
	String get howCouldThereBeNoDataItCantBePossible => 'How could there be no data? It can\'t be possible :<';

	/// en: 'Unsupported image format: ${str}'
	String unsupportedImageFormat({required Object str}) => 'Unsupported image format: ${str}';

	/// en: 'Invalid gallery ID'
	String get invalidGalleryId => 'Invalid gallery ID';

	/// en: 'Translation failed, please try again later'
	String get translationFailedPleaseTryAgainLater => 'Translation failed, please try again later';

	/// en: 'An error occurred, please try again later.'
	String get errorOccurred => 'An error occurred, please try again later.';

	/// en: 'Error occurred while processing request'
	String get errorOccurredWhileProcessingRequest => 'Error occurred while processing request';

	/// en: 'Error while fetching datas, please try again later'
	String get errorWhileFetchingDatas => 'Error while fetching datas, please try again later';

	/// en: 'Service not initialized'
	String get serviceNotInitialized => 'Service not initialized';

	/// en: 'Unknown type'
	String get unknownType => 'Unknown type';

	/// en: 'Error while opening link: ${link}'
	String errorWhileOpeningLink({required Object link}) => 'Error while opening link: ${link}';

	/// en: 'Invalid URL'
	String get invalidUrl => 'Invalid URL';

	/// en: 'Failed to operate'
	String get failedToOperate => 'Failed to operate';

	/// en: 'Permission Denied'
	String get permissionDenied => 'Permission Denied';

	/// en: 'You do not have permission to access this resource'
	String get youDoNotHavePermissionToAccessThisResource => 'You do not have permission to access this resource';

	/// en: 'Login Failed'
	String get loginFailed => 'Login Failed';

	/// en: 'Unknown Error'
	String get unknownError => 'Unknown Error';

	/// en: 'Session Expired'
	String get sessionExpired => 'Session Expired';

	/// en: 'Failed to fetch captcha'
	String get failedToFetchCaptcha => 'Failed to fetch captcha';

	/// en: 'Email already exists'
	String get emailAlreadyExists => 'Email already exists';

	/// en: 'Invalid Captcha'
	String get invalidCaptcha => 'Invalid Captcha';

	/// en: 'Register Failed'
	String get registerFailed => 'Register Failed';

	/// en: 'Failed to fetch comments'
	String get failedToFetchComments => 'Failed to fetch comments';

	/// en: 'Failed to fetch image detail'
	String get failedToFetchImageDetail => 'Failed to fetch image detail';

	/// en: 'Failed to fetch image list'
	String get failedToFetchImageList => 'Failed to fetch image list';

	/// en: 'Failed to fetch data'
	String get failedToFetchData => 'Failed to fetch data';

	/// en: 'Invalid parameter'
	String get invalidParameter => 'Invalid parameter';

	/// en: 'Please login first'
	String get pleaseLoginFirst => 'Please login first';

	/// en: 'Error while loading post'
	String get errorWhileLoadingPost => 'Error while loading post';

	/// en: 'Error while loading post detail'
	String get errorWhileLoadingPostDetail => 'Error while loading post detail';

	/// en: 'Invalid post ID'
	String get invalidPostId => 'Invalid post ID';

	/// en: 'Currently in force update state, cannot go back'
	String get forceUpdateNotPermittedToGoBack => 'Currently in force update state, cannot go back';

	/// en: 'Please login again'
	String get pleaseLoginAgain => 'Please login again';

	/// en: 'Invalid login, Please check your email and password'
	String get invalidLogin => 'Invalid login, Please check your email and password';

	/// en: 'Too many requests, please try again later'
	String get tooManyRequests => 'Too many requests, please try again later';

	/// en: 'Exceeds max length: ${max}'
	String exceedsMaxLength({required Object max}) => 'Exceeds max length: ${max}';

	/// en: 'Content cannot be empty'
	String get contentCanNotBeEmpty => 'Content cannot be empty';

	/// en: 'Title cannot be empty'
	String get titleCanNotBeEmpty => 'Title cannot be empty';

	/// en: 'Too many requests, please try again later, remaining'
	String get tooManyRequestsPleaseTryAgainLaterText => 'Too many requests, please try again later, remaining';

	/// en: '${num} hours'
	String remainingHours({required Object num}) => '${num} hours';

	/// en: '${num} minutes'
	String remainingMinutes({required Object num}) => '${num} minutes';

	/// en: '${num} seconds'
	String remainingSeconds({required Object num}) => '${num} seconds';

	/// en: 'Tag limit exceeded, limit: ${limit}'
	String tagLimitExceeded({required Object limit}) => 'Tag limit exceeded, limit: ${limit}';

	/// en: 'Failed to refresh'
	String get failedToRefresh => 'Failed to refresh';

	/// en: 'No permission'
	String get noPermission => 'No permission';

	/// en: 'Resource not found'
	String get resourceNotFound => 'Resource not found';

	/// en: 'Failed to save login credentials'
	String get failedToSaveCredentials => 'Failed to save login credentials';

	/// en: 'Failed to load saved credentials'
	String get failedToLoadSavedCredentials => 'Failed to load saved credentials';

	/// en: 'Special follow limit exceeded, limit: ${cnt}, please adjust in the follow list page'
	String specialFollowLimitReached({required Object cnt}) => 'Special follow limit exceeded, limit: ${cnt}, please adjust in the follow list page';

	/// en: 'Content not found or has been deleted'
	String get notFound => 'Content not found or has been deleted';

	late final TranslationsErrorsNetworkEn network = TranslationsErrorsNetworkEn._(_root);
}

// Path: friends
class TranslationsFriendsEn {
	TranslationsFriendsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Click to restore friend'
	String get clickToRestoreFriend => 'Click to restore friend';

	/// en: 'Friends List'
	String get friendsList => 'Friends List';

	/// en: 'Friend Requests'
	String get friendRequests => 'Friend Requests';

	/// en: 'Friend Requests List'
	String get friendRequestsList => 'Friend Requests List';

	/// en: 'Removing friend...'
	String get removingFriend => 'Removing friend...';

	/// en: 'Failed to remove friend'
	String get failedToRemoveFriend => 'Failed to remove friend';

	/// en: 'Canceling friend request...'
	String get cancelingRequest => 'Canceling friend request...';

	/// en: 'Failed to cancel friend request'
	String get failedToCancelRequest => 'Failed to cancel friend request';
}

// Path: authorProfile
class TranslationsAuthorProfileEn {
	TranslationsAuthorProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'No more data'
	String get noMoreDatas => 'No more data';

	/// en: 'User Profile'
	String get userProfile => 'User Profile';
}

// Path: favorites
class TranslationsFavoritesEn {
	TranslationsFavoritesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Click to restore favorite'
	String get clickToRestoreFavorite => 'Click to restore favorite';

	/// en: 'My Favorites'
	String get myFavorites => 'My Favorites';
}

// Path: galleryDetail
class TranslationsGalleryDetailEn {
	TranslationsGalleryDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Gallery Detail'
	String get galleryDetail => 'Gallery Detail';

	/// en: 'View Gallery Detail'
	String get viewGalleryDetail => 'View Gallery Detail';

	/// en: 'Copy Link'
	String get copyLink => 'Copy Link';

	/// en: 'Copy Image'
	String get copyImage => 'Copy Image';

	/// en: 'Save As'
	String get saveAs => 'Save As';

	/// en: 'Save to Album'
	String get saveToAlbum => 'Save to Album';

	/// en: 'Published At'
	String get publishedAt => 'Published At';

	/// en: 'Views Count'
	String get viewsCount => 'Views Count';

	/// en: 'Image Library Function Introduction'
	String get imageLibraryFunctionIntroduction => 'Image Library Function Introduction';

	/// en: 'Right Click to Save Single Image'
	String get rightClickToSaveSingleImage => 'Right Click to Save Single Image';

	/// en: 'Batch Save'
	String get batchSave => 'Batch Save';

	/// en: 'Keyboard Left and Right to Switch'
	String get keyboardLeftAndRightToSwitch => 'Keyboard Left and Right to Switch';

	/// en: 'Keyboard Up and Down to Zoom'
	String get keyboardUpAndDownToZoom => 'Keyboard Up and Down to Zoom';

	/// en: 'Mouse Wheel to Switch'
	String get mouseWheelToSwitch => 'Mouse Wheel to Switch';

	/// en: 'CTRL + Mouse Wheel to Zoom'
	String get ctrlAndMouseWheelToZoom => 'CTRL + Mouse Wheel to Zoom';

	/// en: 'More Features to Be Discovered...'
	String get moreFeaturesToBeDiscovered => 'More Features to Be Discovered...';

	/// en: 'Author's Other Galleries'
	String get authorOtherGalleries => 'Author\'s Other Galleries';

	/// en: 'Related Galleries'
	String get relatedGalleries => 'Related Galleries';

	/// en: 'Click Left and Right Edge to Switch Image'
	String get clickLeftAndRightEdgeToSwitchImage => 'Click Left and Right Edge to Switch Image';
}

// Path: playList
class TranslationsPlayListEn {
	TranslationsPlayListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'My Play List'
	String get myPlayList => 'My Play List';

	/// en: 'Friendly Tips'
	String get friendlyTips => 'Friendly Tips';

	/// en: 'Dear User'
	String get dearUser => 'Dear User';

	/// en: 'iwara's play list system is not perfect yet'
	String get iwaraPlayListSystemIsNotPerfectYet => 'iwara\'s play list system is not perfect yet';

	/// en: 'Not support set cover'
	String get notSupportSetCover => 'Not support set cover';

	/// en: 'Not support delete list'
	String get notSupportDeleteList => 'Not support delete list';

	/// en: 'Not support set private'
	String get notSupportSetPrivate => 'Not support set private';

	/// en: 'Yes... create list will always exist and visible to everyone'
	String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Yes... create list will always exist and visible to everyone';

	/// en: 'Small Suggestion'
	String get smallSuggestion => 'Small Suggestion';

	/// en: 'If you are more concerned about privacy, it is recommended to use the "like" function to collect content'
	String get useLikeToCollectContent => 'If you are more concerned about privacy, it is recommended to use the "like" function to collect content';

	/// en: 'If you have other suggestions or ideas, welcome to discuss on GitHub!'
	String get welcomeToDiscussOnGitHub => 'If you have other suggestions or ideas, welcome to discuss on GitHub!';

	/// en: 'I Understand'
	String get iUnderstand => 'I Understand';

	/// en: 'Search Playlists...'
	String get searchPlaylists => 'Search Playlists...';

	/// en: 'New Playlist Name'
	String get newPlaylistName => 'New Playlist Name';

	/// en: 'Create New Playlist'
	String get createNewPlaylist => 'Create New Playlist';

	/// en: 'Videos'
	String get videos => 'Videos';
}

// Path: search
class TranslationsSearchEn {
	TranslationsSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Search Scope'
	String get googleSearchScope => 'Search Scope';

	/// en: 'Search Tags...'
	String get searchTags => 'Search Tags...';

	/// en: 'Content Rating'
	String get contentRating => 'Content Rating';

	/// en: 'Remove Tag'
	String get removeTag => 'Remove Tag';

	/// en: 'Please enter search content'
	String get pleaseEnterSearchContent => 'Please enter search content';

	/// en: 'Search History'
	String get searchHistory => 'Search History';

	/// en: 'Search Suggestion'
	String get searchSuggestion => 'Search Suggestion';

	/// en: 'Used Times'
	String get usedTimes => 'Used Times';

	/// en: 'Last Used'
	String get lastUsed => 'Last Used';

	/// en: 'No search history'
	String get noSearchHistoryRecords => 'No search history';

	/// en: 'Not support current search type ${searchType}, please wait for the update'
	String notSupportCurrentSearchType({required Object searchType}) => 'Not support current search type ${searchType}, please wait for the update';

	/// en: 'Search Result'
	String get searchResult => 'Search Result';

	/// en: 'Unsupported search type: ${searchType}'
	String unsupportedSearchType({required Object searchType}) => 'Unsupported search type: ${searchType}';

	/// en: 'Google Search'
	String get googleSearch => 'Google Search';

	/// en: '${webName} 's search function is not easy to use? Try Google Search!'
	String googleSearchHint({required Object webName}) => '${webName} \'s search function is not easy to use? Try Google Search!';

	/// en: 'Use the :site search operator of Google Search to search for content on the site. This is very useful when searching for videos, galleries, playlists, and users.'
	String get googleSearchDescription => 'Use the :site search operator of Google Search to search for content on the site. This is very useful when searching for videos, galleries, playlists, and users.';

	/// en: 'Enter keywords to search'
	String get googleSearchKeywordsHint => 'Enter keywords to search';

	/// en: 'Open Link Jump'
	String get openLinkJump => 'Open Link Jump';

	/// en: 'Google Search'
	String get googleSearchButton => 'Google Search';

	/// en: 'Please enter search keywords'
	String get pleaseEnterSearchKeywords => 'Please enter search keywords';

	/// en: 'Search query copied to clipboard'
	String get googleSearchQueryCopied => 'Search query copied to clipboard';

	/// en: 'Failed to open browser: ${error}'
	String googleSearchBrowserOpenFailed({required Object error}) => 'Failed to open browser: ${error}';
}

// Path: mediaList
class TranslationsMediaListEn {
	TranslationsMediaListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personal Introduction'
	String get personalIntroduction => 'Personal Introduction';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'List View Mode'
	String get listViewMode => 'List View Mode';

	/// en: 'Use Traditional Pagination Mode'
	String get useTraditionalPaginationMode => 'Use Traditional Pagination Mode';

	/// en: 'Enable traditional pagination mode, disable waterfall mode'
	String get useTraditionalPaginationModeDesc => 'Enable traditional pagination mode, disable waterfall mode';

	/// en: 'Show Video Progress Bottom Bar When Toolbar Hidden'
	String get showVideoProgressBottomBarWhenToolbarHidden => 'Show Video Progress Bottom Bar When Toolbar Hidden';

	/// en: 'This configuration determines whether the video progress bottom bar will be shown when the toolbar is hidden.'
	String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'This configuration determines whether the video progress bottom bar will be shown when the toolbar is hidden.';

	/// en: 'Basic Settings'
	String get basicSettings => 'Basic Settings';

	/// en: 'Personalized Settings'
	String get personalizedSettings => 'Personalized Settings';

	/// en: 'Other Settings'
	String get otherSettings => 'Other Settings';

	/// en: 'Search Config'
	String get searchConfig => 'Search Config';

	/// en: 'This configuration determines whether the previous configuration will be used when playing videos again.'
	String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'This configuration determines whether the previous configuration will be used when playing videos again.';

	/// en: 'Play Control'
	String get playControl => 'Play Control';

	/// en: 'Fast Forward Time'
	String get fastForwardTime => 'Fast Forward Time';

	/// en: 'Fast forward time must be a positive integer.'
	String get fastForwardTimeMustBeAPositiveInteger => 'Fast forward time must be a positive integer.';

	/// en: 'Rewind Time'
	String get rewindTime => 'Rewind Time';

	/// en: 'Rewind time must be a positive integer.'
	String get rewindTimeMustBeAPositiveInteger => 'Rewind time must be a positive integer.';

	/// en: 'Long Press Playback Speed'
	String get longPressPlaybackSpeed => 'Long Press Playback Speed';

	/// en: 'Long press playback speed must be a positive number.'
	String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Long press playback speed must be a positive number.';

	/// en: 'Repeat'
	String get repeat => 'Repeat';

	/// en: 'Render Vertical Video in Vertical Screen'
	String get renderVerticalVideoInVerticalScreen => 'Render Vertical Video in Vertical Screen';

	/// en: 'This configuration determines whether the video will be rendered in vertical screen when playing in full screen.'
	String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'This configuration determines whether the video will be rendered in vertical screen when playing in full screen.';

	/// en: 'Remember Volume'
	String get rememberVolume => 'Remember Volume';

	/// en: 'This configuration determines whether the volume will be kept when playing videos again.'
	String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'This configuration determines whether the volume will be kept when playing videos again.';

	/// en: 'Remember Brightness'
	String get rememberBrightness => 'Remember Brightness';

	/// en: 'This configuration determines whether the brightness will be kept when playing videos again.'
	String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'This configuration determines whether the brightness will be kept when playing videos again.';

	/// en: 'Play Control Area'
	String get playControlArea => 'Play Control Area';

	/// en: 'Left and Right Control Area Width'
	String get leftAndRightControlAreaWidth => 'Left and Right Control Area Width';

	/// en: 'This configuration determines the width of the control areas on the left and right sides of the player.'
	String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'This configuration determines the width of the control areas on the left and right sides of the player.';

	/// en: 'Proxy address cannot be empty.'
	String get proxyAddressCannotBeEmpty => 'Proxy address cannot be empty.';

	/// en: 'Invalid proxy address format. Please use the format of IP:port or domain name:port.'
	String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Invalid proxy address format. Please use the format of IP:port or domain name:port.';

	/// en: 'Proxy normal work.'
	String get proxyNormalWork => 'Proxy normal work.';

	/// en: 'Test proxy failed, status code: ${code}'
	String testProxyFailedWithStatusCode({required Object code}) => 'Test proxy failed, status code: ${code}';

	/// en: 'Test proxy failed, exception: ${exception}'
	String testProxyFailedWithException({required Object exception}) => 'Test proxy failed, exception: ${exception}';

	/// en: 'Proxy Config'
	String get proxyConfig => 'Proxy Config';

	/// en: 'This is http proxy address'
	String get thisIsHttpProxyAddress => 'This is http proxy address';

	/// en: 'Check Proxy'
	String get checkProxy => 'Check Proxy';

	/// en: 'Proxy Address'
	String get proxyAddress => 'Proxy Address';

	/// en: 'Please enter the URL of the proxy server, for example 127.0.0.1:8080'
	String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Please enter the URL of the proxy server, for example 127.0.0.1:8080';

	/// en: 'Enable Proxy'
	String get enableProxy => 'Enable Proxy';

	/// en: 'Left'
	String get left => 'Left';

	/// en: 'Middle'
	String get middle => 'Middle';

	/// en: 'Right'
	String get right => 'Right';

	/// en: 'Player Settings'
	String get playerSettings => 'Player Settings';

	/// en: 'Network Settings'
	String get networkSettings => 'Network Settings';

	/// en: 'Customize Your Playback Experience'
	String get customizeYourPlaybackExperience => 'Customize Your Playback Experience';

	/// en: 'Choose Your Favorite App Appearance'
	String get chooseYourFavoriteAppAppearance => 'Choose Your Favorite App Appearance';

	/// en: 'Configure Your Proxy Server'
	String get configureYourProxyServer => 'Configure Your Proxy Server';

	/// en: 'Settings'
	String get settings => 'Settings';

	/// en: 'Theme Settings'
	String get themeSettings => 'Theme Settings';

	/// en: 'Follow System'
	String get followSystem => 'Follow System';

	/// en: 'Light Mode'
	String get lightMode => 'Light Mode';

	/// en: 'Dark Mode'
	String get darkMode => 'Dark Mode';

	/// en: 'Preset Theme'
	String get presetTheme => 'Preset Theme';

	/// en: 'Basic Theme'
	String get basicTheme => 'Basic Theme';

	/// en: 'Need to restart the app to apply the settings'
	String get needRestartToApply => 'Need to restart the app to apply the settings';

	/// en: 'The theme settings need to restart the app to apply the settings'
	String get themeNeedRestartDescription => 'The theme settings need to restart the app to apply the settings';

	/// en: 'About'
	String get about => 'About';

	/// en: 'Current Version'
	String get currentVersion => 'Current Version';

	/// en: 'Latest Version'
	String get latestVersion => 'Latest Version';

	/// en: 'Check for Updates'
	String get checkForUpdates => 'Check for Updates';

	/// en: 'Update'
	String get update => 'Update';

	/// en: 'New Version Available'
	String get newVersionAvailable => 'New Version Available';

	/// en: 'Project Home'
	String get projectHome => 'Project Home';

	/// en: 'Release'
	String get release => 'Release';

	/// en: 'Issue Report'
	String get issueReport => 'Issue Report';

	/// en: 'Open Source License'
	String get openSourceLicense => 'Open Source License';

	/// en: 'Check for updates failed, please try again later'
	String get checkForUpdatesFailed => 'Check for updates failed, please try again later';

	/// en: 'Auto Check Update'
	String get autoCheckUpdate => 'Auto Check Update';

	/// en: 'Update Content'
	String get updateContent => 'Update Content';

	/// en: 'Release Date'
	String get releaseDate => 'Release Date';

	/// en: 'Ignore This Version'
	String get ignoreThisVersion => 'Ignore This Version';

	/// en: 'Current version is too low, please update as soon as possible'
	String get minVersionUpdateRequired => 'Current version is too low, please update as soon as possible';

	/// en: 'This is a mandatory update. Please update to the latest version as soon as possible'
	String get forceUpdateTip => 'This is a mandatory update. Please update to the latest version as soon as possible';

	/// en: 'View Changelog'
	String get viewChangelog => 'View Changelog';

	/// en: 'Already the latest version'
	String get alreadyLatestVersion => 'Already the latest version';

	/// en: 'App Settings'
	String get appSettings => 'App Settings';

	/// en: 'Configure Your App Settings'
	String get configureYourAppSettings => 'Configure Your App Settings';

	/// en: 'History'
	String get history => 'History';

	/// en: 'Auto Record History'
	String get autoRecordHistory => 'Auto Record History';

	/// en: 'Auto record the videos and images you have watched'
	String get autoRecordHistoryDesc => 'Auto record the videos and images you have watched';

	/// en: 'Show Unprocessed Markdown Text'
	String get showUnprocessedMarkdownText => 'Show Unprocessed Markdown Text';

	/// en: 'Show the original text of the markdown'
	String get showUnprocessedMarkdownTextDesc => 'Show the original text of the markdown';

	/// en: 'Markdown'
	String get markdown => 'Markdown';

	/// en: 'Privacy Mode'
	String get activeBackgroundPrivacyMode => 'Privacy Mode';

	/// en: 'Prevent screenshots, hide screen when running in the background...'
	String get activeBackgroundPrivacyModeDesc => 'Prevent screenshots, hide screen when running in the background...';

	/// en: 'Privacy'
	String get privacy => 'Privacy';

	/// en: 'Forum'
	String get forum => 'Forum';

	/// en: 'Disable Forum Reply Quote'
	String get disableForumReplyQuote => 'Disable Forum Reply Quote';

	/// en: 'Disable carrying replied floor information when replying in forum'
	String get disableForumReplyQuoteDesc => 'Disable carrying replied floor information when replying in forum';

	/// en: 'Theater Mode'
	String get theaterMode => 'Theater Mode';

	/// en: 'After opening, the player background will be set to the blurred version of the video cover'
	String get theaterModeDesc => 'After opening, the player background will be set to the blurred version of the video cover';

	/// en: 'App Links'
	String get appLinks => 'App Links';

	/// en: 'Default Browse'
	String get defaultBrowser => 'Default Browse';

	/// en: 'Please open the default link configuration item in the system settings and add the iwara.tv website link'
	String get defaultBrowserDesc => 'Please open the default link configuration item in the system settings and add the iwara.tv website link';

	/// en: 'Theme Mode'
	String get themeMode => 'Theme Mode';

	/// en: 'This configuration determines the theme mode of the app'
	String get themeModeDesc => 'This configuration determines the theme mode of the app';

	/// en: 'Dynamic Color'
	String get dynamicColor => 'Dynamic Color';

	/// en: 'This configuration determines whether the app uses dynamic color'
	String get dynamicColorDesc => 'This configuration determines whether the app uses dynamic color';

	/// en: 'Use Dynamic Color'
	String get useDynamicColor => 'Use Dynamic Color';

	/// en: 'This configuration determines whether the app uses dynamic color'
	String get useDynamicColorDesc => 'This configuration determines whether the app uses dynamic color';

	/// en: 'Preset Colors'
	String get presetColors => 'Preset Colors';

	/// en: 'Custom Colors'
	String get customColors => 'Custom Colors';

	/// en: 'Pick Color'
	String get pickColor => 'Pick Color';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'No custom colors'
	String get noCustomColors => 'No custom colors';

	/// en: 'Record and Restore Playback Progress'
	String get recordAndRestorePlaybackProgress => 'Record and Restore Playback Progress';

	/// en: 'Signature'
	String get signature => 'Signature';

	/// en: 'Enable Signature'
	String get enableSignature => 'Enable Signature';

	/// en: 'This configuration determines whether the app will add signature when replying'
	String get enableSignatureDesc => 'This configuration determines whether the app will add signature when replying';

	/// en: 'Enter Signature'
	String get enterSignature => 'Enter Signature';

	/// en: 'Edit Signature'
	String get editSignature => 'Edit Signature';

	/// en: 'Signature Content'
	String get signatureContent => 'Signature Content';

	/// en: 'Export App Configuration'
	String get exportConfig => 'Export App Configuration';

	/// en: 'Export app configuration to a file (excluding download records)'
	String get exportConfigDesc => 'Export app configuration to a file (excluding download records)';

	/// en: 'Import App Configuration'
	String get importConfig => 'Import App Configuration';

	/// en: 'Import app configuration from a file'
	String get importConfigDesc => 'Import app configuration from a file';

	/// en: 'Configuration exported successfully!'
	String get exportConfigSuccess => 'Configuration exported successfully!';

	/// en: 'Failed to export configuration'
	String get exportConfigFailed => 'Failed to export configuration';

	/// en: 'Configuration imported successfully!'
	String get importConfigSuccess => 'Configuration imported successfully!';

	/// en: 'Failed to import configuration'
	String get importConfigFailed => 'Failed to import configuration';

	/// en: 'History Update Logs'
	String get historyUpdateLogs => 'History Update Logs';

	/// en: 'No update logs available'
	String get noUpdateLogs => 'No update logs available';

	/// en: 'Version: {version}'
	String get versionLabel => 'Version: {version}';

	/// en: 'Release Date: {date}'
	String get releaseDateLabel => 'Release Date: {date}';

	/// en: 'No update content available'
	String get noChanges => 'No update content available';

	/// en: 'Interaction'
	String get interaction => 'Interaction';

	/// en: 'Enable Vibration'
	String get enableVibration => 'Enable Vibration';

	/// en: 'Enable vibration feedback when interacting with the app'
	String get enableVibrationDesc => 'Enable vibration feedback when interacting with the app';

	/// en: 'Keep Video Toolbar Visible'
	String get defaultKeepVideoToolbarVisible => 'Keep Video Toolbar Visible';

	/// en: 'This setting determines whether the video toolbar remains visible when first entering the video page.'
	String get defaultKeepVideoToolbarVisibleDesc => 'This setting determines whether the video toolbar remains visible when first entering the video page.';

	/// en: 'Mobile devices enable theater mode, which may cause performance issues. You can choose to enable it.'
	String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Mobile devices enable theater mode, which may cause performance issues. You can choose to enable it.';

	/// en: 'Lock Button Position'
	String get lockButtonPosition => 'Lock Button Position';

	/// en: 'Both Sides'
	String get lockButtonPositionBothSides => 'Both Sides';

	/// en: 'Left Side'
	String get lockButtonPositionLeftSide => 'Left Side';

	/// en: 'Right Side'
	String get lockButtonPositionRightSide => 'Right Side';

	/// en: 'Jump Link'
	String get jumpLink => 'Jump Link';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Language setting has been changed, please restart the app to take effect.'
	String get languageChanged => 'Language setting has been changed, please restart the app to take effect.';

	/// en: 'Gesture Control'
	String get gestureControl => 'Gesture Control';

	/// en: 'Left Double Tap Rewind'
	String get leftDoubleTapRewind => 'Left Double Tap Rewind';

	/// en: 'Right Double Tap Fast Forward'
	String get rightDoubleTapFastForward => 'Right Double Tap Fast Forward';

	/// en: 'Double Tap Pause'
	String get doubleTapPause => 'Double Tap Pause';

	/// en: 'Right Vertical Swipe Volume (Effective when entering a new page)'
	String get rightVerticalSwipeVolume => 'Right Vertical Swipe Volume (Effective when entering a new page)';

	/// en: 'Left Vertical Swipe Brightness (Effective when entering a new page)'
	String get leftVerticalSwipeBrightness => 'Left Vertical Swipe Brightness (Effective when entering a new page)';

	/// en: 'Long Press Fast Forward'
	String get longPressFastForward => 'Long Press Fast Forward';

	/// en: 'Enable Mouse Hover Show Toolbar'
	String get enableMouseHoverShowToolbar => 'Enable Mouse Hover Show Toolbar';

	/// en: 'When enabled, the video toolbar will be shown when the mouse is hovering over the player. It will be automatically hidden after 3 seconds of inactivity.'
	String get enableMouseHoverShowToolbarInfo => 'When enabled, the video toolbar will be shown when the mouse is hovering over the player. It will be automatically hidden after 3 seconds of inactivity.';

	/// en: 'Audio Video Configuration'
	String get audioVideoConfig => 'Audio Video Configuration';

	/// en: 'Expand Buffer'
	String get expandBuffer => 'Expand Buffer';

	/// en: 'When enabled, the buffer size increases, loading time becomes longer but playback is smoother'
	String get expandBufferInfo => 'When enabled, the buffer size increases, loading time becomes longer but playback is smoother';

	/// en: 'Video Sync Mode'
	String get videoSyncMode => 'Video Sync Mode';

	/// en: 'Audio-video synchronization strategy'
	String get videoSyncModeSubtitle => 'Audio-video synchronization strategy';

	/// en: 'Hardware Decoding Mode'
	String get hardwareDecodingMode => 'Hardware Decoding Mode';

	/// en: 'Hardware decoding settings'
	String get hardwareDecodingModeSubtitle => 'Hardware decoding settings';

	/// en: 'Enable Hardware Acceleration'
	String get enableHardwareAcceleration => 'Enable Hardware Acceleration';

	/// en: 'Enabling hardware acceleration can improve decoding performance, but some devices may not be compatible'
	String get enableHardwareAccelerationInfo => 'Enabling hardware acceleration can improve decoding performance, but some devices may not be compatible';

	/// en: 'Use OpenSLES Audio Output'
	String get useOpenSLESAudioOutput => 'Use OpenSLES Audio Output';

	/// en: 'Use low-latency audio output, may improve audio performance'
	String get useOpenSLESAudioOutputInfo => 'Use low-latency audio output, may improve audio performance';

	/// en: 'Audio Sync'
	String get videoSyncAudio => 'Audio Sync';

	/// en: 'Display Resample'
	String get videoSyncDisplayResample => 'Display Resample';

	/// en: 'Display Resample (Drop Frames)'
	String get videoSyncDisplayResampleVdrop => 'Display Resample (Drop Frames)';

	/// en: 'Display Resample (Desync)'
	String get videoSyncDisplayResampleDesync => 'Display Resample (Desync)';

	/// en: 'Display Tempo'
	String get videoSyncDisplayTempo => 'Display Tempo';

	/// en: 'Display Drop Video Frames'
	String get videoSyncDisplayVdrop => 'Display Drop Video Frames';

	/// en: 'Display Drop Audio Frames'
	String get videoSyncDisplayAdrop => 'Display Drop Audio Frames';

	/// en: 'Display Desync'
	String get videoSyncDisplayDesync => 'Display Desync';

	/// en: 'Desync'
	String get videoSyncDesync => 'Desync';

	/// en: 'Auto'
	String get hardwareDecodingAuto => 'Auto';

	/// en: 'Auto Copy'
	String get hardwareDecodingAutoCopy => 'Auto Copy';

	/// en: 'Auto Safe'
	String get hardwareDecodingAutoSafe => 'Auto Safe';

	/// en: 'Disabled'
	String get hardwareDecodingNo => 'Disabled';

	/// en: 'Force Enable'
	String get hardwareDecodingYes => 'Force Enable';

	late final TranslationsSettingsDownloadSettingsEn downloadSettings = TranslationsSettingsDownloadSettingsEn._(_root);
}

// Path: oreno3d
class TranslationsOreno3dEn {
	TranslationsOreno3dEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Oreno3D'
	String get name => 'Oreno3D';

	/// en: 'Tags'
	String get tags => 'Tags';

	/// en: 'Characters'
	String get characters => 'Characters';

	/// en: 'Origin'
	String get origin => 'Origin';

	/// en: 'The **tags**, **characters**, and **origin** information displayed here are provided by the third-party site **Oreno3D** for reference only. Since this information source is only available in Japanese, it currently lacks internationalization adaptation. If you are interested in contributing to internationalization efforts, please visit the repository to help improve it!'
	String get thirdPartyTagsExplanation => 'The **tags**, **characters**, and **origin** information displayed here are provided by the third-party site **Oreno3D** for reference only.\n\nSince this information source is only available in Japanese, it currently lacks internationalization adaptation.\n\nIf you are interested in contributing to internationalization efforts, please visit the repository to help improve it!';

	late final TranslationsOreno3dSortTypesEn sortTypes = TranslationsOreno3dSortTypesEn._(_root);
	late final TranslationsOreno3dErrorsEn errors = TranslationsOreno3dErrorsEn._(_root);
	late final TranslationsOreno3dLoadingEn loading = TranslationsOreno3dLoadingEn._(_root);
	late final TranslationsOreno3dMessagesEn messages = TranslationsOreno3dMessagesEn._(_root);
}

// Path: signIn
class TranslationsSignInEn {
	TranslationsSignInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please login first'
	String get pleaseLoginFirst => 'Please login first';

	/// en: 'You have already signed in today!'
	String get alreadySignedInToday => 'You have already signed in today!';

	/// en: 'You did not stick to the sign in.'
	String get youDidNotStickToTheSignIn => 'You did not stick to the sign in.';

	/// en: 'Sign in successfully!'
	String get signInSuccess => 'Sign in successfully!';

	/// en: 'Sign in failed, please try again later'
	String get signInFailed => 'Sign in failed, please try again later';

	/// en: 'Consecutive Sign Ins'
	String get consecutiveSignIns => 'Consecutive Sign Ins';

	/// en: 'Failure Reason'
	String get failureReason => 'Failure Reason';

	/// en: 'Select Date Range'
	String get selectDateRange => 'Select Date Range';

	/// en: 'Start Date'
	String get startDate => 'Start Date';

	/// en: 'End Date'
	String get endDate => 'End Date';

	/// en: 'Invalid Date'
	String get invalidDate => 'Invalid Date';

	/// en: 'Invalid Date Range'
	String get invalidDateRange => 'Invalid Date Range';

	/// en: 'Date Format Error'
	String get errorFormatText => 'Date Format Error';

	/// en: 'Invalid Date Range'
	String get errorInvalidText => 'Invalid Date Range';

	/// en: 'Invalid Date Range'
	String get errorInvalidRangeText => 'Invalid Date Range';

	/// en: 'Date range cannot be more than one year'
	String get dateRangeCantBeMoreThanOneYear => 'Date range cannot be more than one year';

	/// en: 'Sign In'
	String get signIn => 'Sign In';

	/// en: 'Sign In Record'
	String get signInRecord => 'Sign In Record';

	/// en: 'Total Sign Ins'
	String get totalSignIns => 'Total Sign Ins';

	/// en: 'Please select sign in status'
	String get pleaseSelectSignInStatus => 'Please select sign in status';
}

// Path: subscriptions
class TranslationsSubscriptionsEn {
	TranslationsSubscriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please login first to view your subscriptions.'
	String get pleaseLoginFirstToViewYourSubscriptions => 'Please login first to view your subscriptions.';

	/// en: 'Select User'
	String get selectUser => 'Select User';

	/// en: 'No subscribed users'
	String get noSubscribedUsers => 'No subscribed users';

	/// en: 'Show all subscribed users content'
	String get showAllSubscribedUsersContent => 'Show all subscribed users content';
}

// Path: videoDetail
class TranslationsVideoDetailEn {
	TranslationsVideoDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'PiP Mode'
	String get pipMode => 'PiP Mode';

	/// en: 'Resume from last position: ${position}'
	String resumeFromLastPosition({required Object position}) => 'Resume from last position: ${position}';

	/// en: 'Video ID is empty'
	String get videoIdIsEmpty => 'Video ID is empty';

	/// en: 'Video info is empty'
	String get videoInfoIsEmpty => 'Video info is empty';

	/// en: 'This is a private video'
	String get thisIsAPrivateVideo => 'This is a private video';

	/// en: 'Get video info failed, please try again later'
	String get getVideoInfoFailed => 'Get video info failed, please try again later';

	/// en: 'No video source found'
	String get noVideoSourceFound => 'No video source found';

	/// en: 'Tag "${tagId}" copied to clipboard'
	String tagCopiedToClipboard({required Object tagId}) => 'Tag "${tagId}" copied to clipboard';

	/// en: 'Error loading video'
	String get errorLoadingVideo => 'Error loading video';

	/// en: 'Play'
	String get play => 'Play';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Exit App Fullscreen'
	String get exitAppFullscreen => 'Exit App Fullscreen';

	/// en: 'Enter App Fullscreen'
	String get enterAppFullscreen => 'Enter App Fullscreen';

	/// en: 'Exit System Fullscreen'
	String get exitSystemFullscreen => 'Exit System Fullscreen';

	/// en: 'Enter System Fullscreen'
	String get enterSystemFullscreen => 'Enter System Fullscreen';

	/// en: 'Seek To'
	String get seekTo => 'Seek To';

	/// en: 'Switch Resolution'
	String get switchResolution => 'Switch Resolution';

	/// en: 'Switch Playback Speed'
	String get switchPlaybackSpeed => 'Switch Playback Speed';

	/// en: 'Rewind ${num} seconds'
	String rewindSeconds({required Object num}) => 'Rewind ${num} seconds';

	/// en: 'Fast Forward ${num} seconds'
	String fastForwardSeconds({required Object num}) => 'Fast Forward ${num} seconds';

	/// en: 'Playing at ${rate}x speed'
	String playbackSpeedIng({required Object rate}) => 'Playing at ${rate}x speed';

	/// en: 'Brightness'
	String get brightness => 'Brightness';

	/// en: 'Brightness is lowest'
	String get brightnessLowest => 'Brightness is lowest';

	/// en: 'Volume'
	String get volume => 'Volume';

	/// en: 'Volume is muted'
	String get volumeMuted => 'Volume is muted';

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Video Player'
	String get videoPlayer => 'Video Player';

	/// en: 'Video Player Info'
	String get videoPlayerInfo => 'Video Player Info';

	/// en: 'More Settings'
	String get moreSettings => 'More Settings';

	/// en: 'Video Player Feature Info'
	String get videoPlayerFeatureInfo => 'Video Player Feature Info';

	/// en: 'Auto Rewind'
	String get autoRewind => 'Auto Rewind';

	/// en: 'Rewind and Fast Forward'
	String get rewindAndFastForward => 'Rewind and Fast Forward';

	/// en: 'Volume and Brightness'
	String get volumeAndBrightness => 'Volume and Brightness';

	/// en: 'Center Area Double Tap Pause or Play'
	String get centerAreaDoubleTapPauseOrPlay => 'Center Area Double Tap Pause or Play';

	/// en: 'Show Vertical Video in Full Screen'
	String get showVerticalVideoInFullScreen => 'Show Vertical Video in Full Screen';

	/// en: 'Keep Last Volume and Brightness'
	String get keepLastVolumeAndBrightness => 'Keep Last Volume and Brightness';

	/// en: 'Set Proxy'
	String get setProxy => 'Set Proxy';

	/// en: 'More Features to Be Discovered...'
	String get moreFeaturesToBeDiscovered => 'More Features to Be Discovered...';

	/// en: 'Video Player Settings'
	String get videoPlayerSettings => 'Video Player Settings';

	/// en: '${num} comments'
	String commentCount({required Object num}) => '${num} comments';

	/// en: 'Write your comment here...'
	String get writeYourCommentHere => 'Write your comment here...';

	/// en: 'Author's Other Videos'
	String get authorOtherVideos => 'Author\'s Other Videos';

	/// en: 'Related Videos'
	String get relatedVideos => 'Related Videos';

	/// en: 'This is a private video'
	String get privateVideo => 'This is a private video';

	/// en: 'This is an external video'
	String get externalVideo => 'This is an external video';

	/// en: 'Open in Browser'
	String get openInBrowser => 'Open in Browser';

	/// en: 'This video seems to have been deleted :/'
	String get resourceDeleted => 'This video seems to have been deleted :/';

	/// en: 'No download URL'
	String get noDownloadUrl => 'No download URL';

	/// en: 'Start downloading'
	String get startDownloading => 'Start downloading';

	/// en: 'Download failed, please try again later'
	String get downloadFailed => 'Download failed, please try again later';

	/// en: 'Download success'
	String get downloadSuccess => 'Download success';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Download Manager'
	String get downloadManager => 'Download Manager';

	/// en: 'Resource not found'
	String get resourceNotFound => 'Resource not found';

	/// en: 'Video load error'
	String get videoLoadError => 'Video load error';

	/// en: 'Author has no other videos'
	String get authorNoOtherVideos => 'Author has no other videos';

	/// en: 'No related videos'
	String get noRelatedVideos => 'No related videos';

	late final TranslationsVideoDetailSkeletonEn skeleton = TranslationsVideoDetailSkeletonEn._(_root);
}

// Path: share
class TranslationsShareEn {
	TranslationsShareEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Share Play List'
	String get sharePlayList => 'Share Play List';

	/// en: 'Wow, did you see this?'
	String get wowDidYouSeeThis => 'Wow, did you see this?';

	/// en: 'Name is'
	String get nameIs => 'Name is';

	/// en: 'Click link to view'
	String get clickLinkToView => 'Click link to view';

	/// en: 'I really like this'
	String get iReallyLikeThis => 'I really like this';

	/// en: 'Share failed, please try again later'
	String get shareFailed => 'Share failed, please try again later';

	/// en: 'Share'
	String get share => 'Share';

	/// en: 'Share as Image'
	String get shareAsImage => 'Share as Image';

	/// en: 'Share as Text'
	String get shareAsText => 'Share as Text';

	/// en: 'Share the video cover as an image'
	String get shareAsImageDesc => 'Share the video cover as an image';

	/// en: 'Share the video details as text'
	String get shareAsTextDesc => 'Share the video details as text';

	/// en: 'Share the video cover as an image failed, please try again later'
	String get shareAsImageFailed => 'Share the video cover as an image failed, please try again later';

	/// en: 'Share the video details as text failed, please try again later'
	String get shareAsTextFailed => 'Share the video details as text failed, please try again later';

	/// en: 'Share Video'
	String get shareVideo => 'Share Video';

	/// en: 'Author is'
	String get authorIs => 'Author is';

	/// en: 'Share Gallery'
	String get shareGallery => 'Share Gallery';

	/// en: 'Gallery title is'
	String get galleryTitleIs => 'Gallery title is';

	/// en: 'Gallery author is'
	String get galleryAuthorIs => 'Gallery author is';

	/// en: 'Share User'
	String get shareUser => 'Share User';

	/// en: 'User name is'
	String get userNameIs => 'User name is';

	/// en: 'User author is'
	String get userAuthorIs => 'User author is';

	/// en: 'Comments'
	String get comments => 'Comments';

	/// en: 'Share Thread'
	String get shareThread => 'Share Thread';

	/// en: 'Views'
	String get views => 'Views';

	/// en: 'Share Post'
	String get sharePost => 'Share Post';

	/// en: 'Post title is'
	String get postTitleIs => 'Post title is';

	/// en: 'Post author is'
	String get postAuthorIs => 'Post author is';
}

// Path: markdown
class TranslationsMarkdownEn {
	TranslationsMarkdownEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Markdown Syntax'
	String get markdownSyntax => 'Markdown Syntax';

	/// en: 'Iwara Special Markdown Syntax'
	String get iwaraSpecialMarkdownSyntax => 'Iwara Special Markdown Syntax';

	/// en: 'Internal Link'
	String get internalLink => 'Internal Link';

	/// en: 'Support auto convert link below:'
	String get supportAutoConvertLinkBelow => 'Support auto convert link below:';

	/// en: '🎬 Video Link\n🖼️ Image Link\n👤 User Link\n📌 Forum Link\n🎵 Playlist Link\n💬 Thread Link'
	String get convertLinkExample => '🎬 Video Link\n🖼️ Image Link\n👤 User Link\n📌 Forum Link\n🎵 Playlist Link\n💬 Thread Link';

	/// en: 'Mention User'
	String get mentionUser => 'Mention User';

	/// en: 'Input @ followed by username, will be automatically converted to user link'
	String get mentionUserDescription => 'Input @ followed by username, will be automatically converted to user link';

	/// en: 'Markdown Basic Syntax'
	String get markdownBasicSyntax => 'Markdown Basic Syntax';

	/// en: 'Paragraph and Line Break'
	String get paragraphAndLineBreak => 'Paragraph and Line Break';

	/// en: 'Paragraphs are separated by a line, and two spaces at the end of the line will be converted to a line break'
	String get paragraphAndLineBreakDescription => 'Paragraphs are separated by a line, and two spaces at the end of the line will be converted to a line break';

	/// en: 'This is the first paragraph\n\nThis is the second paragraph\nThis line ends with two spaces \nwill be converted to a line break'
	String get paragraphAndLineBreakSyntax => 'This is the first paragraph\n\nThis is the second paragraph\nThis line ends with two spaces  \nwill be converted to a line break';

	/// en: 'Text Style'
	String get textStyle => 'Text Style';

	/// en: 'Use special symbols to surround text to change style'
	String get textStyleDescription => 'Use special symbols to surround text to change style';

	/// en: '**Bold Text**\n*Italic Text*\n~~Strikethrough Text~~\n`Code Text`'
	String get textStyleSyntax => '**Bold Text**\n*Italic Text*\n~~Strikethrough Text~~\n`Code Text`';

	/// en: 'Quote'
	String get quote => 'Quote';

	/// en: 'Use > symbol to create quote, multiple > to create multi-level quote'
	String get quoteDescription => 'Use > symbol to create quote, multiple > to create multi-level quote';

	/// en: '> This is a first-level quote\n>> This is a second-level quote'
	String get quoteSyntax => '> This is a first-level quote\n>> This is a second-level quote';

	/// en: 'List'
	String get list => 'List';

	/// en: 'Create ordered list with number+dot, create unordered list with -'
	String get listDescription => 'Create ordered list with number+dot, create unordered list with -';

	/// en: '1. First item\n2. Second item\n\n- Unordered item\n - Subitem\n - Another subitem'
	String get listSyntax => '1. First item\n2. Second item\n\n- Unordered item\n  - Subitem\n  - Another subitem';

	/// en: 'Link and Image'
	String get linkAndImage => 'Link and Image';

	/// en: 'Link format: [text](URL)\nImage format: ![description](URL)'
	String get linkAndImageDescription => 'Link format: [text](URL)\nImage format: ![description](URL)';

	/// en: '[link text](${link})\n![image description](${imgUrl})'
	String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[link text](${link})\n![image description](${imgUrl})';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Use # symbol to create title, number to show level'
	String get titleDescription => 'Use # symbol to create title, number to show level';

	/// en: '# First-level title\n## Second-level title\n### Third-level title'
	String get titleSyntax => '# First-level title\n## Second-level title\n### Third-level title';

	/// en: 'Separator'
	String get separator => 'Separator';

	/// en: 'Create separator with three or more - symbols'
	String get separatorDescription => 'Create separator with three or more - symbols';

	/// en: '---'
	String get separatorSyntax => '---';

	/// en: 'Syntax'
	String get syntax => 'Syntax';
}

// Path: forum
class TranslationsForumEn {
	TranslationsForumEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recent'
	String get recent => 'Recent';

	/// en: 'Category'
	String get category => 'Category';

	/// en: 'Last Reply'
	String get lastReply => 'Last Reply';

	late final TranslationsForumErrorsEn errors = TranslationsForumErrorsEn._(_root);

	/// en: 'Create Post'
	String get createPost => 'Create Post';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Enter Title'
	String get enterTitle => 'Enter Title';

	/// en: 'Content'
	String get content => 'Content';

	/// en: 'Enter Content'
	String get enterContent => 'Enter Content';

	/// en: 'Write your content here...'
	String get writeYourContentHere => 'Write your content here...';

	/// en: 'Posts'
	String get posts => 'Posts';

	/// en: 'Threads'
	String get threads => 'Threads';

	/// en: 'Forum'
	String get forum => 'Forum';

	/// en: 'Create Thread'
	String get createThread => 'Create Thread';

	/// en: 'Select Category'
	String get selectCategory => 'Select Category';

	/// en: 'Cooldown remaining ${minutes} minutes ${seconds} seconds'
	String cooldownRemaining({required Object minutes, required Object seconds}) => 'Cooldown remaining ${minutes} minutes ${seconds} seconds';

	late final TranslationsForumGroupsEn groups = TranslationsForumGroupsEn._(_root);
	late final TranslationsForumLeafNamesEn leafNames = TranslationsForumLeafNamesEn._(_root);
	late final TranslationsForumLeafDescriptionsEn leafDescriptions = TranslationsForumLeafDescriptionsEn._(_root);

	/// en: 'Reply'
	String get reply => 'Reply';

	/// en: 'Pending Review'
	String get pendingReview => 'Pending Review';

	/// en: 'Edited At'
	String get editedAt => 'Edited At';

	/// en: 'Copied to clipboard'
	String get copySuccess => 'Copied to clipboard';

	/// en: 'Copied to clipboard: ${str}'
	String copySuccessForMessage({required Object str}) => 'Copied to clipboard: ${str}';

	/// en: 'Edit Reply'
	String get editReply => 'Edit Reply';

	/// en: 'Edit Title'
	String get editTitle => 'Edit Title';

	/// en: 'Submit'
	String get submit => 'Submit';
}

// Path: notifications
class TranslationsNotificationsEn {
	TranslationsNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsNotificationsErrorsEn errors = TranslationsNotificationsErrorsEn._(_root);

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Profile'
	String get profile => 'Profile';

	/// en: 'Posted new comment'
	String get postedNewComment => 'Posted new comment';

	/// en: 'In your'
	String get inYour => 'In your';

	/// en: 'Video'
	String get video => 'Video';

	/// en: 'Replied your video comment'
	String get repliedYourVideoComment => 'Replied your video comment';

	/// en: 'Copy notification info to clipboard'
	String get copyInfoToClipboard => 'Copy notification info to clipboard';

	/// en: 'Copied to clipboard'
	String get copySuccess => 'Copied to clipboard';

	/// en: 'Copied to clipboard: ${str}'
	String copySuccessForMessage({required Object str}) => 'Copied to clipboard: ${str}';

	/// en: 'Mark all as read'
	String get markAllAsRead => 'Mark all as read';

	/// en: 'All notifications have been marked as read'
	String get markAllAsReadSuccess => 'All notifications have been marked as read';

	/// en: 'Mark all as read failed'
	String get markAllAsReadFailed => 'Mark all as read failed';

	/// en: 'Mark selected as read'
	String get markSelectedAsRead => 'Mark selected as read';

	/// en: 'Selected notifications have been marked as read'
	String get markSelectedAsReadSuccess => 'Selected notifications have been marked as read';

	/// en: 'Mark selected as read failed'
	String get markSelectedAsReadFailed => 'Mark selected as read failed';

	/// en: 'Mark as read'
	String get markAsRead => 'Mark as read';

	/// en: 'Notification has been marked as read'
	String get markAsReadSuccess => 'Notification has been marked as read';

	/// en: 'Notification marked as read failed'
	String get markAsReadFailed => 'Notification marked as read failed';

	/// en: 'Notification Type Help'
	String get notificationTypeHelp => 'Notification Type Help';

	/// en: 'Due to the lack of notification type details, the supported types may not cover the messages you currently receive'
	String get dueToLackOfNotificationTypeDetails => 'Due to the lack of notification type details, the supported types may not cover the messages you currently receive';

	/// en: 'If you are willing to help us improve the support for notification types'
	String get helpUsImproveNotificationTypeSupport => 'If you are willing to help us improve the support for notification types';

	/// en: '1. 📋 Copy the notification information\n2. 🐞 Submit an issue to the project repository\n\n⚠️ Note: Notification information may contain personal privacy, if you do not want to public, you can also send it to the project author by email.'
	String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Copy the notification information\n2. 🐞 Submit an issue to the project repository\n\n⚠️ Note: Notification information may contain personal privacy, if you do not want to public, you can also send it to the project author by email.';

	/// en: 'Go to Repository'
	String get goToRepository => 'Go to Repository';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Comment Approved'
	String get commentApproved => 'Comment Approved';

	/// en: 'Replied your profile comment'
	String get repliedYourProfileComment => 'Replied your profile comment';

	/// en: 'replied to your comment on'
	String get kReplied => 'replied to your comment on';

	/// en: 'commented on your'
	String get kCommented => 'commented on your';

	/// en: 'video'
	String get kVideo => 'video';

	/// en: 'gallery'
	String get kGallery => 'gallery';

	/// en: 'profile'
	String get kProfile => 'profile';

	/// en: 'thread'
	String get kThread => 'thread';

	/// en: 'post'
	String get kPost => 'post';

	/// en: 'comment section'
	String get kCommentSection => 'comment section';

	/// en: 'Comment approved'
	String get kApprovedComment => 'Comment approved';

	/// en: 'Video approved'
	String get kApprovedVideo => 'Video approved';

	/// en: 'Gallery approved'
	String get kApprovedGallery => 'Gallery approved';

	/// en: 'Thread approved'
	String get kApprovedThread => 'Thread approved';

	/// en: 'Post approved'
	String get kApprovedPost => 'Post approved';

	/// en: 'Unknown notification type'
	String get kUnknownType => 'Unknown notification type';
}

// Path: conversation
class TranslationsConversationEn {
	TranslationsConversationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsConversationErrorsEn errors = TranslationsConversationErrorsEn._(_root);

	/// en: 'Conversation'
	String get conversation => 'Conversation';

	/// en: 'Start Conversation'
	String get startConversation => 'Start Conversation';

	/// en: 'No conversation'
	String get noConversation => 'No conversation';

	/// en: 'Select from left list and start conversation'
	String get selectFromLeftListAndStartConversation => 'Select from left list and start conversation';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Body'
	String get body => 'Body';

	/// en: 'Select a user'
	String get selectAUser => 'Select a user';

	/// en: 'Search users...'
	String get searchUsers => 'Search users...';

	/// en: 'No conversions'
	String get tmpNoConversions => 'No conversions';

	/// en: 'Delete this message'
	String get deleteThisMessage => 'Delete this message';

	/// en: 'This operation cannot be undone'
	String get deleteThisMessageSubtitle => 'This operation cannot be undone';

	/// en: 'Write message here...'
	String get writeMessageHere => 'Write message here...';

	/// en: 'Send message'
	String get sendMessage => 'Send message';
}

// Path: splash
class TranslationsSplashEn {
	TranslationsSplashEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSplashErrorsEn errors = TranslationsSplashErrorsEn._(_root);

	/// en: 'Preparing...'
	String get preparing => 'Preparing...';

	/// en: 'Initializing...'
	String get initializing => 'Initializing...';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Ready'
	String get ready => 'Ready';

	/// en: 'Initializing message service...'
	String get initializingMessageService => 'Initializing message service...';
}

// Path: download
class TranslationsDownloadEn {
	TranslationsDownloadEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsDownloadErrorsEn errors = TranslationsDownloadErrorsEn._(_root);

	/// en: 'Download List'
	String get downloadList => 'Download List';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Start Downloading'
	String get startDownloading => 'Start Downloading';

	/// en: 'Clear All Failed Tasks'
	String get clearAllFailedTasks => 'Clear All Failed Tasks';

	/// en: 'Are you sure you want to clear all failed download tasks? The files of these tasks will also be deleted.'
	String get clearAllFailedTasksConfirmation => 'Are you sure you want to clear all failed download tasks? The files of these tasks will also be deleted.';

	/// en: 'Cleared all failed tasks'
	String get clearAllFailedTasksSuccess => 'Cleared all failed tasks';

	/// en: 'Error occurred while clearing failed tasks'
	String get clearAllFailedTasksError => 'Error occurred while clearing failed tasks';

	/// en: 'Download Status'
	String get downloadStatus => 'Download Status';

	/// en: 'Image List'
	String get imageList => 'Image List';

	/// en: 'Retry Download'
	String get retryDownload => 'Retry Download';

	/// en: 'Not Downloaded'
	String get notDownloaded => 'Not Downloaded';

	/// en: 'Downloaded'
	String get downloaded => 'Downloaded';

	/// en: 'Waiting for Download'
	String get waitingForDownload => 'Waiting for Download';

	/// en: 'Downloading (${downloaded}/${total} images ${progress}%)'
	String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Downloading (${downloaded}/${total} images ${progress}%)';

	/// en: 'Downloading (${downloaded} images)'
	String downloadingSingleImageProgress({required Object downloaded}) => 'Downloading (${downloaded} images)';

	/// en: 'Paused (${downloaded}/${total} images ${progress}%)'
	String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Paused (${downloaded}/${total} images ${progress}%)';

	/// en: 'Paused (${downloaded} images)'
	String pausedSingleImageProgress({required Object downloaded}) => 'Paused (${downloaded} images)';

	/// en: 'Downloaded (Total ${total} images)'
	String downloadedProgressForImageProgress({required Object total}) => 'Downloaded (Total ${total} images)';

	/// en: 'View Video Detail'
	String get viewVideoDetail => 'View Video Detail';

	/// en: 'View Gallery Detail'
	String get viewGalleryDetail => 'View Gallery Detail';

	/// en: 'More Options'
	String get moreOptions => 'More Options';

	/// en: 'Open File'
	String get openFile => 'Open File';

	/// en: 'Pause'
	String get pause => 'Pause';

	/// en: 'Resume'
	String get resume => 'Resume';

	/// en: 'Copy Download URL'
	String get copyDownloadUrl => 'Copy Download URL';

	/// en: 'Show in Folder'
	String get showInFolder => 'Show in Folder';

	/// en: 'Delete Task'
	String get deleteTask => 'Delete Task';

	/// en: 'Are you sure you want to delete this download task?\nThe task file will also be deleted.'
	String get deleteTaskConfirmation => 'Are you sure you want to delete this download task?\nThe task file will also be deleted.';

	/// en: 'Force Delete Task'
	String get forceDeleteTask => 'Force Delete Task';

	/// en: 'Are you sure you want to force delete this download task?\nThe task file will also be deleted, even if the file is being used.'
	String get forceDeleteTaskConfirmation => 'Are you sure you want to force delete this download task?\nThe task file will also be deleted, even if the file is being used.';

	/// en: 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s'
	String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';

	/// en: 'Downloading ${downloaded} • ${speed}MB/s'
	String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Downloading ${downloaded} • ${speed}MB/s';

	/// en: 'Paused ${downloaded}/${total} (${progress}%)'
	String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Paused ${downloaded}/${total} (${progress}%)';

	/// en: 'Paused • Downloaded ${downloaded}'
	String pausedAndDownloaded({required Object downloaded}) => 'Paused • Downloaded ${downloaded}';

	/// en: 'Downloaded • ${size}'
	String downloadedWithSize({required Object size}) => 'Downloaded • ${size}';

	/// en: 'Download URL copied'
	String get copyDownloadUrlSuccess => 'Download URL copied';

	/// en: '${num} images'
	String totalImageNums({required Object num}) => '${num} images';

	/// en: 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s'
	String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';

	/// en: 'Downloading'
	String get downloading => 'Downloading';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'Completed'
	String get completed => 'Completed';

	/// en: 'Download Detail'
	String get downloadDetail => 'Download Detail';

	/// en: 'Copy'
	String get copy => 'Copy';

	/// en: 'Copied'
	String get copySuccess => 'Copied';

	/// en: 'Waiting'
	String get waiting => 'Waiting';

	/// en: 'Paused'
	String get paused => 'Paused';

	/// en: 'Downloading ${downloaded}'
	String downloadingOnlyDownloaded({required Object downloaded}) => 'Downloading ${downloaded}';

	/// en: 'Gallery Download Completed: ${galleryName}'
	String galleryDownloadCompletedWithName({required Object galleryName}) => 'Gallery Download Completed: ${galleryName}';

	/// en: 'Download Completed: ${fileName}'
	String downloadCompletedWithName({required Object fileName}) => 'Download Completed: ${fileName}';

	/// en: 'Still in development'
	String get stillInDevelopment => 'Still in development';

	/// en: 'Save to app directory'
	String get saveToAppDirectory => 'Save to app directory';
}

// Path: favorite
class TranslationsFavoriteEn {
	TranslationsFavoriteEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFavoriteErrorsEn errors = TranslationsFavoriteErrorsEn._(_root);

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Add success'
	String get addSuccess => 'Add success';

	/// en: 'Add failed'
	String get addFailed => 'Add failed';

	/// en: 'Remove'
	String get remove => 'Remove';

	/// en: 'Remove success'
	String get removeSuccess => 'Remove success';

	/// en: 'Remove failed'
	String get removeFailed => 'Remove failed';

	/// en: 'Are you sure you want to remove this item from favorites?'
	String get removeConfirmation => 'Are you sure you want to remove this item from favorites?';

	/// en: 'Item removed from favorites'
	String get removeConfirmationSuccess => 'Item removed from favorites';

	/// en: 'Failed to remove item from favorites'
	String get removeConfirmationFailed => 'Failed to remove item from favorites';

	/// en: 'Folder created successfully'
	String get createFolderSuccess => 'Folder created successfully';

	/// en: 'Failed to create folder'
	String get createFolderFailed => 'Failed to create folder';

	/// en: 'Create Folder'
	String get createFolder => 'Create Folder';

	/// en: 'Enter folder name'
	String get enterFolderName => 'Enter folder name';

	/// en: 'Enter folder name here...'
	String get enterFolderNameHere => 'Enter folder name here...';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Items'
	String get items => 'Items';

	/// en: 'New Folder'
	String get newFolderName => 'New Folder';

	/// en: 'Search folders...'
	String get searchFolders => 'Search folders...';

	/// en: 'Search items...'
	String get searchItems => 'Search items...';

	/// en: 'Created At'
	String get createdAt => 'Created At';

	/// en: 'My Favorites'
	String get myFavorites => 'My Favorites';

	/// en: 'Delete Folder'
	String get deleteFolderTitle => 'Delete Folder';

	/// en: 'Are you sure you want to delete ${title} folder?'
	String deleteFolderConfirmWithTitle({required Object title}) => 'Are you sure you want to delete ${title} folder?';

	/// en: 'Remove Item'
	String get removeItemTitle => 'Remove Item';

	/// en: 'Are you sure you want to delete ${title} item?'
	String removeItemConfirmWithTitle({required Object title}) => 'Are you sure you want to delete ${title} item?';

	/// en: 'Item removed from favorites'
	String get removeItemSuccess => 'Item removed from favorites';

	/// en: 'Failed to remove item from favorites'
	String get removeItemFailed => 'Failed to remove item from favorites';

	/// en: 'Local Favorite'
	String get localizeFavorite => 'Local Favorite';

	/// en: 'Edit Folder'
	String get editFolderTitle => 'Edit Folder';

	/// en: 'Folder updated successfully'
	String get editFolderSuccess => 'Folder updated successfully';

	/// en: 'Failed to update folder'
	String get editFolderFailed => 'Failed to update folder';

	/// en: 'Search tags'
	String get searchTags => 'Search tags';
}

// Path: translation
class TranslationsTranslationEn {
	TranslationsTranslationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Test Connection'
	String get testConnection => 'Test Connection';

	/// en: 'Test connection success'
	String get testConnectionSuccess => 'Test connection success';

	/// en: 'Test connection failed'
	String get testConnectionFailed => 'Test connection failed';

	/// en: 'Test connection failed: ${message}'
	String testConnectionFailedWithMessage({required Object message}) => 'Test connection failed: ${message}';

	/// en: 'Translation'
	String get translation => 'Translation';

	/// en: 'Need Verification'
	String get needVerification => 'Need Verification';

	/// en: 'Please test the connection first before enabling AI translation'
	String get needVerificationContent => 'Please test the connection first before enabling AI translation';

	/// en: 'Confirm'
	String get confirm => 'Confirm';

	/// en: 'Disclaimer'
	String get disclaimer => 'Disclaimer';

	/// en: 'Risk Warning'
	String get riskWarning => 'Risk Warning';

	/// en: 'Due to the text being generated by users, it may contain content that violates the content policy of the AI service provider'
	String get dureToRisk1 => 'Due to the text being generated by users, it may contain content that violates the content policy of the AI service provider';

	/// en: 'Inappropriate content may lead to API key suspension or service termination'
	String get dureToRisk2 => 'Inappropriate content may lead to API key suspension or service termination';

	/// en: 'Operation Suggestion'
	String get operationSuggestion => 'Operation Suggestion';

	/// en: '1. Use before strictly reviewing the content to be translated'
	String get operationSuggestion1 => '1. Use before strictly reviewing the content to be translated';

	/// en: '2. Avoid translating content involving violence, adult content, etc.'
	String get operationSuggestion2 => '2. Avoid translating content involving violence, adult content, etc.';

	/// en: 'API Config'
	String get apiConfig => 'API Config';

	/// en: 'Modify configuration will automatically close AI translation, need to test again after opening'
	String get modifyConfigWillAutoCloseAITranslation => 'Modify configuration will automatically close AI translation, need to test again after opening';

	/// en: 'API Address'
	String get apiAddress => 'API Address';

	/// en: 'Model Name'
	String get modelName => 'Model Name';

	/// en: 'For example: gpt-4-turbo'
	String get modelNameHintText => 'For example: gpt-4-turbo';

	/// en: 'Max Tokens'
	String get maxTokens => 'Max Tokens';

	/// en: 'For example: 1024'
	String get maxTokensHintText => 'For example: 1024';

	/// en: 'Temperature'
	String get temperature => 'Temperature';

	/// en: '0.0-2.0'
	String get temperatureHintText => '0.0-2.0';

	/// en: 'Click test button to verify API connection validity'
	String get clickTestButtonToVerifyAPIConnection => 'Click test button to verify API connection validity';

	/// en: 'Request Preview'
	String get requestPreview => 'Request Preview';

	/// en: 'Enable AI'
	String get enableAITranslation => 'Enable AI';

	/// en: 'Enabled'
	String get enabled => 'Enabled';

	/// en: 'Disabled'
	String get disabled => 'Disabled';

	/// en: 'Testing...'
	String get testing => 'Testing...';

	/// en: 'Test Now'
	String get testNow => 'Test Now';

	/// en: 'Connection Status'
	String get connectionStatus => 'Connection Status';

	/// en: 'Success'
	String get success => 'Success';

	/// en: 'Failed'
	String get failed => 'Failed';

	/// en: 'Information'
	String get information => 'Information';

	/// en: 'View Raw Response'
	String get viewRawResponse => 'View Raw Response';

	/// en: 'Please check input parameters format'
	String get pleaseCheckInputParametersFormat => 'Please check input parameters format';

	/// en: 'Please fill in API address, model name and key'
	String get pleaseFillInAPIAddressModelNameAndKey => 'Please fill in API address, model name and key';

	/// en: 'Please fill in valid configuration parameters'
	String get pleaseFillInValidConfigurationParameters => 'Please fill in valid configuration parameters';

	/// en: 'Please complete connection test'
	String get pleaseCompleteConnectionTest => 'Please complete connection test';

	/// en: 'Not Configured'
	String get notConfigured => 'Not Configured';

	/// en: 'API Endpoint'
	String get apiEndpoint => 'API Endpoint';

	/// en: 'Configured Key'
	String get configuredKey => 'Configured Key';

	/// en: 'Not Configured Key'
	String get notConfiguredKey => 'Not Configured Key';

	/// en: 'Authentication Status'
	String get authenticationStatus => 'Authentication Status';

	/// en: 'This field cannot be empty'
	String get thisFieldCannotBeEmpty => 'This field cannot be empty';

	/// en: 'API Key'
	String get apiKey => 'API Key';

	/// en: 'API key cannot be empty'
	String get apiKeyCannotBeEmpty => 'API key cannot be empty';

	/// en: 'Please enter valid number'
	String get pleaseEnterValidNumber => 'Please enter valid number';

	/// en: 'Range'
	String get range => 'Range';

	/// en: 'Must be greater than'
	String get mustBeGreaterThan => 'Must be greater than';

	/// en: 'Invalid API response'
	String get invalidAPIResponse => 'Invalid API response';

	/// en: 'Connection failed: ${message}'
	String connectionFailedForMessage({required Object message}) => 'Connection failed: ${message}';

	/// en: 'AI translation is not enabled, please enable it in settings'
	String get aiTranslationNotEnabledHint => 'AI translation is not enabled, please enable it in settings';

	/// en: 'Go to Settings'
	String get goToSettings => 'Go to Settings';

	/// en: 'Disable AI Translation'
	String get disableAITranslation => 'Disable AI Translation';

	/// en: 'Current Value'
	String get currentValue => 'Current Value';

	/// en: 'Configure Translation Strategy'
	String get configureTranslationStrategy => 'Configure Translation Strategy';

	/// en: 'Advanced Settings'
	String get advancedSettings => 'Advanced Settings';

	/// en: 'Translation Prompt'
	String get translationPrompt => 'Translation Prompt';

	/// en: 'Please enter translation prompt, use [TL] as the placeholder for the target language'
	String get promptHint => 'Please enter translation prompt, use [TL] as the placeholder for the target language';

	/// en: 'The prompt must contain [TL] as the placeholder for the target language'
	String get promptHelperText => 'The prompt must contain [TL] as the placeholder for the target language';

	/// en: 'The prompt must contain [TL] placeholder'
	String get promptMustContainTargetLang => 'The prompt must contain [TL] placeholder';

	/// en: 'AI translation will be disabled'
	String get aiTranslationWillBeDisabled => 'AI translation will be disabled';

	/// en: 'Due to the change of basic configuration, AI translation will be disabled'
	String get aiTranslationWillBeDisabledDueToConfigChange => 'Due to the change of basic configuration, AI translation will be disabled';

	/// en: 'Due to the change of translation prompt, AI translation will be disabled'
	String get aiTranslationWillBeDisabledDueToPromptChange => 'Due to the change of translation prompt, AI translation will be disabled';

	/// en: 'Due to the change of parameter configuration, AI translation will be disabled'
	String get aiTranslationWillBeDisabledDueToParamChange => 'Due to the change of parameter configuration, AI translation will be disabled';

	/// en: 'Currently only supports OpenAI-compatible API format (application/json request body)'
	String get onlyOpenAIAPISupported => 'Currently only supports OpenAI-compatible API format (application/json request body)';

	/// en: 'Streaming Translation'
	String get streamingTranslation => 'Streaming Translation';

	/// en: 'Streaming Translation Supported'
	String get streamingTranslationSupported => 'Streaming Translation Supported';

	/// en: 'Streaming Translation Not Supported'
	String get streamingTranslationNotSupported => 'Streaming Translation Not Supported';

	/// en: 'Streaming translation can display results in real-time during the translation process, providing a better user experience'
	String get streamingTranslationDescription => 'Streaming translation can display results in real-time during the translation process, providing a better user experience';

	/// en: 'Using full URL (ending with #)'
	String get usingFullUrlWithHash => 'Using full URL (ending with #)';

	/// en: 'When ending with #, it will be used as the actual request address'
	String get baseUrlInputHelperText => 'When ending with #, it will be used as the actual request address';

	/// en: 'Current actual URL: ${url}'
	String currentActualUrl({required Object url}) => 'Current actual URL: ${url}';

	/// en: 'URL ending with # will be used directly without adding any suffix'
	String get urlEndingWithHashTip => 'URL ending with # will be used directly without adding any suffix';

	/// en: 'Note: This feature requires API service support for streaming transmission, some models may not support it'
	String get streamingTranslationWarning => 'Note: This feature requires API service support for streaming transmission, some models may not support it';
}

// Path: mediaPlayer
class TranslationsMediaPlayerEn {
	TranslationsMediaPlayerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Video Player Error'
	String get videoPlayerError => 'Video Player Error';

	/// en: 'Video Load Failed'
	String get videoLoadFailed => 'Video Load Failed';

	/// en: 'Video Codec Not Supported'
	String get videoCodecNotSupported => 'Video Codec Not Supported';

	/// en: 'Network Connection Issue'
	String get networkConnectionIssue => 'Network Connection Issue';

	/// en: 'Insufficient Permission'
	String get insufficientPermission => 'Insufficient Permission';

	/// en: 'Unsupported Video Format'
	String get unsupportedVideoFormat => 'Unsupported Video Format';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'External Player'
	String get externalPlayer => 'External Player';

	/// en: 'Detailed Error Information'
	String get detailedErrorInfo => 'Detailed Error Information';

	/// en: 'Format'
	String get format => 'Format';

	/// en: 'Suggestion'
	String get suggestion => 'Suggestion';

	/// en: 'Android devices have limited support for WEBM format. It is recommended to use an external player or download a player app that supports WEBM'
	String get androidWebmCompatibilityIssue => 'Android devices have limited support for WEBM format. It is recommended to use an external player or download a player app that supports WEBM';

	/// en: 'Current device does not support the codec for this video format'
	String get currentDeviceCodecNotSupported => 'Current device does not support the codec for this video format';

	/// en: 'Please check your network connection and try again'
	String get checkNetworkConnection => 'Please check your network connection and try again';

	/// en: 'The app may lack necessary media playback permissions'
	String get appMayLackMediaPermission => 'The app may lack necessary media playback permissions';

	/// en: 'Please try using other video players'
	String get tryOtherVideoPlayer => 'Please try using other video players';

	/// en: 'VIDEO'
	String get video => 'VIDEO';

	/// en: 'Image Load Failed'
	String get imageLoadFailed => 'Image Load Failed';

	/// en: 'Unsupported Image Format'
	String get unsupportedImageFormat => 'Unsupported Image Format';

	/// en: 'Please try using other viewers'
	String get tryOtherViewer => 'Please try using other viewers';
}

// Path: linkInputDialog
class TranslationsLinkInputDialogEn {
	TranslationsLinkInputDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Input Link'
	String get title => 'Input Link';

	/// en: 'Support intelligently identify multiple ${webName} links and quickly jump to the corresponding page in the app (separate links from other text with spaces)'
	String supportedLinksHint({required Object webName}) => 'Support intelligently identify multiple ${webName} links and quickly jump to the corresponding page in the app (separate links from other text with spaces)';

	/// en: 'Please enter ${webName} link'
	String inputHint({required Object webName}) => 'Please enter ${webName} link';

	/// en: 'Please enter link'
	String get validatorEmptyLink => 'Please enter link';

	/// en: 'No valid ${webName} link detected'
	String validatorNoIwaraLink({required Object webName}) => 'No valid ${webName} link detected';

	/// en: 'Multiple links detected, please select one:'
	String get multipleLinksDetected => 'Multiple links detected, please select one:';

	/// en: 'Not a valid ${webName} link'
	String notIwaraLink({required Object webName}) => 'Not a valid ${webName} link';

	/// en: 'Link parsing error: ${error}'
	String linkParseError({required Object error}) => 'Link parsing error: ${error}';

	/// en: 'Unsupported Link'
	String get unsupportedLinkDialogTitle => 'Unsupported Link';

	/// en: 'This link type cannot be opened directly in the app and needs to be accessed using an external browser. Do you want to open this link in a browser?'
	String get unsupportedLinkDialogContent => 'This link type cannot be opened directly in the app and needs to be accessed using an external browser.\n\nDo you want to open this link in a browser?';

	/// en: 'Open in Browser'
	String get openInBrowser => 'Open in Browser';

	/// en: 'Confirm Open Browser'
	String get confirmOpenBrowserDialogTitle => 'Confirm Open Browser';

	/// en: 'The following link is about to be opened in an external browser:'
	String get confirmOpenBrowserDialogContent => 'The following link is about to be opened in an external browser:';

	/// en: 'Are you sure you want to continue?'
	String get confirmContinueBrowserOpen => 'Are you sure you want to continue?';

	/// en: 'Failed to open link'
	String get browserOpenFailed => 'Failed to open link';

	/// en: 'Unsupported Link'
	String get unsupportedLink => 'Unsupported Link';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Open in Browser'
	String get confirm => 'Open in Browser';
}

// Path: log
class TranslationsLogEn {
	TranslationsLogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Log Management'
	String get logManagement => 'Log Management';

	/// en: 'Enable Log Persistence'
	String get enableLogPersistence => 'Enable Log Persistence';

	/// en: 'Save logs to the database for analysis'
	String get enableLogPersistenceDesc => 'Save logs to the database for analysis';

	/// en: 'Log Database Size Limit'
	String get logDatabaseSizeLimit => 'Log Database Size Limit';

	/// en: 'Current: ${size}'
	String logDatabaseSizeLimitDesc({required Object size}) => 'Current: ${size}';

	/// en: 'Export Current Logs'
	String get exportCurrentLogs => 'Export Current Logs';

	/// en: 'Export the current application logs to help developers diagnose problems'
	String get exportCurrentLogsDesc => 'Export the current application logs to help developers diagnose problems';

	/// en: 'Export History Logs'
	String get exportHistoryLogs => 'Export History Logs';

	/// en: 'Export logs within a specified date range'
	String get exportHistoryLogsDesc => 'Export logs within a specified date range';

	/// en: 'Export Merged Logs'
	String get exportMergedLogs => 'Export Merged Logs';

	/// en: 'Export merged logs within a specified date range'
	String get exportMergedLogsDesc => 'Export merged logs within a specified date range';

	/// en: 'Show Log Stats'
	String get showLogStats => 'Show Log Stats';

	/// en: 'Log export success'
	String get logExportSuccess => 'Log export success';

	/// en: 'Log export failed: ${error}'
	String logExportFailed({required Object error}) => 'Log export failed: ${error}';

	/// en: 'View statistics of various types of logs'
	String get showLogStatsDesc => 'View statistics of various types of logs';

	/// en: 'Failed to get log statistics: ${error}'
	String logExtractFailed({required Object error}) => 'Failed to get log statistics: ${error}';

	/// en: 'Clear All Logs'
	String get clearAllLogs => 'Clear All Logs';

	/// en: 'Clear all log data'
	String get clearAllLogsDesc => 'Clear all log data';

	/// en: 'Confirm Clear'
	String get confirmClearAllLogs => 'Confirm Clear';

	/// en: 'Are you sure you want to clear all log data? This operation cannot be undone.'
	String get confirmClearAllLogsDesc => 'Are you sure you want to clear all log data? This operation cannot be undone.';

	/// en: 'Log cleared successfully'
	String get clearAllLogsSuccess => 'Log cleared successfully';

	/// en: 'Failed to clear logs: ${error}'
	String clearAllLogsFailed({required Object error}) => 'Failed to clear logs: ${error}';

	/// en: 'Unable to get log size information'
	String get unableToGetLogSizeInfo => 'Unable to get log size information';

	/// en: 'Current Log Size:'
	String get currentLogSize => 'Current Log Size:';

	/// en: 'Log Count:'
	String get logCount => 'Log Count:';

	/// en: 'logs'
	String get logCountUnit => 'logs';

	/// en: 'Log Size Limit:'
	String get logSizeLimit => 'Log Size Limit:';

	/// en: 'Usage Rate:'
	String get usageRate => 'Usage Rate:';

	/// en: 'Exceed Limit'
	String get exceedLimit => 'Exceed Limit';

	/// en: 'Remaining'
	String get remaining => 'Remaining';

	/// en: 'Current log size exceeded, please clean old logs or increase log size limit'
	String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Current log size exceeded, please clean old logs or increase log size limit';

	/// en: 'Current log size almost exceeded, please clean old logs'
	String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Current log size almost exceeded, please clean old logs';

	/// en: 'Cleaning old logs...'
	String get cleaningOldLogs => 'Cleaning old logs...';

	/// en: 'Log cleaning completed'
	String get logCleaningCompleted => 'Log cleaning completed';

	/// en: 'Log cleaning process may not be completed'
	String get logCleaningProcessMayNotBeCompleted => 'Log cleaning process may not be completed';

	/// en: 'Clean exceeded logs'
	String get cleanExceededLogs => 'Clean exceeded logs';

	/// en: 'No logs to export'
	String get noLogsToExport => 'No logs to export';

	/// en: 'Exporting logs...'
	String get exportingLogs => 'Exporting logs...';

	/// en: 'No history logs to export, please try using the app for a while first'
	String get noHistoryLogsToExport => 'No history logs to export, please try using the app for a while first';

	/// en: 'Select Log Date'
	String get selectLogDate => 'Select Log Date';

	/// en: 'Today'
	String get today => 'Today';

	/// en: 'Select Merge Range'
	String get selectMergeRange => 'Select Merge Range';

	/// en: 'Please select the log time range to merge'
	String get selectMergeRangeHint => 'Please select the log time range to merge';

	/// en: 'Recent ${days} days'
	String selectMergeRangeDays({required Object days}) => 'Recent ${days} days';

	/// en: 'Log Stats'
	String get logStats => 'Log Stats';

	/// en: 'Today Logs: ${count} logs'
	String todayLogs({required Object count}) => 'Today Logs: ${count} logs';

	/// en: 'Recent 7 Days Logs: ${count} logs'
	String recent7DaysLogs({required Object count}) => 'Recent 7 Days Logs: ${count} logs';

	/// en: 'Total Logs: ${count} logs'
	String totalLogs({required Object count}) => 'Total Logs: ${count} logs';

	/// en: 'Set Log Database Size Limit'
	String get setLogDatabaseSizeLimit => 'Set Log Database Size Limit';

	/// en: 'Current Log Size: ${size}'
	String currentLogSizeWithSize({required Object size}) => 'Current Log Size: ${size}';

	/// en: 'Warning'
	String get warning => 'Warning';

	/// en: 'New size limit: ${size}'
	String newSizeLimit({required Object size}) => 'New size limit: ${size}';

	/// en: 'Confirm to continue'
	String get confirmToContinue => 'Confirm to continue';

	/// en: 'Log size limit set to ${size}'
	String logSizeLimitSetSuccess({required Object size}) => 'Log size limit set to ${size}';
}

// Path: common.pagination
class TranslationsCommonPaginationEn {
	TranslationsCommonPaginationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Total ${num} items'
	String totalItems({required Object num}) => 'Total ${num} items';

	/// en: 'Jump to page'
	String get jumpToPage => 'Jump to page';

	/// en: 'Please enter page number (1-${max})'
	String pleaseEnterPageNumber({required Object max}) => 'Please enter page number (1-${max})';

	/// en: 'Page number'
	String get pageNumber => 'Page number';

	/// en: 'Jump'
	String get jump => 'Jump';

	/// en: 'Please enter a valid page number (1-${max})'
	String invalidPageNumber({required Object max}) => 'Please enter a valid page number (1-${max})';

	/// en: 'Please enter a valid page number'
	String get invalidInput => 'Please enter a valid page number';

	/// en: 'Waterfall'
	String get waterfall => 'Waterfall';

	/// en: 'Pagination'
	String get pagination => 'Pagination';
}

// Path: errors.network
class TranslationsErrorsNetworkEn {
	TranslationsErrorsNetworkEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network error - '
	String get basicPrefix => 'Network error - ';

	/// en: 'Failed to connect to server'
	String get failedToConnectToServer => 'Failed to connect to server';

	/// en: 'Server not available'
	String get serverNotAvailable => 'Server not available';

	/// en: 'Request timeout'
	String get requestTimeout => 'Request timeout';

	/// en: 'Unexpected error'
	String get unexpectedError => 'Unexpected error';

	/// en: 'Invalid response'
	String get invalidResponse => 'Invalid response';

	/// en: 'Invalid request'
	String get invalidRequest => 'Invalid request';

	/// en: 'Invalid URL'
	String get invalidUrl => 'Invalid URL';

	/// en: 'Invalid method'
	String get invalidMethod => 'Invalid method';

	/// en: 'Invalid header'
	String get invalidHeader => 'Invalid header';

	/// en: 'Invalid body'
	String get invalidBody => 'Invalid body';

	/// en: 'Invalid status code'
	String get invalidStatusCode => 'Invalid status code';

	/// en: 'Server error'
	String get serverError => 'Server error';

	/// en: 'Request canceled'
	String get requestCanceled => 'Request canceled';

	/// en: 'Invalid port'
	String get invalidPort => 'Invalid port';

	/// en: 'Proxy port error'
	String get proxyPortError => 'Proxy port error';

	/// en: 'Connection refused'
	String get connectionRefused => 'Connection refused';

	/// en: 'Network unreachable'
	String get networkUnreachable => 'Network unreachable';

	/// en: 'No route to host'
	String get noRouteToHost => 'No route to host';

	/// en: 'Connection failed'
	String get connectionFailed => 'Connection failed';

	/// en: 'SSL connection failed, please check your network settings'
	String get sslConnectionFailed => 'SSL connection failed, please check your network settings';
}

// Path: settings.downloadSettings
class TranslationsSettingsDownloadSettingsEn {
	TranslationsSettingsDownloadSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Download Settings'
	String get downloadSettings => 'Download Settings';

	/// en: 'Storage Permission Status'
	String get storagePermissionStatus => 'Storage Permission Status';

	/// en: 'Access Public Directory Need Storage Permission'
	String get accessPublicDirectoryNeedStoragePermission => 'Access Public Directory Need Storage Permission';

	/// en: 'Checking Permission Status...'
	String get checkingPermissionStatus => 'Checking Permission Status...';

	/// en: 'Storage Permission Granted'
	String get storagePermissionGranted => 'Storage Permission Granted';

	/// en: 'Storage Permission Not Granted'
	String get storagePermissionNotGranted => 'Storage Permission Not Granted';

	/// en: 'Storage Permission Grant Success'
	String get storagePermissionGrantSuccess => 'Storage Permission Grant Success';

	/// en: 'Storage Permission Grant Failed But Some Features May Be Limited'
	String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Storage Permission Grant Failed But Some Features May Be Limited';

	/// en: 'Grant Storage Permission'
	String get grantStoragePermission => 'Grant Storage Permission';

	/// en: 'Custom Download Path'
	String get customDownloadPath => 'Custom Download Path';

	/// en: 'When enabled, you can choose a custom save location for downloaded files'
	String get customDownloadPathDescription => 'When enabled, you can choose a custom save location for downloaded files';

	/// en: '💡 Tip: Selecting public directories (like Downloads folder) requires storage permission, recommend using recommended paths first'
	String get customDownloadPathTip => '💡 Tip: Selecting public directories (like Downloads folder) requires storage permission, recommend using recommended paths first';

	/// en: 'Android Note: Avoid selecting public directories (such as Downloads folder), recommend using app-specific directories to ensure access permissions.'
	String get androidWarning => 'Android Note: Avoid selecting public directories (such as Downloads folder), recommend using app-specific directories to ensure access permissions.';

	/// en: '⚠️ Notice: You selected a public directory, storage permission is required for normal file downloads'
	String get publicDirectoryPermissionTip => '⚠️ Notice: You selected a public directory, storage permission is required for normal file downloads';

	/// en: 'Storage permission required for public directories'
	String get permissionRequiredForPublicDirectory => 'Storage permission required for public directories';

	/// en: 'Current Download Path'
	String get currentDownloadPath => 'Current Download Path';

	/// en: 'Default App Directory'
	String get defaultAppDirectory => 'Default App Directory';

	/// en: 'Granted'
	String get permissionGranted => 'Granted';

	/// en: 'Permission Required'
	String get permissionRequired => 'Permission Required';

	/// en: 'Enable Custom Download Path'
	String get enableCustomDownloadPath => 'Enable Custom Download Path';

	/// en: 'Use app default path when disabled'
	String get disableCustomDownloadPath => 'Use app default path when disabled';

	/// en: 'Custom Download Path'
	String get customDownloadPathLabel => 'Custom Download Path';

	/// en: 'Select download folder'
	String get selectDownloadFolder => 'Select download folder';

	/// en: 'Recommended Path'
	String get recommendedPath => 'Recommended Path';

	/// en: 'Select Folder'
	String get selectFolder => 'Select Folder';

	/// en: 'Filename Template'
	String get filenameTemplate => 'Filename Template';

	/// en: 'Customize the naming rules for downloaded files, supports variable substitution'
	String get filenameTemplateDescription => 'Customize the naming rules for downloaded files, supports variable substitution';

	/// en: 'Video Filename Template'
	String get videoFilenameTemplate => 'Video Filename Template';

	/// en: 'Gallery Folder Template'
	String get galleryFolderTemplate => 'Gallery Folder Template';

	/// en: 'Image Filename Template'
	String get imageFilenameTemplate => 'Image Filename Template';

	/// en: 'Reset to Default'
	String get resetToDefault => 'Reset to Default';

	/// en: 'Supported Variables'
	String get supportedVariables => 'Supported Variables';

	/// en: 'The following variables can be used in filename templates:'
	String get supportedVariablesDescription => 'The following variables can be used in filename templates:';

	/// en: 'Copy Variable'
	String get copyVariable => 'Copy Variable';

	/// en: 'Variable copied'
	String get variableCopied => 'Variable copied';

	/// en: 'Warning: Selected public directory may not be accessible. Recommend selecting app-specific directory.'
	String get warningPublicDirectory => 'Warning: Selected public directory may not be accessible. Recommend selecting app-specific directory.';

	/// en: 'Download path updated'
	String get downloadPathUpdated => 'Download path updated';

	/// en: 'Failed to select path'
	String get selectPathFailed => 'Failed to select path';

	/// en: 'Set to recommended path'
	String get recommendedPathSet => 'Set to recommended path';

	/// en: 'Failed to set recommended path'
	String get setRecommendedPathFailed => 'Failed to set recommended path';

	/// en: 'Reset to default template'
	String get templateResetToDefault => 'Reset to default template';

	/// en: 'Functional Test'
	String get functionalTest => 'Functional Test';

	/// en: 'Testing...'
	String get testInProgress => 'Testing...';

	/// en: 'Run Test'
	String get runTest => 'Run Test';

	/// en: 'Test if download path and permission configuration work properly'
	String get testDownloadPathAndPermissions => 'Test if download path and permission configuration work properly';

	/// en: 'Test Results'
	String get testResults => 'Test Results';

	/// en: 'Test completed'
	String get testCompleted => 'Test completed';

	/// en: 'items passed'
	String get testPassed => 'items passed';

	/// en: 'Test failed'
	String get testFailed => 'Test failed';

	/// en: 'Storage Permission Check'
	String get testStoragePermissionCheck => 'Storage Permission Check';

	/// en: 'Storage permission granted'
	String get testStoragePermissionGranted => 'Storage permission granted';

	/// en: 'Storage permission missing, some features may be limited'
	String get testStoragePermissionMissing => 'Storage permission missing, some features may be limited';

	/// en: 'Permission check failed'
	String get testPermissionCheckFailed => 'Permission check failed';

	/// en: 'Download Path Validation'
	String get testDownloadPathValidation => 'Download Path Validation';

	/// en: 'Path validation failed'
	String get testPathValidationFailed => 'Path validation failed';

	/// en: 'Filename Template Validation'
	String get testFilenameTemplateValidation => 'Filename Template Validation';

	/// en: 'All templates are valid'
	String get testAllTemplatesValid => 'All templates are valid';

	/// en: 'Some templates contain invalid characters'
	String get testSomeTemplatesInvalid => 'Some templates contain invalid characters';

	/// en: 'Template validation failed'
	String get testTemplateValidationFailed => 'Template validation failed';

	/// en: 'Directory Operation Test'
	String get testDirectoryOperationTest => 'Directory Operation Test';

	/// en: 'Directory creation and file writing are normal'
	String get testDirectoryOperationNormal => 'Directory creation and file writing are normal';

	/// en: 'Directory operation failed'
	String get testDirectoryOperationFailed => 'Directory operation failed';

	/// en: 'Video Template'
	String get testVideoTemplate => 'Video Template';

	/// en: 'Gallery Template'
	String get testGalleryTemplate => 'Gallery Template';

	/// en: 'Image Template'
	String get testImageTemplate => 'Image Template';

	/// en: 'Valid'
	String get testValid => 'Valid';

	/// en: 'Invalid'
	String get testInvalid => 'Invalid';

	/// en: 'Success'
	String get testSuccess => 'Success';

	/// en: 'Correct'
	String get testCorrect => 'Correct';

	/// en: 'Error'
	String get testError => 'Error';

	/// en: 'Test Path'
	String get testPath => 'Test Path';

	/// en: 'Base Path'
	String get testBasePath => 'Base Path';

	/// en: 'Directory Creation'
	String get testDirectoryCreation => 'Directory Creation';

	/// en: 'File Writing'
	String get testFileWriting => 'File Writing';

	/// en: 'File Content'
	String get testFileContent => 'File Content';

	/// en: 'Checking path status...'
	String get checkingPathStatus => 'Checking path status...';

	/// en: 'Unable to get path status'
	String get unableToGetPathStatus => 'Unable to get path status';

	/// en: 'Note: Actual path differs from selected path'
	String get actualPathDifferentFromSelected => 'Note: Actual path differs from selected path';

	/// en: 'Grant Permission'
	String get grantPermission => 'Grant Permission';

	/// en: 'Fix Issue'
	String get fixIssue => 'Fix Issue';

	/// en: 'Issue fixed'
	String get issueFixed => 'Issue fixed';

	/// en: 'Fix failed, please handle manually'
	String get fixFailed => 'Fix failed, please handle manually';

	/// en: 'Lack storage permission'
	String get lackStoragePermission => 'Lack storage permission';

	/// en: 'Cannot access public directory, need "All files access permission"'
	String get cannotAccessPublicDirectory => 'Cannot access public directory, need "All files access permission"';

	/// en: 'Cannot create directory'
	String get cannotCreateDirectory => 'Cannot create directory';

	/// en: 'Directory not writable'
	String get directoryNotWritable => 'Directory not writable';

	/// en: 'Insufficient available space'
	String get insufficientSpace => 'Insufficient available space';

	/// en: 'Path is valid'
	String get pathValid => 'Path is valid';

	/// en: 'Validation failed'
	String get validationFailed => 'Validation failed';

	/// en: 'Using default app directory'
	String get usingDefaultAppDirectory => 'Using default app directory';

	/// en: 'App Private Directory'
	String get appPrivateDirectory => 'App Private Directory';

	/// en: 'Safe and reliable, no additional permissions required'
	String get appPrivateDirectoryDesc => 'Safe and reliable, no additional permissions required';

	/// en: 'Download Directory'
	String get downloadDirectory => 'Download Directory';

	/// en: 'System default download location, easy to manage'
	String get downloadDirectoryDesc => 'System default download location, easy to manage';

	/// en: 'Movies Directory'
	String get moviesDirectory => 'Movies Directory';

	/// en: 'System movies directory, recognizable by media apps'
	String get moviesDirectoryDesc => 'System movies directory, recognizable by media apps';

	/// en: 'Documents Directory'
	String get documentsDirectory => 'Documents Directory';

	/// en: 'iOS app documents directory'
	String get documentsDirectoryDesc => 'iOS app documents directory';

	/// en: 'Requires storage permission to access'
	String get requiresStoragePermission => 'Requires storage permission to access';

	/// en: 'Recommended Paths'
	String get recommendedPaths => 'Recommended Paths';

	/// en: 'Select a recommended download location'
	String get selectRecommendedDownloadLocation => 'Select a recommended download location';

	/// en: 'No recommended paths available'
	String get noRecommendedPaths => 'No recommended paths available';

	/// en: 'Recommended'
	String get recommended => 'Recommended';

	/// en: 'Requires Permission'
	String get requiresPermission => 'Requires Permission';

	/// en: 'Authorize and Select'
	String get authorizeAndSelect => 'Authorize and Select';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'Permission authorization failed, cannot select this path'
	String get permissionAuthorizationFailed => 'Permission authorization failed, cannot select this path';

	/// en: 'Path validation failed'
	String get pathValidationFailed => 'Path validation failed';

	/// en: 'Download path set to'
	String get downloadPathSetTo => 'Download path set to';

	/// en: 'Failed to set path'
	String get setPathFailed => 'Failed to set path';

	/// en: 'Title'
	String get variableTitle => 'Title';

	/// en: 'Author name'
	String get variableAuthor => 'Author name';

	/// en: 'Author username'
	String get variableUsername => 'Author username';

	/// en: 'Video quality'
	String get variableQuality => 'Video quality';

	/// en: 'Original filename'
	String get variableFilename => 'Original filename';

	/// en: 'Content ID'
	String get variableId => 'Content ID';

	/// en: 'Gallery image count'
	String get variableCount => 'Gallery image count';

	/// en: 'Current date (YYYY-MM-DD)'
	String get variableDate => 'Current date (YYYY-MM-DD)';

	/// en: 'Current time (HH-MM-SS)'
	String get variableTime => 'Current time (HH-MM-SS)';

	/// en: 'Current date time (YYYY-MM-DD_HH-MM-SS)'
	String get variableDatetime => 'Current date time (YYYY-MM-DD_HH-MM-SS)';

	/// en: 'Download Settings'
	String get downloadSettingsTitle => 'Download Settings';

	/// en: 'Configure download path and file naming rules'
	String get downloadSettingsSubtitle => 'Configure download path and file naming rules';

	/// en: 'For example: %title_%quality'
	String get suchAsTitleQuality => 'For example: %title_%quality';

	/// en: 'For example: %title_%id'
	String get suchAsTitleId => 'For example: %title_%id';

	/// en: 'For example: %title_%filename'
	String get suchAsTitleFilename => 'For example: %title_%filename';
}

// Path: oreno3d.sortTypes
class TranslationsOreno3dSortTypesEn {
	TranslationsOreno3dSortTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Hot'
	String get hot => 'Hot';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Latest'
	String get latest => 'Latest';

	/// en: 'Popular'
	String get popularity => 'Popular';
}

// Path: oreno3d.errors
class TranslationsOreno3dErrorsEn {
	TranslationsOreno3dErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Request failed, status code'
	String get requestFailed => 'Request failed, status code';

	/// en: 'Connection timeout, please check network connection'
	String get connectionTimeout => 'Connection timeout, please check network connection';

	/// en: 'Send request timeout'
	String get sendTimeout => 'Send request timeout';

	/// en: 'Receive response timeout'
	String get receiveTimeout => 'Receive response timeout';

	/// en: 'Certificate verification failed'
	String get badCertificate => 'Certificate verification failed';

	/// en: 'Requested resource not found'
	String get resourceNotFound => 'Requested resource not found';

	/// en: 'Access denied, may require authentication or permission'
	String get accessDenied => 'Access denied, may require authentication or permission';

	/// en: 'Internal server error'
	String get serverError => 'Internal server error';

	/// en: 'Service temporarily unavailable'
	String get serviceUnavailable => 'Service temporarily unavailable';

	/// en: 'Request cancelled'
	String get requestCancelled => 'Request cancelled';

	/// en: 'Network connection error, please check network settings'
	String get connectionError => 'Network connection error, please check network settings';

	/// en: 'Network request failed'
	String get networkRequestFailed => 'Network request failed';

	/// en: 'Unknown error occurred while searching videos'
	String get searchVideoError => 'Unknown error occurred while searching videos';

	/// en: 'Unknown error occurred while getting popular videos'
	String get getPopularVideoError => 'Unknown error occurred while getting popular videos';

	/// en: 'Unknown error occurred while getting video details'
	String get getVideoDetailError => 'Unknown error occurred while getting video details';

	/// en: 'Unknown error occurred while getting and parsing video details'
	String get parseVideoDetailError => 'Unknown error occurred while getting and parsing video details';

	/// en: 'Unknown error occurred while downloading file'
	String get downloadFileError => 'Unknown error occurred while downloading file';
}

// Path: oreno3d.loading
class TranslationsOreno3dLoadingEn {
	TranslationsOreno3dLoadingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Getting video information...'
	String get gettingVideoInfo => 'Getting video information...';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: oreno3d.messages
class TranslationsOreno3dMessagesEn {
	TranslationsOreno3dMessagesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Video not found or has been deleted'
	String get videoNotFoundOrDeleted => 'Video not found or has been deleted';

	/// en: 'Unable to get video playback link'
	String get unableToGetVideoPlayLink => 'Unable to get video playback link';

	/// en: 'Failed to get video details'
	String get getVideoDetailFailed => 'Failed to get video details';
}

// Path: videoDetail.skeleton
class TranslationsVideoDetailSkeletonEn {
	TranslationsVideoDetailSkeletonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Fetching video info...'
	String get fetchingVideoInfo => 'Fetching video info...';

	/// en: 'Fetching video sources...'
	String get fetchingVideoSources => 'Fetching video sources...';

	/// en: 'Loading video...'
	String get loadingVideo => 'Loading video...';
}

// Path: forum.errors
class TranslationsForumErrorsEn {
	TranslationsForumErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please select a category'
	String get pleaseSelectCategory => 'Please select a category';

	/// en: 'This thread is locked, cannot reply'
	String get threadLocked => 'This thread is locked, cannot reply';
}

// Path: forum.groups
class TranslationsForumGroupsEn {
	TranslationsForumGroupsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Administration'
	String get administration => 'Administration';

	/// en: 'Global'
	String get global => 'Global';

	/// en: 'Chinese'
	String get chinese => 'Chinese';

	/// en: 'Japanese'
	String get japanese => 'Japanese';

	/// en: 'Korean'
	String get korean => 'Korean';

	/// en: 'Other'
	String get other => 'Other';
}

// Path: forum.leafNames
class TranslationsForumLeafNamesEn {
	TranslationsForumLeafNamesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Announcements'
	String get announcements => 'Announcements';

	/// en: 'Feedback'
	String get feedback => 'Feedback';

	/// en: 'Support'
	String get support => 'Support';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Guides'
	String get guides => 'Guides';

	/// en: 'Questions'
	String get questions => 'Questions';

	/// en: 'Requests'
	String get requests => 'Requests';

	/// en: 'Sharing'
	String get sharing => 'Sharing';

	/// en: 'General'
	String get general_zh => 'General';

	/// en: 'Questions'
	String get questions_zh => 'Questions';

	/// en: 'Requests'
	String get requests_zh => 'Requests';

	/// en: 'Support'
	String get support_zh => 'Support';

	/// en: 'General'
	String get general_ja => 'General';

	/// en: 'Questions'
	String get questions_ja => 'Questions';

	/// en: 'Requests'
	String get requests_ja => 'Requests';

	/// en: 'Support'
	String get support_ja => 'Support';

	/// en: 'Korean'
	String get korean => 'Korean';

	/// en: 'Other'
	String get other => 'Other';
}

// Path: forum.leafDescriptions
class TranslationsForumLeafDescriptionsEn {
	TranslationsForumLeafDescriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Official important notifications and announcements'
	String get announcements => 'Official important notifications and announcements';

	/// en: 'Feedback on the website's features and services'
	String get feedback => 'Feedback on the website\'s features and services';

	/// en: 'Help to resolve website-related issues'
	String get support => 'Help to resolve website-related issues';

	/// en: 'Discuss any topic'
	String get general => 'Discuss any topic';

	/// en: 'Share your experiences and tutorials'
	String get guides => 'Share your experiences and tutorials';

	/// en: 'Raise your inquiries'
	String get questions => 'Raise your inquiries';

	/// en: 'Post your requests'
	String get requests => 'Post your requests';

	/// en: 'Share interesting content'
	String get sharing => 'Share interesting content';

	/// en: 'Discuss any topic'
	String get general_zh => 'Discuss any topic';

	/// en: 'Raise your inquiries'
	String get questions_zh => 'Raise your inquiries';

	/// en: 'Post your requests'
	String get requests_zh => 'Post your requests';

	/// en: 'Help to resolve website-related issues'
	String get support_zh => 'Help to resolve website-related issues';

	/// en: 'Discuss any topic'
	String get general_ja => 'Discuss any topic';

	/// en: 'Raise your inquiries'
	String get questions_ja => 'Raise your inquiries';

	/// en: 'Post your requests'
	String get requests_ja => 'Post your requests';

	/// en: 'Help to resolve website-related issues'
	String get support_ja => 'Help to resolve website-related issues';

	/// en: 'Discussions related to Korean'
	String get korean => 'Discussions related to Korean';

	/// en: 'Other unclassified content'
	String get other => 'Other unclassified content';
}

// Path: notifications.errors
class TranslationsNotificationsErrorsEn {
	TranslationsNotificationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unsupported notification type'
	String get unsupportedNotificationType => 'Unsupported notification type';

	/// en: 'Unknown user'
	String get unknownUser => 'Unknown user';

	/// en: 'Unsupported notification type: ${type}'
	String unsupportedNotificationTypeWithType({required Object type}) => 'Unsupported notification type: ${type}';

	/// en: 'Unknown notification type'
	String get unknownNotificationType => 'Unknown notification type';
}

// Path: conversation.errors
class TranslationsConversationErrorsEn {
	TranslationsConversationErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Please select a user'
	String get pleaseSelectAUser => 'Please select a user';

	/// en: 'Please enter a title'
	String get pleaseEnterATitle => 'Please enter a title';

	/// en: 'Click to select a user'
	String get clickToSelectAUser => 'Click to select a user';

	/// en: 'Load failed, click to retry'
	String get loadFailedClickToRetry => 'Load failed, click to retry';

	/// en: 'Load failed'
	String get loadFailed => 'Load failed';

	/// en: 'Click to retry'
	String get clickToRetry => 'Click to retry';

	/// en: 'No more conversations'
	String get noMoreConversations => 'No more conversations';
}

// Path: splash.errors
class TranslationsSplashErrorsEn {
	TranslationsSplashErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Initialization failed, please restart the app'
	String get initializationFailed => 'Initialization failed, please restart the app';
}

// Path: download.errors
class TranslationsDownloadErrorsEn {
	TranslationsDownloadErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Image model not found'
	String get imageModelNotFound => 'Image model not found';

	/// en: 'Download failed'
	String get downloadFailed => 'Download failed';

	/// en: 'Video info not found'
	String get videoInfoNotFound => 'Video info not found';

	/// en: 'Download task already exists'
	String get downloadTaskAlreadyExists => 'Download task already exists';

	/// en: 'Video already downloaded'
	String get videoAlreadyDownloaded => 'Video already downloaded';

	/// en: 'Add download task failed: ${errorInfo}'
	String downloadFailedForMessage({required Object errorInfo}) => 'Add download task failed: ${errorInfo}';

	/// en: 'User paused download'
	String get userPausedDownload => 'User paused download';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'File system error: ${errorInfo}'
	String fileSystemError({required Object errorInfo}) => 'File system error: ${errorInfo}';

	/// en: 'Unknown error: ${errorInfo}'
	String unknownError({required Object errorInfo}) => 'Unknown error: ${errorInfo}';

	/// en: 'Connection timeout'
	String get connectionTimeout => 'Connection timeout';

	/// en: 'Send timeout'
	String get sendTimeout => 'Send timeout';

	/// en: 'Receive timeout'
	String get receiveTimeout => 'Receive timeout';

	/// en: 'Server error: ${errorInfo}'
	String serverError({required Object errorInfo}) => 'Server error: ${errorInfo}';

	/// en: 'Unknown network error'
	String get unknownNetworkError => 'Unknown network error';

	/// en: 'Download service is closing'
	String get serviceIsClosing => 'Download service is closing';

	/// en: 'Partial content download failed'
	String get partialDownloadFailed => 'Partial content download failed';

	/// en: 'No download task'
	String get noDownloadTask => 'No download task';

	/// en: 'Task not found or data error'
	String get taskNotFoundOrDataError => 'Task not found or data error';

	/// en: 'File not found'
	String get fileNotFound => 'File not found';

	/// en: 'Failed to open folder'
	String get openFolderFailed => 'Failed to open folder';

	/// en: 'Failed to copy download URL'
	String get copyDownloadUrlFailed => 'Failed to copy download URL';

	/// en: 'Failed to open folder: ${message}'
	String openFolderFailedWithMessage({required Object message}) => 'Failed to open folder: ${message}';

	/// en: 'Directory not found'
	String get directoryNotFound => 'Directory not found';

	/// en: 'Copy failed'
	String get copyFailed => 'Copy failed';

	/// en: 'Failed to open file'
	String get openFileFailed => 'Failed to open file';

	/// en: 'Failed to open file: ${message}'
	String openFileFailedWithMessage({required Object message}) => 'Failed to open file: ${message}';

	/// en: 'No download source'
	String get noDownloadSource => 'No download source';

	/// en: 'No download source, please wait for information loading to be completed and try again'
	String get noDownloadSourceNowPleaseWaitInfoLoaded => 'No download source, please wait for information loading to be completed and try again';

	/// en: 'No active download task'
	String get noActiveDownloadTask => 'No active download task';

	/// en: 'No failed download task'
	String get noFailedDownloadTask => 'No failed download task';

	/// en: 'No completed download task'
	String get noCompletedDownloadTask => 'No completed download task';

	/// en: 'Task already completed, do not add again'
	String get taskAlreadyCompletedDoNotAdd => 'Task already completed, do not add again';

	/// en: 'Link expired, trying to get new download link'
	String get linkExpiredTryAgain => 'Link expired, trying to get new download link';

	/// en: 'Link expired, trying to get new download link success'
	String get linkExpiredTryAgainSuccess => 'Link expired, trying to get new download link success';

	/// en: 'Link expired, trying to get new download link failed'
	String get linkExpiredTryAgainFailed => 'Link expired, trying to get new download link failed';

	/// en: 'Task deleted'
	String get taskDeleted => 'Task deleted';

	/// en: 'Unsupported image format: ${format}'
	String unsupportedImageFormat({required Object format}) => 'Unsupported image format: ${format}';

	/// en: 'Failed to delete file, possibly because the file is being used by another process'
	String get deleteFileError => 'Failed to delete file, possibly because the file is being used by another process';

	/// en: 'Failed to delete task'
	String get deleteTaskError => 'Failed to delete task';

	/// en: 'Failed to refresh video task'
	String get canNotRefreshVideoTask => 'Failed to refresh video task';

	/// en: 'Task already processing'
	String get taskAlreadyProcessing => 'Task already processing';

	/// en: 'Task not found'
	String get taskNotFound => 'Task not found';

	/// en: 'Failed to load tasks'
	String get failedToLoadTasks => 'Failed to load tasks';

	/// en: 'Partial download failed: ${message}'
	String partialDownloadFailedWithMessage({required Object message}) => 'Partial download failed: ${message}';

	/// en: 'Unsupported image format: ${extension}, you can try to download it to your device to view it'
	String unsupportedImageFormatWithMessage({required Object extension}) => 'Unsupported image format: ${extension}, you can try to download it to your device to view it';

	/// en: 'Image load failed'
	String get imageLoadFailed => 'Image load failed';

	/// en: 'Please try using other viewers to open'
	String get pleaseTryOtherViewer => 'Please try using other viewers to open';
}

// Path: favorite.errors
class TranslationsFavoriteErrorsEn {
	TranslationsFavoriteErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add failed'
	String get addFailed => 'Add failed';

	/// en: 'Add success'
	String get addSuccess => 'Add success';

	/// en: 'Delete folder failed'
	String get deleteFolderFailed => 'Delete folder failed';

	/// en: 'Delete folder success'
	String get deleteFolderSuccess => 'Delete folder success';

	/// en: 'Folder name cannot be empty'
	String get folderNameCannotBeEmpty => 'Folder name cannot be empty';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'common.appName': return 'Love Iwara';
			case 'common.ok': return 'OK';
			case 'common.cancel': return 'Cancel';
			case 'common.save': return 'Save';
			case 'common.delete': return 'Delete';
			case 'common.visit': return 'Visit';
			case 'common.loading': return 'Loading...';
			case 'common.scrollToTop': return 'Scroll to Top';
			case 'common.privacyHint': return 'Privacy content, not displayed';
			case 'common.latest': return 'Latest';
			case 'common.likesCount': return 'Likes';
			case 'common.viewsCount': return 'Views';
			case 'common.popular': return 'Popular';
			case 'common.trending': return 'Trending';
			case 'common.commentList': return 'Comment List';
			case 'common.sendComment': return 'Send Comment';
			case 'common.send': return 'Send';
			case 'common.retry': return 'Retry';
			case 'common.premium': return 'Premium';
			case 'common.follower': return 'Follower';
			case 'common.friend': return 'Friend';
			case 'common.video': return 'Video';
			case 'common.following': return 'Following';
			case 'common.expand': return 'Expand';
			case 'common.collapse': return 'Collapse';
			case 'common.cancelFriendRequest': return 'Cancel Request';
			case 'common.cancelSpecialFollow': return 'Cancel Special Follow';
			case 'common.addFriend': return 'Add Friend';
			case 'common.removeFriend': return 'Remove Friend';
			case 'common.followed': return 'Followed';
			case 'common.follow': return 'Follow';
			case 'common.unfollow': return 'Unfollow';
			case 'common.specialFollow': return 'Special Follow';
			case 'common.specialFollowed': return 'Special Followed';
			case 'common.gallery': return 'Gallery';
			case 'common.playlist': return 'Playlist';
			case 'common.commentPostedSuccessfully': return 'Comment Posted Successfully';
			case 'common.commentPostedFailed': return 'Comment Posted Failed';
			case 'common.success': return 'Success';
			case 'common.commentDeletedSuccessfully': return 'Comment Deleted Successfully';
			case 'common.commentUpdatedSuccessfully': return 'Comment Updated Successfully';
			case 'common.totalComments': return ({required Object count}) => '${count} Comments';
			case 'common.writeYourCommentHere': return 'Write your comment here...';
			case 'common.tmpNoReplies': return 'No replies yet';
			case 'common.loadMore': return 'Load More';
			case 'common.noMoreDatas': return 'No more data';
			case 'common.selectTranslationLanguage': return 'Select Translation Language';
			case 'common.translate': return 'Translate';
			case 'common.translateFailedPleaseTryAgainLater': return 'Translate failed, please try again later';
			case 'common.translationResult': return 'Translation Result';
			case 'common.justNow': return 'Just Now';
			case 'common.minutesAgo': return ({required Object num}) => '${num} minutes ago';
			case 'common.hoursAgo': return ({required Object num}) => '${num} hours ago';
			case 'common.daysAgo': return ({required Object num}) => '${num} days ago';
			case 'common.editedAt': return ({required Object num}) => '${num} edited';
			case 'common.editComment': return 'Edit Comment';
			case 'common.commentUpdated': return 'Comment Updated';
			case 'common.replyComment': return 'Reply Comment';
			case 'common.reply': return 'Reply';
			case 'common.edit': return 'Edit';
			case 'common.unknownUser': return 'Unknown User';
			case 'common.me': return 'Me';
			case 'common.author': return 'Author';
			case 'common.admin': return 'Admin';
			case 'common.viewReplies': return ({required Object num}) => 'View Replies (${num})';
			case 'common.hideReplies': return 'Hide Replies';
			case 'common.confirmDelete': return 'Confirm Delete';
			case 'common.areYouSureYouWantToDeleteThisItem': return 'Are you sure you want to delete this item?';
			case 'common.tmpNoComments': return 'No comments yet';
			case 'common.refresh': return 'Refresh';
			case 'common.back': return 'Back';
			case 'common.tips': return 'Tips';
			case 'common.linkIsEmpty': return 'Link is empty';
			case 'common.linkCopiedToClipboard': return 'Link copied to clipboard';
			case 'common.imageCopiedToClipboard': return 'Image copied to clipboard';
			case 'common.copyImageFailed': return 'Copy image failed';
			case 'common.mobileSaveImageIsUnderDevelopment': return 'Mobile save image is under development';
			case 'common.imageSavedTo': return 'Image saved to';
			case 'common.saveImageFailed': return 'Save image failed';
			case 'common.close': return 'Close';
			case 'common.more': return 'More';
			case 'common.moreFeaturesToBeDeveloped': return 'More features to be developed';
			case 'common.all': return 'All';
			case 'common.selectedRecords': return ({required Object num}) => 'Selected ${num} records';
			case 'common.cancelSelectAll': return 'Cancel Select All';
			case 'common.selectAll': return 'Select All';
			case 'common.exitEditMode': return 'Exit Edit Mode';
			case 'common.areYouSureYouWantToDeleteSelectedItems': return ({required Object num}) => 'Are you sure you want to delete selected ${num} items?';
			case 'common.searchHistoryRecords': return 'Search History Records...';
			case 'common.settings': return 'Settings';
			case 'common.subscriptions': return 'Subscriptions';
			case 'common.videoCount': return ({required Object num}) => '${num} videos';
			case 'common.share': return 'Share';
			case 'common.areYouSureYouWantToShareThisPlaylist': return 'Are you sure you want to share this playlist?';
			case 'common.editTitle': return 'Edit Title';
			case 'common.editMode': return 'Edit Mode';
			case 'common.pleaseEnterNewTitle': return 'Please enter new title';
			case 'common.createPlayList': return 'Create Play List';
			case 'common.create': return 'Create';
			case 'common.checkNetworkSettings': return 'Check Network Settings';
			case 'common.general': return 'General';
			case 'common.r18': return 'R18';
			case 'common.sensitive': return 'Sensitive';
			case 'common.year': return 'Year';
			case 'common.month': return 'Month';
			case 'common.tag': return 'Tag';
			case 'common.private': return 'Private';
			case 'common.noTitle': return 'No Title';
			case 'common.search': return 'Search';
			case 'common.noContent': return 'No content';
			case 'common.recording': return 'Recording';
			case 'common.paused': return 'Paused';
			case 'common.clear': return 'Clear';
			case 'common.user': return 'User';
			case 'common.post': return 'Post';
			case 'common.seconds': return 'Seconds';
			case 'common.comingSoon': return 'Coming Soon';
			case 'common.confirm': return 'Confirm';
			case 'common.hour': return 'Hour';
			case 'common.minute': return 'Minute';
			case 'common.clickToRefresh': return 'Click to Refresh';
			case 'common.history': return 'History';
			case 'common.favorites': return 'Favorites';
			case 'common.friends': return 'Friends';
			case 'common.playList': return 'Play List';
			case 'common.checkLicense': return 'Check License';
			case 'common.logout': return 'Logout';
			case 'common.fensi': return 'Fans';
			case 'common.accept': return 'Accept';
			case 'common.reject': return 'Reject';
			case 'common.clearAllHistory': return 'Clear All History';
			case 'common.clearAllHistoryConfirm': return 'Are you sure you want to clear all history?';
			case 'common.followingList': return 'Following List';
			case 'common.followersList': return 'Followers List';
			case 'common.follows': return 'Follows';
			case 'common.fans': return 'Fans';
			case 'common.followsAndFans': return 'Follows and Fans';
			case 'common.numViews': return 'Views';
			case 'common.updatedAt': return 'Updated At';
			case 'common.publishedAt': return 'Published At';
			case 'common.externalVideo': return 'External Video';
			case 'common.originalText': return 'Original Text';
			case 'common.showOriginalText': return 'Show Original Text';
			case 'common.showProcessedText': return 'Show Processed Text';
			case 'common.preview': return 'Preview';
			case 'common.rules': return 'Rules';
			case 'common.agree': return 'Agree';
			case 'common.disagree': return 'Disagree';
			case 'common.agreeToRules': return 'Agree to Rules';
			case 'common.createPost': return 'Create Post';
			case 'common.title': return 'Title';
			case 'common.enterTitle': return 'Please enter title';
			case 'common.content': return 'Content';
			case 'common.enterContent': return 'Please enter content';
			case 'common.writeYourContentHere': return 'Please enter content...';
			case 'common.tagBlacklist': return 'Tag Blacklist';
			case 'common.noData': return 'No data';
			case 'common.tagLimit': return 'Tag Limit';
			case 'common.enableFloatingButtons': return 'Enable Floating Buttons';
			case 'common.disableFloatingButtons': return 'Disable Floating Buttons';
			case 'common.enabledFloatingButtons': return 'Enabled Floating Buttons';
			case 'common.disabledFloatingButtons': return 'Disabled Floating Buttons';
			case 'common.pendingCommentCount': return 'Pending Comment Count';
			case 'common.joined': return ({required Object str}) => 'Joined at ${str}';
			case 'common.download': return 'Download';
			case 'common.selectQuality': return 'Select Quality';
			case 'common.selectDateRange': return 'Select Date Range';
			case 'common.selectDateRangeHint': return 'Select date range, default is recent 30 days';
			case 'common.clearDateRange': return 'Clear Date Range';
			case 'common.followSuccessClickAgainToSpecialFollow': return 'Followed successfully, click again to special follow';
			case 'common.exitConfirmTip': return 'Are you sure you want to exit?';
			case 'common.error': return 'Error';
			case 'common.taskRunning': return 'A task is already running, please wait.';
			case 'common.operationCancelled': return 'Operation cancelled.';
			case 'common.unsavedChanges': return 'You have unsaved changes';
			case 'common.specialFollowsManagementTip': return 'Drag to reorder • Swipe left to remove';
			case 'common.specialFollowsManagement': return 'Special Follows Management';
			case 'common.pagination.totalItems': return ({required Object num}) => 'Total ${num} items';
			case 'common.pagination.jumpToPage': return 'Jump to page';
			case 'common.pagination.pleaseEnterPageNumber': return ({required Object max}) => 'Please enter page number (1-${max})';
			case 'common.pagination.pageNumber': return 'Page number';
			case 'common.pagination.jump': return 'Jump';
			case 'common.pagination.invalidPageNumber': return ({required Object max}) => 'Please enter a valid page number (1-${max})';
			case 'common.pagination.invalidInput': return 'Please enter a valid page number';
			case 'common.pagination.waterfall': return 'Waterfall';
			case 'common.pagination.pagination': return 'Pagination';
			case 'common.notice': return 'Notice';
			case 'common.detail': return 'Detail';
			case 'common.parseExceptionDestopHint': return ' - Desktop users can configure proxy in settings';
			case 'common.iwaraTags': return 'Iwara Tags';
			case 'common.likeThisVideo': return 'Like This Video';
			case 'common.operation': return 'Operation';
			case 'common.replies': return 'Replies';
			case 'auth.login': return 'Login';
			case 'auth.logout': return 'Logout';
			case 'auth.email': return 'Email';
			case 'auth.password': return 'Password';
			case 'auth.loginOrRegister': return 'Login / Register';
			case 'auth.register': return 'Register';
			case 'auth.pleaseEnterEmail': return 'Please enter email';
			case 'auth.pleaseEnterPassword': return 'Please enter password';
			case 'auth.passwordMustBeAtLeast6Characters': return 'Password must be at least 6 characters';
			case 'auth.pleaseEnterCaptcha': return 'Please enter captcha';
			case 'auth.captcha': return 'Captcha';
			case 'auth.refreshCaptcha': return 'Refresh Captcha';
			case 'auth.captchaNotLoaded': return 'Captcha not loaded';
			case 'auth.loginSuccess': return 'Login Success';
			case 'auth.emailVerificationSent': return 'Email verification sent';
			case 'auth.notLoggedIn': return 'Not Logged In';
			case 'auth.clickToLogin': return 'Click to Login';
			case 'auth.logoutConfirmation': return 'Are you sure you want to logout?';
			case 'auth.logoutSuccess': return 'Logout Success';
			case 'auth.logoutFailed': return 'Logout Failed';
			case 'auth.usernameOrEmail': return 'Username or Email';
			case 'auth.pleaseEnterUsernameOrEmail': return 'Please enter username or email';
			case 'auth.rememberMe': return 'Remember Username and Password';
			case 'errors.error': return 'Error';
			case 'errors.required': return 'This field is required';
			case 'errors.invalidEmail': return 'Invalid email address';
			case 'errors.networkError': return 'Network error, please try again';
			case 'errors.errorWhileFetching': return 'Error while fetching';
			case 'errors.commentCanNotBeEmpty': return 'Comment content cannot be empty';
			case 'errors.errorWhileFetchingReplies': return 'Error while fetching replies, please check network connection';
			case 'errors.canNotFindCommentController': return 'Can not find comment controller';
			case 'errors.errorWhileLoadingGallery': return 'Error while loading gallery';
			case 'errors.howCouldThereBeNoDataItCantBePossible': return 'How could there be no data? It can\'t be possible :<';
			case 'errors.unsupportedImageFormat': return ({required Object str}) => 'Unsupported image format: ${str}';
			case 'errors.invalidGalleryId': return 'Invalid gallery ID';
			case 'errors.translationFailedPleaseTryAgainLater': return 'Translation failed, please try again later';
			case 'errors.errorOccurred': return 'An error occurred, please try again later.';
			case 'errors.errorOccurredWhileProcessingRequest': return 'Error occurred while processing request';
			case 'errors.errorWhileFetchingDatas': return 'Error while fetching datas, please try again later';
			case 'errors.serviceNotInitialized': return 'Service not initialized';
			case 'errors.unknownType': return 'Unknown type';
			case 'errors.errorWhileOpeningLink': return ({required Object link}) => 'Error while opening link: ${link}';
			case 'errors.invalidUrl': return 'Invalid URL';
			case 'errors.failedToOperate': return 'Failed to operate';
			case 'errors.permissionDenied': return 'Permission Denied';
			case 'errors.youDoNotHavePermissionToAccessThisResource': return 'You do not have permission to access this resource';
			case 'errors.loginFailed': return 'Login Failed';
			case 'errors.unknownError': return 'Unknown Error';
			case 'errors.sessionExpired': return 'Session Expired';
			case 'errors.failedToFetchCaptcha': return 'Failed to fetch captcha';
			case 'errors.emailAlreadyExists': return 'Email already exists';
			case 'errors.invalidCaptcha': return 'Invalid Captcha';
			case 'errors.registerFailed': return 'Register Failed';
			case 'errors.failedToFetchComments': return 'Failed to fetch comments';
			case 'errors.failedToFetchImageDetail': return 'Failed to fetch image detail';
			case 'errors.failedToFetchImageList': return 'Failed to fetch image list';
			case 'errors.failedToFetchData': return 'Failed to fetch data';
			case 'errors.invalidParameter': return 'Invalid parameter';
			case 'errors.pleaseLoginFirst': return 'Please login first';
			case 'errors.errorWhileLoadingPost': return 'Error while loading post';
			case 'errors.errorWhileLoadingPostDetail': return 'Error while loading post detail';
			case 'errors.invalidPostId': return 'Invalid post ID';
			case 'errors.forceUpdateNotPermittedToGoBack': return 'Currently in force update state, cannot go back';
			case 'errors.pleaseLoginAgain': return 'Please login again';
			case 'errors.invalidLogin': return 'Invalid login, Please check your email and password';
			case 'errors.tooManyRequests': return 'Too many requests, please try again later';
			case 'errors.exceedsMaxLength': return ({required Object max}) => 'Exceeds max length: ${max}';
			case 'errors.contentCanNotBeEmpty': return 'Content cannot be empty';
			case 'errors.titleCanNotBeEmpty': return 'Title cannot be empty';
			case 'errors.tooManyRequestsPleaseTryAgainLaterText': return 'Too many requests, please try again later, remaining';
			case 'errors.remainingHours': return ({required Object num}) => '${num} hours';
			case 'errors.remainingMinutes': return ({required Object num}) => '${num} minutes';
			case 'errors.remainingSeconds': return ({required Object num}) => '${num} seconds';
			case 'errors.tagLimitExceeded': return ({required Object limit}) => 'Tag limit exceeded, limit: ${limit}';
			case 'errors.failedToRefresh': return 'Failed to refresh';
			case 'errors.noPermission': return 'No permission';
			case 'errors.resourceNotFound': return 'Resource not found';
			case 'errors.failedToSaveCredentials': return 'Failed to save login credentials';
			case 'errors.failedToLoadSavedCredentials': return 'Failed to load saved credentials';
			case 'errors.specialFollowLimitReached': return ({required Object cnt}) => 'Special follow limit exceeded, limit: ${cnt}, please adjust in the follow list page';
			case 'errors.notFound': return 'Content not found or has been deleted';
			case 'errors.network.basicPrefix': return 'Network error - ';
			case 'errors.network.failedToConnectToServer': return 'Failed to connect to server';
			case 'errors.network.serverNotAvailable': return 'Server not available';
			case 'errors.network.requestTimeout': return 'Request timeout';
			case 'errors.network.unexpectedError': return 'Unexpected error';
			case 'errors.network.invalidResponse': return 'Invalid response';
			case 'errors.network.invalidRequest': return 'Invalid request';
			case 'errors.network.invalidUrl': return 'Invalid URL';
			case 'errors.network.invalidMethod': return 'Invalid method';
			case 'errors.network.invalidHeader': return 'Invalid header';
			case 'errors.network.invalidBody': return 'Invalid body';
			case 'errors.network.invalidStatusCode': return 'Invalid status code';
			case 'errors.network.serverError': return 'Server error';
			case 'errors.network.requestCanceled': return 'Request canceled';
			case 'errors.network.invalidPort': return 'Invalid port';
			case 'errors.network.proxyPortError': return 'Proxy port error';
			case 'errors.network.connectionRefused': return 'Connection refused';
			case 'errors.network.networkUnreachable': return 'Network unreachable';
			case 'errors.network.noRouteToHost': return 'No route to host';
			case 'errors.network.connectionFailed': return 'Connection failed';
			case 'errors.network.sslConnectionFailed': return 'SSL connection failed, please check your network settings';
			case 'friends.clickToRestoreFriend': return 'Click to restore friend';
			case 'friends.friendsList': return 'Friends List';
			case 'friends.friendRequests': return 'Friend Requests';
			case 'friends.friendRequestsList': return 'Friend Requests List';
			case 'friends.removingFriend': return 'Removing friend...';
			case 'friends.failedToRemoveFriend': return 'Failed to remove friend';
			case 'friends.cancelingRequest': return 'Canceling friend request...';
			case 'friends.failedToCancelRequest': return 'Failed to cancel friend request';
			case 'authorProfile.noMoreDatas': return 'No more data';
			case 'authorProfile.userProfile': return 'User Profile';
			case 'favorites.clickToRestoreFavorite': return 'Click to restore favorite';
			case 'favorites.myFavorites': return 'My Favorites';
			case 'galleryDetail.galleryDetail': return 'Gallery Detail';
			case 'galleryDetail.viewGalleryDetail': return 'View Gallery Detail';
			case 'galleryDetail.copyLink': return 'Copy Link';
			case 'galleryDetail.copyImage': return 'Copy Image';
			case 'galleryDetail.saveAs': return 'Save As';
			case 'galleryDetail.saveToAlbum': return 'Save to Album';
			case 'galleryDetail.publishedAt': return 'Published At';
			case 'galleryDetail.viewsCount': return 'Views Count';
			case 'galleryDetail.imageLibraryFunctionIntroduction': return 'Image Library Function Introduction';
			case 'galleryDetail.rightClickToSaveSingleImage': return 'Right Click to Save Single Image';
			case 'galleryDetail.batchSave': return 'Batch Save';
			case 'galleryDetail.keyboardLeftAndRightToSwitch': return 'Keyboard Left and Right to Switch';
			case 'galleryDetail.keyboardUpAndDownToZoom': return 'Keyboard Up and Down to Zoom';
			case 'galleryDetail.mouseWheelToSwitch': return 'Mouse Wheel to Switch';
			case 'galleryDetail.ctrlAndMouseWheelToZoom': return 'CTRL + Mouse Wheel to Zoom';
			case 'galleryDetail.moreFeaturesToBeDiscovered': return 'More Features to Be Discovered...';
			case 'galleryDetail.authorOtherGalleries': return 'Author\'s Other Galleries';
			case 'galleryDetail.relatedGalleries': return 'Related Galleries';
			case 'galleryDetail.clickLeftAndRightEdgeToSwitchImage': return 'Click Left and Right Edge to Switch Image';
			case 'playList.myPlayList': return 'My Play List';
			case 'playList.friendlyTips': return 'Friendly Tips';
			case 'playList.dearUser': return 'Dear User';
			case 'playList.iwaraPlayListSystemIsNotPerfectYet': return 'iwara\'s play list system is not perfect yet';
			case 'playList.notSupportSetCover': return 'Not support set cover';
			case 'playList.notSupportDeleteList': return 'Not support delete list';
			case 'playList.notSupportSetPrivate': return 'Not support set private';
			case 'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone': return 'Yes... create list will always exist and visible to everyone';
			case 'playList.smallSuggestion': return 'Small Suggestion';
			case 'playList.useLikeToCollectContent': return 'If you are more concerned about privacy, it is recommended to use the "like" function to collect content';
			case 'playList.welcomeToDiscussOnGitHub': return 'If you have other suggestions or ideas, welcome to discuss on GitHub!';
			case 'playList.iUnderstand': return 'I Understand';
			case 'playList.searchPlaylists': return 'Search Playlists...';
			case 'playList.newPlaylistName': return 'New Playlist Name';
			case 'playList.createNewPlaylist': return 'Create New Playlist';
			case 'playList.videos': return 'Videos';
			case 'search.googleSearchScope': return 'Search Scope';
			case 'search.searchTags': return 'Search Tags...';
			case 'search.contentRating': return 'Content Rating';
			case 'search.removeTag': return 'Remove Tag';
			case 'search.pleaseEnterSearchContent': return 'Please enter search content';
			case 'search.searchHistory': return 'Search History';
			case 'search.searchSuggestion': return 'Search Suggestion';
			case 'search.usedTimes': return 'Used Times';
			case 'search.lastUsed': return 'Last Used';
			case 'search.noSearchHistoryRecords': return 'No search history';
			case 'search.notSupportCurrentSearchType': return ({required Object searchType}) => 'Not support current search type ${searchType}, please wait for the update';
			case 'search.searchResult': return 'Search Result';
			case 'search.unsupportedSearchType': return ({required Object searchType}) => 'Unsupported search type: ${searchType}';
			case 'search.googleSearch': return 'Google Search';
			case 'search.googleSearchHint': return ({required Object webName}) => '${webName} \'s search function is not easy to use? Try Google Search!';
			case 'search.googleSearchDescription': return 'Use the :site search operator of Google Search to search for content on the site. This is very useful when searching for videos, galleries, playlists, and users.';
			case 'search.googleSearchKeywordsHint': return 'Enter keywords to search';
			case 'search.openLinkJump': return 'Open Link Jump';
			case 'search.googleSearchButton': return 'Google Search';
			case 'search.pleaseEnterSearchKeywords': return 'Please enter search keywords';
			case 'search.googleSearchQueryCopied': return 'Search query copied to clipboard';
			case 'search.googleSearchBrowserOpenFailed': return ({required Object error}) => 'Failed to open browser: ${error}';
			case 'mediaList.personalIntroduction': return 'Personal Introduction';
			case 'settings.listViewMode': return 'List View Mode';
			case 'settings.useTraditionalPaginationMode': return 'Use Traditional Pagination Mode';
			case 'settings.useTraditionalPaginationModeDesc': return 'Enable traditional pagination mode, disable waterfall mode';
			case 'settings.showVideoProgressBottomBarWhenToolbarHidden': return 'Show Video Progress Bottom Bar When Toolbar Hidden';
			case 'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc': return 'This configuration determines whether the video progress bottom bar will be shown when the toolbar is hidden.';
			case 'settings.basicSettings': return 'Basic Settings';
			case 'settings.personalizedSettings': return 'Personalized Settings';
			case 'settings.otherSettings': return 'Other Settings';
			case 'settings.searchConfig': return 'Search Config';
			case 'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain': return 'This configuration determines whether the previous configuration will be used when playing videos again.';
			case 'settings.playControl': return 'Play Control';
			case 'settings.fastForwardTime': return 'Fast Forward Time';
			case 'settings.fastForwardTimeMustBeAPositiveInteger': return 'Fast forward time must be a positive integer.';
			case 'settings.rewindTime': return 'Rewind Time';
			case 'settings.rewindTimeMustBeAPositiveInteger': return 'Rewind time must be a positive integer.';
			case 'settings.longPressPlaybackSpeed': return 'Long Press Playback Speed';
			case 'settings.longPressPlaybackSpeedMustBeAPositiveNumber': return 'Long press playback speed must be a positive number.';
			case 'settings.repeat': return 'Repeat';
			case 'settings.renderVerticalVideoInVerticalScreen': return 'Render Vertical Video in Vertical Screen';
			case 'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen': return 'This configuration determines whether the video will be rendered in vertical screen when playing in full screen.';
			case 'settings.rememberVolume': return 'Remember Volume';
			case 'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain': return 'This configuration determines whether the volume will be kept when playing videos again.';
			case 'settings.rememberBrightness': return 'Remember Brightness';
			case 'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain': return 'This configuration determines whether the brightness will be kept when playing videos again.';
			case 'settings.playControlArea': return 'Play Control Area';
			case 'settings.leftAndRightControlAreaWidth': return 'Left and Right Control Area Width';
			case 'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer': return 'This configuration determines the width of the control areas on the left and right sides of the player.';
			case 'settings.proxyAddressCannotBeEmpty': return 'Proxy address cannot be empty.';
			case 'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort': return 'Invalid proxy address format. Please use the format of IP:port or domain name:port.';
			case 'settings.proxyNormalWork': return 'Proxy normal work.';
			case 'settings.testProxyFailedWithStatusCode': return ({required Object code}) => 'Test proxy failed, status code: ${code}';
			case 'settings.testProxyFailedWithException': return ({required Object exception}) => 'Test proxy failed, exception: ${exception}';
			case 'settings.proxyConfig': return 'Proxy Config';
			case 'settings.thisIsHttpProxyAddress': return 'This is http proxy address';
			case 'settings.checkProxy': return 'Check Proxy';
			case 'settings.proxyAddress': return 'Proxy Address';
			case 'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080': return 'Please enter the URL of the proxy server, for example 127.0.0.1:8080';
			case 'settings.enableProxy': return 'Enable Proxy';
			case 'settings.left': return 'Left';
			case 'settings.middle': return 'Middle';
			case 'settings.right': return 'Right';
			case 'settings.playerSettings': return 'Player Settings';
			case 'settings.networkSettings': return 'Network Settings';
			case 'settings.customizeYourPlaybackExperience': return 'Customize Your Playback Experience';
			case 'settings.chooseYourFavoriteAppAppearance': return 'Choose Your Favorite App Appearance';
			case 'settings.configureYourProxyServer': return 'Configure Your Proxy Server';
			case 'settings.settings': return 'Settings';
			case 'settings.themeSettings': return 'Theme Settings';
			case 'settings.followSystem': return 'Follow System';
			case 'settings.lightMode': return 'Light Mode';
			case 'settings.darkMode': return 'Dark Mode';
			case 'settings.presetTheme': return 'Preset Theme';
			case 'settings.basicTheme': return 'Basic Theme';
			case 'settings.needRestartToApply': return 'Need to restart the app to apply the settings';
			case 'settings.themeNeedRestartDescription': return 'The theme settings need to restart the app to apply the settings';
			case 'settings.about': return 'About';
			case 'settings.currentVersion': return 'Current Version';
			case 'settings.latestVersion': return 'Latest Version';
			case 'settings.checkForUpdates': return 'Check for Updates';
			case 'settings.update': return 'Update';
			case 'settings.newVersionAvailable': return 'New Version Available';
			case 'settings.projectHome': return 'Project Home';
			case 'settings.release': return 'Release';
			case 'settings.issueReport': return 'Issue Report';
			case 'settings.openSourceLicense': return 'Open Source License';
			case 'settings.checkForUpdatesFailed': return 'Check for updates failed, please try again later';
			case 'settings.autoCheckUpdate': return 'Auto Check Update';
			case 'settings.updateContent': return 'Update Content';
			case 'settings.releaseDate': return 'Release Date';
			case 'settings.ignoreThisVersion': return 'Ignore This Version';
			case 'settings.minVersionUpdateRequired': return 'Current version is too low, please update as soon as possible';
			case 'settings.forceUpdateTip': return 'This is a mandatory update. Please update to the latest version as soon as possible';
			case 'settings.viewChangelog': return 'View Changelog';
			case 'settings.alreadyLatestVersion': return 'Already the latest version';
			case 'settings.appSettings': return 'App Settings';
			case 'settings.configureYourAppSettings': return 'Configure Your App Settings';
			case 'settings.history': return 'History';
			case 'settings.autoRecordHistory': return 'Auto Record History';
			case 'settings.autoRecordHistoryDesc': return 'Auto record the videos and images you have watched';
			case 'settings.showUnprocessedMarkdownText': return 'Show Unprocessed Markdown Text';
			case 'settings.showUnprocessedMarkdownTextDesc': return 'Show the original text of the markdown';
			case 'settings.markdown': return 'Markdown';
			case 'settings.activeBackgroundPrivacyMode': return 'Privacy Mode';
			case 'settings.activeBackgroundPrivacyModeDesc': return 'Prevent screenshots, hide screen when running in the background...';
			case 'settings.privacy': return 'Privacy';
			case 'settings.forum': return 'Forum';
			case 'settings.disableForumReplyQuote': return 'Disable Forum Reply Quote';
			case 'settings.disableForumReplyQuoteDesc': return 'Disable carrying replied floor information when replying in forum';
			case 'settings.theaterMode': return 'Theater Mode';
			case 'settings.theaterModeDesc': return 'After opening, the player background will be set to the blurred version of the video cover';
			case 'settings.appLinks': return 'App Links';
			case 'settings.defaultBrowser': return 'Default Browse';
			case 'settings.defaultBrowserDesc': return 'Please open the default link configuration item in the system settings and add the iwara.tv website link';
			case 'settings.themeMode': return 'Theme Mode';
			case 'settings.themeModeDesc': return 'This configuration determines the theme mode of the app';
			case 'settings.dynamicColor': return 'Dynamic Color';
			case 'settings.dynamicColorDesc': return 'This configuration determines whether the app uses dynamic color';
			case 'settings.useDynamicColor': return 'Use Dynamic Color';
			case 'settings.useDynamicColorDesc': return 'This configuration determines whether the app uses dynamic color';
			case 'settings.presetColors': return 'Preset Colors';
			case 'settings.customColors': return 'Custom Colors';
			case 'settings.pickColor': return 'Pick Color';
			case 'settings.cancel': return 'Cancel';
			case 'settings.confirm': return 'Confirm';
			case 'settings.noCustomColors': return 'No custom colors';
			case 'settings.recordAndRestorePlaybackProgress': return 'Record and Restore Playback Progress';
			case 'settings.signature': return 'Signature';
			case 'settings.enableSignature': return 'Enable Signature';
			case 'settings.enableSignatureDesc': return 'This configuration determines whether the app will add signature when replying';
			case 'settings.enterSignature': return 'Enter Signature';
			case 'settings.editSignature': return 'Edit Signature';
			case 'settings.signatureContent': return 'Signature Content';
			case 'settings.exportConfig': return 'Export App Configuration';
			case 'settings.exportConfigDesc': return 'Export app configuration to a file (excluding download records)';
			case 'settings.importConfig': return 'Import App Configuration';
			case 'settings.importConfigDesc': return 'Import app configuration from a file';
			case 'settings.exportConfigSuccess': return 'Configuration exported successfully!';
			case 'settings.exportConfigFailed': return 'Failed to export configuration';
			case 'settings.importConfigSuccess': return 'Configuration imported successfully!';
			case 'settings.importConfigFailed': return 'Failed to import configuration';
			case 'settings.historyUpdateLogs': return 'History Update Logs';
			case 'settings.noUpdateLogs': return 'No update logs available';
			case 'settings.versionLabel': return 'Version: {version}';
			case 'settings.releaseDateLabel': return 'Release Date: {date}';
			case 'settings.noChanges': return 'No update content available';
			case 'settings.interaction': return 'Interaction';
			case 'settings.enableVibration': return 'Enable Vibration';
			case 'settings.enableVibrationDesc': return 'Enable vibration feedback when interacting with the app';
			case 'settings.defaultKeepVideoToolbarVisible': return 'Keep Video Toolbar Visible';
			case 'settings.defaultKeepVideoToolbarVisibleDesc': return 'This setting determines whether the video toolbar remains visible when first entering the video page.';
			case 'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt': return 'Mobile devices enable theater mode, which may cause performance issues. You can choose to enable it.';
			case 'settings.lockButtonPosition': return 'Lock Button Position';
			case 'settings.lockButtonPositionBothSides': return 'Both Sides';
			case 'settings.lockButtonPositionLeftSide': return 'Left Side';
			case 'settings.lockButtonPositionRightSide': return 'Right Side';
			case 'settings.jumpLink': return 'Jump Link';
			case 'settings.language': return 'Language';
			case 'settings.languageChanged': return 'Language setting has been changed, please restart the app to take effect.';
			case 'settings.gestureControl': return 'Gesture Control';
			case 'settings.leftDoubleTapRewind': return 'Left Double Tap Rewind';
			case 'settings.rightDoubleTapFastForward': return 'Right Double Tap Fast Forward';
			case 'settings.doubleTapPause': return 'Double Tap Pause';
			case 'settings.rightVerticalSwipeVolume': return 'Right Vertical Swipe Volume (Effective when entering a new page)';
			case 'settings.leftVerticalSwipeBrightness': return 'Left Vertical Swipe Brightness (Effective when entering a new page)';
			case 'settings.longPressFastForward': return 'Long Press Fast Forward';
			case 'settings.enableMouseHoverShowToolbar': return 'Enable Mouse Hover Show Toolbar';
			case 'settings.enableMouseHoverShowToolbarInfo': return 'When enabled, the video toolbar will be shown when the mouse is hovering over the player. It will be automatically hidden after 3 seconds of inactivity.';
			case 'settings.audioVideoConfig': return 'Audio Video Configuration';
			case 'settings.expandBuffer': return 'Expand Buffer';
			case 'settings.expandBufferInfo': return 'When enabled, the buffer size increases, loading time becomes longer but playback is smoother';
			case 'settings.videoSyncMode': return 'Video Sync Mode';
			case 'settings.videoSyncModeSubtitle': return 'Audio-video synchronization strategy';
			case 'settings.hardwareDecodingMode': return 'Hardware Decoding Mode';
			case 'settings.hardwareDecodingModeSubtitle': return 'Hardware decoding settings';
			case 'settings.enableHardwareAcceleration': return 'Enable Hardware Acceleration';
			case 'settings.enableHardwareAccelerationInfo': return 'Enabling hardware acceleration can improve decoding performance, but some devices may not be compatible';
			case 'settings.useOpenSLESAudioOutput': return 'Use OpenSLES Audio Output';
			case 'settings.useOpenSLESAudioOutputInfo': return 'Use low-latency audio output, may improve audio performance';
			case 'settings.videoSyncAudio': return 'Audio Sync';
			case 'settings.videoSyncDisplayResample': return 'Display Resample';
			case 'settings.videoSyncDisplayResampleVdrop': return 'Display Resample (Drop Frames)';
			case 'settings.videoSyncDisplayResampleDesync': return 'Display Resample (Desync)';
			case 'settings.videoSyncDisplayTempo': return 'Display Tempo';
			case 'settings.videoSyncDisplayVdrop': return 'Display Drop Video Frames';
			case 'settings.videoSyncDisplayAdrop': return 'Display Drop Audio Frames';
			case 'settings.videoSyncDisplayDesync': return 'Display Desync';
			case 'settings.videoSyncDesync': return 'Desync';
			case 'settings.hardwareDecodingAuto': return 'Auto';
			case 'settings.hardwareDecodingAutoCopy': return 'Auto Copy';
			case 'settings.hardwareDecodingAutoSafe': return 'Auto Safe';
			case 'settings.hardwareDecodingNo': return 'Disabled';
			case 'settings.hardwareDecodingYes': return 'Force Enable';
			case 'settings.downloadSettings.downloadSettings': return 'Download Settings';
			case 'settings.downloadSettings.storagePermissionStatus': return 'Storage Permission Status';
			case 'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission': return 'Access Public Directory Need Storage Permission';
			case 'settings.downloadSettings.checkingPermissionStatus': return 'Checking Permission Status...';
			case 'settings.downloadSettings.storagePermissionGranted': return 'Storage Permission Granted';
			case 'settings.downloadSettings.storagePermissionNotGranted': return 'Storage Permission Not Granted';
			case 'settings.downloadSettings.storagePermissionGrantSuccess': return 'Storage Permission Grant Success';
			case 'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited': return 'Storage Permission Grant Failed But Some Features May Be Limited';
			case 'settings.downloadSettings.grantStoragePermission': return 'Grant Storage Permission';
			case 'settings.downloadSettings.customDownloadPath': return 'Custom Download Path';
			case 'settings.downloadSettings.customDownloadPathDescription': return 'When enabled, you can choose a custom save location for downloaded files';
			case 'settings.downloadSettings.customDownloadPathTip': return '💡 Tip: Selecting public directories (like Downloads folder) requires storage permission, recommend using recommended paths first';
			case 'settings.downloadSettings.androidWarning': return 'Android Note: Avoid selecting public directories (such as Downloads folder), recommend using app-specific directories to ensure access permissions.';
			case 'settings.downloadSettings.publicDirectoryPermissionTip': return '⚠️ Notice: You selected a public directory, storage permission is required for normal file downloads';
			case 'settings.downloadSettings.permissionRequiredForPublicDirectory': return 'Storage permission required for public directories';
			case 'settings.downloadSettings.currentDownloadPath': return 'Current Download Path';
			case 'settings.downloadSettings.defaultAppDirectory': return 'Default App Directory';
			case 'settings.downloadSettings.permissionGranted': return 'Granted';
			case 'settings.downloadSettings.permissionRequired': return 'Permission Required';
			case 'settings.downloadSettings.enableCustomDownloadPath': return 'Enable Custom Download Path';
			case 'settings.downloadSettings.disableCustomDownloadPath': return 'Use app default path when disabled';
			case 'settings.downloadSettings.customDownloadPathLabel': return 'Custom Download Path';
			case 'settings.downloadSettings.selectDownloadFolder': return 'Select download folder';
			case 'settings.downloadSettings.recommendedPath': return 'Recommended Path';
			case 'settings.downloadSettings.selectFolder': return 'Select Folder';
			case 'settings.downloadSettings.filenameTemplate': return 'Filename Template';
			case 'settings.downloadSettings.filenameTemplateDescription': return 'Customize the naming rules for downloaded files, supports variable substitution';
			case 'settings.downloadSettings.videoFilenameTemplate': return 'Video Filename Template';
			case 'settings.downloadSettings.galleryFolderTemplate': return 'Gallery Folder Template';
			case 'settings.downloadSettings.imageFilenameTemplate': return 'Image Filename Template';
			case 'settings.downloadSettings.resetToDefault': return 'Reset to Default';
			case 'settings.downloadSettings.supportedVariables': return 'Supported Variables';
			case 'settings.downloadSettings.supportedVariablesDescription': return 'The following variables can be used in filename templates:';
			case 'settings.downloadSettings.copyVariable': return 'Copy Variable';
			case 'settings.downloadSettings.variableCopied': return 'Variable copied';
			case 'settings.downloadSettings.warningPublicDirectory': return 'Warning: Selected public directory may not be accessible. Recommend selecting app-specific directory.';
			case 'settings.downloadSettings.downloadPathUpdated': return 'Download path updated';
			case 'settings.downloadSettings.selectPathFailed': return 'Failed to select path';
			case 'settings.downloadSettings.recommendedPathSet': return 'Set to recommended path';
			case 'settings.downloadSettings.setRecommendedPathFailed': return 'Failed to set recommended path';
			case 'settings.downloadSettings.templateResetToDefault': return 'Reset to default template';
			case 'settings.downloadSettings.functionalTest': return 'Functional Test';
			case 'settings.downloadSettings.testInProgress': return 'Testing...';
			case 'settings.downloadSettings.runTest': return 'Run Test';
			case 'settings.downloadSettings.testDownloadPathAndPermissions': return 'Test if download path and permission configuration work properly';
			case 'settings.downloadSettings.testResults': return 'Test Results';
			case 'settings.downloadSettings.testCompleted': return 'Test completed';
			case 'settings.downloadSettings.testPassed': return 'items passed';
			case 'settings.downloadSettings.testFailed': return 'Test failed';
			case 'settings.downloadSettings.testStoragePermissionCheck': return 'Storage Permission Check';
			case 'settings.downloadSettings.testStoragePermissionGranted': return 'Storage permission granted';
			case 'settings.downloadSettings.testStoragePermissionMissing': return 'Storage permission missing, some features may be limited';
			case 'settings.downloadSettings.testPermissionCheckFailed': return 'Permission check failed';
			case 'settings.downloadSettings.testDownloadPathValidation': return 'Download Path Validation';
			case 'settings.downloadSettings.testPathValidationFailed': return 'Path validation failed';
			case 'settings.downloadSettings.testFilenameTemplateValidation': return 'Filename Template Validation';
			case 'settings.downloadSettings.testAllTemplatesValid': return 'All templates are valid';
			case 'settings.downloadSettings.testSomeTemplatesInvalid': return 'Some templates contain invalid characters';
			case 'settings.downloadSettings.testTemplateValidationFailed': return 'Template validation failed';
			case 'settings.downloadSettings.testDirectoryOperationTest': return 'Directory Operation Test';
			case 'settings.downloadSettings.testDirectoryOperationNormal': return 'Directory creation and file writing are normal';
			case 'settings.downloadSettings.testDirectoryOperationFailed': return 'Directory operation failed';
			case 'settings.downloadSettings.testVideoTemplate': return 'Video Template';
			case 'settings.downloadSettings.testGalleryTemplate': return 'Gallery Template';
			case 'settings.downloadSettings.testImageTemplate': return 'Image Template';
			case 'settings.downloadSettings.testValid': return 'Valid';
			case 'settings.downloadSettings.testInvalid': return 'Invalid';
			case 'settings.downloadSettings.testSuccess': return 'Success';
			case 'settings.downloadSettings.testCorrect': return 'Correct';
			case 'settings.downloadSettings.testError': return 'Error';
			case 'settings.downloadSettings.testPath': return 'Test Path';
			case 'settings.downloadSettings.testBasePath': return 'Base Path';
			case 'settings.downloadSettings.testDirectoryCreation': return 'Directory Creation';
			case 'settings.downloadSettings.testFileWriting': return 'File Writing';
			case 'settings.downloadSettings.testFileContent': return 'File Content';
			case 'settings.downloadSettings.checkingPathStatus': return 'Checking path status...';
			case 'settings.downloadSettings.unableToGetPathStatus': return 'Unable to get path status';
			case 'settings.downloadSettings.actualPathDifferentFromSelected': return 'Note: Actual path differs from selected path';
			case 'settings.downloadSettings.grantPermission': return 'Grant Permission';
			case 'settings.downloadSettings.fixIssue': return 'Fix Issue';
			case 'settings.downloadSettings.issueFixed': return 'Issue fixed';
			case 'settings.downloadSettings.fixFailed': return 'Fix failed, please handle manually';
			case 'settings.downloadSettings.lackStoragePermission': return 'Lack storage permission';
			case 'settings.downloadSettings.cannotAccessPublicDirectory': return 'Cannot access public directory, need "All files access permission"';
			case 'settings.downloadSettings.cannotCreateDirectory': return 'Cannot create directory';
			case 'settings.downloadSettings.directoryNotWritable': return 'Directory not writable';
			case 'settings.downloadSettings.insufficientSpace': return 'Insufficient available space';
			case 'settings.downloadSettings.pathValid': return 'Path is valid';
			case 'settings.downloadSettings.validationFailed': return 'Validation failed';
			case 'settings.downloadSettings.usingDefaultAppDirectory': return 'Using default app directory';
			case 'settings.downloadSettings.appPrivateDirectory': return 'App Private Directory';
			case 'settings.downloadSettings.appPrivateDirectoryDesc': return 'Safe and reliable, no additional permissions required';
			case 'settings.downloadSettings.downloadDirectory': return 'Download Directory';
			case 'settings.downloadSettings.downloadDirectoryDesc': return 'System default download location, easy to manage';
			case 'settings.downloadSettings.moviesDirectory': return 'Movies Directory';
			case 'settings.downloadSettings.moviesDirectoryDesc': return 'System movies directory, recognizable by media apps';
			case 'settings.downloadSettings.documentsDirectory': return 'Documents Directory';
			case 'settings.downloadSettings.documentsDirectoryDesc': return 'iOS app documents directory';
			case 'settings.downloadSettings.requiresStoragePermission': return 'Requires storage permission to access';
			case 'settings.downloadSettings.recommendedPaths': return 'Recommended Paths';
			case 'settings.downloadSettings.selectRecommendedDownloadLocation': return 'Select a recommended download location';
			case 'settings.downloadSettings.noRecommendedPaths': return 'No recommended paths available';
			case 'settings.downloadSettings.recommended': return 'Recommended';
			case 'settings.downloadSettings.requiresPermission': return 'Requires Permission';
			case 'settings.downloadSettings.authorizeAndSelect': return 'Authorize and Select';
			case 'settings.downloadSettings.select': return 'Select';
			case 'settings.downloadSettings.permissionAuthorizationFailed': return 'Permission authorization failed, cannot select this path';
			case 'settings.downloadSettings.pathValidationFailed': return 'Path validation failed';
			case 'settings.downloadSettings.downloadPathSetTo': return 'Download path set to';
			case 'settings.downloadSettings.setPathFailed': return 'Failed to set path';
			case 'settings.downloadSettings.variableTitle': return 'Title';
			case 'settings.downloadSettings.variableAuthor': return 'Author name';
			case 'settings.downloadSettings.variableUsername': return 'Author username';
			case 'settings.downloadSettings.variableQuality': return 'Video quality';
			case 'settings.downloadSettings.variableFilename': return 'Original filename';
			case 'settings.downloadSettings.variableId': return 'Content ID';
			case 'settings.downloadSettings.variableCount': return 'Gallery image count';
			case 'settings.downloadSettings.variableDate': return 'Current date (YYYY-MM-DD)';
			case 'settings.downloadSettings.variableTime': return 'Current time (HH-MM-SS)';
			case 'settings.downloadSettings.variableDatetime': return 'Current date time (YYYY-MM-DD_HH-MM-SS)';
			case 'settings.downloadSettings.downloadSettingsTitle': return 'Download Settings';
			case 'settings.downloadSettings.downloadSettingsSubtitle': return 'Configure download path and file naming rules';
			case 'settings.downloadSettings.suchAsTitleQuality': return 'For example: %title_%quality';
			case 'settings.downloadSettings.suchAsTitleId': return 'For example: %title_%id';
			case 'settings.downloadSettings.suchAsTitleFilename': return 'For example: %title_%filename';
			case 'oreno3d.name': return 'Oreno3D';
			case 'oreno3d.tags': return 'Tags';
			case 'oreno3d.characters': return 'Characters';
			case 'oreno3d.origin': return 'Origin';
			case 'oreno3d.thirdPartyTagsExplanation': return 'The **tags**, **characters**, and **origin** information displayed here are provided by the third-party site **Oreno3D** for reference only.\n\nSince this information source is only available in Japanese, it currently lacks internationalization adaptation.\n\nIf you are interested in contributing to internationalization efforts, please visit the repository to help improve it!';
			case 'oreno3d.sortTypes.hot': return 'Hot';
			case 'oreno3d.sortTypes.favorites': return 'Favorites';
			case 'oreno3d.sortTypes.latest': return 'Latest';
			case 'oreno3d.sortTypes.popularity': return 'Popular';
			case 'oreno3d.errors.requestFailed': return 'Request failed, status code';
			case 'oreno3d.errors.connectionTimeout': return 'Connection timeout, please check network connection';
			case 'oreno3d.errors.sendTimeout': return 'Send request timeout';
			case 'oreno3d.errors.receiveTimeout': return 'Receive response timeout';
			case 'oreno3d.errors.badCertificate': return 'Certificate verification failed';
			case 'oreno3d.errors.resourceNotFound': return 'Requested resource not found';
			case 'oreno3d.errors.accessDenied': return 'Access denied, may require authentication or permission';
			case 'oreno3d.errors.serverError': return 'Internal server error';
			case 'oreno3d.errors.serviceUnavailable': return 'Service temporarily unavailable';
			case 'oreno3d.errors.requestCancelled': return 'Request cancelled';
			case 'oreno3d.errors.connectionError': return 'Network connection error, please check network settings';
			case 'oreno3d.errors.networkRequestFailed': return 'Network request failed';
			case 'oreno3d.errors.searchVideoError': return 'Unknown error occurred while searching videos';
			case 'oreno3d.errors.getPopularVideoError': return 'Unknown error occurred while getting popular videos';
			case 'oreno3d.errors.getVideoDetailError': return 'Unknown error occurred while getting video details';
			case 'oreno3d.errors.parseVideoDetailError': return 'Unknown error occurred while getting and parsing video details';
			case 'oreno3d.errors.downloadFileError': return 'Unknown error occurred while downloading file';
			case 'oreno3d.loading.gettingVideoInfo': return 'Getting video information...';
			case 'oreno3d.loading.cancel': return 'Cancel';
			case 'oreno3d.messages.videoNotFoundOrDeleted': return 'Video not found or has been deleted';
			case 'oreno3d.messages.unableToGetVideoPlayLink': return 'Unable to get video playback link';
			case 'oreno3d.messages.getVideoDetailFailed': return 'Failed to get video details';
			case 'signIn.pleaseLoginFirst': return 'Please login first';
			case 'signIn.alreadySignedInToday': return 'You have already signed in today!';
			case 'signIn.youDidNotStickToTheSignIn': return 'You did not stick to the sign in.';
			case 'signIn.signInSuccess': return 'Sign in successfully!';
			case 'signIn.signInFailed': return 'Sign in failed, please try again later';
			case 'signIn.consecutiveSignIns': return 'Consecutive Sign Ins';
			case 'signIn.failureReason': return 'Failure Reason';
			case 'signIn.selectDateRange': return 'Select Date Range';
			case 'signIn.startDate': return 'Start Date';
			case 'signIn.endDate': return 'End Date';
			case 'signIn.invalidDate': return 'Invalid Date';
			case 'signIn.invalidDateRange': return 'Invalid Date Range';
			case 'signIn.errorFormatText': return 'Date Format Error';
			case 'signIn.errorInvalidText': return 'Invalid Date Range';
			case 'signIn.errorInvalidRangeText': return 'Invalid Date Range';
			case 'signIn.dateRangeCantBeMoreThanOneYear': return 'Date range cannot be more than one year';
			case 'signIn.signIn': return 'Sign In';
			case 'signIn.signInRecord': return 'Sign In Record';
			case 'signIn.totalSignIns': return 'Total Sign Ins';
			case 'signIn.pleaseSelectSignInStatus': return 'Please select sign in status';
			case 'subscriptions.pleaseLoginFirstToViewYourSubscriptions': return 'Please login first to view your subscriptions.';
			case 'subscriptions.selectUser': return 'Select User';
			case 'subscriptions.noSubscribedUsers': return 'No subscribed users';
			case 'subscriptions.showAllSubscribedUsersContent': return 'Show all subscribed users content';
			case 'videoDetail.pipMode': return 'PiP Mode';
			case 'videoDetail.resumeFromLastPosition': return ({required Object position}) => 'Resume from last position: ${position}';
			case 'videoDetail.videoIdIsEmpty': return 'Video ID is empty';
			case 'videoDetail.videoInfoIsEmpty': return 'Video info is empty';
			case 'videoDetail.thisIsAPrivateVideo': return 'This is a private video';
			case 'videoDetail.getVideoInfoFailed': return 'Get video info failed, please try again later';
			case 'videoDetail.noVideoSourceFound': return 'No video source found';
			case 'videoDetail.tagCopiedToClipboard': return ({required Object tagId}) => 'Tag "${tagId}" copied to clipboard';
			case 'videoDetail.errorLoadingVideo': return 'Error loading video';
			case 'videoDetail.play': return 'Play';
			case 'videoDetail.pause': return 'Pause';
			case 'videoDetail.exitAppFullscreen': return 'Exit App Fullscreen';
			case 'videoDetail.enterAppFullscreen': return 'Enter App Fullscreen';
			case 'videoDetail.exitSystemFullscreen': return 'Exit System Fullscreen';
			case 'videoDetail.enterSystemFullscreen': return 'Enter System Fullscreen';
			case 'videoDetail.seekTo': return 'Seek To';
			case 'videoDetail.switchResolution': return 'Switch Resolution';
			case 'videoDetail.switchPlaybackSpeed': return 'Switch Playback Speed';
			case 'videoDetail.rewindSeconds': return ({required Object num}) => 'Rewind ${num} seconds';
			case 'videoDetail.fastForwardSeconds': return ({required Object num}) => 'Fast Forward ${num} seconds';
			case 'videoDetail.playbackSpeedIng': return ({required Object rate}) => 'Playing at ${rate}x speed';
			case 'videoDetail.brightness': return 'Brightness';
			case 'videoDetail.brightnessLowest': return 'Brightness is lowest';
			case 'videoDetail.volume': return 'Volume';
			case 'videoDetail.volumeMuted': return 'Volume is muted';
			case 'videoDetail.home': return 'Home';
			case 'videoDetail.videoPlayer': return 'Video Player';
			case 'videoDetail.videoPlayerInfo': return 'Video Player Info';
			case 'videoDetail.moreSettings': return 'More Settings';
			case 'videoDetail.videoPlayerFeatureInfo': return 'Video Player Feature Info';
			case 'videoDetail.autoRewind': return 'Auto Rewind';
			case 'videoDetail.rewindAndFastForward': return 'Rewind and Fast Forward';
			case 'videoDetail.volumeAndBrightness': return 'Volume and Brightness';
			case 'videoDetail.centerAreaDoubleTapPauseOrPlay': return 'Center Area Double Tap Pause or Play';
			case 'videoDetail.showVerticalVideoInFullScreen': return 'Show Vertical Video in Full Screen';
			case 'videoDetail.keepLastVolumeAndBrightness': return 'Keep Last Volume and Brightness';
			case 'videoDetail.setProxy': return 'Set Proxy';
			case 'videoDetail.moreFeaturesToBeDiscovered': return 'More Features to Be Discovered...';
			case 'videoDetail.videoPlayerSettings': return 'Video Player Settings';
			case 'videoDetail.commentCount': return ({required Object num}) => '${num} comments';
			case 'videoDetail.writeYourCommentHere': return 'Write your comment here...';
			case 'videoDetail.authorOtherVideos': return 'Author\'s Other Videos';
			case 'videoDetail.relatedVideos': return 'Related Videos';
			case 'videoDetail.privateVideo': return 'This is a private video';
			case 'videoDetail.externalVideo': return 'This is an external video';
			case 'videoDetail.openInBrowser': return 'Open in Browser';
			case 'videoDetail.resourceDeleted': return 'This video seems to have been deleted :/';
			case 'videoDetail.noDownloadUrl': return 'No download URL';
			case 'videoDetail.startDownloading': return 'Start downloading';
			case 'videoDetail.downloadFailed': return 'Download failed, please try again later';
			case 'videoDetail.downloadSuccess': return 'Download success';
			case 'videoDetail.download': return 'Download';
			case 'videoDetail.downloadManager': return 'Download Manager';
			case 'videoDetail.resourceNotFound': return 'Resource not found';
			case 'videoDetail.videoLoadError': return 'Video load error';
			case 'videoDetail.authorNoOtherVideos': return 'Author has no other videos';
			case 'videoDetail.noRelatedVideos': return 'No related videos';
			case 'videoDetail.skeleton.fetchingVideoInfo': return 'Fetching video info...';
			case 'videoDetail.skeleton.fetchingVideoSources': return 'Fetching video sources...';
			case 'videoDetail.skeleton.loadingVideo': return 'Loading video...';
			case 'share.sharePlayList': return 'Share Play List';
			case 'share.wowDidYouSeeThis': return 'Wow, did you see this?';
			case 'share.nameIs': return 'Name is';
			case 'share.clickLinkToView': return 'Click link to view';
			case 'share.iReallyLikeThis': return 'I really like this';
			case 'share.shareFailed': return 'Share failed, please try again later';
			case 'share.share': return 'Share';
			case 'share.shareAsImage': return 'Share as Image';
			case 'share.shareAsText': return 'Share as Text';
			case 'share.shareAsImageDesc': return 'Share the video cover as an image';
			case 'share.shareAsTextDesc': return 'Share the video details as text';
			case 'share.shareAsImageFailed': return 'Share the video cover as an image failed, please try again later';
			case 'share.shareAsTextFailed': return 'Share the video details as text failed, please try again later';
			case 'share.shareVideo': return 'Share Video';
			case 'share.authorIs': return 'Author is';
			case 'share.shareGallery': return 'Share Gallery';
			case 'share.galleryTitleIs': return 'Gallery title is';
			case 'share.galleryAuthorIs': return 'Gallery author is';
			case 'share.shareUser': return 'Share User';
			case 'share.userNameIs': return 'User name is';
			case 'share.userAuthorIs': return 'User author is';
			case 'share.comments': return 'Comments';
			case 'share.shareThread': return 'Share Thread';
			case 'share.views': return 'Views';
			case 'share.sharePost': return 'Share Post';
			case 'share.postTitleIs': return 'Post title is';
			case 'share.postAuthorIs': return 'Post author is';
			case 'markdown.markdownSyntax': return 'Markdown Syntax';
			case 'markdown.iwaraSpecialMarkdownSyntax': return 'Iwara Special Markdown Syntax';
			case 'markdown.internalLink': return 'Internal Link';
			case 'markdown.supportAutoConvertLinkBelow': return 'Support auto convert link below:';
			case 'markdown.convertLinkExample': return '🎬 Video Link\n🖼️ Image Link\n👤 User Link\n📌 Forum Link\n🎵 Playlist Link\n💬 Thread Link';
			case 'markdown.mentionUser': return 'Mention User';
			case 'markdown.mentionUserDescription': return 'Input @ followed by username, will be automatically converted to user link';
			case 'markdown.markdownBasicSyntax': return 'Markdown Basic Syntax';
			case 'markdown.paragraphAndLineBreak': return 'Paragraph and Line Break';
			case 'markdown.paragraphAndLineBreakDescription': return 'Paragraphs are separated by a line, and two spaces at the end of the line will be converted to a line break';
			case 'markdown.paragraphAndLineBreakSyntax': return 'This is the first paragraph\n\nThis is the second paragraph\nThis line ends with two spaces  \nwill be converted to a line break';
			case 'markdown.textStyle': return 'Text Style';
			case 'markdown.textStyleDescription': return 'Use special symbols to surround text to change style';
			case 'markdown.textStyleSyntax': return '**Bold Text**\n*Italic Text*\n~~Strikethrough Text~~\n`Code Text`';
			case 'markdown.quote': return 'Quote';
			case 'markdown.quoteDescription': return 'Use > symbol to create quote, multiple > to create multi-level quote';
			case 'markdown.quoteSyntax': return '> This is a first-level quote\n>> This is a second-level quote';
			case 'markdown.list': return 'List';
			case 'markdown.listDescription': return 'Create ordered list with number+dot, create unordered list with -';
			case 'markdown.listSyntax': return '1. First item\n2. Second item\n\n- Unordered item\n  - Subitem\n  - Another subitem';
			case 'markdown.linkAndImage': return 'Link and Image';
			case 'markdown.linkAndImageDescription': return 'Link format: [text](URL)\nImage format: ![description](URL)';
			case 'markdown.linkAndImageSyntax': return ({required Object link, required Object imgUrl}) => '[link text](${link})\n![image description](${imgUrl})';
			case 'markdown.title': return 'Title';
			case 'markdown.titleDescription': return 'Use # symbol to create title, number to show level';
			case 'markdown.titleSyntax': return '# First-level title\n## Second-level title\n### Third-level title';
			case 'markdown.separator': return 'Separator';
			case 'markdown.separatorDescription': return 'Create separator with three or more - symbols';
			case 'markdown.separatorSyntax': return '---';
			case 'markdown.syntax': return 'Syntax';
			case 'forum.recent': return 'Recent';
			case 'forum.category': return 'Category';
			case 'forum.lastReply': return 'Last Reply';
			case 'forum.errors.pleaseSelectCategory': return 'Please select a category';
			case 'forum.errors.threadLocked': return 'This thread is locked, cannot reply';
			case 'forum.createPost': return 'Create Post';
			case 'forum.title': return 'Title';
			case 'forum.enterTitle': return 'Enter Title';
			case 'forum.content': return 'Content';
			case 'forum.enterContent': return 'Enter Content';
			case 'forum.writeYourContentHere': return 'Write your content here...';
			case 'forum.posts': return 'Posts';
			case 'forum.threads': return 'Threads';
			case 'forum.forum': return 'Forum';
			case 'forum.createThread': return 'Create Thread';
			case 'forum.selectCategory': return 'Select Category';
			case 'forum.cooldownRemaining': return ({required Object minutes, required Object seconds}) => 'Cooldown remaining ${minutes} minutes ${seconds} seconds';
			case 'forum.groups.administration': return 'Administration';
			case 'forum.groups.global': return 'Global';
			case 'forum.groups.chinese': return 'Chinese';
			case 'forum.groups.japanese': return 'Japanese';
			case 'forum.groups.korean': return 'Korean';
			case 'forum.groups.other': return 'Other';
			case 'forum.leafNames.announcements': return 'Announcements';
			case 'forum.leafNames.feedback': return 'Feedback';
			case 'forum.leafNames.support': return 'Support';
			case 'forum.leafNames.general': return 'General';
			case 'forum.leafNames.guides': return 'Guides';
			case 'forum.leafNames.questions': return 'Questions';
			case 'forum.leafNames.requests': return 'Requests';
			case 'forum.leafNames.sharing': return 'Sharing';
			case 'forum.leafNames.general_zh': return 'General';
			case 'forum.leafNames.questions_zh': return 'Questions';
			case 'forum.leafNames.requests_zh': return 'Requests';
			case 'forum.leafNames.support_zh': return 'Support';
			case 'forum.leafNames.general_ja': return 'General';
			case 'forum.leafNames.questions_ja': return 'Questions';
			case 'forum.leafNames.requests_ja': return 'Requests';
			case 'forum.leafNames.support_ja': return 'Support';
			case 'forum.leafNames.korean': return 'Korean';
			case 'forum.leafNames.other': return 'Other';
			case 'forum.leafDescriptions.announcements': return 'Official important notifications and announcements';
			case 'forum.leafDescriptions.feedback': return 'Feedback on the website\'s features and services';
			case 'forum.leafDescriptions.support': return 'Help to resolve website-related issues';
			case 'forum.leafDescriptions.general': return 'Discuss any topic';
			case 'forum.leafDescriptions.guides': return 'Share your experiences and tutorials';
			case 'forum.leafDescriptions.questions': return 'Raise your inquiries';
			case 'forum.leafDescriptions.requests': return 'Post your requests';
			case 'forum.leafDescriptions.sharing': return 'Share interesting content';
			case 'forum.leafDescriptions.general_zh': return 'Discuss any topic';
			case 'forum.leafDescriptions.questions_zh': return 'Raise your inquiries';
			case 'forum.leafDescriptions.requests_zh': return 'Post your requests';
			case 'forum.leafDescriptions.support_zh': return 'Help to resolve website-related issues';
			case 'forum.leafDescriptions.general_ja': return 'Discuss any topic';
			case 'forum.leafDescriptions.questions_ja': return 'Raise your inquiries';
			case 'forum.leafDescriptions.requests_ja': return 'Post your requests';
			case 'forum.leafDescriptions.support_ja': return 'Help to resolve website-related issues';
			case 'forum.leafDescriptions.korean': return 'Discussions related to Korean';
			case 'forum.leafDescriptions.other': return 'Other unclassified content';
			case 'forum.reply': return 'Reply';
			case 'forum.pendingReview': return 'Pending Review';
			case 'forum.editedAt': return 'Edited At';
			case 'forum.copySuccess': return 'Copied to clipboard';
			case 'forum.copySuccessForMessage': return ({required Object str}) => 'Copied to clipboard: ${str}';
			case 'forum.editReply': return 'Edit Reply';
			case 'forum.editTitle': return 'Edit Title';
			case 'forum.submit': return 'Submit';
			case 'notifications.errors.unsupportedNotificationType': return 'Unsupported notification type';
			case 'notifications.errors.unknownUser': return 'Unknown user';
			case 'notifications.errors.unsupportedNotificationTypeWithType': return ({required Object type}) => 'Unsupported notification type: ${type}';
			case 'notifications.errors.unknownNotificationType': return 'Unknown notification type';
			case 'notifications.notifications': return 'Notifications';
			case 'notifications.profile': return 'Profile';
			case 'notifications.postedNewComment': return 'Posted new comment';
			case 'notifications.inYour': return 'In your';
			case 'notifications.video': return 'Video';
			case 'notifications.repliedYourVideoComment': return 'Replied your video comment';
			case 'notifications.copyInfoToClipboard': return 'Copy notification info to clipboard';
			case 'notifications.copySuccess': return 'Copied to clipboard';
			case 'notifications.copySuccessForMessage': return ({required Object str}) => 'Copied to clipboard: ${str}';
			case 'notifications.markAllAsRead': return 'Mark all as read';
			case 'notifications.markAllAsReadSuccess': return 'All notifications have been marked as read';
			case 'notifications.markAllAsReadFailed': return 'Mark all as read failed';
			case 'notifications.markSelectedAsRead': return 'Mark selected as read';
			case 'notifications.markSelectedAsReadSuccess': return 'Selected notifications have been marked as read';
			case 'notifications.markSelectedAsReadFailed': return 'Mark selected as read failed';
			case 'notifications.markAsRead': return 'Mark as read';
			case 'notifications.markAsReadSuccess': return 'Notification has been marked as read';
			case 'notifications.markAsReadFailed': return 'Notification marked as read failed';
			case 'notifications.notificationTypeHelp': return 'Notification Type Help';
			case 'notifications.dueToLackOfNotificationTypeDetails': return 'Due to the lack of notification type details, the supported types may not cover the messages you currently receive';
			case 'notifications.helpUsImproveNotificationTypeSupport': return 'If you are willing to help us improve the support for notification types';
			case 'notifications.helpUsImproveNotificationTypeSupportLongText': return '1. 📋 Copy the notification information\n2. 🐞 Submit an issue to the project repository\n\n⚠️ Note: Notification information may contain personal privacy, if you do not want to public, you can also send it to the project author by email.';
			case 'notifications.goToRepository': return 'Go to Repository';
			case 'notifications.copy': return 'Copy';
			case 'notifications.commentApproved': return 'Comment Approved';
			case 'notifications.repliedYourProfileComment': return 'Replied your profile comment';
			case 'notifications.kReplied': return 'replied to your comment on';
			case 'notifications.kCommented': return 'commented on your';
			case 'notifications.kVideo': return 'video';
			case 'notifications.kGallery': return 'gallery';
			case 'notifications.kProfile': return 'profile';
			case 'notifications.kThread': return 'thread';
			case 'notifications.kPost': return 'post';
			case 'notifications.kCommentSection': return 'comment section';
			case 'notifications.kApprovedComment': return 'Comment approved';
			case 'notifications.kApprovedVideo': return 'Video approved';
			case 'notifications.kApprovedGallery': return 'Gallery approved';
			case 'notifications.kApprovedThread': return 'Thread approved';
			case 'notifications.kApprovedPost': return 'Post approved';
			case 'notifications.kUnknownType': return 'Unknown notification type';
			case 'conversation.errors.pleaseSelectAUser': return 'Please select a user';
			case 'conversation.errors.pleaseEnterATitle': return 'Please enter a title';
			case 'conversation.errors.clickToSelectAUser': return 'Click to select a user';
			case 'conversation.errors.loadFailedClickToRetry': return 'Load failed, click to retry';
			case 'conversation.errors.loadFailed': return 'Load failed';
			case 'conversation.errors.clickToRetry': return 'Click to retry';
			case 'conversation.errors.noMoreConversations': return 'No more conversations';
			case 'conversation.conversation': return 'Conversation';
			case 'conversation.startConversation': return 'Start Conversation';
			case 'conversation.noConversation': return 'No conversation';
			case 'conversation.selectFromLeftListAndStartConversation': return 'Select from left list and start conversation';
			case 'conversation.title': return 'Title';
			case 'conversation.body': return 'Body';
			case 'conversation.selectAUser': return 'Select a user';
			case 'conversation.searchUsers': return 'Search users...';
			case 'conversation.tmpNoConversions': return 'No conversions';
			case 'conversation.deleteThisMessage': return 'Delete this message';
			case 'conversation.deleteThisMessageSubtitle': return 'This operation cannot be undone';
			case 'conversation.writeMessageHere': return 'Write message here...';
			case 'conversation.sendMessage': return 'Send message';
			case 'splash.errors.initializationFailed': return 'Initialization failed, please restart the app';
			case 'splash.preparing': return 'Preparing...';
			case 'splash.initializing': return 'Initializing...';
			case 'splash.loading': return 'Loading...';
			case 'splash.ready': return 'Ready';
			case 'splash.initializingMessageService': return 'Initializing message service...';
			case 'download.errors.imageModelNotFound': return 'Image model not found';
			case 'download.errors.downloadFailed': return 'Download failed';
			case 'download.errors.videoInfoNotFound': return 'Video info not found';
			case 'download.errors.downloadTaskAlreadyExists': return 'Download task already exists';
			case 'download.errors.videoAlreadyDownloaded': return 'Video already downloaded';
			case 'download.errors.downloadFailedForMessage': return ({required Object errorInfo}) => 'Add download task failed: ${errorInfo}';
			case 'download.errors.userPausedDownload': return 'User paused download';
			case 'download.errors.unknown': return 'Unknown';
			case 'download.errors.fileSystemError': return ({required Object errorInfo}) => 'File system error: ${errorInfo}';
			case 'download.errors.unknownError': return ({required Object errorInfo}) => 'Unknown error: ${errorInfo}';
			case 'download.errors.connectionTimeout': return 'Connection timeout';
			case 'download.errors.sendTimeout': return 'Send timeout';
			case 'download.errors.receiveTimeout': return 'Receive timeout';
			case 'download.errors.serverError': return ({required Object errorInfo}) => 'Server error: ${errorInfo}';
			case 'download.errors.unknownNetworkError': return 'Unknown network error';
			case 'download.errors.serviceIsClosing': return 'Download service is closing';
			case 'download.errors.partialDownloadFailed': return 'Partial content download failed';
			case 'download.errors.noDownloadTask': return 'No download task';
			case 'download.errors.taskNotFoundOrDataError': return 'Task not found or data error';
			case 'download.errors.fileNotFound': return 'File not found';
			case 'download.errors.openFolderFailed': return 'Failed to open folder';
			case 'download.errors.copyDownloadUrlFailed': return 'Failed to copy download URL';
			case 'download.errors.openFolderFailedWithMessage': return ({required Object message}) => 'Failed to open folder: ${message}';
			case 'download.errors.directoryNotFound': return 'Directory not found';
			case 'download.errors.copyFailed': return 'Copy failed';
			case 'download.errors.openFileFailed': return 'Failed to open file';
			case 'download.errors.openFileFailedWithMessage': return ({required Object message}) => 'Failed to open file: ${message}';
			case 'download.errors.noDownloadSource': return 'No download source';
			case 'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded': return 'No download source, please wait for information loading to be completed and try again';
			case 'download.errors.noActiveDownloadTask': return 'No active download task';
			case 'download.errors.noFailedDownloadTask': return 'No failed download task';
			case 'download.errors.noCompletedDownloadTask': return 'No completed download task';
			case 'download.errors.taskAlreadyCompletedDoNotAdd': return 'Task already completed, do not add again';
			case 'download.errors.linkExpiredTryAgain': return 'Link expired, trying to get new download link';
			case 'download.errors.linkExpiredTryAgainSuccess': return 'Link expired, trying to get new download link success';
			case 'download.errors.linkExpiredTryAgainFailed': return 'Link expired, trying to get new download link failed';
			case 'download.errors.taskDeleted': return 'Task deleted';
			case 'download.errors.unsupportedImageFormat': return ({required Object format}) => 'Unsupported image format: ${format}';
			case 'download.errors.deleteFileError': return 'Failed to delete file, possibly because the file is being used by another process';
			case 'download.errors.deleteTaskError': return 'Failed to delete task';
			case 'download.errors.canNotRefreshVideoTask': return 'Failed to refresh video task';
			case 'download.errors.taskAlreadyProcessing': return 'Task already processing';
			case 'download.errors.taskNotFound': return 'Task not found';
			case 'download.errors.failedToLoadTasks': return 'Failed to load tasks';
			case 'download.errors.partialDownloadFailedWithMessage': return ({required Object message}) => 'Partial download failed: ${message}';
			case 'download.errors.unsupportedImageFormatWithMessage': return ({required Object extension}) => 'Unsupported image format: ${extension}, you can try to download it to your device to view it';
			case 'download.errors.imageLoadFailed': return 'Image load failed';
			case 'download.errors.pleaseTryOtherViewer': return 'Please try using other viewers to open';
			case 'download.downloadList': return 'Download List';
			case 'download.download': return 'Download';
			case 'download.startDownloading': return 'Start Downloading';
			case 'download.clearAllFailedTasks': return 'Clear All Failed Tasks';
			case 'download.clearAllFailedTasksConfirmation': return 'Are you sure you want to clear all failed download tasks? The files of these tasks will also be deleted.';
			case 'download.clearAllFailedTasksSuccess': return 'Cleared all failed tasks';
			case 'download.clearAllFailedTasksError': return 'Error occurred while clearing failed tasks';
			case 'download.downloadStatus': return 'Download Status';
			case 'download.imageList': return 'Image List';
			case 'download.retryDownload': return 'Retry Download';
			case 'download.notDownloaded': return 'Not Downloaded';
			case 'download.downloaded': return 'Downloaded';
			case 'download.waitingForDownload': return 'Waiting for Download';
			case 'download.downloadingProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => 'Downloading (${downloaded}/${total} images ${progress}%)';
			case 'download.downloadingSingleImageProgress': return ({required Object downloaded}) => 'Downloading (${downloaded} images)';
			case 'download.pausedProgressForImageProgress': return ({required Object downloaded, required Object total, required Object progress}) => 'Paused (${downloaded}/${total} images ${progress}%)';
			case 'download.pausedSingleImageProgress': return ({required Object downloaded}) => 'Paused (${downloaded} images)';
			case 'download.downloadedProgressForImageProgress': return ({required Object total}) => 'Downloaded (Total ${total} images)';
			case 'download.viewVideoDetail': return 'View Video Detail';
			case 'download.viewGalleryDetail': return 'View Gallery Detail';
			case 'download.moreOptions': return 'More Options';
			case 'download.openFile': return 'Open File';
			case 'download.pause': return 'Pause';
			case 'download.resume': return 'Resume';
			case 'download.copyDownloadUrl': return 'Copy Download URL';
			case 'download.showInFolder': return 'Show in Folder';
			case 'download.deleteTask': return 'Delete Task';
			case 'download.deleteTaskConfirmation': return 'Are you sure you want to delete this download task?\nThe task file will also be deleted.';
			case 'download.forceDeleteTask': return 'Force Delete Task';
			case 'download.forceDeleteTaskConfirmation': return 'Are you sure you want to force delete this download task?\nThe task file will also be deleted, even if the file is being used.';
			case 'download.downloadingProgressForVideoTask': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloadingOnlyDownloadedAndSpeed': return ({required Object downloaded, required Object speed}) => 'Downloading ${downloaded} • ${speed}MB/s';
			case 'download.pausedForDownloadedAndTotal': return ({required Object downloaded, required Object total, required Object progress}) => 'Paused ${downloaded}/${total} (${progress}%)';
			case 'download.pausedAndDownloaded': return ({required Object downloaded}) => 'Paused • Downloaded ${downloaded}';
			case 'download.downloadedWithSize': return ({required Object size}) => 'Downloaded • ${size}';
			case 'download.copyDownloadUrlSuccess': return 'Download URL copied';
			case 'download.totalImageNums': return ({required Object num}) => '${num} images';
			case 'download.downloadingDownloadedTotalProgressSpeed': return ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
			case 'download.downloading': return 'Downloading';
			case 'download.failed': return 'Failed';
			case 'download.completed': return 'Completed';
			case 'download.downloadDetail': return 'Download Detail';
			case 'download.copy': return 'Copy';
			case 'download.copySuccess': return 'Copied';
			case 'download.waiting': return 'Waiting';
			case 'download.paused': return 'Paused';
			case 'download.downloadingOnlyDownloaded': return ({required Object downloaded}) => 'Downloading ${downloaded}';
			case 'download.galleryDownloadCompletedWithName': return ({required Object galleryName}) => 'Gallery Download Completed: ${galleryName}';
			case 'download.downloadCompletedWithName': return ({required Object fileName}) => 'Download Completed: ${fileName}';
			case 'download.stillInDevelopment': return 'Still in development';
			case 'download.saveToAppDirectory': return 'Save to app directory';
			case 'favorite.errors.addFailed': return 'Add failed';
			case 'favorite.errors.addSuccess': return 'Add success';
			case 'favorite.errors.deleteFolderFailed': return 'Delete folder failed';
			case 'favorite.errors.deleteFolderSuccess': return 'Delete folder success';
			case 'favorite.errors.folderNameCannotBeEmpty': return 'Folder name cannot be empty';
			case 'favorite.add': return 'Add';
			case 'favorite.addSuccess': return 'Add success';
			case 'favorite.addFailed': return 'Add failed';
			case 'favorite.remove': return 'Remove';
			case 'favorite.removeSuccess': return 'Remove success';
			case 'favorite.removeFailed': return 'Remove failed';
			case 'favorite.removeConfirmation': return 'Are you sure you want to remove this item from favorites?';
			case 'favorite.removeConfirmationSuccess': return 'Item removed from favorites';
			case 'favorite.removeConfirmationFailed': return 'Failed to remove item from favorites';
			case 'favorite.createFolderSuccess': return 'Folder created successfully';
			case 'favorite.createFolderFailed': return 'Failed to create folder';
			case 'favorite.createFolder': return 'Create Folder';
			case 'favorite.enterFolderName': return 'Enter folder name';
			case 'favorite.enterFolderNameHere': return 'Enter folder name here...';
			case 'favorite.create': return 'Create';
			case 'favorite.items': return 'Items';
			case 'favorite.newFolderName': return 'New Folder';
			case 'favorite.searchFolders': return 'Search folders...';
			case 'favorite.searchItems': return 'Search items...';
			case 'favorite.createdAt': return 'Created At';
			case 'favorite.myFavorites': return 'My Favorites';
			case 'favorite.deleteFolderTitle': return 'Delete Folder';
			case 'favorite.deleteFolderConfirmWithTitle': return ({required Object title}) => 'Are you sure you want to delete ${title} folder?';
			case 'favorite.removeItemTitle': return 'Remove Item';
			case 'favorite.removeItemConfirmWithTitle': return ({required Object title}) => 'Are you sure you want to delete ${title} item?';
			case 'favorite.removeItemSuccess': return 'Item removed from favorites';
			case 'favorite.removeItemFailed': return 'Failed to remove item from favorites';
			case 'favorite.localizeFavorite': return 'Local Favorite';
			case 'favorite.editFolderTitle': return 'Edit Folder';
			case 'favorite.editFolderSuccess': return 'Folder updated successfully';
			case 'favorite.editFolderFailed': return 'Failed to update folder';
			case 'favorite.searchTags': return 'Search tags';
			case 'translation.testConnection': return 'Test Connection';
			case 'translation.testConnectionSuccess': return 'Test connection success';
			case 'translation.testConnectionFailed': return 'Test connection failed';
			case 'translation.testConnectionFailedWithMessage': return ({required Object message}) => 'Test connection failed: ${message}';
			case 'translation.translation': return 'Translation';
			case 'translation.needVerification': return 'Need Verification';
			case 'translation.needVerificationContent': return 'Please test the connection first before enabling AI translation';
			case 'translation.confirm': return 'Confirm';
			case 'translation.disclaimer': return 'Disclaimer';
			case 'translation.riskWarning': return 'Risk Warning';
			case 'translation.dureToRisk1': return 'Due to the text being generated by users, it may contain content that violates the content policy of the AI service provider';
			case 'translation.dureToRisk2': return 'Inappropriate content may lead to API key suspension or service termination';
			case 'translation.operationSuggestion': return 'Operation Suggestion';
			case 'translation.operationSuggestion1': return '1. Use before strictly reviewing the content to be translated';
			case 'translation.operationSuggestion2': return '2. Avoid translating content involving violence, adult content, etc.';
			case 'translation.apiConfig': return 'API Config';
			case 'translation.modifyConfigWillAutoCloseAITranslation': return 'Modify configuration will automatically close AI translation, need to test again after opening';
			case 'translation.apiAddress': return 'API Address';
			case 'translation.modelName': return 'Model Name';
			case 'translation.modelNameHintText': return 'For example: gpt-4-turbo';
			case 'translation.maxTokens': return 'Max Tokens';
			case 'translation.maxTokensHintText': return 'For example: 1024';
			case 'translation.temperature': return 'Temperature';
			case 'translation.temperatureHintText': return '0.0-2.0';
			case 'translation.clickTestButtonToVerifyAPIConnection': return 'Click test button to verify API connection validity';
			case 'translation.requestPreview': return 'Request Preview';
			case 'translation.enableAITranslation': return 'Enable AI';
			case 'translation.enabled': return 'Enabled';
			case 'translation.disabled': return 'Disabled';
			case 'translation.testing': return 'Testing...';
			case 'translation.testNow': return 'Test Now';
			case 'translation.connectionStatus': return 'Connection Status';
			case 'translation.success': return 'Success';
			case 'translation.failed': return 'Failed';
			case 'translation.information': return 'Information';
			case 'translation.viewRawResponse': return 'View Raw Response';
			case 'translation.pleaseCheckInputParametersFormat': return 'Please check input parameters format';
			case 'translation.pleaseFillInAPIAddressModelNameAndKey': return 'Please fill in API address, model name and key';
			case 'translation.pleaseFillInValidConfigurationParameters': return 'Please fill in valid configuration parameters';
			case 'translation.pleaseCompleteConnectionTest': return 'Please complete connection test';
			case 'translation.notConfigured': return 'Not Configured';
			case 'translation.apiEndpoint': return 'API Endpoint';
			case 'translation.configuredKey': return 'Configured Key';
			case 'translation.notConfiguredKey': return 'Not Configured Key';
			case 'translation.authenticationStatus': return 'Authentication Status';
			case 'translation.thisFieldCannotBeEmpty': return 'This field cannot be empty';
			case 'translation.apiKey': return 'API Key';
			case 'translation.apiKeyCannotBeEmpty': return 'API key cannot be empty';
			case 'translation.pleaseEnterValidNumber': return 'Please enter valid number';
			case 'translation.range': return 'Range';
			case 'translation.mustBeGreaterThan': return 'Must be greater than';
			case 'translation.invalidAPIResponse': return 'Invalid API response';
			case 'translation.connectionFailedForMessage': return ({required Object message}) => 'Connection failed: ${message}';
			case 'translation.aiTranslationNotEnabledHint': return 'AI translation is not enabled, please enable it in settings';
			case 'translation.goToSettings': return 'Go to Settings';
			case 'translation.disableAITranslation': return 'Disable AI Translation';
			case 'translation.currentValue': return 'Current Value';
			case 'translation.configureTranslationStrategy': return 'Configure Translation Strategy';
			case 'translation.advancedSettings': return 'Advanced Settings';
			case 'translation.translationPrompt': return 'Translation Prompt';
			case 'translation.promptHint': return 'Please enter translation prompt, use [TL] as the placeholder for the target language';
			case 'translation.promptHelperText': return 'The prompt must contain [TL] as the placeholder for the target language';
			case 'translation.promptMustContainTargetLang': return 'The prompt must contain [TL] placeholder';
			case 'translation.aiTranslationWillBeDisabled': return 'AI translation will be disabled';
			case 'translation.aiTranslationWillBeDisabledDueToConfigChange': return 'Due to the change of basic configuration, AI translation will be disabled';
			case 'translation.aiTranslationWillBeDisabledDueToPromptChange': return 'Due to the change of translation prompt, AI translation will be disabled';
			case 'translation.aiTranslationWillBeDisabledDueToParamChange': return 'Due to the change of parameter configuration, AI translation will be disabled';
			case 'translation.onlyOpenAIAPISupported': return 'Currently only supports OpenAI-compatible API format (application/json request body)';
			case 'translation.streamingTranslation': return 'Streaming Translation';
			case 'translation.streamingTranslationSupported': return 'Streaming Translation Supported';
			case 'translation.streamingTranslationNotSupported': return 'Streaming Translation Not Supported';
			case 'translation.streamingTranslationDescription': return 'Streaming translation can display results in real-time during the translation process, providing a better user experience';
			case 'translation.usingFullUrlWithHash': return 'Using full URL (ending with #)';
			case 'translation.baseUrlInputHelperText': return 'When ending with #, it will be used as the actual request address';
			case 'translation.currentActualUrl': return ({required Object url}) => 'Current actual URL: ${url}';
			case 'translation.urlEndingWithHashTip': return 'URL ending with # will be used directly without adding any suffix';
			case 'translation.streamingTranslationWarning': return 'Note: This feature requires API service support for streaming transmission, some models may not support it';
			case 'mediaPlayer.videoPlayerError': return 'Video Player Error';
			case 'mediaPlayer.videoLoadFailed': return 'Video Load Failed';
			case 'mediaPlayer.videoCodecNotSupported': return 'Video Codec Not Supported';
			case 'mediaPlayer.networkConnectionIssue': return 'Network Connection Issue';
			case 'mediaPlayer.insufficientPermission': return 'Insufficient Permission';
			case 'mediaPlayer.unsupportedVideoFormat': return 'Unsupported Video Format';
			case 'mediaPlayer.retry': return 'Retry';
			case 'mediaPlayer.externalPlayer': return 'External Player';
			case 'mediaPlayer.detailedErrorInfo': return 'Detailed Error Information';
			case 'mediaPlayer.format': return 'Format';
			case 'mediaPlayer.suggestion': return 'Suggestion';
			case 'mediaPlayer.androidWebmCompatibilityIssue': return 'Android devices have limited support for WEBM format. It is recommended to use an external player or download a player app that supports WEBM';
			case 'mediaPlayer.currentDeviceCodecNotSupported': return 'Current device does not support the codec for this video format';
			case 'mediaPlayer.checkNetworkConnection': return 'Please check your network connection and try again';
			case 'mediaPlayer.appMayLackMediaPermission': return 'The app may lack necessary media playback permissions';
			case 'mediaPlayer.tryOtherVideoPlayer': return 'Please try using other video players';
			case 'mediaPlayer.video': return 'VIDEO';
			case 'mediaPlayer.imageLoadFailed': return 'Image Load Failed';
			case 'mediaPlayer.unsupportedImageFormat': return 'Unsupported Image Format';
			case 'mediaPlayer.tryOtherViewer': return 'Please try using other viewers';
			case 'linkInputDialog.title': return 'Input Link';
			case 'linkInputDialog.supportedLinksHint': return ({required Object webName}) => 'Support intelligently identify multiple ${webName} links and quickly jump to the corresponding page in the app (separate links from other text with spaces)';
			case 'linkInputDialog.inputHint': return ({required Object webName}) => 'Please enter ${webName} link';
			case 'linkInputDialog.validatorEmptyLink': return 'Please enter link';
			case 'linkInputDialog.validatorNoIwaraLink': return ({required Object webName}) => 'No valid ${webName} link detected';
			case 'linkInputDialog.multipleLinksDetected': return 'Multiple links detected, please select one:';
			case 'linkInputDialog.notIwaraLink': return ({required Object webName}) => 'Not a valid ${webName} link';
			case 'linkInputDialog.linkParseError': return ({required Object error}) => 'Link parsing error: ${error}';
			case 'linkInputDialog.unsupportedLinkDialogTitle': return 'Unsupported Link';
			case 'linkInputDialog.unsupportedLinkDialogContent': return 'This link type cannot be opened directly in the app and needs to be accessed using an external browser.\n\nDo you want to open this link in a browser?';
			case 'linkInputDialog.openInBrowser': return 'Open in Browser';
			case 'linkInputDialog.confirmOpenBrowserDialogTitle': return 'Confirm Open Browser';
			case 'linkInputDialog.confirmOpenBrowserDialogContent': return 'The following link is about to be opened in an external browser:';
			case 'linkInputDialog.confirmContinueBrowserOpen': return 'Are you sure you want to continue?';
			case 'linkInputDialog.browserOpenFailed': return 'Failed to open link';
			case 'linkInputDialog.unsupportedLink': return 'Unsupported Link';
			case 'linkInputDialog.cancel': return 'Cancel';
			case 'linkInputDialog.confirm': return 'Open in Browser';
			case 'log.logManagement': return 'Log Management';
			case 'log.enableLogPersistence': return 'Enable Log Persistence';
			case 'log.enableLogPersistenceDesc': return 'Save logs to the database for analysis';
			case 'log.logDatabaseSizeLimit': return 'Log Database Size Limit';
			case 'log.logDatabaseSizeLimitDesc': return ({required Object size}) => 'Current: ${size}';
			case 'log.exportCurrentLogs': return 'Export Current Logs';
			case 'log.exportCurrentLogsDesc': return 'Export the current application logs to help developers diagnose problems';
			case 'log.exportHistoryLogs': return 'Export History Logs';
			case 'log.exportHistoryLogsDesc': return 'Export logs within a specified date range';
			case 'log.exportMergedLogs': return 'Export Merged Logs';
			case 'log.exportMergedLogsDesc': return 'Export merged logs within a specified date range';
			case 'log.showLogStats': return 'Show Log Stats';
			case 'log.logExportSuccess': return 'Log export success';
			case 'log.logExportFailed': return ({required Object error}) => 'Log export failed: ${error}';
			case 'log.showLogStatsDesc': return 'View statistics of various types of logs';
			case 'log.logExtractFailed': return ({required Object error}) => 'Failed to get log statistics: ${error}';
			case 'log.clearAllLogs': return 'Clear All Logs';
			case 'log.clearAllLogsDesc': return 'Clear all log data';
			case 'log.confirmClearAllLogs': return 'Confirm Clear';
			case 'log.confirmClearAllLogsDesc': return 'Are you sure you want to clear all log data? This operation cannot be undone.';
			case 'log.clearAllLogsSuccess': return 'Log cleared successfully';
			case 'log.clearAllLogsFailed': return ({required Object error}) => 'Failed to clear logs: ${error}';
			case 'log.unableToGetLogSizeInfo': return 'Unable to get log size information';
			case 'log.currentLogSize': return 'Current Log Size:';
			case 'log.logCount': return 'Log Count:';
			case 'log.logCountUnit': return 'logs';
			case 'log.logSizeLimit': return 'Log Size Limit:';
			case 'log.usageRate': return 'Usage Rate:';
			case 'log.exceedLimit': return 'Exceed Limit';
			case 'log.remaining': return 'Remaining';
			case 'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit': return 'Current log size exceeded, please clean old logs or increase log size limit';
			case 'log.currentLogSizeAlmostExceededPleaseCleanOldLogs': return 'Current log size almost exceeded, please clean old logs';
			case 'log.cleaningOldLogs': return 'Cleaning old logs...';
			case 'log.logCleaningCompleted': return 'Log cleaning completed';
			case 'log.logCleaningProcessMayNotBeCompleted': return 'Log cleaning process may not be completed';
			case 'log.cleanExceededLogs': return 'Clean exceeded logs';
			case 'log.noLogsToExport': return 'No logs to export';
			case 'log.exportingLogs': return 'Exporting logs...';
			case 'log.noHistoryLogsToExport': return 'No history logs to export, please try using the app for a while first';
			case 'log.selectLogDate': return 'Select Log Date';
			case 'log.today': return 'Today';
			case 'log.selectMergeRange': return 'Select Merge Range';
			case 'log.selectMergeRangeHint': return 'Please select the log time range to merge';
			case 'log.selectMergeRangeDays': return ({required Object days}) => 'Recent ${days} days';
			case 'log.logStats': return 'Log Stats';
			case 'log.todayLogs': return ({required Object count}) => 'Today Logs: ${count} logs';
			case 'log.recent7DaysLogs': return ({required Object count}) => 'Recent 7 Days Logs: ${count} logs';
			case 'log.totalLogs': return ({required Object count}) => 'Total Logs: ${count} logs';
			case 'log.setLogDatabaseSizeLimit': return 'Set Log Database Size Limit';
			case 'log.currentLogSizeWithSize': return ({required Object size}) => 'Current Log Size: ${size}';
			case 'log.warning': return 'Warning';
			case 'log.newSizeLimit': return ({required Object size}) => 'New size limit: ${size}';
			case 'log.confirmToContinue': return 'Confirm to continue';
			case 'log.logSizeLimitSetSuccess': return ({required Object size}) => 'Log size limit set to ${size}';
			default: return null;
		}
	}
}

