///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
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
	late final TranslationsTutorialEn tutorial = TranslationsTutorialEn._(_root);
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
	late final TranslationsNavigationOrderSettingsEn navigationOrderSettings = TranslationsNavigationOrderSettingsEn._(_root);
	late final TranslationsDisplaySettingsEn displaySettings = TranslationsDisplaySettingsEn._(_root);
	late final TranslationsLayoutSettingsEn layoutSettings = TranslationsLayoutSettingsEn._(_root);
	late final TranslationsMediaPlayerEn mediaPlayer = TranslationsMediaPlayerEn._(_root);
	late final TranslationsLinkInputDialogEn linkInputDialog = TranslationsLinkInputDialogEn._(_root);
	late final TranslationsLogEn log = TranslationsLogEn._(_root);
	late final TranslationsEmojiEn emoji = TranslationsEmojiEn._(_root);
	late final TranslationsSearchFilterEn searchFilter = TranslationsSearchFilterEn._(_root);
	late final TranslationsFirstTimeSetupEn firstTimeSetup = TranslationsFirstTimeSetupEn._(_root);
	late final TranslationsProxyHelperEn proxyHelper = TranslationsProxyHelperEn._(_root);
	late final TranslationsTagSelectorEn tagSelector = TranslationsTagSelectorEn._(_root);
	late final TranslationsAnime4kEn anime4k = TranslationsAnime4kEn._(_root);
}

// Path: tutorial
class TranslationsTutorialEn {
	TranslationsTutorialEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Special Follow Feature'
	String get specialFollowFeature => 'Special Follow Feature';

	/// en: 'This shows authors you follow specially. Go to video, gallery, or author detail pages, click the follow button, then select "Add as Special Follow".'
	String get specialFollowDescription => 'This shows authors you follow specially. Go to video, gallery, or author detail pages, click the follow button, then select "Add as Special Follow".';

	/// en: 'Example: Author Info Row'
	String get exampleAuthorInfoRow => 'Example: Author Info Row';

	/// en: 'Author Name'
	String get authorName => 'Author Name';

	/// en: 'Followed'
	String get followed => 'Followed';

	/// en: 'Click "Followed" button → Select "Add as Special Follow"'
	String get specialFollowInstruction => 'Click "Followed" button → Select "Add as Special Follow"';

	/// en: 'Follow Button Locations:'
	String get followButtonLocations => 'Follow Button Locations:';

	/// en: 'Video Detail Page'
	String get videoDetailPage => 'Video Detail Page';

	/// en: 'Gallery Detail Page'
	String get galleryDetailPage => 'Gallery Detail Page';

	/// en: 'Author Detail Page'
	String get authorDetailPage => 'Author Detail Page';

	/// en: 'After Special Follow, you can quickly view the latest content of the author!'
	String get afterSpecialFollow => 'After Special Follow, you can quickly view the latest content of the author!';

	/// en: 'Special Follow list can be managed in Sidebar - Following List - Special Follow List page'
	String get specialFollowManagementTip => 'Special Follow list can be managed in Sidebar - Following List - Special Follow List page';

	/// en: 'Skip'
	String get skip => 'Skip';
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sort'
	String get sort => 'Sort';

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

	/// en: 'Loading more...'
	String get loadingMore => 'Loading more...';

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

	/// en: 'Markdown Syntax Help'
	String get markdownSyntaxHelp => 'Markdown Syntax Help';

	/// en: 'Preview Content'
	String get previewContent => 'Preview Content';

	/// en: '${current}/${max}'
	String characterCount({required Object current, required Object max}) => '${current}/${max}';

	/// en: 'Exceeds max length limit (${max})'
	String exceedsMaxLengthLimit({required Object max}) => 'Exceeds max length limit (${max})';

	/// en: 'Agree to Community Rules'
	String get agreeToCommunityRules => 'Agree to Community Rules';

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

	/// en: 'Last seen ${str}'
	String lastSeenAt({required Object str}) => 'Last seen ${str}';

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

	/// en: 'Create Time Desc'
	String get createTimeDesc => 'Create Time Desc';

	/// en: 'Create Time Asc'
	String get createTimeAsc => 'Create Time Asc';

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

	/// en: 'External Link Warning'
	String get externalLinkWarning => 'External Link Warning';

	/// en: 'You are about to open an external link that is not part of iwara.tv. Please be cautious and ensure the link is safe before proceeding.'
	String get externalLinkWarningMessage => 'You are about to open an external link that is not part of iwara.tv. Please be cautious and ensure the link is safe before proceeding.';

	/// en: 'Continue'
	String get continueToExternalLink => 'Continue';

	/// en: 'Cancel'
	String get cancelExternalLink => 'Cancel';
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

	/// en: 'Introduction'
	String get personalIntroduction => 'Introduction';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'List View Mode'
	String get listViewMode => 'List View Mode';

	/// en: 'Preview Effect'
	String get previewEffect => 'Preview Effect';

	/// en: 'Use Traditional Pagination Mode'
	String get useTraditionalPaginationMode => 'Use Traditional Pagination Mode';

	/// en: 'Enable traditional pagination mode, disable waterfall mode. Takes effect after re-rendering the page or restarting the app'
	String get useTraditionalPaginationModeDesc => 'Enable traditional pagination mode, disable waterfall mode. Takes effect after re-rendering the page or restarting the app';

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

	/// en: 'Vertical Screen Orientation After Entering Fullscreen'
	String get fullscreenOrientation => 'Vertical Screen Orientation After Entering Fullscreen';

	/// en: 'This setting determines the default screen orientation when entering fullscreen (mobile only)'
	String get fullscreenOrientationDesc => 'This setting determines the default screen orientation when entering fullscreen (mobile only)';

	/// en: 'Left Landscape'
	String get fullscreenOrientationLeftLandscape => 'Left Landscape';

	/// en: 'Right Landscape'
	String get fullscreenOrientationRightLandscape => 'Right Landscape';

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

	/// en: 'Horizontal Swipe to Seek'
	String get enableHorizontalDragSeek => 'Horizontal Swipe to Seek';

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

	late final TranslationsSettingsForumSettingsEn forumSettings = TranslationsSettingsForumSettingsEn._(_root);
	late final TranslationsSettingsChatSettingsEn chatSettings = TranslationsSettingsChatSettingsEn._(_root);

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

	/// en: 'Content Distribution Strategy'
	String get cdnDistributionStrategy => 'Content Distribution Strategy';

	/// en: 'Select video source server distribution strategy to optimize loading speed'
	String get cdnDistributionStrategyDesc => 'Select video source server distribution strategy to optimize loading speed';

	/// en: 'Distribution Strategy'
	String get cdnDistributionStrategyLabel => 'Distribution Strategy';

	/// en: 'No Change (Use Original Server)'
	String get cdnDistributionStrategyNoChange => 'No Change (Use Original Server)';

	/// en: 'Auto Select (Fastest Server)'
	String get cdnDistributionStrategyAuto => 'Auto Select (Fastest Server)';

	/// en: 'Specify Server'
	String get cdnDistributionStrategySpecial => 'Specify Server';

	/// en: 'Specify Server'
	String get cdnSpecialServer => 'Specify Server';

	/// en: 'Please click the button below to refresh the server list'
	String get cdnRefreshServerListHint => 'Please click the button below to refresh the server list';

	/// en: 'Refresh'
	String get cdnRefreshButton => 'Refresh';

	/// en: 'Fast Ring Servers'
	String get cdnFastRingServers => 'Fast Ring Servers';

	/// en: 'Refresh server list'
	String get cdnRefreshServerListTooltip => 'Refresh server list';

	/// en: 'Speed Test'
	String get cdnSpeedTestButton => 'Speed Test';

	/// en: 'Testing (${count})'
	String cdnSpeedTestingButton({required Object count}) => 'Testing (${count})';

	/// en: 'No server data available, please click the refresh button'
	String get cdnNoServerDataHint => 'No server data available, please click the refresh button';

	/// en: 'Testing'
	String get cdnTestingStatus => 'Testing';

	/// en: 'Unreachable'
	String get cdnUnreachableStatus => 'Unreachable';

	/// en: 'Not Tested'
	String get cdnNotTestedStatus => 'Not Tested';

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

	late final TranslationsVideoDetailLocalInfoEn localInfo = TranslationsVideoDetailLocalInfoEn._(_root);

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

	late final TranslationsVideoDetailPlayerEn player = TranslationsVideoDetailPlayerEn._(_root);
	late final TranslationsVideoDetailSkeletonEn skeleton = TranslationsVideoDetailSkeletonEn._(_root);
	late final TranslationsVideoDetailCastEn cast = TranslationsVideoDetailCastEn._(_root);
	late final TranslationsVideoDetailLikeAvatarsEn likeAvatars = TranslationsVideoDetailLikeAvatarsEn._(_root);
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

	/// en: 'Forum post approved'
	String get kApprovedForumPost => 'Forum post approved';

	/// en: 'Content review rejected'
	String get kRejectedContent => 'Content review rejected';

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

	/// en: 'View Download List'
	String get viewDownloadList => 'View Download List';

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

	/// en: 'Play Locally'
	String get playLocally => 'Play Locally';

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

	/// en: 'Already downloaded with the same quality, continue downloading?'
	String get alreadyDownloadedWithQuality => 'Already downloaded with the same quality, continue downloading?';

	/// en: 'Already downloaded with qualities: ${qualities}, continue downloading?'
	String alreadyDownloadedWithQualities({required Object qualities}) => 'Already downloaded with qualities: ${qualities}, continue downloading?';

	/// en: 'Other qualities'
	String get otherQualities => 'Other qualities';
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

	/// en: 'Current Service'
	String get currentService => 'Current Service';

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

	/// en: 'For example: 32000'
	String get maxTokensHintText => 'For example: 32000';

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

	/// en: 'Translation Service'
	String get translationService => 'Translation Service';

	/// en: 'Select your preferred translation service'
	String get translationServiceDescription => 'Select your preferred translation service';

	/// en: 'Google Translation'
	String get googleTranslation => 'Google Translation';

	/// en: 'Free online translation service supporting multiple languages'
	String get googleTranslationDescription => 'Free online translation service supporting multiple languages';

	/// en: 'AI Translation'
	String get aiTranslation => 'AI Translation';

	/// en: 'Intelligent translation service based on large language models'
	String get aiTranslationDescription => 'Intelligent translation service based on large language models';

	/// en: 'DeepLX Translation'
	String get deeplxTranslation => 'DeepLX Translation';

	/// en: 'Open source implementation of DeepL translation, providing high-quality translation'
	String get deeplxTranslationDescription => 'Open source implementation of DeepL translation, providing high-quality translation';

	/// en: 'Features'
	String get googleTranslationFeatures => 'Features';

	/// en: 'Free to use'
	String get freeToUse => 'Free to use';

	/// en: 'No configuration required, ready to use'
	String get freeToUseDescription => 'No configuration required, ready to use';

	/// en: 'Fast response'
	String get fastResponse => 'Fast response';

	/// en: 'Fast translation speed with low latency'
	String get fastResponseDescription => 'Fast translation speed with low latency';

	/// en: 'Stable and reliable'
	String get stableAndReliable => 'Stable and reliable';

	/// en: 'Based on Google official API'
	String get stableAndReliableDescription => 'Based on Google official API';

	/// en: 'Enabled - Default translation service'
	String get enabledDefaultService => 'Enabled - Default translation service';

	/// en: 'Not enabled'
	String get notEnabled => 'Not enabled';

	/// en: 'DeepLX Translation Service'
	String get deeplxTranslationService => 'DeepLX Translation Service';

	/// en: 'DeepLX is an open source implementation of DeepL translation, supporting Free, Pro and Official endpoint modes'
	String get deeplxDescription => 'DeepLX is an open source implementation of DeepL translation, supporting Free, Pro and Official endpoint modes';

	/// en: 'Server Address'
	String get serverAddress => 'Server Address';

	/// en: 'https://api.deeplx.org'
	String get serverAddressHint => 'https://api.deeplx.org';

	/// en: 'Base address of DeepLX server'
	String get serverAddressHelperText => 'Base address of DeepLX server';

	/// en: 'Endpoint Type'
	String get endpointType => 'Endpoint Type';

	/// en: 'Free - Free endpoint, may have rate limits'
	String get freeEndpoint => 'Free - Free endpoint, may have rate limits';

	/// en: 'Pro - Requires dl_session, more stable'
	String get proEndpoint => 'Pro - Requires dl_session, more stable';

	/// en: 'Official - Official API format'
	String get officialEndpoint => 'Official - Official API format';

	/// en: 'Final Request URL'
	String get finalRequestUrl => 'Final Request URL';

	/// en: 'API Key (Optional)'
	String get apiKeyOptional => 'API Key (Optional)';

	/// en: 'For accessing protected DeepLX services'
	String get apiKeyOptionalHint => 'For accessing protected DeepLX services';

	/// en: 'Some DeepLX services require API Key for authentication'
	String get apiKeyOptionalHelperText => 'Some DeepLX services require API Key for authentication';

	/// en: 'DL Session'
	String get dlSession => 'DL Session';

	/// en: 'dl_session parameter required for Pro mode'
	String get dlSessionHint => 'dl_session parameter required for Pro mode';

	/// en: 'Session parameter required for Pro endpoint, obtained from DeepL Pro account'
	String get dlSessionHelperText => 'Session parameter required for Pro endpoint, obtained from DeepL Pro account';

	/// en: 'Pro mode requires dl_session'
	String get proModeRequiresDlSession => 'Pro mode requires dl_session';

	/// en: 'Click test button to verify DeepLX API connection'
	String get clickTestButtonToVerifyDeepLXAPI => 'Click test button to verify DeepLX API connection';

	/// en: 'Enable DeepLX Translation'
	String get enableDeepLXTranslation => 'Enable DeepLX Translation';

	/// en: 'DeepLX translation will be disabled due to configuration changes'
	String get deepLXTranslationWillBeDisabled => 'DeepLX translation will be disabled due to configuration changes';

	/// en: 'Translated Result'
	String get translatedResult => 'Translated Result';

	/// en: 'Test successful'
	String get testSuccess => 'Test successful';

	/// en: 'Please fill in DeepLX server address'
	String get pleaseFillInDeepLXServerAddress => 'Please fill in DeepLX server address';

	/// en: 'Invalid API response format'
	String get invalidAPIResponseFormat => 'Invalid API response format';

	/// en: 'Translation service returned error or empty result'
	String get translationServiceReturnedError => 'Translation service returned error or empty result';

	/// en: 'Connection failed'
	String get connectionFailed => 'Connection failed';

	/// en: 'Translation failed'
	String get translationFailed => 'Translation failed';

	/// en: 'AI translation failed'
	String get aiTranslationFailed => 'AI translation failed';

	/// en: 'DeepLX translation failed'
	String get deeplxTranslationFailed => 'DeepLX translation failed';

	/// en: 'AI translation test failed'
	String get aiTranslationTestFailed => 'AI translation test failed';

	/// en: 'DeepLX translation test failed'
	String get deeplxTranslationTestFailed => 'DeepLX translation test failed';

	/// en: 'Streaming translation timeout, forcing resource cleanup'
	String get streamingTranslationTimeout => 'Streaming translation timeout, forcing resource cleanup';

	/// en: 'Translation request timeout'
	String get translationRequestTimeout => 'Translation request timeout';

	/// en: 'Streaming translation data reception timeout'
	String get streamingTranslationDataTimeout => 'Streaming translation data reception timeout';

	/// en: 'Data reception timeout'
	String get dataReceptionTimeout => 'Data reception timeout';

	/// en: 'Error parsing stream data'
	String get streamDataParseError => 'Error parsing stream data';

	/// en: 'Streaming translation failed'
	String get streamingTranslationFailed => 'Streaming translation failed';

	/// en: 'Fallback to normal translation also failed'
	String get fallbackTranslationFailed => 'Fallback to normal translation also failed';

	/// en: 'Translation Settings'
	String get translationSettings => 'Translation Settings';

	/// en: 'Enable Google Translation'
	String get enableGoogleTranslation => 'Enable Google Translation';
}

// Path: navigationOrderSettings
class TranslationsNavigationOrderSettingsEn {
	TranslationsNavigationOrderSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Navigation Order Settings'
	String get title => 'Navigation Order Settings';

	/// en: 'Custom Navigation Order'
	String get customNavigationOrder => 'Custom Navigation Order';

	/// en: 'Drag to adjust the display order of pages in the bottom navigation bar and sidebar'
	String get customNavigationOrderDesc => 'Drag to adjust the display order of pages in the bottom navigation bar and sidebar';

	/// en: 'Restart app required'
	String get restartRequired => 'Restart app required';

	/// en: 'Navigation Item Sorting'
	String get navigationItemSorting => 'Navigation Item Sorting';

	/// en: 'Done'
	String get done => 'Done';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Preview Effect'
	String get previewEffect => 'Preview Effect';

	/// en: 'Bottom Navigation Preview:'
	String get bottomNavigationPreview => 'Bottom Navigation Preview:';

	/// en: 'Sidebar Preview:'
	String get sidebarPreview => 'Sidebar Preview:';

	/// en: 'Confirm Reset Navigation Order'
	String get confirmResetNavigationOrder => 'Confirm Reset Navigation Order';

	/// en: 'Are you sure you want to reset the navigation order to default settings?'
	String get confirmResetNavigationOrderDesc => 'Are you sure you want to reset the navigation order to default settings?';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Browse popular video content'
	String get videoDescription => 'Browse popular video content';

	/// en: 'Browse images and galleries'
	String get galleryDescription => 'Browse images and galleries';

	/// en: 'View latest content from followed users'
	String get subscriptionDescription => 'View latest content from followed users';

	/// en: 'Participate in community discussions'
	String get forumDescription => 'Participate in community discussions';
}

// Path: displaySettings
class TranslationsDisplaySettingsEn {
	TranslationsDisplaySettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Display Settings'
	String get title => 'Display Settings';

	/// en: 'Layout Settings'
	String get layoutSettings => 'Layout Settings';

	/// en: 'Customize column count and breakpoint configuration'
	String get layoutSettingsDesc => 'Customize column count and breakpoint configuration';

	/// en: 'Grid Layout'
	String get gridLayout => 'Grid Layout';

	/// en: 'Navigation Order Settings'
	String get navigationOrderSettings => 'Navigation Order Settings';

	/// en: 'Custom Navigation Order'
	String get customNavigationOrder => 'Custom Navigation Order';

	/// en: 'Adjust the display order of pages in the bottom navigation bar and sidebar'
	String get customNavigationOrderDesc => 'Adjust the display order of pages in the bottom navigation bar and sidebar';
}

// Path: layoutSettings
class TranslationsLayoutSettingsEn {
	TranslationsLayoutSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Layout Settings'
	String get title => 'Layout Settings';

	/// en: 'Layout Configuration Description'
	String get descriptionTitle => 'Layout Configuration Description';

	/// en: 'The configuration here will determine the number of columns displayed in video and gallery list pages. You can choose auto mode to let the system automatically adjust based on screen width, or choose manual mode to fix the column count.'
	String get descriptionContent => 'The configuration here will determine the number of columns displayed in video and gallery list pages. You can choose auto mode to let the system automatically adjust based on screen width, or choose manual mode to fix the column count.';

	/// en: 'Layout Mode'
	String get layoutMode => 'Layout Mode';

	/// en: 'Reset'
	String get reset => 'Reset';

	/// en: 'Auto Mode'
	String get autoMode => 'Auto Mode';

	/// en: 'Automatically adjust based on screen width'
	String get autoModeDesc => 'Automatically adjust based on screen width';

	/// en: 'Manual Mode'
	String get manualMode => 'Manual Mode';

	/// en: 'Use fixed column count'
	String get manualModeDesc => 'Use fixed column count';

	/// en: 'Manual Settings'
	String get manualSettings => 'Manual Settings';

	/// en: 'Fixed Columns'
	String get fixedColumns => 'Fixed Columns';

	/// en: 'columns'
	String get columns => 'columns';

	/// en: 'Breakpoint Configuration'
	String get breakpointConfig => 'Breakpoint Configuration';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Default Columns'
	String get defaultColumns => 'Default Columns';

	/// en: 'Default display for large screens'
	String get defaultColumnsDesc => 'Default display for large screens';

	/// en: 'Preview Effect'
	String get previewEffect => 'Preview Effect';

	/// en: 'Screen Width'
	String get screenWidth => 'Screen Width';

	/// en: 'Add Breakpoint'
	String get addBreakpoint => 'Add Breakpoint';

	/// en: 'Edit Breakpoint'
	String get editBreakpoint => 'Edit Breakpoint';

	/// en: 'Delete Breakpoint'
	String get deleteBreakpoint => 'Delete Breakpoint';

	/// en: 'Screen Width'
	String get screenWidthLabel => 'Screen Width';

	/// en: '600'
	String get screenWidthHint => '600';

	/// en: 'Columns'
	String get columnsLabel => 'Columns';

	/// en: '3'
	String get columnsHint => '3';

	/// en: 'Please enter width'
	String get enterWidth => 'Please enter width';

	/// en: 'Please enter valid width'
	String get enterValidWidth => 'Please enter valid width';

	/// en: 'Width cannot exceed 9999'
	String get widthCannotExceed9999 => 'Width cannot exceed 9999';

	/// en: 'Breakpoint already exists'
	String get breakpointAlreadyExists => 'Breakpoint already exists';

	/// en: 'Please enter columns'
	String get enterColumns => 'Please enter columns';

	/// en: 'Please enter valid columns'
	String get enterValidColumns => 'Please enter valid columns';

	/// en: 'Columns cannot exceed 12'
	String get columnsCannotExceed12 => 'Columns cannot exceed 12';

	/// en: 'Breakpoint already exists'
	String get breakpointConflict => 'Breakpoint already exists';

	/// en: 'Reset Layout Settings'
	String get confirmResetLayoutSettings => 'Reset Layout Settings';

	/// en: 'Are you sure you want to reset all layout settings to default values?\n\nWill restore to:\n• Auto mode\n• Default breakpoint configuration'
	String get confirmResetLayoutSettingsDesc => 'Are you sure you want to reset all layout settings to default values?\n\nWill restore to:\n• Auto mode\n• Default breakpoint configuration';

	/// en: 'Reset to Defaults'
	String get resetToDefaults => 'Reset to Defaults';

	/// en: 'Delete Breakpoint'
	String get confirmDeleteBreakpoint => 'Delete Breakpoint';

	/// en: 'Are you sure you want to delete the ${width}px breakpoint?'
	String confirmDeleteBreakpointDesc({required Object width}) => 'Are you sure you want to delete the ${width}px breakpoint?';

	/// en: 'No custom breakpoints, using default columns'
	String get noCustomBreakpoints => 'No custom breakpoints, using default columns';

	/// en: 'Breakpoint Range'
	String get breakpointRange => 'Breakpoint Range';

	/// en: '${range}px'
	String breakpointRangeDesc({required Object range}) => '${range}px';

	/// en: '≤${width}px'
	String breakpointRangeDescFirst({required Object width}) => '≤${width}px';

	/// en: '${start}-${end}px'
	String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';
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

	/// en: 'Local'
	String get local => 'Local';

	/// en: 'Unknown'
	String get unknown => 'Unknown';

	/// en: 'Local video path is empty'
	String get localVideoPathEmpty => 'Local video path is empty';

	/// en: 'Local video file does not exist: ${path}'
	String localVideoFileNotExists({required Object path}) => 'Local video file does not exist: ${path}';

	/// en: 'Unable to play local video: ${error}'
	String unableToPlayLocalVideo({required Object error}) => 'Unable to play local video: ${error}';

	/// en: 'Drop video file here to play'
	String get dropVideoFileHere => 'Drop video file here to play';

	/// en: 'Supported formats: MP4, MKV, AVI, MOV, WEBM, etc.'
	String get supportedFormats => 'Supported formats: MP4, MKV, AVI, MOV, WEBM, etc.';

	/// en: 'No supported video file found'
	String get noSupportedVideoFile => 'No supported video file found';

	/// en: 'Video link open failed, retrying'
	String get retryingOpenVideoLink => 'Video link open failed, retrying';

	/// en: 'Unable to load decoder: ${event}. Try switching to software decoding in player settings and re-enter the page'
	String decoderOpenFailedWithSuggestion({required Object event}) => 'Unable to load decoder: ${event}. Try switching to software decoding in player settings and re-enter the page';

	/// en: 'Video load error: ${event}'
	String videoLoadErrorWithDetail({required Object event}) => 'Video load error: ${event}';

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

// Path: emoji
class TranslationsEmojiEn {
	TranslationsEmojiEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Emoji'
	String get name => 'Emoji';

	/// en: 'Size'
	String get size => 'Size';

	/// en: 'Small'
	String get small => 'Small';

	/// en: 'Medium'
	String get medium => 'Medium';

	/// en: 'Large'
	String get large => 'Large';

	/// en: 'Extra Large'
	String get extraLarge => 'Extra Large';

	/// en: 'Emoji link copied'
	String get copyEmojiLinkSuccess => 'Emoji link copied';

	/// en: 'Emoji Preview'
	String get preview => 'Emoji Preview';

	/// en: 'Emoji Library'
	String get library => 'Emoji Library';

	/// en: 'No emojis'
	String get noEmojis => 'No emojis';

	/// en: 'Click the button in the top right to add emojis'
	String get clickToAddEmojis => 'Click the button in the top right to add emojis';

	/// en: 'Add Emojis'
	String get addEmojis => 'Add Emojis';

	/// en: 'Image Preview'
	String get imagePreview => 'Image Preview';

	/// en: 'Image load failed'
	String get imageLoadFailed => 'Image load failed';

	/// en: 'Loading...'
	String get loading => 'Loading...';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Delete Image'
	String get deleteImage => 'Delete Image';

	/// en: 'Are you sure you want to delete this image?'
	String get confirmDeleteImage => 'Are you sure you want to delete this image?';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Batch Delete'
	String get batchDelete => 'Batch Delete';

	/// en: 'Are you sure you want to delete the selected ${count} images? This operation cannot be undone.'
	String confirmBatchDelete({required Object count}) => 'Are you sure you want to delete the selected ${count} images? This operation cannot be undone.';

	/// en: 'Successfully deleted'
	String get deleteSuccess => 'Successfully deleted';

	/// en: 'Add Image'
	String get addImage => 'Add Image';

	/// en: 'Add by URL'
	String get addImageByUrl => 'Add by URL';

	/// en: 'Add Image URL'
	String get addImageUrl => 'Add Image URL';

	/// en: 'Image URL'
	String get imageUrl => 'Image URL';

	/// en: 'Please enter image URL'
	String get enterImageUrl => 'Please enter image URL';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Batch Import'
	String get batchImport => 'Batch Import';

	/// en: 'Please enter JSON format URL array:'
	String get enterJsonUrlArray => 'Please enter JSON format URL array:';

	/// en: 'Format example:\n["url1", "url2", "url3"]'
	String get formatExample => 'Format example:\n["url1", "url2", "url3"]';

	/// en: 'Please paste JSON format URL array'
	String get pasteJsonUrlArray => 'Please paste JSON format URL array';

	/// en: 'Import'
	String get import => 'Import';

	/// en: 'Successfully imported ${count} images'
	String importSuccess({required Object count}) => 'Successfully imported ${count} images';

	/// en: 'JSON format error, please check input'
	String get jsonFormatError => 'JSON format error, please check input';

	/// en: 'Create Emoji Group'
	String get createGroup => 'Create Emoji Group';

	/// en: 'Group Name'
	String get groupName => 'Group Name';

	/// en: 'Please enter group name'
	String get enterGroupName => 'Please enter group name';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Edit Group Name'
	String get editGroupName => 'Edit Group Name';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete Group'
	String get deleteGroup => 'Delete Group';

	/// en: 'Are you sure you want to delete this emoji group? All images in the group will also be deleted.'
	String get confirmDeleteGroup => 'Are you sure you want to delete this emoji group? All images in the group will also be deleted.';

	/// en: '${count} images'
	String imageCount({required Object count}) => '${count} images';

	/// en: 'Select Emoji'
	String get selectEmoji => 'Select Emoji';

	/// en: 'No emojis in this group'
	String get noEmojisInGroup => 'No emojis in this group';

	/// en: 'Go to settings to add emojis'
	String get goToSettingsToAddEmojis => 'Go to settings to add emojis';

	/// en: 'Emoji Management'
	String get emojiManagement => 'Emoji Management';

	/// en: 'Manage emoji groups and images'
	String get manageEmojiGroupsAndImages => 'Manage emoji groups and images';

	/// en: 'Upload Local Images'
	String get uploadLocalImages => 'Upload Local Images';

	/// en: 'Uploading Images'
	String get uploadingImages => 'Uploading Images';

	/// en: 'Uploading ${count} images, please wait...'
	String uploadingImagesProgress({required Object count}) => 'Uploading ${count} images, please wait...';

	/// en: 'Please do not close this dialog'
	String get doNotCloseDialog => 'Please do not close this dialog';

	/// en: 'Successfully uploaded ${count} images'
	String uploadSuccess({required Object count}) => 'Successfully uploaded ${count} images';

	/// en: 'Failed ${count}'
	String uploadFailed({required Object count}) => 'Failed ${count}';

	/// en: 'Image upload failed, please check network connection or file format'
	String get uploadFailedMessage => 'Image upload failed, please check network connection or file format';

	/// en: 'Error occurred during upload: ${error}'
	String uploadErrorMessage({required Object error}) => 'Error occurred during upload: ${error}';
}

// Path: searchFilter
class TranslationsSearchFilterEn {
	TranslationsSearchFilterEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select Field'
	String get selectField => 'Select Field';

	/// en: 'Add'
	String get add => 'Add';

	/// en: 'Clear'
	String get clear => 'Clear';

	/// en: 'Clear All'
	String get clearAll => 'Clear All';

	/// en: 'Generated Query'
	String get generatedQuery => 'Generated Query';

	/// en: 'Copy to Clipboard'
	String get copyToClipboard => 'Copy to Clipboard';

	/// en: 'Copied'
	String get copied => 'Copied';

	/// en: '${count} filters'
	String filterCount({required Object count}) => '${count} filters';

	/// en: 'Filter Settings'
	String get filterSettings => 'Filter Settings';

	/// en: 'Field'
	String get field => 'Field';

	/// en: 'Operator'
	String get operator => 'Operator';

	/// en: 'Language'
	String get language => 'Language';

	/// en: 'Value'
	String get value => 'Value';

	/// en: 'Date Range'
	String get dateRange => 'Date Range';

	/// en: 'Number Range'
	String get numberRange => 'Number Range';

	/// en: 'From'
	String get from => 'From';

	/// en: 'To'
	String get to => 'To';

	/// en: 'Date'
	String get date => 'Date';

	/// en: 'Number'
	String get number => 'Number';

	/// en: 'Boolean'
	String get boolean => 'Boolean';

	/// en: 'Tags'
	String get tags => 'Tags';

	/// en: 'Select'
	String get select => 'Select';

	/// en: 'Click to select date'
	String get clickToSelectDate => 'Click to select date';

	/// en: 'Please enter valid number'
	String get pleaseEnterValidNumber => 'Please enter valid number';

	/// en: 'Please enter valid date format (YYYY-MM-DD)'
	String get pleaseEnterValidDate => 'Please enter valid date format (YYYY-MM-DD)';

	/// en: 'Start value must be less than end value'
	String get startValueMustBeLessThanEndValue => 'Start value must be less than end value';

	/// en: 'Start date must be before end date'
	String get startDateMustBeBeforeEndDate => 'Start date must be before end date';

	/// en: 'Please fill start value'
	String get pleaseFillStartValue => 'Please fill start value';

	/// en: 'Please fill end value'
	String get pleaseFillEndValue => 'Please fill end value';

	/// en: 'Range value format error'
	String get rangeValueFormatError => 'Range value format error';

	/// en: 'Contains'
	String get contains => 'Contains';

	/// en: 'Equals'
	String get equals => 'Equals';

	/// en: 'Not Equals'
	String get notEquals => 'Not Equals';

	/// en: '>'
	String get greaterThan => '>';

	/// en: '>='
	String get greaterEqual => '>=';

	/// en: '<'
	String get lessThan => '<';

	/// en: '<='
	String get lessEqual => '<=';

	/// en: 'Range'
	String get range => 'Range';

	/// en: 'Contains Any'
	String get kIn => 'Contains Any';

	/// en: 'Not Contains Any'
	String get notIn => 'Not Contains Any';

	/// en: 'Username'
	String get username => 'Username';

	/// en: 'Nickname'
	String get nickname => 'Nickname';

	/// en: 'Registration Date'
	String get registrationDate => 'Registration Date';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Title'
	String get title => 'Title';

	/// en: 'Body'
	String get body => 'Body';

	/// en: 'Author'
	String get author => 'Author';

	/// en: 'Publish Date'
	String get publishDate => 'Publish Date';

	/// en: 'Private'
	String get private => 'Private';

	/// en: 'Duration (seconds)'
	String get duration => 'Duration (seconds)';

	/// en: 'Likes'
	String get likes => 'Likes';

	/// en: 'Views'
	String get views => 'Views';

	/// en: 'Comments'
	String get comments => 'Comments';

	/// en: 'Rating'
	String get rating => 'Rating';

	/// en: 'Image Count'
	String get imageCount => 'Image Count';

	/// en: 'Video Count'
	String get videoCount => 'Video Count';

	/// en: 'Create Date'
	String get createDate => 'Create Date';

	/// en: 'Content'
	String get content => 'Content';

	/// en: 'All'
	String get all => 'All';

	/// en: 'Adult'
	String get adult => 'Adult';

	/// en: 'General'
	String get general => 'General';

	/// en: 'Yes'
	String get yes => 'Yes';

	/// en: 'No'
	String get no => 'No';

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Videos'
	String get videos => 'Videos';

	/// en: 'Images'
	String get images => 'Images';

	/// en: 'Posts'
	String get posts => 'Posts';

	/// en: 'Forum Threads'
	String get forumThreads => 'Forum Threads';

	/// en: 'Forum Posts'
	String get forumPosts => 'Forum Posts';

	/// en: 'Playlists'
	String get playlists => 'Playlists';

	late final TranslationsSearchFilterSortTypesEn sortTypes = TranslationsSearchFilterSortTypesEn._(_root);
}

// Path: firstTimeSetup
class TranslationsFirstTimeSetupEn {
	TranslationsFirstTimeSetupEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFirstTimeSetupWelcomeEn welcome = TranslationsFirstTimeSetupWelcomeEn._(_root);
	late final TranslationsFirstTimeSetupBasicEn basic = TranslationsFirstTimeSetupBasicEn._(_root);
	late final TranslationsFirstTimeSetupNetworkEn network = TranslationsFirstTimeSetupNetworkEn._(_root);
	late final TranslationsFirstTimeSetupThemeEn theme = TranslationsFirstTimeSetupThemeEn._(_root);
	late final TranslationsFirstTimeSetupPlayerEn player = TranslationsFirstTimeSetupPlayerEn._(_root);
	late final TranslationsFirstTimeSetupCompletionEn completion = TranslationsFirstTimeSetupCompletionEn._(_root);
	late final TranslationsFirstTimeSetupCommonEn common = TranslationsFirstTimeSetupCommonEn._(_root);
}

// Path: proxyHelper
class TranslationsProxyHelperEn {
	TranslationsProxyHelperEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'System proxy detected'
	String get systemProxyDetected => 'System proxy detected';

	/// en: 'Copied'
	String get copied => 'Copied';

	/// en: 'Copy'
	String get copy => 'Copy';
}

// Path: tagSelector
class TranslationsTagSelectorEn {
	TranslationsTagSelectorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select Tags'
	String get selectTags => 'Select Tags';

	/// en: 'Click to select tags'
	String get clickToSelectTags => 'Click to select tags';

	/// en: 'Add Tag'
	String get addTag => 'Add Tag';

	/// en: 'Remove Tag'
	String get removeTag => 'Remove Tag';

	/// en: 'Delete Tag'
	String get deleteTag => 'Delete Tag';

	/// en: 'First add tags, then click to select from existing tags'
	String get usageInstructions => 'First add tags, then click to select from existing tags';

	/// en: 'Usage Instructions'
	String get usageInstructionsTooltip => 'Usage Instructions';

	/// en: 'Add Tag'
	String get addTagTooltip => 'Add Tag';

	/// en: 'Remove Tag'
	String get removeTagTooltip => 'Remove Tag';

	/// en: 'Cancel Selection'
	String get cancelSelection => 'Cancel Selection';

	/// en: 'Select All'
	String get selectAll => 'Select All';

	/// en: 'Cancel Select All'
	String get cancelSelectAll => 'Cancel Select All';

	/// en: 'Delete'
	String get delete => 'Delete';
}

// Path: anime4k
class TranslationsAnime4kEn {
	TranslationsAnime4kEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Real-time video upscaling and denoising, improving animation video quality'
	String get realTimeVideoUpscalingAndDenoising => 'Real-time video upscaling and denoising, improving animation video quality';

	/// en: 'Anime4K Settings'
	String get settings => 'Anime4K Settings';

	/// en: 'Anime4K Preset'
	String get preset => 'Anime4K Preset';

	/// en: 'Disable Anime4K'
	String get disable => 'Disable Anime4K';

	/// en: 'Disable video enhancement effects'
	String get disableDescription => 'Disable video enhancement effects';

	/// en: 'High Quality Presets'
	String get highQualityPresets => 'High Quality Presets';

	/// en: 'Fast Presets'
	String get fastPresets => 'Fast Presets';

	/// en: 'Lightweight Presets'
	String get litePresets => 'Lightweight Presets';

	/// en: 'More Lightweight Presets'
	String get moreLitePresets => 'More Lightweight Presets';

	/// en: 'Custom Presets'
	String get customPresets => 'Custom Presets';

	late final TranslationsAnime4kPresetGroupsEn presetGroups = TranslationsAnime4kPresetGroupsEn._(_root);
	late final TranslationsAnime4kPresetDescriptionsEn presetDescriptions = TranslationsAnime4kPresetDescriptionsEn._(_root);
	late final TranslationsAnime4kPresetNamesEn presetNames = TranslationsAnime4kPresetNamesEn._(_root);

	/// en: '💡 Tip: Choose appropriate presets based on device performance. Low-end devices are recommended to use lightweight presets.'
	String get performanceTip => '💡 Tip: Choose appropriate presets based on device performance. Low-end devices are recommended to use lightweight presets.';
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

// Path: settings.forumSettings
class TranslationsSettingsForumSettingsEn {
	TranslationsSettingsForumSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Forum'
	String get name => 'Forum';

	/// en: 'Configure Your Forum Settings'
	String get configureYourForumSettings => 'Configure Your Forum Settings';
}

// Path: settings.chatSettings
class TranslationsSettingsChatSettingsEn {
	TranslationsSettingsChatSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Chat'
	String get name => 'Chat';

	/// en: 'Configure Your Chat Settings'
	String get configureYourChatSettings => 'Configure Your Chat Settings';
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

	/// en: 'Actual Download Path'
	String get actualDownloadPath => 'Actual Download Path';

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

	/// en: 'External App Private Directory'
	String get externalAppPrivateDirectory => 'External App Private Directory';

	/// en: 'External storage app private directory, user accessible, larger space'
	String get externalAppPrivateDirectoryDesc => 'External storage app private directory, user accessible, larger space';

	/// en: 'Internal App Private Directory'
	String get internalAppPrivateDirectory => 'Internal App Private Directory';

	/// en: 'App internal storage, no permissions required, smaller space'
	String get internalAppPrivateDirectoryDesc => 'App internal storage, no permissions required, smaller space';

	/// en: 'App Documents Directory'
	String get appDocumentsDirectory => 'App Documents Directory';

	/// en: 'App-specific documents directory, safe and reliable'
	String get appDocumentsDirectoryDesc => 'App-specific documents directory, safe and reliable';

	/// en: 'Downloads Folder'
	String get downloadsFolder => 'Downloads Folder';

	/// en: 'System default download directory'
	String get downloadsFolderDesc => 'System default download directory';

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

// Path: videoDetail.localInfo
class TranslationsVideoDetailLocalInfoEn {
	TranslationsVideoDetailLocalInfoEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Video Info'
	String get videoInfo => 'Video Info';

	/// en: 'Current Quality'
	String get currentQuality => 'Current Quality';

	/// en: 'Duration'
	String get duration => 'Duration';

	/// en: 'Resolution'
	String get resolution => 'Resolution';

	/// en: 'File Info'
	String get fileInfo => 'File Info';

	/// en: 'File Name'
	String get fileName => 'File Name';

	/// en: 'File Size'
	String get fileSize => 'File Size';

	/// en: 'File Path'
	String get filePath => 'File Path';

	/// en: 'Copy Path'
	String get copyPath => 'Copy Path';

	/// en: 'Open Folder'
	String get openFolder => 'Open Folder';

	/// en: 'Path copied to clipboard'
	String get pathCopiedToClipboard => 'Path copied to clipboard';

	/// en: 'Failed to open folder'
	String get openFolderFailed => 'Failed to open folder';
}

// Path: videoDetail.player
class TranslationsVideoDetailPlayerEn {
	TranslationsVideoDetailPlayerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Error while loading video source'
	String get errorWhileLoadingVideoSource => 'Error while loading video source';

	/// en: 'Error while setting up listeners'
	String get errorWhileSettingUpListeners => 'Error while setting up listeners';

	/// en: 'Server fault detected, automatically switched route and retrying'
	String get serverFaultDetectedAutoSwitched => 'Server fault detected, automatically switched route and retrying';
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

	/// en: 'Applying solution...'
	String get applyingSolution => 'Applying solution...';

	/// en: 'Adding listeners...'
	String get addingListeners => 'Adding listeners...';

	/// en: 'Successfully fetched video duration, starting to load video...'
	String get successFecthVideoDurationInfo => 'Successfully fetched video duration, starting to load video...';

	/// en: 'Loading completed'
	String get successFecthVideoHeightInfo => 'Loading completed';
}

// Path: videoDetail.cast
class TranslationsVideoDetailCastEn {
	TranslationsVideoDetailCastEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Cast'
	String get dlnaCast => 'Cast';

	/// en: 'Failed to start casting search: ${error}'
	String unableToStartCastingSearch({required Object error}) => 'Failed to start casting search: ${error}';

	/// en: 'Start casting to ${deviceName}'
	String startCastingTo({required Object deviceName}) => 'Start casting to ${deviceName}';

	/// en: 'Cast failed: ${error}\nPlease try to re-search for devices or switch networks'
	String castFailed({required Object error}) => 'Cast failed: ${error}\nPlease try to re-search for devices or switch networks';

	/// en: 'Cast stopped'
	String get castStopped => 'Cast stopped';

	late final TranslationsVideoDetailCastDeviceTypesEn deviceTypes = TranslationsVideoDetailCastDeviceTypesEn._(_root);

	/// en: 'Current platform does not support casting'
	String get currentPlatformNotSupported => 'Current platform does not support casting';

	/// en: 'Unable to get video URL, please try again later'
	String get unableToGetVideoUrl => 'Unable to get video URL, please try again later';

	/// en: 'Stop casting'
	String get stopCasting => 'Stop casting';

	late final TranslationsVideoDetailCastDlnaCastSheetEn dlnaCastSheet = TranslationsVideoDetailCastDlnaCastSheetEn._(_root);
}

// Path: videoDetail.likeAvatars
class TranslationsVideoDetailLikeAvatarsEn {
	TranslationsVideoDetailLikeAvatarsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Who's secretly liking'
	String get dialogTitle => 'Who\'s secretly liking';

	/// en: 'Curious who they are? Flip through this "Like Album"~'
	String get dialogDescription => 'Curious who they are? Flip through this "Like Album"~';

	/// en: 'Close'
	String get closeTooltip => 'Close';

	/// en: 'Retry'
	String get retry => 'Retry';

	/// en: 'No one has appeared here yet. Be the first!'
	String get noLikesYet => 'No one has appeared here yet. Be the first!';

	/// en: 'Page ${page} / ${totalPages} · Total ${totalCount} people'
	String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Page ${page} / ${totalPages} · Total ${totalCount} people';

	/// en: 'Previous Page'
	String get prevPage => 'Previous Page';

	/// en: 'Next Page'
	String get nextPage => 'Next Page';
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

	/// en: 'SSL handshake failed, please check your network'
	String get sslHandshakeFailed => 'SSL handshake failed, please check your network';

	/// en: 'Connection failed, please check your network'
	String get connectionFailed => 'Connection failed, please check your network';

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

	/// en: 'Failed to play locally'
	String get playLocallyFailed => 'Failed to play locally';

	/// en: 'Failed to play locally: ${message}'
	String playLocallyFailedWithMessage({required Object message}) => 'Failed to play locally: ${message}';

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

// Path: searchFilter.sortTypes
class TranslationsSearchFilterSortTypesEn {
	TranslationsSearchFilterSortTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Relevance'
	String get relevance => 'Relevance';

	/// en: 'Latest'
	String get latest => 'Latest';

	/// en: 'Views'
	String get views => 'Views';

	/// en: 'Likes'
	String get likes => 'Likes';
}

// Path: firstTimeSetup.welcome
class TranslationsFirstTimeSetupWelcomeEn {
	TranslationsFirstTimeSetupWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome'
	String get title => 'Welcome';

	/// en: 'Let's start your personalized setup journey'
	String get subtitle => 'Let\'s start your personalized setup journey';

	/// en: 'Just a few steps to tailor the best experience for you'
	String get description => 'Just a few steps to tailor the best experience for you';
}

// Path: firstTimeSetup.basic
class TranslationsFirstTimeSetupBasicEn {
	TranslationsFirstTimeSetupBasicEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Basic Settings'
	String get title => 'Basic Settings';

	/// en: 'Personalize your experience'
	String get subtitle => 'Personalize your experience';

	/// en: 'Choose the preferences that suit you'
	String get description => 'Choose the preferences that suit you';
}

// Path: firstTimeSetup.network
class TranslationsFirstTimeSetupNetworkEn {
	TranslationsFirstTimeSetupNetworkEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Network Settings'
	String get title => 'Network Settings';

	/// en: 'Configure network options'
	String get subtitle => 'Configure network options';

	/// en: 'Adjust based on your network environment'
	String get description => 'Adjust based on your network environment';

	/// en: 'A restart is required after successful configuration to take effect'
	String get tip => 'A restart is required after successful configuration to take effect';
}

// Path: firstTimeSetup.theme
class TranslationsFirstTimeSetupThemeEn {
	TranslationsFirstTimeSetupThemeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Theme Settings'
	String get title => 'Theme Settings';

	/// en: 'Choose your preferred appearance'
	String get subtitle => 'Choose your preferred appearance';

	/// en: 'Personalize your visual experience'
	String get description => 'Personalize your visual experience';
}

// Path: firstTimeSetup.player
class TranslationsFirstTimeSetupPlayerEn {
	TranslationsFirstTimeSetupPlayerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Player Settings'
	String get title => 'Player Settings';

	/// en: 'Configure playback controls'
	String get subtitle => 'Configure playback controls';

	/// en: 'Quickly set commonly used playback preferences'
	String get description => 'Quickly set commonly used playback preferences';
}

// Path: firstTimeSetup.completion
class TranslationsFirstTimeSetupCompletionEn {
	TranslationsFirstTimeSetupCompletionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Complete Setup'
	String get title => 'Complete Setup';

	/// en: 'You're ready to start your journey'
	String get subtitle => 'You\'re ready to start your journey';

	/// en: 'Please read and agree to the related agreements'
	String get description => 'Please read and agree to the related agreements';

	/// en: 'User Agreement and Community Rules'
	String get agreementTitle => 'User Agreement and Community Rules';

	/// en: 'Before using this app, please carefully read and agree to our user agreement and community rules. These terms help maintain a good environment.'
	String get agreementDesc => 'Before using this app, please carefully read and agree to our user agreement and community rules. These terms help maintain a good environment.';

	/// en: 'I have read and agree to the user agreement and community rules'
	String get checkboxTitle => 'I have read and agree to the user agreement and community rules';

	/// en: 'You cannot use the app if you disagree'
	String get checkboxSubtitle => 'You cannot use the app if you disagree';
}

// Path: firstTimeSetup.common
class TranslationsFirstTimeSetupCommonEn {
	TranslationsFirstTimeSetupCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'These settings can be changed anytime in Settings'
	String get settingsChangeableTip => 'These settings can be changed anytime in Settings';

	/// en: 'Please agree to the user agreement and community rules first'
	String get agreeAgreementSnackbar => 'Please agree to the user agreement and community rules first';
}

// Path: anime4k.presetGroups
class TranslationsAnime4kPresetGroupsEn {
	TranslationsAnime4kPresetGroupsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'High Quality'
	String get highQuality => 'High Quality';

	/// en: 'Fast'
	String get fast => 'Fast';

	/// en: 'Lite'
	String get lite => 'Lite';

	/// en: 'More Lite'
	String get moreLite => 'More Lite';

	/// en: 'Custom'
	String get custom => 'Custom';
}

// Path: anime4k.presetDescriptions
class TranslationsAnime4kPresetDescriptionsEn {
	TranslationsAnime4kPresetDescriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Suitable for most 1080p animations, especially those dealing with blur, resampling and compression artifacts. Provides the highest perceived quality.'
	String get mode_a_hq => 'Suitable for most 1080p animations, especially those dealing with blur, resampling and compression artifacts. Provides the highest perceived quality.';

	/// en: 'Suitable for animations with slight blur or ringing effects caused by scaling. Can effectively reduce ringing and aliasing.'
	String get mode_b_hq => 'Suitable for animations with slight blur or ringing effects caused by scaling. Can effectively reduce ringing and aliasing.';

	/// en: 'Suitable for high-quality sources (such as native 1080p animations or movies). Denoises and provides the highest PSNR.'
	String get mode_c_hq => 'Suitable for high-quality sources (such as native 1080p animations or movies). Denoises and provides the highest PSNR.';

	/// en: 'Enhanced version of Mode A, providing ultimate perceived quality and can reconstruct almost all degraded lines. May produce oversharpening or ringing.'
	String get mode_a_a_hq => 'Enhanced version of Mode A, providing ultimate perceived quality and can reconstruct almost all degraded lines. May produce oversharpening or ringing.';

	/// en: 'Enhanced version of Mode B, providing higher perceived quality, further optimizing lines and reducing artifacts.'
	String get mode_b_b_hq => 'Enhanced version of Mode B, providing higher perceived quality, further optimizing lines and reducing artifacts.';

	/// en: 'Perceived quality enhanced version of Mode C, maintaining high PSNR while attempting to reconstruct some line details.'
	String get mode_c_a_hq => 'Perceived quality enhanced version of Mode C, maintaining high PSNR while attempting to reconstruct some line details.';

	/// en: 'Fast version of Mode A, balancing quality and performance, suitable for most 1080p animations.'
	String get mode_a_fast => 'Fast version of Mode A, balancing quality and performance, suitable for most 1080p animations.';

	/// en: 'Fast version of Mode B, for handling slight artifacts and ringing with lower overhead.'
	String get mode_b_fast => 'Fast version of Mode B, for handling slight artifacts and ringing with lower overhead.';

	/// en: 'Fast version of Mode C, for fast denoising and upscaling of high-quality sources.'
	String get mode_c_fast => 'Fast version of Mode C, for fast denoising and upscaling of high-quality sources.';

	/// en: 'Fast version of Mode A+A, pursuing higher perceived quality in performance-constrained devices.'
	String get mode_a_a_fast => 'Fast version of Mode A+A, pursuing higher perceived quality in performance-constrained devices.';

	/// en: 'Fast version of Mode B+B, providing enhanced line repair and artifact processing for performance-constrained devices.'
	String get mode_b_b_fast => 'Fast version of Mode B+B, providing enhanced line repair and artifact processing for performance-constrained devices.';

	/// en: 'Fast version of Mode C+A, performing fast processing of high-quality sources while providing light line repair.'
	String get mode_c_a_fast => 'Fast version of Mode C+A, performing fast processing of high-quality sources while providing light line repair.';

	/// en: 'Ultra-fast x2 upscaling using only the fastest CNN model, no repair and denoising, minimal performance overhead.'
	String get upscale_only_s => 'Ultra-fast x2 upscaling using only the fastest CNN model, no repair and denoising, minimal performance overhead.';

	/// en: 'Fast upscaling and deblurring using traditional non-CNN algorithms, better than default player algorithms with very low performance overhead.'
	String get upscale_deblur_fast => 'Fast upscaling and deblurring using traditional non-CNN algorithms, better than default player algorithms with very low performance overhead.';

	/// en: 'Repair only using the fastest CNN model, no upscaling. Suitable for native resolution playback where you want to improve quality.'
	String get restore_s_only => 'Repair only using the fastest CNN model, no upscaling. Suitable for native resolution playback where you want to improve quality.';

	/// en: 'Fast denoising using traditional bilateral filtering, extremely fast, suitable for processing light noise.'
	String get denoise_bilateral_fast => 'Fast denoising using traditional bilateral filtering, extremely fast, suitable for processing light noise.';

	/// en: 'Fast upscaling using traditional algorithms, very low performance overhead, better than player defaults.'
	String get upscale_non_cnn => 'Fast upscaling using traditional algorithms, very low performance overhead, better than player defaults.';

	/// en: 'Mode A (Fast) + Line darkening, adding line darkening effects on top of fast mode A for more prominent, stylized lines.'
	String get mode_a_fast_darken => 'Mode A (Fast) + Line darkening, adding line darkening effects on top of fast mode A for more prominent, stylized lines.';

	/// en: 'Mode A (HQ) + Line thinning, adding line thinning effects on top of high quality mode A for more refined appearance.'
	String get mode_a_hq_thin => 'Mode A (HQ) + Line thinning, adding line thinning effects on top of high quality mode A for more refined appearance.';
}

// Path: anime4k.presetNames
class TranslationsAnime4kPresetNamesEn {
	TranslationsAnime4kPresetNamesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Mode A (HQ)'
	String get mode_a_hq => 'Mode A (HQ)';

	/// en: 'Mode B (HQ)'
	String get mode_b_hq => 'Mode B (HQ)';

	/// en: 'Mode C (HQ)'
	String get mode_c_hq => 'Mode C (HQ)';

	/// en: 'Mode A+A (HQ)'
	String get mode_a_a_hq => 'Mode A+A (HQ)';

	/// en: 'Mode B+B (HQ)'
	String get mode_b_b_hq => 'Mode B+B (HQ)';

	/// en: 'Mode C+A (HQ)'
	String get mode_c_a_hq => 'Mode C+A (HQ)';

	/// en: 'Mode A (Fast)'
	String get mode_a_fast => 'Mode A (Fast)';

	/// en: 'Mode B (Fast)'
	String get mode_b_fast => 'Mode B (Fast)';

	/// en: 'Mode C (Fast)'
	String get mode_c_fast => 'Mode C (Fast)';

	/// en: 'Mode A+A (Fast)'
	String get mode_a_a_fast => 'Mode A+A (Fast)';

	/// en: 'Mode B+B (Fast)'
	String get mode_b_b_fast => 'Mode B+B (Fast)';

	/// en: 'Mode C+A (Fast)'
	String get mode_c_a_fast => 'Mode C+A (Fast)';

	/// en: 'CNN Upscaling (Ultra Fast)'
	String get upscale_only_s => 'CNN Upscaling (Ultra Fast)';

	/// en: 'Upscaling & Deblurring (Fast)'
	String get upscale_deblur_fast => 'Upscaling & Deblurring (Fast)';

	/// en: 'Restoration (Ultra Fast)'
	String get restore_s_only => 'Restoration (Ultra Fast)';

	/// en: 'Bilateral Denoising (Ultra Fast)'
	String get denoise_bilateral_fast => 'Bilateral Denoising (Ultra Fast)';

	/// en: 'Non-CNN Upscaling (Ultra Fast)'
	String get upscale_non_cnn => 'Non-CNN Upscaling (Ultra Fast)';

	/// en: 'Mode A (Fast) + Line Darkening'
	String get mode_a_fast_darken => 'Mode A (Fast) + Line Darkening';

	/// en: 'Mode A (HQ) + Line Thinning'
	String get mode_a_hq_thin => 'Mode A (HQ) + Line Thinning';
}

// Path: videoDetail.cast.deviceTypes
class TranslationsVideoDetailCastDeviceTypesEn {
	TranslationsVideoDetailCastDeviceTypesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Media Player'
	String get mediaRenderer => 'Media Player';

	/// en: 'Media Server'
	String get mediaServer => 'Media Server';

	/// en: 'Router'
	String get internetGatewayDevice => 'Router';

	/// en: 'Basic Device'
	String get basicDevice => 'Basic Device';

	/// en: 'Smart Light'
	String get dimmableLight => 'Smart Light';

	/// en: 'WLAN Access Point'
	String get wlanAccessPoint => 'WLAN Access Point';

	/// en: 'WLAN Connection Device'
	String get wlanConnectionDevice => 'WLAN Connection Device';

	/// en: 'Printer'
	String get printer => 'Printer';

	/// en: 'Scanner'
	String get scanner => 'Scanner';

	/// en: 'Digital Security Camera'
	String get digitalSecurityCamera => 'Digital Security Camera';

	/// en: 'Unknown Device'
	String get unknownDevice => 'Unknown Device';
}

// Path: videoDetail.cast.dlnaCastSheet
class TranslationsVideoDetailCastDlnaCastSheetEn {
	TranslationsVideoDetailCastDlnaCastSheetEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Remote Cast'
	String get title => 'Remote Cast';

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Searching for devices...'
	String get searchingDevices => 'Searching for devices...';

	/// en: 'Click search button to re-search for casting devices'
	String get searchPrompt => 'Click search button to re-search for casting devices';

	/// en: 'Searching'
	String get searching => 'Searching';

	/// en: 'Search Again'
	String get searchAgain => 'Search Again';

	/// en: 'No casting devices found\nPlease ensure devices are on the same network'
	String get noDevicesFound => 'No casting devices found\nPlease ensure devices are on the same network';

	/// en: 'Searching for devices, please wait...'
	String get searchingDevicesPrompt => 'Searching for devices, please wait...';

	/// en: 'Cast'
	String get cast => 'Cast';

	/// en: 'Connected to: ${deviceName}'
	String connectedTo({required Object deviceName}) => 'Connected to: ${deviceName}';

	/// en: 'No device connected'
	String get notConnected => 'No device connected';

	/// en: 'Stop Casting'
	String get stopCasting => 'Stop Casting';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'tutorial.specialFollowFeature' => 'Special Follow Feature',
			'tutorial.specialFollowDescription' => 'This shows authors you follow specially. Go to video, gallery, or author detail pages, click the follow button, then select "Add as Special Follow".',
			'tutorial.exampleAuthorInfoRow' => 'Example: Author Info Row',
			'tutorial.authorName' => 'Author Name',
			'tutorial.followed' => 'Followed',
			'tutorial.specialFollowInstruction' => 'Click "Followed" button → Select "Add as Special Follow"',
			'tutorial.followButtonLocations' => 'Follow Button Locations:',
			'tutorial.videoDetailPage' => 'Video Detail Page',
			'tutorial.galleryDetailPage' => 'Gallery Detail Page',
			'tutorial.authorDetailPage' => 'Author Detail Page',
			'tutorial.afterSpecialFollow' => 'After Special Follow, you can quickly view the latest content of the author!',
			'tutorial.specialFollowManagementTip' => 'Special Follow list can be managed in Sidebar - Following List - Special Follow List page',
			'tutorial.skip' => 'Skip',
			'common.sort' => 'Sort',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Cancel',
			'common.save' => 'Save',
			'common.delete' => 'Delete',
			'common.visit' => 'Visit',
			'common.loading' => 'Loading...',
			'common.scrollToTop' => 'Scroll to Top',
			'common.privacyHint' => 'Privacy content, not displayed',
			'common.latest' => 'Latest',
			'common.likesCount' => 'Likes',
			'common.viewsCount' => 'Views',
			'common.popular' => 'Popular',
			'common.trending' => 'Trending',
			'common.commentList' => 'Comment List',
			'common.sendComment' => 'Send Comment',
			'common.send' => 'Send',
			'common.retry' => 'Retry',
			'common.premium' => 'Premium',
			'common.follower' => 'Follower',
			'common.friend' => 'Friend',
			'common.video' => 'Video',
			'common.following' => 'Following',
			'common.expand' => 'Expand',
			'common.collapse' => 'Collapse',
			'common.cancelFriendRequest' => 'Cancel Request',
			'common.cancelSpecialFollow' => 'Cancel Special Follow',
			'common.addFriend' => 'Add Friend',
			'common.removeFriend' => 'Remove Friend',
			'common.followed' => 'Followed',
			'common.follow' => 'Follow',
			'common.unfollow' => 'Unfollow',
			'common.specialFollow' => 'Special Follow',
			'common.specialFollowed' => 'Special Followed',
			'common.gallery' => 'Gallery',
			'common.playlist' => 'Playlist',
			'common.commentPostedSuccessfully' => 'Comment Posted Successfully',
			'common.commentPostedFailed' => 'Comment Posted Failed',
			'common.success' => 'Success',
			'common.commentDeletedSuccessfully' => 'Comment Deleted Successfully',
			'common.commentUpdatedSuccessfully' => 'Comment Updated Successfully',
			'common.totalComments' => ({required Object count}) => '${count} Comments',
			'common.writeYourCommentHere' => 'Write your comment here...',
			'common.tmpNoReplies' => 'No replies yet',
			'common.loadMore' => 'Load More',
			'common.loadingMore' => 'Loading more...',
			'common.noMoreDatas' => 'No more data',
			'common.selectTranslationLanguage' => 'Select Translation Language',
			'common.translate' => 'Translate',
			'common.translateFailedPleaseTryAgainLater' => 'Translate failed, please try again later',
			'common.translationResult' => 'Translation Result',
			'common.justNow' => 'Just Now',
			'common.minutesAgo' => ({required Object num}) => '${num} minutes ago',
			'common.hoursAgo' => ({required Object num}) => '${num} hours ago',
			'common.daysAgo' => ({required Object num}) => '${num} days ago',
			'common.editedAt' => ({required Object num}) => '${num} edited',
			'common.editComment' => 'Edit Comment',
			'common.commentUpdated' => 'Comment Updated',
			'common.replyComment' => 'Reply Comment',
			'common.reply' => 'Reply',
			'common.edit' => 'Edit',
			'common.unknownUser' => 'Unknown User',
			'common.me' => 'Me',
			'common.author' => 'Author',
			'common.admin' => 'Admin',
			'common.viewReplies' => ({required Object num}) => 'View Replies (${num})',
			'common.hideReplies' => 'Hide Replies',
			'common.confirmDelete' => 'Confirm Delete',
			'common.areYouSureYouWantToDeleteThisItem' => 'Are you sure you want to delete this item?',
			'common.tmpNoComments' => 'No comments yet',
			'common.refresh' => 'Refresh',
			'common.back' => 'Back',
			'common.tips' => 'Tips',
			'common.linkIsEmpty' => 'Link is empty',
			'common.linkCopiedToClipboard' => 'Link copied to clipboard',
			'common.imageCopiedToClipboard' => 'Image copied to clipboard',
			'common.copyImageFailed' => 'Copy image failed',
			'common.mobileSaveImageIsUnderDevelopment' => 'Mobile save image is under development',
			'common.imageSavedTo' => 'Image saved to',
			'common.saveImageFailed' => 'Save image failed',
			'common.close' => 'Close',
			'common.more' => 'More',
			'common.moreFeaturesToBeDeveloped' => 'More features to be developed',
			'common.all' => 'All',
			'common.selectedRecords' => ({required Object num}) => 'Selected ${num} records',
			'common.cancelSelectAll' => 'Cancel Select All',
			'common.selectAll' => 'Select All',
			'common.exitEditMode' => 'Exit Edit Mode',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Are you sure you want to delete selected ${num} items?',
			'common.searchHistoryRecords' => 'Search History Records...',
			'common.settings' => 'Settings',
			'common.subscriptions' => 'Subscriptions',
			'common.videoCount' => ({required Object num}) => '${num} videos',
			'common.share' => 'Share',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Are you sure you want to share this playlist?',
			'common.editTitle' => 'Edit Title',
			'common.editMode' => 'Edit Mode',
			'common.pleaseEnterNewTitle' => 'Please enter new title',
			'common.createPlayList' => 'Create Play List',
			'common.create' => 'Create',
			'common.checkNetworkSettings' => 'Check Network Settings',
			'common.general' => 'General',
			'common.r18' => 'R18',
			'common.sensitive' => 'Sensitive',
			'common.year' => 'Year',
			'common.month' => 'Month',
			'common.tag' => 'Tag',
			'common.private' => 'Private',
			'common.noTitle' => 'No Title',
			'common.search' => 'Search',
			'common.noContent' => 'No content',
			'common.recording' => 'Recording',
			'common.paused' => 'Paused',
			'common.clear' => 'Clear',
			'common.user' => 'User',
			'common.post' => 'Post',
			'common.seconds' => 'Seconds',
			'common.comingSoon' => 'Coming Soon',
			'common.confirm' => 'Confirm',
			'common.hour' => 'Hour',
			'common.minute' => 'Minute',
			'common.clickToRefresh' => 'Click to Refresh',
			'common.history' => 'History',
			'common.favorites' => 'Favorites',
			'common.friends' => 'Friends',
			'common.playList' => 'Play List',
			'common.checkLicense' => 'Check License',
			'common.logout' => 'Logout',
			'common.fensi' => 'Fans',
			'common.accept' => 'Accept',
			'common.reject' => 'Reject',
			'common.clearAllHistory' => 'Clear All History',
			'common.clearAllHistoryConfirm' => 'Are you sure you want to clear all history?',
			'common.followingList' => 'Following List',
			'common.followersList' => 'Followers List',
			'common.follows' => 'Follows',
			'common.fans' => 'Fans',
			'common.followsAndFans' => 'Follows and Fans',
			'common.numViews' => 'Views',
			'common.updatedAt' => 'Updated At',
			'common.publishedAt' => 'Published At',
			'common.externalVideo' => 'External Video',
			'common.originalText' => 'Original Text',
			'common.showOriginalText' => 'Show Original Text',
			'common.showProcessedText' => 'Show Processed Text',
			'common.preview' => 'Preview',
			'common.rules' => 'Rules',
			'common.agree' => 'Agree',
			'common.disagree' => 'Disagree',
			'common.agreeToRules' => 'Agree to Rules',
			'common.markdownSyntaxHelp' => 'Markdown Syntax Help',
			'common.previewContent' => 'Preview Content',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Exceeds max length limit (${max})',
			'common.agreeToCommunityRules' => 'Agree to Community Rules',
			'common.createPost' => 'Create Post',
			'common.title' => 'Title',
			'common.enterTitle' => 'Please enter title',
			'common.content' => 'Content',
			'common.enterContent' => 'Please enter content',
			'common.writeYourContentHere' => 'Please enter content...',
			'common.tagBlacklist' => 'Tag Blacklist',
			'common.noData' => 'No data',
			'common.tagLimit' => 'Tag Limit',
			'common.enableFloatingButtons' => 'Enable Floating Buttons',
			'common.disableFloatingButtons' => 'Disable Floating Buttons',
			'common.enabledFloatingButtons' => 'Enabled Floating Buttons',
			'common.disabledFloatingButtons' => 'Disabled Floating Buttons',
			'common.pendingCommentCount' => 'Pending Comment Count',
			'common.joined' => ({required Object str}) => 'Joined at ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Last seen ${str}',
			'common.download' => 'Download',
			'common.selectQuality' => 'Select Quality',
			'common.selectDateRange' => 'Select Date Range',
			'common.selectDateRangeHint' => 'Select date range, default is recent 30 days',
			'common.clearDateRange' => 'Clear Date Range',
			'common.followSuccessClickAgainToSpecialFollow' => 'Followed successfully, click again to special follow',
			'common.exitConfirmTip' => 'Are you sure you want to exit?',
			'common.error' => 'Error',
			'common.taskRunning' => 'A task is already running, please wait.',
			'common.operationCancelled' => 'Operation cancelled.',
			'common.unsavedChanges' => 'You have unsaved changes',
			'common.specialFollowsManagementTip' => 'Drag to reorder • Swipe left to remove',
			'common.specialFollowsManagement' => 'Special Follows Management',
			'common.createTimeDesc' => 'Create Time Desc',
			'common.createTimeAsc' => 'Create Time Asc',
			'common.pagination.totalItems' => ({required Object num}) => 'Total ${num} items',
			'common.pagination.jumpToPage' => 'Jump to page',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Please enter page number (1-${max})',
			'common.pagination.pageNumber' => 'Page number',
			'common.pagination.jump' => 'Jump',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Please enter a valid page number (1-${max})',
			'common.pagination.invalidInput' => 'Please enter a valid page number',
			'common.pagination.waterfall' => 'Waterfall',
			'common.pagination.pagination' => 'Pagination',
			'common.notice' => 'Notice',
			'common.detail' => 'Detail',
			'common.parseExceptionDestopHint' => ' - Desktop users can configure proxy in settings',
			'common.iwaraTags' => 'Iwara Tags',
			'common.likeThisVideo' => 'Like This Video',
			'common.operation' => 'Operation',
			'common.replies' => 'Replies',
			'common.externalLinkWarning' => 'External Link Warning',
			'common.externalLinkWarningMessage' => 'You are about to open an external link that is not part of iwara.tv. Please be cautious and ensure the link is safe before proceeding.',
			'common.continueToExternalLink' => 'Continue',
			'common.cancelExternalLink' => 'Cancel',
			'auth.login' => 'Login',
			'auth.logout' => 'Logout',
			'auth.email' => 'Email',
			'auth.password' => 'Password',
			'auth.loginOrRegister' => 'Login / Register',
			'auth.register' => 'Register',
			'auth.pleaseEnterEmail' => 'Please enter email',
			'auth.pleaseEnterPassword' => 'Please enter password',
			'auth.passwordMustBeAtLeast6Characters' => 'Password must be at least 6 characters',
			'auth.pleaseEnterCaptcha' => 'Please enter captcha',
			'auth.captcha' => 'Captcha',
			'auth.refreshCaptcha' => 'Refresh Captcha',
			'auth.captchaNotLoaded' => 'Captcha not loaded',
			'auth.loginSuccess' => 'Login Success',
			'auth.emailVerificationSent' => 'Email verification sent',
			'auth.notLoggedIn' => 'Not Logged In',
			'auth.clickToLogin' => 'Click to Login',
			'auth.logoutConfirmation' => 'Are you sure you want to logout?',
			'auth.logoutSuccess' => 'Logout Success',
			'auth.logoutFailed' => 'Logout Failed',
			'auth.usernameOrEmail' => 'Username or Email',
			'auth.pleaseEnterUsernameOrEmail' => 'Please enter username or email',
			'auth.rememberMe' => 'Remember Username and Password',
			'errors.error' => 'Error',
			'errors.required' => 'This field is required',
			'errors.invalidEmail' => 'Invalid email address',
			'errors.networkError' => 'Network error, please try again',
			'errors.errorWhileFetching' => 'Error while fetching',
			'errors.commentCanNotBeEmpty' => 'Comment content cannot be empty',
			'errors.errorWhileFetchingReplies' => 'Error while fetching replies, please check network connection',
			'errors.canNotFindCommentController' => 'Can not find comment controller',
			'errors.errorWhileLoadingGallery' => 'Error while loading gallery',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'How could there be no data? It can\'t be possible :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Unsupported image format: ${str}',
			'errors.invalidGalleryId' => 'Invalid gallery ID',
			'errors.translationFailedPleaseTryAgainLater' => 'Translation failed, please try again later',
			'errors.errorOccurred' => 'An error occurred, please try again later.',
			'errors.errorOccurredWhileProcessingRequest' => 'Error occurred while processing request',
			'errors.errorWhileFetchingDatas' => 'Error while fetching datas, please try again later',
			'errors.serviceNotInitialized' => 'Service not initialized',
			'errors.unknownType' => 'Unknown type',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Error while opening link: ${link}',
			'errors.invalidUrl' => 'Invalid URL',
			'errors.failedToOperate' => 'Failed to operate',
			'errors.permissionDenied' => 'Permission Denied',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'You do not have permission to access this resource',
			'errors.loginFailed' => 'Login Failed',
			'errors.unknownError' => 'Unknown Error',
			'errors.sessionExpired' => 'Session Expired',
			'errors.failedToFetchCaptcha' => 'Failed to fetch captcha',
			'errors.emailAlreadyExists' => 'Email already exists',
			'errors.invalidCaptcha' => 'Invalid Captcha',
			'errors.registerFailed' => 'Register Failed',
			'errors.failedToFetchComments' => 'Failed to fetch comments',
			'errors.failedToFetchImageDetail' => 'Failed to fetch image detail',
			'errors.failedToFetchImageList' => 'Failed to fetch image list',
			'errors.failedToFetchData' => 'Failed to fetch data',
			'errors.invalidParameter' => 'Invalid parameter',
			'errors.pleaseLoginFirst' => 'Please login first',
			'errors.errorWhileLoadingPost' => 'Error while loading post',
			'errors.errorWhileLoadingPostDetail' => 'Error while loading post detail',
			'errors.invalidPostId' => 'Invalid post ID',
			'errors.forceUpdateNotPermittedToGoBack' => 'Currently in force update state, cannot go back',
			'errors.pleaseLoginAgain' => 'Please login again',
			'errors.invalidLogin' => 'Invalid login, Please check your email and password',
			'errors.tooManyRequests' => 'Too many requests, please try again later',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Exceeds max length: ${max}',
			'errors.contentCanNotBeEmpty' => 'Content cannot be empty',
			'errors.titleCanNotBeEmpty' => 'Title cannot be empty',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Too many requests, please try again later, remaining',
			'errors.remainingHours' => ({required Object num}) => '${num} hours',
			'errors.remainingMinutes' => ({required Object num}) => '${num} minutes',
			'errors.remainingSeconds' => ({required Object num}) => '${num} seconds',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Tag limit exceeded, limit: ${limit}',
			'errors.failedToRefresh' => 'Failed to refresh',
			'errors.noPermission' => 'No permission',
			'errors.resourceNotFound' => 'Resource not found',
			'errors.failedToSaveCredentials' => 'Failed to save login credentials',
			'errors.failedToLoadSavedCredentials' => 'Failed to load saved credentials',
			'errors.specialFollowLimitReached' => ({required Object cnt}) => 'Special follow limit exceeded, limit: ${cnt}, please adjust in the follow list page',
			'errors.notFound' => 'Content not found or has been deleted',
			'errors.network.basicPrefix' => 'Network error - ',
			'errors.network.failedToConnectToServer' => 'Failed to connect to server',
			'errors.network.serverNotAvailable' => 'Server not available',
			'errors.network.requestTimeout' => 'Request timeout',
			'errors.network.unexpectedError' => 'Unexpected error',
			'errors.network.invalidResponse' => 'Invalid response',
			'errors.network.invalidRequest' => 'Invalid request',
			'errors.network.invalidUrl' => 'Invalid URL',
			'errors.network.invalidMethod' => 'Invalid method',
			'errors.network.invalidHeader' => 'Invalid header',
			'errors.network.invalidBody' => 'Invalid body',
			'errors.network.invalidStatusCode' => 'Invalid status code',
			'errors.network.serverError' => 'Server error',
			'errors.network.requestCanceled' => 'Request canceled',
			'errors.network.invalidPort' => 'Invalid port',
			'errors.network.proxyPortError' => 'Proxy port error',
			'errors.network.connectionRefused' => 'Connection refused',
			'errors.network.networkUnreachable' => 'Network unreachable',
			'errors.network.noRouteToHost' => 'No route to host',
			'errors.network.connectionFailed' => 'Connection failed',
			'errors.network.sslConnectionFailed' => 'SSL connection failed, please check your network settings',
			'friends.clickToRestoreFriend' => 'Click to restore friend',
			'friends.friendsList' => 'Friends List',
			'friends.friendRequests' => 'Friend Requests',
			'friends.friendRequestsList' => 'Friend Requests List',
			'friends.removingFriend' => 'Removing friend...',
			'friends.failedToRemoveFriend' => 'Failed to remove friend',
			'friends.cancelingRequest' => 'Canceling friend request...',
			'friends.failedToCancelRequest' => 'Failed to cancel friend request',
			'authorProfile.noMoreDatas' => 'No more data',
			'authorProfile.userProfile' => 'User Profile',
			'favorites.clickToRestoreFavorite' => 'Click to restore favorite',
			'favorites.myFavorites' => 'My Favorites',
			'galleryDetail.galleryDetail' => 'Gallery Detail',
			'galleryDetail.viewGalleryDetail' => 'View Gallery Detail',
			'galleryDetail.copyLink' => 'Copy Link',
			'galleryDetail.copyImage' => 'Copy Image',
			'galleryDetail.saveAs' => 'Save As',
			'galleryDetail.saveToAlbum' => 'Save to Album',
			'galleryDetail.publishedAt' => 'Published At',
			'galleryDetail.viewsCount' => 'Views Count',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Image Library Function Introduction',
			'galleryDetail.rightClickToSaveSingleImage' => 'Right Click to Save Single Image',
			'galleryDetail.batchSave' => 'Batch Save',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Keyboard Left and Right to Switch',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Keyboard Up and Down to Zoom',
			'galleryDetail.mouseWheelToSwitch' => 'Mouse Wheel to Switch',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + Mouse Wheel to Zoom',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'More Features to Be Discovered...',
			'galleryDetail.authorOtherGalleries' => 'Author\'s Other Galleries',
			'galleryDetail.relatedGalleries' => 'Related Galleries',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Click Left and Right Edge to Switch Image',
			'playList.myPlayList' => 'My Play List',
			'playList.friendlyTips' => 'Friendly Tips',
			'playList.dearUser' => 'Dear User',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'iwara\'s play list system is not perfect yet',
			'playList.notSupportSetCover' => 'Not support set cover',
			'playList.notSupportDeleteList' => 'Not support delete list',
			'playList.notSupportSetPrivate' => 'Not support set private',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Yes... create list will always exist and visible to everyone',
			'playList.smallSuggestion' => 'Small Suggestion',
			'playList.useLikeToCollectContent' => 'If you are more concerned about privacy, it is recommended to use the "like" function to collect content',
			'playList.welcomeToDiscussOnGitHub' => 'If you have other suggestions or ideas, welcome to discuss on GitHub!',
			'playList.iUnderstand' => 'I Understand',
			'playList.searchPlaylists' => 'Search Playlists...',
			'playList.newPlaylistName' => 'New Playlist Name',
			'playList.createNewPlaylist' => 'Create New Playlist',
			'playList.videos' => 'Videos',
			'search.googleSearchScope' => 'Search Scope',
			'search.searchTags' => 'Search Tags...',
			'search.contentRating' => 'Content Rating',
			'search.removeTag' => 'Remove Tag',
			'search.pleaseEnterSearchContent' => 'Please enter search content',
			'search.searchHistory' => 'Search History',
			'search.searchSuggestion' => 'Search Suggestion',
			'search.usedTimes' => 'Used Times',
			'search.lastUsed' => 'Last Used',
			'search.noSearchHistoryRecords' => 'No search history',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Not support current search type ${searchType}, please wait for the update',
			'search.searchResult' => 'Search Result',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Unsupported search type: ${searchType}',
			'search.googleSearch' => 'Google Search',
			'search.googleSearchHint' => ({required Object webName}) => '${webName} \'s search function is not easy to use? Try Google Search!',
			'search.googleSearchDescription' => 'Use the :site search operator of Google Search to search for content on the site. This is very useful when searching for videos, galleries, playlists, and users.',
			'search.googleSearchKeywordsHint' => 'Enter keywords to search',
			'search.openLinkJump' => 'Open Link Jump',
			'search.googleSearchButton' => 'Google Search',
			'search.pleaseEnterSearchKeywords' => 'Please enter search keywords',
			'search.googleSearchQueryCopied' => 'Search query copied to clipboard',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Failed to open browser: ${error}',
			'mediaList.personalIntroduction' => 'Introduction',
			'settings.listViewMode' => 'List View Mode',
			'settings.previewEffect' => 'Preview Effect',
			'settings.useTraditionalPaginationMode' => 'Use Traditional Pagination Mode',
			'settings.useTraditionalPaginationModeDesc' => 'Enable traditional pagination mode, disable waterfall mode. Takes effect after re-rendering the page or restarting the app',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Show Video Progress Bottom Bar When Toolbar Hidden',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'This configuration determines whether the video progress bottom bar will be shown when the toolbar is hidden.',
			'settings.basicSettings' => 'Basic Settings',
			'settings.personalizedSettings' => 'Personalized Settings',
			'settings.otherSettings' => 'Other Settings',
			'settings.searchConfig' => 'Search Config',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'This configuration determines whether the previous configuration will be used when playing videos again.',
			'settings.playControl' => 'Play Control',
			'settings.fastForwardTime' => 'Fast Forward Time',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'Fast forward time must be a positive integer.',
			'settings.rewindTime' => 'Rewind Time',
			'settings.rewindTimeMustBeAPositiveInteger' => 'Rewind time must be a positive integer.',
			'settings.longPressPlaybackSpeed' => 'Long Press Playback Speed',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'Long press playback speed must be a positive number.',
			'settings.repeat' => 'Repeat',
			'settings.renderVerticalVideoInVerticalScreen' => 'Render Vertical Video in Vertical Screen',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'This configuration determines whether the video will be rendered in vertical screen when playing in full screen.',
			'settings.rememberVolume' => 'Remember Volume',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'This configuration determines whether the volume will be kept when playing videos again.',
			'settings.rememberBrightness' => 'Remember Brightness',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'This configuration determines whether the brightness will be kept when playing videos again.',
			'settings.playControlArea' => 'Play Control Area',
			'settings.leftAndRightControlAreaWidth' => 'Left and Right Control Area Width',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'This configuration determines the width of the control areas on the left and right sides of the player.',
			'settings.proxyAddressCannotBeEmpty' => 'Proxy address cannot be empty.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Invalid proxy address format. Please use the format of IP:port or domain name:port.',
			'settings.proxyNormalWork' => 'Proxy normal work.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Test proxy failed, status code: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Test proxy failed, exception: ${exception}',
			'settings.proxyConfig' => 'Proxy Config',
			'settings.thisIsHttpProxyAddress' => 'This is http proxy address',
			'settings.checkProxy' => 'Check Proxy',
			'settings.proxyAddress' => 'Proxy Address',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Please enter the URL of the proxy server, for example 127.0.0.1:8080',
			'settings.enableProxy' => 'Enable Proxy',
			'settings.left' => 'Left',
			'settings.middle' => 'Middle',
			'settings.right' => 'Right',
			'settings.playerSettings' => 'Player Settings',
			'settings.networkSettings' => 'Network Settings',
			'settings.customizeYourPlaybackExperience' => 'Customize Your Playback Experience',
			'settings.chooseYourFavoriteAppAppearance' => 'Choose Your Favorite App Appearance',
			'settings.configureYourProxyServer' => 'Configure Your Proxy Server',
			'settings.settings' => 'Settings',
			'settings.themeSettings' => 'Theme Settings',
			'settings.followSystem' => 'Follow System',
			'settings.lightMode' => 'Light Mode',
			'settings.darkMode' => 'Dark Mode',
			'settings.presetTheme' => 'Preset Theme',
			'settings.basicTheme' => 'Basic Theme',
			'settings.needRestartToApply' => 'Need to restart the app to apply the settings',
			'settings.themeNeedRestartDescription' => 'The theme settings need to restart the app to apply the settings',
			'settings.about' => 'About',
			'settings.currentVersion' => 'Current Version',
			'settings.latestVersion' => 'Latest Version',
			'settings.checkForUpdates' => 'Check for Updates',
			'settings.update' => 'Update',
			'settings.newVersionAvailable' => 'New Version Available',
			'settings.projectHome' => 'Project Home',
			'settings.release' => 'Release',
			'settings.issueReport' => 'Issue Report',
			'settings.openSourceLicense' => 'Open Source License',
			'settings.checkForUpdatesFailed' => 'Check for updates failed, please try again later',
			'settings.autoCheckUpdate' => 'Auto Check Update',
			'settings.updateContent' => 'Update Content',
			'settings.releaseDate' => 'Release Date',
			'settings.ignoreThisVersion' => 'Ignore This Version',
			'settings.minVersionUpdateRequired' => 'Current version is too low, please update as soon as possible',
			'settings.forceUpdateTip' => 'This is a mandatory update. Please update to the latest version as soon as possible',
			'settings.viewChangelog' => 'View Changelog',
			'settings.alreadyLatestVersion' => 'Already the latest version',
			'settings.appSettings' => 'App Settings',
			'settings.configureYourAppSettings' => 'Configure Your App Settings',
			'settings.history' => 'History',
			'settings.autoRecordHistory' => 'Auto Record History',
			'settings.autoRecordHistoryDesc' => 'Auto record the videos and images you have watched',
			'settings.showUnprocessedMarkdownText' => 'Show Unprocessed Markdown Text',
			'settings.showUnprocessedMarkdownTextDesc' => 'Show the original text of the markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Privacy Mode',
			'settings.activeBackgroundPrivacyModeDesc' => 'Prevent screenshots, hide screen when running in the background...',
			'settings.privacy' => 'Privacy',
			'settings.forum' => 'Forum',
			'settings.disableForumReplyQuote' => 'Disable Forum Reply Quote',
			'settings.disableForumReplyQuoteDesc' => 'Disable carrying replied floor information when replying in forum',
			'settings.theaterMode' => 'Theater Mode',
			'settings.theaterModeDesc' => 'After opening, the player background will be set to the blurred version of the video cover',
			'settings.appLinks' => 'App Links',
			'settings.defaultBrowser' => 'Default Browse',
			'settings.defaultBrowserDesc' => 'Please open the default link configuration item in the system settings and add the iwara.tv website link',
			'settings.themeMode' => 'Theme Mode',
			'settings.themeModeDesc' => 'This configuration determines the theme mode of the app',
			'settings.dynamicColor' => 'Dynamic Color',
			'settings.dynamicColorDesc' => 'This configuration determines whether the app uses dynamic color',
			'settings.useDynamicColor' => 'Use Dynamic Color',
			'settings.useDynamicColorDesc' => 'This configuration determines whether the app uses dynamic color',
			'settings.presetColors' => 'Preset Colors',
			'settings.customColors' => 'Custom Colors',
			'settings.pickColor' => 'Pick Color',
			'settings.cancel' => 'Cancel',
			'settings.confirm' => 'Confirm',
			'settings.noCustomColors' => 'No custom colors',
			'settings.recordAndRestorePlaybackProgress' => 'Record and Restore Playback Progress',
			'settings.signature' => 'Signature',
			'settings.enableSignature' => 'Enable Signature',
			'settings.enableSignatureDesc' => 'This configuration determines whether the app will add signature when replying',
			'settings.enterSignature' => 'Enter Signature',
			'settings.editSignature' => 'Edit Signature',
			'settings.signatureContent' => 'Signature Content',
			'settings.exportConfig' => 'Export App Configuration',
			'settings.exportConfigDesc' => 'Export app configuration to a file (excluding download records)',
			'settings.importConfig' => 'Import App Configuration',
			'settings.importConfigDesc' => 'Import app configuration from a file',
			'settings.exportConfigSuccess' => 'Configuration exported successfully!',
			'settings.exportConfigFailed' => 'Failed to export configuration',
			'settings.importConfigSuccess' => 'Configuration imported successfully!',
			_ => null,
		} ?? switch (path) {
			'settings.importConfigFailed' => 'Failed to import configuration',
			'settings.historyUpdateLogs' => 'History Update Logs',
			'settings.noUpdateLogs' => 'No update logs available',
			'settings.versionLabel' => 'Version: {version}',
			'settings.releaseDateLabel' => 'Release Date: {date}',
			'settings.noChanges' => 'No update content available',
			'settings.interaction' => 'Interaction',
			'settings.enableVibration' => 'Enable Vibration',
			'settings.enableVibrationDesc' => 'Enable vibration feedback when interacting with the app',
			'settings.defaultKeepVideoToolbarVisible' => 'Keep Video Toolbar Visible',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'This setting determines whether the video toolbar remains visible when first entering the video page.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Mobile devices enable theater mode, which may cause performance issues. You can choose to enable it.',
			'settings.lockButtonPosition' => 'Lock Button Position',
			'settings.lockButtonPositionBothSides' => 'Both Sides',
			'settings.lockButtonPositionLeftSide' => 'Left Side',
			'settings.lockButtonPositionRightSide' => 'Right Side',
			'settings.fullscreenOrientation' => 'Vertical Screen Orientation After Entering Fullscreen',
			'settings.fullscreenOrientationDesc' => 'This setting determines the default screen orientation when entering fullscreen (mobile only)',
			'settings.fullscreenOrientationLeftLandscape' => 'Left Landscape',
			'settings.fullscreenOrientationRightLandscape' => 'Right Landscape',
			'settings.jumpLink' => 'Jump Link',
			'settings.language' => 'Language',
			'settings.languageChanged' => 'Language setting has been changed, please restart the app to take effect.',
			'settings.gestureControl' => 'Gesture Control',
			'settings.leftDoubleTapRewind' => 'Left Double Tap Rewind',
			'settings.rightDoubleTapFastForward' => 'Right Double Tap Fast Forward',
			'settings.doubleTapPause' => 'Double Tap Pause',
			'settings.rightVerticalSwipeVolume' => 'Right Vertical Swipe Volume (Effective when entering a new page)',
			'settings.leftVerticalSwipeBrightness' => 'Left Vertical Swipe Brightness (Effective when entering a new page)',
			'settings.longPressFastForward' => 'Long Press Fast Forward',
			'settings.enableMouseHoverShowToolbar' => 'Enable Mouse Hover Show Toolbar',
			'settings.enableMouseHoverShowToolbarInfo' => 'When enabled, the video toolbar will be shown when the mouse is hovering over the player. It will be automatically hidden after 3 seconds of inactivity.',
			'settings.enableHorizontalDragSeek' => 'Horizontal Swipe to Seek',
			'settings.audioVideoConfig' => 'Audio Video Configuration',
			'settings.expandBuffer' => 'Expand Buffer',
			'settings.expandBufferInfo' => 'When enabled, the buffer size increases, loading time becomes longer but playback is smoother',
			'settings.videoSyncMode' => 'Video Sync Mode',
			'settings.videoSyncModeSubtitle' => 'Audio-video synchronization strategy',
			'settings.hardwareDecodingMode' => 'Hardware Decoding Mode',
			'settings.hardwareDecodingModeSubtitle' => 'Hardware decoding settings',
			'settings.enableHardwareAcceleration' => 'Enable Hardware Acceleration',
			'settings.enableHardwareAccelerationInfo' => 'Enabling hardware acceleration can improve decoding performance, but some devices may not be compatible',
			'settings.useOpenSLESAudioOutput' => 'Use OpenSLES Audio Output',
			'settings.useOpenSLESAudioOutputInfo' => 'Use low-latency audio output, may improve audio performance',
			'settings.videoSyncAudio' => 'Audio Sync',
			'settings.videoSyncDisplayResample' => 'Display Resample',
			'settings.videoSyncDisplayResampleVdrop' => 'Display Resample (Drop Frames)',
			'settings.videoSyncDisplayResampleDesync' => 'Display Resample (Desync)',
			'settings.videoSyncDisplayTempo' => 'Display Tempo',
			'settings.videoSyncDisplayVdrop' => 'Display Drop Video Frames',
			'settings.videoSyncDisplayAdrop' => 'Display Drop Audio Frames',
			'settings.videoSyncDisplayDesync' => 'Display Desync',
			'settings.videoSyncDesync' => 'Desync',
			'settings.forumSettings.name' => 'Forum',
			'settings.forumSettings.configureYourForumSettings' => 'Configure Your Forum Settings',
			'settings.chatSettings.name' => 'Chat',
			'settings.chatSettings.configureYourChatSettings' => 'Configure Your Chat Settings',
			'settings.hardwareDecodingAuto' => 'Auto',
			'settings.hardwareDecodingAutoCopy' => 'Auto Copy',
			'settings.hardwareDecodingAutoSafe' => 'Auto Safe',
			'settings.hardwareDecodingNo' => 'Disabled',
			'settings.hardwareDecodingYes' => 'Force Enable',
			'settings.cdnDistributionStrategy' => 'Content Distribution Strategy',
			'settings.cdnDistributionStrategyDesc' => 'Select video source server distribution strategy to optimize loading speed',
			'settings.cdnDistributionStrategyLabel' => 'Distribution Strategy',
			'settings.cdnDistributionStrategyNoChange' => 'No Change (Use Original Server)',
			'settings.cdnDistributionStrategyAuto' => 'Auto Select (Fastest Server)',
			'settings.cdnDistributionStrategySpecial' => 'Specify Server',
			'settings.cdnSpecialServer' => 'Specify Server',
			'settings.cdnRefreshServerListHint' => 'Please click the button below to refresh the server list',
			'settings.cdnRefreshButton' => 'Refresh',
			'settings.cdnFastRingServers' => 'Fast Ring Servers',
			'settings.cdnRefreshServerListTooltip' => 'Refresh server list',
			'settings.cdnSpeedTestButton' => 'Speed Test',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Testing (${count})',
			'settings.cdnNoServerDataHint' => 'No server data available, please click the refresh button',
			'settings.cdnTestingStatus' => 'Testing',
			'settings.cdnUnreachableStatus' => 'Unreachable',
			'settings.cdnNotTestedStatus' => 'Not Tested',
			'settings.downloadSettings.downloadSettings' => 'Download Settings',
			'settings.downloadSettings.storagePermissionStatus' => 'Storage Permission Status',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Access Public Directory Need Storage Permission',
			'settings.downloadSettings.checkingPermissionStatus' => 'Checking Permission Status...',
			'settings.downloadSettings.storagePermissionGranted' => 'Storage Permission Granted',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Storage Permission Not Granted',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Storage Permission Grant Success',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Storage Permission Grant Failed But Some Features May Be Limited',
			'settings.downloadSettings.grantStoragePermission' => 'Grant Storage Permission',
			'settings.downloadSettings.customDownloadPath' => 'Custom Download Path',
			'settings.downloadSettings.customDownloadPathDescription' => 'When enabled, you can choose a custom save location for downloaded files',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Tip: Selecting public directories (like Downloads folder) requires storage permission, recommend using recommended paths first',
			'settings.downloadSettings.androidWarning' => 'Android Note: Avoid selecting public directories (such as Downloads folder), recommend using app-specific directories to ensure access permissions.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Notice: You selected a public directory, storage permission is required for normal file downloads',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Storage permission required for public directories',
			'settings.downloadSettings.currentDownloadPath' => 'Current Download Path',
			'settings.downloadSettings.actualDownloadPath' => 'Actual Download Path',
			'settings.downloadSettings.defaultAppDirectory' => 'Default App Directory',
			'settings.downloadSettings.permissionGranted' => 'Granted',
			'settings.downloadSettings.permissionRequired' => 'Permission Required',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Enable Custom Download Path',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Use app default path when disabled',
			'settings.downloadSettings.customDownloadPathLabel' => 'Custom Download Path',
			'settings.downloadSettings.selectDownloadFolder' => 'Select download folder',
			'settings.downloadSettings.recommendedPath' => 'Recommended Path',
			'settings.downloadSettings.selectFolder' => 'Select Folder',
			'settings.downloadSettings.filenameTemplate' => 'Filename Template',
			'settings.downloadSettings.filenameTemplateDescription' => 'Customize the naming rules for downloaded files, supports variable substitution',
			'settings.downloadSettings.videoFilenameTemplate' => 'Video Filename Template',
			'settings.downloadSettings.galleryFolderTemplate' => 'Gallery Folder Template',
			'settings.downloadSettings.imageFilenameTemplate' => 'Image Filename Template',
			'settings.downloadSettings.resetToDefault' => 'Reset to Default',
			'settings.downloadSettings.supportedVariables' => 'Supported Variables',
			'settings.downloadSettings.supportedVariablesDescription' => 'The following variables can be used in filename templates:',
			'settings.downloadSettings.copyVariable' => 'Copy Variable',
			'settings.downloadSettings.variableCopied' => 'Variable copied',
			'settings.downloadSettings.warningPublicDirectory' => 'Warning: Selected public directory may not be accessible. Recommend selecting app-specific directory.',
			'settings.downloadSettings.downloadPathUpdated' => 'Download path updated',
			'settings.downloadSettings.selectPathFailed' => 'Failed to select path',
			'settings.downloadSettings.recommendedPathSet' => 'Set to recommended path',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Failed to set recommended path',
			'settings.downloadSettings.templateResetToDefault' => 'Reset to default template',
			'settings.downloadSettings.functionalTest' => 'Functional Test',
			'settings.downloadSettings.testInProgress' => 'Testing...',
			'settings.downloadSettings.runTest' => 'Run Test',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Test if download path and permission configuration work properly',
			'settings.downloadSettings.testResults' => 'Test Results',
			'settings.downloadSettings.testCompleted' => 'Test completed',
			'settings.downloadSettings.testPassed' => 'items passed',
			'settings.downloadSettings.testFailed' => 'Test failed',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Storage Permission Check',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Storage permission granted',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Storage permission missing, some features may be limited',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Permission check failed',
			'settings.downloadSettings.testDownloadPathValidation' => 'Download Path Validation',
			'settings.downloadSettings.testPathValidationFailed' => 'Path validation failed',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Filename Template Validation',
			'settings.downloadSettings.testAllTemplatesValid' => 'All templates are valid',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Some templates contain invalid characters',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Template validation failed',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Directory Operation Test',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'Directory creation and file writing are normal',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Directory operation failed',
			'settings.downloadSettings.testVideoTemplate' => 'Video Template',
			'settings.downloadSettings.testGalleryTemplate' => 'Gallery Template',
			'settings.downloadSettings.testImageTemplate' => 'Image Template',
			'settings.downloadSettings.testValid' => 'Valid',
			'settings.downloadSettings.testInvalid' => 'Invalid',
			'settings.downloadSettings.testSuccess' => 'Success',
			'settings.downloadSettings.testCorrect' => 'Correct',
			'settings.downloadSettings.testError' => 'Error',
			'settings.downloadSettings.testPath' => 'Test Path',
			'settings.downloadSettings.testBasePath' => 'Base Path',
			'settings.downloadSettings.testDirectoryCreation' => 'Directory Creation',
			'settings.downloadSettings.testFileWriting' => 'File Writing',
			'settings.downloadSettings.testFileContent' => 'File Content',
			'settings.downloadSettings.checkingPathStatus' => 'Checking path status...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Unable to get path status',
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Note: Actual path differs from selected path',
			'settings.downloadSettings.grantPermission' => 'Grant Permission',
			'settings.downloadSettings.fixIssue' => 'Fix Issue',
			'settings.downloadSettings.issueFixed' => 'Issue fixed',
			'settings.downloadSettings.fixFailed' => 'Fix failed, please handle manually',
			'settings.downloadSettings.lackStoragePermission' => 'Lack storage permission',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Cannot access public directory, need "All files access permission"',
			'settings.downloadSettings.cannotCreateDirectory' => 'Cannot create directory',
			'settings.downloadSettings.directoryNotWritable' => 'Directory not writable',
			'settings.downloadSettings.insufficientSpace' => 'Insufficient available space',
			'settings.downloadSettings.pathValid' => 'Path is valid',
			'settings.downloadSettings.validationFailed' => 'Validation failed',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Using default app directory',
			'settings.downloadSettings.appPrivateDirectory' => 'App Private Directory',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Safe and reliable, no additional permissions required',
			'settings.downloadSettings.downloadDirectory' => 'Download Directory',
			'settings.downloadSettings.downloadDirectoryDesc' => 'System default download location, easy to manage',
			'settings.downloadSettings.moviesDirectory' => 'Movies Directory',
			'settings.downloadSettings.moviesDirectoryDesc' => 'System movies directory, recognizable by media apps',
			'settings.downloadSettings.documentsDirectory' => 'Documents Directory',
			'settings.downloadSettings.documentsDirectoryDesc' => 'iOS app documents directory',
			'settings.downloadSettings.requiresStoragePermission' => 'Requires storage permission to access',
			'settings.downloadSettings.recommendedPaths' => 'Recommended Paths',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'External App Private Directory',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'External storage app private directory, user accessible, larger space',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Internal App Private Directory',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'App internal storage, no permissions required, smaller space',
			'settings.downloadSettings.appDocumentsDirectory' => 'App Documents Directory',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'App-specific documents directory, safe and reliable',
			'settings.downloadSettings.downloadsFolder' => 'Downloads Folder',
			'settings.downloadSettings.downloadsFolderDesc' => 'System default download directory',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Select a recommended download location',
			'settings.downloadSettings.noRecommendedPaths' => 'No recommended paths available',
			'settings.downloadSettings.recommended' => 'Recommended',
			'settings.downloadSettings.requiresPermission' => 'Requires Permission',
			'settings.downloadSettings.authorizeAndSelect' => 'Authorize and Select',
			'settings.downloadSettings.select' => 'Select',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Permission authorization failed, cannot select this path',
			'settings.downloadSettings.pathValidationFailed' => 'Path validation failed',
			'settings.downloadSettings.downloadPathSetTo' => 'Download path set to',
			'settings.downloadSettings.setPathFailed' => 'Failed to set path',
			'settings.downloadSettings.variableTitle' => 'Title',
			'settings.downloadSettings.variableAuthor' => 'Author name',
			'settings.downloadSettings.variableUsername' => 'Author username',
			'settings.downloadSettings.variableQuality' => 'Video quality',
			'settings.downloadSettings.variableFilename' => 'Original filename',
			'settings.downloadSettings.variableId' => 'Content ID',
			'settings.downloadSettings.variableCount' => 'Gallery image count',
			'settings.downloadSettings.variableDate' => 'Current date (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'Current time (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Current date time (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Download Settings',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Configure download path and file naming rules',
			'settings.downloadSettings.suchAsTitleQuality' => 'For example: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'For example: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'For example: %title_%filename',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Tags',
			'oreno3d.characters' => 'Characters',
			'oreno3d.origin' => 'Origin',
			'oreno3d.thirdPartyTagsExplanation' => 'The **tags**, **characters**, and **origin** information displayed here are provided by the third-party site **Oreno3D** for reference only.\n\nSince this information source is only available in Japanese, it currently lacks internationalization adaptation.\n\nIf you are interested in contributing to internationalization efforts, please visit the repository to help improve it!',
			'oreno3d.sortTypes.hot' => 'Hot',
			'oreno3d.sortTypes.favorites' => 'Favorites',
			'oreno3d.sortTypes.latest' => 'Latest',
			'oreno3d.sortTypes.popularity' => 'Popular',
			'oreno3d.errors.requestFailed' => 'Request failed, status code',
			'oreno3d.errors.connectionTimeout' => 'Connection timeout, please check network connection',
			'oreno3d.errors.sendTimeout' => 'Send request timeout',
			'oreno3d.errors.receiveTimeout' => 'Receive response timeout',
			'oreno3d.errors.badCertificate' => 'Certificate verification failed',
			'oreno3d.errors.resourceNotFound' => 'Requested resource not found',
			'oreno3d.errors.accessDenied' => 'Access denied, may require authentication or permission',
			'oreno3d.errors.serverError' => 'Internal server error',
			'oreno3d.errors.serviceUnavailable' => 'Service temporarily unavailable',
			'oreno3d.errors.requestCancelled' => 'Request cancelled',
			'oreno3d.errors.connectionError' => 'Network connection error, please check network settings',
			'oreno3d.errors.networkRequestFailed' => 'Network request failed',
			'oreno3d.errors.searchVideoError' => 'Unknown error occurred while searching videos',
			'oreno3d.errors.getPopularVideoError' => 'Unknown error occurred while getting popular videos',
			'oreno3d.errors.getVideoDetailError' => 'Unknown error occurred while getting video details',
			'oreno3d.errors.parseVideoDetailError' => 'Unknown error occurred while getting and parsing video details',
			'oreno3d.errors.downloadFileError' => 'Unknown error occurred while downloading file',
			'oreno3d.loading.gettingVideoInfo' => 'Getting video information...',
			'oreno3d.loading.cancel' => 'Cancel',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Video not found or has been deleted',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Unable to get video playback link',
			'oreno3d.messages.getVideoDetailFailed' => 'Failed to get video details',
			'signIn.pleaseLoginFirst' => 'Please login first',
			'signIn.alreadySignedInToday' => 'You have already signed in today!',
			'signIn.youDidNotStickToTheSignIn' => 'You did not stick to the sign in.',
			'signIn.signInSuccess' => 'Sign in successfully!',
			'signIn.signInFailed' => 'Sign in failed, please try again later',
			'signIn.consecutiveSignIns' => 'Consecutive Sign Ins',
			'signIn.failureReason' => 'Failure Reason',
			'signIn.selectDateRange' => 'Select Date Range',
			'signIn.startDate' => 'Start Date',
			'signIn.endDate' => 'End Date',
			'signIn.invalidDate' => 'Invalid Date',
			'signIn.invalidDateRange' => 'Invalid Date Range',
			'signIn.errorFormatText' => 'Date Format Error',
			'signIn.errorInvalidText' => 'Invalid Date Range',
			'signIn.errorInvalidRangeText' => 'Invalid Date Range',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'Date range cannot be more than one year',
			'signIn.signIn' => 'Sign In',
			'signIn.signInRecord' => 'Sign In Record',
			'signIn.totalSignIns' => 'Total Sign Ins',
			'signIn.pleaseSelectSignInStatus' => 'Please select sign in status',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Please login first to view your subscriptions.',
			'subscriptions.selectUser' => 'Select User',
			'subscriptions.noSubscribedUsers' => 'No subscribed users',
			'subscriptions.showAllSubscribedUsersContent' => 'Show all subscribed users content',
			'videoDetail.pipMode' => 'PiP Mode',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Resume from last position: ${position}',
			'videoDetail.localInfo.videoInfo' => 'Video Info',
			'videoDetail.localInfo.currentQuality' => 'Current Quality',
			'videoDetail.localInfo.duration' => 'Duration',
			'videoDetail.localInfo.resolution' => 'Resolution',
			'videoDetail.localInfo.fileInfo' => 'File Info',
			'videoDetail.localInfo.fileName' => 'File Name',
			'videoDetail.localInfo.fileSize' => 'File Size',
			'videoDetail.localInfo.filePath' => 'File Path',
			'videoDetail.localInfo.copyPath' => 'Copy Path',
			'videoDetail.localInfo.openFolder' => 'Open Folder',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Path copied to clipboard',
			'videoDetail.localInfo.openFolderFailed' => 'Failed to open folder',
			'videoDetail.videoIdIsEmpty' => 'Video ID is empty',
			'videoDetail.videoInfoIsEmpty' => 'Video info is empty',
			'videoDetail.thisIsAPrivateVideo' => 'This is a private video',
			'videoDetail.getVideoInfoFailed' => 'Get video info failed, please try again later',
			'videoDetail.noVideoSourceFound' => 'No video source found',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Tag "${tagId}" copied to clipboard',
			'videoDetail.errorLoadingVideo' => 'Error loading video',
			'videoDetail.play' => 'Play',
			'videoDetail.pause' => 'Pause',
			'videoDetail.exitAppFullscreen' => 'Exit App Fullscreen',
			'videoDetail.enterAppFullscreen' => 'Enter App Fullscreen',
			'videoDetail.exitSystemFullscreen' => 'Exit System Fullscreen',
			'videoDetail.enterSystemFullscreen' => 'Enter System Fullscreen',
			'videoDetail.seekTo' => 'Seek To',
			'videoDetail.switchResolution' => 'Switch Resolution',
			'videoDetail.switchPlaybackSpeed' => 'Switch Playback Speed',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Rewind ${num} seconds',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Fast Forward ${num} seconds',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Playing at ${rate}x speed',
			'videoDetail.brightness' => 'Brightness',
			'videoDetail.brightnessLowest' => 'Brightness is lowest',
			'videoDetail.volume' => 'Volume',
			'videoDetail.volumeMuted' => 'Volume is muted',
			'videoDetail.home' => 'Home',
			'videoDetail.videoPlayer' => 'Video Player',
			'videoDetail.videoPlayerInfo' => 'Video Player Info',
			'videoDetail.moreSettings' => 'More Settings',
			'videoDetail.videoPlayerFeatureInfo' => 'Video Player Feature Info',
			'videoDetail.autoRewind' => 'Auto Rewind',
			'videoDetail.rewindAndFastForward' => 'Rewind and Fast Forward',
			'videoDetail.volumeAndBrightness' => 'Volume and Brightness',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Center Area Double Tap Pause or Play',
			'videoDetail.showVerticalVideoInFullScreen' => 'Show Vertical Video in Full Screen',
			'videoDetail.keepLastVolumeAndBrightness' => 'Keep Last Volume and Brightness',
			'videoDetail.setProxy' => 'Set Proxy',
			'videoDetail.moreFeaturesToBeDiscovered' => 'More Features to Be Discovered...',
			'videoDetail.videoPlayerSettings' => 'Video Player Settings',
			'videoDetail.commentCount' => ({required Object num}) => '${num} comments',
			'videoDetail.writeYourCommentHere' => 'Write your comment here...',
			'videoDetail.authorOtherVideos' => 'Author\'s Other Videos',
			'videoDetail.relatedVideos' => 'Related Videos',
			'videoDetail.privateVideo' => 'This is a private video',
			'videoDetail.externalVideo' => 'This is an external video',
			'videoDetail.openInBrowser' => 'Open in Browser',
			'videoDetail.resourceDeleted' => 'This video seems to have been deleted :/',
			'videoDetail.noDownloadUrl' => 'No download URL',
			'videoDetail.startDownloading' => 'Start downloading',
			'videoDetail.downloadFailed' => 'Download failed, please try again later',
			'videoDetail.downloadSuccess' => 'Download success',
			'videoDetail.download' => 'Download',
			'videoDetail.downloadManager' => 'Download Manager',
			'videoDetail.resourceNotFound' => 'Resource not found',
			'videoDetail.videoLoadError' => 'Video load error',
			'videoDetail.authorNoOtherVideos' => 'Author has no other videos',
			'videoDetail.noRelatedVideos' => 'No related videos',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Error while loading video source',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Error while setting up listeners',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Server fault detected, automatically switched route and retrying',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Fetching video info...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Fetching video sources...',
			'videoDetail.skeleton.loadingVideo' => 'Loading video...',
			'videoDetail.skeleton.applyingSolution' => 'Applying solution...',
			'videoDetail.skeleton.addingListeners' => 'Adding listeners...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Successfully fetched video duration, starting to load video...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Loading completed',
			'videoDetail.cast.dlnaCast' => 'Cast',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Failed to start casting search: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Start casting to ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Cast failed: ${error}\nPlease try to re-search for devices or switch networks',
			'videoDetail.cast.castStopped' => 'Cast stopped',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Media Player',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Media Server',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Router',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Basic Device',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Smart Light',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'WLAN Access Point',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'WLAN Connection Device',
			'videoDetail.cast.deviceTypes.printer' => 'Printer',
			'videoDetail.cast.deviceTypes.scanner' => 'Scanner',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Digital Security Camera',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Unknown Device',
			'videoDetail.cast.currentPlatformNotSupported' => 'Current platform does not support casting',
			'videoDetail.cast.unableToGetVideoUrl' => 'Unable to get video URL, please try again later',
			'videoDetail.cast.stopCasting' => 'Stop casting',
			'videoDetail.cast.dlnaCastSheet.title' => 'Remote Cast',
			'videoDetail.cast.dlnaCastSheet.close' => 'Close',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Searching for devices...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Click search button to re-search for casting devices',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Searching',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Search Again',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'No casting devices found\nPlease ensure devices are on the same network',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Searching for devices, please wait...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Cast',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Connected to: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'No device connected',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Stop Casting',
			'videoDetail.likeAvatars.dialogTitle' => 'Who\'s secretly liking',
			'videoDetail.likeAvatars.dialogDescription' => 'Curious who they are? Flip through this "Like Album"~',
			'videoDetail.likeAvatars.closeTooltip' => 'Close',
			'videoDetail.likeAvatars.retry' => 'Retry',
			'videoDetail.likeAvatars.noLikesYet' => 'No one has appeared here yet. Be the first!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Page ${page} / ${totalPages} · Total ${totalCount} people',
			'videoDetail.likeAvatars.prevPage' => 'Previous Page',
			'videoDetail.likeAvatars.nextPage' => 'Next Page',
			'share.sharePlayList' => 'Share Play List',
			'share.wowDidYouSeeThis' => 'Wow, did you see this?',
			'share.nameIs' => 'Name is',
			'share.clickLinkToView' => 'Click link to view',
			'share.iReallyLikeThis' => 'I really like this',
			'share.shareFailed' => 'Share failed, please try again later',
			'share.share' => 'Share',
			'share.shareAsImage' => 'Share as Image',
			'share.shareAsText' => 'Share as Text',
			'share.shareAsImageDesc' => 'Share the video cover as an image',
			'share.shareAsTextDesc' => 'Share the video details as text',
			'share.shareAsImageFailed' => 'Share the video cover as an image failed, please try again later',
			'share.shareAsTextFailed' => 'Share the video details as text failed, please try again later',
			'share.shareVideo' => 'Share Video',
			'share.authorIs' => 'Author is',
			'share.shareGallery' => 'Share Gallery',
			'share.galleryTitleIs' => 'Gallery title is',
			'share.galleryAuthorIs' => 'Gallery author is',
			'share.shareUser' => 'Share User',
			'share.userNameIs' => 'User name is',
			'share.userAuthorIs' => 'User author is',
			'share.comments' => 'Comments',
			'share.shareThread' => 'Share Thread',
			'share.views' => 'Views',
			'share.sharePost' => 'Share Post',
			'share.postTitleIs' => 'Post title is',
			'share.postAuthorIs' => 'Post author is',
			'markdown.markdownSyntax' => 'Markdown Syntax',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Iwara Special Markdown Syntax',
			'markdown.internalLink' => 'Internal Link',
			'markdown.supportAutoConvertLinkBelow' => 'Support auto convert link below:',
			'markdown.convertLinkExample' => '🎬 Video Link\n🖼️ Image Link\n👤 User Link\n📌 Forum Link\n🎵 Playlist Link\n💬 Thread Link',
			'markdown.mentionUser' => 'Mention User',
			'markdown.mentionUserDescription' => 'Input @ followed by username, will be automatically converted to user link',
			'markdown.markdownBasicSyntax' => 'Markdown Basic Syntax',
			'markdown.paragraphAndLineBreak' => 'Paragraph and Line Break',
			'markdown.paragraphAndLineBreakDescription' => 'Paragraphs are separated by a line, and two spaces at the end of the line will be converted to a line break',
			'markdown.paragraphAndLineBreakSyntax' => 'This is the first paragraph\n\nThis is the second paragraph\nThis line ends with two spaces  \nwill be converted to a line break',
			'markdown.textStyle' => 'Text Style',
			'markdown.textStyleDescription' => 'Use special symbols to surround text to change style',
			'markdown.textStyleSyntax' => '**Bold Text**\n*Italic Text*\n~~Strikethrough Text~~\n`Code Text`',
			'markdown.quote' => 'Quote',
			'markdown.quoteDescription' => 'Use > symbol to create quote, multiple > to create multi-level quote',
			'markdown.quoteSyntax' => '> This is a first-level quote\n>> This is a second-level quote',
			'markdown.list' => 'List',
			'markdown.listDescription' => 'Create ordered list with number+dot, create unordered list with -',
			'markdown.listSyntax' => '1. First item\n2. Second item\n\n- Unordered item\n  - Subitem\n  - Another subitem',
			'markdown.linkAndImage' => 'Link and Image',
			'markdown.linkAndImageDescription' => 'Link format: [text](URL)\nImage format: ![description](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[link text](${link})\n![image description](${imgUrl})',
			'markdown.title' => 'Title',
			'markdown.titleDescription' => 'Use # symbol to create title, number to show level',
			'markdown.titleSyntax' => '# First-level title\n## Second-level title\n### Third-level title',
			'markdown.separator' => 'Separator',
			'markdown.separatorDescription' => 'Create separator with three or more - symbols',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Syntax',
			'forum.recent' => 'Recent',
			'forum.category' => 'Category',
			'forum.lastReply' => 'Last Reply',
			'forum.errors.pleaseSelectCategory' => 'Please select a category',
			'forum.errors.threadLocked' => 'This thread is locked, cannot reply',
			'forum.createPost' => 'Create Post',
			'forum.title' => 'Title',
			'forum.enterTitle' => 'Enter Title',
			'forum.content' => 'Content',
			'forum.enterContent' => 'Enter Content',
			'forum.writeYourContentHere' => 'Write your content here...',
			'forum.posts' => 'Posts',
			'forum.threads' => 'Threads',
			'forum.forum' => 'Forum',
			'forum.createThread' => 'Create Thread',
			'forum.selectCategory' => 'Select Category',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Cooldown remaining ${minutes} minutes ${seconds} seconds',
			'forum.groups.administration' => 'Administration',
			'forum.groups.global' => 'Global',
			'forum.groups.chinese' => 'Chinese',
			'forum.groups.japanese' => 'Japanese',
			'forum.groups.korean' => 'Korean',
			'forum.groups.other' => 'Other',
			'forum.leafNames.announcements' => 'Announcements',
			'forum.leafNames.feedback' => 'Feedback',
			'forum.leafNames.support' => 'Support',
			'forum.leafNames.general' => 'General',
			'forum.leafNames.guides' => 'Guides',
			'forum.leafNames.questions' => 'Questions',
			'forum.leafNames.requests' => 'Requests',
			'forum.leafNames.sharing' => 'Sharing',
			'forum.leafNames.general_zh' => 'General',
			'forum.leafNames.questions_zh' => 'Questions',
			'forum.leafNames.requests_zh' => 'Requests',
			'forum.leafNames.support_zh' => 'Support',
			'forum.leafNames.general_ja' => 'General',
			'forum.leafNames.questions_ja' => 'Questions',
			'forum.leafNames.requests_ja' => 'Requests',
			'forum.leafNames.support_ja' => 'Support',
			'forum.leafNames.korean' => 'Korean',
			'forum.leafNames.other' => 'Other',
			'forum.leafDescriptions.announcements' => 'Official important notifications and announcements',
			'forum.leafDescriptions.feedback' => 'Feedback on the website\'s features and services',
			'forum.leafDescriptions.support' => 'Help to resolve website-related issues',
			'forum.leafDescriptions.general' => 'Discuss any topic',
			'forum.leafDescriptions.guides' => 'Share your experiences and tutorials',
			'forum.leafDescriptions.questions' => 'Raise your inquiries',
			'forum.leafDescriptions.requests' => 'Post your requests',
			'forum.leafDescriptions.sharing' => 'Share interesting content',
			'forum.leafDescriptions.general_zh' => 'Discuss any topic',
			'forum.leafDescriptions.questions_zh' => 'Raise your inquiries',
			'forum.leafDescriptions.requests_zh' => 'Post your requests',
			'forum.leafDescriptions.support_zh' => 'Help to resolve website-related issues',
			'forum.leafDescriptions.general_ja' => 'Discuss any topic',
			'forum.leafDescriptions.questions_ja' => 'Raise your inquiries',
			'forum.leafDescriptions.requests_ja' => 'Post your requests',
			'forum.leafDescriptions.support_ja' => 'Help to resolve website-related issues',
			'forum.leafDescriptions.korean' => 'Discussions related to Korean',
			'forum.leafDescriptions.other' => 'Other unclassified content',
			'forum.reply' => 'Reply',
			'forum.pendingReview' => 'Pending Review',
			'forum.editedAt' => 'Edited At',
			'forum.copySuccess' => 'Copied to clipboard',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Copied to clipboard: ${str}',
			'forum.editReply' => 'Edit Reply',
			'forum.editTitle' => 'Edit Title',
			'forum.submit' => 'Submit',
			'notifications.errors.unsupportedNotificationType' => 'Unsupported notification type',
			'notifications.errors.unknownUser' => 'Unknown user',
			_ => null,
		} ?? switch (path) {
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Unsupported notification type: ${type}',
			'notifications.errors.unknownNotificationType' => 'Unknown notification type',
			'notifications.notifications' => 'Notifications',
			'notifications.profile' => 'Profile',
			'notifications.postedNewComment' => 'Posted new comment',
			'notifications.inYour' => 'In your',
			'notifications.video' => 'Video',
			'notifications.repliedYourVideoComment' => 'Replied your video comment',
			'notifications.copyInfoToClipboard' => 'Copy notification info to clipboard',
			'notifications.copySuccess' => 'Copied to clipboard',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Copied to clipboard: ${str}',
			'notifications.markAllAsRead' => 'Mark all as read',
			'notifications.markAllAsReadSuccess' => 'All notifications have been marked as read',
			'notifications.markAllAsReadFailed' => 'Mark all as read failed',
			'notifications.markSelectedAsRead' => 'Mark selected as read',
			'notifications.markSelectedAsReadSuccess' => 'Selected notifications have been marked as read',
			'notifications.markSelectedAsReadFailed' => 'Mark selected as read failed',
			'notifications.markAsRead' => 'Mark as read',
			'notifications.markAsReadSuccess' => 'Notification has been marked as read',
			'notifications.markAsReadFailed' => 'Notification marked as read failed',
			'notifications.notificationTypeHelp' => 'Notification Type Help',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Due to the lack of notification type details, the supported types may not cover the messages you currently receive',
			'notifications.helpUsImproveNotificationTypeSupport' => 'If you are willing to help us improve the support for notification types',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Copy the notification information\n2. 🐞 Submit an issue to the project repository\n\n⚠️ Note: Notification information may contain personal privacy, if you do not want to public, you can also send it to the project author by email.',
			'notifications.goToRepository' => 'Go to Repository',
			'notifications.copy' => 'Copy',
			'notifications.commentApproved' => 'Comment Approved',
			'notifications.repliedYourProfileComment' => 'Replied your profile comment',
			'notifications.kReplied' => 'replied to your comment on',
			'notifications.kCommented' => 'commented on your',
			'notifications.kVideo' => 'video',
			'notifications.kGallery' => 'gallery',
			'notifications.kProfile' => 'profile',
			'notifications.kThread' => 'thread',
			'notifications.kPost' => 'post',
			'notifications.kCommentSection' => 'comment section',
			'notifications.kApprovedComment' => 'Comment approved',
			'notifications.kApprovedVideo' => 'Video approved',
			'notifications.kApprovedGallery' => 'Gallery approved',
			'notifications.kApprovedThread' => 'Thread approved',
			'notifications.kApprovedPost' => 'Post approved',
			'notifications.kApprovedForumPost' => 'Forum post approved',
			'notifications.kRejectedContent' => 'Content review rejected',
			'notifications.kUnknownType' => 'Unknown notification type',
			'conversation.errors.pleaseSelectAUser' => 'Please select a user',
			'conversation.errors.pleaseEnterATitle' => 'Please enter a title',
			'conversation.errors.clickToSelectAUser' => 'Click to select a user',
			'conversation.errors.loadFailedClickToRetry' => 'Load failed, click to retry',
			'conversation.errors.loadFailed' => 'Load failed',
			'conversation.errors.clickToRetry' => 'Click to retry',
			'conversation.errors.noMoreConversations' => 'No more conversations',
			'conversation.conversation' => 'Conversation',
			'conversation.startConversation' => 'Start Conversation',
			'conversation.noConversation' => 'No conversation',
			'conversation.selectFromLeftListAndStartConversation' => 'Select from left list and start conversation',
			'conversation.title' => 'Title',
			'conversation.body' => 'Body',
			'conversation.selectAUser' => 'Select a user',
			'conversation.searchUsers' => 'Search users...',
			'conversation.tmpNoConversions' => 'No conversions',
			'conversation.deleteThisMessage' => 'Delete this message',
			'conversation.deleteThisMessageSubtitle' => 'This operation cannot be undone',
			'conversation.writeMessageHere' => 'Write message here...',
			'conversation.sendMessage' => 'Send message',
			'splash.errors.initializationFailed' => 'Initialization failed, please restart the app',
			'splash.preparing' => 'Preparing...',
			'splash.initializing' => 'Initializing...',
			'splash.loading' => 'Loading...',
			'splash.ready' => 'Ready',
			'splash.initializingMessageService' => 'Initializing message service...',
			'download.errors.imageModelNotFound' => 'Image model not found',
			'download.errors.downloadFailed' => 'Download failed',
			'download.errors.videoInfoNotFound' => 'Video info not found',
			'download.errors.downloadTaskAlreadyExists' => 'Download task already exists',
			'download.errors.videoAlreadyDownloaded' => 'Video already downloaded',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Add download task failed: ${errorInfo}',
			'download.errors.userPausedDownload' => 'User paused download',
			'download.errors.unknown' => 'Unknown',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'File system error: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Unknown error: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Connection timeout',
			'download.errors.sendTimeout' => 'Send timeout',
			'download.errors.receiveTimeout' => 'Receive timeout',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Server error: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Unknown network error',
			'download.errors.sslHandshakeFailed' => 'SSL handshake failed, please check your network',
			'download.errors.connectionFailed' => 'Connection failed, please check your network',
			'download.errors.serviceIsClosing' => 'Download service is closing',
			'download.errors.partialDownloadFailed' => 'Partial content download failed',
			'download.errors.noDownloadTask' => 'No download task',
			'download.errors.taskNotFoundOrDataError' => 'Task not found or data error',
			'download.errors.fileNotFound' => 'File not found',
			'download.errors.openFolderFailed' => 'Failed to open folder',
			'download.errors.copyDownloadUrlFailed' => 'Failed to copy download URL',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Failed to open folder: ${message}',
			'download.errors.directoryNotFound' => 'Directory not found',
			'download.errors.copyFailed' => 'Copy failed',
			'download.errors.openFileFailed' => 'Failed to open file',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Failed to open file: ${message}',
			'download.errors.playLocallyFailed' => 'Failed to play locally',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Failed to play locally: ${message}',
			'download.errors.noDownloadSource' => 'No download source',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'No download source, please wait for information loading to be completed and try again',
			'download.errors.noActiveDownloadTask' => 'No active download task',
			'download.errors.noFailedDownloadTask' => 'No failed download task',
			'download.errors.noCompletedDownloadTask' => 'No completed download task',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Task already completed, do not add again',
			'download.errors.linkExpiredTryAgain' => 'Link expired, trying to get new download link',
			'download.errors.linkExpiredTryAgainSuccess' => 'Link expired, trying to get new download link success',
			'download.errors.linkExpiredTryAgainFailed' => 'Link expired, trying to get new download link failed',
			'download.errors.taskDeleted' => 'Task deleted',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Unsupported image format: ${format}',
			'download.errors.deleteFileError' => 'Failed to delete file, possibly because the file is being used by another process',
			'download.errors.deleteTaskError' => 'Failed to delete task',
			'download.errors.canNotRefreshVideoTask' => 'Failed to refresh video task',
			'download.errors.taskAlreadyProcessing' => 'Task already processing',
			'download.errors.taskNotFound' => 'Task not found',
			'download.errors.failedToLoadTasks' => 'Failed to load tasks',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Partial download failed: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Unsupported image format: ${extension}, you can try to download it to your device to view it',
			'download.errors.imageLoadFailed' => 'Image load failed',
			'download.errors.pleaseTryOtherViewer' => 'Please try using other viewers to open',
			'download.downloadList' => 'Download List',
			'download.viewDownloadList' => 'View Download List',
			'download.download' => 'Download',
			'download.startDownloading' => 'Start Downloading',
			'download.clearAllFailedTasks' => 'Clear All Failed Tasks',
			'download.clearAllFailedTasksConfirmation' => 'Are you sure you want to clear all failed download tasks? The files of these tasks will also be deleted.',
			'download.clearAllFailedTasksSuccess' => 'Cleared all failed tasks',
			'download.clearAllFailedTasksError' => 'Error occurred while clearing failed tasks',
			'download.downloadStatus' => 'Download Status',
			'download.imageList' => 'Image List',
			'download.retryDownload' => 'Retry Download',
			'download.notDownloaded' => 'Not Downloaded',
			'download.downloaded' => 'Downloaded',
			'download.waitingForDownload' => 'Waiting for Download',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Downloading (${downloaded}/${total} images ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Downloading (${downloaded} images)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Paused (${downloaded}/${total} images ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'Paused (${downloaded} images)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Downloaded (Total ${total} images)',
			'download.viewVideoDetail' => 'View Video Detail',
			'download.viewGalleryDetail' => 'View Gallery Detail',
			'download.moreOptions' => 'More Options',
			'download.openFile' => 'Open File',
			'download.playLocally' => 'Play Locally',
			'download.pause' => 'Pause',
			'download.resume' => 'Resume',
			'download.copyDownloadUrl' => 'Copy Download URL',
			'download.showInFolder' => 'Show in Folder',
			'download.deleteTask' => 'Delete Task',
			'download.deleteTaskConfirmation' => 'Are you sure you want to delete this download task?\nThe task file will also be deleted.',
			'download.forceDeleteTask' => 'Force Delete Task',
			'download.forceDeleteTaskConfirmation' => 'Are you sure you want to force delete this download task?\nThe task file will also be deleted, even if the file is being used.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Downloading ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'Paused ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'Paused • Downloaded ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Downloaded • ${size}',
			'download.copyDownloadUrlSuccess' => 'Download URL copied',
			'download.totalImageNums' => ({required Object num}) => '${num} images',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'Downloading',
			'download.failed' => 'Failed',
			'download.completed' => 'Completed',
			'download.downloadDetail' => 'Download Detail',
			'download.copy' => 'Copy',
			'download.copySuccess' => 'Copied',
			'download.waiting' => 'Waiting',
			'download.paused' => 'Paused',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Downloading ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Gallery Download Completed: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Download Completed: ${fileName}',
			'download.stillInDevelopment' => 'Still in development',
			'download.saveToAppDirectory' => 'Save to app directory',
			'download.alreadyDownloadedWithQuality' => 'Already downloaded with the same quality, continue downloading?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Already downloaded with qualities: ${qualities}, continue downloading?',
			'download.otherQualities' => 'Other qualities',
			'favorite.errors.addFailed' => 'Add failed',
			'favorite.errors.addSuccess' => 'Add success',
			'favorite.errors.deleteFolderFailed' => 'Delete folder failed',
			'favorite.errors.deleteFolderSuccess' => 'Delete folder success',
			'favorite.errors.folderNameCannotBeEmpty' => 'Folder name cannot be empty',
			'favorite.add' => 'Add',
			'favorite.addSuccess' => 'Add success',
			'favorite.addFailed' => 'Add failed',
			'favorite.remove' => 'Remove',
			'favorite.removeSuccess' => 'Remove success',
			'favorite.removeFailed' => 'Remove failed',
			'favorite.removeConfirmation' => 'Are you sure you want to remove this item from favorites?',
			'favorite.removeConfirmationSuccess' => 'Item removed from favorites',
			'favorite.removeConfirmationFailed' => 'Failed to remove item from favorites',
			'favorite.createFolderSuccess' => 'Folder created successfully',
			'favorite.createFolderFailed' => 'Failed to create folder',
			'favorite.createFolder' => 'Create Folder',
			'favorite.enterFolderName' => 'Enter folder name',
			'favorite.enterFolderNameHere' => 'Enter folder name here...',
			'favorite.create' => 'Create',
			'favorite.items' => 'Items',
			'favorite.newFolderName' => 'New Folder',
			'favorite.searchFolders' => 'Search folders...',
			'favorite.searchItems' => 'Search items...',
			'favorite.createdAt' => 'Created At',
			'favorite.myFavorites' => 'My Favorites',
			'favorite.deleteFolderTitle' => 'Delete Folder',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Are you sure you want to delete ${title} folder?',
			'favorite.removeItemTitle' => 'Remove Item',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Are you sure you want to delete ${title} item?',
			'favorite.removeItemSuccess' => 'Item removed from favorites',
			'favorite.removeItemFailed' => 'Failed to remove item from favorites',
			'favorite.localizeFavorite' => 'Local Favorite',
			'favorite.editFolderTitle' => 'Edit Folder',
			'favorite.editFolderSuccess' => 'Folder updated successfully',
			'favorite.editFolderFailed' => 'Failed to update folder',
			'favorite.searchTags' => 'Search tags',
			'translation.currentService' => 'Current Service',
			'translation.testConnection' => 'Test Connection',
			'translation.testConnectionSuccess' => 'Test connection success',
			'translation.testConnectionFailed' => 'Test connection failed',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Test connection failed: ${message}',
			'translation.translation' => 'Translation',
			'translation.needVerification' => 'Need Verification',
			'translation.needVerificationContent' => 'Please test the connection first before enabling AI translation',
			'translation.confirm' => 'Confirm',
			'translation.disclaimer' => 'Disclaimer',
			'translation.riskWarning' => 'Risk Warning',
			'translation.dureToRisk1' => 'Due to the text being generated by users, it may contain content that violates the content policy of the AI service provider',
			'translation.dureToRisk2' => 'Inappropriate content may lead to API key suspension or service termination',
			'translation.operationSuggestion' => 'Operation Suggestion',
			'translation.operationSuggestion1' => '1. Use before strictly reviewing the content to be translated',
			'translation.operationSuggestion2' => '2. Avoid translating content involving violence, adult content, etc.',
			'translation.apiConfig' => 'API Config',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Modify configuration will automatically close AI translation, need to test again after opening',
			'translation.apiAddress' => 'API Address',
			'translation.modelName' => 'Model Name',
			'translation.modelNameHintText' => 'For example: gpt-4-turbo',
			'translation.maxTokens' => 'Max Tokens',
			'translation.maxTokensHintText' => 'For example: 32000',
			'translation.temperature' => 'Temperature',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Click test button to verify API connection validity',
			'translation.requestPreview' => 'Request Preview',
			'translation.enableAITranslation' => 'Enable AI',
			'translation.enabled' => 'Enabled',
			'translation.disabled' => 'Disabled',
			'translation.testing' => 'Testing...',
			'translation.testNow' => 'Test Now',
			'translation.connectionStatus' => 'Connection Status',
			'translation.success' => 'Success',
			'translation.failed' => 'Failed',
			'translation.information' => 'Information',
			'translation.viewRawResponse' => 'View Raw Response',
			'translation.pleaseCheckInputParametersFormat' => 'Please check input parameters format',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Please fill in API address, model name and key',
			'translation.pleaseFillInValidConfigurationParameters' => 'Please fill in valid configuration parameters',
			'translation.pleaseCompleteConnectionTest' => 'Please complete connection test',
			'translation.notConfigured' => 'Not Configured',
			'translation.apiEndpoint' => 'API Endpoint',
			'translation.configuredKey' => 'Configured Key',
			'translation.notConfiguredKey' => 'Not Configured Key',
			'translation.authenticationStatus' => 'Authentication Status',
			'translation.thisFieldCannotBeEmpty' => 'This field cannot be empty',
			'translation.apiKey' => 'API Key',
			'translation.apiKeyCannotBeEmpty' => 'API key cannot be empty',
			'translation.pleaseEnterValidNumber' => 'Please enter valid number',
			'translation.range' => 'Range',
			'translation.mustBeGreaterThan' => 'Must be greater than',
			'translation.invalidAPIResponse' => 'Invalid API response',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Connection failed: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'AI translation is not enabled, please enable it in settings',
			'translation.goToSettings' => 'Go to Settings',
			'translation.disableAITranslation' => 'Disable AI Translation',
			'translation.currentValue' => 'Current Value',
			'translation.configureTranslationStrategy' => 'Configure Translation Strategy',
			'translation.advancedSettings' => 'Advanced Settings',
			'translation.translationPrompt' => 'Translation Prompt',
			'translation.promptHint' => 'Please enter translation prompt, use [TL] as the placeholder for the target language',
			'translation.promptHelperText' => 'The prompt must contain [TL] as the placeholder for the target language',
			'translation.promptMustContainTargetLang' => 'The prompt must contain [TL] placeholder',
			'translation.aiTranslationWillBeDisabled' => 'AI translation will be disabled',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Due to the change of basic configuration, AI translation will be disabled',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Due to the change of translation prompt, AI translation will be disabled',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Due to the change of parameter configuration, AI translation will be disabled',
			'translation.onlyOpenAIAPISupported' => 'Currently only supports OpenAI-compatible API format (application/json request body)',
			'translation.streamingTranslation' => 'Streaming Translation',
			'translation.streamingTranslationSupported' => 'Streaming Translation Supported',
			'translation.streamingTranslationNotSupported' => 'Streaming Translation Not Supported',
			'translation.streamingTranslationDescription' => 'Streaming translation can display results in real-time during the translation process, providing a better user experience',
			'translation.usingFullUrlWithHash' => 'Using full URL (ending with #)',
			'translation.baseUrlInputHelperText' => 'When ending with #, it will be used as the actual request address',
			'translation.currentActualUrl' => ({required Object url}) => 'Current actual URL: ${url}',
			'translation.urlEndingWithHashTip' => 'URL ending with # will be used directly without adding any suffix',
			'translation.streamingTranslationWarning' => 'Note: This feature requires API service support for streaming transmission, some models may not support it',
			'translation.translationService' => 'Translation Service',
			'translation.translationServiceDescription' => 'Select your preferred translation service',
			'translation.googleTranslation' => 'Google Translation',
			'translation.googleTranslationDescription' => 'Free online translation service supporting multiple languages',
			'translation.aiTranslation' => 'AI Translation',
			'translation.aiTranslationDescription' => 'Intelligent translation service based on large language models',
			'translation.deeplxTranslation' => 'DeepLX Translation',
			'translation.deeplxTranslationDescription' => 'Open source implementation of DeepL translation, providing high-quality translation',
			'translation.googleTranslationFeatures' => 'Features',
			'translation.freeToUse' => 'Free to use',
			'translation.freeToUseDescription' => 'No configuration required, ready to use',
			'translation.fastResponse' => 'Fast response',
			'translation.fastResponseDescription' => 'Fast translation speed with low latency',
			'translation.stableAndReliable' => 'Stable and reliable',
			'translation.stableAndReliableDescription' => 'Based on Google official API',
			'translation.enabledDefaultService' => 'Enabled - Default translation service',
			'translation.notEnabled' => 'Not enabled',
			'translation.deeplxTranslationService' => 'DeepLX Translation Service',
			'translation.deeplxDescription' => 'DeepLX is an open source implementation of DeepL translation, supporting Free, Pro and Official endpoint modes',
			'translation.serverAddress' => 'Server Address',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Base address of DeepLX server',
			'translation.endpointType' => 'Endpoint Type',
			'translation.freeEndpoint' => 'Free - Free endpoint, may have rate limits',
			'translation.proEndpoint' => 'Pro - Requires dl_session, more stable',
			'translation.officialEndpoint' => 'Official - Official API format',
			'translation.finalRequestUrl' => 'Final Request URL',
			'translation.apiKeyOptional' => 'API Key (Optional)',
			'translation.apiKeyOptionalHint' => 'For accessing protected DeepLX services',
			'translation.apiKeyOptionalHelperText' => 'Some DeepLX services require API Key for authentication',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'dl_session parameter required for Pro mode',
			'translation.dlSessionHelperText' => 'Session parameter required for Pro endpoint, obtained from DeepL Pro account',
			'translation.proModeRequiresDlSession' => 'Pro mode requires dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Click test button to verify DeepLX API connection',
			'translation.enableDeepLXTranslation' => 'Enable DeepLX Translation',
			'translation.deepLXTranslationWillBeDisabled' => 'DeepLX translation will be disabled due to configuration changes',
			'translation.translatedResult' => 'Translated Result',
			'translation.testSuccess' => 'Test successful',
			'translation.pleaseFillInDeepLXServerAddress' => 'Please fill in DeepLX server address',
			'translation.invalidAPIResponseFormat' => 'Invalid API response format',
			'translation.translationServiceReturnedError' => 'Translation service returned error or empty result',
			'translation.connectionFailed' => 'Connection failed',
			'translation.translationFailed' => 'Translation failed',
			'translation.aiTranslationFailed' => 'AI translation failed',
			'translation.deeplxTranslationFailed' => 'DeepLX translation failed',
			'translation.aiTranslationTestFailed' => 'AI translation test failed',
			'translation.deeplxTranslationTestFailed' => 'DeepLX translation test failed',
			'translation.streamingTranslationTimeout' => 'Streaming translation timeout, forcing resource cleanup',
			'translation.translationRequestTimeout' => 'Translation request timeout',
			'translation.streamingTranslationDataTimeout' => 'Streaming translation data reception timeout',
			'translation.dataReceptionTimeout' => 'Data reception timeout',
			'translation.streamDataParseError' => 'Error parsing stream data',
			'translation.streamingTranslationFailed' => 'Streaming translation failed',
			'translation.fallbackTranslationFailed' => 'Fallback to normal translation also failed',
			'translation.translationSettings' => 'Translation Settings',
			'translation.enableGoogleTranslation' => 'Enable Google Translation',
			'navigationOrderSettings.title' => 'Navigation Order Settings',
			'navigationOrderSettings.customNavigationOrder' => 'Custom Navigation Order',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Drag to adjust the display order of pages in the bottom navigation bar and sidebar',
			'navigationOrderSettings.restartRequired' => 'Restart app required',
			'navigationOrderSettings.navigationItemSorting' => 'Navigation Item Sorting',
			'navigationOrderSettings.done' => 'Done',
			'navigationOrderSettings.edit' => 'Edit',
			'navigationOrderSettings.reset' => 'Reset',
			'navigationOrderSettings.previewEffect' => 'Preview Effect',
			'navigationOrderSettings.bottomNavigationPreview' => 'Bottom Navigation Preview:',
			'navigationOrderSettings.sidebarPreview' => 'Sidebar Preview:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Confirm Reset Navigation Order',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Are you sure you want to reset the navigation order to default settings?',
			'navigationOrderSettings.cancel' => 'Cancel',
			'navigationOrderSettings.videoDescription' => 'Browse popular video content',
			'navigationOrderSettings.galleryDescription' => 'Browse images and galleries',
			'navigationOrderSettings.subscriptionDescription' => 'View latest content from followed users',
			'navigationOrderSettings.forumDescription' => 'Participate in community discussions',
			'displaySettings.title' => 'Display Settings',
			'displaySettings.layoutSettings' => 'Layout Settings',
			'displaySettings.layoutSettingsDesc' => 'Customize column count and breakpoint configuration',
			'displaySettings.gridLayout' => 'Grid Layout',
			'displaySettings.navigationOrderSettings' => 'Navigation Order Settings',
			'displaySettings.customNavigationOrder' => 'Custom Navigation Order',
			'displaySettings.customNavigationOrderDesc' => 'Adjust the display order of pages in the bottom navigation bar and sidebar',
			'layoutSettings.title' => 'Layout Settings',
			'layoutSettings.descriptionTitle' => 'Layout Configuration Description',
			'layoutSettings.descriptionContent' => 'The configuration here will determine the number of columns displayed in video and gallery list pages. You can choose auto mode to let the system automatically adjust based on screen width, or choose manual mode to fix the column count.',
			'layoutSettings.layoutMode' => 'Layout Mode',
			'layoutSettings.reset' => 'Reset',
			'layoutSettings.autoMode' => 'Auto Mode',
			'layoutSettings.autoModeDesc' => 'Automatically adjust based on screen width',
			'layoutSettings.manualMode' => 'Manual Mode',
			'layoutSettings.manualModeDesc' => 'Use fixed column count',
			'layoutSettings.manualSettings' => 'Manual Settings',
			'layoutSettings.fixedColumns' => 'Fixed Columns',
			'layoutSettings.columns' => 'columns',
			'layoutSettings.breakpointConfig' => 'Breakpoint Configuration',
			'layoutSettings.add' => 'Add',
			'layoutSettings.defaultColumns' => 'Default Columns',
			'layoutSettings.defaultColumnsDesc' => 'Default display for large screens',
			'layoutSettings.previewEffect' => 'Preview Effect',
			'layoutSettings.screenWidth' => 'Screen Width',
			'layoutSettings.addBreakpoint' => 'Add Breakpoint',
			'layoutSettings.editBreakpoint' => 'Edit Breakpoint',
			'layoutSettings.deleteBreakpoint' => 'Delete Breakpoint',
			'layoutSettings.screenWidthLabel' => 'Screen Width',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Columns',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Please enter width',
			'layoutSettings.enterValidWidth' => 'Please enter valid width',
			'layoutSettings.widthCannotExceed9999' => 'Width cannot exceed 9999',
			'layoutSettings.breakpointAlreadyExists' => 'Breakpoint already exists',
			'layoutSettings.enterColumns' => 'Please enter columns',
			'layoutSettings.enterValidColumns' => 'Please enter valid columns',
			'layoutSettings.columnsCannotExceed12' => 'Columns cannot exceed 12',
			'layoutSettings.breakpointConflict' => 'Breakpoint already exists',
			'layoutSettings.confirmResetLayoutSettings' => 'Reset Layout Settings',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Are you sure you want to reset all layout settings to default values?\n\nWill restore to:\n• Auto mode\n• Default breakpoint configuration',
			'layoutSettings.resetToDefaults' => 'Reset to Defaults',
			'layoutSettings.confirmDeleteBreakpoint' => 'Delete Breakpoint',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Are you sure you want to delete the ${width}px breakpoint?',
			'layoutSettings.noCustomBreakpoints' => 'No custom breakpoints, using default columns',
			'layoutSettings.breakpointRange' => 'Breakpoint Range',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Edit',
			'layoutSettings.delete' => 'Delete',
			'layoutSettings.cancel' => 'Cancel',
			'layoutSettings.save' => 'Save',
			'mediaPlayer.videoPlayerError' => 'Video Player Error',
			'mediaPlayer.videoLoadFailed' => 'Video Load Failed',
			'mediaPlayer.videoCodecNotSupported' => 'Video Codec Not Supported',
			'mediaPlayer.networkConnectionIssue' => 'Network Connection Issue',
			'mediaPlayer.insufficientPermission' => 'Insufficient Permission',
			'mediaPlayer.unsupportedVideoFormat' => 'Unsupported Video Format',
			'mediaPlayer.retry' => 'Retry',
			'mediaPlayer.externalPlayer' => 'External Player',
			'mediaPlayer.detailedErrorInfo' => 'Detailed Error Information',
			'mediaPlayer.format' => 'Format',
			'mediaPlayer.suggestion' => 'Suggestion',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Android devices have limited support for WEBM format. It is recommended to use an external player or download a player app that supports WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'Current device does not support the codec for this video format',
			'mediaPlayer.checkNetworkConnection' => 'Please check your network connection and try again',
			'mediaPlayer.appMayLackMediaPermission' => 'The app may lack necessary media playback permissions',
			'mediaPlayer.tryOtherVideoPlayer' => 'Please try using other video players',
			'mediaPlayer.video' => 'VIDEO',
			'mediaPlayer.local' => 'Local',
			'mediaPlayer.unknown' => 'Unknown',
			'mediaPlayer.localVideoPathEmpty' => 'Local video path is empty',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Local video file does not exist: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Unable to play local video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Drop video file here to play',
			'mediaPlayer.supportedFormats' => 'Supported formats: MP4, MKV, AVI, MOV, WEBM, etc.',
			'mediaPlayer.noSupportedVideoFile' => 'No supported video file found',
			'mediaPlayer.retryingOpenVideoLink' => 'Video link open failed, retrying',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Unable to load decoder: ${event}. Try switching to software decoding in player settings and re-enter the page',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Video load error: ${event}',
			'mediaPlayer.imageLoadFailed' => 'Image Load Failed',
			'mediaPlayer.unsupportedImageFormat' => 'Unsupported Image Format',
			'mediaPlayer.tryOtherViewer' => 'Please try using other viewers',
			'linkInputDialog.title' => 'Input Link',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Support intelligently identify multiple ${webName} links and quickly jump to the corresponding page in the app (separate links from other text with spaces)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Please enter ${webName} link',
			'linkInputDialog.validatorEmptyLink' => 'Please enter link',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'No valid ${webName} link detected',
			'linkInputDialog.multipleLinksDetected' => 'Multiple links detected, please select one:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Not a valid ${webName} link',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Link parsing error: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Unsupported Link',
			'linkInputDialog.unsupportedLinkDialogContent' => 'This link type cannot be opened directly in the app and needs to be accessed using an external browser.\n\nDo you want to open this link in a browser?',
			'linkInputDialog.openInBrowser' => 'Open in Browser',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Confirm Open Browser',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'The following link is about to be opened in an external browser:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Are you sure you want to continue?',
			'linkInputDialog.browserOpenFailed' => 'Failed to open link',
			'linkInputDialog.unsupportedLink' => 'Unsupported Link',
			'linkInputDialog.cancel' => 'Cancel',
			'linkInputDialog.confirm' => 'Open in Browser',
			'log.logManagement' => 'Log Management',
			'log.enableLogPersistence' => 'Enable Log Persistence',
			'log.enableLogPersistenceDesc' => 'Save logs to the database for analysis',
			'log.logDatabaseSizeLimit' => 'Log Database Size Limit',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Current: ${size}',
			'log.exportCurrentLogs' => 'Export Current Logs',
			'log.exportCurrentLogsDesc' => 'Export the current application logs to help developers diagnose problems',
			'log.exportHistoryLogs' => 'Export History Logs',
			'log.exportHistoryLogsDesc' => 'Export logs within a specified date range',
			'log.exportMergedLogs' => 'Export Merged Logs',
			'log.exportMergedLogsDesc' => 'Export merged logs within a specified date range',
			'log.showLogStats' => 'Show Log Stats',
			'log.logExportSuccess' => 'Log export success',
			'log.logExportFailed' => ({required Object error}) => 'Log export failed: ${error}',
			'log.showLogStatsDesc' => 'View statistics of various types of logs',
			'log.logExtractFailed' => ({required Object error}) => 'Failed to get log statistics: ${error}',
			'log.clearAllLogs' => 'Clear All Logs',
			'log.clearAllLogsDesc' => 'Clear all log data',
			'log.confirmClearAllLogs' => 'Confirm Clear',
			'log.confirmClearAllLogsDesc' => 'Are you sure you want to clear all log data? This operation cannot be undone.',
			'log.clearAllLogsSuccess' => 'Log cleared successfully',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Failed to clear logs: ${error}',
			'log.unableToGetLogSizeInfo' => 'Unable to get log size information',
			'log.currentLogSize' => 'Current Log Size:',
			'log.logCount' => 'Log Count:',
			'log.logCountUnit' => 'logs',
			'log.logSizeLimit' => 'Log Size Limit:',
			'log.usageRate' => 'Usage Rate:',
			'log.exceedLimit' => 'Exceed Limit',
			'log.remaining' => 'Remaining',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Current log size exceeded, please clean old logs or increase log size limit',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'Current log size almost exceeded, please clean old logs',
			'log.cleaningOldLogs' => 'Cleaning old logs...',
			'log.logCleaningCompleted' => 'Log cleaning completed',
			'log.logCleaningProcessMayNotBeCompleted' => 'Log cleaning process may not be completed',
			'log.cleanExceededLogs' => 'Clean exceeded logs',
			'log.noLogsToExport' => 'No logs to export',
			'log.exportingLogs' => 'Exporting logs...',
			'log.noHistoryLogsToExport' => 'No history logs to export, please try using the app for a while first',
			'log.selectLogDate' => 'Select Log Date',
			'log.today' => 'Today',
			_ => null,
		} ?? switch (path) {
			'log.selectMergeRange' => 'Select Merge Range',
			'log.selectMergeRangeHint' => 'Please select the log time range to merge',
			'log.selectMergeRangeDays' => ({required Object days}) => 'Recent ${days} days',
			'log.logStats' => 'Log Stats',
			'log.todayLogs' => ({required Object count}) => 'Today Logs: ${count} logs',
			'log.recent7DaysLogs' => ({required Object count}) => 'Recent 7 Days Logs: ${count} logs',
			'log.totalLogs' => ({required Object count}) => 'Total Logs: ${count} logs',
			'log.setLogDatabaseSizeLimit' => 'Set Log Database Size Limit',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Current Log Size: ${size}',
			'log.warning' => 'Warning',
			'log.newSizeLimit' => ({required Object size}) => 'New size limit: ${size}',
			'log.confirmToContinue' => 'Confirm to continue',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Log size limit set to ${size}',
			'emoji.name' => 'Emoji',
			'emoji.size' => 'Size',
			'emoji.small' => 'Small',
			'emoji.medium' => 'Medium',
			'emoji.large' => 'Large',
			'emoji.extraLarge' => 'Extra Large',
			'emoji.copyEmojiLinkSuccess' => 'Emoji link copied',
			'emoji.preview' => 'Emoji Preview',
			'emoji.library' => 'Emoji Library',
			'emoji.noEmojis' => 'No emojis',
			'emoji.clickToAddEmojis' => 'Click the button in the top right to add emojis',
			'emoji.addEmojis' => 'Add Emojis',
			'emoji.imagePreview' => 'Image Preview',
			'emoji.imageLoadFailed' => 'Image load failed',
			'emoji.loading' => 'Loading...',
			'emoji.delete' => 'Delete',
			'emoji.close' => 'Close',
			'emoji.deleteImage' => 'Delete Image',
			'emoji.confirmDeleteImage' => 'Are you sure you want to delete this image?',
			'emoji.cancel' => 'Cancel',
			'emoji.batchDelete' => 'Batch Delete',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Are you sure you want to delete the selected ${count} images? This operation cannot be undone.',
			'emoji.deleteSuccess' => 'Successfully deleted',
			'emoji.addImage' => 'Add Image',
			'emoji.addImageByUrl' => 'Add by URL',
			'emoji.addImageUrl' => 'Add Image URL',
			'emoji.imageUrl' => 'Image URL',
			'emoji.enterImageUrl' => 'Please enter image URL',
			'emoji.add' => 'Add',
			'emoji.batchImport' => 'Batch Import',
			'emoji.enterJsonUrlArray' => 'Please enter JSON format URL array:',
			'emoji.formatExample' => 'Format example:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Please paste JSON format URL array',
			'emoji.import' => 'Import',
			'emoji.importSuccess' => ({required Object count}) => 'Successfully imported ${count} images',
			'emoji.jsonFormatError' => 'JSON format error, please check input',
			'emoji.createGroup' => 'Create Emoji Group',
			'emoji.groupName' => 'Group Name',
			'emoji.enterGroupName' => 'Please enter group name',
			'emoji.create' => 'Create',
			'emoji.editGroupName' => 'Edit Group Name',
			'emoji.save' => 'Save',
			'emoji.deleteGroup' => 'Delete Group',
			'emoji.confirmDeleteGroup' => 'Are you sure you want to delete this emoji group? All images in the group will also be deleted.',
			'emoji.imageCount' => ({required Object count}) => '${count} images',
			'emoji.selectEmoji' => 'Select Emoji',
			'emoji.noEmojisInGroup' => 'No emojis in this group',
			'emoji.goToSettingsToAddEmojis' => 'Go to settings to add emojis',
			'emoji.emojiManagement' => 'Emoji Management',
			'emoji.manageEmojiGroupsAndImages' => 'Manage emoji groups and images',
			'emoji.uploadLocalImages' => 'Upload Local Images',
			'emoji.uploadingImages' => 'Uploading Images',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Uploading ${count} images, please wait...',
			'emoji.doNotCloseDialog' => 'Please do not close this dialog',
			'emoji.uploadSuccess' => ({required Object count}) => 'Successfully uploaded ${count} images',
			'emoji.uploadFailed' => ({required Object count}) => 'Failed ${count}',
			'emoji.uploadFailedMessage' => 'Image upload failed, please check network connection or file format',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Error occurred during upload: ${error}',
			'searchFilter.selectField' => 'Select Field',
			'searchFilter.add' => 'Add',
			'searchFilter.clear' => 'Clear',
			'searchFilter.clearAll' => 'Clear All',
			'searchFilter.generatedQuery' => 'Generated Query',
			'searchFilter.copyToClipboard' => 'Copy to Clipboard',
			'searchFilter.copied' => 'Copied',
			'searchFilter.filterCount' => ({required Object count}) => '${count} filters',
			'searchFilter.filterSettings' => 'Filter Settings',
			'searchFilter.field' => 'Field',
			'searchFilter.operator' => 'Operator',
			'searchFilter.language' => 'Language',
			'searchFilter.value' => 'Value',
			'searchFilter.dateRange' => 'Date Range',
			'searchFilter.numberRange' => 'Number Range',
			'searchFilter.from' => 'From',
			'searchFilter.to' => 'To',
			'searchFilter.date' => 'Date',
			'searchFilter.number' => 'Number',
			'searchFilter.boolean' => 'Boolean',
			'searchFilter.tags' => 'Tags',
			'searchFilter.select' => 'Select',
			'searchFilter.clickToSelectDate' => 'Click to select date',
			'searchFilter.pleaseEnterValidNumber' => 'Please enter valid number',
			'searchFilter.pleaseEnterValidDate' => 'Please enter valid date format (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'Start value must be less than end value',
			'searchFilter.startDateMustBeBeforeEndDate' => 'Start date must be before end date',
			'searchFilter.pleaseFillStartValue' => 'Please fill start value',
			'searchFilter.pleaseFillEndValue' => 'Please fill end value',
			'searchFilter.rangeValueFormatError' => 'Range value format error',
			'searchFilter.contains' => 'Contains',
			'searchFilter.equals' => 'Equals',
			'searchFilter.notEquals' => 'Not Equals',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Range',
			'searchFilter.kIn' => 'Contains Any',
			'searchFilter.notIn' => 'Not Contains Any',
			'searchFilter.username' => 'Username',
			'searchFilter.nickname' => 'Nickname',
			'searchFilter.registrationDate' => 'Registration Date',
			'searchFilter.description' => 'Description',
			'searchFilter.title' => 'Title',
			'searchFilter.body' => 'Body',
			'searchFilter.author' => 'Author',
			'searchFilter.publishDate' => 'Publish Date',
			'searchFilter.private' => 'Private',
			'searchFilter.duration' => 'Duration (seconds)',
			'searchFilter.likes' => 'Likes',
			'searchFilter.views' => 'Views',
			'searchFilter.comments' => 'Comments',
			'searchFilter.rating' => 'Rating',
			'searchFilter.imageCount' => 'Image Count',
			'searchFilter.videoCount' => 'Video Count',
			'searchFilter.createDate' => 'Create Date',
			'searchFilter.content' => 'Content',
			'searchFilter.all' => 'All',
			'searchFilter.adult' => 'Adult',
			'searchFilter.general' => 'General',
			'searchFilter.yes' => 'Yes',
			'searchFilter.no' => 'No',
			'searchFilter.users' => 'Users',
			'searchFilter.videos' => 'Videos',
			'searchFilter.images' => 'Images',
			'searchFilter.posts' => 'Posts',
			'searchFilter.forumThreads' => 'Forum Threads',
			'searchFilter.forumPosts' => 'Forum Posts',
			'searchFilter.playlists' => 'Playlists',
			'searchFilter.sortTypes.relevance' => 'Relevance',
			'searchFilter.sortTypes.latest' => 'Latest',
			'searchFilter.sortTypes.views' => 'Views',
			'searchFilter.sortTypes.likes' => 'Likes',
			'firstTimeSetup.welcome.title' => 'Welcome',
			'firstTimeSetup.welcome.subtitle' => 'Let\'s start your personalized setup journey',
			'firstTimeSetup.welcome.description' => 'Just a few steps to tailor the best experience for you',
			'firstTimeSetup.basic.title' => 'Basic Settings',
			'firstTimeSetup.basic.subtitle' => 'Personalize your experience',
			'firstTimeSetup.basic.description' => 'Choose the preferences that suit you',
			'firstTimeSetup.network.title' => 'Network Settings',
			'firstTimeSetup.network.subtitle' => 'Configure network options',
			'firstTimeSetup.network.description' => 'Adjust based on your network environment',
			'firstTimeSetup.network.tip' => 'A restart is required after successful configuration to take effect',
			'firstTimeSetup.theme.title' => 'Theme Settings',
			'firstTimeSetup.theme.subtitle' => 'Choose your preferred appearance',
			'firstTimeSetup.theme.description' => 'Personalize your visual experience',
			'firstTimeSetup.player.title' => 'Player Settings',
			'firstTimeSetup.player.subtitle' => 'Configure playback controls',
			'firstTimeSetup.player.description' => 'Quickly set commonly used playback preferences',
			'firstTimeSetup.completion.title' => 'Complete Setup',
			'firstTimeSetup.completion.subtitle' => 'You\'re ready to start your journey',
			'firstTimeSetup.completion.description' => 'Please read and agree to the related agreements',
			'firstTimeSetup.completion.agreementTitle' => 'User Agreement and Community Rules',
			'firstTimeSetup.completion.agreementDesc' => 'Before using this app, please carefully read and agree to our user agreement and community rules. These terms help maintain a good environment.',
			'firstTimeSetup.completion.checkboxTitle' => 'I have read and agree to the user agreement and community rules',
			'firstTimeSetup.completion.checkboxSubtitle' => 'You cannot use the app if you disagree',
			'firstTimeSetup.common.settingsChangeableTip' => 'These settings can be changed anytime in Settings',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Please agree to the user agreement and community rules first',
			'proxyHelper.systemProxyDetected' => 'System proxy detected',
			'proxyHelper.copied' => 'Copied',
			'proxyHelper.copy' => 'Copy',
			'tagSelector.selectTags' => 'Select Tags',
			'tagSelector.clickToSelectTags' => 'Click to select tags',
			'tagSelector.addTag' => 'Add Tag',
			'tagSelector.removeTag' => 'Remove Tag',
			'tagSelector.deleteTag' => 'Delete Tag',
			'tagSelector.usageInstructions' => 'First add tags, then click to select from existing tags',
			'tagSelector.usageInstructionsTooltip' => 'Usage Instructions',
			'tagSelector.addTagTooltip' => 'Add Tag',
			'tagSelector.removeTagTooltip' => 'Remove Tag',
			'tagSelector.cancelSelection' => 'Cancel Selection',
			'tagSelector.selectAll' => 'Select All',
			'tagSelector.cancelSelectAll' => 'Cancel Select All',
			'tagSelector.delete' => 'Delete',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Real-time video upscaling and denoising, improving animation video quality',
			'anime4k.settings' => 'Anime4K Settings',
			'anime4k.preset' => 'Anime4K Preset',
			'anime4k.disable' => 'Disable Anime4K',
			'anime4k.disableDescription' => 'Disable video enhancement effects',
			'anime4k.highQualityPresets' => 'High Quality Presets',
			'anime4k.fastPresets' => 'Fast Presets',
			'anime4k.litePresets' => 'Lightweight Presets',
			'anime4k.moreLitePresets' => 'More Lightweight Presets',
			'anime4k.customPresets' => 'Custom Presets',
			'anime4k.presetGroups.highQuality' => 'High Quality',
			'anime4k.presetGroups.fast' => 'Fast',
			'anime4k.presetGroups.lite' => 'Lite',
			'anime4k.presetGroups.moreLite' => 'More Lite',
			'anime4k.presetGroups.custom' => 'Custom',
			'anime4k.presetDescriptions.mode_a_hq' => 'Suitable for most 1080p animations, especially those dealing with blur, resampling and compression artifacts. Provides the highest perceived quality.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Suitable for animations with slight blur or ringing effects caused by scaling. Can effectively reduce ringing and aliasing.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Suitable for high-quality sources (such as native 1080p animations or movies). Denoises and provides the highest PSNR.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Enhanced version of Mode A, providing ultimate perceived quality and can reconstruct almost all degraded lines. May produce oversharpening or ringing.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Enhanced version of Mode B, providing higher perceived quality, further optimizing lines and reducing artifacts.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Perceived quality enhanced version of Mode C, maintaining high PSNR while attempting to reconstruct some line details.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Fast version of Mode A, balancing quality and performance, suitable for most 1080p animations.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Fast version of Mode B, for handling slight artifacts and ringing with lower overhead.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Fast version of Mode C, for fast denoising and upscaling of high-quality sources.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Fast version of Mode A+A, pursuing higher perceived quality in performance-constrained devices.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Fast version of Mode B+B, providing enhanced line repair and artifact processing for performance-constrained devices.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Fast version of Mode C+A, performing fast processing of high-quality sources while providing light line repair.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Ultra-fast x2 upscaling using only the fastest CNN model, no repair and denoising, minimal performance overhead.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Fast upscaling and deblurring using traditional non-CNN algorithms, better than default player algorithms with very low performance overhead.',
			'anime4k.presetDescriptions.restore_s_only' => 'Repair only using the fastest CNN model, no upscaling. Suitable for native resolution playback where you want to improve quality.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Fast denoising using traditional bilateral filtering, extremely fast, suitable for processing light noise.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Fast upscaling using traditional algorithms, very low performance overhead, better than player defaults.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Fast) + Line darkening, adding line darkening effects on top of fast mode A for more prominent, stylized lines.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + Line thinning, adding line thinning effects on top of high quality mode A for more refined appearance.',
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
			'anime4k.presetNames.upscale_only_s' => 'CNN Upscaling (Ultra Fast)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Upscaling & Deblurring (Fast)',
			'anime4k.presetNames.restore_s_only' => 'Restoration (Ultra Fast)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Bilateral Denoising (Ultra Fast)',
			'anime4k.presetNames.upscale_non_cnn' => 'Non-CNN Upscaling (Ultra Fast)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Fast) + Line Darkening',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + Line Thinning',
			'anime4k.performanceTip' => '💡 Tip: Choose appropriate presets based on device performance. Low-end devices are recommended to use lightweight presets.',
			_ => null,
		};
	}
}
