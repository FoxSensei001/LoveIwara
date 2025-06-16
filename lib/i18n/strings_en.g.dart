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
	late final TranslationsLinkInputDialogEn linkInputDialog = TranslationsLinkInputDialogEn._(_root);
	late final TranslationsLogEn log = TranslationsLogEn._(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get appName => 'Love Iwara';
	String get ok => 'OK';
	String get cancel => 'Cancel';
	String get save => 'Save';
	String get delete => 'Delete';
	String get loading => 'Loading...';
	String get scrollToTop => 'Scroll to Top';
	String get privacyHint => 'Privacy content, not displayed';
	String get latest => 'Latest';
	String get likesCount => 'Likes';
	String get viewsCount => 'Views';
	String get popular => 'Popular';
	String get trending => 'Trending';
	String get commentList => 'Comment List';
	String get sendComment => 'Send Comment';
	String get send => 'Send';
	String get retry => 'Retry';
	String get premium => 'Premium';
	String get follower => 'Follower';
	String get friend => 'Friend';
	String get video => 'Video';
	String get following => 'Following';
	String get expand => 'Expand';
	String get collapse => 'Collapse';
	String get cancelFriendRequest => 'Cancel Request';
	String get cancelSpecialFollow => 'Cancel Special Follow';
	String get addFriend => 'Add Friend';
	String get removeFriend => 'Remove Friend';
	String get followed => 'Followed';
	String get follow => 'Follow';
	String get unfollow => 'Unfollow';
	String get specialFollow => 'Special Follow';
	String get specialFollowed => 'Special Followed';
	String get gallery => 'Gallery';
	String get playlist => 'Playlist';
	String get commentPostedSuccessfully => 'Comment Posted Successfully';
	String get commentPostedFailed => 'Comment Posted Failed';
	String get success => 'Success';
	String get commentDeletedSuccessfully => 'Comment Deleted Successfully';
	String get commentUpdatedSuccessfully => 'Comment Updated Successfully';
	String totalComments({required Object count}) => '${count} Comments';
	String get writeYourCommentHere => 'Write your comment here...';
	String get tmpNoReplies => 'No replies yet';
	String get loadMore => 'Load More';
	String get noMoreDatas => 'No more data';
	String get selectTranslationLanguage => 'Select Translation Language';
	String get translate => 'Translate';
	String get translateFailedPleaseTryAgainLater => 'Translate failed, please try again later';
	String get translationResult => 'Translation Result';
	String get justNow => 'Just Now';
	String minutesAgo({required Object num}) => '${num} minutes ago';
	String hoursAgo({required Object num}) => '${num} hours ago';
	String daysAgo({required Object num}) => '${num} days ago';
	String editedAt({required Object num}) => '${num} edited';
	String get editComment => 'Edit Comment';
	String get commentUpdated => 'Comment Updated';
	String get replyComment => 'Reply Comment';
	String get reply => 'Reply';
	String get edit => 'Edit';
	String get unknownUser => 'Unknown User';
	String get me => 'Me';
	String get author => 'Author';
	String get admin => 'Admin';
	String viewReplies({required Object num}) => 'View Replies (${num})';
	String get hideReplies => 'Hide Replies';
	String get confirmDelete => 'Confirm Delete';
	String get areYouSureYouWantToDeleteThisItem => 'Are you sure you want to delete this item?';
	String get tmpNoComments => 'No comments yet';
	String get refresh => 'Refresh';
	String get back => 'Back';
	String get tips => 'Tips';
	String get linkIsEmpty => 'Link is empty';
	String get linkCopiedToClipboard => 'Link copied to clipboard';
	String get imageCopiedToClipboard => 'Image copied to clipboard';
	String get copyImageFailed => 'Copy image failed';
	String get mobileSaveImageIsUnderDevelopment => 'Mobile save image is under development';
	String get imageSavedTo => 'Image saved to';
	String get saveImageFailed => 'Save image failed';
	String get close => 'Close';
	String get more => 'More';
	String get moreFeaturesToBeDeveloped => 'More features to be developed';
	String get all => 'All';
	String selectedRecords({required Object num}) => 'Selected ${num} records';
	String get cancelSelectAll => 'Cancel Select All';
	String get selectAll => 'Select All';
	String get exitEditMode => 'Exit Edit Mode';
	String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Are you sure you want to delete selected ${num} items?';
	String get searchHistoryRecords => 'Search History Records...';
	String get settings => 'Settings';
	String get subscriptions => 'Subscriptions';
	String videoCount({required Object num}) => '${num} videos';
	String get share => 'Share';
	String get areYouSureYouWantToShareThisPlaylist => 'Are you sure you want to share this playlist?';
	String get editTitle => 'Edit Title';
	String get editMode => 'Edit Mode';
	String get pleaseEnterNewTitle => 'Please enter new title';
	String get createPlayList => 'Create Play List';
	String get create => 'Create';
	String get checkNetworkSettings => 'Check Network Settings';
	String get general => 'General';
	String get r18 => 'R18';
	String get sensitive => 'Sensitive';
	String get year => 'Year';
	String get month => 'Month';
	String get tag => 'Tag';
	String get private => 'Private';
	String get noTitle => 'No Title';
	String get search => 'Search';
	String get noContent => 'No content';
	String get recording => 'Recording';
	String get paused => 'Paused';
	String get clear => 'Clear';
	String get user => 'User';
	String get post => 'Post';
	String get seconds => 'Seconds';
	String get comingSoon => 'Coming Soon';
	String get confirm => 'Confirm';
	String get hour => 'Hour';
	String get minute => 'Minute';
	String get clickToRefresh => 'Click to Refresh';
	String get history => 'History';
	String get favorites => 'Favorites';
	String get friends => 'Friends';
	String get playList => 'Play List';
	String get checkLicense => 'Check License';
	String get logout => 'Logout';
	String get fensi => 'Fans';
	String get accept => 'Accept';
	String get reject => 'Reject';
	String get clearAllHistory => 'Clear All History';
	String get clearAllHistoryConfirm => 'Are you sure you want to clear all history?';
	String get followingList => 'Following List';
	String get followersList => 'Followers List';
	String get follows => 'Follows';
	String get fans => 'Fans';
	String get followsAndFans => 'Follows and Fans';
	String get numViews => 'Views';
	String get updatedAt => 'Updated At';
	String get publishedAt => 'Published At';
	String get externalVideo => 'External Video';
	String get originalText => 'Original Text';
	String get showOriginalText => 'Show Original Text';
	String get showProcessedText => 'Show Processed Text';
	String get preview => 'Preview';
	String get rules => 'Rules';
	String get agree => 'Agree';
	String get disagree => 'Disagree';
	String get agreeToRules => 'Agree to Rules';
	String get createPost => 'Create Post';
	String get title => 'Title';
	String get enterTitle => 'Please enter title';
	String get content => 'Content';
	String get enterContent => 'Please enter content';
	String get writeYourContentHere => 'Please enter content...';
	String get tagBlacklist => 'Tag Blacklist';
	String get noData => 'No data';
	String get tagLimit => 'Tag Limit';
	String get enableFloatingButtons => 'Enable Floating Buttons';
	String get disableFloatingButtons => 'Disable Floating Buttons';
	String get enabledFloatingButtons => 'Enabled Floating Buttons';
	String get disabledFloatingButtons => 'Disabled Floating Buttons';
	String get pendingCommentCount => 'Pending Comment Count';
	String joined({required Object str}) => 'Joined at ${str}';
	String get download => 'Download';
	String get selectQuality => 'Select Quality';
	String get selectDateRange => 'Select Date Range';
	String get selectDateRangeHint => 'Select date range, default is recent 30 days';
	String get clearDateRange => 'Clear Date Range';
	String get followSuccessClickAgainToSpecialFollow => 'Followed successfully, click again to special follow';
	String get exitConfirmTip => 'Are you sure you want to exit?';
	String get error => 'Error';
	String get taskRunning => 'A task is already running, please wait.';
	String get operationCancelled => 'Operation cancelled.';
	String get unsavedChanges => 'You have unsaved changes';
	String get specialFollowsManagementTip => 'Drag to reorder • Swipe left to remove';
	String get specialFollowsManagement => 'Special Follows Management';
	late final TranslationsCommonPaginationEn pagination = TranslationsCommonPaginationEn._(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get login => 'Login';
	String get logout => 'Logout';
	String get email => 'Email';
	String get password => 'Password';
	String get loginOrRegister => 'Login / Register';
	String get register => 'Register';
	String get pleaseEnterEmail => 'Please enter email';
	String get pleaseEnterPassword => 'Please enter password';
	String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';
	String get pleaseEnterCaptcha => 'Please enter captcha';
	String get captcha => 'Captcha';
	String get refreshCaptcha => 'Refresh Captcha';
	String get captchaNotLoaded => 'Captcha not loaded';
	String get loginSuccess => 'Login Success';
	String get emailVerificationSent => 'Email verification sent';
	String get notLoggedIn => 'Not Logged In';
	String get clickToLogin => 'Click to Login';
	String get logoutConfirmation => 'Are you sure you want to logout?';
	String get logoutSuccess => 'Logout Success';
	String get logoutFailed => 'Logout Failed';
	String get usernameOrEmail => 'Username or Email';
	String get pleaseEnterUsernameOrEmail => 'Please enter username or email';
	String get rememberMe => 'Remember Username and Password';
}

// Path: errors
class TranslationsErrorsEn {
	TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get error => 'Error';
	String get required => 'This field is required';
	String get invalidEmail => 'Invalid email address';
	String get networkError => 'Network error, please try again';
	String get errorWhileFetching => 'Error while fetching';
	String get commentCanNotBeEmpty => 'Comment content cannot be empty';
	String get errorWhileFetchingReplies => 'Error while fetching replies, please check network connection';
	String get canNotFindCommentController => 'Can not find comment controller';
	String get errorWhileLoadingGallery => 'Error while loading gallery';
	String get howCouldThereBeNoDataItCantBePossible => 'How could there be no data? It can\'t be possible :<';
	String unsupportedImageFormat({required Object str}) => 'Unsupported image format: ${str}';
	String get invalidGalleryId => 'Invalid gallery ID';
	String get translationFailedPleaseTryAgainLater => 'Translation failed, please try again later';
	String get errorOccurred => 'An error occurred, please try again later.';
	String get errorOccurredWhileProcessingRequest => 'Error occurred while processing request';
	String get errorWhileFetchingDatas => 'Error while fetching datas, please try again later';
	String get serviceNotInitialized => 'Service not initialized';
	String get unknownType => 'Unknown type';
	String errorWhileOpeningLink({required Object link}) => 'Error while opening link: ${link}';
	String get invalidUrl => 'Invalid URL';
	String get failedToOperate => 'Failed to operate';
	String get permissionDenied => 'Permission Denied';
	String get youDoNotHavePermissionToAccessThisResource => 'You do not have permission to access this resource';
	String get loginFailed => 'Login Failed';
	String get unknownError => 'Unknown Error';
	String get sessionExpired => 'Session Expired';
	String get failedToFetchCaptcha => 'Failed to fetch captcha';
	String get emailAlreadyExists => 'Email already exists';
	String get invalidCaptcha => 'Invalid Captcha';
	String get registerFailed => 'Register Failed';
	String get failedToFetchComments => 'Failed to fetch comments';
	String get failedToFetchImageDetail => 'Failed to fetch image detail';
	String get failedToFetchImageList => 'Failed to fetch image list';
	String get failedToFetchData => 'Failed to fetch data';
	String get invalidParameter => 'Invalid parameter';
	String get pleaseLoginFirst => 'Please login first';
	String get errorWhileLoadingPost => 'Error while loading post';
	String get errorWhileLoadingPostDetail => 'Error while loading post detail';
	String get invalidPostId => 'Invalid post ID';
	String get forceUpdateNotPermittedToGoBack => 'Currently in force update state, cannot go back';
	String get pleaseLoginAgain => 'Please login again';
	String get invalidLogin => 'Invalid login, Please check your email and password';
	String get tooManyRequests => 'Too many requests, please try again later';
	String exceedsMaxLength({required Object max}) => 'Exceeds max length: ${max}';
	String get contentCanNotBeEmpty => 'Content cannot be empty';
	String get titleCanNotBeEmpty => 'Title cannot be empty';
	String get tooManyRequestsPleaseTryAgainLaterText => 'Too many requests, please try again later, remaining';
	String remainingHours({required Object num}) => '${num} hours';
	String remainingMinutes({required Object num}) => '${num} minutes';
	String remainingSeconds({required Object num}) => '${num} seconds';
	String tagLimitExceeded({required Object limit}) => 'Tag limit exceeded, limit: ${limit}';
	String get failedToRefresh => 'Failed to refresh';
	String get noPermission => 'No permission';
	String get resourceNotFound => 'Resource not found';
	String get failedToSaveCredentials => 'Failed to save login credentials';
	String get failedToLoadSavedCredentials => 'Failed to load saved credentials';
	String specialFollowLimitReached({required Object cnt}) => 'Special follow limit exceeded, limit: ${cnt}, please adjust in the follow list page';
	String get notFound => 'Content not found or has been deleted';
}

// Path: friends
class TranslationsFriendsEn {
	TranslationsFriendsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get clickToRestoreFriend => 'Click to restore friend';
	String get friendsList => 'Friends List';
	String get friendRequests => 'Friend Requests';
	String get friendRequestsList => 'Friend Requests List';
	String get removingFriend => 'Removing friend...';
	String get failedToRemoveFriend => 'Failed to remove friend';
	String get cancelingRequest => 'Canceling friend request...';
	String get failedToCancelRequest => 'Failed to cancel friend request';
}

// Path: authorProfile
class TranslationsAuthorProfileEn {
	TranslationsAuthorProfileEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get noMoreDatas => 'No more data';
	String get userProfile => 'User Profile';
}

// Path: favorites
class TranslationsFavoritesEn {
	TranslationsFavoritesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get clickToRestoreFavorite => 'Click to restore favorite';
	String get myFavorites => 'My Favorites';
}

// Path: galleryDetail
class TranslationsGalleryDetailEn {
	TranslationsGalleryDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get galleryDetail => 'Gallery Detail';
	String get viewGalleryDetail => 'View Gallery Detail';
	String get copyLink => 'Copy Link';
	String get copyImage => 'Copy Image';
	String get saveAs => 'Save As';
	String get saveToAlbum => 'Save to Album';
	String get publishedAt => 'Published At';
	String get viewsCount => 'Views Count';
	String get imageLibraryFunctionIntroduction => 'Image Library Function Introduction';
	String get rightClickToSaveSingleImage => 'Right Click to Save Single Image';
	String get batchSave => 'Batch Save';
	String get keyboardLeftAndRightToSwitch => 'Keyboard Left and Right to Switch';
	String get keyboardUpAndDownToZoom => 'Keyboard Up and Down to Zoom';
	String get mouseWheelToSwitch => 'Mouse Wheel to Switch';
	String get ctrlAndMouseWheelToZoom => 'CTRL + Mouse Wheel to Zoom';
	String get moreFeaturesToBeDiscovered => 'More Features to Be Discovered...';
	String get authorOtherGalleries => 'Author\'s Other Galleries';
	String get relatedGalleries => 'Related Galleries';
	String get clickLeftAndRightEdgeToSwitchImage => 'Click Left and Right Edge to Switch Image';
}

// Path: playList
class TranslationsPlayListEn {
	TranslationsPlayListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get myPlayList => 'My Play List';
	String get friendlyTips => 'Friendly Tips';
	String get dearUser => 'Dear User';
	String get iwaraPlayListSystemIsNotPerfectYet => 'iwara\'s play list system is not perfect yet';
	String get notSupportSetCover => 'Not support set cover';
	String get notSupportDeleteList => 'Not support delete list';
	String get notSupportSetPrivate => 'Not support set private';
	String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Yes... create list will always exist and visible to everyone';
	String get smallSuggestion => 'Small Suggestion';
	String get useLikeToCollectContent => 'If you are more concerned about privacy, it is recommended to use the "like" function to collect content';
	String get welcomeToDiscussOnGitHub => 'If you have other suggestions or ideas, welcome to discuss on GitHub!';
	String get iUnderstand => 'I Understand';
	String get searchPlaylists => 'Search Playlists...';
	String get newPlaylistName => 'New Playlist Name';
	String get createNewPlaylist => 'Create New Playlist';
	String get videos => 'Videos';
}

// Path: search
class TranslationsSearchEn {
	TranslationsSearchEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get googleSearchScope => 'Search Scope';
	String get searchTags => 'Search Tags...';
	String get contentRating => 'Content Rating';
	String get removeTag => 'Remove Tag';
	String get pleaseEnterSearchContent => 'Please enter search content';
	String get searchHistory => 'Search History';
	String get searchSuggestion => 'Search Suggestion';
	String get usedTimes => 'Used Times';
	String get lastUsed => 'Last Used';
	String get noSearchHistoryRecords => 'No search history';
	String notSupportCurrentSearchType({required Object searchType}) => 'Not support current search type ${searchType}, please wait for the update';
	String get searchResult => 'Search Result';
	String unsupportedSearchType({required Object searchType}) => 'Unsupported search type: ${searchType}';
	String get googleSearch => 'Google Search';
	String googleSearchHint({required Object webName}) => '${webName} \'s search function is not easy to use? Try Google Search!';
	String get googleSearchDescription => 'Use the :site search operator of Google Search to search for content on the site. This is very useful when searching for videos, galleries, playlists, and users.';
	String get googleSearchKeywordsHint => 'Enter keywords to search';
	String get openLinkJump => 'Open Link Jump';
	String get googleSearchButton => 'Google Search';
	String get pleaseEnterSearchKeywords => 'Please enter search keywords';
	String get googleSearchQueryCopied => 'Search query copied to clipboard';
	String googleSearchBrowserOpenFailed({required Object error}) => 'Failed to open browser: ${error}';
}

// Path: mediaList
class TranslationsMediaListEn {
	TranslationsMediaListEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get personalIntroduction => 'Personal Introduction';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get listViewMode => 'List View Mode';
	String get useTraditionalPaginationMode => 'Use Traditional Pagination Mode';
	String get useTraditionalPaginationModeDesc => 'Enable traditional pagination mode, disable waterfall mode';
	String get showVideoProgressBottomBarWhenToolbarHidden => 'Show Video Progress Bottom Bar When Toolbar Hidden';
	String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'This configuration determines whether the video progress bottom bar will be shown when the toolbar is hidden.';
	String get basicSettings => 'Basic Settings';
	String get personalizedSettings => 'Personalized Settings';
	String get otherSettings => 'Other Settings';
	String get searchConfig => 'Search Config';
	String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'This configuration determines whether the previous configuration will be used when playing videos again.';
	String get playControl => 'Play Control';
	String get fastForwardTime => 'Fast Forward Time';
	String get fastForwardTimeMustBeAPositiveInteger => 'Fast forward time must be a positive integer.';
	String get rewindTime => 'Rewind Time';
	String get rewindTimeMustBeAPositiveInteger => 'Rewind time must be a positive integer.';
	String get longPressPlaybackSpeed => 'Long Press Playback Speed';
	String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Long press playback speed must be a positive number.';
	String get repeat => 'Repeat';
	String get renderVerticalVideoInVerticalScreen => 'Render Vertical Video in Vertical Screen';
	String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'This configuration determines whether the video will be rendered in vertical screen when playing in full screen.';
	String get rememberVolume => 'Remember Volume';
	String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'This configuration determines whether the volume will be kept when playing videos again.';
	String get rememberBrightness => 'Remember Brightness';
	String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'This configuration determines whether the brightness will be kept when playing videos again.';
	String get playControlArea => 'Play Control Area';
	String get leftAndRightControlAreaWidth => 'Left and Right Control Area Width';
	String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'This configuration determines the width of the control areas on the left and right sides of the player.';
	String get proxyAddressCannotBeEmpty => 'Proxy address cannot be empty.';
	String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Invalid proxy address format. Please use the format of IP:port or domain name:port.';
	String get proxyNormalWork => 'Proxy normal work.';
	String testProxyFailedWithStatusCode({required Object code}) => 'Test proxy failed, status code: ${code}';
	String testProxyFailedWithException({required Object exception}) => 'Test proxy failed, exception: ${exception}';
	String get proxyConfig => 'Proxy Config';
	String get thisIsHttpProxyAddress => 'This is http proxy address';
	String get checkProxy => 'Check Proxy';
	String get proxyAddress => 'Proxy Address';
	String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Please enter the URL of the proxy server, for example 127.0.0.1:8080';
	String get enableProxy => 'Enable Proxy';
	String get left => 'Left';
	String get middle => 'Middle';
	String get right => 'Right';
	String get playerSettings => 'Player Settings';
	String get networkSettings => 'Network Settings';
	String get customizeYourPlaybackExperience => 'Customize Your Playback Experience';
	String get chooseYourFavoriteAppAppearance => 'Choose Your Favorite App Appearance';
	String get configureYourProxyServer => 'Configure Your Proxy Server';
	String get settings => 'Settings';
	String get themeSettings => 'Theme Settings';
	String get followSystem => 'Follow System';
	String get lightMode => 'Light Mode';
	String get darkMode => 'Dark Mode';
	String get presetTheme => 'Preset Theme';
	String get basicTheme => 'Basic Theme';
	String get needRestartToApply => 'Need to restart the app to apply the settings';
	String get themeNeedRestartDescription => 'The theme settings need to restart the app to apply the settings';
	String get about => 'About';
	String get currentVersion => 'Current Version';
	String get latestVersion => 'Latest Version';
	String get checkForUpdates => 'Check for Updates';
	String get update => 'Update';
	String get newVersionAvailable => 'New Version Available';
	String get projectHome => 'Project Home';
	String get release => 'Release';
	String get issueReport => 'Issue Report';
	String get openSourceLicense => 'Open Source License';
	String get checkForUpdatesFailed => 'Check for updates failed, please try again later';
	String get autoCheckUpdate => 'Auto Check Update';
	String get updateContent => 'Update Content';
	String get releaseDate => 'Release Date';
	String get ignoreThisVersion => 'Ignore This Version';
	String get minVersionUpdateRequired => 'Current version is too low, please update as soon as possible';
	String get forceUpdateTip => 'This is a mandatory update. Please update to the latest version as soon as possible';
	String get viewChangelog => 'View Changelog';
	String get alreadyLatestVersion => 'Already the latest version';
	String get appSettings => 'App Settings';
	String get configureYourAppSettings => 'Configure Your App Settings';
	String get history => 'History';
	String get autoRecordHistory => 'Auto Record History';
	String get autoRecordHistoryDesc => 'Auto record the videos and images you have watched';
	String get showUnprocessedMarkdownText => 'Show Unprocessed Markdown Text';
	String get showUnprocessedMarkdownTextDesc => 'Show the original text of the markdown';
	String get markdown => 'Markdown';
	String get activeBackgroundPrivacyMode => 'Privacy Mode';
	String get activeBackgroundPrivacyModeDesc => 'Prevent screenshots, hide screen when running in the background...';
	String get privacy => 'Privacy';
	String get forum => 'Forum';
	String get disableForumReplyQuote => 'Disable Forum Reply Quote';
	String get disableForumReplyQuoteDesc => 'Disable carrying replied floor information when replying in forum';
	String get theaterMode => 'Theater Mode';
	String get theaterModeDesc => 'After opening, the player background will be set to the blurred version of the video cover';
	String get appLinks => 'App Links';
	String get defaultBrowser => 'Default Browse';
	String get defaultBrowserDesc => 'Please open the default link configuration item in the system settings and add the iwara.tv website link';
	String get themeMode => 'Theme Mode';
	String get themeModeDesc => 'This configuration determines the theme mode of the app';
	String get dynamicColor => 'Dynamic Color';
	String get dynamicColorDesc => 'This configuration determines whether the app uses dynamic color';
	String get useDynamicColor => 'Use Dynamic Color';
	String get useDynamicColorDesc => 'This configuration determines whether the app uses dynamic color';
	String get presetColors => 'Preset Colors';
	String get customColors => 'Custom Colors';
	String get pickColor => 'Pick Color';
	String get cancel => 'Cancel';
	String get confirm => 'Confirm';
	String get noCustomColors => 'No custom colors';
	String get recordAndRestorePlaybackProgress => 'Record and Restore Playback Progress';
	String get signature => 'Signature';
	String get enableSignature => 'Enable Signature';
	String get enableSignatureDesc => 'This configuration determines whether the app will add signature when replying';
	String get enterSignature => 'Enter Signature';
	String get editSignature => 'Edit Signature';
	String get signatureContent => 'Signature Content';
	String get exportConfig => 'Export App Configuration';
	String get exportConfigDesc => 'Export app configuration to a file (excluding download records)';
	String get importConfig => 'Import App Configuration';
	String get importConfigDesc => 'Import app configuration from a file';
	String get exportConfigSuccess => 'Configuration exported successfully!';
	String get exportConfigFailed => 'Failed to export configuration';
	String get importConfigSuccess => 'Configuration imported successfully!';
	String get importConfigFailed => 'Failed to import configuration';
	String get historyUpdateLogs => 'History Update Logs';
	String get noUpdateLogs => 'No update logs available';
	String get versionLabel => 'Version: {version}';
	String get releaseDateLabel => 'Release Date: {date}';
	String get noChanges => 'No update content available';
	String get interaction => 'Interaction';
	String get enableVibration => 'Enable Vibration';
	String get enableVibrationDesc => 'Enable vibration feedback when interacting with the app';
	String get defaultKeepVideoToolbarVisible => 'Keep Video Toolbar Visible';
	String get defaultKeepVideoToolbarVisibleDesc => 'This setting determines whether the video toolbar remains visible when first entering the video page.';
	String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Mobile devices enable theater mode, which may cause performance issues. You can choose to enable it.';
	String get lockButtonPosition => 'Lock Button Position';
	String get lockButtonPositionBothSides => 'Both Sides';
	String get lockButtonPositionLeftSide => 'Left Side';
	String get lockButtonPositionRightSide => 'Right Side';
	String get jumpLink => 'Jump Link';
}

// Path: signIn
class TranslationsSignInEn {
	TranslationsSignInEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pleaseLoginFirst => 'Please login first';
	String get alreadySignedInToday => 'You have already signed in today!';
	String get youDidNotStickToTheSignIn => 'You did not stick to the sign in.';
	String get signInSuccess => 'Sign in successfully!';
	String get signInFailed => 'Sign in failed, please try again later';
	String get consecutiveSignIns => 'Consecutive Sign Ins';
	String get failureReason => 'Failure Reason';
	String get selectDateRange => 'Select Date Range';
	String get startDate => 'Start Date';
	String get endDate => 'End Date';
	String get invalidDate => 'Invalid Date';
	String get invalidDateRange => 'Invalid Date Range';
	String get errorFormatText => 'Date Format Error';
	String get errorInvalidText => 'Invalid Date Range';
	String get errorInvalidRangeText => 'Invalid Date Range';
	String get dateRangeCantBeMoreThanOneYear => 'Date range cannot be more than one year';
	String get signIn => 'Sign In';
	String get signInRecord => 'Sign In Record';
	String get totalSignIns => 'Total Sign Ins';
	String get pleaseSelectSignInStatus => 'Please select sign in status';
}

// Path: subscriptions
class TranslationsSubscriptionsEn {
	TranslationsSubscriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pleaseLoginFirstToViewYourSubscriptions => 'Please login first to view your subscriptions.';
}

// Path: videoDetail
class TranslationsVideoDetailEn {
	TranslationsVideoDetailEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pipMode => 'PiP Mode';
	String resumeFromLastPosition({required Object position}) => 'Resume from last position: ${position}';
	String get videoIdIsEmpty => 'Video ID is empty';
	String get videoInfoIsEmpty => 'Video info is empty';
	String get thisIsAPrivateVideo => 'This is a private video';
	String get getVideoInfoFailed => 'Get video info failed, please try again later';
	String get noVideoSourceFound => 'No video source found';
	String tagCopiedToClipboard({required Object tagId}) => 'Tag "${tagId}" copied to clipboard';
	String get errorLoadingVideo => 'Error loading video';
	String get play => 'Play';
	String get pause => 'Pause';
	String get exitAppFullscreen => 'Exit App Fullscreen';
	String get enterAppFullscreen => 'Enter App Fullscreen';
	String get exitSystemFullscreen => 'Exit System Fullscreen';
	String get enterSystemFullscreen => 'Enter System Fullscreen';
	String get seekTo => 'Seek To';
	String get switchResolution => 'Switch Resolution';
	String get switchPlaybackSpeed => 'Switch Playback Speed';
	String rewindSeconds({required Object num}) => 'Rewind ${num} seconds';
	String fastForwardSeconds({required Object num}) => 'Fast Forward ${num} seconds';
	String playbackSpeedIng({required Object rate}) => 'Playing at ${rate}x speed';
	String get brightness => 'Brightness';
	String get brightnessLowest => 'Brightness is lowest';
	String get volume => 'Volume';
	String get volumeMuted => 'Volume is muted';
	String get home => 'Home';
	String get videoPlayer => 'Video Player';
	String get videoPlayerInfo => 'Video Player Info';
	String get moreSettings => 'More Settings';
	String get videoPlayerFeatureInfo => 'Video Player Feature Info';
	String get autoRewind => 'Auto Rewind';
	String get rewindAndFastForward => 'Rewind and Fast Forward';
	String get volumeAndBrightness => 'Volume and Brightness';
	String get centerAreaDoubleTapPauseOrPlay => 'Center Area Double Tap Pause or Play';
	String get showVerticalVideoInFullScreen => 'Show Vertical Video in Full Screen';
	String get keepLastVolumeAndBrightness => 'Keep Last Volume and Brightness';
	String get setProxy => 'Set Proxy';
	String get moreFeaturesToBeDiscovered => 'More Features to Be Discovered...';
	String get videoPlayerSettings => 'Video Player Settings';
	String commentCount({required Object num}) => '${num} comments';
	String get writeYourCommentHere => 'Write your comment here...';
	String get authorOtherVideos => 'Author\'s Other Videos';
	String get relatedVideos => 'Related Videos';
	String get privateVideo => 'This is a private video';
	String get externalVideo => 'This is an external video';
	String get openInBrowser => 'Open in Browser';
	String get resourceDeleted => 'This video seems to have been deleted :/';
	String get noDownloadUrl => 'No download URL';
	String get startDownloading => 'Start downloading';
	String get downloadFailed => 'Download failed, please try again later';
	String get downloadSuccess => 'Download success';
	String get download => 'Download';
	String get downloadManager => 'Download Manager';
}

// Path: share
class TranslationsShareEn {
	TranslationsShareEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get sharePlayList => 'Share Play List';
	String get wowDidYouSeeThis => 'Wow, did you see this?';
	String get nameIs => 'Name is';
	String get clickLinkToView => 'Click link to view';
	String get iReallyLikeThis => 'I really like this';
	String get shareFailed => 'Share failed, please try again later';
	String get share => 'Share';
	String get shareAsImage => 'Share as Image';
	String get shareAsText => 'Share as Text';
	String get shareAsImageDesc => 'Share the video cover as an image';
	String get shareAsTextDesc => 'Share the video details as text';
	String get shareAsImageFailed => 'Share the video cover as an image failed, please try again later';
	String get shareAsTextFailed => 'Share the video details as text failed, please try again later';
	String get shareVideo => 'Share Video';
	String get authorIs => 'Author is';
	String get shareGallery => 'Share Gallery';
	String get galleryTitleIs => 'Gallery title is';
	String get galleryAuthorIs => 'Gallery author is';
	String get shareUser => 'Share User';
	String get userNameIs => 'User name is';
	String get userAuthorIs => 'User author is';
	String get comments => 'Comments';
	String get shareThread => 'Share Thread';
	String get views => 'Views';
	String get sharePost => 'Share Post';
	String get postTitleIs => 'Post title is';
	String get postAuthorIs => 'Post author is';
}

// Path: markdown
class TranslationsMarkdownEn {
	TranslationsMarkdownEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get markdownSyntax => 'Markdown Syntax';
	String get iwaraSpecialMarkdownSyntax => 'Iwara Special Markdown Syntax';
	String get internalLink => 'Internal Link';
	String get supportAutoConvertLinkBelow => 'Support auto convert link below:';
	String get convertLinkExample => '🎬 Video Link\n🖼️ Image Link\n👤 User Link\n📌 Forum Link\n🎵 Playlist Link\n💬 Thread Link';
	String get mentionUser => 'Mention User';
	String get mentionUserDescription => 'Input @ followed by username, will be automatically converted to user link';
	String get markdownBasicSyntax => 'Markdown Basic Syntax';
	String get paragraphAndLineBreak => 'Paragraph and Line Break';
	String get paragraphAndLineBreakDescription => 'Paragraphs are separated by a line, and two spaces at the end of the line will be converted to a line break';
	String get paragraphAndLineBreakSyntax => 'This is the first paragraph\n\nThis is the second paragraph\nThis line ends with two spaces  \nwill be converted to a line break';
	String get textStyle => 'Text Style';
	String get textStyleDescription => 'Use special symbols to surround text to change style';
	String get textStyleSyntax => '**Bold Text**\n*Italic Text*\n~~Strikethrough Text~~\n`Code Text`';
	String get quote => 'Quote';
	String get quoteDescription => 'Use > symbol to create quote, multiple > to create multi-level quote';
	String get quoteSyntax => '> This is a first-level quote\n>> This is a second-level quote';
	String get list => 'List';
	String get listDescription => 'Create ordered list with number+dot, create unordered list with -';
	String get listSyntax => '1. First item\n2. Second item\n\n- Unordered item\n  - Subitem\n  - Another subitem';
	String get linkAndImage => 'Link and Image';
	String get linkAndImageDescription => 'Link format: [text](URL)\nImage format: ![description](URL)';
	String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[link text](${link})\n![image description](${imgUrl})';
	String get title => 'Title';
	String get titleDescription => 'Use # symbol to create title, number to show level';
	String get titleSyntax => '# First-level title\n## Second-level title\n### Third-level title';
	String get separator => 'Separator';
	String get separatorDescription => 'Create separator with three or more - symbols';
	String get separatorSyntax => '---';
	String get syntax => 'Syntax';
}

// Path: forum
class TranslationsForumEn {
	TranslationsForumEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get recent => 'Recent';
	String get category => 'Category';
	String get lastReply => 'Last Reply';
	late final TranslationsForumErrorsEn errors = TranslationsForumErrorsEn._(_root);
	String get createPost => 'Create Post';
	String get title => 'Title';
	String get enterTitle => 'Enter Title';
	String get content => 'Content';
	String get enterContent => 'Enter Content';
	String get writeYourContentHere => 'Write your content here...';
	String get posts => 'Posts';
	String get threads => 'Threads';
	String get forum => 'Forum';
	String get createThread => 'Create Thread';
	String get selectCategory => 'Select Category';
	String cooldownRemaining({required Object minutes, required Object seconds}) => 'Cooldown remaining ${minutes} minutes ${seconds} seconds';
	late final TranslationsForumGroupsEn groups = TranslationsForumGroupsEn._(_root);
	late final TranslationsForumLeafNamesEn leafNames = TranslationsForumLeafNamesEn._(_root);
	late final TranslationsForumLeafDescriptionsEn leafDescriptions = TranslationsForumLeafDescriptionsEn._(_root);
	String get reply => 'Reply';
	String get pendingReview => 'Pending Review';
	String get editedAt => 'Edited At';
	String get copySuccess => 'Copied to clipboard';
	String copySuccessForMessage({required Object str}) => 'Copied to clipboard: ${str}';
	String get editReply => 'Edit Reply';
	String get editTitle => 'Edit Title';
	String get submit => 'Submit';
}

// Path: notifications
class TranslationsNotificationsEn {
	TranslationsNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsNotificationsErrorsEn errors = TranslationsNotificationsErrorsEn._(_root);
	String get notifications => 'Notifications';
	String get profile => 'Profile';
	String get postedNewComment => 'Posted new comment';
	String get inYour => 'In your';
	String get video => 'Video';
	String get repliedYourVideoComment => 'Replied your video comment';
	String get copyInfoToClipboard => 'Copy notification info to clipboard';
	String get copySuccess => 'Copied to clipboard';
	String copySuccessForMessage({required Object str}) => 'Copied to clipboard: ${str}';
	String get markAllAsRead => 'Mark all as read';
	String get markAllAsReadSuccess => 'All notifications have been marked as read';
	String get markAllAsReadFailed => 'Mark all as read failed';
	String get markSelectedAsRead => 'Mark selected as read';
	String get markSelectedAsReadSuccess => 'Selected notifications have been marked as read';
	String get markSelectedAsReadFailed => 'Mark selected as read failed';
	String get markAsRead => 'Mark as read';
	String get markAsReadSuccess => 'Notification has been marked as read';
	String get markAsReadFailed => 'Notification marked as read failed';
	String get notificationTypeHelp => 'Notification Type Help';
	String get dueToLackOfNotificationTypeDetails => 'Due to the lack of notification type details, the supported types may not cover the messages you currently receive';
	String get helpUsImproveNotificationTypeSupport => 'If you are willing to help us improve the support for notification types';
	String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Copy the notification information\n2. 🐞 Submit an issue to the project repository\n\n⚠️ Note: Notification information may contain personal privacy, if you do not want to public, you can also send it to the project author by email.';
	String get goToRepository => 'Go to Repository';
	String get copy => 'Copy';
	String get commentApproved => 'Comment Approved';
	String get repliedYourProfileComment => 'Replied your profile comment';
	String get kReplied => 'replied to your comment on';
	String get kCommented => 'commented on your';
	String get kVideo => 'video';
	String get kGallery => 'gallery';
	String get kProfile => 'profile';
	String get kThread => 'thread';
	String get kPost => 'post';
	String get kCommentSection => 'comment section';
	String get kApprovedComment => 'Comment approved';
	String get kApprovedVideo => 'Video approved';
	String get kApprovedGallery => 'Gallery approved';
	String get kApprovedThread => 'Thread approved';
	String get kApprovedPost => 'Post approved';
	String get kUnknownType => 'Unknown notification type';
}

// Path: conversation
class TranslationsConversationEn {
	TranslationsConversationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsConversationErrorsEn errors = TranslationsConversationErrorsEn._(_root);
	String get conversation => 'Conversation';
	String get startConversation => 'Start Conversation';
	String get noConversation => 'No conversation';
	String get selectFromLeftListAndStartConversation => 'Select from left list and start conversation';
	String get title => 'Title';
	String get body => 'Body';
	String get selectAUser => 'Select a user';
	String get searchUsers => 'Search users...';
	String get tmpNoConversions => 'No conversions';
	String get deleteThisMessage => 'Delete this message';
	String get deleteThisMessageSubtitle => 'This operation cannot be undone';
	String get writeMessageHere => 'Write message here...';
	String get sendMessage => 'Send message';
}

// Path: splash
class TranslationsSplashEn {
	TranslationsSplashEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSplashErrorsEn errors = TranslationsSplashErrorsEn._(_root);
	String get preparing => 'Preparing...';
	String get initializing => 'Initializing...';
	String get loading => 'Loading...';
	String get ready => 'Ready';
	String get initializingMessageService => 'Initializing message service...';
}

// Path: download
class TranslationsDownloadEn {
	TranslationsDownloadEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsDownloadErrorsEn errors = TranslationsDownloadErrorsEn._(_root);
	String get downloadList => 'Download List';
	String get download => 'Download';
	String get startDownloading => 'Start Downloading';
	String get clearAllFailedTasks => 'Clear All Failed Tasks';
	String get clearAllFailedTasksConfirmation => 'Are you sure you want to clear all failed download tasks? The files of these tasks will also be deleted.';
	String get clearAllFailedTasksSuccess => 'Cleared all failed tasks';
	String get clearAllFailedTasksError => 'Error occurred while clearing failed tasks';
	String get downloadStatus => 'Download Status';
	String get imageList => 'Image List';
	String get retryDownload => 'Retry Download';
	String get notDownloaded => 'Not Downloaded';
	String get downloaded => 'Downloaded';
	String get waitingForDownload => 'Waiting for Download';
	String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Downloading (${downloaded}/${total} images ${progress}%)';
	String downloadingSingleImageProgress({required Object downloaded}) => 'Downloading (${downloaded} images)';
	String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Paused (${downloaded}/${total} images ${progress}%)';
	String pausedSingleImageProgress({required Object downloaded}) => 'Paused (${downloaded} images)';
	String downloadedProgressForImageProgress({required Object total}) => 'Downloaded (Total ${total} images)';
	String get viewVideoDetail => 'View Video Detail';
	String get viewGalleryDetail => 'View Gallery Detail';
	String get moreOptions => 'More Options';
	String get openFile => 'Open File';
	String get pause => 'Pause';
	String get resume => 'Resume';
	String get copyDownloadUrl => 'Copy Download URL';
	String get showInFolder => 'Show in Folder';
	String get deleteTask => 'Delete Task';
	String get forceDeleteTask => 'Force Delete Task';
	String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Downloading ${downloaded} • ${speed}MB/s';
	String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Paused ${downloaded}/${total} (${progress}%)';
	String pausedAndDownloaded({required Object downloaded}) => 'Paused • Downloaded ${downloaded}';
	String downloadedWithSize({required Object size}) => 'Downloaded • ${size}';
	String get copyDownloadUrlSuccess => 'Download URL copied';
	String totalImageNums({required Object num}) => '${num} images';
	String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Downloading ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	String get downloading => 'Downloading';
	String get failed => 'Failed';
	String get completed => 'Completed';
	String get downloadDetail => 'Download Detail';
	String get copy => 'Copy';
	String get copySuccess => 'Copied';
	String get waiting => 'Waiting';
	String get paused => 'Paused';
	String downloadingOnlyDownloaded({required Object downloaded}) => 'Downloading ${downloaded}';
	String galleryDownloadCompletedWithName({required Object galleryName}) => 'Gallery Download Completed: ${galleryName}';
	String downloadCompletedWithName({required Object fileName}) => 'Download Completed: ${fileName}';
	String get stillInDevelopment => 'Still in development';
	String get saveToAppDirectory => 'Save to app directory';
}

// Path: favorite
class TranslationsFavoriteEn {
	TranslationsFavoriteEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFavoriteErrorsEn errors = TranslationsFavoriteErrorsEn._(_root);
	String get add => 'Add';
	String get addSuccess => 'Add success';
	String get addFailed => 'Add failed';
	String get remove => 'Remove';
	String get removeSuccess => 'Remove success';
	String get removeFailed => 'Remove failed';
	String get removeConfirmation => 'Are you sure you want to remove this item from favorites?';
	String get removeConfirmationSuccess => 'Item removed from favorites';
	String get removeConfirmationFailed => 'Failed to remove item from favorites';
	String get createFolderSuccess => 'Folder created successfully';
	String get createFolderFailed => 'Failed to create folder';
	String get createFolder => 'Create Folder';
	String get enterFolderName => 'Enter folder name';
	String get enterFolderNameHere => 'Enter folder name here...';
	String get create => 'Create';
	String get items => 'Items';
	String get newFolderName => 'New Folder';
	String get searchFolders => 'Search folders...';
	String get searchItems => 'Search items...';
	String get createdAt => 'Created At';
	String get myFavorites => 'My Favorites';
	String get deleteFolderTitle => 'Delete Folder';
	String deleteFolderConfirmWithTitle({required Object title}) => 'Are you sure you want to delete ${title} folder?';
	String get removeItemTitle => 'Remove Item';
	String removeItemConfirmWithTitle({required Object title}) => 'Are you sure you want to delete ${title} item?';
	String get removeItemSuccess => 'Item removed from favorites';
	String get removeItemFailed => 'Failed to remove item from favorites';
	String get localizeFavorite => 'Local Favorite';
	String get editFolderTitle => 'Edit Folder';
	String get editFolderSuccess => 'Folder updated successfully';
	String get editFolderFailed => 'Failed to update folder';
	String get searchTags => 'Search tags';
}

// Path: translation
class TranslationsTranslationEn {
	TranslationsTranslationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get testConnection => 'Test Connection';
	String get testConnectionSuccess => 'Test connection success';
	String get testConnectionFailed => 'Test connection failed';
	String testConnectionFailedWithMessage({required Object message}) => 'Test connection failed: ${message}';
	String get translation => 'Translation';
	String get needVerification => 'Need Verification';
	String get needVerificationContent => 'Please test the connection first before enabling AI translation';
	String get confirm => 'Confirm';
	String get disclaimer => 'Disclaimer';
	String get riskWarning => 'Risk Warning';
	String get dureToRisk1 => 'Due to the text being generated by users, it may contain content that violates the content policy of the AI service provider';
	String get dureToRisk2 => 'Inappropriate content may lead to API key suspension or service termination';
	String get operationSuggestion => 'Operation Suggestion';
	String get operationSuggestion1 => '1. Use before strictly reviewing the content to be translated';
	String get operationSuggestion2 => '2. Avoid translating content involving violence, adult content, etc.';
	String get apiConfig => 'API Config';
	String get modifyConfigWillAutoCloseAITranslation => 'Modify configuration will automatically close AI translation, need to test again after opening';
	String get apiAddress => 'API Address';
	String get modelName => 'Model Name';
	String get modelNameHintText => 'For example: gpt-4-turbo';
	String get maxTokens => 'Max Tokens';
	String get maxTokensHintText => 'For example: 1024';
	String get temperature => 'Temperature';
	String get temperatureHintText => '0.0-2.0';
	String get clickTestButtonToVerifyAPIConnection => 'Click test button to verify API connection validity';
	String get requestPreview => 'Request Preview';
	String get enableAITranslation => 'Enable AI';
	String get enabled => 'Enabled';
	String get disabled => 'Disabled';
	String get testing => 'Testing...';
	String get testNow => 'Test Now';
	String get connectionStatus => 'Connection Status';
	String get success => 'Success';
	String get failed => 'Failed';
	String get information => 'Information';
	String get viewRawResponse => 'View Raw Response';
	String get pleaseCheckInputParametersFormat => 'Please check input parameters format';
	String get pleaseFillInAPIAddressModelNameAndKey => 'Please fill in API address, model name and key';
	String get pleaseFillInValidConfigurationParameters => 'Please fill in valid configuration parameters';
	String get pleaseCompleteConnectionTest => 'Please complete connection test';
	String get notConfigured => 'Not Configured';
	String get apiEndpoint => 'API Endpoint';
	String get configuredKey => 'Configured Key';
	String get notConfiguredKey => 'Not Configured Key';
	String get authenticationStatus => 'Authentication Status';
	String get thisFieldCannotBeEmpty => 'This field cannot be empty';
	String get apiKey => 'API Key';
	String get apiKeyCannotBeEmpty => 'API key cannot be empty';
	String get pleaseEnterValidNumber => 'Please enter valid number';
	String get range => 'Range';
	String get mustBeGreaterThan => 'Must be greater than';
	String get invalidAPIResponse => 'Invalid API response';
	String connectionFailedForMessage({required Object message}) => 'Connection failed: ${message}';
	String get aiTranslationNotEnabledHint => 'AI translation is not enabled, please enable it in settings';
	String get goToSettings => 'Go to Settings';
	String get disableAITranslation => 'Disable AI Translation';
	String get currentValue => 'Current Value';
	String get configureTranslationStrategy => 'Configure Translation Strategy';
	String get advancedSettings => 'Advanced Settings';
	String get translationPrompt => 'Translation Prompt';
	String get promptHint => 'Please enter translation prompt, use [TL] as the placeholder for the target language';
	String get promptHelperText => 'The prompt must contain [TL] as the placeholder for the target language';
	String get promptMustContainTargetLang => 'The prompt must contain [TL] placeholder';
	String get aiTranslationWillBeDisabled => 'AI translation will be disabled';
	String get aiTranslationWillBeDisabledDueToConfigChange => 'Due to the change of basic configuration, AI translation will be disabled';
	String get aiTranslationWillBeDisabledDueToPromptChange => 'Due to the change of translation prompt, AI translation will be disabled';
	String get aiTranslationWillBeDisabledDueToParamChange => 'Due to the change of parameter configuration, AI translation will be disabled';
	String get onlyOpenAIAPISupported => 'Currently only supports OpenAI-compatible API format (application/json request body)';
	String get streamingTranslation => 'Streaming Translation';
	String get streamingTranslationSupported => 'Streaming Translation Supported';
	String get streamingTranslationNotSupported => 'Streaming Translation Not Supported';
	String get streamingTranslationDescription => 'Streaming translation can display results in real-time during the translation process, providing a better user experience';
	String get usingFullUrlWithHash => 'Using full URL (ending with #)';
	String get baseUrlInputHelperText => 'When ending with #, it will be used as the actual request address';
	String currentActualUrl({required Object url}) => 'Current actual URL: ${url}';
	String get urlEndingWithHashTip => 'URL ending with # will be used directly without adding any suffix';
	String get streamingTranslationWarning => 'Note: This feature requires API service support for streaming transmission, some models may not support it';
}

// Path: linkInputDialog
class TranslationsLinkInputDialogEn {
	TranslationsLinkInputDialogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Input Link';
	String supportedLinksHint({required Object webName}) => 'Support intelligently identify multiple ${webName} links and quickly jump to the corresponding page in the app (separate links from other text with spaces)';
	String inputHint({required Object webName}) => 'Please enter ${webName} link';
	String get validatorEmptyLink => 'Please enter link';
	String validatorNoIwaraLink({required Object webName}) => 'No valid ${webName} link detected';
	String get multipleLinksDetected => 'Multiple links detected, please select one:';
	String notIwaraLink({required Object webName}) => 'Not a valid ${webName} link';
	String linkParseError({required Object error}) => 'Link parsing error: ${error}';
	String get unsupportedLinkDialogTitle => 'Unsupported Link';
	String get unsupportedLinkDialogContent => 'This link type cannot be opened directly in the app and needs to be accessed using an external browser.\n\nDo you want to open this link in a browser?';
	String get openInBrowser => 'Open in Browser';
	String get confirmOpenBrowserDialogTitle => 'Confirm Open Browser';
	String get confirmOpenBrowserDialogContent => 'The following link is about to be opened in an external browser:';
	String get confirmContinueBrowserOpen => 'Are you sure you want to continue?';
	String get browserOpenFailed => 'Failed to open link';
	String get unsupportedLink => 'Unsupported Link';
	String get cancel => 'Cancel';
	String get confirm => 'Open in Browser';
}

// Path: log
class TranslationsLogEn {
	TranslationsLogEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get logManagement => 'Log Management';
	String get enableLogPersistence => 'Enable Log Persistence';
	String get enableLogPersistenceDesc => 'Save logs to the database for analysis';
	String get logDatabaseSizeLimit => 'Log Database Size Limit';
	String logDatabaseSizeLimitDesc({required Object size}) => 'Current: ${size}';
	String get exportCurrentLogs => 'Export Current Logs';
	String get exportCurrentLogsDesc => 'Export the current application logs to help developers diagnose problems';
	String get exportHistoryLogs => 'Export History Logs';
	String get exportHistoryLogsDesc => 'Export logs within a specified date range';
	String get exportMergedLogs => 'Export Merged Logs';
	String get exportMergedLogsDesc => 'Export merged logs within a specified date range';
	String get showLogStats => 'Show Log Stats';
	String get logExportSuccess => 'Log export success';
	String logExportFailed({required Object error}) => 'Log export failed: ${error}';
	String get showLogStatsDesc => 'View statistics of various types of logs';
	String logExtractFailed({required Object error}) => 'Failed to get log statistics: ${error}';
	String get clearAllLogs => 'Clear All Logs';
	String get clearAllLogsDesc => 'Clear all log data';
	String get confirmClearAllLogs => 'Confirm Clear';
	String get confirmClearAllLogsDesc => 'Are you sure you want to clear all log data? This operation cannot be undone.';
	String get clearAllLogsSuccess => 'Log cleared successfully';
	String clearAllLogsFailed({required Object error}) => 'Failed to clear logs: ${error}';
	String get unableToGetLogSizeInfo => 'Unable to get log size information';
	String get currentLogSize => 'Current Log Size:';
	String get logCount => 'Log Count:';
	String get logCountUnit => 'logs';
	String get logSizeLimit => 'Log Size Limit:';
	String get usageRate => 'Usage Rate:';
	String get exceedLimit => 'Exceed Limit';
	String get remaining => 'Remaining';
	String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Current log size exceeded, please clean old logs or increase log size limit';
	String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Current log size almost exceeded, please clean old logs';
	String get cleaningOldLogs => 'Cleaning old logs...';
	String get logCleaningCompleted => 'Log cleaning completed';
	String get logCleaningProcessMayNotBeCompleted => 'Log cleaning process may not be completed';
	String get cleanExceededLogs => 'Clean exceeded logs';
	String get noLogsToExport => 'No logs to export';
	String get exportingLogs => 'Exporting logs...';
	String get noHistoryLogsToExport => 'No history logs to export, please try using the app for a while first';
	String get selectLogDate => 'Select Log Date';
	String get today => 'Today';
	String get selectMergeRange => 'Select Merge Range';
	String get selectMergeRangeHint => 'Please select the log time range to merge';
	String selectMergeRangeDays({required Object days}) => 'Recent ${days} days';
	String get logStats => 'Log Stats';
	String todayLogs({required Object count}) => 'Today Logs: ${count} logs';
	String recent7DaysLogs({required Object count}) => 'Recent 7 Days Logs: ${count} logs';
	String totalLogs({required Object count}) => 'Total Logs: ${count} logs';
	String get setLogDatabaseSizeLimit => 'Set Log Database Size Limit';
	String currentLogSizeWithSize({required Object size}) => 'Current Log Size: ${size}';
	String get warning => 'Warning';
	String newSizeLimit({required Object size}) => 'New size limit: ${size}';
	String get confirmToContinue => 'Confirm to continue';
	String logSizeLimitSetSuccess({required Object size}) => 'Log size limit set to ${size}';
}

// Path: common.pagination
class TranslationsCommonPaginationEn {
	TranslationsCommonPaginationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String totalItems({required Object num}) => 'Total ${num} items';
	String get jumpToPage => 'Jump to page';
	String pleaseEnterPageNumber({required Object max}) => 'Please enter page number (1-${max})';
	String get pageNumber => 'Page number';
	String get jump => 'Jump';
	String invalidPageNumber({required Object max}) => 'Please enter a valid page number (1-${max})';
	String get invalidInput => 'Please enter a valid page number';
	String get waterfall => 'Waterfall';
	String get pagination => 'Pagination';
}

// Path: forum.errors
class TranslationsForumErrorsEn {
	TranslationsForumErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pleaseSelectCategory => 'Please select a category';
	String get threadLocked => 'This thread is locked, cannot reply';
}

// Path: forum.groups
class TranslationsForumGroupsEn {
	TranslationsForumGroupsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get administration => 'Administration';
	String get global => 'Global';
	String get chinese => 'Chinese';
	String get japanese => 'Japanese';
	String get korean => 'Korean';
	String get other => 'Other';
}

// Path: forum.leafNames
class TranslationsForumLeafNamesEn {
	TranslationsForumLeafNamesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get announcements => 'Announcements';
	String get feedback => 'Feedback';
	String get support => 'Support';
	String get general => 'General';
	String get guides => 'Guides';
	String get questions => 'Questions';
	String get requests => 'Requests';
	String get sharing => 'Sharing';
	String get general_zh => 'General';
	String get questions_zh => 'Questions';
	String get requests_zh => 'Requests';
	String get support_zh => 'Support';
	String get general_ja => 'General';
	String get questions_ja => 'Questions';
	String get requests_ja => 'Requests';
	String get support_ja => 'Support';
	String get korean => 'Korean';
	String get other => 'Other';
}

// Path: forum.leafDescriptions
class TranslationsForumLeafDescriptionsEn {
	TranslationsForumLeafDescriptionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get announcements => 'Official important notifications and announcements';
	String get feedback => 'Feedback on the website\'s features and services';
	String get support => 'Help to resolve website-related issues';
	String get general => 'Discuss any topic';
	String get guides => 'Share your experiences and tutorials';
	String get questions => 'Raise your inquiries';
	String get requests => 'Post your requests';
	String get sharing => 'Share interesting content';
	String get general_zh => 'Discuss any topic';
	String get questions_zh => 'Raise your inquiries';
	String get requests_zh => 'Post your requests';
	String get support_zh => 'Help to resolve website-related issues';
	String get general_ja => 'Discuss any topic';
	String get questions_ja => 'Raise your inquiries';
	String get requests_ja => 'Post your requests';
	String get support_ja => 'Help to resolve website-related issues';
	String get korean => 'Discussions related to Korean';
	String get other => 'Other unclassified content';
}

// Path: notifications.errors
class TranslationsNotificationsErrorsEn {
	TranslationsNotificationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get unsupportedNotificationType => 'Unsupported notification type';
	String get unknownUser => 'Unknown user';
	String unsupportedNotificationTypeWithType({required Object type}) => 'Unsupported notification type: ${type}';
	String get unknownNotificationType => 'Unknown notification type';
}

// Path: conversation.errors
class TranslationsConversationErrorsEn {
	TranslationsConversationErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pleaseSelectAUser => 'Please select a user';
	String get pleaseEnterATitle => 'Please enter a title';
	String get clickToSelectAUser => 'Click to select a user';
	String get loadFailedClickToRetry => 'Load failed, click to retry';
	String get loadFailed => 'Load failed';
	String get clickToRetry => 'Click to retry';
	String get noMoreConversations => 'No more conversations';
}

// Path: splash.errors
class TranslationsSplashErrorsEn {
	TranslationsSplashErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get initializationFailed => 'Initialization failed, please restart the app';
}

// Path: download.errors
class TranslationsDownloadErrorsEn {
	TranslationsDownloadErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get imageModelNotFound => 'Image model not found';
	String get downloadFailed => 'Download failed';
	String get videoInfoNotFound => 'Video info not found';
	String get downloadTaskAlreadyExists => 'Download task already exists';
	String get videoAlreadyDownloaded => 'Video already downloaded';
	String downloadFailedForMessage({required Object errorInfo}) => 'Add download task failed: ${errorInfo}';
	String get userPausedDownload => 'User paused download';
	String get unknown => 'Unknown';
	String fileSystemError({required Object errorInfo}) => 'File system error: ${errorInfo}';
	String unknownError({required Object errorInfo}) => 'Unknown error: ${errorInfo}';
	String get connectionTimeout => 'Connection timeout';
	String get sendTimeout => 'Send timeout';
	String get receiveTimeout => 'Receive timeout';
	String serverError({required Object errorInfo}) => 'Server error: ${errorInfo}';
	String get unknownNetworkError => 'Unknown network error';
	String get serviceIsClosing => 'Download service is closing';
	String get partialDownloadFailed => 'Partial content download failed';
	String get noDownloadTask => 'No download task';
	String get taskNotFoundOrDataError => 'Task not found or data error';
	String get fileNotFound => 'File not found';
	String get openFolderFailed => 'Failed to open folder';
	String get copyDownloadUrlFailed => 'Failed to copy download URL';
	String openFolderFailedWithMessage({required Object message}) => 'Failed to open folder: ${message}';
	String get directoryNotFound => 'Directory not found';
	String get copyFailed => 'Copy failed';
	String get openFileFailed => 'Failed to open file';
	String openFileFailedWithMessage({required Object message}) => 'Failed to open file: ${message}';
	String get noDownloadSource => 'No download source';
	String get noDownloadSourceNowPleaseWaitInfoLoaded => 'No download source, please wait for information loading to be completed and try again';
	String get noActiveDownloadTask => 'No active download task';
	String get noFailedDownloadTask => 'No failed download task';
	String get noCompletedDownloadTask => 'No completed download task';
	String get taskAlreadyCompletedDoNotAdd => 'Task already completed, do not add again';
	String get linkExpiredTryAgain => 'Link expired, trying to get new download link';
	String get linkExpiredTryAgainSuccess => 'Link expired, trying to get new download link success';
	String get linkExpiredTryAgainFailed => 'Link expired, trying to get new download link failed';
	String get taskDeleted => 'Task deleted';
	String unsupportedImageFormat({required Object format}) => 'Unsupported image format: ${format}';
	String get deleteFileError => 'Failed to delete file, possibly because the file is being used by another process';
	String get deleteTaskError => 'Failed to delete task';
	String get canNotRefreshVideoTask => 'Failed to refresh video task';
	String get taskAlreadyProcessing => 'Task already processing';
	String get taskNotFound => 'Task not found';
	String get failedToLoadTasks => 'Failed to load tasks';
	String partialDownloadFailedWithMessage({required Object message}) => 'Partial download failed: ${message}';
	String unsupportedImageFormatWithMessage({required Object extension}) => 'Unsupported image format: ${extension}, you can try to download it to your device to view it';
	String get imageLoadFailed => 'Image load failed';
	String get pleaseTryOtherViewer => 'Please try using other viewers to open';
}

// Path: favorite.errors
class TranslationsFavoriteErrorsEn {
	TranslationsFavoriteErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get addFailed => 'Add failed';
	String get addSuccess => 'Add success';
	String get deleteFolderFailed => 'Delete folder failed';
	String get deleteFolderSuccess => 'Delete folder success';
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
			case 'download.forceDeleteTask': return 'Force Delete Task';
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

