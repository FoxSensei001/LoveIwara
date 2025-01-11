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
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
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
	late final TranslationsDownloadEn download = TranslationsDownloadEn._(_root);
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
	String get download => 'Download';
	String get selectQuality => 'Select Quality';
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
	String get errorOccurred => 'Error occurred, please try again later';
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
			case 'common.download': return 'Download';
			case 'common.selectQuality': return 'Select Quality';
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
			case 'errors.errorOccurred': return 'Error occurred, please try again later';
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
			case 'friends.clickToRestoreFriend': return 'Click to restore friend';
			case 'friends.friendsList': return 'Friends List';
			case 'friends.friendRequests': return 'Friend Requests';
			case 'friends.friendRequestsList': return 'Friend Requests List';
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
			case 'mediaList.personalIntroduction': return 'Personal Introduction';
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
			default: return null;
		}
	}
}

